-- 中国建筑观点调整（2026-10-26）：集中度提升与资金优势、研发与大项目能力、存量 PPP 风险；整合姜诚（中泰资管）关于建筑行业的公开观点。
-- 只改研究层（论点、壁垒、风险、适配度、跟踪事项、来源、事实、关联、变更日志），不改模型参数。按编号/标题定位，可重复执行。
-- 执行：./psql.sh -f "companies/601668_中国建筑/view_update_20261026.sql"
-- 注意：seed.py 早于本次调整（也早于风险表），重跑 seed.py 后要再执行本文件。
-- 2026-10-26 起跟踪事项并入指标：本文件不再写跟踪事项；R5 的预警指标与正文以 data/data_layer.json 为准。
BEGIN;
CREATE TEMP TABLE co ON COMMIT DROP AS SELECT id FROM vi_company_base WHERE code = '601668.SH';

-- ---------------------------------------------------------------- 来源：姜诚的公开访谈（第三方转述）
DELETE FROM vi_source_base WHERE company_id = (SELECT id FROM co) AND title LIKE '姜诚%';
INSERT INTO vi_source_base (title, source_type, publisher, publish_date, url, reliability, verify_status, retrieved_on, summary, limitations, company_id) VALUES
($s$姜诚访谈：价值投资最重要的是厘清概念（2023-12）$s$, '研究方法', '中国基金报', '2023-12-05',
 'https://www.chnfund.com/article/AR2023120521044215969182', '三级·第三方数据', '已读原文', '2026-10-26',
 $s$建筑行业资产轻、周转快、需求多元、市场空间足够大；好的建筑公司成本优势大、银行授信充裕、利率低；产品差异大，最难的项目通常最赚钱，好公司能挑项目和客户，所以利润率更高、坏账率更低；研发投入含在项目合同里，在老项目习得的能力能在新项目复制；龙头地位更稳，头部与非头部的差距在拉大。$s$,
 $s$媒体转述，非逐字稿；未点名中国建筑，未谈 PPP 与应收。$s$, (SELECT id FROM co)),
($s$姜诚访谈：点拾投资×基煜基金联合访谈（2022-05）$s$, '研究方法', '点拾投资（搜狐转载）', '2022-05-19',
 'https://www.sohu.com/a/548679879_143019', '三级·第三方数据', '已读原文', '2026-10-26',
 $s$竞争优势只有成本领先与产品差异化两类，成本优势更容易看清和量化；建筑行业规模经济明显：订单越多越能投入研发，强化获得高利润率项目的能力；把股票当债券看，用长期现金流对应的内部收益率衡量，前景和价格都要打折扣、看悲观情形；对建筑与地产做“退市检验”；曾在约 4 倍市盈率买入建筑龙头。$s$,
 $s$访谈整理稿；2022 年的观点，早于本轮地产与化债周期的后半段。$s$, (SELECT id FROM co)),
($s$姜诚交流纪要与 2025 年年报（2025-06、2026-04）$s$, '研究方法', '新浪财经', '2026-04-03',
 'https://finance.sina.com.cn/money/fund/jjyj/2025-06-23/doc-infcaafh9419848.shtml', '三级·第三方数据', '已读原文', '2026-10-26',
 $s$建筑行业现金流自 2024 年四季度到 2025 年一季度明显好转，担忧下降；中国建筑是前三大重仓，跌时加、涨时减；判断标准是价格对应的内部收益率而非行业好坏，目标两位数；周期底部比多数人预期的长，现金回收拖得越久价值越低。2025 年年报另见 https://finance.sina.com.cn/wm/2026-04-03/doc-inhtfkwx3748202.shtml 。$s$,
 $s$交流纪要为第三方整理；年报观点经媒体转述；未谈 PPP。$s$, (SELECT id FROM co));

