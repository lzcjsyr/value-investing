"""自动采集工作流（通用，全部创建为“停用”，确认后在 设置→工作流 里启用）：
  ① 采集  每天 18:30：遍历“采集配置”中启用的数据源 → 新建原始记录（采集中）→ HTTP GET → 写回原始响应（待入库）
  ② 入库  每天 18:40：一条 SQL 把“可入库”的原始记录写入高频数据，并回写处理状态
  ③ 自检  每天 19:10：回写最近自检/自检结果 → 统计需要处理的数据源 → 有则发站内信
  ④ 手动  驾驶舱按钮新增一条“采集运行”（带公司）即触发：只采这家公司和通用指标（vi_collect_targets），再入库、自检
解析、校验、去重全部在 SQL 视图 vi_raw_capture_calc 中完成。新增数据源只需在“采集配置”加一行。
"""
import json, subprocess, pathlib

HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parent
STATE = HERE / 'workflows_state.json'
DAY = '2026-10-22T{}:00.000+08:00'

REFERER = 'https://finance.sina.com.cn/'
UA = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0 Safari/537.36'
INGEST_SQL = 'SELECT * FROM vi_ingest()'          # 逻辑在 sql/02_calc.sql，改逻辑不用改工作流
TARGETS_SQL = 'SELECT * FROM vi_collect_targets(:run_id)'   # ④ 本次要采的数据源：运行有公司时只采这家公司和通用指标
SELFCHECK_SQL = 'SELECT * FROM vi_selfcheck()'


def sql_config(sql):
    return {'dataSource': 'main', 'sql': sql, 'variables': [], 'withMeta': False}


def begin_config(item, run=None):
    values = {'collector_id': f'{{{{{item}.id}}}}', 'run_label': f'{{{{{item}.name}}}}｜{{{{$context.date}}}}',
              'collected_at': '{{$context.date}}', 'status': '采集中'}
    if run:   # ④ 手动采集：触发记录是“采集运行”，用它的 id 关联；采集时间取当前时间
        values.update({'run_id': f'{{{{{run}.id}}}}', 'run_label': f'{{{{{item}.name}}}}｜手动', 'collected_at': '{{$system.now}}'})
    return {'collection': 'vi_raw_capture', 'usingAssignFormSchema': False, 'params': {'values': values}}


def targets_config():
    return {**sql_config(TARGETS_SQL), 'variables': [{'name': 'run_id', 'value': '{{$context.data.id}}'}]}


def loop_config(source_key):
    return {'target': f"{{{{$jobsMapByNodeKey.{source_key}}}}}", 'exit': 2}


def run_status(status):
    return {'collection': 'vi_collect_run', 'usingAssignFormSchema': False,
            'params': {'individualHooks': False, 'filter': {'$and': [{'id': {'$eq': '{{$context.data.id}}'}}]},
                       'values': {'status': status}}}


def http_config(item):
    # Referer：新浪行情（纸浆期货）不带就返回 403；腾讯、中债、长江水文网带上也正常（2026-10-22 实测）
    return {'method': 'GET', 'url': f'{{{{{item}.url}}}}', 'timeout': 20000, 'ignoreFail': True, 'onlyData': False,
            'headers': [{'name': 'User-Agent', 'value': UA}, {'name': 'Referer', 'value': REFERER}], 'params': []}


def save_config(begin_key, http_key):
    """写回原始响应和抓取结果：成功时为“HTTP 200 …”，失败时为状态码或连接错误原文（vi_raw_capture_calc 据此判断抓取失败）。"""
    h = f'$jobsMapByNodeKey.{http_key}'
    return {'collection': 'vi_raw_capture', 'usingAssignFormSchema': False,
            'params': {'individualHooks': False,
                       'filter': {'$and': [{'id': {'$eq': f"{{{{$jobsMapByNodeKey.{begin_key}.id}}}}"}}]},
                       'values': {'raw_response': f'{{{{{h}.data}}}}',
                                  'fetch_result': f'HTTP {{{{{h}.status}}}} {{{{{h}.code}}}} {{{{{h}.message}}}}',
                                  'status': '待入库'}}}


def notice_text(count_key):
    return f"有 {{{{$jobsMapByNodeKey.{count_key}}}}} 个数据源需要处理，请查看「框架与后台 / 采集 / 采集配置」与工作流执行记录。"


def notice_config(count_key):
    return {'channelName': 'in-app-message', 'ignoreFail': True, 'title': '自动采集异常', 'content': notice_text(count_key),
            'receivers': [1], 'options': {}}


