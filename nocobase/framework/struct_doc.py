"""「框架与后台 / 数据结构」的正文：按前端菜单列出每个页面用到哪些后台 table。

全部从线上读，不手写：菜单（desktopRoutes）→ 页面里的区块、图表 SQL、JS（flowModels，含弹窗模板）
→ 提到的 vi_ 对象 → 视图依赖（information_schema.view_table_usage，递归）→ 真正存数据的 table。

  python3 struct_doc.py            # 打印 markdown
  python3 struct_doc.py --apply    # 写到线上「数据结构」页（原地更新，地址不变）
"""
import collections, datetime, json, pathlib, re, subprocess, sys
import spec

ROOT = pathlib.Path(__file__).resolve().parent.parent
T = {t['code']: t for t in spec.TABLES}
TITLE = {t['code']: t['title'] for t in spec.TABLES + spec.REPORTS}
NAME = re.compile(r'\bvi_[a-z][a-z0-9_]*')
POPUP = ('ChildPageModel', 'ChildPageTabModel')
COMPANY_GROUPS = ['驾驶舱', '商业模式', '预测与估值', '数据底稿', '跟踪']


def q(sql):
    out = subprocess.run([str(ROOT / 'psql.sh'), '-At', '-c', sql], capture_output=True, text=True, check=True).stdout.strip()
    return json.loads(out) if out else []


def load():
    routes = q("""SELECT json_agg(json_build_object('id', id, 'parent', "parentId", 'title', title, 'type', type,
                  'uid', "schemaUid", 'sort', sort, 'hidden', coalesce(hidden, false)) ORDER BY sort, id) FROM "desktopRoutes" """)
    models = q("""SELECT json_agg(json_build_object('uid', uid, 'parent', options->>'parentId', 'use', options->>'use', 'text', options::text))
                  FROM "flowModels" """)
    usage = q("""SELECT json_agg(json_build_object('model', u."modelUid", 'target', t."targetUid"))
                 FROM "flowModelTemplateUsages" u JOIN "flowModelTemplates" t ON t.uid = u."templateUid" """)
    deps = q("""SELECT json_agg(json_build_object('v', view_name, 't', table_name)) FROM information_schema.view_table_usage
                WHERE view_schema = 'public' AND view_name LIKE 'vi\\_%' AND table_name LIKE 'vi\\_%'""")
    paths = q("""SELECT json_agg(json_build_array(ancestor, descendant)) FROM "flowModelTreePath" WHERE depth > 0""")
    kinds = {r['n']: r['k'] for r in q("""SELECT json_agg(json_build_object('n', table_name, 'k', table_type))
                                          FROM information_schema.tables WHERE table_schema = 'public' AND table_name LIKE 'vi\\_%'""")}
    return routes, models, usage, deps, kinds, paths


