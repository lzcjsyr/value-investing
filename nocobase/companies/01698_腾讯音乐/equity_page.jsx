const { React, antd } = ctx.libs;
const { Alert, Typography, Tag, Tooltip, theme } = antd;
const { Text, Link } = Typography;

const known = (x) => x !== null && x !== undefined && x !== '' && Number.isFinite(Number(x));
const fmt = (x, d = 2) => (known(x) ? Number(x).toLocaleString('zh-CN', { minimumFractionDigits: d, maximumFractionDigits: d }) : '—');
const sfmt = (x, d = 2) => (!known(x) ? '—' : (Number(x) > 0 ? '+' : '') + fmt(x, d));
const pct = (x, d = 1) => (known(x) ? `${(Number(x) * 100).toFixed(d)}%` : '—');
const bySort = (k) => (a, b) => (a[k] ?? 0) - (b[k] ?? 0) || a.id - b.id;

async function list(name, filter, appends = [], pageSize = 300) {
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
  const [values, units, items, checks, judgments, theses, risks] = await Promise.all([
    list('vi_gw_value', scope),
    list('vi_gw_unit', scope),
    list('vi_bs_item', scope, [], 200),
    list('vi_check', scope),
    list('vi_judgment', scope, [], 200),
    list('vi_thesis', scope),
    list('vi_risk', scope),
  ]);
  return {
    co, v: values[0], unit: units.find((u) => u.business_code === 'B1') || units[0],
    items, checks: checks.sort(bySort('id')),
    jLayer: judgments.find((j) => j.code === 'J-LAYER'),
    theses: theses.sort((a, b) => String(a.code).localeCompare(String(b.code))),
    risks: risks.sort((a, b) => String(a.code).localeCompare(String(b.code))),
  };
}

// 求解买价对应的零增长隐含回报 r，使 (E/r + bridge) * (1+r)^elapsed / shares = price
function solveEpvIrr(e, bridge, shares, elapsed, price) {
  if (![e, bridge, shares, price].every(known) || e <= 0 || shares <= 0 || price <= 0) return null;
  const f = (r) => ((e / r + bridge) * Math.pow(1 + r, elapsed)) / shares;
  let lo = 0.001, hi = 1.0;
  if (f(lo) < price || f(hi) > price) return null;
  for (let i = 0; i < 50; i++) {
    const mid = (lo + hi) / 2;
    if (f(mid) > price) lo = mid;
    else hi = mid;
  }
  return (lo + hi) / 2;
}

