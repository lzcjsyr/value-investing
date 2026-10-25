from cloud_health import *
def main():
 for name,columns in [(R,['运行标识','指标代码','采集时间','日期V2','数值V2','运行结果','来源网址']),(C,['指标','接入状态','最近采集','最近观察日','健康状态','来源说明','工作流入口']),(H,['观察ID','指标','指标代码','日期','统一数值','单位','来源','质量有效','采集时间','原始文件'])]:
  cli('+field-list','--table-id',state['tables'][name]);key=name+'-云端工作视图'
  if key not in state.get('views',{}):
   cli('+view-create','--table-id',state['tables'][name],'--json',json.dumps({'name':'云端工作视图','type':'grid'},ensure_ascii=False))
   cli('+view-set-visible-fields','--table-id',state['tables'][name],'--view-id','云端工作视图','--json',json.dumps({'visible_fields':columns},ensure_ascii=False))
   state.setdefault('views',{})[key]=True;save()
 blocks=[('云端数据健康状态','bar',{'table_name':C,'count_all':True,'group_by':[{'field_name':'健康状态','sort':{'type':'view','order':'asc'}}]}),('云端覆盖与限制','text',{'text':'## 云端采集（电脑离线也可运行）\n18:30抓取 → 18:40校验去重入库 → 19:10异常检查。\n已接入：股价（腾讯）、国债10年（中债）、三峡库水位（长江水文网）。\n待接通：三峡/向家坝入库流量、公司公告与PDF解析。\n原始响应及每次运行状态保存在V2_14；V2_15查看健康状态。不同来源独立存储，不自动改估值假设。\n历史水文负流量已从有效看板隔离；原值保留待核验。'})]
 for code,(name,url,unit) in SOURCES.items():
  blocks.append(('云端 · '+name+'（'+unit+'）','line',{'table_name':H,'series':[{'field_name':'统一数值','rollup':'MAX'}],'group_by':[{'field_name':'日期','sort':{'type':'group','order':'asc'}}],'filter':{'conjunction':'and','conditions':[{'field_name':'指标代码','operator':'is','value':code},{'field_name':'当前有效数','operator':'is','value':1},{'field_name':'质量有效','operator':'is','value':1}]}}))
 for name,typ,cfg in blocks:
  if name not in state['blocks']:
   state['blocks'][name]=cli('+dashboard-block-create','--dashboard-id',state['dashboard'],'--name',name,'--type',typ,'--data-config',json.dumps(cfg,ensure_ascii=False));save()
 group='V2 · 云端自动化'
 if group not in state['folders']:
  state['folders'][group]=cli('+base-block-create','--type','folder','--name',group);save()
 x=state['folders'][group];folder=x.get('block',{}).get('id') or x.get('id') or x.get('block_id')
 for bid in [state['tables'][C],state['tables'][R]]+[x['workflow_id'] for x in state['cloud_workflows'].values()]:
  cli('+base-block-move','--block-id',bid,'--parent-id',folder)
 cli('+dashboard-arrange','--dashboard-id',state['dashboard'])
 print('CLOUD PRESENTED')
if __name__=='__main__':main()
