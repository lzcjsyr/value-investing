BEGIN;
-- 业务驱动与财务结果分域；合同额/合约销售额和 ARPPU 是业务，不能仅按金额单位判断。
CREATE OR REPLACE FUNCTION vi_disclosed_category(p_item text) RETURNS text LANGUAGE sql IMMUTABLE AS $$
SELECT CASE WHEN p_item = ANY(ARRAY['AIoT平台连接设备数（不含手机和平板）', '全球月活跃用户', '全球月活跃用户（12 月）', '单个付费用户月均收入（ARPPU）', '发电量', '在线音乐付费用户', '在线音乐月活跃用户', '地产合约销售额', '建筑业务新签合同额', '房屋建筑新开工面积', '拥有五件及以上AIoT设备的用户数', '新签合同总额', '智能手机ASP', '智能手机出货量', '汽车ASP', '汽车交付量', '浆纸销量（管理层口径）', '竞品月活：汽水音乐']) THEN '经营'
            WHEN p_item ~ '收入|利润|毛利|费用|开支|损益|现金|负债|借款|应收|应付|减值|回购|股息|收益' THEN '财务'
            ELSE '其他' END
$$;

CREATE OR REPLACE FUNCTION vi_put_disclosed(p_company bigint, p_item text, p_basis text, p_unit text, p_period text, p_end date,
                                            p_value double precision, p_yoy double precision, p_impact text, p_assessment text,
                                            p_summary text, p_status text, p_doc bigint) RETURNS bigint LANGUAGE plpgsql AS $$
DECLARE mid bigint; ccode text; n int; oid bigint;
BEGIN
  SELECT id INTO mid FROM vi_metric_base
   WHERE company_id = p_company AND source_kind = '公司披露' AND name = p_item AND basis IS NOT DISTINCT FROM p_basis
     AND unit IS NOT DISTINCT FROM p_unit
   ORDER BY id LIMIT 1;
  IF mid IS NULL THEN
    SELECT code INTO ccode FROM vi_company_base WHERE id = p_company;
    SELECT coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1 INTO n FROM vi_metric_base WHERE code LIKE ccode || '.D%';
    INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency)
    VALUES (ccode || '.D' || lpad(n::text, 3, '0'), p_item, p_unit, vi_disclosed_category(p_item), '公司披露', p_basis, p_company, '公司披露',
            CASE p_basis WHEN '单季' THEN '季' WHEN '半年累计' THEN '半年' WHEN '前三季度累计' THEN '年' WHEN '全年' THEN '年' END)
    RETURNING id INTO mid;
  END IF;
  DELETE FROM vi_observation_base WHERE metric_id = mid AND period IS NOT DISTINCT FROM p_period;
  INSERT INTO vi_observation_base (metric_id, obs_date, period, value, yoy, impact, assessment, summary, status, doc_id, collected_at)
  VALUES (mid, p_end, p_period, p_value, p_yoy, p_impact, p_assessment, p_summary, p_status, p_doc, now())
  RETURNING id INTO oid;
  RETURN oid;
END $$;
COMMIT;
