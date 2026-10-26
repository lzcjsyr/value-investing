-- 自动生成：framework/migrate_history.py（历史年度、资产项目改为引用指标）。执行前先删 NocoBase 里历史年度的数值字段；执行后重跑 02、03。
BEGIN;
ALTER TABLE vi_metric_base ADD COLUMN model_field text;
COMMENT ON COLUMN vi_metric_base.model_field IS '模型字段：这个指标是历史年度的哪一列（每家公司每列只能有一个指标）';
ALTER TABLE vi_sotp_item_base ADD COLUMN metric_id bigint REFERENCES vi_metric_base(id) ON DELETE SET NULL;
CREATE INDEX ON vi_sotp_item_base (metric_id);
COMMENT ON COLUMN vi_sotp_item_base.metric_id IS '取数指标（关联 指标）';
-- C. 资产项目：新建报表计算指标，金额改为引用
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '01698.HK' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '对外上市股权（公允价值）', '亿元', '财务', '报表计算', '时点', 11,
       '财务数据（三大报表）：指定以公允价值记账之金融资产', '季', '指定以公允价值记账之金融资产' FROM vi_metric_base WHERE code LIKE '01698.HK.D%';
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '01698.HK' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '少数股东权益', '亿元', '财务', '报表计算', '时点', 11,
       '财务数据（三大报表）：少数股东权益', '季', '少数股东权益' FROM vi_metric_base WHERE code LIKE '01698.HK.D%';
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '01810.HK' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '少数股东权益', '亿元', '财务', '报表计算', '时点', 21,
       '财务数据（三大报表）：少数股东权益', '季', '少数股东权益' FROM vi_metric_base WHERE code LIKE '01810.HK.D%';
UPDATE vi_sotp_item_base SET metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '现金、定期存款和短期投资' AND unit = '亿元'), amount = NULL WHERE id = 291;
UPDATE vi_sotp_item_base SET metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '带息负债（借款＋票据＋租赁）' AND unit = '亿元'), amount = NULL WHERE id = 292;
UPDATE vi_sotp_item_base SET metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '对外上市股权（公允价值）' AND unit = '亿元'), amount = NULL WHERE id = 298;
UPDATE vi_sotp_item_base SET metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '对外上市股权（公允价值）' AND unit = '亿元'), amount = NULL WHERE id = 299;
UPDATE vi_sotp_item_base SET metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '对外上市股权（公允价值）' AND unit = '亿元'), amount = NULL WHERE id = 300;
UPDATE vi_sotp_item_base SET metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '少数股东权益' AND unit = '亿元'), amount = NULL WHERE id = 305;
UPDATE vi_sotp_item_base SET metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '现金储备' AND unit = '亿元'), amount = NULL WHERE id = 366;
UPDATE vi_sotp_item_base SET metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '借款' AND unit = '亿元'), amount = NULL WHERE id = 367;
UPDATE vi_sotp_item_base SET metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '少数股东权益' AND unit = '亿元'), amount = NULL WHERE id = 382;
-- A. 历史年度：每列对应一个指标；报表算不出或对不上的年份录原值
UPDATE vi_metric_base SET model_field = 'volume' WHERE id = (SELECT id FROM vi_metric_base WHERE id = 97);
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE id = 97) AND basis = '全年' AND period = '2014';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE id = 97), '2014-12-31', '2014', '全年', 1166, '历史年度原值；口径：重组前（三峡、葛洲坝）', 14, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE id = 97) AND basis = '全年' AND period = '2015';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE id = 97), '2015-12-31', '2015', '全年', 1049.79, '历史年度原值；口径：重组前（三峡、葛洲坝）', 14, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE id = 97) AND basis = '全年' AND period = '2016';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE id = 97), '2016-12-31', '2016', '全年', 2060.6, '历史年度原值；口径：四站（三峡、葛洲坝、溪洛渡、向家坝）', 14, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE id = 97) AND basis = '全年' AND period = '2017';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE id = 97), '2017-12-31', '2017', '全年', 2108.93, '历史年度原值；口径：四站（三峡、葛洲坝、溪洛渡、向家坝）', 14, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE id = 97) AND basis = '全年' AND period = '2018';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE id = 97), '2018-12-31', '2018', '全年', 2154.82, '历史年度原值；口径：四站（三峡、葛洲坝、溪洛渡、向家坝）', 14, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE id = 97) AND basis = '全年' AND period = '2019';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE id = 97), '2019-12-31', '2019', '全年', 2104.63, '历史年度原值；口径：四站（三峡、葛洲坝、溪洛渡、向家坝）', 14, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE id = 97) AND basis = '全年' AND period = '2020';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE id = 97), '2020-12-31', '2020', '全年', 2269.3, '历史年度原值；口径：四站（三峡、葛洲坝、溪洛渡、向家坝）', 14, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE id = 97) AND basis = '全年' AND period = '2021';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE id = 97), '2021-12-31', '2021', '全年', 2083.22, '历史年度原值；口径：四站（三峡、葛洲坝、溪洛渡、向家坝）', 14, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE id = 97) AND basis = '全年' AND period = '2022';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE id = 97), '2022-12-31', '2022', '全年', 1855.81, '历史年度原值；口径：四站（三峡、葛洲坝、溪洛渡、向家坝）', 14, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE id = 97) AND basis = '全年' AND period = '2023';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE id = 97), '2023-12-31', '2023', '全年', 2762.63, '历史年度原值；口径：六站全口径（新增乌东德、白鹤滩）', 1, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE id = 97) AND basis = '全年' AND period = '2024';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE id = 97), '2024-12-31', '2024', '全年', 2959.04, '历史年度原值；口径：六站全口径（新增乌东德、白鹤滩）', 1, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE id = 97) AND basis = '全年' AND period = '2025';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE id = 97), '2025-12-31', '2025', '全年', 3071.94, '历史年度原值；口径：六站全口径（新增乌东德、白鹤滩）', 1, now());
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '600900.SH' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '营业收入', '亿元', '财务', '报表计算',
       '全年', 1, '财务数据（三大报表）：营业收入', '年', '营业收入'
FROM vi_metric_base WHERE code LIKE '600900.SH.D%';
UPDATE vi_metric_base SET model_field = 'revenue' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '营业收入' AND unit IS NOT DISTINCT FROM '亿元');
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '营业收入' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2015';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '营业收入' AND unit IS NOT DISTINCT FROM '亿元'), '2015-12-31', '2015', '全年', 242.39, '历史年度原值（报表算出 474.3496，差异为追溯调整或口径不同）；口径：重组前（三峡、葛洲坝）', 14, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '营业收入' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2017';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '营业收入' AND unit IS NOT DISTINCT FROM '亿元'), '2017-12-31', '2017', '全年', 501.47, '历史年度原值（报表算出 501.4550，差异为追溯调整或口径不同）；口径：四站（三峡、葛洲坝、溪洛渡、向家坝）', 14, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '营业收入' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2022';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '营业收入' AND unit IS NOT DISTINCT FROM '亿元'), '2022-12-31', '2022', '全年', 520.6, '历史年度原值（报表算出 688.6313，差异为追溯调整或口径不同）；口径：四站（三峡、葛洲坝、溪洛渡、向家坝）', 14, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '营业收入' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2023';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '营业收入' AND unit IS NOT DISTINCT FROM '亿元'), '2023-12-31', '2023', '全年', 781.12, '历史年度原值（报表算出 781.4354，差异为追溯调整或口径不同）；口径：六站全口径（新增乌东德、白鹤滩）', 1, now());
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '600900.SH' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '营业成本', '亿元', '财务', '报表计算',
       '全年', 1, '财务数据（三大报表）：营业成本', '年', '营业成本'
FROM vi_metric_base WHERE code LIKE '600900.SH.D%';
UPDATE vi_metric_base SET model_field = 'cost_of_sales' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '营业成本' AND unit IS NOT DISTINCT FROM '亿元');
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '营业成本' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2022';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '营业成本' AND unit IS NOT DISTINCT FROM '亿元'), '2022-12-31', '2022', '全年', 222.33, '历史年度原值（报表算出 295.2422，差异为追溯调整或口径不同）；口径：四站（三峡、葛洲坝、溪洛渡、向家坝）', 14, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '营业成本' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2023';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '营业成本' AND unit IS NOT DISTINCT FROM '亿元'), '2023-12-31', '2023', '全年', 329.43, '历史年度原值（报表算出 329.5828，差异为追溯调整或口径不同）；口径：六站全口径（新增乌东德、白鹤滩）', 1, now());
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '600900.SH' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '利润总额', '亿元', '财务', '报表计算',
       '全年', 1, '财务数据（三大报表）：利润总额', '年', '利润总额'
FROM vi_metric_base WHERE code LIKE '600900.SH.D%';
UPDATE vi_metric_base SET model_field = 'pretax_profit' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '利润总额' AND unit IS NOT DISTINCT FROM '亿元');
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '利润总额' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2023';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '利润总额' AND unit IS NOT DISTINCT FROM '亿元'), '2023-12-31', '2023', '全年', 324.13, '历史年度原值（报表算出 324.2405，差异为追溯调整或口径不同）；口径：六站全口径（新增乌东德、白鹤滩）', 1, now());
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '600900.SH' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '所得税', '亿元', '财务', '报表计算',
       '全年', 1, '财务数据（三大报表）：所得税费用', '年', '所得税费用'
FROM vi_metric_base WHERE code LIKE '600900.SH.D%';
UPDATE vi_metric_base SET model_field = 'income_tax' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '所得税' AND unit IS NOT DISTINCT FROM '亿元');
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '600900.SH' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '归母净利润', '亿元', '财务', '报表计算',
       '全年', 1, '财务数据（三大报表）：归属于母公司所有者的净利润', '年', '归属于母公司所有者的净利润'
FROM vi_metric_base WHERE code LIKE '600900.SH.D%';
UPDATE vi_metric_base SET model_field = 'np_parent' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '归母净利润' AND unit IS NOT DISTINCT FROM '亿元');
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '归母净利润' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2015';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '归母净利润' AND unit IS NOT DISTINCT FROM '亿元'), '2015-12-31', '2015', '全年', 115.2, '历史年度原值（报表算出 182.3466，差异为追溯调整或口径不同）；口径：重组前（三峡、葛洲坝）', 14, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '归母净利润' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2022';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '归母净利润' AND unit IS NOT DISTINCT FROM '亿元'), '2022-12-31', '2022', '全年', 213.09, '历史年度原值（报表算出 237.2592，差异为追溯调整或口径不同）；口径：四站（三峡、葛洲坝、溪洛渡、向家坝）', 14, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '归母净利润' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2023';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '归母净利润' AND unit IS NOT DISTINCT FROM '亿元'), '2023-12-31', '2023', '全年', 272.39, '历史年度原值（报表算出 272.4462，差异为追溯调整或口径不同）；口径：六站全口径（新增乌东德、白鹤滩）', 1, now());
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '600900.SH' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '少数股东损益', '亿元', '财务', '报表计算',
       '全年', 1, '财务数据（三大报表）：少数股东损益', '年', '少数股东损益'
FROM vi_metric_base WHERE code LIKE '600900.SH.D%';
UPDATE vi_metric_base SET model_field = 'minority_profit' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '少数股东损益' AND unit IS NOT DISTINCT FROM '亿元');
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '少数股东损益' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2023';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '少数股东损益' AND unit IS NOT DISTINCT FROM '亿元'), '2023-12-31', '2023', '全年', 7.17, '历史年度原值（报表算出 7.2285，差异为追溯调整或口径不同）；口径：六站全口径（新增乌东德、白鹤滩）', 1, now());
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '600900.SH' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '折旧摊销', '亿元', '财务', '年报',
       '全年', 1, '年报（原历史年度手录）', '年', NULL
