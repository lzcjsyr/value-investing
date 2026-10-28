-- 新增「财务预测」表（2026-10-28）：券商研报式逐年利润表与现金摘要，供只用分部加总三块的公司（腾讯音乐）使用。
-- 表结构由 spec.py 的 fin_forecast 生成（gen_sql.py → 01_schema.sql，这里摘出建表语句）；计算视图 vi_fin_forecast_calc 在 02_calc.sql。
-- 顺序：本迁移 → 02_calc.sql → 03_ui.sql → 登记集合 vi_fin_forecast（register.collection_body）→ 重启 app。
BEGIN;
CREATE TABLE vi_fin_forecast_base (
  id bigserial PRIMARY KEY,
  year integer,
  sub_rev double precision,
  nonsub_rev double precision,
  social_rev double precision,
  gross_margin double precision,
  selling_ratio double precision,
  admin_ratio double precision,
  other_income double precision,
  equity_income double precision,
  finance_cost double precision,
  tax_rate double precision,
  minority_share double precision,
  sbc double precision,
  acq_amort double precision,
  cfo_ratio double precision,
  capex double precision,
  shareholder_return double precision,
  other_cash double precision,
  note text,
  model_id bigint,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE vi_fin_forecast_base IS '财务预测：券商研报式的逐年利润表与现金摘要预测（只用分部加总三块的公司，如腾讯音乐）；引用【估值模型】。每个预测年一行：三块收入、毛利率、费用率、其他收入与融资成本、税率、现金转化与资本开支、股东回报；利润表与期末净现金由计算列得出。只作财务预测，不做股息贴现；估值模型的 2027 年三块收入与这里一致。';

COMMENT ON COLUMN vi_fin_forecast_base.year IS '年度';

COMMENT ON COLUMN vi_fin_forecast_base.sub_rev IS '会员订阅收入（亿元）：含长音频会员';

COMMENT ON COLUMN vi_fin_forecast_base.nonsub_rev IS '非订阅音乐收入（亿元）：广告、演出、周边、艺人经纪';

COMMENT ON COLUMN vi_fin_forecast_base.social_rev IS '社交娱乐收入（亿元）：直播打赏';

COMMENT ON COLUMN vi_fin_forecast_base.gross_margin IS '毛利率（小数，0.05＝5%）';

COMMENT ON COLUMN vi_fin_forecast_base.selling_ratio IS '销售费用率：销售及分销费用÷营业收入（小数，0.05＝5%）';

COMMENT ON COLUMN vi_fin_forecast_base.admin_ratio IS '管理费用率：行政开支（含研发、股权激励、收购摊销）÷营业收入（小数，0.05＝5%）';

COMMENT ON COLUMN vi_fin_forecast_base.other_income IS '其他收入及收益（亿元）：利息收入为主，不含一次性收益';

COMMENT ON COLUMN vi_fin_forecast_base.equity_income IS '联营公司收益（亿元）';

COMMENT ON COLUMN vi_fin_forecast_base.finance_cost IS '融资成本（亿元）';

COMMENT ON COLUMN vi_fin_forecast_base.tax_rate IS '所得税率（小数，0.05＝5%）';

COMMENT ON COLUMN vi_fin_forecast_base.minority_share IS '少数股东占比：少数股东损益占净利润的比例（小数，0.05＝5%）';

COMMENT ON COLUMN vi_fin_forecast_base.sbc IS '股权激励（亿元）：经调整归母净利加回';

COMMENT ON COLUMN vi_fin_forecast_base.acq_amort IS '收购摊销（亿元）：经调整归母净利加回';

COMMENT ON COLUMN vi_fin_forecast_base.cfo_ratio IS '经营现金流÷归母净利';

COMMENT ON COLUMN vi_fin_forecast_base.capex IS '资本开支（亿元）';

COMMENT ON COLUMN vi_fin_forecast_base.shareholder_return IS '股东回报（亿元）：当年支付的股息＋回购（现金口径）';

COMMENT ON COLUMN vi_fin_forecast_base.other_cash IS '其他现金变动（亿元）：并购等影响净现金的项目；借款同时增加现金与负债，不影响净现金';

COMMENT ON COLUMN vi_fin_forecast_base.note IS '说明';

COMMENT ON COLUMN vi_fin_forecast_base.model_id IS '估值模型（关联 估值模型）';

CREATE TRIGGER vi_fin_forecast_base_touch BEFORE UPDATE ON vi_fin_forecast_base FOR EACH ROW EXECUTE FUNCTION vi_touch_updated_at();

ALTER TABLE vi_fin_forecast_base ADD FOREIGN KEY (model_id) REFERENCES vi_model_base(id) ON DELETE SET NULL;
CREATE INDEX ON vi_fin_forecast_base (model_id);
ALTER TABLE vi_fin_forecast_base ADD CONSTRAINT vi_fin_forecast_uniq UNIQUE (model_id, year);
COMMIT;
