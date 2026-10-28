const CONFIG = __CONFIG__;
const { Alert, Button, Col, Row, Space, Statistic, Table, Tag, Typography } = ctx.libs.antd;
const finite = (v) => v !== null && v !== undefined && Number.isFinite(Number(v));
const number = (v, digits = 2) => finite(v) ? Number(v).toFixed(digits) : '—';
const percent = (v, digits = 2) => finite(v) ? `${number(Number(v) * 100, digits)}%` : '—';

async function listRows(collectionName, filter) {
  const resource = ctx.makeResource('MultiRecordResource');
  resource.setResourceName(collectionName);
  resource.setPageSize(200);
  resource.setFilter(filter);
  await resource.refresh();
  return resource.getData() || [];
}

try {
  const [company] = await listRows('vi_company', { $and: [{ code: { $eq: CONFIG.code } }] });
  if (!company) throw new Error('未找到公司记录');
  const models = await listRows('vi_model', {
    $and: [{ company_id: { $eq: company.id } }, { status: { $eq: '当前' } }],
  });
  if (models.length !== 1) throw new Error('需要且仅能有一个当前估值模型');
  const model = models[0];
  const filter = { $and: [{ model_id: { $eq: model.id } }] };
  const [values, checks] = await Promise.all([
    listRows(CONFIG.sotp ? 'vi_sotp' : 'vi_valuation', filter),
    listRows('vi_check', filter),
  ]);
  const scenarios = values.slice().sort((a, b) => (a.sort ?? a.id) - (b.sort ?? b.id));
  const base = scenarios.find((row) => row.is_base);
  if (!base) throw new Error('当前模型缺少基准情景');
  const fx = company.latest_fx;
  const quote = (v) => finite(v) && finite(fx) && Number(fx) > 0 ? Number(v) / Number(fx) : null;
  const gap = (price, value) => finite(price) && finite(value) && Number(value) > 0 ? Number(price) / Number(value) - 1 : null;
  const count = (result) => checks.filter((row) => row.result === result).length;
  const threshold = base.required_return ?? model.required_return;
  const rows = scenarios.map((row) => ({ ...row, quote: quote(row.value_per_share),
    gap: gap(row.market_price, CONFIG.sotp ? row.value_per_share : row.value_at_required) }));
  const pessimistic = rows.find((row) => row.scenario_name === '悲观');
  const optimistic = rows.find((row) => row.scenario_name === '乐观');
  const baseRow = rows.find((row) => row.is_base);
  const metrics = CONFIG.sotp ? [
    { title: '港股市场价', value: company.latest_price_raw, suffix: '港元' },
    { title: '悲观情景', value: pessimistic?.quote, suffix: '港元' },
    { title: '基准情景', value: baseRow.quote, suffix: '港元' },
    { title: '乐观情景', value: optimistic?.quote, suffix: '港元' },
  ] : [
    { title: '市场价', value: company.latest_price, suffix: '元' },
    { title: '基准隐含年化回报', value: finite(base.implied_irr) ? base.implied_irr * 100 : null, suffix: '%' },
    { title: '基准现金支持回报', value: finite(base.cash_implied_irr) ? base.cash_implied_irr * 100 : null, suffix: '%' },
    { title: `门槛 ${percent(threshold, 1)} 的最高买入价`, value: base.value_at_required, suffix: '元' },
  ];
  const scenarioColumn = { title: '情景', dataIndex: 'scenario_name', width: 75,
    render: (name, row) => row.is_base ? <Typography.Text strong>{name}</Typography.Text> : name };
  const columns = CONFIG.sotp ? [scenarioColumn,
    { title: '业务价值（亿元）', dataIndex: 'business_value', align: 'right', render: (v) => number(v, 1) },
    { title: '资产与调整（亿元）', dataIndex: 'asset_value', align: 'right', render: (v) => number(v, 1) },
    { title: '股权价值（亿元）', dataIndex: 'equity_value', align: 'right', render: (v) => number(v, 1) },
    { title: '每股（人民币元）', dataIndex: 'value_per_share', align: 'right', render: (v) => number(v) },
    { title: '每股（港元）', dataIndex: 'quote', align: 'right', render: (v) => <Typography.Text strong>{number(v)}</Typography.Text> },
    { title: '现价相对价值', dataIndex: 'gap', align: 'right', render: (v) => percent(v, 1) },
  ] : [scenarioColumn,
    { title: '隐含年化回报', dataIndex: 'implied_irr', align: 'right', render: (v) => percent(v) },
    { title: '现金支持回报', dataIndex: 'cash_implied_irr', align: 'right', render: (v) => percent(v) },
    { title: `门槛 ${percent(threshold, 1)} 的最高买入价（元）`, dataIndex: 'value_at_required', align: 'right', render: (v) => <Typography.Text strong>{number(v)}</Typography.Text> },
    { title: '现价相对最高买入价', dataIndex: 'gap', align: 'right', render: (v) => percent(v, 1) },
    { title: '回报与门槛', key: 'result', align: 'right', render: (_, row) => finite(row.implied_irr) && finite(threshold)
      ? <Tag color={row.implied_irr >= threshold ? 'green' : 'gold'}>{row.implied_irr >= threshold ? '达到门槛' : '低于门槛'}</Tag> : '—' },
  ];

  ctx.render(
    <div>
      <Space wrap align="center" style={{ justifyContent: 'space-between', width: '100%', marginBottom: 8 }}>
        <Typography.Title level={4} style={{ margin: 0 }}>{company.name} · 投资驾驶舱</Typography.Title>
        <Space wrap>{CONFIG.links.map((link) => <Button key={link.href} size="small" href={link.href}>{link.title}</Button>)}</Space>
      </Space>
      <Typography.Paragraph type="secondary" style={{ marginBottom: 16 }}>
        {company.code} · 股价 {company.latest_price_date || '—'} · {CONFIG.sotp ? `资产基准日 ${base.as_of || '—'}` : `预测 ${model.base_year + 1}—${model.terminal_year} 年`}
        {' · '}股本 {number(model.shares, 1)} 亿{CONFIG.sotp ? '普通股' : '股'}
      </Typography.Paragraph>
      <Row gutter={[20, 16]}>{metrics.map((metric) => (
        <Col key={metric.title} xs={12} lg={6}><Statistic title={metric.title} value={number(metric.value)} suffix={metric.suffix} /></Col>
      ))}</Row>
      <Space wrap style={{ margin: '16px 0 12px' }}>
        <Tag color="blue">现价相对基准{CONFIG.sotp ? '价值' : '最高买入价'} {percent(baseRow.gap, 1)}</Tag>
        <Typography.Text type="secondary">
          {CONFIG.sotp ? `关注价：10% 边际 ${number(quote(base.watch_low))} 港元 · 30% 边际 ${number(quote(base.watch_high))} 港元`
            : `当前已保存门槛 ${percent(threshold, 1)} · 参数试算与回报拆解见「估值」`}
        </Typography.Text>
      </Space>
      <Table size="small" rowKey="id" pagination={false} dataSource={rows} columns={columns}
        scroll={{ x: CONFIG.sotp ? 850 : 760 }} style={{ fontVariantNumeric: 'tabular-nums' }} />
      <Typography.Paragraph type="secondary" style={{ margin: '10px 0' }}>
        {CONFIG.sotp
          ? `业务价值＋资产与调整＝股权价值；股权价值÷股本＝每股价值。1 港元＝${number(fx, 4)} 元人民币。`
          : '隐含回报按现价与预测股息计算；现金支持口径考虑可分配现金。最高买入价按模型已保存门槛折现。'}
        {' '}{CONFIG.focus}。驾驶舱与图表读取当前已保存模型。
      </Typography.Paragraph>
      <Space wrap>
        <Typography.Text type="secondary">质量自检</Typography.Text>
        <Tag color="green">通过 {count('通过')}</Tag><Tag color="gold">提示 {count('提示')}</Tag>
        <Tag color={count('阻断') ? 'red' : 'default'}>阻断 {count('阻断')}</Tag>
        <Typography.Text type="secondary">PE TTM {number(company.pe_ttm)} · PB {number(company.pb)}（{company.pe_pb_date || '—'}，市场口径）</Typography.Text>
      </Space>
      {CONFIG.sotp && <Typography.Paragraph type="secondary" style={{ margin: '10px 0 0' }}>
        直接估值业务含主观判断：基准 {number(base.direct_value, 0)} 亿元；按 0 计时其余假设不变，每股 {number(quote(finite(base.equity_value) && finite(base.direct_value) && Number(base.shares) > 0 ? (base.equity_value - base.direct_value) / base.shares : null))} 港元。
        此项敏感性与完整分部明细见「估值」。
      </Typography.Paragraph>}
      {CONFIG.sotp && !(finite(fx) && Number(fx) > 0) && <Alert type="warning" showIcon message="汇率缺失，港元估值暂不换算" />}
    </div>,
  );
} catch (error) {
  ctx.render(<Alert type="error" showIcon message="驾驶舱读取失败" description={String(error?.message || error)} />);
}
