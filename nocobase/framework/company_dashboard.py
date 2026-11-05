"""四家公司驾驶舱：沿用腾讯音乐的信息层级，按生意保留核心图。"""
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
PROFILES = {
    '600900.SH': {
        'focus': '经营重点：来水、发电量、电价与股东现金回报',
        'keys': ['irr_scen', 'irr_curve', 'hist_vol', 'level', 'peer_roe', 'hist_np', 'hist_cash',
                 'hist_quality', 'debt', 'path', 'req_curve', 'price', 'fit'],
    },
    '002078.SZ': {
        'focus': '经营重点：浆纸销量、毛利率、扩产开支与负债',
        'keys': ['irr_scen', 'irr_curve', 'hist_vol', 'peer_gm', 'pulp', 'gm_q', 'hist_np', 'hist_cash',
                 'debt', 'hist_quality', 'path', 'price', 'fit'],
    },
    '601668.SH': {
        'focus': '经营重点：新签转收入、应收与合同资产、减值及现金回收',
        'keys': ['irr_scen', 'irr_curve', 'hist_vol', 'conv', 'wc', 'imp', 'peer_roe', 'peer_ar',
                 'hist_np', 'hist_cash', 'hist_quality', 'debt', 'price', 'fit'],
    },
    '01810.HK': {
        'sotp': True,
        'focus': '经营重点：手机与生态利润、汽车交付，以及 AI 等新业务的估值假设',
        'keys': ['sotp_bridge', 'sotp_grid', 'seg_rev', 'seg_profit', 'gm_lines', 'line_op',
                 'ship', 'asp', 'ev', 'mau', 'hist_cash', 'cash_q', 'price', 'fit'],
    },
}


def kpi_code(code):
    state = json.loads((HERE / 'pages_state.json').read_text())['pages']
    links = []
    for key, title in [('val', '估值模型'), ('assume', '财务模型'), ('thesis', '核心论点')]:
        page = state.get(f'{key}@{code}')
        if page:
            links.append({'title': title, 'href': '/admin/' + page['pageSchemaUid']})
    config = {k: v for k, v in PROFILES[code].items() if k != 'keys'} | {'code': code, 'links': links}
    return ((HERE / 'price_summary.jsx').read_text() + '\n'
            + (HERE / 'company_dashboard_kpi.jsx').read_text().replace('__CONFIG__', json.dumps(config, ensure_ascii=False)))


# 估值模型页总览顶部的现价与三情景估值（与腾讯音乐估值模型页、各公司驾驶舱同一组件 price_summary.jsx）
PRICE_HEADER = r"""const CONFIG = __CONFIG__;
const finite = (v) => v !== null && v !== undefined && Number.isFinite(Number(v));
async function listRows(collectionName, filter) {
  const resource = ctx.makeResource('MultiRecordResource');
  resource.setResourceName(collectionName);
  resource.setPageSize(200);
  resource.setFilter(filter);
  await resource.refresh();
  return resource.getData() || [];
}
try {
  const [company] = await listRows('vi_company', { $and: [{ code: { $eq: CONFIG.code } }] });
  const [model] = await listRows('vi_model', { $and: [{ company_id: { $eq: company.id } }, { status: { $eq: '当前' } }] });
  const values = await listRows(CONFIG.sotp ? 'vi_sotp' : 'vi_valuation', { $and: [{ model_id: { $eq: model.id } }] });
  const fx = company.latest_fx;
  const quote = (v) => finite(v) && finite(fx) && Number(fx) > 0 ? Number(v) / Number(fx) : null;
  ctx.render(<PriceSummary price={CONFIG.sotp ? company.latest_price_raw : company.latest_price} date={company.latest_price_date} unit={CONFIG.sotp ? '港元' : '元'}
    scenarios={values.map((row) => ({ name: row.scenario_name, value: CONFIG.sotp ? quote(row.value_per_share) : row.value_today, isBase: !!row.is_base }))} />);
} catch (error) {
  ctx.render(<div style={{ color: '#999' }}>现价与情景估值读取失败：{String(error?.message || error)}</div>);
}
"""


