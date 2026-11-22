-- 价值投资研究框架：计算层（手写）。每个 vi_<表>_calc 输出 id + 计算列；vi_gw_unit / vi_gw_value / vi_check 是只读报表视图。
-- 全部按公司/情景泛化，不写死公司、年份、情景名或指标代码。
-- 约定：未知值保持 NULL（不当作 0）；r <= g 时不输出价值；比率均为小数。
BEGIN;

DROP MATERIALIZED VIEW IF EXISTS vi_fin_history_cache, vi_stmt_cache CASCADE;
DROP VIEW IF EXISTS vi_metric_value CASCADE;
DROP VIEW IF EXISTS vi_check, vi_gw_value, vi_gw_unit, vi_epv_calc, vi_bs_item_calc, vi_moat_calc, vi_risk_calc, vi_collect_run_calc,
  vi_series, vi_thesis_calc, vi_fin_metric, vi_fin_history, vi_fin_history_calc, vi_collector_calc, vi_raw_capture_calc,
  vi_observation_calc, vi_obs_current, vi_disclosed, vi_metric_calc, vi_company_calc, vi_company_metric, vi_event_calc CASCADE;

---------------------------------------------------------------------------
-- 通用函数
---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION vi_num(t text) RETURNS double precision LANGUAGE sql IMMUTABLE AS $$
  SELECT CASE WHEN t ~ '^\s*[-+]?([0-9]+\.?[0-9]*|\.[0-9]+)([eE][-+]?[0-9]+)?\s*$' THEN t::double precision END
$$;

CREATE OR REPLACE FUNCTION vi_today() RETURNS date LANGUAGE sql STABLE AS $$
  SELECT (now() AT TIME ZONE 'Asia/Shanghai')::date
$$;

-- 门槛：全部公司共用一个投资回报率要求（框架与后台 / 统一设置，只有一行）
CREATE OR REPLACE FUNCTION vi_hurdle() RETURNS double precision LANGUAGE sql STABLE AS $$
  SELECT hurdle FROM vi_setting_base ORDER BY id LIMIT 1
$$;

CREATE OR REPLACE FUNCTION vi_pct(x double precision, digits int DEFAULT 1) RETURNS text LANGUAGE sql IMMUTABLE AS $$
  SELECT CASE WHEN x IS NULL THEN '—' ELSE round((x * 100)::numeric, digits)::text || '%' END
$$;

CREATE OR REPLACE FUNCTION vi_fmt(x double precision, digits int DEFAULT 2) RETURNS text LANGUAGE sql IMMUTABLE AS $$
  SELECT CASE WHEN x IS NULL THEN '—' ELSE round(x::numeric, digits)::text END
$$;

-- 解析器：把一次原始响应解析成（观察日期，数值，标识校验）。新增数据源类型时在这里加一个分支。
CREATE OR REPLACE FUNCTION vi_parse(parser text, param text, raw text,
  OUT obs_date date, OUT value double precision, OUT label_ok boolean)
LANGUAGE plpgsql IMMUTABLE AS $$
DECLARE
  u text := replace(coalesce(raw, ''), E'\\', '');   -- 去掉 JSON 转义，兼容“包装后的响应”与“纯正文”
  parts text[]; hdr text; labels text[]; vals text[]; idx int; obj text; stcd text; fld text; d text;
BEGIN
  label_ok := false;
  IF parser = 'tencent_quote' THEN                       -- 腾讯行情：v_sh600900="1~名称~600900~现价~…~日期时间~…"（港股日期为 2026/10/22 16:08:42）
    parts := string_to_array(raw, '~');
    label_ok := parts[3] = regexp_replace(param, '^[a-zA-Z]+', '');
    value := vi_num(parts[4]);
    d := left(regexp_replace(coalesce(parts[31], ''), '[^0-9]', '', 'g'), 8);
    IF d ~ '^[0-9]{8}$' THEN obs_date := to_date(d, 'YYYYMMDD'); END IF;
  ELSIF parser = 'tencent_fx' THEN                       -- 腾讯外汇：v_whHKDCNY="310~港元人民币~HKDCNY~现价~0~20261022193603~…"
    parts := string_to_array(raw, '~');
    label_ok := parts[3] = upper(regexp_replace(param, '^(wh|fx)', ''));
    value := vi_num(parts[4]);
    d := left(parts[6], 8);
    IF d ~ '^[0-9]{8}$' THEN obs_date := to_date(d, 'YYYYMMDD'); END IF;
  ELSIF parser = 'chinabond_curve' THEN                  -- 中债收益率曲线页面：按表头找期限所在列
    u := regexp_replace(u, '<!--.*?-->', '', 'g');
    d := (regexp_match(u, '<th>([0-9]{4}-[0-9]{2}-[0-9]{2})'))[1];
    IF d IS NOT NULL THEN obs_date := d::date; END IF;
    -- 表头行：从日期列开始到该行结束；数据行：“中债国债收益率曲线”所在行（用字符串切片，避免正则贪婪匹配越界）
    hdr := split_part(substr(u, strpos(u, '<th>' || coalesce(d, '#'))), '</tr>', 1);
    labels := ARRAY(SELECT btrim((regexp_matches(hdr, '<th[^>]*>([^<]*)</th>', 'g'))[1]));
    idx := array_position(labels, param) - 1;          -- 第 1 个表头是日期列
    vals := ARRAY(SELECT (regexp_matches(split_part(split_part(u, '中债国债收益率曲线</td>', 2), '</tr>', 1),
                                         '<td[^>]*>\s*([0-9.]+)\s*</td>', 'g'))[1]);
    IF idx IS NOT NULL THEN value := vi_num(vals[idx]); label_ok := true; END IF;
  ELSIF parser = 'cjh_reservoir' THEN                    -- 长江水文网水情：站码:字段（z 水位，q 入库，oq 出库）
    stcd := split_part(param, ':', 1); fld := split_part(param, ':', 2);
    obj := (regexp_match(u, '([{][^{}]*"stcd":"' || stcd || '"[^{}]*[}])'))[1];
    IF obj IS NOT NULL THEN
      label_ok := true;
      value := vi_num((regexp_match(obj, '"' || fld || '":"?([0-9.]+)'))[1]);
      d := (regexp_match(obj, '"tm":([0-9]+)'))[1];
      IF d IS NOT NULL THEN obs_date := (to_timestamp(d::double precision / 1000) AT TIME ZONE 'Asia/Shanghai')::date; END IF;
    END IF;
  ELSIF parser = 'sina_future' THEN                      -- 新浪期货：var hq_str_nf_SP0="名称,时间,开,高,低,…,最新价(第9段),…,日期(第18段),…"
    label_ok := strpos(coalesce(raw, ''), 'hq_str_nf_' || param || '="') > 0;
    parts := string_to_array(split_part(coalesce(raw, ''), '"', 2), ',');
    value := vi_num(parts[9]);
    d := parts[18];
    IF d ~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' THEN obs_date := d::date; END IF;
  END IF;
END $$;

---------------------------------------------------------------------------
-- 数据（每期数值）。口径记在每一行上；同一指标、同一口径、同一日期多次采集时取最后一次为当前版本
---------------------------------------------------------------------------
CREATE VIEW vi_observation_calc AS
SELECT o.id, m.unit, m.measure, m.source_kind,
       row_number() OVER (PARTITION BY o.metric_id, o.basis, o.obs_date ORDER BY o.collected_at DESC NULLS LAST, o.id DESC) = 1 AS is_current,
       (o.value IS NOT NULL
        AND o.value >= coalesce(m.valid_min, '-infinity'::float8)
        AND o.value <= coalesce(m.valid_max, 'infinity'::float8)) AS is_valid
FROM vi_observation_base o LEFT JOIN vi_metric_base m ON m.id = o.metric_id;

-- 事项：挂了几个侧面（定性事实）、最近一个侧面的截至日期
CREATE VIEW vi_event_calc AS
SELECT e.id, count(f.id)::int AS fact_count, max(f.as_of) AS latest_as_of
FROM vi_event_base e LEFT JOIN vi_fact_base f ON f.event_id = e.id
GROUP BY e.id;

-- 每个指标的“当前且有效”数据（供其他视图引用）
-- 写成“没有更新的同期同口径数据”，按指标走索引（单个指标取最新值时不用把全部数据排一遍）
CREATE VIEW vi_obs_current AS
SELECT o.metric_id, o.basis, o.period, o.obs_date, o.value, o.yoy, o.id
FROM vi_observation_base o JOIN vi_metric_base m ON m.id = o.metric_id
WHERE o.value IS NOT NULL AND o.value >= coalesce(m.valid_min, '-infinity'::float8) AND o.value <= coalesce(m.valid_max, 'infinity'::float8)
  AND NOT EXISTS (SELECT 1 FROM vi_observation_base o2
                  WHERE o2.metric_id = o.metric_id AND o2.obs_date = o.obs_date AND o2.basis IS NOT DISTINCT FROM o.basis
                    AND (o2.collected_at > o.collected_at OR (o2.collected_at IS NOT NULL AND o.collected_at IS NULL)
                         OR (o2.collected_at IS NOT DISTINCT FROM o.collected_at AND o2.id > o.id)));

-- 报表计算：指标的“报表公式”从三大报表（vi_fin_stmt_base）实时算出各口径的数，不另存。
-- 公式写法：科目相加相减，如“应收账款 + 合同资产”“−资产减值损失 − 信用减值损失”；比率用“÷”，两边各是一组科目，
--   如“（营业收入 − 营业成本）÷ 营业收入”“毛利 ÷ 营业额”，结果×100（单位 %）。科目名与报表一致；同名科目出现在
--   多张报表时写成“资产负债表：科目”。缺项按 0 计，整组都缺则该期为空。
-- 口径：利润表、现金流量表在报表里是年初至今累计——单季＝本期累计−上季累计（一季度即累计），滚动四季度＝本期累计＋上年全年−上年同期累计，
--   四季度的累计记为“全年”（期间写年份），一至三季度记为“年初至今累计”；只含资产负债表科目的公式为“时点”（期末余额）。
-- 同比＝本期÷上年同期−1（上年同期不为正时不算；比率不算同比）。
CREATE OR REPLACE FUNCTION vi_stmt_series(p_company bigint, p_formula text)
RETURNS TABLE (basis text, period text, period_end date, value double precision, yoy double precision)
LANGUAGE sql STABLE SET search_path = public AS $fn$   -- 固定查找路径：pg_dump 恢复时会清空 search_path
WITH s AS (
  SELECT ord::int AS side, btrim(regexp_replace(btrim(x), '^（(.*)）$', '\1')) AS expr
  FROM unnest(string_to_array(p_formula, '÷')) WITH ORDINALITY u(x, ord)
), t AS (
  SELECT s.side, CASE WHEN m[1] IN ('−', '－', '-') THEN -1 ELSE 1 END AS sign, btrim(m[2]) AS term
  FROM s, regexp_matches(s.expr, '([+＋−－-]?)\s*([^+＋−－-]+)', 'g') m
  WHERE btrim(m[2]) <> ''
), r AS (
  SELECT t.side, t.sign,
         CASE WHEN t.term ~ '^(利润表|资产负债表|现金流量表)[:：]' THEN substring(t.term FROM '^(利润表|资产负债表|现金流量表)') END AS stmt0,
         btrim(regexp_replace(t.term, '^(利润表|资产负债表|现金流量表)[:：]', '')) AS item
  FROM t
), r2 AS (
  SELECT r.side, r.sign, r.item,
         coalesce(r.stmt0, (SELECT min(f.stmt) FROM vi_fin_stmt_base f WHERE f.company_id = p_company AND f.item = r.item)) AS stmt
  FROM r
), q AS (
  SELECT r2.side, f.period, max(f.period_end) AS pe, sum(r2.sign * f.amount) AS v,
         substr(f.period, 1, 4)::int AS y, right(f.period, 1)::int AS qn
  FROM r2 JOIN vi_fin_stmt_base f ON f.company_id = p_company AND f.item = r2.item AND f.stmt = r2.stmt AND f.amount IS NOT NULL
  WHERE f.period ~ '^\d{4}Q[1-4]$'
  GROUP BY r2.side, f.period
), flow AS (
  SELECT coalesce(bool_or(stmt <> '资产负债表'), false) AS is_flow, count(DISTINCT side) AS sides FROM r2
), c AS (
  SELECT a.side, a.period, a.pe, a.y, a.qn, a.v AS ytd,
         a.v - CASE WHEN a.qn = 1 THEN 0 ELSE p.v END AS sq,
         a.v + fy.v - ly.v AS ttm
  FROM q a
  LEFT JOIN q p ON p.side = a.side AND p.y = a.y AND p.qn = a.qn - 1
  LEFT JOIN q fy ON fy.side = a.side AND fy.y = a.y - 1 AND fy.qn = 4
  LEFT JOIN q ly ON ly.side = a.side AND ly.y = a.y - 1 AND ly.qn = a.qn
), b AS (
  SELECT c.side, k.basis, k.period, c.pe, c.y, c.qn, k.v
  FROM c CROSS JOIN flow
  CROSS JOIN LATERAL (VALUES
    ('单季', c.period, c.sq, flow.is_flow),
    ('滚动四季度', c.period, c.ttm, flow.is_flow),
    (CASE WHEN c.qn = 4 THEN '全年' ELSE '年初至今累计' END, CASE WHEN c.qn = 4 THEN c.y::text ELSE c.period END, c.ytd, flow.is_flow),
    ('时点', c.period, c.ytd, NOT flow.is_flow)
  ) k(basis, period, v, keep)
  WHERE k.keep AND k.v IS NOT NULL
), v AS (
  SELECT n.basis, n.period, n.pe, n.y, n.qn,
         CASE WHEN (SELECT sides FROM flow) = 1 THEN n.v
              WHEN d.v IS NOT NULL AND d.v <> 0 THEN n.v / d.v * 100 END AS value,
         (SELECT sides FROM flow) > 1 AS ratio
  FROM b n LEFT JOIN b d ON d.side = 2 AND d.basis = n.basis AND d.period = n.period
  WHERE n.side = 1
)
SELECT v.basis, v.period, v.pe, v.value,
       CASE WHEN NOT v.ratio AND l.value > 0 THEN v.value / l.value - 1 END