-- ---------------------------------------------------------------- 事实：研发投入
DELETE FROM vi_fact_base WHERE company_id = (SELECT id FROM co) AND title LIKE '研发投入：%';
INSERT INTO vi_fact_base (title, category, statement, value, unit, period, as_of, verify_status, notes, company_id, source_id) VALUES
($f$研发投入：2025 年 440 亿元（收入的 2.1%）$f$, '经营',
 $f$利润表研发费用：2017 年 27.9 亿元、2019 年 172.9、2021 年 400.2、2022 年 497.5（峰值）、2023 年 460.7、2024 年 454.6、2025 年 440.1 亿元（占营业收入 2.1%）；2026 年上半年 162.7 亿元（1.7%）。$f$,
 440.1, '亿元', '2025', '2025-12-31', '已核验',
 $f$口径提示：建筑企业的研发费用包含大量项目上的技术攻关支出，2018 年起高新技术企业认定与加计扣除推动归集，增长有一部分来自口径变化。东方财富 F10 利润表（data/eastmoney_income.json）。$f$,
 (SELECT id FROM co),
 (SELECT id FROM vi_source_base WHERE company_id = (SELECT id FROM co) AND title LIKE '%东方财富%' ORDER BY id LIMIT 1));

-- ---------------------------------------------------------------- 论点
UPDATE vi_thesis_base SET
  title = '规模与信用让它在行业寒冬里拿份额，集中度提升',
  bull_case = $t$1）份额在升：全国建筑业新签 2025 年 −5.51%，公司建筑新签反而 +1.7%，占全国的比重从约 12.2% 升到约 13.2%；管理层称 2026 年上半年市场占有率又提高 2.2 个百分点；八大建筑央企合计占全国新签从 2013 年约 24% 升到 2024 年约 47%。2）寒冬是集中度提升的窗口：业主缺钱、工期拉长，施工企业要先垫资后收款，民企与弱地方国企的资金链先断；公司三大评级 A 级、带息负债平均成本约 2%（2026 年上半年综合融资成本再降 14bp），银行授信充裕，敢在别人收缩时接单（M1）。3）总量仍大：全国建筑业总产值 2025 年约 30.4 万亿元，只比上年降 5.4%；工业厂房、能源、数据中心订单在增长，住宅压到房建订单的两成以内（B1）；难项目、大项目有资格做的企业少（T9）。$t$,
  verdict = $t$成立（把握由中提高到高）：寒冬里活下来、接得到单的条件是资金，而资金正是它最强的地方；份额提升已经在数据里（全国新签 −5.5%、公司 +1.7%）。集中度提升是这家公司最确定的长期判断，也是收入不会跟着行业大幅下滑的主要理由（T2）。仍要看两点：份额是不是用更差的付款条件换来的（应收增速，T4），份额能不能变成利润（T7）。$t$,
  confidence = '高',
  bull_rebuttal = $t$新接项目毛利率 +0.2pt、住宅占比压到两成以内、PPP 不再新增：公司在拿份额的同时收紧了项目质量；民企退出后，集中度上升本身会改善竞争格局，好公司还能挑项目和客户。$t$,
  external_view = $t$姜诚（中泰资管，中国建筑多年为其前三大重仓）：好的建筑公司成本优势大、银行授信充裕、利率低，龙头地位更稳，头部与非头部的差距在拉大（来源：姜诚访谈 2023-12）。岗底斯同业对比：中国建筑新签占全国建筑业比例逆势提升至 13.16%，工业厂房增速领先同梯队（同业新签见 M2）；卖方普遍把“央企龙头份额提升”作为看多理由。$t$,
  debated_on = '2026-10-26'
WHERE company_id = (SELECT id FROM co) AND code = 'T1';

