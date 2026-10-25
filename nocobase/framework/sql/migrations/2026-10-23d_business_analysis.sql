-- 2026-10-23（第四次）：「研究」与「商业与壁垒」合并为「商业模式分析」；多空辩论并入论点（论点与辩论）。
-- 在线库执行顺序：先在 NocoBase 里删掉旧页面、vi_debate 集合和指向辩论关联表的字段（见 README），
-- 然后 ./psql.sh -f framework/sql/migrations/2026-10-23d_business_analysis.sql，再重跑 02、03，register.py，重启 app。
-- 空库重建不需要它：01_schema.sql 已是新结构。
BEGIN;

-- 1. 论点：列改名（与辩论统一口径），补辩论字段
ALTER TABLE vi_thesis_base RENAME COLUMN mechanism TO bull_case;
ALTER TABLE vi_thesis_base RENAME COLUMN counter TO bear_case;
ALTER TABLE vi_thesis_base RENAME COLUMN current_view TO verdict;
ALTER TABLE vi_thesis_base RENAME COLUMN evidence_needed TO decisive_evidence;
ALTER TABLE vi_thesis_base RENAME COLUMN falsification TO mind_changer;
ALTER TABLE vi_thesis_base ADD COLUMN confidence text, ADD COLUMN bull_rebuttal text, ADD COLUMN bear_rebuttal text,
  ADD COLUMN model_impact text, ADD COLUMN external_view text, ADD COLUMN debated_on date;
UPDATE vi_thesis_base SET category = '壁垒' WHERE category = '资产';

-- 2. 新关联表：论点↔事实、适配度↔论点、产业链↔竞争对手
CREATE TABLE IF NOT EXISTS vi_lnk_thesis_facts (
  thesis_id bigint NOT NULL REFERENCES vi_thesis_base(id) ON DELETE CASCADE,
  fact_id bigint NOT NULL REFERENCES vi_fact_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (thesis_id, fact_id)
);
COMMENT ON TABLE vi_lnk_thesis_facts IS '论点与辩论 ↔ 依据事实（多对多）';
CREATE TABLE IF NOT EXISTS vi_lnk_fit_score_theses (
  fit_score_id bigint NOT NULL REFERENCES vi_fit_score_base(id) ON DELETE CASCADE,
  thesis_id bigint NOT NULL REFERENCES vi_thesis_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (fit_score_id, thesis_id)
);
COMMENT ON TABLE vi_lnk_fit_score_theses IS '价值投资适配度 ↔ 相关论点（多对多）';
CREATE TABLE IF NOT EXISTS vi_lnk_value_chain_competitors (
  value_chain_id bigint NOT NULL REFERENCES vi_value_chain_base(id) ON DELETE CASCADE,
  competitor_id bigint NOT NULL REFERENCES vi_competitor_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (value_chain_id, competitor_id)
);
COMMENT ON TABLE vi_lnk_value_chain_competitors IS '产业链与五力 ↔ 相关对手（多对多）';

-- 3. 多空辩论逐条并入论点（编号沿用 D1…，裁决：正方占优→成立，反方占优→存疑，势均力敌、证据不足→观察）
INSERT INTO vi_thesis_base (company_id, code, title, category, status, confidence, bull_case, bear_case, bull_rebuttal, bear_rebuttal,
                            verdict, decisive_evidence, mind_changer, model_impact, external_view, debated_on)
SELECT d.company_id, d.code, d.motion,
       coalesce((SELECT '壁垒' FROM vi_lnk_debate_moats l JOIN vi_moat_base m ON m.id = l.moat_id
                  WHERE l.debate_id = d.id AND m.verdict IS DISTINCT FROM '伪壁垒' LIMIT 1),
                (SELECT t.category FROM vi_lnk_debate_theses l JOIN vi_thesis_base t ON t.id = l.thesis_id
                  WHERE l.debate_id = d.id ORDER BY t.id LIMIT 1)),
       CASE d.winner WHEN '正方占优' THEN '成立' WHEN '反方占优' THEN '存疑' ELSE '观察' END,
       d.confidence, d.bull_case, d.bear_case, d.bull_rebuttal, d.bear_rebuttal,
       d.verdict, d.decisive_evidence, d.mind_changer, d.model_impact, d.external_view, d.debated_on
