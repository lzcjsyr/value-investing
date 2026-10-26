"""验收五家公司的业务/财务分域，使用在线页面的实际筛选条件请求数据。"""
import json
from pathlib import Path
import subprocess
import sys
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
import build_pages as bp
from data_domains import business_scope, financial_supplement_scope, STATEMENT_DUPLICATES, category

OUT=bp.ROOT/'checks'/'business_data_20261026'
CODES={'600900.SH','002078.SZ','601668.SH','01698.HK','01810.HK'}


def walk(items):
    for item in items:
        yield item
        yield from walk(item.get('children') or [])


def server_filter(condition):
    if 'logic' in condition:
        return {condition['logic']:[server_filter(c) for c in condition['items']]}
    return {condition['path']:{condition['operator']:condition['value']}}


def rows_for(filter_):
    return bp.nb_json('resource','list','--resource','vi_observation','--filter',json.dumps(server_filter(filter_),ensure_ascii=False),
                     '--appends','metric','--page-size','2000')['data']


if __name__=='__main__':
    routes=list(walk(json.load(open(OUT/'routes_after.json'))))
    result=[]
    for co in bp.companies():
        if co['code'] not in CODES:continue
        key=f'observation@{co["code"]}'
        page=json.load(open(OUT/('after_'+key+'.json')))
        route=next(r for r in routes if r['id']==bp.state()['pages'][key]['routeId'])
        assert route['title']=='业务数据'
        tabs=sorted(route['children'],key=lambda r:r.get('sort',0))
        assert [t['title'] for t in tabs]==['公司披露','高频业务数据']
        tables=[b for b in bp.blocks(page['tree']) if b['use']=='TableBlockModel']
        assert len(tables)==2
        found=[]
        for table in tables:
            f=table['stepParams']['tableSettings']['dataScope']['filter']
            assert f in [business_scope(co),business_scope(co,True)]
            data=rows_for(f)
            for r in data:
                assert r['metric']['category'] in ('经营','水文','商品'),r
                assert r['metric']['name'] not in STATEMENT_DUPLICATES,r
            found+=data
        names={r['metric']['name'] for r in found}
        if co['code']=='601668.SH':assert {'新签合同总额','地产合约销售额','房屋建筑新开工面积'}<=names
        if co['code']=='600900.SH':assert any('三峡水库水位' in n for n in names)
        if co['code']=='01810.HK':assert {'AIoT平台连接设备数（不含手机和平板）','拥有五件及以上AIoT设备的用户数'}<=names
        financial=json.load(open(OUT/f'after_finstmt@{co["code"]}.json'))
        extra=[b for b in bp.blocks(financial['tree']) if b['use']=='TableBlockModel']
        supplemental=[]
        for table in extra:
            f=table['stepParams']['tableSettings']['dataScope']['filter']
            assert f==financial_supplement_scope(co)
            supplemental+=rows_for(f)
        assert all(r['metric']['category']=='财务' and r['metric']['name'] not in STATEMENT_DUPLICATES for r in supplemental)
        result.append({'company':co['name'],'business_observations':len(found),'business_names':sorted(names),'supplemental_financial_observations':len(supplemental)})
        print(co['name'],'业务',len(found),'财务补充',len(supplemental),flush=True)
    sql="""SELECT json_build_object('metrics',(SELECT json_agg(x ORDER BY id) FROM vi_metric_base x),
    'observations',(SELECT json_agg(x ORDER BY id) FROM vi_observation_base x),
    'financial_count',(SELECT count(*) FROM vi_fin_stmt_base),
    'financial_hash',(SELECT md5(string_agg(row_to_json(x)::text,'|' ORDER BY id)) FROM vi_fin_stmt_base x),
    'models',(SELECT json_agg(x ORDER BY id) FROM vi_model_base x),
    'forecasts',(SELECT json_agg(x ORDER BY id) FROM vi_forecast_base x))"""
    p=subprocess.run([str(bp.ROOT/'psql.sh'),'-At','-c',sql],capture_output=True,text=True,check=True)
    (OUT/'data_after.json').write_text(p.stdout)
    before=json.load(open(OUT/'data_before.json'));after=json.loads(p.stdout)
    assert before['financial_hash']==after['financial_hash'] and before['financial_count']==after['financial_count']
    assert before['models']==after['models'] and before['forecasts']==after['forecasts']
    after_obs={r['id']:r for r in after['observations']}
    assert all(row==after_obs[row['id']] for row in before['observations'])
    old_ids={r['id'] for r in before['observations']};new_obs=[r for r in after['observations'] if r['id'] not in old_ids]
    assert len(new_obs)==2 and {r['value'] for r in new_obs}=={1160.8,24.6}
    unchanged_fields=lambda r:{k:v for k,v in r.items() if k not in ('category','updated_at')}
    after_metrics={r['id']:r for r in after['metrics']}
    assert all(unchanged_fields(r)==unchanged_fields(after_metrics[r['id']]) for r in before['metrics'])
    for r in after['metrics']:
        if r['source_kind']=='公司披露':assert r['category']==category(r['name'])
    report={'companies':result,'financial_records_unchanged':after['financial_count'],'all_existing_observations_unchanged':len(before['observations']),
        'models_unchanged':True,'forecasts_unchanged':True,'new_business_observations':2,'passed':True}
    (OUT/'verification.json').write_text(json.dumps(report,ensure_ascii=False,indent=2))
    print(json.dumps({k:v for k,v in report.items() if k!='companies'},ensure_ascii=False))