const style = `
.tme-eq {max-width:1180px;margin:0 auto;padding:4px 4px 28px;color:var(--ink);font-variant-numeric:tabular-nums;line-height:1.55;container-type:inline-size}
.tme-eq * {box-sizing:border-box}
.tme-eq h2,.tme-eq h3,.tme-eq p {margin:0}
.tme-eq .hero {display:grid;grid-template-columns:minmax(0,1.15fr) minmax(0,1fr);gap:20px;padding:20px 24px;background:var(--tint);border:1px solid var(--line);border-radius:12px;align-items:center}
.tme-eq .eyebrow {font-size:13px;color:var(--muted);font-weight:500;display:flex;align-items:center;flex-wrap:wrap;gap:8px}
.tme-eq .num-row {display:flex;align-items:baseline;gap:10px;margin:6px 0 8px;flex-wrap:wrap}
.tme-eq .hero-num {font-size:clamp(34px,4.8cqw,48px);font-weight:700;letter-spacing:-1.4px;line-height:1.12;color:var(--ink)}
.tme-eq .hero-hkd {font-size:20px;font-weight:600;color:var(--primary)}
.tme-eq .badges {display:flex;flex-wrap:wrap;gap:6px 14px;font-size:13.5px;color:var(--muted)}
.tme-eq .badges b {color:var(--ink);font-weight:600}
.tme-eq .kpi-strip {margin-top:12px;padding-top:10px;border-top:1px dashed var(--line);display:flex;flex-wrap:wrap;gap:8px 18px;font-size:13px;color:var(--muted)}
.tme-eq .kpi-strip strong {color:var(--ink);font-weight:700}
.tme-eq .verdict {background:var(--card);border:1px solid var(--line);border-left:4px solid var(--ok);border-radius:10px;padding:14px 16px}
.tme-eq .verdict-head {font-size:13px;font-weight:600;color:var(--ok);margin-bottom:8px;display:flex;justify-content:space-between;align-items:center;gap:8px;flex-wrap:wrap}
.tme-eq .verdict p {font-size:12.5px;color:var(--muted);line-height:1.6}
.tme-eq .verdict p + p {margin-top:6px}
.tme-eq .verdict b {color:var(--ink)}
.tme-eq .sec {margin-top:16px;background:var(--card);border:1px solid var(--line);border-radius:12px;padding:16px 20px}
.tme-eq .sec-head {display:flex;justify-content:space-between;align-items:baseline;flex-wrap:wrap;gap:6px 16px;margin-bottom:12px}
.tme-eq .sec-head h3 {font-size:15.5px;font-weight:600}
.tme-eq .sec-sub {font-size:12.5px;color:var(--muted)}
.tme-eq .ladder-svg {display:block;width:100%;min-width:680px;height:auto}
.tme-eq .grid-2 {display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:16px;margin-top:16px}
.tme-eq .card {background:var(--card);border:1px solid var(--line);border-radius:12px;padding:16px 20px;display:flex;flex-direction:column;justify-content:space-between}
.tme-eq .tbl-wrap {overflow-x:auto;border:1px solid var(--line);border-radius:10px}
.tme-eq table.tbl {width:100%;border-collapse:collapse;font-size:13px}
.tme-eq .tbl th {background:var(--tint);color:var(--muted);font-weight:600;font-size:12px;padding:9px 10px;border-bottom:1px solid var(--line);white-space:nowrap}
.tme-eq .tbl td {padding:8px 10px;border-bottom:1px solid var(--line-soft);vertical-align:middle}
.tme-eq .tbl th.num,.tme-eq .tbl td.num {text-align:right;white-space:nowrap}
.tme-eq .tbl tr.is-main td {background:var(--primary-bg);font-weight:700}
.tme-eq .tbl tr.is-main td:first-child {box-shadow:inset 4px 0 0 var(--primary)}
.tme-eq .tbl tr.is-now td {background:var(--ok-bg);font-weight:700}
.tme-eq .stress-card {padding:9px 12px;border:1px solid var(--line-soft);border-radius:9px;background:var(--tint-soft);margin-bottom:8px;display:flex;justify-content:space-between;align-items:center;gap:12px;flex-wrap:wrap}
.tme-eq .stress-card:last-child {margin-bottom:0}
.tme-eq .chk-grid {display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:8px;margin-top:10px}
.tme-eq .chk-pill {padding:7px 10px;border:1px solid var(--line-soft);border-radius:8px;background:var(--tint-soft);font-size:12px}
.tme-eq .nav-grid {display:grid;grid-template-columns:repeat(4,minmax(0,1fr));gap:12px;margin-top:16px}
.tme-eq .nav-card {display:flex;flex-direction:column;justify-content:space-between;gap:5px;padding:12px 14px;background:var(--card);border:1px solid var(--line);border-radius:10px;text-decoration:none;color:var(--ink)}
.tme-eq .nav-card:hover {border-color:var(--primary);background:var(--tint-soft)}
.tme-eq .nav-title {font-size:13px;font-weight:600;color:var(--primary)}
.tme-eq .nav-val {font-size:18px;font-weight:700;color:var(--ink)}
.tme-eq .nav-sub {font-size:11.5px;color:var(--muted)}
.tme-eq .is-ok {color:var(--ok)}
.tme-eq .is-warn {color:var(--warn)}
.tme-eq .is-err {color:var(--err)}
@container (max-width:900px) {.tme-eq .hero,.tme-eq .grid-2{grid-template-columns:1fr}.tme-eq .chk-grid,.tme-eq .nav-grid{grid-template-columns:repeat(2,minmax(0,1fr))}}
@container (max-width:520px) {.tme-eq .chk-grid,.tme-eq .nav-grid{grid-template-columns:1fr}}
`;