FROM vi_metric_base WHERE code LIKE '600900.SH.D%';
UPDATE vi_metric_base SET model_field = 'da' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元');
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2014';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元'), '2014-12-31', '2014', '全年', 62.21, '历史年度原值；口径：重组前（三峡、葛洲坝）', 14, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2015';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元'), '2015-12-31', '2015', '全年', 61.8, '历史年度原值；口径：重组前（三峡、葛洲坝）', 14, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2016';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元'), '2016-12-31', '2016', '全年', 123.19, '历史年度原值；口径：四站（三峡、葛洲坝、溪洛渡、向家坝）', 14, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2017';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元'), '2017-12-31', '2017', '全年', 122.98, '历史年度原值；口径：四站（三峡、葛洲坝、溪洛渡、向家坝）', 14, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2018';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元'), '2018-12-31', '2018', '全年', 122.23, '历史年度原值；口径：四站（三峡、葛洲坝、溪洛渡、向家坝）', 14, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2019';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元'), '2019-12-31', '2019', '全年', 120.6, '历史年度原值；口径：四站（三峡、葛洲坝、溪洛渡、向家坝）', 14, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2020';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元'), '2020-12-31', '2020', '全年', 116.38, '历史年度原值；口径：四站（三峡、葛洲坝、溪洛渡、向家坝）', 14, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2021';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元'), '2021-12-31', '2021', '全年', 114.98, '历史年度原值；口径：四站（三峡、葛洲坝、溪洛渡、向家坝）', 14, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2022';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元'), '2022-12-31', '2022', '全年', 111.16, '历史年度原值；口径：四站（三峡、葛洲坝、溪洛渡、向家坝）', 14, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2023';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元'), '2023-12-31', '2023', '全年', 192.13, '历史年度原值；口径：六站全口径（新增乌东德、白鹤滩）', 1, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2024';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元'), '2024-12-31', '2024', '全年', 197.8, '历史年度原值；口径：六站全口径（新增乌东德、白鹤滩）', 1, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2025';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元'), '2025-12-31', '2025', '全年', 195.29, '历史年度原值；口径：六站全口径（新增乌东德、白鹤滩）', 1, now());
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '600900.SH' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '财务费用', '亿元', '财务', '报表计算',
       '全年', 1, '财务数据（三大报表）：财务费用', '年', '财务费用'
FROM vi_metric_base WHERE code LIKE '600900.SH.D%';
UPDATE vi_metric_base SET model_field = 'finance_cost' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '财务费用' AND unit IS NOT DISTINCT FROM '亿元');
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '财务费用' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2015';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '财务费用' AND unit IS NOT DISTINCT FROM '亿元'), '2015-12-31', '2015', '全年', 28.5, '历史年度原值（报表算出 87.8110，差异为追溯调整或口径不同）；口径：重组前（三峡、葛洲坝）', 14, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '财务费用' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2022';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '财务费用' AND unit IS NOT DISTINCT FROM '亿元'), '2022-12-31', '2022', '全年', 40.92, '历史年度原值（报表算出 95.8137，差异为追溯调整或口径不同）；口径：四站（三峡、葛洲坝、溪洛渡、向家坝）', 14, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '财务费用' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2023';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '财务费用' AND unit IS NOT DISTINCT FROM '亿元'), '2023-12-31', '2023', '全年', 125.56, '历史年度原值（报表算出 125.6038，差异为追溯调整或口径不同）；口径：六站全口径（新增乌东德、白鹤滩）', 1, now());
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '600900.SH' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '投资收益', '亿元', '财务', '报表计算',
       '全年', 1, '财务数据（三大报表）：投资收益', '年', '投资收益'
FROM vi_metric_base WHERE code LIKE '600900.SH.D%';
UPDATE vi_metric_base SET model_field = 'invest_income' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元');
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '600900.SH' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '权益法投资收益', '亿元', '财务', '报表计算',
       '全年', 1, '财务数据（三大报表）：对联营企业和合营企业的投资收益', '年', '对联营企业和合营企业的投资收益'
FROM vi_metric_base WHERE code LIKE '600900.SH.D%';
UPDATE vi_metric_base SET model_field = 'equity_income' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '权益法投资收益' AND unit IS NOT DISTINCT FROM '亿元');
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '权益法投资收益' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2024';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '权益法投资收益' AND unit IS NOT DISTINCT FROM '亿元'), '2024-12-31', '2024', '全年', 43.56, '历史年度原值（报表算出 48.0616，差异为追溯调整或口径不同）；口径：六站全口径（新增乌东德、白鹤滩）', 1, now());
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '600900.SH' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '经营活动现金流量净额', '亿元', '财务', '报表计算',
       '全年', 1, '财务数据（三大报表）：经营活动产生的现金流量净额', '年', '经营活动产生的现金流量净额'
FROM vi_metric_base WHERE code LIKE '600900.SH.D%';
UPDATE vi_metric_base SET model_field = 'cfo' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '经营活动现金流量净额' AND unit IS NOT DISTINCT FROM '亿元');
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '经营活动现金流量净额' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2015';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '经营活动现金流量净额' AND unit IS NOT DISTINCT FROM '亿元'), '2015-12-31', '2015', '全年', 177.17, '历史年度原值（报表算出 397.9314，差异为追溯调整或口径不同）；口径：重组前（三峡、葛洲坝）', 14, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '经营活动现金流量净额' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2022';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '经营活动现金流量净额' AND unit IS NOT DISTINCT FROM '亿元'), '2022-12-31', '2022', '全年', 309.13, '历史年度原值（报表算出 434.7650，差异为追溯调整或口径不同）；口径：四站（三峡、葛洲坝、溪洛渡、向家坝）', 14, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '经营活动现金流量净额' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2023';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '经营活动现金流量净额' AND unit IS NOT DISTINCT FROM '亿元'), '2023-12-31', '2023', '全年', 647.19, '历史年度原值（报表算出 647.4945，差异为追溯调整或口径不同）；口径：六站全口径（新增乌东德、白鹤滩）', 1, now());
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '600900.SH' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '资本开支', '亿元', '财务', '报表计算',
       '全年', 1, '财务数据（三大报表）：购建固定资产、无形资产和其他长期资产所支付的现金', '年', '购建固定资产、无形资产和其他长期资产所支付的现金'
FROM vi_metric_base WHERE code LIKE '600900.SH.D%';
UPDATE vi_metric_base SET model_field = 'capex' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '资本开支' AND unit IS NOT DISTINCT FROM '亿元');
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '资本开支' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2015';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '资本开支' AND unit IS NOT DISTINCT FROM '亿元'), '2015-12-31', '2015', '全年', 4.6, '历史年度原值（报表算出 48.2454，差异为追溯调整或口径不同）；口径：重组前（三峡、葛洲坝）', 14, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '资本开支' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2022';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '资本开支' AND unit IS NOT DISTINCT FROM '亿元'), '2022-12-31', '2022', '全年', 48.71, '历史年度原值（报表算出 124.6972，差异为追溯调整或口径不同）；口径：四站（三峡、葛洲坝、溪洛渡、向家坝）', 14, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '资本开支' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2023';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '资本开支' AND unit IS NOT DISTINCT FROM '亿元'), '2023-12-31', '2023', '全年', 122.33, '历史年度原值（报表算出 124.1711，差异为追溯调整或口径不同）；口径：六站全口径（新增乌东德、白鹤滩）', 1, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '资本开支' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2024';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '资本开支' AND unit IS NOT DISTINCT FROM '亿元'), '2024-12-31', '2024', '全年', 144.2, '历史年度原值（报表算出 146.3408，差异为追溯调整或口径不同）；口径：六站全口径（新增乌东德、白鹤滩）', 1, now());
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '600900.SH' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '收到投资分红', '亿元', '财务', '报表计算',
       '全年', 1, '财务数据（三大报表）：取得投资收益收到的现金', '年', '取得投资收益收到的现金'
FROM vi_metric_base WHERE code LIKE '600900.SH.D%';
UPDATE vi_metric_base SET model_field = 'investee_cash_div' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '收到投资分红' AND unit IS NOT DISTINCT FROM '亿元');
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '600900.SH' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '净借款', '亿元', '财务', '年报',
       '全年', 1, '年报（原历史年度手录）', '年', NULL
FROM vi_metric_base WHERE code LIKE '600900.SH.D%';
UPDATE vi_metric_base SET model_field = 'net_borrowing' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元');
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2023';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元'), '2023-12-31', '2023', '全年', 295.45, '历史年度原值；口径：六站全口径（新增乌东德、白鹤滩）', 1, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2024';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元'), '2024-12-31', '2024', '全年', -152.22, '历史年度原值；口径：六站全口径（新增乌东德、白鹤滩）', 1, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2025';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元'), '2025-12-31', '2025', '全年', -95.12, '历史年度原值；口径：六站全口径（新增乌东德、白鹤滩）', 1, now());
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '600900.SH' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '带息负债', '亿元', '财务', '年报',
       '时点', 1, '年报（原历史年度手录）', '年', NULL
FROM vi_metric_base WHERE code LIKE '600900.SH.D%';
UPDATE vi_metric_base SET model_field = 'interest_debt' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '带息负债' AND unit IS NOT DISTINCT FROM '亿元');
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '带息负债' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '时点' AND period = '2014Q4';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '带息负债' AND unit IS NOT DISTINCT FROM '亿元'), '2014-12-31', '2014Q4', '时点', 566.33, '历史年度原值；口径：重组前（三峡、葛洲坝）', 14, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '带息负债' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '时点' AND period = '2015Q4';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '带息负债' AND unit IS NOT DISTINCT FROM '亿元'), '2015-12-31', '2015Q4', '时点', 474.62, '历史年度原值；口径：重组前（三峡、葛洲坝）', 14, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '带息负债' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '时点' AND period = '2016Q4';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '带息负债' AND unit IS NOT DISTINCT FROM '亿元'), '2016-12-31', '2016Q4', '时点', 928.27, '历史年度原值；口径：四站（三峡、葛洲坝、溪洛渡、向家坝）', 14, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '带息负债' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '时点' AND period = '2017Q4';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '带息负债' AND unit IS NOT DISTINCT FROM '亿元'), '2017-12-31', '2017Q4', '时点', 981.76, '历史年度原值；口径：四站（三峡、葛洲坝、溪洛渡、向家坝）', 14, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '带息负债' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '时点' AND period = '2018Q4';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '带息负债' AND unit IS NOT DISTINCT FROM '亿元'), '2018-12-31', '2018Q4', '时点', 952.52, '历史年度原值；口径：四站（三峡、葛洲坝、溪洛渡、向家坝）', 14, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '带息负债' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '时点' AND period = '2019Q4';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '带息负债' AND unit IS NOT DISTINCT FROM '亿元'), '2019-12-31', '2019Q4', '时点', 1009.7, '历史年度原值；口径：四站（三峡、葛洲坝、溪洛渡、向家坝）', 14, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '带息负债' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '时点' AND period = '2020Q4';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '带息负债' AND unit IS NOT DISTINCT FROM '亿元'), '2020-12-31', '2020Q4', '时点', 1080.98, '历史年度原值；口径：四站（三峡、葛洲坝、溪洛渡、向家坝）', 14, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '带息负债' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '时点' AND period = '2021Q4';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '带息负债' AND unit IS NOT DISTINCT FROM '亿元'), '2021-12-31', '2021Q4', '时点', 1053.15, '历史年度原值；口径：四站（三峡、葛洲坝、溪洛渡、向家坝）', 14, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '带息负债' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '时点' AND period = '2022Q4';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '带息负债' AND unit IS NOT DISTINCT FROM '亿元'), '2022-12-31', '2022Q4', '时点', 1150.37, '历史年度原值；口径：四站（三峡、葛洲坝、溪洛渡、向家坝）', 14, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '带息负债' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '时点' AND period = '2023Q4';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '带息负债' AND unit IS NOT DISTINCT FROM '亿元'), '2023-12-31', '2023Q4', '时点', 3166.19, '历史年度原值；口径：六站全口径（新增乌东德、白鹤滩）', 1, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '带息负债' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '时点' AND period = '2024Q4';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '带息负债' AND unit IS NOT DISTINCT FROM '亿元'), '2024-12-31', '2024Q4', '时点', 2994.54, '历史年度原值；口径：六站全口径（新增乌东德、白鹤滩）', 1, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '带息负债' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '时点' AND period = '2025Q4';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '带息负债' AND unit IS NOT DISTINCT FROM '亿元'), '2025-12-31', '2025Q4', '时点', 2907.51, '历史年度原值；口径：六站全口径（新增乌东德、白鹤滩）', 1, now());
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '600900.SH' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '货币资金', '亿元', '财务', '年报',
       '时点', 1, '年报（原历史年度手录）', '年', NULL
FROM vi_metric_base WHERE code LIKE '600900.SH.D%';
UPDATE vi_metric_base SET model_field = 'cash' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '货币资金' AND unit IS NOT DISTINCT FROM '亿元');
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '货币资金' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '时点' AND period = '2023Q4';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '货币资金' AND unit IS NOT DISTINCT FROM '亿元'), '2023-12-31', '2023Q4', '时点', 77.78, '历史年度原值；口径：六站全口径（新增乌东德、白鹤滩）', 1, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '货币资金' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '时点' AND period = '2024Q4';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '货币资金' AND unit IS NOT DISTINCT FROM '亿元'), '2024-12-31', '2024Q4', '时点', 65.55, '历史年度原值；口径：六站全口径（新增乌东德、白鹤滩）', 1, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '货币资金' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '时点' AND period = '2025Q4';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '货币资金' AND unit IS NOT DISTINCT FROM '亿元'), '2025-12-31', '2025Q4', '时点', 45.86, '历史年度原值；口径：六站全口径（新增乌东德、白鹤滩）', 1, now());
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '600900.SH' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '归母净资产', '亿元', '财务', '报表计算',
       '时点', 1, '财务数据（三大报表）：归属于母公司股东权益合计', '年', '归属于母公司股东权益合计'