class Graph:
    def __init__(self):
        self.routes, models, usage, deps, self.kinds, paths = load()
        self.model = {m['uid']: m for m in models}
        self.desc = collections.defaultdict(set)      # 祖先 → 全部后代（flowModelTreePath 完整；options.parentId 不全）
        self.anc = collections.defaultdict(set)
        for a, d in paths:
            self.desc[a].add(d)
            self.anc[d].add(a)
        self.template = collections.defaultdict(list)
        for u in usage:
            self.template[u['model']].append(u['target'])
        self.view_deps = collections.defaultdict(set)
        for d in deps:
            self.view_deps[d['v']].add(d['t'])
        self.rows = {n: int(c) for n, c in (l.split('|') for l in subprocess.run(
            [str(ROOT / 'psql.sh'), '-At', '-c', ' UNION ALL '.join(
                f"SELECT '{n}', count(*) FROM {n}" for n, k in self.kinds.items() if k == 'BASE TABLE')],
            capture_output=True, text=True, check=True).stdout.split())}

    def base(self, name, seen=None):
        """一个 vi_ 对象最终读到的 table（视图递归展开；函数等非表对象忽略）。"""
        if self.kinds.get(name) == 'BASE TABLE':
            return {name}
        if self.kinds.get(name) != 'VIEW':
            return set()
        seen = seen or set()
        if name in seen:
            return set()
        seen.add(name)
        return set().union(*(self.base(d, seen) for d in self.view_deps[name])) if self.view_deps[name] else set()

    def obj(self, name):
        """页面提到的 vi_ 名字 → 它代表的对象：录入表（vi_X / _base / _calc 都算 X 的 _base）、配对表、或其他视图（报表）。"""
        for suf in ('_base', '_calc', ''):
            code = name[3:len(name) - len(suf)] if suf else name[3:]
            if (not suf or name.endswith(suf)) and code in T:
                return f'vi_{code}_base'
        return name if self.kinds.get(name) else None   # 函数等非表对象不算

    def names(self, roots):
        """页面本体与弹窗分开收集用到的对象；弹窗＝ChildPage 之下，以及动作引用的弹窗模板。
        关联字段（列、表单字段）只写字段名，按 spec 换成目标表；弹窗里只换主表自己的字段（关联记录的详情弹窗不再展开）。"""
        nodes, todo, seen = [], [(u, False) for u in self.descendants(roots)], set()
        while todo:
            uid, forced = todo.pop()
            if (uid, forced) in seen or uid not in self.model:
                continue
            seen.add((uid, forced))
            m = self.model[uid]
            in_popup = forced or m['use'] in POPUP or any(self.model.get(a, {}).get('use') in POPUP for a in self.anc[uid])
            nodes.append((m, in_popup))
            for t in self.template.get(uid, []):
                todo += [(t, True)] + [(d, True) for d in self.desc[t]]
        blocks = {c for m, pop in nodes if not pop and (m['use'] or '').endswith('BlockModel')
                  for c in re.findall(r'"collectionName":\s*"vi_([a-z0-9_]+)"', m['text'])}
        page, popup = set(), set()
        for m, in_popup in nodes:
            found = set(NAME.findall(m['text']))
            for coll, path in re.findall(r'"collectionName":\s*"vi_([a-z0-9_]+)"[^{}]*?"fieldPath":\s*"([a-z0-9_]+)', m['text']):
                rel = next((f for f in T.get(coll, {}).get('fields', []) if f['name'] == path and f['kind'] in ('m2o', 'm2m')), None)
                if rel and (not in_popup or coll in blocks):
                    found.add(f"vi_{rel['target']}")
                    if rel['kind'] == 'm2m':
                        found.add(spec.lnk_table(T[coll], rel))
            (popup if in_popup else page).update(found)
        objs = lambda ns: {o for o in map(self.obj, ns) if o}
        return objs(page), objs(popup), {f'vi_{c}_base' for c in blocks if c in T}, {f'vi_{c}' for c in blocks if c not in T}

    def page(self, route):
        roots = [route['uid']] + [r['uid'] for r in self.routes if r['parent'] == route['id'] and r['type'] == 'tabs']
        page, popup, main, reports = self.names(roots)
        for b in main:                        # 多对多配对表在表单里编辑
            popup |= {spec.lnk_table(T[b[3:-5]], f) for f in spec.m2m_fields(T[b[3:-5]])}
        reads = page - main
        pop = popup - main - reads
        uses = {self.model[u]['use'] for u in self.descendants(roots)}
        js = bool(uses & {'JSBlockModel', 'ChartBlockModel'})
        return main, reads, pop, ('report' if reports and not main else js)

    def descendants(self, roots):
        return [u for r in roots for u in [r, *self.desc[r]] if u in self.model]

    def reads_of(self, view):
        """视图最终读到的录入表与配对表（递归展开，不含自己）。"""
        return {o for o in map(self.obj, self.base(view)) if o}


VIEW_NAMES = {'vi_obs_current': '数据·当前有效值', 'vi_disclosed': '公司披露数据（按期展开）',
              'vi_company_metric': '公司用到的指标', 'vi_fin_metric': '历史年度长表（论点检查用）',
              'vi_valuation_cf': '估值现金流', 'vi_sotp_segment_val': '经营分部估值计算'}


def label(t):
    if t.startswith('vi_lnk_'):
        for code, tb in T.items():
            for f in spec.m2m_fields(tb):
                if spec.lnk_table(tb, f) == t:
                    return f"{tb['title']}↔{f['title']}"
    if t.endswith('_base') and t[3:-5] in T:
        return T[t[3:-5]]['title']
    return f"〔{TITLE.get(t[3:]) or VIEW_NAMES.get(t, t)}〕"


def labels(ts):
    order = {f"vi_{c}_base": i for i, c in enumerate(T)}
    rank = lambda t: (2 if t.startswith('vi_lnk_') else 1 if not t.endswith('_base') else 0, order.get(t, 99), t)
    items = [label(t) for t in sorted(ts, key=rank)]
    # NocoBase 的 markdown 表格单元格不换行：每 4 项折一行
    return '<br>'.join('、'.join(items[i:i + 4]) for i in range(0, len(items), 4)) or '—'


