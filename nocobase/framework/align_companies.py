"""对标页面；显式限定公司，原地更新，禁止触及长江电力。

python3 framework/align_companies.py [002078.SZ ...] [--business-only]
"""
import json
import sys
from pathlib import Path
import build_pages as bp
import build_bizviews as biz
import build_chainmap as chain
import build_valuation as val
import build_overview as overview
from page_style import wrap_js, column_settings, business_unit_label

TARGETS = {'002078.SZ', '601668.SH', '01698.HK', '01810.HK'}
AUDIT = bp.ROOT / 'checks' / 'alignment_20261026'
ORIGINAL_BLUEPRINT = bp.blueprint


def aligned_blueprint(*args, **kwargs):
    body = ORIGINAL_BLUEPRINT(*args, **kwargs)
    company = kwargs.get('company') or (args[3] if len(args) > 3 else None)
    for tab in body['tabs']:
        for block in tab['blocks']:
            if block['type'] != 'table':
                continue
            meta = {f['name']: f for f in bp.live_fields(block['collection'])}
            columns = []
            for field in block['fields']:
                entry = {'field': field} if isinstance(field, str) else dict(field)
                entry['settings'] = column_settings(meta[entry['field']])
                if company and (label := business_unit_label(entry['field'], company['code'])):
                    entry['label'] = label
                columns.append(entry)
            block['fields'] = columns
            block['settings']['density'] = 'middle'
    # 字段说明保留；只提供说明文字，不清空任何全局集合元数据。
    for coll, defaults in body['defaults']['collections'].items():
        described = {f['name']: f['description']
                     for f in bp.live_fields(coll) if f.get('interface') and f.get('description') and f.get('interface') != 'dateOnly'}
        if described:
            defaults['formBehaviorDescriptionReview'] = {'fields': {
                name: {'decision': 'noUiBehavior', 'reasonCode': 'no-ui-behavior'} for name in described}}
    return body


def apply(name, body):
    overview.apply_page(name, body)
    print('APPLIED', name, flush=True)


def native_tab(code, title, gid, co):
    b = aligned_blueprint(code, title, gid, co)
    return b['tabs'][0], b['defaults']['collections']


def business(co, only=None):
    gid = chain.group_id(co)
    for code in biz.VIEWS:
        if only and code not in only:
            continue
        if bp.skipped(code, co):                   # 如腾讯音乐的情景、估值模型已并入「估值模型」页（build_pages.SOTP_ONLY）
            continue
        key = bp.page_key(code, co)
        title = biz.page_title(code)
        if key not in bp.state()['pages']:
            if not bp.build(code, title, bp.page_group(bp.state(), co, '商业模式', 'SafetyOutlined', code), co):
                raise RuntimeError('页面创建失败：' + key)
        b = aligned_blueprint(code, title, gid, co)
        visual = biz.VIEWS[code][0]
        extra_tabs = []
        if code == 'biz_model' and co['code'] == '01810.HK':
            tab, defaults = native_tab('business', '业务分部（编辑）', gid, co)
            tab['title'] = '业务分部（编辑）'
            extra_tabs.append(tab)
            b['defaults']['collections'].update(defaults)
        apply(f'bizview_{code}_{co["code"]}', {
            'version': '1', 'mode': 'replace', 'target': {'pageSchemaUid': bp.state()['pages'][key]['pageSchemaUid']},
            'page': {'title': title, 'documentTitle': f'{co["name"]} · {title}', 'enableTabs': True},
            'defaults': b['defaults'],
            'assets': {'scripts': {code: {'version': 'v2', 'code': business_script(code, co)}}},
            'tabs': [{'title': visual, 'blocks': [{'type': 'jsBlock', 'script': code}]},
                     {'title': biz.EDIT_TAB, 'blocks': b['tabs'][0]['blocks']}] + extra_tabs})
        bp.order_tabs(key, [visual, biz.EDIT_TAB] + [t['title'] for t in extra_tabs])
    if only:
        return
    key = bp.page_key(chain.KEY, co)
    b = chain.body(co, gid)
    if key in bp.state()['pages']:
        apply(f'chainmap_{co["code"]}', {'version': '1', 'mode': 'replace',
              'target': {'pageSchemaUid': bp.state()['pages'][key]['pageSchemaUid']}, **b})
    else:
        # 同名的产业链表格页原地改写，保留原地址。
        old = bp.page_key('value_chain', co)
        apply(f'chainmap_{co["code"]}', {'version': '1', 'mode': 'replace',
              'target': {'pageSchemaUid': bp.state()['pages'][old]['pageSchemaUid']}, **b})
        st = bp.state()
        st['pages'][key] = st['pages'].pop(old)
        bp.STATE.write_text(json.dumps(st, ensure_ascii=False, indent=1))
    bp.order_tabs(key, [chain.MAP_TAB, chain.EDIT_TAB, chain.COMP_TAB])
    bp.destroy_page(bp.page_key('competitor', co))
    chain.sort_group(gid)


