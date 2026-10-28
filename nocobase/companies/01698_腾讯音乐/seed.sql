BEGIN;

INSERT INTO vi_company_base (code, name, exchange, industry, currency, volume_label, volume_unit, price_label, price_unit, is_default, profile, notes)
VALUES ('01698.HK', '腾讯音乐', '香港联交所（01698）、纽约证券交易所（TME，1 股 ADS＝2 股）', '在线音乐与音频娱乐', '人民币',
        '在线音乐付费用户（第四季度，2026 年起为年末音乐服务付费用户）', '亿人',
        '每付费用户年收入（总收入÷付费用户）', '元/人/年（含订阅、广告、演出、周边与社交娱乐收入）', FALSE, '中国最大的在线音乐与音频娱乐平台：QQ 音乐、酷狗音乐、酷我音乐、全民 K 歌，2026 年 5 月起并入喜马拉雅（长音频）。腾讯控股是控股股东（不同投票权架构）。2025 年收入 329.0 亿元（+15.8%）：在线音乐 267.3 亿元（订阅 176.6、非订阅 90.7，含广告、演出、艺人周边）、社交娱乐 61.8 亿元（直播打赏，持续收缩）；非国际财务报告准则归母净利 95.9 亿元，国际财务报告准则归母 110.6 亿元（含 23.7 亿元一次性收益）。年末在线音乐付费用户 1.274 亿、单个付费用户月均收入 11.9 元。
怎么赚钱：向唱片公司和版权方买曲库（固定保底＋分成），再通过会员订阅（超级会员 2,000 万以上）、广告、演唱会和周边、直播变现。毛利率约 44%，经营费用率约 15%，核心经营利润率约 29%；轻资产，资本开支每年约 12 亿元。账上现金、定期存款和短期投资 442 亿元（2026 年 6 月），另持有 Spotify、环球音乐、华纳音乐、SM 娱乐股权约 191 亿元。
本质：一个有定价权的“版权聚合＋分发”平台，正从“付费用户和单价双升”的订阅成长股，变成多元变现、大比例回购分红的现金流股。价值取决于两件事：字节跳动的汽水音乐、番茄音乐用免费模式分流轻度用户，会不会蔓延到付费核心用户；以及现金和利润有多少真正回到股东手里。', '主要风险：字节系免费音乐（汽水、番茄）与抖音导流；AI 生成音乐削弱版权稀缺性；版权方改变授权模式；监管（独家版权、直播打赏、未成年人）；季度经营指标从 2026 年起停止披露，订阅内生增长难以跟踪；喜马拉雅整合；境内现金汇出境外受外汇与预提税约束（回购在境外，资金靠美元借款与票据衔接）；不同投票权与腾讯控股的利益安排；港元、美元报价与人民币记账之间的汇率。')
ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, exchange = EXCLUDED.exchange, industry = EXCLUDED.industry,
  currency = EXCLUDED.currency, volume_label = EXCLUDED.volume_label, volume_unit = EXCLUDED.volume_unit,
  price_label = EXCLUDED.price_label, price_unit = EXCLUDED.price_unit, profile = EXCLUDED.profile, notes = EXCLUDED.notes;

INSERT INTO vi_metric_base (code, name, unit, category, company_id, source_name, frequency, valid_min, valid_max, notes)
VALUES ('01698.HK.PRICE', '腾讯音乐港股收盘价', '港元', '行情', (SELECT id FROM vi_company_base WHERE code = '01698.HK'), '腾讯行情（自动采集）；2025-10-20—2026-10-22 日线由腾讯 K 线接口一次性补齐（不复权）',
        '交易日', 1, 300, '港元报价。估值比较时按“港元兑人民币”指标折成人民币（公司表的股价汇率指标）。股价只进入对比层，不进入经营假设。')
ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, unit = EXCLUDED.unit, category = EXCLUDED.category, company_id = EXCLUDED.company_id,
  source_name = EXCLUDED.source_name, frequency = EXCLUDED.frequency, valid_min = EXCLUDED.valid_min, valid_max = EXCLUDED.valid_max, notes = EXCLUDED.notes;

UPDATE vi_company_base SET price_metric_id = (SELECT id FROM vi_metric_base WHERE code = '01698.HK.PRICE'),
  price_fx_metric_id = (SELECT id FROM vi_metric_base WHERE code = 'HKDCNY') WHERE code = '01698.HK';

INSERT INTO vi_collector_base (name, metric_id, url, parser, parser_param, enabled, max_lag_days, notes)
SELECT '腾讯音乐港股股价（腾讯行情）', (SELECT id FROM vi_metric_base WHERE code = '01698.HK.PRICE'), 'https://qt.gtimg.cn/q=hk01698', 'tencent_quote', 'hk01698', TRUE, 7, '返回 GBK 编码；港股日期格式为 2026/10/22 16:08:42，解析器只取数字。港股收盘约 16:10，之前采集到的是盘中价。'
WHERE NOT EXISTS (SELECT 1 FROM vi_collector_base WHERE name = '腾讯音乐港股股价（腾讯行情）');
UPDATE vi_collector_base SET metric_id = (SELECT id FROM vi_metric_base WHERE code = '01698.HK.PRICE'), url = 'https://qt.gtimg.cn/q=hk01698', parser = 'tencent_quote', parser_param = 'hk01698',
  max_lag_days = 7, notes = '返回 GBK 编码；港股日期格式为 2026/10/22 16:08:42，解析器只取数字。港股收盘约 16:10，之前采集到的是盘中价。' WHERE name = '腾讯音乐港股股价（腾讯行情）';

DELETE FROM vi_sotp_segment_base WHERE model_id IN (SELECT id FROM vi_model_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK'));
DELETE FROM vi_sotp_item_base WHERE model_id IN (SELECT id FROM vi_model_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK'));
DELETE FROM vi_fin_forecast_base WHERE model_id IN (SELECT id FROM vi_model_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK'));
DELETE FROM vi_trial_base WHERE model_id IN (SELECT id FROM vi_model_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK'));
DELETE FROM vi_forecast_base WHERE model_id IN (SELECT id FROM vi_model_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK'));
DELETE FROM vi_scenario_base WHERE model_id IN (SELECT id FROM vi_model_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK'));
DELETE FROM vi_model_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK');
DELETE FROM vi_fit_score_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK');
DELETE FROM vi_moat_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK');
DELETE FROM vi_competitor_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK');
DELETE FROM vi_value_chain_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK');
DELETE FROM vi_biz_model_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK');
DELETE FROM vi_issue_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK');
DELETE FROM vi_change_log_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK');
DELETE FROM vi_judgment_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK');
DELETE FROM vi_fact_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK');
DELETE FROM vi_thesis_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK');
DELETE FROM vi_observation_base WHERE metric_id IN (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND source_kind = '公司披露');
DELETE FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK');
DELETE FROM vi_lnk_risk_metrics WHERE risk_id IN (SELECT id FROM vi_risk_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK'));  -- 风险是更新不是重建，预警指标按 data_layer.json 重写

INSERT INTO vi_source_base (company_id, title, source_type, url, reliability, verify_status, summary, limitations) SELECT (SELECT id FROM vi_company_base WHERE code = '01698.HK'), '腾讯音乐港股收盘价：腾讯 K 线收盘价（港元，不复权）（2025—2026 年历史数据）', '数据库取数', 'https://web.ifzq.gtimg.cn/appstock/app/fqkline/get?param=hk01698,day（不复权日线）', '三级·第三方数据', '待核验', '历史日线收盘价', '历史补数：腾讯 K 线收盘价（港元，不复权）' WHERE NOT EXISTS (SELECT 1 FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '腾讯音乐港股收盘价：腾讯 K 线收盘价（港元，不复权）（2025—2026 年历史数据）');

INSERT INTO vi_observation_base (metric_id, obs_date, value, collected_at, doc_id)
SELECT (SELECT id FROM vi_metric_base WHERE code = '01698.HK.PRICE'), v.d, v.x, '2026-10-22T20:00:00+08:00', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '腾讯音乐港股收盘价：腾讯 K 线收盘价（港元，不复权）（2025—2026 年历史数据）')
FROM (VALUES
('2025-10-20'::date, 87.6),
('2025-10-21'::date, 86.7),
('2025-10-22'::date, 87.5),
('2025-10-23'::date, 88.3),
('2025-10-24'::date, 89.7),
('2025-10-27'::date, 89.8),
('2025-10-28'::date, 90.8),
('2025-10-30'::date, 86.8),
('2025-10-31'::date, 86.85),
('2025-11-03'::date, 88.15),
('2025-11-04'::date, 89.8),
('2025-11-05'::date, 87.65),
('2025-11-06'::date, 88.8),
('2025-11-07'::date, 86.5),
('2025-11-10'::date, 85.05),
('2025-11-11'::date, 83.65),
('2025-11-12'::date, 84.65),
('2025-11-13'::date, 75.6),
('2025-11-14'::date, 74.15),
('2025-11-17'::date, 74.3),
('2025-11-18'::date, 72.2),
('2025-11-19'::date, 72.85),
('2025-11-20'::date, 73.6),
('2025-11-21'::date, 69.2),
('2025-11-24'::date, 72.3),
('2025-11-25'::date, 73.5),
('2025-11-26'::date, 71.9),
('2025-11-27'::date, 71.0),
('2025-11-28'::date, 71.3),
('2025-12-01'::date, 71.85),
('2025-12-02'::date, 71.4),
('2025-12-03'::date, 70.8),
('2025-12-04'::date, 72.15),
('2025-12-05'::date, 73.2),
('2025-12-08'::date, 72.9),
('2025-12-09'::date, 72.55),
('2025-12-10'::date, 71.95),
('2025-12-11'::date, 70.25),
('2025-12-12'::date, 71.95),
('2025-12-15'::date, 71.15),
('2025-12-16'::date, 68.7),
('2025-12-17'::date, 69.25),
('2025-12-18'::date, 69.5),
('2025-12-19'::date, 70.55),
('2025-12-22'::date, 69.95),
('2025-12-23'::date, 69.65),
('2025-12-24'::date, 69.15),
('2025-12-29'::date, 69.0),
('2025-12-30'::date, 69.35),
('2025-12-31'::date, 69.0),
('2026-01-02'::date, 69.65),
('2026-01-05'::date, 70.3),
('2026-01-06'::date, 70.95),
('2026-01-07'::date, 67.05),
('2026-01-08'::date, 66.1),
('2026-01-09'::date, 68.7),
('2026-01-12'::date, 68.5),
('2026-01-13'::date, 68.65),
('2026-01-14'::date, 69.15),
('2026-01-15'::date, 67.45),
('2026-01-16'::date, 64.3),
('2026-01-19'::date, 64.35),
('2026-01-20'::date, 64.55),
('2026-01-21'::date, 63.6),
('2026-01-22'::date, 63.25),
('2026-01-23'::date, 63.55),
('2026-01-26'::date, 67.05),
('2026-01-27'::date, 66.05),
('2026-01-28'::date, 68.45),
('2026-01-29'::date, 66.9),
('2026-01-30'::date, 65.5),
('2026-02-02'::date, 64.2),
('2026-02-03'::date, 64.45),
('2026-02-04'::date, 64.5),
('2026-02-05'::date, 63.4),
('2026-02-06'::date, 62.95),
('2026-02-09'::date, 63.65),
('2026-02-10'::date, 63.55),
('2026-02-11'::date, 66.5),
('2026-02-12'::date, 65.0),
('2026-02-13'::date, 59.0),
('2026-02-16'::date, 61.85),
('2026-02-20'::date, 58.45),
('2026-02-23'::date, 60.5),
('2026-02-24'::date, 57.1),
('2026-02-25'::date, 57.7),
('2026-02-26'::date, 55.65),
('2026-02-27'::date, 56.85),
('2026-03-02'::date, 55.7),
('2026-03-03'::date, 55.95),
('2026-03-04'::date, 55.0),
('2026-03-05'::date, 54.4),
('2026-03-06'::date, 54.95),
('2026-03-09'::date, 53.45),
('2026-03-10'::date, 55.4),
('2026-03-11'::date, 54.35),
('2026-03-12'::date, 52.85),
('2026-03-13'::date, 54.1),
('2026-03-16'::date, 56.85),
('2026-03-17'::date, 57.2),
('2026-03-18'::date, 44.72),
('2026-03-19'::date, 41.12),
('2026-03-20'::date, 40.5),
('2026-03-23'::date, 39.22),
('2026-03-24'::date, 39.34),
('2026-03-25'::date, 39.24),
('2026-03-26'::date, 37.82),
('2026-03-27'::date, 38.38),
('2026-03-30'::date, 37.3),
('2026-03-31'::date, 37.18),
('2026-04-01'::date, 36.48),
('2026-04-02'::date, 35.5),
('2026-04-08'::date, 37.36),
('2026-04-09'::date, 36.7),
('2026-04-10'::date, 36.88),
('2026-04-13'::date, 36.78),
('2026-04-14'::date, 37.34),
('2026-04-15'::date, 38.56),
('2026-04-16'::date, 39.78),
('2026-04-17'::date, 39.68),
('2026-04-20'::date, 39.6),
('2026-04-21'::date, 39.76),
('2026-04-22'::date, 38.3),
('2026-04-23'::date, 37.36),
('2026-04-24'::date, 36.84),
('2026-04-27'::date, 36.52),
('2026-04-28'::date, 35.92),
('2026-04-29'::date, 36.58),
('2026-04-30'::date, 35.08),
('2026-05-04'::date, 35.72),
('2026-05-05'::date, 35.86),
('2026-05-06'::date, 36.18),
('2026-05-07'::date, 37.92),
('2026-05-08'::date, 37.4),
('2026-05-11'::date, 36.72),
('2026-05-12'::date, 36.16),
('2026-05-13'::date, 35.28),
('2026-05-14'::date, 34.2),
('2026-05-15'::date, 33.8),
('2026-05-18'::date, 34.24),
('2026-05-19'::date, 35.94),
('2026-05-20'::date, 36.02),
('2026-05-21'::date, 35.12),
('2026-05-22'::date, 35.84),
('2026-05-26'::date, 34.94),
('2026-05-27'::date, 35.22),
('2026-05-28'::date, 34.92),
('2026-05-29'::date, 35.34),
('2026-06-01'::date, 36.14),
('2026-06-02'::date, 38.02),
('2026-06-03'::date, 36.82),
('2026-06-04'::date, 35.26),
('2026-06-05'::date, 35.9),
('2026-06-08'::date, 35.4),
('2026-06-09'::date, 35.44),
('2026-06-10'::date, 35.36),
('2026-06-11'::date, 35.66),
('2026-06-12'::date, 36.38),
('2026-06-15'::date, 36.02),
('2026-06-16'::date, 35.34),
('2026-06-17'::date, 34.86),
('2026-06-18'::date, 33.94),
('2026-06-22'::date, 33.72),
('2026-06-23'::date, 32.02),
('2026-06-24'::date, 32.62),
('2026-06-25'::date, 32.18),
('2026-06-26'::date, 31.46),
('2026-06-29'::date, 32.88),
('2026-06-30'::date, 32.88),
('2026-07-02'::date, 33.94),
('2026-07-03'::date, 34.74),
('2026-07-06'::date, 34.9),
('2026-07-07'::date, 34.18),
('2026-07-08'::date, 35.22),
('2026-07-09'::date, 34.76),
('2026-07-10'::date, 35.04),
('2026-07-13'::date, 34.6),
('2026-07-14'::date, 35.0),
('2026-07-15'::date, 34.64),
('2026-07-16'::date, 36.2),
('2026-07-17'::date, 36.58),
('2026-07-20'::date, 36.1),
('2026-07-21'::date, 36.3),
('2026-07-22'::date, 34.98),
('2026-07-23'::date, 35.0),
('2026-07-24'::date, 34.3),
('2026-07-27'::date, 35.46),
('2026-07-28'::date, 36.5),
('2026-07-29'::date, 38.18),
('2026-07-30'::date, 38.74),
('2026-07-31'::date, 38.5),
('2026-08-03'::date, 37.32),
('2026-08-04'::date, 37.74),
('2026-08-05'::date, 37.6),
('2026-08-06'::date, 37.4),
('2026-08-07'::date, 37.38),
('2026-08-10'::date, 37.6),
('2026-08-11'::date, 38.56),
('2026-08-12'::date, 33.72),
('2026-08-13'::date, 32.94),
('2026-08-14'::date, 33.6),
('2026-08-17'::date, 34.4),
('2026-08-18'::date, 34.6),
('2026-08-19'::date, 34.24),
('2026-08-20'::date, 35.14),
('2026-08-21'::date, 34.52),
('2026-08-24'::date, 33.78),
('2026-08-25'::date, 33.74),
('2026-08-26'::date, 34.14),
('2026-08-27'::date, 34.0),
('2026-08-28'::date, 34.12),
('2026-08-31'::date, 33.72),
('2026-09-01'::date, 33.14),
('2026-09-02'::date, 32.78),
('2026-09-03'::date, 32.54),
('2026-09-04'::date, 32.58),
('2026-09-07'::date, 32.24),
('2026-09-08'::date, 32.46),
('2026-09-09'::date, 31.52),
('2026-09-10'::date, 31.2),
('2026-09-11'::date, 30.96),
('2026-09-14'::date, 31.78),
('2026-09-15'::date, 31.68),
('2026-09-16'::date, 31.1),
('2026-09-17'::date, 30.88),
('2026-09-18'::date, 31.1),
('2026-09-21'::date, 30.58),
('2026-09-22'::date, 32.28),
('2026-09-23'::date, 31.98),
('2026-09-24'::date, 32.02),
('2026-09-25'::date, 32.38),
('2026-09-28'::date, 33.1),
('2026-09-29'::date, 32.36),
('2026-09-30'::date, 31.5),
('2026-10-02'::date, 30.94),
('2026-10-05'::date, 30.52),
('2026-10-06'::date, 30.94),
('2026-10-07'::date, 31.1),
('2026-10-08'::date, 30.88),
('2026-10-09'::date, 31.84),
('2026-10-12'::date, 32.84),
('2026-10-13'::date, 33.26),
('2026-10-14'::date, 33.58),
('2026-10-15'::date, 32.8),
('2026-10-16'::date, 34.04),
('2026-10-20'::date, 33.44),
('2026-10-21'::date, 32.94),
('2026-10-22'::date, 32.14)) v(d, x)
WHERE NOT EXISTS (SELECT 1 FROM vi_observation_base o WHERE o.metric_id = (SELECT id FROM vi_metric_base WHERE code = '01698.HK.PRICE') AND o.obs_date = v.d);

UPDATE vi_observation_base SET doc_id = (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '腾讯音乐港股收盘价：腾讯 K 线收盘价（港元，不复权）（2025—2026 年历史数据）') WHERE doc_id IS NULL AND raw_capture_id IS NULL AND metric_id = (SELECT price_metric_id FROM vi_company_base WHERE code = '01698.HK');

INSERT INTO vi_source_base (company_id, title, source_type, publisher, publish_date, url, reliability, verify_status, retrieved_on, summary, limitations) VALUES
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '腾讯音乐 2025 年年报', '定期报告', '腾讯音乐', '2026-04-17', 'https://www.hkexnews.hk/', '一级·法定披露', '仅定位入口', '2026-10-22', '以公允价值计量且其变动计入其他综合收益的金融资产 262.31 亿元，主要是 Spotify 与环球音乐（UMG）股权；第四季度在线音乐付费用户 1.274 亿。', '经岗底斯知识库取得片段（file-id 22997104），全文未下载。'),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025 年第四季度及全年未经审计财务业绩公告', '定期报告', '腾讯音乐', '2026-03-17', 'https://ir.tencentmusic.com', '一级·法定披露', '已读原文', '2026-10-22', '2025 年收入 329.0 亿元（+15.8%）、毛利率 44.2%、经营费用率 14.8%、归母净利 110.6 亿元（含视同处置联营公司收益 23.7 亿元）、非国际财务报告准则归母 95.9 亿元；第四季度付费用户 1.274 亿、月活 5.28 亿（−5.0%）、ARPPU 11.9 元；年末现金、定期存款和短期投资 380.4 亿元；2025 年度股息每股 0.12 美元（约 3.68 亿美元）；自 2026 年起停止披露季度月活、付费用户与 ARPPU，改为每年披露年末付费用户总数。', '经岗底斯取得港交所公告原文（file-id 22121779）。'),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026 年第二季度未经审计财务业绩公告', '定期报告', '腾讯音乐', '2026-08-11', 'https://ir.tencentmusic.com', '一级·法定披露', '已读原文', '2026-10-22', '二季度收入 89.3 亿元（+5.8%）：音乐相关服务 76.1 亿元（会员 47.9、营销及消费类 28.1）、社交娱乐 13.3 亿元（−16.4%）；毛利率 44.2%；归母 24.7 亿元、非国际财务报告准则归母 26.9 亿元；喜马拉雅 5 月 18 日起并表；6 月末现金等合计 442.2 亿元，新增借款 131.4 亿元；二季度回购 4.0 亿美元（4,350 万股 ADS，均价 9.2 美元）。附上半年合并报表。', '经岗底斯取得港交所公告原文（file-id 85648742）。“在线音乐服务”自 2026 年起更名为“音乐相关服务”，含长音频。'),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025 年第一至第三季度未经审计财务业绩公告', '定期报告', '腾讯音乐', '2025-11-12', 'https://ir.tencentmusic.com', '一级·法定披露', '已读原文', '2026-10-22', '2024、2025 年各季度收入、毛利、归母与非国际财务报告准则归母净利；月活、付费用户、ARPPU 与订阅收入；2025 年一季度回购 6,450 万美元。', '经岗底斯取得港交所公告原文（file-id 14105277、14027065、13861673）。'),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022、2023 年第四季度业绩公告与 2023 年年报（经营指标片段）', '定期报告', '腾讯音乐', '2024-04-19', 'https://www.hkexnews.hk/', '一级·法定披露', '数值已核对', '2026-10-22', '第四季度在线音乐付费用户：2021 年 7,620 万、2022 年 8,850 万、2023 年 1.067 亿；年均付费用户 2021—2023 年 6,860 万、8,420 万、1.009 亿；订阅收入 73.33、86.99、120.96 亿元。', '经岗底斯知识库检索公告片段（file-id 15751942、14874627、14750511），全文未下载。2019、2020 年未取得。'),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '截至 2025 年 12 月 31 日止年度的股息公告', '临时公告', '腾讯音乐', '2026-03-17', 'https://www.hkexnews.hk/', '一级·法定披露', '已读原文', '2026-10-22', '2025 年度现金股息每股 0.12 美元（每股 ADS 0.24 美元），记录日 2026-04-02，派发日 2026-04-20。', '经岗底斯取得港交所公告原文（file-id 22121780）。'),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '收购喜马拉雅：拟议收购（2025-06-10）与完成收购（2026-05-18）公告', '临时公告', '腾讯音乐', '2026-05-18', 'https://www.hkexnews.hk/', '一级·法定披露', '已读原文', '2026-10-22', '对价：现金最高 12.6 亿美元，加最多 175,288,891 股 A 类普通股（含新发行股份与股权激励相关股份）；交割后喜马拉雅成为全资附属公司。', '经岗底斯取得港交所公告原文（file-id 25242719；拟议收购公告 14080203 未下载）。'),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '10 亿美元票据发售的定价与完成公告（2026-09）', '临时公告', '腾讯音乐', '2026-09-11', 'https://www.hkexnews.hk/', '一级·法定披露', '已读原文', '2026-10-22', '发行 5 亿美元 5.050% 2031 年到期与 5 亿美元 5.650% 2036 年到期优先无抵押票据，净额约 9.919 亿美元，用于一般企业用途，包括境外债务再融资及股份回购。', '经岗底斯取得港交所公告原文（file-id 88112885、92568090）。'),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '腾讯控股 2026 年中期报告（业务合并附注）', '定期报告', '腾讯控股', '2026-08-25', 'https://www.hkexnews.hk/', '一级·法定披露', '已读原文', '2026-10-22', '腾讯音乐收购喜马拉雅：总对价约 140 亿元＝现金约 80 亿元＋原持有权益公允价值约 11 亿元＋发行或待发行普通股；可辨认净资产约 48 亿元，商誉约 92 亿元。', '经岗底斯知识库取得腾讯控股中报附注 33 片段（file-id 86814917）；是母公司口径的披露，腾讯音乐自身的购买价分摊未取得。'),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026 年第二季度业绩电话会纪要（2026-08-11）', '数据库取数', '岗底斯（业绩电话会纪要）', '2026-08-11', NULL, '三级·第三方数据', '待核验', '2026-10-22', '竞争主要冲击轻度用户，超级会员受影响有限；已接管微信视频号音乐垂类运营；下半年毛利率同比略降；全年销售与管理费用合理增加、净利率小幅承压、经调整 EBITDA 小幅增长；10 亿美元回购计划将按时完成，正积极准备新一轮回购并探讨不同的股东回报方式。', '由岗底斯整理的纪要或第三方研报，是转述口径；关键数字需以公告核对。（file-id 6376186）'),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '摩根大通：2026 年二季度业绩后投资者交流会要点（2026-08-16）及 3 月下调评级报告', '数据库取数', '岗底斯（外资研报）', '2026-08-16', NULL, '三级·第三方数据', '待核验', '2026-10-22', '剔除喜马拉雅后会员内生增长可能仅持平；管理层把竞争描述为“曲库成本差异”而非需求变化；毛利率下行阈值约 42%；目标价 36 港元/9 美元（9 倍 2027 年市盈率）；3 月报告：订阅增长不再线性、停披季度指标说明旧的估值框架在弱化，下调至中性。', '由岗底斯整理的纪要或第三方研报，是转述口径；关键数字需以公告核对。（file-id 479558633291124736、424730925432705024）'),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '岗底斯：卖方 2026 年中报点评（国信、光大、广发、华泰等）与外资估值', '数据库取数', '岗底斯', '2026-10-15', NULL, '三级·第三方数据', '待核验', '2026-10-22', '中报后 2026—2028 年经调整归母净利预测：国信 98.6/111.4/124.3、光大 99/110/119、华泰 98.0/108.3/115.5、广发 2026—2027 年 98/107 亿元；目标价 36（摩根大通）、44.9、46（高盛）、52.4（广发）、61.3 港元（华泰）；摩根士丹利对 2.5% Spotify、2% UMG、0.8% WMG、9.7% SM 娱乐（韩国 SM Entertainment，不是索尼音乐）的持股估值 236 亿元，再打七折。', '卖方预测是非国际财务报告准则口径，比本模型的国际财务报告准则归母净利高约 10 亿元（股权激励与收购摊销）。只作对照。'),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '行业竞争资料：汽水音乐、番茄音乐用户规模与定价', '数据库取数', '岗底斯（行业研报、产业公众号）', '2026-09-16', NULL, '三级·第三方数据', '待核验', '2026-10-22', '汽水音乐 2026 年 7 月月活 1.7 亿、日活 5,969 万，iOS 免费榜稳定前 7；番茄音乐月活 4,553 万；汽水 VIP 8 元/月、SVIP 18 元/月（QQ 音乐 20—40 元）；看 80 秒广告换全天免费；分流主要来自酷狗、酷我的下沉与轻度用户（QuestMobile、EP 平台付费用户数据转述）。', '第三方监测数据口径不一，只看趋势。'),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '东方财富港股/美股格式三大报表（akshare 取数）', '数据库取数', '东方财富', '2026-10-22', 'https://emweb.securities.eastmoney.com/PC_HKF10/', '三级·第三方数据', '数值已核对', '2026-10-22', '港股格式 2019—2025 年、美股格式 2015—2025 年三大报表全部科目；2024、2025 年与业绩公告一致。原始数据保存在 companies/01698_腾讯音乐/data/。', '经 akshare（stock_financial_hk_report_em、stock_financial_us_report_em）取数；美股格式 2022 年以后现金流量表明细缺失，历史财务以港股格式为主，2017—2018 年用美股格式。'),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '腾讯行情 K 线：腾讯音乐港股日线与港元兑人民币（2025-10—2026-10）', '数据库取数', '腾讯财经', '2026-10-22', 'https://web.ifzq.gtimg.cn/appstock/app/fqkline/get?param=hk01698,day', '三级·第三方数据', '数值已核对', '2026-10-22', '港股 248 个交易日不复权收盘价：2025-10-20 87.10 港元 → 2026-10-22 32.14 港元（−63%）；港元兑人民币 0.9163 → 0.8507。', NULL),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '卖方行业研究：在线音乐产业链、版权成本与竞争格局（国信、中金、长江、中信建投等，2024-12—2026-09）', '数据库取数', '岗底斯（卖方研报）', '2026-09-07', NULL, '三级·第三方数据', '待核验', '2026-10-22', '国内前五大唱片公司份额约 29%、平台付给版权方约 45%—55%（海外 60%—70%）；腾讯音乐约占市场三分之二；三家音乐平台付费率、ARPPU、毛利率对比（中金 2026-09，2026 年起为估算）；汽水音乐曲库约 5,000 万首、热歌 86% 来自抖音（中信建投 2025-12）；自制音乐播放份额 20%—30%（中金 2025-09）；AI 音乐上传约 40%、播放 1%—3%（中金 2026-07）；版权授权 1—3 年、保底＋分成（招股书，外资研报转引）。', '卖方转引的行业数据口径不一，只用于判断结构与方向；2026 年起腾讯音乐的季度用户数据是卖方估算。'),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '券商组织的行业专家与业内交流纪要（国信 2025-05、06、11；弘则 2025-06；汽水音乐专题 2026-06；中金业绩会纪要与月度交流）', '数据库取数', '岗底斯（会议纪要、网络纪要）', '2026-06-10', NULL, '三级·第三方数据', '待核验', '2026-10-22', '前环球音乐人士等业内交流：腾讯音乐续费率 80% 以上、付费墙比例（两种说法：60%—70% 与 20% 多）、付费上限约 1.5—1.7 亿；汽水音乐对三大唱片“必采”、“抖汽互通”授权、会员渗透率不到 10%、30 日留存约 10%、与酷狗用户重合约 60%；中金：2026 年一季度业绩会（管理层称竞争对手用 AI 生成的盗版内容引流）、喜马拉雅收购附条件批准（五年限制）。', '岗底斯帕米尔专家纪要库无权限，这里是券商组织的交流纪要；专家身份与数据无法独立核实。'),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '网易云音乐 2026 年中期业绩点评（光大、东财、浦银国际、华兴、中金）', '数据库取数', '岗底斯（研报、首席观点）', '2026-08-26', NULL, '三级·第三方数据', '待核验', '2026-10-22', '网易云音乐 2026 年上半年收入 39.59 亿元（+3.4%），会员订阅 26.01 亿元（+5.3%），毛利率 37.2%，销售费用率 7.5%，经调整经营利润 −12%；会员规模增长、学生会员摊薄 ARPPU。', '没有读网易云公告原文。'),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '研究推导：商业模式、产业链、竞争壁垒、多空辩论与适配度评分（2026-10-22）', '研究推导', '本研究', '2026-10-22', NULL, '研究推导', '待核验', '2026-10-22', '商业模式画布 9 项、产业链 11 个环节（含五力归类）、6 个竞争对手、9 项候选壁垒（含 4 项伪壁垒）、5 场多空辩论与 8 维适配度评分的推导过程。', '岗底斯观点 PK 三次调用均超时、技能脚本未配置授权，辩论由本研究按正反证据组织，裁决是判断。'),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '研究推导：2026—2035 年经营与现金桥接假设', '研究推导', '本研究', '2026-10-22', NULL, '研究推导', '待核验', '2026-10-22', '主营三块的收入与利润率见判断 J-S1、J-S2、J-S3，自由现金见 J-CASH。', '判断成分高，需逐项核验。');

INSERT INTO vi_fact_base (company_id, title, category, statement, period, as_of, verify_status, source_id) VALUES
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '流通股约 31.5 亿股（估算）', '治理', '腾讯行情显示已发行股份 33.02 亿股（含库存股与股权激励信托持有股份）；2026 年二季度加权平均基本股数 31.28 亿股。期末流通股估算：一季度约 30.8 亿股＋喜马拉雅对价发行最多 1.75 亿股−二季度回购 0.87 亿股（4,350 万 ADS）≈ 31.4—31.7 亿股。每股价值的分母用 31.5 亿股（1 股 ADS＝2 股）。精确数待年报或股份变动月报核对。', '2026-06-30', '2026-10-22', '待核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2026 年第二季度未经审计财务业绩公告' LIMIT 1)),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025 年收入 329.0 亿元（+15.8%），订阅 176.6 亿元', '经营', '2025 年总收入 329.02 亿元：在线音乐服务 267.26 亿元（+22.9%；其中订阅 176.6 亿元 +16.0%、非订阅 90.7 亿元 +39.2%，主要是线下演出、广告、艺人周边）、社交娱乐及其他 61.76 亿元（−7.3%）。', '2025', '2025-12-31', '已核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第四季度及全年未经审计财务业绩公告' LIMIT 1)),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '付费用户 1.274 亿、ARPPU 11.9 元，月活连续下滑', '经营', '第四季度在线音乐付费用户：2021 年 7,620 万 → 2022 年 8,850 万 → 2023 年 1.067 亿 → 2024 年 1.210 亿 → 2025 年 1.274 亿（+5.3%，增速逐年放缓）；ARPPU 2022 年 8.9 元 → 2025 年 11.9 元。月活 2024 年四季度 5.56 亿 → 2025 年四季度 5.28 亿（−5.0%）。2026 年起停止披露季度月活、付费用户和 ARPPU，只在年报披露年末付费用户总数。', '2025Q4', '2025-12-31', '已核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第四季度及全年未经审计财务业绩公告' LIMIT 1)),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '订阅（会员）收入增速：+26% → +16% → 内生约持平', '经营', '订阅收入同比：2024 年 +25.9%（152.3 亿元）、2025 年 +16.0%（176.6 亿元；四个季度 +16.6%、+17.1%、+17.2%、+13.2%）；2026 年起改称“会员服务”（含长音频）：一季度 45.68 亿元 +6.6%、二季度 47.92 亿元 +8.1%（含喜马拉雅）。摩根大通估算剔除喜马拉雅后二季度会员内生增长约持平。', '2026Q2', '2026-06-30', '已核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2026 年第二季度未经审计财务业绩公告' LIMIT 1)),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026 年上半年：收入 +6.5%、非国际财务报告准则归母 +5.6%', '财务', '2026 年上半年收入 168.28 亿元（+6.5%）、毛利率 44.5%、归母净利 45.62 亿元（2025 年上半年 67.00 亿元含 23.7 亿元一次性收益）、非国际财务报告准则归母 49.59 亿元（+5.6%）；经营现金流 51.96 亿元（+25%）。', '2026H1', '2026-06-30', '已核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2026 年第二季度未经审计财务业绩公告' LIMIT 1)),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026 年二季度：喜马拉雅并表 4.07 亿元，社交娱乐 −16%', '经营', '二季度收入 89.33 亿元（+5.8%）：会员 47.92 亿元（+8.1%）、营销及消费类服务 28.13 亿元（+16.2%，演出、周边增长，广告承压）、社交娱乐 13.28 亿元（−16.4%）。喜马拉雅 5 月 18 日起并表，贡献收入 4.07 亿元；广发据此估算其年化收入约 34 亿元、经营利润约 5.4 亿元。', '2026Q2', '2026-06-30', '已核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2026 年第二季度未经审计财务业绩公告' LIMIT 1)),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '毛利率从 2021 年 30% 升到 2025 年 44%，2026 年下半年同比略降', '经营', '毛利率 2021—2025 年 30.1%、31.0%、35.3%、42.3%、44.2%，2026 年一、二季度 44.9%、44.2%：版权成本优化、订阅占比提升和社交娱乐分成比例下降。线下演出与艺人经纪毛利率低，占比上升会拉低毛利率；管理层预计 2026 年下半年同比略降。', '2025', '2026-08-11', '已核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第四季度及全年未经审计财务业绩公告' LIMIT 1)),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '经营费用率从 2021 年 21% 降到 2025 年 15%', '财务', '经营费用率 2021 年 21.4%、2022 年 19.6%、2023 年 18.1%、2024 年 16.5%、2025 年 14.8%，2026 年二季度 14.5%（喜马拉雅并表与无形资产摊销使同比 +0.8pt）。核心经营利润率（毛利−经营费用）2025 年 29.4%。', '2025', '2026-06-30', '已核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第四季度及全年未经审计财务业绩公告' LIMIT 1)),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025 年一次性收益 23.7 亿元（UMG 股权实物分派）', '财务', '2025 年 3 月一家联营公司（腾讯牵头的财团）把所持环球音乐股份实物分派给各股东，腾讯音乐直接取得 UMG 约 2% 股权，并确认视同处置收益 23.7 亿元，计入其他收益。剔除后 2025 年归母净利约 86.9 亿元。', '2025Q1', '2025-12-31', '已核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第四季度及全年未经审计财务业绩公告' LIMIT 1)),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '现金等 442 亿元，借款与票据约 165 亿元', '债务', '现金、定期存款和短期投资：2024 年末 375.8 亿元、2025 年末 380.4 亿元、2026 年 3 月末 410.0 亿元、6 月末 442.2 亿元。2026 年 6 月末新增借款 131.39 亿元（非流动 71.42、流动 59.97），应付票据 33.90 亿元、租赁负债 3.55 亿元，带息负债约 168.8 亿元，净现金约 273 亿元。借款与上半年喜马拉雅现金对价、回购同期发生；现金大部分在境内，回购与分红在境外支付。', '2026-06-30', '2026-06-30', '已核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2026 年第二季度未经审计财务业绩公告' LIMIT 1)),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026 年 9 月发行 10 亿美元票据（5.05%、5.65%）', '债务', '2026 年 9 月发行 5 亿美元 5.050%（2031 年到期）与 5 亿美元 5.650%（2036 年到期）优先无抵押票据，净额约 9.92 亿美元，用于境外债务再融资和股份回购。原有 5 亿美元票据（2030 年到期）仍在；2025 年已偿还 3 亿美元票据（21.31 亿元）。', '2026-09', '2026-09-11', '已核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '10 亿美元票据发售的定价与完成公告（2026-09）' LIMIT 1)),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '喜马拉雅：总对价约 140 亿元，现金约 80 亿元，商誉约 92 亿元', '资本开支', '2026 年 5 月 18 日完成收购喜马拉雅：现金最高 12.6 亿美元＋最多 1.753 亿股 A 类普通股。腾讯控股中报披露：总对价约 140 亿元（现金约 80 亿元、原持有权益公允价值约 11 亿元，其余为腾讯音乐发行或待发行的股份），可辨认净资产约 48 亿元、商誉约 92 亿元。腾讯音乐 6 月末商誉 297.6 亿元（年初 205.2 亿元）、无形资产 59.0 亿元（年初 29.0 亿元）。', '2026', '2026-08-25', '已核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '腾讯控股 2026 年中期报告（业务合并附注）' LIMIT 1)),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '回购与分红：2026 年二季度回购 4 亿美元，新一轮在准备', '分红', '回购（亿元）：2021 年 34.8、2022 年 31.3、2023 年 12.5、2024 年 19.3、2025 年 3.9；2026 年二季度 4.0 亿美元（约 27 亿元，4,350 万 ADS，均价 9.2 美元）。现金股息：2023 年度每股 0.07 美元、2024 年度 0.09 美元、2025 年度 0.12 美元（约 3.68 亿美元）。2025 年 3 月宣布的 10 亿美元回购计划截至 2026-08-27 剩余约 5.44 亿美元（2027 年 3 月到期）；管理层称正积极准备新一轮回购，并探讨不同的股东回报方式。', '2026Q2', '2026-08-27', '已核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2026 年第二季度未经审计财务业绩公告' LIMIT 1)),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '对外投资 191 亿元：Spotify、UMG、WMG、SM 娱乐', '估值方法', '以公允价值计量且其变动计入其他综合收益的金融资产：2024 年末 144.98 亿元、2025 年末 262.31 亿元、2026 年 6 月末 191.47 亿元（主要是 Spotify 与 UMG，另有 WMG、SM 娱乐）；权益法投资 26.91 亿元。摩根士丹利口径持股比例：Spotify 2.5%、UMG 2%（经腾讯牵头的 Concerto 财团间接持有，公司占财团 9.94%）、WMG 0.8%、SM 娱乐 9.7%（2025 年 5 月从 HYBE 受让，韩国 K-pop 公司）。不持有索尼音乐。这些股权不分红或分红很少，估值里按最新报告账面价值打七折单独计入（见判断 J-INV）。', '2026-06-30', '2026-06-30', '已核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2026 年第二季度未经审计财务业绩公告' LIMIT 1)),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '汽水音乐月活 1.7 亿，定价约为 QQ 音乐的三分之一', '经营', '字节跳动旗下汽水音乐 2026 年 7 月月活 1.7 亿、日活 5,969 万，iOS 免费榜稳定前 7、音乐类第一；番茄音乐月活 4,553 万。汽水用“每天看约 80 秒广告换全天免费”＋抖音导流，VIP 8 元/月、SVIP 18 元/月，QQ 音乐会员 20—40 元。EP 平台数据显示 2026 年 6、7 月腾讯音乐付费用户净增环比下降，分流主要来自酷狗、酷我。', '2026-07', '2026-09-16', '待核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '行业竞争资料：汽水音乐、番茄音乐用户规模与定价' LIMIT 1)),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '管理层：竞争冲击轻度用户，超级会员稳定', '经营', '管理层（2026-08）：竞争主要冲击轻度、泛用户，高价值的超级会员受影响有限（超级会员 2025 年末超过 2,000 万）；应对是接管微信视频号音乐垂类运营、推出酷狗免费版、波点音乐等轻量 App、把演唱会优先购票、周边和喜马拉雅长音频放进超级会员权益。不会大水漫灌式投放，7 月起按集团统一 ROI 标准恢复喜马拉雅投放。', '2025Q4', '2026-08-11', '待核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2026 年第二季度业绩电话会纪要（2026-08-11）' LIMIT 1)),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026 年指引：净利率小幅承压，经调整 EBITDA 小幅增长', '经营', '2026 年 3 月业绩会口径（首席观点转述）：音乐收入增速约 10%—13%、会员中高个位数、其他 20% 以上、毛利率持平、经调整净利率约 29%。8 月更新：下半年毛利率同比略降，销售与管理费用合理增加，加上借款利息，全年净利率小幅承压，经调整 EBITDA 小幅增长。', '2026', '2026-08-11', '待核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2026 年第二季度业绩电话会纪要（2026-08-11）' LIMIT 1)),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '卖方预期 2026—2028 年经调整归母约 98/109/118 亿元', '估值方法', '中报后卖方 2026—2028 年经调整归母预测：国信 98.6/111.4/124.3、光大 99/110/119、华泰 98.0/108.3/115.5 亿元；网络纪要称公司全年预期约 100 亿元。经调整口径加回股权激励（约 7 亿元）和收购摊销（约 5 亿元），比国际财务报告准则归母高约 10—12 亿元。', '2026E', '2026-10-15', '待核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '岗底斯：卖方 2026 年中报点评（国信、光大、广发、华泰等）与外资估值' LIMIT 1)),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '股价一年跌 63%：87.1 → 32.14 港元', '估值方法', '港股 2025-10-20 收盘 87.10 港元，2026-03-17 发布 2025 年业绩并宣布停披季度指标后，美股单日 −24.7%、港股 −20% 以上；2026-10-22 收盘 32.14 港元（一年 −63%），美股 ADS 8.44 美元（2026-10-21）。', '2026-10-22', '2026-10-22', '已核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '腾讯行情 K 线：腾讯音乐港股日线与港元兑人民币（2025-10—2026-10）' LIMIT 1)),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '市值约 862 亿元，扣除净现金与投资后经营业务约 370 亿元', '估值方法', '31.5 亿股 × 32.14 港元 × 0.851 ≈ 862 亿元人民币。扣除 6 月末净现金约 273 亿元和对外投资约 218 亿元（金融资产 191.5＋权益法 26.9）后，经营业务约 370 亿元，约为本模型 2026 年归母净利（88 亿元）的 4.2 倍；按经调整口径约 3.8 倍。', '2026-10-22', '2026-10-22', '已核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '腾讯行情 K 线：腾讯音乐港股日线与港元兑人民币（2025-10—2026-10）' LIMIT 1)),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '社交娱乐收入持续收缩', '经营', '社交娱乐及其他收入（直播打赏为主）：2024 年 66.6 亿元、2025 年 61.8 亿元（−7.3%）；2026 年一、二季度 13.81、13.28 亿元（−11.0%、−16.4%），二季度只占总收入的 14.9%。分成比例下降使这块业务的毛利率在改善，但收入在持续收缩。', '2025', '2026-06-30', '已核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第四季度及全年未经审计财务业绩公告' LIMIT 1)),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '经营现金流约 100 亿元，与经调整净利相当', '财务', '经营现金流 2021—2025 年 52.4、74.8、73.4、102.8、102.3 亿元，2026 年上半年 52.0 亿元；资本开支（固定资产＋无形资产）每年 10—12 亿元。经营现金流约等于经调整净利：负营运资本（预收会员费、应付版权方）随收入增长释放现金。', '2025', '2026-06-30', '已核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '东方财富港股/美股格式三大报表（akshare 取数）' LIMIT 1)),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '有效税率约 17.5%，少数股东约 3%', '财务', '有效税率 2024 年 18.4%、2025 年 14.5%（剔除不征税的一次性收益约 17.6%）、2026 年上半年 17.2%；少数股东损益占税后利润 2024 年 6.5%、2025 年 2.6%、2026 年上半年 2.7%。', '2026H1', '2026-06-30', '已核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2026 年第二季度未经审计财务业绩公告' LIMIT 1)),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '股权激励费用约 7 亿元/年', '财务', '以股份为基础的薪酬开支 2024 年 6.81 亿元、2025 年 6.80 亿元、2026 年上半年 3.39 亿元；收购产生的无形资产摊销 2025 年 3.86 亿元、2026 年上半年 2.46 亿元（喜马拉雅并表后上升）。两者在国际财务报告准则利润里已扣除，本模型不加回。', '2025', '2026-06-30', '已核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第四季度及全年未经审计财务业绩公告' LIMIT 1)),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '港元兑人民币 0.851，一年内人民币升值约 7%', '估值方法', '港元兑人民币（腾讯外汇）2025-10-20 0.9163 → 2026-10-22 0.8507；国家外汇管理局中间价 2026-10-22 每 100 港元 85.64 元。人民币升值使同样的港元股价折成人民币更低；港元盯住美元。', '2026-10-22', '2026-10-22', '已核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '腾讯行情 K 线：腾讯音乐港股日线与港元兑人民币（2025-10—2026-10）' LIMIT 1)),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), 'AI 音乐：供给多但有效播放少', '其他', '管理层与摩根大通转述：AI 音乐在供给端占比高，但没有成熟 IP 的纯 AI 歌曲只吸引很少的有效播放，播放量仍集中在知名歌曲和艺人；中金认为真人版权的核心地位中长期难以撼动。腾讯音乐自己的 AI 作歌工具已赋能 15 万音乐人、1,000 万普通用户。', '2026', '2026-09-07', '待核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '摩根大通：2026 年二季度业绩后投资者交流会要点（2026-08-16）及 3 月下调评级报告' LIMIT 1)),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '上游分散：国内前五大唱片公司约 29%，平台付给版权方约 45%—55%', '经营', '2022 年全球唱片公司在中国市场收入 CR3、CR5、CR10 为 23.6%、29.1%、35.2%（风华秋实招股书，卖方转引）；全球三大唱片加 Merlin 约 75%。国内平台付给版权方约相关收入的 45%—55%，全球约 60%—70%（录音 50%—55%、词曲 10%—15%）。上游分散、下游集中，是国内平台毛利率高于 Spotify 的结构性原因。', '2022', '2025-06-18', '待核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '卖方行业研究：在线音乐产业链、版权成本与竞争格局（国信、中金、长江、中信建投等，2024-12—2026-09）' LIMIT 1)),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '同业对比：付费率 24% 对 31%、39%；毛利率 44% 对 37%、30% 出头', '经营', '中金（2026-09-07，2026 年起为估算）2026 年二季度：腾讯音乐月活 5.25 亿、付费 1.28 亿、付费率 24.4%、ARPPU 12.5 元；网易云 2.21 亿、0.69 亿、31.2%、6.4 元；Spotify 7.77 亿、3.00 亿、38.6%、4.9 欧元。毛利率：腾讯音乐 44.2%（2025）、网易云 37.2%（2026H1）、Spotify 30% 出头；2023 年三家分别为 35.3%、26.7%、25.6%。腾讯音乐付费用户 2026 年一、二季度都在约 1.28 亿。', '2026Q2', '2026-09-07', '待核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '卖方行业研究：在线音乐产业链、版权成本与竞争格局（国信、中金、长江、中信建投等，2024-12—2026-09）' LIMIT 1)),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '网易云音乐 2026 年上半年：收入 +3.4%、会员订阅 +5.3%、毛利率 37.2%', '经营', '收入 39.59 亿元（+3.4%）；在线音乐 30.67 亿元，会员订阅 26.01 亿元（+5.3%，会员规模增长约 13%、学生会员占比上升使 ARPPU 约 −7%）；毛利率 37.2%（+0.8pt）；销售费用率 7.5%（上年同期 4.3%）；经调整经营利润 7.97 亿元（−12%）；DAU/MAU 30% 以上，留存率与续费率提升；注册独立音乐人超 125 万；上半年回购约 9.67 亿港元。', '2026H1', '2026-06-30', '待核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '网易云音乐 2026 年中期业绩点评（光大、东财、浦银国际、华兴、中金）' LIMIT 1)),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '汽水音乐的打法：抖音热歌、对三大唱片“必采”、曲库约 5,000 万首', '经营', '汽水前 1,000 首热歌 86% 来自抖音、54% 从抖音冷启动走红（2024 年）；“抖汽互通”：版权方只授权抖音不授权汽水，可能影响抖音对其内容的推广；对三大唱片、太合“必采”，即使 ROI 未打正也采购，对头部艺人“单点突破”拿非独家内容。汽水曲库约 5,000 万首，已获三大唱片部分授权（非全曲库）；腾讯音乐约 2.6 亿首、覆盖 95% 以上华语热门（含周杰伦、S.H.E. 等），网易云约 1.6 亿首。', '2024', '2025-12-07', '待核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '卖方行业研究：在线音乐产业链、版权成本与竞争格局（国信、中金、长江、中信建投等，2024-12—2026-09）' LIMIT 1)),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '自制音乐播放份额约 20%—30%，已超过三大唱片', '经营', '中金估计 2025 年二季度腾讯音乐自制音乐播放份额 20%—30%，已超过三大唱片在平台的播放份额（约 20%）；部分自制音乐在付费墙内，有助于毛利率。', '2025Q2', '2025-09-09', '待核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '卖方行业研究：在线音乐产业链、版权成本与竞争格局（国信、中金、长江、中信建投等，2024-12—2026-09）' LIMIT 1)),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '经营性投入资本约等于商誉，剔除商誉后为负', '财务', '2025 年末：归母权益 802.87＋少数股东 27.63＋带息负债 38.13−现金与定期存款 380.43−以公允价值计量的金融资产 262.31−权益法投资 16.59−其他投资 3.86＝205.44 亿元，几乎等于商誉 205.21 亿元。2025 年核心经营利润（毛利−经营费用）96.78 亿元，按 17.5% 税率税后约 79.8 亿元，对含商誉的经营性投入资本回报约 39%（2024 年约 32%）。', '2025', '2025-12-31', '已核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第四季度及全年未经审计财务业绩公告' LIMIT 1)),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '销售费用率约 3%，2026 年一季度销售费用 +36%', '财务', '销售及市场推广开支 2024 年 8.65 亿元（收入的 3.0%）、2025 年 9.41 亿元（2.9%）；2026 年一季度 2.71 亿元（+36%，管理层称战略性加大获客，投放广点通、字节等渠道）、二季度 2.36 亿元（+9.3%，2.6%）。网易云 2026 年上半年 7.5%。', '2025', '2026-06-30', '已核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2026 年第二季度未经审计财务业绩公告' LIMIT 1)),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '版权授权：期限 1—3 年，最低保底＋收入分成', '经营', '与唱片公司的录音分销与授权协议期限 1—3 年，费用为最低保底授权费加收入分成；与音著协为框架协议（保底加按收入比例）；个人艺人以收入分成为主（招股书，外资研报转引）。2020 年起监管要求按保底金加分成支付版权费。', '2025', '2025-10-28', '待核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '卖方行业研究：在线音乐产业链、版权成本与竞争格局（国信、中金、长江、中信建投等，2024-12—2026-09）' LIMIT 1)),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '续费率 80% 以上；付费墙比例说法不一', '经营', '国信行业交流（2025-06）：腾讯音乐续费率 80% 以上，付费墙比例接近 60%—70%，网易云约 30%；同一机构 2025-05 的另一场交流称腾讯付费墙占比“20% 多”（口径可能不同：歌曲数量占比与播放占比）。两种说法并列，待核验。中金（2025-04）：网易云平均付费墙约为腾讯音乐的一半。', '2025', '2025-06-20', '待核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '券商组织的行业专家与业内交流纪要（国信 2025-05、06、11；弘则 2025-06；汽水音乐专题 2026-06；中金业绩会纪要与月度交流）' LIMIT 1)),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), 'AI 音乐：日上传量约 40%，播放只占 1%—3%', '其他', '中金（2026-07）：AI 音乐日上传量占比约 40%，实际播放量占比只有 1%—3%。三大唱片推动 AI 音乐标识与“AI 歌曲上榜准则”，以训练数据合法授权为前提；腾讯音乐、网易云目前不给 AI 歌曲结算版税（产业公众号）。', '2026', '2026-08-21', '待核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '卖方行业研究：在线音乐产业链、版权成本与竞争格局（国信、中金、长江、中信建投等，2024-12—2026-09）' LIMIT 1)),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '监管：2021 年解除独家版权，2026 年喜马拉雅收购附条件批准', '政策', '2021 年 7 月市场监管总局责令腾讯解除独家音乐版权；2026 年 5 月市场监管总局附加限制性条件批准收购喜马拉雅，限制期五年，涉及免费内容比例和非独家授权等（中金月度交流转述，公告原文未下载）。', '2026', '2026-05-21', '待核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '券商组织的行业专家与业内交流纪要（国信 2025-05、06、11；弘则 2025-06；汽水音乐专题 2026-06；中金业绩会纪要与月度交流）' LIMIT 1)),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026 年 6 月末：现金等 442.2 亿元、带息负债 168.8 亿元、对外投资 228.4 亿元', '财务', '2026 年 6 月 30 日合并资产负债表：现金及现金等价物 236.98、定期存款（流动 67.61、非流动 136.40）、短期投资 1.23，合计 442.22 亿元；借款 131.39（非流动 71.42、流动 59.97）、应付票据 33.90、租赁负债 3.55，带息负债合计 168.84 亿元；以公允价值计量且其变动计入其他综合收益的金融资产 191.47、权益法投资 26.91、其他投资 10.06（非流动 9.34、流动 0.72），对外投资合计 228.44 亿元；少数股东权益 28.01 亿元。2026 年 9 月新发 10 亿美元票据，所得款项用于再融资与回购，发行当时净现金不变。', '2026-06-30', '2026-06-30', '已核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2026 年第二季度未经审计财务业绩公告' LIMIT 1)),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '境内未分派利润 172.5 亿元，汇出预提税约 17.3 亿元（2025 年末）', '财务', '2025 年年报：截至 2025 年末，中国附属公司及可变利益实体未计入预扣税的未分派利润 172.47 亿元，未确认的所得税负债 17.25 亿元（即按 10% 预提税计）；2024 年末分别为 174.53 亿元、17.45 亿元。境内资金汇出还受外汇管理与法定储备金限制（每年至少提取税后利润的 10%，直到达到注册资本的 50%）。', '2025', '2025-12-31', '待核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '腾讯音乐 2025 年年报' LIMIT 1)),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '收购摊销：2026 年二季度 1.57 亿元，全年化约 9 亿元', '财务', '收购及企业合并产生的无形资产和其他资产摊销（非国际财务报告准则调整项）：2024 年 4.40、2025 年 3.86 亿元；2026 年一季度 0.89、二季度 1.57 亿元（喜马拉雅自 5 月 18 日并表 44 天）。按喜马拉雅满季度推算约 2.3 亿元/季、2027 年约 9 亿元。口径含“版权公允价值调整”（取得的版权使用权在合同期内摊销），合同到期后需按市价重新采购。', '2026Q2', '2026-06-30', '已核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2026 年第二季度未经审计财务业绩公告' LIMIT 1)),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '倍数参照：同业约 10 倍，卖方 9—17 倍，市场隐含核心倍数约 5.5 倍', '估值方法', '同业：网易云音乐 2026 年 8 月末约 10 倍 2026E 经调整市盈率；卖方对腾讯音乐：摩根大通 9 倍 2027E（目标价 36 港元）、另一家 12 倍 2026E（44.9 港元）、华泰 17 倍 2026E（61.29 港元）、广发分部估值 13.35 美元/ADS；摩根士丹利对对外持股给予 30% 控股折价、美元 WACC 14%。腾讯音乐 2025 年中约 26—28 倍、2026 年 3 月约 15 倍。按本模型基准，市场给核心业务的隐含倍数约 5.5 倍（相当于零增长下约 18% 的要求回报）。', '2026-10-22', '2026-10-22', '待核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '岗底斯：卖方 2026 年中报点评（国信、光大、广发、华泰等）与外资估值' LIMIT 1));

INSERT INTO vi_thesis_base (company_id, code, title, category, status, confidence, bull_case, bear_case, bull_rebuttal, bear_rebuttal, verdict, decisive_evidence, mind_changer, model_impact, external_view, debated_on, check_metric, check_op, check_threshold, check_years) VALUES
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), 'T1', '上游议价权与头部曲库，在取消独家、AI 兴起后仍是护城河（毛利率守得住）', '经营', '成立', '中', '1）结构没变（V2、M1）：毛利率 44% 仍高于网易云（37%）和 Spotify（30% 出头）。2）头部曲库（M2）：约 2.6 亿首、覆盖 95% 华语热门，汽水只有约 5,000 万首，经典与港台版权缺口大；会员 20—40 元/月仍是行业最高价。3）AI 音乐“供给多、播放少”（V9），播放仍集中在头部真人作品；三大唱片推动的“先授权”规则，保护的正是持牌平台。4）自制音乐播放份额 20%—30% 已超过三大唱片，平台在向上游延伸。', '1）独家没了：网易云、汽水都拿到了三大唱片的部分授权，字节对三大“必采”、对头部艺人“单点突破”，曲库差距可以用钱缩小。2）发现入口变了（V5）：版权方必须在抖音宣发，“抖汽互通”让版权方有动力授权给汽水。3）管理层自己把竞争描述为“曲库成本差异”：对手用更便宜的曲库和 AI 翻唱填充，用低价换用户。4）高毛利主要来自产业结构，网易云也同样受益（毛利率 2023 年约 27% → 37%），说明这不是腾讯音乐独有的护城河。5）版权方若转向更高分成，或给对手更低价的授权，这项优势会变成成本劣势；AI 长期削弱版权稀缺性。', '轻度用户本来就不是利润来源；超级会员稳定、ARPPU 还在升（2025 年四季度 11.9 元），说明核心用户仍为完整曲库和音质付费。产业结构对两家都有利，但腾讯音乐占三分之二的份额，议价力最强。', 'ARPPU 的提升越来越依赖超级会员占比和喜马拉雅并表；剔除喜马拉雅后会员收入内生约持平，付费用户两个季度没有净增。护城河如果真宽，增长不会这么快停下来。', '护城河真实，但在收窄：它从“独占资源”（独家版权，见伪壁垒 M7）变成了“规模带来的成本与完整度优势”（上游议价权＋曲库）。对核心付费用户仍有效（2026 年二季度毛利率 44.2%，高于摩根大通设的 42% 警戒线；超级会员稳定），对轻度用户已基本失效。定为：上游议价权＝真实壁垒（强、稳定），头部曲库＝局部优势（中、削弱）。', '单季毛利率是否守在 42%—43% 以上；版权续约条款（保底与分成比例）；演出与周边的收入占比（毛利率低）；剔除喜马拉雅后会员收入同比；字节是否拿到头部华语全曲库授权。', '改判为反方占优：毛利率连续两个季度低于 42%，或字节以独家或首发方式拿下周杰伦等头部版权，或三大唱片要求的分成比例明显上调。自动检查：年度毛利率连续两年低于 40%。', '不改参数', '看多方（中金 2026-09、长江 2026-04、中信建投）：真人版权秩序韧性强，汽水只影响泛用户，上限约 2 亿月活。看空方（摩根大通 2026-03、08）：订阅增长不再线性，估值框架弱化；产业公众号：竞争从“谁有歌”变成“歌在哪火”。岗底斯观点 PK 三次调用均超时、技能脚本未配置授权，本次未取得其结果。', '2026-10-22', '毛利率', '<', 0.4, 2),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), 'T2', '腾讯生态能为腾讯音乐提供与抖音相当的流量入口', '经营', '成立', '中', '1）销售费用率约 3%，网易云 7.5%：腾讯生态长期让获客几乎免费（B3、M4）。2）腾讯音乐已接管微信视频号音乐垂类运营，打通“视频号发现→QQ 音乐全曲收听”；QQ 音乐接入元宝、小微。3）微信支付为轻量 App 引流，视频号仍在增长。', '1）音乐的发现起点在抖音（V5），版权方首选在抖音宣发。2）管理层称视频号对 2026 年下半年没有实质贡献，是期权而不是现有能力。3）2026 年一季度销售费用 +36%，而且向字节等渠道买量：说明腾讯生态的流量不够用了。4）腾讯控股可能让腾讯音乐为视频号提供音乐内容，利益不一定一致（治理见 T5）。', '视频号的音乐生态才刚开始建设；腾讯有微信这个最大的入口，时间站在腾讯一边。', '“时间站在腾讯一边”是期待，不是证据；过去三年抖音已经把发现入口拿走了。', '成立（2026-10-28 改判，依据是判断而非新数据）：视频号的导流开关在腾讯手里，识曲跳转、音乐垂类运营等基础设施已就位，日活约 6.5 亿、仍在增长，需要时可以像抖音一样加码导流，而且不用花钱；微信、QQ 的入口继续让获客几乎免费（M4）。保留：视频号用户偏中老年，“造爆款”能力仍落后抖音，反方 1）—3）尚未被数据推翻。', '销售费用率是否回落到 3% 以下；视频号到 QQ 音乐的导流数据（公司是否披露）；QQ 音乐月活同比；年报或业绩会里视频号推出的热歌案例。', '若到 2027 年年报：销售费用率仍高于 3.5%、QQ 音乐月活同比降幅扩大到 5% 以上、且没有视频号带出热歌的案例，改回存疑。', '不改参数', '长江（2026-09）：汽水主要分流酷狗、酷我，QQ 音乐冲击有限。产业公众号（2026-05）：越来越多音乐的爆发起点来自抖音。', '2026-10-28', NULL, NULL, NULL, NULL),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), 'T3', '汽水音乐的免费模式只分流轻度用户，不侵蚀付费核心（付费用户不缩水）', '经营', '观察', '中', '1）用户重合度：汽水与酷狗重合约 60%、与 QQ 音乐居中、与网易云约 30%；分流集中在酷狗、酷我的下沉轻度用户。2）QQ 音乐月活同比只降 0.7%，酷狗、酷我降 10% 以上。3）进入者的用户质量弱、增速在放缓（留存、打开率与会员渗透率见竞争对手：汽水音乐；中信建投判断其月活上限约 2 亿），番茄音乐月活已在环比下降。4）管理层称超级会员（2025 年末超过 2,000 万）未受影响，流失来自价格敏感用户；付费用户至今没有下降。', '1）付费用户增长已经停了：增速从 2023 年 +20.6% 降到 2025 年 +5.3%（四季度 1.274 亿），中金估算 2026 年一、二季度都在约 1.28 亿；EP 平台显示 6、7 月净增环比下降；月活 5.28 亿（−5%）。2）公司在 2026 年停止披露季度月活、付费用户和 ARPPU：停披本身就是信号，市场无法验证“核心不受影响”。3）价格锚被拉低：汽水 8 元/月、看广告免费，腾讯音乐被迫推出酷狗免费版、广告会员，这会稀释 ARPPU；网易云也在加大折扣和投放。4）防守要花钱：2026 年一季度销售费用 +36%。5）若用户习惯免费，付费渗透率和定价权会同时下降；AI 生成音乐还会压低内容的边际成本（V9）。', '付费用户持平而不是下降，说明核心盘守住了；广告会员是把原本流失的用户转为广告收入，不是降级。中金估算 2026 年二季度 ARPPU 约 12.5 元，仍在上升。', '12.5 元可能含喜马拉雅会员，普通音乐会员的单价没有证据在升；“持平”恰好意味着付费渗透率提升这一增长引擎已经熄火，而估值里的长期增长需要它。', '势均力敌：存量没有崩塌，但增长引擎停了。分流确实集中在酷狗、酷我的轻度层，核心付费层暂未流失；然而“付费用户增长”这一过去的主要驱动已经停止（订阅内生增长从 +16% 降到约持平），ARPPU 的提价空间也被免费模式压住。2026 年年报的年末付费用户是第一个硬验证。（原论点标为“存疑”，与辩论裁决不一致，合并后按辩论结论记为“观察”。）', '2026 年年报的年末付费用户（只在年报披露）；会员服务收入（剔除喜马拉雅）同比；第三方监测的付费用户净增；汽水、番茄的月活与付费是否连续放缓。', '反方胜：年末付费用户低于 1.22 亿（−4%），或会员收入内生同比连续两个季度为负。正方胜：汽水月活见顶回落，且会员内生恢复中个位数增长。自动检查：年末付费用户同比连续两年下降。', NULL, '中信建投（2026-03）：汽水上限约 2 亿月活，下半年增速放缓。摩根大通（2026-08）：会员下行好于担忧，但回升时间不明朗，若连续 3 个季度内生增长为零或负就是负面证据。', '2026-10-22', '业务量同比', '<', 0, 2),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), 'T4', '多元变现（超级会员、演出周边、喜马拉雅长音频）能接替放缓的订阅，并加深护城河', '经营', '存疑', '中', '1）营销及消费类收入高速增长（B5），超级会员超过 2,000 万；总收入仍在增长（2026 年上半年 +6.5%）。2）IP 权益（演唱会优先购票、Bubble、周边、喜马拉雅长音频）让高价值用户的转换成本更高，这是汽水没有的（M5）。3）喜马拉雅：约 140 亿元对价（现金约 80 亿元＋股份）买入长音频龙头，年化收入约 34 亿元，毛利率接近 60%（行业交流口径），并表后对毛利率是正贡献；长音频放进超级会员权益可提升留存与 ARPPU，后台系统整合可降本。', '1）演出与经纪毛利率低、波动大，管理层已提示 2026 年下半年毛利率同比略降：增长质量在下降（高毛利订阅放缓、低毛利演出加速）。2）广告承压（V4），社交娱乐二季度 −16%，多元业务里只有演出在增长，季度波动大。3）喜马拉雅过去多年亏损、近年才盈利（待核验），长音频付费率低；7 月起恢复投放，整合要花钱；约 140 亿元的对价里商誉约 92 亿元。4）演出、周边、经纪都不难复制（字节也在办音乐节），不是壁垒，只是收入。', '毛利率“略降”而不是大降，说明多元业务没有破坏利润率；粉丝权益提高的是超级会员留存，价值在会员端而不在演出本身的毛利。', '没有披露超级会员留存或 ARPPU 拆分，“提高留存”只是推断；在数据出来之前，它只能算收入来源，不算壁垒。', '多元变现目前是“守住总量”的收入来源，而不是已被证明的壁垒：它让收入保持增长，但不提高利润率。判定 IP 与粉丝经济（M5）为“待验证、弱、增强”；喜马拉雅 2027 年是第一个完整年度，回报尚未证明。与模型一致：收入每年 +3%—6%，核心利润率持平而不扩张。', '超级会员数与留存（年报是否披露）；演出业务毛利；喜马拉雅收入与利润贡献（公司是否单独披露）、超级会员交叉销售、商誉减值测试；季度收入同比及会员、营销及消费类收入拆分；社交娱乐降幅。', '若年报披露超级会员留存明显高于普通会员、且营销及消费类业务毛利率稳定在 30% 以上，可改为“局部优势”。喜马拉雅出现商誉减值或收入连续两个季度下降，则确认反方。自动检查：营业收入同比连续两年下降。', '不改参数', '广发（2026-08）：喜马拉雅年化收入约 34 亿元、经营利润约 5.4 亿元，2027 年释放协同。华泰（2026-08）：音乐主业增长承压趋势显著，下调目标价。', '2026-10-22', '营业收入同比', '<', 0, 2),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), 'T5', '治理与股东回报：腾讯控股下，利润和超额现金会持续回到少数股东手里', '治理', '观察', '低', '1）2026 年二季度单季回购 4 亿美元（约占股本 2.8%），9 月发行 10 亿美元票据，用途写明含回购；管理层称准备新一轮回购、探讨不同的股东回报方式。2）2023 年起每年分红，每股 0.07 → 0.09 → 0.12 美元；回购 2021—2024 年每年 12—35 亿元。3）净现金约 273 亿元、经营现金流约 100 亿元/年、资本开支只要约 12 亿元：钱足够，再投资需求很低（B9、T6）。4）扣除净现金和对外投资后，经营业务只值约 4 倍利润，此时回购的每股增值效果大。5）腾讯控股是控股股东（列为非全资附属公司），在视频号、元宝、广告与支付上提供生态协同，也从回购中被动增持，利益大体一致。', '1）历史回报率只有 26%—60%（2023—2025 年）：2025 年回购只有 3.9 亿元，回报率 26%（剔除一次性收益后 33%）。2）刚花约 80 亿元现金加新股收购喜马拉雅：现金也可能继续用于并购（T4）。3）现金主要在境内，汇出要缴预提税并受外汇管理；借约 5% 的美元去回购、同时在境内存约 2% 的人民币，说明资金调度有摩擦（T7）。4）没有正式的股东回报政策（比例或金额承诺）；控股股东可能让腾讯音乐承担生态任务（如接手视频号音乐运营），而不是最大化股东回报。5）开曼注册、以协议控制方式经营境内业务、不同投票权，在纽约和香港上市：中美监管与上市地风险。', '2026 年的行为已经和过去不同：单季 4 亿美元是历史最大，并专门发债支持；借美元回购恰恰说明管理层愿意付成本也要回报股东。', '一个季度的行为不等于政策；10 亿美元计划还剩约 5.44 亿美元、2027 年 3 月到期，新计划规模未知。利润全部分配并逐步释放多余现金，需要每年约 15 亿美元（股息约 4—5 亿、回购约 11 亿），相当于把二季度的单季节奏变成常态。', '方向向好，但证据不足以认定利润和多余现金会全部回到股东：2026 年的回购与发债是迄今最强的信号，但还没有正式政策。治理整体可信，估值上给折价（风险溢价 7%，J-R）。估值把约 212 亿元自由现金按“能分的钱”全额计入（J-CASH），这条论点决定这部分最终能有多少回到股东手里。', '新一轮回购计划的规模与期限；2026 年度股息；境外资金来源（新发债、境内分红汇出）；关联交易（腾讯云、广告、版权）与董事会构成。', '正方胜：宣布每年 10 亿美元以上的回购或明确的股东回报比例。反方胜：现金再用于大额并购，或回购节奏回到 2025 年的水平，或出现明显损害少数股东的关联交易。自动检查：股东回报率（股息＋回购÷归母净利润）连续两年低于 50%。', '派息率（股东回报率）是第一跟踪项', '中金（2026-09）：腾讯音乐 2026 年股东回报率约 2.9%（按当时口径，未含新一轮回购）。摩根大通（2026-08）：把“回购价持续低于公允价值”列为资本回报的验证条件。', '2026-10-22', '派息率', '<', 0.5, 2),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), 'T6', '利润是真现金：经营现金流覆盖净利', '财务', '成立', '高', '轻资产、负营运资本（机制见 B9）：经营现金流 2024—2025 年约 102 亿元，约等于经调整净利；资本开支每年 10—12 亿元。这让股息＋回购可以接近 100% 的利润（T5）。', '收入停止增长时，负营运资本不再释放现金；版权预付款若增加会占用现金。', NULL, NULL, '成立：2026 年上半年经营现金流 52.0 亿元（+25%）。', '年度经营现金流÷归母净利润；资本开支；应付版权方与递延收入的变化。', '自动检查：经营现金流÷归母净利润连续两年低于 0.8。', NULL, NULL, NULL, '经营现金流÷归母净利润', '<', 0.8, 2),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), 'T7', '借钱回购，但保持净现金', '财务', '成立', '高', '2026 年起用美元借款和票据（约 165 亿元）支付喜马拉雅现金对价和境外回购，境内保留现金与定期存款 442 亿元，净现金约 273 亿元。借美元（约 5%）、存人民币（约 2%）有利差成本，但避免了境内资金汇出的税费与审批。', '若继续借钱回购、而境内现金用于并购，净现金会转为净负债。', NULL, NULL, '成立。', '净现金、带息负债与平均债务成本；利息收入与利息支出。', '自动检查：由净现金转为净负债（净负债÷EBITDA 大于 0）。', NULL, NULL, NULL, '净负债÷EBITDA', '>', 0, 1);

INSERT INTO vi_lnk_thesis_facts (thesis_id, fact_id, "createdAt", "updatedAt")
SELECT x.id, y.id, now(), now() FROM (VALUES ('T1', '上游分散：国内前五大唱片公司约 29%，平台付给版权方约 45%—55%'), ('T1', '毛利率从 2021 年 30% 升到 2025 年 44%，2026 年下半年同比略降'), ('T1', '同业对比：付费率 24% 对 31%、39%；毛利率 44% 对 37%、30% 出头'), ('T1', '汽水音乐的打法：抖音热歌、对三大唱片“必采”、曲库约 5,000 万首'), ('T1', 'AI 音乐：日上传量约 40%，播放只占 1%—3%'), ('T1', '自制音乐播放份额约 20%—30%，已超过三大唱片'), ('T1', '订阅（会员）收入增速：+26% → +16% → 内生约持平'), ('T2', '销售费用率约 3%，2026 年一季度销售费用 +36%'), ('T2', '管理层：竞争冲击轻度用户，超级会员稳定'), ('T2', '汽水音乐的打法：抖音热歌、对三大唱片“必采”、曲库约 5,000 万首'), ('T3', '汽水音乐月活 1.7 亿，定价约为 QQ 音乐的三分之一'), ('T3', '付费用户 1.274 亿、ARPPU 11.9 元，月活连续下滑'), ('T3', '订阅（会员）收入增速：+26% → +16% → 内生约持平'), ('T3', '管理层：竞争冲击轻度用户，超级会员稳定'), ('T3', '同业对比：付费率 24% 对 31%、39%；毛利率 44% 对 37%、30% 出头'), ('T3', '销售费用率约 3%，2026 年一季度销售费用 +36%'), ('T4', '2025 年收入 329.0 亿元（+15.8%），订阅 176.6 亿元'), ('T4', '2026 年二季度：喜马拉雅并表 4.07 亿元，社交娱乐 −16%'), ('T4', '2026 年上半年：收入 +6.5%、非国际财务报告准则归母 +5.6%'), ('T4', '毛利率从 2021 年 30% 升到 2025 年 44%，2026 年下半年同比略降'), ('T4', '喜马拉雅：总对价约 140 亿元，现金约 80 亿元，商誉约 92 亿元'), ('T4', '管理层：竞争冲击轻度用户，超级会员稳定'), ('T4', '社交娱乐收入持续收缩'), ('T5', '回购与分红：2026 年二季度回购 4 亿美元，新一轮在准备'), ('T5', '现金等 442 亿元，借款与票据约 165 亿元'), ('T5', '2026 年 9 月发行 10 亿美元票据（5.05%、5.65%）'), ('T5', '对外投资 191 亿元：Spotify、UMG、WMG、SM 娱乐'), ('T5', '喜马拉雅：总对价约 140 亿元，现金约 80 亿元，商誉约 92 亿元'), ('T5', '境内未分派利润 172.5 亿元，汇出预提税约 17.3 亿元（2025 年末）'), ('T6', '经营现金流约 100 亿元，与经调整净利相当'), ('T6', '经营性投入资本约等于商誉，剔除商誉后为负'), ('T6', '2026 年上半年：收入 +6.5%、非国际财务报告准则归母 +5.6%'), ('T7', '现金等 442 亿元，借款与票据约 165 亿元'), ('T7', '2026 年 9 月发行 10 亿美元票据（5.05%、5.65%）'), ('T7', '2026 年 6 月末：现金等 442.2 亿元、带息负债 168.8 亿元、对外投资 228.4 亿元')) v(k1, k2)
JOIN vi_thesis_base x ON x.company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND x.code = v.k1 JOIN vi_fact_base y ON y.company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND y.title = v.k2;

INSERT INTO vi_judgment_base (company_id, code, title, fact_layer, judgment, transmission, parameter, affected_years, change_threshold, no_change_condition, counter_evidence, status) VALUES
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), 'J-S1', '主营①会员订阅（含长音频会员）：2027 年收入与利润率', '会员收入 2023—2025 年 120.96、152.3、176.6 亿元（+26%、+16%）；2026 年一、二季度 45.68、47.92 亿元，剔除喜马拉雅后约持平（摩根大通）。第四季度付费用户 2025 年 1.274 亿，超级会员 2,000 万以上；2026 年两个季度付费用户没有净增。喜马拉雅年化收入约 34 亿元，2026 年 5 月起并表。公司只有一个经营分部，不披露分业务的成本与利润（2025 年报附注 2.5）。', '逐年（财务预测）：2026E 196、2027E 208、2028E 213 亿元。估值用 2027 年：基准 208 亿元（音乐会员内生每年约 +2%，到约 184 亿元，加喜马拉雅会员约 24 亿元）；悲观 195、乐观 218。利润率（税前核心经营利润÷收入，不含收购摊销与利息）：基准 42%、悲观 35%、乐观 45%。会员是利润最高的一块：版权按分成付费，没有演出、周边那样的直接制作成本。三块的利润率是分摊估算，约束是加总必须等于公司整体：基准三块合计税前 112.1 亿元、利润率 30.1%，与 2027 年核心经营利润 106.3 亿元加回收购摊销约 6 亿元一致。税率 17.5%，归母 97%（少数股东约 3%）。', '收入每 ±10 亿元，基准每股约 ±1.3 元；利润率每 ±1 个百分点，每股约 ±0.7 元。', '经营分部·S1 收入、利润率；财务预测·会员订阅收入', '2027（三情景）', '年报会员服务收入偏离 2027 年路径 5% 以上；剔除喜马拉雅后连续两个季度同比为负。', '单季波动。', '超级会员提价与长音频捆绑若成功，收入可能达到乐观的 218 亿元；若汽水的分流蔓延到付费核心，悲观的 195 亿元也不算保守。利润率是分摊值，不能直接验证，只能用公司整体利润率校核。', '已形成建议'),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), 'J-S2', '主营②非订阅音乐（广告、演出、周边、艺人经纪）：2027 年收入与利润率', '非订阅音乐收入 2025 年 90.7 亿元（+39%）；2026 年上半年 47.6 亿元（上年同期 40.6 亿元，+17%）。构成（摩根大通 2026-08）：广告约 45%（个位数增长）、演出与艺人管理约 30%（+70%—80%）、粉丝经济与数字专辑约 15%—20%（+20%—30%）。演出与周边毛利率低，占比上升使管理层预计 2026 年下半年毛利率同比略降。', '逐年（财务预测）：2026E 106、2027E 117、2028E 126 亿元。估值用 2027 年：基准 117 亿元（2026 年约 106 亿元，再 +10%，含喜马拉雅广告约 10 亿元）；悲观 105、乐观 125。利润率：基准 15%、悲观 12%、乐观 17%。广告利润率高，但演出、周边要付制作、场馆与代理成本，整块利润薄。倍数与会员相同（见 J-R），质量差异已体现在利润率里。', '收入每 ±10 亿元，基准每股约 ±0.5 元；利润率每 ±1 个百分点，每股约 ±0.4 元。', '经营分部·S2 收入、利润率；财务预测·非订阅音乐收入', '2027（三情景）', '年报非订阅收入偏离 2027 年路径 10% 以上；毛利率单季低于 42%。', '演出档期带来的季度波动。', '演出依赖头部艺人档期（如 G-Dragon 巡演），年度波动大；广告预算向抖音、视频号集中，广告只有个位数增长。', '已形成建议'),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), 'J-S3', '主营③社交娱乐（直播打赏）：持续收缩', '社交娱乐收入 2024 年 66.6 亿元、2025 年 61.8 亿元（−7%）；2026 年一、二季度 13.81、13.28 亿元（同比 −11%、−16%）。监管收紧与公司主动收缩。', '逐年（财务预测）：2026E 53、2027E 48、2028E 44 亿元。估值用 2027 年：基准 48 亿元（2026 年约 53 亿元，再 −10%）；悲观 42、乐观 50。利润率：基准 15%、悲观 10%、乐观 18%：主播分成后毛利低，规模萎缩时费用难以同步下降。倍数不用增长公式，按持续萎缩的永续年金 1÷(r−g)：g 基准 −8%、悲观 −10%、乐观 −5% → 6.0、5.0、7.9 倍。', '整块基准价值约 33 亿元，约每股 1 元：即使归零，影响也有限。', '经营分部·S3 收入、利润率、倍数；财务预测·社交娱乐收入', '2027（三情景）', '单季同比降幅超过 25%，或公司宣布关停、出售。', '季度波动。', '若监管进一步收紧或公司关停，这块价值归零（每股约 −1 元）；若收缩放缓，倍数偏低。', '已形成建议'),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), 'J-FIN', '财务预测：毛利率、费用率、利息与现金（2026E—2028E）', '毛利率 2023—2025 年 35.3%、42.3%、44.2%，2026 年上半年 44.5%；销售费用率 2025 年 2.9%、上半年 3.0%；管理费用率（行政开支，含研发、股权激励与收购摊销）2025 年 11.9%、上半年 11.9%。其他收入及收益 2025 年 36.9 亿元（含 23.7 亿元一次性收益）；融资成本上半年 0.51 亿元，6 月末借款 131.4 亿元，9 月再发 10 亿美元票据。经营现金流÷归母净利 2023—2025 年 1.49、1.55、0.93（剔除一次性约 1.18）；资本开支 10—12 亿元；净现金 2025 年末 342 亿元、2026 年 6 月末 273 亿元。', '毛利率 44.0%（管理层称下半年同比略降，演出占比上升）；销售费用率 3.1%、3.0%、3.0%；管理费用率 12.4%、12.5%、12.3%（喜马拉雅的费用与收购摊销全年计入）。2027E 核心经营利润 106.3 亿元、利润率 28.5%。其他收入及收益（利息收入为主）12、9、8 亿元；融资成本 4、7.5、7.5 亿元；税率 17.5%，少数股东 3%；经调整口径加回股权激励约 7 亿元与收购摊销 6、9、9 亿元。现金：经营现金流＝归母净利×1.15；资本开支 12—13 亿元；股东回报（现金口径）78、80、85 亿元；2026 年其他现金变动 −80 亿元（喜马拉雅现金对价；借款同时增加现金与负债，不影响净现金）。', '估值模型不读这里的利润，只用三块收入与利润率；校核：2027E 核心经营利润＋七成收购摊销，应约等于估值模型三块合计的税前利润（112.1 亿元）。', '财务预测·毛利率、费用率、其他收入、融资成本、税率、股权激励与收购摊销、现金转化、资本开支、股东回报、其他现金变动', '2026—2028', '季报毛利率或费用率偏离 1 个百分点以上；新回购计划或大额并购。', '单季波动。', '卖方经调整归母 2026—2028 年约 98、109、118 亿元，与这里的经调整口径可比但更乐观；若演出占比继续上升，毛利率可能降到 43% 以下。', '已形成建议'),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), 'J-R', '折现率与倍数', '中债 10 年 1.64%（2026-10-22）。净现金、轻资产，但面对字节的免费模式与 AI 冲击；开曼注册、协议控制、境外上市，腾讯控股不同投票权。价值驱动公式：市盈率＝(1−g÷新增投资回报率)÷(r−g)。有机增长几乎不需要资本（经营性投入资本约等于商誉），新增长主要靠并购：喜马拉雅初始回报约 4%。同业约 10 倍，卖方 9—17 倍，市场隐含核心约 5.5 倍。', '风险溢价 7.0%：基准折现率 8.6%，悲观 10.0%、乐观 7.6%。会员订阅与非订阅音乐：永续增长基准 2%、悲观 0、乐观 3%，新增投资回报率 15%、15%、20% → 13.1、10.0、18.5 倍。社交娱乐另按萎缩年金（见 J-S3）。2027 年盈利折回资产负债日（2026-06-30）半年。不手填倍数，倍数随折现率与增长率联动。', '折现率 +1 个百分点，基准每股约 −4 元；会员与非订阅的倍数每 ±1 倍，每股约 ±2.6 元。', '估值模型·无风险利率、风险溢价；情景·折现率、永续增长率、新增投资回报率', '全部', '长期利率变化超过 0.5 个百分点；竞争格局或增长判断改变（T1、T3）；新的大额并购。', '市场情绪带来的倍数波动。', '外资常用 12%—14% 的美元 WACC（摩根士丹利 14%），换成人民币约 10%—11%；市场只给约 5.5 倍，隐含约 18% 的回报或利润持续萎缩。', '已形成建议'),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), 'J-OPCASH', '经营所需现金：先收钱、后付钱，主营只需约 40 亿元周转', '收付结构（2025 年报附注）：会员费预收，递延收入 38.4 亿元（2026 年 6 月 48.9 亿元，含喜马拉雅）；版权费后付，应付账款 62.8 亿元，约为 125 天的营业成本；应收账款 39.0 亿元（约 43 天收入），其中 22.5 亿元是腾讯支付渠道代收、尚未转来的用户付款；存货 0.4 亿元（周边商品）；预付款项主要是预付版权保底金 23.8 亿元。浮存金（应付账款＋递延收入＋其他应付及应计费用＋应付税项＋长期应付，减应收、预付及其他应收、存货）2021—2025 年末 42、61、57、72、70 亿元，2026 年 6 月 85 亿元，约为收入的 20%—24%；2021—2023 年收入降 11% 时反而增加。其他应付及应计费用年末 35.6 亿元，主要是应付工资福利、广告营销与租金等预提费用（24.5 亿元），都是经营项；但每年一季度末跳升 15—19 亿元、二季度回落，与 3 月宣派股息的时间吻合（推测含已宣派未付的股息，年报只披露年末明细）。付现成本（营业成本＋销售费用＋管理费用−折旧摊销）2021—2025 年 275、240、220、201、219 亿元，每月 17—23 亿元；2027E 约 250 亿元，每月约 21 亿元。', '主营几乎不占用营运资金：会员费先收、版权费后付；应收大部分是渠道代收的用户付款，风险低；没有实质库存。所以要从现金里留给主营的只有三块：①日常周转：一个月付现成本，约 21 亿元；②季节性波动：剔除股息应付后，浮存金季度之间最大一次回落约 11 亿元（2025 年一季度到二季度），取 10 亿元；③压力缓冲：收入下降 10% 时浮存金约收回 8 亿元（373×10%×22%）。合计约 40 亿元。浮存金本身（约 85 亿元）不扣：它随业务滚动存在，由以后的经营现金偿还，主营的盈利×倍数已经承担了这部分成本；需要全部扣除的是业务大幅萎缩，那时主营价值本身已大幅下降，不重复扣。', '经营所需现金每 ±10 亿元，每股约 ∓0.32 元（约 0.38 港元）；从原来的 20 亿元调到 40 亿元，基准每股约 −0.75 港元。', '分部估值项·C3 经营所需现金', '资产负债日 2026-06-30', '浮存金占收入比例跌破 15%；应收账款天数超过 60 天；版权付款改为以预付为主。', '季度波动。', '压力幅度是设定值：按收入下降 20% 计，③约 16 亿元，合计约 47 亿元。公司实际持有的现金及等价物近两年在 85—237 亿元之间，远高于此，那是公司愿意留多少钱，不代表经营需要。', '已形成建议'),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), 'J-CASH', '可分配的自由现金：扣掉有息负债与经营所需', '2026 年 6 月末：现金等 442.22 亿元、带息负债 168.84 亿元。境内未分派利润 172.5 亿元，对应 10% 预提税 17.3 亿元（2025 年末），2026 年上半年境内利润约 45 亿元。浮存金（应付账款、递延收入、其他应付、应付税项、长期应付，减应收、预付与存货）：2021—2025 年末 35、54、51、67、67 亿元，2026 年 6 月 81 亿元（含喜马拉雅）；2021—2023 年收入降 11%，浮存金反而增加。核心自由现金流 2022—2025 年合计 275 亿元，为税后核心经营利润的 1.33 倍；同期股息＋回购只有 104 亿元（38%），净现金从 194 亿元增至 343 亿元。', '自由现金＝现金 442.2 − 带息负债 168.8 − 经营所需 40 − 汇出预提税 21.7 ≈ 212 亿元，三情景相同。①带息负债全额扣除：借款与票据要还，借来的钱不是股东的。②经营所需现金 40 亿元：日常周转、季节性波动与压力缓冲三块，测算与“为什么不扣全部浮存金”见 J-OPCASH。③汇出预提税：现金大部分在境内，分给境外股东前要缴 10% 预提税（17.3＋上半年约 4.5 亿元）。④存量与流量不重复：6 月末之前攒下的现金算在这里，之后产生的现金在主营价值里。⑤这是“能分的钱”，不是“会分的钱”：过去四年只还了 38%，能否回到股东手里见 T5。', '每 10 亿元自由现金约合每股 0.32 元（约 0.38 港元）；若把浮存金全部扣除（再减约 45 亿元），每股约 −1.4 元。', '分部估值项·C1 现金、C2 带息负债、C4 资金汇出成本（C3 经营所需现金见 J-OPCASH）', '资产负债日 2026-06-30', '季度现金或借款变化超过 30 亿元；资金汇出安排变化。', '季度内的回购与股息（同时减少现金与股本，按市价回购对每股价值影响小）。', '如果现金被拿去做低回报并购（喜马拉雅初始回报约 4%）而不是回报股东，这部分价值要打折。', '已形成建议'),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), 'J-INV', '对外投资：按最新报告的账面价值打七折', '2026 年 6 月末：以公允价值计量的上市股权（Spotify、UMG、WMG 等）191.47 亿元，权益法投资 26.91、其他投资 10.06 亿元，合计 228.4 亿元。持股 0.8%—9.7%，没有控制权；2025 年投资所得股息 1.73 亿元。摩根士丹利按 236 亿元（2026 年 8 月）再打七折。', '全部按最新报告的账面价值打 7 折（扣 30%：控股折价、处置税费与流动性），三情景相同，约 160 亿元。每季报告出来后更新账面价值，不跟踪股价的日常波动。', '账面价值每 ±10%，每股约 ±0.5 元。', '分部估值项·C5 上市股权、C6 权益法投资、C7 其他投资', '资产负债日 2026-06-30', '新的季报或年报（更新金额）；出售或增持。', '持股市值的日常波动。', '这些股权多年未出售、分红很少，可能长期不变现，这正是打七折的原因；若出售并用于回购，折价可以收窄。', '已形成建议');

INSERT INTO vi_lnk_judgment_facts (judgment_id, fact_id, "createdAt", "updatedAt")
SELECT j.id, f.id, now(), now() FROM (VALUES ('J-S1', '订阅（会员）收入增速：+26% → +16% → 内生约持平'), ('J-S1', '付费用户 1.274 亿、ARPPU 11.9 元，月活连续下滑'), ('J-S1', '2026 年二季度：喜马拉雅并表 4.07 亿元，社交娱乐 −16%'), ('J-S1', '喜马拉雅：总对价约 140 亿元，现金约 80 亿元，商誉约 92 亿元'), ('J-S1', '管理层：竞争冲击轻度用户，超级会员稳定'), ('J-S2', '毛利率从 2021 年 30% 升到 2025 年 44%，2026 年下半年同比略降'), ('J-S2', '2026 年上半年：收入 +6.5%、非国际财务报告准则归母 +5.6%'), ('J-S2', '2026 年指引：净利率小幅承压，经调整 EBITDA 小幅增长'), ('J-S3', '社交娱乐收入持续收缩'), ('J-S3', '2026 年二季度：喜马拉雅并表 4.07 亿元，社交娱乐 −16%'), ('J-FIN', '毛利率从 2021 年 30% 升到 2025 年 44%，2026 年下半年同比略降'), ('J-FIN', '经营费用率从 2021 年 21% 降到 2025 年 15%'), ('J-FIN', '现金等 442 亿元，借款与票据约 165 亿元'), ('J-FIN', '2026 年 9 月发行 10 亿美元票据（5.05%、5.65%）'), ('J-FIN', '经营现金流约 100 亿元，与经调整净利相当'), ('J-FIN', '回购与分红：2026 年二季度回购 4 亿美元，新一轮在准备'), ('J-FIN', '卖方预期 2026—2028 年经调整归母约 98/109/118 亿元'), ('J-FIN', '收购摊销：2026 年二季度 1.57 亿元，全年化约 9 亿元'), ('J-R', '股价一年跌 63%：87.1 → 32.14 港元'), ('J-R', '倍数参照：同业约 10 倍，卖方 9—17 倍，市场隐含核心倍数约 5.5 倍'), ('J-R', '经营性投入资本约等于商誉，剔除商誉后为负'), ('J-R', '喜马拉雅：总对价约 140 亿元，现金约 80 亿元，商誉约 92 亿元'), ('J-OPCASH', '现金等 442 亿元，借款与票据约 165 亿元'), ('J-OPCASH', '2026 年 6 月末：现金等 442.2 亿元、带息负债 168.8 亿元、对外投资 228.4 亿元'), ('J-OPCASH', '版权授权：期限 1—3 年，最低保底＋收入分成'), ('J-CASH', '2026 年 6 月末：现金等 442.2 亿元、带息负债 168.8 亿元、对外投资 228.4 亿元'), ('J-CASH', '境内未分派利润 172.5 亿元，汇出预提税约 17.3 亿元（2025 年末）'), ('J-CASH', '现金等 442 亿元，借款与票据约 165 亿元'), ('J-CASH', '2026 年 9 月发行 10 亿美元票据（5.05%、5.65%）'), ('J-CASH', '经营现金流约 100 亿元，与经调整净利相当'), ('J-CASH', '经营性投入资本约等于商誉，剔除商誉后为负'), ('J-INV', '对外投资 191 亿元：Spotify、UMG、WMG、SM 娱乐'), ('J-INV', '2026 年 6 月末：现金等 442.2 亿元、带息负债 168.8 亿元、对外投资 228.4 亿元')) v(jc, ft)
JOIN vi_judgment_base j ON j.company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND j.code = v.jc JOIN vi_fact_base f ON f.company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND f.title = v.ft;

INSERT INTO vi_lnk_judgment_theses (judgment_id, thesis_id, "createdAt", "updatedAt")
SELECT j.id, t.id, now(), now() FROM (VALUES ('J-S1', 'T1'), ('J-S1', 'T3'), ('J-S2', 'T4'), ('J-S3', 'T4'), ('J-FIN', 'T5'), ('J-FIN', 'T6'), ('J-FIN', 'T7'), ('J-R', 'T1'), ('J-R', 'T3'), ('J-OPCASH', 'T6'), ('J-OPCASH', 'T7'), ('J-CASH', 'T5'), ('J-CASH', 'T7'), ('J-INV', 'T5')) v(jc, tc)
JOIN vi_judgment_base j ON j.company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND j.code = v.jc JOIN vi_thesis_base t ON t.company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND t.code = v.tc;

INSERT INTO vi_biz_model_base (company_id, code, element, title, content, metric, trend) VALUES
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), 'B1', '客户细分', '三层用户＋广告主＋演出观众', '重度与粉丝用户（超级会员 2,000 万以上，集中在 QQ 音乐）、大众付费用户（约 1.27 亿）、轻度与下沉免费用户（酷狗、酷我、轻量 App），另有广告主和演唱会观众。', '月活 5.28 亿、付费用户 1.274 亿，付费率约 24%（2025 年四季度）', '轻度层正被汽水音乐、番茄音乐的免费模式分流，核心付费层是否受影响见 T3。'),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), 'B2', '价值主张', '最全的正版曲库、多端体验和粉丝权益', 'QQ 音乐（综合、偏一二线）、酷狗与酷我（下沉、价格敏感）、全民 K 歌、波点等轻量 App，2026 年起加上喜马拉雅长音频。核心卖点：曲库约 2.6 亿首、覆盖 95% 以上华语热门（含周杰伦等头部版权）；无损与杜比音质、车机与智能设备多端；超级会员的演唱会优先购票、Bubble、周边与长音频权益。', '曲库约 2.6 亿首（对手对比见 M2）；QQ 音乐会员 20—40 元/月，行业最高', '对只听抖音热歌的轻度用户，“曲库全”的价值在下降；价值主张正从“歌全”转向“权益全”。'),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), 'B3', '渠道通路', '腾讯生态带来的低获客成本', '微信、QQ 的社交入口与关系链，手机和车机预装，应用商店分发；2026 年接管微信视频号音乐垂类运营，接入元宝、小微 AI 助手。', '销售费用率 2025 年 2.9%（网易云 2026 年上半年 7.5%）；2026 年一季度销售费用同比 +36%', '音乐“发现”越来越多发生在抖音（V5），公司开始向字节等渠道买量，获客成本在上升；腾讯生态能否对等抖音见 T2。'),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), 'B4', '客户关系', '订阅制、高续费：歌单与会员权益留住用户', '会员按月或按年订阅。音乐是高频、重复收听的需求（用户约 90% 的播放是重复收听，行业交流口径），不需要多平台订阅；歌单、收藏与会员权益形成转换成本（是否构成壁垒见 M3）。超级会员把粉丝权益（B2）变成更深的关系（M5）。', '续费率 80% 以上（行业交流口径）', '管理层称竞争冲击轻度用户，超级会员稳定；免费模式对轻度用户的分流见 T3。'),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), 'B5', '收入来源', '会员约 54%，营销及消费类升到 31%，社交娱乐降到 15%', '收入＝付费用户×ARPPU×12（会员服务）＋广告、演唱会、艺人周边、长音频（营销及消费类）＋直播打赏（社交娱乐）。结构：2025 年会员 53.7%、营销及消费类 27.6%、社交娱乐 18.8%；2026 年二季度会员 53.6%、营销及消费类 31.5%、社交娱乐 14.9%。单价：ARPPU 2022 年 8.9 元 → 2025 年 11.9 元，2026 年二季度中金估算约 12.5 元（可能含喜马拉雅会员）；网易云约 6.4 元，Spotify 约 4.9 欧元（但付给版权方的比例更高）。', '2025 年：会员 176.6、营销及消费类 90.7、社交娱乐 61.8 亿元，ARPPU 11.9 元；营销及消费类 2025 年 +39%、2026 年二季度 +16%；社交娱乐二季度 −16%', '增长引擎从“付费用户×ARPPU”转向“超级会员＋IP 衍生”（能否接替订阅见 T4）：高毛利的会员内生增长约持平，低毛利的演出与经纪在补位；社交娱乐随直播监管持续收缩（V11）。汽水 8 元/月、看广告免费，压住了提价空间；ARPPU 提升越来越依赖超级会员占比，而不是普通会员提价。'),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), 'B6', '核心资源', '长期版权授权、自制音乐、对唱片公司的持股', '与环球、索尼、华纳及杰威尔、华研等长期授权（期限 1—3 年，最低保底＋分成），与音著协有框架协议，构成头部华语曲库（B2、M2）。自制音乐播放份额约 20%—30%，已超过三大唱片在平台的份额（约 20%，中金估算）。持有 UMG 约 2%（经腾讯牵头的 Concerto 财团间接持有）、WMG 0.8%、Spotify 2.5%，以及韩国 SM 娱乐 9.7%（摩根士丹利口径）；不持有索尼音乐。', '对外股权约 191 亿元（2026 年 6 月）', '授权都是非独家的，竞争对手也能拿到大部分曲库；对唱片公司的持股带来关系，但不带来排他权。'),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), 'B7', '关键业务', '版权采购、产品与推荐运营、IP 与演出、长音频', '规模化采购与续约版权（上游议价权是真实壁垒，M1）；QQ 音乐、酷狗、酷我的产品与推荐运营；自制音乐与艺人经纪；演唱会、周边等 IP 与粉丝经济运营（M5）；2026 年起运营喜马拉雅长音频。', '经营费用率从 2021 年 21% 降到 2025 年 15%', 'AI 音乐日上传量约 40%、播放只占 1%—3%，内容供给方式在变，平台目前不给 AI 歌曲结算版税（事实摘录）。'),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), 'B8', '重要合作', '控股股东腾讯、三大唱片与独立版权方', '腾讯控股是控股股东，提供社交入口与关系链（渠道见 B3）。三大唱片（环球、索尼、华纳）及杰威尔、华研等是最主要的版权方，公司持有其中环球（间接）与华纳的少量股权，不持有索尼（B6）；国内版权方分散，平台议价力强（M1）。', '国内前五大唱片公司约 29%；平台付给版权方约 45%—55%', '授权期限 1—3 年，续约时重新议价（M1）；腾讯生态资源的分配决定低获客成本能否持续（T2）。'),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), 'B9', '成本结构', '营业成本约 56%、以版权分成为主；会员预付、版权后付，不占用资金', '利润＝收入−版权分成与内容成本−主播分成−演出与周边成本−获客与管理费用。营业成本包括版权分成与内容成本、主播分成、演出和周边成本、带宽与渠道费；经营费用约占收入 15%（管理及研发约 12%、销售约 3%）。国内平台付给版权方的比例约为相关收入的 45%—55%，海外约 60%—70%。毛利率高出同业 7—12 个百分点（网易云 37.2%、Spotify 30% 出头），续费率高也压低了获客成本（B4）。资本：负营运资本约 80 亿元（应付账款、预收会员费、其他应付减应收与预付）；资本开支每年约 12 亿元。2025 年末，经营性投入资本（归母权益＋少数股东＋带息负债−现金存款−对外投资）约 205 亿元，几乎等于商誉；剔除商誉后为负。', '2025 年营业成本 183.7 亿元（收入的 55.8%）、毛利率 44.2%、核心经营利润率 29.4%；经营现金流约 100 亿元/年，约等于经调整净利；按含商誉的投入资本算，税后经营回报约 39%', '2021 年取消独家版权后，版权成本率下降（毛利率与壁垒的关系见 M1）；演出占比上升会把毛利率往回拉，单位收入带来的利润在下降；收入停止增长时，负营运资本不再释放现金；钱主要花在并购（喜马拉雅约 80 亿元现金）和回购上（利润的现金含量见 T6，股东回报见 T5）。');

INSERT INTO vi_lnk_biz_model_facts (biz_model_id, fact_id, "createdAt", "updatedAt")
SELECT x.id, y.id, now(), now() FROM (VALUES ('B1', '付费用户 1.274 亿、ARPPU 11.9 元，月活连续下滑'), ('B1', '同业对比：付费率 24% 对 31%、39%；毛利率 44% 对 37%、30% 出头'), ('B2', '汽水音乐的打法：抖音热歌、对三大唱片“必采”、曲库约 5,000 万首'), ('B2', '汽水音乐月活 1.7 亿，定价约为 QQ 音乐的三分之一'), ('B3', '销售费用率约 3%，2026 年一季度销售费用 +36%'), ('B3', '管理层：竞争冲击轻度用户，超级会员稳定'), ('B4', '续费率 80% 以上；付费墙比例说法不一'), ('B4', '管理层：竞争冲击轻度用户，超级会员稳定'), ('B5', '2025 年收入 329.0 亿元（+15.8%），订阅 176.6 亿元'), ('B5', '毛利率从 2021 年 30% 升到 2025 年 44%，2026 年下半年同比略降'), ('B5', '经营费用率从 2021 年 21% 降到 2025 年 15%'), ('B5', '2026 年二季度：喜马拉雅并表 4.07 亿元，社交娱乐 −16%'), ('B5', '社交娱乐收入持续收缩'), ('B5', '付费用户 1.274 亿、ARPPU 11.9 元，月活连续下滑'), ('B5', '同业对比：付费率 24% 对 31%、39%；毛利率 44% 对 37%、30% 出头'), ('B5', '续费率 80% 以上；付费墙比例说法不一'), ('B6', '版权授权：期限 1—3 年，最低保底＋收入分成'), ('B6', '自制音乐播放份额约 20%—30%，已超过三大唱片'), ('B6', '对外投资 191 亿元：Spotify、UMG、WMG、SM 娱乐'), ('B7', '经营费用率从 2021 年 21% 降到 2025 年 15%'), ('B7', 'AI 音乐：日上传量约 40%，播放只占 1%—3%'), ('B8', '上游分散：国内前五大唱片公司约 29%，平台付给版权方约 45%—55%'), ('B9', '2025 年收入 329.0 亿元（+15.8%），订阅 176.6 亿元'), ('B9', '毛利率从 2021 年 30% 升到 2025 年 44%，2026 年下半年同比略降'), ('B9', '经营费用率从 2021 年 21% 降到 2025 年 15%'), ('B9', '上游分散：国内前五大唱片公司约 29%，平台付给版权方约 45%—55%'), ('B9', '付费用户 1.274 亿、ARPPU 11.9 元，月活连续下滑'), ('B9', '同业对比：付费率 24% 对 31%、39%；毛利率 44% 对 37%、30% 出头'), ('B9', '续费率 80% 以上；付费墙比例说法不一'), ('B9', '经营性投入资本约等于商誉，剔除商誉后为负'), ('B9', '经营现金流约 100 亿元，与经调整净利相当')) v(k1, k2)
JOIN vi_biz_model_base x ON x.company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND x.code = v.k1 JOIN vi_fact_base y ON y.company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND y.title = v.k2;

INSERT INTO vi_value_chain_base (company_id, code, position, participant, role, force, power, effect, trend, profit_share, analysis, counter) VALUES
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), 'V1', '本公司环节', '腾讯音乐：QQ 音乐、酷狗、酷我、全民 K 歌、喜马拉雅', '聚合版权、分发、会员与广告变现，IP 运营（演唱会、周边、艺人经纪）', '不适用', '中', '中性', '稳定', '毛利率 44%，核心经营利润率 29%；行业口径：流媒体收入中版税约 40%、运营 15%—20%、平台留存 40%—45%', '平台是产业链里最后一个、也是唯一面向付费用户的环节，收入最稳定。自制音乐（播放份额 20%—30%）让平台向上游延伸，进一步降低分成。', '平台的超额利润取决于上游分散这一结构；若上游集中或下游分散，利润池会重新分配。'),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), 'V2', '上游供给', '唱片公司与版权方：环球、索尼、华纳；杰威尔、华研、太合、滚石、摩登天空；独立音乐人；音著协', '录音与词曲版权授权（期限 1—3 年，最低保底＋收入分成）', '供应商议价能力', '中', '有利', '增强', '国内平台付给版权方约 45%—55%（全球 60%—70%）；国内前五大唱片公司份额约 29%，全球三大唱片加 Merlin 约 75%', '中国的结构和海外相反：上游分散、下游集中（腾讯音乐约占市场三分之二）。版权方离不开腾讯音乐，所以平台拿到的分成比海外高，这是腾讯音乐毛利率高于 Spotify 的根本原因（这一结构怎样变成壁垒见 M1）。', '上游有重新集中的力量：取消独家后可以多平台授权，三大唱片借 AI 授权规则争取更高分成，“抖汽互通”让版权方有动力授权给汽水（能否改变结构见 T1 反方）。'),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), 'V3', '下游客户', '付费用户（超级会员、大众会员、价格敏感用户）', '会员订阅：QQ 音乐 20—40 元/月，各类折扣与年卡', '买方议价能力', '中', '中性', '增强', '会员收入约占总收入 54%', '单个用户没有议价力，但免费替代品（汽水看广告免费、8 元会员）给了价格敏感用户“退出选项”，这一层用户的议价力在上升；超级会员的议价力仍弱（核心层是否守得住见 T3）。', '超级会员稳定、ARPPU 仍在升（11.9 元），说明核心层还在接受定价。'),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), 'V4', '下游客户', '广告主', '开屏、信息流、激励广告与广告会员', '买方议价能力', '强', '不利', '增强', '广告在营销及消费类收入里（营销及消费类约占 31%）', '广告预算向抖音、视频号等短视频平台集中，音乐 App 流量下降，eCPM 与广告收入承压（2026 年二季度管理层口径）。', '公司在推激励广告与广告会员模式。'),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), 'V5', '渠道与流量', '抖音（音乐发现的起点）', '短视频 BGM 曝光、热歌宣发', '替代品威胁', '中', '不利', '增强', '汽水音乐前 1,000 首热歌中 86% 来自抖音，54% 从抖音冷启动走红', '爆款的发现已从音乐 App 移到抖音。字节借“抖汽互通”掌握了发现入口，并把用户直接导到汽水：这是对腾讯音乐最实质的结构性威胁。', '抖音不提供完整收听与收藏体验，重复收听仍发生在音乐 App；版权方也需要腾讯音乐的付费分成。'),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), 'V6', '渠道与流量', '腾讯生态（微信、QQ、视频号、元宝），应用商店与手机、车机预装', '社交入口、内容分发、支付与预装', '不适用', '中', '有利', '稳定', '销售费用率约 3%（网易云 7.5%）', '腾讯生态让腾讯音乐长期几乎不用花钱获客；苹果渠道费汇率下降也在改善成本（管理层口径）。2026 年接管的视频号音乐垂类能否补上“发现”这一环，见 T2。', '流量开始不够用：2026 年一季度销售费用 +36%，并向字节等渠道买量（T2 反方）。'),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), 'V7', '潜在进入者', '汽水音乐、番茄音乐（字节跳动）', '免费听歌、广告变现、低价会员', '新进入者威胁', '强', '不利', '增强', '汽水月活 1.7 亿（同比 +69%）、会员渗透率不到 10%；番茄月活约 4,550 万', '字节同时拥有流量（抖音）、资本（对三大唱片“必采”，即使亏损也买）和广告变现能力（90% 以上用户靠广告变现），是唯一能复制腾讯音乐规模的进入者。', '进入者的用户质量与粘性弱、增速在放缓（留存、打开率与月活见竞争对手：汽水音乐、番茄音乐）；中信建投判断汽水月活上限约 2 亿。'),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), 'V8', '同业竞争', '网易云音乐', '音乐社区、独立音乐人、年轻用户', '行业内竞争', '中', '中性', '稳定', '网易云收入约为腾讯音乐的四分之一（2026 年上半年 39.6 亿元）', '两家差异化共存：网易云靠社区与低价会员，腾讯音乐靠曲库与超级会员（付费率、ARPPU 与受汽水冲击程度的对比见竞争对手：网易云音乐）。', '网易云 2026 年上半年也被迫加大投放（销售费用率 7.5%）和学生会员折扣，说明价格竞争在全行业蔓延。'),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), 'V9', '替代品', 'AI 生成音乐、播客与长音频、短剧与视频平台', '更低成本的内容供给、争夺用户时长', '替代品威胁', '弱', '不利', '增强', 'AI 音乐日上传量约占 40%，播放量只占 1%—3%（中金）', '短期内 AI 歌曲主要是“供给多、播放少”；长期看它压低内容稀缺性，也可能被字节用来低成本填充曲库（管理层指责竞争对手用 AI 生成的盗版内容引流）。', '三大唱片推动“先授权、后训练”的规则，AI 内容要进入主流榜单需合法授权；AI 也能降低腾讯音乐自制内容的成本。'),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), 'V10', '互补方', '演出产业链：场馆、票务平台、艺人经纪（SM 娱乐、Black Label、太合等）', '演唱会、周边、艺人合作', '不适用', '中', '有利', '增强', '营销及消费类收入 2025 年 +39%（演出、周边为主）', '腾讯音乐用演唱会优先购票、周边把粉丝绑进超级会员，并投资艺人经纪向上游延伸。', '演出与经纪毛利率低、季度波动大；票务和场馆不在腾讯音乐手里。'),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), 'V11', '监管', '市场监管总局、国家版权局、网信部门', '版权竞争规则、并购审查、直播与未成年人监管', '不适用', '强', '不利', '稳定', '—', '2021 年被责令解除独家版权（伪壁垒 M7）；2026 年收购喜马拉雅获附条件批准（限制期五年，涉及免费内容比例与非独家授权）；直播打赏与未成年人保护持续收紧（社交娱乐 2025 年 61.8 亿元，2026 年二季度同比 −16%，伪壁垒 M9）；AI 内容的版权规则尚未落地。', '版权保护加强（打击 AI 翻唱侵权）对正版平台有利。');

INSERT INTO vi_lnk_value_chain_facts (value_chain_id, fact_id, "createdAt", "updatedAt")
SELECT x.id, y.id, now(), now() FROM (VALUES ('V1', '自制音乐播放份额约 20%—30%，已超过三大唱片'), ('V1', '毛利率从 2021 年 30% 升到 2025 年 44%，2026 年下半年同比略降'), ('V2', '上游分散：国内前五大唱片公司约 29%，平台付给版权方约 45%—55%'), ('V2', '版权授权：期限 1—3 年，最低保底＋收入分成'), ('V3', '汽水音乐月活 1.7 亿，定价约为 QQ 音乐的三分之一'), ('V3', '付费用户 1.274 亿、ARPPU 11.9 元，月活连续下滑'), ('V4', '2026 年二季度：喜马拉雅并表 4.07 亿元，社交娱乐 −16%'), ('V5', '汽水音乐的打法：抖音热歌、对三大唱片“必采”、曲库约 5,000 万首'), ('V6', '销售费用率约 3%，2026 年一季度销售费用 +36%'), ('V6', '管理层：竞争冲击轻度用户，超级会员稳定'), ('V7', '汽水音乐月活 1.7 亿，定价约为 QQ 音乐的三分之一'), ('V7', '汽水音乐的打法：抖音热歌、对三大唱片“必采”、曲库约 5,000 万首'), ('V8', '网易云音乐 2026 年上半年：收入 +3.4%、会员订阅 +5.3%、毛利率 37.2%'), ('V8', '同业对比：付费率 24% 对 31%、39%；毛利率 44% 对 37%、30% 出头'), ('V9', 'AI 音乐：日上传量约 40%，播放只占 1%—3%'), ('V9', 'AI 音乐：供给多但有效播放少'), ('V10', '2025 年收入 329.0 亿元（+15.8%），订阅 176.6 亿元'), ('V10', '毛利率从 2021 年 30% 升到 2025 年 44%，2026 年下半年同比略降'), ('V11', '监管：2021 年解除独家版权，2026 年喜马拉雅收购附条件批准'), ('V11', '社交娱乐收入持续收缩')) v(k1, k2)
JOIN vi_value_chain_base x ON x.company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND x.code = v.k1 JOIN vi_fact_base y ON y.company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND y.title = v.k2;

INSERT INTO vi_competitor_base (company_id, name, ticker, relation, segment, scale_label, scale_value, scale_unit, paying_rate, price_point, gross_margin, growth, as_of, strategy, vs_us, threat, trend, source_id) VALUES
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '网易云音乐', '9899.HK', '直接竞争', '在线音乐（年轻用户、社区）', '月活', 2.21, '亿人', 0.312, '黑胶 VIP 约 18 元/月；学生会员、88VIP 更低', 0.372, 0.034, '2026-06-30', '社区与评论、独立音乐人（注册超 125 万）、学生与家庭会员追求规模；2026 年上半年加大品牌与获客投放。', '强：社区氛围与年轻用户、付费率更高（31% 对 24%）、受汽水冲击小（用户重合约 30%）。弱：ARPPU 约为腾讯音乐一半（6.4 对 12.5 元）、头部版权少、毛利率低约 7 个百分点、销售费用率 7.5%。', '中', '稳定', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '网易云音乐 2026 年中期业绩点评（光大、东财、浦银国际、华兴、中金）' LIMIT 1)),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '汽水音乐', NULL, '直接竞争', '免费听歌（下沉、轻度、男性用户为主）', '月活', 1.7, '亿人', NULL, 'VIP 8 元/月、SVIP 18 元/月；每天看约 80 秒广告换全天免费', NULL, 0.687, '2026-07-31', '抖音导流（“抖汽互通”）、免费＋广告变现、热歌优先（Top1000 中 86% 来自抖音）；对三大唱片“必采”，对周杰伦等头部艺人“单点突破”获取非独家版权；翻唱与 UGC 约占版权成本的 30%。', '强：发现入口在抖音、免费、热歌更新快、背靠字节的广告系统。弱：曲库约 5,000 万首、经典与港台版权缺口大；30 日留存约 10%、主动打开率不到 20%；会员渗透率不到 10%（含激励兑换水分）；内部自负盈亏考核。', '高', '上升', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '行业竞争资料：汽水音乐、番茄音乐用户规模与定价' LIMIT 1)),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '番茄音乐', NULL, '替代品', '下沉与中老年用户、听书与短剧一体', '月活', 0.4553, '亿人', NULL, '免费为主', NULL, NULL, '2026-07-31', '依托番茄小说、红果短剧导流，音乐与有声书、短剧打通。', '强：字节全家桶流量。弱：音乐是附属功能，2026 年二季度各月月活环比为负。', '低', '下降', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '行业竞争资料：汽水音乐、番茄音乐用户规模与定价' LIMIT 1)),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '抖音（作为音乐发现与收听场景）', NULL, '替代品', '短视频 BGM、热歌发现', NULL, NULL, NULL, NULL, '免费', NULL, NULL, '2026-09-16', '版权方的宣发主阵地；用户在短视频里“听过”热歌，部分需求不再需要打开音乐 App。', '强：掌握发现入口与年轻用户时长。弱：不提供完整收听、歌单与收藏体验。', '高', '上升', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '行业竞争资料：汽水音乐、番茄音乐用户规模与定价' LIMIT 1)),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), 'Spotify', 'SPOT.N', '海外对标', '全球在线音乐（订阅＋广告）', '月活', 7.77, '亿人', 0.386, '美国约 11.99 美元/月', NULL, NULL, '2026-06-30', '全球扩张、提价、把播客与有声书打包进会员；付给版权方约 60%—70%。', '对照意义：付费率比腾讯音乐高约 14 个百分点，说明国内付费率还有空间；但毛利率只有 30% 出头，说明腾讯音乐的毛利率优势来自中国的产业结构（上游分散），而不只是公司自身。', '低', '稳定', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '卖方行业研究：在线音乐产业链、版权成本与竞争格局（国信、中金、长江、中信建投等，2024-12—2026-09）' LIMIT 1)),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), 'AI 音乐生成平台（Suno、音潮等）', NULL, '替代品', '内容供给', NULL, NULL, NULL, NULL, '按创作次数或会员收费', NULL, NULL, '2026-08-21', '一句话写歌、照片写歌；单首成本可低至几毛钱。', '强：供给成本趋近于零。弱：版权与授权规则未定，播放占比只有 1%—3%，平台目前不给 AI 歌曲结算版税。', '低', '上升', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '卖方行业研究：在线音乐产业链、版权成本与竞争格局（国信、中金、长江、中信建投等，2024-12—2026-09）' LIMIT 1));

INSERT INTO vi_lnk_competitor_facts (competitor_id, fact_id, "createdAt", "updatedAt")
SELECT x.id, y.id, now(), now() FROM (VALUES ('网易云音乐', '网易云音乐 2026 年上半年：收入 +3.4%、会员订阅 +5.3%、毛利率 37.2%'), ('网易云音乐', '同业对比：付费率 24% 对 31%、39%；毛利率 44% 对 37%、30% 出头'), ('汽水音乐', '汽水音乐月活 1.7 亿，定价约为 QQ 音乐的三分之一'), ('汽水音乐', '汽水音乐的打法：抖音热歌、对三大唱片“必采”、曲库约 5,000 万首'), ('番茄音乐', '汽水音乐月活 1.7 亿，定价约为 QQ 音乐的三分之一'), ('抖音（作为音乐发现与收听场景）', '汽水音乐的打法：抖音热歌、对三大唱片“必采”、曲库约 5,000 万首'), ('Spotify', '同业对比：付费率 24% 对 31%、39%；毛利率 44% 对 37%、30% 出头'), ('Spotify', '上游分散：国内前五大唱片公司约 29%，平台付给版权方约 45%—55%'), ('AI 音乐生成平台（Suno、音潮等）', 'AI 音乐：日上传量约 40%，播放只占 1%—3%')) v(k1, k2)
JOIN vi_competitor_base x ON x.company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND x.name = v.k1 JOIN vi_fact_base y ON y.company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND y.title = v.k2;

INSERT INTO vi_lnk_value_chain_competitors (value_chain_id, competitor_id, "createdAt", "updatedAt")
SELECT x.id, y.id, now(), now() FROM (VALUES ('V3', '汽水音乐'), ('V5', '抖音（作为音乐发现与收听场景）'), ('V5', '汽水音乐'), ('V7', '汽水音乐'), ('V7', '番茄音乐'), ('V8', '网易云音乐'), ('V9', 'AI 音乐生成平台（Suno、音潮等）')) v(k1, k2)
JOIN vi_value_chain_base x ON x.company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND x.code = v.k1 JOIN vi_competitor_base y ON y.company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND y.name = v.k2;

INSERT INTO vi_moat_base (company_id, code, title, moat_type, verdict, strength, trend, mechanism, financial_link, evidence, counter, replication, threats, check_metric, check_op, check_threshold, check_years) VALUES
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), 'M1', '规模采购下的上游议价权（国内版权方分散、平台集中）', '规模经济', '真实壁垒', '强', '稳定', '在上游分散、下游集中的结构里（V2），腾讯音乐约占下游三分之二，是版权方离不开的买家：平台付给版权方的比例（约 45%—55%）低于海外（60%—70%）；规模越大，最低保底金摊得越薄。', '毛利率高出同业 7—12 个百分点（B9）；经营性投入资本约等于商誉，按含商誉的投入资本算税后经营回报约 39%（B9）。', '毛利率 2021—2025 年 30% → 44%，取消独家后版权成本率下降；自制音乐播放份额 20%—30% 已超过三大唱片；腾讯系与三大唱片交叉持股、长期续约。', '优势主要来自产业结构，网易云同样受益（见 T1 反方）；上游有重新集中的力量（V2）。', '需要数亿付费规模和多年保底金。字节有资本也有流量，但付费用户规模短期复制不了（汽水会员渗透率不到 10%）。对照对手：Spotify。', '上游集中化（三大唱片、AI 授权规则，V2）；“抖汽互通”让版权方转向字节（V5）；监管限制非独家授权条款（V11）。', '毛利率', '<', 0.4, 2),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), 'M2', '头部华语曲库与长期授权关系', '牌照与资源', '局部优势', '中', '削弱', '周杰伦（杰威尔）、华研等头部华语版权与约 2.6 亿首曲库，覆盖 95% 以上华语热门。行业观点是：核心曲库只占约 1%，却撬动了较高的付费转化。', '付费墙歌曲比例与付费转化；QQ 音乐 20—40 元的定价。', '曲库约 2.6 亿首，网易云约 1.6 亿首，汽水约 5,000 万首；汽水在经典曲目、港台与韩国厂牌上仍有明显缺口。', '2021 年起不能独家，曲库差距可以用钱缩小（论证见 T1 反方）；轻度用户只听抖音热歌，不在乎曲库是否完整。', '头部华语艺人的非独家授权可以用钱买到，两到三年能补齐主要曲库；难复制的是老歌长尾和港台小厂牌的完整授权。', '授权到期（1—3 年）续约时版权方要价；字节高价采购；喜马拉雅收购附条件要求非独家授权。', NULL, NULL, NULL, NULL),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), 'M3', '转换成本（歌单收藏、曲库差异、超级会员权益）', '转换成本', '局部优势', '中', '削弱', '三层叠加：1）歌单、收藏与多年听歌记录：重度用户积累越久越难搬；2）曲库差异（M2）放大前者：导入工具只能搬“歌名”，新平台没有授权的歌会变灰，推荐也要重新学习；3）超级会员权益（M5）：演唱会优先购票、Bubble、周边，换平台就要放弃。付费习惯属于整个品类，不属于腾讯音乐，免费模式会直接瓦解它，不算壁垒。', '2022—2025 年 ARPPU 从 8.9 元升到 11.9 元，主要靠回收折扣，付费用户同期仍在增长：涨价没赶走用户。超级会员 2,000 万以上 × 约 20 元/月（摩根大通估算）≈ 48 亿元/年，约占 2025 年订阅收入 176.6 亿元的 27%：这部分锁定最强。', 'QQ 音乐月活同比只降 0.7%，酷狗、酷我降 10% 以上（中金月度跟踪）：流失集中在积累少的轻度用户。管理层称超级会员未受影响；汽水冲击网易云大于腾讯音乐（国信 2025-11）（论证见 T3 正方）。', '轻度、价格敏感用户（酷狗、酷我为主）积累少，转换成本接近零，与汽水重合约 60%；付费用户 2026 年两个季度没有净增；摩根大通模型季度留存约 78%，“续费率 80%”无周期与口径，不作证据；2026 年一季度销售费用 +36%、推出酷狗免费版，说明要花钱留人（见 T3 反方）。', '—（转换成本属于用户，不是对手能直接复制的资产；对手靠免费与导流绕开它）。对照对手：汽水音乐。', '免费模式拉低价格锚；歌单迁移工具降低转换成本（待核验）。', '业务量同比', '<', 0, 2),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), 'M4', '腾讯生态流量与低获客成本', '生态与渠道', '局部优势', '中', '稳定', '微信、QQ 的账号与入口让获客几乎不花钱，腾讯不单独收流量费（年报关联交易里没有购买流量一项）。视频号是腾讯自己掌握开关的期权：识曲一键跳转 QQ 音乐、音乐垂类由腾讯音乐运营，需要时可以像抖音一样加码导流，不用花钱、也不受制于对手；元宝也已接入。', '销售费用率约 3%，网易云 7.5%：按网易云的费率获客，每年要多花约 15 亿元，约为 2027 年核心盈利的 17%。', '2025 年销售费用 9.41 亿元（收入的 2.9%）；已接管视频号音乐垂类运营，《缠缚》经视频号推广单日播放峰值超 600 万（2025 年年报）；视频号日活约 6.5 亿、总时长约为抖音主站的 60%，仍在增长（专家交流，2026-04）。', '音乐的发现起点在抖音（V5）；2026 年一季度销售费用 +36%。视频号能放大导流，但未必能“造爆款”：45 岁以上用户约占一半，新歌走红靠年轻用户与创作者自发使用（论证见 T2）。', '只有字节能复制，而且已经复制（抖音→汽水）。', '抖音流量优势扩大；腾讯集团可能让腾讯音乐承担生态任务（T5）。', NULL, NULL, NULL, NULL),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), 'M5', 'IP 与粉丝经济（演唱会、周边、艺人经纪、超级会员权益）', '工艺与组织', '待验证', '弱', '增强', '把演唱会、周边、粉丝俱乐部、Bubble 打包进超级会员，用 IP 锁定高价值用户；投资 SM 娱乐、Black Label 向上游延伸。', '营销及消费类收入高速增长（B5）、ARPPU 提升；但演出拉低了毛利率。', '超级会员 2025 年末超过 2,000 万；为 G-DRAGON 操盘 20 场亚太巡演。', '演出与经纪毛利率低，正在拉低毛利率；业务可被复制，公司也没有披露超级会员留存数据（论证见 T4）。', '一到两年可复制演出与周边业务；难复制的是与唱片公司和艺人的长期关系。', '演出市场周期与监管；粉丝经济集中于少数艺人。', NULL, NULL, NULL, NULL),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), 'M6', '伪壁垒：用户规模（5 亿月活）', '网络效应', '伪壁垒', '无', '削弱', '用户多本身并不让每个用户得到更多价值，音乐播放没有网络效应；规模的作用只是摊薄版权保底金（已计入 M1）。', '—', '月活 5.56 亿 → 5.28 亿仍在流失，规模没能阻止汽水一年拿到 1.7 亿月活。', '社交功能（全民 K 歌、评论、Bubble）有弱网络效应，但规模有限。', '—', '—', NULL, NULL, NULL, NULL),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), 'M7', '伪壁垒：历史独家版权', '牌照与资源', '伪壁垒', '无', '削弱', '2021 年以前靠独家版权锁定用户；这一优势已被监管取消。', '—', '2021 年 7 月被责令解除独家版权；2026 年收购喜马拉雅也附带非独家授权的条件。', '长期合作关系和持股仍有残余影响（已计入 M2）。', '—', '—', NULL, NULL, NULL, NULL),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), 'M8', '伪壁垒：账上净现金与对外股权', '牌照与资源', '伪壁垒', '无', '稳定', '净现金约 273 亿元、对外股权约 191 亿元是资源，不是竞争优势：它们不阻止竞争者，价值取决于会不会回到股东手里。', '见判断 J-CASH 与 J-INV。', '2026 年刚用约 80 亿元现金收购喜马拉雅；同时单季回购 4 亿美元。', '现金让公司能在竞争中持续投入与回购，是“防守弹药”。', '—', '—', NULL, NULL, NULL, NULL),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), 'M9', '伪壁垒：社交娱乐（直播打赏）', '生态与渠道', '伪壁垒', '无', '削弱', '直播打赏收入依赖监管尺度和流量，不是可持续的竞争优势。', '—', '社交娱乐收入 2025 年 −7.3%，2026 年二季度 −16.4%，占总收入降到 15%。', '分成比例下降让这块毛利率改善。', '—', '直播监管。', NULL, NULL, NULL, NULL);

INSERT INTO vi_lnk_moat_facts (moat_id, fact_id, "createdAt", "updatedAt")
SELECT x.id, y.id, now(), now() FROM (VALUES ('M1', '上游分散：国内前五大唱片公司约 29%，平台付给版权方约 45%—55%'), ('M1', '毛利率从 2021 年 30% 升到 2025 年 44%，2026 年下半年同比略降'), ('M1', '自制音乐播放份额约 20%—30%，已超过三大唱片'), ('M1', '同业对比：付费率 24% 对 31%、39%；毛利率 44% 对 37%、30% 出头'), ('M1', '经营性投入资本约等于商誉，剔除商誉后为负'), ('M2', '汽水音乐的打法：抖音热歌、对三大唱片“必采”、曲库约 5,000 万首'), ('M2', '版权授权：期限 1—3 年，最低保底＋收入分成'), ('M2', '汽水音乐月活 1.7 亿，定价约为 QQ 音乐的三分之一'), ('M3', '付费用户 1.274 亿、ARPPU 11.9 元，月活连续下滑'), ('M3', '续费率 80% 以上；付费墙比例说法不一'), ('M3', '管理层：竞争冲击轻度用户，超级会员稳定'), ('M3', '同业对比：付费率 24% 对 31%、39%；毛利率 44% 对 37%、30% 出头'), ('M4', '销售费用率约 3%，2026 年一季度销售费用 +36%'), ('M4', '管理层：竞争冲击轻度用户，超级会员稳定'), ('M4', '汽水音乐的打法：抖音热歌、对三大唱片“必采”、曲库约 5,000 万首'), ('M5', '2025 年收入 329.0 亿元（+15.8%），订阅 176.6 亿元'), ('M5', '毛利率从 2021 年 30% 升到 2025 年 44%，2026 年下半年同比略降'), ('M5', '管理层：竞争冲击轻度用户，超级会员稳定'), ('M6', '付费用户 1.274 亿、ARPPU 11.9 元，月活连续下滑'), ('M6', '汽水音乐月活 1.7 亿，定价约为 QQ 音乐的三分之一'), ('M7', '监管：2021 年解除独家版权，2026 年喜马拉雅收购附条件批准'), ('M8', '现金等 442 亿元，借款与票据约 165 亿元'), ('M8', '对外投资 191 亿元：Spotify、UMG、WMG、SM 娱乐'), ('M9', '社交娱乐收入持续收缩')) v(k1, k2)
JOIN vi_moat_base x ON x.company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND x.code = v.k1 JOIN vi_fact_base y ON y.company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND y.title = v.k2;

INSERT INTO vi_lnk_moat_theses (moat_id, thesis_id, "createdAt", "updatedAt")
SELECT x.id, y.id, now(), now() FROM (VALUES ('M1', 'T1'), ('M2', 'T1'), ('M3', 'T3'), ('M4', 'T2'), ('M4', 'T5'), ('M5', 'T4'), ('M6', 'T3'), ('M7', 'T1'), ('M8', 'T5'), ('M8', 'T7'), ('M9', 'T4')) v(k1, k2)
JOIN vi_moat_base x ON x.company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND x.code = v.k1 JOIN vi_thesis_base y ON y.company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND y.code = v.k2;

INSERT INTO vi_fit_score_base (company_id, dimension, score, rationale, counter, sort) VALUES
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '长坡', 4, '音乐是长期稳定的高频需求；付费率约 24%，低于 Spotify 的约 39%，仍有提升空间；长音频与粉丝经济拓宽了可服务市场。', '用户总量在下降（月活 −5%）；行业交流认为国内愿意为音乐付费的人约 1.5—1.7 亿，腾讯音乐已有约 1.27 亿。', 1),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '厚雪', 4, '行业双寡头，上游分散、下游集中；毛利率 44%，经营性投入资本约等于商誉，回报率高；负营运资本。', '字节以“免费＋流量”进入，利润池开始被分走；广告和社交娱乐在收缩。', 2),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '慢变', 4, '音乐消费习惯本身变化慢。', '分发（抖音）、内容供给（AI 生成）、商业模式（免费＋广告）三项规则同时在变；公司在 2026 年停止披露季度指标，可见度下降。', 3),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '护城河', 3, '上游议价权是真实壁垒；曲库、转换成本、腾讯生态是局部优势。', '各项局部优势都在削弱；IP 与粉丝经济尚未被证明。', 4),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '再投资', 4, '再投资需求低（资本开支约 12 亿元/年），多余现金可以回报股东。', '大额再投资是并购：喜马拉雅约 140 亿元对价、商誉约 92 亿元，回报尚未证明；增量回报未知。', 5),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '财务质量', 5, '净现金约 273 亿元；经营现金流约等于经调整净利；轻资产、负营运资本；国际财务报告准则利润与经调整利润差异可解释（股权激励、收购摊销、一次性收益）。', '2026 年起借入约 165 亿元美元债务和借款；现金在境内、回报在境外。', 6),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '治理配置', 3, '2026 年回购与分红明显加码，并发债支持回购。', '腾讯控股、不同投票权、开曼注册加协议控制；历史股东回报率偏低；没有正式的回报政策。', 7),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '可估值性', 4, '核心驱动（付费用户、ARPPU、利润率、回报率）可理解，现金流稳定。', '停止披露季度经营指标；增长路径区间很宽；价值对股东回报率极其敏感。', 8);

INSERT INTO vi_lnk_fit_score_theses (fit_score_id, thesis_id, "createdAt", "updatedAt")
SELECT x.id, y.id, now(), now() FROM (VALUES ('长坡', 'T3'), ('厚雪', 'T1'), ('慢变', 'T1'), ('慢变', 'T3'), ('护城河', 'T1'), ('护城河', 'T2'), ('护城河', 'T4'), ('再投资', 'T4'), ('财务质量', 'T6'), ('财务质量', 'T7'), ('治理配置', 'T5'), ('可估值性', 'T3'), ('可估值性', 'T5')) v(k1, k2)
JOIN vi_fit_score_base x ON x.company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND x.dimension = v.k1 JOIN vi_thesis_base y ON y.company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND y.code = v.k2;

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '营业收入', '单季', '亿元', '2024Q1', '2024-03-31', 67.68, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第一至第三季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '会员（订阅）收入', '单季', '亿元', '2024Q1', '2024-03-31', 36.2, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第一至第三季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '非订阅音乐收入（广告、演出、周边）', '单季', '亿元', '2024Q1', '2024-03-31', 13.87, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第一至第三季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '社交娱乐及其他收入', '单季', '亿元', '2024Q1', '2024-03-31', 17.61, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第一至第三季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '毛利率', '单季', '%', '2024Q1', '2024-03-31', 40.94, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第一至第三季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '归母净利润', '单季', '亿元', '2024Q1', '2024-03-31', 14.22, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第一至第三季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '非国际财务报告准则归母净利润', '单季', '亿元', '2024Q1', '2024-03-31', 17.04, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第一至第三季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '在线音乐付费用户', '单季', '百万人', '2024Q1', '2024-03-31', 113.5, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第一至第三季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '单个付费用户月均收入（ARPPU）', '单季', '元', '2024Q1', '2024-03-31', 10.6, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第一至第三季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '在线音乐月活跃用户', '单季', '百万人', '2024Q1', '2024-03-31', 578, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第一至第三季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '营业收入', '单季', '亿元', '2024Q2', '2024-06-30', 71.6, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第一至第三季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '会员（订阅）收入', '单季', '亿元', '2024Q2', '2024-06-30', 37.4, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第一至第三季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '非订阅音乐收入（广告、演出、周边）', '单季', '亿元', '2024Q2', '2024-06-30', 16.84, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第一至第三季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '社交娱乐及其他收入', '单季', '亿元', '2024Q2', '2024-06-30', 17.36, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第一至第三季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '毛利率', '单季', '%', '2024Q2', '2024-06-30', 42.04, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第一至第三季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '归母净利润', '单季', '亿元', '2024Q2', '2024-06-30', 16.82, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第一至第三季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '非国际财务报告准则归母净利润', '单季', '亿元', '2024Q2', '2024-06-30', 18.73, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第一至第三季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '在线音乐付费用户', '单季', '百万人', '2024Q2', '2024-06-30', 117.0, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第一至第三季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '单个付费用户月均收入（ARPPU）', '单季', '元', '2024Q2', '2024-06-30', 10.7, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第一至第三季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '在线音乐月活跃用户', '单季', '百万人', '2024Q2', '2024-06-30', 571, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第一至第三季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '营业收入', '单季', '亿元', '2024Q3', '2024-09-30', 70.15, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第一至第三季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '会员（订阅）收入', '单季', '亿元', '2024Q3', '2024-09-30', 38.4, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第一至第三季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '非订阅音乐收入（广告、演出、周边）', '单季', '亿元', '2024Q3', '2024-09-30', 16.4, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第一至第三季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '社交娱乐及其他收入', '单季', '亿元', '2024Q3', '2024-09-30', 15.35, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第一至第三季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '毛利率', '单季', '%', '2024Q3', '2024-09-30', 42.64, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第一至第三季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '归母净利润', '单季', '亿元', '2024Q3', '2024-09-30', 15.83, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第一至第三季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '非国际财务报告准则归母净利润', '单季', '亿元', '2024Q3', '2024-09-30', 18.14, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第一至第三季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '在线音乐付费用户', '单季', '百万人', '2024Q3', '2024-09-30', 119.0, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第一至第三季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '单个付费用户月均收入（ARPPU）', '单季', '元', '2024Q3', '2024-09-30', 10.8, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第一至第三季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '在线音乐月活跃用户', '单季', '百万人', '2024Q3', '2024-09-30', 576, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第一至第三季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '营业收入', '单季', '亿元', '2024Q4', '2024-12-31', 74.58, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第四季度及全年未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '会员（订阅）收入', '单季', '亿元', '2024Q4', '2024-12-31', 40.3, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第四季度及全年未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '非订阅音乐收入（广告、演出、周边）', '单季', '亿元', '2024Q4', '2024-12-31', 18.01, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第四季度及全年未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '社交娱乐及其他收入', '单季', '亿元', '2024Q4', '2024-12-31', 16.27, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第四季度及全年未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '毛利率', '单季', '%', '2024Q4', '2024-12-31', 43.62, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第四季度及全年未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '归母净利润', '单季', '亿元', '2024Q4', '2024-12-31', 19.57, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第四季度及全年未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '非国际财务报告准则归母净利润', '单季', '亿元', '2024Q4', '2024-12-31', 22.8, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第四季度及全年未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '在线音乐付费用户', '单季', '百万人', '2024Q4', '2024-12-31', 121.0, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第四季度及全年未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '单个付费用户月均收入（ARPPU）', '单季', '元', '2024Q4', '2024-12-31', 11.1, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第四季度及全年未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '在线音乐月活跃用户', '单季', '百万人', '2024Q4', '2024-12-31', 556, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第四季度及全年未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '营业收入', '单季', '亿元', '2025Q1', '2025-03-31', 73.56, 0.086879, '归母含 UMG 实物分派带来的视同处置收益 23.7 亿元。', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第一至第三季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '会员（订阅）收入', '单季', '亿元', '2025Q1', '2025-03-31', 42.2, 0.165746, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第一至第三季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '非订阅音乐收入（广告、演出、周边）', '单季', '亿元', '2025Q1', '2025-03-31', 15.84, 0.142033, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第一至第三季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '社交娱乐及其他收入', '单季', '亿元', '2025Q1', '2025-03-31', 15.52, -0.118683, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第一至第三季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '毛利率', '单季', '%', '2025Q1', '2025-03-31', 44.07, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第一至第三季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '归母净利润', '单季', '亿元', '2025Q1', '2025-03-31', 42.91, 2.017581, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第一至第三季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '非国际财务报告准则归母净利润', '单季', '亿元', '2025Q1', '2025-03-31', 21.24, 0.246479, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第一至第三季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '在线音乐付费用户', '单季', '百万人', '2025Q1', '2025-03-31', 122.9, 0.082819, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第一至第三季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '单个付费用户月均收入（ARPPU）', '单季', '元', '2025Q1', '2025-03-31', 11.4, 0.075472, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第一至第三季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '在线音乐月活跃用户', '单季', '百万人', '2025Q1', '2025-03-31', 555, -0.039792, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第一至第三季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '营业收入', '单季', '亿元', '2025Q2', '2025-06-30', 84.42, 0.17905, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第一至第三季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '会员（订阅）收入', '单季', '亿元', '2025Q2', '2025-06-30', 43.8, 0.171123, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第一至第三季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '非订阅音乐收入（广告、演出、周边）', '单季', '亿元', '2025Q2', '2025-06-30', 24.74, 0.469121, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第一至第三季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '社交娱乐及其他收入', '单季', '亿元', '2025Q2', '2025-06-30', 15.88, -0.085253, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第一至第三季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '毛利率', '单季', '%', '2025Q2', '2025-06-30', 44.41, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第一至第三季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '归母净利润', '单季', '亿元', '2025Q2', '2025-06-30', 24.09, 0.432224, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第一至第三季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '非国际财务报告准则归母净利润', '单季', '亿元', '2025Q2', '2025-06-30', 25.74, 0.374266, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第一至第三季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '在线音乐付费用户', '单季', '百万人', '2025Q2', '2025-06-30', 124.4, 0.063248, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第一至第三季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '单个付费用户月均收入（ARPPU）', '单季', '元', '2025Q2', '2025-06-30', 11.7, 0.093458, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第一至第三季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '在线音乐月活跃用户', '单季', '百万人', '2025Q2', '2025-06-30', 553, -0.031524, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第一至第三季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '营业收入', '单季', '亿元', '2025Q3', '2025-09-30', 84.63, 0.206415, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第一至第三季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '会员（订阅）收入', '单季', '亿元', '2025Q3', '2025-09-30', 45.0, 0.171875, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第一至第三季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '非订阅音乐收入（广告、演出、周边）', '单季', '亿元', '2025Q3', '2025-09-30', 24.69, 0.505488, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第一至第三季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '社交娱乐及其他收入', '单季', '亿元', '2025Q3', '2025-09-30', 14.94, -0.02671, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第一至第三季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '毛利率', '单季', '%', '2025Q3', '2025-09-30', 43.51, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第一至第三季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '归母净利润', '单季', '亿元', '2025Q3', '2025-09-30', 21.53, 0.360076, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第一至第三季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '非国际财务报告准则归母净利润', '单季', '亿元', '2025Q3', '2025-09-30', 24.05, 0.325799, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第一至第三季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '在线音乐付费用户', '单季', '百万人', '2025Q3', '2025-09-30', 125.7, 0.056303, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第一至第三季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '单个付费用户月均收入（ARPPU）', '单季', '元', '2025Q3', '2025-09-30', 11.9, 0.101852, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第一至第三季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '在线音乐月活跃用户', '单季', '百万人', '2025Q3', '2025-09-30', 551, -0.043403, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第一至第三季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '营业收入', '单季', '亿元', '2025Q4', '2025-12-31', 86.41, 0.158622, '2026-03-17 发布：宣布停止披露季度月活、付费用户和 ARPPU；美股次日 −24.7%。', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第四季度及全年未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '会员（订阅）收入', '单季', '亿元', '2025Q4', '2025-12-31', 45.6, 0.131514, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第四季度及全年未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '非订阅音乐收入（广告、演出、周边）', '单季', '亿元', '2025Q4', '2025-12-31', 25.39, 0.409772, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第四季度及全年未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '社交娱乐及其他收入', '单季', '亿元', '2025Q4', '2025-12-31', 15.42, -0.052243, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第四季度及全年未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '毛利率', '单季', '%', '2025Q4', '2025-12-31', 44.69, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第四季度及全年未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '归母净利润', '单季', '亿元', '2025Q4', '2025-12-31', 22.03, 0.125703, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第四季度及全年未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '非国际财务报告准则归母净利润', '单季', '亿元', '2025Q4', '2025-12-31', 24.85, 0.089912, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第四季度及全年未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '在线音乐付费用户', '单季', '百万人', '2025Q4', '2025-12-31', 127.4, 0.052893, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第四季度及全年未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '单个付费用户月均收入（ARPPU）', '单季', '元', '2025Q4', '2025-12-31', 11.9, 0.072072, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第四季度及全年未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '在线音乐月活跃用户', '单季', '百万人', '2025Q4', '2025-12-31', 528, -0.05036, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第四季度及全年未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '营业收入', '单季', '亿元', '2026Q1', '2026-03-31', 78.95, 0.073274, '“在线音乐服务”更名为“音乐相关服务”（含长音频）；会员服务同比 +6.6%（重述口径）。', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2026 年第二季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '会员（订阅）收入', '单季', '亿元', '2026Q1', '2026-03-31', 45.68, 0.066293, '2026 年起为“会员服务”（含长音频）；同比按重述后的 2025Q1 数 42.84 亿元计算。', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2026 年第二季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '非订阅音乐收入（广告、演出、周边）', '单季', '亿元', '2026Q1', '2026-03-31', 19.46, 0.280263, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2026 年第二季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '社交娱乐及其他收入', '单季', '亿元', '2026Q1', '2026-03-31', 13.81, -0.11018, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2026 年第二季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '毛利率', '单季', '%', '2026Q1', '2026-03-31', 44.91, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2026 年第二季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '归母净利润', '单季', '亿元', '2026Q1', '2026-03-31', 20.91, -0.512701, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2026 年第二季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '非国际财务报告准则归母净利润', '单季', '亿元', '2026Q1', '2026-03-31', 22.73, 0.070151, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2026 年第二季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '营业收入', '单季', '亿元', '2026Q2', '2026-06-30', 89.33, 0.058162, '喜马拉雅 5 月 18 日起并表，贡献收入 4.07 亿元；剔除后会员内生增长约持平（摩根大通估算）；回购 4.0 亿美元。', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2026 年第二季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '会员（订阅）收入', '单季', '亿元', '2026Q2', '2026-06-30', 47.92, 0.08074, '2026 年起为“会员服务”（含长音频）；同比按重述后的 2025Q2 数 44.34 亿元计算。', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2026 年第二季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '非订阅音乐收入（广告、演出、周边）', '单季', '亿元', '2026Q2', '2026-06-30', 28.13, 0.162397, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2026 年第二季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '社交娱乐及其他收入', '单季', '亿元', '2026Q2', '2026-06-30', 13.28, -0.163728, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2026 年第二季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '毛利率', '单季', '%', '2026Q2', '2026-06-30', 44.21, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2026 年第二季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '归母净利润', '单季', '亿元', '2026Q2', '2026-06-30', 24.71, 0.025737, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2026 年第二季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '非国际财务报告准则归母净利润', '单季', '亿元', '2026Q2', '2026-06-30', 26.86, 0.043512, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2026 年第二季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '会员（订阅）收入', '全年', '亿元', '2021', '2021-12-31', 73.33, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2022、2023 年第四季度业绩公告与 2023 年年报（经营指标片段）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '会员（订阅）收入', '全年', '亿元', '2022', '2022-12-31', 86.99, 0.186281, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2022、2023 年第四季度业绩公告与 2023 年年报（经营指标片段）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '会员（订阅）收入', '全年', '亿元', '2023', '2023-12-31', 120.96, 0.390505, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2022、2023 年第四季度业绩公告与 2023 年年报（经营指标片段）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '会员（订阅）收入', '全年', '亿元', '2024', '2024-12-31', 152.3, 0.259094, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第四季度及全年未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '会员（订阅）收入', '全年', '亿元', '2025', '2025-12-31', 176.6, 0.159554, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第四季度及全年未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '非订阅音乐收入（广告、演出、周边）', '全年', '亿元', '2023', '2023-12-31', 52.29, NULL, '在线音乐 173.25 − 订阅 120.96。', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2022、2023 年第四季度业绩公告与 2023 年年报（经营指标片段）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '非订阅音乐收入（广告、演出、周边）', '全年', '亿元', '2024', '2024-12-31', 65.12, 0.245, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第四季度及全年未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '非订阅音乐收入（广告、演出、周边）', '全年', '亿元', '2025', '2025-12-31', 90.66, 0.392, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第四季度及全年未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '社交娱乐及其他收入', '全年', '亿元', '2023', '2023-12-31', 104.27, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2022、2023 年第四季度业绩公告与 2023 年年报（经营指标片段）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '社交娱乐及其他收入', '全年', '亿元', '2024', '2024-12-31', 66.59, -0.361, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第四季度及全年未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '社交娱乐及其他收入', '全年', '亿元', '2025', '2025-12-31', 61.76, -0.073, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第四季度及全年未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '现金、定期存款和短期投资', '单季', '亿元', '2025Q3', '2025-09-30', 360.8, NULL, '季末余额', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第四季度及全年未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '现金、定期存款和短期投资', '单季', '亿元', '2025Q4', '2025-12-31', 380.4, NULL, '季末余额', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第四季度及全年未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '现金、定期存款和短期投资', '单季', '亿元', '2026Q1', '2026-03-31', 410.0, NULL, '季末余额', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2026 年第二季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '现金、定期存款和短期投资', '单季', '亿元', '2026Q2', '2026-06-30', 442.2, NULL, '季末余额；同期新增借款 131.4 亿元。', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2026 年第二季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '带息负债（借款＋票据＋租赁）', '单季', '亿元', '2026Q2', '2026-06-30', 168.84, NULL, '季末余额：借款 131.39＋应付票据 33.90＋租赁负债 3.55。', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2026 年第二季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '回购金额', '单季', '亿美元', '2025Q1', '2025-03-31', 0.645, NULL, '590 万股 ADS，均价 10.8 美元。', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第一至第三季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '回购金额', '单季', '亿美元', '2026Q2', '2026-06-30', 4.0, NULL, '4,350 万股 ADS，均价 9.2 美元。', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2026 年第二季度未经审计财务业绩公告' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '竞品月活：汽水音乐', '单季', '百万人', '2026Q3', '2026-07-31', 170, NULL, '2026 年 7 月数据（第三方监测）：日活 5,969 万；番茄音乐月活 4,553 万。', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '行业竞争资料：汽水音乐、番茄音乐用户规模与定价' LIMIT 1));

INSERT INTO vi_model_base (company_id, name, status, method, base_year, terminal_year, shares, rf, rf_date, rf_metric_id, erp,
  opening_debt, opening_op_assets, opening_lt_invest, opening_equity, opening_minority, required_return, margin_low, margin_high, notes,
  primary_method, sotp_year, sotp_core_adj, sotp_as_of)
VALUES ((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '腾讯音乐 分部加总（主营三块＋自由现金＋对外投资）', '当前',
  '分部加总，三块：①主营业务价值＝会员订阅、非订阅音乐、社交娱乐三块各自的 2027 年税后盈利×倍数，折回 2026-06-30（J-S1、J-S2、J-S3、J-R）；'
  '②可分配的自由现金＝现金−带息负债−经营所需−汇出预提税（J-CASH）；③对外投资＝最新报告账面价值×70%（J-INV）；再减少数股东权益。不做逐年预测与股息贴现（2026-10-28 起）。'
  '估值用人民币，港股股价按当天港元兑人民币折算后比较。',
  2025, 2035, 31.5, 0.0164, '2026-10-22', (SELECT id FROM vi_metric_base WHERE code = 'CGB10Y.CCDC'), 0.07,
  38.13, 271.98, 278.90, 802.87, 27.63, 0.06, 0.10, 0.30,
  '口径（2026-10-28）：主营三块的利润率是分摊估算，三块加总须等于公司整体核心经营利润（不含利息、投资收益与收购摊销）；税率 17.5%，归母 97%。非经营部分统一截至 2026-06-30（与股本同日）。股本 31.5 亿股为 2026 年 6 月末流通股估算（喜马拉雅发行与二季度回购之后，待年报核对）；未来回购按市价进行，对每股价值影响小，不预测股本变化；股权激励已作为费用计入利润率。市场价＝港股收盘价×当天港元兑人民币（自动采集）。安全边际两档并列 10%/30%。',
  '分部加总', NULL, NULL, '2026-06-30')
;

INSERT INTO vi_scenario_base (model_id, name, is_base, sort, volume_factor, price_factor, cost_factor, discount_rate, terminal_growth, ronic, nature, description, sotp_multiple) VALUES
((SELECT id FROM vi_model_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '腾讯音乐 分部加总（主营三块＋自由现金＋对外投资）'), '悲观', FALSE, 1, 1, 1, 1, 0.1, 0.0, 0.15, '免费模式侵蚀付费核心、演出与直播双双走弱', '会员 195、非订阅 105、社交娱乐 42 亿元，利润率 35%、12%、10%；折现率 10.0%，永续增长 0。', NULL),
((SELECT id FROM vi_model_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '腾讯音乐 分部加总（主营三块＋自由现金＋对外投资）'), '基准', TRUE, 2, 1, 1, 1, NULL, 0.02, 0.15, '会员内生约持平、多元变现带动收入低个位数增长', '会员 208、非订阅 117、社交娱乐 48 亿元，利润率 42%、15%、15%（三块合计 373 亿元、税前 112 亿元）；折现率＝无风险利率＋风险溢价（8.6%），永续增长 2%。', NULL),
((SELECT id FROM vi_model_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '腾讯音乐 分部加总（主营三块＋自由现金＋对外投资）'), '乐观', FALSE, 3, 1, 1, 1, 0.076, 0.03, 0.2, '超级会员与喜马拉雅交叉销售成功、订阅重回增长', '会员 218、非订阅 125、社交娱乐 50 亿元，利润率 45%、17%、18%；折现率 7.6%，永续增长 3%，新增投资回报率 20%。', NULL);

INSERT INTO vi_sotp_item_base (model_id, scenario_id, code, name, kind, amount, haircut, as_of, basis) VALUES
((SELECT id FROM vi_model_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '腾讯音乐 分部加总（主营三块＋自由现金＋对外投资）'), NULL, 'C1', '现金、现金等价物、定期存款和短期投资', '现金及等价物', 442.22, 0, '2026-06-30', '现金及现金等价物 236.98＋定期存款 204.01（流动 67.61、非流动 136.40）＋短期投资 1.23。'),
((SELECT id FROM vi_model_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '腾讯音乐 分部加总（主营三块＋自由现金＋对外投资）'), NULL, 'C2', '带息负债：借款、应付票据、租赁负债', '带息负债', 168.84, 0, '2026-06-30', '借款 131.39＋2030 年到期 5 亿美元票据 33.90＋租赁负债 3.55。2026 年 9 月新发的 10 亿美元票据在发行时同时增加现金和负债，净额不变。'),
((SELECT id FROM vi_model_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '腾讯音乐 分部加总（主营三块＋自由现金＋对外投资）'), NULL, 'C3', '经营所需现金（周转＋季节波动＋压力缓冲）', '经营所需现金', 40, 0, '2026-06-30', '一个月付现成本约 21 亿元＋浮存金季度间最大回落约 10 亿元＋收入下降 10% 时浮存金收回约 8 亿元；浮存金本身不扣，测算见 J-OPCASH。'),
((SELECT id FROM vi_model_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '腾讯音乐 分部加总（主营三块＋自由现金＋对外投资）'), NULL, 'C4', '境内资金汇出预提税（10%）', '资金汇出成本', 21.7, 0, '2026-06-30', '年报：2025 年末境内未分派利润 172.47 亿元对应 17.25 亿元；加 2026 年上半年境内利润约 45 亿元×10%≈4.5 亿元。'),
((SELECT id FROM vi_model_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '腾讯音乐 分部加总（主营三块＋自由现金＋对外投资）'), NULL, 'C5', '对外上市股权（Spotify、UMG、WMG 等，账面公允价值）', '对外投资', 191.47, 0.3, '2026-06-30', '最新报告（6 月末）账面价值打七折，见 J-INV。'),
((SELECT id FROM vi_model_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '腾讯音乐 分部加总（主营三块＋自由现金＋对外投资）'), NULL, 'C6', '权益法投资', '对外投资', 26.91, 0.3, '2026-06-30', '最新报告账面价值打七折，见 J-INV。'),
((SELECT id FROM vi_model_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '腾讯音乐 分部加总（主营三块＋自由现金＋对外投资）'), NULL, 'C7', '其他投资', '对外投资', 10.06, 0.3, '2026-06-30', '非流动 9.34＋流动 0.72，打七折，见 J-INV。'),
((SELECT id FROM vi_model_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '腾讯音乐 分部加总（主营三块＋自由现金＋对外投资）'), NULL, 'C8', '少数股东权益', '少数股东权益', 28.01, 0, '2026-06-30', '6 月末账面价值；主营盈利已按 97% 归母，现金与投资是合并口径，需扣除少数股东那部分。');

INSERT INTO vi_lnk_sotp_item_facts (sotp_item_id, fact_id, "createdAt", "updatedAt")
SELECT x.id, y.id, now(), now() FROM (VALUES ('C1', '', '2026 年 6 月末：现金等 442.2 亿元、带息负债 168.8 亿元、对外投资 228.4 亿元'), ('C1', '', '现金等 442 亿元，借款与票据约 165 亿元'), ('C2', '', '2026 年 6 月末：现金等 442.2 亿元、带息负债 168.8 亿元、对外投资 228.4 亿元'), ('C2', '', '2026 年 9 月发行 10 亿美元票据（5.05%、5.65%）'), ('C3', '', '现金等 442 亿元，借款与票据约 165 亿元'), ('C3', '', '2026 年 6 月末：现金等 442.2 亿元、带息负债 168.8 亿元、对外投资 228.4 亿元'), ('C4', '', '境内未分派利润 172.5 亿元，汇出预提税约 17.3 亿元（2025 年末）'), ('C5', '', '对外投资 191 亿元：Spotify、UMG、WMG、SM 娱乐'), ('C5', '', '2026 年 6 月末：现金等 442.2 亿元、带息负债 168.8 亿元、对外投资 228.4 亿元'), ('C6', '', '2026 年 6 月末：现金等 442.2 亿元、带息负债 168.8 亿元、对外投资 228.4 亿元'), ('C7', '', '2026 年 6 月末：现金等 442.2 亿元、带息负债 168.8 亿元、对外投资 228.4 亿元'), ('C8', '', '2026 年 6 月末：现金等 442.2 亿元、带息负债 168.8 亿元、对外投资 228.4 亿元')) v(code, sname, ft)
JOIN vi_sotp_item_base x ON x.model_id = (SELECT id FROM vi_model_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '腾讯音乐 分部加总（主营三块＋自由现金＋对外投资）') AND x.code = v.code
  AND coalesce((SELECT name FROM vi_scenario_base WHERE id = x.scenario_id), '') = v.sname
JOIN vi_fact_base y ON y.company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND y.title = v.ft;

INSERT INTO vi_sotp_segment_base (model_id, scenario_id, code, name, method, earn_year, revenue, op_margin, tax_rate, attrib, multiple, basis) VALUES
((SELECT id FROM vi_model_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '腾讯音乐 分部加总（主营三块＋自由现金＋对外投资）'), (SELECT id FROM vi_scenario_base WHERE model_id = (SELECT id FROM vi_model_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '腾讯音乐 分部加总（主营三块＋自由现金＋对外投资）') AND name = '悲观'), 'S1', '会员订阅（含长音频会员）', '盈利×倍数', 2027, 195, 0.35, 0.175, 0.97, NULL, '音乐会员内生下滑，喜马拉雅会员约 24 亿元；见 J-S1。'),
((SELECT id FROM vi_model_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '腾讯音乐 分部加总（主营三块＋自由现金＋对外投资）'), (SELECT id FROM vi_scenario_base WHERE model_id = (SELECT id FROM vi_model_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '腾讯音乐 分部加总（主营三块＋自由现金＋对外投资）') AND name = '基准'), 'S1', '会员订阅（含长音频会员）', '盈利×倍数', 2027, 208, 0.42, 0.175, 0.97, NULL, '音乐会员内生约 +2%/年到约 184 亿元，加喜马拉雅会员约 24 亿元；见 J-S1。'),
((SELECT id FROM vi_model_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '腾讯音乐 分部加总（主营三块＋自由现金＋对外投资）'), (SELECT id FROM vi_scenario_base WHERE model_id = (SELECT id FROM vi_model_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '腾讯音乐 分部加总（主营三块＋自由现金＋对外投资）') AND name = '乐观'), 'S1', '会员订阅（含长音频会员）', '盈利×倍数', 2027, 218, 0.45, 0.175, 0.97, NULL, '超级会员提价与长音频捆绑成功；见 J-S1。'),
((SELECT id FROM vi_model_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '腾讯音乐 分部加总（主营三块＋自由现金＋对外投资）'), (SELECT id FROM vi_scenario_base WHERE model_id = (SELECT id FROM vi_model_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '腾讯音乐 分部加总（主营三块＋自由现金＋对外投资）') AND name = '悲观'), 'S2', '非订阅音乐（广告、演出、周边、艺人经纪）', '盈利×倍数', 2027, 105, 0.12, 0.175, 0.97, NULL, '演出放缓、广告继续流向短视频；见 J-S2。'),
((SELECT id FROM vi_model_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '腾讯音乐 分部加总（主营三块＋自由现金＋对外投资）'), (SELECT id FROM vi_scenario_base WHERE model_id = (SELECT id FROM vi_model_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '腾讯音乐 分部加总（主营三块＋自由现金＋对外投资）') AND name = '基准'), 'S2', '非订阅音乐（广告、演出、周边、艺人经纪）', '盈利×倍数', 2027, 117, 0.15, 0.175, 0.97, NULL, '2026 年约 106 亿元再 +10%，含喜马拉雅广告约 10 亿元；见 J-S2。'),
((SELECT id FROM vi_model_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '腾讯音乐 分部加总（主营三块＋自由现金＋对外投资）'), (SELECT id FROM vi_scenario_base WHERE model_id = (SELECT id FROM vi_model_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '腾讯音乐 分部加总（主营三块＋自由现金＋对外投资）') AND name = '乐观'), 'S2', '非订阅音乐（广告、演出、周边、艺人经纪）', '盈利×倍数', 2027, 125, 0.17, 0.175, 0.97, NULL, '演出与粉丝经济保持高增长；见 J-S2。'),
((SELECT id FROM vi_model_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '腾讯音乐 分部加总（主营三块＋自由现金＋对外投资）'), (SELECT id FROM vi_scenario_base WHERE model_id = (SELECT id FROM vi_model_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '腾讯音乐 分部加总（主营三块＋自由现金＋对外投资）') AND name = '悲观'), 'S3', '社交娱乐（直播打赏）', '盈利×倍数', 2027, 42, 0.1, 0.175, 0.97, 5.0, '萎缩年金 1÷(10%＋10%)；见 J-S3。'),
((SELECT id FROM vi_model_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '腾讯音乐 分部加总（主营三块＋自由现金＋对外投资）'), (SELECT id FROM vi_scenario_base WHERE model_id = (SELECT id FROM vi_model_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '腾讯音乐 分部加总（主营三块＋自由现金＋对外投资）') AND name = '基准'), 'S3', '社交娱乐（直播打赏）', '盈利×倍数', 2027, 48, 0.15, 0.175, 0.97, 6.0, '萎缩年金 1÷(8.6%＋8%)；见 J-S3。'),
((SELECT id FROM vi_model_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '腾讯音乐 分部加总（主营三块＋自由现金＋对外投资）'), (SELECT id FROM vi_scenario_base WHERE model_id = (SELECT id FROM vi_model_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '腾讯音乐 分部加总（主营三块＋自由现金＋对外投资）') AND name = '乐观'), 'S3', '社交娱乐（直播打赏）', '盈利×倍数', 2027, 50, 0.18, 0.175, 0.97, 7.9, '萎缩年金 1÷(7.6%＋5%)；见 J-S3。');

INSERT INTO vi_fin_forecast_base (model_id, year, sub_rev, nonsub_rev, social_rev, gross_margin, selling_ratio, admin_ratio, other_income, equity_income, finance_cost, tax_rate, minority_share, sbc, acq_amort, cfo_ratio, capex, shareholder_return, other_cash, note) VALUES
((SELECT id FROM vi_model_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '腾讯音乐 分部加总（主营三块＋自由现金＋对外投资）'), 2026, 196, 106, 53, 0.44, 0.031, 0.124, 12.0, 0.5, 4.0, 0.175, 0.03, 7.0, 6.0, 1.15, 12.0, 78, -80, '上半年实际收入 168.3 亿元；喜马拉雅 5 月起并表。股东回报＝上半年回购约 27＋2025 年度股息约 26＋下半年回购约 25；其他现金＝喜马拉雅现金对价约 −80。'),
((SELECT id FROM vi_model_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '腾讯音乐 分部加总（主营三块＋自由现金＋对外投资）'), 2027, 208, 117, 48, 0.44, 0.03, 0.125, 9.0, 0.5, 7.5, 0.175, 0.03, 7.0, 9.0, 1.15, 12.5, 80, 0, '喜马拉雅全年并表；核心经营利润 106.3 亿元，加回七成收购摊销后与估值模型三块合计（112.1 亿元）一致。'),
((SELECT id FROM vi_model_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '腾讯音乐 分部加总（主营三块＋自由现金＋对外投资）'), 2028, 213, 126, 44, 0.44, 0.03, 0.123, 8.0, 0.5, 7.5, 0.175, 0.03, 7.0, 9.0, 1.15, 13.0, 85, 0, '会员内生约 +2%、非订阅 +8%、社交娱乐 −8%。');

INSERT INTO vi_issue_base (company_id, code, title, severity, impact, done_condition, status, progress) VALUES
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), 'Q01', '安全边际选 10% 还是 30%', '策略', '关注价', '用户确定交易纪律后在估值模型里只保留一档。', '待处理', '两档并列展示（与其他三家公司一致）。'),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), 'Q02', '主营三块的 2027 年假设待核验（收入、利润率）', '关键', '主营业务价值（三情景）', '三季报（2026 年 11 月中旬）与年报出来后，对照三块收入与公司整体利润率修正 J-S1—J-S3。', '待处理', '三季报重点：剔除喜马拉雅后的会员收入同比、毛利率是否守住 43%、新一轮回购计划。'),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), 'Q03', '流通股数为估算', '关键', '每股价值', '取得 2026 年 6 月末或最新的流通股数（年报、股份变动月报或 20-F）。', '待处理', '估算 31.4—31.7 亿股，模型用 31.5（口径见估值模型说明与事实摘录“流通股约 31.5 亿股（估算）”）。'),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), 'Q04', '喜马拉雅现金净流出与购买价分摊', '一般', '会员订阅收入（喜马拉雅部分）、收购摊销口径', '读取 2026 年中期报告全文的业务合并附注（岗底斯下载因文件名过长失败）。', '待处理', '腾讯控股中报：现金约 80 亿元、商誉约 92 亿元；交割时取得的现金未知。'),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), 'Q05', '停披季度经营指标后的替代跟踪', '关键', '论点 T3', '用会员服务收入（剔除喜马拉雅）、第三方监测的付费用户与竞品月活替代；年报核对年末付费用户。', '处理中', '2019—2020 年第四季度付费用户也未取得。'),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), 'Q06', '境内现金能否回到股东手里', '关键', '股东回报率、超额现金', '确认境内外现金分布、预提税率与外汇安排；跟踪美元票据与借款用途。', '待处理', '2026 年用美元借款和票据支付喜马拉雅现金对价与回购，境内保留人民币存款。'),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), 'Q07', '对外投资按最新报告更新', '一般', '对外投资（C5—C7）', '每季报告出来后更新 C5—C7 的账面价值，统一打七折（J-INV）；不跟踪股价日常波动。', '处理中', '当前按 2026 年 6 月末账面价值 228.4 亿元打七折，约 160 亿元。'),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), 'Q09', '经营所需现金与汇出成本的口径', '一般', '分部加总', '用年报的境内外现金分布与未分派利润更新 C3、C4。', '待处理', '三情景统一扣经营所需现金 40 亿元（J-OPCASH）、预提税 21.7 亿元（J-CASH）。'),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), 'Q08', '电话会、研报与第三方监测为三级来源', '一般', '事实摘录', '竞争数据、指引转述以公告核对；第三方月活只看趋势。', '待处理', NULL);

INSERT INTO vi_change_log_base (company_id, change_date, title, target, old_value, new_value, reason, basis, verification) VALUES
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026-10-22', '纳入价值投资框架（独立项目，第一家境外上市公司）', '公司、论点、事实、判断、历史财务、估值模型、跟踪；框架增加股价汇率换算', '—', '10 条论点（6 条自动证伪）、27 张事实卡、16 条判断、2017—2025 年历史财务、10 个季度经营数据与付费用户/ARPPU/月活、DDM（股息＋回购）＋现金桥接模型（2026—2035 年逐年假设、三情景、6 个单参数试验）、11 个跟踪事项；港股股价与港元兑人民币自动采集', '用户要求按同一架构再做腾讯音乐，作为独立项目', '2025 年四季度及全年、2025 年一至三季度、2026 年二季度业绩公告；股息、喜马拉雅、美元票据公告；腾讯控股中报；业绩会纪要与卖方、外资研报；东方财富报表；腾讯行情', '2024、2025 年季度收入与归母净利合计与年度公告一致；东方财富 2025 年报表与业绩公告一致；Python 复算与数据库视图结果核对'),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026-10-22', '补充商业与壁垒：商业模式、产业链与五力、竞争对手、竞争壁垒、多空辩论、适配度', '新增六张表的内容；新增 4 个来源、11 张事实卡', '框架没有商业模式、产业链、竞对与壁垒的结构化分析', '商业模式 9 个要素；产业链 11 个环节（含五力归类）；竞争对手 6 个；候选壁垒 9 项（真实 1：上游议价权；局部优势 3：曲库、转换成本、腾讯生态；待验证 1：IP 与粉丝经济；伪壁垒 4）；多空辩论 5 场（正方占优 1、势均力敌 2、反方占优 2）；适配度 25/40（可研究，更偏现金流价值）', '用户要求补充竞争壁垒、商业模式、竞对和产业链分析，并用辩论方式对抗检验', '岗底斯：卖方行业深度（国信、中金、长江、中信建投）、行业交流纪要、网易云中报点评、汽水音乐专题；公司公告。岗底斯观点 PK 三次调用均超时，辩论由本研究组织', '新增关联 11 张表的条数与脚本预期一致；壁垒自动检查（毛利率、付费用户同比）未触发；估值与论点检查结果不变'),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026-10-22', '主估值改为分部加总，股息贴现作交叉验证', '估值模型、情景、分部估值项；新增判断 J-SOTP-E、J-SOTP-M、J-SOTP-C、J-SOTP-I', '股息贴现（股息＋回购）为唯一估值：基准 44.58 元；现金只释放约 100 亿元，对外投资不计入', '核心盈利 90.1 亿元（2027 年）×13.1 倍＋可用净现金 231.7 亿元＋对外投资（折后）159.9 亿元−少数股东 28.0 亿元：基准每股 49.10 元；悲观 29.27 元、乐观 72.84 元；市场隐含核心倍数约 5.5 倍', '用户要求按“核心业务盈利×合理倍数＋可用净现金＋对外投资”估值，并做深度优化', '2026 年二季报资产负债表；2025 年年报未分派利润与预提税；收购摊销；同业与卖方倍数；价值驱动公式', 'Python 独立复算三情景的核心盈利、倍数、可用净现金、对外投资与每股价值，与数据库视图一致'),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026-10-23', '商业模式分析重构：论点与多空辩论合并，同一观点只写一处', '论点与辩论、竞争壁垒、商业模式、产业链与五力、适配度的关联，参数判断与跟踪事项里的论点编号', '投资论点 10 条＋多空辩论 5 场，分在“研究”“商业与壁垒”两组；同一观点在论点、辩论、壁垒、产业链里重复（例如版权护城河同时写在 T1、D1、M1、M2、V2）', '论点与辩论 7 条（辩论过 5 条，带自动检查 6 条）：T1 上游议价权与曲库（原 T1＋D1）、T2 腾讯生态入口（原 D4）、T3 免费模式只分流轻度用户（原 T2＋D2＋T8）、T4 多元变现（原 T3＋D3＋T7）、T5 治理与股东回报（原 T5＋D5＋T9）、T6 利润是真现金（原 T4）、T7 借钱回购但保持净现金（原 T6）；原 T10（监管）并入产业链 V11。商业模式、产业链、竞争壁垒里与论点重复的论证改成按编号引用；产业链的同业、进入者、替代品关联到具体对手。原 T2 标“存疑”与辩论 D2 的“势均力敌”不一致，按辩论记为“观察”。', '用户要求把“研究”和“商业与壁垒”合并为“商业模式分析”，尽量减少冗余、确保内容完整', '框架迁移 2026-10-23d（多空辩论并入论点：正方占优→成立、势均力敌→观察、反方占优→存疑）；内容来自原论点、辩论与各表，没有新增研究结论', 'tools/content_audit.py：重构前研究文字里 432 个带单位的数字，重构后只有 1 个找不到（“28 元”，J-PAYOUT 里写作“28.0 元”）；行与行之间共有的长片段从 57 对降到 38 对（剩下的多是事实卡与引用它的行）。估值不变：股息贴现 24.51、44.59、66.65 元，分部加总 29.27、49.10、72.84 元；C09、C14、C15、C16 通过，5 项非伪壁垒都关联了辩论过的论点。'),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026-10-27', '分部加总：补充“能拆开算”的论证与多余现金测算（估值不变）', '判断 J-REL、J-SOTP-C、J-CASH 的文字', '只写了核心盈利不含利息；可用净现金只有余额拆分，浮存金只扣 20 亿元的理由一句话带过；J-CASH 写“真正的超额现金约 190 亿元”，与分部加总基准口径不一致', 'J-REL：拆开算的三个条件；整体市盈率（约 36.1 元）、股息贴现（44.6 元）、分部加总（49.1 元）对应现金回到股东的三种程度；卖方 9 倍换成核心口径约 6.7 倍。J-SOTP-C：浮存金 2021—2026 年逐年核对、核心自由现金流 2022—2025 年对税后核心经营利润 1.33 倍、往后每年多余现金约 78 亿元、过去只还 38%。J-CASH：说明股息贴现与分部加总对浮存金的不同口径。', '有人质疑“净利润已含投资部分，分部估值重复”；用户要求补强多余现金测算并论证主业单独估值', '东方财富港股三大报表 2021—2026 年中（data/fin_stmt.json）；模型 2027 年预测', '分部加总 29.30、49.12、72.87 元与股息贴现 24.54、44.63、66.70 元与修改前一致（只改文字）'),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026-10-28', '估值重构为三块：主营三块盈利×倍数＋可分配自由现金＋对外投资七折；删除逐年预测与股息贴现', '估值模型、情景、经营分部（新增 S1—S3）、分部估值项、判断（20 条减为 6 条）、假设依据与风险的跟踪指标、逐年假设与单参数试验（删除）', '核心盈利 90.1 亿元（2027 年，整体一个数）×13.1 倍＋可用净现金（悲观、乐观另设经营所需与预提税）＋对外投资（悲观五折、乐观八五折）；股息贴现交叉验证；判断 20 条', '主营三块（2027 年基准）：会员订阅 208 亿元×42%、非订阅音乐 117 亿元×15%（13.1 倍）、社交娱乐 48 亿元×15%（萎缩年金 6.0 倍），折回 2026-06-30 半年；自由现金＝442.2−168.8−20−21.7；对外投资 228.4×70%；三情景只改主营。判断 6 条：J-S1、J-S2、J-S3、J-R、J-CASH、J-INV。跟踪指标 8 个。', '用户要求估值与财务模型分成三块（主营分三部分、可分配的自由现金、对外投资统一按最新报告打七折），删掉股息贴现，并精简假设与跟踪', '2025 年报（只有一个经营分部，不披露分业务成本）；季度收入构成；摩根大通非订阅收入构成（2026-08）；原模型 2027 年核心经营利润 106.3 亿元', '三块合计收入 373 亿元、税前 112.1 亿元，与原模型 2027 年核心经营利润加回收购摊销一致；三情景每股价值见估值结论'),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026-10-28', '页面合并为「估值模型」；「财务模型」改为券商研报式预测（2026E—2028E）', '估值、估值模型、情景三页合并；新增财务预测表与判断 J-FIN；三块收入判断补逐年数', '估值、模型底稿 / 估值模型、模型底稿 / 情景三页内容重复；财务模型页只显示三块估值', '「估值模型」：总览＋业务估值、资产估值与调整、情景、模型参数四个编辑标签。「财务模型」：2023A—2028E 利润表与现金摘要，2026E—2028E 收入 355、373、383 亿元，归母 87.8、86.7、88.8 亿元，经调整 100.8、102.7、104.8 亿元，期末净现金 273、280、285 亿元。判断 7 条。', '用户要求估值模型保持简单的三块框架给出直观结论，财务模型做成券商研报后面那种具体的财报数据预测', '三大报表 2023—2025 年；季度收入构成；2026 年上半年实际；原模型 2027 年口径', '2027E 核心经营利润 106.3＋七成收购摊销 6.3＝112.6 亿元，与估值模型三块合计税前 112.1 亿元相差 0.4%；2026E 期末净现金 273.2 亿元与 6 月末实际 273.4 亿元一致'),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026-10-28', '经营所需现金从 20 亿元改为 40 亿元，新增判断 J-OPCASH', '分部估值项 C3；判断 J-OPCASH（新增）、J-CASH', '经营所需现金 20 亿元（约一个月付现成本，经验值）；可分配自由现金约 232 亿元', '经营所需现金 40 亿元＝日常周转约 21（一个月付现成本）＋季节性波动约 10（浮存金季度间最大回落，剔除股息应付）＋压力缓冲约 8（收入下降 10%）；可分配自由现金约 212 亿元', '用户要求用一条假设依据专门论证主营需要的资金体量，并说明先收钱、后分钱的模式资金需求小', '2025 年报附注 26（其他应付及应计费用构成）、附注 27（递延收入）、附注 32（应收腾讯集团 22.5 亿元为支付渠道代收）；2021—2026 年季度资产负债表', '浮存金各季末按报表科目逐项复算；付现成本按利润表与现金流量表的折旧摊销复算');

DELETE FROM vi_fin_stmt_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK');

INSERT INTO vi_fin_stmt_base (company_id, period, period_end, stmt, item, seq, amount) VALUES
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q2', '2026-06-30', '资产负债表', '物业厂房及设备', 1, 15.4),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q2', '2026-06-30', '资产负债表', '无形资产', 2, 58.95),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q2', '2026-06-30', '资产负债表', '商誉', 3, 297.57),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q2', '2026-06-30', '资产负债表', '土地使用权', 4, 22.54),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q2', '2026-06-30', '资产负债表', '递延税项资产', 5, 6.33),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q2', '2026-06-30', '资产负债表', '预付款项', 6, 4.45),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q2', '2026-06-30', '资产负债表', '其他投资', 7, 36.25),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q2', '2026-06-30', '资产负债表', '指定以公允价值记账之金融资产', 8, 191.47),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q2', '2026-06-30', '资产负债表', '中长期存款', 9, 136.4),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q2', '2026-06-30', '资产负债表', '非流动资产其他项目', 10, 3.22),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q2', '2026-06-30', '资产负债表', '非流动资产合计', 11, 772.58),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q2', '2026-06-30', '资产负债表', '存货', 12, 0.98),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q2', '2026-06-30', '资产负债表', '应收帐款', 13, 41.84),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q2', '2026-06-30', '资产负债表', '预付款按金及其他应收款', 14, 47.45),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q2', '2026-06-30', '资产负债表', '短期投资', 15, 1.95),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q2', '2026-06-30', '资产负债表', '受限制存款及现金', 16, 0.08),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q2', '2026-06-30', '资产负债表', '现金及等价物', 17, 236.98),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q2', '2026-06-30', '资产负债表', '短期存款', 18, 67.61),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q2', '2026-06-30', '资产负债表', '流动资产合计', 19, 396.89),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q2', '2026-06-30', '资产负债表', '总资产', 20, 1169.47),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q2', '2026-06-30', '资产负债表', '应付帐款', 21, 67.16),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q2', '2026-06-30', '资产负债表', '应付税项', 22, 9.99),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q2', '2026-06-30', '资产负债表', '融资租赁负债(流动)', 23, 1.37),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q2', '2026-06-30', '资产负债表', '递延收入(流动)', 24, 44.47),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q2', '2026-06-30', '资产负债表', '其他应付款及应计费用', 25, 44.51),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q2', '2026-06-30', '资产负债表', '短期贷款', 26, 59.97),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q2', '2026-06-30', '资产负债表', '流动负债合计', 27, 227.47),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q2', '2026-06-30', '资产负债表', '净流动资产', 28, 169.42),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q2', '2026-06-30', '资产负债表', '总资产减流动负债', 29, 942.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q2', '2026-06-30', '资产负债表', '长期贷款', 30, 71.42),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q2', '2026-06-30', '资产负债表', '递延税项负债', 31, 14.62),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q2', '2026-06-30', '资产负债表', '融资租赁负债(非流动)', 32, 2.18),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q2', '2026-06-30', '资产负债表', '递延收入(非流动)', 33, 4.47),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q2', '2026-06-30', '资产负债表', '长期应付款', 34, 4.68),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q2', '2026-06-30', '资产负债表', '应付票据(非流动)', 35, 33.9),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q2', '2026-06-30', '资产负债表', '非流动负债合计', 36, 131.27),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q2', '2026-06-30', '资产负债表', '总负债', 37, 358.74),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q2', '2026-06-30', '资产负债表', '少数股东权益', 38, 28.01),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q2', '2026-06-30', '资产负债表', '净资产', 39, 810.73),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q2', '2026-06-30', '资产负债表', '股本', 40, 0.02),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q2', '2026-06-30', '资产负债表', '保留溢利(累计亏损)', 41, 311.18),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q2', '2026-06-30', '资产负债表', '公积金', 42, 349.33),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q2', '2026-06-30', '资产负债表', '其他储备', 43, 156.08),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q2', '2026-06-30', '资产负债表', '库存股', 44, -33.89),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q2', '2026-06-30', '资产负债表', '股东权益', 45, 782.72),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q2', '2026-06-30', '资产负债表', '总权益', 46, 810.73),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q2', '2026-06-30', '资产负债表', '总权益及非流动负债', 47, 942.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q2', '2026-06-30', '资产负债表', '总权益及总负债', 48, 1169.47),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q1', '2026-03-31', '资产负债表', '物业厂房及设备', 1, 13.01),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q1', '2026-03-31', '资产负债表', '无形资产', 2, 27.7),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q1', '2026-03-31', '资产负债表', '商誉', 3, 205.28),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q1', '2026-03-31', '资产负债表', '土地使用权', 4, 22.72),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q1', '2026-03-31', '资产负债表', '递延税项资产', 5, 5.35),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q1', '2026-03-31', '资产负债表', '预付款项', 6, 4.18),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q1', '2026-03-31', '资产负债表', '其他投资', 7, 28.92),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q1', '2026-03-31', '资产负债表', '指定以公允价值记账之金融资产', 8, 198.66),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q1', '2026-03-31', '资产负债表', '中长期存款', 9, 143.3),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q1', '2026-03-31', '资产负债表', '非流动资产其他项目', 10, 2.72),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q1', '2026-03-31', '资产负债表', '非流动资产合计', 11, 651.84),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q1', '2026-03-31', '资产负债表', '存货', 12, 0.48),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q1', '2026-03-31', '资产负债表', '应收帐款', 13, 38.25),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q1', '2026-03-31', '资产负债表', '预付款按金及其他应收款', 14, 40.36),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q1', '2026-03-31', '资产负债表', '短期投资', 15, 0.73),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q1', '2026-03-31', '资产负债表', '受限制存款及现金', 16, 0.15),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q1', '2026-03-31', '资产负债表', '现金及等价物', 17, 184.16),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q1', '2026-03-31', '资产负债表', '短期存款', 18, 82.54),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q1', '2026-03-31', '资产负债表', '流动资产合计', 19, 346.67),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q1', '2026-03-31', '资产负债表', '总资产', 20, 998.51),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q1', '2026-03-31', '资产负债表', '应付帐款', 21, 61.76),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q1', '2026-03-31', '资产负债表', '应付税项', 22, 10.59),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q1', '2026-03-31', '资产负债表', '融资租赁负债(流动)', 23, 1.11),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q1', '2026-03-31', '资产负债表', '递延收入(流动)', 24, 38.15),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q1', '2026-03-31', '资产负债表', '其他应付款及应计费用', 25, 54.6),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q1', '2026-03-31', '资产负债表', '流动负债合计', 27, 166.21),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q1', '2026-03-31', '资产负债表', '净流动资产', 28, 180.46),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q1', '2026-03-31', '资产负债表', '总资产减流动负债', 29, 832.3),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q1', '2026-03-31', '资产负债表', '长期贷款', 30, 11.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q1', '2026-03-31', '资产负债表', '递延税项负债', 31, 5.88),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q1', '2026-03-31', '资产负债表', '融资租赁负债(非流动)', 32, 1.88),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q1', '2026-03-31', '资产负债表', '递延收入(非流动)', 33, 3.56),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q1', '2026-03-31', '资产负债表', '长期应付款', 34, 4.25),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q1', '2026-03-31', '资产负债表', '应付票据(非流动)', 35, 34.43),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q1', '2026-03-31', '资产负债表', '非流动负债合计', 36, 61.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q1', '2026-03-31', '资产负债表', '总负债', 37, 227.21),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q1', '2026-03-31', '资产负债表', '少数股东权益', 38, 27.9),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q1', '2026-03-31', '资产负债表', '净资产', 39, 771.3),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q1', '2026-03-31', '资产负债表', '股本', 40, 0.02),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q1', '2026-03-31', '资产负债表', '保留溢利(累计亏损)', 41, 286.47),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q1', '2026-03-31', '资产负债表', '公积金', 42, 300.2),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q1', '2026-03-31', '资产负债表', '其他储备', 43, 163.35),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q1', '2026-03-31', '资产负债表', '库存股', 44, -6.64),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q1', '2026-03-31', '资产负债表', '股东权益', 45, 743.4),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q1', '2026-03-31', '资产负债表', '总权益', 46, 771.3),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q1', '2026-03-31', '资产负债表', '总权益及非流动负债', 47, 832.3),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q1', '2026-03-31', '资产负债表', '总权益及总负债', 48, 998.51),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '资产负债表', '物业厂房及设备', 1, 12.01),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '资产负债表', '无形资产', 2, 28.99),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '资产负债表', '商誉', 3, 205.21),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '资产负债表', '土地使用权', 4, 22.9),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '资产负债表', '递延税项资产', 5, 4.98),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '资产负债表', '预付款项', 6, 3.65),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '资产负债表', '其他投资', 7, 19.62),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '资产负债表', '指定以公允价值记账之金融资产', 8, 262.31),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '资产负债表', '中长期存款', 9, 138.1),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '资产负债表', '非流动资产其他项目', 10, 2.87),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '资产负债表', '非流动资产合计', 11, 700.64),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '资产负债表', '存货', 12, 0.41),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '资产负债表', '应收帐款', 13, 39.03),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '资产负债表', '预付款按金及其他应收款', 14, 41.83),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '资产负债表', '短期投资', 15, 0.83),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '资产负债表', '受限制存款及现金', 16, 0.15),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '资产负债表', '现金及等价物', 17, 84.7),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '资产负债表', '短期存款', 18, 157.63),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '资产负债表', '流动资产合计', 19, 324.58),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '资产负债表', '总资产', 20, 1025.22),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '资产负债表', '应付帐款', 21, 62.84),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '资产负债表', '应付税项', 22, 10.92),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '资产负债表', '融资租赁负债(流动)', 23, 1.16),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '资产负债表', '递延收入(流动)', 24, 35.39),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '资产负债表', '其他应付款及应计费用', 25, 35.58),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '资产负债表', '流动负债合计', 27, 145.89),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '资产负债表', '净流动资产', 28, 178.69),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '资产负债表', '总资产减流动负债', 29, 879.33),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '资产负债表', '递延税项负债', 31, 5.04),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '资产负债表', '融资租赁负债(非流动)', 32, 2.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '资产负债表', '递延收入(非流动)', 33, 3.03),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '资产负债表', '长期应付款', 34, 3.79),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '资产负债表', '应付票据(非流动)', 35, 34.97),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '资产负债表', '非流动负债合计', 36, 48.83),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '资产负债表', '总负债', 37, 194.72),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '资产负债表', '少数股东权益', 38, 27.63),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '资产负债表', '净资产', 39, 830.5),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '资产负债表', '股本', 40, 0.02),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '资产负债表', '保留溢利(累计亏损)', 41, 293.81),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '资产负债表', '公积金', 42, 299.19),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '资产负债表', '其他储备', 43, 216.49),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '资产负债表', '库存股', 44, -6.64),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '资产负债表', '股东权益', 45, 802.87),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '资产负债表', '总权益', 46, 830.5),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '资产负债表', '总权益及非流动负债', 47, 879.33),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '资产负债表', '总权益及总负债', 48, 1025.22),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q3', '2025-09-30', '资产负债表', '物业厂房及设备', 1, 10.49),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q3', '2025-09-30', '资产负债表', '无形资产', 2, 29.44),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q3', '2025-09-30', '资产负债表', '商誉', 3, 205.17),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q3', '2025-09-30', '资产负债表', '土地使用权', 4, 23.08),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q3', '2025-09-30', '资产负债表', '递延税项资产', 5, 5.38),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q3', '2025-09-30', '资产负债表', '预付款项', 6, 3.73),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q3', '2025-09-30', '资产负债表', '其他投资', 7, 21.61),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q3', '2025-09-30', '资产负债表', '指定以公允价值记账之金融资产', 8, 309.4),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q3', '2025-09-30', '资产负债表', '中长期存款', 9, 138.1),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q3', '2025-09-30', '资产负债表', '非流动资产其他项目', 10, 3.09),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q3', '2025-09-30', '资产负债表', '非流动资产合计', 11, 749.49),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q3', '2025-09-30', '资产负债表', '存货', 12, 0.57),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q3', '2025-09-30', '资产负债表', '应收帐款', 13, 36.82),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q3', '2025-09-30', '资产负债表', '预付款按金及其他应收款', 14, 38.43),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q3', '2025-09-30', '资产负债表', '短期投资', 15, 0.5),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q3', '2025-09-30', '资产负债表', '受限制存款及现金', 16, 0.15),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q3', '2025-09-30', '资产负债表', '现金及等价物', 17, 112.55),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q3', '2025-09-30', '资产负债表', '短期存款', 18, 110.15),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q3', '2025-09-30', '资产负债表', '流动资产合计', 19, 299.17),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q3', '2025-09-30', '资产负债表', '总资产', 20, 1048.66),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q3', '2025-09-30', '资产负债表', '应付帐款', 21, 66.19),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q3', '2025-09-30', '资产负债表', '应付税项', 22, 9.48),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q3', '2025-09-30', '资产负债表', '融资租赁负债(流动)', 23, 1.04),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q3', '2025-09-30', '资产负债表', '递延收入(流动)', 24, 34.08),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q3', '2025-09-30', '资产负债表', '其他应付款及应计费用', 25, 32.69),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q3', '2025-09-30', '资产负债表', '流动负债合计', 27, 143.48),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q3', '2025-09-30', '资产负债表', '净流动资产', 28, 155.69),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q3', '2025-09-30', '资产负债表', '总资产减流动负债', 29, 905.18),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q3', '2025-09-30', '资产负债表', '递延税项负债', 31, 6.79),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q3', '2025-09-30', '资产负债表', '融资租赁负债(非流动)', 32, 2.27),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q3', '2025-09-30', '资产负债表', '递延收入(非流动)', 33, 2.8),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q3', '2025-09-30', '资产负债表', '长期应付款', 34, 3.65),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q3', '2025-09-30', '资产负债表', '应付票据(非流动)', 35, 35.34),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q3', '2025-09-30', '资产负债表', '非流动负债合计', 36, 50.85),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q3', '2025-09-30', '资产负债表', '总负债', 37, 194.33),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q3', '2025-09-30', '资产负债表', '少数股东权益', 38, 26.82),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q3', '2025-09-30', '资产负债表', '净资产', 39, 854.33),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q3', '2025-09-30', '资产负债表', '股本', 40, 0.02),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q3', '2025-09-30', '资产负债表', '保留溢利(累计亏损)', 41, 271.88),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q3', '2025-09-30', '资产负债表', '公积金', 42, 298.95),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q3', '2025-09-30', '资产负债表', '其他储备', 43, 263.3),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q3', '2025-09-30', '资产负债表', '库存股', 44, -6.64),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q3', '2025-09-30', '资产负债表', '股东权益', 45, 827.51),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q3', '2025-09-30', '资产负债表', '总权益', 46, 854.33),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q3', '2025-09-30', '资产负债表', '总权益及非流动负债', 47, 905.18),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q3', '2025-09-30', '资产负债表', '总权益及总负债', 48, 1048.66),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q2', '2025-06-30', '资产负债表', '物业厂房及设备', 1, 9.63),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q2', '2025-06-30', '资产负债表', '无形资产', 2, 30.47),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q2', '2025-06-30', '资产负债表', '商誉', 3, 204.65),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q2', '2025-06-30', '资产负债表', '土地使用权', 4, 23.27),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q2', '2025-06-30', '资产负债表', '递延税项资产', 5, 4.31),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q2', '2025-06-30', '资产负债表', '预付款项', 6, 2.63),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q2', '2025-06-30', '资产负债表', '其他投资', 7, 21.67),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q2', '2025-06-30', '资产负债表', '指定以公允价值记账之金融资产', 8, 342.54),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q2', '2025-06-30', '资产负债表', '中长期存款', 9, 127.69),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q2', '2025-06-30', '资产负债表', '非流动资产其他项目', 10, 3.1),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q2', '2025-06-30', '资产负债表', '非流动资产合计', 11, 769.96),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q2', '2025-06-30', '资产负债表', '存货', 12, 0.32),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q2', '2025-06-30', '资产负债表', '应收帐款', 13, 37.29),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q2', '2025-06-30', '资产负债表', '预付款按金及其他应收款', 14, 49.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q2', '2025-06-30', '资产负债表', '短期投资', 15, 0.5),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q2', '2025-06-30', '资产负债表', '受限制存款及现金', 16, 0.2),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q2', '2025-06-30', '资产负债表', '现金及等价物', 17, 109.99),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q2', '2025-06-30', '资产负债表', '短期存款', 18, 111.47),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q2', '2025-06-30', '资产负债表', '流动资产合计', 19, 308.77),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q2', '2025-06-30', '资产负债表', '总资产', 20, 1078.73),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q2', '2025-06-30', '资产负债表', '应付帐款', 21, 69.56),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q2', '2025-06-30', '资产负债表', '应付票据', 49, 21.47),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q2', '2025-06-30', '资产负债表', '应付税项', 22, 8.51),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q2', '2025-06-30', '资产负债表', '融资租赁负债(流动)', 23, 1.04),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q2', '2025-06-30', '资产负债表', '递延收入(流动)', 24, 34.28),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q2', '2025-06-30', '资产负债表', '其他应付款及应计费用', 25, 30.1),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q2', '2025-06-30', '资产负债表', '流动负债合计', 27, 164.96),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q2', '2025-06-30', '资产负债表', '净流动资产', 28, 143.81),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q2', '2025-06-30', '资产负债表', '总资产减流动负债', 29, 913.77),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q2', '2025-06-30', '资产负债表', '递延税项负债', 31, 6.16),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q2', '2025-06-30', '资产负债表', '融资租赁负债(非流动)', 32, 2.32),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q2', '2025-06-30', '资产负债表', '递延收入(非流动)', 33, 2.5),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q2', '2025-06-30', '资产负债表', '长期应付款', 34, 3.45),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q2', '2025-06-30', '资产负债表', '应付票据(非流动)', 35, 35.59),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q2', '2025-06-30', '资产负债表', '非流动负债合计', 36, 50.02),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q2', '2025-06-30', '资产负债表', '总负债', 37, 214.98),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q2', '2025-06-30', '资产负债表', '少数股东权益', 38, 24.97),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q2', '2025-06-30', '资产负债表', '净资产', 39, 863.75),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q2', '2025-06-30', '资产负债表', '股本', 40, 0.02),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q2', '2025-06-30', '资产负债表', '保留溢利(累计亏损)', 41, 250.36),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q2', '2025-06-30', '资产负债表', '公积金', 42, 294.63),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q2', '2025-06-30', '资产负债表', '其他储备', 43, 303.16),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q2', '2025-06-30', '资产负债表', '库存股', 44, -9.39),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q2', '2025-06-30', '资产负债表', '股东权益', 45, 838.78),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q2', '2025-06-30', '资产负债表', '总权益', 46, 863.75),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q2', '2025-06-30', '资产负债表', '总权益及非流动负债', 47, 913.77),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q2', '2025-06-30', '资产负债表', '总权益及总负债', 48, 1078.73),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q1', '2025-03-31', '资产负债表', '物业厂房及设备', 1, 8.81),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q1', '2025-03-31', '资产负债表', '无形资产', 2, 20.29),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q1', '2025-03-31', '资产负债表', '商誉', 3, 196.48),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q1', '2025-03-31', '资产负债表', '土地使用权', 4, 23.45),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q1', '2025-03-31', '资产负债表', '递延税项资产', 5, 3.93),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q1', '2025-03-31', '资产负债表', '预付款项', 6, 3.12),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q1', '2025-03-31', '资产负债表', '其他投资', 7, 21.75),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q1', '2025-03-31', '资产负债表', '指定以公允价值记账之金融资产', 8, 247.8),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q1', '2025-03-31', '资产负债表', '中长期存款', 9, 110.29),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q1', '2025-03-31', '资产负债表', '非流动资产其他项目', 10, 3.16),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q1', '2025-03-31', '资产负债表', '非流动资产合计', 11, 639.08),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q1', '2025-03-31', '资产负债表', '存货', 12, 0.18),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q1', '2025-03-31', '资产负债表', '应收帐款', 13, 32.01),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q1', '2025-03-31', '资产负债表', '预付款按金及其他应收款', 14, 42.55),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q1', '2025-03-31', '资产负债表', '短期投资', 15, 0.48),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q1', '2025-03-31', '资产负债表', '受限制存款及现金', 16, 0.11),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q1', '2025-03-31', '资产负债表', '现金及等价物', 17, 120.22),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q1', '2025-03-31', '资产负债表', '短期存款', 18, 146.21),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q1', '2025-03-31', '资产负债表', '流动资产合计', 19, 341.76),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q1', '2025-03-31', '资产负债表', '总资产', 20, 980.84),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q1', '2025-03-31', '资产负债表', '应付帐款', 21, 72.96),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q1', '2025-03-31', '资产负债表', '应付票据', 49, 21.52),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q1', '2025-03-31', '资产负债表', '应付税项', 22, 9.11),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q1', '2025-03-31', '资产负债表', '融资租赁负债(流动)', 23, 1.04),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q1', '2025-03-31', '资产负债表', '递延收入(流动)', 24, 33.13),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q1', '2025-03-31', '资产负债表', '其他应付款及应计费用', 25, 48.54),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q1', '2025-03-31', '资产负债表', '流动负债合计', 27, 186.3),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q1', '2025-03-31', '资产负债表', '净流动资产', 28, 155.46),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q1', '2025-03-31', '资产负债表', '总资产减流动负债', 29, 794.54),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q1', '2025-03-31', '资产负债表', '递延税项负债', 31, 2.27),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q1', '2025-03-31', '资产负债表', '融资租赁负债(非流动)', 32, 2.51),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q1', '2025-03-31', '资产负债表', '递延收入(非流动)', 33, 2.09),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q1', '2025-03-31', '资产负债表', '应付票据(非流动)', 35, 35.68),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q1', '2025-03-31', '资产负债表', '非流动负债合计', 36, 42.55),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q1', '2025-03-31', '资产负债表', '总负债', 37, 228.85),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q1', '2025-03-31', '资产负债表', '少数股东权益', 38, 19.62),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q1', '2025-03-31', '资产负债表', '净资产', 39, 751.99),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q1', '2025-03-31', '资产负债表', '股本', 40, 0.02),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q1', '2025-03-31', '资产负债表', '保留溢利(累计亏损)', 41, 226.42),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q1', '2025-03-31', '资产负债表', '公积金', 42, 291.76),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q1', '2025-03-31', '资产负债表', '其他储备', 43, 224.26),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q1', '2025-03-31', '资产负债表', '库存股', 44, -10.09),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q1', '2025-03-31', '资产负债表', '股东权益', 45, 732.37),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q1', '2025-03-31', '资产负债表', '总权益', 46, 751.99),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q1', '2025-03-31', '资产负债表', '总权益及非流动负债', 47, 794.54),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q1', '2025-03-31', '资产负债表', '总权益及总负债', 48, 980.84),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '资产负债表', '物业厂房及设备', 1, 8.03),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '资产负债表', '无形资产', 2, 20.49),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '资产负债表', '商誉', 3, 196.47),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '资产负债表', '土地使用权', 4, 23.64),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '资产负债表', '递延税项资产', 5, 4.22),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '资产负债表', '预付款项', 6, 4.25),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '资产负债表', '其他投资', 7, 49.78),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '资产负债表', '指定以公允价值记账之金融资产', 8, 144.98),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '资产负债表', '中长期存款', 9, 104.19),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '资产负债表', '非流动资产其他项目', 10, 2.95),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '资产负债表', '非流动资产合计', 11, 559.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '资产负债表', '存货', 12, 0.23),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '资产负债表', '应收帐款', 13, 35.08),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '资产负债表', '预付款按金及其他应收款', 14, 37.93),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '资产负债表', '短期投资', 15, 0.46),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '资产负债表', '受限制存款及现金', 16, 0.11),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '资产负债表', '现金及等价物', 17, 131.64),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '资产负债表', '短期存款', 18, 139.99),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '资产负债表', '流动资产合计', 19, 345.44),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '资产负债表', '总资产', 20, 904.44),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '资产负债表', '应付帐款', 21, 68.79),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '资产负债表', '应付票据', 49, 21.54),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '资产负债表', '应付税项', 22, 9.34),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '资产负债表', '融资租赁负债(流动)', 23, 1.06),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '资产负债表', '递延收入(流动)', 24, 30.96),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '资产负债表', '其他应付款及应计费用', 25, 33.81),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '资产负债表', '流动负债合计', 27, 165.5),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '资产负债表', '净流动资产', 28, 179.94),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '资产负债表', '总资产减流动负债', 29, 738.94),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '资产负债表', '递延税项负债', 31, 1.98),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '资产负债表', '融资租赁负债(非流动)', 32, 2.19),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '资产负债表', '递延收入(非流动)', 33, 1.79),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '资产负债表', '应付票据(非流动)', 35, 35.72),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '资产负债表', '非流动负债合计', 36, 41.68),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '资产负债表', '总负债', 37, 207.18),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '资产负债表', '少数股东权益', 38, 18.63),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '资产负债表', '净资产', 39, 697.26),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '资产负债表', '股本', 40, 0.02),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '资产负债表', '保留溢利(累计亏损)', 41, 200.51),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '资产负债表', '公积金', 42, 290.35),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '资产负债表', '其他储备', 43, 193.25),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '资产负债表', '库存股', 44, -5.5),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '资产负债表', '股东权益', 45, 678.63),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '资产负债表', '总权益', 46, 697.26),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '资产负债表', '总权益及非流动负债', 47, 738.94),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '资产负债表', '总权益及总负债', 48, 904.44),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q3', '2024-09-30', '资产负债表', '物业厂房及设备', 1, 7.04),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q3', '2024-09-30', '资产负债表', '无形资产', 2, 19.96),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q3', '2024-09-30', '资产负债表', '商誉', 3, 196.47),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q3', '2024-09-30', '资产负债表', '土地使用权', 4, 23.82),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q3', '2024-09-30', '资产负债表', '递延税项资产', 5, 3.88),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q3', '2024-09-30', '资产负债表', '预付款项', 6, 4.54),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q3', '2024-09-30', '资产负债表', '其他投资', 7, 48.98),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q3', '2024-09-30', '资产负债表', '指定以公允价值记账之金融资产', 8, 117.77),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q3', '2024-09-30', '资产负债表', '中长期存款', 9, 75.29),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q3', '2024-09-30', '资产负债表', '非流动资产其他项目', 10, 3.12),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q3', '2024-09-30', '资产负债表', '非流动资产合计', 11, 500.87),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q3', '2024-09-30', '资产负债表', '存货', 12, 0.18),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q3', '2024-09-30', '资产负债表', '应收帐款', 13, 29.35),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q3', '2024-09-30', '资产负债表', '预付款按金及其他应收款', 14, 30.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q3', '2024-09-30', '资产负债表', '短期投资', 15, 0.48),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q3', '2024-09-30', '资产负债表', '受限制存款及现金', 16, 0.1),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q3', '2024-09-30', '资产负债表', '现金及等价物', 17, 102.09),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q3', '2024-09-30', '资产负债表', '短期存款', 18, 183.06),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q3', '2024-09-30', '资产负债表', '流动资产合计', 19, 345.26),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q3', '2024-09-30', '资产负债表', '总资产', 20, 846.13),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q3', '2024-09-30', '资产负债表', '应付帐款', 21, 65.23),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q3', '2024-09-30', '资产负债表', '应付票据', 49, 20.99),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q3', '2024-09-30', '资产负债表', '应付税项', 22, 8.23),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q3', '2024-09-30', '资产负债表', '融资租赁负债(流动)', 23, 1.09),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q3', '2024-09-30', '资产负债表', '递延收入(流动)', 24, 29.31),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q3', '2024-09-30', '资产负债表', '其他应付款及应计费用', 25, 27.86),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q3', '2024-09-30', '资产负债表', '流动负债合计', 27, 152.71),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q3', '2024-09-30', '资产负债表', '净流动资产', 28, 192.55),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q3', '2024-09-30', '资产负债表', '总资产减流动负债', 29, 693.42),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q3', '2024-09-30', '资产负债表', '递延税项负债', 31, 2.34),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q3', '2024-09-30', '资产负债表', '融资租赁负债(非流动)', 32, 2.35),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q3', '2024-09-30', '资产负债表', '递延收入(非流动)', 33, 1.63),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q3', '2024-09-30', '资产负债表', '应付票据(非流动)', 35, 34.81),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q3', '2024-09-30', '资产负债表', '非流动负债合计', 36, 41.13),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q3', '2024-09-30', '资产负债表', '总负债', 37, 193.84),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q3', '2024-09-30', '资产负债表', '少数股东权益', 38, 17.44),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q3', '2024-09-30', '资产负债表', '净资产', 39, 652.29),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q3', '2024-09-30', '资产负债表', '股本', 40, 0.02),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q3', '2024-09-30', '资产负债表', '保留溢利(累计亏损)', 41, 181.06),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q3', '2024-09-30', '资产负债表', '公积金', 42, 367.02),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q3', '2024-09-30', '资产负债表', '其他储备', 43, 162.13),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q3', '2024-09-30', '资产负债表', '库存股', 44, -75.38),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q3', '2024-09-30', '资产负债表', '股东权益', 45, 634.85),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q3', '2024-09-30', '资产负债表', '总权益', 46, 652.29),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q3', '2024-09-30', '资产负债表', '总权益及非流动负债', 47, 693.42),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q3', '2024-09-30', '资产负债表', '总权益及总负债', 48, 846.13),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q2', '2024-06-30', '资产负债表', '物业厂房及设备', 1, 5.91),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q2', '2024-06-30', '资产负债表', '无形资产', 2, 20.34),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q2', '2024-06-30', '资产负债表', '商誉', 3, 196.46),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q2', '2024-06-30', '资产负债表', '土地使用权', 4, 24.01),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q2', '2024-06-30', '资产负债表', '递延税项资产', 5, 3.69),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q2', '2024-06-30', '资产负债表', '预付款项', 6, 4.19),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q2', '2024-06-30', '资产负债表', '其他投资', 7, 50.24),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q2', '2024-06-30', '资产负债表', '指定以公允价值记账之金融资产', 8, 102.94),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q2', '2024-06-30', '资产负债表', '中长期存款', 9, 105.29),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q2', '2024-06-30', '资产负债表', '非流动资产其他项目', 10, 3.08),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q2', '2024-06-30', '资产负债表', '非流动资产合计', 11, 516.15),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q2', '2024-06-30', '资产负债表', '存货', 12, 0.14),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q2', '2024-06-30', '资产负债表', '应收帐款', 13, 30.24),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q2', '2024-06-30', '资产负债表', '预付款按金及其他应收款', 14, 31.98),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q2', '2024-06-30', '资产负债表', '短期投资', 15, 10.43),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q2', '2024-06-30', '资产负债表', '受限制存款及现金', 16, 0.07),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q2', '2024-06-30', '资产负债表', '现金及等价物', 17, 122.51),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q2', '2024-06-30', '资产负债表', '短期存款', 18, 112.53),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q2', '2024-06-30', '资产负债表', '流动资产合计', 19, 307.9),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q2', '2024-06-30', '资产负债表', '总资产', 20, 824.05),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q2', '2024-06-30', '资产负债表', '应付帐款', 21, 62.18),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q2', '2024-06-30', '资产负债表', '应付税项', 22, 6.96),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q2', '2024-06-30', '资产负债表', '融资租赁负债(流动)', 23, 1.12),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q2', '2024-06-30', '资产负债表', '递延收入(流动)', 24, 29.52),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q2', '2024-06-30', '资产负债表', '其他应付款及应计费用', 25, 32.01),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q2', '2024-06-30', '资产负债表', '流动负债合计', 27, 131.79),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q2', '2024-06-30', '资产负债表', '净流动资产', 28, 176.11),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q2', '2024-06-30', '资产负债表', '总资产减流动负债', 29, 692.26),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q2', '2024-06-30', '资产负债表', '递延税项负债', 31, 2.67),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q2', '2024-06-30', '资产负债表', '融资租赁负债(非流动)', 32, 2.43),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q2', '2024-06-30', '资产负债表', '递延收入(非流动)', 33, 1.63),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q2', '2024-06-30', '资产负债表', '应付票据(非流动)', 35, 56.74),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q2', '2024-06-30', '资产负债表', '非流动负债合计', 36, 63.47),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q2', '2024-06-30', '资产负债表', '总负债', 37, 195.26),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q2', '2024-06-30', '资产负债表', '少数股东权益', 38, 16.7),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q2', '2024-06-30', '资产负债表', '净资产', 39, 628.79),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q2', '2024-06-30', '资产负债表', '股本', 40, 0.02),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q2', '2024-06-30', '资产负债表', '保留溢利(累计亏损)', 41, 165.2),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q2', '2024-06-30', '资产负债表', '公积金', 42, 366.43),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q2', '2024-06-30', '资产负债表', '其他储备', 43, 151.11),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q2', '2024-06-30', '资产负债表', '库存股', 44, -70.67),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q2', '2024-06-30', '资产负债表', '股东权益', 45, 612.09),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q2', '2024-06-30', '资产负债表', '总权益', 46, 628.79),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q2', '2024-06-30', '资产负债表', '总权益及非流动负债', 47, 692.26),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q2', '2024-06-30', '资产负债表', '总权益及总负债', 48, 824.05),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q1', '2024-03-31', '资产负债表', '物业厂房及设备', 1, 5.26),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q1', '2024-03-31', '资产负债表', '无形资产', 2, 20.23),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q1', '2024-03-31', '资产负债表', '商誉', 3, 195.67),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q1', '2024-03-31', '资产负债表', '土地使用权', 4, 24.19),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q1', '2024-03-31', '资产负债表', '递延税项资产', 5, 3.6),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q1', '2024-03-31', '资产负债表', '预付款项', 6, 4.37),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q1', '2024-03-31', '资产负债表', '其他投资', 7, 46.04),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q1', '2024-03-31', '资产负债表', '指定以公允价值记账之金融资产', 8, 87.91),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q1', '2024-03-31', '资产负债表', '中长期存款', 9, 75.89),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q1', '2024-03-31', '资产负债表', '非流动资产其他项目', 10, 3.17),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q1', '2024-03-31', '资产负债表', '非流动资产合计', 11, 466.33),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q1', '2024-03-31', '资产负债表', '存货', 12, 0.11),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q1', '2024-03-31', '资产负债表', '应收帐款', 13, 28.08),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q1', '2024-03-31', '资产负债表', '预付款按金及其他应收款', 14, 30.68),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q1', '2024-03-31', '资产负债表', '短期投资', 15, 0.37),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q1', '2024-03-31', '资产负债表', '受限制存款及现金', 16, 0.31),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q1', '2024-03-31', '资产负债表', '现金及等价物', 17, 102.18),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q1', '2024-03-31', '资产负债表', '短期存款', 18, 163.7),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q1', '2024-03-31', '资产负债表', '流动资产合计', 19, 325.43),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q1', '2024-03-31', '资产负债表', '总资产', 20, 791.76),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q1', '2024-03-31', '资产负债表', '应付帐款', 21, 54.93),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q1', '2024-03-31', '资产负债表', '应付税项', 22, 6.7),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q1', '2024-03-31', '资产负债表', '融资租赁负债(流动)', 23, 0.97),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q1', '2024-03-31', '资产负债表', '递延收入(流动)', 24, 29.91),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q1', '2024-03-31', '资产负债表', '其他应付款及应计费用', 25, 29.36),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q1', '2024-03-31', '资产负债表', '流动负债合计', 27, 121.87),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q1', '2024-03-31', '资产负债表', '净流动资产', 28, 203.56),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q1', '2024-03-31', '资产负债表', '总资产减流动负债', 29, 669.89),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q1', '2024-03-31', '资产负债表', '递延税项负债', 31, 1.74),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q1', '2024-03-31', '资产负债表', '融资租赁负债(非流动)', 32, 2.57),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q1', '2024-03-31', '资产负债表', '递延收入(非流动)', 33, 1.56),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q1', '2024-03-31', '资产负债表', '应付票据(非流动)', 35, 56.47),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q1', '2024-03-31', '资产负债表', '非流动负债合计', 36, 62.34),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q1', '2024-03-31', '资产负债表', '总负债', 37, 184.21),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q1', '2024-03-31', '资产负债表', '少数股东权益', 38, 14.39),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q1', '2024-03-31', '资产负债表', '净资产', 39, 607.55),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q1', '2024-03-31', '资产负债表', '股本', 40, 0.02),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q1', '2024-03-31', '资产负债表', '保留溢利(累计亏损)', 41, 183.91),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q1', '2024-03-31', '资产负债表', '公积金', 42, 365.59),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q1', '2024-03-31', '资产负债表', '其他储备', 43, 115.6),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q1', '2024-03-31', '资产负债表', '库存股', 44, -71.96),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q1', '2024-03-31', '资产负债表', '股东权益', 45, 593.16),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q1', '2024-03-31', '资产负债表', '总权益', 46, 607.55),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q1', '2024-03-31', '资产负债表', '总权益及非流动负债', 47, 669.89),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q1', '2024-03-31', '资产负债表', '总权益及总负债', 48, 791.76),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '资产负债表', '物业厂房及设备', 1, 4.9),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '资产负债表', '无形资产', 2, 20.32),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '资产负债表', '商誉', 3, 195.42),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '资产负债表', '土地使用权', 4, 24.37),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '资产负债表', '递延税项资产', 5, 3.52),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '资产负债表', '预付款项', 6, 5.4),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '资产负债表', '其他投资', 7, 45.81),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '资产负债表', '指定以公允价值记账之金融资产', 8, 65.4),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '资产负债表', '中长期存款', 9, 87.19),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '资产负债表', '非流动资产其他项目', 10, 3.67),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '资产负债表', '非流动资产合计', 11, 456.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '资产负债表', '存货', 12, 0.08),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '资产负债表', '应收帐款', 13, 29.18),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '资产负债表', '预付款按金及其他应收款', 14, 34.38),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '资产负债表', '短期投资', 15, 0.37),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '资产负债表', '受限制存款及现金', 16, 0.31),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '资产负债表', '现金及等价物', 17, 135.67),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '资产负债表', '短期存款', 18, 99.37),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '资产负债表', '流动资产合计', 19, 299.36),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '资产负债表', '总资产', 20, 755.36),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '资产负债表', '应付帐款', 21, 50.06),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '资产负债表', '应付税项', 22, 5.67),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '资产负债表', '融资租赁负债(流动)', 23, 1.15),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '资产负债表', '递延收入(流动)', 24, 28.54),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '资产负债表', '其他应付款及应计费用', 25, 34.72),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '资产负债表', '流动负债合计', 27, 120.14),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '资产负债表', '净流动资产', 28, 179.22),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '资产负债表', '总资产减流动负债', 29, 635.22),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '资产负债表', '递延税项负债', 31, 2.39),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '资产负债表', '融资租赁负债(非流动)', 32, 2.97),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '资产负债表', '递延收入(非流动)', 33, 1.48),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '资产负债表', '应付票据(非流动)', 35, 56.36),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '资产负债表', '非流动负债合计', 36, 63.2),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '资产负债表', '总负债', 37, 183.34),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '资产负债表', '少数股东权益', 38, 12.95),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '资产负债表', '净资产', 39, 572.02),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '资产负债表', '股本', 40, 0.02),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '资产负债表', '保留溢利(累计亏损)', 41, 169.69),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '资产负债表', '公积金', 42, 365.76),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '资产负债表', '其他储备', 43, 93.56),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '资产负债表', '库存股', 44, -69.96),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '资产负债表', '股东权益', 45, 559.07),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '资产负债表', '总权益', 46, 572.02),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '资产负债表', '总权益及非流动负债', 47, 635.22),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '资产负债表', '总权益及总负债', 48, 755.36),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q3', '2023-09-30', '资产负债表', '物业厂房及设备', 1, 4.36),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q3', '2023-09-30', '资产负债表', '无形资产', 2, 21.36),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q3', '2023-09-30', '资产负债表', '商誉', 3, 195.42),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q3', '2023-09-30', '资产负债表', '土地使用权', 4, 24.56),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q3', '2023-09-30', '资产负债表', '递延税项资产', 5, 3.75),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q3', '2023-09-30', '资产负债表', '预付款项', 6, 5.8),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q3', '2023-09-30', '资产负债表', '其他投资', 7, 46.91),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q3', '2023-09-30', '资产负债表', '中长期存款', 9, 87.69),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q3', '2023-09-30', '资产负债表', '非流动资产其他项目', 10, 58.92),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q3', '2023-09-30', '资产负债表', '非流动资产合计', 11, 448.77),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q3', '2023-09-30', '资产负债表', '存货', 12, 0.05),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q3', '2023-09-30', '资产负债表', '应收帐款', 13, 25.02),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q3', '2023-09-30', '资产负债表', '预付款按金及其他应收款', 14, 33.38),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q3', '2023-09-30', '资产负债表', '短期投资', 15, 0.37),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q3', '2023-09-30', '资产负债表', '受限制存款及现金', 16, 0.1),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q3', '2023-09-30', '资产负债表', '现金及等价物', 17, 123.81),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q3', '2023-09-30', '资产负债表', '短期存款', 18, 98.06),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q3', '2023-09-30', '资产负债表', '流动资产合计', 19, 280.79),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q3', '2023-09-30', '资产负债表', '总资产', 20, 729.56),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q3', '2023-09-30', '资产负债表', '应付帐款', 21, 50.5),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q3', '2023-09-30', '资产负债表', '应付税项', 22, 4.91),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q3', '2023-09-30', '资产负债表', '融资租赁负债(流动)', 23, 1.13),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q3', '2023-09-30', '资产负债表', '递延收入(流动)', 24, 25.55),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q3', '2023-09-30', '资产负债表', '其他应付款及应计费用', 25, 32.04),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q3', '2023-09-30', '资产负债表', '流动负债合计', 27, 114.13),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q3', '2023-09-30', '资产负债表', '净流动资产', 28, 166.66),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q3', '2023-09-30', '资产负债表', '总资产减流动负债', 29, 615.43),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q3', '2023-09-30', '资产负债表', '递延税项负债', 31, 2.06),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q3', '2023-09-30', '资产负债表', '融资租赁负债(非流动)', 32, 3.2),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q3', '2023-09-30', '资产负债表', '递延收入(非流动)', 33, 1.37),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q3', '2023-09-30', '资产负债表', '应付票据(非流动)', 35, 57.12),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q3', '2023-09-30', '资产负债表', '非流动负债合计', 36, 63.75),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q3', '2023-09-30', '资产负债表', '总负债', 37, 177.88),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q3', '2023-09-30', '资产负债表', '少数股东权益', 38, 12.34),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q3', '2023-09-30', '资产负债表', '净资产', 39, 551.68),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q3', '2023-09-30', '资产负债表', '股本', 40, 0.02),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q3', '2023-09-30', '资产负债表', '保留溢利(累计亏损)', 41, 156.66),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q3', '2023-09-30', '资产负债表', '公积金', 42, 365.95),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q3', '2023-09-30', '资产负债表', '其他储备', 43, 82.1),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q3', '2023-09-30', '资产负债表', '库存股', 44, -65.39),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q3', '2023-09-30', '资产负债表', '股东权益', 45, 539.34),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q3', '2023-09-30', '资产负债表', '总权益', 46, 551.68),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q3', '2023-09-30', '资产负债表', '总权益及非流动负债', 47, 615.43),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q3', '2023-09-30', '资产负债表', '总权益及总负债', 48, 729.56),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q2', '2023-06-30', '资产负债表', '物业厂房及设备', 1, 4.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q2', '2023-06-30', '资产负债表', '无形资产', 2, 21.95),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q2', '2023-06-30', '资产负债表', '商誉', 3, 195.38),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q2', '2023-06-30', '资产负债表', '土地使用权', 4, 24.44),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q2', '2023-06-30', '资产负债表', '递延税项资产', 5, 3.43),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q2', '2023-06-30', '资产负债表', '预付款项', 6, 6.42),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q2', '2023-06-30', '资产负债表', '其他投资', 7, 48.05),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q2', '2023-06-30', '资产负债表', '指定以公允价值记账之金融资产', 8, 55.92),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q2', '2023-06-30', '资产负债表', '中长期存款', 9, 75.7),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q2', '2023-06-30', '资产负债表', '非流动资产其他项目', 10, 3.34),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q2', '2023-06-30', '资产负债表', '非流动资产合计', 11, 438.63),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q2', '2023-06-30', '资产负债表', '存货', 12, 0.06),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q2', '2023-06-30', '资产负债表', '应收帐款', 13, 24.59),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q2', '2023-06-30', '资产负债表', '预付款按金及其他应收款', 14, 31.4),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q2', '2023-06-30', '资产负债表', '短期投资', 15, 0.37),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q2', '2023-06-30', '资产负债表', '受限制存款及现金', 16, 0.11),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q2', '2023-06-30', '资产负债表', '现金及等价物', 17, 129.5),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q2', '2023-06-30', '资产负债表', '短期存款', 18, 100.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q2', '2023-06-30', '资产负债表', '流动资产合计', 19, 286.03),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q2', '2023-06-30', '资产负债表', '总资产', 20, 724.66),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q2', '2023-06-30', '资产负债表', '应付帐款', 21, 52.17),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q2', '2023-06-30', '资产负债表', '应付税项', 22, 4.61),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q2', '2023-06-30', '资产负债表', '融资租赁负债(流动)', 23, 1.22),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q2', '2023-06-30', '资产负债表', '递延收入(流动)', 24, 24.26),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q2', '2023-06-30', '资产负债表', '其他应付款及应计费用', 25, 32.15),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q2', '2023-06-30', '资产负债表', '流动负债合计', 27, 114.41),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q2', '2023-06-30', '资产负债表', '净流动资产', 28, 171.62),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q2', '2023-06-30', '资产负债表', '总资产减流动负债', 29, 610.25),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q2', '2023-06-30', '资产负债表', '递延税项负债', 31, 1.47),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q2', '2023-06-30', '资产负债表', '融资租赁负债(非流动)', 32, 2.54),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q2', '2023-06-30', '资产负债表', '递延收入(非流动)', 33, 1.65),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q2', '2023-06-30', '资产负债表', '应付票据(非流动)', 35, 57.47),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q2', '2023-06-30', '资产负债表', '非流动负债合计', 36, 63.13),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q2', '2023-06-30', '资产负债表', '总负债', 37, 177.54),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q2', '2023-06-30', '资产负债表', '少数股东权益', 38, 11.35),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q2', '2023-06-30', '资产负债表', '净资产', 39, 547.12),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q2', '2023-06-30', '资产负债表', '股本', 40, 0.02),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q2', '2023-06-30', '资产负债表', '保留溢利(累计亏损)', 41, 144.98),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q2', '2023-06-30', '资产负债表', '公积金', 42, 365.28),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q2', '2023-06-30', '资产负债表', '其他储备', 43, 85.4),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q2', '2023-06-30', '资产负债表', '库存股', 44, -59.91),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q2', '2023-06-30', '资产负债表', '股东权益', 45, 535.77),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q2', '2023-06-30', '资产负债表', '总权益', 46, 547.12),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q2', '2023-06-30', '资产负债表', '总权益及非流动负债', 47, 610.25),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q2', '2023-06-30', '资产负债表', '总权益及总负债', 48, 724.66),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q1', '2023-03-31', '资产负债表', '物业厂房及设备', 1, 3.4),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q1', '2023-03-31', '资产负债表', '无形资产', 2, 22.89),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q1', '2023-03-31', '资产负债表', '商誉', 3, 195.38),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q1', '2023-03-31', '资产负债表', '土地使用权', 4, 24.62),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q1', '2023-03-31', '资产负债表', '递延税项资产', 5, 3.52),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q1', '2023-03-31', '资产负债表', '预付款项', 6, 5.99),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q1', '2023-03-31', '资产负债表', '其他投资', 7, 45.92),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q1', '2023-03-31', '资产负债表', '指定以公允价值记账之金融资产', 8, 46.94),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q1', '2023-03-31', '资产负债表', '中长期存款', 9, 80.4),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q1', '2023-03-31', '资产负债表', '非流动资产其他项目', 10, 3.62),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q1', '2023-03-31', '资产负债表', '非流动资产合计', 11, 432.68),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q1', '2023-03-31', '资产负债表', '存货', 12, 0.12),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q1', '2023-03-31', '资产负债表', '应收帐款', 13, 27.22),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q1', '2023-03-31', '资产负债表', '预付款按金及其他应收款', 14, 25.79),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q1', '2023-03-31', '资产负债表', '短期投资', 15, 0.37),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q1', '2023-03-31', '资产负债表', '受限制存款及现金', 16, 0.41),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q1', '2023-03-31', '资产负债表', '现金及等价物', 17, 121.29),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q1', '2023-03-31', '资产负债表', '短期存款', 18, 83.25),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q1', '2023-03-31', '资产负债表', '流动资产合计', 19, 258.45),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q1', '2023-03-31', '资产负债表', '总资产', 20, 691.13),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q1', '2023-03-31', '资产负债表', '应付帐款', 21, 53.2),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q1', '2023-03-31', '资产负债表', '应付税项', 22, 4.14),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q1', '2023-03-31', '资产负债表', '融资租赁负债(流动)', 23, 1.15),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q1', '2023-03-31', '资产负债表', '递延收入(流动)', 24, 23.34),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q1', '2023-03-31', '资产负债表', '其他应付款及应计费用', 25, 27.97),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q1', '2023-03-31', '资产负债表', '流动负债合计', 27, 109.8),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q1', '2023-03-31', '资产负债表', '净流动资产', 28, 148.65),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q1', '2023-03-31', '资产负债表', '总资产减流动负债', 29, 581.33),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q1', '2023-03-31', '资产负债表', '递延税项负债', 31, 1.93),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q1', '2023-03-31', '资产负债表', '融资租赁负债(非流动)', 32, 2.84),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q1', '2023-03-31', '资产负债表', '递延收入(非流动)', 33, 1.29),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q1', '2023-03-31', '资产负债表', '长期应付款', 34, 0.01),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q1', '2023-03-31', '资产负债表', '应付票据(非流动)', 35, 54.63),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q1', '2023-03-31', '资产负债表', '非流动负债合计', 36, 60.7),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q1', '2023-03-31', '资产负债表', '总负债', 37, 170.5),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q1', '2023-03-31', '资产负债表', '少数股东权益', 38, 10.83),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q1', '2023-03-31', '资产负债表', '净资产', 39, 520.63),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q1', '2023-03-31', '资产负债表', '股本', 40, 0.02),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q1', '2023-03-31', '资产负债表', '保留溢利(累计亏损)', 41, 132.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q1', '2023-03-31', '资产负债表', '公积金', 42, 364.47),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q1', '2023-03-31', '资产负债表', '其他储备', 43, 74.19),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q1', '2023-03-31', '资产负债表', '库存股', 44, -60.88),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q1', '2023-03-31', '资产负债表', '股东权益', 45, 509.8),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q1', '2023-03-31', '资产负债表', '总权益', 46, 520.63),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q1', '2023-03-31', '资产负债表', '总权益及非流动负债', 47, 581.33),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q1', '2023-03-31', '资产负债表', '总权益及总负债', 48, 691.13),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '资产负债表', '物业厂房及设备', 1, 3.23),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '资产负债表', '无形资产', 2, 23.68),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '资产负债表', '商誉', 3, 194.93),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '资产负债表', '土地使用权', 4, 24.8),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '资产负债表', '递延税项资产', 5, 3.47),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '资产负债表', '预付款项', 6, 7.09),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '资产负债表', '其他投资', 7, 46.34),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '资产负债表', '指定以公允价值记账之金融资产', 8, 31.68),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '资产负债表', '中长期存款', 9, 65.3),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '资产负债表', '非流动资产其他项目', 10, 3.98),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '资产负债表', '非流动资产合计', 11, 404.5),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '资产负债表', '存货', 12, 0.14),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '资产负债表', '应收帐款', 13, 26.7),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '资产负债表', '预付款按金及其他应收款', 14, 29.58),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '资产负债表', '短期投资', 15, 0.37),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '资产负债表', '受限制存款及现金', 16, 0.34),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '资产负债表', '现金及等价物', 17, 95.55),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '资产负债表', '短期存款', 18, 112.91),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '资产负债表', '流动资产合计', 19, 265.59),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '资产负债表', '总资产', 20, 670.09),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '资产负债表', '应付帐款', 21, 49.98),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '资产负债表', '应付税项', 22, 4.04),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '资产负债表', '融资租赁负债(流动)', 23, 1.23),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '资产负债表', '递延收入(流动)', 24, 21.7),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '资产负债表', '其他应付款及应计费用', 25, 40.22),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '资产负债表', '流动负债合计', 27, 117.17),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '资产负债表', '净流动资产', 28, 148.42),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '资产负债表', '总资产减流动负债', 29, 552.92),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '资产负债表', '递延税项负债', 31, 2.11),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '资产负债表', '融资租赁负债(非流动)', 32, 3.06),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '资产负债表', '递延收入(非流动)', 33, 1.06),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '资产负债表', '长期应付款', 34, 0.06),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '资产负债表', '应付票据(非流动)', 35, 55.36),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '资产负债表', '非流动负债合计', 36, 61.65),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '资产负债表', '总负债', 37, 178.82),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '资产负债表', '少数股东权益', 38, 10.28),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '资产负债表', '净资产', 39, 491.27),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '资产负债表', '股本', 40, 0.02),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '资产负债表', '保留溢利(累计亏损)', 41, 120.52),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '资产负债表', '公积金', 42, 364.56),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '资产负债表', '其他储备', 43, 59.38),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '资产负债表', '库存股', 44, -63.49),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '资产负债表', '股东权益', 45, 480.99),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '资产负债表', '总权益', 46, 491.27),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '资产负债表', '总权益及非流动负债', 47, 552.92),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '资产负债表', '总权益及总负债', 48, 670.09),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q3', '2022-09-30', '资产负债表', '物业厂房及设备', 1, 2.89),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q3', '2022-09-30', '资产负债表', '无形资产', 2, 24.91),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q3', '2022-09-30', '资产负债表', '商誉', 3, 194.93),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q3', '2022-09-30', '资产负债表', '土地使用权', 4, 24.99),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q3', '2022-09-30', '资产负债表', '递延税项资产', 5, 3.92),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q3', '2022-09-30', '资产负债表', '预付款项', 6, 6.59),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q3', '2022-09-30', '资产负债表', '其他投资', 7, 46.85),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q3', '2022-09-30', '资产负债表', '指定以公允价值记账之金融资产', 8, 31.72),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q3', '2022-09-30', '资产负债表', '中长期存款', 9, 65.7),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q3', '2022-09-30', '资产负债表', '非流动资产其他项目', 10, 4.35),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q3', '2022-09-30', '资产负债表', '非流动资产合计', 11, 406.85),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q3', '2022-09-30', '资产负债表', '存货', 12, 0.2),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q3', '2022-09-30', '资产负债表', '应收帐款', 13, 29.16),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q3', '2022-09-30', '资产负债表', '预付款按金及其他应收款', 14, 42.21),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q3', '2022-09-30', '资产负债表', '短期投资', 15, 0.37),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q3', '2022-09-30', '资产负债表', '现金及等价物', 17, 85.82),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q3', '2022-09-30', '资产负债表', '短期存款', 18, 102.94),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q3', '2022-09-30', '资产负债表', '流动资产合计', 19, 260.7),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q3', '2022-09-30', '资产负债表', '总资产', 20, 667.55),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q3', '2022-09-30', '资产负债表', '应付帐款', 21, 48.38),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q3', '2022-09-30', '资产负债表', '应付税项', 22, 4.76),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q3', '2022-09-30', '资产负债表', '融资租赁负债(流动)', 23, 0.99),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q3', '2022-09-30', '资产负债表', '递延收入(流动)', 24, 22.35),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q3', '2022-09-30', '资产负债表', '其他应付款及应计费用', 25, 44.9),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q3', '2022-09-30', '资产负债表', '流动负债合计', 27, 121.38),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q3', '2022-09-30', '资产负债表', '净流动资产', 28, 139.32),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q3', '2022-09-30', '资产负债表', '总资产减流动负债', 29, 546.17),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q3', '2022-09-30', '资产负债表', '递延税项负债', 31, 2.19),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q3', '2022-09-30', '资产负债表', '融资租赁负债(非流动)', 32, 3.49),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q3', '2022-09-30', '资产负债表', '递延收入(非流动)', 33, 1.08),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q3', '2022-09-30', '资产负债表', '长期应付款', 34, 0.06),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q3', '2022-09-30', '资产负债表', '应付票据(非流动)', 35, 56.41),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q3', '2022-09-30', '资产负债表', '非流动负债合计', 36, 63.23),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q3', '2022-09-30', '资产负债表', '总负债', 37, 184.61),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q3', '2022-09-30', '资产负债表', '少数股东权益', 38, 10.7),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q3', '2022-09-30', '资产负债表', '净资产', 39, 482.94),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q3', '2022-09-30', '资产负债表', '股本', 40, 0.02),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q3', '2022-09-30', '资产负债表', '保留溢利(累计亏损)', 41, 109.7),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q3', '2022-09-30', '资产负债表', '公积金', 42, 364.93),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q3', '2022-09-30', '资产负债表', '其他储备', 43, 52.04),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q3', '2022-09-30', '资产负债表', '库存股', 44, -54.45),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q3', '2022-09-30', '资产负债表', '股东权益', 45, 472.24),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q3', '2022-09-30', '资产负债表', '总权益', 46, 482.94),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q3', '2022-09-30', '资产负债表', '总权益及非流动负债', 47, 546.17),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q3', '2022-09-30', '资产负债表', '总权益及总负债', 48, 667.55),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q2', '2022-06-30', '资产负债表', '物业厂房及设备', 1, 2.68),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q2', '2022-06-30', '资产负债表', '无形资产', 2, 27.51),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q2', '2022-06-30', '资产负债表', '商誉', 3, 194.93),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q2', '2022-06-30', '资产负债表', '土地使用权', 4, 25.17),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q2', '2022-06-30', '资产负债表', '递延税项资产', 5, 3.99),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q2', '2022-06-30', '资产负债表', '预付款项', 6, 6.22),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q2', '2022-06-30', '资产负债表', '其他投资', 7, 44.02),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q2', '2022-06-30', '资产负债表', '指定以公允价值记账之金融资产', 8, 32.4),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q2', '2022-06-30', '资产负债表', '中长期存款', 9, 44.33),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q2', '2022-06-30', '资产负债表', '非流动资产其他项目', 10, 4.65),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q2', '2022-06-30', '资产负债表', '非流动资产合计', 11, 385.9),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q2', '2022-06-30', '资产负债表', '存货', 12, 0.23),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q2', '2022-06-30', '资产负债表', '应收帐款', 13, 28.98),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q2', '2022-06-30', '资产负债表', '预付款按金及其他应收款', 14, 33.98),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q2', '2022-06-30', '资产负债表', '短期投资', 15, 11.53),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q2', '2022-06-30', '资产负债表', '现金及等价物', 17, 100.44),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q2', '2022-06-30', '资产负债表', '短期存款', 18, 102.02),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q2', '2022-06-30', '资产负债表', '流动资产合计', 19, 277.18),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q2', '2022-06-30', '资产负债表', '总资产', 20, 663.08),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q2', '2022-06-30', '资产负债表', '应付帐款', 21, 57.38),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q2', '2022-06-30', '资产负债表', '应付税项', 22, 3.93),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q2', '2022-06-30', '资产负债表', '融资租赁负债(流动)', 23, 0.88),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q2', '2022-06-30', '资产负债表', '递延收入(流动)', 24, 18.95),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q2', '2022-06-30', '资产负债表', '其他应付款及应计费用', 25, 37.87),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q2', '2022-06-30', '资产负债表', '流动负债合计', 27, 119.01),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q2', '2022-06-30', '资产负债表', '净流动资产', 28, 158.17),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q2', '2022-06-30', '资产负债表', '总资产减流动负债', 29, 544.07),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q2', '2022-06-30', '资产负债表', '递延税项负债', 31, 2.5),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q2', '2022-06-30', '资产负债表', '融资租赁负债(非流动)', 32, 3.78),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q2', '2022-06-30', '资产负债表', '递延收入(非流动)', 33, 1.1),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q2', '2022-06-30', '资产负债表', '长期应付款', 34, 0.62),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q2', '2022-06-30', '资产负债表', '应付票据(非流动)', 35, 53.31),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q2', '2022-06-30', '资产负债表', '非流动负债合计', 36, 61.31),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q2', '2022-06-30', '资产负债表', '总负债', 37, 180.32),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q2', '2022-06-30', '资产负债表', '少数股东权益', 38, 10.38),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q2', '2022-06-30', '资产负债表', '净资产', 39, 482.76),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q2', '2022-06-30', '资产负债表', '股本', 40, 0.02),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q2', '2022-06-30', '资产负债表', '保留溢利(累计亏损)', 41, 156.59),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q2', '2022-06-30', '资产负债表', '公积金', 42, 363.79),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q2', '2022-06-30', '资产负债表', '其他储备', 43, -1.71),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q2', '2022-06-30', '资产负债表', '库存股', 44, -46.31),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q2', '2022-06-30', '资产负债表', '股东权益', 45, 472.38),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q2', '2022-06-30', '资产负债表', '总权益', 46, 482.76),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q2', '2022-06-30', '资产负债表', '总权益及非流动负债', 47, 544.07),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q2', '2022-06-30', '资产负债表', '总权益及总负债', 48, 663.08),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q1', '2022-03-31', '资产负债表', '物业厂房及设备', 1, 2.47),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q1', '2022-03-31', '资产负债表', '无形资产', 2, 26.92),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q1', '2022-03-31', '资产负债表', '商誉', 3, 191.26),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q1', '2022-03-31', '资产负债表', '土地使用权', 4, 25.35),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q1', '2022-03-31', '资产负债表', '递延税项资产', 5, 3.57),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q1', '2022-03-31', '资产负债表', '预付款项', 6, 6.75),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q1', '2022-03-31', '资产负债表', '其他投资', 7, 40.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q1', '2022-03-31', '资产负债表', '指定以公允价值记账之金融资产', 8, 49.04),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q1', '2022-03-31', '资产负债表', '中长期存款', 9, 59.33),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q1', '2022-03-31', '资产负债表', '非流动资产其他项目', 10, 2.68),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q1', '2022-03-31', '资产负债表', '非流动资产合计', 11, 407.37),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q1', '2022-03-31', '资产负债表', '存货', 12, 0.23),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q1', '2022-03-31', '资产负债表', '应收帐款', 13, 25.13),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q1', '2022-03-31', '资产负债表', '预付款按金及其他应收款', 14, 26.9),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q1', '2022-03-31', '资产负债表', '短期投资', 15, 11.25),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q1', '2022-03-31', '资产负债表', '现金及等价物', 17, 83.53),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q1', '2022-03-31', '资产负债表', '短期存款', 18, 105.56),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q1', '2022-03-31', '资产负债表', '流动资产合计', 19, 252.6),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q1', '2022-03-31', '资产负债表', '总资产', 20, 659.97),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q1', '2022-03-31', '资产负债表', '应付帐款', 21, 51.79),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q1', '2022-03-31', '资产负债表', '应付税项', 22, 4.25),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q1', '2022-03-31', '资产负债表', '融资租赁负债(流动)', 23, 0.86),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q1', '2022-03-31', '资产负债表', '递延收入(流动)', 24, 18.72),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q1', '2022-03-31', '资产负债表', '其他应付款及应计费用', 25, 35.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q1', '2022-03-31', '资产负债表', '流动负债合计', 27, 110.62),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q1', '2022-03-31', '资产负债表', '净流动资产', 28, 141.98),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q1', '2022-03-31', '资产负债表', '总资产减流动负债', 29, 549.35),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q1', '2022-03-31', '资产负债表', '递延税项负债', 31, 2.54),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q1', '2022-03-31', '资产负债表', '融资租赁负债(非流动)', 32, 1.99),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q1', '2022-03-31', '资产负债表', '递延收入(非流动)', 33, 1.05),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q1', '2022-03-31', '资产负债表', '长期应付款', 34, 1.15),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q1', '2022-03-31', '资产负债表', '应付票据(非流动)', 35, 50.41),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q1', '2022-03-31', '资产负债表', '非流动负债合计', 36, 57.14),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q1', '2022-03-31', '资产负债表', '总负债', 37, 167.76),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q1', '2022-03-31', '资产负债表', '少数股东权益', 38, 7.89),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q1', '2022-03-31', '资产负债表', '净资产', 39, 492.21),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q1', '2022-03-31', '资产负债表', '股本', 40, 0.02),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q1', '2022-03-31', '资产负债表', '保留溢利(累计亏损)', 41, 148.03),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q1', '2022-03-31', '资产负债表', '公积金', 42, 361.87),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q1', '2022-03-31', '资产负债表', '其他储备', 43, 11.04),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q1', '2022-03-31', '资产负债表', '库存股', 44, -36.64),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q1', '2022-03-31', '资产负债表', '股东权益', 45, 484.32),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q1', '2022-03-31', '资产负债表', '总权益', 46, 492.21),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q1', '2022-03-31', '资产负债表', '总权益及非流动负债', 47, 549.35),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q1', '2022-03-31', '资产负债表', '总权益及总负债', 48, 659.97),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '资产负债表', '物业厂房及设备', 1, 2.43),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '资产负债表', '无形资产', 2, 28.29),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '资产负债表', '商誉', 3, 191.21),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '资产负债表', '土地使用权', 4, 14.95),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '资产负债表', '递延税项资产', 5, 3.46),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '资产负债表', '预付款项', 6, 7.43),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '资产负债表', '其他投资', 7, 37.98),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '资产负债表', '指定以公允价值记账之金融资产', 8, 73.02),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '资产负债表', '中长期存款', 9, 43.03),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '资产负债表', '非流动资产其他项目', 10, 2.83),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '资产负债表', '非流动资产合计', 11, 404.63),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '资产负债表', '存货', 12, 0.24),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '资产负债表', '应收帐款', 13, 36.1),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '资产负债表', '预付款按金及其他应收款', 14, 27.31),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '资产负债表', '短期投资', 15, 10.66),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '资产负债表', '现金及等价物', 17, 65.91),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '资产负债表', '短期存款', 18, 127.69),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '资产负债表', '流动资产合计', 19, 267.91),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '资产负债表', '总资产', 20, 672.54),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '资产负债表', '应付帐款', 21, 43.29),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '资产负债表', '应付税项', 22, 3.63),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '资产负债表', '融资租赁负债(流动)', 23, 0.92),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '资产负债表', '递延收入(流动)', 24, 18.34),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '资产负债表', '其他应付款及应计费用', 25, 38.32),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '资产负债表', '流动负债合计', 27, 104.5),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '资产负债表', '净流动资产', 28, 163.41),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '资产负债表', '总资产减流动负债', 29, 568.04),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '资产负债表', '递延税项负债', 31, 2.71),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '资产负债表', '融资租赁负债(非流动)', 32, 2.05),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '资产负债表', '递延收入(非流动)', 33, 0.86),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '资产负债表', '长期应付款', 34, 1.25),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '资产负债表', '应付票据(非流动)', 35, 50.62),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '资产负债表', '非流动负债合计', 36, 57.49),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '资产负债表', '总负债', 37, 161.99),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '资产负债表', '少数股东权益', 38, 7.38),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '资产负债表', '净资产', 39, 510.55),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '资产负债表', '股本', 40, 0.02),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '资产负债表', '保留溢利(累计亏损)', 41, 141.94),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '资产负债表', '公积金', 42, 362.38),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '资产负债表', '其他储备', 43, 35.43),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '资产负债表', '库存股', 44, -36.6),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '资产负债表', '股东权益', 45, 503.17),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '资产负债表', '总权益', 46, 510.55),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '资产负债表', '总权益及非流动负债', 47, 568.04),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '资产负债表', '总权益及总负债', 48, 672.54),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '资产负债表', '物业厂房及设备', 1, 1.76),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '资产负债表', '无形资产', 2, 20.2),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '资产负债表', '商誉', 3, 174.92),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '资产负债表', '递延税项资产', 5, 3.03),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '资产负债表', '预付款项', 6, 9.56),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '资产负债表', '其他投资', 7, 26.04),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '资产负债表', '指定以公允价值记账之金融资产', 8, 97.71),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '资产负债表', '中长期存款', 9, 29.53),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '资产负债表', '非流动资产其他项目', 10, 3.11),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '资产负债表', '非流动资产合计', 11, 365.86),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '资产负债表', '存货', 12, 0.18),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '资产负债表', '应收帐款', 13, 28.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '资产负债表', '预付款按金及其他应收款', 14, 28.46),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '资产负债表', '短期投资', 15, 0.37),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '资产负债表', '现金及等价物', 17, 111.28),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '资产负债表', '短期存款', 18, 148.58),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '资产负债表', '流动资产合计', 19, 316.87),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '资产负债表', '总资产', 20, 682.73),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '资产负债表', '应付帐款', 21, 35.65),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '资产负债表', '应付税项', 22, 4.45),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '资产负债表', '融资租赁负债(流动)', 23, 1.03),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '资产负债表', '递延收入(流动)', 24, 16.08),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '资产负债表', '其他应付款及应计费用', 25, 38.81),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '资产负债表', '流动负债合计', 27, 96.02),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '资产负债表', '净流动资产', 28, 220.85),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '资产负债表', '总资产减流动负债', 29, 586.71),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '资产负债表', '递延税项负债', 31, 2.65),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '资产负债表', '融资租赁负债(非流动)', 32, 2.18),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '资产负债表', '递延收入(非流动)', 33, 0.78),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '资产负债表', '长期应付款', 34, 2.04),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '资产负债表', '应付票据(非流动)', 35, 51.75),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '资产负债表', '非流动负债合计', 36, 59.4),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '资产负债表', '总负债', 37, 155.42),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '资产负债表', '少数股东权益', 38, 4.86),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '资产负债表', '净资产', 39, 527.31),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '资产负债表', '股本', 40, 0.02),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '资产负债表', '保留溢利(累计亏损)', 41, 111.11),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '资产负债表', '公积金', 42, 350.44),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '资产负债表', '其他储备', 43, 62.22),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '资产负债表', '库存股', 44, -1.34),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '资产负债表', '股东权益', 45, 522.45),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '资产负债表', '总权益', 46, 527.31),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '资产负债表', '总权益及非流动负债', 47, 586.71),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '资产负债表', '总权益及总负债', 48, 682.73),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '资产负债表', '物业厂房及设备', 1, 1.79),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '资产负债表', '无形资产', 2, 16.22),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '资产负债表', '商誉', 3, 171.4),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '资产负债表', '递延税项资产', 5, 1.92),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '资产负债表', '预付款项', 6, 8.16),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '资产负债表', '其他投资', 7, 7.06),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '资产负债表', '指定以公允价值记账之金融资产', 8, 44.61),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '资产负债表', '中长期存款', 9, 5.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '资产负债表', '非流动资产其他项目', 10, 1.48),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '资产负债表', '非流动资产合计', 11, 257.64),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '资产负债表', '存货', 12, 0.26),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '资产负债表', '应收帐款', 13, 21.98),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '资产负债表', '预付款按金及其他应收款', 14, 22.2),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '资产负债表', '短期投资', 15, 0.44),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '资产负债表', '现金及等价物', 17, 154.26),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '资产负债表', '短期存款', 18, 70.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '资产负债表', '流动资产合计', 19, 269.14),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '资产负债表', '总资产', 20, 526.78),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '资产负债表', '应付帐款', 21, 25.59),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '资产负债表', '应付税项', 22, 3.86),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '资产负债表', '融资租赁负债(流动)', 23, 0.69),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '资产负债表', '递延收入(流动)', 24, 16.94),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '资产负债表', '其他应付款及应计费用', 25, 37.82),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '资产负债表', '流动负债合计', 27, 84.9),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '资产负债表', '净流动资产', 28, 184.24),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '资产负债表', '总资产减流动负债', 29, 441.88),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '资产负债表', '递延税项负债', 31, 2.97),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '资产负债表', '融资租赁负债(非流动)', 32, 0.78),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '资产负债表', '递延收入(非流动)', 33, 0.67),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '资产负债表', '长期应付款', 34, 0.68),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '资产负债表', '非流动负债合计', 36, 5.1),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '资产负债表', '总负债', 37, 90.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '资产负债表', '少数股东权益', 38, 0.88),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '资产负债表', '净资产', 39, 436.78),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '资产负债表', '股本', 40, 0.02),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '资产负债表', '保留溢利(累计亏损)', 41, 70.07),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '资产负债表', '公积金', 42, 344.25),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '资产负债表', '其他储备', 43, 21.56),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '资产负债表', '股东权益', 45, 435.9),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '资产负债表', '总权益', 46, 436.78),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '资产负债表', '总权益及非流动负债', 47, 441.88),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '资产负债表', '总权益及总负债', 48, 526.78),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q2', '2026-06-30', '利润表', '营业额', 1, 168.28),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q2', '2026-06-30', '利润表', '营运收入', 2, 168.28),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q2', '2026-06-30', '利润表', '营运支出', 3, 93.33),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q2', '2026-06-30', '利润表', '毛利', 4, 74.95),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q2', '2026-06-30', '利润表', '其他收入', 5, 4.75),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q2', '2026-06-30', '利润表', '其他收益', 6, 2.18),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q2', '2026-06-30', '利润表', '销售及分销费用', 7, 5.07),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q2', '2026-06-30', '利润表', '行政开支', 8, 19.99),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q2', '2026-06-30', '利润表', '经营溢利', 9, 56.82),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q2', '2026-06-30', '利润表', '融资成本', 10, 0.51),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q2', '2026-06-30', '利润表', '应占联营公司溢利', 11, 0.3),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q2', '2026-06-30', '利润表', '除税前溢利', 12, 56.61),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q2', '2026-06-30', '利润表', '税项', 13, 9.71),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q2', '2026-06-30', '利润表', '持续经营业务税后利润', 14, 46.9),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q2', '2026-06-30', '利润表', '除税后溢利', 15, 46.9),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q2', '2026-06-30', '利润表', '少数股东损益', 16, 1.28),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q2', '2026-06-30', '利润表', '股东应占溢利', 17, 45.62),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q2', '2026-06-30', '利润表', '每股基本盈利', 18, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q2', '2026-06-30', '利润表', '每股摊薄盈利', 19, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q2', '2026-06-30', '利润表', '非运算项目', 20, -24.829649),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q1', '2026-03-31', '利润表', '营业额', 1, 78.95),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q1', '2026-03-31', '利润表', '营运收入', 2, 78.95),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q1', '2026-03-31', '利润表', '营运支出', 3, 43.49),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q1', '2026-03-31', '利润表', '毛利', 4, 35.46),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q1', '2026-03-31', '利润表', '其他收入', 5, 2.46),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q1', '2026-03-31', '利润表', '其他收益', 6, 0.66),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q1', '2026-03-31', '利润表', '销售及分销费用', 7, 2.71),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q1', '2026-03-31', '利润表', '行政开支', 8, 9.4),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q1', '2026-03-31', '利润表', '经营溢利', 9, 26.47),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q1', '2026-03-31', '利润表', '融资成本', 10, 0.46),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q1', '2026-03-31', '利润表', '应占联营公司溢利', 11, -0.07),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q1', '2026-03-31', '利润表', '除税前溢利', 12, 25.94),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q1', '2026-03-31', '利润表', '税项', 13, 4.57),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q1', '2026-03-31', '利润表', '持续经营业务税后利润', 14, 21.37),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q1', '2026-03-31', '利润表', '除税后溢利', 15, 21.37),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q1', '2026-03-31', '利润表', '少数股东损益', 16, 0.46),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q1', '2026-03-31', '利润表', '股东应占溢利', 17, 20.91),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q1', '2026-03-31', '利润表', '每股基本盈利', 18, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q1', '2026-03-31', '利润表', '每股摊薄盈利', 19, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q1', '2026-03-31', '利润表', '非运算项目', 20, 37.290653),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '利润表', '营业额', 1, 329.02),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '利润表', '营运收入', 2, 329.02),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '利润表', '营运支出', 3, 183.67),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '利润表', '毛利', 4, 145.35),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '利润表', '其他收入', 5, 10.54),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '利润表', '其他收益', 6, 26.32),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '利润表', '销售及分销费用', 7, 9.41),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '利润表', '行政开支', 8, 39.16),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '利润表', '经营溢利', 9, 133.64),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '利润表', '融资成本', 10, 1.29),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '利润表', '应占联营公司溢利', 11, 0.42),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '利润表', '除税前溢利', 12, 132.77),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '利润表', '税项', 13, 19.24),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '利润表', '持续经营业务税后利润', 14, 113.53),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '利润表', '除税后溢利', 15, 113.53),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '利润表', '少数股东损益', 16, 2.97),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '利润表', '股东应占溢利', 17, 110.56),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '利润表', '每股基本盈利', 18, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '利润表', '每股摊薄盈利', 19, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '利润表', '其他全面收益其他项目', 21, 32.34),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '利润表', '其他全面收益', 22, 32.34),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '利润表', '全面收益总额', 23, 145.87),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '利润表', '非控股权益应占全面收益总额', 24, 2.97),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '利润表', '本公司拥有人应占全面收益总额', 25, 142.9),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '利润表', '非运算项目', 20, -232.24),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q3', '2025-09-30', '利润表', '营业额', 1, 242.61),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q3', '2025-09-30', '利润表', '营运收入', 2, 242.61),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q3', '2025-09-30', '利润表', '营运支出', 3, 135.88),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q3', '2025-09-30', '利润表', '毛利', 4, 106.73),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q3', '2025-09-30', '利润表', '其他收入', 5, 7.96),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q3', '2025-09-30', '利润表', '其他收益', 6, 26.65),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q3', '2025-09-30', '利润表', '销售及分销费用', 7, 6.75),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q3', '2025-09-30', '利润表', '行政开支', 8, 29.35),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q3', '2025-09-30', '利润表', '经营溢利', 9, 105.24),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q3', '2025-09-30', '利润表', '融资成本', 10, 0.69),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q3', '2025-09-30', '利润表', '应占联营公司溢利', 11, 0.5),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q3', '2025-09-30', '利润表', '除税前溢利', 12, 105.05),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q3', '2025-09-30', '利润表', '税项', 13, 14.38),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q3', '2025-09-30', '利润表', '持续经营业务税后利润', 14, 90.67),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q3', '2025-09-30', '利润表', '除税后溢利', 15, 90.67),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q3', '2025-09-30', '利润表', '少数股东损益', 16, 2.14),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q3', '2025-09-30', '利润表', '股东应占溢利', 17, 88.53),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q3', '2025-09-30', '利润表', '每股基本盈利', 18, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q3', '2025-09-30', '利润表', '每股摊薄盈利', 19, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q3', '2025-09-30', '利润表', '非运算项目', 20, -79.4917),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q2', '2025-06-30', '利润表', '营业额', 1, 157.98),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q2', '2025-06-30', '利润表', '营运收入', 2, 157.98),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q2', '2025-06-30', '利润表', '营运支出', 3, 88.07),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q2', '2025-06-30', '利润表', '毛利', 4, 69.91),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q2', '2025-06-30', '利润表', '其他收入', 5, 5.51),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q2', '2025-06-30', '利润表', '其他收益', 6, 25.71),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q2', '2025-06-30', '利润表', '销售及分销费用', 7, 4.15),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q2', '2025-06-30', '利润表', '行政开支', 8, 18.84),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q2', '2025-06-30', '利润表', '经营溢利', 9, 78.14),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q2', '2025-06-30', '利润表', '融资成本', 10, 0.37),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q2', '2025-06-30', '利润表', '应占联营公司溢利', 11, 0.39),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q2', '2025-06-30', '利润表', '除税前溢利', 12, 78.16),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q2', '2025-06-30', '利润表', '税项', 13, 9.61),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q2', '2025-06-30', '利润表', '持续经营业务税后利润', 14, 68.55),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q2', '2025-06-30', '利润表', '除税后溢利', 15, 68.55),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q2', '2025-06-30', '利润表', '少数股东损益', 16, 1.55),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q2', '2025-06-30', '利润表', '股东应占溢利', 17, 67.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q2', '2025-06-30', '利润表', '每股基本盈利', 18, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q2', '2025-06-30', '利润表', '每股摊薄盈利', 19, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q2', '2025-06-30', '利润表', '非运算项目', 20, -18.724511),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q1', '2025-03-31', '利润表', '营业额', 1, 73.56),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q1', '2025-03-31', '利润表', '营运收入', 2, 73.56),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q1', '2025-03-31', '利润表', '营运支出', 3, 41.14),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q1', '2025-03-31', '利润表', '毛利', 4, 32.42),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q1', '2025-03-31', '利润表', '其他收入', 5, 2.97),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q1', '2025-03-31', '利润表', '其他收益', 6, 24.4),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q1', '2025-03-31', '利润表', '销售及分销费用', 7, 1.99),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q1', '2025-03-31', '利润表', '行政开支', 8, 9.44),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q1', '2025-03-31', '利润表', '经营溢利', 9, 48.36),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q1', '2025-03-31', '利润表', '融资成本', 10, 0.25),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q1', '2025-03-31', '利润表', '应占联营公司溢利', 11, 0.23),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q1', '2025-03-31', '利润表', '除税前溢利', 12, 48.34),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q1', '2025-03-31', '利润表', '税项', 13, 4.46),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q1', '2025-03-31', '利润表', '持续经营业务税后利润', 14, 43.88),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q1', '2025-03-31', '利润表', '除税后溢利', 15, 43.88),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q1', '2025-03-31', '利润表', '少数股东损益', 16, 0.97),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q1', '2025-03-31', '利润表', '股东应占溢利', 17, 42.91),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q1', '2025-03-31', '利润表', '每股基本盈利', 18, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q1', '2025-03-31', '利润表', '每股摊薄盈利', 19, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q1', '2025-03-31', '利润表', '非运算项目', 20, 39.642961),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '利润表', '营业额', 1, 284.01),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '利润表', '营运收入', 2, 284.01),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '利润表', '营运支出', 3, 163.76),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '利润表', '毛利', 4, 120.25),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '利润表', '其他收入', 5, 11.96),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '利润表', '其他收益', 6, 1.65),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '利润表', '销售及分销费用', 7, 8.65),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '利润表', '行政开支', 8, 38.11),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '利润表', '经营溢利', 9, 87.1),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '利润表', '融资成本', 10, 0.94),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '利润表', '应占联营公司溢利', 11, 0.96),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '利润表', '除税前溢利', 12, 87.12),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '利润表', '税项', 13, 16.03),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '利润表', '持续经营业务税后利润', 14, 71.09),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '利润表', '除税后溢利', 15, 71.09),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '利润表', '少数股东损益', 16, 4.65),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '利润表', '股东应占溢利', 17, 66.44),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '利润表', '每股基本盈利', 18, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '利润表', '每股摊薄盈利', 19, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '利润表', '其他全面收益其他项目', 21, 80.18),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '利润表', '其他全面收益', 22, 80.18),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '利润表', '全面收益总额', 23, 151.27),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '利润表', '非控股权益应占全面收益总额', 24, 4.65),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '利润表', '本公司拥有人应占全面收益总额', 25, 146.62),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '利润表', '非运算项目', 20, -210.52),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q3', '2024-09-30', '利润表', '营业额', 1, 209.43),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q3', '2024-09-30', '利润表', '营运收入', 2, 209.43),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q3', '2024-09-30', '利润表', '营运支出', 3, 121.71),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q3', '2024-09-30', '利润表', '毛利', 4, 87.72),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q3', '2024-09-30', '利润表', '其他收入', 5, 8.81),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q3', '2024-09-30', '利润表', '其他收益', 6, 1.5),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q3', '2024-09-30', '利润表', '销售及分销费用', 7, 6.17),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q3', '2024-09-30', '利润表', '行政开支', 8, 28.85),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q3', '2024-09-30', '利润表', '经营溢利', 9, 63.01),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q3', '2024-09-30', '利润表', '融资成本', 10, 1.53),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q3', '2024-09-30', '利润表', '应占联营公司溢利', 11, 0.65),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q3', '2024-09-30', '利润表', '除税前溢利', 12, 62.13),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q3', '2024-09-30', '利润表', '税项', 13, 11.8),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q3', '2024-09-30', '利润表', '持续经营业务税后利润', 14, 50.33),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q3', '2024-09-30', '利润表', '除税后溢利', 15, 50.33),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q3', '2024-09-30', '利润表', '少数股东损益', 16, 3.46),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q3', '2024-09-30', '利润表', '股东应占溢利', 17, 46.87),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q3', '2024-09-30', '利润表', '每股基本盈利', 18, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q3', '2024-09-30', '利润表', '每股摊薄盈利', 19, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q3', '2024-09-30', '利润表', '非运算项目', 20, -63.430119),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q2', '2024-06-30', '利润表', '营业额', 1, 139.28),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q2', '2024-06-30', '利润表', '营运收入', 2, 139.28),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q2', '2024-06-30', '利润表', '营运支出', 3, 81.47),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q2', '2024-06-30', '利润表', '毛利', 4, 57.81),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q2', '2024-06-30', '利润表', '其他收入', 5, 5.82),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q2', '2024-06-30', '利润表', '其他收益', 6, 0.78),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q2', '2024-06-30', '利润表', '销售及分销费用', 7, 3.97),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q2', '2024-06-30', '利润表', '行政开支', 8, 18.87),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q2', '2024-06-30', '利润表', '经营溢利', 9, 41.57),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q2', '2024-06-30', '利润表', '融资成本', 10, 0.56),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q2', '2024-06-30', '利润表', '应占联营公司溢利', 11, 0.36),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q2', '2024-06-30', '利润表', '除税前溢利', 12, 41.37),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q2', '2024-06-30', '利润表', '税项', 13, 8.13),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q2', '2024-06-30', '利润表', '持续经营业务税后利润', 14, 33.24),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q2', '2024-06-30', '利润表', '除税后溢利', 15, 33.24),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q2', '2024-06-30', '利润表', '少数股东损益', 16, 2.2),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q2', '2024-06-30', '利润表', '股东应占溢利', 17, 31.04),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q2', '2024-06-30', '利润表', '每股基本盈利', 18, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q2', '2024-06-30', '利润表', '每股摊薄盈利', 19, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q2', '2024-06-30', '利润表', '非运算项目', 20, -11.387386),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q1', '2024-03-31', '利润表', '营业额', 1, 67.68),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q1', '2024-03-31', '利润表', '营运收入', 2, 67.68),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q1', '2024-03-31', '利润表', '营运支出', 3, 39.97),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q1', '2024-03-31', '利润表', '毛利', 4, 27.71),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q1', '2024-03-31', '利润表', '其他收入', 5, 2.78),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q1', '2024-03-31', '利润表', '其他收益', 6, 0.46),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q1', '2024-03-31', '利润表', '销售及分销费用', 7, 1.87),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q1', '2024-03-31', '利润表', '行政开支', 8, 9.49),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q1', '2024-03-31', '利润表', '经营溢利', 9, 19.59),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q1', '2024-03-31', '利润表', '融资成本', 10, 0.3),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q1', '2024-03-31', '利润表', '应占联营公司溢利', 11, -0.18),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q1', '2024-03-31', '利润表', '除税前溢利', 12, 19.11),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q1', '2024-03-31', '利润表', '税项', 13, 3.81),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q1', '2024-03-31', '利润表', '持续经营业务税后利润', 14, 15.3),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q1', '2024-03-31', '利润表', '除税后溢利', 15, 15.3),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q1', '2024-03-31', '利润表', '少数股东损益', 16, 1.08),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q1', '2024-03-31', '利润表', '股东应占溢利', 17, 14.22),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q1', '2024-03-31', '利润表', '每股基本盈利', 18, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q1', '2024-03-31', '利润表', '每股摊薄盈利', 19, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q1', '2024-03-31', '利润表', '非运算项目', 20, 41.748525),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '利润表', '营业额', 1, 277.52),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '利润表', '营运收入', 2, 277.52),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '利润表', '营运支出', 3, 179.57),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '利润表', '毛利', 4, 97.95),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '利润表', '其他收入', 5, 10.52),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '利润表', '其他收益', 6, 2.3),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '利润表', '销售及分销费用', 7, 8.97),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '利润表', '行政开支', 8, 41.21),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '利润表', '经营溢利', 9, 60.59),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '利润表', '融资成本', 10, 1.41),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '利润表', '应占联营公司溢利', 11, 1.27),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '利润表', '除税前溢利', 12, 60.45),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '利润表', '税项', 13, 8.25),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '利润表', '持续经营业务税后利润', 14, 52.2),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '利润表', '除税后溢利', 15, 52.2),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '利润表', '少数股东损益', 16, 3.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '利润表', '股东应占溢利', 17, 49.2),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '利润表', '每股基本盈利', 18, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '利润表', '每股摊薄盈利', 19, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '利润表', '其他全面收益其他项目', 21, 34.67),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '利润表', '其他全面收益', 22, 34.67),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '利润表', '全面收益总额', 23, 86.87),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '利润表', '非控股权益应占全面收益总额', 24, 3.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '利润表', '本公司拥有人应占全面收益总额', 25, 83.87),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '利润表', '非运算项目', 20, -229.75),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q3', '2023-09-30', '利润表', '营业额', 1, 208.59),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q3', '2023-09-30', '利润表', '营运收入', 2, 208.59),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q3', '2023-09-30', '利润表', '营运支出', 3, 137.05),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q3', '2023-09-30', '利润表', '毛利', 4, 71.54),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q3', '2023-09-30', '利润表', '其他收入', 5, 7.75),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q3', '2023-09-30', '利润表', '其他收益', 6, 1.68),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q3', '2023-09-30', '利润表', '销售及分销费用', 7, 6.42),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q3', '2023-09-30', '利润表', '行政开支', 8, 31.1),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q3', '2023-09-30', '利润表', '经营溢利', 9, 43.45),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q3', '2023-09-30', '利润表', '融资成本', 10, 1.11),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q3', '2023-09-30', '利润表', '应占联营公司溢利', 11, 1.07),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q3', '2023-09-30', '利润表', '除税前溢利', 12, 43.41),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q3', '2023-09-30', '利润表', '税项', 13, 5.3),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q3', '2023-09-30', '利润表', '持续经营业务税后利润', 14, 38.11),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q3', '2023-09-30', '利润表', '除税后溢利', 15, 38.11),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q3', '2023-09-30', '利润表', '少数股东损益', 16, 1.97),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q3', '2023-09-30', '利润表', '股东应占溢利', 17, 36.14),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q3', '2023-09-30', '利润表', '每股基本盈利', 18, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q3', '2023-09-30', '利润表', '每股摊薄盈利', 19, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q3', '2023-09-30', '利润表', '非运算项目', 20, 94498322.6),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q2', '2023-06-30', '利润表', '营业额', 1, 142.9),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q2', '2023-06-30', '利润表', '营运收入', 2, 142.9),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q2', '2023-06-30', '利润表', '营运支出', 3, 94.78),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q2', '2023-06-30', '利润表', '毛利', 4, 48.12),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q2', '2023-06-30', '利润表', '其他收入', 5, 5.02),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q2', '2023-06-30', '利润表', '其他收益', 6, 0.9),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q2', '2023-06-30', '利润表', '销售及分销费用', 7, 4.23),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q2', '2023-06-30', '利润表', '行政开支', 8, 20.61),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q2', '2023-06-30', '利润表', '经营溢利', 9, 29.2),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q2', '2023-06-30', '利润表', '融资成本', 10, 0.76),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q2', '2023-06-30', '利润表', '应占联营公司溢利', 11, 0.58),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q2', '2023-06-30', '利润表', '除税前溢利', 12, 29.02),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q2', '2023-06-30', '利润表', '税项', 13, 3.54),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q2', '2023-06-30', '利润表', '持续经营业务税后利润', 14, 25.48),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q2', '2023-06-30', '利润表', '除税后溢利', 15, 25.48),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q2', '2023-06-30', '利润表', '少数股东损益', 16, 1.02),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q2', '2023-06-30', '利润表', '股东应占溢利', 17, 24.46),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q2', '2023-06-30', '利润表', '每股基本盈利', 18, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q2', '2023-06-30', '利润表', '每股摊薄盈利', 19, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q2', '2023-06-30', '利润表', '非运算项目', 20, 94494423.99),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q1', '2023-03-31', '利润表', '营业额', 1, 70.04),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q1', '2023-03-31', '利润表', '营运收入', 2, 70.04),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q1', '2023-03-31', '利润表', '营运支出', 3, 46.89),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q1', '2023-03-31', '利润表', '毛利', 4, 23.15),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q1', '2023-03-31', '利润表', '其他收入', 5, 2.37),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q1', '2023-03-31', '利润表', '其他收益', 6, 0.58),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q1', '2023-03-31', '利润表', '销售及分销费用', 7, 2.12),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q1', '2023-03-31', '利润表', '行政开支', 8, 10.17),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q1', '2023-03-31', '利润表', '经营溢利', 9, 13.81),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q1', '2023-03-31', '利润表', '融资成本', 10, 0.34),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q1', '2023-03-31', '利润表', '应占联营公司溢利', 11, 0.2),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q1', '2023-03-31', '利润表', '除税前溢利', 12, 13.67),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q1', '2023-03-31', '利润表', '税项', 13, 1.67),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q1', '2023-03-31', '利润表', '持续经营业务税后利润', 14, 12.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q1', '2023-03-31', '利润表', '除税后溢利', 15, 12.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q1', '2023-03-31', '利润表', '少数股东损益', 16, 0.52),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q1', '2023-03-31', '利润表', '股东应占溢利', 17, 11.48),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q1', '2023-03-31', '利润表', '每股基本盈利', 18, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q1', '2023-03-31', '利润表', '每股摊薄盈利', 19, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q1', '2023-03-31', '利润表', '非运算项目', 20, 94289839.96),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '利润表', '营业额', 1, 283.39),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '利润表', '营运收入', 2, 283.39),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '利润表', '营运支出', 3, 195.66),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '利润表', '毛利', 4, 87.73),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '利润表', '其他收入', 5, 7.11),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '利润表', '其他收益', 6, 5.16),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '利润表', '销售及分销费用', 7, 11.44),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '利润表', '行政开支', 8, 44.13),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '利润表', '经营溢利', 9, 44.43),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '利润表', '融资成本', 10, 1.08),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '利润表', '应占联营公司溢利', 11, 0.38),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '利润表', '除税前溢利', 12, 43.73),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '利润表', '税项', 13, 5.34),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '利润表', '持续经营业务税后利润', 14, 38.39),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '利润表', '除税后溢利', 15, 38.39),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '利润表', '少数股东损益', 16, 1.62),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '利润表', '股东应占溢利', 17, 36.77),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '利润表', '每股基本盈利', 18, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '利润表', '每股摊薄盈利', 19, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '利润表', '其他全面收益其他项目', 21, -35.26),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '利润表', '其他全面收益', 22, -35.26),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '利润表', '全面收益总额', 23, 3.13),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '利润表', '非控股权益应占全面收益总额', 24, 1.62),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '利润表', '本公司拥有人应占全面收益总额', 25, 1.51),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '利润表', '非运算项目', 20, -251.23),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q3', '2022-09-30', '利润表', '营业额', 1, 209.14),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q3', '2022-09-30', '利润表', '营运收入', 2, 209.14),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q3', '2022-09-30', '利润表', '营运支出', 3, 145.88),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q3', '2022-09-30', '利润表', '毛利', 4, 63.26),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q3', '2022-09-30', '利润表', '其他收入', 5, 4.87),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q3', '2022-09-30', '利润表', '其他收益', 6, 4.38),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q3', '2022-09-30', '利润表', '销售及分销费用', 7, 8.78),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q3', '2022-09-30', '利润表', '行政开支', 8, 33.18),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q3', '2022-09-30', '利润表', '经营溢利', 9, 30.55),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q3', '2022-09-30', '利润表', '融资成本', 10, 0.77),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q3', '2022-09-30', '利润表', '应占联营公司溢利', 11, 0.22),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q3', '2022-09-30', '利润表', '除税前溢利', 12, 30.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q3', '2022-09-30', '利润表', '税项', 13, 3.66),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q3', '2022-09-30', '利润表', '持续经营业务税后利润', 14, 26.34),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q3', '2022-09-30', '利润表', '除税后溢利', 15, 26.34),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q3', '2022-09-30', '利润表', '少数股东损益', 16, 1.08),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q3', '2022-09-30', '利润表', '股东应占溢利', 17, 25.26),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q3', '2022-09-30', '利润表', '每股基本盈利', 18, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q3', '2022-09-30', '利润表', '每股摊薄盈利', 19, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q3', '2022-09-30', '利润表', '非运算项目', 20, 97212741.5),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q2', '2022-06-30', '利润表', '营业额', 1, 135.49),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q2', '2022-06-30', '利润表', '营运收入', 2, 135.49),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q2', '2022-06-30', '利润表', '营运支出', 3, 96.26),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q2', '2022-06-30', '利润表', '毛利', 4, 39.23),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q2', '2022-06-30', '利润表', '其他收入', 5, 3.01),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q2', '2022-06-30', '利润表', '其他收益', 6, 3.29),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q2', '2022-06-30', '利润表', '销售及分销费用', 7, 6.33),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q2', '2022-06-30', '利润表', '行政开支', 8, 21.26),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q2', '2022-06-30', '利润表', '经营溢利', 9, 17.94),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q2', '2022-06-30', '利润表', '融资成本', 10, 0.53),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q2', '2022-06-30', '利润表', '应占联营公司溢利', 11, 0.14),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q2', '2022-06-30', '利润表', '除税前溢利', 12, 17.55),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q2', '2022-06-30', '利润表', '税项', 13, 2.14),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q2', '2022-06-30', '利润表', '持续经营业务税后利润', 14, 15.41),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q2', '2022-06-30', '利润表', '除税后溢利', 15, 15.41),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q2', '2022-06-30', '利润表', '少数股东损益', 16, 0.76),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q2', '2022-06-30', '利润表', '股东应占溢利', 17, 14.65),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q2', '2022-06-30', '利润表', '每股基本盈利', 18, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q2', '2022-06-30', '利润表', '每股摊薄盈利', 19, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q2', '2022-06-30', '利润表', '非运算项目', 20, 97837594.58),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q1', '2022-03-31', '利润表', '营业额', 1, 66.44),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q1', '2022-03-31', '利润表', '营运收入', 2, 66.44),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q1', '2022-03-31', '利润表', '营运支出', 3, 47.84),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q1', '2022-03-31', '利润表', '毛利', 4, 18.6),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q1', '2022-03-31', '利润表', '其他收入', 5, 1.5),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q1', '2022-03-31', '利润表', '其他收益', 6, 0.81),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q1', '2022-03-31', '利润表', '销售及分销费用', 7, 3.3),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q1', '2022-03-31', '利润表', '行政开支', 8, 10.12),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q1', '2022-03-31', '利润表', '经营溢利', 9, 7.49),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q1', '2022-03-31', '利润表', '融资成本', 10, 0.3),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q1', '2022-03-31', '利润表', '应占联营公司溢利', 11, 0.2),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q1', '2022-03-31', '利润表', '除税前溢利', 12, 7.39),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q1', '2022-03-31', '利润表', '税项', 13, 0.9),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q1', '2022-03-31', '利润表', '持续经营业务税后利润', 14, 6.49),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q1', '2022-03-31', '利润表', '除税后溢利', 15, 6.49),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q1', '2022-03-31', '利润表', '少数股东损益', 16, 0.4),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q1', '2022-03-31', '利润表', '股东应占溢利', 17, 6.09),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q1', '2022-03-31', '利润表', '每股基本盈利', 18, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q1', '2022-03-31', '利润表', '每股摊薄盈利', 19, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q1', '2022-03-31', '利润表', '非运算项目', 20, 98631111.11),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '利润表', '营业额', 1, 312.44),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '利润表', '营运收入', 2, 312.44),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '利润表', '营运支出', 3, 218.4),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '利润表', '毛利', 4, 94.04),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '利润表', '其他收入', 5, 5.3),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '利润表', '其他收益', 6, 5.53),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '利润表', '销售及分销费用', 7, 26.78),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '利润表', '行政开支', 8, 40.09),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '利润表', '经营溢利', 9, 38.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '利润表', '融资成本', 10, 1.21),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '利润表', '应占联营公司溢利', 11, -0.47),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '利润表', '除税前溢利', 12, 36.32),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '利润表', '税项', 13, 4.17),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '利润表', '持续经营业务税后利润', 14, 32.15),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '利润表', '除税后溢利', 15, 32.15),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '利润表', '少数股东损益', 16, 1.86),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '利润表', '股东应占溢利', 17, 30.29),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '利润表', '每股基本盈利', 18, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '利润表', '每股摊薄盈利', 19, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '利润表', '其他全面收益其他项目', 21, -25.02),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '利润表', '其他全面收益', 22, -25.02),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '利润表', '全面收益总额', 23, 7.13),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '利润表', '非控股权益应占全面收益总额', 24, 1.86),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '利润表', '本公司拥有人应占全面收益总额', 25, 5.27),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '利润表', '非运算项目', 20, -285.27),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q3', '2021-09-30', '利润表', '营业额', 1, 236.37),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q3', '2021-09-30', '利润表', '营运收入', 2, 236.37),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q3', '2021-09-30', '利润表', '营运支出', 3, 164.25),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q3', '2021-09-30', '利润表', '毛利', 4, 72.12),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q3', '2021-09-30', '利润表', '其他收入', 5, 4.08),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q3', '2021-09-30', '利润表', '其他收益', 6, 3.68),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q3', '2021-09-30', '利润表', '销售及分销费用', 7, 19.28),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q3', '2021-09-30', '利润表', '行政开支', 8, 29.42),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q3', '2021-09-30', '利润表', '经营溢利', 9, 31.18),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q3', '2021-09-30', '利润表', '融资成本', 10, 0.9),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q3', '2021-09-30', '利润表', '应占联营公司溢利', 11, -0.48),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q3', '2021-09-30', '利润表', '除税前溢利', 12, 29.8),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q3', '2021-09-30', '利润表', '税项', 13, 3.42),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q3', '2021-09-30', '利润表', '持续经营业务税后利润', 14, 26.38),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q3', '2021-09-30', '利润表', '除税后溢利', 15, 26.38),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q3', '2021-09-30', '利润表', '少数股东损益', 16, 1.45),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q3', '2021-09-30', '利润表', '股东应占溢利', 17, 24.93),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q3', '2021-09-30', '利润表', '每股基本盈利', 18, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q3', '2021-09-30', '利润表', '每股摊薄盈利', 19, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q3', '2021-09-30', '利润表', '非运算项目', 20, 100749802.7797),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q2', '2021-06-30', '利润表', '营业额', 1, 158.32),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q2', '2021-06-30', '利润表', '营运收入', 2, 158.32),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q2', '2021-06-30', '利润表', '营运支出', 3, 109.29),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q2', '2021-06-30', '利润表', '毛利', 4, 49.03),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q2', '2021-06-30', '利润表', '其他收入', 5, 2.77),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q2', '2021-06-30', '利润表', '其他收益', 6, 2.51),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q2', '2021-06-30', '利润表', '销售及分销费用', 7, 13.41),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q2', '2021-06-30', '利润表', '行政开支', 8, 18.91),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q2', '2021-06-30', '利润表', '经营溢利', 9, 21.99),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q2', '2021-06-30', '利润表', '融资成本', 10, 0.6),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q2', '2021-06-30', '利润表', '应占联营公司溢利', 11, -0.49),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q2', '2021-06-30', '利润表', '除税前溢利', 12, 20.9),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q2', '2021-06-30', '利润表', '税项', 13, 2.4),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q2', '2021-06-30', '利润表', '持续经营业务税后利润', 14, 18.5),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q2', '2021-06-30', '利润表', '除税后溢利', 15, 18.5),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q2', '2021-06-30', '利润表', '少数股东损益', 16, 0.97),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q2', '2021-06-30', '利润表', '股东应占溢利', 17, 17.53),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q2', '2021-06-30', '利润表', '每股基本盈利', 18, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q2', '2021-06-30', '利润表', '每股摊薄盈利', 19, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q2', '2021-06-30', '利润表', '其他全面收益其他项目', 21, -13.19),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q2', '2021-06-30', '利润表', '其他全面收益', 22, -13.19),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q2', '2021-06-30', '利润表', '全面收益总额', 23, 5.31),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q2', '2021-06-30', '利润表', '非控股权益应占全面收益总额', 24, 0.97),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q2', '2021-06-30', '利润表', '本公司拥有人应占全面收益总额', 25, 4.34),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q2', '2021-06-30', '利润表', '非运算项目', 20, -117.8),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q1', '2021-03-31', '利润表', '营业额', 1, 78.24),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q1', '2021-03-31', '利润表', '营运收入', 2, 78.24),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q1', '2021-03-31', '利润表', '营运支出', 3, 53.58),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q1', '2021-03-31', '利润表', '毛利', 4, 24.66),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q1', '2021-03-31', '利润表', '其他收入', 5, 1.54),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q1', '2021-03-31', '利润表', '其他收益', 6, 0.99),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q1', '2021-03-31', '利润表', '销售及分销费用', 7, 6.72),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q1', '2021-03-31', '利润表', '行政开支', 8, 8.83),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q1', '2021-03-31', '利润表', '经营溢利', 9, 11.64),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q1', '2021-03-31', '利润表', '融资成本', 10, 0.31),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q1', '2021-03-31', '利润表', '应占联营公司溢利', 11, -0.27),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q1', '2021-03-31', '利润表', '除税前溢利', 12, 11.06),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q1', '2021-03-31', '利润表', '税项', 13, 1.27),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q1', '2021-03-31', '利润表', '持续经营业务税后利润', 14, 9.79),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q1', '2021-03-31', '利润表', '除税后溢利', 15, 9.79),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q1', '2021-03-31', '利润表', '少数股东损益', 16, 0.53),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q1', '2021-03-31', '利润表', '股东应占溢利', 17, 9.26),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q1', '2021-03-31', '利润表', '每股基本盈利', 18, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q1', '2021-03-31', '利润表', '每股摊薄盈利', 19, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q1', '2021-03-31', '利润表', '其他全面收益其他项目', 21, -12.77),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q1', '2021-03-31', '利润表', '其他全面收益', 22, -12.77),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q1', '2021-03-31', '利润表', '全面收益总额', 23, -2.98),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q1', '2021-03-31', '利润表', '非控股权益应占全面收益总额', 24, 0.53),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q1', '2021-03-31', '利润表', '本公司拥有人应占全面收益总额', 25, -3.51),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q1', '2021-03-31', '利润表', '非运算项目', 20, -62.32),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '利润表', '营业额', 1, 291.53),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '利润表', '营运收入', 2, 291.53),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '利润表', '营运支出', 3, 198.51),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '利润表', '毛利', 4, 93.02),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '利润表', '其他收入', 5, 6.22),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '利润表', '其他收益', 6, 3.62),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '利润表', '销售及分销费用', 7, 24.75),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '利润表', '行政开支', 8, 31.01),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '利润表', '经营溢利', 9, 47.1),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '利润表', '融资成本', 10, 0.97),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '利润表', '应占联营公司溢利', 11, 0.19),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '利润表', '除税前溢利', 12, 46.32),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '利润表', '税项', 13, 4.56),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '利润表', '持续经营业务税后利润', 14, 41.76),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '利润表', '除税后溢利', 15, 41.76),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '利润表', '少数股东损益', 16, 0.21),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '利润表', '股东应占溢利', 17, 41.55),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '利润表', '每股基本盈利', 18, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '利润表', '每股摊薄盈利', 19, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '利润表', '其他全面收益其他项目', 21, 39.24),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '利润表', '其他全面收益', 22, 39.24),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '利润表', '全面收益总额', 23, 81.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '利润表', '非控股权益应占全面收益总额', 24, 0.21),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '利润表', '本公司拥有人应占全面收益总额', 25, 80.79),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '利润表', '非运算项目', 20, -254.27),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '利润表', '营业额', 1, 254.34),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '利润表', '营运收入', 2, 254.34),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '利润表', '营运支出', 3, 167.61),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '利润表', '毛利', 4, 86.73),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '利润表', '其他收入', 5, 6.15),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '利润表', '其他收益', 6, 0.78),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '利润表', '销售及分销费用', 7, 20.41),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '利润表', '行政开支', 8, 27.03),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '利润表', '经营溢利', 9, 46.22),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '利润表', '融资成本', 10, 0.64),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '利润表', '应占联营公司溢利', 11, -0.18),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '利润表', '除税前溢利', 12, 45.4),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '利润表', '税项', 13, 5.63),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '利润表', '持续经营业务税后利润', 14, 39.77),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '利润表', '除税后溢利', 15, 39.77),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '利润表', '少数股东损益', 16, -0.05),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '利润表', '股东应占溢利', 17, 39.82),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '利润表', '每股基本盈利', 18, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '利润表', '每股摊薄盈利', 19, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '利润表', '其他全面收益其他项目', 21, 12.91),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '利润表', '其他全面收益', 22, 12.91),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '利润表', '全面收益总额', 23, 52.68),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '利润表', '非控股权益应占全面收益总额', 24, -0.05),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '利润表', '本公司拥有人应占全面收益总额', 25, 52.73),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '利润表', '非运算项目', 20, -122.6),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q2', '2026-06-30', '现金流量表', '经营业务现金净额', 1, 51.96),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q2', '2026-06-30', '现金流量表', '投资业务现金净额', 2, 29.32),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q2', '2026-06-30', '现金流量表', '融资前现金净额', 3, 81.28),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q2', '2026-06-30', '现金流量表', '融资业务现金净额', 4, 72.73),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q2', '2026-06-30', '现金流量表', '现金净额', 5, 154.01),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q2', '2026-06-30', '现金流量表', '期初现金', 6, 84.7),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q2', '2026-06-30', '现金流量表', '期间变动其他项目', 7, -1.73),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q2', '2026-06-30', '现金流量表', '期末现金', 8, 236.98),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q1', '2026-03-31', '现金流量表', '经营业务现金净额', 1, 23.32),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q1', '2026-03-31', '现金流量表', '投资业务现金净额', 2, 66.5),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q1', '2026-03-31', '现金流量表', '融资前现金净额', 3, 89.82),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q1', '2026-03-31', '现金流量表', '融资业务现金净额', 4, 10.11),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q1', '2026-03-31', '现金流量表', '现金净额', 5, 99.93),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q1', '2026-03-31', '现金流量表', '期初现金', 6, 84.7),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q1', '2026-03-31', '现金流量表', '期间变动其他项目', 7, -0.47),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2026Q1', '2026-03-31', '现金流量表', '期末现金', 8, 184.16),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '现金流量表', '除税前溢利(业务利润)', 9, 132.77),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '现金流量表', '减:利息收入', 10, 10.54),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '现金流量表', '加:利息支出', 11, 1.22),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '现金流量表', '减:投资收益', 12, 1.73),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '现金流量表', '减:应占附属公司溢利', 13, 0.42),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '现金流量表', '加:折旧及摊销', 14, 13.75),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '现金流量表', '减:汇兑收益', 15, -0.07),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '现金流量表', '加:经营调整其他项目', 16, -20.22),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '现金流量表', '营运资金变动前经营溢利', 17, 114.9),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '现金流量表', '存货(增加)减少', 18, -0.17),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '现金流量表', '应付帐款及应计费用增加(减少)', 19, -7.83),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '现金流量表', '营运资本变动其他项目', 20, 1.22),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '现金流量表', '经营产生现金', 21, 108.12),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '现金流量表', '已收利息(经营)', 22, 12.4),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '现金流量表', '已付税项', 23, 18.21),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '现金流量表', '经营业务现金净额', 1, 102.31),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '现金流量表', '已收股息(投资)', 24, 3.32),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '现金流量表', '存款减少(增加)', 25, -178.8),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '现金流量表', '购建固定资产', 26, 3.05),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '现金流量表', '购建无形资产及其他资产', 27, 8.83),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '现金流量表', '收回投资所得现金', 28, 0.4),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '现金流量表', '投资支付现金', 29, 50.75),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '现金流量表', '投资业务其他项目', 30, 135.44),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '现金流量表', '投资业务现金净额', 2, -102.27),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '现金流量表', '融资前现金净额', 3, 0.04),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '现金流量表', '已付利息(融资)', 31, 1.19),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '现金流量表', '已付股息(融资)', 32, 20.35),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '现金流量表', '吸收投资所得', 33, 0.01),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '现金流量表', '发行股份', 34, 4.3),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '现金流量表', '回购股份', 35, 3.9),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '现金流量表', '赎回债券', 36, 21.31),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '现金流量表', '偿还融资租赁', 37, 1.24),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '现金流量表', '融资业务其他项目', 38, -2.81),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '现金流量表', '融资业务现金净额', 4, -46.49),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '现金流量表', '现金净额', 5, -46.45),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '现金流量表', '期初现金', 6, 131.64),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '现金流量表', '期间变动其他项目', 7, -0.49),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q4', '2025-12-31', '现金流量表', '期末现金', 8, 84.7),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q3', '2025-09-30', '现金流量表', '经营业务现金净额', 1, 78.4),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q3', '2025-09-30', '现金流量表', '投资业务现金净额', 2, -50.98),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q3', '2025-09-30', '现金流量表', '融资前现金净额', 3, 27.42),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q3', '2025-09-30', '现金流量表', '融资业务现金净额', 4, -46.34),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q3', '2025-09-30', '现金流量表', '现金净额', 5, -18.92),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q3', '2025-09-30', '现金流量表', '期初现金', 6, 131.64),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q3', '2025-09-30', '现金流量表', '期间变动其他项目', 7, -0.17),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q3', '2025-09-30', '现金流量表', '期末现金', 8, 112.55),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q2', '2025-06-30', '现金流量表', '经营业务现金净额', 1, 41.57),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q2', '2025-06-30', '现金流量表', '投资业务现金净额', 2, -38.54),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q2', '2025-06-30', '现金流量表', '融资前现金净额', 3, 3.03),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q2', '2025-06-30', '现金流量表', '融资业务现金净额', 4, -25.12),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q2', '2025-06-30', '现金流量表', '现金净额', 5, -22.09),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q2', '2025-06-30', '现金流量表', '期初现金', 6, 131.64),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q2', '2025-06-30', '现金流量表', '期间变动其他项目', 7, 0.44),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q2', '2025-06-30', '现金流量表', '期末现金', 8, 109.99),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q1', '2025-03-31', '现金流量表', '经营业务现金净额', 1, 25.19),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q1', '2025-03-31', '现金流量表', '投资业务现金净额', 2, -32.21),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q1', '2025-03-31', '现金流量表', '融资前现金净额', 3, -7.02),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q1', '2025-03-31', '现金流量表', '融资业务现金净额', 4, -4.56),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q1', '2025-03-31', '现金流量表', '现金净额', 5, -11.58),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q1', '2025-03-31', '现金流量表', '期初现金', 6, 131.64),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q1', '2025-03-31', '现金流量表', '期间变动其他项目', 7, 0.16),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025Q1', '2025-03-31', '现金流量表', '期末现金', 8, 120.22),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '现金流量表', '除税前溢利(业务利润)', 9, 87.12),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '现金流量表', '减:利息收入', 10, 11.96),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '现金流量表', '加:利息支出', 11, 1.24),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '现金流量表', '减:投资收益', 12, 0.17),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '现金流量表', '减:应占附属公司溢利', 13, 0.96),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '现金流量表', '加:折旧及摊销', 14, 9.78),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '现金流量表', '减:汇兑收益', 15, 0.3),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '现金流量表', '加:经营调整其他项目', 16, 1.47),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '现金流量表', '营运资金变动前经营溢利', 17, 86.22),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '现金流量表', '存货(增加)减少', 18, -0.15),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '现金流量表', '应付帐款及应计费用增加(减少)', 19, 18.45),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '现金流量表', '营运资本变动其他项目', 20, 2.65),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '现金流量表', '经营产生现金', 21, 107.17),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '现金流量表', '已收利息(经营)', 22, 9.13),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '现金流量表', '已付税项', 23, 13.55),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '现金流量表', '经营业务现金净额', 1, 102.75),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '现金流量表', '已收股息(投资)', 24, 0.61),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '现金流量表', '存款减少(增加)', 25, -244.58),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '现金流量表', '购建固定资产', 26, 3.19),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '现金流量表', '购建无形资产及其他资产', 27, 7.13),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '现金流量表', '出售附属公司', 39, -0.25),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '现金流量表', '收回投资所得现金', 28, 0.18),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '现金流量表', '投资支付现金', 29, 120.09),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '现金流量表', '投资业务其他项目', 30, 306.27),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '现金流量表', '投资业务现金净额', 2, -68.18),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '现金流量表', '融资前现金净额', 3, 34.57),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '现金流量表', '已付利息(融资)', 31, 1.19),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '现金流量表', '已付股息(融资)', 32, 15.76),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '现金流量表', '吸收投资所得', 33, 0.06),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '现金流量表', '发行股份', 34, 1.56),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '现金流量表', '回购股份', 35, 19.25),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '现金流量表', '偿还融资租赁', 37, 1.34),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '现金流量表', '融资业务其他项目', 38, -2.38),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '现金流量表', '融资业务现金净额', 4, -38.3),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '现金流量表', '现金净额', 5, -3.73),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '现金流量表', '期初现金', 6, 135.67),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '现金流量表', '期间变动其他项目', 7, -0.3),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q4', '2024-12-31', '现金流量表', '期末现金', 8, 131.64),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q3', '2024-09-30', '现金流量表', '经营业务现金净额', 1, 77.95),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q3', '2024-09-30', '现金流量表', '投资业务现金净额', 2, -81.42),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q3', '2024-09-30', '现金流量表', '融资前现金净额', 3, -3.47),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q3', '2024-09-30', '现金流量表', '融资业务现金净额', 4, -30.15),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q3', '2024-09-30', '现金流量表', '现金净额', 5, -33.62),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q3', '2024-09-30', '现金流量表', '期初现金', 6, 135.67),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q3', '2024-09-30', '现金流量表', '期间变动其他项目', 7, 0.04),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q3', '2024-09-30', '现金流量表', '期末现金', 8, 102.09),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q2', '2024-06-30', '现金流量表', '经营业务现金净额', 1, 56.3),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q2', '2024-06-30', '现金流量表', '投资业务现金净额', 2, -48.05),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q2', '2024-06-30', '现金流量表', '融资前现金净额', 3, 8.25),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q2', '2024-06-30', '现金流量表', '融资业务现金净额', 4, -21.33),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q2', '2024-06-30', '现金流量表', '现金净额', 5, -13.08),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q2', '2024-06-30', '现金流量表', '期初现金', 6, 135.67),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q2', '2024-06-30', '现金流量表', '期间变动其他项目', 7, -0.08),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q2', '2024-06-30', '现金流量表', '期末现金', 8, 122.51),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q1', '2024-03-31', '现金流量表', '经营业务现金净额', 1, 26.86),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q1', '2024-03-31', '现金流量表', '投资业务现金净额', 2, -54.98),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q1', '2024-03-31', '现金流量表', '融资前现金净额', 3, -28.12),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q1', '2024-03-31', '现金流量表', '融资业务现金净额', 4, -5.22),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q1', '2024-03-31', '现金流量表', '现金净额', 5, -33.34),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q1', '2024-03-31', '现金流量表', '期初现金', 6, 135.67),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q1', '2024-03-31', '现金流量表', '期间变动其他项目', 7, -0.15),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024Q1', '2024-03-31', '现金流量表', '期末现金', 8, 102.18),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '现金流量表', '除税前溢利(业务利润)', 9, 60.45),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '现金流量表', '减:利息收入', 10, 10.52),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '现金流量表', '加:利息支出', 11, 1.24),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '现金流量表', '减:投资收益', 12, 0.15),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '现金流量表', '减:应占附属公司溢利', 13, 1.27),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '现金流量表', '加:折旧及摊销', 14, 10.04),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '现金流量表', '减:汇兑收益', 15, -0.17),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '现金流量表', '加:经营调整其他项目', 16, 4.69),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '现金流量表', '营运资金变动前经营溢利', 17, 64.65),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '现金流量表', '存货(增加)减少', 18, 0.07),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '现金流量表', '应付帐款及应计费用增加(减少)', 19, 0.52),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '现金流量表', '营运资本变动其他项目', 20, 9.31),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '现金流量表', '经营产生现金', 21, 74.55),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '现金流量表', '已收利息(经营)', 22, 7.07),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '现金流量表', '已付税项', 23, 8.25),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '现金流量表', '经营业务现金净额', 1, 73.37),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '现金流量表', '已收股息(投资)', 24, 1.26),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '现金流量表', '存款减少(增加)', 25, -136.63),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '现金流量表', '购建固定资产', 26, 1.65),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '现金流量表', '购建无形资产及其他资产', 27, 9.99),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '现金流量表', '出售附属公司', 39, 0.07),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '现金流量表', '收回投资所得现金', 28, 0.59),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '现金流量表', '投资支付现金', 29, 0.08),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '现金流量表', '投资业务其他项目', 30, 127.8),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '现金流量表', '投资业务现金净额', 2, -18.63),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '现金流量表', '融资前现金净额', 3, 54.74),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '现金流量表', '已付利息(融资)', 31, 1.17),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '现金流量表', '已付股息(融资)', 32, 0.42),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '现金流量表', '发行股份', 34, 0.57),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '现金流量表', '回购股份', 35, 12.49),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '现金流量表', '偿还融资租赁', 37, 1.16),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '现金流量表', '融资业务其他项目', 38, -0.71),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '现金流量表', '融资业务现金净额', 4, -15.38),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '现金流量表', '现金净额', 5, 39.36),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '现金流量表', '期初现金', 6, 95.55),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '现金流量表', '期间变动其他项目', 7, 0.76),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q4', '2023-12-31', '现金流量表', '期末现金', 8, 135.67),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q3', '2023-09-30', '现金流量表', '经营业务现金净额', 1, 53.6),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q3', '2023-09-30', '现金流量表', '投资业务现金净额', 2, -16.7),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q3', '2023-09-30', '现金流量表', '融资前现金净额', 3, 36.9),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q3', '2023-09-30', '现金流量表', '融资业务现金净额', 4, -9.62),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q3', '2023-09-30', '现金流量表', '现金净额', 5, 27.28),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q3', '2023-09-30', '现金流量表', '期初现金', 6, 95.55),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q3', '2023-09-30', '现金流量表', '期间变动其他项目', 7, 0.98),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q3', '2023-09-30', '现金流量表', '期末现金', 8, 123.81),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q2', '2023-06-30', '现金流量表', '经营业务现金净额', 1, 39.19),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q2', '2023-06-30', '现金流量表', '投资业务现金净额', 2, -5.28),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q2', '2023-06-30', '现金流量表', '融资前现金净额', 3, 33.91),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q2', '2023-06-30', '现金流量表', '融资业务现金净额', 4, -1.13),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q2', '2023-06-30', '现金流量表', '现金净额', 5, 32.78),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q2', '2023-06-30', '现金流量表', '期初现金', 6, 95.55),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q2', '2023-06-30', '现金流量表', '期间变动其他项目', 7, 1.17),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q2', '2023-06-30', '现金流量表', '期末现金', 8, 129.5),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q1', '2023-03-31', '现金流量表', '经营业务现金净额', 1, 18.52),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q1', '2023-03-31', '现金流量表', '投资业务现金净额', 2, 8.11),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q1', '2023-03-31', '现金流量表', '融资前现金净额', 3, 26.63),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q1', '2023-03-31', '现金流量表', '融资业务现金净额', 4, -0.8),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q1', '2023-03-31', '现金流量表', '现金净额', 5, 25.83),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q1', '2023-03-31', '现金流量表', '期初现金', 6, 95.55),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q1', '2023-03-31', '现金流量表', '期间变动其他项目', 7, -0.09),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023Q1', '2023-03-31', '现金流量表', '期末现金', 8, 121.29),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '现金流量表', '除税前溢利(业务利润)', 9, 43.73),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '现金流量表', '减:利息收入', 10, 7.11),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '现金流量表', '加:利息支出', 11, 1.15),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '现金流量表', '减:投资收益', 12, 0.14),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '现金流量表', '减:应占附属公司溢利', 13, 0.38),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '现金流量表', '减:重估盈余', 40, 0.17),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '现金流量表', '加:折旧及摊销', 14, 11.6),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '现金流量表', '减:汇兑收益', 15, 0.07),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '现金流量表', '加:经营调整其他项目', 16, 5.45),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '现金流量表', '营运资金变动前经营溢利', 17, 54.06),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '现金流量表', '存货(增加)减少', 18, 0.1),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '现金流量表', '应收帐款减少', 41, 9.06),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '现金流量表', '应付帐款及应计费用增加(减少)', 19, 6.63),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '现金流量表', '营运资本变动其他项目', 20, 6.42),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '现金流量表', '经营产生现金', 21, 76.27),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '现金流量表', '已收利息(经营)', 22, 5.87),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '现金流量表', '已付税项', 23, 7.33),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '现金流量表', '经营业务现金净额', 1, 74.81),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '现金流量表', '已收股息(投资)', 24, 0.74),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '现金流量表', '存款减少(增加)', 25, -339.19),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '现金流量表', '购建固定资产', 26, 0.85),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '现金流量表', '购建无形资产及其他资产', 27, 9.68),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '现金流量表', '出售附属公司', 39, 0.21),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '现金流量表', '投资支付现金', 29, 3.16),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '现金流量表', '投资业务其他项目', 30, 337.47),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '现金流量表', '投资业务现金净额', 2, -14.46),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '现金流量表', '融资前现金净额', 3, 60.35),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '现金流量表', '已付利息(融资)', 31, 1.15),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '现金流量表', '已付股息(融资)', 32, 0.7),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '现金流量表', '发行股份', 34, 0.03),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '现金流量表', '回购股份', 35, 31.27),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '现金流量表', '偿还融资租赁', 37, 1.3),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '现金流量表', '融资业务其他项目', 38, 0.2),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '现金流量表', '融资业务现金净额', 4, -34.19),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '现金流量表', '现金净额', 5, 26.16),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '现金流量表', '期初现金', 6, 65.91),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '现金流量表', '期间变动其他项目', 7, 3.48),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q4', '2022-12-31', '现金流量表', '期末现金', 8, 95.55),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q3', '2022-09-30', '现金流量表', '经营业务现金净额', 1, 49.87),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q3', '2022-09-30', '现金流量表', '投资业务现金净额', 2, -3.38),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q3', '2022-09-30', '现金流量表', '融资前现金净额', 3, 46.49),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q3', '2022-09-30', '现金流量表', '融资业务现金净额', 4, -30.36),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q3', '2022-09-30', '现金流量表', '现金净额', 5, 16.13),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q3', '2022-09-30', '现金流量表', '期初现金', 6, 65.91),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q3', '2022-09-30', '现金流量表', '期间变动其他项目', 7, 3.78),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q3', '2022-09-30', '现金流量表', '期末现金', 8, 85.82),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q2', '2022-06-30', '现金流量表', '经营业务现金净额', 1, 37.35),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q2', '2022-06-30', '现金流量表', '投资业务现金净额', 2, 9.05),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q2', '2022-06-30', '现金流量表', '融资前现金净额', 3, 46.4),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q2', '2022-06-30', '现金流量表', '融资业务现金净额', 4, -13.68),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q2', '2022-06-30', '现金流量表', '现金净额', 5, 32.72),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q2', '2022-06-30', '现金流量表', '期初现金', 6, 65.91),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q2', '2022-06-30', '现金流量表', '期间变动其他项目', 7, 1.81),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q2', '2022-06-30', '现金流量表', '期末现金', 8, 100.44),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q1', '2022-03-31', '现金流量表', '经营业务现金净额', 1, 24.94),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q1', '2022-03-31', '现金流量表', '投资业务现金净额', 2, -3.29),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q1', '2022-03-31', '现金流量表', '融资前现金净额', 3, 21.65),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q1', '2022-03-31', '现金流量表', '融资业务现金净额', 4, -3.95),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q1', '2022-03-31', '现金流量表', '现金净额', 5, 17.7),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q1', '2022-03-31', '现金流量表', '期初现金', 6, 65.91),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q1', '2022-03-31', '现金流量表', '期间变动其他项目', 7, -0.08),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022Q1', '2022-03-31', '现金流量表', '期末现金', 8, 83.53),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '现金流量表', '除税前溢利(业务利润)', 9, 36.32),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '现金流量表', '减:利息收入', 10, 5.3),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '现金流量表', '加:利息支出', 11, 1.2),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '现金流量表', '减:投资收益', 12, 0.27),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '现金流量表', '加:折旧及摊销', 14, 10.01),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '现金流量表', '减:汇兑收益', 15, -0.01),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '现金流量表', '加:经营调整其他项目', 16, 6.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '现金流量表', '营运资金变动前经营溢利', 17, 47.97),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '现金流量表', '存货(增加)减少', 18, -0.06),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '现金流量表', '应收帐款减少', 41, -7.69),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '现金流量表', '应付帐款及应计费用增加(减少)', 19, 6.31),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '现金流量表', '营运资本变动其他项目', 20, 7.17),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '现金流量表', '经营产生现金', 21, 53.7),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '现金流量表', '已收利息(经营)', 22, 4.58),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '现金流量表', '已付税项', 23, 5.89),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '现金流量表', '经营业务现金净额', 1, 52.39),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '现金流量表', '已收股息(投资)', 24, 0.88),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '现金流量表', '存款减少(增加)', 25, -151.53),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '现金流量表', '购建固定资产', 26, 1.59),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '现金流量表', '购建无形资产及其他资产', 27, 25.99),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '现金流量表', '出售附属公司', 39, 0.03),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '现金流量表', '收回投资所得现金', 28, 3.63),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '现金流量表', '投资支付现金', 29, 56.16),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '现金流量表', '投资业务其他项目', 30, 170.74),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '现金流量表', '投资业务现金净额', 2, -59.99),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '现金流量表', '融资前现金净额', 3, -7.6),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '现金流量表', '已付利息(融资)', 31, 1.05),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '现金流量表', '已付股息(融资)', 32, 0.03),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '现金流量表', '发行股份', 34, 1.04),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '现金流量表', '回购股份', 35, 34.79),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '现金流量表', '偿还融资租赁', 37, 1.16),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '现金流量表', '融资业务其他项目', 38, -1.11),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '现金流量表', '融资业务现金净额', 4, -37.1),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '现金流量表', '现金净额', 5, -44.7),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '现金流量表', '期初现金', 6, 111.28),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '现金流量表', '期间变动其他项目', 7, -0.67),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q4', '2021-12-31', '现金流量表', '期末现金', 8, 65.91),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q3', '2021-09-30', '现金流量表', '经营业务现金净额', 1, 44.17),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q3', '2021-09-30', '现金流量表', '投资业务现金净额', 2, -69.95),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q3', '2021-09-30', '现金流量表', '融资业务现金净额', 4, -34.24),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q3', '2021-09-30', '现金流量表', '现金净额', 5, -60.02),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q3', '2021-09-30', '现金流量表', '期初现金', 6, 111.28),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q3', '2021-09-30', '现金流量表', '期间变动其他项目', 7, -0.48),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q3', '2021-09-30', '现金流量表', '期末现金', 8, 50.78),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q2', '2021-06-30', '现金流量表', '经营产生现金', 21, 28.48),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q2', '2021-06-30', '现金流量表', '已收利息(经营)', 22, 2.56),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q2', '2021-06-30', '现金流量表', '已付税项', 23, 2.82),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q2', '2021-06-30', '现金流量表', '经营业务现金净额', 1, 28.22),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q2', '2021-06-30', '现金流量表', '存款减少(增加)', 25, -75.65),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q2', '2021-06-30', '现金流量表', '购建固定资产', 26, 0.89),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q2', '2021-06-30', '现金流量表', '购建无形资产及其他资产', 27, 7.94),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q2', '2021-06-30', '现金流量表', '出售附属公司', 39, 0.01),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q2', '2021-06-30', '现金流量表', '投资支付现金', 29, 45.96),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q2', '2021-06-30', '现金流量表', '投资业务其他项目', 30, 77.4),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q2', '2021-06-30', '现金流量表', '投资业务现金净额', 2, -53.03),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q2', '2021-06-30', '现金流量表', '已付利息(融资)', 31, 0.54),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q2', '2021-06-30', '现金流量表', '已付股息(融资)', 32, 0.02),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q2', '2021-06-30', '现金流量表', '发行股份', 34, 0.85),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q2', '2021-06-30', '现金流量表', '回购股份', 35, 16.83),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q2', '2021-06-30', '现金流量表', '偿还融资租赁', 37, 0.54),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q2', '2021-06-30', '现金流量表', '融资业务其他项目', 38, -0.65),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q2', '2021-06-30', '现金流量表', '融资业务现金净额', 4, -17.73),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q2', '2021-06-30', '现金流量表', '现金净额', 5, -42.54),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q2', '2021-06-30', '现金流量表', '期初现金', 6, 111.28),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q2', '2021-06-30', '现金流量表', '期间变动其他项目', 7, -0.52),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q2', '2021-06-30', '现金流量表', '期末现金', 8, 68.22),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q1', '2021-03-31', '现金流量表', '除税前溢利(业务利润)', 9, 11.06),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q1', '2021-03-31', '现金流量表', '减:利息收入', 10, 1.54),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q1', '2021-03-31', '现金流量表', '加:利息支出', 11, 0.31),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q1', '2021-03-31', '现金流量表', '减:投资收益', 12, 0.01),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q1', '2021-03-31', '现金流量表', '减:应占附属公司溢利', 13, -0.27),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q1', '2021-03-31', '现金流量表', '加:减值及拨备', 42, 0.03),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q1', '2021-03-31', '现金流量表', '加:折旧及摊销', 14, 2.2),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q1', '2021-03-31', '现金流量表', '加:经营调整其他项目', 16, 1.61),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q1', '2021-03-31', '现金流量表', '营运资金变动前经营溢利', 17, 13.93),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q1', '2021-03-31', '现金流量表', '应收帐款减少', 41, 0.1),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q1', '2021-03-31', '现金流量表', '应付帐款及应计费用增加(减少)', 19, 3.2),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q1', '2021-03-31', '现金流量表', '营运资本变动其他项目', 20, 1.15),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q1', '2021-03-31', '现金流量表', '经营产生现金', 21, 18.38),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q1', '2021-03-31', '现金流量表', '已收利息(经营)', 22, 1.54),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q1', '2021-03-31', '现金流量表', '已付税项', 23, 1.14),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q1', '2021-03-31', '现金流量表', '经营业务现金净额', 1, 18.78),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q1', '2021-03-31', '现金流量表', '存款减少(增加)', 25, -29.41),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q1', '2021-03-31', '现金流量表', '购建固定资产', 26, 0.39),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q1', '2021-03-31', '现金流量表', '购建无形资产及其他资产', 27, 1.61),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q1', '2021-03-31', '现金流量表', '出售附属公司', 39, 0.01),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q1', '2021-03-31', '现金流量表', '投资支付现金', 29, 24.16),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q1', '2021-03-31', '现金流量表', '投资业务其他项目', 30, 31.74),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q1', '2021-03-31', '现金流量表', '投资业务现金净额', 2, -23.82),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q1', '2021-03-31', '现金流量表', '融资前现金净额', 3, -5.04),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q1', '2021-03-31', '现金流量表', '已付利息(融资)', 31, 0.5),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q1', '2021-03-31', '现金流量表', '已付股息(融资)', 32, 0.02),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q1', '2021-03-31', '现金流量表', '回购股份', 35, 3.27),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q1', '2021-03-31', '现金流量表', '偿还融资租赁', 37, 0.23),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q1', '2021-03-31', '现金流量表', '融资业务其他项目', 38, 0.3),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q1', '2021-03-31', '现金流量表', '融资业务现金净额', 4, -3.72),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q1', '2021-03-31', '现金流量表', '现金净额', 5, -8.76),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q1', '2021-03-31', '现金流量表', '期初现金', 6, 111.28),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q1', '2021-03-31', '现金流量表', '期间变动其他项目', 7, 0.22),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021Q1', '2021-03-31', '现金流量表', '期末现金', 8, 102.74),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '现金流量表', '除税前溢利(业务利润)', 9, 46.32),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '现金流量表', '减:利息收入', 10, 6.22),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '现金流量表', '加:利息支出', 11, 0.62),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '现金流量表', '减:应占附属公司溢利', 13, 0.19),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '现金流量表', '加:折旧及摊销', 14, 8.24),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '现金流量表', '减:汇兑收益', 15, 0.02),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '现金流量表', '加:经营调整其他项目', 16, 5.67),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '现金流量表', '营运资金变动前经营溢利', 17, 54.42),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '现金流量表', '存货(增加)减少', 18, 0.08),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '现金流量表', '应收帐款减少', 41, -5.2),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '现金流量表', '应付帐款及应计费用增加(减少)', 19, 6.44),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '现金流量表', '营运资本变动其他项目', 20, -6.29),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '现金流量表', '经营产生现金', 21, 49.45),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '现金流量表', '已收利息(经营)', 22, 5.77),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '现金流量表', '已付税项', 23, 6.37),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '现金流量表', '经营业务现金净额', 1, 48.85),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '现金流量表', '存款减少(增加)', 25, -306.43),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '现金流量表', '购建固定资产', 26, 1.08),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '现金流量表', '购建无形资产及其他资产', 27, 3.93),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '现金流量表', '出售附属公司', 39, 0.15),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '现金流量表', '投资支付现金', 29, 9.18),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '现金流量表', '投资业务其他项目', 30, 178.41),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '现金流量表', '投资业务现金净额', 2, -142.06),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '现金流量表', '融资前现金净额', 3, -93.21),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '现金流量表', '已付利息(融资)', 31, 0.15),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '现金流量表', '发行股份', 34, 1.63),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '现金流量表', '回购股份', 35, 1.34),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '现金流量表', '发行债券', 43, 54.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '现金流量表', '偿还融资租赁', 37, 0.78),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '现金流量表', '融资业务其他项目', 38, -0.44),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '现金流量表', '融资业务现金净额', 4, 52.92),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '现金流量表', '现金净额', 5, -40.29),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '现金流量表', '期初现金', 6, 154.26),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '现金流量表', '期间变动其他项目', 7, -2.69),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020Q4', '2020-12-31', '现金流量表', '期末现金', 8, 111.28),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '现金流量表', '除税前溢利(业务利润)', 9, 45.4),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '现金流量表', '减:利息收入', 10, 6.15),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '现金流量表', '加:利息支出', 11, 0.31),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '现金流量表', '减:投资收益', 12, -0.37),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '现金流量表', '减:应占附属公司溢利', 13, -0.18),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '现金流量表', '加:减值及拨备', 42, 0.61),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '现金流量表', '加:折旧及摊销', 14, 5.83),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '现金流量表', '减:汇兑收益', 15, 0.04),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '现金流量表', '加:经营调整其他项目', 16, 5.55),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '现金流量表', '营运资金变动前经营溢利', 17, 52.06),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '现金流量表', '存货(增加)减少', 18, 0.09),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '现金流量表', '应收帐款减少', 41, -7.33),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '现金流量表', '应付帐款及应计费用增加(减少)', 19, 7.17),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '现金流量表', '营运资本变动其他项目', 20, 9.89),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '现金流量表', '经营产生现金', 21, 61.88),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '现金流量表', '已收利息(经营)', 22, 5.76),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '现金流量表', '已付税项', 23, 5.64),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '现金流量表', '经营业务现金净额', 1, 62.0),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '现金流量表', '已收股息(投资)', 24, 0.32),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '现金流量表', '存款减少(增加)', 25, -120.5),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '现金流量表', '购建固定资产', 26, 0.95),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '现金流量表', '购建无形资产及其他资产', 27, 1.91),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '现金流量表', '投资支付现金', 29, 0.37),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '现金流量表', '投资业务其他项目', 30, 42.39),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '现金流量表', '投资业务现金净额', 2, -81.02),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '现金流量表', '融资前现金净额', 3, -19.02),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '现金流量表', '已付利息(融资)', 31, 0.07),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '现金流量表', '发行股份', 34, 0.12),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '现金流量表', '偿还融资租赁', 37, 0.56),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '现金流量表', '融资业务其他项目', 38, 0.2),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '现金流量表', '融资业务现金净额', 4, -0.31),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '现金流量表', '现金净额', 5, -19.33),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '现金流量表', '期初现金', 6, 173.56),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '现金流量表', '期间变动其他项目', 7, 0.03),
((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019Q4', '2019-12-31', '现金流量表', '期末现金', 8, 154.26);

SELECT vi_merge_company_metrics((SELECT id FROM vi_company_base WHERE code = '01698.HK'));

DELETE FROM vi_fact_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2017 年度数据口径与说明';

INSERT INTO vi_fact_base (company_id, title, category, statement, period, as_of, verify_status, source_id) VALUES ((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2017 年度数据口径与说明', '财务', '财务数据：东方财富（国际财务报告准则）；“分红总额”为股东回报＝归属该年度的现金股息＋当年回购；货币资金为现金、现金等价物与定期存款（公司口径）；带息负债＝应付票据＋租赁负债＋借款；投资收益栏＝利息收入＋其他收益净额。；美股格式报表（东方财富）；腾讯音乐 2018 年 12 月在纽交所上市。；付费用户（第四季度）未取得。', '2017', '2017-12-31', '待核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '东方财富港股/美股格式三大报表（akshare 取数）' ORDER BY id LIMIT 1));

DELETE FROM vi_fact_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2018 年度数据口径与说明';

INSERT INTO vi_fact_base (company_id, title, category, statement, period, as_of, verify_status, source_id) VALUES ((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2018 年度数据口径与说明', '财务', '财务数据：东方财富（国际财务报告准则）；“分红总额”为股东回报＝归属该年度的现金股息＋当年回购；货币资金为现金、现金等价物与定期存款（公司口径）；带息负债＝应付票据＋租赁负债＋借款；投资收益栏＝利息收入＋其他收益净额。；美股格式报表（东方财富）；纽交所上市募资约 77 亿元。；付费用户（第四季度）未取得。', '2018', '2018-12-31', '待核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '东方财富港股/美股格式三大报表（akshare 取数）' ORDER BY id LIMIT 1));

DELETE FROM vi_fact_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2019 年度数据口径与说明';

INSERT INTO vi_fact_base (company_id, title, category, statement, period, as_of, verify_status, source_id) VALUES ((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2019 年度数据口径与说明', '财务', '财务数据：东方财富（国际财务报告准则）；“分红总额”为股东回报＝归属该年度的现金股息＋当年回购；货币资金为现金、现金等价物与定期存款（公司口径）；带息负债＝应付票据＋租赁负债＋借款；投资收益栏＝利息收入＋其他收益净额。；付费用户（第四季度）未取得。', '2019', '2019-12-31', '待核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '东方财富港股/美股格式三大报表（akshare 取数）' ORDER BY id LIMIT 1));

DELETE FROM vi_fact_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2020 年度数据口径与说明';

INSERT INTO vi_fact_base (company_id, title, category, statement, period, as_of, verify_status, source_id) VALUES ((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2020 年度数据口径与说明', '财务', '财务数据：东方财富（国际财务报告准则）；“分红总额”为股东回报＝归属该年度的现金股息＋当年回购；货币资金为现金、现金等价物与定期存款（公司口径）；带息负债＝应付票据＋租赁负债＋借款；投资收益栏＝利息收入＋其他收益净额。；发行 8 亿美元票据（54.0 亿元）；开始回购。；付费用户（第四季度）未取得。', '2020', '2020-12-31', '待核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '东方财富港股/美股格式三大报表（akshare 取数）' ORDER BY id LIMIT 1));

DELETE FROM vi_fact_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2021 年度数据口径与说明';

INSERT INTO vi_fact_base (company_id, title, category, statement, period, as_of, verify_status, source_id) VALUES ((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2021 年度数据口径与说明', '财务', '财务数据：东方财富（国际财务报告准则）；“分红总额”为股东回报＝归属该年度的现金股息＋当年回购；货币资金为现金、现金等价物与定期存款（公司口径）；带息负债＝应付票据＋租赁负债＋借款；投资收益栏＝利息收入＋其他收益净额。；市场监管总局责令解除独家版权（2021 年 7 月）；回购 34.8 亿元。', '2021', '2021-12-31', '待核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '东方财富港股/美股格式三大报表（akshare 取数）' ORDER BY id LIMIT 1));

DELETE FROM vi_fact_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2022 年度数据口径与说明';

INSERT INTO vi_fact_base (company_id, title, category, statement, period, as_of, verify_status, source_id) VALUES ((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2022 年度数据口径与说明', '财务', '财务数据：东方财富（国际财务报告准则）；“分红总额”为股东回报＝归属该年度的现金股息＋当年回购；货币资金为现金、现金等价物与定期存款（公司口径）；带息负债＝应付票据＋租赁负债＋借款；投资收益栏＝利息收入＋其他收益净额。；收入下降 9.3%；在港交所以介绍方式上市（2022 年 9 月）。', '2022', '2022-12-31', '待核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '东方财富港股/美股格式三大报表（akshare 取数）' ORDER BY id LIMIT 1));

DELETE FROM vi_fact_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2023 年度数据口径与说明';

INSERT INTO vi_fact_base (company_id, title, category, statement, period, as_of, verify_status, source_id) VALUES ((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2023 年度数据口径与说明', '财务', '财务数据：东方财富（国际财务报告准则）；“分红总额”为股东回报＝归属该年度的现金股息＋当年回购；货币资金为现金、现金等价物与定期存款（公司口径）；带息负债＝应付票据＋租赁负债＋借款；投资收益栏＝利息收入＋其他收益净额。；首次宣派年度现金股息（每股 0.07 美元）；毛利率升到 35.3%。', '2023', '2023-12-31', '待核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '东方财富港股/美股格式三大报表（akshare 取数）' ORDER BY id LIMIT 1));

DELETE FROM vi_fact_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2024 年度数据口径与说明';

INSERT INTO vi_fact_base (company_id, title, category, statement, period, as_of, verify_status, source_id) VALUES ((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2024 年度数据口径与说明', '财务', '财务数据：东方财富（国际财务报告准则）；“分红总额”为股东回报＝归属该年度的现金股息＋当年回购；货币资金为现金、现金等价物与定期存款（公司口径）；带息负债＝应付票据＋租赁负债＋借款；投资收益栏＝利息收入＋其他收益净额。；订阅收入 +25.9%；毛利率 42.3%。', '2024', '2024-12-31', '待核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第四季度及全年未经审计财务业绩公告' ORDER BY id LIMIT 1));

DELETE FROM vi_fact_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年度数据口径与说明';

INSERT INTO vi_fact_base (company_id, title, category, statement, period, as_of, verify_status, source_id) VALUES ((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '2025 年度数据口径与说明', '财务', '财务数据：东方财富（国际财务报告准则）；“分红总额”为股东回报＝归属该年度的现金股息＋当年回购；货币资金为现金、现金等价物与定期存款（公司口径）；带息负债＝应付票据＋租赁负债＋借款；投资收益栏＝利息收入＋其他收益净额。；模型基准年。归母净利含 UMG 实物分派带来的视同处置收益 23.7 亿元（剔除后约 86.9 亿元，股东回报率约 33%）；偿还 3 亿美元票据。', '2025', '2025-12-31', '待核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '2025 年第四季度及全年未经审计财务业绩公告' ORDER BY id LIMIT 1));

UPDATE vi_metric_base SET notes = '跟踪用途：看剔除喜马拉雅后的同比', source_name = '季度业绩公告、业绩会' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '会员（订阅）收入' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1);

UPDATE vi_metric_base SET source_name = '季度业绩公告' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '毛利率' AND unit IS NOT DISTINCT FROM '%' ORDER BY id LIMIT 1);

UPDATE vi_metric_base SET source_name = '业绩公告、港交所回购公告' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '回购金额' AND unit IS NOT DISTINCT FROM '亿美元' ORDER BY id LIMIT 1);

UPDATE vi_metric_base SET source_name = '资产负债表' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '现金、定期存款和短期投资' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1);

UPDATE vi_metric_base SET source_name = '资产负债表' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '带息负债（借款＋票据＋租赁）' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1);

UPDATE vi_metric_base SET source_name = 'QuestMobile、行业研报' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '竞品月活：汽水音乐' AND unit IS NOT DISTINCT FROM '百万人' ORDER BY id LIMIT 1);

UPDATE vi_metric_base SET source_name = '年报（2027 年 3 月）' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '在线音乐付费用户' AND unit IS NOT DISTINCT FROM '百万人' ORDER BY id LIMIT 1);

SELECT vi_metric_to_stmt((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '毛利率', '%', '毛利 ÷ 营业额', '单季');

SELECT vi_metric_to_stmt((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '现金、定期存款和短期投资', '亿元', '现金及等价物 + 短期存款 + 短期投资 + 中长期存款', '时点');

SELECT vi_metric_to_stmt((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '带息负债（借款＋票据＋租赁）', '亿元', '短期贷款 + 长期贷款 + 应付票据 + 应付票据(非流动) + 融资租赁负债(流动) + 融资租赁负债(非流动)', '时点');

SELECT vi_metric_to_stmt((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '营业收入', '亿元', '营业额', '单季');

SELECT vi_metric_to_stmt((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '归母净利润', '亿元', '股东应占溢利', '单季');

INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id, "createdAt", "updatedAt") SELECT x.id, (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '会员（订阅）收入' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), now(), now() FROM vi_judgment_base x WHERE x.company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND x.code = 'J-S1' AND (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '会员（订阅）收入' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) IS NOT NULL ON CONFLICT DO NOTHING;

INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id, "createdAt", "updatedAt") SELECT x.id, (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '在线音乐付费用户' AND unit IS NOT DISTINCT FROM '百万人' ORDER BY id LIMIT 1), now(), now() FROM vi_judgment_base x WHERE x.company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND x.code = 'J-S1' AND (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '在线音乐付费用户' AND unit IS NOT DISTINCT FROM '百万人' ORDER BY id LIMIT 1) IS NOT NULL ON CONFLICT DO NOTHING;

INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id, "createdAt", "updatedAt") SELECT x.id, (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '毛利率' AND unit IS NOT DISTINCT FROM '%' ORDER BY id LIMIT 1), now(), now() FROM vi_judgment_base x WHERE x.company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND x.code = 'J-S1' AND (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '毛利率' AND unit IS NOT DISTINCT FROM '%' ORDER BY id LIMIT 1) IS NOT NULL ON CONFLICT DO NOTHING;

INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id, "createdAt", "updatedAt") SELECT x.id, (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '非订阅音乐收入（广告、演出、周边）' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), now(), now() FROM vi_judgment_base x WHERE x.company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND x.code = 'J-S2' AND (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '非订阅音乐收入（广告、演出、周边）' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) IS NOT NULL ON CONFLICT DO NOTHING;

INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id, "createdAt", "updatedAt") SELECT x.id, (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '社交娱乐及其他收入' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), now(), now() FROM vi_judgment_base x WHERE x.company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND x.code = 'J-S3' AND (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '社交娱乐及其他收入' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) IS NOT NULL ON CONFLICT DO NOTHING;

INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id, "createdAt", "updatedAt") SELECT x.id, (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '现金、定期存款和短期投资' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), now(), now() FROM vi_judgment_base x WHERE x.company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND x.code = 'J-CASH' AND (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '现金、定期存款和短期投资' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) IS NOT NULL ON CONFLICT DO NOTHING;

INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id, "createdAt", "updatedAt") SELECT x.id, (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '带息负债（借款＋票据＋租赁）' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), now(), now() FROM vi_judgment_base x WHERE x.company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND x.code = 'J-CASH' AND (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '带息负债（借款＋票据＋租赁）' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) IS NOT NULL ON CONFLICT DO NOTHING;

INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id, "createdAt", "updatedAt") SELECT x.id, (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '对外上市股权（公允价值）' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), now(), now() FROM vi_judgment_base x WHERE x.company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND x.code = 'J-INV' AND (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '对外上市股权（公允价值）' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) IS NOT NULL ON CONFLICT DO NOTHING;

INSERT INTO vi_lnk_risk_metrics (risk_id, metric_id, "createdAt", "updatedAt") SELECT x.id, (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '会员（订阅）收入' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), now(), now() FROM vi_risk_base x WHERE x.company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND x.code = 'R1' AND (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '会员（订阅）收入' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) IS NOT NULL ON CONFLICT DO NOTHING;

INSERT INTO vi_lnk_risk_metrics (risk_id, metric_id, "createdAt", "updatedAt") SELECT x.id, (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '在线音乐付费用户' AND unit IS NOT DISTINCT FROM '百万人' ORDER BY id LIMIT 1), now(), now() FROM vi_risk_base x WHERE x.company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND x.code = 'R1' AND (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '在线音乐付费用户' AND unit IS NOT DISTINCT FROM '百万人' ORDER BY id LIMIT 1) IS NOT NULL ON CONFLICT DO NOTHING;

INSERT INTO vi_lnk_risk_metrics (risk_id, metric_id, "createdAt", "updatedAt") SELECT x.id, (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '毛利率' AND unit IS NOT DISTINCT FROM '%' ORDER BY id LIMIT 1), now(), now() FROM vi_risk_base x WHERE x.company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND x.code = 'R2' AND (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '毛利率' AND unit IS NOT DISTINCT FROM '%' ORDER BY id LIMIT 1) IS NOT NULL ON CONFLICT DO NOTHING;

INSERT INTO vi_lnk_risk_metrics (risk_id, metric_id, "createdAt", "updatedAt") SELECT x.id, (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '现金、定期存款和短期投资' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), now(), now() FROM vi_risk_base x WHERE x.company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND x.code = 'R3' AND (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '现金、定期存款和短期投资' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) IS NOT NULL ON CONFLICT DO NOTHING;

INSERT INTO vi_lnk_risk_metrics (risk_id, metric_id, "createdAt", "updatedAt") SELECT x.id, (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '带息负债（借款＋票据＋租赁）' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), now(), now() FROM vi_risk_base x WHERE x.company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND x.code = 'R3' AND (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '带息负债（借款＋票据＋租赁）' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) IS NOT NULL ON CONFLICT DO NOTHING;

INSERT INTO vi_lnk_risk_metrics (risk_id, metric_id, "createdAt", "updatedAt") SELECT x.id, (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '对外上市股权（公允价值）' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), now(), now() FROM vi_risk_base x WHERE x.company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND x.code = 'R5' AND (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '对外上市股权（公允价值）' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) IS NOT NULL ON CONFLICT DO NOTHING;

UPDATE vi_risk_base SET early_warning = '会员服务收入同比（剔除喜马拉雅）：连续两个季度同比为负
汽水音乐、番茄音乐月活与付费：汽水月活超过 2.5 亿或推出更低价会员
年末付费用户总数：2026 年末低于 1.22 亿（−4%）
持续跟踪：番茄音乐月活、汽水音乐付费情况（月；来源：QuestMobile、行业研报）' WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND code = 'R1';

UPDATE vi_risk_base SET early_warning = '毛利率：单季毛利率低于 42%
AI 音乐与版权政策：AI 翻唱或生成音乐的版权规则落地
持续跟踪：AI 音乐与版权政策（季；来源：监管部门、行业协会、唱片公司）' WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND code = 'R2';

UPDATE vi_risk_base SET early_warning = '回购执行与新回购计划：新一轮回购计划公布（规模、期限）；或回购明显放缓而股价低于 9 美元
现金、借款与美元票据：净现金低于 150 亿元，或带息负债超过 250 亿元
持续跟踪：新回购计划（季；来源：业绩公告、港交所回购公告）' WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND code = 'R3';

UPDATE vi_risk_base SET early_warning = '喜马拉雅收入与利润贡献：整合后收入下降或出现商誉减值
持续跟踪：喜马拉雅收入与利润贡献（季；来源：业绩公告、年报分部或附注）' WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND code = 'R4';

UPDATE vi_risk_base SET early_warning = '港元兑人民币：一个月内变动超过 3%
对外持股市值（Spotify、UMG）：金融资产较上季变动超过 20%
持续跟踪：对外持股市值（Spotify、UMG）（季；来源：资产负债表的金融资产；Spotify、UMG 股价）' WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND code = 'R5';

UPDATE vi_fact_base SET notes = NULL WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '付费用户 1.274 亿、ARPPU 11.9 元，月活连续下滑';

UPDATE vi_fact_base SET notes = NULL WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '回购与分红：2026 年二季度回购 4 亿美元，新一轮在准备';

UPDATE vi_fact_base SET notes = '原“数值”字段：20 百万人（2025Q4），为正文数字的推算或合计' WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '管理层：竞争冲击轻度用户，超级会员稳定';

UPDATE vi_fact_base SET notes = '原“数值”字段：0.25 比率（2025Q2），为正文数字的推算或合计' WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND title = '自制音乐播放份额约 20%—30%，已超过三大唱片';

INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT c.code || '.D' || lpad((coalesce((SELECT max(substring(x.code FROM '\.D(\d+)$')::int) FROM vi_metric_base x WHERE x.code LIKE c.code || '.D%'), 0) + 1)::text, 3, '0'),
       '对外上市股权（公允价值）', '亿元', '财务', '报表计算', '时点', c.id, '财务数据（三大报表）：指定以公允价值记账之金融资产', '季', '指定以公允价值记账之金融资产'
FROM vi_company_base c WHERE c.id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND NOT EXISTS (SELECT 1 FROM vi_metric_base WHERE company_id = c.id AND name = '对外上市股权（公允价值）' AND unit IS NOT DISTINCT FROM '亿元');

INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT c.code || '.D' || lpad((coalesce((SELECT max(substring(x.code FROM '\.D(\d+)$')::int) FROM vi_metric_base x WHERE x.code LIKE c.code || '.D%'), 0) + 1)::text, 3, '0'),
       '少数股东权益', '亿元', '财务', '报表计算', '时点', c.id, '财务数据（三大报表）：少数股东权益', '季', '少数股东权益'
FROM vi_company_base c WHERE c.id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND NOT EXISTS (SELECT 1 FROM vi_metric_base WHERE company_id = c.id AND name = '少数股东权益' AND unit IS NOT DISTINCT FROM '亿元');

INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT c.code || '.D' || lpad((coalesce((SELECT max(substring(x.code FROM '\.D(\d+)$')::int) FROM vi_metric_base x WHERE x.code LIKE c.code || '.D%'), 0) + 1)::text, 3, '0'),
       '在线音乐付费用户', '百万人', '经营', '年报', '全年', c.id, '年报', '年', NULL
FROM vi_company_base c WHERE c.id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND NOT EXISTS (SELECT 1 FROM vi_metric_base WHERE company_id = c.id AND name = '在线音乐付费用户' AND unit IS NOT DISTINCT FROM '百万人');

UPDATE vi_metric_base SET model_field = 'volume' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '在线音乐付费用户' AND unit IS NOT DISTINCT FROM '百万人' ORDER BY id LIMIT 1);

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '在线音乐付费用户' AND unit IS NOT DISTINCT FROM '百万人' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2021';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '在线音乐付费用户' AND unit IS NOT DISTINCT FROM '百万人' ORDER BY id LIMIT 1), '2021-12-31', '2021', '全年', 76.2, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '在线音乐付费用户' AND unit IS NOT DISTINCT FROM '百万人' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2022';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '在线音乐付费用户' AND unit IS NOT DISTINCT FROM '百万人' ORDER BY id LIMIT 1), '2022-12-31', '2022', '全年', 88.5, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '在线音乐付费用户' AND unit IS NOT DISTINCT FROM '百万人' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2023';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '在线音乐付费用户' AND unit IS NOT DISTINCT FROM '百万人' ORDER BY id LIMIT 1), '2023-12-31', '2023', '全年', 106.7, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '在线音乐付费用户' AND unit IS NOT DISTINCT FROM '百万人' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2024';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '在线音乐付费用户' AND unit IS NOT DISTINCT FROM '百万人' ORDER BY id LIMIT 1), '2024-12-31', '2024', '全年', 121.0, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '在线音乐付费用户' AND unit IS NOT DISTINCT FROM '百万人' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2025';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '在线音乐付费用户' AND unit IS NOT DISTINCT FROM '百万人' ORDER BY id LIMIT 1), '2025-12-31', '2025', '全年', 127.4, '历史年度原值；口径：合并口径', now());

INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT c.code || '.D' || lpad((coalesce((SELECT max(substring(x.code FROM '\.D(\d+)$')::int) FROM vi_metric_base x WHERE x.code LIKE c.code || '.D%'), 0) + 1)::text, 3, '0'),
       '营业收入', '亿元', '财务', '报表计算', '全年', c.id, '财务数据（三大报表）：营业额', '年', '营业额'
FROM vi_company_base c WHERE c.id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND NOT EXISTS (SELECT 1 FROM vi_metric_base WHERE company_id = c.id AND name = '营业收入' AND unit IS NOT DISTINCT FROM '亿元');

UPDATE vi_metric_base SET model_field = 'revenue' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '营业收入' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1);

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '营业收入' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2017';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '营业收入' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2017-12-31', '2017', '全年', 109.81, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '营业收入' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2018';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '营业收入' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2018-12-31', '2018', '全年', 189.85, '历史年度原值；口径：合并口径', now());

INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT c.code || '.D' || lpad((coalesce((SELECT max(substring(x.code FROM '\.D(\d+)$')::int) FROM vi_metric_base x WHERE x.code LIKE c.code || '.D%'), 0) + 1)::text, 3, '0'),
       '营业成本', '亿元', '财务', '报表计算', '全年', c.id, '财务数据（三大报表）：营业额 − 毛利', '年', '营业额 − 毛利'
FROM vi_company_base c WHERE c.id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND NOT EXISTS (SELECT 1 FROM vi_metric_base WHERE company_id = c.id AND name = '营业成本' AND unit IS NOT DISTINCT FROM '亿元');

UPDATE vi_metric_base SET model_field = 'cost_of_sales' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '营业成本' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1);

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '营业成本' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2017';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '营业成本' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2017-12-31', '2017', '全年', 71.71, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '营业成本' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2018';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '营业成本' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2018-12-31', '2018', '全年', 117.08, '历史年度原值；口径：合并口径', now());

INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT c.code || '.D' || lpad((coalesce((SELECT max(substring(x.code FROM '\.D(\d+)$')::int) FROM vi_metric_base x WHERE x.code LIKE c.code || '.D%'), 0) + 1)::text, 3, '0'),
       '利润总额', '亿元', '财务', '报表计算', '全年', c.id, '财务数据（三大报表）：除税前溢利', '年', '除税前溢利'
FROM vi_company_base c WHERE c.id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND NOT EXISTS (SELECT 1 FROM vi_metric_base WHERE company_id = c.id AND name = '利润总额' AND unit IS NOT DISTINCT FROM '亿元');

UPDATE vi_metric_base SET model_field = 'pretax_profit' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '利润总额' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1);

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '利润总额' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2017';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '利润总额' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2017-12-31', '2017', '全年', 15.97, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '利润总额' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2018';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '利润总额' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2018-12-31', '2018', '全年', 20.03, '历史年度原值；口径：合并口径', now());

INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT c.code || '.D' || lpad((coalesce((SELECT max(substring(x.code FROM '\.D(\d+)$')::int) FROM vi_metric_base x WHERE x.code LIKE c.code || '.D%'), 0) + 1)::text, 3, '0'),
       '所得税', '亿元', '财务', '报表计算', '全年', c.id, '财务数据（三大报表）：税项', '年', '税项'
FROM vi_company_base c WHERE c.id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND NOT EXISTS (SELECT 1 FROM vi_metric_base WHERE company_id = c.id AND name = '所得税' AND unit IS NOT DISTINCT FROM '亿元');

UPDATE vi_metric_base SET model_field = 'income_tax' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '所得税' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1);

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '所得税' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2017';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '所得税' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2017-12-31', '2017', '全年', 2.78, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '所得税' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2018';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '所得税' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2018-12-31', '2018', '全年', 1.71, '历史年度原值；口径：合并口径', now());

INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT c.code || '.D' || lpad((coalesce((SELECT max(substring(x.code FROM '\.D(\d+)$')::int) FROM vi_metric_base x WHERE x.code LIKE c.code || '.D%'), 0) + 1)::text, 3, '0'),
       '归母净利润', '亿元', '财务', '报表计算', '全年', c.id, '财务数据（三大报表）：股东应占溢利', '年', '股东应占溢利'
FROM vi_company_base c WHERE c.id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND NOT EXISTS (SELECT 1 FROM vi_metric_base WHERE company_id = c.id AND name = '归母净利润' AND unit IS NOT DISTINCT FROM '亿元');

UPDATE vi_metric_base SET model_field = 'np_parent' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '归母净利润' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1);

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '归母净利润' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2017';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '归母净利润' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2017-12-31', '2017', '全年', 13.26, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '归母净利润' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2018';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '归母净利润' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2018-12-31', '2018', '全年', 18.33, '历史年度原值；口径：合并口径', now());

INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT c.code || '.D' || lpad((coalesce((SELECT max(substring(x.code FROM '\.D(\d+)$')::int) FROM vi_metric_base x WHERE x.code LIKE c.code || '.D%'), 0) + 1)::text, 3, '0'),
       '少数股东损益', '亿元', '财务', '报表计算', '全年', c.id, '财务数据（三大报表）：少数股东损益', '年', '少数股东损益'
FROM vi_company_base c WHERE c.id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND NOT EXISTS (SELECT 1 FROM vi_metric_base WHERE company_id = c.id AND name = '少数股东损益' AND unit IS NOT DISTINCT FROM '亿元');

UPDATE vi_metric_base SET model_field = 'minority_profit' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '少数股东损益' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1);

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '少数股东损益' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2017';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '少数股东损益' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2017-12-31', '2017', '全年', -0.07, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '少数股东损益' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2018';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '少数股东损益' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2018-12-31', '2018', '全年', -0.01, '历史年度原值；口径：合并口径', now());

INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT c.code || '.D' || lpad((coalesce((SELECT max(substring(x.code FROM '\.D(\d+)$')::int) FROM vi_metric_base x WHERE x.code LIKE c.code || '.D%'), 0) + 1)::text, 3, '0'),
       '折旧摊销', '亿元', '财务', '报表计算', '全年', c.id, '财务数据（三大报表）：加:折旧及摊销', '年', '加:折旧及摊销'
FROM vi_company_base c WHERE c.id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND NOT EXISTS (SELECT 1 FROM vi_metric_base WHERE company_id = c.id AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元');

UPDATE vi_metric_base SET model_field = 'da' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1);

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2017';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2017-12-31', '2017', '全年', 3.79, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2018';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2018-12-31', '2018', '全年', 3.69, '历史年度原值；口径：合并口径', now());

INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT c.code || '.D' || lpad((coalesce((SELECT max(substring(x.code FROM '\.D(\d+)$')::int) FROM vi_metric_base x WHERE x.code LIKE c.code || '.D%'), 0) + 1)::text, 3, '0'),
       '财务费用', '亿元', '财务', '报表计算', '全年', c.id, '财务数据（三大报表）：融资成本', '年', '融资成本'
FROM vi_company_base c WHERE c.id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND NOT EXISTS (SELECT 1 FROM vi_metric_base WHERE company_id = c.id AND name = '财务费用' AND unit IS NOT DISTINCT FROM '亿元');

UPDATE vi_metric_base SET model_field = 'finance_cost' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '财务费用' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1);

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '财务费用' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2018';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '财务费用' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2018-12-31', '2018', '全年', 0.35, '历史年度原值；口径：合并口径', now());

INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT c.code || '.D' || lpad((coalesce((SELECT max(substring(x.code FROM '\.D(\d+)$')::int) FROM vi_metric_base x WHERE x.code LIKE c.code || '.D%'), 0) + 1)::text, 3, '0'),
       '投资收益', '亿元', '财务', '年报', '全年', c.id, '年报', '年', NULL
FROM vi_company_base c WHERE c.id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND NOT EXISTS (SELECT 1 FROM vi_metric_base WHERE company_id = c.id AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元');

UPDATE vi_metric_base SET model_field = 'invest_income' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1);

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2017';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2017-12-31', '2017', '全年', 2.17, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2018';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2018-12-31', '2018', '全年', -12.66, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2019';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2019-12-31', '2019', '全年', 6.93, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2020';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2020-12-31', '2020', '全年', 9.84, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2021';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2021-12-31', '2021', '全年', 10.83, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2022';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2022-12-31', '2022', '全年', 12.27, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2023';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2023-12-31', '2023', '全年', 12.82, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2024';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2024-12-31', '2024', '全年', 13.61, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2025';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2025-12-31', '2025', '全年', 36.86, '历史年度原值；口径：合并口径', now());

INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT c.code || '.D' || lpad((coalesce((SELECT max(substring(x.code FROM '\.D(\d+)$')::int) FROM vi_metric_base x WHERE x.code LIKE c.code || '.D%'), 0) + 1)::text, 3, '0'),
       '权益法投资收益', '亿元', '财务', '报表计算', '全年', c.id, '财务数据（三大报表）：应占联营公司溢利', '年', '应占联营公司溢利'
FROM vi_company_base c WHERE c.id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND NOT EXISTS (SELECT 1 FROM vi_metric_base WHERE company_id = c.id AND name = '权益法投资收益' AND unit IS NOT DISTINCT FROM '亿元');

UPDATE vi_metric_base SET model_field = 'equity_income' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '权益法投资收益' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1);

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '权益法投资收益' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2017';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '权益法投资收益' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2017-12-31', '2017', '全年', 0.04, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '权益法投资收益' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2018';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '权益法投资收益' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2018-12-31', '2018', '全年', -0.01, '历史年度原值；口径：合并口径', now());

INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT c.code || '.D' || lpad((coalesce((SELECT max(substring(x.code FROM '\.D(\d+)$')::int) FROM vi_metric_base x WHERE x.code LIKE c.code || '.D%'), 0) + 1)::text, 3, '0'),
       '经营活动现金流量净额', '亿元', '财务', '报表计算', '全年', c.id, '财务数据（三大报表）：经营业务现金净额', '年', '经营业务现金净额'
FROM vi_company_base c WHERE c.id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND NOT EXISTS (SELECT 1 FROM vi_metric_base WHERE company_id = c.id AND name = '经营活动现金流量净额' AND unit IS NOT DISTINCT FROM '亿元');

UPDATE vi_metric_base SET model_field = 'cfo' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '经营活动现金流量净额' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1);

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '经营活动现金流量净额' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2017';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '经营活动现金流量净额' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2017-12-31', '2017', '全年', 25, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '经营活动现金流量净额' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2018';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '经营活动现金流量净额' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2018-12-31', '2018', '全年', 56.32, '历史年度原值；口径：合并口径', now());

INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT c.code || '.D' || lpad((coalesce((SELECT max(substring(x.code FROM '\.D(\d+)$')::int) FROM vi_metric_base x WHERE x.code LIKE c.code || '.D%'), 0) + 1)::text, 3, '0'),
       '资本开支', '亿元', '财务', '报表计算', '全年', c.id, '财务数据（三大报表）：购建固定资产 + 购建无形资产及其他资产', '年', '购建固定资产 + 购建无形资产及其他资产'
FROM vi_company_base c WHERE c.id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND NOT EXISTS (SELECT 1 FROM vi_metric_base WHERE company_id = c.id AND name = '资本开支' AND unit IS NOT DISTINCT FROM '亿元');

UPDATE vi_metric_base SET model_field = 'capex' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '资本开支' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1);

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '资本开支' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2017';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '资本开支' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2017-12-31', '2017', '全年', 1.38, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '资本开支' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2018';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '资本开支' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2018-12-31', '2018', '全年', 4.83, '历史年度原值；口径：合并口径', now());

INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT c.code || '.D' || lpad((coalesce((SELECT max(substring(x.code FROM '\.D(\d+)$')::int) FROM vi_metric_base x WHERE x.code LIKE c.code || '.D%'), 0) + 1)::text, 3, '0'),
       '收到投资分红', '亿元', '财务', '报表计算', '全年', c.id, '财务数据（三大报表）：已收股息(投资)', '年', '已收股息(投资)'
FROM vi_company_base c WHERE c.id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND NOT EXISTS (SELECT 1 FROM vi_metric_base WHERE company_id = c.id AND name = '收到投资分红' AND unit IS NOT DISTINCT FROM '亿元');

UPDATE vi_metric_base SET model_field = 'investee_cash_div' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '收到投资分红' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1);

INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT c.code || '.D' || lpad((coalesce((SELECT max(substring(x.code FROM '\.D(\d+)$')::int) FROM vi_metric_base x WHERE x.code LIKE c.code || '.D%'), 0) + 1)::text, 3, '0'),
       '净借款', '亿元', '财务', '年报', '全年', c.id, '年报', '年', NULL
FROM vi_company_base c WHERE c.id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND NOT EXISTS (SELECT 1 FROM vi_metric_base WHERE company_id = c.id AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元');

UPDATE vi_metric_base SET model_field = 'net_borrowing' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1);

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2017';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2017-12-31', '2017', '全年', 0, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2018';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2018-12-31', '2018', '全年', 0, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2019';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2019-12-31', '2019', '全年', 0, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2020';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2020-12-31', '2020', '全年', 54, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2021';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2021-12-31', '2021', '全年', 0, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2022';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2022-12-31', '2022', '全年', 0, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2023';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2023-12-31', '2023', '全年', 0, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2024';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2024-12-31', '2024', '全年', 0, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2025';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2025-12-31', '2025', '全年', -21.31, '历史年度原值；口径：合并口径', now());

INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT c.code || '.D' || lpad((coalesce((SELECT max(substring(x.code FROM '\.D(\d+)$')::int) FROM vi_metric_base x WHERE x.code LIKE c.code || '.D%'), 0) + 1)::text, 3, '0'),
       '带息负债（借款＋票据＋租赁）', '亿元', '财务', '报表计算', '时点', c.id, '财务数据（三大报表）：短期贷款 + 长期贷款 + 应付票据 + 应付票据(非流动) + 融资租赁负债(流动) + 融资租赁负债(非流动)', '年', '短期贷款 + 长期贷款 + 应付票据 + 应付票据(非流动) + 融资租赁负债(流动) + 融资租赁负债(非流动)'
FROM vi_company_base c WHERE c.id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND NOT EXISTS (SELECT 1 FROM vi_metric_base WHERE company_id = c.id AND name = '带息负债（借款＋票据＋租赁）' AND unit IS NOT DISTINCT FROM '亿元');

UPDATE vi_metric_base SET model_field = 'interest_debt' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '带息负债（借款＋票据＋租赁）' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1);

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '带息负债（借款＋票据＋租赁）' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '时点' AND period = '2017Q4';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '带息负债（借款＋票据＋租赁）' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2017-12-31', '2017Q4', '时点', 0, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '带息负债（借款＋票据＋租赁）' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '时点' AND period = '2018Q4';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '带息负债（借款＋票据＋租赁）' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2018-12-31', '2018Q4', '时点', 0, '历史年度原值；口径：合并口径', now());

INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT c.code || '.D' || lpad((coalesce((SELECT max(substring(x.code FROM '\.D(\d+)$')::int) FROM vi_metric_base x WHERE x.code LIKE c.code || '.D%'), 0) + 1)::text, 3, '0'),
       '货币资金', '亿元', '财务', '报表计算', '时点', c.id, '财务数据（三大报表）：现金及等价物 + 短期存款 + 中长期存款', '年', '现金及等价物 + 短期存款 + 中长期存款'
FROM vi_company_base c WHERE c.id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND NOT EXISTS (SELECT 1 FROM vi_metric_base WHERE company_id = c.id AND name = '货币资金' AND unit IS NOT DISTINCT FROM '亿元');

UPDATE vi_metric_base SET model_field = 'cash' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '货币资金' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1);

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '货币资金' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '时点' AND period = '2017Q4';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '货币资金' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2017-12-31', '2017Q4', '时点', 64.8, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '货币资金' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '时点' AND period = '2018Q4';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '货币资金' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2018-12-31', '2018Q4', '时点', 200.8, '历史年度原值；口径：合并口径', now());

INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT c.code || '.D' || lpad((coalesce((SELECT max(substring(x.code FROM '\.D(\d+)$')::int) FROM vi_metric_base x WHERE x.code LIKE c.code || '.D%'), 0) + 1)::text, 3, '0'),
       '归母净资产', '亿元', '财务', '报表计算', '时点', c.id, '财务数据（三大报表）：股东权益', '年', '股东权益'
FROM vi_company_base c WHERE c.id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND NOT EXISTS (SELECT 1 FROM vi_metric_base WHERE company_id = c.id AND name = '归母净资产' AND unit IS NOT DISTINCT FROM '亿元');

UPDATE vi_metric_base SET model_field = 'equity_parent' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '归母净资产' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1);

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '归母净资产' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '时点' AND period = '2017Q4';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '归母净资产' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2017-12-31', '2017Q4', '时点', 261.41, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '归母净资产' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '时点' AND period = '2018Q4';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '归母净资产' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2018-12-31', '2018Q4', '时点', 377.21, '历史年度原值；口径：合并口径', now());

INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT c.code || '.D' || lpad((coalesce((SELECT max(substring(x.code FROM '\.D(\d+)$')::int) FROM vi_metric_base x WHERE x.code LIKE c.code || '.D%'), 0) + 1)::text, 3, '0'),
       '现金分红总额', '亿元', '财务', '年报', '全年', c.id, '年报', '年', NULL
FROM vi_company_base c WHERE c.id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND NOT EXISTS (SELECT 1 FROM vi_metric_base WHERE company_id = c.id AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元');

UPDATE vi_metric_base SET model_field = 'dividend_total' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1);

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2017';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2017-12-31', '2017', '全年', 0, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2018';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2018-12-31', '2018', '全年', 0, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2019';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2019-12-31', '2019', '全年', 0, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2020';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2020-12-31', '2020', '全年', 1.34, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2021';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2021-12-31', '2021', '全年', 34.79, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2022';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2022-12-31', '2022', '全年', 31.27, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2023';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2023-12-31', '2023', '全年', 28.25, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2024';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2024-12-31', '2024', '全年', 39.6, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2025';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2025-12-31', '2025', '全年', 29.11, '历史年度原值；口径：合并口径', now());

INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT c.code || '.D' || lpad((coalesce((SELECT max(substring(x.code FROM '\.D(\d+)$')::int) FROM vi_metric_base x WHERE x.code LIKE c.code || '.D%'), 0) + 1)::text, 3, '0'),
       '每股股息', '元', '财务', '年报', '全年', c.id, '年报', '年', NULL
FROM vi_company_base c WHERE c.id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND NOT EXISTS (SELECT 1 FROM vi_metric_base WHERE company_id = c.id AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元');

UPDATE vi_metric_base SET model_field = 'dps' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元' ORDER BY id LIMIT 1);

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2017';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元' ORDER BY id LIMIT 1), '2017-12-31', '2017', '全年', 0, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2018';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元' ORDER BY id LIMIT 1), '2018-12-31', '2018', '全年', 0, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2019';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元' ORDER BY id LIMIT 1), '2019-12-31', '2019', '全年', 0, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2020';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元' ORDER BY id LIMIT 1), '2020-12-31', '2020', '全年', 0, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2021';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元' ORDER BY id LIMIT 1), '2021-12-31', '2021', '全年', 0, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2022';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元' ORDER BY id LIMIT 1), '2022-12-31', '2022', '全年', 0, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2023';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元' ORDER BY id LIMIT 1), '2023-12-31', '2023', '全年', 0.5, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2024';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元' ORDER BY id LIMIT 1), '2024-12-31', '2024', '全年', 0.65, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2025';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元' ORDER BY id LIMIT 1), '2025-12-31', '2025', '全年', 0.82, '历史年度原值；口径：合并口径', now());

UPDATE vi_sotp_item_base SET metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '现金、定期存款和短期投资' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), amount = NULL WHERE model_id IN (SELECT id FROM vi_model_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK')) AND code = 'C1' AND scenario_id IS NULL;

UPDATE vi_sotp_item_base SET metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '带息负债（借款＋票据＋租赁）' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), amount = NULL WHERE model_id IN (SELECT id FROM vi_model_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK')) AND code = 'C2' AND scenario_id IS NULL;

UPDATE vi_sotp_item_base SET metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '对外上市股权（公允价值）' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), amount = NULL WHERE model_id IN (SELECT id FROM vi_model_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK')) AND code = 'C5' AND scenario_id IS NULL;

UPDATE vi_sotp_item_base SET metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND name = '少数股东权益' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), amount = NULL WHERE model_id IN (SELECT id FROM vi_model_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK')) AND code = 'C8' AND scenario_id IS NULL;

COMMIT;