// 三层堆叠估值解剖图：④ 资产负债桥（基座）＋ 各层经营价值，叠加现价竖线
function ThreeLayerChart({ v, fx, rollFactor, token }) {
  const shares = Number(v.shares) || 1;
  const brPs = (Number(v.bridge) * rollFactor) / shares;
  const avOpsPs = (Number(v.av_total) * rollFactor) / shares;
  const epvOpsPs = (Number(v.epv_total) * rollFactor) / shares;
  const growthOpsPs = ((Number(v.full_total) - Number(v.epv_total)) * rollFactor) / shares;
  const mp = Number(v.market_price) || 0;
  const maxX = Math.max(Number(v.full_ps) || 0, Number(v.epv_ps) || 0, mp, 1) * 1.18;

  const rows = [
    { key: '资产价值', label: '① 资产价值层（挤水分重估底线）', total: Number(v.av_ps), segs: [[brPs, token.colorInfoActive || '#13c2c2', '④ 桥'], [avOpsPs, token.colorTextTertiary, '① 经营 AV']] },
    { key: '盈利能力价值', label: '② 盈利能力层（零增长 · 主估值层）', total: Number(v.epv_ps), segs: [[brPs, token.colorInfoActive || '#13c2c2', '④ 桥'], [epvOpsPs, token.colorPrimary, '② 经营 EPV']] },
    { key: '含增长价值', label: '③ 含增长层（10年优势期参照）', total: Number(v.full_ps), segs: [[brPs, token.colorInfoActive || '#13c2c2', '④ 桥'], [epvOpsPs, token.colorPrimary, '② 经营 EPV'], [growthOpsPs, token.colorSuccess, '③ 增长']] },
  ];

  const W = 940, H = 206, pL = 218, pR = 128, pT = 32, rowH = 48, barH = 24;
  const cW = W - pL - pR;
  const xOf = (val) => pL + (Math.max(0, val) / maxX) * cW;
  const xPrice = xOf(mp);

  return (
    <div style={{ width: '100%', overflowX: 'auto' }}>
      <svg className="ladder-svg" viewBox={`0 0 ${W} ${H}`} role="img" aria-label="三层股权价值构成与现价对比图">
        {/* 刻度网格 */}
        {[0, 15, 30, 45, 60].filter((t) => t <= maxX).map((t) => (
          <g key={t}>
            <line x1={xOf(t)} y1={pT - 6} x2={xOf(t)} y2={H - 22} stroke={token.colorSplit} strokeDasharray="3 3" />
            <text x={xOf(t)} y={H - 6} textAnchor="middle" fontSize="10.5" fill={token.colorTextTertiary}>{t} 元</text>
          </g>
        ))}

        {rows.map((r, idx) => {
          const y = pT + idx * rowH + 8;
          const isMain = v.value_layer === r.key;
          let acc = 0;
          return (
            <g key={r.key}>
              {isMain && <rect x={4} y={y - 7} width={W - 8} height={barH + 14} rx={8} fill={token.colorPrimaryBg} fillOpacity="0.6" />}
              <text x={14} y={y + 16} fontSize="12.5" fontWeight={isMain ? 700 : 500} fill={isMain ? token.colorPrimary : token.colorText}>
                {r.label}
              </text>
              {r.segs.map(([val, col, name], sIdx) => {
                const x1 = xOf(acc);
                const w = Math.max(val > 0.2 ? 3 : 0, xOf(acc + val) - x1);
                acc += val;
                return (
                  <g key={sIdx}>
                    <rect x={x1} y={y} width={w} height={barH} rx={sIdx === 0 ? 4 : 3} fill={col} fillOpacity={sIdx === 0 ? 0.65 : 0.85} />
                    {w > 54 && (
                      <text x={x1 + w / 2} y={y + 15.5} textAnchor="middle" fontSize="10.5" fontWeight="600" fill="#fff">
                        {name} {fmt(val, 1)}
                      </text>
                    )}
                  </g>
                );
              })}
              <text x={xOf(r.total) + 8} y={y + 16} fontSize="12.5" fontWeight="700" fill={isMain ? token.colorPrimary : token.colorText}>
                {fmt(r.total, 2)} 元{fx ? ` / ${fmt(r.total / fx, 1)} 港` : ''}
              </text>
            </g>
          );
        })}

        {/* 现价红线 */}
        {mp > 0 && (
          <g>
            <line x1={xPrice} y1={16} x2={xPrice} y2={H - 22} stroke={token.colorError} strokeWidth="2.2" strokeDasharray="5 3" />
            <rect x={xPrice - 74} y={2} width={148} height={19} rx={9} fill={token.colorError} />
            <text x={xPrice} y={14.5} textAnchor="middle" fontSize="11" fontWeight="700" fill="#fff">
              现价 {fmt(mp, 2)} 元{fx ? ` (${fmt(mp / fx, 1)}港)` : ''}
            </text>
          </g>
        )}
      </svg>
    </div>
  );
}

