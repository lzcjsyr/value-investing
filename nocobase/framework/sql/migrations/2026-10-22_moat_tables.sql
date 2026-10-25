BEGIN;

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

COMMENT ON TABLE vi_biz_model_base IS '商业模式：公司卖什么、卖给谁、为什么能卖、为什么能赚钱、为什么现金能留下来。一行一个要素，第一行写盈利公式。';

COMMENT ON COLUMN vi_biz_model_base.code IS '编号：如 B1';

COMMENT ON COLUMN vi_biz_model_base.element IS '要素（可选：盈利公式、产品与价值主张、客户与使用场景、渠道与获客、收入结构、成本结构、单位经济、现金循环与资本需求、关键资源与合作）';

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

COMMENT ON TABLE vi_value_chain_base IS '产业链与五力：上下游各环节是谁、拿走多少利润、对公司的议价力强弱；每行同时标注属于波特五力中的哪一种力量。';

COMMENT ON COLUMN vi_value_chain_base.code IS '编号：如 V1';

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

COMMENT ON TABLE vi_competitor_base IS '竞争对手：直接对手、替代品、潜在进入者与海外对标。关键数字写明截至日期；第三方估算在来源里注明。';

COMMENT ON COLUMN vi_competitor_base.name IS '对手';

COMMENT ON COLUMN vi_competitor_base.ticker IS '证券代码：未上市留空';

COMMENT ON COLUMN vi_competitor_base.relation IS '关系（可选：直接竞争、替代品、潜在进入者、海外对标、上游、下游与渠道）';

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

COMMENT ON TABLE vi_moat_base IS '竞争壁垒：每一项候选壁垒：机制、财务体现、证据、反证、复制难度；看起来像壁垒其实不是的（伪壁垒）也要列出。可设自动检查，读取历史财务。';

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

COMMENT ON COLUMN vi_moat_base.check_metric IS '自动检查·指标：从历史财务（年度）取值；留空表示不做自动检查（可选：业务量、单价、营业收入、归母净利润、派息率、财务费用、业务量同比、单价同比、营业收入同比、财务费用同比、毛利率、ROE、经营现金流÷归母净利润、资本开支÷经营现金流、净负债、净负债÷EBITDA）';

COMMENT ON COLUMN vi_moat_base.check_op IS '自动检查·条件（可选：<、<=、>、>=）';

COMMENT ON COLUMN vi_moat_base.check_threshold IS '自动检查·阈值：比率类填小数：-0.03 表示 -3%';

COMMENT ON COLUMN vi_moat_base.check_years IS '自动检查·连续年数：最近连续几年都满足条件才算触发';

COMMENT ON COLUMN vi_moat_base.company_id IS '公司（关联 公司）';

CREATE TRIGGER vi_moat_base_touch BEFORE UPDATE ON vi_moat_base FOR EACH ROW EXECUTE FUNCTION vi_touch_updated_at();

