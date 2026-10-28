"""腾讯音乐驾驶舱：只展示有明确口径的 12 张核心图，保持现有页面地址。"""
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent


def kpi_code():
    return (HERE / 'tencent_dashboard_kpi.jsx').read_text()


def layout(keys):
    return [[{'key': 'kpi', 'span': 24}]] + [
        [{'key': key, 'span': 12} for key in keys[i:i + 2]]
        for i in range(0, len(keys), 2)
    ] + [[{'key': 'collect', 'span': 24}]]


def collect_code(code):
    """沿用现有采集逻辑和权限处理，只把工具折叠。"""
    code = code.replace('Button, Steps, Table,', 'Button, Collapse, Steps, Table,', 1)
    start = '  return (\n    <div>\n      {flows && !ready && ('
    end = '    </div>\n  );\n}\n\nctx.render(<Panel />);'
    assert start in code and end in code
    return code.replace(start,
        "  return (\n    <Collapse items={[{ key: 'collect', label: '数据更新与采集', children: <div>\n      {flows && !ready && (", 1
    ).replace(end, '    </div> }]} />\n  );\n}\n\nctx.render(<Panel />);', 1)


SERIES = r"""const rows = ctx.data?.objects || [];
const spec = __SPEC__;
const categories = [...new Set(rows.map((row) => String(row[spec.x])))];
const names = spec.names || [...new Set(rows.map((row) => spec.group ? String(row[spec.group]) : spec.label))];
const colors = spec.colors || ['#5470c6', '#2b9d8f', '#d99044', '#66758a'];
const numeric = (value) => value === null || value === undefined ? null : Number(value);
const series = names.map((name, index) => ({
  name,
  type: spec.kind,
  stack: spec.stack ? 'total' : undefined,
  barMaxWidth: 32,
  connectNulls: false,
  showSymbol: categories.length < 30,
  symbolSize: 5,
  lineStyle: { width: 2 },
  itemStyle: { color: colors[index % colors.length] },
  data: categories.map((category) => {
    const row = rows.find((item) => String(item[spec.x]) === category && (!spec.group || String(item[spec.group]) === name));
    return row ? numeric(row[spec.y]) : null;
  }),
}));
return {
  animation: false,
  grid: { left: 12, right: 22, top: 44, bottom: spec.note ? 42 : 16, containLabel: true },
  legend: { top: 0, type: 'scroll', textStyle: { fontSize: 12 } },
  tooltip: { trigger: 'axis', valueFormatter: (v) => v === null ? '—' : `${Number(v).toFixed(spec.digits ?? 1)} ${spec.unit}` },
  xAxis: {
    type: 'category',
    data: categories,
    boundaryGap: spec.kind === 'bar',
    axisLabel: { hideOverlap: true, formatter: (v) => /^\d{4}Q/.test(v) ? v.slice(2) : v },
    axisTick: { alignWithLabel: true },
  },
  yAxis: { type: 'value', min: spec.min, max: spec.max, name: spec.unit, splitLine: { lineStyle: { color: '#edf0f4' } } },
  graphic: spec.note ? [{ type: 'text', left: 'center', bottom: 0, style: { text: spec.note, fill: '#8c8c8c', fontSize: 11 } }] : [],
  series,
};
"""

BRIDGE = r"""const rows = ctx.data?.objects || [];
let accumulated = 0;
const bases = [];
const bars = [];
for (const row of rows) {
  const value = row.v === null || row.v === undefined ? null : Number(row.v);
  const total = row.part === '合计';
  if (value === null) {
    bases.push(null);
    bars.push(null);
    continue;
  }
  bases.push(total ? 0 : Math.min(accumulated, accumulated + value));
  bars.push({ value: total ? value : Math.abs(value),
    itemStyle: { color: total ? '#5470c6' : value < 0 ? '#c65555' : '#2b9d8f' } });
  if (!total) accumulated += value;
}
return {
  animation: false,
  grid: { left: 12, right: 18, top: 30, bottom: 12, containLabel: true },
  tooltip: { trigger: 'axis', formatter: (items) => {
    const row = rows[items[0].dataIndex];
    return `${row.part}<br/>${Number(row.v).toFixed(2)} 元/股`;
  } },
  xAxis: { type: 'category', data: rows.map((row) => row.part), axisLabel: { interval: 0, fontSize: 11 } },
  yAxis: { type: 'value', name: '元/股', splitLine: { lineStyle: { color: '#edf0f4' } } },
  series: [
    { type: 'bar', stack: 'bridge', silent: true, itemStyle: { color: 'transparent' }, emphasis: { disabled: true }, data: bases },
    { type: 'bar', stack: 'bridge', barMaxWidth: 44, data: bars,
      label: { show: true, position: 'top', formatter: (p) => Number(rows[p.dataIndex].v).toFixed(2), fontSize: 11 } },
  ],
};
"""

