-- 飞书公式的 SQL 等价实现。每个 cj_<code>_calc 视图输出 id + 计算列，由 04_ui.sql 拼进界面视图。
-- 语义约定：飞书返回 "" 的分支在这里返回 NULL；飞书 ROUND 为四舍五入（远离零），用 numeric round 实现。
BEGIN;

-- 多层视图的计划很大，JIT 编译会让单次查询从毫秒级变成数十秒；对本库关闭（也在 ALTER DATABASE 中设置）
DROP VIEW IF EXISTS
  cj_v1_sens_calc, cj_v1_scenario_calc, cj_v1_valuation_calc, cj_v1_forecast_calc, cj_v1_annual_calc,
  cj_collect_ctl_calc, cj_quality_calc, cj_tracking_calc, cj_param_trial_calc, cj_sens_rg_calc,
  cj_valuation_calc, cj_fin_calc_calc, cj_annual_calc, cj_scenario_calc, cj_collect_raw_calc,
  cj_market_obs_calc, cj_collect_raw_parse CASCADE;

-- 飞书 VALUE()：可解析为数字则返回数字，否则 NULL（对应 IFERROR）
CREATE OR REPLACE FUNCTION cj_num(t text) RETURNS double precision LANGUAGE sql IMMUTABLE AS $$
  SELECT CASE WHEN t ~ '^\s*[-+]?([0-9]+\.?[0-9]*|\.[0-9]+)([eE][-+]?[0-9]+)?\s*$' THEN t::double precision END
$$;

-- 飞书 ROUND(x, n)
CREATE OR REPLACE FUNCTION cj_round(x double precision, n int) RETURNS double precision LANGUAGE sql IMMUTABLE AS $$
  SELECT round(x::numeric, n)::double precision
$$;

-- 数字转文本，与飞书数字转文本一致（最短表示，去掉尾随 0）
CREATE OR REPLACE FUNCTION cj_numtext(x double precision) RETURNS text LANGUAGE sql IMMUTABLE AS $$
  SELECT x::text
$$;

---------------------------------------------------------------------------
-- 4.2 采集原始记录：解析层（只依赖本表）
---------------------------------------------------------------------------
CREATE VIEW cj_collect_raw_parse AS
WITH r AS (
  SELECT b.*,
         replace(b.raw_response, E'\\', '') AS unesc,
         string_to_array(b.raw_response, '~') AS parts
  FROM cj_collect_raw_base b
), p AS (
  SELECT r.*,
         CASE WHEN metric_code = 'TENCENT-600900' THEN left(parts[31], 8) END AS date_candidate,
         -- 旧 V1 路径：腾讯取第 4 段；中债在飞书里恒为 0（V1 国债行正则未命中，VALUE("")=0）；三峡为空
         CASE metric_code WHEN 'TENCENT-600900' THEN cj_num(parts[4]) WHEN 'CHINABOND-CGB10Y' THEN 0 END AS value_candidate,
         (regexp_match(unesc, '([{][^{}]*60106980[^{}]*[}])'))[1] AS sx_obj,
         (regexp_match(unesc, '中债国债收益率曲线</td>(.*?)</tr>'))[1] AS cgb_data_row
  FROM r
), d AS (
  SELECT p.*,
         CASE WHEN metric_code = 'TENCENT-600900' AND date_candidate IS NOT NULL
              THEN left(date_candidate, 4) || '-' || substr(date_candidate, 5, 2) || '-' || right(date_candidate, 2)
         END AS obs_date_v1
  FROM p
), v AS (
  SELECT d.*,
         CASE metric_code
           WHEN 'TENCENT-600900' THEN obs_date_v1
           WHEN 'CHINABOND-CGB10Y' THEN (regexp_match(unesc, '<th>([0-9-]+)'))[1]
           WHEN 'CJH-SX-LEVEL' THEN to_char(to_timestamp(cj_num((regexp_match(sx_obj, '"tm":([0-9]+)'))[1]) / 1000)
                                             AT TIME ZONE 'Asia/Shanghai', 'YYYY-MM-DD')
         END AS date_v2,
         CASE metric_code
           WHEN 'TENCENT-600900' THEN value_candidate
           WHEN 'CHINABOND-CGB10Y' THEN cj_num((ARRAY(
               SELECT (regexp_matches(regexp_replace(cgb_data_row, '<!--.*?-->', '', 'g'),
                                      '<td[^>]*>([0-9.]+)</td>', 'g'))[1]))[7])
           WHEN 'CJH-SX-LEVEL' THEN cj_num((regexp_match(sx_obj, '"z":"([0-9.]+)"'))[1])
         END AS value_num
  FROM d
)
SELECT v.id,
       COALESCE(v.feishu_id, 'nb' || v.id) AS raw_id,
       to_char(date_trunc('second', v.collected_at + interval '0.5 second') AT TIME ZONE 'Asia/Shanghai',
               'YYYY-MM-DD HH24:MI:SS') AS collected_at_text,
       v.date_v2,
       cj_numtext(v.value_num) AS value_v2,
       v.metric_code || '|' || COALESCE(v.date_v2, '') || '|' || COALESCE(cj_numtext(v.value_num), '') AS obs_key_v2,
       CASE WHEN v.date_v2 ~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
             AND ((v.collected_at AT TIME ZONE 'Asia/Shanghai')::date - v.date_v2::date) BETWEEN 0 AND 7
             AND v.value_num IS NOT NULL
             AND CASE v.metric_code
                   WHEN 'TENCENT-600900' THEN v.parts[3] = '600900' AND v.value_num > 0 AND v.value_num < 1000
                   WHEN 'CHINABOND-CGB10Y' THEN v.value_num >= 0 AND v.value_num < 20 AND strpos(v.unesc, '10<!-- 年 -->年') > 0
                   WHEN 'CJH-SX-LEVEL' THEN v.value_num > 100 AND v.value_num < 200
                   ELSE FALSE
                 END
            THEN 1 ELSE 0 END AS valid_v2,
       v.unesc AS response_unescaped,
       v.cgb_data_row,
       v.sx_obj,
       v.date_candidate,
       v.obs_date_v1,
       v.value_candidate,
       v.metric_code,
       v.collected_at,
       v.process_status
