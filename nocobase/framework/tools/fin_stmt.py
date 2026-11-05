"""季度完整三大报表（财务数据，表代码 fin_stmt）：akshare 取数 → 仔细检验 → 入库。

数据来源（都经 akshare）：
  · A 股（长江电力、太阳纸业、中国建筑）＝新浪财报 stock_financial_report_sina，按报告期的完整三大报表，科目为报表中文原名、列序即报表行次。
  · 港股（腾讯音乐、小米集团）＝东方财富港股报表 stock_financial_hk_report_em(indicator='报告期')，标准科目（STD_ITEM_NAME）按科目代码排序。

检验（check，取数后自动做，也可单独跑）：
  1. 会计恒等式：资产＝负债＋权益、各表合计与分项、利润总额−所得税＝净利润、净利润＝归母＋少数、
     期末现金＝期初现金＋净增加额（＋期间变动其他项目，港股）、三类业务现金净额合计＝现金净额（港股）。
     容差 0.01 亿元（源数据按千元/百万元取整）。
  2. 现金衔接：现金流量表的期初是年初余额（累计口径），年内各期应一致；跨年衔接（本年年初 vs 上年末）差异只做提示，
     重述或口径差异常见，不作为失败。
  3. 跨源核对（A 股）：与东方财富 stock_*_sheet_by_report_em 的关键科目逐报告期比对；只在 2010 年以后的报告期要求一致。
  4. 旧文件核对（港股）：与 data/eastmoney_hk_*.json（此前逐项核对过业绩公告的原始报表）比对。
  （历史年度的数值已直接从本报表计算，不再单独对账；报表算出的数与年报不同的年份，在「数据」里录调整值。）
  修复规则：某报告期恒等式失败、且东方财富同口径通过时，用东方财富值替换该期的关键科目（计入“已修复”）；
  源头就残缺、无法一致修复的期次保留原值并列入“已知源数据瑕疵”。

快照：companies/<代码>/data/fin_stmt.json（fetched_at/source/rows/cross）。rows 一行＝公司×报表×报告期×科目，
金额已折成亿元（报表原值÷1e8）；cross 是 A 股跨源关键科目，供离线复核。

用法（在 framework/ 或任意目录执行）：
  python3 tools/fin_stmt.py fetch [公司代码 ...]    # akshare 取数写快照
  python3 tools/fin_stmt.py check [公司代码 ...]    # 只检验（读快照＋数据库），失败退出码 1
  python3 tools/fin_stmt.py load  [公司代码 ...]    # 快照 → vi_fin_stmt_base（先删本公司再插，幂等）
  python3 tools/fin_stmt.py all   [公司代码 ...]    # fetch + check + load
"""
import datetime, json, pathlib, subprocess, sys, warnings

HERE = pathlib.Path(__file__).resolve().parent
FRAMEWORK = HERE.parent
ROOT = FRAMEWORK.parent
warnings.filterwarnings('ignore')

COMPANIES = {
    '600900.SH': dict(name='长江电力', market='A', sina='sh600900', em='SH600900'),
    '002078.SZ': dict(name='太阳纸业', market='A', sina='sz002078', em='SZ002078'),
    '601668.SH': dict(name='中国建筑', market='A', sina='sh601668', em='SH601668'),
    '01698.HK': dict(name='腾讯音乐', market='HK', em_hk='01698'),
    '01810.HK': dict(name='小米集团', market='HK', em_hk='01810'),
}
STMTS = ['资产负债表', '利润表', '现金流量表']
TOL = 0.01          # 恒等式容差（亿元）：源数据按千元/百万元取整
CROSS_TOL = 0.01    # 跨源比对容差（亿元）
MODERN = '2010-01-01'   # 跨源比对的“现代”报告期：此前的差异多为老准则口径