FROM v
LEFT JOIN v l ON l.basis = v.basis AND l.y = v.y - 1 AND l.qn = v.qn
WHERE v.value IS NOT NULL
$fn$;

-- 报表计算的结果缓存：由数据库自动维护（三大报表或指标公式一变就整体刷新），不是手工数据；其他视图都读它，避免每次重算公式
CREATE MATERIALIZED VIEW vi_stmt_cache AS
SELECT m.id AS metric_id, s.basis, s.period, s.period_end, s.value, s.yoy
FROM vi_metric_base m CROSS JOIN LATERAL vi_stmt_series(m.company_id, m.formula) s
WHERE m.source_kind = '报表计算' AND nullif(btrim(m.formula), '') IS NOT NULL;
CREATE INDEX ON vi_stmt_cache (metric_id, basis, period);

CREATE OR REPLACE FUNCTION vi_refresh_stmt_cache() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  REFRESH MATERIALIZED VIEW vi_stmt_cache;
  IF to_regclass('vi_fin_history_cache') IS NOT NULL THEN REFRESH MATERIALIZED VIEW vi_fin_history_cache; END IF;
  RETURN NULL;
END $$;
DROP TRIGGER IF EXISTS vi_fin_stmt_refresh ON vi_fin_stmt_base;
CREATE TRIGGER vi_fin_stmt_refresh AFTER INSERT OR UPDATE OR DELETE OR TRUNCATE ON vi_fin_stmt_base
  FOR EACH STATEMENT EXECUTE FUNCTION vi_refresh_stmt_cache();
DROP TRIGGER IF EXISTS vi_metric_stmt_ins ON vi_metric_base;
CREATE TRIGGER vi_metric_stmt_ins AFTER INSERT ON vi_metric_base FOR EACH ROW WHEN (NEW.source_kind = '报表计算')
  EXECUTE FUNCTION vi_refresh_stmt_cache();
DROP TRIGGER IF EXISTS vi_metric_stmt_upd ON vi_metric_base;
CREATE TRIGGER vi_metric_stmt_upd AFTER UPDATE ON vi_metric_base FOR EACH ROW
  WHEN (OLD.formula IS DISTINCT FROM NEW.formula OR OLD.source_kind IS DISTINCT FROM NEW.source_kind OR OLD.company_id IS DISTINCT FROM NEW.company_id)
  EXECUTE FUNCTION vi_refresh_stmt_cache();
DROP TRIGGER IF EXISTS vi_metric_stmt_del ON vi_metric_base;
CREATE TRIGGER vi_metric_stmt_del AFTER DELETE ON vi_metric_base FOR EACH ROW WHEN (OLD.source_kind = '报表计算')
  EXECUTE FUNCTION vi_refresh_stmt_cache();

-- 每个指标的全部数值（唯一入口）：「数据」里存的当前有效值 ＋ 报表计算指标从三大报表实时算出的值。
-- 报表计算的指标在「数据」里录了某期某口径的数（追溯调整、口径不同），以录的为准，算出的那期不再出现。
CREATE VIEW vi_series AS
SELECT o.metric_id, o.basis, o.period, o.obs_date, o.value, o.yoy, o.id AS observation_id
FROM vi_obs_current o
UNION ALL
SELECT s.metric_id, s.basis, s.period, s.period_end, s.value, s.yoy, NULL::bigint
FROM vi_stmt_cache s
LEFT JOIN vi_observation_base o ON o.metric_id = s.metric_id AND o.basis = s.basis AND o.period = s.period
WHERE o.id IS NULL;

-- 公司的定期数据（披露＋报表计算），按“期间 × 项目 × 口径”展开（驾驶舱图表、核对脚本读这里）
CREATE VIEW vi_disclosed AS
SELECT x.observation_id AS id, m.company_id, x.period, x.obs_date AS period_end, x.basis AS period_kind, m.name AS line_item, x.value, m.unit, x.yoy,
       o.summary, o.doc_id AS source_id, m.id AS metric_id, m.code AS metric_code
FROM vi_series x JOIN vi_metric_base m ON m.id = x.metric_id
LEFT JOIN vi_observation_base o ON o.id = x.observation_id
WHERE m.company_id IS NOT NULL AND m.source_kind <> '自动采集';

-- 指标数值（只读，给页面读）：每个指标每期每口径一行；“取值”标明是录入的还是报表算的
CREATE VIEW vi_metric_value AS
SELECT CASE WHEN x.observation_id IS NOT NULL THEN x.observation_id
            ELSE -(x.metric_id * 1000000 + abs(hashtext(x.basis || '|' || x.period)) % 1000000) END AS id,
       x.metric_id, m.company_id, x.period, x.basis, x.obs_date, x.value, x.yoy, m.unit,
       CASE WHEN x.observation_id IS NULL THEN '报表计算' ELSE '录入' END AS origin,
       o.summary, o.doc_id, d.title AS doc_title
FROM vi_series x JOIN vi_metric_base m ON m.id = x.metric_id
LEFT JOIN vi_observation_base o ON o.id = x.observation_id
LEFT JOIN vi_source_base d ON d.id = o.doc_id;

-- 指标性质与口径一致：时点指标（存量）每期口径只能是“时点”，时期指标（流量）不能用“时点”；指标性质留空的不检查
CREATE OR REPLACE FUNCTION vi_measure_basis_guard() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE ms text; nm text; bad text;
BEGIN
  IF TG_TABLE_NAME = 'vi_observation_base' THEN
    SELECT measure, name INTO ms, nm FROM vi_metric_base WHERE id = NEW.metric_id;
    IF ms = '时点' AND NEW.basis IS DISTINCT FROM '时点' THEN
      RAISE EXCEPTION '指标“%”是时点指标（存量），每期口径只能是“时点”，这一期写的是“%”', nm, NEW.basis;
    ELSIF ms = '时期' AND NEW.basis = '时点' THEN
      RAISE EXCEPTION '指标“%”是时期指标（流量），口径不能是“时点”，请选单季、全年等', nm;
    END IF;
  ELSE
    IF NEW.measure = '时点' AND NEW.basis IS DISTINCT FROM '时点' THEN
      RAISE EXCEPTION '指标“%”是时点指标，主口径只能是“时点”', NEW.name;
    ELSIF NEW.measure = '时期' AND NEW.basis = '时点' THEN
      RAISE EXCEPTION '指标“%”是时期指标，主口径不能是“时点”，请选单季、全年等', NEW.name;
    END IF;
    IF NEW.measure IS NOT NULL THEN
      SELECT string_agg(DISTINCT o.basis, '、') INTO bad FROM vi_observation_base o
       WHERE o.metric_id = NEW.id AND ((NEW.measure = '时点' AND o.basis IS DISTINCT FROM '时点') OR (NEW.measure = '时期' AND o.basis = '时点'));
      IF bad IS NOT NULL THEN
        RAISE EXCEPTION '指标“%”已有口径为“%”的数据，与“%指标”不符；先改这些数据的口径', NEW.name, bad, NEW.measure;
      END IF;
    END IF;
  END IF;
  RETURN NEW;
END $$;
DROP TRIGGER IF EXISTS vi_observation_measure_guard ON vi_observation_base;
CREATE TRIGGER vi_observation_measure_guard BEFORE INSERT OR UPDATE OF metric_id, basis ON vi_observation_base
  FOR EACH ROW EXECUTE FUNCTION vi_measure_basis_guard();
DROP TRIGGER IF EXISTS vi_metric_measure_guard ON vi_metric_base;
CREATE TRIGGER vi_metric_measure_guard BEFORE INSERT OR UPDATE OF measure, basis ON vi_metric_base
  FOR EACH ROW EXECUTE FUNCTION vi_measure_basis_guard();

-- 写入一条公司披露的数据：按 公司×项目×口径×单位 找指标，没有就新建（代码＝公司代码.D001 起顺序编号）；
-- 同一指标同一期间已有的数据先删掉再写，可重复执行。种子脚本和迁移都用它，规则只写一处。
-- 业务驱动与财务结果分域；合同额/合约销售额和 ARPPU 是业务，不能仅按金额单位判断。
CREATE OR REPLACE FUNCTION vi_disclosed_category(p_item text) RETURNS text LANGUAGE sql IMMUTABLE AS $$
SELECT CASE WHEN p_item = ANY(ARRAY['AIoT平台连接设备数（不含手机和平板）', '全球月活跃用户', '全球月活跃用户（12 月）', '单个付费用户月均收入（ARPPU）', '发电量', '在线音乐付费用户', '在线音乐月活跃用户', '地产合约销售额', '建筑业务新签合同额', '建筑新签占全国比重', '房屋建筑新开工面积', '清收政府逾期债权', '实现售电价', '拥有五件及以上AIoT设备的用户数', '新签合同总额', '智能手机ASP', '智能手机出货量', '汽车ASP', '汽车交付量', '浆纸销量（管理层口径）', '竞品月活：汽水音乐']) THEN '经营'
            WHEN p_item ~ '收入|利润|毛利|费用|开支|损益|现金|负债|借款|应收|应付|减值|回购|股息|收益' THEN '财务'
            ELSE '其他' END
$$;

DROP FUNCTION IF EXISTS vi_put_disclosed(bigint, text, text, text, text, date, double precision, double precision, text, text, text, text, bigint);
CREATE OR REPLACE FUNCTION vi_put_disclosed(p_company bigint, p_item text, p_basis text, p_unit text, p_period text, p_end date,
                                            p_value double precision, p_yoy double precision, p_summary text, p_doc bigint) RETURNS bigint LANGUAGE plpgsql AS $$
DECLARE mid bigint; kind text; ccode text; n int; oid bigint;
BEGIN
  -- 一个指标一行：按 公司×名称×单位 找（口径记在每期数据上）
  SELECT id, source_kind INTO mid, kind FROM vi_metric_base
   WHERE company_id = p_company AND source_kind <> '自动采集' AND name = p_item AND unit IS NOT DISTINCT FROM p_unit
   ORDER BY id LIMIT 1;
  IF kind = '报表计算' THEN
    RETURN NULL;                         -- 派生值不手填：这个数由三大报表算出
  END IF;
  IF mid IS NULL THEN
    SELECT code INTO ccode FROM vi_company_base WHERE id = p_company;
    SELECT coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1 INTO n FROM vi_metric_base WHERE code LIKE ccode || '.D%';
    INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency)
    VALUES (ccode || '.D' || lpad(n::text, 3, '0'), p_item, p_unit, vi_disclosed_category(p_item), '公司披露', p_basis, p_company, '公司披露',
            CASE p_basis WHEN '单季' THEN '季' WHEN '时点' THEN '季' WHEN '半年累计' THEN '半年' WHEN '前三季度累计' THEN '年' WHEN '全年' THEN '年' END)
    RETURNING id INTO mid;
  END IF;
  DELETE FROM vi_observation_base WHERE metric_id = mid AND period IS NOT DISTINCT FROM p_period AND basis IS NOT DISTINCT FROM p_basis;
  INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, yoy, summary, doc_id, collected_at)
  VALUES (mid, p_end, p_period, p_basis, p_value, p_yoy, p_summary, p_doc, now())
  RETURNING id INTO oid;
  RETURN oid;
END $$;

-- 把一家公司“与三大报表重复”的指标改成报表计算：写上公式，删掉另存的数（迁移和种子共用）
CREATE OR REPLACE FUNCTION vi_metric_to_stmt(p_company bigint, p_name text, p_unit text, p_formula text, p_basis text) RETURNS bigint
LANGUAGE plpgsql AS $$
DECLARE mid bigint;
BEGIN
  SELECT id INTO mid FROM vi_metric_base WHERE company_id = p_company AND name = p_name AND unit IS NOT DISTINCT FROM p_unit ORDER BY id LIMIT 1;
  IF mid IS NULL THEN RETURN NULL; END IF;
  UPDATE vi_metric_base SET source_kind = '报表计算', formula = p_formula, basis = p_basis, source_name = '财务数据（三大报表）：' || p_formula
   WHERE id = mid;
  DELETE FROM vi_observation_base WHERE metric_id = mid;
  RETURN mid;
END $$;

-- 一家公司里同名同单位的指标合成一个（口径已记在每期数据上）：保留被假设依据/风险关联的、否则编号最小的，引用全部改指向它
CREATE OR REPLACE FUNCTION vi_merge_company_metrics(p_company bigint) RETURNS int LANGUAGE plpgsql AS $$
DECLARE g record; keep bigint; d bigint; n int := 0;
BEGIN
  FOR g IN SELECT name, unit, array_agg(id ORDER BY
             (EXISTS (SELECT 1 FROM vi_lnk_judgment_metrics l WHERE l.metric_id = m.id) OR EXISTS (SELECT 1 FROM vi_lnk_risk_metrics l WHERE l.metric_id = m.id)) DESC, id) AS ids
           FROM vi_metric_base m WHERE company_id = p_company GROUP BY name, unit HAVING count(*) > 1 LOOP
    keep := g.ids[1];
    FOREACH d IN ARRAY g.ids[2:] LOOP
      UPDATE vi_observation_base SET metric_id = keep WHERE metric_id = d;
      UPDATE vi_collector_base SET metric_id = keep WHERE metric_id = d;
      UPDATE vi_company_base SET price_metric_id = keep WHERE price_metric_id = d;
      UPDATE vi_company_base SET price_fx_metric_id = keep WHERE price_fx_metric_id = d;
      INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id) SELECT judgment_id, keep FROM vi_lnk_judgment_metrics WHERE metric_id = d ON CONFLICT DO NOTHING;
      INSERT INTO vi_lnk_risk_metrics (risk_id, metric_id) SELECT risk_id, keep FROM vi_lnk_risk_metrics WHERE metric_id = d ON CONFLICT DO NOTHING;
      DELETE FROM vi_metric_base WHERE id = d;
      n := n + 1;
    END LOOP;
  END LOOP;
  RETURN n;
