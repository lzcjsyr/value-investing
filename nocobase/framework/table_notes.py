"""前端每个表格区块顶上的说明栏，分四条写：
① 功能定位  ② 数据库基本表  ③ 引用的前端表格  ④ 被哪些前端表格引用

全部从本地库读，不手写清单：desktopRoutes＋flowModels 找出每个表格区块和它所在的页面；
② 只写这张表自己的基础表；③④ 用浏览器里看得到的名字写“哪一列 → 哪个页面”：关联列取外键（spec 与数据库一致），
自动列的来源见 CALC_FROM（对照 02_calc.sql 逐列核对）。说明栏会把换行显示成换行；正文里不用半角冒号（会被界面翻译当成命名空间吃掉）。

  python3 table_notes.py               # 逐个打印将要写入的说明，不改页面
  python3 table_notes.py --apply       # 写入全部表格区块（原地更新，地址不变）
  python3 table_notes.py --apply 腾讯音乐  # 只写这个顶层菜单下的表格
"""
import collections, json, pathlib, re, subprocess, sys
import spec

ROOT = pathlib.Path(__file__).resolve().parent.parent
T = {t['code']: t for t in spec.TABLES}
TITLE = {t['code']: t['title'] for t in spec.TABLES + spec.REPORTS}
NAME = re.compile(r'\bvi_[a-z][a-z0-9_]*')
POPUP = ('ChildPageModel', 'ChildPageTabModel')
SHARED = ('宏观数据', '框架与后台')
SP = '　'                                   # 全角空格：界面会压掉半角空格，全角的能保留缩进

LNK = {spec.lnk_table(t, f): (t['code'], f) for t in spec.TABLES for f in spec.m2m_fields(t)}
CODES = list(T) + [r['code'] for r in spec.REPORTS]
# 不对应前端表格的内部视图：缓存和长表算作它所属的那张表；其余是纯辅助视图，展开依赖时直接穿过
HELPER_OWNER = {'fin_history_cache': 'fin_history', 'fin_metric': 'fin_history', 'obs_current': 'observation',
                'stmt_cache': 'fin_stmt', 'valuation_cf': 'valuation'}


def q(sql):
    out = subprocess.run([str(ROOT / 'psql.sh'), '-At', '-c', sql], capture_output=True, text=True, check=True).stdout.strip()
    return json.loads(out) if out else []


