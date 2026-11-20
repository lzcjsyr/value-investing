"""「预测与估值」五个页面：按「估值地基：Greenwald 三层价值」的分层（2026-11-11 重构）。

  ① 资产价值（第一层）       全公司经营资产与经营负债、公司的资产价值口径
  ② 盈利能力（第二层）   调整后利润表（每块业务一张，历年数＋正常化值，逐行算到 E 与盈利能力价值）
  ③ 增长价值（第三层）       增长（增长率、新增投资回报率、优势年限）
  ④ 独立资产           现金与投资、参照估值、有息负债、其他索取权
  ⑤ 股权价值             结论：各层股权价值、每股价值、隐含回报、估值检查；估值设置
  （第六页是表格页「假设依据」，由 build_pages.py 生成）

  python3 framework/build_greenwald.py --register      登记集合（之后 docker compose restart app）
  python3 framework/build_greenwald.py [公司代码 ...]   生成或原地更新这五页（不写公司代码＝全部公司）

页面只读 vi_gw_value / vi_gw_unit / vi_bs_item / vi_check（02_calc.sql），不在页面里计算价值。
"""
import sys

import align_companies as al
import build_overview as overview
import build_pages as bp
import register
import spec

PAGES = [  # (页面键, 标题, 图标, 模式, 编辑标签 [(表, 标签, 数据范围)])
    ('gw_av', '① 资产价值', 'GoldOutlined', 'av',
     [('bs_item', '经营资产与负债（编辑）', 'ops'), ('company', '资产价值口径（编辑）', 'asset_settings')]),
    ('gw_epv', '② 盈利能力', 'FundOutlined', 'epv',
     [('epv', '调整后利润表（编辑）', None), ('business', '业务（编辑）', None)]),
    ('gw_growth', '③ 增长价值', 'RiseOutlined', 'growth', [('growth', '增长（编辑）', None)]),
    ('gw_bridge', '④ 独立资产', 'SwapOutlined', 'bridge', [('bs_item', '资产负债桥（编辑）', 'bridge')]),
    ('gw_equity', '⑤ 股权价值', 'FlagOutlined', 'equity',
     [('company', '估值设置（编辑）', 'self')]),
]
assert [p[1] for p in PAGES] == bp.VALUATION_PAGES

