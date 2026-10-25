-- 自动生成：framework/gen_sql.py。界面视图与写入触发器（依赖 02_calc.sql）

BEGIN;

DROP VIEW IF EXISTS vi_company CASCADE;

CREATE VIEW vi_company AS
SELECT b.id,
       b.code,
       b.name,
       b.exchange,
       b.industry,
       b.currency,
       b.volume_label,
       b.volume_unit,
       b.price_label,
       b.price_unit,
       b.is_default,
       b.profile,
       b.notes,
       b.price_metric_id,
       b.price_fx_metric_id,
       c.latest_price,
       c.latest_price_date,
       c.latest_price_raw,
       c.latest_fx,
       c.macro_used,
       b.updated_at
FROM vi_company_base b LEFT JOIN vi_company_calc c ON c.id = b.id;

COMMENT ON VIEW vi_company IS '公司（界面视图：输入列＋自动计算列）';

CREATE OR REPLACE FUNCTION vi_company_dml() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO vi_company_base (code, name, exchange, industry, currency, volume_label, volume_unit, price_label, price_unit, is_default, profile, notes, price_metric_id, price_fx_metric_id) VALUES (NEW.code, NEW.name, NEW.exchange, NEW.industry, NEW.currency, NEW.volume_label, NEW.volume_unit, NEW.price_label, NEW.price_unit, NEW.is_default, NEW.profile, NEW.notes, NEW.price_metric_id, NEW.price_fx_metric_id) RETURNING id INTO NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE vi_company_base SET code = NEW.code, name = NEW.name, exchange = NEW.exchange, industry = NEW.industry, currency = NEW.currency, volume_label = NEW.volume_label, volume_unit = NEW.volume_unit, price_label = NEW.price_label, price_unit = NEW.price_unit, is_default = NEW.is_default, profile = NEW.profile, notes = NEW.notes, price_metric_id = NEW.price_metric_id, price_fx_metric_id = NEW.price_fx_metric_id WHERE id = OLD.id;
    RETURN NEW;
  ELSE
    DELETE FROM vi_company_base WHERE id = OLD.id;
    RETURN OLD;
  END IF;
END $$;

CREATE TRIGGER vi_company_dml INSTEAD OF INSERT OR UPDATE OR DELETE ON vi_company FOR EACH ROW EXECUTE FUNCTION vi_company_dml();

DROP VIEW IF EXISTS vi_source CASCADE;

CREATE VIEW vi_source AS
SELECT b.id,
       b.title,
       b.source_type,
       b.publisher,
       b.publish_date,
       b.url,
       b.reliability,
       b.verify_status,
       b.retrieved_on,
       b.summary,
       b.limitations,
       b.company_id,
       b.updated_at
FROM vi_source_base b;

COMMENT ON VIEW vi_source IS '来源文档（界面视图：输入列＋自动计算列）';

CREATE OR REPLACE FUNCTION vi_source_dml() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO vi_source_base (title, source_type, publisher, publish_date, url, reliability, verify_status, retrieved_on, summary, limitations, company_id) VALUES (NEW.title, NEW.source_type, NEW.publisher, NEW.publish_date, NEW.url, NEW.reliability, NEW.verify_status, NEW.retrieved_on, NEW.summary, NEW.limitations, NEW.company_id) RETURNING id INTO NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE vi_source_base SET title = NEW.title, source_type = NEW.source_type, publisher = NEW.publisher, publish_date = NEW.publish_date, url = NEW.url, reliability = NEW.reliability, verify_status = NEW.verify_status, retrieved_on = NEW.retrieved_on, summary = NEW.summary, limitations = NEW.limitations, company_id = NEW.company_id WHERE id = OLD.id;
    RETURN NEW;
  ELSE
    DELETE FROM vi_source_base WHERE id = OLD.id;
    RETURN OLD;
  END IF;
END $$;

CREATE TRIGGER vi_source_dml INSTEAD OF INSERT OR UPDATE OR DELETE ON vi_source FOR EACH ROW EXECUTE FUNCTION vi_source_dml();

DROP VIEW IF EXISTS vi_fact CASCADE;

CREATE VIEW vi_fact AS
SELECT b.id,
       b.title,
       b.category,
       b.statement,
       b.value,
       b.unit,
       b.period,
       b.as_of,
       b.verify_status,
       b.notes,
       b.company_id,
       b.source_id,
       b.updated_at
FROM vi_fact_base b;

COMMENT ON VIEW vi_fact IS '事实摘录（界面视图：输入列＋自动计算列）';

CREATE OR REPLACE FUNCTION vi_fact_dml() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO vi_fact_base (title, category, statement, value, unit, period, as_of, verify_status, notes, company_id, source_id) VALUES (NEW.title, NEW.category, NEW.statement, NEW.value, NEW.unit, NEW.period, NEW.as_of, NEW.verify_status, NEW.notes, NEW.company_id, NEW.source_id) RETURNING id INTO NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE vi_fact_base SET title = NEW.title, category = NEW.category, statement = NEW.statement, value = NEW.value, unit = NEW.unit, period = NEW.period, as_of = NEW.as_of, verify_status = NEW.verify_status, notes = NEW.notes, company_id = NEW.company_id, source_id = NEW.source_id WHERE id = OLD.id;
    RETURN NEW;
  ELSE
    DELETE FROM vi_fact_base WHERE id = OLD.id;
    RETURN OLD;
  END IF;
END $$;

CREATE TRIGGER vi_fact_dml INSTEAD OF INSERT OR UPDATE OR DELETE ON vi_fact FOR EACH ROW EXECUTE FUNCTION vi_fact_dml();

DROP VIEW IF EXISTS vi_biz_model CASCADE;

CREATE VIEW vi_biz_model AS
SELECT b.id,
       b.code,
       b.element,
       b.title,
       b.content,
       b.metric,
       b.trend,
       b.company_id,
       b.updated_at
FROM vi_biz_model_base b;

COMMENT ON VIEW vi_biz_model IS '商业模式拆解（界面视图：输入列＋自动计算列）';

CREATE OR REPLACE FUNCTION vi_biz_model_dml() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO vi_biz_model_base (code, element, title, content, metric, trend, company_id) VALUES (NEW.code, NEW.element, NEW.title, NEW.content, NEW.metric, NEW.trend, NEW.company_id) RETURNING id INTO NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE vi_biz_model_base SET code = NEW.code, element = NEW.element, title = NEW.title, content = NEW.content, metric = NEW.metric, trend = NEW.trend, company_id = NEW.company_id WHERE id = OLD.id;
    RETURN NEW;
  ELSE
    DELETE FROM vi_biz_model_base WHERE id = OLD.id;
    RETURN OLD;
  END IF;
END $$;

CREATE TRIGGER vi_biz_model_dml INSTEAD OF INSERT OR UPDATE OR DELETE ON vi_biz_model FOR EACH ROW EXECUTE FUNCTION vi_biz_model_dml();