class Live:
    """线上页面与数据库依赖。"""

    def __init__(self):
        routes = q("""SELECT json_agg(json_build_object('id',id,'parent',"parentId",'title',title,'type',type,'uid',"schemaUid")) FROM "desktopRoutes" """)
        self.route = {r['id']: r for r in routes}
        by_uid = {r['uid']: r for r in routes if r['uid']}
        models = {m['uid']: m for m in q("""SELECT json_agg(json_build_object('uid',uid,'use',options->>'use','o',options)) FROM "flowModels" """)}
        anc = collections.defaultdict(list)
        for a, d, depth in q("""SELECT json_agg(json_build_array(ancestor, descendant, depth)) FROM "flowModelTreePath" WHERE depth > 0"""):
            anc[d].append((depth, a))
        self.blocks, self.charts = [], collections.defaultdict(set)    # charts：视图 → 用到它的（顶层, 页面）
        for uid, m in models.items():
            ancs = [a for _, a in sorted(anc[uid])]
            tab = next((by_uid[a] for a in ancs if a in by_uid), None)
            if not tab or any(models.get(a, {}).get('use') in POPUP for a in ancs):
                continue
            top, page = self.where(tab)
            if m['use'] == 'TableBlockModel':
                sp = m['o'].get('stepParams', {})
                self.blocks.append({'uid': uid, 'top': top, 'page': page, 'tab': tab['title'],
                                    'key': sp.get('__flowSurfaceMeta', {}).get('declaredKey', '').split('.')[-1],
                                    'code': sp['resourceSettings']['init']['collectionName'][3:],
                                    'old': sp.get('cardSettings', {}).get('titleDescription', {}).get('description')})
            elif m['use'] in ('JSBlockModel', 'ChartBlockModel'):
                for n in set(NAME.findall(json.dumps(m['o'], ensure_ascii=False))):
                    self.charts[n[3:]].add((top, page))
        self.blocks.sort(key=lambda b: (b['top'], b['page'], b['tab']))
        self.companies = [r['title'] for r in routes if r['parent'] is None and r['title'] not in SHARED
                          and any(c['parent'] == r['id'] and c['title'] == '驾驶舱' for c in routes)]
        self.tables = collections.defaultdict(set)                     # 表 → 有它表格的（顶层, 页面）
        self.spots = collections.defaultdict(set)                      # 表 → （顶层, 页面或“页面 / 标签”）
        codes_on = collections.defaultdict(set)
        for b in self.blocks:
            self.tables[b['code']].add((b['top'], b['page']))
            codes_on[(b['top'], b['page'])].add(b['code'])
        for b in self.blocks:                  # 一页里放了几张不同的表时写到标签，否则写到页面
            spot = f"{b['page']} / {b['tab']}" if len(codes_on[(b['top'], b['page'])]) > 1 else b['page']
            self.spots[b['code']].add((b['top'], spot))
        self.load_deps()

    def where(self, tab):
        """标签路由 → (顶层菜单, 顶层以下到页面的路径)。"""
        chain, r = [], self.route.get(tab['parent']) if tab['type'] == 'tabs' else tab
        while r:
            chain.append(r['title'])
            r = self.route.get(r['parent'])
        chain.reverse()
        return chain[0], ' / '.join(chain[1:])

    def load_deps(self):
        self.kinds = {r['n']: r['k'] for r in q("""SELECT json_agg(json_build_object('n',relname,'k',relkind)) FROM pg_class
            WHERE relnamespace='public'::regnamespace AND relname LIKE 'vi\\_%' AND relkind IN ('r','v','m')""")}
        self.deps = collections.defaultdict(set)
        for r in q("""SELECT json_agg(json_build_object('v',v,'t',t)) FROM (SELECT DISTINCT s.relname v, ref.relname t
                FROM pg_rewrite rw JOIN pg_class s ON s.oid=rw.ev_class
                JOIN pg_depend d ON d.objid=rw.oid AND d.classid='pg_rewrite'::regclass
                JOIN pg_class ref ON ref.oid=d.refobjid AND d.refclassid='pg_class'::regclass
                WHERE s.relname LIKE 'vi\\_%' AND ref.relname LIKE 'vi\\_%' AND s.oid<>ref.oid) x"""):
            self.deps[r['v']].add(r['t'])
        # 视图调用的 SQL 函数，函数体里的表引用 pg_depend 不展开（例如 vi_stmt_series 读财务报表）；函数再调函数也算
        funcs = {r['n']: r['b'] for r in q("""SELECT json_agg(json_build_object('n',proname,'b',pg_get_functiondef(oid))) FROM pg_proc
            WHERE pronamespace='public'::regnamespace AND proname LIKE 'vi\\_%' AND prokind='f'""")}

        def fn_tables(f, seen):
            if f in seen or f not in funcs:
                return set()
            seen.add(f)
            names = set(NAME.findall(funcs[f]))
            return {n for n in names if n in self.kinds}.union(*(fn_tables(n, seen) for n in names if n in funcs))
        for r in q("""SELECT json_agg(json_build_object('v',c.relname,'f',p.proname)) FROM (SELECT DISTINCT rw.ev_class c, d.refobjid p
                FROM pg_rewrite rw JOIN pg_depend d ON d.objid=rw.oid AND d.classid='pg_rewrite'::regclass AND d.refclassid='pg_proc'::regclass) x
                JOIN pg_class c ON c.oid=x.c JOIN pg_proc p ON p.oid=x.p WHERE c.relname LIKE 'vi\\_%'"""):
            self.deps[r['v']] |= fn_tables(r['f'], set()) - {r['v']}

    def direct(self, code):
        """一张前端表的视图直接读到哪些前端表：沿依赖展开，穿过自己的 _calc 和纯辅助视图，碰到别的前端表就停。"""
        found, todo, seen = set(), [f'vi_{code}'], set()
        while todo:
            n = todo.pop()
            if n in seen:
                continue
            seen.add(n)
            for d in self.deps[n]:
                o = obj(d)
                if o is None or o == code:
                    todo.append(d)
                else:
                    found.add(o)
        return found - {'company'}

    def base(self, name, seen=None):
        """一个视图最终读到的基本表（递归展开）。"""
        seen = set() if seen is None else seen
        if name in seen:
            return set()
        seen.add(name)
        if self.kinds.get(name) == 'r':
            return {name}
        return set().union(*(self.base(d, seen) for d in self.deps[name]))


