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

const RATE_FIELDS = [
  { key: 'gross', label: '综合毛利率', formula: '−营业成本' },
  { key: 'selling', label: '销售费用率', formula: '−销售及营销费用' },
  { key: 'admin', label: '管理费用率', formula: '−一般及行政费用' },
];

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
  const config = JSON.parse(row.revenue_plan || 'null');
  if (config?.model !== 'group_income') throw new Error('缺少集团利润率预测参数，请核对增长底稿。');
  const plan = config.lines;
  const lines = epv.filter(own);
  const revs = lines.filter((x) => x.section === '收入');
  const revenues = new Map(revs.map((x) => [x.name, Number(x.normalized)]));
  const costLines = lines.filter((line) => line.section === '成本费用');
  const rates = {};
  if (!(Number(unit.revenue) > 0) || costLines.some((line) => !RATE_FIELDS.some((f) => f.formula === line.formula))) {
    throw new Error('集团成本费用与第二层科目不匹配，请核对底稿。');
  }
  for (const { key, formula } of RATE_FIELDS) {
    const entries = costLines.filter((line) => line.formula === formula);
    if (!entries.length || !entries.every((line) => known(line.normalized)) || !known(config.rateChanges?.[key])) {
      throw new Error('集团成本或费用率输入不完整。');
    }
    const ratio = entries.reduce((total, line) => total + Number(line.normalized), 0) / Number(unit.revenue);
    rates[key] = key === 'gross' ? 1 - ratio : ratio;
  }
  const taxRate = lines.find((x) => x.section === '所得税')?.value;
  if (!Array.isArray(plan) || plan.length !== revenues.size || plan.length !== revs.length ||
      new Set(plan.map((p) => p.name)).size !== plan.length || !plan.every((p) => revenues.has(p.name) && [p.early,p.late].every(known)) ||
      !revs.every((x) => known(x.normalized)) || ![taxRate,unit.earnings,unit.epv,unit.attrib,unit.pre_adj,unit.post_adj,unit.ebit_reported,unit.h,row.adv_years,row.ronic].every(known) ||
      unit.h <= 0 || row.ronic <= 0 || row.adv_years < 0 || row.adv_years > 100) {
    throw new Error('请核对第二层收入项目、正常化金额和第三层分项预测参数。');
  }
  const ids = new Set((row.judgments || []).map((x) => String(x.id)));
  return { co, unit, value: values[0], row, plan, rates, rateChanges: config.rateChanges, revenues, taxRate, lines, basis: basis.filter((x) => ids.has(String(x.id))),
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
.tme-g .ledger table.mx {overflow:visible;border:0}
.tme-g .ledger .mx th:first-child {width:185px;min-width:145px;max-width:200px;white-space:normal}
.tme-g .ledger .mx .subtotal > * {font-weight:650;padding-block:10px;background:var(--tint);color:var(--ink)}
.tme-g .ledger .mx .cash-result > * {color:var(--primary);background:var(--cash-bg);border-top:2px solid var(--primary);font-weight:700}
.tme-g .ledger .mx .breakdown > * {color:var(--muted);font-weight:400;font-size:12px}
.tme-g .ledger .breakdown th:first-child {padding-left:27px}
.tme-g .ledger .mx tr > :last-child {border-left:2px solid var(--line);font-weight:700}
`;


const EDIT_MODE = __GROWTH_EDIT_MODE__;
const sum = (numbers) => numbers.reduce((total, value) => total + value, 0);

function forecast(d, plan, changes, ro, years) {
  const u = d.unit;
  const h = Number(u.h);
  const rates = {
    gross: d.rates.gross + changes.gross,
    selling: d.rates.selling + changes.selling,
    admin: d.rates.admin + changes.admin,
  };
  const statement = (revenues, r) => {
    const revenue = sum(revenues);
    const grossProfit = revenue * r.gross;
    const selling = revenue * r.selling;
    const admin = revenue * r.admin;
    const core = grossProfit - selling - admin;
    const ebit = core + Number(u.pre_adj);
    const tax = ebit * Number(d.taxRate);
    const beforeMinority = ebit - tax + Number(u.post_adj);
    const earnings = beforeMinority * Number(u.attrib);
    return { revenues, revenue, directCost: revenue - grossProfit, grossProfit, selling, admin, core, ebit,
      tax, minority: beforeMinority - earnings, earnings };
  };
  const baseline = statement(plan.map((line) => d.revenues.get(line.name)), d.rates);
  const netMargin = (rates.gross - rates.selling - rates.admin) * (1 - Number(d.taxRate)) * Number(u.attrib);
  const rows = [];
  let previous = baseline;
  for (let year = 1; year <= years; year++) {
    const revenues = previous.revenues.map((rev, i) => rev * (1 + (year <= 3 ? plan[i].early : plan[i].late)));
    const next = statement(revenues, rates);
    const expansion = Math.max(0, next.revenue - previous.revenue);
    const investment = expansion * Math.max(0, netMargin) / ro;
    const flow = previous.earnings - investment;
    rows.push({ ...next, year, opening: previous.earnings, investment, flow, pv: flow / (1 + h) ** year });
    previous = next;
  }
  const terminal = previous.earnings / h / (1 + h) ** years;
  const flowsPV = sum(rows.map((r) => r.pv));
  return { baseline, rows, terminal, flowsPV, full: terminal + flowsPV, end: previous };
}

function Scenario({ d }) {
  const { token } = theme.useToken();
  const { unit: u, value: v, row, plan: saved } = d;
  const [plan, setPlan] = React.useState(saved);
  const [changes, setChanges] = React.useState(d.rateChanges);
  const [roPct, setRo] = React.useState(Number(row.ronic) * 100);
  const [years, setYears] = React.useState(Number(row.adv_years));
  const [status, setStatus] = React.useState('');
  const [busy, setBusy] = React.useState(false);
  const [savedNote, setSavedNote] = React.useState(row.note || '');
  const validRates = RATE_FIELDS.every(({ key }) => known(changes[key])) &&
    d.rates.gross + changes.gross <= 1 && d.rates.selling + changes.selling >= 0 && d.rates.admin + changes.admin >= 0;
  const valid = validRates && Number.isInteger(years) && years >= 0 && years <= 100 && known(roPct) && roPct > 0 &&
    plan.every((p) => [p.early,p.late].every(known) && p.early >= -1 && p.late >= -1);
  const model = valid ? forecast(d, plan, changes, roPct / 100, years) : null;
  const savedModel = forecast(d, saved, d.rateChanges, Number(row.ronic), Number(row.adv_years));
  const aligned = u.complete && known(u.full_value) && Math.abs(savedModel.full - Number(u.full_value)) < 0.001 &&
    Math.abs(savedModel.baseline.earnings - Number(u.earnings)) < 0.0001;
  const reset = () => { setPlan(saved); setChanges(d.rateChanges); setRo(Number(row.ronic) * 100); setYears(Number(row.adv_years)); setSavedNote(row.note || ''); setStatus(''); };
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
      await resource.update(row.id, { revenue_plan: JSON.stringify({ model: 'group_income', lines: plan, rateChanges: changes }), ronic: roPct / 100, adv_years: years, note: savedNote });
      await d.reload(true);
    } catch (e) { setStatus(String(e)); }
    finally { setBusy(false); }
  };
  const vars = { '--ink': token.colorText, '--muted': token.colorTextSecondary, '--card': token.colorBgContainer,
    '--tint': token.colorFillQuaternary, '--tint-soft': token.colorFillAlter, '--line': token.colorBorderSecondary,
    '--line-soft': token.colorSplit, '--primary': token.colorPrimary, '--cash-bg': token.colorPrimaryBg, '--ok': token.colorSuccessText, '--err': token.colorError };
  const statements = model ? [model.baseline, ...model.rows] : [];
  const adjustmentRows = (section) => d.lines.filter((line) => line.section === section).map((line) =>
    [line.name, () => (line.direction === '减' ? -1 : 1) * Number(line.normalized)]);
  const groups = [
    ['合计收入', s => s.revenue, plan.map((p,i) => [p.name, s => s.revenues[i]])],
    ['毛利', s => s.grossProfit, [['营业成本', s => s.directCost]]],
    ['经营利润', s => s.core, [['销售及营销费用', s => s.selling], ['一般及行政费用', s => s.admin]]],
    ['调整后经营利润', s => s.ebit, adjustmentRows('税前调整')],
    ['归母可持续现金收益', s => s.earnings, [['经营所得税', s => s.tax], ...adjustmentRows('税后调整'), ['少数股东份额', s => s.minority]]],
  ];
  const amounts = (get) => statements.map((s,i) => <td key={i}>{fmt(get(s))}</td>);
  const incomeRow = (p, i) => <tr key={p.name}><th scope="row">{p.name}</th><td>{fmt(d.revenues.get(p.name))}</td>
    {['early','late'].map((field, j) => <td key={field}><InputNumber aria-label={p.name + ['前三年增速','后续增速'][j]} value={known(p[field]) ? Number((p[field] * 100).toFixed(5)) : null} addonAfter="%" min={-100} step={1} onChange={(val) => setRate(p.name,field,val)} /></td>)}
    <td>{fmt(model?.end.revenues[i])}</td></tr>;
  return <article className="tme-g" style={vars}><style>{style}</style>
    <header className="hero"><div><div className="eyebrow">腾讯音乐 · 第三层 · {String(d.co.as_of).slice(0,10)} 估值基准</div>
      <h2>{EDIT_MODE ? '编辑分项增长假设' : '分项收入与增长价值'}</h2>
      <div className="num-row"><strong className="hero-num">{fmt(model?.full, 1)}</strong><span>亿元 · 含增长经营价值</span></div>
      <div className="badges"><span>无增长 EPV <b>{fmt(u.epv,1)} 亿</b></span><span>增长净贡献 <b>{model ? sfmt(model.full - u.epv,1) : '—'} 亿</b></span></div></div>
      <div className="verdict"><div>已保存基准 <b>{fmt(u.full_value,1)} 亿元</b></div><div>本次试算含独立资产与负债桥 <b>{fmt(perShare)} 元/普通股</b></div>
      <div className="verdict-note">经营价值按估值日折现。每股价值沿用第二层的股数、资产负债桥及滚算日期。折现门槛 {pct(u.h)}。</div></div></header>
    {!aligned && <Alert type="warning" showIcon message="基期或基准价值未与数据库对齐，请复核第二层输入并刷新。"/>}
    <section className="sec"><div className="sec-head"><h3>分项收入预测</h3><span className="sec-sub">金额均为人民币亿元</span></div>
      <div className="scroll"><table className="mx"><thead><tr>{['收入来源','第二层基期','第 1–3 年增速','第 4 年起增速','期末收入'].map((t) => <th key={t}>{t}</th>)}</tr></thead><tbody>{plan.map(incomeRow)}</tbody></table></div>
    </section>
    <section className="sec"><div className="sec-head"><h3>集团毛利与费用假设</h3><span className="sec-sub">偏移为 0 时沿用第二层正常化比率</span></div>
      <div className="scroll"><table className="mx"><thead><tr><th>项目</th><th>第二层基准</th><th>预测偏移（百分点）</th><th>预测比率</th></tr></thead>
      <tbody>{RATE_FIELDS.map(({ key, label }) => <tr key={key}><th scope="row">{label}</th><td>{pct(d.rates[key],2)}</td>
        <td><InputNumber aria-label={label+'偏移'} value={known(changes[key]) ? Number((100*changes[key]).toFixed(6)) : null} step={0.5}
          onChange={(value) => setChanges((old) => ({ ...old, [key]: value === null ? null : value/100 }))}/></td>
        <td>{known(changes[key]) ? pct(d.rates[key]+changes[key],2) : '—'}</td></tr>)}</tbody></table></div>
      <p className="note">预测期各年按合计收入计算毛利和费用。业务组合变化对集团毛利率的影响可用负偏移试算，例如 −1 个百分点。</p>
      <div className="controls"><label>新增投资税后回报 <InputNumber aria-label="新增投资税后回报" addonAfter="%" value={roPct} min={0.1} step={1} onChange={setRo}/></label>
      <label>优势期 <InputNumber aria-label="优势期" addonAfter="年" min={0} max={100} precision={0} value={years} onChange={setYears}/></label>
      <button className="pbtn" onClick={reset}>恢复已保存基准</button><button className="pbtn" onClick={() => setPlan(plan.map((p) => ({...p,early:0,late:0})))}>各项零增长</button>
      <button className="pbtn" onClick={() => setRo(Number(u.h)*100)}>新增回报等于门槛</button></div>
      {EDIT_MODE ? <div className="controls"><label>假设说明 <antd.Input.TextArea value={savedNote} onChange={(e) => setSavedNote(e.target.value)}/></label>
        <antd.Button type="primary" disabled={!valid || !aligned} loading={busy} onClick={save}>保存为第三层基准</antd.Button>{d.saved && <Text type="success">基准已保存</Text>}{status && <Text type="danger">{status}</Text>}</div>
        : <p className="note">当前调整仅供试算。在「增长（编辑）」中可以保存基准。</p>}
      {!valid && <Alert type="warning" message="请填齐参数。毛利率最高 100%，费用率下限为零，收入增速下限为 −100%，新增回报须为正，优势期取 0–100 的整数。"/>}
    </section>
    {model && <><section className="sec"><div className="sec-head"><h3>逐年收入与正常化利润</h3><span className="sec-sub">金额为人民币亿元</span></div>
      <div className="scroll ledger"><table className="mx"><thead><tr><th>科目</th><th>基期</th>{model.rows.map(r => <th key={r.year}>第 {r.year} 年末</th>)}</tr></thead><tbody>
      {groups.map(([label,get,details],i) => <React.Fragment key={label}>
        {details.map(([name,value]) => <tr className="breakdown" key={name}><th scope="row">{name}</th>{amounts(value)}</tr>)}
        <tr className={i === groups.length-1 ? 'subtotal cash-result' : 'subtotal'}>
          <th scope="row">{label}</th>{amounts(get)}
        </tr>
      </React.Fragment>)}
      </tbody></table></div><p className="note">基期取自第二层。预测毛利等于合计收入乘综合毛利率，销售及管理费用分别按合计收入乘对应费用率。沿用第二层的经营税率 {pct(d.taxRate,2)}、归母比例 {pct(u.attrib)}、税前与税后调整金额。维持性投入已计入可持续收益。</p></section>
      <section className="sec"><div className="sec-head"><h3>从盈利到可分配现金</h3><span className="sec-sub">各年现金流现值 {fmt(model.flowsPV)} ＋ 稳态终值现值 {fmt(model.terminal)} ＝ {fmt(model.full)} 亿元</span></div>
      <p className="note">当年可分配现金等于期初可持续收益减增长投入。增长投入按集团净新增收入乘预测经营利润率、税后及归母比例，再除以新增投资回报率估算。集团收入收缩时投入按零计，维持性开支已在收益中扣除。第 {years + 1} 年起收入与利润持平，按期末收益 {fmt(model.end.earnings)} 亿元资本化。</p>
      <div className="scroll"><table className="mx"><thead><tr>{['年度','期初收益','增长再投资','可分配现金','现金流现值','期末收益'].map(t=><th key={t}>{t}</th>)}</tr></thead><tbody>{model.rows.map(r=><tr key={r.year}><th>第 {r.year} 年</th>{[r.opening,r.investment,r.flow,r.pv,r.earnings].map((v,i)=><td key={i}>{fmt(v)}</td>)}</tr>)}</tbody></table></div>
      </section></>}
    <section className="sec"><h3>收入判断与竞争优势</h3>
      <p className="note">2026 年三季度会员收入同比增长 9.2%，涵盖喜马拉雅并表。营销及消费增长 12.1%，受演出与周边带动。社交娱乐同比下降 15.7%。预测采用第二层的会员单季年化、营销及消费滚动四季、社交娱乐单季年化基线。广告、演出与周边按公司合并披露口径预测。</p>
      <p className="note">基准研究将会员升级与免费产品分流合并考虑，营销及消费随规模扩大分两段减速，社交娱乐延续收缩。集团毛利率和费用率锚定第二层。集团净扩张的再投资估算假设平台可共用部分资源。新增投资能否创造价值取决于其回报能否超过折现门槛，实际占用资金还取决于提价、内容投入和演出垫资。</p>
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
