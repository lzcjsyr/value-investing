-- 统一门槛（2026-11-11）：投资回报率要求放在「框架与后台 / 统一设置」（vi_setting，一行），全部公司、全部估值方法都读它；

-- 估值模型的“要求收益率”只显示、写入时改统一值。另加资产负债重估、估值输入的归属检查。执行顺序：本文件 → 02_calc.sql → 03_ui.sql。

BEGIN;

CREATE TABLE vi_setting_base (
  id bigserial PRIMARY KEY,
  name text,
  hurdle double precision,
  note text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE vi_setting_base IS '统一设置：全部公司共用的研究参数（只有一行）。投资回报率要求（门槛）对五家公司一视同仁：三层估值、统一估值引擎、股息贴现都用它资本化收益、判断隐含回报够不够、算最高买入价。各估值模型里的“要求收益率”只是显示这个值。';

COMMENT ON COLUMN vi_setting_base.name IS '设置：固定为“全局”';

COMMENT ON COLUMN vi_setting_base.hurdle IS '投资回报率要求（门槛）：自己的机会成本：低于它的回报不值得买（小数，0.05＝5%）';

COMMENT ON COLUMN vi_setting_base.note IS '说明：为什么定这个数、什么时候改';

CREATE TRIGGER vi_setting_base_touch BEFORE UPDATE ON vi_setting_base FOR EACH ROW EXECUTE FUNCTION vi_touch_updated_at();

ALTER TABLE vi_setting_base ADD CONSTRAINT vi_setting_uniq UNIQUE (name);

COMMENT ON COLUMN vi_model_base.required_return IS '要求收益率：全部公司共用的门槛（框架与后台 / 统一设置），这里只显示；在这里改等于改统一值。用于资本化经营收益、判断隐含回报是否达标、算最高买入价（小数，0.05＝5%）';

-- Greenwald 三层估值（2026-11-11）：资产负债重估、估值输入的业务与情景必须属于估值模型所在公司；类别、折价取值有效。
CREATE OR REPLACE FUNCTION vi_gw_guard() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE owner_id bigint;
BEGIN
  SELECT company_id INTO owner_id FROM vi_model_base WHERE id = NEW.model_id;
  IF NEW.business_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM vi_business_base WHERE id = NEW.business_id AND company_id = owner_id) THEN
    RAISE EXCEPTION '业务必须属于估值模型所在公司';
  END IF;
  IF TG_TABLE_NAME = 'vi_val_input_base' THEN
    IF NEW.business_id IS NULL OR NEW.scenario_id IS NULL THEN RAISE EXCEPTION '估值输入必须选业务和情景'; END IF;
    IF NOT EXISTS (SELECT 1 FROM vi_scenario_base WHERE id = NEW.scenario_id AND model_id = NEW.model_id) THEN
      RAISE EXCEPTION '情景必须属于当前估值模型';
    END IF;
  ELSE
    IF NEW.category IS NULL OR NEW.category NOT IN ('经营资产', '经营负债', '现金与投资', '有息负债', '其他索取权') THEN
      RAISE EXCEPTION '请填写有效的类别';
    END IF;
    IF NEW.haircut IS NOT NULL AND (NEW.haircut < 0 OR NEW.haircut > 1) THEN RAISE EXCEPTION '折价必须在 0 到 1 之间'; END IF;
  END IF;
  RETURN NEW;
END $$;
DROP TRIGGER IF EXISTS vi_bs_item_guard ON vi_bs_item_base;
CREATE TRIGGER vi_bs_item_guard BEFORE INSERT OR UPDATE ON vi_bs_item_base FOR EACH ROW EXECUTE FUNCTION vi_gw_guard();
DROP TRIGGER IF EXISTS vi_val_input_guard ON vi_val_input_base;
CREATE TRIGGER vi_val_input_guard BEFORE INSERT OR UPDATE ON vi_val_input_base FOR EACH ROW EXECUTE FUNCTION vi_gw_guard();

-- 统一设置只有一行（“全局”）；空库建好就有默认门槛 6%
ALTER TABLE vi_setting_base ADD CONSTRAINT vi_setting_single CHECK (name = '全局');
INSERT INTO vi_setting_base (name, hurdle, note) VALUES ('全局', 0.06, '全部公司统一使用的投资回报率要求；在这里改，所有估值同时更新。')
ON CONFLICT (name) DO NOTHING;

UPDATE vi_model_base SET required_return = NULL;  -- 已停用：门槛统一在 vi_setting

-- 资产负债重估的“报表科目”列名 item 与页面生成器的内部 key 冲突，改名 line_item（在线库已建表时执行）
DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'vi_bs_item_base' AND column_name = 'item') THEN
    ALTER TABLE vi_bs_item_base RENAME COLUMN item TO line_item;
  END IF;
END $$;

CREATE OR REPLACE FUNCTION vi_setting_keep() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN RAISE EXCEPTION '统一设置不能删除：全部估值都读这里的门槛，改数值即可'; END $$;
DROP TRIGGER IF EXISTS vi_setting_keep ON vi_setting_base;
CREATE TRIGGER vi_setting_keep BEFORE DELETE ON vi_setting_base FOR EACH ROW EXECUTE FUNCTION vi_setting_keep();

COMMIT;