def desired(name, keys):
    """可以原地升级的节点配置（按节点 key）。"""
    if name == 'collect':
        q, loop, begin, http, save = keys
        return {http: http_config(f'$scopes.{loop}.item'), save: save_config(begin, http)}
    if name == 'manual':
        mark, q, loop, begin, http, save, ing, chk, done = keys
        item = f'$scopes.{loop}.item'
        return {q: targets_config(), loop: loop_config(q),
                begin: begin_config(item, '$context.data'), http: http_config(item), save: save_config(begin, http),
                ing: sql_config(INGEST_SQL), chk: sql_config(SELFCHECK_SQL)}
    if name == 'ingest':
        return {keys[0]: sql_config(INGEST_SQL)}
    return {keys[0]: sql_config(SELFCHECK_SQL), keys[3]: notice_config(keys[1])}


def nb(*args, body=None):
    cmd = ['nb', 'api', 'workflow', *args, '-j'] + (['--body', json.dumps(body, ensure_ascii=False)] if body is not None else [])
    p = subprocess.run(cmd, capture_output=True, text=True, cwd=ROOT)
    if p.returncode:
        raise RuntimeError(f'{args}\n{p.stdout[-1500:]}\n{p.stderr[-500:]}')
    return json.loads(p.stdout)['data']


def workflow(title, hhmm, description):
    h, m = hhmm.split(':')
    return nb('workflows', 'create', body={'title': title, 'type': 'schedule', 'enabled': False, 'sync': False,
                                           'description': description,
                                           'config': {'mode': 0, 'startsOn': DAY.format(hhmm), 'repeat': f'0 {int(m)} {int(h)} * * *'}})


def node(wf, ntype, title, config, upstream=None, branch=None):
    body = {'type': ntype, 'title': title, 'config': config, 'upstreamId': upstream}
    if branch is not None:
        body['branchIndex'] = branch
    return nb('workflows', 'nodes', 'create', '--workflow-id', str(wf['id']), body=body)


def build():
    st = {}
    wf = workflow('① 采集 · 所有启用的数据源', '18:30', '遍历“采集配置”中启用的数据源，抓取原始响应写入“原始采集记录”')
    q = node(wf, 'query', '读取启用的采集配置', {
        'collection': 'vi_collector', 'multiple': True, 'failOnEmpty': False,
        'params': {'filter': {'$and': [{'enabled': {'$isTruly': True}}]}, 'sort': [{'field': 'id', 'direction': 'asc'}],
                   'pageSize': 100, 'appends': []}})
    loop = node(wf, 'loop', '逐个数据源', {'target': f"{{{{$jobsMapByNodeKey.{q['key']}}}}}", 'exit': 2}, upstream=q['id'])
    item = f"$scopes.{loop['key']}.item"
    begin = node(wf, 'create', '新建原始记录（采集中）', begin_config(item), upstream=loop['id'], branch=0)
    http = node(wf, 'request', 'HTTP GET 数据源', http_config(item), upstream=begin['id'])
    save = node(wf, 'update', '写回原始响应（待入库）', save_config(begin['key'], http['key']), upstream=http['id'])
    st['collect'] = {'id': wf['id'], 'key': wf['key'], 'nodes': [q['key'], loop['key'], begin['key'], http['key'], save['key']]}

    wf = workflow('② 入库 · 校验去重写入高频数据', '18:40', '“可入库”的原始记录写入高频数据，并回写处理状态（已入库/重复未入库/校验失败）')
    ing = node(wf, 'sql', '校验去重入库并回写状态', sql_config(INGEST_SQL))
    st['ingest'] = {'id': wf['id'], 'key': wf['key'], 'nodes': [ing['key']]}

    wf = workflow('③ 自检 · 采集健康检查', '19:10', '回写最近自检/自检结果；有需要处理的数据源时发站内信')
    chk = node(wf, 'sql', '回写最近自检与自检结果', sql_config(SELFCHECK_SQL))
    cnt = node(wf, 'aggregate', '统计需要处理的数据源', {
        'aggregator': 'count', 'associated': False, 'collection': 'vi_collector', 'precision': 0,
        'params': {'field': 'id', 'filter': {'$and': [{'needs_alert': {'$isTruly': True}}]}, 'distinct': False}}, upstream=chk['id'])
    cond = node(wf, 'condition', '有异常？', {
        'rejectOnFalse': False, 'engine': 'basic',
        'calculation': {'group': {'type': 'and', 'calculations': [
            {'calculator': 'gt', 'operands': [f"{{{{$jobsMapByNodeKey.{cnt['key']}}}}}", 0]}]}}}, upstream=cnt['id'])
    note = node(wf, 'notification', '站内信提醒', {
        'channelName': 'in-app-message', 'ignoreFail': True, 'title': '自动采集异常',
        'content': notice_text(cnt['key']),
        'receivers': [1], 'options': {}}, upstream=cond['id'], branch=1)
    st['selfcheck'] = {'id': wf['id'], 'key': wf['key'], 'nodes': [chk['key'], cnt['key'], cond['key'], note['key']]}
    STATE.write_text(json.dumps(st, ensure_ascii=False, indent=1))
    return st


