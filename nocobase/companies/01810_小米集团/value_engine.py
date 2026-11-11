"""小米集团 → 统一估值引擎（2026-11-08；11-09 按公司披露的分部重排）：
- E1 手机×AIoT 生态（公司披露的分部）：手机、AIoT、互联网服务是三条收入线，各自的成本按披露的分品类毛利率；营业费用是生态共用的一条成本线，
  不再按收入分摊（旧模型分摊后手机“亏损”，是分摊口径造成的）。逐年收入、毛利率、费用率取 seed.py 已有的路径（LINES）。
- S4 智能电动汽车：2026 年直接填收入，2027 年起交付量×ASP×(1＋其他收入比例)，经营利润率（不含 AI）。
- S5 AI 等新业务：沿用直接估值 1,000 亿元。资产负债桥沿用 C1—C11。
商业模式画布仍按 S1—S3 写（手机、AIoT、互联网），它们在估值里是 E1 的收入线。"""
import importlib.util
import pathlib
from value_engine_seed import Rows, line

HERE = pathlib.Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('xiaomi_seed', HERE / 'seed.py')
S = importlib.util.module_from_spec(spec)
spec.loader.exec_module(S)

KEYS = {'phone': ('R1', 'C1', '智能手机', 'J-PHONE'), 'aiot': ('R2', 'C2', 'AIoT 与生活消费产品（含其他相关业务）', 'J-AIOT'),
        'net': ('R3', 'C3', '互联网服务', 'J-NET')}
WEIGHT = {'E1': None, 'S4': 2.0}     # 期初投入资本分摊：生态按手机、AIoT 1、互联网 0.2 的收入权重，汽车 2；AI 不分资本


def h1_gross():
    """2026 年上半年三条收入线的收入与毛利、生态营业费用（亿元），由 seed.py 的季度数据计算。"""
    ps = ('2026Q1', '2026Q2')
    gp = {'phone': sum(S.Q[p][9] for p in ps), 'net': sum(S.Q[p][11] for p in ps)}
    gp['aiot'] = sum(S.Q[p][7] for p in ps) - gp['phone'] - gp['net']
    rev = {k: S.H1_LINES[k][0] for k in KEYS}
    opex = sum(S.OPEX[p] - S.Q[p][16] for p in ps)
    return rev, gp, opex


