const { React } = ctx.libs;
const { Card, Typography, Space, Table, Collapse, theme, Divider } = ctx.libs.antd;
const { Title, Paragraph, Text, Link } = Typography;
const sections = [
 { n:'01', title:'经营与财务', sub:'把证据存清楚，让每个判断都能回到出处。', principle:'来源文档统一在“研究维护”登记；数字和事实在这里各存一处，分析时通过关联引用。指标定义和逐期数值分开；报表已有的数字优先由报表计算，减少重复录入。',
 rows:[
 ['财务报表','一条报表科目 × 一个报告期','vi_fin_stmt_base → vi_fin_stmt','后台按科目存，前台转成“科目 × 报告期”矩阵；切换累计与单季查看。'],
 ['定量指标','一个指标定义；每一期数值另存','vi_metric_base ＋ vi_observation_base → vi_metric / vi_series','前台每个指标一行，分四个标签；展开看趋势和逐期数据。报表计算指标读取财务报表。'],
 ['定性事实','一件事项；其下每个侧面各一行','vi_event_base ＋ vi_fact_base → vi_event / vi_fact','“事项”聚合一件事的进展，“全部事实”编辑各侧面，保留日期、来源与核验状态。']
 ],
 steps:['先在“研究维护 / 来源文档”登记来源，再补报表、指标或定性事实。','新一期数字进入已有指标；核对期间、单位与口径。','在商业模式与假设依据中关联事实、指标，避免反复抄写。'],
 note:'四个指标标签是同一指标库的分类入口：定期经营、高频经营、财务指标、宏观与市场。共享的宏观指标按需引用，不为每家公司再建一份。' },
 { n:'02', title:'研究维护', sub:'让缺口有去处，让修改有来由。', principle:'来源资料、自动检查、人工待办、变更记录各司其职。自检回答“哪里有异常”，待办回答“下一步做什么”，日志回答“改了什么、为什么改”。',
 rows:[
  ['来源文档','一份年报、公告或其他来源','vi_source_base → vi_source','登记标题、日期和出处，供事实与研究判断引用。'],
 ['质量自检','一项规则的检查结果','vi_check（计算视图）','读取当前数据和模型自动判断；回到对应底稿或假设修正，再刷新查看。'],
 ['待办清单','一件做完即可关闭的事','vi_issue_base → vi_issue','维护级别、影响范围、完成条件、状态与进展，解决后关闭。'],
 ['变更日志','一次有意义的数据或假设修改','vi_change_log_base → vi_change_log','记录对象、旧值、新值、理由、依据与验证，便于日后复盘。']
 ],
 steps:['先看自检；需要人工补资料或核验的工作写入待办。','修正底稿或模型输入，刷新检查并验证结果。','重要修改补一条日志；满足完成条件后关闭待办。'],
 note:'对公司的判断放“核心论点”，长期观察的数关联指标，不堆进待办。质量自检同时含三层估值的检查 G01—G10（也显示在“预测与估值 / ⑤ 股权价值”）。' },
 { n:'03', title:'商业模式', sub:'从赚钱机制走到可检验的判断。', principle:'先理解谁付钱、成本在哪里，再分析竞争与壁垒，最后形成论点、风险与适配度判断。图用于理解，明细用于编辑，两者读取同一批记录。',
 rows:[
 ['商业模式拆解','一个业务范围中的一项画布要素','vi_biz_model_base → vi_biz_model','九格画布呈现客户、价值、资源、收入和成本；按集团或业务范围组织。'],
 ['产业链与五力','一个产业链环节；一个竞争对手','vi_value_chain_base ＋ vi_competitor_base → 对应前台集合','五力图读产业链记录，对手表存独立的对比资料，编辑标签维护原记录。'],
 ['竞争壁垒 / 核心论点','一项壁垒；一条可被证伪的论点','vi_moat_base ＋ vi_thesis_base → 对应前台集合','壁垒关联论点；论点写正反证据、裁决和改判条件，图中汇总引用关系。'],
 ['风险分析 / 价投适配度','一项风险；一个评分维度','vi_risk_base ＋ vi_fit_score_base → 对应前台集合','风险矩阵呈现可能性与冲击，评分看板汇总维度判断；具体理由在明细中维护。']
 ],
 steps:['先看画布与五力图，理解生意和竞争位置。','到“明细（编辑）”补依据事实、依据指标及正反论证，再作裁决。','将影响估值的判断写入“假设依据”，经复核后调整估值输入。'],
 note:'改事实或论点不会自动改变估值。业务身份由 vi_business_base 统一关联；可独立定价的经营分部才拆成业务（三层估值的估值单元），共用客户和费用的收入来源不拆。' }
];
function Page(){
 const { token } = theme.useToken();
 return <div style={{maxWidth:1080,margin:'0 auto',padding:'24px 12px 36px'}}>
  <Text type="secondary" style={{fontSize:12,letterSpacing:2}}>研究工作台 · 使用与设计</Text>
  <Title level={2} style={{margin:'8px 0 12px'}}>从底稿到判断，再到持续维护</Title>
  <Paragraph type="secondary" style={{maxWidth:780,marginBottom:10}}>一份证据，多处引用；一套底表，按公司呈现。前台把记录组织成表格、图和看板，后台保存可追溯的原始记录与关联。</Paragraph>
  <Paragraph style={{marginBottom:26}}><Text strong>商业模式 → 经营与财务 → 预测与估值 → 研究维护</Text></Paragraph>
  <Space direction="vertical" size={20} style={{width:'100%'}}>
   {sections.map(s=><Card key={s.n} style={{borderRadius:14}} styles={{body:{padding:24}}}>
    <Space align="baseline" size={12}><Text style={{color:token.colorPrimary,fontSize:13}}>{s.n}</Text><Title level={3} style={{margin:0}}>{s.title}</Title></Space>
    <Paragraph type="secondary" style={{margin:'6px 0 18px'}}>{s.sub}</Paragraph>
    <Paragraph style={{lineHeight:1.85}}>{s.principle}</Paragraph>
    <Table size="small" pagination={false} rowKey={r=>r[0]} dataSource={s.rows} scroll={{x:640}} columns={[
     {title:'前台入口',width:170,render:(_,r)=><Text strong>{r[0]}</Text>},
     {title:'底表里的一行',width:230,render:(_,r)=>r[1]},
     {title:'前台如何呈现',render:(_,r)=>r[3]}
    ]}/>
    <Divider style={{margin:'18px 0'}}/>
    <Text strong>怎么使用</Text>
    <ol style={{paddingLeft:20,margin:'10px 0 14px',lineHeight:1.9}}>{s.steps.map(t=><li key={t}>{t}</li>)}</ol>
    <Paragraph type="secondary" style={{fontSize:13,marginBottom:14}}>{s.note}</Paragraph>
    <Collapse ghost size="small" items={[{key:'tables',label:'查看后台表的对应关系',children:<Space direction="vertical" size={10} style={{width:'100%'}}>{s.rows.map(r=><div key={r[0]}><Text strong>{r[0]}</Text><br/><Text type="secondary" style={{fontSize:12,overflowWrap:'anywhere'}}>{r[2]}</Text></div>)}<Text type="secondary" style={{fontSize:12}}>_base 保存基础记录；前台集合与计算视图组织展示。关联字段连接不同记录，不需要复制内容。</Text></Space>}]} />
   </Card>)}
  </Space>
  <Paragraph type="secondary" style={{fontSize:12,margin:'20px 0 0'}}>按当前五家公司页面与表结构整理 · 2026-11-09 · <Link href="/admin/vsha1l0e5il">完整数据结构</Link></Paragraph>
 </div>;
}
ctx.render(<Page/>);
