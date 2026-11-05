-- 太阳纸业研究增强（2026-11-05）：成本优势从定性改为测算；浆价纸价改为每日跟踪；待办推进。
-- 数据来自跟踪脚本（track.py → data/track.json，种子在此之前已写入）；本文件只改研究正文、补关联与待办，按业务键定位，可重复执行。

-- 1. 壁垒 M1：用同口径同业毛利率与吨经济测算
UPDATE vi_moat_base SET
  financial_link = '毛利率 2022—2025 年 15.2%—16.0%，七家 A 股造纸同业中位数 11.5%、9.9%、9.6%、7.9%（领先 3.7、6.0、6.4、7.7 个百分点）；行业下行期仍盈利 28—33 亿元。',
  evidence = '测算（跟踪脚本，同口径新浪财报：毛利率＝1 − 营业成本÷营业收入）：太阳纸业毛利率领先七家 A 股造纸同业（山鹰、博汇、晨鸣、华泰、岳阳、仙鹤、五洲）中位数，2016—2021 年只有 0—6 个百分点（2021 年 −0.1：高浆价年份特种纸同业更赚钱），2022 年起拉开并稳定在 6—9 个百分点：2023 年 6.0、2024 年 6.4、2025 年 7.7，2026 年一至三季度单季 7.1、6.9、8.9。2026 年纸浆期货从 6,000 元/吨以上跌到 4,600 元附近，领先幅度没有收窄反而扩大：胶版纸期货（约 3,580 元/吨）已低于针叶浆期货，外购浆做文化纸亏现金，自制浆的价值更大。吨口径：吨营业成本 2022 年 4,553 元 → 2025 年 3,561 元，吨毛利 2017 年 1,366 元 → 2025 年 657 元——优势是相对同业的，绝对吨利随纸价下行。',
  counter = '浆价低迷时外购浆的同业成本下降更快，优势理应收窄；但 2026 年的测算相反（纸价跌得比浆价多，领先幅度扩大到 8.9 个百分点）。真正的反例是：纸价回升而浆价不动时，同业修复更快，领先幅度可能回到 2016—2021 年的 0—6 个百分点。它不是定价权（论证见 T1）。'
WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '002078.SZ') AND code = 'M1';

-- 2. 论点 T1：改判条件改用可度量的“毛利率领先同业中位数”
UPDATE vi_thesis_base SET
  decisive_evidence = '“毛利率领先同业中位数”（七家 A 股同业、同口径，单季与全年）：2022 年起 6—9 个百分点；吨营业成本与浆价、胶版纸价的对照；新浆线投产后的吨浆成本（管理层说年底或明年初才有对比）。',
  mind_changer = '改判：毛利率被同业追平——“毛利率领先同业中位数”连续两个季度低于 2 个百分点（2016—2021 年曾在 0—6 之间）。自动检查：年度毛利率连续两年低于 13%。'
WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '002078.SZ') AND code = 'T1';

-- 3. 风险 R1 预警：纸价改用胶版纸期货（每日），增加领先幅度
UPDATE vi_risk_base SET early_warning =
  '毛利率领先同业中位数：单季低于 4 个百分点（2023—2026 年在 6—9）' || chr(10) ||
  '纸浆价格：纸浆期货、现货较 2026-11 水平（约 4,600—4,800 元/吨）变动超过 ±15% 且持续一个月' || chr(10) ||
  '胶版纸期货（双胶纸）：较 2026-11 水平（约 3,600 元/吨）再跌 10%，或与针叶浆期货的价差（纸价 − 浆价）继续走阔' || chr(10) ||
  '季度毛利率与分产品吨利：综合毛利率连续两季低于 13%，或箱板纸毛利率低于 13%' || chr(10) ||
  '箱板纸价格与提价落地：旺季提价未落地、价格反跌（箱板纸尚无公开日度价格，来源：卓创/隆众/钢联（券商转引））' || chr(10) ||
  '持续跟踪：分产品吨利（季；来源：季报、半年报分产品毛利率）'
WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '002078.SZ') AND code = 'R1';

-- 4. 依据指标、预警指标、跟踪指标
WITH co AS (SELECT id FROM vi_company_base WHERE code = '002078.SZ'),
     m AS (SELECT id, name FROM vi_metric_base WHERE (company_id = (SELECT id FROM co) AND name IN ('毛利率领先同业中位数', '吨营业成本（营业成本 ÷ 浆纸销量）', '吨毛利（毛利 ÷ 浆纸销量）'))
                                              OR (company_id IS NULL AND code IN ('SP.SHFE.SINA', 'OP.SHFE.SINA', 'SP.SPOT.100PPI')))
INSERT INTO vi_lnk_moat_basis_metrics (moat_id, metric_id, "createdAt", "updatedAt")
SELECT x.id, m.id, now(), now() FROM vi_moat_base x, m WHERE x.company_id = (SELECT id FROM co) AND x.code = 'M1' ON CONFLICT DO NOTHING;

WITH co AS (SELECT id FROM vi_company_base WHERE code = '002078.SZ')
INSERT INTO vi_lnk_thesis_basis_metrics (thesis_id, metric_id, "createdAt", "updatedAt")
SELECT t.id, m.id, now(), now() FROM vi_thesis_base t JOIN vi_metric_base m ON m.company_id = t.company_id AND m.name IN ('毛利率领先同业中位数', '吨营业成本（营业成本 ÷ 浆纸销量）')
WHERE t.company_id = (SELECT id FROM co) AND t.code = 'T1' ON CONFLICT DO NOTHING;

WITH co AS (SELECT id FROM vi_company_base WHERE code = '002078.SZ')
INSERT INTO vi_lnk_risk_metrics (risk_id, metric_id, "createdAt", "updatedAt")
SELECT r.id, m.id, now(), now() FROM vi_risk_base r
JOIN vi_metric_base m ON (m.company_id = r.company_id AND m.name = '毛利率领先同业中位数') OR (m.company_id IS NULL AND m.code IN ('OP.SHFE.SINA', 'SP.SPOT.100PPI'))
WHERE r.company_id = (SELECT id FROM co) AND r.code = 'R1' ON CONFLICT DO NOTHING;

WITH co AS (SELECT id FROM vi_company_base WHERE code = '002078.SZ')
INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id, "createdAt", "updatedAt")
SELECT j.id, m.id, now(), now() FROM vi_judgment_base j
JOIN vi_metric_base m ON (j.code = 'J-M' AND m.company_id = j.company_id AND m.name IN ('毛利率领先同业中位数', '吨营业成本（营业成本 ÷ 浆纸销量）'))
                      OR (j.code = 'J-P' AND ((m.company_id = j.company_id AND m.name = '吨收入（营业收入 ÷ 浆纸销量）') OR (m.company_id IS NULL AND m.code = 'OP.SHFE.SINA')))
WHERE j.company_id = (SELECT id FROM co) ON CONFLICT DO NOTHING;

-- 5. 2018 年销量（待办 Q05）：纸制品 297 万吨＋浆 103 万吨（中国银河证券研报转引公司公告；2017 年同口径 279＋81＝360 与已有数据一致）
SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '002078.SZ'), '浆纸销量（纸＋外销浆）', '全年', '万吨', '2018', '2018-12-31', 400, 0.1111,
  '纸制品 297 万吨＋浆 103 万吨（中国银河证券研报转引公司 2018 年年报产销量表；三级来源，待与年报原文核对）', NULL);

