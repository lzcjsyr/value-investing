"""一次性：估值部分重构（2026-11-11）——读在线库的旧估值数据，生成 sql/migrations/2026-11-11c_restructure.sql。

重构后估值只有 Greenwald 三层：资产负债重估（第一层＋资产负债桥）、盈利能力（第二层）、增长（第三层）、情景；
估值设置（截至日、股本、主估值层）放在公司表。旧的估值模型、逐年假设、财务预测、经营分部估值、资产估值与调整、单参数试验、
统一估值引擎（收入与成本项目、估值假设）、估值输入全部删除。

搬运规则：
  腾讯音乐：资产负债重估、估值输入（拆成盈利能力、增长）原样搬过来。
  其余四家（统一估值引擎）：
    盈利能力＝第一个完整年度（2027）的收入、正常化经营利润率（没填取当年利润率）、税率、归母比例；
    增长＝原永续增长率、终值新增投资回报率（原来留空＝门槛，搬成 6%），优势年限留空（永续，与原终值一致）；
    资产负债桥＝原资产估值与调整里单独计价的项目（情景专属的照搬），已含业务估值、不计价的项目只是边界说明，不搬；
    经营资本＝原期初投入资本，一行研究项目“经营投入资本（迁移，待按报表逐项归类）”；
    直接估值的业务（小米 AI）＝资产负债桥里一行“参照估值”；
    依据：原估值假设关联的假设依据照挂，另加一条 J-MIG 说明迁移。
  主估值层：腾讯音乐＝盈利能力价值（已研究）；其余四家＝含增长价值（原结论用全价值），待按 Greenwald 重新研究。

  python3 framework/tools/restructure_20261111.py      # 只写 SQL；执行见 README
"""
import json
import pathlib
import subprocess

ROOT = pathlib.Path(__file__).resolve().parents[2]
OUT = ROOT / 'framework/sql/migrations/2026-11-11c_restructure.sql'
H = 0.06


def q(sql):
    p = subprocess.run([str(ROOT / 'psql.sh'), '-At', '-c', f"SELECT coalesce(json_agg(t), '[]') FROM ({sql}) t"],
                       capture_output=True, text=True, check=True)
    return json.loads(p.stdout)


def lit(v):
    if v is None:
        return 'NULL'
    if isinstance(v, bool):
        return 'true' if v else 'false'
    if isinstance(v, (int, float)):
        return repr(round(v, 8)) if isinstance(v, float) else str(v)
    return "'" + str(v).replace("'", "''") + "'"


EPV_PARAMS = ('收入', '经营利润率', '经营利润', '税率', '归母比例', '正常化经营利润率', '驱动1', '驱动2', '驱动3', '金额', '比例', '单位成本')
GROWTH_PARAMS = ('永续增长率', '终值新增投资回报率')


def schema_blocks():
    """从新生成的 01_schema.sql 里取新表（盈利能力、增长及其关联表）的建表语句。"""
    s = (ROOT / 'framework/sql/01_schema.sql').read_text().split('\n\n')
    want = [b for b in s if any(k in b for k in ('vi_epv_base', 'vi_growth_base', 'vi_lnk_epv_', 'vi_lnk_growth_'))
            and not b.startswith('ALTER TABLE vi_bs_item') and 'vi_lnk_bs_item' not in b]
    return want


