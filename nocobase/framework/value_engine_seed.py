"""统一估值引擎的种子（2026-11-08）：各公司 companies/<公司>/value_engine.py 的 build(db) 给出业务、假设依据、
资产负债桥与估值假设，这里写成 companies/<公司>/value_engine.sql 并在线执行。可重复执行：先删本模型的估值假设、
N 开头的资产负债桥项目，业务与假设依据按编号更新。

  python3 framework/value_engine_seed.py [公司代码 ...] [--dry]

空库重建：在各公司 seed.sql 之后执行 value_engine.sql（见 README「从零重建」）。
"""
import importlib.util
import json
import pathlib
import subprocess
import sys

HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parent
COMPANIES = {'600900.SH': '600900_长江电力', '002078.SZ': '002078_太阳纸业', '601668.SH': '601668_中国建筑',
             '01698.HK': '01698_腾讯音乐', '01810.HK': '01810_小米集团'}
SIGN = {'现金及等价物': 1, '对外投资': 1, '固定资产': 1, '其他非经营资产': 1,
        '带息负债': -1, '经营所需现金': -1, '资金汇出成本': -1, '少数股东权益': -1}


# ---------------------------------------------------------------- 数据库
def q(sql):
    p = subprocess.run([str(ROOT / 'psql.sh'), '-At', '-c', f'SELECT coalesce(json_agg(t), \'[]\') FROM ({sql}) t'],
                       capture_output=True, text=True, check=True)
    return json.loads(p.stdout)


class DB:
    def __init__(self, code):
        self.code = code
        co = q(f"SELECT id, name, volume_label, volume_unit, price_label, price_unit FROM vi_company_base WHERE code = '{code}'")[0]
        self.co = co
        self.model = q(f"SELECT * FROM vi_model_base WHERE company_id = {co['id']} AND status = '当前'")[0]
        self.scenarios = q(f"SELECT * FROM vi_scenario_base WHERE model_id = {self.model['id']} ORDER BY sort")
        self.years = list(range(self.model['base_year'] + 1, self.model['terminal_year'] + 1))

    def forecast(self):
        return {r['year']: r for r in q(f"SELECT * FROM vi_forecast_base WHERE model_id = {self.model['id']}")}

    def bs(self, date):
        """资产负债表某日的科目 → 金额（亿元）"""
        return {r['item']: r['amount'] for r in q(
            f"SELECT item, amount FROM vi_fin_stmt_base WHERE company_id = {self.co['id']} AND stmt = '资产负债表' "
            f"AND period_end = '{date}' AND amount IS NOT NULL")}

    def history(self):
        return q(f"SELECT * FROM vi_fin_history WHERE company_id = {self.co['id']} ORDER BY year")

    def old_bridge_book(self):
        """已有（非 N 开头）资产负债桥项目的账面合计，口径同 vi_ve_check 的 V09：基准情景，单独计价，账面价值或经营所需现金。"""
        m = self.model['id']
        r = q(f"""SELECT sum(CASE WHEN i.kind = '其他调整' THEN ic.amount_used ELSE sign(ic.signed_value) * abs(ic.amount_used) END) AS v FROM vi_sotp_item_base i JOIN vi_sotp_item_calc ic ON ic.id = i.id
          WHERE i.model_id = {m} AND i.code NOT LIKE 'N%' AND i.treatment = '单独计价' AND ic.signed_value <> 0
            AND (i.scenario_id IS NULL OR i.scenario_id IN (SELECT id FROM vi_scenario_base WHERE model_id = {m} AND is_base))
            AND NOT EXISTS (SELECT 1 FROM vi_sotp_item_base i2 WHERE i.scenario_id IS NULL AND i2.model_id = i.model_id AND i2.code = i.code
                             AND i2.scenario_id IN (SELECT id FROM vi_scenario_base WHERE model_id = {m} AND is_base))
            AND ((coalesce(i.valuation_method, '账面价值') = '账面价值' AND i.kind <> '资金汇出成本') OR i.kind = '经营所需现金')""")
        return r[0]['v'] or 0.0


