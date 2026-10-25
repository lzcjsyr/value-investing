-- 自动生成：gen_sql.py。界面视图（输入列 + 计算列）与写入触发器

BEGIN;

CREATE OR REPLACE VIEW cj_guide AS
SELECT b.id,
       b.topic,
       b.rules,
       b.scope,
       b.feishu_id
FROM cj_guide_base b;

CREATE OR REPLACE FUNCTION cj_guide_dml() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO cj_guide_base (topic, rules, scope) VALUES (NEW.topic, NEW.rules, NEW.scope) RETURNING id INTO NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE cj_guide_base SET topic = NEW.topic, rules = NEW.rules, scope = NEW.scope WHERE id = OLD.id;
    RETURN NEW;
  ELSE
    DELETE FROM cj_guide_base WHERE id = OLD.id;
    RETURN OLD;
  END IF;
END $$;

DROP TRIGGER IF EXISTS cj_guide_dml ON cj_guide;
CREATE TRIGGER cj_guide_dml INSTEAD OF INSERT OR UPDATE OR DELETE ON cj_guide FOR EACH ROW EXECUTE FUNCTION cj_guide_dml();

CREATE OR REPLACE VIEW cj_biz_model AS
SELECT b.id,
       b.proposition,
       b.company_code,
       b.earning_mechanism,
       b.moat_evidence,
       b.counter_view,
       b.financial_mapping,
       b.current_view,
       b.feishu_id
FROM cj_biz_model_base b;

CREATE OR REPLACE FUNCTION cj_biz_model_dml() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO cj_biz_model_base (proposition, company_code, earning_mechanism, moat_evidence, counter_view, financial_mapping, current_view) VALUES (NEW.proposition, NEW.company_code, NEW.earning_mechanism, NEW.moat_evidence, NEW.counter_view, NEW.financial_mapping, NEW.current_view) RETURNING id INTO NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE cj_biz_model_base SET proposition = NEW.proposition, company_code = NEW.company_code, earning_mechanism = NEW.earning_mechanism, moat_evidence = NEW.moat_evidence, counter_view = NEW.counter_view, financial_mapping = NEW.financial_mapping, current_view = NEW.current_view WHERE id = OLD.id;
    RETURN NEW;
  ELSE
    DELETE FROM cj_biz_model_base WHERE id = OLD.id;
    RETURN OLD;
  END IF;
END $$;

DROP TRIGGER IF EXISTS cj_biz_model_dml ON cj_biz_model;
CREATE TRIGGER cj_biz_model_dml INSTEAD OF INSERT OR UPDATE OR DELETE ON cj_biz_model FOR EACH ROW EXECUTE FUNCTION cj_biz_model_dml();

CREATE OR REPLACE VIEW cj_evidence AS
SELECT b.id,
       b.evidence_id,
       b.company_code,
       b.report_period,
       b.source_type,
       b.fact_text,
       b.source_link,
       b.published_date,
       b.fetched_date,
       b.verify_status,
       b.scope_limits,
       b.legacy_ref,
       b.feishu_id
FROM cj_evidence_base b;

CREATE OR REPLACE FUNCTION cj_evidence_dml() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO cj_evidence_base (evidence_id, company_code, report_period, source_type, fact_text, source_link, published_date, fetched_date, verify_status, scope_limits, legacy_ref) VALUES (NEW.evidence_id, NEW.company_code, NEW.report_period, NEW.source_type, NEW.fact_text, NEW.source_link, NEW.published_date, NEW.fetched_date, NEW.verify_status, NEW.scope_limits, NEW.legacy_ref) RETURNING id INTO NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE cj_evidence_base SET evidence_id = NEW.evidence_id, company_code = NEW.company_code, report_period = NEW.report_period, source_type = NEW.source_type, fact_text = NEW.fact_text, source_link = NEW.source_link, published_date = NEW.published_date, fetched_date = NEW.fetched_date, verify_status = NEW.verify_status, scope_limits = NEW.scope_limits, legacy_ref = NEW.legacy_ref WHERE id = OLD.id;
    RETURN NEW;
  ELSE
    DELETE FROM cj_evidence_base WHERE id = OLD.id;
    RETURN OLD;
  END IF;
END $$;

DROP TRIGGER IF EXISTS cj_evidence_dml ON cj_evidence;
CREATE TRIGGER cj_evidence_dml INSTEAD OF INSERT OR UPDATE OR DELETE ON cj_evidence FOR EACH ROW EXECUTE FUNCTION cj_evidence_dml();

CREATE OR REPLACE VIEW cj_fact_mapping AS
SELECT b.id,
       b.mapping_id,
       b.fact_layer,
       b.judgment,
       b.math_transmission,
       b.param_key,
       b.affected_years,
       b.change_threshold,
       b.no_change_condition,
       b.counter_evidence,
       b.judgment_status,
       b.feishu_id
FROM cj_fact_mapping_base b;

CREATE OR REPLACE FUNCTION cj_fact_mapping_dml() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO cj_fact_mapping_base (mapping_id, fact_layer, judgment, math_transmission, param_key, affected_years, change_threshold, no_change_condition, counter_evidence, judgment_status) VALUES (NEW.mapping_id, NEW.fact_layer, NEW.judgment, NEW.math_transmission, NEW.param_key, NEW.affected_years, NEW.change_threshold, NEW.no_change_condition, NEW.counter_evidence, NEW.judgment_status) RETURNING id INTO NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE cj_fact_mapping_base SET mapping_id = NEW.mapping_id, fact_layer = NEW.fact_layer, judgment = NEW.judgment, math_transmission = NEW.math_transmission, param_key = NEW.param_key, affected_years = NEW.affected_years, change_threshold = NEW.change_threshold, no_change_condition = NEW.no_change_condition, counter_evidence = NEW.counter_evidence, judgment_status = NEW.judgment_status WHERE id = OLD.id;
    RETURN NEW;
  ELSE
    DELETE FROM cj_fact_mapping_base WHERE id = OLD.id;
    RETURN OLD;
  END IF;
END $$;