FROM vi_debate_base d ORDER BY d.id;

CREATE TEMP TABLE d2t ON COMMIT DROP AS
SELECT d.id AS debate_id, t.id AS thesis_id FROM vi_debate_base d JOIN vi_thesis_base t ON t.company_id = d.company_id AND t.code = d.code;

INSERT INTO vi_lnk_thesis_facts (thesis_id, fact_id, "createdAt", "updatedAt")
SELECT x.thesis_id, l.fact_id, l."createdAt", l."updatedAt" FROM vi_lnk_debate_facts l JOIN d2t x USING (debate_id) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_moat_theses (moat_id, thesis_id, "createdAt", "updatedAt")
SELECT l.moat_id, x.thesis_id, l."createdAt", l."updatedAt" FROM vi_lnk_debate_moats l JOIN d2t x USING (debate_id) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_judgment_theses (judgment_id, thesis_id, "createdAt", "updatedAt")
SELECT l.judgment_id, x.thesis_id, l."createdAt", l."updatedAt" FROM vi_lnk_debate_judgments l JOIN d2t x USING (debate_id) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_fit_score_theses (fit_score_id, thesis_id, "createdAt", "updatedAt")
SELECT l.fit_score_id, x.thesis_id, l."createdAt", l."updatedAt" FROM vi_lnk_fit_score_debates l JOIN d2t x USING (debate_id) ON CONFLICT DO NOTHING;
-- 辩论“相关论点”（同一话题的旧论点）不再需要关联：逐家公司重构时把两条合并成一条

-- 4. 删除多空辩论（视图、触发器函数、关联表、输入表）；vi_moat_calc、vi_check 随 CASCADE 删除，由 02_calc.sql 重建
DROP VIEW IF EXISTS vi_debate CASCADE;
DROP FUNCTION IF EXISTS vi_debate_dml();
DROP TABLE IF EXISTS vi_lnk_debate_facts, vi_lnk_debate_moats, vi_lnk_debate_judgments, vi_lnk_debate_theses, vi_lnk_fit_score_debates CASCADE;
DROP TABLE IF EXISTS vi_debate_base CASCADE;

