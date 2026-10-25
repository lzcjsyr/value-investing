from cloud import *
C='V2_15云端采集控制'
H='V2_11市场观察'
def main():
 table(C,[t('指标代码'),t('指标'),t('接入状态'),n('允许观察滞后天'),t('来源说明'),t('工作流入口')])
 rows(C,[{'指标代码':code,'指标':name,'接入状态':'云端已接入','允许观察滞后天':2 if code.startswith('CJH') else 7,'来源说明':url,'工作流入口':f'https://b7okxcyuao.feishu.cn/base/{BASE}?table='+state['cloud_workflows'][code]['workflow_id']} for code,(name,url,unit) in SOURCES.items()]+[
 {'指标代码':'PENDING-SX-INFLOW','指标':'三峡入库流量','接入状态':'待接通','来源说明':'已抓官方页面未提供入库流量，不能用出库流量替代。Wind手动备份仍保留。'},
 {'指标代码':'PENDING-XJB-INFLOW','指标':'向家坝入库流量','接入状态':'待接通','来源说明':'尚无已验证的飞书可直连授权数据接口；不宣称无人值守覆盖。'},
 {'指标代码':'PENDING-ANNOUNCEMENTS','指标':'公司公告及财报','接入状态':'待接通','来源说明':'尚未部署云端公告增量、PDF解析与内容哈希去重；不宣称每日自动研究已完成。'}])
 cli('+field-list','--table-id',state['tables'][R]);cli('+field-list','--table-id',state['tables'][H])
 formulas(C,{
 '最近采集':f'[{R}].FILTER(CurrentValue.[指标代码]=[指标代码]).[采集时间].MAX()',
 '最近运行结果':f'[{R}].FILTER(CurrentValue.[指标代码]=[指标代码]).SORTBY([{R}].[采集时间],FALSE()).[运行结果].FIRST()',
 '最近观察日':f'[{H}].FILTER(CurrentValue.[指标代码]=[指标代码]).SORTBY([{H}].[日期],FALSE()).[日期].FIRST()',
 '健康状态':'IF([接入状态]!="云端已接入","待接通",IF(OR(ISBLANK([最近采集]),DAYS(NOW(),[最近采集])>1.5),"采集缺失或停摆",IF(CONTAINTEXT([最近运行结果],"未完成"),"采集未完成",IF(CONTAINTEXT([最近运行结果],"部分完成"),"解析或校验失败",IF(ISBLANK([最近观察日]),"等待首次入库",IF(DAYS(TODAY(),TODATE([最近观察日]))>[允许观察滞后天],"观察持续过期","正常"))))))',
 '异常需通知':'IF(AND([接入状态]="云端已接入",[健康状态]!="正常"),1,0)',
 })
 if 'HEALTH' not in state.get('cloud_workflows',{}):
  uid=state['cloud_workflows']['TENCENT-600900']['creator_id']
  steps=[step('timer','TimerTrigger',{'rule':'DAILY','start_time':'2026-09-20 19:10','is_never_end':True},'find'),
   step('find','FindRecordAction',{'table_name':C,'field_names':['指标','健康状态','最近观察日'],'should_proceed_when_no_results':False,'filter_info':{'conjunction':'and','conditions':[{'field_name':'异常需通知','operator':'is','value':[val('1')]}]}},'notify'),
   step('notify','LarkMessageAction',{'receiver':[val({'id':uid},'user')],'send_to_everyone':False,'title':[val('长江电力工作台：云端采集异常')],'content':[val('至少一项已接入数据源未完成采集、校验或出现持续过期。请查看云端采集控制与工作流运行日志。不会自动替换经营或估值假设。\n'),val(f'https://b7okxcyuao.feishu.cn/base/{BASE}?table='+state['tables'][C])],'btn_list':[]})]
  x=cli('+workflow-create','--json',json.dumps({'client_token':str(uuid.uuid4()),'title':'V2云端异常检查（正常不通知）','steps':steps},ensure_ascii=False));state['cloud_workflows']['HEALTH']=x;save();cli('+workflow-enable','--workflow-id',x['workflow_id'])
 print('HEALTH READY')
if __name__=='__main__':main()
