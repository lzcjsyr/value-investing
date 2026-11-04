-- 重要事实改称“定性事实”；8 张上层表（商业模式拆解、产业链与五力、竞争壁垒、核心论点、假设依据、资产估值与调整、经营分部估值、逐年假设）
-- 增加“依据指标”（多对多关联指标），上层判断可以直接引用数据底稿里的指标（2026-11-04）。
-- 顺序：本迁移 → 02_calc.sql → 03_ui.sql → register.py → 重启 app → register.py --describe。
BEGIN;
CREATE TABLE IF NOT EXISTS vi_lnk_biz_model_basis_metrics (
  biz_model_id bigint NOT NULL REFERENCES vi_biz_model_base(id) ON DELETE CASCADE,
  metric_id bigint NOT NULL REFERENCES vi_metric_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (biz_model_id, metric_id)
);

COMMENT ON TABLE vi_lnk_biz_model_basis_metrics IS '商业模式拆解 ↔ 依据指标（多对多）';
CREATE TABLE IF NOT EXISTS vi_lnk_value_chain_basis_metrics (
  value_chain_id bigint NOT NULL REFERENCES vi_value_chain_base(id) ON DELETE CASCADE,
  metric_id bigint NOT NULL REFERENCES vi_metric_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (value_chain_id, metric_id)
);

COMMENT ON TABLE vi_lnk_value_chain_basis_metrics IS '产业链与五力 ↔ 依据指标（多对多）';
CREATE TABLE IF NOT EXISTS vi_lnk_moat_basis_metrics (
  moat_id bigint NOT NULL REFERENCES vi_moat_base(id) ON DELETE CASCADE,
  metric_id bigint NOT NULL REFERENCES vi_metric_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (moat_id, metric_id)
);

COMMENT ON TABLE vi_lnk_moat_basis_metrics IS '竞争壁垒 ↔ 依据指标（多对多）';
CREATE TABLE IF NOT EXISTS vi_lnk_thesis_basis_metrics (
  thesis_id bigint NOT NULL REFERENCES vi_thesis_base(id) ON DELETE CASCADE,
  metric_id bigint NOT NULL REFERENCES vi_metric_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (thesis_id, metric_id)
);

COMMENT ON TABLE vi_lnk_thesis_basis_metrics IS '核心论点 ↔ 依据指标（多对多）';
CREATE TABLE IF NOT EXISTS vi_lnk_judgment_basis_metrics (
  judgment_id bigint NOT NULL REFERENCES vi_judgment_base(id) ON DELETE CASCADE,
  metric_id bigint NOT NULL REFERENCES vi_metric_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (judgment_id, metric_id)
);

COMMENT ON TABLE vi_lnk_judgment_basis_metrics IS '假设依据 ↔ 依据指标（多对多）';
CREATE TABLE IF NOT EXISTS vi_lnk_sotp_item_basis_metrics (
  sotp_item_id bigint NOT NULL REFERENCES vi_sotp_item_base(id) ON DELETE CASCADE,
  metric_id bigint NOT NULL REFERENCES vi_metric_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (sotp_item_id, metric_id)
);

COMMENT ON TABLE vi_lnk_sotp_item_basis_metrics IS '资产估值与调整 ↔ 依据指标（多对多）';
CREATE TABLE IF NOT EXISTS vi_lnk_sotp_segment_basis_metrics (
  sotp_segment_id bigint NOT NULL REFERENCES vi_sotp_segment_base(id) ON DELETE CASCADE,
  metric_id bigint NOT NULL REFERENCES vi_metric_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (sotp_segment_id, metric_id)
);

COMMENT ON TABLE vi_lnk_sotp_segment_basis_metrics IS '经营分部估值 ↔ 依据指标（多对多）';
CREATE TABLE IF NOT EXISTS vi_lnk_forecast_basis_metrics (
  forecast_id bigint NOT NULL REFERENCES vi_forecast_base(id) ON DELETE CASCADE,
  metric_id bigint NOT NULL REFERENCES vi_metric_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (forecast_id, metric_id)
);

