"""“<公司> / 预测与估值”的定制页面：历史年度 → 财务模型 → 估值，每家公司只用一个估值逻辑。

  财务模型：每个驱动一行，从收入、成本算到利润和股息，历史实际 → 逐年预测（按情景）→ 假设依据并排；三个情景差在哪；全部假设依据。
  （原名「情景假设」，2026-10-25 改名：它本质是一张财务模型，情景只是其中的切换，和其他公司的「财务模型」页同名。）
  估值：按公司的估值逻辑定制。现在只有“隐含回报”（irr）：把每股股息当票息，求按市场价买入的年化回报，和门槛比。

录入用的表格页（逐年假设、情景、估值模型、假设依据）收进“预测与估值 / 模型底稿”；被这两页取代的只读报表（预测计算、估值结论、
资产与资本、敏感性）、单参数试验和财务模型不再生成页面（build_pages.CUSTOM_VALUATION），表与数据不动。
页面只读数据库（vi_projection / vi_forecast / vi_scenario / vi_valuation / vi_judgment / vi_fin_history），不存任何数字。

  python3 build_valuation.py             # 给 PROFILES 里的公司建缺的页面，把表格页挪进模型底稿、删掉被取代的页面
  python3 build_valuation.py --replace   # 原地改写这两页（改了下面的 JS、标题或 PROFILES 之后用，地址不变）
  python3 build_valuation.py --rebuild   # 删除后重建这两页（地址会变）
"""
import json, sys
from build_pages import state, companies, destroy_page, ensure_group, company_root, valuation_group, nb_json, \
    CUSTOM_VALUATION, COMPANY_MENU, DRAFTS, page_key, sort_menu
from build_overview import apply_page, record

# 每家公司的页面配置。drivers：财务模型页的逐年表，每行一个科目
#   p＝预测计算（随情景变）、f＝逐年假设（各情景相同）、h＝历史年度字段或推导（tax_rate、minority_share、opening_debt）
#   j＝假设依据编号；pct＝按百分比显示；d＝小数位
PROFILES = {
    '600900.SH': {
        'method': 'irr',
        'hurdle_j': 'J-R',   # 门槛的依据
        'logic': '收入基本不增长（发电量 × 电价）；利润增长来自折旧退坡和利息下降；股息＝归母净利润 × 派息率。'
                 '估值把每股股息当成债券票息，看按今天的价格买入能拿到多少年化回报。',
        'drivers': [
            {'section': '收入'},
            {'label': '发电量（亿千瓦时）', 'p': 'volume', 'h': 'volume', 'd': 0, 'j': ['J-Q'], 'how': '逐年假设 × 情景系数'},
            {'label': '电价（元/千瓦时）', 'p': 'price', 'h': 'price', 'd': 4, 'j': ['J-P'], 'how': '逐年假设 × 情景系数'},
            {'label': '营业收入', 'p': 'revenue', 'h': 'revenue', 'strong': True, 'how': '发电量 × 电价'},
            {'section': '成本'},
            {'label': '付现成本', 'p': 'cash_cost', 'j': ['J-COST'], 'how': '逐年假设 × 情景成本系数'},
            {'label': '折旧摊销', 'p': 'depreciation', 'h': 'da', 'j': ['J-DA'], 'how': '机组折旧到期逐年退坡'},
            {'label': '利息', 'p': 'interest', 'h': 'finance_cost', 'j': ['J-DEBT'], 'how': '平均带息负债 × 债务成本（历史为财务费用）'},
            {'label': '　债务成本', 'f': 'cost_of_debt', 'pct': True, 'd': 2, 'j': ['J-DEBT'], 'how': '逐年假设'},
            {'label': '　期末带息负债', 'p': 'debt_close', 'h': 'opening_debt', 'd': 0, 'j': ['J-DEBT'], 'how': '上年末 ＋ 净借款'},
            {'label': '其他净贡献', 'p': 'other_contrib', 'how': '投资收益等净额（逐年假设）'},
            {'section': '利润到股息'},
            {'label': '利润总额', 'p': 'pretax', 'h': 'pretax_profit', 'strong': True, 'how': '收入 − 成本 ＋ 其他净贡献'},
            {'label': '所得税率', 'f': 'tax_rate', 'h': 'tax_rate', 'pct': True, 'd': 2, 'how': '逐年假设'},
            {'label': '少数股东占比', 'f': 'minority_share', 'h': 'minority_share', 'pct': True, 'd': 2, 'how': '逐年假设'},
            {'label': '归母净利润', 'p': 'np_parent', 'h': 'np_parent', 'strong': True, 'how': '利润总额 ×（1 − 税率）×（1 − 少数股东占比）'},
            {'label': '派息率', 'p': 'payout', 'h': 'payout', 'pct': True, 'j': ['J-PAYOUT'], 'how': '逐年假设（公司承诺不低于 70%）'},
            {'label': '每股股息（元）', 'p': 'dps', 'h': 'dps', 'd': 3, 'strong': True, 'how': '股息 ÷ 总股本；估值用的现金流'},
            {'section': '现金（只用于检查股息付不付得出，不改变估值）'},
            {'label': '维持资本开支', 'f': 'maint_capex', 'j': ['J-CB2026'], 'how': '逐年假设'},
            {'label': '扩张资本开支', 'f': 'growth_capex', 'j': ['J-CAPEX', 'J-CB2026'], 'how': '逐年假设；新项目收益未计入收入'},
            {'label': '净借款（负＝还债）', 'f': 'net_borrowing', 'j': ['J-DEBT', 'J-CB2026'], 'how': '逐年假设'},
            {'label': '股东自由现金流', 'p': 'fcfe', 'j': ['J-CASH'], 'strong': True, 'how': '归母净利 ＋ 折旧 − 非现金收益 ＋ 收到分红 − 资本开支 ＋ 净借款'},
            {'label': '计划股息缺口', 'p': 'funding_gap', 'how': '计划股息 − 股东自由现金流（不够的部分）'},
        ],
        # 估值页“什么会改变结论”：在基准情景上一次只动一个假设
        'shocks': [
            {'label': '收入 −5%（发电量或电价）', 'rev': -0.05, 'j': 'J-Q / J-P'},
            {'label': '收入 +5%（发电量或电价）', 'rev': 0.05, 'j': 'J-Q / J-P'},
            {'label': '付现成本 +10%', 'cost': 0.10, 'j': 'J-COST'},
            {'label': '债务成本 +1 个百分点（利率上行）', 'kd': 0.01, 'j': 'J-DEBT'},
            {'label': '派息率降到 70%（承诺下限）', 'payout': 0.70, 'j': 'J-PAYOUT'},
            {'label': '永续增长 0%', 'g': 0.0, 'j': 'J-TV'},
            {'label': '永续增长 2%', 'g': 0.02, 'j': 'J-TV'},
            {'label': '买入价 −10%', 'price': -0.10},
        ],
    },
}

