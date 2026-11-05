"""“<公司> / 商业模式”下各页（以及情景、估值模型）改成两个标签：图（JS 可视化，只读，点任一项看全文）＋明细（编辑）（原生表格，在这里新增和修改）。
  · 商业模式拆解：商业模式画布（九格，左边怎么做、右边为谁做、中间价值主张、底部钱怎么花怎么来）；
  · 竞争壁垒：按判定分四栏（真实壁垒、局部优势、待验证、伪壁垒），每项写明论证它的论点及裁决；
  · 核心论点：论点卡片（裁决、把握、改判条件），并列出被哪些壁垒、风险、假设依据、适配度维度引用；
  · 风险分析：可能性×冲击矩阵；
  · 价投适配度：评分看板（build_fitboard.JS）；
预测与估值里的两张录入表也用同样的形式：
  · 情景：情景对比（隐含回报 vs 门槛的横条、每股股息路径、各情景的假设与结果）；
  · 估值模型：模型参数（门槛、预测区间、折现率构成、期初资产负债、门槛依据；侧栏是模型说明）。
产业链与五力在 build_chainmap.py（五力图＋产业链、竞争对手两个编辑标签）。
页面原地改写（apply-blueprint replace），地址不变；明细标签的表格与 build_pages.blueprint 生成的完全相同。数据全部来自 vi_ 表，页面不存内容。

  python3 build_bizviews.py 600900.SH                 # 这家公司的这些页面都改
  python3 build_bizviews.py 600900.SH moat thesis     # 只改其中几个
改了下面的 JS 之后重跑即可（同样是原地改写）。
"""
import json, sys
import build_pages as bp
import build_fitboard
from build_pages import state, companies, ensure_group, company_root, COMPANY_MENU
from build_overview import apply_page

EDIT_TAB = '明细（编辑）'

PRELUDE = r"""const COMPANY = '__COMPANY__';   // 由 build_bizviews.py 写入：只看这家公司
const EDIT_TAB = '__EDIT__';
const { React } = ctx.libs;
const { useState, useRef } = React;
const { Tooltip, Alert, Empty, Segmented, theme } = ctx.libs.antd;

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
const clamp = (n) => ({ overflow: 'hidden', display: '-webkit-box', WebkitLineClamp: n, WebkitBoxOrient: 'vertical', wordBreak: 'normal', overflowWrap: 'anywhere' });
const REF_KIND = { V: '产业链', M: '壁垒', T: '论点', B: '商业模式', J: '假设依据', R: '风险' };
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
    // 只滚动最近的滚动容器：scrollIntoView 会连外层框架和窗口一起滚，详情较短时页面底部会露出空白
    const el = detailRef.current;
    if (side || !el) return;
    let box = el.parentElement;
    while (box && !(/(auto|scroll)/.test(window.getComputedStyle(box).overflowY) && box.scrollHeight > box.clientHeight)) box = box.parentElement;
    if (!box) return;
    const r = el.getBoundingClientRect(), b = box.getBoundingClientRect();
    if (r.top >= b.top && r.top < b.bottom - 120) return;       // 详情开头已在视野内
    const top = Math.min(box.scrollTop + r.top - b.top - 12, box.scrollHeight - box.clientHeight);
    box.scrollTo({ top: Math.max(0, top), behavior: 'smooth' });
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
  const [chain, moats, theses, biz, judgments, risks] = await Promise.all([
    listRows('vi_value_chain', scope), listRows('vi_moat', scope), listRows('vi_thesis', scope), listRows('vi_biz_model', scope),
    listRows('vi_judgment', scope), listRows('vi_risk', scope),
  ]);
  const refs = {};
  chain.forEach((r) => { refs[r.code] = r.participant; });
  moats.forEach((r) => { refs[r.code] = `${r.title}（${r.verdict || ''}）`; });
  theses.forEach((r) => { refs[r.code] = `${r.title}${r.status ? '（' + r.status + '）' : ''}`; });
  biz.filter((r) => !r.business_id).forEach((r) => { refs[r.code] = `${r.element}：${r.title}`; });
  judgments.forEach((r) => { refs[r.code] = r.title; });
  risks.forEach((r) => { refs[r.code] = r.title; });
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
"""

