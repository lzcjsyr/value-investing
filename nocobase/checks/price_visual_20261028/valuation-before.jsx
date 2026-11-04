const COMPANY = '01698.HK';
const PROFILE = {"method": "sotp", "hurdle_j": null, "logic": "付费用户 × 每用户年收入近似集团收入；该单价包含广告、演出及社交娱乐，不等同于订阅 ARPPU。主估值为核心盈利、净现金和对外投资的分部加总。", "drivers": [{"section": "收入与业务规模"}, {"label": "付费用户（亿人）", "p": "volume", "h": "volume", "j": ["J-Q"], "d": 2, "how": "逐年路径 × 情景业务量系数"}, {"label": "总收入 / 付费用户（元/年）", "p": "price", "h": "price", "j": ["J-P"], "d": 1, "how": "逐年路径 × 情景单价系数"}, {"label": "营业收入", "p": "revenue", "h": "revenue", "strong": true, "how": "业务量 × 单价"}, {"section": "成本与利润（金额：亿元人民币）"}, {"label": "付现成本", "p": "cash_cost", "j": ["J-M"], "how": "基准付现成本 × 情景成本系数"}, {"label": "折旧摊销", "p": "depreciation", "h": "da", "j": ["J-DA"]}, {"label": "利息", "p": "interest", "h": "finance_cost", "j": ["J-DEBT"]}, {"label": "其他净贡献", "p": "other_contrib", "j": ["J-OTH"], "how": "投资收益、减值等净额，按各公司原模型口径"}, {"label": "利润总额", "p": "pretax", "h": "pretax_profit", "strong": true}, {"label": "所得税率", "f": "tax_rate", "h": "tax_rate", "pct": true, "d": 2, "j": ["J-TAX"]}, {"label": "少数股东占比", "f": "minority_share", "h": "minority_share", "pct": true, "d": 2, "j": ["J-TAX"]}, {"label": "归母净利润", "p": "np_parent", "h": "np_parent", "strong": true}, {"section": "股东回报与现金约束"}, {"label": "股东回报率（股息＋回购）", "p": "payout", "h": "payout", "j": ["J-PAYOUT"], "pct": true, "how": "按原模型口径；回购金额不等于现金股息"}, {"label": "每股股东回报（元人民币）", "p": "dps", "h": "dps", "strong": true, "d": 3}, {"label": "维持资本开支", "f": "maint_capex", "j": ["J-CAPEX"], "d": 1}, {"label": "扩张资本开支", "f": "growth_capex", "j": ["J-CAPEX"], "d": 1}, {"label": "营运资本增加", "f": "wc_increase", "j": [], "d": 1}, {"label": "净借款（负数＝偿债）", "f": "net_borrowing", "d": 1}, {"label": "股东自由现金流", "p": "fcfe", "strong": true, "how": "按数据库归母现金桥接口径"}, {"label": "计划回报现金缺口", "p": "funding_gap", "how": "现金不足部分；缺项保持未知"}], "shocks": [{"label": "收入中枢 −5%", "rev": -0.05, "j": "J-Q / J-P"}, {"label": "收入中枢 +5%", "rev": 0.05, "j": "J-Q / J-P"}, {"label": "付现成本 +5%", "cost": 0.05, "j": "J-M"}, {"label": "债务成本 +1 个百分点", "kd": 0.01}, {"label": "永续增长 0%", "g": 0.0, "j": "J-TV"}, {"label": "买入价 −10%", "price": -0.1}]};
const { React } = ctx.libs;
const { useState } = React;
const { Card, Segmented, Table: NativeTable, Alert, Typography, Space, Tag, Popover, Collapse, Descriptions, Row, Col, Statistic,
        InputNumber, Button, message, theme } = ctx.libs.antd;
const { Text, Paragraph, Title } = Typography;


function Table(props) {
  const numberKeys = new Set(['prob', 'probability', 'core', 'm', 'coreValue', 'mature', 'growth', 'invest', 'direct', 'cash', 'inv', 'other', 'vps', 'quote', 'vsPrice', 'irr', 'cashIrr', 'ceiling', 'price', 'np', 'dps', 'g', 'vf', 'pf', 'cf']);
  const cols = (props.columns || []).map((c) => {
    const key = c.dataIndex || c.key;
    const numeric = numberKeys.has(key) || /^h\d{4}$|^y\d{4}$/.test(String(key));
    return { ...c, align: c.align || (numeric ? 'right' : 'left'),
      width: c.width || (numeric ? 140 : key === 'name' || key === 'scenario_name' ? 120 : 200),
      onHeaderCell: (...args) => ({ ...c.onHeaderCell?.(...args), style: { whiteSpace: 'normal', wordBreak: 'normal' } }),
    };
  });
  return <NativeTable {...props} columns={cols} scroll={props.scroll || { x: 'max-content' }}
    style={{ fontVariantNumeric: 'tabular-nums', ...props.style }} />;
}

