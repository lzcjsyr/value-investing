from cloud_health import *
def main():
 fs=cli('+field-list','--table-id',state['tables'][C])['fields'];fid={f['name']:f['id'] for f in fs}
 if '最近自检' not in fid:
  cli('+field-create','--table-id',state['tables'][C],'--json',json.dumps([{'name':'最近自检','type':'datetime'},t('自检结果')],ensure_ascii=False))
 uid=state['cloud_workflows']['TENCENT-600900']['creator_id']
 steps=[step('timer','TimerTrigger',{'rule':'DAILY','start_time':'2026-09-20 19:10','is_never_end':True},'find0')]
 for i,code in enumerate(SOURCES):
  fil={'conjunction':'and','conditions':[{'field_name':'指标代码','operator':'is','value':[val(code)]}]}
  nxt='find'+str(i+1) if i<2 else None
  steps.append(step('find'+str(i),'FindRecordAction',{'table_name':C,'field_names':['指标','健康状态','最近观察日'],'should_proceed_when_no_results':False,'filter_info':fil},'check'+str(i)))
  steps.append(dict(step('check'+str(i),'IfElseBranch',{'condition':{'conjunction':'or','conditions':[{'conjunction':'and','conditions':[{'left_value':val('$.find'+str(i)+'.firstfieldsRecord.'+fid['健康状态'],'ref'),'operator':'is','right_value':[val('正常')]}]}]}},nxt),children={'links':[{'kind':'if_true','to':'ok'+str(i)},{'kind':'if_false','to':'alert'+str(i)}]}))
  steps.append(step('ok'+str(i),'SetRecordAction',{'table_name':C,'filter_info':fil,'max_set_record_num':1,'field_values':fields({'最近自检':val('now','date'),'自检结果':val('正常；未通知')})}))
  steps.append(step('alert'+str(i),'LarkMessageAction',{'receiver':[val({'id':uid},'user')],'send_to_everyone':False,'title':[val('长江电力云端采集异常：'+SOURCES[code][0])],'content':[val('状态：'),val('$.find'+str(i)+'.firstfieldsRecord.'+fid['健康状态'],'ref'),val('\n请查看V2_15云端采集控制及工作流运行日志。不会自动更改估值假设。\n'+f'https://b7okxcyuao.feishu.cn/base/{BASE}?table='+state['tables'][C])],'btn_list':[]},'bad'+str(i)))
  steps.append(step('bad'+str(i),'SetRecordAction',{'table_name':C,'filter_info':fil,'max_set_record_num':1,'field_values':fields({'最近自检':val('now','date'),'自检结果':val('异常；已通知')})}))
 wid=state['cloud_workflows']['HEALTH']['workflow_id'];cli('+workflow-get','--workflow-id',wid)
 cli('+workflow-update','--workflow-id',wid,'--json',json.dumps({'title':'V2云端异常检查（正常不通知）','steps':steps},ensure_ascii=False))
 cli('+workflow-enable','--workflow-id',wid)
 print('HEALTH DIRECT CONFIGURED')
if __name__=='__main__':main()