def main():
    out = ["-- 自动生成：framework/tools/restructure_20261111.py。估值部分按 Greenwald 三层重构：建新结构 → 搬数据 → 删旧表。",
           "-- 执行顺序：本文件 → 02_calc.sql → 03_ui.sql（本文件先删掉全部 vi_ 视图）。", 'BEGIN;',
           """DO $$ DECLARE r record; BEGIN
  FOR r IN SELECT matviewname AS n FROM pg_matviews WHERE schemaname = 'public' AND matviewname LIKE 'vi\\_%' LOOP
    EXECUTE 'DROP MATERIALIZED VIEW IF EXISTS ' || r.n || ' CASCADE'; END LOOP;
  FOR r IN SELECT viewname AS n FROM pg_views WHERE schemaname = 'public' AND viewname LIKE 'vi\\_%' LOOP
    EXECUTE 'DROP VIEW IF EXISTS ' || r.n || ' CASCADE'; END LOOP;
END $$;""", "DROP FUNCTION IF EXISTS vi_gw_guard() CASCADE;  -- 旧的归属检查（按估值模型），新规则在文末重建"]

    # ---------------- 1 公司：估值设置
    out.append("""ALTER TABLE vi_company_base ADD COLUMN IF NOT EXISTS shares double precision, ADD COLUMN IF NOT EXISTS as_of date,
  ADD COLUMN IF NOT EXISTS value_layer text, ADD COLUMN IF NOT EXISTS layer_reason text;""")
    models = q("SELECT m.id, m.company_id, c.code, c.name, m.shares, coalesce(m.as_of, m.sotp_as_of, make_date(m.base_year, 12, 31)) AS as_of, "
               "m.value_layer, m.layer_reason, m.rf_metric_id FROM vi_model_base m JOIN vi_company_base c ON c.id = m.company_id WHERE m.status = '当前'")
    for m in models:
        layer, reason = m['value_layer'], m['layer_reason']
        if not layer:
            layer = '含增长价值'
            reason = '迁移自统一估值引擎：原结论用全价值（逐年现金流折现）。待按 Greenwald 重新研究资产价值与盈利能力后再定主估值层。'
        out.append(f"UPDATE vi_company_base SET shares = {lit(m['shares'])}, as_of = {lit(m['as_of'])}, value_layer = {lit(layer)}, "
                   f"layer_reason = {lit(reason)} WHERE id = {m['company_id']};")
        if m['rf_metric_id']:          # 原估值模型的无风险利率参考指标：改成订阅的宏观数据（指标不丢）
            out.append(f"""INSERT INTO vi_lnk_company_macro_metrics (company_id, metric_id, "createdAt", "updatedAt")
SELECT {m['company_id']}, {m['rf_metric_id']}, now(), now() WHERE EXISTS (SELECT 1 FROM vi_metric_base WHERE id = {m['rf_metric_id']} AND company_id IS NULL)
ON CONFLICT DO NOTHING;""")
    model_of = {m['company_id']: m['id'] for m in models}

    # ---------------- 2 情景：挂到公司，去掉旧方法的列
    out.append("""ALTER TABLE vi_scenario_base ADD COLUMN IF NOT EXISTS company_id bigint;
UPDATE vi_scenario_base s SET company_id = m.company_id FROM vi_model_base m WHERE m.id = s.model_id AND m.status = '当前';
DELETE FROM vi_scenario_base WHERE company_id IS NULL;
ALTER TABLE vi_scenario_base DROP CONSTRAINT IF EXISTS vi_scenario_uniq;
ALTER TABLE vi_scenario_base DROP COLUMN model_id CASCADE, DROP COLUMN volume_factor, DROP COLUMN price_factor, DROP COLUMN cost_factor,
  DROP COLUMN discount_rate, DROP COLUMN terminal_growth, DROP COLUMN nature, DROP COLUMN ronic, DROP COLUMN sotp_multiple;
ALTER TABLE vi_scenario_base ADD CONSTRAINT vi_scenario_uniq UNIQUE (company_id, name);
ALTER TABLE vi_scenario_base ADD FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE SET NULL;
CREATE INDEX ON vi_scenario_base (company_id);""")

    # ---------------- 3 业务：去掉统一引擎的驱动列，加重建成本
    out.append("""ALTER TABLE vi_business_base ADD COLUMN IF NOT EXISTS repro_cost double precision;
ALTER TABLE vi_business_base DROP COLUMN IF EXISTS kind, DROP COLUMN IF EXISTS driver1_label, DROP COLUMN IF EXISTS driver1_unit,
  DROP COLUMN IF EXISTS driver2_label, DROP COLUMN IF EXISTS driver2_unit, DROP COLUMN IF EXISTS driver3_label, DROP COLUMN IF EXISTS driver3_unit,
  DROP COLUMN IF EXISTS driver_scale, DROP COLUMN IF EXISTS cost_allocation;""")

    # ---------------- 4 资产负债重估：挂到公司，加适用情景
    out.append("""ALTER TABLE vi_bs_item_base ADD COLUMN IF NOT EXISTS company_id bigint, ADD COLUMN IF NOT EXISTS scenario_id bigint;
UPDATE vi_bs_item_base b SET company_id = m.company_id FROM vi_model_base m WHERE m.id = b.model_id;
ALTER TABLE vi_bs_item_base DROP COLUMN model_id CASCADE;
ALTER TABLE vi_bs_item_base ADD FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE SET NULL;
ALTER TABLE vi_bs_item_base ADD FOREIGN KEY (scenario_id) REFERENCES vi_scenario_base(id) ON DELETE SET NULL;
CREATE INDEX ON vi_bs_item_base (company_id); CREATE INDEX ON vi_bs_item_base (scenario_id);""")

    # ---------------- 5 盈利能力、增长：新表
    out += schema_blocks()

    # 腾讯音乐：估值输入 → 盈利能力＋增长
    out.append("""INSERT INTO vi_epv_base (company_id, business_id, scenario_id, revenue, margin, tax_rate, da, maint_capex, attrib, life, note)
SELECT m.company_id, v.business_id, v.scenario_id, v.revenue, v.margin, v.tax_rate, v.da, v.maint_capex, v.attrib, v.life, v.note
FROM vi_val_input_base v JOIN vi_model_base m ON m.id = v.model_id;
INSERT INTO vi_growth_base (company_id, business_id, scenario_id, growth, ronic, adv_years, note)
SELECT m.company_id, v.business_id, v.scenario_id, v.growth, v.ronic, v.adv_years, v.note
FROM vi_val_input_base v JOIN vi_model_base m ON m.id = v.model_id WHERE v.growth IS NOT NULL OR v.ronic IS NOT NULL OR v.adv_years IS NOT NULL;
INSERT INTO vi_lnk_epv_judgments (epv_id, judgment_id, "createdAt", "updatedAt")
SELECT e.id, l.judgment_id, now(), now() FROM vi_lnk_val_input_judgments l JOIN vi_val_input_base v ON v.id = l.val_input_id
JOIN vi_epv_base e ON e.business_id = v.business_id AND e.scenario_id = v.scenario_id
JOIN vi_judgment_base j ON j.id = l.judgment_id WHERE j.code <> 'J-GROW';
INSERT INTO vi_lnk_growth_judgments (growth_id, judgment_id, "createdAt", "updatedAt")
SELECT g.id, l.judgment_id, now(), now() FROM vi_lnk_val_input_judgments l JOIN vi_val_input_base v ON v.id = l.val_input_id
JOIN vi_growth_base g ON g.business_id = v.business_id AND g.scenario_id = v.scenario_id
JOIN vi_judgment_base j ON j.id = l.judgment_id WHERE j.code = 'J-GROW';""")

    # 其余四家：统一估值引擎 → 三层
    first = q("""WITH ff AS (SELECT scenario_id, business_id, min(year) FILTER (WHERE w >= 1) AS y FROM vi_ve_year GROUP BY 1, 2)
      SELECT y.company_id, y.scenario_id, y.scenario_name, y.business_id, b.business_code, b.business_name, y.year, y.revenue,
             coalesce(y.norm_margin, y.margin) AS margin, y.norm_margin, y.tax_rate, y.attrib, b.ic0, b.g, b.ronic_used, b.ronic_default, b.av_basis, b.value
      FROM vi_ve_year y JOIN ff ON ff.scenario_id = y.scenario_id AND ff.business_id = y.business_id AND ff.y = y.year
      JOIN vi_ve_business b ON b.scenario_id = y.scenario_id AND b.business_id = y.business_id
      ORDER BY y.company_id, b.business_sort, y.scenario_sort""")
    links = q("SELECT a.business_id, a.parameter, j.code FROM vi_assumption_base a JOIN vi_judgment_base j ON j.id = a.judgment_id "
              "GROUP BY 1, 2, 3")
    jl = {}
    for r in links:
        kind = 'epv' if r['parameter'] in EPV_PARAMS else 'growth' if r['parameter'] in GROWTH_PARAMS else None
        if kind and r['code'] not in ('J-IC', 'J-VE'):
            jl.setdefault((r['business_id'], kind), set()).add(r['code'])
    cos = sorted({r['company_id'] for r in first})
    names = {m['company_id']: m['name'] for m in models}
    for cid in cos:
        rows = [r for r in first if r['company_id'] == cid]
        out.append(f"""INSERT INTO vi_judgment_base (company_id, code, title, status, judgment, transmission, parameter, change_threshold)
VALUES ({cid}, 'J-MIG', '三层估值的输入：迁移自统一估值引擎（待按 Greenwald 重新研究）', '已形成建议',
{lit('2026-11-11 估值重构时从统一估值引擎搬来：盈利能力＝第一个完整年度（2027）的收入、正常化经营利润率（没填时取当年利润率）、税率、归母比例；'
     '增长＝原永续增长率与终值新增投资回报率（原来留空＝门槛 6%），优势年限留空＝永续，与原终值口径一致；'
     '经营资本＝原期初投入资本（归母权益减资产负债桥账面项），还没有按资产负债表逐项归类；资产负债桥＝原资产估值与调整里单独计价的项目。'
     '原逐年预测（明确期现金流）不再使用，所以含增长价值与原全价值不同。')},
'盈利能力价值＝E÷门槛；含增长价值按增长率、新增投资回报率、优势年限；股权价值＝业务价值＋资产负债桥。',
'盈利能力、增长、资产负债重估', '按 Greenwald 重新研究这家公司时逐项替换（正常化利润率、维持性资本开支、资产负债表逐项归类、优势年限）。')
ON CONFLICT (company_id, code) DO UPDATE SET judgment = EXCLUDED.judgment;""")
        jmig = f"(SELECT id FROM vi_judgment_base WHERE company_id = {cid} AND code = 'J-MIG')"

        def link_codes(table, fk, row_sql, codes):
            return (f"INSERT INTO vi_lnk_{table}_judgments ({fk}, judgment_id, \"createdAt\", \"updatedAt\") "
                    f"SELECT x.id, j.id, now(), now() FROM ({row_sql}) x JOIN vi_judgment_base j ON j.company_id = {cid} "
                    f"AND j.code IN ({', '.join(lit(c) for c in sorted(codes | {'J-MIG'}))}) ON CONFLICT DO NOTHING;")

        for r in rows:
            if r['av_basis'] == '直接估值':
                continue
            note = '迁移：' + ('正常化经营利润率' if r['norm_margin'] is not None else f"{r['year']} 年经营利润率") + f"，{r['year']} 年收入（统一估值引擎）"
            out.append(f"INSERT INTO vi_epv_base (company_id, business_id, scenario_id, revenue, margin, tax_rate, attrib, note) VALUES "
                       f"({cid}, {r['business_id']}, {r['scenario_id']}, {lit(round(r['revenue'], 2))}, {lit(round(r['margin'], 6))}, "
                       f"{lit(r['tax_rate'])}, {lit(r['attrib'])}, {lit(note)});")
            out.append(link_codes('epv', 'epv_id', f"SELECT id FROM vi_epv_base WHERE business_id = {r['business_id']} AND scenario_id = {r['scenario_id']}",
                                  jl.get((r['business_id'], 'epv'), set())))
            ronic = H if r['ronic_default'] else r['ronic_used']
            gnote = '迁移：原永续增长率与终值新增投资回报率' + ('（原来留空＝门槛，增长不创造价值）' if r['ronic_default'] else '')
            out.append(f"INSERT INTO vi_growth_base (company_id, business_id, scenario_id, growth, ronic, note) VALUES "
                       f"({cid}, {r['business_id']}, {r['scenario_id']}, {lit(r['g'])}, {lit(ronic)}, {lit(gnote)});")
            out.append(link_codes('growth', 'growth_id', f"SELECT id FROM vi_growth_base WHERE business_id = {r['business_id']} AND scenario_id = {r['scenario_id']}",
                                  jl.get((r['business_id'], 'growth'), set())))
        # 经营资本：每块业务一行（原期初投入资本）
        seen = set()
        for r in rows:
            if r['av_basis'] == '直接估值' or r['business_id'] in seen:
                continue
            seen.add(r['business_id'])
            out.append(f"""WITH ins AS (INSERT INTO vi_bs_item_base (company_id, business_id, category, name, adjustment, basis, sort) VALUES
({cid}, {r['business_id']}, '经营资产', '经营投入资本（迁移，待按报表逐项归类）', {lit(round(r['ic0'], 2))},
{lit('原统一估值引擎的期初投入资本＝截至日归母权益 − 资产负债桥里按账面计的项目（原检查 V09 对账）。按 Greenwald 研究时改成逐个报表科目。')}, {len(seen)}) RETURNING id)
INSERT INTO vi_lnk_bs_item_judgments (bs_item_id, judgment_id, "createdAt", "updatedAt") SELECT ins.id, {jmig}, now(), now() FROM ins;""")
        # 直接估值的业务 → 参照估值
        for r in rows:
            if r['av_basis'] == '直接估值' and r['scenario_name'] == '基准':
                out.append(f"""WITH ins AS (INSERT INTO vi_bs_item_base (company_id, category, name, adjustment, basis, sort) VALUES
({cid}, '参照估值', {lit(r['business_name'] + '（直接估值）')}, {lit(round(r['value'], 2))},
{lit('原统一估值引擎“直接估值”：按可比公司或主观判断给出的整体价值，不自己建模（Greenwald 第四个模块：参照）。')}, 50) RETURNING id)
INSERT INTO vi_lnk_bs_item_judgments (bs_item_id, judgment_id, "createdAt", "updatedAt")
SELECT ins.id, j.id, now(), now() FROM ins JOIN vi_judgment_base j ON j.company_id = {cid}
 AND (j.code = 'J-MIG' OR j.id IN (SELECT judgment_id FROM vi_assumption_base WHERE business_id = {r['business_id']} AND judgment_id IS NOT NULL));""")
        # 资产负债桥：原资产估值与调整里单独计价的项目
        items = q(f"""SELECT i.code, i.name, i.kind, i.valuation_method, i.haircut, i.basis, ic.amount_used, ic.signed_value, i.scenario_id,
                             (SELECT name FROM vi_scenario_base WHERE id = i.scenario_id) AS scen
                      FROM vi_sotp_item_base i JOIN vi_sotp_item_calc ic ON ic.id = i.id
                      WHERE i.model_id = {model_of[cid]} AND i.treatment = '单独计价' ORDER BY i.code, i.scenario_id NULLS FIRST""")
        for n, it in enumerate(items, 10):
            kind, amt, sv = it['kind'], it['amount_used'], it['signed_value']
            if kind in ('现金及等价物',):
                cat, adj = '现金与投资', amt
            elif kind == '对外投资':
                cat, adj = '现金与投资', sv
            elif kind == '带息负债':
                cat, adj = '有息负债', amt
            elif kind == '经营所需现金':
                cat, adj = '现金与投资', -amt
            elif kind in ('少数股东权益', '资金汇出成本'):
                cat, adj = '其他索取权', amt
            elif sv is not None and sv >= 0:
                cat, adj = '参照估值', sv
            else:
                cat, adj = '其他索取权', -(sv or 0)
            extra = f"原 {it['code']}" + (f"，账面 {amt:,.1f} 亿元打折 {it['haircut'] * 100:.0f}%" if it['haircut'] else '') + \
                    (f"，{it['scen']}情景" if it['scen'] else '') + '。'
            basis = extra + (it['basis'] or '')
            sc = it['scenario_id'] if it['scenario_id'] else 'NULL'
            out.append(f"""WITH ins AS (INSERT INTO vi_bs_item_base (company_id, scenario_id, category, name, adjustment, basis, sort) VALUES
({cid}, {sc}, '{cat}', {lit(it['name'])}, {lit(round(adj, 4))}, {lit(basis)}, {n}) RETURNING id)
INSERT INTO vi_lnk_bs_item_judgments (bs_item_id, judgment_id, "createdAt", "updatedAt") SELECT ins.id, {jmig}, now(), now() FROM ins;""")
        print(names[cid], len(rows), '行输入', len(items), '项桥')

    # ---------------- 6 假设依据：去掉“影响年份/情景”
    out.append("ALTER TABLE vi_judgment_base DROP COLUMN IF EXISTS affected_years;")

    # ---------------- 7 删旧表与旧函数
    out.append("""DROP TABLE IF EXISTS vi_lnk_val_input_judgments, vi_val_input_base, vi_assumption_base, vi_line_base,
  vi_trial_base, vi_fin_forecast_base, vi_forecast_base, vi_sotp_segment_base, vi_sotp_item_base, vi_model_base CASCADE;
DO $$ DECLARE r record; BEGIN
  FOR r IN SELECT tablename AS n FROM pg_tables WHERE schemaname = 'public'
            AND tablename ~ '^vi_lnk_(forecast|trial|sotp_item|sotp_segment|assumption|line|val_input|model)_' LOOP
    EXECUTE 'DROP TABLE IF EXISTS ' || r.n || ' CASCADE'; END LOOP;
END $$;
DROP FUNCTION IF EXISTS vi_pv(double precision[], double precision[], double precision, double precision, double precision, double precision) CASCADE;
DROP FUNCTION IF EXISTS vi_irr(double precision[], double precision[], double precision, double precision, double precision, double precision) CASCADE;
DO $$ DECLARE r record; BEGIN
  FOR r IN SELECT p.oid::regprocedure AS f FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
            WHERE n.nspname = 'public' AND p.proname IN ('vi_pv', 'vi_irr', 'vi_ve_pv', 'vi_ve_irr', 'vi_gw_guard') LOOP
    EXECUTE 'DROP FUNCTION IF EXISTS ' || r.f || ' CASCADE'; END LOOP;
END $$;""")
    # ---------------- 8 新的业务规则（归属检查）
    rules = (ROOT / 'framework/sql/business_rules.sql').read_text()
    out.append(rules[:rules.index('-- 统一设置只有一行')].strip())
    out.append('COMMIT;')
    OUT.write_text('\n\n'.join(out) + '\n')
    print('→', OUT.relative_to(ROOT))


if __name__ == '__main__':
    main()