function EquityContent({ d }) {
  const { token } = theme.useToken();
  const { co, v, unit, items, checks, jLayer, theses, risks } = d;

  const fx = known(co.latest_fx) && Number(co.latest_fx) > 0 ? Number(co.latest_fx) : null;
  const toHkd = (rmb) => (known(rmb) && fx ? Number(rmb) / fx : null);
  const shares = Number(v.shares) || 1;
  const hurdle = Number(v.hurdle) || 0.06;
  const mp = Number(v.market_price) || 0;

  const baseEqEpv = Number(v.epv_total) + Number(v.bridge);
  const rollFactor = known(v.epv_ps) && baseEqEpv > 0 ? (Number(v.epv_ps) * shares) / baseEqEpv : 1;
  const elapsed = hurdle > 0 && rollFactor > 1 ? Math.log(rollFactor) / Math.log(1 + hurdle) : 0;

  const discount = known(v.value_ps) && Number(v.value_ps) > 0 ? mp / Number(v.value_ps) - 1 : null;
  const mcap = mp * shares;
  const impliedOps = mcap - Number(v.bridge);
  const impliedMult = Number(unit?.earnings) > 0 ? impliedOps / Number(unit.earnings) : null;

  // 第四层内部拆解，用于极端组合压力测试
  const bridge = items.filter((i) => i.role === '资产负债桥');
  const CASH_NAMES = new Set(['现金及现金等价物', '短期存款', '中长期存款', '短期投资']);
  const sumV = (rs, k = 'value_signed') => rs.reduce((s, r) => s + (Number(r[k]) || 0), 0);
  const grossCash = sumV(bridge.filter((i) => CASH_NAMES.has(i.line_item)), 'book_signed');
  const opReserve = Math.abs(Number(bridge.find((i) => i.name === '划给经营的周转现金')?.value_signed) || 0);
  const invBook = sumV(bridge.filter((i) => i.category === '现金与投资' && !CASH_NAMES.has(i.line_item) && i.name !== '划给经营的周转现金'), 'book_signed');
  const debtAbs = Math.abs(sumV(bridge.filter((i) => i.category === '有息负债')));
  const whtAbs = Math.abs(Number(bridge.find((i) => (i.name || '').includes('预提税'))?.value_signed) || 0);
  const freeNetCash = grossCash - opReserve - debtAbs - whtAbs;

  // 构建三层总表
  const layers = [
    { key: '资产价值', label: '① 资产价值（挤水分重估）', biz: v.av_total, bridge: v.bridge, eq: Number(v.av_total) + Number(v.bridge), ps: v.av_ps, irr: null, note: '轻资产底线，不代表业务盈利能力' },
    { key: '盈利能力价值', label: '② 盈利能力价值（零增长）', biz: v.epv_total, bridge: v.bridge, eq: baseEqEpv, ps: v.epv_ps, irr: v.irr_epv, note: '主估值层：不依赖增长假设' },
    { key: '含增长价值', label: '③ 含增长价值（10年优势期）', biz: v.full_total, bridge: v.bridge, eq: Number(v.full_total) + Number(v.bridge), ps: v.full_ps, irr: v.irr_full, note: '上行看涨期权，须待 T3/T4 兑现' },
  ];

  // 不同买价档位的隐含回报（以主估值层 EPV 基准）
  const epvPs = Number(v.epv_ps) || 0;
  const priceTiers = [
    { name: '主估值 9 折', price: epvPs * 0.9 },
    { name: '主估值 7 折（传统安全边际）', price: epvPs * 0.7 },
    { name: `当前现价（${v.market_date || ''}）`, price: mp, isNow: true },
    { name: '主估值 5 折（极深折价）', price: epvPs * 0.5 },
  ].map((t) => ({
    ...t,
    hkd: toHkd(t.price),
    mult: Number(unit?.earnings) > 0 ? (t.price * shares - Number(v.bridge)) / Number(unit.earnings) : null,
    irr: solveEpvIrr(Number(unit?.earnings), Number(v.bridge), shares, elapsed, t.price),
  }));

  // 多因素联合极端压力测试（验证最坏情况下是否亏钱）
  const baseE = Number(unit?.earnings) || 0;
  const baseRev = Number(unit?.revenue) || 349.06;
  const calcCombined = (eAdj, cashDiscPct, invHaircutPct, h) => {
    const br = (freeNetCash * (1 - cashDiscPct / 100) + invBook * (1 - invHaircutPct / 100)) * 0.97;
    const eq = eAdj / h + br;
    const ps = (eq * rollFactor) / shares;
    return { eq, ps, hkd: toHkd(ps), vsPrice: mp > 0 ? ps / mp - 1 : null };
  };
  const taxRate = 14.02 / 83.11;
  const eNoPpa = baseE - 6.3 * (1 - taxRate) * 0.97; // 收购摊销 0% 加回
  const eSoda = ((baseRev * 0.95 * 0.21 + 6.3) * (1 - taxRate)) * 0.97; // 收入-5%，核心OPM压至21%
  const eSodaNoPpa = ((baseRev * 0.95 * 0.21) * (1 - taxRate)) * 0.97;
  const stressCases = [
    { title: '组合一 · 汽水冲击（OPM 21%）＋ 净现金打 5 折（T5 担忧）', desc: '毛利率跌至 40% 红线、自由现金只按一半计价、门槛 6%', res: calcCombined(eSoda, 50, 20, 0.06) },
    { title: '组合二 · 极保守会计（PPA 0%）＋ 外资高门槛（10%）', desc: '不加回任何收购摊销，同时要求 10% 零增长年化回报', res: calcCombined(eNoPpa, 0, 20, 0.10) },
    { title: '组合三 · 四重齐发（汽水冲击 ＋ PPA 0% ＋ 现金 5 折 ＋ 8% 门槛）', desc: '经营承压、不加回摊销、治理打折与较高回报要求同时发生', res: calcCombined(eSodaNoPpa, 50, 30, 0.08) },
  ];

  const gChecks = checks.filter((c) => c.code.startsWith('G'));
  const cWarns = checks.filter((c) => !c.code.startsWith('G') && c.result !== '通过');
  const majorRisks = risks.filter((r) => r.level === '重大');

  const vars = {
    '--ink': token.colorText, '--muted': token.colorTextSecondary, '--card': token.colorBgContainer,
    '--tint': token.colorFillQuaternary, '--tint-soft': token.colorFillAlter || token.colorFillQuaternary,
    '--line': token.colorBorderSecondary, '--line-soft': token.colorSplit, '--primary': token.colorPrimary,
    '--primary-bg': token.colorPrimaryBg, '--primary-bd': token.colorPrimaryBorder,
    '--ok': token.colorSuccessText || token.colorSuccess, '--ok-bg': token.colorSuccessBg,
    '--warn': token.colorWarningText || token.colorWarning, '--err': token.colorError,
  };

  return (
    <article className="tme-eq" style={vars}>
      <style>{style}</style>

      {/* 1. 首屏最终估值决策区 */}
      <header className="hero">
        <div>
          <div className="eyebrow">
            <span>第五层 · 股权价值与投资决策总览 · 截至 {String(v.as_of).slice(0, 10)}</span>
            <Tag color="blue" style={{ marginInlineEnd: 0 }}>主估值层：{v.value_layer}</Tag>
            <Tag color="default" style={{ marginInlineEnd: 0 }}>统一门槛 {pct(hurdle, 1)}</Tag>
          </div>
          <div className="num-row">
            <strong className="hero-num">{fmt(v.value_ps, 2)} 元</strong>
            {fx && <span className="hero-hkd">≈ {fmt(toHkd(v.value_ps), 2)} 港元/股</span>}
          </div>
          <div className="badges">
            <span>现价（{v.market_date}）<b>{fmt(mp, 2)} 元</b>{known(co.latest_price_raw) ? `（${fmt(co.latest_price_raw, 2)} 港元 × ${fmt(fx, 4)}）` : ''}</span>
            <span>股本代理 <b>{fmt(shares, 2)} 亿股</b></span>
          </div>
          <div className="kpi-strip">
            <span>安全边际 <strong className={discount !== null && discount <= 0 ? 'is-ok' : 'is-warn'}>{discount !== null ? (discount <= 0 ? `折价 ${pct(-discount, 1)}` : `溢价 ${pct(discount, 1)}`) : '—'}</strong></span>
            <span>主层隐含年化回报 <strong className={Number(v.implied_irr) >= hurdle ? 'is-ok' : 'is-err'}>{pct(v.implied_irr, 1)}</strong></span>
            <span>市场隐含主营倍数 <strong>{fmt(impliedMult, 1)}× E</strong></span>
          </div>
        </div>

        <div className="verdict">
          <div className="verdict-head">
            <span>Greenwald 三层落点裁决</span>
            <Tag color={mp <= epvPs ? 'green' : 'orange'} style={{ marginInlineEnd: 0 }}>
              {mp <= epvPs ? '落于 ② 之下：不为增长付钱' : '落于 ② 之上：已计入部分增长'}
            </Tag>
          </div>
          <p>
            <b>为什么选第二层（盈利能力价值）作主估值？</b>
            {co.layer_reason || jLayer?.judgment}
          </p>
          <p>
            <b>当下赔率：</b>现价（{fmt(mp, 2)} 元 / {fmt(co.latest_price_raw, 2)} 港元）较零增长 EPV（{fmt(epvPs, 2)} 元）折价 <b>{pct(-discount, 1)}</b>，扣除 ④ 桥后市场仅为主营付 <b>{fmt(impliedMult, 1)}× E</b>，不依赖增长即可获得 <b>{pct(v.irr_epv, 1)}</b> 隐含年化回报；第三层增长（+{fmt(Number(v.full_ps) - epvPs, 2)} 元）属免费看涨期权。
          </p>
        </div>
      </header>

      {/* 2. 三层堆叠估值解剖图 */}
      <section className="sec">
        <div className="sec-head">
          <h3>三层每股股权价值构成与现价落点（元/股 · 已滚算至今，附港元折算）</h3>
          <span className="sec-sub">三层本身即“保守底线 → 零增长基准 → 含增长乐观”，不再另设情景</span>
        </div>
        <ThreeLayerChart v={v} fx={fx} rollFactor={rollFactor} token={token} />
      </section>

      {/* 3. 从经营价值到每股的完整对账表 */}
      <section className="sec">
        <div className="sec-head">
          <h3>三层汇总对账表（截至 {String(v.as_of).slice(0, 10)} → 按 {pct(hurdle, 1)} 滚算至今）</h3>
          <span className="sec-sub">第一层按实务做经营资产挤水分重估（不强求重建成本），与 ② 对比验证护城河；④ 已全额扣除 221 亿有息负债</span>
        </div>
        <div className="tbl-wrap">
          <table className="tbl">
            <thead>
              <tr>
                <th style={{ textAlign: 'left' }}>估值层</th>
                <th className="num">经营价值（亿）</th>
                <th className="num">＋ ④ 桥（亿）</th>
                <th className="num">＝ 股权价值（亿）</th>
                <th className="num">每股（人民币）</th>
                <th className="num">每股（港元）</th>
                <th className="num">现价相对该层</th>
                <th className="num">隐含年化回报</th>
              </tr>
            </thead>
            <tbody>
              {layers.map((r) => {
                const rel = known(r.ps) && Number(r.ps) > 0 ? mp / Number(r.ps) - 1 : null;
                const isMain = r.key === v.value_layer;
                return (
                  <tr key={r.key} className={isMain ? 'is-main' : ''}>
                    <td>
                      <div>{r.label}{isMain && <Tag color="blue" style={{ marginLeft: 6 }}>主估值层</Tag>}</div>
                      <div style={{ fontSize: 11.5, color: token.colorTextSecondary, fontWeight: 400 }}>{r.note}</div>
                    </td>
                    <td className="num">{fmt(r.biz, 1)}</td>
                    <td className="num">+{fmt(r.bridge, 1)}</td>
                    <td className="num">{fmt(r.eq, 1)}</td>
                    <td className="num"><b>{fmt(r.ps, 2)} 元</b></td>
                    <td className="num">{fx ? `${fmt(toHkd(r.ps), 2)} 港` : '—'}</td>
                    <td className="num"><span className={rel !== null && rel <= 0 ? 'is-ok' : 'is-warn'}>{sfmt(rel !== null ? rel * 100 : null, 1)}%</span></td>
                    <td className="num"><span className={known(r.irr) && Number(r.irr) >= hurdle ? 'is-ok' : ''}>{pct(r.irr, 1)}</span></td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
        {co.notes && <p style={{ marginTop: 8, fontSize: 12, color: token.colorTextSecondary }}><b>口径备忘：</b>{co.notes}</p>}
      </section>

      {/* 4. 双栏决策工具：不同买价赔率表 + 多因素联合极端压力测试 */}
      <div className="grid-2">
        <section className="card">
          <div>
            <div className="sec-head" style={{ marginBottom: 8 }}>
              <h3>不同买价（安全边际）对应的零增长回报</h3>
              <span className="sec-sub">按第二层 E {fmt(baseE, 1)} 亿 ＋ ④ 桥 {fmt(v.bridge, 1)} 亿计算</span>
            </div>
            <div className="tbl-wrap">
              <table className="tbl">
                <thead>
                  <tr>
                    <th style={{ textAlign: 'left' }}>价格档位</th>
                    <th className="num">人民币</th>
                    <th className="num">港元</th>
                    <th className="num">主营倍数</th>
                    <th className="num">零增长 IRR</th>
                  </tr>
                </thead>
                <tbody>
                  {priceTiers.map((t) => (
                    <tr key={t.name} className={t.isNow ? 'is-now' : ''}>
                      <td>{t.name}</td>
                      <td className="num">{fmt(t.price, 2)}</td>
                      <td className="num">{fx ? fmt(t.hkd, 2) : '—'}</td>
                      <td className="num">{fmt(t.mult, 1)}×</td>
                      <td className="num"><b className={t.irr >= hurdle ? 'is-ok' : 'is-err'}>{pct(t.irr, 1)}</b></td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
          {jLayer?.change_threshold && (
            <p style={{ marginTop: 10, paddingTop: 8, borderTop: `1px dashed ${token.colorSplit}`, fontSize: 12, color: token.colorTextSecondary }}>
              <b>切换主估值层条件（J-LAYER）：</b>{jLayer.change_threshold}
            </p>
          )}
        </section>

        <section className="card">
          <div>
            <div className="sec-head" style={{ marginBottom: 8 }}>
              <h3>极端组合压力测试：坏事同时发生，现价还安全吗？</h3>
              <span className="sec-sub">同时叠加经营承压、会计保守与治理折价，对比现价 {fmt(mp, 2)} 元</span>
            </div>
            {stressCases.map((s) => (
              <div className="stress-card" key={s.title}>
                <div style={{ flex: '1 1 220px' }}>
                  <div style={{ fontSize: 13, fontWeight: 600 }}>{s.title}</div>
                  <div style={{ fontSize: 11.5, color: token.colorTextSecondary }}>{s.desc}</div>
                </div>
                <div style={{ textAlign: 'right', whiteSpace: 'nowrap' }}>
                  <div style={{ fontSize: 17, fontWeight: 700 }} className={s.res.ps >= mp ? 'is-ok' : 'is-err'}>
                    {fmt(s.res.ps, 2)} 元{fx ? ` / ${fmt(s.res.hkd, 1)} 港` : ''}
                  </div>
                  <div style={{ fontSize: 11.5, color: token.colorTextSecondary }}>
                    相对现价 {sfmt(s.res.vsPrice * 100, 1)}%
                  </div>
                </div>
              </div>
            ))}
          </div>
          <p style={{ marginTop: 8, fontSize: 12, color: token.colorTextSecondary }}>
            <b>决策含义：</b>单一风险甚至双重风险同时落地时，估值仍高于现价；只有当<b>汽水冲击＋PPA归零＋现金五折＋高门槛</b>四重不利同时叠加，安全边际才会收窄至现价附近。
          </p>
        </section>
      </div>

      {/* 5. 投资决策前置体检：G01–G09 + 研究提示项 + 重大风险 */}
      <section className="sec">
        <div className="sec-head">
          <h3>决策前置体检：估值校验（G01–G09）与待处理研究提示</h3>
          <span className="sec-sub">通过 {gChecks.filter((c) => c.result === '通过').length} / {gChecks.length} 项估值校验 · 研究提醒 {cWarns.length} 项</span>
        </div>
        <div className="chk-grid">
          {gChecks.map((c) => (
            <Tooltip title={c.detail} key={c.code}>
              <div className="chk-pill">
                <Tag color={c.result === '通过' ? 'green' : c.result === '提示' ? 'gold' : 'red'} style={{ marginInlineEnd: 6 }}>{c.code} {c.result}</Tag>
                <b>{c.name}</b>
              </div>
            </Tooltip>
          ))}
        </div>
        {(cWarns.length > 0 || majorRisks.length > 0) && (
          <div style={{ marginTop: 12, paddingTop: 10, borderTop: `1px dashed ${token.colorSplit}`, fontSize: 12.5, color: token.colorTextSecondary }}>
            {cWarns.map((c) => (
              <div key={c.code} style={{ marginBottom: 4 }}>
                <Tag color="gold" style={{ marginInlineEnd: 6 }}>{c.code} {c.name}</Tag>{c.detail}
              </div>
            ))}
            <div style={{ marginTop: 6, display: 'flex', flexWrap: 'wrap', gap: 6, alignItems: 'center' }}>
              <b style={{ color: token.colorText }}>核心论点速览：</b>
              {theses.map((t) => <Tag key={t.id} color={t.status === '成立' ? 'green' : t.status === '存疑' ? 'orange' : 'default'}>{t.code} {t.status}</Tag>)}
              <b style={{ color: token.colorText, marginLeft: 8 }}>重大风险：</b>
              {majorRisks.map((r) => <Tag key={r.id} color="red">{r.code} {r.title}</Tag>)}
            </div>
          </div>
        )}
      </section>

      {/* 6. 底部四层回溯导航 */}
      <nav className="nav-grid" aria-label="Greenwald 估值分层导航">
        <Link href="/admin/__AV_UID__" className="nav-card">
          <span className="nav-title">① 资产价值（底线）</span>
          <span className="nav-val">{fmt(v.av_total, 1)} 亿</span>
          <span className="nav-sub">每股 {fmt(v.av_ps, 2)} 元 · 经营资产挤水分重估</span>
        </Link>
        <Link href="/admin/__EPV_UID__" className="nav-card">
          <span className="nav-title">② 盈利能力（主估值层）</span>
          <span className="nav-val">{fmt(v.epv_total, 1)} 亿</span>
          <span className="nav-sub">每股 {fmt(v.epv_ps, 2)} 元 · E {fmt(baseE, 1)} 亿 ÷ {pct(hurdle, 1)}</span>
        </Link>
        <Link href="/admin/__GROWTH_UID__" className="nav-card">
          <span className="nav-title">③ 增长价值（期权）</span>
          <span className="nav-val">+{fmt(unit?.growth_value, 1)} 亿</span>
          <span className="nav-sub">含增长每股 {fmt(v.full_ps, 2)} 元</span>
        </Link>
        <Link href="/admin/__BRIDGE_UID__" className="nav-card">
          <span className="nav-title">④ 独立资产与负债桥</span>
          <span className="nav-val">+{fmt(v.bridge, 1)} 亿</span>
          <span className="nav-sub">多余现金投资 − 有息负债 − 税费等</span>
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
  if (!data) return <Text type="secondary">正在读取三层股权价值与决策汇总…</Text>;
  if (!data.v) return <Alert type="info" showIcon message="腾讯音乐三层估值数据尚待补全。" />;
  return <EquityContent d={data} />;
}

ctx.render(<App />);