# ---------------------------------------------------------------- 假设行的组织
class Rows:
    """收集估值假设行：series() 把逐年值按情景合并（各情景相同时只写一行“所有情景”），再把连续相同的年份并成区间。
    line＝收入与成本项目的编号（留空＝业务层参数）。"""

    def __init__(self, years, scenarios):
        self.years, self.scen, self.out = years, [s['name'] for s in scenarios], []

    def static(self, biz, param, value, j, note='', scen=None, line=None):
        if value is not None:
            self.out.append((biz, line, scen, param, None, None, value, j, note))

    def series(self, biz, param, j, by_scen, note='', line=None):
        """by_scen: {情景名: {年: 值}}；或单个 {年: 值}＝所有情景相同。"""
        if not isinstance(next(iter(by_scen.values())), dict):
            by_scen = {s: by_scen for s in self.scen}
        same = all(_eq(by_scen[s], by_scen[self.scen[0]]) for s in self.scen)
        for s in ([None] if same else self.scen):
            vals = by_scen[self.scen[0] if s is None else s]
            for a, b, v in _ranges(vals):
                self.out.append((biz, line, s, param, a, b, v, j, note))


def line(business, code, name, kind, basis, base=None, sort=None, note=None, scale=None, drivers=()):
    """收入与成本项目；drivers＝[(名称, 单位), …]（驱动 1—3）。"""
    d = dict(business=business, code=code, name=name, kind=kind, basis=basis, base_line=base, sort=sort, note=note, driver_scale=scale)
    for i, (lab, unit) in enumerate(drivers, 1):
        d[f'driver{i}_label'], d[f'driver{i}_unit'] = lab, unit
    return d


def _eq(a, b):
    return a.keys() == b.keys() and all(abs((a[k] or 0) - (b[k] or 0)) < 1e-9 for k in a)


def _ranges(vals):
    ys = sorted(vals)
    start = ys[0]
    for i, y in enumerate(ys):
        nxt = ys[i + 1] if i + 1 < len(ys) else None
        if nxt is None or nxt != y + 1 or abs(vals[nxt] - vals[y]) > 1e-9:
            yield start, y, round(vals[y], 6)
            start = nxt