async function listRows(name, filter, pageSize = 1000) {
  const resource = ctx.makeResource('MultiRecordResource');
  resource.setResourceName(name);
  resource.setPageSize?.(pageSize);
  if (filter) resource.setFilter?.(filter);
  await resource.refresh();
  return resource.getData() || [];
}
const isNum = (v) => v !== null && v !== undefined && v !== '' && !Number.isNaN(Number(v));
const fmt = (v, d = 1) => (isNum(v) ? Number(v).toLocaleString('zh-CN', { minimumFractionDigits: d, maximumFractionDigits: d }) : '—');
const pct = (v, d = 1) => (isNum(v) ? (Number(v) * 100).toFixed(d) + '%' : '—');
const pp = (v) => (isNum(v) ? (Math.abs(v) * 100).toFixed(2) + ' 个百分点' : '—');
const bp = (v) => (isNum(v) ? (v >= 0 ? '+' : '−') + Math.abs(Math.round(v * 10000)) + 'bp' : '—');
const narrow = (typeof window !== 'undefined' ? window.innerWidth : 1200) < 760;
const bySort = (a, b) => (a.sort ?? 0) - (b.sort ?? 0) || a.id - b.id;

// 读这家公司的当前模型及其全部情景、逐年数据
async function load() {
  const [company] = await listRows('vi_company', { code: { $eq: COMPANY } });
  if (!company) throw new Error('公司不存在：' + COMPANY);
  const [model] = await listRows('vi_model', { company_id: { $eq: company.id }, status: { $eq: '当前' } });
  if (!model) return { company };
  const byModel = { model_id: { $eq: model.id } };
  const [scenarios, projections, forecasts, valuations, judgments, history] = await Promise.all([
    listRows('vi_scenario', byModel), listRows('vi_projection', byModel), listRows('vi_forecast', byModel),
    listRows('vi_valuation', byModel), listRows('vi_judgment', { company_id: { $eq: company.id } }),
    listRows('vi_fin_history', { company_id: { $eq: company.id } }),
  ]);
  scenarios.sort(bySort);
  const years = [...new Set(forecasts.map((f) => Number(f.year)))].sort((a, b) => a - b);
  const pOf = (sc, y) => projections.find((p) => p.scenario_name === sc.name && Number(p.year) === Number(y));
  const fOf = (y) => forecasts.find((f) => Number(f.year) === Number(y));
  return { company, model, scenarios, projections, forecasts, valuations, judgments, history, years, pOf, fOf };
}

// 假设依据：编号标签，悬停看判断、传导与修改门槛
function JTag({ code, judgments }) {
  const j = judgments.find((x) => x.code === code);
  if (!j) return <Tag>{code}</Tag>;
  const body = (
    <div style={{ maxWidth: 420 }}>
      <Paragraph style={{ marginBottom: 6 }}><b>判断</b>：{j.judgment}</Paragraph>
      {j.transmission && <Paragraph style={{ marginBottom: 6 }}><b>怎么传导</b>：{j.transmission}</Paragraph>}
      {j.change_threshold && <Paragraph style={{ marginBottom: 0 }}><b>什么情况下改</b>：{j.change_threshold}</Paragraph>}
    </div>
  );
  return (
    <Popover title={`${j.code} ${j.title} · ${j.status || ''}`} content={body}>
      <Tag color="blue" style={{ cursor: 'help' }}>{j.code}</Tag>
    </Popover>
  );
}

