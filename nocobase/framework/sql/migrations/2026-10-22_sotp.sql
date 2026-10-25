BEGIN;

ALTER TABLE vi_model_base ADD COLUMN IF NOT EXISTS primary_method text, ADD COLUMN IF NOT EXISTS sotp_year integer,
  ADD COLUMN IF NOT EXISTS sotp_core_adj double precision, ADD COLUMN IF NOT EXISTS sotp_as_of date;
ALTER TABLE vi_scenario_base ADD COLUMN IF NOT EXISTS ronic double precision, ADD COLUMN IF NOT EXISTS sotp_multiple double precision;

COMMENT ON COLUMN vi_model_base.primary_method IS '主估值方法：驾驶舱先展示哪一种，另一种作交叉验证；留空＝股息贴现（可选：股息贴现、分部加总）';

COMMENT ON COLUMN vi_model_base.sotp_year IS '分部加总·核心盈利年份：取哪一年的预测核心盈利（通常是下一个完整年度）';

COMMENT ON COLUMN vi_model_base.sotp_core_adj IS '分部加总·核心盈利调整（亿元）：税后归母口径，如加回收购形成的无形资产摊销；股权激励不加回';

COMMENT ON COLUMN vi_model_base.sotp_as_of IS '分部加总·资产负债日：现金、负债、对外投资与股本的统一截止日';

COMMENT ON COLUMN vi_scenario_base.ronic IS '新增投资回报率：分部加总推导合理倍数用：P/E＝(1−g÷新增投资回报率)÷(r−g)（小数，0.05＝5%）';

COMMENT ON COLUMN vi_scenario_base.sotp_multiple IS '合理倍数（手填）：填了就用手填值，留空则按公式推导';

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

COMMENT ON TABLE vi_sotp_item_base IS '分部估值项：分部加总估值里核心业务以外的部分：现金、带息负债、经营所需现金、资金汇出成本、对外投资、少数股东权益。一行一项；适用情景留空＝所有情景，某个情景另有同编号的一行时以那一行为准。';

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

ALTER TABLE vi_sotp_item_base ADD FOREIGN KEY (model_id) REFERENCES vi_model_base(id) ON DELETE SET NULL;

CREATE INDEX ON vi_sotp_item_base (model_id);

ALTER TABLE vi_sotp_item_base ADD FOREIGN KEY (scenario_id) REFERENCES vi_scenario_base(id) ON DELETE SET NULL;

CREATE INDEX ON vi_sotp_item_base (scenario_id);

CREATE TABLE vi_lnk_sotp_item_facts (
  sotp_item_id bigint NOT NULL REFERENCES vi_sotp_item_base(id) ON DELETE CASCADE,
  fact_id bigint NOT NULL REFERENCES vi_fact_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (sotp_item_id, fact_id)
);

COMMENT ON TABLE vi_lnk_sotp_item_facts IS '分部估值项 ↔ 依据事实（多对多）';

COMMIT;
