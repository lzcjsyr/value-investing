from cloud import *
def main():
 key='INGEST';wid=state['cloud_workflows'][key]['workflow_id'];x=cli('+workflow-get','--workflow-id',wid)
 if 'workflow' in x:x=x['workflow']
 x['steps'][0]['data']['start_time']=(datetime.now()+timedelta(minutes=2)).strftime('%Y-%m-%d %H:%M')
 find=next(s for s in x['steps'] if s['id']=='find')
 find['data']['filter_info']={'conjunction':'and','conditions':[{'field_name':'入库指令','operator':'is','value':[val('待入库')]}]}
 cli('+workflow-update','--workflow-id',wid,'--json',json.dumps({'title':x['title'],'steps':x['steps']},ensure_ascii=False))
 print('RETEST',x['steps'][0]['data']['start_time'])
if __name__=='__main__':main()