def price_header_code(code):
    config = {'code': code, 'sotp': bool(PROFILES.get(code, {}).get('sotp'))}
    return (HERE / 'price_summary.jsx').read_text() + '\n' + PRICE_HEADER.replace('__CONFIG__', json.dumps(config, ensure_ascii=False))


SERIES = r"""const spec = __SPEC__;
const rows = (ctx.data?.objects || []).map((r) => ({...r, [spec.group]: spec.labels?.[r[spec.group]] || r[spec.group]}));
const categories = [...new Set(rows.map((r) => String(r[spec.x])))];
const names = [...new Set(rows.map((r) => spec.group ? String(r[spec.group]) : spec.label))];
const colors = ['#5470c6', '#2b9d8f', '#d99044', '#66758a', '#9b72b0'];
const fixedColors = {'隐含收益率': '#5470c6', '现金支持口径': '#2b9d8f', '要求收益率': '#66758a', '悲观': '#d99044', '基准': '#5470c6', '乐观': '#2b9d8f', '市场价': '#66758a'};
const zoom = categories.length > 45;
return {
  animation: false,
  grid: {left: 12, right: 22, top: 48, bottom: zoom ? 54 : 18, containLabel: true},
  legend: {top: 0, type: 'scroll', textStyle: {fontSize: 11}},
  tooltip: {trigger: 'axis', valueFormatter: (v) => v === null ? '—' : `${Number(v).toLocaleString('zh-CN', {maximumFractionDigits: spec.digits ?? 2})} ${spec.unit}`},
  xAxis: {type: 'category', data: categories, boundaryGap: spec.kind === 'bar',
    axisLabel: {hideOverlap: true, formatter: (v) => /^\d{4}Q/.test(v) ? v.slice(2) : v}, axisTick: {alignWithLabel: true}},
  yAxis: {type: 'value', name: spec.unit, scale: spec.scale || false, splitLine: {lineStyle: {color: '#edf0f4'}}},
  dataZoom: zoom ? [{type: 'inside'}, {type: 'slider', height: 18, bottom: 8, showDetail: false}] : [],
  series: names.map((name, i) => ({name, type: spec.kind, barMaxWidth: 30,
    showSymbol: categories.length < 25, symbolSize: 5, connectNulls: false,
    itemStyle: {color: fixedColors[name] || colors[i % colors.length]},
    lineStyle: {width: 2, type: /市场价|要求收益率/.test(name) ? 'dashed' : 'solid'},
    data: categories.map((category) => {
      const row = rows.find((r) => String(r[spec.x]) === category && (!spec.group || String(r[spec.group]) === name));
      return row && row[spec.y] !== null && row[spec.y] !== undefined ? Number(row[spec.y]) : null;
    }),
  })),
};
"""

BRIDGE = r"""const rows = ctx.data?.objects || [];
let accumulated = 0;
const bases = [], bars = [];
for (const row of rows) {
  const v = row.v === null || row.v === undefined ? null : Number(row.v);
  const total = ['合计', '市场价'].includes(row.part);
  bases.push(v === null ? null : total ? 0 : Math.min(accumulated, accumulated + v));
  bars.push(v === null ? null : {value: total ? v : Math.abs(v), itemStyle: {color: total ? row.part === '市场价' ? '#66758a' : '#5470c6' : v < 0 ? '#c65555' : '#2b9d8f'}});
  if (v !== null && !total) accumulated += v;
}
return {
  animation: false, grid: {left: 12, right: 16, top: 28, bottom: 14, containLabel: true},
  tooltip: {trigger: 'axis', formatter: (items) => {const row = rows[items[0].dataIndex]; return `${row.part}<br/>${row.v === null ? '—' : Number(row.v).toFixed(2)} 元/股`; }},
  xAxis: {type: 'category', data: rows.map((r) => r.part), axisLabel: {interval: 0, fontSize: 10, formatter: (v) => v.length > 4 ? v.slice(0, 4) + '\n' + v.slice(4) : v}},
  yAxis: {type: 'value', name: '人民币元/股', splitLine: {lineStyle: {color: '#edf0f4'}}},
  series: [
    {type: 'bar', stack: 'bridge', silent: true, itemStyle: {color: 'transparent'}, emphasis: {disabled: true}, data: bases},
    {type: 'bar', stack: 'bridge', barMaxWidth: 30, data: bars, label: {show: true, position: 'top', fontSize: 10, formatter: (p) => rows[p.dataIndex].v === null ? '—' : Number(rows[p.dataIndex].v).toFixed(1)}},
  ],
};
"""

