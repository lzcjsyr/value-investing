-- 经营数据的水电来水枚举改为通用经营解读。
-- 原列已经是 text，不重建表或视图，不改变经营数值和来源。
-- NocoBase 字段及页面组件另经 data-modeling / flow-surfaces 接口同步。
-- 幂等：已迁移文字或后来录入的经营解读不会被覆盖。
BEGIN;

UPDATE vi_period_data_base
SET assessment = '原来水评价：' || assessment
WHERE assessment IN ('偏丰', '正常', '偏枯')
  AND company_id IN (SELECT id FROM vi_company_base WHERE code = '600900.SH');

UPDATE vi_period_data_base
SET assessment = NULL
WHERE assessment = '不适用';

COMMENT ON TABLE vi_period_data_base IS '定期经营数据：公司定期披露的经营指标，如销量、订单、用户数、交付量与发电量。区分单季、累计和期末口径；经营解读记录研究判断，披露摘要保留事实与统计口径。';
COMMENT ON COLUMN vi_period_data_base.line_item IS '项目：如销量、新签合同额、付费用户、汽车交付量、发电量';
COMMENT ON COLUMN vi_period_data_base.assessment IS '经营解读：结合公司业务说明比较基准、变化原因及对利润或模型假设的影响；缺少依据时留空。原来水评价仅保留历史标签，不等于经营好坏。';
COMMENT ON COLUMN vi_period_data_base.summary IS '披露摘要与口径：记录披露事实、统计范围、单季或累计口径、管理层披露摘要与推算过程；研究判断写在经营解读。';

COMMIT;