# A 股跨源关键科目：（报表, 科目名, 东方财富列名）。同时用于跨源核对与恒等式修复。
A_KEY = [
    ('资产负债表', '资产总计', 'TOTAL_ASSETS'),
    ('资产负债表', '负债合计', 'TOTAL_LIABILITIES'),
    ('资产负债表', '所有者权益(或股东权益)合计', 'TOTAL_EQUITY'),
    ('资产负债表', '归属于母公司股东权益合计', 'TOTAL_PARENT_EQUITY'),
    ('资产负债表', '少数股东权益', 'MINORITY_EQUITY'),
    ('资产负债表', '货币资金', 'MONETARYFUNDS'),
    ('资产负债表', '短期借款', 'SHORT_LOAN'),
    ('资产负债表', '其他权益工具', 'OTHER_EQUITY'),
    ('利润表', '营业总收入', 'TOTAL_OPERATE_INCOME'),
    ('利润表', '营业成本', 'OPERATE_COST'),
    ('利润表', '营业总成本', 'TOTAL_OPERATE_COST'),
    ('利润表', '利润总额', 'TOTAL_PROFIT'),
    ('利润表', '所得税费用', 'INCOME_TAX'),
    ('利润表', '净利润', 'NETPROFIT'),
    ('利润表', '归属于母公司所有者的净利润', 'PARENT_NETPROFIT'),
    ('利润表', '少数股东损益', 'MINORITY_INTEREST'),
    ('现金流量表', '经营活动产生的现金流量净额', 'NETCASH_OPERATE'),
    ('现金流量表', '现金及现金等价物净增加额', 'CCE_ADD'),
    ('现金流量表', '期初现金及现金等价物余额', 'BEGIN_CCE'),
    ('现金流量表', '期末现金及现金等价物余额', 'END_CCE'),
]

# 恒等式：(说明, 报表, 左边科目, 右边[(科目, 系数)])。左边 = Σ 系数×科目；有科目缺失时该条跳过。
IDENT = {
    'A': [
        ('资产＝负债＋权益', '资产负债表', '资产总计', [('负债合计', 1), ('所有者权益(或股东权益)合计', 1)]),
        ('资产＝负债和权益总计', '资产负债表', '资产总计', [('负债和所有者权益(或股东权益)总计', 1)]),
        ('资产＝流动＋非流动资产', '资产负债表', '资产总计', [('流动资产合计', 1), ('非流动资产合计', 1)]),
        ('负债＝流动＋非流动负债', '资产负债表', '负债合计', [('流动负债合计', 1), ('非流动负债合计', 1)]),
        ('权益＝归母＋少数', '资产负债表', '所有者权益(或股东权益)合计', [('归属于母公司股东权益合计', 1), ('少数股东权益', 1)]),
        ('利润总额−所得税＝净利润', '利润表', '净利润', [('利润总额', 1), ('所得税费用', -1)]),
        ('净利润＝归母＋少数', '利润表', '净利润', [('归属于母公司所有者的净利润', 1), ('少数股东损益', 1)]),
        ('期末现金＝期初现金＋净增加额', '现金流量表', '期末现金及现金等价物余额',
         [('期初现金及现金等价物余额', 1), ('现金及现金等价物净增加额', 1)]),
    ],
    'HK': [
        ('总资产＝总负债＋总权益', '资产负债表', '总资产', [('总负债', 1), ('总权益', 1)]),
        ('总资产＝总权益及总负债', '资产负债表', '总资产', [('总权益及总负债', 1)]),
        ('总资产＝流动＋非流动资产', '资产负债表', '总资产', [('流动资产合计', 1), ('非流动资产合计', 1)]),
        ('总负债＝流动＋非流动负债', '资产负债表', '总负债', [('流动负债合计', 1), ('非流动负债合计', 1)]),
        ('总权益＝股东权益＋少数股东权益', '资产负债表', '总权益', [('股东权益', 1), ('少数股东权益', 1)]),
        ('净资产＝总资产−总负债', '资产负债表', '净资产', [('总资产', 1), ('总负债', -1)]),
        ('除税前溢利−税项＝除税后溢利', '利润表', '除税后溢利', [('除税前溢利', 1), ('税项', -1)]),
        ('除税后溢利＝股东应占溢利＋少数股东损益', '利润表', '除税后溢利', [('股东应占溢利', 1), ('少数股东损益', 1)]),
        ('毛利＝营业额−销售成本', '利润表', '毛利', [('营业额', 1), ('销售成本', -1)]),
        ('期末现金＝期初现金＋现金净额＋期间变动其他项目', '现金流量表', '期末现金',
         [('期初现金', 1), ('现金净额', 1), ('期间变动其他项目', 1)]),
        ('三类业务现金净额合计＝现金净额', '现金流量表', '现金净额',
         [('经营业务现金净额', 1), ('投资业务现金净额', 1), ('融资业务现金净额', 1)]),
    ],
}

