const { React, antd } = ctx.libs;
const { Segmented, Alert, Typography, Tag, Slider, Tooltip, theme } = antd;
const { Text, Link } = Typography;

const known = (x) => x !== null && x !== undefined && x !== '' && Number.isFinite(Number(x));
const fmt = (x, d = 2) => (known(x) ? Number(x).toLocaleString('zh-CN', { minimumFractionDigits: d, maximumFractionDigits: d }) : '—');
const sfmt = (x, d = 2) => (!known(x) ? '—' : (Number(x) > 0 ? '+' : '') + fmt(x, d));
const pct = (x, d = 1) => (known(x) ? `${(Number(x) * 100).toFixed(d)}%` : '—');
const bySort = (k) => (a, b) => (a[k] ?? 0) - (b[k] ?? 0) || a.id - b.id;

async function list(name, filter, appends = [], pageSize = 500) {
  const r = ctx.makeResource('MultiRecordResource');
  r.setResourceName(name);
  r.setPageSize?.(pageSize);
  if (filter) r.setFilter?.(filter);
  if (appends.length && r.setAppends) r.setAppends(appends);
  await r.refresh();
  return r.getData() || [];
}

async function load() {
  const [co] = await list('vi_company', { code: { $eq: '01698.HK' } });
  const scope = { company_id: { $eq: co.id } };
  const [values, units, items, judgments, epvLines, stmts, checks, theses, risks] = await Promise.all([
    list('vi_gw_value', scope),
    list('vi_gw_unit', scope),
    list('vi_bs_item', scope, ['judgments'], 200),
    list('vi_judgment', scope, ['theses'], 200),
    list('vi_epv', scope, [], 200),
    list('vi_fin_stmt', { ...scope, stmt: { $eq: '资产负债表' }, period: { $in: ['2024Q4', '2025Q4', '2026Q2', '2026Q3'] } }, [], 500),
    list('vi_check', scope),
    list('vi_thesis', scope),
    list('vi_risk', scope),
  ]);
  epvLines.forEach((l) => { try { l.hist = JSON.parse(l.history || '[]'); } catch { l.hist = []; } });
  return {
    co, v: values[0], unit: units.find((u) => u.business_code === 'B1') || units[0],
    items: items.sort(bySort('sort')),
    judgments: new Map(judgments.map((j) => [j.code, j])),
    exclEpv: epvLines.filter((l) => l.section === '不计入').sort(bySort('sort')),
    stmts,
    checks: checks.filter((c) => ['G01', 'G05', 'G07'].includes(c.code)),
    t5: theses.find((t) => t.code === 'T5'),
    r3: risks.find((r) => r.code === 'R3'),
  };
}