def business_script(code, co):
    js = wrap_js(biz.script(code, co))
    if code == 'model':
        js = js.replace('逐年数字见“逐年假设”', '逐年数字见“财务模型 / 逐年假设（编辑）”')
    if code == 'scenario' and co['code'].endswith('.HK'):
        js = js.replace('${company.name} · 情景', '${company.name} · 情景 · 股东回报折现交叉验证')
        js = js.replace('情景只调整逐年假设的整体系数和永续增长；点情景看说明与结论。',
                        '此处为集团股东回报折现的交叉验证；主估值在“估值”页按分部加总。点情景看说明与结论。')
        js = js.replace('每股股息', '每股股东回报').replace('路径（元）', '路径（元人民币）')
    return js


def finance(co, only=None):
    gid = bp.ensure_group(bp.state(), f'{co["name"]}/预测与估值', '预测与估值', 'CalculatorOutlined', parent=bp.company_root(bp.state(), co))
    profile = val.PROFILES[co['code']]
    for key, title, icon, factory in val.PAGES:
        if only and key not in only:
            continue
        sotp_only = key == 'val' and co['code'] in bp.SOTP_ONLY
        if sotp_only:
            title = '估值模型'                       # 估值、估值模型、情景合并为一页（2026-10-28）
        script = financial_script(key, co)
        b = val.body(co, key, title, script)
        b['page']['enableTabs'] = True
        b['defaults'] = {'collections': {}}
        edits = [('fin_forecast' if co['code'] in bp.SOTP_ONLY else 'forecast', '逐年假设（编辑）')] if key == 'assume' else \
                ([('sotp_segment', '业务估值（编辑）')] if co['code'] in ('01810.HK', '01698.HK') else []) + [('sotp_item', '资产估值与调整（编辑）')] if profile['method'] == 'sotp' else []
        if sotp_only:
            edits += [('scenario', '情景（编辑）'), ('model', '模型参数（编辑）')]
        if key == 'val':
            b['tabs'][0]['title'] = '总览' if sotp_only else '分部估值' if profile['method'] == 'sotp' else '回报与门槛'
        for table, label in edits:
            tab, defaults = native_tab(table, label, gid, co)
            tab['title'] = label
            b['tabs'].append(tab)
            b['defaults']['collections'].update(defaults)
        pkey = bp.page_key(key, co)
        # 原财务模型与新页面同名：保留原页面和地址，只转换状态键。
        st = bp.state()
        old_key = bp.page_key('finmodel', co)
        if key == 'assume' and pkey not in st['pages'] and old_key in st['pages']:
            st['pages'][pkey] = st['pages'].pop(old_key)
            bp.STATE.write_text(json.dumps(st, ensure_ascii=False, indent=1))
        if pkey in bp.state()['pages']:
            live_uids = set()
            def walk(nodes):
                for node in nodes:
                    live_uids.add(node.get('schemaUid'))
                    walk(node.get('children') or [])
            walk(bp.routes())
            if bp.state()['pages'][pkey]['pageSchemaUid'] not in live_uids:
                st = bp.state(); del st['pages'][pkey]
                bp.STATE.write_text(json.dumps(st, ensure_ascii=False, indent=1))
        if pkey in bp.state()['pages']:
            apply(f'{key}_{co["code"]}', {'version': '1', 'mode': 'replace',
                 'target': {'pageSchemaUid': bp.state()['pages'][pkey]['pageSchemaUid']}, **b})
        else:
            apply(f'{key}_{co["code"]}', {'version': '1', 'mode': 'create',
                 'navigation': {'group': {'routeId': gid}, 'item': {'title': title, 'icon': icon}}, **b})
            overview.record(pkey, gid, title)
        if len(b['tabs']) > 1:
            bp.order_tabs(pkey, [t['title'] for t in b['tabs']])
    val.move_drafts(co)