TITLES = {
    'irr_scen': '三情景隐含回报与门槛（%）', 'irr_curve': '买入价与隐含年化回报（基准，%）',
    'req_curve': '回报门槛与最高买入价（元）', 'path': '基准预测：利润、股息与 FCFE（亿元）',
    'hist_np': '归母净利润与现金分红（亿元）', 'hist_cash': '经营现金流与资本开支（亿元）',
    'hist_quality': '年度毛利率与 ROE（%）', 'debt': '带息负债：历史与预测（亿元）',
    'fit': '价值投资适配度（各项 0—5 分）', 'level': '三峡水库水位（米）',
    'gm_q': '单季毛利率（%）', 'pulp': '纸浆与胶版纸价格（元/吨）', 'peer_gm': '单季毛利率：太阳纸业 vs 七家同业中位数（%）',
    'conv': '收入转化率：收入÷新签合同（%）', 'wc': '营收、应收与合同资产、应付（亿元）',
    'imp': '年度资产及信用减值损失（亿元）', 'peer_roe': 'ROE：中国建筑 vs 六家建筑央企中位数（%）',
    'peer_ar': '（应收＋合同资产）÷收入：中国建筑 vs 同业中位数（%）',
    'sotp_bridge': '基准每股价值桥接（人民币元）', 'sotp_grid': '成熟业务统一倍数试算（人民币元/股）',
    'seg_rev': '单季分部收入（亿元）', 'seg_profit': '单季分部经营损益（亿元）',
    'gm_lines': '单季分业务毛利率（%）', 'line_op': '年度分业务经营利润（分摊，亿元）',
    'ship': '单季智能手机出货（百万台）', 'asp': '单季智能手机 ASP（元）',
    'ev': '单季汽车交付（辆）', 'mau': '全球月活跃用户（百万人，季末）',
    'cash_q': '现金储备与借款（亿元，季末）',
}
LABELS = {
    '手机×AIoT 分部收入': '手机×AIoT', '智能电动汽车及AI分部收入': '汽车及 AI',
    '生态经营利润（推算）': '手机×AIoT（推算）', '汽车及AI分部经营损益': '汽车及 AI（含 AI 投入）',
    '智能手机毛利率': '手机', 'IoT毛利率': 'IoT', '互联网服务毛利率': '互联网', '汽车及AI分部毛利率': '汽车及 AI',
}