DROP TRIGGER IF EXISTS cj_fact_mapping_dml ON cj_fact_mapping;
CREATE TRIGGER cj_fact_mapping_dml INSTEAD OF INSERT OR UPDATE OR DELETE ON cj_fact_mapping FOR EACH ROW EXECUTE FUNCTION cj_fact_mapping_dml();

CREATE OR REPLACE VIEW cj_scenario AS
SELECT b.id,
       b.scenario,
       b.company_code,
       b.volume_factor,
       b.price_factor,
       b.cash_cost_factor,
       b.discount_rate,
       b.terminal_growth,
       b.terminal_year,
       b.valuation_base_year,
       b.shares_yi,
       b.base_price,
       b.base_other_contrib,
       b.base_burden_rate,
       b.base_payout,
       b.base_rf_pct,
       b.base_erp_pct,
       b.rate_date,
       b.legacy_price,
       b.price_date,
       b.assumption_nature,
       b.publish_status,
       b.scenario_note,
       c.calc_base_discount_rate,
       c.eff_discount_rate,
       c.eff_terminal_year,
       c.eff_base_year,
       c.eff_shares_yi,
       c.eff_legacy_price,
       c.latest_price,
       c.latest_price_date,
       b.feishu_id
FROM cj_scenario_base b LEFT JOIN cj_scenario_calc c ON c.id = b.id;

CREATE OR REPLACE FUNCTION cj_scenario_dml() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO cj_scenario_base (scenario, company_code, volume_factor, price_factor, cash_cost_factor, discount_rate, terminal_growth, terminal_year, valuation_base_year, shares_yi, base_price, base_other_contrib, base_burden_rate, base_payout, base_rf_pct, base_erp_pct, rate_date, legacy_price, price_date, assumption_nature, publish_status, scenario_note) VALUES (NEW.scenario, NEW.company_code, NEW.volume_factor, NEW.price_factor, NEW.cash_cost_factor, NEW.discount_rate, NEW.terminal_growth, NEW.terminal_year, NEW.valuation_base_year, NEW.shares_yi, NEW.base_price, NEW.base_other_contrib, NEW.base_burden_rate, NEW.base_payout, NEW.base_rf_pct, NEW.base_erp_pct, NEW.rate_date, NEW.legacy_price, NEW.price_date, NEW.assumption_nature, NEW.publish_status, NEW.scenario_note) RETURNING id INTO NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE cj_scenario_base SET scenario = NEW.scenario, company_code = NEW.company_code, volume_factor = NEW.volume_factor, price_factor = NEW.price_factor, cash_cost_factor = NEW.cash_cost_factor, discount_rate = NEW.discount_rate, terminal_growth = NEW.terminal_growth, terminal_year = NEW.terminal_year, valuation_base_year = NEW.valuation_base_year, shares_yi = NEW.shares_yi, base_price = NEW.base_price, base_other_contrib = NEW.base_other_contrib, base_burden_rate = NEW.base_burden_rate, base_payout = NEW.base_payout, base_rf_pct = NEW.base_rf_pct, base_erp_pct = NEW.base_erp_pct, rate_date = NEW.rate_date, legacy_price = NEW.legacy_price, price_date = NEW.price_date, assumption_nature = NEW.assumption_nature, publish_status = NEW.publish_status, scenario_note = NEW.scenario_note WHERE id = OLD.id;
    RETURN NEW;
  ELSE
    DELETE FROM cj_scenario_base WHERE id = OLD.id;
    RETURN OLD;
  END IF;
END $$;

DROP TRIGGER IF EXISTS cj_scenario_dml ON cj_scenario;
CREATE TRIGGER cj_scenario_dml INSTEAD OF INSERT OR UPDATE OR DELETE ON cj_scenario FOR EACH ROW EXECUTE FUNCTION cj_scenario_dml();

CREATE OR REPLACE VIEW cj_annual AS
SELECT b.id,
       b.year_key,
       b.company_code,
       b.year,
       b.volume,
       b.price,
       b.cash_cost,
       b.depreciation,
       b.interest,
       b.other_contrib,
       b.burden_rate,
       b.payout,
       b.attrib_da_addback,
       b.noncash_gain_deduct,
       b.invest_cash_dividend,
       b.other_cash_adj,
       b.wc_increase,
       b.maint_capex,
       b.growth_capex,
       b.net_borrowing,
       b.min_cash_topup,
       b.cash_bridge_note,
       b.evidence_status,
       c.eff_price,
       c.eff_other_contrib,
       c.eff_burden_rate,
       c.eff_payout,
       c.cash_bridge_live_status,
       b.feishu_id
FROM cj_annual_base b LEFT JOIN cj_annual_calc c ON c.id = b.id;

CREATE OR REPLACE FUNCTION cj_annual_dml() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO cj_annual_base (year_key, company_code, year, volume, price, cash_cost, depreciation, interest, other_contrib, burden_rate, payout, attrib_da_addback, noncash_gain_deduct, invest_cash_dividend, other_cash_adj, wc_increase, maint_capex, growth_capex, net_borrowing, min_cash_topup, cash_bridge_note, evidence_status) VALUES (NEW.year_key, NEW.company_code, NEW.year, NEW.volume, NEW.price, NEW.cash_cost, NEW.depreciation, NEW.interest, NEW.other_contrib, NEW.burden_rate, NEW.payout, NEW.attrib_da_addback, NEW.noncash_gain_deduct, NEW.invest_cash_dividend, NEW.other_cash_adj, NEW.wc_increase, NEW.maint_capex, NEW.growth_capex, NEW.net_borrowing, NEW.min_cash_topup, NEW.cash_bridge_note, NEW.evidence_status) RETURNING id INTO NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE cj_annual_base SET year_key = NEW.year_key, company_code = NEW.company_code, year = NEW.year, volume = NEW.volume, price = NEW.price, cash_cost = NEW.cash_cost, depreciation = NEW.depreciation, interest = NEW.interest, other_contrib = NEW.other_contrib, burden_rate = NEW.burden_rate, payout = NEW.payout, attrib_da_addback = NEW.attrib_da_addback, noncash_gain_deduct = NEW.noncash_gain_deduct, invest_cash_dividend = NEW.invest_cash_dividend, other_cash_adj = NEW.other_cash_adj, wc_increase = NEW.wc_increase, maint_capex = NEW.maint_capex, growth_capex = NEW.growth_capex, net_borrowing = NEW.net_borrowing, min_cash_topup = NEW.min_cash_topup, cash_bridge_note = NEW.cash_bridge_note, evidence_status = NEW.evidence_status WHERE id = OLD.id;
    RETURN NEW;
  ELSE
    DELETE FROM cj_annual_base WHERE id = OLD.id;
    RETURN OLD;
  END IF;
