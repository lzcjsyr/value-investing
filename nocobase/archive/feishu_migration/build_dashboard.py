"""驾驶舱页面：复刻飞书「V2价值投资驾驶舱」的说明文字 + 14 张图表，并新增一行 KPI 卡片。"""
import json, subprocess, pathlib

HERE = pathlib.Path(__file__).resolve().parent
STATE = json.loads((HERE / 'pages_state.json').read_text())

INTRO = """# 长江电力 · 价值投资驾驶舱
事实 → 判断 → 参数 → 财务 → 估值 → 证伪

**当前为条件模型，旧财务假设尚待原件核验。** 估值基准为2025年末，不能直接视为今天的目标价。现金桥接缺失时不输出现金支持估值。市场观察独立更新，不自动覆盖长期折现率。"""

DISCIPLINE = """## 从哪里开始
1. 3.3 质量检查：先处理关键缺口。
2. 1.2 证据账本：登记原文、报告期和口径。
3. 1.3 事实→判断映射：写清为什么改、改哪年、什么情况不改。
4. 2.2 年度假设与 2.1 情景参数：修改输入，SQL 视图自动重算。
5. 3.4 变更日志：保留旧值、新值、理由和验证。

## 三条底线
- 折旧不是免费现金；资本更新不能漏。
- 偿债、扩张和分红不能重复使用同一笔现金。
- 好公司与好价格分开判断；先问什么会导致永久损失。"""

COLLECT = """## 本机采集（NocoBase 工作流，电脑开机且 Docker 运行时才执行）
18:30 抓取 → 18:40 校验去重入库 → 19:10 异常检查。已接入：股价（腾讯）、国债10年（中债）、三峡库水位（长江水文网）。
原始响应及每次运行状态保存在 4.2 采集原始记录；4.1 采集状态查看健康状态。不同来源独立存储，不自动改估值假设。历史水文负流量已从有效看板隔离；原值保留待核验。"""

KPI_CODE = r"""const { Card, Col, Row, Statistic, Tag, Typography, Alert } = ctx.libs.antd;

async function listRows(collectionName) {
  const resource = ctx.makeResource('MultiRecordResource');
  resource.setResourceName(collectionName);
  resource.setPageSize?.(200);
  await resource.refresh();
  return resource.getData() || [];
}

const fmt = (v, d = 2) => (v === null || v === undefined || v === '' ? '—' : Number(v).toFixed(d));
const pct = (v, d = 1) => (v === null || v === undefined || v === '' ? '—' : (Number(v) * 100).toFixed(d) + '%');

try {
  const [valuations, scenarios, quality, collect] = await Promise.all([
    listRows('cj_valuation'),
    listRows('cj_scenario'),
    listRows('cj_quality'),
    listRows('cj_collect_ctl'),
  ]);
  const base = valuations.find((r) => r.scenario === '基准') || {};
  const baseScenario = scenarios.find((r) => r.scenario === '基准') || {};
  const passed = valuations.filter((r) => r.model_check === '通过').length;
  const connected = collect.filter((r) => r.integration_status === '云端已接入');
  const healthy = connected.filter((r) => r.health_status === '正常').length;
  const premium = base.cond_ddm > 0 && base.market_price ? base.market_price / base.cond_ddm - 1 : null;

  ctx.render(
    <div>
      <Row gutter={[12, 12]}>
        <Col xs={12} md={6}><Card size="small"><Statistic title="基准条件DDM（元/股）" value={fmt(base.cond_ddm)} /></Card></Col>
        <Col xs={12} md={6}><Card size="small"><Statistic title={`市场观察价（${base.market_date || '—'}）`} value={fmt(base.market_price)} /></Card></Col>
        <Col xs={12} md={6}><Card size="small"><Statistic title="市场价相对条件DDM" value={premium === null ? '—' : (premium * 100).toFixed(1) + '%'} /></Card></Col>
        <Col xs={12} md={6}><Card size="small"><Statistic title="基准有效折现率" value={pct(baseScenario.eff_discount_rate)} /></Card></Col>
        <Col xs={12} md={6}><Card size="small"><Statistic title="关注价·10%边际（元）" value={fmt(base.watch_price_10)} /></Card></Col>
        <Col xs={12} md={6}><Card size="small"><Statistic title="关注价·30%边际（元）" value={fmt(base.watch_price_30)} /></Card></Col>
        <Col xs={12} md={6}><Card size="small"><Statistic title="三情景模型勾稽" value={`${passed} / ${valuations.length} 通过`} /></Card></Col>
        <Col xs={12} md={6}><Card size="small"><Statistic title="已接入数据健康" value={`${healthy} / ${connected.length} 正常`} /></Card></Col>
      </Row>
      <Typography.Paragraph type="secondary" style={{ marginTop: 8, marginBottom: 0 }}>
        {base.decision_status || ''}
      </Typography.Paragraph>
    </div>
  );
} catch (error) {
  ctx.render(<Alert type="error" showIcon message="驾驶舱指标读取失败" description={String(error?.message || error)} />);
}
"""


def obs_chart(code):
    return {
        'query': {'mode': 'sql', 'sql': (
            "SELECT obs_date, max(unified_value) AS value FROM cj_market_obs "
            f"WHERE metric_code = '{code}' AND is_current AND quality_ok = 1 "
            "GROUP BY obs_date ORDER BY obs_date")},
        'visual': {'mode': 'basic', 'type': 'line', 'mappings': {'x': 'obs_date', 'y': 'value'}},
    }


def sql_chart(sql, kind, mappings):
    return {'query': {'mode': 'sql', 'sql': sql}, 'visual': {'mode': 'basic', 'type': kind, 'mappings': mappings}}


