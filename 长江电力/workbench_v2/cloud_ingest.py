from cloud import *
H='V2_11市场观察'
def main():
 cli('+field-list','--table-id',state['tables'][H])
 formulas(R,{'原始ID':'RECORD_ID()','已有观察数':f'[{H}].COUNTIF(CurrentValue.[观察ID]=[观察键V2])','允许入库':f'IF(AND([校验V2]=1,[已有观察数]=0,[{R}].FILTER(CurrentValue.[观察键V2]=[观察键V2]).SORTBY([{R}].[采集时间],TRUE()).[原始ID].FIRST()=RECORD_ID()),1,0)'})
 fs=cli('+field-list','--table-id',state['tables'][R])['fields']; fid={x['name']:x['id'] for x in fs}
 cli('+field-list','--table-id',state['tables'][H])
 def ref(name):
  name={'观察键':'观察键V2','观测日期':'日期V2','数值候选':'数值V2'}.get(name,name)
  return val('$.loop.item.'+fid[name],'ref')
 def filt(name,value):return {'conjunction':'and','conditions':[{'field_name':name,'operator':'is','value':[value]}]}
 start=(datetime.now()+timedelta(minutes=2)).strftime('%Y-%m-%d %H:%M')
 steps=[step('timer','TimerTrigger',{'rule':'DAILY','start_time':start,'is_never_end':True},'find'),
 step('find','FindRecordAction',{'table_name':R,'field_names':list(fid),'should_proceed_when_no_results':False,'filter_info':filt('允许入库',val('1'))},'loop'),
 dict(step('loop','Loop',{'data':[val('$.find.fieldRecords','ref')],'max_loop_times':5,'loop_mode':'end'}),children={'links':[{'kind':'loop_start','to':'add'}]}),
 step('add','AddRecordAction',{'table_name':H,'field_values':fields({'观察ID':ref('观察键'),'指标':ref('指标代码'),'指标代码':ref('指标代码'),'日期':ref('观测日期'),'云端数值原文':ref('数值候选'),'单位':ref('单位'),'来源':ref('来源网址'),'采集时间':ref('采集时间文本'),'原始文件':[val(f'https://b7okxcyuao.feishu.cn/base/{BASE}?table='+state['tables'][R]+'&record='),val('$.loop.item.recordId','ref')],'使用边界':val('飞书云端HTTP与规则校验；非财报核验。不同来源不混接；不自动改估值参数。')})},'done'),
 step('done','SetRecordAction',{'table_name':R,'filter_info':filt('运行标识',ref('运行标识')),'max_set_record_num':1,'field_values':fields({'处理状态':val('完成（新增或已去重）')})})]
 body={'client_token':str(uuid.uuid4()),'title':'V2云端校验去重入库','steps':steps}
 x=cli('+workflow-create','--json',json.dumps(body,ensure_ascii=False));state.setdefault('cloud_workflows',{})['INGEST']=x;save()
 cli('+workflow-enable','--workflow-id',x['workflow_id']);print(x['workflow_id'],start)
if __name__=='__main__':main()