FROM vi_metric_base WHERE code LIKE '600900.SH.D%';
UPDATE vi_metric_base SET model_field = 'equity_parent' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '归母净资产' AND unit IS NOT DISTINCT FROM '亿元');
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '归母净资产' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '时点' AND period = '2018Q4';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '归母净资产' AND unit IS NOT DISTINCT FROM '亿元'), '2018-12-31', '2018Q4', '时点', 1422.25, '历史年度原值（报表算出 1422.0341，差异为追溯调整或口径不同）；口径：四站（三峡、葛洲坝、溪洛渡、向家坝）', 14, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '归母净资产' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '时点' AND period = '2022Q4';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '归母净资产' AND unit IS NOT DISTINCT FROM '亿元'), '2022-12-31', '2022Q4', '时点', 1854.88, '历史年度原值（报表算出 2276.7271，差异为追溯调整或口径不同）；口径：四站（三峡、葛洲坝、溪洛渡、向家坝）', 14, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '归母净资产' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '时点' AND period = '2023Q4';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '归母净资产' AND unit IS NOT DISTINCT FROM '亿元'), '2023-12-31', '2023Q4', '时点', 2013.3, '历史年度原值（报表算出 2014.5334，差异为追溯调整或口径不同）；口径：六站全口径（新增乌东德、白鹤滩）', 1, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '归母净资产' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '时点' AND period = '2024Q4';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '归母净资产' AND unit IS NOT DISTINCT FROM '亿元'), '2024-12-31', '2024Q4', '时点', 2102.88, '历史年度原值（报表算出 2103.4891，差异为追溯调整或口径不同）；口径：六站全口径（新增乌东德、白鹤滩）', 1, now());
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '600900.SH' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '现金分红总额', '亿元', '财务', '年报',
       '全年', 1, '年报（原历史年度手录）', '年', NULL
FROM vi_metric_base WHERE code LIKE '600900.SH.D%';
UPDATE vi_metric_base SET model_field = 'dividend_total' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元');
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2014';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元'), '2014-12-31', '2014', '全年', 62.55, '历史年度原值；口径：重组前（三峡、葛洲坝）', 14, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2015';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元'), '2015-12-31', '2015', '全年', 78.53, '历史年度原值；口径：重组前（三峡、葛洲坝）', 14, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2016';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元'), '2016-12-31', '2016', '全年', 156.88, '历史年度原值；口径：四站（三峡、葛洲坝、溪洛渡、向家坝）', 14, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2017';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元'), '2017-12-31', '2017', '全年', 149.6, '历史年度原值；口径：四站（三峡、葛洲坝、溪洛渡、向家坝）', 14, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2018';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元'), '2018-12-31', '2018', '全年', 149.6, '历史年度原值；口径：四站（三峡、葛洲坝、溪洛渡、向家坝）', 14, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2019';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元'), '2019-12-31', '2019', '全年', 149.6, '历史年度原值；口径：四站（三峡、葛洲坝、溪洛渡、向家坝）', 14, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2020';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元'), '2020-12-31', '2020', '全年', 159.19, '历史年度原值；口径：四站（三峡、葛洲坝、溪洛渡、向家坝）', 14, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2021';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元'), '2021-12-31', '2021', '全年', 185.41, '历史年度原值；口径：四站（三峡、葛洲坝、溪洛渡、向家坝）', 14, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2022';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元'), '2022-12-31', '2022', '全年', 200.92, '历史年度原值；口径：四站（三峡、葛洲坝、溪洛渡、向家坝）', 14, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2023';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元'), '2023-12-31', '2023', '全年', 200.64, '历史年度原值；口径：六站全口径（新增乌东德、白鹤滩）', 1, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2024';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元'), '2024-12-31', '2024', '全年', 230.74, '历史年度原值；口径：六站全口径（新增乌东德、白鹤滩）', 1, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2025';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元'), '2025-12-31', '2025', '全年', 244.68, '历史年度原值；口径：六站全口径（新增乌东德、白鹤滩）', 1, now());
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '600900.SH' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '每股股息', '元', '财务', '年报',
       '全年', 1, '年报（原历史年度手录）', '年', NULL
FROM vi_metric_base WHERE code LIKE '600900.SH.D%';
UPDATE vi_metric_base SET model_field = 'dps' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元');
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元') AND basis = '全年' AND period = '2014';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元'), '2014-12-31', '2014', '全年', 0.3791, '历史年度原值；口径：重组前（三峡、葛洲坝）', 14, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元') AND basis = '全年' AND period = '2017';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元'), '2017-12-31', '2017', '全年', 0.68, '历史年度原值；口径：四站（三峡、葛洲坝、溪洛渡、向家坝）', 14, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元') AND basis = '全年' AND period = '2018';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元'), '2018-12-31', '2018', '全年', 0.68, '历史年度原值；口径：四站（三峡、葛洲坝、溪洛渡、向家坝）', 14, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元') AND basis = '全年' AND period = '2019';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元'), '2019-12-31', '2019', '全年', 0.68, '历史年度原值；口径：四站（三峡、葛洲坝、溪洛渡、向家坝）', 14, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元') AND basis = '全年' AND period = '2020';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元'), '2020-12-31', '2020', '全年', 0.7, '历史年度原值；口径：四站（三峡、葛洲坝、溪洛渡、向家坝）', 14, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元') AND basis = '全年' AND period = '2021';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元'), '2021-12-31', '2021', '全年', 0.8153, '历史年度原值；口径：四站（三峡、葛洲坝、溪洛渡、向家坝）', 14, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元') AND basis = '全年' AND period = '2022';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元'), '2022-12-31', '2022', '全年', 0.8533, '历史年度原值；口径：四站（三峡、葛洲坝、溪洛渡、向家坝）', 14, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元') AND basis = '全年' AND period = '2023';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元'), '2023-12-31', '2023', '全年', 0.82, '历史年度原值；口径：六站全口径（新增乌东德、白鹤滩）', 1, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元') AND basis = '全年' AND period = '2024';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元'), '2024-12-31', '2024', '全年', 0.943, '历史年度原值；口径：六站全口径（新增乌东德、白鹤滩）', 1, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元') AND basis = '全年' AND period = '2025';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元'), '2025-12-31', '2025', '全年', 1, '历史年度原值；口径：六站全口径（新增乌东德、白鹤滩）', 1, now());
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '002078.SZ' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '浆纸销量（纸＋外销浆）', '万吨', '经营', '年报',
       '全年', 2, '年报（原历史年度手录）', '年', NULL
FROM vi_metric_base WHERE code LIKE '002078.SZ.D%';
UPDATE vi_metric_base SET model_field = 'volume' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '浆纸销量（纸＋外销浆）' AND unit IS NOT DISTINCT FROM '万吨');
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '浆纸销量（纸＋外销浆）' AND unit IS NOT DISTINCT FROM '万吨') AND basis = '全年' AND period = '2016';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '浆纸销量（纸＋外销浆）' AND unit IS NOT DISTINCT FROM '万吨'), '2016-12-31', '2016', '全年', 307, '历史年度原值；口径：合并口径', 809, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '浆纸销量（纸＋外销浆）' AND unit IS NOT DISTINCT FROM '万吨') AND basis = '全年' AND period = '2017';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '浆纸销量（纸＋外销浆）' AND unit IS NOT DISTINCT FROM '万吨'), '2017-12-31', '2017', '全年', 360, '历史年度原值；口径：合并口径', 809, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '浆纸销量（纸＋外销浆）' AND unit IS NOT DISTINCT FROM '万吨') AND basis = '全年' AND period = '2019';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '浆纸销量（纸＋外销浆）' AND unit IS NOT DISTINCT FROM '万吨'), '2019-12-31', '2019', '全年', 471, '历史年度原值；口径：合并口径', 810, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '浆纸销量（纸＋外销浆）' AND unit IS NOT DISTINCT FROM '万吨') AND basis = '全年' AND period = '2020';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '浆纸销量（纸＋外销浆）' AND unit IS NOT DISTINCT FROM '万吨'), '2020-12-31', '2020', '全年', 477, '历史年度原值；口径：合并口径', 800, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '浆纸销量（纸＋外销浆）' AND unit IS NOT DISTINCT FROM '万吨') AND basis = '全年' AND period = '2021';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '浆纸销量（纸＋外销浆）' AND unit IS NOT DISTINCT FROM '万吨'), '2021-12-31', '2021', '全年', 630, '历史年度原值；口径：合并口径', 799, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '浆纸销量（纸＋外销浆）' AND unit IS NOT DISTINCT FROM '万吨') AND basis = '全年' AND period = '2022';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '浆纸销量（纸＋外销浆）' AND unit IS NOT DISTINCT FROM '万吨'), '2022-12-31', '2022', '全年', 741, '历史年度原值；口径：合并口径', 798, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '浆纸销量（纸＋外销浆）' AND unit IS NOT DISTINCT FROM '万吨') AND basis = '全年' AND period = '2023';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '浆纸销量（纸＋外销浆）' AND unit IS NOT DISTINCT FROM '万吨'), '2023-12-31', '2023', '全年', 812, '历史年度原值；口径：合并口径', 797, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '浆纸销量（纸＋外销浆）' AND unit IS NOT DISTINCT FROM '万吨') AND basis = '全年' AND period = '2024';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '浆纸销量（纸＋外销浆）' AND unit IS NOT DISTINCT FROM '万吨'), '2024-12-31', '2024', '全年', 897, '历史年度原值；口径：合并口径', 796, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '浆纸销量（纸＋外销浆）' AND unit IS NOT DISTINCT FROM '万吨') AND basis = '全年' AND period = '2025';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '浆纸销量（纸＋外销浆）' AND unit IS NOT DISTINCT FROM '万吨'), '2025-12-31', '2025', '全年', 929, '历史年度原值；口径：合并口径', 795, now());
UPDATE vi_metric_base SET model_field = 'revenue' WHERE id = (SELECT id FROM vi_metric_base WHERE id = 99);
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE id = 99) AND basis = '全年' AND period = '2021';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE id = 99), '2021-12-31', '2021', '全年', 319.97, '历史年度原值（报表算出 321.5916，差异为追溯调整或口径不同）；口径：合并口径', 799, now());
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '002078.SZ' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '营业成本', '亿元', '财务', '报表计算',
       '全年', 2, '财务数据（三大报表）：营业成本', '年', '营业成本'
FROM vi_metric_base WHERE code LIKE '002078.SZ.D%';
UPDATE vi_metric_base SET model_field = 'cost_of_sales' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '营业成本' AND unit IS NOT DISTINCT FROM '亿元');
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '营业成本' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2021';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '营业成本' AND unit IS NOT DISTINCT FROM '亿元'), '2021-12-31', '2021', '全年', 264.38, '历史年度原值（报表算出 266.3165，差异为追溯调整或口径不同）；口径：合并口径', 799, now());
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '002078.SZ' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '利润总额', '亿元', '财务', '报表计算',
       '全年', 2, '财务数据（三大报表）：利润总额', '年', '利润总额'
FROM vi_metric_base WHERE code LIKE '002078.SZ.D%';
UPDATE vi_metric_base SET model_field = 'pretax_profit' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '利润总额' AND unit IS NOT DISTINCT FROM '亿元');
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '利润总额' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2021';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '利润总额' AND unit IS NOT DISTINCT FROM '亿元'), '2021-12-31', '2021', '全年', 33.79, '历史年度原值（报表算出 33.4805，差异为追溯调整或口径不同）；口径：合并口径', 799, now());
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '002078.SZ' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '所得税', '亿元', '财务', '报表计算',
       '全年', 2, '财务数据（三大报表）：所得税费用', '年', '所得税费用'
FROM vi_metric_base WHERE code LIKE '002078.SZ.D%';
UPDATE vi_metric_base SET model_field = 'income_tax' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '所得税' AND unit IS NOT DISTINCT FROM '亿元');
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '所得税' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2021';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '所得税' AND unit IS NOT DISTINCT FROM '亿元'), '2021-12-31', '2021', '全年', 4.12, '历史年度原值（报表算出 4.0881，差异为追溯调整或口径不同）；口径：合并口径', 799, now());
UPDATE vi_metric_base SET model_field = 'np_parent' WHERE id = (SELECT id FROM vi_metric_base WHERE id = 100);
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE id = 100) AND basis = '全年' AND period = '2021';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE id = 100), '2021-12-31', '2021', '全年', 29.57, '历史年度原值（报表算出 29.2940，差异为追溯调整或口径不同）；口径：合并口径', 799, now());
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '002078.SZ' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '少数股东损益', '亿元', '财务', '报表计算',
       '全年', 2, '财务数据（三大报表）：少数股东损益', '年', '少数股东损益'
