-- 仅在隔离副本运行；所有变更在末尾回滚。
BEGIN;
CREATE FUNCTION pg_temp.assert_true(ok boolean, label text) RETURNS void LANGUAGE plpgsql AS $$
BEGIN IF ok IS DISTINCT FROM true THEN RAISE EXCEPTION '断言失败：%',label; END IF; END $$;
CREATE FUNCTION pg_temp.expect_error(statement text, expected text) RETURNS void LANGUAGE plpgsql AS $$
DECLARE caught boolean := false;
BEGIN
  BEGIN EXECUTE statement;
  EXCEPTION WHEN OTHERS THEN
    IF SQLERRM NOT LIKE '%'||expected||'%' THEN RAISE; END IF;
    caught := true;
  END;
  IF NOT caught THEN RAISE EXCEPTION '应该拒绝但没有拒绝：%',statement; END IF;
END $$;
CREATE TEMP TABLE original_totals AS SELECT * FROM vi_sotp;
CREATE TEMP TABLE xm AS SELECT m.id model_id,m.company_id,s.id scenario_id,
 (SELECT id FROM vi_business_base WHERE company_id=m.company_id AND code='S4') business_id
 FROM vi_model_base m JOIN vi_company_base c ON c.id=m.company_id
 JOIN vi_scenario_base s ON s.model_id=m.id AND s.is_base WHERE c.code='01810.HK';

SELECT pg_temp.assert_true((SELECT count(*)=5 FROM vi_business_base WHERE company_id=(SELECT company_id FROM xm)),'五个业务身份');
SELECT pg_temp.assert_true((SELECT count(*)=54 FROM vi_biz_model_base WHERE company_id=(SELECT company_id FROM xm)),'集团九项＋五块业务各九项');
SELECT pg_temp.assert_true((SELECT count(*)=15 AND count(business_id)=15 FROM vi_sotp_segment_base WHERE model_id=(SELECT model_id FROM xm)),'三情景均连接业务身份');
SELECT pg_temp.assert_true((SELECT count(*)=5 AND sum(signed_value)=0 AND count(amount)=0 FROM vi_sotp_item WHERE model_id=(SELECT model_id FROM xm) AND treatment='已含业务估值'),'经营资产未知金额不冒充零，计入值为零');

INSERT INTO vi_sotp_item(model_id,code,name,kind,treatment,amount,haircut,boundary)
SELECT model_id,'TEST_FIXED','测试独立固定资产','固定资产','单独计价',100,.25,'已剔除对应业务的盈利、租金和处置收益' FROM xm;
SELECT pg_temp.assert_true((SELECT bool_and(abs(a.equity_value-b.equity_value-75)<1e-8) FROM vi_sotp a JOIN original_totals b USING(id) WHERE a.model_id=(SELECT model_id FROM xm)),'独立固定资产折后加计');
INSERT INTO vi_sotp_item(model_id,scenario_id,code,name,kind,treatment,amount,haircut,boundary)
SELECT model_id,scenario_id,'TEST_FIXED','测试基准覆盖','固定资产','单独计价',200,.10,'基准覆盖公共行，不重复加总' FROM xm;
SELECT pg_temp.assert_true((SELECT abs(a.equity_value-b.equity_value-180)<1e-8 FROM vi_sotp a JOIN original_totals b USING(id) WHERE a.id=(SELECT scenario_id FROM xm)),'资产情景专属行覆盖公共行');

UPDATE vi_sotp_item SET amount=NULL WHERE code='TEST_FIXED' AND scenario_id=(SELECT scenario_id FROM xm);
SELECT pg_temp.assert_true((SELECT equity_value IS NULL AND value_per_share IS NULL AND asset_value IS NULL AND asset_incomplete=1 FROM vi_sotp WHERE id=(SELECT scenario_id FROM xm)),'单独计价缺金额时阻止输出总值');
UPDATE vi_sotp_item SET treatment='已含业务估值',business_id=(SELECT business_id FROM xm),amount=9999 WHERE code='TEST_FIXED';
SELECT pg_temp.assert_true((SELECT bool_and(abs(a.equity_value-b.equity_value)<1e-8) FROM vi_sotp a JOIN original_totals b USING(id) WHERE a.model_id=(SELECT model_id FROM xm)),'已含业务价值不重复加计');
UPDATE vi_sotp_item SET treatment='不计价',amount=NULL WHERE code='TEST_FIXED';
SELECT pg_temp.assert_true((SELECT bool_and(abs(a.equity_value-b.equity_value)<1e-8) FROM vi_sotp a JOIN original_totals b USING(id) WHERE a.model_id=(SELECT model_id FROM xm)),'不计价项目未知金额不阻断');

