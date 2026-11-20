-- 自动生成：framework/tools/restructure_20261111.py。估值部分按 Greenwald 三层重构：建新结构 → 搬数据 → 删旧表。

-- 执行顺序：本文件 → 02_calc.sql → 03_ui.sql（本文件先删掉全部 vi_ 视图）。

BEGIN;

DO $$ DECLARE r record; BEGIN
  FOR r IN SELECT matviewname AS n FROM pg_matviews WHERE schemaname = 'public' AND matviewname LIKE 'vi\_%' LOOP
    EXECUTE 'DROP MATERIALIZED VIEW IF EXISTS ' || r.n || ' CASCADE'; END LOOP;
  FOR r IN SELECT viewname AS n FROM pg_views WHERE schemaname = 'public' AND viewname LIKE 'vi\_%' LOOP
    EXECUTE 'DROP VIEW IF EXISTS ' || r.n || ' CASCADE'; END LOOP;
END $$;

DROP FUNCTION IF EXISTS vi_gw_guard() CASCADE;  -- 旧的归属检查（按估值模型），新规则在文末重建

ALTER TABLE vi_company_base ADD COLUMN IF NOT EXISTS shares double precision, ADD COLUMN IF NOT EXISTS as_of date,
  ADD COLUMN IF NOT EXISTS value_layer text, ADD COLUMN IF NOT EXISTS layer_reason text;

UPDATE vi_company_base SET shares = 28.5419, as_of = '2026-06-30', value_layer = '含增长价值', layer_reason = '迁移自统一估值引擎：原结论用全价值（逐年现金流折现）。待按 Greenwald 重新研究资产价值与盈利能力后再定主估值层。' WHERE id = 2;

INSERT INTO vi_lnk_company_macro_metrics (company_id, metric_id, "createdAt", "updatedAt")
SELECT 2, 2, now(), now() WHERE EXISTS (SELECT 1 FROM vi_metric_base WHERE id = 2 AND company_id IS NULL)
ON CONFLICT DO NOTHING;

UPDATE vi_company_base SET shares = 257.0944, as_of = '2026-06-30', value_layer = '含增长价值', layer_reason = '迁移自统一估值引擎：原结论用全价值（逐年现金流折现）。待按 Greenwald 重新研究资产价值与盈利能力后再定主估值层。' WHERE id = 21;

INSERT INTO vi_lnk_company_macro_metrics (company_id, metric_id, "createdAt", "updatedAt")
SELECT 21, 2, now(), now() WHERE EXISTS (SELECT 1 FROM vi_metric_base WHERE id = 2 AND company_id IS NULL)
ON CONFLICT DO NOTHING;

UPDATE vi_company_base SET shares = 413.2039, as_of = '2026-06-30', value_layer = '含增长价值', layer_reason = '迁移自统一估值引擎：原结论用全价值（逐年现金流折现）。待按 Greenwald 重新研究资产价值与盈利能力后再定主估值层。' WHERE id = 7;

INSERT INTO vi_lnk_company_macro_metrics (company_id, metric_id, "createdAt", "updatedAt")
SELECT 7, 2, now(), now() WHERE EXISTS (SELECT 1 FROM vi_metric_base WHERE id = 2 AND company_id IS NULL)
ON CONFLICT DO NOTHING;

UPDATE vi_company_base SET shares = 244.68, as_of = '2026-06-30', value_layer = '含增长价值', layer_reason = '迁移自统一估值引擎：原结论用全价值（逐年现金流折现）。待按 Greenwald 重新研究资产价值与盈利能力后再定主估值层。' WHERE id = 1;

INSERT INTO vi_lnk_company_macro_metrics (company_id, metric_id, "createdAt", "updatedAt")
SELECT 1, 2, now(), now() WHERE EXISTS (SELECT 1 FROM vi_metric_base WHERE id = 2 AND company_id IS NULL)
ON CONFLICT DO NOTHING;

UPDATE vi_company_base SET shares = 31.6, as_of = '2026-06-30', value_layer = '盈利能力价值', layer_reason = '轻资产平台，资产价值说明不了价值；增长取决于优势能维持多久（T3、T4 未定），先以不增长的盈利能力价值作结论，增长只作参照。见 J-LAYER。' WHERE id = 11;

INSERT INTO vi_lnk_company_macro_metrics (company_id, metric_id, "createdAt", "updatedAt")
SELECT 11, 2, now(), now() WHERE EXISTS (SELECT 1 FROM vi_metric_base WHERE id = 2 AND company_id IS NULL)
ON CONFLICT DO NOTHING;

ALTER TABLE vi_scenario_base ADD COLUMN IF NOT EXISTS company_id bigint;
UPDATE vi_scenario_base s SET company_id = m.company_id FROM vi_model_base m WHERE m.id = s.model_id AND m.status = '当前';
DELETE FROM vi_scenario_base WHERE company_id IS NULL;
ALTER TABLE vi_scenario_base DROP CONSTRAINT IF EXISTS vi_scenario_uniq;
ALTER TABLE vi_scenario_base DROP COLUMN model_id CASCADE, DROP COLUMN volume_factor, DROP COLUMN price_factor, DROP COLUMN cost_factor,
  DROP COLUMN discount_rate, DROP COLUMN terminal_growth, DROP COLUMN nature, DROP COLUMN ronic, DROP COLUMN sotp_multiple;
ALTER TABLE vi_scenario_base ADD CONSTRAINT vi_scenario_uniq UNIQUE (company_id, name);
ALTER TABLE vi_scenario_base ADD FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE SET NULL;
CREATE INDEX ON vi_scenario_base (company_id);

ALTER TABLE vi_business_base ADD COLUMN IF NOT EXISTS repro_cost double precision;
ALTER TABLE vi_business_base DROP COLUMN IF EXISTS kind, DROP COLUMN IF EXISTS driver1_label, DROP COLUMN IF EXISTS driver1_unit,
  DROP COLUMN IF EXISTS driver2_label, DROP COLUMN IF EXISTS driver2_unit, DROP COLUMN IF EXISTS driver3_label, DROP COLUMN IF EXISTS driver3_unit,
  DROP COLUMN IF EXISTS driver_scale, DROP COLUMN IF EXISTS cost_allocation;

ALTER TABLE vi_bs_item_base ADD COLUMN IF NOT EXISTS company_id bigint, ADD COLUMN IF NOT EXISTS scenario_id bigint;
UPDATE vi_bs_item_base b SET company_id = m.company_id FROM vi_model_base m WHERE m.id = b.model_id;
ALTER TABLE vi_bs_item_base DROP COLUMN model_id CASCADE;
ALTER TABLE vi_bs_item_base ADD FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE SET NULL;
ALTER TABLE vi_bs_item_base ADD FOREIGN KEY (scenario_id) REFERENCES vi_scenario_base(id) ON DELETE SET NULL;
CREATE INDEX ON vi_bs_item_base (company_id); CREATE INDEX ON vi_bs_item_base (scenario_id);

