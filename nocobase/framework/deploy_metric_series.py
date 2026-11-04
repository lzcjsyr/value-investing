"""指标性质与“一个指标一行＋趋势”上线（2026-11-04）。页面原地改写，地址不变；改前的页面树存在 checks/metric_series_20261104/。

1. 五家公司数据底稿：「财务报表」只放三大报表；「定量指标」三个标签（定期经营、高频经营、分部与财务补充）都是指标表
   （每个指标一行，点开看逐期数据并录入）。菜单顺序：财务报表、定量指标、定性事实、来源文档。
2. 所有指标表格补“指标性质”列和“趋势”小折线（trend_column.py）。
3. 指标详情弹窗换新脚本（按指标性质限定口径、统计时间），详情区块补“指标性质”。
4. 表格说明栏按新结构重写（table_notes.py）。

python3 framework/deploy_metric_series.py
"""
import json, subprocess
import build_pages as bp
import build_finstmt as bf
import build_overview as bo
import align_companies as aligned
import metric_detail
import table_notes
import trend_column

OUT = bp.ROOT / 'checks' / 'data_menu_20261104'   # 改前页面树（上一轮在 metric_series_20261104）


def snapshot(key, co):
    tree = bp.page_tree(f'{key}@{co["code"]}')
    (OUT / f'before_{key}_{co["code"]}.json').write_text(json.dumps(tree, ensure_ascii=False, indent=1))


def data_pages(co):
    """数据底稿（2026-11-04 调整）：财务报表（只放三大报表）在前；定量指标＝定期经营｜高频经营｜分部与财务补充，每个指标一行。"""
    gid = bp.state()['groups'][co['name'] + '/数据底稿']
    body = aligned.aligned_blueprint('observation', '定量指标', gid, co)
    body.pop('navigation', None)
    body.update(mode='replace', target={'pageSchemaUid': bp.state()['pages'][f'observation@{co["code"]}']['pageSchemaUid']})
    bo.apply_page(f'observation_{co["code"]}', body)
    rename(f'observation@{co["code"]}', '定量指标')
    bp.order_tabs(f'observation@{co["code"]}', ['定期经营', '高频经营', '分部与财务补充'])
    body = bf.page_body(co, gid)
    body.update(version='1', mode='replace', target={'pageSchemaUid': bp.state()['pages'][f'finstmt@{co["code"]}']['pageSchemaUid']})
    bo.apply_page(f'finstmt_{co["code"]}', body)
    rename(f'finstmt@{co["code"]}', bf.TITLE)
    print('页面', co['name'], '财务报表、定量指标', flush=True)


def rename(key, title):
    bp.nb_json('resource', 'update', '--resource', 'desktopRoutes', '--filter-by-tk', str(bp.state()['pages'][key]['routeId']),
               '--values', json.dumps({'title': title}, ensure_ascii=False))


def sql(q):
    return subprocess.run([str(bp.ROOT / 'psql.sh'), '-At', '-c', q], capture_output=True, text=True, check=True).stdout.split()


def popups():
    """已建的指标详情弹窗：脚本换新；详情区块补“指标性质”（放在类别后面）。"""
    for uid in sql("""SELECT uid FROM "flowModels" WHERE options->>'use' = 'JSBlockModel' AND options::text LIKE '%指标趋势读取失败%'"""):
        bp.nb_json('flow-surfaces', 'configure', '--target', json.dumps({'uid': uid}),
                   '--changes', json.dumps({'code': metric_detail.JS, 'version': 'v2'}, ensure_ascii=False))
    for uid in sql("""SELECT d.uid FROM "flowModels" d WHERE d.options->>'use' = 'DetailsBlockModel'
                      AND d.options#>>'{stepParams,resourceSettings,init,collectionName}' = 'vi_metric'"""):
        tree = bp.nb_json('flow-surfaces', 'get', '--uid', uid)['data']
        tree = tree.get('tree', tree)
        grid = tree['subModels']['grid']
        items = grid.get('subModels', {}).get('items', [])
        paths = {i.get('stepParams', {}).get('fieldSettings', {}).get('init', {}).get('fieldPath'): i['uid'] for i in items}
        if 'measure' in paths or 'category' not in paths:
            continue
        new = bp.nb_json('flow-surfaces', 'add-field', '--target', json.dumps({'uid': uid}), '--field-path', 'measure')['data']['uid']
        trend_column.move_after(new, paths['category'])
    print('指标详情弹窗已更新', flush=True)


if __name__ == '__main__':
    OUT.mkdir(parents=True, exist_ok=True)
    for co in bp.companies():
        for key in ('observation', 'finstmt'):
            snapshot(key, co)
    for co in bp.companies():
        data_pages(co)
    bp.sort_menu()
    trend_column.main()          # 指标表格补“指标性质”“趋势”；定量指标页的趋势紧跟指标名称
    popups()
    table_notes.apply(table_notes.Notes())
