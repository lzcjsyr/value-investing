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
  scope_breaks text,
  pe_ttm double precision,
  pb double precision,
  pe_pb_date date,
  shares double precision,
  as_of date,
  value_layer text,
  layer_reason text,
  av_basis text DEFAULT '调整后净资产',
  repro_cost double precision,
  profile text,
  notes text,
  price_metric_id bigint,
  price_fx_metric_id bigint,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE vi_company_base IS '公司：研究的公司：股价取数、业务量口径与估值设置（截至日、股本、主估值层）；引用【指标】；各表都按公司归属。研究对象。业务量/单价的名称和单位用于历史年度与图表；资产价值口径和重建成本在「① 资产价值」维护，其余估值设置在「⑤ 股权价值」维护。';

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

COMMENT ON COLUMN vi_company_base.scope_breaks IS '口径变化年份：并表范围或披露口径变化的年份（如 2016、2023），历史年度里这些年与上一年不算同比';

COMMENT ON COLUMN vi_company_base.pe_ttm IS '市盈率TTM：市场口径（A 股东方财富、港股百度股市通），由 tools/pe_pb.py 经 akshare 写入；驾驶舱顶部显示';

COMMENT ON COLUMN vi_company_base.pb IS '市净率：同上，市场口径的最新市净率';

COMMENT ON COLUMN vi_company_base.pe_pb_date IS '市盈率/市净率日期：上面两个数对应的交易日';

COMMENT ON COLUMN vi_company_base.shares IS '股本（亿股）：估值用的普通股股数';

COMMENT ON COLUMN vi_company_base.as_of IS '估值截至日：资产负债重估取这一天的资产负债表；价值算到这一天，再按门槛滚到今天';

COMMENT ON COLUMN vi_company_base.value_layer IS '主估值层：以哪一层作结论（每股价值、隐含回报）；另两层做交叉检验（可选：资产价值、盈利能力价值、含增长价值）';

COMMENT ON COLUMN vi_company_base.layer_reason IS '主估值层依据：为什么选这一层';

COMMENT ON COLUMN vi_company_base.av_basis IS '资产价值口径：第一层怎么估（全公司）：调整后净资产＝资产负债重估里经营资产与经营负债的重估合计；重建成本＝下面填的重建成本；不适用＝资产说明不了价值（可选：调整后净资产、重建成本、不适用）';

COMMENT ON COLUMN vi_company_base.repro_cost IS '重建成本（亿元）：资产价值口径为“重建成本”时用：今天重建同等竞争地位（全公司经营）要花多少';

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

COMMENT ON TABLE vi_source_base IS '来源文档：所有数据和事实的出处；被【定性事实】【竞争对手】【数据】【指标数值】引用。原始出处：年报、公告、数据库取数、官网。定性事实、每期数据都关联它；一份文档可以支撑多条事实和数据。';

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

