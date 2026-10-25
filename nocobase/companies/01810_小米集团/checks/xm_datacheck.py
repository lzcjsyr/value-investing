"""数据核对：分业务年度数据、季度数据、估值输入，与公告原文数字、东方财富原始报表、数据库逐项对照。

用法：python3 xm_datacheck.py     （需要在 nocobase 目录下能执行 ./psql.sh）
"""
import json
import pathlib
import subprocess

import xm_model as M

ROOT = pathlib.Path(__file__).resolve().parents[3]
S = M.load_seed()
DATA = S.DATA
RESULTS = []


def check(group, name, got, want, tol=0.05):
    ok = got is not None and want is not None and abs(got - want) <= tol
    RESULTS.append((group, name, got, want, ok))


def em(name, period):
    out = {}
    for r in json.loads((DATA / f'eastmoney_hk_{name}.json').read_text()):
        if r['AMOUNT'] == r['AMOUNT']:
            out.setdefault(r['REPORT_DATE'][:10] if period else int(r['REPORT_DATE'][:4]), {})[r['STD_ITEM_NAME']] = r['AMOUNT'] / 1e8
    return out


def sql(q):
    p = subprocess.run(['./psql.sh', '-At', '-F', '|', '-c', q], cwd=ROOT, capture_output=True, text=True, check=True)
    return [line.split('|') for line in p.stdout.strip().splitlines() if line]


L, LR = em('income', False), em('income_rpt', True)
OPEX_ITEMS = ('研发费用', '销售及分销费用', '行政开支')

# ---------------------------------------------------------------- A 分业务年度数据
for y, (pr, pg, ir, ig, nr, ng, orv, og) in S.LINE_HIST.items():
    rev, gp = (pr + ir + nr + orv) / 100, (pg + ig + ng + og) / 100
    if y <= 2023:
        check('A 分业务年度', f'{y} 四项收入合计＝东方财富营业额', rev, L[y]['营业额'])
        check('A 分业务年度', f'{y} 四项毛利合计＝东方财富毛利', gp, L[y]['毛利'])
    else:
        qs = [S.Q[f'{y}Q{i}'] for i in range(1, 5)]
        check('A 分业务年度', f'{y} 四项收入合计＝四个季度手机×AIoT 收入', rev, sum(q[2] for q in qs))
        check('A 分业务年度', f'{y} 四项毛利合计＝四个季度手机×AIoT 毛利', gp, sum(q[7] for q in qs))
        check('A 分业务年度', f'{y} 手机×AIoT＋汽车及 AI 收入＝东方财富营业额', rev + sum(q[3] for q in qs), L[y]['营业额'])
        check('A 分业务年度', f'{y} 手机×AIoT＋汽车及 AI 毛利＝东方财富毛利', gp + sum(q[8] for q in qs), L[y]['毛利'])
        tag = '（四季度由全年倒算，按构造一致）' if y == 2024 else ''
        for lab, i, val in (('手机收入', 4, pr), ('IoT 收入', 5, ir), ('互联网收入', 6, nr), ('手机毛利', 9, pg), ('IoT 毛利', 10, ig), ('互联网毛利', 11, ng)):
            check('A 分业务年度', f'{y} {lab}＝四个季度之和{tag}', val / 100, sum(q[i] for q in qs))
# 公告正文写出的毛利率（%）
DISCLOSED = [(2019, 'IoT', 11.2), (2020, 'IoT', 12.8), (2021, '手机', 11.9), (2021, 'IoT', 13.1), (2022, '手机', 9.0), (2022, 'IoT', 14.4),
             (2022, '互联网', 71.8), (2023, '手机', 14.6), (2023, 'IoT', 16.3), (2023, '互联网', 74.2), (2024, '手机', 12.6), (2024, 'IoT', 20.3),
             (2024, '互联网', 76.6), (2025, '手机', 10.9), (2025, 'IoT', 23.1), (2025, '互联网', 76.5)]
for y, line, pct in DISCLOSED:
    pr, pg, ir, ig, nr, ng, orv, og = S.LINE_HIST[y]
    got = {'手机': pg / pr, 'IoT': ig / ir, '互联网': ng / nr}[line] * 100
    check('A 分业务年度', f'{y} {line}毛利率＝公告正文 {pct}%', round(got, 1), pct, tol=0.001)
