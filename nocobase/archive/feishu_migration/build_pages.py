"""为每个 cj_* 集合生成 NocoBase 页面（apply-blueprint）。

用法：python3 build_pages.py [code ...]   不带参数则按 spec.TABLES 顺序全部生成。
表格列沿用飞书各表第一个视图（“日常”）的可见列；新增/编辑表单只放输入字段与关联字段（计算列只读不进表单）；
详情弹窗展示全部字段并分组。菜单分组 routeId 记录在 pages_state.json，后续页面复用，避免重复建组。
"""
import json, subprocess, sys, pathlib
import spec

HERE = pathlib.Path(__file__).resolve().parent
STATE = HERE / 'pages_state.json'
TB = spec.table_by_code()
VIEWS = json.load(open(HERE / 'feishu_export' / 'views.json'))

GROUP_ICON = {'0 驾驶舱': 'DashboardOutlined', '1 研究': 'ExperimentOutlined', '2 估值': 'CalculatorOutlined',
              '3 跟踪': 'RadarChartOutlined', '4 后台': 'SettingOutlined', '5 归档': 'InboxOutlined'}
PAGE_ICON = 'TableOutlined'


def state():
    return json.loads(STATE.read_text()) if STATE.exists() else {'groups': {}, 'pages': {}}


def links_of(code):
    out = [(l[1], l[2], l[3], l[4]) for l in spec.LINKS if l[0] == code]
    out += [(l[5][0], l[5][1], l[0], 'm2m') for l in spec.LINKS if l[3] == code and l[5]]
    return out  # (飞书名, 英文名, 目标code, 类型)


def cn_to_en(code):
    m = {cn: en for cn, en, _ in spec.INPUTS.get(code, []) + spec.CALC.get(code, [])}
    m.update({cn: en for cn, en, _, _ in links_of(code)})
    return m


def rel(en, target):
    return {'field': en, 'titleField': spec.TITLE_FIELD[target]}


_META = {}


def live_fields(coll):
    if coll not in _META:
        p = subprocess.run(['nb', 'api', 'data-modeling', 'collections', 'get', '--filter-by-tk', coll,
                            '--appends', 'fields', '-j'], capture_output=True, text=True, cwd=HERE.parent, check=True)
        _META[coll] = json.loads(p.stdout)['data']['fields']
    return _META[coll]


def default_field_groups(code):
    """后端生成的弹窗（详情/编辑）字段超过 10 个时需要集合级分组：输入 / 计算结果 / 系统。"""
    scalar = [f['name'] for f in live_fields(f'cj_{code}')
              if f.get('interface') and f['interface'] not in ('id', 'm2m', 'o2m', 'o2o', 'obo', 'oho')]
    if len(scalar) <= 10:
        return None
    inputs = {e for _, e, _ in spec.INPUTS.get(code, [])}
    calc = {e for _, e, _ in spec.CALC.get(code, [])}
    m2o = {f['name'] for f in live_fields(f'cj_{code}') if f.get('interface') == 'm2o'}
    return grouped([('基本信息', [f for f in scalar if f in inputs]),
                    ('关联', [f for f in scalar if f in m2o]),
                    ('计算结果（只读）', [f for f in scalar if f in calc]),
                    ('系统', [f for f in scalar if f not in inputs and f not in calc and f not in m2o])])['fieldGroups']


def relation_field(en, target):
    tf = spec.TITLE_FIELD[target]
    shown = [tf] + [e for _, e, _ in spec.INPUTS.get(target, []) if e != tf][:5]
    return {'field': en, 'titleField': tf, 'popup': {'title': TB[target][1], 'blocks': [
        {'type': 'details', 'resource': {'binding': 'currentRecord', 'collectionName': f'cj_{target}'}, 'fields': shown}]}}


def grouped(groups):
    groups = [(t, f) for t, f in groups if f]
    total = sum(len(f) for _, f in groups)
    if total <= 10:
        return {'fields': [x for _, f in groups for x in f]}
    out = []
    for title, fields in groups:  # 单组超过 10 个字段时再按 10 个一段切开，便于阅读
        for i in range(0, len(fields), 10):
            n = (len(fields) + 9) // 10
            out.append({'title': title if n == 1 else f'{title}（{i // 10 + 1}/{n}）', 'fields': fields[i:i + 10]})
    return {'fieldGroups': out}