FIT = r"""const rows = ctx.data?.objects || [];
return {
  animation: false,
  grid: { left: 12, right: 30, top: 16, bottom: 12, containLabel: true },
  tooltip: { trigger: 'axis', axisPointer: { type: 'shadow' } },
  xAxis: { type: 'value', min: 0, max: 5, interval: 1, splitLine: { lineStyle: { color: '#edf0f4' } } },
  yAxis: { type: 'category', inverse: true, data: rows.map((row) => row['维度']), axisTick: { show: false } },
  series: [{ name: '评分', type: 'bar', barMaxWidth: 22, itemStyle: { color: '#5470c6' },
    label: { show: true, position: 'right' }, data: rows.map((row) => Number(row['评分'])) }],
};
"""

PAYOUT = r"""const rows = ctx.data?.objects || [];
return {
  animation: false,
  grid: { left: 12, right: 20, top: 30, bottom: 40, containLabel: true },
  tooltip: { trigger: 'axis', valueFormatter: (v) => `${Number(v).toFixed(1)}%` },
  xAxis: { type: 'category', data: rows.map((row) => row.year) },
  yAxis: { type: 'value', name: '%', splitLine: { lineStyle: { color: '#edf0f4' } } },
  graphic: [{ type: 'text', left: 'center', bottom: 0, style: {
    text: '（当年实付股息＋现金回购）÷ 同年归母利润；非持股收益率', fill: '#8c8c8c', fontSize: 11,
  } }],
  series: [{ name: '现金回报占归母利润', type: 'bar', barMaxWidth: 42,
    itemStyle: { color: '#5470c6' },
    label: { show: true, position: 'top', formatter: (p) => `${Number(p.value).toFixed(1)}%` },
    data: rows.map((row) => row['%'] === null ? null : Number(row['%'])) }],
};
"""


def visual(spec):
    return {'mode': 'custom', 'raw': SERIES.replace('__SPEC__', json.dumps(spec, ensure_ascii=False))}


