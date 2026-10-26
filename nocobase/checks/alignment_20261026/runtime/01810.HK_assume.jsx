export default async function run(ctx) {
const COMPANY = '01810.HK';
const PROFILE = {"method": "sotp", "hurdle_j": null, "logic": "月活 × 每月活年收入只是集团汇总模型，不代表每个用户实际付费。主估值分别处理手机、AIoT、互联网、汽车和 AI；集团现金流用于交叉检查。", "drivers": [{"section": "收入与业务规模"}, {"label": "全球月活用户（亿人）", "p": "volume", "h": "volume", "j": ["J-MAU"], "d": 2, "how": "逐年路径 × 情景业务量系数"}, {"label": "集团收入 / 月活用户（元/年）", "p": "price", "h": "price", "j": ["J-MAU"], "d": 1, "how": "逐年路径 × 情景单价系数"}, {"label": "营业收入", "p": "revenue", "h": "revenue", "strong": true, "how": "业务量 × 单价"}, {"section": "成本与利润（金额：亿元人民币）"}, {"label": "付现成本", "p": "cash_cost", "j": ["J-OPEX"], "how": "基准付现成本 × 情景成本系数"}, {"label": "折旧摊销", "p": "depreciation", "h": "da"}, {"label": "利息", "p": "interest", "h": "finance_cost", "j": ["J-OTHER"]}, {"label": "其他净贡献", "p": "other_contrib", "j": ["J-OTHER"], "how": "投资收益、减值等净额，按各公司原模型口径"}, {"label": "利润总额", "p": "pretax", "h": "pretax_profit", "strong": true}, {"label": "所得税率", "f": "tax_rate", "h": "tax_rate", "pct": true, "d": 2, "j": []}, {"label": "少数股东占比", "f": "minority_share", "h": "minority_share", "pct": true, "d": 2, "j": []}, {"label": "归母净利润", "p": "np_parent", "h": "np_parent", "strong": true}, {"section": "股东回报与现金约束"}, {"label": "股东回报率（股息＋回购）", "p": "payout", "h": "payout", "j": ["J-PAYOUT"], "pct": true, "how": "按原模型口径；回购金额不等于现金股息"}, {"label": "每股股东回报（元人民币）", "p": "dps", "h": "dps", "strong": true, "d": 3}, {"label": "维持资本开支", "f": "maint_capex", "j": [], "d": 1}, {"label": "扩张资本开支", "f": "growth_capex", "j": [], "d": 1}, {"label": "营运资本增加", "f": "wc_increase", "j": [], "d": 1}, {"label": "净借款（负数＝偿债）", "f": "net_borrowing", "d": 1}, {"label": "股东自由现金流", "p": "fcfe", "strong": true, "how": "按数据库归母现金桥接口径"}, {"label": "计划回报现金缺口", "p": "funding_gap", "how": "现金不足部分；缺项保持未知"}], "shocks": [{"label": "收入中枢 −5%", "rev": -0.05, "j": "J-MAU / J-MAU"}, {"label": "收入中枢 +5%", "rev": 0.05, "j": "J-MAU / J-MAU"}, {"label": "付现成本 +5%", "cost": 0.05, "j": "J-OPEX"}, {"label": "债务成本 +1 个百分点", "kd": 0.01}, {"label": "永续增长 0%", "g": 0.0, "j": "J-TV"}, {"label": "买入价 −10%", "price": -0.1}]};
const { React } = ctx.libs;
const { useState } = React;
const { Card, Segmented, Table: NativeTable, Alert, Typography, Space, Tag, Popover, Collapse, Descriptions, Row, Col, Statistic,
        InputNumber, Button, message, theme } = ctx.libs.antd;
const { Text, Paragraph, Title } = Typography;


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
              逐年路径与情景系数共同生成预测；分部估值另用各分部参数。所有金额为亿元人民币，每股金额及业务单位以行标题为准。
            </Text>
          </Card>

          <Card size="small" style={{ marginBottom: 12 }}
            title={<Space wrap><span>逐年驱动：历史实际 → 预测</span>
              <Segmented size="small" value={sc.id} onChange={setScId} options={scenarios.map((s) => ({ label: s.name, value: s.id }))} /></Space>}>
            <Table size="small" pagination={false} rowKey="key" dataSource={rows} columns={columns} scroll={{ x: 'max-content' }} />
            <Text type="secondary" style={{ fontSize: 12 }}>灰字为历史实际（预测与估值 / 历史年度）；改逐年数字请切换本页「逐年假设（编辑）」；情景和假设依据在「模型底稿」。</Text>
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

}
