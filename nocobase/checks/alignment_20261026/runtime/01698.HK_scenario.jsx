export default async function run(ctx) {
const COMPANY = '01698.HK';   // 由 build_bizviews.py 写入：只看这家公司
const EDIT_TAB = '明细（编辑）';
const { React } = ctx.libs;
const { useState, useRef } = React;
const { Tooltip, Alert, Empty, theme } = ctx.libs.antd;

async function listRows(name, filter, appends, pageSize = 500) {
  const resource = ctx.makeResource('MultiRecordResource');
  resource.setResourceName(name);
  resource.setPageSize?.(pageSize);
  if (filter) resource.setFilter?.(filter);
  if (appends) resource.setAppends?.(appends);
  await resource.refresh();
  return resource.getData() || [];
}

// 布局按页面实际可用宽度切换（不是窗口宽度）
function useWidth(ref) {
  const [w, setW] = useState(0);
  React.useLayoutEffect(() => {
    const el = ref.current;
    if (!el) return undefined;
    setW(el.getBoundingClientRect().width);
    const RO = typeof window !== 'undefined' ? window.ResizeObserver : undefined;
    if (!RO) return undefined;
    const ro = new RO((es) => setW(es[0].contentRect.width));
    ro.observe(el);
    return () => ro.disconnect();
  }, []);
  return w;
}

const usable = (s) => s !== null && s !== undefined && String(s).trim() !== '' && s !== '—';
const codeNum = (c) => Number(String(c || '').replace(/\D/g, '')) || 0;
const byCode = (a, b) => codeNum(a.code) - codeNum(b.code) || String(a.code).localeCompare(String(b.code));
const head = (s) => String(s || '').split(/[：:]/)[0];
const short = (s, n = 16) => { const x = head(String(s || '').replace(/^伪壁垒[：:]\s*/, '')).replace(/（[^）]*）/g, '').trim(); return x.length > n ? x.slice(0, n) + '…' : x; };
const clamp = (n) => ({ overflow: 'hidden', display: '-webkit-box', WebkitLineClamp: n, WebkitBoxOrient: 'vertical', wordBreak: 'break-all' });
const REF_KIND = { V: '产业链', M: '壁垒', T: '论点', B: '商业模式', J: '假设依据', R: '风险', K: '跟踪事项', W: '跟踪事项' };
const REF_RE = /(?<![A-Za-z0-9-])(V\d{1,2}|M\d{1,2}|T\d{1,2}|B\d{1,2}|R\d{1,2}|K\d{1,2}|W\d{1,2}|J-[A-Z0-9]+)(?![0-9])/g;

// 设计约定：颜色只出现在圆点、色条这类标记上（表示状态），文字一律用正文色；
// 字号三级：结论 22、卡片标题 15—16、正文 14；灰字只用于编号和辅助说明。
function useUI() {
  const { token: t } = theme.useToken();
  const orange = t.orange6 || '#d46b08';
  return {
    t,
    status: { 成立: t.colorSuccess, 观察: t.colorWarning, 存疑: orange, 证伪: t.colorError },
    verdict: { 真实壁垒: t.colorSuccess, 局部优势: t.colorPrimary, 待验证: t.colorWarning, 伪壁垒: t.colorTextQuaternary },
    level: { 重大: t.colorError, 重要: orange, 一般: t.colorTextQuaternary },
    fs: {
      h1: { fontSize: 22, fontWeight: 600, lineHeight: 1.45, color: t.colorTextHeading, margin: 0 },
      h2: { fontSize: 20, fontWeight: 600, lineHeight: 1.45, color: t.colorTextHeading, margin: 0 },
      title: { fontSize: 15, fontWeight: 600, lineHeight: 1.5, color: t.colorText },
      body: { fontSize: 14, lineHeight: 1.75, color: t.colorText },
      meta: { fontSize: 13, lineHeight: 1.6, color: t.colorTextSecondary },
      code: { fontSize: 12, color: t.colorTextTertiary, fontVariantNumeric: 'tabular-nums', letterSpacing: 0.3 },
    },
  };
}

function Dot({ color, size = 8 }) {
  const { t } = useUI();
  return <span style={{ width: size, height: size, borderRadius: '50%', flex: 'none', display: 'inline-block', background: color || t.colorBorder }} />;
}

// 状态：色点＋文字（文字用正文色，不靠颜色单独表意）
function Status({ label, color, size = 13, strong }) {
  const { t } = useUI();
  return (
    <span style={{ display: 'inline-flex', alignItems: 'center', gap: 6, fontSize: size, color: t.colorText, fontWeight: strong ? 600 : 400, whiteSpace: 'nowrap' }}>
      <Dot color={color} />{label}
    </span>
  );
}

function Tag({ children }) {
  const { t } = useUI();
  return <span style={{ fontSize: 12, lineHeight: '20px', padding: '0 7px', borderRadius: 4, background: t.colorFillTertiary, color: t.colorTextSecondary, whiteSpace: 'nowrap' }}>{children}</span>;
}

function Flag({ children }) {
  const { t } = useUI();
  return <span style={{ fontSize: 12, lineHeight: '20px', padding: '0 7px', borderRadius: 4, background: t.colorWarningBg, color: t.colorWarningText, whiteSpace: 'nowrap' }}>⚠ {children}</span>;
}

// 正文里的编号（V/M/T/B/R/K/J-）：悬停看标题
function RefText({ text, refs }) {
  const { t } = useUI();
  if (!usable(text)) return null;
  const parts = String(text).split(REF_RE);
  return (
    <>
      {parts.map((p, i) => {
        if (i % 2 === 0) return <React.Fragment key={i}>{p}</React.Fragment>;
        const kind = p.startsWith('J-') ? 'J' : p[0];
        const title = refs[p];
        return (
          <Tooltip key={i} title={title ? `${REF_KIND[kind]} ${p}：${title}` : `${REF_KIND[kind]} ${p}`}>
            <span style={{ color: t.colorPrimary, cursor: 'help', borderBottom: `1px dashed ${t.colorPrimaryBorder}` }}>{p}</span>
          </Tooltip>
        );
      })}
    </>
  );
}

function Label({ children }) {
  const { t } = useUI();
  return <div style={{ fontSize: 13, fontWeight: 600, color: t.colorTextHeading, marginBottom: 6 }}>{children}</div>;
}

// 详情里的一段：tone＝plain / pro（正方或证据，绿条）/ con（反方或反证，橙条）/ key（结论，浅底）
function Section({ label, text, refs, tone = 'plain', children }) {
  const { t, fs } = useUI();
  if (!children && !usable(text)) return null;
  const box = {
    plain: {},
    pro: { borderLeft: `3px solid ${t.colorSuccess}`, paddingLeft: 14 },
    con: { borderLeft: `3px solid ${t.colorWarning}`, paddingLeft: 14 },
    key: { background: t.colorFillQuaternary, borderRadius: 10, padding: '12px 16px' },
  }[tone];
  return (
    <div style={box}>
      <Label>{label}</Label>
      {children || <p style={{ ...fs.body, fontSize: 14.5, lineHeight: 1.8, margin: 0, whiteSpace: 'pre-wrap' }}><RefText text={text} refs={refs} /></p>}
    </div>
  );
}

function Attrs({ items }) {
  const { t } = useUI();
  const xs = items.filter((x) => x);
  return (
    <div style={{ display: 'grid', gridTemplateColumns: `repeat(${Math.min(xs.length, 4)}, minmax(0,1fr))`, gap: 16, padding: '14px 0',
                  borderTop: `1px solid ${t.colorSplit}`, borderBottom: `1px solid ${t.colorSplit}` }}>
      {xs.map(([k, v]) => (
        <div key={k} style={{ minWidth: 0 }}>
          <div style={{ fontSize: 12, color: t.colorTextSecondary, marginBottom: 4 }}>{k}</div>
          <div style={{ fontSize: 15, fontWeight: 600, color: t.colorText }}>{v || '—'}</div>
        </div>
      ))}
    </div>
  );
}

// 关联到的记录：编号＋标题（＋状态）
function LinkList({ label, items }) {
  const { t, fs } = useUI();
  if (!items || !items.length) return null;
  return (
    <div>
      <Label>{label}</Label>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
        {items.map((x, i) => (
          <div key={i} style={{ display: 'flex', gap: 10, alignItems: 'baseline' }}>
            {x.code ? <span style={{ ...fs.code, flex: 'none', minWidth: 30 }}>{x.code}</span> : null}
            <span style={{ ...fs.body, flex: 1, minWidth: 0 }}>{x.title}</span>
            {x.tag ? <Status label={x.tag} color={x.color} /> : null}
          </div>
        ))}
      </div>
    </div>
  );
}

function Facts({ facts }) {
  const { fs } = useUI();
  if (!facts || !facts.length) return null;
  return (
    <div>
      <Label>依据事实</Label>
      {facts.map((f) => (
        <div key={f.id} style={{ ...fs.meta, paddingLeft: 14, position: 'relative' }}>
          <span style={{ position: 'absolute', left: 2 }}>·</span>{f.title}
        </div>
      ))}
    </div>
  );
}

// 一排大数字：色点＋名称，数字是视觉重点
function Stats({ items }) {
  const { t } = useUI();
  return (
    <div style={{ display: 'flex', flexWrap: 'wrap', rowGap: 12 }}>
      {items.map((x, i) => (
        <div key={x.label} style={{ paddingRight: 28, marginRight: 28, borderRight: i < items.length - 1 ? `1px solid ${t.colorSplit}` : 'none', opacity: x.value ? 1 : 0.45 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 6, fontSize: 13, color: t.colorTextSecondary }}>{x.color ? <Dot color={x.color} /> : null}{x.label}</div>
          <div style={{ fontSize: 28, fontWeight: 600, lineHeight: 1.25, color: t.colorTextHeading, fontVariantNumeric: 'tabular-nums' }}>
            {x.value}<span style={{ fontSize: 14, fontWeight: 400, color: t.colorTextSecondary, marginLeft: 4 }}>{x.unit || ''}</span>
          </div>
        </div>
      ))}
    </div>
  );
}

// 需要处理的事项，集中在一处（不在卡片里到处标橙色）
function Notice({ items }) {
  const { t, fs } = useUI();
  if (!items || !items.length) return null;
  return (
    <div style={{ background: t.colorWarningBg, border: `1px solid ${t.colorWarningBorder}`, borderRadius: 10, padding: '12px 16px' }}>
      <div style={{ ...fs.title, fontSize: 14, marginBottom: 4 }}>⚠ 需要处理</div>
      {items.map((x, i) => <div key={i} style={{ ...fs.body, fontSize: 13.5, lineHeight: 1.7 }}>{x}</div>)}
    </div>
  );
}

// 卡片：白底细边；选中＝主色描边；muted＝弱化（例如伪壁垒）
function Card({ selected, onClick, children, style, accent, muted }) {
  const { t } = useUI();
  const base = selected ? t.colorPrimary : t.colorBorderSecondary;
  return (
    <div onClick={onClick}
         onMouseEnter={(e) => { if (!selected) e.currentTarget.style.borderColor = t.colorPrimaryBorderHover || t.colorPrimaryBorder; }}
         onMouseLeave={(e) => { if (!selected) e.currentTarget.style.borderColor = base; }}
         style={{ background: muted ? t.colorFillQuaternary : t.colorBgContainer, cursor: 'pointer', borderRadius: 12, minWidth: 0,
                  border: `1px solid ${base}`, boxShadow: selected ? `0 0 0 3px ${t.colorPrimaryBg}` : '0 1px 2px rgba(0,0,0,0.03)',
                  borderLeft: accent ? `4px solid ${accent}` : `1px solid ${base}`, transition: 'border-color .15s, box-shadow .15s', ...style }}>
      {children}
    </div>
  );
}

function DetailHead({ meta, title, children }) {
  const { fs } = useUI();
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
      <div style={fs.meta}>{meta}</div>
      <h2 style={fs.h2}>{title}</h2>
      {children}
    </div>
  );
}