# 已知源数据瑕疵：源头残缺、无法一致修复，保留原值。命中这里不算检验失败。
# (报告期, 报表, 恒等式/环节说明, 原因)
KNOWN = {
    '002078.SZ': [
        ('2006-06-30', '现金流量表', '期末现金＝期初现金＋净增加额',
         '上市前报告期：新浪与东方财富的期初/期末现金均残缺（东财该期缺期末，新浪把净增加额抄进期末），保留原值'),
    ],
}

# 有据修复：源头个别单元格明显错了（与恒等式、跨源都对不上），按依据改正并在报告里记录。
# (报告期, 报表, 科目, 新值[None=删除该格], 依据)。新值是“报表同格科目名”时取该格金额。
FIXES = {
    '600900.SH': [
        ('2004-03-31', '资产负债表', '少数股东权益', None,
         '新浪幻数 78.56 亿元：该期无少数股东权益（东财该格为空，权益合计＝归母，与资产＝负债＋权益矛盾），置空'),
        ('2004-03-31', '资产负债表', '负债和所有者权益(或股东权益)总计', '资产总计',
         '新浪该行按幻数权益加总成 381.25 亿元，与资产总计矛盾；按恒等式改＝资产总计'),
    ],
}


def d8(s):
    s = str(s)[:10].replace('-', '').replace('/', '')
    return f'{s[:4]}-{s[4:6]}-{s[6:8]}'


def period_label(d):
    y, m = int(d[:4]), int(d[5:7])
    return f'{y}Q{(m - 1) // 3 + 1}'


def company_dir(code):
    """companies/ 下按证券代码数字部分找公司目录（如 601668_中国建筑）。"""
    num = code.split('.')[0]
    for d in sorted((ROOT / 'companies').iterdir()):
        if d.is_dir() and d.name.split('_')[0] == num:
            return d
    raise RuntimeError(f'找不到公司目录：{code}')


def is_known(code, d, stmt, label):
    return any(d == kd and stmt == ks and label == kl for kd, ks, kl, _ in KNOWN.get(code, []))


# ================================================================ 取数
META_COLS = {'报告日', '公告日期', '类型', '更新日期'}   # 新浪报表的元数据列，不是科目


def fetch_a(code, cfg):
    import akshare as ak
    import pandas as pd
    rows = []
    for stmt in STMTS:
        df = ak.stock_financial_report_sina(stock=cfg['sina'], symbol=stmt)
        items = [c for c in df.columns if c not in META_COLS]
        for _, r in df.iterrows():
            d = d8(r['报告日'])
            for seq, item in enumerate(items, 1):
                v = pd.to_numeric(r[item], errors='coerce')
                if v != v:
                    continue
                rows.append(dict(period_end=d, period=period_label(d), stmt=stmt, item=item,
                                 seq=seq, amount=round(float(v) / 1e8, 6)))
    # 跨源：东方财富关键科目（同一张表按报告期取，留作核对与修复依据）
    fn = {'资产负债表': ak.stock_balance_sheet_by_report_em,
          '利润表': ak.stock_profit_sheet_by_report_em,
          '现金流量表': ak.stock_cash_flow_sheet_by_report_em}
    cross = {}
    for stmt in STMTS:
        want = {em: item for st, item, em in A_KEY if st == stmt}
        df = fn[stmt](symbol=cfg['em'])
        for _, r in df.iterrows():
            d = d8(r['REPORT_DATE'])
            cell = {}
            for em, sname in want.items():
                if em not in df.columns:
                    continue
                v = pd.to_numeric(r[em], errors='coerce')
                if v == v:
                    cell[sname] = round(float(v) / 1e8, 6)
            if cell:
                cross.setdefault(d, {}).setdefault(stmt, {}).update(cell)
    return rows, cross


