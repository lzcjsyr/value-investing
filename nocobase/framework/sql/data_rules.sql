ALTER TABLE vi_metric_base ADD CONSTRAINT vi_metric_source_required CHECK (nullif(btrim(source_name), '') IS NOT NULL);
ALTER TABLE vi_sotp_item_base ADD CONSTRAINT vi_sotp_item_one_amount CHECK (metric_id IS NULL OR amount IS NULL);
CREATE INDEX IF NOT EXISTS vi_fin_stmt_item_idx ON vi_fin_stmt_base (company_id, item);
CREATE UNIQUE INDEX IF NOT EXISTS vi_metric_model_field_uniq ON vi_metric_base (company_id, model_field) WHERE model_field IS NOT NULL;
CREATE INDEX IF NOT EXISTS vi_observation_mbp_idx ON vi_observation_base (metric_id, basis, period);
CREATE INDEX IF NOT EXISTS vi_observation_mbd_idx ON vi_observation_base (metric_id, obs_date, basis);