def obj(name):
    """数据库对象 → 它属于哪张前端表（vi_X、vi_X_calc、vi_X_base、多对多关联表、缓存）；纯辅助视图返回 None。"""
    if name in LNK:
        return LNK[name][0]
    c = name[3:]
    for suffix in ('_base', '_calc'):
        if c.endswith(suffix) and c[:-len(suffix)] in CODES:
            return c[:-len(suffix)]
    return c if c in CODES else HELPER_OWNER.get(c)


# 自动计算列从哪张表格算来（对照 sql/02_calc.sql 各 _calc 视图逐列核对；只列读了别的表格的列）
CALC_FROM = {
    'company': [(['最新股价（元）', '最新股价（原币）', '最新股价日期', '折算汇率'], ['metric']),
                (['用到的宏观数据'], ['metric', 'judgment', 'risk', 'model'])],
    'event': [(['侧面数', '最近日期'], ['fact'])],
    'moat': [(['最近年度', '最近值', '自动检查结果'], ['@history']), (['已辩论的论点数', '论点裁决'], ['thesis'])],
    'thesis': [(['最近年度', '最近值', '自动检查结果'], ['@history']), (['假设依据（状态）'], ['judgment'])],
    'risk': [(['相关论点裁决'], ['thesis'])],
    'metric': [(['最新值', '最新统计时间', '趋势', '数据条数', '状态'], ['@own', '@stmt']),
               (['重点跟踪'], ['judgment', 'risk']), (['使用公司'], ['company', 'model', 'judgment', 'risk'])],
    'observation': [(['单位', '指标性质', '来源方式'], ['metric'])],
    'model': [(['最新无风险利率观察', '最新观察日期'], ['metric'])],
    'scenario': [(['实际折现率'], ['model'])],
    'sotp_item': [(['金额·取用（亿元）'], ['metric'])],
    'sotp_segment': [(['采用折现率', '分部价值（亿元）'], ['model', 'scenario'])],
    'forecast': [(['期初带息负债（亿元）', '利息（亿元）'], ['model'])],
    'fin_forecast': [(['营业收入（亿元）', '净利润（亿元）', '期末净现金（亿元）'], ['model', '@history'])],
    'trial': [(['基准每股价值（元）', '试验后每股价值（元）'], ['forecast', 'model'])],
    'collector': [(['最近采集', '最近观察日', '健康状态'], ['raw_capture', 'observation'])],
    'collect_run': [(['数据源数', '新入库', '结果'], ['raw_capture'])],
    'raw_capture': [(['解析数值', '入库判断'], ['collector', 'observation'])],
}
# 不是一张表格、但浏览器里能找到的来源
SOURCE_TEXT = {'@own': '本表点“查看”看到的逐期数据', '@stmt': '数据底稿 / 财务报表（报表原值）',
               '@history': '定量指标按年汇总（财务模型里的历史年度）'}


def owner(table):
    """基本表 → 它在前端属于哪张表：vi_X_base → X；多对多关联表 → 定义这个关联的表。"""
    return LNK[table][0] if table in LNK else table[3:-5]


def table_label(table):
    if table in LNK:
        code, f = LNK[table]
        return f"{TITLE[code]}↔{f['title']}"
    return TITLE.get(table[3:-5], table)


