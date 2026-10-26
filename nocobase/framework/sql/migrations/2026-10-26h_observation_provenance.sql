-- 自动生成：framework/migrate_provenance.py。执行前先删 NocoBase 里「数据」的 source、note 字段；执行后重跑 02、03。
BEGIN;
-- 1. 历史补数：每种出处一份来源文档，数据关联它
WITH s AS (INSERT INTO vi_source_base (company_id, title, source_type, publisher, url, reliability, verify_status, summary, limitations)
  VALUES (NULL, '10年国债到期收益率（中证口径）：Wind / 中证指数公司（2026 年历史数据）', '数据库取数', 'Wind / 中证指数公司', NULL, '三级·第三方数据', '待核验',
          '19 条历史数据（2026-08-25 至 2026-09-18）', '观察数据；水文不得直接外推全年电量；国债为中证口径，非中债，不自动改长期折现率') RETURNING id)
UPDATE vi_observation_base o SET doc_id = s.id FROM s
 WHERE o.raw_capture_id IS NULL AND o.source = 'Wind / 中证指数公司' AND o.note IS NOT DISTINCT FROM '观察数据；水文不得直接外推全年电量；国债为中证口径，非中债，不自动改长期折现率'
   AND o.metric_id IN (3);
WITH s AS (INSERT INTO vi_source_base (company_id, title, source_type, publisher, url, reliability, verify_status, summary, limitations)
  VALUES (NULL, '纸浆期货收盘价（Wind 活跃合约）：Wind 期货收盘价（活跃合约）（2021—2026 年历史数据）', '数据库取数', 'Wind EDB M0330982', NULL, '三级·第三方数据', '待核验',
          '1212 条历史数据（2021-10-21 至 2026-10-21）', '历史补数：Wind 期货收盘价（活跃合约）') RETURNING id)
UPDATE vi_observation_base o SET doc_id = s.id FROM s
 WHERE o.raw_capture_id IS NULL AND o.source = 'Wind EDB M0330982' AND o.note IS NOT DISTINCT FROM '历史补数：Wind 期货收盘价（活跃合约）'
   AND o.metric_id IN (9);
WITH s AS (INSERT INTO vi_source_base (company_id, title, source_type, publisher, url, reliability, verify_status, summary, limitations)
  VALUES (NULL, '港元兑人民币：腾讯外汇 K 线收盘价（2025—2026 年历史数据）', '数据库取数', NULL, 'https://web.ifzq.gtimg.cn/appstock/app/fqkline/get?param=whHKDCNY,day', '三级·第三方数据', '待核验',
          '263 条历史数据（2025-10-20 至 2026-10-22）', '历史补数：腾讯外汇 K 线收盘价') RETURNING id)
UPDATE vi_observation_base o SET doc_id = s.id FROM s
 WHERE o.raw_capture_id IS NULL AND o.source = 'https://web.ifzq.gtimg.cn/appstock/app/fqkline/get?param=whHKDCNY,day' AND o.note IS NOT DISTINCT FROM '历史补数：腾讯外汇 K 线收盘价'
   AND o.metric_id IN (29);
WITH s AS (INSERT INTO vi_source_base (company_id, title, source_type, publisher, url, reliability, verify_status, summary, limitations)
  VALUES (1, '三峡水库入库流量（Wind）、三峡水库水位（Wind）、向家坝水库入库流量（Wind）：Wind / 长江水文网（2026 年历史数据）', '数据库取数', 'Wind / 长江水文网', NULL, '三级·第三方数据', '待核验',
          '18 条历史数据（2026-08-27 至 2026-09-17）', '观察数据；水文不得直接外推全年电量；国债为中证口径，非中债，不自动改长期折现率') RETURNING id)
UPDATE vi_observation_base o SET doc_id = s.id FROM s
 WHERE o.raw_capture_id IS NULL AND o.source = 'Wind / 长江水文网' AND o.note IS NOT DISTINCT FROM '观察数据；水文不得直接外推全年电量；国债为中证口径，非中债，不自动改长期折现率'
   AND o.metric_id IN (5, 6, 7);
WITH s AS (INSERT INTO vi_source_base (company_id, title, source_type, publisher, url, reliability, verify_status, summary, limitations)
  VALUES (1, '长江电力收盘价：Wind 金融数据服务（2026 年历史数据）', '数据库取数', 'Wind 金融数据服务', NULL, '三级·第三方数据', '待核验',
          '1 条历史数据（2026-09-18 至 2026-09-18）', '独立市场观察；不得直接与2025年末条件估值作为现时买卖信号比较') RETURNING id)
UPDATE vi_observation_base o SET doc_id = s.id FROM s
 WHERE o.raw_capture_id IS NULL AND o.source = 'Wind 金融数据服务' AND o.note IS NOT DISTINCT FROM '独立市场观察；不得直接与2025年末条件估值作为现时买卖信号比较'
   AND o.metric_id IN (1);
