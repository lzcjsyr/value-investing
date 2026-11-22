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
       b.scope_breaks,
       b.pe_ttm,
       b.pb,
       b.pe_pb_date,
       b.shares,
       b.as_of,
       b.value_layer,
       b.layer_reason,
       b.av_basis,
       b.repro_cost,
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
    INSERT INTO vi_company_base (code, name, exchange, industry, currency, volume_label, volume_unit, price_label, price_unit, is_default, scope_breaks, pe_ttm, pb, pe_pb_date, shares, as_of, value_layer, layer_reason, av_basis, repro_cost, profile, notes, price_metric_id, price_fx_metric_id) VALUES (NEW.code, NEW.name, NEW.exchange, NEW.industry, NEW.currency, NEW.volume_label, NEW.volume_unit, NEW.price_label, NEW.price_unit, NEW.is_default, NEW.scope_breaks, NEW.pe_ttm, NEW.pb, NEW.pe_pb_date, NEW.shares, NEW.as_of, NEW.value_layer, NEW.layer_reason, COALESCE(NEW.av_basis, '调整后净资产'), NEW.repro_cost, NEW.profile, NEW.notes, NEW.price_metric_id, NEW.price_fx_metric_id) RETURNING id INTO NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE vi_company_base SET code = NEW.code, name = NEW.name, exchange = NEW.exchange, industry = NEW.industry, currency = NEW.currency, volume_label = NEW.volume_label, volume_unit = NEW.volume_unit, price_label = NEW.price_label, price_unit = NEW.price_unit, is_default = NEW.is_default, scope_breaks = NEW.scope_breaks, pe_ttm = NEW.pe_ttm, pb = NEW.pb, pe_pb_date = NEW.pe_pb_date, shares = NEW.shares, as_of = NEW.as_of, value_layer = NEW.value_layer, layer_reason = NEW.layer_reason, av_basis = COALESCE(NEW.av_basis, '调整后净资产'), repro_cost = NEW.repro_cost, profile = NEW.profile, notes = NEW.notes, price_metric_id = NEW.price_metric_id, price_fx_metric_id = NEW.price_fx_metric_id WHERE id = OLD.id;
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

DROP VIEW IF EXISTS vi_event CASCADE;

CREATE VIEW vi_event AS
SELECT b.id,
       b.name,
       b.category,
       b.status,
       b.period,
       b.summary,
       b.company_id,
       c.fact_count,
       c.latest_as_of,
       b.updated_at
FROM vi_event_base b LEFT JOIN vi_event_calc c ON c.id = b.id;

COMMENT ON VIEW vi_event IS '事项（界面视图：输入列＋自动计算列）';

CREATE OR REPLACE FUNCTION vi_event_dml() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO vi_event_base (name, category, status, period, summary, company_id) VALUES (NEW.name, NEW.category, NEW.status, NEW.period, NEW.summary, NEW.company_id) RETURNING id INTO NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE vi_event_base SET name = NEW.name, category = NEW.category, status = NEW.status, period = NEW.period, summary = NEW.summary, company_id = NEW.company_id WHERE id = OLD.id;
    RETURN NEW;
  ELSE
    DELETE FROM vi_event_base WHERE id = OLD.id;
    RETURN OLD;
  END IF;
END $$;

CREATE TRIGGER vi_event_dml INSTEAD OF INSERT OR UPDATE OR DELETE ON vi_event FOR EACH ROW EXECUTE FUNCTION vi_event_dml();

DROP VIEW IF EXISTS vi_fact CASCADE;

CREATE VIEW vi_fact AS
SELECT b.id,
       b.title,
       b.category,
       b.statement,
       b.period,
       b.as_of,
       b.verify_status,
       b.notes,
       b.company_id,
       b.event_id,
       b.source_id,
       b.updated_at
FROM vi_fact_base b;

COMMENT ON VIEW vi_fact IS '定性事实（界面视图：输入列＋自动计算列）';