def manual():
    """④ 手动采集：“采集运行”表新增一行即触发（驾驶舱的“立即采集一次”按钮就是新增一行），一次跑完 采集→入库→自检。"""
    st = json.loads(STATE.read_text())
    if 'manual' in st:
        return st['manual']
    wf = nb('workflows', 'create', body={'title': '④ 手动采集 · 按钮触发（采集→入库→自检）', 'type': 'collection', 'enabled': False,
                                         'sync': False, 'description': '驾驶舱“立即采集一次”新增一条采集运行即触发；结果按本次原始记录统计',
                                         'config': {'collection': 'vi_collect_run', 'mode': 1, 'changed': [],
                                                    'condition': {'$and': []}, 'appends': []}})
    mark = node(wf, 'update', '标记运行中', run_status('运行中'))
    q = node(wf, 'sql', '本次要采的数据源（这家公司＋通用指标）', targets_config(), upstream=mark['id'])
    loop = node(wf, 'loop', '逐个数据源', loop_config(q['key']), upstream=q['id'])
    item = f"$scopes.{loop['key']}.item"
    begin = node(wf, 'create', '新建原始记录（采集中）', begin_config(item, '$context.data'), upstream=loop['id'], branch=0)
    http = node(wf, 'request', 'HTTP GET 数据源', http_config(item), upstream=begin['id'])
    save = node(wf, 'update', '写回原始响应（待入库）', save_config(begin['key'], http['key']), upstream=http['id'])
    ing = node(wf, 'sql', '校验去重入库并回写状态', sql_config(INGEST_SQL), upstream=loop['id'])
    chk = node(wf, 'sql', '回写最近自检与自检结果', sql_config(SELFCHECK_SQL), upstream=ing['id'])
    done = node(wf, 'update', '标记完成', run_status('完成'), upstream=chk['id'])
    st['manual'] = {'id': wf['id'], 'key': wf['key'],
                    'nodes': [n['key'] for n in (mark, q, loop, begin, http, save, ing, chk, done)]}
    STATE.write_text(json.dumps(st, ensure_ascii=False, indent=1))
    return st['manual']


def upgrade():
    """把已创建的工作流升级到当前配置：执行过的版本不能改，先建同 key 新版本（设为当前），再改节点。"""
    st = json.loads(STATE.read_text())
    for name, info in st.items():
        wf = nb('workflows', 'get', '--filter-by-tk', str(info['id']), '--appends', 'nodes', '--appends', 'versionStats')
        if (wf.get('versionStats') or {}).get('executed', 0) > 0:
            new = nb('workflows', 'revision', '--filter-by-tk', str(wf['id']), '--filter', json.dumps({'key': wf['key']}),
                     body={'current': True})
            wf = nb('workflows', 'get', '--filter-by-tk', str(new['id']), '--appends', 'nodes')
            print(f"{wf['title']}: 已执行过，新建版本 {wf['id']}")
        by_key = {n['key']: n for n in wf['nodes']}
        if name == 'manual' and by_key[info['nodes'][1]]['type'] == 'query':
            # 2026-10-23：“读取启用的采集配置”(查询全部) 换成 SQL 节点 vi_collect_targets(本次运行)，按公司筛选
            old = by_key.pop(info['nodes'][1])
            new_node = node(wf, 'sql', '本次要采的数据源（这家公司＋通用指标）', targets_config(), upstream=old['upstreamId'])
            nb('flow-nodes', 'destroy', '--filter-by-tk', str(old['id']))
            info['nodes'][1] = new_node['key']
            by_key[new_node['key']] = new_node
            print(f"{wf['title']}: 读取数据源改为按公司筛选")
        for key, config in desired(name, info['nodes']).items():
            nb('flow-nodes', 'update', '--filter-by-tk', str(by_key[key]['id']), body={'config': config})
        info['id'] = wf['id']
        print(f"{wf['title']}: 节点已更新")
    STATE.write_text(json.dumps(st, ensure_ascii=False, indent=1))


if __name__ == '__main__':
    import sys
    if '--upgrade' in sys.argv:
        upgrade()
    elif '--manual' in sys.argv:
        print(json.dumps(manual(), ensure_ascii=False, indent=1))
    elif STATE.exists():
        raise SystemExit('workflows_state.json 已存在：工作流已创建（升级到当前配置用 --upgrade）')
    else:
        build()
        print(json.dumps(manual(), ensure_ascii=False, indent=1))
