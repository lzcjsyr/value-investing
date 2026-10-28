"""生成 NocoBase 页面：每家公司一个顶层菜单（商业模式/预测与估值/数据底稿/研究维护），共用页面在“框架与后台”。

表格默认只显示关键列（COLUMNS）；新增/编辑表单只含输入字段与关联；详情弹窗显示全部字段并分组；
只读报表（预测计算、估值结论、敏感性、质量自检）没有新增/编辑/删除。
用法：python3 build_pages.py [公司代码 ...]；已建页面记录在 pages_state.json（键：表代码@公司代码），重复执行会跳过。
"""
import json, subprocess, sys, pathlib, secrets, string
from contextlib import contextmanager
import spec

HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parent
STATE = HERE / 'pages_state.json'
T = spec.all_tables() | {r['code']: r for r in spec.REPORTS}
REPORT_CODES = {r['code'] for r in spec.REPORTS}

# 菜单按公司分列：每家公司一个顶层菜单（驾驶舱在最上面，下面四个二级分组），只显示这家公司的数据；
# 财务模型是可视化页，由 build_finmodel.py 生成，放在“预测与估值”组内第一页（sort_menu 负责排序）。
# 跨公司共用的内容（使用说明、公司、指标、自动采集）放在“框架与后台”。
COMPANY_MENU = [  # (二级分组, 图标, [(code, 页面标题)])
    # 商业模式：纯分析（每个观点只写一处）
    ('商业模式', 'SafetyOutlined', [('biz_model', '商业模式拆解'), ('value_chain', '产业链与五力'), ('competitor', '竞争对手'),
                                   ('moat', '竞争壁垒'), ('risk', '风险分析'), ('fit_score', '价投适配度'), ('thesis', '核心论点')]),
    # 预测与估值：财务模型（可视化总览）在最前；表格页先看假设依据（每个参数为什么这么设），再看结论与模型
    # 重点指标＝财务模型和判断依赖的数（模型字段指标、假设依据与风险的跟踪指标），点开看趋势；放在组内最前，有定制估值页的公司也不收进模型底稿
    ('预测与估值', 'CalculatorOutlined', [('key_metric', '重点指标'), ('judgment', '假设依据'), ('valuation', '估值结论'), ('sotp', '分部加总估值'), ('sotp_segment', '经营分部估值'), ('sotp_item', '资产估值与调整'), ('model', '估值模型'), ('scenario', '情景'), ('forecast', '逐年假设'),
                                   ('projection', '预测计算'), ('balance', '资产与资本'), ('sensitivity', '敏感性：折现率×永续增长'),
                                   ('trial', '单参数试验')]),
    # 数据底稿：业务数据＝定期经营指标与高频业务环境，财务结果另列；
    # 原始材料：业务数据（每期数值）、财务数据（季度三大报表的定制页 build_finstmt.py，不在此生成）、重要事实（文字）、来源文档（出处，垫底）。
    # 指标目录不在这里：在「预测与估值 / 重点指标」（模型数据｜跟踪指标｜其他指标）
    ('数据底稿', 'DatabaseOutlined', [('observation', '业务数据'), ('fact', '重要事实'), ('source', '来源文档')]),
    # 研究维护：维护这套研究本身（模型与数据检查、待办、改动记录），不是对公司的分析
    ('研究维护', 'ToolOutlined', [('check', '质量自检'), ('issue', '待办清单'), ('change_log', '变更日志')]),
]
# 宏观数据：独立项目（顶层菜单），利率、汇率、商品等不属于任何公司的指标，各公司按需使用（估值参数、重点跟踪、订阅）
MACRO = ('宏观数据', 'GlobalOutlined', [('metric', '指标'), ('observation', '高频数据'), ('collector', '采集配置')])
MACRO_SCOPE = {'metric': 'scope', 'observation': 'metric.scope', 'collector': 'metric.scope'}   # 归属＝宏观
REPLACED_BY_CHAINMAP = ('value_chain', 'competitor')   # 有可视化产业链页面（build_chainmap.py）的公司不再单独生成这两个表格页
# 有定制估值页（build_valuation.py：财务模型 → 估值）的公司：“预测与估值”组只放这两页，
# 录入用的表格页收进组内的“模型底稿”子组；skip 里的页面不生成：用不到的估值方法、已被定制页取代的只读报表与财务模型
DRAFTS = '模型底稿'
REPLACED_BY_CUSTOM = ('finmodel', 'valuation', 'projection', 'balance', 'sensitivity', 'trial')
CUSTOM_VALUATION = {'600900.SH': {'skip': ('sotp', 'sotp_segment', 'sotp_item') + REPLACED_BY_CUSTOM}}
for _code in ('002078.SZ', '601668.SH', '01698.HK', '01810.HK'):
    CUSTOM_VALUATION[_code] = {'skip': ('sotp', 'sotp_segment', 'sotp_item', 'forecast') + REPLACED_BY_CUSTOM}