from company_profiles import PROFILES as COMPANY_PROFILES
PROFILES.update(COMPANY_PROFILES)

COMMON = r"""const COMPANY = '__COMPANY__';
const PROFILE = __PROFILE__;
const { React } = ctx.libs;
const { useState } = React;
const { Card, Segmented, Table, Alert, Typography, Space, Tag, Popover, Collapse, Descriptions, Row, Col, Statistic,
        InputNumber, Button, message, theme } = ctx.libs.antd;
const { Text, Paragraph, Title } = Typography;

async function listRows(name, filter, pageSize = 1000) {
  const resource = ctx.makeResource('MultiRecordResource');
  resource.setResourceName(name);
  resource.setPageSize?.(pageSize);
  if (filter) resource.setFilter?.(filter);
  await resource.refresh();
  return resource.getData() || [];
}
const isNum = (v) => v !== null && v !== undefined && v !== '' && !Number.isNaN(Number(v));
const fmt = (v, d = 1) => (isNum(v) ? Number(v).toLocaleString('zh-CN', { minimumFractionDigits: d, maximumFractionDigits: d }) : '—');
const pct = (v, d = 1) => (isNum(v) ? (Number(v) * 100).toFixed(d) + '%' : '—');
const pp = (v) => (isNum(v) ? (Math.abs(v) * 100).toFixed(2) + ' 个百分点' : '—');
const bp = (v) => (isNum(v) ? (v >= 0 ? '+' : '−') + Math.abs(Math.round(v * 10000)) + 'bp' : '—');
const narrow = (typeof window !== 'undefined' ? window.innerWidth : 1200) < 760;
const bySort = (a, b) => (a.sort ?? 0) - (b.sort ?? 0) || a.id - b.id;

// 读这家公司的当前模型及其全部情景、逐年数据
async function load() {
  const [company] = await listRows('vi_company', { code: { $eq: COMPANY } });
  if (!company) throw new Error('公司不存在：' + COMPANY);
  const [model] = await listRows('vi_model', { company_id: { $eq: company.id }, status: { $eq: '当前' } });
  if (!model) return { company };
  const byModel = { model_id: { $eq: model.id } };
  const [scenarios, projections, forecasts, valuations, judgments, history] = await Promise.all([
    listRows('vi_scenario', byModel), listRows('vi_projection', byModel), listRows('vi_forecast', byModel),
    listRows('vi_valuation', byModel), listRows('vi_judgment', { company_id: { $eq: company.id } }),
    listRows('vi_fin_history', { company_id: { $eq: company.id } }),
  ]);
  scenarios.sort(bySort);
  const years = [...new Set(forecasts.map((f) => Number(f.year)))].sort((a, b) => a - b);
  const pOf = (sc, y) => projections.find((p) => p.scenario_name === sc.name && Number(p.year) === Number(y));
  const fOf = (y) => forecasts.find((f) => Number(f.year) === Number(y));
  return { company, model, scenarios, projections, forecasts, valuations, judgments, history, years, pOf, fOf };
}

// 假设依据：编号标签，悬停看判断、传导与修改门槛
function JTag({ code, judgments }) {
  const j = judgments.find((x) => x.code === code);
  if (!j) return <Tag>{code}</Tag>;
  const body = (
    <div style={{ maxWidth: 420 }}>
      <Paragraph style={{ marginBottom: 6 }}><b>判断</b>：{j.judgment}</Paragraph>
      {j.transmission && <Paragraph style={{ marginBottom: 6 }}><b>怎么传导</b>：{j.transmission}</Paragraph>}
      {j.change_threshold && <Paragraph style={{ marginBottom: 0 }}><b>什么情况下改</b>：{j.change_threshold}</Paragraph>}
    </div>
  );
  return (
    <Popover title={`${j.code} ${j.title} · ${j.status || ''}`} content={body}>
      <Tag color="blue" style={{ cursor: 'help' }}>{j.code}</Tag>
    </Popover>
  );
}
"""