END $$;

DROP TRIGGER IF EXISTS cj_annual_dml ON cj_annual;
CREATE TRIGGER cj_annual_dml INSTEAD OF INSERT OR UPDATE OR DELETE ON cj_annual FOR EACH ROW EXECUTE FUNCTION cj_annual_dml();

CREATE OR REPLACE VIEW cj_fin_calc AS
SELECT b.id,
       b.model_key,
       b.scenario_name,
       b.year,
       b.annual_input_id,
       b.scenario_input_id,
       c.volume,
       c.volume_factor,
       c.price,
       c.price_factor,
       c.revenue,
       c.cash_cost,
       c.cash_cost_factor,
       c.depreciation,
       c.interest,
       c.other_contrib,
       c.pretax_profit,
       c.burden_rate,
       c.np_proxy,
       c.payout,
       c.planned_div,
       c.discount_rate,
       c.base_year,
       c.discount_factor,
       c.planned_div_pv,
       c.terminal_year,
       c.terminal_growth,
       c.shares_yi,
       c.attrib_da_addback,
       c.noncash_gain_deduct,
       c.invest_cash_dividend,
       c.other_cash_adj,
       c.wc_increase,
       c.maint_capex,
       c.growth_capex,
       c.net_borrowing,
       c.min_cash_topup,
       c.cash_data_complete,
       c.owner_earnings,
       c.fcfe,
       c.fcfe_pv,
       c.cash_supported_div,
       c.cash_div_pv,
       c.funding_gap,
       c.calc_status,
       b.feishu_id
FROM cj_fin_calc_base b LEFT JOIN cj_fin_calc_calc c ON c.id = b.id;

CREATE OR REPLACE FUNCTION cj_fin_calc_dml() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO cj_fin_calc_base (model_key, scenario_name, year, annual_input_id, scenario_input_id) VALUES (NEW.model_key, NEW.scenario_name, NEW.year, NEW.annual_input_id, NEW.scenario_input_id) RETURNING id INTO NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE cj_fin_calc_base SET model_key = NEW.model_key, scenario_name = NEW.scenario_name, year = NEW.year, annual_input_id = NEW.annual_input_id, scenario_input_id = NEW.scenario_input_id WHERE id = OLD.id;
    RETURN NEW;
  ELSE
    DELETE FROM cj_fin_calc_base WHERE id = OLD.id;
    RETURN OLD;
  END IF;
END $$;

DROP TRIGGER IF EXISTS cj_fin_calc_dml ON cj_fin_calc;
CREATE TRIGGER cj_fin_calc_dml INSTEAD OF INSERT OR UPDATE OR DELETE ON cj_fin_calc FOR EACH ROW EXECUTE FUNCTION cj_fin_calc_dml();

CREATE OR REPLACE VIEW cj_valuation AS
SELECT b.id,
       b.scenario,
       b.usage_note,
       b.scenario_input_id,
       c.cond_ddm,
       c.cash_ddm,
       c.model_check,
       c.market_price,
       c.market_date,
       c.legacy_price,
       c.legacy_margin,
       c.watch_price_10,
       c.watch_price_30,
       c.forecast_pv,
       c.terminal_div,
       c.terminal_pv,
       c.terminal_share,
       c.discount_rate,
       c.terminal_growth,
       c.base_year,
       c.terminal_year,
       c.shares_yi,
       c.linked_rows,
       c.same_name_rows,
       c.terminal_rows,
       c.recon_diff,
       c.cash_complete_years,
       c.terminal_cash_div,
       c.decision_status,
       b.feishu_id
FROM cj_valuation_base b LEFT JOIN cj_valuation_calc c ON c.id = b.id;

CREATE OR REPLACE FUNCTION cj_valuation_dml() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO cj_valuation_base (scenario, usage_note, scenario_input_id) VALUES (NEW.scenario, NEW.usage_note, NEW.scenario_input_id) RETURNING id INTO NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE cj_valuation_base SET scenario = NEW.scenario, usage_note = NEW.usage_note, scenario_input_id = NEW.scenario_input_id WHERE id = OLD.id;
    RETURN NEW;
  ELSE
    DELETE FROM cj_valuation_base WHERE id = OLD.id;
    RETURN OLD;
  END IF;
END $$;

DROP TRIGGER IF EXISTS cj_valuation_dml ON cj_valuation;
CREATE TRIGGER cj_valuation_dml INSTEAD OF INSERT OR UPDATE OR DELETE ON cj_valuation FOR EACH ROW EXECUTE FUNCTION cj_valuation_dml();

CREATE OR REPLACE VIEW cj_sens_rg AS
SELECT b.id,
       b.combo,
       b.rate_shift,
       b.growth_shift,
       b.base_scenario_id,
       c.discount_rate,
       c.terminal_growth,
       c.cond_ddm,
       c.forecast_pv,
       c.terminal_div,
       c.shares_yi,
       c.base_year,
       c.terminal_year,
       c.nature,
       b.feishu_id
FROM cj_sens_rg_base b LEFT JOIN cj_sens_rg_calc c ON c.id = b.id;

CREATE OR REPLACE FUNCTION cj_sens_rg_dml() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO cj_sens_rg_base (combo, rate_shift, growth_shift, base_scenario_id) VALUES (NEW.combo, NEW.rate_shift, NEW.growth_shift, NEW.base_scenario_id) RETURNING id INTO NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE cj_sens_rg_base SET combo = NEW.combo, rate_shift = NEW.rate_shift, growth_shift = NEW.growth_shift, base_scenario_id = NEW.base_scenario_id WHERE id = OLD.id;
    RETURN NEW;
  ELSE
    DELETE FROM cj_sens_rg_base WHERE id = OLD.id;
    RETURN OLD;
  END IF;
