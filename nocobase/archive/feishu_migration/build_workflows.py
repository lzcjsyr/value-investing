"""在 NocoBase 中复刻飞书的采集 → 入库 → 自检流程（全部创建为“停用”，确认后再启用）。

飞书原有 9 条（3 采集 + 3 入库 + 3 自检），这里合并为 5 条：
  采集 × 3（每天 18:30）：新建原始记录(采集中) → HTTP GET → 写回原始响应(已抓取待校验)
  入库 × 1（每天 18:40）：一条 SQL 把所有“允许入库=1”的原始记录写入市场数据，并按飞书三种结果回写处理状态
  自检 × 1（每天 19:10）：回写最近自检/自检结果 → 统计“异常需通知” → 有异常则发站内信
解析与校验仍由 SQL 视图完成（与飞书公式逐格一致），工作流只搬运数据。
"""
import json, subprocess, pathlib

HERE = pathlib.Path(__file__).resolve().parent
STATE = HERE / 'workflows_state.json'

SOURCES = [
    ('TENCENT-600900', '长江电力股价', 'https://qt.gtimg.cn/q=sh600900', '元'),
    ('CHINABOND-CGB10Y', '中债国债10年收益率', 'https://yield.chinabond.com.cn/cbweb-pbc-web/pbc/more?locale=cn_zh', '%'),
    ('CJH-SX-LEVEL', '三峡库水位', 'http://www.cjh.com.cn/sqindex.html', '米'),
]
DAY = '2026-10-21T{}:00.000+08:00'

INGEST_SQL = """WITH c AS (
  SELECT r.id, r.metric_code, r.unit, r.source_url,
         k.obs_key_v2, k.date_v2, k.value_v2, k.collected_at_text, k.valid_v2, k.allow_ingest
  FROM cj_collect_raw_base r JOIN cj_collect_raw_calc k ON k.id = r.id
  WHERE r.process_status = '已抓取待校验'
), ins AS (
  INSERT INTO cj_market_obs_base (obs_id, metric_code, metric, obs_date, cloud_value_text, unit, source,
                                  collected_at, raw_file, usage_boundary)
  SELECT obs_key_v2, metric_code,
         CASE metric_code WHEN 'TENCENT-600900' THEN '长江电力股价'
                          WHEN 'CHINABOND-CGB10Y' THEN '中债国债10年收益率'
                          WHEN 'CJH-SX-LEVEL' THEN '三峡库水位' END,
         date_v2, value_v2, unit, source_url, collected_at_text,
         'NocoBase 4.2 采集原始记录 #' || CAST(id AS text),
         '本机 NocoBase 采集；通过基础解析与范围校验，非财务核验；不得自动改变估值假设。'
  FROM c WHERE allow_ingest = 1
  RETURNING obs_id
)
UPDATE cj_collect_raw_base r
SET process_status = CASE WHEN c.valid_v2 <> 1 THEN '异常：校验未通过'
                          WHEN c.allow_ingest = 1 THEN '完成（新增或已去重）'
                          ELSE '完成（重复观察未新增）' END
FROM c WHERE r.id = c.id
RETURNING r.id, r.metric_code, r.process_status"""

SELFCHECK_SQL = """UPDATE cj_collect_ctl_base b
SET last_selfcheck = now(),
    selfcheck_result = CASE WHEN c.health_status = '正常' THEN '正常；未通知' ELSE '异常；已通知' END
FROM cj_collect_ctl_calc c
WHERE c.id = b.id AND b.integration_status = '云端已接入'
RETURNING b.metric_code, c.health_status"""


def nb(*args, body=None):
    cmd = ['nb', 'api', 'workflow', *args, '-j']
    if body is not None:
        cmd += ['--body', json.dumps(body, ensure_ascii=False)]
    p = subprocess.run(cmd, capture_output=True, text=True, cwd=HERE.parent)
    if p.returncode:
        raise RuntimeError(f'{args}\n{p.stdout[-2000:]}\n{p.stderr[-1000:]}')
    return json.loads(p.stdout)['data']


def workflow(title, hhmm, description):
    return nb('workflows', 'create', body={
        'title': title, 'type': 'schedule', 'enabled': False, 'sync': False, 'description': description,
        'config': {'mode': 0, 'startsOn': DAY.format(hhmm), 'repeat': f'0 {int(hhmm[3:])} {int(hhmm[:2])} * * *'},
    })