# ---------------------------------------------------------------- 逐年假设（旧股息贴现模型）→ 统一引擎
def translate_forecast(db, rows, cfg):
    """旧逐年假设（基准路径＋情景系数）→ 一块业务 B1 的收入线与成本线。
    R1 收入（驱动1×驱动2，情景系数作用后）；C1 付现成本（按 cfg['cost_basis']：金额｜收入比例｜单位成本，含情景成本系数）；
    C2 折旧摊销；C3 其他净损益（include_other，负数＝收益）；股权口径另有 C4 利息，归母比例＝1−少数股东占比，净投资＝留存利润。
    企业口径的净投资＝维持资本＋扩张资本＋营运资本增加−折旧（parent_capex＝旧现金桥接是归母口径，÷(1−少数股东占比) 还原）。"""
    f, co, jm = db.forecast(), db.co, cfg['jmap']
    equity = cfg.get('basis') == '股权'
    cost_basis = cfg.get('cost_basis', '金额')
    lines = [line('B1', 'R1', cfg['rev_name'], '收入', '驱动', sort=1, scale=1,
                  drivers=[(co['volume_label'], co['volume_unit']), (co['price_label'], co['price_unit'])]),
             line('B1', 'C1', cfg.get('cost_name', '付现成本'), '成本', cost_basis, base='R1' if cost_basis != '金额' else None, sort=11, scale=1,
                  note={'金额': '营业成本中非折旧部分＋期间费用＋税金及附加（亿元）', '收入比例': '付现成本÷收入',
                        '单位成本': '付现成本÷销量（每单位成本）'}[cost_basis]),
             line('B1', 'C2', '折旧摊销', '成本', '金额', sort=12)]
    if cfg['include_other']:
        lines.append(line('B1', 'C3', cfg.get('other_name', '其他净损益（负数＝收益）'), '成本', '金额', sort=13,
                          note='旧模型“其他净贡献”取负号'))
    if equity:
        lines.append(line('B1', 'C4', '利息', '成本', '金额', sort=14, note='旧模型债务滚动算出的利息（平均带息负债×平均债务成本）'))
    d1, d2, c1 = {}, {}, {}
    for s in db.scenarios:
        n = s['name']
        d1[n], d2[n], c1[n] = {}, {}, {}
        for y in db.years:
            r = f[y]
            vol, price, cost = r['volume'] * s['volume_factor'], r['price'] * s['price_factor'], r['cash_cost'] * s['cost_factor']
            d1[n][y], d2[n][y] = vol, price
            c1[n][y] = {'金额': cost, '收入比例': cost / (vol * price), '单位成本': cost / vol}[cost_basis]
    rows.series('B1', '驱动1', jm['驱动1'], d1, line='R1')
    rows.series('B1', '驱动2', jm['驱动2'], d2, line='R1')
    rows.series('B1', {'金额': '金额', '收入比例': '比例', '单位成本': '单位成本'}[cost_basis], jm['付现成本'], c1, line='C1',
                note='旧逐年假设×情景成本系数')
    rows.series('B1', '金额', jm['折旧'], {y: f[y]['depreciation'] for y in db.years}, line='C2')
    if cfg['include_other']:
        rows.series('B1', '金额', jm['其他'], {y: -(f[y]['other_contrib'] or 0) for y in db.years}, line='C3')
    rows.series('B1', '税率', jm['税率'], {y: f[y]['tax_rate'] for y in db.years})
    if equity:
        interest = {r['year']: r['interest'] for r in q(f"SELECT f.year, c.interest FROM vi_forecast_base f JOIN vi_forecast_calc c ON c.id = f.id "
                                                        f"WHERE f.model_id = {db.model['id']}")}
        rows.series('B1', '金额', jm['利息'], interest, line='C4')
        rows.series('B1', '归母比例', jm['税率'], {y: 1 - (f[y]['minority_share'] or 0) for y in db.years}, '1−少数股东占比')
        proj = q(f"SELECT scenario_name, year, np_parent, dividend FROM vi_projection WHERE model_id = {db.model['id']}")
        ninv = {}
        for r in proj:
            ninv.setdefault(r['scenario_name'], {})[r['year']] = r['np_parent'] - r['dividend']
        rows.series('B1', '净投资', jm['净投资'], ninv, '股权口径：留存利润＝归母净利×(1−派息率)')
    else:
        gross = {y: 1 / (1 - (f[y]['minority_share'] or 0)) if cfg.get('parent_capex') else 1 for y in db.years}
        rows.series('B1', '净投资', jm['净投资'],
                    {y: round((f[y]['maint_capex'] + f[y]['growth_capex'] + (f[y]['wc_increase'] or 0)) * gross[y] - f[y]['depreciation'], 4)
                     for y in db.years},
                    '旧逐年假设换算：(维持资本＋扩张资本＋营运资本增加)' + ('÷(1−少数股东占比)' if cfg.get('parent_capex') else '') + '−折旧')
    for s in db.scenarios:
        rows.static('B1', '永续增长率', s['terminal_growth'], jm['永续增长率'], scen=s['name'])
    return lines


def normalized_margin(db, years, keep_invest_income=False, equity=False):
    """历史经营利润率均值：(利润总额＋财务费用−投资收益)÷收入；keep_invest_income＝投资收益属于经营（如合营项目）时不扣。"""
    if equity:   # 股权口径：税前利润率（利息后）＝利润总额÷收入
        vals = [h['pretax_profit'] / h['revenue'] for h in db.history()
                if h['year'] in years and h['pretax_profit'] is not None and h['revenue']]
    else:
        vals = [((h['pretax_profit'] + (h['finance_cost'] or 0) - (0 if keep_invest_income else (h['invest_income'] or 0))) / h['revenue'])
                for h in db.history() if h['year'] in years and h['pretax_profit'] is not None and h['revenue']]
    return round(sum(vals) / len(vals), 4), len(vals)