JS = r"""const COMPANY = '__COMPANY__';
const MODE = '__MODE__';
const { React } = ctx.libs;
const { useState } = React;
const { Card, Table, Alert, Typography, Space, Tag, Row, Col, Statistic, Tooltip, theme } = ctx.libs.antd;
const { Text, Paragraph } = Typography;

async function listRows(name, filter, pageSize = 2000, appends) {
  const resource = ctx.makeResource('MultiRecordResource');
  resource.setResourceName(name);
  resource.setPageSize?.(pageSize);
  if (appends) resource.setAppends?.(appends);
  if (filter) resource.setFilter?.(filter);
  await resource.refresh();
  return resource.getData() || [];
}
const isNum = (v) => v !== null && v !== undefined && v !== '' && !Number.isNaN(Number(v));
const fmt = (v, d = 1) => (isNum(v) ? Number(v).toLocaleString('zh-CN', { minimumFractionDigits: d, maximumFractionDigits: d }) : '—');
const pct = (v, d = 1) => (isNum(v) ? (Number(v) * 100).toFixed(d) + '%' : '—');
const bySort = (k) => (a, b) => (a[k] ?? 0) - (b[k] ?? 0) || a.id - b.id;
const sum = (rs, k) => rs.reduce((s, r) => s + (Number(r[k]) || 0), 0);
const RESULT_COLOR = { 通过: 'green', 提示: 'gold', 阻断: 'red', 不适用: 'default' };
const LAYERS = [['av_ps', '资产价值', '第一层：调整后的经营资产（或重建成本）＋资产负债桥'],
                ['epv_ps', '盈利能力价值', '第二层：今天可持续的现金收益÷门槛，不增长'],
                ['full_ps', '含增长价值', '第三层：优势期内的增长，之后增长不再创造价值']];
const num = (title, dataIndex, d = 1, extra = {}) => ({ title, dataIndex, key: dataIndex, align: 'right', render: (v) => fmt(v, d), ...extra });
const per = (title, dataIndex, d = 1, extra = {}) => ({ title, dataIndex, key: dataIndex, align: 'right', render: (v) => pct(v, d), ...extra });
const tip = (label, text) => <Tooltip title={text}>{label}</Tooltip>;

async function load() {
  const [company] = await listRows('vi_company', { code: { $eq: COMPANY } });
  const byCo = { company_id: { $eq: company.id } };
  const [values, units, items, checks, settings, lines] = await Promise.all([
    listRows('vi_gw_value', byCo), listRows('vi_gw_unit', byCo), listRows('vi_bs_item', byCo), listRows('vi_check', byCo),
    listRows('vi_setting'), listRows('vi_epv', byCo, 2000, ['judgments'])]);
  lines.forEach((l) => { try { l.hist = JSON.parse(l.history || '[]'); } catch (e) { l.hist = []; } });
  return { company, v: values[0], units: units.sort(bySort('business_sort')), items: items.sort(bySort('sort')),
           lines: lines.sort(bySort('sort')), checks: checks.sort(bySort('id')), hurdle: settings[0]?.hurdle };
}

function Intro({ title, children }) {
  const { token } = theme.useToken();
  return (
    <div style={{ borderLeft: `4px solid ${token.colorPrimary}`, background: token.colorFillQuaternary, borderRadius: 8, padding: '10px 14px' }}>
      <Text strong>{title}</Text><div style={{ marginTop: 4 }}><Text type="secondary">{children}</Text></div>
    </div>
  );
}

function Checks({ d, codes }) {
  const rows = d.checks.filter((c) => !codes || codes.includes(c.code));
  return (
    <Space direction="vertical" style={{ width: '100%' }}>
      {rows.map((c) => (<div key={c.id}><Tag color={RESULT_COLOR[c.result]}>{c.result}</Tag><b>{c.code} {c.name}</b>：{c.detail}</div>))}
    </Space>
  );
}

const Empty = () => <Alert type="info" showIcon message="这家公司还没有三层估值输入：先在「② 盈利能力」填调整后利润表（样板见腾讯音乐）。" />;

// 一条横线：三层价值的刻度与现价；主估值层最后画（压在上面）
function Ladder({ v }) {
  const { token } = theme.useToken();
  const pts = LAYERS.map(([k, label]) => [label, v[k]]).filter(([, x]) => isNum(x)).map(([l, x]) => [l, Number(x)])
    .sort((a, b) => (a[0] === v.value_layer) - (b[0] === v.value_layer));
  const top = Math.max(...pts.map(([, x]) => x), Number(v.market_price) || 0) * 1.1;
  if (!(top > 0)) return null;
  const x = (n) => `${Math.max(0, Math.min(100, (n / top) * 100))}%`;
  const color = { 资产价值: token.colorTextTertiary, 盈利能力价值: token.colorPrimary, 含增长价值: token.colorSuccess };
  return (
    <div style={{ position: 'relative', height: 56, margin: '8px 0 12px' }}>
      <div style={{ position: 'absolute', left: 0, right: 0, top: 12, height: 2, background: token.colorBorderSecondary }} />
      {pts.slice().sort((a, b) => a[1] - b[1]).map(([label, n], i) => (
        <div key={label} style={{ position: 'absolute', left: x(n), top: 6, marginLeft: -7, zIndex: label === v.value_layer ? 2 : 1 }}>
          <div style={{ width: 14, height: 14, borderRadius: 7, background: color[label],
                        border: v.value_layer === label ? `2px solid ${token.colorText}` : 'none' }} />
          <div style={{ fontSize: 11, whiteSpace: 'nowrap', marginTop: i % 2 ? 20 : 4, transform: 'translateX(-40%)' }}>{label} {fmt(n, 2)}</div>
        </div>))}
      {isNum(v.market_price) && <Tooltip title={`现价 ${fmt(v.market_price, 2)} 元`}>
        <div style={{ position: 'absolute', left: x(v.market_price), top: 0, height: 26, width: 2, marginLeft: -1, background: token.colorError }} /></Tooltip>}
    </div>
  );
}

const ITEM_COLS = [
  { title: '项目', key: 'name', width: 250, render: (_, r) => r.name || r.line_item },
  { title: '类别', dataIndex: 'category', key: 'cat', width: 90 },
  num('账面计入值', 'book_signed', 2), per('折价', 'haircut', 0), num('调整额', 'adjustment', 2),
  { ...num('计入值', 'value_signed', 2), render: (v) => <b>{fmt(v, 2)}</b> },
  { title: '依据', dataIndex: 'basis', key: 'basis', render: (v) => <Text type="secondary" style={{ fontSize: 12 }}>{v || ''}</Text> },
];

const irrCell = (v, r) => <Text type={isNum(v) && v >= r.hurdle ? 'success' : 'danger'}>{pct(v, 1)}</Text>;

function AssetPage({ d }) {
  const ops = d.items.filter((i) => i.role === '经营资本');
  const v = d.v;
  const hasBook = ops.length > 0 && ops.every((r) => isNum(r.book_signed));
  const revalued = ops.length > 0 && ops.every((r) => isNum(r.value_signed));
  const book = hasBook ? (v?.book_capital ?? sum(ops, 'book_signed')) : null;
  const adj = revalued ? (v?.adj_capital ?? sum(ops, 'value_signed')) : null;
  const basis = v?.av_basis ?? d.company.av_basis;
  return (
    <Space direction="vertical" style={{ width: '100%' }} size="large">
      <Intro title="第一层 · 全公司经营资产重估">
        以 {d.company.as_of || '估值截至日'} 的资产负债表为底稿，逐项重估全公司的经营资产与经营负债。
        重估金额＝账面×(1−折价)＋调整额。经营资产计正，经营负债计负。
      </Intro>
      {ops.length > 0 || v ? <Card size="small" title={`公司资产价值 · ${basis || '待设定'}`}>
        <Row gutter={[16, 16]}>
          <Col xs={12} md={6}><Statistic title="账面经营资本" value={fmt(book, 2)} suffix="亿元" /></Col>
          <Col xs={12} md={6}><Statistic title="调整后经营资本" value={fmt(adj, 2)} suffix="亿元" /></Col>
          {basis === '重建成本' && <Col xs={12} md={6}><Statistic title="重建成本" value={fmt(d.company.repro_cost, 2)} suffix="亿元" /></Col>}
          <Col xs={12} md={6}><Statistic title="归母比例" value={pct(v?.av_attrib, 1)} /></Col>
          <Col xs={12} md={6}><Statistic title="经营资产价值（归母）" value={fmt(v?.av_total, 2)} suffix="亿元" /></Col>
        </Row>
      </Card> : <Alert type="info" showIcon message="这家公司还没有资产价值输入。" />}
      {ops.length > 0 && <Card size="small" title={`经营资本明细（${ops.length} 项，亿元）`}>
        <Table rowKey="id" size="small" pagination={false} scroll={{ x: 'max-content' }} columns={ITEM_COLS} dataSource={ops} />
      </Card>}
      <Card size="small" title="检查"><Checks d={d} codes={['G01', 'G07']} /></Card>
    </Space>
  );
}

// 第二层：一块业务的调整后利润表（历年数＋正常化值，逐行算到盈利能力价值）
const SIGN = { 收入: '', 成本费用: '−', 所得税: '−', 少数股东: '−' };
function Statement({ d, u }) {
  const { token } = theme.useToken();
  const ls = d.lines.filter((l) => l.business_id === u.business_id);
  const labels = [...new Set(ls.flatMap((l) => l.hist.map((h) => h[0])))].sort((a, b) => (a.startsWith('近') - b.startsWith('近')) || a.localeCompare(b));
  const hv = (l) => Object.fromEntries(l.hist.map(([k, v]) => [k, Number(v)]));
  const sumH = (sec) => { const o = {}; labels.forEach((k) => { const xs = ls.filter((l) => l.section === sec).map((l) => hv(l)[k]); o[k] = xs.length && xs.every(isNum) ? xs.reduce((a, b) => a + b, 0) : null; }); return o; };
  const revH = sumH('收入'), costH = sumH('成本费用');
  const ebitH = Object.fromEntries(labels.map((k) => [k, isNum(revH[k]) && isNum(costH[k]) ? revH[k] - costH[k] : null]));
  const rows = [];
  const line = (l) => {
    const s = l.section === '税前调整' || l.section === '税后调整' ? (l.direction === '减' ? '−' : '＋') : SIGN[l.section];
    const how = l.method === '历史平均' || l.method === '历史平均占收入' ? `${l.method}（${l.from_year}—${l.to_year}）`
      : l.method === '占收入比例' || l.method === '比率' ? `${l.method} ${pct(l.value, 1)}` : (l.method || '');
    rows.push({ key: `l${l.id}`, label: <span>{s && <Text type="secondary">{s} </Text>}{l.name}</span>, h: hv(l), n: l.normalized,
                r: l.ratio, how, note: l.note, judg: (l.judgments || []).map((j) => j.code).join('、') });
  };
  const total = (label, n, h, r, strong = true) => rows.push({ key: label, label: <b>{label}</b>, h: h || {}, n, r, total: true, strong });
  const sec = (name) => ls.filter((l) => l.section === name).forEach(line);
  sec('收入');
  if (ls.filter((l) => l.section === '收入').length > 1) total('收入合计', u.revenue, revH, 1);
  sec('成本费用');
  total('＝ 报表经营利润', u.ebit_reported, ebitH, u.ebit_reported / u.revenue);
  rows.push({ key: 'm1', label: <Text type="secondary">　报表经营利润率</Text>, h: Object.fromEntries(labels.map((k) => [k, isNum(ebitH[k]) && revH[k] ? ebitH[k] / revH[k] : null])), pctRow: true });
  sec('税前调整');
  total('＝ 调整后经营利润', u.ebit, null, u.margin);
  sec('所得税');
  total('＝ 税后经营利润', u.nopat, null, u.nopat / u.revenue);
  sec('税后调整');
  sec('少数股东');
  total('＝ 可持续现金收益 E（归母）', u.earnings, null, u.earnings / u.revenue);
  rows.push({ key: 'h', label: <span><Text type="secondary">÷ </Text>门槛</span>, n: null, how: pct(d.hurdle, 1), plain: true });
  total('＝ 盈利能力价值（亿元）', u.epv, null, null);
  const cell = (row, v) => (row.pctRow ? pct(v, 1) : fmt(v, 1));
  const cols = [
    { title: '项目', dataIndex: 'label', key: 'label', fixed: 'left', width: 270 },
    ...labels.map((k) => ({ title: k, key: k, align: 'right', width: 86, render: (_, r) => <Text type="secondary">{r.h ? cell(r, r.h[k]) : ''}</Text> })),
    { title: <b>正常化</b>, key: 'n', align: 'right', width: 96, onCell: () => ({ style: { background: token.colorPrimaryBg } }),
      render: (_, r) => (r.pctRow || r.plain ? '' : r.strong ? <b>{fmt(r.n, 1)}</b> : fmt(r.n, 1)) },
    { title: '占收入', key: 'r', align: 'right', width: 76, render: (_, r) => (isNum(r.r) ? pct(r.r, 1) : '') },
    { title: '取值方式', dataIndex: 'how', key: 'how', width: 160 },
    { title: '依据', dataIndex: 'judg', key: 'j', width: 110 },
    { title: '说明', dataIndex: 'note', key: 'note', width: 320, render: (v) => <Text type="secondary" style={{ fontSize: 12 }}>{v || ''}</Text> },
  ];
  const memo = ls.filter((l) => l.section === '不计入');
  return (
    <Space direction="vertical" style={{ width: '100%' }}>
      <Table rowKey="key" size="small" pagination={false} scroll={{ x: 'max-content' }} columns={cols} dataSource={rows}
        rowClassName={(r) => (r.total ? 'gw-total' : '')}
        onRow={(r) => ({ style: r.total ? { background: token.colorFillQuaternary } : {} })} />
      {memo.length > 0 && <Card size="small" type="inner" title="不计入经营利润（对照）：这些收益与成本对应的资产或负债在「④ 独立资产」里单独计价">
        <Table rowKey="id" size="small" pagination={false} scroll={{ x: 'max-content' }} dataSource={memo}
          columns={[{ title: '项目', dataIndex: 'name', key: 'n', fixed: 'left', width: 270 },
                    ...labels.map((k) => ({ title: k, key: k, align: 'right', width: 86, render: (_, l) => <Text type="secondary">{fmt(hv(l)[k], 1)}</Text> })),
                    { title: '说明', dataIndex: 'note', key: 'note', render: (v) => <Text type="secondary" style={{ fontSize: 12 }}>{v || ''}</Text> }]} />
      </Card>}
    </Space>
  );
}

function EpvPage({ d }) {
  const v = d.v;
  return (
    <Space direction="vertical" style={{ width: '100%' }} size="large">
      <Intro title="第二层：盈利能力价值——现有业务不增长，可持续的盈利值多少">
        一张调整后的利润表：从报表数出发（灰色是历年实际数），每行按“取值方式”取正常化值（蓝底），一路算到可持续现金收益 E，再除以门槛 {pct(d.hurdle, 1)}。
        Greenwald 的调整：周期业务取多年平均利润率；为增长花的费用有依据才加回；折旧换成维持性资本开支；不含独立计价资产的收益（列在“不计入”）。
      </Intro>
      {d.units.length ? d.units.map((u) => (
        <Card key={u.id} size="small" title={`${u.business_name}：调整后利润表（亿元）`} extra={u.note ? <Text type="danger">{u.note}</Text> : null}>
          <Statement d={d} u={u} />
        </Card>)) : <Empty />}
      {v && <Card size="small" title="每股盈利能力价值">
        <Row gutter={[16, 16]}>
          <Col xs={12} md={6}><Statistic title="业务盈利能力价值" value={fmt(v.epv_total, 1)} suffix="亿元" /></Col>
          <Col xs={12} md={6}><Statistic title="＋资产负债桥（④）" value={fmt(v.bridge, 1)} suffix="亿元" /></Col>
          <Col xs={12} md={6}><Statistic title={`每股（今天，股本 ${fmt(v.shares, 2)} 亿股）`} value={fmt(v.epv_ps, 2)} suffix="元" /></Col>
          <Col xs={12} md={6}><Statistic title="隐含回报·不增长（现价买入）" value={pct(v.irr_epv, 1)} /></Col>
        </Row></Card>}
      <Card size="small" title="检查"><Checks d={d} codes={['G02', 'G05', 'G08']} /></Card>
    </Space>
  );
}

function GrowthPage({ d }) {
  const v = d.v;
  return (
    <Space direction="vertical" style={{ width: '100%' }} size="large">
      <Intro title="第三层：增长价值——增长能多创造多少价值，可正、可零、可负">
        从第二层的 E 出发：优势年限内每年增长 g，每年要把 g ÷ 新增投资回报率 的收益再投进去；之后增长不再创造价值。新增投资回报率高于门槛 {pct(d.hurdle, 1)} 才创造价值，
        等于门槛一分不值，低于门槛毁灭价值；高于门槛必须有壁垒支撑（G04：依据经“成立”的论点连到“真实壁垒”）。
      </Intro>
      {d.units.length ? <Card size="small" title="每块业务（亿元）">
        <Table rowKey="id" size="small" pagination={false} scroll={{ x: 'max-content' }} dataSource={d.units}
          columns={[{ title: '业务', dataIndex: 'business_name', key: 'n', width: 180 }, num('E', 'earnings', 1), per('增长率', 'g', 1), per('新增投资回报率', 'ronic', 0),
                    { title: '再投入比例', key: 'ri', align: 'right', render: (_, u) => (Number(u.g) && isNum(u.ronic) ? pct(u.g / u.ronic, 0) : '—') },
                    { title: '优势年限', dataIndex: 'adv_years', key: 'y', align: 'right', render: (x, u) => (isNum(x) ? `${x} 年` : Number(u.g) ? '永续' : '—') },
                    num('盈利能力价值', 'epv', 0), { ...num('含增长价值', 'full_value', 0), render: (x) => <b>{fmt(x, 0)}</b> },
                    { ...num('增长价值', 'growth_value', 0), render: (x) => <Text type={Number(x) < 0 ? 'danger' : undefined}>{fmt(x, 0)}</Text> },
                    { title: '增长价值占比', key: 'sh', align: 'right', render: (_, u) => (isNum(u.full_value) && Number(u.full_value) ? pct(u.growth_value / u.full_value, 0) : '—') }]} />
      </Card> : <Empty />}
      {v && <Card size="small" title="每股含增长价值">
        <Row gutter={[16, 16]}>
          <Col xs={12} md={6}><Statistic title="每股盈利能力价值" value={fmt(v.epv_ps, 2)} suffix="元" /></Col>
          <Col xs={12} md={6}><Statistic title="每股含增长价值" value={fmt(v.full_ps, 2)} suffix="元" /></Col>
          <Col xs={12} md={6}><Statistic title="每股增长价值" value={fmt(v.full_ps - v.epv_ps, 2)} suffix="元" /></Col>
          <Col xs={12} md={6}><Statistic title="隐含回报·含增长" value={pct(v.irr_full, 1)} /></Col>
        </Row></Card>}
      <Card size="small" title="检查"><Checks d={d} codes={['G03', 'G04']} /></Card>
    </Space>
  );
}

function BridgePage({ d }) {
  const bridge = d.items.filter((i) => i.role === '资产负债桥');
  const cats = ['现金与投资', '参照估值', '有息负债', '其他索取权'];
  return (
    <Space direction="vertical" style={{ width: '100%' }} size="large">
      <Intro title="独立资产与调整——经营价值之外的资产，以及排在股东前面的索取权">
        按科目类别列示多余现金与投资、参照估值、有息负债、少数股东与其他索取权。
        企业口径的业务，有息负债在这里扣；资产划出来时，对应的收益也要从经营利润里剔除（② 的“不计入”），同一价值只计一次。
      </Intro>
      <Row gutter={[16, 16]}>
        {cats.map((c) => <Col xs={12} md={4} key={c}><Statistic title={c} value={fmt(sum(bridge.filter((r) => r.category === c), 'value_signed'), 1)} suffix="亿元" /></Col>)}
        <Col xs={12} md={4}><Statistic title="资产负债桥合计" value={fmt(sum(bridge, 'value_signed'), 1)} suffix="亿元" /></Col>
        <Col xs={12} md={4}><Statistic title="每股（截至日）" value={d.v ? fmt(sum(bridge, 'value_signed') / d.v.shares, 2) : '—'} suffix="元" /></Col>
      </Row>
      <Card size="small" title={`明细（${bridge.length} 项）`}>
        <Table rowKey="id" size="small" pagination={false} scroll={{ x: 'max-content' }} columns={ITEM_COLS} dataSource={bridge} />
      </Card>
      <Card size="small" title="检查"><Checks d={d} codes={['G01', 'G05', 'G07']} /></Card>
    </Space>
  );
}

function EquityPage({ d }) {
  const v = d.v;
  if (!v) return <Empty />;
  const layer = v.value_layer;
  const build = [['资产价值', 'av_total', 'av_ps'], ['盈利能力价值', 'epv_total', 'epv_ps'], ['含增长价值', 'full_total', 'full_ps']].map(([label, k, ps]) => ({
    id: k, label, biz: v[k], bridge: v.bridge, equity: isNum(v[k]) ? Number(v[k]) + Number(v.bridge) : null, ps: v[ps],
    irr: { epv_total: v.irr_epv, full_total: v.irr_full }[k] }));
  return (
    <Space direction="vertical" style={{ width: '100%' }} size="large">
      <Row gutter={[16, 16]}>
        <Col xs={12} md={6}><Statistic title={`现价（${v.market_date || ''}，记账币种）`} value={fmt(v.market_price, 2)} suffix="元" /></Col>
        <Col xs={12} md={6}><Statistic title={`${layer || '未选主估值层'}（门槛 ${pct(v.hurdle, 1)}）`} value={fmt(v.value_ps, 2)} suffix="元" /></Col>
        <Col xs={12} md={6}><Statistic title="主估值层的隐含年化回报" value={pct(v.implied_irr, 1)} /></Col>
        <Col xs={12} md={6}><Statistic title="现价相对主估值层" value={isNum(v.value_ps) && Number(v.value_ps) ? pct(v.market_price / v.value_ps - 1, 1) : '—'} /></Col>
      </Row>
      <Paragraph style={{ marginBottom: 0 }}>{v.conclusion}</Paragraph>
      <Card size="small" title="三层价值与现价（元/股，今天）">
        <Ladder v={v} />
        <Text type="secondary">圆点：灰＝资产价值，蓝＝盈利能力价值，绿＝含增长价值（黑框＝主估值层）；红线＝现价。三层本身就是从保守到乐观的三种情形。</Text>
      </Card>
      <Card size="small" title={`从经营价值到每股（截至日 ${v.as_of}，股本 ${fmt(v.shares, 2)} 亿股）`}>
        <Table rowKey="id" size="small" pagination={false} dataSource={build}
          columns={[{ title: '口径', dataIndex: 'label', key: 'l', render: (x) => (x === layer ? <b>{x}（主估值层）</b> : x) },
                    num('经营价值（亿元）', 'biz', 1), num('＋资产负债桥（亿元）', 'bridge', 1), num('＝股权价值（亿元）', 'equity', 1),
                    { ...num('每股（元，今天）', 'ps', 2), render: (x) => <b>{fmt(x, 2)}</b> },
                    { title: '隐含回报（现价买入）', dataIndex: 'irr', key: 'irr', align: 'right', render: (x) => (isNum(x) ? irrCell(x, v) : '—') }]} />
        <Text type="secondary">每股价值从截至日按门槛滚到今天；门槛在「框架与后台 / 统一设置」里改，全部公司共用。主估值层依据：{d.company.layer_reason || '—'}</Text>
      </Card>
      <Card size="small" title="估值检查（G01—G09；数据与论点的检查见「研究维护 / 质量自检」）">
        <Checks d={d} codes={['G01', 'G02', 'G03', 'G04', 'G05', 'G06', 'G07', 'G08', 'G09']} /></Card>
    </Space>
  );
}

function Page() {
  const [d, setD] = useState(null);
  const [err, setErr] = useState(null);
  React.useEffect(() => { load().then(setD).catch((e) => setErr(String(e))); }, []);
  if (err) return <Alert type="error" message={err} />;
  if (!d) return <Text type="secondary">加载中…</Text>;
  const P = { av: AssetPage, epv: EpvPage, growth: GrowthPage, bridge: BridgePage, equity: EquityPage }[MODE];
  return <P d={d} />;
}

ctx.render(<Page />);
"""

