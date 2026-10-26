-- 自动生成：framework/gen_sql.py。价值投资研究框架输入表

BEGIN;

CREATE OR REPLACE FUNCTION vi_touch_updated_at() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN NEW.updated_at := now(); RETURN NEW; END $$;

CREATE TABLE vi_company_base (
  id bigserial PRIMARY KEY,
  code text,
  name text,
  exchange text,
  industry text,
  currency text,
  volume_label text,
  volume_unit text,
  price_label text,
  price_unit text,
  is_default boolean,
  profile text,
  notes text,
  price_metric_id bigint,
  price_fx_metric_id bigint,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE vi_company_base IS '公司：研究的公司，以及它的业务量和单价怎么定义；引用【指标】；各表都按公司归属。研究对象。业务量/单价的名称和单位在这里定义，估值模型统一用“业务量×单价＝收入”。';

COMMENT ON COLUMN vi_company_base.code IS '证券代码：如 600900.SH';

COMMENT ON COLUMN vi_company_base.name IS '公司名称';

COMMENT ON COLUMN vi_company_base.exchange IS '交易所';

COMMENT ON COLUMN vi_company_base.industry IS '行业';

COMMENT ON COLUMN vi_company_base.currency IS '记账币种：金额统一为该币种亿元';

COMMENT ON COLUMN vi_company_base.volume_label IS '业务量名称：收入驱动的“量”，如发电量、销量';

COMMENT ON COLUMN vi_company_base.volume_unit IS '业务量单位：如 亿千瓦时';

COMMENT ON COLUMN vi_company_base.price_label IS '单价名称：收入驱动的“价”，如综合电价';

COMMENT ON COLUMN vi_company_base.price_unit IS '单价单位：如 元/千瓦时；业务量×单价应等于收入（亿元）';

COMMENT ON COLUMN vi_company_base.is_default IS '驾驶舱默认展示：已不再使用：每家公司在自己的菜单下都有驾驶舱';

COMMENT ON COLUMN vi_company_base.profile IS '公司简介';

COMMENT ON COLUMN vi_company_base.notes IS '备注';

COMMENT ON COLUMN vi_company_base.price_metric_id IS '股价指标（关联 指标）';

COMMENT ON COLUMN vi_company_base.price_fx_metric_id IS '股价汇率指标（关联 指标）';

CREATE TRIGGER vi_company_base_touch BEFORE UPDATE ON vi_company_base FOR EACH ROW EXECUTE FUNCTION vi_touch_updated_at();

CREATE TABLE vi_source_base (
  id bigserial PRIMARY KEY,
  title text,
  source_type text,
  publisher text,
  publish_date date,
  url text,
  reliability text,
  verify_status text,
  retrieved_on date,
  summary text,
  limitations text,
  company_id bigint,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE vi_source_base IS '来源文档：所有数据和事实的出处；被【重要事实】【竞争对手】【历史年度】【数据】引用。原始出处：年报、公告、数据库取数、官网。一份文档可以支撑多条重要事实。';

COMMENT ON COLUMN vi_source_base.title IS '标题';

COMMENT ON COLUMN vi_source_base.source_type IS '类型（可选：定期报告、临时公告、官方网站、数据库取数、研究方法、研究推导、旧系统迁移）';

COMMENT ON COLUMN vi_source_base.publisher IS '发布方';

COMMENT ON COLUMN vi_source_base.publish_date IS '发布日期';

COMMENT ON COLUMN vi_source_base.url IS '链接';

COMMENT ON COLUMN vi_source_base.reliability IS '可靠性（可选：一级·法定披露、二级·官方统计、三级·第三方数据、研究推导）';

COMMENT ON COLUMN vi_source_base.verify_status IS '核验状态（可选：已读原文、数值已核对、待核验、仅定位入口）';

COMMENT ON COLUMN vi_source_base.retrieved_on IS '获取日期';

COMMENT ON COLUMN vi_source_base.summary IS '内容摘要';

COMMENT ON COLUMN vi_source_base.limitations IS '口径与局限';

COMMENT ON COLUMN vi_source_base.company_id IS '公司（关联 公司）';

CREATE TRIGGER vi_source_base_touch BEFORE UPDATE ON vi_source_base FOR EACH ROW EXECUTE FUNCTION vi_touch_updated_at();

CREATE TABLE vi_fact_base (
  id bigserial PRIMARY KEY,
  title text,
  category text,
  statement text,
  value double precision,
  unit text,
  period text,
  as_of date,
  verify_status text,
  notes text,
  company_id bigint,
  metric_id bigint,
  source_id bigint,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE vi_fact_base IS '重要事实：用来支撑分析的单条可核验事实；引用【来源文档】【指标】；被【商业模式拆解】【产业链与五力】【竞争对手】【竞争壁垒】【核心论点】【风险分析】【假设依据】【分部估值项】【经营分部估值】【逐年假设】引用。从来源文档里摘出的一条可核验事实（尽量带期间和单位）。事实只记录“是什么”，解释放到论点或假设依据里。按期重复的数字（发电量、销量、新签合同额等）以「数据」为准：选“数字引自”的指标并写所属期间，不再另抄一份；一次性的数字照常写在数值里。';

COMMENT ON COLUMN vi_fact_base.title IS '事实：一句话标题';

COMMENT ON COLUMN vi_fact_base.category IS '类别（可选：经营、财务、资本开支、分红、债务、政策、治理、水文、估值方法、其他）';

COMMENT ON COLUMN vi_fact_base.statement IS '事实陈述';

COMMENT ON COLUMN vi_fact_base.value IS '数值：一次性的数字；按期重复的数字改用“数字引自”';

COMMENT ON COLUMN vi_fact_base.unit IS '单位';

COMMENT ON COLUMN vi_fact_base.period IS '所属期间：如 2025、2026Q3';

COMMENT ON COLUMN vi_fact_base.as_of IS '截至日期';

COMMENT ON COLUMN vi_fact_base.verify_status IS '核验状态（可选：已核验、待核验、建议值待核验）';

COMMENT ON COLUMN vi_fact_base.notes IS '备注';

COMMENT ON COLUMN vi_fact_base.company_id IS '公司（关联 公司）';

COMMENT ON COLUMN vi_fact_base.metric_id IS '数字引自（指标）（关联 指标）';

COMMENT ON COLUMN vi_fact_base.source_id IS '来源文档（关联 来源文档）';

CREATE TRIGGER vi_fact_base_touch BEFORE UPDATE ON vi_fact_base FOR EACH ROW EXECUTE FUNCTION vi_touch_updated_at();

CREATE TABLE vi_biz_model_base (
  id bigserial PRIMARY KEY,
  code text,
  element text,
  title text,
  content text,
  metric text,
  trend text,
  company_id bigint,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE vi_biz_model_base IS '商业模式拆解：用商业模式画布 9 项讲清公司怎么赚钱；引用【重要事实】。商业模式画布 9 项，每家公司一项一行（B1—B9 按画布顺序）。投资者关心的内容放进画布：盈利公式的收入一侧、收入结构、单价、增长与周期写在“收入来源”；盈利公式的成本一侧、成本构成、单位利润、资本需求与现金循环写在“成本结构”。只写事实与机制；有争议、决定价值的判断写在核心论点里。';

COMMENT ON COLUMN vi_biz_model_base.code IS '编号：B1—B9，按画布顺序';

COMMENT ON COLUMN vi_biz_model_base.element IS '要素：客户细分：卖给谁｜价值主张：为什么买｜渠道通路：怎么触达和交付｜客户关系：怎么留住、合同与结算方式｜收入来源：收入公式（量×价）、结构、单价、增长与周期｜核心资源：不可或缺的资产与能力｜关键业务：公司自己做的事｜重要合作：控股股东、供应商、伙伴｜成本结构：成本构成、经营杠杆、单位利润、资本需求与现金循环（可选：客户细分、价值主张、渠道通路、客户关系、收入来源、核心资源、关键业务、重要合作、成本结构）';

COMMENT ON COLUMN vi_biz_model_base.title IS '要点';

COMMENT ON COLUMN vi_biz_model_base.content IS '说明';

COMMENT ON COLUMN vi_biz_model_base.metric IS '关键数字：如 毛利率 44%；ARPPU 11.9 元';

COMMENT ON COLUMN vi_biz_model_base.trend IS '变化与风险';

COMMENT ON COLUMN vi_biz_model_base.company_id IS '公司（关联 公司）';

CREATE TRIGGER vi_biz_model_base_touch BEFORE UPDATE ON vi_biz_model_base FOR EACH ROW EXECUTE FUNCTION vi_touch_updated_at();

CREATE TABLE vi_value_chain_base (
  id bigserial PRIMARY KEY,
  code text,
  position text,
  participant text,
  role text,
  force text,
  power text,
  effect text,
  trend text,
  profit_share text,
  analysis text,
  counter text,
  company_id bigint,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE vi_value_chain_base IS '产业链与五力：产业链上下游各方对公司的议价力强弱；引用【重要事实】【竞争对手】。上下游各环节是谁、拿走多少利润、对公司的议价力强弱；每行同时标注属于波特五力中的哪一种力量。同业、替代品、潜在进入者这几行只评估力量强弱，具体对手的规模与打法写在竞争对手表，并在“相关对手”里关联。';

COMMENT ON COLUMN vi_value_chain_base.code IS '编号：V1 固定是本公司环节，其余各方从 V2 起编';

COMMENT ON COLUMN vi_value_chain_base.position IS '环节（可选：上游供给、本公司环节、下游客户、渠道与流量、互补方、替代品、潜在进入者、同业竞争、监管）';

COMMENT ON COLUMN vi_value_chain_base.participant IS '参与者';

COMMENT ON COLUMN vi_value_chain_base.role IS '提供或购买什么';

COMMENT ON COLUMN vi_value_chain_base.force IS '五力归类（可选：供应商议价能力、买方议价能力、新进入者威胁、替代品威胁、行业内竞争、不适用）';

COMMENT ON COLUMN vi_value_chain_base.power IS '力量强弱（可选：强、中、弱）';

COMMENT ON COLUMN vi_value_chain_base.effect IS '对公司（可选：有利、中性、不利）';

COMMENT ON COLUMN vi_value_chain_base.trend IS '趋势（可选：增强、稳定、减弱）';

COMMENT ON COLUMN vi_value_chain_base.profit_share IS '利润池或成本占比：如 版权成本约占收入 45%—55%';

COMMENT ON COLUMN vi_value_chain_base.analysis IS '分析';

COMMENT ON COLUMN vi_value_chain_base.counter IS '反面证据';

COMMENT ON COLUMN vi_value_chain_base.company_id IS '公司（关联 公司）';

CREATE TRIGGER vi_value_chain_base_touch BEFORE UPDATE ON vi_value_chain_base FOR EACH ROW EXECUTE FUNCTION vi_touch_updated_at();

CREATE TABLE vi_competitor_base (
  id bigserial PRIMARY KEY,
  name text,
  ticker text,
  relation text,
  segment text,
  scale_label text,
  scale_value double precision,
  scale_unit text,
  paying_rate double precision,
  price_point text,
  gross_margin double precision,
  growth double precision,
  as_of date,
  strategy text,
  vs_us text,
  threat text,
  trend text,
  company_id bigint,
  source_id bigint,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE vi_competitor_base IS '竞争对手：具体竞争对手的规模、打法和威胁；引用【来源文档】【重要事实】；被【产业链与五力】引用。直接对手、替代品、潜在进入者与海外对标。关键数字写明截至日期；第三方估算在来源里注明。';

COMMENT ON COLUMN vi_competitor_base.name IS '对手';

COMMENT ON COLUMN vi_competitor_base.ticker IS '证券代码：未上市留空';

COMMENT ON COLUMN vi_competitor_base.relation IS '关系：同业对标＝同行业、不直接抢客户的对照公司（如不同流域的水电）（可选：直接竞争、同业对标、替代品、潜在进入者、海外对标、上游、下游与渠道）';

COMMENT ON COLUMN vi_competitor_base.segment IS '竞争领域';

COMMENT ON COLUMN vi_competitor_base.scale_label IS '规模指标：如 月活';

COMMENT ON COLUMN vi_competitor_base.scale_value IS '规模数值';

COMMENT ON COLUMN vi_competitor_base.scale_unit IS '规模单位';

COMMENT ON COLUMN vi_competitor_base.paying_rate IS '付费率或渗透率（小数，0.05＝5%）';

COMMENT ON COLUMN vi_competitor_base.price_point IS '价格：如 会员 8 元/月';

COMMENT ON COLUMN vi_competitor_base.gross_margin IS '毛利率（小数，0.05＝5%）';

COMMENT ON COLUMN vi_competitor_base.growth IS '收入或用户增速（小数，0.05＝5%）';

COMMENT ON COLUMN vi_competitor_base.as_of IS '截至';

COMMENT ON COLUMN vi_competitor_base.strategy IS '打法';

COMMENT ON COLUMN vi_competitor_base.vs_us IS '相对本公司的强项与弱项';

COMMENT ON COLUMN vi_competitor_base.threat IS '威胁程度（可选：高、中、低）';

COMMENT ON COLUMN vi_competitor_base.trend IS '势头（可选：上升、稳定、下降）';

COMMENT ON COLUMN vi_competitor_base.company_id IS '公司（关联 公司）';

COMMENT ON COLUMN vi_competitor_base.source_id IS '来源文档（关联 来源文档）';

CREATE TRIGGER vi_competitor_base_touch BEFORE UPDATE ON vi_competitor_base FOR EACH ROW EXECUTE FUNCTION vi_touch_updated_at();

CREATE TABLE vi_moat_base (
  id bigserial PRIMARY KEY,
  code text,
  title text,
  moat_type text,
  verdict text,
  strength text,
  trend text,
  mechanism text,
  financial_link text,
  evidence text,
  counter text,
  replication text,
  threats text,
  check_metric text,
  check_op text,
  check_threshold double precision,
  check_years integer,
  company_id bigint,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE vi_moat_base IS '竞争壁垒：公司有哪些护城河，各靠什么机制成立；引用【重要事实】【核心论点】【历史年度】；被【自动检查】引用。每一项候选壁垒：机制、财务体现、证据、反证、复制难度；看起来像壁垒其实不是的（伪壁垒）也要列出。壁垒能不能持续，在核心论点里正反论证并关联到这里。可设自动检查，读取历史年度。';

COMMENT ON COLUMN vi_moat_base.code IS '编号：如 M1';

COMMENT ON COLUMN vi_moat_base.title IS '壁垒';

COMMENT ON COLUMN vi_moat_base.moat_type IS '类型（可选：成本优势、品牌与定价权、转换成本、网络效应、规模经济、牌照与资源、工艺与组织、数据与算法、生态与渠道）';

COMMENT ON COLUMN vi_moat_base.verdict IS '判定（可选：真实壁垒、局部优势、伪壁垒、待验证）';

COMMENT ON COLUMN vi_moat_base.strength IS '强度（可选：强、中、弱、无）';

COMMENT ON COLUMN vi_moat_base.trend IS '趋势（可选：增强、稳定、削弱）';

COMMENT ON COLUMN vi_moat_base.mechanism IS '机制：为什么能带来超额回报';

COMMENT ON COLUMN vi_moat_base.financial_link IS '财务体现：体现在哪个指标：更高 ROIC 或毛利率、更高留存、更低获客成本、更稳定的现金流';

COMMENT ON COLUMN vi_moat_base.evidence IS '证据';

COMMENT ON COLUMN vi_moat_base.counter IS '反证';

COMMENT ON COLUMN vi_moat_base.replication IS '复制难度：竞争者复制需要多少时间、资本、组织能力和客户验证';

COMMENT ON COLUMN vi_moat_base.threats IS '削弱因素：新技术、监管、竞争者行为';

COMMENT ON COLUMN vi_moat_base.check_metric IS '自动检查·指标：从历史年度取值；留空表示不做自动检查（可选：业务量、单价、营业收入、归母净利润、派息率、财务费用、业务量同比、单价同比、营业收入同比、财务费用同比、毛利率、ROE、经营现金流÷归母净利润、资本开支÷经营现金流、净负债、净负债÷EBITDA）';

COMMENT ON COLUMN vi_moat_base.check_op IS '自动检查·条件（可选：<、<=、>、>=）';

COMMENT ON COLUMN vi_moat_base.check_threshold IS '自动检查·阈值：比率类填小数：-0.03 表示 -3%';

COMMENT ON COLUMN vi_moat_base.check_years IS '自动检查·连续年数：最近连续几年都满足条件才算触发';

COMMENT ON COLUMN vi_moat_base.company_id IS '公司（关联 公司）';

CREATE TRIGGER vi_moat_base_touch BEFORE UPDATE ON vi_moat_base FOR EACH ROW EXECUTE FUNCTION vi_touch_updated_at();

CREATE TABLE vi_thesis_base (
  id bigserial PRIMARY KEY,
  code text,
  title text,
  category text,
  status text,
  confidence text,
  bull_case text,
  bear_case text,
  bull_rebuttal text,
  bear_rebuttal text,
  verdict text,
  decisive_evidence text,
  mind_changer text,
  model_impact text,
  external_view text,
  debated_on date,
  check_metric text,
  check_op text,
  check_threshold double precision,
  check_years integer,
  company_id bigint,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE vi_thesis_base IS '核心论点：决定公司价值的关键判断（问题与结论），每条正反辩论后下结论；引用【重要事实】【历史年度】；被【竞争壁垒】【风险分析】【价投适配度】【假设依据】【跟踪事项】【自动检查】引用。决定价值的几个关键判断，每条都正反论证：正方立论、反方立论、互相反驳，再给裁决、把握、改判条件和对模型的影响。判断只写这里：没有答案的判断性问题也写成论点，缺的证据写进“决定胜负的证据”，不进“待办清单”。壁垒能否持续的论点关联到竞争壁垒（伪壁垒以外每项壁垒至少一条辩论过的论点）；能量化的改判条件设自动检查，读取历史年度。';

COMMENT ON COLUMN vi_thesis_base.code IS '编号：如 T1';

COMMENT ON COLUMN vi_thesis_base.title IS '论点：写成一个可以被证伪的判断';

COMMENT ON COLUMN vi_thesis_base.category IS '类别：不利事件本身写在风险分析；这里只放有争议、决定价值的判断（可选：壁垒、经营、财务、治理、估值）';

COMMENT ON COLUMN vi_thesis_base.status IS '裁决：成立＝正方占优；观察＝势均力敌或证据不足；存疑＝反方占优；证伪＝改判条件已经出现（可选：成立、观察、存疑、证伪）';

COMMENT ON COLUMN vi_thesis_base.confidence IS '把握（可选：高、中、低）';

COMMENT ON COLUMN vi_thesis_base.bull_case IS '正方立论：为什么成立、怎么影响现金流，附证据';

COMMENT ON COLUMN vi_thesis_base.bear_case IS '反方立论：反证与边界：什么情况下不成立或被高估';

COMMENT ON COLUMN vi_thesis_base.bull_rebuttal IS '正方反驳';

COMMENT ON COLUMN vi_thesis_base.bear_rebuttal IS '反方反驳';

COMMENT ON COLUMN vi_thesis_base.verdict IS '裁决理由';

COMMENT ON COLUMN vi_thesis_base.decisive_evidence IS '决定胜负的证据：下一步要看哪些数据，包括还没取得、需要去找的证据';

COMMENT ON COLUMN vi_thesis_base.mind_changer IS '改判条件：什么情况下改判；能量化的同时填下面的自动检查';

COMMENT ON COLUMN vi_thesis_base.model_impact IS '对模型的影响：只写关联之外的说明（如“不改参数，只跟踪”）；对应哪条假设依据在假设依据的“相关论点”里关联，状态自动汇总在“假设依据（状态）”';

COMMENT ON COLUMN vi_thesis_base.external_view IS '外部观点：卖方、外资、岗底斯观点 PK 的正反观点摘要；裁决仍由自己负责';

COMMENT ON COLUMN vi_thesis_base.debated_on IS '辩论日期：做完正反立论与互相反驳后填写；竞争壁垒的“已辩论的论点数”按它统计';

COMMENT ON COLUMN vi_thesis_base.check_metric IS '自动检查·指标：从历史年度取值；留空表示不做自动检查（可选：业务量、单价、营业收入、归母净利润、派息率、财务费用、业务量同比、单价同比、营业收入同比、财务费用同比、毛利率、ROE、经营现金流÷归母净利润、资本开支÷经营现金流、净负债、净负债÷EBITDA）';

COMMENT ON COLUMN vi_thesis_base.check_op IS '自动检查·条件（可选：<、<=、>、>=）';

COMMENT ON COLUMN vi_thesis_base.check_threshold IS '自动检查·阈值：比率类填小数：-0.03 表示 -3%';

COMMENT ON COLUMN vi_thesis_base.check_years IS '自动检查·连续年数：最近连续几年都满足条件才算触发';

COMMENT ON COLUMN vi_thesis_base.company_id IS '公司（关联 公司）';

CREATE TRIGGER vi_thesis_base_touch BEFORE UPDATE ON vi_thesis_base FOR EACH ROW EXECUTE FUNCTION vi_touch_updated_at();

CREATE TABLE vi_risk_base (
  id bigserial PRIMARY KEY,
  code text,
  title text,
  category text,
  mechanism text,
  probability text,
  impact text,
  horizon text,
  trend text,
  impact_estimate text,
  mitigants text,
  treatment text,
  early_warning text,
  response text,
  status text,
  company_id bigint,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE vi_risk_base IS '风险分析：可能让这笔投资亏钱的事件；引用【重要事实】【核心论点】【假设依据】【跟踪事项】；被【自动检查】引用。会让这笔投资亏钱的不利事件：传导路径、可能性×冲击（自动定级）、量化影响、缓冲因素、在估值里怎么处理、预警信号与触发后应对。风险是论点失败或外部冲击的“事件”，论证本身仍在核心论点里，这里只关联会被削弱的论点；落到参数的关联假设依据，盯什么关联跟踪事项。';

COMMENT ON COLUMN vi_risk_base.code IS '编号：如 R1';

COMMENT ON COLUMN vi_risk_base.title IS '风险：写成会发生的不利事件，如“连续枯水：年发电量两年以上低于 2,700 亿千瓦时”';

COMMENT ON COLUMN vi_risk_base.category IS '类别（可选：行业与竞争、技术与替代、经营与执行、财务与资产质量、政策与监管、治理与资本配置、宏观与环境、估值与市场）';

COMMENT ON COLUMN vi_risk_base.mechanism IS '传导路径：从事件到收入、利润、现金、估值的路径';

COMMENT ON COLUMN vi_risk_base.probability IS '可能性：未来三年内发生的可能性（可选：高、中、低）';

COMMENT ON COLUMN vi_risk_base.impact IS '冲击：发生后对每股价值的冲击：高＝超过 20%，中＝5%—20%，低＝5% 以内（可选：高、中、低）';

COMMENT ON COLUMN vi_risk_base.horizon IS '时间窗口（可选：1 年内、1—3 年、3 年以上）';

COMMENT ON COLUMN vi_risk_base.trend IS '趋势（可选：上升、稳定、下降）';

COMMENT ON COLUMN vi_risk_base.impact_estimate IS '影响测算：能量化的写数：对利润、现金或每股价值的影响（可引用单参数试验、情景）';

COMMENT ON COLUMN vi_risk_base.mitigants IS '缓冲因素：什么能限制损失';

COMMENT ON COLUMN vi_risk_base.treatment IS '估值处理：这项风险在估值里怎么体现；未计入的要在影响测算里说明为什么（可选：已计入基准情景、已计入悲观情景、体现在折现率或门槛、未计入估值）';

COMMENT ON COLUMN vi_risk_base.early_warning IS '预警信号：看什么、到什么程度算预警；已建跟踪事项的在“预警跟踪事项”里关联';

COMMENT ON COLUMN vi_risk_base.response IS '触发后应对：复核哪条论点或假设依据、要不要改参数（研究预警，不是交易指令）';

COMMENT ON COLUMN vi_risk_base.status IS '状态（可选：监控中、已部分发生、已发生、已缓解、已解除）';

COMMENT ON COLUMN vi_risk_base.company_id IS '公司（关联 公司）';

CREATE TRIGGER vi_risk_base_touch BEFORE UPDATE ON vi_risk_base FOR EACH ROW EXECUTE FUNCTION vi_touch_updated_at();

CREATE TABLE vi_fit_score_base (
  id bigserial PRIMARY KEY,
  dimension text,
  score integer,
  rationale text,
  counter text,
  sort integer,
  company_id bigint,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE vi_fit_score_base IS '价投适配度：按八个维度打分，看公司适不适合价值投资；引用【核心论点】；被【自动检查】引用。长坡、厚雪、慢变、护城河、再投资、财务质量、治理配置、可估值性，各 0—5 分。总分 32—40 适合复利框架，22—31 可研究，21 以下通常不符合价值投资标准。';

COMMENT ON COLUMN vi_fit_score_base.dimension IS '维度（可选：长坡、厚雪、慢变、护城河、再投资、财务质量、治理配置、可估值性）';

COMMENT ON COLUMN vi_fit_score_base.score IS '评分（0—5）';

COMMENT ON COLUMN vi_fit_score_base.rationale IS '理由与证据';

COMMENT ON COLUMN vi_fit_score_base.counter IS '反证';

COMMENT ON COLUMN vi_fit_score_base.sort IS '排序';

COMMENT ON COLUMN vi_fit_score_base.company_id IS '公司（关联 公司）';

CREATE TRIGGER vi_fit_score_base_touch BEFORE UPDATE ON vi_fit_score_base FOR EACH ROW EXECUTE FUNCTION vi_touch_updated_at();

CREATE TABLE vi_judgment_base (
  id bigserial PRIMARY KEY,
  code text,
  title text,
  fact_layer text,
  judgment text,
  transmission text,
  parameter text,
  affected_years text,
  change_threshold text,
  no_change_condition text,
  counter_evidence text,
  status text,
  company_id bigint,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE vi_judgment_base IS '假设依据：每个估值参数为什么这样设；引用【重要事实】【核心论点】；被【风险分析】【逐年假设】【单参数试验】【跟踪事项】引用。事实 → 判断 → 参数：解释事实和论点如何影响哪个估值参数、改参数的门槛、什么情况下不改。论证本身写在核心论点里，这里只写到参数的传导。';

COMMENT ON COLUMN vi_judgment_base.code IS '编号：如 J-Q';

COMMENT ON COLUMN vi_judgment_base.title IS '判断主题';

COMMENT ON COLUMN vi_judgment_base.fact_layer IS '事实层：需要观察到什么事实';

COMMENT ON COLUMN vi_judgment_base.judgment IS '判断';

COMMENT ON COLUMN vi_judgment_base.transmission IS '数学传导：参数变化如何传到利润、现金和估值';

COMMENT ON COLUMN vi_judgment_base.parameter IS '影响参数';

COMMENT ON COLUMN vi_judgment_base.affected_years IS '影响年份/情景';

COMMENT ON COLUMN vi_judgment_base.change_threshold IS '修改门槛';

COMMENT ON COLUMN vi_judgment_base.no_change_condition IS '不改模型的情况';

COMMENT ON COLUMN vi_judgment_base.counter_evidence IS '反证或替代解释';

COMMENT ON COLUMN vi_judgment_base.status IS '状态（可选：研究规则、已形成建议、已采纳、已否决）';

COMMENT ON COLUMN vi_judgment_base.company_id IS '公司（关联 公司）';

CREATE TRIGGER vi_judgment_base_touch BEFORE UPDATE ON vi_judgment_base FOR EACH ROW EXECUTE FUNCTION vi_touch_updated_at();

CREATE TABLE vi_fin_stmt_base (
  id bigserial PRIMARY KEY,
  period text,
  period_end date,
  stmt text,
  item text,
  seq integer,
  amount double precision,
  company_id bigint,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE vi_fin_stmt_base IS '财务数据：公司的季度三大报表原值。季度完整三大报表（资产负债表、利润表、现金流量表），一行＝公司×报表×报告期×科目，金额为报表原值折亿元。合并报表科目以这里为准，由 tools/fin_stmt.py 取数检验后入库，不手录（A 股来自新浪财报、港股来自东方财富港股报表，都经 akshare）。空白科目＝该期未披露。资产负债表是时点余额；利润表/现金流量表是年初至报告期末的累计数。';

COMMENT ON COLUMN vi_fin_stmt_base.period IS '报告期：如 2025Q3；Q4 即年报口径';

COMMENT ON COLUMN vi_fin_stmt_base.period_end IS '期末日期';

COMMENT ON COLUMN vi_fin_stmt_base.stmt IS '报表（可选：资产负债表、利润表、现金流量表）';

COMMENT ON COLUMN vi_fin_stmt_base.item IS '科目：报表科目中文原名';

COMMENT ON COLUMN vi_fin_stmt_base.seq IS '行次：科目在报表内的顺序';

COMMENT ON COLUMN vi_fin_stmt_base.amount IS '金额（亿元）：报表原值÷1e8，累计口径';

COMMENT ON COLUMN vi_fin_stmt_base.company_id IS '公司（关联 公司）';

CREATE TRIGGER vi_fin_stmt_base_touch BEFORE UPDATE ON vi_fin_stmt_base FOR EACH ROW EXECUTE FUNCTION vi_touch_updated_at();

CREATE TABLE vi_fin_history_base (
  id bigserial PRIMARY KEY,
  year integer,
  scope_note text,
  volume double precision,
  revenue double precision,
  cost_of_sales double precision,
  pretax_profit double precision,
  income_tax double precision,
  np_parent double precision,
  minority_profit double precision,
  da double precision,
  finance_cost double precision,
  invest_income double precision,
  equity_income double precision,
  cfo double precision,
  capex double precision,
  investee_cash_div double precision,
  net_borrowing double precision,
  interest_debt double precision,
  cash double precision,
  equity_parent double precision,
  dividend_total double precision,
  dps double precision,
  note text,
  company_id bigint,
  source_id bigint,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE vi_fin_history_base IS '历史年度：财务模型的历史一侧：每年的关键财务和经营数字，和逐年假设同一套列；引用【来源文档】；被【竞争壁垒】【核心论点】引用。一年一行，是财务模型的历史实际（逐年假设是预测）。报表项按当年年报披露口径录入，与「财务数据」自动对账（tools/fin_stmt.py check），重组追溯等口径差写在口径说明；业务量、分红、每股股息、带息负债、折旧摊销等报表外或需定口径的项目只录在这里。空白＝尚未取得，不是 0。派生指标（单价、派息率、同比、ROE 等）自动计算，论点与竞争壁垒的自动检查读这里。';

COMMENT ON COLUMN vi_fin_history_base.year IS '年度';

COMMENT ON COLUMN vi_fin_history_base.scope_note IS '口径说明：并表范围变化等，如“四站口径”“六站全口径”';

COMMENT ON COLUMN vi_fin_history_base.volume IS '业务量：单位见公司表（长江电力＝发电量，亿千瓦时）';

COMMENT ON COLUMN vi_fin_history_base.revenue IS '营业收入（亿元）';

COMMENT ON COLUMN vi_fin_history_base.cost_of_sales IS '营业成本（亿元）：用于毛利率；含折旧等制造成本';

COMMENT ON COLUMN vi_fin_history_base.pretax_profit IS '利润总额（亿元）';

COMMENT ON COLUMN vi_fin_history_base.income_tax IS '所得税（亿元）';

COMMENT ON COLUMN vi_fin_history_base.np_parent IS '归母净利润（亿元）';

COMMENT ON COLUMN vi_fin_history_base.minority_profit IS '少数股东损益（亿元）';

COMMENT ON COLUMN vi_fin_history_base.da IS '折旧摊销（亿元）：含使用权资产折旧（2019 年起）';

COMMENT ON COLUMN vi_fin_history_base.finance_cost IS '财务费用（亿元）';

COMMENT ON COLUMN vi_fin_history_base.invest_income IS '投资收益（亿元）';

COMMENT ON COLUMN vi_fin_history_base.equity_income IS '权益法投资收益（亿元）：对联营合营企业的投资收益，非当期现金';

COMMENT ON COLUMN vi_fin_history_base.cfo IS '经营活动现金流（亿元）';

COMMENT ON COLUMN vi_fin_history_base.capex IS '资本开支（亿元）：购建固定资产、无形资产和其他长期资产支付的现金';

COMMENT ON COLUMN vi_fin_history_base.investee_cash_div IS '收到投资分红（亿元）：取得投资收益收到的现金';

COMMENT ON COLUMN vi_fin_history_base.net_borrowing IS '净借款（亿元）：取得借款−偿还债务；负数＝净还债';

COMMENT ON COLUMN vi_fin_history_base.interest_debt IS '带息负债（期末，亿元）';

COMMENT ON COLUMN vi_fin_history_base.cash IS '货币资金（期末，亿元）';

COMMENT ON COLUMN vi_fin_history_base.equity_parent IS '归母净资产（期末，亿元）：用于 ROE 与市净率';

COMMENT ON COLUMN vi_fin_history_base.dividend_total IS '现金分红总额（亿元）：归属该年度的分红（含中期）';

COMMENT ON COLUMN vi_fin_history_base.dps IS '每股股息（元）：归属该年度，含中期分红';

COMMENT ON COLUMN vi_fin_history_base.note IS '备注';

COMMENT ON COLUMN vi_fin_history_base.company_id IS '公司（关联 公司）';

COMMENT ON COLUMN vi_fin_history_base.source_id IS '主要来源（关联 来源文档）';

CREATE TRIGGER vi_fin_history_base_touch BEFORE UPDATE ON vi_fin_history_base FOR EACH ROW EXECUTE FUNCTION vi_touch_updated_at();

CREATE TABLE vi_metric_base (
  id bigserial PRIMARY KEY,
  code text,
  name text,
  unit text,
  category text,
  source_kind text DEFAULT '自动采集',
  basis text DEFAULT '时点',
  source_name text,
  frequency text,
  valid_min double precision,
  valid_max double precision,
  notes text,
  company_id bigint,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE vi_metric_base IS '指标：数字序列的定义：经营驱动、财务结果，以及行情、利率和水文等环境数据，按类别分开呈现；被【公司】【重要事实】【数据】【估值模型】【跟踪事项】【采集配置】【自动检查】引用。一条数字序列的定义，数值在「数据」里。来源方式区分自动采集、公司披露、年报和手工整理；所属公司为空的是宏观数据（利率、汇率、商品等），归“宏观数据”项目所有，各公司按需使用；只和一家公司有关的（股价、水位、发电量、销量）挂在这家公司下。同一含义不同口径（单季、累计）分成不同指标，不拼接。';

COMMENT ON COLUMN vi_metric_base.code IS '指标代码：稳定的英文代码，如 600900.SH.PRICE';

COMMENT ON COLUMN vi_metric_base.name IS '指标名称';

COMMENT ON COLUMN vi_metric_base.unit IS '单位：利率类直接存百分数值，如 1.65 表示 1.65%';

COMMENT ON COLUMN vi_metric_base.category IS '类别：业务驱动选经营，收入/利润/现金及分部财务选财务；合同额、合约销售额仍是业务。（可选：行情、利率、汇率、商品、宏观、水文、经营、财务、其他）';

COMMENT ON COLUMN vi_metric_base.source_kind IS '来源方式：类别区分业务与财务；公司披露/年报/手工整理的业务在“定期经营数据”，自动采集的水文、商品和经营指标在“高频业务数据”。（可选：自动采集、公司披露、年报、手工整理）';

COMMENT ON COLUMN vi_metric_base.basis IS '口径：时点＝某一天的值（股价、利率、水位）或期末余额；其余为期间数：年初至今累计用于月度简报，滚动四季度＝最近四个季度合计（可选：时点、单季、半年累计、前三季度累计、全年、年初至今累计、滚动四季度）';

COMMENT ON COLUMN vi_metric_base.source_name IS '数据来源';

COMMENT ON COLUMN vi_metric_base.frequency IS '频率';

COMMENT ON COLUMN vi_metric_base.valid_min IS '合理下限：超出范围的观察标记为无效，不参与计算';

COMMENT ON COLUMN vi_metric_base.valid_max IS '合理上限';

COMMENT ON COLUMN vi_metric_base.notes IS '说明';

COMMENT ON COLUMN vi_metric_base.company_id IS '所属公司（关联 公司）';

CREATE TRIGGER vi_metric_base_touch BEFORE UPDATE ON vi_metric_base FOR EACH ROW EXECUTE FUNCTION vi_touch_updated_at();

CREATE TABLE vi_observation_base (
  id bigserial PRIMARY KEY,
  obs_date date,
  period text,
  value double precision,
  yoy double precision,
  impact text,
  assessment text,
  summary text,
  status text,
  collected_at timestamptz,
  source text,
  note text,
  metric_id bigint,
  doc_id bigint,
  raw_capture_id bigint,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE vi_observation_base IS '数据：每个指标每一期的数值，以及对它的理解（经营影响、经营解读）；引用【来源文档】【指标】【原始采集记录】；被【自动检查】引用。一行＝某个指标在某一期的一个数：自动采集的按天（股价、利率、水位），公司披露的按期（发电量、销量、新签合同额）。同一指标同一日期多次采集时取最后一次为“当前版本”；超出合理范围的为无效。公司披露的数据写期间、同比、来源文档，以及经营影响、经营解读和披露摘要。';

COMMENT ON COLUMN vi_observation_base.obs_date IS '观察日期：自动采集为采集到的日期；公司披露为期末日期';

COMMENT ON COLUMN vi_observation_base.period IS '期间：公司披露的数据填，如 2026Q3、2026H1、2025';

COMMENT ON COLUMN vi_observation_base.value IS '数值';

COMMENT ON COLUMN vi_observation_base.yoy IS '同比（小数，0.05＝5%）';

COMMENT ON COLUMN vi_observation_base.impact IS '经营影响：结合比较基准与经营解读，判断这项数据对公司经营的影响。中性表示已有依据支持影响有限；待判断表示依据不足。（可选：利好、中性、利空、待判断）';

COMMENT ON COLUMN vi_observation_base.assessment IS '经营解读：结合公司业务说明比较基准、变化原因及对利润或模型假设的影响；缺少依据时留空。';

COMMENT ON COLUMN vi_observation_base.summary IS '披露摘要与口径：记录披露事实、统计范围、单季或累计口径、管理层披露摘要与推算过程；研究判断写在经营解读。';

COMMENT ON COLUMN vi_observation_base.status IS '处理状态（可选：已入模、待处理、无需入模）';

COMMENT ON COLUMN vi_observation_base.collected_at IS '采集时间';

COMMENT ON COLUMN vi_observation_base.source IS '采集地址';

COMMENT ON COLUMN vi_observation_base.note IS '使用边界';

COMMENT ON COLUMN vi_observation_base.metric_id IS '指标（关联 指标）';

COMMENT ON COLUMN vi_observation_base.doc_id IS '来源文档（关联 来源文档）';

COMMENT ON COLUMN vi_observation_base.raw_capture_id IS '原始采集记录（关联 原始采集记录）';

CREATE TRIGGER vi_observation_base_touch BEFORE UPDATE ON vi_observation_base FOR EACH ROW EXECUTE FUNCTION vi_touch_updated_at();

CREATE TABLE vi_model_base (
  id bigserial PRIMARY KEY,
  name text,
  status text,
  method text,
  base_year integer,
  terminal_year integer,
  shares double precision,
  rf double precision,
  rf_date date,
  erp double precision,
  opening_debt double precision,
  opening_op_assets double precision,
  opening_lt_invest double precision,
  opening_equity double precision,
  opening_minority double precision,
  required_return double precision,
  margin_low double precision,
  margin_high double precision,
  notes text,
  primary_method text,
  sotp_year integer,
  sotp_core_adj double precision,
  sotp_as_of date,
  company_id bigint,
  rf_metric_id bigint,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE vi_model_base IS '估值模型：一家公司一版估值的基本参数；引用【指标】；被【情景】【分部估值项】【经营分部估值】【逐年假设】【单参数试验】【预测计算】【资产与资本】【估值结论】【分部加总估值】【敏感性：折现率×永续增长】【自动检查】引用。一家公司的一版估值模型：基准年、终值年、股本、折现率构成、期初负债与安全边际。';

COMMENT ON COLUMN vi_model_base.name IS '模型名称';

COMMENT ON COLUMN vi_model_base.status IS '状态（可选：当前、归档）';

COMMENT ON COLUMN vi_model_base.method IS '方法';

COMMENT ON COLUMN vi_model_base.base_year IS '基准年：估值基准日＝该年 12 月 31 日；预测从下一年开始';

COMMENT ON COLUMN vi_model_base.terminal_year IS '终值年：明确预测期最后一年，之后按永续增长';

COMMENT ON COLUMN vi_model_base.shares IS '股本（亿股）';

COMMENT ON COLUMN vi_model_base.rf IS '无风险利率：长期参数；自动采集的数据不会自动覆盖（小数，0.05＝5%）';

COMMENT ON COLUMN vi_model_base.rf_date IS '无风险利率日期';

COMMENT ON COLUMN vi_model_base.erp IS '风险溢价（小数，0.05＝5%）';

COMMENT ON COLUMN vi_model_base.opening_debt IS '期初带息负债（亿元）：基准年末余额，债务滚动的起点';

COMMENT ON COLUMN vi_model_base.opening_op_assets IS '期初经营性长期资产（亿元）：基准年末固定资产＋在建工程＋无形资产＋使用权资产';

COMMENT ON COLUMN vi_model_base.opening_lt_invest IS '期初长期股权投资（亿元）';

COMMENT ON COLUMN vi_model_base.opening_equity IS '期初归母权益（亿元）';

COMMENT ON COLUMN vi_model_base.opening_minority IS '期初少数股东权益（亿元）';

COMMENT ON COLUMN vi_model_base.required_return IS '要求收益率：投资者自己的门槛回报（机会成本）。用于算隐含收益率是否达标、以及按此收益率的最高买入价；与基准折现率是两个视角（小数，0.05＝5%）';

COMMENT ON COLUMN vi_model_base.margin_low IS '安全边际·低档（小数，0.05＝5%）';

COMMENT ON COLUMN vi_model_base.margin_high IS '安全边际·高档（小数，0.05＝5%）';

COMMENT ON COLUMN vi_model_base.notes IS '模型说明';

COMMENT ON COLUMN vi_model_base.primary_method IS '主估值方法：驾驶舱先展示哪一种，另一种作交叉验证；留空＝股息贴现（可选：股息贴现、分部加总）';

COMMENT ON COLUMN vi_model_base.sotp_year IS '分部加总·核心盈利年份：取哪一年的预测核心盈利（通常是下一个完整年度）；留空＝不用预测计算，经营业务全部写在“经营分部估值”';

COMMENT ON COLUMN vi_model_base.sotp_core_adj IS '分部加总·核心盈利调整（亿元）：税后归母口径，如加回收购形成的无形资产摊销；股权激励不加回';

COMMENT ON COLUMN vi_model_base.sotp_as_of IS '分部加总·资产负债日：现金、负债、对外投资与股本的统一截止日';

COMMENT ON COLUMN vi_model_base.company_id IS '公司（关联 公司）';

COMMENT ON COLUMN vi_model_base.rf_metric_id IS '无风险利率参考指标（关联 指标）';

CREATE TRIGGER vi_model_base_touch BEFORE UPDATE ON vi_model_base FOR EACH ROW EXECUTE FUNCTION vi_touch_updated_at();

CREATE TABLE vi_scenario_base (
  id bigserial PRIMARY KEY,
  name text,
  is_base boolean,
  sort integer,
  volume_factor double precision,
  price_factor double precision,
  cost_factor double precision,
  discount_rate double precision,
  terminal_growth double precision,
  nature text,
  description text,
  ronic double precision,
  sotp_multiple double precision,
  probability double precision,
  model_id bigint,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE vi_scenario_base IS '情景：各情景对逐年假设的整体调整；引用【估值模型】；被【分部估值项】【经营分部估值】【预测计算】【估值结论】【分部加总估值】【自动检查】引用。情景＝对逐年假设的整体调整：业务量、单价、付现成本乘以系数，折现率与永续增长按情景设置。';

COMMENT ON COLUMN vi_scenario_base.name IS '情景';

COMMENT ON COLUMN vi_scenario_base.is_base IS '基准情景：敏感性分析和单参数试验以基准情景为起点';

COMMENT ON COLUMN vi_scenario_base.sort IS '排序';

COMMENT ON COLUMN vi_scenario_base.volume_factor IS '业务量系数：1＝不调整；0.9＝业务量−10%';

COMMENT ON COLUMN vi_scenario_base.price_factor IS '单价系数';

COMMENT ON COLUMN vi_scenario_base.cost_factor IS '付现成本系数';

COMMENT ON COLUMN vi_scenario_base.discount_rate IS '折现率（留空＝基准折现率）（小数，0.05＝5%）';

COMMENT ON COLUMN vi_scenario_base.terminal_growth IS '永续增长率（小数，0.05＝5%）';

COMMENT ON COLUMN vi_scenario_base.nature IS '假设性质';

COMMENT ON COLUMN vi_scenario_base.description IS '情景说明';

COMMENT ON COLUMN vi_scenario_base.ronic IS '新增投资回报率：分部加总推导合理倍数用：P/E＝(1−g÷新增投资回报率)÷(r−g)（小数，0.05＝5%）';

COMMENT ON COLUMN vi_scenario_base.sotp_multiple IS '合理倍数（手填）：填了就用手填值，留空则按公式推导';

COMMENT ON COLUMN vi_scenario_base.probability IS '情景概率：分部加总的概率加权价值用；同一模型各情景合计应为 100%，留空＝不加权（小数，0.05＝5%）';

COMMENT ON COLUMN vi_scenario_base.model_id IS '估值模型（关联 估值模型）';

CREATE TRIGGER vi_scenario_base_touch BEFORE UPDATE ON vi_scenario_base FOR EACH ROW EXECUTE FUNCTION vi_touch_updated_at();

CREATE TABLE vi_sotp_item_base (
  id bigserial PRIMARY KEY,
  code text,
  name text,
  kind text,
  amount double precision,
  haircut double precision,
  as_of date,
  basis text,
  model_id bigint,
  scenario_id bigint,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE vi_sotp_item_base IS '分部估值项：分部加总里经营业务以外的加减项（现金、负债、对外投资等）；引用【重要事实】【估值模型】【情景】；被【分部加总估值】引用。分部加总估值里核心业务以外的部分：现金、带息负债、经营所需现金、资金汇出成本、对外投资、少数股东权益。一行一项；适用情景留空＝所有情景，某个情景另有同编号的一行时以那一行为准。';

COMMENT ON COLUMN vi_sotp_item_base.code IS '编号：如 C1；同一编号可按情景各写一行';

COMMENT ON COLUMN vi_sotp_item_base.name IS '项目';

COMMENT ON COLUMN vi_sotp_item_base.kind IS '类别（可选：现金及等价物、带息负债、经营所需现金、资金汇出成本、对外投资、少数股东权益、其他调整）';

COMMENT ON COLUMN vi_sotp_item_base.amount IS '金额（亿元）：填正数，类别决定加减：现金与对外投资为加，其余为减；“其他调整”按填写的正负号';

COMMENT ON COLUMN vi_sotp_item_base.haircut IS '折价：对金额打的折扣，如对外投资的持有折价与处置税费（小数，0.05＝5%）';

COMMENT ON COLUMN vi_sotp_item_base.as_of IS '截至';

COMMENT ON COLUMN vi_sotp_item_base.basis IS '依据';

COMMENT ON COLUMN vi_sotp_item_base.model_id IS '估值模型（关联 估值模型）';

COMMENT ON COLUMN vi_sotp_item_base.scenario_id IS '适用情景（关联 情景）';

CREATE TRIGGER vi_sotp_item_base_touch BEFORE UPDATE ON vi_sotp_item_base FOR EACH ROW EXECUTE FUNCTION vi_touch_updated_at();

CREATE TABLE vi_sotp_segment_base (
  id bigserial PRIMARY KEY,
  code text,
  name text,
  method text,
  stage text,
  earn_year integer,
  revenue double precision,
  op_margin double precision,
  tax_rate double precision,
  attrib double precision,
  multiple double precision,
  ronic double precision,
  growth double precision,
  discount_rate double precision,
  interim_cash double precision,
  commit_amount double precision,
  commit_years double precision,
  ongoing_cost double precision,
  direct_value double precision,
  basis text,
  model_id bigint,
  scenario_id bigint,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE vi_sotp_segment_base IS '经营分部估值：分部加总里每个经营业务的估值；引用【重要事实】【估值模型】【情景】；被【分部加总估值】【自动检查】引用。分部加总里的经营业务，按发展阶段各用一种方法：成熟或周期业务用“盈利×倍数”（正常化盈利）；成长业务用“稳态折现”（稳态年盈利×退出倍数折回今天，加上到稳态前的期间现金流）；投入期业务用“承诺投入”（只计已承诺的成本，回报不计入）。一行一个分部；适用情景留空＝所有情景，同编号可按情景另写一行。';

COMMENT ON COLUMN vi_sotp_segment_base.code IS '编号：如 S1；同一编号可按情景各写一行';

COMMENT ON COLUMN vi_sotp_segment_base.name IS '分部';

COMMENT ON COLUMN vi_sotp_segment_base.method IS '估值方法：盈利×倍数＝成熟或周期业务；稳态折现＝成长业务；承诺投入＝投入期业务（负值）；直接估值＝按可比公司或主观判断给整体价值（可选：盈利×倍数、稳态折现、承诺投入、直接估值）';

COMMENT ON COLUMN vi_sotp_segment_base.stage IS '发展阶段：如 成熟·周期底部、成长·规模爬坡、投入期';

COMMENT ON COLUMN vi_sotp_segment_base.earn_year IS '盈利年份：盈利×倍数＝正常化盈利所在年份；稳态折现＝稳态年份。价值按“该年年初价值＝该年盈利×倍数”折回资产负债日，例如资产负债日 2026-06-30、盈利年份 2027 年时折回 0.5 年';

COMMENT ON COLUMN vi_sotp_segment_base.revenue IS '收入（亿元）：盈利年份的分部收入；承诺投入不填';

COMMENT ON COLUMN vi_sotp_segment_base.op_margin IS '经营利润率：已扣股权激励，不含利息、投资收益与补贴（小数，0.05＝5%）';

COMMENT ON COLUMN vi_sotp_segment_base.tax_rate IS '所得税率：承诺投入填研发加计扣除后的实际抵税率（小数，0.05＝5%）';

COMMENT ON COLUMN vi_sotp_segment_base.attrib IS '归母比例：留空＝100%（小数，0.05＝5%）';

COMMENT ON COLUMN vi_sotp_segment_base.multiple IS '倍数（手填）：填了就用手填值；留空按 (1−g÷新增投资回报率)÷(r−g)';

COMMENT ON COLUMN vi_sotp_segment_base.ronic IS '新增投资回报率：留空＝情景的新增投资回报率（小数，0.05＝5%）';

COMMENT ON COLUMN vi_sotp_segment_base.growth IS '永续增长率：留空＝情景的永续增长率；承诺投入＝承诺期后年成本的增长率（小数，0.05＝5%）';

COMMENT ON COLUMN vi_sotp_segment_base.discount_rate IS '折现率：留空＝情景折现率；成长业务可加执行风险溢价（小数，0.05＝5%）';

COMMENT ON COLUMN vi_sotp_segment_base.interim_cash IS '期间现金流（亿元）：资产负债日到盈利年份年初之间的税后累计现金流（负数＝净投入），按期中折现';

COMMENT ON COLUMN vi_sotp_segment_base.commit_amount IS '承诺投入·剩余金额（亿元）：资产负债日之后尚需投入的税前金额（扣除相关收入）';

COMMENT ON COLUMN vi_sotp_segment_base.commit_years IS '承诺投入·剩余年数';

COMMENT ON COLUMN vi_sotp_segment_base.ongoing_cost IS '承诺期后年成本（亿元）：承诺期结束后每年仍需承担、没有回报覆盖的税前净成本；留空＝0';

COMMENT ON COLUMN vi_sotp_segment_base.direct_value IS '直接估值（亿元）：直接估值：按可比公司、交易价格或主观判断给出的整体价值（已含该业务未来的投入与回报），不折现';

COMMENT ON COLUMN vi_sotp_segment_base.basis IS '依据';

COMMENT ON COLUMN vi_sotp_segment_base.model_id IS '估值模型（关联 估值模型）';

COMMENT ON COLUMN vi_sotp_segment_base.scenario_id IS '适用情景（关联 情景）';

CREATE TRIGGER vi_sotp_segment_base_touch BEFORE UPDATE ON vi_sotp_segment_base FOR EACH ROW EXECUTE FUNCTION vi_touch_updated_at();

CREATE TABLE vi_forecast_base (
  id bigserial PRIMARY KEY,
  year integer,
  volume double precision,
  price double precision,
  cash_cost double precision,
  depreciation double precision,
  other_contrib double precision,
  tax_rate double precision,
  minority_share double precision,
  payout double precision,
  net_borrowing double precision,
  cost_of_debt double precision,
  noncash_gain_deduct double precision,
  investee_cash_div double precision,
  other_cash_adj double precision,
  wc_increase double precision,
  maint_capex double precision,
  growth_capex double precision,
  min_cash_topup double precision,
  operating_status text,
  cash_status text,
  note text,
  model_id bigint,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE vi_forecast_base IS '逐年假设：基准情景下每年的经营与现金假设；引用【重要事实】【假设依据】【估值模型】；被【单参数试验】【预测计算】【资产与资本】【自动检查】引用。基准情景下每年的经营与现金假设。每格都显式填写（没有“留空继承”）；利息由债务滚动自动计算。';

COMMENT ON COLUMN vi_forecast_base.year IS '年度';

COMMENT ON COLUMN vi_forecast_base.volume IS '业务量';

COMMENT ON COLUMN vi_forecast_base.price IS '单价';

COMMENT ON COLUMN vi_forecast_base.cash_cost IS '付现成本（亿元）：营业成本中非折旧部分＋期间费用＋税金及附加';

COMMENT ON COLUMN vi_forecast_base.depreciation IS '折旧摊销（亿元）';

COMMENT ON COLUMN vi_forecast_base.other_contrib IS '其他净贡献（亿元）：投资收益、公允价值变动、减值、营业外等净额';

COMMENT ON COLUMN vi_forecast_base.tax_rate IS '所得税率（小数，0.05＝5%）';

COMMENT ON COLUMN vi_forecast_base.minority_share IS '少数股东占比：少数股东损益占净利润的比例（小数，0.05＝5%）';

COMMENT ON COLUMN vi_forecast_base.payout IS '派息率（小数，0.05＝5%）';

COMMENT ON COLUMN vi_forecast_base.net_borrowing IS '净借款（亿元）：负数＝净还债；决定期末负债与利息';

COMMENT ON COLUMN vi_forecast_base.cost_of_debt IS '平均债务成本：利息＝平均带息负债×平均债务成本（小数，0.05＝5%）';

COMMENT ON COLUMN vi_forecast_base.noncash_gain_deduct IS '非现金收益扣除（亿元）：权益法收益等记入利润但未收到现金的部分';

COMMENT ON COLUMN vi_forecast_base.investee_cash_div IS '收到投资分红（亿元）';

COMMENT ON COLUMN vi_forecast_base.other_cash_adj IS '其他现金调整（亿元）：必须有明确依据；不能用来凑数';

COMMENT ON COLUMN vi_forecast_base.wc_increase IS '营运资本增加（亿元）：增加＝占用现金';

COMMENT ON COLUMN vi_forecast_base.maint_capex IS '维持资本开支（亿元）：维持现有业务量所需的更新改造';

COMMENT ON COLUMN vi_forecast_base.growth_capex IS '扩张资本开支（亿元）：新项目投资；其收益是否已计入收入要在说明里写清';

COMMENT ON COLUMN vi_forecast_base.min_cash_topup IS '最低现金补充（亿元）：为保持安全现金余额而留存的现金';

COMMENT ON COLUMN vi_forecast_base.operating_status IS '经营假设状态（可选：旧模型迁移、建议值待核验、已核验）';

COMMENT ON COLUMN vi_forecast_base.cash_status IS '现金桥接状态（可选：未填、建议值待核验、已核验）';

COMMENT ON COLUMN vi_forecast_base.note IS '说明';

COMMENT ON COLUMN vi_forecast_base.model_id IS '估值模型（关联 估值模型）';

CREATE TRIGGER vi_forecast_base_touch BEFORE UPDATE ON vi_forecast_base FOR EACH ROW EXECUTE FUNCTION vi_touch_updated_at();

CREATE TABLE vi_trial_base (
  id bigserial PRIMARY KEY,
  name text,
  start_year integer,
  end_year integer,
  volume_delta double precision,
  price_delta double precision,
  cost_delta double precision,
  da_delta double precision,
  interest_delta double precision,
  rate_delta double precision,
  boundary text,
  model_id bigint,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE vi_trial_base IS '单参数试验：只改一个参数，看每股价值变多少；引用【假设依据】【估值模型】【逐年假设】【预测计算】【估值结论】。在基准情景上只改一个参数，看每股价值变化多少。不改正式假设。';

COMMENT ON COLUMN vi_trial_base.name IS '试验';

COMMENT ON COLUMN vi_trial_base.start_year IS '开始年度';

COMMENT ON COLUMN vi_trial_base.end_year IS '结束年度';

COMMENT ON COLUMN vi_trial_base.volume_delta IS '业务量变动：−0.1＝业务量−10%（小数，0.05＝5%）';

COMMENT ON COLUMN vi_trial_base.price_delta IS '单价变动（小数，0.05＝5%）';

COMMENT ON COLUMN vi_trial_base.cost_delta IS '付现成本变动（亿元/年）';

COMMENT ON COLUMN vi_trial_base.da_delta IS '折旧变动（亿元/年）';

COMMENT ON COLUMN vi_trial_base.interest_delta IS '利息变动（亿元/年）';

COMMENT ON COLUMN vi_trial_base.rate_delta IS '折现率变动：0.005＝提高 50bp（小数，0.05＝5%）';

COMMENT ON COLUMN vi_trial_base.boundary IS '事实与判断边界';

COMMENT ON COLUMN vi_trial_base.model_id IS '估值模型（关联 估值模型）';

CREATE TRIGGER vi_trial_base_touch BEFORE UPDATE ON vi_trial_base FOR EACH ROW EXECUTE FUNCTION vi_touch_updated_at();

CREATE TABLE vi_watch_base (
  id bigserial PRIMARY KEY,
  code text,
  title text,
  purpose text,
  fetch_method text,
  preferred_source text,
  frequency text,
  compare text DEFAULT '数值',
  baseline double precision,
  lower double precision,
  upper double precision,
  trigger text,
  action text,
  company_id bigint,
  metric_id bigint,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE vi_watch_base IS '跟踪事项：研究员要盯的核心数据，每条服务于论点或估值参数；引用【核心论点】【假设依据】【指标】；被【风险分析】引用。每条写明模型基准和触发线；数值在“数据”里（关联指标），取数方式见字段说明（季报后跑 tools/track_fetch.py）。状态自动算：已触发、待更新（过了下次应更新日期还没新数）、正常、无数据。研究预警，不是交易指令。';

COMMENT ON COLUMN vi_watch_base.code IS '编号：如 W1';

COMMENT ON COLUMN vi_watch_base.title IS '跟踪什么：一个能量化的数，写清口径，如“新签合同总额·年初累计同比”';

COMMENT ON COLUMN vi_watch_base.purpose IS '为什么跟踪：它验证哪个判断、喂给哪个参数，模型或论点现在假设多少';

COMMENT ON COLUMN vi_watch_base.fetch_method IS '取数方式：自动采集＝采集配置（行情、利率、汇率、水位、期货）；脚本抓取＝tools/track_fetch.py 从财务数据（季报）算出；手动录入＝在“数据”里录；事件阅读＝没有数值（可选：自动采集、脚本抓取、手动录入、事件阅读）';

COMMENT ON COLUMN vi_watch_base.preferred_source IS '来源：具体到哪份公告、哪个报表科目或网址';

COMMENT ON COLUMN vi_watch_base.frequency IS '更新频率：决定“下次应更新”日期（可选：交易日、周、月、季、半年、年、不定期）';

COMMENT ON COLUMN vi_watch_base.compare IS '比较：触发线和基准比的是指标的数值还是同比（可选：数值、同比）';

COMMENT ON COLUMN vi_watch_base.baseline IS '模型基准：模型或论点假设的水平，与“比较”同口径（同比填小数，如 −0.05）';

COMMENT ON COLUMN vi_watch_base.lower IS '触发下限：最新值低于它即“已触发”';

COMMENT ON COLUMN vi_watch_base.upper IS '触发上限：最新值高于它即“已触发”';

COMMENT ON COLUMN vi_watch_base.trigger IS '触发条件说明：用文字写清触发线的含义；组合条件或需要人工判断的写在这里';

COMMENT ON COLUMN vi_watch_base.action IS '触发后动作：复核哪条论点、哪个参数';

COMMENT ON COLUMN vi_watch_base.company_id IS '公司（关联 公司）';

COMMENT ON COLUMN vi_watch_base.metric_id IS '数据（指标）（关联 指标）';

CREATE TRIGGER vi_watch_base_touch BEFORE UPDATE ON vi_watch_base FOR EACH ROW EXECUTE FUNCTION vi_touch_updated_at();

CREATE TABLE vi_issue_base (
  id bigserial PRIMARY KEY,
  code text,
  title text,
  severity text,
  impact text,
  done_condition text,
  status text,
  progress text,
  company_id bigint,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE vi_issue_base IS '待办清单：做完即关的研究与工程待办：数据源、核验、模型缺口、待定的策略选择；不放对公司的判断。人工维护、做完即关的待办：数据源待接通、数值待核验、模型缺口、来源待核对，以及等你拍板的策略选择（如安全边际取哪一档）。对公司的判断（问题与结论）一律写在“核心论点”，缺的证据写在论点的“决定胜负的证据”，这里不重复；持续盯的指标在“跟踪事项”，数据能自动判断的在“自动检查”。';

COMMENT ON COLUMN vi_issue_base.code IS '编号';

COMMENT ON COLUMN vi_issue_base.title IS '待办：写成要做的一件事或要补的一个缺口，不写成对公司的判断';

COMMENT ON COLUMN vi_issue_base.severity IS '级别：关键＝影响估值结论；一般＝影响局部数字；策略＝等你拍板的交易纪律；数据源＝待接通或待补齐的数据（可选：关键、一般、策略、数据源）';

COMMENT ON COLUMN vi_issue_base.impact IS '影响范围';

COMMENT ON COLUMN vi_issue_base.done_condition IS '完成条件';

COMMENT ON COLUMN vi_issue_base.status IS '状态（可选：待处理、处理中、已解决、不处理）';

COMMENT ON COLUMN vi_issue_base.progress IS '进展';

COMMENT ON COLUMN vi_issue_base.company_id IS '公司（关联 公司）';

CREATE TRIGGER vi_issue_base_touch BEFORE UPDATE ON vi_issue_base FOR EACH ROW EXECUTE FUNCTION vi_touch_updated_at();

CREATE TABLE vi_change_log_base (
  id bigserial PRIMARY KEY,
  change_date date,
  title text,
  target text,
  old_value text,
  new_value text,
  reason text,
  basis text,
  verification text,
  company_id bigint,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE vi_change_log_base IS '变更日志：每次改假设或数据的记录。每次修改假设或数据：旧值、新值、理由、依据、验证。';

COMMENT ON COLUMN vi_change_log_base.change_date IS '日期';

COMMENT ON COLUMN vi_change_log_base.title IS '变更';

COMMENT ON COLUMN vi_change_log_base.target IS '对象';

COMMENT ON COLUMN vi_change_log_base.old_value IS '旧值';

COMMENT ON COLUMN vi_change_log_base.new_value IS '新值';

COMMENT ON COLUMN vi_change_log_base.reason IS '理由';

COMMENT ON COLUMN vi_change_log_base.basis IS '依据';

COMMENT ON COLUMN vi_change_log_base.verification IS '验证';

COMMENT ON COLUMN vi_change_log_base.company_id IS '公司（关联 公司）';

CREATE TRIGGER vi_change_log_base_touch BEFORE UPDATE ON vi_change_log_base FOR EACH ROW EXECUTE FUNCTION vi_touch_updated_at();

CREATE TABLE vi_collector_base (
  id bigserial PRIMARY KEY,
  name text,
  url text,
  parser text,
  parser_param text,
  enabled boolean,
  max_lag_days integer,
  last_selfcheck timestamptz,
  selfcheck_result text,
  notes text,
  metric_id bigint,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE vi_collector_base IS '采集配置：自动采集从哪里取数、写进哪个指标；引用【指标】；被【原始采集记录】【自动检查】引用。自动采集的数据源：地址、解析器与参数、写入哪个指标。新增股票或水文站只需加一行配置。';

COMMENT ON COLUMN vi_collector_base.name IS '名称';

COMMENT ON COLUMN vi_collector_base.url IS '采集地址';

COMMENT ON COLUMN vi_collector_base.parser IS '解析器：tencent_quote＝腾讯行情（A 股、港股）；tencent_fx＝腾讯外汇行情；chinabond_curve＝中债收益率曲线；cjh_reservoir＝长江水文网水情；sina_future＝新浪期货行情（可选：tencent_quote、tencent_fx、chinabond_curve、cjh_reservoir、sina_future）';

COMMENT ON COLUMN vi_collector_base.parser_param IS '解析参数：腾讯：股票代码如 sh600900、hk01698；腾讯外汇：货币对如 whHKDCNY；中债：期限如 10年；水文：站码:字段，如 60106980:z（z＝水位）；新浪期货：合约如 SP0（纸浆连续）';

COMMENT ON COLUMN vi_collector_base.enabled IS '启用';

COMMENT ON COLUMN vi_collector_base.max_lag_days IS '允许观察滞后（天）';

COMMENT ON COLUMN vi_collector_base.last_selfcheck IS '最近自检';

COMMENT ON COLUMN vi_collector_base.selfcheck_result IS '自检结果';

COMMENT ON COLUMN vi_collector_base.notes IS '说明';

COMMENT ON COLUMN vi_collector_base.metric_id IS '写入指标（关联 指标）';

CREATE TRIGGER vi_collector_base_touch BEFORE UPDATE ON vi_collector_base FOR EACH ROW EXECUTE FUNCTION vi_touch_updated_at();

CREATE TABLE vi_collect_run_base (
  id bigserial PRIMARY KEY,
  label text,
  trigger_source text,
  status text,
  company_id bigint,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE vi_collect_run_base IS '采集运行：每次手动触发采集的记录和结果；被【原始采集记录】引用。每按一次“立即采集”新增一行，触发“④ 手动采集”工作流跑完 采集→入库→自检；有公司时只采这家公司和通用指标，结果按本次的原始记录自动统计。';

COMMENT ON COLUMN vi_collect_run_base.label IS '运行：例如：手动｜2026-10-21 23:50';

COMMENT ON COLUMN vi_collect_run_base.trigger_source IS '发起方式（可选：手动、定时）';

COMMENT ON COLUMN vi_collect_run_base.status IS '状态（可选：排队、运行中、完成）';

COMMENT ON COLUMN vi_collect_run_base.company_id IS '公司（关联 公司）';

CREATE TRIGGER vi_collect_run_base_touch BEFORE UPDATE ON vi_collect_run_base FOR EACH ROW EXECUTE FUNCTION vi_touch_updated_at();

CREATE TABLE vi_raw_capture_base (
  id bigserial PRIMARY KEY,
  run_label text,
  collected_at timestamptz,
  status text,
  fetch_result text,
  raw_response text,
  collector_id bigint,
  run_id bigint,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE vi_raw_capture_base IS '原始采集记录：每次采集拿到的原始响应；引用【采集配置】【采集运行】；被【数据】引用。每次采集保存完整原始响应；解析、校验、去重全部由 SQL 视图完成，可追溯。';

COMMENT ON COLUMN vi_raw_capture_base.run_label IS '运行标识';

COMMENT ON COLUMN vi_raw_capture_base.collected_at IS '采集时间';

COMMENT ON COLUMN vi_raw_capture_base.status IS '处理状态（可选：采集中、待入库、抓取失败、已入库、重复未入库、校验失败）';

COMMENT ON COLUMN vi_raw_capture_base.fetch_result IS '抓取结果（原文）：采集工作流写入：HTTP 状态码，或连接错误原文';

COMMENT ON COLUMN vi_raw_capture_base.raw_response IS '原始响应';

COMMENT ON COLUMN vi_raw_capture_base.collector_id IS '采集配置（关联 采集配置）';

COMMENT ON COLUMN vi_raw_capture_base.run_id IS '采集运行（关联 采集运行）';

CREATE TRIGGER vi_raw_capture_base_touch BEFORE UPDATE ON vi_raw_capture_base FOR EACH ROW EXECUTE FUNCTION vi_touch_updated_at();

ALTER TABLE vi_company_base ADD FOREIGN KEY (price_metric_id) REFERENCES vi_metric_base(id) ON DELETE SET NULL;

CREATE INDEX ON vi_company_base (price_metric_id);

ALTER TABLE vi_company_base ADD FOREIGN KEY (price_fx_metric_id) REFERENCES vi_metric_base(id) ON DELETE SET NULL;

CREATE INDEX ON vi_company_base (price_fx_metric_id);

ALTER TABLE vi_source_base ADD FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE SET NULL;

CREATE INDEX ON vi_source_base (company_id);

ALTER TABLE vi_fact_base ADD FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE SET NULL;

CREATE INDEX ON vi_fact_base (company_id);

ALTER TABLE vi_fact_base ADD FOREIGN KEY (metric_id) REFERENCES vi_metric_base(id) ON DELETE SET NULL;

CREATE INDEX ON vi_fact_base (metric_id);

ALTER TABLE vi_fact_base ADD FOREIGN KEY (source_id) REFERENCES vi_source_base(id) ON DELETE SET NULL;

CREATE INDEX ON vi_fact_base (source_id);

ALTER TABLE vi_biz_model_base ADD FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE SET NULL;

CREATE INDEX ON vi_biz_model_base (company_id);

ALTER TABLE vi_value_chain_base ADD FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE SET NULL;

CREATE INDEX ON vi_value_chain_base (company_id);

ALTER TABLE vi_competitor_base ADD FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE SET NULL;

CREATE INDEX ON vi_competitor_base (company_id);

ALTER TABLE vi_competitor_base ADD FOREIGN KEY (source_id) REFERENCES vi_source_base(id) ON DELETE SET NULL;

CREATE INDEX ON vi_competitor_base (source_id);

ALTER TABLE vi_moat_base ADD FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE SET NULL;

CREATE INDEX ON vi_moat_base (company_id);

ALTER TABLE vi_thesis_base ADD FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE SET NULL;

CREATE INDEX ON vi_thesis_base (company_id);

ALTER TABLE vi_risk_base ADD FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE SET NULL;

CREATE INDEX ON vi_risk_base (company_id);

ALTER TABLE vi_fit_score_base ADD FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE SET NULL;

CREATE INDEX ON vi_fit_score_base (company_id);

ALTER TABLE vi_judgment_base ADD FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE SET NULL;

CREATE INDEX ON vi_judgment_base (company_id);

ALTER TABLE vi_fin_stmt_base ADD FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE SET NULL;

CREATE INDEX ON vi_fin_stmt_base (company_id);

ALTER TABLE vi_fin_history_base ADD FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE SET NULL;

CREATE INDEX ON vi_fin_history_base (company_id);

ALTER TABLE vi_fin_history_base ADD FOREIGN KEY (source_id) REFERENCES vi_source_base(id) ON DELETE SET NULL;

CREATE INDEX ON vi_fin_history_base (source_id);

ALTER TABLE vi_metric_base ADD FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE SET NULL;

CREATE INDEX ON vi_metric_base (company_id);

ALTER TABLE vi_observation_base ADD FOREIGN KEY (metric_id) REFERENCES vi_metric_base(id) ON DELETE SET NULL;

CREATE INDEX ON vi_observation_base (metric_id);

ALTER TABLE vi_observation_base ADD FOREIGN KEY (doc_id) REFERENCES vi_source_base(id) ON DELETE SET NULL;

CREATE INDEX ON vi_observation_base (doc_id);

ALTER TABLE vi_observation_base ADD FOREIGN KEY (raw_capture_id) REFERENCES vi_raw_capture_base(id) ON DELETE SET NULL;

CREATE INDEX ON vi_observation_base (raw_capture_id);

ALTER TABLE vi_model_base ADD FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE SET NULL;

CREATE INDEX ON vi_model_base (company_id);

ALTER TABLE vi_model_base ADD FOREIGN KEY (rf_metric_id) REFERENCES vi_metric_base(id) ON DELETE SET NULL;

CREATE INDEX ON vi_model_base (rf_metric_id);

ALTER TABLE vi_scenario_base ADD FOREIGN KEY (model_id) REFERENCES vi_model_base(id) ON DELETE SET NULL;

CREATE INDEX ON vi_scenario_base (model_id);

ALTER TABLE vi_sotp_item_base ADD FOREIGN KEY (model_id) REFERENCES vi_model_base(id) ON DELETE SET NULL;

CREATE INDEX ON vi_sotp_item_base (model_id);

ALTER TABLE vi_sotp_item_base ADD FOREIGN KEY (scenario_id) REFERENCES vi_scenario_base(id) ON DELETE SET NULL;

CREATE INDEX ON vi_sotp_item_base (scenario_id);

ALTER TABLE vi_sotp_segment_base ADD FOREIGN KEY (model_id) REFERENCES vi_model_base(id) ON DELETE SET NULL;

CREATE INDEX ON vi_sotp_segment_base (model_id);

ALTER TABLE vi_sotp_segment_base ADD FOREIGN KEY (scenario_id) REFERENCES vi_scenario_base(id) ON DELETE SET NULL;

CREATE INDEX ON vi_sotp_segment_base (scenario_id);

ALTER TABLE vi_forecast_base ADD FOREIGN KEY (model_id) REFERENCES vi_model_base(id) ON DELETE SET NULL;

CREATE INDEX ON vi_forecast_base (model_id);

ALTER TABLE vi_trial_base ADD FOREIGN KEY (model_id) REFERENCES vi_model_base(id) ON DELETE SET NULL;

CREATE INDEX ON vi_trial_base (model_id);

ALTER TABLE vi_watch_base ADD FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE SET NULL;

CREATE INDEX ON vi_watch_base (company_id);

ALTER TABLE vi_watch_base ADD FOREIGN KEY (metric_id) REFERENCES vi_metric_base(id) ON DELETE SET NULL;

CREATE INDEX ON vi_watch_base (metric_id);

ALTER TABLE vi_issue_base ADD FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE SET NULL;

CREATE INDEX ON vi_issue_base (company_id);

ALTER TABLE vi_change_log_base ADD FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE SET NULL;

CREATE INDEX ON vi_change_log_base (company_id);

ALTER TABLE vi_collector_base ADD FOREIGN KEY (metric_id) REFERENCES vi_metric_base(id) ON DELETE SET NULL;

CREATE INDEX ON vi_collector_base (metric_id);

ALTER TABLE vi_collect_run_base ADD FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE SET NULL;

CREATE INDEX ON vi_collect_run_base (company_id);

ALTER TABLE vi_raw_capture_base ADD FOREIGN KEY (collector_id) REFERENCES vi_collector_base(id) ON DELETE SET NULL;

CREATE INDEX ON vi_raw_capture_base (collector_id);

ALTER TABLE vi_raw_capture_base ADD FOREIGN KEY (run_id) REFERENCES vi_collect_run_base(id) ON DELETE SET NULL;

CREATE INDEX ON vi_raw_capture_base (run_id);

ALTER TABLE vi_company_base ADD CONSTRAINT vi_company_uniq UNIQUE (code);

ALTER TABLE vi_metric_base ADD CONSTRAINT vi_metric_uniq UNIQUE (code);

ALTER TABLE vi_fin_stmt_base ADD CONSTRAINT vi_fin_stmt_uniq UNIQUE (company_id, stmt, period_end, item);

ALTER TABLE vi_fin_history_base ADD CONSTRAINT vi_fin_history_uniq UNIQUE (company_id, year);

ALTER TABLE vi_forecast_base ADD CONSTRAINT vi_forecast_uniq UNIQUE (model_id, year);

ALTER TABLE vi_scenario_base ADD CONSTRAINT vi_scenario_uniq UNIQUE (model_id, name);

ALTER TABLE vi_thesis_base ADD CONSTRAINT vi_thesis_uniq UNIQUE (company_id, code);

ALTER TABLE vi_judgment_base ADD CONSTRAINT vi_judgment_uniq UNIQUE (company_id, code);

ALTER TABLE vi_biz_model_base ADD CONSTRAINT vi_biz_model_uniq UNIQUE (company_id, code);

ALTER TABLE vi_value_chain_base ADD CONSTRAINT vi_value_chain_uniq UNIQUE (company_id, code);

ALTER TABLE vi_competitor_base ADD CONSTRAINT vi_competitor_uniq UNIQUE (company_id, name);

ALTER TABLE vi_moat_base ADD CONSTRAINT vi_moat_uniq UNIQUE (company_id, code);

ALTER TABLE vi_fit_score_base ADD CONSTRAINT vi_fit_score_uniq UNIQUE (company_id, dimension);

ALTER TABLE vi_risk_base ADD CONSTRAINT vi_risk_uniq UNIQUE (company_id, code);

CREATE TABLE vi_lnk_company_macro_metrics (
  company_id bigint NOT NULL REFERENCES vi_company_base(id) ON DELETE CASCADE,
  metric_id bigint NOT NULL REFERENCES vi_metric_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (company_id, metric_id)
);

COMMENT ON TABLE vi_lnk_company_macro_metrics IS '公司 ↔ 订阅的宏观数据（多对多）';

CREATE TABLE vi_lnk_biz_model_facts (
  biz_model_id bigint NOT NULL REFERENCES vi_biz_model_base(id) ON DELETE CASCADE,
  fact_id bigint NOT NULL REFERENCES vi_fact_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (biz_model_id, fact_id)
);

COMMENT ON TABLE vi_lnk_biz_model_facts IS '商业模式拆解 ↔ 依据事实（多对多）';

CREATE TABLE vi_lnk_value_chain_facts (
  value_chain_id bigint NOT NULL REFERENCES vi_value_chain_base(id) ON DELETE CASCADE,
  fact_id bigint NOT NULL REFERENCES vi_fact_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (value_chain_id, fact_id)
);

COMMENT ON TABLE vi_lnk_value_chain_facts IS '产业链与五力 ↔ 依据事实（多对多）';

CREATE TABLE vi_lnk_value_chain_competitors (
  value_chain_id bigint NOT NULL REFERENCES vi_value_chain_base(id) ON DELETE CASCADE,
  competitor_id bigint NOT NULL REFERENCES vi_competitor_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (value_chain_id, competitor_id)
);

COMMENT ON TABLE vi_lnk_value_chain_competitors IS '产业链与五力 ↔ 相关对手（多对多）';

CREATE TABLE vi_lnk_competitor_facts (
  competitor_id bigint NOT NULL REFERENCES vi_competitor_base(id) ON DELETE CASCADE,
  fact_id bigint NOT NULL REFERENCES vi_fact_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (competitor_id, fact_id)
);

COMMENT ON TABLE vi_lnk_competitor_facts IS '竞争对手 ↔ 依据事实（多对多）';

CREATE TABLE vi_lnk_moat_facts (
  moat_id bigint NOT NULL REFERENCES vi_moat_base(id) ON DELETE CASCADE,
  fact_id bigint NOT NULL REFERENCES vi_fact_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (moat_id, fact_id)
);

COMMENT ON TABLE vi_lnk_moat_facts IS '竞争壁垒 ↔ 依据事实（多对多）';

CREATE TABLE vi_lnk_moat_theses (
  moat_id bigint NOT NULL REFERENCES vi_moat_base(id) ON DELETE CASCADE,
  thesis_id bigint NOT NULL REFERENCES vi_thesis_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (moat_id, thesis_id)
);

COMMENT ON TABLE vi_lnk_moat_theses IS '竞争壁垒 ↔ 相关论点（多对多）';

CREATE TABLE vi_lnk_thesis_facts (
  thesis_id bigint NOT NULL REFERENCES vi_thesis_base(id) ON DELETE CASCADE,
  fact_id bigint NOT NULL REFERENCES vi_fact_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (thesis_id, fact_id)
);

COMMENT ON TABLE vi_lnk_thesis_facts IS '核心论点 ↔ 依据事实（多对多）';

CREATE TABLE vi_lnk_risk_theses (
  risk_id bigint NOT NULL REFERENCES vi_risk_base(id) ON DELETE CASCADE,
  thesis_id bigint NOT NULL REFERENCES vi_thesis_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (risk_id, thesis_id)
);

COMMENT ON TABLE vi_lnk_risk_theses IS '风险分析 ↔ 会削弱的论点（多对多）';

CREATE TABLE vi_lnk_risk_judgments (
  risk_id bigint NOT NULL REFERENCES vi_risk_base(id) ON DELETE CASCADE,
  judgment_id bigint NOT NULL REFERENCES vi_judgment_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (risk_id, judgment_id)
);

COMMENT ON TABLE vi_lnk_risk_judgments IS '风险分析 ↔ 估值对应的假设依据（多对多）';

CREATE TABLE vi_lnk_risk_watches (
  risk_id bigint NOT NULL REFERENCES vi_risk_base(id) ON DELETE CASCADE,
  watch_id bigint NOT NULL REFERENCES vi_watch_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (risk_id, watch_id)
);

COMMENT ON TABLE vi_lnk_risk_watches IS '风险分析 ↔ 预警跟踪事项（多对多）';

CREATE TABLE vi_lnk_risk_facts (
  risk_id bigint NOT NULL REFERENCES vi_risk_base(id) ON DELETE CASCADE,
  fact_id bigint NOT NULL REFERENCES vi_fact_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (risk_id, fact_id)
);

COMMENT ON TABLE vi_lnk_risk_facts IS '风险分析 ↔ 依据事实（多对多）';

CREATE TABLE vi_lnk_fit_score_theses (
  fit_score_id bigint NOT NULL REFERENCES vi_fit_score_base(id) ON DELETE CASCADE,
  thesis_id bigint NOT NULL REFERENCES vi_thesis_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (fit_score_id, thesis_id)
);

COMMENT ON TABLE vi_lnk_fit_score_theses IS '价投适配度 ↔ 相关论点（多对多）';

CREATE TABLE vi_lnk_judgment_facts (
  judgment_id bigint NOT NULL REFERENCES vi_judgment_base(id) ON DELETE CASCADE,
  fact_id bigint NOT NULL REFERENCES vi_fact_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (judgment_id, fact_id)
);

COMMENT ON TABLE vi_lnk_judgment_facts IS '假设依据 ↔ 依据事实（多对多）';

CREATE TABLE vi_lnk_judgment_theses (
  judgment_id bigint NOT NULL REFERENCES vi_judgment_base(id) ON DELETE CASCADE,
  thesis_id bigint NOT NULL REFERENCES vi_thesis_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (judgment_id, thesis_id)
);

COMMENT ON TABLE vi_lnk_judgment_theses IS '假设依据 ↔ 相关论点（多对多）';

CREATE TABLE vi_lnk_sotp_item_facts (
  sotp_item_id bigint NOT NULL REFERENCES vi_sotp_item_base(id) ON DELETE CASCADE,
  fact_id bigint NOT NULL REFERENCES vi_fact_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (sotp_item_id, fact_id)
);

COMMENT ON TABLE vi_lnk_sotp_item_facts IS '分部估值项 ↔ 依据事实（多对多）';

CREATE TABLE vi_lnk_sotp_segment_facts (
  sotp_segment_id bigint NOT NULL REFERENCES vi_sotp_segment_base(id) ON DELETE CASCADE,
  fact_id bigint NOT NULL REFERENCES vi_fact_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (sotp_segment_id, fact_id)
);

COMMENT ON TABLE vi_lnk_sotp_segment_facts IS '经营分部估值 ↔ 依据事实（多对多）';

CREATE TABLE vi_lnk_forecast_facts (
  forecast_id bigint NOT NULL REFERENCES vi_forecast_base(id) ON DELETE CASCADE,
  fact_id bigint NOT NULL REFERENCES vi_fact_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (forecast_id, fact_id)
);

COMMENT ON TABLE vi_lnk_forecast_facts IS '逐年假设 ↔ 依据事实（多对多）';

CREATE TABLE vi_lnk_forecast_judgments (
  forecast_id bigint NOT NULL REFERENCES vi_forecast_base(id) ON DELETE CASCADE,
  judgment_id bigint NOT NULL REFERENCES vi_judgment_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (forecast_id, judgment_id)
);

COMMENT ON TABLE vi_lnk_forecast_judgments IS '逐年假设 ↔ 假设依据（多对多）';

CREATE TABLE vi_lnk_trial_judgments (
  trial_id bigint NOT NULL REFERENCES vi_trial_base(id) ON DELETE CASCADE,
  judgment_id bigint NOT NULL REFERENCES vi_judgment_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (trial_id, judgment_id)
);

COMMENT ON TABLE vi_lnk_trial_judgments IS '单参数试验 ↔ 假设依据（多对多）';

CREATE TABLE vi_lnk_watch_theses (
  watch_id bigint NOT NULL REFERENCES vi_watch_base(id) ON DELETE CASCADE,
  thesis_id bigint NOT NULL REFERENCES vi_thesis_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (watch_id, thesis_id)
);

COMMENT ON TABLE vi_lnk_watch_theses IS '跟踪事项 ↔ 验证的论点（多对多）';

CREATE TABLE vi_lnk_watch_judgments (
  watch_id bigint NOT NULL REFERENCES vi_watch_base(id) ON DELETE CASCADE,
  judgment_id bigint NOT NULL REFERENCES vi_judgment_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (watch_id, judgment_id)
);

COMMENT ON TABLE vi_lnk_watch_judgments IS '跟踪事项 ↔ 对应假设依据（多对多）';

COMMIT;