def financial_script(key, co):
    profile = val.PROFILES[co['code']]
    factory = next(factory for k, _, _, factory in val.PAGES if k == key)
    js = factory(profile).replace('__COMPANY__', co['code']).replace('__PROFILE__', json.dumps(profile, ensure_ascii=False))
    if key == 'assume' and co['code'] in bp.SOTP_ONLY:      # 券商研报式财务预测（vi_fin_forecast）
        return wrap_js(val.FINMODEL_JS.replace('__COMPANY__', co['code']).replace('__PROFILE__', json.dumps(profile, ensure_ascii=False)))
    if key == 'val' and co['code'] in bp.SOTP_ONLY:
        return wrap_js(val.VALMODEL_JS.replace('__COMPANY__', co['code']).replace('__PROFILE__', json.dumps(profile, ensure_ascii=False)))
    if key == 'assume':
        js = wrap_js(js).replace('没列出的假设（折旧、利息、税率、派息率、资本开支）各情景相同。情景只改现金流，不改门槛，门槛在「估值」页。',
            '逐年路径与情景系数共同生成预测；分部估值另用各分部参数。所有金额为亿元人民币，每股金额及业务单位以行标题为准。')
        js = js.replace('改数字到「模型底稿 / 逐年假设」「情景」，改依据到「模型底稿 / 假设依据」。',
            '改逐年数字请切换本页「逐年假设（编辑）」；情景和假设依据在「模型底稿」。')
    elif profile['method'] == 'irr':
        js = wrap_js(js).replace('这几年是在一边还债一边多付股息。',
            '计划分红超过了模型当年的可分配现金，需要复核资本开支、回款和融资假设。')
    return js


def tables(co):
    # 可视化中已有的表不再在菜单重复出现，其余原生表格全部对齐列宽。
    for group, icon, pages in bp.COMPANY_MENU:
        for code, title in pages:
            if code in biz.VIEWS or bp.skipped(code, co):
                continue
            key = bp.page_key(code, co)
            if key not in bp.state()['pages']:
                continue
            body = aligned_blueprint(code, title, bp.page_group(bp.state(), co, group, icon, code), co)
            body.pop('navigation', None)
            body.update(mode='replace', target={'pageSchemaUid': bp.state()['pages'][key]['pageSchemaUid']})
            apply(f'{code}_{co["code"]}', body)
            if code in bp.REPORT_CODES:
                bp.strip_write_actions(key)


def dashboard(co):
    # 原地修改，地址与所有图表都保留。
    key = bp.page_key('dashboard', co)
    charts = overview.charts(overview.company_info(co))
    keys = [k for k, _, _ in charts]
    blocks = [{'key': 'kpi', 'type': 'jsBlock', 'script': 'kpi'}, {'key': 'collect', 'type': 'jsBlock', 'script': 'collect'}] + [
        {'key': k, 'type': 'chart', 'title': title, 'chart': k} for k, title, _ in charts]
    rows = [[{'key': 'kpi', 'span': 24}], [{'key': 'collect', 'span': 24}]] + [
        [{'key': k, 'span': 8} for k in keys[i:i+3]] for i in range(0, len(keys), 3)]
    if co['code'] == '01698.HK':
        from tencent_dashboard import layout
        rows = layout(keys)
        for block in blocks:
            if block['type'] == 'chart':
                block['settings'] = {'height': 360, 'heightMode': 'specifyValue'}
    body = {'version': '1', 'mode': 'replace', 'target': {'pageSchemaUid': bp.state()['pages'][key]['pageSchemaUid']},
        'page': {'title': '驾驶舱', 'documentTitle': f'{co["name"]} · 驾驶舱'},
        'assets': {'scripts': {'kpi': {'version': 'v2', 'code': overview.kpi_code(co['code'])},
                               'collect': {'version': 'v2', 'code': wrap_js(overview.collect_js(co['code']))}},
                   'charts': {k: chart for k, _, chart in charts}},
        'tabs': [{'title': '驾驶舱', 'layout': {'rows': rows}, 'blocks': blocks}]}
    apply(f'dashboard_{co["code"]}', body)


if __name__ == '__main__':
    want = {a for a in sys.argv[1:] if not a.startswith('--')} or TARGETS
    if not want <= TARGETS:
        raise SystemExit('只允许修改其余四家公司；长江电力受保护')
    bp.blueprint = aligned_blueprint
    for co in bp.companies():
        if co['code'] not in want:
            continue
        print('START', co['name'], flush=True)
        if '--finish' not in sys.argv:
            business(co)
        if '--business-only' not in sys.argv:
            finance(co)
            tables(co)
            dashboard(co)
        print('DONE', co['name'], flush=True)
    bp.sort_menu(want)
