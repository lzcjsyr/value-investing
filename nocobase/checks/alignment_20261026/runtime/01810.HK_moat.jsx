export default async function run(ctx) {
const COMPANY = '01810.HK';   // 由 build_bizviews.py 写入：只看这家公司
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

// 竞争壁垒：按判定分四栏；每项写明论证它的论点及裁决；伪壁垒以外没有壁垒类论点的，集中列在“需要处理”
const COLS = [
  ['真实壁垒', '能持续带来超额回报'], ['局部优势', '有优势，但范围有限或可被追赶'], ['待验证', '证据还不够'], ['伪壁垒', '看起来像壁垒，其实不是'],
];
const STRENGTH = { 强: 3, 中: 2, 弱: 1, 无: 0 };
const unproven = (m) => m.verdict !== '伪壁垒' && !(m.theses || []).some((x) => x.category === '壁垒');

function Bars({ v }) {
  const { t } = useUI();
  const n = STRENGTH[v] ?? 0;
  return (
    <Tooltip title={`强度：${v || '未标注'}`}>
      <span style={{ display: 'inline-flex', gap: 2, alignItems: 'center' }}>
        {[1, 2, 3].map((i) => <span key={i} style={{ width: 12, height: 6, borderRadius: 2, background: i <= n ? t.colorText : t.colorFillSecondary }} />)}
      </span>
    </Tooltip>
  );
}

function Trend({ v }) {
  const { t } = useUI();
  const m = { 增强: ['↑', t.colorSuccess], 削弱: ['↓', t.colorError], 稳定: ['→', t.colorTextTertiary] }[v];
  return m ? <span style={{ fontSize: 13, color: t.colorTextSecondary }}><span style={{ color: m[1], fontWeight: 700 }}>{m[0]}</span> {v}</span> : null;
}

function MoatCard({ m, selected, onSelect }) {
  const { t, fs, status } = useUI();
  const ts = (m.theses || []).slice().sort(byCode);
  const fake = m.verdict === '伪壁垒';
  return (
    <Card selected={selected} onClick={() => onSelect(m.code)} muted={fake} style={{ padding: '14px 16px', display: 'flex', flexDirection: 'column', gap: 10 }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
        <span style={fs.code}>{m.code}</span>
        <span style={{ ...fs.meta, flex: 1 }}>{m.moat_type}</span>
        {fake ? null : <Bars v={m.strength} />}
      </div>
      <div style={{ ...fs.title, color: fake ? t.colorTextSecondary : t.colorText, ...clamp(3) }}>{short(m.title, 40)}</div>
      {fake ? null : <Trend v={m.trend} />}
      <div style={{ display: 'flex', flexDirection: 'column', gap: 4, paddingTop: 8, borderTop: `1px solid ${t.colorSplit}` }}>
        {ts.length ? ts.map((x) => (
          <div key={x.id} style={{ display: 'flex', gap: 8, alignItems: 'center', fontSize: 13 }}>
            <Dot color={status[x.status]} size={7} />
            <span style={{ color: t.colorText, fontWeight: 500, flex: 'none' }}>{x.code} {x.status || '未裁决'}</span>
            <span style={{ color: t.colorTextSecondary, flex: 1, minWidth: 0, ...clamp(1) }}>{short(x.title, 30)}</span>
          </div>
        )) : <span style={{ ...fs.meta, color: t.colorTextTertiary }}>没有关联论点</span>}
      </div>
      {unproven(m) || m.check_result === '已触发' ? (
        <div style={{ display: 'flex', gap: 6, flexWrap: 'wrap' }}>
          {unproven(m) ? <Flag>未专门论证</Flag> : null}
          {m.check_result === '已触发' ? <Flag>自动检查已触发</Flag> : null}
        </div>
      ) : null}
    </Card>
  );
}

function Detail({ m, refs }) {
  const { status, verdict } = useUI();
  if (!m) return <Empty description="点击任一壁垒查看分析" />;
  const ts = (m.theses || []).slice().sort(byCode);
  const check = m.check_metric ? `${m.check_metric} ${m.check_op || ''} ${m.check_threshold ?? ''}，连续 ${m.check_years || '?'} 年 → ${m.check_result || ''}` : '';
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 22 }}>
      <DetailHead meta={`${m.code}${m.moat_type ? ' · ' + m.moat_type : ''}`} title={m.title} />
      <Attrs items={[['判定', <Status label={m.verdict || '未判定'} color={verdict[m.verdict]} size={15} strong />], ['强度', m.strength], ['趋势', m.trend],
                     ['自动检查', m.check_result || '未设置']]} />
      <LinkList label="论证它的论点" items={ts.map((x) => ({ code: x.code, title: `${x.title}（${x.category || ''}）`, tag: x.status || '未裁决', color: status[x.status] }))} />
      {unproven(m) ? <Notice items={['关联的论点都不是壁垒类：这项壁垒能否持续，还没有专门正反辩论过。']} /> : null}
      <Section label="机制" text={m.mechanism} refs={refs} />
      <Section label="财务体现" text={m.financial_link} refs={refs} tone="key" />
      <Section label="证据" text={m.evidence} refs={refs} tone="pro" />
      <Section label="反证" text={m.counter} refs={refs} tone="con" />
      <Section label="复制难度" text={m.replication} refs={refs} />
      <Section label="削弱因素" text={m.threats} refs={refs} tone="con" />
      <Section label="自动检查条件" text={check} refs={refs} />
      <Facts facts={m.facts} />
    </div>
  );
}

