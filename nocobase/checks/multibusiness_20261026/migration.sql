BEGIN;


CREATE TABLE vi_business_base (
  id bigserial PRIMARY KEY, code text, name text, boundary text,
  cost_allocation text, asset_boundary text, sort integer,
  company_id bigint REFERENCES vi_company_base(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT vi_business_uniq UNIQUE (company_id, code)
);
CREATE INDEX ON vi_business_base(company_id);
CREATE TRIGGER vi_business_base_touch BEFORE UPDATE ON vi_business_base
  FOR EACH ROW EXECUTE FUNCTION vi_touch_updated_at();
ALTER TABLE vi_biz_model_base ADD COLUMN business_id bigint REFERENCES vi_business_base(id) ON DELETE SET NULL;
ALTER TABLE vi_sotp_segment_base ADD COLUMN business_id bigint REFERENCES vi_business_base(id) ON DELETE SET NULL;
ALTER TABLE vi_sotp_item_base ADD COLUMN business_id bigint REFERENCES vi_business_base(id) ON DELETE SET NULL;
ALTER TABLE vi_sotp_item_base ADD COLUMN treatment text DEFAULT '单独计价';
ALTER TABLE vi_sotp_item_base ADD COLUMN valuation_method text;
ALTER TABLE vi_sotp_item_base ADD COLUMN boundary text;
CREATE INDEX ON vi_biz_model_base(business_id);
CREATE INDEX ON vi_sotp_segment_base(business_id);
CREATE INDEX ON vi_sotp_item_base(business_id);
ALTER TABLE vi_biz_model_base DROP CONSTRAINT vi_biz_model_uniq;
ALTER TABLE vi_biz_model_base ADD CONSTRAINT vi_biz_model_uniq
  UNIQUE NULLS NOT DISTINCT (company_id, business_id, code);


-- 业务身份的公司归属、估值情景归属，以及避免重复计价所需的边界约束。
CREATE OR REPLACE FUNCTION vi_business_scope_guard() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE owner_id bigint; business_owner bigint;
BEGIN
  IF TG_TABLE_NAME = 'vi_biz_model_base' THEN owner_id := NEW.company_id;
  ELSE
    SELECT company_id INTO owner_id FROM vi_model_base WHERE id = NEW.model_id;
    IF NEW.scenario_id IS NOT NULL AND NOT EXISTS
       (SELECT 1 FROM vi_scenario_base WHERE id = NEW.scenario_id AND model_id = NEW.model_id) THEN
      RAISE EXCEPTION '适用情景必须属于当前估值模型';
    END IF;
  END IF;
  IF NEW.business_id IS NOT NULL THEN
    SELECT company_id INTO business_owner FROM vi_business_base WHERE id = NEW.business_id;
    IF owner_id IS NULL OR business_owner IS DISTINCT FROM owner_id THEN
      RAISE EXCEPTION '所属业务必须属于当前公司或估值模型所在公司';
    END IF;
  END IF;
  IF TG_TABLE_NAME = 'vi_sotp_item_base' THEN
    IF NEW.treatment IS NULL OR NEW.treatment NOT IN ('单独计价', '已含业务估值', '不计价') THEN
      RAISE EXCEPTION '请填写有效的计价处理';
    END IF;
    IF NEW.treatment = '已含业务估值' AND NEW.business_id IS NULL THEN
      RAISE EXCEPTION '已含业务估值的资产必须关联具体业务';
    END IF;
    IF NEW.kind IN ('固定资产', '其他非经营资产') AND
       (NEW.boundary IS NULL OR btrim(NEW.boundary) = '') THEN
      RAISE EXCEPTION '固定资产及其他非经营资产必须说明计价边界';
    END IF;
    IF NEW.haircut IS NOT NULL AND (NEW.haircut < 0 OR NEW.haircut > 1) THEN
      RAISE EXCEPTION '折价必须在 0 到 1 之间';
    END IF;
  END IF;
  RETURN NEW;
END $$;
DROP TRIGGER IF EXISTS vi_biz_model_business_scope ON vi_biz_model_base;
CREATE TRIGGER vi_biz_model_business_scope BEFORE INSERT OR UPDATE ON vi_biz_model_base
  FOR EACH ROW EXECUTE FUNCTION vi_business_scope_guard();
DROP TRIGGER IF EXISTS vi_sotp_segment_business_scope ON vi_sotp_segment_base;
CREATE TRIGGER vi_sotp_segment_business_scope BEFORE INSERT OR UPDATE ON vi_sotp_segment_base
  FOR EACH ROW EXECUTE FUNCTION vi_business_scope_guard();
DROP TRIGGER IF EXISTS vi_sotp_item_business_scope ON vi_sotp_item_base;
CREATE TRIGGER vi_sotp_item_business_scope BEFORE INSERT OR UPDATE ON vi_sotp_item_base
  FOR EACH ROW EXECUTE FUNCTION vi_business_scope_guard();
CREATE UNIQUE INDEX IF NOT EXISTS vi_sotp_segment_business_scenario_uniq
  ON vi_sotp_segment_base (model_id, business_id, scenario_id) NULLS NOT DISTINCT
  WHERE business_id IS NOT NULL;

-- 业务一旦被引用，不允许改变其所属公司或删除为集团记录。
CREATE OR REPLACE FUNCTION vi_business_owner_guard() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'DELETE' OR NEW.company_id IS DISTINCT FROM OLD.company_id THEN
    IF EXISTS (SELECT 1 FROM vi_biz_model_base WHERE business_id = OLD.id)
       OR EXISTS (SELECT 1 FROM vi_sotp_segment_base WHERE business_id = OLD.id)
       OR EXISTS (SELECT 1 FROM vi_sotp_item_base WHERE business_id = OLD.id) THEN
      RAISE EXCEPTION '业务仍被商业模式或估值引用，请先处理关联记录';
    END IF;
  END IF;
  IF TG_OP = 'DELETE' THEN RETURN OLD; END IF;
  RETURN NEW;
END $$;
DROP TRIGGER IF EXISTS vi_business_owner ON vi_business_base;
CREATE TRIGGER vi_business_owner BEFORE UPDATE OR DELETE ON vi_business_base
  FOR EACH ROW EXECUTE FUNCTION vi_business_owner_guard();


COMMENT ON TABLE vi_business_base IS '业务分部：商业模式和业务估值共用的业务身份；不随模型或情景重复；被【商业模式拆解】【资产估值与调整】【经营分部估值】【分部逐情景计算】引用。一家公司的一块业务一行。明确业务边界、共享费用分摊与经营资产归属；现金、投资和可单独处置资产在资产估值与调整中处理。';

COMMENT ON COLUMN vi_business_base.code IS '业务编号';

COMMENT ON COLUMN vi_business_base.name IS '业务名称';

COMMENT ON COLUMN vi_business_base.boundary IS '业务边界';

COMMENT ON COLUMN vi_business_base.cost_allocation IS '费用分摊依据';

COMMENT ON COLUMN vi_business_base.asset_boundary IS '经营资产与投入边界';

COMMENT ON COLUMN vi_business_base.sort IS '排序';

COMMENT ON COLUMN vi_business_base.company_id IS '公司（关联 公司）';

COMMENT ON TABLE vi_biz_model_base IS '商业模式拆解：用商业模式画布 9 项讲清公司怎么赚钱；引用【重要事实】【业务分部】。商业模式画布 9 项，每块业务一项一行（B1—B9 按画布顺序）；所属业务留空表示集团整体或共性，不表示自动继承。投资者关心的内容放进画布：盈利公式的收入一侧、收入结构、单价、增长与周期写在“收入来源”；盈利公式的成本一侧、成本构成、单位利润、资本需求与现金循环写在“成本结构”。只写事实与机制；有争议、决定价值的判断写在核心论点里。';

COMMENT ON COLUMN vi_biz_model_base.code IS '编号：B1—B9，按画布顺序；在公司和所属业务内唯一';

COMMENT ON COLUMN vi_biz_model_base.element IS '要素：客户细分：卖给谁｜价值主张：为什么买｜渠道通路：怎么触达和交付｜客户关系：怎么留住、合同与结算方式｜收入来源：收入公式（量×价）、结构、单价、增长与周期｜核心资源：不可或缺的资产与能力｜关键业务：公司自己做的事｜重要合作：控股股东、供应商、伙伴｜成本结构：成本构成、经营杠杆、单位利润、资本需求与现金循环（可选：客户细分、价值主张、渠道通路、客户关系、收入来源、核心资源、关键业务、重要合作、成本结构）';

COMMENT ON COLUMN vi_biz_model_base.title IS '要点';

COMMENT ON COLUMN vi_biz_model_base.content IS '说明';

COMMENT ON COLUMN vi_biz_model_base.metric IS '关键数字：如 毛利率 44%；ARPPU 11.9 元';

COMMENT ON COLUMN vi_biz_model_base.trend IS '变化与风险';

COMMENT ON COLUMN vi_biz_model_base.company_id IS '公司（关联 公司）';

COMMENT ON COLUMN vi_biz_model_base.business_id IS '所属业务（关联 业务分部）';

COMMENT ON TABLE vi_sotp_item_base IS '资产估值与调整：现金、投资、固定资产等独立价值，以及负债和归属调整；标明是否已含在业务价值中；引用【重要事实】【业务分部】【估值模型】【情景】；被【分部加总估值】引用。总价值＝业务估值＋资产估值与调整净额。单独计价的资产加计、负债扣减；已含业务估值或不计价的项目只作边界说明，计入值为零。固定资产只有在相关盈利、租金或处置收益未计入业务价值时才单独加计。情景留空＝全部，同编号情景专属行优先。';

COMMENT ON COLUMN vi_sotp_item_base.code IS '编号：如 C1；同一编号可按情景各写一行';

COMMENT ON COLUMN vi_sotp_item_base.name IS '项目';

COMMENT ON COLUMN vi_sotp_item_base.kind IS '类别（可选：现金及等价物、带息负债、经营所需现金、资金汇出成本、对外投资、固定资产、其他非经营资产、少数股东权益、其他调整）';

COMMENT ON COLUMN vi_sotp_item_base.treatment IS '计价处理：已含业务估值或不计价不再加总；单独计价金额未知时不输出总价值（可选：单独计价、已含业务估值、不计价）';

COMMENT ON COLUMN vi_sotp_item_base.valuation_method IS '资产计价依据：金额的计量方式；具体推导与截至日期写在依据（可选：账面价值、市场价值、可变现净值、现值、研究估计）';

COMMENT ON COLUMN vi_sotp_item_base.boundary IS '计价边界：说明与业务盈利、净现金、投资及其他资产项目的重叠如何排除';

COMMENT ON COLUMN vi_sotp_item_base.amount IS '金额（亿元）：填正数，现金、投资、固定资产和其他非经营资产为加；负债等为减；其他调整按填写正负号。空白＝未知';

COMMENT ON COLUMN vi_sotp_item_base.haircut IS '折价：对金额打的折扣，如对外投资的持有折价与处置税费（小数，0.05＝5%）';

COMMENT ON COLUMN vi_sotp_item_base.as_of IS '截至';

COMMENT ON COLUMN vi_sotp_item_base.basis IS '依据';

COMMENT ON COLUMN vi_sotp_item_base.model_id IS '估值模型（关联 估值模型）';

COMMENT ON COLUMN vi_sotp_item_base.scenario_id IS '适用情景（关联 情景）';

COMMENT ON COLUMN vi_sotp_item_base.business_id IS '相关业务（关联 业务分部）';

COMMENT ON TABLE vi_sotp_segment_base IS '经营分部估值：分部加总里每个经营业务的估值；引用【重要事实】【业务分部】【估值模型】【情景】；被【分部逐情景计算】【分部加总估值】【自动检查】引用。分部加总里的经营业务，按发展阶段各用一种方法：成熟或周期业务用“盈利×倍数”（正常化盈利）；成长业务用“稳态折现”（稳态年盈利×退出倍数折回今天，加上到稳态前的期间现金流）；投入期业务用“承诺投入”（只计已承诺的成本，回报不计入）。一行一个分部；适用情景留空＝所有情景，同编号可按情景另写一行。';

COMMENT ON COLUMN vi_sotp_segment_base.code IS '编号：如 S1；同一编号可按情景各写一行';

COMMENT ON COLUMN vi_sotp_segment_base.name IS '分部';

COMMENT ON COLUMN vi_sotp_segment_base.method IS '估值方法：盈利×倍数＝成熟或周期业务；稳态折现＝成长业务；承诺投入＝投入期业务（负值）；直接估值＝按可比公司或主观判断给整体价值（可选：盈利×倍数、稳态折现、承诺投入、直接估值）';

COMMENT ON COLUMN vi_sotp_segment_base.stage IS '发展阶段：如 成熟·周期底部、成长·规模爬坡、投入期';

COMMENT ON COLUMN vi_sotp_segment_base.earn_year IS '盈利年份：盈利×倍数＝正常化盈利所在年份；稳态折现＝稳态年份。价值按“该年年初价值＝该年盈利×倍数”折回资产负债日，例如资产负债日 2026-06-30、盈利年份 2027 年时折回 0.5 年';

COMMENT ON COLUMN vi_sotp_segment_base.revenue IS '收入（亿元）：盈利年份的分部收入；承诺投入不填';

COMMENT ON COLUMN vi_sotp_segment_base.op_margin IS '经营利润率：已扣股权激励，不含利息、投资收益与补贴（小数，0.05＝5%）';

COMMENT ON COLUMN vi_sotp_segment_base.tax_rate IS '所得税率：承诺投入填研发加计扣除后的实际抵税率（小数，0.05＝5%）';

COMMENT ON COLUMN vi_sotp_segment_base.attrib IS '归母比例：留空＝100%（小数，0.05＝5%）';

COMMENT ON COLUMN vi_sotp_segment_base.multiple IS '倍数（手填）：填了就用手填值；留空按 (1−g÷新增投资回报率)÷(r−g)';

COMMENT ON COLUMN vi_sotp_segment_base.ronic IS '新增投资回报率：留空＝情景的新增投资回报率（小数，0.05＝5%）';

COMMENT ON COLUMN vi_sotp_segment_base.growth IS '永续增长率：留空＝情景的永续增长率；承诺投入＝承诺期后年成本的增长率（小数，0.05＝5%）';

COMMENT ON COLUMN vi_sotp_segment_base.discount_rate IS '折现率：留空＝情景折现率；成长业务可加执行风险溢价（小数，0.05＝5%）';

COMMENT ON COLUMN vi_sotp_segment_base.interim_cash IS '期间现金流（亿元）：资产负债日到盈利年份年初之间的税后累计现金流（负数＝净投入），按期中折现';

COMMENT ON COLUMN vi_sotp_segment_base.commit_amount IS '承诺投入·剩余金额（亿元）：资产负债日之后尚需投入的税前金额（扣除相关收入）';

COMMENT ON COLUMN vi_sotp_segment_base.commit_years IS '承诺投入·剩余年数';

COMMENT ON COLUMN vi_sotp_segment_base.ongoing_cost IS '承诺期后年成本（亿元）：承诺期结束后每年仍需承担、没有回报覆盖的税前净成本；留空＝0';

COMMENT ON COLUMN vi_sotp_segment_base.direct_value IS '直接估值（亿元）：直接估值：按可比公司、交易价格或主观判断给出的整体价值（已含该业务未来的投入与回报），不折现';

COMMENT ON COLUMN vi_sotp_segment_base.basis IS '依据';

COMMENT ON COLUMN vi_sotp_segment_base.model_id IS '估值模型（关联 估值模型）';

COMMENT ON COLUMN vi_sotp_segment_base.scenario_id IS '适用情景（关联 情景）';

COMMENT ON COLUMN vi_sotp_segment_base.business_id IS '所属业务（关联 业务分部）';

CREATE OR REPLACE VIEW vi_sotp_item_calc AS
SELECT i.id,
       CASE WHEN i.treatment IN ('已含业务估值', '不计价') THEN 0
            WHEN i.kind = '其他调整' THEN i.amount
            WHEN i.kind IN ('现金及等价物', '对外投资', '固定资产', '其他非经营资产') THEN abs(i.amount)
            ELSE -abs(i.amount) END * (1 - coalesce(i.haircut, 0)) AS signed_value,
       coalesce(s.name, '全部情景') AS scope
FROM vi_sotp_item_base i LEFT JOIN vi_scenario_base s ON s.id = i.scenario_id;

CREATE OR REPLACE VIEW vi_sotp_segment_val AS
WITH pick AS (
  SELECT DISTINCT ON (s.id, coalesce('business:' || g.business_id::text, 'code:' || g.code))
         s.id AS scenario_id, s.model_id, s.name AS scenario_name, coalesce(s.is_base, false) AS is_base,
         g.id AS segment_id, g.code, g.name, g.method, g.earn_year, g.revenue, g.op_margin,
         coalesce(g.tax_rate, 0) AS tax_rate, coalesce(g.attrib, 1) AS attrib, g.multiple,
         coalesce(g.ronic, s.ronic) AS ronic, coalesce(g.growth, s.terminal_growth) AS growth,
         coalesce(g.discount_rate, x.eff_discount_rate) AS r, coalesce(g.interim_cash, 0) AS interim_cash,
         coalesce(g.commit_amount, 0) AS commit_amount, g.commit_years, coalesce(g.ongoing_cost, 0) AS ongoing_cost,
         g.direct_value, m.sotp_as_of AS as_of, g.business_id
  FROM vi_scenario_base s
  JOIN vi_scenario_calc x ON x.id = s.id
  JOIN vi_model_base m ON m.id = s.model_id
  JOIN vi_sotp_segment_base g ON g.model_id = s.model_id AND (g.scenario_id = s.id OR g.scenario_id IS NULL)
  ORDER BY s.id, coalesce('business:' || g.business_id::text, 'code:' || g.code), (g.scenario_id IS NULL)
), a AS (
  SELECT pick.*,
         CASE WHEN method = '承诺投入' THEN -ongoing_cost * (1 - tax_rate) * attrib
              WHEN method = '直接估值' THEN NULL
              ELSE revenue * op_margin * (1 - tax_rate) * attrib END AS earnings,
         CASE WHEN method IN ('盈利×倍数', '稳态折现') AND ronic > 0 AND r > growth THEN (1 - growth / ronic) / (r - growth) END AS formula_multiple,
         CASE WHEN method = '承诺投入' THEN commit_years
              WHEN method = '直接估值' THEN 0
              ELSE greatest(0, ((make_date(earn_year - 1, 12, 31) - as_of) / 365.25)::float8) END AS tau
  FROM pick
), b AS (
  SELECT a.*, CASE WHEN method IN ('盈利×倍数', '稳态折现') THEN coalesce(multiple, formula_multiple) END AS multiple_used FROM a
), c AS (
  SELECT b.*,
         CASE WHEN method = '承诺投入' THEN
                CASE WHEN ongoing_cost = 0 THEN 0
                     WHEN r > growth AND tau IS NOT NULL THEN -ongoing_cost * (1 - tax_rate) * attrib / (r - growth) / power(1 + r, tau) END
              WHEN method = '直接估值' THEN direct_value
              ELSE earnings * multiple_used / power(1 + r, tau) END AS terminal_pv,
         CASE WHEN method = '承诺投入' THEN
                CASE WHEN commit_amount = 0 THEN 0
                     WHEN tau > 0 AND r > 0 THEN -(commit_amount / tau) * (1 - tax_rate) * attrib * (1 - power(1 + r, -tau)) / r END
              WHEN method = '直接估值' THEN 0
              ELSE interim_cash / power(1 + r, tau / 2) END AS interim_pv,
         CASE WHEN method IN ('盈利×倍数', '稳态折现') THEN earnings / power(1 + r, tau) END AS earn_pv
  FROM b
)
SELECT scenario_id * 100000 + segment_id AS id, scenario_id, model_id, scenario_name, is_base, segment_id, code, name, method,
       earn_year, revenue, op_margin, tax_rate, attrib, r, growth, ronic, earnings, formula_multiple, multiple_used, tau,
       interim_cash, commit_amount, commit_years, ongoing_cost, direct_value, terminal_pv, interim_pv, earn_pv,
       terminal_pv + interim_pv AS value, business_id
FROM c;

CREATE OR REPLACE VIEW vi_sotp AS
WITH sc AS (
  SELECT s.id AS scenario_id, s.model_id, s.name AS scenario_name, coalesce(s.is_base, false) AS is_base, s.sort,
         x.eff_discount_rate AS r, s.terminal_growth AS g, s.ronic, s.sotp_multiple, s.probability,
         m.sotp_year, m.sotp_core_adj, m.sotp_as_of, m.shares, m.margin_low, m.margin_high, m.company_id,
         m.name AS model_name, co.name AS company_name, cc.latest_price, cc.latest_fx
  FROM vi_scenario_base s
  JOIN vi_scenario_calc x ON x.id = s.id
  JOIN vi_model_base m ON m.id = s.model_id
  LEFT JOIN vi_company_base co ON co.id = m.company_id
  LEFT JOIN vi_company_calc cc ON cc.id = m.company_id
  WHERE EXISTS (SELECT 1 FROM vi_sotp_item_base i WHERE i.model_id = m.id)
     OR EXISTS (SELECT 1 FROM vi_sotp_segment_base g WHERE g.model_id = m.id)
), core AS (
  SELECT sc.*, p.pretax - p.other_contrib + p.interest AS core_pretax,
         (p.pretax - p.other_contrib + p.interest) * p.np_parent / NULLIF(p.pretax, 0) + coalesce(sc.sotp_core_adj, 0) AS core_earnings
  FROM sc LEFT JOIN vi_projection p ON p.scenario_id = sc.scenario_id AND p.year = sc.sotp_year
), items AS (
  SELECT DISTINCT ON (c.scenario_id, i.code) c.scenario_id, i.kind, i.treatment, i.business_id, ic.signed_value
  FROM core c
  JOIN vi_sotp_item_base i ON i.model_id = c.model_id AND (i.scenario_id = c.scenario_id OR i.scenario_id IS NULL)
  JOIN vi_sotp_item_calc ic ON ic.id = i.id
  ORDER BY c.scenario_id, i.code, (i.scenario_id IS NULL)
), agg AS (
  SELECT scenario_id,
         sum(signed_value) FILTER (WHERE kind = '现金及等价物') AS cash,
         sum(signed_value) FILTER (WHERE kind = '带息负债') AS debt,
         sum(signed_value) FILTER (WHERE kind = '经营所需现金') AS op_cash,
         sum(signed_value) FILTER (WHERE kind = '资金汇出成本') AS repatriation,
         sum(signed_value) FILTER (WHERE kind = '对外投资') AS investments,
         sum(signed_value) FILTER (WHERE kind = '固定资产') AS fixed_assets,
         sum(signed_value) FILTER (WHERE kind = '其他非经营资产') AS other_assets,
         count(*) FILTER (WHERE signed_value IS NULL OR (treatment = '已含业务估值' AND NOT EXISTS
           (SELECT 1 FROM vi_sotp_segment_val v WHERE v.scenario_id = items.scenario_id AND v.business_id = items.business_id))) AS asset_incomplete,
         sum(signed_value) FILTER (WHERE kind IN ('少数股东权益', '其他调整')) AS minority_other,
         sum(signed_value) AS noncore
  FROM items GROUP BY scenario_id
), segs AS (
  SELECT scenario_id, count(*) AS n_segments, count(*) FILTER (WHERE value IS NULL) AS n_incomplete,
         sum(value) AS segments_value,
         sum(value) FILTER (WHERE method = '盈利×倍数') AS mature_value,
         sum(earnings) FILTER (WHERE method = '盈利×倍数') AS mature_earnings,
         sum(earn_pv) FILTER (WHERE method = '盈利×倍数') AS mature_earn_pv,
         sum(interim_pv) FILTER (WHERE method = '盈利×倍数') AS mature_interim_pv,
         sum(value) FILTER (WHERE method = '稳态折现') AS growth_value,
         sum(value) FILTER (WHERE method = '承诺投入') AS invest_value,
         sum(value) FILTER (WHERE method = '直接估值') AS direct_value
  FROM vi_sotp_segment_val GROUP BY scenario_id
), v AS (
  SELECT core.*, a.cash, a.debt, a.op_cash, a.repatriation, a.investments, a.minority_other,
         CASE WHEN coalesce(a.asset_incomplete, 0) = 0 THEN coalesce(a.noncore, 0) END AS noncore,
         a.fixed_assets, a.other_assets, coalesce(a.asset_incomplete, 0) AS asset_incomplete,
         coalesce(a.cash, 0) + coalesce(a.debt, 0) + coalesce(a.op_cash, 0) + coalesce(a.repatriation, 0) AS usable_net_cash,
         CASE WHEN core.ronic > 0 AND core.r > core.g THEN (1 - core.g / core.ronic) / (core.r - core.g) END AS formula_multiple,
         coalesce(sg.n_segments, 0) AS n_segments, coalesce(sg.n_incomplete, 0) AS n_incomplete,
         sg.segments_value, sg.mature_value, sg.mature_earnings, sg.mature_earn_pv, sg.mature_interim_pv, sg.growth_value, sg.invest_value,
         sg.direct_value
  FROM core LEFT JOIN agg a USING (scenario_id) LEFT JOIN segs sg USING (scenario_id)
), w AS (
  SELECT v.*, coalesce(v.sotp_multiple, v.formula_multiple) AS multiple FROM v
), x AS (
  SELECT w.*, w.core_earnings * w.multiple AS core_value,
         CASE WHEN w.n_incomplete = 0 AND w.asset_incomplete = 0 AND (w.sotp_year IS NULL OR w.core_earnings * w.multiple IS NOT NULL)
              THEN coalesce(w.core_earnings * w.multiple, 0) + coalesce(w.segments_value, 0) + w.noncore END AS equity_value
  FROM w
), y AS (
  SELECT x.*, x.equity_value / NULLIF(x.shares, 0) AS vps, x.latest_price * x.shares AS mcap FROM x
), z AS (
  SELECT y.*,
         CASE WHEN count(*) OVER pm = count(y.probability) OVER pm AND count(*) OVER pm = count(y.vps) OVER pm
              THEN sum(y.probability * y.vps) OVER pm / NULLIF(sum(y.probability) OVER pm, 0) END AS weighted_value,
         CASE WHEN y.mature_earn_pv > 0 THEN (y.mcap - y.noncore - coalesce(y.core_value, 0) - coalesce(y.growth_value, 0)
                                              - coalesce(y.invest_value, 0) - coalesce(y.direct_value, 0) - y.mature_interim_pv) / y.mature_earn_pv END AS implied_mature_multiple,
         CASE WHEN y.growth_value IS NOT NULL THEN y.mcap - y.noncore - coalesce(y.core_value, 0) - coalesce(y.mature_value, 0)
                                                   - coalesce(y.invest_value, 0) - coalesce(y.direct_value, 0) END AS implied_growth_value,
         (y.mature_value - y.mature_interim_pv) / NULLIF(y.mature_earn_pv, 0) AS mature_multiple
  FROM y WINDOW pm AS (PARTITION BY y.model_id)
)
SELECT z.scenario_id AS id, z.model_id, z.company_id, z.company_name, z.model_name, z.scenario_name, z.is_base, z.sort,
       z.sotp_year AS core_year, z.sotp_as_of AS as_of, z.core_pretax, z.core_earnings,
       z.r AS discount_rate, z.g AS terminal_growth, z.ronic, z.formula_multiple, z.multiple, z.core_value,
       z.segments_value, z.mature_value, z.mature_earnings, z.mature_multiple, z.growth_value, z.invest_value, z.direct_value,
       z.mature_earn_pv, z.mature_interim_pv,
       z.cash, z.debt, z.op_cash, z.repatriation, z.usable_net_cash, z.investments, z.minority_other, z.noncore,
       z.equity_value, z.shares, z.vps AS value_per_share, z.vps / NULLIF(z.latest_fx, 0) AS value_per_share_quote,
       z.latest_price AS market_price, z.latest_price / NULLIF(z.vps, 0) - 1 AS price_vs_value,
       (z.mcap - z.noncore - coalesce(z.segments_value, 0)) / NULLIF(z.core_earnings, 0) AS implied_core_multiple,
       z.implied_mature_multiple, z.implied_growth_value, z.probability, z.weighted_value,
       dv.value_today AS ddm_value, z.vps / NULLIF(dv.value_today, 0) - 1 AS diff_vs_ddm,
       z.vps * (1 - z.margin_low) AS watch_low, z.vps * (1 - z.margin_high) AS watch_high,
       CASE WHEN z.sotp_year IS NOT NULL AND z.core_earnings IS NULL THEN format('预测计算里没有 %s 年的数据，核心盈利无法计算', z.sotp_year)
            WHEN z.sotp_year IS NOT NULL AND z.multiple IS NULL THEN '没有合理倍数：在情景里填“合理倍数”或“新增投资回报率”'
            WHEN z.n_incomplete > 0 THEN format('经营分部有 %s 项输入不完整，无法计算（见「估值 / 经营分部估值」）', z.n_incomplete)
            WHEN z.asset_incomplete > 0 THEN format('资产估值与调整有 %s 项金额未知或缺少对应业务估值，暂不输出总价值', z.asset_incomplete)
            WHEN z.n_segments = 0 AND z.sotp_year IS NULL THEN format('纯资产估值：资产估值与调整净额 %s 亿元；股本 %s 亿股，每股 %s 元。',vi_fmt(z.noncore,0),vi_fmt(z.shares,2),vi_fmt(z.vps))
            WHEN z.n_segments = 0 THEN
              format('核心盈利 %s 亿元（%s 年）× 合理倍数 %s 倍 ＝ %s 亿元；可用净现金 %s 亿元；对外投资（折后）%s 亿元；少数股东权益与其他 %s 亿元；'
                     '股权价值 %s 亿元，每股 %s 元%s。市场价 %s 元，%s；市场给核心业务的隐含倍数 %s 倍。股息贴现口径 %s 元。',
                     vi_fmt(z.core_earnings, 1), z.sotp_year, vi_fmt(z.multiple, 1), vi_fmt(z.core_value, 0),
                     vi_fmt(z.usable_net_cash, 0), vi_fmt(z.investments, 0), vi_fmt(z.minority_other, 0),
                     vi_fmt(z.equity_value, 0), vi_fmt(z.vps),
                     CASE WHEN z.latest_fx IS NOT NULL THEN format('（约合股价币种 %s）', vi_fmt(z.vps / z.latest_fx)) ELSE '' END,
                     vi_fmt(z.latest_price),
                     CASE WHEN z.latest_price IS NULL THEN '暂无市场价'
                          WHEN z.latest_price > z.vps THEN format('高于每股价值 %s', vi_pct(z.latest_price / z.vps - 1))
                          ELSE format('低于每股价值 %s', vi_pct(1 - z.latest_price / z.vps)) END,
                     vi_fmt((z.mcap - z.noncore) / NULLIF(z.core_earnings, 0), 1),
                     vi_fmt(dv.value_today))
            ELSE
              format('%s经营分部合计 %s 亿元（成熟业务 %s、成长业务 %s、投入期业务 %s、直接估值业务 %s）；可用净现金 %s 亿元；对外投资（折后）%s 亿元；'
                     '少数股东权益与其他 %s 亿元；股权价值 %s 亿元，每股 %s 元%s。市场价 %s 元，%s。%s%s%s股息贴现口径 %s 元。',
                     CASE WHEN z.core_earnings IS NOT NULL THEN format('核心盈利 %s 亿元（%s 年）× %s 倍 ＝ %s 亿元；',
                          vi_fmt(z.core_earnings, 1), z.sotp_year, vi_fmt(z.multiple, 1), vi_fmt(z.core_value, 0)) ELSE '' END,
                     vi_fmt(z.segments_value, 0), vi_fmt(coalesce(z.mature_value, 0), 0), vi_fmt(coalesce(z.growth_value, 0), 0),
                     vi_fmt(coalesce(z.invest_value, 0), 0), vi_fmt(coalesce(z.direct_value, 0), 0), vi_fmt(z.usable_net_cash, 0), vi_fmt(z.investments, 0), vi_fmt(z.minority_other, 0),
                     vi_fmt(z.equity_value, 0), vi_fmt(z.vps),
                     CASE WHEN z.latest_fx IS NOT NULL THEN format('（约合股价币种 %s）', vi_fmt(z.vps / z.latest_fx)) ELSE '' END,
                     vi_fmt(z.latest_price),
                     CASE WHEN z.latest_price IS NULL THEN '暂无市场价'
                          WHEN z.latest_price > z.vps THEN format('高于每股价值 %s', vi_pct(z.latest_price / z.vps - 1))
                          ELSE format('低于每股价值 %s', vi_pct(1 - z.latest_price / z.vps)) END,
                     CASE WHEN z.implied_mature_multiple IS NOT NULL THEN format('其余部分按本模型取值时，市值对应成熟业务约 %s 倍正常化盈利（本模型 %s 倍）；',
                          vi_fmt(z.implied_mature_multiple, 1), vi_fmt(z.mature_multiple, 1)) ELSE '' END,
                     CASE WHEN z.implied_growth_value IS NOT NULL THEN format('或者说，市场为成长业务付了约 %s 亿元（本模型 %s 亿元）。',
                          vi_fmt(z.implied_growth_value, 0), vi_fmt(z.growth_value, 0)) ELSE '' END,
                     CASE WHEN z.weighted_value IS NOT NULL THEN format('按情景概率加权，每股 %s 元。', vi_fmt(z.weighted_value)) ELSE '' END,
                     vi_fmt(dv.value_today)) END
       || format(' 单独计价固定资产 %s 亿元，其他非经营资产 %s 亿元；业务估值与资产调整分开汇总，已含业务价值的资产不再加计。', vi_fmt(coalesce(z.fixed_assets, 0), 0), vi_fmt(coalesce(z.other_assets, 0), 0)) AS conclusion,
       CASE WHEN z.n_incomplete = 0 AND (z.sotp_year IS NULL OR z.core_earnings * z.multiple IS NOT NULL)
            THEN coalesce(z.core_value, 0) + coalesce(z.segments_value, 0) END AS business_value,
       z.noncore AS asset_value, z.fixed_assets, z.other_assets, z.asset_incomplete
FROM z LEFT JOIN vi_valuation dv ON dv.id = z.scenario_id;

DROP VIEW IF EXISTS vi_business CASCADE;

CREATE VIEW vi_business AS
SELECT b.id,
       b.code,
       b.name,
       b.boundary,
       b.cost_allocation,
       b.asset_boundary,
       b.sort,
       b.company_id,
       b.updated_at
FROM vi_business_base b;

COMMENT ON VIEW vi_business IS '业务分部（界面视图：输入列＋自动计算列）';

CREATE OR REPLACE FUNCTION vi_business_dml() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO vi_business_base (code, name, boundary, cost_allocation, asset_boundary, sort, company_id) VALUES (NEW.code, NEW.name, NEW.boundary, NEW.cost_allocation, NEW.asset_boundary, NEW.sort, NEW.company_id) RETURNING id INTO NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE vi_business_base SET code = NEW.code, name = NEW.name, boundary = NEW.boundary, cost_allocation = NEW.cost_allocation, asset_boundary = NEW.asset_boundary, sort = NEW.sort, company_id = NEW.company_id WHERE id = OLD.id;
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
       b.business_id,
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
    INSERT INTO vi_sotp_segment_base (code, name, method, stage, earn_year, revenue, op_margin, tax_rate, attrib, multiple, ronic, growth, discount_rate, interim_cash, commit_amount, commit_years, ongoing_cost, direct_value, basis, model_id, scenario_id, business_id) VALUES (NEW.code, NEW.name, NEW.method, NEW.stage, NEW.earn_year, NEW.revenue, NEW.op_margin, NEW.tax_rate, NEW.attrib, NEW.multiple, NEW.ronic, NEW.growth, NEW.discount_rate, NEW.interim_cash, NEW.commit_amount, NEW.commit_years, NEW.ongoing_cost, NEW.direct_value, NEW.basis, NEW.model_id, NEW.scenario_id, NEW.business_id) RETURNING id INTO NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE vi_sotp_segment_base SET code = NEW.code, name = NEW.name, method = NEW.method, stage = NEW.stage, earn_year = NEW.earn_year, revenue = NEW.revenue, op_margin = NEW.op_margin, tax_rate = NEW.tax_rate, attrib = NEW.attrib, multiple = NEW.multiple, ronic = NEW.ronic, growth = NEW.growth, discount_rate = NEW.discount_rate, interim_cash = NEW.interim_cash, commit_amount = NEW.commit_amount, commit_years = NEW.commit_years, ongoing_cost = NEW.ongoing_cost, direct_value = NEW.direct_value, basis = NEW.basis, model_id = NEW.model_id, scenario_id = NEW.scenario_id, business_id = NEW.business_id WHERE id = OLD.id;
    RETURN NEW;
  ELSE
    DELETE FROM vi_sotp_segment_base WHERE id = OLD.id;
    RETURN OLD;
  END IF;
END $$;

CREATE TRIGGER vi_sotp_segment_dml INSTEAD OF INSERT OR UPDATE OR DELETE ON vi_sotp_segment FOR EACH ROW EXECUTE FUNCTION vi_sotp_segment_dml();


DROP VIEW IF EXISTS vi_sotp_item CASCADE;

CREATE VIEW vi_sotp_item AS
SELECT b.id,
       b.code,
       b.name,
       b.kind,
       b.treatment,
       b.valuation_method,
       b.boundary,
       b.amount,
       b.haircut,
       b.as_of,
       b.basis,
       b.model_id,
       b.scenario_id,
       b.business_id,
       c.signed_value,
       c.scope,
       b.updated_at
FROM vi_sotp_item_base b LEFT JOIN vi_sotp_item_calc c ON c.id = b.id;

COMMENT ON VIEW vi_sotp_item IS '资产估值与调整（界面视图：输入列＋自动计算列）';

CREATE OR REPLACE FUNCTION vi_sotp_item_dml() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO vi_sotp_item_base (code, name, kind, treatment, valuation_method, boundary, amount, haircut, as_of, basis, model_id, scenario_id, business_id) VALUES (NEW.code, NEW.name, NEW.kind, COALESCE(NEW.treatment, '单独计价'), NEW.valuation_method, NEW.boundary, NEW.amount, NEW.haircut, NEW.as_of, NEW.basis, NEW.model_id, NEW.scenario_id, NEW.business_id) RETURNING id INTO NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE vi_sotp_item_base SET code = NEW.code, name = NEW.name, kind = NEW.kind, treatment = COALESCE(NEW.treatment, '单独计价'), valuation_method = NEW.valuation_method, boundary = NEW.boundary, amount = NEW.amount, haircut = NEW.haircut, as_of = NEW.as_of, basis = NEW.basis, model_id = NEW.model_id, scenario_id = NEW.scenario_id, business_id = NEW.business_id WHERE id = OLD.id;
    RETURN NEW;
  ELSE
    DELETE FROM vi_sotp_item_base WHERE id = OLD.id;
    RETURN OLD;
  END IF;
END $$;

CREATE TRIGGER vi_sotp_item_dml INSTEAD OF INSERT OR UPDATE OR DELETE ON vi_sotp_item FOR EACH ROW EXECUTE FUNCTION vi_sotp_item_dml();


INSERT INTO vi_business_base(company_id,code,name,boundary,cost_allocation,asset_boundary,sort) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),'S1','智能手机','手机硬件销售；互联网服务收入和利润归 S3，自研芯片等创新业务归 S5。','手机、AIoT、互联网共用生态营业费用，沿用 J-OPEX 按各自收入分摊；不能因分部独立而漏掉共同获客成本。','经营设备、品牌与渠道对盈利的贡献包含在业务价值中；经营所需现金由 C5 集团统一扣除，集团现金及投资不放进分部价值。',1) ON CONFLICT (company_id,code) DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S1'),'B1','客户细分','面向不同价位的手机用户','Redmi 覆盖入门市场，Xiaomi 数字旗舰与 Ultra 面向高端用户；用户规模与月活口径不能混用。',NULL,'境内外用户购买力和变现能力不同。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S1'),'B2','价值主张','性价比与高端化并行','以产品定义、供应链与影像等体验竞争；硬件获客后形成的互联网收入归 S3。',NULL,'高端化能否抵消存储等物料涨价需要持续验证。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S1'),'B3','渠道通路','电商、新零售及海外运营商','使用集团渠道；渠道共性见集团层，手机相关费用不能遗漏。',NULL,'门店扩张对费用率与销售效率的影响。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S1'),'B4','客户关系','硬件销售后维系设备与账户用户','手机销售形成设备用户基础；持续服务变现与硬件销售分别记录。',NULL,'换机流失会滞后影响互联网月活。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S1'),'B5','收入来源','收入＝出货量×平均售价','硬件收入与毛利单列；互联网变现不在手机分部重复确认。','业务估值 S1；正常化年份及收入见对应情景','销量、产品结构和存储周期影响正常化盈利。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S1'),'B6','核心资源','产品、供应链、品牌与设备用户基础','品牌和渠道属于共享能力；对经营盈利的贡献已包含在分部估值中。',NULL,'共享资源不等于各业务都能获得同样的超额利润。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S1'),'B7','关键业务','产品定义、研发与供应链管理','沿用现有集团画布的制造与研发描述；自研芯片创新业务暂放 S5。',NULL,'制造与研发边界须随披露更新。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S1'),'B8','重要合作','核心器件、影像与系统伙伴','依赖 SoC、存储、屏幕及系统生态伙伴，器件供应集中影响议价与成本。',NULL,'关键器件供需与替代可行性。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S1'),'B9','成本结构','硬件毛利减分摊费用','经营利润＝手机收入×毛利率−按收入分摊的生态营业费用；维持原税率、正常化年份和期间现金流。','共同费用分摊：J-OPEX；估值参数：S1','按收入分摊是研究假设，不能将推算损益等同公司披露分部利润。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_business_base(company_id,code,name,boundary,cost_allocation,asset_boundary,sort) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),'S2','AIoT 与生活消费产品','IoT 与生活消费产品，含其他相关业务；生态链公司的股权投资归资产项目 C8，不重复作为自营业务。','沿用 J-OPEX，按收入分摊生态共同费用；其他相关业务的收入与损益并入本分部。','服务经营的设备、渠道与品牌包含在业务价值中；对外股权持仓在 C8 单独计价，经营所需现金在 C5 统一处理。',2) ON CONFLICT (company_id,code) DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S2'),'B1','客户细分','个人设备与家庭消费用户','覆盖可穿戴、平板、电视、大家电等生活消费产品；连接设备数不是月活用户数。',NULL,'不同品类购买频率和竞争格局存在差异。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S2'),'B2','价值主张','产品性价比与设备协同','通过米家等设备连接提升跨品类使用体验；不把连接规模直接当作利润。',NULL,'生态锁定程度与产品独立竞争力需要分开验证。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S2'),'B3','渠道通路','集团新零售与电商渠道','共用渠道的机制见集团层；各品类渠道费用与销售结构影响分摊。',NULL,'渠道扩张与国补变化影响需求。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S2'),'B4','客户关系','多设备与家庭场景复购','多设备使用形成交叉销售机会，需以实际复购和毛利验证。',NULL,'设备连接不保证付费或复购。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S2'),'B5','收入来源','各类产品销售收入加总','估值口径合并 IoT 与生活消费产品和其他相关业务；对外股权投资另放 C8。','业务估值 S2，含其他相关业务','产品组合与补贴变化影响收入和毛利率。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S2'),'B6','核心资源','产品定义、渠道与生态链伙伴','共享品牌、零售渠道和设备生态；被投企业的股权价值不在此重复加计。',NULL,'合作利益与集团利益可能不一致。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S2'),'B7','关键业务','跨品类产品与供应链组织','围绕产品定义、供应链、渠道与设备连接开展经营；各品类的经营资产贡献包含在盈利中。',NULL,'品类扩张可能同时增加管理复杂度。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S2'),'B8','重要合作','生态链制造与供应伙伴','合作伙伴提供产品和制造能力，集团提供品牌、渠道及生态连接。',NULL,'伙伴依赖、质量与利润分配。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S2'),'B9','成本结构','产品毛利减共享费用','按分项毛利率与 J-OPEX 的收入分摊费用率估算经营利润，沿用正常化及过渡期现金流。','共同费用分摊：J-OPEX；估值参数：S2','毛利率结构升级与国补退坡均需验证。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_business_base(company_id,code,name,boundary,cost_allocation,asset_boundary,sort) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),'S3','互联网服务','设备用户的广告、游戏及其他互联网服务变现；硬件收入归 S1、S2。','按收入分摊生态共同费用，包含硬件获客所需共同费用的分摊；单独估值不意味着脱离硬件生态。','用户、账户、软件及相关经营资产的贡献包含在盈利估值中，不另加用户或生态溢价；集团现金与投资另算。',3) ON CONFLICT (company_id,code) DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S3'),'B1','客户细分','设备用户与服务付费方','设备用户形成流量基础；广告、游戏等业务的付款方和使用者可能不同。',NULL,'用户数量和单位用户价值分别跟踪。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S3'),'B2','价值主张','基于设备入口提供互联网服务','通过广告、游戏等服务变现；与硬件获客相互依赖。',NULL,'用户体验、监管和竞争约束变现强度。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S3'),'B3','渠道通路','账户、系统与设备入口','依托存量设备和系统服务触达用户，入口来自手机等硬件业务。',NULL,'入口控制与合作安排可能变化。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S3'),'B4','客户关系','随设备持续使用形成服务关系','收入取决于活跃用户及单位用户变现，不等同于硬件当期出货收入。',NULL,'设备用户流失可能滞后传导。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S3'),'B5','收入来源','收入＝活跃用户×单位用户变现','广告、游戏等收入汇总；收入、毛利与共享获客成本分别观察。','业务估值 S3；用户与变现数据见既有事实','国内外用户变现差异，不能只外推集团月活。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S3'),'B6','核心资源','用户基础、账户与系统运营能力','现有用户及软件的经营贡献已反映在盈利估值中，不另加生态溢价。',NULL,'流量规模能否维持以及变现是否透支体验。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S3'),'B7','关键业务','服务运营与流量变现','运营广告、游戏及其他互联网服务，并与设备业务协同获客。',NULL,'变现效率与服务体验的平衡。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S3'),'B8','重要合作','内容、广告与系统生态伙伴','业务依赖广告主、内容和服务伙伴及系统生态；具体合同条款未在此补造。',NULL,'合作方议价、合规及分成变化。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S3'),'B9','成本结构','高毛利服务仍需承担共享成本','互联网毛利减按收入分摊的生态共同费用，防止手机承担全部获客成本而互联网只保留利润。','共同费用分摊：J-OPEX；估值参数：S3','更换分摊方式会改变各业务价值，需要通过情景检验。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_business_base(company_id,code,name,boundary,cost_allocation,asset_boundary,sort) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),'S4','智能电动汽车','汽车及相关服务，不含 AI、大模型、芯片与机器人；延续 J-EV-SPLIT 的估算拆分。','汽车毛利减汽车本身研发、渠道等费用；AI 成本按既有拆分剔出，拆分不确定性仍由 J-EV-SPLIT 跟踪。','汽车工厂及生产设施的经营贡献包含在稳态盈利与期间现金流中，不再按账面固定资产加计；资本开支沿用原假设。',4) ON CONFLICT (company_id,code) DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S4'),'B1','客户细分','汽车消费用户','面向汽车消费者，用户可能来自小米设备生态之外；沿用集团画布与现有汽车事实。',NULL,'不能以手机月活直接推算汽车销量。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S4'),'B2','价值主张','汽车产品与智能体验','以汽车产品、交付质量及使用体验竞争，与手机硬件和互联网服务分别估值。',NULL,'产品竞争、价格战与质量反馈。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S4'),'B3','渠道通路','汽车销售、交付及服务渠道','汽车有专门门店与交付服务体系，同时使用集团品牌和部分渠道能力。',NULL,'扩张速度与渠道效率。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S4'),'B4','客户关系','购车到交付后的持续服务','客户关系跨越订单、交付和车辆使用周期；手机用户关系不能直接替代汽车关系。',NULL,'订单转交付、服务与口碑。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S4'),'B5','收入来源','收入＝交付量×平均售价＋相关收入','沿用汽车稳态经营假设，收入和利润中剔出 AI 等创新业务。','业务估值 S4；稳态年份 2030','交付规模、ASP 和稳态利润率。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S4'),'B6','核心资源','汽车产品、工厂与组织能力','工厂与生产设施为业务创造利润，其价值包含在稳态盈利与期间现金流中。','资产边界登记 A4：已含业务估值','生产、供应链与质量管理仍需验证。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S4'),'B7','关键业务','产品研发、制造与交付服务','沿用现有汽车自建工厂及量产描述，资本开支和营运资本沿用原模型。',NULL,'爬坡中的产能利用率与资金需求。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S4'),'B8','重要合作','电池与汽车供应链伙伴','沿用现有电池及供应链证据，供应集中与交付能力影响经营。',NULL,'供应依赖与零部件成本。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S4'),'B9','成本结构','汽车毛利减汽车本身费用','汽车经营费用与 AI 投入按 J-EV-SPLIT 拆开；稳态价值加期间现金流，不再加汽车工厂账面价值。','估值参数 S4；拆分依据 J-EV-SPLIT','AI 拆分估计、价格战和执行风险。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_business_base(company_id,code,name,boundary,cost_allocation,asset_boundary,sort) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),'S5','AI、芯片与机器人','沿用现有估值分组，暂合并大模型、芯片与机器人；三者商业化路径不同，披露足够后可继续拆分。','与汽车成本分开，集团共用研发的归属仍需核验；沿用 J-AI 整体估值，不新增一笔投入扣减。','直接估值沿用既有整体口径；未来投入及集团现金支持的重叠问题保留在 T4/J-AI，不因本次结构调整视作已解决。',5) ON CONFLICT (company_id,code) DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S5'),'B1','客户细分','客户与付费场景尚待明确','大模型、芯片、机器人目前合并跟踪，不能认定三者具有同一种已验证的付费客户。',NULL,'客户、收入及对内对外使用口径待核验。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S5'),'B2','价值主张','模型、芯片与机器人能力探索','经营价值取决于未来应用与商业化；现有直接估值是研究判断。',NULL,'研发能力不自动等于可持续盈利。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S5'),'B3','渠道通路','独立销售渠道尚待验证','可能与集团产品协同，但尚无足够证据确认稳定的独立销售和交付路径。',NULL,'对内协同收益和对外收入不能混计。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S5'),'B4','客户关系','持续使用与付费机制待验证','尚不能用手机月活或集团用户关系替代 AI 业务留存和付费数据。',NULL,'商业化与留存证据不足。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S5'),'B5','收入来源','尚未建立可靠盈利预测','沿用直接估值方法，不补造收入、利润率或现金流；后续披露足够时再拆分及建模。','业务估值 S5；直接估值沿用既有情景','可比公司口径、资金归属及未来投入均影响价值。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S5'),'B6','核心资源','研发团队、技术与集团应用场景','沿用现有 AI 与芯片证据；技术能力能否形成壁垒仍需验证。',NULL,'投入规模不等于技术壁垒或股东价值。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S5'),'B7','关键业务','大模型、芯片及机器人研发','暂作为同一投入期估值分组，业务边界明示；继续拆分需独立的经营与资金披露。',NULL,'研发交付、商业化与投入节奏。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S5'),'B8','重要合作','研发与产业合作待持续核验','不从可比公司估值推断小米实际客户、合作条款或供应关系。',NULL,'技术生态与外部依赖变化。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ((SELECT id FROM vi_company_base WHERE code='01810.HK'),(SELECT id FROM vi_business_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND code='S5'),'B9','成本结构','研发投入与资金口径须单列','沿用原整体直接估值，暂不新增成本扣减；可比估值自带现金而小米由集团出资的口径风险保留在 T4/J-AI。','费用与资金边界见 J-AI、J-EV-SPLIT','不能将资金口径尚待裁决解释为已经消除重复计价。') ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;