def bridge_from_bs(bs, spec):
    """spec: [(编号, 名称, 类别, [科目…], 计价处理, 说明)] → 资产负债桥行（账面价值，金额取科目合计；“其他调整”按负数＝扣减）。"""
    out = []
    for code, name, kind, items, treatment, note in spec:
        amt = sum(bs.get(i) or 0 for i in items) * (-1 if kind == '其他调整' else 1)
        detail = '＋'.join(f"{i} {bs[i]:,.1f}" for i in items if bs.get(i))
        out.append(dict(code=code, name=name, kind=kind, treatment=treatment, valuation_method='账面价值',
                        business='B1' if treatment == '已含业务估值' else None,
                        amount=round(abs(amt) if kind != '其他调整' else amt, 4), haircut=0,
                        basis=f"{detail}（亿元）。{note}".strip()))
    return out


def bridge_book(items):
    tot = 0.0
    for i in items:
        if i['treatment'] != '单独计价':
            continue
        if not (i['valuation_method'] == '账面价值' and i['kind'] != '资金汇出成本') and i['kind'] != '经营所需现金':
            continue
        tot += i['amount'] if i['kind'] == '其他调整' else SIGN[i['kind']] * abs(i['amount'])
    return tot


# ---------------------------------------------------------------- 单业务、由旧逐年假设换算的公司（长江电力、太阳纸业、中国建筑）
PROB = {'悲观': 0.25, '基准': 0.5, '乐观': 0.25}


def ddm_build(db, cfg):
    """cfg: biz（业务编号、名称、边界）、jmap（参数 → 依据编号）、bridge（bridge_from_bs 的 spec）、include_other、parent_capex、
    norm（正常化利润率的年份范围，None＝不填）、keep_invest_income、extra_judgments。"""
    as_of = cfg.get('as_of', '2026-06-30')
    co = db.co
    basis = cfg.get('basis', '企业')
    biz = dict(code='B1', name=cfg['biz_name'], kind='经营', capital_basis=basis,
               driver1_label=None, driver1_unit=None, driver2_label=None, driver2_unit=None, driver_scale=None,
               boundary=cfg['boundary'], sort=1)
    bs = db.bs(as_of)
    bridge = bridge_from_bs(bs, cfg['bridge'])
    equity = bs.get('归属于母公司股东权益合计')
    bb = bridge_book(bridge)
    ic0 = round(equity - bb, 2)
    rows = Rows(db.years, db.scenarios)
    lines = translate_forecast(db, rows, cfg)
    rows.static('B1', '期初投入资本', ic0, 'J-IC')
    judgments = [dict(code='J-IC', title='期初投入资本与资产负债桥（统一估值引擎）', status='已形成建议',
                      judgment=f'{as_of} 归母权益 {equity:,.1f} 亿元，减去资产负债桥里按账面计的项目净额 {bb:,.1f} 亿元'
                               f'（{"、".join(b["name"] for b in bridge if b["treatment"] == "单独计价")}；负数＝负债多于资产），'
                               f'得到{"股权口径的期初资本（归母净资产口径）" if basis == "股权" else "经营业务的期初投入资本"} {ic0:,.1f} 亿元。'
                               '业务资本和资产负债桥合起来正好是报表的归母权益，没有重复或遗漏（自动检查 V09 对账）。',
                      transmission='投入资本是资产价值（未填重置成本时）和 ROIC 的分母；资本增加从自由现金流里扣。',
                      parameter='估值假设·期初投入资本；资产负债桥 N 项',
                      change_threshold='新的半年报或年报出来后，按同一口径更新截至日与金额。')]
    if cfg.get('norm'):
        nm, n = normalized_margin(db, cfg['norm'], cfg.get('keep_invest_income', False), equity=basis == '股权')
        rows.static('B1', '正常化经营利润率', nm, 'J-NORM')
        judgments.append(dict(code='J-NORM', title='正常化经营利润率（盈利能力价值用）', status='已形成建议',
                              judgment=f'{cfg["norm"][0]}—{cfg["norm"][-1]} 年 {n} 年的平均' + (
                                  f'税前利润率 {nm * 100:.1f}%（利润总额÷营业收入，股权口径：利息后）' if basis == '股权' else
                                  f'经营利润率 {nm * 100:.1f}%（(利润总额＋财务费用{"" if cfg.get("keep_invest_income") else "−投资收益"})÷营业收入）')
                                  + '，代表一个完整周期的中枢。',
                              transmission='盈利能力价值＝第一个完整年度收入×正常化经营利润率×(1−税率)÷门槛；只影响“三层价值”的中间一层，不影响全价值。',
                              parameter='估值假设·正常化经营利润率',
                              change_threshold='行业格局或公司成本结构发生持久变化（不是周期波动）时改用新的中枢。'))
    judgments.append(dict(code='J-PROB', title='情景概率 25% / 50% / 25%（待确认）', status='已形成建议',
                          judgment='还没有逐一论证情景概率，先按悲观 25%、基准 50%、乐观 25% 给出概率加权价值；要改时写清楚为什么某一情景更可能。',
                          transmission='只影响概率加权每股价值，不影响各情景本身。',
                          parameter='情景·情景概率', change_threshold='有证据表明某一情景的可能性明显更高或更低。'))
    judgments += cfg.get('extra_judgments', [])
    return dict(as_of=as_of, businesses=[biz], lines=lines, judgments=judgments, probabilities=PROB, bridge=bridge, rows=rows.out)


