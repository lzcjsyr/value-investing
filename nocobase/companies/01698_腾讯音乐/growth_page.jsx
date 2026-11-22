const { React, antd } = ctx.libs;
const { Alert, Typography, Tag, InputNumber, theme } = antd;
const { Text, Link } = Typography;

const known = (x) => x !== null && x !== undefined && x !== '' && Number.isFinite(Number(x));
const fmt = (x, d = 2) => (known(x) ? Number(x).toLocaleString('zh-CN', { minimumFractionDigits: d, maximumFractionDigits: d }) : '—');
const sfmt = (x, d = 2) => (!known(x) ? '—' : (Number(x) > 0 ? '+' : '') + fmt(x, d));
const pct = (x, d = 1) => (known(x) ? `${(Number(x) * 100).toFixed(d)}%` : '—');

const OFFICIAL = {
  q3: 'https://ir.tencentmusic.com/2026-11-17-Tencent-Music-Entertainment-Group-Announces-Third-Quarter-2026-Unaudited-Financial-Results',
  method: 'https://www.fool.com/investing/general/2013/10/11/an-interview-with-bruce-greenwald-value-investing.aspx',
};

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
  const [units, values, growth, epv, basis, checks] = await Promise.all([
    list('vi_gw_unit', scope), list('vi_gw_value', scope), list('vi_growth', scope, ['judgments']),
    list('vi_epv', scope), list('vi_judgment', scope), list('vi_check', scope)
  ]);
  const unit = units.find((x) => x.business_code === 'B1');
  const own = (x) => unit && String(x.business_id) === String(unit.business_id);
  const row = growth.find(own);
  if (!unit || !row || !values.length) throw new Error('第三层缺少业务、增长参数或估值结果。');
  const plan = JSON.parse(row.revenue_plan || 'null');
  const lines = epv.filter(own);
  const revs = lines.filter((x) => x.section === '收入');
  const revenues = new Map(revs.map((x) => [x.name, Number(x.normalized)]));
  const taxRate = lines.find((x) => x.section === '所得税')?.value;
  if (!Array.isArray(plan) || plan.length !== revenues.size || plan.length !== revs.length ||
      new Set(plan.map((p) => p.name)).size !== plan.length || !plan.every((p) => revenues.has(p.name) && [p.early,p.late,p.margin].every(known)) ||
      !revs.every((x) => known(x.normalized)) || ![taxRate,unit.earnings,unit.epv,unit.attrib,unit.pre_adj,unit.post_adj,unit.ebit_reported,unit.h,row.adv_years,row.ronic].every(known) ||
      unit.h <= 0 || row.ronic <= 0 || row.adv_years < 0 || row.adv_years > 100) {
    throw new Error('请核对第二层收入项目、正常化金额和第三层分项预测参数。');
  }
  const ids = new Set((row.judgments || []).map((x) => String(x.id)));
  return { co, unit, value: values[0], row, plan, revenues, taxRate, lines, basis: basis.filter((x) => ids.has(String(x.id))),
    checks: checks.filter((c) => ['G03','G04'].includes(c.code)) };
}