// 页面骨架：小标题 → 一句话结论 → 大数字 → 需要处理 → 图（左）＋详情（右；不够宽时在图下方，选中后滚过去）
function Shell({ eyebrow, headline, hint, stats, notice, main, detail, sel, detailWidth = 420, minSide = 1200 }) {
  const { t, fs } = useUI();
  const rootRef = useRef(null);
  const detailRef = useRef(null);
  const first = useRef(true);
  const W = useWidth(rootRef);
  const side = W >= minSide;
  React.useEffect(() => {
    if (first.current) { first.current = false; return; }
    if (!side) detailRef.current?.scrollIntoView?.({ behavior: 'smooth', block: 'start' });
  }, [sel]);
  return (
    <div ref={rootRef} style={{ maxWidth: 1480, margin: '0 auto', padding: '8px 8px 16px' }}>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 6, marginBottom: 24 }}>
        <div style={{ ...fs.meta, fontWeight: 500 }}>{eyebrow}</div>
        <h1 style={fs.h1}>{headline}</h1>
        <div style={fs.meta}>{hint}　修改请切到“{EDIT_TAB}”标签。</div>
      </div>
      {stats || notice ? (
        <div style={{ display: 'flex', flexDirection: 'column', gap: 18, marginBottom: 28 }}>{stats}{notice}</div>
      ) : null}
      <div style={{ display: 'grid', gridTemplateColumns: side ? `minmax(0,1fr) ${detailWidth}px` : '1fr', gap: side ? 36 : 28, alignItems: 'start' }}>
        <div style={{ minWidth: 0 }}>{typeof main === 'function' ? main(W - (side ? detailWidth + 36 : 0)) : main}</div>
        <div ref={detailRef} style={side ? { position: 'sticky', top: 12, borderLeft: `1px solid ${t.colorSplit}`, paddingLeft: 32 }
                                         : { borderTop: `1px solid ${t.colorSplit}`, paddingTop: 28, maxWidth: 760 }}>
          {detail}
        </div>
      </div>
    </div>
  );
}

