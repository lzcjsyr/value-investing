-- 经营数据并进“指标＋数据”（二）：搬数据、核对、删旧表。需要先执行 2026-10-25d_obs_columns.sql 和 02_calc.sql（vi_put_disclosed）。
-- 每行经营数据按 公司×项目×口径×单位 找到或新建一个“公司披露”指标，写进数据；经营影响、经营解读、披露摘要、处理状态、来源文档原样带过去。
-- 核对：行数、每家公司的数值合计、带解读的行数都一致才删旧表，否则整个事务回滚。
BEGIN;
DO $$
DECLARE r record; n_old int; n_new int; bad int;
BEGIN
  IF to_regclass('vi_period_data_base') IS NULL THEN RAISE NOTICE '经营数据表已不存在，跳过'; RETURN; END IF;
  FOR r IN SELECT * FROM vi_period_data_base ORDER BY company_id, id LOOP
    PERFORM vi_put_disclosed(r.company_id, r.line_item, r.period_kind, r.unit, r.period, r.period_end, r.value, r.yoy,
                             r.impact, r.assessment, r.summary, r.status, r.source_id);
  END LOOP;
  SELECT count(*) INTO n_old FROM vi_period_data_base;
  SELECT count(*) INTO n_new FROM vi_disclosed;
  IF n_old <> n_new THEN RAISE EXCEPTION '行数不一致：经营数据 % 行，搬过去 % 行', n_old, n_new; END IF;
  SELECT count(*) INTO bad FROM vi_period_data_base p
   WHERE NOT EXISTS (SELECT 1 FROM vi_disclosed d WHERE d.company_id = p.company_id AND d.line_item = p.line_item
                       AND d.period_kind IS NOT DISTINCT FROM p.period_kind AND d.unit IS NOT DISTINCT FROM p.unit
                       AND d.period IS NOT DISTINCT FROM p.period AND d.period_end IS NOT DISTINCT FROM p.period_end
                       AND d.value IS NOT DISTINCT FROM p.value AND d.yoy IS NOT DISTINCT FROM p.yoy
                       AND d.impact IS NOT DISTINCT FROM p.impact AND d.assessment IS NOT DISTINCT FROM p.assessment
                       AND d.summary IS NOT DISTINCT FROM p.summary AND d.status IS NOT DISTINCT FROM p.status
                       AND d.source_id IS NOT DISTINCT FROM p.source_id);
  IF bad > 0 THEN RAISE EXCEPTION '有 % 行在新表里找不到完全相同的记录', bad; END IF;
  RAISE NOTICE '经营数据 % 行已逐字段核对一致，删除旧表', n_old;
  DROP VIEW IF EXISTS vi_period_data CASCADE;
  DROP TABLE vi_period_data_base;
END $$;
COMMIT;