def fetch_hk(code, cfg):
    import akshare as ak
    import pandas as pd
    rows = []
    for stmt in STMTS:
        df = ak.stock_financial_hk_report_em(stock=cfg['em_hk'], symbol=stmt, indicator='报告期')
        seq_of = {}
        for _, r in df.iterrows():
            seq_of.setdefault(r['STD_ITEM_CODE'], len(seq_of) + 1)
            v = pd.to_numeric(r['AMOUNT'], errors='coerce')
            if v != v:
                continue
            d = d8(r['REPORT_DATE'])
            rows.append(dict(period_end=d, period=period_label(d), stmt=stmt,
                             item=str(r['STD_ITEM_NAME']), seq=seq_of[r['STD_ITEM_CODE']],
                             amount=round(float(v) / 1e8, 6)))
    return rows, {}


def rows_by(rows):
    out = {}
    for r in rows:
        out.setdefault((r['stmt'], r['period_end']), {})[r['item']] = r['amount']
    return out


def repair(code, cfg, rows, cross):
    """恒等式失败且东方财富同口径通过的报告期：用东财值替换该期关键科目。返回 (rows, 修复记录)。"""
    if cfg['market'] != 'A' or not cross:
        return rows, []
    by = rows_by(rows)
    fixed = []
    for label, stmt, lhs, rhs in IDENT[cfg['market']]:
        for (s, d), cell in sorted(by.items()):
            if s != stmt or lhs not in cell or is_known(code, d, s, label):
                continue
            if all(n in cell for n, _ in rhs) and abs(cell[lhs] - sum(c * cell[n] for n, c in rhs)) <= TOL:
                continue
            # 该期该表恒等式失败：东财同口径是否有解？
            cc = cross.get(d, {}).get(s) or {}
            if lhs not in cc or any(n not in cc for n, _ in rhs):
                continue
            if abs(cc[lhs] - sum(c * cc[n] for n, c in rhs)) > TOL:
                continue
            for item in {lhs} | {n for n, _ in rhs}:
                old = cell.get(item)
                if old is not None and item in cc and abs(old - cc[item]) > TOL:
                    for r in rows:
                        if r['stmt'] == s and r['period_end'] == d and r['item'] == item:
                            r['amount'] = cc[item]
                    by[(s, d)][item] = cc[item]
                    fixed.append(f'{d} {s} {item}：{old:,.2f} → {cc[item]:,.2f}（东财值）')
    return rows, fixed


def apply_fixes(code, rows):
    """按 FIXES 有据修复个别单元格。返回修复记录。"""
    log = []
    for d, stmt, item, new, why in FIXES.get(code, []):
        hit = [r for r in rows if r['stmt'] == stmt and r['period_end'] == d and r['item'] == item]
        if not hit:
            continue
        old = hit[0]['amount']
        if new is None:
            rows[:] = [r for r in rows if r not in hit]
            log.append(f'{d} {stmt} {item}：{old:,.2f} → 置空（{why}）')
        else:
            if isinstance(new, str):
                ref = next((r['amount'] for r in rows if r['stmt'] == stmt and r['period_end'] == d and r['item'] == new), None)
                new = ref
            hit[0]['amount'] = new
            log.append(f'{d} {stmt} {item}：{old:,.2f} → {new:,.2f}（{why}）')
    return log


def fetch(codes):
    for code in codes:
        cfg = COMPANIES[code]
        print(f'取数 {cfg["name"]}（{code}）…')
        rows, cross = (fetch_a if cfg['market'] == 'A' else fetch_hk)(code, cfg)
        rows, fixed = repair(code, cfg, rows, cross)
        fixed += apply_fixes(code, rows)
        for f in fixed:
            print('  已修复', f)
        snap = dict(fetched_at=datetime.datetime.now().astimezone().isoformat(timespec='seconds'),
                    source=('akshare stock_financial_report_sina（主）＋ stock_*_sheet_by_report_em（跨源核对与修复）'
                            if cfg['market'] == 'A' else 'akshare stock_financial_hk_report_em（indicator=报告期）'),
                    unit='亿元', repaired=fixed, rows=rows, cross=cross)
        p = company_dir(code) / 'data' / 'fin_stmt.json'
        p.parent.mkdir(exist_ok=True)
        p.write_text(json.dumps(snap, ensure_ascii=False))
        print(f'  {len(rows)} 行 × {len({(r["stmt"], r["period_end"]) for r in rows})} 个报告期×报表 → {p.relative_to(ROOT)}')


