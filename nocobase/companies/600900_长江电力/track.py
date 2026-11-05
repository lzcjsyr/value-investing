"""长江电力的跟踪数据（framework/tools/track.py 调用；python3 framework/tools/track.py all 600900.SH）。

同业对比（四家 A 股水电：华能水电、国投电力、川投能源、桂冠电力；新浪财报，与长江电力同口径，framework/tools/peer_stats.py）：
毛利率（年度与单季）、ROE（归母净利 ÷ 年初年末平均归母权益）、资产负债率的中位数，每家的值写在说明里；
长江电力自己的同口径 ROE、资产负债率一起算，便于对照（论点 T1 的“回报高于并稳于同业”、T4 的财务费用退坡）。
国投电力、川投能源含火电或参股水电，口径不完全可比，看中位数与趋势。
"""
import peer_stats

SELF = 'sh600900'
PEERS = [('sh600025', '华能水电'), ('sh600886', '国投电力'), ('sh600674', '川投能源'), ('sh600236', '桂冠电力')]
YEARS = range(2016, 2026)
SRC = ('跟踪脚本 companies/600900_长江电力/track.py：新浪财报（akshare stock_financial_report_sina），四家水电：'
       + '、'.join(n for _, n in PEERS))


def m(name, category, basis, frequency, source, notes):
    return dict(name=name, unit='%', category=category, source_kind='手工整理', basis=basis, frequency=frequency, measure='时期',
                source_name=source, notes=notes)


METRICS = [
    m('同业毛利率中位数（四家水电）', '其他', '单季', '季', SRC + '；毛利率＝1 − 营业成本÷营业收入',
      '与长江电力同口径。水电成本以折旧为主，毛利率差主要来自电价与利用小时。'),
    m('同业ROE中位数（四家水电）', '其他', '全年', '年', SRC + '；ROE＝归母净利÷年初年末平均归母权益',
      '长江电力的同口径 ROE 见“归母ROE（同业口径）”。'),
    m('同业资产负债率中位数（四家水电）', '其他', '全年', '年', SRC + '；负债合计÷资产总计（年末）', None),
    m('归母ROE（同业口径）', '财务', '全年', '年', '跟踪脚本：归母净利 ÷ 年初年末平均归母权益（新浪财报，与同业同口径）',
      '与公司公告的加权平均 ROE 略有差异。'),
    m('资产负债率', '财务', '全年', '年', '跟踪脚本：负债合计 ÷ 资产总计（年末，新浪财报）', None),
]


def fetch(db):
    own = peer_stats.ratios(SELF, YEARS)
    peers = {n: peer_stats.ratios(c, YEARS) for c, n in PEERS}
    rows = []
    for key, name in (('gm', METRICS[0]['name']), ('roe', METRICS[1]['name']), ('debt', METRICS[2]['name'])):
        rows += peer_stats.peer_rows(name, key, own, peers, '长江电力')
    rows += peer_stats.own_rows(METRICS[3]['name'], 'roe', own) + peer_stats.own_rows(METRICS[4]['name'], 'debt', own)
    return rows