UPDATE vi_thesis_base SET
  title = '收入在 2027 年见底：集中度提升抵消大部分行业下滑',
  status = '观察',
  bull_case = $t$1）份额对冲总量：行业总产值每年降约 5% 时，公司份额只要每年提高约 1 个百分点（13.2% → 14.2% 即多 7.6%），收入就能大体持平；2025 年份额 +1pt、2026 年上半年 +2.2pt，已经在发生（T1）。2）订单不缺：新签三年稳定，2026 年 1—9 月 −0.1%；转化率下降主要是开工少、业主资金紧、工期拉长，化债回款后结算会恢复一部分。3）总量仍大：基建与工业投资的绝对规模仍很大，工业厂房、能源、数据中心订单增长快、开工快；地产结转未来两三年大体平稳（管理层）。$t$,
  verdict = $t$观察（原为存疑）：短期反方的证据更硬——2026 年上半年收入 −12%、房建新开工 −18%，2026 年收入约 −10% 已成定局；但中期看，集中度提升（T1）能抵消大部分行业下滑，收入不会跟着行业一路下滑。模型基准（2026 年 −9.7%、2027 年再降约 2% 后见底）与这个判断一致，不调整参数；悲观情景（收入较基准 −6.9%）覆盖反方的路径。验证点在 2027 年。$t$,
  mind_changer = $t$改判为成立：2027 年收入降幅收窄到 −5% 以内，且建筑新签占全国的比重继续提高。改判为存疑：2027 年收入仍下滑 5% 以上，或份额下降。自动检查（触发即证伪）：营业收入同比连续两年低于 −5%（2026 年大概率低于 −5%，若 2027 年仍低于 −5% 即触发）。$t$,
  external_view = $t$姜诚：建筑“需求多元，市场空间足够大”，龙头与非龙头的差距在拉大；2025 年交流称行业现金流自 2024 年四季度明显好转、担忧下降。他也提醒：这轮周期底部比多数人预期的长，现金回收拖得越久价值越低（来源：姜诚访谈 2023-12、交流纪要 2025-06）。卖方大多认为 2027 年收入能恢复增长（见 J-P 反证）；对 2026—2028 年归母净利的一致预期约 370—392 亿元，中报后普遍下调（事实摘录）。$t$,
  debated_on = '2026-10-26'
WHERE company_id = (SELECT id FROM co) AND code = 'T2';

DELETE FROM vi_thesis_base WHERE company_id = (SELECT id FROM co) AND code = 'T9';
INSERT INTO vi_thesis_base (code, title, category, status, confidence, bull_case, bear_case, bull_rebuttal, bear_rebuttal, verdict,
                            decisive_evidence, mind_changer, model_impact, external_view, debated_on, company_id) VALUES
('T9', '研发与技术积累让它接得住最难、最大的项目', '壁垒', '成立', '中',
 $t$1）研发投入大：研发费用 2022 年约 498 亿元、2025 年约 440 亿元（收入的 2.1%），绝对额是多数建筑企业营收的数倍。2）能力体现在难项目：ENR 全球最大承包商，国内绝大多数 300 米以上超高层由公司承建；复杂工业厂房、数据中心、能源工程需要设计—采购—施工一体化与大项目管理经验，有业绩的企业少：2025 年工业厂房新签 +23%、能源工程 +17%，2026 年上半年数据中心与算力中心新签 873 亿元（+328%）。3）规模与研发相互强化：订单越多越能摊薄研发、积累工法与项目经验，难项目竞争者少、利润更高。4）施工毛利率在升：2025 年 8.8%（+0.7pt），2026 年上半年房建 8.2%（+0.9pt），新接项目毛利率 +0.2pt。$t$,
 $t$1）技术优势还没有体现在利润率上：综合毛利率 9.9%，与央企同业 9.3%—12.4% 持平，低于中国交建、中国电建（事实摘录）。2）研发费用口径宽：2017 年只有 28 亿元，2018 年起高新技术企业认定与加计扣除推动归集，增长相当部分是口径变化；研发强度 2.1% 在央企里不突出。3）研发随收入下降：2022 年峰值后连降三年，2026 年上半年只占收入 1.7%。4）中铁、铁建、中冶、电建也在抢工业、能源与数据中心（M2 反证）。$t$,
 $t$难项目的价值首先是拿得到：行业下行期公司新签总量持平，同期中铁、铁建、交建上半年新签 −9% 至 −17%（M2）；毛利率持平而份额上升，本身就是竞争力。$t$,
 $t$拿得到但赚不到更多，只能算份额优势，不能算定价权；要看新领域项目的毛利率与回款是否好于住宅和地方基建。$t$,
 $t$成立：技术与大项目能力是真实的竞争力，体现在接得住大单、难单和行业下行期的新签份额上；但还没有体现在高于同业的毛利率上，所以它强化的是份额（T1），不是利润率（T3）。$t$,
 $t$工业厂房、能源、数据中心的新签与毛利率；施工毛利率与央企同业对比；新接项目毛利率；研发费用与研发强度。$t$,
 $t$改判为观察：施工毛利率连续两年低于央企同业中位数，或工业厂房、数据中心等新领域新签增速转负。不设自动检查（同业毛利率不在历史财务里），年报后手工对比。$t$,
 '不单独改参数（通过 T1、T3 影响 J-Q、J-M）',
 $t$姜诚：产品差异大，最难的项目通常最赚钱；研发投入含在项目合同里，在老项目习得的能力能在新项目复制；订单越多越能投入研发，强化获得高利润率项目的能力（来源：姜诚访谈 2023-12、2022-05）。$t$,
 '2026-10-26', (SELECT id FROM co));

