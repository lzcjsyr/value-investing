const COMPANY = '01698.HK';   // 由 build_overview.py 写入：这个驾驶舱只看这家公司
const IRR_ONLY = false;   // 估值只用“隐含回报 vs 门槛”的公司（build_valuation.PROFILES）：不显示折现率价值与关注价
const { React } = ctx.libs;
const { useState } = React;
const { Card, Col, Row, Statistic, Typography, Alert, Slider, InputNumber, Button, Table: NativeTable, Tag, Space, message } = ctx.libs.antd;


function Table(props) {
  const numberKeys = new Set(['prob', 'probability', 'core', 'm', 'coreValue', 'mature', 'growth', 'invest', 'direct', 'cash', 'inv', 'other', 'vps', 'quote', 'vsPrice', 'irr', 'cashIrr', 'ceiling', 'price', 'np', 'dps', 'g', 'vf', 'pf', 'cf']);
  const cols = (props.columns || []).map((c) => {
    const key = c.dataIndex || c.key;
    const numeric = numberKeys.has(key) || /^h\d{4}$|^y\d{4}$/.test(String(key));
    return { ...c, align: c.align || (numeric ? 'right' : 'left'),
      width: c.width || (numeric ? 140 : key === 'name' || key === 'scenario_name' ? 120 : 200),
      onHeaderCell: (...args) => ({ ...c.onHeaderCell?.(...args), style: { whiteSpace: 'normal', wordBreak: 'normal' } }),
    };
  });
  return <NativeTable {...props} columns={cols} scroll={props.scroll || { x: 'max-content' }}
    style={{ fontVariantNumeric: 'tabular-nums', ...props.style }} />;
}

async function listRows(collectionName, filter, pageSize = 200) {
  const resource = ctx.makeResource('MultiRecordResource');
  resource.setResourceName(collectionName);
  resource.setPageSize?.(pageSize);
  if (filter) resource.setFilter?.(filter);
  await resource.refresh();
  return resource.getData() || [];
}

const fmt = (v, d = 2) => (v === null || v === undefined || Number.isNaN(v) ? '—' : Number(v).toFixed(d));
const pct = (v, d = 2) => (v === null || v === undefined || Number.isNaN(v) ? '—' : (Number(v) * 100).toFixed(d) + '%');

// 这家公司要采的数据源＝它用到的指标（自有、股价、汇率折算、无风险利率、重点跟踪、订阅的宏观数据）。
// 用途由数据库视图 vi_company_metric 汇总，指标的 used_by_codes 来自它；SQL vi_collect_targets 用的是同一个视图。
function ownCollectors(collectors, metrics, companies, coId) {
  const code = companies.find((c) => c.id === coId)?.code;
  const keep = new Set(metrics.filter((m) => m.company_id === coId
    || (code && (m.used_by_codes || '').includes(`,${code},`))).map((m) => m.id));
  return collectors.filter((c) => keep.has(c.metric_id));
}

// 从今天起算的每股股息现值：Σ d/(1+r)^τ ＋ 终年股息×(1+g)/(r−g)/(1+r)^τ_T
function presentValue(flows, terminal, g, r) {
  if (!(r > g) || !terminal) return null;
  let pv = 0;
  for (const f of flows) {
    if (f.tau > 0 && f.dps !== null && f.dps !== undefined) pv += f.dps / Math.pow(1 + r, f.tau);
  }
  return pv + terminal.dps * (1 + g) / (r - g) / Math.pow(1 + r, terminal.tau);
}

