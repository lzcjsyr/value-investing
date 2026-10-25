from cloud_health import *
import pathlib
def main():
 run=ROOT/'runs'/('cloud-'+datetime.now().strftime('%Y%m%dT%H%M%S%f'));run.mkdir()
 def export(name,names):
  path=run/(name+'.ndjson');args=['+record-list','--table-id',state['tables'][name]]
  for n in names:args+=['--field-id',n]
  m=cli(*args,'--format','ndjson','--output',str(path.relative_to(pathlib.Path.cwd())))
  assert not m['has_more']
  return [json.loads(s) for s in path.read_text().splitlines()]
 raw=export(R,['指标代码','日期V2','数值V2','校验V2','处理状态','运行结果','已有观察数'])
 obs=export(H,['观察ID','指标代码','日期','云端数值原文','统一数值','质量有效'])
 health=export(C,['指标代码','健康状态','最近自检','自检结果','最近观察日'])
 workflows=cli('+workflow-list')['items'];(run/'workflows.json').write_text(json.dumps(workflows,ensure_ascii=False,indent=2))
 checks={}
 for code in SOURCES:
  rr=[r for r in raw if r['指标代码']==code];oo=[r for r in obs if r['指标代码']==code]
  checks[code+'真实入库']=len(oo)>=1 and all(o['云端数值原文'] for o in oo)
  checks[code+'重复抓取不重复入库']=len(rr)>=2 and len(oo)==len({r['日期V2']+'|'+r['数值V2'] for r in rr if r['校验V2']=='1'})
  checks[code+'处理完成']=all(str(r['处理状态']).startswith('完成') for r in rr)
  checks[code+'健康自检正常']=any(r['指标代码']==code and r['健康状态']=='正常' and r['自检结果']=='正常；未通知' for r in health)
 checks['观察ID无重复']=len(obs)==len({r['观察ID'] for r in obs})
 checks['三条负流量已隔离']=len([r for r in obs if r['统一数值'] and float(r['统一数值'])<0 and r['质量有效']=='0'])==3
 checks['9条生产流程启用']=sum(w['status']=='enabled' for w in workflows)==9
 for key,w in state['cloud_workflows'].items():
  current=cli('+workflow-get','--workflow-id',w['workflow_id']);current=current.get('workflow',current)
  if key=='INGEST':checks['旧入库方案已停用']=current['status']=='disabled';continue
  hhmm='18:30' if key in SOURCES else '18:40' if key.startswith('DIRECT-') else '19:10'
  timer=current['steps'][0]['data'];checks[key+'正式排程']=timer.get('rule')=='DAILY' and timer.get('start_time','').endswith(hhmm)
 report={'at':datetime.now().isoformat(),'status':'completed' if all(checks.values()) else 'partial','checks':checks,'observation_count':len(obs),'raw_runs':len(raw),'scope':'三种已接入数据的云端采集/解析/入库/去重；工程验证非财务核验','remaining':['三峡入库流量接口','向家坝入库流量接口','公告增量与PDF解析','积压记录额外补跑机制','异常通知失败分支未注入故障演练']}
 (run/'manifest.json').write_text(json.dumps(report,ensure_ascii=False,indent=2));print(json.dumps(report,ensure_ascii=False,indent=2));print('REPORT',run)
if __name__=='__main__':main()