// 所有编号 → 标题（正文里的引用悬停用）
async function loadRefs(scope) {
  const [chain, moats, theses, biz, judgments, risks, watches] = await Promise.all([
    listRows('vi_value_chain', scope), listRows('vi_moat', scope), listRows('vi_thesis', scope), listRows('vi_biz_model', scope),
    listRows('vi_judgment', scope), listRows('vi_risk', scope), listRows('vi_watch', scope),
  ]);
  const refs = {};
  chain.forEach((r) => { refs[r.code] = r.participant; });
  moats.forEach((r) => { refs[r.code] = `${r.title}（${r.verdict || ''}）`; });
  theses.forEach((r) => { refs[r.code] = `${r.title}${r.status ? '（' + r.status + '）' : ''}`; });
  biz.forEach((r) => { refs[r.code] = `${r.element}：${r.title}`; });
  judgments.forEach((r) => { refs[r.code] = r.title; });
  risks.forEach((r) => { refs[r.code] = r.title; });
  watches.forEach((r) => { refs[r.code] = r.title; });
  return refs;
}

async function boot(what, fn) {
  try {
    const cos = await listRows('vi_company', { code: { $eq: COMPANY } });
    const company = cos[0];
    if (!company) { ctx.render(<Alert type="info" showIcon message={`公司表里没有代码为 ${COMPANY} 的公司`} />); return; }
    await fn(company, { company_id: { $eq: company.id } });
  } catch (error) {
    ctx.render(<Alert type="error" showIcon message={`${what}读取失败`} description={String(error?.message || error)} />);
  }
}