UPDATE vi_sotp_segment_base g SET business_id=b.id FROM vi_business_base b,vi_model_base m WHERE g.model_id=m.id AND m.company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND b.company_id=m.company_id AND b.code=g.code AND g.business_id IS NULL;

INSERT INTO vi_lnk_biz_model_facts(biz_model_id,fact_id,"createdAt","updatedAt")
SELECT DISTINCT canvas.id,f.id,now(),now() FROM (VALUES ('S1','B1','2026 年二季度手机出货'),('S1','B1','2026 年二季度中国大陆：'),('S1','B2','2026 年二季度手机出货'),('S1','B3','小米之家：'),('S1','B4','全球月活（12 月）'),('S1','B7','2025 年研发'),('S1','B8','存储成本：'),('S1','B9','生态营业费用率'),('S1','B9','2026 年上半年分业务：'),('S2','B1','AIoT 连接设备'),('S2','B2','AIoT 连接设备'),('S2','B3','小米之家：'),('S2','B4','AIoT 连接设备'),('S2','B5','2025 年 IoT 收入'),('S2','B5','2026 年二季度 IoT'),('S2','B6','AIoT 连接设备'),('S2','B9','生态营业费用率'),('S2','B9','2026 年上半年分业务：'),('S3','B1','全球月活 2026'),('S3','B1','2025 年广告收入'),('S3','B2','互联网服务：'),('S3','B3','全球月活（12 月）'),('S3','B4','全球月活（12 月）'),('S3','B5','互联网服务：'),('S3','B5','2025 年广告收入'),('S3','B6','全球月活 2026'),('S3','B7','互联网服务：'),('S3','B9','生态营业费用率'),('S3','B9','2026 年上半年分业务：'),('S4','B1','新一代 SU7'),('S4','B2','2025 年交付'),('S4','B3','小米之家：'),('S4','B4','新一代 SU7'),('S4','B5','2025 年交付'),('S4','B5','2026 年二季度汽车及 AI'),('S4','B6','2026 年上半年资本开支'),('S4','B7','2026 年上半年资本开支'),('S4','B9','汽车及 AI 分部经营开支：'),('S5','B2','管理层：未来三年 AI'),('S5','B2','MiMo-V2.5'),('S5','B5','MiMo-V2.5'),('S5','B6','管理层：未来三年 AI'),('S5','B6','MiMo-V2.5'),('S5','B7','管理层：未来三年 AI'),('S5','B7','2025 年研发'),('S5','B9','管理层：未来三年 AI'),('S5','B9','大模型公司按收入')) e(business_code,canvas_code,fact_prefix)
JOIN vi_business_base b ON b.company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND b.code=e.business_code
JOIN vi_biz_model_base canvas ON canvas.business_id=b.id AND canvas.code=e.canvas_code
JOIN vi_fact_base f ON f.company_id=b.company_id AND f.title LIKE e.fact_prefix||'%'
ON CONFLICT DO NOTHING;