FROM vi_metric_base WHERE code LIKE '002078.SZ.D%';
UPDATE vi_metric_base SET model_field = 'minority_profit' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '少数股东损益' AND unit IS NOT DISTINCT FROM '亿元');
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '002078.SZ' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '折旧摊销', '亿元', '财务', '年报',
       '全年', 2, '年报（原历史年度手录）', '年', NULL
FROM vi_metric_base WHERE code LIKE '002078.SZ.D%';
UPDATE vi_metric_base SET model_field = 'da' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元');
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2014';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元'), '2014-12-31', '2014', '全年', 7.54, '历史年度原值；口径：合并口径', 810, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2015';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元'), '2015-12-31', '2015', '全年', 7.47, '历史年度原值；口径：合并口径', 810, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2016';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元'), '2016-12-31', '2016', '全年', 8.95, '历史年度原值；口径：合并口径', 809, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2017';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元'), '2017-12-31', '2017', '全年', 9.93, '历史年度原值；口径：合并口径', 809, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2018';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元'), '2018-12-31', '2018', '全年', 11.51, '历史年度原值；口径：合并口径', 810, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2019';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元'), '2019-12-31', '2019', '全年', 14.53, '历史年度原值；口径：合并口径', 810, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2020';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元'), '2020-12-31', '2020', '全年', 14.35, '历史年度原值；口径：合并口径', 800, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2021';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元'), '2021-12-31', '2021', '全年', 17.69, '历史年度原值；口径：合并口径', 799, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2022';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元'), '2022-12-31', '2022', '全年', 21.09, '历史年度原值；口径：合并口径', 798, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2023';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元'), '2023-12-31', '2023', '全年', 21.81, '历史年度原值；口径：合并口径', 797, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2024';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元'), '2024-12-31', '2024', '全年', 23.86, '历史年度原值；口径：合并口径', 796, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2025';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元'), '2025-12-31', '2025', '全年', 24.98, '历史年度原值；口径：合并口径', 795, now());
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '002078.SZ' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '财务费用', '亿元', '财务', '报表计算',
       '全年', 2, '财务数据（三大报表）：财务费用', '年', '财务费用'
FROM vi_metric_base WHERE code LIKE '002078.SZ.D%';
UPDATE vi_metric_base SET model_field = 'finance_cost' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '财务费用' AND unit IS NOT DISTINCT FROM '亿元');
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '002078.SZ' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '投资收益', '亿元', '财务', '报表计算',
       '全年', 2, '财务数据（三大报表）：投资收益', '年', '投资收益'
FROM vi_metric_base WHERE code LIKE '002078.SZ.D%';
UPDATE vi_metric_base SET model_field = 'invest_income' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元');
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '002078.SZ' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '权益法投资收益', '亿元', '财务', '报表计算',
       '全年', 2, '财务数据（三大报表）：对联营企业和合营企业的投资收益', '年', '对联营企业和合营企业的投资收益'
FROM vi_metric_base WHERE code LIKE '002078.SZ.D%';
UPDATE vi_metric_base SET model_field = 'equity_income' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '权益法投资收益' AND unit IS NOT DISTINCT FROM '亿元');
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '002078.SZ' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '经营活动现金流量净额', '亿元', '财务', '报表计算',
       '全年', 2, '财务数据（三大报表）：经营活动产生的现金流量净额', '年', '经营活动产生的现金流量净额'
FROM vi_metric_base WHERE code LIKE '002078.SZ.D%';
UPDATE vi_metric_base SET model_field = 'cfo' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '经营活动现金流量净额' AND unit IS NOT DISTINCT FROM '亿元');
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '经营活动现金流量净额' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2017';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '经营活动现金流量净额' AND unit IS NOT DISTINCT FROM '亿元'), '2017-12-31', '2017', '全年', 37.67, '历史年度原值（报表算出 38.5320，差异为追溯调整或口径不同）；口径：合并口径', 809, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '经营活动现金流量净额' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2021';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '经营活动现金流量净额' AND unit IS NOT DISTINCT FROM '亿元'), '2021-12-31', '2021', '全年', 49.29, '历史年度原值（报表算出 48.9846，差异为追溯调整或口径不同）；口径：合并口径', 799, now());
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '002078.SZ' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '资本开支', '亿元', '财务', '报表计算',
       '全年', 2, '财务数据（三大报表）：购建固定资产、无形资产和其他长期资产所支付的现金', '年', '购建固定资产、无形资产和其他长期资产所支付的现金'
FROM vi_metric_base WHERE code LIKE '002078.SZ.D%';
UPDATE vi_metric_base SET model_field = 'capex' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '资本开支' AND unit IS NOT DISTINCT FROM '亿元');
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '资本开支' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2021';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '资本开支' AND unit IS NOT DISTINCT FROM '亿元'), '2021-12-31', '2021', '全年', 72.49, '历史年度原值（报表算出 72.1812，差异为追溯调整或口径不同）；口径：合并口径', 799, now());
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '002078.SZ' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '收到投资分红', '亿元', '财务', '报表计算',
       '全年', 2, '财务数据（三大报表）：取得投资收益收到的现金', '年', '取得投资收益收到的现金'
FROM vi_metric_base WHERE code LIKE '002078.SZ.D%';
UPDATE vi_metric_base SET model_field = 'investee_cash_div' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '收到投资分红' AND unit IS NOT DISTINCT FROM '亿元');
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '002078.SZ' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '净借款', '亿元', '财务', '报表计算',
       '全年', 2, '财务数据（三大报表）：取得借款收到的现金 − 偿还债务支付的现金', '年', '取得借款收到的现金 − 偿还债务支付的现金'
FROM vi_metric_base WHERE code LIKE '002078.SZ.D%';
UPDATE vi_metric_base SET model_field = 'net_borrowing' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元');
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2022';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元'), '2022-12-31', '2022', '全年', 24.9, '历史年度原值（报表算出 24.9063，差异为追溯调整或口径不同）；口径：合并口径', 798, now());
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '002078.SZ' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '带息负债', '亿元', '财务', '报表计算',
       '时点', 2, '财务数据（三大报表）：短期借款 + 一年内到期的非流动负债 + 长期借款 + 应付债券 + 租赁负债', '年', '短期借款 + 一年内到期的非流动负债 + 长期借款 + 应付债券 + 租赁负债'
FROM vi_metric_base WHERE code LIKE '002078.SZ.D%';
UPDATE vi_metric_base SET model_field = 'interest_debt' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '带息负债' AND unit IS NOT DISTINCT FROM '亿元');
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '带息负债' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '时点' AND period = '2014Q4';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '带息负债' AND unit IS NOT DISTINCT FROM '亿元'), '2014-12-31', '2014Q4', '时点', 72.67, '历史年度原值（报表算出 72.6399，差异为追溯调整或口径不同）；口径：合并口径', 810, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '带息负债' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '时点' AND period = '2017Q4';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '带息负债' AND unit IS NOT DISTINCT FROM '亿元'), '2017-12-31', '2017Q4', '时点', 99.76, '历史年度原值（报表算出 99.6267，差异为追溯调整或口径不同）；口径：合并口径', 809, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '带息负债' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '时点' AND period = '2020Q4';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '带息负债' AND unit IS NOT DISTINCT FROM '亿元'), '2020-12-31', '2020Q4', '时点', 132.19, '历史年度原值（报表算出 132.1197，差异为追溯调整或口径不同）；口径：合并口径', 800, now());
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '002078.SZ' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '货币资金', '亿元', '财务', '报表计算',
       '时点', 2, '财务数据（三大报表）：货币资金', '年', '货币资金'
FROM vi_metric_base WHERE code LIKE '002078.SZ.D%';
UPDATE vi_metric_base SET model_field = 'cash' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '货币资金' AND unit IS NOT DISTINCT FROM '亿元');
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '002078.SZ' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '归母净资产', '亿元', '财务', '报表计算',
       '时点', 2, '财务数据（三大报表）：归属于母公司股东权益合计', '年', '归属于母公司股东权益合计'
FROM vi_metric_base WHERE code LIKE '002078.SZ.D%';
UPDATE vi_metric_base SET model_field = 'equity_parent' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '归母净资产' AND unit IS NOT DISTINCT FROM '亿元');
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '归母净资产' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '时点' AND period = '2021Q4';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '归母净资产' AND unit IS NOT DISTINCT FROM '亿元'), '2021-12-31', '2021Q4', '时点', 187.33, '历史年度原值（报表算出 187.0550，差异为追溯调整或口径不同）；口径：合并口径', 799, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '归母净资产' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '时点' AND period = '2022Q4';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '归母净资产' AND unit IS NOT DISTINCT FROM '亿元'), '2022-12-31', '2022Q4', '时点', 230.84, '历史年度原值（报表算出 230.8499，差异为追溯调整或口径不同）；口径：合并口径', 798, now());
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '002078.SZ' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '现金分红总额', '亿元', '财务', '年报',
       '全年', 2, '年报（原历史年度手录）', '年', NULL
FROM vi_metric_base WHERE code LIKE '002078.SZ.D%';
UPDATE vi_metric_base SET model_field = 'dividend_total' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元');
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2014';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元'), '2014-12-31', '2014', '全年', 1.27, '历史年度原值；口径：合并口径', 810, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2015';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元'), '2015-12-31', '2015', '全年', 1.27, '历史年度原值；口径：合并口径', 810, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2016';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元'), '2016-12-31', '2016', '全年', 1.27, '历史年度原值；口径：合并口径', 809, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2017';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元'), '2017-12-31', '2017', '全年', 2.59, '历史年度原值；口径：合并口径', 809, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2018';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元'), '2018-12-31', '2018', '全年', 2.59, '历史年度原值；口径：合并口径', 810, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2019';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元'), '2019-12-31', '2019', '全年', 2.59, '历史年度原值；口径：合并口径', 810, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2020';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元'), '2020-12-31', '2020', '全年', 2.62, '历史年度原值；口径：合并口径', 800, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2021';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元'), '2021-12-31', '2021', '全年', 5.37, '历史年度原值；口径：合并口径', 799, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2022';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元'), '2022-12-31', '2022', '全年', 5.59, '历史年度原值；口径：合并口径', 798, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2023';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元'), '2023-12-31', '2023', '全年', 8.38, '历史年度原值；口径：合并口径', 797, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2024';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元'), '2024-12-31', '2024', '全年', 8.38, '历史年度原值；口径：合并口径', 796, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2025';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元'), '2025-12-31', '2025', '全年', 8.38, '历史年度原值；口径：合并口径', 795, now());
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '002078.SZ' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '每股股息', '元', '财务', '年报',
       '全年', 2, '年报（原历史年度手录）', '年', NULL
FROM vi_metric_base WHERE code LIKE '002078.SZ.D%';
UPDATE vi_metric_base SET model_field = 'dps' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元');
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元') AND basis = '全年' AND period = '2014';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元'), '2014-12-31', '2014', '全年', 0.05, '历史年度原值；口径：合并口径', 810, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元') AND basis = '全年' AND period = '2015';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元'), '2015-12-31', '2015', '全年', 0.05, '历史年度原值；口径：合并口径', 810, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元') AND basis = '全年' AND period = '2016';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元'), '2016-12-31', '2016', '全年', 0.05, '历史年度原值；口径：合并口径', 809, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元') AND basis = '全年' AND period = '2017';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元'), '2017-12-31', '2017', '全年', 0.1, '历史年度原值；口径：合并口径', 809, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元') AND basis = '全年' AND period = '2018';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元'), '2018-12-31', '2018', '全年', 0.1, '历史年度原值；口径：合并口径', 810, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元') AND basis = '全年' AND period = '2019';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元'), '2019-12-31', '2019', '全年', 0.1, '历史年度原值；口径：合并口径', 810, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元') AND basis = '全年' AND period = '2020';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元'), '2020-12-31', '2020', '全年', 0.1, '历史年度原值；口径：合并口径', 800, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元') AND basis = '全年' AND period = '2021';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元'), '2021-12-31', '2021', '全年', 0.2, '历史年度原值；口径：合并口径', 799, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元') AND basis = '全年' AND period = '2022';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元'), '2022-12-31', '2022', '全年', 0.2, '历史年度原值；口径：合并口径', 798, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元') AND basis = '全年' AND period = '2023';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元'), '2023-12-31', '2023', '全年', 0.3, '历史年度原值；口径：合并口径', 797, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元') AND basis = '全年' AND period = '2024';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元'), '2024-12-31', '2024', '全年', 0.3, '历史年度原值；口径：合并口径', 796, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元') AND basis = '全年' AND period = '2025';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 2 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元'), '2025-12-31', '2025', '全年', 0.3, '历史年度原值；口径：合并口径', 795, now());
UPDATE vi_metric_base SET model_field = 'volume' WHERE id = (SELECT id FROM vi_metric_base WHERE id = 190);
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE id = 190) AND basis = '全年' AND period = '2017';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE id = 190), '2017-12-31', '2017', '全年', 24535, '历史年度原值；口径：合并口径', 876, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE id = 190) AND basis = '全年' AND period = '2018';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE id = 190), '2018-12-31', '2018', '全年', 26271, '历史年度原值；口径：合并口径', 876, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE id = 190) AND basis = '全年' AND period = '2019';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE id = 190), '2019-12-31', '2019', '全年', 28687, '历史年度原值；口径：合并口径', 876, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE id = 190) AND basis = '全年' AND period = '2020';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE id = 190), '2020-12-31', '2020', '全年', 32008, '历史年度原值；口径：合并口径', 876, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE id = 190) AND basis = '全年' AND period = '2021';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE id = 190), '2021-12-31', '2021', '全年', 35300, '历史年度原值；口径：合并口径', 876, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE id = 190) AND basis = '全年' AND period = '2022';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE id = 190), '2022-12-31', '2022', '全年', 39031, '历史年度原值；口径：合并口径', 866, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE id = 190) AND basis = '全年' AND period = '2023';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE id = 190), '2023-12-31', '2023', '全年', 43241, '历史年度原值；口径：合并口径', 866, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE id = 190) AND basis = '全年' AND period = '2024';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE id = 190), '2024-12-31', '2024', '全年', 45027, '历史年度原值；口径：合并口径', 865, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE id = 190) AND basis = '全年' AND period = '2025';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE id = 190), '2025-12-31', '2025', '全年', 45458, '历史年度原值；口径：合并口径', 865, now());
UPDATE vi_metric_base SET model_field = 'revenue' WHERE id = (SELECT id FROM vi_metric_base WHERE id = 103);
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '601668.SH' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '营业成本', '亿元', '财务', '报表计算',
       '全年', 7, '财务数据（三大报表）：营业成本', '年', '营业成本'
