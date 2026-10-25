-- 经营影响标签与经营解读分开；清理界面中的迁移前缀。
-- 仅重建本接口视图，DROP 不带 CASCADE，遇到意外依赖时整个事务会停止。
BEGIN;
ALTER TABLE vi_period_data_base ADD COLUMN IF NOT EXISTS impact text DEFAULT '待判断';
ALTER TABLE vi_period_data_base ALTER COLUMN impact SET DEFAULT '待判断';
UPDATE vi_period_data_base SET impact = '待判断' WHERE impact IS NULL;
UPDATE vi_period_data_base SET assessment = regexp_replace(assessment, '^原来水评价：', '来水') WHERE assessment LIKE '原来水评价：%';
COMMENT ON COLUMN vi_period_data_base.impact IS '经营影响：结合比较基准与经营解读，判断这项数据对公司经营的影响。中性表示已有依据支持影响有限；待判断表示依据不足。（可选：利好、中性、利空、待判断）';
COMMENT ON COLUMN vi_period_data_base.assessment IS '经营解读：结合公司业务说明比较基准、变化原因及对利润或模型假设的影响；缺少依据时留空。';

DROP VIEW IF EXISTS vi_period_data;

CREATE VIEW vi_period_data AS
SELECT b.id,
       b.period,
       b.period_end,
       b.period_kind,
       b.line_item,
       b.value,
       b.unit,
       b.yoy,
       b.impact,
       b.assessment,
       b.summary,
       b.status,
       b.company_id,
       b.source_id,
       b.updated_at
FROM vi_period_data_base b;

COMMENT ON VIEW vi_period_data IS '定期经营数据（界面视图：输入列＋自动计算列）';

CREATE OR REPLACE FUNCTION vi_period_data_dml() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO vi_period_data_base (period, period_end, period_kind, line_item, value, unit, yoy, impact, assessment, summary, status, company_id, source_id) VALUES (NEW.period, NEW.period_end, NEW.period_kind, NEW.line_item, NEW.value, NEW.unit, NEW.yoy, COALESCE(NEW.impact, '待判断'), NEW.assessment, NEW.summary, NEW.status, NEW.company_id, NEW.source_id) RETURNING id INTO NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE vi_period_data_base SET period = NEW.period, period_end = NEW.period_end, period_kind = NEW.period_kind, line_item = NEW.line_item, value = NEW.value, unit = NEW.unit, yoy = NEW.yoy, impact = COALESCE(NEW.impact, '待判断'), assessment = NEW.assessment, summary = NEW.summary, status = NEW.status, company_id = NEW.company_id, source_id = NEW.source_id WHERE id = OLD.id;
    RETURN NEW;
  ELSE
    DELETE FROM vi_period_data_base WHERE id = OLD.id;
    RETURN OLD;
  END IF;
END $$;

CREATE TRIGGER vi_period_data_dml INSTEAD OF INSERT OR UPDATE OR DELETE ON vi_period_data FOR EACH ROW EXECUTE FUNCTION vi_period_data_dml();


COMMIT;