INSERT INTO vi_lnk_biz_model_facts(biz_model_id,fact_id,"createdAt","updatedAt")
SELECT DISTINCT b.id,l.fact_id,now(),now() FROM vi_biz_model_base b
JOIN vi_sotp_segment_base s ON s.business_id=b.business_id
JOIN vi_lnk_sotp_segment_facts l ON l.sotp_segment_id=s.id
WHERE b.company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND b.code IN ('B5','B9') ON CONFLICT DO NOTHING;

UPDATE vi_sotp_item_base SET treatment=coalesce(treatment,'单独计价'),valuation_method=coalesce(valuation_method,'账面价值'),boundary=coalesce(boundary,'公司现金储备口径；理财已包含，C8 不再包含理财。经营所需现金 C5、受限资金 C7 与资金汇出成本 C6 另扣。') WHERE model_id IN (SELECT id FROM vi_model_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK')) AND code='C1';

UPDATE vi_sotp_item_base SET treatment=coalesce(treatment,'单独计价'),valuation_method=coalesce(valuation_method,'账面价值'),boundary=coalesce(boundary,'经营分部使用税后经营盈利，未扣融资利息；借款在此统一扣减。') WHERE model_id IN (SELECT id FROM vi_model_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK')) AND code='C2';

UPDATE vi_sotp_item_base SET treatment=coalesce(treatment,'单独计价'),valuation_method=coalesce(valuation_method,'账面价值'),boundary=coalesce(boundary,'沿用租赁负债处理：经营利润已扣使用权资产折旧、未扣租赁利息。') WHERE model_id IN (SELECT id FROM vi_model_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK')) AND code='C3';

UPDATE vi_sotp_item_base SET treatment=coalesce(treatment,'单独计价'),valuation_method=coalesce(valuation_method,'账面价值'),boundary=coalesce(boundary,'计息递延对价，在资产负债调整中扣减，不再在分部价值里另扣本金。') WHERE model_id IN (SELECT id FROM vi_model_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK')) AND code='C4';

UPDATE vi_sotp_item_base SET treatment=coalesce(treatment,'单独计价'),valuation_method=coalesce(valuation_method,'研究估计'),boundary=coalesce(boundary,'从 C1 中剔除经营所需资金；本次保持原分部盈利和期间现金流假设。') WHERE model_id IN (SELECT id FROM vi_model_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK')) AND code='C5';

UPDATE vi_sotp_item_base SET treatment=coalesce(treatment,'单独计价'),valuation_method=coalesce(valuation_method,'研究估计'),boundary=coalesce(boundary,'资金汇出成本单独扣减，未并入 C1、C5 或业务利润率。') WHERE model_id IN (SELECT id FROM vi_model_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK')) AND code='C6';

UPDATE vi_sotp_item_base SET treatment=coalesce(treatment,'单独计价'),valuation_method=coalesce(valuation_method,'研究估计'),boundary=coalesce(boundary,'从现金储备中剔除不可用资金，按原情景取值；不与 C5 重复。') WHERE model_id IN (SELECT id FROM vi_model_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK')) AND code='C7';

UPDATE vi_sotp_item_base SET treatment=coalesce(treatment,'单独计价'),valuation_method=coalesce(valuation_method,'账面价值'),boundary=coalesce(boundary,'不含 C1 已计的理财；对外股权收益不在业务盈利中资本化；外部基金份额由 C9 扣减。') WHERE model_id IN (SELECT id FROM vi_model_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK')) AND code='C8';

UPDATE vi_sotp_item_base SET treatment=coalesce(treatment,'单独计价'),valuation_method=coalesce(valuation_method,'账面价值'),boundary=coalesce(boundary,'C8 包含合并产业基金资产，此处扣除外部出资人权益；不与 C10 重复。') WHERE model_id IN (SELECT id FROM vi_model_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK')) AND code='C9';

UPDATE vi_sotp_item_base SET treatment=coalesce(treatment,'单独计价'),valuation_method=coalesce(valuation_method,'账面价值'),boundary=coalesce(boundary,'沿用集团少数股东权益扣减；各分部维持原归母比例口径。') WHERE model_id IN (SELECT id FROM vi_model_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK')) AND code='C10';

UPDATE vi_sotp_item_base SET treatment=coalesce(treatment,'单独计价'),valuation_method=coalesce(valuation_method,'现值'),boundary=coalesce(boundary,'沿用原补助资本化，已从各业务经营利润率中排除；这是其他估值调整，不是固定资产。') WHERE model_id IN (SELECT id FROM vi_model_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK')) AND code='C11';

INSERT INTO vi_sotp_item_base(model_id,business_id,code,name,kind,treatment,boundary,amount,haircut,as_of,basis)
SELECT m.id,b.id,'A1','手机经营固定资产','固定资产','已含业务估值','归属边界登记，未填独立资产估值；经营贡献已包含在该业务估值中，不另加账面价值或重置成本。',NULL,0,m.sotp_as_of,
'本项用于防止把经营资产与业务盈利重复计价；金额未知，不代表固定资产账面额为零。'
FROM vi_model_base m JOIN vi_business_base b ON b.company_id=m.company_id AND b.code='S1'
WHERE m.company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND NOT EXISTS (SELECT 1 FROM vi_sotp_item_base i WHERE i.model_id=m.id AND i.code='A1');

INSERT INTO vi_sotp_item_base(model_id,business_id,code,name,kind,treatment,boundary,amount,haircut,as_of,basis)
SELECT m.id,b.id,'A2','AIoT 经营固定资产','固定资产','已含业务估值','归属边界登记，未填独立资产估值；经营贡献已包含在该业务估值中，不另加账面价值或重置成本。',NULL,0,m.sotp_as_of,
'本项用于防止把经营资产与业务盈利重复计价；金额未知，不代表固定资产账面额为零。'
FROM vi_model_base m JOIN vi_business_base b ON b.company_id=m.company_id AND b.code='S2'
WHERE m.company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND NOT EXISTS (SELECT 1 FROM vi_sotp_item_base i WHERE i.model_id=m.id AND i.code='A2');

INSERT INTO vi_sotp_item_base(model_id,business_id,code,name,kind,treatment,boundary,amount,haircut,as_of,basis)
SELECT m.id,b.id,'A3','互联网经营固定资产','固定资产','已含业务估值','归属边界登记，未填独立资产估值；经营贡献已包含在该业务估值中，不另加账面价值或重置成本。',NULL,0,m.sotp_as_of,
'本项用于防止把经营资产与业务盈利重复计价；金额未知，不代表固定资产账面额为零。'
FROM vi_model_base m JOIN vi_business_base b ON b.company_id=m.company_id AND b.code='S3'
WHERE m.company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND NOT EXISTS (SELECT 1 FROM vi_sotp_item_base i WHERE i.model_id=m.id AND i.code='A3');

INSERT INTO vi_sotp_item_base(model_id,business_id,code,name,kind,treatment,boundary,amount,haircut,as_of,basis)
SELECT m.id,b.id,'A4','汽车工厂与生产设施','固定资产','已含业务估值','归属边界登记，未填独立资产估值；经营贡献已包含在该业务估值中，不另加账面价值或重置成本。',NULL,0,m.sotp_as_of,
'本项用于防止把经营资产与业务盈利重复计价；金额未知，不代表固定资产账面额为零。'
FROM vi_model_base m JOIN vi_business_base b ON b.company_id=m.company_id AND b.code='S4'
WHERE m.company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND NOT EXISTS (SELECT 1 FROM vi_sotp_item_base i WHERE i.model_id=m.id AND i.code='A4');

INSERT INTO vi_sotp_item_base(model_id,business_id,code,name,kind,treatment,boundary,amount,haircut,as_of,basis)
SELECT m.id,b.id,'A5','AI 等创新业务经营资产','固定资产','已含业务估值','归属边界登记，未填独立资产估值；经营贡献已包含在该业务估值中，不另加账面价值或重置成本。未来投入与集团现金的口径风险仍由 T4/J-AI 跟踪。',NULL,0,m.sotp_as_of,
'本项用于防止把经营资产与业务盈利重复计价；金额未知，不代表固定资产账面额为零。'
FROM vi_model_base m JOIN vi_business_base b ON b.company_id=m.company_id AND b.code='S5'
WHERE m.company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND NOT EXISTS (SELECT 1 FROM vi_sotp_item_base i WHERE i.model_id=m.id AND i.code='A5');

INSERT INTO vi_lnk_sotp_item_facts(sotp_item_id,fact_id,"createdAt","updatedAt")
SELECT DISTINCT i.id,l.fact_id,now(),now() FROM vi_sotp_item_base i
JOIN vi_biz_model_base b ON b.business_id=i.business_id AND b.code IN ('B6','B7')
JOIN vi_lnk_biz_model_facts l ON l.biz_model_id=b.id
WHERE i.model_id IN (SELECT id FROM vi_model_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK')) AND i.code IN ('A1','A2','A3','A4','A5') ON CONFLICT DO NOTHING;

INSERT INTO vi_change_log_base(company_id,change_date,title,target,old_value,new_value,reason,basis,verification)
SELECT (SELECT id FROM vi_company_base WHERE code='01810.HK'),'2026-10-26','打通多业务商业模式与业务／资产估值','业务分部、商业模式、经营分部估值、资产估值与调整',
'集团九项画布与分部估值没有业务关联；固定资产只能通过其他调整表达。',
'五块业务身份连接分业务画布和三情景估值；现金、投资与负债独立汇总；经营固定资产登记为已含业务估值，不重复加计。',
'按用户要求区分业务估值和资产估值，并明确共享费用、经营资产与未来投入的边界。',
'沿用已有事实与估值输入；不新增资产公允价值，也不裁决 T4／J-AI 的资金口径争议。',
'隔离迁移与空库重建通过；原三情景估值不变；独立固定资产、情景覆盖、缺失金额与重复计价边界已验证。'
WHERE NOT EXISTS(SELECT 1 FROM vi_change_log_base WHERE company_id=(SELECT id FROM vi_company_base WHERE code='01810.HK') AND title='打通多业务商业模式与业务／资产估值');


COMMIT;