FROM vi_metric_base WHERE code LIKE '601668.SH.D%';
UPDATE vi_metric_base SET model_field = 'cost_of_sales' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '营业成本' AND unit IS NOT DISTINCT FROM '亿元');
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '601668.SH' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '利润总额', '亿元', '财务', '报表计算',
       '全年', 7, '财务数据（三大报表）：利润总额', '年', '利润总额'
FROM vi_metric_base WHERE code LIKE '601668.SH.D%';
UPDATE vi_metric_base SET model_field = 'pretax_profit' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '利润总额' AND unit IS NOT DISTINCT FROM '亿元');
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '601668.SH' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '所得税', '亿元', '财务', '报表计算',
       '全年', 7, '财务数据（三大报表）：所得税费用', '年', '所得税费用'
FROM vi_metric_base WHERE code LIKE '601668.SH.D%';
UPDATE vi_metric_base SET model_field = 'income_tax' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '所得税' AND unit IS NOT DISTINCT FROM '亿元');
UPDATE vi_metric_base SET model_field = 'np_parent' WHERE id = (SELECT id FROM vi_metric_base WHERE id = 104);
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '601668.SH' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '少数股东损益', '亿元', '财务', '报表计算',
       '全年', 7, '财务数据（三大报表）：少数股东损益', '年', '少数股东损益'
FROM vi_metric_base WHERE code LIKE '601668.SH.D%';
UPDATE vi_metric_base SET model_field = 'minority_profit' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '少数股东损益' AND unit IS NOT DISTINCT FROM '亿元');
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '601668.SH' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '折旧摊销', '亿元', '财务', '年报',
       '全年', 7, '年报（原历史年度手录）', '年', NULL
FROM vi_metric_base WHERE code LIKE '601668.SH.D%';
UPDATE vi_metric_base SET model_field = 'da' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元');
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2014';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元'), '2014-12-31', '2014', '全年', 58.92, '历史年度原值；口径：合并口径', 876, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2015';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元'), '2015-12-31', '2015', '全年', 70.53, '历史年度原值；口径：合并口径', 876, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2016';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元'), '2016-12-31', '2016', '全年', 76.24, '历史年度原值；口径：合并口径', 876, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2017';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元'), '2017-12-31', '2017', '全年', 89.22, '历史年度原值；口径：合并口径', 876, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2018';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元'), '2018-12-31', '2018', '全年', 101.9, '历史年度原值；口径：合并口径', 876, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2019';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元'), '2019-12-31', '2019', '全年', 107.66, '历史年度原值；口径：合并口径', 876, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2020';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元'), '2020-12-31', '2020', '全年', 112.11, '历史年度原值；口径：合并口径', 876, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2021';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元'), '2021-12-31', '2021', '全年', 145.03, '历史年度原值；口径：合并口径', 876, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2022';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元'), '2022-12-31', '2022', '全年', 165.41, '历史年度原值；口径：合并口径', 866, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2023';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元'), '2023-12-31', '2023', '全年', 186.35, '历史年度原值；口径：合并口径', 866, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2024';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元'), '2024-12-31', '2024', '全年', 189.52, '历史年度原值；口径：合并口径', 865, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2025';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元'), '2025-12-31', '2025', '全年', 192.01, '历史年度原值；口径：合并口径', 865, now());
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '601668.SH' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '财务费用', '亿元', '财务', '报表计算',
       '全年', 7, '财务数据（三大报表）：财务费用', '年', '财务费用'
FROM vi_metric_base WHERE code LIKE '601668.SH.D%';
UPDATE vi_metric_base SET model_field = 'finance_cost' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '财务费用' AND unit IS NOT DISTINCT FROM '亿元');
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '601668.SH' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '投资收益', '亿元', '财务', '报表计算',
       '全年', 7, '财务数据（三大报表）：投资收益', '年', '投资收益'
FROM vi_metric_base WHERE code LIKE '601668.SH.D%';
UPDATE vi_metric_base SET model_field = 'invest_income' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元');
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '601668.SH' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '权益法投资收益', '亿元', '财务', '报表计算',
       '全年', 7, '财务数据（三大报表）：对联营企业和合营企业的投资收益', '年', '对联营企业和合营企业的投资收益'
FROM vi_metric_base WHERE code LIKE '601668.SH.D%';
UPDATE vi_metric_base SET model_field = 'equity_income' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '权益法投资收益' AND unit IS NOT DISTINCT FROM '亿元');
UPDATE vi_metric_base SET model_field = 'cfo' WHERE id = (SELECT id FROM vi_metric_base WHERE id = 185);
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '601668.SH' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '资本开支', '亿元', '财务', '报表计算',
       '全年', 7, '财务数据（三大报表）：购建固定资产、无形资产和其他长期资产所支付的现金', '年', '购建固定资产、无形资产和其他长期资产所支付的现金'
FROM vi_metric_base WHERE code LIKE '601668.SH.D%';
UPDATE vi_metric_base SET model_field = 'capex' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '资本开支' AND unit IS NOT DISTINCT FROM '亿元');
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '601668.SH' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '收到投资分红', '亿元', '财务', '报表计算',
       '全年', 7, '财务数据（三大报表）：取得投资收益收到的现金', '年', '取得投资收益收到的现金'
FROM vi_metric_base WHERE code LIKE '601668.SH.D%';
UPDATE vi_metric_base SET model_field = 'investee_cash_div' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '收到投资分红' AND unit IS NOT DISTINCT FROM '亿元');
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '601668.SH' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '净借款', '亿元', '财务', '报表计算',
       '全年', 7, '财务数据（三大报表）：取得借款收到的现金 + 发行债券收到的现金 − 偿还债务支付的现金', '年', '取得借款收到的现金 + 发行债券收到的现金 − 偿还债务支付的现金'
FROM vi_metric_base WHERE code LIKE '601668.SH.D%';
UPDATE vi_metric_base SET model_field = 'net_borrowing' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元');
UPDATE vi_metric_base SET model_field = 'interest_debt' WHERE id = (SELECT id FROM vi_metric_base WHERE id = 188);
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '601668.SH' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '货币资金', '亿元', '财务', '报表计算',
       '时点', 7, '财务数据（三大报表）：货币资金', '年', '货币资金'
FROM vi_metric_base WHERE code LIKE '601668.SH.D%';
UPDATE vi_metric_base SET model_field = 'cash' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '货币资金' AND unit IS NOT DISTINCT FROM '亿元');
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '601668.SH' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '归母净资产', '亿元', '财务', '年报',
       '时点', 7, '年报（原历史年度手录）', '年', NULL
FROM vi_metric_base WHERE code LIKE '601668.SH.D%';
UPDATE vi_metric_base SET model_field = 'equity_parent' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '归母净资产' AND unit IS NOT DISTINCT FROM '亿元');
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '归母净资产' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '时点' AND period = '2014Q4';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '归母净资产' AND unit IS NOT DISTINCT FROM '亿元'), '2014-12-31', '2014Q4', '时点', 1370.23, '历史年度原值；口径：合并口径', 876, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '归母净资产' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '时点' AND period = '2015Q4';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '归母净资产' AND unit IS NOT DISTINCT FROM '亿元'), '2015-12-31', '2015Q4', '时点', 1510.05, '历史年度原值；口径：合并口径', 876, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '归母净资产' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '时点' AND period = '2016Q4';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '归母净资产' AND unit IS NOT DISTINCT FROM '亿元'), '2016-12-31', '2016Q4', '时点', 1735.18, '历史年度原值；口径：合并口径', 876, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '归母净资产' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '时点' AND period = '2017Q4';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '归母净资产' AND unit IS NOT DISTINCT FROM '亿元'), '2017-12-31', '2017Q4', '时点', 1977.83, '历史年度原值；口径：合并口径', 876, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '归母净资产' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '时点' AND period = '2018Q4';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '归母净资产' AND unit IS NOT DISTINCT FROM '亿元'), '2018-12-31', '2018Q4', '时点', 2209.89, '历史年度原值；口径：合并口径', 876, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '归母净资产' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '时点' AND period = '2019Q4';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '归母净资产' AND unit IS NOT DISTINCT FROM '亿元'), '2019-12-31', '2019Q4', '时点', 2562.22, '历史年度原值；口径：合并口径', 876, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '归母净资产' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '时点' AND period = '2020Q4';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '归母净资产' AND unit IS NOT DISTINCT FROM '亿元'), '2020-12-31', '2020Q4', '时点', 2904.63, '历史年度原值；口径：合并口径', 876, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '归母净资产' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '时点' AND period = '2021Q4';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '归母净资产' AND unit IS NOT DISTINCT FROM '亿元'), '2021-12-31', '2021Q4', '时点', 3356.28, '历史年度原值；口径：合并口径', 876, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '归母净资产' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '时点' AND period = '2022Q4';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '归母净资产' AND unit IS NOT DISTINCT FROM '亿元'), '2022-12-31', '2022Q4', '时点', 3743.22, '历史年度原值；口径：合并口径', 866, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '归母净资产' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '时点' AND period = '2023Q4';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '归母净资产' AND unit IS NOT DISTINCT FROM '亿元'), '2023-12-31', '2023Q4', '时点', 4184.78, '历史年度原值；口径：合并口径', 866, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '归母净资产' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '时点' AND period = '2024Q4';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '归母净资产' AND unit IS NOT DISTINCT FROM '亿元'), '2024-12-31', '2024Q4', '时点', 4534.98, '历史年度原值；口径：合并口径', 865, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '归母净资产' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '时点' AND period = '2025Q4';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '归母净资产' AND unit IS NOT DISTINCT FROM '亿元'), '2025-12-31', '2025Q4', '时点', 4825.56, '历史年度原值；口径：合并口径', 865, now());
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '601668.SH' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '现金分红总额', '亿元', '财务', '年报',
       '全年', 7, '年报（原历史年度手录）', '年', NULL
