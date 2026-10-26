"""五家公司：业务驱动与财务结果分开，保留数据 ID 和已有图表引用。

python3 framework/reorganize_business_data.py
"""
from collections import defaultdict
import json
from pathlib import Path
import build_pages as bp
import build_finstmt as bf
import build_overview as bo
import align_companies as aligned
import spec
from data_domains import category, STATEMENT_DUPLICATES

OUT = bp.ROOT / 'checks' / 'business_data_20261026'
COMPANIES = {'600900.SH','002078.SZ','601668.SH','01698.HK','01810.HK'}


def records(resource):
    return bp.nb_json('resource','list','--resource',resource,'--page-size','2000')['data']


def configure_categories():
    field = next(f for f in spec.all_tables()['metric']['fields'] if f['name']=='category')
    old = next(f for f in bp.live_fields('vi_metric') if f['name']=='category')
    colors = {item['value']:item.get('color','default') for item in old.get('uiSchema',{}).get('enum',[])}
    result = bp.nb_json('data-modeling','fields','apply','--collection-name','vi_metric','--name','category',
        '--title','类别','--interface','select','--description',field['desc'],
        '--enum',json.dumps([{'value':v,'label':v,'color':colors.get(v,'purple')} for v in field['options']],ensure_ascii=False))
    (OUT/'category_metadata_applied.json').write_text(json.dumps(result,ensure_ascii=False,indent=2))
    groups = defaultdict(list)
    allowed_ids = {co['id'] for co in bp.companies() if co['code'] in COMPANIES}
    for metric in records('vi_metric'):
        if metric.get('company_id') in allowed_ids and metric.get('source_kind') in ('公司披露','年报','手工整理'):
            wanted = category(metric['name'])
            if metric['category'] != wanted: groups[wanted].append(metric['id'])
    for wanted, ids in groups.items():
        bp.nb_json('resource','update','--resource','vi_metric',
            '--filter',json.dumps({'$or':[{'id':{'$eq':i}} for i in ids]}),
            '--values',json.dumps({'category':wanted},ensure_ascii=False))
        print('分类',wanted,len(ids),flush=True)
    bp._META.clear()


def aiot_operating_data():
    co = next(c for c in bp.companies() if c['code']=='01810.HK')
    fact = next(f for f in records('vi_fact') if f['company_id']==co['id'] and f['title'].startswith('AIoT 连接设备'))
    assert fact['verify_status']=='已核验' and fact['as_of']=='2026-06-30' and fact['value']==11.608
    source = next(s for s in records('vi_source') if s['id']==fact['source_id'])
    metrics = records('vi_metric')
    for suffix,name,unit,value,yoy in [
        ('AIOT_DEVICES','AIoT平台连接设备数（不含手机和平板）','百万台',1160.8,0.174),
        ('AIOT_MULTI_USERS','拥有五件及以上AIoT设备的用户数','百万人',24.6,0.202),
    ]:
        code = '01810.HK.OP.'+suffix
        metric = next((m for m in metrics if m['code']==code),None)
        if not metric:
            metric = bp.nb_json('resource','create','--resource','vi_metric','--values',json.dumps({
                'code':code,'name':name,'unit':unit,'category':'经营','source_kind':'公司披露','basis':'时点',
                'company_id':co['id'],'source_name':source['title'],'frequency':'季','valid_min':0,
                'notes':'来源为已有已核验事实：'+fact['title']+'。官方披露为平台连接设备，不能改称月活跃设备。'},ensure_ascii=False))['data']
        existing = bp.nb_json('resource','list','--resource','vi_observation','--filter',json.dumps({'$and':[
            {'metric_id':{'$eq':metric['id']}},{'period':{'$eq':'2026Q2'}}]}),'--page-size','20')['data']
        if not existing:
            bp.nb_json('resource','create','--resource','vi_observation','--values',json.dumps({
                'metric_id':metric['id'],'obs_date':'2026-06-30','period':'2026Q2','value':value,'yoy':yoy,
                'impact':'待判断','summary':fact['statement'],'status':'无需入模','doc_id':fact['source_id'],
                'source':source['url'],'note':'期末连接/持有数量；设备数量不含手机和平板，以原公告口径为准。'},ensure_ascii=False))
        print('业务指标',code,flush=True)


def deploy(co, metrics):
    for key in ('observation','finstmt'):
        tree = bp.page_tree(f'{key}@{co["code"]}')
        (OUT/f'before_{key}_{co["code"]}.json').write_text(json.dumps(tree,ensure_ascii=False,indent=1))
    gid = bp.state()['groups'][co['name']+'/数据底稿']
    body = aligned.aligned_blueprint('observation','业务数据',gid,co)
    body.pop('navigation',None)
    body.update(mode='replace',target={'pageSchemaUid':bp.state()['pages'][f'observation@{co["code"]}']['pageSchemaUid']})
    bo.apply_page(f'observation_{co["code"]}',body)
    bp.nb_json('resource','update','--resource','desktopRoutes','--filter-by-tk',str(bp.state()['pages'][f'observation@{co["code"]}']['routeId']),
        '--values',json.dumps({'title':'业务数据'},ensure_ascii=False))
    bp.order_tabs(f'observation@{co["code"]}',['定期经营数据','高频业务数据'])
    has_supplement = any(m['company_id']==co['id'] and m['category']=='财务' and m['name'] not in STATEMENT_DUPLICATES and m['obs_count']>0 for m in metrics)
    body = bf.page_body(co,gid,has_supplement)
    body.update(version='1',mode='replace',target={'pageSchemaUid':bp.state()['pages'][f'finstmt@{co["code"]}']['pageSchemaUid']})
    bo.apply_page(f'finstmt_{co["code"]}',body)
    if has_supplement: bp.order_tabs(f'finstmt@{co["code"]}',['财务报表','分部与财务补充'])
    print('完成',co['name'],'业务数据 / 财务数据',flush=True)


if __name__=='__main__':
    OUT.mkdir(exist_ok=True,parents=True)
    configure_categories()
    aiot_operating_data()
    metrics = records('vi_metric')
    (OUT/'metrics_after.json').write_text(json.dumps(metrics,ensure_ascii=False,indent=2))
    for company in bp.companies():
        if company['code'] in COMPANIES: deploy(company,metrics)
