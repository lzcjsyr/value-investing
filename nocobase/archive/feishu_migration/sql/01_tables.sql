-- 自动生成：gen_sql.py。输入表与关联表

BEGIN;

CREATE TABLE cj_guide_base (
  id bigserial PRIMARY KEY,
  topic text,
  rules text,
  scope text,
  feishu_id text UNIQUE
);

CREATE TABLE cj_biz_model_base (
  id bigserial PRIMARY KEY,
  proposition text,
  company_code text,
  earning_mechanism text,
  moat_evidence text,
  counter_view text,
  financial_mapping text,
  current_view text,
  feishu_id text UNIQUE
);

CREATE TABLE cj_evidence_base (
  id bigserial PRIMARY KEY,
  evidence_id text,
  company_code text,
  report_period text,
  source_type text,
  fact_text text,
  source_link text,
  published_date text,
  fetched_date text,
  verify_status text,
  scope_limits text,
  legacy_ref text,
  feishu_id text UNIQUE
);

CREATE TABLE cj_fact_mapping_base (
  id bigserial PRIMARY KEY,
  mapping_id text,
  fact_layer text,
  judgment text,
  math_transmission text,
  param_key text,
  affected_years text,
  change_threshold text,
  no_change_condition text,
  counter_evidence text,
  judgment_status text,
  feishu_id text UNIQUE
);

CREATE TABLE cj_scenario_base (
  id bigserial PRIMARY KEY,
  scenario text,
  company_code text,
  volume_factor double precision,
  price_factor double precision,
  cash_cost_factor double precision,
  discount_rate double precision,
  terminal_growth double precision,
  terminal_year bigint,
  valuation_base_year bigint,
  shares_yi double precision,
  base_price double precision,
  base_other_contrib double precision,
  base_burden_rate double precision,
  base_payout double precision,
  base_rf_pct double precision,
  base_erp_pct double precision,
  rate_date text,
  legacy_price double precision,
  price_date text,
  assumption_nature text,
  publish_status text,
  scenario_note text,
  feishu_id text UNIQUE
);

CREATE TABLE cj_annual_base (
  id bigserial PRIMARY KEY,
  year_key text,
  company_code text,
  year bigint,
  volume double precision,
  price double precision,
  cash_cost double precision,
  depreciation double precision,
  interest double precision,
  other_contrib double precision,
  burden_rate double precision,
  payout double precision,
  attrib_da_addback double precision,
  noncash_gain_deduct double precision,
  invest_cash_dividend double precision,
  other_cash_adj double precision,
  wc_increase double precision,
  maint_capex double precision,
  growth_capex double precision,
  net_borrowing double precision,
  min_cash_topup double precision,
  cash_bridge_note text,
  evidence_status text,
  feishu_id text UNIQUE
);

CREATE TABLE cj_fin_calc_base (
  id bigserial PRIMARY KEY,
  model_key text,
  scenario_name text,
  year bigint,
  annual_input_id bigint,
  scenario_input_id bigint,
  feishu_id text UNIQUE
);

CREATE TABLE cj_valuation_base (
  id bigserial PRIMARY KEY,
  scenario text,
  usage_note text,
  scenario_input_id bigint,
  feishu_id text UNIQUE
);

CREATE TABLE cj_sens_rg_base (
  id bigserial PRIMARY KEY,
  combo text,
  rate_shift double precision,
  growth_shift double precision,
  base_scenario_id bigint,
  feishu_id text UNIQUE
);

CREATE TABLE cj_param_trial_base (
  id bigserial PRIMARY KEY,
  trial text,
  start_year bigint,
  end_year bigint,
  volume_delta double precision,
  price_delta double precision,
  cash_cost_delta double precision,
  da_delta double precision,
  interest_delta double precision,
  rate_delta double precision,
  boundary text,
  base_scenario_id bigint,
  feishu_id text UNIQUE
);

CREATE TABLE cj_tracking_base (
  id bigserial PRIMARY KEY,
  task_id text,
  metric text,
  obs_code text,
  frequency text,
  preferred_source text,
  trigger_threshold text,
  threshold_nature text,
  action_after text,
  collect_status text,
  latest_obs_note text,
  obs_date_note text,
  feishu_id text UNIQUE
);