END $$;

-- 每家公司用到哪些指标、做什么用（唯一来源，不另存）：自有指标、股价、股价汇率、重点跟踪（假设依据、风险关联的指标）、订阅的宏观数据。
-- 指标的“使用公司”、公司的“用到的宏观数据”、一键采集的范围都从这里读。
CREATE VIEW vi_company_metric AS
SELECT company_id, metric_id, string_agg(DISTINCT usage, '、' ORDER BY usage) AS usages
FROM (
  SELECT company_id, id AS metric_id, '自有' AS usage FROM vi_metric_base WHERE company_id IS NOT NULL
  UNION ALL SELECT id, price_metric_id, '股价' FROM vi_company_base WHERE price_metric_id IS NOT NULL
  UNION ALL SELECT id, price_fx_metric_id, '汇率折算' FROM vi_company_base WHERE price_fx_metric_id IS NOT NULL
  UNION ALL SELECT j.company_id, l.metric_id, '重点跟踪' FROM vi_lnk_judgment_metrics l JOIN vi_judgment_base j ON j.id = l.judgment_id WHERE j.company_id IS NOT NULL
  UNION ALL SELECT r.company_id, l.metric_id, '重点跟踪' FROM vi_lnk_risk_metrics l JOIN vi_risk_base r ON r.id = l.risk_id WHERE r.company_id IS NOT NULL
  UNION ALL SELECT company_id, metric_id, '订阅' FROM vi_lnk_company_macro_metrics
) u
GROUP BY company_id, metric_id;

-- 指标的最新值按“主口径”取（没有主口径的数据时取最新一期）；状态只看数据是否到期：最新一期日期＋频率对应的披露间隔
CREATE VIEW vi_metric_calc AS
SELECT m.id,
       (SELECT count(*) FROM vi_series x WHERE x.metric_id = m.id)::int AS obs_count,
       l.value AS latest_value, l.period AS latest_period, l.obs_date AS latest_date,
       CASE WHEN m.company_id IS NULL THEN '宏观' ELSE '公司' END AS scope,
       u.used_by, u.used_by_codes,
       CASE WHEN l.obs_date IS NULL THEN '未记录' WHEN d.due < vi_today() THEN '待更新' ELSE '已更新' END AS state,
       d.due AS next_due, t.tracked_by, t.tracked_codes, tr.trend,
       array_position(ARRAY['volume', 'revenue', 'cost_of_sales', 'pretax_profit', 'income_tax', 'np_parent', 'minority_profit', 'da', 'finance_cost', 'invest_income', 'equity_income', 'cfo', 'capex', 'investee_cash_div', 'net_borrowing', 'interest_debt', 'cash', 'equity_parent', 'dividend_total', 'dps'], m.model_field) AS model_order
FROM vi_metric_base m
LEFT JOIN LATERAL (SELECT value, period, obs_date FROM vi_series x WHERE x.metric_id = m.id
                   ORDER BY (x.basis IS NOT DISTINCT FROM m.basis) DESC, obs_date DESC LIMIT 1) l ON true
-- 趋势（表格里的小折线）：主口径最近 12 期，日度数据取最近 60 个交易日；按时间先后，[[统计时间, 数值], …]
-- 主口径不足两期时改用数据最多的口径（如累计口径只有今年一期、全年数有多年），折线下方的起止统计时间能看出口径
LEFT JOIN LATERAL (
  SELECT x.basis AS basis FROM vi_series x WHERE x.metric_id = m.id AND x.value IS NOT NULL GROUP BY x.basis
  ORDER BY (x.basis IS NOT DISTINCT FROM m.basis AND count(*) >= 2) DESC, count(*) DESC, max(x.obs_date) DESC LIMIT 1
) tb ON true
LEFT JOIN LATERAL (
  SELECT json_agg(json_build_array(coalesce(z.period, z.obs_date::text), round(z.value::numeric, 4)) ORDER BY z.obs_date)::text AS trend
  FROM (SELECT x.period, x.obs_date, x.value FROM vi_series x
        WHERE x.metric_id = m.id AND x.basis IS NOT DISTINCT FROM tb.basis AND x.value IS NOT NULL
        ORDER BY x.obs_date DESC
        LIMIT CASE WHEN m.frequency IN ('交易日', '工作日', '日') THEN 60 ELSE 12 END) z
) tr ON true
CROSS JOIN LATERAL (
  SELECT (l.obs_date + CASE WHEN m.frequency IN ('交易日', '工作日', '日') THEN interval '5 days' WHEN m.frequency = '周' THEN interval '12 days'
          WHEN m.frequency IN ('月', '月度') THEN interval '55 days' WHEN m.frequency IN ('季', '季度') THEN interval '4 months'
          WHEN m.frequency = '半年' THEN interval '10 months' WHEN m.frequency = '年' THEN interval '16 months' END)::date AS due
) d
LEFT JOIN LATERAL (
  SELECT string_agg(z.txt, '；' ORDER BY z.cid) AS tracked_by, ',' || string_agg(z.code, ',' ORDER BY z.cid) || ',' AS tracked_codes
  FROM (SELECT c.id AS cid, c.code, CASE WHEN m.company_id IS NULL THEN c.name || ' ' ELSE '' END || string_agg(DISTINCT u.code, '、' ORDER BY u.code) AS txt
        FROM (SELECT j.company_id, j.code FROM vi_lnk_judgment_metrics l JOIN vi_judgment_base j ON j.id = l.judgment_id WHERE l.metric_id = m.id
              UNION ALL SELECT r.company_id, r.code FROM vi_lnk_risk_metrics l JOIN vi_risk_base r ON r.id = l.risk_id WHERE l.metric_id = m.id) u
        JOIN vi_company_base c ON c.id = u.company_id GROUP BY c.id, c.code, c.name) z
) t ON true
LEFT JOIN LATERAL (SELECT string_agg(c.name || '（' || cm.usages || '）', '；' ORDER BY c.id) AS used_by,
                          ',' || string_agg(c.code, ',' ORDER BY c.id) || ',' AS used_by_codes
                   FROM vi_company_metric cm JOIN vi_company_base c ON c.id = cm.company_id
                   WHERE cm.metric_id = m.id) u ON true;

-- 订阅只能指向宏观数据；已被订阅的宏观指标不能再划归某家公司
CREATE OR REPLACE FUNCTION vi_macro_subscription_check() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_TABLE_NAME = 'vi_lnk_company_macro_metrics' THEN
    IF EXISTS (SELECT 1 FROM vi_metric_base WHERE id = NEW.metric_id AND company_id IS NOT NULL) THEN
      RAISE EXCEPTION '只能订阅宏观数据（所属公司为空的指标）；指标 % 属于某家公司', NEW.metric_id;
    END IF;
  ELSIF NEW.company_id IS NOT NULL AND EXISTS (SELECT 1 FROM vi_lnk_company_macro_metrics WHERE metric_id = NEW.id) THEN
    RAISE EXCEPTION '指标 % 已被公司订阅为宏观数据，不能划归某家公司（先取消订阅）', NEW.id;
  END IF;
  RETURN NEW;
END $$;
DROP TRIGGER IF EXISTS vi_lnk_company_macro_metrics_check ON vi_lnk_company_macro_metrics;
CREATE TRIGGER vi_lnk_company_macro_metrics_check BEFORE INSERT OR UPDATE ON vi_lnk_company_macro_metrics
  FOR EACH ROW EXECUTE FUNCTION vi_macro_subscription_check();
DROP TRIGGER IF EXISTS vi_metric_base_macro_check ON vi_metric_base;
CREATE TRIGGER vi_metric_base_macro_check BEFORE UPDATE OF company_id ON vi_metric_base
  FOR EACH ROW EXECUTE FUNCTION vi_macro_subscription_check();

-- 股价币种与记账币种不同时（港股、美股），按股价日或之前最近一个有效汇率折成记账币种；有汇率指标但没有汇率观察时不输出股价
CREATE VIEW vi_company_calc AS
SELECT c.id,
       CASE WHEN c.price_fx_metric_id IS NULL THEN l.value ELSE l.value * fx.value END AS latest_price,
       l.obs_date AS latest_price_date, l.value AS latest_price_raw, fx.value AS latest_fx, mu.macro_used
FROM vi_company_base c
LEFT JOIN LATERAL (SELECT value, obs_date FROM vi_obs_current x WHERE x.metric_id = c.price_metric_id
                   ORDER BY obs_date DESC LIMIT 1) l ON true
LEFT JOIN LATERAL (SELECT value FROM vi_obs_current x WHERE x.metric_id = c.price_fx_metric_id AND x.obs_date <= l.obs_date
                   ORDER BY obs_date DESC LIMIT 1) fx ON true
LEFT JOIN LATERAL (SELECT string_agg(m.name || '（' || cm.usages || '）', '；' ORDER BY m.id) AS macro_used
                   FROM vi_company_metric cm JOIN vi_metric_base m ON m.id = cm.metric_id
                   WHERE cm.company_id = c.id AND m.company_id IS NULL) mu ON true;

---------------------------------------------------------------------------
-- 自动采集：原始记录 → 解析 → 校验 → 去重判断
---------------------------------------------------------------------------
CREATE VIEW vi_raw_capture_calc AS
WITH p AS (
  SELECT r.id, r.status, r.collected_at, k.metric_id, m.valid_min, m.valid_max, x.*,
         CASE WHEN r.fetch_result IS NULL THEN coalesce(length(r.raw_response), 0) > 0
              ELSE r.fetch_result ~ '^HTTP 2[0-9]{2}' AND coalesce(length(r.raw_response), 0) > 0 END AS fetch_ok,
         CASE WHEN r.fetch_result IS NULL THEN CASE WHEN coalesce(length(r.raw_response), 0) > 0 THEN '成功（迁移记录）' ELSE '无响应（迁移记录）' END
              WHEN r.fetch_result ~ '^HTTP 2[0-9]{2}' AND coalesce(length(r.raw_response), 0) > 0 THEN '成功 · HTTP ' || substr(r.fetch_result, 6, 3)
              WHEN r.fetch_result ~ '^HTTP 2[0-9]{2}' THEN '空响应 · HTTP ' || substr(r.fetch_result, 6, 3)
              WHEN r.fetch_result ~ '^HTTP [0-9]{3}' THEN '网站返回错误 · HTTP ' || substr(r.fetch_result, 6, 3)
              ELSE '连接失败（网络、代理或网站拒绝）· ' || regexp_replace(btrim(substr(r.fetch_result, 5)), '\s+', ' ', 'g') END AS fetch_note
  FROM vi_raw_capture_base r
  LEFT JOIN vi_collector_base k ON k.id = r.collector_id
  LEFT JOIN vi_metric_base m ON m.id = k.metric_id
  LEFT JOIN LATERAL vi_parse(k.parser, k.parser_param, r.raw_response) x ON true
), v AS (
  SELECT p.*,
         (obs_date IS NOT NULL AND value IS NOT NULL AND label_ok
          AND ((collected_at AT TIME ZONE 'Asia/Shanghai')::date - obs_date) BETWEEN 0 AND 7
          AND value >= coalesce(valid_min, '-infinity'::float8)
          AND value <= coalesce(valid_max, 'infinity'::float8)) AS is_valid
  FROM p
), w AS (
  SELECT v.*,
         EXISTS (SELECT 1 FROM vi_observation_base o
                  WHERE o.metric_id = v.metric_id AND o.obs_date = v.obs_date AND o.value = v.value) AS already_exists,
         row_number() OVER (PARTITION BY v.metric_id, v.obs_date, v.value, v.is_valid ORDER BY v.collected_at, v.id) AS dup_rank
  FROM v
)
SELECT id, fetch_ok, fetch_note, obs_date AS parsed_date, value AS parsed_value, is_valid, already_exists,
       CASE WHEN status = '采集中' THEN '采集未完成'
            WHEN NOT fetch_ok THEN '抓取失败'
            WHEN NOT is_valid THEN '校验失败'
            WHEN already_exists THEN '重复：已有相同观察'
            WHEN dup_rank > 1 THEN '重复：同批次已有相同记录'
            ELSE '可入库' END AS decision
FROM w;

CREATE VIEW vi_collector_calc AS
WITH k AS (
  SELECT c.id, c.enabled, c.max_lag_days, c.metric_id,
         (SELECT max(r.collected_at) FROM vi_raw_capture_base r WHERE r.collector_id = c.id) AS last_collected,
         (SELECT max(o.obs_date) FROM vi_obs_current o WHERE o.metric_id = c.metric_id) AS last_obs_date,
         (SELECT r.status FROM vi_raw_capture_base r WHERE r.collector_id = c.id
           ORDER BY r.collected_at DESC, r.id DESC LIMIT 1) AS last_result
  FROM vi_collector_base c
), h AS (
  SELECT k.*,
         CASE WHEN NOT coalesce(enabled, false) THEN '已停用'
              WHEN last_collected IS NULL OR now() - last_collected > interval '36 hours' THEN '采集缺失或停摆'
              WHEN last_result = '采集中' THEN '采集未完成'
              WHEN last_result = '抓取失败' THEN '抓取失败（网络或网站）'
              WHEN last_result = '校验失败' THEN '解析或校验失败'
              WHEN last_obs_date IS NULL THEN '等待首次入库'
              WHEN vi_today() - last_obs_date > coalesce(max_lag_days, 7) THEN '观察过期'
              ELSE '正常' END AS health
  FROM k
)
SELECT id, last_collected, last_obs_date, last_result, health,
       (coalesce(enabled, false) AND health <> '正常') AS needs_alert
