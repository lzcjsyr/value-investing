"""「<公司> / 数据底稿 / 财务报表」定制页：季度完整三大报表的矩阵视图（只读）。

上：关键数据（收入、毛利率、归母净利、经营与自由现金流、净现金、ROE、股东回报）和三张年度趋势图，取各公司的“模型字段”指标
（vi_metric / vi_metric_value，已按各自报表科目映射成统一口径），五家通用；下：报表明细，长表透视成报表的样子，
默认年度、关键科目，可切季度（累计/单季）与全部科目，带同比与趋势列。数据来自 fin_stmt（framework/tools/fin_stmt.py 灌入），
金额为亿元（报表原值÷1e8）；脚本只读，不存任何数字。

  python3 build_finstmt.py             # 给五家公司建缺的页面
  python3 build_finstmt.py --update    # 只更新已建页面的脚本（改了下面的 JS 或表的定位之后用，地址不变）
  python3 build_finstmt.py --rebuild   # 删除后重建
  ../tools/finstmt_check.sh 600900.SH  # 不开浏览器用真实数据验证脚本（Node 模拟 RunJS）
"""
import json, sys
import spec
from build_pages import state, companies, destroy_page, ensure_group, company_root, sort_menu, blocks, page_tree, nb_json
from build_overview import apply_page, record

TITLE = '财务报表'
ICON = 'TableOutlined'
KEY = 'finstmt'

