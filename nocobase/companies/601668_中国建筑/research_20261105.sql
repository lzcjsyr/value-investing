-- 中国建筑研究增强（2026-11-05）：行业高频（国家统计局）与六家建筑央企同口径对比接入；三季报核对；待办推进。
-- 数据来自跟踪脚本（track.py → data/track.json，种子在此之前已写入）；本文件只改研究正文、补关联与待办，按业务键定位，可重复执行。

-- 1. 论点的决定性证据：写入已测算的读数
UPDATE vi_thesis_base SET decisive_evidence = '建筑新签占全国的比重（中建协年度统计）；订单结构（工业、能源、住宅、海外占比）；新接项目毛利率；应收增速与收入增速之差。'
  || '季度读数（2026-11，国家统计局）：1—9 月公司新签 +0.4%、全国建筑业总产值 −13.8%；公司房建新开工 −18.1%、全国房地产新开工 −24.9%——降幅都小于全国，份额仍在提升。10 月建筑业商务活动指数 48.0（收缩）。'
WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '601668.SH') AND code = 'T1';

UPDATE vi_thesis_base SET verdict = verdict || '（2026-11 更新：三季报前三季度收入 −14.3%、三季度单季约 −20%，比“下半年约 −8%”差；2026 年更可能在 −13% 到 −15%，基准是否下调见待办 Q02。）'
WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '601668.SH') AND code = 'T2' AND verdict NOT LIKE '%2026-11 更新%';

UPDATE vi_thesis_base SET decisive_evidence = '年度经营现金流÷归母净利；应收＋合同资产增速与收入增速之差；政府债权回收与逾期金额；PPP 回款；应付账款变化。'
  || '同业对比（跟踪脚本，六家建筑央企同口径，年末应收账款＋合同资产 ÷ 全年营业收入）：中国建筑 2021 年 20.9% → 2025 年 48.2%，同业中位数 33.9% → 57.3%——垫资强度低于同业约 9 个百分点，但上升速度与同业相当。'
  || '还没取得：应收与合同资产的账龄结构、坏账准备计提比例、政府类客户占比（应收＋合同资产 2026 年中 1.18 万亿元、PPP 相关非流动资产约 4,900 亿元，是 PB 0.37 倍的核心原因）。'
WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '601668.SH') AND code = 'T4';

UPDATE vi_thesis_base SET decisive_evidence = '年度 ROE；减值是否收敛（T8）；地产利润是否企稳；留存利润的增量回报。'
  || '同业对比（跟踪脚本，归母净利 ÷ 年初年末平均归母权益）：中国建筑 2021—2025 年 16.0%、14.0%、13.4%、10.4%、8.2%，六家建筑央企中位数 8.8%、9.3%、8.5%、7.5%、5.8%——始终高出 2.4—7 个百分点，但下降斜率与同业相同，已接近资本成本 7.6%。'
WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '601668.SH') AND code = 'T7';

-- 2. 依据指标与跟踪指标
WITH co AS (SELECT id FROM vi_company_base WHERE code = '601668.SH')
INSERT INTO vi_lnk_thesis_basis_metrics (thesis_id, metric_id, "createdAt", "updatedAt")
SELECT t.id, m.id, now(), now() FROM vi_thesis_base t JOIN vi_metric_base m ON
  (t.code = 'T1' AND ((m.company_id IS NULL AND m.code IN ('NBS.PMI.CONSTRUCTION', 'NBS.CONSTRUCTION.OUTPUT', 'NBS.RE.NEWSTART'))))
  OR (t.code = 'T2' AND ((m.company_id IS NULL AND m.code IN ('NBS.CONSTRUCTION.OUTPUT', 'NBS.RE.INVEST', 'NBS.RE.NEWSTART'))))
  OR (t.code = 'T4' AND m.company_id = t.company_id AND m.name IN ('（应收账款＋合同资产）÷营业收入', '同业（应收账款＋合同资产）÷营业收入中位数'))
  OR (t.code = 'T7' AND m.company_id = t.company_id AND m.name IN ('归母ROE（同业口径）', '同业ROE中位数（六家建筑央企）'))
  OR (t.code = 'T3' AND m.company_id = t.company_id AND m.name = '同业毛利率中位数（六家建筑央企）')
WHERE t.company_id = (SELECT id FROM co) ON CONFLICT DO NOTHING;

WITH co AS (SELECT id FROM vi_company_base WHERE code = '601668.SH')
INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id, "createdAt", "updatedAt")
SELECT j.id, m.id, now(), now() FROM vi_judgment_base j JOIN vi_metric_base m ON
  (j.code = 'J-P' AND m.company_id IS NULL AND m.code IN ('NBS.CONSTRUCTION.OUTPUT', 'NBS.RE.NEWSTART'))
  OR (j.code = 'J-Q' AND m.company_id IS NULL AND m.code = 'NBS.PMI.CONSTRUCTION')
WHERE j.company_id = (SELECT id FROM co) ON CONFLICT DO NOTHING;

-- 3. 待办
UPDATE vi_issue_base SET status = '处理中', progress = '三季报核对（2026-11-05）：前三季度营收 13,357 亿元（−14.3%）、归母 287.1 亿元（−24.8%）、减值 101.6 亿元（+27.4%）；三季度单季营收 3,599 亿元（−20.0%）、归母 57.1 亿元。'
  || '没有达到“收入降幅收窄到 −10% 左右、减值少于去年同期”。按四季度收入同比 −10% 到 −15% 推算，2026 年收入约 17,800—18,100 亿元（−13% 到 −15%），比基准 18,796 亿元低 4%—5%；四季度减值按全年约 235 亿元（前三季度已 101.6）需比去年四季度（178.9）少 46 亿元，归母全年约 300—320 亿元，低于基准 357 亿元。'
  || '建议（需你确认）：J-P 2026 年收入转化率 0.414 → 约 0.395（收入约 17,950 亿元），2027 年 0.405 是否同步下调待年报；J-IMP 2026 年减值维持约 235 亿元。'
WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '601668.SH') AND code = 'Q02';
UPDATE vi_issue_base SET status = '已解决', progress = '2026-11-05：跟踪脚本（companies/601668_中国建筑/track.py，国家统计局）接入建筑业商务活动指数（月）、全国房地产开发投资与新开工面积（月，累计）、全国建筑业总产值（季，累计），历史从 2021 年起；另接入六家建筑央企同口径的毛利率、ROE、垫资强度。专项债发行暂无稳定公开接口。'
WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '601668.SH') AND code = 'Q08';
UPDATE vi_issue_base SET progress = progress || '　2026-11-05：网上公开报道只找到 2016 年一季度（建筑新签 3,483 亿元，+26.9%）等分期数，仍未取得 2014—2016 年全年数。'
WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '601668.SH') AND code = 'Q05' AND progress NOT LIKE '%2026-11-05%';

-- 4. 三季报后修正 2026 年假设（你确认，2026-11-05）
UPDATE vi_judgment_base SET judgment = '2026 年 0.395（全年收入约 17,930 亿元，−14%：前三季度 −14.3%、三季度单季约 −20%，2026-11-05 由 0.414 下调）；2027 年起 0.405（收入约 18,390 亿元，比 2026 年回升约 2.6%），之后不变。即收入在 2026 年见底。'
WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '601668.SH') AND code = 'J-P';
UPDATE vi_judgment_base SET judgment = '2026 年 34.54%（每股 0.2718 元不变：三季报后归母下调到约 325 亿元，派息率随之由 31.44% 升到 34.54%，2026-11-05），2027 年起回到 32%、每年 +1pt，2035 年 40%（2027 年派息率低于 2026 年，但每股股息仍上升到约 0.277 元）。理由：经营现金流在改善、扩张资本下降，2029 年起 FCFE 高于计划股息；终值按永续增长 1% 计，可持续派息率远高于 40%，40% 偏保守。'
WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '601668.SH') AND code = 'J-PAYOUT';
UPDATE vi_thesis_base SET verdict = replace(verdict, '基准是否下调见待办 Q02。）', '基准已于 2026-11-05 下调为约 17,930 亿元（−14%），见待办 Q02。）')
WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '601668.SH') AND code = 'T2';
UPDATE vi_issue_base SET status = '处理中', progress = '2026-11-05 已按三季报修正（你确认）：J-P 2026 年收入转化率 0.414 → 0.395（收入约 17,933 亿元，−13.9%），付现成本按核心利润率 6.6% 同步重算；J-PAYOUT 2026 年派息率 31.44% → 34.54%（每股股息 0.2718 元持平）。基准 2026 年归母 357.2 → 325.2 亿元；股息贴现每股价值不变（5.42 元，股息路径未变），现金支持价值降到 5.34 元。'
  || '依据：前三季度营收 13,357 亿元（−14.3%）、三季度单季 −20.0%，归母 287.1 亿元（−24.8%），减值 101.6 亿元（+27.4%）。年报出来后核验全年，2027 年 0.405 一并复核后标“已核验”。'
WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '601668.SH') AND code = 'Q02';
INSERT INTO vi_change_log_base (change_date, title, target, old_value, new_value, reason, basis, verification, company_id, created_at, updated_at)
SELECT '2026-11-05', '三季报后下调 2026 年收入并保持每股股息', '逐年假设 2026 年：收入转化率（J-P）、派息率（J-PAYOUT）',
  '收入转化率 0.414（收入约 18,796 亿元）；派息率 31.44%', '收入转化率 0.395（收入约 17,933 亿元）；派息率 34.54%（每股 0.2718 元持平）',
  '三季报前三季度收入 −14.3%、三季度单季约 −20%，没有收窄到“下半年约 −8%”（待办 Q02）', '2026 年三季度报告（营业收入、归母净利、减值）',
  '基准 2026 年归母 357.2 → 325.2 亿元；股息贴现每股价值不变 5.42 元；现金支持价值 5.34 元', c.id, now(), now()
FROM vi_company_base c WHERE c.code = '601668.SH' AND NOT EXISTS (SELECT 1 FROM vi_change_log_base x WHERE x.company_id = c.id AND x.title = '三季报后下调 2026 年收入并保持每股股息');

-- 安全边际只保留 10% 一档（你确认，2026-11-05）
INSERT INTO vi_change_log_base (change_date, title, target, old_value, new_value, reason, basis, verification, company_id, created_at, updated_at)
SELECT '2026-11-05', '安全边际只保留 10% 一档', '估值模型：安全边际（低档 10%、高档取消）', '10% / 30% 两档并列', '10% 一档（关注价＝今天价值×90%）',
  '你确定交易纪律：安全边际用 10%', '用户决定', '关注价只显示一个；估值不变', c.id, now(), now()
FROM vi_company_base c WHERE c.code = '601668.SH' AND NOT EXISTS (SELECT 1 FROM vi_change_log_base x WHERE x.company_id = c.id AND x.title = '安全边际只保留 10% 一档');
