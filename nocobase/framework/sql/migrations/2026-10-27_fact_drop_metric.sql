-- 重要事实只写文字、关联来源文档：取消“相关指标”（2026-10-27）。原 17 条关联存档在 checks/fact_metric_20261027/。
BEGIN;
DROP VIEW IF EXISTS vi_fact CASCADE;
ALTER TABLE vi_fact_base DROP COLUMN metric_id;
COMMIT;
