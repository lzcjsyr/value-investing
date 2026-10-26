-- 自动生成：framework/migrate_metric_layer.py（指标与数据重构）。
-- 执行顺序：先删 NocoBase 里「数据」的经营影响、经营解读、处理状态字段和重点跟踪集合；执行本文件；再重跑 02_calc.sql、03_ui.sql。
BEGIN;
-- 1. 口径记到每期数据上；经营解读并入说明
ALTER TABLE vi_observation_base ADD COLUMN basis text DEFAULT '时点';
COMMENT ON COLUMN vi_observation_base.basis IS '口径：时点＝某一天的值或期末余额；其余为期间数（可选：时点、单季、半年累计、前三季度累计、全年、年初至今累计、滚动四季度）';
UPDATE vi_observation_base o SET basis = m.basis FROM vi_metric_base m WHERE m.id = o.metric_id;
UPDATE vi_observation_base SET basis = '时点' WHERE metric_id = 157;
UPDATE vi_observation_base SET summary = CASE WHEN nullif(btrim(summary), '') IS NULL THEN '解读：' || assessment ELSE summary || E'\n解读：' || assessment END WHERE nullif(btrim(assessment), '') IS NOT NULL;
COMMENT ON COLUMN vi_observation_base.summary IS '说明：披露原文摘要、统计范围与推算过程；需要时写一句对经营的解读';
-- 2. 与三大报表重复的指标改为报表计算（公式已逐期核对），删掉另存的数
ALTER TABLE vi_metric_base ADD COLUMN formula text;
COMMENT ON COLUMN vi_metric_base.formula IS '报表公式：报表计算的指标填，科目相加减；比率用“÷”，结果为 %';
COMMENT ON COLUMN vi_metric_base.basis IS '主口径：最新值、重点跟踪按这个口径取；每期数据自己的口径记在「数据」上（可选：时点、单季、半年累计、前三季度累计、全年、年初至今累计、滚动四季度）';
UPDATE vi_metric_base SET source_kind = '报表计算', formula = '营业收入', source_name = '财务数据（三大报表）：营业收入' WHERE id = 99;
UPDATE vi_metric_base SET source_kind = '报表计算', formula = '归属于母公司所有者的净利润', source_name = '财务数据（三大报表）：归属于母公司所有者的净利润' WHERE id = 100;
UPDATE vi_metric_base SET source_kind = '报表计算', formula = '（营业收入 − 营业成本）÷ 营业收入', source_name = '财务数据（三大报表）：（营业收入 − 营业成本）÷ 营业收入' WHERE id = 101;
UPDATE vi_metric_base SET source_kind = '报表计算', formula = '营业收入', source_name = '财务数据（三大报表）：营业收入' WHERE id = 103;
UPDATE vi_metric_base SET source_kind = '报表计算', formula = '归属于母公司所有者的净利润', source_name = '财务数据（三大报表）：归属于母公司所有者的净利润' WHERE id = 104;
UPDATE vi_metric_base SET source_kind = '报表计算', formula = '（营业收入 − 营业成本）÷ 营业收入', source_name = '财务数据（三大报表）：（营业收入 − 营业成本）÷ 营业收入' WHERE id = 105;
UPDATE vi_metric_base SET source_kind = '报表计算', formula = '（营业收入 − 营业成本）÷ 营业收入', source_name = '财务数据（三大报表）：（营业收入 − 营业成本）÷ 营业收入' WHERE id = 189;
UPDATE vi_metric_base SET source_kind = '报表计算', formula = '应收账款 + 合同资产', source_name = '财务数据（三大报表）：应收账款 + 合同资产' WHERE id = 112;
UPDATE vi_metric_base SET source_kind = '报表计算', formula = '应收账款 + 合同资产', source_name = '财务数据（三大报表）：应收账款 + 合同资产' WHERE id = 115;
UPDATE vi_metric_base SET source_kind = '报表计算', formula = '应收账款 + 合同资产', source_name = '财务数据（三大报表）：应收账款 + 合同资产' WHERE id = 186;
UPDATE vi_metric_base SET source_kind = '报表计算', formula = '应付票据及应付账款', source_name = '财务数据（三大报表）：应付票据及应付账款' WHERE id = 113;
UPDATE vi_metric_base SET source_kind = '报表计算', formula = '应付票据及应付账款', source_name = '财务数据（三大报表）：应付票据及应付账款' WHERE id = 116;
UPDATE vi_metric_base SET source_kind = '报表计算', formula = '−资产减值损失 − 信用减值损失', source_name = '财务数据（三大报表）：−资产减值损失 − 信用减值损失' WHERE id = 114;
UPDATE vi_metric_base SET source_kind = '报表计算', formula = '−资产减值损失 − 信用减值损失', source_name = '财务数据（三大报表）：−资产减值损失 − 信用减值损失' WHERE id = 117;
UPDATE vi_metric_base SET source_kind = '报表计算', formula = '−资产减值损失 − 信用减值损失', source_name = '财务数据（三大报表）：−资产减值损失 − 信用减值损失' WHERE id = 184;
UPDATE vi_metric_base SET source_kind = '报表计算', formula = '经营活动产生的现金流量净额', source_name = '财务数据（三大报表）：经营活动产生的现金流量净额' WHERE id = 185;
UPDATE vi_metric_base SET source_kind = '报表计算', formula = '其他非流动资产 + 长期应收款', source_name = '财务数据（三大报表）：其他非流动资产 + 长期应收款' WHERE id = 187;
UPDATE vi_metric_base SET source_kind = '报表计算', formula = '短期借款 + 一年内到期的非流动负债 + 长期借款 + 应付债券 + 租赁负债', source_name = '财务数据（三大报表）：短期借款 + 一年内到期的非流动负债 + 长期借款 + 应付债券 + 租赁负债' WHERE id = 188;
UPDATE vi_metric_base SET source_kind = '报表计算', formula = '营业额', source_name = '财务数据（三大报表）：营业额' WHERE id = 118;
UPDATE vi_metric_base SET source_kind = '报表计算', formula = '股东应占溢利', source_name = '财务数据（三大报表）：股东应占溢利' WHERE id = 124;
UPDATE vi_metric_base SET source_kind = '报表计算', formula = '毛利 ÷ 营业额', source_name = '财务数据（三大报表）：毛利 ÷ 营业额' WHERE id = 123;
UPDATE vi_metric_base SET source_kind = '报表计算', formula = '现金及等价物 + 短期存款 + 短期投资 + 中长期存款', source_name = '财务数据（三大报表）：现金及等价物 + 短期存款 + 短期投资 + 中长期存款' WHERE id = 130;
UPDATE vi_metric_base SET source_kind = '报表计算', formula = '短期贷款 + 长期贷款 + 应付票据 + 应付票据(非流动) + 融资租赁负债(流动) + 融资租赁负债(非流动)', source_name = '财务数据（三大报表）：短期贷款 + 长期贷款 + 应付票据 + 应付票据(非流动) + 融资租赁负债(流动) + 融资租赁负债(非流动)' WHERE id = 131;
UPDATE vi_metric_base SET source_kind = '报表计算', formula = '营业额', source_name = '财务数据（三大报表）：营业额' WHERE id = 134;
UPDATE vi_metric_base SET source_kind = '报表计算', formula = '毛利 ÷ 营业额', source_name = '财务数据（三大报表）：毛利 ÷ 营业额' WHERE id = 140;
UPDATE vi_metric_base SET source_kind = '报表计算', formula = '研发费用', source_name = '财务数据（三大报表）：研发费用' WHERE id = 146;
UPDATE vi_metric_base SET source_kind = '报表计算', formula = '除税后溢利', source_name = '财务数据（三大报表）：除税后溢利' WHERE id = 155;
UPDATE vi_metric_base SET source_kind = '报表计算', formula = '短期贷款 + 长期贷款', source_name = '财务数据（三大报表）：短期贷款 + 长期贷款' WHERE id = 158;
DELETE FROM vi_observation_base WHERE metric_id IN (99, 100, 101, 103, 104, 105, 189, 112, 115, 186, 113, 116, 114, 117, 184, 185, 187, 188, 118, 124, 123, 130, 131, 134, 140, 146, 155, 158);
-- 3. 同名同单位的指标合成一个，设主口径（合并函数取自 02_calc.sql，这里先装上）
CREATE OR REPLACE FUNCTION vi_merge_company_metrics(p_company bigint) RETURNS int LANGUAGE plpgsql AS $$
DECLARE g record; keep bigint; d bigint; n int := 0;
BEGIN
  FOR g IN SELECT name, unit, array_agg(id ORDER BY
             (EXISTS (SELECT 1 FROM vi_lnk_judgment_metrics l WHERE l.metric_id = m.id) OR EXISTS (SELECT 1 FROM vi_lnk_risk_metrics l WHERE l.metric_id = m.id)) DESC, id) AS ids
           FROM vi_metric_base m WHERE company_id = p_company GROUP BY name, unit HAVING count(*) > 1 LOOP
    keep := g.ids[1];
    FOREACH d IN ARRAY g.ids[2:] LOOP
      UPDATE vi_observation_base SET metric_id = keep WHERE metric_id = d;
      UPDATE vi_fact_base SET metric_id = keep WHERE metric_id = d;
      UPDATE vi_collector_base SET metric_id = keep WHERE metric_id = d;
      UPDATE vi_company_base SET price_metric_id = keep WHERE price_metric_id = d;
      UPDATE vi_company_base SET price_fx_metric_id = keep WHERE price_fx_metric_id = d;
      UPDATE vi_model_base SET rf_metric_id = keep WHERE rf_metric_id = d;
      INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id) SELECT judgment_id, keep FROM vi_lnk_judgment_metrics WHERE metric_id = d ON CONFLICT DO NOTHING;
      INSERT INTO vi_lnk_risk_metrics (risk_id, metric_id) SELECT risk_id, keep FROM vi_lnk_risk_metrics WHERE metric_id = d ON CONFLICT DO NOTHING;
      DELETE FROM vi_metric_base WHERE id = d;
      n := n + 1;
    END LOOP;
  END LOOP;
  RETURN n;