FROM h;

---------------------------------------------------------------------------
-- 采集运行：按本次的原始记录统计结果
---------------------------------------------------------------------------
CREATE VIEW vi_collect_run_calc AS
WITH r AS (
  SELECT run_id, count(*) AS raw_count,
         count(*) FILTER (WHERE status = '已入库') AS ingested,
         count(*) FILTER (WHERE status = '重复未入库') AS duplicates,
         count(*) FILTER (WHERE status = '抓取失败') AS fetch_failed,
         count(*) FILTER (WHERE status = '校验失败') AS invalid
  FROM vi_raw_capture_base WHERE run_id IS NOT NULL GROUP BY run_id
)
SELECT b.id, b.created_at AS requested_at,
       CASE WHEN b.status = '完成' THEN b.updated_at END AS finished_at,
       CASE WHEN b.status = '完成' THEN round(extract(epoch FROM b.updated_at - b.created_at))::int END AS seconds,
       coalesce(r.raw_count, 0)::int AS raw_count, coalesce(r.ingested, 0)::int AS ingested,
       coalesce(r.duplicates, 0)::int AS duplicates, coalesce(r.fetch_failed, 0)::int AS fetch_failed,
       coalesce(r.invalid, 0)::int AS invalid,
       CASE WHEN b.status = '完成'
              THEN coalesce(r.raw_count, 0) || ' 个数据源：新入库 ' || coalesce(r.ingested, 0) || '，重复 ' || coalesce(r.duplicates, 0)
                   || '，抓取失败 ' || coalesce(r.fetch_failed, 0) || '，校验失败 ' || coalesce(r.invalid, 0)
            WHEN now() - b.updated_at > interval '5 minutes' THEN '超过 5 分钟未结束：到「设置 → 工作流 → ④ 手动采集」看执行记录'
            ELSE '进行中' END AS summary
FROM vi_collect_run_base b LEFT JOIN r ON r.run_id = b.id;

---------------------------------------------------------------------------
-- 采集工作流调用的函数（逻辑放在 SQL 里，改逻辑不用改工作流）
--   vi_collect_targets(run) ④ 手动采集：本次要采的数据源。运行有公司时＝这家公司用到的指标（vi_company_metric：
--                           自有、股价、汇率折算、无风险利率、重点跟踪、订阅的宏观数据）；没有公司时＝全部启用的数据源
--   vi_ingest()    ② 入库：“待入库”的原始记录按入库判断写入高频数据，并回写处理状态
--   vi_selfcheck() ③ 自检：回写每个启用数据源的最近自检时间与结果
---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION vi_collect_targets(p_run bigint) RETURNS TABLE (id bigint, name text, url text) LANGUAGE sql STABLE AS $fn$
SELECT k.id, k.name, k.url
FROM vi_collector_base k
JOIN vi_metric_base m ON m.id = k.metric_id
LEFT JOIN vi_collect_run_base r ON r.id = p_run
WHERE k.enabled
  AND (r.company_id IS NULL
       OR EXISTS (SELECT 1 FROM vi_company_metric cm WHERE cm.company_id = r.company_id AND cm.metric_id = m.id))
ORDER BY k.id
$fn$;

CREATE OR REPLACE FUNCTION vi_ingest() RETURNS TABLE (raw_id bigint, status text) LANGUAGE sql AS $fn$
WITH c AS (
  SELECT r.id, k.metric_id, k.url, r.collected_at, x.parsed_date, x.parsed_value, x.decision
  FROM vi_raw_capture_base r
  JOIN vi_raw_capture_calc x ON x.id = r.id
  JOIN vi_collector_base k ON k.id = r.collector_id
  WHERE r.status = '待入库'
), ins AS (
  INSERT INTO vi_observation_base (metric_id, obs_date, value, collected_at, raw_capture_id)   -- 出处＝原始采集记录（→ 采集配置的地址）
  SELECT metric_id, parsed_date, parsed_value, collected_at, id
  FROM c WHERE decision = '可入库'
  RETURNING raw_capture_id
)
UPDATE vi_raw_capture_base r
SET status = CASE WHEN c.decision = '可入库' THEN '已入库'
                  WHEN c.decision = '抓取失败' THEN '抓取失败'
                  WHEN c.decision LIKE '重复%' THEN '重复未入库'
                  ELSE '校验失败' END
FROM c WHERE r.id = c.id
RETURNING r.id::bigint, r.status::text
$fn$;

CREATE OR REPLACE FUNCTION vi_selfcheck() RETURNS TABLE (collector_id bigint, health text) LANGUAGE sql AS $fn$
UPDATE vi_collector_base b
SET last_selfcheck = now(),
    selfcheck_result = CASE WHEN c.health = '正常' THEN '正常；未通知' ELSE '异常（' || c.health || '）；已通知' END
FROM vi_collector_calc c
WHERE c.id = b.id AND b.enabled
RETURNING b.id::bigint, c.health::text
$fn$;

---------------------------------------------------------------------------
-- 年度关键项派生指标 & 论点自动证伪检查（同比只在口径相同的相邻年份之间计算，并表/重组年份为空）
---------------------------------------------------------------------------
-- 历史年度：数值全部来自指标（指标的“模型字段”说明它是哪一列）。期间数取“全年”，余额取四季度“时点”；本表只存口径说明与来源
-- 单位换算：模型字段要的单位与指标的单位不同时（如业务量要“亿人”、指标存“百万人”）
CREATE OR REPLACE FUNCTION vi_unit_factor(p_from text, p_to text) RETURNS double precision LANGUAGE sql IMMUTABLE AS $$
SELECT CASE WHEN p_from IS NOT DISTINCT FROM p_to OR p_to IS NULL THEN 1
            WHEN p_from = '百万人' AND p_to = '亿人' THEN 0.01 WHEN p_from = '亿人' AND p_to = '百万人' THEN 100
            WHEN p_from = '百万台' AND p_to = '亿台' THEN 0.01 WHEN p_from = '亿台' AND p_to = '百万台' THEN 100
            WHEN p_from = '辆' AND p_to = '万辆' THEN 0.0001 WHEN p_from = '万辆' AND p_to = '辆' THEN 10000
            WHEN p_from = '万吨' AND p_to = '亿吨' THEN 0.0001 ELSE 1 END
$$;

-- 历史年度（只读，不存数）：模型字段指标的年度值透视成“年份 × 字段”，给财务模型、自动检查和图表用。
-- 期间数取“全年”，余额取四季度“时点”；业务量换算成公司表的业务量单位；年份＝有数据的年度里最近 12 年。
CREATE MATERIALIZED VIEW vi_fin_history_cache AS
WITH a AS (
  SELECT m.company_id, m.model_field,
         x.value * vi_unit_factor(m.unit, CASE WHEN m.model_field = 'volume' THEN c.volume_unit ELSE m.unit END) AS value,
         CASE WHEN x.basis = '全年' AND x.period ~ '^\d{4}$' THEN x.period::int
              WHEN x.basis = '时点' AND x.period ~ '^\d{4}Q4$' THEN left(x.period, 4)::int END AS year
  FROM vi_metric_base m JOIN vi_company_base c ON c.id = m.company_id JOIN vi_series x ON x.metric_id = m.id
  WHERE m.model_field IS NOT NULL
), p AS (
  SELECT a.company_id, a.year,
         max(a.value) FILTER (WHERE a.model_field = 'volume') AS volume,
         max(a.value) FILTER (WHERE a.model_field = 'revenue') AS revenue,
         max(a.value) FILTER (WHERE a.model_field = 'cost_of_sales') AS cost_of_sales,
         max(a.value) FILTER (WHERE a.model_field = 'pretax_profit') AS pretax_profit,
         max(a.value) FILTER (WHERE a.model_field = 'income_tax') AS income_tax,
         max(a.value) FILTER (WHERE a.model_field = 'np_parent') AS np_parent,
         max(a.value) FILTER (WHERE a.model_field = 'minority_profit') AS minority_profit,
         max(a.value) FILTER (WHERE a.model_field = 'da') AS da,
         max(a.value) FILTER (WHERE a.model_field = 'finance_cost') AS finance_cost,
         max(a.value) FILTER (WHERE a.model_field = 'invest_income') AS invest_income,
         max(a.value) FILTER (WHERE a.model_field = 'equity_income') AS equity_income,
         max(a.value) FILTER (WHERE a.model_field = 'cfo') AS cfo,
         max(a.value) FILTER (WHERE a.model_field = 'capex') AS capex,
         max(a.value) FILTER (WHERE a.model_field = 'investee_cash_div') AS investee_cash_div,
         max(a.value) FILTER (WHERE a.model_field = 'net_borrowing') AS net_borrowing,
         max(a.value) FILTER (WHERE a.model_field = 'interest_debt') AS interest_debt,
         max(a.value) FILTER (WHERE a.model_field = 'cash') AS cash,
         max(a.value) FILTER (WHERE a.model_field = 'equity_parent') AS equity_parent,
         max(a.value) FILTER (WHERE a.model_field = 'dividend_total') AS dividend_total,
         max(a.value) FILTER (WHERE a.model_field = 'dps') AS dps
  FROM a WHERE a.year IS NOT NULL
  GROUP BY a.company_id, a.year
), k AS (
  SELECT p.*, max(year) FILTER (WHERE revenue IS NOT NULL) OVER (PARTITION BY company_id) AS last_year FROM p
)
SELECT company_id * 10000 + year AS id, company_id, year, volume, revenue, cost_of_sales, pretax_profit, income_tax, np_parent, minority_profit, da, finance_cost, invest_income, equity_income, cfo, capex, investee_cash_div, net_borrowing, interest_debt, cash, equity_parent, dividend_total, dps
FROM k WHERE year BETWEEN last_year - 11 AND last_year;
CREATE UNIQUE INDEX ON vi_fin_history_cache (id);
CREATE INDEX ON vi_fin_history_cache (company_id, year);

-- 刷新时机：模型字段改了；模型字段指标的数据变了（只看这次改到的行，其他数据不触发）
CREATE OR REPLACE FUNCTION vi_refresh_fin_history() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_TABLE_NAME = 'vi_observation_base' THEN       -- 每种操作只引用它自己有的转换表（INSERT 只有 nt，DELETE 只有 ot）
    IF TG_OP = 'INSERT' THEN
      IF NOT EXISTS (SELECT 1 FROM nt JOIN vi_metric_base m ON m.id = nt.metric_id WHERE m.model_field IS NOT NULL) THEN RETURN NULL; END IF;
    ELSIF TG_OP = 'DELETE' THEN
      IF NOT EXISTS (SELECT 1 FROM ot JOIN vi_metric_base m ON m.id = ot.metric_id WHERE m.model_field IS NOT NULL) THEN RETURN NULL; END IF;
    ELSE
      IF NOT EXISTS (SELECT 1 FROM nt JOIN vi_metric_base m ON m.id = nt.metric_id WHERE m.model_field IS NOT NULL)
         AND NOT EXISTS (SELECT 1 FROM ot JOIN vi_metric_base m ON m.id = ot.metric_id WHERE m.model_field IS NOT NULL) THEN RETURN NULL; END IF;
    END IF;
  END IF;
  REFRESH MATERIALIZED VIEW vi_fin_history_cache;
  RETURN NULL;
END $$;
DROP TRIGGER IF EXISTS vi_obs_hist_ins ON vi_observation_base;
CREATE TRIGGER vi_obs_hist_ins AFTER INSERT ON vi_observation_base REFERENCING NEW TABLE AS nt FOR EACH STATEMENT EXECUTE FUNCTION vi_refresh_fin_history();
DROP TRIGGER IF EXISTS vi_obs_hist_upd ON vi_observation_base;
CREATE TRIGGER vi_obs_hist_upd AFTER UPDATE ON vi_observation_base REFERENCING NEW TABLE AS nt OLD TABLE AS ot FOR EACH STATEMENT EXECUTE FUNCTION vi_refresh_fin_history();
DROP TRIGGER IF EXISTS vi_obs_hist_del ON vi_observation_base;
CREATE TRIGGER vi_obs_hist_del AFTER DELETE ON vi_observation_base REFERENCING OLD TABLE AS ot FOR EACH STATEMENT EXECUTE FUNCTION vi_refresh_fin_history();
DROP TRIGGER IF EXISTS vi_metric_hist ON vi_metric_base;
CREATE TRIGGER vi_metric_hist AFTER UPDATE ON vi_metric_base FOR EACH ROW WHEN (OLD.model_field IS DISTINCT FROM NEW.model_field)
  EXECUTE FUNCTION vi_refresh_fin_history();
DROP TRIGGER IF EXISTS vi_metric_hist_del ON vi_metric_base;
CREATE TRIGGER vi_metric_hist_del AFTER DELETE ON vi_metric_base FOR EACH ROW WHEN (OLD.model_field IS NOT NULL)
  EXECUTE FUNCTION vi_refresh_fin_history();