CANVAS = r"""
// 商业模式画布：左半边怎么做（合作、业务、资源），右半边为谁做（关系、渠道、客户），中间价值主张，底部成本与收入
const AREA = { 重要合作: 'kp', 关键业务: 'ka', 核心资源: 'kr', 价值主张: 'vp', 客户关系: 'cr', 渠道通路: 'ch', 客户细分: 'cs', 成本结构: 'cost', 收入来源: 'rev' };
// 五个区域各一个颜色，只用在圆点和色条上：怎么做、价值主张、为谁做、钱怎么花、钱怎么来
function zoneColor(t, el) {
  if (el === '价值主张') return t.colorPrimary;
  if (['重要合作', '关键业务', '核心资源'].includes(el)) return t.geekblue6 || '#2f54eb';
  if (['客户关系', '渠道通路', '客户细分'].includes(el)) return t.cyan6 || '#08979c';
  return el === '成本结构' ? (t.orange6 || '#d46b08') : t.colorSuccess;
}

// 关键数字：按“；”拆成一行一条，数字加粗
// 只加粗“带单位的数”“千分位数”“小数”；年份、2026H1、A2 这类编号不加粗
const NUM_RE = /((?<![A-Za-z\d.])[+−\-–]?\d[\d,，]*(?:\.\d+)?\s*(?:%|pt|个百分点|万亿元|亿元|万元|元|亿|万㎡|万吨|倍|bp)|(?<![A-Za-z\d.])[+−\-–]?\d{1,3}(?:[,，]\d{3})+(?:\.\d+)?(?![\dA-Za-z])|(?<![A-Za-z\d.])[+−\-–]?\d+\.\d+(?![\dA-Za-z%]))/g;
function Num({ text }) {
  const { t } = useUI();
  return String(text).split(NUM_RE).map((x, i) => (i % 2
    ? <b key={i} style={{ fontWeight: 600, color: t.colorTextHeading, fontVariantNumeric: 'tabular-nums' }}>{x}</b>
    : <React.Fragment key={i}>{x}</React.Fragment>));
}
const parts = (s) => String(s || '').split(/[；;]\s*/).map((x) => x.trim()).filter(Boolean);

function Cell({ r, element, selected, onSelect, max = 3, core, wide }) {
  const { t, fs } = useUI();
  const color = zoneColor(t, element);
  if (!r) {
    return (
      <div style={{ gridArea: AREA[element], border: `1px dashed ${t.colorBorder}`, borderRadius: 12, padding: 16 }}>
        <Status label={element} color={color} />
        <div style={{ ...fs.meta, color: t.colorTextQuaternary, marginTop: 6 }}>未填写</div>
      </div>
    );
  }
  const ms = usable(r.metric) ? parts(r.metric) : [];
  return (
    <Card selected={selected} onClick={() => onSelect(r.code)}
          style={{ gridArea: AREA[element], padding: core ? '18px 18px 20px' : '14px 16px 16px', display: 'flex', flexDirection: 'column', gap: 12,
                   background: core && !selected ? t.colorPrimaryBg : undefined, borderTop: `3px solid ${color}` }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <span style={{ fontSize: 13, fontWeight: 600, color: core ? t.colorPrimary : t.colorTextSecondary }}>{element}</span>
        <span style={fs.code}>{r.code}</span>
      </div>
      <div style={{ ...fs.title, fontSize: core ? 18 : 15.5, lineHeight: 1.55, ...clamp(core ? 5 : 4) }}>{r.title}</div>
      {ms.length ? (
        <div style={{ display: wide ? 'grid' : 'flex', gridTemplateColumns: wide ? 'repeat(2, minmax(0,1fr))' : undefined, flexDirection: 'column',
                      gap: wide ? '6px 20px' : 6, paddingTop: 10, borderTop: `1px solid ${t.colorSplit}` }}>
          {ms.slice(0, max).map((m, i) => (
            <div key={i} style={{ display: 'flex', gap: 8, fontSize: 13, lineHeight: 1.6, color: t.colorTextSecondary, minWidth: 0 }}>
              <span style={{ width: 4, height: 4, borderRadius: 2, background: color, flex: 'none', marginTop: 9 }} />
              <span style={{ minWidth: 0, ...clamp(core ? 4 : 2) }}><Num text={m} /></span>
            </div>
          ))}
          {ms.length > max ? <div style={{ ...fs.code, paddingLeft: 12 }}>另有 {ms.length - max} 项，点开看</div> : null}
        </div>
      ) : null}
    </Card>
  );
}

function Detail({ r, refs }) {
  if (!r) return <Empty description="点击画布中的格子查看详情" />;
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 22 }}>
      <DetailHead meta={`${r.code} · ${r.element}`} title={r.title} />
      <Section label="关键数字" text={r.metric} refs={refs} tone="key" />
      <Section label="说明" text={r.content} refs={refs} />
      <Section label="变化与风险" text={r.trend} refs={refs} tone="con" />
      <Facts facts={r.facts} />
    </div>
  );
}

boot('商业模式', async (company, scope) => {
  const [allRows, refs, businesses] = await Promise.all([listRows('vi_biz_model', scope, ['facts']), loadRefs(scope), listRows('vi_business', scope)]);
  allRows.sort(byCode);
  businesses.sort((a, b) => (a.sort || 0) - (b.sort || 0) || byCode(a,b));
  function Page() {
    const { t, fs } = useUI();
    const [businessId, setBusinessId] = useState('group');
    const rows = allRows.filter((r) => businessId === 'group' ? !r.business_id : String(r.business_id) === String(businessId));
    const business = businesses.find((b) => String(b.id) === String(businessId));
    const of = (el) => rows.find((r) => r.element === el);
    const [sel, setSel] = useState('B2');
    if (!allRows.length) return <Empty description={`${company.name}还没有填写商业模式（切到“${EDIT_TAB}”标签新增）`} />;
    const p = (el, opt = {}) => <Cell key={el} r={of(el)} element={el} selected={of(el)?.code === sel} onSelect={setSel} core={el === '价值主张'} {...opt} />;
    const zone = (area, label, color, align) => (
      <div style={{ gridArea: area, display: 'flex', alignItems: 'center', gap: 8, justifyContent: align || 'flex-start', fontSize: 12.5, color: t.colorTextSecondary }}>
        <Dot color={color} size={7} />{label}
      </div>
    );
    const canvas = (w) => (w >= 760 ? (
      <div style={{ display: 'grid', gap: 12, gridTemplateColumns: 'repeat(10, minmax(0,1fr))', alignItems: 'stretch',
                    gridTemplateAreas: '"c1 c1 c1 c1 c2 c2 c3 c3 c3 c3" "kp kp ka ka vp vp cr cr cs cs" "kp kp kr kr vp vp ch ch cs cs" "c4 c4 c4 c4 c4 c5 c5 c5 c5 c5" "cost cost cost cost cost rev rev rev rev rev"' }}>
        {zone('c1', '怎么做 · 靠谁、做什么、靠什么', zoneColor(t, '关键业务'))}
        {zone('c2', '提供什么', t.colorPrimary, 'center')}
        {zone('c3', '为谁做 · 怎么维系、怎么送达、卖给谁', zoneColor(t, '客户细分'), 'flex-end')}
        {p('重要合作', { max: 4 })}{p('关键业务')}{p('核心资源')}{p('价值主张', { max: 4 })}{p('客户关系')}{p('渠道通路')}{p('客户细分', { max: 4 })}
        <div style={{ gridArea: 'c4', marginTop: 8 }}>{zone(undefined, '钱怎么花', zoneColor(t, '成本结构'))}</div>
        <div style={{ gridArea: 'c5', marginTop: 8 }}>{zone(undefined, '钱怎么来', zoneColor(t, '收入来源'))}</div>
        {p('成本结构', { max: 4, wide: w >= 1100 })}{p('收入来源', { max: 4, wide: w >= 1100 })}
      </div>
    ) : (
      <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
        {rows.map((r) => <Cell key={r.code} r={r} element={r.element} selected={r.code === sel} onSelect={setSel} core={r.element === '价值主张'} />)}
      </div>
    ));
    const vp = of('价值主张');
    return (
      <div>
      {businesses.length > 0 && <div style={{ marginBottom: 18 }}>
        <Segmented value={businessId} onChange={(id) => {setBusinessId(id); setSel('B2');}} options={[{label:'集团整体 / 共性',value:'group'}, ...businesses.map((b) => ({label:b.name,value:String(b.id)}))]} block />
        {business && <div style={{ marginTop: 12, ...fs.body }}>
          <Section label="业务边界" text={business.boundary} refs={refs} />
          <Section label="费用分摊" text={business.cost_allocation} refs={refs} />
          <Section label="经营资产与投入" text={business.asset_boundary} refs={refs} />
        </div>}
      </div>}
      <Shell eyebrow={`${company.name} · ${business?.name || '集团整体 / 共性'} · 商业模式画布`} headline={vp ? vp.title : '商业模式'}
             hint="左边怎么做、右边为谁做、中间价值主张，底部是钱怎么花、怎么来。点格子看说明、变化与风险和依据事实。"
             main={canvas} sel={sel} minSide={1800} detail={<Detail r={rows.find((r) => r.code === sel)} refs={refs} />} />
      </div>
    );
  }
  ctx.render(<Page />);
});
"""

