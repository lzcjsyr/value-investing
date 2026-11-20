"""「框架与后台 / 数据结构」的正文，以及 framework/docs/ 下的两份本地文档。

设计要点手写在 database_design.md；表清单、行数、“哪个页面维护哪张表”从本地库读，不手写。

  python3 struct_doc.py                # 打印 markdown
  python3 struct_doc.py --write-local  # 写《数据结构说明》《字段字典》
  python3 struct_doc.py --apply        # 写到线上「数据结构」页（原地更新，地址不变）
"""
import collections, json, pathlib, re, subprocess, sys
import spec
import database_documentation as documentation

ROOT = pathlib.Path(__file__).resolve().parent.parent
T = {t['code']: t for t in spec.TABLES}
TITLE = documentation.TITLE
POPUP = ('ChildPageModel', 'ChildPageTabModel')
COMPANY_GROUPS = ['驾驶舱', '商业模式', '预测与估值', '经营与财务', '研究维护']


def q(sql):
    out = subprocess.run([str(ROOT / 'psql.sh'), '-At', '-c', sql], capture_output=True, text=True, check=True).stdout.strip()
    return json.loads(out) if out else []


class Graph:
    def __init__(self, cat):
        self.routes = q("""SELECT json_agg(json_build_object('id', id, 'parent', "parentId", 'title', title, 'type', type,
                  'uid', "schemaUid", 'sort', sort) ORDER BY sort, id) FROM "desktopRoutes" """)
        self.model = {m['uid']: m for m in q("""SELECT json_agg(json_build_object('uid', uid, 'use', options->>'use',
                  'text', options::text)) FROM "flowModels" """)}
        self.desc = collections.defaultdict(set)      # 祖先 → 全部后代（flowModelTreePath 完整；options.parentId 不全）
        self.anc = collections.defaultdict(set)
        for a, d in q("""SELECT json_agg(json_build_array(ancestor, descendant)) FROM "flowModelTreePath" WHERE depth > 0"""):
            self.desc[a].add(d)
            self.anc[d].add(a)
        self.tables = [o['name'] for o in cat['objects'] if o['kind'] == 'r']
        self.rows = {n: int(c) for n, c in (l.split('|') for l in subprocess.run(
            [str(ROOT / 'psql.sh'), '-At', '-c', ' UNION ALL '.join(f"SELECT '{n}', count(*) FROM {n}" for n in self.tables)],
            capture_output=True, text=True, check=True).stdout.split())}

    def page(self, route):
        """页面本体（不含弹窗）里区块直接绑定的集合 → (录入表, 只读报表)。"""
        roots = [route['uid']] + [r['uid'] for r in self.routes if r['parent'] == route['id'] and r['type'] == 'tabs']
        found = set()
        for u in (u for r in roots for u in [r, *self.desc[r]] if u in self.model):
            m = self.model[u]
            if (m['use'] or '').endswith('BlockModel') and not any(self.model.get(a, {}).get('use') in POPUP for a in self.anc[u]):
                found |= set(re.findall(r'"collectionName":\s*"vi_([a-z0-9_]+)"', m['text']))
        return {c for c in found if c in T}, {c for c in found if c not in T}


def maintains(tables, reports):
    order = list(T)
    if tables:
        return '、'.join(spec.doc_name(c) for c in sorted(tables, key=order.index))
    return '只读：' + '、'.join(TITLE.get(c, c) for c in sorted(reports)) if reports else '只看（图表、汇总）'


def render(cat=None):
    cat = cat or documentation.catalogue(q)
    g = Graph(cat)
    kinds = collections.Counter('lnk' if o['name'].startswith('vi_lnk_') else o['kind'] for o in cat['objects'])
    out = [f"# 数据结构\n\n> {documentation.today()} 核验本地库：{kinds['r']} 张录入表、{kinds['lnk']} 张关联表、"
           f"{kinds['v']} 个视图、{kinds['m']} 个计算缓存。每个字段的含义见《字段字典》。",
           pathlib.Path(__file__).with_name('database_design.md').read_text().strip()]

    base = [(t, f"vi_{t['code']}_base") for t in sorted(spec.TABLES, key=lambda t: t['group'])]
    out.append('## 表清单\n\n| 分组 | 表 | 行数 | 记什么 |\n|---|---|---:|---|\n' + '\n'.join(
        f"| {t['group'].split()[-1]} | {f'`{n}`' if t['code'] in spec.CODE_FIRST else f'{t['title']} `{n}`'} | {g.rows[n]} | {t.get('role', '')} |"
        for t, n in base if n in g.rows))
    out.append(f"另有 {kinds['lnk']} 张多对多关联表 `vi_lnk_<表>_<字段>`，只存两端 id（如“假设依据↔跟踪指标”），"
               "各表有哪些写在《字段字典》每节末尾。")
    if cat['stale_collections']:
        out.append(f"待清理：NocoBase 集合目录里还有 {len(cat['stale_collections'])} 条失效登记（"
                   + '、'.join(f'`{n}`' for n in cat['stale_collections']) + '），对应的表已删除。')

    tops = [r for r in g.routes if r['parent'] is None]
    companies = [r['title'] for r in tops if any(c['title'] == '驾驶舱' for c in g.routes if c['parent'] == r['id'])]

    def pages_under(rid, path):
        for r in sorted((r for r in g.routes if r['parent'] == rid), key=lambda r: (r['sort'] or 0, r['id'])):
            if r['type'] == 'group':
                yield from pages_under(r['id'], path + [r['title']])
            elif r['type'] == 'flowPage':
                yield path, r

    # 公司菜单：五家结构相同，合并成一张表（某页不是五家都有时注明）
    merged = collections.OrderedDict()
    for top in (t for t in tops if t['title'] in companies):
        for path, r in pages_under(top['id'], []):
            m = merged.setdefault((path[0] if path else '驾驶舱', ' / '.join(path[1:] + [r['title']])), [[], set(), set()])
            tables, reports = g.page(r)
            m[0].append(top['title']); m[1] |= tables; m[2] |= reports
    rows = []
    for grp in COMPANY_GROUPS:
        for (gp, title), (cos, tables, reports) in merged.items():
            if gp == grp:
                only = '' if len(cos) == len(companies) else f"（仅{'、'.join(cos)}）"
                rows.append(f"| 公司 · {grp} | {title}{only} | {maintains(tables, reports)} |")
    for top in (t for t in tops if t['title'] not in companies):
        for path, r in pages_under(top['id'], []):
            tables, reports = g.page(r)
            if tables or reports:                     # 纯说明页不列
                rows.append(f"| {top['title']} | {' / '.join(path + [r['title']])} | {maintains(tables, reports)} |")
    out.append(f"## 哪个页面维护哪张表\n\n公司菜单五家相同（{'、'.join(companies)}）。“维护的表”指页面上原生表格直接增删改的表。"
               "\n\n| 菜单 | 页面 | 维护的表 |\n|---|---|---|\n" + '\n'.join(rows))
    return '\n\n'.join(out) + '\n'


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
    cat = documentation.catalogue(q)
    md = render(cat)
    if '--write-local' in sys.argv:
        folder = ROOT / 'framework' / 'docs'
        folder.mkdir(parents=True, exist_ok=True)
        (folder / '数据结构说明.md').write_text(md)
        (folder / '字段字典.md').write_text(documentation.field_dictionary(cat))
    if '--apply' in sys.argv:
        apply(md)
    elif '--write-local' not in sys.argv:
        print(md)
