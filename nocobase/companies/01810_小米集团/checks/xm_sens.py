"""敏感性：在独立复算（xm_model.py）上逐项改一个输入，看基准情景每股价值与概率加权价值的变化。"""

import sys

import xm_model as M

PRICE = float(sys.argv[1]) if len(sys.argv) > 1 else 21.96

BASE = M.run(M.load_seed(), PRICE)


def fresh():
    S = M.load_seed()
    return S


def show(label, fn, scen='基准'):
    S = fresh()
    fn(S)
    r = M.run(S, PRICE)
    b, b0 = r[scen]['vps'], BASE[scen]['vps']
    w, w0 = r[scen]['weighted'], BASE[scen]['weighted']
    print(f"{label:<46} {scen} {b:6.2f}（{b - b0:+.2f}）  加权 {w:6.2f}（{w - w0:+.2f}）")
    return r


def set_line(S, k, field, idx, delta, scen=None, parts=('norm',)):
    for s in ([scen] if scen else list(S.LINES)):
        for part in parts:
            if part in S.LINES[s][k]:
                t = list(S.LINES[s][k][part])
                t[idx] = round(t[idx] + delta, 6)
                S.LINES[s][k][part] = tuple(t)


def realloc(S, net_ratio=None, by_gp=False):
    """改变营业费用在三块业务之间的分摊（总费用不变）。net_ratio：互联网费用率固定为该值，其余按收入分给手机与 AIoT；by_gp：按毛利分摊。"""
    for s in S.LINES:
        for part in ('h2', 'y27', 'norm'):
            ks = [k for k in ('phone', 'aiot', 'net') if part in S.LINES[s][k]]
            if part == 'y27':
                ks = ['phone', 'aiot', 'net']
            d = {k: S.LINES[s][k].get(part) or S.LINES[s][k]['norm'] for k in ks}
            total_opex = sum(v[0] * v[2] for v in d.values())
            if by_gp:
                gp = {k: v[0] * v[1] for k, v in d.items()}
                new = {k: total_opex * gp[k] / sum(gp.values()) / d[k][0] for k in ks}
            else:
                net_opex = d['net'][0] * net_ratio
                rest = sum(d[k][0] for k in ks if k != 'net')
                new = {k: (net_ratio if k == 'net' else (total_opex - net_opex) / rest) for k in ks}
            for k in ks:
                if part in S.LINES[s][k]:
                    rev, gm, _ = S.LINES[s][k][part]
                    S.LINES[s][k][part] = (rev, gm, round(new[k], 6))


print(f"基准 {BASE['基准']['vps']:.2f} 元；悲观 {BASE['悲观']['vps']:.2f}；乐观 {BASE['乐观']['vps']:.2f}；加权 {BASE['基准']['weighted']:.2f}（股价 {PRICE} 元）")
for k, lab in (('phone', '手机'), ('aiot', 'AIoT'), ('net', '互联网')):
    show(f'{lab}正常化毛利率 +1pt（三个情景）', lambda S, k=k: set_line(S, k, 'gm', 1, 0.01))
    show(f'{lab}正常化毛利率 −1pt（三个情景）', lambda S, k=k: set_line(S, k, 'gm', 1, -0.01))
show('营业费用率 +0.5pt（三块、正常化年份）', lambda S: [set_line(S, k, 'ox', 2, 0.005) for k in ('phone', 'aiot', 'net')])
show('营业费用率 −0.5pt（三块、正常化年份）', lambda S: [set_line(S, k, 'ox', 2, -0.005) for k in ('phone', 'aiot', 'net')])
show('营业费用率 +1pt（三块、正常化与过渡期）', lambda S: [set_line(S, k, 'ox', 2, 0.01, parts=('h2', 'y27', 'norm')) for k in ('phone', 'aiot', 'net')])
show('费用分摊：互联网费用率 25%（总费用不变）', lambda S: realloc(S, net_ratio=0.25))
show('费用分摊：按毛利分摊（总费用不变）', lambda S: realloc(S, by_gp=True))
show('过渡期手机毛利率 −1pt（2026H2、2027）', lambda S: set_line(S, 'phone', 'gm', 1, -0.01, parts=('h2', 'y27')))


