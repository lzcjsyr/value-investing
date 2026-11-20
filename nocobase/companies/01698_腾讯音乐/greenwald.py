"""腾讯音乐 → Greenwald 三层估值（2026-11-11，新框架第一家）。

估值基准：2026 年第三季度官方业绩公告。金额为人民币亿元。
第一层与第四层采用同一期合并资产负债表，第二层用第三季度经营规模正常化，第三层以同一经营规模推演。
生成与执行：python3 framework/greenwald_seed.py 01698.HK
"""

from pathlib import Path

AS_OF = '2026-09-30'
Q3_REVENUE, Q3_COST, Q3_SELLING, Q3_ADMIN = 89.41, 51.18, 2.95, 12.37
Q3_TAX_RATE = 14.02 / 83.11  # 前九个月有效税率
Q3_SHARES = 31.38478643  # Q3 基本加权平均普通股数（亿股）
INTANGIBLE_HAIRCUT = 0.25
OP_CASH, WHT, INV_HAIRCUT, MINORITY = 40.0, 21.7, 0.30, 0.03

# 资产负债表科目 → (类别, 是否属于经营业务)；顺序＝报表顺序
OPERATING_ASSETS = ['物业厂房及设备', '无形资产', '商誉', '土地使用权', '递延税项资产', '预付款项', '使用权资产',
                    '存货', '应收账款', '预付款、按金及其他资产（流动）', '受限现金']
OPERATING_LIABS = ['应付账款', '应交所得税', '递延收入（流动）', '其他应付款项及其他负债（流动）', '递延税项负债', '递延收入（非流动）', '其他应付款项及其他负债（非流动）']
CASH = ['现金及现金等价物', '短期存款', '中长期存款']
INVESTMENTS = ['以公允价值计量且其变动计入其他综合收益的金融资产', '其他投资（非流动）', '按权益法核算的投资']
DEBT = ['短期借款', '长期借款', '应付票据（非流动）', '租赁负债（流动）', '租赁负债（非流动）']

