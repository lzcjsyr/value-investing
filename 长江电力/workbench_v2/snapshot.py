import json, subprocess, pathlib, datetime
BASE='PMnCb5BsGaME0ysW21uc7pHJnDb'
ROOT=pathlib.Path(__file__).resolve().parent
def cli(*args):
    p=subprocess.run(['lark-cli','base',*args,'--base-token',BASE,'--as','user'],capture_output=True,text=True)
    if p.returncode: raise RuntimeError(p.stderr)
    x=json.loads(p.stdout)
    if x.get('manifest_version'): return x
    if not x.get('ok'): raise RuntimeError(p.stdout)
    return x['data']
if __name__=='__main__':
    dest=ROOT/'snapshots'/datetime.datetime.now().strftime('%Y%m%dT%H%M%S')
    dest.mkdir(parents=True)
    tables=cli('+table-list')['tables']
    (dest/'tables.json').write_text(json.dumps(tables,ensure_ascii=False,indent=2))
    for t in tables:
        fs=cli('+field-list','--table-id',t['id'])['fields']
        (dest/(t['id']+'.schema.json')).write_text(json.dumps(fs,ensure_ascii=False,indent=2))
        args=['+record-list','--table-id',t['id']]
        for f in fs: args+=['--field-id',f['id']]
        args+=['--format','ndjson','--output',str((dest/(t['id']+'.ndjson')).relative_to(pathlib.Path.cwd()))]
        r=cli(*args)
        if r.get('has_more'): raise RuntimeError('Snapshot incomplete: pagination required')
        print(t['name'],r.get('records_count'),flush=True)
    print('SNAPSHOT',dest)
