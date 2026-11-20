-- 业务身份的公司归属：商业模式拆解、调整后利润表、增长里的业务必须属于同一家公司。
CREATE OR REPLACE FUNCTION vi_business_scope_guard() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.business_id IS NOT NULL AND NOT EXISTS
     (SELECT 1 FROM vi_business_base WHERE id = NEW.business_id AND company_id = NEW.company_id) THEN
    RAISE EXCEPTION '业务必须属于当前公司';
  END IF;
  IF TG_TABLE_NAME IN ('vi_epv_base', 'vi_growth_base') AND NEW.business_id IS NULL THEN RAISE EXCEPTION '必须选业务'; END IF;
  RETURN NEW;
END $$;
-- 资产负债重估是全公司口径（不分业务）：只查类别与折价
CREATE OR REPLACE FUNCTION vi_bs_item_guard() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.category IS NULL OR NEW.category NOT IN ('经营资产', '经营负债', '现金与投资', '参照估值', '有息负债', '其他索取权') THEN
    RAISE EXCEPTION '请填写有效的类别';
  END IF;
  IF NEW.haircut IS NOT NULL AND (NEW.haircut < 0 OR NEW.haircut > 1) THEN RAISE EXCEPTION '折价必须在 0 到 1 之间'; END IF;
  RETURN NEW;
END $$;
DROP TRIGGER IF EXISTS vi_biz_model_business_scope ON vi_biz_model_base;
CREATE TRIGGER vi_biz_model_business_scope BEFORE INSERT OR UPDATE ON vi_biz_model_base
  FOR EACH ROW EXECUTE FUNCTION vi_business_scope_guard();
DROP TRIGGER IF EXISTS vi_bs_item_business_scope ON vi_bs_item_base;
DROP TRIGGER IF EXISTS vi_bs_item_check ON vi_bs_item_base;
CREATE TRIGGER vi_bs_item_check BEFORE INSERT OR UPDATE ON vi_bs_item_base
  FOR EACH ROW EXECUTE FUNCTION vi_bs_item_guard();
DROP TRIGGER IF EXISTS vi_epv_business_scope ON vi_epv_base;
CREATE TRIGGER vi_epv_business_scope BEFORE INSERT OR UPDATE ON vi_epv_base
  FOR EACH ROW EXECUTE FUNCTION vi_business_scope_guard();
DROP TRIGGER IF EXISTS vi_growth_business_scope ON vi_growth_base;
CREATE TRIGGER vi_growth_business_scope BEFORE INSERT OR UPDATE ON vi_growth_base
  FOR EACH ROW EXECUTE FUNCTION vi_business_scope_guard();

-- 业务一旦被引用，不允许改变其所属公司或删除。
CREATE OR REPLACE FUNCTION vi_business_owner_guard() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'DELETE' OR NEW.company_id IS DISTINCT FROM OLD.company_id THEN
    IF EXISTS (SELECT 1 FROM vi_biz_model_base WHERE business_id = OLD.id)
       OR EXISTS (SELECT 1 FROM vi_epv_base WHERE business_id = OLD.id)
       OR EXISTS (SELECT 1 FROM vi_growth_base WHERE business_id = OLD.id) THEN
      RAISE EXCEPTION '业务仍被商业模式或估值引用，请先处理关联记录';
    END IF;
  END IF;
  IF TG_OP = 'DELETE' THEN RETURN OLD; END IF;
  RETURN NEW;
END $$;
DROP TRIGGER IF EXISTS vi_business_owner ON vi_business_base;
CREATE TRIGGER vi_business_owner BEFORE UPDATE OR DELETE ON vi_business_base
  FOR EACH ROW EXECUTE FUNCTION vi_business_owner_guard();

-- 统一设置只有一行（“全局”），删不掉；空库建好就有默认门槛 6%
ALTER TABLE vi_setting_base DROP CONSTRAINT IF EXISTS vi_setting_single;
ALTER TABLE vi_setting_base ADD CONSTRAINT vi_setting_single CHECK (name = '全局');
INSERT INTO vi_setting_base (name, hurdle, note) VALUES ('全局', 0.06, '全部公司统一使用的投资回报率要求；在这里改，所有估值同时更新。')
ON CONFLICT (name) DO NOTHING;
CREATE OR REPLACE FUNCTION vi_setting_keep() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN RAISE EXCEPTION '统一设置不能删除：全部估值都读这里的门槛，改数值即可'; END $$;
DROP TRIGGER IF EXISTS vi_setting_keep ON vi_setting_base;
CREATE TRIGGER vi_setting_keep BEFORE DELETE ON vi_setting_base FOR EACH ROW EXECUTE FUNCTION vi_setting_keep();