END $$;

DROP TRIGGER IF EXISTS cj_sens_rg_dml ON cj_sens_rg;
CREATE TRIGGER cj_sens_rg_dml INSTEAD OF INSERT OR UPDATE OR DELETE ON cj_sens_rg FOR EACH ROW EXECUTE FUNCTION cj_sens_rg_dml();

CREATE OR REPLACE VIEW cj_param_trial AS
SELECT b.id,
       b.trial,
       b.start_year,
       b.end_year,
       b.volume_delta,
       b.price_delta,
       b.cash_cost_delta,
       b.da_delta,
       b.interest_delta,
       b.rate_delta,
       b.boundary,
       b.base_scenario_id,
       c.trial_value,
       c.base_value,
       c.value_change,
       c.change_pct,
       c.trial_rate,
       c.terminal_growth,
       c.shares_yi,
       c.base_year,
       c.terminal_year,
       c.trial_div_2026,
       c.trial_div_2027,
       c.trial_div_2028,
       c.trial_div_2029,
       c.trial_div_2030,
       c.trial_div_2031,
       c.trial_div_2032,
       c.trial_div_2033,
       c.trial_div_2034,
       c.trial_div_2035,
       b.feishu_id
FROM cj_param_trial_base b LEFT JOIN cj_param_trial_calc c ON c.id = b.id;

CREATE OR REPLACE FUNCTION cj_param_trial_dml() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO cj_param_trial_base (trial, start_year, end_year, volume_delta, price_delta, cash_cost_delta, da_delta, interest_delta, rate_delta, boundary, base_scenario_id) VALUES (NEW.trial, NEW.start_year, NEW.end_year, NEW.volume_delta, NEW.price_delta, NEW.cash_cost_delta, NEW.da_delta, NEW.interest_delta, NEW.rate_delta, NEW.boundary, NEW.base_scenario_id) RETURNING id INTO NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE cj_param_trial_base SET trial = NEW.trial, start_year = NEW.start_year, end_year = NEW.end_year, volume_delta = NEW.volume_delta, price_delta = NEW.price_delta, cash_cost_delta = NEW.cash_cost_delta, da_delta = NEW.da_delta, interest_delta = NEW.interest_delta, rate_delta = NEW.rate_delta, boundary = NEW.boundary, base_scenario_id = NEW.base_scenario_id WHERE id = OLD.id;
    RETURN NEW;
  ELSE
    DELETE FROM cj_param_trial_base WHERE id = OLD.id;
    RETURN OLD;
  END IF;
END $$;

DROP TRIGGER IF EXISTS cj_param_trial_dml ON cj_param_trial;
CREATE TRIGGER cj_param_trial_dml INSTEAD OF INSERT OR UPDATE OR DELETE ON cj_param_trial FOR EACH ROW EXECUTE FUNCTION cj_param_trial_dml();

CREATE OR REPLACE VIEW cj_tracking AS
SELECT b.id,
       b.task_id,
       b.metric,
       b.obs_code,
       b.frequency,
       b.preferred_source,
       b.trigger_threshold,
       b.threshold_nature,
       b.action_after,
       b.collect_status,
       b.latest_obs_note,
       b.obs_date_note,
       c.latest_value,
       c.latest_unit,
       c.latest_date,
       c.latest_metric,
       c.link_status,
       b.feishu_id
FROM cj_tracking_base b LEFT JOIN cj_tracking_calc c ON c.id = b.id;

CREATE OR REPLACE FUNCTION cj_tracking_dml() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO cj_tracking_base (task_id, metric, obs_code, frequency, preferred_source, trigger_threshold, threshold_nature, action_after, collect_status, latest_obs_note, obs_date_note) VALUES (NEW.task_id, NEW.metric, NEW.obs_code, NEW.frequency, NEW.preferred_source, NEW.trigger_threshold, NEW.threshold_nature, NEW.action_after, NEW.collect_status, NEW.latest_obs_note, NEW.obs_date_note) RETURNING id INTO NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE cj_tracking_base SET task_id = NEW.task_id, metric = NEW.metric, obs_code = NEW.obs_code, frequency = NEW.frequency, preferred_source = NEW.preferred_source, trigger_threshold = NEW.trigger_threshold, threshold_nature = NEW.threshold_nature, action_after = NEW.action_after, collect_status = NEW.collect_status, latest_obs_note = NEW.latest_obs_note, obs_date_note = NEW.obs_date_note WHERE id = OLD.id;
    RETURN NEW;
  ELSE
    DELETE FROM cj_tracking_base WHERE id = OLD.id;
    RETURN OLD;
  END IF;
END $$;

DROP TRIGGER IF EXISTS cj_tracking_dml ON cj_tracking;
CREATE TRIGGER cj_tracking_dml INSTEAD OF INSERT OR UPDATE OR DELETE ON cj_tracking FOR EACH ROW EXECUTE FUNCTION cj_tracking_dml();

CREATE OR REPLACE VIEW cj_market_obs AS
SELECT b.id,
       b.obs_id,
       b.metric_code,
       b.metric,
       b.obs_date,
       b.value,
       b.cloud_value_text,
       b.unit,
       b.source,
       b.collected_at,
       b.raw_file,
       b.usage_boundary,
       c.unified_value,
       c.quality_ok,
       c.is_current,
       c.current_valid_count,
       c.raw_count,
       c.source_check,
       b.feishu_id
FROM cj_market_obs_base b LEFT JOIN cj_market_obs_calc c ON c.id = b.id;