DROP VIEW IF EXISTS vi_value_chain CASCADE;

CREATE VIEW vi_value_chain AS
SELECT b.id,
       b.code,
       b.position,
       b.participant,
       b.role,
       b.force,
       b.power,
       b.effect,
       b.trend,
       b.profit_share,
       b.analysis,
       b.counter,
       b.company_id,
       b.updated_at
FROM vi_value_chain_base b;

COMMENT ON VIEW vi_value_chain IS '产业链与五力（界面视图：输入列＋自动计算列）';

CREATE OR REPLACE FUNCTION vi_value_chain_dml() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO vi_value_chain_base (code, position, participant, role, force, power, effect, trend, profit_share, analysis, counter, company_id) VALUES (NEW.code, NEW.position, NEW.participant, NEW.role, NEW.force, NEW.power, NEW.effect, NEW.trend, NEW.profit_share, NEW.analysis, NEW.counter, NEW.company_id) RETURNING id INTO NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE vi_value_chain_base SET code = NEW.code, position = NEW.position, participant = NEW.participant, role = NEW.role, force = NEW.force, power = NEW.power, effect = NEW.effect, trend = NEW.trend, profit_share = NEW.profit_share, analysis = NEW.analysis, counter = NEW.counter, company_id = NEW.company_id WHERE id = OLD.id;
    RETURN NEW;
  ELSE
    DELETE FROM vi_value_chain_base WHERE id = OLD.id;
    RETURN OLD;
  END IF;
END $$;

CREATE TRIGGER vi_value_chain_dml INSTEAD OF INSERT OR UPDATE OR DELETE ON vi_value_chain FOR EACH ROW EXECUTE FUNCTION vi_value_chain_dml();

DROP VIEW IF EXISTS vi_competitor CASCADE;

CREATE VIEW vi_competitor AS
SELECT b.id,
       b.name,
       b.ticker,
       b.relation,
       b.segment,
       b.scale_label,
       b.scale_value,
       b.scale_unit,
       b.paying_rate,
       b.price_point,
       b.gross_margin,
       b.growth,
       b.as_of,
       b.strategy,
       b.vs_us,
       b.threat,
       b.trend,
       b.company_id,
       b.source_id,
       b.updated_at
FROM vi_competitor_base b;

COMMENT ON VIEW vi_competitor IS '竞争对手（界面视图：输入列＋自动计算列）';

CREATE OR REPLACE FUNCTION vi_competitor_dml() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO vi_competitor_base (name, ticker, relation, segment, scale_label, scale_value, scale_unit, paying_rate, price_point, gross_margin, growth, as_of, strategy, vs_us, threat, trend, company_id, source_id) VALUES (NEW.name, NEW.ticker, NEW.relation, NEW.segment, NEW.scale_label, NEW.scale_value, NEW.scale_unit, NEW.paying_rate, NEW.price_point, NEW.gross_margin, NEW.growth, NEW.as_of, NEW.strategy, NEW.vs_us, NEW.threat, NEW.trend, NEW.company_id, NEW.source_id) RETURNING id INTO NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE vi_competitor_base SET name = NEW.name, ticker = NEW.ticker, relation = NEW.relation, segment = NEW.segment, scale_label = NEW.scale_label, scale_value = NEW.scale_value, scale_unit = NEW.scale_unit, paying_rate = NEW.paying_rate, price_point = NEW.price_point, gross_margin = NEW.gross_margin, growth = NEW.growth, as_of = NEW.as_of, strategy = NEW.strategy, vs_us = NEW.vs_us, threat = NEW.threat, trend = NEW.trend, company_id = NEW.company_id, source_id = NEW.source_id WHERE id = OLD.id;
    RETURN NEW;
  ELSE
    DELETE FROM vi_competitor_base WHERE id = OLD.id;
    RETURN OLD;
  END IF;
END $$;

CREATE TRIGGER vi_competitor_dml INSTEAD OF INSERT OR UPDATE OR DELETE ON vi_competitor FOR EACH ROW EXECUTE FUNCTION vi_competitor_dml();

DROP VIEW IF EXISTS vi_moat CASCADE;

CREATE VIEW vi_moat AS
SELECT b.id,
       b.code,
       b.title,
       b.moat_type,
       b.verdict,
       b.strength,
       b.trend,
       b.mechanism,
       b.financial_link,
       b.evidence,
       b.counter,
       b.replication,
       b.threats,
       b.check_metric,
       b.check_op,
       b.check_threshold,
       b.check_years,
       b.company_id,
       c.check_latest_year,
       c.check_latest_value,
       c.check_result,
       c.debate_count,
       c.debate_winner,
       b.updated_at
FROM vi_moat_base b LEFT JOIN vi_moat_calc c ON c.id = b.id;

COMMENT ON VIEW vi_moat IS '竞争壁垒（界面视图：输入列＋自动计算列）';

CREATE OR REPLACE FUNCTION vi_moat_dml() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO vi_moat_base (code, title, moat_type, verdict, strength, trend, mechanism, financial_link, evidence, counter, replication, threats, check_metric, check_op, check_threshold, check_years, company_id) VALUES (NEW.code, NEW.title, NEW.moat_type, NEW.verdict, NEW.strength, NEW.trend, NEW.mechanism, NEW.financial_link, NEW.evidence, NEW.counter, NEW.replication, NEW.threats, NEW.check_metric, NEW.check_op, NEW.check_threshold, NEW.check_years, NEW.company_id) RETURNING id INTO NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE vi_moat_base SET code = NEW.code, title = NEW.title, moat_type = NEW.moat_type, verdict = NEW.verdict, strength = NEW.strength, trend = NEW.trend, mechanism = NEW.mechanism, financial_link = NEW.financial_link, evidence = NEW.evidence, counter = NEW.counter, replication = NEW.replication, threats = NEW.threats, check_metric = NEW.check_metric, check_op = NEW.check_op, check_threshold = NEW.check_threshold, check_years = NEW.check_years, company_id = NEW.company_id WHERE id = OLD.id;
    RETURN NEW;
  ELSE
    DELETE FROM vi_moat_base WHERE id = OLD.id;
    RETURN OLD;
  END IF;
END $$;

CREATE TRIGGER vi_moat_dml INSTEAD OF INSERT OR UPDATE OR DELETE ON vi_moat FOR EACH ROW EXECUTE FUNCTION vi_moat_dml();

DROP VIEW IF EXISTS vi_thesis CASCADE;

CREATE VIEW vi_thesis AS
SELECT b.id,
       b.code,
       b.title,
       b.category,
       b.status,
       b.confidence,
       b.bull_case,
       b.bear_case,
       b.bull_rebuttal,
       b.bear_rebuttal,
       b.verdict,
       b.decisive_evidence,
       b.mind_changer,
       b.model_impact,
       b.external_view,
       b.debated_on,
       b.check_metric,
       b.check_op,
       b.check_threshold,
       b.check_years,
       b.company_id,
       c.check_latest_year,
       c.check_latest_value,
       c.check_result,
       c.judgment_status,
       b.updated_at