CREATE VIEW vi_fin_history AS
WITH v AS (
  SELECT h.*, h.year = ANY (coalesce(array_remove(regexp_split_to_array(c.scope_breaks, '[^0-9]+'), '')::int[], '{}')) AS scope_break
  FROM vi_fin_history_cache h JOIN vi_company_base c ON c.id = h.company_id
), b AS (
  SELECT v.*,
         revenue / NULLIF(volume, 0) AS price_,
         lag(year) OVER w AS py, lag(volume) OVER w AS p_volume, lag(revenue) OVER w AS p_revenue,
         lag(revenue / NULLIF(volume, 0)) OVER w AS p_price, lag(np_parent) OVER w AS p_np,
         lag(finance_cost) OVER w AS p_fc, lag(equity_parent) OVER w AS p_equity
  FROM v
  WINDOW w AS (PARTITION BY company_id ORDER BY year)
)
SELECT id, company_id, year, volume, revenue, cost_of_sales, pretax_profit, income_tax, np_parent, minority_profit, da, finance_cost, invest_income, equity_income, cfo, capex, investee_cash_div, net_borrowing, interest_debt, cash, equity_parent, dividend_total, dps,
       price_ AS price,
       dividend_total / NULLIF(np_parent, 0) AS payout,
       income_tax / NULLIF(pretax_profit, 0) AS tax_rate,
       minority_profit / NULLIF(pretax_profit - income_tax, 0) AS minority_share,
       1 - np_parent / NULLIF(pretax_profit, 0) AS burden,
       cfo - capex AS fcf,
       CASE WHEN py = year - 1 AND NOT scope_break THEN volume / NULLIF(p_volume, 0) - 1 END AS volume_yoy,
       CASE WHEN py = year - 1 AND NOT scope_break THEN price_ / NULLIF(p_price, 0) - 1 END AS price_yoy,
       CASE WHEN py = year - 1 AND NOT scope_break THEN revenue / NULLIF(p_revenue, 0) - 1 END AS revenue_yoy,
       CASE WHEN py = year - 1 AND NOT scope_break THEN np_parent / NULLIF(p_np, 0) - 1 END AS np_yoy,
       CASE WHEN py = year - 1 AND NOT scope_break THEN finance_cost / NULLIF(p_fc, 0) - 1 END AS finance_cost_yoy,
       1 - cost_of_sales / NULLIF(revenue, 0) AS gross_margin,
       CASE WHEN py = year - 1 THEN np_parent / NULLIF((equity_parent + p_equity) / 2, 0) END AS roe,
       cfo / NULLIF(np_parent, 0) AS cfo_to_np,
       capex / NULLIF(cfo, 0) AS capex_to_cfo,
       interest_debt - cash AS net_debt,
       (interest_debt - cash) / NULLIF(pretax_profit + finance_cost + da, 0) AS net_debt_to_ebitda
FROM b;

-- 长表：公司×年度×指标名（论点检查按中文指标名取值）
CREATE VIEW vi_fin_metric AS
SELECT c.company_id, c.year, x.metric, x.value
FROM vi_fin_history c
CROSS JOIN LATERAL (VALUES
  ('业务量', c.volume), ('单价', c.price), ('营业收入', c.revenue), ('归母净利润', c.np_parent),
  ('派息率', c.payout), ('财务费用', c.finance_cost), ('业务量同比', c.volume_yoy),
  ('单价同比', c.price_yoy), ('营业收入同比', c.revenue_yoy), ('财务费用同比', c.finance_cost_yoy),
  ('毛利率', c.gross_margin), ('ROE', c.roe), ('经营现金流÷归母净利润', c.cfo_to_np),
  ('资本开支÷经营现金流', c.capex_to_cfo), ('净负债', c.net_debt), ('净负债÷EBITDA', c.net_debt_to_ebitda)
) AS x(metric, value)
WHERE x.value IS NOT NULL;

-- 自动检查（论点与竞争壁垒共用）：取最近一年的值；最近连续 N 年都满足条件即“已触发”
CREATE OR REPLACE FUNCTION vi_check_eval(cid bigint, metric text, op text, threshold double precision, years int,
  OUT latest_year int, OUT latest_value double precision, OUT result text)
LANGUAGE sql STABLE AS $$
  SELECT l.year, l.value,
         CASE WHEN metric IS NULL OR op IS NULL OR threshold IS NULL THEN '未设置'
              WHEN n.cnt < coalesce(years, 1) THEN '数据不足'
              WHEN n.hits = coalesce(years, 1) THEN
                format('已触发：最近 %s 年%s %s %s', coalesce(years, 1), metric, op, threshold)
              ELSE format('未触发：%s 年 %s＝%s', l.year, metric, round(l.value::numeric, 4)) END
  FROM (SELECT 1) one
  LEFT JOIN LATERAL (SELECT year, value FROM vi_fin_metric m WHERE m.company_id = cid AND m.metric = vi_check_eval.metric
                     ORDER BY year DESC LIMIT 1) l ON true
  LEFT JOIN LATERAL (
    SELECT count(*) AS cnt,
           count(*) FILTER (WHERE CASE op WHEN '<' THEN value < threshold WHEN '<=' THEN value <= threshold
                                          WHEN '>' THEN value > threshold WHEN '>=' THEN value >= threshold END) AS hits
    FROM (SELECT value FROM vi_fin_metric m WHERE m.company_id = cid AND m.metric = vi_check_eval.metric
          ORDER BY year DESC LIMIT coalesce(years, 1)) z
  ) n ON true
$$;

-- 论点：自动检查＋关联的假设依据及其状态（“对模型的影响”不再手写编号）
CREATE VIEW vi_thesis_calc AS
SELECT t.id, x.latest_year AS check_latest_year, x.latest_value AS check_latest_value, x.result AS check_result,
       (SELECT string_agg(j.code || ' ' || coalesce(j.status, '未定'), '；' ORDER BY j.code) FROM vi_lnk_judgment_theses l
          JOIN vi_judgment_base j ON j.id = l.judgment_id WHERE l.thesis_id = t.id) AS judgment_status
FROM vi_thesis_base t
CROSS JOIN LATERAL vi_check_eval(t.company_id, t.check_metric, t.check_op, t.check_threshold, t.check_years) x;

-- 竞争壁垒：自动检查＋辩论统计（关联到这项壁垒、填了辩论日期的论点条数，以及这些论点各自的裁决）
CREATE VIEW vi_moat_calc AS
SELECT m.id, x.latest_year AS check_latest_year, x.latest_value AS check_latest_value, x.result AS check_result,
       (SELECT count(*) FROM vi_lnk_moat_theses l JOIN vi_thesis_base t ON t.id = l.thesis_id
         WHERE l.moat_id = m.id AND t.debated_on IS NOT NULL)::int AS debate_count,
       (SELECT string_agg(t.code || ' ' || coalesce(t.status, '未裁决'), '；' ORDER BY t.id) FROM vi_lnk_moat_theses l JOIN vi_thesis_base t ON t.id = l.thesis_id
         WHERE l.moat_id = m.id AND t.debated_on IS NOT NULL) AS debate_winner
FROM vi_moat_base m
CROSS JOIN LATERAL vi_check_eval(m.company_id, m.check_metric, m.check_op, m.check_threshold, m.check_years) x;

-- 风险分析：可能性×冲击定级（高 3、中 2、低 1；乘积 6—9 重大、3—4 重要、1—2 一般），关联论点的当前裁决
CREATE VIEW vi_risk_calc AS
SELECT r.id,
       CASE WHEN s.score IS NULL THEN NULL WHEN s.score >= 6 THEN '重大' WHEN s.score >= 3 THEN '重要' ELSE '一般' END AS level,
       (SELECT string_agg(t.code || ' ' || coalesce(t.status, '未裁决'), '；' ORDER BY t.code) FROM vi_lnk_risk_theses l
          JOIN vi_thesis_base t ON t.id = l.thesis_id WHERE l.risk_id = r.id) AS thesis_verdicts
FROM vi_risk_base r
CROSS JOIN LATERAL (SELECT (CASE r.probability WHEN '高' THEN 3 WHEN '中' THEN 2 WHEN '低' THEN 1 END)
                         * (CASE r.impact WHEN '高' THEN 3 WHEN '中' THEN 2 WHEN '低' THEN 1 END) AS score) s;

---------------------------------------------------------------------------
-- Greenwald 三层估值（2026-11-11 重构）：公司拆成估值单元（业务），每个单元用四个模块，另有一个口径开关。
--   第一层 资产价值：资产负债重估里挂在本业务的重估计入值合计（或业务的重建成本）×归母比例；
--   第二层 盈利能力价值：调整后利润表（vi_epv）：收入 − 成本费用 ± 税前调整 − 所得税 ± 税后调整 − 少数股东 ＝ E，E÷h；
--   第三层 含增长价值：优势期 N 年内每年增长 g、每年再投入 g÷RONIC 的收益，之后增长不再创造价值（N 留空＝永续，要求 g＜h）；
--   独立资产与调整（资产负债桥）：资产负债重估里没挂业务的行（现金与投资、参照估值、有息负债、其他索取权）；
--   股权价值＝选定一层的业务价值合计＋资产负债桥。口径开关（业务的 capital_basis）：股权口径的业务把有息负债挂在业务上，利润用利息后口径。
--   只用一个利率：门槛 h＝vi_hurdle()（框架与后台 / 统一设置）。价值算到公司的估值截至日，再按门槛滚到今天。空白＝未知，不输出价值。
---------------------------------------------------------------------------
-- 一个单元的现值：e＝第一年可持续现金收益；g、ronic、n（优势年限）、life（盈利年限）可空
CREATE OR REPLACE FUNCTION vi_gw_pv(e double precision, g double precision, ronic double precision, n integer, life integer,
                                    r double precision)
RETURNS double precision LANGUAGE plpgsql IMMUTABLE AS $$
DECLARE gg double precision := coalesce(g, 0); k integer; q double precision; pv double precision;
BEGIN
  IF e IS NULL OR r IS NULL OR r <= 0 THEN RETURN NULL; END IF;
  IF life IS NOT NULL AND life <= 0 THEN RETURN 0; END IF;
  IF gg = 0 THEN
    RETURN CASE WHEN life IS NULL THEN e / r ELSE e * (1 - power(1 + r, -life)) / r END;
  END IF;
  IF ronic IS NULL OR ronic <= 0 THEN RETURN NULL; END IF;
  IF n IS NULL AND life IS NULL THEN                        -- 永续增长
    IF gg >= r THEN RETURN NULL; END IF;
    RETURN e * (1 - gg / ronic) / (r - gg);
  END IF;
  k := CASE WHEN n IS NULL THEN life WHEN life IS NULL THEN n ELSE least(n, life) END;
  q := (1 + gg) / (1 + r);
  -- 优势期：第 t 年收益 e(1+g)^(t−1)，再投入 g÷ronic 后的现金流折现
  pv := e * (1 - gg / ronic) / (1 + r) * CASE WHEN abs(q - 1) < 1e-12 THEN k ELSE (1 - power(q, k)) / (1 - q) END;
  -- 优势期后：收益停在 e(1+g)^k，永续或到盈利年限
  RETURN pv + e * power(1 + gg, k) / power(1 + r, k)
              * CASE WHEN life IS NULL THEN 1 / r ELSE (1 - power(1 + r, -(life - k))) / r END;
END $$;

-- 每个元素是一期可分配现金，最后一个元素是优势期结束后的稳态年收益。
CREATE OR REPLACE FUNCTION vi_gw_cash_path(plan text, bases jsonb, e double precision,
    core double precision, tax_rate double precision, attrib double precision, ro double precision, n integer)
RETURNS jsonb LANGUAGE plpgsql IMMUTABLE STRICT AS $$
DECLARE
  items jsonb;
  revenue double precision; spread double precision; current_e double precision := e;
  delta_e double precision; investment double precision; flows double precision[] := '{}';
  yr integer;
BEGIN
  items := plan::jsonb;
  IF jsonb_typeof(items) <> 'array' OR n NOT BETWEEN 0 AND 100 OR ro <= 0 THEN RETURN NULL; END IF;
  -- 每个收入行必须唯一匹配。少行、多行或改名时停止输出该预测。
  IF EXISTS (SELECT 1 FROM jsonb_to_recordset(items) p(name text, early float8, late float8, margin float8)
      WHERE NOT (bases ? name) OR name IS NULL OR early IS NULL OR late IS NULL OR margin IS NULL
         OR early < -1 OR late < -1 OR (bases->>name)::float8 IS NULL)
    OR jsonb_array_length(items) <> (SELECT count(DISTINCT p->>'name') FROM jsonb_array_elements(items) p)
    OR jsonb_array_length(items) <> (SELECT count(*) FROM jsonb_object_keys(bases)) THEN RETURN NULL; END IF;
  SELECT sum((bases->>name)::float8), sum((bases->>name)::float8 * margin)
    INTO revenue, spread FROM jsonb_to_recordset(items) p(name text, margin float8);
  IF revenue IS NULL OR revenue <= 0 THEN RETURN NULL; END IF;
  spread := (spread - core) / revenue;
  FOR yr IN 1..n LOOP
    WITH changes AS (
      SELECT (bases->>name)::float8 * power(1+early, least(yr-1,3)) * power(1+late, greatest(yr-4,0))
             * CASE WHEN yr<=3 THEN early ELSE late END * (margin-spread) * (1-tax_rate) * attrib AS de
      FROM jsonb_to_recordset(items) p(name text, early float8, late float8, margin float8)
    )
    SELECT sum(de), sum(greatest(de,0))/ro INTO delta_e, investment FROM changes;
    flows := array_append(flows, current_e-investment);
    current_e := current_e + delta_e;
  END LOOP;
  RETURN to_jsonb(array_append(flows,current_e));
EXCEPTION WHEN data_exception THEN RETURN NULL;
END $$;

CREATE OR REPLACE FUNCTION vi_gw_cash_pv(path jsonb, r double precision)
RETURNS double precision LANGUAGE sql IMMUTABLE STRICT AS $$
  SELECT CASE WHEN r > 0 THEN sum(CASE WHEN t=jsonb_array_length(path)
    THEN cf::float8 / r / power(1+r,t-1) ELSE cf::float8 / power(1+r,t) END) END
  FROM jsonb_array_elements_text(path) WITH ORDINALITY a(cf,t)
