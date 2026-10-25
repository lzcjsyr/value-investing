-- 2026-10-24：宏观数据独立成项目。
-- 指标“所属公司”为空＝宏观数据（利率、汇率、商品等），由 macro/ 种子负责，各公司按需使用：
--   · 估值参数（无风险利率、股价汇率）与跟踪事项直接引用指标；
--   · 其他想看的宏观数据通过“订阅”（vi_lnk_company_macro_metrics）关联；
--   · 视图 vi_company_metric 汇总以上全部用途，是“哪家公司用到哪个指标”的唯一来源（指标的使用公司、公司的用到的宏观数据、一键采集范围都读它）。
-- 执行完本文件后重新执行 02_calc.sql 与 03_ui.sql。
BEGIN;
COMMENT ON TABLE vi_metric_base IS '指标：高频数据指标的定义。所属公司为空的是宏观数据（利率、汇率、商品等），归“宏观数据”项目所有，各公司按需使用；只和一家公司有关的（股价、水位）挂在这家公司下。同一含义不同口径的数据分成不同指标，不拼接。';
COMMENT ON COLUMN vi_metric_base.category IS '类别（可选：行情、利率、汇率、商品、宏观、水文、经营、其他）';

CREATE TABLE vi_lnk_company_macro_metrics (
  company_id bigint NOT NULL REFERENCES vi_company_base(id) ON DELETE CASCADE,
  metric_id bigint NOT NULL REFERENCES vi_metric_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (company_id, metric_id)
);
COMMENT ON TABLE vi_lnk_company_macro_metrics IS '公司 ↔ 订阅的宏观数据（多对多）';

-- 纸浆期货是大宗商品价格，归宏观数据；类别细分为利率、汇率、商品
UPDATE vi_metric_base SET company_id = NULL, category = '商品' WHERE code IN ('SP.SHFE.WIND', 'SP.SHFE.SINA');
UPDATE vi_metric_base SET category = '汇率' WHERE code = 'HKDCNY';
UPDATE vi_metric_base SET category = '利率' WHERE code IN ('CGB10Y.CCDC', 'CGB10Y.CSI');

-- 订阅：估值参数与跟踪事项已经引用的不必再订阅
INSERT INTO vi_lnk_company_macro_metrics (company_id, metric_id)
SELECT c.id, m.id FROM vi_company_base c JOIN vi_metric_base m ON (c.code, m.code) IN
  (('002078.SZ', 'SP.SHFE.WIND'), ('002078.SZ', 'SP.SHFE.SINA'), ('600900.SH', 'CGB10Y.CSI'))
ON CONFLICT DO NOTHING;
COMMIT;