class Notes:
    def __init__(self, live=None):
        self.live = live or Live()
        # 计算读取：视图直接读到的前端表（不含经别的前端表间接读到的，不含公司）
        self.calc = {c: self.live.direct(c) for c in CODES if f'vi_{c}' in self.live.kinds}
        self.fk = {c: [f['target'] for f in T[c]['fields'] if f['kind'] in ('m2o', 'm2m') and f['target'] != 'company']
                   for c in T}
        self.metrics = scope_metrics()
        self.counts = company_counts()

    def place(self, code, top):
        """这张表在前端哪里能看到：优先同一顶层菜单的表格，其次共用菜单，再次别家公司的菜单，最后页面图表。"""
        if code == 'observation' and top in self.live.companies:     # 公司菜单里逐期数据不单列表格，在指标详情里看和录入
            return '本公司各指标表格点“查看”，看逐期数据并录入'
        tables = self.live.tables.get(code, set())
        here = sorted(p for t, p in tables if t == top)
        if here:                                     # 公司菜单里省掉公司名；共用菜单写全，免得“采集配置〔采集配置〕”
            return '、'.join(f'{top} / {p}' if top in SHARED else p for p in here)
        shared = sorted(f'{t} / {p}' for t, p in tables if t in SHARED)
        if shared:
            return '、'.join(shared)
        if tables:                                   # 只在别的公司菜单里有：本公司有没有这类记录、别家在哪
            by_page = collections.defaultdict(list)
            for c in self.live.companies:
                for p in sorted(p for t, p in tables if t == c):
                    by_page[p].append(c)
            where = '，'.join(('各公司' if len(cs) == len(self.live.companies) else '、'.join(cs)) + f'在 {p}'
                              for p, cs in by_page.items())
            if top not in self.live.companies:
                return where
            n = self.counts.get(code, {}).get(top, 0)
            return (f'本公司有 {n} 条记录但没有表格页' if n else '本公司没有这类记录') + f'；{where}'
        charts = self.live.charts.get(code, set())
        pages = sorted({p.split(' / ')[-1] for t, p in charts if t == top})
        if pages:
            return '、'.join(pages) + ' 页的图表'
        pages = sorted({p.split(' / ')[-1] for t, p in charts})
        return '各公司的 ' + '、'.join(pages) + ' 页图表' if pages else '没有前端页面'

    def names(self, codes, top):
        return '、'.join(f"{spec.doc_name(c)}〔{self.place(c, top)}〕" for c in sorted(set(codes), key=CODES.index))

    def text(self, b):
        code, top = b['code'], b['top']
        t = T.get(code)
        lines = ['① 功能定位：' + self.purpose(b)]

        # ② 数据库基本表：只写这张表自己的基础表（关联表、计算读到的表不列，表间关系看 ③④）
        if t:
            lines.append(f'② 数据库基本表：vi_{code}_base（页面上新增、修改都写回这里）')
        else:
            lines.append(f'② 数据库基本表：无，vi_{code} 是只读视图，由其他表算出')

        # ③④ 用浏览器里看得到的名字写：哪一列 → 哪个页面；只列本公司菜单或共用菜单里有的表格，图表与数据库对象不列
        if code == 'company':
            lines += ['③ 这张表格引用了哪些表格：'] + self.refs_out(code, top)
            lines.append('④ 哪些表格引用了这张表格：所有研究表格都有「公司」列，记录按公司归属到这里（不逐一列出）')
            return '\n'.join(lines)
        out, inn = self.refs_out(code, top), self.refs_in(code, top)
        lines.append('③ 这张表格引用了哪些表格：' + ('' if out else '无'))
        lines += out
        lines.append('④ 哪些表格引用了这张表格：' + ('' if inn else '无'))
        lines += inn
        return '\n'.join(lines)

    def where(self, code, top):
        """浏览器里能看到这张表格的页面（菜单路径）；看不到时返回 None。"""
        tables = self.live.spots.get(code, set())
        here = sorted({p for t, p in tables if t == top})
        if here:
            return '、'.join(f'{top} / {p}' if top in SHARED else p for p in here)
        shared = sorted({f'{t} / {p}' for t, p in tables if t in SHARED})
        if shared:
            return '、'.join(shared)
        if top in SHARED and tables:              # 从共用菜单看公司菜单里的表格
            cos = {t for t, _ in tables}
            pages = sorted({p for _, p in tables})
            who = '各公司' if cos >= set(self.live.companies) else '、'.join(c for c in self.live.companies if c in cos)
            return '、'.join(f'{who} / {p}' for p in pages)
        return None

    def refs_out(self, code, top):
        """③：本表哪些列选的是别的表格（关联列），哪些列是从别的表格自动算来的（自动列）。"""
        rows = []
        for f in T[code]['fields'] if code in T else []:
            if f['kind'] not in ('m2o', 'm2m') or f['target'] == 'company':
                continue
            w = self.where(f['target'], top)
            rows.append(f"{SP}「{f['title']}」列 → {w or '本公司菜单里没有这张表格'}")
        for cols, src in CALC_FROM.get(code, []):
            places = [x for x in (SOURCE_TEXT.get(c) or self.where(c, top) for c in src) if x]
            if places:
                rows.append(f"{SP}{''.join(f'「{c}」' for c in cols)}列（自动）← {'、'.join(dict.fromkeys(places))}")
        return rows

    def refs_in(self, code, top):
        """④：哪些表格的哪一列引用了本表（关联列，或从本表自动算来的列）。"""
        rows = []
        for t in spec.TABLES:
            for f in t['fields']:
                if f['kind'] in ('m2o', 'm2m') and f['target'] == code and t['code'] != code:
                    w = self.where(t['code'], top)
                    if w:
                        rows.append(f"{SP}{w} 的「{f['title']}」列")
        for t, items in CALC_FROM.items():
            if t == code:
                continue
            for cols, src in items:
                if code in src:
                    w = self.where(t, top)
                    if w:
                        rows.append(f"{SP}{w} 的{''.join(f'「{c}」' for c in cols)}列（自动）")
        return list(dict.fromkeys(rows))

    def purpose(self, b):
        code, key, top = b['code'], b['key'], b['top']
        role = (T.get(code) or next(r for r in spec.REPORTS if r['code'] == code))['role'].rstrip('。')
        m = self.metrics.get(top, {})
        listed = lambda k: '、'.join(m[k]) if len(m.get(k, [])) <= 8 else f"{len(m[k])} 个，如 {'、'.join(m[k][:5])} 等"
        each = '每个指标一行，“趋势”是主口径最近 12 期的小折线（主口径不足两期时用数据最多的口径）；点“查看”看逐期数据并录入新一期。'
        if code == 'metric':
            if key == 'disclosed':
                return ((f"本公司按期披露的经营指标（量、价、订单、用户等），现有 {listed('disclosed')}。" if m.get('disclosed') else
                         '本公司按期披露的经营指标（量、价、订单、用户等）；目前还没有这类指标，标签为空。') + each)
            if key == 'auto':
                return ((f"自动采集的高频经营指标，现有 {listed('auto')}。" if m.get('auto') else
                         '自动采集的高频经营指标（如水位、流量）；本公司目前没有这类指标，标签为空。')
                        + each + '股价、利率、汇率、商品价格在“宏观与市场”标签。')
            if key == 'finance':
                return (f"本公司的全部财务指标，共 {len(m.get('finance', []))} 个：报表里有的科目与比率（收入、利润、现金流、毛利率等）"
                        "按报表公式从财务报表实时算，不另存；报表里没有的（分部收入、公司口径的现金与调整后利润、股息回购等）在这里录入。"
                        + each + '“模型字段”有值的进财务模型，“重点跟踪”列出盯着它的假设依据和风险。')
            if key == 'market':
                return (f"本公司用到的宏观与市场数据，现有 {listed('market')}，多为自动采集。" + each
                        + '宏观指标各公司共用，新建与采集配置在“宏观数据”。')
            if top == '宏观数据':
                return f"各公司共用的宏观指标（利率、汇率、商品价格），现有 {listed('macro')}。点开一行看趋势与逐期数据。"
        if code == 'observation':
            if top == '宏观数据':
                return '宏观指标（利率、汇率、商品价格）的逐期数据，各公司共用；大多由自动采集写入。'
            if top == '框架与后台':
                return '全部指标的逐期数据，不分公司、不分宏观，用于排查采集与录入；日常按公司看“数据底稿”。'
        if code == 'collector' and top == '宏观数据':
            return f"宏观指标的自动采集配置，现有 {listed('macro_collector')}。全部采集配置在“框架与后台 / 采集”。"
        if code == 'collector':
            return '全部自动采集配置（股价、利率、汇率、水位、商品价格）：从哪里取数、写进哪个指标、允许滞后几天、最近一次自检结果。'
        if code == 'fin_forecast':
            return '腾讯音乐的逐年财务预测：输入收入、毛利率、费用率、税率、现金转化、资本开支和股东回报，利润、每股收益、期末净现金自动算。收入与业务估值分开存，不自动同步，改一边要核对另一边。'
        if code == 'model' and top == '腾讯音乐':
            return '腾讯音乐这版估值的基本参数（股本、分部加总基准日、核心调整等）；估值方法只用分部加总。'
        if code == 'scenario' and top == '腾讯音乐':
            return '乐观、基准、悲观三个情景；腾讯音乐的情景通过“适用情景”覆盖业务估值和资产项。'
        return role + '。'