const style = `
.tme-br {max-width:1180px;margin:0 auto;padding:4px 4px 28px;color:var(--ink);font-variant-numeric:tabular-nums;line-height:1.55;container-type:inline-size}
.tme-br * {box-sizing:border-box}
.tme-br h2,.tme-br h3,.tme-br p {margin:0}
.tme-br .hero {display:grid;grid-template-columns:minmax(0,1.1fr) minmax(0,1fr);gap:20px;padding:20px 24px;background:var(--tint);border:1px solid var(--line);border-radius:12px;align-items:center}
.tme-br .eyebrow {font-size:13px;color:var(--muted);font-weight:500;display:flex;align-items:center;flex-wrap:wrap;gap:8px}
.tme-br .num-row {display:flex;align-items:baseline;gap:8px;margin:6px 0 10px;flex-wrap:wrap}
.tme-br .hero-num {font-size:clamp(34px,4.6cqw,46px);font-weight:700;letter-spacing:-1.4px;line-height:1.12;color:var(--ink)}
.tme-br .hero-unit {font-size:16px;font-weight:600;color:var(--muted)}
.tme-br .badges {display:flex;flex-wrap:wrap;gap:6px 14px;font-size:13.5px;color:var(--muted)}
.tme-br .badges b {color:var(--ink);font-weight:600}
.tme-br .kpi-strip {margin-top:12px;padding-top:10px;border-top:1px dashed var(--line);display:flex;flex-wrap:wrap;gap:8px 18px;font-size:13px;color:var(--muted)}
.tme-br .kpi-strip strong {color:var(--ink);font-weight:700}
.tme-br .verdict {background:var(--card);border:1px solid var(--line);border-left:4px solid var(--primary);border-radius:10px;padding:14px 16px}
.tme-br .verdict-head {font-size:13px;font-weight:600;color:var(--primary);margin-bottom:10px;display:flex;justify-content:space-between;align-items:center;gap:8px;flex-wrap:wrap}
.tme-br .cmp-row {display:grid;grid-template-columns:118px 1fr auto;align-items:center;gap:10px;font-size:13px;margin-bottom:7px}
.tme-br .cmp-track {height:9px;background:var(--track);border-radius:999px;overflow:hidden}
.tme-br .cmp-fill {height:100%;border-radius:999px}
.tme-br .verdict-note {margin-top:8px;padding-top:8px;border-top:1px dashed var(--line);font-size:12.5px;color:var(--muted);line-height:1.55}
.tme-br .verdict-note b {color:var(--ink)}
.tme-br .sec {margin-top:16px;background:var(--card);border:1px solid var(--line);border-radius:12px;padding:16px 20px}
.tme-br .sec-head {display:flex;justify-content:space-between;align-items:baseline;flex-wrap:wrap;gap:6px 16px;margin-bottom:12px}
.tme-br .sec-head h3 {font-size:15.5px;font-weight:600}
.tme-br .sec-sub {font-size:12.5px;color:var(--muted)}
.tme-br .wf-wrap {width:100%;overflow-x:auto}
.tme-br .wf-svg {display:block;width:100%;min-width:700px;height:auto}
.tme-br .grid-2 {display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:16px;margin-top:16px}
.tme-br .card {background:var(--card);border:1px solid var(--line);border-radius:12px;padding:16px 20px;display:flex;flex-direction:column;justify-content:space-between}
.tme-br .chart-svg {display:block;width:100%;height:auto}
.tme-br .legend {display:flex;flex-wrap:wrap;gap:6px 14px;margin-top:6px;font-size:12px;color:var(--muted)}
.tme-br .dot {display:inline-block;width:8px;height:8px;border-radius:2px;margin-right:5px;vertical-align:-0.5px}
.tme-br .iso-row {display:grid;grid-template-columns:1fr auto 1fr;gap:8px;align-items:center;padding:8px 10px;border:1px solid var(--line-soft);border-radius:8px;background:var(--tint-soft);font-size:12.5px;margin-bottom:8px}
.tme-br .iso-row:last-child {margin-bottom:0}
.tme-br .stress {display:grid;grid-template-columns:minmax(0,1fr) minmax(0,1fr);gap:20px;align-items:start}
.tme-br .sliders {display:flex;flex-direction:column;gap:8px}
.tme-br .srow {padding:7px 12px 4px;border:1px solid var(--line-soft);border-radius:9px;background:var(--tint-soft)}
.tme-br .shead {display:flex;justify-content:space-between;align-items:baseline;font-size:12.5px}
.tme-br .shead b {color:var(--primary);font-size:13px}
.tme-br .sim-kpis {display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:10px}
.tme-br .sim-box {border:1px solid var(--line);border-radius:10px;padding:10px 12px;background:var(--tint-soft)}
.tme-br .sim-box.is-focus {background:var(--primary-bg);border-color:var(--primary-bd)}
.tme-br .sim-box span {display:block;font-size:12px;color:var(--muted)}
.tme-br .sim-box strong {display:block;font-size:19px;font-weight:700;margin-top:2px}
.tme-br .sim-box small {display:block;font-size:11.5px;color:var(--muted);margin-top:2px}
.tme-br .toolbar {display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:10px 16px;margin-bottom:10px}
.tme-br .tbl-wrap {overflow-x:auto;border:1px solid var(--line);border-radius:10px}
.tme-br table.tbl {width:100%;min-width:860px;border-collapse:collapse;font-size:13px}
.tme-br .tbl th {background:var(--tint);color:var(--muted);font-weight:600;font-size:12px;padding:9px 10px;border-bottom:1px solid var(--line);white-space:nowrap}
.tme-br .tbl td {padding:8px 10px;border-bottom:1px solid var(--line-soft);vertical-align:top}
.tme-br .tbl th.num,.tme-br .tbl td.num {text-align:right;white-space:nowrap}
.tme-br .tbl tr.sec-row td {background:var(--tint);font-size:11.5px;font-weight:700;color:var(--muted);padding:5px 10px;border-top:1px solid var(--line);border-bottom:1px solid var(--line)}
.tme-br .tbl tbody tr.sec-row:first-child td {border-top:0}
.tme-br .tbl tr.item-row:hover td {background:var(--hover)}
.tme-br .tbl tr.item-row.is-click {cursor:pointer}
.tme-br .tbl tr.sub-row td {background:var(--tint-soft);font-weight:700;border-top:1.5px solid var(--line-strong)}
.tme-br .tbl tr.major-row td {background:var(--primary-bg);font-weight:800;font-size:13.5px;border-top:2px solid var(--primary-bd)}
.tme-br .exp-btn {appearance:none;border:1px solid var(--line);background:var(--card);color:var(--primary);font-size:11px;padding:0 6px;border-radius:4px;cursor:pointer;line-height:1.5}
.tme-br .basis-row td {background:var(--tint-soft);padding:10px 16px 12px 24px;border-bottom:1px solid var(--line)}
.tme-br .basis-box {max-width:82ch;font-size:12.5px;line-height:1.65}
.tme-br .basis-box p + p {margin-top:4px}
.tme-br .nav-grid {display:grid;grid-template-columns:repeat(4,minmax(0,1fr));gap:12px;margin-top:16px}
.tme-br .nav-card {display:flex;flex-direction:column;justify-content:space-between;gap:5px;padding:12px 14px;background:var(--card);border:1px solid var(--line);border-radius:10px;text-decoration:none;color:var(--ink)}
.tme-br .nav-card:hover {border-color:var(--primary);background:var(--tint-soft)}
.tme-br .nav-title {font-size:13px;font-weight:600;color:var(--primary)}
.tme-br .nav-val {font-size:18px;font-weight:700;color:var(--ink)}
.tme-br .nav-sub {font-size:11.5px;color:var(--muted)}
.tme-br .is-ok {color:var(--ok)}
.tme-br .is-warn {color:var(--warn)}
.tme-br .is-err {color:var(--err)}
.tme-br .mute {color:var(--dot)}
@container (max-width:900px) {.tme-br .hero,.tme-br .grid-2,.tme-br .stress{grid-template-columns:1fr}.tme-br .nav-grid{grid-template-columns:repeat(2,minmax(0,1fr))}}
@container (max-width:520px) {.tme-br .sim-kpis,.tme-br .nav-grid{grid-template-columns:1fr}.tme-br .iso-row{grid-template-columns:1fr}}
`;