-- ---------------------------------------------------------------- 壁垒
UPDATE vi_moat_base SET strength = '强', trend = '增强',
  mechanism = $m$三大评级 A 级（全球建筑行业最高）、带息负债平均成本约 2%（2026 年上半年再降 14bp）、银行授信充裕：行业寒冬里施工企业要先垫资后收款，资金成本和资金可得性决定谁能接单、谁能活下来；民企与弱地方国企的资金链先断，订单向央企集中。$m$,
  financial_link = $m$体现在份额：2025 年建筑新签占全国约 13.2%（+1pt），2026 年上半年再 +2.2pt（T1）；没有体现在利润率：毛利率 9.9%，与央企同业（9.3%—12.4%）持平。$m$
WHERE company_id = (SELECT id FROM co) AND code = 'M1';

UPDATE vi_moat_base SET title = '规模、研发与超大复杂项目的总承包能力', verdict = '真实壁垒', trend = '增强',
  mechanism = $m$ENR 全球最大承包商，国内绝大多数 300 米以上超高层由公司承建；研发费用每年 440—500 亿元，工法与项目经验在新项目里复制。复杂公建、大型工业厂房、数据中心需要设计—采购—施工一体化与大项目管理经验，有资格和业绩竞标的企业少（T9）。$m$,
  financial_link = $m$订单向工业厂房（2025 年 +23%）、能源工程（+17%）、数据中心（2026 年上半年 +328%）转移；施工毛利率 2025 年 8.8%（+0.7pt）。体现在份额，尚未体现在高于同业的毛利率（T9）。$m$
WHERE company_id = (SELECT id FROM co) AND code = 'M2';

UPDATE vi_moat_base SET threats = '地方财政的付费能力；存量回收周期拉长（风险 R5）。'
WHERE company_id = (SELECT id FROM co) AND code = 'M7';

-- ---------------------------------------------------------------- 风险：新增 R5，修正 R1—R4 的错位文字
DELETE FROM vi_risk_base WHERE company_id = (SELECT id FROM co) AND code = 'R5';
INSERT INTO vi_risk_base (code, title, category, mechanism, probability, impact, horizon, trend, impact_estimate, mitigants, treatment, early_warning, response, status, company_id) VALUES
('R5', '存量 PPP 回收周期拉长、结果不确定', '财务与资产质量',
 $r$1）敞口大：在施 PPP 416 个、权益投资 5,951 亿元，累计回款只有 1,515 亿元（约四分之一）；资产负债表上 PPP 相关的其他非流动资产 3,574 亿元、长期应收款 1,351 亿元，合计约 4,900 亿元，接近归母净资产（5,039 亿元）。2）回收靠地方财政：运营期回报主要是政府付费与可行性缺口补助，财政紧张时付款推迟、绩效考核扣款或重谈合同；2023 年 11 月后不再新增，但存量要 10—20 年才回收完。3）时间就是价值：回收每推迟一年，约 4,900 亿元资产损失约 7% 的时间价值（约 340 亿元，合约 0.8 元/股，合并口径、未扣少数股东）；推迟最后会变成减值——公司董办称 PPP/BT 项目的计提“有上升苗头”。$r$,
 '中', '高', '3—10 年', '上升',
 $r$本模型没有把存量 PPP 的回收当作现金来源（J-CB），拖延本身不压低模型价值；进入模型的是两条：减值（J-IMP 基准每年约 180 亿元，仍是正常账龄的两倍）与尾款投入（J-CAPEX 的扩张资本含存量 PPP 尾款）。若 PPP 相关资产 10% 最终收不回（约 490 亿元，分 5 年计提），相当于减值每年多约 100 亿元，对应已有单参数试验“减值多 100 亿元/年”。$r$,
 $r$1）85.6% 已进入运营期（365 个、5,097 亿元），2025 年 PPP 投资回款 3,848 亿元、收支比 113.6%，回款已大于投入。2）化债把政府逾期债权纳入台账，央企债权优先级高（T4）。3）不再新增，敞口只减不增。$r$,
 '已计入基准情景',
 $r$W12 存量 PPP 回款与减值：收支比低于 100%，或 PPP/BT 相关减值单年超过 30 亿元，或 PPP 相关长期资产不降反升
W9 地方化债与政府债权回收：化债资金明显退坡，或政府逾期债权回升$r$,
 '触发后复核 J-IMP、J-CAPEX 与论点 T4、T8；必要时把单参数试验“减值多 100 亿元/年”升为悲观情景假设。',
 '监控中', (SELECT id FROM co));

