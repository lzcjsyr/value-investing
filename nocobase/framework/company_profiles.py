"""公司页面配置：沿用长江电力的交互，按各公司原模型解释驱动。"""

def driver(label, field, historical=None, judgment=None, **extra):
    return dict(label=label, p=field, **({'h': historical} if historical else {}),
                **({'j': judgment if isinstance(judgment, list) else [judgment]} if judgment else {}), **extra)


def profile(code):
    labels = {
        '002078.SZ': ('浆纸销量（万吨）', '综合吨收入（万元/吨）',
                      '销量 × 综合吨收入得到收入；吨成本、折旧和利息决定利润，资本开支与派息率决定股东能拿到的现金。'),
        '601668.SH': ('新签合同总额（亿元）', '收入转化率',
                      '新签合同总额 × 收入转化率是年度收入的近似建模口径；订单并非当期收入。重点检验减值、回款及归母现金能否支持分红。'),
        '01698.HK': ('付费用户（亿人）', '总收入 / 付费用户（元/年）',
                     '付费用户 × 每用户年收入近似集团收入；该单价包含广告、演出及社交娱乐，不等同于订阅 ARPPU。主估值为核心盈利、净现金和对外投资的分部加总。'),
        '01810.HK': ('全球月活用户（亿人）', '集团收入 / 月活用户（元/年）',
                     '月活 × 每月活年收入只是集团汇总模型，不代表每个用户实际付费。主估值分别处理手机、AIoT、互联网、汽车和 AI；集团现金流用于交叉检查。'),
    }
    volume, price, logic = labels[code]
    qj = 'J-MAU' if code == '01810.HK' else 'J-Q'
    pj = 'J-MAU' if code == '01810.HK' else 'J-P'
    costj = 'J-OPEX' if code == '01810.HK' else 'J-M'
    foreign = code.endswith('.HK')
    rows = [
        {'section': '收入与业务规模'},
        driver(volume, 'volume', 'volume', qj, d=2, how='逐年路径 × 情景业务量系数'),
        driver(price, 'price', 'price', pj, d=4 if code in ('002078.SZ', '601668.SH') else 1, how='逐年路径 × 情景单价系数'),
        driver('营业收入', 'revenue', 'revenue', strong=True, how='业务量 × 单价'),
        {'section': '成本与利润（金额：亿元人民币）'},
        driver('付现成本', 'cash_cost', judgment=costj, how='基准付现成本 × 情景成本系数'),
        driver('折旧摊销', 'depreciation', 'da', 'J-DA' if code != '01810.HK' else None),
        driver('利息', 'interest', 'finance_cost', 'J-DEBT' if code != '01810.HK' else 'J-OTHER'),
        driver('其他净贡献', 'other_contrib', judgment='J-IMP' if code == '601668.SH' else 'J-OTH' if code == '01698.HK' else 'J-OTHER', how='投资收益、减值等净额，按各公司原模型口径'),
        driver('利润总额', 'pretax', 'pretax_profit', strong=True),
        dict(label='所得税率', f='tax_rate', h='tax_rate', pct=True, d=2, j=['J-TAX'] if code != '01810.HK' else []),
        dict(label='少数股东占比', f='minority_share', h='minority_share', pct=True, d=2, j=['J-TAX'] if code in ('01698.HK', '601668.SH') else []),
        driver('归母净利润', 'np_parent', 'np_parent', strong=True),
        {'section': '股东回报与现金约束'},
        driver('股东回报率（股息＋回购）' if foreign else '派息率', 'payout', 'payout', 'J-PAYOUT', pct=True, how='按原模型口径；回购金额不等于现金股息' if foreign else '计划股息 ÷ 归母净利润'),
        driver('每股股东回报（元人民币）' if foreign else '每股股息（元）', 'dps', 'dps', strong=True, d=3),
        dict(label='维持资本开支', f='maint_capex', j=['J-CAPEX'] if code != '01810.HK' else [], d=1),
        dict(label='扩张资本开支', f='growth_capex', j=['J-CAPEX'] if code != '01810.HK' else [], d=1),
        dict(label='营运资本增加', f='wc_increase', j=['J-WC'] if code == '601668.SH' else [], d=1),
        dict(label='净借款（负数＝偿债）', f='net_borrowing', d=1),
        driver('股东自由现金流', 'fcfe', strong=True, how='按数据库归母现金桥接口径'),
        driver('计划回报现金缺口', 'funding_gap', how='现金不足部分；缺项保持未知'),
    ]
    return {
        # 原 J-R 是折现率与风险溢价，不能冒充投资者的回报门槛依据。
        'method': 'sotp' if foreign else 'irr', 'hurdle_j': None, 'logic': logic, 'drivers': rows,
        'shocks': [
            {'label': '收入中枢 −5%', 'rev': -0.05, 'j': qj + ' / ' + pj},
            {'label': '收入中枢 +5%', 'rev': 0.05, 'j': qj + ' / ' + pj},
            {'label': '付现成本 +5%', 'cost': 0.05, 'j': costj},
            {'label': '债务成本 +1 个百分点', 'kd': 0.01},
            {'label': '永续增长 0%', 'g': 0.0, 'j': 'J-TV'},
            {'label': '买入价 −10%', 'price': -0.1},
        ],
    }


PROFILES = {code: profile(code) for code in ('002078.SZ', '601668.SH', '01698.HK', '01810.HK')}