CREATE TABLE cj_market_obs_base (
  id bigserial PRIMARY KEY,
  obs_id text,
  metric_code text,
  metric text,
  obs_date text,
  value double precision,
  cloud_value_text text,
  unit text,
  source text,
  collected_at text,
  raw_file text,
  usage_boundary text,
  feishu_id text UNIQUE
);

CREATE TABLE cj_quality_base (
  id bigserial PRIMARY KEY,
  check_id text,
  level text,
  issue text,
  impact_scope text,
  done_condition text,
  status text,
  feishu_id text UNIQUE
);

CREATE TABLE cj_change_log_base (
  id bigserial PRIMARY KEY,
  change_id text,
  time_text text,
  target text,
  old_value text,
  new_value text,
  reason text,
  evidence_ref text,
  verify_status text,
  feishu_id text UNIQUE
);

CREATE TABLE cj_collect_ctl_base (
  id bigserial PRIMARY KEY,
  metric_code text,
  metric text,
  integration_status text,
  max_lag_days double precision,
  source_note text,
  workflow_entry text,
  last_selfcheck timestamptz,
  selfcheck_result text,
  feishu_id text UNIQUE
);

CREATE TABLE cj_collect_raw_base (
  id bigserial PRIMARY KEY,
  run_id text,
  metric_code text,
  source_url text,
  unit text,
  collected_at timestamptz,
  process_status text,
  raw_response text,
  feishu_id text UNIQUE
);

CREATE TABLE cj_v1_param_base (
  id bigserial PRIMARY KEY,
  param_name text,
  symbol text,
  category text,
  definition text,
  unit text,
  current_value text,
  model_role text,
  param_relation text,
  update_freq text,
  data_source text,
  source_note text,
  mapping_reason text,
  last_updated timestamptz,
  revision_log text,
  feishu_id text UNIQUE
);

CREATE TABLE cj_v1_annual_base (
  id bigserial PRIMARY KEY,
  year bigint,
  generation double precision,
  avg_price double precision,
  revenue double precision,
  net_profit double precision,
  da double precision,
  finance_cost double precision,
  invest_income double precision,
  cfo double precision,
  capex double precision,
  interest_debt double precision,
  dps double precision,
  dividend_total double precision,
  source text,
  note text,
  feishu_id text UNIQUE
);

CREATE TABLE cj_v1_quarterly_base (
  id bigserial PRIMARY KEY,
  period text,
  generation double precision,
  yoy_pct double precision,
  inflow_eval text,
  summary text,
  announcement_link text,
  status text,
  feishu_id text UNIQUE
);

CREATE TABLE cj_v1_source_base (
  id bigserial PRIMARY KEY,
  name text,
  source_type text,
  authority text,
  link text,
  update_freq text,
  usage_note text,
  feishu_id text UNIQUE
);

CREATE TABLE cj_v1_announce_base (
  id bigserial PRIMARY KEY,
  date timestamptz,
  title text,
  ann_type text,
  summary text,
  link text,
  status text,
  feishu_id text UNIQUE
);

CREATE TABLE cj_v1_thesis_base (
  id bigserial PRIMARY KEY,
  thesis text,
  category text,
  evidence text,
  falsification text,
  status text,
  feishu_id text UNIQUE
);

CREATE TABLE cj_v1_valuation_base (
  id bigserial PRIMARY KEY,
  scenario text,
  price double precision,
  price_date timestamptz,
  cgb10y double precision,
  erp double precision,
  r_pct double precision,
  g_pct double precision,
  shares_yi double precision,
  margin_pct double precision,
  fcfe_ps double precision,
  feishu_id text UNIQUE
);

CREATE TABLE cj_v1_forecast_base (
  id bigserial PRIMARY KEY,
  year bigint,
  generation double precision,
  avg_price double precision,
  cash_cost double precision,
  depreciation double precision,
  finance_cost double precision,
  other_contrib double precision,
  burden_pct double precision,
  payout_pct double precision,
  note text,
  feishu_id text UNIQUE
);

