"""“<公司> / 预测与估值 / 财务模型”：可视化地展示一年的钱怎么从营收一步步算到利润、现金和股息；资产与资本另算。
每家公司一个页面（只看这家公司的模型）。数据全部来自 vi_projection / vi_forecast / vi_balance / vi_fin_history，页面本身不存任何数字。

  python3 build_finmodel.py              # 缺的公司页面才创建
  python3 build_finmodel.py --rebuild    # 删除后重建所有公司的页面（改了下面的 JS 之后用）
"""
import sys
from build_pages import state, companies, destroy_page, valuation_group, CUSTOM_VALUATION
from build_overview import apply_page, record

TITLE, KEY = '财务模型', 'finmodel'

JS = r"""const COMPANY = '__COMPANY__';   // 由 build_finmodel.py 写入：只看这家公司的模型
const { React } = ctx.libs;
const { useState } = React;
const { Card, Segmented, Select, Tabs, Table, Alert, Typography, Space, Row, Col, Statistic, theme } = ctx.libs.antd;
const { Text, Paragraph } = Typography;

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
const signed = (v, d = 1) => (!isNum(v) ? '—' : Math.abs(v) < 0.05 ? fmt(0, d) : (v > 0 ? '+' : '−') + fmt(Math.abs(v), d));
const PALETTE = { op: '#4e79a7', lt: '#59a14f', other: '#bab0ac', debt: '#e15759', mi: '#f28e2b', eq: '#76b7b2', otherLiab: '#9c755f' };
const narrow = (typeof window !== 'undefined' ? window.innerWidth : 1200) < 760;

// 瀑布：total 行从 0 画到数值；其余行从上一行的累计值起，正数向右（绿）、负数向左（红）
function Waterfall({ steps, base, shareLabel }) {
  const { token } = theme.useToken();
  let run = 0;
  const bars = steps.map((s) => {
    const v = Number(s.value) || 0;
    const start = s.kind === 'total' ? 0 : run;
    const end = s.kind === 'total' ? v : run + v;
    run = end;
    return { ...s, v, start, end };
  });
  const hi = Math.max(0, ...bars.map((b) => Math.max(b.start, b.end)));
  const lo = Math.min(0, ...bars.map((b) => Math.min(b.start, b.end)));
  const x = (v) => ((v - lo) / (hi - lo || 1)) * 100;
  const cols = narrow ? 'minmax(0,1fr) 84px' : 'minmax(0,9fr) minmax(0,7fr) 92px 60px';
  const head = { fontSize: 12, color: token.colorTextSecondary };
  return (
    <div>
      {!narrow && (
        <div style={{ display: 'grid', gridTemplateColumns: cols, gap: 12, paddingBottom: 6 }}>
          <span style={head}>项目 · 怎么算（灰字是这一年代入的数）</span>
          <span style={head}>图示</span>
          <span style={{ ...head, textAlign: 'right' }}>亿元</span>
          <span style={{ ...head, textAlign: 'right' }}>{shareLabel}</span>
        </div>
      )}
      {bars.map((b, i) => {
        const total = b.kind === 'total';
        const color = total ? token.colorPrimary : b.v >= 0 ? token.colorSuccess : token.colorError;
        const width = Math.abs(x(b.end) - x(b.start));
        const bar = (
          <div style={{ position: 'relative', height: 16, background: token.colorFillQuaternary, borderRadius: 3 }}>
            {width > 0 && (
              <div style={{ position: 'absolute', left: x(Math.min(b.start, b.end)) + '%', width: Math.max(width, 0.4) + '%',
                top: 0, bottom: 0, background: color, borderRadius: 2, opacity: total ? 1 : 0.8 }} />
            )}
          </div>
        );
        const label = (
          <div>
            <div style={{ fontWeight: total ? 600 : 400 }}>{b.label}</div>
            <div style={{ fontSize: 12, color: token.colorTextSecondary }}>{b.formula}</div>
          </div>
        );
        const amount = (
          <div style={{ textAlign: 'right', fontVariantNumeric: 'tabular-nums', fontWeight: total ? 600 : 400, color: total ? token.colorText : color }}>
            {total ? fmt(b.v) : signed(b.v)}
          </div>
        );
        const share = (
          <div style={{ textAlign: 'right', fontSize: 12, color: token.colorTextSecondary }}>{base ? pct(Math.abs(b.v) / base) : ''}</div>
        );
        const line = `1px solid ${b.divider ? token.colorBorder : token.colorSplit}`;
        return narrow ? (
          <div key={i} style={{ borderTop: line, padding: '6px 0' }}>
            {label}
            <div style={{ display: 'grid', gridTemplateColumns: cols, gap: 8, alignItems: 'center', marginTop: 4 }}>{bar}{amount}</div>
          </div>
        ) : (
          <div key={i} style={{ display: 'grid', gridTemplateColumns: cols, gap: 12, alignItems: 'center', borderTop: line, padding: '6px 0' }}>
            {label}{bar}{amount}{share}
          </div>
        );
      })}
    </div>
  );
}

// 逐年表：行＝科目（附公式），列＝年份；点年份表头切换上方瀑布
function YearTable({ rows, years, year, setYear, firstCol }) {
  const { token } = theme.useToken();
  const cell = (r, v) => (
    <span style={{ fontVariantNumeric: 'tabular-nums', fontWeight: r.strong ? 600 : 400 }}>
      {r.pct ? pct(v) : r.times ? (isNum(v) ? fmt(v, 1) + '×' : '—') : fmt(v, r.d ?? 1)}
    </span>
  );
  const hl = (y) => (y === year ? { background: token.colorPrimaryBg } : {});
  const columns = [
    { title: '项目 · 怎么算', key: 'item', fixed: narrow ? undefined : 'left', width: 250,
      render: (_, r) => (
        <div>
          <div style={{ fontWeight: r.strong ? 600 : 400 }}>{r.item}</div>
          {r.formula && <div style={{ fontSize: 12, color: token.colorTextSecondary }}>{r.formula}</div>}
        </div>
      ) },
    ...(firstCol ? [{ title: firstCol, key: 'first', align: 'right', width: 88, render: (_, r) => cell(r, r.first) }] : []),
    ...years.map((y) => ({
      title: `${y}E`, key: String(y), align: 'right', width: 84,
      onHeaderCell: () => ({ onClick: () => setYear(y), style: { cursor: 'pointer', ...hl(y) } }),
      onCell: () => ({ style: hl(y) }),
      render: (_, r) => cell(r, r.values[y]),
    })),
  ];
  return <Table size="small" pagination={false} rowKey="item" dataSource={rows} columns={columns} scroll={{ x: 'max-content' }} />;
}

// 资产负债的“T 形账户”：左边钱投在哪，右边钱从哪来，两边一样高
function Stack({ title, parts }) {
  const total = parts.reduce((s, p) => s + p.v, 0);
  return (
    <div style={{ flex: 1, minWidth: 200 }}>
      <div style={{ fontWeight: 600, marginBottom: 6 }}>
        {title}<Text type="secondary" style={{ fontWeight: 400 }}> · 合计 {fmt(total, 0)}</Text>
      </div>
      <div style={{ display: 'flex', gap: 10 }}>
        <div style={{ width: 56, height: 220, display: 'flex', flexDirection: 'column', borderRadius: 4, overflow: 'hidden' }}>
          {parts.map((p) => (
            <div key={p.n} title={`${p.n} ${fmt(p.v)}`} style={{ height: (p.v / total) * 100 + '%', background: p.c, borderBottom: '1px solid rgba(255,255,255,.7)' }} />
          ))}
        </div>
        <div style={{ display: 'flex', flexDirection: 'column', justifyContent: 'space-around', fontSize: 13 }}>
          {parts.map((p) => (
            <div key={p.n}>
              <span style={{ display: 'inline-block', width: 10, height: 10, background: p.c, borderRadius: 2, marginRight: 6 }} />
              {p.n} <b style={{ fontVariantNumeric: 'tabular-nums' }}>{fmt(p.v, 0)}</b> <Text type="secondary">{pct(p.v / total, 0)}</Text>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

try {
  const [companies, allModels] = await Promise.all([listRows('vi_company'), listRows('vi_model', { status: { $eq: '当前' } })]);
  const only = companies.find((c) => c.code === COMPANY);
  const models = only ? allModels.filter((m) => m.company_id === only.id) : allModels;
  if (!models.length) {
    ctx.render(<Alert type="info" showIcon message="还没有状态为“当前”的估值模型" />);
    return;
  }
  const byModel = { model_id: { $in: models.map((m) => m.id) } };
  const [scenarios, projections, forecasts, balances, history] = await Promise.all([
    listRows('vi_scenario', byModel), listRows('vi_projection', byModel), listRows('vi_forecast', byModel),
    listRows('vi_balance', byModel), listRows('vi_fin_history'),
  ]);
  const coOf = (m) => companies.find((c) => c.id === m.company_id) || {};
  const defaultModel = models.find((m) => coOf(m).is_default) || models[0];

  function Panel() {
    const [modelId, setModelId] = useState(defaultModel.id);
    const [scName, setScName] = useState(null);
    const [year, setYear] = useState(null);
    const [tab, setTab] = useState('pl');

    const model = models.find((m) => m.id === modelId) || defaultModel;
    const co = coOf(model);
    const scs = scenarios.filter((s) => s.model_id === model.id).sort((a, b) => (a.sort ?? 0) - (b.sort ?? 0) || a.id - b.id);
    const sc = scs.find((s) => s.name === scName) || scs.find((s) => s.is_base) || scs[0] || {};
    const years = [...new Set(forecasts.filter((f) => f.model_id === model.id).map((f) => f.year))].sort((a, b) => a - b);
    const y = years.includes(year) ? year : years[0];
    const pOf = (yy) => projections.find((p) => p.model_id === model.id && p.scenario_name === sc.name && p.year === yy);
    const fOf = (yy) => forecasts.find((f) => f.model_id === model.id && f.year === yy);
    const bOf = (yy) => balances.find((b) => b.model_id === model.id && b.scenario_name === sc.name && b.year === yy);
    const hist = history.find((h) => h.company_id === co.id && h.year === model.base_year);
    const p = pOf(y);
    const f = fOf(y);
    if (!p || !f) return <Alert type="info" showIcon message="这个模型还没有逐年假设或情景" />;

    const vName = co.volume_label || '业务量';
    const pName = co.price_label || '单价';
    const vf = Number(sc.volume_factor ?? 1), pf = Number(sc.price_factor ?? 1), cf = Number(sc.cost_factor ?? 1);
    const factorNote = vf !== 1 || pf !== 1 ? `（已乘情景系数：${vName}×${vf}，${pName}×${pf}）` : '';
    const series = (get) => Object.fromEntries(years.map((yy) => [yy, pOf(yy) ? get(pOf(yy), fOf(yy)) : null]));

    // ---------- 利润：营收 → 利润总额 → 归母净利 → 股息 ----------
    const plSteps = [
      { kind: 'total', label: '营业收入', value: p.revenue,
        formula: `${vName} ${fmt(p.volume, 1)} ${co.volume_unit || ''} × ${pName} ${fmt(p.price, 4)} ${co.price_unit || ''}${factorNote}` },
      { label: '付现成本', value: -p.cash_cost,
        formula: cf !== 1 ? `逐年假设 ${fmt(f.cash_cost)} × 情景成本系数 ${cf}` : '逐年假设：营业成本中非折旧部分＋期间费用＋税金及附加' },
      { label: '折旧摊销', value: -p.depreciation, formula: '逐年假设；不花现金，在“现金”页加回' },
      { label: '利息', value: -p.interest,
        formula: `(期初带息负债 ${fmt(f.debt_open, 0)} ＋ 期末 ${fmt(f.debt_close, 0)}) ÷ 2 × 平均债务成本 ${pct(f.cost_of_debt, 2)}` },
      { label: '其他净贡献', value: p.other_contrib, formula: '投资收益、公允价值变动、减值、营业外等净额（逐年假设）' },
      { kind: 'total', label: '利润总额', value: p.pretax, formula: '营业收入 − 付现成本 − 折旧摊销 − 利息 ＋ 其他净贡献', divider: true },
      { label: '所得税', value: -p.tax, formula: `利润总额 ${fmt(p.pretax)} × 所得税率 ${pct(f.tax_rate, 2)}` },
      { label: '少数股东损益', value: -p.minority, formula: `税后利润 ${fmt(p.pretax - p.tax)} × 少数股东占比 ${pct(f.minority_share, 2)}` },
      { kind: 'total', label: '归母净利润', value: p.np_parent,
        formula: `利润总额 − 所得税 − 少数股东损益；每股收益 ${fmt(p.np_parent / model.shares, 3)} 元`, divider: true },
      { label: '留存（不分配）', value: -(p.np_parent - p.dividend), formula: `归母净利润 × (1 − 派息率 ${pct(p.payout)})` },
      { kind: 'total', label: '股息（估值用的现金流）', value: p.dividend,
        formula: `归母净利润 × 派息率 ${pct(p.payout)}；每股 ${fmt(p.dps, 3)} 元 ＝ 股息 ÷ 总股本 ${fmt(model.shares, 2)} 亿股`, divider: true },
    ];
    const plRows = [
      { item: `${vName}（${co.volume_unit || ''}）`, formula: '逐年假设 × 情景系数', values: series((q) => q.volume), first: hist?.volume },
      { item: `${pName}（${co.price_unit || ''}）`, formula: '逐年假设 × 情景系数', values: series((q) => q.price), first: hist?.price, d: 4 },
      { item: '营业收入', formula: `${vName} × ${pName}`, values: series((q) => q.revenue), first: hist?.revenue, strong: true },
      { item: '− 付现成本', formula: '逐年假设 × 情景成本系数', values: series((q) => q.cash_cost), first: null },
      { item: '− 折旧摊销', formula: '逐年假设', values: series((q) => q.depreciation), first: hist?.da },
      { item: '− 利息', formula: '平均带息负债 × 平均债务成本', values: series((q) => q.interest), first: hist?.finance_cost },
      { item: '＋ 其他净贡献', formula: '逐年假设', values: series((q) => q.other_contrib), first: null },
      { item: '利润总额', formula: '以上合计', values: series((q) => q.pretax), first: hist?.pretax_profit, strong: true },
      { item: '− 所得税', formula: '利润总额 × 所得税率', values: series((q) => q.tax), first: hist?.income_tax },
      { item: '− 少数股东损益', formula: '税后利润 × 少数股东占比', values: series((q) => q.minority), first: hist?.minority_profit },
      { item: '归母净利润', formula: '利润总额 − 所得税 − 少数股东损益', values: series((q) => q.np_parent), first: hist?.np_parent, strong: true },
      { item: '净利率', formula: '归母净利润 ÷ 营业收入', values: series((q) => q.np_parent / q.revenue),
        first: hist ? hist.np_parent / hist.revenue : null, pct: true },
      { item: '派息率', formula: '逐年假设', values: series((q) => q.payout), first: hist?.payout, pct: true },
      { item: '股息', formula: '归母净利润 × 派息率', values: series((q) => q.dividend), first: hist?.dividend_total, strong: true },
      { item: '每股股息（元）', formula: '股息 ÷ 总股本', values: series((q) => q.dps), first: hist?.dps, d: 3 },
    ];
    const histGap = hist ? hist.revenue - hist.da - hist.finance_cost - hist.pretax_profit : null;

    // ---------- 现金：归母净利 → 所有者收益 → FCFE ----------
    const cashOk = !!f.cash_complete;
    const cashSteps = [
      { kind: 'total', label: '归母净利润', value: p.np_parent, formula: '来自“利润”页' },
      { label: '加回：归属折旧', value: f.attrib_da, formula: `折旧 ${fmt(p.depreciation)} × (1 − 少数股东占比 ${pct(f.minority_share, 2)})` },
      { label: '扣除：非现金收益', value: -f.noncash_gain_deduct, formula: '权益法投资收益等，记入利润但没收到现金' },
      { label: '加：收到投资分红', value: f.investee_cash_div, formula: '被投资企业实际分到手的现金' },
      { label: '其他现金调整', value: f.other_cash_adj, formula: '必须有明确依据，不能用来凑数' },
      { label: '扣除：营运资本增加', value: -f.wc_increase, formula: '应收、存货增加占用的现金' },
      { label: '扣除：维持资本开支', value: -f.maint_capex, formula: '维持现有业务量所需的更新改造' },
      { kind: 'total', label: '所有者收益', value: p.owner_earnings, formula: '不削弱现有业务、可以拿走的现金', divider: true },
      { label: '扣除：扩张资本开支', value: -f.growth_capex, formula: '新项目投资（其收益是否已进营收要在逐年假设里写清）' },
      { label: f.net_borrowing < 0 ? '扣除：净还债' : '加：净借款', value: f.net_borrowing, formula: '同时决定期末带息负债和利息' },
      { kind: 'total', label: '股权自由现金流（FCFE）', value: p.fcfe, formula: '所有者收益 − 扩张资本开支 ＋ 净借款', divider: true },
    ];
    const fseries = (get) => Object.fromEntries(years.map((yy) => [yy, fOf(yy) ? get(fOf(yy), pOf(yy)) : null]));
    const cashRows = [
      { item: '归母净利润', formula: '来自利润表', values: series((q) => q.np_parent), strong: true },
      { item: '＋ 归属折旧', formula: '折旧 × (1 − 少数股东占比)', values: fseries((q) => q.attrib_da) },
      { item: '− 非现金收益', formula: '逐年假设', values: fseries((q) => q.noncash_gain_deduct) },
      { item: '＋ 收到投资分红', formula: '逐年假设', values: fseries((q) => q.investee_cash_div) },
      { item: '± 其他现金调整', formula: '逐年假设', values: fseries((q) => q.other_cash_adj) },
      { item: '− 营运资本增加', formula: '逐年假设', values: fseries((q) => q.wc_increase) },
      { item: '− 维持资本开支', formula: '逐年假设', values: fseries((q) => q.maint_capex) },
      { item: '所有者收益', formula: '以上合计', values: series((q) => q.owner_earnings), strong: true },
      { item: '− 扩张资本开支', formula: '逐年假设', values: fseries((q) => q.growth_capex) },
      { item: '＋ 净借款', formula: '逐年假设；负数＝还债', values: fseries((q) => q.net_borrowing) },
      { item: '股权自由现金流（FCFE）', formula: '所有者收益 − 扩张资本 ＋ 净借款', values: series((q) => q.fcfe), strong: true },
      { item: '计划股息', formula: '归母净利润 × 派息率', values: series((q) => q.dividend) },
      { item: '现金能支持的股息', formula: 'min(股息, FCFE − 最低现金补充)', values: series((q) => q.cash_supported_div) },
      { item: '资金缺口', formula: 'max(0, 股息 ＋ 最低现金补充 − FCFE)', values: series((q) => q.funding_gap), strong: true },
    ];

    // ---------- 资产与资本：逐项滚动，平衡项＝其他净资产 ----------
    const open0 = { op: model.opening_op_assets, lt: model.opening_lt_invest, debt: model.opening_debt, eq: model.opening_equity, mi: model.opening_minority };
    const bsOk = [open0.op, open0.lt, open0.debt, open0.eq, open0.mi].every(isNum);
    open0.other = bsOk ? open0.eq + open0.mi + open0.debt - open0.op - open0.lt : null;
    const closeOf = (yy) => {
      const b = bOf(yy);
      return b ? { op: b.op_assets_close, lt: b.lt_invest_close, debt: b.debt_close, eq: b.equity_close, mi: b.minority_close, other: b.other_net_assets } : null;
    };
    const b = bOf(y);
    const cur = closeOf(y);
    const prev = closeOf(y - 1) || open0;
    const flow = (v) => ({ add: v > 0 ? v : 0, sub: v < 0 ? -v : 0 });
    const otherChg = bsOk && cur ? cur.other - prev.other : null;
    const rollRows = bsOk && cur ? [
      { item: '经营性长期资产', what: '固定资产＋在建工程＋无形资产＋使用权资产', open: prev.op,
        add: b.capex_total, addWhy: `资本开支（维持 ${fmt(f.maint_capex)}＋扩张 ${fmt(f.growth_capex)}）`, sub: b.depreciation, subWhy: '折旧摊销', close: cur.op },
      { item: '长期股权投资', what: '联营、合营企业股权', open: prev.lt,
        add: f.noncash_gain_deduct, addWhy: '权益法投资收益', sub: f.investee_cash_div, subWhy: '收到的投资分红', close: cur.lt },
      { item: '其他净资产（平衡项）', what: '现金＋营运资本−应付等无息负债', open: prev.other,
        ...flow(otherChg), addWhy: '当年现金净增加（约）', subWhy: '当年现金净减少（约）', close: cur.other },
      { item: '资产合计', strong: true, open: prev.op + prev.lt + prev.other, close: cur.op + cur.lt + cur.other },
      { item: '带息负债', what: '借款＋债券＋租赁负债', open: prev.debt,
        ...flow(f.net_borrowing), addWhy: '净借款', subWhy: '净还债', close: cur.debt },
      { item: '少数股东权益', what: '子公司里不属于本公司股东的部分', open: prev.mi,
        add: p.minority, addWhy: '少数股东损益', sub: p.minority * p.payout, subWhy: '少数股东分红（按同一派息率）', close: cur.mi },
      { item: '归母权益', what: '属于本公司股东的净资产', open: prev.eq,
        add: p.np_parent, addWhy: '归母净利润', sub: p.dividend, subWhy: '股息', close: cur.eq },
      { item: '资本合计', strong: true, open: prev.debt + prev.mi + prev.eq, close: cur.debt + cur.mi + cur.eq },
    ] : [];
    const bseries = (get) => Object.fromEntries(years.map((yy) => [yy, bOf(yy) ? get(bOf(yy)) : null]));
    const bsRows = [
      { item: '经营性长期资产', formula: '期初＋资本开支−折旧', values: bseries((q) => q.op_assets_close), first: open0.op },
      { item: '长期股权投资', formula: '期初＋权益法收益−收到分红', values: bseries((q) => q.lt_invest_close), first: open0.lt },
      { item: '其他净资产（平衡项）', formula: '权益＋负债−上面两项；下降＝动用现金', values: bseries((q) => q.other_net_assets), first: open0.other, strong: true },
      { item: '带息负债', formula: '期初＋净借款', values: bseries((q) => q.debt_close), first: open0.debt },
      { item: '少数股东权益', formula: '期初＋少数股东损益×(1−派息率)', values: bseries((q) => q.minority_close), first: open0.mi },
      { item: '归母权益', formula: '期初＋归母净利−股息', values: bseries((q) => q.equity_close), first: open0.eq },
      { item: 'ROE', formula: '归母净利 ÷ 平均归母权益', values: bseries((q) => q.roe), first: null, pct: true },
      { item: '带息负债率', formula: '带息负债 ÷ (带息负债＋全部权益)', values: bseries((q) => q.debt_to_capital),
        first: bsOk ? open0.debt / (open0.debt + open0.eq + open0.mi) : null, pct: true },
      { item: '利息保障倍数', formula: '(利润总额＋利息) ÷ 利息', values: bseries((q) => q.interest_cover), first: null, times: true },
      { item: '带息负债 ÷ EBITDA', formula: 'EBITDA＝利润总额＋利息＋折旧', values: bseries((q) => q.debt_to_ebitda), first: null, times: true },
    ];

    const controls = (
      <Space wrap size={[16, 8]}>
        {models.length > 1 && (
          <Select value={model.id} onChange={(v) => setModelId(v)} style={{ minWidth: 220 }}
            options={models.map((m) => ({ value: m.id, label: `${coOf(m).name || ''} · ${m.name}` }))} />
        )}
        <Space size={6}><Text type="secondary">情景</Text>
          <Segmented value={sc.name} onChange={(v) => setScName(v)} options={scs.map((s) => s.name)} /></Space>
        <Space size={6}><Text type="secondary">年份</Text>
          {narrow || years.length > 12
            ? <Select value={y} onChange={(v) => setYear(v)} style={{ width: 100 }} options={years.map((v) => ({ value: v, label: `${v}E` }))} />
            : <Segmented value={y} onChange={(v) => setYear(v)} options={years.map((v) => ({ value: v, label: String(v) }))} />}
        </Space>
      </Space>
    );

    const cover = isNum(p.fcfe) && p.dividend > 0 ? p.fcfe / p.dividend : null;
    const summary = (
      <Row gutter={[12, 12]} style={{ marginBottom: 4 }}>
        <Col xs={12} md={6}><Statistic title={`营业收入（${y}E，亿元）`} value={fmt(p.revenue)} /></Col>
        <Col xs={12} md={6}><Statistic title={`归母净利润 · 净利率 ${pct(p.np_parent / p.revenue)}`} value={fmt(p.np_parent)} /></Col>
        <Col xs={12} md={6}><Statistic title={`每股股息 · 派息率 ${pct(p.payout)}`} value={fmt(p.dps, 3)} suffix="元" /></Col>
        <Col xs={12} md={6}><Statistic title="FCFE ÷ 计划股息" value={cover === null ? '—' : fmt(cover, 2) + '×'}
          valueStyle={{ color: cover !== null && cover < 1 ? '#cf1322' : undefined }} /></Col>
      </Row>
    );

    const plTab = (
      <div>
        <Paragraph type="secondary">
          利润表回答“这一年赚多少”。每行灰字是公式和代入的数字；数字来自「逐年假设」和「情景」，改了之后刷新本页即可。
          股息是 DDM 估值真正用到的现金流。
        </Paragraph>
        <Card size="small" title={`${y}E · ${sc.name}情景：从营收到股息`} style={{ marginBottom: 12 }}>
          <Waterfall steps={plSteps} base={p.revenue} shareLabel="占营收" />
        </Card>
        <Card size="small" title="逐年利润表（点年份表头切换上面的瀑布）">
          <YearTable rows={plRows} years={years} year={y} setYear={setYear} firstCol={hist ? `${model.base_year}A` : null} />
          {hist && (
            <Paragraph type="secondary" style={{ marginTop: 8, marginBottom: 0, fontSize: 12 }}>
              {model.base_year}A 为年报实际值，“利息”列取财务费用。付现成本与其他净贡献在年报里不单独披露，
              两者之差＝营业收入−折旧−财务费用−利润总额＝{fmt(histGap)} 亿元，模型的基准年校准即以此为准。
            </Paragraph>
          )}
        </Card>
      </div>
    );

    const cashTab = (
      <div>
        <Paragraph type="secondary">
          利润不等于能分的钱：折旧不花现金要加回，没收到现金的投资收益要扣掉，维持和扩张都要花钱，还债也占用现金。
          所有者收益是“不削弱现有业务能拿走的钱”，FCFE 再扣掉扩张、加上借款。
        </Paragraph>
        {!cashOk ? (
          <Alert type="warning" showIcon message={`${y} 年现金桥接有缺项，暂不计算`} description="到「逐年假设」把非现金收益、投资分红、营运资本、维持/扩张资本、净借款等填全。" />
        ) : (
          <div>
            <Card size="small" title={`${y}E · ${sc.name}情景：从净利到可分配现金`} style={{ marginBottom: 12 }}>
              <Waterfall steps={cashSteps} base={p.np_parent} shareLabel="占净利" />
              <Alert style={{ marginTop: 12 }} showIcon type={p.funding_gap > 0.05 ? 'warning' : 'success'}
                message={p.funding_gap > 0.05
                  ? `FCFE ${fmt(p.fcfe)} 亿元不够付计划股息 ${fmt(p.dividend)} 亿元${f.min_cash_topup ? `（另需留存 ${fmt(f.min_cash_topup)}）` : ''}：缺口 ${fmt(p.funding_gap)} 亿元，要动用账上现金或多借款。按现金口径这一年只能支持 ${fmt(p.cash_supported_div)} 亿元股息。`
                  : `FCFE ${fmt(p.fcfe)} 亿元足够支付计划股息 ${fmt(p.dividend)} 亿元，多出的 ${fmt(p.fcfe - p.dividend - (f.min_cash_topup || 0))} 亿元留在公司。`} />
            </Card>
            <Card size="small" title="逐年现金桥接（点年份表头切换）">
              <YearTable rows={cashRows} years={years} year={y} setYear={setYear} />
            </Card>
          </div>
        )}
      </div>
    );

    const rollColumns = [
      { title: '科目 · 是什么', key: 'item', width: 230, render: (_, r) => (
        <div><div style={{ fontWeight: r.strong ? 600 : 400 }}>{r.item}</div>{r.what && <Text type="secondary" style={{ fontSize: 12 }}>{r.what}</Text>}</div>) },
      { title: `期初（${y - 1}${y - 1 === model.base_year ? 'A' : 'E'} 末）`, key: 'open', align: 'right', render: (_, r) => <span style={{ fontWeight: r.strong ? 600 : 400 }}>{fmt(r.open)}</span> },
      { title: '增加', key: 'add', align: 'right', render: (_, r) => (r.strong ? '' : (
        <div><span style={{ color: '#389e0d' }}>{r.add > 0.05 ? '+' + fmt(r.add) : '—'}</span>{r.add > 0.05 && <div><Text type="secondary" style={{ fontSize: 12 }}>{r.addWhy}</Text></div>}</div>)) },
      { title: '减少', key: 'sub', align: 'right', render: (_, r) => (r.strong ? '' : (
        <div><span style={{ color: '#cf1322' }}>{r.sub > 0.05 ? '−' + fmt(r.sub) : '—'}</span>{r.sub > 0.05 && <div><Text type="secondary" style={{ fontSize: 12 }}>{r.subWhy}</Text></div>}</div>)) },
      { title: `期末（${y}E 末）`, key: 'close', align: 'right', render: (_, r) => <span style={{ fontWeight: 600 }}>{fmt(r.close)}</span> },
    ];

    const bsTab = !bsOk ? (
      <Alert type="info" showIcon message="还没有期初资产负债"
        description="到「估值模型」填写基准年末的经营性长期资产、长期股权投资、带息负债、归母权益、少数股东权益（亿元），这里就会逐年滚动。" />
    ) : (
      <div>
        <Paragraph type="secondary">
          资产侧在利润表之外单独推算，不改变上面的利润和估值（利息用的带息负债与这里是同一条）。它回答的是：
          按这套假设分红、投资、还债，资产负债会变成什么样——现金会不会被抽干，负债和利息是否安全。
          “其他净资产”是平衡项（现金＋营运资本−应付等无息负债），它每年的变化约等于当年现金净增减。
        </Paragraph>
        <Row gutter={[12, 12]} style={{ marginBottom: 12 }}>
          <Col xs={24} lg={12}>
            <Card size="small" title={`${y}E 末 · ${sc.name}情景：钱投在哪 / 钱从哪来`} style={{ height: '100%' }}>
              <div style={{ display: 'flex', gap: 16, flexWrap: 'wrap' }}>
                <Stack title="资产" parts={[
                  { n: '经营性长期资产', v: cur.op, c: PALETTE.op }, { n: '长期股权投资', v: cur.lt, c: PALETTE.lt },
                  ...(cur.other > 0 ? [{ n: '其他净资产', v: cur.other, c: PALETTE.other }] : [])]} />
                <Stack title="资本" parts={[
                  ...(cur.other < 0 ? [{ n: '应付等无息负债（净）', v: -cur.other, c: PALETTE.otherLiab }] : []),
                  { n: '带息负债', v: cur.debt, c: PALETTE.debt }, { n: '少数股东权益', v: cur.mi, c: PALETTE.mi }, { n: '归母权益', v: cur.eq, c: PALETTE.eq }]} />
              </div>
              {cur.other < 0 && (
                <Text type="secondary" style={{ fontSize: 12 }}>
                  其他净资产为负（应付等无息负债大于现金和营运资本），画在右边作为资金来源；下表把它记在资产侧的负数里，所以两处合计相差 {fmt(-cur.other, 0)}。
                </Text>
              )}
            </Card>
          </Col>
          <Col xs={24} lg={12}>
            <Row gutter={[12, 12]}>
              <Col span={12}><Card size="small"><Statistic title="ROE（归母净利÷平均归母权益）" value={pct(b.roe)} /></Card></Col>
              <Col span={12}><Card size="small"><Statistic title="带息负债率（÷带息负债＋全部权益）" value={pct(b.debt_to_capital)} /></Card></Col>
              <Col span={12}><Card size="small"><Statistic title="利息保障倍数（(利润总额＋利息)÷利息）" value={fmt(b.interest_cover, 1) + '×'} /></Card></Col>
              <Col span={12}><Card size="small"><Statistic title="带息负债 ÷ EBITDA" value={fmt(b.debt_to_ebitda, 2) + '×'} /></Card></Col>
              <Col span={24}>
                <Alert showIcon type={otherChg < 0 ? 'warning' : 'success'} message={otherChg < 0
                  ? `${y} 年股息、资本开支和还债合计超过了经营带来的现金，其他净资产减少 ${fmt(-otherChg)} 亿元（约等于动用账上现金）。`
                  : `${y} 年经营现金覆盖了股息、资本开支和还债，其他净资产增加 ${fmt(otherChg)} 亿元。`} />
              </Col>
            </Row>
          </Col>
        </Row>
        <Card size="small" title={`${y}E 逐项滚动：期初 ＋ 增加 − 减少 ＝ 期末`} style={{ marginBottom: 12 }}>
          <Table size="small" pagination={false} rowKey="item" dataSource={rollRows} columns={rollColumns} scroll={{ x: 'max-content' }} />
        </Card>
        <Card size="small" title="逐年资产与资本（点年份表头切换）">
          <YearTable rows={bsRows} years={years} year={y} setYear={setYear} firstCol={`${model.base_year}A`} />
        </Card>
      </div>
    );

    return (
      <div>
        <Space wrap align="center" style={{ justifyContent: 'space-between', width: '100%', marginBottom: 12 }}>
          <Typography.Title level={4} style={{ margin: 0 }}>{co.name || ''} · {model.name}</Typography.Title>
          {controls}
        </Space>
        {summary}
        <Tabs activeKey={tab} onChange={setTab} items={[
          { key: 'pl', label: '利润：营收 → 净利 → 股息', children: plTab },
          { key: 'cash', label: '现金：净利 → 可分配现金', children: cashTab },
          { key: 'bs', label: '资产与资本（另算）', children: bsTab },
        ]} />
      </div>
    );
  }

  ctx.render(<Panel />);
} catch (error) {
  ctx.render(<Alert type="error" showIcon message="财务模型读取失败" description={String(error?.message || error)} />);
}
"""