CREATE OR REPLACE FUNCTION cj_market_obs_dml() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO cj_market_obs_base (obs_id, metric_code, metric, obs_date, value, cloud_value_text, unit, source, collected_at, raw_file, usage_boundary) VALUES (NEW.obs_id, NEW.metric_code, NEW.metric, NEW.obs_date, NEW.value, NEW.cloud_value_text, NEW.unit, NEW.source, NEW.collected_at, NEW.raw_file, NEW.usage_boundary) RETURNING id INTO NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE cj_market_obs_base SET obs_id = NEW.obs_id, metric_code = NEW.metric_code, metric = NEW.metric, obs_date = NEW.obs_date, value = NEW.value, cloud_value_text = NEW.cloud_value_text, unit = NEW.unit, source = NEW.source, collected_at = NEW.collected_at, raw_file = NEW.raw_file, usage_boundary = NEW.usage_boundary WHERE id = OLD.id;
    RETURN NEW;
  ELSE
    DELETE FROM cj_market_obs_base WHERE id = OLD.id;
    RETURN OLD;
  END IF;
END $$;

DROP TRIGGER IF EXISTS cj_market_obs_dml ON cj_market_obs;
CREATE TRIGGER cj_market_obs_dml INSTEAD OF INSERT OR UPDATE OR DELETE ON cj_market_obs FOR EACH ROW EXECUTE FUNCTION cj_market_obs_dml();

CREATE OR REPLACE VIEW cj_quality AS
SELECT b.id,
       b.check_id,
       b.level,
       b.issue,
       b.impact_scope,
       b.done_condition,
       b.status,
       c.live_status,
       c.cash_bridge_check,
       c.price_date_check,
       c.model_row_check,
       c.negative_obs_check,
       b.feishu_id
FROM cj_quality_base b LEFT JOIN cj_quality_calc c ON c.id = b.id;

CREATE OR REPLACE FUNCTION cj_quality_dml() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO cj_quality_base (check_id, level, issue, impact_scope, done_condition, status) VALUES (NEW.check_id, NEW.level, NEW.issue, NEW.impact_scope, NEW.done_condition, NEW.status) RETURNING id INTO NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE cj_quality_base SET check_id = NEW.check_id, level = NEW.level, issue = NEW.issue, impact_scope = NEW.impact_scope, done_condition = NEW.done_condition, status = NEW.status WHERE id = OLD.id;
    RETURN NEW;
  ELSE
    DELETE FROM cj_quality_base WHERE id = OLD.id;
    RETURN OLD;
  END IF;
END $$;

DROP TRIGGER IF EXISTS cj_quality_dml ON cj_quality;
CREATE TRIGGER cj_quality_dml INSTEAD OF INSERT OR UPDATE OR DELETE ON cj_quality FOR EACH ROW EXECUTE FUNCTION cj_quality_dml();

CREATE OR REPLACE VIEW cj_change_log AS
SELECT b.id,
       b.change_id,
       b.time_text,
       b.target,
       b.old_value,
       b.new_value,
       b.reason,
       b.evidence_ref,
       b.verify_status,
       b.feishu_id
FROM cj_change_log_base b;

CREATE OR REPLACE FUNCTION cj_change_log_dml() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO cj_change_log_base (change_id, time_text, target, old_value, new_value, reason, evidence_ref, verify_status) VALUES (NEW.change_id, NEW.time_text, NEW.target, NEW.old_value, NEW.new_value, NEW.reason, NEW.evidence_ref, NEW.verify_status) RETURNING id INTO NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE cj_change_log_base SET change_id = NEW.change_id, time_text = NEW.time_text, target = NEW.target, old_value = NEW.old_value, new_value = NEW.new_value, reason = NEW.reason, evidence_ref = NEW.evidence_ref, verify_status = NEW.verify_status WHERE id = OLD.id;
    RETURN NEW;
  ELSE
    DELETE FROM cj_change_log_base WHERE id = OLD.id;
    RETURN OLD;
  END IF;
END $$;

DROP TRIGGER IF EXISTS cj_change_log_dml ON cj_change_log;
CREATE TRIGGER cj_change_log_dml INSTEAD OF INSERT OR UPDATE OR DELETE ON cj_change_log FOR EACH ROW EXECUTE FUNCTION cj_change_log_dml();

CREATE OR REPLACE VIEW cj_collect_ctl AS
SELECT b.id,
       b.metric_code,
       b.metric,
       b.integration_status,
       b.max_lag_days,
       b.source_note,
       b.workflow_entry,
       b.last_selfcheck,
       b.selfcheck_result,
       c.health_status,
       c.needs_alert,
       c.notify_condition,
       c.latest_collected_at,
       c.latest_obs_date,
       c.latest_run_result,
       b.feishu_id
FROM cj_collect_ctl_base b LEFT JOIN cj_collect_ctl_calc c ON c.id = b.id;

CREATE OR REPLACE FUNCTION cj_collect_ctl_dml() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO cj_collect_ctl_base (metric_code, metric, integration_status, max_lag_days, source_note, workflow_entry, last_selfcheck, selfcheck_result) VALUES (NEW.metric_code, NEW.metric, NEW.integration_status, NEW.max_lag_days, NEW.source_note, NEW.workflow_entry, NEW.last_selfcheck, NEW.selfcheck_result) RETURNING id INTO NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE cj_collect_ctl_base SET metric_code = NEW.metric_code, metric = NEW.metric, integration_status = NEW.integration_status, max_lag_days = NEW.max_lag_days, source_note = NEW.source_note, workflow_entry = NEW.workflow_entry, last_selfcheck = NEW.last_selfcheck, selfcheck_result = NEW.selfcheck_result WHERE id = OLD.id;
    RETURN NEW;
  ELSE
    DELETE FROM cj_collect_ctl_base WHERE id = OLD.id;
    RETURN OLD;
  END IF;
END $$;

DROP TRIGGER IF EXISTS cj_collect_ctl_dml ON cj_collect_ctl;
CREATE TRIGGER cj_collect_ctl_dml INSTEAD OF INSERT OR UPDATE OR DELETE ON cj_collect_ctl FOR EACH ROW EXECUTE FUNCTION cj_collect_ctl_dml();