CREATE TABLE cj_v1_scenario_base (
  id bigserial PRIMARY KEY,
  scenario text,
  base_dps double precision,
  g1_pct double precision,
  r_pct double precision,
  g_pct double precision,
  note text,
  feishu_id text UNIQUE
);

CREATE TABLE cj_v1_sens_base (
  id bigserial PRIMARY KEY,
  combo text,
  r_pct double precision,
  g1_pct double precision,
  g_pct double precision,
  base_dps double precision,
  note text,
  feishu_id text UNIQUE
);

CREATE TABLE cj_lnk_evidence_scenarios (
  evidence_id bigint NOT NULL REFERENCES cj_evidence_base(id) ON DELETE CASCADE,
  scenario_id bigint NOT NULL REFERENCES cj_scenario_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (evidence_id, scenario_id)
);

CREATE TABLE cj_lnk_fact_mapping_biz_models (
  fact_mapping_id bigint NOT NULL REFERENCES cj_fact_mapping_base(id) ON DELETE CASCADE,
  biz_model_id bigint NOT NULL REFERENCES cj_biz_model_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (fact_mapping_id, biz_model_id)
);

CREATE TABLE cj_lnk_fact_mapping_evidences (
  fact_mapping_id bigint NOT NULL REFERENCES cj_fact_mapping_base(id) ON DELETE CASCADE,
  evidence_id bigint NOT NULL REFERENCES cj_evidence_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (fact_mapping_id, evidence_id)
);

CREATE TABLE cj_lnk_annual_evidences (
  annual_id bigint NOT NULL REFERENCES cj_annual_base(id) ON DELETE CASCADE,
  evidence_id bigint NOT NULL REFERENCES cj_evidence_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (annual_id, evidence_id)
);

CREATE TABLE cj_lnk_annual_mappings (
  annual_id bigint NOT NULL REFERENCES cj_annual_base(id) ON DELETE CASCADE,
  fact_mapping_id bigint NOT NULL REFERENCES cj_fact_mapping_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (annual_id, fact_mapping_id)
);

CREATE TABLE cj_lnk_valuation_forecast_rows (
  valuation_id bigint NOT NULL REFERENCES cj_valuation_base(id) ON DELETE CASCADE,
  fin_calc_id bigint NOT NULL REFERENCES cj_fin_calc_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (valuation_id, fin_calc_id)
);

CREATE TABLE cj_lnk_param_trial_mappings (
  param_trial_id bigint NOT NULL REFERENCES cj_param_trial_base(id) ON DELETE CASCADE,
  fact_mapping_id bigint NOT NULL REFERENCES cj_fact_mapping_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (param_trial_id, fact_mapping_id)
);

CREATE TABLE cj_lnk_tracking_mappings (
  tracking_id bigint NOT NULL REFERENCES cj_tracking_base(id) ON DELETE CASCADE,
  fact_mapping_id bigint NOT NULL REFERENCES cj_fact_mapping_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (tracking_id, fact_mapping_id)
);

CREATE TABLE cj_lnk_v1_source_params (
  v1_source_id bigint NOT NULL REFERENCES cj_v1_source_base(id) ON DELETE CASCADE,
  v1_param_id bigint NOT NULL REFERENCES cj_v1_param_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (v1_source_id, v1_param_id)
);

CREATE TABLE cj_lnk_v1_announce_params (
  v1_announce_id bigint NOT NULL REFERENCES cj_v1_announce_base(id) ON DELETE CASCADE,
  v1_param_id bigint NOT NULL REFERENCES cj_v1_param_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (v1_announce_id, v1_param_id)
);

CREATE TABLE cj_lnk_v1_thesis_params (
  v1_thesis_id bigint NOT NULL REFERENCES cj_v1_thesis_base(id) ON DELETE CASCADE,
  v1_param_id bigint NOT NULL REFERENCES cj_v1_param_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (v1_thesis_id, v1_param_id)
);

COMMIT;