ASSUME_JS = COMMON + r"""
// 历史年份的推导值（历史年度里没有现成字段的）
function histValue(key, h, model) {
  if (!h) return null;
  if (key === 'tax_rate') return isNum(h.income_tax) && isNum(h.pretax_profit) ? h.income_tax / h.pretax_profit : null;
  if (key === 'minority_share') return isNum(h.minority_profit) && isNum(h.pretax_profit) && isNum(h.income_tax)
    ? h.minority_profit / (h.pretax_profit - h.income_tax) : null;
  if (key === 'opening_debt') return h.year === model.base_year ? model.opening_debt : null;
  return h[key];
}

function factorText(v) {
  const x = Number(v ?? 1);
  if (Math.abs(x - 1) < 1e-9) return <Text type="secondary">同基准</Text>;
  return `×${x.toFixed(2)}（${x > 1 ? '+' : '−'}${(Math.abs(x - 1) * 100).toFixed(0)}%）`;
}

try {
  const D = await load();
  if (!D.model) {
    ctx.render(<Alert type="info" showIcon message="还没有状态为“当前”的估值模型" />);
  } else {
    const { company, model, scenarios, judgments, history, years, pOf, fOf } = D;
    const histYears = history.map((h) => h.year).filter((y) => y <= model.base_year).sort((a, b) => a - b).slice(-3);
    const hOf = (y) => history.find((h) => h.year === y);
    const base = scenarios.find((s) => s.is_base) || scenarios[0];
    const used = new Set(PROFILE.drivers.flatMap((r) => r.j || []).concat(['J-TV', PROFILE.hurdle_j]));   // J-TV 挂在情景表的永续增长列，门槛依据在估值页

    function Panel() {
      const { token } = theme.useToken();
      const [scId, setScId] = useState(base.id);
      const sc = scenarios.find((s) => s.id === scId) || base;
      const last = years[years.length - 1];

      const cell = (r, v) => (
        <span style={{ fontVariantNumeric: 'tabular-nums', fontWeight: r.strong ? 600 : 400 }}>{r.pct ? pct(v, r.d ?? 1) : fmt(v, r.d ?? 1)}</span>
      );
      const rows = PROFILE.drivers.map((r, i) => {
        if (r.section) return { key: i, section: r.section };
        const row = { key: i, ...r };
        histYears.forEach((y) => { row['h' + y] = r.h ? histValue(r.h, hOf(y), model) : null; });
        years.forEach((y) => { const p = pOf(sc, y), f = fOf(y); row['y' + y] = r.p ? p?.[r.p] : r.f ? f?.[r.f] : null; });
        return row;
      });
      const span = 1 + histYears.length + years.length + 1;
      const sectionCell = (r) => (r.section ? { colSpan: 0 } : {});
      const columns = [
        { title: '驱动 · 怎么来', key: 'label', fixed: narrow ? undefined : 'left', width: 230,
          onCell: (r) => (r.section ? { colSpan: span } : {}),
          render: (_, r) => r.section ? <Text strong style={{ color: token.colorTextSecondary }}>{r.section}</Text> : (
            <div>
              <div style={{ fontWeight: r.strong ? 600 : 400 }}>{r.label}</div>
              <div style={{ fontSize: 12, color: token.colorTextSecondary }}>{r.how}</div>
            </div>) },
        { title: '依据', key: 'j', width: 120, onCell: sectionCell,
          render: (_, r) => (r.j || []).map((c) => <JTag key={c} code={c} judgments={judgments} />) },
        ...histYears.map((y) => ({ title: `${y}A`, key: 'h' + y, align: 'right', width: 84, onCell: sectionCell,
          render: (_, r) => <span style={{ color: token.colorTextSecondary }}>{cell(r, r['h' + y])}</span> })),
        ...years.map((y) => ({ title: `${y}E`, key: 'y' + y, align: 'right', width: 84, onCell: sectionCell,
          render: (_, r) => cell(r, r['y' + y]) })),
      ];

      const scCols = [
        { title: '情景', dataIndex: 'name', render: (v, s) => <span>{v}{s.is_base && <Tag color="blue" style={{ marginLeft: 6 }}>基准</Tag>}</span> },
        { title: company.volume_label || '业务量', key: 'vf', render: (_, s) => factorText(s.volume_factor) },
        { title: company.price_label || '单价', key: 'pf', render: (_, s) => factorText(s.price_factor) },
        { title: '付现成本', key: 'cf', render: (_, s) => factorText(s.cost_factor) },
        { title: <span>永续增长 <JTag code="J-TV" judgments={judgments} /></span>, key: 'g', render: (_, s) => pct(s.terminal_growth) },
        { title: `${last}E 归母净利润`, key: 'np', align: 'right', render: (_, s) => fmt(pOf(s, last)?.np_parent, 0) },
        { title: `${last}E 每股股息`, key: 'dps', align: 'right', render: (_, s) => fmt(pOf(s, last)?.dps, 3) + ' 元' },
      ];

      return (
        <div>
          <Title level={4} style={{ marginTop: 0 }}>{company.name} · 财务模型</Title>
          <Paragraph type="secondary">{PROFILE.logic}</Paragraph>

          <Card size="small" title="三个情景差在哪（系数乘在基准的逐年路径上）" style={{ marginBottom: 12 }}>
            <Table size="small" pagination={false} rowKey="id" dataSource={scenarios} columns={scCols} scroll={{ x: 'max-content' }} />
            <Text type="secondary" style={{ fontSize: 12 }}>
              没列出的假设（折旧、利息、税率、派息率、资本开支）各情景相同。情景只改现金流，不改门槛，门槛在「估值」页。
            </Text>
          </Card>

          <Card size="small" style={{ marginBottom: 12 }}
            title={<Space wrap><span>逐年驱动：历史实际 → 预测</span>
              <Segmented size="small" value={sc.id} onChange={setScId} options={scenarios.map((s) => ({ label: s.name, value: s.id }))} /></Space>}>
            <Table size="small" pagination={false} rowKey="key" dataSource={rows} columns={columns} scroll={{ x: 'max-content' }} />
            <Text type="secondary" style={{ fontSize: 12 }}>灰字为历史实际（预测与估值 / 历史年度）；改数字到「模型底稿 / 逐年假设」「情景」，改依据到「模型底稿 / 假设依据」。</Text>
          </Card>

          <Card size="small" title={`全部假设依据（${judgments.length} 条）`}>
            <Collapse size="small" items={[...judgments].sort((a, b) => a.code.localeCompare(b.code)).map((j) => ({
              key: j.code,
              label: <span><b>{j.code}</b> {j.title} <Tag style={{ marginLeft: 6 }}>{j.status}</Tag>
                {!used.has(j.code) && <Text type="secondary" style={{ fontSize: 12 }}>（上表没有直接对应的行）</Text>}</span>,
              children: (
                <Descriptions size="small" column={1} bordered items={[
                  ['事实层', j.fact_layer], ['判断', j.judgment], ['怎么传导', j.transmission], ['影响参数', j.parameter],
                  ['影响年份', j.affected_years], ['什么情况下改', j.change_threshold], ['什么情况下不改', j.no_change_condition],
                  ['反证', j.counter_evidence],
                ].filter(([, v]) => v).map(([label, v]) => ({ key: label, label, children: v }))} />
              ),
            }))} />
          </Card>
        </div>
      );
    }
    ctx.render(<Panel />);
  }
} catch (error) {
  ctx.render(<Alert type="error" showIcon message="财务模型读取失败" description={String(error?.message || error)} />);
}
"""

