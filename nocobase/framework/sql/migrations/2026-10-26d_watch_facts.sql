BEGIN;
ALTER TABLE vi_watch_base ADD COLUMN fact_note text;
ALTER TABLE vi_watch_base ADD COLUMN fact_date date;
ALTER TABLE vi_watch_base ADD CONSTRAINT vi_watch_fact_pair CHECK ((nullif(btrim(fact_note),'') IS NULL) = (fact_date IS NULL));
CREATE OR REPLACE VIEW vi_watch_calc AS
-- 数值引用指标，定性记录手填；状态只反映事实更新时效。
SELECT w.id,
       CASE WHEN f.as_of IS NULL THEN '未记录' WHEN d.due < current_date THEN '待更新' ELSE '已更新' END AS state,
       l.v AS latest_value, f.period AS latest_period, f.as_of AS latest_date,
       NULL::float8 AS vs_baseline, d.due AS next_due,
       f.fact AS latest_fact, coalesce(nullif(f.period,''),f.as_of::text) AS fact_as_of
FROM vi_watch_base w
LEFT JOIN vi_metric_base m ON m.id=w.metric_id
LEFT JOIN LATERAL (
  SELECT CASE WHEN w.compare='同比' THEN b.yoy ELSE b.value END AS v,b.period,c.obs_date
  FROM vi_obs_current c JOIN vi_observation_base b ON b.id=c.id
  WHERE c.metric_id=w.metric_id AND (w.compare IS DISTINCT FROM '同比' OR b.yoy IS NOT NULL)
  ORDER BY c.obs_date DESC LIMIT 1
) l ON true
CROSS JOIN LATERAL (
  SELECT CASE WHEN nullif(btrim(w.fact_note),'') IS NOT NULL AND (l.obs_date IS NULL OR w.fact_date >= l.obs_date) THEN true ELSE false END AS manual
) pick
CROSS JOIN LATERAL (
 SELECT CASE WHEN pick.manual THEN w.fact_note WHEN l.v IS NOT NULL THEN
          CASE WHEN w.compare='同比' THEN '同比 '||vi_fmt(l.v*100,2)||'%'
               ELSE vi_fmt(l.v,4)||coalesce(' '||nullif(m.unit,''),'') END END AS fact,
        CASE WHEN pick.manual THEN w.fact_date ELSE l.obs_date END AS as_of,
        CASE WHEN pick.manual THEN w.fact_date::text ELSE l.period END AS period
) f
CROSS JOIN LATERAL (
 SELECT (f.as_of + CASE w.frequency WHEN '交易日' THEN interval '5 days' WHEN '周' THEN interval '12 days'
         WHEN '月' THEN interval '55 days' WHEN '季' THEN interval '4 months'
         WHEN '半年' THEN interval '10 months' WHEN '年' THEN interval '16 months' END)::date AS due
) d;
CREATE OR REPLACE VIEW vi_watch AS SELECT b.id,b.code,b.title,b.purpose,b.fetch_method,b.preferred_source,b.frequency,b.compare,b.baseline,b.lower,b.upper,b.trigger,b.action,b.company_id,b.metric_id,c.state,c.latest_value,c.latest_period,c.latest_date,c.vs_baseline,c.next_due,b.updated_at,b.fact_note,b.fact_date,c.latest_fact,c.fact_as_of FROM vi_watch_base b LEFT JOIN vi_watch_calc c ON c.id=b.id;
CREATE OR REPLACE FUNCTION vi_watch_dml() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO vi_watch_base (code, title, fact_note, fact_date, purpose, fetch_method, preferred_source, frequency, compare, baseline, lower, upper, trigger, action, company_id, metric_id) VALUES (NEW.code, NEW.title, NEW.fact_note, NEW.fact_date, NEW.purpose, NEW.fetch_method, NEW.preferred_source, NEW.frequency, COALESCE(NEW.compare, '数值'), NEW.baseline, NEW.lower, NEW.upper, NEW.trigger, NEW.action, NEW.company_id, NEW.metric_id) RETURNING id INTO NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE vi_watch_base SET code = NEW.code, title = NEW.title, fact_note = NEW.fact_note, fact_date = NEW.fact_date, purpose = NEW.purpose, fetch_method = NEW.fetch_method, preferred_source = NEW.preferred_source, frequency = NEW.frequency, compare = COALESCE(NEW.compare, '数值'), baseline = NEW.baseline, lower = NEW.lower, upper = NEW.upper, trigger = NEW.trigger, action = NEW.action, company_id = NEW.company_id, metric_id = NEW.metric_id WHERE id = OLD.id;
    RETURN NEW;
  ELSE
    DELETE FROM vi_watch_base WHERE id = OLD.id;
    RETURN OLD;
  END IF;
END $$;

SAVEPOINT watch_test;
UPDATE vi_watch_base SET fact_note='测试：公告披露案件进展',fact_date=current_date,frequency='不定期' WHERE id=(SELECT min(id) FROM vi_watch_base);
DO $$ BEGIN
 IF NOT EXISTS(SELECT 1 FROM vi_watch WHERE id=(SELECT min(id) FROM vi_watch_base) AND state='已更新' AND latest_fact='测试：公告披露案件进展' AND fact_as_of=current_date::text) THEN RAISE EXCEPTION '定性事实测试失败'; END IF;
END $$;
UPDATE vi_watch SET fact_date=current_date-1000,frequency='月',metric_id=NULL WHERE id=(SELECT min(id) FROM vi_watch_base);
DO $$ BEGIN
 IF NOT EXISTS(SELECT 1 FROM vi_watch WHERE id=(SELECT min(id) FROM vi_watch_base) AND state='待更新') THEN RAISE EXCEPTION '定性事实过期测试失败'; END IF;
 BEGIN
 UPDATE vi_watch SET fact_date=NULL WHERE id=(SELECT min(id) FROM vi_watch_base);
 RAISE EXCEPTION '缺少日期未被阻止';
 EXCEPTION WHEN check_violation THEN NULL;
 END;
END $$;
ROLLBACK TO SAVEPOINT watch_test;
COMMIT;