def charts(code, existing):
    from tencent_dashboard import FIT
    configs = {key: (title, config) for key, title, config in existing}
    out = []
    for key in PROFILES[code]['keys']:
        title, original = configs[key]
        config = json.loads(json.dumps(original))
        title = TITLES.get(key, title)
        if key == 'peer_roe':
            title = {'600900.SH': 'ROE：长江电力 vs 四家水电中位数（%）', '601668.SH': 'ROE：中国建筑 vs 六家建筑央企中位数（%）'}[code]
        if key == 'hist_vol':
            title = {'600900.SH': '年度发电量（亿千瓦时）', '002078.SZ': '年度浆纸销量（万吨）',
                     '601668.SH': '年度新签合同总额（亿元）'}[code]
        if key == 'price':
            title = '港股收盘价（港元/普通股，不复权）' if code == '01810.HK' else 'A 股收盘价（元/股，不复权）'
            config['query']['sql'] = (
                "SELECT o.obs_date,o.value AS 股价 FROM vi_obs_current o "
                "JOIN vi_company_base co ON co.price_metric_id=o.metric_id "
                f"WHERE co.code='{code}' ORDER BY o.obs_date")
        if key in ('ship', 'mau'):
            config['query']['sql'] = config['query']['sql'].replace('ORDER BY', "AND d.period_kind='单季' ORDER BY")
        if key == 'conv':
            config['query']['sql'] = config['query']['sql'].replace('h.price::numeric', '(h.price*100)::numeric')
        if key == 'fit':
            config['visual'] = {'mode': 'custom', 'raw': FIT}
        elif key == 'sotp_bridge':
            current = ("FROM vi_sotp s JOIN vi_company_base co ON co.id=s.company_id AND co.code='01810.HK' "
                       "JOIN vi_model_base m ON m.id=s.model_id AND m.status='当前' ")
            config['query']['sql'] = (
                "SELECT CASE g.code WHEN 'S1' THEN '手机' WHEN 'S2' THEN 'AIoT' WHEN 'S3' THEN '互联网' "
                "WHEN 'S4' THEN '汽车' WHEN 'S5' THEN 'AI等新业务' ELSE g.name END AS part,g.value/s.shares AS v, "
                "10+coalesce(nullif(regexp_replace(g.code,'\\D','','g'),'')::int,0) AS ord " + current +
                "JOIN vi_sotp_segment_val g ON g.scenario_id=s.id AND g.model_id=s.model_id WHERE s.is_base "
                "UNION ALL SELECT x.part,x.v/s.shares,x.ord " + current +
                "CROSS JOIN LATERAL (VALUES ('可用净现金',s.usable_net_cash,30),('对外投资',s.investments,31),"
                "('其他调整',s.asset_value-s.usable_net_cash-s.investments,32),('合计',s.equity_value,40),('市场价',s.market_price*s.shares,41)) x(part,v,ord) "
                "WHERE s.is_base ORDER BY ord")
            config['visual'] = {'mode': 'custom', 'raw': BRIDGE}
        else:
            visual = config['visual']
            mappings = visual['mappings']
            unit = ('%' if key in ('irr_scen', 'irr_curve', 'hist_quality', 'gm_q', 'conv', 'gm_lines', 'peer_gm', 'peer_roe', 'peer_ar') else
                    '亿元' if key in ('path', 'hist_np', 'hist_cash', 'debt', 'wc', 'imp', 'seg_rev', 'seg_profit', 'line_op', 'cash_q') else
                    '倍' if key == 'sotp_grid' else '米' if key == 'level' else '元/吨' if key == 'pulp' else
                    '亿千瓦时' if key == 'hist_vol' and code == '600900.SH' else '万吨' if key == 'hist_vol' and code == '002078.SZ' else
                    '亿元' if key == 'hist_vol' else '百万台' if key == 'ship' else '百万人' if key == 'mau' else
                    '辆' if key == 'ev' else '港元/股' if key == 'price' and code == '01810.HK' else '元/股' if key in ('price', 'req_curve', 'sotp_grid') else '元')
            if key == 'sotp_grid':
                unit = '元/股'
                config['query']['sql'] = config['query']['sql'].replace(
                    "AND co.code = '01810.HK'", "AND co.code = '01810.HK' JOIN vi_model_base cm ON cm.id=s.model_id AND cm.status='当前'")
            chart_spec = {'x': mappings['x'], 'y': mappings['y'], 'group': mappings.get('series'),
                          'label': title.split('（')[0], 'kind': visual['type'], 'unit': unit, 'labels': LABELS,
                          'scale': key in ('level', 'price', 'asp', 'pulp')}
            config['visual'] = {'mode': 'custom', 'raw': SERIES.replace('__SPEC__', json.dumps(chart_spec, ensure_ascii=False))}
        out.append((key, title, config))
    return out
