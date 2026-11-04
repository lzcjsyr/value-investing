-- 指标性质（时期指标＝流量／时点指标＝存量）；数据的“期间”改称“统计时间”、“观察日期”改称“对应日期”；
-- 腾讯音乐填指标性质并纠正用户类指标的口径（2026-11-04）。其他公司的指标性质暂时留空。
-- 顺序：本迁移 → 02_calc.sql（趋势列、指标性质、口径一致性触发器）→ 03_ui.sql → register.py → 重启 app → register.py --describe。
BEGIN;
ALTER TABLE vi_metric_base ADD COLUMN IF NOT EXISTS measure text;
COMMENT ON TABLE vi_metric_base IS '指标：一家公司要看的每一个数（经营、财务、行情与环境），一个指标一行：从哪来、最新值、是否到期、被哪些假设或风险盯着；被【公司】【风险分析】【假设依据】【数据】【估值模型】【资产估值与调整】【采集配置】【历史年度】【指标数值】【质量自检】引用。一个指标一行；每期的数在「数据」里，口径（单季、累计、全年、时点）记在每期数据上。来源方式：自动采集、公司披露／年报／手工整理（在「数据」里录）、报表计算（按“报表公式”从三大报表实时算，不另存；报表里有的科目只能这样取）。所属公司为空的是宏观数据。';
COMMENT ON COLUMN vi_metric_base.measure IS '指标性质：时期指标（流量）＝一段时间内累计发生的量，如营业收入、利润、现金流、销量、回购金额；由它们算出的比率（毛利率、ARPPU）也是时期指标，同类时期可以相加（四个单季≈全年）。时点指标（存量）＝某一时刻的状态或规模，如现金、负债、净资产、负债率、股价、零售价、用户数；不能跨期相加，按季度平均的用户数也算时点。时点指标每期的口径只能是“时点”，时期指标不能用“时点”。留空＝还没判定（可选：时期、时点）';
COMMENT ON COLUMN vi_metric_base.basis IS '主口径：最新值、趋势和重点跟踪按这个口径取；每期数据自己的口径记在「数据」上。时点指标只能选“时点”（可选：时点、单季、半年累计、前三季度累计、全年、年初至今累计、滚动四季度）';
COMMENT ON TABLE vi_observation_base IS '数据：每个指标每一期的数：统计时间、口径、数值、同比、来源文档和说明；引用【来源文档】【指标】【原始采集记录】；被【历史年度】【指标数值】【质量自检】引用。一行＝某个指标在某一期、某个口径下的一个数：自动采集的按天（股价、利率、水位），公司披露的按期（发电量、销量、新签合同额）。同一指标、同一口径、同一日期多次采集时取最后一次为“当前版本”；超出合理范围的为无效。报表计算的指标不在这里存数。出处只记一处：公司披露和历史补数关联“来源文档”，自动采集关联“原始采集记录”（只做解析与范围校验，不是财务核验）。';
COMMENT ON COLUMN vi_observation_base.obs_date IS '对应日期：精确到日：时期指标填这段时期的最后一天（2026Q2 → 2026-06-30）；时点指标填观察当天（股价、水位为交易日，期末余额为期末日）';
COMMENT ON COLUMN vi_observation_base.period IS '统计时间：时期指标写这段时期：2026Q2（第二季度）、2026H1（上半年）、2025（全年）、2026M07（7 月）；时点指标写时点所在的报告期：2026Q2＝二季度末、2026M07＝7 月末；日度数据可留空，以对应日期为准';
COMMENT ON COLUMN vi_observation_base.basis IS '口径：这一期数值覆盖的范围。时点指标只能用“时点”（某一天的值或期末余额）；时期指标用其余几种：单季、半年累计、前三季度累计、全年、年初至今累计（月度简报用）、滚动四季度（最近四个季度合计）（可选：时点、单季、半年累计、前三季度累计、全年、年初至今累计、滚动四季度）';

-- 腾讯音乐：付费用户、月活是用户规模（时点指标），原来记成“单季”；2021—2023 年的“全年”实为第四季度的季末数，
-- 2024、2025 年的“全年”与当年第四季度重复（数值相同），删掉重复行，其余改为“时点”、统计时间写到季度。
DO $fix$
DECLARE co bigint := (SELECT id FROM vi_company_base WHERE code = '01698.HK');
        pu bigint; dup int;
BEGIN
  SELECT id INTO pu FROM vi_metric_base WHERE company_id = co AND code = '01698.HK.D009';
  SELECT count(*) INTO dup FROM vi_observation_base a
   WHERE a.metric_id = pu AND a.basis = '全年' AND a.period IN ('2024', '2025')
     AND NOT EXISTS (SELECT 1 FROM vi_observation_base q WHERE q.metric_id = pu AND q.basis = '单季'
                     AND q.period = a.period || 'Q4' AND q.value = a.value);
  IF dup > 0 THEN RAISE EXCEPTION '付费用户 2024/2025 全年数与第四季度不一致，停止迁移'; END IF;
  DELETE FROM vi_observation_base WHERE metric_id = pu AND basis = '全年' AND period IN ('2024', '2025');
  UPDATE vi_observation_base SET basis = '时点', period = period || 'Q4'
   WHERE metric_id = pu AND basis = '全年' AND period ~ '^\d{4}$';
  UPDATE vi_observation_base SET basis = '时点'
   WHERE metric_id IN (SELECT id FROM vi_metric_base WHERE company_id = co AND code IN ('01698.HK.D009', '01698.HK.D011', '01698.HK.D016'));
  -- 汽水音乐月活是第三方的 7 月数据，统计时间写到月
  UPDATE vi_observation_base SET period = '2026M07'
   WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = co AND code = '01698.HK.D016') AND period = '2026Q3';
  UPDATE vi_metric_base SET basis = '时点' WHERE company_id = co AND code IN ('01698.HK.D009', '01698.HK.D011', '01698.HK.D016');
  UPDATE vi_metric_base SET frequency = '月' WHERE company_id = co AND code = '01698.HK.D016';

  UPDATE vi_metric_base SET measure = '时点' WHERE company_id = co AND code IN (
    '01698.HK.PRICE', '01698.HK.D009', '01698.HK.D011', '01698.HK.D016', '01698.HK.D013', '01698.HK.D014',
    '01698.HK.D017', '01698.HK.D018', '01698.HK.D032', '01698.HK.D033');
  UPDATE vi_metric_base SET measure = '时期' WHERE company_id = co AND measure IS NULL;
END
$fix$;
COMMIT;
