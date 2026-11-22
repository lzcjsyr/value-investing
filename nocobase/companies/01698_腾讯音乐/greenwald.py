"""腾讯音乐 → Greenwald 三层估值（2026-11-11，新框架第一家）。

估值基准：2026 年第三季度官方业绩公告。金额为人民币亿元。
第一层与第四层采用同一期合并资产负债表；第二层遵循 Greenwald 盈利能力价值（EPV）方法，
以官方功能法利润表为主干，剔除非经营与一次性项、平滑季节性、审慎处理收购摊销与维持性资本开支；
第三层以同一经营规模推演。
生成与执行：python3 framework/greenwald_seed.py 01698.HK
"""

from pathlib import Path

AS_OF = '2026-09-30'
Q3_REVENUE, Q3_COST, Q3_SELLING, Q3_ADMIN = 89.41, 51.18, 2.95, 12.37
Q3_TAX_RATE = 14.02 / 83.11  # 前九个月有效税率（剔除 2025 年一次性投资收益对税率的扭曲）
Q3_SHARES = 31.38478643  # Q3 基本加权平均普通股数（亿股）
INTANGIBLE_HAIRCUT = 0.20
OP_CASH, WHT, INV_HAIRCUT, MINORITY = 40.0, 21.7, 0.20, 0.03

# 资产负债表科目 → (类别, 是否属于经营业务)；顺序＝报表顺序
OPERATING_ASSETS = ['物业厂房及设备', '无形资产', '商誉', '土地使用权', '递延税项资产', '预付款项', '使用权资产',
                    '存货', '应收账款', '预付款、按金及其他资产（流动）', '受限现金']
OPERATING_LIABS = ['应付账款', '应交所得税', '递延收入（流动）', '其他应付款项及其他负债（流动）', '递延税项负债', '递延收入（非流动）', '其他应付款项及其他负债（非流动）']
CASH = ['现金及现金等价物', '短期存款', '中长期存款']
INVESTMENTS = ['以公允价值计量且其变动计入其他综合收益的金融资产', '其他投资（非流动）', '按权益法核算的投资', '其他投资（流动）']
DEBT = ['短期借款', '长期借款', '应付票据（非流动）', '租赁负债（流动）', '租赁负债（非流动）']

# 第二层（Greenwald EPV）：
# 1) 收入按三条经济特征截然不同的业务线正常化：
#    - 会员服务：月度续费、季节性弱，2026Q3 为喜马拉雅完整并表首季，按 Q3 实际 49.85 × 4 = 199.40 亿（不臆造已停披的付费用户×ARPPU）；
#    - 营销及消费服务：广告与线下演出存在显著季节性（Q1 淡季、Q2/Q3 演出旺季），采用滚动四季度（TTM 2026Q3 = 99.30 亿）平滑单季波动；
#    - 社交娱乐及其他：结构性收缩（同比 -15.7%），保守取下滑后的最新单季运行水平 Q3 12.59 × 4 = 50.36 亿（低于 TTM 55.10 亿）。
# 2) 成本费用回归官方功能法主表（营业成本 / 销售及营销费用 / 一般及行政费用），与 2021—2025 历史及 TTM 100% 连续可比，
#    直接呈现毛利率（M1 护城河核心指标）与核心经营利润率，杜绝跨期拼凑附注造成的 84 亿黑箱差额；
#    比率取 2026Q3 完整并表后实绩（毛利率 42.8%、核心经营利润率 25.6%），低于 2025 顶点（29.4%），避免资本化周期高点。
# 3) 税前调整：仅加回七成非消耗性收购摊销（6.30 亿）；股权激励（SBC）作为真实成本不加回；增长性营销/研发加回保守取 0。
# 4) 税后调整：无增长稳态下，剔除已加回收购摊销后的经营性折旧摊销（14.34 亿）需由维持性资本开支重置，两者配平（净额 0），
#    纠正“并表后 Q3 折旧 14.34 − 并表前 22—25 均值 11.09（且含一次性总部购地款）”造成的 +3.25 亿/年（+52.5 亿 EPV）虚增。
Q3_MEMBERSHIP, Q3_MARKETING, Q3_SOCIAL = 49.85, 26.97, 12.59
TTM_MARKETING = 99.30  # 25Q4(24.74) + 26Q1(19.46) + 26Q2(28.13) + 26Q3(26.97)，用于判断说明；表中由 method='滚动四季度' 实时计算
NORMAL_MEMBERSHIP = Q3_MEMBERSHIP * 4
NORMAL_SOCIAL = Q3_SOCIAL * 4
NORMAL_REVENUE_EST = NORMAL_MEMBERSHIP + TTM_MARKETING + NORMAL_SOCIAL

