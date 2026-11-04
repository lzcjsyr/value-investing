"""定性事实页改为“事项 ｜ 全部事实”两个标签（2026-11-04）。页面原地改写，地址不变；改前页面树存在 checks/events_20261104/。

python3 framework/deploy_events.py
"""
import json
import build_pages as bp
import build_overview as bo
import align_companies as aligned
import scope_selects
import table_notes

OUT = bp.ROOT / 'checks' / 'events_20261104'

if __name__ == '__main__':
    OUT.mkdir(parents=True, exist_ok=True)
    for co in bp.companies():
        key = f'fact@{co["code"]}'
        (OUT / f'before_{key}.json').write_text(json.dumps(bp.page_tree(key), ensure_ascii=False, indent=1))
        gid = bp.state()['groups'][co['name'] + '/数据底稿']
        body = aligned.aligned_blueprint('fact', '定性事实', gid, co)
        body.pop('navigation', None)
        body.update(mode='replace', target={'pageSchemaUid': bp.state()['pages'][key]['pageSchemaUid']})
        bo.apply_page(f'fact_{co["code"]}', body)
        bp.order_tabs(key, ['事项', '全部事实'])
        print('页面', co['name'], '定性事实：事项 ｜ 全部事实', flush=True)
    scope_selects.main()                         # “所属事项”下拉只列本公司的事项
    table_notes.apply(table_notes.Notes())