def delay(S):
    """手机与 AIoT 正常化后移一年：2028 年按 2027 年的水平计入过渡期。"""
    S.LINE_META['phone'] = S.LINE_META['phone'][:3] + (2029,)
    S.LINE_META['aiot'] = S.LINE_META['aiot'][:3] + (2029,)
    orig = S.line_interim

    def li(s, k, orig=orig, S=S):
        v = orig(s, k)
        if k in ('phone', 'aiot'):
            rev, gm, ox = S.LINES[s][k]['y27']
            v = round(v + rev * (gm - ox) * (1 - S.TAX), 2)
        return v
    S.line_interim = li


show('手机与 AIoT 正常化后移一年（2029 年）', delay)


def g_phone(S, g):
    for s in S.LINE_GR['phone']:
        S.LINE_GR['phone'][s] = (g, S.LINE_GR['phone'][s][1])


show('手机永续增长 0%→3%（亏损随规模增长）', lambda S: g_phone(S, 0.03))


def net_gr(S, g=None, ronic=None):
    for s, (g0, r0) in list(S.LINE_GR['net'].items()):
        S.LINE_GR['net'][s] = (g if g is not None else g0, ronic if ronic is not None else r0)


show('互联网新增投资回报率 →30%', lambda S: net_gr(S, ronic=0.30))
show('互联网永续增长 →2%', lambda S: net_gr(S, g=0.02))
show('三块都用情景倍数（AIoT 口径）', lambda S: [S.LINE_GR.__setitem__(k, {s: None for s in S.LINE_GR[k]}) for k in ('phone', 'net')])


def same_year(S):
    S.LINE_META['net'] = S.LINE_META['net'][:3] + (2028,)
    for s in S.LINES:
        n = S.LINES[s]['net']
        n['y27'] = n['norm']


show('三块都用情景倍数且都在 2028 年正常化', lambda S: (same_year(S), [S.LINE_GR.__setitem__(k, {s: None for s in S.LINE_GR[k]}) for k in ('phone', 'net')]))
for v in (0, 669, 1500):
    show(f'AI 直接估值 1,000→{v:,} 亿元', lambda S, v=v: S.AI_VALUE.update({s: float(v) for s in S.AI_VALUE}))


def rate(S, d):
    S.SCEN = [tuple(list(x[:3]) + [(x[3] if x[3] is not None else M.base_rate(S)) + d if x[1] else x[3]] + list(x[4:])) for x in S.SCEN]


show('基准折现率 +1pt（9.1%→10.1%）', lambda S: rate(S, 0.01))
show('基准折现率 −1pt（9.1%→8.1%）', lambda S: rate(S, -0.01))


def prob(S, pb, pm, pu):
    m = {'悲观': pb, '基准': pm, '乐观': pu}
    S.SCEN = [tuple(list(x[:6]) + [m[x[0]]] + list(x[7:])) for x in S.SCEN]


show('概率 35/40/25', lambda S: prob(S, 0.35, 0.40, 0.25))
show('经营所需现金 +100 亿元', lambda S: S.OPCASH.update({s: S.OPCASH[s] + 100 for s in S.OPCASH}) or setattr(S, 'SOTP_ITEMS', [
    (i[0], i[1], i[2], i[3], (S.OPCASH[i[1]] if i[0] == 'C5' else i[4]), *i[5:]) for i in S.SOTP_ITEMS]))
b = BASE['基准']
print('\n基准分部明细（亿元）：' + '；'.join(f"{c} {x['value']:,.1f}" for c, x in b['segs'].items()) +
      f"；成熟业务倍数 {b['mature_multiple']:.2f}；市场隐含成熟倍数 {b['implied_mature_multiple']:.2f}、隐含汽车价值 {b['implied_growth_value']:,.0f}")
