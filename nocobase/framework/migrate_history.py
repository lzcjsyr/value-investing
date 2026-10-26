"""历史年度与资产项目不再手抄（2026-10-26）：生成 sql/migrations/2026-10-26i_history_assets.sql，并写各公司 data/data_layer.json 的 history、assets 两节。
只读在线库。

A. 历史年度：每个年度字段对应公司的一个指标（指标上的“模型字段”）。能用报表算的，从候选公式里选与原手录值吻合年份最多的那个
   （吻合＝差额不超过 0.006 亿元，即两位小数的舍入）；吻合年份不到一半、或报表里没有的字段（业务量、现金分红、每股股息等）建成披露指标，
   原值逐年录进「数据」。报表算出的数与原值不一致的年份（追溯调整、口径不同），把原值录为该年的调整值——录了就以录的为准。
   之后历史年度只保留口径说明、主要来源、备注，数值全部从指标汇总。
C. 资产估值与调整：金额就是报表科目或已有指标的，关联“取数指标”，金额清空（截至日的值由视图取）。

  python3 framework/migrate_history.py      （在 nocobase/ 执行）
"""
import json, pathlib, subprocess

ROOT = pathlib.Path(__file__).resolve().parents[1]
OUT = ROOT / 'framework/sql/migrations/2026-10-26i_history_assets.sql'
AUDIT = ROOT / 'checks/history_assets_20261026'
DIRS = {'600900.SH': '600900_长江电力', '002078.SZ': '002078_太阳纸业', '601668.SH': '601668_中国建筑', '01698.HK': '01698_腾讯音乐', '01810.HK': '01810_小米集团'}
TOL = 0.006
# 字段 → (指标名, 单位, 类别, 是否期末余额, 候选报表公式)；候选为空＝只能披露
FIELDS = {
    'volume': (None, None, '经营', False, []),
    'revenue': ('营业收入', '亿元', '财务', False, ['营业收入', '营业额']),
    'cost_of_sales': ('营业成本', '亿元', '财务', False, ['营业成本', '销售成本', '营业额 − 毛利']),
    'pretax_profit': ('利润总额', '亿元', '财务', False, ['利润总额', '除税前溢利']),
    'income_tax': ('所得税', '亿元', '财务', False, ['所得税费用', '税项']),
    'np_parent': ('归母净利润', '亿元', '财务', False, ['归属于母公司所有者的净利润', '股东应占溢利']),
    'minority_profit': ('少数股东损益', '亿元', '财务', False, ['少数股东损益']),
    'da': ('折旧摊销', '亿元', '财务', False, ['加:折旧及摊销']),
    'finance_cost': ('财务费用', '亿元', '财务', False, ['财务费用', '融资成本', '利息费用']),
    'invest_income': ('投资收益', '亿元', '财务', False, ['投资收益', '−减:投资收益']),
    'equity_income': ('权益法投资收益', '亿元', '财务', False, ['对联营企业和合营企业的投资收益', '应占联营公司溢利']),
    'cfo': ('经营活动现金流量净额', '亿元', '财务', False, ['经营活动产生的现金流量净额', '经营业务现金净额']),
    'capex': ('资本开支', '亿元', '财务', False, ['购建固定资产、无形资产和其他长期资产所支付的现金', '−购建固定资产 − 购建无形资产及其他资产',
                                            '购建固定资产 + 购建无形资产及其他资产']),
    'investee_cash_div': ('收到投资分红', '亿元', '财务', False, ['取得投资收益收到的现金', '已收股息(投资)']),
    'net_borrowing': ('净借款', '亿元', '财务', False, ['取得借款收到的现金 − 偿还债务支付的现金',
                                                  '取得借款收到的现金 + 发行债券收到的现金 − 偿还债务支付的现金']),
    'interest_debt': ('带息负债', '亿元', '财务', True, ['短期借款 + 一年内到期的非流动负债 + 长期借款 + 应付债券 + 租赁负债',
                                                 '短期借款 + 一年内到期的非流动负债 + 长期借款 + 应付债券',
                                                 '短期贷款 + 长期贷款',
                                                 '短期贷款 + 长期贷款 + 应付票据 + 应付票据(非流动) + 融资租赁负债(流动) + 融资租赁负债(非流动)']),
    'cash': ('货币资金', '亿元', '财务', True, ['货币资金', '现金及等价物', '现金及等价物 + 短期存款', '现金及等价物 + 短期存款 + 中长期存款',
                                         '现金及等价物 + 短期存款 + 短期投资 + 中长期存款']),
    'equity_parent': ('归母净资产', '亿元', '财务', True, ['归属于母公司股东权益合计', '股东权益']),
    'dividend_total': ('现金分红总额', '亿元', '财务', False, []),
    'dps': ('每股股息', '元', '财务', False, []),
}
REUSE = {('601668.SH', 'dps'): '每股现金分红'}      # 已有同义指标
# C：资产项目 id → 取数指标（名称, 单位）；NEW 为本次新建的报表计算指标
ASSETS = {291: ('现金、定期存款和短期投资', '亿元'), 292: ('带息负债（借款＋票据＋租赁）', '亿元'),
          298: ('对外上市股权（公允价值）', '亿元'), 299: ('对外上市股权（公允价值）', '亿元'), 300: ('对外上市股权（公允价值）', '亿元'),
          305: ('少数股东权益', '亿元'), 366: ('现金储备', '亿元'), 367: ('借款', '亿元'), 382: ('少数股东权益', '亿元')}