FROM v;

---------------------------------------------------------------------------
-- 3.2 市场数据
---------------------------------------------------------------------------
CREATE VIEW cj_market_obs_calc AS
WITH rk AS (  -- 原始采集按观察键计数（只解析一次）
  SELECT obs_key_v2, count(*) AS n FROM cj_collect_raw_parse GROUP BY obs_key_v2
), m AS (
  SELECT b.*,
         COALESCE(b.value, cj_num(b.cloud_value_text)) AS uv,
         (SELECT m2.obs_id FROM cj_market_obs_base m2
           WHERE m2.metric_code = b.metric_code AND m2.obs_date = b.obs_date
           ORDER BY m2.collected_at COLLATE "C" DESC, m2.id LIMIT 1) IS NOT DISTINCT FROM b.obs_id AS cur,
         COALESCE(rk.n, 0) AS rn
  FROM cj_market_obs_base b LEFT JOIN rk ON rk.obs_key_v2 = b.obs_id
)
SELECT id,
       uv AS unified_value,
       CASE WHEN uv >= 0 THEN 1 ELSE 0 END AS quality_ok,
       cur AS is_current,
       CASE WHEN cur THEN 1 ELSE 0 END AS current_valid_count,
       rn AS raw_count,
       CASE WHEN metric_code IN ('TENCENT-600900', 'CHINABOND-CGB10Y', 'CJH-SX-LEVEL')
            THEN CASE WHEN rn > 0 THEN '已匹配原始采集' ELSE '缺少原始采集' END
            ELSE 'Wind备份；核对原始文件' END AS source_check
FROM m;

-- 市场数据带计算列的完整行（供其他计算引用）
CREATE VIEW cj_market_obs_full AS
SELECT b.*, c.unified_value, c.quality_ok, c.is_current
FROM cj_market_obs_base b JOIN cj_market_obs_calc c USING (id);

---------------------------------------------------------------------------
-- 4.2 采集原始记录：入库判断层
---------------------------------------------------------------------------
CREATE VIEW cj_collect_raw_calc AS
WITH x AS (
  SELECT p.*,
         (SELECT count(*) FROM cj_market_obs_base m WHERE m.obs_id = p.obs_key_v2) AS existing_obs_count,
         first_value(p.raw_id) OVER (PARTITION BY p.obs_key_v2 ORDER BY p.collected_at, p.id) AS first_raw_id
  FROM cj_collect_raw_parse p
)
SELECT id, raw_id, collected_at_text, date_v2, value_v2, obs_key_v2, valid_v2, existing_obs_count,
       CASE WHEN valid_v2 = 1 AND existing_obs_count = 0 AND first_raw_id = raw_id THEN 1 ELSE 0 END AS allow_ingest,
       CASE WHEN valid_v2 = 1 AND existing_obs_count = 0 AND first_raw_id = raw_id THEN '待入库' ELSE '跳过' END AS ingest_cmd,
       CASE WHEN existing_obs_count > 0 THEN '完成（已入库或去重）'
            WHEN process_status = '采集中' THEN '未完成：检查工作流HTTP运行日志'
            WHEN valid_v2 = 1 THEN '校验通过待入库'
            ELSE '部分完成：解析或日期数值校验失败' END AS run_result,
       response_unescaped, cgb_data_row, sx_obj, date_candidate, obs_date_v1, value_candidate