# 公司表在两处编辑标签分别显示相关字段。
ASSET_SETTINGS = ['av_basis', 'repro_cost']
EQUITY_SETTINGS = ['code', 'name', 'as_of', 'shares', 'value_layer', 'layer_reason', 'latest_price', 'latest_price_date']
OPERATING_CATEGORIES = ['经营资产', '经营负债']


def register_collections():
    T = spec.all_tables()
    R = {r['code']: r for r in spec.REPORTS}
    for code in ('company', 'business', 'bs_item', 'epv', 'growth', 'judgment', 'setting', 'risk'):
        register.nb('collections', 'apply', body=register.collection_body(T[code]))
    for code in ('gw_unit', 'gw_value', 'check'):
        register.nb('collections', 'apply', body=register.collection_body(R[code], report=True))
    register.register_relations(['bs_item', 'epv', 'growth'])
    register.mark_relation_source(['bs_item', 'epv', 'growth'])
    for code in ('company', 'business', 'bs_item', 'epv', 'growth'):
        register.reorder_fields(code)
    print('已登记；请重启 app：docker compose restart app')


def scope(kind, co):
    own = {'path': 'company_id', 'operator': '$eq', 'value': co['id']}
    if kind in ('ops', 'bridge'):
        operator = '$in' if kind == 'ops' else '$notIn'
        return {'logic': '$and', 'items': [own, {'path': 'category', 'operator': operator, 'value': OPERATING_CATEGORIES}]}
    if kind in ('asset_settings', 'self'):
        return {'logic': '$and', 'items': [{'path': 'id', 'operator': '$eq', 'value': co['id']}]}
    return None