def scope_metrics():
    """几个按指标子集过滤的标签里，各公司现有哪些指标（与 build_pages / data_domains 的数据范围一致）。"""
    out = collections.defaultdict(dict)
    for name, kind, items in [tuple(r) for r in q("""SELECT json_agg(json_build_array(n, k, v)) FROM (
        SELECT c.name n, 'auto' k, json_agg(DISTINCT m.name) v FROM vi_company_base c JOIN vi_metric m
          ON m.source_kind='自动采集' AND m.category IN ('经营','水文')
         AND (m.company_id=c.id OR m.used_by_codes LIKE '%,'||c.code||',%') GROUP BY c.name
        UNION ALL SELECT c.name, 'disclosed', json_agg(DISTINCT m.name) FROM vi_company_base c JOIN vi_metric m
          ON m.company_id=c.id AND m.category='经营' AND m.source_kind IS DISTINCT FROM '自动采集' GROUP BY c.name
        UNION ALL SELECT c.name, 'finance', json_agg(DISTINCT m.name) FROM vi_company_base c JOIN vi_metric m
          ON m.company_id=c.id AND m.category='财务' GROUP BY c.name
        UNION ALL SELECT c.name, 'market', json_agg(DISTINCT m.name) FROM vi_company_base c JOIN vi_metric m
          ON m.category IN ('宏观','利率','汇率','商品','行情','其他')
         AND (m.company_id=c.id OR m.used_by_codes LIKE '%,'||c.code||',%') GROUP BY c.name
        UNION ALL SELECT '宏观数据', 'macro', json_agg(name ORDER BY id) FROM vi_metric WHERE scope='宏观'
        UNION ALL SELECT '宏观数据', 'macro_collector', json_agg(c.name ORDER BY c.id) FROM vi_collector c
          JOIN vi_metric m ON m.id=c.metric_id AND m.scope='宏观') x""")]:
        out[name][kind] = sorted(items) if kind not in ('macro', 'macro_collector') else items
    return out


