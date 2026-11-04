"""种子用：写入一家公司的“关注”与数据底稿补充（companies/<公司>/data/data_layer.json），按业务键定位，可重复执行。

data_layer.json 记录 2026-10-26 几次重构的结果，由 framework/migrate_*.py 写入（数据底稿四样东西、指标与数据、历史年度与资产项目）：
  new_metrics       数据里还没有、要先建的指标
  stmt_metrics      与三大报表重复的指标：改为报表计算（写公式、删掉另存的数）
  main_basis        合并后的主口径；basis_fix  口径记错的指标（连同每期数据一起改）
  metric_updates    指标的跟踪用途（说明）、数据来源、频率
  judgment_metrics  假设依据 → 跟踪指标        risk_metrics  风险 → 预警指标
  text              研究正文的改写（原跟踪事项编号换成名称、补写的“持续跟踪：…”），整段覆盖
  facts             定性事实（原“重要事实”）的备注
  new_stmt          资产项目要引用、数据里还没有的报表计算指标
  history           历史年度每列对应的指标（报表公式或披露）与需要录入的年份值（追溯调整值、报表外的数；值为空＝该年明确不取报表值）
  assets            资产估值与调整：引用指标的项目（按编号＋情景）
  merge_metrics     同一序列被拆成两个指标的：并入保留的那个（按系数换算单位）后删除
  year_notes        原历史年度的年度备注，写成定性事实（“<年> 年度数据口径与说明”；腾讯音乐已并入来源文档）
  company           公司表补充字段（如口径变化年份）
  measure           指标性质：{"时点": [指标名称…], "时期": "其余"}——列出的是时点指标，其余为时期指标；最后执行（口径都写完之后，口径须与性质一致）
报表原值（data/fin_stmt.json）由 fin_stmt_statements() 写入，放在最前。
指标按 名称＋单位＋归属（公司或宏观）定位（一个指标一行，口径记在每期数据上）。放在种子最后执行（指标、假设依据、事实都写完之后）。
"""
import json


def lit(v):
    return 'NULL' if v is None else "'" + str(v).replace("'", "''") + "'"


def metric(co, m):
    owner = 'company_id IS NULL' if m.get('macro') else f'company_id = {co}'
    return (f"(SELECT id FROM vi_metric_base WHERE {owner} AND name = {lit(m['name'])} "
            f"AND unit IS NOT DISTINCT FROM {lit(m.get('unit'))} ORDER BY id LIMIT 1)")


def fin_stmt_statements(co, path):
    """三大报表原值（tools/fin_stmt.py 的快照）：先删后写，一条语句写完（报表缓存只刷新一次）。"""
    rows = json.loads(path.read_text())['rows']
    vals = ',\n'.join(f"({co}, {lit(r['period'])}, {lit(r['period_end'])}, {lit(r['stmt'])}, {lit(r['item'])}, "
                      f"{r['seq'] if r.get('seq') is not None else 'NULL'}, {repr(r['amount']) if r.get('amount') is not None else 'NULL'})" for r in rows)
    return [f'DELETE FROM vi_fin_stmt_base WHERE company_id = {co};',
            f'INSERT INTO vi_fin_stmt_base (company_id, period, period_end, stmt, item, seq, amount) VALUES\n{vals};']


