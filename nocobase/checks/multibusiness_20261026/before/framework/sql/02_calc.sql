-- 价值投资研究框架：计算层（手写）。每个 vi_<表>_calc 输出 id + 计算列；vi_projection / vi_valuation /
-- vi_sensitivity / vi_check 是只读报表视图。全部按公司/模型/情景泛化，不写死公司、年份、情景名或指标代码。
-- 约定：未知值保持 NULL（不当作 0）；r <= g 时不输出价值；比率均为小数。
BEGIN;

DROP VIEW IF EXISTS vi_check, vi_sotp, vi_sotp_segment_calc, vi_sotp_segment_val, vi_sotp_item_calc, vi_moat_calc, vi_risk_calc, vi_sensitivity, vi_valuation, vi_valuation_cf, vi_balance, vi_projection, vi_collect_run_calc, vi_trial_calc,
  vi_forecast_calc, vi_scenario_calc, vi_model_calc, vi_watch_calc, vi_thesis_calc, vi_fin_metric,
  vi_fin_history_calc, vi_collector_calc, vi_raw_capture_calc, vi_observation_calc, vi_obs_current, vi_disclosed,
  vi_metric_calc, vi_company_calc, vi_company_metric CASCADE;

---------------------------------------------------------------------------
-- 通用函数
---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION vi_num(t text) RETURNS double precision LANGUAGE sql IMMUTABLE AS $$
  SELECT CASE WHEN t ~ '^\s*[-+]?([0-9]+\.?[0-9]*|\.[0-9]+)([eE][-+]?[0-9]+)?\s*$' THEN t::double precision END
$$;

CREATE OR REPLACE FUNCTION vi_today() RETURNS date LANGUAGE sql STABLE AS $$
  SELECT (now() AT TIME ZONE 'Asia/Shanghai')::date
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
-- 高频数据
---------------------------------------------------------------------------
CREATE VIEW vi_observation_calc AS
SELECT o.id, m.unit, m.basis, m.source_kind,
       o.id = (SELECT o2.id FROM vi_observation_base o2
                WHERE o2.metric_id = o.metric_id AND o2.obs_date = o.obs_date
                ORDER BY o2.collected_at DESC NULLS LAST, o2.id DESC LIMIT 1) AS is_current,
       (o.value IS NOT NULL
        AND o.value >= coalesce(m.valid_min, '-infinity'::float8)
        AND o.value <= coalesce(m.valid_max, 'infinity'::float8)) AS is_valid
FROM vi_observation_base o LEFT JOIN vi_metric_base m ON m.id = o.metric_id;

-- 每个指标的“当前且有效”观察（供其他视图引用）
CREATE VIEW vi_obs_current AS
SELECT o.metric_id, o.obs_date, o.value, o.id
FROM vi_observation_base o JOIN vi_observation_calc c USING (id)
WHERE c.is_current AND c.is_valid;

-- 公司披露的数据：指标＋数据里来源方式＝公司披露的部分，按“期间 × 项目 × 口径”展开（驾驶舱图表、核对脚本读这里）
CREATE VIEW vi_disclosed AS
SELECT o.id, m.company_id, o.period, o.obs_date AS period_end, m.basis AS period_kind, m.name AS line_item, o.value, m.unit, o.yoy,
       o.impact, o.assessment, o.summary, o.status, o.doc_id AS source_id, m.id AS metric_id, m.code AS metric_code
FROM vi_observation_base o JOIN vi_metric_base m ON m.id = o.metric_id
WHERE m.source_kind = '公司披露';

-- 写入一条公司披露的数据：按 公司×项目×口径×单位 找指标，没有就新建（代码＝公司代码.D001 起顺序编号）；
-- 同一指标同一期间已有的数据先删掉再写，可重复执行。种子脚本和迁移都用它，规则只写一处。
-- 业务驱动与财务结果分域；合同额/合约销售额和 ARPPU 是业务，不能仅按金额单位判断。
CREATE OR REPLACE FUNCTION vi_disclosed_category(p_item text) RETURNS text LANGUAGE sql IMMUTABLE AS $$
SELECT CASE WHEN p_item = ANY(ARRAY['AIoT平台连接设备数（不含手机和平板）', '全球月活跃用户', '全球月活跃用户（12 月）', '单个付费用户月均收入（ARPPU）', '发电量', '在线音乐付费用户', '在线音乐月活跃用户', '地产合约销售额', '建筑业务新签合同额', '房屋建筑新开工面积', '拥有五件及以上AIoT设备的用户数', '新签合同总额', '智能手机ASP', '智能手机出货量', '汽车ASP', '汽车交付量', '浆纸销量（管理层口径）', '竞品月活：汽水音乐']) THEN '经营'
            WHEN p_item ~ '收入|利润|毛利|费用|开支|损益|现金|负债|借款|应收|应付|减值|回购|股息|收益' THEN '财务'
            ELSE '其他' END
$$;

CREATE OR REPLACE FUNCTION vi_put_disclosed(p_company bigint, p_item text, p_basis text, p_unit text, p_period text, p_end date,
                                            p_value double precision, p_yoy double precision, p_impact text, p_assessment text,
                                            p_summary text, p_status text, p_doc bigint) RETURNS bigint LANGUAGE plpgsql AS $$
DECLARE mid bigint; ccode text; n int; oid bigint;
BEGIN
  SELECT id INTO mid FROM vi_metric_base
   WHERE company_id = p_company AND source_kind = '公司披露' AND name = p_item AND basis IS NOT DISTINCT FROM p_basis
     AND unit IS NOT DISTINCT FROM p_unit
   ORDER BY id LIMIT 1;
  IF mid IS NULL THEN
    SELECT code INTO ccode FROM vi_company_base WHERE id = p_company;
    SELECT coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1 INTO n FROM vi_metric_base WHERE code LIKE ccode || '.D%';
    INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency)
    VALUES (ccode || '.D' || lpad(n::text, 3, '0'), p_item, p_unit, vi_disclosed_category(p_item), '公司披露', p_basis, p_company, '公司披露',
            CASE p_basis WHEN '单季' THEN '季' WHEN '半年累计' THEN '半年' WHEN '前三季度累计' THEN '年' WHEN '全年' THEN '年' END)
    RETURNING id INTO mid;
  END IF;
  DELETE FROM vi_observation_base WHERE metric_id = mid AND period IS NOT DISTINCT FROM p_period;
  INSERT INTO vi_observation_base (metric_id, obs_date, period, value, yoy, impact, assessment, summary, status, doc_id, collected_at)
  VALUES (mid, p_end, p_period, p_value, p_yoy, p_impact, p_assessment, p_summary, p_status, p_doc, now())
  RETURNING id INTO oid;
  RETURN oid;
END $$;

-- 每家公司用到哪些指标、做什么用（唯一来源，不另存）：自有指标、股价、股价汇率、估值模型的无风险利率、跟踪事项、订阅的宏观数据。
-- 指标的“使用公司”、公司的“用到的宏观数据”、一键采集的范围都从这里读。
CREATE VIEW vi_company_metric AS
SELECT company_id, metric_id, string_agg(DISTINCT usage, '、' ORDER BY usage) AS usages
FROM (
  SELECT company_id, id AS metric_id, '自有' AS usage FROM vi_metric_base WHERE company_id IS NOT NULL
  UNION ALL SELECT id, price_metric_id, '股价' FROM vi_company_base WHERE price_metric_id IS NOT NULL
  UNION ALL SELECT id, price_fx_metric_id, '汇率折算' FROM vi_company_base WHERE price_fx_metric_id IS NOT NULL
  UNION ALL SELECT company_id, rf_metric_id, '无风险利率' FROM vi_model_base WHERE rf_metric_id IS NOT NULL AND company_id IS NOT NULL
  UNION ALL SELECT company_id, metric_id, '跟踪事项' FROM vi_watch_base WHERE metric_id IS NOT NULL AND company_id IS NOT NULL
  UNION ALL SELECT company_id, metric_id, '订阅' FROM vi_lnk_company_macro_metrics
) u
GROUP BY company_id, metric_id;

CREATE VIEW vi_metric_calc AS
SELECT m.id,
       (SELECT count(*) FROM vi_observation_base o WHERE o.metric_id = m.id)::int AS obs_count,
       l.value AS latest_value, l.obs_date AS latest_date,
       CASE WHEN m.company_id IS NULL THEN '宏观' ELSE '公司' END AS scope,
       u.used_by, u.used_by_codes