def node(wf, ntype, title, config, upstream=None, branch=None):
    body = {'type': ntype, 'title': title, 'config': config, 'upstreamId': upstream}
    if branch is not None:
        body['branchIndex'] = branch
    return nb('workflows', 'nodes', 'create', '--workflow-id', str(wf['id']), body=body)


def build():
    state = {}
    for code, name, url, unit in SOURCES:
        wf = workflow(f'① 采集 · {name}', '18:30', f'每天 18:30 抓取 {url}，原始响应写入 4.2 采集原始记录')
        begin = node(wf, 'create', '新建原始记录（采集中）', {
            'collection': 'cj_collect_raw', 'usingAssignFormSchema': False,
            'params': {'values': {'run_id': f'{code}|{{{{$context.date}}}}', 'metric_code': code,
                                  'source_url': url, 'unit': unit, 'collected_at': '{{$context.date}}',
                                  'process_status': '采集中'}}})
        http = node(wf, 'request', 'HTTP GET 数据源', {
            'method': 'GET', 'url': url, 'timeout': 15000, 'ignoreFail': False, 'onlyData': False,
            'headers': [], 'params': []}, upstream=begin['id'])
        save = node(wf, 'update', '写回原始响应（已抓取待校验）', {
            'collection': 'cj_collect_raw', 'usingAssignFormSchema': False,
            'params': {'individualHooks': False,
                       'filter': {'$and': [{'id': {'$eq': f"{{{{$jobsMapByNodeKey.{begin['key']}.id}}}}"}}]},
                       'values': {'raw_response': f"{{{{$jobsMapByNodeKey.{http['key']}.data}}}}",
                                  'process_status': '已抓取待校验'}}}, upstream=http['id'])
        state[f'collect_{code}'] = {'id': wf['id'], 'key': wf['key'], 'nodes': [begin['key'], http['key'], save['key']]}

    wf = workflow('② 入库 · 校验去重写入市场数据', '18:40', '每天 18:40：允许入库=1 的原始记录写入 3.2 市场数据，并回写处理状态')
    ing = node(wf, 'sql', '校验去重入库并回写状态', {'dataSource': 'main', 'sql': INGEST_SQL, 'variables': [], 'withMeta': False})
    state['ingest'] = {'id': wf['id'], 'key': wf['key'], 'nodes': [ing['key']]}

    wf = workflow('③ 自检 · 采集健康检查', '19:10', '每天 19:10：回写自检结果；已接入来源异常时发站内信')
    chk = node(wf, 'sql', '回写最近自检与自检结果', {'dataSource': 'main', 'sql': SELFCHECK_SQL, 'variables': [], 'withMeta': False})
    cnt = node(wf, 'aggregate', '统计异常需通知', {
        'aggregator': 'count', 'associated': False, 'collection': 'cj_collect_ctl', 'precision': 0,
        'params': {'field': 'id', 'filter': {'$and': [{'needs_alert': {'$eq': 1}}]}, 'distinct': False}}, upstream=chk['id'])
    cond = node(wf, 'condition', '有异常？', {
        'rejectOnFalse': False, 'engine': 'basic',
        'calculation': {'group': {'type': 'and', 'calculations': [
            {'calculator': 'gt', 'operands': [f"{{{{$jobsMapByNodeKey.{cnt['key']}}}}}", 0]}]}}}, upstream=cnt['id'])
    note = node(wf, 'notification', '站内信提醒', {
        'channelName': 'in-app-message', 'ignoreFail': True,
        'title': '长江电力采集异常',
        'content': f"有 {{{{$jobsMapByNodeKey.{cnt['key']}}}}} 个已接入来源健康状态异常，请查看「4 后台 / 4.1 采集状态」与工作流执行记录。",
        'receivers': [1], 'options': {}}, upstream=cond['id'], branch=1)
    state['selfcheck'] = {'id': wf['id'], 'key': wf['key'], 'nodes': [chk['key'], cnt['key'], cond['key'], note['key']]}
    STATE.write_text(json.dumps(state, ensure_ascii=False, indent=1))
    return state


if __name__ == '__main__':
    if STATE.exists():
        raise SystemExit('workflows_state.json 已存在：工作流已创建，避免重复创建')
    print(json.dumps(build(), ensure_ascii=False, indent=1))
