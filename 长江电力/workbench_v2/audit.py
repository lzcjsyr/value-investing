import json, pathlib, datetime
from build import ROOT, cli, state, S,I,F,V
QA_RUN=ROOT/'qa'/datetime.datetime.now().strftime('%Y%m%dT%H%M%S%f')
def export(name,fields):
    path=QA_RUN/(name+'.ndjson');path.parent.mkdir(parents=True,exist_ok=True)
    # Feishu tables were renamed on 2026-10-21; resolve the original V2 key to its stable table ID.
    args=['+record-list','--table-id',state['tables'].get(name,name)]
    for f in fields:args+=['--field-id',f]
    out=cli(*args,'--format','ndjson','--output',str(path.relative_to(pathlib.Path.cwd())))
    assert not out['has_more']
    return [json.loads(x) for x in path.read_text().splitlines()]
def main():
    cash_keys=['归属折旧加回亿元','非现金收益扣除亿元','投资现金分红亿元','其他现金调整亿元','营运资本增加亿元','维持资本亿元','扩张资本亿元','净借款亿元','最低现金补充亿元']
    sc=export(S,['情景','电量系数','电价系数','付现成本系数','有效折现率','永续增长率','有效股本亿股','计算基准折现率','基准无风险利率pct','基准风险溢价pct'])
    inp=export(I,['年份','电量亿千瓦时','有效电价元','付现成本亿元','折旧亿元','利息亿元','有效其他净贡献亿元','有效综合负担率','有效派息率','现金桥接实时状态']+cash_keys)
    fin=export(F,['模型键','情景名称','年份','收入亿元','归母利润代理亿元','计划股息亿元','FCFE亿元','现金数据完整'])
    vs=export(V,['情景','条件DDM元','终值占比','现金完整年数','现金支持DDM元','模型勾稽','预测期勾稽差额亿元'])
    sens=export('V2_12估值敏感性',['组合','折现率','永续增长率','条件DDM元'])
    shock=export('V2_13参数影响沙盘',['试验','试验价值元','每股价值变化元'])
    checks=[]
    def check(name,ok):checks.append({'check':name,'pass':bool(ok)})
    def close(a,b):return abs(float(a)-float(b))<1e-5
    sdict={x['情景']:x for x in sc};expected={}
    cash_complete_count=sum(all(a.get(k) is not None for k in cash_keys) for a in inp)
    for s in sc:
        divs=[]
        for a in inp:
            rev=a['电量亿千瓦时']*s['电量系数']*float(a['有效电价元'])*s['电价系数']
            profit=(rev-a['付现成本亿元']*s['付现成本系数']-a['折旧亿元']-a['利息亿元']+float(a['有效其他净贡献亿元']))*(1-float(a['有效综合负担率']))
            div=max(0,profit*float(a['有效派息率']));divs.append(div)
            row=next(x for x in fin if x['情景名称']==s['情景'] and x['年份']==a['年份'])
            check(row['模型键'],close(row['收入亿元'],rev) and close(row['归母利润代理亿元'],profit) and close(row['计划股息亿元'],div))
        def pv(r,g):return (sum(d/(1+r)**(i+1) for i,d in enumerate(divs))+divs[-1]*(1+g)/(r-g)/(1+r)**10)/float(s['有效股本亿股'])
        value=pv(float(s['有效折现率']),s['永续增长率']);expected[s['情景']]=value
        v=next(x for x in vs if x['情景']==s['情景']);check(s['情景']+'DDM独立重算',close(v['条件DDM元'],value))
        check(s['情景']+'表内勾稽',v['模型勾稽']=='通过' and close(v['预测期勾稽差额亿元'],0))
        check(s['情景']+'现金状态联动',float(v['现金完整年数'])==cash_complete_count and ((v['现金支持DDM元'] not in ['',None]) if cash_complete_count==10 else (v['现金支持DDM元'] in ['',None])))
        if s['情景']=='基准':
            for x in sens:check(x['组合'],close(x['条件DDM元'],pv(float(x['折现率']),float(x['永续增长率']))))
    check('情景排序',expected['悲观']<expected['基准']<expected['乐观'])
    rate=sdict['基准']
    check('基准折现率公式',close(rate['计算基准折现率'],rate['有效折现率']) and close(rate['计算基准折现率'],round(rate['基准无风险利率pct']+rate['基准风险溢价pct'],1)/100))
    check('现金输入缺项显式保留',all((x['现金桥接实时状态']=='现金项已填；仍待证据核验')==all(x.get(k) is not None for k in cash_keys) for x in inp))
    check('无虚假FCFE',all((x['FCFE亿元'] not in ['',None])==(str(x['现金数据完整']).lower() in ('true','1')) for x in fin))
    for x in shock:
        check('沙盘方向-'+x['试验'],float(x['每股价值变化元'])<0 if ('-10%' in x['试验'] or '-3%' in x['试验'] or '50bp' in x['试验']) else float(x['每股价值变化元'])>0)
    old=json.loads((ROOT/'snapshots/20260919T153616/tables.json').read_text());cur={x['id']:x for x in cli('+table-list')['tables']}
    for t in old:check('原表保留-'+t['name'],cur[t['id']]['records_count']==t['records_count'])
    report={'at':datetime.datetime.now().isoformat(),'checks':checks,'passed':sum(x['pass'] for x in checks),'failed':sum(not x['pass'] for x in checks),'conditional_values':expected,'readiness':'工程验收；非财务假设核验'}
    (QA_RUN/'report.json').write_text(json.dumps(report,ensure_ascii=False,indent=2))
    if report['failed']:raise RuntimeError(json.dumps([x for x in checks if not x['pass']],ensure_ascii=False))
    print(json.dumps({k:v for k,v in report.items() if k!='checks'},ensure_ascii=False,indent=2))
if __name__=='__main__':main()