$$;

-- 隐含回报：使 (Σ单元现值(r)＋资产负债桥)×(1+r)^距截至日年数÷股本＝市价 的 r（二分法；超出 (0, 100%] 或解不出返回空）
CREATE OR REPLACE FUNCTION vi_gw_irr_paths(e double precision[], g double precision[], ro double precision[], n integer[], life integer[],
                                     with_growth boolean, konst double precision, shares double precision,
                                     elapsed double precision, price double precision, paths jsonb)
RETURNS double precision LANGUAGE plpgsql IMMUTABLE AS $$
DECLARE lo double precision; hi double precision := 1.0; mid double precision; i int;
BEGIN
  IF price IS NULL OR price <= 0 OR shares IS NULL OR shares <= 0 OR konst IS NULL OR e IS NULL THEN RETURN NULL; END IF;
  lo := 1e-4 + CASE WHEN with_growth THEN greatest(0, coalesce((SELECT max(gg) FROM unnest(g, n, life) AS x(gg, nn, ll)
                                                                 WHERE nn IS NULL AND ll IS NULL), 0)) ELSE 0 END;
  IF vi_gw_equity_paths(e, g, ro, n, life, with_growth, konst, lo, paths) * power(1 + lo, elapsed) / shares < price THEN RETURN NULL; END IF;
  IF vi_gw_equity_paths(e, g, ro, n, life, with_growth, konst, hi, paths) * power(1 + hi, elapsed) / shares > price THEN RETURN NULL; END IF;
  FOR i IN 1..60 LOOP
    mid := (lo + hi) / 2;
    IF vi_gw_equity_paths(e, g, ro, n, life, with_growth, konst, mid, paths) * power(1 + mid, elapsed) / shares > price THEN lo := mid; ELSE hi := mid; END IF;
  END LOOP;
  RETURN (lo + hi) / 2;
END $$;

CREATE OR REPLACE FUNCTION vi_gw_equity_paths(e double precision[], g double precision[], ro double precision[], n integer[], life integer[],
                                        with_growth boolean, konst double precision, r double precision, paths jsonb)
RETURNS double precision LANGUAGE sql IMMUTABLE AS $$
  SELECT sum(CASE WHEN with_growth AND jsonb_typeof(paths->(idx::int-1)) = 'array' THEN vi_gw_cash_pv(paths->(idx::int-1),r) ELSE vi_gw_pv(ee, CASE WHEN with_growth THEN gg ELSE 0 END, rr, nn, ll, r) END) + konst
  FROM unnest(e, g, ro, n, life) WITH ORDINALITY AS x(ee, gg, rr, nn, ll, idx)
$$;

CREATE OR REPLACE FUNCTION vi_gw_irr(e double precision[], g double precision[], ro double precision[], n integer[], life integer[],
                                     with_growth boolean, konst double precision, shares double precision, elapsed double precision, price double precision)
RETURNS double precision LANGUAGE sql IMMUTABLE AS $$
  SELECT vi_gw_irr_paths(e,g,ro,n,life,with_growth,konst,shares,elapsed,price,NULL)
$$;

CREATE OR REPLACE FUNCTION vi_gw_equity(e double precision[], g double precision[], ro double precision[], n integer[], life integer[],
                                        with_growth boolean, konst double precision, r double precision)
RETURNS double precision LANGUAGE sql IMMUTABLE AS $$
  SELECT vi_gw_equity_paths(e,g,ro,n,life,with_growth,konst,r,NULL)
$$;

-- 资产负债重估（全公司口径，不分业务）：账面取公司估值截至日的资产负债表；经营资产与经营负债＝经营资本，其余＝资产负债桥
CREATE VIEW vi_bs_item_calc AS
WITH x AS (
  SELECT b.id, co.as_of, b.category, b.haircut, b.adjustment,
         CASE WHEN nullif(btrim(b.line_item), '') IS NULL THEN 0
              ELSE (SELECT f.amount FROM vi_fin_stmt_base f WHERE f.company_id = b.company_id AND f.stmt = '资产负债表'
                       AND f.period_end = co.as_of AND f.item = btrim(b.line_item)) END AS book,
         CASE WHEN b.category IN ('经营资产', '现金与投资', '参照估值') THEN 1 WHEN b.category IN ('经营负债', '有息负债', '其他索取权') THEN -1 END AS sgn
  FROM vi_bs_item_base b LEFT JOIN vi_company_base co ON co.id = b.company_id
), y AS (
  SELECT x.*, book * (1 - coalesce(haircut, 0)) + coalesce(adjustment, 0) AS revalued FROM x
)
SELECT id, as_of, book, revalued, sgn * book AS book_signed, sgn * revalued AS value_signed,
       CASE WHEN category IN ('经营资产', '经营负债') THEN '经营资本' ELSE '资产负债桥' END AS role
FROM y;

-- 调整后利润表：每行的历年数（报表公式，全年口径，最近 5 年＋最近四个季度）与正常化值
--   收入行先算（不能用“占收入”类取值方式），正常化收入＝本业务收入行合计；其他行再按取值方式算；
--   所得税、少数股东按比率乘对应的小计（小计在 vi_gw_unit 里算，这里也一并算出金额便于逐行展示）。
CREATE VIEW vi_epv_calc AS
WITH l AS (
  SELECT e.* FROM vi_epv_base e
), h AS (            -- 全年口径的历年数
  SELECT l.id, l.business_id, l.section, s.period::int AS y, s.value
  FROM l CROSS JOIN LATERAL vi_stmt_series(l.company_id, l.formula) s
  WHERE nullif(btrim(l.formula), '') IS NOT NULL AND s.basis = '全年'
), t AS (            -- 最近四个季度
  SELECT DISTINCT ON (l.id) l.id, s.period, s.value
  FROM l CROSS JOIN LATERAL vi_stmt_series(l.company_id, l.formula) s
  WHERE nullif(btrim(l.formula), '') IS NOT NULL AND s.basis = '滚动四季度'
  ORDER BY l.id, s.period_end DESC
), maxy AS (
  SELECT business_id, max(y) AS y FROM h GROUP BY business_id
), rh AS (           -- 本业务收入行的历年合计（算“历史平均占收入”）
  SELECT business_id, y, sum(value) AS rev FROM h WHERE section = '收入' GROUP BY business_id, y
), base AS (         -- 不依赖正常化收入的取值方式
  SELECT l.id, l.business_id, l.section, l.direction, l.method, l.value, l.from_year, l.to_year,
         CASE l.method
           WHEN '金额' THEN l.value
           WHEN '最新年度' THEN (SELECT h.value FROM h JOIN maxy m ON m.business_id = h.business_id AND m.y = h.y WHERE h.id = l.id)
           WHEN '滚动四季度' THEN (SELECT t.value FROM t WHERE t.id = l.id)
           WHEN '历史平均' THEN (SELECT avg(h.value) FROM h WHERE h.id = l.id AND h.y BETWEEN coalesce(l.from_year, 0) AND coalesce(l.to_year, 9999)) END AS v0,
         (SELECT avg(h.value / NULLIF(rh.rev, 0)) FROM h JOIN rh ON rh.business_id = h.business_id AND rh.y = h.y
           WHERE h.id = l.id AND h.y BETWEEN coalesce(l.from_year, 0) AND coalesce(l.to_year, 9999)) AS avg_ratio
  FROM l
), rev AS (
  SELECT business_id, CASE WHEN count(*) = count(v0) THEN sum(v0) END AS rev FROM base WHERE section = '收入' GROUP BY business_id
), amt AS (          -- 收入、成本费用、调整、不计入
  SELECT b.*, r.rev,
         CASE WHEN b.section IN ('所得税', '少数股东') THEN NULL
              WHEN b.method = '占收入比例' AND b.section <> '收入' THEN b.value * r.rev
              WHEN b.method = '历史平均占收入' AND b.section <> '收入' THEN b.avg_ratio * r.rev
              ELSE b.v0 END AS amount,
         CASE WHEN b.section IN ('税前调整', '税后调整') AND b.direction = '减' THEN -1 WHEN b.section IN ('税前调整', '税后调整') THEN 1 END AS sgn
  FROM base b LEFT JOIN rev r ON r.business_id = b.business_id
), sub AS (          -- 小计：调整后经营利润、税后经营利润与税后调整
  SELECT business_id,
         sum(amount) FILTER (WHERE section = '收入') - coalesce(sum(amount) FILTER (WHERE section = '成本费用'), 0)
           + coalesce(sum(sgn * amount) FILTER (WHERE section = '税前调整'), 0) AS ebit,
         coalesce(sum(sgn * amount) FILTER (WHERE section = '税后调整'), 0) AS post_adj,
         max(value) FILTER (WHERE section = '所得税') AS tax_rate
  FROM amt GROUP BY business_id
), hist AS (
  SELECT h.id, json_agg(json_build_array(h.y::text, round(h.value::numeric, 4)) ORDER BY h.y) AS j
  FROM h JOIN maxy m ON m.business_id = h.business_id WHERE h.y > m.y - 5 GROUP BY h.id
)
SELECT a.id,
       CASE WHEN hist.j IS NOT NULL OR t.value IS NOT NULL THEN
         (coalesce(hist.j::jsonb, '[]'::jsonb) || CASE WHEN t.value IS NULL OR t.period LIKE '%Q4' THEN '[]'::jsonb
                                                       ELSE jsonb_build_array(jsonb_build_array('近四季（' || t.period || '）', round(t.value::numeric, 4))) END)::text END AS history,
       CASE WHEN a.section = '所得税' THEN a.value * s.ebit
            WHEN a.section = '少数股东' THEN a.value * (s.ebit * (1 - s.tax_rate) + s.post_adj)
            ELSE a.amount END AS normalized,
       CASE WHEN a.section = '所得税' THEN a.value * s.ebit
            WHEN a.section = '少数股东' THEN a.value * (s.ebit * (1 - s.tax_rate) + s.post_adj)
            ELSE a.amount END / NULLIF(a.rev, 0) AS ratio
FROM amt a LEFT JOIN sub s ON s.business_id = a.business_id LEFT JOIN hist ON hist.id = a.id LEFT JOIN t ON t.id = a.id;

-- 业务：一行一块业务（有调整后利润表的业务）：第二、三层
CREATE VIEW vi_gw_unit AS
WITH lines AS (
  SELECT e.company_id, e.business_id, e.name, e.section, e.direction, e.value, e.method, c.normalized,
         CASE WHEN e.section IN ('税前调整', '税后调整') AND e.direction = '减' THEN -1 ELSE 1 END AS sgn
  FROM vi_epv_base e JOIN vi_epv_calc c ON c.id = e.id
), agg AS (
  SELECT company_id, business_id,
         jsonb_object_agg(name, normalized) FILTER (WHERE section = '收入' AND name IS NOT NULL) AS bases,
         sum(normalized) FILTER (WHERE section = '收入') AS revenue,
         coalesce(sum(normalized) FILTER (WHERE section = '成本费用'), 0) AS cost,
         coalesce(sum(sgn * normalized) FILTER (WHERE section = '税前调整'), 0) AS pre_adj,
         max(value) FILTER (WHERE section = '所得税') AS tax_rate,
         coalesce(sum(sgn * normalized) FILTER (WHERE section = '税后调整'), 0) AS post_adj,
         coalesce(max(value) FILTER (WHERE section = '少数股东'), 0) AS minority_rate,
         count(*) FILTER (WHERE section = '收入') AS n_rev,
         count(*) FILTER (WHERE section = '所得税') AS n_tax,
         count(*) FILTER (WHERE section = '税后调整') AS n_post,
         string_agg(CASE WHEN section NOT IN ('所得税', '少数股东', '不计入') AND normalized IS NULL THEN '“' || coalesce(nullif(method, ''), '?') || '”取不到值' END, '、') AS bad_lines
  FROM lines GROUP BY company_id, business_id
), i AS (
  SELECT a.*, bz.code AS business_code, bz.name AS business_name, bz.sort AS business_sort,
         coalesce(bz.capital_basis, '企业') AS capital_basis,
         vi_hurdle() AS h, co.as_of, coalesce(g.growth, 0) AS g, g.ronic, g.adv_years, g.revenue_plan
  FROM agg a JOIN vi_business_base bz ON bz.id = a.business_id
  LEFT JOIN vi_company_base co ON co.id = a.company_id
  LEFT JOIN vi_growth_base g ON g.business_id = a.business_id
), e AS (
  SELECT i.*, i.revenue - i.cost AS ebit_reported, i.revenue - i.cost + i.pre_adj AS ebit,
         concat_ws('、', CASE WHEN i.h IS NULL THEN '门槛（统一设置）' END, CASE WHEN i.n_rev = 0 OR i.revenue IS NULL THEN '收入' END,
                   CASE WHEN i.n_tax <> 1 OR i.tax_rate IS NULL THEN '所得税（一行，填比率）' END, i.bad_lines,
                   CASE WHEN i.g <> 0 AND i.ronic IS NULL THEN '新增投资回报率' END) AS missing
  FROM i
), f AS (
  SELECT e.*, ebit * tax_rate AS tax, ebit * (1 - tax_rate) AS nopat,
         (ebit * (1 - tax_rate) + post_adj) * minority_rate AS minority,
         CASE WHEN missing = '' THEN (ebit * (1 - tax_rate) + post_adj) * (1 - minority_rate) END AS earnings
  FROM e
), paths AS (
  SELECT f.*, CASE WHEN n_rev = (SELECT count(*) FROM jsonb_object_keys(bases)) THEN
     vi_gw_cash_path(revenue_plan,bases,earnings,ebit_reported,tax_rate,1-minority_rate,ronic,adv_years) END AS cash_path
  FROM f
), v AS (
  SELECT paths.*, vi_gw_pv(earnings, 0, NULL, NULL, NULL, h) AS epv,
    CASE WHEN revenue_plan IS NOT NULL THEN vi_gw_cash_pv(cash_path,h) ELSE vi_gw_pv(earnings, g, ronic, adv_years, NULL, h) END AS full_value
  FROM paths
)
SELECT business_id AS id, company_id, business_id, business_code, business_name, business_sort, capital_basis, h, as_of,
       revenue, cost, ebit_reported, pre_adj, ebit, ebit / NULLIF(revenue, 0) AS margin, tax, nopat, post_adj, minority,
       1 - minority_rate AS attrib, earnings, ebit * (1 - tax_rate) + post_adj AS pre_minority,
       epv, full_value, full_value - epv AS growth_value,
       CASE WHEN revenue_plan IS NULL THEN g WHEN adv_years = 0 THEN 0
            WHEN adv_years > 0 AND earnings > 0 AND (cash_path->>-1)::float8 > 0
            THEN power((cash_path->>-1)::float8/earnings,1.0/adv_years)-1 END AS g,
       ronic, adv_years, n_post,
       missing = '' AND full_value IS NOT NULL AS complete,
       CASE WHEN missing <> '' THEN '缺 ' || missing
            WHEN revenue_plan IS NOT NULL AND cash_path IS NULL THEN '分项预测输入与收入底稿不匹配或缺少有效回报率、优势期'
            WHEN full_value IS NULL THEN '永续增长率不低于门槛，不输出价值' END AS note, cash_path