# ---------------------------------------------------------------- SQL
def lit(v):
    if v is None:
        return 'NULL'
    if isinstance(v, bool):
        return 'true' if v else 'false'
    if isinstance(v, (int, float)):
        return repr(round(v, 8)) if isinstance(v, float) else str(v)
    return "'" + str(v).replace("'", "''") + "'"


def sql(code, d):
    co = f"(SELECT id FROM vi_company_base WHERE code = '{code}')"
    m = f"(SELECT id FROM vi_model_base WHERE company_id = {co} AND status = '当前')"
    out = [f"-- 自动生成：framework/value_engine_seed.py（companies/<公司>/value_engine.py）。统一估值引擎：业务、收入与成本项目、依据、资产负债桥、估值假设", 'BEGIN;',
           f"UPDATE vi_model_base SET sotp_as_of = {lit(d['as_of'])} WHERE id = {m};",
           f"DELETE FROM vi_assumption_base WHERE model_id = {m};",
           f"DELETE FROM vi_line_base WHERE business_id IN (SELECT id FROM vi_business_base WHERE company_id = {co});"]
    for code_ in d.get('drop_businesses', []):
        out.append(f"DELETE FROM vi_business_base WHERE company_id = {co} AND code = {lit(code_)};")
    for b in d['businesses']:
        cols = ['company_id'] + [k for k in b]
        vals = [co] + [lit(v) for v in b.values()]
        upd = ', '.join(f"{k} = EXCLUDED.{k}" for k in b if k != 'code')
        out.append(f"INSERT INTO vi_business_base ({', '.join(cols)}) VALUES ({', '.join(vals)}) "
                   f"ON CONFLICT (company_id, code) DO UPDATE SET {upd};")
    for ln in d.get('lines', []):
        ln = {k: v for k, v in ln.items() if v is not None}
        bz = f"(SELECT id FROM vi_business_base WHERE company_id = {co} AND code = {lit(ln.pop('business'))})"
        ln.pop('base_line', None)
        out.append(f"INSERT INTO vi_line_base (business_id, {', '.join(ln)}) VALUES ({bz}, {', '.join(lit(v) for v in ln.values())});")
    for ln in d.get('lines', []):
        if ln.get('base_line'):
            bz = f"(SELECT id FROM vi_business_base WHERE company_id = {co} AND code = {lit(ln['business'])})"
            out.append(f"UPDATE vi_line_base SET base_line_id = (SELECT id FROM vi_line_base WHERE business_id = {bz} AND code = {lit(ln['base_line'])}) "
                       f"WHERE business_id = {bz} AND code = {lit(ln['code'])};")
    for j in d.get('judgments', []):
        j = dict(j)
        theses = j.pop('theses', [])
        cols = ['company_id'] + list(j)
        out.append(f"INSERT INTO vi_judgment_base ({', '.join(cols)}) VALUES ({', '.join([co] + [lit(v) for v in j.values()])}) "
                   f"ON CONFLICT (company_id, code) DO UPDATE SET {', '.join(f'{k} = EXCLUDED.{k}' for k in j if k != 'code')};")
        for t in theses:
            out.append(f"""INSERT INTO vi_lnk_judgment_theses (judgment_id, thesis_id, "createdAt", "updatedAt")
SELECT j.id, t.id, now(), now() FROM vi_judgment_base j JOIN vi_thesis_base t ON t.company_id = j.company_id AND t.code = {lit(t)}
WHERE j.company_id = {co} AND j.code = {lit(j['code'])} ON CONFLICT DO NOTHING;""")
    for name, p in (d.get('probabilities') or {}).items():
        out.append(f"UPDATE vi_scenario_base SET probability = {lit(p)} WHERE model_id = {m} AND name = {lit(name)};")
    out.append(f"DELETE FROM vi_sotp_item_base WHERE model_id = {m} AND code LIKE 'N%';")
    for i in d.get('bridge', []):
        sc = f"(SELECT id FROM vi_scenario_base WHERE model_id = {m} AND name = {lit(i['scenario'])})" if i.get('scenario') else 'NULL'
        bz = f"(SELECT id FROM vi_business_base WHERE company_id = {co} AND code = {lit(i['business'])})" if i.get('business') else 'NULL'
        out.append(f"INSERT INTO vi_sotp_item_base (model_id, scenario_id, business_id, code, name, kind, treatment, valuation_method, amount, haircut, as_of, basis) "
                   f"VALUES ({m}, {sc}, {bz}, {lit(i['code'])}, {lit(i['name'])}, {lit(i['kind'])}, {lit(i['treatment'])}, {lit(i['valuation_method'])}, "
                   f"{lit(i['amount'])}, {lit(i['haircut'])}, {lit(d['as_of'])}, {lit(i['basis'])});")
    vals = []
    for biz, ln, scen, param, a, b, v, j, note in d['rows']:
        bz = f"(SELECT id FROM vi_business_base WHERE company_id = {co} AND code = {lit(biz)})"
        li = f"(SELECT id FROM vi_line_base WHERE business_id = {bz} AND code = {lit(ln)})" if ln else 'NULL'
        sc = f"(SELECT id FROM vi_scenario_base WHERE model_id = {m} AND name = {lit(scen)})" if scen else 'NULL'
        jd = f"(SELECT id FROM vi_judgment_base WHERE company_id = {co} AND code = {lit(j)})"
        vals.append(f"({m}, {bz}, {li}, {sc}, {lit(param)}, {lit(a)}, {lit(b)}, {lit(v)}, {jd}, {lit(note or None)})")
    out.append("INSERT INTO vi_assumption_base (model_id, business_id, line_id, scenario_id, parameter, from_year, to_year, value, judgment_id, note) VALUES\n"
               + ',\n'.join(vals) + ';')
    out.append('COMMIT;')
    return '\n'.join(out) + '\n'


def load(code):
    path = ROOT / 'companies' / COMPANIES[code] / 'value_engine.py'
    spec = importlib.util.spec_from_file_location(f've_{code}', path)
    mod = importlib.util.module_from_spec(spec)
    sys.path.insert(0, str(HERE))
    spec.loader.exec_module(mod)
    return mod, path.parent


def run(code, dry=False):
    mod, folder = load(code)
    d = mod.build(DB(code))
    text = sql(code, d)
    out = folder / 'value_engine.sql'
    out.write_text(text)
    print(code, len(d['rows']), '行估值假设 →', out.relative_to(ROOT))
    if not dry:
        subprocess.run([str(ROOT / 'psql.sh'), '-f', str(out.relative_to(ROOT))], check=True, cwd=ROOT)


if __name__ == '__main__':
    codes = [a for a in sys.argv[1:] if not a.startswith('--')] or list(COMPANIES)
    for c in codes:
        run(c, dry='--dry' in sys.argv)