# 只用分部加总三块的公司（2026-10-28 起腾讯音乐）：估值、估值模型、情景合并为「估值模型」一页（页面键仍是 val），
# 情景与模型参数变成该页的编辑标签，不再单独生成「模型底稿 / 估值模型」「情景」
SOTP_ONLY = {'01698.HK'}
for _code in SOTP_ONLY:
    CUSTOM_VALUATION[_code]['skip'] += ('scenario', 'model')
SHARED = '框架与后台'
SHARED_MENU = [('company', '公司')]                      # 直接放在“框架与后台”下；指标在各公司「数据底稿」和「宏观数据」里
SHARED_SUB = ('采集', 'CloudDownloadOutlined',
              [('collector', '采集配置'), ('collect_run', '采集运行'), ('raw_capture', '原始采集记录'), ('observation', '数据（全部指标）')])
COMPANY_ICON = {'600900.SH': 'ThunderboltOutlined', '002078.SZ': 'FileTextOutlined', '601668.SH': 'BuildOutlined',
                '01698.HK': 'SoundOutlined', '01810.HK': 'MobileOutlined'}
# 每张表按哪个字段过滤到“这家公司”（关联路径的末端都是整数字段，用 $eq）
SCOPE = {'thesis': 'company_id', 'fact': 'company_id', 'source': 'company_id', 'judgment': 'company_id',
         'business': 'company_id', 'biz_model': 'company_id', 'value_chain': 'company_id', 'competitor': 'company_id', 'moat': 'company_id',
         'fit_score': 'company_id', 'risk': 'company_id', 'sotp_item': 'model.company_id', 'sotp_segment': 'model.company_id', 'sotp': 'company_id',
         'observation': 'metric.company_id',
         'model': 'company_id', 'scenario': 'model.company_id', 'forecast': 'model.company_id', 'fin_forecast': 'model.company_id', 'trial': 'model.company_id',
         'issue': 'company_id', 'change_log': 'company_id',
         'projection': 'company_id', 'balance': 'company_id', 'valuation': 'company_id', 'sensitivity': 'company_id', 'check': 'company_id'}

