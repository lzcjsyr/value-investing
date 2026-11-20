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