END $$;
SELECT vi_merge_company_metrics(id) FROM vi_company_base;
UPDATE vi_metric_base SET basis = '滚动四季度' WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '601668.SH') AND name = '毛利率' AND unit IS NOT DISTINCT FROM '%';
UPDATE vi_metric_base SET basis = '年初至今累计' WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '601668.SH') AND name = '资产及信用减值损失' AND unit IS NOT DISTINCT FROM '亿元';
UPDATE vi_metric_base SET basis = '单季' WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '600900.SH') AND name = '发电量' AND unit IS NOT DISTINCT FROM '亿千瓦时';
UPDATE vi_metric_base SET basis = '单季' WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '002078.SZ') AND name = '毛利率' AND unit IS NOT DISTINCT FROM '%';
UPDATE vi_metric_base SET basis = '单季' WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '601668.SH') AND name = '营业收入' AND unit IS NOT DISTINCT FROM '亿元';
UPDATE vi_metric_base SET basis = '单季' WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '毛利率' AND unit IS NOT DISTINCT FROM '%';
UPDATE vi_metric_base SET basis = '时点' WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '现金、定期存款和短期投资' AND unit IS NOT DISTINCT FROM '亿元';
UPDATE vi_metric_base SET basis = '时点' WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '带息负债（借款＋票据＋租赁）' AND unit IS NOT DISTINCT FROM '亿元';
UPDATE vi_metric_base SET basis = '单季' WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '智能手机毛利率' AND unit IS NOT DISTINCT FROM '%';
UPDATE vi_metric_base SET basis = '单季' WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = 'IoT毛利率' AND unit IS NOT DISTINCT FROM '%';
UPDATE vi_metric_base SET basis = '单季' WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '汽车及AI分部经营损益' AND unit IS NOT DISTINCT FROM '亿元';
UPDATE vi_metric_base SET basis = '单季' WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '互联网服务收入' AND unit IS NOT DISTINCT FROM '亿元';
UPDATE vi_metric_base SET basis = '单季' WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '回购（港元）' AND unit IS NOT DISTINCT FROM '亿港元';
UPDATE vi_metric_base SET basis = '时点' WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '现金储备' AND unit IS NOT DISTINCT FROM '亿元';
UPDATE vi_metric_base SET basis = '时点' WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '借款' AND unit IS NOT DISTINCT FROM '亿元';
UPDATE vi_metric_base SET basis = '年初至今累计' WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '601668.SH') AND name = '新签合同总额' AND unit IS NOT DISTINCT FROM '亿元';
UPDATE vi_metric_base SET basis = '年初至今累计' WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '601668.SH') AND name = '房屋建筑新开工面积' AND unit IS NOT DISTINCT FROM '万㎡';
UPDATE vi_metric_base SET basis = '年初至今累计' WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '601668.SH') AND name = '地产合约销售额' AND unit IS NOT DISTINCT FROM '亿元';
UPDATE vi_metric_base SET basis = '单季' WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '002078.SZ') AND name = '营业收入' AND unit IS NOT DISTINCT FROM '亿元';
UPDATE vi_metric_base SET basis = '时点' WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '601668.SH') AND name = '应收账款＋合同资产' AND unit IS NOT DISTINCT FROM '亿元';
UPDATE vi_metric_base SET basis = '单季' WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '智能手机出货量' AND unit IS NOT DISTINCT FROM '百万台';
UPDATE vi_metric_base SET basis = '单季' WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '汽车交付量' AND unit IS NOT DISTINCT FROM '辆';
UPDATE vi_metric_base SET basis = '单季' WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '002078.SZ') AND name = '归母净利润' AND unit IS NOT DISTINCT FROM '亿元';
UPDATE vi_metric_base SET basis = '单季' WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '601668.SH') AND name = '归母净利润' AND unit IS NOT DISTINCT FROM '亿元';
UPDATE vi_metric_base SET basis = '时点' WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '601668.SH') AND name = '应付票据及应付账款' AND unit IS NOT DISTINCT FROM '亿元';
UPDATE vi_metric_base SET basis = '单季' WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '营业收入' AND unit IS NOT DISTINCT FROM '亿元';
UPDATE vi_metric_base SET basis = '单季' WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '归母净利润' AND unit IS NOT DISTINCT FROM '亿元';
UPDATE vi_metric_base SET basis = '单季' WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '营业收入' AND unit IS NOT DISTINCT FROM '亿元';
UPDATE vi_metric_base SET basis = '单季' WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '智能手机收入' AND unit IS NOT DISTINCT FROM '亿元';
UPDATE vi_metric_base SET basis = '单季' WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = 'IoT与生活消费产品收入' AND unit IS NOT DISTINCT FROM '亿元';
UPDATE vi_metric_base SET basis = '单季' WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '毛利率' AND unit IS NOT DISTINCT FROM '%';
UPDATE vi_metric_base SET basis = '单季' WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '互联网服务毛利率' AND unit IS NOT DISTINCT FROM '%';
UPDATE vi_metric_base SET basis = '单季' WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '研发开支' AND unit IS NOT DISTINCT FROM '亿元';
UPDATE vi_metric_base SET basis = '单季' WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '生态经营利润（推算）' AND unit IS NOT DISTINCT FROM '亿元';
UPDATE vi_metric_base SET basis = '单季' WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '生态经营利润率（推算）' AND unit IS NOT DISTINCT FROM '%';
UPDATE vi_metric_base SET basis = '单季' WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '期间利润（国际财务报告准则）' AND unit IS NOT DISTINCT FROM '亿元';
UPDATE vi_metric_base SET basis = '滚动四季度' WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '601668.SH') AND name = '经营活动现金流量净额' AND unit IS NOT DISTINCT FROM '亿元';
UPDATE vi_metric_base SET basis = '时点' WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '601668.SH') AND name = 'PPP 相关长期资产（其他非流动资产＋长期应收款）' AND unit IS NOT DISTINCT FROM '亿元';
UPDATE vi_metric_base SET basis = '时点' WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '601668.SH') AND name = '带息负债' AND unit IS NOT DISTINCT FROM '亿元';
-- 4. 删除不再使用的字段与视图（02、03 随后重建）
DROP VIEW IF EXISTS vi_tracking, vi_observation, vi_observation_calc, vi_disclosed CASCADE;
ALTER TABLE vi_observation_base DROP COLUMN impact, DROP COLUMN assessment, DROP COLUMN status;
COMMIT;