def kind(main, js, title):
    if js == 'report':
        return '只读报表'
    if main and js:
        return '可视化＋表格'
    if main:
        return '表格'
    return '可视化' if js else '说明'


def er():
    lines = ['```mermaid', 'erDiagram']
    for t in spec.TABLES:
        for f in t['fields']:
            if f['kind'] == 'm2o' and f['target'] != 'company':
                lines.append(f"  {T[f['target']]['title']} ||--o{{ {t['title']} : {f['title']}")
            elif f['kind'] == 'm2m':
                lines.append(f"  {t['title']} }}o--o{{ {T[f['target']]['title']} : {f['title']}")
    return '\n'.join(lines + ['```'])


def render():
    g = Graph()
    tops = [r for r in g.routes if r['parent'] is None]
    companies = [r['title'] for r in tops if any(c['title'] == '驾驶舱' for c in g.routes if c['parent'] == r['id'])]
    used = collections.defaultdict(lambda: collections.defaultdict(set))   # 对象 → 角色 → 页面
    HEAD = '| 页面 | 类型 | 主表 | 页面还读取 | 弹窗与下拉 |\n|---|---|---|---|---|'

    def pages_under(rid, path):
        for r in sorted((r for r in g.routes if r['parent'] == rid), key=lambda r: (r['sort'] or 0, r['id'])):
            if r['type'] == 'group':
                yield from pages_under(r['id'], path + [r['title']])
            elif r['type'] == 'flowPage':
                yield path, r

    def note(where, main, reads, pop):
        for role, ts in (('主表', main), ('读取', reads), ('弹窗', pop)):
            for t in ts:
                used[t][role].add(where)
                if role == '读取' and not t.endswith('_base') and not t.startswith('vi_lnk_'):
                    for x in g.reads_of(t):          # 经视图读到的表也算
                        used[x]['读取'].add(where)

    def row(title, main, reads, pop, js):
        return f"| {title} | {kind(main, js, title)} | {labels(main)} | {labels(reads)} | {labels(pop)} |"

    out = [f"# 数据结构\n\n> 按线上菜单自动生成（`framework/struct_doc.py`，{datetime.date.today()}）。改了页面或表之后重跑：`python3 struct_doc.py --apply`。",
           """## 怎么读
- **后台 table** 是真正存数据的地方：录入表 `vi_<表>_base`，以及多对多配对表 `vi_lnk_<表>_<字段>`（写成“跟踪事项↔假设依据”）。下面用中文名，代码见最后的反查表。
- 每个页面分三栏：
  - **主表**：这页的原生表格直接展示、增删改的 table。
  - **页面还读取**：表格以外的部分（图表、看板、JS 页面、表格里显示的关联列）直接用到的表。带〔〕的是**视图或只读报表**，本身不存数据，它读哪些表见“视图与报表”一节。
  - **弹窗与下拉**：只在查看、编辑弹窗或下拉选项里用到的表，包括表单里编辑的多对多配对。
- 自动计算列（例如跟踪事项的“最新值”）读的表算在表自己身上，见反查表最后一栏，不重复记到每个页面。
- 页面类型：**表格**＝原生表格可编辑；**只读报表**＝表格但数据由视图算出，不能改；**可视化**＝图表或 JS 页面；**可视化＋表格**＝两者都有。"""]

    # 公司菜单：五家结构相同，合并成一张表（某页不是五家都有时注明）
    merged = collections.OrderedDict()
    for top in tops:
        if top['title'] not in companies:
            continue
        for path, r in pages_under(top['id'], []):
            key = (path[0] if path else '驾驶舱', ' / '.join(path[1:] + [r['title']]))
            main, reads, pop, js = g.page(r)
            m = merged.setdefault(key, {'cos': [], 'main': set(), 'reads': set(), 'pop': set(), 'js': False})
            m['cos'].append(top['title']); m['main'] |= main; m['reads'] |= reads; m['pop'] |= pop; m['js'] = m['js'] or js
    for (grp, title), m in merged.items():
        m['reads'] -= m['main']; m['pop'] -= m['main'] | m['reads']
        note('公司 / ' + (f'{grp} / {title}' if grp != '驾驶舱' else '驾驶舱'), m['main'], m['reads'], m['pop'])
    out.append(f"## 公司菜单（{'、'.join(companies)}，结构相同）")
    for grp in COMPANY_GROUPS:
        rows = [(t, m) for (gp, t), m in merged.items() if gp == grp]
        if rows:
            out.append(f"### {grp}\n\n{HEAD}")
            for title, m in rows:
                only = '' if len(m['cos']) == len(companies) else f"<br>（仅{'、'.join(m['cos'])}）"
                out.append(row(title + only, m['main'], m['reads'], m['pop'], m['js']))
            out.append('')
    for top in tops:
        if top['title'] in companies:
            continue
        rows = []
        for path, r in pages_under(top['id'], []):
            title = ' / '.join(path + [r['title']])
            main, reads, pop, js = g.page(r)
            note(f"{top['title']} / {title}", main, reads, pop)
            rows.append(row(title, main, reads, pop, js))
        out.append(f"## {top['title']}\n\n{HEAD}\n" + '\n'.join(rows) + '\n')

    # 视图与报表：页面里出现的视图，读哪些表
    views = sorted({t for t in used if not t.endswith('_base') and not t.startswith('vi_lnk_')}, key=label)
    out.append("## 视图与报表读哪些表\n\n| 视图 | 代码 | 读取的表 |\n|---|---|---|")
    out += [f"| {label(v)} | `{v}` | {labels(g.reads_of(v))} |" for v in views]

    # 反查：每张 table 在哪些页面出现
    out.append("\n## 反查：每张后台 table 用在哪里\n\n公司菜单下的页面五家同名，只算一次（省略“公司 /”）。“主表页面”为空＝没有原生表格能直接看或改它。\n")
    out.append('| table | 行数 | 主表页面 | 页面读取（页数，含经视图） | 弹窗与下拉（页数） | 自动计算列读取 |\n|---|---|---|---|---|---|')
    order = [f"vi_{c}_base" for c in T if f"vi_{c}_base" in g.kinds] + sorted(n for n in g.kinds if n.startswith('vi_lnk_'))
    short = lambda s: '<br>'.join(sorted(x.replace('公司 / ', '') for x in s)) or '—'
    for t in order:
        u = used.get(t, {})
        calc = f"vi_{t[3:-5]}_calc" if t.endswith('_base') else None
        calc_reads = labels(g.reads_of(calc) - {t}) if calc in g.kinds else '—'
        out.append(f"| {label(t)}<br>`{t}` | {g.rows.get(t, 0)} | {short(u.get('主表', ()))} | {len(u.get('读取', ()))} | {len(u.get('弹窗', ()))} | {calc_reads} |")

    out.append("\n## 表之间的关系\n\n每张表都按公司归属（公司这条线省略）。实线＝多对一字段，虚线＝多对多配对表。\n\n" + er())
    out.append("""
## 约定
- 金额：亿元；股本：亿股；每股：元。比率字段显示为百分比（数据库里存小数）。
- 每条记录都属于一家公司；同一套表同时研究多家公司，公司菜单里的页面按公司过滤。
- 数据库层：录入表 `vi_<表>_base`，计算视图 `vi_<表>_calc`，界面视图 `vi_<表>`（可编辑，写操作经触发器回到 `_base`）；只读报表只有视图；每个字段都有中文注释。""")
    return '\n'.join(out)


def apply(md):
    st = json.loads((pathlib.Path(__file__).parent / 'pages_state.json').read_text())
    uid = st['pages']['doc_structure']['pageSchemaUid']
    tree = json.loads(subprocess.run(['nb', 'api', 'flow-surfaces', 'get', '--page-schema-uid', uid, '-j'],
                                     capture_output=True, text=True, cwd=ROOT, check=True).stdout)['data']['tree']
    found = []

    def walk(x):
        if isinstance(x, dict):
            if x.get('use') == 'MarkdownBlockModel':
                found.append(x['uid'])
            for v in x.values():
                walk(v)
        elif isinstance(x, list):
            for v in x:
                walk(v)
    walk(tree)
    assert len(found) == 1, found
    p = subprocess.run(['nb', 'api', 'flow-surfaces', 'configure', '--body',
                        json.dumps({'target': {'uid': found[0]}, 'changes': {'content': md}}, ensure_ascii=False), '-j'],
                       capture_output=True, text=True, cwd=ROOT)
    if p.returncode:
        sys.exit(p.stdout[-1500:] + p.stderr[-500:])
    print('已更新「数据结构」', found[0])


if __name__ == '__main__':
    md = render()
    apply(md) if '--apply' in sys.argv else print(md)
