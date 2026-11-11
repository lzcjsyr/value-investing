"""腾讯音乐 → 统一估值引擎（2026-11-08；11-09 改为一块业务）：会员订阅、非订阅音乐、社交娱乐共用用户、曲库和团队，不能单独定价，
所以是一块业务的三条收入线；成本按利润表科目（营业成本、销售费用、管理费用）占全部收入的比例，不往收入线上分摊。
收入：2026、2028 年取「财务预测」，2027 年取各情景的分部收入，2029 年起按增长率；成本率：2026—2028 年取财务预测，之后不变，
悲观、乐观情景按旧分部利润率与基准的差调整营业成本率。资产负债桥沿用 C1—C9。"""
from value_engine_seed import Rows, q, PROB, line

TAX, ATTRIB = 0.175, 0.97
REV = {'R1': ('会员订阅（含长音频会员）', 'sub_rev', 'J-S1'), 'R2': ('非订阅音乐（广告、演出、周边、艺人经纪）', 'nonsub_rev', 'J-S2'),
       'R3': ('社交娱乐（直播打赏）', 'social_rev', 'J-S3')}
SEG = {'R1': 'S1', 'R2': 'S2', 'R3': 'S3'}
R3_G = {'悲观': -0.10, '基准': -0.08, '乐观': -0.05}   # 社交娱乐持续收缩（与旧倍数 5 / 6 / 7.9 倍对应的衰减速度）


