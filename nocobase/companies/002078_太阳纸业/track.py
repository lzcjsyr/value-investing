"""太阳纸业的跟踪数据（framework/tools/track.py 调用；python3 framework/tools/track.py all 002078.SZ）。

1. 浆价与纸价（宏观日度行情，各公司共用）：
   · 纸浆期货（新浪 SP0 连续）：采集工作流只从 2026-10-22 起有数，这里补 2018 年上市以来的日收盘价；
   · 胶版印刷纸期货（新浪 OP0 连续，上期所 2025-09-10 上市）：文化纸（双胶纸）的公开日度价格，补全部历史；之后由采集工作流每天采；
   · 纸浆现货价（生意社现期表，山东漂白针叶浆）：期货贴水/升水看现货紧不紧，增量补数。
2. 成本优势的测算（同业对比）：七家 A 股造纸同业与太阳纸业同口径（新浪财报利润表，营业收入、营业成本）算的毛利率，
   年度 2016—2025、单季近 3 年；“毛利率领先同业中位数”＝太阳纸业 − 七家中位数（百分点）。
3. 吨经济：营业收入、营业成本、毛利 ÷ 浆纸销量（纸＋外销浆），元/吨（年度；收入含少量电汽、化工等，按全部收入计）。
"""
import json, pathlib, statistics, warnings
from inspect import signature
import akshare as ak
import peer_stats

warnings.filterwarnings('ignore')
HERE = pathlib.Path(__file__).resolve().parent
SNAP = HERE / 'data' / 'track.json'
SELF = ('sz002078', '太阳纸业')
PEERS = [('sh600567', '山鹰国际'), ('sh600966', '博汇纸业'), ('sz000488', '晨鸣纸业'), ('sh600308', '华泰股份'),
         ('sh600963', '岳阳林纸'), ('sh603733', '仙鹤股份'), ('sh605007', '五洲特纸')]
YEARS = range(2016, 2026)
SRC_FS = '跟踪脚本 companies/002078_太阳纸业/track.py：新浪财报利润表（akshare stock_financial_report_sina），毛利率＝1 − 营业成本 ÷ 营业收入'
DAILY_NOTE = '跟踪脚本补历史（akshare），之后由采集工作流或跟踪脚本每天更新'

MACRO = [
    dict(name='纸浆期货最新价（新浪 SP0 连续）', unit='元/吨', code='SP.SHFE.SINA', category='商品', source_kind='自动采集', basis='时点',
         frequency='交易日', measure='时点', macro=True,
         source_name='新浪期货 SP0 连续（采集工作流）；2026-10-22 以前为跟踪脚本补的日收盘价（akshare futures_main_sina）',
         notes='上期所纸浆期货交割品是漂白针叶浆，只代表针叶浆价格方向；太阳纸业外购浆以阔叶浆为主、自制浆六成以上。'),
    dict(name='胶版印刷纸期货（新浪 OP0 连续）', unit='元/吨', code='OP.SHFE.SINA', category='商品', source_kind='自动采集', basis='时点',
         frequency='交易日', measure='时点', macro=True,
         source_name='新浪期货 OP0 连续（采集工作流）；历史为跟踪脚本补的日收盘价（akshare futures_main_sina）',
         notes='上期所胶版印刷纸期货（2025-09-10 上市），交割品为双胶纸（胶版印刷纸），是文化纸价格的公开日度参照；看“纸价 − 浆价”的价差，不只看纸价。'),
    dict(name='纸浆现货价（生意社，漂白针叶浆）', unit='元/吨', code='SP.SPOT.100PPI', category='商品', source_kind='手工整理', basis='时点',
         frequency='交易日', measure='时点', macro=True,
         source_name='跟踪脚本：生意社期现表纸浆现货价（akshare futures_spot_price_daily），山东地区漂白针叶浆',
         notes='与期货价之差＝基差：现货升水说明现货紧、期货偏低。只代表针叶浆。'),
]
COMPANY = [dict(name=f'同业毛利率：{n}', unit='%', category='其他', source_kind='手工整理', basis='单季', frequency='季', measure='时期',
                source_name=SRC_FS, notes=f'与太阳纸业同口径的毛利率，用于测算成本优势（壁垒 M1—M3）。{c[2:]}')
           for c, n in PEERS] + [
    dict(name='毛利率领先同业中位数', unit='百分点', category='其他', source_kind='手工整理', basis='单季', frequency='季', measure='时期',
         source_name=SRC_FS + '；七家同业：' + '、'.join(n for _, n in PEERS),
         notes='太阳纸业毛利率 − 七家 A 股造纸同业毛利率的中位数（同一报告期、同一口径）。成本优势的直接度量：持续为正且不收窄，说明自制浆、能源、林地的成本优势在兑现。'),
    dict(name='吨收入（营业收入 ÷ 浆纸销量）', unit='元/吨', category='经营', source_kind='手工整理', basis='全年', frequency='年', measure='时期',
         source_name='跟踪脚本：营业收入（新浪财报）÷ 浆纸销量（纸＋外销浆，年报）', notes='收入含少量电汽、化工等其他业务，按全部收入计。'),
    dict(name='吨营业成本（营业成本 ÷ 浆纸销量）', unit='元/吨', category='经营', source_kind='手工整理', basis='全年', frequency='年', measure='时期',
         source_name='跟踪脚本：营业成本（新浪财报）÷ 浆纸销量（纸＋外销浆，年报）', notes='吨成本的走势与浆价（纸浆期货）对照：自制浆比例越高，吨成本随浆价波动越小。'),
    dict(name='吨毛利（毛利 ÷ 浆纸销量）', unit='元/吨', category='经营', source_kind='手工整理', basis='全年', frequency='年', measure='时期',
         source_name='跟踪脚本：（营业收入 − 营业成本）÷ 浆纸销量（纸＋外销浆，年报）', notes=None),
]
METRICS = MACRO + COMPANY


