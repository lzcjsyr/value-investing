"""只读导出飞书 Base「长江电力投资工作台」：表清单、字段定义（含公式）、全部记录。"""
import json, subprocess, pathlib
BASE = 'PMnCb5BsGaME0ysW21uc7pHJnDb'
OUT = pathlib.Path(__file__).resolve().parent / 'feishu_export'

def cli(*args):
    p = subprocess.run(['lark-cli', 'base', *args, '--base-token', BASE, '--as', 'user'],
                       capture_output=True, text=True, cwd=OUT)
    if p.returncode:
        raise RuntimeError(p.stderr)
    x = json.loads(p.stdout)
    if x.get('manifest_version'):
        return x
    if not x.get('ok'):
        raise RuntimeError(p.stdout)
    return x['data']

if __name__ == '__main__':
    tables = cli('+table-list')['tables']
    (OUT / 'tables.json').write_text(json.dumps(tables, ensure_ascii=False, indent=2))
    for t in tables:
        fs = cli('+field-list', '--table-id', t['id'])['fields']
        (OUT / f"{t['id']}.fields.json").write_text(json.dumps(fs, ensure_ascii=False, indent=2))
        args = ['+record-list', '--table-id', t['id']]
        for f in fs:
            args += ['--field-id', f['id']]
        args += ['--format', 'ndjson', '--output', f"{t['id']}.ndjson"]
        r = cli(*args)
        if r.get('has_more'):
            raise RuntimeError(f"{t['name']} 需要分页")
        print(t['id'], t['name'], len(fs), 'fields', r.get('records_count'), 'records', flush=True)