COLUMNS = {
    'company': ['code', 'name', 'industry', 'volume_label', 'volume_unit', 'price_label', 'latest_price', 'latest_price_raw', 'latest_fx', 'latest_price_date'],
    'thesis': ['code', 'title', 'category', 'status', 'confidence', 'verdict', 'mind_changer', 'check_result', 'debated_on'],
    'source': ['title', 'source_type', 'publish_date', 'reliability', 'verify_status', 'url'],
    'fact': ['title', 'category', 'period', 'verify_status', 'source'],
    'judgment': ['code', 'title', 'parameter', 'status', 'theses', 'facts'],
    'business': ['code', 'name', 'boundary', 'cost_allocation', 'asset_boundary'],
    'biz_model': ['business', 'code', 'element', 'title', 'metric', 'trend'],
    'value_chain': ['code', 'position', 'participant', 'force', 'power', 'effect', 'trend', 'profit_share'],
    'competitor': ['name', 'relation', 'segment', 'scale_label', 'scale_value', 'scale_unit', 'paying_rate', 'gross_margin', 'growth',
                   'price_point', 'threat', 'trend', 'as_of'],
    'moat': ['code', 'title', 'moat_type', 'verdict', 'strength', 'trend', 'check_result', 'debate_count', 'debate_winner'],
    'fit_score': ['dimension', 'score', 'rationale', 'theses'],
    'risk': ['code', 'title', 'category', 'probability', 'impact', 'level', 'treatment', 'status', 'thesis_verdicts'],
    'sotp_item': ['code', 'scenario', 'name', 'kind', 'treatment', 'business', 'valuation_method', 'metric', 'amount', 'amount_used', 'haircut', 'signed_value', 'as_of'],
    'sotp_segment': ['business', 'code', 'scenario', 'name', 'method', 'stage', 'earn_year', 'revenue', 'op_margin', 'multiple_used', 'eff_rate',
                     'interim_cash', 'commit_amount', 'ongoing_cost', 'direct_value', 'value', 'calc_scenario'],
    'sotp': ['scenario_name', 'probability', 'core_earnings', 'multiple', 'core_value', 'segments_value', 'usable_net_cash', 'investments', 'minority_other',
             'value_per_share', 'value_per_share_quote', 'market_price', 'price_vs_value', 'implied_core_multiple', 'implied_mature_multiple',
             'implied_growth_value', 'weighted_value', 'ddm_value', 'conclusion'],
    'key_metric': ['name', 'model_field', 'tracked_by', 'latest_value', 'unit', 'latest_period', 'state', 'source_kind', 'notes'],
    'metric': ['name', 'category', 'unit', 'basis', 'latest_value', 'latest_period', 'state', 'tracked_by', 'source_kind', 'formula', 'source_name'],
    'observation': ['metric', 'obs_date', 'value', 'unit', 'is_current', 'is_valid', 'collected_at', 'doc', 'raw_capture'],
    'model': ['name', 'status', 'primary_method', 'required_return', 'base_year', 'terminal_year', 'shares', 'rf', 'erp', 'base_discount_rate',
              'sotp_year', 'valuation_date'],
    'scenario': ['name', 'is_base', 'probability', 'volume_factor', 'price_factor', 'cost_factor', 'eff_discount_rate', 'terminal_growth', 'ronic',
                 'sotp_multiple', 'description'],
    'forecast': ['year', 'volume', 'price', 'revenue', 'cash_cost', 'depreciation', 'interest', 'other_contrib', 'tax_rate', 'payout',
                 'net_borrowing', 'cost_of_debt', 'maint_capex', 'growth_capex', 'operating_status', 'cash_status'],
    'fin_forecast': ['year', 'sub_rev', 'nonsub_rev', 'social_rev', 'revenue', 'gross_margin', 'selling_ratio', 'admin_ratio', 'core_op',
                     'other_income', 'finance_cost', 'np_parent', 'adj_np', 'cfo_ratio', 'capex', 'shareholder_return', 'other_cash', 'note'],
    'trial': ['name', 'start_year', 'end_year', 'base_value', 'trial_value', 'value_change', 'change_pct'],
    'issue': ['code', 'title', 'severity', 'status', 'impact', 'progress'],
    'change_log': ['change_date', 'title', 'target', 'reason', 'verification'],
    'collector': ['name', 'metric', 'parser', 'parser_param', 'enabled', 'health', 'last_collected', 'last_obs_date', 'last_result'],
    'collect_run': ['label', 'trigger_source', 'status', 'requested_at', 'seconds', 'summary'],
    'raw_capture': ['run_label', 'collector', 'collected_at', 'fetch_note', 'status', 'parsed_date', 'parsed_value', 'decision'],
    'projection': ['scenario_name', 'year', 'revenue', 'pretax', 'np_parent', 'dividend', 'dps', 'dividend_pv', 'owner_earnings',
                   'fcfe', 'cash_supported_div', 'funding_gap', 'debt_close'],
    'valuation': ['scenario_name', 'market_price', 'implied_irr', 'cash_implied_irr', 'required_return', 'value_at_required',
                  'value_today', 'price_vs_value', 'watch_low', 'watch_high', 'terminal_share', 'conclusion'],
    'balance': ['scenario_name', 'year', 'op_assets_close', 'lt_invest_close', 'debt_close', 'equity_close', 'minority_close',
                'other_net_assets', 'other_net_change', 'roe', 'debt_to_capital', 'interest_cover', 'debt_to_ebitda'],
    'sensitivity': ['label', 'r', 'g', 'value_today', 'value_base_date'],
    'check': ['code', 'name', 'result', 'detail'],
}
# 公司数据页“定期经营数据”标签的列（自动采集标签用 COLUMNS['observation']）
DISCLOSED_COLUMNS = ['metric', 'period', 'basis', 'value', 'unit', 'yoy', 'summary', 'doc']
SORT = {'observation': [('obs_date', 'desc')], 'raw_capture': [('collected_at', 'desc')], 'collect_run': [('id', 'desc')], 'change_log': [('change_date', 'desc')],
        'key_metric': [('model_order', 'asc'), ('name', 'asc')], 'fit_score': [('sort', 'asc')], 'forecast': [('year', 'asc')],
        'projection': [('id', 'asc')], 'sotp': [('id', 'asc')], 'sotp_item': [('code', 'asc'), ('id', 'asc')], 'sotp_segment': [('code', 'asc'), ('id', 'asc')], 'risk': [('code', 'asc')], 'metric': [('category', 'asc'), ('name', 'asc')], 'balance': [('id', 'asc')], 'valuation': [('id', 'asc')], 'sensitivity': [('id', 'asc')], 'check': [('id', 'asc')]}


def state():
    return json.loads(STATE.read_text()) if STATE.exists() else {'groups': {}, 'pages': {}}


def chunk(title, fields):
    n = (len(fields) + 9) // 10
    return [{'title': title if n == 1 else f'{title}（{i // 10 + 1}/{n}）', 'fields': fields[i:i + 10]}
            for i in range(0, len(fields), 10)]


def grouped(groups):
    groups = [(t, f) for t, f in groups if f]
    if sum(len(f) for _, f in groups) <= 10:
        return {'fields': [x for _, f in groups for x in f]}
    return {'fieldGroups': [g for t, f in groups for g in chunk(t, f)]}


def rel(f):
    return {'field': f['name'], 'titleField': T[f['target']]['title_field']}


def rel_popup(f):
    tgt = T[f['target']]
    shown = [tgt['title_field']] + [x['name'] for x in spec.scalar_fields(tgt) if x['name'] != tgt['title_field']][:5]
    return {'field': f['name'], 'titleField': tgt['title_field'], 'popup': {'title': tgt['title'], 'blocks': [
        {'type': 'details', 'resource': {'binding': 'currentRecord', 'collectionName': f"vi_{f['target']}"}, 'fields': shown}]}}


_META = {}


def live_fields(coll):
    if coll not in _META:
        p = subprocess.run(['nb', 'api', 'data-modeling', 'collections', 'get', '--filter-by-tk', coll, '--appends', 'fields', '-j'],
                           capture_output=True, text=True, cwd=ROOT, check=True)
        _META[coll] = json.loads(p.stdout)['data']['fields']
    return _META[coll]