IRR_JS = COMMON + r"""
// 与数据库 vi_pv / vi_irr 同一口径：现金流是从今天起算的每股股息，tau＝(年份−基准年)−距基准日年数，已过去的年份不计；
// 终值＝最后一年股息×(1+g)÷(r−g)，在最后一年折回。
function pv(flows, g, r) {
  if (!isNum(r) || !isNum(g) || r <= g || !flows.length) return null;
  const last = flows[flows.length - 1];
  return flows.reduce((s, x) => s + (x.tau > 0 ? x.dps / Math.pow(1 + r, x.tau) : 0), 0)
    + last.dps * (1 + g) / (r - g) / Math.pow(1 + r, last.tau);
}
function irr(flows, g, price) {
  if (!isNum(price) || price <= 0 || !flows.length || flows.some((x) => !isNum(x.dps))) return null;
  let lo = g + 1e-7, hi = 1;
  if (pv(flows, g, hi) > price) return null;
  for (let i = 0; i < 80; i++) { const mid = (lo + hi) / 2; if (pv(flows, g, mid) > price) lo = mid; else hi = mid; }
  return (lo + hi) / 2;
}

// 每股股息折线（各情景一条，起点是基准年实际）
function DpsChart({ series, startYear, startDps }) {
  const { token } = theme.useToken();
  const W = 640, H = 220, L = 44, R = 64, T = 12, B = 26;
  const all = series.flatMap((s) => s.points.map((p) => p.dps)).concat(isNum(startDps) ? [startDps] : []);
  const lo = Math.floor(Math.min(...all) * 10) / 10, hi = Math.ceil(Math.max(...all) * 10) / 10;
  const years = series[0].points.map((p) => p.year);
  const x0 = isNum(startDps) ? startYear : years[0], x1 = years[years.length - 1];
  const x = (y) => L + ((y - x0) / (x1 - x0 || 1)) * (W - L - R);
  const y = (v) => T + (1 - (v - lo) / (hi - lo || 1)) * (H - T - B);
  const ticks = [lo, (lo + hi) / 2, hi];
  return (
    <svg viewBox={`0 0 ${W} ${H}`} style={{ width: '100%', height: 'auto' }}>
      {ticks.map((t) => (
        <g key={t}>
          <line x1={L} x2={W - R} y1={y(t)} y2={y(t)} stroke={token.colorSplit} />
          <text x={L - 6} y={y(t) + 4} fontSize="11" textAnchor="end" fill={token.colorTextSecondary}>{t.toFixed(2)}</text>
        </g>
      ))}
      {[x0, ...years].filter((yy, i, a) => i === 0 || i === a.length - 1 || (yy - x0) % 2 === 0).map((yy) => (
        <text key={yy} x={x(yy)} y={H - 8} fontSize="11" textAnchor="middle" fill={token.colorTextSecondary}>{yy === x0 && isNum(startDps) ? `${yy}A` : `${yy}E`}</text>
      ))}
      {series.map((s) => {
        const pts = (isNum(startDps) ? [{ year: startYear, dps: startDps }] : []).concat(s.points);
        const end = s.points[s.points.length - 1];
        return (
          <g key={s.name}>
            <polyline fill="none" stroke={s.color} strokeWidth={s.strong ? 2.5 : 1.5} points={pts.map((p) => `${x(p.year)},${y(p.dps)}`).join(' ')} />
            <text x={x(end.year) + 6} y={y(end.dps) + 4} fontSize="11" fill={s.color}>{s.name} {end.dps.toFixed(2)}</text>
          </g>
        );
      })}
      {isNum(startDps) && <circle cx={x(startYear)} cy={y(startDps)} r="3" fill={token.colorText} />}
    </svg>
  );
}

try {
  const D = await load();
  if (!D.model) {
    ctx.render(<Alert type="info" showIcon message="还没有状态为“当前”的估值模型" />);
  } else {
    const { company, model, scenarios, valuations, judgments, history, years, pOf, fOf } = D;
    const shares = Number(model.shares);
    const tauOf = (yy) => (yy - model.base_year) - model.years_elapsed;
    const base = scenarios.find((s) => s.is_base) || scenarios[0];
    const vOf = (s) => valuations.find((v) => v.scenario_name === s.name) || {};
    const price = vOf(base).market_price, priceDate = vOf(base).market_date;
    const flowsOf = (s, dpsFn) => years.map((yy) => {
      const p = pOf(s, yy), f = fOf(yy);
      return { year: yy, tau: tauOf(yy), dps: p ? (dpsFn ? dpsFn(p, f) : p.dps) : null };
    });
    const flows = Object.fromEntries(scenarios.map((s) => [s.id, flowsOf(s)]));
    const irrOf = (s) => irr(flows[s.id], s.terminal_growth, price);
    const hist0 = history.find((h) => h.year === model.base_year);
    const COLORS = (token) => [token.colorError, token.colorPrimary, token.colorSuccess];
    const first = years[0], last = years[years.length - 1];

    // 一次只动一个假设的基准情景（与模型同一套线性关系：利润总额变化 ×(1−税率)×(1−少数股东占比)×派息率 ＝ 股息变化）
    const keep = (f) => (1 - f.tax_rate) * (1 - f.minority_share);
    const shockFlows = (k) => flowsOf(base, (p, f) => {
      const dPretax = (k.rev ? k.rev * p.revenue : 0) - (k.cost ? k.cost * p.cash_cost : 0)
        - (k.kd ? k.kd * (Number(f.debt_open) + Number(f.debt_close)) / 2 : 0);
      return (p.np_parent + dPretax * keep(f)) * (isNum(k.payout) ? k.payout : p.payout) / shares;
    });

    function Panel() {
      const { token } = theme.useToken();
      const colors = COLORS(token);
      const saved = Math.round((model.required_return ?? 0.06) * 1000) / 10;
      const [reqPct, setReqPct] = useState(saved);
      const [saving, setSaving] = useState(false);
      const req = reqPct / 100;
      const ok = (r) => isNum(r) && r >= req;
      const irrColor = (r) => (ok(r) ? token.colorSuccess : token.colorText);
      const baseIrr = irrOf(base);
      const passing = scenarios.filter((s) => ok(irrOf(s)));
      const rf = isNum(model.latest_rf) ? model.latest_rf / 100 : model.rf;

      const save = async () => {
        setSaving(true);
        try {
          await ctx.request({ url: 'vi_model:update', method: 'post', params: { filterByTk: model.id }, data: { required_return: req } });
          message.success(`已保存：门槛 ${reqPct}%`);
        } catch (e) {
          message.error('保存失败：' + String(e?.message || e));
        } finally {
          setSaving(false);
        }
      };

      const verdict = !isNum(baseIrr) ? '算不出隐含回报：预测年份不完整或没有市场价。'
        : `按 ${fmt(price, 2)} 元（${priceDate || ''}）买入，基准情景年化 ${pct(baseIrr, 2)}，`
          + `比门槛 ${pct(req, 1)} ${ok(baseIrr) ? '高' : '低'} ${pp(baseIrr - req)}`
          + `；${passing.length === scenarios.length ? '三个情景都达到门槛' : passing.length ? `达到门槛的只有${passing.map((s) => s.name).join('、')}情景` : '三个情景都低于门槛'}。`;

      // 回报从哪来：首年股息率 ＋ 股息增长 ＋ 永续
      const b0 = pOf(base, first), b1 = pOf(base, last);
      const yield0 = b0 && price ? b0.dps / price : null;
      const growth = b0 && b1 ? Math.pow(b1.dps / b0.dps, 1 / (last - first)) - 1 : null;
      const bf = flows[base.id];
      const terminalShare = isNum(baseIrr) && price
        ? (bf[bf.length - 1].dps * (1 + base.terminal_growth) / (baseIrr - base.terminal_growth) / Math.pow(1 + baseIrr, bf[bf.length - 1].tau)) / price : null;

      // 归母净利润为什么涨：首年 → 末年，各项对利润总额的变化 × 末年保留比例
      const f1 = fOf(last);
      const k1 = f1 ? keep(f1) : 1;
      const parts = b0 && b1 ? [
        { n: '营业收入', v: (b1.revenue - b0.revenue) * k1 },
        { n: '付现成本', v: -(b1.cash_cost - b0.cash_cost) * k1 },
        { n: '折旧退坡', v: -(b1.depreciation - b0.depreciation) * k1 },
        { n: '利息下降', v: -(b1.interest - b0.interest) * k1 },
        { n: '其他净贡献', v: (b1.other_contrib - b0.other_contrib) * k1 },
      ] : [];
      if (parts.length) parts.push({ n: '税率与少数股东', v: (b1.np_parent - b0.np_parent) - parts.reduce((s, p) => s + p.v, 0) });
      const maxPart = Math.max(1, ...parts.map((p) => Math.abs(p.v)));

      // 买入价 → 回报
      const step = price > 50 ? 5 : 2;
      const pts = [];
      if (isNum(price)) for (let q = Math.floor(price * 0.7 / step) * step; q <= price * 1.25; q += step) pts.push(q);
      if (isNum(price) && !pts.includes(price)) pts.push(price);
      pts.sort((a, b) => a - b);
      const priceCols = [
        { title: '情景', dataIndex: 'name', fixed: narrow ? undefined : 'left' },
        ...pts.map((q) => ({
          title: q === price ? <b>{fmt(q, 2)}（现价）</b> : fmt(q, 0), key: 'q' + q, align: 'right',
          render: (_, s) => { const r = irr(flows[s.id], s.terminal_growth, q);
            return <span style={{ color: irrColor(r), fontWeight: q === price ? 600 : 400 }}>{pct(r, 1)}</span>; } })),
        { title: `门槛 ${pct(req, 1)} 下最高买入价`, key: 'cap', align: 'right',
          render: (_, s) => <b>{fmt(pv(flows[s.id], s.terminal_growth, req), 2)} 元</b> },
      ];

      // 什么会改变结论
      const shockRows = PROFILE.shocks.map((k, i) => {
        const fl = (k.rev || k.cost || k.kd || isNum(k.payout)) ? shockFlows(k) : flows[base.id];
        const g = isNum(k.g) ? k.g : base.terminal_growth;
        const q = k.price ? price * (1 + k.price) : price;
        const r = irr(fl, g, q);
        return { key: i, label: k.label, j: k.j, r, d: isNum(r) && isNum(baseIrr) ? r - baseIrr : null, cap: k.price ? null : pv(fl, g, req) };
      });

      const gaps = years.map((yy) => ({ yy, gap: pOf(base, yy)?.funding_gap })).filter((x) => isNum(x.gap) && x.gap > 0.05);
      const cashIrr = vOf(base).cash_implied_irr;

      return (
        <div>
          <Title level={4} style={{ marginTop: 0 }}>{company.name} · 估值：按今天的价格买入，年化回报多少？</Title>
          <Paragraph type="secondary">
            只用一个估值逻辑：把未来每年的每股股息当成债券票息（{first}—{last} 年逐年预测，之后按永续增长延续），
            求出按市场价买入的隐含年化回报，再和门槛比。情景只改现金流，门槛只有一个。
          </Paragraph>

          <Row gutter={[12, 12]} style={{ marginBottom: 12 }}>
            {scenarios.map((s, i) => (
              <Col key={s.id} xs={12} md={5}>
                <Card size="small" style={s.is_base ? { borderColor: token.colorPrimary } : {}}>
                  <Statistic title={`${s.name}情景 · 隐含年化回报`} value={pct(irrOf(s), 2)} valueStyle={{ color: irrColor(irrOf(s)), fontWeight: s.is_base ? 600 : 400 }} />
                </Card>
              </Col>
            ))}
            <Col xs={12} md={5}>
              <Card size="small">
                <div style={{ color: token.colorTextSecondary, marginBottom: 4 }}>门槛（要求的年化回报）{PROFILE.hurdle_j && <JTag code={PROFILE.hurdle_j} judgments={judgments} />}</div>
                <Space.Compact>
                  <InputNumber min={2} max={15} step={0.5} value={reqPct} onChange={(v) => isNum(v) && setReqPct(v)} addonAfter="%" style={{ width: 110 }} />
                  <Button disabled={reqPct === saved} loading={saving} onClick={save}>保存</Button>
                </Space.Compact>
              </Card>
            </Col>
            <Col xs={12} md={4}>
              <Card size="small"><Statistic title={`10 年国债（${model.latest_rf_date || model.rf_date || ''}）`} value={pct(rf, 2)} /></Card>
            </Col>
          </Row>
          <Alert showIcon type={ok(baseIrr) ? 'success' : 'warning'} style={{ marginBottom: 12 }} message={verdict}
            description={isNum(baseIrr) && isNum(rf) ? `基准回报比 10 年国债${baseIrr >= rf ? '高' : '低'} ${pp(baseIrr - rf)}。研究提示，不是交易指令。` : null} />

          <Row gutter={[12, 12]} style={{ marginBottom: 12 }}>
            <Col xs={24} lg={12}>
              <Card size="small" title="回报从哪来（基准情景）" style={{ height: '100%' }}>
                <Row gutter={12}>
                  <Col span={8}><Statistic title={`首年股息率（${first}E）`} value={pct(yield0, 2)} /></Col>
                  <Col span={8}><Statistic title={`股息年增（${first}—${last}E）`} value={pct(growth, 2)} /></Col>
                  <Col span={8}><Statistic title={`${last} 年后永续增长`} value={pct(base.terminal_growth, 1)} /></Col>
                </Row>
                <Paragraph type="secondary" style={{ marginTop: 8, marginBottom: 8 }}>
                  隐含回报 ≈ 股息率 ＋ 股息增长。{last} 年以后的股息（终值）占买入价的 {pct(terminalShare, 0)}，所以永续增长和最后几年的股息水平很关键。
                </Paragraph>
                <div style={{ fontWeight: 500, marginBottom: 4 }}>股息为什么能涨：归母净利润 {fmt(b0?.np_parent, 0)} → {fmt(b1?.np_parent, 0)} 亿元（{first}E → {last}E）</div>
                {parts.map((p) => (
                  <div key={p.n} style={{ display: 'grid', gridTemplateColumns: '96px 1fr 64px', gap: 8, alignItems: 'center', padding: '2px 0' }}>
                    <span style={{ fontSize: 13 }}>{p.n}</span>
                    <div style={{ position: 'relative', height: 12, background: token.colorFillQuaternary, borderRadius: 2 }}>
                      <div style={{ position: 'absolute', top: 0, bottom: 0, borderRadius: 2,
                        left: p.v >= 0 ? '50%' : `${50 - Math.abs(p.v) / maxPart * 50}%`, width: `${Math.abs(p.v) / maxPart * 50}%`,
                        background: p.v >= 0 ? token.colorSuccess : token.colorError }} />
                    </div>
                    <span style={{ textAlign: 'right', fontVariantNumeric: 'tabular-nums', fontSize: 13 }}>{p.v >= 0 ? '+' : '−'}{fmt(Math.abs(p.v), 1)}</span>
                  </div>
                ))}
                <Text type="secondary" style={{ fontSize: 12 }}>各项是对利润总额的变化 × {last} 年的（1 − 税率）×（1 − 少数股东占比），单位亿元。</Text>
              </Card>
            </Col>
            <Col xs={24} lg={12}>
              <Card size="small" title="每股股息路径（元）" style={{ height: '100%' }}>
                <DpsChart startYear={model.base_year} startDps={hist0?.dps}
                  series={scenarios.map((s, i) => ({ name: s.name, color: colors[i % colors.length], strong: s.is_base,
                    points: flows[s.id].filter((p) => isNum(p.dps)) }))} />
                <Text type="secondary" style={{ fontSize: 12 }}>黑点是 {model.base_year} 年实际每股股息；各情景的假设见「财务模型」。</Text>
              </Card>
            </Col>
          </Row>

          <Card size="small" title="买入价 → 年化回报（绿色＝达到门槛）" style={{ marginBottom: 12 }}>
            <Table size="small" pagination={false} rowKey="id" dataSource={scenarios} columns={priceCols} scroll={{ x: 'max-content' }} />
          </Card>

          <Card size="small" title="什么会改变结论（基准情景，一次只动一个假设）" style={{ marginBottom: 12 }}>
            <Table size="small" pagination={false} rowKey="key" dataSource={shockRows} scroll={{ x: 'max-content' }} columns={[
              { title: '变化', dataIndex: 'label' },
              { title: '依据', dataIndex: 'j', render: (v) => (v ? v.split(' / ').map((c) => <JTag key={c} code={c} judgments={judgments} />) : null) },
              { title: '隐含年化回报', dataIndex: 'r', align: 'right', render: (v) => <span style={{ color: irrColor(v) }}>{pct(v, 2)}</span> },
              { title: '比基准', dataIndex: 'd', align: 'right', render: (v) => <span style={{ color: v >= 0 ? token.colorSuccess : token.colorError }}>{bp(v)}</span> },
              { title: `门槛下最高买入价`, dataIndex: 'cap', align: 'right', render: (v) => (isNum(v) ? fmt(v, 2) + ' 元' : '—') },
            ]} />
          </Card>

          <Card size="small" title="检查：计划股息付得出来吗">
            {gaps.length ? (
              <Paragraph style={{ marginBottom: 6 }}>
                基准情景 {gaps[0].yy}—{gaps[gaps.length - 1].yy} 年股东自由现金流不够付计划股息，缺口合计 {fmt(gaps.reduce((s, x) => s + x.gap, 0), 0)} 亿元
                （{gaps.map((x) => `${x.yy} 年 ${fmt(x.gap, 0)}`).join('、')}），这几年是在一边还债一边多付股息。
                只按付得出的股息算，隐含回报是 {pct(cashIrr, 2)}（相差 {bp(isNum(cashIrr) && isNum(baseIrr) ? cashIrr - baseIrr : null)}）。
              </Paragraph>
            ) : (
              <Paragraph style={{ marginBottom: 6 }}>基准情景各年股东自由现金流都覆盖计划股息。</Paragraph>
            )}
            <Text type="secondary" style={{ fontSize: 12 }}>现金假设见「财务模型」最后一段。</Text>
          </Card>
        </div>
      );
    }
    ctx.render(<Panel />);
  }
} catch (error) {
  ctx.render(<Alert type="error" showIcon message="估值读取失败" description={String(error?.message || error)} />);
}
"""