CREATE TABLE vi_event_base (
  id bigserial PRIMARY KEY,
  name text,
  category text,
  status text,
  period text,
  summary text,
  company_id bigint,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE vi_event_base IS '事项：一件事一行（并购、监管变化、竞争格局、资本运作等），短名称加简介；具体的可核验侧面是挂在它下面的定性事实；被【定性事实】引用。名称用短名词短语，不带数字；简介三五句讲清来龙去脉、关键条款和现状。每个侧面（日期、来源、核验状态各自独立）记在定性事实里，上层判断引用侧面；零散的一次性事实可以不挂事项。';

COMMENT ON COLUMN vi_event_base.name IS '事项：短名称，不带数字，如“喜马拉雅收购”';

COMMENT ON COLUMN vi_event_base.category IS '类别（可选：经营、财务、资本开支、分红、债务、政策、治理、竞争、估值方法、其他）';

COMMENT ON COLUMN vi_event_base.status IS '状态（可选：进行中、已完成、持续、待观察）';

COMMENT ON COLUMN vi_event_base.period IS '时间：发生或持续的时间，如 2026、2018—2025';

COMMENT ON COLUMN vi_event_base.summary IS '简介：三五句讲清来龙去脉、关键条款和现状；细节看下面的各个侧面';

COMMENT ON COLUMN vi_event_base.company_id IS '公司（关联 公司）';

CREATE TRIGGER vi_event_base_touch BEFORE UPDATE ON vi_event_base FOR EACH ROW EXECUTE FUNCTION vi_touch_updated_at();

CREATE TABLE vi_fact_base (
  id bigserial PRIMARY KEY,
  title text,
  category text,
  statement text,
  period text,
  as_of date,
  verify_status text,
  notes text,
  company_id bigint,
  event_id bigint,
  source_id bigint,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE vi_fact_base IS '定性事实：数字以外、会改变判断的事实：制度监管、合作授权、并购与资本运作、人事、诉讼、管理层表态、竞争对手动作，以及外部观点与估值参照；引用【来源文档】【事项】；被【商业模式拆解】【产业链与五力】【竞争对手】【竞争壁垒】【核心论点】【风险分析】【假设依据】引用。一条可核验的定性事实，通常是某个事项的一个侧面。按期重复的数字不放这里：它们在「指标／数据」里，上层判断用“依据指标”引用；一次性的数字（并购对价、回购额度）可以写进事实。';

COMMENT ON COLUMN vi_fact_base.title IS '侧面：短名称，说明是事项的哪个侧面，如“交易对价与商誉”';

COMMENT ON COLUMN vi_fact_base.category IS '类别（可选：经营、财务、资本开支、分红、债务、政策、治理、水文、估值方法、其他）';

COMMENT ON COLUMN vi_fact_base.statement IS '陈述：写清这个侧面发生了什么、关键数字与出处';

COMMENT ON COLUMN vi_fact_base.period IS '所属期间：如 2025、2026Q3';

COMMENT ON COLUMN vi_fact_base.as_of IS '截至日期';

COMMENT ON COLUMN vi_fact_base.verify_status IS '核验状态（可选：已核验、待核验、建议值待核验）';

COMMENT ON COLUMN vi_fact_base.notes IS '备注';

COMMENT ON COLUMN vi_fact_base.company_id IS '公司（关联 公司）';

COMMENT ON COLUMN vi_fact_base.event_id IS '所属事项（关联 事项）';

COMMENT ON COLUMN vi_fact_base.source_id IS '来源文档（关联 来源文档）';

CREATE TRIGGER vi_fact_base_touch BEFORE UPDATE ON vi_fact_base FOR EACH ROW EXECUTE FUNCTION vi_touch_updated_at();

CREATE TABLE vi_business_base (
  id bigserial PRIMARY KEY,
  code text,
  name text,
  boundary text,
  asset_boundary text,
  sort integer,
  capital_basis text DEFAULT '企业',
  company_id bigint,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE vi_business_base IS '业务分部：商业模式和估值共用的业务身份：一块能单独定价的业务一行；被【商业模式拆解】【调整后利润表】【增长】引用。以公司披露的经营分部为准（有自己的客户、资本和费用）；共用用户、内容或费用的收入来源不拆成业务。估值上它是第二、三层的估值单元（一块业务一张调整后利润表）；口径开关在这里定。第一层资产价值按全公司估，不分业务。';

COMMENT ON COLUMN vi_business_base.code IS '业务编号';

COMMENT ON COLUMN vi_business_base.name IS '业务名称';

COMMENT ON COLUMN vi_business_base.boundary IS '业务边界';

COMMENT ON COLUMN vi_business_base.asset_boundary IS '经营资产与投入边界';

COMMENT ON COLUMN vi_business_base.sort IS '排序';

COMMENT ON COLUMN vi_business_base.capital_basis IS '口径：企业＝利息前利润，有息负债在资产负债桥里扣；股权＝利息后利润，有息负债在资产负债重估里归为经营负债（银行、保险、地产开发等借钱就是生意本身）（可选：企业、股权）';

COMMENT ON COLUMN vi_business_base.company_id IS '公司（关联 公司）';

CREATE TRIGGER vi_business_base_touch BEFORE UPDATE ON vi_business_base FOR EACH ROW EXECUTE FUNCTION vi_touch_updated_at();

CREATE TABLE vi_biz_model_base (
  id bigserial PRIMARY KEY,
  code text,
  element text,
  title text,
  content text,
  metric text,
  trend text,
  company_id bigint,
  business_id bigint,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE vi_biz_model_base IS '商业模式拆解：用商业模式画布 9 项讲清公司怎么赚钱；引用【定性事实】【业务分部】【指标】。商业模式画布 9 项，每块业务一项一行（B1—B9 按画布顺序）；所属业务留空表示集团整体或共性，不表示自动继承。投资者关心的内容放进画布：盈利公式的收入一侧、收入结构、单价、增长与周期写在“收入来源”；盈利公式的成本一侧、成本构成、单位利润、资本需求与现金循环写在“成本结构”。只写事实与机制；有争议、决定价值的判断写在核心论点里。';

COMMENT ON COLUMN vi_biz_model_base.code IS '编号：B1—B9，按画布顺序；在公司和所属业务内唯一';

COMMENT ON COLUMN vi_biz_model_base.element IS '要素：客户细分：卖给谁｜价值主张：为什么买｜渠道通路：怎么触达和交付｜客户关系：怎么留住、合同与结算方式｜收入来源：收入公式（量×价）、结构、单价、增长与周期｜核心资源：不可或缺的资产与能力｜关键业务：公司自己做的事｜重要合作：控股股东、供应商、伙伴｜成本结构：成本构成、经营杠杆、单位利润、资本需求与现金循环（可选：客户细分、价值主张、渠道通路、客户关系、收入来源、核心资源、关键业务、重要合作、成本结构）';

COMMENT ON COLUMN vi_biz_model_base.title IS '要点';

COMMENT ON COLUMN vi_biz_model_base.content IS '说明';

COMMENT ON COLUMN vi_biz_model_base.metric IS '关键数字：如 毛利率 44%；ARPPU 11.9 元';

COMMENT ON COLUMN vi_biz_model_base.trend IS '变化与风险';

COMMENT ON COLUMN vi_biz_model_base.company_id IS '公司（关联 公司）';

COMMENT ON COLUMN vi_biz_model_base.business_id IS '所属业务（关联 业务分部）';

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

COMMENT ON TABLE vi_value_chain_base IS '产业链与五力：产业链上下游各方对公司的议价力强弱；引用【定性事实】【竞争对手】【指标】。上下游各环节是谁、拿走多少利润、对公司的议价力强弱；每行同时标注属于波特五力中的哪一种力量。同业、替代品、潜在进入者这几行只评估力量强弱，具体对手的规模与打法写在竞争对手表，并在“相关对手”里关联。';

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

COMMENT ON TABLE vi_competitor_base IS '竞争对手：具体竞争对手的规模、打法和威胁；引用【来源文档】【定性事实】；被【产业链与五力】引用。直接对手、替代品、潜在进入者与海外对标。关键数字写明截至日期；第三方估算在来源里注明。';

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

COMMENT ON TABLE vi_moat_base IS '竞争壁垒：公司有哪些护城河，各靠什么机制成立；引用【定性事实】【核心论点】【指标】【历史年度】；被【质量自检】引用。每一项候选壁垒：机制、财务体现、证据、反证、复制难度；看起来像壁垒其实不是的（伪壁垒）也要列出。壁垒能不能持续，在核心论点里正反论证并关联到这里。可设自动检查，读取历史年度。';

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

COMMENT ON TABLE vi_thesis_base IS '核心论点：决定公司价值的关键判断（问题与结论），每条正反辩论后下结论；引用【定性事实】【指标】【历史年度】；被【竞争壁垒】【风险分析】【价投适配度】【假设依据】【质量自检】引用。决定价值的几个关键判断，每条都正反论证：正方立论、反方立论、互相反驳，再给裁决、把握、改判条件和对模型的影响。判断只写这里：没答案的问题也写成论点，缺的证据写进“决定胜负的证据”。壁垒能否持续的论点关联到竞争壁垒（伪壁垒以外每项壁垒至少一条辩论过的论点）；能量化的改判条件设自动检查，读取历史年度。';

COMMENT ON COLUMN vi_thesis_base.code IS '编号：如 T1';

COMMENT ON COLUMN vi_thesis_base.title IS '论点：写成一个可以被证伪的判断';

COMMENT ON COLUMN vi_thesis_base.category IS '类别：不利事件本身写在风险分析；这里只放有争议、决定价值的判断（可选：经营、财务、治理、估值）';

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

COMMENT ON TABLE vi_risk_base IS '风险分析：可能让这笔投资亏钱的事件；引用【定性事实】【核心论点】【假设依据】【指标】；被【质量自检】引用。会让这笔投资亏钱的不利事件：传导路径、可能性×冲击（自动定级）、量化影响、缓冲因素、在估值里怎么处理、预警信号与触发后应对。风险是论点失败或外部冲击的“事件”，论证本身仍在核心论点里，这里只关联会被削弱的论点；落到参数的关联假设依据，盯哪些数关联预警指标。';

COMMENT ON COLUMN vi_risk_base.code IS '编号：如 R1';

COMMENT ON COLUMN vi_risk_base.title IS '风险：写成会发生的不利事件，如“连续枯水：年发电量两年以上低于 2,700 亿千瓦时”';

COMMENT ON COLUMN vi_risk_base.category IS '类别（可选：行业与竞争、技术与替代、经营与执行、财务与资产质量、政策与监管、治理与资本配置、宏观与环境、估值与市场）';

COMMENT ON COLUMN vi_risk_base.mechanism IS '传导路径：从事件到收入、利润、现金、估值的路径';

COMMENT ON COLUMN vi_risk_base.probability IS '可能性：未来三年内发生的可能性（可选：高、中、低）';

COMMENT ON COLUMN vi_risk_base.impact IS '冲击：发生后对每股价值的冲击：高＝超过 20%，中＝5%—20%，低＝5% 以内（可选：高、中、低）';

COMMENT ON COLUMN vi_risk_base.horizon IS '时间窗口（可选：1 年内、1—3 年、3 年以上）';

COMMENT ON COLUMN vi_risk_base.trend IS '趋势（可选：上升、稳定、下降）';

COMMENT ON COLUMN vi_risk_base.impact_estimate IS '影响测算：能量化的写数：对利润、现金或每股价值的影响';

COMMENT ON COLUMN vi_risk_base.mitigants IS '缓冲因素：什么能限制损失';

COMMENT ON COLUMN vi_risk_base.treatment IS '估值处理：这项风险在估值里怎么体现；未计入的要在影响测算里说明为什么（可选：已计入估值输入、体现在主估值层或门槛、未计入估值）';

COMMENT ON COLUMN vi_risk_base.early_warning IS '预警信号：看什么、到什么程度算预警；能用数据看的，把指标关联到“预警指标”；没有指标的定性事项写成“持续跟踪：…”';

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

COMMENT ON TABLE vi_fit_score_base IS '价投适配度：按八个维度打分，看公司适不适合价值投资；引用【核心论点】；被【质量自检】引用。长坡、厚雪、慢变、护城河、再投资、财务质量、治理配置、可估值性，各 0—5 分。总分 32—40 适合复利框架，22—31 合适，21 以下通常不符合价值投资标准。';

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
  change_threshold text,
  no_change_condition text,
  counter_evidence text,
  status text,
  company_id bigint,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE vi_judgment_base IS '假设依据：每个估值参数为什么这样设；引用【定性事实】【核心论点】【指标】；被【风险分析】【资产负债重估】【调整后利润表】【增长】引用。事实 → 判断 → 参数：解释事实和论点如何影响哪个估值参数、改参数的门槛、什么情况下不改。论证本身写在核心论点里，这里只写到参数的传导。';

COMMENT ON COLUMN vi_judgment_base.code IS '编号：如 J-Q';

COMMENT ON COLUMN vi_judgment_base.title IS '判断主题';

COMMENT ON COLUMN vi_judgment_base.fact_layer IS '事实层：需要观察到什么事实';

COMMENT ON COLUMN vi_judgment_base.judgment IS '判断';

COMMENT ON COLUMN vi_judgment_base.transmission IS '数学传导：参数变化如何传到利润、现金和估值';

COMMENT ON COLUMN vi_judgment_base.parameter IS '影响参数';

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
  currency text,
  unit text,
  company_id bigint,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE vi_fin_stmt_base IS '财务报表：公司的季度三大报表原值；被【资产负债重估】【调整后利润表】【历史年度】【指标数值】【质量自检】引用。季度完整三大报表（资产负债表、利润表、现金流量表），一行＝公司×报表×报告期×科目，金额为报表原值折亿元。合并报表科目以这里为准，由 tools/fin_stmt.py 取数检验后入库，不手录（A 股用新浪财报，小米用东方财富，均经 akshare；腾讯音乐用 SEC 文件及公司业绩公告）。空白科目＝该期未披露。资产负债表是时点余额；利润表/现金流量表是年初至报告期末的累计数。';

COMMENT ON COLUMN vi_fin_stmt_base.period IS '报告期：如 2025Q3；Q4 即年报口径';

COMMENT ON COLUMN vi_fin_stmt_base.period_end IS '期末日期';

COMMENT ON COLUMN vi_fin_stmt_base.stmt IS '报表（可选：资产负债表、利润表、现金流量表）';

COMMENT ON COLUMN vi_fin_stmt_base.item IS '科目：报表科目中文原名';

COMMENT ON COLUMN vi_fin_stmt_base.seq IS '行次：科目在报表内的顺序';

COMMENT ON COLUMN vi_fin_stmt_base.amount IS '数值：一般金额按亿元，每股数据按元/股';

COMMENT ON COLUMN vi_fin_stmt_base.currency IS '列报币种：ISO 币种代码，如 CNY、USD、HKD';

COMMENT ON COLUMN vi_fin_stmt_base.unit IS '单位：数值实际使用的单位，如 亿元、元/股；空表示待核对';

COMMENT ON COLUMN vi_fin_stmt_base.company_id IS '公司（关联 公司）';

CREATE TRIGGER vi_fin_stmt_base_touch BEFORE UPDATE ON vi_fin_stmt_base FOR EACH ROW EXECUTE FUNCTION vi_touch_updated_at();

CREATE TABLE vi_metric_base (
  id bigserial PRIMARY KEY,
  code text,
  name text,
  unit text,
  category text,
  measure text,
  source_kind text DEFAULT '自动采集',
  basis text DEFAULT '时点',
  model_field text,
  formula text,
  source_name text,
  frequency text,
  valid_min double precision,
  valid_max double precision,
  notes text,
  company_id bigint,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE vi_metric_base IS '指标：一家公司要看的每一个数（经营、财务、行情与环境），一个指标一行：从哪来、最新值、是否到期；被【公司】【商业模式拆解】【产业链与五力】【竞争壁垒】【核心论点】【风险分析】【假设依据】【数据】【采集配置】【历史年度】【指标数值】【质量自检】引用。每期的数在「数据」里，口径记在每期数据上。来源方式：自动采集、公司披露／年报／手工整理（在「数据」里录）、报表计算（按报表公式从三大报表实时算，不另存）。所属公司为空的是宏观数据。';

COMMENT ON COLUMN vi_metric_base.code IS '指标代码：稳定的英文代码，如 600900.SH.PRICE';

COMMENT ON COLUMN vi_metric_base.name IS '指标名称';

COMMENT ON COLUMN vi_metric_base.unit IS '单位：利率类直接存百分数值，如 1.65 表示 1.65%';

COMMENT ON COLUMN vi_metric_base.category IS '类别：业务驱动选经营，收入/利润/现金及分部财务选财务；合同额、合约销售额仍是业务。（可选：行情、利率、汇率、商品、宏观、水文、经营、财务、其他）';

COMMENT ON COLUMN vi_metric_base.measure IS '指标性质：时期指标（流量）＝一段时间内累计发生的量，如营业收入、利润、现金流、销量、回购金额；由它们算出的比率（毛利率、ARPPU）也是时期指标，同类时期可以相加（四个单季≈全年）。时点指标（存量）＝某一时刻的状态或规模，如现金、负债、净资产、负债率、股价、零售价、用户数；不能跨期相加，按季度平均的用户数也算时点。时点指标每期的口径只能是“时点”，时期指标不能用“时点”。留空＝还没判定（可选：时期、时点）';

COMMENT ON COLUMN vi_metric_base.source_kind IS '来源方式：报表计算＝按“报表公式”从三大报表实时算出，不在「数据」里存数（可选：自动采集、公司披露、年报、手工整理、报表计算）';

COMMENT ON COLUMN vi_metric_base.basis IS '主口径：最新值、趋势和重点跟踪按这个口径取；每期数据自己的口径记在「数据」上。时点指标只能选“时点”（可选：时点、单季、半年累计、前三季度累计、全年、年初至今累计、滚动四季度）';

COMMENT ON COLUMN vi_metric_base.model_field IS '模型字段：这个指标是财务模型历史一侧的哪一列（每家公司每列一个指标）；在「数据底稿 / 定量指标」的“模型字段”列标明（可选：volume、revenue、cost_of_sales、pretax_profit、income_tax、np_parent、minority_profit、da、finance_cost、invest_income、equity_income、cfo、capex、investee_cash_div、net_borrowing、interest_debt、cash、equity_parent、dividend_total、dps）';

COMMENT ON COLUMN vi_metric_base.formula IS '报表公式：报表计算的指标填：科目相加减，如“应收账款 + 合同资产”；比率用“÷”，如“（营业收入 − 营业成本）÷ 营业收入”（结果为 %）。科目名与三大报表一致';

COMMENT ON COLUMN vi_metric_base.source_name IS '数据来源：必填：这条序列从哪里来（公告名称、报表科目、网址或采集源）；每期的来源文档关联在“数据”上';

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
  basis text DEFAULT '时点',
  value double precision,
  yoy double precision,
  summary text,
  collected_at timestamptz,
  metric_id bigint,
  doc_id bigint,
  raw_capture_id bigint,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE vi_observation_base IS '数据：每个指标每一期的数：统计时间、口径、数值、同比、来源文档和说明；引用【来源文档】【指标】【原始采集记录】；被【历史年度】【指标数值】【质量自检】引用。一行＝某个指标在某一期、某个口径下的一个数：自动采集的按天（股价、利率、水位），公司披露的按期（发电量、销量、新签合同额）。同一指标、同一口径、同一日期多次采集时取最后一次为“当前版本”；超出合理范围的为无效。报表计算的指标不在这里存数。出处只记一处：公司披露和历史补数关联“来源文档”，自动采集关联“原始采集记录”（只做解析与范围校验，不是财务核验）。';

COMMENT ON COLUMN vi_observation_base.obs_date IS '对应日期：精确到日：时期指标填这段时期的最后一天（2026Q2 → 2026-06-30）；时点指标填观察当天（股价、水位为交易日，期末余额为期末日）';

COMMENT ON COLUMN vi_observation_base.period IS '统计时间：时期指标写这段时期：2026Q2（第二季度）、2026H1（上半年）、2025（全年）、2026M07（7 月）；时点指标写时点所在的报告期：2026Q2＝二季度末、2026M07＝7 月末；日度数据可留空，以对应日期为准';

COMMENT ON COLUMN vi_observation_base.basis IS '口径：这一期数值覆盖的范围。时点指标只能用“时点”（某一天的值或期末余额）；时期指标用其余几种：单季、半年累计、前三季度累计、全年、年初至今累计（月度简报用）、滚动四季度（最近四个季度合计）（可选：时点、单季、半年累计、前三季度累计、全年、年初至今累计、滚动四季度）';

COMMENT ON COLUMN vi_observation_base.value IS '数值';

COMMENT ON COLUMN vi_observation_base.yoy IS '同比（小数，0.05＝5%）';

COMMENT ON COLUMN vi_observation_base.summary IS '说明：披露原文摘要、统计范围与推算过程；需要时写一句对经营的解读';

COMMENT ON COLUMN vi_observation_base.collected_at IS '采集时间';

COMMENT ON COLUMN vi_observation_base.metric_id IS '指标（关联 指标）';

COMMENT ON COLUMN vi_observation_base.doc_id IS '来源文档（关联 来源文档）';

COMMENT ON COLUMN vi_observation_base.raw_capture_id IS '原始采集记录（关联 原始采集记录）';

CREATE TRIGGER vi_observation_base_touch BEFORE UPDATE ON vi_observation_base FOR EACH ROW EXECUTE FUNCTION vi_touch_updated_at();

CREATE TABLE vi_bs_item_base (
  id bigserial PRIMARY KEY,
  category text,
  line_item text,
  name text,
  haircut double precision,
  adjustment double precision,
  basis text,
  sort integer,
  company_id bigint,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE vi_bs_item_base IS '资产负债重估：资产负债表逐科目归类与重估（全公司口径）：经营资产与经营负债＝经营资本（第一层），其余＝资产负债桥（独立资产与调整）；引用【假设依据】【财务报表】；被【三层价值·业务】【三层价值·结果】引用。一行一个报表科目或一项报表外研究调整，不分业务（负债往往是全公司共用的）。重估＝账面×(1−折价)＋调整额；资产计正，负债与索取权计负。报表科目行的账面合计＝归母股东权益（G01）。';

COMMENT ON COLUMN vi_bs_item_base.category IS '类别：经营资产、经营负债进第一层的经营资本；现金与投资、参照估值（不自己建模、按市价交易价账面计的业务或资产）、有息负债、其他索取权进资产负债桥。经营资产、现金与投资、参照估值计正，其余计负；股权口径的公司把有息负债归为经营负债（可选：经营资产、经营负债、现金与投资、参照估值、有息负债、其他索取权）';

COMMENT ON COLUMN vi_bs_item_base.line_item IS '报表科目：与「财务报表」资产负债表的科目名完全一致；留空＝报表外的研究项目';

COMMENT ON COLUMN vi_bs_item_base.name IS '项目：显示名称；留空＝报表科目';

COMMENT ON COLUMN vi_bs_item_base.haircut IS '折价：对账面打的折扣：对外投资的持有折价与处置税费；商誉不计入资产价值填 100%（小数，0.05＝5%）';

COMMENT ON COLUMN vi_bs_item_base.adjustment IS '调整额（亿元）：在“账面×(1−折价)”之上加减，与本行方向一致（负债行填正数＝负债更多）；研究项目的金额填这里';

COMMENT ON COLUMN vi_bs_item_base.basis IS '依据：为什么这样归类、调整；金额推导写清';

COMMENT ON COLUMN vi_bs_item_base.sort IS '排序';

COMMENT ON COLUMN vi_bs_item_base.company_id IS '公司（关联 公司）';

CREATE TRIGGER vi_bs_item_base_touch BEFORE UPDATE ON vi_bs_item_base FOR EACH ROW EXECUTE FUNCTION vi_touch_updated_at();

CREATE TABLE vi_epv_base (
  id bigserial PRIMARY KEY,
  sort integer,
  name text,
  section text,
  direction text,
  formula text,
  method text,
  value double precision,
  from_year integer,
  to_year integer,
  note text,
  company_id bigint,
  business_id bigint,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE vi_epv_base IS '调整后利润表：第二层：每块业务一张调整后利润表，一行一个项目，从报表利润一路算到可持续现金收益 E；引用【业务分部】【假设依据】【财务报表】；被【三层价值·业务】引用。收入 − 成本费用 ＝ 报表经营利润；± 税前调整 ＝ 调整后经营利润；− 所得税 ＝ 税后经营利润；± 税后调整（折旧摊销、维持性资本开支）；− 少数股东 ＝ E；盈利能力价值＝E÷门槛。每行的报表公式给出历年数，正常化值按取值方式算。';

COMMENT ON COLUMN vi_epv_base.sort IS '排序';

COMMENT ON COLUMN vi_epv_base.name IS '项目';

COMMENT ON COLUMN vi_epv_base.section IS '段落：收入相加、成本费用相减得报表经营利润；税前调整、税后调整按方向加减；所得税、少数股东按比率；不计入＝只作对照（如利息收入、投资收益，它们在资产负债桥里单独计价）（可选：收入、成本费用、税前调整、所得税、税后调整、少数股东、不计入）';

COMMENT ON COLUMN vi_epv_base.direction IS '方向：税前调整、税后调整用：加回还是扣除（可选：加、减）';

COMMENT ON COLUMN vi_epv_base.formula IS '报表公式：历年数从「财务报表」按公式算：科目相加减，如“营运支出”“购建固定资产 + 购建无形资产及其他资产”；同名科目在多张报表时写“现金流量表：科目”。留空＝没有历史数（研究调整）';

COMMENT ON COLUMN vi_epv_base.method IS '取值方式：正常化值怎么取：金额＝填数（亿元）；占收入比例＝比例×正常化收入；最新年度、滚动四季度＝报表公式的最近一年或最近四个季度；历史平均＝起止年份的平均金额；历史平均占收入＝起止年份占收入比例的平均×正常化收入（周期业务的正常化）；比率＝所得税、少数股东的比率（可选：金额、占收入比例、最新年度、滚动四季度、历史平均、历史平均占收入、比率）';

COMMENT ON COLUMN vi_epv_base.value IS '数值：金额（亿元）或比例、比率（小数）';

COMMENT ON COLUMN vi_epv_base.from_year IS '起始年：历史平均用';

COMMENT ON COLUMN vi_epv_base.to_year IS '结束年：历史平均用';

COMMENT ON COLUMN vi_epv_base.note IS '说明';

COMMENT ON COLUMN vi_epv_base.company_id IS '公司（关联 公司）';

COMMENT ON COLUMN vi_epv_base.business_id IS '业务（关联 业务分部）';

CREATE TRIGGER vi_epv_base_touch BEFORE UPDATE ON vi_epv_base FOR EACH ROW EXECUTE FUNCTION vi_touch_updated_at();

CREATE TABLE vi_growth_base (
  id bigserial PRIMARY KEY,
  growth double precision,
  ronic double precision,
  adv_years integer,
  note text,
  company_id bigint,
  business_id bigint,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE vi_growth_base IS '增长：第三层输入：每块业务一行，增长与新增投资回报；引用【业务分部】【假设依据】；被【三层价值·业务】引用。优势年限内每年增长 g、再投入 g÷新增投资回报率 的收益，之后增长不再创造价值；新增投资回报率等于门槛时增长一分不值。不填或增长率为 0＝含增长价值等于盈利能力价值。';

COMMENT ON COLUMN vi_growth_base.growth IS '增长率：优势期内每年的增长（小数，0.05＝5%）';

COMMENT ON COLUMN vi_growth_base.ronic IS '新增投资回报率：为增长新投入资本的税后回报；增长率不为 0 时必填（小数，0.05＝5%）';

COMMENT ON COLUMN vi_growth_base.adv_years IS '优势年限：超额回报还能持续几年，之后增长不再创造价值；留空＝永续（要求增长率低于门槛）';

COMMENT ON COLUMN vi_growth_base.note IS '说明';

COMMENT ON COLUMN vi_growth_base.company_id IS '公司（关联 公司）';

COMMENT ON COLUMN vi_growth_base.business_id IS '业务（关联 业务分部）';

CREATE TRIGGER vi_growth_base_touch BEFORE UPDATE ON vi_growth_base FOR EACH ROW EXECUTE FUNCTION vi_touch_updated_at();

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

COMMENT ON TABLE vi_issue_base IS '待办清单：做完即关的研究与工程待办：数据源、核验、模型缺口、待定的策略选择；不放对公司的判断。人工维护、做完即关的待办：数据源待接通、数值待核验、模型缺口、来源待核对，以及等你拍板的策略选择（如安全边际取哪一档）。对公司的判断（问题与结论）一律写在“核心论点”，缺的证据写在论点的“决定胜负的证据”，这里不重复；持续盯的数据在「指标」的“重点跟踪”标签（假设依据、风险关联的指标），数据能自动判断的在“质量自检”。';

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

CREATE TABLE vi_setting_base (
  id bigserial PRIMARY KEY,
  name text,
  hurdle double precision,
  note text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE vi_setting_base IS '统一设置：全部公司共用的研究参数（只有一行）；被【三层价值·结果】引用。投资回报率要求（门槛）对五家公司一视同仁：三层估值、统一估值引擎、股息贴现都用它资本化收益、判断隐含回报够不够、算最高买入价。各公司不再单独设门槛。';

COMMENT ON COLUMN vi_setting_base.name IS '设置：固定为“全局”';

COMMENT ON COLUMN vi_setting_base.hurdle IS '投资回报率要求（门槛）：自己的机会成本：低于它的回报不值得买（小数，0.05＝5%）';

COMMENT ON COLUMN vi_setting_base.note IS '说明：为什么定这个数、什么时候改';

CREATE TRIGGER vi_setting_base_touch BEFORE UPDATE ON vi_setting_base FOR EACH ROW EXECUTE FUNCTION vi_touch_updated_at();

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

COMMENT ON TABLE vi_collector_base IS '采集配置：自动采集从哪里取数、写进哪个指标；引用【指标】；被【原始采集记录】【质量自检】引用。自动采集的数据源：地址、解析器与参数、写入哪个指标。新增股票或水文站只需加一行配置。';

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

ALTER TABLE vi_event_base ADD FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE SET NULL;

CREATE INDEX ON vi_event_base (company_id);

ALTER TABLE vi_fact_base ADD FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE SET NULL;

CREATE INDEX ON vi_fact_base (company_id);

ALTER TABLE vi_fact_base ADD FOREIGN KEY (event_id) REFERENCES vi_event_base(id) ON DELETE SET NULL;

CREATE INDEX ON vi_fact_base (event_id);

ALTER TABLE vi_fact_base ADD FOREIGN KEY (source_id) REFERENCES vi_source_base(id) ON DELETE SET NULL;

CREATE INDEX ON vi_fact_base (source_id);

ALTER TABLE vi_business_base ADD FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE SET NULL;

CREATE INDEX ON vi_business_base (company_id);

ALTER TABLE vi_biz_model_base ADD FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE SET NULL;

CREATE INDEX ON vi_biz_model_base (company_id);

ALTER TABLE vi_biz_model_base ADD FOREIGN KEY (business_id) REFERENCES vi_business_base(id) ON DELETE SET NULL;

CREATE INDEX ON vi_biz_model_base (business_id);

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

ALTER TABLE vi_metric_base ADD FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE SET NULL;

CREATE INDEX ON vi_metric_base (company_id);

ALTER TABLE vi_observation_base ADD FOREIGN KEY (metric_id) REFERENCES vi_metric_base(id) ON DELETE SET NULL;

CREATE INDEX ON vi_observation_base (metric_id);

ALTER TABLE vi_observation_base ADD FOREIGN KEY (doc_id) REFERENCES vi_source_base(id) ON DELETE SET NULL;

CREATE INDEX ON vi_observation_base (doc_id);

ALTER TABLE vi_observation_base ADD FOREIGN KEY (raw_capture_id) REFERENCES vi_raw_capture_base(id) ON DELETE SET NULL;

CREATE INDEX ON vi_observation_base (raw_capture_id);

ALTER TABLE vi_bs_item_base ADD FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE SET NULL;

CREATE INDEX ON vi_bs_item_base (company_id);

ALTER TABLE vi_epv_base ADD FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE SET NULL;

CREATE INDEX ON vi_epv_base (company_id);

ALTER TABLE vi_epv_base ADD FOREIGN KEY (business_id) REFERENCES vi_business_base(id) ON DELETE SET NULL;

CREATE INDEX ON vi_epv_base (business_id);

ALTER TABLE vi_growth_base ADD FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE SET NULL;

CREATE INDEX ON vi_growth_base (company_id);

ALTER TABLE vi_growth_base ADD FOREIGN KEY (business_id) REFERENCES vi_business_base(id) ON DELETE SET NULL;

CREATE INDEX ON vi_growth_base (business_id);

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

ALTER TABLE vi_setting_base ADD CONSTRAINT vi_setting_uniq UNIQUE (name);

ALTER TABLE vi_fin_stmt_base ADD CONSTRAINT vi_fin_stmt_uniq UNIQUE (company_id, stmt, period_end, item);

ALTER TABLE vi_thesis_base ADD CONSTRAINT vi_thesis_uniq UNIQUE (company_id, code);

ALTER TABLE vi_event_base ADD CONSTRAINT vi_event_uniq UNIQUE (company_id, name);

ALTER TABLE vi_judgment_base ADD CONSTRAINT vi_judgment_uniq UNIQUE (company_id, code);

ALTER TABLE vi_business_base ADD CONSTRAINT vi_business_uniq UNIQUE (company_id, code);

ALTER TABLE vi_growth_base ADD CONSTRAINT vi_growth_uniq UNIQUE (business_id);

ALTER TABLE vi_biz_model_base ADD CONSTRAINT vi_biz_model_uniq UNIQUE NULLS NOT DISTINCT (company_id, business_id, code);

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

CREATE TABLE vi_lnk_biz_model_basis_metrics (
  biz_model_id bigint NOT NULL REFERENCES vi_biz_model_base(id) ON DELETE CASCADE,
  metric_id bigint NOT NULL REFERENCES vi_metric_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (biz_model_id, metric_id)
);

COMMENT ON TABLE vi_lnk_biz_model_basis_metrics IS '商业模式拆解 ↔ 依据指标（多对多）';

CREATE TABLE vi_lnk_value_chain_facts (
  value_chain_id bigint NOT NULL REFERENCES vi_value_chain_base(id) ON DELETE CASCADE,
  fact_id bigint NOT NULL REFERENCES vi_fact_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (value_chain_id, fact_id)
);

COMMENT ON TABLE vi_lnk_value_chain_facts IS '产业链与五力 ↔ 依据事实（多对多）';

CREATE TABLE vi_lnk_value_chain_basis_metrics (
  value_chain_id bigint NOT NULL REFERENCES vi_value_chain_base(id) ON DELETE CASCADE,
  metric_id bigint NOT NULL REFERENCES vi_metric_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (value_chain_id, metric_id)
);

COMMENT ON TABLE vi_lnk_value_chain_basis_metrics IS '产业链与五力 ↔ 依据指标（多对多）';

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

CREATE TABLE vi_lnk_moat_basis_metrics (
  moat_id bigint NOT NULL REFERENCES vi_moat_base(id) ON DELETE CASCADE,
  metric_id bigint NOT NULL REFERENCES vi_metric_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (moat_id, metric_id)
);

COMMENT ON TABLE vi_lnk_moat_basis_metrics IS '竞争壁垒 ↔ 依据指标（多对多）';

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

CREATE TABLE vi_lnk_thesis_basis_metrics (
  thesis_id bigint NOT NULL REFERENCES vi_thesis_base(id) ON DELETE CASCADE,
  metric_id bigint NOT NULL REFERENCES vi_metric_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (thesis_id, metric_id)
);

COMMENT ON TABLE vi_lnk_thesis_basis_metrics IS '核心论点 ↔ 依据指标（多对多）';

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

CREATE TABLE vi_lnk_risk_metrics (
  risk_id bigint NOT NULL REFERENCES vi_risk_base(id) ON DELETE CASCADE,
  metric_id bigint NOT NULL REFERENCES vi_metric_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (risk_id, metric_id)
);

COMMENT ON TABLE vi_lnk_risk_metrics IS '风险分析 ↔ 预警指标（多对多）';

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

CREATE TABLE vi_lnk_judgment_basis_metrics (
  judgment_id bigint NOT NULL REFERENCES vi_judgment_base(id) ON DELETE CASCADE,
  metric_id bigint NOT NULL REFERENCES vi_metric_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (judgment_id, metric_id)
);

COMMENT ON TABLE vi_lnk_judgment_basis_metrics IS '假设依据 ↔ 依据指标（多对多）';

CREATE TABLE vi_lnk_judgment_theses (
  judgment_id bigint NOT NULL REFERENCES vi_judgment_base(id) ON DELETE CASCADE,
  thesis_id bigint NOT NULL REFERENCES vi_thesis_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (judgment_id, thesis_id)
);

COMMENT ON TABLE vi_lnk_judgment_theses IS '假设依据 ↔ 相关论点（多对多）';

CREATE TABLE vi_lnk_judgment_metrics (
  judgment_id bigint NOT NULL REFERENCES vi_judgment_base(id) ON DELETE CASCADE,
  metric_id bigint NOT NULL REFERENCES vi_metric_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (judgment_id, metric_id)
);

COMMENT ON TABLE vi_lnk_judgment_metrics IS '假设依据 ↔ 跟踪指标（多对多）';

CREATE TABLE vi_lnk_bs_item_judgments (
  bs_item_id bigint NOT NULL REFERENCES vi_bs_item_base(id) ON DELETE CASCADE,
  judgment_id bigint NOT NULL REFERENCES vi_judgment_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (bs_item_id, judgment_id)
);

COMMENT ON TABLE vi_lnk_bs_item_judgments IS '资产负债重估 ↔ 假设依据（多对多）';

CREATE TABLE vi_lnk_epv_judgments (
  epv_id bigint NOT NULL REFERENCES vi_epv_base(id) ON DELETE CASCADE,
  judgment_id bigint NOT NULL REFERENCES vi_judgment_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (epv_id, judgment_id)
);

COMMENT ON TABLE vi_lnk_epv_judgments IS '调整后利润表 ↔ 假设依据（多对多）';

CREATE TABLE vi_lnk_growth_judgments (
  growth_id bigint NOT NULL REFERENCES vi_growth_base(id) ON DELETE CASCADE,
  judgment_id bigint NOT NULL REFERENCES vi_judgment_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (growth_id, judgment_id)
);

COMMENT ON TABLE vi_lnk_growth_judgments IS '增长 ↔ 假设依据（多对多）';

-- 业务身份的公司归属：商业模式拆解、调整后利润表、增长里的业务必须属于同一家公司。
CREATE OR REPLACE FUNCTION vi_business_scope_guard() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.business_id IS NOT NULL AND NOT EXISTS
     (SELECT 1 FROM vi_business_base WHERE id = NEW.business_id AND company_id = NEW.company_id) THEN
    RAISE EXCEPTION '业务必须属于当前公司';
  END IF;
  IF TG_TABLE_NAME IN ('vi_epv_base', 'vi_growth_base') AND NEW.business_id IS NULL THEN RAISE EXCEPTION '必须选业务'; END IF;
  RETURN NEW;
END $$;
-- 资产负债重估是全公司口径（不分业务）：只查类别与折价
CREATE OR REPLACE FUNCTION vi_bs_item_guard() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.category IS NULL OR NEW.category NOT IN ('经营资产', '经营负债', '现金与投资', '参照估值', '有息负债', '其他索取权') THEN
    RAISE EXCEPTION '请填写有效的类别';
  END IF;
  IF NEW.haircut IS NOT NULL AND (NEW.haircut < 0 OR NEW.haircut > 1) THEN RAISE EXCEPTION '折价必须在 0 到 1 之间'; END IF;
  RETURN NEW;
END $$;
DROP TRIGGER IF EXISTS vi_biz_model_business_scope ON vi_biz_model_base;
CREATE TRIGGER vi_biz_model_business_scope BEFORE INSERT OR UPDATE ON vi_biz_model_base
  FOR EACH ROW EXECUTE FUNCTION vi_business_scope_guard();
DROP TRIGGER IF EXISTS vi_bs_item_business_scope ON vi_bs_item_base;
DROP TRIGGER IF EXISTS vi_bs_item_check ON vi_bs_item_base;
CREATE TRIGGER vi_bs_item_check BEFORE INSERT OR UPDATE ON vi_bs_item_base
  FOR EACH ROW EXECUTE FUNCTION vi_bs_item_guard();
DROP TRIGGER IF EXISTS vi_epv_business_scope ON vi_epv_base;
CREATE TRIGGER vi_epv_business_scope BEFORE INSERT OR UPDATE ON vi_epv_base
  FOR EACH ROW EXECUTE FUNCTION vi_business_scope_guard();
DROP TRIGGER IF EXISTS vi_growth_business_scope ON vi_growth_base;
CREATE TRIGGER vi_growth_business_scope BEFORE INSERT OR UPDATE ON vi_growth_base
  FOR EACH ROW EXECUTE FUNCTION vi_business_scope_guard();

-- 业务一旦被引用，不允许改变其所属公司或删除。
CREATE OR REPLACE FUNCTION vi_business_owner_guard() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'DELETE' OR NEW.company_id IS DISTINCT FROM OLD.company_id THEN
    IF EXISTS (SELECT 1 FROM vi_biz_model_base WHERE business_id = OLD.id)
       OR EXISTS (SELECT 1 FROM vi_epv_base WHERE business_id = OLD.id)
       OR EXISTS (SELECT 1 FROM vi_growth_base WHERE business_id = OLD.id) THEN
      RAISE EXCEPTION '业务仍被商业模式或估值引用，请先处理关联记录';
    END IF;
  END IF;
  IF TG_OP = 'DELETE' THEN RETURN OLD; END IF;
  RETURN NEW;
END $$;
DROP TRIGGER IF EXISTS vi_business_owner ON vi_business_base;
CREATE TRIGGER vi_business_owner BEFORE UPDATE OR DELETE ON vi_business_base
  FOR EACH ROW EXECUTE FUNCTION vi_business_owner_guard();

-- 统一设置只有一行（“全局”），删不掉；空库建好就有默认门槛 6%
ALTER TABLE vi_setting_base DROP CONSTRAINT IF EXISTS vi_setting_single;
ALTER TABLE vi_setting_base ADD CONSTRAINT vi_setting_single CHECK (name = '全局');
INSERT INTO vi_setting_base (name, hurdle, note) VALUES ('全局', 0.06, '全部公司统一使用的投资回报率要求；在这里改，所有估值同时更新。')
ON CONFLICT (name) DO NOTHING;
CREATE OR REPLACE FUNCTION vi_setting_keep() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN RAISE EXCEPTION '统一设置不能删除：全部估值都读这里的门槛，改数值即可'; END $$;
DROP TRIGGER IF EXISTS vi_setting_keep ON vi_setting_base;
CREATE TRIGGER vi_setting_keep BEFORE DELETE ON vi_setting_base FOR EACH ROW EXECUTE FUNCTION vi_setting_keep();


ALTER TABLE vi_metric_base ADD CONSTRAINT vi_metric_source_required CHECK (nullif(btrim(source_name), '') IS NOT NULL);
CREATE INDEX IF NOT EXISTS vi_fin_stmt_item_idx ON vi_fin_stmt_base (company_id, item);
CREATE UNIQUE INDEX IF NOT EXISTS vi_metric_model_field_uniq ON vi_metric_base (company_id, model_field) WHERE model_field IS NOT NULL;
CREATE INDEX IF NOT EXISTS vi_observation_mbp_idx ON vi_observation_base (metric_id, basis, period);
CREATE INDEX IF NOT EXISTS vi_observation_mbd_idx ON vi_observation_base (metric_id, obs_date, basis);

-- 旧快照未记录币种和单位。普通金额沿用既有亿元口径；
-- 历史每股收益曾按金额缩放，须由源数值明确写入单位。
CREATE OR REPLACE FUNCTION vi_fin_stmt_fill_units() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.currency IS NULL THEN
    SELECT CASE currency WHEN '人民币' THEN 'CNY' WHEN '港元' THEN 'HKD' WHEN '美元' THEN 'USD'
                         ELSE currency END
      INTO NEW.currency FROM vi_company_base WHERE id = NEW.company_id;
  END IF;
  IF NEW.unit IS NULL AND NEW.item !~ '每股' THEN
    NEW.unit := '亿元';
  END IF;
  RETURN NEW;
END $$;

DROP TRIGGER IF EXISTS vi_fin_stmt_fill_units ON vi_fin_stmt_base;
CREATE TRIGGER vi_fin_stmt_fill_units BEFORE INSERT OR UPDATE ON vi_fin_stmt_base
FOR EACH ROW EXECUTE FUNCTION vi_fin_stmt_fill_units();


COMMIT;
