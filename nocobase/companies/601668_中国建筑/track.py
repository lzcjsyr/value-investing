"""中国建筑的跟踪数据（framework/tools/track.py 调用；python3 framework/tools/track.py all 601668.SH）。

1. 行业高频（宏观，国家统计局，akshare macro_china_nbs_nation）：
   · 建筑业商务活动指数（PMI，月）：50 以上扩张；
   · 全国房地产开发投资、房地产新开工施工面积（月，年初至今累计，同比）：房建新签与新开工的需求端；
   · 全国建筑业总产值（季，年初至今累计）：公司营业收入的行业对照（同比由跟踪脚本按上年同期算）。
2. 同业对比（六家建筑央企：中国中铁、中国铁建、中国交建、中国电建、中国化学、中国中冶；新浪财报，与中国建筑同口径）：
   毛利率、ROE（归母净利 ÷ 年初年末平均归母权益）、（应收账款＋合同资产）÷ 营业收入 的中位数，每家的数写在说明里；
   中国建筑自己的同口径 ROE 与（应收＋合同资产）÷ 收入一起算，便于对照。
"""
import warnings
import akshare as ak
import peer_stats

warnings.filterwarnings('ignore')
SELF = 'sh601668'
PEERS = [('sh601390', '中国中铁'), ('sh601186', '中国铁建'), ('sh601800', '中国交建'), ('sh601669', '中国电建'),
         ('sh601117', '中国化学'), ('sh601618', '中国中冶')]
YEARS = range(2019, 2026)
NBS = '国家统计局（akshare macro_china_nbs_nation）'
SRC = '跟踪脚本 companies/601668_中国建筑/track.py：新浪财报（akshare stock_financial_report_sina），六家建筑央企：' + '、'.join(n for _, n in PEERS)


def m(name, unit, category, basis, frequency, measure, source, notes, macro=False, code=None):
    d = dict(name=name, unit=unit, category=category, source_kind='手工整理', basis=basis, frequency=frequency, measure=measure,
             source_name=source, notes=notes, macro=macro)
    if code:
        d['code'] = code
    return d


MACRO = [
    m('建筑业商务活动指数（PMI）', '指数', '宏观', '时点', '月', '时点', NBS + '：非制造业采购经理指数 > 建筑业商务活动指数',
      '50 以上表示建筑业活动扩张。中国建筑的房建、基建新签与它同向。', True, 'NBS.PMI.CONSTRUCTION'),
    m('全国房地产开发投资', '亿元', '宏观', '年初至今累计', '月', '时期', NBS + '：房地产 > 房地产开发投资情况（累计值、累计增长）',
      '地产投资下滑传导到房建新签（2—3 个季度）和中海地产的拿地。', True, 'NBS.RE.INVEST'),
    m('全国房地产新开工施工面积', '万平方米', '宏观', '年初至今累计', '月', '时期', NBS + '：房地产 > 房地产施工、竣工面积',
      '与公司“房屋建筑新开工面积”对照：公司跌幅小于全国，说明份额在提升。', True, 'NBS.RE.NEWSTART'),
    m('全国建筑业总产值', '亿元', '宏观', '年初至今累计', '季', '时期', NBS + '：建筑业 > 建筑业总产值（同比按上年同期累计值计算）',
      '公司营业收入的行业对照。', True, 'NBS.CONSTRUCTION.OUTPUT'),
]
COMPANY = [
    m('同业毛利率中位数（六家建筑央企）', '%', '其他', '单季', '季', '时期', SRC + '；毛利率＝1 − 营业成本÷营业收入',
      '与中国建筑同口径。中国建筑的房建占比高、毛利率天然低于基建为主的同业，看的是差距是否稳定。'),
    m('同业ROE中位数（六家建筑央企）', '%', '其他', '全年', '年', '时期', SRC + '；ROE＝归母净利÷年初年末平均归母权益（含永续债，不扣除）',
      '中国建筑的同口径 ROE 见“归母ROE（同业口径）”。'),
    m('同业（应收账款＋合同资产）÷营业收入中位数', '%', '其他', '全年', '年', '时期', SRC + '；年末余额 ÷ 全年营业收入',
      '垫资强度：越高说明收入里越多的部分还没收到现金。'),
    m('归母ROE（同业口径）', '%', '财务', '全年', '年', '时期', '跟踪脚本：归母净利 ÷ 年初年末平均归母权益（新浪财报，与同业同口径）',
      '含永续债的权益口径，与公司公告的加权平均 ROE 略有差异。'),
    m('（应收账款＋合同资产）÷营业收入', '%', '财务', '全年', '年', '时期', '跟踪脚本：年末（应收账款＋合同资产）÷ 全年营业收入（新浪财报）',
      '垫资强度；与同业中位数对照。'),
]
METRICS = MACRO + COMPANY