const style = `
.tme-g {max-width:1180px;margin:0 auto;padding:4px 4px 28px;color:var(--ink);font-variant-numeric:tabular-nums;line-height:1.55;container-type:inline-size}
.tme-g * {box-sizing:border-box}
.tme-g h2,.tme-g h3,.tme-g p {margin:0}
.tme-g .hero {display:grid;grid-template-columns:minmax(0,1.12fr) minmax(0,1fr);gap:20px;padding:20px 24px;background:var(--tint);border:1px solid var(--line);border-radius:12px;align-items:center}
.tme-g .eyebrow {font-size:13px;color:var(--muted);font-weight:500;display:flex;align-items:center;flex-wrap:wrap;gap:8px}
.tme-g .num-row {display:flex;align-items:baseline;gap:8px;margin:6px 0 10px;flex-wrap:wrap}
.tme-g .hero-num {font-size:clamp(34px,4.6cqw,46px);font-weight:700;letter-spacing:-1.4px;line-height:1.12;color:var(--ink)}
.tme-g .hero-unit {font-size:16px;font-weight:600;color:var(--muted)}
.tme-g .badges {display:flex;flex-wrap:wrap;gap:6px 14px;font-size:13.5px;color:var(--muted)}
.tme-g .verdict {background:var(--card);border:1px solid var(--line);border-left:4px solid var(--ok);border-radius:10px;padding:14px 16px}
.tme-g .verdict-note {padding-top:8px;border-top:1px dashed var(--line);font-size:12.5px;color:var(--muted);line-height:1.55}
.tme-g .verdict-note b {color:var(--ink)}
.tme-g .sec {margin-top:16px;background:var(--card);border:1px solid var(--line);border-radius:12px;padding:16px 20px}
.tme-g .sec-head {display:flex;justify-content:space-between;align-items:baseline;flex-wrap:wrap;gap:6px 16px;margin-bottom:12px}
.tme-g .sec-head h3 {font-size:15.5px;font-weight:600}
.tme-g .sec-sub {font-size:12.5px;color:var(--muted)}
.tme-g .pbtn {appearance:none;border:1px solid var(--line);background:var(--tint-soft);color:var(--ink);font-size:12.5px;padding:5px 11px;border-radius:8px;cursor:pointer;font-weight:500}
.tme-g .pbtn:hover {border-color:var(--primary)}
.tme-g table.mx {width:100%;border-collapse:collapse;font-size:12.5px;border:1px solid var(--line);border-radius:8px;overflow:hidden}
.tme-g .mx th,.tme-g .mx td {padding:7px 8px;text-align:right;border:1px solid var(--line-soft);white-space:nowrap}
.tme-g .mx th {background:var(--tint);color:var(--muted);font-weight:600}
.tme-g .mx th:first-child,.tme-g .mx td:first-child {text-align:left;font-weight:600}
.tme-g .nav-grid {display:grid;grid-template-columns:repeat(4,minmax(0,1fr));gap:12px;margin-top:16px}
.tme-g .nav-card {display:flex;flex-direction:column;justify-content:space-between;gap:5px;padding:12px 14px;background:var(--card);border:1px solid var(--line);border-radius:10px;text-decoration:none;color:var(--ink)}
.tme-g .nav-card:hover {border-color:var(--primary);background:var(--tint-soft)}

@container (max-width:760px) {.tme-g .hero{grid-template-columns:1fr}.tme-g .nav-grid{grid-template-columns:1fr 1fr}}
.tme-g .scroll {overflow-x:auto;margin:10px 0}
.tme-g .scroll th:first-child {position:sticky;left:0;background:var(--card);text-align:left;z-index:1}
.tme-g .controls {display:flex;flex-wrap:wrap;align-items:center;gap:12px;margin:14px 0}
.tme-g .controls label {display:flex;align-items:center;gap:8px}
.tme-g .ant-input-number-group-wrapper {width:94px}
.tme-g .note,.tme-g details p {font-size:13px;color:var(--muted);margin:9px 0}
.tme-g details {margin:10px 0}
.tme-g summary {cursor:pointer}
`;


const EDIT_MODE = __GROWTH_EDIT_MODE__;
const sum = (numbers) => numbers.reduce((total, value) => total + value, 0);

function forecast(d, plan, ro, years) {
  const u = d.unit;
  const h = Number(u.h);
  const taxRate = Number(d.taxRate);
  const afterTax = (1 - taxRate) * Number(u.attrib);
  const bases = plan.map((p) => d.revenues.get(p.name));
  const gap = (sum(plan.map((p, i) => bases[i] * p.margin)) - Number(u.ebit_reported)) / Number(u.revenue);
  const margins = plan.map((p) => p.margin - gap);
  const statement = (revenues) => {
    const profits = revenues.map((rev, i) => rev * margins[i]);
    const revenue = sum(revenues);
    const core = sum(profits);
    const ebit = core + Number(u.pre_adj);
    const tax = ebit * taxRate;
    const beforeMinority = ebit - tax + Number(u.post_adj);
    const earnings = beforeMinority * Number(u.attrib);
    return { revenues, profits, revenue, costs: revenue - core, core, ebit, tax, minority: beforeMinority - earnings, earnings };
  };
  const baseline = statement(bases);
  const rows = [];
  const contributions = plan.map(() => 0);
  let previous = baseline;
  for (let year = 1; year <= years; year++) {
    const next = statement(previous.revenues.map((rev, i) => rev * (1 + (year <= 3 ? plan[i].early : plan[i].late))));
    const deltas = next.profits.map((profit, i) => (profit - previous.profits[i]) * afterTax);
    const investments = deltas.map((delta) => Math.max(0, delta) / ro);
    const discount = (1 + h) ** (-year);
    deltas.forEach((delta, i) => { contributions[i] += (delta / h - investments[i]) * discount; });
    const investment = sum(investments);
    const flow = previous.earnings - investment;
    rows.push({ ...next, year, opening: previous.earnings, investment, flow, pv: flow * discount });
    previous = next;
  }
  const terminal = previous.earnings / h / (1 + h) ** years;
  const flowsPV = sum(rows.map((r) => r.pv));
  return { baseline, rows, margins, contributions, terminal, flowsPV, full: terminal + flowsPV, end: previous };
}