JS = r"""
  const React = ctx.libs.React;
  const { Table, Segmented, Select, Space, Typography, Card, Row, Col, Empty, theme } = ctx.libs.antd;
  const { Text } = Typography;
  const COMPANY = '__COMPANY__';
  const ROLE = __ROLE__;          // 表的一句话定位（spec.role_line）
  const STMTS = ['资产负债表', '利润表', '现金流量表'];
  // 合计、小计与关键利润、现金行：加粗加底色，“关键科目”只列这些
  const BOLD = /(合计|总计|小计|毛利|净利润|净资产|净增加额|现金净额|溢利|利润总额|营业利润|营业总收入|营业总成本|营业收入|营业额|总资产|总负债|总权益|经营业务现金净额|经营活动产生的现金流量净额|投资活动产生的现金流量净额|筹资活动产生的现金流量净额|期初现金|期末现金|货币资金|现金及现金等价物)$/;
  const get = async (url, params) => (await ctx.request({ url, params }))?.data?.data;
  const listOf = async (name, params = {}) => (await get(`${name}:list`, { pageSize: 2000, ...params })) || [];
  const fetchAll = async (name, filter, sort) => {
    const rows = [];
    for (let page = 1; ; page += 1) {
      const batch = await listOf(name, { filter: JSON.stringify(filter), sort, page, pageSize: 2000 });
      rows.push(...batch);
      if (batch.length < 2000) break;
    }
    return rows;
  };
  const cos = await listOf('vi_company', { filter: JSON.stringify({ code: { $eq: COMPANY } }) });
  if (!cos.length) {
    ctx.render(<Text type="danger">未找到公司 {COMPANY}</Text>);
    return;
  }
  const co = cos[0];
  const UNIT = `${co.currency && co.currency !== '人民币' ? co.currency : ''}亿元`;

  // ---------- 关键数据：用各公司“模型字段”指标（已按各自报表科目映射成统一口径），五家通用 ----------
  const FIELDS = ['revenue', 'cost_of_sales', 'np_parent', 'cfo', 'capex', 'cash', 'interest_debt', 'equity_parent', 'dividend_total'];
  const STOCK = new Set(['cash', 'interest_debt', 'equity_parent']);
  const metrics = await listOf('vi_metric', { filter: JSON.stringify({ company_id: { $eq: co.id }, model_field: { $in: FIELDS } }) });
  const fieldOf = Object.fromEntries(metrics.map((m) => [m.id, m.model_field]));
  const values = metrics.length ? await fetchAll('vi_metric_value',
    { metric_id: { $in: metrics.map((m) => m.id) }, basis: { $in: ['全年', '时点', '滚动四季度'] } }, 'obs_date') : [];
  const annual = {}, ttm = {};     // annual[field][year]＝年度值（期末余额取四季度）；ttm[field][period]＝最近四个季度或期末
  for (const f of FIELDS) { annual[f] = {}; ttm[f] = {}; }
  for (const v of values) {
    const f = fieldOf[v.metric_id];
    if (!f || v.value === null || v.value === undefined) continue;
    if (STOCK.has(f)) {
      if (v.basis !== '时点') continue;
      ttm[f][v.period] = v.value;
      const m = String(v.period).match(/^(\d{4})Q4$/);
      if (m) annual[f][m[1]] = v.value;
    } else if (v.basis === '全年' && /^\d{4}$/.test(v.period)) annual[f][v.period] = v.value;
    else if (v.basis === '滚动四季度') ttm[f][v.period] = v.value;
  }
  const yearsAll = [...new Set(FIELDS.flatMap((f) => Object.keys(annual[f])))].sort();
  const years = yearsAll.filter((y) => annual.revenue[y] !== undefined).slice(-10);
  const lastKey = (obj) => Object.keys(obj).sort().pop();
  const prevYearPeriod = (p) => (/^\d{4}Q\d$/.test(p) ? `${Number(p.slice(0, 4)) - 1}${p.slice(4)}` : String(Number(p) - 1));
  const div = (a, b) => (a === undefined || b === undefined || a === null || b === null || b === 0 ? undefined : a / b);
  const minus = (a, b) => (a === undefined || b === undefined ? undefined : a - b);

  // 卡片取“最近四个季度”（有报表季度数据时），否则取最近完整年度；同比与同一口径的上年同期比
  const pick = (f) => {
    const t = lastKey(ttm[f]), y = lastKey(annual[f]);
    if (t && (!y || t > `${y}Q4` || STOCK.has(f))) {
      const p = prevYearPeriod(t);
      return { v: ttm[f][t], prev: ttm[f][p], label: STOCK.has(f) ? `${t} 末` : `截至 ${t} 的四个季度`, cmp: STOCK.has(f) ? `${p} 末` : `上年同期（截至 ${p}）`, src: ttm[f], key: t };
    }
    if (y) return { v: annual[f][y], prev: annual[f][String(Number(y) - 1)], label: `${y} 年`, cmp: `${Number(y) - 1} 年`, src: annual[f], key: y };
    return null;
  };
  const rev = pick('revenue');
  const at = (f, key, isTtm) => (isTtm ? ttm[f][key] : annual[f][key]);
  const revTtm = rev && rev.src === ttm.revenue;
  const prevKey = rev ? (revTtm ? prevYearPeriod(rev.key) : String(Number(rev.key) - 1)) : null;
  const gm = (k) => { const r = at('revenue', k, revTtm), c = at('cost_of_sales', k, revTtm); return r && c !== undefined ? 1 - c / r : undefined; };
  const npNow = rev && at('np_parent', rev.key, revTtm), npPrev = rev && at('np_parent', prevKey, revTtm);
  const cfoNow = rev && at('cfo', rev.key, revTtm), cfoPrev = rev && at('cfo', prevKey, revTtm);
  let fcfNow = rev && minus(at('cfo', rev.key, revTtm), at('capex', rev.key, revTtm));
  let fcfPrev = rev && minus(at('cfo', prevKey, revTtm), at('capex', prevKey, revTtm));
  let fcfLabel = rev?.label, fcfCmp = rev ? (revTtm ? `较上年同期（截至 ${prevKey}）` : `较 ${prevKey} 年`) : '';
  if (fcfNow === undefined) {      // 资本开支没有同口径的季度数时，退回最近完整年度
    const fy = [...yearsAll].reverse().find((yy) => annual.cfo[yy] !== undefined && annual.capex[yy] !== undefined);
    if (fy) {
      fcfNow = minus(annual.cfo[fy], annual.capex[fy]);
      fcfPrev = minus(annual.cfo[String(Number(fy) - 1)], annual.capex[String(Number(fy) - 1)]);
      fcfLabel = `${fy} 年`;
      fcfCmp = `较 ${Number(fy) - 1} 年`;
    }
  }
  const cashK = lastKey(ttm.cash), debtK = lastKey(ttm.interest_debt);
  const bsKey = cashK && debtK ? [cashK, debtK].sort()[0] : (cashK || debtK);
  const netCash = bsKey ? minus(ttm.cash[bsKey], ttm.interest_debt[bsKey]) : undefined;
  const lastY = [...years].reverse().find((y) => annual.np_parent[y] !== undefined && annual.equity_parent[y] !== undefined && annual.equity_parent[String(Number(y) - 1)] !== undefined);
  const roe = lastY ? annual.np_parent[lastY] / ((annual.equity_parent[lastY] + annual.equity_parent[String(Number(lastY) - 1)]) / 2) : undefined;
  const divY = [...years].reverse().find((y) => annual.dividend_total[y] !== undefined);

  const num = (v, d = 1) => (v === undefined || v === null || Number.isNaN(v) ? '—' : v.toLocaleString('zh-CN', { minimumFractionDigits: d, maximumFractionDigits: d }));
  const pct = (v, d = 1) => (v === undefined ? '—' : `${num(v * 100, d)}%`);
  const growth = (a, b) => (a === undefined || b === undefined || !b || b < 0 ? undefined : a / b - 1);

  const Kpi = ({ title, value, suffix, note, change, changeLabel, token }) => (
    <Card size="small" styles={{ body: { padding: '12px 14px' } }} style={{ height: '100%' }}>
      <div style={{ fontSize: 13, color: token.colorTextSecondary }}>{title}</div>
      <div style={{ fontSize: 24, fontWeight: 600, lineHeight: 1.4 }}>{value}<span style={{ fontSize: 13, fontWeight: 400, marginLeft: 4 }}>{suffix}</span></div>
      {change !== undefined ? (
        <div style={{ fontSize: 12, color: change >= 0 ? '#389e0d' : '#cf1322' }}>{change >= 0 ? '▲' : '▼'} {changeLabel}</div>
      ) : <div style={{ fontSize: 12 }}>&nbsp;</div>}
      <div style={{ fontSize: 12, color: token.colorTextTertiary, marginTop: 2 }}>{note}</div>
    </Card>
  );

  // 通用组合图：柱＝金额（左轴），线＝比率（右轴，%）；悬停看数值
  // 通用组合图：柱＝金额（左轴），线＝比率（右轴，%）。鼠标移到某一年（整列都可以），高亮这一列并浮出当年各项数值
  const Combo = ({ title, cats, bars = [], lines = [], token, note }) => {
    const [hover, setHover] = React.useState(null);
    const W = 560, H = 240, L = 52, R = 46, T = 16, B = 30;
    const vals = bars.flatMap((b) => cats.map((c) => b.values[c])).filter((v) => v !== undefined && v !== null);
    if (!cats.length || !vals.length) return <Card size="small" title={title}><Empty image={Empty.PRESENTED_IMAGE_SIMPLE} description="数据不足" /></Card>;
    let lo = Math.min(0, ...vals), hi = Math.max(0, ...vals);
    if (hi === lo) hi = lo + 1;
    const pv = lines.flatMap((l) => cats.map((c) => l.values[c])).filter((v) => v !== undefined && v !== null);
    let plo = pv.length ? Math.min(0, ...pv) : 0, phi = pv.length ? Math.max(...pv) : 1;
    if (phi === plo) phi = plo + 0.1;
    const gw = (W - L - R) / cats.length, bw = Math.min(26, (gw * 0.75) / Math.max(1, bars.length));
    const y = (v) => T + ((hi - v) * (H - T - B)) / (hi - lo);
    const py = (v) => T + ((phi - v) * (H - T - B)) / (phi - plo);
    const cx = (i) => L + gw * i + gw / 2;
    const ticks = [0, 1, 2, 3].map((k) => lo + ((hi - lo) * k) / 3);
    const has = (v) => v !== undefined && v !== null;
    const dim = (i) => (hover === null || hover === i ? 1 : 0.4);
    const c = hover === null ? null : cats[hover];
    const left = hover === null ? 0 : (cx(hover) / W) * 100;
    return (
      <Card size="small" title={title} extra={<span style={{ fontSize: 12, color: token.colorTextTertiary }}>{note}</span>}>
        <div style={{ position: 'relative' }} onMouseLeave={() => setHover(null)}>
          <svg viewBox={`0 0 ${W} ${H}`} style={{ width: '100%', height: 'auto', display: 'block' }}>
            {hover !== null ? <rect x={L + gw * hover} y={T} width={gw} height={H - T - B} fill={token.colorFillSecondary} /> : null}
            {ticks.map((t, k) => (
              <g key={k}>
                <line x1={L} x2={W - R} y1={y(t)} y2={y(t)} stroke={token.colorSplit} />
                <text x={L - 6} y={y(t) + 4} fontSize="12" textAnchor="end" fill={token.colorTextTertiary}>{num(t, Math.abs(hi) >= 100 ? 0 : 1)}</text>
              </g>
            ))}
            <line x1={L} x2={W - R} y1={y(0)} y2={y(0)} stroke={token.colorTextQuaternary} />
            {cats.map((cat, i) => (
              <g key={cat} opacity={dim(i)}>
                {bars.map((b, j) => {
                  const v = b.values[cat];
                  if (!has(v)) return null;
                  const x = cx(i) - (bars.length * bw) / 2 + j * bw;
                  return <rect key={b.name} x={x} y={Math.min(y(v), y(0))} width={bw - 2} height={Math.max(1, Math.abs(y(v) - y(0)))} fill={b.color} rx="2" />;
                })}
                <text x={cx(i)} y={H - 10} fontSize="12" textAnchor="middle" fill={hover === i ? token.colorText : token.colorTextTertiary}
                  fontWeight={hover === i ? 600 : 400}>{cat}</text>
              </g>
            ))}
            {lines.map((l) => {
              const pts = cats.map((cat, i) => [i, l.values[cat]]).filter(([, v]) => has(v));
              return (
                <g key={l.name}>
                  <path d={pts.map(([i, v], k) => `${k ? 'L' : 'M'}${cx(i).toFixed(1)},${py(v).toFixed(1)}`).join(' ')} fill="none" stroke={l.color} strokeWidth="2" />
                  {pts.map(([i, v]) => <circle key={i} cx={cx(i)} cy={py(v)} r={hover === i ? 5 : 3} fill={hover === i ? l.color : '#fff'} stroke={l.color} strokeWidth="1.5" />)}
                </g>
              );
            })}
            {lines.length ? [0, 1, 2].map((k) => {
              const t = plo + ((phi - plo) * k) / 2;
              return <text key={k} x={W - R + 6} y={py(t) + 4} fontSize="12" fill={token.colorTextTertiary}>{pct(t, 0)}</text>;
            }) : null}
            {cats.map((cat, i) => (
              <rect key={`hit-${cat}`} x={L + gw * i} y={0} width={gw} height={H} fill="transparent" style={{ cursor: 'crosshair' }}
                onMouseEnter={() => setHover(i)} onClick={() => setHover(i)} />
            ))}
          </svg>
          {c !== null ? (
            <div style={{
              position: 'absolute', top: 6, left: `${left}%`, transform: left > 55 ? 'translateX(calc(-100% - 14px))' : 'translateX(14px)',
              background: token.colorBgElevated, boxShadow: token.boxShadowSecondary, borderRadius: 6, padding: '8px 12px',
              fontSize: 12, lineHeight: 1.8, pointerEvents: 'none', whiteSpace: 'nowrap', zIndex: 2,
            }}>
              <div style={{ fontWeight: 600 }}>{c} 年</div>
              {bars.map((b) => (
                <div key={b.name} style={{ display: 'flex', justifyContent: 'space-between', gap: 16 }}>
                  <span><span style={{ display: 'inline-block', width: 9, height: 9, background: b.color, borderRadius: 2, marginRight: 6 }} />{b.name}</span>
                  <b>{has(b.values[c]) ? `${num(b.values[c])} ${UNIT}` : '—'}</b>
                </div>
              ))}
              {lines.map((l) => (
                <div key={l.name} style={{ display: 'flex', justifyContent: 'space-between', gap: 16 }}>
                  <span><span style={{ display: 'inline-block', width: 9, height: 9, background: l.color, borderRadius: 5, marginRight: 6 }} />{l.name}</span>
                  <b>{has(l.values[c]) ? pct(l.values[c]) : '—'}</b>
                </div>
              ))}
            </div>
          ) : null}
        </div>
        <Space size={14} wrap style={{ fontSize: 12 }}>
          {bars.map((b) => <span key={b.name}><span style={{ display: 'inline-block', width: 10, height: 10, background: b.color, borderRadius: 2, marginRight: 4 }} />{b.name}</span>)}
          {lines.map((l) => <span key={l.name}><span style={{ display: 'inline-block', width: 14, height: 2, background: l.color, verticalAlign: 'middle', marginRight: 4 }} />{l.name}（右轴）</span>)}
          <span style={{ color: token.colorTextTertiary }}>鼠标移到某一年看当年数值</span>
        </Space>
      </Card>
    );
  };

  const Overview = () => {
    const { token } = theme.useToken();
    const series = (f) => Object.fromEntries(years.map((y) => [y, annual[f][y]]));
    const ratio = (a, b, f = (x) => x) => Object.fromEntries(years.map((y) => [y, f(div(annual[a][y], annual[b][y]))]));
    const fcf = Object.fromEntries(years.map((y) => [y, minus(annual.cfo[y], annual.capex[y])]));
    const gpS = Object.fromEntries(years.map((y) => [y, minus(annual.revenue[y], annual.cost_of_sales[y])]));
    const net = Object.fromEntries(years.map((y) => [y, minus(annual.cash[y], annual.interest_debt[y])]));
    const gmS = Object.fromEntries(years.map((y) => [y, annual.cost_of_sales[y] !== undefined && annual.revenue[y] ? 1 - annual.cost_of_sales[y] / annual.revenue[y] : undefined]));
    const roeS = Object.fromEntries(years.map((y) => {
      const e0 = annual.equity_parent[String(Number(y) - 1)], e1 = annual.equity_parent[y];
      return [y, e0 !== undefined && e1 !== undefined ? div(annual.np_parent[y], (e0 + e1) / 2) : undefined];
    }));
    const span = years.length ? `${years[0]}—${years[years.length - 1]} 年` : '';
    const cmpTxt = rev ? (revTtm ? `较上年同期（截至 ${prevKey}）` : `较 ${prevKey} 年`) : '';
    const gNow = rev && gm(rev.key), gPrev = rev && gm(prevKey);
    return (
      <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
        <Row gutter={[12, 12]}>
          <Col xs={12} md={6}><Kpi token={token} title="营业收入" value={num(rev?.v)} suffix={UNIT} note={rev?.label}
            change={growth(rev?.v, rev?.prev)} changeLabel={`${pct(growth(rev?.v, rev?.prev))} ${cmpTxt}`} /></Col>
          <Col xs={12} md={6}><Kpi token={token} title="毛利率" value={pct(gNow)} note={rev?.label}
            change={minus(gNow, gPrev)} changeLabel={`${num(minus(gNow, gPrev) * 100)} 个百分点 ${cmpTxt}`} /></Col>
          <Col xs={12} md={6}><Kpi token={token} title="归母净利润" value={num(npNow)} suffix={UNIT} note={`${rev?.label || ''}；净利率 ${pct(div(npNow, rev?.v))}`}
            change={growth(npNow, npPrev)} changeLabel={`${pct(growth(npNow, npPrev))} ${cmpTxt}`} /></Col>
          <Col xs={12} md={6}><Kpi token={token} title="经营现金流" value={num(cfoNow)} suffix={UNIT} note={`${rev?.label || ''}；÷归母净利 ${num(div(cfoNow, npNow), 2)} 倍`}
            change={growth(cfoNow, cfoPrev)} changeLabel={`${pct(growth(cfoNow, cfoPrev))} ${cmpTxt}`} /></Col>
          <Col xs={12} md={6}><Kpi token={token} title="自由现金流" value={num(fcfNow)} suffix={UNIT} note={`经营现金流 − 资本开支；${fcfLabel || ''}`}
            change={growth(fcfNow, fcfPrev)} changeLabel={`${pct(growth(fcfNow, fcfPrev))} ${fcfCmp}`} /></Col>
          <Col xs={12} md={6}><Kpi token={token} title={netCash !== undefined && netCash < 0 ? '净负债' : '净现金'} value={num(netCash === undefined ? undefined : Math.abs(netCash))} suffix={UNIT}
            note={bsKey ? `${bsKey} 末：现金 ${num(ttm.cash[bsKey])}、带息负债 ${num(ttm.interest_debt[bsKey])}` : '缺期末余额'} /></Col>
          <Col xs={12} md={6}><Kpi token={token} title="ROE（归母）" value={pct(roe)} note={lastY ? `${lastY} 年归母净利 ÷ 年初年末平均归母净资产` : '数据不足'} /></Col>
          <Col xs={12} md={6}><Kpi token={token} title="股东现金回报" value={num(divY ? annual.dividend_total[divY] : undefined)} suffix={UNIT}
            note={divY ? `${divY} 年；占归母净利 ${pct(div(annual.dividend_total[divY], annual.np_parent[divY]))}` : '未录入'} /></Col>
        </Row>
        <Row gutter={[12, 12]}>
          <Col xs={24} lg={12}><Combo token={token} title="收入与利润" note={`${span}，${UNIT}`} cats={years}
            bars={[{ name: '营业收入', color: '#5470c6', values: series('revenue') }, { name: '毛利润', color: '#73c0de', values: gpS }, { name: '归母净利润', color: '#91cc75', values: series('np_parent') }]}
            lines={[{ name: '毛利率', color: '#ee6666', values: gmS }, { name: '净利率', color: '#fac858', values: ratio('np_parent', 'revenue') }]} /></Col>
          <Col xs={24} lg={12}><Combo token={token} title="现金流" note={`${span}，${UNIT}`} cats={years}
            bars={[{ name: '经营现金流', color: '#5470c6', values: series('cfo') }, { name: '资本开支', color: '#fac858', values: series('capex') }, { name: '自由现金流', color: '#3ba272', values: fcf }]} /></Col>
          <Col xs={24} lg={12}><Combo token={token} title="现金与负债（年末）" note={`${span}，${UNIT}`} cats={years}
            bars={[{ name: '现金', color: '#3ba272', values: series('cash') }, { name: '带息负债', color: '#ee6666', values: series('interest_debt') }, { name: '净现金', color: '#73c0de', values: net }]} /></Col>
          <Col xs={24} lg={12}><Combo token={token} title="盈利回报与分红" note={`${span}，${UNIT}`} cats={years}
            bars={[{ name: '归母净利润', color: '#91cc75', values: series('np_parent') }, { name: '股东现金回报', color: '#9a60b4', values: series('dividend_total') }]}
            lines={[{ name: 'ROE', color: '#ee6666', values: roeS }, { name: '派息率', color: '#5470c6', values: ratio('dividend_total', 'np_parent') }]} /></Col>
        </Row>
      </div>
    );
  };

  // ---------- 报表明细：年度（四季度＝全年或年末）／季度（累计或单季），关键科目／全部科目 ----------
  const [bsRows, isRows, cfRows] = await Promise.all(STMTS.map((s) => fetchAll('vi_fin_stmt', { company_id: { $eq: co.id }, stmt: { $eq: s } }, 'period_end')));
  const ROWS = { '资产负债表': bsRows, '利润表': isRows, '现金流量表': cfRows };
  const round6 = (v) => Math.round(v * 1e6) / 1e6;
  const fmt = (v) => {
    if (v === null || v === undefined) return '';
    return v.toLocaleString('zh-CN', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
  };
  const matrix = (rows, single) => {
    const perDate = {}, seqOf = {}, cum = {};
    for (const r of rows) {
      perDate[r.period] = r.period_end;
      if (!(r.item in seqOf) || r.seq < seqOf[r.item]) seqOf[r.item] = r.seq;
      cum[`${r.item}|${r.period}`] = r.amount;
    }
    const periods = Object.keys(perDate).sort((a, b) => (perDate[a] < perDate[b] ? 1 : -1));
    const items = Object.keys(seqOf).sort((a, b) => seqOf[a] - seqOf[b]);
    const prevOf = (p) => {
      const yy = p.slice(0, 4), q = Number(p.slice(5));
      return q > 1 ? `${yy}Q${q - 1}` : null;
    };
    const value = (item, p) => {
      const v = cum[`${item}|${p}`];
      if (v === undefined) return null;
      if (!single) return v;
      const pp = prevOf(p);
      if (!pp) return v;
      const base = cum[`${item}|${pp}`];
      return base === undefined ? null : round6(v - base);
    };
    return { periods, items, perDate, value, raw: (item, p) => cum[`${item}|${p}`] };
  };
  const Spark = ({ vals }) => {
    const pts = vals.filter((v) => v !== null && v !== undefined);
    if (pts.length < 2) return null;
    const W = 90, H = 22, lo = Math.min(...pts), hi = Math.max(...pts), s = hi - lo || 1;
    const d = pts.map((v, i) => `${i ? 'L' : 'M'}${(2 + (i * (W - 4)) / (pts.length - 1)).toFixed(1)},${(H - 2 - ((v - lo) / s) * (H - 4)).toFixed(1)}`).join(' ');
    return <svg width={W} height={H}><path d={d} fill="none" stroke="#5470c6" strokeWidth="1.3" /></svg>;
  };

  // 常用比率：按概念找本公司报表里的科目（A 股、港股两种格式），找不到的比率不显示
  const CONCEPT = {
    rev: ['营业收入', '营业额'], cogs: ['营业成本', '销售成本'], gp: ['毛利'],
    sell: ['销售费用', '销售及分销费用'], admin: ['管理费用', '行政开支'], rd: ['研发费用'],
    op: ['营业利润', '经营溢利'], pretax: ['利润总额', '除税前溢利'], tax: ['所得税费用', '税项'],
    np: ['净利润', '除税后溢利'], npp: ['归属于母公司所有者的净利润', '归属于母公司股东的净利润', '股东应占溢利'],
    ta: ['资产总计', '总资产'], tl: ['负债合计', '总负债'], ca: ['流动资产合计'], cl: ['流动负债合计'],
    cfo: ['经营活动产生的现金流量净额', '经营业务现金净额'],
  };
  const ITEM = {};
  for (const [k, names] of Object.entries(CONCEPT)) {
    for (const st of STMTS) {
      const have = new Set(ROWS[st].map((r) => r.item));
      const it = names.find((n) => have.has(n));
      if (it) { ITEM[k] = [st, it]; break; }
    }
  }
  const cfItems = new Set(cfRows.map((r) => r.item));
  const CAPEX = cfItems.has('购建固定资产、无形资产和其他长期资产所支付的现金') ? ['购建固定资产、无形资产和其他长期资产所支付的现金']
    : ['购建固定资产', '购建无形资产及其他资产'].filter((n) => cfItems.has(n));
  const RATIOS = {
    '利润表': [
      ['毛利率', 'pct', (g) => div(g('gp') ?? minus(g('rev'), g('cogs')), g('rev')), ['gp', 'cogs']],
      ['销售费用率', 'pct', (g) => div(g('sell'), g('rev')), ['sell']],
      ['管理费用率', 'pct', (g) => div(g('admin'), g('rev')), ['admin']],
      ['研发费用率', 'pct', (g) => div(g('rd'), g('rev')), ['rd']],
      ['营业利润率', 'pct', (g) => div(g('op'), g('rev')), ['op']],
      ['有效税率', 'pct', (g) => div(g('tax'), g('pretax')), ['tax']],
      ['净利率', 'pct', (g) => div(g('np'), g('rev')), ['np']],
      ['归母净利率', 'pct', (g) => div(g('npp'), g('rev')), ['npp']],
    ],
    '资产负债表': [
      ['资产负债率', 'pct', (g) => div(g('tl'), g('ta')), ['tl']],
      ['流动比率', 'x', (g) => div(g('ca'), g('cl')), ['cl']],
    ],
    '现金流量表': [
      ['经营现金流 ÷ 净利润', 'x', (g) => div(g('cfo'), g('np')), ['cfo']],
      ['自由现金流（经营现金流 − 资本开支）', 'amt', (g) => minus(g('cfo'), g('capex')), ['capex']],
      ['资本开支 ÷ 经营现金流', 'pct', (g) => div(g('capex'), g('cfo')), ['capex']],
    ],
  };
  const anchorOf = (st, keys) => {
    for (const k of keys) {
      if (k === 'capex' && CAPEX.length) return CAPEX[CAPEX.length - 1];
      if (ITEM[k] && ITEM[k][0] === st) return ITEM[k][1];
    }
    return null;
  };
  const LOWER_BETTER = /(费用率|有效税率|资产负债率|资本开支 ÷)/;   // 这些比率下降是好事，同比颜色反过来
  const showCalc = (v, f) => (v === undefined || v === null ? '' : f === 'pct' ? `${num(v * 100)}%` : f === 'x' ? `${num(v, 2)} 倍` : fmt(v));

  const Statements = () => {
    const { token } = theme.useToken();
    const [stmt, setStmt] = React.useState(STMTS[1]);
    const [freq, setFreq] = React.useState('年度');
    const [single, setSingle] = React.useState(false);
    const [scope, setScope] = React.useState('关键科目');
    const [win, setWin] = React.useState(8);
    const isFlow = stmt !== '资产负债表';
    const on = freq === '季度' && single && isFlow;
    const m = matrix(ROWS[stmt], on);
    const periods = freq === '年度' ? m.periods.filter((p) => p.endsWith('Q4')) : m.periods;
    const shown = periods.slice(0, win > 0 ? win : undefined);
    const label = (p) => (freq === '年度' ? p.slice(0, 4) : p);
    const NOT_KEY = /(被合并方|终止经营)/;      // 名字像合计行、但不是关键数的科目
    const items = (scope === '关键科目' ? m.items.filter((i) => BOLD.test(i) && !NOT_KEY.test(i)) : m.items)
      .filter((i) => shown.some((p) => m.value(i, p) !== null));   // 所示各期都空的科目不列
    const mats = Object.fromEntries(STMTS.map((st) => [st, st === stmt ? m : matrix(ROWS[st], freq === '季度' && single && st !== '资产负债表')]));
    const getter = (p) => (k) => {
      if (k === 'capex') {
        const vs = CAPEX.map((it) => mats['现金流量表'].value(it, p)).filter((v) => v !== null);
        return vs.length ? vs.reduce((a, b) => a + Math.abs(b), 0) : undefined;
      }
      const x = ITEM[k];
      if (!x) return undefined;
      const v = mats[x[0]].value(x[1], p);
      return v === null ? undefined : v;
    };
    const latest = shown[0];
    const yoyBase = latest ? (freq === '年度' ? `${Number(latest.slice(0, 4)) - 1}Q4` : `${Number(latest.slice(0, 4)) - 1}${latest.slice(4)}`) : null;
    const columns = [
      { title: '科目', dataIndex: 'item', fixed: 'left', width: 220,
        render: (v, r) => (r.kind === 'calc'
          ? <span style={{ paddingLeft: 16, color: token.colorTextSecondary }}>{v}</span>
          : <span style={{ fontWeight: r.kind === 'key' ? 600 : 400 }}>{v}</span>) },
      { title: '趋势', dataIndex: 'spark', width: 104, render: (v) => <Spark vals={v} /> },
      { title: latest ? <div style={{ textAlign: 'center', lineHeight: 1.3 }}><div>同比</div><div style={{ fontSize: 11, color: token.colorTextTertiary }}>{label(latest)} 对 {label(yoyBase)}</div></div> : '同比',
        dataIndex: 'yoy', width: 96, align: 'right',
        render: (v, r) => {
          if (v === undefined) return '';
          const txt = r.fmt === 'pct' ? `${num(v * 100)}pt` : r.fmt === 'x' ? `${num(v, 2)} 倍` : `${num(v * 100)}%`;
          const good = r.lower ? v <= 0 : v >= 0;
          return <span style={{ color: good ? '#389e0d' : '#cf1322' }}>{v >= 0 ? '+' : ''}{txt}</span>;
        } },
      ...shown.map((p) => ({
        title: (<div style={{ textAlign: 'center', lineHeight: 1.3 }}>
          <div>{label(p)}</div>
          <div style={{ fontSize: 11, color: token.colorTextTertiary }}>{m.perDate[p]}</div>
        </div>),
        dataIndex: p, align: 'right', width: 112,
        render: (v, r) => <span style={{ color: v < 0 ? '#cf1322' : r.fmt ? token.colorTextSecondary : undefined }}>{r.fmt ? showCalc(v, r.fmt) : fmt(v)}</span>,
      })),
    ];
    const calcRows = RATIOS[stmt].map(([name, f, fn, anchor]) => {
      const row = { key: `calc:${name}`, item: name, kind: 'calc', fmt: f, lower: LOWER_BETTER.test(name), anchor: anchorOf(stmt, anchor) };
      for (const p of shown) row[p] = fn(getter(p));
      row.spark = [...shown].reverse().map((p) => row[p]);
      const a = latest ? fn(getter(latest)) : undefined, b = yoyBase ? fn(getter(yoyBase)) : undefined;
      row.yoy = f === 'amt' ? (a !== undefined && b !== undefined && b > 0 ? a / b - 1 : undefined) : minus(a, b);
      return row;
    }).filter((r) => shown.some((p) => r[p] !== undefined && r[p] !== null));
    const keep = new Set(items);
    const dataSource = [];
    for (const item of m.items) {
      if (keep.has(item)) {
        const row = { key: item, item, kind: BOLD.test(item) ? 'key' : 'item' };
        for (const p of shown) row[p] = m.value(item, p);
        row.spark = [...shown].reverse().map((p) => row[p]);
        const a = latest ? m.value(item, latest) : null, b = yoyBase ? m.value(item, yoyBase) : null;
        row.yoy = a !== null && b !== null && b > 0 ? a / b - 1 : undefined;
        dataSource.push(row);
      }
      dataSource.push(...calcRows.filter((r) => r.anchor === item));
    }
    dataSource.push(...calcRows.filter((r) => !r.anchor || !m.items.includes(r.anchor)));
    return (
      <Card size="small" title="报表明细" extra={<Text type="secondary" style={{ fontSize: 12 }}>金额：{UNIT}</Text>}>
        <Space wrap style={{ marginBottom: 10 }}>
          <Segmented value={stmt} onChange={setStmt} options={STMTS} />
          <Segmented value={freq} onChange={setFreq} options={['年度', '季度']} />
          {freq === '季度' && isFlow ? <Segmented value={on ? '单季' : '累计'} onChange={(v) => setSingle(v === '单季')} options={['累计', '单季']} /> : null}
          <Segmented value={scope} onChange={setScope} options={['关键科目', '全部科目']} />
          <Select value={win} onChange={setWin} style={{ width: 108 }}
            options={[4, 8, 12, 20].map((n) => ({ label: `近${n}期`, value: n })).concat([{ label: '全部', value: 0 }])} />
        </Space>
        <div style={{ fontSize: 12, color: token.colorTextTertiary, marginBottom: 8 }}>
          {freq === '年度' ? '年度＝四季度报告：利润表、现金流量表为全年，资产负债表为年末。' : '利润表、现金流量表的“累计”是年初至报告期末；“单季”＝本年相邻两期累计之差（一季度即累计）。'}
          灰字缩进的是算出来的比率（毛利率、费用率、利润率、负债率等），放在对应科目下面，比率的同比为百分点变化；
          <span style={{ background: '#e6f0ff', padding: '0 4px' }}>蓝底行</span>是关键科目（合计、小计与关键利润、现金行）；空白＝该期未披露。
        </div>
        <style>{`
          .vi-fs .vi-key-row > td { background: #e6f0ff !important; }
          .vi-fs .vi-key-row:hover > td { background: #d6e6ff !important; }
        `}</style>
        <div className="vi-fs">
          <Table columns={columns} dataSource={dataSource} pagination={false} bordered size="small" scroll={{ x: 'max-content', y: 620 }}
            rowClassName={(r) => (r.kind === 'key' ? 'vi-key-row' : '')} />
        </div>
      </Card>
    );
  };

  ctx.render(
    <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
      <Text type="secondary">{ROLE} 上方关键数据用统一口径的模型指标（各公司按自己的报表科目映射），下方是报表原值。</Text>
      <Overview />
      <Statements />
      <Text type="secondary" style={{ fontSize: 12 }}>
        数据源：akshare（A 股＝新浪财报，港股＝东方财富港股报表）；取数、检验与口径见 framework/tools/fin_stmt.py，表代码 vi_fin_stmt_base。
      </Text>
    </div>,
  );
"""