def default_groups(code):
    """后端生成弹窗（详情/编辑）的集合级字段分组：基本信息 / 关联 / 自动计算 / 系统。"""
    t = T[code]
    live = [f for f in live_fields(f'vi_{code}') if f.get('interface') and f['interface'] not in ('id', 'm2m', 'o2m', 'o2o')]
    if len(live) <= 10:
        return None
    if t.get('groups'):                           # 报表可在 spec 里指定分组
        names = {f['name'] for f in live}
        return grouped([(g, [n for n in fs if n in names]) for g, fs in t['groups']]).get('fieldGroups')
    inputs = {f['name'] for f in t['fields'] if f['kind'] not in ('m2o', 'm2m')}
    rels = {f['name'] for f in live if f['interface'] == 'm2o'}
    calc = {f['name'] for f in t.get('calc', [])}
    names = [f['name'] for f in live]
    fks = {f"{f['name']}_id" for f in spec.m2o_fields(t)} if code in T and 'fields' in t else set()
    g = grouped([('基本信息', [n for n in names if n in inputs]), ('关联', [n for n in names if n in rels]),
                 ('自动计算（只读）', [n for n in names if n in calc]),
                 ('系统', [n for n in names if n not in inputs | rels | calc | fks])])
    return g.get('fieldGroups')


def blueprint(code, page_title, group_route, company=None, scope=None, prefix=None):
    """一个表格页面。company＝{'id','code','name'} 时只显示这家公司的记录（区块数据范围）。"""
    src = 'metric' if code == 'key_metric' else code          # 重点指标是指标表的一个视角
    t = T[src]
    coll = f'vi_{src}'
    report = code in REPORT_CODES
    rels = {f['name']: f for f in t['fields'] if f['kind'] in ('m2o', 'm2m')}
    cols = [rel_popup(rels[c]) if c in rels else c for c in COLUMNS[code]]
    involved = {coll: t['title']} | {f"vi_{f['target']}": T[f['target']]['title'] for f in rels.values()}
    defaults = {'collections': {c: {'popups': {
        'view': {'name': f'{n}·详情', 'description': f'查看一条「{n}」记录'},
        'addNew': {'name': f'{n}·新增', 'description': f'新增一条「{n}」记录'},
        'edit': {'name': f'{n}·编辑', 'description': f'编辑一条「{n}」记录'}}} for c, n in involved.items()}}
    for c in involved:
        fg = default_groups(c[3:])
        if fg:
            defaults['collections'][c]['fieldGroups'] = fg
    # 区块说明栏写这张表的一句话定位（spec.role_line），录入前就能看到；标题留空（默认的“基础表 · …”没有信息）
    settings = {'title': '', 'description': spec.role_line(t), 'pageSize': 50, 'sorting': [{'field': f, 'direction': d} for f, d in SORT.get(code, [('id', 'asc')])]}
    if scope:
        settings['dataScope'] = scope
    elif company and code == 'observation':      # 公司的高频数据＝自己的指标＋用到的宏观数据（vi_company_metric）
        settings['dataScope'] = {'logic': '$or', 'items': [
            {'path': 'metric.company_id', 'operator': '$eq', 'value': company['id']},
            {'path': 'metric.used_by_codes', 'operator': '$includes', 'value': f",{company['code']},"}]}
    elif company and code in ('metric', 'key_metric'):   # 公司的指标＝自己的指标＋用到的宏观指标
        settings['dataScope'] = {'logic': '$or', 'items': [
            {'path': 'company_id', 'operator': '$eq', 'value': company['id']},
            {'path': 'used_by_codes', 'operator': '$includes', 'value': f",{company['code']},"}]}
    elif company:
        settings['dataScope'] = {'logic': '$and', 'items': [{'path': SCOPE[code], 'operator': '$eq', 'value': company['id']}]}
    block = {'key': 'main', 'type': 'table', 'collection': coll, 'fields': cols, 'settings': settings}
    if report:
        block['actions'] = ['filter', 'refresh']
        block['recordActions'] = ['view']
    else:
        inputs = [f['name'] for f in spec.scalar_fields(t)]
        form = grouped([('基本信息', inputs), ('关联', [rel(f) for f in rels.values()])])
        block['actions'] = ['filter', 'refresh', {'type': 'addNew', 'popup': {'title': f'新增 · {page_title}', 'blocks': [
            {'type': 'createForm', 'resource': {'collectionName': coll}, **form, 'actions': ['submit']}]}}, 'bulkDelete']
        block['recordActions'] = ['view', {'type': 'edit', 'popup': {'title': f'编辑 · {page_title}', 'blocks': [
            {'type': 'editForm', **form, 'actions': ['submit']}]}}, 'delete']
    assets = None
    if src == 'metric':                          # 点开指标：趋势、逐期数据、录入一期（metric_detail.py）
        import metric_detail
        block['recordActions'][0] = metric_detail.view_action(page_title)
        assets = metric_detail.ASSETS
    nav = {'group': {'routeId': group_route}, 'item': {'title': page_title, 'icon': 'TableOutlined' if not report else 'FundOutlined'}}
    prefix = prefix or (company['name'] if company else '价值投资框架')
    tabs = [{'title': page_title, 'blocks': [block]}]
    if company and code == 'key_metric':         # 重点指标：模型数据 ｜ 跟踪指标 ｜ 其他指标（这家公司的全部指标都在这一页）
        own = {'path': 'company_id', 'operator': '$eq', 'value': company['id']}
        used = {'logic': '$or', 'items': [own, {'path': 'used_by_codes', 'operator': '$includes', 'value': f",{company['code']},"}]}
        rest = {'logic': '$and', 'items': [used, {'path': 'model_field', 'operator': '$empty', 'value': True},
                {'logic': '$or', 'items': [{'path': 'tracked_codes', 'operator': '$empty', 'value': True},
                                           {'path': 'tracked_codes', 'operator': '$notIncludes', 'value': f",{company['code']},"}]}]}
        model = {'logic': '$and', 'items': [own, {'path': 'model_field', 'operator': '$notEmpty', 'value': True}]}
        tracked = {'logic': '$and', 'items': [{'path': 'tracked_codes', 'operator': '$includes', 'value': f",{company['code']},"}]}
        tabs = [{'title': '模型数据', 'blocks': [dict(block, key='model', settings=dict(settings, dataScope=model,
                    description='财务模型历史一侧用到的数（收入、成本、利润、现金、负债、分红、业务量等），按年汇总给财务模型和自动检查。点开看趋势与逐期数据。'))]},
                {'title': '跟踪指标', 'blocks': [dict(block, key='tracked', settings=dict(settings, dataScope=tracked,
                    description='假设依据的“跟踪指标”、风险的“预警指标”关联到的指标：最新值、是否到期。要盯新的数，在假设依据或风险里关联指标；为什么盯写在指标说明。'))]},
                {'title': '其他指标', 'blocks': [dict(block, key='rest', settings=dict(settings, dataScope=rest,
                    description='没有进模型、也没有被假设依据或风险盯着的指标：分部数据、行情与用到的宏观数据等。新建指标点“添加”；被关联或设了模型字段后会出现在前两个标签。'))]}]
    if company and code == 'observation' and not scope:    # 公司的业务页：定期经营数据 ｜ 高频业务数据
        from data_domains import business_scope, business_description
        auto = business_scope(company, automatic=True)
        disclosed = business_scope(company)
        dcols = [rel_popup(rels[c]) if c in rels else c for c in DISCLOSED_COLUMNS]
        tabs = [{'title': '定期经营数据', 'blocks': [dict(block, key='disclosed', fields=dcols, settings=dict(settings, dataScope=disclosed))]},
                {'title': '高频业务数据', 'blocks': [dict(block, key='auto', settings=dict(settings, dataScope=auto))]}]
        for tab in tabs:
            for entry in tab['blocks']:
                entry['settings']['description'] = business_description(automatic=entry['key'] == 'auto')
    return {'version': '1', 'mode': 'create', 'navigation': nav,
            'page': {'title': page_title, 'documentTitle': f'{prefix} · {page_title}', **({'enableTabs': True} if len(tabs) > 1 else {})},
            'defaults': defaults, 'tabs': tabs, **({'assets': assets} if assets else {})}