FROM vi_thesis_base b LEFT JOIN vi_thesis_calc c ON c.id = b.id;

COMMENT ON VIEW vi_thesis IS '核心论点（界面视图：输入列＋自动计算列）';

CREATE OR REPLACE FUNCTION vi_thesis_dml() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO vi_thesis_base (code, title, category, status, confidence, bull_case, bear_case, bull_rebuttal, bear_rebuttal, verdict, decisive_evidence, mind_changer, model_impact, external_view, debated_on, check_metric, check_op, check_threshold, check_years, company_id) VALUES (NEW.code, NEW.title, NEW.category, NEW.status, NEW.confidence, NEW.bull_case, NEW.bear_case, NEW.bull_rebuttal, NEW.bear_rebuttal, NEW.verdict, NEW.decisive_evidence, NEW.mind_changer, NEW.model_impact, NEW.external_view, NEW.debated_on, NEW.check_metric, NEW.check_op, NEW.check_threshold, NEW.check_years, NEW.company_id) RETURNING id INTO NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE vi_thesis_base SET code = NEW.code, title = NEW.title, category = NEW.category, status = NEW.status, confidence = NEW.confidence, bull_case = NEW.bull_case, bear_case = NEW.bear_case, bull_rebuttal = NEW.bull_rebuttal, bear_rebuttal = NEW.bear_rebuttal, verdict = NEW.verdict, decisive_evidence = NEW.decisive_evidence, mind_changer = NEW.mind_changer, model_impact = NEW.model_impact, external_view = NEW.external_view, debated_on = NEW.debated_on, check_metric = NEW.check_metric, check_op = NEW.check_op, check_threshold = NEW.check_threshold, check_years = NEW.check_years, company_id = NEW.company_id WHERE id = OLD.id;
    RETURN NEW;
  ELSE
    DELETE FROM vi_thesis_base WHERE id = OLD.id;
    RETURN OLD;
  END IF;
END $$;

CREATE TRIGGER vi_thesis_dml INSTEAD OF INSERT OR UPDATE OR DELETE ON vi_thesis FOR EACH ROW EXECUTE FUNCTION vi_thesis_dml();

DROP VIEW IF EXISTS vi_risk CASCADE;

CREATE VIEW vi_risk AS
SELECT b.id,
       b.code,
       b.title,
       b.category,
       b.mechanism,
       b.probability,
       b.impact,
       b.horizon,
       b.trend,
       b.impact_estimate,
       b.mitigants,
       b.treatment,
       b.early_warning,
       b.response,
       b.status,
       b.company_id,
       c.level,
       c.thesis_verdicts,
       b.updated_at
FROM vi_risk_base b LEFT JOIN vi_risk_calc c ON c.id = b.id;

COMMENT ON VIEW vi_risk IS '风险分析（界面视图：输入列＋自动计算列）';

CREATE OR REPLACE FUNCTION vi_risk_dml() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO vi_risk_base (code, title, category, mechanism, probability, impact, horizon, trend, impact_estimate, mitigants, treatment, early_warning, response, status, company_id) VALUES (NEW.code, NEW.title, NEW.category, NEW.mechanism, NEW.probability, NEW.impact, NEW.horizon, NEW.trend, NEW.impact_estimate, NEW.mitigants, NEW.treatment, NEW.early_warning, NEW.response, NEW.status, NEW.company_id) RETURNING id INTO NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE vi_risk_base SET code = NEW.code, title = NEW.title, category = NEW.category, mechanism = NEW.mechanism, probability = NEW.probability, impact = NEW.impact, horizon = NEW.horizon, trend = NEW.trend, impact_estimate = NEW.impact_estimate, mitigants = NEW.mitigants, treatment = NEW.treatment, early_warning = NEW.early_warning, response = NEW.response, status = NEW.status, company_id = NEW.company_id WHERE id = OLD.id;
    RETURN NEW;
  ELSE
    DELETE FROM vi_risk_base WHERE id = OLD.id;
    RETURN OLD;
  END IF;
END $$;

CREATE TRIGGER vi_risk_dml INSTEAD OF INSERT OR UPDATE OR DELETE ON vi_risk FOR EACH ROW EXECUTE FUNCTION vi_risk_dml();

DROP VIEW IF EXISTS vi_fit_score CASCADE;

CREATE VIEW vi_fit_score AS
SELECT b.id,
       b.dimension,
       b.score,
       b.rationale,
       b.counter,
       b.sort,
       b.company_id,
       b.updated_at
FROM vi_fit_score_base b;

COMMENT ON VIEW vi_fit_score IS '价投适配度（界面视图：输入列＋自动计算列）';

CREATE OR REPLACE FUNCTION vi_fit_score_dml() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO vi_fit_score_base (dimension, score, rationale, counter, sort, company_id) VALUES (NEW.dimension, NEW.score, NEW.rationale, NEW.counter, NEW.sort, NEW.company_id) RETURNING id INTO NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE vi_fit_score_base SET dimension = NEW.dimension, score = NEW.score, rationale = NEW.rationale, counter = NEW.counter, sort = NEW.sort, company_id = NEW.company_id WHERE id = OLD.id;
    RETURN NEW;
  ELSE
    DELETE FROM vi_fit_score_base WHERE id = OLD.id;
    RETURN OLD;
  END IF;
END $$;

CREATE TRIGGER vi_fit_score_dml INSTEAD OF INSERT OR UPDATE OR DELETE ON vi_fit_score FOR EACH ROW EXECUTE FUNCTION vi_fit_score_dml();

DROP VIEW IF EXISTS vi_judgment CASCADE;

CREATE VIEW vi_judgment AS
SELECT b.id,
       b.code,
       b.title,
       b.fact_layer,
       b.judgment,
       b.transmission,
       b.parameter,
       b.affected_years,
       b.change_threshold,
       b.no_change_condition,
       b.counter_evidence,
       b.status,
       b.company_id,
       b.updated_at
FROM vi_judgment_base b;

COMMENT ON VIEW vi_judgment IS '假设依据（界面视图：输入列＋自动计算列）';

CREATE OR REPLACE FUNCTION vi_judgment_dml() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO vi_judgment_base (code, title, fact_layer, judgment, transmission, parameter, affected_years, change_threshold, no_change_condition, counter_evidence, status, company_id) VALUES (NEW.code, NEW.title, NEW.fact_layer, NEW.judgment, NEW.transmission, NEW.parameter, NEW.affected_years, NEW.change_threshold, NEW.no_change_condition, NEW.counter_evidence, NEW.status, NEW.company_id) RETURNING id INTO NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE vi_judgment_base SET code = NEW.code, title = NEW.title, fact_layer = NEW.fact_layer, judgment = NEW.judgment, transmission = NEW.transmission, parameter = NEW.parameter, affected_years = NEW.affected_years, change_threshold = NEW.change_threshold, no_change_condition = NEW.no_change_condition, counter_evidence = NEW.counter_evidence, status = NEW.status, company_id = NEW.company_id WHERE id = OLD.id;
    RETURN NEW;
  ELSE
    DELETE FROM vi_judgment_base WHERE id = OLD.id;
    RETURN OLD;
  END IF;