def page_script(co, mode):
    if co['code'] == '01698.HK' and mode == 'growth':
        case_page = (bp.ROOT / 'companies/01698_腾讯音乐/growth_page.jsx').read_text()
        basis_uid = bp.state()['pages'][bp.page_key('judgment', co)]['pageSchemaUid']
        return case_page.replace('__BASIS_UID__', basis_uid)
    script = JS.replace('__COMPANY__', co['code']).replace('__MODE__', mode)
    if co['code'] == '01698.HK' and mode == 'av':
        uid = bp.state()['pages'][bp.page_key('gw_bridge', co)]['pageSchemaUid']
        return (bp.ROOT / 'companies/01698_腾讯音乐/asset_page.jsx').read_text().replace('__BRIDGE_UID__', uid)
    return script


def page(co, key, title, icon, mode, tabs):
    st = bp.state()
    gid = bp.valuation_group(st, co)
    b = {'page': {'title': title, 'documentTitle': f"{co['name']} · {title}", 'enableTabs': True},
         'assets': {'scripts': {key: {'version': 'v1', 'code': page_script(co, mode)}}},
         'tabs': [{'title': '总览', 'blocks': [{'type': 'jsBlock', 'script': key}]}],
         'defaults': {'collections': {}}}
    company_columns = bp.COLUMNS['company']
    try:
        for table, label, kind in tabs:
            if table == 'company':
                bp.COLUMNS['company'] = ['name', *ASSET_SETTINGS] if kind == 'asset_settings' else EQUITY_SETTINGS
            body = al.aligned_blueprint(table, label, gid, co, scope=scope(kind, co))
            tab = body['tabs'][0]
            tab['title'] = label
            if kind == 'asset_settings':
                edit_action = next(a for a in tab['blocks'][0]['recordActions'] if isinstance(a, dict) and a['type'] == 'edit')
                form = edit_action['popup']['blocks'][0]
                form.pop('fieldGroups', None)
                form['fields'] = ASSET_SETTINGS
            b['tabs'].append(tab)
            b['defaults']['collections'].update(body['defaults']['collections'])
    finally:
        bp.COLUMNS['company'] = company_columns
    # 弹窗用新模板名（旧页面生成的模板没有新列）
    titles = {f"vi_{t['code']}": t['title'] for t in spec.TABLES}
    for coll, cfg in b['defaults']['collections'].items():
        n = titles.get(coll, coll)
        cfg['popups'] = {'view': {'name': f'{n}·详情（三层）', 'description': f'查看一条「{n}」记录'},
                         'addNew': {'name': f'{n}·新增（三层）', 'description': f'新增一条「{n}」记录'},
                         'edit': {'name': f'{n}·编辑（三层）', 'description': f'编辑一条「{n}」记录'}}
    pkey = bp.page_key(key, co)
    if pkey in bp.state()['pages']:
        al.apply(f'{key}_{co["code"]}', {'version': '1', 'mode': 'replace',
                                          'target': {'pageSchemaUid': bp.state()['pages'][pkey]['pageSchemaUid']}, **b})
    else:
        al.apply(f'{key}_{co["code"]}', {'version': '1', 'mode': 'create',
                                          'navigation': {'group': {'routeId': gid}, 'item': {'title': title, 'icon': icon}}, **b})
        overview.record(pkey, gid, title)
    bp.order_tabs(pkey, [t['title'] for t in b['tabs']])
    for _, label, kind in tabs:
        if kind == 'asset_settings':
            bp.strip_write_actions(pkey, tab_title=label, keep_edit=True)


if __name__ == '__main__':
    if '--register' in sys.argv:
        register_collections()
        sys.exit()
    codes = [a for a in sys.argv[1:] if not a.startswith('--')]
    for co in bp.companies():
        if not codes or co['code'] in codes:
            for key, title, icon, mode, tabs in PAGES:
                page(co, key, title, icon, mode, tabs)
    import scope_selects
    scope_selects.main()                          # 表单里的业务、依据下拉只列这家公司
    bp.sort_menu(codes or None)