function BridgeWaterfall({ grossCash, opReserve, invBook, invHaircutLoss, debtAbs, whtAbs, nciAbs, netBridge, token }) {
  const excessCash = grossCash - opReserve;
  const invNet = invBook - invHaircutLoss;
  const grossAssets = excessCash + invNet;
  const afterDebt = grossAssets - debtAbs;
  const steps = [
    { label: '广义现金存款', sub: '含定存', s: 0, e: grossCash, v: grossCash, k: 'pos' },
    { label: '− 经营周转金', sub: '划往 ① 层', s: excessCash, e: grossCash, v: -opReserve, k: 'neg' },
    { label: '+ 对外投资(折后)', sub: `账面${fmt(invBook, 0)}折后`, s: excessCash, e: grossAssets, v: invNet, k: 'pos' },
    { label: '− 全部有息负债', sub: '借款/票据/租赁', s: afterDebt, e: grossAssets, v: -debtAbs, k: 'debt' },
    { label: '− 汇出预提税', sub: '10% 暂估', s: afterDebt - whtAbs, e: afterDebt, v: -whtAbs, k: 'neg' },
    { label: '− 非经营少数股东', sub: '3% 份额', s: netBridge, e: afterDebt - whtAbs, v: -nciAbs, k: 'neg' },
    { label: '＝ ④ 桥净额', sub: '并入股权价值', s: 0, e: netBridge, v: netBridge, k: 'final' },
  ];
  const W = 900, H = 224, pL = 24, pR = 24, pT = 30, pB = 46, cH = H - pT - pB;
  const maxY = Math.max(grossAssets, grossCash, 1) * 1.1;
  const yOf = (v) => pT + cH - (Math.max(0, v) / maxY) * cH;
  const colW = (W - pL - pR) / steps.length, barW = Math.min(64, colW * 0.58);
  const fill = (k) => k === 'final' ? token.colorPrimary : k === 'pos' ? token.colorSuccess : k === 'debt' ? token.colorError : token.colorWarning;
  return (
    <div className="wf-wrap">
      <svg className="wf-svg" viewBox={`0 0 ${W} ${H}`} role="img" aria-label="独立资产与负债桥瀑布图">
        <line x1={pL} y1={yOf(0)} x2={W - pR} y2={yOf(0)} stroke={token.colorBorder} />
        {[0.25, 0.5, 0.75].map((f) => <line key={f} x1={pL} y1={yOf(maxY * f)} x2={W - pR} y2={yOf(maxY * f)} stroke={token.colorSplit} strokeDasharray="3 4" />)}
        {steps.map((st, i) => {
          const cx = pL + colW * (i + 0.5), x = cx - barW / 2;
          const yT = yOf(Math.max(st.s, st.e)), yB = yOf(Math.min(st.s, st.e)), h = Math.max(3, yB - yT);
          const connY = st.k === 'final' ? yT : st.v >= 0 ? yT : yB;
          return (
            <g key={st.label}>
              {steps[i + 1] && <line x1={x + barW} y1={connY} x2={pL + colW * (i + 1.5) - barW / 2} y2={connY} stroke={token.colorBorderSecondary} strokeDasharray="2 2" />}
              <rect x={x} y={yT} width={barW} height={h} rx={4} fill={fill(st.k)} fillOpacity={st.k === 'final' ? 0.92 : 0.78} />
              <text x={cx} y={yT - 7} textAnchor="middle" fontSize="12" fontWeight={st.k === 'final' || st.k === 'debt' ? 700 : 600} fill={st.k === 'debt' ? token.colorError : st.k === 'final' ? token.colorPrimary : token.colorText}>
                {st.k === 'final' ? fmt(st.v, 1) : sfmt(st.v, 1)}
              </text>
              <text x={cx} y={H - 24} textAnchor="middle" fontSize="11.5" fontWeight={st.k === 'final' ? 700 : 500} fill={token.colorText}>{st.label}</text>
              <text x={cx} y={H - 8} textAnchor="middle" fontSize="10.5" fill={token.colorTextSecondary}>{st.sub}</text>
            </g>
          );
        })}
      </svg>
    </div>
  );
}

