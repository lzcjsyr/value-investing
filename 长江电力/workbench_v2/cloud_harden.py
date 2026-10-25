from cloud import *
def main():
 for code in SOURCES:
  wid=state['cloud_workflows'][code]['workflow_id'];x=cli('+workflow-get','--workflow-id',wid)
  if 'workflow' in x:x=x['workflow']
  steps=x['steps']
  if not any(s['id']=='begin' for s in steps):
   raw=next(s for s in steps if s['id']=='raw')
   initial=[f for f in raw['data']['field_values'] if f['field_name']!='原始响应']
   initial=[dict(f,value=[val('采集中')]) if f['field_name']=='处理状态' else f for f in initial]
   steps.insert(1,step('begin','AddRecordAction',{'table_name':R,'field_values':initial},'http'))
   steps[0]['next']='begin'
   raw['type']='SetRecordAction';raw['data']={'table_name':R,'ref_info':{'step_id':'begin'},'field_values':fields({'原始响应':val('$.http','ref'),'处理状态':val('已抓取待校验')})}
  steps[0]['data']['start_time']=(datetime.now()+timedelta(minutes=2)).strftime('%Y-%m-%d %H:%M')
  cli('+workflow-update','--workflow-id',wid,'--json',json.dumps({'title':x['title'],'steps':steps},ensure_ascii=False))
  print('HARDENED',code,steps[0]['data']['start_time'],flush=True)
 formulas(R,{'运行结果':'IF([已有观察数]>0,"完成（已入库或去重）",IF([处理状态]="采集中","未完成：检查工作流HTTP运行日志",IF([校验V2]=1,"校验通过待入库","部分完成：解析或日期数值校验失败")))'})
 h='V2_11市场观察'
 cli('+field-list','--table-id',state['tables'][h])
 for name in ['国债收益率观察（%，中证口径）','三峡入库流量（立方米/秒）','三峡库水位（米）']:
  bid=state['blocks'][name]['block']['block_id'];x=cli('+dashboard-block-get','--dashboard-id',state['dashboard'],'--block-id',bid)
  cfg=x.get('block',x)['data_config']; filt=cfg['filter'];filt['conditions']=[c for c in filt['conditions'] if c['field_name']!='质量有效']+[{'field_name':'质量有效','operator':'is','value':1}]
  cli('+dashboard-block-update','--dashboard-id',state['dashboard'],'--block-id',bid,'--data-config',json.dumps({'filter':filt,'series':[{'field_name':'统一数值','rollup':'MAX'}]},ensure_ascii=False))
if __name__=='__main__':main()