// 情景对比：隐含回报 vs 门槛（横条）、每股股东回报路径（折线）、三个情景的假设与结果
const pct = (v, d = 1) => (v === null || v === undefined || v === '' ? '—' : `${(Number(v) * 100).toFixed(d)}%`);
const num = (v, d = 2) => (v === null || v === undefined || v === '' ? '—' : Number(v).toLocaleString('zh-CN', { minimumFractionDigits: d, maximumFractionDigits: d }));
const factor = (v) => (v === null || v === undefined || v === '' ? '—' : `×${Number(v).toFixed(2)}${Number(v) === 1 ? '' : `（${Number(v) > 1 ? '+' : '−'}${Math.round(Math.abs(Number(v) - 1) * 100)}%）`}`);

// 情景颜色固定跟着情景走（基准蓝、悲观橙、乐观青），不随排序变
function useScenColor() {
  const { t } = useUI();
  return (name, i) => ({ 基准: t.colorPrimary, 悲观: '#eb6834', 乐观: '#1baf7a' }[name] || ['#6250d6', '#eda100', '#e87ba4'][i % 3]);
}

function IrrBars({ rows, hurdle, onSelect, sel }) {
  const { t, fs } = useUI();
  const color = useScenColor();
  const max = Math.max(hurdle || 0, ...rows.map((r) => r.irr || 0)) * 1.18 || 0.1;
  const x = (v) => `${Math.max(0, (v / max) * 100)}%`;
  return (
    <div style={{ position: 'relative', paddingTop: 26 }}>
      {hurdle ? (
        <div style={{ position: 'absolute', top: 0, bottom: 0, left: `calc(96px + (100% - 96px - 64px) * ${hurdle / max})`, borderLeft: `2px dashed ${t.colorTextSecondary}`, zIndex: 1 }}>
          <span style={{ position: 'absolute', top: 0, left: 6, fontSize: 12, color: t.colorText, fontWeight: 600, whiteSpace: 'nowrap' }}>门槛 {pct(hurdle)}</span>
        </div>
      ) : null}
      {rows.map((r, i) => (
        <div key={r.name} onClick={() => onSelect(r.name)} style={{ display: 'grid', gridTemplateColumns: '96px 1fr 64px', alignItems: 'center', gap: 0, padding: '8px 0', cursor: 'pointer' }}>
          <span style={{ ...fs.title, fontSize: 14, color: sel === r.name ? t.colorPrimary : t.colorText }}>{r.name}{r.is_base ? <span style={{ ...fs.code, marginLeft: 6 }}>基准</span> : null}</span>
          <div style={{ position: 'relative', height: 14, background: t.colorFillQuaternary, borderRadius: 7 }}>
            <div style={{ position: 'absolute', left: 0, top: 0, bottom: 0, width: x(r.irr || 0), background: color(r.name, i), borderRadius: 7 }} />
          </div>
          <span style={{ fontSize: 15, fontWeight: 600, color: t.colorText, textAlign: 'right', fontVariantNumeric: 'tabular-nums' }}>{pct(r.irr, 2)}</span>
        </div>
      ))}
    </div>
  );
}

