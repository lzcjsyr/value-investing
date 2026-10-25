"""Deploy Feishu-hosted collection. This file is not a scheduled collector."""
from build import *
from datetime import datetime, timedelta
import uuid

R='V2_14云端采集原始记录'
SOURCES={
 'TENCENT-600900':('长江电力股价','https://qt.gtimg.cn/q=sh600900','元'),
 'CHINABOND-CGB10Y':('中债国债10年收益率','https://yield.chinabond.com.cn/cbweb-pbc-web/pbc/more?locale=cn_zh','%'),
 'CJH-SX-LEVEL':('三峡库水位','http://www.cjh.com.cn/sqindex.html','米'),
}
def val(v,typ='text'):return {'value_type':typ,'value':v}
def step(i,typ,data,nxt=None):return {'id':i,'type':typ,'title':i,'next':nxt,'data':data}
def fields(d):return [{'field_name':k,'value':v if isinstance(v,list) else [v]} for k,v in d.items()]
def deploy():
 table(R,[t('运行标识'),t('指标代码'),t('来源网址'),t('单位'),{'name':'采集时间','type':'datetime'},t('原始响应'),t('处理状态')])
 for code,(name,url,unit) in SOURCES.items():
  if code in state.get('cloud_workflows',{}):continue
  start=(datetime.now()+timedelta(minutes=2)).strftime('%Y-%m-%d %H:%M')
  steps=[step('timer','TimerTrigger',{'rule':'DAILY','start_time':start,'is_never_end':True},'http'),
   step('http','HTTPClientAction',{'method':'GET','url':[val(url)],'body_type':'none','response_type':'text'},'raw'),
   step('raw','AddRecordAction',{'table_name':R,'field_values':fields({'运行标识':[val(code+'|'),val('$.timer.scheduleTime','ref')],'指标代码':val(code),'来源网址':val(url),'单位':val(unit),'采集时间':val('now','date'),'原始响应':val('$.http','ref'),'处理状态':val('已抓取待校验')})})]
  body={'client_token':str(uuid.uuid4()),'title':'V2云端采集 · '+name,'steps':steps}
  x=cli('+workflow-create','--json',json.dumps(body,ensure_ascii=False))
  state.setdefault('cloud_workflows',{})[code]=x;save();print(code,json.dumps(x,ensure_ascii=False),flush=True)
  wid=x.get('workflow_id') or x.get('workflow',{}).get('workflow_id')
  if not wid:raise RuntimeError('Inspect workflow response')
  cli('+workflow-enable','--workflow-id',wid)
if __name__=='__main__':deploy()
