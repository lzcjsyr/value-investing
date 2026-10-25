"""独立复算：只读 seed.py 里的输入常量，按框架公式（02_calc.sql 的 vi_sotp_segment_val / vi_sotp）重新计算分部估值。

不读数据库、不调用种子的 SQL 生成函数，用来和数据库视图逐项对比（xm_check.py），也供敏感性分析（xm_sens.py）复用。
"""
import importlib.util
import pathlib
from datetime import date

HERE = pathlib.Path(__file__).resolve().parent


def load_seed():
    spec = importlib.util.spec_from_file_location('xm_seed', HERE.parent / 'seed.py')
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def base_rate(S):
    return round(0.0164 + 0.075, 3)          # 估值模型：无风险利率 1.64%＋风险溢价 7.5%，框架按三位小数取整


def tau(as_of, earn_year):
    return max(0.0, (date(earn_year - 1, 12, 31) - as_of).days / 365.25)


def scenarios(S):
    r0 = base_rate(S)
    return {name: dict(r=r if r is not None else r0, g=g, ronic=ronic, p=p, sort=sort)
            for name, is_base, sort, r, g, ronic, p, nature, desc in S.SCEN}


def segment_rows(S, s):
    """按种子的业务规则重建某情景的经营分部输入（与 seed.segments() 同一套常量，但不经过 SQL）。"""
    rows = []
    for k, (code, name, stage, year) in S.LINE_META.items():
        rev, gm, ox = S.LINES[s][k]['norm']
        gr = S.LINE_GR[k][s]
        rows.append(dict(code=code, method='盈利×倍数', earn_year=year, revenue=rev, op_margin=S.line_margin(s, k), tax=S.TAX,
                         multiple=None, ronic=gr[1] if gr else None, growth=gr[0] if gr else None, r=None, interim=S.line_interim(s, k)))
    v = S.EV[s]
    vol, asp, oth, mg = v['steady']
    rows.append(dict(code='S4', method='稳态折现', earn_year=2030, revenue=round(S.ev_rev(vol, asp, oth), 2), op_margin=mg, tax=S.TAX,
                     multiple=v['mult'], ronic=None, growth=None, r=v['r'], interim=S.ev_interim(s)))
    rows.append(dict(code='S5', method='直接估值', direct=S.AI_VALUE[s]))
    return rows


def seg_value(row, sc, as_of):
    if row['method'] == '直接估值':
        return dict(code=row['code'], method=row['method'], value=row['direct'], earnings=None, earn_pv=None, interim_pv=0.0, multiple=None, tau=0.0)
    r = row['r'] if row['r'] is not None else sc['r']
    g = row['growth'] if row['growth'] is not None else sc['g']
    ronic = row['ronic'] if row['ronic'] is not None else sc['ronic']
    e = row['revenue'] * row['op_margin'] * (1 - row['tax'])
    fm = (1 - g / ronic) / (r - g) if ronic and ronic > 0 and r > g else None
    m = row['multiple'] if row['multiple'] is not None else fm
    t = tau(as_of, row['earn_year'])
    tpv = e * m / (1 + r) ** t
    ipv = row['interim'] / (1 + r) ** (t / 2)
    return dict(code=row['code'], method=row['method'], value=tpv + ipv, earnings=e, earn_pv=e / (1 + r) ** t, interim_pv=ipv,
                multiple=m, formula_multiple=fm, tau=t, r=r, g=g, ronic=ronic)


def noncore(S, s):
    """分部估值项：同编号有情景专属行时以专属行为准；符号规则同 vi_sotp_item_calc。"""
    pick = {}
    for code, sname, name, kind, amount, haircut, basis, facts in S.SOTP_ITEMS:
        if sname not in (None, s):
            continue
        if code in pick and pick[code][0] is not None and sname is None:
            continue
        pick[code] = (sname, kind, amount, haircut)
    total, parts = 0.0, {}
    for code, (sname, kind, amount, haircut) in pick.items():
        if kind == '其他调整':
            v = amount
        elif kind in ('现金及等价物', '对外投资'):
            v = abs(amount)
        else:
            v = -abs(amount)
        v *= 1 - (haircut or 0)
        parts[code] = v
        total += v
    usable = sum(parts[c] for c in ('C1', 'C2', 'C3', 'C4', 'C5', 'C6') if c in parts)
    return total, usable, parts


def run(S=None, price=None, overrides=None):
    """返回每个情景的结果字典；price 为人民币股价（None 时不算市场隐含值）。overrides(S) 可在计算前修改常量。"""
    S = S or load_seed()
    if overrides:
        overrides(S)
    as_of = date.fromisoformat(S.AS_OF)
    out = {}
    for s, sc in scenarios(S).items():
        segs = [seg_value(row, sc, as_of) for row in segment_rows(S, s)]
        nc, usable, parts = noncore(S, s)
        segv = sum(x['value'] for x in segs)
        mature = [x for x in segs if x['method'] == '盈利×倍数']
        mv = sum(x['value'] for x in mature)
        mepv = sum(x['earn_pv'] for x in mature)
        mipv = sum(x['interim_pv'] for x in mature)
        growth = sum(x['value'] for x in segs if x['method'] == '稳态折现')
        direct = sum(x['value'] for x in segs if x['method'] == '直接估值')
        equity = segv + nc
        vps = equity / S.SHARES
        res = dict(scenario=s, p=sc['p'], r=sc['r'], segs={x['code']: x for x in segs}, segments_value=segv, mature_value=mv,
                   mature_earn_pv=mepv, mature_interim_pv=mipv, mature_multiple=(mv - mipv) / mepv, growth_value=growth,
                   direct_value=direct, noncore=nc, usable_net_cash=usable, items=parts, equity=equity, vps=vps)
        if price is not None:
            mcap = price * S.SHARES
            res['implied_mature_multiple'] = (mcap - nc - growth - direct - mipv) / mepv
            res['implied_growth_value'] = mcap - nc - mv - direct
        out[s] = res
    w = sum(o['p'] * o['vps'] for o in out.values()) / sum(o['p'] for o in out.values())
    for o in out.values():
        o['weighted'] = w
    return out


if __name__ == '__main__':
    import sys
    price = float(sys.argv[1]) if len(sys.argv) > 1 else None
    res = run(price=price)
    for s, o in res.items():
        print(f"== {s}（概率 {o['p']:.0%}，r＝{o['r']:.3f}）")
        for c, x in o['segs'].items():
            if x['method'] == '直接估值':
                print(f"  {c} 直接估值 {x['value']:,.1f}")
            else:
                print(f"  {c} {x['method']}：盈利 {x['earnings']:,.2f} × {x['multiple']:.2f} 倍，τ {x['tau']:.3f}，"
                      f"终值现值 {x['value'] - x['interim_pv']:,.1f}＋期间 {x['interim_pv']:,.1f} ＝ {x['value']:,.1f}")
        print(f"  分部合计 {o['segments_value']:,.1f}（成熟 {o['mature_value']:,.1f}、成长 {o['growth_value']:,.1f}、直接估值 {o['direct_value']:,.1f}）；"
              f"非经营 {o['noncore']:,.1f}（可用净现金 {o['usable_net_cash']:,.1f}）")
        print(f"  股权 {o['equity']:,.1f} → 每股 {o['vps']:.2f} 元；成熟业务倍数 {o['mature_multiple']:.2f}")
        if price is not None:
            print(f"  市场隐含：成熟业务 {o['implied_mature_multiple']:.2f} 倍；成长业务（汽车）{o['implied_growth_value']:,.1f} 亿元")
    print(f"概率加权 {next(iter(res.values()))['weighted']:.2f} 元")