try {
  const companies = await listRows('vi_company', { code: { $eq: COMPANY } });
  const company = companies[0];
  if (!company) {
    ctx.render(<Alert type="info" showIcon message={`公司表里没有代码为 ${COMPANY} 的公司`} />);
    return;
  }
  const models = await listRows('vi_model', { company_id: { $eq: company.id }, status: { $eq: '当前' } });
  const model = models[0];
  if (!model) {
    ctx.render(<Alert type="info" showIcon message="这家公司还没有状态为“当前”的估值模型" />);
    return;
  }
  const [valuations, projections, checks, allCollectors, sotpRows, metrics, allCompanies] = await Promise.all([
    listRows('vi_valuation', { model_id: { $eq: model.id } }),
    listRows('vi_projection', { model_id: { $eq: model.id } }, 500),
    listRows('vi_check', { model_id: { $eq: model.id } }),
    listRows('vi_collector'),
    listRows('vi_sotp', { model_id: { $eq: model.id } }),
    listRows('vi_metric', null, 500),
    listRows('vi_company'),
  ]);
  const collectors = ownCollectors(allCollectors, metrics, allCompanies, company.id);
  // 分部加总：核心业务盈利 × 合理倍数 ＋ 非经营部分（可用净现金、对外投资、少数股东等）
  const sotp = sotpRows.slice().sort((a, b) => (a.id || 0) - (b.id || 0));
  const sotpPrimary = model.primary_method === '分部加总' && sotp.length > 0;
  const sotpBase = sotp.find((r) => r.is_base) || sotp[0];
  const scenarios = valuations.slice().sort((a, b) => (a.id || 0) - (b.id || 0)).map((v) => {
    const rows = projections.filter((p) => p.scenario_name === v.scenario_name && p.year > model.base_year && p.year <= model.terminal_year);
    const flows = rows.map((p) => ({ dps: p.dps, tau: (p.year - model.base_year) - model.years_elapsed }));
    const last = rows.find((p) => p.year === model.terminal_year);
    const terminal = last ? { dps: last.dps, tau: (model.terminal_year - model.base_year) - model.years_elapsed } : null;
    return { ...v, flows, terminal };
  });
  const base = scenarios.find((v) => v.is_base) || scenarios[0] || {};
  const count = (r) => checks.filter((c) => c.result === r).length;
  const enabled = collectors.filter((c) => c.enabled);
  const healthy = enabled.filter((c) => c.health === '正常').length;
  const initial = Math.round((model.required_return ?? 0.06) * 1000) / 10;

  function Panel() {
    const [reqPct, setReqPct] = useState(initial);
    const [trialMult, setTrialMult] = useState(null);   // 试算倍数：留空＝用各情景的合理倍数
    const [saving, setSaving] = useState(false);
    const [convertRmb, setConvertRmb] = useState(null);
    const req = reqPct / 100;
    const rows = scenarios.map((v) => {
      const ceiling = presentValue(v.flows, v.terminal, v.terminal_growth, req);
      return {
        key: v.id, name: v.scenario_name, irr: v.implied_irr, cashIrr: v.cash_implied_irr, ceiling,
        price: v.market_price, ok: v.implied_irr !== null && v.implied_irr !== undefined && v.implied_irr >= req,
      };
    });
    const baseRow = rows.find((r) => r.name === base.scenario_name) || rows[0] || {};
    const save = async () => {
      setSaving(true);
      try {
        await ctx.request({ url: 'vi_model:update', method: 'post', params: { filterByTk: model.id }, data: { required_return: req } });
        message.success(`已保存：要求收益率 ${reqPct}%（刷新后结论与图表同步更新）`);
      } catch (e) {
        message.error('保存失败：' + String(e?.message || e));
      } finally {
        setSaving(false);
      }
    };
    const fx = company.latest_fx;
    const toHkd = (value) => fx > 0 && value !== null && value !== undefined ? Number(value) / fx : null;
    // 有“核心盈利”（来自预测计算）就试算核心倍数；只有经营分部时试算成熟业务（盈利×倍数）的倍数
    const hasCore = sotpBase && sotpBase.core_earnings !== null && sotpBase.core_earnings !== undefined;
    const hasSeg = sotpBase && sotpBase.segments_value !== null && sotpBase.segments_value !== undefined;
    const baseMult = (r) => (hasCore ? r.multiple : r.mature_multiple);
    const sotpCalc = sotp.map((r) => {
      const m = trialMult ?? baseMult(r);
      const anchor = hasCore ? r.core_value : (r.mature_value ?? 0);
      const anchorTrial = hasCore ? r.core_earnings * m : (r.mature_earn_pv ?? 0) * m + (r.mature_interim_pv ?? 0);
      const equity = r.equity_value === null || r.equity_value === undefined ? null : r.equity_value - anchor + anchorTrial;
      const vps = equity === null ? null : equity / r.shares;
      return { key: r.id, name: r.scenario_name, prob: r.probability, core: r.core_earnings, m, coreValue: hasCore ? r.core_earnings * m : null,
               mature: hasSeg ? anchorTrial : null, growth: r.growth_value, invest: r.invest_value, direct: r.direct_value, cash: r.usable_net_cash,
               inv: r.investments, other: r.minority_other, fixed: r.fixed_assets, otherAssets: r.other_assets,
               business: r.business_value === null || r.business_value === undefined ? null : r.business_value - anchor + anchorTrial,
               assets: r.asset_value, equity, shares: r.shares, vps, quote: fx && vps !== null ? vps / fx : null,
               vsPrice: r.market_price && vps ? r.market_price / vps - 1 : null };
    });
    const sotpBaseCalc = sotpCalc.find((r) => sotpBase && r.key === sotpBase.id) || sotpCalc[0] || {};
    const hasDirect = sotp.some((r) => r.direct_value !== null && r.direct_value !== undefined);
    const hasInvest = sotp.some((r) => r.invest_value !== null && r.invest_value !== undefined);
    const probs = sotpCalc.filter((r) => r.prob !== null && r.prob !== undefined && r.vps !== null);
    const weighted = probs.length === sotpCalc.length && probs.length > 0
      ? probs.reduce((a, r) => a + r.prob * r.vps, 0) / probs.reduce((a, r) => a + r.prob, 0) : null;
    const quoteReference = sotpPrimary ? (weighted !== null ? weighted : sotpCalc.find((r) => r.name === '悲观')?.vps) : baseRow.ceiling;
    const quoteReferenceTitle = sotpPrimary ? (weighted !== null ? '概率加权价值' : '悲观分部估值') : `回报门槛 ${reqPct}% 的最高买入价`;
    const sotpTitle = !sotpPrimary ? '分部加总（交叉验证）'
      : '主估值：业务估值合计＋资产估值与调整净额';
    const sotpCard = sotp.length === 0 ? null : (
      <Card size="small" style={{ marginBottom: 12 }} title={sotpTitle}>
        <Row gutter={[12, 12]}>
          <Col xs={12} md={6}><Statistic title={`基准每股价值（${trialMult ? '试算倍数' : (hasCore ? '合理倍数' : '成熟业务倍数')} ${fmt(sotpBaseCalc.m, 1)} 倍）`} value={fmt(sotpBaseCalc.vps)} suffix={fx ? `元 ≈ ${fmt(sotpBaseCalc.quote)} 港元` : '元'} /></Col>
          <Col xs={12} md={6}><Statistic title={`市场价（${base.market_date || '—'}）`} value={fmt(sotpBase.market_price)} suffix="元" /></Col>
          <Col xs={12} md={6}><Statistic title="市场价相对基准价值" value={sotpBaseCalc.vsPrice === null ? '—' : pct(sotpBaseCalc.vsPrice, 1)} valueStyle={{ color: sotpBaseCalc.vsPrice < 0 ? '#389e0d' : '#cf1322' }} /></Col>
          {weighted !== null
            ? <Col xs={12} md={6}><Statistic title="概率加权每股价值" value={fmt(weighted)} suffix={fx ? `元 ≈ ${fmt(weighted / fx)}` : '元'} /></Col>
            : <Col xs={12} md={6}><Statistic title="市场给核心业务的隐含倍数（基准）" value={fmt(sotpBase.implied_core_multiple, 1)} suffix="倍" /></Col>}
        </Row>
        {hasSeg ? (
          <Row gutter={[12, 12]} style={{ marginTop: 8 }}>
            <Col xs={12} md={6}><Statistic title="市场隐含成熟业务倍数（本模型）" value={`${fmt(sotpBase.implied_mature_multiple, 1)}（${fmt(sotpBase.mature_multiple, 1)}）`} suffix="倍" /></Col>
            <Col xs={12} md={6}><Statistic title="市场隐含成长业务价值（本模型）" value={`${fmt(sotpBase.implied_growth_value, 0)}（${fmt(sotpBase.growth_value, 0)}）`} suffix="亿元" /></Col>
            {hasDirect
              ? <Col xs={12} md={6}><Statistic title="直接估值业务（可比公司或主观判断）" value={fmt(sotpBase.direct_value, 0)} suffix="亿元" /></Col>
              : <Col xs={12} md={6}><Statistic title="投入期业务（承诺投入的成本）" value={fmt(sotpBase.invest_value, 0)} suffix="亿元" /></Col>}
            <Col xs={12} md={6}><Statistic title="关注价（低档/高档边际）" value={`${fmt(sotpBase.watch_low)} / ${fmt(sotpBase.watch_high)}`} suffix="元" /></Col>
          </Row>
        ) : null}
        <Space wrap align="center" style={{ margin: '8px 0' }}>
          <Typography.Text strong>{hasCore ? '试算倍数' : '试算成熟业务倍数'}</Typography.Text>
          <Slider style={{ width: 240 }} min={3} max={30} step={0.5} value={trialMult ?? baseMult(sotpBase)} onChange={(v) => setTrialMult(v)} />
          <InputNumber min={1} max={60} step={0.5} value={trialMult ?? Number(fmt(baseMult(sotpBase), 1))} onChange={(v) => setTrialMult(v)} addonAfter="倍" />
          <Button onClick={() => setTrialMult(null)}>恢复各情景倍数</Button>
        </Space>
        {(() => {
          // 价值桥：每行一个组成部分，每列一个情景；① 业务估值 ＋ ② 资产估值与调整净额 ＝ ③ 股权价值 → 每股价值
          const coreOnly = hasCore && !hasSeg;
          const anyNonZero = (k) => sotpCalc.some((r) => r[k] !== null && r[k] !== undefined && Number(r[k]) !== 0);
          const signed = (v, d = 0) => (v === null || v === undefined ? '—' : (Number(v) > 0 ? '＋' : Number(v) < 0 ? '−' : '') + fmt(Math.abs(Number(v)), d));
          const lines = [
            { key: 'h1', kind: 'head', label: '① 业务估值' },
            ...(hasCore ? [
              { key: 'core', label: `核心盈利（${sotpBase.core_year} 年）`, v: (r) => fmt(r.core, 1) },
              { key: 'm', label: '× 倍数', v: (r) => `${fmt(r.m, 1)} 倍` },
            ] : []),
            ...(hasCore && !coreOnly ? [{ key: 'coreValue', label: '核心业务价值', v: (r) => fmt(r.coreValue, 0) }] : []),
            ...(hasSeg ? [
              { key: 'mature', label: '成熟业务（盈利×倍数）', v: (r) => fmt(r.mature, 0) },
              { key: 'growth', label: '成长业务', v: (r) => fmt(r.growth, 0) },
            ] : []),
            ...(hasSeg && hasInvest ? [{ key: 'invest', label: '投入期业务（承诺投入的成本）', v: (r) => fmt(r.invest, 0) }] : []),
            ...(hasSeg && hasDirect ? [{ key: 'direct', label: '直接估值业务', v: (r) => fmt(r.direct, 0) }] : []),
            { key: 'business', kind: 'total', label: coreOnly ? '＝ 业务估值合计（核心盈利 × 倍数）' : '＝ 业务估值合计', v: (r) => fmt(r.business, 0) },
            { key: 'h2', kind: 'head', label: '② 资产估值与调整' },
            { key: 'cash', label: '可用净现金（现金 − 带息负债 − 经营所需现金 − 汇出成本）', v: (r) => signed(r.cash) },
            { key: 'inv', label: '对外投资（折价后）', v: (r) => signed(r.inv) },
            ...(anyNonZero('fixed') ? [{ key: 'fixed', label: '独立固定资产', v: (r) => signed(r.fixed) }] : []),
            ...(anyNonZero('otherAssets') ? [{ key: 'otherAssets', label: '其他非经营资产', v: (r) => signed(r.otherAssets) }] : []),
            { key: 'other', label: '少数股东权益与其他调整', v: (r) => signed(r.other) },
            { key: 'assets', kind: 'total', label: '＝ 资产估值与调整净额', v: (r) => signed(r.assets) },
            { key: 'h3', kind: 'head', label: '③ 每股价值' },
            { key: 'equity', kind: 'total', label: '股权价值 ＝ ① ＋ ②', v: (r) => fmt(r.equity, 0) },
            { key: 'shares', label: '÷ 股本（亿股）', v: (r) => fmt(r.shares, 2) },
            { key: 'vps', kind: 'final', label: '＝ 每股价值', v: (r) => (r.vps === null ? '—' : `${fmt(r.vps)} 元`) },
            ...(fx ? [{ key: 'quote', label: '折合港元', v: (r) => (r.quote === null ? '—' : `${fmt(r.quote)} 港元`) }] : []),
            { key: 'vsPrice', label: `市场价 ${fmt(sotpBase.market_price)} 元相对每股价值`, v: (r) => (r.vsPrice === null ? '—' : pct(r.vsPrice, 1)),
              color: (r) => (r.vsPrice === null ? undefined : r.vsPrice < 0 ? '#389e0d' : '#cf1322') },
            ...(weighted !== null ? [{ key: 'prob', label: '情景概率', v: (r) => pct(r.prob, 0) }] : []),
          ];
          const baseKey = sotpBase ? sotpBase.id : null;
          const rowStyle = (l) => (l.kind === 'head' ? { background: 'rgba(0,0,0,0.03)', fontWeight: 600 }
            : l.kind === 'total' ? { fontWeight: 600, borderTop: '1px solid rgba(0,0,0,0.15)' }
            : l.kind === 'final' ? { fontWeight: 700, fontSize: 15, borderTop: '2px solid rgba(0,0,0,0.45)' } : {});
          const cellPad = { padding: '6px 12px' };
          return (
            <div style={{ overflowX: 'auto' }}>
              <table style={{ width: '100%', borderCollapse: 'collapse', fontVariantNumeric: 'tabular-nums', fontSize: 13 }}>
                <thead>
                  <tr style={{ borderBottom: '1px solid rgba(0,0,0,0.15)' }}>
                    <th style={{ ...cellPad, textAlign: 'left', fontWeight: 600, width: '46%' }}>亿元（另注明的除外）</th>
                    {sotpCalc.map((r) => (
                      <th key={r.key} style={{ ...cellPad, textAlign: 'right', fontWeight: 600, background: r.key === baseKey ? 'rgba(22,119,255,0.06)' : undefined }}>
                        {r.name}{r.key === baseKey && r.name !== '基准' ? '（基准）' : ''}
                      </th>
                    ))}
                  </tr>
                </thead>
                <tbody>
                  {lines.map((l) => (
                    <tr key={l.key} style={rowStyle(l)}>
                      <td style={{ ...cellPad, paddingLeft: l.kind ? 12 : 28, color: l.kind ? undefined : 'rgba(0,0,0,0.65)' }}>{l.label}</td>
                      {sotpCalc.map((r) => (
                        <td key={r.key} style={{ ...cellPad, textAlign: 'right', background: r.key === baseKey ? 'rgba(22,119,255,0.06)' : undefined,
                                                 color: l.color ? l.color(r) : undefined }}>
                          {l.kind === 'head' ? '' : l.v(r)}
                        </td>
                      ))}
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          );
        })()}
        <Typography.Paragraph type="secondary" style={{ marginTop: 8, marginBottom: 0 }}>
          {hasSeg
            ? <>经营分部按发展阶段估值（明细见「估值 / 业务估值（编辑）」）：成熟业务＝正常化盈利×倍数，倍数＝(1−永续增长率÷新增投资回报率)÷(折现率−永续增长率)；成长业务＝稳态年盈利×退出倍数折回资产负债日，加上到稳态前的期间现金流；投入期业务＝已承诺投入的税后现值加承诺期后年成本（负值）；直接估值业务＝按可比公司或主观判断给出的整体价值。非经营部分统一截至 {sotpBase.as_of}，明细见「估值 / 资产估值与调整（编辑）」。
                市场隐含值＝其余部分按本模型取值时，市值对应的成熟业务倍数或成长业务价值。试算倍数只改成熟业务的倍数。股东回报折现（交叉验证）基准 {fmt(sotpBase.ddm_value)} 元。</>
            : <>合理倍数＝(1−永续增长率÷新增投资回报率)÷(折现率−永续增长率)，可在“情景”里手填覆盖；非经营部分统一截至 {sotpBase.as_of}（与股本同日），明细见「估值 / 资产估值与调整（编辑）」。
                隐含倍数＝(市值−非经营部分)÷核心盈利：市场为核心业务付了几倍。股息贴现口径（交叉验证）基准 {fmt(sotpBase.ddm_value)} 元。</>}
        </Typography.Paragraph>
      </Card>
    );
    return (
      <div>
        <Typography.Title level={4} style={{ marginTop: 0 }}>
          {company.name}（{company.code}）· {model.name}
        </Typography.Title>
        <Row gutter={[16, 8]} style={{ marginBottom: 12 }}>
          <Col xs={8} md={4}><Statistic title="PE (TTM)" value={fmt(company.pe_ttm)} /></Col>
          <Col xs={8} md={4}><Statistic title="PB" value={fmt(company.pb)} /></Col>
          <Col xs={8} md={6}><Statistic title="交易日（akshare 市场口径）" value={company.pe_pb_date || '—'} /></Col>
        </Row>
        {COMPANY.endsWith('.HK') && (
          <Card size="small" title={`港股速览 · ${COMPANY} · 港元 / 普通股`} style={{ marginBottom: 12 }}>
            <Row gutter={[16, 16]}>
              <Col xs={12} md={6}><Statistic title={`港股市场价 · ${company.latest_price_date || '—'}`} value={fmt(company.latest_price_raw)} suffix="港元" /></Col>
              <Col xs={12} md={6}><Statistic title={sotpPrimary ? '基准分部估值' : '基准每股价值'} value={fmt(toHkd(sotpPrimary ? sotpBaseCalc.vps : base.value_today))} suffix="港元" /></Col>
              <Col xs={12} md={6}><Statistic title={quoteReferenceTitle} value={fmt(toHkd(quoteReference))} suffix="港元" /></Col>
              <Col xs={12} md={6}><Statistic title="1 港元折人民币" value={fmt(fx, 4)} suffix="元" /></Col>
            </Row>
            {!(fx > 0) && <Alert type="warning" showIcon message="缺少有效汇率，港元估值暂不换算" />}
            <Space wrap style={{ marginTop: 12 }}>
              <Typography.Text>人民币金额换算</Typography.Text>
              <InputNumber value={convertRmb} onChange={setConvertRmb} min={0} placeholder="输入人民币金额" addonAfter="元" />
              <Typography.Text strong>≈ {fmt(fx > 0 && convertRmb !== null ? convertRmb / fx : null)} 港元</Typography.Text>
            </Space>
            <Typography.Paragraph type="secondary" style={{ marginTop: 8, marginBottom: 0, fontSize: 12 }}>
              换算：人民币价值 ÷ 港元兑人民币汇率。采用数据库与股价日匹配的汇率；汇率指标最新观察日 {metrics.find((m) => m.id === company.price_fx_metric_id)?.latest_date || '—'}。
              下方经营金额和估值底稿仍为人民币，港元结果按同一普通股股本换算。股本与资产假设的核验状态见模型底稿。
            </Typography.Paragraph>
          </Card>
        )}
        {sotpPrimary ? sotpCard : null}
        <Card size="small" title={sotpPrimary ? '交叉验证：股息贴现，按要求收益率估值' : IRR_ONLY ? '估值：按市价买入的隐含年化回报 vs 门槛' : '按要求收益率估值'} style={{ marginBottom: 12 }}>
          <Space wrap align="center" style={{ marginBottom: 8 }}>
            <Typography.Text strong>{IRR_ONLY ? '门槛' : '要求收益率'}</Typography.Text>
            <Slider style={{ width: 240 }} min={3} max={10} step={0.1} value={reqPct} onChange={(v) => setReqPct(v)} />
            <InputNumber min={0.1} max={20} step={0.1} value={reqPct} onChange={(v) => setReqPct(v ?? initial)} addonAfter="%" />
            <Button onClick={() => setReqPct(initial)}>恢复 {initial}%</Button>
            <Button type="primary" loading={saving} onClick={save}>保存为模型默认</Button>
          </Space>
          <Row gutter={[12, 12]}>
            <Col xs={12} md={6}><Statistic title={`市场价（${base.market_date || '—'}${company.latest_fx ? `；原币 ${fmt(company.latest_price_raw)} × 汇率 ${company.latest_fx}` : ''}）`} value={fmt(base.market_price)} suffix="元" /></Col>
            <Col xs={12} md={6}><Statistic title="买入后隐含年化收益率（基准）" value={pct(baseRow.irr)} valueStyle={{ color: baseRow.ok ? '#389e0d' : '#cf1322' }} /></Col>
            <Col xs={12} md={6}><Statistic title={`${IRR_ONLY ? '门槛' : '要求'} ${reqPct}% 的最高买入价（基准）`} value={fmt(baseRow.ceiling)} suffix="元" /></Col>
            <Col xs={12} md={6}><Statistic title="市场价相对最高买入价" value={baseRow.ceiling ? pct(base.market_price / baseRow.ceiling - 1, 1) : '—'} /></Col>
          </Row>
          <Table size="small" pagination={false} style={{ marginTop: 12 }} dataSource={rows} columns={[
            { title: '情景', dataIndex: 'name' },
            { title: '隐含年化收益率', dataIndex: 'irr', render: (v) => pct(v) },
            { title: '现金支持口径', dataIndex: 'cashIrr', render: (v) => pct(v) },
            { title: `${IRR_ONLY ? '门槛' : '要求'} ${reqPct}% 的最高买入价（元）`, dataIndex: 'ceiling', render: (v) => fmt(v) },
            { title: '市场价（元）', dataIndex: 'price', render: (v) => fmt(v) },
            { title: '结论', dataIndex: 'ok', render: (v) => (v ? <Tag color="green">{IRR_ONLY ? '达到门槛' : '达到要求'}</Tag> : <Tag color="red">{IRR_ONLY ? '低于门槛' : '未达到要求'}</Tag>) },
          ]} />
          {!IRR_ONLY && <Typography.Paragraph type="secondary" style={{ marginTop: 8, marginBottom: 0 }}>
            隐含年化收益率＝按今天市场价买入、获得模型预测的股息并按永续增长率增长时的内部收益率，与要求收益率无关；
            最高买入价＝按要求收益率把未来股息折现到今天的每股价值。两者等价：隐含收益率高于要求收益率 ⇔ 市场价低于最高买入价。
          </Typography.Paragraph>}
        </Card>
        {!sotpPrimary ? sotpCard : null}
        {IRR_ONLY ? (
          <Typography.Paragraph type="secondary" style={{ marginTop: 8, marginBottom: 0 }}>
            质量自检：通过 {count('通过')} · 提示 {count('提示')} · 阻断 {count('阻断')}。自动采集（这家公司和通用指标）：{healthy} / {enabled.length} 个数据源正常。
            回报拆解、买入价与假设的影响见「预测与估值 / 估值」。
          </Typography.Paragraph>
        ) : (<>
        <Row gutter={[12, 12]}>
          <Col xs={12} md={6}><Card size="small"><Statistic title={`${sotpPrimary ? '股息贴现·' : ''}今天每股价值（折现率 ${pct(base.discount_rate)}）`} value={fmt(base.value_today)} suffix="元" /></Card></Col>
          <Col xs={12} md={6}><Card size="small"><Statistic title="现金支持价值·今天" value={fmt(base.cash_value_today)} suffix="元" /></Card></Col>
          <Col xs={12} md={6}><Card size="small"><Statistic title={`${sotpPrimary ? '股息贴现·' : ''}关注价（低档/高档边际）`} value={`${fmt(base.watch_low)} / ${fmt(base.watch_high)}`} /></Card></Col>
          <Col xs={12} md={6}><Card size="small"><Statistic title="质量自检" value={`通过 ${count('通过')} · 提示 ${count('提示')} · 阻断 ${count('阻断')}`} /></Card></Col>
        </Row>
        <Typography.Paragraph type="secondary" style={{ marginTop: 8, marginBottom: 0 }}>
          {base.conclusion || ''} 自动采集（这家公司和通用指标）：{healthy} / {enabled.length} 个数据源正常。
        </Typography.Paragraph>
        </>)}
      </div>
    );
  }

  ctx.render(<Panel />);
} catch (error) {
  ctx.render(<Alert type="error" showIcon message="驾驶舱读取失败" description={String(error?.message || error)} />);
}