// 折线：每个情景一条；悬停显示当年各情景数值
function Lines({ series, years, fmt, width }) {
  const { t } = useUI();
  const [hover, setHover] = useState(null);
  const W = Math.max(320, width || 600), H = 220, L = 44, R = 16, T = 12, B = 28;
  const ys = series.flatMap((s) => s.values.filter((v) => v !== null && v !== undefined));
  if (!ys.length || !years.length) return null;
  let lo = Math.min(...ys), hi = Math.max(...ys);
  const pad = (hi - lo) * 0.15 || hi * 0.1 || 1; lo -= pad; hi += pad;
  const X = (i) => L + (years.length === 1 ? 0 : (i / (years.length - 1)) * (W - L - R));
  const Y = (v) => T + (1 - (v - lo) / (hi - lo)) * (H - T - B);
  const ticks = [0, 1, 2, 3].map((k) => lo + ((hi - lo) * k) / 3);
  const onMove = (e) => {
    const box = e.currentTarget.getBoundingClientRect();
    const px = ((e.clientX - box.left) / box.width) * W;
    let best = 0;
    years.forEach((_, i) => { if (Math.abs(X(i) - px) < Math.abs(X(best) - px)) best = i; });
    setHover(best);
  };
  return (
    <div style={{ position: 'relative' }}>
      <svg viewBox={`0 0 ${W} ${H}`} width="100%" style={{ display: 'block', overflow: 'visible' }} onMouseMove={onMove} onMouseLeave={() => setHover(null)}>
        {ticks.map((v, k) => (
          <g key={k}>
            <line x1={L} x2={W - R} y1={Y(v)} y2={Y(v)} stroke={t.colorSplit} strokeWidth="1" />
            <text x={L - 8} y={Y(v) + 4} textAnchor="end" fontSize="11" fill={t.colorTextTertiary}>{fmt(v)}</text>
          </g>
        ))}
        {years.map((y, i) => (i % Math.ceil(years.length / 8) === 0 || i === years.length - 1
          ? <text key={y} x={X(i)} y={H - 8} textAnchor="middle" fontSize="11" fill={t.colorTextTertiary}>{y}</text> : null))}
        {hover !== null ? <line x1={X(hover)} x2={X(hover)} y1={T} y2={H - B} stroke={t.colorTextQuaternary} strokeDasharray="3 3" /> : null}
        {series.map((s) => (
          <g key={s.name}>
            <polyline fill="none" stroke={s.color} strokeWidth="2" strokeLinejoin="round" strokeLinecap="round"
                      points={s.values.map((v, i) => (v === null || v === undefined ? null : `${X(i)},${Y(v)}`)).filter(Boolean).join(' ')} />
            {hover !== null && s.values[hover] !== null && s.values[hover] !== undefined
              ? <circle cx={X(hover)} cy={Y(s.values[hover])} r="4.5" fill={s.color} stroke={t.colorBgContainer} strokeWidth="2" /> : null}
          </g>
        ))}
      </svg>
      {hover !== null ? (
        <div style={{ position: 'absolute', top: 4, left: `${Math.min(70, (X(hover) / W) * 100)}%`, transform: 'translateX(12px)', background: t.colorBgElevated,
                      boxShadow: t.boxShadowSecondary, borderRadius: 8, padding: '8px 12px', fontSize: 13, pointerEvents: 'none', minWidth: 120 }}>
          <div style={{ fontWeight: 600, marginBottom: 4, color: t.colorText }}>{years[hover]}</div>
          {series.map((s) => (
            <div key={s.name} style={{ display: 'flex', alignItems: 'center', gap: 6, color: t.colorText }}>
              <Dot color={s.color} /><span style={{ flex: 1 }}>{s.name}</span><span style={{ fontVariantNumeric: 'tabular-nums' }}>{fmt(s.values[hover])}</span>
            </div>
          ))}
        </div>
      ) : null}
      <div style={{ display: 'flex', gap: 16, marginTop: 6 }}>
        {series.map((s) => <Status key={s.name} label={s.name} color={s.color} />)}
      </div>
    </div>
  );
}

