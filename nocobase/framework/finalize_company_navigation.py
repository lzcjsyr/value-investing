"""只整理四家公司菜单和标签；相同排序值按明确路由 ID 成批更新。"""
from collections import defaultdict
import json
import align_companies as a


def walk(nodes):
    for node in nodes:
        yield node
        yield from walk(node.get('children') or [])


if __name__ == '__main__':
    st = a.bp.state()
    roots = a.bp.routes()
    # 腾讯音乐用核心盈利，不需要空白的经营分部表；资产项目仍保留。
    target = st['pages']['val@01698.HK']['routeId']
    route = next(n for n in walk(roots) if n['id'] == target)
    for tab in route.get('children') or []:
        if tab['title'] == '经营分部（编辑）':
            a.bp.nb_json('flow-surfaces', 'remove-tab', '--uid', tab['schemaUid'])
    roots = a.bp.routes()
    by_id = {page['routeId']: key.split('@')[0] for key, page in st['pages'].items()}
    company_index = {co['name']: i+1 for i, co in enumerate(a.bp.companies())}
    target_names = {co['name'] for co in a.bp.companies() if co['code'] in a.TARGETS}
    sub_order = {g: [title for _, title in pages] for g, _, pages in a.bp.COMPANY_MENU}
    sub_order['数据底稿'] = ['业务数据', '财务数据', '重要事实', '来源文档']
    sub_order['预测与估值'] = ['重点指标', '财务模型', '估值'] + [title for title in sub_order['预测与估值'] if title != '重点指标'] + [a.bp.DRAFTS]
    sub_order[a.bp.DRAFTS] = sub_order['预测与估值']
    changes = defaultdict(list)
    tab_details = []
    def set_sort(node, value):
        if node.get('sort') != value: changes[value].append(node['id'])
    def sort_tabs(page):
        key = by_id.get(page['id'])
        tabs = page.get('children') or []
        expected = [a.biz.VIEWS[key][0], a.biz.EDIT_TAB] if key in a.biz.VIEWS else \
            [a.chain.MAP_TAB, a.chain.EDIT_TAB, a.chain.COMP_TAB] if key == 'chainmap' else \
            ['财务模型', '逐年假设（编辑）'] if key == 'assume' else \
            ['回报与门槛', '分部估值', '经营分部（编辑）', '资产项目（编辑）'] if key == 'val' else \
            ['定期经营数据', '高频业务数据'] if key == 'observation' else [tab['title'] for tab in tabs]
        ordered = sorted(tabs, key=lambda tab: expected.index(tab['title']) if tab['title'] in expected else 99)
        for i, tab in enumerate(ordered, 1): set_sort(tab, i)
        tab_details.append({'routeId': page['id'], 'key': key, 'titles': [tab['title'] for tab in ordered]})
    def sort_group(group):
        order = sub_order.get(group['title'], [])
        for child in group.get('children') or []:
            set_sort(child, (order.index(child['title']) if child['title'] in order else 99)+1)
            if child['type'] == 'group': sort_group(child)
            else: sort_tabs(child)
    for root in roots:
        if root['title'] not in target_names: continue
        base = company_index[root['title']] * 1000
        set_sort(root, base)
        for child in root.get('children') or []:
            order = a.bp.COMPANY_TOP
            set_sort(child, base + ((order.index(child['title']) if child['title'] in order else 99)+1)*10)
            if child['type'] == 'group': sort_group(child)
            else: sort_tabs(child)
    for value, ids in changes.items():
        filt = {'$or': [{'id': {'$eq': rid}} for rid in ids]}
        a.bp.nb_json('resource', 'update', '--resource', 'desktopRoutes', '--filter', json.dumps(filt), '--values', json.dumps({'sort': value}))
        print('SORT', value, len(ids), flush=True)
    (a.AUDIT / 'tab_order_expected.json').write_text(json.dumps(tab_details, ensure_ascii=False, indent=2))
    print('菜单与标签整理完成', len(tab_details), '页', flush=True)