// 只用分部加总、没有逐年预测的公司（腾讯音乐，2026-10-28 起）：财务模型＝三块（主营各块盈利×倍数＋可分配自由现金＋对外投资）
async function renderThree(D, full) {
  const { company, model, scenarios, judgments } = D;
  const byModel = { model_id: { $eq: model.id } };
  const [segs, sotp, fins] = await Promise.all([listRows('vi_sotp_segment_val', byModel), listRows('vi_sotp', byModel), listRows('vi_fin_forecast', byModel)]);
  const names = scenarios.map((s) => s.name);
  const sOf = (n) => sotp.find((r) => r.scenario_name === n) || {};
  const T = (c) => <JTag key={c} code={c} judgments={judgments} />;
  const segJ = (code) => judgments.some((j) => j.code === 'J-' + code) ? ['J-' + code] : [];
  const codes = [...new Set(segs.map((g) => g.code))].sort();
  const segRows = codes.map((code) => {
    const row = { key: code, code, name: segs.find((g) => g.code === code)?.name };
    names.forEach((n) => { row[n] = segs.find((g) => g.code === code && g.scenario_name === n); });
    return row;
  });
  const num = { fontVariantNumeric: 'tabular-nums' };
  const segCell = (g) => !g ? '—' : (
    <div style={{ ...num, lineHeight: 1.7 }}>
      <div>收入 {fmt(g.revenue, 0)} × 利润率 {pct(g.op_margin, 0)} ＝ 税前 {fmt(Number(g.revenue) * Number(g.op_margin), 1)}</div>
      <div style={{ fontSize: 12, opacity: 0.7 }}>税后归母 {fmt(g.earnings, 1)} × {fmt(g.multiple_used, 1)} 倍，折回 {fmt(g.tau, 1)} 年</div>
      <div style={{ fontWeight: 600 }}>{fmt(g.value, 0)} 亿元</div>
    </div>);
  const segCols = [
    { title: '主营业务', key: 'name', width: 260, render: (_, r) => <div><div>{r.code} {r.name}</div><Space size={4} style={{ marginTop: 4 }}>{segJ(r.code).map(T)}</Space></div> },
    ...names.map((n) => ({ title: n, key: n, align: 'right', render: (_, r) => segCell(r[n]) })),
  ];
  // 港股：人民币每股价值 ÷ 当天港元兑人民币 ＝ 港元每股价值，与港股原始收盘价比较
  const fx = isNum(company.latest_fx) && Number(company.latest_fx) > 0 ? Number(company.latest_fx) : null;
  const pxH = isNum(company.latest_price_raw) ? Number(company.latest_price_raw) : null;
  const toH = (x) => (isNum(x) && fx ? Number(x) / fx : null);
  const pxDate = company.latest_price_date || '—';
  const sumRows = [
    { key: 's1', section: '① 主营业务' },
    { key: 'a', label: '主营业务价值（三块合计，见上表）', j: ['J-R'], f: (s) => s.segments_value, strong: true },
    { key: 's2', section: '② 可分配的自由现金' },
    { key: 'b1', label: '现金、定期存款和短期投资', j: [], f: (s) => s.cash },
    { key: 'b2', label: '− 带息负债', j: [], f: (s) => s.debt },
    { key: 'b3', label: '− 经营所需现金（周转＋季节波动＋压力缓冲）', j: ['J-OPCASH'], f: (s) => s.op_cash },
    { key: 'b4', label: '− 境内资金汇出预提税', j: [], f: (s) => s.repatriation },
    { key: 'b', label: '＝ 可分配的自由现金', j: ['J-CASH'], f: (s) => s.usable_net_cash, strong: true },
    { key: 's3', section: '③ 对外投资' },
    { key: 'c', label: '最新报告账面价值 × 70%', j: ['J-INV'], f: (s) => s.investments, strong: true },
    { key: 's4', section: '加总得到每股价值' },
    { key: 'e1', label: '① 主营业务', j: [], f: (s) => s.segments_value },
    { key: 'e2', label: '＋ ② 可分配的自由现金', j: [], f: (s) => s.usable_net_cash },
    { key: 'e3', label: '＋ ③ 对外投资', j: [], f: (s) => s.investments },
    { key: 'd', label: '− 投资应付款与少数股东份额（3%）', j: [], f: (s) => s.minority_other },
    { key: 'e', label: '＝ 股权价值（亿元）', j: [], f: (s) => s.equity_value, strong: true },
    { key: 'sh', label: '÷ 股本（亿股）', j: [], f: () => model.shares, d: 2 },
    { key: 'f', label: '＝ 每股价值（元人民币）', j: [], f: (s) => s.value_per_share, strong: true, d: 2 },
    ...(fx ? [
      { key: 'hx', section: '换算成港元' },
      { key: 'fx', label: `÷ 港元兑人民币（${pxDate}）`, j: [], f: () => fx, d: 4 },
      { key: 'h', label: '＝ 每股价值（港元）', j: [], f: (s) => toH(s.value_per_share), strong: true, d: 2 },
      { key: 'hp', label: `港股收盘价（港元，${pxDate}）`, j: [], f: () => pxH, d: 2 },
      { key: 'hg', label: '港股价相对每股价值', j: [], f: (s) => (pxH && toH(s.value_per_share) ? pxH / toH(s.value_per_share) - 1 : null), pct: true },
      { key: 'hw', label: `关注价（港元，边际 ${pct(model.margin_low, 0)} / ${pct(model.margin_high, 0)}）`, j: [], txt: (s) => `${fmt(toH(s.watch_low), 2)} / ${fmt(toH(s.watch_high), 2)}` },
    ] : [{ key: 'g', label: '市场价相对每股价值', j: [], f: (s) => s.price_vs_value, pct: true }]),
  ];
  const sumCols = [
    { title: '项目', key: 'label', width: 300, onCell: (r) => (r.section ? { colSpan: names.length + 2, style: { background: 'rgba(22,119,255,0.06)' } } : {}),
      render: (_, r) => r.section ? <Text strong style={{ fontSize: 14 }}>{r.section}</Text> : <span style={{ fontWeight: r.strong ? 600 : 400, paddingLeft: r.strong ? 0 : 12 }}>{r.label}</span> },
    { title: '依据', key: 'j', width: 90, onCell: (r) => (r.section ? { colSpan: 0 } : {}), render: (_, r) => <Space size={4}>{(r.j || []).filter((c) => judgments.some((x) => x.code === c)).map(T)}</Space> },
    ...names.map((n) => ({ title: n, key: n, align: 'right', onCell: (r) => (r.section ? { colSpan: 0 } : {}), render: (_, r) => {
      if (r.section) return null;
      if (r.txt) return <span style={num}>{r.txt(sOf(n))}</span>;
      const v = r.f(sOf(n));
      return <span style={{ ...num, fontWeight: r.strong ? 600 : 400 }}>{r.pct ? pct(v, 1) : fmt(v, r.d ?? 0)}</span>; } })),
  ];
  const base = sotp.find((r) => r.is_base) || sotp[0] || {};
  const calib = names.map((n) => {
    const gs = segs.filter((g) => g.scenario_name === n);
    const rev = gs.reduce((a, g) => a + Number(g.revenue || 0), 0);
    const pre = gs.reduce((a, g) => a + Number(g.revenue || 0) * Number(g.op_margin || 0), 0);
    return `${n}收入 ${fmt(rev, 0)} 亿元、税前 ${fmt(pre, 1)} 亿元（${pct(rev ? pre / rev : null, 1)}）`;
  }).join('；');
  const vy = segs.find((g) => g.earn_year)?.earn_year;
  const fr = fins.find((r) => Number(r.year) === Number(vy));
  const fmPre = fr ? Number(fr.core_op) + 0.7 * Number(fr.acq_amort || 0) : null;
  const fmRev = fr ? Number(fr.revenue) : null;
  ctx.render(
    <div>
      <Title level={5} style={{ marginTop: 0 }}>{full ? `${company.name} · 估值模型` : `${company.name} · 财务模型（三块）`}</Title>
      {full ? (() => {
        const hk = !!fx && isNum(pxH);
        const unit = hk ? '港元' : '元';
        const v = hk ? toH(base.value_per_share) : base.value_per_share, px = hk ? pxH : base.market_price;
        const head = !isNum(v) || !isNum(px) ? '' : `${hk ? '港股价' : '市场价'} ${fmt(px, 2)} ${unit}，比基准每股价值 ${fmt(v, 2)} ${unit}${px < v ? '低' : '高'} ${pct(Math.abs(1 - px / v), 1)}`;
        const low = hk ? toH(sOf(names[0]).value_per_share) : sOf(names[0]).value_per_share;
        return (<>
          <Title level={4} style={{ marginTop: 0 }}>{head}{isNum(low) && isNum(px) && px < low ? '，也低于悲观情景' : ''}</Title>
          <Row gutter={[16, 12]} style={{ marginBottom: 12 }}>
            {names.map((n) => <Col key={n} xs={12} md={4}><Statistic title={hk ? `${n}·每股价值（≈ ${fmt(sOf(n).value_per_share, 2)} 元）` : `${n}·每股价值`} value={fmt(hk ? toH(sOf(n).value_per_share) : sOf(n).value_per_share, 2)} suffix={unit} /></Col>)}
            <Col xs={12} md={4}><Statistic title={hk ? `港股价（${pxDate}）` : '市场价'} value={fmt(px, 2)} suffix={unit} /></Col>
            <Col xs={12} md={4}><Statistic title={`关注价（边际 ${pct(model.margin_low, 0)} / ${pct(model.margin_high, 0)}）`} value={hk ? `${fmt(toH(base.watch_low), 2)} / ${fmt(toH(base.watch_high), 2)}` : `${fmt(base.watch_low, 2)} / ${fmt(base.watch_high, 2)}`} suffix={unit} /></Col>
          </Row>
          <Descriptions size="small" bordered column={narrow ? 1 : 4} style={{ marginBottom: 12 }} items={[
            { key: 'r', label: <span>折现率（基准）<JTag code="J-R" judgments={judgments} /></span>, children: `无风险利率 ${pct(model.rf, 2)} ＋ 风险溢价 ${pct(model.erp, 1)} ＝ ${pct(base.discount_rate, 1)}` },
            { key: 'sh', label: '股本', children: `${fmt(model.shares, 2)} 亿股` },
            { key: 'req', label: '门槛（要求收益率）', children: pct(model.required_return, 1) },
            { key: 'asof', label: '资产负债日', children: base.as_of || '—' },
            ...(fx ? [{ key: 'fx', label: '港元兑人民币', children: `1 港元 ＝ ${fmt(fx, 4)} 元（${pxDate}）` }] : []),
          ]} />
        </>);
      })() : <Paragraph type="secondary">{model.method}</Paragraph>}
      <Card size="small" style={{ marginBottom: 12 }} title="① 主营业务：2027 年收入 × 利润率 ×（1 − 税率）× 归母比例 × 倍数，折回资产负债日">
        <Paragraph style={{ marginBottom: 8 }}>
          <Text strong>利润率</Text>＝核心经营利润率＝（毛利 − 销售费用 − 管理费用 ＋ 七成收购摊销）÷ 收入。税前；不含利息收入、投资收益与融资成本（它们来自现金、持股和借款，在下面的自由现金、对外投资里单独计价）；股权激励作为成本扣除。
          税率 {pct(segs[0]?.tax_rate, 1)}，归母比例 {pct(segs[0]?.attrib, 0)}（扣除少数股东约 3% 的利润；非经营资产净额同样扣 3%，见资产项 C8）。
        </Paragraph>
        <Table size="small" pagination={false} rowKey="key" dataSource={segRows} columns={segCols} scroll={{ x: 'max-content' }} />
        <Paragraph type="secondary" style={{ marginTop: 8, marginBottom: 0 }}>
          三块的利润率是分摊估算（公司不披露分业务成本），基准情景的加总须等于财务模型：{calib}。
          {fr ? `财务模型 ${vy}E：收入 ${fmt(fmRev, 0)} 亿元，核心经营利润 ${fmt(fr.core_op, 1)} ＋ 七成收购摊销 ${fmt(0.7 * Number(fr.acq_amort || 0), 1)} ＝ ${fmt(fmPre, 1)} 亿元。` : ''}修改在本页「业务估值（编辑）」。
        </Paragraph>
      </Card>
      <Card size="small" title={`三块加总：主营 ＋ 自由现金 ＋ 对外投资 → 每股价值${fx ? ' → 港元' : ''}（亿元；资产负债日 ${base.as_of || '—'}；②③ 三情景相同）`}>
        <Table size="small" pagination={false} rowKey="key" dataSource={sumRows} columns={sumCols} scroll={{ x: 'max-content' }} />
        <Paragraph type="secondary" style={{ marginTop: 8, marginBottom: 0 }}>
          {fx ? `港元每股价值＝人民币每股价值 ÷ 当天港元兑人民币 ${fmt(fx, 4)}（自动采集）；港股收盘价 ${fmt(pxH, 2)} 港元为原始报价。` : `市场价 ${fmt(base.market_price, 2)} 元。`}悬停编号看假设依据；改金额在本页「资产估值与调整（编辑）」；情景的折现率与增长率在「情景（编辑）」，股本与风险溢价在「模型参数（编辑）」。
        </Paragraph>
      </Card>
    </div>
  );
}

try {
  const D = await load();
  if (!D.model) ctx.render(<Alert type="info" showIcon message="还没有状态为“当前”的估值模型" />);
  else await renderThree(D, true);
} catch (error) {
  ctx.render(<Alert type="error" showIcon message="估值模型读取失败" description={String(error?.message || error)} />);
}
