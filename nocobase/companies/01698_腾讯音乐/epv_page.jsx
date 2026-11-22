const { React, antd } = ctx.libs;
const { Segmented, Alert, Typography, Tag, Slider, Tooltip, theme } = antd;
const { Text, Link } = Typography;

const known = (x) => x !== null && x !== undefined && x !== '' && Number.isFinite(Number(x));
const fmt = (x, d = 2) => (known(x) ? Number(x).toLocaleString('zh-CN', { minimumFractionDigits: d, maximumFractionDigits: d }) : '—');
const sfmt = (x, d = 2) => (!known(x) ? '—' : (Number(x) > 0 ? '+' : '') + fmt(x, d));
const pct = (x, d = 1) => (known(x) ? `${(Number(x) * 100).toFixed(d)}%` : '—');
const bySort = (k) => (a, b) => (a[k] ?? 0) - (b[k] ?? 0) || a.id - b.id;

async function list(name, filter, appends = [], pageSize = 500) {
 const res = ctx.makeResource('MultiRecordResource');
 res.setResourceName(name);
 res.setPageSize?.(pageSize);
 if (filter) res.setFilter?.(filter);
 if (appends.length && res.setAppends) res.setAppends(appends);
 await res.refresh();
 return res.getData() || [];
}

async function load() {
 const [co] = await list('vi_company', { code: { $eq: '01698.HK' } });
 const scope = { company_id: { $eq: co.id } };
 const [values, units, lines, judgments, stmts, moats, theses, risks, metrics, checks, settings, bsItems] = await Promise.all([
  list('vi_gw_value', scope),
  list('vi_gw_unit', scope),
  list('vi_epv', scope, ['judgments'], 200),
  list('vi_judgment', scope, ['theses'], 200),
  list('vi_fin_stmt', { ...scope, stmt: { $in: ['利润表', '现金流量表'] } }, [], 2000),
  list('vi_moat', scope),
  list('vi_thesis', scope),
  list('vi_risk', scope),
  list('vi_metric', scope, [], 200),
  list('vi_check', scope),
  list('vi_setting'),
  list('vi_bs_item', scope, [], 200),
 ]);
 lines.forEach((l) => { try { l.hist = JSON.parse(l.history || '[]'); } catch { l.hist = []; } });
 return {
  co, v: values[0], unit: units.find((u) => u.business_code === 'B1') || units[0],
  lines: lines.sort(bySort('sort')),
  judgments: new Map(judgments.map((j) => [j.code, j])),
  stmts, moats: moats.sort((a, b) => String(a.code).localeCompare(String(b.code))),
  theses: theses.sort((a, b) => String(a.code).localeCompare(String(b.code))),
  risks: risks.sort((a, b) => String(a.code).localeCompare(String(b.code))),
  metrics: new Map(metrics.map((m) => [m.code, m])),
  checks: checks.sort(bySort('id')),
  hurdle: settings[0]?.hurdle ?? values[0]?.hurdle,
  bsItems,
 };
}