FROM v;

-- 公司：一行
CREATE VIEW vi_gw_value AS
WITH s AS (
  SELECT co.id AS company_id, co.name AS company_name, co.shares, vi_hurdle() AS h, co.as_of, co.value_layer,
         coalesce(co.av_basis, '调整后净资产') AS av_basis, co.repro_cost, cc.latest_price, cc.latest_price_date
  FROM vi_company_base co LEFT JOIN vi_company_calc cc ON cc.id = co.id
  WHERE EXISTS (SELECT 1 FROM vi_epv_base e WHERE e.company_id = co.id)
), br AS (
  SELECT b.company_id, sum(c.value_signed) AS bridge, count(*) FILTER (WHERE c.book IS NULL) AS n_missing
  FROM vi_bs_item_base b JOIN vi_bs_item_calc c ON c.id = b.id WHERE c.role = '资产负债桥' GROUP BY b.company_id
), op AS (       -- 全公司的经营资本（第一层）
  SELECT b.company_id, sum(c.book_signed) AS book_capital, sum(c.value_signed) AS adj_capital, count(*) FILTER (WHERE c.book IS NULL) AS n_missing
  FROM vi_bs_item_base b JOIN vi_bs_item_calc c ON c.id = b.id WHERE c.role = '经营资本' GROUP BY b.company_id
), u AS (
  SELECT company_id, sum(epv) AS epv_total, sum(full_value) AS full_total,
         1 - coalesce(sum(minority) / NULLIF(sum(pre_minority), 0), 0) AS av_attrib,
         bool_and(complete) AS complete,
         string_agg(business_name || '：' || note, '；' ORDER BY business_sort) FILTER (WHERE NOT complete) AS missing,
         array_agg(earnings ORDER BY business_id) AS e, array_agg(g ORDER BY business_id) AS g, array_agg(ronic ORDER BY business_id) AS ro, array_agg(adv_years ORDER BY business_id) AS n,
         jsonb_agg(cash_path ORDER BY business_id) AS paths, array_agg(NULL::integer) AS l
  FROM vi_gw_unit GROUP BY company_id
), x AS (
  SELECT s.*, u.epv_total, u.full_total, u.av_attrib, op.book_capital, op.adj_capital,
         CASE s.av_basis WHEN '不适用' THEN NULL WHEN '重建成本' THEN s.repro_cost * u.av_attrib
              ELSE CASE WHEN coalesce(op.n_missing, 0) = 0 THEN op.adj_capital * u.av_attrib END END AS av_total,
         u.missing, u.e, u.g, u.ro, u.n, u.l, u.paths,
         coalesce(br.bridge, 0) AS bridge, coalesce(br.n_missing, 0) AS bridge_missing,
         coalesce(u.complete, false) AND coalesce(br.n_missing, 0) = 0 AND s.shares > 0 AND s.as_of IS NOT NULL AS complete,
         greatest(0, (vi_today() - s.as_of) / 365.25) AS elapsed
  FROM s LEFT JOIN u ON u.company_id = s.company_id LEFT JOIN br ON br.company_id = s.company_id LEFT JOIN op ON op.company_id = s.company_id
), z AS (
  SELECT x.*, power(1 + h, elapsed) / shares AS k,
         CASE WHEN complete THEN vi_gw_irr(e, g, ro, n, l, false, bridge, shares, elapsed, latest_price) END AS irr_epv,
         CASE WHEN complete THEN vi_gw_irr_paths(e, g, ro, n, l, true, bridge, shares, elapsed, latest_price, paths) END AS irr_full
  FROM x
), y AS (
  SELECT z.*,
         CASE WHEN complete THEN (av_total + bridge) * k END AS av_ps,
         CASE WHEN complete THEN (epv_total + bridge) * k END AS epv_ps,
         CASE WHEN complete THEN (full_total + bridge) * k END AS full_ps
  FROM z
), v AS (
  SELECT y.*,
         CASE value_layer WHEN '资产价值' THEN av_ps WHEN '盈利能力价值' THEN epv_ps WHEN '含增长价值' THEN full_ps END AS value_ps,
         CASE value_layer WHEN '盈利能力价值' THEN irr_epv WHEN '含增长价值' THEN irr_full END AS implied_irr
  FROM y
)
SELECT company_id AS id, company_id, company_name, h AS hurdle, as_of, shares, bridge, av_basis, book_capital, adj_capital, av_attrib,
       av_total, epv_total, full_total,
       av_ps, epv_ps, full_ps, value_layer, value_ps,
       latest_price AS market_price, latest_price_date AS market_date, irr_epv, irr_full, implied_irr, complete,
       CASE WHEN NOT complete THEN '输入不完整：' || coalesce(missing,
              CASE WHEN bridge_missing > 0 THEN '资产负债桥有科目在报表里找不到' WHEN as_of IS NULL THEN '公司没填估值截至日' ELSE '股本未填' END)
            ELSE format('主估值层：%s。按门槛 %s，今天每股：资产价值 %s、盈利能力价值 %s、含增长价值 %s 元。', coalesce(value_layer, '未选'),
                        vi_pct(h, 1), vi_fmt(av_ps), vi_fmt(epv_ps), vi_fmt(full_ps))
              || CASE WHEN latest_price IS NULL THEN '暂无市价。'
                      ELSE format('市价 %s 元', vi_fmt(latest_price))
                           || CASE WHEN av_ps IS NOT NULL AND latest_price <= av_ps THEN '，低于资产价值'
                                   WHEN latest_price <= epv_ps THEN '，低于盈利能力价值：不为增长付钱'
                                   WHEN latest_price <= full_ps THEN '，在盈利能力价值与含增长价值之间：为部分增长付钱'
                                   ELSE '，高于含增长价值' END
                           || format('；隐含年化回报：不增长 %s、含增长 %s（门槛 %s）。', vi_pct(irr_epv, 1), vi_pct(irr_full, 1), vi_pct(h, 1)) END END AS conclusion
FROM v;

---------------------------------------------------------------------------
-- 质量自检：每家公司一组。C＝数据、论点、壁垒、适配度、风险；G＝三层估值。
---------------------------------------------------------------------------
CREATE VIEW vi_check AS
WITH m AS (
  SELECT co.id AS company_id, co.name AS company_name, vi_hurdle() AS h, co.as_of, co.value_layer, cc.latest_price_date
  FROM vi_company_base co LEFT JOIN vi_company_calc cc ON cc.id = co.id
), c AS (
  SELECT m.*,
    (SELECT count(*) FROM vi_collector_base k JOIN vi_collector_calc kc USING (id) WHERE kc.needs_alert) AS n_alert,
    (SELECT count(*) FROM vi_observation_base o JOIN vi_observation_calc oc USING (id)
       JOIN vi_metric_base mt ON mt.id = o.metric_id WHERE NOT oc.is_valid AND (mt.company_id = m.company_id OR mt.company_id IS NULL)) AS n_invalid,
    (SELECT count(*) FROM vi_thesis_base th JOIN vi_thesis_calc tc USING (id) WHERE th.company_id = m.company_id AND tc.check_result LIKE '已触发%') AS n_falsified,
    (SELECT count(*) FROM vi_thesis_base th JOIN vi_thesis_calc tc USING (id) WHERE th.company_id = m.company_id AND tc.check_result NOT IN ('未设置')) AS n_checked,
    (SELECT count(*) FROM vi_moat_base mo WHERE mo.company_id = m.company_id) AS n_moat,
    (SELECT format('真实壁垒 %s、局部优势 %s、伪壁垒 %s、待验证 %s',
                   count(*) FILTER (WHERE mo.verdict = '真实壁垒'), count(*) FILTER (WHERE mo.verdict = '局部优势'),
                   count(*) FILTER (WHERE mo.verdict = '伪壁垒'), count(*) FILTER (WHERE mo.verdict IS NULL OR mo.verdict = '待验证'))
       FROM vi_moat_base mo WHERE mo.company_id = m.company_id) AS moat_mix,
    (SELECT count(*) FROM vi_moat_base mo WHERE mo.company_id = m.company_id AND mo.verdict IS DISTINCT FROM '伪壁垒'
       AND NOT EXISTS (SELECT 1 FROM vi_lnk_moat_theses l JOIN vi_thesis_base t ON t.id = l.thesis_id
                       WHERE l.moat_id = mo.id AND t.debated_on IS NOT NULL)) AS n_moat_undebated,
    (SELECT count(*) FROM vi_moat_base mo JOIN vi_moat_calc mc USING (id) WHERE mo.company_id = m.company_id
       AND mc.check_result LIKE '已触发%') AS n_moat_broken,
    (SELECT count(*) FROM vi_fit_score_base fs WHERE fs.company_id = m.company_id AND fs.score IS NOT NULL) AS n_fit,
    (SELECT sum(fs.score) FROM vi_fit_score_base fs WHERE fs.company_id = m.company_id) AS fit_total,
    (SELECT string_agg(z.txt, '；' ORDER BY z.sort) FROM (
       SELECT fs.sort, format('%s %s 分，但 %s', fs.dimension, fs.score,
                              string_agg(t.code || ' ' || t.status, '、' ORDER BY t.code)) AS txt
       FROM vi_fit_score_base fs JOIN vi_lnk_fit_score_theses l ON l.fit_score_id = fs.id JOIN vi_thesis_base t ON t.id = l.thesis_id
       WHERE fs.company_id = m.company_id AND fs.score >= 4 AND t.status IN ('存疑', '证伪')
       GROUP BY fs.id, fs.sort, fs.dimension, fs.score) z) AS fit_conflict,
    (SELECT count(*) FROM vi_risk_base r WHERE r.company_id = m.company_id) AS n_risk,
    (SELECT format('重大 %s、重要 %s、一般 %s', count(*) FILTER (WHERE rc.level = '重大'), count(*) FILTER (WHERE rc.level = '重要'),
                   count(*) FILTER (WHERE rc.level = '一般'))
       FROM vi_risk_base r JOIN vi_risk_calc rc USING (id) WHERE r.company_id = m.company_id) AS risk_mix,
    (SELECT string_agg(r.code, '、' ORDER BY r.code) FROM vi_risk_base r JOIN vi_risk_calc rc USING (id)
      WHERE r.company_id = m.company_id AND rc.level = '重大' AND coalesce(r.treatment, '未计入估值') = '未计入估值') AS risk_unpriced,
    (SELECT string_agg(r.code, '、' ORDER BY r.code) FROM vi_risk_base r JOIN vi_risk_calc rc USING (id)
      WHERE r.company_id = m.company_id AND rc.level IN ('重大', '重要') AND nullif(trim(r.early_warning), '') IS NULL
        AND NOT EXISTS (SELECT 1 FROM vi_lnk_risk_metrics l WHERE l.risk_id = r.id)) AS risk_no_signal,
    (SELECT string_agg(r.code, '、' ORDER BY r.code) FROM vi_risk_base r
      WHERE r.company_id = m.company_id AND (r.probability IS NULL OR r.impact IS NULL OR r.treatment IS NULL)) AS risk_incomplete,
    -- 三层估值
    (SELECT count(*) FROM vi_epv_base e WHERE e.company_id = m.company_id) AS n_epv,
    (SELECT count(*) FROM vi_bs_item_base b WHERE b.company_id = m.company_id AND nullif(btrim(b.line_item), '') IS NOT NULL) AS n_stmt_rows,
    (SELECT sum(c.book_signed) FROM vi_bs_item_base b JOIN vi_bs_item_calc c ON c.id = b.id WHERE b.company_id = m.company_id) AS book_sum,
    (SELECT string_agg(b.line_item, '、') FROM vi_bs_item_base b JOIN vi_bs_item_calc c ON c.id = b.id
      WHERE b.company_id = m.company_id AND c.book IS NULL) AS items_missing,
    (SELECT string_agg(f.line_item || '（' || f.n || ' 行）', '、') FROM (SELECT b.line_item, count(*) AS n FROM vi_bs_item_base b
      WHERE b.company_id = m.company_id AND nullif(btrim(b.line_item), '') IS NOT NULL GROUP BY b.line_item HAVING count(*) > 1) f) AS items_dup,
    (SELECT max(f.amount) FROM vi_fin_stmt_base f WHERE f.company_id = m.company_id AND f.stmt = '资产负债表' AND f.period_end = m.as_of
        AND f.item IN ('归属于母公司股东权益合计', '股东权益')) AS equity_parent,
    (SELECT string_agg(u.business_name || '（' || u.note || '）', '；') FROM vi_gw_unit u
      WHERE u.company_id = m.company_id AND NOT u.complete) AS incomplete,
    (SELECT string_agg(DISTINCT bz.name, '、') FROM vi_growth_base g JOIN vi_business_base bz ON bz.id = g.business_id
      WHERE g.company_id = m.company_id AND NOT EXISTS (SELECT 1 FROM vi_epv_base e WHERE e.business_id = g.business_id)) AS rows_missing,
    (SELECT string_agg(DISTINCT u.business_name || ' ' || vi_pct(u.g, 1), '、') FROM vi_gw_unit u
      WHERE u.company_id = m.company_id AND u.adv_years IS NULL AND u.g >= u.h) AS bad_g,
    (SELECT count(*) FROM vi_growth_base g WHERE g.company_id = m.company_id AND (g.revenue_plan IS NOT NULL OR coalesce(g.growth, 0) > 0) AND g.ronic > m.h) AS n_ronic_high,
    (SELECT string_agg(DISTINCT bz.name || ' ' || vi_pct(g.ronic, 0), '、')
       FROM vi_growth_base g JOIN vi_business_base bz ON bz.id = g.business_id
      WHERE g.company_id = m.company_id AND (g.revenue_plan IS NOT NULL OR coalesce(g.growth, 0) > 0) AND g.ronic > m.h
        AND NOT EXISTS (SELECT 1 FROM vi_lnk_growth_judgments gj JOIN vi_lnk_judgment_theses jt ON jt.judgment_id = gj.judgment_id
                          JOIN vi_thesis_base t ON t.id = jt.thesis_id AND t.status = '成立'
                          JOIN vi_lnk_moat_theses mt ON mt.thesis_id = t.id JOIN vi_moat_base mo ON mo.id = mt.moat_id AND mo.verdict = '真实壁垒'
                         WHERE gj.growth_id = g.id)) AS ronic_unbacked,
    (SELECT count(*) FROM vi_epv_base e WHERE e.company_id = m.company_id AND e.section <> '不计入'
        AND NOT EXISTS (SELECT 1 FROM vi_lnk_epv_judgments x WHERE x.epv_id = e.id))
     + (SELECT count(*) FROM vi_growth_base g WHERE g.company_id = m.company_id
        AND NOT EXISTS (SELECT 1 FROM vi_lnk_growth_judgments x WHERE x.growth_id = g.id)) AS n_input_nojudg,
    (SELECT string_agg(coalesce(nullif(b.name, ''), b.line_item), '、') FROM vi_bs_item_base b
      WHERE b.company_id = m.company_id AND (coalesce(b.haircut, 0) <> 0 OR coalesce(b.adjustment, 0) <> 0)
        AND NOT EXISTS (SELECT 1 FROM vi_lnk_bs_item_judgments bj WHERE bj.bs_item_id = b.id)) AS bs_nojudg,
    (SELECT string_agg(DISTINCT j.code, '、') FROM vi_judgment_base j WHERE coalesce(j.status, '') <> '已采纳' AND j.id IN (
        SELECT x.judgment_id FROM vi_lnk_epv_judgments x JOIN vi_epv_base e ON e.id = x.epv_id WHERE e.company_id = m.company_id
        UNION SELECT x.judgment_id FROM vi_lnk_growth_judgments x JOIN vi_growth_base g ON g.id = x.growth_id WHERE g.company_id = m.company_id
        UNION SELECT x.judgment_id FROM vi_lnk_bs_item_judgments x JOIN vi_bs_item_base b ON b.id = x.bs_item_id WHERE b.company_id = m.company_id)) AS judg_open,
    (SELECT string_agg(DISTINCT u.business_name, '、') FROM vi_gw_unit u WHERE u.company_id = m.company_id AND u.capital_basis = '股权'
        AND EXISTS (SELECT 1 FROM vi_bs_item_base b WHERE b.company_id = m.company_id AND b.category = '有息负债')) AS debt_in_enterprise,
    NULL::text AS equity_no_debt,
    (SELECT string_agg(u.business_name, '、') FROM vi_gw_unit u WHERE u.company_id = m.company_id AND u.n_post = 0) AS no_maint,
    (SELECT CASE WHEN co.av_basis = '不适用' THEN co.name END FROM vi_company_base co WHERE co.id = m.company_id) AS av_na
  FROM m
), g AS (
  SELECT c.*, judg_open IS NULL AS judg_ok, cardinality(string_to_array(judg_open, '、')) AS n_judg_open FROM c
)
SELECT company_id * 100 + k AS id, company_id, company_name, code, name,
       CASE WHEN code LIKE 'G%' AND n_epv = 0 THEN '不适用' ELSE result END AS result,
       CASE WHEN code LIKE 'G%' AND n_epv = 0 THEN '还没有三层估值输入' ELSE detail END AS detail
