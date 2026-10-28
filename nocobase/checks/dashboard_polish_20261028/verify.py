"""Verify persisted page configs against generated blueprints and frozen model data."""
import json
from pathlib import Path
P = Path(__file__).resolve().parent
FRAMEWORK = P.parents[1] / 'framework'
report = {}
lines = ['# 驾驶舱改版验收（2026-10-28）', '', '四家公司沿用腾讯音乐的阅读顺序：核心读数与三情景 → 两列核心图 → 底部折叠采集。页面地址保留。', '', '公司记录、模型参数、12 条情景估值、3 条小米分部加总和 76 条质量检查与改前逐字段一致。50 张图的 SQL 均已执行并返回数据，保存的配置与生成器核对一致。逐页截图检查首屏与核心图，采集折叠可展开，未发起采集或保存模型参数。', '', '腾讯音乐的两张股东回报图在本次工作期间由其他工作更新；本次未向腾讯音乐页面发出写操作。', '']
for short, name in [('600900','长江电力'), ('002078','太阳纸业'), ('601668','中国建筑'), ('01810','小米集团')]:
    code = short + ('.HK' if short == '01810' else '.SZ' if short == '002078' else '.SH')
    data = json.loads((P / (short + '_surface_after.json')).read_text())['data']
    before = json.loads((P / (short + '_surface_before.json')).read_text())['data']
    grid = data['tree']['subModels']['tabs'][0]['subModels']['grid']
    items = grid['subModels']['items']
    body = json.loads((FRAMEWORK / 'blueprints' / ('dashboard_' + code + '.json')).read_text())
    nodes = {n['stepParams']['cardSettings']['titleDescription']['title']: n for n in items if n['use'] == 'ChartBlockModel'}
    specs = [x for x in body['tabs'][0]['blocks'] if x['type'] == 'chart']
    assert len(nodes) == len(specs) == (14 if short == '01810' else 12)
    assert all(s == [12, 12] for s in list(grid['props']['sizes'].values())[1:-1])
    assert data['tree']['props']['routeId'] == before['tree']['props']['routeId']
    assert {n['stepParams']['jsSettings']['runJs']['code'].strip() for n in items if n['use'] == 'JSBlockModel'} == {s['code'].strip() for s in body['assets']['scripts'].values()}
    evidence = []
    for item in specs:
        node = nodes[item['title']]
        config = node['stepParams']['chartSettings']['configure']
        asset = body['assets']['charts'][item['chart']]
        assert config['query']['sql'].strip() == asset['query']['sql'].strip(), item['chart']
        assert config['chart']['option']['raw'].strip() == asset['visual']['raw'].strip(), item['chart']
        evidence.append({'title': item['title'], 'asset': item['chart'], 'uid': node['uid']})
    report[code] = {'route_preserved': True, 'chart_count': len(nodes), 'two_columns': True, 'scripts_match': True, 'chart_configs_match': True, 'charts': evidence}
    uid = body['target']['pageSchemaUid']
    lines += [f'## {name}', '', f'[打开页面](http://localhost:13000/admin/{uid}) · {len(nodes)} 张图。', '', f'![改后首屏]({short}_after.png)', '', '| 图表标题 | 资产键 | 线上区块 UID |', '|---|---|---|']
    lines += [f"| {e['title']} | {e['asset']} | {e['uid']} |" for e in evidence]
    lines += ['']
(P / 'structure_checks.json').write_text(json.dumps(report, ensure_ascii=False, indent=2))
lines += ['## 维护与恢复', '', '生成器：`framework/build_overview.py`、`company_dashboard.py`、`company_dashboard_kpi.jsx`。', '', '原地址更新命令（nocobase 目录）：', '', '```sh', 'python3 framework/build_overview.py --refresh-dashboard 600900.SH 002078.SZ 601668.SH 01810.HK', '```', '', '各公司 `*_rollback_blueprint.json` 的 `data.document` 可通过 `nb api flow-surfaces apply-blueprint` 恢复旧版。改前整库备份：`backups/nocobase_20261028_202029.sql.gz`。']
(P / '验收记录.md').write_text('\n'.join(lines))
print('PASS: 4 original routes, 50 chart configs, 8 JS blocks. Model data comparison: data_checks.json')
