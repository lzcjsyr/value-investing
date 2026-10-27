-- 历史年度表取消（2026-10-26）：年度数值本来就来自指标，表里只剩口径说明与备注。
-- 1. 合并同一序列被拆开的指标；2. 年度备注转为重要事实，口径变化年份记在公司表；3. 删表（只读视图 vi_fin_history 由 02_calc.sql 重建）。
BEGIN;
-- 1. 腾讯音乐付费用户：年末值（亿人）并入季度指标（百万人），模型字段随之移过去
INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, yoy, summary, doc_id, collected_at)
SELECT 126, obs_date, period, basis, value * 100, yoy, summary, doc_id, collected_at FROM vi_observation_base WHERE metric_id = 255;
UPDATE vi_metric_base SET model_field = NULL WHERE id = 255;
DELETE FROM vi_metric_base WHERE id = 255;
UPDATE vi_metric_base SET model_field = 'volume' WHERE id = 126;
--    小米全球月活：“12 月”（百万人）并入季度指标；“年末，含手机与平板”（亿人）是同一组数换了单位，删除
UPDATE vi_observation_base SET metric_id = 156 WHERE metric_id = 160;
UPDATE vi_fact_base SET metric_id = 156 WHERE metric_id = 160;
UPDATE vi_metric_base SET model_field = NULL WHERE id = 272;
DELETE FROM vi_metric_base WHERE id IN (160, 272);
UPDATE vi_metric_base SET model_field = 'volume' WHERE id = 156;
-- 2. 口径变化年份（跨口径的相邻两年不算同比）；年度备注转为重要事实
ALTER TABLE vi_company_base ADD COLUMN scope_breaks text;
COMMENT ON COLUMN vi_company_base.scope_breaks IS '口径变化年份：并表范围或披露口径变化的年份（如 2016、2023），这些年与上一年不算同比';
UPDATE vi_company_base SET scope_breaks = '2016、2023' WHERE code = '600900.SH';
INSERT INTO vi_fact_base (company_id, title, category, statement, period, as_of, verify_status, source_id)
SELECT h.company_id, h.year || ' 年度数据口径与说明', '财务',
       concat_ws('；', CASE WHEN nullif(h.scope_note, '') IS NOT NULL AND h.scope_note <> '合并口径' THEN '口径：' || h.scope_note END, h.note),
       h.year::text, make_date(h.year, 12, 31), '待核验', h.source_id
FROM vi_fin_history_base h WHERE nullif(btrim(concat_ws('', h.note, h.scope_note)), '') IS NOT NULL;
-- 3. 删表（缓存与视图由 02、03 重建）
DROP MATERIALIZED VIEW IF EXISTS vi_fin_history_cache CASCADE;
DROP VIEW IF EXISTS vi_fin_history, vi_fin_history_calc, vi_fin_metric CASCADE;
DROP TABLE vi_fin_history_base CASCADE;
COMMIT;