# ================================================================ 检验
def check_one(code, cfg):
    snap = json.loads((company_dir(code) / 'data' / 'fin_stmt.json').read_text())
    rows, cross, market = snap['rows'], snap.get('cross') or {}, cfg['market']
    by = rows_by(rows)
    periods = sorted({r['period_end'] for r in rows})
    print(f'\n== {cfg["name"]}（{code}）：{len(rows)} 行，{len(periods)} 个报告期，{snap["fetched_at"]} 取数')
    for stmt in STMTS:
        n = len({r['period_end'] for r in rows if r['stmt'] == stmt})
        items = len({r['item'] for r in rows if r['stmt'] == stmt})
        print(f'  {stmt}：{n} 期（{periods[0]}—{periods[-1]}），{items} 个科目')
    for f in snap.get('repaired') or []:
        print('  [已修复]', f)
    fails = 0

    # 1. 会计恒等式
    for label, stmt, lhs, rhs in IDENT[market]:
        for (s, d), cell in sorted(by.items()):
            if s != stmt or lhs not in cell or any(n not in cell for n, _ in rhs):
                continue
            lv, rv = cell[lhs], sum(c * cell[n] for n, c in rhs)
            if abs(lv - rv) > TOL:
                known = is_known(code, d, s, label)
                fails += 0 if known else 1
                print(f'  [{"已知瑕疵" if known else "失败"}] {d} {s} {label}：{lv:,.2f} vs {rv:,.2f}（差 {lv - rv:,.2f} 亿元）')

    # 2. 现金流量表的“期初”是年初余额（累计口径）：年内各期一致性与跨年衔接只做提示
    #    （各期报表各自平衡已由恒等式保证；年初数在不同期报表间被重述/取整是源数据常态，不算失败）
    b_name, e_name = {'A': ('期初现金及现金等价物余额', '期末现金及现金等价物余额'),
                      'HK': ('期初现金', '期末现金')}[market]
    cf = {d: cell for (s, d), cell in by.items() if s == '现金流量表'}
    year_begin = {}
    for d, cell in sorted(cf.items()):
        if b_name in cell:
            year_begin.setdefault(d[:4], []).append((d, cell[b_name]))
    for y, lst in sorted(year_begin.items()):
        v0 = lst[0][1]
        for d, v in lst:
            if abs(v - v0) > TOL:
                print(f'  [提示] 年初余额 {y}：{d} 期初 {v:,.2f} 与年内其他期 {v0:,.2f} 不同（重述/口径差异常见，供参考）')
    for y, lst in sorted(year_begin.items()):
        prev_end = max(((d, c[e_name]) for d, c in cf.items() if d[:4] == str(int(y) - 1) and e_name in c), default=None)
        if prev_end and abs(lst[0][1] - prev_end[1]) > TOL:
            print(f'  [提示] 跨年衔接 {y}：年初 {lst[0][1]:,.2f} vs 上年末 {prev_end[1]:,.2f}（差 {lst[0][1] - prev_end[1]:,.2f}；'
                  f'重述或口径差异常见，供参考）')

    # 3. 跨源核对（A 股）：关键科目逐报告期比对
    if market == 'A' and cross:
        n = modern_bad = 0
        for (s, d), cell in sorted(by.items()):
            for item, v in sorted(cell.items()):
                cv = cross.get(d, {}).get(s, {}).get(item)
                if cv is None:
                    continue
                n += 1
                if abs(v - cv) > CROSS_TOL:
                    level = '失败' if d >= MODERN else '差异（老报告期）'
                    if d >= MODERN:
                        fails += 1
                        modern_bad += 1
                    print(f'  [{level}] 跨源 {d} {s} {item}：新浪 {v:,.2f} vs 东财 {cv:,.2f}')
        print(f'  跨源核对（东方财富关键科目）：{n} 格可比，'
              + (f'{modern_bad} 格现代报告期不一致' if modern_bad else '2010 年起全部一致（更早差异为老准则口径）'))

    # 4. 旧文件核对（港股：此前逐项核对过业绩公告的原始报表）
    if market == 'HK':
        old = {}
        for name, stmt in [('balance', '资产负债表'), ('income', '利润表'), ('cashflow', '现金流量表')]:
            p = company_dir(code) / 'data' / f'eastmoney_hk_{name}.json'
            if not p.exists():
                continue
            for r in json.loads(p.read_text()):
                if r.get('AMOUNT') == r.get('AMOUNT'):
                    old[(stmt, d8(r['REPORT_DATE']), r['STD_ITEM_NAME'])] = r['AMOUNT'] / 1e8
        n = bad = 0
        for (s, d), cell in by.items():
            for item, v in cell.items():
                ov = old.get((s, d, item))
                if ov is None:
                    continue
                n += 1
                if abs(v - ov) > CROSS_TOL:
                    bad += 1
                    fails += 1
                    print(f'  [失败] 旧文件 {d} {s} {item}：现取 {v:,.2f} vs 原始 {ov:,.2f}')
        print(f'  旧文件核对（eastmoney_hk_*.json，已核对过公告）：{n} 格可比，{bad} 格不一致')

    for kd, ks, kl, note in KNOWN.get(code, []):
        print(f'  [已知瑕疵] {kd} {ks} {kl}：{note}')
    return fails