CREATE OR REPLACE FUNCTION vi_fact_dml() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO vi_fact_base (title, category, statement, period, as_of, verify_status, notes, company_id, event_id, source_id) VALUES (NEW.title, NEW.category, NEW.statement, NEW.period, NEW.as_of, NEW.verify_status, NEW.notes, NEW.company_id, NEW.event_id, NEW.source_id) RETURNING id INTO NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE vi_fact_base SET title = NEW.title, category = NEW.category, statement = NEW.statement, period = NEW.period, as_of = NEW.as_of, verify_status = NEW.verify_status, notes = NEW.notes, company_id = NEW.company_id, event_id = NEW.event_id, source_id = NEW.source_id WHERE id = OLD.id;
    RETURN NEW;
  ELSE
    DELETE FROM vi_fact_base WHERE id = OLD.id;
    RETURN OLD;
  END IF;
END $$;

CREATE TRIGGER vi_fact_dml INSTEAD OF INSERT OR UPDATE OR DELETE ON vi_fact FOR EACH ROW EXECUTE FUNCTION vi_fact_dml();

DROP VIEW IF EXISTS vi_business CASCADE;

CREATE VIEW vi_business AS
SELECT b.id,
       b.code,
       b.name,
       b.boundary,
       b.asset_boundary,
       b.sort,
       b.capital_basis,
       b.company_id,
       b.updated_at
FROM vi_business_base b;

COMMENT ON VIEW vi_business IS '业务分部（界面视图：输入列＋自动计算列）';

CREATE OR REPLACE FUNCTION vi_business_dml() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO vi_business_base (code, name, boundary, asset_boundary, sort, capital_basis, company_id) VALUES (NEW.code, NEW.name, NEW.boundary, NEW.asset_boundary, NEW.sort, COALESCE(NEW.capital_basis, '企业'), NEW.company_id) RETURNING id INTO NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE vi_business_base SET code = NEW.code, name = NEW.name, boundary = NEW.boundary, asset_boundary = NEW.asset_boundary, sort = NEW.sort, capital_basis = COALESCE(NEW.capital_basis, '企业'), company_id = NEW.company_id WHERE id = OLD.id;
    RETURN NEW;
  ELSE
    DELETE FROM vi_business_base WHERE id = OLD.id;
    RETURN OLD;
  END IF;
END $$;

CREATE TRIGGER vi_business_dml INSTEAD OF INSERT OR UPDATE OR DELETE ON vi_business FOR EACH ROW EXECUTE FUNCTION vi_business_dml();

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
       b.business_id,
       b.updated_at
FROM vi_biz_model_base b;

COMMENT ON VIEW vi_biz_model IS '商业模式拆解（界面视图：输入列＋自动计算列）';

CREATE OR REPLACE FUNCTION vi_biz_model_dml() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO vi_biz_model_base (code, element, title, content, metric, trend, company_id, business_id) VALUES (NEW.code, NEW.element, NEW.title, NEW.content, NEW.metric, NEW.trend, NEW.company_id, NEW.business_id) RETURNING id INTO NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE vi_biz_model_base SET code = NEW.code, element = NEW.element, title = NEW.title, content = NEW.content, metric = NEW.metric, trend = NEW.trend, company_id = NEW.company_id, business_id = NEW.business_id WHERE id = OLD.id;
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
    INSERT INTO vi_judgment_base (code, title, fact_layer, judgment, transmission, parameter, change_threshold, no_change_condition, counter_evidence, status, company_id) VALUES (NEW.code, NEW.title, NEW.fact_layer, NEW.judgment, NEW.transmission, NEW.parameter, NEW.change_threshold, NEW.no_change_condition, NEW.counter_evidence, NEW.status, NEW.company_id) RETURNING id INTO NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE vi_judgment_base SET code = NEW.code, title = NEW.title, fact_layer = NEW.fact_layer, judgment = NEW.judgment, transmission = NEW.transmission, parameter = NEW.parameter, change_threshold = NEW.change_threshold, no_change_condition = NEW.no_change_condition, counter_evidence = NEW.counter_evidence, status = NEW.status, company_id = NEW.company_id WHERE id = OLD.id;
    RETURN NEW;
  ELSE
    DELETE FROM vi_judgment_base WHERE id = OLD.id;
    RETURN OLD;
  END IF;
