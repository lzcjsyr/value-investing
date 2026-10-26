export default async function run(ctx) {
const COMPANY = '601668.SH';
const PROFILE = {"method": "irr", "hurdle_j": null, "logic": "新签合同总额 × 收入转化率是年度收入的近似建模口径；订单并非当期收入。重点检验减值、回款及归母现金能否支持分红。", "drivers": [{"section": "收入与业务规模"}, {"label": "新签合同总额（亿元）", "p": "volume", "h": "volume", "j": ["J-Q"], "d": 2, "how": "逐年路径 × 情景业务量系数"}, {"label": "收入转化率", "p": "price", "h": "price", "j": ["J-P"], "d": 4, "how": "逐年路径 × 情景单价系数"}, {"label": "营业收入", "p": "revenue", "h": "revenue", "strong": true, "how": "业务量 × 单价"}, {"section": "成本与利润（金额：亿元人民币）"}, {"label": "付现成本", "p": "cash_cost", "j": ["J-M"], "how": "基准付现成本 × 情景成本系数"}, {"label": "折旧摊销", "p": "depreciation", "h": "da", "j": ["J-DA"]}, {"label": "利息", "p": "interest", "h": "finance_cost", "j": ["J-DEBT"]}, {"label": "其他净贡献", "p": "other_contrib", "j": ["J-IMP"], "how": "投资收益、减值等净额，按各公司原模型口径"}, {"label": "利润总额", "p": "pretax", "h": "pretax_profit", "strong": true}, {"label": "所得税率", "f": "tax_rate", "h": "tax_rate", "pct": true, "d": 2, "j": ["J-TAX"]}, {"label": "少数股东占比", "f": "minority_share", "h": "minority_share", "pct": true, "d": 2, "j": ["J-TAX"]}, {"label": "归母净利润", "p": "np_parent", "h": "np_parent", "strong": true}, {"section": "股东回报与现金约束"}, {"label": "派息率", "p": "payout", "h": "payout", "j": ["J-PAYOUT"], "pct": true, "how": "计划股息 ÷ 归母净利润"}, {"label": "每股股息（元）", "p": "dps", "h": "dps", "strong": true, "d": 3}, {"label": "维持资本开支", "f": "maint_capex", "j": ["J-CAPEX"], "d": 1}, {"label": "扩张资本开支", "f": "growth_capex", "j": ["J-CAPEX"], "d": 1}, {"label": "营运资本增加", "f": "wc_increase", "j": ["J-WC"], "d": 1}, {"label": "净借款（负数＝偿债）", "f": "net_borrowing", "d": 1}, {"label": "股东自由现金流", "p": "fcfe", "strong": true, "how": "按数据库归母现金桥接口径"}, {"label": "计划回报现金缺口", "p": "funding_gap", "how": "现金不足部分；缺项保持未知"}], "shocks": [{"label": "收入中枢 −5%", "rev": -0.05, "j": "J-Q / J-P"}, {"label": "收入中枢 +5%", "rev": 0.05, "j": "J-Q / J-P"}, {"label": "付现成本 +5%", "cost": 0.05, "j": "J-M"}, {"label": "债务成本 +1 个百分点", "kd": 0.01}, {"label": "永续增长 0%", "g": 0.0, "j": "J-TV"}, {"label": "买入价 −10%", "price": -0.1}]};
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

// 与数据库 vi_pv / vi_irr 同一口径：现金流是从今天起算的每股股息，tau＝(年份−基准年)−距基准日年数，已过去的年份不计；
// 终值＝最后一年股息×(1+g)÷(r−g)，在最后一年折回。
function pv(flows, g, r) {
  if (!isNum(r) || !isNum(g) || r <= g || !flows.length) return null;
  const last = flows[flows.length - 1];
  return flows.reduce((s, x) => s + (x.tau > 0 ? x.dps / Math.pow(1 + r, x.tau) : 0), 0)
    + last.dps * (1 + g) / (r - g) / Math.pow(1 + r, last.tau);
}
function irr(flows, g, price) {
  if (!isNum(price) || price <= 0 || !flows.length || flows.some((x) => !isNum(x.dps))) return null;
  let lo = g + 1e-7, hi = 1;
  if (pv(flows, g, hi) > price) return null;
  for (let i = 0; i < 80; i++) { const mid = (lo + hi) / 2; if (pv(flows, g, mid) > price) lo = mid; else hi = mid; }
  return (lo + hi) / 2;
}

// 每股股息折线（各情景一条，起点是基准年实际）
function DpsChart({ series, startYear, startDps }) {
  const { token } = theme.useToken();
  const W = 640, H = 220, L = 44, R = 64, T = 12, B = 26;
  const all = series.flatMap((s) => s.points.map((p) => p.dps)).concat(isNum(startDps) ? [startDps] : []);
  const lo = Math.floor(Math.min(...all) * 10) / 10, hi = Math.ceil(Math.max(...all) * 10) / 10;
  const years = series[0].points.map((p) => p.year);
  const x0 = isNum(startDps) ? startYear : years[0], x1 = years[years.length - 1];
  const x = (y) => L + ((y - x0) / (x1 - x0 || 1)) * (W - L - R);
  const y = (v) => T + (1 - (v - lo) / (hi - lo || 1)) * (H - T - B);
  const ticks = [lo, (lo + hi) / 2, hi];
  return (
    <svg viewBox={`0 0 ${W} ${H}`} style={{ width: '100%', height: 'auto' }}>
      {ticks.map((t) => (
        <g key={t}>
          <line x1={L} x2={W - R} y1={y(t)} y2={y(t)} stroke={token.colorSplit} />
          <text x={L - 6} y={y(t) + 4} fontSize="11" textAnchor="end" fill={token.colorTextSecondary}>{t.toFixed(2)}</text>
        </g>
      ))}
      {[x0, ...years].filter((yy, i, a) => i === 0 || i === a.length - 1 || (yy - x0) % 2 === 0).map((yy) => (
        <text key={yy} x={x(yy)} y={H - 8} fontSize="11" textAnchor="middle" fill={token.colorTextSecondary}>{yy === x0 && isNum(startDps) ? `${yy}A` : `${yy}E`}</text>
      ))}
      {series.map((s) => {
        const pts = (isNum(startDps) ? [{ year: startYear, dps: startDps }] : []).concat(s.points);
        const end = s.points[s.points.length - 1];
        return (
          <g key={s.name}>
            <polyline fill="none" stroke={s.color} strokeWidth={s.strong ? 2.5 : 1.5} points={pts.map((p) => `${x(p.year)},${y(p.dps)}`).join(' ')} />
            <text x={x(end.year) + 6} y={y(end.dps) + 4} fontSize="11" fill={s.color}>{s.name} {end.dps.toFixed(2)}</text>
          </g>
        );
      })}
      {isNum(startDps) && <circle cx={x(startYear)} cy={y(startDps)} r="3" fill={token.colorText} />}
    </svg>
  );
}

try {
  const D = await load();
  if (!D.model) {
    ctx.render(<Alert type="info" showIcon message="还没有状态为“当前”的估值模型" />);
  } else {
    const { company, model, scenarios, valuations, judgments, history, years, pOf, fOf } = D;
    const shares = Number(model.shares);
    const tauOf = (yy) => (yy - model.base_year) - model.years_elapsed;
    const base = scenarios.find((s) => s.is_base) || scenarios[0];
    const vOf = (s) => valuations.find((v) => v.scenario_name === s.name) || {};
    const price = vOf(base).market_price, priceDate = vOf(base).market_date;
    const flowsOf = (s, dpsFn) => years.map((yy) => {
      const p = pOf(s, yy), f = fOf(yy);
      return { year: yy, tau: tauOf(yy), dps: p ? (dpsFn ? dpsFn(p, f) : p.dps) : null };
    });
    const flows = Object.fromEntries(scenarios.map((s) => [s.id, flowsOf(s)]));
    const irrOf = (s) => irr(flows[s.id], s.terminal_growth, price);
    const hist0 = history.find((h) => h.year === model.base_year);
    const COLORS = (token) => [token.colorError, token.colorPrimary, token.colorSuccess];
    const first = years[0], last = years[years.length - 1];

    // 一次只动一个假设的基准情景（与模型同一套线性关系：利润总额变化 ×(1−税率)×(1−少数股东占比)×派息率 ＝ 股息变化）
    const keep = (f) => (1 - f.tax_rate) * (1 - f.minority_share);
    const shockFlows = (k) => flowsOf(base, (p, f) => {
      const dPretax = (k.rev ? k.rev * p.revenue : 0) - (k.cost ? k.cost * p.cash_cost : 0)
        - (k.kd ? k.kd * (Number(f.debt_open) + Number(f.debt_close)) / 2 : 0);
      return (p.np_parent + dPretax * keep(f)) * (isNum(k.payout) ? k.payout : p.payout) / shares;
    });

    function Panel() {
      const { token } = theme.useToken();
      const colors = COLORS(token);
      const saved = Math.round((model.required_return ?? 0.06) * 1000) / 10;
      const [reqPct, setReqPct] = useState(saved);
      const [saving, setSaving] = useState(false);
      const req = reqPct / 100;
      const ok = (r) => isNum(r) && r >= req;
      const irrColor = (r) => (ok(r) ? token.colorSuccess : token.colorText);
      const baseIrr = irrOf(base);
      const passing = scenarios.filter((s) => ok(irrOf(s)));
      const rf = isNum(model.latest_rf) ? model.latest_rf / 100 : model.rf;

      const save = async () => {
        setSaving(true);
        try {
          await ctx.request({ url: 'vi_model:update', method: 'post', params: { filterByTk: model.id }, data: { required_return: req } });
          message.success(`已保存：门槛 ${reqPct}%`);
        } catch (e) {
          message.error('保存失败：' + String(e?.message || e));
        } finally {
          setSaving(false);
        }
      };

      const verdict = !isNum(baseIrr) ? '算不出隐含回报：预测年份不完整或没有市场价。'
        : `按 ${fmt(price, 2)} 元（${priceDate || ''}）买入，基准情景年化 ${pct(baseIrr, 2)}，`
          + `比门槛 ${pct(req, 1)} ${ok(baseIrr) ? '高' : '低'} ${pp(baseIrr - req)}`
          + `；${passing.length === scenarios.length ? '三个情景都达到门槛' : passing.length ? `达到门槛的只有${passing.map((s) => s.name).join('、')}情景` : '三个情景都低于门槛'}。`;

      // 回报从哪来：首年股息率 ＋ 股息增长 ＋ 永续
      const b0 = pOf(base, first), b1 = pOf(base, last);
      const yield0 = b0 && price ? b0.dps / price : null;
      const growth = b0 && b1 ? Math.pow(b1.dps / b0.dps, 1 / (last - first)) - 1 : null;
      const bf = flows[base.id];
      const terminalShare = isNum(baseIrr) && price
        ? (bf[bf.length - 1].dps * (1 + base.terminal_growth) / (baseIrr - base.terminal_growth) / Math.pow(1 + baseIrr, bf[bf.length - 1].tau)) / price : null;

      // 归母净利润为什么涨：首年 → 末年，各项对利润总额的变化 × 末年保留比例
      const f1 = fOf(last);
      const k1 = f1 ? keep(f1) : 1;
      const parts = b0 && b1 ? [
        { n: '营业收入', v: (b1.revenue - b0.revenue) * k1 },
        { n: '付现成本', v: -(b1.cash_cost - b0.cash_cost) * k1 },
        { n: '折旧退坡', v: -(b1.depreciation - b0.depreciation) * k1 },
        { n: '利息下降', v: -(b1.interest - b0.interest) * k1 },
        { n: '其他净贡献', v: (b1.other_contrib - b0.other_contrib) * k1 },
      ] : [];
      if (parts.length) parts.push({ n: '税率与少数股东', v: (b1.np_parent - b0.np_parent) - parts.reduce((s, p) => s + p.v, 0) });
      const maxPart = Math.max(1, ...parts.map((p) => Math.abs(p.v)));

      // 买入价 → 回报
      const step = price > 50 ? 5 : 2;
      const pts = [];
      if (isNum(price)) for (let q = Math.floor(price * 0.7 / step) * step; q <= price * 1.25; q += step) pts.push(q);
      if (isNum(price) && !pts.includes(price)) pts.push(price);
      pts.sort((a, b) => a - b);
      const priceCols = [
        { title: '情景', dataIndex: 'name', fixed: narrow ? undefined : 'left' },
        ...pts.map((q) => ({
          title: q === price ? <b>{fmt(q, 2)}（现价）</b> : fmt(q, 0), key: 'q' + q, align: 'right',
          render: (_, s) => { const r = irr(flows[s.id], s.terminal_growth, q);
            return <span style={{ color: irrColor(r), fontWeight: q === price ? 600 : 400 }}>{pct(r, 1)}</span>; } })),
        { title: `门槛 ${pct(req, 1)} 下最高买入价`, key: 'cap', align: 'right',
          render: (_, s) => <b>{fmt(pv(flows[s.id], s.terminal_growth, req), 2)} 元</b> },
      ];

      // 什么会改变结论
      const shockRows = PROFILE.shocks.map((k, i) => {
        const fl = (k.rev || k.cost || k.kd || isNum(k.payout)) ? shockFlows(k) : flows[base.id];
        const g = isNum(k.g) ? k.g : base.terminal_growth;
        const q = k.price ? price * (1 + k.price) : price;
        const r = irr(fl, g, q);
        return { key: i, label: k.label, j: k.j, r, d: isNum(r) && isNum(baseIrr) ? r - baseIrr : null, cap: k.price ? null : pv(fl, g, req) };
      });

      const gaps = years.map((yy) => ({ yy, gap: pOf(base, yy)?.funding_gap })).filter((x) => isNum(x.gap) && x.gap > 0.05);
      const cashIrr = vOf(base).cash_implied_irr;

      return (
        <div>
          <Title level={4} style={{ marginTop: 0 }}>{company.name} · 估值：按今天的价格买入，年化回报多少？</Title>
          <Paragraph type="secondary">
            只用一个估值逻辑：把未来每年的每股股息当成债券票息（{first}—{last} 年逐年预测，之后按永续增长延续），
            求出按市场价买入的隐含年化回报，再和门槛比。情景只改现金流，门槛只有一个。
          </Paragraph>

          <Row gutter={[12, 12]} style={{ marginBottom: 12 }}>
            {scenarios.map((s, i) => (
              <Col key={s.id} xs={12} md={5}>
                <Card size="small" style={s.is_base ? { borderColor: token.colorPrimary } : {}}>
                  <Statistic title={`${s.name}情景 · 隐含年化回报`} value={pct(irrOf(s), 2)} valueStyle={{ color: irrColor(irrOf(s)), fontWeight: s.is_base ? 600 : 400 }} />
                </Card>
              </Col>
            ))}
            <Col xs={12} md={5}>
              <Card size="small">
                <div style={{ color: token.colorTextSecondary, marginBottom: 4 }}>门槛（要求的年化回报）{PROFILE.hurdle_j && <JTag code={PROFILE.hurdle_j} judgments={judgments} />}</div>
                <Space.Compact>
                  <InputNumber min={2} max={15} step={0.5} value={reqPct} onChange={(v) => isNum(v) && setReqPct(v)} addonAfter="%" style={{ width: 110 }} />
                  <Button disabled={reqPct === saved} loading={saving} onClick={save}>保存</Button>
                </Space.Compact>
              </Card>
            </Col>
            <Col xs={12} md={4}>
              <Card size="small"><Statistic title={`10 年国债（${model.latest_rf_date || model.rf_date || ''}）`} value={pct(rf, 2)} /></Card>
            </Col>
          </Row>
          <Alert showIcon type={ok(baseIrr) ? 'success' : 'warning'} style={{ marginBottom: 12 }} message={verdict}
            description={isNum(baseIrr) && isNum(rf) ? `基准回报比 10 年国债${baseIrr >= rf ? '高' : '低'} ${pp(baseIrr - rf)}。研究提示，不是交易指令。` : null} />

          <Row gutter={[12, 12]} style={{ marginBottom: 12 }}>
            <Col xs={24} lg={12}>
              <Card size="small" title="回报从哪来（基准情景）" style={{ height: '100%' }}>
                <Row gutter={12}>
                  <Col span={8}><Statistic title={`首年股息率（${first}E）`} value={pct(yield0, 2)} /></Col>
                  <Col span={8}><Statistic title={`股息年增（${first}—${last}E）`} value={pct(growth, 2)} /></Col>
                  <Col span={8}><Statistic title={`${last} 年后永续增长`} value={pct(base.terminal_growth, 1)} /></Col>
                </Row>
                <Paragraph type="secondary" style={{ marginTop: 8, marginBottom: 8 }}>
                  隐含回报 ≈ 股息率 ＋ 股息增长。{last} 年以后的股息（终值）占买入价的 {pct(terminalShare, 0)}，所以永续增长和最后几年的股息水平很关键。
                </Paragraph>
                <div style={{ fontWeight: 500, marginBottom: 4 }}>股息为什么能涨：归母净利润 {fmt(b0?.np_parent, 0)} → {fmt(b1?.np_parent, 0)} 亿元（{first}E → {last}E）</div>
                {parts.map((p) => (
                  <div key={p.n} style={{ display: 'grid', gridTemplateColumns: '96px 1fr 64px', gap: 8, alignItems: 'center', padding: '2px 0' }}>
                    <span style={{ fontSize: 13 }}>{p.n}</span>
                    <div style={{ position: 'relative', height: 12, background: token.colorFillQuaternary, borderRadius: 2 }}>
                      <div style={{ position: 'absolute', top: 0, bottom: 0, borderRadius: 2,
                        left: p.v >= 0 ? '50%' : `${50 - Math.abs(p.v) / maxPart * 50}%`, width: `${Math.abs(p.v) / maxPart * 50}%`,
                        background: p.v >= 0 ? token.colorSuccess : token.colorError }} />
                    </div>
                    <span style={{ textAlign: 'right', fontVariantNumeric: 'tabular-nums', fontSize: 13 }}>{p.v >= 0 ? '+' : '−'}{fmt(Math.abs(p.v), 1)}</span>
                  </div>
                ))}
                <Text type="secondary" style={{ fontSize: 12 }}>各项是对利润总额的变化 × {last} 年的（1 − 税率）×（1 − 少数股东占比），单位亿元。</Text>
              </Card>
            </Col>
            <Col xs={24} lg={12}>
              <Card size="small" title="每股股息路径（元）" style={{ height: '100%' }}>
                <DpsChart startYear={model.base_year} startDps={hist0?.dps}
                  series={scenarios.map((s, i) => ({ name: s.name, color: colors[i % colors.length], strong: s.is_base,
                    points: flows[s.id].filter((p) => isNum(p.dps)) }))} />
                <Text type="secondary" style={{ fontSize: 12 }}>黑点是 {model.base_year} 年实际每股股息；各情景的假设见「财务模型」。</Text>
              </Card>
            </Col>
          </Row>

          <Card size="small" title="买入价 → 年化回报（绿色＝达到门槛）" style={{ marginBottom: 12 }}>
            <Table size="small" pagination={false} rowKey="id" dataSource={scenarios} columns={priceCols} scroll={{ x: 'max-content' }} />
          </Card>

          <Card size="small" title="什么会改变结论（基准情景，一次只动一个假设）" style={{ marginBottom: 12 }}>
            <Table size="small" pagination={false} rowKey="key" dataSource={shockRows} scroll={{ x: 'max-content' }} columns={[
              { title: '变化', dataIndex: 'label' },
              { title: '依据', dataIndex: 'j', render: (v) => (v ? v.split(' / ').map((c) => <JTag key={c} code={c} judgments={judgments} />) : null) },
              { title: '隐含年化回报', dataIndex: 'r', align: 'right', render: (v) => <span style={{ color: irrColor(v) }}>{pct(v, 2)}</span> },
              { title: '比基准', dataIndex: 'd', align: 'right', render: (v) => <span style={{ color: v >= 0 ? token.colorSuccess : token.colorError }}>{bp(v)}</span> },
              { title: `门槛下最高买入价`, dataIndex: 'cap', align: 'right', render: (v) => (isNum(v) ? fmt(v, 2) + ' 元' : '—') },
            ]} />
          </Card>

          <Card size="small" title="检查：计划股息付得出来吗">
            {gaps.length ? (
              <Paragraph style={{ marginBottom: 6 }}>
                基准情景 {gaps[0].yy}—{gaps[gaps.length - 1].yy} 年股东自由现金流不够付计划股息，缺口合计 {fmt(gaps.reduce((s, x) => s + x.gap, 0), 0)} 亿元
                （{gaps.map((x) => `${x.yy} 年 ${fmt(x.gap, 0)}`).join('、')}），计划分红超过了模型当年的可分配现金，需要复核资本开支、回款和融资假设。
                只按付得出的股息算，隐含回报是 {pct(cashIrr, 2)}（相差 {bp(isNum(cashIrr) && isNum(baseIrr) ? cashIrr - baseIrr : null)}）。
              </Paragraph>
            ) : (
              <Paragraph style={{ marginBottom: 6 }}>基准情景各年股东自由现金流都覆盖计划股息。</Paragraph>
            )}
            <Text type="secondary" style={{ fontSize: 12 }}>现金假设见「财务模型」最后一段。</Text>
          </Card>
        </div>
      );
    }
    ctx.render(<Panel />);
  }
} catch (error) {
  ctx.render(<Alert type="error" showIcon message="估值读取失败" description={String(error?.message || error)} />);
}

}