function ScenCard({ s, v, last, selected, onSelect, color }) {
  const { t, fs } = useUI();
  const row = (k, val) => (
    <div style={{ display: 'flex', justifyContent: 'space-between', gap: 12, fontSize: 13.5, lineHeight: 1.9 }}>
      <span style={{ color: t.colorTextSecondary }}>{k}</span><span style={{ color: t.colorText, fontVariantNumeric: 'tabular-nums' }}>{val}</span>
    </div>
  );
  return (
    <Card selected={selected} onClick={() => onSelect(s.name)} accent={color} style={{ padding: '14px 18px', display: 'flex', flexDirection: 'column', gap: 8 }}>
      <div style={{ display: 'flex', alignItems: 'baseline', gap: 8 }}>
        <span style={{ fontSize: 17, fontWeight: 600, color: t.colorTextHeading }}>{s.name}</span>
        {s.is_base ? <Tag>基准</Tag> : null}
        <span style={{ flex: 1 }} />
        <span style={{ fontSize: 13, color: t.colorTextSecondary }}>隐含回报 <b style={{ color: t.colorText, fontSize: 15 }}>{pct(v?.implied_irr, 2)}</b></span>
      </div>
      {usable(s.description) ? <div style={{ ...fs.meta, ...clamp(2) }}>{s.description}</div> : null}
      <div style={{ borderTop: `1px solid ${t.colorSplit}`, paddingTop: 6 }}>
        {row('业务量系数', factor(s.volume_factor))}
        {row('单价系数', factor(s.price_factor))}
        {row('付现成本系数', factor(s.cost_factor))}
        {row('永续增长率', pct(s.terminal_growth))}
        {s.probability !== null && s.probability !== undefined ? row('情景概率', pct(s.probability, 0)) : null}
        {last ? row(`${last.year}E 每股股东回报`, `${num(last.dps, 3)} 元`) : null}
        {v ? row('门槛下最高买入价', `${num(v.value_at_required)} 元`) : null}
      </div>
    </Card>
  );
}

function Detail({ s, v, refs }) {
  if (!s) return <Empty description="点击情景查看说明" />;
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 22 }}>
      <DetailHead meta={`情景${s.is_base ? ' · 基准' : ''}${usable(s.nature) ? ' · ' + s.nature : ''}`} title={s.name} />
      <Attrs items={[['隐含回报', pct(v?.implied_irr, 2)], ['现金支持口径', pct(v?.cash_implied_irr, 2)], ['门槛', pct(v?.required_return)], ['终值占比', pct(v?.terminal_share, 0)]]} />
      <Section label="结论" text={v?.conclusion} refs={refs} tone="key" />
      <Section label="情景说明" text={s.description} refs={refs} />
      <Section label="假设性质" text={s.nature} refs={refs} />
    </div>
  );
}