FROM x;

---------------------------------------------------------------------------
-- 2.1 情景参数
---------------------------------------------------------------------------
CREATE VIEW cj_scenario_calc AS
WITH r AS (
  SELECT s.*,
         CASE WHEN s.base_rf_pct IS NOT NULL AND s.base_erp_pct IS NOT NULL
              THEN cj_round(s.base_rf_pct + s.base_erp_pct, 1) / 100 END AS calc_rate
  FROM cj_scenario_base s
), base AS (
  SELECT * FROM r WHERE scenario = '基准' ORDER BY id LIMIT 1
), px AS (
  SELECT unified_value, obs_date FROM cj_market_obs_full
  WHERE metric_code = 'TENCENT-600900' AND is_current AND quality_ok = 1
  ORDER BY obs_date COLLATE "C" DESC, id LIMIT 1
)
SELECT r.id,
       r.calc_rate AS calc_base_discount_rate,
       COALESCE(r.discount_rate, (SELECT calc_rate FROM base)) AS eff_discount_rate,
       COALESCE(r.terminal_year, (SELECT terminal_year FROM base)) AS eff_terminal_year,
       COALESCE(r.valuation_base_year, (SELECT valuation_base_year FROM base)) AS eff_base_year,
       COALESCE(r.shares_yi, (SELECT shares_yi FROM base)) AS eff_shares_yi,
       COALESCE(r.legacy_price, (SELECT legacy_price FROM base)) AS eff_legacy_price,
       (SELECT unified_value FROM px) AS latest_price,
       (SELECT obs_date FROM px) AS latest_price_date
FROM r;

CREATE VIEW cj_scenario_full AS
SELECT b.*, c.calc_base_discount_rate, c.eff_discount_rate, c.eff_terminal_year, c.eff_base_year,
       c.eff_shares_yi, c.eff_legacy_price, c.latest_price, c.latest_price_date
FROM cj_scenario_base b JOIN cj_scenario_calc c USING (id);

---------------------------------------------------------------------------
-- 2.2 年度假设
---------------------------------------------------------------------------
CREATE VIEW cj_annual_calc AS
WITH base AS (SELECT * FROM cj_scenario_base WHERE scenario = '基准' ORDER BY id LIMIT 1)
SELECT a.id,
       COALESCE(a.price, (SELECT base_price FROM base)) AS eff_price,
       COALESCE(a.other_contrib, (SELECT base_other_contrib FROM base)) AS eff_other_contrib,
       COALESCE(a.burden_rate, (SELECT base_burden_rate FROM base)) AS eff_burden_rate,
       COALESCE(a.payout, (SELECT base_payout FROM base)) AS eff_payout,
       CASE WHEN a.attrib_da_addback IS NOT NULL AND a.noncash_gain_deduct IS NOT NULL
             AND a.invest_cash_dividend IS NOT NULL AND a.other_cash_adj IS NOT NULL
             AND a.wc_increase IS NOT NULL AND a.maint_capex IS NOT NULL AND a.growth_capex IS NOT NULL
             AND a.net_borrowing IS NOT NULL AND a.min_cash_topup IS NOT NULL
            THEN '现金项已填；仍待证据核验' ELSE '现金桥接缺项' END AS cash_bridge_live_status
FROM cj_annual_base a;

CREATE VIEW cj_annual_full AS
SELECT b.*, c.eff_price, c.eff_other_contrib, c.eff_burden_rate, c.eff_payout
FROM cj_annual_base b JOIN cj_annual_calc c USING (id);