def apply(body, name):
    path = HERE / 'blueprints' / f'{name}.json'
    path.parent.mkdir(exist_ok=True)
    path.write_text(json.dumps(body, ensure_ascii=False, indent=1))
    p = subprocess.run(['nb', 'api', 'flow-surfaces', 'apply-blueprint', '--body-file', str(path), '-j'],
                       capture_output=True, text=True, cwd=ROOT)
    return p


def nb_json(*a):
    p = subprocess.run(['nb', 'api', *a, '-j'], capture_output=True, text=True, cwd=ROOT, check=True)
    return json.loads(p.stdout)


def routes():
    return nb_json('resource', 'list', '--resource', 'desktopRoutes:listAccessible', '--no-paginate')['data']


def child_page(group_id, page_title):
    """在指定分组（任意层级）下按标题找页面路由。"""
    def walk(nodes):
        for n in nodes:
            if n.get('id') == group_id:
                return next((c for c in n.get('children') or [] if c.get('title') == page_title and c.get('type') != 'group'), None)
            hit = walk(n.get('children') or [])
            if hit:
                return hit
    return walk(routes())


def find_route(group_title, page_title):
    for g in routes():
        if g.get('type') == 'group' and g.get('title') == group_title:
            for c in g.get('children') or []:
                if c.get('title') == page_title:
                    return g, c
    raise RuntimeError(f'路由未找到：{group_title}/{page_title}')


def companies():
    p = subprocess.run([str(ROOT / 'psql.sh'), '-At', '-c',
                        "SELECT coalesce(json_agg(t ORDER BY t.id), '[]') FROM (SELECT id, code, name FROM vi_company_base) t"],
                       capture_output=True, text=True, check=True)
    return json.loads(p.stdout)