MOAT = r"""
// 竞争壁垒：按判定分四栏；每项写明论证它的论点及裁决；伪壁垒以外没有壁垒类论点的，集中列在“需要处理”
const COLS = [
  ['真实壁垒', '能持续带来超额回报'], ['局部优势', '有优势，但范围有限或可被追赶'], ['待验证', '证据还不够'], ['伪壁垒', '看起来像壁垒，其实不是'],
];
const STRENGTH = { 强: 3, 中: 2, 弱: 1, 无: 0 };
const unproven = (m) => m.verdict !== '伪壁垒' && !(m.theses || []).some((x) => x.category === '经营');

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
      {unproven(m) ? <Notice items={['没有关联经营类论点：这项壁垒能否持续，还没有专门正反辩论过。']} /> : null}
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
    const todo = rows.filter(unproven).map((m) => `${m.code} ${short(m.title)}：关联的 ${(m.theses || []).map((x) => x.code).join('、') || '—'} 不是经营类论点，能否持续还没专门辩论`)
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
"""

THESIS = r"""
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
             hint="对公司的判断只写在这里：每条都正反辩论后下结论，还没答案的判断也写成论点，缺的证据写在“决定胜负的证据”（待办清单只放待办）。卡片底部是引用它的壁垒、风险、假设依据和适配度维度，点卡片看辩论全文。"
             stats={<Stats items={['成立', '观察', '存疑', '证伪'].map((s) => ({ label: s, value: n(s), unit: '条', color: status[s] }))} />}
             notice={<Notice items={todo} />} main={list} sel={sel} detailWidth={480}
             detail={<Detail x={cur} used={cur ? used[cur.code] : null} refs={refs} />} />
    );
  }
  ctx.render(<Page />);
});
"""