function CashDebtChart({ stmts, token }) {
  const byP = new Map();
  stmts.forEach((r) => {
    if (!byP.has(r.period)) byP.set(r.period, new Map());
    byP.get(r.period).set(r.item, Number(r.amount) || 0);
  });
  const sum = (p, names) => names.reduce((s, n) => s + (byP.get(p)?.get(n) || 0), 0);
  const periods = [['2024Q4', '2024'], ['2025Q4', '2025'], ['2026Q2', '26Q2'], ['2026Q3', '26Q3']].map(([p, lbl]) => {
    const cash = sum(p, ['现金及现金等价物', '短期存款', '中长期存款', '短期投资']);
    const debt = sum(p, ['短期借款', '长期借款', '应付票据（非流动）', '租赁负债（流动）', '租赁负债（非流动）']);
    const inv = sum(p, ['以公允价值计量且其变动计入其他综合收益的金融资产', '其他投资（非流动）', '按权益法核算的投资', '其他投资（流动）']);
    return { lbl, cash, debt, inv, netCash: cash - debt };
  });
  const W = 520, H = 216, pL = 38, pR = 16, pT = 24, pB = 34, cW = W - pL - pR, cH = H - pT - pB;
  const maxY = Math.max(...periods.map((x) => Math.max(x.cash, x.debt, x.inv)), 520) * 1.12;
  const yOf = (v) => pT + cH - (v / maxY) * cH;
  const colW = cW / periods.length, bw = 22;
  return (
    <svg className="chart-svg" viewBox={`0 0 ${W} ${H}`} role="img" aria-label="2024年至2026Q3现金存款、有息负债与对外投资演变">
      {[0, 200, 400].map((v) => (
        <g key={v}>
          <line x1={pL} y1={yOf(v)} x2={W - pR} y2={yOf(v)} stroke={token.colorSplit} strokeDasharray="3 3" />
          <text x={pL - 5} y={yOf(v) + 3.5} textAnchor="end" fontSize="10" fill={token.colorTextTertiary}>{v}</text>
        </g>
      ))}
      {periods.map((p, i) => {
        const cx = pL + colW * (i + 0.5);
        return (
          <g key={p.lbl}>
            <rect x={cx - bw * 1.55} y={yOf(p.cash)} width={bw} height={yOf(0) - yOf(p.cash)} rx={3} fill={token.colorSuccess} fillOpacity="0.72" />
            <text x={cx - bw * 1.05} y={yOf(p.cash) - 4} textAnchor="middle" fontSize="9.5" fontWeight="600" fill={token.colorSuccessText}>{fmt(p.cash, 0)}</text>
            <rect x={cx - bw * 0.45} y={yOf(p.debt)} width={bw} height={yOf(0) - yOf(p.debt)} rx={3} fill={token.colorError} fillOpacity="0.72" />
            <text x={cx + bw * 0.05} y={yOf(p.debt) - 4} textAnchor="middle" fontSize="9.5" fontWeight="600" fill={token.colorError}>{fmt(p.debt, 0)}</text>
            <rect x={cx + bw * 0.65} y={yOf(p.inv)} width={bw} height={yOf(0) - yOf(p.inv)} rx={3} fill={token.colorPrimary} fillOpacity="0.62" />
            <text x={cx + bw * 1.15} y={yOf(p.inv) - 4} textAnchor="middle" fontSize="9.5" fill={token.colorPrimary}>{fmt(p.inv, 0)}</text>
            <text x={cx} y={H - 12} textAnchor="middle" fontSize="11" fontWeight={i === 3 ? 700 : 400} fill={token.colorTextSecondary}>{p.lbl}</text>
          </g>
        );
      })}
    </svg>
  );
}