NEW_STMT = [('01698.HK', '对外上市股权（公允价值）', '指定以公允价值记账之金融资产'), ('01698.HK', '少数股东权益', '少数股东权益'),
            ('01810.HK', '少数股东权益', '少数股东权益')]


def q(sql):
    p = subprocess.run([str(ROOT / 'psql.sh'), '-At', '-c', f"SELECT coalesce(json_agg(t), '[]') FROM ({sql}) t"], capture_output=True, text=True, check=True)
    return json.loads(p.stdout)


def lit(v):
    return 'NULL' if v is None else "'" + str(v).replace("'", "''") + "'"


def annual(cid, formula, balance):
    rows = q(f"SELECT basis, period, value FROM vi_stmt_series({cid}, {lit(formula)})")
    if balance:
        return {int(r['period'][:4]): r['value'] for r in rows if r['basis'] == '时点' and r['period'].endswith('Q4')}
    return {int(r['period']): r['value'] for r in rows if r['basis'] == '全年'}


def main():
    AUDIT.mkdir(parents=True, exist_ok=True)
    cos = q('SELECT id, code, name, volume_label, volume_unit FROM vi_company_base ORDER BY id')
    metrics = q('SELECT id, company_id, name, unit, source_kind, formula FROM vi_metric_base')
    hist = q('SELECT * FROM vi_fin_history_base ORDER BY company_id, year')
    sql = ['-- 自动生成：framework/migrate_history.py（历史年度、资产项目改为引用指标）。执行前先删 NocoBase 里历史年度的数值字段；执行后重跑 02、03。',
           'BEGIN;', "ALTER TABLE vi_metric_base ADD COLUMN model_field text;",
           "COMMENT ON COLUMN vi_metric_base.model_field IS '模型字段：这个指标是历史年度的哪一列（每家公司每列只能有一个指标）';",
           "ALTER TABLE vi_sotp_item_base ADD COLUMN metric_id bigint REFERENCES vi_metric_base(id) ON DELETE SET NULL;",
           "CREATE INDEX ON vi_sotp_item_base (metric_id);",
           "COMMENT ON COLUMN vi_sotp_item_base.metric_id IS '取数指标（关联 指标）';",
           '-- C. 资产项目：新建报表计算指标，金额改为引用']
    seeds = {c['code']: {'history': [], 'assets': [], 'new_stmt': []} for c in cos}
    for code, name, formula in NEW_STMT:
        cid = next(c['id'] for c in cos if c['code'] == code)
        sql.append(f"""INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT {lit(code)} || '.D' || lpad((coalesce(max(substring(code FROM '\\.D(\\d+)$')::int), 0) + 1)::text, 3, '0'), {lit(name)}, '亿元', '财务', '报表计算', '时点', {cid},
       {lit('财务数据（三大报表）：' + formula)}, '季', {lit(formula)} FROM vi_metric_base WHERE code LIKE {lit(code + '.D%')};""")
        seeds[code]['new_stmt'].append({'name': name, 'unit': '亿元', 'formula': formula})
    asset_rows = {r['id']: r for r in q('SELECT i.id, i.code, i.scenario_id, s.name AS scenario, m.company_id, i.amount FROM vi_sotp_item_base i '
                                         'JOIN vi_model_base m ON m.id = i.model_id LEFT JOIN vi_scenario_base s ON s.id = i.scenario_id')}
    for aid, (name, unit) in ASSETS.items():
        a = asset_rows[aid]
        sql.append(f"UPDATE vi_sotp_item_base SET metric_id = (SELECT id FROM vi_metric_base WHERE company_id = {a['company_id']} AND name = {lit(name)} "
                   f"AND unit = {lit(unit)}), amount = NULL WHERE id = {aid};")
        code = next(c['code'] for c in cos if c['id'] == a['company_id'])
        seeds[code]['assets'].append({'code': a['code'], 'scenario': a['scenario'], 'metric': {'name': name, 'unit': unit}})

    sql.append('-- A. 历史年度：每列对应一个指标；报表算不出或对不上的年份录原值')
    report = []
    for co in cos:
        rows = [h for h in hist if h['company_id'] == co['id']]
        if not rows:
            continue
        for field, (label, unit, cat, balance, cands) in FIELDS.items():
            stored = {h['year']: h[field] for h in rows if h[field] is not None}
            if not stored:
                continue
            best, best_n, best_ser = None, 0, {}
            for f in cands:
                ser = annual(co['id'], f, balance)
                n = sum(1 for y, v in stored.items() if y in ser and abs(ser[y] - v) <= TOL)
                if n > best_n:
                    best, best_n, best_ser = f, n, ser
            use_formula = best is not None and best_n * 2 >= len(stored)
            if field == 'volume':
                label, unit = co['volume_label'], co['volume_unit']
                core = label.split('（')[0]
                hit = next((m for m in metrics if m['company_id'] == co['id'] and m['name'] == core and m['unit'] == unit), None)
                if hit:
                    label = core
            label = REUSE.get((co['code'], field), label)
            existing = next((m for m in metrics if m['company_id'] == co['id'] and m['source_kind'] == '报表计算' and use_formula and m['formula'] == best), None) \
                or next((m for m in metrics if m['company_id'] == co['id'] and m['name'] == label and m['unit'] == unit
                         and (m['formula'] == best if use_formula else m['source_kind'] != '报表计算')), None)
            if existing:
                mref = f"(SELECT id FROM vi_metric_base WHERE id = {existing['id']})"
                key = {'name': existing['name'], 'unit': existing['unit']}
            else:
                if any(m['company_id'] == co['id'] and m['name'] == label and m['unit'] == unit for m in metrics):
                    label += '（历史年度口径）'
                kind = '报表计算' if use_formula else '年报'
                sql.append(f"""INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency, formula)
SELECT {lit(co['code'])} || '.D' || lpad((coalesce(max(substring(code FROM '\\.D(\\d+)$')::int), 0) + 1)::text, 3, '0'), {lit(label)}, {lit(unit)}, {lit(cat)}, {lit(kind)},
       {lit('时点' if balance else '全年')}, {co['id']}, {lit(('财务数据（三大报表）：' + best) if use_formula else '年报（原历史年度手录）')}, '年', {lit(best if use_formula else None)}
FROM vi_metric_base WHERE code LIKE {lit(co['code'] + '.D%')};""")
                mref = f"(SELECT id FROM vi_metric_base WHERE company_id = {co['id']} AND name = {lit(label)} AND unit IS NOT DISTINCT FROM {lit(unit)})"
                key = {'name': label, 'unit': unit}
                metrics.append({'id': None, 'company_id': co['id'], 'name': label, 'unit': unit, 'source_kind': kind, 'formula': best if use_formula else None})
            sql.append(f"UPDATE vi_metric_base SET model_field = {lit(field)} WHERE id = {mref};")
            entry = {'field': field, 'metric': key, 'formula': best if use_formula else None, 'balance': balance, 'values': []}
            have = {}
            if existing:                       # 已有同一期的数且相同：不重复录
                have = {(o['basis'], o['period']): o['value'] for o in q(f"SELECT basis, period, value FROM vi_observation_base WHERE metric_id = {existing['id']}")}
            overrides = []
            for h in rows:
                v = h[field]
                if v is None:
                    continue
                c = best_ser.get(h['year']) if use_formula else None
                if c is not None and abs(c - v) <= TOL:
                    continue
                k = ('时点', f"{h['year']}Q4") if balance else ('全年', str(h['year']))
                if k in have and have[k] is not None and abs(have[k] - v) <= TOL:
                    continue
                overrides.append((h, v, c))
            for h, v, c in overrides:
                basis, period, end = ('时点', f"{h['year']}Q4", f"{h['year']}-12-31") if balance else ('全年', str(h['year']), f"{h['year']}-12-31")
                why = '历史年度原值' + (f'（报表算出 {c:.4f}，差异为追溯调整或口径不同）' if c is not None else '') + \
                      (f'；口径：{h["scope_note"]}' if h['scope_note'] else '')
                sql.append(f"DELETE FROM vi_observation_base WHERE metric_id = {mref} AND basis = {lit(basis)} AND period = {lit(period)};")
                sql.append(f"INSERT INTO vi_observation_base (metric_id, obs_date, period, basis, value, summary, doc_id, collected_at) VALUES "
                           f"({mref}, {lit(end)}, {lit(period)}, {lit(basis)}, {v!r}, {lit(why)}, {h['source_id'] or 'NULL'}, now());")
                entry['values'].append({'year': h['year'], 'value': v, 'summary': why, 'source_id': h['source_id']})
            seeds[co['code']]['history'].append(entry)
            report.append({'company': co['code'], 'field': field, 'metric': key['name'], 'formula': best if use_formula else '（披露）',
                           'years': len(stored), 'matched': best_n if use_formula else 0, 'stored_values': len(overrides)})
    sql += ['-- 历史年度只留口径说明、主要来源、备注',
            'CREATE UNIQUE INDEX vi_metric_model_field_uniq ON vi_metric_base (company_id, model_field) WHERE model_field IS NOT NULL;',
            'ALTER TABLE vi_sotp_item_base ADD CONSTRAINT vi_sotp_item_one_amount CHECK (metric_id IS NULL OR amount IS NULL);',
            'DROP VIEW IF EXISTS vi_fin_history, vi_fin_history_calc, vi_fin_metric CASCADE;',
            'ALTER TABLE vi_fin_history_base ' + ', '.join(f'DROP COLUMN {f}' for f in FIELDS) + ';',
            'COMMIT;']
    OUT.write_text('\n'.join(sql) + '\n')
    (AUDIT / 'history_fields.json').write_text(json.dumps(report, ensure_ascii=False, indent=1))
    for code, d in DIRS.items():
        p = ROOT / 'companies' / d / 'data' / 'data_layer.json'
        data = json.loads(p.read_text())
        data.update(seeds[code])
        p.write_text(json.dumps(data, ensure_ascii=False, indent=1))
    formula_n = sum(1 for r in report if r['formula'] != '（披露）')
    print(OUT.name, f'｜历史年度 {len(report)} 列：报表计算 {formula_n}，披露 {len(report) - formula_n}；录入原值 {sum(r["stored_values"] for r in report)} 个'
          f'（原手录 {sum(r["years"] for r in report)} 个）｜资产项目改引用 {len(ASSETS)} 条')


if __name__ == '__main__':
    main()