FROM vi_metric_base WHERE code LIKE '601668.SH.D%';
UPDATE vi_metric_base SET model_field = 'dividend_total' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元');
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2014';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元'), '2014-12-31', '2014', '全年', 51.6, '历史年度原值；口径：合并口径', 876, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2015';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元'), '2015-12-31', '2015', '全年', 60, '历史年度原值；口径：合并口径', 876, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2016';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元'), '2016-12-31', '2016', '全年', 64.5, '历史年度原值；口径：合并口径', 876, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2017';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元'), '2017-12-31', '2017', '全年', 64.48, '历史年度原值；口径：合并口径', 876, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2018';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元'), '2018-12-31', '2018', '全年', 70.53, '历史年度原值；口径：合并口径', 876, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2019';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元'), '2019-12-31', '2019', '全年', 77.64, '历史年度原值；口径：合并口径', 876, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2020';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元'), '2020-12-31', '2020', '全年', 90.06, '历史年度原值；口径：合并口径', 876, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2021';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元'), '2021-12-31', '2021', '全年', 104.85, '历史年度原值；口径：合并口径', 876, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2022';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元'), '2022-12-31', '2022', '全年', 105.97, '历史年度原值；口径：合并口径', 866, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2023';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元'), '2023-12-31', '2023', '全年', 112.98, '历史年度原值；口径：合并口径', 866, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2024';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元'), '2024-12-31', '2024', '全年', 112.18, '历史年度原值；口径：合并口径', 865, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2025';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 7 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元'), '2025-12-31', '2025', '全年', 112.31, '历史年度原值；口径：合并口径', 865, now());
UPDATE vi_metric_base SET model_field = 'dps' WHERE id = (SELECT id FROM vi_metric_base WHERE id = 195);
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE id = 195) AND basis = '全年' AND period = '2014';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE id = 195), '2014-12-31', '2014', '全年', 0.172, '历史年度原值；口径：合并口径', 876, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE id = 195) AND basis = '全年' AND period = '2015';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE id = 195), '2015-12-31', '2015', '全年', 0.2, '历史年度原值；口径：合并口径', 876, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE id = 195) AND basis = '全年' AND period = '2016';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE id = 195), '2016-12-31', '2016', '全年', 0.215, '历史年度原值；口径：合并口径', 876, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE id = 195) AND basis = '全年' AND period = '2017';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE id = 195), '2017-12-31', '2017', '全年', 0.215, '历史年度原值；口径：合并口径', 876, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE id = 195) AND basis = '全年' AND period = '2018';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE id = 195), '2018-12-31', '2018', '全年', 0.168, '历史年度原值；口径：合并口径', 876, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE id = 195) AND basis = '全年' AND period = '2019';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE id = 195), '2019-12-31', '2019', '全年', 0.185, '历史年度原值；口径：合并口径', 876, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE id = 195) AND basis = '全年' AND period = '2020';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE id = 195), '2020-12-31', '2020', '全年', 0.2147, '历史年度原值；口径：合并口径', 876, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE id = 195) AND basis = '全年' AND period = '2021';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE id = 195), '2021-12-31', '2021', '全年', 0.25, '历史年度原值；口径：合并口径', 876, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE id = 195) AND basis = '全年' AND period = '2022';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE id = 195), '2022-12-31', '2022', '全年', 0.2527, '历史年度原值；口径：合并口径', 866, now());
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '01698.HK' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '在线音乐付费用户（第四季度，2026 年起为年末音乐服务付费用户）', '亿人', '经营', '年报',
       '全年', 11, '年报（原历史年度手录）', '年', NULL
FROM vi_metric_base WHERE code LIKE '01698.HK.D%';
UPDATE vi_metric_base SET model_field = 'volume' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '在线音乐付费用户（第四季度，2026 年起为年末音乐服务付费用户）' AND unit IS NOT DISTINCT FROM '亿人');
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '在线音乐付费用户（第四季度，2026 年起为年末音乐服务付费用户）' AND unit IS NOT DISTINCT FROM '亿人') AND basis = '全年' AND period = '2021';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '在线音乐付费用户（第四季度，2026 年起为年末音乐服务付费用户）' AND unit IS NOT DISTINCT FROM '亿人'), '2021-12-31', '2021', '全年', 0.762, '历史年度原值；口径：合并口径', 641, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '在线音乐付费用户（第四季度，2026 年起为年末音乐服务付费用户）' AND unit IS NOT DISTINCT FROM '亿人') AND basis = '全年' AND period = '2022';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '在线音乐付费用户（第四季度，2026 年起为年末音乐服务付费用户）' AND unit IS NOT DISTINCT FROM '亿人'), '2022-12-31', '2022', '全年', 0.885, '历史年度原值；口径：合并口径', 641, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '在线音乐付费用户（第四季度，2026 年起为年末音乐服务付费用户）' AND unit IS NOT DISTINCT FROM '亿人') AND basis = '全年' AND period = '2023';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '在线音乐付费用户（第四季度，2026 年起为年末音乐服务付费用户）' AND unit IS NOT DISTINCT FROM '亿人'), '2023-12-31', '2023', '全年', 1.067, '历史年度原值；口径：合并口径', 641, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '在线音乐付费用户（第四季度，2026 年起为年末音乐服务付费用户）' AND unit IS NOT DISTINCT FROM '亿人') AND basis = '全年' AND period = '2024';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '在线音乐付费用户（第四季度，2026 年起为年末音乐服务付费用户）' AND unit IS NOT DISTINCT FROM '亿人'), '2024-12-31', '2024', '全年', 1.21, '历史年度原值；口径：合并口径', 629, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '在线音乐付费用户（第四季度，2026 年起为年末音乐服务付费用户）' AND unit IS NOT DISTINCT FROM '亿人') AND basis = '全年' AND period = '2025';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '在线音乐付费用户（第四季度，2026 年起为年末音乐服务付费用户）' AND unit IS NOT DISTINCT FROM '亿人'), '2025-12-31', '2025', '全年', 1.274, '历史年度原值；口径：合并口径', 629, now());
UPDATE vi_metric_base SET model_field = 'revenue' WHERE id = (SELECT id FROM vi_metric_base WHERE id = 118);
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE id = 118) AND basis = '全年' AND period = '2017';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE id = 118), '2017-12-31', '2017', '全年', 109.81, '历史年度原值；口径：合并口径', 641, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE id = 118) AND basis = '全年' AND period = '2018';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE id = 118), '2018-12-31', '2018', '全年', 189.85, '历史年度原值；口径：合并口径', 641, now());
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '01698.HK' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '营业成本', '亿元', '财务', '报表计算',
       '全年', 11, '财务数据（三大报表）：营业额 − 毛利', '年', '营业额 − 毛利'
FROM vi_metric_base WHERE code LIKE '01698.HK.D%';
UPDATE vi_metric_base SET model_field = 'cost_of_sales' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '营业成本' AND unit IS NOT DISTINCT FROM '亿元');
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '营业成本' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2017';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '营业成本' AND unit IS NOT DISTINCT FROM '亿元'), '2017-12-31', '2017', '全年', 71.71, '历史年度原值；口径：合并口径', 641, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '营业成本' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2018';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '营业成本' AND unit IS NOT DISTINCT FROM '亿元'), '2018-12-31', '2018', '全年', 117.08, '历史年度原值；口径：合并口径', 641, now());
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '01698.HK' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '利润总额', '亿元', '财务', '报表计算',
       '全年', 11, '财务数据（三大报表）：除税前溢利', '年', '除税前溢利'
FROM vi_metric_base WHERE code LIKE '01698.HK.D%';
UPDATE vi_metric_base SET model_field = 'pretax_profit' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '利润总额' AND unit IS NOT DISTINCT FROM '亿元');
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '利润总额' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2017';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '利润总额' AND unit IS NOT DISTINCT FROM '亿元'), '2017-12-31', '2017', '全年', 15.97, '历史年度原值；口径：合并口径', 641, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '利润总额' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2018';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '利润总额' AND unit IS NOT DISTINCT FROM '亿元'), '2018-12-31', '2018', '全年', 20.03, '历史年度原值；口径：合并口径', 641, now());
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '01698.HK' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '所得税', '亿元', '财务', '报表计算',
       '全年', 11, '财务数据（三大报表）：税项', '年', '税项'
FROM vi_metric_base WHERE code LIKE '01698.HK.D%';
UPDATE vi_metric_base SET model_field = 'income_tax' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '所得税' AND unit IS NOT DISTINCT FROM '亿元');
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '所得税' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2017';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '所得税' AND unit IS NOT DISTINCT FROM '亿元'), '2017-12-31', '2017', '全年', 2.78, '历史年度原值；口径：合并口径', 641, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '所得税' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2018';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '所得税' AND unit IS NOT DISTINCT FROM '亿元'), '2018-12-31', '2018', '全年', 1.71, '历史年度原值；口径：合并口径', 641, now());
UPDATE vi_metric_base SET model_field = 'np_parent' WHERE id = (SELECT id FROM vi_metric_base WHERE id = 124);
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE id = 124) AND basis = '全年' AND period = '2017';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE id = 124), '2017-12-31', '2017', '全年', 13.26, '历史年度原值；口径：合并口径', 641, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE id = 124) AND basis = '全年' AND period = '2018';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE id = 124), '2018-12-31', '2018', '全年', 18.33, '历史年度原值；口径：合并口径', 641, now());
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '01698.HK' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '少数股东损益', '亿元', '财务', '报表计算',
       '全年', 11, '财务数据（三大报表）：少数股东损益', '年', '少数股东损益'
FROM vi_metric_base WHERE code LIKE '01698.HK.D%';
UPDATE vi_metric_base SET model_field = 'minority_profit' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '少数股东损益' AND unit IS NOT DISTINCT FROM '亿元');
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '少数股东损益' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2017';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '少数股东损益' AND unit IS NOT DISTINCT FROM '亿元'), '2017-12-31', '2017', '全年', -0.07, '历史年度原值；口径：合并口径', 641, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '少数股东损益' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2018';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '少数股东损益' AND unit IS NOT DISTINCT FROM '亿元'), '2018-12-31', '2018', '全年', -0.01, '历史年度原值；口径：合并口径', 641, now());
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '01698.HK' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '折旧摊销', '亿元', '财务', '报表计算',
       '全年', 11, '财务数据（三大报表）：加:折旧及摊销', '年', '加:折旧及摊销'
FROM vi_metric_base WHERE code LIKE '01698.HK.D%';
UPDATE vi_metric_base SET model_field = 'da' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元');
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2017';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元'), '2017-12-31', '2017', '全年', 3.79, '历史年度原值；口径：合并口径', 641, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2018';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元'), '2018-12-31', '2018', '全年', 3.69, '历史年度原值；口径：合并口径', 641, now());
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '01698.HK' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '财务费用', '亿元', '财务', '报表计算',
       '全年', 11, '财务数据（三大报表）：融资成本', '年', '融资成本'
FROM vi_metric_base WHERE code LIKE '01698.HK.D%';
UPDATE vi_metric_base SET model_field = 'finance_cost' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '财务费用' AND unit IS NOT DISTINCT FROM '亿元');
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '财务费用' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2018';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '财务费用' AND unit IS NOT DISTINCT FROM '亿元'), '2018-12-31', '2018', '全年', 0.35, '历史年度原值；口径：合并口径', 641, now());
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '01698.HK' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '投资收益', '亿元', '财务', '年报',
       '全年', 11, '年报（原历史年度手录）', '年', NULL
FROM vi_metric_base WHERE code LIKE '01698.HK.D%';
UPDATE vi_metric_base SET model_field = 'invest_income' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元');
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2017';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元'), '2017-12-31', '2017', '全年', 2.17, '历史年度原值；口径：合并口径', 641, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2018';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元'), '2018-12-31', '2018', '全年', -12.66, '历史年度原值；口径：合并口径', 641, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2019';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元'), '2019-12-31', '2019', '全年', 6.93, '历史年度原值；口径：合并口径', 641, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2020';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元'), '2020-12-31', '2020', '全年', 9.84, '历史年度原值；口径：合并口径', 641, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2021';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元'), '2021-12-31', '2021', '全年', 10.83, '历史年度原值；口径：合并口径', 641, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2022';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元'), '2022-12-31', '2022', '全年', 12.27, '历史年度原值；口径：合并口径', 641, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2023';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元'), '2023-12-31', '2023', '全年', 12.82, '历史年度原值；口径：合并口径', 641, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2024';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元'), '2024-12-31', '2024', '全年', 13.61, '历史年度原值；口径：合并口径', 629, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2025';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元'), '2025-12-31', '2025', '全年', 36.86, '历史年度原值；口径：合并口径', 629, now());
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '01698.HK' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '权益法投资收益', '亿元', '财务', '报表计算',
       '全年', 11, '财务数据（三大报表）：应占联营公司溢利', '年', '应占联营公司溢利'
FROM vi_metric_base WHERE code LIKE '01698.HK.D%';
UPDATE vi_metric_base SET model_field = 'equity_income' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '权益法投资收益' AND unit IS NOT DISTINCT FROM '亿元');
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '权益法投资收益' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2017';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '权益法投资收益' AND unit IS NOT DISTINCT FROM '亿元'), '2017-12-31', '2017', '全年', 0.04, '历史年度原值；口径：合并口径', 641, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '权益法投资收益' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2018';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '权益法投资收益' AND unit IS NOT DISTINCT FROM '亿元'), '2018-12-31', '2018', '全年', -0.01, '历史年度原值；口径：合并口径', 641, now());
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '01698.HK' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '经营活动现金流量净额', '亿元', '财务', '报表计算',
       '全年', 11, '财务数据（三大报表）：经营业务现金净额', '年', '经营业务现金净额'