def f(v):
    return peer_stats.num(v)


def nbs(kind, path, period='2021-'):
    df = ak.macro_china_nbs_nation(kind=kind, path=path, period=period)
    out = {}
    for col in df.columns:
        c = str(col)
        y = int(c[:4])
        if '季度' in c:
            mo = {'第一季度': 3, '第二季度': 6, '第三季度': 9, '第四季度': 12}[c[5:]]
        else:
            mo = int(c[5:].rstrip('月'))
        out[(y, mo)] = df[col]
    return out


def month_end(y, mo):
    return f'{y}-{mo:02d}-{30 if mo in (4, 6, 9, 11) else 28 if mo == 2 else 31}'


def fetch(db):
    rows = []
    pmi = nbs('月度数据', '采购经理指数 > 非制造业采购经理指数')
    for (y, mo), s in sorted(pmi.items()):
        v = f(s.get('建筑业商务活动指数(%)'))
        if v is not None:
            rows.append(dict(name=MACRO[0]['name'], unit='指数', period=f'{y}M{mo:02d}', basis='时点', obs_date=month_end(y, mo), value=v))
    inv = nbs('月度数据', '房地产 > 房地产开发投资情况')
    for (y, mo), s in sorted(inv.items()):
        v, g = f(s.get('房地产投资__累计值(亿元)')), f(s.get('房地产投资_累计增长(%)'))
        if v:
            rows.append(dict(name=MACRO[1]['name'], unit='亿元', period=f'{y}M{mo:02d}', basis='年初至今累计', obs_date=month_end(y, mo),
                             value=v, yoy=None if g is None else round(g / 100, 4)))
    area = nbs('月度数据', '房地产 > 房地产施工、竣工面积')
    for (y, mo), s in sorted(area.items()):
        v, g = f(s.get('房地产新开工施工面积_累计值(万平方米)')), f(s.get('房地产新开工施工面积累计增长(%)'))
        if v:
            rows.append(dict(name=MACRO[2]['name'], unit='万平方米', period=f'{y}M{mo:02d}', basis='年初至今累计', obs_date=month_end(y, mo),
                             value=v, yoy=None if g is None else round(g / 100, 4)))
    out = nbs('季度数据', '建筑业 > 建筑业总产值')
    vals = {k: f(s.get('建筑业总产值_累计值(亿元)')) for k, s in out.items()}
    for (y, mo), v in sorted(vals.items()):
        if v:
            ly = vals.get((y - 1, mo))
            rows.append(dict(name=MACRO[3]['name'], unit='亿元', period=f'{y}M{mo:02d}', basis='年初至今累计', obs_date=month_end(y, mo),
                             value=v, yoy=round(v / ly - 1, 4) if ly else None))
    own = peer_stats.ratios(SELF, YEARS)
    peers = {n: peer_stats.ratios(c, YEARS) for c, n in PEERS}
    for key, name in (('gm', COMPANY[0]['name']), ('roe', COMPANY[1]['name']), ('ar', COMPANY[2]['name'])):
        rows += peer_stats.peer_rows(name, key, own, peers, '中国建筑', min_peers=4)
    rows += peer_stats.own_rows(COMPANY[3]['name'], 'roe', own) + peer_stats.own_rows(COMPANY[4]['name'], 'ar', own)
    return rows