---------------------------------------------------------------------------
-- 2.3 财务计算
---------------------------------------------------------------------------
CREATE VIEW cj_fin_calc_calc AS
WITH j AS (
  SELECT f.id, f.year,
         a.volume, s.volume_factor, a.eff_price AS price, s.price_factor,
         a.cash_cost, s.cash_cost_factor, a.depreciation, a.interest, a.eff_other_contrib AS other_contrib,
         a.eff_burden_rate AS burden_rate, a.eff_payout AS payout,
         s.eff_discount_rate AS discount_rate, s.eff_base_year AS base_year, s.eff_terminal_year AS terminal_year,
         s.terminal_growth, s.eff_shares_yi AS shares_yi,
         a.attrib_da_addback, a.noncash_gain_deduct, a.invest_cash_dividend, a.other_cash_adj,
         a.wc_increase, a.maint_capex, a.growth_capex, a.net_borrowing, a.min_cash_topup
  FROM cj_fin_calc_base f
  LEFT JOIN cj_annual_full a ON a.id = f.annual_input_id
  LEFT JOIN cj_scenario_full s ON s.id = f.scenario_input_id
), k AS (
  SELECT j.*,
         volume * volume_factor * price * price_factor AS revenue,
         (attrib_da_addback IS NOT NULL AND noncash_gain_deduct IS NOT NULL AND invest_cash_dividend IS NOT NULL
          AND other_cash_adj IS NOT NULL AND wc_increase IS NOT NULL AND maint_capex IS NOT NULL
          AND growth_capex IS NOT NULL AND net_borrowing IS NOT NULL AND min_cash_topup IS NOT NULL) AS cash_data_complete,
         1 / power(1 + discount_rate, year - base_year) AS discount_factor
  FROM j
), l AS (
  SELECT k.*, revenue - cash_cost * cash_cost_factor - depreciation - interest + other_contrib AS pretax_profit
  FROM k
), m AS (
  SELECT l.*, pretax_profit * (1 - burden_rate) AS np_proxy FROM l
), n AS (
  SELECT m.*,
         GREATEST(0, np_proxy * payout) AS planned_div,
         CASE WHEN cash_data_complete THEN np_proxy + attrib_da_addback - noncash_gain_deduct + invest_cash_dividend
                                           + other_cash_adj - wc_increase - maint_capex END AS owner_earnings
  FROM m
), o AS (
  SELECT n.*, CASE WHEN cash_data_complete THEN owner_earnings - growth_capex + net_borrowing END AS fcfe FROM n
)
SELECT id, volume, volume_factor, price, price_factor, revenue, cash_cost, cash_cost_factor, depreciation, interest,
       other_contrib, pretax_profit, burden_rate, np_proxy, payout, planned_div, discount_rate, base_year,
       discount_factor, planned_div * discount_factor AS planned_div_pv, terminal_year, terminal_growth, shares_yi,
       attrib_da_addback, noncash_gain_deduct, invest_cash_dividend, other_cash_adj, wc_increase, maint_capex,
       growth_capex, net_borrowing, min_cash_topup, cash_data_complete, owner_earnings, fcfe,
       CASE WHEN cash_data_complete THEN fcfe * discount_factor END AS fcfe_pv,
       CASE WHEN cash_data_complete THEN LEAST(planned_div, GREATEST(0, fcfe - min_cash_topup)) END AS cash_supported_div,
       CASE WHEN cash_data_complete THEN LEAST(planned_div, GREATEST(0, fcfe - min_cash_topup)) * discount_factor END AS cash_div_pv,
       CASE WHEN cash_data_complete THEN GREATEST(0, planned_div + min_cash_topup - fcfe) END AS funding_gap,
       CASE WHEN cash_data_complete THEN '现金桥接已填；仍需证据核验' ELSE 'DDM条件计算；现金桥接缺失' END AS calc_status
FROM o;

CREATE VIEW cj_fin_calc_full AS
SELECT b.model_key, b.scenario_name, b.year AS row_year, c.*
FROM cj_fin_calc_base b JOIN cj_fin_calc_calc c USING (id);