-- R1—R4 原先由论点整理生成时错位（R2 写成了毛利率、R3 写成了 ROE、R4 写成了回款）；按各自标题对应的论点重写
UPDATE vi_risk_base r SET
  mechanism = t.bear_case, mitigants = t.bull_case,
  impact_estimate = '整理自论点 ' || t.code || '：' || t.verdict || E'\n可能性与冲击为初始研究判断，非统计概率；本次未改变模型参数。',
  response = '触发后复核相关论点和假设依据，再决定是否调整模型。原论点改判条件：' || t.mind_changer
FROM vi_thesis_base t, (VALUES ('R1', 'T2'), ('R2', 'T4'), ('R3', 'T8'), ('R4', 'T6')) m(risk, thesis)
WHERE r.company_id = (SELECT id FROM co) AND t.company_id = r.company_id AND r.code = m.risk AND t.code = m.thesis;

-- ---------------------------------------------------------------- 适配度
UPDATE vi_fit_score_base SET score = 2,
  rationale = $a$建筑业总量已过峰，但基建与工业投资的绝对规模仍很大（全国建筑业总产值约 30 万亿元）；集中度提升让龙头收入跌幅远小于行业（T1、T2）；模型假设收入 2027 年见底、之后每年 +1%。$a$,
  counter = $a$新开工两位数下滑，2026 年收入约 −10%；住宅与地方基建长期收缩。$a$
WHERE company_id = (SELECT id FROM co) AND dimension = '长坡';
UPDATE vi_fit_score_base SET score = 3,
  rationale = $a$央企信用与低成本资金（M1，真实壁垒、强）在寒冬里转化为份额；研发与超大复杂项目能力（M2、T9）让它接得住大单、难单；中海的拿地纪律（M3）是局部优势。$a$
WHERE company_id = (SELECT id FROM co) AND dimension = '护城河';

-- ---------------------------------------------------------------- 关联
INSERT INTO vi_lnk_thesis_facts (thesis_id, fact_id, "createdAt", "updatedAt")
SELECT t.id, f.id, now(), now() FROM vi_thesis_base t JOIN vi_fact_base f ON f.company_id = t.company_id
WHERE t.company_id = (SELECT id FROM co) AND (
  (t.code = 'T9' AND (f.title LIKE '研发投入：%' OR f.title LIKE '全球最大承包商%' OR f.title LIKE '订单结构%' OR f.title LIKE '建筑央企 2025 年%'))
  OR (t.code = 'T1' AND (f.title LIKE '市场份额%' OR f.title LIKE '带息负债%')))
AND NOT EXISTS (SELECT 1 FROM vi_lnk_thesis_facts x WHERE x.thesis_id = t.id AND x.fact_id = f.id);

INSERT INTO vi_lnk_moat_theses (moat_id, thesis_id, "createdAt", "updatedAt")
SELECT m.id, t.id, now(), now() FROM vi_moat_base m JOIN vi_thesis_base t ON t.company_id = m.company_id
WHERE m.company_id = (SELECT id FROM co) AND ((m.code = 'M2' AND t.code = 'T9') OR (m.code = 'M1' AND t.code = 'T1'))
AND NOT EXISTS (SELECT 1 FROM vi_lnk_moat_theses x WHERE x.moat_id = m.id AND x.thesis_id = t.id);

INSERT INTO vi_lnk_moat_facts (moat_id, fact_id, "createdAt", "updatedAt")
SELECT m.id, f.id, now(), now() FROM vi_moat_base m JOIN vi_fact_base f ON f.company_id = m.company_id
WHERE m.company_id = (SELECT id FROM co) AND m.code = 'M2' AND f.title LIKE '研发投入：%'
AND NOT EXISTS (SELECT 1 FROM vi_lnk_moat_facts x WHERE x.moat_id = m.id AND x.fact_id = f.id);

