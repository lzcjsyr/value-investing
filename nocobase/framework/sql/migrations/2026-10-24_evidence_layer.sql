-- 2026-10-24：来源与事实归到“数据底稿”，参数判断移到“估值”。
-- 表名：事实卡→事实摘录、市场观察→高频数据、参数判断→假设依据；正文里的旧名同步改写（变更日志是历史记录，不改）。
-- 删除与高频数据重复的行情快照事实摘录；论点的“对模型的影响”只写编号，细节移入对应的假设依据。
-- 内容与各公司种子一致；空库重建不需要执行本文件。

BEGIN;
COMMENT ON TABLE vi_source_base IS '来源文档：原始出处：年报、公告、数据库取数、官网。一份文档可以支撑多条事实摘录。';
COMMENT ON TABLE vi_fact_base IS '事实摘录：从来源文档里摘出的一条可核验事实（尽量带数值、期间和单位）。事实只记录“是什么”，解释放到论点或假设依据里。';
COMMENT ON COLUMN vi_thesis_base.model_impact IS '对模型的影响：对应哪条假设依据、改不改参数';
COMMENT ON TABLE vi_judgment_base IS '假设依据：事实 → 判断 → 参数：解释事实和论点如何影响哪个估值参数、改参数的门槛、什么情况下不改。论证本身写在论点与辩论里，这里只写到参数的传导。';
COMMENT ON TABLE vi_metric_base IS '指标：高频数据指标的定义：股价、利率、水文等。同一含义不同口径的数据分成不同指标，不拼接。';
COMMENT ON TABLE vi_observation_base IS '高频数据：每个指标每天的观察值。同一天多次采集时取最后一次为“当前版本”；超出合理范围的为无效。';
COMMENT ON COLUMN vi_model_base.rf IS '无风险利率：长期参数；高频数据不会自动覆盖（小数，0.05＝5%）';
COMMENT ON TABLE vi_lnk_judgment_facts IS '假设依据 ↔ 依据事实（多对多）';
COMMENT ON TABLE vi_lnk_judgment_theses IS '假设依据 ↔ 相关论点（多对多）';
COMMENT ON TABLE vi_lnk_forecast_judgments IS '逐年假设 ↔ 假设依据（多对多）';
COMMENT ON TABLE vi_lnk_trial_judgments IS '单参数试验 ↔ 假设依据（多对多）';
COMMENT ON TABLE vi_lnk_watch_judgments IS '跟踪事项 ↔ 假设依据（多对多）';
COMMENT ON VIEW vi_fact IS '事实摘录（界面视图：输入列＋自动计算列）';
COMMENT ON VIEW vi_judgment IS '假设依据（界面视图：输入列＋自动计算列）';
COMMENT ON VIEW vi_observation IS '高频数据（界面视图：输入列＋自动计算列）';

