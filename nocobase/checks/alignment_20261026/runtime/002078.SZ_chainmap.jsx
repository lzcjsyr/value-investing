export default async function run(ctx) {
const COMPANY = '002078.SZ';   // 由 build_chainmap.py 写入：只看这家公司的产业链
const { React } = ctx.libs;
const { useState, useRef } = React;
const { Tooltip, Alert, Typography, Empty, theme } = ctx.libs.antd;
const { Text, Title } = Typography;

async function listRows(name, filter, appends, pageSize = 500) {
  const resource = ctx.makeResource('MultiRecordResource');
  resource.setResourceName(name);
  resource.setPageSize?.(pageSize);
  if (filter) resource.setFilter?.(filter);
  if (appends) resource.setAppends?.(appends);
  await resource.refresh();
  return resource.getData() || [];
}

// 布局按页面实际可用宽度切换（不是窗口宽度）：并排 / 上下 / 竖排
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
const POWER = { 强: 3, 中: 2, 弱: 1 };
const REF_KIND = { V: '产业链', M: '壁垒', T: '论点', B: '商业模式', J: '判断' };
const REF_RE = /(?<![A-Za-z0-9-])(V\d{1,2}|M\d{1,2}|T\d{1,2}|B\d{1,2}|J-[A-Z0-9]+)(?![0-9])/g;
const codeNum = (c) => Number(String(c || '').replace(/\D/g, '')) || 0;
const isNum = (v) => v !== null && v !== undefined && v !== '' && !Number.isNaN(Number(v));
const fmtNum = (v) => (isNum(v) ? Number(v).toLocaleString('zh-CN', { maximumFractionDigits: 2 }) : '');
const fmtPct = (v) => (isNum(v) ? (Number(v) * 100).toFixed(1) + '%' : '');
const usable = (s) => s && s !== '—';

// “设备与工程：东方电气…”“国家电网、南方电网（单一买方）”→ 主标题＋副标题；其他不拆
function splitName(s) {
  const t = String(s || '');
  const colon = t.match(/^([^（：]{2,20})：(.+)$/);
  if (colon) return [colon[1].trim(), colon[2].trim()];
  const paren = t.match(/^([^（]{2,30})（([^（）]+)）$/);
  if (paren) return [paren[1].trim(), paren[2].trim()];
  return [t, ''];
}

function usePalette() {
  const { token } = theme.useToken();
  const effect = { 有利: token.colorSuccess, 中性: token.colorTextQuaternary, 不利: token.colorError };
  return { token, effect };
}

// 力量：三格细条
function Strength({ power, size = 'sm' }) {
  const { token } = usePalette();
  const n = POWER[power] || 0;
  const w = size === 'sm' ? 6 : 10;
  return (
    <span style={{ display: 'inline-flex', gap: 2, alignItems: 'center' }} title={`力量${power || '未标注'}`}>
      {[1, 2, 3].map((i) => (
        <span key={i} style={{ width: w, height: size === 'sm' ? 10 : 6, borderRadius: 1.5,
                               background: i <= n ? token.colorTextSecondary : token.colorFillSecondary }} />
      ))}
    </span>
  );
}

function Dot({ effect, size = 8 }) {
  const { token, effect: c } = usePalette();
  return <span style={{ width: size, height: size, borderRadius: '50%', flex: 'none', display: 'inline-block',
                        background: c[effect] || token.colorBorder }} />;
}

function trendText(n) {
  const arrow = { 增强: '↑', 稳定: '', 减弱: '↓' }[n.trend] || '';
  const bad = (n.effect === '不利' && n.trend === '增强') || (n.effect === '有利' && n.trend === '减弱');
  const good = (n.effect === '有利' && n.trend === '增强') || (n.effect === '不利' && n.trend === '减弱');
  return { arrow, tone: bad ? 'bad' : good ? 'good' : 'flat' };
}

// 一行：色点（对公司的影响）、编号、名称、趋势、力量
function Row({ n, selected, onSelect }) {
  const { token } = usePalette();
  const [head, sub] = splitName(n.participant);
  const t = trendText(n);
  const tone = { bad: token.colorError, good: token.colorSuccess, flat: token.colorTextTertiary }[t.tone];
  return (
    <Tooltip title={sub || null} placement="top" mouseEnterDelay={0.4}>
      <div
        onClick={() => onSelect(n.code)}
        style={{
          display: 'flex', alignItems: 'center', gap: 8, padding: '7px 10px', borderRadius: 6, cursor: 'pointer',
          background: selected ? token.colorPrimaryBg : 'transparent',
          outline: selected ? `1px solid ${token.colorPrimaryBorder}` : 'none',
          transition: 'background .15s',
        }}
        onMouseEnter={(e) => { if (!selected) e.currentTarget.style.background = token.colorFillTertiary; }}
        onMouseLeave={(e) => { if (!selected) e.currentTarget.style.background = 'transparent'; }}
      >
        <Dot effect={n.effect} />
        <span style={{ fontSize: 12, color: token.colorTextQuaternary, width: 24, flex: 'none' }}>{n.code}</span>
        <span style={{ flex: 1, minWidth: 0, fontSize: 14, lineHeight: 1.4, color: token.colorText, overflow: 'hidden',
                       display: '-webkit-box', WebkitLineClamp: 2, WebkitBoxOrient: 'vertical', wordBreak: 'break-all' }}>
          {head}
        </span>
        {t.arrow ? <span style={{ fontSize: 12, color: tone, flex: 'none' }}>{t.arrow}</span> : null}
        <Strength power={n.power} />
      </div>
    </Tooltip>
  );
}

function Box({ title, hint, nodes, selected, onSelect, tone = 'plain', style, onTitle }) {
  const { token } = usePalette();
  const bg = { plain: token.colorBgContainer, core: token.colorPrimaryBg, soft: 'transparent' }[tone];
  const border = tone === 'soft' ? `1px dashed ${token.colorBorder}` : `1px solid ${tone === 'core' ? token.colorPrimaryBorder : token.colorBorderSecondary}`;
  return (
    <div style={{ background: bg, border, borderRadius: 10, padding: '10px 6px 6px', minWidth: 0,
                  boxShadow: tone === 'plain' ? '0 1px 2px rgba(0,0,0,0.04)' : 'none', ...style }}>
      <div onClick={onTitle} style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between', gap: 8, padding: '0 10px 6px',
                                     cursor: onTitle ? 'pointer' : 'default' }}>
        <span style={{ fontSize: 13, fontWeight: 600, color: onTitle ? token.colorPrimary : token.colorText }}>{title}</span>
        {hint ? <span style={{ fontSize: 12, color: token.colorTextTertiary }}>{hint}</span> : null}
      </div>
      {nodes.length ? nodes.map((n) => <Row key={n.code} n={n} selected={selected === n.code} onSelect={onSelect} />)
        : <div style={{ fontSize: 12, color: token.colorTextQuaternary, padding: '4px 10px 8px' }}>未填写</div>}
    </div>
  );
}