def charts(existing):
    configs = {key: config for key, _, config in existing}
    out = []

    def add(key, title, spec=None, sql=None, raw=None):
        config = dict(configs[key])
        if sql:
            config['query'] = {'mode': 'sql', 'sql': sql}
        config['visual'] = {'mode': 'custom', 'raw': raw} if raw else visual(spec)
        out.append((key, title, config))

    current = ("FROM vi_sotp s JOIN vi_company_base co ON co.id=s.company_id AND co.code='01698.HK' "
               "JOIN vi_model_base m ON m.id=s.model_id AND m.status='当前' ")
    bridge = (
        "SELECT CASE g.code WHEN 'S1' THEN '会员订阅' WHEN 'S2' THEN '非订阅音乐' WHEN 'S3' THEN '社交娱乐' ELSE g.name END AS part, "
        "g.value/s.shares AS v, 10+coalesce(nullif(regexp_replace(g.code,'\\D','','g'),'')::int,0) AS ord "
        + current + "JOIN vi_sotp_segment_val g ON g.scenario_id=s.id AND g.model_id=s.model_id WHERE s.is_base "
        "UNION ALL SELECT x.part,x.v/s.shares,x.ord " + current +
        "CROSS JOIN LATERAL (VALUES ('自由现金',s.usable_net_cash,30),('投资七折',s.investments,31),"
        "('其他调整',s.minority_other,32),('合计',s.equity_value,40)) x(part,v,ord) WHERE s.is_base ORDER BY ord"
    )
    add('sotp_bridge', '基准每股价值桥接（人民币元）', sql=bridge, raw=BRIDGE)
    add('sotp_grid', '成熟业务统一倍数试算（人民币元/股）',
        {'x': '倍数', 'y': '每股价值', 'group': '系列', 'kind': 'line', 'unit': '元/股',
         'names': ['悲观', '基准', '乐观', '市场价'], 'colors': ['#d99044', '#5470c6', '#2b9d8f', '#66758a'],
         'note': '横轴为统一试算倍数；三条曲线保留各情景的盈利假设'},
        sql=configs['sotp_grid']['query']['sql'].replace("AND co.code = '01698.HK' ",
            "AND co.code = '01698.HK' JOIN vi_model_base m ON m.id=s.model_id AND m.status='当前' "))
    rev_sql = ("SELECT d.period, CASE d.line_item WHEN '会员（订阅）收入' THEN '会员订阅' "
               "WHEN '非订阅音乐收入（广告、演出、周边）' THEN '非订阅音乐' ELSE '社交娱乐' END AS 项目,d.value AS 亿元 "
               "FROM vi_disclosed d JOIN vi_company_base co ON co.id=d.company_id AND co.code='01698.HK' "
               "WHERE d.period_kind='单季' AND d.line_item IN ('会员（订阅）收入','非订阅音乐收入（广告、演出、周边）','社交娱乐及其他收入') "
               "ORDER BY d.period_end,2")
    add('rev_mix', '单季收入结构（亿元）',
        {'x': 'period', 'y': '亿元', 'group': '项目', 'kind': 'bar', 'unit': '亿元', 'stack': True,
         'names': ['会员订阅', '非订阅音乐', '社交娱乐']}, sql=rev_sql)
    add('sub_yoy', '单季收入同比（%）',
        {'x': 'period', 'y': '同比（%）', 'group': '项目', 'kind': 'line', 'unit': '%',
         'names': ['会员订阅', '社交娱乐', '营业收入'], 'colors': ['#5470c6', '#d99044', '#66758a']},
        sql=configs['sub_yoy']['query']['sql'].replace('d.line_item AS "项目"',
            "CASE d.line_item WHEN '会员（订阅）收入' THEN '会员订阅' WHEN '社交娱乐及其他收入' THEN '社交娱乐' ELSE d.line_item END AS \"项目\""))
    add('gm_q', '单季毛利率（%）',
        {'x': 'period', 'y': '毛利率（%）', 'label': '毛利率', 'kind': 'line', 'unit': '%', 'min': 0, 'max': 50})
    add('users', '在线音乐用户（百万人，季末披露）',
        {'x': 'period', 'y': '百万人', 'group': '项目', 'kind': 'line', 'unit': '百万人',
         'names': ['在线音乐付费用户', '在线音乐月活跃用户'], 'note': '2026 年起停止季度披露；此处仅比较同口径季末数据'},
        sql=configs['users']['query']['sql'].replace("WHERE d.line_item IN", "WHERE d.period_kind='单季' AND d.line_item IN"))
    add('hist_np', '归母利润、实付股息与现金回购（亿元）',
        {'x': 'year', 'y': 'amount', 'group': 'item', 'kind': 'line', 'unit': '亿元',
         'names': ['归母净利润', '实付现金股息', '现金回购'], 'note': '按实际支付年份；股息不含向非控股股东派息'},
        sql="SELECT h.year::text AS year,x.item,x.amount FROM vi_fin_history h "
            "JOIN vi_company_base co ON co.id=h.company_id AND co.code='01698.HK' "
            "LEFT JOIN LATERAL (SELECT max(d.value) FILTER (WHERE d.line_item='实付本公司股东现金股息') AS div, "
            "max(d.value) FILTER (WHERE d.line_item='现金回购支出') AS buyback FROM vi_disclosed d "
            "WHERE d.company_id=h.company_id AND d.period=h.year::text AND d.period_kind='全年') r ON true "
            "CROSS JOIN LATERAL (VALUES ('归母净利润',h.np_parent),('实付现金股息',r.div),('现金回购',r.buyback)) x(item,amount) "
            "WHERE h.year>=2020 AND x.amount IS NOT NULL ORDER BY h.year,x.item")
    add('hist_cash', '经营现金流与资本开支（亿元）',
        {'x': 'year', 'y': 'amount', 'group': 'item', 'kind': 'bar', 'unit': '亿元', 'names': ['经营现金流', '资本开支']})
    add('cash', '现金储备与带息负债（亿元，期末）',
        {'x': 'year', 'y': '亿元', 'group': '项目', 'kind': 'bar', 'unit': '亿元', 'names': ['现金储备', '带息负债']},
        sql=configs['cash']['query']['sql'].replace('现金与定期存款', '现金储备'))
    add('payout', '股东现金回报占归母利润（%）', raw=PAYOUT,
        sql="SELECT h.year::text AS year,round((h.payout*100)::numeric,1) AS \"%\" FROM vi_fin_history h "
            "JOIN vi_company_base co ON co.id=h.company_id AND co.code='01698.HK' "
            "WHERE h.year>=2020 AND h.payout IS NOT NULL ORDER BY h.year")
    add('price', '港股收盘价（港元/普通股，不复权）',
        {'x': 'obs_date', 'y': '股价', 'label': '港股收盘价', 'kind': 'line', 'unit': '港元', 'digits': 2},
        sql="SELECT o.obs_date,o.value AS 股价 FROM vi_obs_current o JOIN vi_company_base co ON co.price_metric_id=o.metric_id AND co.code='01698.HK' ORDER BY o.obs_date")
    add('fit', '价值投资适配度（各项 0—5 分）', raw=FIT)
    return out
