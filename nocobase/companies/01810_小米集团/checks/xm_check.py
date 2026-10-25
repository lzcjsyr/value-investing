"""公式复算：独立实现（xm_model.py）与数据库视图 vi_sotp_segment_val、vi_sotp 逐项对比。

用法：python3 xm_check.py     （需要在 nocobase 目录下能执行 ./psql.sh）
"""
import pathlib
import subprocess

import xm_model as M

ROOT = pathlib.Path(__file__).resolve().parents[3]


def sql(q):
    p = subprocess.run(['./psql.sh', '-At', '-F', '|', '-c', q], cwd=ROOT, capture_output=True, text=True, check=True)
    return [line.split('|') for line in p.stdout.strip().splitlines() if line]


def f(x):
    return None if x in ('', None) else float(x)


price = f(sql("SELECT cc.latest_price FROM vi_company_base c JOIN vi_company_calc cc ON cc.id = c.id WHERE c.code = '01810.HK'")[0][0])
mine = M.run(price=price)
rows, bad = [], []


def cmp(name, got, want, tol=0.01):
    ok = (got is None and want is None) or (got is not None and want is not None and abs(got - want) <= tol)
    rows.append((name, got, want, ok))
    if not ok:
        bad.append((name, got, want))


seg = sql("SELECT v.scenario_name, v.code, v.method, v.earnings, v.multiple_used, v.tau, v.terminal_pv, v.interim_pv, v.value, "
          "g.revenue, g.op_margin, g.interim_cash, g.direct_value FROM vi_sotp_segment_val v JOIN vi_sotp_segment_base g ON g.id = v.segment_id "
          "JOIN vi_model_base m ON m.id = v.model_id JOIN vi_company_base c ON c.id = m.company_id WHERE c.code = '01810.HK' AND m.status = '当前'")
for sname, code, method, e, mult, tau, tpv, ipv, val, rev, om, ic, dv in seg:
    x = mine[sname]['segs'][code]
    cmp(f'{sname} {code} 价值', f(val), x['value'])
    cmp(f'{sname} {code} 期间现金流现值', f(ipv), x['interim_pv'])
    if method != '直接估值':
        cmp(f'{sname} {code} 盈利', f(e), x['earnings'])
        cmp(f'{sname} {code} 倍数', f(mult), x['multiple'], tol=1e-6)
        cmp(f'{sname} {code} 折现年数', f(tau), x['tau'], tol=1e-9)
        cmp(f'{sname} {code} 终值现值', f(tpv), x['value'] - x['interim_pv'])
    else:
        cmp(f'{sname} {code} 直接估值', f(dv), x['value'])
top = sql("SELECT scenario_name, segments_value, mature_value, growth_value, direct_value, invest_value, usable_net_cash, noncore, equity_value, value_per_share, "
          "mature_multiple, implied_mature_multiple, implied_growth_value, weighted_value FROM vi_sotp WHERE company_name = '小米集团'")
for sname, sv, mv, gv, dv, iv, unc, nc, eq, vps, mm, imm, igv, wv in top:
    x = mine[sname]
    cmp(f'{sname} 分部合计', f(sv), x['segments_value'])
    cmp(f'{sname} 成熟业务', f(mv), x['mature_value'])
    cmp(f'{sname} 成长业务', f(gv), x['growth_value'])
    cmp(f'{sname} 直接估值业务', f(dv), x['direct_value'])
    cmp(f'{sname} 投入期业务（应为空）', f(iv), None)
    cmp(f'{sname} 可用净现金', f(unc), x['usable_net_cash'])
    cmp(f'{sname} 非经营部分', f(nc), x['noncore'])
    cmp(f'{sname} 股权价值', f(eq), x['equity'])
    cmp(f'{sname} 每股价值', f(vps), x['vps'], tol=1e-4)
    cmp(f'{sname} 成熟业务倍数', f(mm), x['mature_multiple'], tol=1e-6)
    cmp(f'{sname} 市场隐含成熟业务倍数', f(imm), x['implied_mature_multiple'], tol=1e-6)
    cmp(f'{sname} 市场隐含成长业务价值', f(igv), x['implied_growth_value'])
    cmp(f'{sname} 概率加权每股价值', f(wv), x['weighted'], tol=1e-4)
print(f'股价 {price:.4f} 元；复算 {len(rows)} 项，不一致 {len(bad)} 项')
for name, got, want in bad:
    print(f'  ✗ {name}：数据库 {got}，复算 {want}')
for s, x in mine.items():
    print(f"  {s}：每股 {x['vps']:.2f} 元（" + '、'.join(f"{c} {v['value']:,.1f}" for c, v in x['segs'].items()) + f"；非经营 {x['noncore']:,.1f}）")