boot('情景', async (company, scope) => {
  const models = await listRows('vi_model', scope);
  const model = models.find((m) => m.status === '当前') || models[0];
  if (!model) { ctx.render(<Empty description={`${company.name}还没有估值模型`} />); return; }
  const [scens, vals, proj, refs] = await Promise.all([
    listRows('vi_scenario', { model_id: { $eq: model.id } }), listRows('vi_valuation', { model_id: { $eq: model.id } }),
    listRows('vi_projection', { model_id: { $eq: model.id } }, null, 2000), loadRefs(scope),
  ]);
  scens.sort((a, b) => (a.sort ?? 0) - (b.sort ?? 0));
  const val = (n) => vals.find((v) => v.scenario_name === n);
  const years = [...new Set(proj.map((r) => r.year))].sort((a, b) => a - b);
  function Page() {
    const { t } = useUI();
    const color = useScenColor();
    const base = scens.find((s) => s.is_base) || scens[0];
    const [sel, setSel] = useState(base?.name);
    if (!scens.length) return <Empty description={`${company.name}还没有情景（切到“${EDIT_TAB}”标签新增）`} />;
    const hurdle = vals[0]?.required_return ?? model.required_return;
    const rows = scens.map((s) => ({ name: s.name, is_base: s.is_base, irr: val(s.name)?.implied_irr }));
    const above = rows.filter((r) => r.irr !== undefined && r.irr !== null && r.irr >= hurdle);
    const headline = !hurdle ? `${scens.length} 个情景` : above.length === rows.length ? `${rows.length} 个情景的隐含回报都高于门槛 ${pct(hurdle)}`
      : above.length ? `${above.map((r) => r.name).join('、')}高于门槛 ${pct(hurdle)}，其余低于` : `${rows.length} 个情景的隐含回报都低于门槛 ${pct(hurdle)}`;
    const lastOf = (n) => proj.filter((r) => r.scenario_name === n).sort((a, b) => b.year - a.year)[0];
    const series = scens.map((s, i) => ({ name: s.name, color: color(s.name, i), values: years.map((y) => proj.find((r) => r.scenario_name === s.name && r.year === y)?.dps ?? null) }));
    const main = (w) => (
      <div style={{ display: 'flex', flexDirection: 'column', gap: 28 }}>
        <div>
          <Label>隐含年化回报 vs 门槛（按市价 {num(vals[0]?.market_price)} 元买入）</Label>
          <IrrBars rows={rows} hurdle={hurdle} onSelect={setSel} sel={sel} />
        </div>
        {years.length ? (
          <div>
            <Label>每股股东回报路径（元人民币）</Label>
            <Lines series={series} years={years} fmt={(v) => (v === null || v === undefined ? '—' : Number(v).toFixed(2))} width={w} />
          </div>
        ) : null}
        <div style={{ display: 'grid', gridTemplateColumns: `repeat(${w >= 720 ? Math.min(scens.length, 3) : 1}, minmax(0,1fr))`, gap: 14 }}>
          {scens.map((s, i) => <ScenCard key={s.id} s={s} v={val(s.name)} last={lastOf(s.name)} selected={s.name === sel} onSelect={setSel} color={color(s.name, i)} />)}
        </div>
      </div>
    );
    const cur = scens.find((s) => s.name === sel);
    return (
      <Shell eyebrow={`${company.name} · 情景 · 股东回报折现交叉验证`} headline={headline}
             hint={`模型：${model.name}。此处为集团股东回报折现的交叉验证；主估值在“估值”页按分部加总。点情景看说明与结论。`}
             stats={<Stats items={rows.map((r, i) => ({ label: `${r.name}·隐含回报`, value: pct(r.irr, 2), color: color(r.name, i) })).concat(hurdle ? [{ label: '门槛', value: pct(hurdle) }] : [])} />}
             main={main} sel={sel} detail={<Detail s={cur} v={cur ? val(cur.name) : null} refs={refs} />} />
    );
  }
  ctx.render(<Page />);
});

}