END $$;

CREATE TRIGGER vi_judgment_dml INSTEAD OF INSERT OR UPDATE OR DELETE ON vi_judgment FOR EACH ROW EXECUTE FUNCTION vi_judgment_dml();

DROP VIEW IF EXISTS vi_fin_history CASCADE;

CREATE VIEW vi_fin_history AS
SELECT b.id,
       b.year,
       b.scope_note,
       b.volume,
       b.revenue,
       b.cost_of_sales,
       b.pretax_profit,
       b.income_tax,
       b.np_parent,
       b.minority_profit,
       b.da,
       b.finance_cost,
       b.invest_income,
       b.equity_income,
       b.cfo,
       b.capex,
       b.investee_cash_div,
       b.net_borrowing,
       b.interest_debt,
       b.cash,
       b.equity_parent,
       b.dividend_total,
       b.dps,
       b.note,
       b.company_id,
       b.source_id,
       c.price,
       c.payout,
       c.tax_rate,
       c.minority_share,
       c.burden,
       c.fcf,
       c.volume_yoy,
       c.price_yoy,
       c.revenue_yoy,
       c.np_yoy,
       c.finance_cost_yoy,
       c.gross_margin,
       c.roe,
       c.cfo_to_np,
       c.capex_to_cfo,
       c.net_debt,
       c.net_debt_to_ebitda,
       b.updated_at
FROM vi_fin_history_base b LEFT JOIN vi_fin_history_calc c ON c.id = b.id;

COMMENT ON VIEW vi_fin_history IS '财务数据（界面视图：输入列＋自动计算列）';

CREATE OR REPLACE FUNCTION vi_fin_history_dml() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO vi_fin_history_base (year, scope_note, volume, revenue, cost_of_sales, pretax_profit, income_tax, np_parent, minority_profit, da, finance_cost, invest_income, equity_income, cfo, capex, investee_cash_div, net_borrowing, interest_debt, cash, equity_parent, dividend_total, dps, note, company_id, source_id) VALUES (NEW.year, NEW.scope_note, NEW.volume, NEW.revenue, NEW.cost_of_sales, NEW.pretax_profit, NEW.income_tax, NEW.np_parent, NEW.minority_profit, NEW.da, NEW.finance_cost, NEW.invest_income, NEW.equity_income, NEW.cfo, NEW.capex, NEW.investee_cash_div, NEW.net_borrowing, NEW.interest_debt, NEW.cash, NEW.equity_parent, NEW.dividend_total, NEW.dps, NEW.note, NEW.company_id, NEW.source_id) RETURNING id INTO NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE vi_fin_history_base SET year = NEW.year, scope_note = NEW.scope_note, volume = NEW.volume, revenue = NEW.revenue, cost_of_sales = NEW.cost_of_sales, pretax_profit = NEW.pretax_profit, income_tax = NEW.income_tax, np_parent = NEW.np_parent, minority_profit = NEW.minority_profit, da = NEW.da, finance_cost = NEW.finance_cost, invest_income = NEW.invest_income, equity_income = NEW.equity_income, cfo = NEW.cfo, capex = NEW.capex, investee_cash_div = NEW.investee_cash_div, net_borrowing = NEW.net_borrowing, interest_debt = NEW.interest_debt, cash = NEW.cash, equity_parent = NEW.equity_parent, dividend_total = NEW.dividend_total, dps = NEW.dps, note = NEW.note, company_id = NEW.company_id, source_id = NEW.source_id WHERE id = OLD.id;
    RETURN NEW;
  ELSE
    DELETE FROM vi_fin_history_base WHERE id = OLD.id;
    RETURN OLD;
  END IF;
END $$;

CREATE TRIGGER vi_fin_history_dml INSTEAD OF INSERT OR UPDATE OR DELETE ON vi_fin_history FOR EACH ROW EXECUTE FUNCTION vi_fin_history_dml();

DROP VIEW IF EXISTS vi_period_data CASCADE;

CREATE VIEW vi_period_data AS
SELECT b.id,
       b.period,
       b.period_end,
       b.period_kind,
       b.line_item,
       b.value,
       b.unit,
       b.yoy,
       b.impact,
       b.assessment,
       b.summary,
       b.status,
       b.company_id,
       b.source_id,
       b.updated_at
FROM vi_period_data_base b;

COMMENT ON VIEW vi_period_data IS '经营数据（界面视图：输入列＋自动计算列）';

CREATE OR REPLACE FUNCTION vi_period_data_dml() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO vi_period_data_base (period, period_end, period_kind, line_item, value, unit, yoy, impact, assessment, summary, status, company_id, source_id) VALUES (NEW.period, NEW.period_end, NEW.period_kind, NEW.line_item, NEW.value, NEW.unit, NEW.yoy, COALESCE(NEW.impact, '待判断'), NEW.assessment, NEW.summary, NEW.status, NEW.company_id, NEW.source_id) RETURNING id INTO NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE vi_period_data_base SET period = NEW.period, period_end = NEW.period_end, period_kind = NEW.period_kind, line_item = NEW.line_item, value = NEW.value, unit = NEW.unit, yoy = NEW.yoy, impact = COALESCE(NEW.impact, '待判断'), assessment = NEW.assessment, summary = NEW.summary, status = NEW.status, company_id = NEW.company_id, source_id = NEW.source_id WHERE id = OLD.id;
    RETURN NEW;
  ELSE
    DELETE FROM vi_period_data_base WHERE id = OLD.id;
    RETURN OLD;
  END IF;
END $$;

CREATE TRIGGER vi_period_data_dml INSTEAD OF INSERT OR UPDATE OR DELETE ON vi_period_data FOR EACH ROW EXECUTE FUNCTION vi_period_data_dml();

DROP VIEW IF EXISTS vi_metric CASCADE;

CREATE VIEW vi_metric AS
SELECT b.id,
       b.code,
       b.name,
       b.unit,
       b.category,
       b.source_name,
       b.frequency,
       b.valid_min,
       b.valid_max,
       b.notes,
       b.company_id,
       c.obs_count,
       c.latest_value,
       c.latest_date,
       c.scope,
       c.used_by,
       c.used_by_codes,
       b.updated_at
FROM vi_metric_base b LEFT JOIN vi_metric_calc c ON c.id = b.id;

COMMENT ON VIEW vi_metric IS '指标（界面视图：输入列＋自动计算列）';

