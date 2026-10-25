"""只读导出每张飞书表第一个视图（“日常”）的可见列，作为 NocoBase 表格默认列。"""
import json, subprocess, pathlib
BASE = 'PMnCb5BsGaME0ysW21uc7pHJnDb'
OUT = pathlib.Path(__file__).resolve().parent / 'feishu_export'

def cli(*a):
    p = subprocess.run(['lark-cli', 'base', *a, '--base-token', BASE, '--as', 'user'], capture_output=True, text=True)
    x = json.loads(p.stdout)
    if not x.get('ok'):
        raise RuntimeError(p.stdout + p.stderr)
    return x['data']

views = {}
for t in json.load(open(OUT / 'tables.json')):
    vs = cli('+view-list', '--table-id', t['id'])['views']
    first = vs[0]
    vis = cli('+view-get-visible-fields', '--table-id', t['id'], '--view-id', first['id'])
    views[t['id']] = {'view': first['name'], 'visible': vis}
    print(t['name'], first['name'], str(vis)[:150], flush=True)
(OUT / 'views.json').write_text(json.dumps(views, ensure_ascii=False, indent=1))
