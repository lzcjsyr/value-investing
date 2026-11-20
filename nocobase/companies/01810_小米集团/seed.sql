BEGIN;

INSERT INTO vi_company_base (code, name, exchange, industry, currency, volume_label, volume_unit, price_label, price_unit, is_default, profile, notes)
VALUES ('01810.HK', '小米集团', '香港联交所（01810 港币柜台、81810 人民币柜台）', '消费电子、智能电动汽车与互联网服务', '人民币',
        '全球月活跃用户（年末，含手机与平板）', '亿人',
        '每月活用户年收入（集团收入÷年末月活）', '元/人/年（含手机、IoT、互联网、汽车与 AI 收入）', FALSE, '全球第三大智能手机厂商（2025 年出货 1.652 亿台，份额 13.3%），也是“手机×AIoT＋智能电动汽车”的消费电子与汽车集团。2025 年收入 4,572.9 亿元（+25.0%）：手机×AIoT 分部 3,512.2 亿元（手机 1,864.4、IoT 与生活消费产品 1,232.0、互联网服务 374.4、其他 41.4），智能电动汽车及 AI 等创新业务分部 1,060.7 亿元（汽车 1,033 亿元，交付 41.1 万辆）。国际财务报告准则归母净利 416.4 亿元（含投资公允价值收益 133.1 亿元），经调整净利润 391.7 亿元。
怎么赚钱：硬件按接近成本定价获客（手机毛利率约 11%，2026 年存储涨价后降到 8.5%），靠 7.67 亿月活用户的互联网服务（广告、游戏、金融科技，毛利率约 76%）赚取大部分利润；IoT 与大家电（毛利率 20%—25%）扩大单用户收入；汽车 2024 年起交付，2025 年分部首次全年盈利 9 亿元，2026 年因 AI 投入与价格下降转为亏损。
本质：一个用“性价比硬件＋自有渠道”获取用户、用互联网服务变现的生态平台，正在用手机业务的现金和 2,193 亿元现金储备投资汽车与 AI。价值取决于四件事：存储周期过后手机毛利率能回到多少、IoT 的结构升级能否保住；互联网能否随月活继续增长；汽车能否在 50 万辆以上规模稳定盈利；AI 值多少（估值按主观判断 1,000 亿元；三年投入超 600 亿元）。', '主要风险：存储等核心器件涨价（低端机型存储占物料成本 60% 以上）；国内手机份额被华为、苹果挤压；国补退坡后 IoT 需求回落；汽车行业价格战与 50 万辆规模门槛；AI、芯片、机器人投入回报不确定；投资组合（约 410 家公司）公允价值波动；印度税务与外汇调查（约 35 亿元资金被冻结）；同股不同权（雷军控制投票权）；港元报价与人民币记账之间的汇率。')
ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, exchange = EXCLUDED.exchange, industry = EXCLUDED.industry,
  currency = EXCLUDED.currency, volume_label = EXCLUDED.volume_label, volume_unit = EXCLUDED.volume_unit,
  price_label = EXCLUDED.price_label, price_unit = EXCLUDED.price_unit, profile = EXCLUDED.profile, notes = EXCLUDED.notes;

INSERT INTO vi_metric_base (code, name, unit, category, company_id, source_name, frequency, valid_min, valid_max, notes)
VALUES ('01810.HK.PRICE', '小米集团港股收盘价', '港元', '行情', (SELECT id FROM vi_company_base WHERE code = '01810.HK'), '腾讯行情（自动采集）；2025-10-20—2026-10-22 日线由腾讯 K 线接口一次性补齐（不复权）',
        '交易日', 3, 200, '港元报价（港币柜台 01810）。估值比较时按“港元兑人民币”指标折成人民币。股价只进入对比层，不进入经营假设。')
ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, unit = EXCLUDED.unit, category = EXCLUDED.category, company_id = EXCLUDED.company_id,
  source_name = EXCLUDED.source_name, frequency = EXCLUDED.frequency, valid_min = EXCLUDED.valid_min, valid_max = EXCLUDED.valid_max, notes = EXCLUDED.notes;

UPDATE vi_company_base SET price_metric_id = (SELECT id FROM vi_metric_base WHERE code = '01810.HK.PRICE'),
  price_fx_metric_id = (SELECT id FROM vi_metric_base WHERE code = 'HKDCNY') WHERE code = '01810.HK';

INSERT INTO vi_collector_base (name, metric_id, url, parser, parser_param, enabled, max_lag_days, notes)
SELECT '小米集团港股股价（腾讯行情）', (SELECT id FROM vi_metric_base WHERE code = '01810.HK.PRICE'), 'https://qt.gtimg.cn/q=hk01810', 'tencent_quote', 'hk01810', TRUE, 7, '返回 GBK 编码；港股日期格式为 2026/10/22 16:08:42，解析器只取数字。港股收盘约 16:10，之前采集到的是盘中价。'
WHERE NOT EXISTS (SELECT 1 FROM vi_collector_base WHERE name = '小米集团港股股价（腾讯行情）');
UPDATE vi_collector_base SET metric_id = (SELECT id FROM vi_metric_base WHERE code = '01810.HK.PRICE'), url = 'https://qt.gtimg.cn/q=hk01810', parser = 'tencent_quote', parser_param = 'hk01810',
  max_lag_days = 7, notes = '返回 GBK 编码；港股日期格式为 2026/10/22 16:08:42，解析器只取数字。港股收盘约 16:10，之前采集到的是盘中价。' WHERE name = '小米集团港股股价（腾讯行情）';

DELETE FROM vi_fit_score_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK');
DELETE FROM vi_moat_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK');
DELETE FROM vi_competitor_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK');
DELETE FROM vi_value_chain_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK');
DELETE FROM vi_biz_model_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK');
DELETE FROM vi_issue_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK');
DELETE FROM vi_change_log_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK');
DELETE FROM vi_judgment_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK');
DELETE FROM vi_fact_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK');
DELETE FROM vi_thesis_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK');
DELETE FROM vi_observation_base WHERE metric_id IN (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND source_kind = '公司披露');
DELETE FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK');

INSERT INTO vi_source_base (company_id, title, source_type, url, reliability, verify_status, summary, limitations) SELECT (SELECT id FROM vi_company_base WHERE code = '01810.HK'), '小米集团港股收盘价：腾讯 K 线收盘价（港元，不复权）（2025—2026 年历史数据）', '数据库取数', 'https://web.ifzq.gtimg.cn/appstock/app/fqkline/get?param=hk01810,day（不复权日线）', '三级·第三方数据', '待核验', '历史日线收盘价', '历史补数：腾讯 K 线收盘价（港元，不复权）' WHERE NOT EXISTS (SELECT 1 FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '小米集团港股收盘价：腾讯 K 线收盘价（港元，不复权）（2025—2026 年历史数据）');

INSERT INTO vi_observation_base (metric_id, obs_date, value, collected_at, doc_id)
SELECT (SELECT id FROM vi_metric_base WHERE code = '01810.HK.PRICE'), v.d, v.x, '2026-10-23T02:00:00+08:00', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '小米集团港股收盘价：腾讯 K 线收盘价（港元，不复权）（2025—2026 年历史数据）')
FROM (VALUES
('2025-10-20'::date, 47.14),
('2025-10-21'::date, 46.46),
('2025-10-22'::date, 46.34),
('2025-10-23'::date, 46.74),
('2025-10-24'::date, 45.92),
('2025-10-27'::date, 45.8),
('2025-10-28'::date, 44.92),
('2025-10-30'::date, 44.16),
('2025-10-31'::date, 43.2),
('2025-11-03'::date, 44.72),
('2025-11-04'::date, 43.42),
('2025-11-05'::date, 43.32),
('2025-11-06'::date, 43.44),
('2025-11-07'::date, 42.24),
('2025-11-10'::date, 42.36),
('2025-11-11'::date, 42.98),
('2025-11-12'::date, 43.7),
('2025-11-13'::date, 43.5),
('2025-11-14'::date, 42.36),
('2025-11-17'::date, 41.96),
('2025-11-18'::date, 40.78),
('2025-11-19'::date, 38.82),
('2025-11-20'::date, 37.7),
('2025-11-21'::date, 38.08),
('2025-11-24'::date, 38.66),
('2025-11-25'::date, 40.34),
('2025-11-26'::date, 40.1),
('2025-11-27'::date, 41.1),
('2025-11-28'::date, 41.02),
('2025-12-01'::date, 40.3),
('2025-12-02'::date, 40.7),
('2025-12-03'::date, 40.22),
('2025-12-04'::date, 41.98),
('2025-12-05'::date, 42.78),
('2025-12-08'::date, 42.58),
('2025-12-09'::date, 41.26),
('2025-12-10'::date, 41.78),
('2025-12-11'::date, 42.18),
('2025-12-12'::date, 42.96),
('2025-12-15'::date, 41.84),
('2025-12-16'::date, 40.9),
('2025-12-17'::date, 41.22),
('2025-12-18'::date, 40.2),
('2025-12-19'::date, 40.54),
('2025-12-22'::date, 39.8),
('2025-12-23'::date, 39.2),
('2025-12-24'::date, 39.22),
('2025-12-29'::date, 38.58),
('2025-12-30'::date, 39.36),
('2025-12-31'::date, 39.3),
('2026-01-02'::date, 40.28),
('2026-01-05'::date, 39.34),
('2026-01-06'::date, 38.76),
('2026-01-07'::date, 38.16),
('2026-01-08'::date, 38.02),
('2026-01-09'::date, 37.82),
('2026-01-12'::date, 38.74),
('2026-01-13'::date, 37.98),
('2026-01-14'::date, 37.78),
('2026-01-15'::date, 37.86),
('2026-01-16'::date, 37.1),
('2026-01-19'::date, 36.48),
('2026-01-20'::date, 35.48),
('2026-01-21'::date, 35.42),
('2026-01-22'::date, 35.24),
('2026-01-23'::date, 36.24),
('2026-01-26'::date, 35.22),
('2026-01-27'::date, 35.56),
('2026-01-28'::date, 36.32),
('2026-01-29'::date, 36.62),
('2026-01-30'::date, 35.5),
('2026-02-02'::date, 35.06),
('2026-02-03'::date, 34.6),
('2026-02-04'::date, 33.96),
('2026-02-05'::date, 34.92),
('2026-02-06'::date, 35.18),
('2026-02-09'::date, 35.2),
('2026-02-10'::date, 35.58),
('2026-02-11'::date, 37.1),
('2026-02-12'::date, 36.52),
('2026-02-13'::date, 36.84),
('2026-02-16'::date, 36.66),
('2026-02-20'::date, 35.36),
('2026-02-23'::date, 36.56),
('2026-02-24'::date, 35.74),
('2026-02-25'::date, 35.6),
('2026-02-26'::date, 35.18),
('2026-02-27'::date, 34.9),
('2026-03-02'::date, 33.14),
('2026-03-03'::date, 31.58),
('2026-03-04'::date, 32.0),
('2026-03-05'::date, 32.2),
('2026-03-06'::date, 33.42),
('2026-03-09'::date, 33.68),
('2026-03-10'::date, 33.62),
('2026-03-11'::date, 33.34),
('2026-03-12'::date, 33.3),
('2026-03-13'::date, 33.32),
('2026-03-16'::date, 35.2),
('2026-03-17'::date, 35.36),
('2026-03-18'::date, 35.14),
('2026-03-19'::date, 36.32),
('2026-03-20'::date, 33.2),
('2026-03-23'::date, 32.06),
('2026-03-24'::date, 32.68),
('2026-03-25'::date, 32.52),
('2026-03-26'::date, 32.44),
('2026-03-27'::date, 33.0),
('2026-03-30'::date, 32.38),
('2026-03-31'::date, 31.76),
('2026-04-01'::date, 32.02),
('2026-04-02'::date, 30.88),
('2026-04-08'::date, 32.76),
('2026-04-09'::date, 31.36),
('2026-04-10'::date, 30.9),
('2026-04-13'::date, 30.66),
('2026-04-14'::date, 30.88),
('2026-04-15'::date, 30.9),
('2026-04-16'::date, 32.06),
('2026-04-17'::date, 32.0),
('2026-04-20'::date, 32.32),
('2026-04-21'::date, 32.4),
('2026-04-22'::date, 31.8),
('2026-04-23'::date, 31.18),
('2026-04-24'::date, 31.2),
('2026-04-27'::date, 31.1),
('2026-04-28'::date, 29.92),
('2026-04-29'::date, 30.14),
('2026-04-30'::date, 29.02),
('2026-05-04'::date, 30.98),
('2026-05-05'::date, 30.46),
('2026-05-06'::date, 30.82),
('2026-05-07'::date, 31.12),
('2026-05-08'::date, 31.68),
('2026-05-11'::date, 31.7),
('2026-05-12'::date, 31.46),
('2026-05-13'::date, 31.8),
('2026-05-14'::date, 31.72),
('2026-05-15'::date, 30.7),
('2026-05-18'::date, 30.66),
('2026-05-19'::date, 30.64),
('2026-05-20'::date, 30.14),
('2026-05-21'::date, 29.66),
('2026-05-22'::date, 30.0),
('2026-05-26'::date, 29.76),
('2026-05-27'::date, 28.4),
('2026-05-28'::date, 28.56),
('2026-05-29'::date, 28.04),
('2026-06-01'::date, 28.72),
('2026-06-02'::date, 29.62),
('2026-06-03'::date, 28.58),
('2026-06-04'::date, 28.38),
('2026-06-05'::date, 27.8),
('2026-06-08'::date, 27.38),
('2026-06-09'::date, 27.2),
('2026-06-10'::date, 26.32),
('2026-06-11'::date, 25.84),
('2026-06-12'::date, 26.2),
('2026-06-15'::date, 26.26),
('2026-06-16'::date, 25.66),
('2026-06-17'::date, 25.42),
('2026-06-18'::date, 24.58),
('2026-06-22'::date, 23.72),
('2026-06-23'::date, 22.62),
('2026-06-24'::date, 22.96),
('2026-06-25'::date, 22.3),
('2026-06-26'::date, 21.42),
('2026-06-29'::date, 21.86),
('2026-06-30'::date, 21.64),
('2026-07-02'::date, 22.6),
('2026-07-03'::date, 22.96),
('2026-07-06'::date, 23.28),
('2026-07-07'::date, 23.1),
('2026-07-08'::date, 25.3),
('2026-07-09'::date, 25.0),
('2026-07-10'::date, 25.84),
('2026-07-13'::date, 25.84),
('2026-07-14'::date, 26.04),
('2026-07-15'::date, 25.86),
('2026-07-16'::date, 27.5),
('2026-07-17'::date, 26.88),
('2026-07-20'::date, 27.74),
('2026-07-21'::date, 27.42),
('2026-07-22'::date, 26.68),
('2026-07-23'::date, 27.14),
('2026-07-24'::date, 26.72),
('2026-07-27'::date, 28.68),
('2026-07-28'::date, 29.26),
('2026-07-29'::date, 31.88),
('2026-07-30'::date, 31.04),
('2026-07-31'::date, 28.78),
('2026-08-03'::date, 27.96),
('2026-08-04'::date, 27.96),
('2026-08-05'::date, 27.64),
('2026-08-06'::date, 26.86),
('2026-08-07'::date, 27.06),
('2026-08-10'::date, 27.62),
('2026-08-11'::date, 26.66),
('2026-08-12'::date, 26.36),
('2026-08-13'::date, 25.88),
('2026-08-14'::date, 25.62),
('2026-08-17'::date, 25.88),
('2026-08-18'::date, 26.18),
('2026-08-19'::date, 27.44),
('2026-08-20'::date, 27.76),
('2026-08-21'::date, 29.02),
('2026-08-24'::date, 27.82),
('2026-08-25'::date, 27.76),
('2026-08-26'::date, 28.46),
('2026-08-27'::date, 27.48),
('2026-08-28'::date, 27.82),
('2026-08-31'::date, 27.62),
('2026-09-01'::date, 27.56),
('2026-09-02'::date, 28.06),
('2026-09-03'::date, 27.44),
('2026-09-04'::date, 28.44),
('2026-09-07'::date, 27.5),
('2026-09-08'::date, 26.92),
('2026-09-09'::date, 26.38),
('2026-09-10'::date, 25.92),
('2026-09-11'::date, 26.36),
('2026-09-14'::date, 27.16),
('2026-09-15'::date, 26.5),
('2026-09-16'::date, 26.18),
('2026-09-17'::date, 26.14),
('2026-09-18'::date, 26.4),
('2026-09-21'::date, 27.58),
('2026-09-22'::date, 27.2),
('2026-09-23'::date, 26.18),
('2026-09-24'::date, 26.58),
('2026-09-25'::date, 25.9),
('2026-09-28'::date, 25.86),
('2026-09-29'::date, 25.2),
('2026-09-30'::date, 25.24),
('2026-10-02'::date, 24.24),
('2026-10-05'::date, 23.88),
('2026-10-06'::date, 24.26),
('2026-10-07'::date, 23.94),
('2026-10-08'::date, 23.66),
('2026-10-09'::date, 25.96),
('2026-10-12'::date, 24.52),
('2026-10-13'::date, 25.04),
('2026-10-14'::date, 26.38),
('2026-10-15'::date, 27.08),
('2026-10-16'::date, 26.66),
('2026-10-20'::date, 27.06),
('2026-10-21'::date, 26.8),
('2026-10-22'::date, 25.8)) v(d, x)
WHERE NOT EXISTS (SELECT 1 FROM vi_observation_base o WHERE o.metric_id = (SELECT id FROM vi_metric_base WHERE code = '01810.HK.PRICE') AND o.obs_date = v.d);

UPDATE vi_observation_base SET doc_id = (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '小米集团港股收盘价：腾讯 K 线收盘价（港元，不复权）（2025—2026 年历史数据）') WHERE doc_id IS NULL AND raw_capture_id IS NULL AND metric_id = (SELECT price_metric_id FROM vi_company_base WHERE code = '01810.HK');

INSERT INTO vi_source_base (company_id, title, source_type, publisher, publish_date, url, reliability, verify_status, retrieved_on, summary, limitations) VALUES
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026 年第二季度及中期业绩公告（2026-08-18）', '定期报告', '小米集团', '2026-08-18', 'https://www.hkexnews.hk/', '一级·法定披露', '已读原文', '2026-10-23', '二季度收入 1,089.2 亿元（−6.1%）、毛利率 19.8%、经调整净利润 62.2 亿元（−42.6%）；手机出货 3,120 万台、ASP 1,351 元、毛利率 8.5%；IoT 312.8 亿元（−19.2%）；互联网 90.4 亿元、毛利率 76.8%；汽车及 AI 分部收入 249.0 亿元、交付 104,199 辆、毛利率 19.2%、经营亏损 26 亿元；6 月末现金储备 2,193 亿元、借款 393 亿元；投资约 410 家公司、账面 920 亿元；资产负债表与投资、借款附注；年初至 8 月 13 日回购 3.775 亿股、116.7 亿港元。', '经岗底斯取得港交所公告原文（PDF 转文本后逐项读取）。岗底斯 file-id 86101067。'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026 年第一季度业绩公告（2026-05-26）', '定期报告', '小米集团', '2026-05-26', 'https://www.hkexnews.hk/', '一级·法定披露', '已读原文', '2026-10-23', '一季度收入 991.4 亿元（−10.9%）、经调整净利润 60.7 亿元；手机出货 3,380 万台、ASP 1,310 元、毛利率 10.1%；汽车交付 80,856 辆、分部经营亏损 31 亿元；“手机×AIoT”分部营业费用率 14.9%；3 月末现金储备 2,206 亿元。', '经岗底斯取得港交所公告原文（PDF 转文本后逐项读取）。岗底斯 file-id 25759388。'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025 年全年业绩公告（2026-03-24）', '定期报告', '小米集团', '2026-03-24', 'https://www.hkexnews.hk/', '一级·法定披露', '已读原文', '2026-10-23', '2025 年收入 4,572.9 亿元、毛利 1,018.1 亿元、经营利润 479.0 亿元、经调整净利润 391.7 亿元；分部收入与毛利、手机/IoT/互联网/汽车分项；汽车交付 411,082 辆、ASP 251,171 元；汽车及 AI 分部经营收益 9 亿元、经营开支 248 亿元（2024 年 132 亿元）；研发 331 亿元，2026—2030 年累计研发预计超 2,000 亿元；2026 年交付目标 55 万辆；2025 年回购 63 亿港元。', '经岗底斯取得港交所公告原文（PDF 转文本后逐项读取）。岗底斯 file-id 22185974。'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025 年第三季度业绩公告（2025-11-18）', '定期报告', '小米集团', '2025-11-18', 'https://www.hkexnews.hk/', '一级·法定披露', '已读原文', '2026-10-23', '三季度收入 1,131.2 亿元、经调整净利润 113.1 亿元；汽车交付 108,796 辆，分部首次单季经营盈利 7 亿元；9 月末现金储备 2,367 亿元。', '经岗底斯取得港交所公告原文（PDF 转文本后逐项读取）。岗底斯 file-id 13859057。'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025 年第二季度及中期业绩公告（2025-08-19）', '定期报告', '小米集团', '2025-08-19', 'https://www.hkexnews.hk/', '一级·法定披露', '已读原文', '2026-10-23', '二季度收入 1,159.6 亿元、经调整净利润 108.3 亿元；汽车交付 81,302 辆，分部经营亏损 3 亿元；现金储备定义（含理财投资）。', '经岗底斯取得港交所公告原文（PDF 转文本后逐项读取）。岗底斯 file-id 14021239。'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025 年第一季度业绩公告（2025-05-27）', '定期报告', '小米集团', '2025-05-27', 'https://www.hkexnews.hk/', '一级·法定披露', '已读原文', '2026-10-23', '一季度收入 1,112.9 亿元、经调整净利润 106.8 亿元；汽车交付 75,869 辆，分部经营亏损 5 亿元；含 2024 年一季度对比数。', '经岗底斯取得港交所公告原文（PDF 转文本后逐项读取）。岗底斯 file-id 14096385。'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025 年年度报告（附注：其他非流动负债、投资者负债、租赁负债、融资活动负债）', '定期报告', '小米集团', '2026-04-28', 'https://www.hkexnews.hk/', '一级·法定披露', '数值已核对', '2026-10-23', '其他非流动负债 203.9 亿元＝投资者负债 127.7＋租赁负债 36.3＋购买无形资产应付款 15.0＋递延收入 24.4；投资者负债合计 139.1 亿元（公允价值计量 60.6＋摊余成本 78.5）；租赁负债合计 57.1 亿元；融资活动现金流（回购 61.7 亿元、基金投资者分派 38.4 亿元）。', '经岗底斯知识库取得附注片段（file-id 23484054），PDF 字体编码导致全文无法直接转文本。'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026 年中期报告（附注：其他非流动负债、其他应付款项、租赁负债）', '定期报告', '小米集团', '2026-09-23', 'https://www.hkexnews.hk/', '一级·法定披露', '数值已核对', '2026-10-23', '6 月末其他非流动负债 241.5 亿元＝投资者负债 142.3＋租赁负债 34.4＋购买无形资产应付款 35.5＋递延收入 28.7；流动部分租赁负债 16.0、购买无形资产应付款 15.2 亿元。', '经岗底斯知识库取得附注片段（file-id 94165565）；全文 PDF 字体编码异常，未逐页读取。投资者负债的流动部分未披露。'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '港交所证券变动月报表（2025 年 12 月、2026 年 6 月、2026 年 9 月）', '临时公告', '小米集团', '2026-10-07', 'https://www1.hkexnews.hk/listedco/listconews/sehk/2026/0707/2026070700720_c.pdf', '一级·法定披露', '已读原文', '2026-10-23', '2026 年 6 月底：B 类 21,341,753,161 股（含 75,925,000 股已回购待注销）、A 类 4,443,616,133 股；9 月底：B 类 21,365,475,889 股（含 41,975,200 股待注销）、A 类 4,429,236,628 股；2025 年 12 月底：B 类 21,535,682,134 股（含 118,500,000 股待注销）、A 类 4,511,553,144 股。', '港交所网站直接下载（2026070700720、2026100700863、2026010700988）。'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018—2024 年全年业绩公告（分业务收入与成本、月活、出货量、创新业务费用）', '定期报告', '小米集团', '2025-03-18', 'https://www1.hkexnews.hk/listedco/listconews/sehk/2025/0318/2025031801046_c.pdf', '一级·法定披露', '数值已核对', '2026-10-23', '全球月活（12 月）：2019 年 3.096 亿（+27.9%）、2020 年 3.963 亿、2021 年 5.089 亿、2022 年 5.821 亿、2023 年 6.412 亿、2024 年 7.023 亿；手机出货 2020—2024 年；智能电动汽车等创新业务费用 2022 年 31 亿元、2023 年 67 亿元；2019—2024 年手机、IoT 与生活消费产品、互联网服务、其他的收入与销售成本（2024 年起直接披露毛利）。', '港交所网站直接下载 2019—2025 年发布的全年业绩公告；2018、2019 年出货量未取得。分业务只披露到毛利，营业费用不拆分。'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '业绩会纪要：2025 年四季度（2026-03-24）、2026 年一季度（2026-05-26）、二季度（2026-08-18）', '旧系统迁移', '小米集团（业绩会）', '2026-08-18', 'https://ir.mi.com', '三级·第三方数据', '待核验', '2026-10-23', '2025 年四季度业绩会：未来三年 AI 投入超 600 亿元，2026 年 160 亿元（当期研发费用占七成以上，其余为基础设施资本开支的摊销）；汽车及创新业务分部“也承担了大量 AI 大模型及具身智能的先期投入”；新一代 SU7 锁单用户中苹果手机用户近 60%。二季度：内存涨价超预期，预计三季度中途放缓、四季度缓涨；AI 处于大规模投入期，变现不是主要诉求。', '由岗底斯整理的纪要或第三方研报，是转述口径；关键数字需以公告核对。东吴、国泰海通、智东西等转述。'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '券商组织的产业链与专家交流纪要（光大家电 2026-10-21、财通汽车 2026-07-13、申万宏源 2026-08-20、mi 造车系列 2026-08、10）', '旧系统迁移', '光大、财通、申万宏源等券商', '2026-10-21', NULL, '三级·第三方数据', '待核验', '2026-10-23', '2026 年交付预计 46—48.5 万辆（55 万目标难完成）；澎程首月新增订单约 8.1 万台、低于公司预期约 12 万台；SU7/YU7 单车净利 2.5 万元以内、N90 1.5—2 万元、N70 1—1.3 万元（光大）；剔除 AI 后汽车单车盈利约 5,000 元、AI 全年费用约 100 亿元（财通）；手机硬件 2026 年预计亏损 80—100 亿元，IoT 净利约 160 亿元（mi 造车系列）。', '由岗底斯整理的纪要或第三方研报，是转述口径；关键数字需以公告核对。专家口径互相矛盾，只作区间参考。'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '卖方与外资：高盛业绩前瞻（2026-05）、申万宏源分部估值（2026-08）、银河证券等中报点评（2026-08）、国泰海通纪要', '旧系统迁移', '高盛、申万宏源、银河证券等', '2026-08-21', NULL, '三级·第三方数据', '待核验', '2026-10-23', '高盛（2026-05）：核心业务 EV/NOPAT 16 倍（悲观 6、乐观 20），汽车 1.6 倍市销率，目标价 41 港元（悲观 26、乐观 45）。申万宏源（2026-08）：主业 2026 年经调整净利 334 亿元×25 倍＝8,500 亿元，汽车及 AI 收入 1,173 亿元×0.7 倍＝800 亿元。银河：2026—2028 年归母 278、373、434 亿元；另一家券商（2026-08-21 中报点评，岗底斯片段未显示机构名）：291、367、447 亿元。', '由岗底斯整理的纪要或第三方研报，是转述口径；关键数字需以公告核对。'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '行业数据：Omdia 与 Counterpoint 手机出货、乘联会与车企月度交付、车企 2026 年中报毛利率汇总', '数据库取数', 'Omdia、Counterpoint、乘联会、国盛证券等', '2026-10-15', NULL, '三级·第三方数据', '待核验', '2026-10-23', '2026Q2 全球手机出货 2.72 亿部（−6%），小米 3,120 万部第三（−26%），三星 6,050 万、苹果 5,510 万；中国大陆：华为 23%、苹果 19%、OPPO/vivo 各 16%、小米 12%（820 万台，−21%）。Omdia 初步：2026Q3 小米全球份额 12%（−2pt）、中国大陆 800 万台（−20%）。2026H1 车企毛利率：比亚迪 18.8%、特斯拉 18.7%、小鹏 20.6%、零跑 11.7%、理想 9.5%、赛力斯 23.3%。9 月小米汽车交付超 4 万台、澎程 30 天锁单超 7 万台。', '第三方统计口径各异；只看趋势与相对位置。'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '东方财富港股格式三大报表（akshare 取数）', '数据库取数', '东方财富（akshare stock_financial_hk_report_em）', '2026-10-23', 'https://emweb.securities.eastmoney.com', '二级·官方统计', '数值已核对', '2026-10-23', '2018—2025 年年度与 2024—2026 年报告期三大报表；2025 年收入、毛利、经营利润、归母净利与全年业绩公告一致。', '“投资收益”栏用公允价值变动＋其他收益；分部数据不在报表里。'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '腾讯行情 K 线：小米港股日线与港元兑人民币（2025-10—2026-10）', '数据库取数', '腾讯行情', '2026-10-23', 'https://web.ifzq.gtimg.cn', '三级·第三方数据', '数值已核对', '2026-10-23', '小米港股不复权日线 248 个交易日（2025-10-20 收 47.14 港元 → 2026-10-22 收 25.80 港元，最低收盘 21.42 港元）；港元兑人民币 0.9163 → 0.8515。', '不复权；港股收盘价与港交所收市价可能有小差异。'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '研究推导：分部估值与逐年假设（2026-10-23）', '研究推导', '本研究', '2026-10-23', NULL, '研究推导', '待核验', '2026-10-23', '分部估值的每项输入（正常化利润率、汽车稳态、AI 投入、现金与投资）及 2026—2035 年逐年假设的推导，见判断表与估值模型说明。', '假设，不是事实。'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '研究推导：商业模式、产业链、竞争壁垒、多空辩论与适配度评分（2026-10-23）', '研究推导', '本研究', '2026-10-23', NULL, '研究推导', '待核验', '2026-10-23', '商业模式画布 9 项、产业链 11 个环节、竞争对手 15 家（含 6 家大模型公司，作 AI 估值参照）、候选壁垒 9 项（含伪壁垒）、多空辩论 5 场、适配度评分。岗底斯观点 PK 未调用（此前三次超时），辩论由本研究按正反证据组织。', '判断，不是事实。'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '港股行情：智谱（02513.HK）、MiniMax（00100.HK）收盘价与总股本（2026-10-22）', '数据库取数', '腾讯行情（qt.gtimg.cn），岗底斯行情交叉核对', '2026-10-22', 'https://qt.gtimg.cn/q=r_hk02513,r_hk00100', '三级·第三方数据', '数值已核对', '2026-10-23', '2026-10-22 收盘：智谱 460.8 港元、总股本 487,588,090 股（H 股 263,059,605 股）；MiniMax 160.7 港元、总股本 352,480,183 股。两家行情源的收盘价一致。近一年最高：智谱 2,980 港元、MiniMax 1,330 港元。', '总股本取腾讯行情字段，未与港交所月报表逐一核对；市值按全部股本×H 股价格计算，港元按 0.851 折人民币。'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '国内大模型公司融资与估值汇总（金圆统一证券 2026-09-30、大模型二季度复盘 2026-07-03 等，岗底斯知识库）', '旧系统迁移', '金圆统一证券、华泰证券、摩根大通等（岗底斯知识库）', '2026-09-30', NULL, '三级·第三方数据', '待核验', '2026-10-23', 'DeepSeek：2026 年 4 月首轮外部融资 500 亿元（投后超 500 亿美元），8 月第二轮投前约 5,000 亿元（约 775 亿美元）。月之暗面：2025 年 12 月投后 43 亿美元 → 2026 年 7 月 F 轮投后 350 亿美元。智谱：7 月按 1,588 港元、9 月按 714 港元配售（对应约 950、431 亿美元），两次净募资约 706 亿港元。MiniMax：7 月按 268 港元配售约 160 亿港元并发行 65 亿港元可转债（约 116 亿美元）。阶跃星辰：5 月 Pre-IPO 后约 120 亿美元。百川智能：2024 年 7 月约 28 亿美元。2026 年 7 月初测算：智谱 2026、2027 年市销率 248、96 倍，MiniMax 56、19 倍；月之暗面约 150 倍（按 ARR）；阶跃星辰约 136 倍。摩根大通（2026-04）：研发费用约为收入的 4—5 倍，很可能继续融资。', '一级市场估值来自媒体报道与研报转述，投前/投后、币种口径不完全一致。');

INSERT INTO vi_fact_base (company_id, title, category, statement, period, as_of, verify_status, source_id, notes) VALUES
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025 年收入 4,572.9 亿元，经调整净利润 391.7 亿元', '财务', '2025 年收入 4,572.87 亿元（+25.0%）、毛利 1,018.06 亿元（毛利率 22.3%）、经营利润 479.01 亿元、归母净利 416.43 亿元；经调整净利润 391.66 亿元（+43.8%）。', '2025', '2025-12-31', '已核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年全年业绩公告（2026-03-24）' LIMIT 1), '经营利润含投资公允价值收益 133.1 亿元。'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025 年分部：手机×AIoT 3,512.2 亿元（毛利率 21.7%），汽车及 AI 1,060.7 亿元（经营收益 9 亿元）', '经营', '手机×AIoT 收入 3,512.17 亿元（+5.4%）、毛利 760.42 亿元；智能电动汽车及 AI 等创新业务收入 1,060.70 亿元（+223.8%）、毛利 257.63 亿元（24.3%）、经营收益 9 亿元（首次全年转正）。', '2025', '2025-12-31', '已核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年全年业绩公告（2026-03-24）' LIMIT 1), '分部经营收益＝毛利−经营开支（含股权激励）。'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '生态（手机×AIoT）经营利润率：2024 年 8.6%、2025 年 7.9%、2026 年上半年 6.7%', '经营', '由公告推算：生态经营利润＝分部毛利−(集团研发、销售、行政费用−汽车及 AI 分部经营开支)。2024 年 705.1−(550.4−132)＝286.7 亿元（收入 3,331.5，8.6%）；2025 年 760.4−(730.0−248)＝278.4 亿元（3,512.2，7.9%）；2026 年上半年 346.3−(382.2−145)＝109.1 亿元（1,633.0，6.7%）。', '2026H1', '2026-06-30', '已核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第二季度及中期业绩公告（2026-08-18）' LIMIT 1), '汽车分部经营开支在公告里按亿元取整，推算值误差约 ±1 亿元。'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '生态经营利润率 2019—2025 年：3.7%、3.7%、5.9%、2.9%、7.6%、8.6%、7.9%', '经营', '2019—2023 年没有分部数据，按“毛利−研发−销售−行政＋当年创新业务费用”推算（2022 年 31 亿、2023 年 67 亿元）：3.68%、3.75%、5.90%、2.93%、7.65%；2024—2025 年用分部数据 8.61%、7.93%。2021—2025 年收入加权平均 6.70%，2019—2025 年 6.03%。', '2021—2025', '2025-12-31', '已核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '东方财富港股格式三大报表（akshare 取数）' LIMIT 1), '2021 年的汽车早期费用没有披露，未扣除；2018 年因上市一次性股权激励（约 100 亿元）不计入。'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '生态经营利润按季：2025 年 104.6、92.1、60.4、21.4 亿元，2026 年 60.6、48.5 亿元', '经营', '生态经营利润（推算）：2025 年一季度 104.6、二季度 92.1、三季度 60.4、四季度 21.4 亿元（营业费用率 17.4%）；2026 年一季度 60.6、二季度 48.5 亿元。存储涨价从 2025 年下半年开始压低利润。', '2026Q2', '2026-06-30', '已核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第二季度及中期业绩公告（2026-08-18）' LIMIT 1), NULL),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026 年二季度收入 1,089.2 亿元（−6.1%），经调整净利润 62.2 亿元（−42.6%）', '财务', '二季度收入 1,089.22 亿元（−6.1%）、毛利率 19.8%（−2.7pt）、经营利润 108.70 亿元（含投资公允价值收益 64.6 亿元）、期间利润 94.63 亿元、经调整净利润 62.19 亿元（−42.6%）。上半年收入 2,080.63 亿元（−8.4%）。', '2026Q2', '2026-06-30', '已核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第二季度及中期业绩公告（2026-08-18）' LIMIT 1), NULL),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026 年二季度手机出货 3,120 万台（−26.5%）、ASP 1,351 元（+25.9%）、毛利率 8.5%', '经营', '手机收入 421.2 亿元（−7.5%），出货 31.2 百万台（−26.5%），ASP 1,351.0 元（+25.9%，历史新高），毛利率 8.5%（−3.0pt，核心零部件涨价）。中国大陆 3,000 元以上机型占比 32.1%。', '2026Q2', '2026-06-30', '已核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第二季度及中期业绩公告（2026-08-18）' LIMIT 1), NULL),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025 年手机收入 1,864.4 亿元、毛利率 10.9%、出货 1.652 亿台；四季度毛利率 8.3%', '经营', '2025 年手机收入 1,864.40 亿元（−2.8%）、出货 165.2 百万台（−2.0%）、ASP 1,128.7 元、毛利率 10.9%（2024 年 12.6%）；四季度毛利率 8.3%，下半年受国补退坡与核心零部件涨价影响。', '2025', '2025-12-31', '已核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年全年业绩公告（2026-03-24）' LIMIT 1), NULL),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026 年二季度 IoT 与生活消费产品收入 312.8 亿元（−19.2%），国补退坡', '经营', 'IoT 与生活消费产品收入 312.8 亿元（−19.2%）、毛利率 20.1%（−2.4pt），主因中国大陆国家补贴退坡；境外 IoT 收入高速增长。', '2026Q2', '2026-06-30', '已核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第二季度及中期业绩公告（2026-08-18）' LIMIT 1), NULL),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025 年 IoT 收入 1,232.0 亿元（+18.3%）、毛利率 23.1%；大家电 +23.1%', '经营', '2025 年 IoT 与生活消费产品收入 1,232.00 亿元（+18.3%）、毛利率 23.1%（+2.8pt）；智能大家电收入 +23.1%，空调出货超 850 万台、冰箱超 280 万台、洗衣机超 230 万台。上半年受益于国补。', '2025', '2025-12-31', '已核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年全年业绩公告（2026-03-24）' LIMIT 1), NULL),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '互联网服务：2025 年 374.4 亿元（+9.7%）、毛利率 76.5%；2026 年二季度 90.4 亿元（−0.6%）', '经营', '互联网服务 2025 年收入 374.40 亿元（+9.7%）、毛利率 76.5%；2026 年二季度 90.44 亿元（−0.6%，游戏及其他增值服务下降）、毛利率 76.8%。2024 年 341.15 亿元、2023 年 301 亿元。', '2025', '2025-12-31', '已核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年全年业绩公告（2026-03-24）' LIMIT 1), '互联网服务含广告、游戏、金融科技等。'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025 年广告收入 285 亿元（+15.2%），境外互联网收入 126 亿元（占 33.8%）', '经营', '2025 年广告收入 285 亿元（+15.2%），四季度 78 亿元；境外互联网服务收入 126 亿元（+15.2%），占互联网收入 33.8%。2026 年二季度广告 72 亿元（+4.8%）。', '2025', '2025-12-31', '已核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年全年业绩公告（2026-03-24）' LIMIT 1), NULL),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '全球月活 2026 年 6 月 7.665 亿（+4.8%），中国大陆 1.977 亿（+7.0%）', '经营', '2026 年 6 月全球月活 766.5 百万（+4.8%），中国大陆 197.7 百万（+7.0%）；智能电视月活 76.9 百万；米家 APP 月活 124.1 百万、小爱同学 174.9 百万。', '2026-06', '2026-06-30', '已核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第二季度及中期业绩公告（2026-08-18）' LIMIT 1), '月活含手机与平板。'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '全球月活（12 月）2018—2025 年：2.42 亿 → 7.54 亿', '经营', '全球月活（12 月）：2018 年 242.1 百万、2019 年 309.6、2020 年 396.3、2021 年 508.9、2022 年 582.1、2023 年 641.2、2024 年 702.3、2025 年 754.1 百万（+7.4%）。增速从 28% 逐年降到 7%。', '2025', '2025-12-31', '已核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2018—2024 年全年业绩公告（分业务收入与成本、月活、出货量、创新业务费用）' LIMIT 1), '2018 年由 2019 年数与同比倒算。'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '手机出货 2020—2025 年：1.464、1.903、1.505、1.456、1.685、1.652 亿台', '经营', '手机出货：2020 年 146.4 百万台、2021 年 190.3、2022 年 150.5（−20.9%）、2023 年 145.6、2024 年 168.5（+15.7%）、2025 年 165.2；2026 年上半年 65.0（同期 84.2）。', '2025', '2025-12-31', '已核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2018—2024 年全年业绩公告（分业务收入与成本、月活、出货量、创新业务费用）' LIMIT 1), '2018、2019 年未取得。'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'AIoT 连接设备 11.608 亿台（+17.4%），五件以上设备用户 2,460 万（+20.2%）', '经营', '截至 2026 年 6 月底 AIoT 平台连接设备（不含手机、平板）1,160.8 百万台（+17.4%），拥有五件及以上设备的用户 24.6 百万（+20.2%）。', '2026-06', '2026-06-30', '已核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第二季度及中期业绩公告（2026-08-18）' LIMIT 1), NULL),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026 年二季度汽车及 AI 分部：收入 249.0 亿元、交付 104,199 辆、ASP 22.93 万元、毛利率 19.2%、经营亏损 26 亿元', '经营', '分部收入 248.96 亿元（+17.1%），其中汽车 239 亿元、其他 10 亿元（含 MiMo 大模型 AI 收入）；交付 104,199 辆（+28.2%），ASP 229,312 元（−9.6%，SU7 Ultra 占比下降）；分部毛利率 19.2%（同期 26.4%），经营开支 74 亿元，经营亏损 26 亿元。', '2026Q2', '2026-06-30', '已核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第二季度及中期业绩公告（2026-08-18）' LIMIT 1), NULL),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026 年一季度汽车及 AI 分部经营亏损 31 亿元，交付 80,856 辆', '经营', '分部收入 198.64 亿元，汽车 190 亿元；交付 80,856 辆（+6.6%，停售初代 SU7），ASP 235,116 元；分部毛利率 20.1%、经营开支 71 亿元、经营亏损 31 亿元。', '2026Q1', '2026-03-31', '已核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第一季度业绩公告（2026-05-26）' LIMIT 1), NULL),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025 年交付 411,082 辆、汽车收入 1,033 亿元、ASP 25.12 万元；2026 年目标 55 万辆', '经营', '2025 年交付 411,082 辆（+200.4%），汽车收入 1,033 亿元，ASP 251,171 元；四季度交付 145,115 辆、分部经营收益 11 亿元。2026 年“全力冲刺交付 55 万辆”。截至 2025 年底在 138 个城市开业 477 家汽车门店。', '2025', '2025-12-31', '已核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年全年业绩公告（2026-03-24）' LIMIT 1), NULL),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '9 月小米汽车交付超 4 万台，澎程 30 天锁单超 7 万台；前三季度约 28.7 万台', '经营', '公司公布：9 月交付超 40,000 台，其中澎程首月超 10,000 台；澎程 9 月 7 日—10 月 7 日锁单超 7 万台。第三方测算 1—9 月累计约 28.6—28.7 万台，完成 55 万目标需四季度月均约 8.8 万台。', '2026 年 1—9 月', '2026-09-30', '待核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '行业数据：Omdia 与 Counterpoint 手机出货、乘联会与车企月度交付、车企 2026 年中报毛利率汇总' LIMIT 1), '月度数据为“超过”口径。'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '专家预计 2026 年交付 46—48.5 万辆，55 万目标难以完成', '经营', '光大家电纪要（2026-10-21）：四季度交付约 16.5—17 万台，全年 46.5—48.5 万台；澎程首月新增订单约 8.13 万台、低于公司预期约 12 万台。另一份纪要：46—48 万台；明年海外 2.5—3 万台、2028 年 10—13 万台、2029 年 25—30 万台。', '2026E', '2026-10-21', '待核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '券商组织的产业链与专家交流纪要（光大家电 2026-10-21、财通汽车 2026-07-13、申万宏源 2026-08-20、mi 造车系列 2026-08、10）' LIMIT 1), '专家口径。'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '专家对汽车单车利润的估计分歧大：约 0.5 万元到 2.5 万元', '经营', '光大纪要：SU7/YU7 单车净利 2.5 万元以内、N90 1.5—2 万元、N70 1—1.3 万元，2025 年约 3.3 万元，2026 年汽车业务本身利润约 90—96 亿元。财通纪要：剔除 AI 后一季度勉强盈利、全年单车约 5,000 元，AI 全年费用约 100 亿元。两者相差 4—5 倍。', '2026E', '2026-10-21', '待核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '券商组织的产业链与专家交流纪要（光大家电 2026-10-21、财通汽车 2026-07-13、申万宏源 2026-08-20、mi 造车系列 2026-08、10）' LIMIT 1), '公司不单独披露汽车与 AI 的利润。'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '汽车及 AI 分部经营开支：2024 年 132 亿元、2025 年 248 亿元，2026 年一、二季度 71、74 亿元', '经营', '汽车及 AI 分部经营开支：2024 年 132 亿元、2025 年 248 亿元（含该分部股权激励 16 亿元），2025 年各季 48、59、67、74 亿元，2026 年一、二季度 71、74 亿元。', '2026Q2', '2026-06-30', '已核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第二季度及中期业绩公告（2026-08-18）' LIMIT 1), NULL),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '“手机×AIoT”分部营业费用率：2025 年四季度 17.4%、2026 年一季度 14.9%、二季度 14.2%', '经营', '公司披露“手机×AIoT”分部营业费用率：2026 年一季度 14.9%（环比下降 2.5pt，即 2025 年四季度约 17.4%）、二季度 14.2%。', '2026Q2', '2026-06-30', '已核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第二季度及中期业绩公告（2026-08-18）' LIMIT 1), NULL),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '管理层：未来三年 AI 投入超 600 亿元，2026 年 160 亿元', '经营', 'CFO 林世伟（2025 年四季度业绩会）：未来三年在 AI 领域投入超 600 亿元；以 2026 年规划的 160 亿元为例，当期研发费用占七成以上，其余主要是基础设施资本开支及其摊销。汽车及创新业务分部“涵盖造车业务本身的利润贡献，同时也承担了大量 AI 大模型及具身智能等前沿领域的先期投入”。', '2026—2028', '2026-03-24', '待核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '业绩会纪要：2025 年四季度（2026-03-24）、2026 年一季度（2026-05-26）、二季度（2026-08-18）' LIMIT 1), '纪要转述，两家纪要口径一致。'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025 年研发 331.3 亿元（+37.8%）；2026—2030 年累计研发预计超 2,000 亿元', '经营', '2025 年研发开支 331.32 亿元（+37.8%），过去五年累计 1,055 亿元；预计 2026 年起五年累计研发超 2,000 亿元。2026 年上半年研发 181.9 亿元（+25.6%），研发人员 24,961 人。', '2025', '2025-12-31', '已核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年全年业绩公告（2026-03-24）' LIMIT 1), NULL),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '存储成本：4 百美元以下机型存储占物料成本 60% 以上（2025 年三季度约 30%）', '经营', '高盛整理的 Omdia 数据：400 美元以下机型存储占物料成本 60% 以上、高端机型 30% 以上（2025 年三季度分别约 30%、10%）；厂商被迫提价、缩减低端产品线。Omdia：小米是前五大厂商中受存储成本影响最大的。', '2026Q2', '2026-07-14', '待核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '行业数据：Omdia 与 Counterpoint 手机出货、乘联会与车企月度交付、车企 2026 年中报毛利率汇总' LIMIT 1), NULL),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '管理层：内存涨价超预期，三季度中途放缓、四季度缓涨', '经营', '卢伟冰（二季度业绩会）：内存涨价幅度超出预期，对低端及入门机型冲击最明显；预计三季度中途放缓、四季度缓涨，整体趋于可控。申万纪要：TrendForce 预计消费级 DRAM、NAND 合约价三季度涨势放缓，明年 DRAM 仍偏紧。', '2026Q3', '2026-08-18', '待核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '业绩会纪要：2025 年四季度（2026-03-24）、2026 年一季度（2026-05-26）、二季度（2026-08-18）' LIMIT 1), NULL),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026 年二季度中国大陆：华为 23%、苹果 19%、小米 12%（820 万台，−21%）', '经营', 'Omdia：2026 年二季度中国大陆出货 66.1 百万台（−2%）；华为 15.2（+25%）、苹果 12.4（+24%）、OPPO 10.6、vivo 10.5、小米 8.2 百万台（−21%，份额 12%，第五）。', '2026Q2', '2026-06-30', '待核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '行业数据：Omdia 与 Counterpoint 手机出货、乘联会与车企月度交付、车企 2026 年中报毛利率汇总' LIMIT 1), NULL),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026 年二季度全球：三星 6,050 万、苹果 5,510 万、小米 3,120 万部（−26%）', '经营', 'Omdia：2026 年二季度全球出货 2.72 亿部（−6%）；三星 60.5 百万（+5%）、苹果 55.1 百万（+23%）、小米 31.2 百万（−26%）、OPPO 28.4、vivo 21.5 百万。', '2026Q2', '2026-06-30', '待核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '行业数据：Omdia 与 Counterpoint 手机出货、乘联会与车企月度交付、车企 2026 年中报毛利率汇总' LIMIT 1), NULL),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'Omdia 初步：2026 年三季度小米全球份额 12%（−2pt），中国大陆 800 万台（−20%）', '经营', 'Omdia 初步：2026 年三季度全球出货同比约 −20%，小米份额 12%（−2pt）排名第三；中国大陆 59.3 百万台（−12%），小米 8.0 百万台（−20%）、份额 13%、第五。', '2026Q3', '2026-10-15', '待核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '行业数据：Omdia 与 Counterpoint 手机出货、乘联会与车企月度交付、车企 2026 年中报毛利率汇总' LIMIT 1), '东方财富海外转述。'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026-06-30 现金储备 2,193 亿元，借款 393 亿元（含可换股债券 50.8 亿元）', '财务', '截至 2026 年 6 月 30 日：现金及现金等价物 373 亿元，现金储备 2,193 亿元（含现金、受限制现金、定期存款、短期投资、按摊余成本计量的长期投资及理财投资）；借款总额 393 亿元，其中可换股债券 50.78 亿元（2027 年到期，初始换股价 36.74 港元）。', '2026-06-30', '2026-06-30', '已核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第二季度及中期业绩公告（2026-08-18）' LIMIT 1), NULL),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026-06-30 现金类资产明细合计 2,274.7 亿元，比公司现金储备口径多 81.7 亿元', '财务', '资产负债表明细：现金及现金等价物 372.52、受限制现金 41.38、定期存款 1,281.76（流动 624.66、非流动 657.11）、短期投资 220.06、按摊余成本计量的长期投资 160.09、理财投资 198.90，合计 2,274.71 亿元；公司口径现金储备 2,193 亿元，差额 81.7 亿元未说明（可能扣除了受限或金融业务资金）。2025 年末同样有 66.9 亿元差额。', '2026-06-30', '2026-06-30', '已核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第二季度及中期业绩公告（2026-08-18）' LIMIT 1), '估值采用较低的公司口径。'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026-06-30 对外投资 720.7 亿元：权益法 66.1、普通股 185.8、优先股 382.4、其他 86.3', '财务', '按权益法入账的投资 66.15、按公允价值计入损益的长期投资中普通股 185.83、优先股 382.44、其他投资 86.27 亿元，合计 720.69 亿元（理财投资 198.90 亿元已在现金储备里）。公司口径：共投资约 410 家公司、总账面价值 920 亿元。2025 年末长期投资中一级公允价值（上市股权）71.7 亿元，其余为三级。', '2026-06-30', '2026-06-30', '已核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第二季度及中期业绩公告（2026-08-18）' LIMIT 1), '920 亿元口径范围更大，未拆分。'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '投资者负债（基金外部出资人份额）：2025 年末 139.1 亿元，2026 年 6 月末非流动部分 142.3 亿元', '财务', '投资者负债＝合并的产业基金中外部出资人份额：2025 年末 139.07 亿元（公允价值计量 60.60＋摊余成本 78.47），其中非流动 127.73 亿元；2026 年 6 月末非流动 142.32 亿元（流动部分未披露）。2026 年上半年因其价值变动计入财务成本 8.16 亿元。', '2026-06-30', '2026-06-30', '已核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年中期报告（附注：其他非流动负债、其他应付款项、租赁负债）' LIMIT 1), '流动部分按 2025 年末 11.34 亿元估计。'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026-06-30 租赁负债 50.4 亿元、购买无形资产应付款 50.7 亿元', '财务', '2026 年 6 月末租赁负债 50.41 亿元（流动 16.01、非流动 34.40）；购买无形资产应付款 50.75 亿元（流动 15.20、非流动 35.54），二者都计息。', '2026-06-30', '2026-06-30', '已核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年中期报告（附注：其他非流动负债、其他应付款项、租赁负债）' LIMIT 1), NULL),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '印度：491.7 亿卢比（约 35.4 亿元）资金被冻结，案件在听证阶段', '财务', '自 2021 年 12 月起印度税务、外汇等部门调查小米印度，指控其不当扣除许可费等，部分银行账户被扣押；截至 2026 年 6 月底 49,170,230,000 卢比（约 35.36 亿元）受限，案件在听证阶段，公司未计提重大拨备。', '2026-06-30', '2026-06-30', '已核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第二季度及中期业绩公告（2026-08-18）' LIMIT 1), NULL),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026-06-30 在外股份 257.09 亿股（已发行 257.85 亿股，扣除待注销回购 0.76 亿股）', '财务', '港交所月报表：2026 年 6 月底已发行 B 类 21,341,753,161 股（含已回购待注销 75,925,000 股）、A 类 4,443,616,133 股；在外 25,709,444,294 股。二季度加权平均 25,723,924 千股，摊薄另加约 6.17 亿股。', '2026-06-30', '2026-06-30', '已核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '港交所证券变动月报表（2025 年 12 月、2026 年 6 月、2026 年 9 月）' LIMIT 1), NULL),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026-09-30 在外股份 257.53 亿股：回购之外，股权激励新增 B 类股', '财务', '9 月底已发行 B 类 21,365,475,889 股（含待注销 41,975,200 股）、A 类 4,429,236,628 股，在外约 257.53 亿股；9 月 B 类股增加约 3,550 万股（股权激励发股），抵消了部分回购。2025 年 12 月底在外约 259.29 亿股。', '2026-09-30', '2026-09-30', '已核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '港交所证券变动月报表（2025 年 12 月、2026 年 6 月、2026 年 9 月）' LIMIT 1), NULL),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026 年回购：截至 10 月 12 日约 4.10 亿股、125 亿港元；新计划上限 200 亿港元', '财务', '2026 年 1 月 1 日至 8 月 13 日回购 377,465,400 股 B 类股、约 116.66 亿港元（1—6 月 351.3 百万股、109.6 亿港元）；截至 10 月 12 日约 4.10 亿股、125 亿港元。5 月 26 日采纳新回购计划，总额不超过 200 亿港元。', '2026 年 1 月—10 月 12 日', '2026-10-12', '已核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第二季度及中期业绩公告（2026-08-18）' LIMIT 1), '10 月数为东方财富按公告统计。'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025 年回购 63 亿港元（1.526 亿股）；2026 年 1 月首次公告自动回购计划', '财务', '2025 年回购约 63 亿港元、152.6 百万股；2026 年 1 月首次公告不超过 25 亿港元的自动回购计划。2025 年 3 月按每股 53.25 港元配售 8 亿股，募资约 425 亿港元。', '2025', '2025-12-31', '已核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年全年业绩公告（2026-03-24）' LIMIT 1), NULL),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '股权激励：2026 年上半年 23.2 亿元；摊薄调整约 7.0 亿股', '财务', '以股份为基础的薪酬：2026 年上半年 23.21 亿元（同期 23.64 亿元）、二季度 9.10 亿元；2025 年汽车及 AI 分部股权激励 16 亿元。上半年摊薄性受限制股份及购股权调整 7.03 亿股。经调整净利润加回了这部分费用。', '2026H1', '2026-06-30', '已核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第二季度及中期业绩公告（2026-08-18）' LIMIT 1), NULL),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026 年上半年资本开支 68.9 亿元：手机×AIoT 30.2、汽车及 AI 38.3', '财务', '资本开支：2026 年一季度 32.74 亿元（手机×AIoT 17.80、汽车及 AI 14.94），二季度 36.21 亿元（12.38、23.83）。2025 年购建固定资产 127.7 亿元。', '2026H1', '2026-06-30', '已核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第二季度及中期业绩公告（2026-08-18）' LIMIT 1), NULL),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '其他收入（主要是补贴）：2019—2025 年 6—27 亿元，2026 年上半年 32.5 亿元', '财务', '其他收入（以政府补贴为主）：2019 年 12.7、2020 年 6.4、2021 年 8.3、2022 年 11.4、2023 年 7.4、2024 年 16.7、2025 年 27.4 亿元；2026 年上半年 32.5 亿元（二季度 21.6 亿元，补贴收入增加）。', '2026H1', '2026-06-30', '已核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '东方财富港股格式三大报表（akshare 取数）' LIMIT 1), NULL),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '投资公允价值收益：2025 年 133.1 亿元，2026 年上半年 73.1 亿元（经调整净利润剔除）', '财务', '按公允价值计入损益之金融工具公允价值变动：2024 年 10.5、2025 年 133.1 亿元，2026 年上半年 73.1 亿元（二季度 64.6 亿元，上市股权与优先股估值上升）。经调整净利润剔除投资公允价值变动。', '2026H1', '2026-06-30', '已核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第二季度及中期业绩公告（2026-08-18）' LIMIT 1), NULL),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '实际所得税率：2024 年 16.2%、2025 年 16.3%、2026 年上半年 17.9%', '财务', '所得税÷税前利润：2023 年 20.6%、2024 年 16.2%、2025 年 16.3%、2026 年上半年 17.9%。研发费用加计扣除使研发支出的实际抵税率高于法定税率。', '2025', '2025-12-31', '已核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '东方财富港股格式三大报表（akshare 取数）' LIMIT 1), NULL),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智能电动汽车等创新业务费用：2022 年 31 亿元、2023 年 67 亿元', '经营', '公司披露：2022 年智能电动汽车等创新业务费用 31 亿元；2023 年 67 亿元（四个季度 11、14、17、24 亿元），均计入经调整净利润。', '2023', '2023-12-31', '已核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2018—2024 年全年业绩公告（分业务收入与成本、月活、出货量、创新业务费用）' LIMIT 1), NULL),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026-10-22 收盘 25.80 港元（约 21.96 元），近一年最高收盘 47.14 港元', '估值方法', '腾讯行情：2026-10-22 收盘 25.80 港元，按 0.851 折 21.96 元；近一年（2025-10-20 起）最高收盘 47.14、最低 21.42 港元。第三方报道历史最高 61.45 港元（2025 年）。', '2026-10-22', '2026-10-22', '已核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '腾讯行情 K 线：小米港股日线与港元兑人民币（2025-10—2026-10）' LIMIT 1), NULL),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '高盛（2026-05）：核心 EV/NOPAT 16 倍、汽车 1.6 倍市销率，目标价 41 港元', '估值方法', '高盛闭门会（2026-05）：核心业务（手机＋AIoT）EV/NOPAT 基准 16 倍、悲观 6 倍、乐观 20 倍；汽车按市销率 1.6 倍（悲观 0.9 倍）；净现金与投资直接加总，再考虑控股公司折价；目标价 41 港元（悲观 26、乐观 45）。', '2026-05', '2026-05-09', '待核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '卖方与外资：高盛业绩前瞻（2026-05）、申万宏源分部估值（2026-08）、银河证券等中报点评（2026-08）、国泰海通纪要' LIMIT 1), NULL),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '申万宏源（2026-08）：主业 334 亿元×25 倍＋汽车及 AI 0.7 倍市销率，目标市值 9,000 亿元以上', '估值方法', '申万宏源纪要（2026-08-20）：主业 2026 年经调整净利润 334 亿元×历史中枢 25 倍＝8,500 亿元；汽车及 AI 收入 1,173 亿元×0.7 倍市销率＝800 亿元；手机毛利率二季度 8.5% 为底，明年 9.5%—10%。', '2026-08', '2026-08-20', '待核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '卖方与外资：高盛业绩前瞻（2026-05）、申万宏源分部估值（2026-08）、银河证券等中报点评（2026-08）、国泰海通纪要' LIMIT 1), '卖方估值没有扣除 AI 投入的长期成本，也没有扣除股权激励。'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '卖方 2026—2028 年归母净利预测：约 278—291、367—373、434—447 亿元', '估值方法', '银河证券：2026—2028 年归母净利 278.4、373.0、434.5 亿元；另一家券商（2026-08-21 中报点评）：291.3、367.2、446.9 亿元（均为国际财务报告准则口径预测，含投资收益）。', '2026E—2028E', '2026-08-21', '待核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '卖方与外资：高盛业绩前瞻（2026-05）、申万宏源分部估值（2026-08）、银河证券等中报点评（2026-08）、国泰海通纪要' LIMIT 1), NULL),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026 年上半年毛利率：比亚迪 18.8%、特斯拉 18.7%、小鹏 20.6%、零跑 11.7%、理想 9.5%', '经营', '国盛证券汇总：2026 年上半年毛利率比亚迪 18.8%、特斯拉 18.7%、吉利 17.9%、小鹏 20.6%、蔚来 18.7%、零跑 11.7%、理想 9.5%、赛力斯 23.3%、小米集团 20.9%。', '2026H1', '2026-09-23', '待核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '行业数据：Omdia 与 Counterpoint 手机出货、乘联会与车企月度交付、车企 2026 年中报毛利率汇总' LIMIT 1), NULL),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '零跑：上半年交付 35.65 万辆，二季度毛利率 12.6%、净利 6 亿元，全年净利指引降到约 30 亿元', '经营', '零跑 2026 年上半年交付 35.65 万辆（+60.8%），二季度 24.6 万辆、收入 273 亿元、毛利率 12.6%、归母净利约 6 亿元；全年净利指引由 50 亿元下调至约 30 亿元；1—9 月约 66.7 万辆、目标 100 万辆。', '2026H1', '2026-06-30', '待核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '行业数据：Omdia 与 Counterpoint 手机出货、乘联会与车企月度交付、车企 2026 年中报毛利率汇总' LIMIT 1), NULL),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '理想：2026 年二季度车辆毛利率 9.4%、经营亏损 23 亿元', '经营', '理想 2026 年二季度收入 256.7 亿元、交付 98,330 辆、车辆毛利率 9.4%（同期 20.1%）、经营亏损 23.0 亿元、现金储备 875 亿元。', '2026Q2', '2026-06-30', '待核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '行业数据：Omdia 与 Counterpoint 手机出货、乘联会与车企月度交付、车企 2026 年中报毛利率汇总' LIMIT 1), NULL),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '新一代 SU7 锁单用户中苹果手机用户近 60%（初代约 50%）', '经营', 'CFO 林世伟（2025 年四季度业绩会）：新一代 SU7 锁单用户绝大多数是全新客户，女性占比提升，苹果手机用户渗透率从初代约 50% 升到近 60%。', '2026-03', '2026-03-24', '待核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '业绩会纪要：2025 年四季度（2026-03-24）、2026 年一季度（2026-05-26）、二季度（2026-08-18）' LIMIT 1), '说明汽车客户并不依赖小米手机生态。'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '小米之家：中国大陆约 1.6—1.8 万家，境外新零售门店超 640 家', '经营', '2025 年末中国大陆小米之家约 18,000 家（2025 年净增超 3,000 家），2026 年 3 月超 16,000 家；500 平米以上大店超 270 家（2026 年 6 月）；境外新零售门店超 640 家。', '2026-06', '2026-06-30', '已核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第二季度及中期业绩公告（2026-08-18）' LIMIT 1), NULL),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '专家：2026 年手机硬件预计亏损 80—100 亿元，IoT 与互联网托底', '经营', 'mi 造车系列纪要（2026-08-06）：手机业务今年硬件预计亏损 80—100 亿元，IoT 和互联网利润托底，集团全年净利润 220—250 亿元；IoT 营收与去年持平或略好，毛利率约 26%、净利约 160 亿元。', '2026E', '2026-08-06', '待核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '券商组织的产业链与专家交流纪要（光大家电 2026-10-21、财通汽车 2026-07-13、申万宏源 2026-08-20、mi 造车系列 2026-08、10）' LIMIT 1), '专家口径，与公司披露的分部毛利率口径不同。'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '分业务毛利率 2019—2025 年：手机 7.2%→10.9%（2023 年 14.6%），IoT 11.2%→23.1%，互联网 64.7%→76.5%', '经营', '全年业绩公告分项（2019—2023 年毛利＝收入−销售成本，2024 年起直接披露）：手机毛利率 2019 年 7.2%、2020 年 8.7%、2021 年 11.9%、2022 年 9.0%、2023 年 14.6%、2024 年 12.6%、2025 年 10.9%，2021—2025 年收入加权 11.8%；IoT 与生活消费产品 11.2%、12.8%、13.1%、14.4%、16.3%、20.3%、23.1%（含毛利为负的其他相关业务后：10.9%、12.7%、13.7%、14.5%、14.6%、18.7%、21.3%）；互联网服务 64.7%、61.6%、74.1%、71.8%、74.2%、76.6%、76.5%。', '2019—2025', '2025-12-31', '已核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2018—2024 年全年业绩公告（分业务收入与成本、月活、出货量、创新业务费用）' LIMIT 1), '2025 年来自 2025 年全年业绩公告；2019—2023 年“其他”与 2024 年起“其他相关业务”口径相近（2023 年两种列示一致）。'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '生态营业费用率 2019—2025 年：10.2%、11.2%、11.8%、14.1%、13.6%、12.6%、13.7%；2026 年上半年 14.5%', '经营', '“手机×AIoT”营业费用＝集团研发、销售、行政费用−汽车等创新业务费用（2022 年 31、2023 年 67 亿元）或汽车及 AI 分部经营开支（2024 年 132、2025 年 248 亿元）。费用率：2019 年 10.2%、2020 年 11.2%、2021 年 11.8%、2022 年 14.1%、2023 年 13.6%、2024 年 12.6%、2025 年 13.7%，2021—2025 年收入加权 13.1%；2026 年上半年 14.5%（237.2÷1,633.0）。公司不按手机、IoT、互联网拆分费用。', '2019—2026H1', '2026-06-30', '已核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '东方财富港股格式三大报表（akshare 取数）' LIMIT 1), '2021 年的汽车早期费用没有披露，未扣除；汽车分部经营开支按公告取整到亿元。'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026 年上半年分业务：手机毛利率 9.3%、AIoT（含其他）21.2%、互联网 76.4%；按收入分摊费用后经营利润 −44.7、39.3、114.6 亿元', '经营', '2026 年上半年：手机收入 863.9 亿元、毛利 80.8 亿元（9.3%）；IoT 与生活消费产品 559.6 亿元、毛利 124.9 亿元（22.3%）；其他相关业务 24.4 亿元、毛利 −0.8 亿元；互联网服务 185.1 亿元、毛利 141.5 亿元（76.4%）。“手机×AIoT”营业费用 237.2 亿元（费用率 14.5%），按收入分摊后经营利润：手机 −44.7、AIoT（含其他）39.3、互联网 114.6 亿元，合计 109.1 亿元。', '2026H1', '2026-06-30', '已核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第二季度及中期业绩公告（2026-08-18）' LIMIT 1), '费用分摊是本研究的假设（公司不拆分）；手机的结果与专家“2026 年手机硬件亏损 80—100 亿元”的估计方向一致。'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'MiMo-V2.5 在 OpenRouter 周调用量第一（10.5 万亿 token），AI 收入仍很小', '经营', '二季度业绩公告：4 月发布的基座模型 MiMo-V2.5 在 OpenRouter 平台周调用量位列第一，达 10.5 万亿 token；6 月发布全屋智能 AI 方案 Miloco 2.0；7 月开源具身模型 Xiaomi-Robotics-U0 与 Robotics-1，机器人已在汽车工厂多个工站应用。汽车及 AI 分部二季度“其他相关业务”收入约 10 亿元（含 AI 收入与售后）。', '2026Q2', '2026-06-30', '已核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第二季度及中期业绩公告（2026-08-18）' LIMIT 1), 'AI 收入未单独披露；调用量高与 API 大幅降价并存。'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智谱（02513.HK）2026-10-22 市值约 2,247 亿港元（约 1,912 亿元），较 6 月高点回落约八成', '估值方法', '2026-10-22 收盘 460.8 港元×总股本 4.876 亿股＝约 2,247 亿港元（约 1,912 亿元、289 亿美元）。1 月 8 日以 116.2 港元上市，6 月盘中最高 2,980 港元；7 月按 1,588 港元、9 月按 714 港元配售并发可转债，两次净募资约 706 亿港元。研报按 7 月初市值 9,381 亿港元测算的 2026、2027 年市销率为 248、96 倍。', '2026-10-22', '2026-10-22', '待核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '港股行情：智谱（02513.HK）、MiniMax（00100.HK）收盘价与总股本（2026-10-22）' LIMIT 1), '收盘价两家行情源一致；股本、配售与市销率为第三方口径。'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'MiniMax（00100.HK）2026-10-22 市值约 566 亿港元（约 482 亿元）', '估值方法', '2026-10-22 收盘 160.7 港元×总股本 3.525 亿股＝约 566 亿港元（约 482 亿元、73 亿美元）。1 月 9 日以 165 港元上市，近一年最高 1,330 港元；7 月按 268 港元配售约 160 亿港元并发行 65 亿港元可转债（对应约 116 亿美元）。研报按 7 月初市值 1,308 亿港元测算的 2026、2027 年市销率为 56、19 倍。', '2026-10-22', '2026-10-22', '待核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '港股行情：智谱（02513.HK）、MiniMax（00100.HK）收盘价与总股本（2026-10-22）' LIMIT 1), '同上。'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '月之暗面（Kimi）2026 年 7 月 F 轮投后估值 350 亿美元', '估值方法', '2025 年 12 月 C 轮 5 亿美元、投后 43 亿美元；2026 年 2 月 C+ 轮约 100 亿美元、5 月 D 轮超 200 亿美元、7 月 F 轮 35 亿美元、投后 350 亿美元（约 2,300 亿元）。ARR 3 月突破 1 亿美元，7 月报道约 3 亿美元；已启动港股上市准备。', '2026-07', '2026-07-31', '待核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '国内大模型公司融资与估值汇总（金圆统一证券 2026-09-30、大模型二季度复盘 2026-07-03 等，岗底斯知识库）' LIMIT 1), '一级市场估值。'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '阶跃星辰 2026 年 5 月 Pre-IPO 轮后估值约 120 亿美元', '估值方法', '2026 年 1 月 B+ 轮超 50 亿元（投后约 28 亿美元）；5 月 Pre-IPO 轮近 25 亿美元，中兴通讯、华勤技术、腾讯投资等参投，投后约 120 亿美元（约 800 亿元）。2025 年收入近 5 亿元，按约 100 亿美元估值的市销率约 136 倍；与手机、汽车厂商合作做终端智能，计划港股上市。', '2026-05', '2026-05-31', '待核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '国内大模型公司融资与估值汇总（金圆统一证券 2026-09-30、大模型二季度复盘 2026-07-03 等，岗底斯知识库）' LIMIT 1), '一级市场估值。'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'DeepSeek 2026 年 8 月第二轮融资投前估值约 5,000 亿元', '估值方法', '2026 年 4 月首轮外部融资 500 亿元（投后超 500 亿美元），腾讯、宁德时代、京东、网易、IDG 等参投；8 月第二轮计划募资 500 亿元，投前估值约 5,000 亿元（研报折约 775 亿美元）。未披露收入。', '2026-08', '2026-08-31', '待核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '国内大模型公司融资与估值汇总（金圆统一证券 2026-09-30、大模型二季度复盘 2026-07-03 等，岗底斯知识库）' LIMIT 1), '一级市场估值。'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '大模型公司按收入的几十到上百倍估值，市值里有大量刚融到的现金', '估值方法', '研报 2026 年 7 月初测算：智谱 2026、2027 年市销率 248、96 倍，MiniMax 56、19 倍；月之暗面按 4 月 ARR 2 亿美元、投前 300 亿美元约 150 倍；阶跃星辰约 136 倍。百川智能最近一次公开估值约 28 亿美元（2024 年 7 月，小米是投资方之一）。这些公司刚完成大额融资（智谱两次净募资约 706 亿港元，MiniMax 募资约 160 亿港元另发 65 亿港元可转债），市值里有相当部分是账上现金；摩根大通估计研发费用约为收入的 4—5 倍。', '2026-07', '2026-09-30', '待核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '国内大模型公司融资与估值汇总（金圆统一证券 2026-09-30、大模型二季度复盘 2026-07-03 等，岗底斯知识库）' LIMIT 1), '估值波动极大：智谱、MiniMax 市值较 6—7 月高点回落六到八成。');

INSERT INTO vi_thesis_base (company_id, code, title, category, status, confidence, bull_case, bear_case, bull_rebuttal, bear_rebuttal, verdict, decisive_evidence, mind_changer, model_impact, external_view, debated_on, check_metric, check_op, check_threshold, check_years) VALUES
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'T1', '生态用户与互联网变现是真壁垒：硬件按成本获客，互联网服务赚钱', '经营', '成立', '中', '1）硬件按接近成本卖出（综合毛利率约 20%，扣除研发、销售、行政后接近盈亏平衡），利润来自互联网：2025 年互联网服务毛利 286.4 亿元，几乎等于生态经营利润 278.4 亿元（B9）。2）月活连续十年增长、互联网毛利率稳定在 75%—78%（M1）：硬件卖得再便宜，只要设备在用户手里，每个用户每年就有约 50 元的高毛利收入（B9）。3）11.6 亿台 IoT 设备和米家、小爱的高活跃让用户难以离开。', '1）这不是网络效应，是“装机量的租金”：互联网收入依赖手机出货带来的新用户与预装，用户会随换机流失到华为、苹果，高端用户正被吸走。2）2026 年二季度互联网收入同比 −0.6%（游戏下降），出货 −26% 会在一两年后传导到月活增速。3）境外变现受谷歌框架约束（V7）；AI 助手可能绕过应用商店与广告入口（V10）。', '月活滞后于出货，但存量设备的生命周期 3—4 年；广告仍 +4.8%，说明变现效率在提高。AI 入口是系统级的，手机厂商比第三方更有优势。', '广告增长放缓到个位数，境内月活增长主要来自平板等；若出货长期低于 1.5 亿台，月活增速会降到 2% 以下。', '互联网变现是小米唯一可度量的真实壁垒：毛利率与月活的长期数据都支持，但它依赖硬件出货，强度“中”。2026 年二季度月活 7.665 亿（+4.8%）、互联网毛利率 76.8%，出货下滑的影响要一两年后才在月活上显现。这支持把互联网单独估值、给比手机和 AIoT 更高的倍数（约 15.4 倍），但不支持卖方 20 倍以上。', '月活同比（设了自动检查）；互联网收入同比与毛利率；广告收入；境外互联网占比。', '改判：月活连续两年增长低于 2%，或互联网毛利率降到 70% 以下。自动检查：全球月活同比连续两年低于 2%。', NULL, '卖方（申万）给主业 25 倍历史中枢；高盛基准 16 倍、悲观 6 倍。岗底斯观点 PK 未调用。', '2026-10-23', '业务量同比', '<', 0.02, 2),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'T2', '存储涨价是周期：周期过后，手机毛利率能回到 11%—12%', '经营', '观察', '低', '1）这是典型的周期：2022 年行业萧条时手机毛利率 9.0%（生态利润率 2.9%），2023 年就回到 14.6%（7.6%）。2）这次的冲击来自存储（V2）：手机毛利率从 2025 年一季度 12.4% 降到 2026 年二季度 8.5%，生态经营利润率从 11.3% 降到 2025 年四季度 2.7%；IoT 与互联网的毛利率受存储影响小。3）小米主动控量保价：出货 −26%，ASP +26% 到 1,351 元（历史新高）；管理层称涨势三季度中途放缓。4）存储新产能 2027—2028 年释放，价格回落后毛利率修复（V2）。', '1）这次有结构性因素：AI 手机需要更大内存，存储占低端机成本从 30% 升到 60% 以上，低端市场在萎缩。2）小米国内份额降到 12%、第五（V8），高端被华为、苹果挤压，低端被涨价打掉；即使周期结束，规模也回不到 1.65 亿台。', '毛利率取的是 2021—2025 年收入加权 11.8%，已经包含一次萧条（2022 年 9.0%）；高端化是结构性的正面因素。', '平均值包含 2023 年存储价格低谷带来的 14.6% 高点；没有那次低价存储，常态可能只有 10%—11%。', '方向上会修复，但幅度不确定。基准取 11.8%，悲观 10.0%、乐观 13.0%。按收入分摊费用后，手机在三个情景里都不赚钱（经营利润率 −5.0%、−2.2%、0%），所以手机毛利率决定的是“获客成本”有多大：每 1pt 约 0.58 元/股。', '2026 年三、四季度及 2027 年上半年的手机毛利率与 ASP、生态营业费用率；DRAM/NAND 合约价；出货份额。', '改判：2027 年存储价格仍在上涨，或手机毛利率连续四个季度低于 9%。自动检查：集团毛利率连续两年低于 19%。', NULL, '申万：二季度手机毛利率 8.5% 为底、明年 9.5%—10%；Omdia：小米是前五大里受存储冲击最大的。', '2026-10-23', '毛利率', '<', 0.19, 2),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'T3', '汽车能成为有规模、有利润的第二曲线', '经营', '观察', '低', '1）第二年分部就盈利：2025 年交付 41.1 万辆，分部经营收益 9 亿元（四季度 11 亿元），三年累计交付超 80 万辆；剔除 AI 后汽车本身仍在盈利。2）SU7、YU7、澎程三条线覆盖 20—35 万元，澎程 30 天锁单 7 万台；品牌与门店（M3、M4）降低获客成本。3）2027 年出海，规划 2029 年海外 25—30 万台。', '1）2026 年交付 46—48 万辆，低于 55 万目标；ASP 同比 −10%，分部毛利率从 26.4% 降到 19.2%。2）行业需求疲软、价格战（V9）：成熟车企利润率只有 5%—9%；新势力长期在 50 万辆附近徘徊就会失去规模效应。3）同行的规模没有变成利润：零跑卖了 66 万辆只赚约 30 亿元，理想亏损（见竞争对手）。', '小米的毛利率（19%—24%）高于零跑、理想；品牌和保值率第一；海外是新增量。', '汽车本身利润无法从公告验证（专家估计相差 4—5 倍）；海外建渠道、合规要多年，并面临关税。', '能成为一门“正常利润”的制造业生意的可能性较大，但很难成为高回报生意。9 月交付回到 4 万台以上，但订单低于公司预期。基准 2030 年 90 万辆、7% 经营利润率、10 倍退出倍数，价值约 1,080 亿元——远低于市场隐含的约 2,300 亿元。', '月度交付（四季度能否月均 5.5 万辆以上）；2027 年交付与 ASP；汽车及 AI 分部毛利率与经营损益；海外首年销量。', '2027 年交付超过 70 万辆且分部（剔除 AI）利润率高于 8%（转向乐观）；或交付低于 50 万辆（转向悲观）。自动检查：集团营业收入同比连续两年下降。', NULL, '高盛按 1.6 倍市销率（约 1,800 亿元）、申万按 0.7 倍（约 800 亿元）；专家预计 2027 年 60—70 万辆。', '2026-10-23', '营业收入同比', '<', 0, 2),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'T4', 'AI 投入能变成回报（估值按主观判断直接计 1,000 亿元）', '经营', '存疑', '中', '1）MiMo 开源模型排名进入全球前列、OpenRouter 调用量第一（M8）。2）系统级 Agent（miclaw）、全屋智能、智驾、机器人都靠同一套模型；小米有十亿级设备入口，AI 回报会体现在每一类硬件的竞争力上。3）AI 是手机、家居、汽车体验的底座，不投入会失去竞争力；若形成新收入（token、订阅、机器人），会把成本变成资产。', '1）三年 AI 投入超 600 亿元（2026 年 160 亿元，挂在汽车及 AI 分部），没有商业化 KPI；API 价格降了最高 99%，管理层说“变现不是主要诉求”。2）与字节、阿里、苹果、华为相比，预算并不占优；回报若只是“不掉队”，那就是成本而不是投资。3）2026 年上半年分部经营亏损 57 亿元，主要来自 AI；AI 收入每季度约 10 亿元（含售后），1,000 亿元的估值缺少收入支撑。', 'AI 是新一代操作系统，不投入的手机厂商会被边缘化；现在的亏损是为十年后的入口付费。', '“不投入会被边缘化”恰好说明它是维持竞争力的成本，应该从利润里扣除。', '研究结论：目前更像维持竞争力的成本，回报没有收入支撑。估值按用户的主观判断，把 AI 当作一个整体直接估 1,000 亿元（参照国内大模型公司，见 J-AI 与竞争对手），不再单独扣除投入成本；股东回报折现仍只计成本。这是整个估值里把握最低的一项，每 100 亿元约 0.39 元/股。', 'AI 相关收入（汽车及 AI 分部“其他相关业务”：MiMo、订阅、机器人）；分部经营损益中 AI 的占比；投入规划与口径的调整；机器人量产；可比大模型公司的估值。', 'AI 收入每年超过 50 亿元且毛利为正，或手机、汽车出现由 AI 带来的可度量溢价。', NULL, '卖方普遍不单独扣 AI 成本（汽车与 AI 合并按市销率估值）；国内大模型公司按收入的几十到上百倍估值，智谱、MiniMax 市值较 7 月初回落约六到八成。粮厂研究员：年均 200 亿元 AI 预算“不是不重要，而是不宽裕”。', '2026-10-23', NULL, NULL, NULL, NULL),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'T5', '净现金与投资组合是价值的下限', '财务', '成立', '中', '6 月末现金储备 2,193 亿元、借款 393 亿元，另有对外投资 720.7 亿元（约 410 家公司）。扣除经营所需现金、租赁、基金外部出资人份额后，非经营部分约 1,680 亿元，约占市值 30%。', '现金里有约 1,000 亿元以上实际上是供应商的应付账款（贸易应付 1,183 亿元），经营萎缩时会流出；对外投资多为未上市优先股，估值有水分。', NULL, NULL, '成立：净现金仍在 1,800 亿元左右。', '现金储备、借款、投资者负债；投资公允价值变动。', '自动检查：年末带息负债超过货币资金（转为净负债）。', NULL, NULL, NULL, '净负债', '>', 0, 1),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'T6', '利润的现金含量：经营现金流覆盖利润', '财务', '观察', '中', '1）硬件公司靠负营运资本（先收款、后付款）运转（B9），经营现金流通常高于利润：2023—2025 年经营现金流÷归母净利 2.36、1.66、0.82。2）归母净利含大额投资公允价值收益（2025 年 133 亿元），比率被压低，需要看剔除后的口径。', '2026 年上半年经营现金流只有 20.5 亿元（备货、预付增加）；出货下滑时负营运资本会回流（B9）。', NULL, NULL, '观察：2026 年现金含量明显下降。', '经营现金流、存货、应付账款周转。', '自动检查：经营现金流÷归母净利润连续两年低于 0.6。', '股东回报折现的现金桥接见逐年假设；经营分部估值不依赖这一比率', NULL, NULL, '经营现金流÷归母净利润', '<', 0.6, 2),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'T7', '资本开支没有失控', '财务', '成立', '中', '轻资产生态＋外包制造的手机、自建工厂的汽车：2025 年资本开支 127.7 亿元、经营现金流 341.4 亿元（0.37）。', 'AI 基础设施与汽车新工厂会推高资本开支；若汽车与 AI 同时扩张，资本开支可能超过经营现金流的一半以上。', NULL, NULL, '成立：2026 年上半年资本开支 68.9 亿元。', '分部资本开支；工厂与算力投入。', '自动检查：资本开支÷经营现金流连续两年高于 0.6。', NULL, NULL, NULL, '资本开支÷经营现金流', '>', 0.6, 2),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'T8', '治理与股东回报：创始人主导的长期投入，回购是真回报（但被股权激励部分抵消）', '治理', '观察', '中', '1）公司不派现金股息，靠回购返还：2025 年 63 亿港元，2026 年至 10 月 12 日 125 亿港元（新计划上限 200 亿港元）。2）长期主义：高研发（2025 年 331 亿元）与汽车投入；回购时 A 类股按比例转换，不增加投票权占比。', '1）股权激励每年发股：9 月 B 类股增加约 3,550 万股；摊薄调整约 7 亿股，回购被部分抵消。2）回购在股价 21—39 港元区间进行，若内在价值低于回购价，回购反而损害长期股东。3）同股不同权：雷军通过 A 类股控制投票权，兼任董事长与 CEO；关键人风险；资本配置由个人判断主导（汽车、AI、机器人），外部股东难以约束。', NULL, NULL, '观察：2026 年回购约等于当年经调整净利润的一半以上；治理整体可信，但资本配置高度依赖创始人。', '回购金额与净股本变化；股权激励费用；关联交易、股权激励规模、投资组合与上市公司之间的利益安排。', '自动检查：回购÷归母净利润连续两年低于 10%。', NULL, NULL, NULL, '派息率', '<', 0.1, 2),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'T9', '25.8 港元已经反映了悲观预期，现价有安全边际', '估值', '观察', '低', '1）股价从 2025 年高点 61 港元跌到 26 港元，市值约 6,650 亿港元；可用净现金约 1,370 亿元加折后投资约 500 亿元，占市值三成多；公司年内回购 125 亿港元。2）按经营分部估值（AI 按 1,000 亿元），基准每股约 28.6 元（约 33.6 港元），概率加权约 30.2 元；即使 AI 按 0 计也有约 24.7 元，仍比现价高约 12%。3）现价对应的是：其余按本模型取值时，成熟业务（手机、AIoT、互联网）约 7.8 倍正常化盈利（本模型约 15.6 倍），或者汽车业务约 −630 亿元（本模型约 1,080 亿元）——汽车一文不值还要倒贴。', '1）高出现价的约 6.6 元里，约 3.9 元来自 AI 的主观估值，而可比大模型公司的市值半年内回落了六到八成。2）分开估值时 IoT 毛利率按结构升级后的 20%、互联网按 15.4 倍计；若费用按毛利分摊或三块用同一倍数，基准约 26.9—27.2 元。3）若 AI 按此前“只计成本”的口径（约 −1,011 亿元），基准约 20.8 元，低于现价。存储周期、汽车价格战都还没有见底。', '即使 AI 按 0、费用按毛利分摊，价值仍约 23.0 元，高于现价；三季报若显示手机毛利率回升，市场会提前反映。', '“AI 按 0”仍然偏高：AI 的投入由集团现金承担，按成本口径是负值；那时安全边际只剩约 5%。', '结论取决于 AI：AI 按 1,000 亿元时，现价比基准价值低约 23%，已低于 10% 安全边际的关注价（约 25.7 元、30.2 港元），但高于 30% 的关注价（约 20.0 元、23.5 港元）；AI 按成本口径时，现价高于价值。小米适合按“AI 值不值钱”分两种情形跟踪，而不是只看一个基准数。（原论点标“存疑”，与辩论裁决“势均力敌”不一致，合并后按辩论结论记为“观察”。）', '三季报（2026 年 11 月下旬）手机与 IoT 毛利率、生态费用率、汽车分部损益；可比大模型公司估值与小米 AI 收入；股价。', 'AI 形成可度量的收入（每年 50 亿元以上），或可比公司估值再大幅回落；手机与 IoT 毛利率连续两个季度低于基准。', '关注价按基准情景；C17 显示市场隐含的成熟业务倍数与汽车价值', '卖方目标价约 41—43 港元（高盛 2026 年 5 月 41 港元；另一家券商 5 月 43.3 港元，按主业 22 倍、汽车 2.4 倍市销率），与本模型的差异主要来自 AI、股权激励、投资收益的处理与倍数。', '2026-10-23', NULL, NULL, NULL, NULL);

INSERT INTO vi_lnk_thesis_facts (thesis_id, fact_id, "createdAt", "updatedAt")
SELECT x.id, y.id, now(), now() FROM (VALUES ('T1', '互联网服务：2025 年 374.4 亿元（+9.7%）、毛利率 76.5%；2026 年二季度 90.4 亿元（−0.6%）'), ('T1', '2025 年广告收入 285 亿元（+15.2%），境外互联网收入 126 亿元（占 33.8%）'), ('T1', '全球月活 2026 年 6 月 7.665 亿（+4.8%），中国大陆 1.977 亿（+7.0%）'), ('T1', '全球月活（12 月）2018—2025 年：2.42 亿 → 7.54 亿'), ('T1', 'AIoT 连接设备 11.608 亿台（+17.4%），五件以上设备用户 2,460 万（+20.2%）'), ('T1', '新一代 SU7 锁单用户中苹果手机用户近 60%（初代约 50%）'), ('T1', '生态（手机×AIoT）经营利润率：2024 年 8.6%、2025 年 7.9%、2026 年上半年 6.7%'), ('T2', '分业务毛利率 2019—2025 年：手机 7.2%→10.9%（2023 年 14.6%），IoT 11.2%→23.1%，互联网 64.7%→76.5%'), ('T2', '生态经营利润率 2019—2025 年：3.7%、3.7%、5.9%、2.9%、7.6%、8.6%、7.9%'), ('T2', '生态经营利润按季：2025 年 104.6、92.1、60.4、21.4 亿元，2026 年 60.6、48.5 亿元'), ('T2', '存储成本：4 百美元以下机型存储占物料成本 60% 以上（2025 年三季度约 30%）'), ('T2', '管理层：内存涨价超预期，三季度中途放缓、四季度缓涨'), ('T2', '2026 年二季度手机出货 3,120 万台（−26.5%）、ASP 1,351 元（+25.9%）、毛利率 8.5%'), ('T2', '2026 年二季度中国大陆：华为 23%、苹果 19%、小米 12%（820 万台，−21%）'), ('T2', 'Omdia 初步：2026 年三季度小米全球份额 12%（−2pt），中国大陆 800 万台（−20%）'), ('T3', '2025 年交付 411,082 辆、汽车收入 1,033 亿元、ASP 25.12 万元；2026 年目标 55 万辆'), ('T3', '2026 年二季度汽车及 AI 分部：收入 249.0 亿元、交付 104,199 辆、ASP 22.93 万元、毛利率 19.2%、经营亏损 26 亿元'), ('T3', '9 月小米汽车交付超 4 万台，澎程 30 天锁单超 7 万台；前三季度约 28.7 万台'), ('T3', '专家预计 2026 年交付 46—48.5 万辆，55 万目标难以完成'), ('T3', '专家对汽车单车利润的估计分歧大：约 0.5 万元到 2.5 万元'), ('T3', '零跑：上半年交付 35.65 万辆，二季度毛利率 12.6%、净利 6 亿元，全年净利指引降到约 30 亿元'), ('T3', '理想：2026 年二季度车辆毛利率 9.4%、经营亏损 23 亿元'), ('T3', '2026 年上半年毛利率：比亚迪 18.8%、特斯拉 18.7%、小鹏 20.6%、零跑 11.7%、理想 9.5%'), ('T4', '管理层：未来三年 AI 投入超 600 亿元，2026 年 160 亿元'), ('T4', '2025 年研发 331.3 亿元（+37.8%）；2026—2030 年累计研发预计超 2,000 亿元'), ('T4', '2026 年一季度汽车及 AI 分部经营亏损 31 亿元，交付 80,856 辆'), ('T4', '2026 年二季度汽车及 AI 分部：收入 249.0 亿元、交付 104,199 辆、ASP 22.93 万元、毛利率 19.2%、经营亏损 26 亿元'), ('T4', 'MiMo-V2.5 在 OpenRouter 周调用量第一（10.5 万亿 token），AI 收入仍很小'), ('T4', '智谱（02513.HK）2026-10-22 市值约 2,247 亿港元（约 1,912 亿元），较 6 月高点回落约八成'), ('T4', 'MiniMax（00100.HK）2026-10-22 市值约 566 亿港元（约 482 亿元）'), ('T4', '大模型公司按收入的几十到上百倍估值，市值里有大量刚融到的现金'), ('T5', '2026-06-30 现金储备 2,193 亿元，借款 393 亿元（含可换股债券 50.8 亿元）'), ('T5', '2026-06-30 现金类资产明细合计 2,274.7 亿元，比公司现金储备口径多 81.7 亿元'), ('T5', '2026-06-30 对外投资 720.7 亿元：权益法 66.1、普通股 185.8、优先股 382.4、其他 86.3'), ('T5', '投资者负债（基金外部出资人份额）：2025 年末 139.1 亿元，2026 年 6 月末非流动部分 142.3 亿元'), ('T5', '2026-06-30 租赁负债 50.4 亿元、购买无形资产应付款 50.7 亿元'), ('T6', '投资公允价值收益：2025 年 133.1 亿元，2026 年上半年 73.1 亿元（经调整净利润剔除）'), ('T6', '2026-06-30 现金储备 2,193 亿元，借款 393 亿元（含可换股债券 50.8 亿元）'), ('T7', '2026 年上半年资本开支 68.9 亿元：手机×AIoT 30.2、汽车及 AI 38.3'), ('T8', '2026 年回购：截至 10 月 12 日约 4.10 亿股、125 亿港元；新计划上限 200 亿港元'), ('T8', '2025 年回购 63 亿港元（1.526 亿股）；2026 年 1 月首次公告自动回购计划'), ('T8', '2026-09-30 在外股份 257.53 亿股：回购之外，股权激励新增 B 类股'), ('T8', '股权激励：2026 年上半年 23.2 亿元；摊薄调整约 7.0 亿股'), ('T8', '2025 年研发 331.3 亿元（+37.8%）；2026—2030 年累计研发预计超 2,000 亿元'), ('T9', '2026-10-22 收盘 25.80 港元（约 21.96 元），近一年最高收盘 47.14 港元'), ('T9', '2026-06-30 现金储备 2,193 亿元，借款 393 亿元（含可换股债券 50.8 亿元）'), ('T9', '2026-06-30 对外投资 720.7 亿元：权益法 66.1、普通股 185.8、优先股 382.4、其他 86.3'), ('T9', '2026 年回购：截至 10 月 12 日约 4.10 亿股、125 亿港元；新计划上限 200 亿港元'), ('T9', '高盛（2026-05）：核心 EV/NOPAT 16 倍、汽车 1.6 倍市销率，目标价 41 港元'), ('T9', '申万宏源（2026-08）：主业 334 亿元×25 倍＋汽车及 AI 0.7 倍市销率，目标市值 9,000 亿元以上'), ('T9', '智谱（02513.HK）2026-10-22 市值约 2,247 亿港元（约 1,912 亿元），较 6 月高点回落约八成')) v(k1, k2)
JOIN vi_thesis_base x ON x.company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND x.code = v.k1 JOIN vi_fact_base y ON y.company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND y.title = v.k2;

INSERT INTO vi_judgment_base (company_id, code, title, fact_layer, judgment, transmission, parameter, change_threshold, no_change_condition, counter_evidence, status) VALUES
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'J-METHOD', '估值方法：按发展阶段分部估值，股息贴现只作交叉验证', '小米没有现金股息，靠回购返还（2025 年回购÷归母约 15%，2026 年约一半）；集团里同时有成熟的手机×AIoT 生态（周期底部）、成长期的汽车（第三年、刚盈利又转亏）、投入期的 AI（三年 600 亿元）。归母净利含大额投资公允价值收益（2025 年 133 亿元）。', '用“经营分部估值”。手机、AIoT（IoT 与生活消费产品＋其他相关业务）、互联网服务三块分开，各按正常化盈利×倍数（不用周期底部或顶部的当年利润）：毛利率按公司披露的分项口径分别取，营业费用按收入分摊（见 J-OPEX）。汽车按 2030 年稳态盈利×退出倍数折回今天，加上到稳态前的现金流；AI 按用户的主观判断直接估值 1,000 亿元（见 J-AI）；现金、借款、租赁、经营所需现金、对外投资、基金外部出资人份额逐项列示。股息贴现里的“股息”＝回购，只回答“少数股东实际拿到多少现金”。', '每股价值＝(手机＋AIoT＋互联网＋汽车＋AI＋非经营部分)÷在外股本。基准：−420＋871＋3,039＋1,078＋1,000＋1,783＝7,351 亿元，每股 28.59 元。各部分的敏感性见下面各条判断。', '估值模型·主估值方法', '公司开始派发稳定股息或公布回购比例政策时，股息贴现可升为主估值之一；公司披露分业务费用时改用实际口径。', '单季利润波动。', '卖方常用“主业经调整市盈率＋汽车市销率”：它没有扣除股权激励，也把投资收益当经营利润。分开估值后，费用分摊与倍数的选择会改变价值：三块用同一倍数时基准约 27.0 元（−1.6 元）。', '已形成建议'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'J-PHONE', '手机：正常化毛利率 11.8%，按收入分摊费用后微亏', '手机毛利率 2019—2025 年 7.2%、8.7%、11.9%、9.0%、14.6%、12.6%、10.9%，2021—2025 年收入加权 11.8%；2026 年上半年 9.3%（二季度 8.5%，存储涨价）。手机收入 2021 年 2,088.7 亿元（高点）、2025 年 1,864.4 亿元，2026 年上半年 863.9 亿元（−10.1%）。按收入分摊费用后，手机 2021—2025 年经营利润率平均约 −1.3%，2026 年上半年 −5.2%；专家估计 2026 年手机硬件亏损 80—100 亿元。', '正常化（2028 年）收入 1,850 亿元（略低于 2025 年），毛利率 11.8%（2021—2025 年收入加权，含一次萧条与一次景气），费用率 14.0%，经营利润率 −2.2%：手机在全额分摊费用后是微亏的获客工具，它的价值体现在互联网与 IoT 上。倍数按“规模不再扩张”的永续年金（g＝0，倍数＝1÷r）。悲观：1,650 亿元、10.0%、15.0%；乐观：2,000 亿元、13.0%、13.0%。', '手机毛利率每 ±1pt：S1 约 ±150 亿元，每股约 ±0.58 元。基准 S1 约 −420 亿元（每股约 −1.63 元）。若手机的亏损随规模按 3% 增长，每股约 −0.34 元。', '经营分部 S1·收入、经营利润率', '存储价格回落后，手机毛利率连续四个季度高于 13% 或低于 10%。', '单季新品与促销节奏。', '高端化（ASP 1,351 元，中国大陆 3,000 元以上机型占 32%）可能让毛利率高于历史平均；反过来，中国大陆份额降到 12%、第五，低端被存储涨价打掉，规模可能回不到 1.65 亿台。', '已形成建议'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'J-AIOT', 'AIoT：正常化毛利率 20%（IoT 结构升级），费用率 14%', 'IoT 与生活消费产品毛利率 2019—2023 年 11.2%—16.3%，2024 年 20.3%、2025 年 23.1%（大家电、高端电视与境外拉动），2026 年上半年 22.3%；含毛利为负的“其他相关业务”后 2024 年 18.7%、2025 年 21.3%、2026 年上半年 21.2%。收入 2025 年 1,232.0 亿元（+18.3%，国补拉动），2026 年二季度 −19.2%（国补退坡）。', '正常化（2028 年）收入 1,300 亿元（含其他相关业务，约等于 2025 年），毛利率 20.0%（低于 2025 年、高于 2024 年，假设结构升级大体保住），费用率 14.0%，经营利润率 6.0%。倍数用情景的永续增长与新增投资回报率（基准 13.9 倍）。悲观：1,100 亿元、18.0%、15.0%；乐观：1,400 亿元、22.0%、13.0%。', 'AIoT 毛利率每 ±1pt：S2 约 ±131 亿元，每股约 ±0.51 元。基准 S2 约 871 亿元（每股约 3.39 元）。', '经营分部 S2·收入、经营利润率', 'IoT 毛利率（含其他相关业务）连续四个季度低于 18% 或高于 23%。', '国补带来的单季收入波动。', '2025 年的高毛利率有国补拉动高端家电的成分，国补退坡后可能回到 16%—18%（悲观情景）；境外 IoT 高速增长、空调冰箱自建工厂则支持更高毛利率。', '已形成建议'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'J-NET', '互联网服务：2027 年 385 亿元、毛利率 76.5%，倍数约 15.4 倍', '互联网收入 2023 年 301.1、2024 年 341.2、2025 年 374.4 亿元，2026 年上半年 185.1 亿元（约持平）；毛利率 2021—2025 年 74.1%、71.8%、74.2%、76.6%、76.5%。广告 2025 年 285 亿元（+15.2%），境外占互联网收入 33.8%；月活 7.665 亿（+4.8%）。', '不受存储周期影响，2027 年即为正常化年份：收入 385 亿元、毛利率 76.5%、费用率 14.0%，经营利润率 62.5%。轻资产，增长来自月活与单用户变现，倍数按永续增长 3%、新增投资回报率 50%：基准 15.4 倍（悲观 1.5%、30% → 10.6 倍；乐观 4%、60% → 22.8 倍）；不另加“生态溢价”。', '互联网永续增长 3%→2%：每股约 −1.40 元；新增投资回报率 50%→30%：约 −0.49 元；毛利率每 ±1pt：约 ±0.18 元。基准 S3 约 3,039 亿元（每股约 11.82 元），是最大的一块。', '经营分部 S3·收入、经营利润率、永续增长、新增投资回报率', '月活同比连续两年低于 2%，或互联网收入连续两季同比下降。', '游戏与金融科技的单季波动。', '互联网收入依赖手机出货带来的新用户（二季度出货 −26%）；按收入分摊的费用率 14% 可能低估了互联网实际占用的研发与销售资源（费用率改为 25% 时每股约 −0.43 元）。', '已形成建议'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'J-OPEX', '营业费用按收入分摊到三块业务（公司不拆分）', '公司只披露“手机×AIoT”分部的营业费用（集团研发、销售、行政减去汽车及 AI 分部经营开支），不拆到手机、IoT、互联网。费用率 2019—2025 年 10.2%—14.1%，2021—2025 年收入加权 13.1%；2026 年上半年 14.5%（收入下降、费用刚性）。按收入分摊时，2026 年上半年手机经营利润 −44.7 亿元，与专家“2026 年手机硬件亏损 80—100 亿元”的估计方向一致。', '三块用同一个费用率（按收入分摊）：基准 2026 年下半年 14.5%、2027 年 14.3%、正常化 14.0%（高于 2021—2025 年平均 13.1%，反映研发强度上升）；悲观 15.0%、乐观 13.0%（正常化）。互联网的正常化年份是 2027 年，直接取长期费用率 14.0%（若与同年的手机、AIoT 一样取 14.3%，每股约 −0.05 元）。这是假设：互联网实际占用的研发（系统、应用）与销售资源可能高于它的收入占比。', '费用率每 ±0.5pt（正常化年份，三块同时）：每股约 ∓0.64 元。分摊方式（总费用不变）：互联网费用率改为 25%，每股约 −0.43 元；按毛利分摊，约 −1.67 元。三块用同一倍数时分摊方式不影响合计。', '经营分部 S1—S3·经营利润率', '公司披露分业务的费用或经营利润；或生态费用率连续四个季度偏离 14% 超过 1.5pt。', '四季度费用的季节性。', '按毛利分摊会把更多费用给互联网（经营利润率约 27%），手机变成小幅盈利；哪种更接近真实，没有公开数据可以验证。', '已形成建议'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'J-MEM', '存储周期：2026 年下半年至 2027 年手机毛利率低于正常', '存储占低端机物料成本 60% 以上；手机毛利率 2025 年一季度 12.4% → 2026 年二季度 8.5%。管理层：三季度中途涨势放缓、四季度缓涨；TrendForce：明年 DRAM 仍偏紧。Omdia：三季度小米全球份额 12%（−2pt）。', '过渡期：手机毛利率 2026 年下半年 8.5%、2027 年 10.5%，AIoT 20.0%、20.0%，费用率 14.5%、14.3%。税后期间现金流：手机约 −101、AIoT 约 85、互联网（只有 2026 年下半年）约 96 亿元。悲观手机 8.0%/9.5%，乐观 9.0%/12.0%。', '过渡期手机毛利率每 −1pt：每股约 −0.08 元；手机与 AIoT 的正常化后移一年（2029 年）：约 −0.14 元。影响远小于正常化毛利率。', '经营分部 S1、S2·期间现金流', '三、四季度手机毛利率低于 7% 或高于 10%。', '单季度存储价格波动。', '若涨价持续到 2028 年以后，且低端市场永久萎缩，正常化毛利率本身要下调（见 J-PHONE）。', '已形成建议'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'J-EV', '汽车稳态：2030 年 90 万辆、经营利润率 7%', '2025 年交付 41.1 万辆、ASP 25.1 万元；2026 年预计 46—48.5 万辆、ASP 约 23.5 万元；澎程 30 天锁单超 7 万台；海外 2027 年起步（规划 2028 年 10—13 万台、2029 年 25—30 万台）。同行 2026 年上半年毛利率 9.5%—23%，零跑二季度净利率约 2%，理想经营亏损。', '基准：交付 2027 年 62 万、2028 年 72 万、2029 年 82 万、2030 年 90 万辆（国内约 70 万＋海外约 20 万），ASP 降到 22 万元，其他收入 3%；稳态经营利润率 7%（不含 AI），退出倍数 10 倍，折现率 11%（含执行风险溢价）。悲观：60 万辆、20.5 万元、3%、7 倍、12.5%；乐观：130 万辆、23.5 万元、9%、13 倍、10%。', '稳态利润率每 ±1pt：汽车价值 ±118 亿元，每股约 ±0.46 元；销量每 ±10 万辆：约 ±91 亿元，每股约 ±0.36 元。', '经营分部 S4', '2027 年交付低于 55 万辆或高于 70 万辆；汽车及 AI 分部（剔除 AI 后）利润率连续两个季度低于 4%。', '月度交付波动。', '新势力长期徘徊在 50 万辆附近会让规模效应消失（悲观情景）；反过来，海外打开、智驾领先可能让小米成为 100 万辆以上的盈利车企（乐观情景）。', '已形成建议'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'J-EV-SPLIT', '汽车与 AI 的成本拆分（公司不披露）', '分部经营损益：2025 年 +9 亿元（收入 1,060.7），2026 年上半年 −57 亿元（收入 447.6）。管理层：2026 年 AI 投入 160 亿元，主要由该分部承担。专家口径：汽车本身 2026 年利润 0.5—2.5 万元/辆，相差 4—5 倍。', '假设汽车本身（含智驾研发）经营利润率 2025 年约 10%、2026 年约 7.5%，倒推 AI 等新业务成本：2025 年约 100 亿元、2026 年约 170 亿元（上半年约 88 亿元）。汽车价值（S4）不扣 AI；AI 按直接估值单列（S5），股东回报折现里扣 AI 成本。汽车本身与 AI 成本合计与分部披露数一致。', '拆分影响 S4 的期间现金流和股东回报折现里的 AI 成本；AI 直接估值（S5）不受影响。', '经营分部 S4 期间现金流；股东回报折现的 AI 成本', '公司披露 AI 投入的实际金额或分部拆分。', '专家纪要的单车利润估计。', '若 160 亿元里有一部分在手机×AIoT 分部，三块业务的费用率里已含部分 AI 成本，汽车本身利润则更低、S4 价值更低。', '已形成建议'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'J-AI', 'AI：按主观判断直接估值 1,000 亿元（参照国内大模型公司）', '三年 AI 投入超 600 亿元（2026 年 160 亿元），2026 年上半年约 88 亿元（按 J-EV-SPLIT 推算）；MiMo-V2.5 调用量第一，但 AI 收入每季度约 10 亿元（含售后）。国内大模型公司（2026-10-22 市值或最近一轮融资）：MiniMax 约 482 亿元、阶跃星辰约 120 亿美元、智谱约 1,912 亿元、月之暗面 350 亿美元、DeepSeek 投前约 5,000 亿元；它们按收入的几十到上百倍估值，市值波动很大（智谱较 7 月初回落约 76%）。', '用户的主观判断：把 AI 作为一个整体直接估 1,000 亿元（三个情景相同），介于 MiniMax 与智谱之间。可比公司的估值已经包含未来的投入与亏损，所以分部估值不再单独扣 AI 的投入成本。股东回报折现（交叉验证）仍按实际现金流扣 AI 成本：2026 年下半年 83 亿元、2027 年 200 亿元、2028 年 230 亿元，之后每年 80 亿元（+2%）。', 'AI 每 ±100 亿元，每股约 ±0.39 元；AI 按 0 计，基准约 24.7 元（−3.89 元）。资金口径：可比公司的市值里有自己的现金，小米 AI 的投入由集团现金（已在分部估值项里全额计入）承担；若扣除剩余承诺投入的税后现值约 331 亿元，AI 约 669 亿元，每股约 −1.29 元。', '经营分部 S5；股东回报折现·AI 成本', '可比公司估值中枢变化超过 50%；AI 收入（MiMo、订阅、机器人）每年超过 50 亿元且毛利为正；或用户调整主观判断。', '模型排名与调用量的短期变化。', '小米 AI 主要服务自家设备，不是独立对外收费的模型公司；论点 T4 的裁决是“存疑”（辩论中反方占优：目前更像维持竞争力的成本）。按此前“只计成本”的口径，S5 约 −1,011 亿元，基准约 20.8 元。', '已形成建议'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'J-CASH', '可用净现金：现金储备−借款−租赁−无形资产应付款−经营所需现金', '现金储备 2,193 亿元（公司口径，比明细加总少 81.7 亿元）；借款 392.8 亿元；租赁负债 50.4 亿元；购买无形资产应付款 50.7 亿元。贸易应付款项 1,183 亿元、存货 849 亿元、应收 198 亿元。', '采用较低的公司口径 2,193 亿元。经营所需现金：基准 300 亿元（约一个月营业成本），悲观 600 亿元（负营运资本大幅回流），乐观 150 亿元。', '经营所需现金每 ±100 亿元，每股约 ∓0.39 元。', '分部估值项 C1—C6', '应付账款周转天数明显缩短，或现金储备口径变化。', '季度末的资金摆布。', '硬件公司的现金很大部分是供应商资金；但只要业务不收缩，这部分浮存是长期的（腾讯音乐同理）。', '已形成建议'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'J-INV', '对外投资打七折，扣除基金外部出资人份额', '对外投资 720.7 亿元：权益法 66.1、普通股 185.8（上市股权约 72）、优先股 382.4、其他投资 86.3；投资者负债（合并基金的外部出资人）非流动 142.3 亿元，流动部分 2025 年末 11.3 亿元。', '投资按 30% 折价（悲观 50%、乐观 15%）：优先股与基金份额是三级公允价值，流动性差、处置有税费。投资者负债 153.7 亿元全额扣除（不打折）。', '折价每 ±10pt，每股约 ∓0.28 元。', '分部估值项 C8、C9', '上市股权市值大幅变化（季度公允价值变动超过 50 亿元）；投资退出兑现。', '单季公允价值波动。', '2025—2026 年投资收益为正（133 亿元、73 亿元），说明组合有价值；但同一时期也有大额减值的历史（2022 年）。', '已形成建议'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'J-SHR', '股本：6 月末在外 257.09 亿股', '港交所月报表：6 月底已发行 257.85 亿股，其中 0.76 亿股已回购待注销；9 月底在外约 257.53 亿股（股权激励发股）。摊薄调整约 7 亿股。', '用 6 月末在外股本 257.09 亿股（与现金同日）。已授出未归属的股权激励不再加到股本里：其费用已在分部利润率里扣除，再加股本会重复。', '股本每 ±1%，每股价值约 ∓1%。若按摊薄股本（约 264 亿股），每股价值约 −2.7%。', '估值模型·股本', '年报或中报披露股本口径变化。', '月度回购与发股。', '若股权激励费用低估了真实稀释，应改用摊薄股本。', '已形成建议'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'J-R', '折现率：无风险利率 1.64%＋风险溢价 7.5%＝9.1%', '腾讯音乐风险溢价 7%；小米同时有硬件周期、汽车价格战、AI 投入与同股不同权。', '基准 9.1%（风险溢价 7.5%），悲观 10.5%、乐观 8.1%。汽车分部另加执行风险：基准 11%、悲观 12.5%、乐观 10%。', '折现率 +1pt（9.1%→10.1%）：三块业务的倍数都下降（手机 11.0→9.9 倍、AIoT 13.9→12.0 倍、互联网 15.4→13.2 倍），基准每股约 −2.0 元；−1pt 约 +2.8 元。汽车用自己的折现率（11%），AI 直接估值不折现，都不随之变化。', '估值模型·风险溢价；情景折现率', '无风险利率变化超过 50bp 并持续。', '单日利率波动。', '港股流动性折价可能要求更高回报。', '已形成建议'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'J-MULT', '三块业务的倍数按价值驱动公式：手机 11.0、AIoT 13.9、互联网 15.4 倍', '生态业务轻资产、负营运资本。手机已不再扩张（出货在 1.46—1.90 亿台之间徘徊）；IoT 有出海与大家电的增长；互联网几乎不需要资本。卖方给核心业务 16—25 倍（经调整口径）；高盛悲观 6 倍。', '倍数＝(1−g÷新增投资回报率)÷(r−g)，r＝9.1%：手机 g＝0 → 11.0 倍；AIoT 用情景值 g＝3%、新增投资回报率 20% → 13.9 倍；互联网 g＝3%、新增投资回报率 50% → 15.4 倍。三块合计约 15.6 倍。悲观（r＝10.5%）：手机 9.5、AIoT 9.7、互联网 10.6 倍；乐观（r＝8.1%）：12.3、18.7、22.8 倍。', '三块都用 AIoT 的倍数（13.9 倍）时，基准每股约 −1.4 元；再把互联网的正常化年份也放到 2028 年，约 −1.6 元。', '情景·新增投资回报率、永续增长；经营分部 S1、S3 的专属参数', '增长或回报率的长期证据变化。', '市场估值情绪。', '卖方倍数用的是经调整利润（不扣股权激励、含投资收益），与本模型口径不同。互联网的高倍数依赖月活继续增长；手机的亏损若随规模增长（g＝3%），每股约 −0.34 元。', '已形成建议'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'J-SUB', '政府补助按常态部分资本化', '其他收入（以补贴为主）2019—2025 年 6—27 亿元，2026 年上半年 32.5 亿元。', '常态补贴每年 15 亿元（悲观 5、乐观 25），税后×8 倍（悲观 6、乐观 10）资本化：基准约 100 亿元。不放进三块业务的经营利润率，避免和业务倍数混在一起。', '每股约 +0.39 元（基准）。', '分部估值项 C11', '补贴政策变化。', '单季补贴波动。', '补贴与汽车、AI 投资绑定，投资放缓时会减少。', '已形成建议'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'J-PROB', '情景概率 25% / 50% / 25%', '三个情景分别对应：存储周期拖长、IoT 结构升级回落、汽车停在 60 万辆（悲观）；周期正常、IoT 保住结构升级、汽车 90 万辆（基准）；手机高端化成功、IoT 出海放量、汽车 130 万辆（乐观）。AI 三个情景都按 1,000 亿元。', '对称分布：悲观 25%、基准 50%、乐观 25%。概率加权价值只是参考，关注价仍按基准情景。', '把悲观概率从 25% 调到 35%（基准降到 40%），加权价值约 −1.35 元（30.18 → 28.82 元）。', '情景·情景概率', '季度数据明显偏向某个情景。', '—', '分布未必对称：汽车与 AI 的结果更像“要么成、要么不成”；AI 在三个情景里取同一个值，概率加权没有反映 AI 的不确定性。', '已形成建议'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'J-PAYOUT', '股东回报率（股息贴现交叉验证用）', '2025 年回购 61.7 亿元（归母 416.4 亿元，约 15%）；2026 年至 10 月 12 日 125 亿港元（约 106 亿元）；不派股息。', '2026 年 77%（全年回购约 128 亿元÷预测归母约 166 亿元），2027—2030 年 50%，2031 年起 60%。', '只影响股息贴现（交叉验证），不影响分部估值。', '逐年假设·派息率（＝回购÷归母净利）', '公司公布回购比例或股息政策。', '单月回购节奏。', '若用回购把现金长期返还，股息贴现会接近分部估值；若停止回购，少数股东拿到的现金会很少。', '已形成建议'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'J-OTHER', '逐年假设里的利息收入、补贴与投资收益', '利息收入 2025 年 53.8 亿元、2026 年上半年 25.7 亿元；补贴 2026 年上半年 32.5 亿元；投资公允价值收益波动大（2025 年 133 亿元）。', '其他净贡献＝利息收入（2026 年 50 → 2029 年起 40 亿元）＋补贴（2026 年 47、之后 15 亿元）。不预测投资公允价值收益（分部估值里投资单列），所以预测的归母净利低于报表口径。', '只影响股息贴现与预测计算；分部估值不读预测计算。', '逐年假设·其他净贡献', '利率或现金规模大幅变化。', '—', '—', '已形成建议'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'J-FX', '港元兑人民币', '近一年港元兑人民币从 0.9163 降到 0.8515（人民币升值约 7%）。', '估值用人民币；市场价按股价日汇率折算，驾驶舱同时给出港元价值。', '汇率每 ±1%，人民币市场价 ±1%，不改经营假设。', '公司·股价汇率指标', '—', '—', '—', '已形成建议'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'J-IND', '印度冻结资金与潜在罚款', '约 35.36 亿元资金受限，案件在听证阶段，公司未计提重大拨备。', '基准、悲观从现金里扣除 35.36 亿元（视为不可用），乐观不扣。罚款风险不单独计价。', '每股约 −0.14 元。', '分部估值项 C7', '判决或和解。', '程序性进展。', '若败诉，损失可能超过冻结金额。', '已形成建议'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'J-REPAT', '资金汇出成本（估算）', '公司在境外有配售所得（2025 年约 425 亿港元）、美元债和海外业务利润，回购用港元支付；年报未找到中国附属公司未分派利润的预扣税附注。', '基准扣 30 亿元（约 600 亿元境内资金按 5% 协定税率汇出），悲观 70 亿元，乐观 0。待读年报附注后更新。', '每 10 亿元约 0.04 元/股。', '分部估值项 C6', '取得未分派利润与预扣税的披露。', '—', '境外现金足够回购时，汇出成本可能接近 0。', '已形成建议'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'J-MAU', '逐年假设：月活×每月活用户年收入', '月活 2025 年末 7.541 亿、2026 年 6 月 7.665 亿；集团收入÷年末月活 2024 年 521 元、2025 年 606 元。', '业务量＝年末全球月活：2026 年 7.75 亿，之后每年约 +2.5%（2030 年 8.55 亿），再 +2%。单价＝集团收入÷月活（汽车与 AI 收入也摊到每个用户上，反映“人车家”的单用户收入）。收入、成本由分部假设汇总：手机＋AIoT＋互联网＋汽车（不含 AI）−AI 成本。', '预测计算只服务于股息贴现交叉验证与资产负债滚动；分部估值直接用分部参数。', '逐年假设·业务量、单价', '月活口径变化。', '—', '汽车收入与手机月活关系不紧密（汽车用户约六成用苹果手机）。', '已形成建议');

INSERT INTO vi_lnk_judgment_facts (judgment_id, fact_id, "createdAt", "updatedAt")
SELECT j.id, f.id, now(), now() FROM (VALUES ('J-METHOD', '2025 年收入 4,572.9 亿元，经调整净利润 391.7 亿元'), ('J-METHOD', '2025 年分部：手机×AIoT 3,512.2 亿元（毛利率 21.7%），汽车及 AI 1,060.7 亿元（经营收益 9 亿元）'), ('J-METHOD', '分业务毛利率 2019—2025 年：手机 7.2%→10.9%（2023 年 14.6%），IoT 11.2%→23.1%，互联网 64.7%→76.5%'), ('J-METHOD', '管理层：未来三年 AI 投入超 600 亿元，2026 年 160 亿元'), ('J-METHOD', '投资公允价值收益：2025 年 133.1 亿元，2026 年上半年 73.1 亿元（经调整净利润剔除）'), ('J-METHOD', '2026 年回购：截至 10 月 12 日约 4.10 亿股、125 亿港元；新计划上限 200 亿港元'), ('J-METHOD', '实际所得税率：2024 年 16.2%、2025 年 16.3%、2026 年上半年 17.9%'), ('J-METHOD', '卖方 2026—2028 年归母净利预测：约 278—291、367—373、434—447 亿元'), ('J-PHONE', '分业务毛利率 2019—2025 年：手机 7.2%→10.9%（2023 年 14.6%），IoT 11.2%→23.1%，互联网 64.7%→76.5%'), ('J-PHONE', '2026 年上半年分业务：手机毛利率 9.3%、AIoT（含其他）21.2%、互联网 76.4%；按收入分摊费用后经营利润 −44.7、39.3、114.6 亿元'), ('J-PHONE', '2026 年二季度手机出货 3,120 万台（−26.5%）、ASP 1,351 元（+25.9%）、毛利率 8.5%'), ('J-PHONE', '2025 年手机收入 1,864.4 亿元、毛利率 10.9%、出货 1.652 亿台；四季度毛利率 8.3%'), ('J-PHONE', '专家：2026 年手机硬件预计亏损 80—100 亿元，IoT 与互联网托底'), ('J-PHONE', '2026 年二季度中国大陆：华为 23%、苹果 19%、小米 12%（820 万台，−21%）'), ('J-AIOT', '分业务毛利率 2019—2025 年：手机 7.2%→10.9%（2023 年 14.6%），IoT 11.2%→23.1%，互联网 64.7%→76.5%'), ('J-AIOT', '2026 年上半年分业务：手机毛利率 9.3%、AIoT（含其他）21.2%、互联网 76.4%；按收入分摊费用后经营利润 −44.7、39.3、114.6 亿元'), ('J-AIOT', '2026 年二季度 IoT 与生活消费产品收入 312.8 亿元（−19.2%），国补退坡'), ('J-AIOT', '2025 年 IoT 收入 1,232.0 亿元（+18.3%）、毛利率 23.1%；大家电 +23.1%'), ('J-AIOT', 'AIoT 连接设备 11.608 亿台（+17.4%），五件以上设备用户 2,460 万（+20.2%）'), ('J-NET', '互联网服务：2025 年 374.4 亿元（+9.7%）、毛利率 76.5%；2026 年二季度 90.4 亿元（−0.6%）'), ('J-NET', '2025 年广告收入 285 亿元（+15.2%），境外互联网收入 126 亿元（占 33.8%）'), ('J-NET', '全球月活 2026 年 6 月 7.665 亿（+4.8%），中国大陆 1.977 亿（+7.0%）'), ('J-NET', '全球月活（12 月）2018—2025 年：2.42 亿 → 7.54 亿'), ('J-NET', '分业务毛利率 2019—2025 年：手机 7.2%→10.9%（2023 年 14.6%），IoT 11.2%→23.1%，互联网 64.7%→76.5%'), ('J-OPEX', '生态营业费用率 2019—2025 年：10.2%、11.2%、11.8%、14.1%、13.6%、12.6%、13.7%；2026 年上半年 14.5%'), ('J-OPEX', '“手机×AIoT”分部营业费用率：2025 年四季度 17.4%、2026 年一季度 14.9%、二季度 14.2%'), ('J-OPEX', '2026 年上半年分业务：手机毛利率 9.3%、AIoT（含其他）21.2%、互联网 76.4%；按收入分摊费用后经营利润 −44.7、39.3、114.6 亿元'), ('J-OPEX', '专家：2026 年手机硬件预计亏损 80—100 亿元，IoT 与互联网托底'), ('J-OPEX', '生态（手机×AIoT）经营利润率：2024 年 8.6%、2025 年 7.9%、2026 年上半年 6.7%'), ('J-OPEX', '智能电动汽车等创新业务费用：2022 年 31 亿元、2023 年 67 亿元'), ('J-MEM', '存储成本：4 百美元以下机型存储占物料成本 60% 以上（2025 年三季度约 30%）'), ('J-MEM', '管理层：内存涨价超预期，三季度中途放缓、四季度缓涨'), ('J-MEM', '2026 年二季度手机出货 3,120 万台（−26.5%）、ASP 1,351 元（+25.9%）、毛利率 8.5%'), ('J-MEM', '2025 年手机收入 1,864.4 亿元、毛利率 10.9%、出货 1.652 亿台；四季度毛利率 8.3%'), ('J-MEM', 'Omdia 初步：2026 年三季度小米全球份额 12%（−2pt），中国大陆 800 万台（−20%）'), ('J-EV', '2025 年交付 411,082 辆、汽车收入 1,033 亿元、ASP 25.12 万元；2026 年目标 55 万辆'), ('J-EV', '2026 年二季度汽车及 AI 分部：收入 249.0 亿元、交付 104,199 辆、ASP 22.93 万元、毛利率 19.2%、经营亏损 26 亿元'), ('J-EV', '9 月小米汽车交付超 4 万台，澎程 30 天锁单超 7 万台；前三季度约 28.7 万台'), ('J-EV', '专家预计 2026 年交付 46—48.5 万辆，55 万目标难以完成'), ('J-EV', '2026 年上半年毛利率：比亚迪 18.8%、特斯拉 18.7%、小鹏 20.6%、零跑 11.7%、理想 9.5%'), ('J-EV', '零跑：上半年交付 35.65 万辆，二季度毛利率 12.6%、净利 6 亿元，全年净利指引降到约 30 亿元'), ('J-EV', '理想：2026 年二季度车辆毛利率 9.4%、经营亏损 23 亿元'), ('J-EV-SPLIT', '汽车及 AI 分部经营开支：2024 年 132 亿元、2025 年 248 亿元，2026 年一、二季度 71、74 亿元'), ('J-EV-SPLIT', '管理层：未来三年 AI 投入超 600 亿元，2026 年 160 亿元'), ('J-EV-SPLIT', '专家对汽车单车利润的估计分歧大：约 0.5 万元到 2.5 万元'), ('J-EV-SPLIT', '2025 年分部：手机×AIoT 3,512.2 亿元（毛利率 21.7%），汽车及 AI 1,060.7 亿元（经营收益 9 亿元）'), ('J-EV-SPLIT', '2026 年一季度汽车及 AI 分部经营亏损 31 亿元，交付 80,856 辆'), ('J-AI', '管理层：未来三年 AI 投入超 600 亿元，2026 年 160 亿元'), ('J-AI', 'MiMo-V2.5 在 OpenRouter 周调用量第一（10.5 万亿 token），AI 收入仍很小'), ('J-AI', '智谱（02513.HK）2026-10-22 市值约 2,247 亿港元（约 1,912 亿元），较 6 月高点回落约八成'), ('J-AI', 'MiniMax（00100.HK）2026-10-22 市值约 566 亿港元（约 482 亿元）'), ('J-AI', '月之暗面（Kimi）2026 年 7 月 F 轮投后估值 350 亿美元'), ('J-AI', '阶跃星辰 2026 年 5 月 Pre-IPO 轮后估值约 120 亿美元'), ('J-AI', 'DeepSeek 2026 年 8 月第二轮融资投前估值约 5,000 亿元'), ('J-AI', '大模型公司按收入的几十到上百倍估值，市值里有大量刚融到的现金'), ('J-AI', '2025 年研发 331.3 亿元（+37.8%）；2026—2030 年累计研发预计超 2,000 亿元'), ('J-CASH', '2026-06-30 现金储备 2,193 亿元，借款 393 亿元（含可换股债券 50.8 亿元）'), ('J-CASH', '2026-06-30 现金类资产明细合计 2,274.7 亿元，比公司现金储备口径多 81.7 亿元'), ('J-CASH', '2026-06-30 租赁负债 50.4 亿元、购买无形资产应付款 50.7 亿元'), ('J-INV', '2026-06-30 对外投资 720.7 亿元：权益法 66.1、普通股 185.8、优先股 382.4、其他 86.3'), ('J-INV', '投资者负债（基金外部出资人份额）：2025 年末 139.1 亿元，2026 年 6 月末非流动部分 142.3 亿元'), ('J-INV', '投资公允价值收益：2025 年 133.1 亿元，2026 年上半年 73.1 亿元（经调整净利润剔除）'), ('J-SHR', '2026-06-30 在外股份 257.09 亿股（已发行 257.85 亿股，扣除待注销回购 0.76 亿股）'), ('J-SHR', '2026-09-30 在外股份 257.53 亿股：回购之外，股权激励新增 B 类股'), ('J-SHR', '股权激励：2026 年上半年 23.2 亿元；摊薄调整约 7.0 亿股'), ('J-R', '2026-10-22 收盘 25.80 港元（约 21.96 元），近一年最高收盘 47.14 港元'), ('J-MULT', '高盛（2026-05）：核心 EV/NOPAT 16 倍、汽车 1.6 倍市销率，目标价 41 港元'), ('J-MULT', '申万宏源（2026-08）：主业 334 亿元×25 倍＋汽车及 AI 0.7 倍市销率，目标市值 9,000 亿元以上'), ('J-MULT', '互联网服务：2025 年 374.4 亿元（+9.7%）、毛利率 76.5%；2026 年二季度 90.4 亿元（−0.6%）'), ('J-MULT', '手机出货 2020—2025 年：1.464、1.903、1.505、1.456、1.685、1.652 亿台'), ('J-SUB', '其他收入（主要是补贴）：2019—2025 年 6—27 亿元，2026 年上半年 32.5 亿元'), ('J-PROB', '专家预计 2026 年交付 46—48.5 万辆，55 万目标难以完成'), ('J-PROB', '管理层：内存涨价超预期，三季度中途放缓、四季度缓涨'), ('J-PAYOUT', '2026 年回购：截至 10 月 12 日约 4.10 亿股、125 亿港元；新计划上限 200 亿港元'), ('J-PAYOUT', '2025 年回购 63 亿港元（1.526 亿股）；2026 年 1 月首次公告自动回购计划'), ('J-OTHER', '其他收入（主要是补贴）：2019—2025 年 6—27 亿元，2026 年上半年 32.5 亿元'), ('J-OTHER', '投资公允价值收益：2025 年 133.1 亿元，2026 年上半年 73.1 亿元（经调整净利润剔除）'), ('J-FX', '2026-10-22 收盘 25.80 港元（约 21.96 元），近一年最高收盘 47.14 港元'), ('J-IND', '印度：491.7 亿卢比（约 35.4 亿元）资金被冻结，案件在听证阶段'), ('J-REPAT', '2026-06-30 现金储备 2,193 亿元，借款 393 亿元（含可换股债券 50.8 亿元）'), ('J-REPAT', '2025 年回购 63 亿港元（1.526 亿股）；2026 年 1 月首次公告自动回购计划'), ('J-MAU', '全球月活 2026 年 6 月 7.665 亿（+4.8%），中国大陆 1.977 亿（+7.0%）'), ('J-MAU', '全球月活（12 月）2018—2025 年：2.42 亿 → 7.54 亿'), ('J-MAU', '新一代 SU7 锁单用户中苹果手机用户近 60%（初代约 50%）')) v(jc, ft)
JOIN vi_judgment_base j ON j.company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND j.code = v.jc JOIN vi_fact_base f ON f.company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND f.title = v.ft;

INSERT INTO vi_lnk_judgment_theses (judgment_id, thesis_id, "createdAt", "updatedAt")
SELECT j.id, t.id, now(), now() FROM (VALUES ('J-METHOD', 'T9'), ('J-PHONE', 'T1'), ('J-PHONE', 'T2'), ('J-AIOT', 'T1'), ('J-NET', 'T1'), ('J-OPEX', 'T1'), ('J-MEM', 'T2'), ('J-EV', 'T3'), ('J-EV-SPLIT', 'T3'), ('J-EV-SPLIT', 'T4'), ('J-AI', 'T4'), ('J-AI', 'T9'), ('J-CASH', 'T5'), ('J-INV', 'T5'), ('J-SHR', 'T8'), ('J-R', 'T9'), ('J-MULT', 'T1'), ('J-MULT', 'T9'), ('J-SUB', 'T5'), ('J-PROB', 'T9'), ('J-PAYOUT', 'T8'), ('J-OTHER', 'T5'), ('J-FX', 'T9'), ('J-IND', 'T5'), ('J-REPAT', 'T5'), ('J-MAU', 'T1')) v(jc, tc)
JOIN vi_judgment_base j ON j.company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND j.code = v.jc JOIN vi_thesis_base t ON t.company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND t.code = v.tc;

INSERT INTO vi_biz_model_base (company_id, code, element, title, content, metric, trend) VALUES
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'B1', '客户细分', '全球 7.67 亿月活，境外收入约 36%', '中国大陆月活 1.98 亿，境外占多数（东南亚、拉美、中东份额第二，欧洲、非洲第三）；汽车客户以一二线城市年轻用户和家庭用户为主。', '2026 年上半年境外收入占 37.9%', '境外用户 ARPU 低、对价格敏感，存储涨价打击最大。'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'B2', '价值主张', '“感动人心、价格厚道”：同配置更便宜，并逐步高端化', '2018 年承诺硬件综合净利率不超过 5%；手机覆盖 Redmi（入门）到 Xiaomi 数字旗舰与 Ultra（4,000—10,000 元），与徕卡合作影像；IoT 覆盖可穿戴、平板、电视、大家电；汽车 SU7、YU7、澎程覆盖 20—35 万元。', 'ASP 1,351 元（2026Q2，历史新高）；中国大陆 3,000 元以上机型占比 32.1%', '高端化提高了单价，但在 3,000 元以上市场华为、苹果份额也在上升；低端是被存储涨价伤得最重的价位段。'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'B3', '渠道通路', '线上起家，线下自建新零售，汽车共用渠道', '小米之家在中国大陆约 1.6—1.8 万家（500 平米以上大店 270 多家），境外新零售门店 640 多家，计划年底超过 1,000 家；汽车门店 477 家（2025 年末）。电商（小米商城、京东、天猫）与海外运营商渠道。', '2025 年销售费用 332.1 亿元（收入的 7.3%）', '门店扩张推高费用；国补退坡后门店客流与家电销售下降。'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'B4', '客户关系', '设备即账户：硬件卖出后，互联网服务持续变现', '手机、IoT 与汽车用户使用同一套小米账号与澎湃 OS，设备在用户手里，就持续带来互联网服务收入（B5）——这是“硬件按接近成本定价”能成立的前提（M1）。品牌与创始人号召力维系用户（M4）；汽车吸引了大量非小米手机用户。', '新一代 SU7 锁单用户中苹果手机用户近 60%（初代约 50%）', '家庭内设备通过米家形成锁定（M6）；但汽车用户与手机生态的重合度不高，锁定不延伸到汽车。'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'B5', '收入来源', '硬件按接近成本定价获客、互联网变现：手机四成、IoT 近三成、汽车两成多', '手机、IoT 收入＝出货×ASP，汽车收入＝交付×ASP，互联网收入＝月活×每用户变现。2025 年收入 4,572.9 亿元：手机 1,864.4（40.8%）、IoT 与生活消费产品 1,232.0（26.9%）、互联网服务 374.4（8.2%）、其他 41.4、汽车及 AI 1,060.7（23.2%）。', '2025 年收入 4,572.9 亿元；互联网收入占 8%，贡献生态毛利约 38%', '2026 年上半年汽车占比升到 21.5%，手机与 IoT 收入同比下降。'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'B6', '核心资源', '用户与设备基础、自研 OS 与芯片、品牌、生态链投资', '全球 7 亿多月活的设备与用户基础（B1）；自研：澎湃 OS、玄戒芯片（出货超百万）、MiMo 大模型（能否成为壁垒待验证，M8）；品牌与创始人号召力（M4）；汽车工厂；生态链投资约 410 家公司、账面 920 亿元。', '对外投资 720.7 亿元（不含理财）', '管理层：未来三年 AI 投入超 600 亿元，2026 年 160 亿元。'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'B7', '关键业务', '产品定义、OS 与互联网运营、供应链管理、新零售；手机外包、汽车自造', '产品定义与设计（手机、IoT、汽车）、操作系统与互联网服务运营、供应链管理与成本控制（M2）、新零售渠道运营（M3）；手机外包制造，汽车自建工厂、自主量产（M5）；AI 与芯片研发。', '2026—2030 年累计研发预计超 2,000 亿元', '汽车量产与供应链组织能力还在验证（M5）。'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'B8', '重要合作', '核心器件供应商、徕卡与谷歌、生态链公司', '供应商：高通、联发科（SoC），三星、海力士、美光、长鑫（存储），京东方等（屏幕），宁德时代（动力电池，SU7/YU7 曾占约八成）；徕卡（影像）；谷歌（境外安卓与服务）；电商平台与海外运营商（渠道见 B3）；生态链被投企业（B6）。', '宁德时代曾占 SU7/YU7 动力电池约八成', '关键器件依赖少数供应商；生态链公司的利益与小米并不总是一致。'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'B9', '成本结构', '物料成本为主、费用率约 16%；生态利润几乎全靠互联网毛利；负营运资本', '生态利润＝硬件毛利（手机＋IoT）＋互联网毛利−研发、销售、行政费用。2025 年：手机毛利 202.7＋IoT 284.2＋互联网 286.4−其他 12.9＝760.4 亿元，费用 482.0 亿元，经营利润 278.4 亿元，几乎等于互联网毛利。汽车单独算：利润＝毛利−汽车研发与渠道费用；AI 目前只有成本。成本：2025 年营业成本 3,554.8 亿元（收入的 77.7%）；研发 331.3（7.2%）、销售 332.1（7.3%）、行政 66.5 亿元（1.5%）；存储、SoC、屏幕是物料大头，低端手机存储占物料成本 60% 以上（2025 年三季度约 30%）。单位经济（每部手机毛利约 120 元，每辆车毛利约 4—6 万元）：手机 2025 年 ASP 1,128.7 元×毛利率 10.9%≈123 元（2026 年二季度 1,351 元×8.5%≈115 元）；互联网 374.4 亿元÷7.54 亿月活≈50 元/年，毛利率 76%；汽车 2025 年 ASP 25.1 万元×分部毛利率 24.3%≈6.1 万元，2026 年二季度 22.9 万元×19.2%≈4.4 万元，分部每辆车经营亏损约 2.5 万元（含 AI）。资本：贸易应付 1,183.3 亿元，存货 848.8、应收 197.7 亿元（2026-06-30）：先收款后付款，现金里有一部分是供应商资金。手机外包制造，资本开支低；汽车自建工厂、AI 买算力，2026 年上半年资本开支 68.9 亿元，汽车及 AI 占 56%。不派股息，回购为主。', '2025 年生态经营利润率 7.9%、互联网毛利 286.4 亿元；研发 331 亿元，股权激励每年约 45—50 亿元；每辆车经营损益：2025 年＋0.2 万元，2026 年二季度 −2.5 万元（含 AI）；现金储备 2,193 亿元；2025 年经营现金流 341.4 亿元', '存储涨价让硬件毛利塌陷（T2），成本受全球存储周期左右、小米议价力有限；互联网毛利是利润底座（T1）；AI 每年 160—230 亿元的投入正在吃掉生态利润的一半以上（T4），研发与 AI 投入是半固定成本；汽车的单车经济取决于 ASP 和 AI 摊销，手机靠“量”，量在下滑；出货下滑时负营运资本回流（2026 年一季度经营现金流 −17.9 亿元）。');

INSERT INTO vi_lnk_biz_model_facts (biz_model_id, fact_id, "createdAt", "updatedAt")
SELECT x.id, y.id, now(), now() FROM (VALUES ('B1', '全球月活 2026 年 6 月 7.665 亿（+4.8%），中国大陆 1.977 亿（+7.0%）'), ('B1', '新一代 SU7 锁单用户中苹果手机用户近 60%（初代约 50%）'), ('B2', '2026 年二季度手机出货 3,120 万台（−26.5%）、ASP 1,351 元（+25.9%）、毛利率 8.5%'), ('B2', '2026 年二季度中国大陆：华为 23%、苹果 19%、小米 12%（820 万台，−21%）'), ('B3', '小米之家：中国大陆约 1.6—1.8 万家，境外新零售门店超 640 家'), ('B3', '2025 年交付 411,082 辆、汽车收入 1,033 亿元、ASP 25.12 万元；2026 年目标 55 万辆'), ('B4', '新一代 SU7 锁单用户中苹果手机用户近 60%（初代约 50%）'), ('B4', 'AIoT 连接设备 11.608 亿台（+17.4%），五件以上设备用户 2,460 万（+20.2%）'), ('B5', '2025 年收入 4,572.9 亿元，经调整净利润 391.7 亿元'), ('B5', '2025 年分部：手机×AIoT 3,512.2 亿元（毛利率 21.7%），汽车及 AI 1,060.7 亿元（经营收益 9 亿元）'), ('B6', '2026-06-30 对外投资 720.7 亿元：权益法 66.1、普通股 185.8、优先股 382.4、其他 86.3'), ('B6', '管理层：未来三年 AI 投入超 600 亿元，2026 年 160 亿元'), ('B7', '2025 年研发 331.3 亿元（+37.8%）；2026—2030 年累计研发预计超 2,000 亿元'), ('B8', '2026-06-30 对外投资 720.7 亿元：权益法 66.1、普通股 185.8、优先股 382.4、其他 86.3'), ('B8', '管理层：未来三年 AI 投入超 600 亿元，2026 年 160 亿元'), ('B9', '2025 年分部：手机×AIoT 3,512.2 亿元（毛利率 21.7%），汽车及 AI 1,060.7 亿元（经营收益 9 亿元）'), ('B9', '生态（手机×AIoT）经营利润率：2024 年 8.6%、2025 年 7.9%、2026 年上半年 6.7%'), ('B9', '互联网服务：2025 年 374.4 亿元（+9.7%）、毛利率 76.5%；2026 年二季度 90.4 亿元（−0.6%）'), ('B9', '存储成本：4 百美元以下机型存储占物料成本 60% 以上（2025 年三季度约 30%）'), ('B9', '2025 年研发 331.3 亿元（+37.8%）；2026—2030 年累计研发预计超 2,000 亿元'), ('B9', '股权激励：2026 年上半年 23.2 亿元；摊薄调整约 7.0 亿股'), ('B9', '2026 年二季度手机出货 3,120 万台（−26.5%）、ASP 1,351 元（+25.9%）、毛利率 8.5%'), ('B9', '2026 年二季度汽车及 AI 分部：收入 249.0 亿元、交付 104,199 辆、ASP 22.93 万元、毛利率 19.2%、经营亏损 26 亿元'), ('B9', '2025 年交付 411,082 辆、汽车收入 1,033 亿元、ASP 25.12 万元；2026 年目标 55 万辆'), ('B9', '2026-06-30 现金储备 2,193 亿元，借款 393 亿元（含可换股债券 50.8 亿元）'), ('B9', '2026 年上半年资本开支 68.9 亿元：手机×AIoT 30.2、汽车及 AI 38.3'), ('B9', '2026 年回购：截至 10 月 12 日约 4.10 亿股、125 亿港元；新计划上限 200 亿港元')) v(k1, k2)
JOIN vi_biz_model_base x ON x.company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND x.code = v.k1 JOIN vi_fact_base y ON y.company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND y.title = v.k2;

INSERT INTO vi_value_chain_base (company_id, code, position, participant, role, force, power, effect, trend, profit_share, analysis, counter) VALUES
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'V1', '本公司环节', '小米：设计、软件（澎湃 OS）、品牌、渠道；手机外包制造，汽车自建工厂', '产品定义与系统、零售', '不适用', '中', '中性', '稳定', '生态经营利润率约 6%—8%，汽车（不含 AI）估计 7%—10%', '附加值主要在系统软件、互联网服务与品牌渠道；硬件制造本身利润薄。', '—'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'V2', '上游供给', '存储芯片：三星、SK 海力士、美光、长鑫、长江存储', 'DRAM 与 NAND', '供应商议价能力', '强', '不利', '增强', '低端机存储占物料 60% 以上（2025 年三季度约 30%）', 'AI 服务器挤占存储产能，2025 年下半年起合约价暴涨；手机厂商没有替代来源，只能提价或缩量。小米低端占比高，是前五大厂商中受影响最大的。', '新产能 2027—2028 年释放后价格会回落；长鑫、长江存储扩产增加国内供给。'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'V3', '上游供给', 'SoC：高通、联发科；自研玄戒', '手机处理器、基带', '供应商议价能力', '强', '不利', '稳定', '旗舰机 SoC 约占物料 15%—25%（行业估计）', '双寡头定价；玄戒 O1 已出货超百万台、第二代即将推出，长期可降低依赖，但研发投入大、良率与工艺受制于先进制程。', '自研芯片成功会把一部分供应商利润收回。'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'V4', '上游供给', '动力电池与汽车零部件：宁德时代、比亚迪弗迪等', '电池、电驱、智驾芯片', '供应商议价能力', '中', '不利', '稳定', '电池约占整车成本三成（行业估计）', 'SU7/YU7 电池宁德时代占比曾达八成左右，供应集中；正在引入第二供应商。', '电池价格过去两年下降，供应商议价力被行业价格战削弱。'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'V5', '渠道与流量', '自有新零售（小米之家、小米商城）、电商平台、境外运营商与分销', '把产品卖到消费者手里', '买方议价能力', '中', '中性', '稳定', '销售费用率约 7%', '自有渠道降低对平台的依赖，也承担了门店成本；境外仍依赖运营商与分销商。', '门店扩张过快会拖累费用率（2025 年四季度生态费用率 17.4%）。'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'V6', '下游客户', '大众与中高端消费者、家庭用户', '手机、IoT、汽车、互联网服务', '买方议价能力', '中', '不利', '稳定', '—', '手机换机周期长、转换成本低，价格敏感；家居设备接进米家后转换成本高；国补退坡后需求回落（IoT 二季度 −19%）。', '高端用户更看重体验，价格敏感度低。'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'V7', '互补方', '谷歌（境外安卓与谷歌服务）、应用开发者、广告主', '系统服务、内容与广告预算', '不适用', '中', '中性', '稳定', '境外互联网收入 126 亿元（2025 年）', '境外变现依赖谷歌框架下的预装与分成；国内依靠自有应用商店、浏览器与广告。', '谷歌政策或监管变化会影响境外收入。'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'V8', '同业竞争', '手机：华为、苹果、OPPO、vivo、荣耀、三星、传音', '同类手机', '行业内竞争', '强', '不利', '增强', '中国大陆 2026Q2：华为 23%、苹果 19%、小米 12%', '存储涨价下安卓厂商普遍提价、缩量，苹果价格稳定反而增长 23%；华为在高端持续回归。小米全球第三的位置靠新兴市场支撑。', '小米在东南亚、拉美、中东份额第二，境外韧性较强。'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'V9', '同业竞争', '汽车：比亚迪、特斯拉、理想、鸿蒙智行（问界）、零跑、小鹏、蔚来', '智能电动车', '行业内竞争', '强', '不利', '增强', '同行上半年毛利率 9.5%—23%', '国内乘用车需求疲软（二季度零售 −22%），价格战；新势力里只有零跑、小鹏规模接近或超过小米。', '小米品牌与保值率领先（YU7 一年保值率 82.8%）。'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'V10', '替代品', 'AI 原生入口：字节、阿里、苹果与华为的 AI 助手', '以对话与智能体替代应用分发', '替代品威胁', '中', '不利', '增强', '—', '若用户通过 AI 助手完成任务，应用商店、浏览器、预装等互联网变现入口会被绕开；小米的应对是自研 MiMo 与系统级 Agent。', '系统级权限是手机厂商的优势，第三方 AI 难以完全绕开。'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'V11', '监管', '国补与以旧换新、购置税、印度税务外汇、数据与智驾法规', '需求刺激与经营约束', '不适用', '中', '不利', '稳定', '—', '国补 2025 年上半年拉动 IoT 与手机，退坡后回落；购置税减免减半压低汽车 ASP；印度约 35 亿元资金被冻结。', '政策也可能再次刺激消费。');

INSERT INTO vi_lnk_value_chain_facts (value_chain_id, fact_id, "createdAt", "updatedAt")
SELECT x.id, y.id, now(), now() FROM (VALUES ('V1', '生态（手机×AIoT）经营利润率：2024 年 8.6%、2025 年 7.9%、2026 年上半年 6.7%'), ('V2', '存储成本：4 百美元以下机型存储占物料成本 60% 以上（2025 年三季度约 30%）'), ('V2', '2026 年二季度全球：三星 6,050 万、苹果 5,510 万、小米 3,120 万部（−26%）'), ('V3', '管理层：未来三年 AI 投入超 600 亿元，2026 年 160 亿元'), ('V4', '专家预计 2026 年交付 46—48.5 万辆，55 万目标难以完成'), ('V5', '小米之家：中国大陆约 1.6—1.8 万家，境外新零售门店超 640 家'), ('V5', '“手机×AIoT”分部营业费用率：2025 年四季度 17.4%、2026 年一季度 14.9%、二季度 14.2%'), ('V6', '2026 年二季度 IoT 与生活消费产品收入 312.8 亿元（−19.2%），国补退坡'), ('V7', '2025 年广告收入 285 亿元（+15.2%），境外互联网收入 126 亿元（占 33.8%）'), ('V8', '2026 年二季度中国大陆：华为 23%、苹果 19%、小米 12%（820 万台，−21%）'), ('V8', '2026 年二季度全球：三星 6,050 万、苹果 5,510 万、小米 3,120 万部（−26%）'), ('V9', '2026 年上半年毛利率：比亚迪 18.8%、特斯拉 18.7%、小鹏 20.6%、零跑 11.7%、理想 9.5%'), ('V9', '零跑：上半年交付 35.65 万辆，二季度毛利率 12.6%、净利 6 亿元，全年净利指引降到约 30 亿元'), ('V9', '理想：2026 年二季度车辆毛利率 9.4%、经营亏损 23 亿元'), ('V10', '管理层：未来三年 AI 投入超 600 亿元，2026 年 160 亿元'), ('V10', '互联网服务：2025 年 374.4 亿元（+9.7%）、毛利率 76.5%；2026 年二季度 90.4 亿元（−0.6%）'), ('V11', '2026 年二季度 IoT 与生活消费产品收入 312.8 亿元（−19.2%），国补退坡'), ('V11', '印度：491.7 亿卢比（约 35.4 亿元）资金被冻结，案件在听证阶段')) v(k1, k2)
JOIN vi_value_chain_base x ON x.company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND x.code = v.k1 JOIN vi_fact_base y ON y.company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND y.title = v.k2;

INSERT INTO vi_competitor_base (company_id, name, ticker, relation, segment, scale_label, scale_value, scale_unit, paying_rate, price_point, gross_margin, growth, as_of, strategy, vs_us, threat, trend, source_id) VALUES
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '华为', NULL, '直接竞争', '中国高端手机、鸿蒙生态、鸿蒙智行（汽车）', '中国大陆手机出货（2026Q2）', 15.2, '百万台', 0.23, NULL, NULL, 0.25, '2026-06-30', '芯片与系统自主，品牌回归高端；汽车以“智选车”与车企合作（问界、享界等）。', '强项：高端品牌、鸿蒙生态、智驾；弱项：境外受限。对小米：在 3,000 元以上价位与汽车上正面竞争。', '高', '上升', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '行业数据：Omdia 与 Counterpoint 手机出货、乘联会与车企月度交付、车企 2026 年中报毛利率汇总' LIMIT 1)),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '苹果', 'AAPL', '海外对标', '全球高端手机与服务', '全球手机出货（2026Q2）', 55.1, '百万台', 0.2, NULL, NULL, 0.23, '2026-06-30', '定价稳定、生态封闭、服务收入高毛利；存储涨价期间份额逆势上升。', '强项：品牌与生态锁定、毛利率远高于安卓；对小米：吸走中国高端用户，汽车客户里约六成用苹果手机。', '高', '上升', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '行业数据：Omdia 与 Counterpoint 手机出货、乘联会与车企月度交付、车企 2026 年中报毛利率汇总' LIMIT 1)),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'OPPO / vivo', NULL, '直接竞争', '中国与新兴市场手机', '全球手机出货（2026Q2）', 49.9, '百万台', NULL, NULL, NULL, -0.17, '2026-06-30', '线下渠道深、影像与续航卖点；同样削减低端机型保利润。', '与小米处境相近；国内份额各 16%，高于小米。', '中', '稳定', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '行业数据：Omdia 与 Counterpoint 手机出货、乘联会与车企月度交付、车企 2026 年中报毛利率汇总' LIMIT 1)),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '传音控股', '688036.SH', '直接竞争', '非洲、南亚等新兴市场手机', '全球份额（2026Q2）', 7.2, '%', NULL, NULL, NULL, 0.2, '2026-06-30', '低价机为主，产品结构升级；存储涨价下靠提价维持收入增长。', '在非洲领先，与小米在新兴市场争夺入门用户。', '中', '稳定', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '行业数据：Omdia 与 Counterpoint 手机出货、乘联会与车企月度交付、车企 2026 年中报毛利率汇总' LIMIT 1)),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '三星电子', '005930.KS', '海外对标', '全球手机（第一）', '全球手机出货（2026Q2）', 60.5, '百万台', 0.22, NULL, NULL, 0.05, '2026-06-30', '自有存储与屏幕，垂直一体化，存储涨价反而受益。', '对比：垂直整合缓冲了成本冲击，小米没有这层保护。', '中', '稳定', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '行业数据：Omdia 与 Counterpoint 手机出货、乘联会与车企月度交付、车企 2026 年中报毛利率汇总' LIMIT 1)),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '比亚迪', '002594.SZ', '直接竞争', '新能源汽车（全价位）', '二季度营收', 1946, '亿元', NULL, NULL, 0.188, -0.03, '2026-06-30', '电池到整车垂直一体化、全价位覆盖、出海。', '规模与成本领先；小米在 20 万元以上智能化与品牌上有差异化。', '中', '稳定', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '行业数据：Omdia 与 Counterpoint 手机出货、乘联会与车企月度交付、车企 2026 年中报毛利率汇总' LIMIT 1)),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '理想汽车', '02015.HK', '直接竞争', '增程家庭 SUV（对标澎程）', '二季度交付', 9.833, '万辆', NULL, NULL, 0.094, -0.151, '2026-06-30', '增程家庭 SUV 开创者；正在换代，二季度车辆毛利率 9.4%、经营亏损 23 亿元。', '澎程直接切入理想的核心市场；理想换代期正是小米的窗口。', '中', '下降', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '行业数据：Omdia 与 Counterpoint 手机出货、乘联会与车企月度交付、车企 2026 年中报毛利率汇总' LIMIT 1)),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '零跑汽车', '09863.HK', '直接竞争', '大众价位智能电动车', '上半年交付', 35.65, '万辆', NULL, NULL, 0.126, 0.608, '2026-06-30', '极致成本、全系列覆盖、月销 10 万辆，目标全年 100 万辆。', '规模远超小米但利润率低（全年净利指引约 30 亿元）；说明“卖得多不等于赚得多”。', '中', '上升', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '行业数据：Omdia 与 Counterpoint 手机出货、乘联会与车企月度交付、车企 2026 年中报毛利率汇总' LIMIT 1)),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '鸿蒙智行（赛力斯等）', '601127.SH', '直接竞争', '中高端智能电动车', '8 月交付', 4.2, '万辆', NULL, NULL, 0.233, NULL, '2026-08-31', '华为智驾与鸿蒙座舱＋车企制造，问界 M8/M9 主打家庭大 SUV。', '与小米 YU7、澎程正面竞争；赛力斯上半年毛利率 23.3%，高于小米汽车。', '高', '稳定', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '行业数据：Omdia 与 Counterpoint 手机出货、乘联会与车企月度交付、车企 2026 年中报毛利率汇总' LIMIT 1)),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智谱', '02513.HK', '直接竞争', '大模型（GLM）：模型即服务平台与企业智能体', '市值（2026-10-22）', 1912, '亿元', NULL, NULL, NULL, NULL, '2026-10-22', '国产算力适配，面向政企与开发者；1 月上市后两次大额配售。', '估值参照：小米 AI 主观估值 1,000 亿元约为其市值的一半；小米 AI 主要服务自家设备，不大规模对外收费。', '低', '下降', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '港股行情：智谱（02513.HK）、MiniMax（00100.HK）收盘价与总股本（2026-10-22）' LIMIT 1)),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'MiniMax', '00100.HK', '直接竞争', '大模型与 AI 应用（海外 C 端、智能体）', '市值（2026-10-22）', 482, '亿元', NULL, NULL, NULL, NULL, '2026-10-22', '多模态模型＋海外 C 端应用；7 月配售并发行可转债。', '估值参照：小米 AI 主观估值约为其两倍；两者都在争夺开发者调用量（OpenRouter）。', '低', '下降', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '港股行情：智谱（02513.HK）、MiniMax（00100.HK）收盘价与总股本（2026-10-22）' LIMIT 1)),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '月之暗面（Kimi）', NULL, '直接竞争', '大模型（Kimi K 系列）与 C 端助手', '最近一轮投后估值', 350, '亿美元', NULL, NULL, NULL, NULL, '2026-07-31', '开源旗舰模型＋海外 API，ARR 约 3 亿美元；筹备港股上市。', '估值参照：一级市场估值约 2,300 亿元，约为小米 AI 主观估值的 2.3 倍。', '低', '上升', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '国内大模型公司融资与估值汇总（金圆统一证券 2026-09-30、大模型二季度复盘 2026-07-03 等，岗底斯知识库）' LIMIT 1)),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '阶跃星辰', NULL, '直接竞争', '多模态大模型与终端智能（与手机、汽车厂商合作）', '最近一轮投后估值', 120, '亿美元', NULL, NULL, NULL, NULL, '2026-05-31', '与终端厂商合作做系统级智能体；华勤、中兴等产业资本参投。', '估值参照：约 800 亿元，与小米 AI 主观估值接近；业务形态（服务终端）也最接近小米。', '低', '上升', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '国内大模型公司融资与估值汇总（金圆统一证券 2026-09-30、大模型二季度复盘 2026-07-03 等，岗底斯知识库）' LIMIT 1)),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'DeepSeek', NULL, '直接竞争', '开源大模型（V 系列）', '第二轮投前估值', 5000, '亿元', NULL, NULL, NULL, NULL, '2026-08-31', '开源、低成本训练；2026 年才首次外部融资。', '估值参照：国内估值最高的模型公司，约为小米 AI 主观估值的五倍；它的开源模型也是小米可以直接使用的替代方案。', '中', '上升', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '国内大模型公司融资与估值汇总（金圆统一证券 2026-09-30、大模型二季度复盘 2026-07-03 等，岗底斯知识库）' LIMIT 1)),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '百川智能', NULL, '直接竞争', '大模型（转向医疗等行业应用）', '最近公开估值（2024-07）', 28, '亿美元', NULL, NULL, NULL, NULL, '2024-07-31', '转向医疗等垂直领域；小米是其 A 轮投资方之一。', '估值参照（较旧）：二线模型公司的估值远低于头部。', '低', '下降', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '国内大模型公司融资与估值汇总（金圆统一证券 2026-09-30、大模型二季度复盘 2026-07-03 等，岗底斯知识库）' LIMIT 1));

INSERT INTO vi_lnk_competitor_facts (competitor_id, fact_id, "createdAt", "updatedAt")
SELECT x.id, y.id, now(), now() FROM (VALUES ('华为', '2026 年二季度中国大陆：华为 23%、苹果 19%、小米 12%（820 万台，−21%）'), ('苹果', '2026 年二季度全球：三星 6,050 万、苹果 5,510 万、小米 3,120 万部（−26%）'), ('苹果', '新一代 SU7 锁单用户中苹果手机用户近 60%（初代约 50%）'), ('OPPO / vivo', '2026 年二季度全球：三星 6,050 万、苹果 5,510 万、小米 3,120 万部（−26%）'), ('OPPO / vivo', '2026 年二季度中国大陆：华为 23%、苹果 19%、小米 12%（820 万台，−21%）'), ('传音控股', '存储成本：4 百美元以下机型存储占物料成本 60% 以上（2025 年三季度约 30%）'), ('三星电子', '2026 年二季度全球：三星 6,050 万、苹果 5,510 万、小米 3,120 万部（−26%）'), ('比亚迪', '2026 年上半年毛利率：比亚迪 18.8%、特斯拉 18.7%、小鹏 20.6%、零跑 11.7%、理想 9.5%'), ('理想汽车', '理想：2026 年二季度车辆毛利率 9.4%、经营亏损 23 亿元'), ('零跑汽车', '零跑：上半年交付 35.65 万辆，二季度毛利率 12.6%、净利 6 亿元，全年净利指引降到约 30 亿元'), ('鸿蒙智行（赛力斯等）', '2026 年上半年毛利率：比亚迪 18.8%、特斯拉 18.7%、小鹏 20.6%、零跑 11.7%、理想 9.5%'), ('智谱', '智谱（02513.HK）2026-10-22 市值约 2,247 亿港元（约 1,912 亿元），较 6 月高点回落约八成'), ('智谱', '大模型公司按收入的几十到上百倍估值，市值里有大量刚融到的现金'), ('MiniMax', 'MiniMax（00100.HK）2026-10-22 市值约 566 亿港元（约 482 亿元）'), ('MiniMax', '大模型公司按收入的几十到上百倍估值，市值里有大量刚融到的现金'), ('月之暗面（Kimi）', '月之暗面（Kimi）2026 年 7 月 F 轮投后估值 350 亿美元'), ('月之暗面（Kimi）', '大模型公司按收入的几十到上百倍估值，市值里有大量刚融到的现金'), ('阶跃星辰', '阶跃星辰 2026 年 5 月 Pre-IPO 轮后估值约 120 亿美元'), ('阶跃星辰', '大模型公司按收入的几十到上百倍估值，市值里有大量刚融到的现金'), ('DeepSeek', 'DeepSeek 2026 年 8 月第二轮融资投前估值约 5,000 亿元'), ('百川智能', '大模型公司按收入的几十到上百倍估值，市值里有大量刚融到的现金')) v(k1, k2)
JOIN vi_competitor_base x ON x.company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND x.name = v.k1 JOIN vi_fact_base y ON y.company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND y.title = v.k2;

INSERT INTO vi_lnk_value_chain_competitors (value_chain_id, competitor_id, "createdAt", "updatedAt")
SELECT x.id, y.id, now(), now() FROM (VALUES ('V2', '三星电子'), ('V8', '华为'), ('V8', '苹果'), ('V8', 'OPPO / vivo'), ('V8', '传音控股'), ('V8', '三星电子'), ('V9', '比亚迪'), ('V9', '理想汽车'), ('V9', '零跑汽车'), ('V9', '鸿蒙智行（赛力斯等）'), ('V10', '苹果'), ('V10', '华为')) v(k1, k2)
JOIN vi_value_chain_base x ON x.company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND x.code = v.k1 JOIN vi_competitor_base y ON y.company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND y.name = v.k2;

INSERT INTO vi_moat_base (company_id, code, title, moat_type, verdict, strength, trend, mechanism, financial_link, evidence, counter, replication, threats, check_metric, check_op, check_threshold, check_years) VALUES
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'M1', '生态用户与互联网变现', '生态与渠道', '真实壁垒', '中', '稳定', '小米掌握自有设备的系统层（澎湃 OS），7.67 亿月活带来应用分发、广告、游戏、金融科技收入；硬件按成本卖出后，每个用户每年约 50 元的互联网收入几乎是纯利润。用户为什么离不开，见 M6（米家家庭设备网络）。', '互联网毛利率 2023—2025 年 74.2%、76.6%、76.5%，2026 年二季度 76.8%；2025 年互联网毛利 286.4 亿元≈生态经营利润 278.4 亿元；月活连续多年增长。', '月活从 2018 年 2.42 亿增到 2025 年 7.54 亿；广告 2025 年 +15%；境外互联网占三成以上。', '互联网收入要靠持续卖出新设备补充用户，境外依赖谷歌框架（论证见 T1 反方）。', '其他安卓厂商也有系统层变现，但小米的用户规模与 IoT 设备数难以短期复制；华为、苹果的封闭生态更强。', 'AI 助手绕过应用入口；出货下滑传导到月活；监管限制预装与广告。', '业务量同比', '<', 0.02, 2),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'M2', '成本效率与“性价比”定价', '成本优势', '局部优势', '中', '削弱', '规模采购、外包制造、低费用率，让同配置产品更便宜；用低价换份额和用户。', '生态营业费用率约 14%—15%（2026 年）；但硬件毛利率低（手机 8.5%—12%），存储涨价时利润率跌得最快。', '全球出货第三、东南亚拉美中东第二；IoT 品类多个全球前二。', '成本优势没有转化为定价权：存储涨价期间小米是前五大厂商中受影响最大的（V2、T2）；三星有自产存储，苹果有品牌溢价。', 'OPPO、vivo、传音、荣耀同样能做到相近的成本；没有专利或资源壁垒。', '存储超级周期；低端市场萎缩。', '毛利率', '<', 0.19, 2),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'M3', '自有新零售渠道', '生态与渠道', '局部优势', '中', '稳定', '1.6—1.8 万家小米之家覆盖到县城，同时卖手机、家电、汽车（477 家汽车门店），降低获客成本并把手机用户导向高客单价品类。', '汽车上市即形成大额订单（初代 SU7 首月锁单 8.8 万台）；大家电收入 2025 年 +23%。', '境外新零售门店 640 多家、年底计划超 1,000 家；500 平米以上大店 270 多家。', '门店是成本：2025 年四季度生态费用率 17.4%；国补退坡后单店产出下降。华为也有类似的门店网络。', '需要 5—10 年和大量资本，但华为、OPPO/vivo 已有同等规模渠道。', '消费疲软、门店盈利下降导致收缩。', NULL, NULL, NULL, NULL),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'M4', '品牌与创始人号召力', '品牌与定价权', '局部优势', '中', '稳定', '雷军个人品牌与“米粉”社区带来极低的获客成本，新品首发即有大额订单；高端化（徕卡、Ultra、YU7）提升品牌溢价。', '手机 ASP 从 2025 年约 1,100 元升到 2026 年二季度 1,351 元；YU7 一年保值率 82.8%（行业第一）。', 'YU7 上市 3 分钟大定 20 万台（第三方报道）；澎程 30 天锁单超 7 万台；新一代 SU7 开售 3 天锁单 3 万台。', '品牌溢价在手机上仍低于华为、苹果；汽车订单热度逐代下降（澎程订单低于公司预期）；关键人风险。', '创始人品牌不可复制，但会随争议或产品失误受损。', '安全事故与舆情；高端化失败。', NULL, NULL, NULL, NULL),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'M5', '汽车量产与供应链组织能力', '工艺与组织', '待验证', '中', '稳定', '三年做到 80 万辆累计交付、第二年分部盈利，说明产品定义、供应链和工厂管理能力强。', '2025 年汽车及 AI 分部毛利率 24.3%、经营收益 9 亿元；2026 年二季度毛利率 19.2%、经营亏损 26 亿元（含 AI）。', '2025 年交付 41.1 万辆、ASP 25.1 万元；SU7 系列累计交付突破 50 万台。', '2026 年交付低于目标、ASP −10%；行业利润率普遍低（零跑净利率约 2%、理想亏损，见 T3 反方）；规模优势要到 100 万辆以上才稳。', '比亚迪、吉利、零跑都有更大规模；新势力的组织能力差异会在价格战中显现。对照对手：鸿蒙智行（赛力斯等）。', '价格战、智驾法规与安全事故、海外关税。', NULL, NULL, NULL, NULL),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'M6', '米家家庭设备网络', '转换成本', '真实壁垒', '中', '增强', '一个家庭只适合一套管理系统：设备都接进米家后，再买新设备会优先选小米，越买越多；想换品牌就得整屋一起换。', '深度家庭在增加：五件以上设备用户 2,460 万（+20%），IoT 连接设备 11.6 亿台（+17%）；IoT 毛利率从 2019 年 11.2% 升到 2025 年 23.1%。', '米家 APP 月活 1.24 亿；五件以上设备用户 2,460 万（+20%）；IoT 连接设备 11.6 亿台（+17%）。', '五件以上设备的深度用户只占月活约 3%，多数用户只有一两件设备，锁不住；Matter 等跨品牌标准与第三方平台（如 HomeKit）会降低切换成本；锁定只在家庭内部，不延伸到汽车——新一代 SU7 锁单用户近六成用苹果手机，“人车家”整体协同不成立。', '华为鸿蒙智家、苹果 HomeKit 有同类锁定，但小米的品类数量与价格覆盖面最广，难以短期复制。', '跨品牌互联标准普及；IoT 品类同质化与价格战。', NULL, NULL, NULL, NULL),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'M7', '全球第三的手机出货规模', '规模经济', '伪壁垒', '弱', '削弱', '看起来规模越大采购越便宜。', '规模没有带来定价权：手机毛利率 2024 年 12.6% → 2026 年二季度 8.5%；出货 −26%。', '全球第三、连续 24 个季度前三。', '手机是规模化但同质化的生意，前五大厂商都有规模；存储周期里规模小的低端品牌反而先退出，规模大的承受更大的绝对损失。', '对照对手：苹果、三星电子。', '—', NULL, NULL, NULL, NULL),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'M8', '自研芯片与 AI 大模型', '数据与算法', '待验证', '弱', '增强', '玄戒芯片与 MiMo 大模型若成功，可降低对高通、联发科与第三方模型的依赖，并让系统级 AI 成为差异化。', '目前只体现为成本：三年 AI 投入超 600 亿元；AI 收入每季度不到 10 亿元（含售后）。', 'MiMo-V2.5 开源模型综合排名靠前、OpenRouter 周调用量第一（10.5 万亿 token）；玄戒 O1 出货超百万。', '商业化“为时尚早”，投入规模并不占优（论证见 T4 反方）。', '大厂都在投入，领先难以持续。对照对手：华为、苹果、智谱、MiniMax、月之暗面（Kimi）、DeepSeek。', '技术路线变化、算力成本。', NULL, NULL, NULL, NULL),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'M9', '账上现金与投资组合', '牌照与资源', '伪壁垒', '无', '稳定', '2,193 亿元现金储备与 720 亿元投资让公司能长期投入汽车与 AI。', '这是资源，不是壁垒：现金不会让产品更好卖，反而可能被低回报项目消耗。', '—', '现金的价值已经在“非经营部分”单独计入，不能再给生态更高倍数。', '—', '—', NULL, NULL, NULL, NULL);

INSERT INTO vi_lnk_moat_facts (moat_id, fact_id, "createdAt", "updatedAt")
SELECT x.id, y.id, now(), now() FROM (VALUES ('M1', '互联网服务：2025 年 374.4 亿元（+9.7%）、毛利率 76.5%；2026 年二季度 90.4 亿元（−0.6%）'), ('M1', '2025 年广告收入 285 亿元（+15.2%），境外互联网收入 126 亿元（占 33.8%）'), ('M1', '全球月活 2026 年 6 月 7.665 亿（+4.8%），中国大陆 1.977 亿（+7.0%）'), ('M1', '全球月活（12 月）2018—2025 年：2.42 亿 → 7.54 亿'), ('M2', '存储成本：4 百美元以下机型存储占物料成本 60% 以上（2025 年三季度约 30%）'), ('M2', '2026 年二季度全球：三星 6,050 万、苹果 5,510 万、小米 3,120 万部（−26%）'), ('M2', '2026 年二季度手机出货 3,120 万台（−26.5%）、ASP 1,351 元（+25.9%）、毛利率 8.5%'), ('M2', '“手机×AIoT”分部营业费用率：2025 年四季度 17.4%、2026 年一季度 14.9%、二季度 14.2%'), ('M3', '小米之家：中国大陆约 1.6—1.8 万家，境外新零售门店超 640 家'), ('M3', '2025 年交付 411,082 辆、汽车收入 1,033 亿元、ASP 25.12 万元；2026 年目标 55 万辆'), ('M3', '2025 年 IoT 收入 1,232.0 亿元（+18.3%）、毛利率 23.1%；大家电 +23.1%'), ('M4', '2026 年二季度手机出货 3,120 万台（−26.5%）、ASP 1,351 元（+25.9%）、毛利率 8.5%'), ('M4', '9 月小米汽车交付超 4 万台，澎程 30 天锁单超 7 万台；前三季度约 28.7 万台'), ('M4', '专家预计 2026 年交付 46—48.5 万辆，55 万目标难以完成'), ('M5', '2025 年交付 411,082 辆、汽车收入 1,033 亿元、ASP 25.12 万元；2026 年目标 55 万辆'), ('M5', '2026 年二季度汽车及 AI 分部：收入 249.0 亿元、交付 104,199 辆、ASP 22.93 万元、毛利率 19.2%、经营亏损 26 亿元'), ('M5', '2026 年上半年毛利率：比亚迪 18.8%、特斯拉 18.7%、小鹏 20.6%、零跑 11.7%、理想 9.5%'), ('M5', '零跑：上半年交付 35.65 万辆，二季度毛利率 12.6%、净利 6 亿元，全年净利指引降到约 30 亿元'), ('M6', 'AIoT 连接设备 11.608 亿台（+17.4%），五件以上设备用户 2,460 万（+20.2%）'), ('M6', '全球月活 2026 年 6 月 7.665 亿（+4.8%），中国大陆 1.977 亿（+7.0%）'), ('M6', '分业务毛利率 2019—2025 年：手机 7.2%→10.9%（2023 年 14.6%），IoT 11.2%→23.1%，互联网 64.7%→76.5%'), ('M6', '新一代 SU7 锁单用户中苹果手机用户近 60%（初代约 50%）'), ('M7', '2026 年二季度全球：三星 6,050 万、苹果 5,510 万、小米 3,120 万部（−26%）'), ('M7', '2026 年二季度手机出货 3,120 万台（−26.5%）、ASP 1,351 元（+25.9%）、毛利率 8.5%'), ('M7', '2025 年手机收入 1,864.4 亿元、毛利率 10.9%、出货 1.652 亿台；四季度毛利率 8.3%'), ('M8', '管理层：未来三年 AI 投入超 600 亿元，2026 年 160 亿元'), ('M8', '2025 年研发 331.3 亿元（+37.8%）；2026—2030 年累计研发预计超 2,000 亿元'), ('M8', 'MiMo-V2.5 在 OpenRouter 周调用量第一（10.5 万亿 token），AI 收入仍很小'), ('M9', '2026-06-30 现金储备 2,193 亿元，借款 393 亿元（含可换股债券 50.8 亿元）'), ('M9', '2026-06-30 对外投资 720.7 亿元：权益法 66.1、普通股 185.8、优先股 382.4、其他 86.3')) v(k1, k2)
JOIN vi_moat_base x ON x.company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND x.code = v.k1 JOIN vi_fact_base y ON y.company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND y.title = v.k2;

INSERT INTO vi_lnk_moat_theses (moat_id, thesis_id, "createdAt", "updatedAt")
SELECT x.id, y.id, now(), now() FROM (VALUES ('M1', 'T1'), ('M2', 'T2'), ('M3', 'T1'), ('M3', 'T3'), ('M4', 'T3'), ('M4', 'T8'), ('M5', 'T3'), ('M6', 'T1'), ('M7', 'T2'), ('M8', 'T4'), ('M9', 'T5'), ('M9', 'T9')) v(k1, k2)
JOIN vi_moat_base x ON x.company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND x.code = v.k1 JOIN vi_thesis_base y ON y.company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND y.code = v.k2;

INSERT INTO vi_fit_score_base (company_id, dimension, score, rationale, counter, sort) VALUES
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '长坡', 3, '全球手机市场停滞，但小米在高端、IoT 出海（境外市场约为国内三倍）与汽车上有增长空间；汽车、AI 是新坡道。', '手机出货下滑、国补退坡后国内 IoT 回落；汽车坡道长但拥挤。', 1),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '厚雪', 2, '生态经营利润率只有 6%—8%，硬件利润薄（手机按收入分摊费用后微亏）；互联网高毛利但体量只占收入 8%。', '轻资产、负营运资本让资本回报高于利润率所显示的水平。', 2),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '慢变', 1, '消费电子一年一代，汽车与 AI 技术路线快速变化，存储等上游周期剧烈。', '品牌与渠道的变化相对慢。', 3),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '护城河', 2, '真实壁垒有两条：生态用户与互联网变现、米家家庭设备网络（强度均为中）；成本、渠道、品牌是局部优势；出货规模、现金是伪壁垒。', '品牌与创始人号召力在新品类上反复验证。', 4),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '再投资', 2, '汽车第二年盈利、第三年因 AI 与降价转亏；AI 三年 600 亿元回报未知；新零售出海回报尚可。', '若汽车做到 100 万辆以上并保持 8% 利润率，再投资回报会很好。', 5),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '财务质量', 4, '净现金约 1,800 亿元，经营现金流长期高于利润；审计与分部披露完整。', '利润含大额投资公允价值收益，股权激励每年约 45—50 亿元；2026 年上半年经营现金流只有 20 亿元。', 6),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '治理配置', 3, '创始人长期主义、持续回购、按季度详细披露；回购时同比例转换 A 类股。', '同股不同权，资本配置高度依赖雷军个人判断（汽车、AI、机器人同时投入）。', 7),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '可估值性', 2, '五块业务处在四个阶段，利润受存储周期、汽车价格战、AI 投入三重影响；AI 只能按主观判断估值（每股约 3.9 元）；情景区间 15.1—48.5 元，跨度三倍多。', '分部估值把不确定性拆开了，主要变量都可跟踪。', 8);

INSERT INTO vi_lnk_fit_score_theses (fit_score_id, thesis_id, "createdAt", "updatedAt")
SELECT x.id, y.id, now(), now() FROM (VALUES ('长坡', 'T3'), ('厚雪', 'T1'), ('厚雪', 'T2'), ('慢变', 'T2'), ('慢变', 'T4'), ('护城河', 'T1'), ('再投资', 'T3'), ('再投资', 'T4'), ('财务质量', 'T5'), ('财务质量', 'T6'), ('财务质量', 'T7'), ('治理配置', 'T8'), ('治理配置', 'T4'), ('可估值性', 'T2'), ('可估值性', 'T3'), ('可估值性', 'T4'), ('可估值性', 'T9')) v(k1, k2)
JOIN vi_fit_score_base x ON x.company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND x.dimension = v.k1 JOIN vi_thesis_base y ON y.company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND y.code = v.k2;

INSERT INTO vi_metric_base (code,name,unit,category,source_kind,basis,company_id,source_name,frequency,valid_min) VALUES ('01810.HK.OP.AIOT_DEVICES','AIoT平台连接设备数（不含手机和平板）','百万台','经营','公司披露','时点',(SELECT id FROM vi_company_base WHERE code = '01810.HK'),'2026 年第二季度及中期业绩公告（2026-08-18）','季',0) ON CONFLICT (code) DO UPDATE SET category='经营',source_kind='公司披露',basis='时点';

INSERT INTO vi_metric_base (code,name,unit,category,source_kind,basis,company_id,source_name,frequency,valid_min) VALUES ('01810.HK.OP.AIOT_MULTI_USERS','拥有五件及以上AIoT设备的用户数','百万人','经营','公司披露','时点',(SELECT id FROM vi_company_base WHERE code = '01810.HK'),'2026 年第二季度及中期业绩公告（2026-08-18）','季',0) ON CONFLICT (code) DO UPDATE SET category='经营',source_kind='公司披露',basis='时点';

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'AIoT平台连接设备数（不含手机和平板）', '时点', '百万台', '2026Q2', '2026-06-30', 1160.8, 0.174, '截至 2026 年 6 月底 AIoT 平台连接设备（不含手机、平板）1,160.8 百万台（+17.4%），拥有五件及以上设备的用户 24.6 百万（+20.2%）。', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第二季度及中期业绩公告（2026-08-18）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '拥有五件及以上AIoT设备的用户数', '时点', '百万人', '2026Q2', '2026-06-30', 24.6, 0.202, '截至 2026 年 6 月底 AIoT 平台连接设备（不含手机、平板）1,160.8 百万台（+17.4%），拥有五件及以上设备的用户 24.6 百万（+20.2%）。', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第二季度及中期业绩公告（2026-08-18）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'AIoT平台连接设备数（不含手机和平板）', '时点', '百万台', '2025Q1', '2025-03-31', 943.7, 0.201, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'AIoT平台连接设备数（不含手机和平板）', '时点', '百万台', '2025Q2', '2025-06-30', 989.0, 0.203, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第二季度及中期业绩公告（2025-08-19）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '拥有五件及以上AIoT设备的用户数', '时点', '百万人', '2025Q2', '2025-06-30', 20.5, 0.268, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第二季度及中期业绩公告（2025-08-19）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'AIoT平台连接设备数（不含手机和平板）', '时点', '百万台', '2025Q3', '2025-09-30', 1035.5, 0.202, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第三季度业绩公告（2025-11-18）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '拥有五件及以上AIoT设备的用户数', '时点', '百万人', '2025Q3', '2025-09-30', 21.6, 0.261, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第三季度业绩公告（2025-11-18）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'AIoT平台连接设备数（不含手机和平板）', '时点', '百万台', '2025Q4', '2025-12-31', 1079.2, 0.193, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年全年业绩公告（2026-03-24）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '拥有五件及以上AIoT设备的用户数', '时点', '百万人', '2025Q4', '2025-12-31', 22.7, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年全年业绩公告（2026-03-24）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '营业收入', '单季', '亿元', '2024Q1', '2024-03-31', 755.07, NULL, 'SU7 3 月 28 日上市；当季汽车收入 1,840 万元。全年交付 136,854 辆减二至四季度 136,794 辆，差 60 辆应为一季度创始版交付（未单独披露）。', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '手机×AIoT 分部收入', '单季', '亿元', '2024Q1', '2024-03-31', 754.81, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智能电动汽车及AI分部收入', '单季', '亿元', '2024Q1', '2024-03-31', 0.26, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智能手机收入', '单季', '亿元', '2024Q1', '2024-03-31', 464.8, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'IoT与生活消费产品收入', '单季', '亿元', '2024Q1', '2024-03-31', 203.74, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '互联网服务收入', '单季', '亿元', '2024Q1', '2024-03-31', 80.48, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '毛利率', '单季', '%', '2024Q1', '2024-03-31', 22.29, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '手机×AIoT 分部毛利率', '单季', '%', '2024Q1', '2024-03-31', 22.29, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智能手机毛利率', '单季', '%', '2024Q1', '2024-03-31', 14.8, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'IoT毛利率', '单季', '%', '2024Q1', '2024-03-31', 19.86, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '互联网服务毛利率', '单季', '%', '2024Q1', '2024-03-31', 74.24, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智能手机出货量', '单季', '百万台', '2024Q1', '2024-03-31', 40.6, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '研发开支', '单季', '亿元', '2024Q1', '2024-03-31', 51.59, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '营业收入', '单季', '亿元', '2024Q2', '2024-06-30', 888.88, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '手机×AIoT 分部收入', '单季', '亿元', '2024Q2', '2024-06-30', 825.19, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智能电动汽车及AI分部收入', '单季', '亿元', '2024Q2', '2024-06-30', 63.69, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智能手机收入', '单季', '亿元', '2024Q2', '2024-06-30', 465.16, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'IoT与生活消费产品收入', '单季', '亿元', '2024Q2', '2024-06-30', 267.6, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '互联网服务收入', '单季', '亿元', '2024Q2', '2024-06-30', 82.66, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '毛利率', '单季', '%', '2024Q2', '2024-06-30', 20.69, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '手机×AIoT 分部毛利率', '单季', '%', '2024Q2', '2024-06-30', 21.1, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '汽车及AI分部毛利率', '单季', '%', '2024Q2', '2024-06-30', 15.39, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智能手机毛利率', '单季', '%', '2024Q2', '2024-06-30', 12.14, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'IoT毛利率', '单季', '%', '2024Q2', '2024-06-30', 19.75, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '互联网服务毛利率', '单季', '%', '2024Q2', '2024-06-30', 78.31, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智能手机出货量', '单季', '百万台', '2024Q2', '2024-06-30', 42.2, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智能手机ASP', '单季', '元', '2024Q2', '2024-06-30', 1103.5, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '汽车交付量', '单季', '辆', '2024Q2', '2024-06-30', 27307, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '汽车ASP', '单季', '元', '2024Q2', '2024-06-30', 228644, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '研发开支', '单季', '亿元', '2024Q2', '2024-06-30', 54.98, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '营业收入', '单季', '亿元', '2024Q3', '2024-09-30', 925.07, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '手机×AIoT 分部收入', '单季', '亿元', '2024Q3', '2024-09-30', 828.09, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智能电动汽车及AI分部收入', '单季', '亿元', '2024Q3', '2024-09-30', 96.97, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智能手机收入', '单季', '亿元', '2024Q3', '2024-09-30', 474.52, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'IoT与生活消费产品收入', '单季', '亿元', '2024Q3', '2024-09-30', 261.02, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '互联网服务收入', '单季', '亿元', '2024Q3', '2024-09-30', 84.63, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '毛利率', '单季', '%', '2024Q3', '2024-09-30', 20.41, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '手机×AIoT 分部毛利率', '单季', '%', '2024Q3', '2024-09-30', 20.8, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '汽车及AI分部毛利率', '单季', '%', '2024Q3', '2024-09-30', 17.12, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智能手机毛利率', '单季', '%', '2024Q3', '2024-09-30', 11.69, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'IoT毛利率', '单季', '%', '2024Q3', '2024-09-30', 20.76, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '互联网服务毛利率', '单季', '%', '2024Q3', '2024-09-30', 77.45, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智能手机出货量', '单季', '百万台', '2024Q3', '2024-09-30', 43.1, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智能手机ASP', '单季', '元', '2024Q3', '2024-09-30', 1102.2, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '汽车交付量', '单季', '辆', '2024Q3', '2024-09-30', 39790, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '汽车ASP', '单季', '元', '2024Q3', '2024-09-30', 238650, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '研发开支', '单季', '亿元', '2024Q3', '2024-09-30', 59.57, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '营业收入', '单季', '亿元', '2024Q4', '2024-12-31', 1090.05, NULL, '手机 ASP 与汽车之外的分项由全年减前三季度得出。', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '手机×AIoT 分部收入', '单季', '亿元', '2024Q4', '2024-12-31', 923.44, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智能电动汽车及AI分部收入', '单季', '亿元', '2024Q4', '2024-12-31', 166.62, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智能手机收入', '单季', '亿元', '2024Q4', '2024-12-31', 513.11, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'IoT与生活消费产品收入', '单季', '亿元', '2024Q4', '2024-12-31', 308.68, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '互联网服务收入', '单季', '亿元', '2024Q4', '2024-12-31', 93.38, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '毛利率', '单季', '%', '2024Q4', '2024-12-31', 20.6, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '手机×AIoT 分部毛利率', '单季', '%', '2024Q4', '2024-12-31', 20.63, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '汽车及AI分部毛利率', '单季', '%', '2024Q4', '2024-12-31', 20.45, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智能手机毛利率', '单季', '%', '2024Q4', '2024-12-31', 12.04, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'IoT毛利率', '单季', '%', '2024Q4', '2024-12-31', 20.55, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '互联网服务毛利率', '单季', '%', '2024Q4', '2024-12-31', 76.5, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智能手机出货量', '单季', '百万台', '2024Q4', '2024-12-31', 42.6, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '汽车交付量', '单季', '辆', '2024Q4', '2024-12-31', 69697, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '汽车ASP', '单季', '元', '2024Q4', '2024-12-31', 234322, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '研发开支', '单季', '亿元', '2024Q4', '2024-12-31', 74.36, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '营业收入', '单季', '亿元', '2025Q1', '2025-03-31', 1112.93, 0.473943, '国补带动 IoT 收入 +58.7%；SU7 Ultra 2 月上市。', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '手机×AIoT 分部收入', '单季', '亿元', '2025Q1', '2025-03-31', 927.13, 0.228296, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智能电动汽车及AI分部收入', '单季', '亿元', '2025Q1', '2025-03-31', 185.8, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智能手机收入', '单季', '亿元', '2025Q1', '2025-03-31', 506.12, 0.088898, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'IoT与生活消费产品收入', '单季', '亿元', '2025Q1', '2025-03-31', 323.39, 0.587268, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '互联网服务收入', '单季', '亿元', '2025Q1', '2025-03-31', 90.76, 0.127734, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '毛利率', '单季', '%', '2025Q1', '2025-03-31', 22.83, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '手机×AIoT 分部毛利率', '单季', '%', '2025Q1', '2025-03-31', 22.76, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '汽车及AI分部毛利率', '单季', '%', '2025Q1', '2025-03-31', 23.17, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智能手机毛利率', '单季', '%', '2025Q1', '2025-03-31', 12.41, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'IoT毛利率', '单季', '%', '2025Q1', '2025-03-31', 25.22, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '互联网服务毛利率', '单季', '%', '2025Q1', '2025-03-31', 76.93, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智能手机出货量', '单季', '百万台', '2025Q1', '2025-03-31', 41.8, 0.029557, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智能手机ASP', '单季', '元', '2025Q1', '2025-03-31', 1210.6, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '汽车交付量', '单季', '辆', '2025Q1', '2025-03-31', 75869, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '汽车ASP', '单季', '元', '2025Q1', '2025-03-31', 238301, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '汽车及AI分部经营损益', '单季', '亿元', '2025Q1', '2025-03-31', -4.95, NULL, '毛利 43.05−经营开支 48（公告取整）', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '生态经营利润（推算）', '单季', '亿元', '2025Q1', '2025-03-31', 104.59, NULL, '分部毛利 211.01−(集团研发、销售、行政 154.42−汽车及 AI 分部经营开支 48)', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '生态经营利润率（推算）', '单季', '%', '2025Q1', '2025-03-31', 11.28, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '经调整净利润', '单季', '亿元', '2025Q1', '2025-03-31', 106.76, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '期间利润（国际财务报告准则）', '单季', '亿元', '2025Q1', '2025-03-31', 108.93, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '全球月活跃用户', '单季', '百万人', '2025Q1', '2025-03-31', 718.8, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '研发开支', '单季', '亿元', '2025Q1', '2025-03-31', 67.12, 0.301027, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '现金储备', '单季', '亿元', '2025Q1', '2025-03-31', 2168, NULL, '公司口径（含现金、定期存款、短期投资、长期摊余成本投资与理财）', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '借款', '单季', '亿元', '2025Q1', '2025-03-31', 309, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '营业收入', '单季', '亿元', '2025Q2', '2025-06-30', 1159.56, 0.304518, 'YU7 6 月发布；汽车分部经营亏损 3 亿元。', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第二季度及中期业绩公告（2025-08-19）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '手机×AIoT 分部收入', '单季', '亿元', '2025Q2', '2025-06-30', 946.93, 0.14753, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第二季度及中期业绩公告（2025-08-19）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智能电动汽车及AI分部收入', '单季', '亿元', '2025Q2', '2025-06-30', 212.63, 2.338515, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第二季度及中期业绩公告（2025-08-19）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智能手机收入', '单季', '亿元', '2025Q2', '2025-06-30', 455.2, -0.021412, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第二季度及中期业绩公告（2025-08-19）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'IoT与生活消费产品收入', '单季', '亿元', '2025Q2', '2025-06-30', 387.12, 0.446637, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第二季度及中期业绩公告（2025-08-19）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '互联网服务收入', '单季', '亿元', '2025Q2', '2025-06-30', 90.98, 0.100653, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第二季度及中期业绩公告（2025-08-19）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '毛利率', '单季', '%', '2025Q2', '2025-06-30', 22.51, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第二季度及中期业绩公告（2025-08-19）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '手机×AIoT 分部毛利率', '单季', '%', '2025Q2', '2025-06-30', 21.63, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第二季度及中期业绩公告（2025-08-19）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '汽车及AI分部毛利率', '单季', '%', '2025Q2', '2025-06-30', 26.44, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第二季度及中期业绩公告（2025-08-19）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智能手机毛利率', '单季', '%', '2025Q2', '2025-06-30', 11.47, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第二季度及中期业绩公告（2025-08-19）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'IoT毛利率', '单季', '%', '2025Q2', '2025-06-30', 22.53, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第二季度及中期业绩公告（2025-08-19）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '互联网服务毛利率', '单季', '%', '2025Q2', '2025-06-30', 75.36, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第二季度及中期业绩公告（2025-08-19）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智能手机出货量', '单季', '百万台', '2025Q2', '2025-06-30', 42.4, 0.004739, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第二季度及中期业绩公告（2025-08-19）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智能手机ASP', '单季', '元', '2025Q2', '2025-06-30', 1073.2, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第二季度及中期业绩公告（2025-08-19）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '汽车交付量', '单季', '辆', '2025Q2', '2025-06-30', 81302, 1.977332, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第二季度及中期业绩公告（2025-08-19）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '汽车ASP', '单季', '元', '2025Q2', '2025-06-30', 253662, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第二季度及中期业绩公告（2025-08-19）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '汽车及AI分部经营损益', '单季', '亿元', '2025Q2', '2025-06-30', -2.79, NULL, '毛利 56.21−经营开支 59（公告取整）', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第二季度及中期业绩公告（2025-08-19）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '生态经营利润（推算）', '单季', '亿元', '2025Q2', '2025-06-30', 92.12, NULL, '分部毛利 204.8−(集团研发、销售、行政 171.68−汽车及 AI 分部经营开支 59)', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第二季度及中期业绩公告（2025-08-19）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '生态经营利润率（推算）', '单季', '%', '2025Q2', '2025-06-30', 9.73, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第二季度及中期业绩公告（2025-08-19）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '经调整净利润', '单季', '亿元', '2025Q2', '2025-06-30', 108.31, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第二季度及中期业绩公告（2025-08-19）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '期间利润（国际财务报告准则）', '单季', '亿元', '2025Q2', '2025-06-30', 118.73, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第二季度及中期业绩公告（2025-08-19）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '全球月活跃用户', '单季', '百万人', '2025Q2', '2025-06-30', 731.2, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第二季度及中期业绩公告（2025-08-19）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '研发开支', '单季', '亿元', '2025Q2', '2025-06-30', 77.63, 0.411968, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第二季度及中期业绩公告（2025-08-19）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '现金储备', '单季', '亿元', '2025Q2', '2025-06-30', 2359, NULL, '公司口径（含现金、定期存款、短期投资、长期摊余成本投资与理财）', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第二季度及中期业绩公告（2025-08-19）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '借款', '单季', '亿元', '2025Q2', '2025-06-30', 289, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第二季度及中期业绩公告（2025-08-19）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '营业收入', '单季', '亿元', '2025Q3', '2025-09-30', 1131.21, 0.222837, '汽车分部首次单季经营盈利 7 亿元；存储开始涨价。', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第三季度业绩公告（2025-11-18）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '手机×AIoT 分部收入', '单季', '亿元', '2025Q3', '2025-09-30', 841.11, 0.015723, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第三季度业绩公告（2025-11-18）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智能电动汽车及AI分部收入', '单季', '亿元', '2025Q3', '2025-09-30', 290.1, 1.991647, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第三季度业绩公告（2025-11-18）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智能手机收入', '单季', '亿元', '2025Q3', '2025-09-30', 459.69, -0.031253, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第三季度业绩公告（2025-11-18）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'IoT与生活消费产品收入', '单季', '亿元', '2025Q3', '2025-09-30', 275.52, 0.055551, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第三季度业绩公告（2025-11-18）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '互联网服务收入', '单季', '亿元', '2025Q3', '2025-09-30', 93.81, 0.108472, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第三季度业绩公告（2025-11-18）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '毛利率', '单季', '%', '2025Q3', '2025-09-30', 22.93, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第三季度业绩公告（2025-11-18）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '手机×AIoT 分部毛利率', '单季', '%', '2025Q3', '2025-09-30', 22.06, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第三季度业绩公告（2025-11-18）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '汽车及AI分部毛利率', '单季', '%', '2025Q3', '2025-09-30', 25.45, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第三季度业绩公告（2025-11-18）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智能手机毛利率', '单季', '%', '2025Q3', '2025-09-30', 11.09, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第三季度业绩公告（2025-11-18）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'IoT毛利率', '单季', '%', '2025Q3', '2025-09-30', 23.94, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第三季度业绩公告（2025-11-18）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '互联网服务毛利率', '单季', '%', '2025Q3', '2025-09-30', 76.87, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第三季度业绩公告（2025-11-18）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智能手机出货量', '单季', '百万台', '2025Q3', '2025-09-30', 43.3, 0.00464, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第三季度业绩公告（2025-11-18）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智能手机ASP', '单季', '元', '2025Q3', '2025-09-30', 1062.8, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第三季度业绩公告（2025-11-18）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '汽车交付量', '单季', '辆', '2025Q3', '2025-09-30', 108796, 1.734255, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第三季度业绩公告（2025-11-18）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '汽车ASP', '单季', '元', '2025Q3', '2025-09-30', 260053, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第三季度业绩公告（2025-11-18）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '汽车及AI分部经营损益', '单季', '亿元', '2025Q3', '2025-09-30', 6.84, NULL, '毛利 73.84−经营开支 67（公告取整）', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第三季度业绩公告（2025-11-18）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '生态经营利润（推算）', '单季', '亿元', '2025Q3', '2025-09-30', 60.36, NULL, '分部毛利 185.52−(集团研发、销售、行政 192.16−汽车及 AI 分部经营开支 67)', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第三季度业绩公告（2025-11-18）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '生态经营利润率（推算）', '单季', '%', '2025Q3', '2025-09-30', 7.18, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第三季度业绩公告（2025-11-18）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '经调整净利润', '单季', '亿元', '2025Q3', '2025-09-30', 113.1, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第三季度业绩公告（2025-11-18）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '期间利润（国际财务报告准则）', '单季', '亿元', '2025Q3', '2025-09-30', 122.57, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第三季度业绩公告（2025-11-18）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '全球月活跃用户', '单季', '百万人', '2025Q3', '2025-09-30', 741.7, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第三季度业绩公告（2025-11-18）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '研发开支', '单季', '亿元', '2025Q3', '2025-09-30', 90.59, 0.520732, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第三季度业绩公告（2025-11-18）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '现金储备', '单季', '亿元', '2025Q3', '2025-09-30', 2367, NULL, '公司口径（含现金、定期存款、短期投资、长期摊余成本投资与理财）', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第三季度业绩公告（2025-11-18）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '借款', '单季', '亿元', '2025Q3', '2025-09-30', 276, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第三季度业绩公告（2025-11-18）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '营业收入', '单季', '亿元', '2025Q4', '2025-12-31', 1169.17, 0.072584, '手机毛利率 8.3%；手机 ASP 由收入÷出货计算；汽车分部经营收益 11 亿元；交付 145,115 辆（单季高点）。', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年全年业绩公告（2026-03-24）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '手机×AIoT 分部收入', '单季', '亿元', '2025Q4', '2025-12-31', 797.0, -0.136923, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年全年业绩公告（2026-03-24）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智能电动汽车及AI分部收入', '单季', '亿元', '2025Q4', '2025-12-31', 372.16, 1.233585, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年全年业绩公告（2026-03-24）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智能手机收入', '单季', '亿元', '2025Q4', '2025-12-31', 443.39, -0.135877, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年全年业绩公告（2026-03-24）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'IoT与生活消费产品收入', '单季', '亿元', '2025Q4', '2025-12-31', 245.97, -0.203155, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年全年业绩公告（2026-03-24）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '互联网服务收入', '单季', '亿元', '2025Q4', '2025-12-31', 98.86, 0.058685, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年全年业绩公告（2026-03-24）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '毛利率', '单季', '%', '2025Q4', '2025-12-31', 20.84, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年全年业绩公告（2026-03-24）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '手机×AIoT 分部毛利率', '单季', '%', '2025Q4', '2025-12-31', 19.96, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年全年业绩公告（2026-03-24）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '汽车及AI分部毛利率', '单季', '%', '2025Q4', '2025-12-31', 22.71, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年全年业绩公告（2026-03-24）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智能手机毛利率', '单季', '%', '2025Q4', '2025-12-31', 8.27, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年全年业绩公告（2026-03-24）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'IoT毛利率', '单季', '%', '2025Q4', '2025-12-31', 20.13, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年全年业绩公告（2026-03-24）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '互联网服务毛利率', '单季', '%', '2025Q4', '2025-12-31', 76.79, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年全年业绩公告（2026-03-24）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智能手机出货量', '单季', '百万台', '2025Q4', '2025-12-31', 37.7, -0.115023, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年全年业绩公告（2026-03-24）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智能手机ASP', '单季', '元', '2025Q4', '2025-12-31', 1176.1, NULL, '由收入÷出货计算', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年全年业绩公告（2026-03-24）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '汽车交付量', '单季', '辆', '2025Q4', '2025-12-31', 145115, 1.082084, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年全年业绩公告（2026-03-24）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '汽车ASP', '单季', '元', '2025Q4', '2025-12-31', 249846, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年全年业绩公告（2026-03-24）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '汽车及AI分部经营损益', '单季', '亿元', '2025Q4', '2025-12-31', 10.53, NULL, '毛利 84.53−经营开支 74（公告取整）', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年全年业绩公告（2026-03-24）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '生态经营利润（推算）', '单季', '亿元', '2025Q4', '2025-12-31', 21.36, NULL, '分部毛利 159.09−(集团研发、销售、行政 211.73−汽车及 AI 分部经营开支 74)', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年全年业绩公告（2026-03-24）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '生态经营利润率（推算）', '单季', '%', '2025Q4', '2025-12-31', 2.68, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年全年业绩公告（2026-03-24）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '经调整净利润', '单季', '亿元', '2025Q4', '2025-12-31', 63.49, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年全年业绩公告（2026-03-24）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '期间利润（国际财务报告准则）', '单季', '亿元', '2025Q4', '2025-12-31', 65.44, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年全年业绩公告（2026-03-24）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '全球月活跃用户', '单季', '百万人', '2025Q4', '2025-12-31', 754.1, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年全年业绩公告（2026-03-24）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '研发开支', '单季', '亿元', '2025Q4', '2025-12-31', 95.98, 0.290748, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年全年业绩公告（2026-03-24）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '现金储备', '单季', '亿元', '2025Q4', '2025-12-31', 2326, NULL, '公司口径（含现金、定期存款、短期投资、长期摊余成本投资与理财）', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年全年业绩公告（2026-03-24）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '借款', '单季', '亿元', '2025Q4', '2025-12-31', 361.24, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年全年业绩公告（2026-03-24）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '营业收入', '单季', '亿元', '2026Q1', '2026-03-31', 991.42, -0.10918, '停售初代 SU7，交付 80,856 辆；汽车及 AI 分部经营亏损 31 亿元（AI 投入）。', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第一季度业绩公告（2026-05-26）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '手机×AIoT 分部收入', '单季', '亿元', '2026Q1', '2026-03-31', 792.77, -0.14492, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第一季度业绩公告（2026-05-26）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智能电动汽车及AI分部收入', '单季', '亿元', '2026Q1', '2026-03-31', 198.64, 0.069107, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第一季度业绩公告（2026-05-26）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智能手机收入', '单季', '亿元', '2026Q1', '2026-03-31', 442.73, -0.125247, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第一季度业绩公告（2026-05-26）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'IoT与生活消费产品收入', '单季', '亿元', '2026Q1', '2026-03-31', 246.81, -0.236804, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第一季度业绩公告（2026-05-26）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '互联网服务收入', '单季', '亿元', '2026Q1', '2026-03-31', 94.68, 0.043191, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第一季度业绩公告（2026-05-26）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '毛利率', '单季', '%', '2026Q1', '2026-03-31', 22.0, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第一季度业绩公告（2026-05-26）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '手机×AIoT 分部毛利率', '单季', '%', '2026Q1', '2026-03-31', 22.47, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第一季度业绩公告（2026-05-26）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '汽车及AI分部毛利率', '单季', '%', '2026Q1', '2026-03-31', 20.11, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第一季度业绩公告（2026-05-26）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智能手机毛利率', '单季', '%', '2026Q1', '2026-03-31', 10.11, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第一季度业绩公告（2026-05-26）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'IoT毛利率', '单季', '%', '2026Q1', '2026-03-31', 25.19, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第一季度业绩公告（2026-05-26）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '互联网服务毛利率', '单季', '%', '2026Q1', '2026-03-31', 76.11, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第一季度业绩公告（2026-05-26）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智能手机出货量', '单季', '百万台', '2026Q1', '2026-03-31', 33.8, -0.191388, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第一季度业绩公告（2026-05-26）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智能手机ASP', '单季', '元', '2026Q1', '2026-03-31', 1310.1, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第一季度业绩公告（2026-05-26）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '汽车交付量', '单季', '辆', '2026Q1', '2026-03-31', 80856, 0.065732, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第一季度业绩公告（2026-05-26）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '汽车ASP', '单季', '元', '2026Q1', '2026-03-31', 235116, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第一季度业绩公告（2026-05-26）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '汽车及AI分部经营损益', '单季', '亿元', '2026Q1', '2026-03-31', -31.06, NULL, '毛利 39.94−经营开支 71（公告取整）', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第一季度业绩公告（2026-05-26）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '生态经营利润（推算）', '单季', '亿元', '2026Q1', '2026-03-31', 60.55, NULL, '分部毛利 178.16−(集团研发、销售、行政 188.61−汽车及 AI 分部经营开支 71)', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第一季度业绩公告（2026-05-26）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '生态经营利润率（推算）', '单季', '%', '2026Q1', '2026-03-31', 7.64, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第一季度业绩公告（2026-05-26）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '经调整净利润', '单季', '亿元', '2026Q1', '2026-03-31', 60.72, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第一季度业绩公告（2026-05-26）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '期间利润（国际财务报告准则）', '单季', '亿元', '2026Q1', '2026-03-31', 47.35, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第一季度业绩公告（2026-05-26）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '全球月活跃用户', '单季', '百万人', '2026Q1', '2026-03-31', 746.2, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第一季度业绩公告（2026-05-26）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '研发开支', '单季', '亿元', '2026Q1', '2026-03-31', 89.54, 0.334029, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第一季度业绩公告（2026-05-26）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '现金储备', '单季', '亿元', '2026Q1', '2026-03-31', 2206, NULL, '公司口径（含现金、定期存款、短期投资、长期摊余成本投资与理财）', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第一季度业绩公告（2026-05-26）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '借款', '单季', '亿元', '2026Q1', '2026-03-31', 353.68, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第一季度业绩公告（2026-05-26）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '回购（港元）', '单季', '亿港元', '2026Q1', '2026-03-31', 52.58, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第二季度及中期业绩公告（2026-08-18）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '营业收入', '单季', '亿元', '2026Q2', '2026-06-30', 1089.22, -0.060661, '出货 −26.5%、ASP +25.9%（控量保价）；国补退坡 IoT −19.2%；汽车及 AI 分部经营亏损 26 亿元。', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第二季度及中期业绩公告（2026-08-18）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '手机×AIoT 分部收入', '单季', '亿元', '2026Q2', '2026-06-30', 840.26, -0.112648, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第二季度及中期业绩公告（2026-08-18）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智能电动汽车及AI分部收入', '单季', '亿元', '2026Q2', '2026-06-30', 248.96, 0.17086, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第二季度及中期业绩公告（2026-08-18）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智能手机收入', '单季', '亿元', '2026Q2', '2026-06-30', 421.19, -0.074714, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第二季度及中期业绩公告（2026-08-18）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'IoT与生活消费产品收入', '单季', '亿元', '2026Q2', '2026-06-30', 312.78, -0.192033, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第二季度及中期业绩公告（2026-08-18）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '互联网服务收入', '单季', '亿元', '2026Q2', '2026-06-30', 90.44, -0.005935, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第二季度及中期业绩公告（2026-08-18）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '毛利率', '单季', '%', '2026Q2', '2026-06-30', 19.84, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第二季度及中期业绩公告（2026-08-18）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '手机×AIoT 分部毛利率', '单季', '%', '2026Q2', '2026-06-30', 20.01, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第二季度及中期业绩公告（2026-08-18）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '汽车及AI分部毛利率', '单季', '%', '2026Q2', '2026-06-30', 19.25, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第二季度及中期业绩公告（2026-08-18）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智能手机毛利率', '单季', '%', '2026Q2', '2026-06-30', 8.54, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第二季度及中期业绩公告（2026-08-18）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'IoT毛利率', '单季', '%', '2026Q2', '2026-06-30', 20.05, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第二季度及中期业绩公告（2026-08-18）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '互联网服务毛利率', '单季', '%', '2026Q2', '2026-06-30', 76.76, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第二季度及中期业绩公告（2026-08-18）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智能手机出货量', '单季', '百万台', '2026Q2', '2026-06-30', 31.2, -0.264151, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第二季度及中期业绩公告（2026-08-18）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智能手机ASP', '单季', '元', '2026Q2', '2026-06-30', 1351.0, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第二季度及中期业绩公告（2026-08-18）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '汽车交付量', '单季', '辆', '2026Q2', '2026-06-30', 104199, 0.281629, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第二季度及中期业绩公告（2026-08-18）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '汽车ASP', '单季', '元', '2026Q2', '2026-06-30', 229312, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第二季度及中期业绩公告（2026-08-18）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '汽车及AI分部经营损益', '单季', '亿元', '2026Q2', '2026-06-30', -26.08, NULL, '毛利 47.92−经营开支 74（公告取整）', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第二季度及中期业绩公告（2026-08-18）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '生态经营利润（推算）', '单季', '亿元', '2026Q2', '2026-06-30', 48.55, NULL, '分部毛利 168.17−(集团研发、销售、行政 193.62−汽车及 AI 分部经营开支 74)', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第二季度及中期业绩公告（2026-08-18）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '生态经营利润率（推算）', '单季', '%', '2026Q2', '2026-06-30', 5.78, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第二季度及中期业绩公告（2026-08-18）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '经调整净利润', '单季', '亿元', '2026Q2', '2026-06-30', 62.19, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第二季度及中期业绩公告（2026-08-18）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '期间利润（国际财务报告准则）', '单季', '亿元', '2026Q2', '2026-06-30', 94.63, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第二季度及中期业绩公告（2026-08-18）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '全球月活跃用户', '单季', '百万人', '2026Q2', '2026-06-30', 766.5, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第二季度及中期业绩公告（2026-08-18）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '研发开支', '单季', '亿元', '2026Q2', '2026-06-30', 92.31, 0.189102, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第二季度及中期业绩公告（2026-08-18）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '现金储备', '单季', '亿元', '2026Q2', '2026-06-30', 2193, NULL, '公司口径（含现金、定期存款、短期投资、长期摊余成本投资与理财）', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第二季度及中期业绩公告（2026-08-18）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '借款', '单季', '亿元', '2026Q2', '2026-06-30', 392.77, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第二季度及中期业绩公告（2026-08-18）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '回购（港元）', '单季', '亿港元', '2026Q2', '2026-06-30', 57.04, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第二季度及中期业绩公告（2026-08-18）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '全球月活跃用户（12 月）', '全年', '百万人', '2018', '2018-12-31', 242.1, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2018—2024 年全年业绩公告（分业务收入与成本、月活、出货量、创新业务费用）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '全球月活跃用户（12 月）', '全年', '百万人', '2019', '2019-12-31', 309.6, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2018—2024 年全年业绩公告（分业务收入与成本、月活、出货量、创新业务费用）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '全球月活跃用户（12 月）', '全年', '百万人', '2020', '2020-12-31', 396.3, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2018—2024 年全年业绩公告（分业务收入与成本、月活、出货量、创新业务费用）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '全球月活跃用户（12 月）', '全年', '百万人', '2021', '2021-12-31', 508.9, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2018—2024 年全年业绩公告（分业务收入与成本、月活、出货量、创新业务费用）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '全球月活跃用户（12 月）', '全年', '百万人', '2022', '2022-12-31', 582.1, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2018—2024 年全年业绩公告（分业务收入与成本、月活、出货量、创新业务费用）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '全球月活跃用户（12 月）', '全年', '百万人', '2023', '2023-12-31', 641.2, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2018—2024 年全年业绩公告（分业务收入与成本、月活、出货量、创新业务费用）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '全球月活跃用户（12 月）', '全年', '百万人', '2024', '2024-12-31', 702.3, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2018—2024 年全年业绩公告（分业务收入与成本、月活、出货量、创新业务费用）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '全球月活跃用户（12 月）', '全年', '百万人', '2025', '2025-12-31', 754.1, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年全年业绩公告（2026-03-24）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智能手机出货量', '全年', '百万台', '2020', '2020-12-31', 146.4, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2018—2024 年全年业绩公告（分业务收入与成本、月活、出货量、创新业务费用）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智能手机出货量', '全年', '百万台', '2021', '2021-12-31', 190.3, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2018—2024 年全年业绩公告（分业务收入与成本、月活、出货量、创新业务费用）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智能手机出货量', '全年', '百万台', '2022', '2022-12-31', 150.5, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2018—2024 年全年业绩公告（分业务收入与成本、月活、出货量、创新业务费用）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智能手机出货量', '全年', '百万台', '2023', '2023-12-31', 145.6, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2018—2024 年全年业绩公告（分业务收入与成本、月活、出货量、创新业务费用）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智能手机出货量', '全年', '百万台', '2024', '2024-12-31', 168.5, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2018—2024 年全年业绩公告（分业务收入与成本、月活、出货量、创新业务费用）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智能手机出货量', '全年', '百万台', '2025', '2025-12-31', 165.2, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年全年业绩公告（2026-03-24）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智能手机收入', '全年', '亿元', '2019', '2019-12-31', 1220.95, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2018—2024 年全年业绩公告（分业务收入与成本、月活、出货量、创新业务费用）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'IoT与生活消费产品收入', '全年', '亿元', '2019', '2019-12-31', 620.88, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2018—2024 年全年业绩公告（分业务收入与成本、月活、出货量、创新业务费用）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '互联网服务收入', '全年', '亿元', '2019', '2019-12-31', 198.42, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2018—2024 年全年业绩公告（分业务收入与成本、月活、出货量、创新业务费用）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '其他相关业务收入', '全年', '亿元', '2019', '2019-12-31', 18.14, NULL, '2023 年及以前为“其他”', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2018—2024 年全年业绩公告（分业务收入与成本、月活、出货量、创新业务费用）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智能手机毛利率', '全年', '%', '2019', '2019-12-31', 7.17, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2018—2024 年全年业绩公告（分业务收入与成本、月活、出货量、创新业务费用）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'IoT毛利率', '全年', '%', '2019', '2019-12-31', 11.2, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2018—2024 年全年业绩公告（分业务收入与成本、月活、出货量、创新业务费用）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'AIoT毛利率（含其他相关业务）', '全年', '%', '2019', '2019-12-31', 10.88, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2018—2024 年全年业绩公告（分业务收入与成本、月活、出货量、创新业务费用）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '互联网服务毛利率', '全年', '%', '2019', '2019-12-31', 64.73, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2018—2024 年全年业绩公告（分业务收入与成本、月活、出货量、创新业务费用）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '生态营业费用率（推算）', '全年', '%', '2019', '2019-12-31', 10.19, NULL, '集团研发、销售、行政 209.75 亿元÷生态收入 2,058.39 亿元', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '东方财富港股格式三大报表（akshare 取数）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智能手机经营利润（分摊）', '全年', '亿元', '2019', '2019-12-31', -36.82, NULL, '按收入分摊“手机×AIoT”营业费用（本研究假设，公司不拆分）', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '东方财富港股格式三大报表（akshare 取数）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'AIoT经营利润（分摊）', '全年', '亿元', '2019', '2019-12-31', 4.4, NULL, '按收入分摊“手机×AIoT”营业费用（本研究假设，公司不拆分）', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '东方财富港股格式三大报表（akshare 取数）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '互联网服务经营利润（分摊）', '全年', '亿元', '2019', '2019-12-31', 108.22, NULL, '按收入分摊“手机×AIoT”营业费用（本研究假设，公司不拆分）', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '东方财富港股格式三大报表（akshare 取数）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智能手机收入', '全年', '亿元', '2020', '2020-12-31', 1521.91, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2018—2024 年全年业绩公告（分业务收入与成本、月活、出货量、创新业务费用）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'IoT与生活消费产品收入', '全年', '亿元', '2020', '2020-12-31', 674.11, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2018—2024 年全年业绩公告（分业务收入与成本、月活、出货量、创新业务费用）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '互联网服务收入', '全年', '亿元', '2020', '2020-12-31', 237.55, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2018—2024 年全年业绩公告（分业务收入与成本、月活、出货量、创新业务费用）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '其他相关业务收入', '全年', '亿元', '2020', '2020-12-31', 25.09, NULL, '2023 年及以前为“其他”', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2018—2024 年全年业绩公告（分业务收入与成本、月活、出货量、创新业务费用）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智能手机毛利率', '全年', '%', '2020', '2020-12-31', 8.68, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2018—2024 年全年业绩公告（分业务收入与成本、月活、出货量、创新业务费用）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'IoT毛利率', '全年', '%', '2020', '2020-12-31', 12.77, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2018—2024 年全年业绩公告（分业务收入与成本、月活、出货量、创新业务费用）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'AIoT毛利率（含其他相关业务）', '全年', '%', '2020', '2020-12-31', 12.73, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2018—2024 年全年业绩公告（分业务收入与成本、月活、出货量、创新业务费用）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '互联网服务毛利率', '全年', '%', '2020', '2020-12-31', 61.65, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2018—2024 年全年业绩公告（分业务收入与成本、月活、出货量、创新业务费用）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '生态营业费用率（推算）', '全年', '%', '2020', '2020-12-31', 11.2, NULL, '集团研发、销售、行政 275.42 亿元÷生态收入 2,458.66 亿元', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '东方财富港股格式三大报表（akshare 取数）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智能手机经营利润（分摊）', '全年', '亿元', '2020', '2020-12-31', -38.45, NULL, '按收入分摊“手机×AIoT”营业费用（本研究假设，公司不拆分）', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '东方财富港股格式三大报表（akshare 取数）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'AIoT经营利润（分摊）', '全年', '亿元', '2020', '2020-12-31', 10.71, NULL, '按收入分摊“手机×AIoT”营业费用（本研究假设，公司不拆分）', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '东方财富港股格式三大报表（akshare 取数）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '互联网服务经营利润（分摊）', '全年', '亿元', '2020', '2020-12-31', 119.83, NULL, '按收入分摊“手机×AIoT”营业费用（本研究假设，公司不拆分）', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '东方财富港股格式三大报表（akshare 取数）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智能手机收入', '全年', '亿元', '2021', '2021-12-31', 2088.69, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2018—2024 年全年业绩公告（分业务收入与成本、月活、出货量、创新业务费用）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'IoT与生活消费产品收入', '全年', '亿元', '2021', '2021-12-31', 849.8, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2018—2024 年全年业绩公告（分业务收入与成本、月活、出货量、创新业务费用）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '互联网服务收入', '全年', '亿元', '2021', '2021-12-31', 282.12, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2018—2024 年全年业绩公告（分业务收入与成本、月活、出货量、创新业务费用）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '其他相关业务收入', '全年', '亿元', '2021', '2021-12-31', 62.48, NULL, '2023 年及以前为“其他”', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2018—2024 年全年业绩公告（分业务收入与成本、月活、出货量、创新业务费用）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智能手机毛利率', '全年', '%', '2021', '2021-12-31', 11.9, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2018—2024 年全年业绩公告（分业务收入与成本、月活、出货量、创新业务费用）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'IoT毛利率', '全年', '%', '2021', '2021-12-31', 13.05, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2018—2024 年全年业绩公告（分业务收入与成本、月活、出货量、创新业务费用）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'AIoT毛利率（含其他相关业务）', '全年', '%', '2021', '2021-12-31', 13.71, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2018—2024 年全年业绩公告（分业务收入与成本、月活、出货量、创新业务费用）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '互联网服务毛利率', '全年', '%', '2021', '2021-12-31', 74.07, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2018—2024 年全年业绩公告（分业务收入与成本、月活、出货量、创新业务费用）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '生态营业费用率（推算）', '全年', '%', '2021', '2021-12-31', 11.84, NULL, '集团研发、销售、行政 388.87 亿元÷生态收入 3,283.09 亿元', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '东方财富港股格式三大报表（akshare 取数）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智能手机经营利润（分摊）', '全年', '亿元', '2021', '2021-12-31', 1.21, NULL, '按收入分摊“手机×AIoT”营业费用（本研究假设，公司不拆分）', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '东方财富港股格式三大报表（akshare 取数）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'AIoT经营利润（分摊）', '全年', '亿元', '2021', '2021-12-31', 16.99, NULL, '按收入分摊“手机×AIoT”营业费用（本研究假设，公司不拆分）', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '东方财富港股格式三大报表（akshare 取数）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '互联网服务经营利润（分摊）', '全年', '亿元', '2021', '2021-12-31', 175.54, NULL, '按收入分摊“手机×AIoT”营业费用（本研究假设，公司不拆分）', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '东方财富港股格式三大报表（akshare 取数）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智能手机收入', '全年', '亿元', '2022', '2022-12-31', 1672.17, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2018—2024 年全年业绩公告（分业务收入与成本、月活、出货量、创新业务费用）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'IoT与生活消费产品收入', '全年', '亿元', '2022', '2022-12-31', 797.95, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2018—2024 年全年业绩公告（分业务收入与成本、月活、出货量、创新业务费用）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '互联网服务收入', '全年', '亿元', '2022', '2022-12-31', 283.21, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2018—2024 年全年业绩公告（分业务收入与成本、月活、出货量、创新业务费用）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '其他相关业务收入', '全年', '亿元', '2022', '2022-12-31', 47.1, NULL, '2023 年及以前为“其他”', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2018—2024 年全年业绩公告（分业务收入与成本、月活、出货量、创新业务费用）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智能手机毛利率', '全年', '%', '2022', '2022-12-31', 8.95, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2018—2024 年全年业绩公告（分业务收入与成本、月活、出货量、创新业务费用）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'IoT毛利率', '全年', '%', '2022', '2022-12-31', 14.41, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2018—2024 年全年业绩公告（分业务收入与成本、月活、出货量、创新业务费用）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'AIoT毛利率（含其他相关业务）', '全年', '%', '2022', '2022-12-31', 14.51, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2018—2024 年全年业绩公告（分业务收入与成本、月活、出货量、创新业务费用）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '互联网服务毛利率', '全年', '%', '2022', '2022-12-31', 71.84, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2018—2024 年全年业绩公告（分业务收入与成本、月活、出货量、创新业务费用）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '生态营业费用率（推算）', '全年', '%', '2022', '2022-12-31', 14.06, NULL, '集团研发、销售、行政 424.65−31 亿元÷生态收入 2,800.44 亿元', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '东方财富港股格式三大报表（akshare 取数）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智能手机经营利润（分摊）', '全年', '亿元', '2022', '2022-12-31', -85.36, NULL, '按收入分摊“手机×AIoT”营业费用（本研究假设，公司不拆分）', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '东方财富港股格式三大报表（akshare 取数）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'AIoT经营利润（分摊）', '全年', '亿元', '2022', '2022-12-31', 3.83, NULL, '按收入分摊“手机×AIoT”营业费用（本研究假设，公司不拆分）', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '东方财富港股格式三大报表（akshare 取数）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '互联网服务经营利润（分摊）', '全年', '亿元', '2022', '2022-12-31', 163.66, NULL, '按收入分摊“手机×AIoT”营业费用（本研究假设，公司不拆分）', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '东方财富港股格式三大报表（akshare 取数）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智能手机收入', '全年', '亿元', '2023', '2023-12-31', 1574.61, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2018—2024 年全年业绩公告（分业务收入与成本、月活、出货量、创新业务费用）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'IoT与生活消费产品收入', '全年', '亿元', '2023', '2023-12-31', 801.08, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2018—2024 年全年业绩公告（分业务收入与成本、月活、出货量、创新业务费用）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '互联网服务收入', '全年', '亿元', '2023', '2023-12-31', 301.07, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2018—2024 年全年业绩公告（分业务收入与成本、月活、出货量、创新业务费用）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '其他相关业务收入', '全年', '亿元', '2023', '2023-12-31', 32.94, NULL, '2023 年及以前为“其他”', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2018—2024 年全年业绩公告（分业务收入与成本、月活、出货量、创新业务费用）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智能手机毛利率', '全年', '%', '2023', '2023-12-31', 14.59, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2018—2024 年全年业绩公告（分业务收入与成本、月活、出货量、创新业务费用）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'IoT毛利率', '全年', '%', '2023', '2023-12-31', 16.33, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2018—2024 年全年业绩公告（分业务收入与成本、月活、出货量、创新业务费用）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'AIoT毛利率（含其他相关业务）', '全年', '%', '2023', '2023-12-31', 14.58, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2018—2024 年全年业绩公告（分业务收入与成本、月活、出货量、创新业务费用）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '互联网服务毛利率', '全年', '%', '2023', '2023-12-31', 74.18, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2018—2024 年全年业绩公告（分业务收入与成本、月活、出货量、创新业务费用）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '生态营业费用率（推算）', '全年', '%', '2023', '2023-12-31', 13.56, NULL, '集团研发、销售、行政 434.51−67 亿元÷生态收入 2,709.70 亿元', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '东方财富港股格式三大报表（akshare 取数）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智能手机经营利润（分摊）', '全年', '亿元', '2023', '2023-12-31', 16.25, NULL, '按收入分摊“手机×AIoT”营业费用（本研究假设，公司不拆分）', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '东方财富港股格式三大报表（akshare 取数）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'AIoT经营利润（分摊）', '全年', '亿元', '2023', '2023-12-31', 8.5, NULL, '按收入分摊“手机×AIoT”营业费用（本研究假设，公司不拆分）', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '东方财富港股格式三大报表（akshare 取数）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '互联网服务经营利润（分摊）', '全年', '亿元', '2023', '2023-12-31', 182.51, NULL, '按收入分摊“手机×AIoT”营业费用（本研究假设，公司不拆分）', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '东方财富港股格式三大报表（akshare 取数）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智能手机收入', '全年', '亿元', '2024', '2024-12-31', 1917.59, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2018—2024 年全年业绩公告（分业务收入与成本、月活、出货量、创新业务费用）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'IoT与生活消费产品收入', '全年', '亿元', '2024', '2024-12-31', 1041.04, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2018—2024 年全年业绩公告（分业务收入与成本、月活、出货量、创新业务费用）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '互联网服务收入', '全年', '亿元', '2024', '2024-12-31', 341.15, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2018—2024 年全年业绩公告（分业务收入与成本、月活、出货量、创新业务费用）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '其他相关业务收入', '全年', '亿元', '2024', '2024-12-31', 31.74, NULL, '2023 年及以前为“其他”', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2018—2024 年全年业绩公告（分业务收入与成本、月活、出货量、创新业务费用）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智能手机毛利率', '全年', '%', '2024', '2024-12-31', 12.65, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2018—2024 年全年业绩公告（分业务收入与成本、月活、出货量、创新业务费用）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'IoT毛利率', '全年', '%', '2024', '2024-12-31', 20.26, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2018—2024 年全年业绩公告（分业务收入与成本、月活、出货量、创新业务费用）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'AIoT毛利率（含其他相关业务）', '全年', '%', '2024', '2024-12-31', 18.75, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2018—2024 年全年业绩公告（分业务收入与成本、月活、出货量、创新业务费用）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '互联网服务毛利率', '全年', '%', '2024', '2024-12-31', 76.64, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2018—2024 年全年业绩公告（分业务收入与成本、月活、出货量、创新业务费用）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '生态营业费用率（推算）', '全年', '%', '2024', '2024-12-31', 12.56, NULL, '集团研发、销售、行政 550.41−132 亿元÷生态收入 3,331.53 亿元', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '东方财富港股格式三大报表（akshare 取数）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智能手机经营利润（分摊）', '全年', '亿元', '2024', '2024-12-31', 1.71, NULL, '按收入分摊“手机×AIoT”营业费用（本研究假设，公司不拆分）', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '东方财富港股格式三大报表（akshare 取数）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'AIoT经营利润（分摊）', '全年', '亿元', '2024', '2024-12-31', 66.36, NULL, '按收入分摊“手机×AIoT”营业费用（本研究假设，公司不拆分）', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '东方财富港股格式三大报表（akshare 取数）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '互联网服务经营利润（分摊）', '全年', '亿元', '2024', '2024-12-31', 218.62, NULL, '按收入分摊“手机×AIoT”营业费用（本研究假设，公司不拆分）', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '东方财富港股格式三大报表（akshare 取数）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智能手机收入', '全年', '亿元', '2025', '2025-12-31', 1864.4, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年全年业绩公告（2026-03-24）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'IoT与生活消费产品收入', '全年', '亿元', '2025', '2025-12-31', 1232.0, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年全年业绩公告（2026-03-24）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '互联网服务收入', '全年', '亿元', '2025', '2025-12-31', 374.4, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年全年业绩公告（2026-03-24）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '其他相关业务收入', '全年', '亿元', '2025', '2025-12-31', 41.37, NULL, '2023 年及以前为“其他”', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年全年业绩公告（2026-03-24）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智能手机毛利率', '全年', '%', '2025', '2025-12-31', 10.87, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年全年业绩公告（2026-03-24）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'IoT毛利率', '全年', '%', '2025', '2025-12-31', 23.07, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年全年业绩公告（2026-03-24）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'AIoT毛利率（含其他相关业务）', '全年', '%', '2025', '2025-12-31', 21.31, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年全年业绩公告（2026-03-24）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '互联网服务毛利率', '全年', '%', '2025', '2025-12-31', 76.5, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年全年业绩公告（2026-03-24）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '生态营业费用率（推算）', '全年', '%', '2025', '2025-12-31', 13.72, NULL, '集团研发、销售、行政 730.00−248 亿元÷生态收入 3,512.17 亿元', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '东方财富港股格式三大报表（akshare 取数）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '智能手机经营利润（分摊）', '全年', '亿元', '2025', '2025-12-31', -53.2, NULL, '按收入分摊“手机×AIoT”营业费用（本研究假设，公司不拆分）', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '东方财富港股格式三大报表（akshare 取数）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'AIoT经营利润（分摊）', '全年', '亿元', '2025', '2025-12-31', 96.61, NULL, '按收入分摊“手机×AIoT”营业费用（本研究假设，公司不拆分）', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '东方财富港股格式三大报表（akshare 取数）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '互联网服务经营利润（分摊）', '全年', '亿元', '2025', '2025-12-31', 235.02, NULL, '按收入分摊“手机×AIoT”营业费用（本研究假设，公司不拆分）', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '东方财富港股格式三大报表（akshare 取数）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '生态经营利润率（推算）', '全年', '%', '2019', '2019-12-31', 3.68, NULL, '毛利−研发−销售−行政＋当年创新业务费用（2022 年 31、2023 年 67 亿元）；2024 年起用分部数据', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '东方财富港股格式三大报表（akshare 取数）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '生态经营利润率（推算）', '全年', '%', '2020', '2020-12-31', 3.75, NULL, '毛利−研发−销售−行政＋当年创新业务费用（2022 年 31、2023 年 67 亿元）；2024 年起用分部数据', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '东方财富港股格式三大报表（akshare 取数）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '生态经营利润率（推算）', '全年', '%', '2021', '2021-12-31', 5.9, NULL, '毛利−研发−销售−行政＋当年创新业务费用（2022 年 31、2023 年 67 亿元）；2024 年起用分部数据', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '东方财富港股格式三大报表（akshare 取数）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '生态经营利润率（推算）', '全年', '%', '2022', '2022-12-31', 2.93, NULL, '毛利−研发−销售−行政＋当年创新业务费用（2022 年 31、2023 年 67 亿元）；2024 年起用分部数据', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '东方财富港股格式三大报表（akshare 取数）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '生态经营利润率（推算）', '全年', '%', '2023', '2023-12-31', 7.65, NULL, '毛利−研发−销售−行政＋当年创新业务费用（2022 年 31、2023 年 67 亿元）；2024 年起用分部数据', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '东方财富港股格式三大报表（akshare 取数）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '生态经营利润率（推算）', '全年', '%', '2024', '2024-12-31', 8.61, NULL, '毛利−研发−销售−行政＋当年创新业务费用（2022 年 31、2023 年 67 亿元）；2024 年起用分部数据', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '东方财富港股格式三大报表（akshare 取数）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '生态经营利润率（推算）', '全年', '%', '2025', '2025-12-31', 7.93, NULL, '毛利−研发−销售−行政＋当年创新业务费用（2022 年 31、2023 年 67 亿元）；2024 年起用分部数据', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '东方财富港股格式三大报表（akshare 取数）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '生态经营利润（推算）', '全年', '亿元', '2024', '2024-12-31', 286.7, NULL, '分部毛利 705.1−(集团费用 550.4−汽车及 AI 分部经营开支 132)', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年全年业绩公告（2026-03-24）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '生态经营利润（推算）', '全年', '亿元', '2025', '2025-12-31', 278.4, NULL, '分部毛利 760.4−(集团费用 730.0−汽车及 AI 分部经营开支 248)', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年全年业绩公告（2026-03-24）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '汽车交付量', '全年', '辆', '2024', '2024-12-31', 136854, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年全年业绩公告（2026-03-24）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '汽车交付量', '全年', '辆', '2025', '2025-12-31', 411082, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年全年业绩公告（2026-03-24）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '汽车及AI分部经营损益', '全年', '亿元', '2024', '2024-12-31', -71.5, NULL, '毛利 60.5−经营开支 132（含 AI，按 2025 年口径重述）', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年全年业绩公告（2026-03-24）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '汽车及AI分部经营损益', '全年', '亿元', '2025', '2025-12-31', 9.6, NULL, '毛利 257.6−经营开支 248；公告称经营收益 9 亿元', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年全年业绩公告（2026-03-24）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '回购（港元）', '全年', '亿港元', '2025', '2025-12-31', 63, NULL, '约 152.6 百万股', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年全年业绩公告（2026-03-24）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '其他相关业务毛利率', '单季', '%', '2024Q1', '2024-03-31', -12.78, NULL, '分部合计减手机、IoT、互联网：收入 5.79 亿元、毛利 -0.74 亿元', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '其他相关业务毛利率', '单季', '%', '2024Q2', '2024-06-30', 0.82, NULL, '分部合计减手机、IoT、互联网：收入 9.77 亿元、毛利 0.08 亿元', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '其他相关业务毛利率', '单季', '%', '2024Q3', '2024-09-30', -37.88, NULL, '分部合计减手机、IoT、互联网：收入 7.92 亿元、毛利 -3.00 亿元', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '其他相关业务毛利率', '单季', '%', '2024Q4', '2024-12-31', -74.61, NULL, '分部合计减手机、IoT、互联网：收入 8.27 亿元、毛利 -6.17 亿元', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '其他相关业务毛利率', '单季', '%', '2025Q1', '2025-03-31', -46.5, NULL, '分部合计减手机、IoT、互联网：收入 6.86 亿元、毛利 -3.19 亿元', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '其他相关业务毛利率', '单季', '%', '2025Q2', '2025-06-30', -23.33, NULL, '分部合计减手机、IoT、互联网：收入 13.63 亿元、毛利 -3.18 亿元', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第二季度及中期业绩公告（2025-08-19）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '其他相关业务毛利率', '单季', '%', '2025Q3', '2025-09-30', -28.95, NULL, '分部合计减手机、IoT、互联网：收入 12.09 亿元、毛利 -3.50 亿元', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第三季度业绩公告（2025-11-18）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '其他相关业务毛利率', '单季', '%', '2025Q4', '2025-12-31', -34.17, NULL, '分部合计减手机、IoT、互联网：收入 8.78 亿元、毛利 -3.00 亿元', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年全年业绩公告（2026-03-24）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '其他相关业务毛利率', '单季', '%', '2026Q1', '2026-03-31', -9.71, NULL, '分部合计减手机、IoT、互联网：收入 8.55 亿元、毛利 -0.83 亿元', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第一季度业绩公告（2026-05-26）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '其他相关业务毛利率', '单季', '%', '2026Q2', '2026-06-30', 0.25, NULL, '分部合计减手机、IoT、互联网：收入 15.85 亿元、毛利 0.04 亿元', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年第二季度及中期业绩公告（2026-08-18）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '其他相关业务毛利率', '全年', '%', '2019', '2019-12-31', -0.14, NULL, '2023 年及以前为“其他”', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2018—2024 年全年业绩公告（分业务收入与成本、月活、出货量、创新业务费用）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '其他相关业务毛利率', '全年', '%', '2020', '2020-12-31', 11.87, NULL, '2023 年及以前为“其他”', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2018—2024 年全年业绩公告（分业务收入与成本、月活、出货量、创新业务费用）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '其他相关业务毛利率', '全年', '%', '2021', '2021-12-31', 22.62, NULL, '2023 年及以前为“其他”', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2018—2024 年全年业绩公告（分业务收入与成本、月活、出货量、创新业务费用）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '其他相关业务毛利率', '全年', '%', '2022', '2022-12-31', 16.2, NULL, '2023 年及以前为“其他”', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2018—2024 年全年业绩公告（分业务收入与成本、月活、出货量、创新业务费用）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '其他相关业务毛利率', '全年', '%', '2023', '2023-12-31', -27.84, NULL, '2023 年及以前为“其他”', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2018—2024 年全年业绩公告（分业务收入与成本、月活、出货量、创新业务费用）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '其他相关业务毛利率', '全年', '%', '2024', '2024-12-31', -30.96, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2018—2024 年全年业绩公告（分业务收入与成本、月活、出货量、创新业务费用）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '其他相关业务毛利率', '全年', '%', '2025', '2025-12-31', -31.12, NULL, NULL, (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年全年业绩公告（2026-03-24）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '手机×AIoT 分部毛利率', '全年', '%', '2024', '2024-12-31', 21.16, NULL, '毛利 705.10÷收入 3331.53 亿元（四个季度合计）', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '汽车及AI分部毛利率', '全年', '%', '2024', '2024-12-31', 18.47, NULL, '毛利 60.50÷收入 327.54 亿元（四个季度合计）', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年第一季度业绩公告（2025-05-27）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '手机×AIoT 分部毛利率', '全年', '%', '2025', '2025-12-31', 21.65, NULL, '毛利 760.42÷收入 3512.17 亿元（四个季度合计）', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年全年业绩公告（2026-03-24）' LIMIT 1));

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '汽车及AI分部毛利率', '全年', '%', '2025', '2025-12-31', 24.29, NULL, '毛利 257.63÷收入 1060.69 亿元（四个季度合计）', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年全年业绩公告（2026-03-24）' LIMIT 1));

INSERT INTO vi_issue_base (company_id, code, title, severity, impact, done_condition, status, progress) VALUES
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'Q01', '安全边际选 10% 还是 30%', '策略', '关注价', '用户确定交易纪律后在估值模型里只保留一档。', '待处理', '两档并列（与其他公司一致）。'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'Q02', '经营假设待核验', '关键', '2026—2035 年全部情景', '三季报（2026 年 11 月下旬）与年报出来后逐项对照，逐年标记“已核验”。', '待处理', '三季报重点：手机与 IoT 毛利率、生态费用率、汽车交付与分部损益、AI 投入口径。'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'Q03', '汽车与 AI 的成本拆分是估算', '关键', '经营分部 S4；股东回报折现的 AI 成本', '公司披露 AI 投入的实际金额或分部拆分。', '待处理', '按汽车本身经营利润率约 7%—10% 倒推；专家口径相差 4—5 倍。'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'Q04', '资金汇出成本是估算', '一般', '分部估值项 C6', '读取 2025 年年报中国附属公司未分派利润与预扣税附注（岗底斯 PDF 字体编码异常，需换来源）。', '待处理', '基准扣 30 亿元。'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'Q05', '现金储备口径差 81.7 亿元', '一般', '分部估值项 C1', '在中报附注或投资者关系材料里找到现金储备的明细定义与差额原因。', '待处理', '采用较低的公司口径。'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'Q06', '投资者负债流动部分是估算', '一般', '分部估值项 C9', '中报附注披露的流动部分。', '待处理', '按 2025 年末 11.34 亿元估计。'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'Q07', '上市股权按市值更新', '一般', '分部估值项 C8', '整理上市持股（数量、市值）后单独列示，不打与未上市相同的折扣。', '待处理', '2025 年末一级公允价值 71.7 亿元。'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'Q08', '纪要、研报与第三方数据为三级来源', '一般', '事实摘录', '交付、份额、单车利润以公司公告或年报核对。', '待处理', NULL),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'Q09', '印度冻结资金与潜在罚款', '一般', '分部估值项 C7', '跟踪判决或和解。', '待处理', NULL),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'Q10', '股权激励稀释口径', '一般', '股本', '比较“费用已在利润率里扣除”与“按摊薄股本”两种处理，确认是否重复。', '待处理', '按摊薄股本（约 264 亿股），每股价值约 −2.7%。'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'Q11', 'AI 直接估值 1,000 亿元是主观判断', '关键', '经营分部 S5（每股约 3.89 元）', '小米披露 AI 收入、单独融资或分拆，或用户调整判断。', '待处理', '用户 2026-10-23 指定，参照国内大模型公司估值；资金口径偏高约 331 亿元（剩余承诺投入的税后现值，见 J-AI）。'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), 'Q12', '营业费用按收入分摊到手机、AIoT、互联网是假设', '一般', '经营分部 S1—S3', '公司披露分业务费用或经营利润。', '待处理', '按毛利分摊时每股约 −1.67 元；三块用同一倍数时分摊方式不影响合计（见 J-OPEX）。');

INSERT INTO vi_change_log_base (company_id, change_date, title, target, old_value, new_value, reason, basis, verification) VALUES
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026-10-23', '纳入价值投资框架（独立项目）', '公司、研究、商业与壁垒、历史财务、定期经营数据、估值模型、跟踪', '—', '10 条论点（7 条自动证伪）、57 张事实卡、20 条判断；商业模式 9、产业链 11、竞争对手 9、候选壁垒 9（含伪壁垒 3）、多空辩论 5、适配度 19/40；2018—2025 年历史财务、2024Q1—2026Q2 季度经营数据；经营分部估值（生态、汽车、AI）＋11 个分部估值项＋股东回报折现交叉验证；港股股价自动采集', '用户要求增加小米集团案例，按业务形式和发展阶段选择更适合的估值方式', '2025 年一至三季度、2025 年全年、2026 年一、二季度业绩公告；2025 年年报与 2026 年中报附注；港交所月报表；东方财富报表；业绩会纪要、卖方与专家纪要（三级来源）', '季度收入、分部收入与全年公告一致；Python 独立复算三情景分部价值与数据库视图一致（见 README）'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026-10-23', '框架新增“经营分部估值”，小米为首个使用者', '估值模型（分部加总不读预测计算）、经营分部估值、情景概率', '分部加总只有一个“核心业务”，取预测计算某一年的盈利×倍数', '经营分部按发展阶段选方法：盈利×倍数、稳态折现、承诺投入；分部加总给出市场隐含成熟业务倍数、市场隐含成长业务价值与概率加权价值；新增自动检查 C17', '小米的三个业务处在不同阶段，单一倍数会把周期底部、成长期和投入期混在一起', '价值驱动公式；稳态折现；承诺投入只计成本（价值投资的保守原则）', '其他四家公司估值不变（空库重建与在线库一致）'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026-10-23', '估值调整：手机、AIoT、互联网分开估值；AI 按直接估值 1,000 亿元', '经营分部估值（5 个分部）、判断（新增 J-PHONE、J-AIOT、J-NET、J-OPEX，改写 J-AI、J-MULT 等）、论点、辩论、跟踪事项、逐年假设、年度分业务数据', '生态（手机×AIoT）合并按 2028 年 6.7%×13.9 倍（2,571 亿元）；AI 按承诺投入只计成本（−1,011 亿元）；基准 17.20 元、悲观 5.81、乐观 35.23、加权 18.86 元', 'S1 手机 −420、S2 AIoT 871、S3 互联网 3,039、S4 汽车 1,078、S5 AI 1,000 亿元；基准 28.59 元、悲观 15.05、乐观 48.46、加权 30.18 元（现价 21.96 元）', '用户要求：AI 当作一个整体直接加 1,000 亿元（主观判断，参照国内大模型公司估值）；手机、AIoT、互联网的结构与趋势不同，有分拆口径就分开算', '2019—2025 年全年业绩公告分业务收入与成本；2026 年一、二季度业绩公告；东方财富报表（费用）；智谱、MiniMax 行情；大模型公司融资报道（三级来源）', '独立复算（checks/xm_model.py）与数据库视图一致；分业务数据与公告、东方财富报表核对（checks/xm_datacheck.py）；敏感性见 checks/xm_sens.py'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026-10-23', '框架新增“直接估值”方法', '经营分部估值·估值方法', '盈利×倍数、稳态折现、承诺投入', '新增“直接估值”：按可比公司、交易价格或主观判断填写整体价值，不折现；分部加总、市场隐含值与自动检查 C17 一并计入', 'AI 业务没有可预测的盈利，用户要求按可比公司估值直接加总', '—', '其他四家公司估值不变'),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026-10-23', '商业模式分析重构：论点与多空辩论合并，同一观点只写一处', '论点与辩论、竞争壁垒、商业模式、产业链与五力、适配度的关联，参数判断里的论点编号', '投资论点 10 条＋多空辩论 5 场，分在“研究”“商业与壁垒”两组；同一观点在论点、辩论、壁垒里重复（例如互联网变现同时写在 T1、D1、M1、B1）', '论点与辩论 9 条（辩论过 5 条，带自动检查 7 条）：T1 生态与互联网变现（原 T1＋D1）、T2 存储周期与手机毛利率（原 T2＋D2）、T3 汽车（原 T3＋D3）、T4 AI 投入的回报（原 T4＋D4）、T5—T7 净现金、现金含量、资本开支（原 T5—T7）、T8 治理与股东回报（原 T8＋T9）、T9 现价是否已反映悲观预期（原 T10＋D5）。商业模式、产业链、竞争壁垒里与论点重复的论证改成按编号引用；产业链的同业、替代品关联到具体对手。原 T10 标“存疑”与辩论 D5 的“势均力敌”不一致，按辩论记为“观察”。', '用户要求把“研究”和“商业与壁垒”合并为“商业模式分析”，尽量减少冗余、确保内容完整', '框架迁移 2026-10-23d（多空辩论并入论点：正方占优→成立、势均力敌→观察、反方占优→存疑）；内容来自原论点、辩论与各表，没有新增研究结论', 'tools/content_audit.py：重构前研究文字里 665 个带单位的数字，重构后只有 1 个按原样找不到（“1.6 万家小米之家”，M3 里写作“1.6—1.8 万家”）；行与行之间共有的长片段从 83 对降到 75 对（剩下的多是参数判断、事实卡与引用它们的行）。估值不变：经营分部基准 28.59 元（悲观 15.05、乐观 48.46，加权 30.18），股东回报折现 3.34、11.40、24.47 元；C09、C14、C17 通过，5 项非伪壁垒都关联了辩论过的论点。');

DELETE FROM vi_fin_stmt_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK');

INSERT INTO vi_fin_stmt_base (company_id, period, period_end, stmt, item, seq, amount) VALUES
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '资产负债表', '物业厂房及设备', 1, 290.77133),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '资产负债表', '无形资产', 2, 108.63229),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '资产负债表', '递延税项资产', 3, 40.16785),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '资产负债表', '长期投资', 4, 160.08606),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '资产负债表', '其他投资', 5, 66.1491),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '资产负债表', '指定以公允价值记账之金融资产', 6, 853.43013),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '资产负债表', '中长期存款', 7, 657.10773),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '资产负债表', '非流动资产其他项目', 8, 206.31893),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '资产负债表', '非流动资产合计', 9, 2382.66342),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '资产负债表', '存货', 10, 848.82115),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '资产负债表', '应收帐款', 11, 197.73065),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '资产负债表', '预付款按金及其他应收款', 12, 341.67707),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '资产负债表', '短期投资', 13, 5.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '资产负债表', '受限制存款及现金', 14, 41.38063),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '资产负债表', '现金及等价物', 15, 372.52369),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '资产负债表', '短期存款', 16, 624.65572),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '资产负债表', '指定以公允价值记账之金融资产(流动)', 17, 215.05612),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '资产负债表', '贷款及垫款(流动)', 18, 130.89949),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '资产负债表', '流动资产合计', 19, 2777.74452),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '资产负债表', '总资产', 20, 5160.40794),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '资产负债表', '应付帐款', 21, 1183.28052),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '资产负债表', '应付税项', 22, 35.31512),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '资产负债表', '其他应付款及应计费用', 23, 278.66977),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '资产负债表', '预收款项', 24, 185.63761),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '资产负债表', '短期贷款', 25, 97.06402),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '资产负债表', '拨备(流动)', 26, 82.42106),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '资产负债表', '流动负债合计', 27, 1862.3881),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '资产负债表', '净流动资产', 28, 915.35642),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '资产负债表', '总资产减流动负债', 29, 3298.01984),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '资产负债表', '长期贷款', 30, 295.7036),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '资产负债表', '递延税项负债', 31, 28.2204),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '资产负债表', '拨备(非流动)', 32, 34.43191),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '资产负债表', '其他非流动负债', 33, 241.46991),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '资产负债表', '非流动负债合计', 34, 599.82582),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '资产负债表', '总负债', 35, 2462.21392),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '资产负债表', '少数股东权益', 36, 1.1949),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '资产负债表', '净资产', 37, 2698.19402),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '资产负债表', '股本', 38, 0.00422),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '资产负债表', '储备', 39, 2696.9949),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '资产负债表', '股东权益', 40, 2696.99912),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '资产负债表', '总权益', 41, 2698.19402),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '资产负债表', '总权益及非流动负债', 42, 3298.01984),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '资产负债表', '总权益及总负债', 43, 5160.40794),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '资产负债表', '物业厂房及设备', 1, 287.46276),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '资产负债表', '无形资产', 2, 116.75867),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '资产负债表', '递延税项资产', 3, 35.83828),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '资产负债表', '长期投资', 4, 154.56222),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '资产负债表', '其他投资', 5, 63.54209),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '资产负债表', '指定以公允价值记账之金融资产', 6, 810.52059),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '资产负债表', '中长期存款', 7, 889.10343),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '资产负债表', '非流动资产其他项目', 8, 208.76807),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '资产负债表', '非流动资产合计', 9, 2566.55611),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '资产负债表', '存货', 10, 781.86312),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '资产负债表', '应收帐款', 11, 177.82583),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '资产负债表', '预付款按金及其他应收款', 12, 325.99838),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '资产负债表', '短期投资', 13, 2.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '资产负债表', '受限制存款及现金', 14, 41.64351),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '资产负债表', '现金及等价物', 15, 263.34483),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '资产负债表', '短期存款', 16, 534.43271),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '资产负债表', '指定以公允价值记账之金融资产(流动)', 17, 182.47657),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '资产负债表', '贷款及垫款(流动)', 18, 91.33578),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '资产负债表', '流动资产合计', 19, 2400.92073),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '资产负债表', '总资产', 20, 4967.47684),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '资产负债表', '应付帐款', 21, 1049.36289),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '资产负债表', '应付税项', 22, 42.11268),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '资产负债表', '其他应付款及应计费用', 23, 311.74133),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '资产负债表', '预收款项', 24, 174.66933),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '资产负债表', '短期贷款', 25, 103.60504),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '资产负债表', '拨备(流动)', 26, 75.40551),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '资产负债表', '流动负债合计', 27, 1756.89678),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '资产负债表', '净流动资产', 28, 644.02395),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '资产负债表', '总资产减流动负债', 29, 3210.58006),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '资产负债表', '长期贷款', 30, 250.06733),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '资产负债表', '递延税项负债', 31, 21.17825),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '资产负债表', '拨备(非流动)', 32, 38.7834),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '资产负债表', '其他非流动负债', 33, 240.21184),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '资产负债表', '非流动负债合计', 34, 550.24082),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '资产负债表', '总负债', 35, 2307.1376),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '资产负债表', '少数股东权益', 36, 1.18389),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '资产负债表', '净资产', 37, 2660.33924),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '资产负债表', '股本', 38, 0.00424),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '资产负债表', '储备', 39, 2659.15111),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '资产负债表', '股东权益', 40, 2659.15535),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '资产负债表', '总权益', 41, 2660.33924),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '资产负债表', '总权益及非流动负债', 42, 3210.58006),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '资产负债表', '总权益及总负债', 43, 4967.47684),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '资产负债表', '物业厂房及设备', 1, 279.50293),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '资产负债表', '无形资产', 2, 83.19373),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '资产负债表', '递延税项资产', 3, 36.36008),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '资产负债表', '长期投资', 4, 134.056),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '资产负债表', '其他投资', 5, 62.68209),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '资产负债表', '指定以公允价值记账之金融资产', 6, 808.81337),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '资产负债表', '中长期存款', 7, 920.45627),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '资产负债表', '非流动资产其他项目', 8, 207.78731),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '资产负债表', '非流动资产合计', 9, 2532.85178),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '资产负债表', '存货', 10, 809.89452),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '资产负债表', '应收帐款', 11, 152.39877),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '资产负债表', '预付款按金及其他应收款', 12, 337.25967),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '资产负债表', '短期投资', 13, 2.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '资产负债表', '受限制存款及现金', 14, 45.78635),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '资产负债表', '现金及等价物', 15, 269.14377),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '资产负债表', '短期存款', 16, 513.08666),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '资产负债表', '指定以公允价值记账之金融资产(流动)', 17, 292.73546),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '资产负债表', '贷款及垫款(流动)', 18, 125.80269),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '资产负债表', '流动资产合计', 19, 2548.10789),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '资产负债表', '总资产', 20, 5080.95967),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '资产负债表', '应付帐款', 21, 1106.99472),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '资产负债表', '应付税项', 22, 66.49117),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '资产负债表', '其他应付款及应计费用', 23, 353.51923),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '资产负债表', '预收款项', 24, 192.72778),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '资产负债表', '短期贷款', 25, 132.02226),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '资产负债表', '拨备(流动)', 26, 72.29961),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '资产负债表', '流动负债合计', 27, 1924.05477),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '资产负债表', '净流动资产', 28, 624.05312),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '资产负债表', '总资产减流动负债', 29, 3156.9049),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '资产负债表', '长期贷款', 30, 229.21433),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '资产负债表', '递延税项负债', 31, 24.00758),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '资产负债表', '拨备(非流动)', 32, 36.52246),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '资产负债表', '其他非流动负债', 33, 203.92784),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '资产负债表', '非流动负债合计', 34, 493.67221),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '资产负债表', '总负债', 35, 2417.72698),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '资产负债表', '少数股东权益', 36, 1.04608),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '资产负债表', '净资产', 37, 2663.23269),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '资产负债表', '股本', 38, 0.00426),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '资产负债表', '储备', 39, 2662.18235),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '资产负债表', '股东权益', 40, 2662.18661),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '资产负债表', '总权益', 41, 2663.23269),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '资产负债表', '总权益及非流动负债', 42, 3156.9049),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '资产负债表', '总权益及总负债', 43, 5080.95967),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '资产负债表', '物业厂房及设备', 1, 250.69729),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '资产负债表', '无形资产', 2, 82.36914),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '资产负债表', '递延税项资产', 3, 27.2911),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '资产负债表', '长期投资', 4, 111.90926),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '资产负债表', '其他投资', 5, 55.70532),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '资产负债表', '指定以公允价值记账之金融资产', 6, 806.72583),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '资产负债表', '中长期存款', 7, 932.39483),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '资产负债表', '非流动资产其他项目', 8, 202.92177),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '资产负债表', '非流动资产合计', 9, 2470.01454),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '资产负债表', '存货', 10, 739.95731),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '资产负债表', '应收帐款', 11, 226.37428),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '资产负债表', '应收票据', 44, 3.56024),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '资产负债表', '预付款按金及其他应收款', 12, 354.44933),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '资产负债表', '受限制存款及现金', 14, 49.65884),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '资产负债表', '现金及等价物', 15, 355.47957),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '资产负债表', '短期存款', 16, 552.18606),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '资产负债表', '指定以公允价值记账之金融资产(流动)', 17, 193.83757),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '资产负债表', '贷款及垫款(流动)', 18, 82.1473),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '资产负债表', '流动资产合计', 19, 2557.6505),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '资产负债表', '总资产', 20, 5027.66504),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '资产负债表', '应付帐款', 21, 1168.08735),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '资产负债表', '应付税项', 22, 39.33305),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '资产负债表', '其他应付款及应计费用', 23, 354.89748),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '资产负债表', '预收款项', 24, 204.00068),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '资产负债表', '短期贷款', 25, 95.88872),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '资产负债表', '拨备(流动)', 26, 79.98619),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '资产负债表', '流动负债合计', 27, 1942.19347),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '资产负债表', '净流动资产', 28, 615.45703),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '资产负债表', '总资产减流动负债', 29, 3085.47157),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '资产负债表', '长期贷款', 30, 180.00079),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '资产负债表', '递延税项负债', 31, 36.04246),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '资产负债表', '拨备(非流动)', 32, 25.32296),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '资产负债表', '其他非流动负债', 33, 188.47168),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '资产负债表', '非流动负债合计', 34, 429.83789),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '资产负债表', '总负债', 35, 2372.03136),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '资产负债表', '少数股东权益', 36, 1.04608),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '资产负债表', '净资产', 37, 2655.63368),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '资产负债表', '股本', 38, 0.00426),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '资产负债表', '储备', 39, 2654.58334),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '资产负债表', '股东权益', 40, 2654.5876),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '资产负债表', '总权益', 41, 2655.63368),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '资产负债表', '总权益及非流动负债', 42, 3085.47157),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '资产负债表', '总权益及总负债', 43, 5027.66504),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '资产负债表', '物业厂房及设备', 1, 222.12155),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '资产负债表', '无形资产', 2, 79.37987),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '资产负债表', '递延税项资产', 3, 27.10583),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '资产负债表', '长期投资', 4, 106.5856),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '资产负债表', '其他投资', 5, 60.34029),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '资产负债表', '指定以公允价值记账之金融资产', 6, 741.62523),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '资产负债表', '中长期存款', 7, 943.13995),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '资产负债表', '非流动资产其他项目', 8, 198.67964),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '资产负债表', '非流动资产合计', 9, 2378.97796),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '资产负债表', '存货', 10, 658.25475),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '资产负债表', '应收帐款', 11, 188.4526),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '资产负债表', '应收票据', 44, 1.8411),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '资产负债表', '预付款按金及其他应收款', 12, 303.06542),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '资产负债表', '受限制存款及现金', 14, 54.11773),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '资产负债表', '现金及等价物', 15, 360.0803),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '资产负债表', '短期存款', 16, 570.3364),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '资产负债表', '指定以公允价值记账之金融资产(流动)', 17, 188.93285),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '资产负债表', '贷款及垫款(流动)', 18, 111.11847),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '资产负债表', '流动资产合计', 19, 2436.19962),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '资产负债表', '总资产', 20, 4815.17758),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '资产负债表', '应付帐款', 21, 1083.93324),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '资产负债表', '应付税项', 22, 37.03966),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '资产负债表', '其他应付款及应计费用', 23, 384.57592),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '资产负债表', '预收款项', 24, 193.63377),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '资产负债表', '短期贷款', 25, 106.40895),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '资产负债表', '拨备(流动)', 26, 77.69839),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '资产负债表', '流动负债合计', 27, 1883.28993),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '资产负债表', '净流动资产', 28, 552.90969),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '资产负债表', '总资产减流动负债', 29, 2931.88765),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '资产负债表', '长期贷款', 30, 182.71941),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '资产负债表', '递延税项负债', 31, 19.33737),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '资产负债表', '拨备(非流动)', 32, 21.87132),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '资产负债表', '其他非流动负债', 33, 179.3526),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '资产负债表', '非流动负债合计', 34, 403.2807),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '资产负债表', '总负债', 35, 2286.57063),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '资产负债表', '少数股东权益', 36, 3.86989),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '资产负债表', '净资产', 37, 2528.60695),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '资产负债表', '股本', 38, 0.00425),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '资产负债表', '储备', 39, 2524.73281),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '资产负债表', '股东权益', 40, 2524.73706),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '资产负债表', '总权益', 41, 2528.60695),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '资产负债表', '总权益及非流动负债', 42, 2931.88765),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '资产负债表', '总权益及总负债', 43, 4815.17758),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '资产负债表', '物业厂房及设备', 1, 195.85867),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '资产负债表', '无形资产', 2, 81.38204),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '资产负债表', '递延税项资产', 3, 30.37605),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '资产负债表', '长期投资', 4, 34.77489),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '资产负债表', '其他投资', 5, 62.22997),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '资产负债表', '指定以公允价值记账之金融资产', 6, 615.63538),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '资产负债表', '中长期存款', 7, 732.65512),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '资产负债表', '非流动资产其他项目', 8, 189.27984),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '资产负债表', '非流动资产合计', 9, 1942.19196),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '资产负债表', '存货', 10, 614.16913),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '资产负债表', '应收帐款', 11, 172.85786),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '资产负债表', '应收票据', 44, 23.71833),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '资产负债表', '预付款按金及其他应收款', 12, 292.80684),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '资产负债表', '短期投资', 13, 4.0343),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '资产负债表', '受限制存款及现金', 14, 53.1503),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '资产负债表', '现金及等价物', 15, 861.71927),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '资产负债表', '短期存款', 16, 167.17922),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '资产负债表', '指定以公允价值记账之金融资产(流动)', 17, 269.4386),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '资产负债表', '贷款及垫款(流动)', 18, 99.89781),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '资产负债表', '流动资产合计', 19, 2558.97166),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '资产负债表', '总资产', 20, 4501.16362),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '资产负债表', '应付帐款', 21, 937.5396),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '资产负债表', '应付税项', 22, 38.16651),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '资产负债表', '其他应付款及应计费用', 23, 359.75107),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '资产负债表', '预收款项', 24, 162.60249),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '资产负债表', '短期贷款', 25, 127.13769),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '资产负债表', '拨备(流动)', 26, 76.77008),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '资产负债表', '流动负债合计', 27, 1701.96744),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '资产负债表', '净流动资产', 28, 857.00422),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '资产负债表', '总资产减流动负债', 29, 2799.19618),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '资产负债表', '长期贷款', 30, 182.30916),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '资产负债表', '递延税项负债', 31, 16.44527),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '资产负债表', '拨备(非流动)', 32, 18.11678),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '资产负债表', '非流动负债其他项目', 45, 183.00716),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '资产负债表', '非流动负债合计', 34, 399.87837),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '资产负债表', '总负债', 35, 2101.84581),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '资产负债表', '少数股东权益', 36, 4.33222),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '资产负债表', '净资产', 37, 2399.31781),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '资产负债表', '股本', 38, 0.00424),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '资产负债表', '储备', 39, 2394.98135),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '资产负债表', '股东权益', 40, 2394.98559),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '资产负债表', '总权益', 41, 2399.31781),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '资产负债表', '总权益及非流动负债', 42, 2799.19618),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '资产负债表', '总权益及总负债', 43, 4501.16362),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '资产负债表', '物业厂房及设备', 1, 180.87583),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '资产负债表', '无形资产', 2, 81.52721),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '资产负债表', '递延税项资产', 3, 27.81982),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '资产负债表', '长期投资', 4, 32.19462),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '资产负债表', '其他投资', 5, 61.51055),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '资产负债表', '指定以公允价值记账之金融资产', 6, 621.12188),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '资产负债表', '中长期存款', 7, 585.20305),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '资产负债表', '非流动资产其他项目', 8, 184.21227),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '资产负债表', '非流动资产合计', 9, 1774.46523),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '资产负债表', '存货', 10, 625.09682),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '资产负债表', '应收帐款', 11, 145.88579),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '资产负债表', '应收票据', 44, 12.55767),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '资产负债表', '预付款按金及其他应收款', 12, 291.00116),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '资产负债表', '短期投资', 13, 7.00163),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '资产负债表', '受限制存款及现金', 14, 54.76417),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '资产负债表', '现金及等价物', 15, 336.61442),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '资产负债表', '短期存款', 16, 363.50271),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '资产负债表', '指定以公允价值记账之金融资产(流动)', 17, 298.04839),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '资产负债表', '贷款及垫款(流动)', 18, 122.6149),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '资产负债表', '流动资产合计', 19, 2257.08766),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '资产负债表', '总资产', 20, 4031.55289),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '资产负债表', '应付帐款', 21, 982.80585),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '资产负债表', '应付税项', 22, 38.22134),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '资产负债表', '其他应付款及应计费用', 23, 363.72035),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '资产负债表', '预收款项', 24, 165.81252),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '资产负债表', '短期贷款', 25, 133.27297),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '资产负债表', '拨备(流动)', 26, 70.01687),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '资产负债表', '流动负债合计', 27, 1753.8499),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '资产负债表', '净流动资产', 28, 503.23776),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '资产负债表', '总资产减流动负债', 29, 2277.70299),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '资产负债表', '长期贷款', 30, 172.75721),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '资产负债表', '递延税项负债', 31, 12.82196),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '资产负债表', '拨备(非流动)', 32, 16.95063),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '资产负债表', '其他非流动负债', 33, 183.122),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '资产负债表', '非流动负债合计', 34, 385.6518),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '资产负债表', '总负债', 35, 2139.5017),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '资产负债表', '少数股东权益', 36, 4.67342),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '资产负债表', '净资产', 37, 1892.05119),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '资产负债表', '股本', 38, 0.00407),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '资产负债表', '储备', 39, 1887.3737),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '资产负债表', '股东权益', 40, 1887.37777),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '资产负债表', '总权益', 41, 1892.05119),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '资产负债表', '总权益及非流动负债', 42, 2277.70299),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '资产负债表', '总权益及总负债', 43, 4031.55289),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '资产负债表', '物业厂房及设备', 1, 161.54692),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '资产负债表', '无形资产', 2, 83.88912),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '资产负债表', '递延税项资产', 3, 22.93469),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '资产负债表', '长期投资', 4, 3.13216),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '资产负债表', '其他投资', 5, 64.46306),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '资产负债表', '指定以公允价值记账之金融资产', 6, 584.54489),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '资产负债表', '中长期存款', 7, 399.29852),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '资产负债表', '非流动资产其他项目', 8, 160.53319),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '资产负债表', '非流动资产合计', 9, 1480.34255),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '资产负债表', '存货', 10, 493.13196),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '资产负债表', '应收帐款', 11, 143.72495),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '资产负债表', '应收票据', 44, 25.86998),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '资产负债表', '预付款按金及其他应收款', 12, 220.62267),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '资产负债表', '受限制存款及现金', 14, 49.21119),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '资产负债表', '现金及等价物', 15, 396.55354),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '资产负债表', '短期存款', 16, 393.43922),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '资产负债表', '指定以公允价值记账之金融资产(流动)', 17, 205.84291),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '资产负债表', '贷款及垫款(流动)', 18, 100.71468),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '资产负债表', '流动资产合计', 19, 2029.1111),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '资产负债表', '总资产', 20, 3509.45365),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '资产负债表', '应付帐款', 21, 686.88815),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '资产负债表', '应付税项', 22, 32.93507),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '资产负债表', '其他应付款及应计费用', 23, 307.80666),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '资产负债表', '预收款项', 24, 142.6702),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '资产负债表', '短期贷款', 25, 49.44089),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '资产负债表', '拨备(流动)', 26, 66.43773),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '资产负债表', '流动负债合计', 27, 1286.1787),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '资产负债表', '净流动资产', 28, 742.9324),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '资产负债表', '总资产减流动负债', 29, 2223.27495),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '资产负债表', '长期贷款', 30, 224.16058),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '资产负债表', '递延税项负债', 31, 12.36418),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '资产负债表', '拨备(非流动)', 32, 13.51873),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '资产负债表', '非流动负债其他项目', 45, 194.98622),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '资产负债表', '非流动负债合计', 34, 445.02971),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '资产负债表', '总负债', 35, 1731.20841),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '资产负债表', '少数股东权益', 36, 5.80468),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '资产负债表', '净资产', 37, 1778.24524),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '资产负债表', '股本', 38, 0.00406),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '资产负债表', '储备', 39, 1772.4365),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '资产负债表', '股东权益', 40, 1772.44056),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '资产负债表', '总权益', 41, 1778.24524),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '资产负债表', '总权益及非流动负债', 42, 2223.27495),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '资产负债表', '总权益及总负债', 43, 3509.45365),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '资产负债表', '物业厂房及设备', 1, 157.79911),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '资产负债表', '无形资产', 2, 77.1925),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '资产负债表', '递延税项资产', 3, 21.60968),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '资产负债表', '长期投资', 4, 3.65749),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '资产负债表', '其他投资', 5, 66.66577),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '资产负债表', '指定以公允价值记账之金融资产', 6, 586.99067),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '资产负债表', '中长期存款', 7, 329.88833),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '资产负债表', '非流动资产其他项目', 8, 148.14712),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '资产负债表', '非流动资产合计', 9, 1391.95067),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '资产负债表', '存货', 10, 515.24154),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '资产负债表', '应收帐款', 11, 136.48816),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '资产负债表', '应收票据', 44, 0.62812),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '资产负债表', '预付款按金及其他应收款', 12, 241.14891),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '资产负债表', '短期投资', 13, 10.11263),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '资产负债表', '受限制存款及现金', 14, 48.1221),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '资产负债表', '现金及等价物', 15, 393.3582),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '资产负债表', '短期存款', 16, 378.63112),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '资产负债表', '指定以公允价值记账之金融资产(流动)', 17, 196.20204),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '资产负债表', '贷款及垫款(流动)', 18, 109.86878),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '资产负债表', '流动资产合计', 19, 2029.8016),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '资产负债表', '总资产', 20, 3421.75227),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '资产负债表', '应付帐款', 21, 667.72473),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '资产负债表', '应付税项', 22, 25.00246),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '资产负债表', '其他应付款及应计费用', 23, 273.73634),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '资产负债表', '预收款项', 24, 135.06871),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '资产负债表', '短期贷款', 25, 89.43685),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '资产负债表', '拨备(流动)', 26, 69.0551),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '资产负债表', '流动负债合计', 27, 1260.02419),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '资产负债表', '净流动资产', 28, 769.77741),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '资产负债表', '总资产减流动负债', 29, 2161.72808),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '资产负债表', '长期贷款', 30, 210.37527),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '资产负债表', '递延税项负债', 31, 11.30255),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '资产负债表', '拨备(非流动)', 32, 12.2472),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '资产负债表', '非流动负债其他项目', 45, 195.84484),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '资产负债表', '非流动负债合计', 34, 429.76986),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '资产负债表', '总负债', 35, 1689.79405),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '资产负债表', '少数股东权益', 36, 6.24075),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '资产负债表', '净资产', 37, 1731.95822),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '资产负债表', '股本', 38, 0.00407),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '资产负债表', '储备', 39, 1725.7134),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '资产负债表', '股东权益', 40, 1725.71747),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '资产负债表', '总权益', 41, 1731.95822),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '资产负债表', '总权益及非流动负债', 42, 2161.72808),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '资产负债表', '总权益及总负债', 43, 3421.75227),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '资产负债表', '物业厂房及设备', 1, 143.2416),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '资产负债表', '无形资产', 2, 80.79485),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '资产负债表', '递延税项资产', 3, 23.57527),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '资产负债表', '长期投资', 4, 3.64404),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '资产负债表', '其他投资', 5, 70.7519),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '资产负债表', '指定以公允价值记账之金融资产', 6, 581.35532),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '资产负债表', '中长期存款', 7, 196.0348),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '资产负债表', '非流动资产其他项目', 8, 170.14313),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '资产负债表', '非流动资产合计', 9, 1269.54091),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '资产负债表', '存货', 10, 519.18525),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '资产负债表', '应收帐款', 11, 112.13539),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '资产负债表', '应收票据', 44, 2.6145),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '资产负债表', '预付款按金及其他应收款', 12, 235.62064),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '资产负债表', '短期投资', 13, 10.02998),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '资产负债表', '受限制存款及现金', 14, 44.92491),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '资产负债表', '现金及等价物', 15, 348.96211),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '资产负债表', '短期存款', 16, 479.72147),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '资产负债表', '指定以公允价值记账之金融资产(流动)', 17, 136.5746),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '资产负债表', '贷款及垫款(流动)', 18, 110.40569),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '资产负债表', '流动资产合计', 19, 2000.17454),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '资产负债表', '总资产', 20, 3269.71545),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '资产负债表', '应付帐款', 21, 605.47077),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '资产负债表', '应付税项', 22, 21.86128),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '资产负债表', '其他应付款及应计费用', 23, 260.63631),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '资产负债表', '预收款项', 24, 131.56844),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '资产负债表', '短期贷款', 25, 50.34168),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '资产负债表', '拨备(流动)', 26, 66.77479),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '资产负债表', '流动负债合计', 27, 1136.65327),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '资产负债表', '净流动资产', 28, 863.52127),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '资产负债表', '总资产减流动负债', 29, 2133.06218),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '资产负债表', '长期贷款', 30, 226.71729),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '资产负债表', '递延税项负债', 31, 13.43266),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '资产负债表', '拨备(非流动)', 32, 10.89747),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '资产负债表', '非流动负债其他项目', 45, 206.07675),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '资产负债表', '非流动负债合计', 34, 457.12417),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '资产负债表', '总负债', 35, 1593.77744),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '资产负债表', '少数股东权益', 36, 2.57581),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '资产负债表', '净资产', 37, 1675.93801),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '资产负债表', '股本', 38, 0.00405),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '资产负债表', '储备', 39, 1673.35815),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '资产负债表', '股东权益', 40, 1673.3622),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '资产负债表', '总权益', 41, 1675.93801),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '资产负债表', '总权益及非流动负债', 42, 2133.06218),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '资产负债表', '总权益及总负债', 43, 3269.71545),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '资产负债表', '物业厂房及设备', 1, 137.20825),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '资产负债表', '无形资产', 2, 86.28739),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '资产负债表', '递延税项资产', 3, 21.6075),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '资产负债表', '长期投资', 4, 3.64476),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '资产负债表', '其他投资', 5, 69.22241),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '资产负债表', '指定以公允价值记账之金融资产', 6, 601.99798),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '资产负债表', '中长期存款', 7, 182.9365),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '资产负债表', '非流动资产其他项目', 8, 149.0426),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '资产负债表', '非流动资产合计', 9, 1251.94739),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '资产负债表', '存货', 10, 444.22837),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '资产负债表', '应收帐款', 11, 121.50928),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '资产负债表', '应收票据', 44, 1.25661),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '资产负债表', '预付款按金及其他应收款', 12, 200.78875),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '资产负债表', '短期投资', 13, 5.02816),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '资产负债表', '受限制存款及现金', 14, 47.94031),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '资产负债表', '现金及等价物', 15, 336.31313),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '资产负债表', '短期存款', 16, 527.97857),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '资产负债表', '指定以公允价值记账之金融资产(流动)', 17, 207.75793),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '资产负债表', '贷款及垫款(流动)', 18, 97.72589),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '资产负债表', '流动资产合计', 19, 1990.527),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '资产负债表', '总资产', 20, 3242.47439),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '资产负债表', '应付帐款', 21, 620.985),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '资产负债表', '应付税项', 22, 18.38222),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '资产负债表', '其他应付款及应计费用', 23, 256.1465),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '资产负债表', '预收款项', 24, 136.14756),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '资产负债表', '短期贷款', 25, 61.83376),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '资产负债表', '拨备(流动)', 26, 62.38092),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '资产负债表', '流动负债合计', 27, 1155.87596),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '资产负债表', '净流动资产', 28, 834.65104),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '资产负债表', '总资产减流动负债', 29, 2086.59843),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '资产负债表', '长期贷款', 30, 216.73969),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '资产负债表', '递延税项负债', 31, 14.94287),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '资产负债表', '拨备(非流动)', 32, 12.15546),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '资产负债表', '非流动负债其他项目', 45, 200.14273),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '资产负债表', '非流动负债合计', 34, 443.98075),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '资产负债表', '总负债', 35, 1599.85671),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '资产负债表', '少数股东权益', 36, 2.66279),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '资产负债表', '净资产', 37, 1642.61768),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '资产负债表', '股本', 38, 0.00407),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '资产负债表', '储备', 39, 1639.95082),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '资产负债表', '股东权益', 40, 1639.95489),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '资产负债表', '总权益', 41, 1642.61768),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '资产负债表', '总权益及非流动负债', 42, 2086.59843),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '资产负债表', '总权益及总负债', 43, 3242.47439),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '资产负债表', '物业厂房及设备', 1, 127.0766),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '资产负债表', '无形资产', 2, 63.6466),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '资产负债表', '递延税项资产', 3, 23.85405),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '资产负债表', '长期投资', 4, 3.69886),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '资产负债表', '其他投资', 5, 80.66276),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '资产负债表', '指定以公允价值记账之金融资产', 6, 584.28088),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '资产负债表', '中长期存款', 7, 187.01409),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '资产负债表', '非流动资产其他项目', 8, 152.45291),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '资产负债表', '非流动资产合计', 9, 1222.68675),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '资产负债表', '存货', 10, 368.42283),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '资产负债表', '应收帐款', 11, 136.77498),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '资产负债表', '应收票据', 44, 8.18815),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '资产负债表', '预付款按金及其他应收款', 12, 180.08742),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '资产负债表', '短期投资', 13, 8.05713),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '资产负债表', '受限制存款及现金', 14, 47.25321),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '资产负债表', '现金及等价物', 15, 316.52566),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '资产负债表', '短期存款', 16, 513.58738),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '资产负债表', '指定以公允价值记账之金融资产(流动)', 17, 148.66168),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '资产负债表', '贷款及垫款(流动)', 18, 67.19983),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '资产负债表', '流动资产合计', 19, 1794.75827),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '资产负债表', '总资产', 20, 3017.44502),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '资产负债表', '应付帐款', 21, 546.82769),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '资产负债表', '应付税项', 22, 25.11629),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '资产负债表', '其他应付款及应计费用', 23, 223.29531),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '资产负债表', '预收款项', 24, 111.8986),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '资产负债表', '短期贷款', 25, 20.60828),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '资产负债表', '拨备(流动)', 26, 62.06622),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '资产负债表', '流动负债合计', 27, 989.81239),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '资产负债表', '净流动资产', 28, 804.94588),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '资产负债表', '总资产减流动负债', 29, 2027.63263),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '资产负债表', '长期贷款', 30, 227.74352),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '资产负债表', '递延税项负债', 31, 12.01213),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '资产负债表', '拨备(非流动)', 32, 9.74946),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '资产负债表', '非流动负债其他项目', 45, 177.49263),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '资产负债表', '非流动负债合计', 34, 426.99774),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '资产负债表', '总负债', 35, 1416.81013),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '资产负债表', '少数股东权益', 36, 2.72809),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '资产负债表', '净资产', 37, 1600.63489),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '资产负债表', '股本', 38, 0.00407),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '资产负债表', '储备', 39, 1597.90273),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '资产负债表', '股东权益', 40, 1597.9068),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '资产负债表', '总权益', 41, 1600.63489),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '资产负债表', '总权益及非流动负债', 42, 2027.63263),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '资产负债表', '总权益及总负债', 43, 3017.44502),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '资产负债表', '物业厂房及设备', 1, 120.19697),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '资产负债表', '无形资产', 2, 60.22056),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '资产负债表', '递延税项资产', 3, 26.16219),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '资产负债表', '长期投资', 4, 3.93037),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '资产负债表', '其他投资', 5, 82.16675),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '资产负债表', '指定以公允价值记账之金融资产', 6, 594.67861),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '资产负债表', '中长期存款', 7, 137.85172),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '资产负债表', '非流动资产其他项目', 8, 155.40046),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '资产负债表', '非流动资产合计', 9, 1180.60763),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '资产负债表', '存货', 10, 384.54691),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '资产负债表', '应收帐款', 11, 125.41275),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '资产负债表', '应收票据', 44, 16.40327),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '资产负债表', '预付款按金及其他应收款', 12, 198.19186),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '资产负债表', '短期投资', 13, 10.02271),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '资产负债表', '受限制存款及现金', 14, 46.26218),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '资产负债表', '现金及等价物', 15, 314.58952),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '资产负债表', '短期存款', 16, 430.95579),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '资产负债表', '指定以公允价值记账之金融资产(流动)', 17, 137.13191),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '资产负债表', '贷款及垫款(流动)', 18, 71.4386),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '资产负债表', '流动资产合计', 19, 1734.9555),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '资产负债表', '总资产', 20, 2915.56313),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '资产负债表', '应付帐款', 21, 551.06248),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '资产负债表', '应付税项', 22, 23.08186),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '资产负债表', '其他应付款及应计费用', 23, 202.01026),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '资产负债表', '预收款项', 24, 98.87617),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '资产负债表', '短期贷款', 25, 11.22048),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '资产负债表', '拨备(流动)', 26, 59.60115),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '资产负债表', '流动负债合计', 27, 945.8524),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '资产负债表', '净流动资产', 28, 789.1031),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '资产负债表', '总资产减流动负债', 29, 1969.71073),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '资产负债表', '长期贷款', 30, 217.63554),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '资产负债表', '递延税项负债', 31, 13.26542),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '资产负债表', '拨备(非流动)', 32, 10.67218),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '资产负债表', '非流动负债其他项目', 45, 177.60467),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '资产负债表', '非流动负债合计', 34, 419.17781),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '资产负债表', '总负债', 35, 1365.03021),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '资产负债表', '少数股东权益', 36, 2.78341),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '资产负债表', '净资产', 37, 1550.53292),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '资产负债表', '股本', 38, 0.00407),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '资产负债表', '储备', 39, 1547.74544),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '资产负债表', '股东权益', 40, 1547.74951),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '资产负债表', '总权益', 41, 1550.53292),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '资产负债表', '总权益及非流动负债', 42, 1969.71073),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '资产负债表', '总权益及总负债', 43, 2915.56313),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '资产负债表', '物业厂房及设备', 1, 97.22141),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '资产负债表', '无形资产', 2, 42.91536),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '资产负债表', '递延税项资产', 3, 23.47871),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '资产负债表', '长期投资', 4, 4.02784),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '资产负债表', '其他投资', 5, 76.92981),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '资产负债表', '指定以公允价值记账之金融资产', 6, 589.91776),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '资产负债表', '中长期存款', 7, 130.68812),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '资产负债表', '非流动资产其他项目', 8, 158.77018),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '资产负债表', '非流动资产合计', 9, 1123.94919),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '资产负债表', '存货', 10, 425.95212),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '资产负债表', '应收帐款', 11, 111.40264),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '资产负债表', '应收票据', 44, 2.831),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '资产负债表', '预付款按金及其他应收款', 12, 159.52534),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '资产负债表', '短期投资', 13, 10.02508),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '资产负债表', '受限制存款及现金', 14, 42.23933),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '资产负债表', '现金及等价物', 15, 261.80952),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '资产负债表', '短期存款', 16, 340.66141),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '资产负债表', '指定以公允价值记账之金融资产(流动)', 17, 99.92951),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '资产负债表', '贷款及垫款(流动)', 18, 63.64918),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '资产负债表', '流动资产合计', 19, 1518.02513),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '资产负债表', '总资产', 20, 2641.97432),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '资产负债表', '应付帐款', 21, 415.84877),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '资产负债表', '应付税项', 22, 16.7306),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '资产负债表', '其他应付款及应计费用', 23, 177.5694),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '资产负债表', '预收款项', 24, 83.57078),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '资产负债表', '短期贷款', 25, 15.83363),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '资产负债表', '拨备(流动)', 26, 50.54347),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '资产负债表', '流动负债合计', 27, 760.09665),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '资产负债表', '净流动资产', 28, 757.92848),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '资产负债表', '总资产减流动负债', 29, 1881.87767),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '资产负债表', '长期贷款', 30, 208.80846),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '资产负债表', '递延税项负债', 31, 12.48149),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '资产负债表', '拨备(非流动)', 32, 8.36313),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '资产负债表', '非流动负债其他项目', 45, 168.4837),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '资产负债表', '非流动负债合计', 34, 398.13678),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '资产负债表', '总负债', 35, 1158.23343),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '资产负债表', '少数股东权益', 36, 2.72589),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '资产负债表', '净资产', 37, 1483.74089),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '资产负债表', '股本', 38, 0.00407),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '资产负债表', '储备', 39, 1481.01093),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '资产负债表', '股东权益', 40, 1481.015),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '资产负债表', '总权益', 41, 1483.74089),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '资产负债表', '总权益及非流动负债', 42, 1881.87767),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '资产负债表', '总权益及总负债', 43, 2641.97432),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '资产负债表', '物业厂房及设备', 1, 91.38221),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '资产负债表', '无形资产', 2, 46.29676),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '资产负债表', '递延税项资产', 3, 22.78175),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '资产负债表', '长期投资', 4, 4.05371),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '资产负债表', '其他投资', 5, 79.32192),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '资产负债表', '指定以公允价值记账之金融资产', 6, 559.79974),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '资产负债表', '中长期存款', 7, 167.88346),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '资产负债表', '非流动资产其他项目', 8, 159.40461),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '资产负债表', '非流动资产合计', 9, 1130.92416),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '资产负债表', '存货', 10, 504.37891),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '资产负债表', '应收帐款', 11, 117.95074),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '资产负债表', '应收票据', 44, 0.40003),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '资产负债表', '预付款按金及其他应收款', 12, 185.78491),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '资产负债表', '受限制存款及现金', 14, 39.56786),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '资产负债表', '现金及等价物', 15, 276.07261),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '资产负债表', '短期存款', 16, 298.74707),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '资产负债表', '指定以公允价值记账之金融资产(流动)', 17, 102.95019),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '资产负债表', '贷款及垫款(流动)', 18, 78.29563),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '资产负债表', '流动资产合计', 19, 1604.14795),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '资产负债表', '总资产', 20, 2735.07211),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '资产负债表', '应付帐款', 21, 530.93543),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '资产负债表', '应付税项', 22, 13.84133),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '资产负债表', '其他应付款及应计费用', 23, 184.40716),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '资产负债表', '预收款项', 24, 95.87959),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '资产负债表', '短期贷款', 25, 21.50741),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '资产负债表', '拨备(流动)', 26, 49.70441),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '资产负债表', '流动负债合计', 27, 896.27533),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '资产负债表', '净流动资产', 28, 707.87262),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '资产负债表', '总资产减流动负债', 29, 1838.79678),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '资产负债表', '长期贷款', 30, 214.93261),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '资产负债表', '递延税项负债', 31, 9.83256),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '资产负债表', '拨备(非流动)', 32, 9.4527),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '资产负债表', '非流动负债其他项目', 45, 165.34831),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '资产负债表', '非流动负债合计', 34, 399.56618),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '资产负债表', '总负债', 35, 1295.84151),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '资产负债表', '少数股东权益', 36, 2.64602),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '资产负债表', '净资产', 37, 1439.2306),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '资产负债表', '股本', 38, 0.00406),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '资产负债表', '储备', 39, 1436.58052),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '资产负债表', '股东权益', 40, 1436.58458),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '资产负债表', '总权益', 41, 1439.2306),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '资产负债表', '总权益及非流动负债', 42, 1838.79678),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '资产负债表', '总权益及总负债', 43, 2735.07211),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '资产负债表', '物业厂房及设备', 1, 84.66094),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '资产负债表', '无形资产', 2, 49.39093),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '资产负债表', '递延税项资产', 3, 23.84142),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '资产负债表', '长期投资', 4, 4.24424),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '资产负债表', '其他投资', 5, 96.29519),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '资产负债表', '指定以公允价值记账之金融资产', 6, 524.6143),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '资产负债表', '中长期存款', 7, 183.86235),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '资产负债表', '非流动资产其他项目', 8, 161.39458),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '资产负债表', '非流动资产合计', 9, 1128.30395),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '资产负债表', '存货', 10, 529.97434),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '资产负债表', '应收帐款', 11, 145.31181),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '资产负债表', '应收票据', 44, 0.00728),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '资产负债表', '预付款按金及其他应收款', 12, 206.37036),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '资产负债表', '受限制存款及现金', 14, 39.5251),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '资产负债表', '现金及等价物', 15, 280.71099),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '资产负债表', '短期存款', 16, 260.22205),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '资产负债表', '指定以公允价值记账之金融资产(流动)', 17, 123.70147),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '资产负债表', '贷款及垫款(流动)', 18, 67.07425),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '资产负债表', '流动资产合计', 19, 1652.89765),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '资产负债表', '总资产', 20, 2781.2016),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '资产负债表', '应付帐款', 21, 589.46062),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '资产负债表', '应付税项', 22, 15.65677),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '资产负债表', '其他应付款及应计费用', 23, 181.77849),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '资产负债表', '预收款项', 24, 86.44747),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '资产负债表', '短期贷款', 25, 25.17215),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '资产负债表', '拨备(流动)', 26, 42.49379),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '资产负债表', '流动负债合计', 27, 941.00929),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '资产负债表', '净流动资产', 28, 711.88836),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '资产负债表', '总资产减流动负债', 29, 1840.19231),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '资产负债表', '长期贷款', 30, 232.44484),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '资产负债表', '递延税项负债', 31, 9.42241),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '资产负债表', '拨备(非流动)', 32, 8.20727),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '资产负债表', '非流动负债其他项目', 45, 172.17656),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '资产负债表', '非流动负债合计', 34, 422.25108),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '资产负债表', '总负债', 35, 1363.26037),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '资产负债表', '少数股东权益', 36, 2.76458),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '资产负债表', '净资产', 37, 1417.94123),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '资产负债表', '股本', 38, 0.00407),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '资产负债表', '储备', 39, 1415.17258),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '资产负债表', '股东权益', 40, 1415.17665),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '资产负债表', '总权益', 41, 1417.94123),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '资产负债表', '总权益及非流动负债', 42, 1840.19231),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '资产负债表', '总权益及总负债', 43, 2781.2016),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '资产负债表', '物业厂房及设备', 1, 76.74223),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '资产负债表', '无形资产', 2, 51.09034),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '资产负债表', '递延税项资产', 3, 21.99688),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '资产负债表', '长期投资', 4, 4.02352),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '资产负债表', '其他投资', 5, 100.20618),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '资产负债表', '指定以公允价值记账之金融资产', 6, 534.24695),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '资产负债表', '中长期存款', 7, 187.28439),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '资产负债表', '非流动资产其他项目', 8, 158.63872),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '资产负债表', '非流动资产合计', 9, 1134.22921),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '资产负债表', '存货', 10, 577.98719),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '资产负债表', '应收帐款', 11, 151.96628),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '资产负债表', '应收票据', 44, 1.02603),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '资产负债表', '预付款按金及其他应收款', 12, 217.30204),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '资产负债表', '受限制存款及现金', 14, 38.70437),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '资产负债表', '现金及等价物', 15, 281.83101),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '资产负债表', '短期存款', 16, 286.07263),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '资产负债表', '指定以公允价值记账之金融资产(流动)', 17, 181.07338),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '资产负债表', '贷款及垫款(流动)', 18, 60.63275),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '资产负债表', '流动资产合计', 19, 1796.59568),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '资产负债表', '总资产', 20, 2930.82489),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '资产负债表', '应付帐款', 21, 696.80442),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '资产负债表', '应付税项', 22, 13.90416),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '资产负债表', '其他应付款及应计费用', 23, 175.35129),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '资产负债表', '预收款项', 24, 78.23186),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '资产负债表', '短期贷款', 25, 70.94778),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '资产负债表', '拨备(流动)', 26, 38.08279),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '资产负债表', '流动负债合计', 27, 1073.3223),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '资产负债表', '净流动资产', 28, 723.27338),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '资产负债表', '总资产减流动负债', 29, 1857.50259),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '资产负债表', '长期贷款', 30, 254.74316),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '资产负债表', '递延税项负债', 31, 10.6933),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '资产负债表', '拨备(非流动)', 32, 11.00959),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '资产负债表', '其他非流动负债', 33, 172.89309),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '资产负债表', '非流动负债合计', 34, 449.33914),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '资产负债表', '总负债', 35, 1522.66144),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '资产负债表', '少数股东权益', 36, 2.6309),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '资产负债表', '净资产', 37, 1408.16345),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '资产负债表', '股本', 38, 0.00406),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '资产负债表', '储备', 39, 1405.52849),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '资产负债表', '股东权益', 40, 1405.53255),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '资产负债表', '总权益', 41, 1408.16345),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '资产负债表', '总权益及非流动负债', 42, 1857.50259),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '资产负债表', '总权益及总负债', 43, 2930.82489),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '资产负债表', '物业厂房及设备', 1, 72.23932),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '资产负债表', '无形资产', 2, 52.93058),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '资产负债表', '递延税项资产', 3, 19.15059),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '资产负债表', '长期投资', 4, 3.72008),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '资产负债表', '其他投资', 5, 100.2662),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '资产负债表', '指定以公允价值记账之金融资产', 6, 491.22848),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '资产负债表', '中长期存款', 7, 158.62841),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '资产负债表', '非流动资产其他项目', 8, 159.67939),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '资产负债表', '非流动资产合计', 9, 1057.84305),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '资产负债表', '存货', 10, 561.447),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '资产负债表', '应收帐款', 11, 172.39735),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '资产负债表', '应收票据', 44, 2.67201),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '资产负债表', '预付款按金及其他应收款', 12, 255.14715),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '资产负债表', '短期投资', 13, 6.35415),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '资产负债表', '受限制存款及现金', 14, 35.47123),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '资产负债表', '现金及等价物', 15, 347.14164),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '资产负债表', '短期存款', 16, 225.4379),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '资产负债表', '指定以公允价值记账之金融资产(流动)', 17, 183.45107),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '资产负债表', '贷款及垫款(流动)', 18, 52.4538),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '资产负债表', '流动资产合计', 19, 1841.9733),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '资产负债表', '总资产', 20, 2899.81635),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '资产负债表', '应付帐款', 21, 748.74543),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '资产负债表', '应付税项', 22, 20.93396),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '资产负债表', '其他应付款及应计费用', 23, 158.95565),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '资产负债表', '预收款项', 24, 84.73168),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '资产负债表', '短期贷款', 25, 92.21716),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '资产负债表', '拨备(流动)', 26, 34.71218),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '资产负债表', '流动负债合计', 27, 1140.29606),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '资产负债表', '净流动资产', 28, 701.67724),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '资产负债表', '总资产减流动负债', 29, 1759.52029),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '资产负债表', '总资产减总负债合计', 46, 1366.48737),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '资产负债表', '长期贷款', 30, 204.92213),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '资产负债表', '递延税项负债', 31, 8.08986),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '资产负债表', '拨备(非流动)', 32, 11.00512),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '资产负债表', '非流动负债其他项目', 45, 169.01581),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '资产负债表', '非流动负债合计', 34, 393.03292),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '资产负债表', '总负债', 35, 1533.32898),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '资产负债表', '少数股东权益', 36, 2.73479),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '资产负债表', '净资产', 37, 1366.48737),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '资产负债表', '股本', 38, 0.00407),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '资产负债表', '储备', 39, 1363.74851),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '资产负债表', '股东权益', 40, 1363.75258),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '资产负债表', '总权益', 41, 1366.48737),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '资产负债表', '总权益及非流动负债', 42, 1759.52029),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '资产负债表', '总权益及总负债', 43, 2899.81635),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '资产负债表', '物业厂房及设备', 1, 69.64621),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '资产负债表', '无形资产', 2, 55.79159),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '资产负债表', '递延税项资产', 3, 16.61947),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '资产负债表', '长期投资', 4, 3.51362),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '资产负债表', '其他投资', 5, 102.30751),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '资产负债表', '指定以公允价值记账之金融资产', 6, 501.13702),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '资产负债表', '中长期存款', 7, 161.95419),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '资产负债表', '非流动资产其他项目', 8, 159.43508),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '资产负债表', '非流动资产合计', 9, 1070.40469),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '资产负债表', '存货', 10, 523.97946),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '资产负债表', '应收帐款', 11, 179.85503),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '资产负债表', '应收票据', 44, 0.14033),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '资产负债表', '预付款按金及其他应收款', 12, 198.51884),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '资产负债表', '短期投资', 13, 15.97919),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '资产负债表', '受限制存款及现金', 14, 43.19661),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '资产负债表', '现金及等价物', 15, 235.11579),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '资产负债表', '短期存款', 16, 310.41129),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '资产负债表', '指定以公允价值记账之金融资产(流动)', 17, 300.22713),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '资产负债表', '贷款及垫款(流动)', 18, 51.09034),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '资产负债表', '流动资产合计', 19, 1858.51401),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '资产负债表', '总资产', 20, 2928.9187),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '资产负债表', '应付帐款', 21, 746.43005),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '资产负债表', '应付税项', 22, 23.35124),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '资产负债表', '其他应付款及应计费用', 23, 202.24499),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '资产负债表', '预收款项', 24, 92.89177),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '资产负债表', '短期贷款', 25, 55.2705),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '资产负债表', '拨备(流动)', 26, 37.08616),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '资产负债表', '流动负债合计', 27, 1157.27471),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '资产负债表', '净流动资产', 28, 701.2393),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '资产负债表', '总资产减流动负债', 29, 1771.64399),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '资产负债表', '长期贷款', 30, 207.1979),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '资产负债表', '递延税项负债', 31, 12.02717),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '资产负债表', '拨备(非流动)', 32, 8.95747),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '资产负债表', '非流动负债其他项目', 45, 169.13649),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '资产负债表', '非流动负债合计', 34, 397.31903),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '资产负债表', '总负债', 35, 1554.59374),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '资产负债表', '少数股东权益', 36, 2.1959),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '资产负债表', '净资产', 37, 1374.32496),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '资产负债表', '股本', 38, 0.00407),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '资产负债表', '储备', 39, 1372.12499),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '资产负债表', '股东权益', 40, 1372.12906),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '资产负债表', '总权益', 41, 1374.32496),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '资产负债表', '总权益及非流动负债', 42, 1771.64399),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '资产负债表', '总权益及总负债', 43, 2928.9187),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '资产负债表', '物业厂房及设备', 1, 71.35251),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '资产负债表', '无形资产', 2, 58.25484),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '资产负债表', '递延税项资产', 3, 11.48245),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '资产负债表', '长期投资', 4, 3.42203),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '资产负债表', '其他投资', 5, 131.73839),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '资产负债表', '指定以公允价值记账之金融资产', 6, 459.45602),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '资产负债表', '中长期存款', 7, 143.24895),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '资产负债表', '非流动资产其他项目', 8, 112.14387),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '资产负债表', '非流动资产合计', 9, 991.09906),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '资产负债表', '存货', 10, 581.81844),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '资产负债表', '应收帐款', 11, 141.07616),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '资产负债表', '应收票据', 44, 3.43876),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '资产负债表', '预付款按金及其他应收款', 12, 249.88516),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '资产负债表', '短期投资', 13, 25.98211),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '资产负债表', '受限制存款及现金', 14, 25.6374),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '资产负债表', '现金及等价物', 15, 326.49502),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '资产负债表', '短期存款', 16, 263.62188),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '资产负债表', '指定以公允价值记账之金融资产(流动)', 17, 202.73458),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '资产负债表', '贷款及垫款(流动)', 18, 71.81845),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '资产负债表', '流动资产合计', 19, 1892.50796),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '资产负债表', '总资产', 20, 2883.60702),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '资产负债表', '应付帐款', 21, 733.55847),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '资产负债表', '应付税项', 22, 16.07815),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '资产负债表', '其他应付款及应计费用', 23, 195.71957),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '资产负债表', '预收款项', 24, 116.05966),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '资产负债表', '短期贷款', 25, 48.91758),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '资产负债表', '拨备(流动)', 26, 34.91619),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '资产负债表', '流动负债合计', 27, 1145.24962),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '资产负债表', '净流动资产', 28, 747.25834),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '资产负债表', '总资产减流动负债', 29, 1738.3574),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '资产负债表', '总资产减总负债合计', 46, 1357.64044),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '资产负债表', '长期贷款', 30, 210.06592),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '资产负债表', '递延税项负债', 31, 5.82536),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '资产负债表', '拨备(非流动)', 32, 9.51442),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '资产负债表', '非流动负债其他项目', 45, 155.31126),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '资产负债表', '非流动负债合计', 34, 380.71696),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '资产负债表', '总负债', 35, 1525.96658),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '资产负债表', '少数股东权益', 36, 2.66485),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '资产负债表', '净资产', 37, 1357.64044),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '资产负债表', '股本', 38, 0.00408),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '资产负债表', '储备', 39, 1354.97151),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '资产负债表', '股东权益', 40, 1354.97559),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '资产负债表', '总权益', 41, 1357.64044),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '资产负债表', '总权益及非流动负债', 42, 1738.3574),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '资产负债表', '总权益及总负债', 43, 2883.60702),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '资产负债表', '物业厂房及设备', 1, 69.87166),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '资产负债表', '无形资产', 2, 36.89028),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '资产负债表', '递延税项资产', 3, 15.78712),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '资产负债表', '长期投资', 4, 3.60814),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '资产负债表', '其他投资', 5, 140.08708),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '资产负债表', '指定以公允价值记账之金融资产', 6, 438.77254),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '资产负债表', '中长期存款', 7, 165.36932),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '资产负债表', '非流动资产其他项目', 8, 90.55203),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '资产负债表', '非流动资产合计', 9, 960.93817),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '资产负债表', '存货', 10, 568.01934),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '资产负债表', '应收帐款', 11, 146.21462),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '资产负债表', '应收票据', 44, 1.4),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '资产负债表', '预付款按金及其他应收款', 12, 241.52596),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '资产负债表', '短期投资', 13, 20.40939),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '资产负债表', '受限制存款及现金', 14, 23.12707),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '资产负债表', '现金及等价物', 15, 318.8104),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '资产负债表', '短期存款', 16, 314.48974),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '资产负债表', '指定以公允价值记账之金融资产(流动)', 17, 282.54707),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '资产负债表', '贷款及垫款(流动)', 18, 86.75403),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '资产负债表', '流动资产合计', 19, 2003.29762),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '资产负债表', '总资产', 20, 2964.23579),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '资产负债表', '应付帐款', 21, 913.73987),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '资产负债表', '应付税项', 22, 13.81699),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '资产负债表', '其他应付款及应计费用', 23, 168.48688),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '资产负债表', '预收款项', 24, 119.13277),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '资产负债表', '短期贷款', 25, 60.51582),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '资产负债表', '拨备(流动)', 26, 34.01168),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '资产负债表', '流动负债合计', 27, 1309.70401),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '资产负债表', '净流动资产', 28, 693.59361),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '资产负债表', '总资产减流动负债', 29, 1654.53178),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '资产负债表', '长期贷款', 30, 132.62146),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '资产负债表', '递延税项负债', 31, 4.15968),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '资产负债表', '拨备(非流动)', 32, 9.71098),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '资产负债表', '非流动负债其他项目', 45, 147.67197),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '资产负债表', '非流动负债合计', 34, 294.16409),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '资产负债表', '总负债', 35, 1603.8681),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '资产负债表', '少数股东权益', 36, 2.69379),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '资产负债表', '净资产', 37, 1360.36769),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '资产负债表', '股本', 38, 0.00408),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '资产负债表', '储备', 39, 1357.66982),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '资产负债表', '股东权益', 40, 1357.6739),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '资产负债表', '总权益', 41, 1360.36769),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '资产负债表', '总权益及非流动负债', 42, 1654.53178),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '资产负债表', '总权益及总负债', 43, 2964.23579),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '资产负债表', '物业厂房及设备', 1, 66.52138),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '资产负债表', '无形资产', 2, 39.8159),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '资产负债表', '递延税项资产', 3, 17.17411),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '资产负债表', '长期投资', 4, 3.54066),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '资产负债表', '其他投资', 5, 131.73876),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '资产负债表', '指定以公允价值记账之金融资产', 6, 387.65178),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '资产负债表', '中长期存款', 7, 134.06709),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '资产负债表', '非流动资产其他项目', 8, 87.56654),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '资产负债表', '非流动资产合计', 9, 868.07622),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '资产负债表', '存货', 10, 495.37348),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '资产负债表', '应收帐款', 11, 126.38874),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '资产负债表', '应收票据', 44, 8.75972),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '资产负债表', '预付款按金及其他应收款', 12, 229.95233),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '资产负债表', '短期投资', 13, 13.14541),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '资产负债表', '受限制存款及现金', 14, 20.73854),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '资产负债表', '现金及等价物', 15, 342.79506),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '资产负债表', '短期存款', 16, 349.39507),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '资产负债表', '指定以公允价值记账之金融资产(流动)', 17, 239.75236),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '资产负债表', '贷款及垫款(流动)', 18, 76.36143),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '资产负债表', '流动资产合计', 19, 1902.66214),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '资产负债表', '总资产', 20, 2770.73836),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '资产负债表', '应付帐款', 21, 823.06095),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '资产负债表', '应付税项', 22, 8.26122),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '资产负债表', '其他应付款及应计费用', 23, 146.643),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '资产负债表', '预收款项', 24, 116.44068),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '资产负债表', '短期贷款', 25, 73.92181),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '资产负债表', '拨备(流动)', 26, 29.68164),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '资产负债表', '流动负债合计', 27, 1198.0093),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '资产负债表', '净流动资产', 28, 704.65284),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '资产负债表', '总资产减流动负债', 29, 1572.72906),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '资产负债表', '总资产减总负债合计', 46, 1322.55346),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '资产负债表', '长期贷款', 30, 136.12704),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '资产负债表', '递延税项负债', 31, 3.78966),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '资产负债表', '拨备(非流动)', 32, 8.44056),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '资产负债表', '非流动负债其他项目', 45, 101.81834),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '资产负债表', '非流动负债合计', 34, 250.1756),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '资产负债表', '总负债', 35, 1448.1849),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '资产负债表', '少数股东权益', 36, 3.18979),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '资产负债表', '净资产', 37, 1322.55346),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '资产负债表', '股本', 38, 0.0041),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '资产负债表', '储备', 39, 1319.35957),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '资产负债表', '股东权益', 40, 1319.36367),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '资产负债表', '总权益', 41, 1322.55346),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '资产负债表', '总权益及非流动负债', 42, 1572.72906),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '资产负债表', '总权益及总负债', 43, 2770.73836),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '资产负债表', '物业厂房及设备', 1, 63.05657),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '资产负债表', '无形资产', 2, 42.65619),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '资产负债表', '递延税项资产', 3, 20.11072),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '资产负债表', '长期投资', 4, 2.32798),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '资产负债表', '其他投资', 5, 127.81995),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '资产负债表', '指定以公允价值记账之金融资产', 6, 352.15319),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '资产负债表', '中长期存款', 7, 96.08677),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '资产负债表', '非流动资产其他项目', 8, 69.75851),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '资产负债表', '非流动资产合计', 9, 773.96988),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '资产负债表', '存货', 10, 416.70719),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '资产负债表', '应收帐款', 11, 101.61019),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '资产负债表', '应收票据', 44, 2.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '资产负债表', '预付款按金及其他应收款', 12, 161.8152),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '资产负债表', '受限制存款及现金', 14, 36.25257),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '资产负债表', '现金及等价物', 15, 547.52443),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '资产负债表', '短期存款', 16, 175.98946),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '资产负债表', '指定以公允价值记账之金融资产(流动)', 17, 231.73843),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '资产负债表', '贷款及垫款(流动)', 18, 89.19088),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '资产负债表', '流动资产合计', 19, 1762.82835),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '资产负债表', '总资产', 20, 2536.79823),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '资产负债表', '应付帐款', 21, 721.98856),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '资产负债表', '应付税项', 22, 6.74298),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '资产负债表', '其他应付款及应计费用', 23, 136.19655),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '资产负债表', '预收款项', 24, 119.99086),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '资产负债表', '短期贷款', 25, 69.61937),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '资产负债表', '拨备(流动)', 26, 24.73096),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '资产负债表', '流动负债合计', 27, 1079.26928),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '资产负债表', '净流动资产', 28, 683.55907),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '资产负债表', '总资产减流动负债', 29, 1457.52895),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '资产负债表', '长期贷款', 30, 106.34806),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '资产负债表', '递延税项负债', 31, 3.00556),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '资产负债表', '拨备(非流动)', 32, 8.0259),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '资产负债表', '非流动负债其他项目', 45, 100.01428),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '资产负债表', '非流动负债合计', 34, 217.3938),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '资产负债表', '总负债', 35, 1296.66308),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '资产负债表', '少数股东权益', 36, 3.21819),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '资产负债表', '净资产', 37, 1240.13515),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '资产负债表', '股本', 38, 0.00409),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '资产负债表', '储备', 39, 1236.91287),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '资产负债表', '股东权益', 40, 1236.91696),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '资产负债表', '总权益', 41, 1240.13515),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '资产负债表', '总权益及非流动负债', 42, 1457.52895),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '资产负债表', '总权益及总负债', 43, 2536.79823),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q3', '2020-09-30', '资产负债表', '物业厂房及设备', 1, 69.90443),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q3', '2020-09-30', '资产负债表', '无形资产', 2, 13.55619),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q3', '2020-09-30', '资产负债表', '递延税项资产', 3, 17.14694),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q3', '2020-09-30', '资产负债表', '其他投资', 5, 124.15403),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q3', '2020-09-30', '资产负债表', '指定以公允价值记账之金融资产', 6, 270.39639),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q3', '2020-09-30', '资产负债表', '中长期存款', 7, 63.95493),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q3', '2020-09-30', '资产负债表', '非流动资产其他项目', 8, 57.67076),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q3', '2020-09-30', '资产负债表', '非流动资产合计', 9, 616.78367),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q3', '2020-09-30', '资产负债表', '存货', 10, 349.96234),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q3', '2020-09-30', '资产负债表', '应收帐款', 11, 134.82432),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q3', '2020-09-30', '资产负债表', '预付款按金及其他应收款', 12, 203.36208),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q3', '2020-09-30', '资产负债表', '短期投资', 13, 3.41527),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q3', '2020-09-30', '资产负债表', '受限制存款及现金', 14, 32.57432),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q3', '2020-09-30', '资产负债表', '现金及等价物', 15, 302.57712),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q3', '2020-09-30', '资产负债表', '短期存款', 16, 141.56263),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q3', '2020-09-30', '资产负债表', '指定以公允价值记账之金融资产(流动)', 17, 219.59881),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q3', '2020-09-30', '资产负债表', '贷款及垫款(流动)', 18, 111.39407),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q3', '2020-09-30', '资产负债表', '流动资产合计', 19, 1499.27096),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q3', '2020-09-30', '资产负债表', '总资产', 20, 2116.05463),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q3', '2020-09-30', '资产负债表', '应付帐款', 21, 632.56578),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q3', '2020-09-30', '资产负债表', '应付税项', 22, 8.35543),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q3', '2020-09-30', '资产负债表', '其他应付款及应计费用', 23, 112.53648),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q3', '2020-09-30', '资产负债表', '预收款项', 24, 100.85567),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q3', '2020-09-30', '资产负债表', '短期贷款', 25, 113.8521),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q3', '2020-09-30', '资产负债表', '拨备(流动)', 26, 27.19266),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q3', '2020-09-30', '资产负债表', '流动负债合计', 27, 995.35812),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q3', '2020-09-30', '资产负债表', '净流动资产', 28, 503.91284),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q3', '2020-09-30', '资产负债表', '总资产减流动负债', 29, 1120.69651),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q3', '2020-09-30', '资产负债表', '总资产减总负债合计', 46, 945.68378),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q3', '2020-09-30', '资产负债表', '长期贷款', 30, 71.83648),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q3', '2020-09-30', '资产负债表', '递延税项负债', 31, 4.19568),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q3', '2020-09-30', '资产负债表', '拨备(非流动)', 32, 7.50523),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q3', '2020-09-30', '资产负债表', '非流动负债其他项目', 45, 91.47534),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q3', '2020-09-30', '资产负债表', '非流动负债合计', 34, 175.01273),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q3', '2020-09-30', '资产负债表', '总负债', 35, 1170.37085),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q3', '2020-09-30', '资产负债表', '少数股东权益', 36, 3.3984),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q3', '2020-09-30', '资产负债表', '净资产', 37, 945.68378),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q3', '2020-09-30', '资产负债表', '股本', 38, 0.00392),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q3', '2020-09-30', '资产负债表', '储备', 39, 942.28146),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q3', '2020-09-30', '资产负债表', '股东权益', 40, 942.28538),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q3', '2020-09-30', '资产负债表', '总权益', 41, 945.68378),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q3', '2020-09-30', '资产负债表', '总权益及非流动负债', 42, 1120.69651),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q3', '2020-09-30', '资产负债表', '总权益及总负债', 43, 2116.05463),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '资产负债表', '物业厂房及设备', 1, 80.01825),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '资产负债表', '无形资产', 2, 14.56254),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '资产负债表', '递延税项资产', 3, 15.09833),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '资产负债表', '其他投资', 5, 120.82879),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '资产负债表', '指定以公允价值记账之金融资产', 6, 247.12785),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '资产负债表', '中长期存款', 7, 29.198),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '资产负债表', '非流动资产其他项目', 8, 56.87964),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '资产负债表', '非流动资产合计', 9, 563.7134),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '资产负债表', '存货', 10, 388.56939),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '资产负债表', '应收帐款', 11, 84.72074),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '资产负债表', '预付款按金及其他应收款', 12, 199.35731),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '资产负债表', '受限制存款及现金', 14, 14.43917),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '资产负债表', '现金及等价物', 15, 228.43316),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '资产负债表', '短期存款', 16, 199.99006),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '资产负债表', '指定以公允价值记账之金融资产(流动)', 17, 175.01122),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '资产负债表', '贷款及垫款(流动)', 18, 130.89932),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '资产负债表', '流动资产合计', 19, 1421.42037),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '资产负债表', '总资产', 20, 1985.13377),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '资产负债表', '应付帐款', 21, 604.33835),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '资产负债表', '应付税项', 22, 4.96025),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '资产负债表', '其他应付款及应计费用', 23, 87.17155),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '资产负债表', '预收款项', 24, 72.48622),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '资产负债表', '短期贷款', 25, 134.08668),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '资产负债表', '拨备(流动)', 26, 23.82982),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '资产负债表', '流动负债合计', 27, 926.87287),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '资产负债表', '净流动资产', 28, 494.5475),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '资产负债表', '总资产减流动负债', 29, 1058.2609),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '资产负债表', '长期贷款', 30, 99.95908),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '资产负债表', '递延税项负债', 31, 4.1531),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '资产负债表', '拨备(非流动)', 32, 7.28262),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '资产负债表', '非流动负债其他项目', 45, 45.24238),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '资产负债表', '非流动负债合计', 34, 156.63718),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '资产负债表', '总负债', 35, 1083.51005),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '资产负债表', '少数股东权益', 36, 3.55786),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '资产负债表', '净资产', 37, 901.62372),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '资产负债表', '股本', 38, 0.00391),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '资产负债表', '储备', 39, 898.06195),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '资产负债表', '股东权益', 40, 898.06586),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '资产负债表', '总权益', 41, 901.62372),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '资产负债表', '总权益及非流动负债', 42, 1058.2609),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '资产负债表', '总权益及总负债', 43, 1985.13377),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q1', '2020-03-31', '资产负债表', '物业厂房及设备', 1, 72.37359),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q1', '2020-03-31', '资产负债表', '无形资产', 2, 15.75532),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q1', '2020-03-31', '资产负债表', '递延税项资产', 3, 14.74459),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q1', '2020-03-31', '资产负债表', '其他投资', 5, 94.61302),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q1', '2020-03-31', '资产负债表', '指定以公允价值记账之金融资产', 6, 228.35985),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q1', '2020-03-31', '资产负债表', '中长期存款', 7, 23.80221),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q1', '2020-03-31', '资产负债表', '非流动资产其他项目', 8, 57.60594),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q1', '2020-03-31', '资产负债表', '非流动资产合计', 9, 507.25452),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q1', '2020-03-31', '资产负债表', '存货', 10, 341.11461),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q1', '2020-03-31', '资产负债表', '应收帐款', 11, 78.1938),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q1', '2020-03-31', '资产负债表', '预付款按金及其他应收款', 12, 190.51834),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q1', '2020-03-31', '资产负债表', '受限制存款及现金', 14, 13.72798),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q1', '2020-03-31', '资产负债表', '现金及等价物', 15, 250.73687),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q1', '2020-03-31', '资产负债表', '短期存款', 16, 131.29091),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q1', '2020-03-31', '资产负债表', '指定以公允价值记账之金融资产(流动)', 17, 130.0424),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q1', '2020-03-31', '资产负债表', '贷款及垫款(流动)', 18, 114.85919),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q1', '2020-03-31', '资产负债表', '流动资产合计', 19, 1250.4841),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q1', '2020-03-31', '资产负债表', '总资产', 20, 1757.73862),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q1', '2020-03-31', '资产负债表', '应付帐款', 21, 539.1021),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q1', '2020-03-31', '资产负债表', '应付税项', 22, 4.96149),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q1', '2020-03-31', '资产负债表', '其他应付款及应计费用', 23, 74.5436),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q1', '2020-03-31', '资产负债表', '预收款项', 24, 53.20609),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q1', '2020-03-31', '资产负债表', '短期贷款', 25, 111.29841),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q1', '2020-03-31', '资产负债表', '拨备(流动)', 26, 21.80918),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q1', '2020-03-31', '资产负债表', '流动负债合计', 27, 804.92087),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q1', '2020-03-31', '资产负债表', '净流动资产', 28, 445.56323),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q1', '2020-03-31', '资产负债表', '总资产减流动负债', 29, 952.81775),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q1', '2020-03-31', '资产负债表', '总资产减总负债合计', 46, 849.08641),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q1', '2020-03-31', '资产负债表', '长期贷款', 30, 53.51211),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q1', '2020-03-31', '资产负债表', '递延税项负债', 31, 5.32735),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q1', '2020-03-31', '资产负债表', '拨备(非流动)', 32, 6.86294),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q1', '2020-03-31', '资产负债表', '非流动负债其他项目', 45, 38.02894),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q1', '2020-03-31', '资产负债表', '非流动负债合计', 34, 103.73134),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q1', '2020-03-31', '资产负债表', '总负债', 35, 908.65221),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q1', '2020-03-31', '资产负债表', '少数股东权益', 36, 3.29096),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q1', '2020-03-31', '资产负债表', '净资产', 37, 849.08641),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q1', '2020-03-31', '资产负债表', '股本', 38, 0.00389),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q1', '2020-03-31', '资产负债表', '储备', 39, 845.79156),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q1', '2020-03-31', '资产负债表', '股东权益', 40, 845.79545),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q1', '2020-03-31', '资产负债表', '总权益', 41, 849.08641),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q1', '2020-03-31', '资产负债表', '总权益及非流动负债', 42, 952.81775),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q1', '2020-03-31', '资产负债表', '总权益及总负债', 43, 1757.73862),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '资产负债表', '物业厂房及设备', 1, 69.92331),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '资产负债表', '无形资产', 2, 16.72002),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '资产负债表', '递延税项资产', 3, 12.83415),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '资产负债表', '其他投资', 5, 93.00507),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '资产负债表', '指定以公允价值记账之金融资产', 6, 206.79363),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '资产负债表', '中长期存款', 7, 5.90157),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '资产负债表', '非流动资产其他项目', 8, 55.72346),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '资产负债表', '非流动资产合计', 9, 460.90121),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '资产负债表', '存货', 10, 325.85438),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '资产负债表', '应收帐款', 11, 69.48567),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '资产负债表', '预付款按金及其他应收款', 12, 198.37018),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '资产负债表', '受限制存款及现金', 14, 15.38266),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '资产负债表', '现金及等价物', 15, 259.19861),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '资产负债表', '短期存款', 16, 215.23043),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '资产负债表', '指定以公允价值记账之金融资产(流动)', 17, 164.6339),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '资产负债表', '贷款及垫款(流动)', 18, 127.23503),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '资产负债表', '流动资产合计', 19, 1375.39086),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '资产负债表', '总资产', 20, 1836.29207),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '资产负债表', '应付帐款', 21, 595.2794),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '资产负债表', '应付税项', 22, 4.7935),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '资产负债表', '其他应付款及应计费用', 23, 91.01343),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '资产负债表', '预收款项', 24, 82.37119),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '资产负债表', '短期贷款', 25, 128.36555),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '资产负债表', '拨备(流动)', 26, 19.98398),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '资产负债表', '流动负债合计', 27, 921.80705),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '资产负债表', '净流动资产', 28, 453.58381),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '资产负债表', '总资产减流动负债', 29, 914.48502),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '资产负债表', '长期贷款', 30, 47.86856),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '资产负债表', '递延税项负债', 31, 5.79902),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '资产负债表', '拨备(非流动)', 32, 6.67857),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '资产负债表', '非流动负债其他项目', 45, 37.56211),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '资产负债表', '非流动负债合计', 34, 97.90826),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '资产负债表', '总负债', 35, 1019.71531),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '资产负债表', '少数股东权益', 36, 3.27102),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '资产负债表', '净资产', 37, 816.57676),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '资产负债表', '股本', 38, 0.00388),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '资产负债表', '储备', 39, 813.30186),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '资产负债表', '股东权益', 40, 813.30574),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '资产负债表', '总权益', 41, 816.57676),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '资产负债表', '总权益及非流动负债', 42, 914.48502),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '资产负债表', '总权益及总负债', 43, 1836.29207),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q3', '2019-09-30', '资产负债表', '物业厂房及设备', 1, 71.57506),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q3', '2019-09-30', '资产负债表', '无形资产', 2, 16.96073),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q3', '2019-09-30', '资产负债表', '递延税项资产', 3, 12.16489),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q3', '2019-09-30', '资产负债表', '其他投资', 5, 95.03927),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q3', '2019-09-30', '资产负债表', '指定以公允价值记账之金融资产', 6, 191.98085),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q3', '2019-09-30', '资产负债表', '非流动资产其他项目', 8, 49.55034),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q3', '2019-09-30', '资产负债表', '非流动资产合计', 9, 437.27114),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q3', '2019-09-30', '资产负债表', '存货', 10, 262.41171),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q3', '2019-09-30', '资产负债表', '应收帐款', 11, 97.9552),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q3', '2019-09-30', '资产负债表', '预付款按金及其他应收款', 12, 200.8965),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q3', '2019-09-30', '资产负债表', '受限制存款及现金', 14, 15.26943),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q3', '2019-09-30', '资产负债表', '现金及等价物', 15, 355.39164),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q3', '2019-09-30', '资产负债表', '短期存款', 16, 43.14497),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q3', '2019-09-30', '资产负债表', '指定以公允价值记账之金融资产(流动)', 17, 147.02051),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q3', '2019-09-30', '资产负债表', '贷款及垫款(流动)', 18, 122.56169),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q3', '2019-09-30', '资产负债表', '流动资产合计', 19, 1244.65165),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q3', '2019-09-30', '资产负债表', '总资产', 20, 1681.92279),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q3', '2019-09-30', '资产负债表', '应付帐款', 21, 495.49418),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q3', '2019-09-30', '资产负债表', '应付税项', 22, 7.57811),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q3', '2019-09-30', '资产负债表', '其他应付款及应计费用', 23, 90.31595),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q3', '2019-09-30', '资产负债表', '预收款项', 24, 65.08952),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q3', '2019-09-30', '资产负债表', '短期贷款', 25, 102.02977),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q3', '2019-09-30', '资产负债表', '拨备(流动)', 26, 17.21598),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q3', '2019-09-30', '资产负债表', '流动负债合计', 27, 777.72351),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q3', '2019-09-30', '资产负债表', '净流动资产', 28, 466.92814),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q3', '2019-09-30', '资产负债表', '总资产减流动负债', 29, 904.19928),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q3', '2019-09-30', '资产负债表', '总资产减总负债合计', 46, 801.015),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q3', '2019-09-30', '资产负债表', '长期贷款', 30, 53.32565),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q3', '2019-09-30', '资产负债表', '递延税项负债', 31, 5.15307),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q3', '2019-09-30', '资产负债表', '拨备(非流动)', 32, 8.97138),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q3', '2019-09-30', '资产负债表', '非流动负债其他项目', 45, 35.73418),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q3', '2019-09-30', '资产负债表', '非流动负债合计', 34, 103.18428),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q3', '2019-09-30', '资产负债表', '总负债', 35, 880.90779),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q3', '2019-09-30', '资产负债表', '少数股东权益', 36, 1.59483),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q3', '2019-09-30', '资产负债表', '净资产', 37, 801.015),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q3', '2019-09-30', '资产负债表', '股本', 38, 0.00385),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q3', '2019-09-30', '资产负债表', '储备', 39, 799.41632),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q3', '2019-09-30', '资产负债表', '股东权益', 40, 799.42017),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q3', '2019-09-30', '资产负债表', '总权益', 41, 801.015),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q3', '2019-09-30', '资产负债表', '总权益及非流动负债', 42, 904.19928),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q3', '2019-09-30', '资产负债表', '总权益及总负债', 43, 1681.92279),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '资产负债表', '物业厂房及设备', 1, 58.91124),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '资产负债表', '无形资产', 2, 18.03026),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '资产负债表', '递延税项资产', 3, 15.60637),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '资产负债表', '其他投资', 5, 94.54872),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '资产负债表', '指定以公允价值记账之金融资产', 6, 191.95544),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '资产负债表', '非流动资产其他项目', 8, 46.99364),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '资产负债表', '非流动资产合计', 9, 426.04567),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '资产负债表', '存货', 10, 266.75009),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '资产负债表', '应收帐款', 11, 73.37191),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '资产负债表', '预付款按金及其他应收款', 12, 187.7855),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '资产负债表', '受限制存款及现金', 14, 6.49707),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '资产负债表', '现金及等价物', 15, 349.21028),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '资产负债表', '短期存款', 16, 24.33226),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '资产负债表', '指定以公允价值记账之金融资产(流动)', 17, 131.22294),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '资产负债表', '贷款及垫款(流动)', 18, 117.33101),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '资产负债表', '流动资产合计', 19, 1156.50106),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '资产负债表', '总资产', 20, 1582.54673),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '资产负债表', '应付帐款', 21, 487.99255),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '资产负债表', '应付税项', 22, 6.15083),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '资产负债表', '其他应付款及应计费用', 23, 70.06271),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '资产负债表', '预收款项', 24, 46.68089),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '资产负债表', '短期贷款', 25, 66.79136),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '资产负债表', '拨备(流动)', 26, 14.39122),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '资产负债表', '流动负债合计', 27, 692.06956),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '资产负债表', '净流动资产', 28, 464.4315),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '资产负债表', '总资产减流动负债', 29, 890.47717),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '资产负债表', '长期贷款', 30, 70.99923),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '资产负债表', '递延税项负债', 31, 7.58583),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '资产负债表', '拨备(非流动)', 32, 7.53026),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '资产负债表', '非流动负债其他项目', 45, 35.89735),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '资产负债表', '非流动负债合计', 34, 122.01267),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '资产负债表', '总负债', 35, 814.08223),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '资产负债表', '少数股东权益', 36, 1.54556),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '资产负债表', '净资产', 37, 768.4645),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '资产负债表', '股本', 38, 0.00384),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '资产负债表', '储备', 39, 766.9151),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '资产负债表', '股东权益', 40, 766.91894),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '资产负债表', '总权益', 41, 768.4645),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '资产负债表', '总权益及非流动负债', 42, 890.47717),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '资产负债表', '总权益及总负债', 43, 1582.54673),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q1', '2019-03-31', '资产负债表', '物业厂房及设备', 1, 54.41114),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q1', '2019-03-31', '资产负债表', '无形资产', 2, 19.57597),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q1', '2019-03-31', '资产负债表', '土地使用权', 47, 33.83144),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q1', '2019-03-31', '资产负债表', '递延税项资产', 3, 15.28806),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q1', '2019-03-31', '资产负债表', '其他投资', 5, 84.28095),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q1', '2019-03-31', '资产负债表', '指定以公允价值记账之金融资产', 6, 205.88047),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q1', '2019-03-31', '资产负债表', '非流动资产其他项目', 8, 13.7028),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q1', '2019-03-31', '资产负债表', '非流动资产合计', 9, 426.97083),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q1', '2019-03-31', '资产负债表', '存货', 10, 259.82064),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q1', '2019-03-31', '资产负债表', '应收帐款', 11, 66.93522),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q1', '2019-03-31', '资产负债表', '预付款按金及其他应收款', 12, 159.58229),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q1', '2019-03-31', '资产负债表', '受限制存款及现金', 14, 12.84066),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q1', '2019-03-31', '资产负债表', '现金及等价物', 15, 264.73131),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q1', '2019-03-31', '资产负债表', '短期存款', 16, 11.25372),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q1', '2019-03-31', '资产负债表', '指定以公允价值记账之金融资产(流动)', 17, 87.49298),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q1', '2019-03-31', '资产负债表', '贷款及垫款(流动)', 18, 92.03829),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q1', '2019-03-31', '资产负债表', '流动资产合计', 19, 954.69511),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q1', '2019-03-31', '资产负债表', '总资产', 20, 1381.66594),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q1', '2019-03-31', '资产负债表', '应付帐款', 21, 360.53557),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q1', '2019-03-31', '资产负债表', '应付税项', 22, 8.28815),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q1', '2019-03-31', '资产负债表', '其他应付款及应计费用', 23, 60.47027),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q1', '2019-03-31', '资产负债表', '预收款项', 24, 39.52282),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q1', '2019-03-31', '资产负债表', '短期贷款', 25, 21.41149),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q1', '2019-03-31', '资产负债表', '拨备(流动)', 26, 12.25914),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q1', '2019-03-31', '资产负债表', '流动负债合计', 27, 502.48744),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q1', '2019-03-31', '资产负债表', '净流动资产', 28, 452.20767),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q1', '2019-03-31', '资产负债表', '总资产减流动负债', 29, 879.1785),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q1', '2019-03-31', '资产负债表', '总资产减总负债合计', 46, 744.7383),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q1', '2019-03-31', '资产负债表', '长期贷款', 30, 84.17235),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q1', '2019-03-31', '资产负债表', '递延税项负债', 31, 8.68305),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q1', '2019-03-31', '资产负债表', '拨备(非流动)', 32, 6.0518),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q1', '2019-03-31', '资产负债表', '非流动负债其他项目', 45, 35.533),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q1', '2019-03-31', '资产负债表', '非流动负债合计', 34, 134.4402),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q1', '2019-03-31', '资产负债表', '总负债', 35, 636.92764),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q1', '2019-03-31', '资产负债表', '少数股东权益', 36, 0.3855),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q1', '2019-03-31', '资产负债表', '净资产', 37, 744.7383),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q1', '2019-03-31', '资产负债表', '股本', 38, 0.00383),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q1', '2019-03-31', '资产负债表', '储备', 39, 744.34897),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q1', '2019-03-31', '资产负债表', '股东权益', 40, 744.3528),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q1', '2019-03-31', '资产负债表', '总权益', 41, 744.7383),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q1', '2019-03-31', '资产负债表', '总权益及非流动负债', 42, 879.1785),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q1', '2019-03-31', '资产负债表', '总权益及总负债', 43, 1381.66594),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '资产负债表', '物业厂房及设备', 1, 50.68053),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '资产负债表', '无形资产', 2, 20.61192),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '资产负债表', '土地使用权', 47, 34.02968),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '资产负债表', '递延税项资产', 3, 13.12245),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '资产负债表', '其他投资', 5, 86.39238),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '资产负债表', '指定以公允价值记账之金融资产', 6, 186.36208),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '资产负债表', '非流动资产其他项目', 8, 0.95485),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '资产负债表', '非流动资产合计', 9, 392.15389),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '资产负债表', '存货', 10, 294.80685),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '资产负债表', '应收帐款', 11, 55.98443),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '资产负债表', '预付款按金及其他应收款', 12, 209.14946),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '资产负债表', '受限制存款及现金', 14, 14.80178),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '资产负债表', '现金及等价物', 15, 302.30147),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '资产负债表', '短期存款', 16, 13.65991),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '资产负债表', '指定以公允价值记账之金融资产(流动)', 17, 66.48526),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '资产负债表', '贷款及垫款(流动)', 18, 102.93645),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '资产负债表', '流动资产合计', 19, 1060.12561),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '资产负债表', '总资产', 20, 1452.2795),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '资产负债表', '应付帐款', 21, 462.87271),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '资产负债表', '应付税项', 22, 6.61816),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '资产负债表', '其他应付款及应计费用', 23, 63.1277),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '资产负债表', '预收款项', 24, 44.79522),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '资产负债表', '短期贷款', 25, 30.75194),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '资产负债表', '拨备(流动)', 26, 11.23585),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '资产负债表', '流动负债合计', 27, 619.40158),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '资产负债表', '净流动资产', 28, 440.72403),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '资产负债表', '总资产减流动负债', 29, 832.87792),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '资产负债表', '长期贷款', 30, 78.56143),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '资产负债表', '递延税项负债', 31, 7.77645),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '资产负债表', '拨备(非流动)', 32, 5.59016),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '资产负债表', '非流动负债其他项目', 45, 28.44859),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '资产负债表', '非流动负债合计', 34, 120.37663),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '资产负债表', '总负债', 35, 739.77821),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '资产负债表', '少数股东权益', 36, -0.72856),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '资产负债表', '净资产', 37, 712.50129),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '资产负债表', '股本', 38, 0.00377),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '资产负债表', '储备', 39, 713.22608),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '资产负债表', '股东权益', 40, 713.22985),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '资产负债表', '总权益', 41, 712.50129),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '资产负债表', '总权益及非流动负债', 42, 832.87792),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '资产负债表', '总权益及总负债', 43, 1452.2795),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q3', '2018-09-30', '资产负债表', '物业厂房及设备', 1, 26.1269),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q3', '2018-09-30', '资产负债表', '无形资产', 2, 20.92122),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q3', '2018-09-30', '资产负债表', '土地使用权', 47, 33.58096),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q3', '2018-09-30', '资产负债表', '递延税项资产', 3, 13.8483),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q3', '2018-09-30', '资产负债表', '其他投资', 5, 80.93629),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q3', '2018-09-30', '资产负债表', '指定以公允价值记账之金融资产', 6, 164.87178),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q3', '2018-09-30', '资产负债表', '非流动资产其他项目', 8, 2.21364),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q3', '2018-09-30', '资产负债表', '非流动资产合计', 9, 342.49909),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q3', '2018-09-30', '资产负债表', '存货', 10, 265.38036),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q3', '2018-09-30', '资产负债表', '应收帐款', 11, 84.95973),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q3', '2018-09-30', '资产负债表', '预付款按金及其他应收款', 12, 205.79297),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q3', '2018-09-30', '资产负债表', '受限制存款及现金', 14, 23.21849),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q3', '2018-09-30', '资产负债表', '现金及等价物', 15, 352.08793),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q3', '2018-09-30', '资产负债表', '短期存款', 16, 6.991),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q3', '2018-09-30', '资产负债表', '指定以公允价值记账之金融资产(流动)', 17, 88.97231),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q3', '2018-09-30', '资产负债表', '贷款及垫款(流动)', 18, 104.00945),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q3', '2018-09-30', '资产负债表', '流动资产合计', 19, 1131.41224),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q3', '2018-09-30', '资产负债表', '总资产', 20, 1473.91133),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q3', '2018-09-30', '资产负债表', '应付帐款', 21, 526.47873),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q3', '2018-09-30', '资产负债表', '应付税项', 22, 7.61302),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q3', '2018-09-30', '资产负债表', '其他应付款及应计费用', 23, 51.00939),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q3', '2018-09-30', '资产负债表', '预收款项', 24, 51.02674),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q3', '2018-09-30', '资产负债表', '短期贷款', 25, 41.55734),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q3', '2018-09-30', '资产负债表', '拨备(流动)', 26, 28.9213),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q3', '2018-09-30', '资产负债表', '流动负债合计', 27, 706.60652),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q3', '2018-09-30', '资产负债表', '净流动资产', 28, 424.80572),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q3', '2018-09-30', '资产负债表', '总资产减流动负债', 29, 767.30481),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q3', '2018-09-30', '资产负债表', '总资产减总负债合计', 46, 671.63179),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q3', '2018-09-30', '资产负债表', '长期贷款', 30, 57.08849),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q3', '2018-09-30', '资产负债表', '递延税项负债', 31, 8.13444),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q3', '2018-09-30', '资产负债表', '拨备(非流动)', 32, 3.83021),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q3', '2018-09-30', '资产负债表', '非流动负债其他项目', 45, 26.61988),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q3', '2018-09-30', '资产负债表', '非流动负债合计', 34, 95.67302),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q3', '2018-09-30', '资产负债表', '总负债', 35, 802.27954),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q3', '2018-09-30', '资产负债表', '少数股东权益', 36, -0.55416),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q3', '2018-09-30', '资产负债表', '净资产', 37, 671.63179),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q3', '2018-09-30', '资产负债表', '股本', 38, 0.00362),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q3', '2018-09-30', '资产负债表', '储备', 39, 672.18233),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q3', '2018-09-30', '资产负债表', '股东权益', 40, 672.18595),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q3', '2018-09-30', '资产负债表', '总权益', 41, 671.63179),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q3', '2018-09-30', '资产负债表', '总权益及非流动负债', 42, 767.30481),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q3', '2018-09-30', '资产负债表', '总权益及总负债', 43, 1473.91133),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '资产负债表', '物业厂房及设备', 1, 23.94155),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '资产负债表', '无形资产', 2, 21.76439),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '资产负债表', '土地使用权', 47, 33.77517),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '资产负债表', '递延税项资产', 3, 9.46928),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '资产负债表', '其他投资', 5, 74.95225),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '资产负债表', '指定以公允价值记账之金融资产', 6, 162.2934),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '资产负债表', '非流动资产其他项目', 8, 1.32189),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '资产负债表', '非流动资产合计', 9, 327.51793),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '资产负债表', '存货', 10, 217.40309),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '资产负债表', '应收帐款', 11, 71.12042),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '资产负债表', '预付款按金及其他应收款', 12, 152.89506),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '资产负债表', '受限制存款及现金', 14, 45.87069),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '资产负债表', '现金及等价物', 15, 148.9415),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '资产负债表', '短期存款', 16, 0.01198),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '资产负债表', '指定以公允价值记账之金融资产(流动)', 17, 79.00902),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '资产负债表', '贷款及垫款(流动)', 18, 87.95925),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '资产负债表', '流动资产合计', 19, 803.21101),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '资产负债表', '总资产', 20, 1130.72894),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '资产负债表', '应付帐款', 21, 449.66287),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '资产负债表', '应付税项', 22, 4.81345),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '资产负债表', '其他应付款及应计费用', 23, 46.24944),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '资产负债表', '预收款项', 24, 37.71828),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '资产负债表', '短期贷款', 25, 79.50151),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '资产负债表', '拨备(流动)', 26, 25.01681),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '资产负债表', '流动负债合计', 27, 642.96236),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '资产负债表', '净流动资产', 28, 160.24865),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '资产负债表', '总资产减流动负债', 29, 487.76658),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '资产负债表', '长期贷款', 30, 46.01862),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '资产负债表', '递延税项负债', 31, 10.43484),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '资产负债表', '拨备(非流动)', 32, 2.39272),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '资产负债表', '可转换可赎回优先股', 48, 1505.63894),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '资产负债表', '非流动负债其他项目', 45, 26.65697),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '资产负债表', '非流动负债合计', 34, 1591.14209),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '资产负债表', '总负债', 35, 2234.10445),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '资产负债表', '少数股东权益', 36, 0.9394),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '资产负债表', '净资产', 37, -1103.37551),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '资产负债表', '股本', 38, 0.00161),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '资产负债表', '储备', 39, -1104.31652),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '资产负债表', '股东权益', 40, -1104.31491),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '资产负债表', '总权益', 41, -1103.37551),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '资产负债表', '总权益及非流动负债', 42, 487.76658),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '资产负债表', '总权益及总负债', 43, 1130.72894),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q1', '2018-03-31', '资产负债表', '物业厂房及设备', 1, 20.99305),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q1', '2018-03-31', '资产负债表', '无形资产', 2, 22.46404),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q1', '2018-03-31', '资产负债表', '土地使用权', 47, 33.96938),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q1', '2018-03-31', '资产负债表', '递延税项资产', 3, 6.06534),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q1', '2018-03-31', '资产负债表', '其他投资', 5, 26.68702),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q1', '2018-03-31', '资产负债表', '指定以公允价值记账之金融资产', 6, 199.19203),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q1', '2018-03-31', '资产负债表', '非流动资产其他项目', 8, 1.27818),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q1', '2018-03-31', '资产负债表', '非流动资产合计', 9, 310.64904),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q1', '2018-03-31', '资产负债表', '存货', 10, 151.36731),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q1', '2018-03-31', '资产负债表', '应收帐款', 11, 60.45241),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q1', '2018-03-31', '资产负债表', '预付款按金及其他应收款', 12, 120.90162),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q1', '2018-03-31', '资产负债表', '短期投资', 13, 10.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q1', '2018-03-31', '资产负债表', '受限制存款及现金', 14, 16.78153),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q1', '2018-03-31', '资产负债表', '现金及等价物', 15, 140.27013),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q1', '2018-03-31', '资产负债表', '短期存款', 16, 2.21398),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q1', '2018-03-31', '资产负债表', '指定以公允价值记账之金融资产(流动)', 17, 26.44754),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q1', '2018-03-31', '资产负债表', '贷款及垫款(流动)', 18, 81.85244),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q1', '2018-03-31', '资产负债表', '流动资产合计', 19, 610.28696),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q1', '2018-03-31', '资产负债表', '总资产', 20, 920.936),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q1', '2018-03-31', '资产负债表', '应付帐款', 21, 294.91076),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q1', '2018-03-31', '资产负债表', '应付税项', 22, 5.25967),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q1', '2018-03-31', '资产负债表', '其他应付款及应计费用', 23, 32.01447),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q1', '2018-03-31', '资产负债表', '预收款项', 24, 43.82266),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q1', '2018-03-31', '资产负债表', '短期贷款', 25, 58.06972),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q1', '2018-03-31', '资产负债表', '拨备(流动)', 26, 18.81911),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q1', '2018-03-31', '资产负债表', '流动负债合计', 27, 452.89639),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q1', '2018-03-31', '资产负债表', '净流动资产', 28, 157.39057),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q1', '2018-03-31', '资产负债表', '总资产减流动负债', 29, 468.03961),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q1', '2018-03-31', '资产负债表', '总资产减总负债合计', 46, -1279.91061),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q1', '2018-03-31', '资产负债表', '长期贷款', 30, 82.49878),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q1', '2018-03-31', '资产负债表', '递延税项负债', 31, 9.8087),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q1', '2018-03-31', '资产负债表', '拨备(非流动)', 32, 1.99019),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q1', '2018-03-31', '资产负债表', '可转换可赎回优先股', 48, 1653.30822),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q1', '2018-03-31', '资产负债表', '非流动负债其他项目', 45, 0.34433),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q1', '2018-03-31', '资产负债表', '非流动负债合计', 34, 1747.95022),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q1', '2018-03-31', '资产负债表', '总负债', 35, 2200.84661),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q1', '2018-03-31', '资产负债表', '少数股东权益', 36, 0.00938),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q1', '2018-03-31', '资产负债表', '净资产', 37, -1279.91061),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q1', '2018-03-31', '资产负债表', '股本', 38, 0.0015),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q1', '2018-03-31', '资产负债表', '储备', 39, -1279.92149),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q1', '2018-03-31', '资产负债表', '股东权益', 40, -1279.91999),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q1', '2018-03-31', '资产负债表', '总权益', 41, -1279.91061),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q1', '2018-03-31', '资产负债表', '总权益及非流动负债', 42, 468.03961),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q1', '2018-03-31', '资产负债表', '总权益及总负债', 43, 920.936),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '资产负债表', '物业厂房及设备', 1, 17.30872),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '资产负债表', '无形资产', 2, 22.74352),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '资产负债表', '土地使用权', 47, 34.16359),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '资产负债表', '递延税项资产', 3, 5.91576),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '资产负债表', '其他投资', 5, 17.10819),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '资产负债表', '指定以公允价值记账之金融资产', 6, 188.56961),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '资产负债表', '非流动资产其他项目', 8, 1.50361),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '资产负债表', '非流动资产合计', 9, 287.313),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '资产负债表', '存货', 10, 163.42928),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '资产负债表', '应收帐款', 11, 54.69507),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '资产负债表', '预付款按金及其他应收款', 12, 113.9391),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '资产负债表', '短期投资', 13, 8.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '资产负债表', '受限制存款及现金', 14, 27.11119),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '资产负债表', '现金及等价物', 15, 115.63282),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '资产负债表', '短期存款', 16, 2.25146),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '资产负债表', '指定以公允价值记账之金融资产(流动)', 17, 44.88076),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '资产负债表', '贷款及垫款(流动)', 18, 81.44493),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '资产负债表', '流动资产合计', 19, 611.38461),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '资产负债表', '总资产', 20, 898.69761),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '资产负债表', '应付帐款', 21, 340.03331),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '资产负债表', '应付税项', 22, 4.21113),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '资产负债表', '其他应付款及应计费用', 23, 42.23979),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '资产负债表', '预收款项', 24, 33.9065),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '资产负债表', '短期贷款', 25, 35.50801),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '资产负债表', '拨备(流动)', 26, 15.42797),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '资产负债表', '流动负债合计', 27, 471.32671),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '资产负债表', '净流动资产', 28, 140.0579),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '资产负债表', '总资产减流动负债', 29, 427.3709),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '资产负债表', '长期贷款', 30, 72.51312),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '资产负债表', '递延税项负债', 31, 10.18651),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '资产负债表', '拨备(非流动)', 32, 1.91404),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '资产负债表', '可转换可赎回优先股', 48, 1614.51203),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '资产负债表', '非流动负债其他项目', 45, 0.35211),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '资产负债表', '非流动负债合计', 34, 1699.47781),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '资产负债表', '总负债', 35, 2170.80452),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '资产负债表', '少数股东权益', 36, 0.6167),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '资产负债表', '净资产', 37, -1272.10691),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '资产负债表', '股本', 38, 0.0015),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '资产负债表', '储备', 39, -1272.72511),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '资产负债表', '股东权益', 40, -1272.72361),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '资产负债表', '总权益', 41, -1272.10691),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '资产负债表', '总权益及非流动负债', 42, 427.3709),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '资产负债表', '总权益及总负债', 43, 898.69761),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '资产负债表', '物业厂房及设备', 1, 8.48377),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '资产负债表', '无形资产', 2, 11.20133),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '资产负债表', '土地使用权', 47, 34.94041),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '资产负债表', '递延税项资产', 3, 4.46303),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '资产负债表', '其他投资', 5, 18.52563),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '资产负债表', '指定以公允价值记账之金融资产', 6, 123.49198),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '资产负债表', '非流动资产其他项目', 8, 0.18668),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '资产负债表', '非流动资产合计', 9, 201.29283),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '资产负债表', '存货', 10, 83.78342),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '资产负债表', '应收帐款', 11, 20.89518),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '资产负债表', '预付款按金及其他应收款', 12, 47.48418),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '资产负债表', '短期投资', 13, 0.8),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '资产负债表', '受限制存款及现金', 14, 6.33964),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '资产负债表', '现金及等价物', 15, 92.3032),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '资产负债表', '短期存款', 16, 4.40156),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '资产负债表', '指定以公允价值记账之金融资产(流动)', 17, 34.37537),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '资产负债表', '贷款及垫款(流动)', 18, 15.98063),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '资产负债表', '流动资产合计', 19, 306.36318),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '资产负债表', '总资产', 20, 507.65601),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '资产负债表', '应付帐款', 21, 175.77702),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '资产负债表', '应付税项', 22, 2.57558),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '资产负债表', '其他应付款及应计费用', 23, 18.76267),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '资产负债表', '预收款项', 24, 18.36174),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '资产负债表', '短期贷款', 25, 37.685),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '资产负债表', '拨备(流动)', 26, 7.47061),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '资产负债表', '流动负债合计', 27, 260.63262),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '资产负债表', '净流动资产', 28, 45.73056),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '资产负债表', '总资产减流动负债', 29, 247.02339),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '资产负债表', '总资产减总负债合计', 46, -920.57875),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '资产负债表', '长期贷款', 30, 3.9),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '资产负债表', '递延税项负债', 31, 4.58289),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '资产负债表', '拨备(非流动)', 32, 1.0197),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '资产负债表', '可转换可赎回优先股', 48, 1158.02177),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '资产负债表', '非流动负债其他项目', 45, 0.07778),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '资产负债表', '非流动负债合计', 34, 1167.60214),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '资产负债表', '总负债', 35, 1428.23476),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '资产负债表', '少数股东权益', 36, 1.33795),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '资产负债表', '净资产', 37, -920.57875),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '资产负债表', '股本', 38, 0.0015),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '资产负债表', '储备', 39, -921.9182),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '资产负债表', '股东权益', 40, -921.9167),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '资产负债表', '总权益', 41, -920.57875),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '资产负债表', '总权益及非流动负债', 42, 247.02339),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '资产负债表', '总权益及总负债', 43, 507.65601),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '资产负债表', '物业厂房及设备', 1, 2.90183),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '资产负债表', '无形资产', 2, 5.53759),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '资产负债表', '递延税项资产', 3, 3.94144),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '资产负债表', '预付款项', 49, 26.00552),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '资产负债表', '其他投资', 5, 17.29269),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '资产负债表', '指定以公允价值记账之金融资产', 6, 83.90794),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '资产负债表', '非流动资产其他项目', 8, 2.25309),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '资产负债表', '非流动资产合计', 9, 141.8401),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '资产负债表', '存货', 10, 86.43183),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '资产负债表', '应收帐款', 11, 14.70155),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '资产负债表', '预付款按金及其他应收款', 12, 31.18768),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '资产负债表', '短期投资', 13, 16.29),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '资产负债表', '受限制存款及现金', 14, 0.6706),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '资产负债表', '现金及等价物', 15, 83.94078),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '资产负债表', '短期存款', 16, 7.3936),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '资产负债表', '指定以公允价值记账之金融资产(流动)', 17, 7.89943),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '资产负债表', '贷款及垫款(流动)', 18, 1.0098),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '资产负债表', '流动资产合计', 19, 249.52527),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '资产负债表', '总资产', 20, 391.36537),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '资产负债表', '应付帐款', 21, 142.2554),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '资产负债表', '应付税项', 22, 1.01345),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '资产负债表', '其他应付款及应计费用', 23, 12.75068),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '资产负债表', '预收款项', 24, 5.30675),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '资产负债表', '拨备(流动)', 26, 3.31652),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '资产负债表', '流动负债合计', 27, 164.6428),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '资产负债表', '净流动资产', 28, 84.88247),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '资产负债表', '总资产减流动负债', 29, 226.72257),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '资产负债表', '总资产减总负债合计', 46, -866.38308),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '资产负债表', '长期贷款', 30, 32.468),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '资产负债表', '递延税项负债', 31, 1.03564),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '资产负债表', '拨备(非流动)', 32, 0.11963),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '资产负债表', '可转换可赎回优先股', 48, 1059.32869),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '资产负债表', '非流动负债其他项目', 45, 0.15369),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '资产负债表', '非流动负债合计', 34, 1093.10565),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '资产负债表', '总负债', 35, 1257.74845),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '资产负债表', '少数股东权益', 36, 0.7617),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '资产负债表', '净资产', 37, -866.38308),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '资产负债表', '股本', 38, 0.0015),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '资产负债表', '储备', 39, -867.14628),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '资产负债表', '股东权益', 40, -867.14478),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '资产负债表', '总权益', 41, -866.38308),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '资产负债表', '总权益及非流动负债', 42, 226.72257),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '资产负债表', '总权益及总负债', 43, 391.36537),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '利润表', '营业额', 1, 2080.63227),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '利润表', '营运收入', 2, 2080.63227),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '利润表', '销售成本', 3, 1646.44189),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '利润表', '毛利', 4, 434.19038),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '利润表', '其他收入', 5, 32.4502),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '利润表', '其他收益', 6, 4.35293),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '利润表', '销售及分销费用', 7, 169.24978),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '利润表', '行政开支', 8, 31.12071),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '利润表', '重估盈余', 9, 73.06176),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '利润表', '研发费用', 10, 181.85665),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '利润表', '经营溢利', 11, 161.82813),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '利润表', '利息收入', 12, 25.66152),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '利润表', '融资成本', 13, 14.54927),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '利润表', '除税前溢利', 14, 172.94038),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '利润表', '税项', 15, 30.96085),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '利润表', '持续经营业务税后利润', 16, 141.97953),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '利润表', '除税后溢利', 17, 141.97953),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '利润表', '少数股东损益', 18, 0.12428),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '利润表', '股东应占溢利', 19, 141.85525),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '利润表', '每股基本盈利', 20, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '利润表', '每股摊薄盈利', 21, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '利润表', '其他全面收益其他项目', 22, -34.24896),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '利润表', '其他全面收益', 23, -34.24896),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '利润表', '全面收益总额', 24, 107.73057),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '利润表', '非控股权益应占全面收益总额', 25, 0.12428),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '利润表', '本公司拥有人应占全面收益总额', 26, 107.60629),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '利润表', '非运算项目', 27, -1646.44189),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '利润表', '营业额', 1, 991.41618),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '利润表', '营运收入', 2, 991.41618),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '利润表', '销售成本', 3, 773.31498),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '利润表', '毛利', 4, 218.1012),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '利润表', '其他收入', 5, 10.85385),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '利润表', '其他收益', 6, 4.29872),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '利润表', '销售及分销费用', 7, 82.76483),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '利润表', '行政开支', 8, 16.30385),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '利润表', '重估盈余', 9, 8.48517),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '利润表', '研发费用', 10, 89.54381),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '利润表', '经营溢利', 11, 53.12645),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '利润表', '利息收入', 12, 12.78054),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '利润表', '融资成本', 13, 8.61992),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '利润表', '除税前溢利', 14, 57.28707),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '利润表', '税项', 15, 9.9413),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '利润表', '持续经营业务税后利润', 16, 47.34577),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '利润表', '除税后溢利', 17, 47.34577),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '利润表', '少数股东损益', 18, 0.11457),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '利润表', '股东应占溢利', 19, 47.2312),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '利润表', '每股基本盈利', 20, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '利润表', '每股摊薄盈利', 21, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '利润表', '其他全面收益其他项目', 22, -18.1084),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '利润表', '其他全面收益', 23, -18.1084),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '利润表', '全面收益总额', 24, 29.23737),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '利润表', '非控股权益应占全面收益总额', 25, 0.11457),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '利润表', '本公司拥有人应占全面收益总额', 26, 29.1228),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '利润表', '非运算项目', 27, -773.31498),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '利润表', '营业额', 1, 4572.86687),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '利润表', '营运收入', 2, 4572.86687),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '利润表', '销售成本', 3, 3554.8084),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '利润表', '毛利', 4, 1018.05847),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '利润表', '其他收入', 5, 27.3694),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '利润表', '其他收益', 6, 30.45965),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '利润表', '销售及分销费用', 7, 332.14338),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '利润表', '行政开支', 8, 66.53026),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '利润表', '重估盈余', 9, 133.11733),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '利润表', '研发费用', 10, 331.32201),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '利润表', '经营溢利', 11, 479.0092),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '利润表', '利息收入', 12, 53.8068),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '利润表', '融资成本', 13, 36.34735),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '利润表', '除税前溢利', 14, 496.46865),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '利润表', '税项', 15, 80.80426),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '利润表', '持续经营业务税后利润', 16, 415.66439),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '利润表', '除税后溢利', 17, 415.66439),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '利润表', '少数股东损益', 18, -0.7695),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '利润表', '股东应占溢利', 19, 416.43389),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '利润表', '每股基本盈利', 20, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '利润表', '每股摊薄盈利', 21, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '利润表', '其他全面收益其他项目', 22, -26.65739),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '利润表', '其他全面收益', 23, -26.65739),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '利润表', '全面收益总额', 24, 389.007),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '利润表', '非控股权益应占全面收益总额', 25, -0.92974),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '利润表', '本公司拥有人应占全面收益总额', 26, 389.93674),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '利润表', '非运算项目', 27, -3554.8084),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '利润表', '营业额', 1, 3403.70162),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '利润表', '营运收入', 2, 3403.70162),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '利润表', '销售成本', 3, 2629.27128),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '利润表', '毛利', 4, 774.43034),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '利润表', '其他收入', 5, 21.47854),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '利润表', '其他收益', 6, 22.35025),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '利润表', '销售及分销费用', 7, 232.87441),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '利润表', '行政开支', 8, 50.05435),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '利润表', '重估盈余', 9, 116.73676),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '利润表', '研发费用', 10, 235.34458),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '利润表', '经营溢利', 11, 416.72255),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '利润表', '利息收入', 12, 39.72267),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '利润表', '融资成本', 13, 31.18126),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '利润表', '除税前溢利', 14, 425.26396),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '利润表', '税项', 15, 75.03746),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '利润表', '持续经营业务税后利润', 16, 350.2265),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '利润表', '除税后溢利', 17, 350.2265),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '利润表', '少数股东损益', 18, -0.7695),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '利润表', '股东应占溢利', 19, 350.996),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '利润表', '每股基本盈利', 20, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '利润表', '每股摊薄盈利', 21, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '利润表', '其他全面收益其他项目', 22, -13.0931),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '利润表', '其他全面收益', 23, -13.0931),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '利润表', '全面收益总额', 24, 337.1334),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '利润表', '非控股权益应占全面收益总额', 25, -0.92974),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '利润表', '本公司拥有人应占全面收益总额', 26, 338.06314),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '利润表', '非运算项目', 27, -2629.27128),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '利润表', '营业额', 1, 2272.49428),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '利润表', '营运收入', 2, 2272.49428),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '利润表', '销售成本', 3, 1757.4256),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '利润表', '毛利', 4, 515.06868),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '利润表', '其他收入', 5, 4.61212),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '利润表', '其他收益', 6, 10.13638),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '利润表', '销售及分销费用', 7, 149.77788),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '利润表', '行政开支', 8, 31.57238),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '利润表', '重估盈余', 9, 61.90519),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '利润表', '研发费用', 10, 144.75085),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '利润表', '经营溢利', 11, 265.62126),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '利润表', '利息收入', 12, 24.82491),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '利润表', '融资成本', 13, 14.73866),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '利润表', '除税前溢利', 14, 275.70751),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '利润表', '税项', 15, 48.04842),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '利润表', '持续经营业务税后利润', 16, 227.65909),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '利润表', '除税后溢利', 17, 227.65909),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '利润表', '少数股东损益', 18, -0.62817),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '利润表', '股东应占溢利', 19, 228.28726),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '利润表', '每股基本盈利', 20, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '利润表', '每股摊薄盈利', 21, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '利润表', '其他全面收益其他项目', 22, -2.66262),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '利润表', '其他全面收益', 23, -2.66262),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '利润表', '全面收益总额', 24, 224.99647),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '利润表', '非控股权益应占全面收益总额', 25, -0.80353),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '利润表', '本公司拥有人应占全面收益总额', 26, 225.8),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '利润表', '非运算项目', 27, -1757.4256),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '利润表', '营业额', 1, 1112.93337),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '利润表', '营运收入', 2, 1112.93337),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '利润表', '销售成本', 3, 858.87427),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '利润表', '毛利', 4, 254.0591),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '利润表', '其他收入', 5, 1.61766),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '利润表', '其他收益', 6, 1.72328),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '利润表', '销售及分销费用', 7, 71.99817),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '利润表', '行政开支', 8, 15.30094),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '利润表', '重估盈余', 9, 28.27022),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '利润表', '研发费用', 10, 67.11708),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '利润表', '经营溢利', 11, 131.25407),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '利润表', '利息收入', 12, 10.03965),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '利润表', '融资成本', 13, 9.61404),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '利润表', '除税前溢利', 14, 131.67968),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '利润表', '税项', 15, 22.75222),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '利润表', '持续经营业务税后利润', 16, 108.92746),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '利润表', '除税后溢利', 17, 108.92746),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '利润表', '少数股东损益', 18, -0.31575),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '利润表', '股东应占溢利', 19, 109.24321),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '利润表', '每股基本盈利', 20, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '利润表', '每股摊薄盈利', 21, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '利润表', '其他全面收益其他项目', 22, 0.19497),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '利润表', '其他全面收益', 23, 0.19497),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '利润表', '全面收益总额', 24, 109.12243),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '利润表', '非控股权益应占全面收益总额', 25, -0.3412),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '利润表', '本公司拥有人应占全面收益总额', 26, 109.46363),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '利润表', '非运算项目', 27, -858.87427),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '利润表', '营业额', 1, 3659.0635),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '利润表', '营运收入', 2, 3659.0635),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '利润表', '销售成本', 3, 2893.46156),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '利润表', '毛利', 4, 765.60194),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '利润表', '其他收入', 5, 16.66779),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '利润表', '其他收益', 6, 2.66511),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '利润表', '销售及分销费用', 7, 253.89628),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '利润表', '行政开支', 8, 56.01248),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '利润表', '重估盈余', 9, 10.50772),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '利润表', '研发费用', 10, 240.50484),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '利润表', '经营溢利', 11, 245.02896),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '利润表', '利息收入', 12, 38.36204),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '利润表', '融资成本', 13, 2.12447),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '利润表', '除税前溢利', 14, 281.26653),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '利润表', '税项', 15, 45.48204),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '利润表', '持续经营业务税后利润', 16, 235.78449),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '利润表', '除税后溢利', 17, 235.78449),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '利润表', '少数股东损益', 18, -0.79677),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '利润表', '股东应占溢利', 19, 236.58126),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '利润表', '每股基本盈利', 20, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '利润表', '每股摊薄盈利', 21, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '利润表', '其他全面收益其他项目', 22, 7.60236),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '利润表', '其他全面收益', 23, 7.60236),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '利润表', '全面收益总额', 24, 243.38685),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '利润表', '非控股权益应占全面收益总额', 25, -0.69011),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '利润表', '本公司拥有人应占全面收益总额', 26, 244.07696),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '利润表', '非运算项目', 27, -2893.46156),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '利润表', '营业额', 1, 2569.01191),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '利润表', '营运收入', 2, 2569.01191),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '利润表', '销售成本', 3, 2027.95887),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '利润表', '毛利', 4, 541.05304),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '利润表', '其他收入', 5, 7.20555),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '利润表', '其他收益', 6, 7.09596),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '利润表', '销售及分销费用', 7, 176.60245),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '利润表', '行政开支', 8, 41.209),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '利润表', '重估盈余', 9, -15.27388),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '利润表', '研发费用', 10, 166.139),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '利润表', '经营溢利', 11, 156.13022),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '利润表', '利息收入', 12, 28.29429),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '利润表', '融资成本', 13, -2.76506),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '利润表', '除税前溢利', 14, 187.18957),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '利润表', '税项', 15, 41.35784),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '利润表', '持续经营业务税后利润', 16, 145.83173),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '利润表', '除税后溢利', 17, 145.83173),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '利润表', '少数股东损益', 18, -0.49294),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '利润表', '股东应占溢利', 19, 146.32467),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '利润表', '每股基本盈利', 20, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '利润表', '每股摊薄盈利', 21, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '利润表', '其他全面收益其他项目', 22, -6.63808),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '利润表', '其他全面收益', 23, -6.63808),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '利润表', '全面收益总额', 24, 139.19365),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '利润表', '非控股权益应占全面收益总额', 25, -0.62604),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '利润表', '本公司拥有人应占全面收益总额', 26, 139.81969),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '利润表', '非运算项目', 27, -2027.95887),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '利润表', '营业额', 1, 1643.9465),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '利润表', '营运收入', 2, 1643.9465),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '利润表', '销售成本', 3, 1291.70756),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '利润表', '毛利', 4, 352.23894),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '利润表', '其他收入', 5, 4.44653),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '利润表', '其他收益', 6, 7.2186),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '利润表', '销售及分销费用', 7, 113.80099),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '利润表', '行政开支', 8, 27.05531),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '利润表', '重估盈余', 9, -20.75902),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '利润表', '研发费用', 10, 106.57116),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '利润表', '经营溢利', 11, 95.71759),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '利润表', '利息收入', 12, 18.9631),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '利润表', '融资成本', 13, -4.33694),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '利润表', '除税前溢利', 14, 119.01763),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '利润表', '税项', 15, 26.58882),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '利润表', '持续经营业务税后利润', 16, 92.42881),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '利润表', '除税后溢利', 17, 92.42881),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '利润表', '少数股东损益', 18, -0.37182),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '利润表', '股东应占溢利', 19, 92.80063),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '利润表', '每股基本盈利', 20, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '利润表', '每股摊薄盈利', 21, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '利润表', '其他全面收益其他项目', 22, 3.69849),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '利润表', '其他全面收益', 23, 3.69849),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '利润表', '全面收益总额', 24, 96.1273),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '利润表', '非控股权益应占全面收益总额', 25, -0.42283),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '利润表', '本公司拥有人应占全面收益总额', 26, 96.55013),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '利润表', '非运算项目', 27, -1291.70756),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '利润表', '营业额', 1, 755.06822),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '利润表', '营运收入', 2, 755.06822),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '利润表', '销售成本', 3, 586.77105),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '利润表', '毛利', 4, 168.29717),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '利润表', '其他收入', 5, 1.57407),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '利润表', '其他收益', 6, 0.85847),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '利润表', '销售及分销费用', 7, 54.81047),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '利润表', '行政开支', 8, 15.23007),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '利润表', '重估盈余', 9, -12.26492),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '利润表', '研发费用', 10, 51.59387),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '利润表', '经营溢利', 11, 36.83038),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '利润表', '利息收入', 12, 10.19435),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '利润表', '融资成本', 13, -5.19905),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '利润表', '除税前溢利', 14, 52.22378),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '利润表', '税项', 15, 10.49166),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '利润表', '持续经营业务税后利润', 16, 41.73212),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '利润表', '除税后溢利', 17, 41.73212),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '利润表', '少数股东损益', 18, -0.08849),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '利润表', '股东应占溢利', 19, 41.82061),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '利润表', '每股基本盈利', 20, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '利润表', '每股摊薄盈利', 21, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '利润表', '其他全面收益其他项目', 22, 0.89236),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '利润表', '其他全面收益', 23, 0.89236),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '利润表', '全面收益总额', 24, 42.62448),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '利润表', '非控股权益应占全面收益总额', 25, -0.08698),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '利润表', '本公司拥有人应占全面收益总额', 26, 42.71146),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '利润表', '非运算项目', 27, -586.77105),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '利润表', '营业额', 1, 2709.70141),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '利润表', '营运收入', 2, 2709.70141),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '利润表', '销售成本', 3, 2134.93902),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '利润表', '毛利', 4, 574.76239),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '利润表', '其他收入', 5, 7.40091),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '利润表', '其他收益', 6, 17.42326),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '利润表', '销售及分销费用', 7, 192.26542),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '利润表', '行政开支', 8, 51.26798),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '利润表', '重估盈余', 9, 35.01053),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '利润表', '研发费用', 10, 190.97699),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '利润表', '经营溢利', 11, 200.0867),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '利润表', '利息收入', 12, 35.58347),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '利润表', '融资成本', 13, 15.5597),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '利润表', '除税前溢利', 14, 220.11047),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '利润表', '税项', 15, 45.36851),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '利润表', '持续经营业务税后利润', 16, 174.74196),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '利润表', '除税后溢利', 17, 174.74196),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '利润表', '少数股东损益', 18, -0.00977),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '利润表', '股东应占溢利', 19, 174.75173),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '利润表', '每股基本盈利', 20, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '利润表', '每股摊薄盈利', 21, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '利润表', '其他全面收益其他项目', 22, 10.35865),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '利润表', '其他全面收益', 23, 10.35865),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '利润表', '全面收益总额', 24, 185.10061),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '利润表', '非控股权益应占全面收益总额', 25, 0.02513),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '利润表', '本公司拥有人应占全面收益总额', 26, 185.07548),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '利润表', '非运算项目', 27, -2134.93902),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '利润表', '营业额', 1, 1977.26454),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '利润表', '营运收入', 2, 1977.26454),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '利润表', '销售成本', 3, 1558.6416),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '利润表', '毛利', 4, 418.62294),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '利润表', '其他收入', 5, 4.78344),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '利润表', '其他收益', 6, 3.28654),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '利润表', '销售及分销费用', 7, 133.16887),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '利润表', '行政开支', 8, 36.43654),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '利润表', '重估盈余', 9, 28.7758),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '利润表', '研发费用', 10, 136.34383),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '利润表', '经营溢利', 11, 149.51948),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '利润表', '利息收入', 12, 25.01012),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '利润表', '融资成本', 13, 11.39366),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '利润表', '除税前溢利', 14, 163.13594),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '利润表', '税项', 15, 35.6286),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '利润表', '持续经营业务税后利润', 16, 127.50734),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '利润表', '除税后溢利', 17, 127.50734),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '利润表', '少数股东损益', 18, 0.03059),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '利润表', '股东应占溢利', 19, 127.47675),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '利润表', '每股基本盈利', 20, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '利润表', '每股摊薄盈利', 21, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '利润表', '其他全面收益其他项目', 22, 18.25436),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '利润表', '其他全面收益', 23, 18.25436),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '利润表', '全面收益总额', 24, 145.7617),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '利润表', '非控股权益应占全面收益总额', 25, 0.08846),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '利润表', '本公司拥有人应占全面收益总额', 26, 145.67324),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '利润表', '非运算项目', 27, -1558.6416),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '利润表', '营业额', 1, 1268.32042),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '利润表', '营运收入', 2, 1268.32042),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '利润表', '销售成本', 3, 1010.79459),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '利润表', '毛利', 4, 257.52583),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '利润表', '其他收入', 5, 3.4961),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '利润表', '其他收益', 6, 1.88215),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '利润表', '销售及分销费用', 7, 85.80622),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '利润表', '行政开支', 8, 22.78363),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '利润表', '重估盈余', 9, 31.77475),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '利润表', '研发费用', 10, 86.68163),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '利润表', '经营溢利', 11, 99.40735),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '利润表', '利息收入', 12, 15.29423),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '利润表', '融资成本', 13, 10.43764),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '利润表', '除税前溢利', 14, 104.26394),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '利润表', '税项', 15, 25.44732),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '利润表', '持续经营业务税后利润', 16, 78.81662),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '利润表', '除税后溢利', 17, 78.81662),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '利润表', '少数股东损益', 18, 0.07848),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '利润表', '股东应占溢利', 19, 78.73814),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '利润表', '每股基本盈利', 20, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '利润表', '每股摊薄盈利', 21, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '利润表', '其他全面收益其他项目', 22, 21.13045),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '利润表', '其他全面收益', 23, 21.13045),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '利润表', '全面收益总额', 24, 99.94707),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '利润表', '非控股权益应占全面收益总额', 25, 0.14378),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '利润表', '本公司拥有人应占全面收益总额', 26, 99.80329),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '利润表', '非运算项目', 27, -1010.79459),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '利润表', '营业额', 1, 594.77134),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '利润表', '营运收入', 2, 594.77134),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '利润表', '销售成本', 3, 478.85567),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '利润表', '毛利', 4, 115.91567),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '利润表', '其他收入', 5, 1.64834),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '利润表', '其他收益', 6, 0.42946),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '利润表', '销售及分销费用', 7, 41.03864),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '利润表', '行政开支', 8, 11.35173),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '利润表', '重估盈余', 9, 34.53259),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '利润表', '研发费用', 10, 41.1336),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '利润表', '经营溢利', 11, 59.00209),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '利润表', '利息收入', 12, 6.7815),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '利润表', '融资成本', 13, 11.07646),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '利润表', '除税前溢利', 14, 54.70713),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '利润表', '税项', 15, 12.54575),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '利润表', '持续经营业务税后利润', 16, 42.16138),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '利润表', '除税后溢利', 17, 42.16138),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '利润表', '少数股东损益', 18, 0.12299),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '利润表', '股东应占溢利', 19, 42.03839),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '利润表', '每股基本盈利', 20, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '利润表', '每股摊薄盈利', 21, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '利润表', '其他全面收益其他项目', 22, -6.176),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '利润表', '其他全面收益', 23, -6.176),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '利润表', '全面收益总额', 24, 35.98538),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '利润表', '非控股权益应占全面收益总额', 25, 0.08626),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '利润表', '本公司拥有人应占全面收益总额', 26, 35.89912),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '利润表', '非运算项目', 27, -478.85567),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '利润表', '营业额', 1, 2800.44016),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '利润表', '营运收入', 2, 2800.44016),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '利润表', '销售成本', 3, 2324.66826),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '利润表', '毛利', 4, 475.7719),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '利润表', '其他收入', 5, 11.3556),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '利润表', '其他收益', 6, -17.6891),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '利润表', '销售及分销费用', 7, 213.23323),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '利润表', '行政开支', 8, 51.13877),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '利润表', '重估盈余', 9, -16.6201),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '利润表', '研发费用', 10, 160.28132),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '利润表', '经营溢利', 11, 28.16498),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '利润表', '利息收入', 12, 16.63941),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '利润表', '融资成本', 13, 5.46483),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '利润表', '除税前溢利', 14, 39.33956),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '利润表', '税项', 15, 14.31388),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '利润表', '持续经营业务税后利润', 16, 25.02568),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '利润表', '除税后溢利', 17, 25.02568),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '利润表', '少数股东损益', 18, 0.28538),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '利润表', '股东应占溢利', 19, 24.7403),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '利润表', '每股基本盈利', 20, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '利润表', '每股摊薄盈利', 21, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '利润表', '其他全面收益其他项目', 22, 37.45355),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '利润表', '其他全面收益', 23, 37.45355),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '利润表', '全面收益总额', 24, 62.47923),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '利润表', '非控股权益应占全面收益总额', 25, 0.46254),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '利润表', '本公司拥有人应占全面收益总额', 26, 62.01669),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '利润表', '非运算项目', 27, -2324.66826),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '利润表', '营业额', 1, 2139.96648),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '利润表', '营运收入', 2, 2139.96648),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '利润表', '销售成本', 3, 1777.96958),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '利润表', '毛利', 4, 361.9969),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '利润表', '其他收入', 5, 5.46775),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '利润表', '其他收益', 6, -12.44139),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '利润表', '销售及分销费用', 7, 154.70968),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '利润表', '行政开支', 8, 38.1537),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '利润表', '重估盈余', 9, -54.27532),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '利润表', '研发费用', 10, 113.27702),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '利润表', '经营溢利', 11, -5.39246),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '利润表', '利息收入', 12, 11.00821),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '利润表', '融资成本', 13, 4.31361),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '利润表', '除税前溢利', 14, 1.30214),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '利润表', '税项', 15, 7.69313),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '利润表', '持续经营业务税后利润', 16, -6.39099),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '利润表', '除税后溢利', 17, -6.39099),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '利润表', '少数股东损益', 18, 0.38151),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '利润表', '股东应占溢利', 19, -6.7725),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '利润表', '每股基本盈利', 20, -0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '利润表', '每股摊薄盈利', 21, -0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '利润表', '其他全面收益其他项目', 22, 46.79736),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '利润表', '其他全面收益', 23, 46.79736),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '利润表', '全面收益总额', 24, 40.40637),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '利润表', '非控股权益应占全面收益总额', 25, 0.5813),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '利润表', '本公司拥有人应占全面收益总额', 26, 39.82507),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '利润表', '非运算项目', 27, -1777.96958),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '利润表', '营业额', 1, 1435.22379),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '利润表', '营运收入', 2, 1435.22379),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '利润表', '销售成本', 3, 1190.44598),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '利润表', '毛利', 4, 244.77781),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '利润表', '其他收入', 5, 3.51104),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '利润表', '其他收益', 6, -5.6416),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '利润表', '销售及分销费用', 7, 105.88392),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '利润表', '行政开支', 8, 25.59977),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '利润表', '重估盈余', 9, -30.36678),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '利润表', '研发费用', 10, 72.57913),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '利润表', '经营溢利', 11, 8.21765),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '利润表', '利息收入', 12, 6.45693),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '利润表', '融资成本', 13, 1.46549),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '利润表', '除税前溢利', 14, 13.20909),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '利润表', '税项', 15, 4.86086),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '利润表', '持续经营业务税后利润', 16, 8.34823),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '利润表', '除税后溢利', 17, 8.34823),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '利润表', '少数股东损益', 18, 0.36023),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '利润表', '股东应占溢利', 19, 7.988),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '利润表', '每股基本盈利', 20, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '利润表', '每股摊薄盈利', 21, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '利润表', '其他全面收益其他项目', 22, 20.79142),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '利润表', '其他全面收益', 23, 20.79142),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '利润表', '全面收益总额', 24, 29.13965),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '利润表', '非控股权益应占全面收益总额', 25, 0.44782),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '利润表', '本公司拥有人应占全面收益总额', 26, 28.69183),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '利润表', '非运算项目', 27, -1190.44598),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '利润表', '营业额', 1, 733.51502),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '利润表', '营运收入', 2, 733.51502),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '利润表', '销售成本', 3, 606.41756),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '利润表', '毛利', 4, 127.09746),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '利润表', '其他收入', 5, 1.64927),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '利润表', '其他收益', 6, -2.40385),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '利润表', '销售及分销费用', 7, 52.56184),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '利润表', '行政开支', 8, 12.44573),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '利润表', '重估盈余', 9, -35.50255),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '利润表', '研发费用', 10, 34.94539),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '利润表', '经营溢利', 11, -9.11263),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '利润表', '利息收入', 12, 2.65702),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '利润表', '融资成本', 13, -2.29631),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '利润表', '除税前溢利', 14, -4.1593),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '利润表', '税项', 15, 1.14624),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '利润表', '持续经营业务税后利润', 16, -5.30554),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '利润表', '除税后溢利', 17, -5.30554),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '利润表', '少数股东损益', 18, 0.57046),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '利润表', '股东应占溢利', 19, -5.876),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '利润表', '每股基本盈利', 20, -0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '利润表', '每股摊薄盈利', 21, -0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '利润表', '其他全面收益其他项目', 22, -2.63023),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '利润表', '其他全面收益', 23, -2.63023),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '利润表', '全面收益总额', 24, -7.93577),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '利润表', '非控股权益应占全面收益总额', 25, 0.55222),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '利润表', '本公司拥有人应占全面收益总额', 26, -8.48799),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '利润表', '非运算项目', 27, -606.41756),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '利润表', '营业额', 1, 3283.09145),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '利润表', '营运收入', 2, 3283.09145),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '利润表', '销售成本', 3, 2700.48204),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '利润表', '毛利', 4, 582.60941),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '利润表', '其他收入', 5, 8.26856),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '利润表', '其他收益', 6, -23.04494),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '利润表', '销售及分销费用', 7, 209.80765),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '利润表', '行政开支', 8, 47.38919),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '利润表', '重估盈余', 9, 81.32133),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '利润表', '研发费用', 10, 131.67088),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '利润表', '经营溢利', 11, 260.28664),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '利润表', '利息收入', 12, 12.29826),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '利润表', '融资成本', 13, 28.41457),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '利润表', '除税前溢利', 14, 244.17033),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '利润表', '税项', 15, 51.33798),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '利润表', '持续经营业务税后利润', 16, 192.83235),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '利润表', '除税后溢利', 17, 192.83235),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '利润表', '少数股东损益', 18, -0.56086),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '利润表', '股东应占溢利', 19, 193.39321),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '利润表', '每股基本盈利', 20, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '利润表', '每股摊薄盈利', 21, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '利润表', '其他全面收益其他项目', 22, -14.04214),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '利润表', '其他全面收益', 23, -14.04214),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '利润表', '全面收益总额', 24, 178.79021),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '利润表', '非控股权益应占全面收益总额', 25, -0.61969),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '利润表', '本公司拥有人应占全面收益总额', 26, 179.4099),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '利润表', '非运算项目', 27, -2700.48204),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '利润表', '营业额', 1, 2427.33978),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '利润表', '营运收入', 2, 2427.33978),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '利润表', '销售成本', 3, 1991.32484),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '利润表', '毛利', 4, 436.01494),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '利润表', '其他收入', 5, 6.21551),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '利润表', '其他收益', 6, 5.89964),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '利润表', '销售及分销费用', 7, 147.26448),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '利润表', '行政开支', 8, 34.12591),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '利润表', '重估盈余', 9, 42.52992),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '利润表', '研发费用', 10, 93.13862),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '利润表', '经营溢利', 11, 216.131),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '利润表', '利息收入', 12, 9.1585),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '利润表', '融资成本', 13, 19.96415),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '利润表', '除税前溢利', 14, 205.32535),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '利润表', '税项', 15, 36.91803),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '利润表', '持续经营业务税后利润', 16, 168.40732),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '利润表', '除税后溢利', 17, 168.40732),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '利润表', '少数股东损益', 18, -0.1289),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '利润表', '股东应占溢利', 19, 168.53622),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '利润表', '每股基本盈利', 20, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '利润表', '每股摊薄盈利', 21, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '利润表', '其他全面收益其他项目', 22, -5.26481),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '利润表', '其他全面收益', 23, -5.26481),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '利润表', '全面收益总额', 24, 163.14251),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '利润表', '非控股权益应占全面收益总额', 25, -0.15046),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '利润表', '本公司拥有人应占全面收益总额', 26, 163.29297),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '利润表', '非运算项目', 27, -1991.32484),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '利润表', '营业额', 1, 1646.71123),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '利润表', '营运收入', 2, 1646.71123),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '利润表', '销售成本', 3, 1353.6185),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '利润表', '毛利', 4, 293.09273),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '利润表', '其他收入', 5, 3.86665),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '利润表', '其他收益', 6, 10.17144),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '利润表', '销售及分销费用', 7, 98.44134),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '利润表', '行政开支', 8, 21.37988),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '利润表', '重估盈余', 9, 62.28626),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '利润表', '研发费用', 10, 60.76167),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '利润表', '经营溢利', 11, 188.83419),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '利润表', '利息收入', 12, 5.97859),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '利润表', '融资成本', 13, 7.35856),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '利润表', '除税前溢利', 14, 187.45422),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '利润表', '税项', 15, 26.93207),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '利润表', '持续经营业务税后利润', 16, 160.52215),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '利润表', '除税后溢利', 17, 160.52215),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '利润表', '少数股东损益', 18, -0.09151),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '利润表', '股东应占溢利', 19, 160.61366),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '利润表', '每股基本盈利', 20, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '利润表', '每股摊薄盈利', 21, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '利润表', '其他全面收益其他项目', 22, -7.0538),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '利润表', '其他全面收益', 23, -7.0538),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '利润表', '全面收益总额', 24, 153.46835),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '利润表', '非控股权益应占全面收益总额', 25, -0.12122),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '利润表', '本公司拥有人应占全面收益总额', 26, 153.58957),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '利润表', '非运算项目', 27, -1353.6185),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '利润表', '营业额', 1, 768.82163),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '利润表', '营运收入', 2, 768.82163),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '利润表', '销售成本', 3, 627.20932),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '利润表', '毛利', 4, 141.61231),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '利润表', '其他收入', 5, 1.52053),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '利润表', '其他收益', 6, -0.5571),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '利润表', '销售及分销费用', 7, 41.63475),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '利润表', '行政开支', 8, 9.87652),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '利润表', '重估盈余', 9, 20.63207),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '利润表', '研发费用', 10, 30.11991),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '利润表', '经营溢利', 11, 81.57663),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '利润表', '利息收入', 12, 2.75208),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '利润表', '融资成本', 13, -6.34009),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '利润表', '除税前溢利', 14, 90.6688),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '利润表', '税项', 15, 12.77973),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '利润表', '除税后溢利', 17, 77.88907),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '利润表', '少数股东损益', 18, -0.03982),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '利润表', '股东应占溢利', 19, 77.92889),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '利润表', '每股基本盈利', 20, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '利润表', '每股摊薄盈利', 21, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '利润表', '其他全面收益其他项目', 22, 4.0437),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '利润表', '其他全面收益', 23, 4.0437),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '利润表', '全面收益总额', 24, 81.93277),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '利润表', '非控股权益应占全面收益总额', 25, -0.02873),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '利润表', '本公司拥有人应占全面收益总额', 26, 81.9615),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '利润表', '非运算项目', 27, 77.88907),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '利润表', '营业额', 1, 2458.65633),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '利润表', '营运收入', 2, 2458.65633),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '利润表', '销售成本', 3, 2091.13771),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '利润表', '毛利', 4, 367.51862),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '利润表', '其他收入', 5, 6.4293),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '利润表', '其他收益', 6, 10.08446),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '利润表', '销售及分销费用', 7, 145.394),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '利润表', '行政开支', 8, 37.46449),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '利润表', '重估盈余', 9, 131.73479),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '利润表', '研发费用', 10, 92.56139),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '利润表', '经营溢利', 11, 240.34729),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '利润表', '利息收入', 12, 9.63555),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '利润表', '融资成本', 13, 33.64852),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '利润表', '除税前溢利', 14, 216.33432),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '利润表', '税项', 15, 13.20722),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '利润表', '持续经营业务税后利润', 16, 203.1271),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '利润表', '除税后溢利', 17, 203.1271),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '利润表', '少数股东损益', 18, -0.42794),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '利润表', '股东应占溢利', 19, 203.55504),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '利润表', '每股基本盈利', 20, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '利润表', '每股摊薄盈利', 21, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '利润表', '其他全面收益其他项目', 22, -23.62821),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '利润表', '其他全面收益', 23, -23.62821),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '利润表', '全面收益总额', 24, 179.49889),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '利润表', '非控股权益应占全面收益总额', 25, -0.36563),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '利润表', '本公司拥有人应占全面收益总额', 26, 179.86452),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '利润表', '非运算项目', 27, -2091.13771),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q3', '2020-09-30', '利润表', '营业额', 1, 1754.02749),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q3', '2020-09-30', '利润表', '营运收入', 2, 1754.02749),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q3', '2020-09-30', '利润表', '销售成本', 3, 1499.7719),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q3', '2020-09-30', '利润表', '毛利', 4, 254.25559),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q3', '2020-09-30', '利润表', '其他收入', 5, 3.96069),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q3', '2020-09-30', '利润表', '其他收益', 6, 5.49573),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q3', '2020-09-30', '利润表', '销售及分销费用', 7, 94.49131),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q3', '2020-09-30', '利润表', '行政开支', 8, 24.70674),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q3', '2020-09-30', '利润表', '重估盈余', 9, 61.31958),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q3', '2020-09-30', '利润表', '研发费用', 10, 61.5052),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q3', '2020-09-30', '利润表', '经营溢利', 11, 144.32834),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q3', '2020-09-30', '利润表', '利息收入', 12, 7.3343),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q3', '2020-09-30', '利润表', '融资成本', 13, 23.93698),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q3', '2020-09-30', '利润表', '除税前溢利', 14, 127.72566),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q3', '2020-09-30', '利润表', '税项', 15, 12.54851),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q3', '2020-09-30', '利润表', '除税后溢利', 17, 115.17715),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q3', '2020-09-30', '利润表', '少数股东损益', 18, -0.24524),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q3', '2020-09-30', '利润表', '股东应占溢利', 19, 115.42239),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q3', '2020-09-30', '利润表', '每股基本盈利', 20, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q3', '2020-09-30', '利润表', '每股摊薄盈利', 21, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q3', '2020-09-30', '利润表', '其他全面收益其他项目', 22, -8.28714),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q3', '2020-09-30', '利润表', '其他全面收益', 23, -8.28714),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q3', '2020-09-30', '利润表', '全面收益总额', 24, 106.89001),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q3', '2020-09-30', '利润表', '非控股权益应占全面收益总额', 25, -0.18496),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q3', '2020-09-30', '利润表', '本公司拥有人应占全面收益总额', 26, 107.07497),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q3', '2020-09-30', '利润表', '非运算项目', 27, 337.24431),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '利润表', '营业额', 1, 1032.39972),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '利润表', '营运收入', 2, 1032.39972),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '利润表', '销售成本', 3, 879.80069),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '利润表', '毛利', 4, 152.59903),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '利润表', '其他收入', 5, 2.56778),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '利润表', '其他收益', 6, 8.01264),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '利润表', '销售及分销费用', 7, 58.48549),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '利润表', '行政开支', 8, 16.17959),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '利润表', '重估盈余', 9, 27.14034),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '利润表', '研发费用', 10, 38.29256),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '利润表', '经营溢利', 11, 77.36215),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '利润表', '利息收入', 12, 5.1374),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '利润表', '融资成本', 13, 9.2807),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '利润表', '除税前溢利', 14, 73.21885),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '利润表', '税项', 15, 6.68518),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '利润表', '持续经营业务税后利润', 16, 66.53367),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '利润表', '除税后溢利', 17, 66.53367),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '利润表', '少数股东损益', 18, -0.08276),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '利润表', '股东应占溢利', 19, 66.61643),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '利润表', '每股基本盈利', 20, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '利润表', '每股摊薄盈利', 21, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '利润表', '其他全面收益其他项目', 22, 4.8999),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '利润表', '其他全面收益', 23, 4.8999),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '利润表', '全面收益总额', 24, 71.43357),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '利润表', '非控股权益应占全面收益总额', 25, -0.02501),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '利润表', '本公司拥有人应占全面收益总额', 26, 71.45858),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '利润表', '非运算项目', 27, -879.80069),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q1', '2020-03-31', '利润表', '营业额', 1, 497.02167),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q1', '2020-03-31', '利润表', '营运收入', 2, 497.02167),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q1', '2020-03-31', '利润表', '销售成本', 3, 421.4371),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q1', '2020-03-31', '利润表', '毛利', 4, 75.58457),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q1', '2020-03-31', '利润表', '其他收入', 5, 0.73727),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q1', '2020-03-31', '利润表', '其他收益', 6, -3.79452),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q1', '2020-03-31', '利润表', '销售及分销费用', 7, 26.24873),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q1', '2020-03-31', '利润表', '行政开支', 8, 7.81533),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q1', '2020-03-31', '利润表', '重估盈余', 9, 3.47846),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q1', '2020-03-31', '利润表', '研发费用', 10, 18.70984),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q1', '2020-03-31', '利润表', '经营溢利', 11, 23.23188),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q1', '2020-03-31', '利润表', '利息收入', 12, 2.91946),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q1', '2020-03-31', '利润表', '融资成本', 13, 1.61045),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q1', '2020-03-31', '利润表', '除税前溢利', 14, 24.54089),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q1', '2020-03-31', '利润表', '税项', 15, 2.94195),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q1', '2020-03-31', '利润表', '除税后溢利', 17, 21.59894),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q1', '2020-03-31', '利润表', '少数股东损益', 18, -0.03621),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q1', '2020-03-31', '利润表', '股东应占溢利', 19, 21.63515),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q1', '2020-03-31', '利润表', '每股基本盈利', 20, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q1', '2020-03-31', '利润表', '每股摊薄盈利', 21, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q1', '2020-03-31', '利润表', '其他全面收益其他项目', 22, 5.17228),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q1', '2020-03-31', '利润表', '其他全面收益', 23, 5.17228),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q1', '2020-03-31', '利润表', '全面收益总额', 24, 26.77122),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q1', '2020-03-31', '利润表', '非控股权益应占全面收益总额', 25, 0.01889),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q1', '2020-03-31', '利润表', '本公司拥有人应占全面收益总额', 26, 26.75233),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '利润表', '营业额', 1, 2058.38682),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '利润表', '营运收入', 2, 2058.38682),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '利润表', '销售成本', 3, 1772.84649),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '利润表', '毛利', 4, 285.54033),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '利润表', '其他收入', 5, 12.65921),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '利润表', '其他收益', 6, -8.98221),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '利润表', '销售及分销费用', 7, 103.78073),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '利润表', '行政开支', 8, 31.03901),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '利润表', '重估盈余', 9, 38.13012),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '利润表', '研发费用', 10, 74.92554),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '利润表', '经营溢利', 11, 117.60217),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '利润表', '利息收入', 12, 9.30889),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '利润表', '融资成本', 13, 5.2846),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '利润表', '除税前溢利', 14, 121.62646),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '利润表', '税项', 15, 20.59696),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '利润表', '持续经营业务税后利润', 16, 101.0295),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '利润表', '除税后溢利', 17, 101.0295),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '利润表', '少数股东损益', 18, 0.58786),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '利润表', '股东应占溢利', 19, 100.44164),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '利润表', '每股基本盈利', 20, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '利润表', '每股摊薄盈利', 21, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '利润表', '其他全面收益其他项目', 22, 4.40433),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '利润表', '其他全面收益', 23, 4.40433),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '利润表', '全面收益总额', 24, 105.43383),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '利润表', '非控股权益应占全面收益总额', 25, 0.70469),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '利润表', '本公司拥有人应占全面收益总额', 26, 104.72914),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '利润表', '非运算项目', 27, -1772.84649),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q3', '2019-09-30', '利润表', '营业额', 1, 1493.68958),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q3', '2019-09-30', '利润表', '营运收入', 2, 1493.68958),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q3', '2019-09-30', '利润表', '销售成本', 3, 1286.58228),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q3', '2019-09-30', '利润表', '毛利', 4, 207.1073),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q3', '2019-09-30', '利润表', '其他收入', 5, 9.14979),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q3', '2019-09-30', '利润表', '其他收益', 6, -4.41092),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q3', '2019-09-30', '利润表', '销售及分销费用', 7, 66.77015),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q3', '2019-09-30', '利润表', '行政开支', 8, 21.99295),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q3', '2019-09-30', '利润表', '重估盈余', 9, 19.94595),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q3', '2019-09-30', '利润表', '研发费用', 10, 52.39839),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q3', '2019-09-30', '利润表', '经营溢利', 11, 90.63063),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q3', '2019-09-30', '利润表', '融资成本', 13, -3.83243),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q3', '2019-09-30', '利润表', '除税前溢利', 14, 94.46306),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q3', '2019-09-30', '利润表', '税项', 15, 17.79575),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q3', '2019-09-30', '利润表', '除税后溢利', 17, 76.66731),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q3', '2019-09-30', '利润表', '少数股东损益', 18, 0.63753),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q3', '2019-09-30', '利润表', '股东应占溢利', 19, 76.02978),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q3', '2019-09-30', '利润表', '每股基本盈利', 20, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q3', '2019-09-30', '利润表', '每股摊薄盈利', 21, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q3', '2019-09-30', '利润表', '其他全面收益其他项目', 22, 10.11361),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q3', '2019-09-30', '利润表', '其他全面收益', 23, 10.11361),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q3', '2019-09-30', '利润表', '全面收益总额', 24, 86.78092),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q3', '2019-09-30', '利润表', '非控股权益应占全面收益总额', 25, 0.76857),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q3', '2019-09-30', '利润表', '本公司拥有人应占全面收益总额', 26, 86.01235),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '利润表', '营业额', 1, 957.07952),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '利润表', '营运收入', 2, 957.07952),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '利润表', '销售成本', 3, 832.33656),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '利润表', '毛利', 4, 124.74296),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '利润表', '其他收入', 5, 4.666),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '利润表', '其他收益', 6, -2.50438),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '利润表', '销售及分销费用', 7, 41.39978),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '利润表', '行政开支', 8, 13.55535),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '利润表', '重估盈余', 9, 19.62062),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '利润表', '研发费用', 10, 32.06724),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '利润表', '经营溢利', 11, 59.50283),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '利润表', '融资成本', 13, -2.01175),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '利润表', '除税前溢利', 14, 61.51458),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '利润表', '税项', 15, 10.04156),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '利润表', '持续经营业务税后利润', 16, 51.47302),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '利润表', '除税后溢利', 17, 51.47302),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '利润表', '少数股东损益', 18, 0.69387),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '利润表', '股东应占溢利', 19, 50.77915),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '利润表', '每股基本盈利', 20, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '利润表', '每股摊薄盈利', 21, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '利润表', '其他全面收益其他项目', 22, 1.00715),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '利润表', '其他全面收益', 23, 1.00715),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '利润表', '全面收益总额', 24, 52.48017),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '利润表', '非控股权益应占全面收益总额', 25, 0.72017),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '利润表', '本公司拥有人应占全面收益总额', 26, 51.76),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '利润表', '非运算项目', 27, -832.33656),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q1', '2019-03-31', '利润表', '营业额', 1, 437.56823),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q1', '2019-03-31', '利润表', '营运收入', 2, 437.56823),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q1', '2019-03-31', '利润表', '销售成本', 3, 385.41246),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q1', '2019-03-31', '利润表', '毛利', 4, 52.15577),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q1', '2019-03-31', '利润表', '其他收入', 5, 0.60247),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q1', '2019-03-31', '利润表', '其他收益', 6, -1.67078),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q1', '2019-03-31', '利润表', '销售及分销费用', 7, 18.44684),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q1', '2019-03-31', '利润表', '行政开支', 8, 6.32022),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q1', '2019-03-31', '利润表', '重估盈余', 9, 26.32715),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q1', '2019-03-31', '利润表', '研发费用', 10, 16.50579),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q1', '2019-03-31', '利润表', '经营溢利', 11, 36.14176),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q1', '2019-03-31', '利润表', '利息收入', 12, 1.02964),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q1', '2019-03-31', '利润表', '除税前溢利', 14, 37.1714),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q1', '2019-03-31', '利润表', '税项', 15, 5.25396),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q1', '2019-03-31', '利润表', '除税后溢利', 17, 31.91744),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q1', '2019-03-31', '利润表', '少数股东损益', 18, 0.65785),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q1', '2019-03-31', '利润表', '股东应占溢利', 19, 31.25959),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q1', '2019-03-31', '利润表', '每股基本盈利', 20, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q1', '2019-03-31', '利润表', '每股摊薄盈利', 21, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q1', '2019-03-31', '利润表', '其他全面收益其他项目', 22, -4.6425),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q1', '2019-03-31', '利润表', '其他全面收益', 23, -4.6425),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q1', '2019-03-31', '利润表', '全面收益总额', 24, 27.27494),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q1', '2019-03-31', '利润表', '非控股权益应占全面收益总额', 25, 0.61542),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q1', '2019-03-31', '利润表', '本公司拥有人应占全面收益总额', 26, 26.65952),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '利润表', '营业额', 1, 1749.15425),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '利润表', '营运收入', 2, 1749.15425),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '利润表', '销售成本', 3, 1527.23486),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '利润表', '毛利', 4, 221.91939),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '利润表', '其他收入', 5, 8.44789),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '利润表', '其他收益', 6, -4.01639),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '利润表', '销售及分销费用', 7, 79.93072),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '利润表', '行政开支', 8, 120.99078),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '利润表', '重估盈余', 9, 44.30359),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '利润表', '研发费用', 10, 57.76826),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '利润表', '经营溢利', 11, 11.96472),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '利润表', '利息收入', 12, 2.16373),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '利润表', '溢利其他项目', 28, 125.14279),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '利润表', '除税前溢利', 14, 139.27124),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '利润表', '税项', 15, 4.49377),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '利润表', '持续经营业务税后利润', 16, 134.77747),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '利润表', '除税后溢利', 17, 134.77747),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '利润表', '少数股东损益', 18, -0.76139),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '利润表', '股东应占溢利', 19, 135.53886),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '利润表', '每股基本盈利', 20, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '利润表', '每股摊薄盈利', 21, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '利润表', '其他全面收益其他项目', 22, -15.56115),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '利润表', '其他全面收益', 23, -15.56115),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '利润表', '全面收益总额', 24, 119.21632),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '利润表', '非控股权益应占全面收益总额', 25, -0.67611),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '利润表', '本公司拥有人应占全面收益总额', 26, 119.89243),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '利润表', '非运算项目', 27, -1527.23486),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q3', '2018-09-30', '利润表', '营业额', 1, 1304.94049),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q3', '2018-09-30', '利润表', '营运收入', 2, 1304.94049),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q3', '2018-09-30', '利润表', '销售成本', 3, 1139.63252),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q3', '2018-09-30', '利润表', '毛利', 4, 165.30797),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q3', '2018-09-30', '利润表', '其他收入', 5, 6.24621),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q3', '2018-09-30', '利润表', '其他收益', 6, -0.58003),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q3', '2018-09-30', '利润表', '销售及分销费用', 7, 56.65445),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q3', '2018-09-30', '利润表', '行政开支', 8, 115.05489),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q3', '2018-09-30', '利润表', '重估盈余', 9, 23.55084),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q3', '2018-09-30', '利润表', '研发费用', 10, 40.01835),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q3', '2018-09-30', '利润表', '其他支出', 29, 2.96579),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q3', '2018-09-30', '利润表', '经营溢利', 11, -20.16849),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q3', '2018-09-30', '利润表', '利息收入', 12, 0.85554),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q3', '2018-09-30', '利润表', '溢利其他项目', 28, 125.14279),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q3', '2018-09-30', '利润表', '除税前溢利', 14, 105.82984),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q3', '2018-09-30', '利润表', '税项', 15, 4.97264),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q3', '2018-09-30', '利润表', '除税后溢利', 17, 100.8572),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q3', '2018-09-30', '利润表', '少数股东损益', 18, -0.59263),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q3', '2018-09-30', '利润表', '股东应占溢利', 19, 101.44983),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q3', '2018-09-30', '利润表', '每股基本盈利', 20, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q3', '2018-09-30', '利润表', '每股摊薄盈利', 21, -0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q3', '2018-09-30', '利润表', '其他全面收益其他项目', 22, -14.91879),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q3', '2018-09-30', '利润表', '其他全面收益', 23, -14.91879),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q3', '2018-09-30', '利润表', '全面收益总额', 24, 85.93841),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q3', '2018-09-30', '利润表', '非控股权益应占全面收益总额', 25, -0.5001),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q3', '2018-09-30', '利润表', '本公司拥有人应占全面收益总额', 26, 86.43851),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '利润表', '营业额', 1, 796.47835),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '利润表', '营运收入', 2, 796.47835),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '利润表', '销售成本', 3, 696.94596),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '利润表', '毛利', 4, 99.53239),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '利润表', '其他收入', 5, 3.65541),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '利润表', '其他收益', 6, 1.44324),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '利润表', '销售及分销费用', 7, 34.78538),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '利润表', '行政开支', 8, 109.22239),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '利润表', '重估盈余', 9, 22.89778),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '利润表', '研发费用', 10, 24.67394),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '利润表', '其他支出', 29, 1.12183),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '利润表', '经营溢利', 11, -42.27472),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '利润表', '利息收入', 12, -0.14496),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '利润表', '溢利其他项目', 28, 124.61345),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '利润表', '除税前溢利', 14, 82.19377),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '利润表', '税项', 15, 6.14141),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '利润表', '除税后溢利', 17, 76.05236),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '利润表', '少数股东损益', 18, -0.40959),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '利润表', '股东应占溢利', 19, 76.46195),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '利润表', '每股基本盈利', 20, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '利润表', '每股摊薄盈利', 21, -0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '利润表', '其他全面收益其他项目', 22, -17.6887),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '利润表', '其他全面收益', 23, -17.6887),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '利润表', '全面收益总额', 24, 58.36366),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '利润表', '非控股权益应占全面收益总额', 25, -0.39092),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '利润表', '本公司拥有人应占全面收益总额', 26, 58.75458),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q1', '2018-03-31', '利润表', '营业额', 1, 344.12362),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q1', '2018-03-31', '利润表', '营运收入', 2, 344.12362),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q1', '2018-03-31', '利润表', '销售成本', 3, 301.10935),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q1', '2018-03-31', '利润表', '毛利', 4, 43.01427),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q1', '2018-03-31', '利润表', '其他收入', 5, 1.58226),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q1', '2018-03-31', '利润表', '其他收益', 6, 1.13896),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q1', '2018-03-31', '利润表', '销售及分销费用', 7, 14.02829),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q1', '2018-03-31', '利润表', '行政开支', 8, 4.65323),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q1', '2018-03-31', '利润表', '重估盈余', 9, 17.62868),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q1', '2018-03-31', '利润表', '研发费用', 10, 11.03775),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q1', '2018-03-31', '利润表', '经营溢利', 11, 33.6449),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q1', '2018-03-31', '利润表', '利息收入', 12, 0.17834),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q1', '2018-03-31', '利润表', '溢利其他项目', 28, -100.71376),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q1', '2018-03-31', '利润表', '除税前溢利', 14, -66.89052),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q1', '2018-03-31', '利润表', '税项', 15, 3.38359),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q1', '2018-03-31', '利润表', '除税后溢利', 17, -70.27411),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q1', '2018-03-31', '利润表', '少数股东损益', 18, -0.22288),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q1', '2018-03-31', '利润表', '股东应占溢利', 19, -70.05123),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q1', '2018-03-31', '利润表', '每股基本盈利', 20, -0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q1', '2018-03-31', '利润表', '每股摊薄盈利', 21, -0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q1', '2018-03-31', '利润表', '其他全面收益其他项目', 22, 57.1089),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q1', '2018-03-31', '利润表', '其他全面收益', 23, 57.1089),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q1', '2018-03-31', '利润表', '全面收益总额', 24, -13.16521),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q1', '2018-03-31', '利润表', '非控股权益应占全面收益总额', 25, -0.27986),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q1', '2018-03-31', '利润表', '本公司拥有人应占全面收益总额', 26, -12.88535),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '利润表', '营业额', 1, 1146.24742),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '利润表', '营运收入', 2, 1146.24742),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '利润表', '销售成本', 3, 994.70537),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '利润表', '毛利', 4, 151.54205),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '利润表', '其他收入', 5, 4.48671),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '利润表', '其他收益', 6, 0.7204),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '利润表', '销售及分销费用', 7, 52.3154),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '利润表', '行政开支', 8, 12.1611),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '利润表', '重估盈余', 9, 63.71098),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '利润表', '研发费用', 10, 31.51401),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '利润表', '其他支出', 29, 2.31496),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '利润表', '经营溢利', 11, 122.15467),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '利润表', '利息收入', 12, 0.26784),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '利润表', '溢利其他项目', 28, -540.71603),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '利润表', '除税前溢利', 14, -418.29352),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '利润表', '税项', 15, 20.59763),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '利润表', '除税后溢利', 17, -438.89115),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '利润表', '少数股东损益', 18, -0.63099),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '利润表', '股东应占溢利', 19, -438.26016),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '利润表', '每股基本盈利', 20, -0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '利润表', '每股摊薄盈利', 21, -0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '利润表', '其他全面收益其他项目', 22, 78.94366),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '利润表', '其他全面收益', 23, 78.94366),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '利润表', '全面收益总额', 24, -359.94749),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '利润表', '非控股权益应占全面收益总额', 25, -0.72625),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '利润表', '本公司拥有人应占全面收益总额', 26, -359.22124),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q3', '2017-09-30', '利润表', '营业额', 1, 795.10682),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q3', '2017-09-30', '利润表', '营运收入', 2, 795.10682),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q3', '2017-09-30', '利润表', '销售成本', 3, 679.969),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q3', '2017-09-30', '利润表', '毛利', 4, 115.13782),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q3', '2017-09-30', '利润表', '其他收入', 5, 3.03123),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q3', '2017-09-30', '利润表', '其他收益', 6, 2.11732),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q3', '2017-09-30', '利润表', '销售及分销费用', 7, 33.17034),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q3', '2017-09-30', '利润表', '行政开支', 8, 7.65988),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q3', '2017-09-30', '利润表', '重估盈余', 9, 35.90472),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q3', '2017-09-30', '利润表', '研发费用', 10, 21.16787),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q3', '2017-09-30', '利润表', '其他支出', 29, 2.17747),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q3', '2017-09-30', '利润表', '经营溢利', 11, 92.01553),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q3', '2017-09-30', '利润表', '利息收入', 12, 0.10588),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q3', '2017-09-30', '利润表', '溢利其他项目', 28, -383.3831),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q3', '2017-09-30', '利润表', '除税前溢利', 14, -291.26169),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q3', '2017-09-30', '利润表', '税项', 15, 17.0009),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q3', '2017-09-30', '利润表', '除税后溢利', 17, -308.26259),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q3', '2017-09-30', '利润表', '少数股东损益', 18, -0.30009),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q3', '2017-09-30', '利润表', '股东应占溢利', 19, -307.9625),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q3', '2017-09-30', '利润表', '每股基本盈利', 20, -0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q3', '2017-09-30', '利润表', '每股摊薄盈利', 21, -0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q3', '2017-09-30', '利润表', '其他全面收益其他项目', 22, 56.0762),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q3', '2017-09-30', '利润表', '其他全面收益', 23, 56.0762),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q3', '2017-09-30', '利润表', '全面收益总额', 24, -252.18639),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q3', '2017-09-30', '利润表', '非控股权益应占全面收益总额', 25, -0.46835),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q3', '2017-09-30', '利润表', '本公司拥有人应占全面收益总额', 26, -251.71804),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q2', '2017-06-30', '利润表', '营业额', 1, 454.10802),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q2', '2017-06-30', '利润表', '营运收入', 2, 454.10802),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q2', '2017-06-30', '利润表', '销售成本', 3, 390.99053),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q2', '2017-06-30', '利润表', '毛利', 4, 63.11749),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q2', '2017-06-30', '利润表', '其他收入', 5, 1.97057),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q2', '2017-06-30', '利润表', '其他收益', 6, -0.10578),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q2', '2017-06-30', '利润表', '销售及分销费用', 7, 18.70371),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q2', '2017-06-30', '利润表', '行政开支', 8, 4.69048),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q2', '2017-06-30', '利润表', '重估盈余', 9, 29.18),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q2', '2017-06-30', '利润表', '研发费用', 10, 13.12),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q2', '2017-06-30', '利润表', '其他支出', 29, 1.51014),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q2', '2017-06-30', '利润表', '经营溢利', 11, 56.13795),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q2', '2017-06-30', '利润表', '融资成本', 13, 0.07641),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q2', '2017-06-30', '利润表', '溢利其他项目', 28, -244.68644),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q2', '2017-06-30', '利润表', '除税前溢利', 14, -188.6249),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q2', '2017-06-30', '利润表', '税项', 15, 9.711),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q2', '2017-06-30', '利润表', '除税后溢利', 17, -198.3359),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q2', '2017-06-30', '利润表', '少数股东损益', 18, -0.27148),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q2', '2017-06-30', '利润表', '股东应占溢利', 19, -198.06442),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q2', '2017-06-30', '利润表', '每股基本盈利', 20, -0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q2', '2017-06-30', '利润表', '每股摊薄盈利', 21, -0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q2', '2017-06-30', '利润表', '其他全面收益其他项目', 22, 28.47097),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q2', '2017-06-30', '利润表', '其他全面收益', 23, 28.47097),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q2', '2017-06-30', '利润表', '全面收益总额', 24, -169.86493),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q2', '2017-06-30', '利润表', '非控股权益应占全面收益总额', 25, -0.31191),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q2', '2017-06-30', '利润表', '本公司拥有人应占全面收益总额', 26, -169.55302),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q1', '2017-03-31', '利润表', '营业额', 1, 185.31793),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q1', '2017-03-31', '利润表', '营运收入', 2, 185.31793),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q1', '2017-03-31', '利润表', '销售成本', 3, 160.67675),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q1', '2017-03-31', '利润表', '毛利', 4, 24.64118),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q1', '2017-03-31', '利润表', '其他收入', 5, 0.24156),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q1', '2017-03-31', '利润表', '其他收益', 6, -0.75319),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q1', '2017-03-31', '利润表', '销售及分销费用', 7, 7.26857),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q1', '2017-03-31', '利润表', '行政开支', 8, 2.40209),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q1', '2017-03-31', '利润表', '重估盈余', 9, 11.797),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q1', '2017-03-31', '利润表', '研发费用', 10, 6.04689),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q1', '2017-03-31', '利润表', '其他支出', 29, 0.66404),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q1', '2017-03-31', '利润表', '经营溢利', 11, 19.54496),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q1', '2017-03-31', '利润表', '融资成本', 13, 0.12121),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q1', '2017-03-31', '利润表', '溢利其他项目', 28, -94.64478),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q1', '2017-03-31', '利润表', '除税前溢利', 14, -75.22103),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q1', '2017-03-31', '利润表', '税项', 15, 3.44915),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q1', '2017-03-31', '利润表', '除税后溢利', 17, -78.67018),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q1', '2017-03-31', '利润表', '少数股东损益', 18, -0.21127),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q1', '2017-03-31', '利润表', '股东应占溢利', 19, -78.45891),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q1', '2017-03-31', '利润表', '每股基本盈利', 20, -0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q1', '2017-03-31', '利润表', '每股摊薄盈利', 21, -0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q1', '2017-03-31', '利润表', '其他全面收益其他项目', 22, 5.84669),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q1', '2017-03-31', '利润表', '其他全面收益', 23, 5.84669),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q1', '2017-03-31', '利润表', '全面收益总额', 24, -72.82349),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q1', '2017-03-31', '利润表', '非控股权益应占全面收益总额', 25, -0.21567),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q1', '2017-03-31', '利润表', '本公司拥有人应占全面收益总额', 26, -72.60782),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '利润表', '营业额', 1, 684.34161),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '利润表', '营运收入', 2, 684.34161),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '利润表', '销售成本', 3, 611.84806),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '利润表', '毛利', 4, 72.49355),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '利润表', '其他收入', 5, 5.40493),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '利润表', '其他收益', 6, -5.2825),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '利润表', '销售及分销费用', 7, 30.22313),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '利润表', '行政开支', 8, 9.26833),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '利润表', '重估盈余', 9, 27.27283),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '利润表', '研发费用', 10, 21.04226),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '利润表', '其他支出', 29, 1.50445),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '利润表', '经营溢利', 11, 37.85064),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '利润表', '融资成本', 13, 0.86246),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '利润表', '溢利其他项目', 28, -25.23309),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '利润表', '除税前溢利', 14, 11.75509),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '利润表', '税项', 15, 6.83903),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '利润表', '除税后溢利', 17, 4.91606),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '利润表', '少数股东损益', 18, -0.61644),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '利润表', '股东应占溢利', 19, 5.5325),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '利润表', '每股基本盈利', 20, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '利润表', '每股摊薄盈利', 21, 0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '利润表', '其他全面收益其他项目', 22, -67.98761),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '利润表', '其他全面收益', 23, -67.98761),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '利润表', '全面收益总额', 24, -63.07155),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '利润表', '非控股权益应占全面收益总额', 25, -0.5268),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '利润表', '本公司拥有人应占全面收益总额', 26, -62.54475),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '利润表', '营业额', 1, 668.11258),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '利润表', '营运收入', 2, 668.11258),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '利润表', '销售成本', 3, 641.11325),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '利润表', '毛利', 4, 26.99933),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '利润表', '其他收入', 5, 5.22436),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '利润表', '其他收益', 6, -3.79439),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '利润表', '销售及分销费用', 7, 19.12765),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '利润表', '行政开支', 8, 7.66252),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '利润表', '重估盈余', 9, 28.13353),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '利润表', '研发费用', 10, 15.11815),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '利润表', '其他支出', 29, 0.92781),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '利润表', '经营溢利', 11, 13.7267),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '利润表', '融资成本', 13, 0.85867),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '利润表', '溢利其他项目', 28, -87.59314),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '利润表', '除税前溢利', 14, -74.72511),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '利润表', '税项', 15, 1.54519),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '利润表', '除税后溢利', 17, -76.2703),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '利润表', '少数股东损益', 18, -0.45735),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '利润表', '股东应占溢利', 19, -75.81295),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '利润表', '每股基本盈利', 20, -0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '利润表', '每股摊薄盈利', 21, -0.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '利润表', '其他全面收益其他项目', 22, -55.09097),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '利润表', '其他全面收益', 23, -55.09097),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '利润表', '全面收益总额', 24, -131.36127),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '利润表', '非控股权益应占全面收益总额', 25, -0.3731),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '利润表', '本公司拥有人应占全面收益总额', 26, -130.98817),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '现金流量表', '经营产生现金', 1, 86.60216),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '现金流量表', '已付税项', 2, 66.09982),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '现金流量表', '经营业务现金净额', 3, 20.50234),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '现金流量表', '已收利息(投资)', 4, 21.8063),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '现金流量表', '已收股息(投资)', 5, 0.5814),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '现金流量表', '存款减少(增加)', 6, 132.70339),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '现金流量表', '处置固定资产', 7, 0.03412),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '现金流量表', '购建固定资产', 8, 37.73539),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '现金流量表', '收回投资所得现金', 9, 311.77245),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '现金流量表', '投资支付现金', 10, 246.93563),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '现金流量表', '投资业务现金净额', 11, 182.22664),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '现金流量表', '融资前现金净额', 12, 202.72898),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '现金流量表', '新增借款', 13, 337.03538),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '现金流量表', '偿还借款', 14, 299.39415),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '现金流量表', '已付股息(融资)', 15, 13.68395),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '现金流量表', '吸收投资所得', 16, 6.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '现金流量表', '回购股份', 17, 96.85177),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '现金流量表', '偿还融资租赁', 18, 14.07339),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '现金流量表', '融资业务其他项目', 19, -16.07705),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '现金流量表', '融资业务现金净额', 20, -97.04493),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '现金流量表', '现金净额', 21, 105.68405),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '现金流量表', '期初现金', 22, 269.14377),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '现金流量表', '期间变动其他项目', 23, -2.30413),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q2', '2026-06-30', '现金流量表', '期末现金', 24, 372.52369),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '现金流量表', '经营业务现金净额', 3, -17.92),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '现金流量表', '投资业务现金净额', 11, 83.269),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '现金流量表', '融资前现金净额', 12, 65.349),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '现金流量表', '融资业务现金净额', 20, -70.593),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '现金流量表', '现金净额', 21, -5.244),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '现金流量表', '期初现金', 22, 269.144),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '现金流量表', '期间变动其他项目', 23, -0.555),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2026Q1', '2026-03-31', '现金流量表', '期末现金', 24, 263.345),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '现金流量表', '除税前溢利(业务利润)', 25, 496.46865),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '现金流量表', '减:利息收入', 26, 53.8068),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '现金流量表', '加:利息支出', 27, 36.34735),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '现金流量表', '减:投资收益', 28, 23.03028),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '现金流量表', '加:减值及拨备', 29, 68.40481),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '现金流量表', '减:重估盈余', 30, 133.11733),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '现金流量表', '减:出售资产之溢利', 31, 0.13739),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '现金流量表', '加:折旧及摊销', 32, 87.56747),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '现金流量表', '减:汇兑收益', 33, 0.95656),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '现金流量表', '加:经营调整其他项目', 34, 52.60464),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '现金流量表', '营运资金变动前经营溢利', 35, 530.34456),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '现金流量表', '存货(增加)减少', 36, -260.65762),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '现金流量表', '应收帐款减少', 37, 2.57988),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '现金流量表', '应付帐款及应计费用增加(减少)', 38, 119.2537),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '现金流量表', '营运资本变动其他项目', 39, 25.50726),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '现金流量表', '预付款项、按金及其他应收款项减少(增加)', 40, -20.76822),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '现金流量表', '预收账款、按金及其他应付款增加(减少)', 41, -8.46194),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '现金流量表', '贷款和垫款(增加)减少', 42, -4.75607),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '现金流量表', '存款(增加)减少', 43, 5.0981),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '现金流量表', '经营产生现金', 1, 388.13965),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '现金流量表', '已付税项', 2, 46.71588),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '现金流量表', '经营业务现金净额', 3, 341.42377),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '现金流量表', '已收利息(投资)', 4, 32.76391),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '现金流量表', '已收股息(投资)', 5, 3.70632),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '现金流量表', '存款减少(增加)', 6, -479.41363),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '现金流量表', '处置固定资产', 7, 0.12776),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '现金流量表', '购建固定资产', 8, 127.69155),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '现金流量表', '收回投资所得现金', 9, 780.41373),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '现金流量表', '投资支付现金', 10, 932.02423),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '现金流量表', '投资业务其他项目', 44, 5.33042),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '现金流量表', '投资业务现金净额', 11, -716.78727),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '现金流量表', '融资前现金净额', 12, -375.3635),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '现金流量表', '新增借款', 13, 303.78289),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '现金流量表', '偿还借款', 14, 250.8095),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '现金流量表', '已付股息(融资)', 15, 38.38507),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '现金流量表', '吸收投资所得', 16, 23.93914),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '现金流量表', '发行股份', 45, 392.25991),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '现金流量表', '回购股份', 17, 61.72545),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '现金流量表', '偿还融资租赁', 18, 29.02504),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '现金流量表', '融资业务其他项目', 19, -32.37824),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '现金流量表', '融资业务现金净额', 20, 307.65864),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '现金流量表', '现金净额', 21, -67.70486),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '现金流量表', '期初现金', 22, 336.61442),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '现金流量表', '期间变动其他项目', 23, 0.23421),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q4', '2025-12-31', '现金流量表', '期末现金', 24, 269.14377),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '现金流量表', '经营业务现金净额', 3, 335.2836),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '现金流量表', '投资业务现金净额', 11, -622.21104),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '现金流量表', '融资前现金净额', 12, -286.92744),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '现金流量表', '融资业务现金净额', 20, 305.18153),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '现金流量表', '现金净额', 21, 18.25409),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '现金流量表', '期初现金', 22, 336.61442),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '现金流量表', '期间变动其他项目', 23, 0.61106),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q3', '2025-09-30', '现金流量表', '期末现金', 24, 355.47957),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '现金流量表', '经营产生现金', 1, 320.08513),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '现金流量表', '已付税项', 2, 39.53773),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '现金流量表', '经营业务现金净额', 3, 280.5474),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '现金流量表', '已收利息(投资)', 4, 18.29829),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '现金流量表', '已收股息(投资)', 5, 1.80842),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '现金流量表', '存款减少(增加)', 6, -560.29958),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '现金流量表', '处置固定资产', 7, 0.07634),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '现金流量表', '购建固定资产', 8, 50.8594),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '现金流量表', '收回投资所得现金', 9, 507.10435),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '现金流量表', '投资支付现金', 10, 517.41481),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '现金流量表', '投资业务现金净额', 11, -601.28639),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '现金流量表', '融资前现金净额', 12, -320.73899),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '现金流量表', '新增借款', 13, 117.21938),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '现金流量表', '偿还借款', 14, 129.20591),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '现金流量表', '已付股息(融资)', 15, 19.91175),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '现金流量表', '吸收投资所得', 16, 10.82914),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '现金流量表', '发行股份', 45, 392.25991),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '现金流量表', '回购股份', 17, 2.07072),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '现金流量表', '偿还融资租赁', 18, 12.54754),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '现金流量表', '融资业务其他项目', 19, -12.22947),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '现金流量表', '融资业务现金净额', 20, 344.34304),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '现金流量表', '现金净额', 21, 23.60405),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '现金流量表', '期初现金', 22, 336.61442),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '现金流量表', '期间变动其他项目', 23, -0.13817),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q2', '2025-06-30', '现金流量表', '期末现金', 24, 360.0803),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '现金流量表', '经营业务现金净额', 3, 45.09497),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '现金流量表', '投资业务现金净额', 11, 99.20811),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '现金流量表', '融资前现金净额', 12, 144.30308),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '现金流量表', '融资业务现金净额', 20, 380.77395),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '现金流量表', '现金净额', 21, 525.07703),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '现金流量表', '期初现金', 22, 336.61442),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '现金流量表', '期间变动其他项目', 23, 0.02782),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025Q1', '2025-03-31', '现金流量表', '期末现金', 24, 861.71927),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '现金流量表', '除税前溢利(业务利润)', 25, 281.26653),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '现金流量表', '减:利息收入', 26, 38.36204),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '现金流量表', '加:利息支出', 27, 2.12447),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '现金流量表', '减:投资收益', 28, 9.34246),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '现金流量表', '加:减值及拨备', 29, 59.5852),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '现金流量表', '减:重估盈余', 30, 10.50772),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '现金流量表', '减:出售资产之溢利', 31, 0.09147),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '现金流量表', '加:折旧及摊销', 32, 63.18269),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '现金流量表', '减:汇兑收益', 33, -3.1963),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '现金流量表', '加:经营调整其他项目', 34, 36.62959),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '现金流量表', '营运资金变动前经营溢利', 35, 387.68109),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '现金流量表', '存货(增加)减少', 36, -241.31971),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '现金流量表', '应收帐款减少', 37, -83.87158),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '现金流量表', '应付帐款及应计费用增加(减少)', 38, 360.92511),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '现金流量表', '营运资本变动其他项目', 39, 12.00898),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '现金流量表', '预付款项、按金及其他应收款项减少(增加)', 40, -53.53379),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '现金流量表', '预收账款、按金及其他应付款增加(减少)', 41, 78.76262),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '现金流量表', '贷款和垫款(增加)减少', 42, -25.67194),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '现金流量表', '存款(增加)减少', 43, -7.35361),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '现金流量表', '经营产生现金', 1, 427.62717),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '现金流量表', '已付税项', 2, 34.67218),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '现金流量表', '经营业务现金净额', 3, 392.95499),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '现金流量表', '已收利息(投资)', 4, 36.46092),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '现金流量表', '已收股息(投资)', 5, 4.27139),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '现金流量表', '存款减少(增加)', 6, -234.46909),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '现金流量表', '处置固定资产', 7, 3.58488),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '现金流量表', '购建固定资产', 8, 72.97307),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '现金流量表', '处置无形资产及其他资产', 46, 15.44837),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '现金流量表', '收回投资所得现金', 9, 1076.38068),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '现金流量表', '投资支付现金', 10, 1183.6726),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '现金流量表', '投资业务其他项目', 44, 1.10461),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '现金流量表', '投资业务现金净额', 11, -353.86391),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '现金流量表', '融资前现金净额', 12, 39.09108),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '现金流量表', '新增借款', 13, 259.98066),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '现金流量表', '偿还借款', 14, 192.65488),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '现金流量表', '已付股息(融资)', 15, 17.90035),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '现金流量表', '吸收投资所得', 16, 20.53079),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '现金流量表', '回购股份', 17, 40.47876),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '现金流量表', '偿还融资租赁', 18, 24.76524),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '现金流量表', '购买子公司少数股权而支付的现金', 47, 0.75809),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '现金流量表', '融资业务其他项目', 19, -43.94389),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '现金流量表', '融资业务现金净额', 20, -39.98976),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '现金流量表', '现金净额', 21, -0.89868),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '现金流量表', '期初现金', 22, 336.31313),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '现金流量表', '期间变动其他项目', 23, 1.19997),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q4', '2024-12-31', '现金流量表', '期末现金', 24, 336.61442),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '现金流量表', '经营业务现金净额', 3, 153.88685),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '现金流量表', '投资业务现金净额', 11, -63.19313),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '现金流量表', '融资前现金净额', 12, 90.69372),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '现金流量表', '融资业务现金净额', 20, -30.99077),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '现金流量表', '现金净额', 21, 59.70295),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '现金流量表', '期初现金', 22, 336.31313),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '现金流量表', '期间变动其他项目', 23, 0.53746),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q3', '2024-09-30', '现金流量表', '期末现金', 24, 396.55354),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '现金流量表', '经营产生现金', 1, 50.21874),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '现金流量表', '已付税项', 2, 24.91299),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '现金流量表', '经营业务现金净额', 3, 25.30575),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '现金流量表', '已收利息(投资)', 4, 18.50478),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '现金流量表', '已收股息(投资)', 5, 1.23761),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '现金流量表', '存款减少(增加)', 6, 2.7615),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '现金流量表', '处置固定资产', 7, 2.54311),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '现金流量表', '购建固定资产', 8, 22.67908),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '现金流量表', '处置无形资产及其他资产', 46, 7.69837),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '现金流量表', '收回投资所得现金', 9, 369.20893),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '现金流量表', '投资支付现金', 10, 352.18444),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '现金流量表', '投资业务现金净额', 11, 27.09078),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '现金流量表', '融资前现金净额', 12, 52.39653),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '现金流量表', '新增借款', 13, 124.36649),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '现金流量表', '偿还借款', 14, 77.59247),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '现金流量表', '已付股息(融资)', 15, 5.8872),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '现金流量表', '吸收投资所得', 16, 15.40529),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '现金流量表', '回购股份', 17, 30.32539),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '现金流量表', '偿还融资租赁', 18, 6.98802),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '现金流量表', '融资业务其他项目', 19, -14.4257),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '现金流量表', '融资业务现金净额', 20, 4.553),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '现金流量表', '现金净额', 21, 56.94953),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '现金流量表', '期初现金', 22, 336.31313),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '现金流量表', '期间变动其他项目', 23, 0.09554),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q2', '2024-06-30', '现金流量表', '期末现金', 24, 393.3582),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '现金流量表', '经营业务现金净额', 3, -92.87058),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '现金流量表', '投资业务现金净额', 11, 107.10999),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '现金流量表', '融资前现金净额', 12, 14.23941),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '现金流量表', '融资业务现金净额', 20, -1.11044),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '现金流量表', '现金净额', 21, 13.12897),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '现金流量表', '期初现金', 22, 336.31313),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '现金流量表', '期间变动其他项目', 23, -0.47999),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024Q1', '2024-03-31', '现金流量表', '期末现金', 24, 348.96211),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '现金流量表', '除税前溢利(业务利润)', 25, 220.11047),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '现金流量表', '减:利息收入', 26, 35.58347),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '现金流量表', '加:利息支出', 27, 15.5597),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '现金流量表', '减:投资收益', 28, 2.03184),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '现金流量表', '加:减值及拨备', 29, 41.90419),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '现金流量表', '减:重估盈余', 30, 35.01053),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '现金流量表', '减:出售资产之溢利', 31, 15.92633),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '现金流量表', '加:折旧及摊销', 32, 48.36287),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '现金流量表', '减:汇兑收益', 33, 1.24405),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '现金流量表', '加:经营调整其他项目', 34, 33.7867),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '现金流量表', '营运资金变动前经营溢利', 35, 269.92771),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '现金流量表', '存货(增加)减少', 36, 21.73795),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '现金流量表', '应收帐款减少', 37, -16.52782),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '现金流量表', '应付帐款及应计费用增加(减少)', 38, 111.47623),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '现金流量表', '营运资本变动其他项目', 39, 35.92484),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '现金流量表', '预付款项、按金及其他应收款项减少(增加)', 40, 16.00556),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '现金流量表', '预收账款、按金及其他应付款增加(减少)', 41, 31.01149),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '现金流量表', '贷款和垫款(增加)减少', 42, -19.83565),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '现金流量表', '存款(增加)减少', 43, -6.59788),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '现金流量表', '经营产生现金', 1, 443.12243),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '现金流量表', '已付税项', 2, 30.11748),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '现金流量表', '经营业务现金净额', 3, 413.00495),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '现金流量表', '已收利息(投资)', 4, 32.58117),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '现金流量表', '已收股息(投资)', 5, 1.97583),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '现金流量表', '存款减少(增加)', 6, -235.61379),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '现金流量表', '处置固定资产', 7, 0.72833),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '现金流量表', '购建固定资产', 8, 62.689),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '现金流量表', '出售附属公司', 48, 1.01294),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '现金流量表', '收回投资所得现金', 9, 532.36781),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '现金流量表', '投资支付现金', 10, 621.87239),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '现金流量表', '投资业务其他项目', 44, -0.18144),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '现金流量表', '投资业务现金净额', 11, -351.69054),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '现金流量表', '融资前现金净额', 12, 61.31441),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '现金流量表', '新增借款', 13, 88.66088),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '现金流量表', '偿还借款', 14, 40.22423),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '现金流量表', '已付股息(融资)', 15, 28.84215),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '现金流量表', '吸收投资所得', 16, 14.17086),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '现金流量表', '回购股份', 17, 13.56825),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '现金流量表', '偿还融资租赁', 18, 11.97692),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '现金流量表', '融资业务其他项目', 19, -13.26991),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '现金流量表', '融资业务现金净额', 20, -5.04972),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '现金流量表', '现金净额', 21, 56.26469),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '现金流量表', '期初现金', 22, 276.07261),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '现金流量表', '期间变动其他项目', 23, 3.97583),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q4', '2023-12-31', '现金流量表', '期末现金', 24, 336.31313),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '现金流量表', '经营业务现金净额', 3, 334.89982),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '现金流量表', '投资业务现金净额', 11, -293.21565),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '现金流量表', '融资前现金净额', 12, 41.68417),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '现金流量表', '融资业务现金净额', 20, -5.48255),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '现金流量表', '现金净额', 21, 36.20162),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '现金流量表', '期初现金', 22, 276.07261),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '现金流量表', '期间变动其他项目', 23, 4.25143),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q3', '2023-09-30', '现金流量表', '期末现金', 24, 316.52566),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '现金流量表', '经营产生现金', 1, 214.30534),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '现金流量表', '已付税项', 2, 12.68523),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '现金流量表', '经营业务现金净额', 3, 201.62011),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '现金流量表', '已收利息(投资)', 4, 15.19206),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '现金流量表', '已收股息(投资)', 5, 1.25767),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '现金流量表', '存款减少(增加)', 6, -89.15372),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '现金流量表', '处置固定资产', 7, 0.61112),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '现金流量表', '购建固定资产', 8, 37.22137),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '现金流量表', '收回投资所得现金', 9, 236.36469),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '现金流量表', '投资支付现金', 10, 271.97242),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '现金流量表', '投资业务现金净额', 11, -144.92197),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '现金流量表', '融资前现金净额', 12, 56.69814),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '现金流量表', '新增借款', 13, 8.98693),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '现金流量表', '偿还借款', 14, 14.02063),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '现金流量表', '已付股息(融资)', 15, 10.53866),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '现金流量表', '吸收投资所得', 16, 4.67578),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '现金流量表', '回购股份', 17, 4.39006),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '现金流量表', '偿还融资租赁', 18, 5.89078),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '现金流量表', '融资业务其他项目', 19, -1.68954),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '现金流量表', '融资业务现金净额', 20, -22.86696),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '现金流量表', '现金净额', 21, 33.83118),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '现金流量表', '期初现金', 22, 276.07261),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '现金流量表', '期间变动其他项目', 23, 4.68573),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q2', '2023-06-30', '现金流量表', '期末现金', 24, 314.58952),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '现金流量表', '经营业务现金净额', 3, 12.18761),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '现金流量表', '投资业务现金净额', 11, -16.22151),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '现金流量表', '融资前现金净额', 12, -4.0339),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '现金流量表', '融资业务现金净额', 20, -8.66848),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '现金流量表', '现金净额', 21, -12.70238),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '现金流量表', '期初现金', 22, 276.07261),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '现金流量表', '期间变动其他项目', 23, -1.56071),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023Q1', '2023-03-31', '现金流量表', '期末现金', 24, 261.80952),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '现金流量表', '除税前溢利(业务利润)', 25, 39.33956),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '现金流量表', '减:利息收入', 26, 16.63941),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '现金流量表', '加:利息支出', 27, 5.46483),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '现金流量表', '减:投资收益', 28, -1.47491),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '现金流量表', '加:减值及拨备', 29, 84.63389),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '现金流量表', '减:重估盈余', 30, -16.6201),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '现金流量表', '减:出售资产之溢利', 31, 0.07345),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '现金流量表', '加:折旧及摊销', 32, 37.07393),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '现金流量表', '减:汇兑收益', 33, -9.98602),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '现金流量表', '加:经营调整其他项目', 34, 24.97358),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '现金流量表', '营运资金变动前经营溢利', 35, 202.85396),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '现金流量表', '存货(增加)减少', 36, -54.4899),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '现金流量表', '应收帐款减少', 37, 43.46873),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '现金流量表', '应付帐款及应计费用增加(减少)', 38, -205.14286),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '现金流量表', '营运资本变动其他项目', 39, 13.53124),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '现金流量表', '预付款项、按金及其他应收款项减少(增加)', 40, 17.43564),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '现金流量表', '预收账款、按金及其他应付款增加(减少)', 41, -5.40598),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '现金流量表', '贷款和垫款(增加)减少', 42, -25.45224),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '现金流量表', '存款(增加)减少', 43, 3.50688),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '现金流量表', '经营产生现金', 1, -9.69453),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '现金流量表', '已付税项', 2, 34.20277),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '现金流量表', '经营业务现金净额', 3, -43.8973),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '现金流量表', '已收利息(投资)', 4, 13.019),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '现金流量表', '已收股息(投资)', 5, 2.01561),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '现金流量表', '存款减少(增加)', 6, 22.72482),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '现金流量表', '处置固定资产', 7, 0.17334),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '现金流量表', '购建固定资产', 8, 57.9957),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '现金流量表', '收购附属公司', 49, 0.25106),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '现金流量表', '收回投资所得现金', 9, 995.67147),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '现金流量表', '投资支付现金', 10, 819.86975),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '现金流量表', '投资业务现金净额', 11, 155.48773),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '现金流量表', '融资前现金净额', 12, 111.59043),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '现金流量表', '新增借款', 13, 198.57851),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '现金流量表', '偿还借款', 14, 236.55586),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '现金流量表', '已付股息(融资)', 15, 2.55576),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '现金流量表', '吸收投资所得', 16, 8.06),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '现金流量表', '回购股份', 17, 23.86143),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '现金流量表', '偿还融资租赁', 18, 12.81785),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '现金流量表', '融资业务其他项目', 19, -9.3956),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '现金流量表', '融资业务现金净额', 20, -78.54799),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '现金流量表', '现金净额', 21, 33.04244),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '现金流量表', '期初现金', 22, 235.11579),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '现金流量表', '期间变动其他项目', 23, 7.91438),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q4', '2022-12-31', '现金流量表', '期末现金', 24, 276.07261),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '现金流量表', '经营业务现金净额', 3, -85.01936),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '现金流量表', '投资业务现金净额', 11, 162.56913),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '现金流量表', '融资前现金净额', 12, 77.54977),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '现金流量表', '融资业务现金净额', 20, -42.37818),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '现金流量表', '现金净额', 21, 35.17159),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '现金流量表', '期初现金', 22, 235.11579),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '现金流量表', '期间变动其他项目', 23, 10.42361),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q3', '2022-09-30', '现金流量表', '期末现金', 24, 280.71099),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '现金流量表', '经营产生现金', 1, -51.18325),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '现金流量表', '已付税项', 2, 19.13099),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '现金流量表', '经营业务现金净额', 3, -70.31424),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '现金流量表', '已收利息(投资)', 4, 4.45399),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '现金流量表', '已收股息(投资)', 5, 0.92511),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '现金流量表', '存款减少(增加)', 6, 6.95355),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '现金流量表', '处置固定资产', 7, 0.14608),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '现金流量表', '购建固定资产', 8, 27.1728),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '现金流量表', '收回投资所得现金', 9, 601.28179),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '现金流量表', '投资支付现金', 10, 510.31414),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '现金流量表', '投资业务现金净额', 11, 76.27358),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '现金流量表', '融资前现金净额', 12, 5.95934),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '现金流量表', '新增借款', 13, 154.2536),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '现金流量表', '偿还借款', 14, 102.02349),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '现金流量表', '吸收投资所得', 16, 5.367),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '现金流量表', '回购股份', 17, 10.38588),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '现金流量表', '偿还融资租赁', 18, 6.69994),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '现金流量表', '融资业务其他项目', 19, -4.17353),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '现金流量表', '融资业务现金净额', 20, 36.33776),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '现金流量表', '现金净额', 21, 42.2971),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '现金流量表', '期初现金', 22, 235.11579),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '现金流量表', '期间变动其他项目', 23, 4.41813),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q2', '2022-06-30', '现金流量表', '期末现金', 24, 281.83102),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '现金流量表', '经营业务现金净额', 3, -86.80606),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '现金流量表', '投资业务现金净额', 11, 175.69436),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '现金流量表', '融资前现金净额', 12, 88.8883),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '现金流量表', '融资业务现金净额', 20, 23.51588),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '现金流量表', '现金净额', 21, 112.40418),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '现金流量表', '期初现金', 22, 235.11579),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '现金流量表', '期间变动其他项目', 23, -0.37833),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022Q1', '2022-03-31', '现金流量表', '期末现金', 24, 347.14164),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '现金流量表', '除税前溢利(业务利润)', 25, 244.17033),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '现金流量表', '减:利息收入', 26, 12.29826),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '现金流量表', '加:利息支出', 27, 28.41457),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '现金流量表', '减:投资收益', 28, 26.34379),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '现金流量表', '加:减值及拨备', 29, 67.05299),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '现金流量表', '减:重估盈余', 30, 77.22876),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '现金流量表', '减:出售资产之溢利', 31, 0.04336),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '现金流量表', '加:折旧及摊销', 32, 30.61646),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '现金流量表', '减:汇兑收益', 33, -4.83287),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '现金流量表', '加:经营调整其他项目', 34, 20.35569),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '现金流量表', '营运资金变动前经营溢利', 35, 279.52874),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '现金流量表', '存货(增加)减少', 36, -137.46697),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '现金流量表', '应收帐款减少', 37, -75.48686),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '现金流量表', '应付帐款及应计费用增加(减少)', 38, 24.56421),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '现金流量表', '营运资本变动其他项目', 39, 14.14983),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '现金流量表', '预付款项、按金及其他应收款项减少(增加)', 40, -70.83938),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '现金流量表', '预收账款、按金及其他应付款增加(减少)', 41, 40.68696),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '现金流量表', '贷款和垫款(增加)减少', 42, 37.06922),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '现金流量表', '存款(增加)减少', 43, 10.07208),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '现金流量表', '经营产生现金', 1, 122.27783),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '现金流量表', '已付税项', 2, 24.42495),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '现金流量表', '经营业务现金净额', 3, 97.85288),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '现金流量表', '已收利息(投资)', 4, 12.2883),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '现金流量表', '已收股息(投资)', 5, 2.29612),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '现金流量表', '存款减少(增加)', 6, -222.78586),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '现金流量表', '处置固定资产', 7, 0.35365),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '现金流量表', '购建固定资产', 8, 71.69313),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '现金流量表', '收购附属公司', 49, 10.86477),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '现金流量表', '收回投资所得现金', 9, 1721.57374),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '现金流量表', '投资支付现金', 10, 1881.2475),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '现金流量表', '投资业务现金净额', 11, -450.07945),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '现金流量表', '融资前现金净额', 12, -352.22657),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '现金流量表', '新增借款', 13, 225.28578),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '现金流量表', '偿还借款', 14, 133.01236),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '现金流量表', '吸收投资所得', 16, 34.71),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '现金流量表', '回购股份', 17, 70.06824),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '现金流量表', '偿还融资租赁', 18, 11.15859),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '现金流量表', '受限制存款及现金增加(减少)', 50, 5.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '现金流量表', '融资业务其他项目', 19, -5.76973),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '现金流量表', '融资业务现金净额', 20, 44.98686),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '现金流量表', '现金净额', 21, -307.23971),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '现金流量表', '期初现金', 22, 547.52443),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '现金流量表', '期间变动其他项目', 23, -5.16893),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q4', '2021-12-31', '现金流量表', '期末现金', 24, 235.11579),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '现金流量表', '经营业务现金净额', 3, -19.46374),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '现金流量表', '投资业务现金净额', 11, -249.36419),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '现金流量表', '融资前现金净额', 12, -268.82793),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '现金流量表', '融资业务现金净额', 20, 50.48736),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '现金流量表', '现金净额', 21, -218.34057),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '现金流量表', '期初现金', 22, 547.52443),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '现金流量表', '期间变动其他项目', 23, -2.68884),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q3', '2021-09-30', '现金流量表', '期末现金', 24, 326.49502),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '现金流量表', '经营产生现金', 1, 95.33448),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '现金流量表', '已付税项', 2, 12.49124),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '现金流量表', '经营业务现金净额', 3, 82.84324),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '现金流量表', '已收利息(投资)', 4, 5.42012),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '现金流量表', '已收股息(投资)', 5, 1.88327),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '现金流量表', '存款减少(增加)', 6, -210.09718),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '现金流量表', '处置固定资产', 7, 0.07237),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '现金流量表', '购建固定资产', 8, 18.28851),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '现金流量表', '收回投资所得现金', 9, 1041.0158),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '现金流量表', '投资支付现金', 10, 1139.87916),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '现金流量表', '投资业务现金净额', 11, -319.87329),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '现金流量表', '融资前现金净额', 12, -237.03005),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '现金流量表', '新增借款', 13, 74.60286),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '现金流量表', '偿还借款', 14, 54.4771),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '现金流量表', '吸收投资所得', 16, 33.71),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '现金流量表', '回购股份', 17, 41.65454),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '现金流量表', '偿还融资租赁', 18, 4.1369),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '现金流量表', '受限制存款及现金增加(减少)', 50, 5.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '现金流量表', '融资业务其他项目', 19, -2.34342),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '现金流量表', '融资业务现金净额', 20, 10.7009),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '现金流量表', '现金净额', 21, -226.32915),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '现金流量表', '期初现金', 22, 547.52443),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '现金流量表', '期间变动其他项目', 23, -2.38488),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q2', '2021-06-30', '现金流量表', '期末现金', 24, 318.8104),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '现金流量表', '经营业务现金净额', 3, 14.53986),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '现金流量表', '投资业务现金净额', 11, -255.46673),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '现金流量表', '融资业务现金净额', 20, 35.83567),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '现金流量表', '现金净额', 21, -205.0912),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '现金流量表', '期初现金', 22, 547.52443),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '现金流量表', '期间变动其他项目', 23, 0.36183),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021Q1', '2021-03-31', '现金流量表', '期末现金', 24, 342.79506),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '现金流量表', '除税前溢利(业务利润)', 25, 216.33432),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '现金流量表', '减:利息收入', 26, 9.63555),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '现金流量表', '加:利息支出', 27, 33.64852),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '现金流量表', '减:投资收益', 28, 17.42322),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '现金流量表', '加:减值及拨备', 29, 56.69207),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '现金流量表', '减:重估盈余', 30, 131.73479),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '现金流量表', '减:出售资产之溢利', 31, 0.06475),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '现金流量表', '加:折旧及摊销', 32, 17.08461),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '现金流量表', '减:汇兑收益', 33, -6.93222),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '现金流量表', '加:经营调整其他项目', 34, 23.28319),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '现金流量表', '营运资金变动前经营溢利', 35, 195.11662),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '现金流量表', '存货(增加)减少', 36, -116.02421),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '现金流量表', '应收帐款减少', 37, -42.72814),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '现金流量表', '应付帐款及应计费用增加(减少)', 38, 103.41399),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '现金流量表', '营运资本变动其他项目', 39, 6.08647),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '现金流量表', '预付款项、按金及其他应收款项减少(增加)', 40, 73.90455),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '现金流量表', '预收账款、按金及其他应付款增加(减少)', 41, 35.34327),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '现金流量表', '贷款和垫款(增加)减少', 42, 7.27548),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '现金流量表', '存款(增加)减少', 43, -24.07001),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '现金流量表', '经营产生现金', 1, 238.31802),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '现金流量表', '已付税项', 2, 19.53302),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '现金流量表', '经营业务现金净额', 3, 218.785),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '现金流量表', '已收利息(投资)', 4, 10.52389),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '现金流量表', '已收股息(投资)', 5, 1.19612),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '现金流量表', '存款减少(增加)', 6, -54.56293),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '现金流量表', '处置固定资产', 7, 0.63088),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '现金流量表', '购建固定资产', 8, 30.25523),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '现金流量表', '收购附属公司', 49, -0.38517),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '现金流量表', '收回投资所得现金', 9, 1957.70505),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '现金流量表', '投资支付现金', 10, 2062.41147),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '现金流量表', '投资业务现金净额', 11, -176.78852),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '现金流量表', '融资前现金净额', 12, 41.99648),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '现金流量表', '新增借款', 13, 305.82175),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '现金流量表', '偿还借款', 14, 325.86382),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '现金流量表', '吸收投资所得', 16, 34.29),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '现金流量表', '发行股份', 45, 199.07936),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '现金流量表', '回购股份', 17, 4.54872),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '现金流量表', '发行债券', 51, 58.01022),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '现金流量表', '偿还融资租赁', 18, 4.93899),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '现金流量表', '受限制存款及现金增加(减少)', 50, 2.75823),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '现金流量表', '融资业务其他项目', 19, -2.45235),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '现金流量表', '融资业务现金净额', 20, 262.15568),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '现金流量表', '现金净额', 21, 304.15216),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '现金流量表', '期初现金', 22, 259.19861),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '现金流量表', '期间变动其他项目', 23, -15.82634),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q4', '2020-12-31', '现金流量表', '期末现金', 24, 547.52443),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q3', '2020-09-30', '现金流量表', '经营业务现金净额', 3, 83.50998),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q3', '2020-09-30', '现金流量表', '投资业务现金净额', 11, -71.73063),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q3', '2020-09-30', '现金流量表', '融资业务现金净额', 20, 38.39898),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q3', '2020-09-30', '现金流量表', '现金净额', 21, 50.17833),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q3', '2020-09-30', '现金流量表', '期初现金', 22, 259.19861),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q3', '2020-09-30', '现金流量表', '期间变动其他项目', 23, -6.79982),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q3', '2020-09-30', '现金流量表', '期末现金', 24, 302.57712),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '现金流量表', '经营产生现金', 1, -25.92853),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '现金流量表', '已付税项', 2, 13.33394),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '现金流量表', '经营业务现金净额', 3, -39.26247),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '现金流量表', '已收利息(投资)', 4, 6.01361),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '现金流量表', '已收股息(投资)', 5, 0.39765),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '现金流量表', '存款减少(增加)', 6, -8.56072),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '现金流量表', '处置固定资产', 7, 0.04368),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '现金流量表', '购建固定资产', 8, 11.29238),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '现金流量表', '收回投资所得现金', 9, 559.19),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '现金流量表', '投资支付现金', 10, 587.90944),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '现金流量表', '投资业务现金净额', 11, -42.1176),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '现金流量表', '融资前现金净额', 12, -81.38007),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '现金流量表', '新增借款', 13, 175.82749),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '现金流量表', '偿还借款', 14, 122.4576),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '现金流量表', '吸收投资所得', 16, 0.31),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '现金流量表', '回购股份', 17, 4.54872),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '现金流量表', '偿还融资租赁', 18, 2.57022),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '现金流量表', '受限制存款及现金增加(减少)', 50, 1.70049),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '现金流量表', '融资业务其他项目', 19, -0.3277),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '现金流量表', '融资业务现金净额', 20, 47.93374),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '现金流量表', '现金净额', 21, -33.44633),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '现金流量表', '期初现金', 22, 259.19861),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '现金流量表', '期间变动其他项目', 23, 2.68088),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q2', '2020-06-30', '现金流量表', '期末现金', 24, 228.43316),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q1', '2020-03-31', '现金流量表', '经营业务现金净额', 3, -82.05339),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q1', '2020-03-31', '现金流量表', '投资业务现金净额', 11, 82.10391),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q1', '2020-03-31', '现金流量表', '融资业务现金净额', 20, -12.31329),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q1', '2020-03-31', '现金流量表', '现金净额', 21, -12.26277),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q1', '2020-03-31', '现金流量表', '期初现金', 22, 259.19861),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q1', '2020-03-31', '现金流量表', '期间变动其他项目', 23, 3.80103),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020Q1', '2020-03-31', '现金流量表', '期末现金', 24, 250.73687),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '现金流量表', '除税前溢利(业务利润)', 25, 121.62646),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '现金流量表', '减:利息收入', 26, 9.30889),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '现金流量表', '加:利息支出', 27, 5.2846),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '现金流量表', '减:投资收益', 28, 0.61844),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '现金流量表', '加:减值及拨备', 29, 49.58651),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '现金流量表', '减:重估盈余', 30, 38.13012),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '现金流量表', '减:出售资产之溢利', 31, -0.07467),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '现金流量表', '加:折旧及摊销', 32, 13.81059),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '现金流量表', '减:汇兑收益', 33, 0.34632),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '现金流量表', '加:经营调整其他项目', 34, 22.01722),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '现金流量表', '营运资金变动前经营溢利', 35, 163.99628),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '现金流量表', '存货(增加)减少', 36, -69.64428),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '现金流量表', '应收帐款减少', 37, -12.76714),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '现金流量表', '应付帐款及应计费用增加(减少)', 38, 135.34575),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '现金流量表', '营运资本变动其他项目', 39, 10.83496),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '现金流量表', '预付款项、按金及其他应收款项减少(增加)', 40, 57.1533),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '现金流量表', '预收账款、按金及其他应付款增加(减少)', 41, 10.45058),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '现金流量表', '贷款和垫款(增加)减少', 42, -34.48312),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '现金流量表', '存款(增加)减少', 43, -1.36394),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '现金流量表', '经营产生现金', 1, 259.52239),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '现金流量表', '已付税项', 2, 21.41885),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '现金流量表', '经营业务现金净额', 3, 238.10354),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '现金流量表', '已收利息(投资)', 4, 8.64226),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '现金流量表', '已收股息(投资)', 5, 3.47205),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '现金流量表', '存款减少(增加)', 6, -207.93124),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '现金流量表', '处置固定资产', 7, 0.67735),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '现金流量表', '购建固定资产', 8, 34.05163),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '现金流量表', '收回投资所得现金', 9, 1299.45237),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '现金流量表', '投资支付现金', 10, 1385.96252),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '现金流量表', '投资业务现金净额', 11, -315.70136),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '现金流量表', '融资前现金净额', 12, -77.59782),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '现金流量表', '新增借款', 13, 170.36724),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '现金流量表', '偿还借款', 14, 104.17425),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '现金流量表', '吸收投资所得', 16, 1.55496),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '现金流量表', '回购股份', 17, 29.32111),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '现金流量表', '偿还融资租赁', 18, 5.78063),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '现金流量表', '受限制存款及现金增加(减少)', 50, 0.75773),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '现金流量表', '购买子公司少数股权而支付的现金', 47, 1.87),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '现金流量表', '融资业务其他项目', 19, -0.32156),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '现金流量表', '融资业务现金净额', 20, 31.21238),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '现金流量表', '现金净额', 21, -46.38544),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '现金流量表', '期初现金', 22, 302.30147),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '现金流量表', '期间变动其他项目', 23, 3.28258),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q4', '2019-12-31', '现金流量表', '期末现金', 24, 259.19861),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q3', '2019-09-30', '现金流量表', '经营业务现金净额', 3, 139.08001),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q3', '2019-09-30', '现金流量表', '投资业务现金净额', 11, -117.68862),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q3', '2019-09-30', '现金流量表', '融资前现金净额', 12, 21.39139),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q3', '2019-09-30', '现金流量表', '融资业务现金净额', 20, 25.76968),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q3', '2019-09-30', '现金流量表', '现金净额', 21, 47.16107),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q3', '2019-09-30', '现金流量表', '期初现金', 22, 302.30147),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q3', '2019-09-30', '现金流量表', '期间变动其他项目', 23, 5.9291),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q3', '2019-09-30', '现金流量表', '期末现金', 24, 355.39164),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '现金流量表', '经营产生现金', 1, 119.77895),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '现金流量表', '已付税项', 2, 10.62471),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '现金流量表', '经营业务现金净额', 3, 109.15424),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '现金流量表', '已收利息(投资)', 4, 4.39415),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '现金流量表', '已收股息(投资)', 5, 1.24284),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '现金流量表', '存款减少(增加)', 6, -12.85477),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '现金流量表', '处置固定资产', 7, 0.63469),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '现金流量表', '购建固定资产', 8, 14.8478),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '现金流量表', '收回投资所得现金', 9, 527.06734),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '现金流量表', '投资支付现金', 10, 585.94199),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '现金流量表', '投资业务现金净额', 11, -80.30554),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '现金流量表', '融资前现金净额', 12, 28.8487),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '现金流量表', '新增借款', 13, 64.0067),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '现金流量表', '偿还借款', 14, 35.68042),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '现金流量表', '吸收投资所得', 16, 1.55496),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '现金流量表', '发行股份', 45, 4.64124),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '现金流量表', '回购股份', 17, 9.8291),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '现金流量表', '偿还融资租赁', 18, 2.93517),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '现金流量表', '受限制存款及现金增加(减少)', 50, 0.00095),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '现金流量表', '购买子公司少数股权而支付的现金', 47, 1.674),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '现金流量表', '融资业务其他项目', 19, -1.16517),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '现金流量表', '融资业务现金净额', 20, 18.91999),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '现金流量表', '现金净额', 21, 47.76869),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '现金流量表', '期初现金', 22, 302.30147),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '现金流量表', '期间变动其他项目', 23, -0.85988),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q2', '2019-06-30', '现金流量表', '期末现金', 24, 349.21028),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q1', '2019-03-31', '现金流量表', '经营业务现金净额', 3, -1.17783),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q1', '2019-03-31', '现金流量表', '投资业务现金净额', 11, -23.72212),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q1', '2019-03-31', '现金流量表', '融资业务现金净额', 20, -4.85696),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q1', '2019-03-31', '现金流量表', '现金净额', 21, -29.75691),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q1', '2019-03-31', '现金流量表', '期初现金', 22, 302.30147),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q1', '2019-03-31', '现金流量表', '期间变动其他项目', 23, -7.81325),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019Q1', '2019-03-31', '现金流量表', '期末现金', 24, 264.73131),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '现金流量表', '除税前溢利(业务利润)', 25, 139.27124),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '现金流量表', '减:利息收入', 26, 6.01065),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '现金流量表', '加:利息支出', 27, 3.84692),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '现金流量表', '减:投资收益', 28, -0.99046),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '现金流量表', '加:减值及拨备', 29, 36.46916),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '现金流量表', '减:重估盈余', 30, 170.71252),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '现金流量表', '减:出售资产之溢利', 31, 0.10295),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '现金流量表', '加:折旧及摊销', 32, 7.48216),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '现金流量表', '减:汇兑收益', 33, -0.1455),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '现金流量表', '加:经营调整其他项目', 34, 123.80668),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '现金流量表', '营运资金变动前经营溢利', 35, 135.186),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '现金流量表', '存货(增加)减少', 36, -161.14975),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '现金流量表', '应收帐款减少', 37, -0.91003),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '现金流量表', '应付帐款及应计费用增加(减少)', 38, 126.27385),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '现金流量表', '营运资本变动其他项目', 39, 2.29297),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '现金流量表', '预付款项、按金及其他应收款项减少(增加)', 40, -84.13008),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '现金流量表', '预收账款、按金及其他应付款增加(减少)', 41, 11.18058),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '现金流量表', '贷款和垫款(增加)减少', 42, -27.52183),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '现金流量表', '经营产生现金', 1, 1.22171),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '现金流量表', '已付税项', 2, 15.36742),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '现金流量表', '经营业务现金净额', 3, -14.14571),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '现金流量表', '已收利息(投资)', 4, 4.89816),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '现金流量表', '已收股息(投资)', 5, 1.31804),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '现金流量表', '存款减少(增加)', 6, -11.57295),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '现金流量表', '处置固定资产', 7, 0.27367),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '现金流量表', '购建固定资产', 8, 37.85259),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '现金流量表', '出售附属公司', 48, -0.25655),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '现金流量表', '收购附属公司', 49, 0.34936),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '现金流量表', '收回投资所得现金', 9, 1440.94865),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '现金流量表', '投资支付现金', 10, 1472.48747),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '现金流量表', '投资业务现金净额', 11, -75.0804),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '现金流量表', '融资前现金净额', 12, -89.22611),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '现金流量表', '新增借款', 13, 102.69415),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '现金流量表', '偿还借款', 14, 105.05637),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '现金流量表', '吸收投资所得', 16, 27.81),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '现金流量表', '发行股份', 45, 233.40587),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '现金流量表', '受限制存款及现金增加(减少)', 50, 9.069),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '现金流量表', '购买子公司少数股权而支付的现金', 47, 1.65),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '现金流量表', '融资业务其他项目', 19, -0.53093),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '现金流量表', '融资业务现金净额', 20, 265.74172),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '现金流量表', '现金净额', 21, 176.51561),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '现金流量表', '期初现金', 22, 115.63282),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '现金流量表', '期间变动其他项目', 23, 10.15304),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q4', '2018-12-31', '现金流量表', '期末现金', 24, 302.30147),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q3', '2018-09-30', '现金流量表', '经营业务现金净额', 3, 47.86246),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q3', '2018-09-30', '现金流量表', '投资业务现金净额', 11, -60.53909),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q3', '2018-09-30', '现金流量表', '融资前现金净额', 12, -12.67663),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q3', '2018-09-30', '现金流量表', '融资业务现金净额', 20, 241.9563),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q3', '2018-09-30', '现金流量表', '现金净额', 21, 229.27967),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q3', '2018-09-30', '现金流量表', '期初现金', 22, 115.63282),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q3', '2018-09-30', '现金流量表', '期间变动其他项目', 23, 7.17544),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q3', '2018-09-30', '现金流量表', '期末现金', 24, 352.08793),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '现金流量表', '经营产生现金', 1, 70.5013),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '现金流量表', '已付税项', 2, 9.28587),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '现金流量表', '经营业务现金净额', 3, 61.21543),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '现金流量表', '已收利息(投资)', 4, 2.01874),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '现金流量表', '已收股息(投资)', 5, 1.19975),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '现金流量表', '存款减少(增加)', 6, 2.03102),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '现金流量表', '处置固定资产', 7, 0.32204),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '现金流量表', '购建固定资产', 8, 10.14684),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '现金流量表', '出售附属公司', 48, -0.25655),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '现金流量表', '收购附属公司', 49, 0.34907),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '现金流量表', '收回投资所得现金', 9, 622.29311),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '现金流量表', '投资支付现金', 10, 655.36949),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '现金流量表', '投资业务现金净额', 11, -38.25729),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '现金流量表', '融资前现金净额', 12, 22.95814),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '现金流量表', '新增借款', 13, 48.34739),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '现金流量表', '偿还借款', 14, 30.66095),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '现金流量表', '吸收投资所得', 16, 26.31),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '现金流量表', '受限制存款及现金增加(减少)', 50, -30.49504),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '现金流量表', '购买子公司少数股权而支付的现金', 47, 0.2),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '现金流量表', '融资业务其他项目', 19, -1.36958),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '现金流量表', '融资业务现金净额', 20, 11.93182),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '现金流量表', '现金净额', 21, 34.88996),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '现金流量表', '期初现金', 22, 115.63282),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '现金流量表', '期间变动其他项目', 23, -1.58128),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q2', '2018-06-30', '现金流量表', '期末现金', 24, 148.9415),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q1', '2018-03-31', '现金流量表', '经营业务现金净额', 3, -12.77682),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q1', '2018-03-31', '现金流量表', '投资业务现金净额', 11, 4.60647),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q1', '2018-03-31', '现金流量表', '融资业务现金净额', 20, 33.37476),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q1', '2018-03-31', '现金流量表', '现金净额', 21, 25.20441),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q1', '2018-03-31', '现金流量表', '期初现金', 22, 115.63282),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q1', '2018-03-31', '现金流量表', '期间变动其他项目', 23, -0.5671),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018Q1', '2018-03-31', '现金流量表', '期末现金', 24, 140.27013),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '现金流量表', '除税前溢利(业务利润)', 25, -418.29352),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '现金流量表', '减:利息收入', 26, 2.42518),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '现金流量表', '加:利息支出', 27, 2.15734),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '现金流量表', '减:投资收益', 28, 3.75723),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '现金流量表', '加:减值及拨备', 29, 9.27995),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '现金流量表', '减:重估盈余', 30, -477.00505),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '现金流量表', '减:出售资产之溢利', 31, 0.00513),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '现金流量表', '加:折旧及摊销', 32, 3.60956),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '现金流量表', '减:汇兑收益', 33, -1.44265),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '现金流量表', '加:经营调整其他项目', 34, 9.09155),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '现金流量表', '营运资金变动前经营溢利', 35, 78.10504),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '现金流量表', '存货(增加)减少', 36, -86.17146),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '现金流量表', '应收帐款减少', 37, -33.96954),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '现金流量表', '应付帐款及应计费用增加(减少)', 38, 154.76486),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '现金流量表', '营运资本变动其他项目', 39, 9.12603),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '现金流量表', '预付款项、按金及其他应收款项减少(增加)', 40, -50.70104),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '现金流量表', '预收账款、按金及其他应付款增加(减少)', 41, 20.56983),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '现金流量表', '贷款和垫款(增加)减少', 42, -68.56767),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '现金流量表', '存款(增加)减少', 43, -17.88284),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '现金流量表', '经营产生现金', 1, 5.27321),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '现金流量表', '已付税项', 2, 15.2299),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '现金流量表', '经营业务现金净额', 3, -9.95669),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '现金流量表', '已收利息(投资)', 4, 2.66054),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '现金流量表', '已收股息(投资)', 5, 1.41548),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '现金流量表', '存款减少(增加)', 6, 1.93428),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '现金流量表', '处置固定资产', 7, 0.01531),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '现金流量表', '购建固定资产', 8, 12.17806),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '现金流量表', '收回投资所得现金', 9, 1138.32257),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '现金流量表', '投资支付现金', 10, 1158.94726),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '现金流量表', '投资业务现金净额', 11, -26.77714),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '现金流量表', '融资前现金净额', 12, -36.73383),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '现金流量表', '新增借款', 13, 111.74861),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '现金流量表', '偿还借款', 14, 45.31248),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '现金流量表', '发行股份', 45, 0.67573),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '现金流量表', '受限制存款及现金增加(减少)', 50, -2.88872),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '现金流量表', '融资业务其他项目', 19, -2.07384),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '现金流量表', '融资业务现金净额', 20, 62.1493),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '现金流量表', '现金净额', 21, 25.41547),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '现金流量表', '期初现金', 22, 92.3032),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '现金流量表', '期间变动其他项目', 23, -2.08585),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q4', '2017-12-31', '现金流量表', '期末现金', 24, 115.63282),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q3', '2017-09-30', '现金流量表', '经营业务现金净额', 3, 32.94922),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q3', '2017-09-30', '现金流量表', '投资业务现金净额', 11, -54.6957),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q3', '2017-09-30', '现金流量表', '融资前现金净额', 12, -21.74648),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q3', '2017-09-30', '现金流量表', '融资业务现金净额', 20, 44.10662),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q3', '2017-09-30', '现金流量表', '现金净额', 21, 22.36014),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q3', '2017-09-30', '现金流量表', '期初现金', 22, 92.3032),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q3', '2017-09-30', '现金流量表', '期间变动其他项目', 23, -2.11329),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q3', '2017-09-30', '现金流量表', '期末现金', 24, 112.55005),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q2', '2017-06-30', '现金流量表', '经营产生现金', 1, 23.8643),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q2', '2017-06-30', '现金流量表', '已付税项', 2, 4.47792),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q2', '2017-06-30', '现金流量表', '经营业务现金净额', 3, 19.38638),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q2', '2017-06-30', '现金流量表', '已收利息(投资)', 4, 0.7811),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q2', '2017-06-30', '现金流量表', '已收股息(投资)', 5, 1.28454),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q2', '2017-06-30', '现金流量表', '存款减少(增加)', 6, 3.25322),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q2', '2017-06-30', '现金流量表', '处置固定资产', 7, 0.01741),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q2', '2017-06-30', '现金流量表', '购建固定资产', 8, 4.30315),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q2', '2017-06-30', '现金流量表', '收回投资所得现金', 9, 372.47882),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q2', '2017-06-30', '现金流量表', '投资支付现金', 10, 391.68528),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q2', '2017-06-30', '现金流量表', '投资业务现金净额', 11, -18.17334),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q2', '2017-06-30', '现金流量表', '融资前现金净额', 12, 1.21304),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q2', '2017-06-30', '现金流量表', '新增借款', 13, 31.44092),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q2', '2017-06-30', '现金流量表', '偿还借款', 14, 3.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q2', '2017-06-30', '现金流量表', '受限制存款及现金增加(减少)', 50, 1.52018),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q2', '2017-06-30', '现金流量表', '融资业务其他项目', 19, -0.28997),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q2', '2017-06-30', '现金流量表', '融资业务现金净额', 20, 29.67113),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q2', '2017-06-30', '现金流量表', '现金净额', 21, 30.88417),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q2', '2017-06-30', '现金流量表', '期初现金', 22, 92.3032),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q2', '2017-06-30', '现金流量表', '期间变动其他项目', 23, -2.38164),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q2', '2017-06-30', '现金流量表', '期末现金', 24, 120.80573),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q1', '2017-03-31', '现金流量表', '除税前溢利(业务利润)', 25, -75.22103),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q1', '2017-03-31', '现金流量表', '减:利息收入', 26, 0.27526),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q1', '2017-03-31', '现金流量表', '加:利息支出', 27, 0.39647),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q1', '2017-03-31', '现金流量表', '减:投资收益', 28, -0.49821),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q1', '2017-03-31', '现金流量表', '加:减值及拨备', 29, 0.86781),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q1', '2017-03-31', '现金流量表', '减:重估盈余', 30, -82.84775),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q1', '2017-03-31', '现金流量表', '减:出售资产之溢利', 31, 0.0047),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q1', '2017-03-31', '现金流量表', '加:折旧及摊销', 32, 0.7372),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q1', '2017-03-31', '现金流量表', '减:汇兑收益', 33, -0.76654),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q1', '2017-03-31', '现金流量表', '加:购股权开支', 52, 1.36176),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q1', '2017-03-31', '现金流量表', '营运资金变动前经营溢利', 35, 11.97475),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q1', '2017-03-31', '现金流量表', '存货(增加)减少', 36, -10.62089),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q1', '2017-03-31', '现金流量表', '应收帐款减少', 37, -10.58867),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q1', '2017-03-31', '现金流量表', '应付帐款及应计费用增加(减少)', 38, 11.52468),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q1', '2017-03-31', '现金流量表', '营运资本变动其他项目', 39, 1.91915),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q1', '2017-03-31', '现金流量表', '预付款项、按金及其他应收款项减少(增加)', 40, -8.25739),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q1', '2017-03-31', '现金流量表', '预收账款、按金及其他应付款增加(减少)', 41, 3.08014),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q1', '2017-03-31', '现金流量表', '贷款和垫款(增加)减少', 42, -10.34595),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q1', '2017-03-31', '现金流量表', '存款(增加)减少', 43, -0.03027),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q1', '2017-03-31', '现金流量表', '经营产生现金', 1, -11.34445),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q1', '2017-03-31', '现金流量表', '已付税项', 2, 1.12251),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q1', '2017-03-31', '现金流量表', '经营业务现金净额', 3, -12.46696),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q1', '2017-03-31', '现金流量表', '已收利息(投资)', 4, 0.25449),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q1', '2017-03-31', '现金流量表', '已收股息(投资)', 5, 0.02704),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q1', '2017-03-31', '现金流量表', '存款减少(增加)', 6, 3.45779),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q1', '2017-03-31', '现金流量表', '处置固定资产', 7, 0.00472),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q1', '2017-03-31', '现金流量表', '购建固定资产', 8, 1.78284),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q1', '2017-03-31', '现金流量表', '收回投资所得现金', 9, 162.94893),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q1', '2017-03-31', '现金流量表', '投资支付现金', 10, 138.31156),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q1', '2017-03-31', '现金流量表', '投资业务现金净额', 11, 26.59857),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q1', '2017-03-31', '现金流量表', '新增借款', 13, 16.64),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q1', '2017-03-31', '现金流量表', '偿还借款', 14, 3.0),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q1', '2017-03-31', '现金流量表', '已付利息(融资)', 53, 0.26856),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q1', '2017-03-31', '现金流量表', '融资业务现金净额', 20, 13.37144),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q1', '2017-03-31', '现金流量表', '现金净额', 21, 27.50305),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q1', '2017-03-31', '现金流量表', '期初现金', 22, 92.3032),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q1', '2017-03-31', '现金流量表', '期间变动其他项目', 23, -0.68054),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2017Q1', '2017-03-31', '现金流量表', '期末现金', 24, 119.12571),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '现金流量表', '除税前溢利(业务利润)', 25, 11.75509),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '现金流量表', '减:利息收入', 26, 0.89233),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '现金流量表', '加:利息支出', 27, 1.75479),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '现金流量表', '减:投资收益', 28, 0.51063),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '现金流量表', '加:减值及拨备', 29, 7.28948),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '现金流量表', '减:重估盈余', 30, 1.14418),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '现金流量表', '减:出售资产之溢利', 31, 0.1117),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '现金流量表', '加:折旧及摊销', 32, 2.40031),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '现金流量表', '减:汇兑收益', 33, -0.54291),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '现金流量表', '加:购股权开支', 52, 8.7123),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '现金流量表', '营运资金变动前经营溢利', 35, 29.79604),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '现金流量表', '存货(增加)减少', 36, -0.15204),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '现金流量表', '应收帐款减少', 37, -6.28852),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '现金流量表', '应付帐款及应计费用增加(减少)', 38, 33.52162),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '现金流量表', '营运资本变动其他项目', 39, 4.84597),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '现金流量表', '预付款项、按金及其他应收款项减少(增加)', 40, -4.18981),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '现金流量表', '预收账款、按金及其他应付款增加(减少)', 41, 4.26003),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '现金流量表', '贷款和垫款(增加)减少', 42, -15.22238),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '现金流量表', '存款(增加)减少', 43, 0.57426),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '现金流量表', '经营产生现金', 1, 47.14517),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '现金流量表', '已付税项', 2, 1.83253),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '现金流量表', '经营业务现金净额', 3, 45.31264),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '现金流量表', '已收利息(投资)', 4, 1.06983),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '现金流量表', '已收股息(投资)', 5, 1.04255),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '现金流量表', '存款减少(增加)', 6, 2.99204),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '现金流量表', '处置固定资产', 7, 0.49855),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '现金流量表', '购建固定资产', 8, 18.26245),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '现金流量表', '收回投资所得现金', 9, 535.02171),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '现金流量表', '投资支付现金', 10, 559.7149),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '现金流量表', '投资业务现金净额', 11, -37.35267),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '现金流量表', '新增借款', 13, 7.4),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '现金流量表', '偿还借款', 14, 0.5),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '现金流量表', '已付利息(融资)', 53, 1.37811),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '现金流量表', '受限制存款及现金增加(减少)', 50, -6.2433),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '现金流量表', '融资业务现金净额', 20, -0.72141),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '现金流量表', '现金净额', 21, 7.23856),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '现金流量表', '期初现金', 22, 83.94078),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '现金流量表', '期间变动其他项目', 23, 1.12386),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2016Q4', '2016-12-31', '现金流量表', '期末现金', 24, 92.3032),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '现金流量表', '除税前溢利(业务利润)', 25, -74.72511),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '现金流量表', '减:利息收入', 26, 0.37682),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '现金流量表', '加:利息支出', 27, 1.23549),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '现金流量表', '减:投资收益', 28, 3.0394),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '现金流量表', '加:减值及拨备', 29, 12.30298),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '现金流量表', '减:重估盈余', 30, -54.12445),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '现金流量表', '减:出售资产之溢利', 31, 0.00279),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '现金流量表', '加:折旧及摊销', 32, 2.06461),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '现金流量表', '减:汇兑收益', 33, -5.06528),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '现金流量表', '加:购股权开支', 52, 6.90742),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '现金流量表', '营运资金变动前经营溢利', 35, 3.55611),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '现金流量表', '存货(增加)减少', 36, -7.77398),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '现金流量表', '应收帐款减少', 37, -5.29748),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '现金流量表', '应付帐款及应计费用增加(减少)', 38, 16.01403),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '现金流量表', '营运资本变动其他项目', 39, 1.09055),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '现金流量表', '预付款项、按金及其他应收款项减少(增加)', 40, -8.78739),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '现金流量表', '预收账款、按金及其他应付款增加(减少)', 41, -24.35752),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '现金流量表', '贷款和垫款(增加)减少', 42, -1.02927),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '现金流量表', '存款(增加)减少', 43, 3.6474),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '现金流量表', '经营产生现金', 1, -22.93755),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '现金流量表', '已付税项', 2, 3.07556),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '现金流量表', '经营业务现金净额', 3, -26.01311),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '现金流量表', '已收利息(投资)', 4, 1.98285),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '现金流量表', '已收股息(投资)', 5, 0.0751),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '现金流量表', '存款减少(增加)', 6, 0.14534),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '现金流量表', '处置固定资产', 7, 0.00398),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '现金流量表', '购建固定资产', 8, 25.24356),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '现金流量表', '收回投资所得现金', 9, 795.14546),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '现金流量表', '投资支付现金', 10, 763.37522),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '现金流量表', '投资业务现金净额', 11, 8.73395),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '现金流量表', '新增借款', 13, 32.468),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '现金流量表', '偿还借款', 14, 40.01826),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '现金流量表', '已付利息(融资)', 53, 0.67083),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '现金流量表', '发行股份', 45, 13.90492),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '现金流量表', '融资业务现金净额', 20, 5.68383),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '现金流量表', '现金净额', 21, -11.59533),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '现金流量表', '期初现金', 22, 92.64955),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '现金流量表', '期间变动其他项目', 23, 2.88656),
((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2015Q4', '2015-12-31', '现金流量表', '期末现金', 24, 83.94078);

SELECT vi_merge_company_metrics((SELECT id FROM vi_company_base WHERE code = '01810.HK'));

UPDATE vi_observation_base SET metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '全球月活跃用户' AND unit IS NOT DISTINCT FROM '百万人' ORDER BY id LIMIT 1), value = value * 1 WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '全球月活跃用户（12 月）' AND unit IS NOT DISTINCT FROM '百万人' ORDER BY id LIMIT 1) AND (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '全球月活跃用户' AND unit IS NOT DISTINCT FROM '百万人' ORDER BY id LIMIT 1) IS NOT NULL;

DELETE FROM vi_metric_base WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '全球月活跃用户（12 月）' AND unit IS NOT DISTINCT FROM '百万人' ORDER BY id LIMIT 1) AND (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '全球月活跃用户' AND unit IS NOT DISTINCT FROM '百万人' ORDER BY id LIMIT 1) IS NOT NULL;

DELETE FROM vi_fact_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2018 年度数据口径与说明';

INSERT INTO vi_fact_base (company_id, title, category, statement, period, as_of, verify_status, source_id) VALUES ((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2018 年度数据口径与说明', '财务', '财务数据：东方财富港股格式（国际财务报告准则）；“分红总额”为当年回购金额（小米不派现金股息）；“投资收益”＝投资公允价值变动＋其他收益净额；货币资金＝现金及等价物＋定期存款＋受限制现金（不含短期投资与理财，公司口径的“现金储备”更大）；带息负债＝短期借款＋长期借款（含可换股债券，不含租赁）。；7 月上市；利润含可转换可赎回优先股公允价值变动约 125 亿元、上市相关一次性股权激励约 100 亿元。', '2018', '2018-12-31', '待核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '东方财富港股格式三大报表（akshare 取数）' ORDER BY id LIMIT 1));

DELETE FROM vi_fact_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2019 年度数据口径与说明';

INSERT INTO vi_fact_base (company_id, title, category, statement, period, as_of, verify_status, source_id) VALUES ((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2019 年度数据口径与说明', '财务', '财务数据：东方财富港股格式（国际财务报告准则）；“分红总额”为当年回购金额（小米不派现金股息）；“投资收益”＝投资公允价值变动＋其他收益净额；货币资金＝现金及等价物＋定期存款＋受限制现金（不含短期投资与理财，公司口径的“现金储备”更大）；带息负债＝短期借款＋长期借款（含可换股债券，不含租赁）。；智能手机出货与月活口径见定期经营数据。', '2019', '2019-12-31', '待核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '东方财富港股格式三大报表（akshare 取数）' ORDER BY id LIMIT 1));

DELETE FROM vi_fact_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2020 年度数据口径与说明';

INSERT INTO vi_fact_base (company_id, title, category, statement, period, as_of, verify_status, source_id) VALUES ((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2020 年度数据口径与说明', '财务', '财务数据：东方财富港股格式（国际财务报告准则）；“分红总额”为当年回购金额（小米不派现金股息）；“投资收益”＝投资公允价值变动＋其他收益净额；货币资金＝现金及等价物＋定期存款＋受限制现金（不含短期投资与理财，公司口径的“现金储备”更大）；带息负债＝短期借款＋长期借款（含可换股债券，不含租赁）。；12 月配售 10 亿股（每股 23.70 港元）；发行 6 亿美元 2030 年票据与 8.55 亿美元 2027 年可换股债券。', '2020', '2020-12-31', '待核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '东方财富港股格式三大报表（akshare 取数）' ORDER BY id LIMIT 1));

DELETE FROM vi_fact_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2021 年度数据口径与说明';

INSERT INTO vi_fact_base (company_id, title, category, statement, period, as_of, verify_status, source_id) VALUES ((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2021 年度数据口径与说明', '财务', '财务数据：东方财富港股格式（国际财务报告准则）；“分红总额”为当年回购金额（小米不派现金股息）；“投资收益”＝投资公允价值变动＋其他收益净额；货币资金＝现金及等价物＋定期存款＋受限制现金（不含短期投资与理财，公司口径的“现金储备”更大）；带息负债＝短期借款＋长期借款（含可换股债券，不含租赁）。；宣布造车（3 月）；7 月发行 8 亿美元 2031 年票据与 4 亿美元 2051 年绿色债券；出货 1.903 亿台（高点）。', '2021', '2021-12-31', '待核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '东方财富港股格式三大报表（akshare 取数）' ORDER BY id LIMIT 1));

DELETE FROM vi_fact_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2022 年度数据口径与说明';

INSERT INTO vi_fact_base (company_id, title, category, statement, period, as_of, verify_status, source_id) VALUES ((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2022 年度数据口径与说明', '财务', '财务数据：东方财富港股格式（国际财务报告准则）；“分红总额”为当年回购金额（小米不派现金股息）；“投资收益”＝投资公允价值变动＋其他收益净额；货币资金＝现金及等价物＋定期存款＋受限制现金（不含短期投资与理财，公司口径的“现金储备”更大）；带息负债＝短期借款＋长期借款（含可换股债券，不含租赁）。；行业萧条：收入 −14.7%，出货 −20.9%；智能电动汽车等创新业务费用 31 亿元。', '2022', '2022-12-31', '待核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '东方财富港股格式三大报表（akshare 取数）' ORDER BY id LIMIT 1));

DELETE FROM vi_fact_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2023 年度数据口径与说明';

INSERT INTO vi_fact_base (company_id, title, category, statement, period, as_of, verify_status, source_id) VALUES ((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2023 年度数据口径与说明', '财务', '财务数据：东方财富港股格式（国际财务报告准则）；“分红总额”为当年回购金额（小米不派现金股息）；“投资收益”＝投资公允价值变动＋其他收益净额；货币资金＝现金及等价物＋定期存款＋受限制现金（不含短期投资与理财，公司口径的“现金储备”更大）；带息负债＝短期借款＋长期借款（含可换股债券，不含租赁）。；创新业务费用 67 亿元；毛利率升到 21.2%。', '2023', '2023-12-31', '待核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '东方财富港股格式三大报表（akshare 取数）' ORDER BY id LIMIT 1));

DELETE FROM vi_fact_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2024 年度数据口径与说明';

INSERT INTO vi_fact_base (company_id, title, category, statement, period, as_of, verify_status, source_id) VALUES ((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2024 年度数据口径与说明', '财务', '财务数据：东方财富港股格式（国际财务报告准则）；“分红总额”为当年回购金额（小米不派现金股息）；“投资收益”＝投资公允价值变动＋其他收益净额；货币资金＝现金及等价物＋定期存款＋受限制现金（不含短期投资与理财，公司口径的“现金储备”更大）；带息负债＝短期借款＋长期借款（含可换股债券，不含租赁）。；汽车 4 月开始交付，全年 136,854 辆；汽车及 AI 分部经营亏损约 71.5 亿元。', '2024', '2024-12-31', '待核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年全年业绩公告（2026-03-24）' ORDER BY id LIMIT 1));

DELETE FROM vi_fact_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年度数据口径与说明';

INSERT INTO vi_fact_base (company_id, title, category, statement, period, as_of, verify_status, source_id) VALUES ((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '2025 年度数据口径与说明', '财务', '财务数据：东方财富港股格式（国际财务报告准则）；“分红总额”为当年回购金额（小米不派现金股息）；“投资收益”＝投资公允价值变动＋其他收益净额；货币资金＝现金及等价物＋定期存款＋受限制现金（不含短期投资与理财，公司口径的“现金储备”更大）；带息负债＝短期借款＋长期借款（含可换股债券，不含租赁）。；模型基准年。3 月配售 8 亿股（每股 53.25 港元）；汽车交付 411,082 辆、分部经营收益 9 亿元；归母含投资公允价值收益 133.1 亿元；回购 61.7 亿元。', '2025', '2025-12-31', '待核验', (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年全年业绩公告（2026-03-24）' ORDER BY id LIMIT 1));

UPDATE vi_metric_base SET source_name = '季度业绩公告' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '智能手机毛利率' AND unit IS NOT DISTINCT FROM '%' ORDER BY id LIMIT 1);

UPDATE vi_metric_base SET source_name = '季度业绩公告：分项毛利、集团费用、汽车分部经营开支' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = 'IoT毛利率' AND unit IS NOT DISTINCT FROM '%' ORDER BY id LIMIT 1);

UPDATE vi_metric_base SET source_name = '季度业绩公告：分项毛利、集团费用、汽车分部经营开支' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '生态营业费用率（推算）' AND unit IS NOT DISTINCT FROM '%' ORDER BY id LIMIT 1);

UPDATE vi_metric_base SET source_name = '季度业绩公告、业绩会' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '汽车及AI分部经营损益' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1);

UPDATE vi_metric_base SET source_name = '季度业绩公告' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '互联网服务收入' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1);

UPDATE vi_metric_base SET source_name = '港交所翌日披露报表、证券变动月报表' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '回购（港元）' AND unit IS NOT DISTINCT FROM '亿港元' ORDER BY id LIMIT 1);

UPDATE vi_metric_base SET source_name = '资产负债表与附注' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '现金储备' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1);

UPDATE vi_metric_base SET source_name = '资产负债表与附注' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '借款' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1);

UPDATE vi_metric_base SET source_name = '季度业绩公告' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '智能手机ASP' AND unit IS NOT DISTINCT FROM '元' ORDER BY id LIMIT 1);

UPDATE vi_metric_base SET source_name = '季度业绩公告' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '智能手机出货量' AND unit IS NOT DISTINCT FROM '百万台' ORDER BY id LIMIT 1);

UPDATE vi_metric_base SET source_name = '公司公告与微博、乘联会' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '汽车交付量' AND unit IS NOT DISTINCT FROM '辆' ORDER BY id LIMIT 1);

UPDATE vi_metric_base SET source_name = '季度业绩公告' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '全球月活跃用户' AND unit IS NOT DISTINCT FROM '百万人' ORDER BY id LIMIT 1);

SELECT vi_metric_to_stmt((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '借款', '亿元', '短期贷款 + 长期贷款', '时点');

SELECT vi_metric_to_stmt((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '营业收入', '亿元', '营业额', '单季');

SELECT vi_metric_to_stmt((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '毛利率', '%', '毛利 ÷ 营业额', '单季');

SELECT vi_metric_to_stmt((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '研发开支', '亿元', '研发费用', '单季');

SELECT vi_metric_to_stmt((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '期间利润（国际财务报告准则）', '亿元', '除税后溢利', '单季');

UPDATE vi_metric_base SET basis = '单季' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '智能手机毛利率' AND unit IS NOT DISTINCT FROM '%' ORDER BY id LIMIT 1);

UPDATE vi_metric_base SET basis = '单季' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = 'IoT毛利率' AND unit IS NOT DISTINCT FROM '%' ORDER BY id LIMIT 1);

UPDATE vi_metric_base SET basis = '单季' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '汽车及AI分部经营损益' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1);

UPDATE vi_metric_base SET basis = '单季' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '互联网服务收入' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1);

UPDATE vi_metric_base SET basis = '单季' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '回购（港元）' AND unit IS NOT DISTINCT FROM '亿港元' ORDER BY id LIMIT 1);

UPDATE vi_metric_base SET basis = '时点' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '现金储备' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1);

UPDATE vi_metric_base SET basis = '单季' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '智能手机出货量' AND unit IS NOT DISTINCT FROM '百万台' ORDER BY id LIMIT 1);

UPDATE vi_metric_base SET basis = '单季' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '汽车交付量' AND unit IS NOT DISTINCT FROM '辆' ORDER BY id LIMIT 1);

UPDATE vi_metric_base SET basis = '单季' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '智能手机收入' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1);

UPDATE vi_metric_base SET basis = '单季' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = 'IoT与生活消费产品收入' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1);

UPDATE vi_metric_base SET basis = '单季' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '互联网服务毛利率' AND unit IS NOT DISTINCT FROM '%' ORDER BY id LIMIT 1);

UPDATE vi_metric_base SET basis = '单季' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '生态经营利润（推算）' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1);

UPDATE vi_metric_base SET basis = '单季' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '生态经营利润率（推算）' AND unit IS NOT DISTINCT FROM '%' ORDER BY id LIMIT 1);

UPDATE vi_observation_base SET basis = '时点' WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '现金储备' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1);

UPDATE vi_metric_base SET basis = '时点' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '现金储备' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1);

INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id, "createdAt", "updatedAt") SELECT x.id, (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '小米集团港股收盘价' AND unit IS NOT DISTINCT FROM '港元' ORDER BY id LIMIT 1), now(), now() FROM vi_judgment_base x WHERE x.company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND x.code = 'J-AI' AND (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '小米集团港股收盘价' AND unit IS NOT DISTINCT FROM '港元' ORDER BY id LIMIT 1) IS NOT NULL ON CONFLICT DO NOTHING;

INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id, "createdAt", "updatedAt") SELECT x.id, (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '汽车及AI分部经营损益' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), now(), now() FROM vi_judgment_base x WHERE x.company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND x.code = 'J-AI' AND (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '汽车及AI分部经营损益' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) IS NOT NULL ON CONFLICT DO NOTHING;

INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id, "createdAt", "updatedAt") SELECT x.id, (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = 'IoT毛利率' AND unit IS NOT DISTINCT FROM '%' ORDER BY id LIMIT 1), now(), now() FROM vi_judgment_base x WHERE x.company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND x.code = 'J-AIOT' AND (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = 'IoT毛利率' AND unit IS NOT DISTINCT FROM '%' ORDER BY id LIMIT 1) IS NOT NULL ON CONFLICT DO NOTHING;

INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id, "createdAt", "updatedAt") SELECT x.id, (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '生态营业费用率（推算）' AND unit IS NOT DISTINCT FROM '%' ORDER BY id LIMIT 1), now(), now() FROM vi_judgment_base x WHERE x.company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND x.code = 'J-AIOT' AND (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '生态营业费用率（推算）' AND unit IS NOT DISTINCT FROM '%' ORDER BY id LIMIT 1) IS NOT NULL ON CONFLICT DO NOTHING;

INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id, "createdAt", "updatedAt") SELECT x.id, (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '现金储备' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), now(), now() FROM vi_judgment_base x WHERE x.company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND x.code = 'J-CASH' AND (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '现金储备' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) IS NOT NULL ON CONFLICT DO NOTHING;

INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id, "createdAt", "updatedAt") SELECT x.id, (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '借款' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), now(), now() FROM vi_judgment_base x WHERE x.company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND x.code = 'J-CASH' AND (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '借款' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) IS NOT NULL ON CONFLICT DO NOTHING;

INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id, "createdAt", "updatedAt") SELECT x.id, (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '汽车交付量' AND unit IS NOT DISTINCT FROM '辆' ORDER BY id LIMIT 1), now(), now() FROM vi_judgment_base x WHERE x.company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND x.code = 'J-EV' AND (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '汽车交付量' AND unit IS NOT DISTINCT FROM '辆' ORDER BY id LIMIT 1) IS NOT NULL ON CONFLICT DO NOTHING;

INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id, "createdAt", "updatedAt") SELECT x.id, (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '汽车及AI分部经营损益' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), now(), now() FROM vi_judgment_base x WHERE x.company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND x.code = 'J-EV-SPLIT' AND (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '汽车及AI分部经营损益' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) IS NOT NULL ON CONFLICT DO NOTHING;

INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id, "createdAt", "updatedAt") SELECT x.id, (SELECT id FROM vi_metric_base WHERE company_id IS NULL AND name = '港元兑人民币' AND unit IS NOT DISTINCT FROM '人民币/港元' ORDER BY id LIMIT 1), now(), now() FROM vi_judgment_base x WHERE x.company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND x.code = 'J-FX' AND (SELECT id FROM vi_metric_base WHERE company_id IS NULL AND name = '港元兑人民币' AND unit IS NOT DISTINCT FROM '人民币/港元' ORDER BY id LIMIT 1) IS NOT NULL ON CONFLICT DO NOTHING;

INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id, "createdAt", "updatedAt") SELECT x.id, (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '现金储备' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), now(), now() FROM vi_judgment_base x WHERE x.company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND x.code = 'J-INV' AND (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '现金储备' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) IS NOT NULL ON CONFLICT DO NOTHING;

INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id, "createdAt", "updatedAt") SELECT x.id, (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '借款' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), now(), now() FROM vi_judgment_base x WHERE x.company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND x.code = 'J-INV' AND (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '借款' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) IS NOT NULL ON CONFLICT DO NOTHING;

INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id, "createdAt", "updatedAt") SELECT x.id, (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '智能手机毛利率' AND unit IS NOT DISTINCT FROM '%' ORDER BY id LIMIT 1), now(), now() FROM vi_judgment_base x WHERE x.company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND x.code = 'J-MEM' AND (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '智能手机毛利率' AND unit IS NOT DISTINCT FROM '%' ORDER BY id LIMIT 1) IS NOT NULL ON CONFLICT DO NOTHING;

INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id, "createdAt", "updatedAt") SELECT x.id, (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '智能手机出货量' AND unit IS NOT DISTINCT FROM '百万台' ORDER BY id LIMIT 1), now(), now() FROM vi_judgment_base x WHERE x.company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND x.code = 'J-MEM' AND (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '智能手机出货量' AND unit IS NOT DISTINCT FROM '百万台' ORDER BY id LIMIT 1) IS NOT NULL ON CONFLICT DO NOTHING;

INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id, "createdAt", "updatedAt") SELECT x.id, (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '智能手机ASP' AND unit IS NOT DISTINCT FROM '元' ORDER BY id LIMIT 1), now(), now() FROM vi_judgment_base x WHERE x.company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND x.code = 'J-MEM' AND (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '智能手机ASP' AND unit IS NOT DISTINCT FROM '元' ORDER BY id LIMIT 1) IS NOT NULL ON CONFLICT DO NOTHING;

INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id, "createdAt", "updatedAt") SELECT x.id, (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '小米集团港股收盘价' AND unit IS NOT DISTINCT FROM '港元' ORDER BY id LIMIT 1), now(), now() FROM vi_judgment_base x WHERE x.company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND x.code = 'J-METHOD' AND (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '小米集团港股收盘价' AND unit IS NOT DISTINCT FROM '港元' ORDER BY id LIMIT 1) IS NOT NULL ON CONFLICT DO NOTHING;

INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id, "createdAt", "updatedAt") SELECT x.id, (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '互联网服务收入' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), now(), now() FROM vi_judgment_base x WHERE x.company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND x.code = 'J-MULT' AND (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '互联网服务收入' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) IS NOT NULL ON CONFLICT DO NOTHING;

INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id, "createdAt", "updatedAt") SELECT x.id, (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '全球月活跃用户' AND unit IS NOT DISTINCT FROM '百万人' ORDER BY id LIMIT 1), now(), now() FROM vi_judgment_base x WHERE x.company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND x.code = 'J-MULT' AND (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '全球月活跃用户' AND unit IS NOT DISTINCT FROM '百万人' ORDER BY id LIMIT 1) IS NOT NULL ON CONFLICT DO NOTHING;

INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id, "createdAt", "updatedAt") SELECT x.id, (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '互联网服务收入' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), now(), now() FROM vi_judgment_base x WHERE x.company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND x.code = 'J-NET' AND (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '互联网服务收入' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) IS NOT NULL ON CONFLICT DO NOTHING;

INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id, "createdAt", "updatedAt") SELECT x.id, (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '全球月活跃用户' AND unit IS NOT DISTINCT FROM '百万人' ORDER BY id LIMIT 1), now(), now() FROM vi_judgment_base x WHERE x.company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND x.code = 'J-NET' AND (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '全球月活跃用户' AND unit IS NOT DISTINCT FROM '百万人' ORDER BY id LIMIT 1) IS NOT NULL ON CONFLICT DO NOTHING;

INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id, "createdAt", "updatedAt") SELECT x.id, (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = 'IoT毛利率' AND unit IS NOT DISTINCT FROM '%' ORDER BY id LIMIT 1), now(), now() FROM vi_judgment_base x WHERE x.company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND x.code = 'J-OPEX' AND (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = 'IoT毛利率' AND unit IS NOT DISTINCT FROM '%' ORDER BY id LIMIT 1) IS NOT NULL ON CONFLICT DO NOTHING;

INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id, "createdAt", "updatedAt") SELECT x.id, (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '生态营业费用率（推算）' AND unit IS NOT DISTINCT FROM '%' ORDER BY id LIMIT 1), now(), now() FROM vi_judgment_base x WHERE x.company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND x.code = 'J-OPEX' AND (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '生态营业费用率（推算）' AND unit IS NOT DISTINCT FROM '%' ORDER BY id LIMIT 1) IS NOT NULL ON CONFLICT DO NOTHING;

INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id, "createdAt", "updatedAt") SELECT x.id, (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '回购（港元）' AND unit IS NOT DISTINCT FROM '亿港元' ORDER BY id LIMIT 1), now(), now() FROM vi_judgment_base x WHERE x.company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND x.code = 'J-PAYOUT' AND (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '回购（港元）' AND unit IS NOT DISTINCT FROM '亿港元' ORDER BY id LIMIT 1) IS NOT NULL ON CONFLICT DO NOTHING;

INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id, "createdAt", "updatedAt") SELECT x.id, (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '智能手机毛利率' AND unit IS NOT DISTINCT FROM '%' ORDER BY id LIMIT 1), now(), now() FROM vi_judgment_base x WHERE x.company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND x.code = 'J-PHONE' AND (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '智能手机毛利率' AND unit IS NOT DISTINCT FROM '%' ORDER BY id LIMIT 1) IS NOT NULL ON CONFLICT DO NOTHING;

INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id, "createdAt", "updatedAt") SELECT x.id, (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '智能手机出货量' AND unit IS NOT DISTINCT FROM '百万台' ORDER BY id LIMIT 1), now(), now() FROM vi_judgment_base x WHERE x.company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND x.code = 'J-PHONE' AND (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '智能手机出货量' AND unit IS NOT DISTINCT FROM '百万台' ORDER BY id LIMIT 1) IS NOT NULL ON CONFLICT DO NOTHING;

INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id, "createdAt", "updatedAt") SELECT x.id, (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '智能手机ASP' AND unit IS NOT DISTINCT FROM '元' ORDER BY id LIMIT 1), now(), now() FROM vi_judgment_base x WHERE x.company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND x.code = 'J-PHONE' AND (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '智能手机ASP' AND unit IS NOT DISTINCT FROM '元' ORDER BY id LIMIT 1) IS NOT NULL ON CONFLICT DO NOTHING;

INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id, "createdAt", "updatedAt") SELECT x.id, (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '小米集团港股收盘价' AND unit IS NOT DISTINCT FROM '港元' ORDER BY id LIMIT 1), now(), now() FROM vi_judgment_base x WHERE x.company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND x.code = 'J-PROB' AND (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '小米集团港股收盘价' AND unit IS NOT DISTINCT FROM '港元' ORDER BY id LIMIT 1) IS NOT NULL ON CONFLICT DO NOTHING;

INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id, "createdAt", "updatedAt") SELECT x.id, (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '回购（港元）' AND unit IS NOT DISTINCT FROM '亿港元' ORDER BY id LIMIT 1), now(), now() FROM vi_judgment_base x WHERE x.company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND x.code = 'J-SHR' AND (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '回购（港元）' AND unit IS NOT DISTINCT FROM '亿港元' ORDER BY id LIMIT 1) IS NOT NULL ON CONFLICT DO NOTHING;

UPDATE vi_judgment_base SET fact_layer = '三年 AI 投入超 600 亿元（2026 年 160 亿元），2026 年上半年约 88 亿元（按 J-EV-SPLIT 推算）；MiMo-V2.5 调用量第一，但 AI 收入每季度约 10 亿元（含售后）。国内大模型公司（2026-10-22 市值或最近一轮融资）：MiniMax 约 482 亿元、阶跃星辰约 120 亿美元、智谱约 1,912 亿元、月之暗面 350 亿美元、DeepSeek 投前约 5,000 亿元；它们按收入的几十到上百倍估值，市值波动很大（智谱较 7 月初回落约 76%）。
持续跟踪：AI 投入口径（季；来源：季度业绩公告、业绩会）
持续跟踪：AI 商业化与可比公司估值（季；来源：业绩公告“其他相关业务”、MiMo 调用量与价格；智谱、MiniMax 市值，月之暗面、阶跃星辰上市定价）' WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND code = 'J-AI';

UPDATE vi_judgment_base SET fact_layer = '现金储备 2,193 亿元（公司口径，比明细加总少 81.7 亿元）；借款 392.8 亿元；租赁负债 50.4 亿元；购买无形资产应付款 50.7 亿元。贸易应付款项 1,183 亿元、存货 849 亿元、应收 198 亿元。
持续跟踪：投资者负债（季；来源：资产负债表与附注）' WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND code = 'J-CASH';

UPDATE vi_judgment_base SET fact_layer = '2025 年交付 41.1 万辆、ASP 25.1 万元；2026 年预计 46—48.5 万辆、ASP 约 23.5 万元；澎程 30 天锁单超 7 万台；海外 2027 年起步（规划 2028 年 10—13 万台、2029 年 25—30 万台）。同行 2026 年上半年毛利率 9.5%—23%，零跑二季度净利率约 2%，理想经营亏损。
持续跟踪：汽车月度交付与订单（单季交付量见指标）（月；来源：公司公告与微博、乘联会）' WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND code = 'J-EV';

UPDATE vi_judgment_base SET fact_layer = '约 35.36 亿元资金受限，案件在听证阶段，公司未计提重大拨备。
持续跟踪：印度诉讼（半年；来源：中报、年报或有事项附注）' WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND code = 'J-IND';

UPDATE vi_judgment_base SET fact_layer = '存储占低端机物料成本 60% 以上；手机毛利率 2025 年一季度 12.4% → 2026 年二季度 8.5%。管理层：三季度中途涨势放缓、四季度缓涨；TrendForce：明年 DRAM 仍偏紧。Omdia：三季度小米全球份额 12%（−2pt）。
持续跟踪：存储合约价（DRAM、NAND）（月；来源：TrendForce、管理层电话会）' WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND code = 'J-MEM';

UPDATE vi_judgment_base SET fact_layer = '2025 年回购 61.7 亿元（归母 416.4 亿元，约 15%）；2026 年至 10 月 12 日 125 亿港元（约 106 亿元）；不派股息。
持续跟踪：股本变动（月；来源：港交所翌日披露报表、证券变动月报表）' WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND code = 'J-PAYOUT';

UPDATE vi_risk_base SET early_warning = '存储合约价（DRAM、NAND）：合约价连续两个月环比下跌，或 2027 年仍在上涨
手机毛利率、ASP 与出货：手机毛利率低于 7% 或高于 11%；出货同比连续两季低于 −20%' WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND code = 'R1';

UPDATE vi_risk_base SET early_warning = '汽车月度交付与订单：四季度月均低于 5 万辆；2027 年全年低于 55 万辆或高于 70 万辆
汽车及 AI 分部经营损益与 AI 投入口径：AI 投入规划调整；分部亏损扩大到单季 40 亿元以上' WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND code = 'R2';

UPDATE vi_risk_base SET early_warning = '汽车及 AI 分部经营损益与 AI 投入口径：AI 投入规划调整；分部亏损扩大到单季 40 亿元以上
AI 商业化与可比公司估值：AI 收入年化超过 50 亿元且毛利为正；或可比公司估值中枢变化超过 50%' WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND code = 'R3';

UPDATE vi_risk_base SET early_warning = 'IoT 毛利率与生态营业费用率：IoT 毛利率（含其他相关业务）连续两季低于 18%；或生态营业费用率连续四个季度高于 15.5% 或低于 12.5%
互联网服务收入与月活：互联网收入连续两季同比下降，或月活增速低于 2%' WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND code = 'R4';

UPDATE vi_risk_base SET early_warning = '回购执行与股本：回购暂停，或股权激励发股超过回购
现金储备、借款、投资者负债：现金储备低于 2,000 亿元或借款超过 500 亿元
印度诉讼：判决或和解' WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND code = 'R5';

UPDATE vi_fact_base SET notes = NULL WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '生态经营利润按季：2025 年 104.6、92.1、60.4、21.4 亿元，2026 年 60.6、48.5 亿元';

UPDATE vi_fact_base SET notes = NULL WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年二季度收入 1,089.2 亿元（−6.1%），经调整净利润 62.2 亿元（−42.6%）';

UPDATE vi_fact_base SET notes = NULL WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年手机收入 1,864.4 亿元、毛利率 10.9%、出货 1.652 亿台；四季度毛利率 8.3%';

UPDATE vi_fact_base SET notes = NULL WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年二季度 IoT 与生活消费产品收入 312.8 亿元（−19.2%），国补退坡';

UPDATE vi_fact_base SET notes = NULL WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年 IoT 收入 1,232.0 亿元（+18.3%）、毛利率 23.1%；大家电 +23.1%';

UPDATE vi_fact_base SET notes = '互联网服务含广告、游戏、金融科技等。' WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '互联网服务：2025 年 374.4 亿元（+9.7%）、毛利率 76.5%；2026 年二季度 90.4 亿元（−0.6%）';

UPDATE vi_fact_base SET notes = '2018 年由 2019 年数与同比倒算。' WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '全球月活（12 月）2018—2025 年：2.42 亿 → 7.54 亿';

UPDATE vi_fact_base SET notes = '2018、2019 年未取得。' WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '手机出货 2020—2025 年：1.464、1.903、1.505、1.456、1.685、1.652 亿台';

UPDATE vi_fact_base SET notes = '原“数值”字段：-26 亿元（2026Q2），为正文数字的推算或合计' WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年二季度汽车及 AI 分部：收入 249.0 亿元、交付 104,199 辆、ASP 22.93 万元、毛利率 19.2%、经营亏损 26 亿元';

UPDATE vi_fact_base SET notes = '原“数值”字段：-31 亿元（2026Q1），为正文数字的推算或合计' WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年一季度汽车及 AI 分部经营亏损 31 亿元，交付 80,856 辆';

UPDATE vi_fact_base SET notes = '专家口径。
原“数值”字段：47 万辆（2026E），为正文数字的推算或合计' WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '专家预计 2026 年交付 46—48.5 万辆，55 万目标难以完成';

UPDATE vi_fact_base SET notes = NULL WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年二季度全球：三星 6,050 万、苹果 5,510 万、小米 3,120 万部（−26%）';

UPDATE vi_fact_base SET notes = '原“数值”字段：101.16 亿元（2026-06-30），为正文数字的推算或合计' WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026-06-30 租赁负债 50.4 亿元、购买无形资产应付款 50.7 亿元';

UPDATE vi_fact_base SET notes = NULL WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2025 年回购 63 亿港元（1.526 亿股）；2026 年 1 月首次公告自动回购计划';

UPDATE vi_fact_base SET notes = '原“数值”字段：68.95 亿元（2026H1），为正文数字的推算或合计' WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '2026 年上半年资本开支 68.9 亿元：手机×AIoT 30.2、汽车及 AI 38.3';

UPDATE vi_fact_base SET notes = '卖方估值没有扣除 AI 投入的长期成本，也没有扣除股权激励。
原“数值”字段：9300 亿元（2026-08），为正文数字的推算或合计' WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND title = '申万宏源（2026-08）：主业 334 亿元×25 倍＋汽车及 AI 0.7 倍市销率，目标市值 9,000 亿元以上';

INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT c.code || '.D' || lpad((coalesce((SELECT max(substring(x.code FROM '\.D(\d+)$')::int) FROM vi_metric_base x WHERE x.code LIKE c.code || '.D%'), 0) + 1)::text, 3, '0'),
       '少数股东权益', '亿元', '财务', '报表计算', '时点', c.id, '财务数据（三大报表）：少数股东权益', '季', '少数股东权益'
FROM vi_company_base c WHERE c.id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND NOT EXISTS (SELECT 1 FROM vi_metric_base WHERE company_id = c.id AND name = '少数股东权益' AND unit IS NOT DISTINCT FROM '亿元');

INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT c.code || '.D' || lpad((coalesce((SELECT max(substring(x.code FROM '\.D(\d+)$')::int) FROM vi_metric_base x WHERE x.code LIKE c.code || '.D%'), 0) + 1)::text, 3, '0'),
       '全球月活跃用户', '百万人', '经营', '年报', '全年', c.id, '年报', '年', NULL
FROM vi_company_base c WHERE c.id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND NOT EXISTS (SELECT 1 FROM vi_metric_base WHERE company_id = c.id AND name = '全球月活跃用户' AND unit IS NOT DISTINCT FROM '百万人');

UPDATE vi_metric_base SET model_field = 'volume' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '全球月活跃用户' AND unit IS NOT DISTINCT FROM '百万人' ORDER BY id LIMIT 1);

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '全球月活跃用户' AND unit IS NOT DISTINCT FROM '百万人' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2018';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '全球月活跃用户' AND unit IS NOT DISTINCT FROM '百万人' ORDER BY id LIMIT 1), '2018-12-31', '2018', '全年', 242.1, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '全球月活跃用户' AND unit IS NOT DISTINCT FROM '百万人' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2019';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '全球月活跃用户' AND unit IS NOT DISTINCT FROM '百万人' ORDER BY id LIMIT 1), '2019-12-31', '2019', '全年', 309.6, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '全球月活跃用户' AND unit IS NOT DISTINCT FROM '百万人' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2020';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '全球月活跃用户' AND unit IS NOT DISTINCT FROM '百万人' ORDER BY id LIMIT 1), '2020-12-31', '2020', '全年', 396.3, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '全球月活跃用户' AND unit IS NOT DISTINCT FROM '百万人' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2021';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '全球月活跃用户' AND unit IS NOT DISTINCT FROM '百万人' ORDER BY id LIMIT 1), '2021-12-31', '2021', '全年', 508.9, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '全球月活跃用户' AND unit IS NOT DISTINCT FROM '百万人' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2022';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '全球月活跃用户' AND unit IS NOT DISTINCT FROM '百万人' ORDER BY id LIMIT 1), '2022-12-31', '2022', '全年', 582.1, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '全球月活跃用户' AND unit IS NOT DISTINCT FROM '百万人' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2023';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '全球月活跃用户' AND unit IS NOT DISTINCT FROM '百万人' ORDER BY id LIMIT 1), '2023-12-31', '2023', '全年', 641.2, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '全球月活跃用户' AND unit IS NOT DISTINCT FROM '百万人' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2024';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '全球月活跃用户' AND unit IS NOT DISTINCT FROM '百万人' ORDER BY id LIMIT 1), '2024-12-31', '2024', '全年', 702.3, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '全球月活跃用户' AND unit IS NOT DISTINCT FROM '百万人' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2025';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '全球月活跃用户' AND unit IS NOT DISTINCT FROM '百万人' ORDER BY id LIMIT 1), '2025-12-31', '2025', '全年', 754.1, '历史年度原值；口径：合并口径', now());

INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT c.code || '.D' || lpad((coalesce((SELECT max(substring(x.code FROM '\.D(\d+)$')::int) FROM vi_metric_base x WHERE x.code LIKE c.code || '.D%'), 0) + 1)::text, 3, '0'),
       '营业收入', '亿元', '财务', '报表计算', '全年', c.id, '财务数据（三大报表）：营业额', '年', '营业额'
FROM vi_company_base c WHERE c.id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND NOT EXISTS (SELECT 1 FROM vi_metric_base WHERE company_id = c.id AND name = '营业收入' AND unit IS NOT DISTINCT FROM '亿元');

UPDATE vi_metric_base SET model_field = 'revenue' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '营业收入' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1);

INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT c.code || '.D' || lpad((coalesce((SELECT max(substring(x.code FROM '\.D(\d+)$')::int) FROM vi_metric_base x WHERE x.code LIKE c.code || '.D%'), 0) + 1)::text, 3, '0'),
       '营业成本', '亿元', '财务', '报表计算', '全年', c.id, '财务数据（三大报表）：销售成本', '年', '销售成本'
FROM vi_company_base c WHERE c.id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND NOT EXISTS (SELECT 1 FROM vi_metric_base WHERE company_id = c.id AND name = '营业成本' AND unit IS NOT DISTINCT FROM '亿元');

UPDATE vi_metric_base SET model_field = 'cost_of_sales' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '营业成本' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1);

INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT c.code || '.D' || lpad((coalesce((SELECT max(substring(x.code FROM '\.D(\d+)$')::int) FROM vi_metric_base x WHERE x.code LIKE c.code || '.D%'), 0) + 1)::text, 3, '0'),
       '利润总额', '亿元', '财务', '报表计算', '全年', c.id, '财务数据（三大报表）：除税前溢利', '年', '除税前溢利'
FROM vi_company_base c WHERE c.id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND NOT EXISTS (SELECT 1 FROM vi_metric_base WHERE company_id = c.id AND name = '利润总额' AND unit IS NOT DISTINCT FROM '亿元');

UPDATE vi_metric_base SET model_field = 'pretax_profit' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '利润总额' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1);

INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT c.code || '.D' || lpad((coalesce((SELECT max(substring(x.code FROM '\.D(\d+)$')::int) FROM vi_metric_base x WHERE x.code LIKE c.code || '.D%'), 0) + 1)::text, 3, '0'),
       '所得税', '亿元', '财务', '报表计算', '全年', c.id, '财务数据（三大报表）：税项', '年', '税项'
FROM vi_company_base c WHERE c.id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND NOT EXISTS (SELECT 1 FROM vi_metric_base WHERE company_id = c.id AND name = '所得税' AND unit IS NOT DISTINCT FROM '亿元');

UPDATE vi_metric_base SET model_field = 'income_tax' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '所得税' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1);

INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT c.code || '.D' || lpad((coalesce((SELECT max(substring(x.code FROM '\.D(\d+)$')::int) FROM vi_metric_base x WHERE x.code LIKE c.code || '.D%'), 0) + 1)::text, 3, '0'),
       '归母净利润', '亿元', '财务', '报表计算', '全年', c.id, '财务数据（三大报表）：股东应占溢利', '年', '股东应占溢利'
FROM vi_company_base c WHERE c.id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND NOT EXISTS (SELECT 1 FROM vi_metric_base WHERE company_id = c.id AND name = '归母净利润' AND unit IS NOT DISTINCT FROM '亿元');

UPDATE vi_metric_base SET model_field = 'np_parent' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '归母净利润' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1);

INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT c.code || '.D' || lpad((coalesce((SELECT max(substring(x.code FROM '\.D(\d+)$')::int) FROM vi_metric_base x WHERE x.code LIKE c.code || '.D%'), 0) + 1)::text, 3, '0'),
       '少数股东损益', '亿元', '财务', '报表计算', '全年', c.id, '财务数据（三大报表）：少数股东损益', '年', '少数股东损益'
FROM vi_company_base c WHERE c.id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND NOT EXISTS (SELECT 1 FROM vi_metric_base WHERE company_id = c.id AND name = '少数股东损益' AND unit IS NOT DISTINCT FROM '亿元');

UPDATE vi_metric_base SET model_field = 'minority_profit' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '少数股东损益' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1);

INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT c.code || '.D' || lpad((coalesce((SELECT max(substring(x.code FROM '\.D(\d+)$')::int) FROM vi_metric_base x WHERE x.code LIKE c.code || '.D%'), 0) + 1)::text, 3, '0'),
       '折旧摊销', '亿元', '财务', '报表计算', '全年', c.id, '财务数据（三大报表）：加:折旧及摊销', '年', '加:折旧及摊销'
FROM vi_company_base c WHERE c.id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND NOT EXISTS (SELECT 1 FROM vi_metric_base WHERE company_id = c.id AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元');

UPDATE vi_metric_base SET model_field = 'da' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '折旧摊销' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1);

INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT c.code || '.D' || lpad((coalesce((SELECT max(substring(x.code FROM '\.D(\d+)$')::int) FROM vi_metric_base x WHERE x.code LIKE c.code || '.D%'), 0) + 1)::text, 3, '0'),
       '财务费用', '亿元', '财务', '报表计算', '全年', c.id, '财务数据（三大报表）：融资成本', '年', '融资成本'
FROM vi_company_base c WHERE c.id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND NOT EXISTS (SELECT 1 FROM vi_metric_base WHERE company_id = c.id AND name = '财务费用' AND unit IS NOT DISTINCT FROM '亿元');

UPDATE vi_metric_base SET model_field = 'finance_cost' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '财务费用' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1);

INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT c.code || '.D' || lpad((coalesce((SELECT max(substring(x.code FROM '\.D(\d+)$')::int) FROM vi_metric_base x WHERE x.code LIKE c.code || '.D%'), 0) + 1)::text, 3, '0'),
       '投资收益', '亿元', '财务', '年报', '全年', c.id, '年报', '年', NULL
FROM vi_company_base c WHERE c.id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND NOT EXISTS (SELECT 1 FROM vi_metric_base WHERE company_id = c.id AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元');

UPDATE vi_metric_base SET model_field = 'invest_income' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1);

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2018';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2018-12-31', '2018', '全年', 40.29, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2019';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2019-12-31', '2019', '全年', 29.15, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2020';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2020-12-31', '2020', '全年', 141.82, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2021';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2021-12-31', '2021', '全年', 58.28, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2022';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2022-12-31', '2022', '全年', -34.31, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2023';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2023-12-31', '2023', '全年', 52.43, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2024';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2024-12-31', '2024', '全年', 13.17, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2025';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '投资收益' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2025-12-31', '2025', '全年', 163.58, '历史年度原值；口径：合并口径', now());

INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT c.code || '.D' || lpad((coalesce((SELECT max(substring(x.code FROM '\.D(\d+)$')::int) FROM vi_metric_base x WHERE x.code LIKE c.code || '.D%'), 0) + 1)::text, 3, '0'),
       '权益法投资收益', '亿元', '财务', '年报', '全年', c.id, '年报', '年', NULL
FROM vi_company_base c WHERE c.id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND NOT EXISTS (SELECT 1 FROM vi_metric_base WHERE company_id = c.id AND name = '权益法投资收益' AND unit IS NOT DISTINCT FROM '亿元');

UPDATE vi_metric_base SET model_field = 'equity_income' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '权益法投资收益' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1);

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '权益法投资收益' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2024';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '权益法投资收益' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2024-12-31', '2024', '全年', 2.77, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '权益法投资收益' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2025';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '权益法投资收益' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2025-12-31', '2025', '全年', 3.26, '历史年度原值；口径：合并口径', now());

INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT c.code || '.D' || lpad((coalesce((SELECT max(substring(x.code FROM '\.D(\d+)$')::int) FROM vi_metric_base x WHERE x.code LIKE c.code || '.D%'), 0) + 1)::text, 3, '0'),
       '经营活动现金流量净额', '亿元', '财务', '报表计算', '全年', c.id, '财务数据（三大报表）：经营业务现金净额', '年', '经营业务现金净额'
FROM vi_company_base c WHERE c.id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND NOT EXISTS (SELECT 1 FROM vi_metric_base WHERE company_id = c.id AND name = '经营活动现金流量净额' AND unit IS NOT DISTINCT FROM '亿元');

UPDATE vi_metric_base SET model_field = 'cfo' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '经营活动现金流量净额' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1);

INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT c.code || '.D' || lpad((coalesce((SELECT max(substring(x.code FROM '\.D(\d+)$')::int) FROM vi_metric_base x WHERE x.code LIKE c.code || '.D%'), 0) + 1)::text, 3, '0'),
       '资本开支', '亿元', '财务', '报表计算', '全年', c.id, '财务数据（三大报表）：购建固定资产 + 购建无形资产及其他资产', '年', '购建固定资产 + 购建无形资产及其他资产'
FROM vi_company_base c WHERE c.id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND NOT EXISTS (SELECT 1 FROM vi_metric_base WHERE company_id = c.id AND name = '资本开支' AND unit IS NOT DISTINCT FROM '亿元');

UPDATE vi_metric_base SET model_field = 'capex' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '资本开支' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1);

INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT c.code || '.D' || lpad((coalesce((SELECT max(substring(x.code FROM '\.D(\d+)$')::int) FROM vi_metric_base x WHERE x.code LIKE c.code || '.D%'), 0) + 1)::text, 3, '0'),
       '收到投资分红', '亿元', '财务', '报表计算', '全年', c.id, '财务数据（三大报表）：已收股息(投资)', '年', '已收股息(投资)'
FROM vi_company_base c WHERE c.id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND NOT EXISTS (SELECT 1 FROM vi_metric_base WHERE company_id = c.id AND name = '收到投资分红' AND unit IS NOT DISTINCT FROM '亿元');

UPDATE vi_metric_base SET model_field = 'investee_cash_div' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '收到投资分红' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1);

INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT c.code || '.D' || lpad((coalesce((SELECT max(substring(x.code FROM '\.D(\d+)$')::int) FROM vi_metric_base x WHERE x.code LIKE c.code || '.D%'), 0) + 1)::text, 3, '0'),
       '净借款', '亿元', '财务', '年报', '全年', c.id, '年报', '年', NULL
FROM vi_company_base c WHERE c.id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND NOT EXISTS (SELECT 1 FROM vi_metric_base WHERE company_id = c.id AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元');

UPDATE vi_metric_base SET model_field = 'net_borrowing' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1);

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2018';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2018-12-31', '2018', '全年', -2.36, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2019';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2019-12-31', '2019', '全年', 66.19, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2020';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2020-12-31', '2020', '全年', 37.97, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2021';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2021-12-31', '2021', '全年', 92.27, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2022';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2022-12-31', '2022', '全年', -37.98, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2023';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2023-12-31', '2023', '全年', 48.44, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2024';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2024-12-31', '2024', '全年', 67.33, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2025';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '净借款' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2025-12-31', '2025', '全年', 52.97, '历史年度原值；口径：合并口径', now());

INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT c.code || '.D' || lpad((coalesce((SELECT max(substring(x.code FROM '\.D(\d+)$')::int) FROM vi_metric_base x WHERE x.code LIKE c.code || '.D%'), 0) + 1)::text, 3, '0'),
       '借款', '亿元', '财务', '报表计算', '时点', c.id, '财务数据（三大报表）：短期贷款 + 长期贷款', '年', '短期贷款 + 长期贷款'
FROM vi_company_base c WHERE c.id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND NOT EXISTS (SELECT 1 FROM vi_metric_base WHERE company_id = c.id AND name = '借款' AND unit IS NOT DISTINCT FROM '亿元');

UPDATE vi_metric_base SET model_field = 'interest_debt' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '借款' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1);

INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT c.code || '.D' || lpad((coalesce((SELECT max(substring(x.code FROM '\.D(\d+)$')::int) FROM vi_metric_base x WHERE x.code LIKE c.code || '.D%'), 0) + 1)::text, 3, '0'),
       '货币资金', '亿元', '财务', '年报', '时点', c.id, '年报', '年', NULL
FROM vi_company_base c WHERE c.id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND NOT EXISTS (SELECT 1 FROM vi_metric_base WHERE company_id = c.id AND name = '货币资金' AND unit IS NOT DISTINCT FROM '亿元');

UPDATE vi_metric_base SET model_field = 'cash' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '货币资金' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1);

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '货币资金' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '时点' AND period = '2018Q4';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '货币资金' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2018-12-31', '2018Q4', '时点', 330.76, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '货币资金' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '时点' AND period = '2019Q4';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '货币资金' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2019-12-31', '2019Q4', '时点', 495.71, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '货币资金' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '时点' AND period = '2020Q4';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '货币资金' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2020-12-31', '2020Q4', '时点', 855.85, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '货币资金' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '时点' AND period = '2021Q4';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '货币资金' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2021-12-31', '2021Q4', '时点', 750.68, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '货币资金' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '时点' AND period = '2022Q4';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '货币资金' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2022-12-31', '2022Q4', '时点', 782.27, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '货币资金' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '时点' AND period = '2023Q4';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '货币资金' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2023-12-31', '2023Q4', '时点', 1095.17, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '货币资金' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '时点' AND period = '2024Q4';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '货币资金' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2024-12-31', '2024Q4', '时点', 1340.08, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '货币资金' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '时点' AND period = '2025Q4';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '货币资金' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2025-12-31', '2025Q4', '时点', 1748.47, '历史年度原值；口径：合并口径', now());

INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT c.code || '.D' || lpad((coalesce((SELECT max(substring(x.code FROM '\.D(\d+)$')::int) FROM vi_metric_base x WHERE x.code LIKE c.code || '.D%'), 0) + 1)::text, 3, '0'),
       '归母净资产', '亿元', '财务', '报表计算', '时点', c.id, '财务数据（三大报表）：股东权益', '年', '股东权益'
FROM vi_company_base c WHERE c.id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND NOT EXISTS (SELECT 1 FROM vi_metric_base WHERE company_id = c.id AND name = '归母净资产' AND unit IS NOT DISTINCT FROM '亿元');

UPDATE vi_metric_base SET model_field = 'equity_parent' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '归母净资产' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1);

INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT c.code || '.D' || lpad((coalesce((SELECT max(substring(x.code FROM '\.D(\d+)$')::int) FROM vi_metric_base x WHERE x.code LIKE c.code || '.D%'), 0) + 1)::text, 3, '0'),
       '现金分红总额', '亿元', '财务', '年报', '全年', c.id, '年报', '年', NULL
FROM vi_company_base c WHERE c.id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND NOT EXISTS (SELECT 1 FROM vi_metric_base WHERE company_id = c.id AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元');

UPDATE vi_metric_base SET model_field = 'dividend_total' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1);

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2018';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2018-12-31', '2018', '全年', 0, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2019';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2019-12-31', '2019', '全年', 29.32, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2020';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2020-12-31', '2020', '全年', 4.55, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2021';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2021-12-31', '2021', '全年', 70.07, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2022';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2022-12-31', '2022', '全年', 23.86, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2023';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2023-12-31', '2023', '全年', 13.57, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2024';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2024-12-31', '2024', '全年', 40.48, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2025';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '现金分红总额' AND unit IS NOT DISTINCT FROM '亿元' ORDER BY id LIMIT 1), '2025-12-31', '2025', '全年', 61.73, '历史年度原值；口径：合并口径', now());

INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT c.code || '.D' || lpad((coalesce((SELECT max(substring(x.code FROM '\.D(\d+)$')::int) FROM vi_metric_base x WHERE x.code LIKE c.code || '.D%'), 0) + 1)::text, 3, '0'),
       '每股股息', '元', '财务', '年报', '全年', c.id, '年报', '年', NULL
FROM vi_company_base c WHERE c.id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND NOT EXISTS (SELECT 1 FROM vi_metric_base WHERE company_id = c.id AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元');

UPDATE vi_metric_base SET model_field = 'dps' WHERE id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元' ORDER BY id LIMIT 1);

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2018';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元' ORDER BY id LIMIT 1), '2018-12-31', '2018', '全年', 0, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2019';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元' ORDER BY id LIMIT 1), '2019-12-31', '2019', '全年', 0, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2020';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元' ORDER BY id LIMIT 1), '2020-12-31', '2020', '全年', 0, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2021';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元' ORDER BY id LIMIT 1), '2021-12-31', '2021', '全年', 0, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2022';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元' ORDER BY id LIMIT 1), '2022-12-31', '2022', '全年', 0, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2023';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元' ORDER BY id LIMIT 1), '2023-12-31', '2023', '全年', 0, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2024';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元' ORDER BY id LIMIT 1), '2024-12-31', '2024', '全年', 0, '历史年度原值；口径：合并口径', now());

DELETE FROM vi_observation_base WHERE metric_id = (SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元' ORDER BY id LIMIT 1) AND basis = '全年' AND period = '2025';

INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES ((SELECT id FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '每股股息' AND unit IS NOT DISTINCT FROM '元' ORDER BY id LIMIT 1), '2025-12-31', '2025', '全年', 0, '历史年度原值；口径：合并口径', now());

UPDATE vi_metric_base SET measure = '时点' WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name IN ('AIoT平台连接设备数（不含手机和平板）', '借款', '小米集团港股收盘价', '少数股东权益', '归母净资产', '拥有五件及以上AIoT设备的用户数', '现金储备', '货币资金');

UPDATE vi_metric_base SET measure = '时期' WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND measure IS NULL;

INSERT INTO vi_business_base(company_id,code,name,boundary,asset_boundary,sort) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),'S1','智能手机','手机硬件销售；互联网服务收入和利润归 S3，自研芯片等创新业务归 S5。','经营设备、品牌与渠道对盈利的贡献包含在业务价值中；经营所需现金由 C5 集团统一扣除，集团现金及投资不放进分部价值。',1) ON CONFLICT (company_id,code) DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S1'),'B1','客户细分','面向不同价位的手机用户','Redmi 覆盖入门市场，Xiaomi 数字旗舰与 Ultra 面向高端用户；用户规模与月活口径不能混用。',NULL,'境内外用户购买力和变现能力不同。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S1'),'B2','价值主张','性价比与高端化并行','以产品定义、供应链与影像等体验竞争；硬件获客后形成的互联网收入归 S3。',NULL,'高端化能否抵消存储等物料涨价需要持续验证。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S1'),'B3','渠道通路','电商、新零售及海外运营商','使用集团渠道；渠道共性见集团层，手机相关费用不能遗漏。',NULL,'门店扩张对费用率与销售效率的影响。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S1'),'B4','客户关系','硬件销售后维系设备与账户用户','手机销售形成设备用户基础；持续服务变现与硬件销售分别记录。',NULL,'换机流失会滞后影响互联网月活。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S1'),'B5','收入来源','收入＝出货量×平均售价','硬件收入与毛利单列；互联网变现不在手机分部重复确认。','业务估值 S1；正常化年份及收入见对应情景','销量、产品结构和存储周期影响正常化盈利。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S1'),'B6','核心资源','产品、供应链、品牌与设备用户基础','品牌和渠道属于共享能力；对经营盈利的贡献已包含在分部估值中。',NULL,'共享资源不等于各业务都能获得同样的超额利润。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S1'),'B7','关键业务','产品定义、研发与供应链管理','沿用现有集团画布的制造与研发描述；自研芯片创新业务暂放 S5。',NULL,'制造与研发边界须随披露更新。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S1'),'B8','重要合作','核心器件、影像与系统伙伴','依赖 SoC、存储、屏幕及系统生态伙伴，器件供应集中影响议价与成本。',NULL,'关键器件供需与替代可行性。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S1'),'B9','成本结构','硬件毛利减分摊费用','经营利润＝手机收入×毛利率−按收入分摊的生态营业费用；维持原税率、正常化年份和期间现金流。','共同费用分摊：J-OPEX；估值参数：S1','按收入分摊是研究假设，不能将推算损益等同公司披露分部利润。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_business_base(company_id,code,name,boundary,asset_boundary,sort) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),'S2','AIoT 与生活消费产品','IoT 与生活消费产品，含其他相关业务；生态链公司的股权投资归资产项目 C8，不重复作为自营业务。','服务经营的设备、渠道与品牌包含在业务价值中；对外股权持仓在 C8 单独计价，经营所需现金在 C5 统一处理。',2) ON CONFLICT (company_id,code) DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S2'),'B1','客户细分','个人设备与家庭消费用户','覆盖可穿戴、平板、电视、大家电等生活消费产品；连接设备数不是月活用户数。',NULL,'不同品类购买频率和竞争格局存在差异。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S2'),'B2','价值主张','产品性价比与设备协同','通过米家等设备连接提升跨品类使用体验；不把连接规模直接当作利润。',NULL,'生态锁定程度与产品独立竞争力需要分开验证。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S2'),'B3','渠道通路','集团新零售与电商渠道','共用渠道的机制见集团层；各品类渠道费用与销售结构影响分摊。',NULL,'渠道扩张与国补变化影响需求。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S2'),'B4','客户关系','多设备与家庭场景复购','多设备使用形成交叉销售机会，需以实际复购和毛利验证。',NULL,'设备连接不保证付费或复购。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S2'),'B5','收入来源','各类产品销售收入加总','估值口径合并 IoT 与生活消费产品和其他相关业务；对外股权投资另放 C8。','业务估值 S2，含其他相关业务','产品组合与补贴变化影响收入和毛利率。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S2'),'B6','核心资源','产品定义、渠道与生态链伙伴','共享品牌、零售渠道和设备生态；被投企业的股权价值不在此重复加计。',NULL,'合作利益与集团利益可能不一致。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S2'),'B7','关键业务','跨品类产品与供应链组织','围绕产品定义、供应链、渠道与设备连接开展经营；各品类的经营资产贡献包含在盈利中。',NULL,'品类扩张可能同时增加管理复杂度。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S2'),'B8','重要合作','生态链制造与供应伙伴','合作伙伴提供产品和制造能力，集团提供品牌、渠道及生态连接。',NULL,'伙伴依赖、质量与利润分配。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S2'),'B9','成本结构','产品毛利减共享费用','按分项毛利率与 J-OPEX 的收入分摊费用率估算经营利润，沿用正常化及过渡期现金流。','共同费用分摊：J-OPEX；估值参数：S2','毛利率结构升级与国补退坡均需验证。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_business_base(company_id,code,name,boundary,asset_boundary,sort) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),'S3','互联网服务','设备用户的广告、游戏及其他互联网服务变现；硬件收入归 S1、S2。','用户、账户、软件及相关经营资产的贡献包含在盈利估值中，不另加用户或生态溢价；集团现金与投资另算。',3) ON CONFLICT (company_id,code) DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S3'),'B1','客户细分','设备用户与服务付费方','设备用户形成流量基础；广告、游戏等业务的付款方和使用者可能不同。',NULL,'用户数量和单位用户价值分别跟踪。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S3'),'B2','价值主张','基于设备入口提供互联网服务','通过广告、游戏等服务变现；与硬件获客相互依赖。',NULL,'用户体验、监管和竞争约束变现强度。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S3'),'B3','渠道通路','账户、系统与设备入口','依托存量设备和系统服务触达用户，入口来自手机等硬件业务。',NULL,'入口控制与合作安排可能变化。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S3'),'B4','客户关系','随设备持续使用形成服务关系','收入取决于活跃用户及单位用户变现，不等同于硬件当期出货收入。',NULL,'设备用户流失可能滞后传导。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S3'),'B5','收入来源','收入＝活跃用户×单位用户变现','广告、游戏等收入汇总；收入、毛利与共享获客成本分别观察。','业务估值 S3；用户与变现数据见既有事实','国内外用户变现差异，不能只外推集团月活。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S3'),'B6','核心资源','用户基础、账户与系统运营能力','现有用户及软件的经营贡献已反映在盈利估值中，不另加生态溢价。',NULL,'流量规模能否维持以及变现是否透支体验。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S3'),'B7','关键业务','服务运营与流量变现','运营广告、游戏及其他互联网服务，并与设备业务协同获客。',NULL,'变现效率与服务体验的平衡。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S3'),'B8','重要合作','内容、广告与系统生态伙伴','业务依赖广告主、内容和服务伙伴及系统生态；具体合同条款未在此补造。',NULL,'合作方议价、合规及分成变化。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S3'),'B9','成本结构','高毛利服务仍需承担共享成本','互联网毛利减按收入分摊的生态共同费用，防止手机承担全部获客成本而互联网只保留利润。','共同费用分摊：J-OPEX；估值参数：S3','更换分摊方式会改变各业务价值，需要通过情景检验。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_business_base(company_id,code,name,boundary,asset_boundary,sort) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),'S4','智能电动汽车','汽车及相关服务，不含 AI、大模型、芯片与机器人；延续 J-EV-SPLIT 的估算拆分。','汽车工厂及生产设施的经营贡献包含在稳态盈利与期间现金流中，不再按账面固定资产加计；资本开支沿用原假设。',4) ON CONFLICT (company_id,code) DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S4'),'B1','客户细分','汽车消费用户','面向汽车消费者，用户可能来自小米设备生态之外；沿用集团画布与现有汽车事实。',NULL,'不能以手机月活直接推算汽车销量。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S4'),'B2','价值主张','汽车产品与智能体验','以汽车产品、交付质量及使用体验竞争，与手机硬件和互联网服务分别估值。',NULL,'产品竞争、价格战与质量反馈。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S4'),'B3','渠道通路','汽车销售、交付及服务渠道','汽车有专门门店与交付服务体系，同时使用集团品牌和部分渠道能力。',NULL,'扩张速度与渠道效率。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S4'),'B4','客户关系','购车到交付后的持续服务','客户关系跨越订单、交付和车辆使用周期；手机用户关系不能直接替代汽车关系。',NULL,'订单转交付、服务与口碑。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S4'),'B5','收入来源','收入＝交付量×平均售价＋相关收入','沿用汽车稳态经营假设，收入和利润中剔出 AI 等创新业务。','业务估值 S4；稳态年份 2030','交付规模、ASP 和稳态利润率。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S4'),'B6','核心资源','汽车产品、工厂与组织能力','工厂与生产设施为业务创造利润，其价值包含在稳态盈利与期间现金流中。','资产边界登记 A4：已含业务估值','生产、供应链与质量管理仍需验证。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S4'),'B7','关键业务','产品研发、制造与交付服务','沿用现有汽车自建工厂及量产描述，资本开支和营运资本沿用原模型。',NULL,'爬坡中的产能利用率与资金需求。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S4'),'B8','重要合作','电池与汽车供应链伙伴','沿用现有电池及供应链证据，供应集中与交付能力影响经营。',NULL,'供应依赖与零部件成本。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S4'),'B9','成本结构','汽车毛利减汽车本身费用','汽车经营费用与 AI 投入按 J-EV-SPLIT 拆开；稳态价值加期间现金流，不再加汽车工厂账面价值。','估值参数 S4；拆分依据 J-EV-SPLIT','AI 拆分估计、价格战和执行风险。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_business_base(company_id,code,name,boundary,asset_boundary,sort) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),'S5','AI、芯片与机器人','沿用现有估值分组，暂合并大模型、芯片与机器人；三者商业化路径不同，披露足够后可继续拆分。','直接估值沿用既有整体口径；未来投入及集团现金支持的重叠问题保留在 T4/J-AI，不因本次结构调整视作已解决。',5) ON CONFLICT (company_id,code) DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S5'),'B1','客户细分','客户与付费场景尚待明确','大模型、芯片、机器人目前合并跟踪，不能认定三者具有同一种已验证的付费客户。',NULL,'客户、收入及对内对外使用口径待核验。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S5'),'B2','价值主张','模型、芯片与机器人能力探索','经营价值取决于未来应用与商业化；现有直接估值是研究判断。',NULL,'研发能力不自动等于可持续盈利。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S5'),'B3','渠道通路','独立销售渠道尚待验证','可能与集团产品协同，但尚无足够证据确认稳定的独立销售和交付路径。',NULL,'对内协同收益和对外收入不能混计。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S5'),'B4','客户关系','持续使用与付费机制待验证','尚不能用手机月活或集团用户关系替代 AI 业务留存和付费数据。',NULL,'商业化与留存证据不足。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S5'),'B5','收入来源','尚未建立可靠盈利预测','沿用直接估值方法，不补造收入、利润率或现金流；后续披露足够时再拆分及建模。','业务估值 S5；直接估值沿用既有情景','可比公司口径、资金归属及未来投入均影响价值。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S5'),'B6','核心资源','研发团队、技术与集团应用场景','沿用现有 AI 与芯片证据；技术能力能否形成壁垒仍需验证。',NULL,'投入规模不等于技术壁垒或股东价值。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S5'),'B7','关键业务','大模型、芯片及机器人研发','暂作为同一投入期估值分组，业务边界明示；继续拆分需独立的经营与资金披露。',NULL,'研发交付、商业化与投入节奏。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S5'),'B8','重要合作','研发与产业合作待持续核验','不从可比公司估值推断小米实际客户、合作条款或供应关系。',NULL,'技术生态与外部依赖变化。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S5'),'B9','成本结构','研发投入与资金口径须单列','沿用原整体直接估值，暂不新增成本扣减；可比估值自带现金而小米由集团出资的口径风险保留在 T4/J-AI。','费用与资金边界见 J-AI、J-EV-SPLIT','不能将资金口径尚待裁决解释为已经消除重复计价。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_lnk_biz_model_facts(biz_model_id,fact_id,"createdAt","updatedAt")
SELECT DISTINCT canvas.id,f.id,now(),now() FROM (VALUES ('S1','B1','2026 年二季度手机出货'),('S1','B1','2026 年二季度中国大陆：'),('S1','B2','2026 年二季度手机出货'),('S1','B3','小米之家：'),('S1','B4','全球月活（12 月）'),('S1','B7','2025 年研发'),('S1','B8','存储成本：'),('S1','B9','生态营业费用率'),('S1','B9','2026 年上半年分业务：'),('S2','B1','AIoT 连接设备'),('S2','B2','AIoT 连接设备'),('S2','B3','小米之家：'),('S2','B4','AIoT 连接设备'),('S2','B5','2025 年 IoT 收入'),('S2','B5','2026 年二季度 IoT'),('S2','B6','AIoT 连接设备'),('S2','B9','生态营业费用率'),('S2','B9','2026 年上半年分业务：'),('S3','B1','全球月活 2026'),('S3','B1','2025 年广告收入'),('S3','B2','互联网服务：'),('S3','B3','全球月活（12 月）'),('S3','B4','全球月活（12 月）'),('S3','B5','互联网服务：'),('S3','B5','2025 年广告收入'),('S3','B6','全球月活 2026'),('S3','B7','互联网服务：'),('S3','B9','生态营业费用率'),('S3','B9','2026 年上半年分业务：'),('S4','B1','新一代 SU7'),('S4','B2','2025 年交付'),('S4','B3','小米之家：'),('S4','B4','新一代 SU7'),('S4','B5','2025 年交付'),('S4','B5','2026 年二季度汽车及 AI'),('S4','B6','2026 年上半年资本开支'),('S4','B7','2026 年上半年资本开支'),('S4','B9','汽车及 AI 分部经营开支：'),('S5','B2','管理层：未来三年 AI'),('S5','B2','MiMo-V2.5'),('S5','B5','MiMo-V2.5'),('S5','B6','管理层：未来三年 AI'),('S5','B6','MiMo-V2.5'),('S5','B7','管理层：未来三年 AI'),('S5','B7','2025 年研发'),('S5','B9','管理层：未来三年 AI'),('S5','B9','大模型公司按收入')) e(business_code,canvas_code,fact_prefix)
JOIN vi_business_base b ON b.company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND b.code=e.business_code
JOIN vi_biz_model_base canvas ON canvas.business_id=b.id AND canvas.code=e.canvas_code
JOIN vi_fact_base f ON f.company_id=b.company_id AND f.title LIKE e.fact_prefix||'%'
ON CONFLICT DO NOTHING;

INSERT INTO vi_change_log_base(company_id,change_date,title,target,old_value,new_value,reason,basis,verification)
SELECT (SELECT id FROM vi_company_base WHERE code='01810.HK'),'2026-10-26','打通多业务商业模式与业务／资产估值','业务分部、商业模式、经营分部估值、资产估值与调整',
'集团九项画布与分部估值没有业务关联；固定资产只能通过其他调整表达。',
'五块业务身份连接分业务画布和三情景估值；现金、投资与负债独立汇总；经营固定资产登记为已含业务估值，不重复加计。',
'按用户要求区分业务估值和资产估值，并明确共享费用、经营资产与未来投入的边界。',
'沿用已有事实与估值输入；不新增资产公允价值，也不裁决 T4／J-AI 的资金口径争议。',
'隔离迁移与空库重建通过；原三情景估值不变；独立固定资产、情景覆盖、缺失金额与重复计价边界已验证。'
WHERE NOT EXISTS(SELECT 1 FROM vi_change_log_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND title='打通多业务商业模式与业务／资产估值');

INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, measure, notes) SELECT (SELECT c.code || '.T' || lpad((coalesce((SELECT max(substring(x.code FROM '\.T(\d+)$')::int) FROM vi_metric_base x WHERE x.code LIKE c.code || '.T%'), 0) + 1)::text, 3, '0') FROM vi_company_base c WHERE c.id = (SELECT id FROM vi_company_base WHERE code = '01810.HK')), '同业毛利率：理想汽车', '%', '其他', '手工整理', '半年累计', (SELECT id FROM vi_company_base WHERE code = '01810.HK'), '跟踪脚本 companies/01810_小米集团/track.py：东方财富港股报表（akshare stock_financial_hk_report_em），毛利率＝毛利÷营业额', '半年', '时期', '与小米“汽车及AI分部毛利率”对照（说明里写同期小米的值）。' WHERE NOT EXISTS (SELECT 1 FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '同业毛利率：理想汽车' AND unit IS NOT DISTINCT FROM '%');

UPDATE vi_metric_base SET category = '其他', basis = '半年累计', source_name = '跟踪脚本 companies/01810_小米集团/track.py：东方财富港股报表（akshare stock_financial_hk_report_em），毛利率＝毛利÷营业额', frequency = '半年', measure = '时期', notes = '与小米“汽车及AI分部毛利率”对照（说明里写同期小米的值）。' WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '同业毛利率：理想汽车' AND unit IS NOT DISTINCT FROM '%';

INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, measure, notes) SELECT (SELECT c.code || '.T' || lpad((coalesce((SELECT max(substring(x.code FROM '\.T(\d+)$')::int) FROM vi_metric_base x WHERE x.code LIKE c.code || '.T%'), 0) + 1)::text, 3, '0') FROM vi_company_base c WHERE c.id = (SELECT id FROM vi_company_base WHERE code = '01810.HK')), '同业毛利率：小鹏汽车', '%', '其他', '手工整理', '半年累计', (SELECT id FROM vi_company_base WHERE code = '01810.HK'), '跟踪脚本 companies/01810_小米集团/track.py：东方财富港股报表（akshare stock_financial_hk_report_em），毛利率＝毛利÷营业额', '半年', '时期', '与小米“汽车及AI分部毛利率”对照（说明里写同期小米的值）。' WHERE NOT EXISTS (SELECT 1 FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '同业毛利率：小鹏汽车' AND unit IS NOT DISTINCT FROM '%');

UPDATE vi_metric_base SET category = '其他', basis = '半年累计', source_name = '跟踪脚本 companies/01810_小米集团/track.py：东方财富港股报表（akshare stock_financial_hk_report_em），毛利率＝毛利÷营业额', frequency = '半年', measure = '时期', notes = '与小米“汽车及AI分部毛利率”对照（说明里写同期小米的值）。' WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '同业毛利率：小鹏汽车' AND unit IS NOT DISTINCT FROM '%';

INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, measure, notes) SELECT (SELECT c.code || '.T' || lpad((coalesce((SELECT max(substring(x.code FROM '\.T(\d+)$')::int) FROM vi_metric_base x WHERE x.code LIKE c.code || '.T%'), 0) + 1)::text, 3, '0') FROM vi_company_base c WHERE c.id = (SELECT id FROM vi_company_base WHERE code = '01810.HK')), '同业毛利率：零跑汽车', '%', '其他', '手工整理', '半年累计', (SELECT id FROM vi_company_base WHERE code = '01810.HK'), '跟踪脚本 companies/01810_小米集团/track.py：东方财富港股报表（akshare stock_financial_hk_report_em），毛利率＝毛利÷营业额', '半年', '时期', '与小米“汽车及AI分部毛利率”对照（说明里写同期小米的值）。' WHERE NOT EXISTS (SELECT 1 FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '同业毛利率：零跑汽车' AND unit IS NOT DISTINCT FROM '%');

UPDATE vi_metric_base SET category = '其他', basis = '半年累计', source_name = '跟踪脚本 companies/01810_小米集团/track.py：东方财富港股报表（akshare stock_financial_hk_report_em），毛利率＝毛利÷营业额', frequency = '半年', measure = '时期', notes = '与小米“汽车及AI分部毛利率”对照（说明里写同期小米的值）。' WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '同业毛利率：零跑汽车' AND unit IS NOT DISTINCT FROM '%';

INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, measure, notes) SELECT (SELECT c.code || '.T' || lpad((coalesce((SELECT max(substring(x.code FROM '\.T(\d+)$')::int) FROM vi_metric_base x WHERE x.code LIKE c.code || '.T%'), 0) + 1)::text, 3, '0') FROM vi_company_base c WHERE c.id = (SELECT id FROM vi_company_base WHERE code = '01810.HK')), '同业毛利率：蔚来', '%', '其他', '手工整理', '全年', (SELECT id FROM vi_company_base WHERE code = '01810.HK'), '跟踪脚本 companies/01810_小米集团/track.py：东方财富港股报表（akshare stock_financial_hk_report_em），毛利率＝毛利÷营业额', '年', '时期', '与小米“汽车及AI分部毛利率”对照（说明里写同期小米的值）。' WHERE NOT EXISTS (SELECT 1 FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '同业毛利率：蔚来' AND unit IS NOT DISTINCT FROM '%');

UPDATE vi_metric_base SET category = '其他', basis = '全年', source_name = '跟踪脚本 companies/01810_小米集团/track.py：东方财富港股报表（akshare stock_financial_hk_report_em），毛利率＝毛利÷营业额', frequency = '年', measure = '时期', notes = '与小米“汽车及AI分部毛利率”对照（说明里写同期小米的值）。' WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '同业毛利率：蔚来' AND unit IS NOT DISTINCT FROM '%';

INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, measure, notes) SELECT (SELECT c.code || '.T' || lpad((coalesce((SELECT max(substring(x.code FROM '\.T(\d+)$')::int) FROM vi_metric_base x WHERE x.code LIKE c.code || '.T%'), 0) + 1)::text, 3, '0') FROM vi_company_base c WHERE c.id = (SELECT id FROM vi_company_base WHERE code = '01810.HK')), '同业毛利率：传音控股', '%', '其他', '手工整理', '单季', (SELECT id FROM vi_company_base WHERE code = '01810.HK'), '跟踪脚本：新浪财报（akshare stock_financial_report_sina），毛利率＝1 − 营业成本÷营业收入', '季', '时期', '新兴市场手机龙头；与小米“智能手机毛利率”对照。' WHERE NOT EXISTS (SELECT 1 FROM vi_metric_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '同业毛利率：传音控股' AND unit IS NOT DISTINCT FROM '%');

UPDATE vi_metric_base SET category = '其他', basis = '单季', source_name = '跟踪脚本：新浪财报（akshare stock_financial_report_sina），毛利率＝1 − 营业成本÷营业收入', frequency = '季', measure = '时期', notes = '新兴市场手机龙头；与小米“智能手机毛利率”对照。' WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND name = '同业毛利率：传音控股' AND unit IS NOT DISTINCT FROM '%';

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '同业毛利率：理想汽车', '单季', '%', '2023Q1', '2023-03-31', 20.39, NULL, NULL, NULL);

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '同业毛利率：理想汽车', '半年累计', '%', '2023H1', '2023-06-30', 21.22, NULL, NULL, NULL);

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '同业毛利率：理想汽车', '全年', '%', '2023', '2023-12-31', 22.2, NULL, NULL, NULL);

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '同业毛利率：理想汽车', '单季', '%', '2024Q1', '2024-03-31', 20.61, NULL, NULL, NULL);

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '同业毛利率：理想汽车', '半年累计', '%', '2024H1', '2024-06-30', 20.0, NULL, NULL, NULL);

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '同业毛利率：理想汽车', '全年', '%', '2024', '2024-12-31', 20.53, NULL, NULL, NULL);

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '同业毛利率：理想汽车', '单季', '%', '2025Q1', '2025-03-31', 20.51, NULL, '同期小米汽车及AI分部 23.17%', NULL);

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '同业毛利率：理想汽车', '半年累计', '%', '2025H1', '2025-06-30', 20.27, NULL, '同期小米汽车及AI分部 24.92%', NULL);

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '同业毛利率：理想汽车', '全年', '%', '2025', '2025-12-31', 18.68, NULL, '同期小米汽车及AI分部 24.29%', NULL);

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '同业毛利率：理想汽车', '单季', '%', '2026Q1', '2026-03-31', 7.87, NULL, '同期小米汽车及AI分部 20.11%', NULL);

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '同业毛利率：理想汽车', '半年累计', '%', '2026H1', '2026-06-30', 9.55, NULL, '同期小米汽车及AI分部 19.63%', NULL);

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '同业毛利率：小鹏汽车', '半年累计', '%', '2023H1', '2023-06-30', -1.43, NULL, NULL, NULL);

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '同业毛利率：小鹏汽车', '全年', '%', '2023', '2023-12-31', 1.47, NULL, NULL, NULL);

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '同业毛利率：小鹏汽车', '半年累计', '%', '2024H1', '2024-06-30', 13.5, NULL, NULL, NULL);

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '同业毛利率：小鹏汽车', '全年', '%', '2024', '2024-12-31', 14.3, NULL, NULL, NULL);

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '同业毛利率：小鹏汽车', '半年累计', '%', '2025H1', '2025-06-30', 16.51, NULL, '同期小米汽车及AI分部 24.92%', NULL);

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '同业毛利率：小鹏汽车', '全年', '%', '2025', '2025-12-31', 18.86, NULL, '同期小米汽车及AI分部 24.29%', NULL);

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '同业毛利率：小鹏汽车', '半年累计', '%', '2026H1', '2026-06-30', 20.64, NULL, '同期小米汽车及AI分部 19.63%', NULL);

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '同业毛利率：零跑汽车', '半年累计', '%', '2023H1', '2023-06-30', -5.88, NULL, NULL, NULL);

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '同业毛利率：零跑汽车', '全年', '%', '2023', '2023-12-31', 0.48, NULL, NULL, NULL);

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '同业毛利率：零跑汽车', '半年累计', '%', '2024H1', '2024-06-30', 1.13, NULL, NULL, NULL);

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '同业毛利率：零跑汽车', '全年', '%', '2024', '2024-12-31', 8.38, NULL, NULL, NULL);

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '同业毛利率：零跑汽车', '半年累计', '%', '2025H1', '2025-06-30', 14.13, NULL, '同期小米汽车及AI分部 24.92%', NULL);

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '同业毛利率：零跑汽车', '全年', '%', '2025', '2025-12-31', 14.54, NULL, '同期小米汽车及AI分部 24.29%', NULL);

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '同业毛利率：零跑汽车', '半年累计', '%', '2026H1', '2026-06-30', 11.67, NULL, '同期小米汽车及AI分部 19.63%', NULL);

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '同业毛利率：蔚来', '半年累计', '%', '2023H1', '2023-06-30', 1.52, NULL, NULL, NULL);

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '同业毛利率：蔚来', '全年', '%', '2023', '2023-12-31', 6.2, NULL, NULL, NULL);

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '同业毛利率：蔚来', '全年', '%', '2024', '2024-12-31', 11.15, NULL, NULL, NULL);

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '同业毛利率：蔚来', '全年', '%', '2025', '2025-12-31', 15.5, NULL, '同期小米汽车及AI分部 24.29%', NULL);

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '同业毛利率：传音控股', '全年', '%', '2019', '2019-12-31', 27.36, NULL, NULL, NULL);

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '同业毛利率：传音控股', '全年', '%', '2020', '2020-12-31', 23.64, NULL, NULL, NULL);

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '同业毛利率：传音控股', '全年', '%', '2021', '2021-12-31', 21.3, NULL, NULL, NULL);

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '同业毛利率：传音控股', '全年', '%', '2022', '2022-12-31', 21.32, NULL, NULL, NULL);

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '同业毛利率：传音控股', '单季', '%', '2023Q1', '2023-03-31', 23.36, NULL, NULL, NULL);

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '同业毛利率：传音控股', '单季', '%', '2023Q2', '2023-06-30', 23.65, NULL, NULL, NULL);

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '同业毛利率：传音控股', '单季', '%', '2023Q3', '2023-09-30', 24.44, NULL, NULL, NULL);

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '同业毛利率：传音控股', '全年', '%', '2023', '2023-12-31', 23.55, NULL, NULL, NULL);

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '同业毛利率：传音控股', '单季', '%', '2023Q4', '2023-12-31', 22.71, NULL, NULL, NULL);

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '同业毛利率：传音控股', '单季', '%', '2024Q1', '2024-03-31', 21.37, NULL, NULL, NULL);

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '同业毛利率：传音控股', '单季', '%', '2024Q2', '2024-06-30', 21.68, NULL, NULL, NULL);

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '同业毛利率：传音控股', '单季', '%', '2024Q3', '2024-09-30', 21.72, NULL, NULL, NULL);

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '同业毛利率：传音控股', '全年', '%', '2024', '2024-12-31', 21.28, NULL, NULL, NULL);

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '同业毛利率：传音控股', '单季', '%', '2024Q4', '2024-12-31', 20.38, NULL, NULL, NULL);

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '同业毛利率：传音控股', '单季', '%', '2025Q1', '2025-03-31', 19.27, NULL, NULL, NULL);

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '同业毛利率：传音控股', '单季', '%', '2025Q2', '2025-06-30', 20.76, NULL, NULL, NULL);

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '同业毛利率：传音控股', '单季', '%', '2025Q3', '2025-09-30', 18.59, NULL, NULL, NULL);

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '同业毛利率：传音控股', '全年', '%', '2025', '2025-12-31', 19.15, NULL, NULL, NULL);

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '同业毛利率：传音控股', '单季', '%', '2025Q4', '2025-12-31', 18.17, NULL, NULL, NULL);

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '同业毛利率：传音控股', '单季', '%', '2026Q1', '2026-03-31', 22.0, NULL, NULL, NULL);

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '同业毛利率：传音控股', '单季', '%', '2026Q2', '2026-06-30', 23.16, NULL, NULL, NULL);

SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01810.HK'), '同业毛利率：传音控股', '单季', '%', '2026Q3', '2026-09-30', 22.66, NULL, NULL, NULL);

-- 小米集团研究增强（2026-11-05）：汽车与手机同业毛利率接入；待办推进。
-- 数据来自跟踪脚本（track.py → data/track.json，种子在此之前已写入）；本文件只改研究正文、补关联与待办，按业务键定位，可重复执行。

UPDATE vi_thesis_base SET decisive_evidence = '月度交付（四季度能否月均 5.5 万辆以上）；2027 年交付与 ASP；汽车及 AI 分部毛利率与经营损益；海外首年销量。'
  || '同业对比（跟踪脚本，公告口径）：2025 年小米汽车及 AI 分部毛利率 24.3%，小鹏 18.9%、蔚来 15.5%、零跑 14.5%，领先明显；2026 年上半年降到 19.6%（一季度 20.1%、二季度 19.3%），已略低于小鹏（20.6%）、仍高于零跑（11.7%）——“比同业更赚钱”的优势在收窄，看三季度能否止跌。'
WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND code = 'T3';

UPDATE vi_thesis_base SET decisive_evidence = '2026 年三、四季度及 2027 年上半年的手机毛利率与 ASP、生态营业费用率；DRAM/NAND 合约价；出货份额。'
  || '对照（跟踪脚本）：传音控股单季毛利率 2026 年一至三季度 22.0%、23.2%、22.7%，同期小米智能手机 10.1%、8.5%（三季度待公告）——存储涨价下传音毛利率反而上升，说明不是全行业同压；小米的回落更多来自自身产品与定价结构，验证“周期过后能回到 11%—12%”时要看高端机占比。'
WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND code = 'T2';

WITH co AS (SELECT id FROM vi_company_base WHERE code = '01810.HK')
INSERT INTO vi_lnk_thesis_basis_metrics (thesis_id, metric_id, "createdAt", "updatedAt")
SELECT t.id, m.id, now(), now() FROM vi_thesis_base t JOIN vi_metric_base m ON m.company_id = t.company_id AND
  ((t.code = 'T3' AND m.name IN ('同业毛利率：理想汽车', '同业毛利率：小鹏汽车', '同业毛利率：零跑汽车', '同业毛利率：蔚来'))
   OR (t.code = 'T2' AND m.name = '同业毛利率：传音控股'))
WHERE t.company_id = (SELECT id FROM co) ON CONFLICT DO NOTHING;

UPDATE vi_issue_base SET status = '处理中', progress = '2026-11-05：汽车同业（理想、小鹏、零跑、蔚来）与手机同业（传音）的毛利率改用公告口径，由跟踪脚本每期更新（track.py）；交付、份额、单车利润仍需以公司公告或年报核对。'
WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND code = 'Q08';

UPDATE vi_issue_base SET progress = '2026-11-05 检索：未见 2026 年判决、上诉或和解的公开报道。已知进展：2022 年印度执法局冻结约 555.1 亿卢比（约 47 亿元人民币），卡纳塔克邦高等法院 2022 年 5 月暂缓、10 月要求银行保函，2023 年 4 月 FEMA 主管机关确认冻结，公司就 FEMA 第 37 条合宪性起诉，高院已保留判决。模型未计入这笔资金，也未计罚款；判决后按结果调整“其他调整”。'
WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND code = 'Q09';

UPDATE vi_issue_base SET status = '处理中', progress = '分析（2026-11-05）：模型利润率按国际财务报告准则的费用分摊，已含股权激励费用；再按摊薄股本（约 264 亿股）算每股，重复的只是“已授出、未归属”的那部分——它们今后的费用在利润率里扣一次、股数里又摊一次；未来新授出的部分只在费用里扣，不重复。'
  || '所以两种处理的差（每股约 −2.7%）是重复计算的上限，实际重复小于它。建议（需你确认）：保留摊薄股本作为保守口径，在估值说明里注明“偏保守，上限约 2.7%”，不再另调利润率。'
WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND code = 'Q10';

-- 安全边际只保留 10% 一档（你确认，2026-11-05）
INSERT INTO vi_change_log_base (change_date, title, target, old_value, new_value, reason, basis, verification, company_id, created_at, updated_at)
SELECT '2026-11-05', '安全边际只保留 10% 一档', '估值模型：安全边际（低档 10%、高档取消）', '10% / 30% 两档并列', '10% 一档（关注价＝今天价值×90%）',
  '你确定交易纪律：安全边际用 10%', '用户决定', '关注价只显示一个；估值不变', c.id, now(), now()
FROM vi_company_base c WHERE c.code = '01810.HK' AND NOT EXISTS (SELECT 1 FROM vi_change_log_base x WHERE x.company_id = c.id AND x.title = '安全边际只保留 10% 一档');
UPDATE vi_issue_base SET status = '已解决', progress = '2026-11-05：你确定安全边际用 10%，估值模型只保留一档（关注价＝基准每股价值×90%）。'
WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND code = 'Q01';
UPDATE vi_issue_base SET status = '已解决', progress = progress || '　2026-11-05 你确认：保留摊薄股本（约 264 亿股）作为保守口径，不另调利润率；重复计算的上限约每股 2.7%。'
WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND code = 'Q10' AND progress NOT LIKE '%2026-11-05 你确认%';
-- （2026-11-11 估值重构：估值模型已删除，股本说明在公司备注里）


-- 小米集团：重要事实 → 定性事实，并按“事项 → 侧面”两层组织（2026-11-05，规则与腾讯音乐 2026-11-04 相同）。
-- 按名称定位，可重复执行（新旧标题都认）；种子在最后执行本文件（研究增强之后）。
-- 1. 引用了“数字事实”的上层判断，改为（或另外）关联对应的“依据指标”
-- 2. 精简 13 条（只留定性部分）；删除 12 条数字已在指标里的事实；8 条年度口径备注并入一条来源文档，其中的资本运作事件合成一条定性事实
-- 3. 卖方观点、AI 公司估值、整车同业这类外部参照保留
-- 4. 建 15 个事项，每条定性事实改成短的侧面名称挂到事项下（“实际税率”“资本开支分部”不挂事项）

-- 1. 引用改接指标（按指标名称定位：编号随建库顺序变化，名称不变）
CREATE TEMP TABLE xm_fact_metric (title text, metrics text[]) ON COMMIT DROP;
INSERT INTO xm_fact_metric VALUES
  ('2025 年收入 4,572.9 亿元，经调整净利润 391.7 亿元', ARRAY['营业收入', '经调整净利润', '归母净利润', '毛利率']),
  ('2026 年二季度收入 1,089.2 亿元（−6.1%），经调整净利润 62.2 亿元（−42.6%）', ARRAY['营业收入', '经调整净利润', '毛利率', '期间利润（国际财务报告准则）']),
  ('2025 年分部：手机×AIoT 3,512.2 亿元（毛利率 21.7%），汽车及 AI 1,060.7 亿元（经营收益 9 亿元）', ARRAY['手机×AIoT 分部收入', '智能电动汽车及AI分部收入', '手机×AIoT 分部毛利率', '汽车及AI分部毛利率', '汽车及AI分部经营损益']),
  ('全球月活（12 月）2018—2025 年：2.42 亿 → 7.54 亿', ARRAY['全球月活跃用户']),
  ('手机出货 2020—2025 年：1.464、1.903、1.505、1.456、1.685、1.652 亿台', ARRAY['智能手机出货量']),
  ('2026 年一季度汽车及 AI 分部经营亏损 31 亿元，交付 80,856 辆', ARRAY['智能电动汽车及AI分部收入', '汽车及AI分部毛利率', '汽车交付量', '汽车ASP', '汽车及AI分部经营损益']),
  ('生态经营利润按季：2025 年 104.6、92.1、60.4、21.4 亿元，2026 年 60.6、48.5 亿元', ARRAY['生态经营利润（推算）']),
  ('生态（手机×AIoT）经营利润率：2024 年 8.6%、2025 年 7.9%、2026 年上半年 6.7%', ARRAY['生态经营利润（推算）', '生态经营利润率（推算）']),
  ('生态经营利润率 2019—2025 年：3.7%、3.7%、5.9%、2.9%、7.6%、8.6%、7.9%', ARRAY['生态经营利润率（推算）']),
  ('生态营业费用率 2019—2025 年：10.2%、11.2%、11.8%、14.1%、13.6%、12.6%、13.7%；2026 年上半年 14.5%', ARRAY['生态营业费用率（推算）']),
  ('AIoT 连接设备 11.608 亿台（+17.4%），五件以上设备用户 2,460 万（+20.2%）', ARRAY['AIoT平台连接设备数（不含手机和平板）', '拥有五件及以上AIoT设备的用户数']),
  ('2026-10-22 收盘 25.80 港元（约 21.96 元），近一年最高收盘 47.14 港元', ARRAY['小米集团港股收盘价']),
  ('2025 年手机收入 1,864.4 亿元、毛利率 10.9%、出货 1.652 亿台；四季度毛利率 8.3%', ARRAY['智能手机收入', '智能手机毛利率', '智能手机出货量', '智能手机ASP']),
  ('2026 年二季度手机出货 3,120 万台（−26.5%）、ASP 1,351 元（+25.9%）、毛利率 8.5%', ARRAY['智能手机收入', '智能手机毛利率', '智能手机出货量', '智能手机ASP']),
  ('互联网服务：2025 年 374.4 亿元（+9.7%）、毛利率 76.5%；2026 年二季度 90.4 亿元（−0.6%）', ARRAY['互联网服务收入', '互联网服务毛利率']),
  ('2025 年 IoT 收入 1,232.0 亿元（+18.3%）、毛利率 23.1%；大家电 +23.1%', ARRAY['IoT与生活消费产品收入', 'IoT毛利率']),
  ('2026 年二季度 IoT 与生活消费产品收入 312.8 亿元（−19.2%），国补退坡', ARRAY['IoT与生活消费产品收入', 'IoT毛利率']),
  ('全球月活 2026 年 6 月 7.665 亿（+4.8%），中国大陆 1.977 亿（+7.0%）', ARRAY['全球月活跃用户']),
  ('2025 年交付 411,082 辆、汽车收入 1,033 亿元、ASP 25.12 万元；2026 年目标 55 万辆', ARRAY['汽车交付量', '汽车ASP']),
  ('2026 年二季度汽车及 AI 分部：收入 249.0 亿元、交付 104,199 辆、ASP 22.93 万元、毛利率 19.2%、经营亏损 26 亿元', ARRAY['智能电动汽车及AI分部收入', '汽车及AI分部毛利率', '汽车交付量', '汽车ASP', '汽车及AI分部经营损益']),
  ('2025 年研发 331.3 亿元（+37.8%）；2026—2030 年累计研发预计超 2,000 亿元', ARRAY['研发开支']),
  ('2025 年回购 63 亿港元（1.526 亿股）；2026 年 1 月首次公告自动回购计划', ARRAY['回购（港元）']),
  ('2026-06-30 现金储备 2,193 亿元，借款 393 亿元（含可换股债券 50.8 亿元）', ARRAY['现金储备', '借款']),
  ('实际所得税率：2024 年 16.2%、2025 年 16.3%、2026 年上半年 17.9%', ARRAY['所得税', '利润总额']),
  ('2026 年上半年毛利率：比亚迪 18.8%、特斯拉 18.7%、小鹏 20.6%、零跑 11.7%、理想 9.5%', ARRAY['同业毛利率：理想汽车', '同业毛利率：小鹏汽车', '同业毛利率：零跑汽车', '同业毛利率：蔚来']);

DO $relink$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY['thesis', 'judgment', 'moat', 'biz_model', 'value_chain'] LOOP
    EXECUTE format($q$
      INSERT INTO vi_lnk_%1$s_basis_metrics (%1$s_id, metric_id, "createdAt", "updatedAt")
      SELECT DISTINCT l.%1$s_id, m.id, now(), now()
      FROM xm_fact_metric x
      JOIN vi_fact_base f ON f.company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND f.title = x.title
      JOIN vi_lnk_%1$s_facts l ON l.fact_id = f.id
      JOIN vi_metric_base m ON m.company_id = f.company_id AND m.name = ANY (x.metrics)
      ON CONFLICT DO NOTHING$q$, t);
  END LOOP;
END
$relink$;

-- 2a. 精简：只留定性部分（数字在依据指标里）
CREATE TEMP TABLE xm_fact_text (title text, new_title text, statement text) ON COMMIT DROP;
INSERT INTO xm_fact_text VALUES
  ('2025 年手机收入 1,864.4 亿元、毛利率 10.9%、出货 1.652 亿台；四季度毛利率 8.3%', '2025 年下半年手机毛利率下滑：国补退坡与零部件涨价',
   '2025 年手机收入与出货小幅下降，毛利率低于 2024 年，四季度降到全年最低；下半年受中国大陆国补退坡与核心零部件（存储）涨价影响。收入、出货、ASP、毛利率见依据指标。'),
  ('2026 年二季度手机出货 3,120 万台（−26.5%）、ASP 1,351 元（+25.9%）、毛利率 8.5%', '2026 年二季度：出货大降，ASP 创新高',
   '2026 年二季度手机出货同比降约四分之一，ASP 创历史新高（中国大陆 3,000 元以上机型占比约三成），毛利率因核心零部件涨价继续下降。出货、ASP、毛利率见依据指标。'),
  ('互联网服务：2025 年 374.4 亿元（+9.7%）、毛利率 76.5%；2026 年二季度 90.4 亿元（−0.6%）', '互联网服务增速放缓：游戏及增值服务下降',
   '互联网服务毛利率稳定在七成五以上，2026 年二季度收入同比转为小幅下降，主要是游戏及其他增值服务下降，广告仍在增长。收入与毛利率见依据指标。'),
  ('2025 年 IoT 收入 1,232.0 亿元（+18.3%）、毛利率 23.1%；大家电 +23.1%', '2025 年大家电高增，上半年受益国补',
   '2025 年 IoT 与生活消费产品收入、毛利率双升，智能大家电增长最快（空调出货超 850 万台、冰箱超 280 万台、洗衣机超 230 万台），上半年受益于国补。收入与毛利率见依据指标。'),
  ('2026 年二季度 IoT 与生活消费产品收入 312.8 亿元（−19.2%），国补退坡', '2026 年二季度 IoT 收入下降：国补退坡，境外高增',
   '2026 年二季度 IoT 与生活消费产品收入同比降约两成、毛利率下降，主因中国大陆国家补贴退坡；境外 IoT 收入高速增长。收入与毛利率见依据指标。'),
  ('全球月活 2026 年 6 月 7.665 亿（+4.8%），中国大陆 1.977 亿（+7.0%）', '用户结构：中国大陆、电视、米家与小爱',
   '2026 年 6 月中国大陆月活 197.7 百万（+7.0%），快于全球；智能电视月活 76.9 百万，米家 APP 月活 124.1 百万、小爱同学 174.9 百万。全球月活增速从 2018 年的约 28% 逐年降到个位数。全球月活见依据指标。'),
  ('2025 年交付 411,082 辆、汽车收入 1,033 亿元、ASP 25.12 万元；2026 年目标 55 万辆', '2026 年交付目标 55 万辆，门店快速扩张',
   '2025 年汽车交付约三倍增长、四季度分部经营收益为正；2026 年目标“全力冲刺交付 55 万辆”。截至 2025 年底在 138 个城市开业 477 家汽车门店。交付量、ASP 见依据指标。'),
  ('2026 年二季度汽车及 AI 分部：收入 249.0 亿元、交付 104,199 辆、ASP 22.93 万元、毛利率 19.2%、经营亏损 26 亿元', '2026 年汽车分部转亏：ASP 下降与 AI 投入',
   '2026 年一、二季度汽车及 AI 分部经营亏损：一季度停售初代 SU7、交付几乎不增；二季度交付回升，但 ASP 因 SU7 Ultra 占比下降而走低，分部毛利率比上年同期低约 7 个百分点，经营开支里含 AI 大模型投入。二季度“其他相关业务”约 10 亿元（含 MiMo 大模型 AI 收入）。分部收入、毛利率、经营损益、交付、ASP 见依据指标。'),
  ('2025 年研发 331.3 亿元（+37.8%）；2026—2030 年累计研发预计超 2,000 亿元', '研发：2026—2030 年累计预计超 2,000 亿元',
   '研发开支过去五年累计约 1,055 亿元，2025 年增速约四成；公司预计 2026 年起五年累计研发超 2,000 亿元，研发人员约 2.5 万人。研发开支见依据指标。'),
  ('2025 年回购 63 亿港元（1.526 亿股）；2026 年 1 月首次公告自动回购计划', '2025 年配售与回购，2026 年首次自动回购计划',
   '2025 年 3 月按每股 53.25 港元配售 8 亿股、募资约 425 亿港元，同年回购约 1.5 亿股；2026 年 1 月首次公告不超过 25 亿港元的自动回购计划。回购金额见依据指标。'),
  ('2026-06-30 现金储备 2,193 亿元，借款 393 亿元（含可换股债券 50.8 亿元）', '现金储备口径与可换股债券',
   '公司口径的“现金储备”含现金、受限制现金、定期存款、短期投资、按摊余成本计量的长期投资及理财投资；借款里有 2027 年到期的可换股债券（初始换股价 36.74 港元）。现金储备、借款见依据指标。'),
  ('实际所得税率：2024 年 16.2%、2025 年 16.3%、2026 年上半年 17.9%', '实际税率：研发加计扣除压低税负',
   '实际所得税率 2024—2025 年约 16%，2026 年上半年略升；研发费用加计扣除使研发支出的实际抵税率高于法定税率。所得税、利润总额见依据指标。'),
  ('2026 年上半年毛利率：比亚迪 18.8%、特斯拉 18.7%、小鹏 20.6%、零跑 11.7%、理想 9.5%', '2026 年上半年整车厂毛利率（国盛汇总）',
   '国盛证券汇总的 2026 年上半年毛利率：比亚迪 18.8%、特斯拉 18.7%、吉利 17.9%、赛力斯 23.3%、蔚来 18.7%、小米集团（集团口径）20.9%。理想、小鹏、零跑、蔚来的同口径毛利率由跟踪脚本按公告更新（同业指标）。');

UPDATE vi_fact_base f SET title = x.new_title, statement = x.statement
FROM xm_fact_text x
WHERE f.company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND f.title = x.title;

-- 2b. 年度口径备注：通用口径并入来源文档；资本运作事件合成一条定性事实
INSERT INTO vi_source_base (company_id, title, source_type, publisher, reliability, verify_status, summary, limitations)
SELECT c.id, '小米集团历史年度数据口径（2018—2025）', '数据库取数', '东方财富港股报表、业绩公告', '三级·第三方数据', '数值已核对',
  '历史年度（财务模型历史一侧）的数据来源与口径。',
  '财务数据：东方财富港股格式（国际财务报告准则）。“分红总额”为当年回购金额（小米不派现金股息）；“投资收益”＝投资公允价值变动＋其他收益净额；货币资金＝现金及等价物＋定期存款＋受限制现金（不含短期投资与理财，公司口径的“现金储备”更大）；带息负债＝短期借款＋长期借款（含可换股债券，不含租赁）。'
  || '一次性项目：2018 年利润含可转换可赎回优先股公允价值变动约 125 亿元、上市相关一次性股权激励约 100 亿元；2022 年行业萧条（收入 −14.7%、出货 −20.9%）；智能电动汽车等创新业务费用 2022 年 31、2023 年 67 亿元；2024 年汽车及 AI 分部经营亏损约 71.5 亿元；2025 年归母含投资公允价值收益 133.1 亿元，为模型基准年。'
FROM vi_company_base c
WHERE c.code = '01810.HK' AND NOT EXISTS (SELECT 1 FROM vi_source_base s WHERE s.company_id = c.id AND s.title = '小米集团历史年度数据口径（2018—2025）');

INSERT INTO vi_fact_base (company_id, title, category, statement, period, as_of, verify_status, source_id)
SELECT c.id, '上市与资本运作历程（2018—2025）', '治理',
  '2018 年 7 月在港交所上市（同股不同权）；2020 年 12 月按每股 23.70 港元配售 10 亿股，并发行 6 亿美元 2030 年票据与 8.55 亿美元 2027 年可换股债券；2021 年 3 月宣布造车，7 月发行 8 亿美元 2031 年票据与 4 亿美元 2051 年绿色债券；2024 年 4 月汽车开始交付；2025 年 3 月按每股 53.25 港元配售 8 亿股。小米不派现金股息，股东回报靠回购。',
  '2018—2025', '2025-12-31', '待核验', s.id
FROM vi_company_base c LEFT JOIN vi_source_base s ON s.company_id = c.id AND s.title = '小米集团历史年度数据口径（2018—2025）'
WHERE c.code = '01810.HK' AND NOT EXISTS (SELECT 1 FROM vi_fact_base f WHERE f.company_id = c.id AND f.title IN ('上市与资本运作历程（2018—2025）', '上市与资本运作历程'));

-- 2c. 删除：数字已在指标里（引用已在第 1 步改接）
DELETE FROM vi_fact_base
WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK')
  AND (title IN ('2025 年收入 4,572.9 亿元，经调整净利润 391.7 亿元',
                 '2026 年二季度收入 1,089.2 亿元（−6.1%），经调整净利润 62.2 亿元（−42.6%）',
                 '2025 年分部：手机×AIoT 3,512.2 亿元（毛利率 21.7%），汽车及 AI 1,060.7 亿元（经营收益 9 亿元）',
                 '全球月活（12 月）2018—2025 年：2.42 亿 → 7.54 亿',
                 '手机出货 2020—2025 年：1.464、1.903、1.505、1.456、1.685、1.652 亿台',
                 '2026 年一季度汽车及 AI 分部经营亏损 31 亿元，交付 80,856 辆',
                 '生态经营利润按季：2025 年 104.6、92.1、60.4、21.4 亿元，2026 年 60.6、48.5 亿元',
                 '生态（手机×AIoT）经营利润率：2024 年 8.6%、2025 年 7.9%、2026 年上半年 6.7%',
                 '生态经营利润率 2019—2025 年：3.7%、3.7%、5.9%、2.9%、7.6%、8.6%、7.9%',
                 '生态营业费用率 2019—2025 年：10.2%、11.2%、11.8%、14.1%、13.6%、12.6%、13.7%；2026 年上半年 14.5%',
                 'AIoT 连接设备 11.608 亿台（+17.4%），五件以上设备用户 2,460 万（+20.2%）',
                 '2026-10-22 收盘 25.80 港元（约 21.96 元），近一年最高收盘 47.14 港元')
       OR title ~ '^\d{4} 年度数据口径与说明$');

-- 3. 事项
INSERT INTO vi_event_base (company_id, name, category, status, period, summary)
SELECT c.id, v.name, v.category, v.status, v.period, v.summary
FROM vi_company_base c, (VALUES
  ('存储涨价与手机毛利率', '经营', '进行中', '2025—2027',
   '2025 年下半年起存储（DRAM、NAND）大幅涨价，低端机型存储占物料成本从约三成升到六成以上，小米是前五大厂商中受影响最大的。手机毛利率从 2024 年约 12.6% 降到 2026 年二季度 8.5%，专家估计 2026 年手机硬件亏损 80—100 亿元、靠 IoT 与互联网托底。管理层称内存涨价三季度中途放缓、四季度缓涨。'),
  ('手机出货与市场份额', '竞争', '进行中', '2026',
   '2026 年全球手机出货下滑，小米降幅明显大于行业：二季度全球出货 −26%、中国大陆 −21%（份额 12%，第五），三季度初步数据全球份额 12%（−2pt）。苹果、华为份额上升。'),
  ('汽车交付与 2026 年目标', '经营', '进行中', '2024—2026',
   '2024 年 4 月开始交付，2025 年交付约 41 万辆、分部全年首次盈利；2026 年目标 55 万辆。一季度停售初代 SU7 导致交付几乎不增，9 月交付超 4 万台、新车澎程首月锁单超 7 万台；专家预计全年 46—48.5 万辆，目标难以完成。新一代 SU7 锁单用户中苹果手机用户近六成。'),
  ('汽车盈利与 AI 投入分摊', '经营', '进行中', '2024—2026',
   '汽车及 AI 分部的经营开支同时承担造车和 AI 大模型、具身智能的先期投入，2026 年一、二季度分部经营亏损。专家对汽车本身单车利润的估计相差 4—5 倍（约 0.5—2.5 万元），汽车与 AI 的成本拆分是估算（待办 Q03）。'),
  ('汽车同业', '竞争', '持续', '2025—2026',
   '2026 年整车行业价格战加剧：理想二季度车辆毛利率降到 9.4% 并经营亏损，零跑把全年净利指引从 50 亿元下调到约 30 亿元。小米汽车毛利率 2025 年明显领先同业，2026 年上半年回落到与小鹏相当（同口径见跟踪脚本的同业指标）。'),
  ('AI 投入与大模型', '经营', '进行中', '2026—2030',
   '管理层：未来三年 AI 投入超 600 亿元，2026 年约 160 亿元（七成以上计入研发费用）；2026—2030 年累计研发预计超 2,000 亿元。自研 MiMo 大模型在 OpenRouter 周调用量排第一，并发布全屋智能与具身智能模型，但 AI 收入仍很小。估值中 AI 等新业务按主观判断直接计 1,000 亿元。'),
  ('AI 公司估值参照', '估值方法', '持续', '2026',
   '国内大模型公司按收入的几十到上百倍估值：智谱、MiniMax 2026 年 1 月在港股上市后大起大落，月之暗面、阶跃星辰、DeepSeek 一级市场估值快速上升；这些公司刚完成大额融资，市值里有相当部分是现金，研发费用约为收入的 4—5 倍。这些是小米 AI 业务直接估值的外部参照。'),
  ('生态利润与费用分摊', '财务', '持续', '2019—2026',
   '公司不按手机、IoT、互联网拆分费用，生态（手机×AIoT）经营利润按“分部毛利−(集团费用−汽车及 AI 分部经营开支)”推算；2019—2023 年无分部数据时扣除当年创新业务费用。手机×AIoT 分部营业费用率 2025 年四季度约 17.4%、2026 年二季度 14.2%；按收入分摊后，2026 年上半年手机经营亏损、IoT 与互联网盈利。'),
  ('IoT 与国补退坡', '经营', '进行中', '2025—2026',
   'IoT 与生活消费产品 2025 年受益国补高速增长，大家电增长最快；2026 年国补退坡后二季度收入降约两成，境外 IoT 高速增长。'),
  ('互联网服务与用户', '经营', '持续', '2018—2026',
   '互联网服务毛利率稳定在七成五以上，广告收入持续增长、境外占约三分之一；2026 年二季度游戏及增值服务下降使收入转为小幅下滑。全球月活增速从约 28% 降到个位数，中国大陆月活增速快于全球。'),
  ('新零售渠道', '经营', '持续', '2025—2026',
   '中国大陆小米之家约 1.6—1.8 万家（2025 年净增超 3,000 家），500 平米以上大店超 270 家，境外新零售门店超 640 家；汽车门店与小米之家协同。'),
  ('现金、投资与非经营资产', '财务', '持续', '2025—2026',
   '公司口径现金储备约 2,200 亿元，资产负债表现金类明细比它多约 80 亿元（差额原因未说明，待办 Q05）；对外投资账面约 720 亿元（以优先股为主，上市股权占少数），投资公允价值收益 2025 年 133 亿元、2026 年上半年 73 亿元（经调整净利润剔除）；另有投资者负债、租赁负债与无形资产应付款等计息负债。'),
  ('股本、回购与股权激励', '分红', '持续', '2018—2026',
   '小米不派现金股息，股东回报靠回购：2026 年截至 10 月 12 日已回购约 4.1 亿股、125 亿港元，5 月采纳上限 200 亿港元的新计划；但股权激励持续发股，抵消部分回购，摊薄股本约 264 亿股。'),
  ('印度资金冻结', '政策', '持续', '2021—2026',
   '自 2021 年 12 月起印度税务、外汇等部门调查小米印度，部分银行账户被扣押，截至 2026 年 6 月底约 35 亿元人民币受限，案件在听证阶段，公司未计提重大拨备；未见 2026 年判决或和解的报道（待办 Q09）。'),
  ('卖方观点与估值参照', '估值方法', '持续', '2026',
   '卖方普遍用分部估值：高盛核心业务 EV/NOPAT 16 倍、汽车 1.6 倍市销率，申万宏源主业 25 倍、汽车及 AI 0.7 倍市销率；2026—2028 年归母净利预测约 280—290、370、435—447 亿元。这些是外部参照，估值以本框架的模型为准。')
) v(name, category, status, period, summary)
WHERE c.code = '01810.HK'
ON CONFLICT (company_id, name) DO UPDATE SET category = EXCLUDED.category, status = EXCLUDED.status,
  period = EXCLUDED.period, summary = EXCLUDED.summary;

-- 4. 侧面
CREATE TEMP TABLE xm_facet (old_title text, title text, event text) ON COMMIT DROP;
INSERT INTO xm_facet VALUES
  ('存储成本：4 百美元以下机型存储占物料成本 60% 以上（2025 年三季度约 30%）', '存储占物料成本的比重', '存储涨价与手机毛利率'),
  ('管理层：内存涨价超预期，三季度中途放缓、四季度缓涨', '管理层：涨价节奏', '存储涨价与手机毛利率'),
  ('2025 年下半年手机毛利率下滑：国补退坡与零部件涨价', '2025 年下半年毛利率下滑', '存储涨价与手机毛利率'),
  ('2026 年二季度：出货大降，ASP 创新高', '2026 年二季度出货与 ASP', '存储涨价与手机毛利率'),
  ('专家：2026 年手机硬件预计亏损 80—100 亿元，IoT 与互联网托底', '专家：手机硬件亏损', '存储涨价与手机毛利率'),
  ('2026 年二季度全球：三星 6,050 万、苹果 5,510 万、小米 3,120 万部（−26%）', '2026 年二季度全球出货', '手机出货与市场份额'),
  ('2026 年二季度中国大陆：华为 23%、苹果 19%、小米 12%（820 万台，−21%）', '2026 年二季度中国大陆份额', '手机出货与市场份额'),
  ('Omdia 初步：2026 年三季度小米全球份额 12%（−2pt），中国大陆 800 万台（−20%）', '2026 年三季度初步数据', '手机出货与市场份额'),
  ('2026 年交付目标 55 万辆，门店快速扩张', '2026 年交付目标与门店', '汽车交付与 2026 年目标'),
  ('9 月小米汽车交付超 4 万台，澎程 30 天锁单超 7 万台；前三季度约 28.7 万台', '9 月交付与澎程锁单', '汽车交付与 2026 年目标'),
  ('专家预计 2026 年交付 46—48.5 万辆，55 万目标难以完成', '专家：全年交付预计', '汽车交付与 2026 年目标'),
  ('新一代 SU7 锁单用户中苹果手机用户近 60%（初代约 50%）', '锁单用户结构', '汽车交付与 2026 年目标'),
  ('2026 年汽车分部转亏：ASP 下降与 AI 投入', '2026 年分部转亏', '汽车盈利与 AI 投入分摊'),
  ('汽车及 AI 分部经营开支：2024 年 132 亿元、2025 年 248 亿元，2026 年一、二季度 71、74 亿元', '分部经营开支', '汽车盈利与 AI 投入分摊'),
  ('专家对汽车单车利润的估计分歧大：约 0.5 万元到 2.5 万元', '单车利润估计分歧', '汽车盈利与 AI 投入分摊'),
  ('2026 年上半年整车厂毛利率（国盛汇总）', '整车厂毛利率（2026 年上半年）', '汽车同业'),
  ('零跑：上半年交付 35.65 万辆，二季度毛利率 12.6%、净利 6 亿元，全年净利指引降到约 30 亿元', '零跑下调利润指引', '汽车同业'),
  ('理想：2026 年二季度车辆毛利率 9.4%、经营亏损 23 亿元', '理想转亏', '汽车同业'),
  ('管理层：未来三年 AI 投入超 600 亿元，2026 年 160 亿元', 'AI 投入计划', 'AI 投入与大模型'),
  ('MiMo-V2.5 在 OpenRouter 周调用量第一（10.5 万亿 token），AI 收入仍很小', 'MiMo 大模型进展', 'AI 投入与大模型'),
  ('研发：2026—2030 年累计预计超 2,000 亿元', '研发规划', 'AI 投入与大模型'),
  ('智谱（02513.HK）2026-10-22 市值约 2,247 亿港元（约 1,912 亿元），较 6 月高点回落约八成', '智谱市值', 'AI 公司估值参照'),
  ('MiniMax（00100.HK）2026-10-22 市值约 566 亿港元（约 482 亿元）', 'MiniMax 市值', 'AI 公司估值参照'),
  ('月之暗面（Kimi）2026 年 7 月 F 轮投后估值 350 亿美元', '月之暗面融资估值', 'AI 公司估值参照'),
  ('阶跃星辰 2026 年 5 月 Pre-IPO 轮后估值约 120 亿美元', '阶跃星辰融资估值', 'AI 公司估值参照'),
  ('DeepSeek 2026 年 8 月第二轮融资投前估值约 5,000 亿元', 'DeepSeek 融资估值', 'AI 公司估值参照'),
  ('大模型公司按收入的几十到上百倍估值，市值里有大量刚融到的现金', '大模型公司的市销率与现金', 'AI 公司估值参照'),
  ('“手机×AIoT”分部营业费用率：2025 年四季度 17.4%、2026 年一季度 14.9%、二季度 14.2%', '分部营业费用率（公司披露）', '生态利润与费用分摊'),
  ('2026 年上半年分业务：手机毛利率 9.3%、AIoT（含其他）21.2%、互联网 76.4%；按收入分摊费用后经营利润 −44.7、39.3、114.6 亿元', '2026 年上半年分业务利润（分摊）', '生态利润与费用分摊'),
  ('分业务毛利率 2019—2025 年：手机 7.2%→10.9%（2023 年 14.6%），IoT 11.2%→23.1%，互联网 64.7%→76.5%', '分业务毛利率（2019—2025 年）', '生态利润与费用分摊'),
  ('智能电动汽车等创新业务费用：2022 年 31 亿元、2023 年 67 亿元', '2022—2023 年创新业务费用', '生态利润与费用分摊'),
  ('2025 年大家电高增，上半年受益国补', '2025 年大家电高增', 'IoT 与国补退坡'),
  ('2026 年二季度 IoT 收入下降：国补退坡，境外高增', '2026 年二季度 IoT 下降', 'IoT 与国补退坡'),
  ('互联网服务增速放缓：游戏及增值服务下降', '互联网服务增速放缓', '互联网服务与用户'),
  ('2025 年广告收入 285 亿元（+15.2%），境外互联网收入 126 亿元（占 33.8%）', '广告与境外互联网收入', '互联网服务与用户'),
  ('用户结构：中国大陆、电视、米家与小爱', '用户结构', '互联网服务与用户'),
  ('小米之家：中国大陆约 1.6—1.8 万家，境外新零售门店超 640 家', '小米之家与境外门店', '新零售渠道'),
  ('现金储备口径与可换股债券', '现金储备口径与可换股债券', '现金、投资与非经营资产'),
  ('2026-06-30 现金类资产明细合计 2,274.7 亿元，比公司现金储备口径多 81.7 亿元', '现金类资产明细与口径差', '现金、投资与非经营资产'),
  ('2026-06-30 对外投资 720.7 亿元：权益法 66.1、普通股 185.8、优先股 382.4、其他 86.3', '对外投资构成', '现金、投资与非经营资产'),
  ('投资者负债（基金外部出资人份额）：2025 年末 139.1 亿元，2026 年 6 月末非流动部分 142.3 亿元', '投资者负债', '现金、投资与非经营资产'),
  ('2026-06-30 租赁负债 50.4 亿元、购买无形资产应付款 50.7 亿元', '租赁负债与无形资产应付款', '现金、投资与非经营资产'),
  ('投资公允价值收益：2025 年 133.1 亿元，2026 年上半年 73.1 亿元（经调整净利润剔除）', '投资公允价值收益', '现金、投资与非经营资产'),
  ('其他收入（主要是补贴）：2019—2025 年 6—27 亿元，2026 年上半年 32.5 亿元', '其他收入（补贴）', '现金、投资与非经营资产'),
  ('2025 年配售与回购，2026 年首次自动回购计划', '2025 年配售与回购', '股本、回购与股权激励'),
  ('2026 年回购：截至 10 月 12 日约 4.10 亿股、125 亿港元；新计划上限 200 亿港元', '2026 年回购进展', '股本、回购与股权激励'),
  ('2026-06-30 在外股份 257.09 亿股（已发行 257.85 亿股，扣除待注销回购 0.76 亿股）', '6 月末在外股份', '股本、回购与股权激励'),
  ('2026-09-30 在外股份 257.53 亿股：回购之外，股权激励新增 B 类股', '9 月末在外股份', '股本、回购与股权激励'),
  ('股权激励：2026 年上半年 23.2 亿元；摊薄调整约 7.0 亿股', '股权激励费用与摊薄', '股本、回购与股权激励'),
  ('上市与资本运作历程（2018—2025）', '上市与资本运作历程', '股本、回购与股权激励'),
  ('印度：491.7 亿卢比（约 35.4 亿元）资金被冻结，案件在听证阶段', '资金冻结与案件进展', '印度资金冻结'),
  ('高盛（2026-05）：核心 EV/NOPAT 16 倍、汽车 1.6 倍市销率，目标价 41 港元', '高盛估值框架', '卖方观点与估值参照'),
  ('申万宏源（2026-08）：主业 334 亿元×25 倍＋汽车及 AI 0.7 倍市销率，目标市值 9,000 亿元以上', '申万宏源估值框架', '卖方观点与估值参照'),
  ('卖方 2026—2028 年归母净利预测：约 278—291、367—373、434—447 亿元', '卖方盈利预测', '卖方观点与估值参照'),
  ('实际税率：研发加计扣除压低税负', '实际税率', NULL),
  ('2026 年上半年资本开支 68.9 亿元：手机×AIoT 30.2、汽车及 AI 38.3', '资本开支分部', NULL);

UPDATE vi_fact_base f SET title = x.title,
  event_id = (SELECT e.id FROM vi_event_base e WHERE e.company_id = f.company_id AND e.name = x.event)
FROM xm_facet x
WHERE f.company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND f.title IN (x.old_title, x.title);


COMMIT;
