"""只读验收：页面身份、表格列宽、公司范围、长江电力保护及模型数据。"""
import concurrent.futures
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import build_pages as bp
from page_style import column_settings

OUT = bp.ROOT / 'checks' / 'alignment_20261026'
TARGETS = {'002078.SZ', '601668.SH', '01698.HK', '01810.HK'}


def nodes(value):
    if isinstance(value, dict):
        if value.get('use'): yield value
        for item in value.values(): yield from nodes(item)
    elif isinstance(value, list):
        for item in value: yield from nodes(item)


if __name__ == '__main__':
    st = bp.state()
    all_routes = bp.routes()
    (OUT / 'routes_after.json').write_text(json.dumps(all_routes, ensure_ascii=False, indent=2))
    live_uids = set()
    def routes(items):
        for item in items:
            live_uids.add(item.get('schemaUid')); routes(item.get('children') or [])
    routes(all_routes)
    keys = [k for k in st['pages'] if k.split('@')[-1] in TARGETS | {'600900.SH'}]
    def fetch(key):
        return key, bp.page_tree(key)
    with concurrent.futures.ThreadPoolExecutor(max_workers=4) as pool:
        trees = dict(pool.map(fetch, keys))
    metadata = {f'vi_{code}': {f['name']: f for f in bp.live_fields(f'vi_{code}')} for code in bp.T}
    pages, problems, table_count, column_count = [], [], 0, 0
    for key, tree in trees.items():
        (OUT / ('after_' + key + '.json')).write_text(json.dumps(tree, ensure_ascii=False, sort_keys=True))
        if st['pages'][key]['pageSchemaUid'] not in live_uids:
            problems.append(key + ' 路由不存在')
        if key.endswith('@600900.SH'):
            before = json.loads((OUT / ('before_' + key + '.json')).read_text())
            if before != tree: problems.append(key + ' 受保护页面被修改')
            continue
        columns = []
        tables = [n for n in nodes(tree['tree']) if n.get('use') == 'TableBlockModel']
        for table in tables:
            table_count += 1
            for col in table.get('subModels', {}).get('columns', []):
                if col['use'] != 'TableColumnModel': continue
                binding = col.get('stepParams', {}).get('fieldSettings', {}).get('init', {})
                coll, field = binding.get('collectionName'), binding.get('fieldPath')
                if field not in metadata.get(coll, {}):
                    problems.append(f'{key} 未登记列 {coll}.{field}'); continue
                expected = column_settings(metadata[coll][field])['width']
                actual = col.get('props', {}).get('width')
                column_count += 1
                columns.append({'collection': coll, 'field': field, 'width': actual})
                if actual != expected:
                    problems.append(f'{key} 列宽 {coll}.{field}: {actual} != {expected}')
        pages.append({'key': key, 'pageSchemaUid': st['pages'][key]['pageSchemaUid'], 'tables': len(tables), 'columns': columns})
    # 基础输入与长江电力数据不应变化；风险是本轮明确新增的内容。
    data_checks = []
    for table in ['company', 'model', 'scenario', 'forecast', 'fin_history', 'thesis', 'judgment']:
        before = json.loads((OUT / ('vi_' + table + '.json')).read_text())['data']
        after = bp.nb_json('resource', 'list', '--resource', 'vi_' + table, '--page-size', '2000')['data']
        stable = lambda rows: sorted(rows, key=lambda r: r['id'])
        same = stable(before) == stable(after)
        data_checks.append({'table': table, 'unchanged': same})
        if not same: problems.append('基础数据变化：' + table)
    result = {'pages': len(pages), 'protected_pages': sum(k.endswith('@600900.SH') for k in trees),
              'native_tables': table_count, 'native_columns': column_count, 'data_checks': data_checks, 'problems': problems}
    (OUT / 'page_alignment_details.json').write_text(json.dumps(pages, ensure_ascii=False, indent=2))
    (OUT / 'verification.json').write_text(json.dumps(result, ensure_ascii=False, indent=2))
    print(json.dumps(result, ensure_ascii=False, indent=2))
    if problems: sys.exit(1)