WITH s AS (INSERT INTO vi_source_base (company_id, title, source_type, publisher, url, reliability, verify_status, summary, limitations)
  VALUES (2, '太阳纸业收盘价：腾讯 K 线收盘价（不复权）（2025—2026 年历史数据）', '数据库取数', NULL, 'https://web.ifzq.gtimg.cn/appstock/app/fqkline/get?param=sz002078,day（不复权日线）', '三级·第三方数据', '待核验',
          '244 条历史数据（2025-10-20 至 2026-10-21）', '历史补数：腾讯 K 线收盘价（不复权）') RETURNING id)
UPDATE vi_observation_base o SET doc_id = s.id FROM s
 WHERE o.raw_capture_id IS NULL AND o.source = 'https://web.ifzq.gtimg.cn/appstock/app/fqkline/get?param=sz002078,day（不复权日线）' AND o.note IS NOT DISTINCT FROM '历史补数：腾讯 K 线收盘价（不复权）'
   AND o.metric_id IN (8);
WITH s AS (INSERT INTO vi_source_base (company_id, title, source_type, publisher, url, reliability, verify_status, summary, limitations)
  VALUES (7, '中国建筑收盘价：腾讯 K 线收盘价（不复权）（2025—2026 年历史数据）', '数据库取数', NULL, 'https://web.ifzq.gtimg.cn/appstock/app/fqkline/get?param=sh601668,day（不复权日线）', '三级·第三方数据', '待核验',
          '245 条历史数据（2025-10-20 至 2026-10-22）', '历史补数：腾讯 K 线收盘价（不复权）') RETURNING id)
UPDATE vi_observation_base o SET doc_id = s.id FROM s
 WHERE o.raw_capture_id IS NULL AND o.source = 'https://web.ifzq.gtimg.cn/appstock/app/fqkline/get?param=sh601668,day（不复权日线）' AND o.note IS NOT DISTINCT FROM '历史补数：腾讯 K 线收盘价（不复权）'
   AND o.metric_id IN (23);
WITH s AS (INSERT INTO vi_source_base (company_id, title, source_type, publisher, url, reliability, verify_status, summary, limitations)
  VALUES (11, '腾讯音乐港股收盘价：腾讯 K 线收盘价（港元，不复权）（2025—2026 年历史数据）', '数据库取数', NULL, 'https://web.ifzq.gtimg.cn/appstock/app/fqkline/get?param=hk01698,day（不复权日线）', '三级·第三方数据', '待核验',
          '248 条历史数据（2025-10-20 至 2026-10-22）', '历史补数：腾讯 K 线收盘价（港元，不复权）') RETURNING id)
UPDATE vi_observation_base o SET doc_id = s.id FROM s
 WHERE o.raw_capture_id IS NULL AND o.source = 'https://web.ifzq.gtimg.cn/appstock/app/fqkline/get?param=hk01698,day（不复权日线）' AND o.note IS NOT DISTINCT FROM '历史补数：腾讯 K 线收盘价（港元，不复权）'
   AND o.metric_id IN (28);
WITH s AS (INSERT INTO vi_source_base (company_id, title, source_type, publisher, url, reliability, verify_status, summary, limitations)
  VALUES (21, '小米集团港股收盘价：腾讯 K 线收盘价（港元，不复权）（2025—2026 年历史数据）', '数据库取数', NULL, 'https://web.ifzq.gtimg.cn/appstock/app/fqkline/get?param=hk01810,day（不复权日线）', '三级·第三方数据', '待核验',
          '248 条历史数据（2025-10-20 至 2026-10-22）', '历史补数：腾讯 K 线收盘价（港元，不复权）') RETURNING id)
UPDATE vi_observation_base o SET doc_id = s.id FROM s
 WHERE o.raw_capture_id IS NULL AND o.source = 'https://web.ifzq.gtimg.cn/appstock/app/fqkline/get?param=hk01810,day（不复权日线）' AND o.note IS NOT DISTINCT FROM '历史补数：腾讯 K 线收盘价（港元，不复权）'
   AND o.metric_id IN (48);
-- 2. 只针对某个指标的使用限制写进指标说明
UPDATE vi_metric_base SET notes = CASE WHEN nullif(btrim(notes), '') IS NULL THEN '水文观察数据，不得直接外推全年电量。' ELSE notes || E'\n' || '水文观察数据，不得直接外推全年电量。' END WHERE id = 5;
UPDATE vi_metric_base SET notes = CASE WHEN nullif(btrim(notes), '') IS NULL THEN '水文观察数据，不得直接外推全年电量。' ELSE notes || E'\n' || '水文观察数据，不得直接外推全年电量。' END WHERE id = 6;
UPDATE vi_metric_base SET notes = CASE WHEN nullif(btrim(notes), '') IS NULL THEN '水文观察数据，不得直接外推全年电量。' ELSE notes || E'\n' || '水文观察数据，不得直接外推全年电量。' END WHERE id = 7;
-- 3. 删除逐行重复的列（自动采集的出处是原始采集记录）
DROP VIEW IF EXISTS vi_observation, vi_observation_calc, vi_obs_current CASCADE;
ALTER TABLE vi_observation_base DROP COLUMN source, DROP COLUMN note;
COMMIT;