# 第二层：调整后利润表（一行一个项目；formula＝报表公式，给出历年数；method/value＝正常化值怎么取）
EPV = [  # (项目, 段落, 方向, 报表公式, 取值方式, 数值, 起始年, 结束年, 依据, 说明)
    ('营业收入', '收入', None, '营业收入', '金额', Q3_REVENUE * 4, None, None, ['J-EPV'],
     '2026Q3 单季收入年化 ×4：会员 199.40＋营销及消费 107.88＋社交娱乐及其他 50.36 亿元。并表后运行水平，含季节性风险。'),
    ('营业成本（版权、分成、带宽等）', '成本费用', None, '−营业成本', '占收入比例', Q3_COST / Q3_REVENUE, None, None, ['J-EPV'],
     'Q3 营业成本 51.18 亿÷收入 89.41 亿；毛利率 42.8%，反映演出、艺人周边等业务组合变化。'),
    ('销售及分销费用', '成本费用', None, '−销售及营销费用', '占收入比例', Q3_SELLING / Q3_REVENUE, None, None, ['J-EPV'],
     'Q3 销售费用 2.95 亿÷收入 89.41 亿，约 3.30%。'),
    ('行政开支（含研发、股权激励、收购摊销）', '成本费用', None, '−一般及行政费用', '占收入比例', Q3_ADMIN / Q3_REVENUE, None, None, ['J-EPV'],
     'Q3 一般及行政费用 12.37 亿÷收入 89.41 亿，约 13.84%，包括股权激励。'),
    ('七成收购摊销', '税前调整', '加', None, '金额', 2.25 * 4 * 0.7, None, None, ['J-EPV'],
     'Q3 调节表披露收购摊销 2.25 亿元。按单季年化并暂加回 70%，余下 30% 作为持续成本。比例为估算。'),
    ('所得税', '所得税', None, '−所得税费用', '比率', Q3_TAX_RATE, None, None, ['J-EPV'], '前三季度所得税 14.02 亿÷税前利润 83.11 亿，约 16.9%。'),
    ('折旧摊销（不含已加回的收购摊销）', '税后调整', '加', '现金流量表：折旧及摊销（现金流附注）', '金额', (0.53 + 4.63 - 2.25 * 0.7) * 4, None, None, ['J-MCAP'],
     'Q3 折旧 0.53 亿＋无形资产摊销 4.63 亿，减税前已加回的收购摊销，再乘 4，约 14.34 亿。'),
    ('维持性资本开支', '税后调整', '减', '−购置物业厂房及设备 − 购置无形资产 − 购置土地使用权', '历史平均', None, 2022, 2025, ['J-MCAP'],
     'Q3 公告仅列投资现金流净额。维持性资本开支暂用 2022—2025 年均值 11.1 亿作代理。'),
    ('少数股东', '少数股东', None, '非控股权益应占净利润', '比率', 0.03, None, None, ['J-MINOR'], 'Q3 少数股东损益 0.65 亿÷净利润 22.19 亿，取整 3%'),
    ('其他收入（利息收入为主）', '不计入', None, '利息收入', None, None, None, None, [],
     '不计入：产生利息的现金在资产负债桥里单独计价，再计利息就重复了'),
    ('其他收益（投资收益、公允价值变动、一次性项目）', '不计入', None, '其他利得及损失净额', None, None, None, None, [],
     '不计入：对外投资在资产负债桥里按七折单独计价；2025 年 26.3 亿元里大部分是一次性收益'),
    ('应占联营公司溢利', '不计入', None, '应占权益法投资净损益', None, None, None, None, [], '不计入：权益法投资在资产负债桥里单独计价'),
    ('融资成本', '不计入', None, '−财务费用', None, None, None, None, [], '不计入：有息负债在资产负债桥里扣除，利息不再进经营利润'),
]
GROWTH = dict(growth=0.025, ronic=0.15, adv_years=10)
# 估值时点及未单独披露的输入
NOTES = ('2026Q3 官方业绩公告为资产负债及经营数据基准。每股价值用 Q3 基本加权平均普通股数 31.38 亿股作分母代理。'
         'Q3 公告未拆出投资应付款、当期汇出税估算或维持性资本开支，相关估值假设见各行。每股均为普通股口径，1 ADS 对应 2 股。')


