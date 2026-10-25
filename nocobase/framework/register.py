"""把 vi_ 界面视图注册为 NocoBase 集合，并建立关联字段。

  python3 register.py            注册集合与字段（不含字段说明）、关联
  python3 register.py --describe 给所有字段写入说明（页面生成之后再执行：UI 生成器会把字段说明当作表单行为指令）

关联字段必须带 options.source，否则 NocoBase 重启时会在目标视图主键加载前绑定关联而无法启动（见 README）。
"""
import json, subprocess, pathlib, sys
import spec

HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parent
T = spec.all_tables()
COLORS = ['blue', 'green', 'orange', 'purple', 'cyan', 'gold', 'magenta', 'geekblue', 'lime', 'volcano', 'red', 'default']
STATUS_COLOR = {'成立': 'green', '观察': 'gold', '存疑': 'orange', '证伪': 'red', '通过': 'green', '提示': 'gold', '阻断': 'red',
                '已解决': 'green', '处理中': 'blue', '待处理': 'orange', '不处理': 'default', '已核验': 'green',
                '待核验': 'orange', '建议值待核验': 'gold', '关键': 'red', '当前': 'green', '归档': 'default',
                '重大': 'red', '重要': 'orange', '一般': 'default', '高': 'red', '中': 'gold', '低': 'default',
                '利好': 'red', '中性': 'default', '利空': 'green', '待判断': 'gold',
                '已发生': 'red', '已部分发生': 'orange', '监控中': 'blue', '已缓解': 'green', '已解除': 'default', '未计入估值': 'orange'}
# 多对多关联的反向字段（在目标表上也能看到）
REVERSE = {('judgment', 'facts'): ('judgments', '相关假设依据'), ('judgment', 'theses'): ('judgments', '相关假设依据'),
           ('moat', 'theses'): ('moats', '相关壁垒'), ('thesis', 'facts'): ('theses', '相关论点'),
           ('value_chain', 'competitors'): ('value_chains', '产业链环节'),
           ('company', 'macro_metrics'): ('subscribers', '订阅的公司'),
           ('risk', 'theses'): ('risks', '相关风险'), ('risk', 'judgments'): ('risks', '相关风险'), ('risk', 'watches'): ('risks', '对应风险')}


def nb(*args, body=None):
    cmd = ['nb', 'api', 'data-modeling', *args, '-j']
    if body is not None:
        cmd += ['--body', json.dumps(body, ensure_ascii=False)]
    p = subprocess.run(cmd, capture_output=True, text=True, cwd=ROOT)
    if p.returncode:
        raise RuntimeError(f'{args}\n{p.stdout[-1500:]}\n{p.stderr[-500:]}')
    return json.loads(p.stdout)


def ui_for(f):
    k = f['kind']
    if k == 'num':
        p = f.get('p', 2)
        return {'x-component-props': {'step': '1' if p == 0 else '0.' + '0' * (p - 1) + '1', 'stringMode': True}}
    if k == 'pct':
        return {'x-component-props': {'step': (f.get('ui') or {}).get('step', '0.01'), 'stringMode': True, 'addonAfter': '%'}}
    if k == 'year':   # 年份不显示千分位
        return {'x-component-props': {'step': '1', 'stringMode': True, 'separator': '0.00'}}
    if k == 'int':
        return {'x-component-props': {'step': '1', 'stringMode': True}}
    return None


def field_def(f, describe=False):
    d = {'name': f['name'], 'title': f['title'], 'interface': spec.NB_INTERFACE[f['kind']]}
    ui = ui_for(f)
    if ui:
        d['uiSchema'] = ui
    if f['kind'] == 'select':
        d['enum'] = [{'value': o, 'label': o, 'color': STATUS_COLOR.get(o, COLORS[i % len(COLORS)])}
                     for i, o in enumerate(f['options'])]
    if 'default' in f:
        d['defaultValue'] = f['default']
    d['description'] = (f.get('desc') or '') if describe else ''
    return d


def collection_body(t, report=False, describe=False):
    fields = [{'name': 'id', 'title': 'ID', 'interface': 'id'}]
    fields += [field_def(f, describe) for f in t['fields'] if f['kind'] not in ('m2o', 'm2m')]
    if not report:
        fields += [{'name': f"{f['name']}_id", 'title': f"{f['title']}（ID）", 'interface': 'integer',
                    'description': ''} for f in spec.m2o_fields(t)]
        fields += [field_def(f, describe) for f in t.get('calc', [])]
        fields += [{'name': 'updated_at', 'title': '最后修改', 'interface': 'datetime', 'description': ''}]
    return {
        'name': f"vi_{t['code']}", 'title': t['title'], 'template': 'view', 'viewName': f"vi_{t['code']}",
        'description': t['desc'],
        'settings': {'writableView': not report, 'filterTargetKey': 'id', 'schema': 'public',
                     'titleField': t['title_field'], 'sortable': False},
        'fields': fields,
    }


def existing_fields(coll):
    d = nb('collections', 'get', '--filter-by-tk', coll, '--appends', 'fields')['data']
    return {f['name'] for f in d['fields']}