END $$;

CREATE TRIGGER vi_judgment_dml INSTEAD OF INSERT OR UPDATE OR DELETE ON vi_judgment FOR EACH ROW EXECUTE FUNCTION vi_judgment_dml();

DROP VIEW IF EXISTS vi_fin_stmt CASCADE;

CREATE VIEW vi_fin_stmt AS
SELECT b.id,
       b.period,
       b.period_end,
       b.stmt,
       b.item,
       b.seq,
       b.amount,
       b.currency,
       b.unit,
       b.company_id,
       b.updated_at
FROM vi_fin_stmt_base b;

COMMENT ON VIEW vi_fin_stmt IS '财务报表（界面视图：输入列＋自动计算列）';

CREATE OR REPLACE FUNCTION vi_fin_stmt_dml() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO vi_fin_stmt_base (period, period_end, stmt, item, seq, amount, currency, unit, company_id) VALUES (NEW.period, NEW.period_end, NEW.stmt, NEW.item, NEW.seq, NEW.amount, NEW.currency, NEW.unit, NEW.company_id) RETURNING id INTO NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE vi_fin_stmt_base SET period = NEW.period, period_end = NEW.period_end, stmt = NEW.stmt, item = NEW.item, seq = NEW.seq, amount = NEW.amount, currency = NEW.currency, unit = NEW.unit, company_id = NEW.company_id WHERE id = OLD.id;
    RETURN NEW;
  ELSE
    DELETE FROM vi_fin_stmt_base WHERE id = OLD.id;
    RETURN OLD;
  END IF;
END $$;

CREATE TRIGGER vi_fin_stmt_dml INSTEAD OF INSERT OR UPDATE OR DELETE ON vi_fin_stmt FOR EACH ROW EXECUTE FUNCTION vi_fin_stmt_dml();

DROP VIEW IF EXISTS vi_metric CASCADE;

CREATE VIEW vi_metric AS
SELECT b.id,
       b.code,
       b.name,
       b.unit,
       b.category,
       b.measure,
       b.source_kind,
       b.basis,
       b.model_field,
       b.formula,
       b.source_name,
       b.frequency,
       b.valid_min,
       b.valid_max,
       b.notes,
       b.company_id,
       c.obs_count,
       c.latest_value,
       c.latest_period,
       c.latest_date,
       c.trend,
       c.state,
       c.next_due,
       c.tracked_by,
       c.tracked_codes,
       c.model_order,
       c.scope,
       c.used_by,
       c.used_by_codes,
       b.updated_at
FROM vi_metric_base b LEFT JOIN vi_metric_calc c ON c.id = b.id;

COMMENT ON VIEW vi_metric IS '指标（界面视图：输入列＋自动计算列）';

CREATE OR REPLACE FUNCTION vi_metric_dml() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO vi_metric_base (code, name, unit, category, measure, source_kind, basis, model_field, formula, source_name, frequency, valid_min, valid_max, notes, company_id) VALUES (NEW.code, NEW.name, NEW.unit, NEW.category, NEW.measure, COALESCE(NEW.source_kind, '自动采集'), COALESCE(NEW.basis, '时点'), NEW.model_field, NEW.formula, NEW.source_name, NEW.frequency, NEW.valid_min, NEW.valid_max, NEW.notes, NEW.company_id) RETURNING id INTO NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE vi_metric_base SET code = NEW.code, name = NEW.name, unit = NEW.unit, category = NEW.category, measure = NEW.measure, source_kind = COALESCE(NEW.source_kind, '自动采集'), basis = COALESCE(NEW.basis, '时点'), model_field = NEW.model_field, formula = NEW.formula, source_name = NEW.source_name, frequency = NEW.frequency, valid_min = NEW.valid_min, valid_max = NEW.valid_max, notes = NEW.notes, company_id = NEW.company_id WHERE id = OLD.id;
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
       b.period,
       b.basis,
       b.value,
       b.yoy,
       b.summary,
       b.collected_at,
       b.metric_id,
       b.doc_id,
       b.raw_capture_id,
       c.unit,
       c.measure,
       c.source_kind,
       c.is_current,
       c.is_valid,
       b.updated_at
