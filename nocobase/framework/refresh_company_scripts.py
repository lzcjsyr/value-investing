"""只更新四家公司的渲染脚本，保留页面、标签、编辑表格与地址。"""
import json
import align_companies as a
from page_style import wrap_js, business_unit_label


def js_blocks(tree):
    for b in a.bp.blocks(tree):
        if b['use'] == 'JSBlockModel':
            yield b


if __name__ == '__main__':
    results = []
    for co in a.bp.companies():
        if co['code'] not in a.TARGETS:
            continue
        for key in ('assume', 'val', 'model', 'scenario', 'dashboard'):
            tree = a.bp.page_tree(a.bp.page_key(key, co))
            blocks = list(js_blocks(tree['tree']))
            if not blocks:
                raise RuntimeError(f'{co["code"]} {key} 没有渲染区块')
            scripts = [a.overview.kpi_code(co['code']), wrap_js(a.overview.collect_js(co['code']))] if key == 'dashboard' else \
                [a.financial_script(key, co)] if key in ('assume', 'val') else [a.business_script(key, co)]
            if len(blocks) != len(scripts):
                raise RuntimeError(f'{co["code"]} {key} 区块数量不符')
            for block, script in zip(blocks, scripts):
                a.bp.nb_json('flow-surfaces', 'configure', '--target', json.dumps({'uid': block['uid']}),
                             '--changes', json.dumps({'version': 'v2', 'code': script}, ensure_ascii=False))
            results.append({'company': co['code'], 'page': key, 'scripts': len(scripts)})
            print('REFRESH', co['code'], key, flush=True)
        for key in ('assume',):
            tree = a.bp.page_tree(a.bp.page_key(key, co))
            def walk(value):
                if isinstance(value, dict):
                    if value.get('use') == 'TableColumnModel': yield value
                    for item in value.values(): yield from walk(item)
                elif isinstance(value, list):
                    for item in value: yield from walk(item)
            for column in walk(tree['tree']):
                init = column.get('stepParams', {}).get('fieldSettings', {}).get('init', {})
                label = business_unit_label(init.get('fieldPath'), co['code'])
                if label:
                    a.bp.nb_json('flow-surfaces', 'configure', '--target', json.dumps({'uid': column['uid']}),
                                 '--changes', json.dumps({'label': label, 'width': 220}, ensure_ascii=False))
    (a.AUDIT / 'script_refresh.json').write_text(json.dumps(results, ensure_ascii=False, indent=2))