CREATE OR REPLACE FUNCTION vi_metric_dml() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO vi_metric_base (code, name, unit, category, source_name, frequency, valid_min, valid_max, notes, company_id) VALUES (NEW.code, NEW.name, NEW.unit, NEW.category, NEW.source_name, NEW.frequency, NEW.valid_min, NEW.valid_max, NEW.notes, NEW.company_id) RETURNING id INTO NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE vi_metric_base SET code = NEW.code, name = NEW.name, unit = NEW.unit, category = NEW.category, source_name = NEW.source_name, frequency = NEW.frequency, valid_min = NEW.valid_min, valid_max = NEW.valid_max, notes = NEW.notes, company_id = NEW.company_id WHERE id = OLD.id;
    RETURN NEW;
  ELSE
    DELETE FROM vi_metric_base WHERE id = OLD.id;
    RETURN OLD;
  END IF;
END $$;

CREATE TRIGGER vi_metric_dml INSTEAD OF INSERT OR UPDATE OR DELETE ON vi_metric FOR EACH ROW EXECUTE FUNCTION vi_metric_dml();

DROP VIEW IF EXISTS vi_observation CASCADE;

CREATE VIEW vi_observation AS
SELECT b.id,
       b.obs_date,
       b.value,
       b.collected_at,
       b.source,
       b.note,
       b.metric_id,
       b.raw_capture_id,
       c.is_current,
       c.is_valid,
       b.updated_at
FROM vi_observation_base b LEFT JOIN vi_observation_calc c ON c.id = b.id;

COMMENT ON VIEW vi_observation IS '高频数据（界面视图：输入列＋自动计算列）';

CREATE OR REPLACE FUNCTION vi_observation_dml() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO vi_observation_base (obs_date, value, collected_at, source, note, metric_id, raw_capture_id) VALUES (NEW.obs_date, NEW.value, NEW.collected_at, NEW.source, NEW.note, NEW.metric_id, NEW.raw_capture_id) RETURNING id INTO NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE vi_observation_base SET obs_date = NEW.obs_date, value = NEW.value, collected_at = NEW.collected_at, source = NEW.source, note = NEW.note, metric_id = NEW.metric_id, raw_capture_id = NEW.raw_capture_id WHERE id = OLD.id;
    RETURN NEW;
  ELSE
    DELETE FROM vi_observation_base WHERE id = OLD.id;
    RETURN OLD;
  END IF;
END $$;

CREATE TRIGGER vi_observation_dml INSTEAD OF INSERT OR UPDATE OR DELETE ON vi_observation FOR EACH ROW EXECUTE FUNCTION vi_observation_dml();

DROP VIEW IF EXISTS vi_model CASCADE;

CREATE VIEW vi_model AS
SELECT b.id,
       b.name,
       b.status,
       b.method,
       b.base_year,
       b.terminal_year,
       b.shares,
       b.rf,
       b.rf_date,
       b.erp,
       b.opening_debt,
       b.opening_op_assets,
       b.opening_lt_invest,
       b.opening_equity,
       b.opening_minority,
       b.required_return,
       b.margin_low,
       b.margin_high,
       b.notes,
       b.primary_method,
       b.sotp_year,
       b.sotp_core_adj,
       b.sotp_as_of,
       b.company_id,
       b.rf_metric_id,
       c.base_discount_rate,
       c.valuation_date,
       c.years_elapsed,
       c.latest_rf,
       c.latest_rf_date,
       b.updated_at
FROM vi_model_base b LEFT JOIN vi_model_calc c ON c.id = b.id;

COMMENT ON VIEW vi_model IS '估值模型（界面视图：输入列＋自动计算列）';

CREATE OR REPLACE FUNCTION vi_model_dml() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO vi_model_base (name, status, method, base_year, terminal_year, shares, rf, rf_date, erp, opening_debt, opening_op_assets, opening_lt_invest, opening_equity, opening_minority, required_return, margin_low, margin_high, notes, primary_method, sotp_year, sotp_core_adj, sotp_as_of, company_id, rf_metric_id) VALUES (NEW.name, NEW.status, NEW.method, NEW.base_year, NEW.terminal_year, NEW.shares, NEW.rf, NEW.rf_date, NEW.erp, NEW.opening_debt, NEW.opening_op_assets, NEW.opening_lt_invest, NEW.opening_equity, NEW.opening_minority, NEW.required_return, NEW.margin_low, NEW.margin_high, NEW.notes, NEW.primary_method, NEW.sotp_year, NEW.sotp_core_adj, NEW.sotp_as_of, NEW.company_id, NEW.rf_metric_id) RETURNING id INTO NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE vi_model_base SET name = NEW.name, status = NEW.status, method = NEW.method, base_year = NEW.base_year, terminal_year = NEW.terminal_year, shares = NEW.shares, rf = NEW.rf, rf_date = NEW.rf_date, erp = NEW.erp, opening_debt = NEW.opening_debt, opening_op_assets = NEW.opening_op_assets, opening_lt_invest = NEW.opening_lt_invest, opening_equity = NEW.opening_equity, opening_minority = NEW.opening_minority, required_return = NEW.required_return, margin_low = NEW.margin_low, margin_high = NEW.margin_high, notes = NEW.notes, primary_method = NEW.primary_method, sotp_year = NEW.sotp_year, sotp_core_adj = NEW.sotp_core_adj, sotp_as_of = NEW.sotp_as_of, company_id = NEW.company_id, rf_metric_id = NEW.rf_metric_id WHERE id = OLD.id;
    RETURN NEW;
  ELSE
    DELETE FROM vi_model_base WHERE id = OLD.id;
    RETURN OLD;
  END IF;
END $$;

CREATE TRIGGER vi_model_dml INSTEAD OF INSERT OR UPDATE OR DELETE ON vi_model FOR EACH ROW EXECUTE FUNCTION vi_model_dml();

DROP VIEW IF EXISTS vi_scenario CASCADE;

CREATE VIEW vi_scenario AS
SELECT b.id,
       b.name,
       b.is_base,
       b.sort,
       b.volume_factor,
       b.price_factor,
       b.cost_factor,
       b.discount_rate,
       b.terminal_growth,
       b.nature,
       b.description,
       b.ronic,
       b.sotp_multiple,
       b.probability,
       b.model_id,
       c.eff_discount_rate,
       b.updated_at
FROM vi_scenario_base b LEFT JOIN vi_scenario_calc c ON c.id = b.id;

COMMENT ON VIEW vi_scenario IS '情景（界面视图：输入列＋自动计算列）';