function Scenario({ d }) {
  const { token } = theme.useToken();
  const { unit: u, value: v, row, plan: saved } = d;
  const [plan, setPlan] = React.useState(saved);
  const [roPct, setRo] = React.useState(Number(row.ronic) * 100);
  const [years, setYears] = React.useState(Number(row.adv_years));
  const [status, setStatus] = React.useState('');
  const [busy, setBusy] = React.useState(false);
  const [savedNote, setSavedNote] = React.useState(row.note || '');
  const valid = Number.isInteger(years) && years >= 0 && years <= 100 && known(roPct) && roPct > 0 &&
    plan.every((p) => [p.early,p.late,p.margin].every(known) && p.early >= -1 && p.late >= -1);
  const model = valid ? forecast(d, plan, roPct / 100, years) : null;
  const savedModel = forecast(d, saved, Number(row.ronic), Number(row.adv_years));
  const aligned = u.complete && known(u.full_value) && Math.abs(savedModel.full - Number(u.full_value)) < 0.001 &&
    Math.abs(savedModel.baseline.earnings - Number(u.earnings)) < 0.0001;
  const reset = () => { setPlan(saved); setRo(Number(row.ronic) * 100); setYears(Number(row.adv_years)); setSavedNote(row.note || ''); setStatus(''); };
  const setRate = (name, field, value) => setPlan((prev) => prev.map((p) => p.name === name ? { ...p, [field]: value === null ? null : value / 100 } : p));
  const roll = known(v.epv_ps) && Number(v.epv_total) + Number(v.bridge) !== 0
    ? Number(v.epv_ps) / (Number(v.epv_total) + Number(v.bridge)) : null;
  const perShare = model && roll !== null ? (model.full + Number(v.bridge)) * roll : null;
  const save = async () => {
    if (!valid || busy) return;
    setBusy(true);
    try {
      const resource = ctx.makeResource('MultiRecordResource');
      resource.setResourceName('vi_growth');
      const [fresh] = await list('vi_growth', { id: { $eq: row.id } });
      if (fresh.updated_at !== row.updated_at) throw new Error('基准已更新，请刷新页面后重新比较。');
      await resource.update(row.id, { revenue_plan: JSON.stringify(plan), ronic: roPct / 100, adv_years: years, note: savedNote });
      await d.reload(true);
    } catch (e) { setStatus(String(e)); }
    finally { setBusy(false); }
  };
  const vars = { '--ink': token.colorText, '--muted': token.colorTextSecondary, '--card': token.colorBgContainer,
    '--tint': token.colorFillQuaternary, '--tint-soft': token.colorFillAlter, '--line': token.colorBorderSecondary,
    '--line-soft': token.colorSplit, '--primary': token.colorPrimary, '--ok': token.colorSuccessText, '--err': token.colorError };
  const costLines = d.lines.filter((line) => line.section === '成本费用');
  const overhead = costLines.filter((line) => line.formula !== '−营业成本');
  const overheadAmount = sum(overhead.map((line) => Number(line.normalized)));
  const costAt = (line, statement) => line.formula === '−营业成本'
    ? statement.costs - overheadAmount * statement.revenue / Number(u.revenue)
    : Number(line.normalized) * statement.revenue / Number(u.revenue);
  const statements = model ? [model.baseline, ...model.rows] : [];
  const stmtRow = (label, getter) => <tr key={label}><th scope="row">{label}</th>{statements.map((s, i) => <td key={i}>{fmt(getter(s), 2)}</td>)}</tr>;
  const adjustments = (section) => d.lines.filter((line) => line.section === section).map((line) =>
    stmtRow(line.name, () => (line.direction === '减' ? -1 : 1) * Number(line.normalized)));
  const incomeRow = (p, i) => <tr key={p.name}><th scope="row">{p.name}</th><td>{fmt(d.revenues.get(p.name))}</td>
    {['early','late','margin'].map((field, j) => <td key={field}><InputNumber aria-label={p.name + ['前三年增速','后续增速','分摊利润率'][j]} value={known(p[field]) ? Number((p[field] * 100).toFixed(5)) : null} addonAfter="%" min={field === 'margin' ? undefined : -100} step={1} onChange={(val) => setRate(p.name,field,val)} /></td>)}
    <td>{pct(model?.margins[i], 2)}</td><td>{fmt(model?.end.revenues[i])}</td><td>{sfmt(model?.contributions[i])}</td></tr>;
  return <article className="tme-g" style={vars}><style>{style}</style>
    <header className="hero"><div><div className="eyebrow">腾讯音乐 · 第三层 · {String(d.co.as_of).slice(0,10)} 估值基准</div>
      <h2>{EDIT_MODE ? '编辑分项增长假设' : '分项收入与增长价值'}</h2>
      <div className="num-row"><strong className="hero-num">{fmt(model?.full, 1)}</strong><span>亿元 · 含增长经营价值</span></div>
      <div className="badges"><span>无增长 EPV <b>{fmt(u.epv,1)} 亿</b></span><span>增长净贡献 <b>{model ? sfmt(model.full - u.epv,1) : '—'} 亿</b></span></div></div>
      <div className="verdict"><div>已保存基准 <b>{fmt(u.full_value,1)} 亿元</b></div><div>本次试算含独立资产与负债桥 <b>{fmt(perShare)} 元/普通股</b></div>
      <div className="verdict-note">经营价值按估值日折现。每股价值沿用第二层的股数、资产负债桥及滚算日期。折现门槛 {pct(u.h)}。</div></div></header>
    {!aligned && <Alert type="warning" showIcon message="基期或基准价值未与数据库对齐，请复核第二层输入并刷新。"/>}
    <section className="sec"><div className="sec-head"><h3>收入预测与分项贡献</h3><span className="sec-sub">金额均为人民币亿元</span></div>
      <div className="scroll"><table className="mx"><thead><tr>{['收入来源','第二层基期','第 1–3 年增速','第 4 年起增速','研究分摊利润率','校准后利润率','期末收入','增长价值贡献'].map((t) => <th key={t}>{t}</th>)}</tr></thead><tbody>{plan.map(incomeRow)}</tbody></table></div>
      <p className="note">分业务经营利润率为研究假设。按收入等比例分摊基期利润差额，使三项经营利润之和等于第二层的 {fmt(u.ebit_reported)} 亿元。预测期沿用校准后的分项利润率，集团利润率随收入组合变化。</p>
      <div className="controls"><label>新增投资税后回报 <InputNumber aria-label="新增投资税后回报" addonAfter="%" value={roPct} min={0.1} step={1} onChange={setRo}/></label>
      <label>优势期 <InputNumber aria-label="优势期" addonAfter="年" min={0} max={100} precision={0} value={years} onChange={setYears}/></label>
      <button className="pbtn" onClick={reset}>恢复已保存基准</button><button className="pbtn" onClick={() => setPlan(plan.map((p) => ({...p,early:0,late:0})))}>各项零增长</button>
      <button className="pbtn" onClick={() => setRo(Number(u.h)*100)}>新增回报等于门槛</button></div>
      {EDIT_MODE ? <div className="controls"><label>假设说明 <antd.Input.TextArea value={savedNote} onChange={(e) => setSavedNote(e.target.value)}/></label>
        <antd.Button type="primary" disabled={!valid || !aligned} loading={busy} onClick={save}>保存为第三层基准</antd.Button>{d.saved && <Text type="success">基准已保存</Text>}{status && <Text type="danger">{status}</Text>}</div>
        : <p className="note">当前调整仅供试算。在「增长（编辑）」中可以保存基准。</p>}
      {!valid && <Alert type="warning" message="请填齐各项假设，增速下限为 −100%，新增回报须为正数，优势期须为 0–100 的整数。"/>}
    </section>
    {model && <><section className="sec"><div className="sec-head"><h3>逐年收入与正常化利润</h3><span className="sec-sub">基期为第二层，各列为当年投入完成后的年化经营水平</span></div>
      <div className="scroll"><table className="mx"><thead><tr><th>项目</th><th>基期</th>{model.rows.map((r) => <th key={r.year}>第 {r.year} 年末</th>)}</tr></thead><tbody>
      {plan.map((p,i) => stmtRow(p.name, (s) => s.revenues[i]))}{stmtRow('合计收入',s=>s.revenue)}
      {plan.map((p,i) => stmtRow(p.name+' · 经营利润',s=>s.profits[i]))}
      {costLines.map((line) => stmtRow(line.name, (s) => costAt(line, s)))}{stmtRow('合计营业成本及经营费用',s=>s.costs)}{stmtRow('经营利润',s=>s.core)}{adjustments('税前调整')}{stmtRow('调整后经营利润',s=>s.ebit)}
      {stmtRow('经营所得税',s=>s.tax)}{adjustments('税后调整')}{stmtRow('少数股东份额',s=>s.minority)}{stmtRow('归母可持续现金收益',s=>s.earnings)}
      </tbody></table></div><p className="note">销售及行政费用按第二层费用率随收入变化，营业成本由各业务组合对应的经营利润倒推。沿用第二层的经营税率 {pct(d.taxRate,2)}、归母比例 {pct(u.attrib)}、税前与税后调整金额。维持性投入已计入可持续收益。</p></section>
      <section className="sec"><div className="sec-head"><h3>从盈利到可分配现金</h3><span className="sec-sub">各年现金流现值 {fmt(model.flowsPV)} ＋ 稳态终值现值 {fmt(model.terminal)} ＝ {fmt(model.full)} 亿元</span></div>
      <p className="note">当年可分配现金等于期初可持续收益减增长投入。每条线新增的税后归母盈利除以新增投资回报率，得到所需投入。衰退减少后续盈利，资本回收按零计。第 {years + 1} 年起收入与利润持平，按期末收益 {fmt(model.end.earnings)} 亿元资本化。</p>
      <div className="scroll"><table className="mx"><thead><tr>{['年度','期初收益','增长再投资','可分配现金','现金流现值','期末收益'].map(t=><th key={t}>{t}</th>)}</tr></thead><tbody>{model.rows.map(r=><tr key={r.year}><th>第 {r.year} 年</th>{[r.opening,r.investment,r.flow,r.pv,r.earnings].map((v,i)=><td key={i}>{fmt(v)}</td>)}</tr>)}</tbody></table></div>
      </section></>}
    <section className="sec"><h3>收入判断与竞争优势</h3>
      <p className="note">2026 年三季度会员收入同比增长 9.2%，涵盖喜马拉雅并表。营销及消费增长 12.1%，受演出与周边带动。社交娱乐同比下降 15.7%。预测采用第二层的会员单季年化、营销及消费滚动四季、社交娱乐单季年化基线。广告、演出与周边按公司合并披露口径预测。</p>
      <p className="note">基准研究将会员升级与免费产品分流合并考虑，营销及消费随规模扩大分两段减速，社交娱乐延续收缩。增长的经济价值来自新增资本回报高于门槛；回报仅及门槛时，扩张贡献趋零，原有盈利的衰退仍会减值。本模型用同一新增回报率估算正向盈利增量所需的资本。提价与自然增长可能需要较少增量资本，演出扩张可能需要较多垫资。分项利润率、增速、回报率和优势期均属研究假设。</p>
      <p><Link href={OFFICIAL.q3} target="_blank">腾讯音乐三季度业绩公告</Link>　<Link href={OFFICIAL.method} target="_blank">Greenwald 关于增长、壁垒与资本配置的访谈</Link>　<Link href="/admin/__BASIS_UID__">假设依据</Link></p>
      {d.basis.map(j=><details key={j.id}><summary>{j.title}</summary><p>{j.fact_layer}</p><p>{j.counter_evidence}</p><p>{j.change_threshold}</p></details>)}
      {d.checks.map(c=><p className="note" key={c.code}><Tag>{c.result}</Tag>{c.name} · {c.detail}</p>)}</section>
    <nav className="nav-grid">{[['__AV_UID__','① 资产价值'],['__EPV_UID__','② 盈利能力价值'],['__BRIDGE_UID__','④ 独立资产与负债桥'],['__EQUITY_UID__','⑤ 股权价值汇总']].map(([uid,t])=><Link className="nav-card" key={uid} href={'/admin/'+uid}>{t}</Link>)}</nav></article>;
}

function App() {
  const [data, setData] = React.useState(null);
  const [error, setError] = React.useState('');
  const reload = async (saved = false) => { const next = await load(); setData({ ...next, saved }); };
  React.useEffect(() => { reload().catch((e) => setError(String(e))); }, []);
  if (error) return <Alert type="error" showIcon message={error}/>;
  if (!data) return <Text type="secondary">正在读取分项预测和第二层底稿…</Text>;
  return <Scenario key={data.row.updated_at} d={{ ...data, reload }}/>;
}

ctx.render(<App />);