FROM vi_metric_base m
LEFT JOIN LATERAL (SELECT value, obs_date FROM vi_obs_current x WHERE x.metric_id = m.id
                   ORDER BY obs_date DESC LIMIT 1) l ON true
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
--                           自有、股价、汇率折算、无风险利率、跟踪事项、订阅的宏观数据）；没有公司时＝全部启用的数据源
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
  INSERT INTO vi_observation_base (metric_id, obs_date, value, collected_at, source, raw_capture_id, note)
  SELECT metric_id, parsed_date, parsed_value, collected_at, url, id,
         '本机 NocoBase 自动采集；通过基础解析与范围校验，非财务核验；不得自动改变估值假设。'
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
CREATE VIEW vi_fin_history_calc AS
WITH b AS (
  SELECT h.*,
         h.revenue / NULLIF(h.volume, 0) AS price_,
         lag(h.year) OVER w AS py, lag(h.scope_note) OVER w AS p_scope, lag(h.volume) OVER w AS p_volume, lag(h.revenue) OVER w AS p_revenue,
         lag(h.revenue / NULLIF(h.volume, 0)) OVER w AS p_price, lag(h.np_parent) OVER w AS p_np,
         lag(h.finance_cost) OVER w AS p_fc, lag(h.equity_parent) OVER w AS p_equity
  FROM vi_fin_history_base h
  WINDOW w AS (PARTITION BY h.company_id ORDER BY h.year)
)
SELECT id,
       price_ AS price,
       dividend_total / NULLIF(np_parent, 0) AS payout,
       income_tax / NULLIF(pretax_profit, 0) AS tax_rate,
       minority_profit / NULLIF(pretax_profit - income_tax, 0) AS minority_share,
       1 - np_parent / NULLIF(pretax_profit, 0) AS burden,
       cfo - capex AS fcf,
       CASE WHEN py = year - 1 AND p_scope IS NOT DISTINCT FROM scope_note THEN volume / NULLIF(p_volume, 0) - 1 END AS volume_yoy,
       CASE WHEN py = year - 1 AND p_scope IS NOT DISTINCT FROM scope_note THEN price_ / NULLIF(p_price, 0) - 1 END AS price_yoy,
       CASE WHEN py = year - 1 AND p_scope IS NOT DISTINCT FROM scope_note THEN revenue / NULLIF(p_revenue, 0) - 1 END AS revenue_yoy,
       CASE WHEN py = year - 1 AND p_scope IS NOT DISTINCT FROM scope_note THEN np_parent / NULLIF(p_np, 0) - 1 END AS np_yoy,
       CASE WHEN py = year - 1 AND p_scope IS NOT DISTINCT FROM scope_note THEN finance_cost / NULLIF(p_fc, 0) - 1 END AS finance_cost_yoy,
       1 - cost_of_sales / NULLIF(revenue, 0) AS gross_margin,
       CASE WHEN py = year - 1 THEN np_parent / NULLIF((equity_parent + p_equity) / 2, 0) END AS roe,
       cfo / NULLIF(np_parent, 0) AS cfo_to_np,
       capex / NULLIF(cfo, 0) AS capex_to_cfo,
       interest_debt - cash AS net_debt,
       (interest_debt - cash) / NULLIF(pretax_profit + finance_cost + da, 0) AS net_debt_to_ebitda
FROM b;