# ================================================================ 入库
def load(codes):
    for code in codes:
        cfg = COMPANIES[code]
        snap = json.loads((company_dir(code) / 'data' / 'fin_stmt.json').read_text())
        rows = sorted(snap['rows'], key=lambda r: (STMTS.index(r['stmt']), r['period_end'], r['seq']))
        sql = ['BEGIN;',
               f"DELETE FROM vi_fin_stmt_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '{code}');"]
        for i in range(0, len(rows), 2000):
            vals = ', '.join("('{}','{}','{}','{}',{}, {})".format(
                r['period'], r['period_end'], r['stmt'].replace("'", "''"),
                r['item'].replace("'", "''"), r['seq'], r['amount']) for r in rows[i:i + 2000])
            sql.append(f"""INSERT INTO vi_fin_stmt_base (company_id, period, period_end, stmt, item, seq, amount)
SELECT co.id, v.period, v.period_end::date, v.stmt, v.item, v.seq, v.amount
FROM (VALUES {vals}) v(period, period_end, stmt, item, seq, amount),
     vi_company_base co WHERE co.code = '{code}';""")
        sql.append('COMMIT;')
        path = ROOT / 'framework' / 'sql' / f'.fin_stmt_{code.split(".")[0]}.sql'
        path.write_text('\n'.join(sql) + '\n')
        try:
            p = subprocess.run([str(ROOT / 'psql.sh'), '-f', str(path.relative_to(ROOT))], capture_output=True, text=True)
        finally:
            path.unlink(missing_ok=True)
        if p.returncode:
            raise RuntimeError(p.stdout[-2000:] + p.stderr[-500:])
        cnt = subprocess.run([str(ROOT / 'psql.sh'), '-At', '-c',
                              f"""SELECT count(*) FROM vi_fin_stmt_base b JOIN vi_company_base co ON co.id = b.company_id
                                   WHERE co.code = '{code}'"""], capture_output=True, text=True, check=True)
        print(f'入库 {cfg["name"]}：{cnt.stdout.strip()} 行')


def main():
    args = sys.argv[1:]
    cmd = args[0] if args else 'all'
    codes = [a for a in args[1:] if a in COMPANIES] or list(COMPANIES)
    unknown = [a for a in args[1:] if a not in COMPANIES]
    if unknown:
        print('未知公司代码：', unknown, '可选：', list(COMPANIES))
        sys.exit(2)
    if cmd in ('fetch', 'all'):
        fetch(codes)
    if cmd in ('check', 'all'):
        fails = sum(check_one(c, COMPANIES[c]) for c in codes)
        print(f'\n检验结束：{fails} 项失败' + ('' if fails else '，全部通过'))
        if fails:
            sys.exit(1)
    if cmd in ('load', 'all'):
        load(codes)


if __name__ == '__main__':
    main()