// 指向中心的箭头：粗细＝力量强弱，颜色＝对公司有利/中性/不利
function forceOf(rows, force) {
  const items = rows.filter((r) => r.force === force);
  if (!items.length) return null;
  const p = Math.max(...items.map((r) => POWER[r.power] || 0));
  const e = items.some((r) => r.effect === '不利') ? '不利' : items.some((r) => r.effect === '有利') ? '有利' : '中性';
  const label = Object.keys(POWER).find((k) => POWER[k] === p) || '';
  return { p, e, label };
}

function ForceArrow({ dir, f, name }) {
  const { token, effect } = usePalette();
  const color = f ? effect[f.e] : token.colorBorder;
  const thick = f ? [1.5, 2, 4, 7][f.p] : 1;
  const head = thick * 1.6 + 6;
  const horizontal = dir === 'left' || dir === 'right';
  const shaft = horizontal
    ? <div style={{ flex: 1, height: thick, background: color, borderRadius: thick }} />
    : <div style={{ flex: 1, width: thick, background: color, borderRadius: thick }} />;
  const tri = {
    right: { borderTop: `${head / 1.6}px solid transparent`, borderBottom: `${head / 1.6}px solid transparent`, borderLeft: `${head}px solid ${color}` },
    left: { borderTop: `${head / 1.6}px solid transparent`, borderBottom: `${head / 1.6}px solid transparent`, borderRight: `${head}px solid ${color}` },
    down: { borderLeft: `${head / 1.6}px solid transparent`, borderRight: `${head / 1.6}px solid transparent`, borderTop: `${head}px solid ${color}` },
    up: { borderLeft: `${head / 1.6}px solid transparent`, borderRight: `${head / 1.6}px solid transparent`, borderBottom: `${head}px solid ${color}` },
  }[dir];
  const arrowHead = <div style={{ width: 0, height: 0, flex: 'none', ...tri }} />;
  const caption = (
    <div style={{ fontSize: 12, lineHeight: 1.3, color: token.colorTextSecondary, textAlign: 'center', whiteSpace: 'nowrap' }}>
      {name}<br /><span style={{ color: f ? color : token.colorTextQuaternary, fontWeight: 600 }}>{f ? f.label : '—'}</span>
    </div>
  );
  if (horizontal) {
    return (
      <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'stretch', justifyContent: 'center', gap: 6, height: '100%', padding: '0 4px' }}>
        {caption}
        <div style={{ display: 'flex', alignItems: 'center' }}>{dir === 'left' ? <>{arrowHead}{shaft}</> : <>{shaft}{arrowHead}</>}</div>
      </div>
    );
  }
  return (
    <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 10, height: '100%', padding: '4px 0' }}>
      <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', height: 44 }}>
        {dir === 'up' ? <>{arrowHead}{shaft}</> : <>{shaft}{arrowHead}</>}
      </div>
      {caption}
    </div>
  );
}