FROM vi_observation_base b LEFT JOIN vi_observation_calc c ON c.id = b.id;

COMMENT ON VIEW vi_observation IS '数据（界面视图：输入列＋自动计算列）';

CREATE OR REPLACE FUNCTION vi_observation_dml() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO vi_observation_base (obs_date, period, basis, value, yoy, summary, collected_at, metric_id, doc_id, raw_capture_id) VALUES (NEW.obs_date, NEW.period, COALESCE(NEW.basis, '时点'), NEW.value, NEW.yoy, NEW.summary, NEW.collected_at, NEW.metric_id, NEW.doc_id, NEW.raw_capture_id) RETURNING id INTO NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE vi_observation_base SET obs_date = NEW.obs_date, period = NEW.period, basis = COALESCE(NEW.basis, '时点'), value = NEW.value, yoy = NEW.yoy, summary = NEW.summary, collected_at = NEW.collected_at, metric_id = NEW.metric_id, doc_id = NEW.doc_id, raw_capture_id = NEW.raw_capture_id WHERE id = OLD.id;
    RETURN NEW;
  ELSE
    DELETE FROM vi_observation_base WHERE id = OLD.id;
    RETURN OLD;
  END IF;
END $$;

CREATE TRIGGER vi_observation_dml INSTEAD OF INSERT OR UPDATE OR DELETE ON vi_observation FOR EACH ROW EXECUTE FUNCTION vi_observation_dml();

DROP VIEW IF EXISTS vi_bs_item CASCADE;

CREATE VIEW vi_bs_item AS
SELECT b.id,
       b.category,
       b.line_item,
       b.name,
       b.haircut,
       b.adjustment,
       b.basis,
       b.sort,
       b.company_id,
       c.as_of,
       c.book,
       c.revalued,
       c.book_signed,
       c.value_signed,
       c.role,
       b.updated_at
FROM vi_bs_item_base b LEFT JOIN vi_bs_item_calc c ON c.id = b.id;

COMMENT ON VIEW vi_bs_item IS '资产负债重估（界面视图：输入列＋自动计算列）';

CREATE OR REPLACE FUNCTION vi_bs_item_dml() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO vi_bs_item_base (category, line_item, name, haircut, adjustment, basis, sort, company_id) VALUES (NEW.category, NEW.line_item, NEW.name, NEW.haircut, NEW.adjustment, NEW.basis, NEW.sort, NEW.company_id) RETURNING id INTO NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE vi_bs_item_base SET category = NEW.category, line_item = NEW.line_item, name = NEW.name, haircut = NEW.haircut, adjustment = NEW.adjustment, basis = NEW.basis, sort = NEW.sort, company_id = NEW.company_id WHERE id = OLD.id;
    RETURN NEW;
  ELSE
    DELETE FROM vi_bs_item_base WHERE id = OLD.id;
    RETURN OLD;
  END IF;
END $$;

CREATE TRIGGER vi_bs_item_dml INSTEAD OF INSERT OR UPDATE OR DELETE ON vi_bs_item FOR EACH ROW EXECUTE FUNCTION vi_bs_item_dml();

DROP VIEW IF EXISTS vi_epv CASCADE;

CREATE VIEW vi_epv AS
SELECT b.id,
       b.sort,
       b.name,
       b.section,
       b.direction,
       b.formula,
       b.method,
       b.value,
       b.from_year,
       b.to_year,
       b.note,
       b.company_id,
       b.business_id,
       c.history,
       c.normalized,
       c.ratio,
       b.updated_at
