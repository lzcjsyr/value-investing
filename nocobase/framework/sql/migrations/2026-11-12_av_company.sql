-- 2026-11-12：第一层资产价值改为全公司口径——资产负债重估不再挂业务（经营负债拆不开到业务）。
-- 经营资产＋经营负债＝全公司经营资本；资产价值口径、重建成本从业务搬到公司。
-- 执行顺序：本文件 → business_rules.sql → 02_calc.sql → 03_ui.sql → companies/01698_腾讯音乐/greenwald.sql

BEGIN;

DO $$ DECLARE r record; BEGIN
  FOR r IN SELECT viewname AS n FROM pg_views WHERE schemaname = 'public' AND viewname LIKE 'vi\_%' LOOP
    EXECUTE 'DROP VIEW IF EXISTS ' || r.n || ' CASCADE'; END LOOP;
END $$;

ALTER TABLE vi_company_base ADD COLUMN IF NOT EXISTS av_basis text DEFAULT '调整后净资产',
                            ADD COLUMN IF NOT EXISTS repro_cost double precision;

-- 每家公司取原来业务上的口径（多块业务时取第一块）
UPDATE vi_company_base co SET av_basis = coalesce(b.av_basis, '调整后净资产'), repro_cost = b.repro_cost
FROM (SELECT DISTINCT ON (company_id) company_id, av_basis, repro_cost FROM vi_business_base ORDER BY company_id, sort, id) b
WHERE b.company_id = co.id;

DROP TRIGGER IF EXISTS vi_bs_item_business_scope ON vi_bs_item_base;
ALTER TABLE vi_bs_item_base DROP COLUMN business_id CASCADE;
ALTER TABLE vi_business_base DROP COLUMN av_basis, DROP COLUMN repro_cost;

COMMIT;