const style = `
.tme-epv {max-width:1180px;margin:0 auto;padding:4px 4px 28px;color:var(--ink);font-variant-numeric:tabular-nums;line-height:1.55;container-type:inline-size}
.tme-epv * {box-sizing:border-box}
.tme-epv h2,.tme-epv h3,.tme-epv h4,.tme-epv p {margin:0}
.tme-epv .hero {display:grid;grid-template-columns:minmax(0,1.12fr) minmax(0,1fr);gap:20px;padding:20px 24px;background:var(--tint);border:1px solid var(--line);border-radius:12px;align-items:center}
.tme-epv .eyebrow {font-size:13px;color:var(--muted);font-weight:500;display:flex;align-items:center;flex-wrap:wrap;gap:8px}
.tme-epv .num-row {display:flex;align-items:baseline;gap:8px;margin:6px 0 10px;flex-wrap:wrap}
.tme-epv .hero-num {font-size:clamp(34px,4.6cqw,46px);font-weight:700;letter-spacing:-1.4px;line-height:1.12;color:var(--ink)}
.tme-epv .hero-unit {font-size:16px;font-weight:600;color:var(--muted)}
.tme-epv .badges {display:flex;flex-wrap:wrap;gap:6px 14px;font-size:13.5px;color:var(--muted)}
.tme-epv .badges b {color:var(--ink);font-weight:600}
.tme-epv .kpi-strip {margin-top:12px;padding-top:10px;border-top:1px dashed var(--line);display:flex;flex-wrap:wrap;gap:8px 18px;font-size:13px;color:var(--muted)}
.tme-epv .kpi-strip strong {color:var(--ink);font-weight:700}
.tme-epv .is-ok {color:var(--ok) !important}
.tme-epv .is-warn {color:var(--warn) !important}
.tme-epv .is-err {color:var(--err) !important}
.tme-epv .verdict {background:var(--card);border:1px solid var(--line);border-left:4px solid var(--primary);border-radius:10px;padding:14px 16px}
.tme-epv .verdict-head {font-size:13px;font-weight:600;color:var(--primary);margin-bottom:10px;display:flex;justify-content:space-between;align-items:center;gap:8px;flex-wrap:wrap}
.tme-epv .cmp-row {display:grid;grid-template-columns:112px 1fr auto;align-items:center;gap:10px;font-size:13px;margin-bottom:8px}
.tme-epv .cmp-track {height:9px;background:var(--track);border-radius:999px;overflow:hidden}
.tme-epv .cmp-fill {height:100%;border-radius:999px}
.tme-epv .verdict-note {margin-top:8px;padding-top:8px;border-top:1px dashed var(--line);font-size:12.5px;color:var(--muted);line-height:1.55}
.tme-epv .verdict-note b {color:var(--ink)}
.tme-epv .sec {margin-top:16px;background:var(--card);border:1px solid var(--line);border-radius:12px;padding:16px 20px}
.tme-epv .sec-head {display:flex;justify-content:space-between;align-items:baseline;flex-wrap:wrap;gap:6px 16px;margin-bottom:12px}
.tme-epv .sec-head h3 {font-size:15.5px;font-weight:600}
.tme-epv .sec-sub {font-size:12.5px;color:var(--muted)}
.tme-epv .wf-wrap {width:100%;overflow-x:auto}
.tme-epv .wf-svg {display:block;width:100%;min-width:720px;height:auto}
.tme-epv .cap-strip {margin-top:12px;padding-top:12px;border-top:1px solid var(--line-soft);display:grid;grid-template-columns:repeat(5,minmax(0,1fr));gap:10px}
.tme-epv .step {border:1px solid var(--line);border-radius:10px;padding:10px 12px;background:var(--tint-soft);display:flex;flex-direction:column;justify-content:space-between}
.tme-epv .step.is-primary {background:var(--primary-bg);border-color:var(--primary-bd)}
.tme-epv .step.is-ok-card {background:var(--ok-bg);border-color:var(--ok-bd)}
.tme-epv .step-label {font-size:12px;color:var(--muted);font-weight:500}
.tme-epv .step-val {font-size:20px;font-weight:700;letter-spacing:-0.4px;margin:3px 0;line-height:1.2}
.tme-epv .step.is-primary .step-val {color:var(--primary)}
.tme-epv .step.is-ok-card .step-val {color:var(--ok)}
.tme-epv .step-desc {font-size:11.5px;color:var(--muted);line-height:1.4}
.tme-epv .grid-2 {display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:16px;margin-top:16px}
.tme-epv .card {background:var(--card);border:1px solid var(--line);border-radius:12px;padding:16px 20px;display:flex;flex-direction:column;justify-content:space-between}
.tme-epv .chart-svg {display:block;width:100%;height:auto}
.tme-epv .legend {display:flex;flex-wrap:wrap;gap:6px 14px;margin-top:6px;font-size:12px;color:var(--muted)}
.tme-epv .dot {display:inline-block;width:8px;height:8px;border-radius:2px;margin-right:5px;vertical-align:-0.5px}
.tme-epv .swatch {display:inline-block;width:14px;height:2px;margin-right:5px;vertical-align:3px}
.tme-epv .checklist {display:flex;flex-direction:column;gap:8px}
.tme-epv .chk {border:1px solid var(--line-soft);border-radius:9px;padding:9px 12px;background:var(--tint-soft)}
.tme-epv .chk-top {display:flex;justify-content:space-between;align-items:center;gap:8px;flex-wrap:wrap;font-size:13px;font-weight:600}
.tme-epv .chk-desc {margin-top:4px;font-size:12px;color:var(--muted);line-height:1.5}
.tme-epv .chk-desc b {color:var(--ink)}
.tme-epv .toolbar {display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:10px 16px;margin-bottom:10px}
.tme-epv .note-bar {display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:8px 16px;padding:8px 12px;background:var(--tint-soft);border-radius:8px;margin-bottom:12px;font-size:12.5px;color:var(--muted)}
.tme-epv .tbl-wrap {overflow-x:auto;border:1px solid var(--line);border-radius:10px}
.tme-epv table.tbl {width:100%;min-width:940px;border-collapse:collapse;font-size:13px}
.tme-epv .tbl th {background:var(--tint);color:var(--muted);font-weight:600;font-size:12px;padding:9px 10px;border-bottom:1px solid var(--line);white-space:nowrap}
.tme-epv .tbl td {padding:8px 10px;border-bottom:1px solid var(--line-soft);vertical-align:top}
.tme-epv .tbl th.num,.tme-epv .tbl td.num {text-align:right;white-space:nowrap}
.tme-epv .tbl th.col-norm {color:var(--primary);background:var(--primary-bg)}
.tme-epv .tbl td.col-norm {color:var(--primary);font-weight:700;background:var(--primary-soft)}
.tme-epv .tbl th.col-ttm {color:var(--ink)}
.tme-epv .tbl td.col-ttm {font-weight:600}
.tme-epv .tbl td.col-hist {color:var(--muted)}
.tme-epv .tbl tr.sec-row td {background:var(--tint);font-size:11.5px;font-weight:700;color:var(--muted);letter-spacing:0.3px;padding:5px 10px;border-top:1px solid var(--line);border-bottom:1px solid var(--line)}
.tme-epv .tbl tbody tr.sec-row:first-child td {border-top:0}
.tme-epv .tbl tr.item-row:hover td {background:var(--hover)}
.tme-epv .tbl tr.item-row.is-click {cursor:pointer}
.tme-epv .tbl tr.item-row td.item-cell {padding-left:14px}
.tme-epv .tbl tr.sub-row td {background:var(--tint-soft);color:var(--ink);font-weight:700;padding-block:9px;border-top:1.5px solid var(--line-strong)}
.tme-epv .tbl tr.sub-row td:first-child {box-shadow:inset 3px 0 0 var(--line-strong)}
.tme-epv .tbl tr.pct-row td {color:var(--muted);font-size:12px;padding-block:5px;background:var(--card)}
.tme-epv .tbl tr.pct-row td.col-norm {color:var(--primary);font-weight:600;background:var(--primary-soft)}
.tme-epv .tbl tr.major-row td {background:var(--primary-bg);color:var(--ink);font-size:13.5px;font-weight:800;padding-block:11px;border-top:2px solid var(--primary-bd);border-bottom:1.5px solid var(--primary-bd)}
.tme-epv .tbl tr.major-row td:first-child {box-shadow:inset 4px 0 0 var(--primary)}
.tme-epv .tbl tr.major-row td.col-norm {background:var(--primary-bg);color:var(--primary);font-size:14.5px}
.tme-epv .item-title {display:flex;align-items:center;flex-wrap:wrap;gap:6px}
.tme-epv .sign {display:inline-block;width:14px;color:var(--muted);font-weight:600}
.tme-epv .exp-btn {appearance:none;border:1px solid var(--line);background:var(--card);color:var(--primary);font-size:11px;padding:0 6px;border-radius:4px;cursor:pointer;line-height:1.5}
.tme-epv .exp-btn:hover {border-color:var(--primary)}
.tme-epv .basis-row td {background:var(--tint-soft);padding:10px 16px 12px 24px;border-bottom:1px solid var(--line)}
.tme-epv .basis-box {max-width:82ch;font-size:12.5px;line-height:1.65;color:var(--ink)}
.tme-epv .basis-box p + p {margin-top:5px}
.tme-epv .basis-list {margin-top:8px;padding-top:8px;border-top:1px dashed var(--line);display:flex;flex-direction:column;gap:6px}
.tme-epv .pill {display:inline-flex;align-items:center;font-size:11.5px;padding:1px 7px;border-radius:999px;border:1px solid var(--line);color:var(--muted);white-space:nowrap}
.tme-epv .pill.is-adj {color:var(--primary);border-color:var(--primary-bd);background:var(--primary-bg);font-weight:600}
.tme-epv .pill.is-ttm {color:var(--ok);border-color:var(--ok-bd);background:var(--ok-bg);font-weight:600}
.tme-epv .mute {color:var(--dot);user-select:none}
.tme-epv details.fold {border-top:1px solid var(--line-soft);margin-top:12px}
.tme-epv details.fold > summary {cursor:pointer;list-style:none;padding:9px 0 2px;font-size:13px;color:var(--primary);font-weight:600;display:flex;align-items:center;justify-content:space-between;gap:8px}
.tme-epv details.fold > summary::-webkit-details-marker {display:none}
.tme-epv details.fold > summary::after {content:'▾';font-size:13px;color:var(--muted);transition:transform 0.15s ease}
.tme-epv details.fold[open] > summary::after {transform:rotate(180deg)}
.tme-epv .fold-body {padding:8px 0 4px;font-size:12.5px;color:var(--muted);line-height:1.65}
.tme-epv .presets {display:flex;flex-wrap:wrap;gap:8px;margin-bottom:14px}
.tme-epv .pbtn {appearance:none;border:1px solid var(--line);background:var(--tint-soft);color:var(--ink);font-size:12.5px;padding:5px 11px;border-radius:8px;cursor:pointer;font-weight:500}
.tme-epv .pbtn:hover {border-color:var(--primary)}
.tme-epv .pbtn.is-on {background:var(--primary-bg);border-color:var(--primary);color:var(--primary);font-weight:600}
.tme-epv .stress {display:grid;grid-template-columns:minmax(0,1.02fr) minmax(0,1fr);gap:20px;align-items:start}
.tme-epv .sliders {display:flex;flex-direction:column;gap:8px}
.tme-epv .srow {padding:7px 12px 4px;border:1px solid var(--line-soft);border-radius:9px;background:var(--tint-soft)}
.tme-epv .shead {display:flex;justify-content:space-between;align-items:baseline;font-size:12.5px}
.tme-epv .shead b {color:var(--primary);font-size:13px}
.tme-epv .sim-kpis {display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:10px;margin-bottom:12px}
.tme-epv .sim-box {border:1px solid var(--line);border-radius:10px;padding:10px 12px;background:var(--tint-soft)}
.tme-epv .sim-box.is-focus {background:var(--primary-bg);border-color:var(--primary-bd)}
.tme-epv .sim-box span {display:block;font-size:12px;color:var(--muted)}
.tme-epv .sim-box strong {display:block;font-size:19px;font-weight:700;margin-top:2px}
.tme-epv .sim-box small {display:block;font-size:11.5px;color:var(--muted);margin-top:2px}
.tme-epv table.mx {width:100%;border-collapse:collapse;font-size:12.5px;border:1px solid var(--line);border-radius:8px;overflow:hidden}
.tme-epv .mx th,.tme-epv .mx td {padding:7px 8px;text-align:right;border:1px solid var(--line-soft);white-space:nowrap}
.tme-epv .mx th {background:var(--tint);color:var(--muted);font-weight:600}
.tme-epv .mx th:first-child,.tme-epv .mx td:first-child {text-align:left;font-weight:600}
.tme-epv .mx td.c-safe {background:var(--ok-bg);color:var(--ok);font-weight:600}
.tme-epv .mx td.c-tight {background:var(--warn-bg);color:var(--warn);font-weight:600}
.tme-epv .mx td.c-bad {background:var(--err-bg);color:var(--err);font-weight:600}
.tme-epv .mx td.c-base {outline:2px solid var(--primary);outline-offset:-2px}
.tme-epv .moat-row {padding:8px 0;border-bottom:1px dashed var(--line-soft);font-size:12.5px}
.tme-epv .moat-row:last-child {border-bottom:0}
.tme-epv .moat-head {display:flex;justify-content:space-between;align-items:center;gap:8px;flex-wrap:wrap;margin-bottom:3px}
.tme-epv .nav-grid {display:grid;grid-template-columns:repeat(4,minmax(0,1fr));gap:12px;margin-top:16px}
.tme-epv .nav-card {display:flex;flex-direction:column;justify-content:space-between;gap:5px;padding:12px 14px;background:var(--card);border:1px solid var(--line);border-radius:10px;text-decoration:none;color:var(--ink)}
.tme-epv .nav-card:hover {border-color:var(--primary);background:var(--tint-soft)}
.tme-epv .nav-title {font-size:13px;font-weight:600;color:var(--primary)}
.tme-epv .nav-val {font-size:18px;font-weight:700;color:var(--ink)}
.tme-epv .nav-sub {font-size:11.5px;color:var(--muted)}
@container (max-width:900px) {.tme-epv .hero,.tme-epv .grid-2,.tme-epv .stress{grid-template-columns:1fr}.tme-epv .cap-strip,.tme-epv .nav-grid{grid-template-columns:repeat(2,minmax(0,1fr))}}
@container (max-width:520px) {.tme-epv .cap-strip,.tme-epv .nav-grid,.tme-epv .sim-kpis{grid-template-columns:1fr}}
`;

function buildHistory(stmts) {
 const byP = new Map();
 stmts.forEach((r) => {
  if (!byP.has(r.period)) byP.set(r.period, new Map());
  byP.get(r.period).set(`${r.stmt}:${r.item}`, Number(r.amount));
 });
 const get = (p, item, stmt = '利润表') => { const v = byP.get(p)?.get(`${stmt}:${item}`); return known(v) ? v : null; };
 const ttm = (qtr, item, stmt = '利润表') => {
  const m = String(qtr).match(/^(\d{4})Q([1-3])$/);
  if (!m) return get(qtr, item, stmt);
  const [yr, q] = [Number(m[1]), Number(m[2])];
  const [c, py, pq] = [get(`${yr}Q${q}`, item, stmt), get(`${yr - 1}Q4`, item, stmt), get(`${yr - 1}Q${q}`, item, stmt)];
  return [c, py, pq].every(known) ? c + py - pq : null;
 };
 const annual = ['2021', '2022', '2023', '2024', '2025'].map((yr) => {
  const p = `${yr}Q4`;
  const rev = get(p, '营业收入'), sub = get(p, '会员及订阅收入（附注）'), mkt = get(p, '营销及消费服务收入'), soc = get(p, '社交娱乐服务及其他收入');
  const gp = get(p, '毛利'), sm = known(get(p, '销售及营销费用')) ? -get(p, '销售及营销费用') : null, ga = known(get(p, '一般及行政费用')) ? -get(p, '一般及行政费用') : null;
  const coreEbit = [gp, sm, ga].every(known) ? gp - sm - ga : null;
  const cfo = get(p, '经营活动现金流量净额', '现金流量表');
  return { label: yr, rev, sub, mkt, soc, gp, gm: rev ? gp / rev : null, coreEbit, opm: rev ? coreEbit / rev : null, cfo };
 });
 const q = '2026Q3';
 const tRev = ttm(q, '营业收入'), tGp = ttm(q, '毛利');
 const tSm = known(ttm(q, '销售及营销费用')) ? -ttm(q, '销售及营销费用') : null;
 const tGa = known(ttm(q, '一般及行政费用')) ? -ttm(q, '一般及行政费用') : null;
 const tCore = [tGp, tSm, tGa].every(known) ? tGp - tSm - tGa : null;
 const ttmPoint = {
  label: '近四季', rev: tRev, sub: ttm(q, '会员及订阅收入（附注）'), mkt: ttm(q, '营销及消费服务收入'), soc: ttm(q, '社交娱乐服务及其他收入'),
  gp: tGp, gm: tRev ? tGp / tRev : null, coreEbit: tCore, opm: tRev ? tCore / tRev : null, cfo: ttm(q, '经营活动现金流量净额', '现金流量表'),
 };
 const naturePeriods = [['2023Q4', '2023'], ['2024Q4', '2024'], ['2025Q4', '2025'], ['2026Q2', '2026H1']];
 const natureItems = [
  ['服务成本（附注）', '版权、创作者分成、服务器与带宽等直接服务交付成本'],
  ['员工福利费用（附注）', '全集团薪酬、奖金、福利及股权激励（SBC）'],
  ['广告代理费（附注）', '广告渠道返点与代理佣金（2026H1 占集团广告收入 23.0%）'],
  ['推广及广告开支（附注）', '用户获客、品牌推广与活动营销支出'],
  ['其他经营成本费用（测算差额）', '折旧摊销、演出制作成本、周边存货成本及其他未单列经营开支'],
 ];
 const natureTable = natureItems.map(([item, desc]) => {
  const vals = {}, ratios = {};
  naturePeriods.forEach(([p, lbl]) => {
   const a = get(p, item), r = get(p, '营业收入');
   vals[lbl] = a;
   ratios[lbl] = known(a) && known(r) && r > 0 ? a / r : null;
  });
  return { item, desc, vals, ratios };
 });
 const natureTotals = Object.fromEntries(naturePeriods.map(([p, lbl]) => {
  const [c, s, g, r] = [get(p, '营业成本'), get(p, '销售及营销费用'), get(p, '一般及行政费用'), get(p, '营业收入')];
  return [lbl, { total: [c, s, g].every(known) ? -(c + s + g) : null, rev: r }];
 }));
 return { annual, ttmPoint, naturePeriods, natureTable, natureTotals };
}

