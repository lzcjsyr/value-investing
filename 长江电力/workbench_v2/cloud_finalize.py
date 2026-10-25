from cloud_health import *
def main():
 for key,w in state['cloud_workflows'].items():
  wid=w['workflow_id'];x=cli('+workflow-get','--workflow-id',wid)
  if 'workflow' in x:x=x['workflow']
  if key=='INGEST':
   cli('+workflow-disable','--workflow-id',wid)
   cli('+workflow-update','--workflow-id',wid,'--json',json.dumps({'title':'V2入库早期方案（已停用）','steps':x['steps']},ensure_ascii=False))
   continue
  hhmm='18:30' if key in SOURCES else '18:40' if key.startswith('DIRECT-') else '19:10'
  x['steps'][0]['data'].update(rule='DAILY',start_time=datetime.now().strftime('%Y-%m-%d')+' '+hhmm,is_never_end=True)
  cli('+workflow-update','--workflow-id',wid,'--json',json.dumps({'title':x['title'],'steps':x['steps']},ensure_ascii=False))
  current=cli('+workflow-get','--workflow-id',wid)
  state['cloud_workflows'][key]=current.get('workflow',current);save()
  print(key,hhmm,flush=True)
 if not state.get('cloud_guide_record'):
  state['cloud_guide_record']=cli('+record-batch-create','--table-id',state['tables'][G],'--json',json.dumps({'create_records':[{'主题':'云端自动化入口与边界','规则与操作':'打开V2 · 云端自动化→V2_15云端采集控制。每天18:30采集股价/中债10年收益率/三峡水位，18:40独立校验去重入库，19:10异常自检；不依赖电脑。三峡/向家坝入库流量、公告和PDF自动研究尚待接通。原始响应在V2_14，市场表看统一数值；不自动改估值假设。','适用范围':'持续采集；非财报核验'}]},ensure_ascii=False));save()
 print('FINAL SCHEDULES SAVED')
if __name__=='__main__':main()