def build(db):
    bs = db.bs(AS_OF)
    cash = sum(bs[i] for i in CASH) + bs['其他投资（流动）']
    debt = sum(bs[i] for i in DEBT)
    inv = sum(bs[i] for i in INVESTMENTS)
    nonop = cash - OP_CASH - debt - WHT + inv * (1 - INV_HAIRCUT)
    minority_nonop = round(MINORITY * nonop, 2)
    goodwill = bs['商誉']
    # 账面经营资本：经营资产＋划入的经营所需现金 − 经营负债
    op_book = sum(bs[i] for i in OPERATING_ASSETS) + OP_CASH - sum(bs[i] for i in OPERATING_LIABS)
    intangibles = bs['无形资产']
    intangible_discount = intangibles * INTANGIBLE_HAIRCUT
    av = op_book - goodwill - intangible_discount
    stmt_book = sum(bs[i] for i in OPERATING_ASSETS) - sum(bs[i] for i in OPERATING_LIABS)   # 报表口径（ROIC 的分母）
    nopat = (Q3_REVENUE - Q3_COST - Q3_SELLING - Q3_ADMIN + 2.25 * 0.7) * 4 * (1 - Q3_TAX_RATE)     # 只用于依据里的 ROIC 说明

    items = []
    add = lambda **k: items.append(k)
    for i in OPERATING_ASSETS:
        if i == '商誉':
            add(category='经营资产', line_item=i, haircut=1.0, judgments=['J-AV'],
                basis=f'收购酷狗、酷我、懒人听书、喜马拉雅等形成的商誉 {goodwill:,.2f} 亿元。计入账面经营资本（ROIC 的分母，反映股东实际投入），'
                      '但不计入资产价值：它是收购溢价，不能单独变现，新进入者也不靠这笔钱重建业务（见 J-AV）。')
        elif i == '无形资产':
            add(category='经营资产', line_item=i, haircut=INTANGIBLE_HAIRCUT, judgments=['J-AV'],
                basis='按账面 75% 暂计，折价 25% 是估值假设。'
                      '2026Q3 披露期末 55.50 亿，较中报 58.95 亿减少 3.45 亿。中报附注 13 披露上半年企业合并新增 33.99 亿。'
                      '2025 年报附注 15 的期初参照：版权 16.89 亿，域名、商标及牌照 4.30 亿，竞业协议 0.78 亿，企业客户关系 0.22 亿，供应商资源 0.01 亿，其他 6.79 亿。'
                      'Q3 未披露期末分类余额。版权与牌照的重置成本取决于剩余期限、授权范围和续约条件；客户关系与竞业协议取决于存量客户留存及合同有效期。'
                      '基准折价用于反映这些估值不确定性。可按 0%、25%、50% 折价比较，待取得分类余额及合同资料后逐项重估。')
        else:
            add(category='经营资产', line_item=i)
    add(category='经营资产', name='经营所需现金（从现金划入）', adjustment=OP_CASH, judgments=['J-OPCASH'],
        basis='周转金估算：22＋10＋8≈40 亿元，取整为 40 亿元。① 日常付款：Q3 营业成本与经营费用合计 66.50 亿元，月均约 22 亿元，用作月度付款规模代理（含非现金费用）。② 季节性周转：估计剔除应付股息后，2025 年一至二季度浮存金回落约 11 亿元，取 10 亿元。③ 压力缓冲：假设收入下降 10%，按Q3 收入年化约 358 亿元×10%×历史浮存金占收入比例约 22%，需约 8 亿元。若收入下降 20%，总需求约 48 亿元。来源：工作台假设 J-OPCASH。')
    for i in OPERATING_LIABS:
        add(category='经营负债', line_item=i,
            basis='Q3 公告未单列投资应付款，整项暂留第一层。中报 4.10 亿元作为历史参照。'
            if i == '其他应付款项及其他负债（流动）' else None)
    for i in CASH:
        add(category='现金与投资', line_item=i,
            basis='现金及等价物、定期存款与短期投资：可以单独计价的现金。' if i == '现金及现金等价物' else None)
    add(category='现金与投资', line_item='其他投资（流动）',
        basis='原财报单列的流动投资，归入第四层，按账面值计。')
    add(category='现金与投资', name='划给经营的周转现金', adjustment=-OP_CASH, judgments=['J-OPCASH'],
        basis='与经营资产里的“经营所需现金”对应：这 40 亿元留在业务里周转，不能分给股东。')
    for i in INVESTMENTS:
        add(category='现金与投资', line_item=i, haircut=INV_HAIRCUT, judgments=['J-INV'],
            basis=('对外上市股权（Spotify、UMG、WMG 等，公允价值）' if i.startswith('以公允价值') else i)
                  + '；按最新报告账面价值打七折（控股折价、处置税费与流动性），见 J-INV。')
    for i in DEBT:
        add(category='有息负债', line_item=i)
    add(category='其他索取权', name='境内资金汇出预提税（10%）', adjustment=WHT, judgments=['J-CASH'],
        basis='Q3 未披露更新的境内未分派利润。暂沿用中报时点估算 21.70 亿，作为第四层汇出税压力扣减。')
    add(category='其他索取权', line_item='非控股权益', adjustment=round(minority_nonop - bs['非控股权益'], 2), judgments=['J-MINOR'],
        basis=f'只扣少数股东在非经营净资产中的 3%：{nonop:,.1f}×3%＝{minority_nonop:.2f} 亿元；账面少数股东权益 {bs["非控股权益"]:.2f} 亿元的其余部分'
              '在经营里，已由归母比例 97% 扣过（J-MINOR）。')

    epv = [dict(business='B1', sort=i, name=n, section=sec, direction=d, formula=f, method=m, value=v, from_year=a, to_year=b, judgments=j, note=note)
           for i, (n, sec, d, f, m, v, a, b, j, note) in enumerate(EPV, 1)]
    growth = [dict(business='B1', **GROWTH, judgments=[], note='十年低速增长，之后增长不再创造价值')]

    judgments = [
        dict(code='J-LAYER', title='主估值层：盈利能力价值（Greenwald 三层）', status='已形成建议',
             judgment='腾讯音乐是轻资产平台：调整后的经营资产约 '
                      f'{av:,.0f} 亿元，账面调整结果对无形资产和维持经营的现金假设敏感。增长能创造多少价值取决于优势能维持多久，'
                      '而汽水音乐的免费模式（T3 观察）与多元变现（T4 存疑）都还没有定论。按 Greenwald 的顺序，以不增长的盈利能力价值作结论，'
                      '增长价值只作为不付钱的上行空间：市价低于盈利能力价值时，买入不需要相信增长。',
             transmission='每股价值与隐含回报都按盈利能力价值计算；资产价值、含增长价值在总览里并列展示，用于交叉检验。',
             parameter='公司·主估值层',
             change_threshold='T3、T4 有了定论（付费用户与利润率在汽水音乐冲击下守住两年以上），可以改用含增长价值；利润率持续跌破 25% 时重新审视盈利能力本身。',
             no_change_condition='单季利润率波动、短期股价变化。'),
        dict(code='J-CASH', title='Q3 独立现金、债务及汇出税', status='已形成建议',
             judgment=f'Q3 现金、存款及流动投资 {cash:.2f} 亿，扣经营周转 {OP_CASH:.2f} 亿、融资和租赁负债 {debt:.2f} 亿及暂估汇出税 {WHT:.2f} 亿。'
                      'Q3 未单列投资应付款，保留在报表原科目内。汇出税沿用最近一次估算。',
             transmission='第四层按 Q3 账面余额重算，与第一层使用同一期报表。',
             change_threshold='收到境内未分派利润或投资应付款的新披露后复核。'),
        dict(code='J-OPCASH', title='Q3 经营周转金暂估 40 亿元', status='已形成建议',
             judgment='一个月付款规模代理约 22 亿，加历史季节性波动缓冲约 10 亿及收入下降压力缓冲约 8 亿。按 Q3 营业成本与经营费用合计 66.50 亿估一个月规模，包含非现金费用。',
             transmission='40 亿元从第四层现金池划入第一层。', change_threshold='取得更细的月度付款和营运资金数据后复核。'),
        dict(code='J-INV', title='Q3 非经营投资按账面七折', status='已形成建议',
             judgment=f'Q3 公允价值计量权益投资、权益法投资及其他非流动投资合计 {inv:.2f} 亿，按账面七折计 {inv * (1 - INV_HAIRCUT):.2f} 亿。'
                      '30% 为处置税费、流动性与估值波动的合并估值假设。',
             transmission='折后金额进入第四层。', change_threshold='持仓结构、可变现性或税费变化后复核。'),
        dict(code='J-AV', title='资产价值：调整后的净经营资产（商誉不计入）', status='已形成建议',
             judgment=f'全公司口径（经营负债拆不到业务，不分业务估）。{AS_OF} 报表口径的经营资本 {stmt_book:,.1f} 亿元（经营资产 − 经营负债），加上划入的经营所需现金 {OP_CASH:.0f} 亿元，'
                      f'合计 {op_book:,.1f} 亿元，其中商誉 {goodwill:,.1f} 亿元。Q3 未单列投资应付款，整项其他应付款暂留经营。'
                      '商誉不计入资产价值：它是收购溢价，不能单独变现，重建这门生意靠的是版权合作、用户与产品，不是这笔商誉。'
                      f'可辨认无形资产 {intangibles:,.2f} 亿元暂按账面 {1 - INTANGIBLE_HAIRCUT:.0%} 计入，折减 {intangible_discount:,.2f} 亿元。Q3 未披露期末分类余额，折价是估值假设。'
                      f'调整后资产价值约 {av:,.1f} 亿元。会员预收（递延收入）与应付版权费大于应收与存货，主营几乎不占营运资金。',
             transmission=f'资产价值只用于第一层：与盈利能力价值比较时需考虑未入账的重建投入（基准 ROIC 约 {nopat / stmt_book * 100:.0f}%，税后经营利润÷报表口径经营资本）；不进主估值。',
             parameter='公司·资产价值口径；资产负债重估·商誉折价 100%、无形资产折价 25%',
             change_threshold='大额并购或商誉减值；可辨认无形资产的构成披露变化。', theses=['T1']),
        dict(code='J-EPV', title='调整后利润表：正常化收入、成本费用、收购摊销加回与税率', status='已形成建议',
             judgment='用 Q3 单季收入 89.41 亿年化至 357.64 亿，营业成本、销售、行政费用率取 Q3 实绩。'
                      '剔除利息及一次性收益，收购摊销按当季披露额年化后加回七成；所得税率取前三季约 16.9%。'
                      '单季年化反映并表后的业务规模，演出、周边和订阅季节性仍会影响结果。',
             transmission='费用率或毛利率每变动 1 个百分点，税前经营利润约变动 3.58 亿。',
             parameter='调整后利润表·收入、营业成本、销售费用、行政开支、收购摊销加回、所得税',
             change_threshold='年报核心经营利润率偏离 2 个百分点以上并持续两个季度；会员收入同比转负（剔除喜马拉雅）。',
             no_change_condition='单季利润率在 28%—31% 之间波动。', theses=['T1', 'T3', 'T6']),
        dict(code='J-MCAP', title='折旧摊销按 Q3 年化，维持性资本开支用历史代理', status='已形成建议',
             judgment='Q3 折旧与无形摊销合计 5.16 亿，扣掉已税前加回的 1.575 亿后年化约 14.34 亿。'
                      'Q3 公告仅列投资活动净现金流，维持性资本开支暂取 2022—2025 年均值 11.1 亿。',
             transmission='维持性资本开支每增加 1 亿，正常化盈利约减少 1 亿。',
             parameter='调整后利润表·折旧摊销、维持性资本开支',
             change_threshold='资本开支连续两年超过 15 亿元（如自建数据中心、AI 算力），或年报披露收购摊销的拆分（Q04）。'),
        dict(code='J-MINOR', title='少数股东 3%：经营部分乘 97%，非经营部分在桥里扣', status='已形成建议',
             judgment=f'Q3 少数股东损益 0.65 亿÷净利润 22.19 亿，取整 3%（J-FIN）。经营部分：调整后利润表最后扣 3%，资产价值也乘 97%；非经营部分：资产负债桥只扣少数股东在'
                      f'非经营净资产（现金扣经营所需与有息负债、汇出预提税，对外投资折后，约 {nonop:,.1f} 亿元）中的 3%，即 {minority_nonop:.2f} 亿元。'
                      f'账面少数股东权益 {bs["非控股权益"]:.2f} 亿元不全额扣：其余部分在经营资产里，已经被 97% 扣过，全额再扣就重复了。',
             transmission='少数股东比例每 ±1 个百分点，每股盈利能力价值约 ∓0.5 元。',
             parameter='调整后利润表·少数股东；资产负债重估·少数股东权益',
             change_threshold='少数股东损益占比变化超过 1 个百分点（如喜马拉雅少数股东结构变化）。'),
    ]
    company = dict(as_of=AS_OF, shares=Q3_SHARES, value_layer='盈利能力价值', av_basis='调整后净资产', repro_cost=None, notes=NOTES,
                   layer_reason='轻资产平台，资产价值说明不了价值；增长取决于优势能维持多久（T3、T4 未定），先以不增长的盈利能力价值作结论，增长只作参照。见 J-LAYER。')
    biz = dict(code='B1', name='在线音乐与音频娱乐平台', boundary='QQ 音乐、酷狗、酷我、全民 K 歌、懒人听书等：会员订阅、非订阅音乐（广告、演出、周边、艺人经纪）、社交娱乐（直播打赏）三条收入线共用用户、曲库与团队。',
               asset_boundary=None, sort=1,
               capital_basis='企业')
    return dict(company=company, businesses=[biz], judgments=judgments, drop_judgments=['J-IC', 'J-VE', 'J-PROB'],
                bs_items=items, epv=epv, growth=growth,
                supplement=Path(__file__).with_name('growth_review.sql').read_text())
