-- 跟踪事项关联来源文档：没有来源文档时必须手填数据来源（preferred_source）。
BEGIN;
ALTER TABLE vi_watch_base ADD COLUMN source_id bigint REFERENCES vi_source_base(id) ON DELETE SET NULL;
CREATE INDEX ON vi_watch_base (source_id);
COMMENT ON COLUMN vi_watch_base.source_id IS '来源文档（关联 来源文档）';
COMMENT ON COLUMN vi_watch_base.preferred_source IS '数据来源（手填）：没有关联来源文档时必填：具体到哪份公告、哪个报表科目或网址；已关联来源文档时可补充报表科目、页码等';
ALTER TABLE vi_watch_base ADD CONSTRAINT vi_watch_source_required CHECK (source_id IS NOT NULL OR nullif(btrim(preferred_source),'') IS NOT NULL);
CREATE OR REPLACE VIEW vi_watch AS SELECT b.id,b.code,b.title,b.purpose,b.fetch_method,b.preferred_source,b.frequency,b.compare,b.baseline,b.lower,b.upper,b.trigger,b.action,b.company_id,b.metric_id,c.state,c.latest_value,c.latest_period,c.latest_date,c.vs_baseline,c.next_due,b.updated_at,b.fact_note,b.fact_date,c.latest_fact,c.fact_as_of,b.source_id FROM vi_watch_base b LEFT JOIN vi_watch_calc c ON c.id=b.id;
CREATE OR REPLACE FUNCTION vi_watch_dml() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO vi_watch_base (code, title, fact_note, fact_date, purpose, fetch_method, preferred_source, frequency, compare, baseline, lower, upper, trigger, action, company_id, metric_id, source_id) VALUES (NEW.code, NEW.title, NEW.fact_note, NEW.fact_date, NEW.purpose, NEW.fetch_method, NEW.preferred_source, NEW.frequency, COALESCE(NEW.compare, '数值'), NEW.baseline, NEW.lower, NEW.upper, NEW.trigger, NEW.action, NEW.company_id, NEW.metric_id, NEW.source_id) RETURNING id INTO NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE vi_watch_base SET code = NEW.code, title = NEW.title, fact_note = NEW.fact_note, fact_date = NEW.fact_date, purpose = NEW.purpose, fetch_method = NEW.fetch_method, preferred_source = NEW.preferred_source, frequency = NEW.frequency, compare = COALESCE(NEW.compare, '数值'), baseline = NEW.baseline, lower = NEW.lower, upper = NEW.upper, trigger = NEW.trigger, action = NEW.action, company_id = NEW.company_id, metric_id = NEW.metric_id, source_id = NEW.source_id WHERE id = OLD.id;
    RETURN NEW;
  ELSE
    DELETE FROM vi_watch_base WHERE id = OLD.id;
    RETURN OLD;
  END IF;
END $$;

SAVEPOINT watch_source_test;
DO $$ DECLARE w bigint := (SELECT min(id) FROM vi_watch_base); s bigint := (SELECT min(id) FROM vi_source_base);
BEGIN
  UPDATE vi_watch SET source_id=s, preferred_source=NULL WHERE id=w;            -- 有来源文档：手填可空
  IF (SELECT source_id FROM vi_watch WHERE id=w) IS DISTINCT FROM s THEN RAISE EXCEPTION '来源文档未写入'; END IF;
  UPDATE vi_watch SET source_id=NULL, preferred_source='公司公告' WHERE id=w;  -- 无来源文档：手填即可
  BEGIN
    UPDATE vi_watch SET source_id=NULL, preferred_source='  ' WHERE id=w;
    RAISE EXCEPTION '两者都空未被阻止';
  EXCEPTION WHEN check_violation THEN NULL;
  END;
END $$;
ROLLBACK TO SAVEPOINT watch_source_test;
COMMIT;