FROM vi_metric_base WHERE code LIKE '01698.HK.D%';
UPDATE vi_metric_base SET model_field = 'cfo' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '经营活动现金流量净额' AND unit IS NOT DISTINCT FROM '亿元');
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '经营活动现金流量净额' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2017';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '经营活动现金流量净额' AND unit IS NOT DISTINCT FROM '亿元'), '2017-12-31', '2017', '全年', 25, '历史年度原值；口径：合并口径', 641, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '经营活动现金流量净额' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2018';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '经营活动现金流量净额' AND unit IS NOT DISTINCT FROM '亿元'), '2018-12-31', '2018', '全年', 56.32, '历史年度原值；口径：合并口径', 641, now());
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '01698.HK' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '资本开支', '亿元', '财务', '报表计算',
       '全年', 11, '财务数据（三大报表）：购建固定资产 + 购建无形资产及其他资产', '年', '购建固定资产 + 购建无形资产及其他资产'
FROM vi_metric_base WHERE code LIKE '01698.HK.D%';
UPDATE vi_metric_base SET model_field = 'capex' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '资本开支' AND unit IS NOT DISTINCT FROM '亿元');
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '资本开支' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2017';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '资本开支' AND unit IS NOT DISTINCT FROM '亿元'), '2017-12-31', '2017', '全年', 1.38, '历史年度原值；口径：合并口径', 641, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '资本开支' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2018';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '资本开支' AND unit IS NOT DISTINCT FROM '亿元'), '2018-12-31', '2018', '全年', 4.83, '历史年度原值；口径：合并口径', 641, now());
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '01698.HK' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '收到投资分红', '亿元', '财务', '报表计算',
       '全年', 11, '财务数据（三大报表）：已收股息(投资)', '年', '已收股息(投资)'
FROM vi_metric_base WHERE code LIKE '01698.HK.D%';
UPDATE vi_metric_base SET model_field = 'investee_cash_div' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '收到投资分红' AND unit IS NOT DISTINCT FROM '亿元');
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '01698.HK' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '净借款', '亿元', '财务', '年报',
       '全年', 11, '年报（原历史年度手录）', '年', NULL
FROM vi_metric_base WHERE code LIKE '01698.HK.D%';
UPDATE vi_metric_base SET model_field = 'net_borrowing' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元');
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2017';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元'), '2017-12-31', '2017', '全年', 0, '历史年度原值；口径：合并口径', 641, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2018';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元'), '2018-12-31', '2018', '全年', 0, '历史年度原值；口径：合并口径', 641, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2019';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元'), '2019-12-31', '2019', '全年', 0, '历史年度原值；口径：合并口径', 641, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2020';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元'), '2020-12-31', '2020', '全年', 54, '历史年度原值；口径：合并口径', 641, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2021';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元'), '2021-12-31', '2021', '全年', 0, '历史年度原值；口径：合并口径', 641, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2022';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元'), '2022-12-31', '2022', '全年', 0, '历史年度原值；口径：合并口径', 641, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2023';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元'), '2023-12-31', '2023', '全年', 0, '历史年度原值；口径：合并口径', 641, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2024';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元'), '2024-12-31', '2024', '全年', 0, '历史年度原值；口径：合并口径', 629, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2025';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元'), '2025-12-31', '2025', '全年', -21.31, '历史年度原值；口径：合并口径', 629, now());
UPDATE vi_metric_base SET model_field = 'interest_debt' WHERE id = (SELECT id FROM vi_metric_base WHERE id = 131);
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE id = 131) AND basis = '时点' AND period = '2017Q4';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE id = 131), '2017-12-31', '2017Q4', '时点', 0, '历史年度原值；口径：合并口径', 641, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE id = 131) AND basis = '时点' AND period = '2018Q4';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE id = 131), '2018-12-31', '2018Q4', '时点', 0, '历史年度原值；口径：合并口径', 641, now());
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '01698.HK' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '货币资金', '亿元', '财务', '报表计算',
       '时点', 11, '财务数据（三大报表）：现金及等价物 + 短期存款 + 中长期存款', '年', '现金及等价物 + 短期存款 + 中长期存款'
FROM vi_metric_base WHERE code LIKE '01698.HK.D%';
UPDATE vi_metric_base SET model_field = 'cash' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '货币资金' AND unit IS NOT DISTINCT FROM '亿元');
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '货币资金' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '时点' AND period = '2017Q4';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '货币资金' AND unit IS NOT DISTINCT FROM '亿元'), '2017-12-31', '2017Q4', '时点', 64.8, '历史年度原值；口径：合并口径', 641, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '货币资金' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '时点' AND period = '2018Q4';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '货币资金' AND unit IS NOT DISTINCT FROM '亿元'), '2018-12-31', '2018Q4', '时点', 200.8, '历史年度原值；口径：合并口径', 641, now());
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '01698.HK' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '归母净资产', '亿元', '财务', '报表计算',
       '时点', 11, '财务数据（三大报表）：股东权益', '年', '股东权益'
FROM vi_metric_base WHERE code LIKE '01698.HK.D%';
UPDATE vi_metric_base SET model_field = 'equity_parent' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '归母净资产' AND unit IS NOT DISTINCT FROM '亿元');
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '归母净资产' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '时点' AND period = '2017Q4';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '归母净资产' AND unit IS NOT DISTINCT FROM '亿元'), '2017-12-31', '2017Q4', '时点', 261.41, '历史年度原值；口径：合并口径', 641, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '归母净资产' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '时点' AND period = '2018Q4';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '归母净资产' AND unit IS NOT DISTINCT FROM '亿元'), '2018-12-31', '2018Q4', '时点', 377.21, '历史年度原值；口径：合并口径', 641, now());
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '01698.HK' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '现金分红总额', '亿元', '财务', '年报',
       '全年', 11, '年报（原历史年度手录）', '年', NULL
FROM vi_metric_base WHERE code LIKE '01698.HK.D%';
UPDATE vi_metric_base SET model_field = 'dividend_total' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元');
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2017';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元'), '2017-12-31', '2017', '全年', 0, '历史年度原值；口径：合并口径', 641, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2018';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元'), '2018-12-31', '2018', '全年', 0, '历史年度原值；口径：合并口径', 641, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2019';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元'), '2019-12-31', '2019', '全年', 0, '历史年度原值；口径：合并口径', 641, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2020';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元'), '2020-12-31', '2020', '全年', 1.34, '历史年度原值；口径：合并口径', 641, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2021';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元'), '2021-12-31', '2021', '全年', 34.79, '历史年度原值；口径：合并口径', 641, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2022';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元'), '2022-12-31', '2022', '全年', 31.27, '历史年度原值；口径：合并口径', 641, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2023';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元'), '2023-12-31', '2023', '全年', 28.25, '历史年度原值；口径：合并口径', 641, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2024';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元'), '2024-12-31', '2024', '全年', 39.6, '历史年度原值；口径：合并口径', 629, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2025';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元'), '2025-12-31', '2025', '全年', 29.11, '历史年度原值；口径：合并口径', 629, now());
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '01698.HK' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '每股股息', '元', '财务', '年报',
       '全年', 11, '年报（原历史年度手录）', '年', NULL
FROM vi_metric_base WHERE code LIKE '01698.HK.D%';
UPDATE vi_metric_base SET model_field = 'dps' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元');
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元') AND basis = '全年' AND period = '2017';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元'), '2017-12-31', '2017', '全年', 0, '历史年度原值；口径：合并口径', 641, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元') AND basis = '全年' AND period = '2018';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元'), '2018-12-31', '2018', '全年', 0, '历史年度原值；口径：合并口径', 641, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元') AND basis = '全年' AND period = '2019';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元'), '2019-12-31', '2019', '全年', 0, '历史年度原值；口径：合并口径', 641, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元') AND basis = '全年' AND period = '2020';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元'), '2020-12-31', '2020', '全年', 0, '历史年度原值；口径：合并口径', 641, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元') AND basis = '全年' AND period = '2021';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元'), '2021-12-31', '2021', '全年', 0, '历史年度原值；口径：合并口径', 641, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元') AND basis = '全年' AND period = '2022';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元'), '2022-12-31', '2022', '全年', 0, '历史年度原值；口径：合并口径', 641, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元') AND basis = '全年' AND period = '2023';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元'), '2023-12-31', '2023', '全年', 0.5, '历史年度原值；口径：合并口径', 641, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元') AND basis = '全年' AND period = '2024';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元'), '2024-12-31', '2024', '全年', 0.65, '历史年度原值；口径：合并口径', 629, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元') AND basis = '全年' AND period = '2025';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 11 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元'), '2025-12-31', '2025', '全年', 0.82, '历史年度原值；口径：合并口径', 629, now());
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '01810.HK' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '全球月活跃用户（年末，含手机与平板）', '亿人', '经营', '年报',
       '全年', 21, '年报（原历史年度手录）', '年', NULL
FROM vi_metric_base WHERE code LIKE '01810.HK.D%';
UPDATE vi_metric_base SET model_field = 'volume' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '全球月活跃用户（年末，含手机与平板）' AND unit IS NOT DISTINCT FROM '亿人');
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '全球月活跃用户（年末，含手机与平板）' AND unit IS NOT DISTINCT FROM '亿人') AND basis = '全年' AND period = '2018';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '全球月活跃用户（年末，含手机与平板）' AND unit IS NOT DISTINCT FROM '亿人'), '2018-12-31', '2018', '全年', 2.421, '历史年度原值；口径：合并口径', 912, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '全球月活跃用户（年末，含手机与平板）' AND unit IS NOT DISTINCT FROM '亿人') AND basis = '全年' AND period = '2019';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '全球月活跃用户（年末，含手机与平板）' AND unit IS NOT DISTINCT FROM '亿人'), '2019-12-31', '2019', '全年', 3.096, '历史年度原值；口径：合并口径', 912, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '全球月活跃用户（年末，含手机与平板）' AND unit IS NOT DISTINCT FROM '亿人') AND basis = '全年' AND period = '2020';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '全球月活跃用户（年末，含手机与平板）' AND unit IS NOT DISTINCT FROM '亿人'), '2020-12-31', '2020', '全年', 3.963, '历史年度原值；口径：合并口径', 912, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '全球月活跃用户（年末，含手机与平板）' AND unit IS NOT DISTINCT FROM '亿人') AND basis = '全年' AND period = '2021';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '全球月活跃用户（年末，含手机与平板）' AND unit IS NOT DISTINCT FROM '亿人'), '2021-12-31', '2021', '全年', 5.089, '历史年度原值；口径：合并口径', 912, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '全球月活跃用户（年末，含手机与平板）' AND unit IS NOT DISTINCT FROM '亿人') AND basis = '全年' AND period = '2022';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '全球月活跃用户（年末，含手机与平板）' AND unit IS NOT DISTINCT FROM '亿人'), '2022-12-31', '2022', '全年', 5.821, '历史年度原值；口径：合并口径', 912, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '全球月活跃用户（年末，含手机与平板）' AND unit IS NOT DISTINCT FROM '亿人') AND basis = '全年' AND period = '2023';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '全球月活跃用户（年末，含手机与平板）' AND unit IS NOT DISTINCT FROM '亿人'), '2023-12-31', '2023', '全年', 6.412, '历史年度原值；口径：合并口径', 912, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '全球月活跃用户（年末，含手机与平板）' AND unit IS NOT DISTINCT FROM '亿人') AND basis = '全年' AND period = '2024';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '全球月活跃用户（年末，含手机与平板）' AND unit IS NOT DISTINCT FROM '亿人'), '2024-12-31', '2024', '全年', 7.023, '历史年度原值；口径：合并口径', 900, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '全球月活跃用户（年末，含手机与平板）' AND unit IS NOT DISTINCT FROM '亿人') AND basis = '全年' AND period = '2025';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '全球月活跃用户（年末，含手机与平板）' AND unit IS NOT DISTINCT FROM '亿人'), '2025-12-31', '2025', '全年', 7.541, '历史年度原值；口径：合并口径', 900, now());
UPDATE vi_metric_base SET model_field = 'revenue' WHERE id = (SELECT id FROM vi_metric_base WHERE id = 134);
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '01810.HK' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '营业成本', '亿元', '财务', '报表计算',
       '全年', 21, '财务数据（三大报表）：销售成本', '年', '销售成本'
FROM vi_metric_base WHERE code LIKE '01810.HK.D%';
UPDATE vi_metric_base SET model_field = 'cost_of_sales' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '营业成本' AND unit IS NOT DISTINCT FROM '亿元');
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '01810.HK' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '利润总额', '亿元', '财务', '报表计算',
       '全年', 21, '财务数据（三大报表）：除税前溢利', '年', '除税前溢利'
FROM vi_metric_base WHERE code LIKE '01810.HK.D%';
UPDATE vi_metric_base SET model_field = 'pretax_profit' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '利润总额' AND unit IS NOT DISTINCT FROM '亿元');
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '01810.HK' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '所得税', '亿元', '财务', '报表计算',
       '全年', 21, '财务数据（三大报表）：税项', '年', '税项'
FROM vi_metric_base WHERE code LIKE '01810.HK.D%';
UPDATE vi_metric_base SET model_field = 'income_tax' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '所得税' AND unit IS NOT DISTINCT FROM '亿元');
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '01810.HK' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '归母净利润', '亿元', '财务', '报表计算',
       '全年', 21, '财务数据（三大报表）：股东应占溢利', '年', '股东应占溢利'