def build(db):
    rows = Rows(db.years, db.scenarios)
    scen = {s['name']: s for s in db.scenarios}
    h1_rev, h1_gp, h1_opex = h1_gross()
    rev, cost, opex = {k: {} for k in KEYS}, {k: {} for k in KEYS}, {}
    for s in scen:
        paths = {k: S.line_path(s, k)[0] for k in KEYS}
        for k in KEYS:
            rev[k][s], cost[k][s] = {}, {}
        opex[s] = {}
        for y in db.years:
            ox_amt, tot = 0.0, 0.0
            for k in KEYS:
                d = S.LINES[s][k]
                r = paths[k][y]
                if y == 2026:
                    rv, gm, ox = d['h2']
                    gp = h1_gp[k] + rv * gm
                    ox_amt += rv * ox
                elif y == 2027 and 'y27' in d:
                    _, gm, ox = d['y27']
                    gp = r * gm
                    ox_amt += r * ox
                else:
                    _, gm, ox = d['norm']
                    gp = r * gm
                    ox_amt += r * ox
                rev[k][s][y], cost[k][s][y] = r, 1 - gp / r
                tot += r
            if y == 2026:
                ox_amt += h1_opex
            opex[s][y] = ox_amt / tot
    for k, (rc, cc, name, j) in KEYS.items():
        rows.series('E1', '金额', j, rev[k], '取自 seed.py 的分部路径（2026 年＝上半年实际＋下半年假设）', line=rc)
        rows.series('E1', '比例', j, cost[k], '1−该品类毛利率（公司披露口径）', line=cc)
    rows.series('E1', '比例', 'J-OPEX', opex, '生态营业费用（销售、管理、研发）÷生态收入；2026 年含上半年实际', line='C4')
    # 汽车
    d1, d2, d3, emg, erev26 = {}, {}, {}, {}, {}
    for s in scen:
        v = S.EV[s]
        er, eo = S.base_paths(s)[2:4]
        erev26[s] = {2026: er[2026]}
        d1[s], d2[s], d3[s], emg[s] = {}, {}, {}, {2026: eo[2026] / er[2026]}
        for y, p in zip([2027, 2028, 2029], v['path'][1:]):
            d1[s][y], d2[s][y], d3[s][y], emg[s][y] = p[0], p[1], 1 + p[2], p[3]
        vol, asp, oth, mg = v['steady']
        for y in range(2030, db.years[-1] + 1):
            d1[s][y] = vol * 1.04 ** min(y - 2030, 2) * 1.03 ** max(0, y - 2032)
            d2[s][y], d3[s][y], emg[s][y] = asp, 1 + oth, mg
    rows.series('S4', '收入', 'J-EV', erev26, '2026 年＝上半年实际 447.6 亿元＋下半年交付量×ASP')
    rows.series('S4', '驱动1', 'J-EV', d1)
    rows.series('S4', '驱动2', 'J-EV', d2)
    rows.series('S4', '驱动3', 'J-EV', d3)
    rows.series('S4', '经营利润率', 'J-EV', emg, '不含 AI 等新业务的成本（J-EV-SPLIT）；公司不披露汽车的成本结构，先用一个利润率')
    ev26 = erev26['基准'][2026]
    # 资本
    equity = db.bs('2026-06-30')['股东权益']
    bb = db.old_bridge_book()
    ic0 = round(equity - bb, 2)
    r26 = {k: rev[k]['基准'][2026] for k in KEYS}
    eco26 = sum(r26.values())
    w_eco = r26['phone'] + r26['aiot'] + 0.2 * r26['net']
    w_ev = WEIGHT['S4'] * ev26
    parts = {'E1': ic0 * w_eco / (w_eco + w_ev), 'S4': ic0 * w_ev / (w_eco + w_ev)}
    for c, base in (('E1', eco26), ('S4', ev26)):
        rows.static(c, '期初投入资本', round(parts[c], 2), 'J-IC')
        rows.static(c, '资本占用率', round(parts[c] / base, 4), 'J-IC')
        rows.static(c, '税率', S.TAX, 'J-VE')
    rows.static('S5', '直接估值', S.AI_VALUE['基准'], 'J-AI')
    rows.static('S5', '期初投入资本', 0, 'J-IC', 'AI 的算力与研发投入大部分已费用化，资本不单独分摊')
    for s in scen:
        g, ro = scen[s]['terminal_growth'], scen[s]['ronic']
        rows.static('E1', '永续增长率', g, 'J-MULT', scen=s)
        rows.static('E1', '终值新增投资回报率', ro, 'J-MULT', scen=s)
        rows.static('S4', '永续增长率', g, 'J-EV', scen=s)
        rows.static('S4', '终值新增投资回报率', ro, 'J-EV', '旧模型用 2030 年退出倍数（7 / 10 / 13 倍）；统一引擎改为逐年到 2035 年，再按情景的永续增长与新增投资回报率', scen=s)
    lines = []
    for i, (k, (rc, cc, name, _)) in enumerate(KEYS.items()):
        lines.append(line('E1', rc, name, '收入', '金额', sort=i + 1))
        lines.append(line('E1', cc, f'{name}·销售成本', '成本', '收入比例', base=rc, sort=11 + i, note='1−毛利率（公司按品类披露）'))
    lines.append(line('E1', 'C4', '营业费用（生态共用）', '成本', '收入比例', sort=14, note='销售、管理、研发费用（不含汽车与 AI）占生态收入；不分摊到品类'))
    judgments = [
        dict(code='J-IC', title='期初投入资本与分摊（统一估值引擎）', status='已形成建议',
             judgment=f'2026-06-30 股东权益 {equity:,.1f} 亿元，减去资产负债桥 C1—C10 的账面净额 {bb:,.1f} 亿元'
                      f'（现金储备、借款、租赁、经营所需现金、对外投资、基金外部出资人、少数股东），经营投入资本 {ic0:,.1f} 亿元。'
                      f'公司不披露分部资产，按 2026 年收入×权重分到两块：手机×AIoT 生态 {parts["E1"]:,.1f} 亿元（手机、AIoT 权重 1，互联网 0.2），'
                      f'汽车 {parts["S4"]:,.1f} 亿元（权重 2）；AI 不分资本。之后各块资本占用率不变。粗略估计，待分部资产数据替换。',
             transmission='投入资本是资产价值和 ROIC 的分母；收入增长按资本占用率占用新资本（汽车扩产的资本开支由此体现）。',
             parameter='估值假设·期初投入资本、资本占用率', change_threshold='公司披露分部资产，或汽车工厂投资计划有变化。'),
        dict(code='J-VE', title='按披露分部估值：生态一块、汽车一块（统一估值引擎）', status='已形成建议',
             judgment='公司披露两个分部：手机×AIoT、智能电动汽车及 AI 等创新业务。手机、AIoT、互联网共用用户、渠道和团队（互联网收入来自手机用户），'
                      '营业费用无法真实拆分，所以生态按一块业务估值：三条收入线各自的销售成本按披露的分品类毛利率，营业费用作为生态共用的一条成本线。'
                      '逐年收入、毛利率、费用率取 seed.py 里各情景的路径；所得税率 17%；汽车不再用 2030 年退出倍数和单独的 11% 折现率，改为逐年预测到 2035 年。',
             transmission='生态经营利润＝三条收入线−三条销售成本−营业费用。', parameter='估值假设·生态收入线与成本线、税率、汽车终值',
             change_threshold='分部披露口径变化。'),
    ]
    businesses = [dict(code='E1', name='手机×AIoT 生态（手机、AIoT、互联网服务）', kind='经营', capital_basis='企业', sort=0,
                       boundary='公司披露的“手机×AIoT”分部：智能手机、IoT 与生活消费产品、互联网服务（广告、游戏、增值服务）。三者共用用户、渠道与团队；'
                                '商业模式画布按 S1—S3 分开写，估值时是本业务的三条收入线。'),
                  dict(code='S4', driver1_label='交付量', driver1_unit='万辆', driver2_label='平均售价', driver2_unit='万元',
                       driver3_label='收入倍数（1＋其他收入比例）', driver3_unit='倍', driver_scale=1, kind='经营', capital_basis='企业')]
    businesses += [dict(code=c, kind='经营', capital_basis='企业') for c in ('S1', 'S2', 'S3', 'S5')]
    return dict(as_of='2026-06-30', businesses=businesses, lines=lines, judgments=judgments, probabilities=None, bridge=[], rows=rows.out)
