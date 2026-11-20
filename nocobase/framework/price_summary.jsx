// 现价与三层价值（资产价值、盈利能力价值、含增长价值）；isBase＝主估值层。只展示，不计算。
function PriceSummary({ price, scenarios, unit = '港元', date }) {
  const valid = (v) => v !== null && v !== undefined && v !== '' && Number.isFinite(Number(v));
  const fmtPrice = (v) => valid(v) ? Number(v).toFixed(2) : '—';
  const palettes = { '资产价值': { ink: '#5b6472', bg: '#f4f5f7', border: '#d9dde3', icon: '▤', hint: '第一层' }, '盈利能力价值': { ink: '#1d4ed8', bg: '#edf4ff', border: '#7da8f5', icon: '◆', hint: '第二层' }, '含增长价值': { ink: '#1f7a4d', bg: '#eefaf3', border: '#b7e4c7', icon: '↗', hint: '第三层' } };
  const ordered = scenarios.slice();
  const base = ordered.find((s) => s.isBase);
  const gap = valid(price) && valid(base?.value) && Number(base.value) > 0 ? Number(price) / Number(base.value) - 1 : null;
  const points = ordered.filter((s) => valid(s.value));
  const prices = [...points.map((s) => Number(s.value)), ...(valid(price) ? [Number(price)] : [])];
  const lo = prices.length ? Math.min(...prices) * 0.85 : 0;
  const hi = prices.length ? Math.max(...prices) * 1.08 : 1;
  const x = (v) => 68 + (Number(v) - lo) / Math.max(hi - lo, 0.01) * 664;
  return <section className="vi-price-summary" aria-label="现价与三层价值对比" style={{ marginBottom: 16, color: '#172b46' }}>
    <style>{`.vi-price-summary .vi-price-grid{display:grid;grid-template-columns:1.05fr 1fr 1.14fr 1fr;gap:12px}.vi-price-summary .vi-price-card{border-radius:12px;padding:18px 16px;min-width:0}.vi-price-summary .vi-price-number{font-size:30px;font-weight:700;line-height:1.35;letter-spacing:-.8px;font-variant-numeric:tabular-nums}.vi-price-summary .vi-price-unit{font-size:12px;font-weight:400;letter-spacing:0;margin-left:5px;white-space:nowrap}.vi-price-summary .vi-price-caption{font-size:12px;margin-top:9px;line-height:1.5}.vi-price-summary .vi-price-verdict{display:flex;align-items:baseline;gap:10px;flex-wrap:wrap;margin:16px 0 4px}.vi-price-summary .vi-price-scale{width:100%;display:block;height:auto}@media(max-width:1100px){.vi-price-summary .vi-price-grid{grid-template-columns:1fr 1fr}.vi-price-summary .vi-price-number{font-size:28px}.vi-price-summary .vi-price-scale{min-width:560px}}`}</style>
    <div className="vi-price-grid">
      <div className="vi-price-card" style={{ background: '#152b46', color: '#fff', border: '1px solid #152b46' }}>
        <div style={{ fontSize: 13, color: '#c4d3e4', marginBottom: 10 }}>● 当前市场价</div>
        <div className="vi-price-number">{fmtPrice(price)}<span className="vi-price-unit">{unit} / 股</span></div>
        <div className="vi-price-caption" style={{ color: '#c4d3e4' }}>市场报价 · {date || '日期未知'}</div>
      </div>
      {ordered.map((s) => {
        const p = palettes[s.name] || palettes['盈利能力价值'];
        const primary = !!s.isBase;
        return <div key={s.name} className="vi-price-card" style={{ background: p.bg, border: `${primary ? 2 : 1}px solid ${p.border}`, color: p.ink }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', gap: 6, fontSize: 13, marginBottom: 10 }}>
            <span>{p.icon} {s.name}</span><span style={{ fontSize: 10, background: primary ? p.ink : 'transparent', color: primary ? '#fff' : p.ink, padding: '2px 6px', borderRadius: 4 }}>{primary ? '主估值层' : p.hint}</span>
          </div>
          <div className="vi-price-number" style={{ fontSize: primary ? 34 : undefined }}>{fmtPrice(s.value)}<span className="vi-price-unit">{unit} / 股</span></div>
        </div>;
      })}
    </div>
    <div className="vi-price-verdict">
      <strong style={{ fontSize: 18, color: '#1d4ed8' }}>{gap === null ? '现价与主估值层暂无法比较' : `现价比${base.name}${gap <= 0 ? '低' : '高'} ${(Math.abs(gap) * 100).toFixed(1)}%`}</strong>
      <span style={{ color: '#6b7788', fontSize: 12 }}>三层从保守到乐观：资产值多少、不增长值多少、算上增长值多少</span>
    </div>
    {points.length > 1 && valid(price) ? <div style={{ overflowX: 'auto' }}><svg className="vi-price-scale" viewBox="0 0 800 112" role="img" aria-label={`价格位置，现价 ${fmtPrice(price)}，${points.map((s) => s.name + '估值 ' + fmtPrice(s.value)).join('，')}，单位${unit}`}>
      <line x1="52" x2="748" y1="52" y2="52" stroke="#e7edf5" strokeWidth="8" strokeLinecap="round" />
      <line x1={x(Math.min(...points.map((s) => Number(s.value))))} x2={x(Math.max(...points.map((s) => Number(s.value))))} y1="52" y2="52" stroke="#c9d8f4" strokeWidth="8" strokeLinecap="round" />
      {points.map((s, i) => <g key={s.name}><circle cx={x(s.value)} cy="52" r={s.isBase ? 7 : 5} fill={(palettes[s.name] || palettes['盈利能力价值']).ink} stroke="white" strokeWidth="2" /><text x={x(s.value)} y={i % 2 ? 98 : 81} textAnchor="middle" fontSize="12" fill={(palettes[s.name] || palettes['盈利能力价值']).ink}>{s.name} {fmtPrice(s.value)}</text></g>)}
      <line x1={x(price)} x2={x(price)} y1="29" y2="59" stroke="#152b46" strokeWidth="2" strokeDasharray="3 3" />
      <path d={`M ${x(price)-5} 23 L ${x(price)+5} 23 L ${x(price)} 30 Z`} fill="#152b46" />
      <text x={x(price)} y="16" textAnchor="middle" fontWeight="700" fontSize="12" fill="#152b46">现价 {fmtPrice(price)}</text>
    </svg></div> : null}
  </section>;
}
