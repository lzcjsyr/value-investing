const { React, antd } = ctx.libs;
const { Space, Alert, Typography, Tag, theme } = antd;
const { Text, Link } = Typography;
const official = {
  fy: 'https://ir.tencentmusic.com/2026-03-17-Tencent-Music-Entertainment-Group-Announces-Fourth-Quarter-and-Full-Year-2025-Unaudited-Financial-Results',
  q2: 'https://ir.tencentmusic.com/2026-08-11-Tencent-Music-Entertainment-Group-Announces-Second-Quarter-2026-Unaudited-Financial-Results',
  q3: 'https://ir.tencentmusic.com/2026-11-17-Tencent-Music-Entertainment-Group-Announces-Third-Quarter-2026-Unaudited-Financial-Results',
  method: 'https://www.fool.com/investing/general/2013/10/11/an-interview-with-bruce-greenwald-value-investing.aspx',
};
const present = v => v != null && v !== '' && Number.isFinite(Number(v));
const fmt = (v, digits = 2) => present(v) ? Number(v).toLocaleString('zh-CN', {maximumFractionDigits: digits, minimumFractionDigits: digits}) : '待补';
const pct = v => present(v) ? Number((100 * v).toFixed(1)) + '%' : '待补';

async function list(name, filter, appends = []) {
  const r = ctx.makeResource('MultiRecordResource');
  r.setResourceName(name);
  r.setPageSize(200);
  r.setFilter(filter);
  if (appends.length) r.setAppends(appends);
  await r.refresh();
  return r.getData() || [];
}
async function load() {
  const [co] = await list('vi_company', {code: {$eq:'01698.HK'}});
  const scope = {company_id: {$eq:co.id}};
  const [units, values, growth, basis, sources, checks] = await Promise.all([
    list('vi_gw_unit', scope), list('vi_gw_value', scope), list('vi_growth', scope, ['judgments']),
    list('vi_judgment', scope, ['facts','theses','basis_metrics']), list('vi_source', scope), list('vi_check', scope),
  ]);
  const unit = units.find(x => x.business_code === 'B1');
  const row = growth.find(x => String(x.business_id) === String(unit?.business_id));
  const ids = new Set((row?.judgments || []).map(x => String(x.id)));
  return {co, unit, row, checks: checks.filter(c => ['G03','G04'].includes(c.code)), value: values[0], basis: basis.filter(x => ids.has(String(x.id))).sort((a,b) =>
    ['J-GROW','J-GROW-R','J-GROW-N'].indexOf(a.code) - ['J-GROW','J-GROW-R','J-GROW-N'].indexOf(b.code)),
    sources: new Map(sources.map(x => [String(x.id),x]))};
}