COST_RATIO = Q3_COST / Q3_REVENUE          # 57.24%（对应毛利率 42.76%）
SELLING_RATIO = Q3_SELLING / Q3_REVENUE    # 3.30%
ADMIN_RATIO = Q3_ADMIN / Q3_REVENUE        # 13.84%
ACQUISITION_AMORTIZATION_ADD_BACK = 2.25 * 4 * 0.7  # 6.30 亿（Q3 收购摊销 2.25 亿年化 × 70%）
OPERATING_DA = round((0.53 + 4.63 - 2.25 * 0.7) * 4, 2)  # 14.34 亿（并表后经营折旧摊销）
MAINT_CAPEX = OPERATING_DA  # 14.34 亿（无增长稳态重置投入，与经营折旧摊销配平）

EPV = [  # (项目, 段落, 方向, 报表公式, 取值方式, 数值, 起始年, 结束年, 依据, 说明)
    ('会员服务', '收入', None, '会员及订阅收入（附注）', '金额', NORMAL_MEMBERSHIP, None, None, ['J-EPV-MEMBER'],
     f'2026Q3 官方披露 {Q3_MEMBERSHIP:.2f} 亿元 × 4 ＝ {NORMAL_MEMBERSHIP:.2f} 亿元。'
     '会员按月续费、季节性弱，Q3 为喜马拉雅完整并表首季，直接作为无增长运行基线。'
     '公司自 2026Q1 起停披季度付费用户与 ARPPU（2025Q4 历史参照：1.274 亿付费用户、ARPPU 11.9 元），此处不臆造未披露参数。'
     '2025 年采用公司同口径比较数；2024 年及以前采用原音乐订阅口径。'),
    ('营销及消费服务', '收入', None, '营销及消费服务收入', '滚动四季度', None, None, None, ['J-EPV-ADS', 'J-EPV-IP'],
     f'采用近四季滚动合计（TTM 2026Q3 ＝ {TTM_MARKETING:.2f} 亿元），而非 Q3 单季年化（{Q3_MARKETING * 4:.2f} 亿元）。'
     '该板块含广告、线下演出与艺人周边，季节性显著（2025Q1 仅 15.20 亿，Q2—Q4 约 24—25 亿；2026Q3 亦受汪苏泷巡演拉动）。'
     '按 Greenwald 平滑周期与季节性原则，取完整四季滚动口径避免把旺季单季资本化。2024 年及以前采用在线音乐减订阅作历史参照。'),
    ('社交娱乐及其他', '收入', None, '社交娱乐服务及其他收入', '金额', NORMAL_SOCIAL, None, None, ['J-EPV-SOCIAL'],
     f'2026Q3 官方披露 {Q3_SOCIAL:.2f} 亿元 × 4 ＝ {NORMAL_SOCIAL:.2f} 亿元（同比 −15.7%）。'
     '直播打赏处于结构性收缩期，故意取低于近四季（55.10 亿元）的最新运行底作无增长基线，不假定回升。'),
    ('营业成本（版权、分成、演出与带宽）', '成本费用', None, '−营业成本', '占收入比例', COST_RATIO, None, None, ['J-EPV-COST'],
     f'取 2026Q3 完整并表后实绩：{Q3_COST:.2f} ÷ {Q3_REVENUE:.2f} ＝ {COST_RATIO:.2%}（对应毛利率 {1 - COST_RATIO:.1%}）。'
     '低于 2025 全年毛利率顶点（44.2%）与近四季（44.1%），已主动反映演出/周边低毛利占比上升及喜马拉雅长音频并表效应，'
     '避免把利润率高点当常态。2023—2026H1 附注按性质拆分见页面「成本性质透视」标签。'),
    ('销售及营销费用', '成本费用', None, '−销售及营销费用', '占收入比例', SELLING_RATIO, None, None, ['J-EPV-COST'],
     f'取 2026Q3 实绩：{Q3_SELLING:.2f} ÷ {Q3_REVENUE:.2f} ＝ {SELLING_RATIO:.2%}（高于 2025 年低点 2.86%）。'
     '已计入应对汽水音乐竞争的防守投放；依托腾讯生态仍显著低于网易云音乐（约 7.5%）。'
     '按 Greenwald 审慎原则，不假设零增长时销售费用还能继续压缩（增长性营销加回取 0）。'),
    ('一般及行政费用（含研发、股权激励与收购摊销）', '成本费用', None, '−一般及行政费用', '占收入比例', ADMIN_RATIO, None, None, ['J-EPV-COST'],
     f'取 2026Q3 完整并表后实绩：{Q3_ADMIN:.2f} ÷ {Q3_REVENUE:.2f} ＝ {ADMIN_RATIO:.2%}（高于 2025 年的 11.90%）。'
     '已全额计入喜马拉雅并表后的团队薪酬、研发投入、收购无形资产摊销及股权激励（SBC 约 7 亿元/年，属真实股东成本，绝不加回）。'
     '研发主要用于维持曲库分发与应对 AI/短视频竞争，增长性研发加回保守取 0。'),
    ('七成收购摊销（非消耗性 PPA）', '税前调整', '加', None, '金额', ACQUISITION_AMORTIZATION_ADD_BACK, None, None, ['J-EPV'],
     '2026Q3 Non-IFRS 调节表披露收购无形资产摊销 2.25 亿元（年化 9.00 亿元）。'
     '按 Greenwald 经济实质区分：70%（6.30 亿元）对应商标、用户关系、技术等历史并购溢价分摊，维持现有业务无需重复购买，予以加回；'
     '余下 30%（2.70 亿元）对应并购取得的版权公允价值调整，合约到期需按市价续约，保留为真实经营成本。'
     '注：卖方 Non-IFRS 额外加回了约 7 亿元股权激励（SBC），本模型严格遵循 Greenwald 口径不予加回。'),
    ('所得税', '所得税', None, '−所得税费用', '比率', Q3_TAX_RATE, None, None, ['J-EPV'],
     f'取 2026 年前三季度有效税率：14.02 ÷ 83.11 ＝ {Q3_TAX_RATE:.2%}。'
     '2025 年表观税率（14.5%）因 23.7 亿元免税/低税一次性投资收益被压低，2026 前三季度非经营利得较小（3.91 亿元），更能代表常态经营税负。'),
    ('经营性折旧与摊销（剔除已加回的七成收购摊销）', '税后调整', '加', '现金流量表：折旧及摊销（现金流附注）', '金额', OPERATING_DA, None, None, ['J-MCAP'],
     f'Q3 物业设备折旧 0.53 亿 ＋ 无形资产摊销 4.63 亿 − 税前已加回的七成收购摊销 1.575 亿 ＝ 3.585 亿 × 4 ＝ {OPERATING_DA:.2f} 亿元。'
     '包含并表后的设备折旧、正常经营版权/软件摊销，以及未加回的三成并购版权摊销。'),
    ('维持性资本开支（无增长稳态重置投入）', '税后调整', '减', '−购置物业厂房及设备 − 购置无形资产', '金额', MAINT_CAPEX, None, None, ['J-MCAP'],
     f'无增长稳态下，按 Greenwald 原则令维持性资本开支与并表后经营性折旧摊销配平（{MAINT_CAPEX:.2f} 亿元，净影响 0.00 亿元）。'
     '历史对照：2024—2025 年剔除一次性总部土地购置款后，经营资本开支为 10.32、11.88 亿元，与同期折旧摊销（9.78、13.75 亿元）基本 1:1 匹配。'
     '喜马拉雅并表后无形资产由 29.0 亿增至 55.5 亿、经营折旧摊销升至 14.34 亿；若错误沿用并表前 2022—2025 均值（11.09 亿）扣除，'
     '会凭空产生 +3.25 亿/年（折合 +52.5 亿元 EPV）的永续折旧虚增，违背无增长稳态资产不能折旧归零的经济学约束。'),
    ('少数股东', '少数股东', None, '非控股权益应占净利润', '比率', MINORITY, None, None, ['J-MINOR'],
     'Q3 少数股东损益 0.65 亿 ÷ 净利润 22.19 亿 ＝ 2.93%，取整 3.0%。与第一层归母比例（97%）和第四层非经营少数股东份额（3%）口径严格闭环，不重复扣减。'),
    ('其他收入（利息收入为主）', '不计入', None, '利息收入', None, None, None, None, [],
     '不计入：产生利息的广义现金与定期存款已在「④ 独立资产」单独计价，若同时保留利息收入会重复计算。'),
    ('其他收益（投资收益、公允价值变动、一次性项目）', '不计入', None, '其他利得及损失净额', None, None, None, None, [],
     '不计入：对外股权投资已在「④ 独立资产」按折后账面值单独计价；且 2025 年 26.32 亿元中含 23.7 亿元一次性分派收益，不具备可持续性。'),
    ('应占联营公司溢利', '不计入', None, '应占权益法投资净损益', None, None, None, None, [],
     '不计入：权益法投资已在「④ 独立资产」单独计价，对应损益须从经营利润中彻底剥离。'),
    ('融资成本', '不计入', None, '−财务费用', None, None, None, None, [],
     '不计入：本业务采用企业口径，全部有息借款、应付票据与租赁负债已在「④ 独立资产」全额扣除，融资利息不再进入经营利润。'),
]
# 前三年、第四年起的收入增速和研究分摊经营利润率。后者在估值时与第二层校准。
GROWTH = dict(ronic=0.15, adv_years=10, revenue_plan='''[
  {"name":"会员服务","early":0.02,"late":0.02,"margin":0.42},
  {"name":"营销及消费服务","early":0.10,"late":0.06,"margin":0.15},
  {"name":"社交娱乐及其他","early":-0.08,"late":-0.08,"margin":0.16}
]''')
# 估值时点及未单独披露的输入
NOTES = ('2026Q3 官方业绩公告为资产负债及经营数据基准。每股价值用 Q3 基本加权平均普通股数 31.38 亿股作分母代理。'
         'Q3 公告未拆出投资应付款、当期汇出税估算或维持性资本开支，相关估值假设见各行。每股均为普通股口径，1 ADS 对应 2 股。')