PAGES = [('assume', '财务模型', 'ExperimentOutlined', lambda prof: ASSUME_JS),   # 页面键仍是 assume（原名「情景假设」）
         ('val', '估值', 'FundOutlined', lambda prof: IRR_JS if prof['method'] == 'irr' else __import__('build_overview').kpi_code('__COMPANY__'))]


def body(co, key, title, js):
    return {'page': {'title': title, 'documentTitle': f"{co['name']} · {title}"},
            'assets': {'scripts': {key: {'version': 'v2', 'code': js}}},
            'tabs': [{'title': title, 'blocks': [{'type': 'jsBlock', 'script': key}]}]}


def create(co, key, title, icon, js):
    st = state()
    gid = ensure_group(st, f"{co['name']}/预测与估值", '预测与估值', 'CalculatorOutlined', parent=company_root(st, co))
    apply_page(f"{key}_{co['code']}", {'version': '1', 'mode': 'create',
                                       'navigation': {'group': {'routeId': gid}, 'item': {'title': title, 'icon': icon}},
                                       **body(co, key, title, js)})
    record(f"{key}@{co['code']}", gid, title)


def replace(co, key, title, js):
    """原地改写已建的页面（脚本、标题），菜单里的名字一起改；页面地址不变。"""
    page = state()['pages'][f"{key}@{co['code']}"]
    apply_page(f"{key}_{co['code']}", {'version': '1', 'mode': 'replace', 'target': {'pageSchemaUid': page['pageSchemaUid']},
                                       **body(co, key, title, js)})
    nb_json('resource', 'update', '--resource', 'desktopRoutes', '--filter-by-tk', str(page['routeId']),
            '--values', json.dumps({'title': title}, ensure_ascii=False))
    print(co['name'], title, '已原地改写')