def company_counts():
    """每张表各公司有多少条记录：直接按公司字段，或经估值模型、指标归属公司。"""
    parts = []
    for c, t in T.items():
        fields = {f['name'] for f in spec.m2o_fields(t)}
        if 'company' in fields:
            join, cid = '', 'x.company_id'
        elif 'model' in fields:
            join, cid = 'JOIN vi_model_base m ON m.id = x.model_id', 'm.company_id'
        elif 'metric' in fields:
            join, cid = 'JOIN vi_metric_base m ON m.id = x.metric_id', 'm.company_id'
        else:
            continue
        parts.append(f"SELECT '{c}' c, co.name n, count(*) k FROM vi_{c}_base x {join} JOIN vi_company_base co ON co.id = {cid} GROUP BY co.name")
    out = collections.defaultdict(dict)
    for c, n, k in q(f"SELECT json_agg(json_build_array(c, n, k)) FROM ({' UNION ALL '.join(parts)}) x"):
        out[c][n] = k
    return out


def apply(notes, tops=None):
    for b in notes.live.blocks:
        if tops and b['top'] not in tops:
            continue
        text = notes.text(b)
        if text == b['old']:
            continue
        p = subprocess.run(['nb', 'api', 'flow-surfaces', 'configure', '--target', json.dumps({'uid': b['uid']}),
                            '--changes', json.dumps({'title': '', 'description': text}, ensure_ascii=False), '-j'],
                           capture_output=True, text=True, cwd=ROOT)
        if p.returncode:
            sys.exit(f"{b['top']} / {b['page']} / {b['tab']} 写入失败：{p.stdout[-800:]}{p.stderr[-300:]}")
        print('OK', b['top'], '/', b['page'], '/', b['tab'])


if __name__ == '__main__':
    notes = Notes()
    tops = {a for a in sys.argv[1:] if not a.startswith('--')}
    if '--apply' in sys.argv:
        apply(notes, tops)
    else:
        for b in notes.live.blocks:
            if not tops or b['top'] in tops:
                print(f"### {b['top']} / {b['page']} / {b['tab']}  ({b['uid']})\n{notes.text(b)}\n")