def create(co):
    st = state()
    # 财务模型是财务引擎的可视化，属于“预测与估值”组（有定制估值页的公司放进组内“模型底稿”），排在表格页前（sort_menu）
    gid = valuation_group(st, co)
    key = f"{KEY}@{co['code']}"
    apply_page(f"{KEY}_{co['code']}", {
        'version': '1', 'mode': 'create',
        'navigation': {'group': {'routeId': gid}, 'item': {'title': TITLE, 'icon': 'FundProjectionScreenOutlined'}},
        'page': {'title': TITLE, 'documentTitle': f"{co['name']} · {TITLE}"},
        'assets': {'scripts': {KEY: {'version': 'v2', 'code': JS.replace('__COMPANY__', co['code'])}}},
        'tabs': [{'title': TITLE, 'blocks': [{'key': KEY, 'type': 'jsBlock', 'script': KEY}]}]})
    record(key, gid, TITLE)


if __name__ == '__main__':
    for co in companies():
        if KEY in CUSTOM_VALUATION.get(co['code'], {}).get('skip', ()):
            continue                              # 定制估值页（build_valuation.py）已取代
        key = f"{KEY}@{co['code']}"
        if '--rebuild' in sys.argv:
            destroy_page(key)
        if key not in state()['pages']:
            create(co)