// 将每年新投入创造的超额收益折到估值基准日。已保存的估值始终取自 vi_gw_unit。
function premium(e, g, ro, n, h) {
  if (![e,g,h].every(present) || h <= 0) return null;
  if (g === 0 || n === 0) return 0;
  if (!present(ro) || ro <= 0 || (n == null && g >= h)) return null;
  const q = (1 + g) / (1 + h);
  const years = n == null ? 1 / (1 - q) : Math.abs(q - 1) < 1e-12 ? n : (1 - Math.pow(q, n)) / (1 - q);
  return e * g * (1/h - 1/ro) * years / (1+h);
}
const assumptions = {
  'J-GROW': ['盈利增速', '三项业务合算，十年利润年增约 2.44%。'],
  'J-GROW-R': ['新增投资回报率', '财报缺少逐项投入与收益，仍待验证。'],
  'J-GROW-N': ['优势期', '取决于版权续约条件和付费用户留存。'],
};
const style = `
.tme-growth {max-width:1000px;margin:0 auto;padding:8px 8px 18px;color:var(--ink);line-height:1.65;font-variant-numeric:tabular-nums;container-type:inline-size}
.tme-growth * {box-sizing:border-box}
.tme-growth h2,.tme-growth h3,.tme-growth p {margin:0}
.tme-growth h2 {font-size:18px;font-weight:600}
.tme-growth h3 {font-size:16px;font-weight:600;margin-bottom:8px}
.tme-growth .hero {padding:18px 24px;background:var(--tint);border-radius:8px}
.tme-growth .amount {font-size:clamp(32px,5cqw,46px);font-weight:600;letter-spacing:-1.5px;line-height:1.25}
.tme-growth .unit {margin-left:6px;font-size:15px}
.tme-growth .sub,.tme-growth .hint {color:var(--muted);font-size:14px}
.tme-growth .hero .sub {margin-top:5px}
.tme-growth section {margin-top:24px}
.tme-growth details {border-bottom:1px solid var(--line)}
.tme-growth details:not([open]) > .body {display:none}
.tme-growth summary {cursor:pointer;padding:12px 0;list-style:none}
.tme-growth summary::-webkit-details-marker {display:none}
.tme-growth summary:focus-visible {outline:2px solid var(--accent);outline-offset:2px}
.tme-growth summary::after {content:'⌄';color:var(--muted);font-size:17px;justify-self:end}
.tme-growth details[open] > summary::after {transform:rotate(180deg)}
.tme-growth .assumption {display:grid;grid-template-columns:minmax(110px,1fr) 84px minmax(160px,2.4fr) 18px;gap:12px;align-items:baseline}
.tme-growth .assumption strong {font-size:20px;line-height:1.2}
.tme-growth .fold {display:grid;grid-template-columns:1fr 18px;gap:8px}
.tme-growth .body {max-width:74ch;padding:4px 0 16px}
.tme-growth .body p + p,.tme-growth .body details {margin-top:8px}
.tme-growth .body b {font-size:13px;margin-right:8px}
.tme-growth .cases {display:grid;grid-template-columns:repeat(3,1fr);border:1px solid var(--line);border-radius:8px}
.tme-growth .case {padding:12px 16px}
.tme-growth .case + .case {border-left:1px solid var(--line)}
.tme-growth .case strong {display:block;font-size:22px;line-height:1.4}
.tme-growth .notes {margin-top:18px}
@container (max-width:600px) {
  .tme-growth .assumption {grid-template-columns:1fr auto 18px;gap:2px 12px}
  .tme-growth .assumption .hint {grid-row:2;grid-column:1 / -1}
  .tme-growth .assumption::after {grid-row:1;grid-column:3}
  .tme-growth .cases {grid-template-columns:1fr}
  .tme-growth .case {display:flex;align-items:center;justify-content:space-between;gap:10px;padding:9px 14px}
  .tme-growth .case + .case {border-left:0;border-top:1px solid var(--line)}
  .tme-growth .hero {padding:14px 18px}
}`;
function Evidence({ j, sources }) {
  return <details><summary className="fold">原始事实与跟踪指标</summary><div className="body">
    {(j.facts || []).map(f => {
      const src = sources.get(String(f.source_id));
      return <p key={f.id}><b>{f.title}</b>{f.statement} <Text type="secondary">（{f.verify_status || '待核验'}）</Text>
        {src?.url ? <Link href={src.url} target="_blank" rel="noreferrer">{src.title}</Link> : src?.title}</p>;
    })}
    <p>相关论点　{(j.theses || []).map(t => <Tag key={t.id}>{t.code} · {t.status}</Tag>)}</p>
    <p>跟踪指标　{(j.basis_metrics || []).map(m => m.name).join('、') || '待补'}</p>
  </div></details>;
}
function Assumption({j,input,sources}) {
  const [title,hint] = assumptions[j.code] || [j.title,j.parameter];
  const sections = [['事实',j.fact_layer],['判断',j.judgment],['推导',j.transmission],['反证',j.counter_evidence],
    ['何时重估',j.change_threshold],['观察条件',j.no_change_condition]];
  return <details><summary className="assumption"><span>{title}</span><strong>{input}</strong><span className="hint">{hint}</span></summary>
    <div className="body">
      {sections.filter(([,value])=>value).map(([label,value])=><p key={label}><b>{label}</b>{value}</p>)}
      <Evidence j={j} sources={sources}/>
      <p><Link href="/admin/__BASIS_UID__">编辑假设依据 · {j.code}</Link>　<Text type="secondary">{j.status}</Text></p>
    </div>
  </details>;
}
function Page({ d }) {
  const {token} = theme.useToken();
  const {unit:u, row, value:v, basis, sources} = d;
  if (!u || !row || !v) return <Alert showIcon type="warning" message="在线音乐与音频业务的增长或盈利底稿待补。" />;
  const toNum = x => present(x) ? Number(x) : null;
  const [e,g,ro,n,h] = [u.earnings,row.growth,row.ronic,row.adv_years,u.h].map(toNum);
  const inputs = {'J-GROW':pct(g),'J-GROW-R':pct(ro),'J-GROW-N':n == null ? '永续' : n+' 年'};
  const reinvest = g === 0 ? 0 : g != null && ro > 0 ? g/ro : null;
  const spend = e != null && reinvest != null ? e*reinvest : null;
  const perShare = present(v.full_ps) && present(v.epv_ps) ? v.full_ps-v.epv_ps : null;
  const cases = [
    ['优势期取 5 年',premium(e,g,ro,5,h)],
    ['新增回报等于门槛 '+pct(h),premium(e,g,h,n,h)],
    ['新增回报取 4%',premium(e,g,0.04,n,h)],
  ];
  return <article className="tme-growth" style={{'--ink':token.colorText,'--muted':token.colorTextSecondary,
    '--line':token.colorBorderSecondary,'--tint':token.colorFillQuaternary,'--accent':token.colorPrimary}}>
    <style>{style}</style>
    <header className="hero"><h2>腾讯音乐的增长价值</h2>
      <div><strong className="amount">{fmt(u.growth_value)}</strong><span className="unit">亿元</span></div>
      <p className="sub">每股增长价值 {fmt(perShare)} 元 · 主估值采用{v.value_layer}</p>
    </header>
    <section><h3>三项增长假设</h3>
      {Object.keys(assumptions).some(code => !basis.some(j=>j.code===code)) &&
        <Alert type="warning" showIcon message="部分参数缺少依据，请检查增长编辑页。"/>}
      {basis.map(j=><Assumption key={j.id} j={j} input={inputs[j.code]} sources={sources}/>)}
    </section>
    <section><h3>改变一项假设，增长还值多少？ <Text type="secondary">（亿元）</Text></h3>
      <div className="cases">{cases.map(([label,value])=><div className="case" key={label}>
        <span className="hint">{label}</span><strong>{fmt(value)}</strong>
      </div>)}</div>
    </section>
    <div className="notes"><details><summary className="fold">估值计算与检查</summary><div className="body">
      <p><b>经营价值</b>截至 {String(u.as_of).slice(0,10)}，无增长价值 {fmt(u.epv)} 亿元，加上增长后为 {fmt(u.full_value)} 亿元。</p>
      <p><b>每股价值</b>按统一门槛滚算至今，无增长 {fmt(v.epv_ps)} 元，含增长 {fmt(v.full_ps)} 元。按最近股价计算的含增长隐含回报为 {pct(v.irr_full)}。</p>
      <p><b>首年再投入</b>现金收益 {fmt(e)} 亿元 × 再投入比例 {pct(reinvest)}（盈利增速 ÷ 新增回报）＝ {fmt(spend)} 亿元。首年可分配 {fmt(e!=null && spend!=null ? e-spend : null)} 亿元，次年需新增收益 {fmt(e!=null && g!=null ? e*g : null)} 亿元。</p>
      <p><b>无增长检验</b>盈利停止增长时，增长价值为 {fmt(premium(e,0,ro,n,h))} 亿元。优势期末保留已形成的盈利，后续投入按零超额回报处理。 <Link href={official.method} target="_blank">Greenwald 访谈</Link></p>
      {d.checks.map(c=><p key={c.code}><b>{c.name} · {c.result}</b>{c.detail}</p>)}
    </div></details>
    <details><summary className="fold">三季报复核与来源 · 2026 年 11 月 18 日</summary><div className="body">
      <p>会员收入同比增长 9.2%，含喜马拉雅并表。营销及消费服务增 12.1%，社交娱乐等降 15.7%。集团毛利率从 43.5% 降至 42.8%，本次沿用原增长假设。</p>
      <Space wrap><Link href={official.fy} target="_blank">2025 全年</Link><Link href={official.q2} target="_blank">2026 二季度</Link><Link href={official.q3} target="_blank">2026 三季度</Link></Space>
    </div></details></div>
  </article>;
}
function App() {
  const [data,setData] = React.useState(null);
  const [error,setError] = React.useState('');
  React.useEffect(() => {load().then(setData).catch(e=>setError(String(e)));}, []);
  if (error) return <Alert type="error" message={error}/>;
  return data ? <Page d={data}/> : <Text type="secondary">正在读取增长底稿…</Text>;
}
ctx.render(<App/>);