---------------------------------------------------------------------------
-- 2.4 估值结论
---------------------------------------------------------------------------
CREATE VIEW cj_valuation_calc AS
WITH v AS (
  SELECT b.id, b.scenario,
         s.eff_discount_rate AS r, s.terminal_growth AS g, s.eff_base_year AS by, s.eff_terminal_year AS ty,
         s.eff_shares_yi AS shares_yi, s.eff_legacy_price AS legacy_price,
         s.latest_price AS market_price, s.latest_price_date AS market_date,
         (SELECT count(f.model_key) FROM cj_lnk_valuation_forecast_rows l JOIN cj_fin_calc_full f ON f.id = l.fin_calc_id
           WHERE l.valuation_id = b.id) AS linked_rows,
         (SELECT sum(f.planned_div_pv) FROM cj_lnk_valuation_forecast_rows l JOIN cj_fin_calc_full f ON f.id = l.fin_calc_id
           WHERE l.valuation_id = b.id) AS forecast_pv,
         (SELECT sum(f.cash_div_pv) FROM cj_lnk_valuation_forecast_rows l JOIN cj_fin_calc_full f ON f.id = l.fin_calc_id
           WHERE l.valuation_id = b.id) AS linked_cash_pv
  FROM cj_valuation_base b
  LEFT JOIN cj_scenario_full s ON s.id = b.scenario_input_id
), w AS (
  SELECT v.*,
         (SELECT count(*) FROM cj_fin_calc_full f WHERE f.scenario_name = v.scenario) AS same_name_rows,
         (SELECT count(*) FROM cj_fin_calc_full f WHERE f.scenario_name = v.scenario AND f.row_year = v.ty) AS terminal_rows,
         (SELECT f.planned_div FROM cj_fin_calc_full f WHERE f.scenario_name = v.scenario AND f.row_year = v.ty
           ORDER BY f.id LIMIT 1) AS terminal_div,
         (SELECT f.cash_supported_div FROM cj_fin_calc_full f WHERE f.scenario_name = v.scenario AND f.row_year = v.ty
           ORDER BY f.id LIMIT 1) AS terminal_cash_div,
         (SELECT count(*) FROM cj_fin_calc_full f WHERE f.scenario_name = v.scenario AND f.cash_data_complete) AS cash_complete_years,
         v.forecast_pv - (SELECT COALESCE(sum(f.planned_div_pv), 0) FROM cj_fin_calc_full f WHERE f.scenario_name = v.scenario) AS recon_diff
  FROM v
), x AS (
  SELECT w.*,
         CASE WHEN linked_rows = ty - by AND same_name_rows = linked_rows AND terminal_rows = 1 AND abs(recon_diff) < 0.000001
              THEN '通过' ELSE '缺行或引用不一致' END AS model_check,
         CASE WHEN r > g THEN terminal_div * (1 + g) / (r - g) / power(1 + r, ty - by) END AS terminal_pv
  FROM w
), y AS (
  SELECT x.*,
         CASE WHEN model_check = '通过' AND r > g AND shares_yi > 0 THEN (forecast_pv + terminal_pv) / shares_yi END AS cond_ddm,
         CASE WHEN model_check = '通过' AND cash_complete_years = ty - by AND r > g AND shares_yi > 0
              THEN (linked_cash_pv + terminal_cash_div * (1 + g) / (r - g) / power(1 + r, ty - by)) / shares_yi END AS cash_ddm
  FROM x
)
SELECT id, cond_ddm, cash_ddm, model_check, market_price, market_date, legacy_price,
       CASE WHEN cond_ddm > 0 THEN 1 - legacy_price / cond_ddm END AS legacy_margin,
       CASE WHEN cond_ddm > 0 THEN cond_ddm * 0.9 END AS watch_price_10,
       CASE WHEN cond_ddm > 0 THEN cond_ddm * 0.7 END AS watch_price_30,
       forecast_pv, terminal_div, terminal_pv,
       CASE WHEN cond_ddm > 0 THEN terminal_pv / (cond_ddm * shares_yi) END AS terminal_share,
       r AS discount_rate, g AS terminal_growth, by AS base_year, ty AS terminal_year, shares_yi,
       linked_rows, same_name_rows, terminal_rows, recon_diff, cash_complete_years, terminal_cash_div,
       '待核验：旧价格、税及少数股东代理、资本更新与终值可持续性未通过；不得机械买卖'::text AS decision_status
FROM y;

---------------------------------------------------------------------------
-- 2.5 敏感性：利率×增长（基准股息路径，r/g 独立偏移）
---------------------------------------------------------------------------
CREATE VIEW cj_sens_rg_calc AS
WITH v AS (
  SELECT b.id,
         s.eff_discount_rate + b.rate_shift AS r, s.terminal_growth + b.growth_shift AS g,
         s.eff_shares_yi AS shares_yi, s.eff_base_year AS by, s.eff_terminal_year AS ty
  FROM cj_sens_rg_base b
  LEFT JOIN cj_scenario_full s ON s.id = b.base_scenario_id
), w AS (
  SELECT v.*,
         (SELECT sum((SELECT f.planned_div FROM cj_fin_calc_full f WHERE f.scenario_name = '基准' AND f.row_year = y
                       ORDER BY f.id LIMIT 1) / power(1 + v.r, y - v.by))
            FROM generate_series(2026, 2035) AS y) AS forecast_pv,
         (SELECT f.planned_div FROM cj_fin_calc_full f WHERE f.scenario_name = '基准' AND f.row_year = v.ty
           ORDER BY f.id LIMIT 1) AS terminal_div
  FROM v
)
SELECT id, r AS discount_rate, g AS terminal_growth,
       CASE WHEN by = 2025 AND ty = 2035 AND r > g AND shares_yi > 0
            THEN (forecast_pv + terminal_div * (1 + g) / (r - g) / power(1 + r, ty - by)) / shares_yi END AS cond_ddm,
       forecast_pv, terminal_div, shares_yi, by AS base_year, ty AS terminal_year,
       '基准现金股息路径不变；r与g独立敏感性，非新增事实'::text AS nature