-- 长表：公司×年度×指标名（论点检查按中文指标名取值）
CREATE VIEW vi_fin_metric AS
SELECT h.company_id, h.year, x.metric, x.value
FROM vi_fin_history_base h JOIN vi_fin_history_calc c USING (id)
CROSS JOIN LATERAL (VALUES
  ('业务量', h.volume), ('单价', c.price), ('营业收入', h.revenue), ('归母净利润', h.np_parent),
  ('派息率', c.payout), ('财务费用', h.finance_cost), ('业务量同比', c.volume_yoy),
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
-- 估值模型：参数、情景、逐年假设
---------------------------------------------------------------------------
CREATE VIEW vi_model_calc AS
SELECT m.id,
       round((m.rf + m.erp)::numeric, 3)::float8 AS base_discount_rate,
       vi_today() AS valuation_date,
       (vi_today() - make_date(m.base_year, 12, 31)) / 365.25 AS years_elapsed,
       l.value AS latest_rf, l.obs_date AS latest_rf_date
FROM vi_model_base m
LEFT JOIN LATERAL (SELECT value, obs_date FROM vi_obs_current x WHERE x.metric_id = m.rf_metric_id
                   ORDER BY obs_date DESC LIMIT 1) l ON true;

CREATE VIEW vi_scenario_calc AS
SELECT s.id, coalesce(s.discount_rate, mc.base_discount_rate) AS eff_discount_rate
FROM vi_scenario_base s LEFT JOIN vi_model_calc mc ON mc.id = s.model_id;

CREATE VIEW vi_forecast_calc AS
WITH d AS (
  SELECT f.*, m.opening_debt,
         sum(f.net_borrowing) OVER w AS nb_before,
         count(*) OVER w AS n_before, count(f.net_borrowing) OVER w AS nb_known_before
  FROM vi_forecast_base f LEFT JOIN vi_model_base m ON m.id = f.model_id
  WINDOW w AS (PARTITION BY f.model_id ORDER BY f.year ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING)
), e AS (
  SELECT d.*,
         CASE WHEN coalesce(n_before, 0) = coalesce(nb_known_before, 0)
              THEN opening_debt + coalesce(nb_before, 0) END AS debt_open_
  FROM d
)
SELECT id,
       volume * price AS revenue,
       debt_open_ AS debt_open,
       debt_open_ + net_borrowing AS debt_close,
       (debt_open_ + (debt_open_ + net_borrowing)) / 2 * cost_of_debt AS interest,
       depreciation * (1 - minority_share) AS attrib_da,
       (noncash_gain_deduct IS NOT NULL AND investee_cash_div IS NOT NULL AND other_cash_adj IS NOT NULL
        AND wc_increase IS NOT NULL AND maint_capex IS NOT NULL AND growth_capex IS NOT NULL
        AND min_cash_topup IS NOT NULL AND net_borrowing IS NOT NULL) AS cash_complete
FROM e;

---------------------------------------------------------------------------
-- 预测计算：情景 × 年度
---------------------------------------------------------------------------
CREATE VIEW vi_projection AS
WITH j AS (
  SELECT s.id AS scenario_id, s.model_id, s.name AS scenario_name, s.is_base, s.sort,
         s.volume_factor, s.price_factor, s.cost_factor, sc.eff_discount_rate AS r,
         m.base_year, m.terminal_year, m.shares, m.name AS model_name, co.name AS company_name, m.company_id,
         f.year, f.volume * s.volume_factor AS volume, f.price * s.price_factor AS price,
         f.cash_cost * s.cost_factor AS cash_cost, f.depreciation, fc.interest, f.other_contrib,
         f.tax_rate, f.minority_share, f.payout, f.net_borrowing, fc.debt_close, fc.attrib_da, fc.cash_complete,
         f.noncash_gain_deduct, f.investee_cash_div, f.other_cash_adj, f.wc_increase, f.maint_capex,
         f.growth_capex, f.min_cash_topup
  FROM vi_scenario_base s
  JOIN vi_scenario_calc sc ON sc.id = s.id
  JOIN vi_model_base m ON m.id = s.model_id
  LEFT JOIN vi_company_base co ON co.id = m.company_id
  JOIN vi_forecast_base f ON f.model_id = s.model_id
  JOIN vi_forecast_calc fc ON fc.id = f.id
), k AS (
  SELECT j.*, volume * price AS revenue FROM j
), l AS (
  SELECT k.*, revenue - cash_cost - depreciation - interest + other_contrib AS pretax FROM k
), m AS (
  SELECT l.*, pretax * tax_rate AS tax, pretax * (1 - tax_rate) * minority_share AS minority,
         pretax * (1 - tax_rate) * (1 - minority_share) AS np_parent,
         1 / power(1 + r, year - base_year) AS discount_factor
  FROM l
), n AS (
  SELECT m.*, greatest(0, np_parent * payout) AS dividend,
         CASE WHEN cash_complete THEN np_parent + attrib_da - noncash_gain_deduct + investee_cash_div
                                       + other_cash_adj - wc_increase - maint_capex END AS owner_earnings
  FROM m
), o AS (
  SELECT n.*, owner_earnings - growth_capex + net_borrowing AS fcfe FROM n
)
SELECT scenario_id * 10000 + year AS id, scenario_id, model_id, company_id, company_name, model_name,
       scenario_name, is_base, sort, year, base_year, terminal_year, shares,
       volume, price, revenue, cash_cost, depreciation, interest, other_contrib, pretax, tax, minority, np_parent,
       payout, dividend, dividend / NULLIF(shares, 0) AS dps, r AS discount_rate, discount_factor,
       dividend * discount_factor AS dividend_pv, owner_earnings, fcfe,
       least(dividend, greatest(0, fcfe - min_cash_topup)) AS cash_supported_div,
       greatest(0, dividend + min_cash_topup - fcfe) AS funding_gap,
       least(dividend, greatest(0, fcfe - min_cash_topup)) * discount_factor AS cash_div_pv,
       debt_close, cash_complete
FROM o;

---------------------------------------------------------------------------
-- 资产与资本：资产侧单独滚动（情景 × 年度）
--   经营性长期资产＝期初＋维持资本＋扩张资本−折旧；长期股权投资＝期初＋权益法收益−收到投资分红
--   归母权益＝期初＋归母净利−股息；少数股东权益＝期初＋少数股东损益×(1−派息率)
--   其他净资产（平衡项）＝归母权益＋少数股东权益＋带息负债−经营性长期资产−长期股权投资
---------------------------------------------------------------------------
CREATE VIEW vi_balance AS
WITH j AS (
  SELECT p.id, p.scenario_id, p.model_id, p.company_id, p.company_name, p.model_name, p.scenario_name, p.is_base, p.sort, p.year,
         p.np_parent, p.dividend, p.minority, p.payout, p.pretax, p.interest, p.depreciation, p.debt_close,
         f.maint_capex + f.growth_capex AS capex_total, f.noncash_gain_deduct - f.investee_cash_div AS lt_change,
         m.opening_op_assets, m.opening_lt_invest, m.opening_equity, m.opening_minority, m.opening_debt
  FROM vi_projection p
  JOIN vi_forecast_base f ON f.model_id = p.model_id AND f.year = p.year
  JOIN vi_model_base m ON m.id = p.model_id
), c AS (
  SELECT j.*,
         opening_op_assets + sum(capex_total - depreciation) OVER w AS op_assets_close,
         opening_lt_invest + sum(lt_change) OVER w AS lt_invest_close,
         opening_equity + sum(np_parent - dividend) OVER w AS equity_close,
         opening_minority + sum(minority * (1 - payout)) OVER w AS minority_close
  FROM j
  WINDOW w AS (PARTITION BY scenario_id ORDER BY year ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
), d AS (
  SELECT c.*,
         coalesce(lag(op_assets_close) OVER s, opening_op_assets) AS op_assets_open,
         coalesce(lag(equity_close) OVER s, opening_equity) AS equity_open,
         equity_close + minority_close + debt_close - op_assets_close - lt_invest_close AS other_net_assets
  FROM c WINDOW s AS (PARTITION BY scenario_id ORDER BY year)
)
SELECT id, scenario_id, model_id, company_id, company_name, model_name, scenario_name, is_base, sort, year,
       op_assets_open, capex_total, depreciation, op_assets_close, lt_invest_close, debt_close,
       equity_open, np_parent, dividend, equity_close, minority_close, other_net_assets,
       other_net_assets - coalesce(lag(other_net_assets) OVER s,
                                   opening_equity + opening_minority + opening_debt - opening_op_assets - opening_lt_invest) AS other_net_change,
       np_parent / NULLIF((equity_open + equity_close) / 2, 0) AS roe,
       debt_close / NULLIF(debt_close + equity_close + minority_close, 0) AS debt_to_capital,
       (pretax + interest) / NULLIF(interest, 0) AS interest_cover,
       debt_close / NULLIF(pretax + interest + depreciation, 0) AS debt_to_ebitda
FROM d WINDOW s AS (PARTITION BY scenario_id ORDER BY year);

---------------------------------------------------------------------------
-- 内部收益率：从“今天”起算的每股股息现金流
--   tau＝距今年数＝(年度−基准年)−距基准日年数；已过去的年份（tau≤0）不计入
--   现值 PV(r)＝Σ d_t/(1+r)^tau_t ＋ d_T·(1+g)/(r−g)/(1+r)^tau_T
--   隐含内部收益率＝使 PV(r)＝市场价 的 r（PV 随 r 单调递减，用二分法求解）
---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION vi_pv(divs double precision[], taus double precision[], td double precision,
                                 ttau double precision, g double precision, r double precision)
RETURNS double precision LANGUAGE sql IMMUTABLE AS $$
  SELECT CASE WHEN r IS NULL OR g IS NULL OR td IS NULL OR r <= g OR r <= -1 THEN NULL ELSE
    coalesce((SELECT sum(d / power(1 + r, tau)) FROM unnest(divs, taus) AS x(d, tau) WHERE tau > 0), 0)
    + td * (1 + g) / (r - g) / power(1 + r, ttau) END
$$;

CREATE OR REPLACE FUNCTION vi_irr(divs double precision[], taus double precision[], td double precision,
                                  ttau double precision, g double precision, price double precision)
RETURNS double precision LANGUAGE plpgsql IMMUTABLE AS $$
DECLARE lo double precision := g + 1e-7; hi double precision := 1.0; mid double precision; i int;
BEGIN
  IF price IS NULL OR price <= 0 OR td IS NULL OR g IS NULL OR array_position(divs, NULL) IS NOT NULL THEN RETURN NULL; END IF;
  IF vi_pv(divs, taus, td, ttau, g, hi) > price THEN RETURN NULL; END IF;   -- 收益率超过 100%，视为无意义
  FOR i IN 1..80 LOOP
    mid := (lo + hi) / 2;
    IF vi_pv(divs, taus, td, ttau, g, mid) > price THEN lo := mid; ELSE hi := mid; END IF;
  END LOOP;
  RETURN (lo + hi) / 2;
END $$;

CREATE VIEW vi_valuation_cf AS
SELECT s.id AS scenario_id, s.model_id, s.terminal_growth AS cf_g, m.required_return, mc.years_elapsed AS cf_elapsed,
       array_agg(p.dividend / NULLIF(m.shares, 0) ORDER BY p.year) AS divs,
       array_agg(p.cash_supported_div / NULLIF(m.shares, 0) ORDER BY p.year) AS cash_divs,
       array_agg((p.year - m.base_year) - mc.years_elapsed ORDER BY p.year) AS taus,
       max(p.dividend / NULLIF(m.shares, 0)) FILTER (WHERE p.year = m.terminal_year) AS td,
       max(p.cash_supported_div / NULLIF(m.shares, 0)) FILTER (WHERE p.year = m.terminal_year) AS tcd,
       (m.terminal_year - m.base_year) - mc.years_elapsed AS ttau
FROM vi_scenario_base s
JOIN vi_model_base m ON m.id = s.model_id
JOIN vi_model_calc mc ON mc.id = m.id
JOIN vi_projection p ON p.scenario_id = s.id AND p.year BETWEEN m.base_year + 1 AND m.terminal_year
GROUP BY s.id, s.model_id, s.terminal_growth, m.required_return, mc.years_elapsed, m.terminal_year, m.base_year;

---------------------------------------------------------------------------
-- 估值结论：每个情景一行
---------------------------------------------------------------------------
CREATE VIEW vi_valuation AS
WITH a AS (
  SELECT s.id, s.model_id, s.name AS scenario_name, coalesce(s.is_base, false) AS is_base, s.sort,
         sc.eff_discount_rate AS r, s.terminal_growth AS g,
         m.base_year AS b, m.terminal_year AS t, m.shares, m.margin_low, m.margin_high, m.name AS model_name,
         m.company_id, co.name AS company_name, cc.latest_price, cc.latest_price_date, mc.years_elapsed,
         (SELECT count(*) FROM vi_projection p WHERE p.scenario_id = s.id AND p.year BETWEEN m.base_year + 1 AND m.terminal_year
                 AND p.np_parent IS NOT NULL) AS n_years,
         (SELECT count(*) FROM vi_projection p WHERE p.scenario_id = s.id AND p.year BETWEEN m.base_year + 1 AND m.terminal_year
                 AND p.cash_supported_div IS NOT NULL) AS cash_years,
         (SELECT sum(dividend_pv) FROM vi_projection p WHERE p.scenario_id = s.id AND p.year BETWEEN m.base_year + 1 AND m.terminal_year) AS pv_explicit,
         (SELECT sum(cash_div_pv) FROM vi_projection p WHERE p.scenario_id = s.id AND p.year BETWEEN m.base_year + 1 AND m.terminal_year) AS cash_pv,
         (SELECT dividend FROM vi_projection p WHERE p.scenario_id = s.id AND p.year = m.terminal_year) AS terminal_div,
         (SELECT cash_supported_div FROM vi_projection p WHERE p.scenario_id = s.id AND p.year = m.terminal_year) AS terminal_cash_div
  FROM vi_scenario_base s
  JOIN vi_scenario_calc sc ON sc.id = s.id
  JOIN vi_model_base m ON m.id = s.model_id
  JOIN vi_model_calc mc ON mc.id = m.id
  LEFT JOIN vi_company_base co ON co.id = m.company_id
  LEFT JOIN vi_company_calc cc ON cc.id = m.company_id
), b AS (
  SELECT a.*, n_years = t - b AS complete,
         CASE WHEN r > g THEN terminal_div * (1 + g) / (r - g) / power(1 + r, t - b) END AS terminal_pv,
         CASE WHEN r > g THEN terminal_cash_div * (1 + g) / (r - g) / power(1 + r, t - b) END AS terminal_cash_pv
  FROM a
), c AS (
  SELECT b.*,
         CASE WHEN complete AND r > g AND shares > 0 THEN (pv_explicit + terminal_pv) / shares END AS v0,
         CASE WHEN cash_years = t - b AND r > g AND shares > 0 THEN (cash_pv + terminal_cash_pv) / shares END AS cv0
  FROM b
), d AS (
  SELECT c.*, v0 * power(1 + r, years_elapsed) AS v1, cv0 * power(1 + r, years_elapsed) AS cv1,
         f.required_return AS req,
         CASE WHEN complete THEN vi_pv(f.divs, f.taus, f.td, f.ttau, g, f.required_return) END AS v_req,
         CASE WHEN complete THEN vi_irr(f.divs, f.taus, f.td, f.ttau, g, latest_price) END AS irr,
         CASE WHEN cash_years = t - b THEN vi_irr(f.cash_divs, f.taus, f.tcd, f.ttau, g, latest_price) END AS cash_irr
  FROM c LEFT JOIN vi_valuation_cf f ON f.scenario_id = c.id
)
SELECT id, model_id, company_id, company_name, model_name, scenario_name, is_base, sort, r AS discount_rate, g AS terminal_growth,
       v0 AS value_base_date, v1 AS value_today, cv1 AS cash_value_today,
       pv_explicit, terminal_pv, terminal_pv / NULLIF(pv_explicit + terminal_pv, 0) AS terminal_share,
       latest_price AS market_price, latest_price_date AS market_date,
       latest_price / NULLIF(v1, 0) - 1 AS price_vs_value,
       v1 * (1 - margin_low) AS watch_low, v1 * (1 - margin_high) AS watch_high,
       complete AS years_complete, cash_years::int,
       req AS required_return, v_req AS value_at_required, irr AS implied_irr, cash_irr AS cash_implied_irr,
       irr - req AS irr_spread,
       CASE WHEN NOT complete THEN format('预测年份不完整：需要 %s—%s 年共 %s 年，现有 %s 年', b + 1, t, t - b, n_years)
            WHEN r <= g THEN '折现率不大于永续增长率，不输出价值'
            ELSE CASE WHEN irr IS NULL OR req IS NULL THEN ''
                      ELSE format('按市场价 %s 元买入，隐含年化收益率 %s（现金支持口径 %s），%s要求收益率 %s；按要求收益率的最高买入价 %s 元。',
                                  vi_fmt(latest_price), vi_pct(irr, 2), vi_pct(cash_irr, 2),
                                  CASE WHEN irr >= req THEN '达到' ELSE '低于' END, vi_pct(req, 1), vi_fmt(v_req)) END
              || format('今天每股价值 %s 元（基准日 %s 元按 %s 滚动 %s 年）。%s%s',
                        vi_fmt(v1), vi_fmt(v0), vi_pct(r, 2), round(years_elapsed::numeric, 2),
                        CASE WHEN latest_price IS NULL THEN '暂无市场价。'
                             WHEN latest_price > v1 THEN format('市场价 %s 元，高于今天价值 %s。', vi_fmt(latest_price), vi_pct(latest_price / v1 - 1))
                             WHEN latest_price > v1 * (1 - margin_low) THEN format('市场价 %s 元，低于今天价值 %s，但未到低档关注价 %s 元。', vi_fmt(latest_price), vi_pct(1 - latest_price / v1), vi_fmt(v1 * (1 - margin_low)))
                             WHEN latest_price > v1 * (1 - margin_high) THEN format('市场价 %s 元，已低于低档关注价 %s 元。', vi_fmt(latest_price), vi_fmt(v1 * (1 - margin_low)))
                             ELSE format('市场价 %s 元，已低于高档关注价 %s 元。', vi_fmt(latest_price), vi_fmt(v1 * (1 - margin_high))) END,
                        CASE WHEN cv1 IS NULL THEN '现金桥接不完整，现金支持价值不输出。'
                             WHEN cv1 < v1 THEN format('现金支持价值 %s 元低于股息贴现价值，部分年份 FCFE 不足以支付计划股息。', vi_fmt(cv1))
                             ELSE '' END) END
       || ' 研究提示，不是交易指令。' AS conclusion
FROM d;

---------------------------------------------------------------------------
-- 敏感性：基准情景股息路径不变，折现率与永续增长各偏移 -1%…+1%
---------------------------------------------------------------------------
CREATE VIEW vi_sensitivity AS
WITH base AS (
  SELECT v.model_id, v.id AS scenario_id, v.discount_rate AS r0, v.terminal_growth AS g0, v.company_id, v.company_name, v.model_name,
         m.base_year AS b, m.terminal_year AS t, m.shares, mc.years_elapsed
  FROM vi_valuation v JOIN vi_model_base m ON m.id = v.model_id JOIN vi_model_calc mc ON mc.id = m.id
  WHERE v.is_base AND v.years_complete
), grid AS (
  SELECT base.*, i, j, (i - 3) * 0.005 AS dr, (j - 3) * 0.005 AS dg
  FROM base, generate_series(1, 5) i, generate_series(1, 5) j
), val AS (
  SELECT grid.*, r0 + dr AS r, g0 + dg AS g,
         (SELECT sum(p.dividend / power(1 + r0 + dr, p.year - b)) FROM vi_projection p
           WHERE p.scenario_id = grid.scenario_id AND p.year BETWEEN b + 1 AND t) AS pv,
         (SELECT p.dividend FROM vi_projection p WHERE p.scenario_id = grid.scenario_id AND p.year = t) AS td
  FROM grid
), v AS (
  SELECT val.*, CASE WHEN r > g AND shares > 0 THEN (pv + td * (1 + g) / (r - g) / power(1 + r, t - b)) / shares END AS v0
  FROM val
)
SELECT model_id * 1000 + i * 10 + j AS id, model_id, company_id, company_name, model_name,
       format('r%s / g%s', CASE WHEN dr >= 0 THEN '+' ELSE '' END || vi_pct(dr, 1),
                           CASE WHEN dg >= 0 THEN '+' ELSE '' END || vi_pct(dg, 1)) AS label,
       dr AS r_shift, dg AS g_shift, r, g, v0 AS value_base_date, v0 * power(1 + r, years_elapsed) AS value_today
FROM v;

---------------------------------------------------------------------------
-- 单参数试验
---------------------------------------------------------------------------
CREATE VIEW vi_trial_calc AS
WITH t AS (
  SELECT tr.id, tr.model_id, coalesce(tr.start_year, 0) AS sy, coalesce(tr.end_year, 0) AS ey,
         coalesce(tr.volume_delta, 0) AS dv, coalesce(tr.price_delta, 0) AS dp, coalesce(tr.cost_delta, 0) AS dc,
         coalesce(tr.da_delta, 0) AS dd, coalesce(tr.interest_delta, 0) AS di, coalesce(tr.rate_delta, 0) AS drt,
         v.id AS scenario_id, v.discount_rate + coalesce(tr.rate_delta, 0) AS r, v.terminal_growth AS g,
         v.value_base_date AS base_value, m.base_year AS b, m.terminal_year AS tyear, m.shares
  FROM vi_trial_base tr
  JOIN vi_model_base m ON m.id = tr.model_id
  JOIN vi_valuation v ON v.model_id = tr.model_id AND v.is_base
), d AS (
  SELECT t.id, p.year,
         greatest(0, p.dividend + CASE WHEN p.year BETWEEN t.sy AND t.ey
           THEN (p.revenue * ((1 + t.dv) * (1 + t.dp) - 1) - t.dc - t.dd - t.di)
                * (1 - p.tax_rate_) * (1 - p.minority_share_) * p.payout
           ELSE 0 END) AS div
  FROM t
  JOIN LATERAL (SELECT pj.*, f.tax_rate AS tax_rate_, f.minority_share AS minority_share_
                FROM vi_projection pj JOIN vi_forecast_base f ON f.model_id = pj.model_id AND f.year = pj.year
                WHERE pj.scenario_id = t.scenario_id AND pj.year BETWEEN t.b + 1 AND t.tyear) p ON true
), s AS (
  SELECT t.*,
         (SELECT sum(d.div / power(1 + t.r, d.year - t.b)) FROM d WHERE d.id = t.id) AS pv,
         (SELECT d.div FROM d WHERE d.id = t.id AND d.year = t.tyear) AS td
  FROM t
), v AS (
  SELECT s.*, CASE WHEN r > g AND shares > 0 THEN (pv + td * (1 + g) / (r - g) / power(1 + r, tyear - b)) / shares END AS tv
  FROM s
)
SELECT id, base_value, tv AS trial_value, tv - base_value AS value_change, (tv - base_value) / NULLIF(base_value, 0) AS change_pct
FROM v;

---------------------------------------------------------------------------
-- 跟踪事项
---------------------------------------------------------------------------
CREATE VIEW vi_watch_calc AS
-- 跟踪事项：取指标最新一期（按“比较”取数值或同比），和触发上下限比；过了“下次应更新”还没新数即待更新。
-- 下次应更新＝最新观察日期＋频率对应的披露节奏（月度简报约次月下旬、季报约一个月、半年报两个月、年报四个月）。
SELECT w.id, x.state, l.v AS latest_value, l.period AS latest_period, l.obs_date AS latest_date,
       l.v - w.baseline AS vs_baseline, x.next_due
FROM vi_watch_base w
LEFT JOIN LATERAL (SELECT CASE WHEN w.compare = '同比' THEN b.yoy ELSE b.value END AS v, b.period, c.obs_date
                   FROM vi_obs_current c JOIN vi_observation_base b ON b.id = c.id
                   WHERE c.metric_id = w.metric_id AND (w.compare IS DISTINCT FROM '同比' OR b.yoy IS NOT NULL)
                   ORDER BY c.obs_date DESC LIMIT 1) l ON true
CROSS JOIN LATERAL (SELECT (l.obs_date + CASE w.frequency WHEN '交易日' THEN interval '5 days' WHEN '周' THEN interval '12 days'
                                                          WHEN '月' THEN interval '55 days' WHEN '季' THEN interval '4 months'
                                                          WHEN '半年' THEN interval '10 months' WHEN '年' THEN interval '16 months' END)::date AS due) d
CROSS JOIN LATERAL (SELECT d.due AS next_due,
                           CASE WHEN w.fetch_method = '事件阅读' THEN '事件'
                                WHEN l.v IS NULL THEN '无数据'
                                WHEN l.v < w.lower OR l.v > w.upper THEN '已触发'
                                WHEN d.due < current_date THEN '待更新'
                                ELSE '正常' END AS state) x;

---------------------------------------------------------------------------
-- 自动检查：每个“当前”模型一组
---------------------------------------------------------------------------
-- 分部加总估值：核心业务盈利 × 合理倍数 ＋ 经营分部价值 ＋ 可用净现金 ＋ 对外投资（折后）− 少数股东权益与其他
--   核心盈利（可选，估值模型填了“核心盈利年份”才用）＝(利润总额−其他净贡献＋利息)×(归母净利润÷利润总额)＋核心盈利调整：
--     不含利息收入、投资收益与财务费用
--   公式倍数＝(1−g÷新增投资回报率)÷(r−g)；情景手填的合理倍数优先
--   分部估值项、经营分部：适用情景为空＝所有情景；同编号有情景专属的一行时，以专属行为准
--   经营分部按发展阶段三种方法，价值都折回资产负债日 D：
--     盈利×倍数、稳态折现：价值＝盈利×倍数÷(1+r)^τ ＋ 期间现金流÷(1+r)^(τ/2)
--       盈利＝收入×经营利润率×(1−税率)×归母比例；τ＝盈利年份上一年 12 月 31 日距 D 的年数（不足 0 记 0）
--     承诺投入：价值＝−(剩余金额÷n)×(1−税率)×[1−(1+r)^−n]÷r − 承诺期后年成本×(1−税率)÷(r−g)÷(1+r)^n，n＝剩余年数
--     直接估值：价值＝填写的直接估值（可比公司或主观判断给出的整体价值，不折现）
---------------------------------------------------------------------------
CREATE VIEW vi_sotp_item_calc AS
SELECT i.id,
       CASE WHEN i.kind = '其他调整' THEN i.amount
            WHEN i.kind IN ('现金及等价物', '对外投资') THEN abs(i.amount)
            ELSE -abs(i.amount) END * (1 - coalesce(i.haircut, 0)) AS signed_value,
       coalesce(s.name, '全部情景') AS scope
FROM vi_sotp_item_base i LEFT JOIN vi_scenario_base s ON s.id = i.scenario_id;

-- 经营分部：情景 × 分部一行（同编号有情景专属行时以专属行为准）
CREATE VIEW vi_sotp_segment_val AS
WITH pick AS (
  SELECT DISTINCT ON (s.id, g.code)
         s.id AS scenario_id, s.model_id, s.name AS scenario_name, coalesce(s.is_base, false) AS is_base,
         g.id AS segment_id, g.code, g.name, g.method, g.earn_year, g.revenue, g.op_margin,
         coalesce(g.tax_rate, 0) AS tax_rate, coalesce(g.attrib, 1) AS attrib, g.multiple,
         coalesce(g.ronic, s.ronic) AS ronic, coalesce(g.growth, s.terminal_growth) AS growth,
         coalesce(g.discount_rate, x.eff_discount_rate) AS r, coalesce(g.interim_cash, 0) AS interim_cash,
         coalesce(g.commit_amount, 0) AS commit_amount, g.commit_years, coalesce(g.ongoing_cost, 0) AS ongoing_cost,
         g.direct_value, m.sotp_as_of AS as_of
  FROM vi_scenario_base s
  JOIN vi_scenario_calc x ON x.id = s.id
  JOIN vi_model_base m ON m.id = s.model_id
  JOIN vi_sotp_segment_base g ON g.model_id = s.model_id AND (g.scenario_id = s.id OR g.scenario_id IS NULL)
  ORDER BY s.id, g.code, (g.scenario_id IS NULL)
), a AS (
  SELECT pick.*,
         CASE WHEN method = '承诺投入' THEN -ongoing_cost * (1 - tax_rate) * attrib
              WHEN method = '直接估值' THEN NULL
              ELSE revenue * op_margin * (1 - tax_rate) * attrib END AS earnings,
         CASE WHEN method IN ('盈利×倍数', '稳态折现') AND ronic > 0 AND r > growth THEN (1 - growth / ronic) / (r - growth) END AS formula_multiple,
         CASE WHEN method = '承诺投入' THEN commit_years
              WHEN method = '直接估值' THEN 0
              ELSE greatest(0, ((make_date(earn_year - 1, 12, 31) - as_of) / 365.25)::float8) END AS tau
  FROM pick
), b AS (
  SELECT a.*, CASE WHEN method IN ('盈利×倍数', '稳态折现') THEN coalesce(multiple, formula_multiple) END AS multiple_used FROM a
), c AS (
  SELECT b.*,
         CASE WHEN method = '承诺投入' THEN
                CASE WHEN ongoing_cost = 0 THEN 0
                     WHEN r > growth AND tau IS NOT NULL THEN -ongoing_cost * (1 - tax_rate) * attrib / (r - growth) / power(1 + r, tau) END
              WHEN method = '直接估值' THEN direct_value
              ELSE earnings * multiple_used / power(1 + r, tau) END AS terminal_pv,
         CASE WHEN method = '承诺投入' THEN
                CASE WHEN commit_amount = 0 THEN 0
                     WHEN tau > 0 AND r > 0 THEN -(commit_amount / tau) * (1 - tax_rate) * attrib * (1 - power(1 + r, -tau)) / r END
              WHEN method = '直接估值' THEN 0
              ELSE interim_cash / power(1 + r, tau / 2) END AS interim_pv,
         CASE WHEN method IN ('盈利×倍数', '稳态折现') THEN earnings / power(1 + r, tau) END AS earn_pv
  FROM b
)
SELECT scenario_id * 100000 + segment_id AS id, scenario_id, model_id, scenario_name, is_base, segment_id, code, name, method,
       earn_year, revenue, op_margin, tax_rate, attrib, r, growth, ronic, earnings, formula_multiple, multiple_used, tau,
       interim_cash, commit_amount, commit_years, ongoing_cost, direct_value, terminal_pv, interim_pv, earn_pv,
       terminal_pv + interim_pv AS value
FROM c;

-- 经营分部表的计算列：适用全部情景的行按基准情景计算（基准另有专属行时按其他情景）
CREATE VIEW vi_sotp_segment_calc AS
SELECT g.id, v.scenario_name AS calc_scenario, v.earnings, v.formula_multiple, v.multiple_used, v.r AS eff_rate,
       v.tau AS years_to_value, v.terminal_pv, v.interim_pv, v.value, coalesce(s.name, '全部情景') AS scope
FROM vi_sotp_segment_base g
LEFT JOIN vi_scenario_base s ON s.id = g.scenario_id
LEFT JOIN LATERAL (SELECT * FROM vi_sotp_segment_val v WHERE v.segment_id = g.id
                   ORDER BY v.is_base DESC, v.scenario_id LIMIT 1) v ON true;

CREATE VIEW vi_sotp AS
WITH sc AS (
  SELECT s.id AS scenario_id, s.model_id, s.name AS scenario_name, coalesce(s.is_base, false) AS is_base, s.sort,
         x.eff_discount_rate AS r, s.terminal_growth AS g, s.ronic, s.sotp_multiple, s.probability,
         m.sotp_year, m.sotp_core_adj, m.sotp_as_of, m.shares, m.margin_low, m.margin_high, m.company_id,
         m.name AS model_name, co.name AS company_name, cc.latest_price, cc.latest_fx
  FROM vi_scenario_base s
  JOIN vi_scenario_calc x ON x.id = s.id
  JOIN vi_model_base m ON m.id = s.model_id
  LEFT JOIN vi_company_base co ON co.id = m.company_id
  LEFT JOIN vi_company_calc cc ON cc.id = m.company_id
  WHERE (m.sotp_year IS NOT NULL AND EXISTS (SELECT 1 FROM vi_sotp_item_base i WHERE i.model_id = m.id))
     OR EXISTS (SELECT 1 FROM vi_sotp_segment_base g WHERE g.model_id = m.id)
), core AS (
  SELECT sc.*, p.pretax - p.other_contrib + p.interest AS core_pretax,
         (p.pretax - p.other_contrib + p.interest) * p.np_parent / NULLIF(p.pretax, 0) + coalesce(sc.sotp_core_adj, 0) AS core_earnings
  FROM sc LEFT JOIN vi_projection p ON p.scenario_id = sc.scenario_id AND p.year = sc.sotp_year
), items AS (
  SELECT DISTINCT ON (c.scenario_id, i.code) c.scenario_id, i.kind, ic.signed_value
  FROM core c
  JOIN vi_sotp_item_base i ON i.model_id = c.model_id AND (i.scenario_id = c.scenario_id OR i.scenario_id IS NULL)
  JOIN vi_sotp_item_calc ic ON ic.id = i.id
  ORDER BY c.scenario_id, i.code, (i.scenario_id IS NULL)
), agg AS (
  SELECT scenario_id,
         sum(signed_value) FILTER (WHERE kind = '现金及等价物') AS cash,
         sum(signed_value) FILTER (WHERE kind = '带息负债') AS debt,
         sum(signed_value) FILTER (WHERE kind = '经营所需现金') AS op_cash,
         sum(signed_value) FILTER (WHERE kind = '资金汇出成本') AS repatriation,
         sum(signed_value) FILTER (WHERE kind = '对外投资') AS investments,
         sum(signed_value) FILTER (WHERE kind IN ('少数股东权益', '其他调整')) AS minority_other,
         sum(signed_value) AS noncore
  FROM items GROUP BY scenario_id
), segs AS (
  SELECT scenario_id, count(*) AS n_segments, count(*) FILTER (WHERE value IS NULL) AS n_incomplete,
         sum(value) AS segments_value,
         sum(value) FILTER (WHERE method = '盈利×倍数') AS mature_value,
         sum(earnings) FILTER (WHERE method = '盈利×倍数') AS mature_earnings,
         sum(earn_pv) FILTER (WHERE method = '盈利×倍数') AS mature_earn_pv,
         sum(interim_pv) FILTER (WHERE method = '盈利×倍数') AS mature_interim_pv,
         sum(value) FILTER (WHERE method = '稳态折现') AS growth_value,
         sum(value) FILTER (WHERE method = '承诺投入') AS invest_value,
         sum(value) FILTER (WHERE method = '直接估值') AS direct_value
  FROM vi_sotp_segment_val GROUP BY scenario_id
), v AS (
  SELECT core.*, a.cash, a.debt, a.op_cash, a.repatriation, a.investments, a.minority_other, coalesce(a.noncore, 0) AS noncore,
         coalesce(a.cash, 0) + coalesce(a.debt, 0) + coalesce(a.op_cash, 0) + coalesce(a.repatriation, 0) AS usable_net_cash,
         CASE WHEN core.ronic > 0 AND core.r > core.g THEN (1 - core.g / core.ronic) / (core.r - core.g) END AS formula_multiple,
         coalesce(sg.n_segments, 0) AS n_segments, coalesce(sg.n_incomplete, 0) AS n_incomplete,
         sg.segments_value, sg.mature_value, sg.mature_earnings, sg.mature_earn_pv, sg.mature_interim_pv, sg.growth_value, sg.invest_value,
         sg.direct_value
  FROM core LEFT JOIN agg a USING (scenario_id) LEFT JOIN segs sg USING (scenario_id)
), w AS (
  SELECT v.*, coalesce(v.sotp_multiple, v.formula_multiple) AS multiple FROM v
), x AS (
  SELECT w.*, w.core_earnings * w.multiple AS core_value,
         CASE WHEN w.n_incomplete = 0 AND (w.sotp_year IS NULL OR w.core_earnings * w.multiple IS NOT NULL)
              THEN coalesce(w.core_earnings * w.multiple, 0) + coalesce(w.segments_value, 0) + w.noncore END AS equity_value
  FROM w
), y AS (
  SELECT x.*, x.equity_value / NULLIF(x.shares, 0) AS vps, x.latest_price * x.shares AS mcap FROM x
), z AS (
  SELECT y.*,
         CASE WHEN count(*) OVER pm = count(y.probability) OVER pm AND count(*) OVER pm = count(y.vps) OVER pm
              THEN sum(y.probability * y.vps) OVER pm / NULLIF(sum(y.probability) OVER pm, 0) END AS weighted_value,
         CASE WHEN y.mature_earn_pv > 0 THEN (y.mcap - y.noncore - coalesce(y.core_value, 0) - coalesce(y.growth_value, 0)
                                              - coalesce(y.invest_value, 0) - coalesce(y.direct_value, 0) - y.mature_interim_pv) / y.mature_earn_pv END AS implied_mature_multiple,
         CASE WHEN y.growth_value IS NOT NULL THEN y.mcap - y.noncore - coalesce(y.core_value, 0) - coalesce(y.mature_value, 0)
                                                   - coalesce(y.invest_value, 0) - coalesce(y.direct_value, 0) END AS implied_growth_value,
         (y.mature_value - y.mature_interim_pv) / NULLIF(y.mature_earn_pv, 0) AS mature_multiple
  FROM y WINDOW pm AS (PARTITION BY y.model_id)
)
SELECT z.scenario_id AS id, z.model_id, z.company_id, z.company_name, z.model_name, z.scenario_name, z.is_base, z.sort,
       z.sotp_year AS core_year, z.sotp_as_of AS as_of, z.core_pretax, z.core_earnings,
       z.r AS discount_rate, z.g AS terminal_growth, z.ronic, z.formula_multiple, z.multiple, z.core_value,
       z.segments_value, z.mature_value, z.mature_earnings, z.mature_multiple, z.growth_value, z.invest_value, z.direct_value,
       z.mature_earn_pv, z.mature_interim_pv,
       z.cash, z.debt, z.op_cash, z.repatriation, z.usable_net_cash, z.investments, z.minority_other, z.noncore,
       z.equity_value, z.shares, z.vps AS value_per_share, z.vps / NULLIF(z.latest_fx, 0) AS value_per_share_quote,
       z.latest_price AS market_price, z.latest_price / NULLIF(z.vps, 0) - 1 AS price_vs_value,
       (z.mcap - z.noncore - coalesce(z.segments_value, 0)) / NULLIF(z.core_earnings, 0) AS implied_core_multiple,
       z.implied_mature_multiple, z.implied_growth_value, z.probability, z.weighted_value,
       dv.value_today AS ddm_value, z.vps / NULLIF(dv.value_today, 0) - 1 AS diff_vs_ddm,
       z.vps * (1 - z.margin_low) AS watch_low, z.vps * (1 - z.margin_high) AS watch_high,
       CASE WHEN z.sotp_year IS NOT NULL AND z.core_earnings IS NULL THEN format('预测计算里没有 %s 年的数据，核心盈利无法计算', z.sotp_year)
            WHEN z.sotp_year IS NOT NULL AND z.multiple IS NULL THEN '没有合理倍数：在情景里填“合理倍数”或“新增投资回报率”'
            WHEN z.n_incomplete > 0 THEN format('经营分部有 %s 项输入不完整，无法计算（见「估值 / 经营分部估值」）', z.n_incomplete)
            WHEN z.n_segments = 0 THEN
              format('核心盈利 %s 亿元（%s 年）× 合理倍数 %s 倍 ＝ %s 亿元；可用净现金 %s 亿元；对外投资（折后）%s 亿元；少数股东权益与其他 %s 亿元；'
                     '股权价值 %s 亿元，每股 %s 元%s。市场价 %s 元，%s；市场给核心业务的隐含倍数 %s 倍。股息贴现口径 %s 元。',
                     vi_fmt(z.core_earnings, 1), z.sotp_year, vi_fmt(z.multiple, 1), vi_fmt(z.core_value, 0),
                     vi_fmt(z.usable_net_cash, 0), vi_fmt(z.investments, 0), vi_fmt(z.minority_other, 0),
                     vi_fmt(z.equity_value, 0), vi_fmt(z.vps),
                     CASE WHEN z.latest_fx IS NOT NULL THEN format('（约合股价币种 %s）', vi_fmt(z.vps / z.latest_fx)) ELSE '' END,
                     vi_fmt(z.latest_price),
                     CASE WHEN z.latest_price IS NULL THEN '暂无市场价'
                          WHEN z.latest_price > z.vps THEN format('高于每股价值 %s', vi_pct(z.latest_price / z.vps - 1))
                          ELSE format('低于每股价值 %s', vi_pct(1 - z.latest_price / z.vps)) END,
                     vi_fmt((z.mcap - z.noncore) / NULLIF(z.core_earnings, 0), 1),
                     vi_fmt(dv.value_today))
            ELSE
              format('%s经营分部合计 %s 亿元（成熟业务 %s、成长业务 %s、投入期业务 %s、直接估值业务 %s）；可用净现金 %s 亿元；对外投资（折后）%s 亿元；'
                     '少数股东权益与其他 %s 亿元；股权价值 %s 亿元，每股 %s 元%s。市场价 %s 元，%s。%s%s%s股息贴现口径 %s 元。',
                     CASE WHEN z.core_earnings IS NOT NULL THEN format('核心盈利 %s 亿元（%s 年）× %s 倍 ＝ %s 亿元；',
                          vi_fmt(z.core_earnings, 1), z.sotp_year, vi_fmt(z.multiple, 1), vi_fmt(z.core_value, 0)) ELSE '' END,
                     vi_fmt(z.segments_value, 0), vi_fmt(coalesce(z.mature_value, 0), 0), vi_fmt(coalesce(z.growth_value, 0), 0),
                     vi_fmt(coalesce(z.invest_value, 0), 0), vi_fmt(coalesce(z.direct_value, 0), 0), vi_fmt(z.usable_net_cash, 0), vi_fmt(z.investments, 0), vi_fmt(z.minority_other, 0),
                     vi_fmt(z.equity_value, 0), vi_fmt(z.vps),
                     CASE WHEN z.latest_fx IS NOT NULL THEN format('（约合股价币种 %s）', vi_fmt(z.vps / z.latest_fx)) ELSE '' END,
                     vi_fmt(z.latest_price),
                     CASE WHEN z.latest_price IS NULL THEN '暂无市场价'
                          WHEN z.latest_price > z.vps THEN format('高于每股价值 %s', vi_pct(z.latest_price / z.vps - 1))
                          ELSE format('低于每股价值 %s', vi_pct(1 - z.latest_price / z.vps)) END,
                     CASE WHEN z.implied_mature_multiple IS NOT NULL THEN format('其余部分按本模型取值时，市值对应成熟业务约 %s 倍正常化盈利（本模型 %s 倍）；',
                          vi_fmt(z.implied_mature_multiple, 1), vi_fmt(z.mature_multiple, 1)) ELSE '' END,
                     CASE WHEN z.implied_growth_value IS NOT NULL THEN format('或者说，市场为成长业务付了约 %s 亿元（本模型 %s 亿元）。',
                          vi_fmt(z.implied_growth_value, 0), vi_fmt(z.growth_value, 0)) ELSE '' END,
                     CASE WHEN z.weighted_value IS NOT NULL THEN format('按情景概率加权，每股 %s 元。', vi_fmt(z.weighted_value)) ELSE '' END,
                     vi_fmt(dv.value_today)) END
       || ' 研究提示，不是交易指令。' AS conclusion
FROM z LEFT JOIN vi_valuation dv ON dv.id = z.scenario_id;

---------------------------------------------------------------------------
CREATE VIEW vi_check AS
WITH m AS (
  SELECT m.id, m.name AS model_name, m.company_id, co.name AS company_name, m.base_year AS b, m.terminal_year AS t,
         m.rf, mc.latest_rf, mc.latest_rf_date, mc.years_elapsed, cc.latest_price_date
  FROM vi_model_base m
  JOIN vi_model_calc mc ON mc.id = m.id
  LEFT JOIN vi_company_base co ON co.id = m.company_id
  LEFT JOIN vi_company_calc cc ON cc.id = m.company_id
  WHERE m.status = '当前'
), vb AS (
  SELECT * FROM vi_valuation WHERE is_base
), sb AS (
  SELECT * FROM vi_sotp WHERE is_base
), c AS (
  SELECT m.*,
    (SELECT count(*) FROM vi_forecast_base f WHERE f.model_id = m.id AND f.year BETWEEN m.b + 1 AND m.t) AS n_fc,
    (SELECT count(*) FROM vi_forecast_base f JOIN vi_forecast_calc fc USING (id) WHERE f.model_id = m.id AND fc.cash_complete) AS n_cash,
    (SELECT count(*) FROM vi_forecast_base f WHERE f.model_id = m.id AND f.cash_status = '建议值待核验') AS n_cash_proposed,
    (SELECT count(*) FROM vi_forecast_base f WHERE f.model_id = m.id AND coalesce(f.operating_status, '') <> '已核验') AS n_op_unverified,
    (SELECT string_agg(s.name, '、') FROM vi_scenario_base s JOIN vi_scenario_calc sc USING (id)
      WHERE s.model_id = m.id AND sc.eff_discount_rate <= s.terminal_growth) AS bad_rg,
    (SELECT min(fc.debt_close) FROM vi_forecast_base f JOIN vi_forecast_calc fc USING (id) WHERE f.model_id = m.id) AS min_debt,
    (SELECT format('%s→%s', vi_pct(min(f.cost_of_debt) FILTER (WHERE f.year = m.b + 1), 2),
                            vi_pct(min(f.cost_of_debt) FILTER (WHERE f.year = m.t), 2))
       FROM vi_forecast_base f WHERE f.model_id = m.id) AS cod_path,
    (SELECT format('%s→%s 亿元', vi_fmt(min(fc.debt_open) FILTER (WHERE f.year = m.b + 1), 0),
                                 vi_fmt(min(fc.debt_close) FILTER (WHERE f.year = m.t), 0))
       FROM vi_forecast_base f JOIN vi_forecast_calc fc USING (id) WHERE f.model_id = m.id) AS debt_path,
    vb.terminal_share AS tv_share,
    (SELECT count(*) FROM vi_collector_base k JOIN vi_collector_calc kc USING (id) WHERE kc.needs_alert) AS n_alert,
    (SELECT count(*) FROM vi_observation_base o JOIN vi_observation_calc oc USING (id)
       JOIN vi_metric_base mt ON mt.id = o.metric_id WHERE NOT oc.is_valid AND (mt.company_id = m.company_id OR mt.company_id IS NULL)) AS n_invalid,
    (SELECT count(*) FROM vi_thesis_base th JOIN vi_thesis_calc tc USING (id) WHERE th.company_id = m.company_id AND tc.check_result LIKE '已触发%') AS n_falsified,
    (SELECT count(*) FROM vi_thesis_base th JOIN vi_thesis_calc tc USING (id) WHERE th.company_id = m.company_id AND tc.check_result NOT IN ('未设置')) AS n_checked,
    vb.implied_irr AS base_irr, vb.cash_implied_irr AS base_cash_irr, vb.value_at_required AS base_v_req,
    (SELECT mb.required_return FROM vi_model_base mb WHERE mb.id = m.id) AS req,
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
        AND NOT EXISTS (SELECT 1 FROM vi_lnk_risk_watches l WHERE l.risk_id = r.id)) AS risk_no_signal,
    (SELECT string_agg(r.code, '、' ORDER BY r.code) FROM vi_risk_base r
      WHERE r.company_id = m.company_id AND (r.probability IS NULL OR r.impact IS NULL OR r.treatment IS NULL)) AS risk_incomplete,
    sb.value_per_share AS sotp_base, sb.diff_vs_ddm AS sotp_diff, sb.implied_core_multiple AS sotp_implied, sb.multiple AS sotp_multiple,
    vb.value_today AS ddm_base,
    (SELECT count(*) FROM vi_sotp_segment_base g WHERE g.model_id = m.id) AS n_seg,
    sb.mature_value AS seg_mature, sb.growth_value AS seg_growth, sb.invest_value AS seg_invest, sb.direct_value AS seg_direct, sb.noncore AS seg_noncore,
    sb.equity_value AS seg_equity, sb.implied_growth_value AS seg_implied_growth, sb.weighted_value AS seg_weighted,
    sb.mature_multiple AS seg_mature_mult, sb.implied_mature_multiple AS seg_implied_mature,
    (SELECT sum(s.probability) FROM vi_scenario_base s WHERE s.model_id = m.id) AS prob_sum,
    (SELECT count(s.probability) FROM vi_scenario_base s WHERE s.model_id = m.id) AS prob_n
  FROM m
  LEFT JOIN vb ON vb.model_id = m.id
  LEFT JOIN sb ON sb.model_id = m.id
)
SELECT id * 100 + k AS id, id AS model_id, company_id, company_name, model_name, code, name, result, detail
FROM c CROSS JOIN LATERAL (VALUES
  (1, 'C01', '预测年份完整',
      CASE WHEN n_fc = t - b THEN '通过' ELSE '阻断' END,
      format('需要 %s—%s 年共 %s 年逐年假设，现有 %s 年', b + 1, t, t - b, n_fc)),
  (2, 'C02', '折现率大于永续增长率',
      CASE WHEN bad_rg IS NULL THEN '通过' ELSE '阻断' END,
      coalesce('以下情景 r≤g：' || bad_rg, '所有情景 r>g')),
  (3, 'C03', '现金桥接',
      CASE WHEN n_cash = t - b AND n_cash_proposed = 0 THEN '通过' WHEN n_cash = t - b THEN '提示' ELSE '阻断' END,
      format('完整 %s / %s 年；其中 %s 年为建议值待核验', n_cash, t - b, n_cash_proposed)),
  (4, 'C04', '债务滚动',
      CASE WHEN min_debt IS NULL THEN '阻断' WHEN min_debt < 0 THEN '阻断' ELSE '通过' END,
      format('带息负债 %s；隐含平均债务成本 %s', debt_path, cod_path)),
  (5, 'C05', '估值日与基准日',
      CASE WHEN years_elapsed > 1.5 THEN '阻断' WHEN years_elapsed > 0.25 THEN '提示' ELSE '通过' END,
      format('距基准日 %s 年。已按折现率把价值滚动到今天；若基准年之后的股息已在今天之前派发，需要从今天价值中扣除。基准日超过 1.5 年应更新模型。', round(years_elapsed::numeric, 2))),
  (6, 'C06', '股价数据新鲜',
      CASE WHEN latest_price_date IS NULL THEN '阻断' WHEN vi_today() - latest_price_date > 7 THEN '提示' ELSE '通过' END,
      format('最新股价日期 %s', coalesce(latest_price_date::text, '无'))),
  (7, 'C07', '无风险利率参数与最新观察',
      CASE WHEN latest_rf IS NULL THEN '提示' WHEN abs(latest_rf / 100 - rf) >= 0.005 THEN '提示' ELSE '通过' END,
      format('模型采用 %s；最新观察 %s（%s），相差 %s bp。长期参数不随单日数据自动修改。',
             vi_pct(rf, 2), CASE WHEN latest_rf IS NULL THEN '—' ELSE latest_rf::text || '%' END,
             coalesce(latest_rf_date::text, '—'),
             CASE WHEN latest_rf IS NULL THEN '—' ELSE round(((latest_rf / 100 - rf) * 10000)::numeric)::text END)),
  (8, 'C08', '终值依赖度',
      CASE WHEN tv_share > 0.7 THEN '提示' ELSE '通过' END,
      format('基准情景终值占比 %s（超过 70%% 时价值主要取决于远期假设）', vi_pct(tv_share))),
  (9, 'C09', '论点证伪',
      CASE WHEN n_falsified > 0 THEN '阻断' ELSE '通过' END,
      format('%s 条论点设置了自动检查，%s 条已触发', n_checked, n_falsified)),
  (10, 'C10', '经营假设核验',
      CASE WHEN n_op_unverified > 0 THEN '提示' ELSE '通过' END,
      format('%s 个年度的经营假设尚未标记为“已核验”', n_op_unverified)),
  (11, 'C11', '自动采集健康',
      CASE WHEN n_alert > 0 THEN '提示' ELSE '通过' END,
      format('%s 个启用的采集源需要处理', n_alert)),
  (12, 'C12', '无效高频数据',
      CASE WHEN n_invalid > 0 THEN '提示' ELSE '通过' END,
      format('%s 条观察超出指标合理范围（已排除在计算之外，原值保留）', n_invalid)),
  (13, 'C13', '隐含收益率与要求收益率',
      CASE WHEN base_irr IS NULL OR req IS NULL THEN '提示' WHEN base_irr >= req THEN '通过' ELSE '提示' END,
      format('按最新市场价买入，基准情景隐含年化收益率 %s（现金支持口径 %s），要求收益率 %s；要求收益率下的最高买入价 %s 元。',
             vi_pct(base_irr, 2), vi_pct(base_cash_irr, 2), vi_pct(req, 1), vi_fmt(base_v_req))),
  (14, 'C14', '竞争壁垒与辩论',
      CASE WHEN n_moat = 0 OR n_moat_undebated > 0 OR n_moat_broken > 0 THEN '提示' ELSE '通过' END,
      CASE WHEN n_moat = 0 THEN '还没有识别竞争壁垒（商业模式分析 / 竞争壁垒）'
           ELSE format('%s 项候选壁垒（%s）；伪壁垒以外还有 %s 项没有关联辩论过的论点（核心论点里填辩论日期并关联壁垒）；壁垒自动检查已触发 %s 项',
                       n_moat, moat_mix, n_moat_undebated, n_moat_broken) END),
  (15, 'C15', '价值投资适配度',
      CASE WHEN n_fit < 8 OR fit_total < 22 THEN '提示' ELSE '通过' END,
      format('已评 %s / 8 个维度，总分 %s / 40：%s', n_fit, coalesce(fit_total, 0),
             CASE WHEN n_fit < 8 THEN '评分未完成'
                  WHEN fit_total >= 32 THEN '适合价值投资复利框架（仍需价格安全边际）'
                  WHEN fit_total >= 22 THEN '可研究，需说明更偏复利、现金流价值还是资产价值'
                  ELSE '通常不符合价值投资标准' END)),
  (16, 'C16', '分部加总与股息贴现对照',
      CASE WHEN sotp_base IS NULL THEN '通过' WHEN abs(sotp_diff) > 0.25 THEN '提示' ELSE '通过' END,
      CASE WHEN sotp_base IS NULL THEN '未设置分部加总，只用股息贴现'
           WHEN sotp_implied IS NULL AND seg_mature_mult IS NOT NULL THEN
             format('基准情景：分部加总 %s 元，股息贴现 %s 元，相差 %s（超过 25%% 时要说明差异来源，常见是股息贴现没有计入留存的现金与对外投资）；成熟业务倍数 %s 倍，市场隐含成熟业务倍数 %s 倍',
                    vi_fmt(sotp_base), vi_fmt(ddm_base), vi_pct(sotp_diff), vi_fmt(seg_mature_mult, 1), vi_fmt(seg_implied_mature, 1))
           ELSE format('基准情景：分部加总 %s 元，股息贴现 %s 元，相差 %s（超过 25%% 时要说明差异来源，常见是股息贴现没有计入留存的现金与对外投资）；合理倍数 %s 倍，市场隐含核心倍数 %s 倍',
                       vi_fmt(sotp_base), vi_fmt(ddm_base), vi_pct(sotp_diff), vi_fmt(sotp_multiple, 1), vi_fmt(sotp_implied, 1)) END),
  (17, 'C17', '经营分部估值',
      CASE WHEN n_seg = 0 THEN '通过'
           WHEN sotp_base IS NULL THEN '阻断'
           WHEN (prob_n > 0 AND abs(prob_sum - 1) > 0.005) OR seg_growth / NULLIF(seg_equity, 0) > 0.4 THEN '提示'
           ELSE '通过' END,
      CASE WHEN n_seg = 0 THEN '未使用经营分部估值'
           WHEN sotp_base IS NULL THEN '经营分部或分部估值项输入不完整，基准情景算不出每股价值（见「估值 / 经营分部估值」）'
           ELSE format('基准情景：成熟业务 %s 亿元、成长业务 %s 亿元、投入期业务 %s 亿元、直接估值业务 %s 亿元、非经营部分 %s 亿元；成长业务占股权价值 %s（超过 40%% 时提示：价值主要取决于尚未成熟的业务）。'
                       '市场隐含成长业务价值 %s 亿元。情景概率合计 %s（应为 100%%），概率加权每股 %s 元。',
                       vi_fmt(seg_mature, 0), vi_fmt(seg_growth, 0), vi_fmt(seg_invest, 0), vi_fmt(seg_direct, 0), vi_fmt(seg_noncore, 0),
                       vi_pct(seg_growth / NULLIF(seg_equity, 0)), vi_fmt(seg_implied_growth, 0),
                       CASE WHEN prob_n = 0 THEN '未填' ELSE vi_pct(prob_sum) END, vi_fmt(seg_weighted)) END),
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
                        THEN '；重大风险都已计入估值，重大、重要风险都有预警信号' ELSE '' END END)
) AS x(k, code, name, result, detail);

COMMIT;