def move_drafts(co):
    """把这家公司已建的“预测与估值”表格页和财务模型挪进“模型底稿”子组；skip 里的页面删掉（页面可由 build_pages 重建，表和数据不动）。"""
    st = state()
    drafts = valuation_group(st, co)
    skip = CUSTOM_VALUATION[co['code']].get('skip', ())
    codes = ['finmodel'] + [c for g, _, pages in COMPANY_MENU if g == '预测与估值' for c, _ in pages if c != 'fin_history']   # 历史年度留在顶层
    for code in codes:
        key = page_key(code, co)
        if key not in state()['pages']:
            continue
        if code == 'finmodel' and state()['pages'].get(page_key('assume', co), {}).get('pageSchemaUid') == state()['pages'][key]['pageSchemaUid']:
            cur = state(); del cur['pages'][key]
            __import__('build_pages').STATE.write_text(json.dumps(cur, ensure_ascii=False, indent=1))
            continue
        if code in skip:
            destroy_page(key)
            print(code, '删除页面（这家公司不用）')
            continue
        nb_json('resource', 'update', '--resource', 'desktopRoutes', '--filter-by-tk', str(state()['pages'][key]['routeId']),
                '--values', json.dumps({'parentId': drafts}))
    print(co['name'], '表格页已在', DRAFTS)


if __name__ == '__main__':
    for co in companies():
        prof = PROFILES.get(co['code'])
        if not prof:
            continue
        js_profile = json.dumps(prof, ensure_ascii=False)
        for key, title, icon, js in PAGES:
            k = f"{key}@{co['code']}"
            code = js(prof).replace('__COMPANY__', co['code']).replace('__PROFILE__', js_profile)
            if '--replace' in sys.argv and k in state()['pages']:
                replace(co, key, title, code); continue
            if '--rebuild' in sys.argv:
                destroy_page(k)
            if k not in state()['pages']:
                create(co, key, title, icon, code)
        if '--replace' not in sys.argv:
            move_drafts(co)
    if '--replace' not in sys.argv:
        sort_menu()