function ForcesMap({ rows, by, selected, onSelect, compact }) {
  const { token } = usePalette();
  const z = (pos) => by[pos] || [];
  const p = { selected, onSelect };
  const up = <Box title="上游供给" hint="供应商" nodes={z('上游供给')} {...p} />;
  const down = <Box title="下游客户" hint="买方" nodes={z('下游客户')} {...p} />;
  const entrants = <Box title="潜在进入者" nodes={z('潜在进入者')} {...p} />;
  const subs = <Box title="替代品" nodes={z('替代品')} {...p} />;
  const peers = z('同业竞争');
  const self = z('本公司环节');
  const rivalry = forceOf(rows, '行业内竞争');
  const core = (
    <Box title="本公司" nodes={self} tone="core" {...p} />
  );
  const coreBlock = (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
      {core}
      <Box title="同业竞争" hint={rivalry ? `行业内竞争 · ${rivalry.label}` : '行业内竞争'} nodes={peers} {...p} />
    </div>
  );
  const reg = z('监管').length ? <Box title="监管" hint="规则与价格边界" nodes={z('监管')} tone="soft" {...p} /> : null;
  const comp = z('互补方').length ? <Box title="互补方" hint="让本公司更值钱" nodes={z('互补方')} tone="soft" {...p} /> : null;
  const channel = z('渠道与流量').length ? <Box title="渠道与流量" nodes={z('渠道与流量')} tone="soft" {...p} /> : null;
  const fSup = forceOf(rows, '供应商议价能力');
  const fBuy = forceOf(rows, '买方议价能力');
  const fNew = forceOf(rows, '新进入者威胁');
  const fSub = forceOf(rows, '替代品威胁');

  if (compact) {
    return (
      <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
        {up}<ForceArrow dir="down" f={fSup} name="供应商议价力" />
        {entrants}<ForceArrow dir="down" f={fNew} name="新进入者威胁" />
        {coreBlock}
        <ForceArrow dir="up" f={fSub} name="替代品威胁" />{subs}
        <ForceArrow dir="up" f={fBuy} name="买方议价力" />{down}
        {channel}{reg}{comp}
      </div>
    );
  }
  // 经典五力布局：中心是本公司与同业，四个方向的力量指向中心；四个角放不属于五力的环节（监管、互补方、渠道）
  return (
    <div style={{ display: 'grid', gridTemplateColumns: 'minmax(0,1fr) 84px minmax(0,1.1fr) 84px minmax(0,1fr)',
                  gridTemplateRows: 'auto 76px auto 76px auto', alignItems: 'stretch' }}>
      <div style={{ gridColumn: 1, gridRow: 1, alignSelf: 'start' }}>{reg}</div>
      <div style={{ gridColumn: 3, gridRow: 1, alignSelf: 'end' }}>{entrants}</div>
      <div style={{ gridColumn: 5, gridRow: 1, alignSelf: 'start' }}>{channel}</div>
      <div style={{ gridColumn: 3, gridRow: 2 }}><ForceArrow dir="down" f={fNew} name="新进入者威胁" /></div>
      <div style={{ gridColumn: 1, gridRow: 3, alignSelf: 'center' }}>{up}</div>
      <div style={{ gridColumn: 2, gridRow: 3 }}><ForceArrow dir="right" f={fSup} name="供应商议价力" /></div>
      <div style={{ gridColumn: 3, gridRow: 3 }}>{coreBlock}</div>
      <div style={{ gridColumn: 4, gridRow: 3 }}><ForceArrow dir="left" f={fBuy} name="买方议价力" /></div>
      <div style={{ gridColumn: 5, gridRow: 3, alignSelf: 'center' }}>{down}</div>
      <div style={{ gridColumn: 3, gridRow: 4 }}><ForceArrow dir="up" f={fSub} name="替代品威胁" /></div>
      <div style={{ gridColumn: 3, gridRow: 5, alignSelf: 'start' }}>{subs}</div>
      <div style={{ gridColumn: 5, gridRow: 5, alignSelf: 'end' }}>{comp}</div>
    </div>
  );
}