FROM w;

---------------------------------------------------------------------------
-- 2.6 单参数试验（飞书空白数字按 0 参与运算）
---------------------------------------------------------------------------
CREATE VIEW cj_param_trial_calc AS
WITH v AS (
  SELECT b.id, COALESCE(b.start_year, 0) AS sy, COALESCE(b.end_year, 0) AS ey,
         COALESCE(b.volume_delta, 0) AS dv, COALESCE(b.price_delta, 0) AS dp,
         COALESCE(b.cash_cost_delta, 0) AS dc, COALESCE(b.da_delta, 0) AS dd, COALESCE(b.interest_delta, 0) AS di,
         s.eff_discount_rate + COALESCE(b.rate_delta, 0) AS tr, s.terminal_growth AS g,
         s.eff_shares_yi AS shares_yi, s.eff_base_year AS by, s.eff_terminal_year AS ty
  FROM cj_param_trial_base b
  LEFT JOIN cj_scenario_full s ON s.id = b.base_scenario_id
), d AS (
  SELECT v.id, y.yr,
         GREATEST(0, f.planned_div + CASE WHEN y.yr >= v.sy AND y.yr <= v.ey
           THEN (f.revenue * ((1 + v.dv) * (1 + v.dp) - 1) - v.dc - v.dd - v.di) * (1 - f.burden_rate) * f.payout
           ELSE 0 END) AS div
  FROM v CROSS JOIN generate_series(2026, 2035) AS y(yr)
  LEFT JOIN LATERAL (SELECT * FROM cj_fin_calc_full f WHERE f.scenario_name = '基准' AND f.row_year = y.yr
                     ORDER BY f.id LIMIT 1) f ON TRUE
), p AS (
  SELECT id, jsonb_object_agg(yr::text, div) AS divs FROM d GROUP BY id
), t AS (
  SELECT v.*, p.divs FROM v JOIN p USING (id)
), u AS (
  SELECT t.*,
         CASE WHEN by = 2025 AND ty = 2035 AND tr > g AND shares_yi > 0
              THEN ((SELECT sum((divs ->> yr::text)::double precision / power(1 + tr, yr - by))
                       FROM generate_series(2026, 2035) AS yr)
                    + (divs ->> '2035')::double precision * (1 + g) / (tr - g) / power(1 + tr, ty - by)) / shares_yi
         END AS trial_value,
         (SELECT cond_ddm FROM cj_valuation_calc c JOIN cj_valuation_base b ON b.id = c.id
           WHERE b.scenario = '基准' ORDER BY b.id LIMIT 1) AS base_value
  FROM t
)
SELECT id, trial_value, base_value,
       CASE WHEN trial_value IS NOT NULL THEN trial_value - base_value END AS value_change,
       CASE WHEN base_value > 0 THEN (trial_value - base_value) / base_value END AS change_pct,
       tr AS trial_rate, g AS terminal_growth, shares_yi, by AS base_year, ty AS terminal_year,
       (divs ->> '2026')::double precision AS trial_div_2026, (divs ->> '2027')::double precision AS trial_div_2027,
       (divs ->> '2028')::double precision AS trial_div_2028, (divs ->> '2029')::double precision AS trial_div_2029,
       (divs ->> '2030')::double precision AS trial_div_2030, (divs ->> '2031')::double precision AS trial_div_2031,
       (divs ->> '2032')::double precision AS trial_div_2032, (divs ->> '2033')::double precision AS trial_div_2033,
       (divs ->> '2034')::double precision AS trial_div_2034, (divs ->> '2035')::double precision AS trial_div_2035
FROM u;

---------------------------------------------------------------------------
-- 3.1 跟踪任务
---------------------------------------------------------------------------
CREATE VIEW cj_tracking_calc AS
SELECT t.id, o.unified_value AS latest_value, o.unit AS latest_unit, o.obs_date AS latest_date, o.metric AS latest_metric,
       CASE WHEN t.obs_code IS NULL OR t.obs_code = '' THEN '尚未接入自动观察'
            WHEN o.unified_value IS NULL THEN '无有效观察'
            ELSE '已联动；不自动修改估值假设' END AS link_status
FROM cj_tracking_base t
LEFT JOIN LATERAL (
  SELECT m.unified_value, m.unit, m.obs_date, m.metric FROM cj_market_obs_full m
  WHERE m.metric_code = t.obs_code AND m.is_current AND m.quality_ok = 1
  ORDER BY m.obs_date COLLATE "C" DESC, m.id LIMIT 1
) o ON t.obs_code IS NOT NULL AND t.obs_code <> '';