-- 5. 表与字段注释（与 gen_sql.py 生成的 01_schema.sql 一致）
COMMENT ON TABLE vi_thesis_base IS '论点与辩论：决定价值的几个关键判断，每条都正反论证：正方立论、反方立论、互相反驳，再给裁决、把握、改判条件和对模型的影响。壁垒能否持续的论点关联到竞争壁垒（伪壁垒以外每项壁垒至少一条辩论过的论点）；能量化的改判条件设自动检查，读取历史财务。';
COMMENT ON TABLE vi_judgment_base IS '参数判断：事实 → 判断 → 参数：解释事实和论点如何影响哪个估值参数、改参数的门槛、什么情况下不改。论证本身写在论点与辩论里，这里只写到参数的传导。';
COMMENT ON TABLE vi_fact_base IS '事实卡：从来源文档里摘出的一条可核验事实（尽量带数值、期间和单位）。事实只记录“是什么”，解释放到论点或参数判断里。';
COMMENT ON TABLE vi_biz_model_base IS '商业模式：公司卖什么、卖给谁、为什么能卖、为什么能赚钱、为什么现金能留下来。一行一个要素，第一行写盈利公式。只写事实与机制；有争议、决定价值的判断写在论点与辩论里。';
COMMENT ON TABLE vi_value_chain_base IS '产业链与五力：上下游各环节是谁、拿走多少利润、对公司的议价力强弱；每行同时标注属于波特五力中的哪一种力量。同业、替代品、潜在进入者这几行只评估力量强弱，具体对手的规模与打法写在竞争对手表，并在“相关对手”里关联。';
COMMENT ON TABLE vi_moat_base IS '竞争壁垒：每一项候选壁垒：机制、财务体现、证据、反证、复制难度；看起来像壁垒其实不是的（伪壁垒）也要列出。壁垒能不能持续，在论点与辩论里正反论证并关联到这里。可设自动检查，读取历史财务。';
COMMENT ON TABLE vi_fit_score_base IS '价值投资适配度：长坡、厚雪、慢变、护城河、再投资、财务质量、治理配置、可估值性，各 0—5 分。总分 32—40 适合复利框架，22—31 可研究，21 以下通常不符合价值投资标准。';
COMMENT ON COLUMN vi_thesis_base.code IS '编号：如 T1';
COMMENT ON COLUMN vi_thesis_base.title IS '论点：写成一个可以被证伪的判断';
COMMENT ON COLUMN vi_thesis_base.category IS '类别（可选：壁垒、经营、财务、治理、风险）';
COMMENT ON COLUMN vi_thesis_base.status IS '裁决：成立＝正方占优；观察＝势均力敌或证据不足；存疑＝反方占优；证伪＝改判条件已经出现（可选：成立、观察、存疑、证伪）';
COMMENT ON COLUMN vi_thesis_base.confidence IS '把握（可选：高、中、低）';
COMMENT ON COLUMN vi_thesis_base.bull_case IS '正方立论：为什么成立、怎么影响现金流，附证据';
COMMENT ON COLUMN vi_thesis_base.bear_case IS '反方立论：反证与边界：什么情况下不成立或被高估';
COMMENT ON COLUMN vi_thesis_base.bull_rebuttal IS '正方反驳';
COMMENT ON COLUMN vi_thesis_base.bear_rebuttal IS '反方反驳';
COMMENT ON COLUMN vi_thesis_base.verdict IS '裁决理由';
COMMENT ON COLUMN vi_thesis_base.decisive_evidence IS '决定胜负的证据：下一步要看哪些数据';
COMMENT ON COLUMN vi_thesis_base.mind_changer IS '改判条件：什么情况下改判；能量化的同时填下面的自动检查';
COMMENT ON COLUMN vi_thesis_base.model_impact IS '对模型的影响：对应哪条参数判断、改不改参数';
COMMENT ON COLUMN vi_thesis_base.external_view IS '外部观点：卖方、外资、岗底斯观点 PK 的正反观点摘要；裁决仍由自己负责';
COMMENT ON COLUMN vi_thesis_base.debated_on IS '辩论日期：做完正反立论与互相反驳后填写；竞争壁垒的“已辩论的论点数”按它统计';
COMMENT ON COLUMN vi_thesis_base.check_metric IS '自动检查·指标：从历史财务（年度）取值；留空表示不做自动检查（可选：业务量、单价、营业收入、归母净利润、派息率、财务费用、业务量同比、单价同比、营业收入同比、财务费用同比、毛利率、ROE、经营现金流÷归母净利润、资本开支÷经营现金流、净负债、净负债÷EBITDA）';
COMMENT ON COLUMN vi_thesis_base.check_op IS '自动检查·条件（可选：<、<=、>、>=）';
COMMENT ON COLUMN vi_thesis_base.check_threshold IS '自动检查·阈值：比率类填小数：-0.03 表示 -3%';
COMMENT ON COLUMN vi_thesis_base.check_years IS '自动检查·连续年数：最近连续几年都满足条件才算触发';
COMMENT ON COLUMN vi_thesis_base.company_id IS '公司（关联 公司）';
COMMENT ON COLUMN vi_biz_model_base.element IS '要素（可选：盈利公式、产品与价值主张、客户与使用场景、渠道与获客、收入结构、成本结构、单位经济、增长与周期驱动、现金循环与资本需求、关键资源与合作）';

-- 6. 竞争对手“关系”加一个选项：同业对标（同行业、不直接抢客户的对照公司）
COMMENT ON COLUMN vi_competitor_base.relation IS '关系：同业对标＝同行业、不直接抢客户的对照公司（如不同流域的水电）（可选：直接竞争、同业对标、替代品、潜在进入者、海外对标、上游、下游与渠道）';

COMMIT;