function WaterfallChart({ unit, costOfRev, opex, token }) {
 const rev = Number(unit.revenue) || 0, gp = rev - costOfRev, ebitRep = Number(unit.ebit_reported) || 0;
 const preAdj = Number(unit.pre_adj) || 0, ebit = Number(unit.ebit) || 0, tax = Number(unit.tax) || 0;
 const nopat = Number(unit.nopat) || 0, postAdj = Number(unit.post_adj) || 0, minority = Number(unit.minority) || 0, e = Number(unit.earnings) || 0;
 const steps = [
  { label: '正常化收入', sub: '100%', s: 0, e: rev, v: rev, k: 'total' },
  { label: '− 营业成本', sub: pct(costOfRev / rev), s: gp, e: rev, v: -costOfRev, k: 'neg' },
  { label: '＝ 毛利', sub: pct(gp / rev), s: 0, e: gp, v: gp, k: 'sub' },
  { label: '− 销售与管理', sub: pct(opex / rev), s: ebitRep, e: gp, v: -opex, k: 'neg' },
  { label: '＝ 核心EBIT', sub: pct(ebitRep / rev), s: 0, e: ebitRep, v: ebitRep, k: 'sub' },
  { label: '+ 收购摊销', sub: '70% PPA', s: ebitRep, e: ebit, v: preAdj, k: preAdj >= 0 ? 'pos' : 'neg' },
  { label: '− 所得税', sub: pct(tax / ebit), s: nopat, e: ebit, v: -tax, k: 'neg' },
  { label: '± 折旧/CapEx', sub: '稳态配平', s: Math.min(nopat, nopat + postAdj), e: Math.max(nopat, nopat + postAdj), v: postAdj, k: Math.abs(postAdj) < 0.05 ? 'zero' : postAdj > 0 ? 'pos' : 'neg' },
  { label: '− 少数股东', sub: pct(1 - unit.attrib), s: e, e: nopat + postAdj, v: -minority, k: 'neg' },
  { label: '＝ 现金收益 E', sub: pct(e / rev), s: 0, e, v: e, k: 'final' },
 ];
 const W = 940, H = 224, pL = 20, pR = 20, pT = 30, pB = 46, cH = H - pT - pB;
 const maxY = Math.max(rev, ebit, e, 1) * 1.08;
 const yOf = (v) => pT + cH - (v / maxY) * cH;
 const colW = (W - pL - pR) / steps.length, barW = Math.min(54, colW * 0.62);
 const fill = (k) => k === 'total' ? token.colorPrimary : k === 'final' || k === 'pos' ? token.colorSuccess : k === 'sub' ? (token.colorInfoActive || token.colorPrimary) : k === 'zero' ? token.colorTextQuaternary : token.colorWarning;
 return (
  <div className="wf-wrap">
   <svg className="wf-svg" viewBox={`0 0 ${W} ${H}`} role="img" aria-label="正常化收入至可持续现金收益E瀑布图">
    <line x1={pL} y1={yOf(0)} x2={W - pR} y2={yOf(0)} stroke={token.colorBorder} strokeWidth="1" />
    {[0.25, 0.5, 0.75].map((f) => <line key={f} x1={pL} y1={yOf(maxY * f)} x2={W - pR} y2={yOf(maxY * f)} stroke={token.colorSplit} strokeDasharray="3 4" />)}
    {steps.map((st, i) => {
     const cx = pL + colW * (i + 0.5), x = cx - barW / 2;
     const yT = yOf(Math.max(st.s, st.e)), yB = yOf(Math.min(st.s, st.e)), h = Math.max(st.k === 'zero' ? 3 : 2, yB - yT);
     const connY = ['total', 'sub', 'final'].includes(st.k) ? yT : st.v >= 0 ? yT : yB;
     const txt = ['total', 'sub', 'final'].includes(st.k) ? fmt(st.v, 1) : Math.abs(st.v) < 0.05 ? '0.0' : sfmt(st.v, 1);
     return (
      <g key={st.label}>
       {steps[i + 1] && <line x1={x + barW} y1={connY} x2={pL + colW * (i + 1.5) - barW / 2} y2={connY} stroke={token.colorBorderSecondary} strokeDasharray="2 2" />}
       <rect x={x} y={yT} width={barW} height={h} rx={4} fill={fill(st.k)} fillOpacity={st.k === 'sub' ? 0.62 : st.k === 'neg' ? 0.78 : 0.92} />
       <text x={cx} y={yT - 7} textAnchor="middle" fontSize="12" fontWeight={['final', 'total', 'sub'].includes(st.k) ? 700 : 600} fill={st.k === 'final' ? token.colorSuccessText : st.k === 'neg' ? token.colorWarningText : token.colorText}>{txt}</text>
       <text x={cx} y={H - 24} textAnchor="middle" fontSize="11.5" fontWeight={st.k === 'final' ? 700 : 500} fill={token.colorText}>{st.label}</text>
       <text x={cx} y={H - 8} textAnchor="middle" fontSize="10.5" fill={token.colorTextSecondary}>{st.sub}</text>
      </g>
     );
    })}
   </svg>
  </div>
 );
}

function MarginHistoryChart({ hist, unit, costOfRev, peerNcmOpm, peerSpotOpm, token }) {
 const series = [
  ...hist.annual,
  hist.ttmPoint,
  { label: '正常化', rev: Number(unit.revenue), sub: hist.normSub, mkt: hist.normMkt, soc: hist.normSoc, gm: (Number(unit.revenue) - costOfRev) / Number(unit.revenue), opm: Number(unit.ebit_reported) / Number(unit.revenue), isNorm: true },
 ];
 const W = 540, H = 242, pL = 34, pR = 38, pT = 22, pB = 32, cW = W - pL - pR, cH = H - pT - pB;
 const maxRev = Math.max(...series.map((s) => s.rev || 0), 400) * 1.08, maxPct = 0.54;
 const yRev = (v) => pT + cH - (v / maxRev) * cH, yPct = (p) => pT + cH - (p / maxPct) * cH;
 const colW = cW / series.length, barW = Math.min(34, colW * 0.56);
 const gmPts = series.map((s, i) => [pL + colW * (i + 0.5), yPct(s.gm || 0), s.gm]);
 const opmPts = series.map((s, i) => [pL + colW * (i + 0.5), yPct(s.opm || 0), s.opm]);
 const pathOf = (pts) => pts.map(([x, y], i) => `${i === 0 ? 'M' : 'L'}${x.toFixed(1)},${y.toFixed(1)}`).join(' ');
 return (
  <svg className="chart-svg" viewBox={`0 0 ${W} ${H}`} role="img" aria-label="2021年至正常化收入构成与利润率趋势">
   {[0, 0.15, 0.30, 0.45].map((p) => (
    <g key={p}>
     <line x1={pL} y1={yPct(p)} x2={W - pR} y2={yPct(p)} stroke={token.colorSplit} strokeDasharray="3 3" />
     <text x={W - pR + 4} y={yPct(p) + 3.5} fontSize="10" fill={token.colorTextTertiary}>{(p * 100).toFixed(0)}%</text>
    </g>
   ))}
   {[0, 150, 300].map((v) => <text key={v} x={pL - 5} y={yRev(v) + 3.5} textAnchor="end" fontSize="10" fill={token.colorTextTertiary}>{v}</text>)}
   <line x1={pL} y1={yPct(0.40)} x2={W - pR} y2={yPct(0.40)} stroke={token.colorError} strokeDasharray="4 3" strokeOpacity="0.6" />
   <text x={pL + 4} y={yPct(0.40) - 4} fontSize="9.5" fill={token.colorError}>M1 毛利红线 40%</text>
   {known(peerNcmOpm) && (
    <>
     <line x1={pL} y1={yPct(peerNcmOpm / 100)} x2={W - pR} y2={yPct(peerNcmOpm / 100)} stroke={token.colorTextTertiary} strokeDasharray="2 3" />
     <text x={W - pR - 4} y={yPct(peerNcmOpm / 100) - 3} textAnchor="end" fontSize="9.5" fill={token.colorTextSecondary}>网易云 OPM {peerNcmOpm.toFixed(1)}%</text>
    </>
   )}
   {known(peerSpotOpm) && (
    <>
     <line x1={pL} y1={yPct(peerSpotOpm / 100)} x2={W - pR} y2={yPct(peerSpotOpm / 100)} stroke={token.colorTextTertiary} strokeDasharray="2 3" />
     <text x={W - pR - 4} y={yPct(peerSpotOpm / 100) + 11} textAnchor="end" fontSize="9.5" fill={token.colorTextSecondary}>Spotify OPM {peerSpotOpm.toFixed(1)}%</text>
    </>
   )}
   {series.map((s, i) => {
    const cx = pL + colW * (i + 0.5), x = cx - barW / 2;
    const [sub, mkt, soc] = [s.sub || 0, s.mkt || 0, s.soc || 0];
    const [y0, y1, y2, y3] = [yRev(0), yRev(sub), yRev(sub + mkt), yRev(sub + mkt + soc)];
    return (
     <g key={s.label}>
      {s.isNorm && <rect x={x - 4} y={pT} width={barW + 8} height={cH} rx={4} fill={token.colorPrimaryBg} fillOpacity="0.65" />}
      <rect x={x} y={y1} width={barW} height={Math.max(0, y0 - y1)} fill={token.colorPrimary} fillOpacity="0.34" />
      <rect x={x} y={y2} width={barW} height={Math.max(0, y1 - y2)} fill={token.colorSuccess} fillOpacity="0.30" />
      <rect x={x} y={y3} width={barW} height={Math.max(0, y2 - y3)} fill={token.colorTextTertiary} fillOpacity="0.22" />
      <text x={cx} y={H - 11} textAnchor="middle" fontSize="11" fontWeight={s.isNorm || s.label === '近四季' ? 700 : 400} fill={s.isNorm ? token.colorPrimary : token.colorTextSecondary}>{s.label}</text>
     </g>
    );
   })}
   <path d={pathOf(gmPts)} fill="none" stroke={token.colorPrimary} strokeWidth="2.2" />
   <path d={pathOf(opmPts)} fill="none" stroke={token.colorSuccess} strokeWidth="2.2" />
   {gmPts.map(([x, y, val], i) => (
    <g key={`gm-${i}`}>
     <circle cx={x} cy={y} r={i === gmPts.length - 1 ? 4 : 3} fill={token.colorPrimary} />
     {(i === 0 || i === 4 || i === gmPts.length - 1) && <text x={x} y={y - 7} textAnchor="middle" fontSize="10.5" fontWeight="700" fill={token.colorPrimary}>{(val * 100).toFixed(1)}%</text>}
    </g>
   ))}
   {opmPts.map(([x, y, val], i) => (
    <g key={`opm-${i}`}>
     <circle cx={x} cy={y} r={i === opmPts.length - 1 ? 4 : 3} fill={token.colorSuccess} />
     {(i === 0 || i === 4 || i === opmPts.length - 1) && <text x={x} y={y + 14} textAnchor="middle" fontSize="10.5" fontWeight="700" fill={token.colorSuccessText}>{(val * 100).toFixed(1)}%</text>}
    </g>
   ))}
  </svg>
 );
}