-- 6. 浆价事实：外盘只记有出处的变化，国内现货与期货改由跟踪指标每日更新
UPDATE vi_fact_base SET title = '浆价：阔叶浆外盘 9 月起上调约 20 美元/吨，国内浆价每日跟踪',
  statement = 'Suzano 向亚洲客户宣布 2026 年 9 月起阔叶浆每吨上调 20 美元（生意社 10-12）；此前 9 月初外盘针叶浆、阔叶浆约 670、590 美元/吨（中信建投）。国内纸浆期货、现货（山东银星针叶浆）和胶版纸期货见「数据底稿 / 定量指标 / 宏观与市场」，每日更新。公司木浆原料占成本 50%—60%。',
  as_of = '2026-10-12'
WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '002078.SZ') AND title LIKE '浆价：%';

-- 7. 待办
UPDATE vi_issue_base SET status = '处理中', progress = '2026 年三季报核对（2026-11-05）：前三季度营收 319.6 亿元（+10.5%）、归母 29.2 亿元（+16.9%）；三季度单季营收 111.0、归母 9.7、毛利率 15.9%。基准 2026E 营收 428.1、归母 37.5 → 四季度需营收约 108.5（同比约 +6%）、归母约 8.3（同比约 +8%），与三季度节奏一致，2026 年假设暂维持。公司不披露季度销量，销量与吨收入待年报核验后标“已核验”。'
WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '002078.SZ') AND code = 'Q02';
UPDATE vi_issue_base SET progress = '2016—2017 年已由岗底斯知识库补齐；2018 年按中国银河证券研报转引的年报产销量表补为 400 万吨（纸 297＋浆 103，2026-11-05），待与年报原文核对；2014、2015 年仍缺（2016 年年报的上年对比数未取得）。'
WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '002078.SZ') AND code = 'Q05';
UPDATE vi_issue_base SET progress = '纸浆期货 2018 年以来的日收盘价已由跟踪脚本补齐（track.py，收盘价口径）；采集工作流当天按钮在 21:00 以后点仍会抓到夜盘最新价，下一次跟踪脚本运行不覆盖已有日期。如需严格收盘价，改为每天 18:30 定时采集。'
WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '002078.SZ') AND code = 'Q07';
UPDATE vi_issue_base SET status = '处理中', progress = '2026-11-05：文化纸（双胶纸）已有公开日度价格——上期所胶版印刷纸期货（新浪 OP0），已加入采集配置并补齐 2025-09 上市以来的历史；纸浆现货（生意社）由跟踪脚本每日更新。箱板纸仍无可自动采集的公开来源（卓创/隆众为付费数据）。'
WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '002078.SZ') AND code = 'Q08';
UPDATE vi_issue_base SET status = '处理中', progress = '交叉核对（2026-11-05）：模型 2026 年资本开支 70 亿元（维持 20＋扩张 50），前三季度实际 55.7 亿元（上年同期 69.2），四季度约 14 亿即可对上，总额合理。维持性资本开支用 20 亿元＝折旧（29 亿）的 0.69 倍：资产较新（2019 年后新增为主）时偏低但不离谱；2018—2025 年资本开支始终高于折旧 1.9 倍以上，无法从报表直接分出维持部分。若按折旧全额作维持性开支，2026 年股东自由现金流少约 9 亿元（每股约 0.32 元）。建议保留现值、在“现金支持口径”里体现；待年报在建工程与项目预算出来后确认。'
WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '002078.SZ') AND code = 'Q03';

-- 安全边际只保留 10% 一档（你确认，2026-11-05）
INSERT INTO vi_change_log_base (change_date, title, target, old_value, new_value, reason, basis, verification, company_id, created_at, updated_at)
SELECT '2026-11-05', '安全边际只保留 10% 一档', '估值模型：安全边际（低档 10%、高档取消）', '10% / 30% 两档并列', '10% 一档（关注价＝今天价值×90%）',
  '你确定交易纪律：安全边际用 10%', '用户决定', '关注价只显示一个；估值不变', c.id, now(), now()
FROM vi_company_base c WHERE c.code = '002078.SZ' AND NOT EXISTS (SELECT 1 FROM vi_change_log_base x WHERE x.company_id = c.id AND x.title = '安全边际只保留 10% 一档');
