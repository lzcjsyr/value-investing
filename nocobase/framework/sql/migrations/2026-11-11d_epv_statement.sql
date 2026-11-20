-- 2026-11-11 晚：取消情景；第二层改为调整后利润表（一行一个项目）；其余四家估值清空（先只做腾讯音乐）。

-- 执行顺序：本文件 → 02_calc.sql → 03_ui.sql → companies/01698_腾讯音乐/greenwald.sql

BEGIN;

DO $$ DECLARE r record; BEGIN
  FOR r IN SELECT viewname AS n FROM pg_views WHERE schemaname = 'public' AND viewname LIKE 'vi\_%' LOOP
    EXECUTE 'DROP VIEW IF EXISTS ' || r.n || ' CASCADE'; END LOOP;
END $$;

-- 腾讯音乐只留基准情景的增长；其余四家的估值输入清空

DELETE FROM vi_growth_base g USING vi_scenario_base s WHERE s.id = g.scenario_id AND NOT coalesce(s.is_base, false);

DELETE FROM vi_growth_base WHERE company_id <> (SELECT id FROM vi_company_base WHERE code = '01698.HK');

DELETE FROM vi_bs_item_base WHERE company_id <> (SELECT id FROM vi_company_base WHERE code = '01698.HK') OR scenario_id IS NOT NULL;

ALTER TABLE vi_growth_base DROP COLUMN scenario_id CASCADE;

ALTER TABLE vi_growth_base DROP CONSTRAINT IF EXISTS vi_growth_uniq;

ALTER TABLE vi_growth_base ADD CONSTRAINT vi_growth_uniq UNIQUE (business_id);

ALTER TABLE vi_bs_item_base DROP COLUMN scenario_id CASCADE;

UPDATE vi_company_base SET value_layer = NULL, layer_reason = NULL WHERE code <> '01698.HK';

DELETE FROM vi_judgment_base WHERE code IN ('J-MIG', 'J-PROB');

-- 风险分析的估值处理：没有情景了

UPDATE vi_risk_base SET treatment = CASE treatment WHEN '已计入基准情景' THEN '已计入估值输入' WHEN '已计入悲观情景' THEN '未计入估值' WHEN '体现在折现率或门槛' THEN '体现在主估值层或门槛' ELSE treatment END;

DROP TABLE vi_lnk_epv_judgments, vi_epv_base CASCADE;

DROP TABLE vi_scenario_base CASCADE;

CREATE TABLE vi_epv_base (
  id bigserial PRIMARY KEY,
  sort integer,
  name text,
  section text,
  direction text,
  formula text,
  method text,
  value double precision,
  from_year integer,
  to_year integer,
  note text,
  company_id bigint,
  business_id bigint,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE vi_epv_base IS '调整后利润表：第二层：每块业务一张调整后利润表，一行一个项目，从报表利润一路算到可持续现金收益 E；引用【业务分部】【假设依据】【财务报表】；被【三层价值·业务】引用。收入 − 成本费用 ＝ 报表经营利润；± 税前调整 ＝ 调整后经营利润；− 所得税 ＝ 税后经营利润；± 税后调整（折旧摊销、维持性资本开支）；− 少数股东 ＝ E；盈利能力价值＝E÷门槛。每行的报表公式给出历年数，正常化值按取值方式算。';

COMMENT ON COLUMN vi_epv_base.sort IS '排序';

COMMENT ON COLUMN vi_epv_base.name IS '项目';

COMMENT ON COLUMN vi_epv_base.section IS '段落：收入相加、成本费用相减得报表经营利润；税前调整、税后调整按方向加减；所得税、少数股东按比率；不计入＝只作对照（如利息收入、投资收益，它们在资产负债桥里单独计价）（可选：收入、成本费用、税前调整、所得税、税后调整、少数股东、不计入）';

COMMENT ON COLUMN vi_epv_base.direction IS '方向：税前调整、税后调整用：加回还是扣除（可选：加、减）';

COMMENT ON COLUMN vi_epv_base.formula IS '报表公式：历年数从「财务报表」按公式算：科目相加减，如“营运支出”“购建固定资产 + 购建无形资产及其他资产”；同名科目在多张报表时写“现金流量表：科目”。留空＝没有历史数（研究调整）';

COMMENT ON COLUMN vi_epv_base.method IS '取值方式：正常化值怎么取：金额＝填数（亿元）；占收入比例＝比例×正常化收入；最新年度、滚动四季度＝报表公式的最近一年或最近四个季度；历史平均＝起止年份的平均金额；历史平均占收入＝起止年份占收入比例的平均×正常化收入（周期业务的正常化）；比率＝所得税、少数股东的比率（可选：金额、占收入比例、最新年度、滚动四季度、历史平均、历史平均占收入、比率）';

COMMENT ON COLUMN vi_epv_base.value IS '数值：金额（亿元）或比例、比率（小数）';

COMMENT ON COLUMN vi_epv_base.from_year IS '起始年：历史平均用';

COMMENT ON COLUMN vi_epv_base.to_year IS '结束年：历史平均用';

COMMENT ON COLUMN vi_epv_base.note IS '说明';

COMMENT ON COLUMN vi_epv_base.company_id IS '公司（关联 公司）';

COMMENT ON COLUMN vi_epv_base.business_id IS '业务（关联 业务分部）';

CREATE TRIGGER vi_epv_base_touch BEFORE UPDATE ON vi_epv_base FOR EACH ROW EXECUTE FUNCTION vi_touch_updated_at();

ALTER TABLE vi_epv_base ADD FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE SET NULL;

CREATE INDEX ON vi_epv_base (company_id);

ALTER TABLE vi_epv_base ADD FOREIGN KEY (business_id) REFERENCES vi_business_base(id) ON DELETE SET NULL;

CREATE INDEX ON vi_epv_base (business_id);

CREATE TABLE vi_lnk_epv_judgments (
  epv_id bigint NOT NULL REFERENCES vi_epv_base(id) ON DELETE CASCADE,
  judgment_id bigint NOT NULL REFERENCES vi_judgment_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (epv_id, judgment_id)
);

COMMENT ON TABLE vi_lnk_epv_judgments IS '调整后利润表 ↔ 假设依据（多对多）';

-- 业务身份的公司归属：商业模式拆解、资产负债重估、调整后利润表、增长里的业务必须属于同一家公司。
CREATE OR REPLACE FUNCTION vi_business_scope_guard() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.business_id IS NOT NULL AND NOT EXISTS
     (SELECT 1 FROM vi_business_base WHERE id = NEW.business_id AND company_id = NEW.company_id) THEN
    RAISE EXCEPTION '业务必须属于当前公司';
  END IF;
  IF TG_TABLE_NAME = 'vi_biz_model_base' THEN RETURN NEW; END IF;
  IF TG_TABLE_NAME IN ('vi_epv_base', 'vi_growth_base') THEN
    IF NEW.business_id IS NULL THEN RAISE EXCEPTION '必须选业务'; END IF;
  ELSE
    IF NEW.category IS NULL OR NEW.category NOT IN ('经营资产', '经营负债', '现金与投资', '参照估值', '有息负债', '其他索取权') THEN
      RAISE EXCEPTION '请填写有效的类别';
    END IF;
    IF NEW.haircut IS NOT NULL AND (NEW.haircut < 0 OR NEW.haircut > 1) THEN RAISE EXCEPTION '折价必须在 0 到 1 之间'; END IF;
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