def ensure_group(st, key, title, icon, parent=None):
    """菜单分组（可嵌套）：已建过的从 pages_state.json 取 id；否则新建。写文件前重新读取，避免用旧快照覆盖刚建的页面记录。"""
    cur = state()
    if key in cur['groups']:
        st['groups'][key] = cur['groups'][key]
        return cur['groups'][key]
    uid = ''.join(secrets.choice(string.ascii_lowercase + string.digits) for _ in range(11))
    values = {'type': 'group', 'title': title, 'icon': icon, 'schemaUid': uid}
    if parent:
        values['parentId'] = parent
    gid = nb_json('resource', 'create', '--resource', 'desktopRoutes', '--values', json.dumps(values, ensure_ascii=False))['data']['id']
    cur['groups'][key] = gid
    STATE.write_text(json.dumps(cur, ensure_ascii=False, indent=1))
    st['groups'][key] = gid
    return gid


def page_key(code, company=None):
    return f"{code}@{company['code']}" if company else code


def build(code, page_title, group_route, company=None, key=None, scope=None, prefix=None):
    st = state()
    key = key or page_key(code, company)
    owner = prefix or (company['name'] if company else SHARED)
    if key in st['pages']:
        print(f'{page_title}（{owner}）: 已存在'); return True
    p = apply(blueprint(code, page_title, group_route, company, scope, prefix), key.replace('@', '_'))
    if p.returncode:
        out = p.stdout[p.stdout.find('{'):p.stdout.rfind('}') + 1]
        try:
            for e in json.loads(out).get('errors', []):
                print(' -', e.get('ruleId'), e.get('path'), '|', e.get('message')[:260])
        except Exception:
            print(p.stdout[-2000:], p.stderr[-500:])
        return False
    c = child_page(group_route, page_title)
    st = state()
    st['pages'][key] = {'routeId': c['id'], 'pageSchemaUid': c.get('schemaUid')}
    STATE.write_text(json.dumps(st, ensure_ascii=False, indent=1))
    if code in REPORT_CODES:
        strip_write_actions(key)
    if code == 'fit_score' and company:          # 适配度页面顶部的结论看板（build_fitboard.py）
        import build_fitboard
        build_fitboard.add_board(company)
    print(f'{page_title}（{owner}）: OK')
    return True


def company_root(st, co):
    return ensure_group(st, co['name'], co['name'], COMPANY_ICON.get(co['code'], 'BankOutlined'))


def valuation_group(st, co):
    """“预测与估值”的表格页放在哪个分组：有定制估值页的公司放进组内的“模型底稿”子组。"""
    gid = ensure_group(st, f"{co['name']}/预测与估值", '预测与估值', 'CalculatorOutlined', parent=company_root(st, co))
    if co['code'] in CUSTOM_VALUATION:
        gid = ensure_group(st, f"{co['name']}/预测与估值/{DRAFTS}", DRAFTS, 'FolderOutlined', parent=gid)
    return gid


def page_group(st, co, sub, icon, code=None):
    if sub == '预测与估值' and code != 'key_metric':     # 重点指标不收进模型底稿
        return valuation_group(st, co)
    return ensure_group(st, f"{co['name']}/{sub}", sub, icon, parent=company_root(st, co))


def skipped(code, co):
    if code in REPLACED_BY_CHAINMAP and f"chainmap@{co['code']}" in state()['pages']:
        return True                               # 已由 build_chainmap.py 的“产业链与五力”页面取代
    return code in CUSTOM_VALUATION.get(co['code'], {}).get('skip', ())


def build_company(co):
    st = state()
    for sub, icon, pages in COMPANY_MENU:
        for code, title in pages:
            if skipped(code, co):
                continue
            if not build(code, title, page_group(st, co, sub, icon, code), co):
                return False
    return True


def shared_root(st):
    return ensure_group(st, SHARED, SHARED, 'SettingOutlined')


def build_shared():
    st = state()
    root = shared_root(st)
    for code, title in SHARED_MENU:
        if not build(code, title, root):
            return False
    sub, icon, pages = SHARED_SUB
    gid = ensure_group(st, f'{SHARED}/{sub}', sub, icon, parent=root)
    for code, title in pages:
        if not build(code, title, gid):
            return False
    return True


def build_macro():
    """宏观数据项目：顶层菜单，只显示归属为“宏观”的指标、高频数据与采集配置（页面键：表代码@macro）。"""
    import register
    st = state()
    title, icon, pages = MACRO
    todo = [c for c, _ in pages if f'{c}@macro' not in st['pages']]
    involved = set(todo) | {f['target'] for c in todo for f in T[c]['fields'] if f['kind'] in ('m2o', 'm2m')}
    if todo:
        register.describe(involved, clear=True)     # 生成页面时先清空字段说明（UI 生成器会把说明当作表单行为指令），建完再写回
    root = ensure_group(st, title, title, icon)
    for code, page_title in pages:
        scope = {'logic': '$and', 'items': [{'path': MACRO_SCOPE[code], 'operator': '$eq', 'value': '宏观'}]}
        if not build(code, page_title, root, key=f'{code}@macro', scope=scope, prefix=title):
            return False
    if todo:
        register.describe(involved)
    return True


WRITE_ACTIONS = {'AddNewActionModel', 'BulkDeleteActionModel', 'DeleteActionModel', 'EditActionModel'}