INSERT INTO vi_lnk_fit_score_theses (fit_score_id, thesis_id, "createdAt", "updatedAt")
SELECT s.id, t.id, now(), now() FROM vi_fit_score_base s JOIN vi_thesis_base t ON t.company_id = s.company_id
WHERE s.company_id = (SELECT id FROM co) AND ((s.dimension = '护城河' AND t.code IN ('T1', 'T9')) OR (s.dimension = '长坡' AND t.code IN ('T1', 'T2')))
AND NOT EXISTS (SELECT 1 FROM vi_lnk_fit_score_theses x WHERE x.fit_score_id = s.id AND x.thesis_id = t.id);

INSERT INTO vi_lnk_risk_theses (risk_id, thesis_id, "createdAt", "updatedAt")
SELECT r.id, t.id, now(), now() FROM vi_risk_base r JOIN vi_thesis_base t ON t.company_id = r.company_id
WHERE r.company_id = (SELECT id FROM co) AND r.code = 'R5' AND t.code IN ('T4', 'T8');
INSERT INTO vi_lnk_risk_judgments (risk_id, judgment_id, "createdAt", "updatedAt")
SELECT r.id, j.id, now(), now() FROM vi_risk_base r JOIN vi_judgment_base j ON j.company_id = r.company_id
WHERE r.company_id = (SELECT id FROM co) AND r.code = 'R5' AND j.code IN ('J-IMP', 'J-CAPEX', 'J-WC');
INSERT INTO vi_lnk_risk_facts (risk_id, fact_id, "createdAt", "updatedAt")
SELECT r.id, f.id, now(), now() FROM vi_risk_base r JOIN vi_fact_base f ON f.company_id = r.company_id
WHERE r.company_id = (SELECT id FROM co) AND r.code = 'R5'
  AND (f.title LIKE 'PPP：%' OR f.title LIKE '应收账款＋合同资产%' OR f.title LIKE '减值构成%');

-- ---------------------------------------------------------------- 变更日志
DELETE FROM vi_change_log_base WHERE company_id = (SELECT id FROM co) AND change_date = '2026-10-26' AND title LIKE '观点调整：%';
INSERT INTO vi_change_log_base (change_date, title, target, old_value, new_value, reason, basis, verification, company_id) VALUES
('2026-10-26', '观点调整：集中度与资金优势、研发与大项目能力、存量 PPP 风险',
 '论点 T1、T2，新增 T9；壁垒 M1、M2、M7；风险 R1—R4（修正错位文字），新增 R5；跟踪事项新增 W12；适配度 长坡、护城河；来源 3 个、事实 1 张',
 'T1 成立/把握中；T2 存疑；无研发论点；M1 强度中、趋势稳定；M2 局部优势；PPP 只作为伪壁垒 M7 与 T4、T8 的反方论据，没有单列风险；R2—R4 的传导路径与缓冲因素错位；适配度 15/40（长坡 1、护城河 2）',
 'T1 成立/把握高（寒冬里资金决定谁能接单，集中度提升）；T2 观察（份额对冲大部分行业下滑，2027 年验证）；T9 研发与技术让它接得住难项目、大项目（成立，强化份额而非利润率）；M1 强度强、趋势增强；M2 改为真实壁垒（加入研发）；R5 存量 PPP 回收周期拉长（中×高，已计入基准情景：J-IMP、J-CAPEX）；R1—R4 改为与标题一致的论点文字；适配度 17/40（长坡 2、护城河 3）',
 '用户判断：建筑高峰已过但基建规模仍大，寒冬中头部央企的贷款与低利率优势让它敢接单，集中度提高、收入未必大降；研发积累带来真实的技术竞争力；PPP 拉长回收周期、增加不确定性，是真实风险。要求参考姜诚（中泰资管）关于建筑行业的发言与访谈做整体调整。',
 '姜诚访谈（中国基金报 2023-12、点拾投资 2022-05）、交流纪要与 2025 年年报（新浪财经）；公司事实卡：市场份额、带息负债、PPP、减值构成、应收与合同资产、订单结构；东方财富 F10 研发费用。',
 '只改研究层，模型参数不变；执行前后三情景今天每股价值与隐含年化收益率对比见验证记录。',
 (SELECT id FROM co));

COMMIT;