function EpvContent({ d }) {
 const { token } = theme.useToken();
 const { co, v, unit, lines, judgments, stmts, moats, theses, risks, metrics, checks, hurdle, bsItems = [] } = d;
 const [viewMode, setViewMode] = React.useState('full');
 const [openRows, setOpenRows] = React.useState(() => new Set());
 const bridgeItems = bsItems.filter((i) => i.role === '资产负债桥');
 const sumCat = (cat) => bridgeItems.filter((i) => i.category === cat).reduce((s, i) => s + (Number(i.value_signed) || 0), 0);
 const brCashInv = sumCat('现金与投资') + sumCat('参照估值');
 const brDebt = sumCat('有息负债');
 const brClaims = sumCat('其他索取权');

 const byName = (pre) => lines.find((l) => l.name.startsWith(pre));
 const revLines = lines.filter((l) => l.section === '收入');
 const costLines = lines.filter((l) => l.section === '成本费用');
 const preLines = lines.filter((l) => l.section === '税前调整');
 const taxLines = lines.filter((l) => l.section === '所得税');
 const postLines = lines.filter((l) => l.section === '税后调整');
 const minLines = lines.filter((l) => l.section === '少数股东');
 const exclLines = lines.filter((l) => l.section === '不计入');

 const cogsLine = byName('营业成本'), smLine = byName('销售及营销'), gaLine = byName('一般及行政');
 const daLine = postLines.find((l) => l.direction === '加'), capexLine = postLines.find((l) => l.direction === '减');

 const baseRev = Number(unit.revenue) || 0;
 const baseCogs = known(cogsLine?.normalized) ? Number(cogsLine.normalized) : Number(unit.cost) * 0.77;
 const baseOpex = (known(smLine?.normalized) ? Number(smLine.normalized) : 0) + (known(gaLine?.normalized) ? Number(gaLine.normalized) : 0);
 const baseGm = baseRev > 0 ? (baseRev - baseCogs) / baseRev : 0.428;
 const baseOpexRatio = baseRev > 0 ? baseOpex / baseRev : 0.171;
 const baseCoreOpmPct = Number(((baseGm - baseOpexRatio) * 100).toFixed(1));
 const basePpaTotal = 9.0;
 const basePpaPct = Math.round(((Number(unit.pre_adj) || 0) / basePpaTotal) * 100);
 const baseTaxRate = Number(taxLines[0]?.value) || 0.1687;
 const basePostNet = Number(unit.post_adj) || 0;
 const baseAttrib = Number(unit.attrib) || 0.97;
 const baseHurdle = Number(hurdle ?? unit.h) || 0.06;

 const [simGm, setSimGm] = React.useState(() => Number((baseGm * 100).toFixed(1)));
 const [simOpex, setSimOpex] = React.useState(() => Number((baseOpexRatio * 100).toFixed(1)));
 const [simRevChg, setSimRevChg] = React.useState(0);
 const [simPpa, setSimPpa] = React.useState(() => basePpaPct);
 const [simCapexGap, setSimCapexGap] = React.useState(() => Number((-basePostNet).toFixed(2)));
 const [simHurdle, setSimHurdle] = React.useState(() => Number((baseHurdle * 100).toFixed(1)));
 const [preset, setPreset] = React.useState('base');

 const applyPreset = (id, p) => {
  setPreset(id); setSimGm(p.gm); setSimOpex(p.opex); setSimRevChg(p.revChg); setSimPpa(p.ppa); setSimCapexGap(p.gap); setSimHurdle(p.h);
 };

 const baseEquityEpv = Number(v.epv_total) + Number(v.bridge);
 const rollFactor = known(v.epv_ps) && baseEquityEpv > 0 ? (Number(v.epv_ps) * Number(v.shares)) / baseEquityEpv : 1;
 const evalSim = (gmPct, opexPct, revChgPct, ppaPct, capexMinusDa, hPct) => {
  const rev = baseRev * (1 + revChgPct / 100);
  const ebit = rev * ((gmPct - opexPct) / 100) + basePpaTotal * (ppaPct / 100);
  const e = (ebit * (1 - baseTaxRate) - capexMinusDa) * baseAttrib;
  const epvOps = hPct > 0 ? e / (hPct / 100) : null;
  const ps = epvOps !== null && Number(v.shares) > 0 ? ((epvOps + Number(v.bridge)) * rollFactor) / Number(v.shares) : null;
  return { rev, ebit, e, epvOps, ps };
 };
 const sim = evalSim(simGm, simOpex, simRevChg, simPpa, simCapexGap, simHurdle);

 const hist = React.useMemo(() => {
  const h = buildHistory(stmts);
  h.normSub = Number(revLines[0]?.normalized) || 0;
  h.normMkt = Number(revLines[1]?.normalized) || 0;
  h.normSoc = Number(revLines[2]?.normalized) || 0;
  return h;
 }, [stmts, lines]);

 const peerNcmOpm = metrics.get('01698.HK.T002')?.latest_value;
 const peerSpotOpm = metrics.get('01698.HK.T004')?.latest_value;

 const marketCap = known(v.market_price) && known(v.shares) ? Number(v.market_price) * Number(v.shares) : null;
 const impliedOps = known(marketCap) && known(v.bridge) ? marketCap - Number(v.bridge) : null;
 const impliedMult = known(impliedOps) && Number(unit.earnings) > 0 ? impliedOps / Number(unit.earnings) : null;
 const impliedYield = known(impliedOps) && impliedOps > 0 ? Number(unit.earnings) / impliedOps : null;
 const impliedE = known(impliedOps) ? impliedOps * baseHurdle : null;
 const epvMult = baseHurdle > 0 ? 1 / baseHurdle : null;
 const discount = known(v.market_price) && known(v.epv_ps) && Number(v.epv_ps) > 0 ? Number(v.market_price) / Number(v.epv_ps) - 1 : null;
 const franchise = known(v.epv_total) && known(v.av_total) ? Number(v.epv_total) - Number(v.av_total) : null;
 const franchiseShare = known(franchise) && Number(v.epv_total) > 0 ? franchise / Number(v.epv_total) : null;
 const roicInclGw = known(unit.nopat) && known(v.book_capital) && Number(v.book_capital) > 0 ? Number(unit.nopat) / Number(v.book_capital) : null;
 const maxBar = Math.max(Number(v.epv_total) || 0, Number(v.av_total) || 0, impliedOps || 0, 1);

 const recent4 = hist.annual.filter((a) => ['2022', '2023', '2024', '2025'].includes(a.label));
 const sum4Cfo = recent4.reduce((s, a) => s + (a.cfo || 0), 0);
 const sum4Core = recent4.reduce((s, a) => s + (a.coreEbit || 0), 0);

 const periods = ['近四季（2026Q3）', '2025', '2024', '2023', '2022', '2021'];
 const histMap = (l) => Object.fromEntries(l.hist || []);
 const sumH = (ls) => Object.fromEntries(periods.map((p) => {
  const xs = ls.map((l) => histMap(l)[p]);
  return [p, xs.length && xs.every(known) ? xs.reduce((a, b) => a + Number(b), 0) : null];
 }));
 const revH = sumH(revLines), costH = sumH(costLines), cogsH = cogsLine ? histMap(cogsLine) : {};
 const gpH = Object.fromEntries(periods.map((p) => [p, known(revH[p]) && known(cogsH[p]) ? revH[p] - cogsH[p] : null]));
 const gmH = Object.fromEntries(periods.map((p) => [p, known(gpH[p]) && revH[p] ? gpH[p] / revH[p] : null]));
 const coreH = Object.fromEntries(periods.map((p) => [p, known(revH[p]) && known(costH[p]) ? revH[p] - costH[p] : null]));
 const opmH = Object.fromEntries(periods.map((p) => [p, known(coreH[p]) && revH[p] ? coreH[p] / revH[p] : null]));

 const badgeOf = (l) => {
  if (l.method === '滚动四季度') return { text: 'TTM 滚动四季', cls: 'is-ttm' };
  if (l.method === '占收入比例') return { text: `占收入 ${pct(l.value, 1)}`, cls: '' };
  if (l.method === '比率') return { text: `比率 ${pct(l.value, 1)}`, cls: '' };
  if (l.method === '历史平均') return { text: `${l.from_year}–${l.to_year} 均值`, cls: '' };
  if (l.section === '税前调整' || l.section === '税后调整') return { text: 'Greenwald 调整', cls: 'is-adj' };
  return { text: l.method || '直接估算', cls: '' };
 };
 const signOf = (l) => (l.section === '收入' ? '' : l.section === '税前调整' || l.section === '税后调整' ? (l.direction === '减' ? '−' : '＋') : '−');
 const toRow = (l) => ({
  key: `line-${l.id}`, kind: 'item', sign: signOf(l), label: l.name, badge: badgeOf(l),
  norm: l.normalized, ratio: l.ratio, h: histMap(l), note: l.note,
  judgs: (l.judgments || []).map((j) => judgments.get(j.code) || j),
 });
 const toExcl = (l) => ({ ...toRow(l), sign: '×', badge: { text: '归入 ④ 剥离', cls: '' }, norm: null, ratio: null });

 const fullRows = [
  { key: 's1', kind: 'sec', title: '一、正常化营业收入（按业务经济特征分别去季节性与并表校准）' },
  ...revLines.map(toRow),
  { key: 't-rev', kind: 'sub', label: '＝ 正常化营业收入合计', norm: unit.revenue, ratio: 1, h: revH },
  { key: 's2', kind: 'sec', title: '二、功能法经营成本与费用（官方报表全历史连续，对接毛利率护城河）' },
  ...(cogsLine ? [toRow(cogsLine), { key: 't-gp', kind: 'sub', label: '＝ 正常化毛利', norm: baseRev - baseCogs, ratio: baseGm, h: gpH }, { key: 'p-gm', kind: 'pct', label: '　毛利率（M1 真实壁垒警戒线 40% / T1 42%）', norm: baseGm, h: gmH }] : []),
  ...costLines.filter((l) => l !== cogsLine).map(toRow),
  { key: 't-core', kind: 'sub', label: '＝ 核心经营利润（调整前 EBIT）', norm: unit.ebit_reported, ratio: unit.ebit_reported / unit.revenue, h: coreH },
  { key: 'p-core', kind: 'pct', label: '　核心经营利润率（对比 2025 顶点 29.4% · 网易云 18.9% · Spotify 13.5%）', norm: unit.ebit_reported / unit.revenue, h: opmH },
  { key: 's3', kind: 'sec', title: '三、Greenwald 税前调整与正常化所得税' },
  ...preLines.map(toRow),
  { key: 't-ebit', kind: 'sub', label: '＝ 调整后经营利润（Normalized EBIT）', norm: unit.ebit, ratio: unit.margin, h: {} },
  ...taxLines.map(toRow),
  { key: 't-nopat', kind: 'sub', label: '＝ 税后经营利润（NOPAT）', norm: unit.nopat, ratio: unit.nopat / unit.revenue, h: {} },
  { key: 's4', kind: 'sec', title: '四、从会计利润到无增长可持续现金收益 E（折旧/CapEx 稳态配平 & 归母）' },
  ...postLines.map(toRow),
  ...minLines.map(toRow),
  { key: 't-e', kind: 'major', label: '＝ 可持续现金收益 E（归母，零增长）', norm: unit.earnings, ratio: unit.earnings / unit.revenue, h: {} },
  { key: 'p-h', kind: 'pct', label: `÷ 统一资本化门槛 R（全公司共用，当前 ${pct(baseHurdle, 1)} → ${fmt(epvMult, 1)}× 倍数）`, norm: null, h: {} },
  { key: 't-epv', kind: 'major', label: '＝ 第二层：经营盈利能力价值 EPV（亿元）', norm: unit.epv, ratio: null, h: {} },
 ];
 const adjRows = [
  { key: 'a1', kind: 'sec', title: '一、税前与税后 Greenwald 核心调整项' },
  ...preLines.map(toRow), ...taxLines.map(toRow), ...postLines.map(toRow), ...minLines.map(toRow),
  { key: 'a-e', kind: 'major', label: '＝ 可持续现金收益 E（归母）', norm: unit.earnings, ratio: unit.earnings / unit.revenue, h: {} },
  { key: 'a2', kind: 'sec', title: '二、已从经营利润彻底剥离的非经营项目（全部归入 ④ 独立资产，杜绝重复计算）' },
  ...exclLines.map(toExcl),
 ];

 const toggleRow = (k) => setOpenRows((p) => { const n = new Set(p); n.has(k) ? n.delete(k) : n.add(k); return n; });
 const matrixMargins = [20.0, 22.5, baseCoreOpmPct, 27.5, 29.5];
 const matrixHurdles = [5.0, 6.0, 8.0, 10.0, 12.0];
 const keyMoats = moats.filter((m) => ['真实壁垒', '局部优势'].includes(m.verdict));
 const keyRisks = risks.filter((r) => ['R1', 'R2', 'R4'].includes(r.code));
 const epvChecks = checks.filter((c) => ['G02', 'G05', 'G08'].includes(c.code));

 const vars = {
  '--ink': token.colorText, '--muted': token.colorTextSecondary, '--dot': token.colorTextQuaternary,
  '--card': token.colorBgContainer, '--tint': token.colorFillQuaternary, '--tint-soft': token.colorFillAlter || token.colorFillQuaternary,
  '--hover': token.colorFillTertiary, '--track': token.colorFillSecondary, '--line': token.colorBorderSecondary,
  '--line-soft': token.colorSplit, '--line-strong': token.colorBorder, '--primary': token.colorPrimary,
  '--primary-bg': token.colorPrimaryBg, '--primary-soft': token.colorFillAlter || token.colorPrimaryBg, '--primary-bd': token.colorPrimaryBorder,
  '--ok': token.colorSuccessText || token.colorSuccess, '--ok-bg': token.colorSuccessBg, '--ok-bd': token.colorSuccessBorder,
  '--warn': token.colorWarningText || token.colorWarning, '--warn-bg': token.colorWarningBg, '--warn-bd': token.colorWarningBorder,
  '--err': token.colorError, '--err-bg': token.colorErrorBg, '--err-bd': token.colorErrorBorder,
 };

 const renderRows = (rows) => rows.map((r) => {
  if (r.kind === 'sec') return <tr className="sec-row" key={r.key}><td colSpan={10}>{r.title}</td></tr>;
  if (r.kind !== 'item') {
   const isP = r.kind === 'pct';
   return (
    <tr className={r.kind === 'major' ? 'major-row' : r.kind === 'sub' ? 'sub-row' : 'pct-row'} key={r.key}>
     <td colSpan={2}>{r.label}</td>
     <td className="num col-norm">{isP ? (known(r.norm) ? pct(r.norm, 1) : '') : fmt(r.norm, 1)}</td>
     <td className="num">{!isP && known(r.ratio) ? pct(r.ratio, 1) : ''}</td>
     {periods.map((p, i) => <td key={p} className={`num ${i === 0 ? 'col-ttm' : 'col-hist'}`}>{known(r.h?.[p]) ? (isP ? pct(r.h[p], 1) : fmt(r.h[p], 1)) : <span className="mute">·</span>}</td>)}
    </tr>
   );
  }
  const hasD = Boolean(r.note || r.judgs?.length), open = openRows.has(r.key);
  return (
   <React.Fragment key={r.key}>
    <tr className={`item-row ${hasD ? 'is-click' : ''}`} onClick={hasD ? () => toggleRow(r.key) : undefined}>
     <td className="item-cell">
      <div className="item-title">
       <span className="sign">{r.sign}</span>
       <span style={{ fontWeight: 500 }}>{r.label}</span>
       {hasD && <button type="button" className="exp-btn" onClick={(e) => { e.stopPropagation(); toggleRow(r.key); }}>{open ? '收起 ▴' : '依据 ▾'}</button>}
      </div>
     </td>
     <td><span className={`pill ${r.badge.cls}`}>{r.badge.text}</span></td>
     <td className="num col-norm">{known(r.norm) ? fmt(r.norm, 1) : <span className="mute">不计入</span>}</td>
     <td className="num">{known(r.ratio) ? pct(r.ratio, 1) : <span className="mute">·</span>}</td>
     {periods.map((p, i) => <td key={p} className={`num ${i === 0 ? 'col-ttm' : 'col-hist'}`}>{known(r.h?.[p]) ? fmt(r.h[p], 1) : <span className="mute">·</span>}</td>)}
    </tr>
    {hasD && open && (
     <tr className="basis-row">
      <td colSpan={10}>
       <div className="basis-box">
        {r.note && <p><b>测算说明：</b>{r.note}</p>}
        {r.judgs?.length > 0 && (
         <div className="basis-list">
          {r.judgs.map((j) => (
           <div key={j.code || j.id}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 6, flexWrap: 'wrap', marginBottom: 3 }}>
             <Tag color="blue" style={{ marginInlineEnd: 0 }}>{j.code}</Tag>
             <b>{j.title}</b>
             {(j.theses || []).map((t) => <Tag key={t.id} color={t.status === '成立' ? 'green' : t.status === '存疑' ? 'orange' : 'default'} style={{ marginInlineEnd: 0 }}>{t.code} · {t.status}</Tag>)}
             <Link href="/admin/__BASIS_UID__" style={{ fontSize: 12 }}>编辑假设依据 →</Link>
            </div>
            {j.judgment && <p style={{ color: token.colorTextSecondary }}><b>判断：</b>{j.judgment}</p>}
            {j.transmission && <p style={{ color: token.colorTextSecondary }}><b>传导：</b>{j.transmission}</p>}
            {j.change_threshold && <p style={{ color: token.colorTextSecondary }}><b>何时重估：</b>{j.change_threshold}</p>}
           </div>
          ))}
         </div>
        )}
       </div>
      </td>
     </tr>
    )}
   </React.Fragment>
  );
 });

 return (
  <article className="tme-epv" style={vars}>
   <style>{style}</style>

   {/* 1. 首屏结论主焦区 */}
   <header className="hero">
    <div>
     <div className="eyebrow">
      <span>第二层 · 经营盈利能力价值（EPV）· 截至 {String(co.as_of).slice(0, 10)}</span>
      <Tag color="blue" style={{ marginInlineEnd: 0 }}>零增长稳态</Tag>
      {v.value_layer === '盈利能力价值' && <Tag color="green" style={{ marginInlineEnd: 0 }}>主估值层</Tag>}
     </div>
     <div className="num-row">
      <strong className="hero-num">{fmt(v.epv_total, 1)}</strong>
      <span className="hero-unit">亿元（归母经营 EPV）</span>
     </div>
     <div className="badges">
      <span>可持续现金收益 E <b>{fmt(unit.earnings, 2)} 亿/年</b></span>
      <span>÷ 统一门槛 <b>{pct(baseHurdle, 1)}</b>（{fmt(epvMult, 1)}×）</span>
      <span>＋ ④ 资产负债桥 <b>{sfmt(v.bridge, 1)} 亿</b>（现金投资 +{fmt(brCashInv, 1)} − 有息负债 {fmt(Math.abs(brDebt), 1)} − 税费与少数股东 {fmt(Math.abs(brClaims), 1)}）</span>
     </div>
     <div className="kpi-strip">
      <span>每股 EPV（滚算至今）<strong>{fmt(v.epv_ps, 2)} 元</strong></span>
      <span>现价（{v.market_date}）<strong>{fmt(v.market_price, 2)} 元</strong></span>
      <span>安全边际 <strong className={discount !== null && discount <= 0 ? 'is-ok' : 'is-warn'}>{discount !== null ? (discount <= 0 ? `折价 ${pct(-discount, 1)}` : `溢价 ${pct(discount, 1)}`) : '—'}</strong></span>
      <span>零增长隐含回报 <strong className={known(v.irr_epv) && Number(v.irr_epv) >= baseHurdle ? 'is-ok' : 'is-warn'}>{pct(v.irr_epv, 1)}</strong></span>
     </div>
    </div>

    <div className="verdict">
     <div className="verdict-head">
      <span>Greenwald 双重交叉检验（同口径经营价值）</span>
      <Tag color={known(v.market_price) && Number(v.market_price) <= Number(v.epv_ps) ? 'green' : 'orange'} style={{ marginInlineEnd: 0 }}>
       {known(v.market_price) && Number(v.market_price) <= Number(v.epv_ps) ? '现价不为增长付钱' : '现价已含增长预期'}
      </Tag>
     </div>
     <div className="cmp-row">
      <Text type="secondary">① 经营资产 AV</Text>
      <div className="cmp-track"><div className="cmp-fill" style={{ width: `${Math.max(3, ((Number(v.av_total) || 0) / maxBar) * 100)}%`, background: token.colorTextTertiary }} /></div>
      <Text strong>{fmt(v.av_total, 1)} 亿</Text>
     </div>
     <div className="cmp-row">
      <Tooltip title={`总市值 ${fmt(marketCap, 1)} 亿 − ④ 独立资产净额 ${fmt(v.bridge, 1)} 亿 ＝ 市场给主营业务的净定价`}>
       <Text type="secondary" style={{ cursor: 'help', borderBottom: `1px dashed ${token.colorBorder}` }}>市场隐含主营</Text>
      </Tooltip>
      <div className="cmp-track"><div className="cmp-fill" style={{ width: `${Math.max(3, ((impliedOps || 0) / maxBar) * 100)}%`, background: token.colorWarning }} /></div>
      <Text strong style={{ color: token.colorWarningText }}>{fmt(impliedOps, 1)} 亿 <Text type="secondary" style={{ fontSize: 11.5 }}>({fmt(impliedMult, 1)}×E)</Text></Text>
     </div>
     <div className="cmp-row" style={{ marginBottom: 0 }}>
      <Text type="secondary">② 经营盈利 EPV</Text>
      <div className="cmp-track"><div className="cmp-fill" style={{ width: `${Math.max(3, ((Number(v.epv_total) || 0) / maxBar) * 100)}%`, background: token.colorPrimary }} /></div>
      <Text strong style={{ color: token.colorPrimary }}>{fmt(v.epv_total, 1)} 亿</Text>
     </div>
     <p className="verdict-note">
      <b>特许经营溢价（EPV − AV）＝ {fmt(franchise, 1)} 亿</b>（占 EPV {pct(franchiseShare, 1)}，含商誉 ROIC 约 {pct(roicInclGw, 0)}）：盈利远超账面资产，必须由真实壁垒（M1）兜底。
      扣除 ④ 后市场仅为主营付 <b>{fmt(impliedOps, 1)} 亿</b>（<b>{fmt(impliedMult, 1)}× E</b>，主营零增长收益率 <b>{pct(impliedYield, 1)}</b>）；按 {pct(baseHurdle, 1)} 门槛反推，现价只隐含 <b>E ＝ {fmt(impliedE, 1)} 亿</b>（不足当前盈利能力一半）。
     </p>
    </div>
   </header>

   {/* 2. 盈利→现金→EPV 瀑布桥 */}
   <section className="sec">
    <div className="sec-head">
     <h3>可持续现金收益 E 是怎么从正常化收入一步步算出来的？（亿元）</h3>
     <span className="sec-sub">{unit.capital_basis}口径（利息与债务归入 ④）· 股权激励 SBC 不加回 · 经营 D&amp;A 与维持性 CapEx 稳态配平</span>
    </div>
    <WaterfallChart unit={unit} costOfRev={baseCogs} opex={baseOpex} token={token} />
    <div className="cap-strip">
     <div className="step"><span className="step-label">① 调整后经营利润 EBIT</span><strong className="step-val">{fmt(unit.ebit, 1)}</strong><span className="step-desc">核心 EBIT {fmt(unit.ebit_reported, 1)} ＋ 七成收购摊销 {fmt(unit.pre_adj, 1)}</span></div>
     <div className="step"><span className="step-label">② 归母现金收益 E</span><strong className="step-val">{fmt(unit.earnings, 2)}</strong><span className="step-desc">NOPAT {fmt(unit.nopat, 1)} ± 税后 {sfmt(unit.post_adj, 1)} × 归母 {pct(baseAttrib, 0)}</span></div>
     <div className="step is-primary"><span className="step-label">③ ÷ 门槛 {pct(baseHurdle, 1)} ＝ 经营 EPV</span><strong className="step-val">{fmt(v.epv_total, 1)}</strong><span className="step-desc">零增长永续资本化（{fmt(epvMult, 1)}× E），不含增长溢价</span></div>
     <div className="step"><span className="step-label">④ ＋ 资产负债桥（含扣债）</span><strong className="step-val">{sfmt(v.bridge, 1)}</strong><span className="step-desc">现金投资 +{fmt(brCashInv, 1)} − 有息负债 {fmt(Math.abs(brDebt), 1)} − 其他 {fmt(Math.abs(brClaims), 1)} → 股权 {fmt(baseEquityEpv, 1)} 亿</span></div>
     <div className="step is-ok-card"><span className="step-label">⑤ 每股 EPV（滚算至今）</span><strong className="step-val">{fmt(v.epv_ps, 2)} 元</strong><span className="step-desc">股本 {fmt(v.shares, 2)} 亿股 · 对比现价 {fmt(v.market_price, 2)} 元</span></div>
    </div>
   </section>

   {/* 3. 双栏 Greenwald 正常化诊断 */}
   <div className="grid-2">
    <section className="card">
     <div>
      <div className="sec-head" style={{ marginBottom: 6 }}>
       <h3>正常化检视一 · 我们是在资本化周期顶点吗？</h3>
       <span className="sec-sub">2021–2026Q3 收入结构（柱，亿）与利润率（线）</span>
      </div>
      <MarginHistoryChart hist={hist} unit={unit} costOfRev={baseCogs} peerNcmOpm={peerNcmOpm} peerSpotOpm={peerSpotOpm} token={token} />
      <div className="legend">
       <span><i className="dot" style={{ background: token.colorPrimary, opacity: 0.5 }} />会员服务</span>
       <span><i className="dot" style={{ background: token.colorSuccess, opacity: 0.45 }} />营销及消费</span>
       <span><i className="dot" style={{ background: token.colorTextTertiary, opacity: 0.35 }} />社交娱乐</span>
       <span><i className="swatch" style={{ background: token.colorPrimary }} />毛利率</span>
       <span><i className="swatch" style={{ background: token.colorSuccess }} />核心经营利润率</span>
      </div>
     </div>
     <p style={{ marginTop: 10, paddingTop: 8, borderTop: `1px dashed ${token.colorSplit}`, fontSize: 12.5, color: token.colorTextSecondary }}>
      <b style={{ color: token.colorText }}>结论：没有把高点当常态。</b>
      2021–2025 业务结构彻底换血（社交娱乐 63% → 14%，毛利率 30.1% → 44.2%）。本次正常化主动采用喜马拉雅完整并表后的 Q3 利润率（毛利率 <b>{pct(baseGm, 1)}</b>、核心 OPM <b>{pct(baseGm - baseOpexRatio, 1)}</b>），低于 2025 顶点（29.4%）与近四季（28.8%），同时仍大幅领先网易云（{known(peerNcmOpm) ? `${peerNcmOpm.toFixed(1)}%` : '—'}）与 Spotify（{known(peerSpotOpm) ? `${peerSpotOpm.toFixed(1)}%` : '—'}）。
     </p>
    </section>

    <section className="card">
     <div>
      <div className="sec-head" style={{ marginBottom: 8 }}>
       <h3>正常化检视二 · Greenwald EPV 五项纪律核查</h3>
       <span className="sec-sub">逐条核对会计扭曲与跨层边界</span>
      </div>
      <div className="checklist">
       <div className="chk">
        <div className="chk-top"><span>1. 去季节性与去伪精确（收入基准）</span><Tag color="green" style={{ marginInlineEnd: 0 }}>已修正</Tag></div>
        <div className="chk-desc">会员取并表首季 Q3×4（<b>199.4 亿</b>，不臆造已停披用户×ARPPU）；营销及消费改取 <b>TTM 99.3 亿</b>，消除 Q1 淡季与 Q3 演出旺季虚高（−8.6 亿）；社交娱乐取同比 −15.7% 后的 Q3×4 底线（<b>50.4 亿</b>）。</div>
       </div>
       <div className="chk">
        <div className="chk-top"><span>2. 折旧摊销 vs 维持性 CapEx（稳态约束）</span><Tag color="green" style={{ marginInlineEnd: 0 }}>已配平 0.0 亿</Tag></div>
        <div className="chk-desc">并表后经营折旧摊销（剔除七成 PPA）为 <b>{fmt(daLine?.normalized, 2)} 亿</b>。无增长稳态下经营折旧不能永续高于重置开支，故维持性 CapEx 按 <b>{fmt(capexLine?.normalized, 2)} 亿</b>配平（24–25 剔除购地后 CapEx 与 D&amp;A 本就约 1:1），消除 +52.5 亿跨口径虚增。</div>
       </div>
       <div className="chk">
        <div className="chk-top"><span>3. 增长性费用加回＝0 &amp; SBC 不加回</span><Tag color="blue" style={{ marginInlineEnd: 0 }}>严于卖方口径</Tag></div>
        <div className="chk-desc">Greenwald 允许加回纯扩张营销/研发，此处审慎取 <b>0</b>（销售费用率 3.3% 已极低，研发用于防卫竞争）。股权激励（SBC 约 7 亿/年）留作真实成本，本模型 <b>E＝{fmt(unit.earnings, 1)} 亿</b> 显著保守于卖方 Non-IFRS 净利（100+ 亿）。</div>
       </div>
       <div className="chk">
        <div className="chk-top"><span>4. 非经营收益与债务彻底剥离</span><Tag color="green" style={{ marginInlineEnd: 0 }}>杜绝重复计价</Tag></div>
        <div className="chk-desc">利息收入（2025 年 10.5 亿）、一次性投资收益（2025 年 26.3 亿）、联营损益与融资成本全部划入「不计入」，对应的 515 亿现金、186 亿股权与 221 亿有息负债在 ④ 独立计价。</div>
       </div>
       <div className="chk">
        <div className="chk-top"><span>5. 利润含金量验真（T6 经营现金流覆盖）</span><Tag color="green" style={{ marginInlineEnd: 0 }}>真现金</Tag></div>
        <div className="chk-desc">2022–2025 累计经营现金流 <b>{fmt(sum4Cfo, 1)} 亿</b>，为核心经营利润（{fmt(sum4Core, 1)} 亿）的 <b>{fmt(sum4Core > 0 ? sum4Cfo / sum4Core : null, 2)} 倍</b>；近四季 CFO 达 <b>{fmt(hist.ttmPoint.cfo, 1)} 亿</b>，远覆盖正常化 E（{fmt(unit.earnings, 1)} 亿）。</div>
       </div>
      </div>
     </div>
    </section>
   </div>

   {/* 4. 调整后利润表底稿（3 视角切换） */}
   <section className="sec">
    <div className="toolbar">
     <h3 style={{ fontSize: 16, fontWeight: 600 }}>{unit.business_name} · 调整后利润表底稿（亿元）</h3>
     <Segmented
      value={viewMode}
      onChange={setViewMode}
      options={[
       { label: '完整调整后利润表（主口径）', value: 'full' },
       { label: '仅看调整与非经营剥离', value: 'adjust' },
       { label: '附注成本性质透视（2023–26H1）', value: 'nature' },
      ]}
     />
    </div>

    {viewMode !== 'nature' ? (
     <>
      <div className="note-bar">
       <span>蓝色列为<b>正常化年度估算</b>（实时读自 <code>vi_epv</code>）。全历史采用同一功能法口径，点击任意带「依据」行可展开测算说明、假设判断与关联论点。</span>
       <Link href="/admin/__BASIS_UID__" style={{ fontSize: 12.5 }}>管理全部假设依据 →</Link>
      </div>
      <div className="tbl-wrap">
       <table className="tbl">
        <thead>
         <tr>
          <th style={{ textAlign: 'left', minWidth: 265 }}>项目与测算依据</th>
          <th style={{ textAlign: 'left', width: 118 }}>取值口径</th>
          <th className="num col-norm" style={{ width: 88 }}>正常化</th>
          <th className="num" style={{ width: 68 }}>占收入</th>
          {periods.map((p, i) => <th key={p} className={`num ${i === 0 ? 'col-ttm' : ''}`} style={{ width: i === 0 ? 112 : 72 }}>{p}</th>)}
         </tr>
        </thead>
        <tbody>{renderRows(viewMode === 'full' ? fullRows : adjRows)}</tbody>
       </table>
      </div>
      {viewMode === 'full' && exclLines.length > 0 && (
       <details className="fold">
        <summary>不计入经营利润的项目（{exclLines.length} 项 · 对应资产/负债已在 ④ 独立计价）</summary>
        <div className="fold-body">
         <div className="tbl-wrap">
          <table className="tbl">
           <thead>
            <tr>
             <th style={{ textAlign: 'left', minWidth: 265 }}>剥离项目与原因</th>
             <th style={{ textAlign: 'left', width: 118 }}>归属去向</th>
             <th className="num col-norm" style={{ width: 88 }}>正常化</th>
             <th className="num" style={{ width: 68 }}>占收入</th>
             {periods.map((p, i) => <th key={p} className={`num ${i === 0 ? 'col-ttm' : ''}`} style={{ width: i === 0 ? 112 : 72 }}>{p}</th>)}
            </tr>
           </thead>
           <tbody>{renderRows(exclLines.map(toExcl))}</tbody>
          </table>
         </div>
        </div>
       </details>
      )}
     </>
    ) : (
     <>
      <div className="note-bar">
       <span><b>为何附注按性质拆分独立展示？</b>公司仅在年报与半年报附注披露成本性质（2026Q3 季报未披露，且 2026H1 仅含喜马拉雅约 1 个月并表）。独立展示既保留成本内部结构透视，又避免在主表制造 84 亿黑箱差额和丢失毛利率。</span>
      </div>
      <div className="tbl-wrap">
       <table className="tbl" style={{ minWidth: 740 }}>
        <thead>
         <tr>
          <th style={{ textAlign: 'left', width: '40%' }}>成本费用性质（年报/中报附注）</th>
          {hist.naturePeriods.map(([, lbl]) => <th key={lbl} className="num">{lbl}（亿元 / 占收入）</th>)}
         </tr>
        </thead>
        <tbody>
         {hist.natureTable.map((row) => (
          <tr className="item-row" key={row.item}>
           <td className="item-cell">
            <div style={{ fontWeight: 600 }}>{row.item}</div>
            <div style={{ fontSize: 11.5, color: token.colorTextSecondary }}>{row.desc}</div>
           </td>
           {hist.naturePeriods.map(([, lbl]) => (
            <td key={lbl} className="num">
             <div><b>{fmt(row.vals[lbl], 2)}</b></div>
             <div style={{ fontSize: 11.5, color: token.colorTextSecondary }}>{pct(row.ratios[lbl], 1)}</div>
            </td>
           ))}
          </tr>
         ))}
         <tr className="sub-row">
          <td>合计（＝ 营业成本 ＋ 销售费用 ＋ 管理费用）</td>
          {hist.naturePeriods.map(([, lbl]) => {
           const t = hist.natureTotals[lbl];
           return (
            <td key={lbl} className="num">
             <div>{fmt(t.total, 2)}</div>
             <div style={{ fontSize: 11.5, fontWeight: 500, color: token.colorTextSecondary }}>{known(t.total) && known(t.rev) ? pct(t.total / t.rev, 1) : '—'}</div>
            </td>
           );
          })}
         </tr>
        </tbody>
       </table>
      </div>
     </>
    )}
   </section>

   {/* 5. 交互式压力测试 & 安全边际矩阵 */}
   <section className="sec">
    <div className="sec-head">
     <h3>Greenwald 压力测试：盈利能力打折多少，才会跌破现价 {fmt(v.market_price, 2)} 元？</h3>
     <span className="sec-sub">交互试算沙盒（只读，不改动数据库保存值）· 检验核心假设的容错边界</span>
    </div>
    <div className="presets">
     {[
      ['base', '当前基准', { gm: Number((baseGm * 100).toFixed(1)), opex: Number((baseOpexRatio * 100).toFixed(1)), revChg: 0, ppa: basePpaPct, gap: Number((-basePostNet).toFixed(2)), h: Number((baseHurdle * 100).toFixed(1)) }],
      ['soda', '汽水冲击（M1 40% 红线）', { gm: 40.0, opex: 19.0, revChg: -5, ppa: 70, gap: 0, h: 6.0 }],
      ['cons', '极保守会计（PPA 0% + CapEx 加码）', { gm: 42.0, opex: 17.5, revChg: 0, ppa: 0, gap: 2.0, h: 6.0 }],
      ['wacc10', '外资高门槛考验（要求回报 10%）', { gm: Number((baseGm * 100).toFixed(1)), opex: Number((baseOpexRatio * 100).toFixed(1)), revChg: 0, ppa: 70, gap: 0, h: 10.0 }],
     ].map(([id, label, p]) => (
      <button key={id} type="button" className={`pbtn ${preset === id ? 'is-on' : ''}`} onClick={() => applyPreset(id, p)}>{label}</button>
     ))}
    </div>

    <div className="stress">
     <div className="sliders">
      <div className="srow">
       <div className="shead"><span>正常化收入变动（基准 {fmt(baseRev, 1)} 亿）</span><b>{simRevChg >= 0 ? `+${simRevChg}%` : `${simRevChg}%`}（{fmt(sim.rev, 1)} 亿）</b></div>
       <Slider min={-20} max={10} step={1} value={simRevChg} onChange={(x) => { setPreset('custom'); setSimRevChg(x); }} />
      </div>
      <div className="srow">
       <div className="shead"><span>毛利率（基准 {pct(baseGm, 1)} · M1 红线 40%）</span><b>{simGm.toFixed(1)}%</b></div>
       <Slider min={35} max={46} step={0.2} value={simGm} onChange={(x) => { setPreset('custom'); setSimGm(x); }} />
      </div>
      <div className="srow">
       <div className="shead"><span>经营费用率 S&amp;M＋G&amp;A（基准 {pct(baseOpexRatio, 1)}）</span><b>{simOpex.toFixed(1)}%</b></div>
       <Slider min={13} max={23} step={0.2} value={simOpex} onChange={(x) => { setPreset('custom'); setSimOpex(x); }} />
      </div>
      <div className="srow">
       <div className="shead"><span>收购摊销加回比例（总 9.0 亿/年 · 基准 {basePpaPct}%）</span><b>{simPpa}%（+{fmt(basePpaTotal * simPpa / 100, 1)} 亿）</b></div>
       <Slider min={0} max={100} step={10} value={simPpa} onChange={(x) => { setPreset('custom'); setSimPpa(x); }} />
      </div>
      <div className="srow">
       <div className="shead"><span>维持性 CapEx − 经营折旧差额（稳态 0 · 负值＝历史低 CapEx）</span><b>{sfmt(simCapexGap, 2)} 亿</b></div>
       <Slider min={-3.5} max={4.0} step={0.25} value={simCapexGap} onChange={(x) => { setPreset('custom'); setSimCapexGap(x); }} />
      </div>
      <div className="srow">
       <div className="shead"><span>资本化门槛 R（统一设置 {pct(baseHurdle, 1)}）</span><b>{simHurdle.toFixed(1)}%（{fmt(100 / simHurdle, 1)}×）</b></div>
       <Slider min={5} max={12} step={0.5} value={simHurdle} onChange={(x) => { setPreset('custom'); setSimHurdle(x); }} />
      </div>
     </div>

     <div>
      <div className="sim-kpis">
       <div className="sim-box">
        <span>试算核心 OPM / 可持续现金收益 E</span>
        <strong>{(simGm - simOpex).toFixed(1)}% · {fmt(sim.e, 1)} 亿</strong>
        <small>相对基准 E（{fmt(unit.earnings, 1)} 亿）{sfmt(sim.e - Number(unit.earnings), 1)} 亿</small>
       </div>
       <div className="sim-box is-focus">
        <span>试算每股 EPV（含 ④ 滚算至今）</span>
        <strong className={known(v.market_price) && sim.ps >= Number(v.market_price) ? 'is-ok' : 'is-err'}>{fmt(sim.ps, 2)} 元</strong>
        <small>经营 EPV {fmt(sim.epvOps, 0)} 亿 · 相对现价 {fmt(v.market_price, 2)} 元 {known(v.market_price) && sim.ps > 0 ? sfmt((sim.ps / Number(v.market_price) - 1) * 100, 1) + '%' : '—'}</small>
       </div>
      </div>
      <div style={{ fontSize: 12.5, fontWeight: 600, marginBottom: 6 }}>安全边际二维矩阵：核心经营利润率 × 要求回报率 → 每股 EPV（元）</div>
      <div style={{ overflowX: 'auto' }}>
       <table className="mx">
        <thead>
         <tr><th>核心 OPM ＼ 门槛 R</th>{matrixHurdles.map((h) => <th key={h}>{h.toFixed(0)}%</th>)}</tr>
        </thead>
        <tbody>
         {matrixMargins.map((m) => (
          <tr key={m}>
           <td>{m.toFixed(1)}%{Math.abs(m - baseCoreOpmPct) < 0.05 ? '（基准）' : m === 20.0 ? '（重压）' : m === 29.5 ? '（25顶）' : ''}</td>
           {matrixHurdles.map((h) => {
            const r = evalSim(m + baseOpexRatio * 100, baseOpexRatio * 100, 0, basePpaPct, -basePostNet, h);
            const mp = Number(v.market_price) || 0;
            const cls = r.ps >= mp * 1.15 ? 'c-safe' : r.ps >= mp ? 'c-tight' : 'c-bad';
            const isBase = Math.abs(m - baseCoreOpmPct) < 0.05 && Math.abs(h - baseHurdle * 100) < 0.05;
            return <td key={h} className={`${cls} ${isBase ? 'c-base' : ''}`}>{fmt(r.ps, 1)}</td>;
           })}
          </tr>
         ))}
        </tbody>
       </table>
      </div>
      <div style={{ fontSize: 11.5, color: token.colorTextSecondary, marginTop: 6 }}>绿格＝高于现价 15%+（安全边际厚）；黄格＝高于现价 0–15%；红格＝低于现价 {fmt(v.market_price, 2)} 元；蓝框＝当前基准。</div>
     </div>
    </div>
   </section>

   {/* 6. 壁垒支撑与风险映射 */}
   <div className="grid-2">
    <section className="card">
     <div>
      <div className="sec-head" style={{ marginBottom: 6 }}>
       <h3>为什么 EPV 能远高于资产价值？（壁垒支撑）</h3>
       <span className="sec-sub">支撑 {pct(baseGm, 1)} 毛利率与 {pct(roicInclGw, 0)} ROIC 的竞争壁垒</span>
      </div>
      {keyMoats.map((m) => (
       <div className="moat-row" key={m.id}>
        <div className="moat-head">
         <span><b>{m.code}</b> {m.title}</span>
         <span>
          <Tag color={m.verdict === '真实壁垒' ? 'green' : 'blue'} style={{ marginInlineEnd: 4 }}>{m.verdict}</Tag>
          <Tag color={m.trend === '削弱' ? 'orange' : 'default'} style={{ marginInlineEnd: 0 }}>趋势：{m.trend}</Tag>
         </span>
        </div>
        <div style={{ color: token.colorTextSecondary }}>{m.financial_link || m.mechanism}</div>
       </div>
      ))}
     </div>
     <div style={{ marginTop: 8, paddingTop: 8, borderTop: `1px solid ${token.colorSplit}`, display: 'flex', flexWrap: 'wrap', gap: 6 }}>
      {theses.filter((t) => ['T1', 'T2', 'T3', 'T4', 'T6'].includes(t.code)).map((t) => (
       <Tag key={t.id} color={t.status === '成立' ? 'green' : t.status === '存疑' ? 'orange' : 'default'} style={{ marginInlineEnd: 0 }}>{t.code} · {t.status}</Tag>
      ))}
     </div>
    </section>

    <section className="card">
     <div>
      <div className="sec-head" style={{ marginBottom: 6 }}>
       <h3>什么会击穿第二层盈利能力？（核心风险红线）</h3>
       <span className="sec-sub">Greenwald 警示：壁垒收窄时超额回报会向资本成本收敛</span>
      </div>
      {keyRisks.map((r) => (
       <div className="moat-row" key={r.id}>
        <div className="moat-head">
         <span><b>{r.code}</b> {r.title}</span>
         <Tag color={r.level === '重大' ? 'red' : 'orange'} style={{ marginInlineEnd: 0 }}>{r.level}</Tag>
        </div>
        <div style={{ color: token.colorTextSecondary }}>{r.early_warning || r.impact_estimate || r.mechanism}</div>
       </div>
      ))}
     </div>
     <details className="fold" style={{ marginTop: 8 }}>
      <summary>模型口径自检（G02 / G05 / G08）</summary>
      <div className="fold-body">
       {epvChecks.map((c) => (
        <p key={c.code}>
         <Tag color={c.result === '通过' ? 'green' : c.result === '提示' ? 'gold' : 'red'} style={{ marginInlineEnd: 6 }}>{c.code} {c.result}</Tag>
         <b style={{ color: token.colorText }}>{c.name}</b>：{c.detail}
        </p>
       ))}
      </div>
     </details>
    </section>
   </div>

   {/* 7. 底部三层串联导航 */}
   <nav className="nav-grid" aria-label="Greenwald 三层估值导航">
    <Link href="/admin/__AV_UID__" className="nav-card">
     <span className="nav-title">← ① 资产价值（底线）</span>
     <span className="nav-val">{fmt(v.av_total, 1)} 亿</span>
     <span className="nav-sub">重估净经营资产 · 含④每股 {fmt(v.av_ps, 2)} 元</span>
    </Link>
    <Link href="/admin/__GROWTH_UID__" className="nav-card">
     <span className="nav-title">→ ③ 增长价值（上行期权）</span>
     <span className="nav-val">+{fmt(unit.growth_value, 1)} 亿</span>
     <span className="nav-sub">g {pct(unit.g, 1)} · RONIC {pct(unit.ronic, 0)} · {unit.adv_years || '永续'} 年</span>
    </Link>
    <Link href="/admin/__BRIDGE_UID__" className="nav-card">
     <span className="nav-title">→ ④ 独立资产与负债桥</span>
     <span className="nav-val">+{fmt(v.bridge, 1)} 亿</span>
     <span className="nav-sub">多余现金、折后股权投资 − 债务与税费</span>
    </Link>
    <Link href="/admin/__EQUITY_UID__" className="nav-card">
     <span className="nav-title">→ ⑤ 股权价值汇总</span>
     <span className="nav-val">{fmt(v.value_ps, 2)} 元/股</span>
     <span className="nav-sub">主估值层：{v.value_layer} · 隐含回报 {pct(v.implied_irr, 1)}</span>
    </Link>
   </nav>
  </article>
 );
}

function App() {
 const [data, setData] = React.useState(null);
 const [error, setError] = React.useState('');
 React.useEffect(() => { load().then(setData).catch((e) => setError(String(e))); }, []);
 if (error) return <Alert type="error" showIcon message={error} />;
 if (!data) return <Text type="secondary">正在读取调整后利润表与 Greenwald 诊断底稿…</Text>;
 if (!data.unit || !data.v) return <Alert type="warning" showIcon message="腾讯音乐第二层调整后利润表或估值汇总尚待补全。" />;
 return <EpvContent d={data} />;
}

ctx.render(<App />);