def page_tree(key):
    uid = state()['pages'][key]['pageSchemaUid']
    p = subprocess.run(['nb', 'api', 'flow-surfaces', 'get', '--page-schema-uid', uid, '-j'],
                       capture_output=True, text=True, cwd=ROOT, check=True)
    return json.loads(p.stdout)['data']


@contextmanager
def no_field_desc(codes):
    """UI 生成器会把字段说明当作表单行为指令：生成页面时先清空这些表（及其关联表）的字段说明，结束后写回。"""
    import register
    involved = set(codes) | {f['target'] for c in codes for f in T[c]['fields'] if f['kind'] in ('m2o', 'm2m')}
    register.describe(involved, clear=True)
    try:
        yield
    finally:
        register.describe(involved)


def order_tabs(key, titles):
    """按 titles 的顺序排页面里的标签：apply-blueprint replace 之后，几个标签的 sort 可能相同，先后不定。"""
    rid = state()['pages'][key]['routeId']
    def find(nodes):
        for n in nodes:
            if n['id'] == rid:
                return n
            hit = find(n.get('children') or [])
            if hit:
                return hit
    uid = {c['title']: c['schemaUid'] for c in find(routes()).get('children') or []}
    for a, b in zip(titles, titles[1:]):
        nb_json('flow-surfaces', 'move-tab', '--source-uid', uid[b], '--target-uid', uid[a], '--position', 'after')


def describe_pages():
    """已建页面重写区块说明（spec.role_line）：改了表的定位或关联之后执行。新页面由 blueprint() 直接带上。"""
    for key in state()['pages']:
        t = T.get(key.split('@')[0])
        if not t:
            continue
        uid = next(b['uid'] for b in blocks(page_tree(key)['tree']) if b.get('use') == 'TableBlockModel')
        nb_json('flow-surfaces', 'configure', '--target', json.dumps({'uid': uid}),
                '--changes', json.dumps({'title': '', 'description': spec.role_line(t)}, ensure_ascii=False))
        print(key, '说明 OK')


def blocks(x):
    if isinstance(x, dict):
        if x.get('use', '').endswith('BlockModel'):
            yield x
        for v in x.values():
            yield from blocks(v)
    elif isinstance(x, list):
        for v in x:
            yield from blocks(v)


def strip_write_actions(key):
    """只读报表：applyBlueprint 会自动补上新增/编辑/删除按钮，生成后逐个移除。"""
    found = []

    def walk(x):
        if isinstance(x, dict):
            if x.get('use') in WRITE_ACTIONS:
                found.append(x['uid'])
            for v in x.values():
                walk(v)
        elif isinstance(x, list):
            for v in x:
                walk(v)
    walk(page_tree(key)['tree'])
    for uid in dict.fromkeys(found):
        subprocess.run(['nb', 'api', 'flow-surfaces', 'remove-node', '--body', json.dumps({'target': {'uid': uid}}), '-j'],
                       capture_output=True, text=True, cwd=ROOT, check=True)
    return len(found)


def drop_templates(collection):
    """删除某集合未被引用的弹窗模板（页面删掉之后才能删）。"""
    def fs(*a, body=None):
        return subprocess.run(['nb', 'api', 'flow-surfaces', *a, '-j'] + (['--body', json.dumps(body)] if body is not None else []),
                              capture_output=True, text=True, cwd=ROOT)
    for _ in range(3):
        d = json.loads(fs('list-templates', body={'pageSize': 500}).stdout)['data']
        rows = [t for t in (d.get('rows', d) if isinstance(d, dict) else d) if t.get('collectionName') == collection]
        if not rows:
            return
        for t in rows:
            fs('destroy-template', body={'uid': t['uid']})


def destroy_page(key):
    st = state()
    if key in st['pages']:
        uid = page_tree(key)['target']['uid']
        subprocess.run(['nb', 'api', 'flow-surfaces', 'destroy-page', '--uid', uid, '-j'], capture_output=True, text=True,
                       cwd=ROOT, check=True)
        st = state()
        del st['pages'][key]
        STATE.write_text(json.dumps(st, ensure_ascii=False, indent=1))


def rebuild(code, company_code=None):
    """删除并重建一个表格页面（所有公司的同名页面一起重建，弹窗模板才会更新）。"""
    import register
    cos = [c for c in companies() if not company_code or c['code'] == company_code]
    keys = [page_key(code, c) for c in cos] + ([code] if not company_code else [])
    for k in keys:
        destroy_page(k)
    drop_templates(f'vi_{code}')                   # 否则会复用旧的弹窗模板，新字段不出现
    involved = {code} | {f['target'] for f in T[code]['fields'] if f['kind'] in ('m2o', 'm2m')}
    register.describe(involved, clear=True)       # UI 生成器会把字段说明当作表单行为指令，生成时先清空
    st = state()
    ok = True
    for co in cos:
        for sub, icon, pages in COMPANY_MENU:
            for c, title in pages:
                if c == code and not skipped(c, co):
                    ok &= build(c, title, page_group(st, co, sub, icon, c), co)
    if not company_code:
        for c, title in SHARED_MENU:
            if c == code:
                ok &= build(c, title, shared_root(st))
        for c, title in SHARED_SUB[2]:
            if c == code:
                ok &= build(c, title, ensure_group(st, f'{SHARED}/{SHARED_SUB[0]}', SHARED_SUB[0], SHARED_SUB[1], parent=shared_root(st)))
    register.describe(involved)
    import scope_selects
    scope_selects.main()                          # 新模板里的关联下拉补上“只列这家公司”的数据范围
    return ok


