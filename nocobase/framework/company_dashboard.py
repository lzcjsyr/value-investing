"""四家公司驾驶舱：沿用腾讯音乐的信息层级，按生意保留核心图；关键读数五家同一份（dashboard_kpi.jsx，build_overview.kpi_code）。"""
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
PROFILES = {
    '600900.SH': {
        'focus': '经营重点：来水、发电量、电价与股东现金回报',
        'keys': ['gw_layers', 'hist_vol', 'level', 'peer_roe', 'hist_np', 'hist_cash',
                 'hist_quality', 'debt', 'price', 'fit'],
    },
    '002078.SZ': {
        'focus': '经营重点：浆纸销量、毛利率、扩产开支与负债',
        'keys': ['gw_layers', 'hist_vol', 'peer_gm', 'pulp', 'gm_q', 'hist_np', 'hist_cash',
                 'debt', 'hist_quality', 'price', 'fit'],
    },
    '601668.SH': {
        'focus': '经营重点：新签转收入、应收与合同资产、减值及现金回收',
        'keys': ['gw_layers', 'hist_vol', 'conv', 'wc', 'imp', 'peer_roe', 'peer_ar',
                 'hist_np', 'hist_cash', 'hist_quality', 'debt', 'price', 'fit'],
    },
    '01810.HK': {
        'focus': '经营重点：手机与生态利润、汽车交付，以及 AI 等新业务的估值假设',
        'keys': ['gw_layers', 'seg_rev', 'seg_profit', 'gm_lines', 'line_op',
                 'ship', 'asp', 'ev', 'mau', 'hist_cash', 'cash_q', 'price', 'fit'],
    },
}


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

TITLES = {
    'gw_layers': '三层价值与现价（元/股，今天）',
    'hist_np': '归母净利润与现金分红（亿元）', 'hist_cash': '经营现金流与资本开支（亿元）',
    'hist_quality': '年度毛利率与 ROE（%）', 'debt': '带息负债（亿元，年末）',
    'fit': '价值投资适配度（各项 0—5 分）', 'level': '三峡水库水位（米）',
    'gm_q': '单季毛利率（%）', 'pulp': '纸浆与胶版纸价格（元/吨）', 'peer_gm': '单季毛利率：太阳纸业 vs 七家同业中位数（%）',
    'conv': '收入转化率：收入÷新签合同（%）', 'wc': '营收、应收与合同资产、应付（亿元）',
    'imp': '年度资产及信用减值损失（亿元）', 'peer_roe': 'ROE：中国建筑 vs 六家建筑央企中位数（%）',
    'peer_ar': '（应收＋合同资产）÷收入：中国建筑 vs 同业中位数（%）',
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
        if key not in configs:                      # 没有内容的图（如还没填三层估值）不放
            continue
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
        else:
            visual = config['visual']
            mappings = visual['mappings']
            unit = ('%' if key in ('hist_quality', 'gm_q', 'conv', 'gm_lines', 'peer_gm', 'peer_roe', 'peer_ar') else
                    '亿元' if key in ('hist_np', 'hist_cash', 'debt', 'wc', 'imp', 'seg_rev', 'seg_profit', 'line_op', 'cash_q') else
                    '米' if key == 'level' else '元/吨' if key == 'pulp' else
                    '亿千瓦时' if key == 'hist_vol' and code == '600900.SH' else '万吨' if key == 'hist_vol' and code == '002078.SZ' else
                    '亿元' if key == 'hist_vol' else '百万台' if key == 'ship' else '百万人' if key == 'mau' else
                    '辆' if key == 'ev' else '港元/股' if key == 'price' and code == '01810.HK' else '元/股' if key in ('price', 'gw_layers') else '元')
            chart_spec = {'x': mappings['x'], 'y': mappings['y'], 'group': mappings.get('series'),
                          'label': title.split('（')[0], 'kind': visual['type'], 'unit': unit, 'labels': LABELS,
                          'scale': key in ('level', 'price', 'asp', 'pulp')}
            config['visual'] = {'mode': 'custom', 'raw': SERIES.replace('__SPEC__', json.dumps(chart_spec, ensure_ascii=False))}
        out.append((key, title, config))
    return out
