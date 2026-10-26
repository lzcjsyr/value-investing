-- 事实摘录里按期重复的数字改为引用「数据」里的指标（数字引自）：同一公司、同一期间、数值一致且只对上一个指标的 10 条。
-- 只填关联，不改事实的文字和数值；按 公司代码＋事实标题＋指标代码 匹配，重新灌种子后可再执行。
BEGIN;
UPDATE vi_fact_base SET metric_id = (SELECT id FROM vi_metric_base WHERE code = '002078.SZ.D004') WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '002078.SZ') AND title = '2026 年上半年分产品销量（管理层口径）';
UPDATE vi_fact_base SET metric_id = (SELECT id FROM vi_metric_base WHERE code = '01698.HK.D015') WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '回购与分红：2026 年二季度回购 4 亿美元，新一轮在准备';
UPDATE vi_fact_base SET metric_id = (SELECT id FROM vi_metric_base WHERE code = '01810.HK.D030') WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年 IoT 收入 1,232.0 亿元（+18.3%）、毛利率 23.1%；大家电 +23.1%';
UPDATE vi_fact_base SET metric_id = (SELECT id FROM vi_metric_base WHERE code = '01810.HK.D045') WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年回购 63 亿港元（1.526 亿股）；2026 年 1 月首次公告自动回购计划';
UPDATE vi_fact_base SET metric_id = (SELECT id FROM vi_metric_base WHERE code = '01810.HK.D005') WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年二季度 IoT 与生活消费产品收入 312.8 亿元（−19.2%），国补退坡';
UPDATE vi_fact_base SET metric_id = (SELECT id FROM vi_metric_base WHERE code = '01810.HK.D012') WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年二季度全球：三星 6,050 万、苹果 5,510 万、小米 3,120 万部（−26%）';
UPDATE vi_fact_base SET metric_id = (SELECT id FROM vi_metric_base WHERE code = '01810.HK.D001') WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年二季度收入 1,089.2 亿元（−6.1%），经调整净利润 62.2 亿元（−42.6%）';
UPDATE vi_fact_base SET metric_id = (SELECT id FROM vi_metric_base WHERE code = '01810.HK.D031') WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '互联网服务：2025 年 374.4 亿元（+9.7%）、毛利率 76.5%；2026 年二季度 90.4 亿元（−0.6%）';
UPDATE vi_fact_base SET metric_id = (SELECT id FROM vi_metric_base WHERE code = '601668.SH.D012') WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '601668.SH') AND title = '减值：2025 年 258.7 亿元，2026 年上半年 100.4 亿元';
UPDATE vi_fact_base SET metric_id = (SELECT id FROM vi_metric_base WHERE code = '601668.SH.D010') WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '601668.SH') AND title = '应收账款＋合同资产 10,045 亿元，两年增长 70%';
COMMIT;