COMPANY_TOP = ['驾驶舱'] + [g for g, _, _ in COMPANY_MENU]
SHARED_ORDER = ['使用说明', '数据结构', '模型公式'] + [t for _, t in SHARED_MENU] + [SHARED_SUB[0]]


def sort_menu(company_codes=None):
    """顶层：各公司（按公司 id），最后是“框架与后台”；公司内：驾驶舱、商业模式、预测与估值、数据底稿、研究维护，分组内按菜单定义（预测与估值组内财务模型在最前）。"""
    current_routes = routes()
    current_sort = {}
    def index_sorts(nodes):
        for n in nodes:
            current_sort[n['id']] = n.get('sort')
            index_sorts(n.get('children') or [])
    index_sorts(current_routes)
    def upd(rid, sort):
        if current_sort.get(rid) == sort:
            return
        nb_json('resource', 'update', '--resource', 'desktopRoutes', '--filter-by-tk', str(rid), '--values', json.dumps({'sort': sort}))
    names = [c['name'] for c in companies()]
    sub_order = {g: [t for _, t in pages] for g, _, pages in COMPANY_MENU} | {SHARED_SUB[0]: [t for _, t in SHARED_SUB[2]]}
    # 可视化页不在 COMPANY_MENU 里：财务数据（build_finstmt.py，季度三大报表）在数据底稿里跟在数据后面；
    # 财务模型（build_finmodel.py）在预测与估值表格页前；定制估值页（build_valuation.py）在最前，模型底稿子组在最后
    sub_order['数据底稿'] = ['业务数据', '财务数据'] + [t for t in sub_order['数据底稿'] if t not in ('业务数据', '财务数据')]
    sub_order['预测与估值'] = ['重点指标', '财务模型', '估值'] + [t for t in sub_order['预测与估值'] if t != '重点指标'] + [DRAFTS]
    sub_order[DRAFTS] = sub_order['预测与估值']
    for g in current_routes:
        top = g['title']
        if company_codes is not None and top not in [c['name'] for c in companies() if c['code'] in company_codes]:
            continue
        gi = names.index(top) + 1 if top in names else (80 if top == MACRO[0] else 90 if top == SHARED else 99)
        upd(g['id'], gi * 1000)
        order = COMPANY_TOP if top in names else SHARED_ORDER if top == SHARED else [t for _, t in MACRO[2]] if top == MACRO[0] else []
        for c in g.get('children') or []:
            k = order.index(c['title']) if c['title'] in order else 99
            upd(c['id'], gi * 1000 + (k + 1) * 10)
            if c.get('type') != 'group':
                continue                       # 页面下的是标签，不属于菜单排序
            inner = sub_order.get(c['title'], []) if c.get('type') == 'group' else []
            for cc in c.get('children') or []:
                kk = inner.index(cc['title']) if cc['title'] in inner else 99
                upd(cc['id'], kk + 1)
                if cc.get('type') != 'group':
                    continue                   # 保留可视化 → 编辑的标签顺序
                deeper = sub_order.get(cc['title'], []) if cc.get('type') == 'group' else []
                for ccc in cc.get('children') or []:
                    upd(ccc['id'], (deeper.index(ccc['title']) if ccc['title'] in deeper else 99) + 1)
    # 菜单行尾的“?”帮助图标来自 tooltip 的自动样板文案（“基础数据表｜…”之类），在窄侧边栏里会被裁掉半截；
    # 统一清掉保持排版干净（页面类型说明在使用说明页里）。新建页面会重新带上，重跑 sort_menu 即可。
    def strip_tooltip(nodes):
        for n in nodes:
            if n.get('tooltip'):
                nb_json('resource', 'update', '--resource', 'desktopRoutes', '--filter-by-tk', str(n['id']),
                        '--values', json.dumps({'tooltip': None}))
            strip_tooltip(n.get('children') or [])
    strip_tooltip([r for r in routes() if company_codes is None or r['title'] in [c['name'] for c in companies() if c['code'] in company_codes]])


if __name__ == '__main__':
    # python3 build_pages.py                 共用页面＋所有公司
    # python3 build_pages.py 002078.SZ       只建这家公司的页面（新公司加入后执行）
    # python3 build_pages.py --describe      已建页面重写区块说明（表的一句话定位，spec.role_line）
    if '--describe' in sys.argv:
        describe_pages(); sys.exit()
    want = set(sys.argv[1:])
    if not want and not (build_shared() and build_macro()):
        sys.exit(1)
    for co in companies():
        if (not want or co['code'] in want) and not build_company(co):
            sys.exit(1)
    import scope_selects
    scope_selects.main()