for y, pct in ((2020, 14.9), (2021, 17.7), (2022, 17.0)):
    pr, pg, ir, ig, nr, ng, orv, og = S.LINE_HIST[y]
    check('A 分业务年度', f'{y} 集团毛利率＝公告正文 {pct}%', round((pg + ig + ng + og) / (pr + ir + nr + orv) * 100, 1), pct, tol=0.001)
# 数据库里的年度分业务行＝种子按原始数据重算
db = {(r[0], r[1]): float(r[2]) for r in sql("SELECT d.period, d.line_item, d.value FROM vi_period_data_base d JOIN vi_company_base c ON c.id = d.company_id "
                                             "WHERE c.code = '01810.HK' AND d.period_kind = '全年'")}
for per, item, val, unit, src, summ in S.line_annual():
    check('A 分业务年度', f'数据库 {per} {item}', db.get((per, item)), val, tol=0.005)
# 生态营业费用率：东方财富费用−创新业务/汽车分部开支，再除以生态收入；与种子里的生态利润率（推算）一致
ECO_MARGIN = {2019: 3.68, 2020: 3.75, 2021: 5.90, 2022: 2.93, 2023: 7.65, 2024: 8.61, 2025: 7.93}
for y, (pr, pg, ir, ig, nr, ng, orv, og) in S.LINE_HIST.items():
    rev = (pr + ir + nr + orv) / 100
    opex = sum(L[y][k] for k in OPEX_ITEMS) - S.ECO_EXCL.get(y, 0)
    check('A 分业务年度', f'{y} 生态利润率＝毛利率−费用率（{ECO_MARGIN[y]}%）', round(((pg + ig + ng + og) / 100 - opex) / rev * 100, 2), ECO_MARGIN[y], tol=0.011)

# ---------------------------------------------------------------- B 季度数据与费用
prev = {'2024Q1': '2023-12-31'}
ends = {p: S.Q[p][0] for p in S.Q}
order = sorted(S.Q)
for i, p in enumerate(order):
    end = ends[p]
    start = None if p.endswith('Q1') else ends[order[i - 1]]
    cur = LR[end]
    q_rev = cur['营业额'] - (LR[start]['营业额'] if start else 0)
    q_gp = cur['毛利'] - (LR[start]['毛利'] if start else 0)
    check('B 季度', f'{p} 集团收入＝东方财富累计数相减', S.Q[p][1], q_rev)
    check('B 季度', f'{p} 两个分部收入之和＝集团收入', S.Q[p][2] + S.Q[p][3], S.Q[p][1])
    check('B 季度', f'{p} 两个分部毛利之和＝东方财富毛利', S.Q[p][7] + S.Q[p][8], q_gp, tol=0.06)
    if p in S.OPEX:
        q_opex = sum(cur[k] for k in OPEX_ITEMS) - (sum(LR[start][k] for k in OPEX_ITEMS) if start else 0)
        check('B 季度', f'{p} 集团研发、销售、行政＝东方财富累计数相减', S.OPEX[p], q_opex)
for p, pct in (('2026Q1', 14.9), ('2026Q2', 14.2)):
    q = S.Q[p]
    check('B 季度', f'{p} 生态营业费用率（推算）≈公司披露 {pct}%', round((S.OPEX[p] - q[16]) / q[2] * 100, 1), pct, tol=0.11)
h1 = S.h1_lines()
want = {'手机收入': 863.9, '手机毛利': 80.8, 'IoT 收入': 559.6, 'IoT 毛利': 124.9, '其他收入': 24.4, '其他毛利': -0.8, '互联网收入': 185.1, '互联网毛利': 141.5,
        '营业费用': 237.2, '手机分摊后': -44.7, 'AIoT 分摊后': 39.3, '互联网分摊后': 114.6, '合计': 109.1}
q1, q2 = S.Q['2026Q1'], S.Q['2026Q2']
got = {'手机收入': q1[4] + q2[4], '手机毛利': q1[9] + q2[9], 'IoT 收入': q1[5] + q2[5], 'IoT 毛利': q1[10] + q2[10],
       '其他收入': q1[2] + q2[2] - (q1[4] + q2[4] + q1[5] + q2[5] + q1[6] + q2[6]),
       '其他毛利': q1[7] + q2[7] - (q1[9] + q2[9] + q1[10] + q2[10] + q1[11] + q2[11]),
       '互联网收入': q1[6] + q2[6], '互联网毛利': q1[11] + q2[11], '营业费用': S.OPEX['2026Q1'] - q1[16] + S.OPEX['2026Q2'] - q2[16],
       '手机分摊后': None, 'AIoT 分摊后': None, '互联网分摊后': None, '合计': None}