function Legend() {
  const { token, effect } = usePalette();
  const item = (c, t) => (
    <span style={{ display: 'inline-flex', alignItems: 'center', gap: 6 }}>
      <span style={{ width: 8, height: 8, borderRadius: '50%', background: c }} />{t}
    </span>
  );
  return (
    <div style={{ display: 'flex', flexWrap: 'wrap', gap: 18, fontSize: 12, color: token.colorTextTertiary }}>
      {item(effect['有利'], '对公司有利')}{item(effect['中性'], '中性')}{item(effect['不利'], '对公司不利')}
      <span style={{ display: 'inline-flex', alignItems: 'center', gap: 6 }}><Strength power="中" />力量强弱</span>
      <span>箭头越粗，力量越强</span>
      <span>↑↓ 趋势</span>
    </div>
  );
}

// 正文里的编号：产业链编号可点击跳转，其他编号悬停看标题（下划虚线，不用彩色标签）
function RefText({ text, refs, onSelect }) {
  const { token } = usePalette();
  if (!text) return null;
  const parts = String(text).split(REF_RE);
  return (
    <>
      {parts.map((p, i) => {
        if (i % 2 === 0) return <React.Fragment key={i}>{p}</React.Fragment>;
        const kind = p.startsWith('J-') ? 'J' : p[0];
        const title = refs[p];
        const jump = kind === 'V' && title;
        return (
          <Tooltip key={i} title={title ? `${REF_KIND[kind]} ${p}：${title}` : `${REF_KIND[kind]} ${p}`}>
            <span onClick={jump ? () => onSelect(p) : undefined}
                  style={{ color: token.colorPrimary, cursor: jump ? 'pointer' : 'help',
                           borderBottom: `1px dashed ${token.colorPrimaryBorder}` }}>{p}</span>
          </Tooltip>
        );
      })}
    </>
  );
}