CREATE OR REPLACE FUNCTION vi_scenario_dml() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO vi_scenario_base (name, is_base, sort, volume_factor, price_factor, cost_factor, discount_rate, terminal_growth, nature, description, ronic, sotp_multiple, probability, model_id) VALUES (NEW.name, NEW.is_base, NEW.sort, NEW.volume_factor, NEW.price_factor, NEW.cost_factor, NEW.discount_rate, NEW.terminal_growth, NEW.nature, NEW.description, NEW.ronic, NEW.sotp_multiple, NEW.probability, NEW.model_id) RETURNING id INTO NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE vi_scenario_base SET name = NEW.name, is_base = NEW.is_base, sort = NEW.sort, volume_factor = NEW.volume_factor, price_factor = NEW.price_factor, cost_factor = NEW.cost_factor, discount_rate = NEW.discount_rate, terminal_growth = NEW.terminal_growth, nature = NEW.nature, description = NEW.description, ronic = NEW.ronic, sotp_multiple = NEW.sotp_multiple, probability = NEW.probability, model_id = NEW.model_id WHERE id = OLD.id;
    RETURN NEW;
  ELSE
    DELETE FROM vi_scenario_base WHERE id = OLD.id;
    RETURN OLD;
  END IF;
END $$;

CREATE TRIGGER vi_scenario_dml INSTEAD OF INSERT OR UPDATE OR DELETE ON vi_scenario FOR EACH ROW EXECUTE FUNCTION vi_scenario_dml();

DROP VIEW IF EXISTS vi_sotp_item CASCADE;

CREATE VIEW vi_sotp_item AS
SELECT b.id,
       b.code,
       b.name,
       b.kind,
       b.amount,
       b.haircut,
       b.as_of,
       b.basis,
       b.model_id,
       b.scenario_id,
       c.signed_value,
       c.scope,
       b.updated_at
FROM vi_sotp_item_base b LEFT JOIN vi_sotp_item_calc c ON c.id = b.id;

COMMENT ON VIEW vi_sotp_item IS '分部估值项（界面视图：输入列＋自动计算列）';

CREATE OR REPLACE FUNCTION vi_sotp_item_dml() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO vi_sotp_item_base (code, name, kind, amount, haircut, as_of, basis, model_id, scenario_id) VALUES (NEW.code, NEW.name, NEW.kind, NEW.amount, NEW.haircut, NEW.as_of, NEW.basis, NEW.model_id, NEW.scenario_id) RETURNING id INTO NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE vi_sotp_item_base SET code = NEW.code, name = NEW.name, kind = NEW.kind, amount = NEW.amount, haircut = NEW.haircut, as_of = NEW.as_of, basis = NEW.basis, model_id = NEW.model_id, scenario_id = NEW.scenario_id WHERE id = OLD.id;
    RETURN NEW;
  ELSE
    DELETE FROM vi_sotp_item_base WHERE id = OLD.id;
    RETURN OLD;
  END IF;
END $$;

CREATE TRIGGER vi_sotp_item_dml INSTEAD OF INSERT OR UPDATE OR DELETE ON vi_sotp_item FOR EACH ROW EXECUTE FUNCTION vi_sotp_item_dml();

DROP VIEW IF EXISTS vi_sotp_segment CASCADE;

CREATE VIEW vi_sotp_segment AS
SELECT b.id,
       b.code,
       b.name,
       b.method,
       b.stage,
       b.earn_year,
       b.revenue,
       b.op_margin,
       b.tax_rate,
       b.attrib,
       b.multiple,
       b.ronic,
       b.growth,
       b.discount_rate,
       b.interim_cash,
       b.commit_amount,
       b.commit_years,
       b.ongoing_cost,
       b.direct_value,
       b.basis,
       b.model_id,
       b.scenario_id,
       c.calc_scenario,
       c.earnings,
       c.formula_multiple,
       c.multiple_used,
       c.eff_rate,
       c.years_to_value,
       c.terminal_pv,
       c.interim_pv,
       c.value,
       c.scope,
       b.updated_at
FROM vi_sotp_segment_base b LEFT JOIN vi_sotp_segment_calc c ON c.id = b.id;

COMMENT ON VIEW vi_sotp_segment IS '经营分部估值（界面视图：输入列＋自动计算列）';

CREATE OR REPLACE FUNCTION vi_sotp_segment_dml() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO vi_sotp_segment_base (code, name, method, stage, earn_year, revenue, op_margin, tax_rate, attrib, multiple, ronic, growth, discount_rate, interim_cash, commit_amount, commit_years, ongoing_cost, direct_value, basis, model_id, scenario_id) VALUES (NEW.code, NEW.name, NEW.method, NEW.stage, NEW.earn_year, NEW.revenue, NEW.op_margin, NEW.tax_rate, NEW.attrib, NEW.multiple, NEW.ronic, NEW.growth, NEW.discount_rate, NEW.interim_cash, NEW.commit_amount, NEW.commit_years, NEW.ongoing_cost, NEW.direct_value, NEW.basis, NEW.model_id, NEW.scenario_id) RETURNING id INTO NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE vi_sotp_segment_base SET code = NEW.code, name = NEW.name, method = NEW.method, stage = NEW.stage, earn_year = NEW.earn_year, revenue = NEW.revenue, op_margin = NEW.op_margin, tax_rate = NEW.tax_rate, attrib = NEW.attrib, multiple = NEW.multiple, ronic = NEW.ronic, growth = NEW.growth, discount_rate = NEW.discount_rate, interim_cash = NEW.interim_cash, commit_amount = NEW.commit_amount, commit_years = NEW.commit_years, ongoing_cost = NEW.ongoing_cost, direct_value = NEW.direct_value, basis = NEW.basis, model_id = NEW.model_id, scenario_id = NEW.scenario_id WHERE id = OLD.id;
    RETURN NEW;
  ELSE
    DELETE FROM vi_sotp_segment_base WHERE id = OLD.id;
    RETURN OLD;
  END IF;
END $$;

CREATE TRIGGER vi_sotp_segment_dml INSTEAD OF INSERT OR UPDATE OR DELETE ON vi_sotp_segment FOR EACH ROW EXECUTE FUNCTION vi_sotp_segment_dml();

DROP VIEW IF EXISTS vi_forecast CASCADE;

CREATE VIEW vi_forecast AS
SELECT b.id,
       b.year,
       b.volume,
       b.price,
       b.cash_cost,
       b.depreciation,
       b.other_contrib,
       b.tax_rate,
       b.minority_share,
       b.payout,
       b.net_borrowing,
       b.cost_of_debt,
       b.noncash_gain_deduct,
       b.investee_cash_div,
       b.other_cash_adj,
       b.wc_increase,
       b.maint_capex,
       b.growth_capex,
       b.min_cash_topup,
       b.operating_status,
       b.cash_status,
       b.note,
       b.model_id,
       c.revenue,
       c.debt_open,
       c.debt_close,
       c.interest,
       c.attrib_da,
       c.cash_complete,
       b.updated_at
FROM vi_forecast_base b LEFT JOIN vi_forecast_calc c ON c.id = b.id;

COMMENT ON VIEW vi_forecast IS '逐年假设（界面视图：输入列＋自动计算列）';