RISK = r"""
// 风险分析：可能性（纵）×冲击（横）矩阵；格子底色＝风险等级（乘积 6—9 重大，3—4 重要，1—2 一般）
const LV = { 高: 3, 中: 2, 低: 1 };
const score = (r) => (LV[r.probability] || 0) * (LV[r.impact] || 0);

function Chip({ r, selected, onSelect }) {
  const { t, fs, level } = useUI();
  const arrow = r.trend === '上升' ? ['↑', t.colorError] : r.trend === '下降' ? ['↓', t.colorSuccess] : null;
  return (
    <Tooltip title={r.title} mouseEnterDelay={0.3}>
      <div onClick={() => onSelect(r.code)}
           style={{ display: 'flex', gap: 8, alignItems: 'center', padding: '8px 10px', borderRadius: 8, cursor: 'pointer', background: t.colorBgContainer,
                    border: `1px solid ${selected ? t.colorPrimary : t.colorBorderSecondary}`, boxShadow: selected ? `0 0 0 3px ${t.colorPrimaryBg}` : '0 1px 2px rgba(0,0,0,0.04)' }}>
        <Dot color={level[r.level]} />
        <span style={{ ...fs.code, flex: 'none' }}>{r.code}</span>
        <span style={{ flex: 1, minWidth: 0, fontSize: 14, lineHeight: 1.45, color: t.colorText, ...clamp(2) }}>{head(r.title)}</span>
        {arrow ? <span style={{ color: arrow[1], fontSize: 13, fontWeight: 700 }}>{arrow[0]}</span> : null}
      </div>
    </Tooltip>
  );
}

function Matrix({ rows, sel, onSelect, compact }) {
  const { t } = useUI();
  const bg = (s) => (s >= 6 ? t.colorErrorBg : s >= 3 ? t.colorWarningBg : t.colorFillQuaternary);
  const axis = { fontSize: 13, color: t.colorTextSecondary, display: 'flex', alignItems: 'center', justifyContent: 'center' };
  const cell = (p, i) => {
    const xs = rows.filter((r) => LV[r.probability] === p && LV[r.impact] === i);
    return (
      <div key={`${p}${i}`} style={{ background: bg(p * i), borderRadius: 10, padding: 10, minHeight: compact ? 64 : 120, display: 'flex', flexDirection: 'column', gap: 8, minWidth: 0 }}>
        {xs.map((r) => <Chip key={r.code} r={r} selected={r.code === sel} onSelect={onSelect} />)}
      </div>
    );
  };
  return (
    <div style={{ display: 'grid', gridTemplateColumns: '44px repeat(3, minmax(0,1fr))', gridTemplateRows: 'repeat(3, auto) 30px', gap: 8 }}>
      {[3, 2, 1].map((p) => (
        <React.Fragment key={p}>
          <div style={{ ...axis, flexDirection: 'column', gap: 2 }}><span style={{ fontWeight: 600, color: t.colorText }}>{['', '低', '中', '高'][p]}</span><span style={{ fontSize: 12 }}>可能性</span></div>
          {[1, 2, 3].map((i) => cell(p, i))}
        </React.Fragment>
      ))}
      <div />
      {[1, 2, 3].map((i) => <div key={i} style={axis}><span style={{ fontWeight: 600, color: t.colorText, marginRight: 4 }}>{['', '低', '中', '高'][i]}</span>冲击</div>)}
    </div>
  );
}

function Detail({ r, refs }) {
  const { status, level } = useUI();
  if (!r) return <Empty description="点击矩阵里的风险查看详情" />;
  const ts = (r.theses || []).slice().sort(byCode);
  const js = (r.judgments || []).slice().sort(byCode);
  const ms = (r.metrics || []).slice().sort((a, b) => String(a.name).localeCompare(String(b.name), 'zh'));
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 22 }}>
      <DetailHead meta={`${r.code}${r.category ? ' · ' + r.category : ''}${r.status ? ' · ' + r.status : ''}`} title={r.title} />
      <Attrs items={[['等级', <Status label={r.level || '未评'} color={level[r.level]} size={15} strong />], ['可能性', r.probability], ['冲击', r.impact], ['时间窗口', r.horizon]]} />
      <Section label="估值里怎么处理" text={r.treatment} refs={refs} tone="key" />
      <Section label="传导路径" text={r.mechanism} refs={refs} />
      <Section label="影响测算" text={r.impact_estimate} refs={refs} />
      <Section label="缓冲因素" text={r.mitigants} refs={refs} tone="pro" />
      <Section label="预警信号" text={r.early_warning} refs={refs} tone="con" />
      <Section label="触发后应对" text={r.response} refs={refs} />
      <LinkList label="会削弱的论点" items={ts.map((x) => ({ code: x.code, title: x.title, tag: x.status || '未裁决', color: status[x.status] }))} />
      <LinkList label="估值对应的假设依据" items={js.map((j) => ({ code: j.code, title: `${j.title}${j.parameter ? '　→ ' + j.parameter : ''}` }))} />
      <LinkList label="预警指标" items={ms.map((m) => ({ code: '', title: `${m.name}${m.unit ? '（' + m.unit + '）' : ''}` }))} />
      <Facts facts={r.facts} />
    </div>
  );
}

boot('风险分析', async (company, scope) => {
  const [rows, refs] = await Promise.all([listRows('vi_risk', scope, ['theses', 'judgments', 'metrics', 'facts']), loadRefs(scope)]);
  rows.sort(byCode);
  function Page() {
    const { t, fs, level } = useUI();
    const ranked = rows.slice().sort((a, b) => score(b) - score(a) || byCode(a, b));
    const [sel, setSel] = useState(ranked[0]?.code);
    if (!rows.length) return <Empty description={`${company.name}还没有填写风险（切到“${EDIT_TAB}”标签新增）`} />;
    const top = ranked[0];
    const rated = rows.filter((r) => score(r));
    const unrated = rows.filter((r) => !score(r));
    const notIn = rows.filter((r) => r.treatment === '未计入估值');
    const headline = `最大的风险：${top.code} ${short(top.title, 20)}`;
    const todo = notIn.map((r) => `${r.code} ${short(r.title, 24)}：还没有计入估值`)
      .concat(unrated.map((r) => `${r.code} ${short(r.title, 24)}：还没评可能性或冲击`));
    const main = (w) => (
      <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
        <Matrix rows={rated} sel={sel} onSelect={setSel} compact={w < 640} />
        {unrated.length ? (
          <div>
            <Label>还没评可能性或冲击</Label>
            <div style={{ display: 'flex', flexWrap: 'wrap', gap: 8 }}>{unrated.map((r) => <Chip key={r.code} r={r} selected={r.code === sel} onSelect={setSel} />)}</div>
          </div>
        ) : null}
        <div style={fs.meta}>底色越红，风险越大（可能性×冲击：6—9 重大，3—4 重要，1—2 一般）；↑↓ 是趋势。</div>
      </div>
    );
    return (
      <Shell eyebrow={`${company.name} · 风险分析`} headline={headline}
             hint={`${top.level || ''}风险，${top.treatment || '估值处理未填'}。右上角是可能性高、冲击大的风险；点风险看传导路径和对应的论点、预警指标。`}
             stats={<Stats items={[...['重大', '重要', '一般'].map((l) => ({ label: l, value: rows.filter((r) => r.level === l).length, unit: '项', color: level[l] })),
                                   { label: '未计入估值', value: notIn.length, unit: '项' }]} />}
             notice={<Notice items={todo} />} main={main} sel={sel} detail={<Detail r={rows.find((r) => r.code === sel)} refs={refs} />} />
    );
  }
  ctx.render(<Page />);
});
"""

