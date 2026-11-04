"""只读核验数据库目录，生成《字段字典》。"""
import collections
import datetime
import re
from zoneinfo import ZoneInfo
import spec

TITLE = {t['code']: t['title'] for t in spec.TABLES + spec.REPORTS}
SKIP = {'id', 'created_at', 'updated_at'}


def today():
    return datetime.datetime.now(ZoneInfo('Asia/Shanghai')).date().isoformat()


def catalogue(q):
    objects = q("""SELECT json_agg(json_build_object('name',c.relname,'kind',c.relkind) ORDER BY c.relname)
        FROM pg_class c WHERE c.relnamespace='public'::regnamespace AND c.relname LIKE 'vi\\_%' AND c.relkind IN ('r','v','m')""")
    columns = q("""SELECT json_agg(json_build_object('table',c.relname,'name',a.attname,
        'description',col_description(c.oid,a.attnum)) ORDER BY c.relname,a.attnum)
        FROM pg_class c JOIN pg_attribute a ON a.attrelid=c.oid AND a.attnum>0 AND NOT a.attisdropped
        WHERE c.relnamespace='public'::regnamespace AND c.relname LIKE 'vi\\_%' AND c.relkind IN ('r','v','m')""")
    registered = q('SELECT json_agg(name ORDER BY name) FROM collections')
    names = {o['name'] for o in objects}
    return {'objects': objects, 'columns': columns,
            'stale_collections': [n for n in registered if n.startswith('vi_') and n not in names]}


def cell(s):
    return str(s or '').replace('|', '／').replace('\n', '<br>')


def explain(f, comment, title):
    """说明栏：优先 spec 的说明；没有时取数据库注释里“名称：”之后的部分，去掉重复的可选值与关联。"""
    text = f.get('desc') or re.sub(r'（(可选|关联)[^）]*）', '', comment or '')
    if text.startswith(title):
        text = text[len(title):].lstrip('：')
    parts = [text] if text else []
    if f.get('kind') == 'm2o':
        parts.insert(0, f"关联{spec.doc_name(f['target'])}")
    if f.get('options'):
        parts.append('可选：' + '、'.join(map(str, f['options'])))
    return cell('；'.join(parts))


def field_dictionary(cat):
    cols = collections.defaultdict(list)
    for c in cat['columns']:
        cols[c['table']].append(c)
    out = ['# 字段字典', '',
           f"> {today()} 核验本地库。每张录入表一节，省略 id 与创建、修改时间；说明写“自动”的是页面里只读的计算字段。"
           "表的用途见《数据结构说明》。", '']
    for t in spec.TABLES:
        name = f"vi_{t['code']}_base"
        if name not in cols:
            continue
        fields = {f['name'] + ('_id' if f['kind'] == 'm2o' else ''): f for f in t['fields'] if f['kind'] != 'm2m'}
        out += [f"## `{name}`" if t['code'] in spec.CODE_FIRST else f"## {t['title']} `{name}`", '', t.get('desc', ''), '', '| 字段 | 含义 | 说明 |', '|---|---|---|']
        for c in cols[name]:
            if c['name'] in SKIP:
                continue
            f = fields.get(c['name'], {})
            title = f.get('title') or re.split(r'[：（]', c['description'] or c['name'])[0]
            out.append(f"| `{c['name']}` | {cell(title)} | {explain(f, c['description'], title)} |")
        shown = {c['name'] for c in cols['vi_' + t['code']]}
        out += [f"| `{f['name']}` | {cell(f['title'])} | {cell('；'.join(filter(None, ['自动', f.get('desc')])))} |"
                for f in t.get('calc', []) if f['name'] in shown]
        rels = spec.m2m_fields(t)
        if rels:
            out += ['', '多对多：' + '；'.join(f"{f['title']} → {spec.doc_name(f['target'])}（`{spec.lnk_table(t, f)}`）" for f in rels)]
        out.append('')
    return '\n'.join(out).rstrip() + '\n'