def build(db):
    m = db.model['id']
    ff = {r['year']: r for r in q(f"SELECT * FROM vi_fin_forecast_base WHERE model_id = {m}")}
    seg = {(r['code'], r['scen']): r for r in q(
        f"SELECT g.code, s.name AS scen, g.revenue, g.op_margin FROM vi_sotp_segment_base g JOIN vi_scenario_base s ON s.id = g.scenario_id WHERE g.model_id = {m}")}
    scen = {s['name']: s for s in db.scenarios}
    ys = db.years
    rows = Rows(ys, db.scenarios)
    rev = {}
    for c, (name, col, j) in REV.items():
        rev[c] = {}
        for s in scen:
            base27, s27 = seg[(SEG[c], '基准')]['revenue'], seg[(SEG[c], s)]['revenue']
            g = R3_G[s] if c == 'R3' else scen[s]['terminal_growth']
            r = {2026: ff[2026][col], 2027: s27, 2028: ff[2028][col] * s27 / base27}
            for y in range(2029, ys[-1] + 1):
                r[y] = r[y - 1] * (1 + g)
            rev[c][s] = r
        rows.series('B1', '金额', j, rev[c], '2026、2028 年取财务预测（2028 年按情景对 2027 年的比例缩放），2027 年取各情景分部收入，2029 年起按增长率（J-VE）', line=c)
    # 成本率：财务预测 2026—2028 年，之后保持 2028 年；收购摊销七成加回（与旧财务模型的对账口径一致）
    fy = lambda y: ff[min(y, 2028)]
    tot = {y: sum(fy(y)[col] for _, col, _ in REV.values()) for y in ys}
    cogs = {y: 1 - fy(y)['gross_margin'] for y in ys}
    sell = {y: fy(y)['selling_ratio'] for y in ys}
    admin = {y: fy(y)['admin_ratio'] - 0.7 * fy(y)['acq_amort'] / tot[y] for y in ys}
    base_m = sum(seg[(SEG[c], '基准')]['revenue'] * seg[(SEG[c], '基准')]['op_margin'] for c in REV) / sum(seg[(SEG[c], '基准')]['revenue'] for c in REV)
    cogs_s = {}
    for s in scen:
        m_s = sum(seg[(SEG[c], s)]['revenue'] * seg[(SEG[c], s)]['op_margin'] for c in REV) / sum(seg[(SEG[c], s)]['revenue'] for c in REV)
        cogs_s[s] = {y: cogs[y] - (m_s - base_m) for y in ys}
    rows.series('B1', '比例', 'J-FIN', cogs_s, '1−毛利率（财务预测）；悲观、乐观按旧分部经营利润率加权值与基准的差调整', line='C1')
    rows.series('B1', '比例', 'J-FIN', sell, '销售及分销费用÷收入（财务预测）', line='C2')
    rows.series('B1', '比例', 'J-FIN', admin, '行政开支（含研发、股权激励）÷收入；收购摊销七成加回（财务预测）', line='C3')
    rows.static('B1', '税率', TAX, 'J-FIN')
    rows.static('B1', '归母比例', ATTRIB, 'J-FIN')
    equity = db.bs('2026-06-30')['股东权益']
    bb = db.old_bridge_book()
    ic0 = round(equity - bb, 2)
    rev26 = sum(rev[c]['基准'][2026] for c in REV)
    rows.static('B1', '期初投入资本', ic0, 'J-IC')
    rows.static('B1', '资本占用率', round(ic0 / rev26, 4), 'J-IC')
    for s in scen:
        rows.static('B1', '永续增长率', scen[s]['terminal_growth'], 'J-R', scen=s)
        rows.static('B1', '终值新增投资回报率', scen[s]['ronic'], 'J-R', scen=s)
    lines = [line('B1', c, n, '收入', '金额', sort=i + 1) for i, (c, (n, _, _)) in enumerate(REV.items())] + [
        line('B1', 'C1', '营业成本（版权、分成、带宽等）', '成本', '收入比例', sort=11, note='占全部收入；公司只披露合计毛利率'),
        line('B1', 'C2', '销售费用', '成本', '收入比例', sort=12, note='占全部收入'),
        line('B1', 'C3', '管理费用（含研发、股权激励）', '成本', '收入比例', sort=13, note='占全部收入；收购摊销七成加回')]
    judgments = [
        dict(code='J-IC', title='期初投入资本（统一估值引擎）', status='已形成建议',
             judgment=f'2026-06-30 股东权益 {equity:,.1f} 亿元，减去资产负债桥 C1—C9 的账面净额 {bb:,.1f} 亿元（现金、负债、对外投资、经营所需现金、少数股东在非经营资产中的份额），'
                      f'经营投入资本 {ic0:,.1f} 亿元（主要是收购形成的商誉约 298 亿元）。三条收入线共用这些资本，不拆分；之后资本占用率不变。',
             transmission='投入资本是资产价值和 ROIC 的分母；收入增长按资本占用率占用新资本。', parameter='估值假设·期初投入资本、资本占用率',
             change_threshold='发生大额并购，或资本占用率明显变化。'),
        dict(code='J-VE', title='三条收入线、一块业务（统一估值引擎）', status='已形成建议',
             judgment='会员订阅、非订阅音乐、社交娱乐共用用户、曲库和团队，费用无法真实拆分，公司也只披露合计毛利率，所以按一块业务估值：'
                      '收入分三条线各自预测，成本按利润表科目占全部收入的比例。2026、2028 年收入取财务预测，2027 年取各情景分部收入，'
                      '2029 年起会员与非订阅按情景永续增长率、社交娱乐每年收缩 5%—10%；成本率 2029 年起保持 2028 年水平。',
             transmission='收入线合计−营业成本−销售费用−管理费用＝经营利润。', parameter='估值假设·收入线与成本线（2026—2035）',
             change_threshold='公司披露分业务毛利，或成本结构（版权成本、分成比例）有持续变化。'),
        dict(code='J-PROB', title='情景概率 25% / 50% / 25%（待确认）', status='已形成建议',
             judgment='旧模型没有情景概率；先按悲观 25%、基准 50%、乐观 25% 给出概率加权价值。', transmission='只影响概率加权每股价值。',
             parameter='情景·情景概率', change_threshold='有证据表明某一情景的可能性明显更高或更低。'),
    ]
    biz = dict(code='B1', name='在线音乐与音频娱乐平台', kind='经营', capital_basis='企业', sort=1,
               boundary='QQ 音乐、酷狗、酷我、全民 K 歌、懒人听书等：会员订阅、非订阅音乐（广告、演出、周边、艺人经纪）、社交娱乐（直播打赏）三条收入线共用用户、曲库与团队。')
    return dict(as_of='2026-06-30', businesses=[biz], drop_businesses=['S1', 'S2', 'S3'], lines=lines, judgments=judgments,
                probabilities=PROB, bridge=[], rows=rows.out)