SCENARIO = r"""
// 情景对比：隐含回报 vs 门槛（横条）、每股股息路径（折线）、三个情景的假设与结果
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
        {last ? row(`${last.year}E 每股股息`, `${num(last.dps, 3)} 元`) : null}
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

// 只用分部加总、没有逐年预测的模型（腾讯音乐，2026-10-28 起）：按分部加总比较各情景
function SotpScenPage({ company, model, scens, sotp, segs, refs }) {
  const { t } = useUI();
  const color = useScenColor();
  const base = scens.find((s) => s.is_base) || scens[0];
  const [sel, setSel] = useState(base?.name);
  const so = (n) => sotp.find((r) => r.scenario_name === n) || {};
  const price = so(base?.name).market_price;
  const rows = scens.map((s) => ({ name: s.name, is_base: s.is_base, vps: so(s.name).value_per_share }));
  const max = Math.max(price || 0, ...rows.map((r) => r.vps || 0)) * 1.15 || 1;
  const below = rows.filter((r) => price && r.vps && price < r.vps);
  const headline = !price ? `${scens.length} 个情景`
    : below.length === rows.length ? `市场价 ${num(price)} 元低于全部 ${rows.length} 个情景的每股价值`
    : below.length ? `市场价 ${num(price)} 元低于${below.map((r) => r.name).join('、')}情景的每股价值，高于其余` : `市场价 ${num(price)} 元高于全部情景的每股价值`;
  const codes = [...new Set(segs.map((g) => g.code))].sort();
  const segOf = (c, n) => segs.find((g) => g.code === c && g.scenario_name === n);
  const cell = { padding: '6px 10px', textAlign: 'right', fontVariantNumeric: 'tabular-nums', borderBottom: `1px solid ${t.colorBorderSecondary}` };
  const head = { ...cell, fontWeight: 600, color: t.colorTextSecondary };
  const lines = [
    ...codes.map((c) => ({ label: `${c} ${segs.find((g) => g.code === c)?.name || ''}`, f: (n) => segOf(c, n)?.value,
                           sub: (n) => { const g = segOf(c, n); return g ? `${num(g.revenue, 0)}×${pct(g.op_margin, 0)}，${num(g.multiple_used, 1)} 倍` : ''; } })),
    { label: '① 主营合计', f: (n) => so(n).segments_value, strong: true },
    { label: '② 可分配的自由现金', f: (n) => so(n).usable_net_cash },
    { label: '③ 对外投资（七折）', f: (n) => so(n).investments },
    { label: '− 少数股东权益', f: (n) => so(n).minority_other },
    { label: '每股价值（元）', f: (n) => so(n).value_per_share, strong: true, d: 2 },
  ];
  const main = (w) => (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 28 }}>
      <div>
        <Label>每股价值 vs 市场价（元）</Label>
        <div style={{ position: 'relative', paddingTop: 26 }}>
          {price ? (
            <div style={{ position: 'absolute', top: 0, bottom: 0, left: `calc(96px + (100% - 96px - 72px) * ${price / max})`, borderLeft: `2px dashed ${t.colorTextSecondary}`, zIndex: 1 }}>
              <span style={{ position: 'absolute', top: 0, left: 6, fontSize: 12, fontWeight: 600, whiteSpace: 'nowrap' }}>市场价 {num(price)}</span>
            </div>) : null}
          {rows.map((r, i) => (
            <div key={r.name} onClick={() => setSel(r.name)} style={{ display: 'grid', gridTemplateColumns: '96px 1fr 72px', alignItems: 'center', padding: '8px 0', cursor: 'pointer' }}>
              <span style={{ fontSize: 14, fontWeight: 600, color: sel === r.name ? t.colorPrimary : t.colorText }}>{r.name}</span>
              <div style={{ position: 'relative', height: 14, background: t.colorFillQuaternary, borderRadius: 7 }}>
                <div style={{ position: 'absolute', left: 0, top: 0, bottom: 0, width: `${Math.max(0, ((r.vps || 0) / max) * 100)}%`, background: color(r.name, i), borderRadius: 7 }} />
              </div>
              <span style={{ fontSize: 15, fontWeight: 600, textAlign: 'right', fontVariantNumeric: 'tabular-nums' }}>{num(r.vps)}</span>
            </div>))}
        </div>
      </div>
      <div style={{ overflowX: 'auto' }}>
        <Label>三块拆解（亿元）：情景只改主营，自由现金与对外投资相同</Label>
        <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: 13 }}>
          <thead><tr><th style={{ ...head, textAlign: 'left' }}>项目</th>{scens.map((s) => <th key={s.id} style={head}>{s.name}</th>)}</tr></thead>
          <tbody>{lines.map((l) => (
            <tr key={l.label}>
              <td style={{ ...cell, textAlign: 'left', fontWeight: l.strong ? 600 : 400 }}>{l.label}</td>
              {scens.map((s) => (
                <td key={s.id} style={{ ...cell, fontWeight: l.strong ? 600 : 400 }}>
                  {num(l.f(s.name), l.d ?? 0)}
                  {l.sub ? <div style={{ fontSize: 11, color: t.colorTextSecondary, fontWeight: 400 }}>{l.sub(s.name)}</div> : null}
                </td>))}
            </tr>))}</tbody>
        </table>
      </div>
    </div>
  );
  const cur = scens.find((s) => s.name === sel);
  return (
    <Shell eyebrow={company.name + ' · 情景（分部加总）'} headline={headline}
           hint={`模型：${model.name}。三个情景只改主营三块的收入、利润率与倍数，分部参数在「估值 / 业务估值（编辑）」；点情景看说明。`}
           stats={<Stats items={rows.map((r, i) => ({ label: `${r.name}·每股价值`, value: `${num(r.vps)} 元`, color: color(r.name, i) })).concat(price ? [{ label: '市场价', value: `${num(price)} 元` }] : [])} />}
           main={main} sel={sel}
           detail={cur ? <div><Section label="情景说明" text={cur.description} refs={refs} /><Section label="假设性质" text={cur.nature} refs={refs} /></div> : null} />
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
  if (!proj.length) {
    const [sotp, segs] = await Promise.all([listRows('vi_sotp', { model_id: { $eq: model.id } }), listRows('vi_sotp_segment_val', { model_id: { $eq: model.id } })]);
    if (sotp.length) { ctx.render(<SotpScenPage company={company} model={model} scens={scens} sotp={sotp} segs={segs} refs={refs} />); return; }
  }
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
            <Label>每股股息路径（元）</Label>
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
      <Shell eyebrow={`${company.name} · 情景`} headline={headline}
             hint={`模型：${model.name}。情景只调整逐年假设的整体系数和永续增长；点情景看说明与结论。`}
             stats={<Stats items={rows.map((r, i) => ({ label: `${r.name}·隐含回报`, value: pct(r.irr, 2), color: color(r.name, i) })).concat(hurdle ? [{ label: '门槛', value: pct(hurdle) }] : [])} />}
             main={main} sel={sel} detail={<Detail s={cur} v={cur ? val(cur.name) : null} refs={refs} />} />
    );
  }
  ctx.render(<Page />);
});
"""

