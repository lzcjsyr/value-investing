"""腾讯音乐的跟踪数据（framework/tools/track.py 调用；python3 framework/tools/track.py all 01698.HK）。

竞争对手的利润率（事项“免费音乐竞争”“同业对比”的定量部分；framework/tools/peer_stats.py）：
  · 网易云音乐（09899.HK，东方财富港股报表）：毛利率、经营利润率，半年与全年；说明里写同期腾讯音乐的同口径值；
  · Spotify（SPOT，东方财富美股报表）：单季毛利率、营业利润率——全球订阅音乐的利润率参照。
"""
import peer_stats

SRC_HK = '跟踪脚本 companies/01698_腾讯音乐/track.py：东方财富港股报表（akshare stock_financial_hk_report_em），毛利率＝毛利÷营业额，经营利润率＝经营溢利÷营业额'
SRC_US = '跟踪脚本：东方财富美股报表（akshare stock_financial_us_report_em，单季），毛利率＝毛利÷营业收入，营业利润率＝营业利润÷营业收入'


def m(name, basis, frequency, source, notes):
    return dict(name=name, unit='%', category='其他', source_kind='手工整理', basis=basis, frequency=frequency, measure='时期',
                source_name=source, notes=notes)


METRICS = [
    m('同业毛利率：网易云音乐', '半年累计', '半年', SRC_HK, '国内第二大在线音乐平台；说明里写同期腾讯音乐的同口径毛利率。'),
    m('同业经营利润率：网易云音乐', '半年累计', '半年', SRC_HK, '说明里写同期腾讯音乐的同口径经营利润率。'),
    m('同业毛利率：Spotify', '单季', '季', SRC_US, '全球订阅音乐龙头；版权方分成比例与腾讯音乐不同，看趋势。'),
    m('同业营业利润率：Spotify', '单季', '季', SRC_US, None),
]


def fetch(db):
    own = peer_stats.hk_margins('01698')
    cloud = peer_stats.hk_margins('09899')
    spot = peer_stats.us_margins('SPOT')
    rows = []
    for key, name in (('gm', METRICS[0]['name']), ('op', METRICS[1]['name'])):
        for (p, b, e), v in sorted(cloud[key].items(), key=lambda x: x[0][2]):
            mine = own[key].get((p, b, e))
            rows.append(dict(name=name, unit='%', period=p, basis=b, obs_date=e, value=round(v, 2),
                             summary=f'同期腾讯音乐 {mine:.2f}%' if mine is not None else None))
    for key, name in (('gm', METRICS[2]['name']), ('op', METRICS[3]['name'])):
        rows += [dict(name=name, unit='%', period=p, basis=b, obs_date=e, value=round(v, 2)) for (p, b, e), v in sorted(spot[key].items(), key=lambda x: x[0][2])]
    return rows