FROM vi_epv_base b LEFT JOIN vi_epv_calc c ON c.id = b.id;

COMMENT ON VIEW vi_epv IS '调整后利润表（界面视图：输入列＋自动计算列）';

CREATE OR REPLACE FUNCTION vi_epv_dml() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO vi_epv_base (sort, name, section, direction, formula, method, value, from_year, to_year, note, company_id, business_id) VALUES (NEW.sort, NEW.name, NEW.section, NEW.direction, NEW.formula, NEW.method, NEW.value, NEW.from_year, NEW.to_year, NEW.note, NEW.company_id, NEW.business_id) RETURNING id INTO NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE vi_epv_base SET sort = NEW.sort, name = NEW.name, section = NEW.section, direction = NEW.direction, formula = NEW.formula, method = NEW.method, value = NEW.value, from_year = NEW.from_year, to_year = NEW.to_year, note = NEW.note, company_id = NEW.company_id, business_id = NEW.business_id WHERE id = OLD.id;
    RETURN NEW;
  ELSE
    DELETE FROM vi_epv_base WHERE id = OLD.id;
    RETURN OLD;
  END IF;
END $$;

CREATE TRIGGER vi_epv_dml INSTEAD OF INSERT OR UPDATE OR DELETE ON vi_epv FOR EACH ROW EXECUTE FUNCTION vi_epv_dml();

DROP VIEW IF EXISTS vi_growth CASCADE;

CREATE VIEW vi_growth AS
SELECT b.id,
       b.growth,
       b.ronic,
       b.adv_years,
       b.note,
       b.revenue_plan,
       b.company_id,
       b.business_id,
       b.updated_at
FROM vi_growth_base b;

COMMENT ON VIEW vi_growth IS '增长（界面视图：输入列＋自动计算列）';

CREATE OR REPLACE FUNCTION vi_growth_dml() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO vi_growth_base (growth, ronic, adv_years, note, revenue_plan, company_id, business_id) VALUES (NEW.growth, NEW.ronic, NEW.adv_years, NEW.note, NEW.revenue_plan, NEW.company_id, NEW.business_id) RETURNING id INTO NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE vi_growth_base SET growth = NEW.growth, ronic = NEW.ronic, adv_years = NEW.adv_years, note = NEW.note, revenue_plan = NEW.revenue_plan, company_id = NEW.company_id, business_id = NEW.business_id WHERE id = OLD.id;
    RETURN NEW;
  ELSE
    DELETE FROM vi_growth_base WHERE id = OLD.id;
    RETURN OLD;
  END IF;
END $$;

CREATE TRIGGER vi_growth_dml INSTEAD OF INSERT OR UPDATE OR DELETE ON vi_growth FOR EACH ROW EXECUTE FUNCTION vi_growth_dml();

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

COMMENT ON VIEW vi_issue IS '待办清单（界面视图：输入列＋自动计算列）';

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

DROP VIEW IF EXISTS vi_setting CASCADE;

CREATE VIEW vi_setting AS
SELECT b.id,
       b.name,
       b.hurdle,
       b.note,
       b.updated_at
FROM vi_setting_base b;

COMMENT ON VIEW vi_setting IS '统一设置（界面视图：输入列＋自动计算列）';

CREATE OR REPLACE FUNCTION vi_setting_dml() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO vi_setting_base (name, hurdle, note) VALUES (NEW.name, NEW.hurdle, NEW.note) RETURNING id INTO NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE vi_setting_base SET name = NEW.name, hurdle = NEW.hurdle, note = NEW.note WHERE id = OLD.id;
    RETURN NEW;
  ELSE
    DELETE FROM vi_setting_base WHERE id = OLD.id;
    RETURN OLD;
  END IF;
END $$;

CREATE TRIGGER vi_setting_dml INSTEAD OF INSERT OR UPDATE OR DELETE ON vi_setting FOR EACH ROW EXECUTE FUNCTION vi_setting_dml();

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