UPDATE vi_thesis_base SET model_impact = 'J-TV、J-P' WHERE id = 377;
UPDATE vi_thesis_base SET model_impact = 'J-Q' WHERE id = 378;
UPDATE vi_thesis_base SET model_impact = 'J-P' WHERE id = 379;
UPDATE vi_thesis_base SET model_impact = 'J-DA、J-DEBT；所得税率见问题清单 Q11' WHERE id = 380;
UPDATE vi_thesis_base SET model_impact = '派息率见逐年假设；J-CB2026' WHERE id = 381;
UPDATE vi_thesis_base SET model_impact = 'J-CAPEX、J-CB2026' WHERE id = 382;
UPDATE vi_moat_base SET evidence = '三峡右岸机组 2025—2026 年、地下机组 2029—2030 年折旧到期，之后溪洛渡、向家坝接续（事实摘录）。' WHERE id = 216;
UPDATE vi_moat_base SET evidence = '新发中票、超短融的票面利率约 1.3%—2.1%，低于存量债务成本（事实摘录）。' WHERE id = 218;
UPDATE vi_biz_model_base SET content = '与两大电网签大宗中长期合同、按月结算，客户只有两家，但电网保障消纳，不存在“丢客户”。电价按机制定：葛洲坝成本加成；三峡按受电省份落地电价倒推（落地价−输电价−线损）；金沙江四站为倒推电价加市场化电价，白鹤滩过渡期后全部市场化（事实摘录“电价机制”）。关系稳定来自管制，不来自公司自身（伪壁垒 M5）。' WHERE id = 298;
UPDATE vi_biz_model_base SET content = '控股股东三峡集团建设电站再注入公司（B6），2026 年增持 44.99 亿元。参股受电区域和长江上游的能源企业（如国投电力、川投能源），投资收益在枯水年平滑利润（事实摘录“投资收益”）。' WHERE id = 302;
UPDATE vi_value_chain_base SET profit_share = '市场化电量约占 40%（年度长协价格见事实摘录）' WHERE id = 267;
UPDATE vi_judgment_base SET judgment = '短期偏枯可能下调年度电量，不必永久化；悲观情景的业务量系数对应连续偏枯。', change_threshold = '公司季度电量或经回测的水文—发电关系；同口径累计比较；2026 年发电量在四季度复核。' WHERE id = 1;
UPDATE vi_judgment_base SET judgment = '政策和交易结构改变平均实现价格；基准不假设电价上涨。', change_threshold = '确认含税/不含税、地区、结算量和生效日期；若沿海年度长协继续下降，先在悲观情景下调单价系数，不机械改基准。' WHERE id = 2;
UPDATE vi_judgment_base SET judgment = '只认可增量回报超过资本成本的增长；扩张资本开支计入现金桥接，新项目收益没有计入收入假设（现金支持价值偏保守）。' WHERE id = 5;
UPDATE vi_judgment_base SET judgment = '永续增长必须有留存与回报支撑；基准永续增长 1%：按稳定现金流建模。' WHERE id = 8;
UPDATE vi_judgment_base SET judgment = '要求回报率由无风险参考、风险补偿与机会成本共同决定：折现率＝10 年国债＋3.5% 风险溢价。当前国债收益率处历史低位，利率上行是这类“类债资产”最大的估值风险；无风险利率取高频数据里的中债 10 年期国债到期收益率（建模时 1.69%，2026-08-31），加风险溢价后按 0.1 个百分点四舍五入（5.19% → 5.2%）。' WHERE id = 7;
UPDATE vi_issue_base SET progress = '模型 2026—2035 年统一用 16.27%（2025 年实际）；卖方按 2026 年 16.5%、2027 年 17.0%、2028 年 16.8% 估算（事实摘录“所得税”）。粗算：税率每高 0.7 个百分点，归母净利约少 0.8%。' WHERE id = 343;
UPDATE vi_watch_base SET action = '原件入库，逐项事实摘录；重大事件重新承保' WHERE id = 1;
UPDATE vi_thesis_base SET bull_case = '1）管理层预计未来 2—3 年资本开支较 2025 年下降（事实摘录）；南宁技改是最后一个已宣布的大项目，2027 年四季度投完。2）在建项目投产后，经营现金流随销量增长，资本开支回落到“折旧＋少量扩张”就能释放股东现金（模型路径见 J-CAPEX）。3）管理层表示扩张结束后，盈利用于降负债、回购或分红（T4）。', bear_case = '1）过去七年经营现金流几乎全部投进了新产能，股东自由现金近似为零（B9）：扩张是公司的传统。2）2025 年资本开支 79 亿元，管理层对 2026—2027 年的口径前后不一（事实摘录）。3）老挝林地达到约 10 万公顷后要上新浆线（最早 2027 年下半年规划）：高峰可能只是推迟。', model_impact = 'J-CAPEX', external_view = '长江证券（2026-08）：2027—2028 年资本开支下降后有望提升分红；首席观点（2026-07）认为后续项目聚焦老挝基地（事实摘录）。' WHERE id = 406;
UPDATE vi_thesis_base SET model_impact = 'J-PAYOUT、J-OTHER' WHERE id = 407;
UPDATE vi_thesis_base SET model_impact = 'J-CAPEX、J-REL' WHERE id = 408;
UPDATE vi_thesis_base SET model_impact = 'J-DEBT' WHERE id = 409;
UPDATE vi_thesis_base SET model_impact = 'J-CB2026' WHERE id = 410;
UPDATE vi_thesis_base SET bull_case = '1）销量：颜店三个项目 2026 年投产，南宁 50 万吨本色浆＋60 万吨特种纸 2027 年四季度试产（事实摘录），销量增长基本确定。2）结构：箱板纸收入占比升到约三分之一（B5），毛利率 18.48%（+2.84pct）；约 100 万吨文化纸已转产包装纸；新机 PM47 盈利与山东高端箱板相当（M5）。3）2026 年二季度箱板纸淡季逆势提价约 400 元/吨，龙头协同挺价。', model_impact = 'J-Q、J-P' WHERE id = 405;
UPDATE vi_thesis_base SET model_impact = 'J-M' WHERE id = 404;
UPDATE vi_moat_base SET evidence = '北海、南宁的 9% 优惠与老挝、沙湾的免税都有到期日（事实摘录“税收优惠到期时间表”）。' WHERE id = 253;
UPDATE vi_biz_model_base SET content = '纸箱厂、印刷厂按订单和市场价采购，同规格的纸可以互相替代，客户换供应商的成本低；价格随行业涨价函与淡旺季调整（2026 年 4—7 月箱板纸淡季提价约 400 元/吨，事实摘录“市场份额”）。维系客户靠质量稳定、交期与部分合同的销售返利；关联方采购是相对稳定的需求（B1）。' WHERE id = 307;
UPDATE vi_biz_model_base SET content = '实控人李洪信，控股股东持股约 45%；集团内的白卡纸业务是第一大客户（关联方，B1）。木浆自给之外的部分外购，另有木片、废纸、煤与化工品采购，价格随国际浆价和能源价格波动（浆价见事实摘录“浆价”，国内期货价格见高频数据）。', metric = '控股股东持股约 45%' WHERE id = 311;
UPDATE vi_judgment_base SET judgment = '付现成本＝营业收入×(1−EBITDA 率)：2026 年 18.3%、2027 年 18.8%、2028 年起 19.0%（七年均值 17.6%，加自制浆约 +1 个百分点）。对应吨付现成本 2026 年约 3284 元；悲观情景按 2022—2023 年的利润率。' WHERE id = 700;
UPDATE vi_judgment_base SET judgment = '2026 年 70（维持 20＋扩张 50；上半年已 39.9）、2027 年 60（22＋38）、2028 年 50（24＋26，老挝新项目开工）、2029 年 48（26＋22）、2030 年 43（28＋15）；2031 年起扩张 10 亿/年、维持资本从 30 亿升至 2035 年 37.1 亿（≈折旧）。老挝新项目按约 50 亿元、2030—2031 年新增约 60 万吨销量计入；资本开支若不下降，模型价值就高估（可用单参数试验看影响）。' WHERE id = 703;
UPDATE vi_judgment_base SET judgment = '风险溢价 6.0%，基准折现率 7.6%；悲观 8.6%、乐观 7.1%。要求收益率（你自己的门槛）仍为 6%，两者分开看；无风险利率取高频数据里的中债 10 年期国债到期收益率（建模时 1.64%，2026-10-21），加风险溢价后按 0.1 个百分点四舍五入（7.64% → 7.6%）。' WHERE id = 706;
UPDATE vi_fact_base SET title = '浆价：外盘针叶浆约 670、阔叶浆约 590 美元/吨（2026 年 9 月初）', statement = '2026 年 9 月初针叶浆、阔叶浆外盘约 670、590 美元/吨（中信建投）；国内纸浆期货价格见高频数据里的纸浆期货收盘价。公司木浆原料占成本 50%—60%。', unit = '美元/吨', period = '2026 年 9 月初', value = 670 WHERE id = 1700;
UPDATE vi_issue_base SET impact = '事实摘录' WHERE id = 373;
UPDATE vi_issue_base SET impact = '高频数据' WHERE id = 374;
UPDATE vi_thesis_base SET model_impact = 'J-DEBT、J-DA' WHERE id = 431;
UPDATE vi_thesis_base SET model_impact = 'J-PAYOUT、J-TAX' WHERE id = 432;
UPDATE vi_thesis_base SET bull_case = '1）减值是 ROE 下降的主因：若减值回落到正常账龄水平（80—100 亿元/年），ROE 可回到 9%—10%。2）核心利润率稳定（T3），PPP 不再新增、资本开支下降，资本密度会下降。3）2025 年 ROE 7.9% 是建筑央企里最高的（岗底斯口径，同业见事实摘录）。', model_impact = '不单独改参数；见 J-REL、J-PAYOUT、J-IMP' WHERE id = 433;
UPDATE vi_thesis_base SET model_impact = 'J-IMP、J-R' WHERE id = 434;
UPDATE vi_thesis_base SET model_impact = 'J-Q' WHERE id = 427;
UPDATE vi_thesis_base SET bull_case = '1）订单不缺：新签三年稳定，2026 年前三季度基本持平（B5）。2）转化率下降有周期原因：开工少、业主资金紧、工期拉长；化债推进后，结算会恢复一部分。3）地产结转比建筑稳定：管理层预计未来两三年地产营收大体平稳（事实摘录）。', model_impact = 'J-P、J-TV', external_view = '卖方大多认为 2027 年收入能恢复增长（见 J-P 反证）；对 2026—2028 年归母净利的一致预期约 370—392 亿元，中报后普遍下调（事实摘录）。' WHERE id = 428;
UPDATE vi_thesis_base SET bull_case = '1）施工毛利率在升：2025 年提高 0.7pt 到 8.8%，2026 年上半年综合毛利率 10.3%，来自选项目与成本管控（M4）。2）核心利润率（不含减值）跨周期稳定在 6%—7%（事实摘录）：利润下滑来自收入与减值，不是施工毛利（B9）。3）订单结构向工业、能源转移，住宅占比下降（B1）。', model_impact = 'J-M' WHERE id = 429;
UPDATE vi_thesis_base SET model_impact = 'J-WC、J-CAPEX、J-CB' WHERE id = 430;
UPDATE vi_moat_base SET financial_link = '毛利率三年稳定在约 9.9%，2026 年上半年升到 10.3%；新接项目毛利率 +0.2pt（事实摘录）。' WHERE id = 272;
UPDATE vi_moat_base SET financial_link = 'PPP 权益投资 5,951 亿元，累计回款 1,515 亿元；资产负债表上 PPP 相关的长期资产约 4,900 亿元（事实摘录）。' WHERE id = 275;
UPDATE vi_biz_model_base SET content = '收入＝新签合同总额×收入转化率（2025 年 45,458 亿元×0.458），施工按进度确认收入。2025 年收入：房建 12,342 亿元（59%）、基建 5,432 亿元（26%）、地产 2,844 亿元（14%）、勘察设计约 1%；境外 1,417 亿元（约 7%）。地产收入只占约 15%，却贡献约 34% 的分部利润总额（2026 年上半年，事实摘录）。周期：全国建筑业新签合同额连续三年下降、总产值 2025 年近十年首次下降；公司新签 2023—2025 年稳定在 4.3—4.5 万亿元（份额上升，T1），但订单变成收入的速度在变慢（收入转化率 0.54 → 0.46，原因与前景见 T2）。增量：工业厂房、能源工程、数据中心、城市更新（含中国建筑国际旗下中建海龙的模块化建筑 MiC）、海外（订单高增、毛利率低）。地产随销售周期，合约销售连续三年下降（事实摘录）。' WHERE id = 317;
UPDATE vi_biz_model_base SET content = '2025 年成本与费用（19,630 亿元）里分包约 37%、原材料约 24%、劳务约 12%，其余是地产结转、其他施工成本与职工薪酬（事实摘录）。施工毛利 8%—11%，扣掉费用后核心利润率约 6.2%（不含减值）。每 100 元收入：营业成本 90.1 元、税金 0.4 元、销售管理研发费用 4.2 元、财务费用 0.85 元、减值 1.24 元（约收入的 1.2%），利润总额 3.4 元；所得税 0.8 元、少数股东 0.7 元，归母净利 1.9 元（2019 年 3.0 元）；即归母净利≈利润总额×56%（税 24%、少数股东 26%）。资本：先垫资后收款——业主按节点付款、质保金后付，回款慢于确认；每 1 元收入对应的应收账款＋合同资产从 2019 年 0.21 元、2023 年 0.26 元升到 2025 年 0.48 元。经营现金流长期只有利润的一到五成（事实摘录）；PPP 存量权益投资 5,951 亿元。购建长期资产约 260 亿元/年，真正的资本需求是营运资本。' WHERE id = 321;
UPDATE vi_judgment_base SET no_change_condition = '季度间计提节奏不均（四季度通常最多）；风险用情景和单参数试验展示，不机械改长期假设。' WHERE id = 742;
UPDATE vi_judgment_base SET no_change_condition = '上半年经营现金流为负（季节性：年底集中收款）；化债退坡的影响用情景展示，不机械改长期假设。' WHERE id = 745;
UPDATE vi_judgment_base SET judgment = '风险溢价 6.0%，基准折现率 7.6%；悲观 8.6%、乐观 7.1%。要求收益率（你自己的门槛）仍为 6%；无风险利率取高频数据里的中债 10 年期国债到期收益率（建模时 1.64%，2026-10-21），加风险溢价后按 0.1 个百分点四舍五入（7.64% → 7.6%）。' WHERE id = 749;
UPDATE vi_fit_score_base SET rationale = '利润池薄：毛利率约 10%、归母净利率约 1.9%；建筑央企 ROE 只有 4.7%—7.9%（同业见事实摘录）。' WHERE id = 250;
UPDATE vi_competitor_base SET vs_us = '收入约为中国建筑的一半，毛利率、ROE、PB 都低于中国建筑；没有大地产平台，利润更“纯工程”：减值÷收入与少数股东占比都明显更低（同业见事实摘录）。' WHERE id = 291;
UPDATE vi_issue_base SET progress = '应收＋合同资产 1.18 万亿元（2026H1），PPP 相关非流动资产约 4,900 亿元；这是 PB 0.37 倍的核心原因。同业的减值÷收入已整理到事实摘录（建筑央企 2025 年）；账龄结构与计提比例还没有取得。' WHERE id = 395;
UPDATE vi_issue_base SET impact = '事实摘录' WHERE id = 397;
UPDATE vi_issue_base SET progress = '少数股东损益约占净利 27%，子公司永续债约 608 亿元；持股比例与各子公司分走的损益已整理到事实摘录（2025 年报），归母可得现金还没有测算。' WHERE id = 398;
UPDATE vi_thesis_base SET model_impact = 'J-PAYOUT（第一跟踪项）' WHERE id = 335;
UPDATE vi_thesis_base SET model_impact = 'J-CB、J-DA' WHERE id = 336;
UPDATE vi_thesis_base SET model_impact = 'J-M（不改参数）' WHERE id = 331;
UPDATE vi_thesis_base SET model_impact = 'J-M（不改参数）' WHERE id = 332;
UPDATE vi_thesis_base SET model_impact = 'J-Q、J-TV' WHERE id = 333;
UPDATE vi_thesis_base SET model_impact = 'J-M、J-P、J-CAPEX（不改参数）' WHERE id = 334;
UPDATE vi_thesis_base SET model_impact = 'J-DEBT、J-OTH、J-SOTP-C' WHERE id = 337;
UPDATE vi_biz_model_base SET trend = 'AI 音乐日上传量约 40%、播放只占 1%—3%，内容供给方式在变，平台目前不给 AI 歌曲结算版税（事实摘录）。' WHERE id = 328;
UPDATE vi_judgment_base SET judgment = '维持资本 2026 年 12.0 亿元，之后每年约 +3%—4%；扩张资本 2026 年 85 亿元（喜马拉雅现金约 80＋其他约 5），2027 年起每年 5 亿元（IP 与艺人投资）；喜马拉雅的现金对价计入扩张资本。' WHERE id = 579;
UPDATE vi_judgment_base SET judgment = '本模型的“派息率”＝（股息＋回购）÷归母净利。2026 年 62%（下半年回购约 25 亿元＋2026 年度股息约 30 亿元；上半年回购已在股本里体现，不重复计入）；2027—2031 年 120%（利润全部分配，另释放每年约 20 亿元超额现金）；2032 年起 90%。按公允价格回购与分红对股东价值等价，所以把回购当作股息处理；待用户确认：是否把基准回报率从 120% 下调到 90%—100%，直到出现正式政策（价值约 41—43 元）。' WHERE id = 581;
UPDATE vi_judgment_base SET judgment = '风险溢价 7.0%，基准折现率 8.6%；悲观 10.0%、乐观 7.6%。要求收益率（你自己的门槛）仍为 6%；无风险利率取高频数据里的中债 10 年期国债到期收益率（建模时 1.64%，2026-10-22），加风险溢价后按 0.1 个百分点四舍五入（8.64% → 8.6%）；估值用人民币现金流与人民币利率，股价按汇率折成人民币后比较。' WHERE id = 584;
UPDATE vi_judgment_base SET judgment = '非现金收益扣除 0.5、收到投资分红 0.5、营运资本增加 0（不假设负营运资本继续释放现金）、最低现金补充 0（现金充足）；不假设负营运资本继续释放现金。' WHERE id = 592;
UPDATE vi_judgment_base SET judgment = '2026 年末 1.27 亿（与 2025 年持平：音乐会员内生约持平），2027 年 1.28 亿，之后每年 +1%。不把喜马拉雅会员计入增长，口径若改变在年报后调整；悲观情景业务量系数 0.96 对应 T3 反方胜；免费模式与 AI 的长期冲击用悲观情景（永续增长 0%，J-TV）和单参数试验体现，不机械改长期假设。' WHERE id = 573;
UPDATE vi_judgment_base SET judgment = '付现成本＝收入×(1−核心 EBITDA 利润率)：2026—2027 年 33.2%，2028 年起 33.0%（毛利率约 43.5%、费用率约 15%）。股权激励（约 7 亿元/年）留在成本里，不加回；悲观情景 28% 对应“护城河失效”（T1）；不因多元化上调（T4）。', change_threshold = '毛利率低于 42% 或连续两个半年度核心利润率偏离假设 1pt 以上；销售费用率持续高于 4% 时，下调核心利润率 1 个百分点（价值约 −1.2 元，见单参数试验“经营效率”反向）。' WHERE id = 575;
UPDATE vi_issue_base SET progress = '估算 31.4—31.7 亿股，模型用 31.5（口径见 J-SHARES 与事实摘录“流通股约 31.5 亿股（估算）”）。' WHERE id = 298;
UPDATE vi_issue_base SET impact = '事实摘录' WHERE id = 304;
UPDATE vi_thesis_base SET model_impact = 'J-NET、J-MULT' WHERE id = 356;
UPDATE vi_thesis_base SET model_impact = 'J-PHONE、J-MEM' WHERE id = 357;
UPDATE vi_thesis_base SET model_impact = 'J-EV' WHERE id = 358;
UPDATE vi_thesis_base SET model_impact = 'J-AI' WHERE id = 359;
UPDATE vi_thesis_base SET model_impact = 'J-CASH、J-INV' WHERE id = 360;
UPDATE vi_thesis_base SET model_impact = 'J-SHR、J-PAYOUT' WHERE id = 363;
UPDATE vi_judgment_base SET judgment = '不受存储周期影响，2027 年即为正常化年份：收入 385 亿元、毛利率 76.5%、费用率 14.0%，经营利润率 62.5%。轻资产，增长来自月活与单用户变现，倍数按永续增长 3%、新增投资回报率 50%：基准 15.4 倍（悲观 1.5%、30% → 10.6 倍；乐观 4%、60% → 22.8 倍）；不另加“生态溢价”。' WHERE id = 640;
UPDATE vi_issue_base SET impact = '事实摘录' WHERE id = 336;
DELETE FROM vi_fact_base WHERE id = 9;   -- 600900.SH 无风险利率参考 1.69%（2026-08-31）
DELETE FROM vi_fact_base WHERE id = 1702;   -- 002078.SZ 无风险利率参考 1.64%（2026-10-21）
DELETE FROM vi_fact_base WHERE id = 1798;   -- 601668.SH 无风险利率参考 1.64%（2026-10-21）
DELETE FROM vi_fact_base WHERE id = 1342;   -- 01698.HK 无风险利率参考 1.64%（2026-10-22）

COMMIT;