def statements(co, path):
    """co：公司 id 的 SQL 表达式（如 '7' 或 '(SELECT id FROM vi_company_base WHERE code = ...)'）。"""
    d = json.loads(path.read_text())
    out = []
    for m in d.get('new_metrics', []):
        out.append(f"""INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency)
SELECT c.code || '.D' || lpad((coalesce((SELECT max(substring(x.code FROM '\\.D(\\d+)$')::int) FROM vi_metric_base x WHERE x.code LIKE c.code || '.D%'), 0) + 1)::text, 3, '0'),
       {lit(m['name'])}, {lit(m['unit'])}, {lit(m['category'])}, {lit(m['source_kind'])}, {lit(m['basis'])}, c.id, {lit(m['source_name'])}, {lit(m['frequency'])}
FROM vi_company_base c WHERE c.id = {co} AND NOT EXISTS (SELECT 1 FROM vi_metric_base WHERE company_id = c.id AND name = {lit(m['name'])});""")
    out.append(f'SELECT vi_merge_company_metrics({co});')
    for g in d.get('merge_metrics', []):
        frm, into = metric(co, g['from']), metric(co, g['into'])
        out.append(f"UPDATE vi_observation_base SET metric_id = {into}, value = value * {g['factor']} WHERE metric_id = {frm} AND {into} IS NOT NULL;")
        out.append(f"DELETE FROM vi_metric_base WHERE id = {frm} AND {into} IS NOT NULL;")
    if d.get('company'):
        sets = ', '.join(f'{k} = {lit(v)}' for k, v in d['company'].items())
        out.append(f"UPDATE vi_company_base SET {sets} WHERE id = {co};")
    for n in d.get('year_notes', []):
        title = f"{n['year']} 年度数据口径与说明"
        src = f"(SELECT id FROM vi_source_base WHERE company_id = {co} AND title = {lit(n['source'])} ORDER BY id LIMIT 1)" if n.get('source') else 'NULL'
        out.append(f"DELETE FROM vi_fact_base WHERE company_id = {co} AND title = {lit(title)};")
        out.append(f"INSERT INTO vi_fact_base (company_id, title, category, statement, period, as_of, verify_status, source_id) VALUES "
                   f"({co}, {lit(title)}, '财务', {lit(n['statement'])}, '{n['year']}', '{n['year']}-12-31', '待核验', {src});")
    for m in d.get('metric_updates', []):          # 先于报表计算：报表计算会把数据来源改写为报表公式
        sets = ', '.join(f'{k} = {lit(m[k])}' for k in ('notes', 'source_name', 'frequency') if k in m)
        out.append(f"UPDATE vi_metric_base SET {sets} WHERE id = {metric(co, m)};")
    for m in d.get('stmt_metrics', []):
        out.append(f"SELECT vi_metric_to_stmt({co}, {lit(m['name'])}, {lit(m['unit'])}, {lit(m['formula'])}, {lit(m['basis'])});")
    for m in d.get('main_basis', []):
        out.append(f"UPDATE vi_metric_base SET basis = {lit(m['basis'])} WHERE id = {metric(co, m)};")
    for m in d.get('basis_fix', []):
        out.append(f"UPDATE vi_observation_base SET basis = {lit(m['basis'])} WHERE metric_id = {metric(co, m)};")
        out.append(f"UPDATE vi_metric_base SET basis = {lit(m['basis'])} WHERE id = {metric(co, m)};")
    for t, key in (('judgment', 'judgment_metrics'), ('risk', 'risk_metrics')):
        for code, m in d.get(key, []):
            out.append(f"INSERT INTO vi_lnk_{t}_metrics ({t}_id, metric_id, \"createdAt\", \"updatedAt\") SELECT x.id, {metric(co, m)}, now(), now() FROM vi_{t}_base x "
                       f"WHERE x.company_id = {co} AND x.code = {lit(code)} AND {metric(co, m)} IS NOT NULL ON CONFLICT DO NOTHING;")
    for t, code, col, text in d.get('text', []):
        out.append(f"UPDATE vi_{t}_base SET {col} = {lit(text)} WHERE company_id = {co} AND code = {lit(code)};")
    for title, _metric, notes in d.get('facts', []):        # 第二项是已取消的“相关指标”（2026-10-27），不再写入
        out.append(f"UPDATE vi_fact_base SET notes = {lit(notes)} WHERE company_id = {co} AND title = {lit(title)};")
    for m in d.get('new_stmt', []):
        out.append(new_metric(co, m['name'], m['unit'], '财务', '报表计算', '时点', '季', m['formula']))
    for e in d.get('history', []):
        m, f = e['metric'], e['formula']
        out.append(new_metric(co, m['name'], m['unit'], '经营' if e['field'] == 'volume' else '财务', '报表计算' if f else '年报',
                              '时点' if e['balance'] else '全年', '年', f))
        out.append(f"UPDATE vi_metric_base SET model_field = {lit(e['field'])} WHERE id = {metric(co, m)};")
        for v in e['values']:
            basis, period = ('时点', f"{v['year']}Q4") if e['balance'] else ('全年', str(v['year']))
            out.append(f"DELETE FROM vi_observation_base WHERE metric_id = {metric(co, m)} AND basis = {lit(basis)} AND period = {lit(period)};")
            out.append(f"INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, collected_at) VALUES "
                       f"({metric(co, m)}, '{v['year']}-12-31', {lit(period)}, {lit(basis)}, {repr(v['value']) if v['value'] is not None else 'NULL'}, {lit(v['summary'])}, now());")
    for a in d.get('assets', []):
        scen = f"scenario_id IN (SELECT id FROM vi_scenario_base WHERE name = {lit(a['scenario'])})" if a['scenario'] else 'scenario_id IS NULL'
        out.append(f"UPDATE vi_sotp_item_base SET metric_id = {metric(co, a['metric'])}, amount = NULL "
                   f"WHERE model_id IN (SELECT id FROM vi_model_base WHERE company_id = {co}) AND code = {lit(a['code'])} AND {scen};")
    meas = d.get('measure')
    if meas:
        out.append(f"UPDATE vi_metric_base SET measure = '时点' WHERE company_id = {co} AND name IN ({', '.join(lit(n) for n in meas['时点'])});")
        if meas.get('时期') == '其余':
            out.append(f"UPDATE vi_metric_base SET measure = '时期' WHERE company_id = {co} AND measure IS NULL;")
    return out


def new_metric(co, name, unit, category, kind, basis, frequency, formula):
    """没有同名同单位的指标才新建（代码＝公司代码.D 顺序号）。"""
    source = ('财务数据（三大报表）：' + formula) if formula else '年报'
    return (f"INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)\n"
            f"SELECT c.code || '.D' || lpad((coalesce((SELECT max(substring(x.code FROM '\\.D(\\d+)$')::int) FROM vi_metric_base x WHERE x.code LIKE c.code || '.D%'), 0) + 1)::text, 3, '0'),\n"
            f"       {lit(name)}, {lit(unit)}, {lit(category)}, {lit(kind)}, {lit(basis)}, c.id, {lit(source)}, {lit(frequency)}, {lit(formula)}\n"
            f"FROM vi_company_base c WHERE c.id = {co} AND NOT EXISTS (SELECT 1 FROM vi_metric_base WHERE company_id = c.id AND name = {lit(name)} "
            f"AND unit IS NOT DISTINCT FROM {lit(unit)});")
