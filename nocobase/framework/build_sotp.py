"""分部加总的业务估值、资产估值与调整；全部金额来自数据库，不在页面复算估值。"""
JS = r"""const COMPANY = '__COMPANY__';
const { React } = ctx.libs;
const { useState } = React;
const { Card, Segmented, Table, Alert, Typography, Row, Col, Statistic, Collapse, Descriptions, Tag } = ctx.libs.antd;
const { Text, Paragraph, Title } = Typography;
async function listRows(name, filter, appends) {
  const r = ctx.makeResource('MultiRecordResource');
  r.setResourceName(name); r.setPageSize?.(1000); r.setFilter?.(filter);
  if(appends) r.setAppends?.(appends);
  await r.refresh(); return r.getData() || [];
}
const numeric = (v) => v !== null && v !== undefined && v !== '' && Number.isFinite(Number(v));
const fmt = (v,d=1) => numeric(v) ? Number(v).toLocaleString('zh-CN',{minimumFractionDigits:d,maximumFractionDigits:d}) : '—';
const pickScenario = (rows, scenario) => {
  const picked = new Map();
  rows.filter(r => r.scenario_id == null || String(r.scenario_id) === String(scenario.id))
    .sort((a,b) => Number(a.scenario_id != null) - Number(b.scenario_id != null))
    .forEach(r => picked.set(r.business_id && r.method ? 'business:'+r.business_id : 'code:'+r.code,r));
  return [...picked.values()].sort((a,b) => String(a.code).localeCompare(String(b.code),undefined,{numeric:true}));
};
try {
 const [company] = await listRows('vi_company',{code:{$eq:COMPANY}});
 if (!company) throw new Error('公司不存在');
 const [model] = await listRows('vi_model',{company_id:{$eq:company.id},status:{$eq:'当前'}});
 if (!model) {ctx.render(<Alert type="info" message="尚无当前估值模型" />);} else {
  const scope = {company_id:{$eq:company.id}}, byModel = {model_id:{$eq:model.id}};
  const [businesses,canvas,scenarios,totals,segments,assets,values] = await Promise.all([
    listRows('vi_business',scope),listRows('vi_biz_model',scope,['facts']),listRows('vi_scenario',byModel),
    listRows('vi_sotp',byModel),listRows('vi_sotp_segment',byModel),listRows('vi_sotp_item',byModel,['facts','metric']),listRows('vi_sotp_segment_val',byModel),
  ]);
  scenarios.sort((a,b)=>(a.sort||0)-(b.sort||0));
  const base = scenarios.find(s=>s.is_base)||scenarios[0];
  if (!base) throw new Error('尚未建立估值情景');
  function Page() {
   const [sid,setSid] = useState(String(base.id));
   const scenario = scenarios.find(s=>String(s.id)===String(sid))||base;
   const total = totals.find(t=>String(t.id)===String(scenario.id))||{};
   const businessOf = r => businesses.find(b=>String(b.id)===String(r.business_id));
   const businessRows = values.filter(v=>String(v.scenario_id)===String(scenario.id)).map(v=>{
     const input=segments.find(r=>String(r.id)===String(v.segment_id))||{};
     return {...input,...v,key:v.id,businessName:businessOf(v)?.name||v.name};
   }).sort((a,b)=>String(a.code).localeCompare(String(b.code),undefined,{numeric:true}));
   if (numeric(total.core_value)) businessRows.unshift({key:'core',code:'核心业务',businessName:'核心业务（预测模型）',method:'核心盈利×倍数',value:total.core_value});
   const assetRows = pickScenario(assets,scenario);
   const evidence = facts => (facts||[]).map(f=>f.title).join('；') || '待补充';
   return <div>
    <Title level={4} style={{marginTop:0}}>{company.name} · 业务估值＋资产估值与调整</Title>
    <Paragraph type="secondary">资产负债日 {total.as_of||'—'}；金额为亿元人民币。每股价值＝（业务估值合计＋资产估值与调整净额）÷股本。</Paragraph>
    <Segmented value={sid} onChange={setSid} options={scenarios.map(s=>({label:s.name,value:String(s.id)}))} />
    {total.asset_incomplete>0 && <Alert type="warning" showIcon style={{marginTop:12}} message={total.conclusion} />}
    {!numeric(total.equity_value) && !(total.asset_incomplete>0) && <Alert type="warning" showIcon style={{marginTop:12}} message={total.conclusion||'估值输入尚不完整'} />}
    <Row gutter={[12,12]} style={{margin:'16px 0'}}>
     <Col xs={12} md={6}><Statistic title="业务估值合计" value={fmt(total.business_value)} suffix="亿元" /></Col>
     <Col xs={12} md={6}><Statistic title="资产估值与调整净额" value={fmt(total.asset_value)} suffix="亿元" /></Col>
     <Col xs={12} md={6}><Statistic title="股权价值" value={fmt(total.equity_value)} suffix="亿元" /></Col>
     <Col xs={12} md={6}><Statistic title="每股价值" value={fmt(total.value_per_share,2)} suffix={numeric(total.value_per_share_quote)?`元 ≈ ${fmt(total.value_per_share_quote,2)} 港元`:'元'} /></Col>
    </Row>
    <Card size="small" title="业务估值" style={{marginBottom:16}}>
     <Table rowKey="key" pagination={false} dataSource={businessRows} columns={[
       {title:'业务',dataIndex:'businessName'}, {title:'估值方法',dataIndex:'method'}, {title:'发展阶段',dataIndex:'stage'},
       {title:'盈利年份',dataIndex:'earn_year'}, {title:'分部价值（亿元）',key:'value',align:'right',render:(_,r)=>fmt(r.value)},
     ]} />
     <Collapse ghost items={businessRows.filter(r=>r.business_id).map(r=>{
       const b=businessOf(r), rows=canvas.filter(c=>String(c.business_id)===String(r.business_id)).sort((a,b)=>String(a.code).localeCompare(String(b.code),undefined,{numeric:true}));
       return {key:r.id,label:`${r.code} ${b?.name||r.name}：商业模式与估值依据`,children:<div>
        <Descriptions column={1} size="small" bordered items={[
         ['业务边界',b?.boundary],['费用分摊',b?.cost_allocation],['经营资产与投入',b?.asset_boundary],['估值依据',r.basis],
        ].filter(([,v])=>v).map(([label,v])=>({key:label,label,children:v}))} />
        <Collapse ghost items={rows.map(c=>({key:c.id,label:c.element+'：'+c.title,children:<div><Paragraph>{c.content}</Paragraph><Paragraph type="secondary">{c.trend}</Paragraph><Paragraph type="secondary">依据事实：{evidence(c.facts)}</Paragraph></div>}))} />
       </div>};
     })} />
    </Card>
    <Card size="small" title="资产估值与调整" style={{marginBottom:16}}>
     <Table rowKey="id" pagination={false} dataSource={assetRows} columns={[
      {title:'项目',dataIndex:'name'},{title:'类别',dataIndex:'kind'},{title:'计价处理',dataIndex:'treatment'},
      {title:'相关业务',key:'businessName',render:(_,r)=>businessOf(r)?.name||'集团'},
      {title:'计价依据',dataIndex:'valuation_method'},{title:'金额（亿元）',dataIndex:'amount_used',align:'right',render:v=>fmt(v)},{title:'取数',key:'metricName',render:(_,r)=>r.metric?.name||'手填'},
      {title:'折价',dataIndex:'haircut',align:'right',render:v=>numeric(v)?fmt(Number(v)*100,0)+'%':'—'},
      {title:'计入价值（亿元）',dataIndex:'signed_value',align:'right',render:v=>fmt(v)},
     ]} />
     <Paragraph type="secondary" style={{marginTop:12}}>已含业务估值的经营固定资产仅登记边界，不再加总；金额空白表示独立资产金额未知。可独立处置的固定资产或其他非经营资产，可在排除相关业务收益后选择单独计价。</Paragraph>
     <Collapse ghost items={assetRows.map(r=>({key:r.id,label:r.code+' '+r.name+'：计价边界与依据',children:<Descriptions size="small" column={1} bordered items={[
       ['计价边界',r.boundary],['依据',r.basis],['截至',r.as_of],['依据事实',evidence(r.facts)],
     ].filter(([,v])=>v).map(([label,v])=>({key:label,label,children:v}))} />
     }))} />
    </Card>
    <Card size="small" title={totals.some(r=>r.ddm_value!==null&&r.ddm_value!==undefined)?"情景汇总与交叉验证":"情景汇总"}>
     <Table rowKey="id" pagination={false} dataSource={totals} columns={[
      {title:'情景',dataIndex:'scenario_name'}, {title:'业务估值（亿元）',dataIndex:'business_value',align:'right',render:v=>fmt(v)},
      {title:'资产调整净额（亿元）',dataIndex:'asset_value',align:'right',render:v=>fmt(v)},
      {title:'股权价值（亿元）',dataIndex:'equity_value',align:'right',render:v=>fmt(v)},
      {title:'每股价值（元）',dataIndex:'value_per_share',align:'right',render:v=>fmt(v,2)},
      {title:'每股价值（港元）',dataIndex:'value_per_share_quote',align:'right',render:v=>fmt(v,2)},
      ...(totals.some(r=>r.ddm_value!==null&&r.ddm_value!==undefined)?[{title:'股东回报折现（元）',dataIndex:'ddm_value',align:'right',render:v=>fmt(v,2)}]:[]),   // 只用分部加总的公司没有股息贴现
     ]} />
     <Paragraph type="secondary" style={{marginTop:12}}>业务参数、资产项目分别在本页编辑标签维护；业务边界及画布在“商业模式拆解”维护。{totals.some(r=>r.ddm_value!==null&&r.ddm_value!==undefined)?'股东回报折现作为集团口径交叉验证。':''}</Paragraph>
    </Card>
   </div>;
  }
  ctx.render(<Page />);
 }
} catch(error) {ctx.render(<Alert type="error" showIcon message="分部估值读取失败" description={String(error?.message||error)} />);}
"""
