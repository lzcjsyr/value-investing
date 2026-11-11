"""统一估值引擎的集合登记与页面（2026-11-08）。

  python3 framework/build_value_engine.py --register      登记 估值假设、收入与成本项目、业务分部（新列）和 5 个报表集合；之后 docker compose restart app
  python3 framework/build_value_engine.py [公司代码 ...]   每家公司「预测与估值 / 估值（统一引擎）」：总览＋估值假设、收入与成本项目、业务、资产负债桥四个编辑标签

页面只读 vi_ve_value / vi_ve_business / vi_ve_year / vi_ve_check（02_calc.sql），不在页面里计算价值。
"""
import json
import sys

import align_companies as al
import build_overview as overview
import build_pages as bp
import register
import spec
from page_style import wrap_js

TITLE = '估值（统一引擎）'
KEY = 've'

VE_JS = r"""const COMPANY = '__COMPANY__';
const { React } = ctx.libs;
const { useState } = React;
const { Card, Segmented, Table, Alert, Typography, Space, Tag, Row, Col, Statistic, Tooltip } = ctx.libs.antd;
const { Text, Paragraph } = Typography;
const Summary = ctx.libs.antd.Table.Summary;     // 表格包装（page_style.TABLE）不带 Summary

async function listRows(name, filter, pageSize = 2000) {
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
const bySort = (k) => (a, b) => (a[k] ?? 0) - (b[k] ?? 0) || a.id - b.id;
const RESULT_COLOR = { 通过: 'green', 提示: 'gold', 阻断: 'red' };

async function load() {
  const [company] = await listRows('vi_company', { code: { $eq: COMPANY } });
  const [model] = await listRows('vi_model', { company_id: { $eq: company.id }, status: { $eq: '当前' } });
  const byModel = { model_id: { $eq: model.id } };
  const [values, businesses, years, checks, bizMeta, oldVal, oldSotp, lines, lineMeta] = await Promise.all([
    listRows('vi_ve_value', byModel), listRows('vi_ve_business', byModel), listRows('vi_ve_year', byModel),
    listRows('vi_ve_check', byModel), listRows('vi_business', { company_id: { $eq: company.id } }),
    listRows('vi_valuation', byModel), listRows('vi_sotp', byModel), listRows('vi_ve_line', byModel, 5000),
    listRows('vi_line'),
  ]);
  values.sort(bySort('sort'));
  const bizIds = new Set(bizMeta.map((x) => x.id));
  return { company, model, values, businesses, years, checks, bizMeta, oldVal, oldSotp, lines,
           lineMeta: lineMeta.filter((l) => bizIds.has(l.business_id)) };
}

// 三层价值条：资产价值 | 壁垒 | 增长，标出现价
function Layers({ v }) {
  const top = Math.max(v.value_ps || 0, v.market_price || 0, v.epv_ps || 0, v.av_ps || 0) * 1.08;
  if (!(top > 0)) return null;
  const x = (n) => `${Math.max(0, Math.min(100, (n / top) * 100))}%`;
  const seg = (from, to, color, label) => (to > from ? (
    <Tooltip title={`${label}：${fmt(from, 2)} → ${fmt(to, 2)} 元`}>
      <div style={{ position: 'absolute', left: x(from), width: `calc(${x(to)} - ${x(from)})`, top: 0, bottom: 0, background: color }} />
    </Tooltip>) : null);
  const av = Math.max(0, v.av_ps || 0), epv = v.epv_ps || 0, full = v.value_ps || 0;
  return (
    <div style={{ position: 'relative', height: 22, background: 'rgba(127,127,127,0.12)', borderRadius: 4, overflow: 'visible' }}>
      {seg(0, av, '#8c8c8c', '资产价值')}
      {seg(av, epv, '#1677ff', '壁垒价值（盈利能力价值−资产价值）')}
      {seg(Math.max(av, epv), full, '#52c41a', '增长价值（全价值−盈利能力价值）')}
      {isNum(v.market_price) && <Tooltip title={`现价 ${fmt(v.market_price, 2)} 元`}>
        <div style={{ position: 'absolute', left: x(v.market_price), top: -4, bottom: -4, width: 2, background: '#f5222d' }} /></Tooltip>}
    </div>
  );
}

function Overview({ d }) {
  const base = d.values.find((v) => v.is_base) || d.values[0];
  if (!base) return <Alert type="info" message="这家公司还没有估值假设（vi_assumption）。" />;
  const w = base.weighted_ps;
  const cols = [
    { title: '情景', dataIndex: 'scenario_name', key: 'name', fixed: 'left', width: 80 },
    { title: '概率', dataIndex: 'probability', key: 'prob', render: (v) => pct(v, 0) },
    { title: '每股资产价值', dataIndex: 'av_ps', key: 'av', render: (v) => fmt(v, 2) },
    { title: '每股盈利能力价值', dataIndex: 'epv_ps', key: 'epv', render: (v) => fmt(v, 2) },
    { title: '每股价值（最高买入价）', dataIndex: 'value_ps', key: 'vps', render: (v) => <b>{fmt(v, 2)}</b> },
    { title: '三层价值与现价', key: 'bar', width: 260, render: (_, v) => <Layers v={v} /> },
    { title: '隐含回报', dataIndex: 'implied_irr', key: 'irr', render: (v, r) => <Text type={isNum(v) && v >= r.hurdle ? 'success' : 'danger'}>{pct(v, 1)}</Text> },
    { title: '终值占比', dataIndex: 'terminal_share', key: 'g', render: (v) => pct(v, 0) },
    { title: '价格隐含倍率', dataIndex: 'implied_ratio', key: 'm', render: (v) => fmt(v, 2) },
  ];
  return (
    <Space direction="vertical" style={{ width: '100%' }} size="middle">
      <Row gutter={[16, 16]}>
        <Col xs={12} md={6}><Statistic title={`现价（${base.market_date || ''}，记账币种）`} value={fmt(base.market_price, 2)} suffix="元" /></Col>
        <Col xs={12} md={6}><Statistic title={`基准每股价值（门槛 ${pct(base.hurdle, 1)}）`} value={fmt(base.value_ps, 2)} suffix="元" /></Col>
        <Col xs={12} md={6}><Statistic title="基准隐含年化回报" value={pct(base.implied_irr, 1)} /></Col>
        <Col xs={12} md={6}><Statistic title="概率加权每股价值" value={isNum(w) ? fmt(w, 2) : '—'} suffix={isNum(w) ? '元' : ''} /></Col>
      </Row>
      <Paragraph style={{ marginBottom: 0 }}>{base.conclusion}</Paragraph>
      <Table rowKey="id" size="small" pagination={false} columns={cols} dataSource={d.values} />
      <Text type="secondary">灰＝资产价值（重置成本或账面投入资本＋资产负债桥），蓝＝壁垒价值，绿＝增长价值，红线＝现价。截至日 {base.as_of}，按门槛滚到今天。
        价格隐含倍率＝市价扣掉资产负债桥与直接估值后，相当于模型经营价值的几倍（大于 1＝市场比模型乐观）。</Text>
    </Space>
  );
}

function Businesses({ d, scen }) {
  const rows = d.businesses.filter((b) => b.scenario_name === scen).sort(bySort('business_sort'));
  const meta = Object.fromEntries(d.bizMeta.map((b) => [b.id, b]));
  const cols = [
    { title: '业务', dataIndex: 'business_name', key: 'name', fixed: 'left', width: 160 },
    { title: '口径', key: 'basis', render: (_, b) => meta[b.business_id]?.capital_basis || '企业' },
    { title: '期初投入资本', dataIndex: 'ic0', key: 'ic', render: (v) => fmt(v, 0) },
    { title: '资产价值', dataIndex: 'av', key: 'av', render: (v, b) => <Tooltip title={b.av_basis}>{fmt(v, 0)}</Tooltip> },
    { title: '盈利能力价值', dataIndex: 'epv', key: 'epv', render: (v) => fmt(v, 0) },
    { title: '全价值', dataIndex: 'value', key: 'vps', render: (v) => <b>{fmt(v, 0)}</b> },
    { title: '壁垒价值', dataIndex: 'franchise_value', key: 'f', render: (v) => fmt(v, 0) },
    { title: '增长价值', dataIndex: 'growth_value', key: 'growth', render: (v) => fmt(v, 0) },
    { title: 'ROIC·首年', dataIndex: 'roic_first', key: 'r1', render: (v) => pct(v, 1) },
    { title: 'ROIC·终值年', dataIndex: 'roic_terminal', key: 'rt', render: (v) => pct(v, 1) },
    { title: '终值新增回报', dataIndex: 'ronic_used', key: 'ro', render: (v, b) => b.av_basis === '直接估值' ? '—' : <Tooltip title={b.ronic_default ? '未填，取门槛（增长不创造价值）' : '已填'}>{pct(v, 0)}{b.ronic_default ? '*' : ''}</Tooltip> },
    { title: '永续增长', dataIndex: 'g', key: 'g', render: (v) => pct(v, 1) },
    { title: '终值占比', dataIndex: 'terminal_share', key: 'ts', render: (v) => pct(v, 0) },
    { title: '说明', dataIndex: 'note', key: 'note', render: (v) => v || '' },
  ];
  return <Table rowKey="id" size="small" pagination={false} columns={cols} dataSource={rows}
    summary={(rs) => (<Summary.Row>
      <Summary.Cell index={0}><b>合计（亿元）</b></Summary.Cell><Summary.Cell index={1} />
      {['ic0', 'av', 'epv', 'value', 'franchise_value', 'growth_value'].map((k, i) => (
        <Summary.Cell key={k} index={i + 2} align="right">{fmt(rs.reduce((s, r) => s + (Number(r[k]) || 0), 0), 0)}</Summary.Cell>))}
    </Summary.Row>)} />;
}

function Years({ d, scen, bizId }) {
  const ys = d.years.filter((y) => y.scenario_name === scen && y.business_id === bizId).sort(bySort('year'));
  const meta = d.bizMeta.find((b) => b.id === bizId) || {};
  const lm = Object.fromEntries(d.lineMeta.map((l) => [l.id, l]));
  const lrows = d.lines.filter((l) => l.scenario_name === scen && l.business_id === bizId);
  const lineIds = [...new Set(lrows.map((l) => l.line_id))].sort((a, b) => (lm[a]?.sort ?? 0) - (lm[b]?.sort ?? 0));
  const auto = (v) => (Math.abs(v) < 10 ? 4 : 1);
  const cell = (v, dd) => (dd === 'p' ? pct(v, 1) : fmt(v, dd === 'a' ? auto(v) : dd));
  const fromYear = (k, dd) => Object.fromEntries(ys.map((y) => [`y${y.year}`, cell(y[k], dd)]));
  const fromLine = (id, k, dd) => Object.fromEntries(ys.map((y) => {
    const r = lrows.find((l) => l.line_id === id && Number(l.year) === Number(y.year)) || {};
    return [`y${y.year}`, cell(r[k], dd)];
  }));
  const data = [];
  const lineBlock = (kind) => lineIds.filter((id) => lm[id]?.kind === kind).forEach((id) => {
    const l = lm[id] || {};
    data.push({ id: `l${id}`, label: <b>{l.name}（亿元）</b>, ...fromLine(id, 'value', 1) });
    [1, 2, 3].filter((i) => l[`driver${i}_label`]).forEach((i) =>
      data.push({ id: `l${id}d${i}`, label: `　${l[`driver${i}_label`]}（${l[`driver${i}_unit`] || ''}）`, ...fromLine(id, `d${i}`, 'a') }));
    if (l.basis === '收入比例') data.push({ id: `l${id}r`, label: '　占收入比例', ...fromLine(id, 'ratio', 'p') });
    if (l.basis === '单位成本') data.push({ id: `l${id}u`, label: '　单位成本', ...fromLine(id, 'unit_cost', 'a') });
  });
  if (lineIds.length) {
    lineBlock('收入');
  } else {
    [1, 2, 3].filter((i) => meta[`driver${i}_label`]).forEach((i) =>
      data.push({ id: `d${i}`, label: `${meta[`driver${i}_label`]}（${meta[`driver${i}_unit`] || ''}）`, ...fromYear(`d${i}`, 'a') }));
  }
  data.push({ id: 'revenue', label: <b>收入合计（亿元）</b>, ...fromYear('revenue', 1) });
  if (lineIds.some((id) => lm[id]?.kind === '成本')) lineBlock('成本');
  [['经营利润（亿元）', 'ebit', 1], ['经营利润率', 'margin', 'p'], ['税后经营利润（亿元）', 'nopat', 1],
   ['期初投入资本（亿元）', 'ic_open', 0], ['投入资本增加（亿元）', 'net_investment', 1], ['自由现金流·归母（亿元）', 'fcf', 1],
   ['ROIC', 'roic', 'p'], ['计入比例', 'w', 2]].forEach(([label, k, dd]) => data.push({ id: k, label, ...fromYear(k, dd) }));
  const cols = [{ title: '项目', dataIndex: 'label', key: 'name', fixed: 'left', width: 230 },
    ...ys.map((y) => ({ title: String(y.year), dataIndex: `y${y.year}`, key: `y${y.year}` }))];
  return <Table rowKey="id" size="small" pagination={false} columns={cols} dataSource={data} />;
}

function OldVsNew({ d }) {
  const rows = d.values.map((v) => {
    const o = d.oldVal.find((x) => x.scenario_name === v.scenario_name) || {};
    const s = d.oldSotp.find((x) => x.scenario_name === v.scenario_name) || {};
    return { id: v.id, name: v.scenario_name, oldDdm: o.value_today, oldIrr: o.implied_irr, oldRate: o.discount_rate,
             oldSotp: s.value_per_share, vps: v.value_ps, irr: v.implied_irr };
  });
  const cols = [
    { title: '情景', dataIndex: 'name', key: 'name' },
    { title: '旧·股息贴现每股（元）', dataIndex: 'oldDdm', key: 'cash', render: (v) => fmt(v, 2) },
    { title: '旧·折现率', dataIndex: 'oldRate', key: 'g', render: (v) => pct(v, 1) },
    { title: '旧·隐含回报', dataIndex: 'oldIrr', key: 'cashIrr', render: (v) => pct(v, 1) },
    { title: '旧·分部加总每股（元）', dataIndex: 'oldSotp', key: 'inv', render: (v) => fmt(v, 2) },
    { title: '新·每股价值（门槛）', dataIndex: 'vps', key: 'vps', render: (v) => fmt(v, 2) },
    { title: '新·隐含回报', dataIndex: 'irr', key: 'irr', render: (v) => pct(v, 1) },
  ];
  return <Table rowKey="id" size="small" pagination={false} columns={cols} dataSource={rows} />;
}

function Checks({ d }) {
  return (
    <Space direction="vertical" style={{ width: '100%' }}>
      {d.checks.sort((a, b) => a.id - b.id).map((c) => (
        <div key={c.id}><Tag color={RESULT_COLOR[c.result]}>{c.result}</Tag><b>{c.code} {c.name}</b>：{c.detail}</div>))}
    </Space>
  );
}

function Page() {
  const [d, setD] = useState(null);
  const [err, setErr] = useState(null);
  const [scen, setScen] = useState(null);
  const [biz, setBiz] = useState(null);
  React.useEffect(() => { load().then(setD).catch((e) => setErr(String(e))); }, []);
  if (err) return <Alert type="error" message={err} />;
  if (!d) return <Text type="secondary">加载中…</Text>;
  const scens = d.values.map((v) => v.scenario_name);
  const sc = scen || (d.values.find((v) => v.is_base) || d.values[0] || {}).scenario_name;
  const bizList = [...new Map(d.businesses.filter((b) => b.av_basis !== '直接估值').sort(bySort('business_sort'))
    .map((b) => [b.business_id, b.business_name])).entries()];
  const bz = biz || bizList[0]?.[0];
  return (
    <Space direction="vertical" style={{ width: '100%' }} size="large">
      <Card size="small" title="估值结果（价值＝业务价值＋资产负债桥；只用一个门槛利率）"><Overview d={d} /></Card>
      <Card size="small" title="业务价值（亿元）" extra={<Segmented size="small" options={scens} value={sc} onChange={setScen} />}>
        <Businesses d={d} scen={sc} /></Card>
      <Card size="small" title="逐年计算" extra={<Space wrap>
        <Segmented size="small" options={bizList.map(([id, n]) => ({ label: n.length > 10 ? n.slice(0, 10) + '…' : n, value: id }))} value={bz} onChange={setBiz} />
        <Segmented size="small" options={scens} value={sc} onChange={setScen} /></Space>}>
        <Years d={d} scen={sc} bizId={bz} /></Card>
      <Card size="small" title="自动检查"><Checks d={d} /></Card>
      <Card size="small" title="与旧模型对照（过渡期）"><OldVsNew d={d} />
        <Text type="secondary">旧模型按各情景折现率（无风险利率＋风险溢价）算价值；新引擎只用门槛，所以每股价值不可直接比，隐含回报可以比。</Text></Card>
    </Space>
  );
}

ctx.render(<Page />);
"""


