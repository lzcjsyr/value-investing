from cloud import *
H='V2_11市场观察'
def main():
 fs=cli('+field-list','--table-id',state['tables'][R])['fields'];fid={x['name']:x['id'] for x in fs}
 cli('+field-list','--table-id',state['tables'][H])
 def ref(name):return val('$.find.firstfieldsRecord.'+fid[name],'ref')
 def condition(name,v):return {'field_name':name,'operator':'is','value':[v]}
 def branch(i,left,right,yes,no):
  return dict(step(i,'IfElseBranch',{'condition':{'conjunction':'or','conditions':[{'conjunction':'and','conditions':[{'left_value':left,'operator':'is','right_value':[right]}]}]}}),children={'links':[{'kind':'if_true','to':yes},{'kind':'if_false','to':no}]})
 for code in SOURCES:
  key='DIRECT-'+code
  start=(datetime.now()+timedelta(minutes=2)).strftime('%Y-%m-%d %H:%M')
  def finish(i,msg):return step(i,'SetRecordAction',{'table_name':R,'max_set_record_num':1,'filter_info':{'conjunction':'and','conditions':[condition('运行标识',ref('运行标识'))]},'field_values':fields({'处理状态':val(msg)})})
  steps=[step('timer','TimerTrigger',{'rule':'DAILY','start_time':start,'is_never_end':True},'find'),
   step('find','FindRecordAction',{'table_name':R,'field_names':list(fid),'should_proceed_when_no_results':False,'filter_info':{'conjunction':'and','conditions':[condition('指标代码',val(code)),condition('处理状态',val('已抓取待校验'))]}},'valid'),
   branch('valid',ref('校验V2'),val('1'),'duplicate','invalid'),
   step('duplicate','FindRecordAction',{'table_name':H,'field_names':['观察ID'],'should_proceed_when_no_results':True,'filter_info':{'conjunction':'and','conditions':[condition('观察ID',ref('观察键V2'))]}},'new'),
   branch('new',val('$.duplicate.recordNum','ref'),val(0,'number'),'add','skip'),
   step('add','AddRecordAction',{'table_name':H,'field_values':fields({'观察ID':ref('观察键V2'),'指标':val(SOURCES[code][0]),'指标代码':val(code),'日期':ref('日期V2'),'云端数值原文':ref('数值V2'),'单位':ref('单位'),'来源':ref('来源网址'),'采集时间':ref('采集时间文本'),'原始文件':val(f'https://b7okxcyuao.feishu.cn/base/{BASE}?table='+state['tables'][R]),'使用边界':val('飞书原生云端采集；通过基础解析与范围校验，非财务核验；不得自动改变估值假设。')})},'done'),finish('done','完成（新增或已去重）'),finish('invalid','异常：校验未通过')]
  steps.append(finish('skip','完成（重复观察未新增）'))
  if key in state.get('cloud_workflows',{}):
   wid=state['cloud_workflows'][key]['workflow_id'];old=cli('+workflow-get','--workflow-id',wid)
   cli('+workflow-update','--workflow-id',wid,'--json',json.dumps({'title':state['cloud_workflows'][key]['title'],'steps':steps},ensure_ascii=False));x=state['cloud_workflows'][key]
  else:
   x=cli('+workflow-create','--json',json.dumps({'client_token':str(uuid.uuid4()),'title':'V2云端入库 · '+SOURCES[code][0],'steps':steps},ensure_ascii=False));state['cloud_workflows'][key]=x;save()
  cli('+workflow-enable','--workflow-id',x['workflow_id']);print(key,start,flush=True)
 cli('+workflow-disable','--workflow-id',state['cloud_workflows']['INGEST']['workflow_id'])
if __name__=='__main__':main()