CREATE OR REPLACE FUNCTION vi_forecast_dml() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO vi_forecast_base (year, volume, price, cash_cost, depreciation, other_contrib, tax_rate, minority_share, payout, net_borrowing, cost_of_debt, noncash_gain_deduct, investee_cash_div, other_cash_adj, wc_increase, maint_capex, growth_capex, min_cash_topup, operating_status, cash_status, note, model_id) VALUES (NEW.year, NEW.volume, NEW.price, NEW.cash_cost, NEW.depreciation, NEW.other_contrib, NEW.tax_rate, NEW.minority_share, NEW.payout, NEW.net_borrowing, NEW.cost_of_debt, NEW.noncash_gain_deduct, NEW.investee_cash_div, NEW.other_cash_adj, NEW.wc_increase, NEW.maint_capex, NEW.growth_capex, NEW.min_cash_topup, NEW.operating_status, NEW.cash_status, NEW.note, NEW.model_id) RETURNING id INTO NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE vi_forecast_base SET year = NEW.year, volume = NEW.volume, price = NEW.price, cash_cost = NEW.cash_cost, depreciation = NEW.depreciation, other_contrib = NEW.other_contrib, tax_rate = NEW.tax_rate, minority_share = NEW.minority_share, payout = NEW.payout, net_borrowing = NEW.net_borrowing, cost_of_debt = NEW.cost_of_debt, noncash_gain_deduct = NEW.noncash_gain_deduct, investee_cash_div = NEW.investee_cash_div, other_cash_adj = NEW.other_cash_adj, wc_increase = NEW.wc_increase, maint_capex = NEW.maint_capex, growth_capex = NEW.growth_capex, min_cash_topup = NEW.min_cash_topup, operating_status = NEW.operating_status, cash_status = NEW.cash_status, note = NEW.note, model_id = NEW.model_id WHERE id = OLD.id;
    RETURN NEW;
  ELSE
    DELETE FROM vi_forecast_base WHERE id = OLD.id;
    RETURN OLD;
  END IF;
END $$;

CREATE TRIGGER vi_forecast_dml INSTEAD OF INSERT OR UPDATE OR DELETE ON vi_forecast FOR EACH ROW EXECUTE FUNCTION vi_forecast_dml();

DROP VIEW IF EXISTS vi_trial CASCADE;

CREATE VIEW vi_trial AS
SELECT b.id,
       b.name,
       b.start_year,
       b.end_year,
       b.volume_delta,
       b.price_delta,
       b.cost_delta,
       b.da_delta,
       b.interest_delta,
       b.rate_delta,
       b.boundary,
       b.model_id,
       c.base_value,
       c.trial_value,
       c.value_change,
       c.change_pct,
       b.updated_at
FROM vi_trial_base b LEFT JOIN vi_trial_calc c ON c.id = b.id;

COMMENT ON VIEW vi_trial IS '单参数试验（界面视图：输入列＋自动计算列）';

CREATE OR REPLACE FUNCTION vi_trial_dml() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO vi_trial_base (name, start_year, end_year, volume_delta, price_delta, cost_delta, da_delta, interest_delta, rate_delta, boundary, model_id) VALUES (NEW.name, NEW.start_year, NEW.end_year, NEW.volume_delta, NEW.price_delta, NEW.cost_delta, NEW.da_delta, NEW.interest_delta, NEW.rate_delta, NEW.boundary, NEW.model_id) RETURNING id INTO NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE vi_trial_base SET name = NEW.name, start_year = NEW.start_year, end_year = NEW.end_year, volume_delta = NEW.volume_delta, price_delta = NEW.price_delta, cost_delta = NEW.cost_delta, da_delta = NEW.da_delta, interest_delta = NEW.interest_delta, rate_delta = NEW.rate_delta, boundary = NEW.boundary, model_id = NEW.model_id WHERE id = OLD.id;
    RETURN NEW;
  ELSE
    DELETE FROM vi_trial_base WHERE id = OLD.id;
    RETURN OLD;
  END IF;
END $$;

CREATE TRIGGER vi_trial_dml INSTEAD OF INSERT OR UPDATE OR DELETE ON vi_trial FOR EACH ROW EXECUTE FUNCTION vi_trial_dml();

DROP VIEW IF EXISTS vi_watch CASCADE;

CREATE VIEW vi_watch AS
SELECT b.id,
       b.code,
       b.title,
       b.frequency,
       b.preferred_source,
       b.trigger,
       b.action,
       b.nature,
       b.company_id,
       b.metric_id,
       c.latest_value,
       c.latest_date,
       b.updated_at
FROM vi_watch_base b LEFT JOIN vi_watch_calc c ON c.id = b.id;

COMMENT ON VIEW vi_watch IS '跟踪事项（界面视图：输入列＋自动计算列）';

CREATE OR REPLACE FUNCTION vi_watch_dml() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO vi_watch_base (code, title, frequency, preferred_source, trigger, action, nature, company_id, metric_id) VALUES (NEW.code, NEW.title, NEW.frequency, NEW.preferred_source, NEW.trigger, NEW.action, NEW.nature, NEW.company_id, NEW.metric_id) RETURNING id INTO NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE vi_watch_base SET code = NEW.code, title = NEW.title, frequency = NEW.frequency, preferred_source = NEW.preferred_source, trigger = NEW.trigger, action = NEW.action, nature = NEW.nature, company_id = NEW.company_id, metric_id = NEW.metric_id WHERE id = OLD.id;
    RETURN NEW;
  ELSE
    DELETE FROM vi_watch_base WHERE id = OLD.id;
    RETURN OLD;
  END IF;
END $$;

CREATE TRIGGER vi_watch_dml INSTEAD OF INSERT OR UPDATE OR DELETE ON vi_watch FOR EACH ROW EXECUTE FUNCTION vi_watch_dml();

DROP VIEW IF EXISTS vi_issue CASCADE;

CREATE VIEW vi_issue AS
SELECT b.id,
       b.code,
       b.title,
       b.severity,
       b.impact,
       b.done_condition,
       b.status,
       b.progress,
       b.company_id,
       b.updated_at
FROM vi_issue_base b;

COMMENT ON VIEW vi_issue IS '问题清单（界面视图：输入列＋自动计算列）';

CREATE OR REPLACE FUNCTION vi_issue_dml() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO vi_issue_base (code, title, severity, impact, done_condition, status, progress, company_id) VALUES (NEW.code, NEW.title, NEW.severity, NEW.impact, NEW.done_condition, NEW.status, NEW.progress, NEW.company_id) RETURNING id INTO NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE vi_issue_base SET code = NEW.code, title = NEW.title, severity = NEW.severity, impact = NEW.impact, done_condition = NEW.done_condition, status = NEW.status, progress = NEW.progress, company_id = NEW.company_id WHERE id = OLD.id;
    RETURN NEW;
  ELSE
    DELETE FROM vi_issue_base WHERE id = OLD.id;
    RETURN OLD;
  END IF;
