const { Alert, Button, Col, Row, Space, Statistic, Table, Tag, Typography } = ctx.libs.antd;

async function listRows(collectionName, filter) {
  const resource = ctx.makeResource('MultiRecordResource');
  resource.setResourceName(collectionName);
  resource.setPageSize?.(200);
  resource.setFilter?.(filter);
  await resource.refresh();
  return resource.getData() || [];
}

const number = (value, digits = 2) => value === null || value === undefined || !Number.isFinite(Number(value))
  ? '—' : Number(value).toFixed(digits);
const percent = (value) => value === null || value === undefined ? '—' : `${number(value * 100, 1)}%`;

try {
  const companies = await listRows('vi_company', { $and: [{ code: { $eq: '01698.HK' } }] });
  const company = companies[0];
  if (!company) throw new Error('未找到腾讯音乐公司记录');
  const models = await listRows('vi_model', {
    $and: [{ company_id: { $eq: company.id } }, { status: { $eq: '当前' } }],
  });
  if (models.length !== 1) throw new Error('腾讯音乐需要且仅能有一个当前模型');
  const model = models[0];
  const filter = { $and: [{ model_id: { $eq: model.id } }] };
  const [values, checks] = await Promise.all([
    listRows('vi_sotp', filter),
    listRows('vi_check', filter),
  ]);
  const scenarios = values.slice().sort((a, b) => a.id - b.id);
  const base = scenarios.find((row) => row.is_base);
  if (!base) throw new Error('当前模型缺少基准情景');
  const fx = Number(company.latest_fx);
  const hkd = (value) => fx > 0 && value !== null && value !== undefined ? Number(value) / fx : null;
  const rows = scenarios.map((row) => ({
    ...row,
    quote: hkd(row.value_per_share),
    gap: row.value_per_share > 0 && row.market_price !== null && row.market_price !== undefined
      ? row.market_price / row.value_per_share - 1 : null,
  }));
  const baseRow = rows.find((row) => row.is_base);
  const pessimistic = rows.find((row) => row.scenario_name === '悲观');
  const optimistic = rows.find((row) => row.scenario_name === '乐观');
  const count = (result) => checks.filter((row) => row.result === result).length;
  const metrics = [
    { title: '港股市场价', value: company.latest_price_raw },
    { title: '悲观情景', value: pessimistic?.quote },
    { title: '基准情景', value: baseRow.quote },
    { title: '乐观情景', value: optimistic?.quote },
  ];

  ctx.render(
    <div>
      <Space wrap align="center" style={{ justifyContent: 'space-between', width: '100%', marginBottom: 8 }}>
        <Typography.Title level={4} style={{ margin: 0 }}>腾讯音乐 · 投资驾驶舱</Typography.Title>
        <Space wrap>
          <Button size="small" href="/admin/euxy5ltu78h">估值模型</Button>
          <Button size="small" href="/admin/wc3nccce8ou">财务模型</Button>
          <Button size="small" href="/admin/iyut3rwi5im">核心论点</Button>
        </Space>
      </Space>
      <Typography.Paragraph type="secondary" style={{ marginBottom: 16 }}>
        01698.HK · 股价 {company.latest_price_date || '—'} · 资产基准日 {base.as_of || '—'} · 股本 {number(model.shares, 1)} 亿普通股
      </Typography.Paragraph>
      <PriceSummary price={company.latest_price_raw} date={company.latest_price_date} scenarios={rows.map((r) => ({ name: r.scenario_name, value: r.quote, isBase: r.is_base }))} />
      <Typography.Paragraph type="secondary" style={{ marginBottom: 12 }}>关注价 · 10% 边际 {number(hkd(base.watch_low))} 港元 / 30% 边际 {number(hkd(base.watch_high))} 港元</Typography.Paragraph>
      <Table
        size="small"
        rowKey="id"
        pagination={false}
        dataSource={rows}
        scroll={{ x: 800 }}
        style={{ fontVariantNumeric: 'tabular-nums' }}
        columns={[
          { title: '情景', dataIndex: 'scenario_name', width: 90,
            render: (name, row) => row.is_base ? <Typography.Text strong>{name}</Typography.Text> : name },
          { title: '主营价值（亿元）', dataIndex: 'business_value', align: 'right', render: (v) => number(v, 1) },
          { title: '资产与调整（亿元）', dataIndex: 'asset_value', align: 'right', render: (v) => number(v, 1) },
          { title: '股权价值（亿元）', dataIndex: 'equity_value', align: 'right', render: (v) => number(v, 1) },
          { title: '每股（人民币元）', dataIndex: 'value_per_share', align: 'right', render: (v) => number(v) },
          { title: '每股（港元）', dataIndex: 'quote', align: 'right', render: (v) => <Typography.Text strong>{number(v)}</Typography.Text> },
          { title: '现价相对价值', dataIndex: 'gap', align: 'right', render: percent },
        ]}
      />
      <Typography.Paragraph type="secondary" style={{ margin: '10px 0' }}>
        主营价值＋资产与调整＝股权价值；股权价值÷股本＝每股价值。1 港元＝{number(fx, 4)} 元人民币。
        驾驶舱与下方图表均读取当前已保存模型，参数与分部明细见「估值模型」。
      </Typography.Paragraph>
      <Space wrap>
        <Typography.Text type="secondary">质量自检</Typography.Text>
        <Tag color="green">通过 {count('通过')}</Tag>
        <Tag color="gold">提示 {count('提示')}</Tag>
        <Tag color={count('阻断') ? 'red' : 'default'}>阻断 {count('阻断')}</Tag>
      </Space>
      {!(fx > 0) && <Alert type="warning" showIcon message="汇率缺失，港元估值暂不换算" />}
    </div>,
  );
} catch (error) {
  ctx.render(<Alert type="error" showIcon message="驾驶舱读取失败" description={String(error?.message || error)} />);
}