function Detail({ n, refs, onSelect }) {
  const { token, effect } = usePalette();
  if (!n) return <Empty description="点击图中的环节查看分析" />;
  const [head, sub] = splitName(n.participant);
  const t = trendText(n);
  const label = (s) => <div style={{ fontSize: 12, color: token.colorTextTertiary, letterSpacing: 0.5, marginBottom: 6 }}>{s}</div>;
  const para = { fontSize: 14, lineHeight: 1.85, color: token.colorText, margin: 0 };
  const comps = n.competitors || [];
  const facts = n.facts || [];
  const attr = (k, v, c) => (
    <div style={{ minWidth: 0 }}>
      <div style={{ fontSize: 12, color: token.colorTextTertiary }}>{k}</div>
      <div style={{ fontSize: 14, fontWeight: 600, color: c || token.colorText, marginTop: 2 }}>{v}</div>
    </div>
  );
  const trendColor = { bad: token.colorError, good: token.colorSuccess, flat: token.colorText }[t.tone];
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 20 }}>
      <div>
        <div style={{ fontSize: 12, color: token.colorTextTertiary }}>
          {n.code} · {n.position}{n.force && n.force !== '不适用' ? ` · ${n.force}` : ''}
        </div>
        <Title level={4} style={{ margin: '4px 0 0', fontWeight: 600 }}>{head}</Title>
        {sub ? <div style={{ fontSize: 13, color: token.colorTextSecondary, marginTop: 4, lineHeight: 1.6 }}>{sub}</div> : null}
      </div>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, minmax(0,1fr))', gap: 12, padding: '12px 0',
                    borderTop: `1px solid ${token.colorSplit}`, borderBottom: `1px solid ${token.colorSplit}` }}>
        {attr('力量', <span style={{ display: 'inline-flex', alignItems: 'center', gap: 8 }}>{n.power || '—'}<Strength power={n.power} size="lg" /></span>)}
        {attr('趋势', `${t.arrow} ${n.trend || '—'}`.trim(), trendColor)}
        {attr('对公司', n.effect || '—', effect[n.effect])}
      </div>
      {usable(n.role) ? <div>{label('提供或购买什么')}<p style={para}><RefText text={n.role} refs={refs} onSelect={onSelect} /></p></div> : null}
      {usable(n.profit_share) ? (
        <div style={{ background: token.colorFillQuaternary, borderRadius: 8, padding: '12px 14px' }}>
          {label('利润池或成本占比')}
          <p style={{ ...para, fontWeight: 500 }}><RefText text={n.profit_share} refs={refs} onSelect={onSelect} /></p>
        </div>
      ) : null}
      {usable(n.analysis) ? <div>{label('分析')}<p style={para}><RefText text={n.analysis} refs={refs} onSelect={onSelect} /></p></div> : null}
      {usable(n.counter) ? (
        <div style={{ borderLeft: `3px solid ${token.colorWarningBorder}`, paddingLeft: 14 }}>
          {label('反面证据')}
          <p style={{ ...para, color: token.colorTextSecondary }}><RefText text={n.counter} refs={refs} onSelect={onSelect} /></p>
        </div>
      ) : null}
      {comps.length ? (
        <div style={{ fontSize: 13, color: token.colorTextSecondary }}>
          {label('相关对手')}
          {comps.map((c) => c.name).join('、')}<span style={{ color: token.colorTextTertiary }}>（共 {comps.length} 家，详见“竞争对手（编辑）”标签）</span>
        </div>
      ) : null}
      {facts.length ? (
        <div>
          {label('依据事实')}
          {facts.map((f) => (
            <div key={f.id} style={{ fontSize: 12, color: token.colorTextSecondary, lineHeight: 1.7, paddingLeft: 12, position: 'relative' }}>
              <span style={{ position: 'absolute', left: 0 }}>·</span>{f.title}
            </div>
          ))}
        </div>
      ) : null}
    </div>
  );
}

// 一句话读图：不利且在增强的环节、有利的环节（由表格数据推出，不另写内容）
function Takeaway({ rows, onSelect }) {
  const { token, effect } = usePalette();
  const bad = rows.filter((r) => r.effect === '不利');
  const good = rows.filter((r) => r.effect === '有利');
  const link = (r) => (
    <span key={r.code} onClick={() => onSelect(r.code)} style={{ cursor: 'pointer', borderBottom: `1px dashed ${token.colorBorder}` }}>
      {r.code} {splitName(r.participant)[0]}{r.trend === '增强' ? '（增强）' : ''}
    </span>
  );
  const join = (xs) => xs.map((r, i) => <React.Fragment key={r.code}>{i ? '、' : ''}{link(r)}</React.Fragment>);
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 6, fontSize: 14, lineHeight: 1.7 }}>
      {bad.length ? <div><span style={{ color: effect['不利'], fontWeight: 600 }}>压力来自　</span>{join(bad)}</div> : null}
      {good.length ? <div><span style={{ color: effect['有利'], fontWeight: 600 }}>有利的是　</span>{join(good)}</div> : null}
    </div>
  );
}

