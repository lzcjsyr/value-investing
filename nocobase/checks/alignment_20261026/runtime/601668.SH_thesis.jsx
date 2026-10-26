export default async function run(ctx) {
const COMPANY = '601668.SH';   // 由 build_bizviews.py 写入：只看这家公司
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

// 核心论点：每条的裁决、把握、改判条件；并列出谁引用了它（壁垒、风险、假设依据、适配度维度）
function ThesisCard({ x, used, selected, onSelect }) {
  const { t, fs, status } = useUI();
  const refs = [['壁垒', used.moats.map((m) => m.code)], ['风险', used.risks.map((r) => r.code)], ['依据', used.judgments.map((j) => j.code)],
                ['适配度', used.fits.map((f) => f.dimension)]].filter(([, xs]) => xs.length);
  return (
    <Card selected={selected} onClick={() => onSelect(x.code)} accent={status[x.status] || t.colorBorder}
          style={{ padding: '16px 18px', display: 'flex', flexDirection: 'column', gap: 10 }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
        <span style={fs.code}>{x.code}</span>
        {x.category ? <Tag>{x.category}</Tag> : null}
        <span style={{ flex: 1 }} />
        <Status label={`${x.status || '未裁决'}${x.confidence ? ' · 把握' + x.confidence : ''}`} color={status[x.status]} />
      </div>
      <div style={{ ...fs.title, fontSize: 16 }}>{x.title}</div>
      {usable(x.mind_changer) ? (
        <div style={{ fontSize: 13.5, lineHeight: 1.7, color: t.colorTextSecondary, ...clamp(2) }}>
          <span style={{ color: t.colorText, fontWeight: 600 }}>改判条件　</span>{String(x.mind_changer).replace(/^改判[：:]?\s*/, '')}
        </div>
      ) : null}
      <div style={{ display: 'flex', flexWrap: 'wrap', gap: 6, alignItems: 'center' }}>
        {refs.length ? refs.map(([k, xs]) => <Tag key={k}>{k} {xs.join(' ')}</Tag>) : <Flag>没有被引用</Flag>}
        {x.check_result === '已触发' ? <Flag>自动检查已触发</Flag> : null}
      </div>
    </Card>
  );
}

function Detail({ x, used, refs }) {
  const { status, level, verdict } = useUI();
  if (!x) return <Empty description="点击任一论点查看辩论全文" />;
  const check = x.check_metric ? `${x.check_metric} ${x.check_op || ''} ${x.check_threshold ?? ''}，连续 ${x.check_years || '?'} 年 → ${x.check_result || ''}` : '';
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 22 }}>
      <DetailHead meta={`${x.code}${x.category ? ' · ' + x.category : ''}${x.debated_on ? ' · 辩论于 ' + x.debated_on : ''}`} title={x.title} />
      <Attrs items={[['裁决', <Status label={x.status || '未裁决'} color={status[x.status]} size={15} strong />], ['把握', x.confidence], ['自动检查', x.check_result || '未设置']]} />
      <Section label="裁决理由" text={x.verdict} refs={refs} tone="key" />
      <Section label="正方立论" text={x.bull_case} refs={refs} tone="pro" />
      <Section label="反方立论" text={x.bear_case} refs={refs} tone="con" />
      <Section label="正方反驳" text={x.bull_rebuttal} refs={refs} tone="pro" />
      <Section label="反方反驳" text={x.bear_rebuttal} refs={refs} tone="con" />
      <Section label="决定胜负的证据" text={x.decisive_evidence} refs={refs} />
      <Section label="改判条件" text={x.mind_changer} refs={refs} tone="key" />
      <Section label="对模型的影响" text={x.model_impact} refs={refs} />
      <Section label="外部观点" text={x.external_view} refs={refs} />
      <Section label="自动检查条件" text={check} refs={refs} />
      <LinkList label="被这些壁垒引用" items={used.moats.map((m) => ({ code: m.code, title: m.title, tag: m.verdict, color: verdict[m.verdict] }))} />
      <LinkList label="被这些风险削弱" items={used.risks.map((r) => ({ code: r.code, title: r.title, tag: r.level, color: level[r.level] }))} />
      <LinkList label="落到这些估值参数（假设依据）" items={used.judgments.map((j) => ({ code: j.code, title: `${j.title}${j.parameter ? '　→ ' + j.parameter : ''}` }))} />
      <LinkList label="支撑这些适配度评分" items={used.fits.map((f) => ({ title: `${f.dimension}　${f.score ?? '—'} 分` }))} />
      <Facts facts={x.facts} />
    </div>
  );
}

boot('核心论点', async (company, scope) => {
  const [rows, moats, risks, judgments, fits, refs] = await Promise.all([
    listRows('vi_thesis', scope, ['facts']), listRows('vi_moat', scope, ['theses']), listRows('vi_risk', scope, ['theses']),
    listRows('vi_judgment', scope, ['theses']), listRows('vi_fit_score', scope, ['theses']), loadRefs(scope),
  ]);
  rows.sort(byCode);
  const usedBy = (x) => {
    const has = (y) => (y.theses || []).some((z) => z.id === x.id);
    return { moats: moats.filter(has).sort(byCode), risks: risks.filter(has).sort(byCode), judgments: judgments.filter(has).sort(byCode),
             fits: fits.filter(has).sort((a, b) => (a.sort ?? 0) - (b.sort ?? 0)) };
  };
  const used = Object.fromEntries(rows.map((x) => [x.code, usedBy(x)]));
  function Page() {
    const { status } = useUI();
    const [sel, setSel] = useState(rows[0]?.code);
    if (!rows.length) return <Empty description={`${company.name}还没有填写核心论点（切到“${EDIT_TAB}”标签新增）`} />;
    const n = (s) => rows.filter((x) => x.status === s).length;
    const open = rows.filter((x) => x.status !== '成立');
    const headline = `${rows.length} 条论点，${n('成立')} 条成立` + (open.length ? `；${open.map((x) => `${x.code} ${short(String(x.title).split('，')[0], 20)}`).join('、')} ${open.every((x) => x.status === '观察') ? '仍在观察' : '未定'}` : '');
    const todo = rows.filter((x) => x.check_result === '已触发').map((x) => `${x.code} ${short(x.title)}：自动检查已触发，需要复核裁决`)
      .concat(rows.filter((x) => { const u = used[x.code]; return !u.moats.length && !u.risks.length && !u.judgments.length && !u.fits.length; })
        .map((x) => `${x.code} ${short(x.title)}：没有被任何壁垒、风险、假设依据或适配度引用`));
    const list = (w) => (
      <div style={{ display: 'grid', gridTemplateColumns: w >= 900 ? 'repeat(2, minmax(0,1fr))' : '1fr', gap: 14, alignItems: 'start' }}>
        {rows.map((x) => <ThesisCard key={x.code} x={x} used={used[x.code]} selected={x.code === sel} onSelect={setSel} />)}
      </div>
    );
    const cur = rows.find((x) => x.code === sel);
    return (
      <Shell eyebrow={`${company.name} · 核心论点`} headline={headline}
             hint="每条都正反辩论后下结论；卡片底部是引用它的壁垒、风险、假设依据和适配度维度。点卡片看辩论全文。"
             stats={<Stats items={['成立', '观察', '存疑', '证伪'].map((s) => ({ label: s, value: n(s), unit: '条', color: status[s] }))} />}
             notice={<Notice items={todo} />} main={list} sel={sel} detailWidth={480}
             detail={<Detail x={cur} used={cur ? used[cur.code] : null} refs={refs} />} />
    );
  }
  ctx.render(<Page />);
});

}