def previous():
    return json.loads(SNAP.read_text()).get('observations', []) if SNAP.exists() else []


def futures(symbol, name, since='20180101'):
    df = ak.futures_main_sina(symbol=symbol, start_date=since, end_date='20991231')
    return [dict(name=name, unit='元/吨', period=None, basis='时点', obs_date=str(r['日期'])[:10], value=float(r['收盘价']))
            for _, r in df.iterrows() if r['收盘价'] == r['收盘价']]


def spot(name):
    old = [o for o in previous() if o['name'] == name]
    start = (max(o['obs_date'] for o in old) if old else '2024-11-01').replace('-', '')
    fetch_spot = ak.futures_spot_price_daily
    if 'start_day' in signature(fetch_spot).parameters:
        df = fetch_spot(start_day=start, end_day='20991231', vars_list=['SP'])
    else:
        df = fetch_spot(start_date=start, end_date=None, symbols='SP')
    new = {str(r['date'])[:4] + '-' + str(r['date'])[4:6] + '-' + str(r['date'])[6:8]: float(r['spot_price'])
           for _, r in df.iterrows() if r['spot_price'] == r['spot_price']}
    rows = {o['obs_date']: o for o in old}
    for d, v in new.items():
        rows[d] = dict(name=name, unit='元/吨', period=None, basis='时点', obs_date=d, value=v)
    return sorted(rows.values(), key=lambda o: o['obs_date'])


def fetch(db):
    rows = futures('SP0', MACRO[0]['name']) + futures('OP0', MACRO[1]['name'], '20250901') + spot(MACRO[2]['name'])
    mine = peer_stats.ratios(SELF[0], YEARS)['gm']
    peers = {n: peer_stats.ratios(c, YEARS)['gm'] for c, n in PEERS}
    inc = peer_stats.sheet(SELF[0], '利润表')
    own = {d: (peer_stats.num(r.get('营业收入')), peer_stats.num(r.get('营业成本'))) for d, r in inc.items() if d.endswith('12-31')}
    for n, gm in peers.items():
        for (p, b, e), v in gm.items():
            rows.append(dict(name=f'同业毛利率：{n}', unit='%', period=p, basis=b, obs_date=e, value=round(v, 2)))
    for (p, b, e), v in sorted(mine.items(), key=lambda x: x[0][2]):
        vals = [gm[(p, b, e)] for gm in peers.values() if (p, b, e) in gm]
        if len(vals) >= 5:
            med = statistics.median(vals)
            rows.append(dict(name='毛利率领先同业中位数', unit='百分点', period=p, basis=b, obs_date=e, value=round(v - med, 2),
                             summary=f'太阳纸业 {v:.2f}% − 同业中位数 {med:.2f}%（{len(vals)} 家）'))
    vol = {r[0]: float(r[1]) for r in db("SELECT s.period, s.value FROM vi_series s JOIN vi_metric_base m ON m.id = s.metric_id "
                                         "WHERE m.company_id = (SELECT id FROM vi_company_base WHERE code = '002078.SZ') "
                                         "AND m.name = '浆纸销量（纸＋外销浆）' AND s.basis = '全年'")}
    for y in YEARS:
        e = f'{y}-12-31'
        if str(y) in vol and e in own and vol[str(y)] > 0:
            rev, cost = own[e]
            t = vol[str(y)] * 1e4
            note = f'营业收入 {rev / 1e8:.2f} 亿元、营业成本 {cost / 1e8:.2f} 亿元、浆纸销量 {vol[str(y)]:.0f} 万吨'
            for name, v in (('吨收入（营业收入 ÷ 浆纸销量）', rev / t), ('吨营业成本（营业成本 ÷ 浆纸销量）', cost / t), ('吨毛利（毛利 ÷ 浆纸销量）', (rev - cost) / t)):
                rows.append(dict(name=name, unit='元/吨', period=str(y), basis='全年', obs_date=e, value=round(v, 0), summary=note))
    return rows
