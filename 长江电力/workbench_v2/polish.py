from build import *
from finish import H,T
from impact import P
def main():
    formulas(H,{'当前版本':f'[{H}].FILTER(AND(CurrentValue.[指标代码]=[指标代码],CurrentValue.[日期]=[日期])).SORTBY([{H}].[采集时间],FALSE()).[观察ID].FIRST()=[观察ID]'})
    formulas(H,{'当前有效数':'IF([当前版本],1,0)'})
    old=state['blocks']['国债收益率观察（%，中证口径）']['block']['block_id']
    cli('+dashboard-block-get','--dashboard-id',state['dashboard'],'--block-id',old)
    def filt(code):return {'conjunction':'and','conditions':[{'field_name':'指标代码','operator':'is','value':code},{'field_name':'当前有效数','operator':'is','value':1}]}
    cli('+dashboard-block-update','--dashboard-id',state['dashboard'],'--block-id',old,'--data-config',json.dumps({'filter':filt('M1001654')},ensure_ascii=False))
    cli('+field-list','--table-id',state['tables'][P])
    for name,typ,config in [
      ('三峡入库流量（立方米/秒）','line',{'table_name':H,'series':[{'field_name':'数值','rollup':'MAX'}],'group_by':[{'field_name':'日期','sort':{'type':'group','order':'asc'}}],'filter':filt('Z3791116')}),
      ('三峡库水位（米）','line',{'table_name':H,'series':[{'field_name':'数值','rollup':'MAX'}],'group_by':[{'field_name':'日期','sort':{'type':'group','order':'asc'}}],'filter':filt('L1680403')}),
      ('单参数变化→每股价值变化（元）','bar',{'table_name':P,'series':[{'field_name':'每股价值变化元','rollup':'MAX'}],'group_by':[{'field_name':'试验','sort':{'type':'view','order':'asc'}}]})]:
        if name not in state['blocks']:
            state['blocks'][name]=cli('+dashboard-block-create','--dashboard-id',state['dashboard'],'--name',name,'--type',typ,'--data-config',json.dumps(config,ensure_ascii=False));save()
        elif name.startswith('三峡'):
            bid=state['blocks'][name]['block']['block_id']
            cli('+dashboard-block-get','--dashboard-id',state['dashboard'],'--block-id',bid)
            cli('+dashboard-block-update','--dashboard-id',state['dashboard'],'--block-id',bid,'--data-config',json.dumps({'filter':config['filter']},ensure_ascii=False))
    cli('+dashboard-arrange','--dashboard-id',state['dashboard'])
    groups={'V2 · 研究与证据':[B,E,M],'V2 · 模型与估值':[S,I,F,V,T,P],'V2 · 跟踪与审计':[K,Q,L,H]}
    for group,names in groups.items():
        if group not in state.get('folders',{}):
            x=cli('+base-block-create','--type','folder','--name',group)
            state.setdefault('folders',{})[group]=x;save();print('FOLDER',group,json.dumps(x,ensure_ascii=False),flush=True)
        x=state['folders'][group]
        bid=x.get('block',{}).get('id') or x.get('id') or x.get('block_id')
        if not bid:raise RuntimeError('folder shape '+json.dumps(x))
        for name in names:
            cli('+base-block-move','--block-id',state['tables'][name],'--parent-id',bid)
    cli('+base-block-move','--block-id',state['dashboard'],'--before-id','tblwC6gbfMfQjipH')
    cli('+base-block-move','--block-id',state['tables'][G],'--after-id',state['dashboard'])
    print('POLISHED')
if __name__=='__main__':main()
