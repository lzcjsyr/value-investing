from cloud_health import *
def main():
 fs=cli('+field-list','--table-id',state['tables'][C])['fields'];fid={f['name']:f['id'] for f in fs}
 uid=state['cloud_workflows']['TENCENT-600900']['creator_id']
 for i,code in reversed(list(enumerate(SOURCES))):
  key='HEALTH' if i==0 else 'HEALTH-'+code
  start=(datetime.now()+timedelta(minutes=2)).strftime('%Y-%m-%d %H:%M')
  fil={'conjunction':'and','conditions':[{'field_name':'指标代码','operator':'is','value':[val(code)]}]}
  health=val('$.find.firstfieldsRecord.'+fid['健康状态'],'ref')
  def mark(s,msg):return step(s,'SetRecordAction',{'table_name':C,'filter_info':fil,'max_set_record_num':1,'field_values':fields({'最近自检':val('now','date'),'自检结果':val(msg)})})
  steps=[step('timer','TimerTrigger',{'rule':'DAILY','start_time':start,'is_never_end':True},'find'),step('find','FindRecordAction',{'table_name':C,'field_names':['指标','健康状态','最近观察日'],'should_proceed_when_no_results':False,'filter_info':fil},'check'),
   dict(step('check','IfElseBranch',{'condition':{'conjunction':'or','conditions':[{'conjunction':'and','conditions':[{'left_value':health,'operator':'is','right_value':[val('正常')]}]}]}}),children={'links':[{'kind':'if_true','to':'ok'},{'kind':'if_false','to':'alert'}]}),
   mark('ok','正常；未通知'),
   step('alert','LarkMessageAction',{'receiver':[val({'id':uid},'user')],'send_to_everyone':False,'title':[val('长江电力云端采集异常：'+SOURCES[code][0])],'content':[val('状态：'),health,val('\n请查看采集控制与执行日志。\n'+f'https://b7okxcyuao.feishu.cn/base/{BASE}?table='+state['tables'][C])],'btn_list':[]},'bad'),mark('bad','异常；已通知')]
  body={'title':'V2云端异常自检 · '+SOURCES[code][0],'steps':steps}
  if key in state['cloud_workflows']:
   wid2=state['cloud_workflows'][key]['workflow_id'];cli('+workflow-get','--workflow-id',wid2);cli('+workflow-update','--workflow-id',wid2,'--json',json.dumps(body,ensure_ascii=False))
  else:
   body['client_token']=str(uuid.uuid4());w=cli('+workflow-create','--json',json.dumps(body,ensure_ascii=False));state['cloud_workflows'][key]=w;save();wid2=w['workflow_id']
  cli('+workflow-enable','--workflow-id',wid2);print(key,start,flush=True)
if __name__=='__main__':main()
