import json
from build import *
H='V2_11市场观察';T='V2_12估值敏感性'
def finish():
    table(H,[t('观察ID'),t('指标'),t('指标代码'),t('日期'),n('数值'),t('单位'),t('来源'),t('采集时间'),t('原始文件'),t('使用边界')])
    table(T,[t('组合'),link('基准情景',S),n('利率偏移'),n('增长偏移')])
    rows(T,[{'组合':f'r{dr:+.3f}/g{dg:+.3f}','基准情景':refs([state['rows'][S][1]]),'利率偏移':dr,'增长偏移':dg} for dr in [-.01,-.005,0,.005,.01] for dg in [-.01,-.005,0,.005,.01]])
    fs={x:f'[基准情景].[{x}].FIRST()' for x in ['估值基年','终值年份','股本亿股']}
    fs['折现率']='[基准情景].[折现率].FIRST()+[利率偏移]';fs['永续增长率']='[基准情景].[永续增长率].FIRST()+[增长偏移]'
    parts=[f'[{F}].FILTER(AND(CurrentValue.[情景名称]="基准",CurrentValue.[年份]={yr})).[计划股息亿元].FIRST()/POWER(1+[折现率],{yr}-[估值基年])' for yr in range(2026,2036)]
    fs['预测期现值亿元']='+'.join(parts)
    fs['终年股息亿元']=f'[{F}].FILTER(AND(CurrentValue.[情景名称]="基准",CurrentValue.[年份]=[终值年份])).[计划股息亿元].FIRST()'
    fs['条件DDM元']='IF(AND([折现率]>[永续增长率],[股本亿股]>0),([预测期现值亿元]+[终年股息亿元]*(1+[永续增长率])/([折现率]-[永续增长率])/POWER(1+[折现率],[终值年份]-[估值基年]))/[股本亿股],"")'
    fs['性质']='"基准现金股息路径不变；r与g独立敏感性，非新增事实"'
    formulas(T,fs)
    for name,columns in [
      (F,['模型键','情景名称','年份','收入亿元','归母利润代理亿元','计划股息亿元','所有者收益亿元','FCFE亿元','资金缺口亿元','计算状态']),
      (V,['情景','条件DDM元','终值占比','现金支持DDM元','关注价10元','关注价30元','决策状态']),
      (I,['年度键','年份','电量亿千瓦时','电价元','付现成本亿元','折旧亿元','利息亿元','证据状态']),
      (M,['映射ID','业务论点','事实层','判断层','参数键','数学传导','证据','判断状态']),
      (E,['证据ID','报告期','事实或原始记录','核验状态','原始链接']),
      (K,['任务ID','跟踪指标','频率','触发阈值','触发后动作','采集状态'])]:
        key=name+'-简洁视图'
        if key in state.get('views',{}):continue
        cli('+field-list','--table-id',state['tables'][name])
        cli('+view-create','--table-id',state['tables'][name],'--json',json.dumps({'name':'日常工作视图','type':'grid'},ensure_ascii=False))
        cli('+view-set-visible-fields','--table-id',state['tables'][name],'--view-id','日常工作视图','--json',json.dumps({'visible_fields':columns},ensure_ascii=False))
        state.setdefault('views',{})[key]=True;save()
    if 'dashboard' not in state:
        x=cli('+dashboard-create','--name','V2价值投资驾驶舱')
        state['dashboard']=x.get('dashboard_id') or x.get('dashboard',{}).get('dashboard_id')
        if not state['dashboard']:print(x);raise RuntimeError('dashboard id')
        save()
    for name in [V,F,Q,H,E]:cli('+field-list','--table-id',state['tables'][name])
    blocks=[
      ('先看模型质量，再看估值','text',{'text':'# 长江电力 · 价值投资驾驶舱\n事实 → 判断 → 参数 → 财务 → 估值 → 证伪\n\n**当前为条件模型，旧财务假设尚待原件核验。** 估值基准为2025年末，不能直接视为今天的目标价。现金桥接缺失时不输出现金支持估值。市场观察独立更新，不自动覆盖长期折现率。'}),
      ('三情景条件DDM（元/股）','column',{'table_name':V,'series':[{'field_name':'条件DDM元','rollup':'MAX'}],'group_by':[{'field_name':'情景','sort':{'type':'view','order':'asc'}}]}),
      ('两档安全边际关注价（元/股）','column',{'table_name':V,'series':[{'field_name':'关注价10元','rollup':'MAX'},{'field_name':'关注价30元','rollup':'MAX'}],'group_by':[{'field_name':'情景','sort':{'type':'view','order':'asc'}}]}),
      ('基准利润与计划股息（亿元）','line',{'table_name':F,'series':[{'field_name':'归母利润代理亿元','rollup':'SUM'},{'field_name':'计划股息亿元','rollup':'SUM'}],'group_by':[{'field_name':'年份','sort':{'type':'group','order':'asc'}}],'filter':{'conjunction':'and','conditions':[{'field_name':'情景名称','operator':'is','value':'基准'}]}}),
      ('终值占比：越高越依赖远期假设','column',{'table_name':V,'series':[{'field_name':'终值占比','rollup':'MAX'}],'group_by':[{'field_name':'情景','sort':{'type':'view','order':'asc'}}]}),
      ('质量检查状态','bar',{'table_name':Q,'count_all':True,'group_by':[{'field_name':'状态','sort':{'type':'value','order':'desc'}}]}),
      ('证据核验进度','bar',{'table_name':E,'count_all':True,'group_by':[{'field_name':'核验状态','sort':{'type':'value','order':'desc'}}]}),
      ('国债收益率观察（%，中证口径）','line',{'table_name':H,'series':[{'field_name':'数值','rollup':'MAX'}],'group_by':[{'field_name':'日期','sort':{'type':'group','order':'asc'}}],'filter':{'conjunction':'and','conditions':[{'field_name':'指标代码','operator':'is','value':'M1001654'}]}}),
      ('研究纪律与操作入口','text',{'text':'## 从哪里开始\n1. V2_09质量检查：先处理关键缺口。\n2. V2_02证据账本：登记原文、报告期和口径。\n3. V2_03事实判断映射：写清为什么改、改哪年、什么情况不改。\n4. V2_05年度假设与V2_04情景控制：修改输入，公式自动重算。\n5. V2_10变更日志：保留旧值、新值、理由和验证。\n\n## 三条底线\n- 折旧不是免费现金；资本更新不能漏。\n- 偿债、扩张和分红不能重复使用同一笔现金。\n- 好公司与好价格分开判断；先问什么会导致永久损失。'})]
    for name,typ,config in blocks:
        if name in state.get('blocks',{}):continue
        x=cli('+dashboard-block-create','--dashboard-id',state['dashboard'],'--name',name,'--type',typ,'--data-config',json.dumps(config,ensure_ascii=False))
        state.setdefault('blocks',{})[name]=x;save();print('BLOCK',name,flush=True)
    if not state.get('arranged'):
        cli('+dashboard-arrange','--dashboard-id',state['dashboard']);state['arranged']=True;save()
    print('FINISHED',flush=True)
if __name__=='__main__':finish()
