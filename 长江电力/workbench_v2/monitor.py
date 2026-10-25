"""Append-only observations. Never changes valuation assumptions or trades."""
import datetime as dt, hashlib, json, pathlib, subprocess, fcntl, math
from snapshot import ROOT, cli
WIND=pathlib.Path('/Users/dielangli/.agents/skills/wind-mcp-skill')
H='tblvFm47sB0tjy3D'  # 3.2 市场数据 (formerly V2_11市场观察); table ID survives renames
def wind(server,tool,params,run):
    p=subprocess.run(['node','scripts/cli.mjs','call',server,tool,json.dumps(params,ensure_ascii=False)],cwd=WIND,capture_output=True,text=True,timeout=180)
    if p.returncode:raise RuntimeError('Wind process failed; inspect authenticated runtime')
    outer=json.loads(p.stdout)
    if outer.get('ok') is False or outer.get('isError'):raise RuntimeError(str(outer.get('code','Wind error')))
    inner=json.loads(outer['content'][0]['text'])
    if inner.get('error'):raise RuntimeError('Wind returned data error')
    path=run/(server+'-'+tool+'.json');path.write_text(json.dumps(outer,ensure_ascii=False,indent=2))
    return inner,str(path.relative_to(ROOT))
def export_keys(run):
    keys=set();offset=0
    while True:
        path=run/f'existing-{offset}.ndjson'
        x=cli('+record-list','--table-id',H,'--field-id','观察ID','--limit','2000','--offset',str(offset),'--format','ndjson','--output',str(path.relative_to(pathlib.Path.cwd())))
        keys.update(json.loads(s)['观察ID'] for s in path.read_text().splitlines())
        if not x['has_more']:return keys
        offset+=x['records_count']
def main():
    lock=open(ROOT/'monitor.lock','a')
    fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB)
    now=dt.datetime.now(dt.timezone(dt.timedelta(hours=8)))
    run=ROOT/'runs'/now.strftime('%Y%m%dT%H%M%S%f');run.mkdir(parents=True)
    statepath=ROOT/'monitor-state.json'
    old=json.loads(statepath.read_text()) if statepath.exists() else {}
    # Backfill from last successful run with a revision overlap, capped only on first run.
    anchor=dt.date.fromisoformat(old.get('last_completed_date',(now.date()-dt.timedelta(days=18)).isoformat()))
    begin=(anchor-dt.timedelta(days=7)).isoformat()
    report={'run':run.name,'started':now.isoformat(),'begin':begin,'errors':[],'inserted':0}
    observations=[]
    def add(code,name,date,value,unit,source,file,boundary):
        if value is None:return
        value=float(value)
        if not math.isfinite(value) or value < 0:
            report['errors'].append(f'Quarantined invalid observation: {code} {date}; original response retained')
            return
        date=str(date).replace('-','')[:8]
        parsed=dt.datetime.strptime(date,'%Y%m%d').date()
        if parsed>now.date():raise ValueError('Future observation rejected')
        identity=hashlib.sha256(f'{code}|{date}|{value}|{unit}|{source}'.encode()).hexdigest()[:20]
        observations.append({'观察ID':identity,'指标':name,'指标代码':code,'日期':parsed.isoformat(),'数值':value,'单位':unit,'来源':source,'采集时间':now.isoformat(),'原始文件':file,'使用边界':boundary})
    try:
        data,file=wind('economic_data','query_economic_indicator_data',{'question':'M1001654,Z3791116,L1680403,K4903912','beginDate':begin,'endDate':now.date().isoformat()},run)
        expected={'M1001654','Z3791116','L1680403','K4903912'}
        actual={m['meta']['code'] for m in data.get('metrics',[])}
        if not expected.issubset(actual):report['errors'].append('EDB missing requested codes: '+','.join(expected-actual))
        for m in data.get('metrics',[]):
            meta=m['meta']
            if meta['code'] not in expected:continue
            if len(m['date'])!=len(m['value']):raise ValueError('EDB dates/values mismatch')
            for date,value in zip(m['date'],m['value']):
                add(meta['code'],meta['name'],date,value,meta.get('unit','单位未提供'),'Wind / '+meta.get('source','来源未提供'),file,'观察数据；水文不得直接外推全年电量；国债为中证口径，非中债，不自动改长期折现率')
    except Exception as e:report['errors'].append('EDB: '+str(e))
    try:
        data,file=wind('stock_data','get_stock_price_indicators',{'windcode':'600900.SH'},run)
        body=data['data'];cols=[x['name'] for x in body['columns']]
        for vals in body['rows']:
            row=dict(zip(cols,vals))
            add('600900.SH.PRICE','长江电力最新成交价',row['最新交易日'],row['最新成交价'],body.get('unit',{}).get('最新成交价','单位未提供'),'Wind 金融数据服务',file,'独立市场观察；不得直接与2025年末条件估值作为现时买卖信号比较')
    except Exception as e:report['errors'].append('PRICE: '+str(e))
    existing=export_keys(run)
    fresh=[r for r in observations if r['观察ID'] not in existing]
    for start in range(0,len(fresh),200):
        batch=fresh[start:start+200]
        cli('+record-batch-create','--table-id',H,'--json',json.dumps({'create_records':batch},ensure_ascii=False));report['inserted']+=len(batch)
    report['observations']=len(observations)
    report['latest']={code:max(r['日期'] for r in observations if r['指标代码']==code) for code in {r['指标代码'] for r in observations}}
    report['status']='partial' if report['errors'] else 'completed'
    (run/'manifest.json').write_text(json.dumps(report,ensure_ascii=False,indent=2))
    if not report['errors']:
        statepath.write_text(json.dumps({'last_completed_date':now.date().isoformat(),'run':run.name},ensure_ascii=False,indent=2))
    print(json.dumps(report,ensure_ascii=False,indent=2))
if __name__=='__main__':main()