def build(db):
    bs = db.bs(AS_OF)
    cash = sum(bs[i] for i in CASH)
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
    core_opm = 1 - COST_RATIO - SELLING_RATIO - ADMIN_RATIO
    nopat = (NORMAL_REVENUE_EST * core_opm + ACQUISITION_AMORTIZATION_ADD_BACK) * (1 - Q3_TAX_RATE)  # 与第二层 NOPAT 一致

    items = []
    add = lambda **k: items.append(k)
    for i in OPERATING_ASSETS:
        if i == '商誉':
            add(category='经营资产', line_item=i, haircut=1.0, judgments=['J-AV'],
                basis=f'收购酷狗、酷我、懒人听书、喜马拉雅等形成的商誉 {goodwill:,.2f} 亿元。计入账面经营资本（ROIC 的分母，反映股东实际投入），'
                      '但不计入资产价值：它是收购溢价，不能单独变现，新进入者也不靠这笔钱重建业务（见 J-AV）。')
        elif i == '无形资产':
            add(category='经营资产', line_item=i, haircut=INTANGIBLE_HAIRCUT, judgments=['J-AV'],
                basis=f'按账面 {1 - INTANGIBLE_HAIRCUT:.0%} 暂计，折价 {INTANGIBLE_HAIRCUT:.0%} 是估值假设。'
                      '2026Q3 披露期末 55.50 亿，较中报 58.95 亿减少 3.45 亿。中报附注 13 披露上半年企业合并新增 33.99 亿。'
                      '2025 年报附注 15 的期初参照：版权 16.89 亿，域名、商标及牌照 4.30 亿，竞业协议 0.78 亿，企业客户关系 0.22 亿，供应商资源 0.01 亿，其他 6.79 亿。'
                      'Q3 未披露期末分类余额。版权与牌照的重置成本取决于剩余期限、授权范围和续约条件；客户关系与竞业协议取决于存量客户留存及合同有效期。'
                      f'可按 0%、{INTANGIBLE_HAIRCUT:.0%}、50% 折价比较，待取得分类余额及合同资料后逐项重估。')
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
    add(category='现金与投资', name='划给经营的周转现金', adjustment=-OP_CASH, judgments=['J-OPCASH'],
        basis='与经营资产里的“经营所需现金”对应：这 40 亿元留在业务里周转，不能分给股东。')
    for i in INVESTMENTS:
        add(category='现金与投资', line_item=i, haircut=INV_HAIRCUT, judgments=['J-INV'],
            basis=('对外上市股权（Spotify、UMG、WMG 等，公允价值）' if i.startswith('以公允价值') else i)
                  + f'；按最新报告账面价值的 {1 - INV_HAIRCUT:.0%} 计入④，见 J-INV。')
    for i in DEBT:
        add(category='有息负债', line_item=i)
    add(category='其他索取权', name='境内资金汇出预提税（10%）', adjustment=WHT, judgments=['J-CASH'],
        basis='Q3 未披露更新的境内未分派利润。暂沿用中报时点估算 21.70 亿，作为第四层汇出税压力扣减。')
    add(category='其他索取权', line_item='非控股权益', adjustment=round(minority_nonop - bs['非控股权益'], 2), judgments=['J-MINOR'],
        basis=f'只扣少数股东在非经营净资产中的 3%：{nonop:,.1f}×3%＝{minority_nonop:.2f} 亿元；账面少数股东权益 {bs["非控股权益"]:.2f} 亿元的其余部分'
              '在经营里，已由归母比例 97% 扣过（J-MINOR）。')

    epv = [dict(business='B1', sort=i, name=n, section=sec, direction=d, formula=f, method=m, value=v, from_year=a, to_year=b, judgments=j, note=note)
           for i, (n, sec, d, f, m, v, a, b, j, note) in enumerate(EPV, 1)]
    growth = [dict(business='B1', **GROWTH, judgments=[], note='逐年汇总分项收入与利润，扣除增长投入；优势期末按届时盈利资本化')]

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
             judgment=f'Q3 现金及存款 {cash:.2f} 亿，扣经营周转 {OP_CASH:.2f} 亿、融资和租赁负债 {debt:.2f} 亿及暂估汇出税 {WHT:.2f} 亿。'
                      'Q3 未单列投资应付款，保留在报表原科目内。汇出税沿用最近一次估算。',
             transmission='第四层按 Q3 账面余额重算，与第一层使用同一期报表。',
             change_threshold='收到境内未分派利润或投资应付款的新披露后复核。'),
        dict(code='J-OPCASH', title='Q3 经营周转金暂估 40 亿元', status='已形成建议',
             judgment='一个月付款规模代理约 22 亿，加历史季节性波动缓冲约 10 亿及收入下降压力缓冲约 8 亿。按 Q3 营业成本与经营费用合计 66.50 亿估一个月规模，包含非现金费用。',
             transmission='40 亿元从第四层现金池划入第一层。', change_threshold='取得更细的月度付款和营运资金数据后复核。'),
        dict(code='J-INV', title=f'Q3 投资统一按账面 {1 - INV_HAIRCUT:.0%} 计入', status='已形成建议',
             judgment=f'Q3 公允价值计量权益投资、权益法投资及其他流动与非流动投资合计 {inv:.2f} 亿，按账面 {1 - INV_HAIRCUT:.0%} 计 {inv * (1 - INV_HAIRCUT):.2f} 亿。'
                      f'{INV_HAIRCUT:.0%} 为处置税费、流动性与估值波动的合并估值假设。',
             transmission='折后金额进入第四层。', change_threshold='持仓结构、可变现性或税费变化后复核。'),
        dict(code='J-AV', title='资产价值：调整后的净经营资产（商誉不计入）', status='已形成建议',
             judgment=f'全公司口径（经营负债拆不到业务，不分业务估）。{AS_OF} 报表口径的经营资本 {stmt_book:,.1f} 亿元（经营资产 − 经营负债），加上划入的经营所需现金 {OP_CASH:.0f} 亿元，'
                      f'合计 {op_book:,.1f} 亿元，其中商誉 {goodwill:,.1f} 亿元。Q3 未单列投资应付款，整项其他应付款暂留经营。'
                      '商誉不计入资产价值：它是收购溢价，不能单独变现，重建这门生意靠的是版权合作、用户与产品，不是这笔商誉。'
                      f'可辨认无形资产 {intangibles:,.2f} 亿元暂按账面 {1 - INTANGIBLE_HAIRCUT:.0%} 计入，折减 {intangible_discount:,.2f} 亿元。Q3 未披露期末分类余额，折价是估值假设。'
                      f'调整后资产价值约 {av:,.1f} 亿元。会员预收（递延收入）与应付版权费大于应收与存货，主营几乎不占营运资金。',
             transmission=f'资产价值只用于第一层：与盈利能力价值比较时需考虑未入账的重建投入（含商誉基准 ROIC 约 {nopat / stmt_book * 100:.0f}%，税后经营利润÷报表口径经营资本）；不进主估值。',
             parameter=f'公司·资产价值口径；资产负债重估·商誉折价 100%、无形资产折价 {INTANGIBLE_HAIRCUT:.0%}',
             change_threshold='大额并购或商誉减值；可辨认无形资产的构成披露变化。', theses=['T1']),
        dict(code='J-EPV', title='调整后利润表：Greenwald 经营利润口径、收购摊销与所得税', status='已形成建议',
             judgment='遵循 Greenwald 第二层方法：从官方功能法核心经营利润出发，彻底剥离利息收入、一次性投资收益、联营损益与融资成本（均归入 ④ 单独计价）。'
                      '税前仅加回七成非消耗性收购摊销（6.30 亿），三成并购版权摊销留作续约成本；股权激励（SBC 约 7 亿/年）作为真实股东成本不加回；'
                      '零增长下的增长性营销/研发费用加回审慎取 0。所得税率取 2026 前三季度有效税率 16.9%（避开 2025 一次性免税收益扭曲）。',
             transmission='收购摊销加回比例每变动 30 个百分点（±2.7 亿税前），影响可持续收益 E 约 ±2.2 亿元、每股 EPV 约 ±1.1 元。',
             parameter='调整后利润表·七成收购摊销、所得税',
             change_threshold='核心经营利润率持续偏离当前假设 2 个百分点以上，或年报披露收购摊销拆分（版权 vs 商标/技术）。', theses=['T1', 'T3', 'T6']),
        dict(code='J-EPV-MEMBER', title='会员服务：并表后运行基线（不臆造已停披参数）', status='已形成建议',
             judgment=f'以 2026Q3 完整并表喜马拉雅后的会员收入 {Q3_MEMBERSHIP:.2f} 亿 × 4 ＝ {NORMAL_MEMBERSHIP:.2f} 亿元作为零增长基线。'
                      '会员按月续费、季节性弱，是最稳定的盈利锚；公司已自 2026Q1 停披季度付费用户与 ARPPU（2025Q4 为 1.274 亿 / 11.9 元），'
                      '不人为倒推未验证的账户数与单价。核心变量是汽水音乐对存量留存的冲击与 SVIP 渗透。',
             transmission=f'会员收入每下降 5%（约 −10.0 亿元），按集团税后净利率传导将减少 E 约 2.2 亿元（若按高毛利会员边际贡献约 40%+ 传导，影响更大、约 −3.2 亿元）。',
             parameter='调整后利润表·会员服务收入', change_threshold='年报披露年末付费用户低于 1.22 亿，或并表周年后可比会员收入转负。', theses=['T3', 'T4']),
        dict(code='J-EPV-ADS', title='营销及消费服务·广告：流量、填充率与渠道效率', status='已形成建议',
             judgment='与演出/周边合并在「营销及消费服务」中按滚动四季度（TTM 99.30 亿元）正常化，避免 Q1 淡季缺失造成的单季年化高估。'
                      '2026H1 附注披露集团广告收入 25.24 亿、广告代理费 5.81 亿（约 23.0%），广告变现受免费广告版转化与宏观预算影响。',
             transmission='营销及消费服务整体每下降 10%（约 −9.9 亿元），按当前净利率口径减少 E 约 2.2 亿元。',
             parameter='调整后利润表·营销及消费服务', change_threshold='广告负载大幅上升仍无增长，或核心品牌广告预算系统性流失。', theses=['T4']),
        dict(code='J-EPV-IP', title='营销及消费服务·演出与周边：平滑季节性与头部艺人档期', status='已形成建议',
             judgment='2025 年营销及消费服务 Q1 仅 15.20 亿，Q2—Q4 约 24—25 亿；2026Q3 亦受汪苏泷合作拉动。'
                      '采用 TTM 滚动四季度（99.30 亿元）替代 Q3×4（107.88 亿元），剔除约 8.6 亿元季节性与单季头部档期虚高。',
             transmission='演出与周边毛利率低于会员订阅，若其占比继续扩大，须同步复核集团毛利率（当前已下修至 42.8%）。',
             parameter='调整后利润表·营销及消费服务', change_threshold='核心艺人巡演排期明显收缩、库存减值或集团毛利率跌破 42%。', theses=['T4']),
        dict(code='J-EPV-SOCIAL', title='社交娱乐及其他：按同比下降后的最新运行底正常化', status='已形成建议',
             judgment=f'以 2026Q3 同比下降 15.7% 后的 {Q3_SOCIAL:.2f} 亿 × 4 ＝ {NORMAL_SOCIAL:.2f} 亿元作无增长基线（低于 TTM 55.10 亿元），不假定直播打赏回升。',
             transmission='收入较基准再降 20%（约 −10.1 亿元），由于主播分成可随收入同步缩减，对税前利润边际拖累约 1.5—2.0 亿元。',
             parameter='调整后利润表·社交娱乐及其他', change_threshold='监管收紧或公司主动关停导致单季同比跌幅扩大至 25% 以上。'),
        dict(code='J-EPV-COST', title='功能法经营成本与费用：锁定并表后 42.8% 毛利率与 25.6% 核心利润率', status='已形成建议',
             judgment='坚持官方功能法三线（营业成本 57.24%、销售费用 3.30%、管理费用 13.84%），保证 2021—2026Q3 历史连续、无黑箱差额，'
                      '并直接对接 M1 护城河红线（毛利率 40%/42%）与 M4 腾讯生态获客优势（销售费用率 3.3% vs 网易云 7.5%）。'
                      '三项比率全部取 2026Q3 完整并表后实绩，已主动低于 2025 顶点（毛利率 44.2%、核心经营利润率 29.4%）。'
                      '2023—2026H1 附注按性质拆分（服务成本、员工福利、广告代理费、推广开支）在页面独立透视展示，供交叉核验。',
             transmission=f'营业成本率或经营费用率每上升 1 个百分点，正常化 EBIT 减少约 {NORMAL_REVENUE_EST * 0.01:.2f} 亿元，每股 EPV 减少约 1.5 元。',
             parameter='调整后利润表·营业成本、销售及营销费用、一般及行政费用',
             change_threshold='单季毛利率连续两季低于 42%（T1 警戒线）或 40%（M1 证伪线）；销售费用率持续高于 4.5%。', theses=['T1', 'T2', 'T4']),
        dict(code='J-MCAP', title='稳态配平：并表后经营折旧摊销 14.34 亿 ＝ 维持性资本开支 14.34 亿', status='已形成建议',
             judgment=f'2026Q3 折旧 0.53 亿 ＋ 无形摊销 4.63 亿，扣除已税前加回的七成收购摊销（1.575 亿）后年化为 {OPERATING_DA:.2f} 亿元。'
                      '2024—2025 年剔除一次性总部土地购置后，经营资本开支（10.32、11.88 亿）与同期折旧摊销（9.78、13.75 亿）基本 1:1 匹配。'
                      '喜马拉雅并表后无形资产翻倍至 55.5 亿元，遵循 Greenwald 无增长稳态约束（真实经营折旧不能永续高于维持性资本开支），'
                      f'令维持性资本开支按 {MAINT_CAPEX:.2f} 亿元配平（税后调整净额 0.00 亿元），杜绝跨期错配造成的 +52.5 亿元估值虚增。',
             transmission='维持性资本开支每高于（或低于）经营折旧摊销 1 亿元，归母 E 减少（或增加）0.97 亿元，经营 EPV 变动 16.2 亿元（约 0.52 元/股）。',
             parameter='调整后利润表·经营性折旧与摊销、维持性资本开支',
             change_threshold='2026 年报披露并表后完整资本开支持续偏离经营折旧摊销 3 亿元以上（如 AI 算力/数据中心大幅扩张）。', theses=['T6']),
        dict(code='J-MINOR', title='少数股东 3%：经营部分乘 97%，非经营部分在桥里扣', status='已形成建议',
             judgment=f'Q3 少数股东损益 0.65 亿÷净利润 22.19 亿，取整 3%（J-FIN）。经营部分：调整后利润表最后扣 3%，资产价值也乘 97%；非经营部分：资产负债桥只扣少数股东在'
                      f'非经营净资产（现金扣经营所需与有息负债、汇出预提税，对外投资折后，约 {nonop:,.1f} 亿元）中的 3%，即 {minority_nonop:.2f} 亿元。'
                      f'账面少数股东权益 {bs["非控股权益"]:.2f} 亿元不全额扣：其余部分在经营资产里，已经被 97% 扣过，全额再扣就重复了。',
             transmission='少数股东比例每 ±1 个百分点，每股盈利能力价值约 ∓0.4 元。',
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
