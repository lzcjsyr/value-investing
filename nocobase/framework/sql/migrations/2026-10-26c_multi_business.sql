BEGIN;
CREATE TABLE vi_business_base (
  id bigserial PRIMARY KEY, code text, name text, boundary text,
  cost_allocation text, asset_boundary text, sort integer,
  company_id bigint REFERENCES vi_company_base(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT vi_business_uniq UNIQUE (company_id, code)
);
CREATE INDEX ON vi_business_base(company_id);
CREATE TRIGGER vi_business_base_touch BEFORE UPDATE ON vi_business_base
  FOR EACH ROW EXECUTE FUNCTION vi_touch_updated_at();
ALTER TABLE vi_biz_model_base ADD COLUMN business_id bigint REFERENCES vi_business_base(id) ON DELETE SET NULL;
ALTER TABLE vi_sotp_segment_base ADD COLUMN business_id bigint REFERENCES vi_business_base(id) ON DELETE SET NULL;
ALTER TABLE vi_sotp_item_base ADD COLUMN business_id bigint REFERENCES vi_business_base(id) ON DELETE SET NULL;
ALTER TABLE vi_sotp_item_base ADD COLUMN treatment text DEFAULT '单独计价';
ALTER TABLE vi_sotp_item_base ADD COLUMN valuation_method text;
ALTER TABLE vi_sotp_item_base ADD COLUMN boundary text;
CREATE INDEX ON vi_biz_model_base(business_id);
CREATE INDEX ON vi_sotp_segment_base(business_id);
CREATE INDEX ON vi_sotp_item_base(business_id);
ALTER TABLE vi_biz_model_base DROP CONSTRAINT vi_biz_model_uniq;
ALTER TABLE vi_biz_model_base ADD CONSTRAINT vi_biz_model_uniq
  UNIQUE NULLS NOT DISTINCT (company_id, business_id, code);
COMMIT;