FROM vi_metric_base WHERE code LIKE '01810.HK.D%';
UPDATE vi_metric_base SET model_field = 'np_parent' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '归母净利润' AND unit IS NOT DISTINCT FROM '亿元');
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '01810.HK' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '少数股东损益', '亿元', '财务', '报表计算',
       '全年', 21, '财务数据（三大报表）：少数股东损益', '年', '少数股东损益'
FROM vi_metric_base WHERE code LIKE '01810.HK.D%';
UPDATE vi_metric_base SET model_field = 'minority_profit' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '少数股东损益' AND unit IS NOT DISTINCT FROM '亿元');
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '01810.HK' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '折旧摊销', '亿元', '财务', '报表计算',
       '全年', 21, '财务数据（三大报表）：加:折旧及摊销', '年', '加:折旧及摊销'
FROM vi_metric_base WHERE code LIKE '01810.HK.D%';
UPDATE vi_metric_base SET model_field = 'da' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元');
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '01810.HK' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '财务费用', '亿元', '财务', '报表计算',
       '全年', 21, '财务数据（三大报表）：融资成本', '年', '融资成本'
FROM vi_metric_base WHERE code LIKE '01810.HK.D%';
UPDATE vi_metric_base SET model_field = 'finance_cost' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '财务费用' AND unit IS NOT DISTINCT FROM '亿元');
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '01810.HK' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '投资收益', '亿元', '财务', '年报',
       '全年', 21, '年报（原历史年度手录）', '年', NULL
FROM vi_metric_base WHERE code LIKE '01810.HK.D%';
UPDATE vi_metric_base SET model_field = 'invest_income' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元');
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2018';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元'), '2018-12-31', '2018', '全年', 40.29, '历史年度原值；口径：合并口径', 912, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2019';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元'), '2019-12-31', '2019', '全年', 29.15, '历史年度原值；口径：合并口径', 912, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2020';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元'), '2020-12-31', '2020', '全年', 141.82, '历史年度原值；口径：合并口径', 912, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2021';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元'), '2021-12-31', '2021', '全年', 58.28, '历史年度原值；口径：合并口径', 912, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2022';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元'), '2022-12-31', '2022', '全年', -34.31, '历史年度原值；口径：合并口径', 912, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2023';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元'), '2023-12-31', '2023', '全年', 52.43, '历史年度原值；口径：合并口径', 912, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2024';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元'), '2024-12-31', '2024', '全年', 13.17, '历史年度原值；口径：合并口径', 900, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2025';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元'), '2025-12-31', '2025', '全年', 163.58, '历史年度原值；口径：合并口径', 900, now());
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '01810.HK' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '权益法投资收益', '亿元', '财务', '年报',
       '全年', 21, '年报（原历史年度手录）', '年', NULL
FROM vi_metric_base WHERE code LIKE '01810.HK.D%';
UPDATE vi_metric_base SET model_field = 'equity_income' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '权益法投资收益' AND unit IS NOT DISTINCT FROM '亿元');
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '权益法投资收益' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2024';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '权益法投资收益' AND unit IS NOT DISTINCT FROM '亿元'), '2024-12-31', '2024', '全年', 2.77, '历史年度原值；口径：合并口径', 900, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '权益法投资收益' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2025';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '权益法投资收益' AND unit IS NOT DISTINCT FROM '亿元'), '2025-12-31', '2025', '全年', 3.26, '历史年度原值；口径：合并口径', 900, now());
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '01810.HK' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '经营活动现金流量净额', '亿元', '财务', '报表计算',
       '全年', 21, '财务数据（三大报表）：经营业务现金净额', '年', '经营业务现金净额'
FROM vi_metric_base WHERE code LIKE '01810.HK.D%';
UPDATE vi_metric_base SET model_field = 'cfo' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '经营活动现金流量净额' AND unit IS NOT DISTINCT FROM '亿元');
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '01810.HK' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '资本开支', '亿元', '财务', '报表计算',
       '全年', 21, '财务数据（三大报表）：购建固定资产 + 购建无形资产及其他资产', '年', '购建固定资产 + 购建无形资产及其他资产'
FROM vi_metric_base WHERE code LIKE '01810.HK.D%';
UPDATE vi_metric_base SET model_field = 'capex' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '资本开支' AND unit IS NOT DISTINCT FROM '亿元');
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '01810.HK' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '收到投资分红', '亿元', '财务', '报表计算',
       '全年', 21, '财务数据（三大报表）：已收股息(投资)', '年', '已收股息(投资)'
FROM vi_metric_base WHERE code LIKE '01810.HK.D%';
UPDATE vi_metric_base SET model_field = 'investee_cash_div' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '收到投资分红' AND unit IS NOT DISTINCT FROM '亿元');
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '01810.HK' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '净借款', '亿元', '财务', '年报',
       '全年', 21, '年报（原历史年度手录）', '年', NULL
FROM vi_metric_base WHERE code LIKE '01810.HK.D%';
UPDATE vi_metric_base SET model_field = 'net_borrowing' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元');
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2018';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元'), '2018-12-31', '2018', '全年', -2.36, '历史年度原值；口径：合并口径', 912, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2019';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元'), '2019-12-31', '2019', '全年', 66.19, '历史年度原值；口径：合并口径', 912, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2020';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元'), '2020-12-31', '2020', '全年', 37.97, '历史年度原值；口径：合并口径', 912, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2021';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元'), '2021-12-31', '2021', '全年', 92.27, '历史年度原值；口径：合并口径', 912, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2022';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元'), '2022-12-31', '2022', '全年', -37.98, '历史年度原值；口径：合并口径', 912, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2023';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元'), '2023-12-31', '2023', '全年', 48.44, '历史年度原值；口径：合并口径', 912, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2024';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元'), '2024-12-31', '2024', '全年', 67.33, '历史年度原值；口径：合并口径', 900, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2025';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元'), '2025-12-31', '2025', '全年', 52.97, '历史年度原值；口径：合并口径', 900, now());
UPDATE vi_metric_base SET model_field = 'interest_debt' WHERE id = (SELECT id FROM vi_metric_base WHERE id = 158);
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '01810.HK' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '货币资金', '亿元', '财务', '年报',
       '时点', 21, '年报（原历史年度手录）', '年', NULL
FROM vi_metric_base WHERE code LIKE '01810.HK.D%';
UPDATE vi_metric_base SET model_field = 'cash' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '货币资金' AND unit IS NOT DISTINCT FROM '亿元');
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '货币资金' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '时点' AND period = '2018Q4';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '货币资金' AND unit IS NOT DISTINCT FROM '亿元'), '2018-12-31', '2018Q4', '时点', 330.76, '历史年度原值；口径：合并口径', 912, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '货币资金' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '时点' AND period = '2019Q4';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '货币资金' AND unit IS NOT DISTINCT FROM '亿元'), '2019-12-31', '2019Q4', '时点', 495.71, '历史年度原值；口径：合并口径', 912, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '货币资金' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '时点' AND period = '2020Q4';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '货币资金' AND unit IS NOT DISTINCT FROM '亿元'), '2020-12-31', '2020Q4', '时点', 855.85, '历史年度原值；口径：合并口径', 912, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '货币资金' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '时点' AND period = '2021Q4';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '货币资金' AND unit IS NOT DISTINCT FROM '亿元'), '2021-12-31', '2021Q4', '时点', 750.68, '历史年度原值；口径：合并口径', 912, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '货币资金' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '时点' AND period = '2022Q4';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '货币资金' AND unit IS NOT DISTINCT FROM '亿元'), '2022-12-31', '2022Q4', '时点', 782.27, '历史年度原值；口径：合并口径', 912, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '货币资金' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '时点' AND period = '2023Q4';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '货币资金' AND unit IS NOT DISTINCT FROM '亿元'), '2023-12-31', '2023Q4', '时点', 1095.17, '历史年度原值；口径：合并口径', 912, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '货币资金' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '时点' AND period = '2024Q4';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '货币资金' AND unit IS NOT DISTINCT FROM '亿元'), '2024-12-31', '2024Q4', '时点', 1340.08, '历史年度原值；口径：合并口径', 900, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '货币资金' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '时点' AND period = '2025Q4';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '货币资金' AND unit IS NOT DISTINCT FROM '亿元'), '2025-12-31', '2025Q4', '时点', 1748.47, '历史年度原值；口径：合并口径', 900, now());
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '01810.HK' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '归母净资产', '亿元', '财务', '报表计算',
       '时点', 21, '财务数据（三大报表）：股东权益', '年', '股东权益'
FROM vi_metric_base WHERE code LIKE '01810.HK.D%';
UPDATE vi_metric_base SET model_field = 'equity_parent' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '归母净资产' AND unit IS NOT DISTINCT FROM '亿元');
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '01810.HK' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '现金分红总额', '亿元', '财务', '年报',
       '全年', 21, '年报（原历史年度手录）', '年', NULL
FROM vi_metric_base WHERE code LIKE '01810.HK.D%';
UPDATE vi_metric_base SET model_field = 'dividend_total' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元');
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2018';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元'), '2018-12-31', '2018', '全年', 0, '历史年度原值；口径：合并口径', 912, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2019';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元'), '2019-12-31', '2019', '全年', 29.32, '历史年度原值；口径：合并口径', 912, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2020';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元'), '2020-12-31', '2020', '全年', 4.55, '历史年度原值；口径：合并口径', 912, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2021';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元'), '2021-12-31', '2021', '全年', 70.07, '历史年度原值；口径：合并口径', 912, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2022';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元'), '2022-12-31', '2022', '全年', 23.86, '历史年度原值；口径：合并口径', 912, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2023';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元'), '2023-12-31', '2023', '全年', 13.57, '历史年度原值；口径：合并口径', 912, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2024';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元'), '2024-12-31', '2024', '全年', 40.48, '历史年度原值；口径：合并口径', 900, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元') AND basis = '全年' AND period = '2025';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元'), '2025-12-31', '2025', '全年', 61.73, '历史年度原值；口径：合并口径', 900, now());
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT '01810.HK' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'), '每股股息', '元', '财务', '年报',
       '全年', 21, '年报（原历史年度手录）', '年', NULL
FROM vi_metric_base WHERE code LIKE '01810.HK.D%';
UPDATE vi_metric_base SET model_field = 'dps' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元');
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元') AND basis = '全年' AND period = '2018';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元'), '2018-12-31', '2018', '全年', 0, '历史年度原值；口径：合并口径', 912, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元') AND basis = '全年' AND period = '2019';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元'), '2019-12-31', '2019', '全年', 0, '历史年度原值；口径：合并口径', 912, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元') AND basis = '全年' AND period = '2020';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元'), '2020-12-31', '2020', '全年', 0, '历史年度原值；口径：合并口径', 912, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元') AND basis = '全年' AND period = '2021';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元'), '2021-12-31', '2021', '全年', 0, '历史年度原值；口径：合并口径', 912, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元') AND basis = '全年' AND period = '2022';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元'), '2022-12-31', '2022', '全年', 0, '历史年度原值；口径：合并口径', 912, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元') AND basis = '全年' AND period = '2023';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元'), '2023-12-31', '2023', '全年', 0, '历史年度原值；口径：合并口径', 912, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元') AND basis = '全年' AND period = '2024';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元'), '2024-12-31', '2024', '全年', 0, '历史年度原值；口径：合并口径', 900, now());
DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元') AND basis = '全年' AND period = '2025';
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = 21 AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元'), '2025-12-31', '2025', '全年', 0, '历史年度原值；口径：合并口径', 900, now());
-- 历史年度只留口径说明、主要来源、备注
CREATE UNIQUE INDEX vi_metric_model_field_uniq ON vi_metric_base (company_id, model_field) WHERE model_field IS NOT NULL;
ALTER TABLE vi_sotp_item_base ADD CONSTRAINT vi_sotp_item_one_amount CHECK (metric_id IS NULL OR amount IS NULL);
DROP VIEW IF EXISTS vi_fin_history, vi_fin_history_calc, vi_fin_metric CASCADE;
ALTER TABLE vi_fin_history_base DROP COLUMN volume, DROP COLUMN revenue, DROP COLUMN cost_of_sales, DROP COLUMN pretax_profit, DROP COLUMN income_tax, DROP COLUMN np_parent, DROP COLUMN minority_profit, DROP COLUMN da, DROP COLUMN finance_cost, DROP COLUMN invest_income, DROP COLUMN equity_income, DROP COLUMN cfo, DROP COLUMN capex, DROP COLUMN investee_cash_div, DROP COLUMN net_borrowing, DROP COLUMN interest_debt, DROP COLUMN cash, DROP COLUMN equity_parent, DROP COLUMN dividend_total, DROP COLUMN dps;
COMMIT;