MODEL = r"""
// 模型参数：门槛与预测区间、折现率构成、期初资产负债、门槛依据；侧栏是模型说明
const pct = (v, d = 1) => (v === null || v === undefined || v === '' ? '—' : `${(Number(v) * 100).toFixed(d)}%`);
const num = (v, d = 2) => (v === null || v === undefined || v === '' ? '—' : Number(v).toLocaleString('zh-CN', { minimumFractionDigits: d, maximumFractionDigits: d }));

function RateBar({ m }) {
  const { t, fs } = useUI();
  const rf = Number(m.rf || 0), erp = Number(m.erp || 0), req = Number(m.required_return || 0);
  const max = Math.max(rf + erp, req) * 1.15 || 0.1;
  const w = (v) => `${(v / max) * 100}%`;
  return (
    <div>
      <div style={{ position: 'relative', height: 30, background: t.colorFillQuaternary, borderRadius: 8, overflow: 'visible' }}>
        <div style={{ position: 'absolute', left: 0, top: 0, bottom: 0, width: w(rf), background: t.colorPrimary, borderRadius: '8px 0 0 8px' }} />
        <div style={{ position: 'absolute', left: w(rf), top: 0, bottom: 0, width: w(erp), background: t.colorPrimaryBorder, borderRadius: '0 8px 8px 0', borderLeft: `2px solid ${t.colorBgContainer}` }} />
        {req ? <div style={{ position: 'absolute', left: w(req), top: -6, bottom: -6, borderLeft: `2px dashed ${t.colorText}` }} /> : null}
      </div>
      <div style={{ display: 'flex', flexWrap: 'wrap', gap: 18, marginTop: 10 }}>
        <Status label={`无风险利率 ${pct(rf, 2)}`} color={t.colorPrimary} />
        <Status label={`风险溢价 ${pct(erp, 2)}`} color={t.colorPrimaryBorder} />
        <span style={{ fontSize: 13, color: t.colorText }}>＝ 基准折现率 <b>{pct(m.base_discount_rate, 2)}</b></span>
        {req ? <span style={{ fontSize: 13, color: t.colorText }}>┆ 门槛（要求收益率）<b>{pct(req)}</b></span> : null}
      </div>
      {m.latest_rf !== null && m.latest_rf !== undefined ? (
        <div style={{ ...fs.meta, marginTop: 6 }}>无风险利率最新观察 {num(m.latest_rf, 2)}%（{m.latest_rf_date}）；模型里用的是 {m.rf_date || '—'} 的 {pct(rf, 2)}。</div>
      ) : null}
    </div>
  );
}

function Balance({ m }) {
  const { t, fs } = useUI();
  const items = [['经营性长期资产', m.opening_op_assets, t.colorPrimary], ['长期股权投资', m.opening_lt_invest, t.colorPrimary],
                 ['带息负债', m.opening_debt, '#eb6834'], ['归母权益', m.opening_equity, t.colorTextSecondary], ['少数股东权益', m.opening_minority, t.colorTextSecondary]]
    .filter((x) => x[1] !== null && x[1] !== undefined);
  if (!items.length) return null;
  const max = Math.max(...items.map((x) => Number(x[1])));
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
      {items.map(([k, v, c]) => (
        <div key={k} style={{ display: 'grid', gridTemplateColumns: '120px 1fr 96px', alignItems: 'center', gap: 12 }}>
          <span style={{ fontSize: 13.5, color: t.colorText }}>{k}</span>
          <div style={{ height: 10, background: t.colorFillQuaternary, borderRadius: 5 }}>
            <div style={{ width: `${(Number(v) / max) * 100}%`, height: '100%', background: c, borderRadius: 5 }} />
          </div>
          <span style={{ fontSize: 14, fontWeight: 600, color: t.colorText, textAlign: 'right', fontVariantNumeric: 'tabular-nums' }}>{num(v, 0)}<span style={{ ...fs.code, marginLeft: 3 }}>亿</span></span>
        </div>
      ))}
    </div>
  );
}

boot('估值模型', async (company, scope) => {
  const [models, judgments, refs] = await Promise.all([listRows('vi_model', scope), listRows('vi_judgment', scope), loadRefs(scope)]);
  models.sort((a, b) => (a.status === '当前' ? -1 : 0) - (b.status === '当前' ? -1 : 0) || a.id - b.id);
  function Page() {
    const { t, fs } = useUI();
    const [sel, setSel] = useState(models[0]?.id);
    if (!models.length) return <Empty description={`${company.name}还没有估值模型（切到“${EDIT_TAB}”标签新增）`} />;
    const m = models.find((x) => x.id === sel) || models[0];
    const hurdleJ = judgments.filter((j) => /要求收益率|门槛/.test(`${j.parameter || ''}${j.title || ''}`)).sort(byCode);
    const headline = usable(m.method) ? String(m.method).split(/[；;。]/)[0] : m.name;
    const span = m.base_year && m.terminal_year ? `${m.base_year} → ${m.terminal_year}` : '—';
    const main = (
      <div style={{ display: 'flex', flexDirection: 'column', gap: 30 }}>
        {models.length > 1 ? (
          <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
            {models.map((x) => (
              <Card key={x.id} selected={x.id === m.id} onClick={() => setSel(x.id)} style={{ padding: '8px 14px' }}>
                <span style={{ fontSize: 14, color: t.colorText }}>{x.name}</span> <span style={fs.code}>{x.status || ''}</span>
              </Card>
            ))}
          </div>
        ) : null}
        <div><Label>折现率构成（虚线是门槛）</Label><RateBar m={m} /></div>
        <div><Label>期初资产负债（{m.base_year} 年末，亿元）</Label><Balance m={m} /></div>
        <LinkList label="门槛的依据（假设依据）" items={hurdleJ.map((j) => ({ code: j.code, title: j.title, tag: j.status }))} />
        <Attrs items={[['主估值方法', m.primary_method || '—'], ['安全边际', m.margin_low !== null && m.margin_low !== undefined ? (m.margin_high === null || m.margin_high === undefined ? pct(m.margin_low, 0) : `${pct(m.margin_low, 0)} / ${pct(m.margin_high, 0)}`) : '—'],
                       ['分部加总核心年', m.sotp_year || '—'], ['状态', m.status || '—']]} />
      </div>
    );
    return (
      <Shell eyebrow={`${company.name} · 估值模型`} headline={headline} hint={`${m.name}。方法、门槛和期初数都在这里；逐年数字见“逐年假设”，情景见“情景”。`}
             stats={<Stats items={[{ label: '门槛（要求收益率）', value: pct(m.required_return) }, { label: '预测区间', value: span },
                                   { label: '股本', value: num(m.shares), unit: '亿股' }, { label: '估值日', value: m.valuation_date || '—' }]} />}
             main={main} sel={sel} detailWidth={460}
             detail={<div style={{ display: 'flex', flexDirection: 'column', gap: 22 }}>
               <DetailHead meta="模型说明" title={m.name} />
               <Section label="方法" text={m.method} refs={refs} tone="key" />
               <Section label="说明与来源" text={m.notes} refs={refs} />
             </div>} />
    );
  }
  ctx.render(<Page />);
});
"""