FROM g CROSS JOIN LATERAL (VALUES
  (6, 'C06', '股价数据新鲜',
      CASE WHEN latest_price_date IS NULL THEN '阻断' WHEN vi_today() - latest_price_date > 7 THEN '提示' ELSE '通过' END,
      format('最新股价日期 %s', coalesce(latest_price_date::text, '无'))),
  (9, 'C09', '论点证伪',
      CASE WHEN n_falsified > 0 THEN '阻断' ELSE '通过' END,
      format('%s 条论点设置了自动检查，%s 条已触发', n_checked, n_falsified)),
  (11, 'C11', '自动采集健康',
      CASE WHEN n_alert > 0 THEN '提示' ELSE '通过' END,
      format('%s 个启用的采集源需要处理', n_alert)),
  (12, 'C12', '无效高频数据',
      CASE WHEN n_invalid > 0 THEN '提示' ELSE '通过' END,
      format('%s 条观察超出指标合理范围（已排除在计算之外，原值保留）', n_invalid)),
  (14, 'C14', '竞争壁垒与辩论',
      CASE WHEN n_moat = 0 OR n_moat_undebated > 0 OR n_moat_broken > 0 THEN '提示' ELSE '通过' END,
      CASE WHEN n_moat = 0 THEN '还没有识别竞争壁垒（商业模式 / 竞争壁垒）'
           ELSE format('%s 项候选壁垒（%s）；伪壁垒以外还有 %s 项没有关联辩论过的论点（核心论点里填辩论日期并关联壁垒）；壁垒自动检查已触发 %s 项',
                       n_moat, moat_mix, n_moat_undebated, n_moat_broken) END),
  (15, 'C15', '价值投资适配度',
      CASE WHEN n_fit < 8 OR fit_total < 22 THEN '提示' ELSE '通过' END,
      format('已评 %s / 8 个维度，总分 %s / 40：%s', n_fit, coalesce(fit_total, 0),
             CASE WHEN n_fit < 8 THEN '评分未完成'
                  WHEN fit_total >= 32 THEN '适合价值投资复利框架（仍需价格安全边际）'
                  WHEN fit_total >= 22 THEN '合适，需说明更偏复利、现金流价值还是资产价值'
                  ELSE '通常不符合价值投资标准' END)),
  (18, 'C18', '适配度与论点一致',
      CASE WHEN fit_conflict IS NULL THEN '通过' ELSE '提示' END,
      coalesce('给了 4 分以上、但关联论点是存疑或证伪的维度：' || fit_conflict || '。要么下调评分，要么说明为什么论点存疑不影响这个维度',
               '4 分以上的维度，关联论点都不是存疑或证伪')),
  (19, 'C19', '风险分析',
      CASE WHEN n_risk = 0 OR risk_unpriced IS NOT NULL OR risk_no_signal IS NOT NULL OR risk_incomplete IS NOT NULL THEN '提示' ELSE '通过' END,
      CASE WHEN n_risk = 0 THEN '还没有做风险分析（商业模式 / 风险分析）'
           ELSE format('%s 条风险（%s）', n_risk, risk_mix)
                || coalesce('；重大风险未计入估值：' || risk_unpriced || '（在悲观情景或参数里体现，或在影响测算里说明为什么不计）', '')
                || coalesce('；重大、重要风险缺预警信号：' || risk_no_signal, '')
                || coalesce('；可能性、冲击或估值处理没填：' || risk_incomplete, '')
                || CASE WHEN risk_unpriced IS NULL AND risk_no_signal IS NULL AND risk_incomplete IS NULL
                        THEN '；重大风险都已计入估值，重大、重要风险都有预警信号' ELSE '' END END),
  (21, 'G01', '资产负债表对账',
      CASE WHEN items_missing IS NOT NULL OR items_dup IS NOT NULL THEN '阻断'
           WHEN n_stmt_rows = 0 THEN '提示'
           WHEN equity_parent IS NULL THEN '提示'
           WHEN abs(book_sum - equity_parent) <= 0.5 THEN '通过' ELSE '阻断' END,
      CASE WHEN items_missing IS NOT NULL THEN '这些报表科目在截至日 ' || coalesce(as_of::text, '（未填）') || ' 的资产负债表里找不到：' || items_missing
           WHEN items_dup IS NOT NULL THEN '同一报表科目写了多行：' || items_dup
           WHEN n_stmt_rows = 0 THEN '还没有按资产负债表逐项归类'
           WHEN equity_parent IS NULL THEN '截至日 ' || coalesce(as_of::text, '（未填）') || ' 没有资产负债表，无法对账'
           ELSE format('报表科目的账面计入值合计 %s 亿元，报表归母股东权益 %s 亿元，相差 %s 亿元%s', vi_fmt(book_sum, 2), vi_fmt(equity_parent, 2),
                       vi_fmt(book_sum - equity_parent, 2),
                       CASE WHEN abs(book_sum - equity_parent) <= 0.5 THEN '：每个科目只计一次，不漏不重' ELSE '：有科目漏了或重复了' END) END),
  (22, 'G02', '输入完整',
      CASE WHEN incomplete IS NULL AND rows_missing IS NULL THEN '通过' ELSE '阻断' END,
      concat_ws('；', '算不出价值：' || incomplete, '有增长、没有调整后利润表：' || rows_missing)
      || CASE WHEN incomplete IS NULL AND rows_missing IS NULL THEN '每块业务的调整后利润表都算得出' ELSE '' END),
  (23, 'G03', '永续增长低于门槛', CASE WHEN bad_g IS NULL THEN '通过' ELSE '阻断' END,
      coalesce('优势年限留空（永续增长）但增长率不低于门槛 ' || vi_pct(h, 1) || '：' || bad_g, '永续增长的业务，增长率都低于门槛 ' || vi_pct(h, 1))),
  (24, 'G04', '超额回报有壁垒支撑', CASE WHEN ronic_unbacked IS NULL THEN '通过' ELSE '提示' END,
      CASE WHEN n_ronic_high = 0 THEN '没有高于门槛的新增投资回报：增长不创造价值（保守默认）'
           ELSE coalesce('新增投资回报率高于门槛，但依据没有经“成立”的论点连到“真实壁垒”：' || ronic_unbacked,
                         n_ronic_high || ' 块业务的新增投资回报高于门槛，依据都经“成立”的论点连到“真实壁垒”') END),
  (25, 'G05', '每个数都有依据', CASE WHEN n_input_nojudg = 0 AND bs_nojudg IS NULL THEN '通过' ELSE '阻断' END,
      concat_ws('；', CASE WHEN n_input_nojudg > 0 THEN n_input_nojudg || ' 行调整后利润表或增长没有关联假设依据' END,
                '有折价或调整额但没有关联假设依据：' || bs_nojudg)
      || CASE WHEN n_input_nojudg = 0 AND bs_nojudg IS NULL THEN '调整后利润表、增长与资产负债调整都关联了假设依据' ELSE '' END),
  (26, 'G06', '依据已采纳', CASE WHEN judg_ok THEN '通过' ELSE '提示' END,
      CASE WHEN judg_ok THEN '用到的假设依据都已采纳'
           ELSE format('%s 条用到的假设依据还不是“已采纳”（%s）：数字可用，但还没最终确认', n_judg_open, judg_open) END),
  (27, 'G07', '口径开关一致', CASE WHEN debt_in_enterprise IS NOT NULL THEN '阻断' WHEN equity_no_debt IS NOT NULL THEN '提示' ELSE '通过' END,
      coalesce('股权口径（利润已扣利息）的业务，但资产负债重估里还有“有息负债”进资产负债桥，债务会扣两次：' || debt_in_enterprise
               || '。股权口径的公司把有息负债归为经营负债', '企业口径：有息负债在资产负债桥里扣；股权口径：有息负债归为经营负债')),
  (28, 'G08', '维持性投入已估', CASE WHEN no_maint IS NULL THEN '通过' ELSE '提示' END,
      coalesce('调整后利润表没有税后调整（折旧摊销、维持性资本开支），按两者相等处理：' || no_maint, '每块业务都估了折旧摊销与维持性资本开支')),
  (29, 'G09', '主估值层', CASE WHEN value_layer IS NULL THEN '提示' WHEN value_layer = '资产价值' AND av_na IS NOT NULL THEN '阻断' ELSE '通过' END,
      CASE WHEN value_layer IS NULL THEN '没选主估值层：只展示三层，不给结论'
           WHEN value_layer = '资产价值' AND av_na IS NOT NULL THEN '主估值层是资产价值，但公司的资产价值口径是“不适用”'
           ELSE '主估值层：' || value_layer END)
) AS x(k, code, name, result, detail);

COMMIT;
