-- 2026-10-23：经营分部估值（sotp_segment）与情景概率。在线库执行一次；空库重建用 01_schema.sql。

BEGIN;

ALTER TABLE vi_scenario_base ADD COLUMN IF NOT EXISTS probability double precision;

COMMENT ON COLUMN vi_scenario_base.probability IS '情景概率：分部加总的概率加权价值用；同一模型各情景合计应为 100%，留空＝不加权（小数，0.05＝5%）';

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
  basis text,
  model_id bigint,
  scenario_id bigint,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE vi_sotp_segment_base IS '经营分部估值：分部加总里的经营业务，按发展阶段各用一种方法：成熟或周期业务用“盈利×倍数”（正常化盈利）；成长业务用“稳态折现”（稳态年盈利×退出倍数折回今天，加上到稳态前的期间现金流）；投入期业务用“承诺投入”（只计已承诺的成本，回报不计入）。一行一个分部；适用情景留空＝所有情景，同编号可按情景另写一行。';

COMMENT ON COLUMN vi_sotp_segment_base.code IS '编号：如 S1；同一编号可按情景各写一行';

COMMENT ON COLUMN vi_sotp_segment_base.name IS '分部';

COMMENT ON COLUMN vi_sotp_segment_base.method IS '估值方法：盈利×倍数＝成熟或周期业务；稳态折现＝成长业务；承诺投入＝投入期业务（负值）（可选：盈利×倍数、稳态折现、承诺投入）';

COMMENT ON COLUMN vi_sotp_segment_base.stage IS '发展阶段：如 成熟·周期底部、成长·规模爬坡、投入期';

COMMENT ON COLUMN vi_sotp_segment_base.earn_year IS '盈利年份：盈利×倍数＝正常化盈利所在年份；稳态折现＝稳态年份。价值按“该年年初价值＝该年盈利×倍数”折回资产负债日；资产负债日之后第一个完整年度不折现';

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

COMMENT ON COLUMN vi_sotp_segment_base.basis IS '依据';

COMMENT ON COLUMN vi_sotp_segment_base.model_id IS '估值模型（关联 估值模型）';

COMMENT ON COLUMN vi_sotp_segment_base.scenario_id IS '适用情景（关联 情景）';

CREATE TRIGGER vi_sotp_segment_base_touch BEFORE UPDATE ON vi_sotp_segment_base FOR EACH ROW EXECUTE FUNCTION vi_touch_updated_at();

ALTER TABLE vi_sotp_segment_base ADD FOREIGN KEY (model_id) REFERENCES vi_model_base(id) ON DELETE SET NULL;

CREATE INDEX ON vi_sotp_segment_base (model_id);

ALTER TABLE vi_sotp_segment_base ADD FOREIGN KEY (scenario_id) REFERENCES vi_scenario_base(id) ON DELETE SET NULL;

CREATE INDEX ON vi_sotp_segment_base (scenario_id);

CREATE TABLE vi_lnk_sotp_segment_facts (
  sotp_segment_id bigint NOT NULL REFERENCES vi_sotp_segment_base(id) ON DELETE CASCADE,
  fact_id bigint NOT NULL REFERENCES vi_fact_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (sotp_segment_id, fact_id)
);

COMMENT ON TABLE vi_lnk_sotp_segment_facts IS '经营分部估值 ↔ 依据事实（多对多）';

COMMIT;

-- 一次性清理：腾讯音乐种子早先重跑时没有先删分部估值项，模型被删后留下 15 条模型为空的孤儿行（不参与任何计算）。
-- 种子脚本已改为先删本模型的分部估值项与经营分部，再删模型。
DELETE FROM vi_sotp_item_base WHERE model_id IS NULL;
