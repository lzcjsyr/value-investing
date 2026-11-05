"""小米集团的跟踪数据（framework/tools/track.py 调用；python3 framework/tools/track.py all 01810.HK）。

同业利润率（framework/tools/peer_stats.py）：
  · 汽车：理想汽车、小鹏汽车、零跑汽车、蔚来（东方财富港股报表，全年、半年、一季度）的集团毛利率；
    说明里写同期小米“汽车及AI分部毛利率”（单季按分部收入加权成半年、全年）。同业是整车公司的集团口径，含少量服务业务。
  · 手机：传音控股（新浪财报，单季、全年）毛利率，与小米“智能手机毛利率”对照。
"""
import peer_stats

EV = [('02015', '理想汽车'), ('09868', '小鹏汽车'), ('09863', '零跑汽车'), ('09866', '蔚来')]
SRC_HK = '跟踪脚本 companies/01810_小米集团/track.py：东方财富港股报表（akshare stock_financial_hk_report_em），毛利率＝毛利÷营业额'
SRC_A = '跟踪脚本：新浪财报（akshare stock_financial_report_sina），毛利率＝1 − 营业成本÷营业收入'
METRICS = [dict(name=f'同业毛利率：{n}', unit='%', category='其他', source_kind='手工整理', basis='全年' if n == '蔚来' else '半年累计',
                frequency='年' if n == '蔚来' else '半年', measure='时期',
                source_name=SRC_HK, notes='与小米“汽车及AI分部毛利率”对照（说明里写同期小米的值）。') for _, n in EV] + [
    dict(name='同业毛利率：传音控股', unit='%', category='其他', source_kind='手工整理', basis='单季', frequency='季', measure='时期',
         source_name=SRC_A, notes='新兴市场手机龙头；与小米“智能手机毛利率”对照。')]


def xiaomi_ev(db):
    """小米汽车及AI分部：单季毛利率与收入 → {(期间, 口径): 毛利率}，含半年、全年的收入加权值。"""
    rows = db("SELECT m.name, s.period, s.value FROM vi_series s JOIN vi_metric_base m ON m.id = s.metric_id "
              "WHERE m.company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND s.basis = '单季' "
              "AND m.name IN ('汽车及AI分部毛利率', '智能电动汽车及AI分部收入')")
    gm = {p: float(v) for n, p, v in rows if n == '汽车及AI分部毛利率'}
    rev = {p: float(v) for n, p, v in rows if n == '智能电动汽车及AI分部收入'}
    out = {(p, '单季'): v for p, v in gm.items()}
    for y in {p[:4] for p in gm}:
        for label, qs, basis in ((f'{y}H1', ('Q1', 'Q2'), '半年累计'), (y, ('Q1', 'Q2', 'Q3', 'Q4'), '全年')):
            ps = [y + q for q in qs]
            if all(p in gm and p in rev for p in ps):
                out[(label, basis)] = sum(gm[p] * rev[p] for p in ps) / sum(rev[p] for p in ps)
    return out


def fetch(db):
    mine = xiaomi_ev(db)
    rows = []
    for code, n in EV:
        gm = peer_stats.hk_margins(code, since=2023)['gm']
        for (p, b, e), v in sorted(gm.items(), key=lambda x: x[0][2]):
            x = mine.get((p, b))
            rows.append(dict(name=f'同业毛利率：{n}', unit='%', period=p, basis=b, obs_date=e, value=round(v, 2),
                             summary=f'同期小米汽车及AI分部 {x:.2f}%' if x is not None else None))
    tr = peer_stats.ratios('sh688036', range(2019, 2026))['gm']
    rows += [dict(name='同业毛利率：传音控股', unit='%', period=p, basis=b, obs_date=e, value=round(v, 2)) for (p, b, e), v in sorted(tr.items(), key=lambda x: x[0][2])]
    return rows
