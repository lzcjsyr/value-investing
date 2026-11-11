-- 统一估值引擎：收入与成本项目（2026-11-09）。业务＝能单独定价的经济单元；业务内的收入线、成本线写在这里。
-- 在线库执行顺序：本文件 → 02_calc.sql → 03_ui.sql。
BEGIN;
CREATE TABLE IF NOT EXISTS vi_line_base (
  id bigserial PRIMARY KEY,
  code text, name text, kind text, basis text,
  driver1_label text, driver1_unit text, driver2_label text, driver2_unit text, driver3_label text, driver3_unit text,
  driver_scale double precision, note text, sort integer,
  business_id bigint REFERENCES vi_business_base(id) ON DELETE SET NULL,
  base_line_id bigint REFERENCES vi_line_base(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS vi_line_base_business_idx ON vi_line_base (business_id);
ALTER TABLE vi_line_base DROP CONSTRAINT IF EXISTS vi_line_uniq;
ALTER TABLE vi_line_base ADD CONSTRAINT vi_line_uniq UNIQUE (business_id, code);
COMMENT ON TABLE vi_line_base IS '收入与成本项目：一块业务里的收入线和成本线';
DROP TRIGGER IF EXISTS vi_line_base_touch ON vi_line_base;
CREATE TRIGGER vi_line_base_touch BEFORE UPDATE ON vi_line_base FOR EACH ROW EXECUTE FUNCTION vi_touch_updated_at();
ALTER TABLE vi_assumption_base ADD COLUMN IF NOT EXISTS line_id bigint REFERENCES vi_line_base(id) ON DELETE SET NULL;
COMMIT;