boot('竞争壁垒', async (company, scope) => {
  const [rows, refs] = await Promise.all([listRows('vi_moat', scope, ['theses', 'facts']), loadRefs(scope)]);
  rows.sort(byCode);
  function Page() {
    const { t, fs, verdict } = useUI();
    const real = rows.filter((m) => m.verdict === '真实壁垒');
    const [sel, setSel] = useState(real[0]?.code || rows[0]?.code);
    if (!rows.length) return <Empty description={`${company.name}还没有填写竞争壁垒（切到“${EDIT_TAB}”标签新增）`} />;
    const groups = COLS.map(([v, hint]) => [v, hint, rows.filter((m) => m.verdict === v)]);
    const other = rows.filter((m) => !COLS.some(([v]) => v === m.verdict));
    if (other.length) groups.push(['未判定', '还没有判定', other]);
    const todo = rows.filter(unproven).map((m) => `${m.code} ${short(m.title)}：关联的 ${(m.theses || []).map((x) => x.code).join('、') || '—'} 不是壁垒类论点，能否持续还没专门辩论`)
      .concat(rows.filter((m) => m.check_result === '已触发').map((m) => `${m.code} ${short(m.title)}：自动检查已触发，需要复核判定`));
    const headline = real.length ? `护城河来自 ${real.map((m) => short(m.title, 20)).join('、')}` : '还没有确认的真实壁垒';
    const board = (w) => {
      const n = w >= 1080 ? groups.length : w >= 600 ? 2 : 1;
      return (
        <div style={{ display: 'grid', gridTemplateColumns: `repeat(${n}, minmax(0,1fr))`, gap: 20, alignItems: 'start' }}>
          {groups.map(([v, hint, xs]) => (
            <div key={v} style={{ display: 'flex', flexDirection: 'column', gap: 12, minWidth: 0 }}>
              <div style={{ paddingBottom: 10, borderBottom: `2px solid ${verdict[v] || t.colorBorder}` }}>
                <div style={{ display: 'flex', alignItems: 'baseline', gap: 8 }}>
                  <span style={{ fontSize: 16, fontWeight: 600, color: t.colorTextHeading }}>{v}</span>
                  <span style={{ fontSize: 14, color: t.colorTextSecondary }}>{xs.length}</span>
                </div>
                <div style={fs.meta}>{hint}</div>
              </div>
              {xs.length ? xs.map((m) => <MoatCard key={m.code} m={m} selected={m.code === sel} onSelect={setSel} />)
                : <div style={{ ...fs.meta, color: t.colorTextQuaternary }}>无</div>}
            </div>
          ))}
        </div>
      );
    };
    return (
      <Shell eyebrow={`${company.name} · 竞争壁垒`} headline={headline} hint="按判定分四栏；卡片下方是论证它能否持续的论点及裁决。点卡片看全文。"
             stats={<Stats items={groups.map(([v, , xs]) => ({ label: v, value: xs.length, unit: '项', color: verdict[v] }))} />}
             notice={<Notice items={todo} />} main={board} sel={sel} minSide={1800}
             detail={<Detail m={rows.find((m) => m.code === sel)} refs={refs} />} />
    );
  }
  ctx.render(<Page />);
});

}