CREATE TABLE vi_debate_base (
  id bigserial PRIMARY KEY,
  code text,
  motion text,
  bull_case text,
  bear_case text,
  bull_rebuttal text,
  bear_rebuttal text,
  winner text,
  verdict text,
  confidence text,
  decisive_evidence text,
  mind_changer text,
  model_impact text,
  external_view text,
  debated_on date,
  company_id bigint,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE vi_debate_base IS '多空辩论：把关键壁垒、论点或判断放上辩论台：正方立论、反方立论、互相反驳，最后裁决，并写清什么情况会改判、对模型有什么影响。';

COMMENT ON COLUMN vi_debate_base.code IS '编号：如 D1';

COMMENT ON COLUMN vi_debate_base.motion IS '辩题';

COMMENT ON COLUMN vi_debate_base.bull_case IS '正方立论';

COMMENT ON COLUMN vi_debate_base.bear_case IS '反方立论';

COMMENT ON COLUMN vi_debate_base.bull_rebuttal IS '正方反驳';

COMMENT ON COLUMN vi_debate_base.bear_rebuttal IS '反方反驳';

COMMENT ON COLUMN vi_debate_base.winner IS '裁决（可选：正方占优、反方占优、势均力敌、证据不足）';

COMMENT ON COLUMN vi_debate_base.verdict IS '裁决理由';

COMMENT ON COLUMN vi_debate_base.confidence IS '把握（可选：高、中、低）';

COMMENT ON COLUMN vi_debate_base.decisive_evidence IS '决定胜负的证据：下一步要看哪些数据';

COMMENT ON COLUMN vi_debate_base.mind_changer IS '改判条件';

COMMENT ON COLUMN vi_debate_base.model_impact IS '对模型的影响';

COMMENT ON COLUMN vi_debate_base.external_view IS '外部观点：岗底斯观点 PK、卖方与外资的正反观点摘要';

COMMENT ON COLUMN vi_debate_base.debated_on IS '辩论日期';

COMMENT ON COLUMN vi_debate_base.company_id IS '公司（关联 公司）';

CREATE TRIGGER vi_debate_base_touch BEFORE UPDATE ON vi_debate_base FOR EACH ROW EXECUTE FUNCTION vi_touch_updated_at();

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

COMMENT ON TABLE vi_fit_score_base IS '价值投资适配度：长坡、厚雪、慢变、护城河、再投资、财务质量、治理配置、可估值性，各 0—5 分。总分 32—40 适合复利框架，22—31 可研究，21 以下通常不符合价值投资标准。';

COMMENT ON COLUMN vi_fit_score_base.dimension IS '维度（可选：长坡、厚雪、慢变、护城河、再投资、财务质量、治理配置、可估值性）';

COMMENT ON COLUMN vi_fit_score_base.score IS '评分（0—5）';

COMMENT ON COLUMN vi_fit_score_base.rationale IS '理由与证据';

COMMENT ON COLUMN vi_fit_score_base.counter IS '反证';

COMMENT ON COLUMN vi_fit_score_base.sort IS '排序';

COMMENT ON COLUMN vi_fit_score_base.company_id IS '公司（关联 公司）';

CREATE TRIGGER vi_fit_score_base_touch BEFORE UPDATE ON vi_fit_score_base FOR EACH ROW EXECUTE FUNCTION vi_touch_updated_at();

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

ALTER TABLE vi_debate_base ADD FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE SET NULL;

CREATE INDEX ON vi_debate_base (company_id);

ALTER TABLE vi_fit_score_base ADD FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE SET NULL;

CREATE INDEX ON vi_fit_score_base (company_id);

ALTER TABLE vi_biz_model_base ADD CONSTRAINT vi_biz_model_uniq UNIQUE (company_id, code);

ALTER TABLE vi_value_chain_base ADD CONSTRAINT vi_value_chain_uniq UNIQUE (company_id, code);

ALTER TABLE vi_competitor_base ADD CONSTRAINT vi_competitor_uniq UNIQUE (company_id, name);

ALTER TABLE vi_moat_base ADD CONSTRAINT vi_moat_uniq UNIQUE (company_id, code);

ALTER TABLE vi_debate_base ADD CONSTRAINT vi_debate_uniq UNIQUE (company_id, code);

ALTER TABLE vi_fit_score_base ADD CONSTRAINT vi_fit_score_uniq UNIQUE (company_id, dimension);

CREATE TABLE vi_lnk_biz_model_facts (
  biz_model_id bigint NOT NULL REFERENCES vi_biz_model_base(id) ON DELETE CASCADE,
  fact_id bigint NOT NULL REFERENCES vi_fact_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (biz_model_id, fact_id)
);

COMMENT ON TABLE vi_lnk_biz_model_facts IS '商业模式 ↔ 依据事实（多对多）';

CREATE TABLE vi_lnk_value_chain_facts (
  value_chain_id bigint NOT NULL REFERENCES vi_value_chain_base(id) ON DELETE CASCADE,
  fact_id bigint NOT NULL REFERENCES vi_fact_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (value_chain_id, fact_id)
);

COMMENT ON TABLE vi_lnk_value_chain_facts IS '产业链与五力 ↔ 依据事实（多对多）';

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

CREATE TABLE vi_lnk_moat_competitors (
  moat_id bigint NOT NULL REFERENCES vi_moat_base(id) ON DELETE CASCADE,
  competitor_id bigint NOT NULL REFERENCES vi_competitor_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (moat_id, competitor_id)
);

COMMENT ON TABLE vi_lnk_moat_competitors IS '竞争壁垒 ↔ 相关对手（多对多）';

CREATE TABLE vi_lnk_debate_facts (
  debate_id bigint NOT NULL REFERENCES vi_debate_base(id) ON DELETE CASCADE,
  fact_id bigint NOT NULL REFERENCES vi_fact_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (debate_id, fact_id)
);

COMMENT ON TABLE vi_lnk_debate_facts IS '多空辩论 ↔ 依据事实（多对多）';

CREATE TABLE vi_lnk_debate_moats (
  debate_id bigint NOT NULL REFERENCES vi_debate_base(id) ON DELETE CASCADE,
  moat_id bigint NOT NULL REFERENCES vi_moat_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (debate_id, moat_id)
);

COMMENT ON TABLE vi_lnk_debate_moats IS '多空辩论 ↔ 相关壁垒（多对多）';

CREATE TABLE vi_lnk_debate_theses (
  debate_id bigint NOT NULL REFERENCES vi_debate_base(id) ON DELETE CASCADE,
  thesis_id bigint NOT NULL REFERENCES vi_thesis_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (debate_id, thesis_id)
);

COMMENT ON TABLE vi_lnk_debate_theses IS '多空辩论 ↔ 相关论点（多对多）';

CREATE TABLE vi_lnk_debate_judgments (
  debate_id bigint NOT NULL REFERENCES vi_debate_base(id) ON DELETE CASCADE,
  judgment_id bigint NOT NULL REFERENCES vi_judgment_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (debate_id, judgment_id)
);

COMMENT ON TABLE vi_lnk_debate_judgments IS '多空辩论 ↔ 相关判断（多对多）';

CREATE TABLE vi_lnk_fit_score_debates (
  fit_score_id bigint NOT NULL REFERENCES vi_fit_score_base(id) ON DELETE CASCADE,
  debate_id bigint NOT NULL REFERENCES vi_debate_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (fit_score_id, debate_id)
);

COMMENT ON TABLE vi_lnk_fit_score_debates IS '价值投资适配度 ↔ 相关辩论（多对多）';

COMMIT;