CREATE TABLE vi_epv_base (
  id bigserial PRIMARY KEY,
  revenue double precision,
  margin double precision,
  tax_rate double precision,
  da double precision,
  maint_capex double precision,
  attrib double precision,
  life integer,
  note text,
  company_id bigint,
  business_id bigint,
  scenario_id bigint,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE vi_epv_base IS '盈利能力：第二层输入：每块业务、每个情景今天可持续的盈利（不增长）；引用【业务分部】【假设依据】【情景】；被【三层价值·业务】引用。可持续现金收益 E＝(正常化收入×正常化经营利润率×(1−税率)＋折旧摊销−维持性资本开支)×归母比例；盈利能力价值＝E÷门槛，有盈利年限时按年金。';

COMMENT ON COLUMN vi_epv_base.revenue IS '正常化收入（亿元）：今天的可持续收入水平，不含增长';

COMMENT ON COLUMN vi_epv_base.margin IS '正常化经营利润率：企业口径＝利息前经营利润÷收入；股权口径＝利息后税前利润÷收入。周期业务取完整周期平均；不含独立计价资产的收益（利息收入、投资收益）（小数，0.05＝5%）';

COMMENT ON COLUMN vi_epv_base.tax_rate IS '税率（小数，0.05＝5%）';

COMMENT ON COLUMN vi_epv_base.da IS '折旧摊销（亿元）：经营利润里已扣的折旧摊销；与维持性资本开支成对填写，都留空＝按两者相等处理';

COMMENT ON COLUMN vi_epv_base.maint_capex IS '维持性资本开支（亿元）：维持现有经营能力所需的资本开支，不含扩张';

COMMENT ON COLUMN vi_epv_base.attrib IS '归母比例：留空＝100%；乘收益和资产价值（小数，0.05＝5%）';

COMMENT ON COLUMN vi_epv_base.life IS '盈利年限：留空＝永续；特许经营期、矿山等有限寿命时填剩余年数';

COMMENT ON COLUMN vi_epv_base.note IS '说明';

COMMENT ON COLUMN vi_epv_base.company_id IS '公司（关联 公司）';

COMMENT ON COLUMN vi_epv_base.business_id IS '业务（关联 业务分部）';

COMMENT ON COLUMN vi_epv_base.scenario_id IS '情景（关联 情景）';

CREATE TRIGGER vi_epv_base_touch BEFORE UPDATE ON vi_epv_base FOR EACH ROW EXECUTE FUNCTION vi_touch_updated_at();

CREATE TABLE vi_growth_base (
  id bigserial PRIMARY KEY,
  growth double precision,
  ronic double precision,
  adv_years integer,
  note text,
  company_id bigint,
  business_id bigint,
  scenario_id bigint,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE vi_growth_base IS '增长：第三层输入：每块业务、每个情景的增长与新增投资回报；引用【业务分部】【假设依据】【情景】；被【三层价值·业务】引用。优势年限内每年增长 g、再投入 g÷新增投资回报率 的收益，之后增长不再创造价值；新增投资回报率等于门槛时增长一分不值。不填或增长率为 0＝含增长价值等于盈利能力价值。';

COMMENT ON COLUMN vi_growth_base.growth IS '增长率：优势期内每年的增长（小数，0.05＝5%）';

COMMENT ON COLUMN vi_growth_base.ronic IS '新增投资回报率：为增长新投入资本的税后回报；增长率不为 0 时必填（小数，0.05＝5%）';

COMMENT ON COLUMN vi_growth_base.adv_years IS '优势年限：超额回报还能持续几年，之后增长不再创造价值；留空＝永续（要求增长率低于门槛）';

COMMENT ON COLUMN vi_growth_base.note IS '说明';

COMMENT ON COLUMN vi_growth_base.company_id IS '公司（关联 公司）';

COMMENT ON COLUMN vi_growth_base.business_id IS '业务（关联 业务分部）';

COMMENT ON COLUMN vi_growth_base.scenario_id IS '情景（关联 情景）';

CREATE TRIGGER vi_growth_base_touch BEFORE UPDATE ON vi_growth_base FOR EACH ROW EXECUTE FUNCTION vi_touch_updated_at();

ALTER TABLE vi_epv_base ADD FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE SET NULL;

CREATE INDEX ON vi_epv_base (company_id);

ALTER TABLE vi_epv_base ADD FOREIGN KEY (business_id) REFERENCES vi_business_base(id) ON DELETE SET NULL;

CREATE INDEX ON vi_epv_base (business_id);

ALTER TABLE vi_epv_base ADD FOREIGN KEY (scenario_id) REFERENCES vi_scenario_base(id) ON DELETE SET NULL;

CREATE INDEX ON vi_epv_base (scenario_id);

ALTER TABLE vi_growth_base ADD FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE SET NULL;

CREATE INDEX ON vi_growth_base (company_id);

ALTER TABLE vi_growth_base ADD FOREIGN KEY (business_id) REFERENCES vi_business_base(id) ON DELETE SET NULL;

CREATE INDEX ON vi_growth_base (business_id);

ALTER TABLE vi_growth_base ADD FOREIGN KEY (scenario_id) REFERENCES vi_scenario_base(id) ON DELETE SET NULL;

CREATE INDEX ON vi_growth_base (scenario_id);

ALTER TABLE vi_epv_base ADD CONSTRAINT vi_epv_uniq UNIQUE (business_id, scenario_id);

ALTER TABLE vi_growth_base ADD CONSTRAINT vi_growth_uniq UNIQUE (business_id, scenario_id);

CREATE TABLE vi_lnk_epv_judgments (
  epv_id bigint NOT NULL REFERENCES vi_epv_base(id) ON DELETE CASCADE,
  judgment_id bigint NOT NULL REFERENCES vi_judgment_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (epv_id, judgment_id)
);

COMMENT ON TABLE vi_lnk_epv_judgments IS '盈利能力 ↔ 假设依据（多对多）';

CREATE TABLE vi_lnk_growth_judgments (
  growth_id bigint NOT NULL REFERENCES vi_growth_base(id) ON DELETE CASCADE,
  judgment_id bigint NOT NULL REFERENCES vi_judgment_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (growth_id, judgment_id)
);

COMMENT ON TABLE vi_lnk_growth_judgments IS '增长 ↔ 假设依据（多对多）';

-- 业务身份的公司归属：商业模式拆解、资产负债重估、盈利能力、增长里的业务与情景必须属于同一家公司。
CREATE OR REPLACE FUNCTION vi_business_scope_guard() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.business_id IS NOT NULL AND NOT EXISTS
     (SELECT 1 FROM vi_business_base WHERE id = NEW.business_id AND company_id = NEW.company_id) THEN
    RAISE EXCEPTION '业务必须属于当前公司';
  END IF;
  IF TG_TABLE_NAME = 'vi_biz_model_base' THEN RETURN NEW; END IF;
  IF NEW.scenario_id IS NOT NULL AND NOT EXISTS
     (SELECT 1 FROM vi_scenario_base WHERE id = NEW.scenario_id AND company_id = NEW.company_id) THEN
    RAISE EXCEPTION '情景必须属于当前公司';
  END IF;
  IF TG_TABLE_NAME IN ('vi_epv_base', 'vi_growth_base') THEN
    IF NEW.business_id IS NULL OR NEW.scenario_id IS NULL THEN RAISE EXCEPTION '必须选业务和情景'; END IF;
  ELSE
    IF NEW.category IS NULL OR NEW.category NOT IN ('经营资产', '经营负债', '现金与投资', '参照估值', '有息负债', '其他索取权') THEN
      RAISE EXCEPTION '请填写有效的类别';
    END IF;
    IF NEW.haircut IS NOT NULL AND (NEW.haircut < 0 OR NEW.haircut > 1) THEN RAISE EXCEPTION '折价必须在 0 到 1 之间'; END IF;
    IF NEW.scenario_id IS NOT NULL AND nullif(btrim(NEW.line_item), '') IS NOT NULL THEN
      RAISE EXCEPTION '情景专属行只能是研究调整：报表科目行对全部情景生效';
    END IF;
  END IF;
  RETURN NEW;
END $$;
DROP TRIGGER IF EXISTS vi_biz_model_business_scope ON vi_biz_model_base;
CREATE TRIGGER vi_biz_model_business_scope BEFORE INSERT OR UPDATE ON vi_biz_model_base
  FOR EACH ROW EXECUTE FUNCTION vi_business_scope_guard();
DROP TRIGGER IF EXISTS vi_bs_item_business_scope ON vi_bs_item_base;
CREATE TRIGGER vi_bs_item_business_scope BEFORE INSERT OR UPDATE ON vi_bs_item_base
  FOR EACH ROW EXECUTE FUNCTION vi_business_scope_guard();
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
       OR EXISTS (SELECT 1 FROM vi_bs_item_base WHERE business_id = OLD.id)
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

INSERT INTO vi_epv_base (company_id, business_id, scenario_id, revenue, margin, tax_rate, da, maint_capex, attrib, life, note)
SELECT m.company_id, v.business_id, v.scenario_id, v.revenue, v.margin, v.tax_rate, v.da, v.maint_capex, v.attrib, v.life, v.note
FROM vi_val_input_base v JOIN vi_model_base m ON m.id = v.model_id;
INSERT INTO vi_growth_base (company_id, business_id, scenario_id, growth, ronic, adv_years, note)
SELECT m.company_id, v.business_id, v.scenario_id, v.growth, v.ronic, v.adv_years, v.note
FROM vi_val_input_base v JOIN vi_model_base m ON m.id = v.model_id WHERE v.growth IS NOT NULL OR v.ronic IS NOT NULL OR v.adv_years IS NOT NULL;
INSERT INTO vi_lnk_epv_judgments (epv_id, judgment_id, "createdAt", "updatedAt")
SELECT e.id, l.judgment_id, now(), now() FROM vi_lnk_val_input_judgments l JOIN vi_val_input_base v ON v.id = l.val_input_id
JOIN vi_epv_base e ON e.business_id = v.business_id AND e.scenario_id = v.scenario_id
JOIN vi_judgment_base j ON j.id = l.judgment_id WHERE j.code <> 'J-GROW';
INSERT INTO vi_lnk_growth_judgments (growth_id, judgment_id, "createdAt", "updatedAt")
SELECT g.id, l.judgment_id, now(), now() FROM vi_lnk_val_input_judgments l JOIN vi_val_input_base v ON v.id = l.val_input_id
JOIN vi_growth_base g ON g.business_id = v.business_id AND g.scenario_id = v.scenario_id
JOIN vi_judgment_base j ON j.id = l.judgment_id WHERE j.code = 'J-GROW';

INSERT INTO vi_judgment_base (company_id, code, title, status, judgment, transmission, parameter, change_threshold)
VALUES (1, 'J-MIG', '三层估值的输入：迁移自统一估值引擎（待按 Greenwald 重新研究）', '已形成建议',
'2026-11-11 估值重构时从统一估值引擎搬来：盈利能力＝第一个完整年度（2027）的收入、正常化经营利润率（没填时取当年利润率）、税率、归母比例；增长＝原永续增长率与终值新增投资回报率（原来留空＝门槛 6%），优势年限留空＝永续，与原终值口径一致；经营资本＝原期初投入资本（归母权益减资产负债桥账面项），还没有按资产负债表逐项归类；资产负债桥＝原资产估值与调整里单独计价的项目。原逐年预测（明确期现金流）不再使用，所以含增长价值与原全价值不同。',
'盈利能力价值＝E÷门槛；含增长价值按增长率、新增投资回报率、优势年限；股权价值＝业务价值＋资产负债桥。',
'盈利能力、增长、资产负债重估', '按 Greenwald 重新研究这家公司时逐项替换（正常化利润率、维持性资本开支、资产负债表逐项归类、优势年限）。')
ON CONFLICT (company_id, code) DO UPDATE SET judgment = EXCLUDED.judgment;

INSERT INTO vi_epv_base (company_id, business_id, scenario_id, revenue, margin, tax_rate, attrib, note) VALUES (1, 16, 1, 747.41, 0.464481, 0.17, 1, '迁移：2027 年经营利润率，2027 年收入（统一估值引擎）');

INSERT INTO vi_lnk_epv_judgments (epv_id, judgment_id, "createdAt", "updatedAt") SELECT x.id, j.id, now(), now() FROM (SELECT id FROM vi_epv_base WHERE business_id = 16 AND scenario_id = 1) x JOIN vi_judgment_base j ON j.company_id = 1 AND j.code IN ('J-COST', 'J-DA', 'J-MIG', 'J-P', 'J-Q', 'J-TAX') ON CONFLICT DO NOTHING;

INSERT INTO vi_growth_base (company_id, business_id, scenario_id, growth, ronic, note) VALUES (1, 16, 1, 0, 0.06, '迁移：原永续增长率与终值新增投资回报率（原来留空＝门槛，增长不创造价值）');

INSERT INTO vi_lnk_growth_judgments (growth_id, judgment_id, "createdAt", "updatedAt") SELECT x.id, j.id, now(), now() FROM (SELECT id FROM vi_growth_base WHERE business_id = 16 AND scenario_id = 1) x JOIN vi_judgment_base j ON j.company_id = 1 AND j.code IN ('J-MIG', 'J-TV') ON CONFLICT DO NOTHING;

INSERT INTO vi_epv_base (company_id, business_id, scenario_id, revenue, margin, tax_rate, attrib, note) VALUES (1, 16, 2, 856.13, 0.544464, 0.17, 1, '迁移：2027 年经营利润率，2027 年收入（统一估值引擎）');

INSERT INTO vi_lnk_epv_judgments (epv_id, judgment_id, "createdAt", "updatedAt") SELECT x.id, j.id, now(), now() FROM (SELECT id FROM vi_epv_base WHERE business_id = 16 AND scenario_id = 2) x JOIN vi_judgment_base j ON j.company_id = 1 AND j.code IN ('J-COST', 'J-DA', 'J-MIG', 'J-P', 'J-Q', 'J-TAX') ON CONFLICT DO NOTHING;

INSERT INTO vi_growth_base (company_id, business_id, scenario_id, growth, ronic, note) VALUES (1, 16, 2, 0.01, 0.06, '迁移：原永续增长率与终值新增投资回报率（原来留空＝门槛，增长不创造价值）');

INSERT INTO vi_lnk_growth_judgments (growth_id, judgment_id, "createdAt", "updatedAt") SELECT x.id, j.id, now(), now() FROM (SELECT id FROM vi_growth_base WHERE business_id = 16 AND scenario_id = 2) x JOIN vi_judgment_base j ON j.company_id = 1 AND j.code IN ('J-MIG', 'J-TV') ON CONFLICT DO NOTHING;

INSERT INTO vi_epv_base (company_id, business_id, scenario_id, revenue, margin, tax_rate, attrib, note) VALUES (1, 16, 3, 907.93, 0.570452, 0.17, 1, '迁移：2027 年经营利润率，2027 年收入（统一估值引擎）');

INSERT INTO vi_lnk_epv_judgments (epv_id, judgment_id, "createdAt", "updatedAt") SELECT x.id, j.id, now(), now() FROM (SELECT id FROM vi_epv_base WHERE business_id = 16 AND scenario_id = 3) x JOIN vi_judgment_base j ON j.company_id = 1 AND j.code IN ('J-COST', 'J-DA', 'J-MIG', 'J-P', 'J-Q', 'J-TAX') ON CONFLICT DO NOTHING;

INSERT INTO vi_growth_base (company_id, business_id, scenario_id, growth, ronic, note) VALUES (1, 16, 3, 0.015, 0.06, '迁移：原永续增长率与终值新增投资回报率（原来留空＝门槛，增长不创造价值）');

INSERT INTO vi_lnk_growth_judgments (growth_id, judgment_id, "createdAt", "updatedAt") SELECT x.id, j.id, now(), now() FROM (SELECT id FROM vi_growth_base WHERE business_id = 16 AND scenario_id = 3) x JOIN vi_judgment_base j ON j.company_id = 1 AND j.code IN ('J-MIG', 'J-TV') ON CONFLICT DO NOTHING;

WITH ins AS (INSERT INTO vi_bs_item_base (company_id, business_id, category, name, adjustment, basis, sort) VALUES
(1, 16, '经营资产', '经营投入资本（迁移，待按报表逐项归类）', 4180.07,
'原统一估值引擎的期初投入资本＝截至日归母权益 − 资产负债桥里按账面计的项目（原检查 V09 对账）。按 Greenwald 研究时改成逐个报表科目。', 1) RETURNING id)
INSERT INTO vi_lnk_bs_item_judgments (bs_item_id, judgment_id, "createdAt", "updatedAt") SELECT ins.id, (SELECT id FROM vi_judgment_base WHERE company_id = 1 AND code = 'J-MIG'), now(), now() FROM ins;

WITH ins AS (INSERT INTO vi_bs_item_base (company_id, scenario_id, category, name, adjustment, basis, sort) VALUES
(1, NULL, '现金与投资', '货币资金', 93.7287, '原 N1。货币资金 93.7（亿元）。2026 年中报。', 10) RETURNING id)
INSERT INTO vi_lnk_bs_item_judgments (bs_item_id, judgment_id, "createdAt", "updatedAt") SELECT ins.id, (SELECT id FROM vi_judgment_base WHERE company_id = 1 AND code = 'J-MIG'), now(), now() FROM ins;

WITH ins AS (INSERT INTO vi_bs_item_base (company_id, scenario_id, category, name, adjustment, basis, sort) VALUES
(1, NULL, '有息负债', '带息负债', 2833.6613, '原 N2。短期借款 67.0＋一年内到期的非流动负债 657.4＋长期借款 1,754.5＋应付债券 349.7＋租赁负债 5.1（亿元）。2026 年中报；其他流动负债 5.2 亿元未计入（性质未核实）。', 11) RETURNING id)
INSERT INTO vi_lnk_bs_item_judgments (bs_item_id, judgment_id, "createdAt", "updatedAt") SELECT ins.id, (SELECT id FROM vi_judgment_base WHERE company_id = 1 AND code = 'J-MIG'), now(), now() FROM ins;

WITH ins AS (INSERT INTO vi_bs_item_base (company_id, scenario_id, category, name, adjustment, basis, sort) VALUES
(1, NULL, '现金与投资', '对外持股（账面价值）', 840.9953, '原 N3。长期股权投资 747.5＋其他权益工具投资 43.3＋其他非流动金融资产 39.1＋债权投资 11.0（亿元）。2026 年中报账面价值，未按市值重估；旧模型只计收到的分红，这里改为计入整笔投资，经营利润相应不含投资收益。', 12) RETURNING id)
INSERT INTO vi_lnk_bs_item_judgments (bs_item_id, judgment_id, "createdAt", "updatedAt") SELECT ins.id, (SELECT id FROM vi_judgment_base WHERE company_id = 1 AND code = 'J-MIG'), now(), now() FROM ins;

WITH ins AS (INSERT INTO vi_bs_item_base (company_id, scenario_id, category, name, adjustment, basis, sort) VALUES
(1, NULL, '其他索取权', '少数股东权益', 119.8231, '原 N4。少数股东权益 119.8（亿元）。2026 年中报账面价值。', 13) RETURNING id)
INSERT INTO vi_lnk_bs_item_judgments (bs_item_id, judgment_id, "createdAt", "updatedAt") SELECT ins.id, (SELECT id FROM vi_judgment_base WHERE company_id = 1 AND code = 'J-MIG'), now(), now() FROM ins;

INSERT INTO vi_judgment_base (company_id, code, title, status, judgment, transmission, parameter, change_threshold)
VALUES (2, 'J-MIG', '三层估值的输入：迁移自统一估值引擎（待按 Greenwald 重新研究）', '已形成建议',
'2026-11-11 估值重构时从统一估值引擎搬来：盈利能力＝第一个完整年度（2027）的收入、正常化经营利润率（没填时取当年利润率）、税率、归母比例；增长＝原永续增长率与终值新增投资回报率（原来留空＝门槛 6%），优势年限留空＝永续，与原终值口径一致；经营资本＝原期初投入资本（归母权益减资产负债桥账面项），还没有按资产负债表逐项归类；资产负债桥＝原资产估值与调整里单独计价的项目。原逐年预测（明确期现金流）不再使用，所以含增长价值与原全价值不同。',
'盈利能力价值＝E÷门槛；含增长价值按增长率、新增投资回报率、优势年限；股权价值＝业务价值＋资产负债桥。',
'盈利能力、增长、资产负债重估', '按 Greenwald 重新研究这家公司时逐项替换（正常化利润率、维持性资本开支、资产负债表逐项归类、优势年限）。')
ON CONFLICT (company_id, code) DO UPDATE SET judgment = EXCLUDED.judgment;

INSERT INTO vi_epv_base (company_id, business_id, scenario_id, revenue, margin, tax_rate, attrib, note) VALUES (2, 18, 119, 417.39, 0.1289, 0.15, 1, '迁移：正常化经营利润率，2027 年收入（统一估值引擎）');

INSERT INTO vi_lnk_epv_judgments (epv_id, judgment_id, "createdAt", "updatedAt") SELECT x.id, j.id, now(), now() FROM (SELECT id FROM vi_epv_base WHERE business_id = 18 AND scenario_id = 119) x JOIN vi_judgment_base j ON j.company_id = 2 AND j.code IN ('J-DA', 'J-M', 'J-MIG', 'J-NORM', 'J-OTHER', 'J-P', 'J-Q', 'J-TAX') ON CONFLICT DO NOTHING;

INSERT INTO vi_growth_base (company_id, business_id, scenario_id, growth, ronic, note) VALUES (2, 18, 119, 0.005, 0.06, '迁移：原永续增长率与终值新增投资回报率（原来留空＝门槛，增长不创造价值）');

INSERT INTO vi_lnk_growth_judgments (growth_id, judgment_id, "createdAt", "updatedAt") SELECT x.id, j.id, now(), now() FROM (SELECT id FROM vi_growth_base WHERE business_id = 18 AND scenario_id = 119) x JOIN vi_judgment_base j ON j.company_id = 2 AND j.code IN ('J-MIG', 'J-TV') ON CONFLICT DO NOTHING;

INSERT INTO vi_epv_base (company_id, business_id, scenario_id, revenue, margin, tax_rate, attrib, note) VALUES (2, 18, 120, 448.23, 0.1289, 0.15, 1, '迁移：正常化经营利润率，2027 年收入（统一估值引擎）');

INSERT INTO vi_lnk_epv_judgments (epv_id, judgment_id, "createdAt", "updatedAt") SELECT x.id, j.id, now(), now() FROM (SELECT id FROM vi_epv_base WHERE business_id = 18 AND scenario_id = 120) x JOIN vi_judgment_base j ON j.company_id = 2 AND j.code IN ('J-DA', 'J-M', 'J-MIG', 'J-NORM', 'J-OTHER', 'J-P', 'J-Q', 'J-TAX') ON CONFLICT DO NOTHING;

INSERT INTO vi_growth_base (company_id, business_id, scenario_id, growth, ronic, note) VALUES (2, 18, 120, 0.015, 0.06, '迁移：原永续增长率与终值新增投资回报率（原来留空＝门槛，增长不创造价值）');

INSERT INTO vi_lnk_growth_judgments (growth_id, judgment_id, "createdAt", "updatedAt") SELECT x.id, j.id, now(), now() FROM (SELECT id FROM vi_growth_base WHERE business_id = 18 AND scenario_id = 120) x JOIN vi_judgment_base j ON j.company_id = 2 AND j.code IN ('J-MIG', 'J-TV') ON CONFLICT DO NOTHING;

INSERT INTO vi_epv_base (company_id, business_id, scenario_id, revenue, margin, tax_rate, attrib, note) VALUES (2, 18, 121, 466.29, 0.1289, 0.15, 1, '迁移：正常化经营利润率，2027 年收入（统一估值引擎）');

INSERT INTO vi_lnk_epv_judgments (epv_id, judgment_id, "createdAt", "updatedAt") SELECT x.id, j.id, now(), now() FROM (SELECT id FROM vi_epv_base WHERE business_id = 18 AND scenario_id = 121) x JOIN vi_judgment_base j ON j.company_id = 2 AND j.code IN ('J-DA', 'J-M', 'J-MIG', 'J-NORM', 'J-OTHER', 'J-P', 'J-Q', 'J-TAX') ON CONFLICT DO NOTHING;

INSERT INTO vi_growth_base (company_id, business_id, scenario_id, growth, ronic, note) VALUES (2, 18, 121, 0.025, 0.06, '迁移：原永续增长率与终值新增投资回报率（原来留空＝门槛，增长不创造价值）');

INSERT INTO vi_lnk_growth_judgments (growth_id, judgment_id, "createdAt", "updatedAt") SELECT x.id, j.id, now(), now() FROM (SELECT id FROM vi_growth_base WHERE business_id = 18 AND scenario_id = 121) x JOIN vi_judgment_base j ON j.company_id = 2 AND j.code IN ('J-MIG', 'J-TV') ON CONFLICT DO NOTHING;

WITH ins AS (INSERT INTO vi_bs_item_base (company_id, business_id, category, name, adjustment, basis, sort) VALUES
(2, 18, '经营资产', '经营投入资本（迁移，待按报表逐项归类）', 504.66,
'原统一估值引擎的期初投入资本＝截至日归母权益 − 资产负债桥里按账面计的项目（原检查 V09 对账）。按 Greenwald 研究时改成逐个报表科目。', 1) RETURNING id)
INSERT INTO vi_lnk_bs_item_judgments (bs_item_id, judgment_id, "createdAt", "updatedAt") SELECT ins.id, (SELECT id FROM vi_judgment_base WHERE company_id = 2 AND code = 'J-MIG'), now(), now() FROM ins;

WITH ins AS (INSERT INTO vi_bs_item_base (company_id, scenario_id, category, name, adjustment, basis, sort) VALUES
(2, NULL, '现金与投资', '货币资金', 24.8754, '原 N1。货币资金 24.9（亿元）。2026 年中报。', 10) RETURNING id)
INSERT INTO vi_lnk_bs_item_judgments (bs_item_id, judgment_id, "createdAt", "updatedAt") SELECT ins.id, (SELECT id FROM vi_judgment_base WHERE company_id = 2 AND code = 'J-MIG'), now(), now() FROM ins;

WITH ins AS (INSERT INTO vi_bs_item_base (company_id, scenario_id, category, name, adjustment, basis, sort) VALUES
(2, NULL, '有息负债', '带息负债', 213.0666, '原 N2。短期借款 80.5＋一年内到期的非流动负债 36.9＋长期借款 95.5＋租赁负债 0.2（亿元）。2026 年中报。', 11) RETURNING id)
INSERT INTO vi_lnk_bs_item_judgments (bs_item_id, judgment_id, "createdAt", "updatedAt") SELECT ins.id, (SELECT id FROM vi_judgment_base WHERE company_id = 2 AND code = 'J-MIG'), now(), now() FROM ins;

WITH ins AS (INSERT INTO vi_bs_item_base (company_id, scenario_id, category, name, adjustment, basis, sort) VALUES
(2, NULL, '其他索取权', '少数股东权益', 1.1688, '原 N3。少数股东权益 1.2（亿元）。2026 年中报账面价值。', 12) RETURNING id)
INSERT INTO vi_lnk_bs_item_judgments (bs_item_id, judgment_id, "createdAt", "updatedAt") SELECT ins.id, (SELECT id FROM vi_judgment_base WHERE company_id = 2 AND code = 'J-MIG'), now(), now() FROM ins;

INSERT INTO vi_judgment_base (company_id, code, title, status, judgment, transmission, parameter, change_threshold)
VALUES (7, 'J-MIG', '三层估值的输入：迁移自统一估值引擎（待按 Greenwald 重新研究）', '已形成建议',
'2026-11-11 估值重构时从统一估值引擎搬来：盈利能力＝第一个完整年度（2027）的收入、正常化经营利润率（没填时取当年利润率）、税率、归母比例；增长＝原永续增长率与终值新增投资回报率（原来留空＝门槛 6%），优势年限留空＝永续，与原终值口径一致；经营资本＝原期初投入资本（归母权益减资产负债桥账面项），还没有按资产负债表逐项归类；资产负债桥＝原资产估值与调整里单独计价的项目。原逐年预测（明确期现金流）不再使用，所以含增长价值与原全价值不同。',
'盈利能力价值＝E÷门槛；含增长价值按增长率、新增投资回报率、优势年限；股权价值＝业务价值＋资产负债桥。',
'盈利能力、增长、资产负债重估', '按 Greenwald 重新研究这家公司时逐项替换（正常化利润率、维持性资本开支、资产负债表逐项归类、优势年限）。')
ON CONFLICT (company_id, code) DO UPDATE SET judgment = EXCLUDED.judgment;

INSERT INTO vi_epv_base (company_id, business_id, scenario_id, revenue, margin, tax_rate, attrib, note) VALUES (7, 19, 128, 17118.3, 0.0495, 0.24, 0.74, '迁移：正常化经营利润率，2027 年收入（统一估值引擎）');

INSERT INTO vi_lnk_epv_judgments (epv_id, judgment_id, "createdAt", "updatedAt") SELECT x.id, j.id, now(), now() FROM (SELECT id FROM vi_epv_base WHERE business_id = 19 AND scenario_id = 128) x JOIN vi_judgment_base j ON j.company_id = 7 AND j.code IN ('J-DA', 'J-DEBT', 'J-IMP', 'J-M', 'J-MIG', 'J-NORM', 'J-P', 'J-Q', 'J-TAX') ON CONFLICT DO NOTHING;

INSERT INTO vi_growth_base (company_id, business_id, scenario_id, growth, ronic, note) VALUES (7, 19, 128, 0, 0.06, '迁移：原永续增长率与终值新增投资回报率（原来留空＝门槛，增长不创造价值）');

INSERT INTO vi_lnk_growth_judgments (growth_id, judgment_id, "createdAt", "updatedAt") SELECT x.id, j.id, now(), now() FROM (SELECT id FROM vi_growth_base WHERE business_id = 19 AND scenario_id = 128) x JOIN vi_judgment_base j ON j.company_id = 7 AND j.code IN ('J-MIG', 'J-TV') ON CONFLICT DO NOTHING;

INSERT INTO vi_epv_base (company_id, business_id, scenario_id, revenue, margin, tax_rate, attrib, note) VALUES (7, 19, 129, 18387, 0.0495, 0.24, 0.74, '迁移：正常化经营利润率，2027 年收入（统一估值引擎）');

INSERT INTO vi_lnk_epv_judgments (epv_id, judgment_id, "createdAt", "updatedAt") SELECT x.id, j.id, now(), now() FROM (SELECT id FROM vi_epv_base WHERE business_id = 19 AND scenario_id = 129) x JOIN vi_judgment_base j ON j.company_id = 7 AND j.code IN ('J-DA', 'J-DEBT', 'J-IMP', 'J-M', 'J-MIG', 'J-NORM', 'J-P', 'J-Q', 'J-TAX') ON CONFLICT DO NOTHING;

INSERT INTO vi_growth_base (company_id, business_id, scenario_id, growth, ronic, note) VALUES (7, 19, 129, 0.01, 0.06, '迁移：原永续增长率与终值新增投资回报率（原来留空＝门槛，增长不创造价值）');

INSERT INTO vi_lnk_growth_judgments (growth_id, judgment_id, "createdAt", "updatedAt") SELECT x.id, j.id, now(), now() FROM (SELECT id FROM vi_growth_base WHERE business_id = 19 AND scenario_id = 129) x JOIN vi_judgment_base j ON j.company_id = 7 AND j.code IN ('J-MIG', 'J-TV') ON CONFLICT DO NOTHING;

INSERT INTO vi_epv_base (company_id, business_id, scenario_id, revenue, margin, tax_rate, attrib, note) VALUES (7, 19, 130, 19317.38, 0.0495, 0.24, 0.74, '迁移：正常化经营利润率，2027 年收入（统一估值引擎）');

INSERT INTO vi_lnk_epv_judgments (epv_id, judgment_id, "createdAt", "updatedAt") SELECT x.id, j.id, now(), now() FROM (SELECT id FROM vi_epv_base WHERE business_id = 19 AND scenario_id = 130) x JOIN vi_judgment_base j ON j.company_id = 7 AND j.code IN ('J-DA', 'J-DEBT', 'J-IMP', 'J-M', 'J-MIG', 'J-NORM', 'J-P', 'J-Q', 'J-TAX') ON CONFLICT DO NOTHING;

INSERT INTO vi_growth_base (company_id, business_id, scenario_id, growth, ronic, note) VALUES (7, 19, 130, 0.02, 0.06, '迁移：原永续增长率与终值新增投资回报率（原来留空＝门槛，增长不创造价值）');

INSERT INTO vi_lnk_growth_judgments (growth_id, judgment_id, "createdAt", "updatedAt") SELECT x.id, j.id, now(), now() FROM (SELECT id FROM vi_growth_base WHERE business_id = 19 AND scenario_id = 130) x JOIN vi_judgment_base j ON j.company_id = 7 AND j.code IN ('J-MIG', 'J-TV') ON CONFLICT DO NOTHING;

WITH ins AS (INSERT INTO vi_bs_item_base (company_id, business_id, category, name, adjustment, basis, sort) VALUES
(7, 19, '经营资产', '经营投入资本（迁移，待按报表逐项归类）', 5129.48,
'原统一估值引擎的期初投入资本＝截至日归母权益 − 资产负债桥里按账面计的项目（原检查 V09 对账）。按 Greenwald 研究时改成逐个报表科目。', 1) RETURNING id)
INSERT INTO vi_lnk_bs_item_judgments (bs_item_id, judgment_id, "createdAt", "updatedAt") SELECT ins.id, (SELECT id FROM vi_judgment_base WHERE company_id = 7 AND code = 'J-MIG'), now(), now() FROM ins;

WITH ins AS (INSERT INTO vi_bs_item_base (company_id, scenario_id, category, name, adjustment, basis, sort) VALUES
(7, NULL, '其他索取权', '永续债（归母权益中的其他权益工具）', 90, '原 N1。永续债 90.0（亿元）。计在归母权益里，但属于债权人，扣除。', 10) RETURNING id)
INSERT INTO vi_lnk_bs_item_judgments (bs_item_id, judgment_id, "createdAt", "updatedAt") SELECT ins.id, (SELECT id FROM vi_judgment_base WHERE company_id = 7 AND code = 'J-MIG'), now(), now() FROM ins;

INSERT INTO vi_judgment_base (company_id, code, title, status, judgment, transmission, parameter, change_threshold)
VALUES (21, 'J-MIG', '三层估值的输入：迁移自统一估值引擎（待按 Greenwald 重新研究）', '已形成建议',
'2026-11-11 估值重构时从统一估值引擎搬来：盈利能力＝第一个完整年度（2027）的收入、正常化经营利润率（没填时取当年利润率）、税率、归母比例；增长＝原永续增长率与终值新增投资回报率（原来留空＝门槛 6%），优势年限留空＝永续，与原终值口径一致；经营资本＝原期初投入资本（归母权益减资产负债桥账面项），还没有按资产负债表逐项归类；资产负债桥＝原资产估值与调整里单独计价的项目。原逐年预测（明确期现金流）不再使用，所以含增长价值与原全价值不同。',
'盈利能力价值＝E÷门槛；含增长价值按增长率、新增投资回报率、优势年限；股权价值＝业务价值＋资产负债桥。',
'盈利能力、增长、资产负债重估', '按 Greenwald 重新研究这家公司时逐项替换（正常化利润率、维持性资本开支、资产负债表逐项归类、优势年限）。')
ON CONFLICT (company_id, code) DO UPDATE SET judgment = EXCLUDED.judgment;

INSERT INTO vi_epv_base (company_id, business_id, scenario_id, revenue, margin, tax_rate, attrib, note) VALUES (21, 35, 131, 3175, 0.05176, 0.17, 1, '迁移：2027 年经营利润率，2027 年收入（统一估值引擎）');

INSERT INTO vi_lnk_epv_judgments (epv_id, judgment_id, "createdAt", "updatedAt") SELECT x.id, j.id, now(), now() FROM (SELECT id FROM vi_epv_base WHERE business_id = 35 AND scenario_id = 131) x JOIN vi_judgment_base j ON j.company_id = 21 AND j.code IN ('J-AIOT', 'J-MIG', 'J-NET', 'J-OPEX', 'J-PHONE') ON CONFLICT DO NOTHING;

INSERT INTO vi_growth_base (company_id, business_id, scenario_id, growth, ronic, note) VALUES (21, 35, 131, 0.015, 0.12, '迁移：原永续增长率与终值新增投资回报率');

INSERT INTO vi_lnk_growth_judgments (growth_id, judgment_id, "createdAt", "updatedAt") SELECT x.id, j.id, now(), now() FROM (SELECT id FROM vi_growth_base WHERE business_id = 35 AND scenario_id = 131) x JOIN vi_judgment_base j ON j.company_id = 21 AND j.code IN ('J-MIG', 'J-MULT') ON CONFLICT DO NOTHING;

INSERT INTO vi_epv_base (company_id, business_id, scenario_id, revenue, margin, tax_rate, attrib, note) VALUES (21, 35, 132, 3415, 0.070962, 0.17, 1, '迁移：2027 年经营利润率，2027 年收入（统一估值引擎）');

INSERT INTO vi_lnk_epv_judgments (epv_id, judgment_id, "createdAt", "updatedAt") SELECT x.id, j.id, now(), now() FROM (SELECT id FROM vi_epv_base WHERE business_id = 35 AND scenario_id = 132) x JOIN vi_judgment_base j ON j.company_id = 21 AND j.code IN ('J-AIOT', 'J-MIG', 'J-NET', 'J-OPEX', 'J-PHONE') ON CONFLICT DO NOTHING;

INSERT INTO vi_growth_base (company_id, business_id, scenario_id, growth, ronic, note) VALUES (21, 35, 132, 0.03, 0.2, '迁移：原永续增长率与终值新增投资回报率');

INSERT INTO vi_lnk_growth_judgments (growth_id, judgment_id, "createdAt", "updatedAt") SELECT x.id, j.id, now(), now() FROM (SELECT id FROM vi_growth_base WHERE business_id = 35 AND scenario_id = 132) x JOIN vi_judgment_base j ON j.company_id = 21 AND j.code IN ('J-MIG', 'J-MULT') ON CONFLICT DO NOTHING;

INSERT INTO vi_epv_base (company_id, business_id, scenario_id, revenue, margin, tax_rate, attrib, note) VALUES (21, 35, 133, 3605, 0.090181, 0.17, 1, '迁移：2027 年经营利润率，2027 年收入（统一估值引擎）');

INSERT INTO vi_lnk_epv_judgments (epv_id, judgment_id, "createdAt", "updatedAt") SELECT x.id, j.id, now(), now() FROM (SELECT id FROM vi_epv_base WHERE business_id = 35 AND scenario_id = 133) x JOIN vi_judgment_base j ON j.company_id = 21 AND j.code IN ('J-AIOT', 'J-MIG', 'J-NET', 'J-OPEX', 'J-PHONE') ON CONFLICT DO NOTHING;

INSERT INTO vi_growth_base (company_id, business_id, scenario_id, growth, ronic, note) VALUES (21, 35, 133, 0.035, 0.25, '迁移：原永续增长率与终值新增投资回报率');

INSERT INTO vi_lnk_growth_judgments (growth_id, judgment_id, "createdAt", "updatedAt") SELECT x.id, j.id, now(), now() FROM (SELECT id FROM vi_growth_base WHERE business_id = 35 AND scenario_id = 133) x JOIN vi_judgment_base j ON j.company_id = 21 AND j.code IN ('J-MIG', 'J-MULT') ON CONFLICT DO NOTHING;

INSERT INTO vi_epv_base (company_id, business_id, scenario_id, revenue, margin, tax_rate, attrib, note) VALUES (21, 4, 131, 1166.88, 0.04, 0.17, 1, '迁移：2027 年经营利润率，2027 年收入（统一估值引擎）');

INSERT INTO vi_lnk_epv_judgments (epv_id, judgment_id, "createdAt", "updatedAt") SELECT x.id, j.id, now(), now() FROM (SELECT id FROM vi_epv_base WHERE business_id = 4 AND scenario_id = 131) x JOIN vi_judgment_base j ON j.company_id = 21 AND j.code IN ('J-EV', 'J-MIG') ON CONFLICT DO NOTHING;

INSERT INTO vi_growth_base (company_id, business_id, scenario_id, growth, ronic, note) VALUES (21, 4, 131, 0.015, 0.12, '迁移：原永续增长率与终值新增投资回报率');

INSERT INTO vi_lnk_growth_judgments (growth_id, judgment_id, "createdAt", "updatedAt") SELECT x.id, j.id, now(), now() FROM (SELECT id FROM vi_growth_base WHERE business_id = 4 AND scenario_id = 131) x JOIN vi_judgment_base j ON j.company_id = 21 AND j.code IN ('J-EV', 'J-MIG') ON CONFLICT DO NOTHING;

INSERT INTO vi_epv_base (company_id, business_id, scenario_id, revenue, margin, tax_rate, attrib, note) VALUES (21, 4, 132, 1468.78, 0.075, 0.17, 1, '迁移：2027 年经营利润率，2027 年收入（统一估值引擎）');

INSERT INTO vi_lnk_epv_judgments (epv_id, judgment_id, "createdAt", "updatedAt") SELECT x.id, j.id, now(), now() FROM (SELECT id FROM vi_epv_base WHERE business_id = 4 AND scenario_id = 132) x JOIN vi_judgment_base j ON j.company_id = 21 AND j.code IN ('J-EV', 'J-MIG') ON CONFLICT DO NOTHING;

INSERT INTO vi_growth_base (company_id, business_id, scenario_id, growth, ronic, note) VALUES (21, 4, 132, 0.03, 0.2, '迁移：原永续增长率与终值新增投资回报率');

INSERT INTO vi_lnk_growth_judgments (growth_id, judgment_id, "createdAt", "updatedAt") SELECT x.id, j.id, now(), now() FROM (SELECT id FROM vi_growth_base WHERE business_id = 4 AND scenario_id = 132) x JOIN vi_judgment_base j ON j.company_id = 21 AND j.code IN ('J-EV', 'J-MIG') ON CONFLICT DO NOTHING;

INSERT INTO vi_epv_base (company_id, business_id, scenario_id, revenue, margin, tax_rate, attrib, note) VALUES (21, 4, 133, 1872, 0.09, 0.17, 1, '迁移：2027 年经营利润率，2027 年收入（统一估值引擎）');

INSERT INTO vi_lnk_epv_judgments (epv_id, judgment_id, "createdAt", "updatedAt") SELECT x.id, j.id, now(), now() FROM (SELECT id FROM vi_epv_base WHERE business_id = 4 AND scenario_id = 133) x JOIN vi_judgment_base j ON j.company_id = 21 AND j.code IN ('J-EV', 'J-MIG') ON CONFLICT DO NOTHING;

INSERT INTO vi_growth_base (company_id, business_id, scenario_id, growth, ronic, note) VALUES (21, 4, 133, 0.035, 0.25, '迁移：原永续增长率与终值新增投资回报率');

INSERT INTO vi_lnk_growth_judgments (growth_id, judgment_id, "createdAt", "updatedAt") SELECT x.id, j.id, now(), now() FROM (SELECT id FROM vi_growth_base WHERE business_id = 4 AND scenario_id = 133) x JOIN vi_judgment_base j ON j.company_id = 21 AND j.code IN ('J-EV', 'J-MIG') ON CONFLICT DO NOTHING;

WITH ins AS (INSERT INTO vi_bs_item_base (company_id, business_id, category, name, adjustment, basis, sort) VALUES
(21, 35, '经营资产', '经营投入资本（迁移，待按报表逐项归类）', 420.31,
'原统一估值引擎的期初投入资本＝截至日归母权益 − 资产负债桥里按账面计的项目（原检查 V09 对账）。按 Greenwald 研究时改成逐个报表科目。', 1) RETURNING id)
INSERT INTO vi_lnk_bs_item_judgments (bs_item_id, judgment_id, "createdAt", "updatedAt") SELECT ins.id, (SELECT id FROM vi_judgment_base WHERE company_id = 21 AND code = 'J-MIG'), now(), now() FROM ins;

WITH ins AS (INSERT INTO vi_bs_item_base (company_id, business_id, category, name, adjustment, basis, sort) VALUES
(21, 4, '经营资产', '经营投入资本（迁移，待按报表逐项归类）', 311.78,
'原统一估值引擎的期初投入资本＝截至日归母权益 − 资产负债桥里按账面计的项目（原检查 V09 对账）。按 Greenwald 研究时改成逐个报表科目。', 2) RETURNING id)
INSERT INTO vi_lnk_bs_item_judgments (bs_item_id, judgment_id, "createdAt", "updatedAt") SELECT ins.id, (SELECT id FROM vi_judgment_base WHERE company_id = 21 AND code = 'J-MIG'), now(), now() FROM ins;

WITH ins AS (INSERT INTO vi_bs_item_base (company_id, category, name, adjustment, basis, sort) VALUES
(21, '参照估值', 'AI、芯片与机器人（直接估值）', 1000,
'原统一估值引擎“直接估值”：按可比公司或主观判断给出的整体价值，不自己建模（Greenwald 第四个模块：参照）。', 50) RETURNING id)
INSERT INTO vi_lnk_bs_item_judgments (bs_item_id, judgment_id, "createdAt", "updatedAt")
SELECT ins.id, j.id, now(), now() FROM ins JOIN vi_judgment_base j ON j.company_id = 21
 AND (j.code = 'J-MIG' OR j.id IN (SELECT judgment_id FROM vi_assumption_base WHERE business_id = 5 AND judgment_id IS NOT NULL));

WITH ins AS (INSERT INTO vi_bs_item_base (company_id, scenario_id, category, name, adjustment, basis, sort) VALUES
(21, NULL, '现金与投资', '现金储备（公司口径）', 2193, '原 C1。现金及现金等价物、受限制现金、定期存款、短期投资、按摊余成本计量的长期投资与理财投资。明细加总 2,274.7 亿元，比公司口径多 81.7 亿元，估值取较低的公司口径。', 10) RETURNING id)
INSERT INTO vi_lnk_bs_item_judgments (bs_item_id, judgment_id, "createdAt", "updatedAt") SELECT ins.id, (SELECT id FROM vi_judgment_base WHERE company_id = 21 AND code = 'J-MIG'), now(), now() FROM ins;

WITH ins AS (INSERT INTO vi_bs_item_base (company_id, scenario_id, category, name, adjustment, basis, sort) VALUES
(21, NULL, '其他索取权', '少数股东权益', 1.1949, '原 C10。6 月末账面价值。', 11) RETURNING id)
INSERT INTO vi_lnk_bs_item_judgments (bs_item_id, judgment_id, "createdAt", "updatedAt") SELECT ins.id, (SELECT id FROM vi_judgment_base WHERE company_id = 21 AND code = 'J-MIG'), now(), now() FROM ins;

WITH ins AS (INSERT INTO vi_bs_item_base (company_id, scenario_id, category, name, adjustment, basis, sort) VALUES
(21, 131, '参照估值', '政府补助（常态部分，资本化）', 24.9, '原 C11，悲观情景。每年 5 亿元×(1−17%)×6 倍；补贴不放进三块业务的利润率，避免和业务倍数混用。', 12) RETURNING id)
INSERT INTO vi_lnk_bs_item_judgments (bs_item_id, judgment_id, "createdAt", "updatedAt") SELECT ins.id, (SELECT id FROM vi_judgment_base WHERE company_id = 21 AND code = 'J-MIG'), now(), now() FROM ins;

WITH ins AS (INSERT INTO vi_bs_item_base (company_id, scenario_id, category, name, adjustment, basis, sort) VALUES
(21, 132, '参照估值', '政府补助（常态部分，资本化）', 99.6, '原 C11，基准情景。每年 15 亿元×(1−17%)×8 倍；补贴不放进三块业务的利润率，避免和业务倍数混用。', 13) RETURNING id)
INSERT INTO vi_lnk_bs_item_judgments (bs_item_id, judgment_id, "createdAt", "updatedAt") SELECT ins.id, (SELECT id FROM vi_judgment_base WHERE company_id = 21 AND code = 'J-MIG'), now(), now() FROM ins;

WITH ins AS (INSERT INTO vi_bs_item_base (company_id, scenario_id, category, name, adjustment, basis, sort) VALUES
(21, 133, '参照估值', '政府补助（常态部分，资本化）', 207.5, '原 C11，乐观情景。每年 25 亿元×(1−17%)×10 倍；补贴不放进三块业务的利润率，避免和业务倍数混用。', 14) RETURNING id)
INSERT INTO vi_lnk_bs_item_judgments (bs_item_id, judgment_id, "createdAt", "updatedAt") SELECT ins.id, (SELECT id FROM vi_judgment_base WHERE company_id = 21 AND code = 'J-MIG'), now(), now() FROM ins;

WITH ins AS (INSERT INTO vi_bs_item_base (company_id, scenario_id, category, name, adjustment, basis, sort) VALUES
(21, NULL, '有息负债', '借款（含可换股债券 50.8 亿元）', 392.7676, '原 C2。非流动 295.70＋流动 97.06；可换股债券 2027 年到期，换股价远高于现价，按负债处理。', 15) RETURNING id)
INSERT INTO vi_lnk_bs_item_judgments (bs_item_id, judgment_id, "createdAt", "updatedAt") SELECT ins.id, (SELECT id FROM vi_judgment_base WHERE company_id = 21 AND code = 'J-MIG'), now(), now() FROM ins;

WITH ins AS (INSERT INTO vi_bs_item_base (company_id, scenario_id, category, name, adjustment, basis, sort) VALUES
(21, NULL, '有息负债', '租赁负债', 50.41, '原 C3。流动 16.01＋非流动 34.40；分部经营利润已扣使用权资产折旧、未扣租赁利息，所以租赁按负债扣除。', 16) RETURNING id)
INSERT INTO vi_lnk_bs_item_judgments (bs_item_id, judgment_id, "createdAt", "updatedAt") SELECT ins.id, (SELECT id FROM vi_judgment_base WHERE company_id = 21 AND code = 'J-MIG'), now(), now() FROM ins;

WITH ins AS (INSERT INTO vi_bs_item_base (company_id, scenario_id, category, name, adjustment, basis, sort) VALUES
(21, NULL, '有息负债', '购买无形资产应付款（递延对价）', 50.75, '原 C4。流动 15.20＋非流动 35.54，计息。', 17) RETURNING id)
INSERT INTO vi_lnk_bs_item_judgments (bs_item_id, judgment_id, "createdAt", "updatedAt") SELECT ins.id, (SELECT id FROM vi_judgment_base WHERE company_id = 21 AND code = 'J-MIG'), now(), now() FROM ins;

WITH ins AS (INSERT INTO vi_bs_item_base (company_id, scenario_id, category, name, adjustment, basis, sort) VALUES
(21, 131, '现金与投资', '经营所需现金（负营运资本大幅回流）', -600, '原 C5，悲观情景。出货与收入继续下滑时，应付账款（1,183 亿元）的浮存会被收回，按约两个月营业成本扣除。', 18) RETURNING id)
INSERT INTO vi_lnk_bs_item_judgments (bs_item_id, judgment_id, "createdAt", "updatedAt") SELECT ins.id, (SELECT id FROM vi_judgment_base WHERE company_id = 21 AND code = 'J-MIG'), now(), now() FROM ins;

WITH ins AS (INSERT INTO vi_bs_item_base (company_id, scenario_id, category, name, adjustment, basis, sort) VALUES
(21, 132, '现金与投资', '经营所需现金（约一个月营业成本）', -300, '原 C5，基准情景。2026 年营业成本约 3,500 亿元，一个月约 290 亿元。', 19) RETURNING id)
INSERT INTO vi_lnk_bs_item_judgments (bs_item_id, judgment_id, "createdAt", "updatedAt") SELECT ins.id, (SELECT id FROM vi_judgment_base WHERE company_id = 21 AND code = 'J-MIG'), now(), now() FROM ins;

WITH ins AS (INSERT INTO vi_bs_item_base (company_id, scenario_id, category, name, adjustment, basis, sort) VALUES
(21, 133, '现金与投资', '经营所需现金（半个月营业成本）', -150, '原 C5，乐观情景。业务增长时负营运资本持续存在，只保留最低周转。', 20) RETURNING id)
INSERT INTO vi_lnk_bs_item_judgments (bs_item_id, judgment_id, "createdAt", "updatedAt") SELECT ins.id, (SELECT id FROM vi_judgment_base WHERE company_id = 21 AND code = 'J-MIG'), now(), now() FROM ins;

WITH ins AS (INSERT INTO vi_bs_item_base (company_id, scenario_id, category, name, adjustment, basis, sort) VALUES
(21, 131, '其他索取权', '资金汇出成本（估算）', 70, '原 C6，悲观情景。约 700 亿元境内资金按 10% 预扣税汇出。', 21) RETURNING id)
INSERT INTO vi_lnk_bs_item_judgments (bs_item_id, judgment_id, "createdAt", "updatedAt") SELECT ins.id, (SELECT id FROM vi_judgment_base WHERE company_id = 21 AND code = 'J-MIG'), now(), now() FROM ins;

WITH ins AS (INSERT INTO vi_bs_item_base (company_id, scenario_id, category, name, adjustment, basis, sort) VALUES
(21, 132, '其他索取权', '资金汇出成本（估算）', 30, '原 C6，基准情景。约 600 亿元境内资金按 5% 协定税率汇出；年报未找到中国附属公司未分派利润附注，待核实（问题 Q04）。', 22) RETURNING id)
INSERT INTO vi_lnk_bs_item_judgments (bs_item_id, judgment_id, "createdAt", "updatedAt") SELECT ins.id, (SELECT id FROM vi_judgment_base WHERE company_id = 21 AND code = 'J-MIG'), now(), now() FROM ins;

WITH ins AS (INSERT INTO vi_bs_item_base (company_id, scenario_id, category, name, adjustment, basis, sort) VALUES
(21, 133, '其他索取权', '资金汇出成本（境外资金足够）', 0, '原 C6，乐观情景。境外有配售所得、美元债与海外业务利润，回购不需要汇出境内资金。', 23) RETURNING id)
INSERT INTO vi_lnk_bs_item_judgments (bs_item_id, judgment_id, "createdAt", "updatedAt") SELECT ins.id, (SELECT id FROM vi_judgment_base WHERE company_id = 21 AND code = 'J-MIG'), now(), now() FROM ins;

WITH ins AS (INSERT INTO vi_bs_item_base (company_id, scenario_id, category, name, adjustment, basis, sort) VALUES
(21, NULL, '其他索取权', '印度被冻结资金', 35.36, '原 C7。491.7 亿卢比受限，案件在听证阶段；视为不可用。', 24) RETURNING id)
INSERT INTO vi_lnk_bs_item_judgments (bs_item_id, judgment_id, "createdAt", "updatedAt") SELECT ins.id, (SELECT id FROM vi_judgment_base WHERE company_id = 21 AND code = 'J-MIG'), now(), now() FROM ins;

WITH ins AS (INSERT INTO vi_bs_item_base (company_id, scenario_id, category, name, adjustment, basis, sort) VALUES
(21, 133, '参照估值', '印度被冻结资金（假设解冻）', 0, '原 C7，乐观情景。乐观情景假设胜诉解冻。', 25) RETURNING id)
INSERT INTO vi_lnk_bs_item_judgments (bs_item_id, judgment_id, "createdAt", "updatedAt") SELECT ins.id, (SELECT id FROM vi_judgment_base WHERE company_id = 21 AND code = 'J-MIG'), now(), now() FROM ins;

WITH ins AS (INSERT INTO vi_bs_item_base (company_id, scenario_id, category, name, adjustment, basis, sort) VALUES
(21, 131, '现金与投资', '对外投资（折价 50%）', 360.345, '原 C8，账面 720.7 亿元打折 50%，悲观情景。权益法 66.15＋普通股 185.83（上市股权约 72）＋优先股 382.44＋其他投资 86.27；理财投资已在现金储备里。多为三级公允价值，按情景打折。', 26) RETURNING id)
INSERT INTO vi_lnk_bs_item_judgments (bs_item_id, judgment_id, "createdAt", "updatedAt") SELECT ins.id, (SELECT id FROM vi_judgment_base WHERE company_id = 21 AND code = 'J-MIG'), now(), now() FROM ins;

WITH ins AS (INSERT INTO vi_bs_item_base (company_id, scenario_id, category, name, adjustment, basis, sort) VALUES
(21, 132, '现金与投资', '对外投资（折价 30%）', 504.483, '原 C8，账面 720.7 亿元打折 30%，基准情景。权益法 66.15＋普通股 185.83（上市股权约 72）＋优先股 382.44＋其他投资 86.27；理财投资已在现金储备里。多为三级公允价值，按情景打折。', 27) RETURNING id)
INSERT INTO vi_lnk_bs_item_judgments (bs_item_id, judgment_id, "createdAt", "updatedAt") SELECT ins.id, (SELECT id FROM vi_judgment_base WHERE company_id = 21 AND code = 'J-MIG'), now(), now() FROM ins;

WITH ins AS (INSERT INTO vi_bs_item_base (company_id, scenario_id, category, name, adjustment, basis, sort) VALUES
(21, 133, '现金与投资', '对外投资（折价 15%）', 612.5865, '原 C8，账面 720.7 亿元打折 15%，乐观情景。权益法 66.15＋普通股 185.83（上市股权约 72）＋优先股 382.44＋其他投资 86.27；理财投资已在现金储备里。多为三级公允价值，按情景打折。', 28) RETURNING id)
INSERT INTO vi_lnk_bs_item_judgments (bs_item_id, judgment_id, "createdAt", "updatedAt") SELECT ins.id, (SELECT id FROM vi_judgment_base WHERE company_id = 21 AND code = 'J-MIG'), now(), now() FROM ins;

WITH ins AS (INSERT INTO vi_bs_item_base (company_id, scenario_id, category, name, adjustment, basis, sort) VALUES
(21, NULL, '其他索取权', '基金外部出资人份额（投资者负债）', 153.66, '原 C9。合并的产业基金里外部出资人的份额：非流动 142.32 亿元（中报）＋流动约 11.34 亿元（按 2025 年末估计）。对应的资产在 C8 里，所以全额扣除。', 29) RETURNING id)
INSERT INTO vi_lnk_bs_item_judgments (bs_item_id, judgment_id, "createdAt", "updatedAt") SELECT ins.id, (SELECT id FROM vi_judgment_base WHERE company_id = 21 AND code = 'J-MIG'), now(), now() FROM ins;

ALTER TABLE vi_judgment_base DROP COLUMN IF EXISTS affected_years;

DROP TABLE IF EXISTS vi_lnk_val_input_judgments, vi_val_input_base, vi_assumption_base, vi_line_base,
  vi_trial_base, vi_fin_forecast_base, vi_forecast_base, vi_sotp_segment_base, vi_sotp_item_base, vi_model_base CASCADE;
DO $$ DECLARE r record; BEGIN
  FOR r IN SELECT tablename AS n FROM pg_tables WHERE schemaname = 'public'
            AND tablename ~ '^vi_lnk_(forecast|trial|sotp_item|sotp_segment|assumption|line|val_input|model)_' LOOP
    EXECUTE 'DROP TABLE IF EXISTS ' || r.n || ' CASCADE'; END LOOP;
END $$;
DROP FUNCTION IF EXISTS vi_pv(double precision[], double precision[], double precision, double precision, double precision, double precision) CASCADE;
DROP FUNCTION IF EXISTS vi_irr(double precision[], double precision[], double precision, double precision, double precision, double precision) CASCADE;
DO $$ DECLARE r record; BEGIN
  FOR r IN SELECT p.oid::regprocedure AS f FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
            WHERE n.nspname = 'public' AND p.proname IN ('vi_pv', 'vi_irr', 'vi_ve_pv', 'vi_ve_irr', 'vi_gw_guard') LOOP
    EXECUTE 'DROP FUNCTION IF EXISTS ' || r.f || ' CASCADE'; END LOOP;
END $$;

-- 业务身份的公司归属：商业模式拆解、资产负债重估、盈利能力、增长里的业务与情景必须属于同一家公司。
CREATE OR REPLACE FUNCTION vi_business_scope_guard() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.business_id IS NOT NULL AND NOT EXISTS
     (SELECT 1 FROM vi_business_base WHERE id = NEW.business_id AND company_id = NEW.company_id) THEN
    RAISE EXCEPTION '业务必须属于当前公司';
  END IF;
  IF TG_TABLE_NAME = 'vi_biz_model_base' THEN RETURN NEW; END IF;
  IF NEW.scenario_id IS NOT NULL AND NOT EXISTS
     (SELECT 1 FROM vi_scenario_base WHERE id = NEW.scenario_id AND company_id = NEW.company_id) THEN
    RAISE EXCEPTION '情景必须属于当前公司';
  END IF;
  IF TG_TABLE_NAME IN ('vi_epv_base', 'vi_growth_base') THEN
    IF NEW.business_id IS NULL OR NEW.scenario_id IS NULL THEN RAISE EXCEPTION '必须选业务和情景'; END IF;
  ELSE
    IF NEW.category IS NULL OR NEW.category NOT IN ('经营资产', '经营负债', '现金与投资', '参照估值', '有息负债', '其他索取权') THEN
      RAISE EXCEPTION '请填写有效的类别';
    END IF;
    IF NEW.haircut IS NOT NULL AND (NEW.haircut < 0 OR NEW.haircut > 1) THEN RAISE EXCEPTION '折价必须在 0 到 1 之间'; END IF;
    IF NEW.scenario_id IS NOT NULL AND nullif(btrim(NEW.line_item), '') IS NOT NULL THEN
      RAISE EXCEPTION '情景专属行只能是研究调整：报表科目行对全部情景生效';
    END IF;
  END IF;
  RETURN NEW;
END $$;
DROP TRIGGER IF EXISTS vi_biz_model_business_scope ON vi_biz_model_base;
CREATE TRIGGER vi_biz_model_business_scope BEFORE INSERT OR UPDATE ON vi_biz_model_base
  FOR EACH ROW EXECUTE FUNCTION vi_business_scope_guard();
DROP TRIGGER IF EXISTS vi_bs_item_business_scope ON vi_bs_item_base;
CREATE TRIGGER vi_bs_item_business_scope BEFORE INSERT OR UPDATE ON vi_bs_item_base
  FOR EACH ROW EXECUTE FUNCTION vi_business_scope_guard();
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
       OR EXISTS (SELECT 1 FROM vi_bs_item_base WHERE business_id = OLD.id)
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

COMMIT;
