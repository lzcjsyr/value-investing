-- 统一估值引擎（2026-11-08）：业务表加类型、资本口径与收入驱动；新表 估值假设。
-- 在线库执行顺序：本文件 → 02_calc.sql → 03_ui.sql。空库重建用 gen_sql.py 生成的 01_schema.sql（已含这些列和表）。
BEGIN;
ALTER TABLE vi_business_base
  ADD COLUMN IF NOT EXISTS kind text DEFAULT '经营',
  ADD COLUMN IF NOT EXISTS capital_basis text DEFAULT '企业',
  ADD COLUMN IF NOT EXISTS driver1_label text, ADD COLUMN IF NOT EXISTS driver1_unit text,
  ADD COLUMN IF NOT EXISTS driver2_label text, ADD COLUMN IF NOT EXISTS driver2_unit text,
  ADD COLUMN IF NOT EXISTS driver3_label text, ADD COLUMN IF NOT EXISTS driver3_unit text,
  ADD COLUMN IF NOT EXISTS driver_scale double precision;
UPDATE vi_business_base SET kind = coalesce(kind, '经营'), capital_basis = coalesce(capital_basis, '企业');
COMMENT ON COLUMN vi_business_base.kind IS '类型：总部＝不属于任何一块业务的公司层面费用；每家公司最多一行（可选：经营、总部）';
COMMENT ON COLUMN vi_business_base.capital_basis IS '资本口径：企业＝投入资本与经营利润（利息前）；股权＝净资产与净利润（银行、保险）（可选：企业、股权）';
COMMENT ON COLUMN vi_business_base.driver_scale IS '收入换算系数：驱动乘积换算成亿元的系数；单位已对齐时为 1';

CREATE TABLE IF NOT EXISTS vi_assumption_base (
  id bigserial PRIMARY KEY,
  parameter text,
  from_year integer,
  to_year integer,
  value double precision,
  note text,
  model_id bigint REFERENCES vi_model_base(id) ON DELETE SET NULL,
  business_id bigint REFERENCES vi_business_base(id) ON DELETE SET NULL,
  scenario_id bigint REFERENCES vi_scenario_base(id) ON DELETE SET NULL,
  judgment_id bigint REFERENCES vi_judgment_base(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS vi_assumption_base_model_idx ON vi_assumption_base (model_id, business_id, parameter);
COMMENT ON TABLE vi_assumption_base IS '估值假设：统一估值引擎的全部输入，一行一个数，每个数挂一条假设依据';
DROP TRIGGER IF EXISTS vi_assumption_base_touch ON vi_assumption_base;
CREATE TRIGGER vi_assumption_base_touch BEFORE UPDATE ON vi_assumption_base FOR EACH ROW EXECUTE FUNCTION vi_touch_updated_at();
COMMIT;