def ensure_reverse(t, f):
    """正向关联已存在、反向字段还没有时（例如后来才加进 REVERSE），在目标集合上单独补建反向字段。"""
    rev = REVERSE.get((t['code'], f['name']))
    if not rev or rev[0] in existing_fields(f"vi_{f['target']}"):
        return
    nb('fields', 'apply', body={'collectionName': f"vi_{f['target']}", 'name': rev[0], 'title': rev[1], 'interface': 'm2m',
                                'target': f"vi_{t['code']}", 'targetKey': 'id', 'targetTitleField': t['title_field'],
                                'through': spec.lnk_table(t, f), 'sourceKey': 'id',
                                'foreignKey': f"{f['target']}_id", 'otherKey': f"{t['code']}_id"})


def register_relations():
    for t in spec.TABLES:
        coll = f"vi_{t['code']}"
        have = existing_fields(coll)
        for f in t['fields']:
            if f['kind'] == 'm2m' and f['name'] in have:
                ensure_reverse(t, f)
            if f['kind'] not in ('m2o', 'm2m') or f['name'] in have:
                continue
            target = T[f['target']]
            body = {'collectionName': coll, 'name': f['name'], 'title': f['title'], 'interface': f['kind'],
                    'target': f"vi_{f['target']}", 'targetKey': 'id', 'targetTitleField': target['title_field']}
            if f['kind'] == 'm2o':
                body['foreignKey'] = f"{f['name']}_id"
            else:
                body.update({'through': spec.lnk_table(t, f), 'sourceKey': 'id',
                             'foreignKey': f"{t['code']}_id", 'otherKey': f"{f['target']}_id"})
                rev = REVERSE.get((t['code'], f['name']))
                if rev:
                    body.update({'reverseName': rev[0], 'reverseTitle': rev[1], 'reverseInterface': 'm2m'})
            nb('fields', 'apply', body=body)


def mark_relation_source():
    """关联字段延迟加载：source 指向本集合的标题字段（普通字段，选项只有 uiSchema）。改完需重启 app。"""
    for t in spec.TABLES:
        sql = (f"UPDATE fields SET options = (options::jsonb || jsonb_build_object('source', 'vi_{t['code']}.{t['title_field']}'))::json "
               f"WHERE \"collectionName\" = 'vi_{t['code']}' AND type IN ('belongsTo', 'belongsToMany')")
        subprocess.run([str(ROOT / 'psql.sh'), '-c', sql], check=True, capture_output=True)


def reorder_fields(code):
    """按 spec 的顺序重排一个集合的字段（详情弹窗、表单按这个顺序分组）。迁移里改名或新增的列默认排在最后，需要重排。"""
    t = T[code]
    want = ['id'] + [f['name'] for f in spec.scalar_fields(t)] + [f"{f['name']}_id" for f in spec.m2o_fields(t)] + \
           [f['name'] for f in t.get('calc', [])] + ['updated_at'] + [f['name'] for f in t['fields'] if f['kind'] in ('m2o', 'm2m')]
    have = existing_fields(f"vi_{code}")
    order = [n for n in want if n in have] + sorted(n for n in have if n not in want)      # 反向关联字段排最后
    for i, n in enumerate(order):
        p = subprocess.run(['nb', 'api', 'resource', 'update', '--resource', 'fields', '--filter',
                            json.dumps({'collectionName': f"vi_{code}", 'name': n}), '--values', json.dumps({'sort': i}), '-j'],
                           capture_output=True, text=True, cwd=ROOT)
        if p.returncode:
            raise RuntimeError(f'{code}.{n}: {p.stdout[-300:]}')
    return order


def describe(codes=None, clear=False):
    """补写字段说明（悬停/表单下方显示），页面生成之后执行。clear=True 时清空（重建页面前用）。"""
    for t in spec.TABLES + spec.REPORTS:
        if codes and t['code'] not in codes:
            continue
        coll = f"vi_{t['code']}"
        for f in t['fields'] + t.get('calc', []):
            if f['kind'] in ('m2o', 'm2m') or not f.get('desc'):
                continue
            nb('fields', 'apply', body={'collectionName': coll, 'name': f['name'], 'title': f['title'],
                                        'interface': spec.NB_INTERFACE[f['kind']], 'description': '' if clear else f['desc'],
                                        **({'uiSchema': ui_for(f)} if ui_for(f) else {}),
                                        **({'enum': field_def(f)['enum']} if f['kind'] == 'select' else {})})


if __name__ == '__main__':
    if '--describe' in sys.argv:
        describe(); print('字段说明已写入'); sys.exit()
    for t in spec.TABLES:
        nb('collections', 'apply', body=collection_body(t))
        print('集合', t['title'])
    for t in spec.REPORTS:
        nb('collections', 'apply', body=collection_body(t, report=True))
        print('报表', t['title'])
    register_relations()
    mark_relation_source()
    print('关联字段已建立并标记延迟加载；请重启 app：docker compose restart app')