SELECT pg_temp.expect_error(format('UPDATE vi_biz_model SET business_id=%s WHERE company_id<>%s AND id=(SELECT min(id) FROM vi_biz_model WHERE company_id<>%s)',business_id,company_id,company_id),'所属业务必须属于') FROM xm;
SELECT pg_temp.expect_error(format('UPDATE vi_sotp_item SET business_id=NULL,treatment=%L WHERE code=%L','已含业务估值','TEST_FIXED'),'必须关联具体业务');
SELECT pg_temp.expect_error('UPDATE vi_sotp_item SET boundary=NULL WHERE code=''TEST_FIXED''','必须说明计价边界');
SELECT pg_temp.expect_error('UPDATE vi_sotp_item SET haircut=1.1 WHERE code=''TEST_FIXED''','折价必须');
SELECT pg_temp.expect_error(format('UPDATE vi_sotp_item SET scenario_id=(SELECT min(id) FROM vi_scenario_base WHERE model_id<>%s) WHERE code=%L',model_id,'TEST_FIXED'),'适用情景必须属于') FROM xm;
SELECT pg_temp.expect_error('INSERT INTO vi_biz_model_base(company_id,code) SELECT company_id,code FROM vi_biz_model_base WHERE business_id IS NULL LIMIT 1','vi_biz_model_uniq');
SELECT pg_temp.expect_error(format('DELETE FROM vi_business WHERE id=%s',business_id),'业务仍被') FROM xm;

-- 公共业务行即便使用另一个编号，也仍按业务身份被情景专属行覆盖。
INSERT INTO vi_sotp_segment(model_id,business_id,code,name,method,direct_value)
SELECT model_id,business_id,'ALT_CODE','公共汽车估值','直接估值',200 FROM xm;
SELECT pg_temp.assert_true((SELECT bool_and(abs(a.equity_value-b.equity_value)<1e-8) FROM vi_sotp a JOIN original_totals b USING(id) WHERE a.model_id=(SELECT model_id FROM xm)),'分部按身份覆盖，不因编号变化重复');
DELETE FROM vi_sotp_segment WHERE model_id=(SELECT model_id FROM xm) AND business_id=(SELECT business_id FROM xm) AND scenario_id=(SELECT scenario_id FROM xm);
SELECT pg_temp.assert_true((SELECT count(*)=1 AND min(value)=200 FROM vi_sotp_segment_val WHERE scenario_id=(SELECT scenario_id FROM xm) AND business_id=(SELECT business_id FROM xm)),'缺少专属行时采用公共行');

-- 纯资产估值模型：无需虚构经营业务，也应有汇总。
INSERT INTO vi_model_base(company_id,name,status,primary_method,sotp_as_of,shares,base_year,terminal_year,rf,erp)
SELECT company_id,'TEST_ASSET_ONLY','归档','分部加总','2026-06-30',100,2025,2035,.02,.07 FROM xm;
INSERT INTO vi_scenario_base(model_id,name,is_base) SELECT id,'资产情景',true FROM vi_model_base WHERE name='TEST_ASSET_ONLY';
INSERT INTO vi_sotp_item(model_id,code,name,kind,treatment,amount,boundary)
SELECT id,'A_ONLY','独立资产','其他非经营资产','单独计价',300,'没有经营收益重复计价' FROM vi_model_base WHERE name='TEST_ASSET_ONLY';
SELECT pg_temp.assert_true((SELECT business_value=0 AND asset_value=300 AND equity_value=300 AND value_per_share=3 FROM vi_sotp WHERE model_name='TEST_ASSET_ONLY'),'纯资产模型可正确汇总');
SELECT '业务与资产计价边界测试全部通过' AS result;
ROLLBACK;
