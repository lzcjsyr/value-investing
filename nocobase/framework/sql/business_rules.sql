-- 业务身份的公司归属、估值情景归属，以及避免重复计价所需的边界约束。
CREATE OR REPLACE FUNCTION vi_business_scope_guard() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE owner_id bigint; business_owner bigint;
BEGIN
  IF TG_TABLE_NAME = 'vi_biz_model_base' THEN owner_id := NEW.company_id;
  ELSE
    SELECT company_id INTO owner_id FROM vi_model_base WHERE id = NEW.model_id;
    IF NEW.scenario_id IS NOT NULL AND NOT EXISTS
       (SELECT 1 FROM vi_scenario_base WHERE id = NEW.scenario_id AND model_id = NEW.model_id) THEN
      RAISE EXCEPTION '适用情景必须属于当前估值模型';
    END IF;
  END IF;
  IF NEW.business_id IS NOT NULL THEN
    SELECT company_id INTO business_owner FROM vi_business_base WHERE id = NEW.business_id;
    IF owner_id IS NULL OR business_owner IS DISTINCT FROM owner_id THEN
      RAISE EXCEPTION '所属业务必须属于当前公司或估值模型所在公司';
    END IF;
  END IF;
  IF TG_TABLE_NAME = 'vi_sotp_item_base' THEN
    IF NEW.treatment IS NULL OR NEW.treatment NOT IN ('单独计价', '已含业务估值', '不计价') THEN
      RAISE EXCEPTION '请填写有效的计价处理';
    END IF;
    IF NEW.treatment = '已含业务估值' AND NEW.business_id IS NULL THEN
      RAISE EXCEPTION '已含业务估值的资产必须关联具体业务';
    END IF;
    IF NEW.kind IN ('固定资产', '其他非经营资产') AND
       (NEW.boundary IS NULL OR btrim(NEW.boundary) = '') THEN
      RAISE EXCEPTION '固定资产及其他非经营资产必须说明计价边界';
    END IF;
    IF NEW.haircut IS NOT NULL AND (NEW.haircut < 0 OR NEW.haircut > 1) THEN
      RAISE EXCEPTION '折价必须在 0 到 1 之间';
    END IF;
  END IF;
  RETURN NEW;
END $$;
DROP TRIGGER IF EXISTS vi_biz_model_business_scope ON vi_biz_model_base;
CREATE TRIGGER vi_biz_model_business_scope BEFORE INSERT OR UPDATE ON vi_biz_model_base
  FOR EACH ROW EXECUTE FUNCTION vi_business_scope_guard();
DROP TRIGGER IF EXISTS vi_sotp_segment_business_scope ON vi_sotp_segment_base;
CREATE TRIGGER vi_sotp_segment_business_scope BEFORE INSERT OR UPDATE ON vi_sotp_segment_base
  FOR EACH ROW EXECUTE FUNCTION vi_business_scope_guard();
DROP TRIGGER IF EXISTS vi_sotp_item_business_scope ON vi_sotp_item_base;
CREATE TRIGGER vi_sotp_item_business_scope BEFORE INSERT OR UPDATE ON vi_sotp_item_base
  FOR EACH ROW EXECUTE FUNCTION vi_business_scope_guard();
CREATE UNIQUE INDEX IF NOT EXISTS vi_sotp_segment_business_scenario_uniq
  ON vi_sotp_segment_base (model_id, business_id, scenario_id) NULLS NOT DISTINCT
  WHERE business_id IS NOT NULL;

-- 业务一旦被引用，不允许改变其所属公司或删除为集团记录。
CREATE OR REPLACE FUNCTION vi_business_owner_guard() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'DELETE' OR NEW.company_id IS DISTINCT FROM OLD.company_id THEN
    IF EXISTS (SELECT 1 FROM vi_biz_model_base WHERE business_id = OLD.id)
       OR EXISTS (SELECT 1 FROM vi_sotp_segment_base WHERE business_id = OLD.id)
       OR EXISTS (SELECT 1 FROM vi_sotp_item_base WHERE business_id = OLD.id) THEN
      RAISE EXCEPTION '业务仍被商业模式或估值引用，请先处理关联记录';
    END IF;
  END IF;
  IF TG_OP = 'DELETE' THEN RETURN OLD; END IF;
  RETURN NEW;
END $$;
DROP TRIGGER IF EXISTS vi_business_owner ON vi_business_base;
CREATE TRIGGER vi_business_owner BEFORE UPDATE OR DELETE ON vi_business_base
  FOR EACH ROW EXECUTE FUNCTION vi_business_owner_guard();