CREATE OR REPLACE VIEW cj_collect_raw AS
SELECT b.id,
       b.run_id,
       b.metric_code,
       b.source_url,
       b.unit,
       b.collected_at,
       b.process_status,
       b.raw_response,
       c.raw_id,
       c.collected_at_text,
       c.date_v2,
       c.value_v2,
       c.obs_key_v2,
       c.valid_v2,
       c.existing_obs_count,
       c.allow_ingest,
       c.ingest_cmd,
       c.run_result,
       c.response_unescaped,
       c.cgb_data_row,
       c.sx_obj,
       c.date_candidate,
       c.obs_date_v1,
       c.value_candidate,
       b.feishu_id
FROM cj_collect_raw_base b LEFT JOIN cj_collect_raw_calc c ON c.id = b.id;

CREATE OR REPLACE FUNCTION cj_collect_raw_dml() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO cj_collect_raw_base (run_id, metric_code, source_url, unit, collected_at, process_status, raw_response) VALUES (NEW.run_id, NEW.metric_code, NEW.source_url, NEW.unit, NEW.collected_at, NEW.process_status, NEW.raw_response) RETURNING id INTO NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE cj_collect_raw_base SET run_id = NEW.run_id, metric_code = NEW.metric_code, source_url = NEW.source_url, unit = NEW.unit, collected_at = NEW.collected_at, process_status = NEW.process_status, raw_response = NEW.raw_response WHERE id = OLD.id;
    RETURN NEW;
  ELSE
    DELETE FROM cj_collect_raw_base WHERE id = OLD.id;
    RETURN OLD;
  END IF;
END $$;

DROP TRIGGER IF EXISTS cj_collect_raw_dml ON cj_collect_raw;
CREATE TRIGGER cj_collect_raw_dml INSTEAD OF INSERT OR UPDATE OR DELETE ON cj_collect_raw FOR EACH ROW EXECUTE FUNCTION cj_collect_raw_dml();

CREATE OR REPLACE VIEW cj_v1_param AS
SELECT b.id,
       b.param_name,
       b.symbol,
       b.category,
       b.definition,
       b.unit,
       b.current_value,
       b.model_role,
       b.param_relation,
       b.update_freq,
       b.data_source,
       b.source_note,
       b.mapping_reason,
       b.last_updated,
       b.revision_log,
       b.feishu_id
FROM cj_v1_param_base b;

CREATE OR REPLACE FUNCTION cj_v1_param_dml() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO cj_v1_param_base (param_name, symbol, category, definition, unit, current_value, model_role, param_relation, update_freq, data_source, source_note, mapping_reason, last_updated, revision_log) VALUES (NEW.param_name, NEW.symbol, NEW.category, NEW.definition, NEW.unit, NEW.current_value, NEW.model_role, NEW.param_relation, NEW.update_freq, NEW.data_source, NEW.source_note, NEW.mapping_reason, NEW.last_updated, NEW.revision_log) RETURNING id INTO NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE cj_v1_param_base SET param_name = NEW.param_name, symbol = NEW.symbol, category = NEW.category, definition = NEW.definition, unit = NEW.unit, current_value = NEW.current_value, model_role = NEW.model_role, param_relation = NEW.param_relation, update_freq = NEW.update_freq, data_source = NEW.data_source, source_note = NEW.source_note, mapping_reason = NEW.mapping_reason, last_updated = NEW.last_updated, revision_log = NEW.revision_log WHERE id = OLD.id;
    RETURN NEW;
  ELSE
    DELETE FROM cj_v1_param_base WHERE id = OLD.id;
    RETURN OLD;
  END IF;
END $$;

DROP TRIGGER IF EXISTS cj_v1_param_dml ON cj_v1_param;
CREATE TRIGGER cj_v1_param_dml INSTEAD OF INSERT OR UPDATE OR DELETE ON cj_v1_param FOR EACH ROW EXECUTE FUNCTION cj_v1_param_dml();

CREATE OR REPLACE VIEW cj_v1_annual AS
SELECT b.id,
       b.year,
       b.generation,
       b.avg_price,
       b.revenue,
       b.net_profit,
       b.da,
       b.finance_cost,
       b.invest_income,
       b.cfo,
       b.capex,
       b.interest_debt,
       b.dps,
       b.dividend_total,
       b.source,
       b.note,
       c.payout_pct,
       c.da_plus_finance,
       b.feishu_id
FROM cj_v1_annual_base b LEFT JOIN cj_v1_annual_calc c ON c.id = b.id;

CREATE OR REPLACE FUNCTION cj_v1_annual_dml() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO cj_v1_annual_base (year, generation, avg_price, revenue, net_profit, da, finance_cost, invest_income, cfo, capex, interest_debt, dps, dividend_total, source, note) VALUES (NEW.year, NEW.generation, NEW.avg_price, NEW.revenue, NEW.net_profit, NEW.da, NEW.finance_cost, NEW.invest_income, NEW.cfo, NEW.capex, NEW.interest_debt, NEW.dps, NEW.dividend_total, NEW.source, NEW.note) RETURNING id INTO NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE cj_v1_annual_base SET year = NEW.year, generation = NEW.generation, avg_price = NEW.avg_price, revenue = NEW.revenue, net_profit = NEW.net_profit, da = NEW.da, finance_cost = NEW.finance_cost, invest_income = NEW.invest_income, cfo = NEW.cfo, capex = NEW.capex, interest_debt = NEW.interest_debt, dps = NEW.dps, dividend_total = NEW.dividend_total, source = NEW.source, note = NEW.note WHERE id = OLD.id;
    RETURN NEW;
  ELSE
    DELETE FROM cj_v1_annual_base WHERE id = OLD.id;
    RETURN OLD;
  END IF;
END $$;

DROP TRIGGER IF EXISTS cj_v1_annual_dml ON cj_v1_annual;
CREATE TRIGGER cj_v1_annual_dml INSTEAD OF INSERT OR UPDATE OR DELETE ON cj_v1_annual FOR EACH ROW EXECUTE FUNCTION cj_v1_annual_dml();

CREATE OR REPLACE VIEW cj_v1_quarterly AS
SELECT b.id,
       b.period,
       b.generation,
       b.yoy_pct,
       b.inflow_eval,
       b.summary,
       b.announcement_link,
       b.status,
       b.feishu_id