---------------------------------------------------------------------------
-- 3.3 质量检查
---------------------------------------------------------------------------
CREATE VIEW cj_quality_calc AS
WITH k AS (
  SELECT
    CASE WHEN (SELECT price_date FROM cj_scenario_full WHERE scenario = '基准' ORDER BY id LIMIT 1)
              = (SELECT latest_price_date FROM cj_scenario_full WHERE scenario = '基准' ORDER BY id LIMIT 1)
         THEN '价格日期同日；估值基年仍需重置' ELSE '旧价格与最近观察日不同；现时信号阻断' END AS price_date_check,
    CASE WHEN (SELECT c.cash_complete_years FROM cj_valuation_calc c JOIN cj_valuation_base b USING (id)
               WHERE b.scenario = '基准' ORDER BY b.id LIMIT 1) = 10
         THEN '现金桥接已填；待证据核验' ELSE '现金桥接缺失；现金估值阻断' END AS cash_bridge_check,
    CASE WHEN (SELECT count(*) FROM cj_valuation_calc WHERE model_check = '通过') = 3
         THEN '三情景模型勾稽通过' ELSE '模型行缺失或引用不一致' END AS model_row_check,
    CASE WHEN (SELECT count(*) FROM cj_market_obs_full WHERE quality_ok = 0 AND unified_value < 0) > 0
         THEN '存在负值观察；已排除有效口径' ELSE '未发现负值有效观察' END AS negative_obs_check
)
SELECT q.id,
       CASE q.check_id WHEN 'Q06' THEN k.cash_bridge_check WHEN 'Q08' THEN k.price_date_check
                       WHEN 'Q11' THEN k.model_row_check WHEN 'Q12' THEN k.negative_obs_check
                       ELSE q.status END AS live_status,
       k.cash_bridge_check, k.price_date_check, k.model_row_check, k.negative_obs_check
FROM cj_quality_base q CROSS JOIN k;

---------------------------------------------------------------------------
-- 4.1 采集状态（依赖当前时间）
---------------------------------------------------------------------------
CREATE VIEW cj_collect_ctl_calc AS
WITH v AS (
  SELECT c.id, c.integration_status, c.max_lag_days,
         (SELECT m.obs_date FROM cj_market_obs_base m WHERE m.metric_code = c.metric_code
           ORDER BY m.obs_date COLLATE "C" DESC, m.id LIMIT 1) AS latest_obs_date,
         (SELECT max(r.collected_at) FROM cj_collect_raw_base r WHERE r.metric_code = c.metric_code) AS latest_collected_at,
         lr.run_result AS latest_run_result
  FROM cj_collect_ctl_base c
  LEFT JOIN (
    SELECT DISTINCT ON (r.metric_code) r.metric_code, rc.run_result
    FROM cj_collect_raw_calc rc JOIN cj_collect_raw_base r USING (id)
    ORDER BY r.metric_code, r.collected_at DESC, r.id
  ) lr ON lr.metric_code = c.metric_code
), h AS (
  SELECT v.*,
         CASE WHEN integration_status IS DISTINCT FROM '云端已接入' THEN '待接通'
              WHEN latest_collected_at IS NULL OR extract(epoch FROM now() - latest_collected_at) / 86400 > 1.5 THEN '采集缺失或停摆'
              WHEN strpos(latest_run_result, '未完成') > 0 THEN '采集未完成'
              WHEN strpos(latest_run_result, '部分完成') > 0 THEN '解析或校验失败'
              WHEN latest_obs_date IS NULL OR latest_obs_date = '' THEN '等待首次入库'
              WHEN (now() AT TIME ZONE 'Asia/Shanghai')::date - latest_obs_date::date > max_lag_days THEN '观察持续过期'
              ELSE '正常' END AS health_status
  FROM v
)
SELECT id, health_status,
       CASE WHEN integration_status = '云端已接入' AND health_status <> '正常' THEN 1 ELSE 0 END AS needs_alert,
       CASE WHEN integration_status = '云端已接入' AND health_status <> '正常' THEN '需要处理' ELSE '正常' END AS notify_condition,
       latest_collected_at, latest_obs_date, latest_run_result
FROM h;

---------------------------------------------------------------------------
-- 归档（V1）表
---------------------------------------------------------------------------
CREATE VIEW cj_v1_annual_calc AS
SELECT id,
       cj_round(dividend_total / NULLIF(net_profit, 0) * 100, 2) AS payout_pct,
       CASE WHEN da IS NOT NULL AND finance_cost IS NOT NULL THEN cj_round(da + finance_cost, 2) END AS da_plus_finance