def blueprint(code, group_route_id):
    tid, title, group = TB[code]
    coll = f'cj_{code}'
    m = cn_to_en(code)
    links = links_of(code)
    link_en = {en: target for _, en, target, _ in links}
    visible = [m[cn] for cn in VIEWS[tid]['visible']['visible_fields'] if cn in m]
    table_fields = [relation_field(f, link_en[f]) if f in link_en else f for f in visible]
    inputs = [en for _, en, _ in spec.INPUTS.get(code, [])]
    rels = [rel(en, t) for _, en, t, _ in links]
    calc = [en for _, en, _ in spec.CALC.get(code, [])]
    form = grouped([('基本信息', inputs), ('关联', rels)])
    detail = grouped([('基本信息', inputs), ('关联', rels), ('计算结果（只读）', calc)])

    involved = {coll: title} | {f'cj_{t}': TB[t][1] for _, _, t, _ in links}
    defaults = {'collections': {c: {'popups': {
        'view': {'name': f'{t}·详情', 'description': f'查看一条「{t}」记录'},
        'addNew': {'name': f'{t}·新增', 'description': f'新增一条「{t}」记录（只含输入字段）'},
        'edit': {'name': f'{t}·编辑', 'description': f'编辑一条「{t}」记录（只含输入字段）'},
    }} for c, t in involved.items()}}
    for c in involved:
        fg = default_field_groups(c[3:])
        if fg:
            defaults['collections'][c]['fieldGroups'] = fg

    nav = {'item': {'title': title, 'icon': PAGE_ICON}}
    nav['group'] = {'routeId': group_route_id} if group_route_id else {'title': group, 'icon': GROUP_ICON[group]}
    return {
        'version': '1', 'mode': 'create', 'navigation': nav,
        'page': {'title': title, 'documentTitle': f'长江电力 · {title}'},
        'defaults': defaults,
        'tabs': [{'title': title, 'blocks': [{
            'key': 'main', 'type': 'table', 'collection': coll,
            'fields': table_fields,
            'settings': {'pageSize': 50, 'sorting': [{'field': 'id', 'direction': 'asc'}]},
            'actions': ['filter', 'refresh',
                        {'type': 'addNew', 'popup': {'title': f'新增 · {title}', 'blocks': [
                            {'type': 'createForm', 'resource': {'collectionName': coll}, **form, 'actions': ['submit']}]}},
                        'bulkDelete'],
            'recordActions': [
                'view',  # 详情弹窗由后端按集合级 fieldGroups 生成（全部字段分组展示）
                {'type': 'edit', 'popup': {'title': f'编辑 · {title}', 'blocks': [
                    {'type': 'editForm', **form, 'actions': ['submit']}]}},
                'delete'],
        }]}],
    }


def apply(body, name):
    path = HERE / 'blueprints' / f'{name}.json'
    path.parent.mkdir(exist_ok=True)
    path.write_text(json.dumps(body, ensure_ascii=False, indent=1))
    p = subprocess.run(['nb', 'api', 'flow-surfaces', 'apply-blueprint', '--body-file', str(path), '-j'],
                       capture_output=True, text=True, cwd=HERE.parent)
    try:
        return json.loads(p.stdout), p
    except json.JSONDecodeError:
        return None, p


def find_route(group_title, page_title):
    p = subprocess.run(['nb', 'api', 'resource', 'list', '--resource', 'desktopRoutes:listAccessible',
                        '--no-paginate', '-j'], capture_output=True, text=True, cwd=HERE.parent, check=True)
    for g in json.loads(p.stdout)['data']:
        if g.get('type') == 'group' and g.get('title') == group_title:
            for c in g.get('children') or []:
                if c.get('title') == page_title:
                    return g, c
    raise RuntimeError(f'路由未找到：{group_title}/{page_title}')


def build(code):
    st = state()
    _, title, group = TB[code]
    if code in st['pages']:
        print(f'{title}: 已存在，跳过'); return True
    body = blueprint(code, st['groups'].get(group))
    res, p = apply(body, code)
    if not res or p.returncode:
        print(f'{title}: 失败\n{p.stdout[-3000:]}\n{p.stderr[-2000:]}'); return False
    grp, page = find_route(group, title)
    st['groups'][group] = grp['id']
    st['pages'][code] = {'routeId': page['id'], 'pageSchemaUid': page.get('schemaUid')}
    STATE.write_text(json.dumps(st, ensure_ascii=False, indent=1))
    print(f'{title}: OK {st["pages"][code]} group={st["groups"].get(group)}')
    return True


if __name__ == '__main__':
    codes = sys.argv[1:] or [c for _, c, _, _ in spec.TABLES]
    for c in codes:
        if not build(c):
            sys.exit(1)