FROM cj_v1_quarterly_base b;

CREATE OR REPLACE FUNCTION cj_v1_quarterly_dml() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO cj_v1_quarterly_base (period, generation, yoy_pct, inflow_eval, summary, announcement_link, status) VALUES (NEW.period, NEW.generation, NEW.yoy_pct, NEW.inflow_eval, NEW.summary, NEW.announcement_link, NEW.status) RETURNING id INTO NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE cj_v1_quarterly_base SET period = NEW.period, generation = NEW.generation, yoy_pct = NEW.yoy_pct, inflow_eval = NEW.inflow_eval, summary = NEW.summary, announcement_link = NEW.announcement_link, status = NEW.status WHERE id = OLD.id;
    RETURN NEW;
  ELSE
    DELETE FROM cj_v1_quarterly_base WHERE id = OLD.id;
    RETURN OLD;
  END IF;
END $$;

DROP TRIGGER IF EXISTS cj_v1_quarterly_dml ON cj_v1_quarterly;
CREATE TRIGGER cj_v1_quarterly_dml INSTEAD OF INSERT OR UPDATE OR DELETE ON cj_v1_quarterly FOR EACH ROW EXECUTE FUNCTION cj_v1_quarterly_dml();

CREATE OR REPLACE VIEW cj_v1_source AS
SELECT b.id,
       b.name,
       b.source_type,
       b.authority,
       b.link,
       b.update_freq,
       b.usage_note,
       b.feishu_id
FROM cj_v1_source_base b;

CREATE OR REPLACE FUNCTION cj_v1_source_dml() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO cj_v1_source_base (name, source_type, authority, link, update_freq, usage_note) VALUES (NEW.name, NEW.source_type, NEW.authority, NEW.link, NEW.update_freq, NEW.usage_note) RETURNING id INTO NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE cj_v1_source_base SET name = NEW.name, source_type = NEW.source_type, authority = NEW.authority, link = NEW.link, update_freq = NEW.update_freq, usage_note = NEW.usage_note WHERE id = OLD.id;
    RETURN NEW;
  ELSE
    DELETE FROM cj_v1_source_base WHERE id = OLD.id;
    RETURN OLD;
  END IF;
END $$;

DROP TRIGGER IF EXISTS cj_v1_source_dml ON cj_v1_source;
CREATE TRIGGER cj_v1_source_dml INSTEAD OF INSERT OR UPDATE OR DELETE ON cj_v1_source FOR EACH ROW EXECUTE FUNCTION cj_v1_source_dml();

CREATE OR REPLACE VIEW cj_v1_announce AS
SELECT b.id,
       b.date,
       b.title,
       b.ann_type,
       b.summary,
       b.link,
       b.status,
       b.feishu_id
FROM cj_v1_announce_base b;

CREATE OR REPLACE FUNCTION cj_v1_announce_dml() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO cj_v1_announce_base (date, title, ann_type, summary, link, status) VALUES (NEW.date, NEW.title, NEW.ann_type, NEW.summary, NEW.link, NEW.status) RETURNING id INTO NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE cj_v1_announce_base SET date = NEW.date, title = NEW.title, ann_type = NEW.ann_type, summary = NEW.summary, link = NEW.link, status = NEW.status WHERE id = OLD.id;
    RETURN NEW;
  ELSE
    DELETE FROM cj_v1_announce_base WHERE id = OLD.id;
    RETURN OLD;
  END IF;
END $$;

DROP TRIGGER IF EXISTS cj_v1_announce_dml ON cj_v1_announce;
CREATE TRIGGER cj_v1_announce_dml INSTEAD OF INSERT OR UPDATE OR DELETE ON cj_v1_announce FOR EACH ROW EXECUTE FUNCTION cj_v1_announce_dml();

CREATE OR REPLACE VIEW cj_v1_thesis AS
SELECT b.id,
       b.thesis,
       b.category,
       b.evidence,
       b.falsification,
       b.status,
       b.feishu_id
FROM cj_v1_thesis_base b;

CREATE OR REPLACE FUNCTION cj_v1_thesis_dml() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO cj_v1_thesis_base (thesis, category, evidence, falsification, status) VALUES (NEW.thesis, NEW.category, NEW.evidence, NEW.falsification, NEW.status) RETURNING id INTO NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE cj_v1_thesis_base SET thesis = NEW.thesis, category = NEW.category, evidence = NEW.evidence, falsification = NEW.falsification, status = NEW.status WHERE id = OLD.id;
    RETURN NEW;
  ELSE
    DELETE FROM cj_v1_thesis_base WHERE id = OLD.id;
    RETURN OLD;
  END IF;
END $$;

DROP TRIGGER IF EXISTS cj_v1_thesis_dml ON cj_v1_thesis;
CREATE TRIGGER cj_v1_thesis_dml INSTEAD OF INSERT OR UPDATE OR DELETE ON cj_v1_thesis FOR EACH ROW EXECUTE FUNCTION cj_v1_thesis_dml();

CREATE OR REPLACE VIEW cj_v1_valuation AS
SELECT b.id,
       b.scenario,
       b.price,
       b.price_date,
       b.cgb10y,
       b.erp,
       b.r_pct,
       b.g_pct,
       b.shares_yi,
       b.margin_pct,
       b.fcfe_ps,
       c.value_ps,
       c.signal,
       c.premium_pct,
       c.buy_threshold,
       c.equity_value,
       c.forecast_pv,
       c.terminal_div,
       c.terminal_value,
       c.terminal_pv,
       c.fcfe_perp_value,
       b.feishu_id
FROM cj_v1_valuation_base b LEFT JOIN cj_v1_valuation_calc c ON c.id = b.id;

