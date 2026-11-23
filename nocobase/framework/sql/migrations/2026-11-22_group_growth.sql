-- 腾讯音乐第三层。保留现有分项增速、RONIC、预测期限及手工研究备注。
BEGIN;
-- 集团口径。收入分项增长，利润率按第二层合并利润表计算；偏移量采用小数。
CREATE OR REPLACE FUNCTION vi_gw_group_cash_path(plan text, bases jsonb, e float8,
    direct_cost float8, selling float8, admin float8, tax_rate float8, attrib float8, ro float8, n integer)
RETURNS jsonb LANGUAGE plpgsql IMMUTABLE STRICT AS $$
DECLARE
  config jsonb;
  items jsonb;
  base_revenue float8;
  gross_rate float8;
  selling_rate float8;
  admin_rate float8;
  base_core float8;
  forecast_margin float8;
  previous_revenue float8;
  next_revenue float8;
  current_e float8 := e;
  investment float8;
  flows float8[] := '{}';
  yr integer;
BEGIN
  config := plan::jsonb;
  items := config->'lines';
  IF config->>'model' IS DISTINCT FROM 'group_income'
     OR jsonb_typeof(items) IS DISTINCT FROM 'array' OR n NOT BETWEEN 0 AND 100 OR ro <= 0
     OR jsonb_typeof(config#>'{rateChanges,gross}') IS DISTINCT FROM 'number'
     OR jsonb_typeof(config#>'{rateChanges,selling}') IS DISTINCT FROM 'number'
     OR jsonb_typeof(config#>'{rateChanges,admin}') IS DISTINCT FROM 'number' THEN RETURN NULL; END IF;
  IF EXISTS (SELECT FROM jsonb_to_recordset(items) p(name text, early float8, late float8)
             WHERE name IS NULL OR (bases->>name)::float8 IS NULL OR early IS NULL OR late IS NULL OR least(early,late) < -1)
     OR jsonb_array_length(items) <> (SELECT count(DISTINCT p->>'name') FROM jsonb_array_elements(items) p)
     OR jsonb_array_length(items) <> (SELECT count(*) FROM jsonb_object_keys(bases)) THEN RETURN NULL; END IF;
  SELECT sum(value::float8) INTO base_revenue FROM jsonb_each_text(bases);
  IF base_revenue IS NULL OR base_revenue <= 0 THEN RETURN NULL; END IF;
  gross_rate := 1 - direct_cost/base_revenue + (config#>>'{rateChanges,gross}')::float8;
  selling_rate := selling/base_revenue + (config#>>'{rateChanges,selling}')::float8;
  admin_rate := admin/base_revenue + (config#>>'{rateChanges,admin}')::float8;
  IF gross_rate > 1 OR selling_rate < 0 OR admin_rate < 0 THEN RETURN NULL; END IF;
  base_core := base_revenue - direct_cost - selling - admin;
  forecast_margin := gross_rate - selling_rate - admin_rate;
  previous_revenue := base_revenue;
  FOR yr IN 1..n LOOP
    SELECT sum((bases->>name)::float8 * power(1+early, least(yr,3)) * power(1+late, greatest(yr-3,0)))
      INTO next_revenue FROM jsonb_to_recordset(items) p(name text, early float8, late float8);
    -- 只有合计收入净扩张带来的正向归母收益需要增长投入。调利润率本身不产生投入。
    investment := greatest(next_revenue-previous_revenue,0) * greatest(forecast_margin*(1-tax_rate)*attrib,0) / ro;
    flows := array_append(flows, current_e-investment);
    current_e := e + (next_revenue*forecast_margin - base_core)*(1-tax_rate)*attrib;
    previous_revenue := next_revenue;
  END LOOP;
  RETURN to_jsonb(array_append(flows,current_e));
EXCEPTION WHEN data_exception THEN RETURN NULL;
END $$;

CREATE OR REPLACE VIEW vi_gw_unit AS
WITH lines AS (
  SELECT e.company_id, e.business_id, e.name, e.formula, e.section, e.direction, e.value, e.method, c.normalized,
         CASE WHEN e.section IN ('税前调整', '税后调整') AND e.direction = '减' THEN -1 ELSE 1 END AS sgn
  FROM vi_epv_base e JOIN vi_epv_calc c ON c.id = e.id
), agg AS (
  SELECT company_id, business_id,
         jsonb_object_agg(name, normalized) FILTER (WHERE section = '收入' AND name IS NOT NULL) AS bases,
         sum(normalized) FILTER (WHERE section = '收入') AS revenue,
         coalesce(sum(normalized) FILTER (WHERE section = '成本费用'), 0) AS cost,
         sum(normalized) FILTER (WHERE section = '成本费用' AND formula = '−营业成本') AS direct_cost,
         sum(normalized) FILTER (WHERE section = '成本费用' AND formula = '−销售及营销费用') AS selling,
         sum(normalized) FILTER (WHERE section = '成本费用' AND formula = '−一般及行政费用') AS admin,
         count(*) FILTER (WHERE section = '成本费用' AND coalesce(formula,'') NOT IN
           ('−营业成本','−销售及营销费用','−一般及行政费用')) AS unmapped_costs,
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
     CASE WHEN left(ltrim(revenue_plan),1) = '{' THEN
       CASE WHEN unmapped_costs = 0 THEN vi_gw_group_cash_path(revenue_plan,bases,earnings,
         direct_cost,selling,admin,tax_rate,1-minority_rate,ronic,adv_years) END
     ELSE vi_gw_cash_path(revenue_plan,bases,earnings,ebit_reported,tax_rate,1-minority_rate,ronic,adv_years) END
  END AS cash_path
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


UPDATE vi_growth_base g
SET revenue_plan=jsonb_build_object(
      'model','group_income',
      'lines',(SELECT jsonb_agg(item-'margin' ORDER BY pos) FROM jsonb_array_elements(g.revenue_plan::jsonb) WITH ORDINALITY a(item,pos)),
      'rateChanges',jsonb_build_object('gross',0,'selling',0,'admin',0)
    )::text,
    note=CASE WHEN g.note IN ('逐年汇总分项收入和利润，扣除增长投入，优势期末按届时盈利资本化。',
                              '逐年汇总分项收入与利润，扣除增长投入；优势期末按届时盈利资本化')
              THEN '逐年汇总分项收入，按集团毛利率和费用率计利润，扣除增长投入并折现。' ELSE g.note END
FROM vi_company_base c, vi_business_base b
WHERE c.code='01698.HK' AND g.company_id=c.id AND b.company_id=c.id AND b.code='B1' AND g.business_id=b.id
  AND jsonb_typeof(g.revenue_plan::jsonb)='array';
UPDATE vi_judgment_base j SET judgment='沿用第二层正常化收入基线 349.06 亿元（会员 199.40、营销及消费 TTM 99.30、社交娱乐 50.36 亿元），先分别预测三条收入线。会员年增 2%，反映付费升级同时受免费产品分流。营销及消费服务前三年增 10%、后七年增 6%，反映演出与周边从较小基数扩张后放缓。社交娱乐每年收缩 8%，接近 2025 全年降幅 7.3%。这些均为十年推演假设。' FROM vi_company_base c
WHERE c.code='01698.HK' AND j.company_id=c.id AND j.code='J-GROW' AND j.judgment='沿用第二层正常化收入基线 349.06 亿元（会员 199.40、营销及消费 TTM 99.30、社交娱乐 50.36 亿元），先按三条收入线估经营利润。会员年增 2%，反映付费升级同时受免费产品分流。营销及消费服务前三年增 10%、后七年增 6%，反映演出与周边从较小基数扩张后放缓。社交娱乐每年收缩 8%，接近 2025 全年降幅 7.3%。这些均为十年推演假设。';
UPDATE vi_judgment_base j SET transmission='各年先汇总三条收入，按第二层正常化的集团综合毛利率、销售费用率和管理费用率计算经营利润，再处理税、维持性投入及少数股东。业务结构变化通过集团毛利率情景测试。新增资本按收入净扩张对应的税后归母盈利和 RONIC 估算。' FROM vi_company_base c
WHERE c.code='01698.HK' AND j.company_id=c.id AND j.code='J-GROW' AND j.transmission='按第二层三条正常化收入（会员 199.40、营销及消费 99.30、社交娱乐 50.36 亿元），以 42%、15%、16% 的研究分摊利润率估基期经营利润 106.71 亿元。十年后分别为 102.09、29.82、3.50 亿元，合计 135.41 亿元。十年复合约 2.41%，按半个百分点取整为 2.5%。利润率沿用研究分摊，税率、归母比例及维持性投入相对稳定，才可把利润增速用于第二层现金收益 E。三块利润仅用来估增长速度。';
COMMENT ON COLUMN vi_growth_base.revenue_plan IS '分项收入预测：各收入行的两段增速与集团预测参数（JSON）';
COMMIT;
