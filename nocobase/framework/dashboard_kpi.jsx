const CONFIG = __CONFIG__;
// 驾驶舱关键读数（五家公司同一份）：现价与三层价值（主估值层）、隐含回报、质量自检。只读 vi_gw_value / vi_check。
const { Alert, Button, Col, Row, Space, Statistic, Table, Tag, Typography } = ctx.libs.antd;
const finite = (v) => v !== null && v !== undefined && v !== '' && Number.isFinite(Number(v));
const number = (v, digits = 2) => finite(v) ? Number(v).toFixed(digits) : '—';
const percent = (v, digits = 1) => finite(v) ? `${(Number(v) * 100).toFixed(digits)}%` : '—';

async function listRows(collectionName, filter) {
  const resource = ctx.makeResource('MultiRecordResource');
  resource.setResourceName(collectionName);
  resource.setPageSize(200);
  if (filter) resource.setFilter(filter);
  await resource.refresh();
  return resource.getData() || [];
}

try {
  const [company] = await listRows('vi_company', { code: { $eq: CONFIG.code } });
  if (!company) throw new Error('未找到公司记录');
  const byCo = { company_id: { $eq: company.id } };
  const [values, checks] = await Promise.all([listRows('vi_gw_value', byCo), listRows('vi_check', byCo)]);
  const v = values[0];
  if (!v) throw new Error('这家公司还没有三层估值（预测与估值 / ② 盈利能力）');
  const layer = v.value_layer;
  const count = (result) => checks.filter((r) => r.result === result).length;
  const quote = finite(company.latest_fx) ? `（${number(company.latest_price_raw)} 港元 × ${number(company.latest_fx, 4)}）` : '';
  const layers = [['资产价值', v.av_ps, null], ['盈利能力价值', v.epv_ps, v.irr_epv], ['含增长价值', v.full_ps, v.irr_full]];
  const rows = layers.map(([name, value, irr]) => ({ name, value, irr }));
  const columns = [
    { title: '层', dataIndex: 'name', render: (x) => (x === layer ? <Typography.Text strong>{x}（主估值层）</Typography.Text> : x) },
    { title: '每股价值（元，今天）', dataIndex: 'value', align: 'right', render: (x) => number(x) },
    { title: '现价相对', key: 'gap', align: 'right', render: (_, r) => (finite(r.value) && Number(r.value) ? percent(company.latest_price / r.value - 1) : '—') },
    { title: '隐含年化回报（现价买入）', dataIndex: 'irr', align: 'right',
      render: (x) => (finite(x) ? <Typography.Text type={x >= v.hurdle ? 'success' : 'danger'}>{percent(x)}</Typography.Text> : '—') },
  ];
  ctx.render(
    <div>
      <Space wrap align="center" style={{ justifyContent: 'space-between', width: '100%', marginBottom: 8 }}>
        <Typography.Title level={4} style={{ margin: 0 }}>{company.name} · 投资驾驶舱</Typography.Title>
        <Space wrap>{CONFIG.links.map((l) => <Button key={l.href} size="small" href={l.href}>{l.title}</Button>)}</Space>
      </Space>
      <Typography.Paragraph type="secondary" style={{ marginBottom: 16 }}>
        {company.code} · 股价 {company.latest_price_date || '—'} · 估值截至日 {v.as_of || '—'} · 股本 {number(v.shares, 2)} 亿股 · 主估值层 {layer || '未选'} · 门槛 {percent(v.hurdle)}
      </Typography.Paragraph>
      <PriceSummary price={company.latest_price} date={company.latest_price_date} unit="元"
        scenarios={rows.map((r) => ({ name: r.name, value: r.value, isBase: r.name === layer }))} />
      <Row gutter={[20, 16]}>
        <Col xs={12} lg={6}><Statistic title={`现价（记账币种）${quote}`} value={number(company.latest_price)} suffix="元" /></Col>
        <Col xs={12} lg={6}><Statistic title={layer || '主估值层'} value={number(v.value_ps)} suffix="元" /></Col>
        <Col xs={12} lg={6}><Statistic title="主估值层的隐含年化回报" value={finite(v.implied_irr) ? (v.implied_irr * 100).toFixed(1) : '—'} suffix="%" /></Col>
        <Col xs={12} lg={6}><Statistic title="资产负债桥（每股，截至日）" value={number(v.bridge / v.shares)} suffix="元" /></Col>
      </Row>
      <Typography.Paragraph style={{ margin: '16px 0 12px' }}>{v.conclusion}</Typography.Paragraph>
      <Table size="small" rowKey="name" pagination={false} dataSource={rows} columns={columns} scroll={{ x: 640 }}
        style={{ fontVariantNumeric: 'tabular-nums' }} />
      <Typography.Paragraph type="secondary" style={{ margin: '10px 0' }}>
        三层价值都已加上资产负债桥、按门槛滚到今天；三层本身就是从保守到乐观的三种情形，结论看主估值层。{CONFIG.focus ? `${CONFIG.focus}。` : ''}
      </Typography.Paragraph>
      <Space wrap>
        <Typography.Text type="secondary">质量自检</Typography.Text>
        <Tag color="green">通过 {count('通过')}</Tag><Tag color="gold">提示 {count('提示')}</Tag>
        <Tag color={count('阻断') ? 'red' : 'default'}>阻断 {count('阻断')}</Tag>
        <Typography.Text type="secondary">PE TTM {number(company.pe_ttm)} · PB {number(company.pb)}（{company.pe_pb_date || '—'}，市场口径）</Typography.Text>
      </Space>
    </div>,
  );
} catch (error) {
  const msg = String(error?.message || error);
  ctx.render(msg.startsWith('这家公司还没有')
    ? <Alert type="info" showIcon message="还没有三层估值" description="先在「预测与估值 / ② 盈利能力」填调整后利润表（样板见腾讯音乐）；下面的经营图表照常可看。" />
    : <Alert type="error" showIcon message="驾驶舱读取失败" description={msg} />);
}
