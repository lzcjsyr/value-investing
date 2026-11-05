"""跟踪脚本共用：A 股同业的同口径财务比率（新浪财报，akshare stock_financial_report_sina）。

ratios(sym) → {比率名: {(期间, 口径, 期末): 数值（%）}}
  gm   毛利率＝1 − 营业成本 ÷ 营业收入；全年（年报）与单季（本期累计 − 上期累计，2023 年起）
  roe  归母净利 ÷ 年初年末平均归母权益（全年；权益含永续债，不扣除）
  ar   年末（应收账款＋合同资产）÷ 全年营业收入
  debt 年末资产负债率＝负债合计 ÷ 资产总计
peer_rows(...) 把同业中位数写成跟踪脚本的数据行，每家的值写在说明里。
"""
import statistics, warnings
import akshare as ak

warnings.filterwarnings('ignore')


def num(v):
    try:
        x = float(v)
        return x if x == x else None
    except (TypeError, ValueError):
        return None


def sheet(sym, kind):
    df = ak.stock_financial_report_sina(stock=sym, symbol=kind)
    return {f'{str(r["报告日"])[:4]}-{str(r["报告日"])[4:6]}-{str(r["报告日"])[6:]}': r for _, r in df.iterrows()}


def prev_quarter(d):
    y, mo = int(d[:4]), int(d[5:7])
    return None if mo == 3 else f'{y}-{mo - 3:02d}-{30 if mo - 3 in (6, 9) else 31}'


def ratios(sym, years=range(2016, 2026), quarterly_since=2023):
    inc, bal = sheet(sym, '利润表'), sheet(sym, '资产负债表')
    out = {'gm': {}, 'roe': {}, 'ar': {}, 'debt': {}}
    for d, r in inc.items():
        y, mo = int(d[:4]), int(d[5:7])
        rev, cost = num(r.get('营业收入')), num(r.get('营业成本'))
        if not rev or cost is None:
            continue
        if mo == 12 and y in years:
            key = (str(y), '全年', d)
            out['gm'][key] = (1 - cost / rev) * 100
            npar = num(r.get('归属于母公司所有者的净利润'))
            b1, b0 = bal.get(d), bal.get(f'{y - 1}-12-31')
            q1 = num(b1.get('归属于母公司股东权益合计')) if b1 is not None else None
            q0 = num(b0.get('归属于母公司股东权益合计')) if b0 is not None else None
            if npar is not None and q1 and q0:
                out['roe'][key] = npar / ((q0 + q1) / 2) * 100
            if b1 is not None:
                ar = (num(b1.get('应收账款')) or 0) + (num(b1.get('合同资产')) or 0)
                if ar:
                    out['ar'][key] = ar / rev * 100
                liab, assets = num(b1.get('负债合计')), num(b1.get('资产总计'))
                if liab and assets:
                    out['debt'][key] = liab / assets * 100
        if y >= quarterly_since and mo in (3, 6, 9, 12):
            p = prev_quarter(d)
            r0 = inc.get(p) if p else None
            if p and r0 is None:
                continue
            rev0, cost0 = (num(r0.get('营业收入')), num(r0.get('营业成本'))) if r0 is not None else (0, 0)
            if rev0 is None or cost0 is None or rev - rev0 <= 0:
                continue
            out['gm'][(f'{y}Q{mo // 3}', '单季', d)] = (1 - (cost - cost0) / (rev - rev0)) * 100
    return out


def peer_rows(name, key, own, peers, self_label, min_peers=3):
    """同业中位数的数据行：name＝指标名称；key＝比率名；own＝本公司 ratios()；peers＝{同业名: ratios()}。"""
    rows = []
    periods = sorted({p for res in peers.values() for p in res[key]}, key=lambda x: x[2])
    for p, b, e in periods:
        vals = [(n, res[key][(p, b, e)]) for n, res in peers.items() if (p, b, e) in res[key]]
        if len(vals) >= min_peers:
            med = statistics.median(v for _, v in vals)
            mine = own[key].get((p, b, e))
            note = (f'{self_label} {mine:.2f}%；' if mine is not None else '') + '、'.join(f'{n} {v:.2f}' for n, v in vals)
            rows.append(dict(name=name, unit='%', period=p, basis=b, obs_date=e, value=round(med, 2), summary=note))
    return rows


def own_rows(name, key, own):
    return [dict(name=name, unit='%', period=p, basis=b, obs_date=e, value=round(v, 2))
            for (p, b, e), v in sorted(own[key].items(), key=lambda x: x[0][2])]


# 港股（东方财富港股报表，报告期）：001 年报＝全年，002 中报＝半年累计，003 一季报＝单季，004 三季报＝前三季度累计
HK_KIND = {'001': ('全年', ''), '002': ('半年累计', 'H1'), '003': ('单季', 'Q1'), '004': ('前三季度累计', 'Q1-Q3')}


def hk_margins(code, since=2021):
    """港股同业的毛利率、经营利润率（%）：{'gm'|'op': {(期间, 口径, 期末): 值}}。经营溢利缺失的期次只有毛利率。"""
    df = ak.stock_financial_hk_report_em(stock=code, symbol='利润表', indicator='报告期')
    out = {'gm': {}, 'op': {}}
    for (d, kind), g in df.groupby(['REPORT_DATE', 'DATE_TYPE_CODE']):
        d = str(d)[:10]
        if kind not in HK_KIND or int(d[:4]) < since:
            continue
        items = {r['STD_ITEM_NAME']: num(r['AMOUNT']) for _, r in g.iterrows()}
        rev = items.get('营业额')
        if not rev:
            continue
        basis, suffix = HK_KIND[kind]
        key = (d[:4] + suffix, basis, d)
        if items.get('毛利') is not None:
            out['gm'][key] = items['毛利'] / rev * 100
        if items.get('经营溢利') is not None:
            out['op'][key] = items['经营溢利'] / rev * 100
    return out


def us_margins(code, since=2023):
    """美股同业的单季毛利率、营业利润率（%）（东方财富美股报表，单季报）。"""
    df = ak.stock_financial_us_report_em(stock=code, symbol='综合损益表', indicator='单季报')
    out = {'gm': {}, 'op': {}}
    for d, g in df.groupby('REPORT_DATE'):
        d = str(d)[:10]
        y, mo = int(d[:4]), int(d[5:7])
        if y < since:
            continue
        items = {r['ITEM_NAME']: num(r['AMOUNT']) for _, r in g.iterrows()}
        rev = items.get('营业收入')
        if not rev:
            continue
        key = (f'{y}Q{(mo - 1) // 3 + 1}', '单季', d)
        if items.get('毛利') is not None:
            out['gm'][key] = items['毛利'] / rev * 100
        if items.get('营业利润') is not None:
            out['op'][key] = items['营业利润'] / rev * 100
    return out