CREATE OR REPLACE FUNCTION cj_v1_valuation_dml() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO cj_v1_valuation_base (scenario, price, price_date, cgb10y, erp, r_pct, g_pct, shares_yi, margin_pct, fcfe_ps) VALUES (NEW.scenario, NEW.price, NEW.price_date, NEW.cgb10y, NEW.erp, NEW.r_pct, NEW.g_pct, NEW.shares_yi, NEW.margin_pct, NEW.fcfe_ps) RETURNING id INTO NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE cj_v1_valuation_base SET scenario = NEW.scenario, price = NEW.price, price_date = NEW.price_date, cgb10y = NEW.cgb10y, erp = NEW.erp, r_pct = NEW.r_pct, g_pct = NEW.g_pct, shares_yi = NEW.shares_yi, margin_pct = NEW.margin_pct, fcfe_ps = NEW.fcfe_ps WHERE id = OLD.id;
    RETURN NEW;
  ELSE
    DELETE FROM cj_v1_valuation_base WHERE id = OLD.id;
    RETURN OLD;
  END IF;
END $$;

DROP TRIGGER IF EXISTS cj_v1_valuation_dml ON cj_v1_valuation;
CREATE TRIGGER cj_v1_valuation_dml INSTEAD OF INSERT OR UPDATE OR DELETE ON cj_v1_valuation FOR EACH ROW EXECUTE FUNCTION cj_v1_valuation_dml();

CREATE OR REPLACE VIEW cj_v1_forecast AS
SELECT b.id,
       b.year,
       b.generation,
       b.avg_price,
       b.cash_cost,
       b.depreciation,
       b.finance_cost,
       b.other_contrib,
       b.burden_pct,
       b.payout_pct,
       b.note,
       c.revenue,
       c.pretax_profit,
       c.net_profit,
       c.dividend_total,
       c.dps,
       c.discount_factor,
       c.div_pv,
       b.feishu_id
FROM cj_v1_forecast_base b LEFT JOIN cj_v1_forecast_calc c ON c.id = b.id;

CREATE OR REPLACE FUNCTION cj_v1_forecast_dml() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO cj_v1_forecast_base (year, generation, avg_price, cash_cost, depreciation, finance_cost, other_contrib, burden_pct, payout_pct, note) VALUES (NEW.year, NEW.generation, NEW.avg_price, NEW.cash_cost, NEW.depreciation, NEW.finance_cost, NEW.other_contrib, NEW.burden_pct, NEW.payout_pct, NEW.note) RETURNING id INTO NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE cj_v1_forecast_base SET year = NEW.year, generation = NEW.generation, avg_price = NEW.avg_price, cash_cost = NEW.cash_cost, depreciation = NEW.depreciation, finance_cost = NEW.finance_cost, other_contrib = NEW.other_contrib, burden_pct = NEW.burden_pct, payout_pct = NEW.payout_pct, note = NEW.note WHERE id = OLD.id;
    RETURN NEW;
  ELSE
    DELETE FROM cj_v1_forecast_base WHERE id = OLD.id;
    RETURN OLD;
  END IF;
END $$;

DROP TRIGGER IF EXISTS cj_v1_forecast_dml ON cj_v1_forecast;
CREATE TRIGGER cj_v1_forecast_dml INSTEAD OF INSERT OR UPDATE OR DELETE ON cj_v1_forecast FOR EACH ROW EXECUTE FUNCTION cj_v1_forecast_dml();

CREATE OR REPLACE VIEW cj_v1_scenario AS
SELECT b.id,
       b.scenario,
       b.base_dps,
       b.g1_pct,
       b.r_pct,
       b.g_pct,
       b.note,
       c.value_ps,
       b.feishu_id
FROM cj_v1_scenario_base b LEFT JOIN cj_v1_scenario_calc c ON c.id = b.id;

CREATE OR REPLACE FUNCTION cj_v1_scenario_dml() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO cj_v1_scenario_base (scenario, base_dps, g1_pct, r_pct, g_pct, note) VALUES (NEW.scenario, NEW.base_dps, NEW.g1_pct, NEW.r_pct, NEW.g_pct, NEW.note) RETURNING id INTO NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE cj_v1_scenario_base SET scenario = NEW.scenario, base_dps = NEW.base_dps, g1_pct = NEW.g1_pct, r_pct = NEW.r_pct, g_pct = NEW.g_pct, note = NEW.note WHERE id = OLD.id;
    RETURN NEW;
  ELSE
    DELETE FROM cj_v1_scenario_base WHERE id = OLD.id;
    RETURN OLD;
  END IF;
END $$;

DROP TRIGGER IF EXISTS cj_v1_scenario_dml ON cj_v1_scenario;
CREATE TRIGGER cj_v1_scenario_dml INSTEAD OF INSERT OR UPDATE OR DELETE ON cj_v1_scenario FOR EACH ROW EXECUTE FUNCTION cj_v1_scenario_dml();

CREATE OR REPLACE VIEW cj_v1_sens AS
SELECT b.id,
       b.combo,
       b.r_pct,
       b.g1_pct,
       b.g_pct,
       b.base_dps,
       b.note,
       c.value_ps,
       b.feishu_id
FROM cj_v1_sens_base b LEFT JOIN cj_v1_sens_calc c ON c.id = b.id;

CREATE OR REPLACE FUNCTION cj_v1_sens_dml() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO cj_v1_sens_base (combo, r_pct, g1_pct, g_pct, base_dps, note) VALUES (NEW.combo, NEW.r_pct, NEW.g1_pct, NEW.g_pct, NEW.base_dps, NEW.note) RETURNING id INTO NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE cj_v1_sens_base SET combo = NEW.combo, r_pct = NEW.r_pct, g1_pct = NEW.g1_pct, g_pct = NEW.g_pct, base_dps = NEW.base_dps, note = NEW.note WHERE id = OLD.id;
    RETURN NEW;
  ELSE
    DELETE FROM cj_v1_sens_base WHERE id = OLD.id;
    RETURN OLD;
  END IF;
END $$;

DROP TRIGGER IF EXISTS cj_v1_sens_dml ON cj_v1_sens;
CREATE TRIGGER cj_v1_sens_dml INSTEAD OF INSERT OR UPDATE OR DELETE ON cj_v1_sens FOR EACH ROW EXECUTE FUNCTION cj_v1_sens_dml();

COMMIT;