def script(co):
    role = spec.role_line(spec.all_tables()['fin_stmt'])
    return JS.replace('__COMPANY__', co['code']).replace('__ROLE__', json.dumps(role, ensure_ascii=False))


def update(co):
    uid = next(b['uid'] for b in blocks(page_tree(f"{KEY}@{co['code']}")['tree']) if b.get('use') == 'JSBlockModel')
    nb_json('flow-surfaces', 'configure', '--target', json.dumps({'uid': uid}),
            '--changes', json.dumps({'code': script(co), 'version': 'v2'}, ensure_ascii=False))
    print(co['name'], TITLE, '脚本已更新')


def page_body(co, gid=None):
    """只放三大报表；报表外的分部与财务补充指标在「数据底稿 / 定量指标」。"""
    return {
        'page': {'title': TITLE, 'documentTitle': f"{co['name']} · {TITLE}"},
        'assets': {'scripts': {KEY: {'version': 'v2', 'code': script(co)}}},
        'tabs': [{'title': TITLE, 'blocks': [{'key': KEY, 'type': 'jsBlock', 'script': KEY}]}]}


def create(co):
    st = state()
    gid = ensure_group(st, f"{co['name']}/数据底稿", '数据底稿', 'DatabaseOutlined', parent=company_root(st, co))
    apply_page(f"{KEY}_{co['code']}", {
        'version': '1', 'mode': 'create',
        'navigation': {'group': {'routeId': gid}, 'item': {'title': TITLE, 'icon': ICON}},
        **page_body(co, gid)})
    record(f"{KEY}@{co['code']}", gid, TITLE)


if __name__ == '__main__':
    if '--update' in sys.argv:                   # 只换脚本：页面和菜单都不动
        for co in companies():
            update(co)
        sys.exit()
    for co in companies():
        k = f"{KEY}@{co['code']}"
        if '--rebuild' in sys.argv:
            destroy_page(k)
        if k not in state()['pages']:
            create(co)
    sort_menu()
    print('完成')