COMMENT ON TABLE vi_lnk_forecast_basis_metrics IS '逐年假设 ↔ 依据指标（多对多）';
-- 表说明（定性事实的定位、各表“引用【指标】”）与 01_schema.sql 一致
COMMENT ON TABLE vi_company_base IS '公司：研究的公司，以及它的业务量和单价怎么定义；引用【指标】；各表都按公司归属。研究对象。业务量/单价的名称和单位在这里定义，估值模型统一用“业务量×单价＝收入”。';
COMMENT ON TABLE vi_source_base IS '来源文档：所有数据和事实的出处；被【定性事实】【竞争对手】【数据】【指标数值】引用。原始出处：年报、公告、数据库取数、官网。重要事实、每期数据都关联它；一份文档可以支撑多条事实和数据。';
COMMENT ON TABLE vi_fact_base IS '定性事实：数字以外、会改变判断的事实：制度监管、合作授权、并购与资本运作、人事、诉讼、管理层表态、竞争对手动作，以及外部观点与估值参照；引用【来源文档】；被【商业模式拆解】【产业链与五力】【竞争对手】【竞争壁垒】【核心论点】【风险分析】【假设依据】【资产估值与调整】【经营分部估值】【逐年假设】引用。一条可核验的定性事实，写清发生了什么，解释放到论点或假设依据。按期重复的数字不放这里：它们在「指标／数据」里，上层判断用“依据指标”引用；一次性的数字（并购对价、回购额度）可以写进事实。';
COMMENT ON TABLE vi_business_base IS '业务分部：商业模式和业务估值共用的业务身份；不随模型或情景重复；被【商业模式拆解】【资产估值与调整】【经营分部估值】【分部逐情景计算】引用。一家公司的一块业务一行。明确业务边界、共享费用分摊与经营资产归属；现金、投资和可单独处置资产在资产估值与调整中处理。';
COMMENT ON TABLE vi_biz_model_base IS '商业模式拆解：用商业模式画布 9 项讲清公司怎么赚钱；引用【定性事实】【业务分部】【指标】。商业模式画布 9 项，每块业务一项一行（B1—B9 按画布顺序）；所属业务留空表示集团整体或共性，不表示自动继承。投资者关心的内容放进画布：盈利公式的收入一侧、收入结构、单价、增长与周期写在“收入来源”；盈利公式的成本一侧、成本构成、单位利润、资本需求与现金循环写在“成本结构”。只写事实与机制；有争议、决定价值的判断写在核心论点里。';
COMMENT ON TABLE vi_value_chain_base IS '产业链与五力：产业链上下游各方对公司的议价力强弱；引用【定性事实】【竞争对手】【指标】。上下游各环节是谁、拿走多少利润、对公司的议价力强弱；每行同时标注属于波特五力中的哪一种力量。同业、替代品、潜在进入者这几行只评估力量强弱，具体对手的规模与打法写在竞争对手表，并在“相关对手”里关联。';
COMMENT ON TABLE vi_competitor_base IS '竞争对手：具体竞争对手的规模、打法和威胁；引用【来源文档】【定性事实】；被【产业链与五力】引用。直接对手、替代品、潜在进入者与海外对标。关键数字写明截至日期；第三方估算在来源里注明。';
COMMENT ON TABLE vi_moat_base IS '竞争壁垒：公司有哪些护城河，各靠什么机制成立；引用【定性事实】【核心论点】【指标】【历史年度】；被【质量自检】引用。每一项候选壁垒：机制、财务体现、证据、反证、复制难度；看起来像壁垒其实不是的（伪壁垒）也要列出。壁垒能不能持续，在核心论点里正反论证并关联到这里。可设自动检查，读取历史年度。';
COMMENT ON TABLE vi_thesis_base IS '核心论点：决定公司价值的关键判断（问题与结论），每条正反辩论后下结论；引用【定性事实】【指标】【历史年度】；被【竞争壁垒】【风险分析】【价投适配度】【假设依据】【质量自检】引用。决定价值的几个关键判断，每条都正反论证：正方立论、反方立论、互相反驳，再给裁决、把握、改判条件和对模型的影响。判断只写这里：没有答案的判断性问题也写成论点，缺的证据写进“决定胜负的证据”，不进“待办清单”。壁垒能否持续的论点关联到竞争壁垒（伪壁垒以外每项壁垒至少一条辩论过的论点）；能量化的改判条件设自动检查，读取历史年度。';
COMMENT ON TABLE vi_risk_base IS '风险分析：可能让这笔投资亏钱的事件；引用【定性事实】【核心论点】【假设依据】【指标】；被【质量自检】引用。会让这笔投资亏钱的不利事件：传导路径、可能性×冲击（自动定级）、量化影响、缓冲因素、在估值里怎么处理、预警信号与触发后应对。风险是论点失败或外部冲击的“事件”，论证本身仍在核心论点里，这里只关联会被削弱的论点；落到参数的关联假设依据，盯哪些数关联预警指标。';
COMMENT ON TABLE vi_fit_score_base IS '价投适配度：按八个维度打分，看公司适不适合价值投资；引用【核心论点】；被【质量自检】引用。长坡、厚雪、慢变、护城河、再投资、财务质量、治理配置、可估值性，各 0—5 分。总分 32—40 适合复利框架，22—31 合适，21 以下通常不符合价值投资标准。';
COMMENT ON TABLE vi_judgment_base IS '假设依据：每个估值参数为什么这样设；引用【定性事实】【核心论点】【指标】；被【风险分析】【逐年假设】【单参数试验】引用。事实 → 判断 → 参数：解释事实和论点如何影响哪个估值参数、改参数的门槛、什么情况下不改。论证本身写在核心论点里，这里只写到参数的传导。';
COMMENT ON TABLE vi_fin_stmt_base IS '财务数据：公司的季度三大报表原值；被【历史年度】【指标数值】引用。季度完整三大报表（资产负债表、利润表、现金流量表），一行＝公司×报表×报告期×科目，金额为报表原值折亿元。合并报表科目以这里为准，由 tools/fin_stmt.py 取数检验后入库，不手录（A 股来自新浪财报、港股来自东方财富港股报表，都经 akshare）。空白科目＝该期未披露。资产负债表是时点余额；利润表/现金流量表是年初至报告期末的累计数。';
COMMENT ON TABLE vi_metric_base IS '指标：一家公司要看的每一个数（经营、财务、行情与环境），一个指标一行：从哪来、最新值、是否到期；被【公司】【商业模式拆解】【产业链与五力】【竞争壁垒】【核心论点】【风险分析】【假设依据】【数据】【估值模型】【资产估值与调整】【经营分部估值】【逐年假设】【采集配置】【历史年度】【指标数值】【质量自检】引用。每期的数在「数据」里，口径记在每期数据上。来源方式：自动采集、公司披露／年报／手工整理（在「数据」里录）、报表计算（按报表公式从三大报表实时算，不另存）。所属公司为空的是宏观数据。';
COMMENT ON TABLE vi_observation_base IS '数据：每个指标每一期的数：统计时间、口径、数值、同比、来源文档和说明；引用【来源文档】【指标】【原始采集记录】；被【历史年度】【指标数值】【质量自检】引用。一行＝某个指标在某一期、某个口径下的一个数：自动采集的按天（股价、利率、水位），公司披露的按期（发电量、销量、新签合同额）。同一指标、同一口径、同一日期多次采集时取最后一次为“当前版本”；超出合理范围的为无效。报表计算的指标不在这里存数。出处只记一处：公司披露和历史补数关联“来源文档”，自动采集关联“原始采集记录”（只做解析与范围校验，不是财务核验）。';
COMMENT ON TABLE vi_model_base IS '估值模型：一家公司一版估值的基本参数；引用【指标】；被【情景】【资产估值与调整】【经营分部估值】【逐年假设】【财务预测】【单参数试验】【预测计算】【资产与资本】【估值结论】【分部逐情景计算】【分部加总估值】【敏感性：折现率×永续增长】【质量自检】引用。一家公司的一版估值模型：基准年、终值年、股本、折现率构成、期初负债与安全边际。';
COMMENT ON TABLE vi_scenario_base IS '情景：各情景对逐年假设的整体调整；引用【估值模型】；被【资产估值与调整】【经营分部估值】【预测计算】【估值结论】【分部逐情景计算】【分部加总估值】【质量自检】引用。情景＝对逐年假设的整体调整：业务量、单价、付现成本乘以系数，折现率与永续增长按情景设置。';
COMMENT ON TABLE vi_sotp_item_base IS '资产估值与调整：现金、投资、固定资产等独立价值，以及负债和归属调整；标明是否已含在业务价值中；引用【定性事实】【业务分部】【指标】【估值模型】【情景】；被【分部加总估值】引用。总价值＝业务估值＋资产估值与调整净额。单独计价的资产加计、负债扣减；已含业务估值或不计价的项目只作边界说明，计入值为零。固定资产只有在相关盈利、租金或处置收益未计入业务价值时才单独加计。情景留空＝全部，同编号情景专属行优先。';
COMMENT ON TABLE vi_sotp_segment_base IS '经营分部估值：分部加总里每个经营业务的估值；引用【定性事实】【业务分部】【指标】【估值模型】【情景】；被【分部逐情景计算】【分部加总估值】【质量自检】引用。分部加总里的经营业务，按发展阶段各用一种方法：成熟或周期业务用“盈利×倍数”（正常化盈利）；成长业务用“稳态折现”（稳态年盈利×退出倍数折回今天，加上到稳态前的期间现金流）；投入期业务用“承诺投入”（只计已承诺的成本，回报不计入）。一行一个分部；适用情景留空＝所有情景，同编号可按情景另写一行。';
COMMENT ON TABLE vi_forecast_base IS '逐年假设：基准情景下每年的经营与现金假设；引用【定性事实】【假设依据】【指标】【估值模型】；被【单参数试验】【预测计算】【资产与资本】【质量自检】引用。基准情景下每年的经营与现金假设。每格都显式填写（没有“留空继承”）；利息由债务滚动自动计算。';
COMMENT ON TABLE vi_fin_forecast_base IS '财务预测：券商研报式的逐年利润表与现金摘要预测（只用分部加总三块的公司，如腾讯音乐）；引用【估值模型】。每个预测年一行：三块收入、毛利率、费用率、其他收入与融资成本、税率、现金转化与资本开支、股东回报；利润表与期末净现金由计算列得出。只作财务预测，不做股息贴现；估值模型的 2027 年三块收入与这里一致。';
COMMENT ON TABLE vi_trial_base IS '单参数试验：只改一个参数，看每股价值变多少；引用【假设依据】【估值模型】【逐年假设】【预测计算】【估值结论】。在基准情景上只改一个参数，看每股价值变化多少。不改正式假设。';
COMMENT ON TABLE vi_issue_base IS '待办清单：做完即关的研究与工程待办：数据源、核验、模型缺口、待定的策略选择；不放对公司的判断。人工维护、做完即关的待办：数据源待接通、数值待核验、模型缺口、来源待核对，以及等你拍板的策略选择（如安全边际取哪一档）。对公司的判断（问题与结论）一律写在“核心论点”，缺的证据写在论点的“决定胜负的证据”，这里不重复；持续盯的数据在「指标」的“重点跟踪”标签（假设依据、风险关联的指标），数据能自动判断的在“质量自检”。';
COMMENT ON TABLE vi_change_log_base IS '变更日志：每次改假设或数据的记录。每次修改假设或数据：旧值、新值、理由、依据、验证。';
COMMENT ON TABLE vi_collector_base IS '采集配置：自动采集从哪里取数、写进哪个指标；引用【指标】；被【原始采集记录】【质量自检】引用。自动采集的数据源：地址、解析器与参数、写入哪个指标。新增股票或水文站只需加一行配置。';
COMMENT ON TABLE vi_collect_run_base IS '采集运行：每次手动触发采集的记录和结果；被【原始采集记录】引用。每按一次“立即采集”新增一行，触发“④ 手动采集”工作流跑完 采集→入库→自检；有公司时只采这家公司和通用指标，结果按本次的原始记录自动统计。';
COMMENT ON TABLE vi_raw_capture_base IS '原始采集记录：每次采集拿到的原始响应；引用【采集配置】【采集运行】；被【数据】引用。每次采集保存完整原始响应；解析、校验、去重全部由 SQL 视图完成，可追溯。';
COMMIT;