CHARTS = [
    ('ddm', '三情景条件DDM（元/股）', sql_chart(
        "SELECT scenario, round(cond_ddm::numeric, 2) AS cond_ddm FROM cj_valuation ORDER BY id",
        'bar', {'x': 'scenario', 'y': 'cond_ddm'})),
    ('watch', '两档安全边际关注价（元/股）', sql_chart(
        "SELECT scenario, '关注价10元' AS level, round(watch_price_10::numeric, 2) AS price, id FROM cj_valuation "
        "UNION ALL SELECT scenario, '关注价30元', round(watch_price_30::numeric, 2), id FROM cj_valuation ORDER BY id, level",
        'bar', {'x': 'scenario', 'y': 'price', 'series': 'level'})),
    ('tv_share', '终值占比：越高越依赖远期假设', sql_chart(
        "SELECT scenario, round(terminal_share::numeric, 4) AS terminal_share FROM cj_valuation ORDER BY id",
        'bar', {'x': 'scenario', 'y': 'terminal_share'})),
    ('profit_div', '基准利润与计划股息（亿元）', sql_chart(
        "SELECT year, '归母利润代理' AS item, round(np_proxy::numeric, 2) AS amount FROM cj_fin_calc WHERE scenario_name = '基准' "
        "UNION ALL SELECT year, '计划股息', round(planned_div::numeric, 2) FROM cj_fin_calc WHERE scenario_name = '基准' ORDER BY year, item",
        'line', {'x': 'year', 'y': 'amount', 'series': 'item'})),
    ('evidence', '证据核验进度', sql_chart(
        "SELECT verify_status, count(*) AS n FROM cj_evidence GROUP BY verify_status ORDER BY n DESC",
        'barHorizontal', {'x': 'verify_status', 'y': 'n'})),
    ('quality', '质量检查实时状态', sql_chart(
        "SELECT live_status, count(*) AS n FROM cj_quality GROUP BY live_status ORDER BY n DESC",
        'barHorizontal', {'x': 'live_status', 'y': 'n'})),
    ('health', '数据采集健康状态', sql_chart(
        "SELECT health_status, count(*) AS n FROM cj_collect_ctl GROUP BY health_status ORDER BY health_status",
        'barHorizontal', {'x': 'health_status', 'y': 'n'})),
    ('trial', '单参数变化→每股价值变化（元）', sql_chart(
        "SELECT trial, round(value_change::numeric, 2) AS value_change FROM cj_param_trial ORDER BY id",
        'barHorizontal', {'x': 'trial', 'y': 'value_change'})),
    ('cgb_wind', '国债收益率观察（%，中证口径）', obs_chart('M1001654')),
    ('inflow', '三峡入库流量（立方米/秒）', obs_chart('Z3791116')),
    ('level_wind', '三峡库水位（米）', obs_chart('L1680403')),
    ('cgb_cloud', '采集 · 中债国债10年收益率（%）', obs_chart('CHINABOND-CGB10Y')),
    ('level_cloud', '采集 · 三峡库水位（米）', obs_chart('CJH-SX-LEVEL')),
    ('price_cloud', '采集 · 长江电力股价（元）', obs_chart('TENCENT-600900')),
]


def blueprint():
    blocks = [
        {'key': 'intro', 'type': 'markdown', 'title': '先看模型质量，再看估值', 'settings': {'content': INTRO}},
        {'key': 'discipline', 'type': 'markdown', 'title': '研究纪律与操作入口', 'settings': {'content': DISCIPLINE}},
        {'key': 'kpi', 'type': 'jsBlock', 'title': '关键读数', 'script': 'kpi'},
        {'key': 'collect', 'type': 'markdown', 'title': '采集覆盖与限制', 'settings': {'content': COLLECT}},
    ] + [{'key': k, 'type': 'chart', 'title': t, 'chart': k} for k, t, _ in CHARTS]
    keys = [k for k, _, _ in CHARTS]
    rows = [[{'key': 'intro', 'span': 12}, {'key': 'discipline', 'span': 12}],
            [{'key': 'kpi', 'span': 24}],
            [{'key': 'collect', 'span': 24}]]
    rows += [[{'key': k, 'span': 8} for k in keys[i:i + 3]] for i in range(0, len(keys), 3)]
    return {
        'version': '1', 'mode': 'create',
        'navigation': {'group': {'routeId': STATE['groups']['0 驾驶舱']}, 'item': {'title': '驾驶舱', 'icon': 'DashboardOutlined'}},
        'page': {'title': '驾驶舱', 'documentTitle': '长江电力 · 驾驶舱'},
        'assets': {'scripts': {'kpi': {'version': 'v2', 'code': KPI_CODE}},
                   'charts': {k: c for k, _, c in CHARTS}},
        'tabs': [{'title': '驾驶舱', 'layout': {'rows': rows}, 'blocks': blocks}],
    }


if __name__ == '__main__':
    path = HERE / 'blueprints' / 'dashboard.json'
    path.write_text(json.dumps(blueprint(), ensure_ascii=False, indent=1))
    p = subprocess.run(['nb', 'api', 'flow-surfaces', 'apply-blueprint', '--body-file', str(path), '-j'],
                       capture_output=True, text=True, cwd=HERE.parent)
    out = p.stdout
    if p.returncode:
        j = out[out.find('{'):out.rfind('}') + 1]
        try:
            for e in json.loads(j).get('errors', []):
                print('-', e.get('ruleId'), e.get('path'), '|', e.get('message')[:300])
                if e.get('details', {}).get('repairHint'):
                    print('   hint:', str(e['details']['repairHint'])[:300])
        except Exception:
            print(out[-3000:], p.stderr[-1000:])
    else:
        print('OK')