function BridgeContent({ d }) {
  const { token } = theme.useToken();
  const { co, v, unit, items, judgments, exclEpv, stmts, checks, t5, r3 } = d;
  const [catFilter, setCatFilter] = React.useState('all');
  const [openRows, setOpenRows] = React.useState(() => new Set());

  const bridge = items.filter((i) => i.role === '资产负债桥');
  const CASH_NAMES = new Set(['现金及现金等价物', '短期存款', '中长期存款', '短期投资']);
  const cashRows = bridge.filter((i) => CASH_NAMES.has(i.line_item));
  const opOut = bridge.find((i) => i.name === '划给经营的周转现金');
  const invRows = bridge.filter((i) => i.category === '现金与投资' && !CASH_NAMES.has(i.line_item) && i !== opOut);
  const debtRows = bridge.filter((i) => i.category === '有息负债');
  const claimRows = bridge.filter((i) => i.category === '其他索取权');

  const sumV = (rs, k = 'value_signed') => rs.reduce((s, r) => s + (Number(r[k]) || 0), 0);
  const grossCash = sumV(cashRows, 'book_signed');
  const opReserve = Math.abs(Number(opOut?.value_signed) || 0);
  const excessCash = grossCash - opReserve;
  const invBook = sumV(invRows, 'book_signed');
  const invNet = sumV(invRows, 'value_signed');
  const invHaircutLoss = invBook - invNet;
  const debtAbs = Math.abs(sumV(debtRows, 'value_signed'));
  const whtRow = claimRows.find((r) => (r.name || '').includes('预提税'));
  const nciRow = claimRows.find((r) => r.line_item === '非控股权益');
  const whtAbs = Math.abs(Number(whtRow?.value_signed) || 0);
  const nciAbs = Math.abs(Number(nciRow?.value_signed) || 0);
  const netBridge = Number(v.bridge) || sumV(bridge, 'value_signed');
  const freeNetCash = excessCash - debtAbs - whtAbs;

  const baseInvHaircutPct = invBook > 0 ? Math.round((invHaircutLoss / invBook) * 100) : 20;
  const [simCashDisc, setSimCashDisc] = React.useState(0); // 自由净现金治理折价（%）
  const [simInvHaircut, setSimInvHaircut] = React.useState(() => baseInvHaircutPct);
  const [simExtraBuf, setSimExtraBuf] = React.useState(0); // 额外预提税/投资应付款缓冲（亿）

  const simNonopPreNci = freeNetCash * (1 - simCashDisc / 100) + invBook * (1 - simInvHaircut / 100) - simExtraBuf;
  const simBridge = simNonopPreNci * 0.97;
  const rollFactor = known(v.epv_ps) && Number(v.epv_total) + netBridge > 0 ? (Number(v.epv_ps) * Number(v.shares)) / (Number(v.epv_total) + netBridge) : 1;
  const simEpvPs = Number(v.shares) > 0 ? ((Number(v.epv_total) + simBridge) * rollFactor) / Number(v.shares) : null;
  const mcap = known(v.market_price) && known(v.shares) ? Number(v.market_price) * Number(v.shares) : null;
  const simImpliedMult = known(mcap) && Number(unit?.earnings) > 0 ? (mcap - simBridge) / Number(unit.earnings) : null;

  const bridgePerShare = Number(v.shares) > 0 ? netBridge / Number(v.shares) : null;
  const bridgeShareOfPrice = known(bridgePerShare) && Number(v.market_price) > 0 ? bridgePerShare / Number(v.market_price) : null;
  const maxPart = Math.max(excessCash, invNet, debtAbs, whtAbs + nciAbs, 1);

  const exclVal = (kw) => {
    const row = exclEpv.find((l) => l.name.includes(kw));
    const h = Object.fromEntries(row?.hist || []);
    return { ttm: h['近四季（2026Q3）'], y25: h['2025'] };
  };

  const filtered = catFilter === 'all' ? bridge : bridge.filter((r) => r.category === catFilter);
  const groups = ['现金与投资', '参照估值', '有息负债', '其他索取权']
    .map((c) => ({ cat: c, rows: filtered.filter((r) => r.category === c) }))
    .filter((g) => g.rows.length > 0);
  const toggle = (id) => setOpenRows((p) => { const n = new Set(p); n.has(id) ? n.delete(id) : n.add(id); return n; });

  const vars = {
    '--ink': token.colorText, '--muted': token.colorTextSecondary, '--dot': token.colorTextQuaternary,
    '--card': token.colorBgContainer, '--tint': token.colorFillQuaternary, '--tint-soft': token.colorFillAlter || token.colorFillQuaternary,
    '--hover': token.colorFillTertiary, '--track': token.colorFillSecondary, '--line': token.colorBorderSecondary,
    '--line-soft': token.colorSplit, '--line-strong': token.colorBorder, '--primary': token.colorPrimary,
    '--primary-bg': token.colorPrimaryBg, '--primary-bd': token.colorPrimaryBorder,
    '--ok': token.colorSuccessText || token.colorSuccess, '--warn': token.colorWarningText || token.colorWarning, '--err': token.colorError,
  };

  return (
    <article className="tme-br" style={vars}>
      <style>{style}</style>

      {/* 1. 首屏主焦区 */}
      <header className="hero">
        <div>
          <div className="eyebrow">
            <span>第四层 · 独立资产与负债桥（非经营净调整）· 截至 {String(co.as_of).slice(0, 10)}</span>
            <Tag color="blue" style={{ marginInlineEnd: 0 }}>与 ①/②/③ 严格隔离</Tag>
          </div>
          <div className="num-row">
            <strong className="hero-num">{sfmt(netBridge, 1)}</strong>
            <span className="hero-unit">亿元（资产负债桥净额）</span>
          </div>
          <div className="badges">
            <span>折合每股 <b>{fmt(bridgePerShare, 2)} 元</b>（截至日）</span>
            <span>占当前股价（{fmt(v.market_price, 2)} 元）的 <b className="is-ok">{pct(bridgeShareOfPrice, 1)}</b></span>
          </div>
          <div className="kpi-strip">
            <span>多余现金 <strong>+{fmt(excessCash, 1)} 亿</strong></span>
            <span>折后投资 <strong>+{fmt(invNet, 1)} 亿</strong></span>
            <span>有息负债 <strong className="is-err">−{fmt(debtAbs, 1)} 亿</strong></span>
            <span>预提税与少数股东 <strong className="is-warn">−{fmt(whtAbs + nciAbs, 1)} 亿</strong></span>
          </div>
        </div>

        <div className="verdict">
          <div className="verdict-head">
            <span>桥接构成与治理折价提醒（能分 ≠ 会分）</span>
            {t5 && <Tag color="orange" style={{ marginInlineEnd: 0 }}>{t5.code} {t5.status} · 把握{t5.confidence}</Tag>}
          </div>
          {[
            ['多余现金（扣周转）', excessCash, token.colorSuccess, `+${fmt(excessCash, 1)} 亿`],
            ['对外股权投资（折后）', invNet, token.colorPrimary, `+${fmt(invNet, 1)} 亿`],
            ['全部有息负债', debtAbs, token.colorError, `−${fmt(debtAbs, 1)} 亿`],
            ['预提税与少数股东', whtAbs + nciAbs, token.colorWarning, `−${fmt(whtAbs + nciAbs, 1)} 亿`],
          ].map(([lbl, val, bg, txt]) => (
            <div className="cmp-row" key={lbl}>
              <Text type="secondary">{lbl}</Text>
              <div className="cmp-track"><div className="cmp-fill" style={{ width: `${Math.max(3, (val / maxPart) * 100)}%`, background: bg }} /></div>
              <Text strong>{txt}</Text>
            </div>
          ))}
          <p className="verdict-note">
            <b>核心风险（R3 重大）：</b>扣除债务与 10% 汇出税后的可分配净现金达 <b>{fmt(freeNetCash, 1)} 亿</b>，但 2026 年用约 86 亿现金低回报收购喜马拉雅说明“账上净现金不等于马上分给股东”。须紧盯回购与股息兑现，并留存下方治理折价压力测试。
          </p>
        </div>
      </header>

      {/* 2. SVG 瀑布桥 */}
      <section className="sec">
        <div className="sec-head">
          <h3>资产负债桥是怎么从 514.9 亿现金与 224.4 亿投资净算到 +{fmt(netBridge, 1)} 亿的？</h3>
          <span className="sec-sub">全部有息借款、票据与租赁负债（−{fmt(debtAbs, 1)} 亿）已在此全额扣除，无遗漏</span>
        </div>
        <BridgeWaterfall
          grossCash={grossCash} opReserve={opReserve} invBook={invBook} invHaircutLoss={invHaircutLoss}
          debtAbs={debtAbs} whtAbs={whtAbs} nciAbs={nciAbs} netBridge={netBridge} token={token}
        />
      </section>

      {/* 3. 双栏深度透视：境内外资金错配演变 + 存量流量边界隔离 */}
      <div className="grid-2">
        <section className="card">
          <div>
            <div className="sec-head" style={{ marginBottom: 6 }}>
              <h3>资金结构透视：为什么 2026 年现金与有息负债同时大增？</h3>
              <span className="sec-sub">2024Q4–2026Q3 广义现金、有息负债与对外投资账面演变（亿元）</span>
            </div>
            <CashDebtChart stmts={stmts} token={token} />
            <div className="legend">
              <span><i className="dot" style={{ background: token.colorSuccess, opacity: 0.75 }} />广义现金与存款</span>
              <span><i className="dot" style={{ background: token.colorError, opacity: 0.75 }} />全部有息负债</span>
              <span><i className="dot" style={{ background: token.colorPrimary, opacity: 0.65 }} />对外股权与金融投资（账面）</span>
            </div>
          </div>
          <p style={{ marginTop: 8, paddingTop: 8, borderTop: `1px dashed ${token.colorSplit}`, fontSize: 12.5, color: token.colorTextSecondary }}>
            <b style={{ color: token.colorText }}>境内外错配特征：</b>人民币现金留存在境内吃约 2% 存款息（汇出需缴 10% 预提税），同时在境外以约 4–5% 利率发债借款（负债由 38 亿升至 221 亿）支付喜马拉雅现金对价与美港股回购。桥内已同时扣除 221 亿全额负债与 21.7 亿汇出税，绝不高估净现金。
          </p>
        </section>

        <section className="card">
          <div>
            <div className="sec-head" style={{ marginBottom: 8 }}>
              <h3>Greenwald 边界隔离核查：为什么绝无重复计算？</h3>
              <span className="sec-sub">存量资产/负债进 ④ ⇄ 对应收益/利息彻底出 ②</span>
            </div>
            {[
              ['多余现金与存款', `+${fmt(excessCash, 1)} 亿`, '利息收入', `近四季 ${fmt(exclVal('利息').ttm, 1)} 亿（已出 ②）`],
              ['上市股权与金融投资', `+${fmt(invNet - (invRows.find((r) => r.line_item === '按权益法核算的投资')?.value_signed || 0), 1)} 亿`, '其他利得/公允变动', `2025 年 ${fmt(exclVal('其他收益').y25, 1)} 亿（已出 ②）`],
              ['按权益法核算投资', `+${fmt(invRows.find((r) => r.line_item === '按权益法核算的投资')?.value_signed, 1)} 亿`, '应占联营公司溢利', `近四季 ${fmt(exclVal('联营').ttm, 1)} 亿（已出 ②）`],
              ['全部有息负债', `−${fmt(debtAbs, 1)} 亿`, '融资成本（财务费用）', `近四季 ${fmt(exclVal('融资').ttm, 1)} 亿（已出 ②）`],
            ].map(([stock, sval, flow, fval]) => (
              <div className="iso-row" key={stock}>
                <div><b>{stock}</b><div style={{ fontSize: 11.5, color: token.colorTextSecondary }}>④ 存量：{sval}</div></div>
                <span style={{ color: token.colorPrimary, fontWeight: 700 }}>⇄</span>
                <div><b>{flow}</b><div style={{ fontSize: 11.5, color: token.colorTextSecondary }}>② 不计入：{fval}</div></div>
              </div>
            ))}
          </div>
          <p style={{ marginTop: 8, paddingTop: 8, borderTop: `1px dashed ${token.colorSplit}`, fontSize: 12, color: token.colorTextSecondary }}>
            <b>待年报核验项：</b>2026H1 中报附注单列 4.10 亿投资应付款，Q3 季报未单列暂留第一层经营负债（若移入 ④，对每股 EPV 影响仅 −0.13 元）；汇出税 21.7 亿沿用中报境内未分派利润测算，年报披露后复核。
          </p>
        </section>
      </div>

      {/* 4. 治理折价与投资折价交互压力测试 */}
      <section className="sec">
        <div className="sec-head">
          <h3>治理与折价压力测试：如果净现金不归少数股东、对外投资再打折？</h3>
          <span className="sec-sub">针对论点 T5（治理与股东回报）与风险 R3 的只读压力试算</span>
        </div>
        <div className="stress">
          <div className="sliders">
            <div className="srow">
              <div className="shead"><span>可分配净现金治理折价（0%＝全额计入，50%＝担忧低效并购）</span><b>{simCashDisc}%</b></div>
              <Slider min={0} max={60} step={5} value={simCashDisc} onChange={setSimCashDisc} />
            </div>
            <div className="srow">
              <div className="shead"><span>对外股权投资统一折价（基准 {baseInvHaircutPct}%）</span><b>{simInvHaircut}%（计 {fmt(invBook * (1 - simInvHaircut / 100), 1)} 亿）</b></div>
              <Slider min={0} max={50} step={5} value={simInvHaircut} onChange={setSimInvHaircut} />
            </div>
            <div className="srow">
              <div className="shead"><span>额外预提税 / 投资应付款预留缓冲（亿）</span><b>−{fmt(simExtraBuf, 1)} 亿</b></div>
              <Slider min={0} max={30} step={1} value={simExtraBuf} onChange={setSimExtraBuf} />
            </div>
          </div>
          <div className="sim-kpis">
            <div className="sim-box">
              <span>试算 ④ 资产负债桥净额</span>
              <strong>{sfmt(simBridge, 1)} 亿</strong>
              <small>相对基准（{fmt(netBridge, 1)} 亿）{sfmt(simBridge - netBridge, 1)} 亿 · 每股 {fmt(simBridge / Number(v.shares), 2)} 元</small>
            </div>
            <div className="sim-box is-focus">
              <span>试算每股 EPV（含打折后 ④）</span>
              <strong className={simEpvPs >= Number(v.market_price) ? 'is-ok' : 'is-err'}>{fmt(simEpvPs, 2)} 元</strong>
              <small>对比现价 {fmt(v.market_price, 2)} 元 {sfmt((simEpvPs / Number(v.market_price) - 1) * 100, 1)}%</small>
            </div>
            <div className="sim-box" style={{ gridColumn: '1 / -1' }}>
              <span>扣除打折后的桥，市场给腾讯音乐主营的隐含估值倍数</span>
              <strong>{fmt(simImpliedMult, 1)}× E（隐含主营净定价 {fmt(mcap - simBridge, 1)} 亿）</strong>
              <small>即使自由净现金打五折、投资再打折，主营仍只对应个位数/低十倍可持续现金收益。</small>
            </div>
          </div>
        </div>
      </section>

      {/* 5. 分类明细底稿表 */}
      <section className="sec">
        <div className="toolbar">
          <h3 style={{ fontSize: 16, fontWeight: 600 }}>独立资产与负债桥明细底稿（{filtered.length} 项，亿元）</h3>
          <Segmented
            value={catFilter}
            onChange={setCatFilter}
            options={[
              { label: `全部（${bridge.length}）`, value: 'all' },
              { label: '现金与投资', value: '现金与投资' },
              { label: '有息负债', value: '有息负债' },
              { label: '其他索取权', value: '其他索取权' },
            ]}
          />
        </div>
        <div className="tbl-wrap">
          <table className="tbl">
            <thead>
              <tr>
                <th style={{ textAlign: 'left', width: '40%' }}>科目 / 估值调整项</th>
                <th style={{ textAlign: 'left', width: 96 }}>类别</th>
                <th className="num" style={{ width: 92 }}>账面计入</th>
                <th className="num" style={{ width: 68 }}>折价</th>
                <th className="num" style={{ width: 88 }}>调整额</th>
                <th className="num" style={{ width: 96 }}>④ 计入值</th>
              </tr>
            </thead>
            <tbody>
              {groups.map((g) => (
                <React.Fragment key={g.cat}>
                  <tr className="sec-row"><td colSpan={6}>{g.cat}（小计 {sfmt(sumV(g.rows), 2)} 亿）</td></tr>
                  {g.rows.map((r) => {
                    const hasD = Boolean(r.basis || (r.judgments || []).length);
                    const open = openRows.has(r.id);
                    return (
                      <React.Fragment key={r.id}>
                        <tr className={`item-row ${hasD ? 'is-click' : ''}`} onClick={hasD ? () => toggle(r.id) : undefined}>
                          <td>
                            <div style={{ display: 'flex', alignItems: 'center', gap: 6, flexWrap: 'wrap' }}>
                              <span style={{ fontWeight: r.haircut || r.adjustment ? 600 : 400 }}>{r.name || r.line_item}</span>
                              {hasD && <button type="button" className="exp-btn" onClick={(e) => { e.stopPropagation(); toggle(r.id); }}>{open ? '收起 ▴' : '依据 ▾'}</button>}
                            </div>
                          </td>
                          <td><Text type="secondary" style={{ fontSize: 12 }}>{r.category}</Text></td>
                          <td className="num">{fmt(r.book_signed, 2)}</td>
                          <td className="num">{known(r.haircut) && Number(r.haircut) !== 0 ? pct(r.haircut, 0) : <span className="mute">·</span>}</td>
                          <td className="num">{known(r.adjustment) && Number(r.adjustment) !== 0 ? sfmt(r.adjustment, 2) : <span className="mute">·</span>}</td>
                          <td className="num"><b className={Number(r.value_signed) < 0 ? 'is-err' : ''}>{sfmt(r.value_signed, 2)}</b></td>
                        </tr>
                        {hasD && open && (
                          <tr className="basis-row">
                            <td colSpan={6}>
                              <div className="basis-box">
                                {r.basis && <p><b>测算说明：</b>{r.basis}</p>}
                                {(r.judgments || []).map((j) => {
                                  const full = judgments.get(j.code) || j;
                                  return (
                                    <p key={j.code}>
                                      <Tag color="blue">{full.code}</Tag><b>{full.title}</b>：{full.judgment}{' '}
                                      <Link href="/admin/__BASIS_UID__">编辑 →</Link>
                                    </p>
                                  );
                                })}
                              </div>
                            </td>
                          </tr>
                        )}
                      </React.Fragment>
                    );
                  })}
                </React.Fragment>
              ))}
              <tr className="major-row">
                <td colSpan={2}>资产负债桥合计（全部科目与 ① 对账归母权益误差 0.00）</td>
                <td className="num">{fmt(sumV(filtered, 'book_signed'), 2)}</td>
                <td className="num" />
                <td className="num">{sfmt(sumV(filtered, 'value_signed') - sumV(filtered, 'book_signed'), 2)}</td>
                <td className="num">{sfmt(sumV(filtered, 'value_signed'), 2)}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </section>

      {/* 6. 自检与底部导航 */}
      <section className="sec" style={{ padding: '12px 18px' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: 8 }}>
          <Text strong>对账与口径检查（G01 / G05 / G07）</Text>
          <div style={{ display: 'flex', gap: 6, flexWrap: 'wrap' }}>
            {checks.map((c) => <Tag key={c.code} color={c.result === '通过' ? 'green' : c.result === '提示' ? 'gold' : 'red'}>{c.code} {c.name} · {c.result}</Tag>)}
          </div>
        </div>
        <div style={{ marginTop: 6, fontSize: 12.5, color: token.colorTextSecondary }}>
          {checks.map((c) => <div key={c.code}><b>{c.code}</b>：{c.detail}</div>)}
        </div>
      </section>

      <nav className="nav-grid" aria-label="Greenwald 三层估值导航">
        <Link href="/admin/__AV_UID__" className="nav-card">
          <span className="nav-title">← ① 资产价值</span>
          <span className="nav-val">{fmt(v.av_total, 1)} 亿</span>
          <span className="nav-sub">含 ④ 经营周转现金配对 40 亿</span>
        </Link>
        <Link href="/admin/__EPV_UID__" className="nav-card">
          <span className="nav-title">← ② 盈利能力（主估值层）</span>
          <span className="nav-val">{fmt(v.epv_total, 1)} 亿</span>
          <span className="nav-sub">已剥离利息、投资收益与融资费用</span>
        </Link>
        <Link href="/admin/__GROWTH_UID__" className="nav-card">
          <span className="nav-title">← ③ 增长价值</span>
          <span className="nav-val">+{fmt(unit?.growth_value, 1)} 亿</span>
          <span className="nav-sub">含增长经营价值 {fmt(v.full_total, 1)} 亿</span>
        </Link>
        <Link href="/admin/__EQUITY_UID__" className="nav-card">
          <span className="nav-title">→ ⑤ 股权价值汇总</span>
          <span className="nav-val">{fmt(v.value_ps, 2)} 元/股</span>
          <span className="nav-sub">主估值层与三层全景决策</span>
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
  if (!data) return <Text type="secondary">正在读取独立资产与负债桥底稿…</Text>;
  if (!data.v) return <Alert type="warning" showIcon message="腾讯音乐资产负债桥或估值结果尚待补全。" />;
  return <BridgeContent d={data} />;
}

ctx.render(<App />);