try {
  const cos = await listRows('vi_company', { code: { $eq: COMPANY } });
  const company = cos[0];
  if (!company) {
    ctx.render(<Alert type="info" showIcon message={`公司表里没有代码为 ${COMPANY} 的公司`} />);
  } else {
    const scope = { company_id: { $eq: company.id } };
    const [chain, moats, theses, biz, judgments] = await Promise.all([
      listRows('vi_value_chain', scope, ['competitors', 'facts']),
      listRows('vi_moat', scope),
      listRows('vi_thesis', scope),
      listRows('vi_biz_model', scope),
      listRows('vi_judgment', scope),
    ]);
    const rows = [...chain].sort((a, b) => codeNum(a.code) - codeNum(b.code));
    const refs = {};
    rows.forEach((r) => { refs[r.code] = r.participant; });
    moats.forEach((r) => { refs[r.code] = `${r.title}（${r.verdict || ''}）`; });
    theses.forEach((r) => { refs[r.code] = `${r.title}${r.status ? '（' + r.status + '）' : ''}`; });
    biz.forEach((r) => { refs[r.code] = `${r.element}：${r.title}`; });
    judgments.forEach((r) => { refs[r.code] = r.title; });
    const by = {};
    rows.forEach((r) => { (by[r.position] = by[r.position] || []).push(r); });
    const first = (by['本公司环节'] || rows)[0]?.code;

    function Panel() {
      const { token } = usePalette();
      const [sel, setSelRaw] = useState(first);
      const detailRef = useRef(null);
      const rootRef = useRef(null);
      const W = useWidth(rootRef);
      const side = W >= 1300;                         // 图与详解并排（大屏）
      const compact = (side ? W - 392 : W) < 660;      // 图太窄时改成竖排
      const setSel = (code) => {      // 详解在图下面时：选中后滚过去
        setSelRaw(code);
        if (!side) setTimeout(() => detailRef.current?.scrollIntoView?.({ behavior: 'smooth', block: 'start' }), 50);
      };
      if (!rows.length) return <Empty description={`${company.name}还没有填写产业链（切到本页的“产业链（编辑）”标签新增）`} />;
      const node = rows.find((r) => r.code === sel);
      return (
        <div ref={rootRef} style={{ maxWidth: 1480, margin: '0 auto', padding: compact ? 0 : '4px 8px' }}>
          <div style={{ marginBottom: 20 }}>
            <Title level={3} style={{ margin: 0, fontWeight: 600 }}>{company.name} · 产业链与五力</Title>
            <Text type="secondary" style={{ fontSize: 13 }}>
              中心是本公司，四周的力量指向它：左边上游、右边下游、上方潜在进入者、下方替代品。点击任一环节查看分析；修改环节请切到“产业链（编辑）”标签。
            </Text>
          </div>
          <div style={{ marginBottom: 24 }}><Takeaway rows={rows} onSelect={setSel} /></div>
          <div style={{ display: 'grid', gridTemplateColumns: side ? 'minmax(0,1fr) 360px' : '1fr', gap: side ? 32 : 24, alignItems: 'start' }}>
            <div>
              <div style={{ background: token.colorFillQuaternary, borderRadius: 14, padding: compact ? 12 : 24 }}>
                <ForcesMap rows={rows} by={by} selected={sel} onSelect={setSel} compact={compact} />
              </div>
              <div style={{ marginTop: 12 }}><Legend /></div>
            </div>
            <div ref={detailRef} style={side ? { position: 'sticky', top: 12, borderLeft: `1px solid ${token.colorSplit}`, paddingLeft: 32 }
                                         : { borderTop: `1px solid ${token.colorSplit}`, paddingTop: 24, maxWidth: 820 }}>
              <Detail n={node} refs={refs} onSelect={setSel} />
            </div>
          </div>
        </div>
      );
    }

    ctx.render(<Panel />);
  }
} catch (error) {
  ctx.render(<Alert type="error" showIcon message="产业链读取失败" description={String(error?.message || error)} />);
}

}