FROM cj_v1_annual_base;

CREATE VIEW cj_v1_forecast_calc AS
WITH k AS (
  SELECT (SELECT r_pct FROM cj_v1_valuation_base ORDER BY id LIMIT 1) AS r_pct,
         (SELECT shares_yi FROM cj_v1_valuation_base ORDER BY id LIMIT 1) AS shares_yi
), a AS (
  SELECT f.*, k.*, cj_round(f.generation * f.avg_price, 2) AS revenue FROM cj_v1_forecast_base f CROSS JOIN k
), b AS (
  SELECT a.*, cj_round(revenue - cash_cost - depreciation - finance_cost + other_contrib, 2) AS pretax_profit FROM a
), c AS (
  SELECT b.*, cj_round(pretax_profit * (1 - burden_pct / 100), 2) AS net_profit FROM b
), d AS (
  SELECT c.*, cj_round(net_profit * payout_pct / 100, 2) AS dividend_total,
         cj_round(1 / power(1 + r_pct / 100, year - 2025), 6) AS discount_factor FROM c
)
SELECT id, revenue, pretax_profit, net_profit, dividend_total,
       cj_round(dividend_total / NULLIF(shares_yi, 0), 4) AS dps, discount_factor,
       cj_round(dividend_total * discount_factor, 2) AS div_pv
FROM d;

CREATE VIEW cj_v1_valuation_calc AS
WITH a AS (
  SELECT v.*,
         (SELECT c.dividend_total FROM cj_v1_forecast_base f JOIN cj_v1_forecast_calc c USING (id)
           WHERE f.year = 2035 ORDER BY f.id LIMIT 1) AS terminal_div,
         cj_round((SELECT sum(div_pv) FROM cj_v1_forecast_calc), 2) AS forecast_pv
  FROM cj_v1_valuation_base v
), b AS (
  SELECT a.*, cj_round(terminal_div * (1 + g_pct / 100) / NULLIF((r_pct - g_pct) / 100, 0), 2) AS terminal_value FROM a
), c AS (
  SELECT b.*, cj_round(terminal_value / power(1 + r_pct / 100, 10), 2) AS terminal_pv FROM b
), d AS (
  SELECT c.*, cj_round(forecast_pv + terminal_pv, 2) AS equity_value FROM c
), e AS (
  SELECT d.*, cj_round(equity_value / NULLIF(shares_yi, 0), 2) AS value_ps FROM d
), f AS (
  SELECT e.*, cj_round(value_ps * (1 - margin_pct / 100), 2) AS buy_threshold FROM e
)
SELECT id, value_ps,
       CASE WHEN price IS NULL OR buy_threshold IS NULL OR value_ps IS NULL THEN '—'
            WHEN price <= buy_threshold THEN '低估·可分批买入'
            WHEN price <= value_ps THEN '合理偏低' ELSE '高估·等待' END AS signal,
       cj_round((price - value_ps) / NULLIF(value_ps, 0) * 100, 2) AS premium_pct,
       buy_threshold, equity_value, forecast_pv, terminal_div, terminal_value, terminal_pv,
       cj_round(fcfe_ps * (1 + g_pct / 100) / NULLIF((r_pct - g_pct) / 100, 0), 2) AS fcfe_perp_value
FROM f;

-- 两阶段戈登：D0·(1+g1)·(1−((1+g1)/(1+r))^10)/(r−g1) + D0·(1+g1)^10·(1+g)/((r−g)·(1+r)^10)
CREATE OR REPLACE FUNCTION cj_two_stage(d0 double precision, g1 double precision, r double precision, g double precision)
RETURNS double precision LANGUAGE sql IMMUTABLE AS $$
  SELECT cj_round(
    d0 * (1 + g1/100) * (1 - power((1 + g1/100) / (1 + r/100), 10)) / NULLIF(r/100 - g1/100, 0)
    + d0 * power(1 + g1/100, 10) * (1 + g/100) / NULLIF((r/100 - g/100) * power(1 + r/100, 10), 0), 2)
$$;

CREATE VIEW cj_v1_scenario_calc AS
SELECT id, cj_two_stage(base_dps, g1_pct, r_pct, g_pct) AS value_ps FROM cj_v1_scenario_base;

CREATE VIEW cj_v1_sens_calc AS
SELECT id, cj_two_stage(base_dps, g1_pct, r_pct, g_pct) AS value_ps FROM cj_v1_sens_base;

COMMIT;