END $$;

CREATE TRIGGER vi_issue_dml INSTEAD OF INSERT OR UPDATE OR DELETE ON vi_issue FOR EACH ROW EXECUTE FUNCTION vi_issue_dml();

DROP VIEW IF EXISTS vi_change_log CASCADE;

CREATE VIEW vi_change_log AS
SELECT b.id,
       b.change_date,
       b.title,
       b.target,
       b.old_value,
       b.new_value,
       b.reason,
       b.basis,
       b.verification,
       b.company_id,
       b.updated_at
FROM vi_change_log_base b;

COMMENT ON VIEW vi_change_log IS '变更日志（界面视图：输入列＋自动计算列）';

CREATE OR REPLACE FUNCTION vi_change_log_dml() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO vi_change_log_base (change_date, title, target, old_value, new_value, reason, basis, verification, company_id) VALUES (NEW.change_date, NEW.title, NEW.target, NEW.old_value, NEW.new_value, NEW.reason, NEW.basis, NEW.verification, NEW.company_id) RETURNING id INTO NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE vi_change_log_base SET change_date = NEW.change_date, title = NEW.title, target = NEW.target, old_value = NEW.old_value, new_value = NEW.new_value, reason = NEW.reason, basis = NEW.basis, verification = NEW.verification, company_id = NEW.company_id WHERE id = OLD.id;
    RETURN NEW;
  ELSE
    DELETE FROM vi_change_log_base WHERE id = OLD.id;
    RETURN OLD;
  END IF;
END $$;

CREATE TRIGGER vi_change_log_dml INSTEAD OF INSERT OR UPDATE OR DELETE ON vi_change_log FOR EACH ROW EXECUTE FUNCTION vi_change_log_dml();

DROP VIEW IF EXISTS vi_collector CASCADE;

CREATE VIEW vi_collector AS
SELECT b.id,
       b.name,
       b.url,
       b.parser,
       b.parser_param,
       b.enabled,
       b.max_lag_days,
       b.last_selfcheck,
       b.selfcheck_result,
       b.notes,
       b.metric_id,
       c.last_collected,
       c.last_obs_date,
       c.last_result,
       c.health,
       c.needs_alert,
       b.updated_at
FROM vi_collector_base b LEFT JOIN vi_collector_calc c ON c.id = b.id;

COMMENT ON VIEW vi_collector IS '采集配置（界面视图：输入列＋自动计算列）';

CREATE OR REPLACE FUNCTION vi_collector_dml() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO vi_collector_base (name, url, parser, parser_param, enabled, max_lag_days, last_selfcheck, selfcheck_result, notes, metric_id) VALUES (NEW.name, NEW.url, NEW.parser, NEW.parser_param, NEW.enabled, NEW.max_lag_days, NEW.last_selfcheck, NEW.selfcheck_result, NEW.notes, NEW.metric_id) RETURNING id INTO NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE vi_collector_base SET name = NEW.name, url = NEW.url, parser = NEW.parser, parser_param = NEW.parser_param, enabled = NEW.enabled, max_lag_days = NEW.max_lag_days, last_selfcheck = NEW.last_selfcheck, selfcheck_result = NEW.selfcheck_result, notes = NEW.notes, metric_id = NEW.metric_id WHERE id = OLD.id;
    RETURN NEW;
  ELSE
    DELETE FROM vi_collector_base WHERE id = OLD.id;
    RETURN OLD;
  END IF;
END $$;

CREATE TRIGGER vi_collector_dml INSTEAD OF INSERT OR UPDATE OR DELETE ON vi_collector FOR EACH ROW EXECUTE FUNCTION vi_collector_dml();

DROP VIEW IF EXISTS vi_collect_run CASCADE;

CREATE VIEW vi_collect_run AS
SELECT b.id,
       b.label,
       b.trigger_source,
       b.status,
       b.company_id,
       c.requested_at,
       c.finished_at,
       c.seconds,
       c.raw_count,
       c.ingested,
       c.duplicates,
       c.fetch_failed,
       c.invalid,
       c.summary,
       b.updated_at
FROM vi_collect_run_base b LEFT JOIN vi_collect_run_calc c ON c.id = b.id;

COMMENT ON VIEW vi_collect_run IS '采集运行（界面视图：输入列＋自动计算列）';

CREATE OR REPLACE FUNCTION vi_collect_run_dml() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO vi_collect_run_base (label, trigger_source, status, company_id) VALUES (NEW.label, NEW.trigger_source, NEW.status, NEW.company_id) RETURNING id INTO NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE vi_collect_run_base SET label = NEW.label, trigger_source = NEW.trigger_source, status = NEW.status, company_id = NEW.company_id WHERE id = OLD.id;
    RETURN NEW;
  ELSE
    DELETE FROM vi_collect_run_base WHERE id = OLD.id;
    RETURN OLD;
  END IF;
END $$;

CREATE TRIGGER vi_collect_run_dml INSTEAD OF INSERT OR UPDATE OR DELETE ON vi_collect_run FOR EACH ROW EXECUTE FUNCTION vi_collect_run_dml();

DROP VIEW IF EXISTS vi_raw_capture CASCADE;

CREATE VIEW vi_raw_capture AS
SELECT b.id,
       b.run_label,
       b.collected_at,
       b.status,
       b.fetch_result,
       b.raw_response,
       b.collector_id,
       b.run_id,
       c.fetch_ok,
       c.fetch_note,
       c.parsed_date,
       c.parsed_value,
       c.is_valid,
       c.already_exists,
       c.decision,
       b.updated_at
FROM vi_raw_capture_base b LEFT JOIN vi_raw_capture_calc c ON c.id = b.id;

COMMENT ON VIEW vi_raw_capture IS '原始采集记录（界面视图：输入列＋自动计算列）';

CREATE OR REPLACE FUNCTION vi_raw_capture_dml() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO vi_raw_capture_base (run_label, collected_at, status, fetch_result, raw_response, collector_id, run_id) VALUES (NEW.run_label, NEW.collected_at, NEW.status, NEW.fetch_result, NEW.raw_response, NEW.collector_id, NEW.run_id) RETURNING id INTO NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE vi_raw_capture_base SET run_label = NEW.run_label, collected_at = NEW.collected_at, status = NEW.status, fetch_result = NEW.fetch_result, raw_response = NEW.raw_response, collector_id = NEW.collector_id, run_id = NEW.run_id WHERE id = OLD.id;
    RETURN NEW;
  ELSE
    DELETE FROM vi_raw_capture_base WHERE id = OLD.id;
    RETURN OLD;
  END IF;
END $$;

CREATE TRIGGER vi_raw_capture_dml INSTEAD OF INSERT OR UPDATE OR DELETE ON vi_raw_capture FOR EACH ROW EXECUTE FUNCTION vi_raw_capture_dml();

COMMIT;