x = got['营业费用'] / (q1[2] + q2[2])                    # 不经过 h1_lines() 的两位小数取整，避免二次取整
got['手机分摊后'] = got['手机毛利'] - got['手机收入'] * x
got['AIoT 分摊后'] = got['IoT 毛利'] + got['其他毛利'] - (got['IoT 收入'] + got['其他收入']) * x
got['互联网分摊后'] = got['互联网毛利'] - got['互联网收入'] * x
got['合计'] = got['手机分摊后'] + got['AIoT 分摊后'] + got['互联网分摊后']
for k in ('phone', 'aiot', 'net'):
    check('B 季度', f'h1_lines() {k} 与直接计算一致', h1[k][1], {'phone': got['手机分摊后'], 'aiot': got['AIoT 分摊后'], 'net': got['互联网分摊后']}[k], tol=0.006)
for k in want:
    check('B 季度', f'2026 年上半年 {k}＝事实卡 F_H1_LINES', round(got[k], 1), want[k], tol=0.051)

# ---------------------------------------------------------------- C 历史财务（数据库）＝东方财富年度报表
FH = {int(r[0]): [float(x) if x else None for x in r[1:]] for r in sql(
    "SELECT h.year, h.revenue, h.cost_of_sales, h.pretax_profit, h.np_parent, h.cfo, h.capex, h.equity_parent FROM vi_fin_history_base h "
    "JOIN vi_company_base c ON c.id = h.company_id WHERE c.code = '01810.HK'")}
X, Z = em('cashflow', False), em('balance', False)
for y in range(2018, 2026):
    for lab, got_, want_ in (('收入', FH[y][0], L[y]['营业额']), ('营业成本', FH[y][1], L[y]['销售成本']), ('税前利润', FH[y][2], L[y]['除税前溢利']),
                             ('归母净利', FH[y][3], L[y]['股东应占溢利']), ('经营现金流', FH[y][4], X[y]['经营业务现金净额']),
                             ('资本开支', FH[y][5], abs(X[y]['购建固定资产'])), ('归母权益', FH[y][6], Z[y]['股东权益'])):
        check('C 历史财务', f'{y} {lab}', abs(got_) if lab == '资本开支' else got_, want_, tol=0.011)

# ---------------------------------------------------------------- D 估值输入
check('D 估值输入', '在外股本＝B 类＋A 类−待注销（亿股，种子取四位小数）', (21341753161 + 4443616133 - 75925000) / 1e8, S.SHARES, tol=1e-4)
for name, px, sh, fact in (('智谱', 460.8, 487588090, 1912), ('MiniMax', 160.7, 352480183, 482)):
    check('D 估值输入', f'{name} 市值（亿元）＝收盘价×总股本×0.851', round(px * sh / 1e8 * 0.851, 0), fact, tol=0.5)
r = M.base_rate(S)
check('D 估值输入', '剩余承诺投入税后现值≈331 亿元', 513 * 0.75 / 2.5 * (1 - (1 + r) ** -2.5) / r, 331, tol=0.5)
eco_norm = sum(S.LINES['基准'][k]['norm'][0] * (S.LINES['基准'][k]['norm'][1] - S.LINES['基准'][k]['norm'][2]) for k in S.LINES['基准'])
check('D 估值输入', '基准正常化生态经营利润≈2025 年实际 278.4 亿元（±5）', eco_norm, 278.4, tol=5)
for s in S.LINES:
    for k in S.LINES[s]:
        d = S.LINES[s][k]
        ok_ = all(0 < d[p][1] < 1 and 0 < d[p][2] < 0.3 for p in d)
        RESULTS.append(('D 估值输入', f'{s} {k} 毛利率与费用率在合理区间', None, None, ok_))

# ---------------------------------------------------------------- 输出
bad = [r for r in RESULTS if not r[4]]
groups = {}
for g, *_ , ok in RESULTS:
    groups.setdefault(g, [0, 0])[0 if ok else 1] += 1
for g, (n_ok, n_bad) in groups.items():
    print(f'{g}：{n_ok} 项一致' + (f'，{n_bad} 项不一致' if n_bad else ''))
for g, name, got_, want_, ok in bad:
    print(f'  ✗ {g} {name}：得到 {got_}，应为 {want_}')
print(f'合计 {len(RESULTS)} 项，不一致 {len(bad)} 项')
