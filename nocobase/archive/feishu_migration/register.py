"""把 SQL 界面视图 cj_<code> 注册为 NocoBase 可写视图集合，并建立关联字段。可重复执行（apply 为 upsert）。"""
import json, subprocess, pathlib, re
import spec

HERE = pathlib.Path(__file__).resolve().parent
EXPORT = HERE / 'feishu_export'
TB = spec.table_by_code()

HUE = {'Blue': 'blue', 'Purple': 'purple', 'Gray': 'default', 'Orange': 'orange', 'Carmine': 'magenta',
       'Red': 'red', 'Green': 'green', 'Lime': 'lime', 'Yellow': 'gold', 'Turquoise': 'cyan',
       'Wathet': 'geekblue', 'Violet': 'purple', 'Indigo': 'geekblue', 'Neutral': 'default'}


def nb(*args, body=None):
    cmd = ['nb', 'api', 'data-modeling', *args, '-j']
    if body is not None:
        cmd += ['--body', json.dumps(body, ensure_ascii=False)]
    p = subprocess.run(cmd, capture_output=True, text=True, cwd=HERE.parent)
    if p.returncode:
        raise RuntimeError(f'{args} failed:\n{p.stdout}\n{p.stderr}')
    return json.loads(p.stdout)


def feishu_fields(code):
    return {f['name']: f for f in json.load(open(EXPORT / f'{TB[code][0]}.fields.json'))}


def calc_step(en):
    if 'factor' in en or en in ('recon_diff',):
        return '0.000001'
    if re.search(r'rate|growth|payout|burden|margin|share$|pct|delta|unified_value|latest_value|value_candidate', en):
        return '0.0001'
    return '0.01'


def field_def(code, cn, en, kind, ff, is_calc):
    d = {'name': en, 'title': cn, 'interface': spec.NB_INTERFACE[kind]}
    if kind == 'num':
        if is_calc:
            step = calc_step(en)
        else:
            p = ff[cn]['style'].get('precision', 4)
            step = '1' if p == 0 else '0.' + '0' * (p - 1) + '1'
        d['uiSchema'] = {'x-component-props': {'step': step, 'stringMode': True}}
    if kind == 'select':
        d['enum'] = [{'value': o['name'], 'label': o['name'], 'color': HUE.get(o.get('hue'), 'default')}
                     for o in ff[cn]['options']]
    if is_calc:
        d['description'] = ''  # 只读说明放在集合描述里；字段描述会被 UI 生成器当作表单行为指令
    return d


def register_collection(code):
    tid, title, group = TB[code]
    ff = feishu_fields(code)
    fields = [{'name': 'id', 'title': 'ID', 'interface': 'id'}]
    fields += [field_def(code, cn, en, k, ff, False) for cn, en, k in spec.INPUTS.get(code, [])]
    fields += [{'name': f'{l[2]}_id', 'title': f'{l[1]}（外键）', 'interface': 'integer'}
               for l in spec.LINKS if l[0] == code and l[4] == 'm2o']
    fields += [field_def(code, cn, en, k, ff, True) for cn, en, k in spec.CALC.get(code, [])]
    fields += [{'name': 'feishu_id', 'title': '飞书记录ID', 'interface': 'input'}]
    body = {
        'name': f'cj_{code}', 'title': title, 'template': 'view', 'viewName': f'cj_{code}',
        'description': f'{group}｜飞书表 {tid}｜计算列由 SQL 视图实时计算，只读',
        'settings': {'writableView': True, 'filterTargetKey': 'id', 'schema': 'public',
                     'titleField': spec.TITLE_FIELD[code], 'sortable': False},
        'fields': fields,
    }
    r = nb('collections', 'apply', body=body)
    v = r.get('verify', {})
    if not v.get('valid', True):
        raise RuntimeError(f'{code}: {v}')
    return len(fields)


def existing_fields(coll):
    d = nb('collections', 'get', '--filter-by-tk', coll, '--appends', 'fields')['data']
    return {f['name'] for f in d['fields']}


def register_links():
    for code, cn, en, target, kind, rev in spec.LINKS:
        if en in existing_fields(f'cj_{code}'):
            continue  # 已建立；双向关联不支持原地更新
        body = {'collectionName': f'cj_{code}', 'name': en, 'title': cn, 'interface': kind,
                'target': f'cj_{target}', 'targetKey': 'id', 'targetTitleField': spec.TITLE_FIELD[target]}
        if kind == 'm2o':
            body['foreignKey'] = f'{en}_id'
        else:
            body.update({'through': f'cj_lnk_{code}_{en}', 'sourceKey': 'id',
                         'foreignKey': f'{code}_id', 'otherKey': f'{target}_id'})
            if rev:
                body.update({'reverseName': rev[1], 'reverseTitle': rev[0], 'reverseInterface': 'm2m'})
        nb('fields', 'apply', body=body)


def mark_relation_source():
    """视图集合的关联字段必须带 options.source，否则 NocoBase 启动时会在目标视图的主键加载前绑定关联，
    报 "Target model ... has no primary key attribute" 导致应用无法启动。带 source 的关联字段会被推迟到所有视图字段加载完再绑定。
    source 指向本集合的 feishu_id（选项里只有 uiSchema，合并时会被关联字段自己的选项覆盖）。改完需重启 app。"""
    sql = ("UPDATE fields SET options = (options::jsonb || jsonb_build_object('source', \"collectionName\" || '.feishu_id'))::json "
           "WHERE \"collectionName\" LIKE 'cj_%' AND \"collectionName\" NOT LIKE 'cj_lnk_%' AND type IN ('belongsTo','belongsToMany')")
    subprocess.run([str(HERE.parent / 'psql.sh'), '-c', sql], check=True, capture_output=True)


if __name__ == '__main__':
    import sys
    for _, code, title, _ in ([] if '--links-only' in sys.argv else spec.TABLES):
        print(f'{title:<16} cj_{code:<14} {register_collection(code)} 个字段', flush=True)
    register_links()
    mark_relation_source()
    print('关联字段', len(spec.LINKS), '个已建立；已标记 source（重启后按延迟顺序加载）')