def register_collections():
    T = spec.all_tables()
    for code in ('business', 'line', 'assumption'):
        register.nb('collections', 'apply', body=register.collection_body(T[code]))
    for r in spec.REPORTS:
        if r['code'].startswith('ve_'):
            register.nb('collections', 'apply', body=register.collection_body(r, report=True))
    register.register_relations(['line', 'assumption'])
    register.mark_relation_source(['line', 'assumption'])
    register.reorder_fields('business')
    register.reorder_fields('assumption')
    register.reorder_fields('line')
    print('已登记：业务分部（新列）、估值假设、vi_ve_* 报表；请重启 app：docker compose restart app')


def page(co):
    st = bp.state()
    gid = bp.ensure_group(st, f'{co["name"]}/预测与估值', '预测与估值', 'CalculatorOutlined', parent=bp.company_root(st, co))
    b = {'page': {'title': TITLE, 'documentTitle': f"{co['name']} · {TITLE}", 'enableTabs': True},
         'assets': {'scripts': {KEY: {'version': 'v2', 'code': wrap_js(VE_JS.replace('__COMPANY__', co['code']))}}},
         'tabs': [{'title': '总览', 'blocks': [{'type': 'jsBlock', 'script': KEY}]}],
         'defaults': {'collections': {}}}
    # replace 按位置对应已有标签：标签顺序要和线上页面一致（加新标签时先加在最后、跑一次，再改回这里的顺序）
    for table, label in (('assumption', '估值假设（编辑）'), ('line', '收入与成本项目（编辑）'), ('business', '业务（编辑）'),
                         ('sotp_item', '资产负债桥（编辑）')):
        tab, defaults = al.native_tab(table, label, gid, co)
        tab['title'] = label
        b['tabs'].append(tab)
        b['defaults']['collections'].update(defaults)
    pkey = bp.page_key(KEY, co)
    if pkey in bp.state()['pages']:
        al.apply(f'{KEY}_{co["code"]}', {'version': '1', 'mode': 'replace',
                                          'target': {'pageSchemaUid': bp.state()['pages'][pkey]['pageSchemaUid']}, **b})
    else:
        al.apply(f'{KEY}_{co["code"]}', {'version': '1', 'mode': 'create',
                                          'navigation': {'group': {'routeId': gid}, 'item': {'title': TITLE, 'icon': 'NodeIndexOutlined'}}, **b})
        overview.record(pkey, gid, TITLE)
    bp.order_tabs(pkey, [t['title'] for t in b['tabs']])


if __name__ == '__main__':
    if '--register' in sys.argv:
        register_collections()
        sys.exit()
    codes = [a for a in sys.argv[1:] if not a.startswith('--')]
    for co in bp.companies():
        if not codes or co['code'] in codes:
            page(co)
    import scope_selects
    scope_selects.main()                          # 估值假设表单里的业务、情景、依据下拉只列这家公司
    bp.sort_menu()