# code: (图标签名, 脚本)；价投适配度沿用 build_fitboard 的看板（它自带取数，不拼 PRELUDE）
VIEWS = {
    'biz_model': ('画布', CANVAS),
    'moat': ('壁垒图', MOAT),
    'thesis': ('论点图', THESIS),
    'risk': ('风险矩阵', RISK),
    'fit_score': ('评分', None),
    'scenario': ('情景对比', SCENARIO),
    'model': ('模型参数', MODEL),
}


def script(code, co):
    if code == 'fit_score':
        return build_fitboard.JS.replace('__COMPANY__', co['code']).replace('在下方表格里', f'在“{EDIT_TAB}”标签里')
    return (PRELUDE + VIEWS[code][1]).replace('__COMPANY__', co['code']).replace('__EDIT__', EDIT_TAB)


def page_title(code):
    return next(t for g, _, pages in COMPANY_MENU for c, t in pages if c == code)


def convert(co, code):
    key = f"{code}@{co['code']}"
    page = state()['pages'].get(key)
    if not page:
        print(f"{co['name']} 没有「{page_title(code)}」页面，跳过"); return
    title, (tab, _) = page_title(code), VIEWS[code]
    st = state()
    gid = ensure_group(st, f"{co['name']}/商业模式", '商业模式', 'SafetyOutlined', parent=company_root(st, co))
    b = bp.blueprint(code, title, gid, co)                 # 明细标签：与原表格页完全相同的表格、弹窗、表单
    extra_tabs = []
    if code == 'biz_model' and co['code'] == '01810.HK':
        businesses = bp.blueprint('business', '业务分部（编辑）', gid, co)
        b['defaults']['collections'].update(businesses['defaults']['collections'])
        extra_tabs = businesses['tabs']
    with bp.no_field_desc([code]):
        apply_page(f"bizview_{code}_{co['code']}", {
          'version': '1', 'mode': 'replace', 'target': {'pageSchemaUid': page['pageSchemaUid']},
          'page': {'title': title, 'documentTitle': f"{co['name']} · {title}", 'enableTabs': True},
          'defaults': b['defaults'],
          'assets': {'scripts': {'view': {'version': 'v2', 'code': script(code, co)}}},
          'tabs': [{'title': tab, 'blocks': [{'key': 'view', 'type': 'jsBlock', 'script': 'view'}]},
                   {'title': EDIT_TAB, 'blocks': [b['tabs'][0]['blocks'][0]]}] + extra_tabs})
    bp.order_tabs(key, [tab, EDIT_TAB] + [x['title'] for x in extra_tabs])
    print(f"{co['name']} · {title}：{tab} ＋ {EDIT_TAB}")


if __name__ == '__main__':
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    codes = [a for a in args if a in VIEWS] or list(VIEWS)
    want = {a for a in args if a not in VIEWS}
    for co in companies():
        if co['code'] in want:
            for code in codes:
                convert(co, code)
