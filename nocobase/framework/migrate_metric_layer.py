"""指标与数据重构（2026-10-26）：生成 sql/migrations/2026-10-26g_metric_layer.sql，并改写各公司 data/data_layer.json（种子用）。
只读在线库；SQL 由人执行。先执行本次的 02_calc.sql 不行——新视图依赖新列，顺序见生成文件开头。

三件事：
  1. 「数据」删掉“经营影响”“处理状态”；“经营解读”并入“说明”（原“披露摘要与口径”）。
  2. 口径从指标移到每期数据上；同一公司同名同单位的指标合成一个，指标上保留“主口径”（最新值、重点跟踪按它取）。
  3. 与三大报表重复的财务指标改为“报表计算”：写报表公式，删掉另存的数，由 vi_stmt_series() 实时算出。
     下表每个公式都和原来存的数逐期核对过（checks/metric_layer_20261026/stmt_check.json）。

  python3 framework/migrate_metric_layer.py      （在 nocobase/ 执行）
"""
import json, pathlib, subprocess

ROOT = pathlib.Path(__file__).resolve().parents[1]
OUT = ROOT / 'framework/sql/migrations/2026-10-26g_metric_layer.sql'
AUDIT = ROOT / 'checks/metric_layer_20261026'
DIRS = {'600900.SH': '600900_长江电力', '002078.SZ': '002078_太阳纸业', '601668.SH': '601668_中国建筑', '01698.HK': '01698_腾讯音乐', '01810.HK': '01810_小米集团'}
MARGIN_A = '（营业收入 − 营业成本）÷ 营业收入'
STMT = {   # 指标 id → 报表公式
    99: '营业收入', 100: '归属于母公司所有者的净利润', 101: MARGIN_A,
    103: '营业收入', 104: '归属于母公司所有者的净利润', 105: MARGIN_A, 189: MARGIN_A,
    112: '应收账款 + 合同资产', 115: '应收账款 + 合同资产', 186: '应收账款 + 合同资产',
    113: '应付票据及应付账款', 116: '应付票据及应付账款',
    114: '−资产减值损失 − 信用减值损失', 117: '−资产减值损失 − 信用减值损失', 184: '−资产减值损失 − 信用减值损失',
    185: '经营活动产生的现金流量净额', 187: '其他非流动资产 + 长期应收款',
    188: '短期借款 + 一年内到期的非流动负债 + 长期借款 + 应付债券 + 租赁负债',
    118: '营业额', 124: '股东应占溢利', 123: '毛利 ÷ 营业额', 130: '现金及等价物 + 短期存款 + 短期投资 + 中长期存款',
    131: '短期贷款 + 长期贷款 + 应付票据 + 应付票据(非流动) + 融资租赁负债(流动) + 融资租赁负债(非流动)',
    134: '营业额', 140: '毛利 ÷ 营业额', 146: '研发费用', 155: '除税后溢利', 158: '短期贷款 + 长期贷款',
}
BASIS_FIX = {157: '时点'}   # 现金储备是期末余额，原来误记为“单季”


def q(sql):
    p = subprocess.run([str(ROOT / 'psql.sh'), '-At', '-c', f"SELECT coalesce(json_agg(t), '[]') FROM ({sql}) t"], capture_output=True, text=True, check=True)
    return json.loads(p.stdout)


def lit(v):
    return 'NULL' if v is None else "'" + str(v).replace("'", "''") + "'"


def check_stmt():
    """每个公式与原来存的数逐期比对（半年累计对二季度累计或时点，全年对全年或四季度时点）。"""
    out = []
    for mid, f in STMT.items():
        m = q(f'SELECT company_id, name, basis FROM vi_metric_base WHERE id = {mid}')[0]
        ser = {(r['basis'], r['period']): r['value'] for r in q(f"SELECT * FROM vi_stmt_series({m['company_id']}, {lit(f)})")}
        ok, bad = 0, []
        for o in q(f'SELECT period, value FROM vi_observation_base WHERE metric_id = {mid}'):
            p, b = o['period'], BASIS_FIX.get(mid, m['basis'])
            cands = [(b, p), ('时点', p), ('全年', p[:4]) if p.endswith('Q4') else None, ('年初至今累计', p[:4] + 'Q2') if p.endswith('H1') else None,
                     ('时点', p[:4] + 'Q2') if p.endswith('H1') else None, ('时点', p + 'Q4') if len(p) == 4 else None]
            c = next((ser[k] for k in cands if k and k in ser), None)
            if c is not None and abs(c - o['value']) <= max(abs(o['value']) * 0.005, 0.06):
                ok += 1
            else:
                bad.append([p, o['value'], c])
        out.append({'id': mid, 'name': m['name'], 'basis': m['basis'], 'formula': f, 'matched': ok, 'mismatched': bad})
    (AUDIT / 'stmt_check.json').write_text(json.dumps(out, ensure_ascii=False, indent=1))
    bad = [r for r in out if r['mismatched']]
    if bad:
        raise SystemExit(f'公式与存的数对不上：{bad}')


def main():
    AUDIT.mkdir(parents=True, exist_ok=True)
    check_stmt()
    ms = {m['id']: m for m in q("""SELECT m.id, m.company_id, c.code AS company, m.name, m.unit, m.basis, m.source_kind,
        (SELECT count(*) FROM vi_observation_base o WHERE o.metric_id = m.id) AS n,
        (SELECT max(o.obs_date) FROM vi_observation_base o WHERE o.metric_id = m.id) AS last,
        EXISTS (SELECT 1 FROM vi_lnk_judgment_metrics l WHERE l.metric_id = m.id) OR EXISTS (SELECT 1 FROM vi_lnk_risk_metrics l WHERE l.metric_id = m.id) AS tracked
        FROM vi_metric_base m LEFT JOIN vi_company_base c ON c.id = m.company_id""")}
    groups = {}
    for m in ms.values():
        if m['company_id']:
            groups.setdefault((m['company'], m['name'], m['unit']), []).append(m)
    main_basis, stmt_rows = {}, []
    for key, g in groups.items():
        g.sort(key=lambda m: (not m['tracked'], m['id']))
        formula = next((STMT[m['id']] for m in g if m['id'] in STMT), None)
        balance = formula and all(t not in formula for t in ('营业', '利润', '溢利', '毛利', '费用', '现金流量', '减值'))
        if formula and balance:
            b = '时点'
        elif g[0]['tracked']:
            b = BASIS_FIX.get(g[0]['id'], g[0]['basis'])
        else:
            b = BASIS_FIX.get(g[0]['id']) or max(g, key=lambda m: (m['last'] or '', m['n'], -m['id']))['basis']   # 最近一期数据所在的口径
        if len(g) > 1 or formula or any(m['id'] in BASIS_FIX for m in g):
            main_basis[key] = b
        if formula:
            assert all(m['id'] in STMT and STMT[m['id']] == formula for m in g), key
            stmt_rows.append({'company': key[0], 'name': key[1], 'unit': key[2], 'formula': formula, 'basis': b})

    sql = ['-- 自动生成：framework/migrate_metric_layer.py（指标与数据重构）。',
           '-- 执行顺序：先删 NocoBase 里「数据」的经营影响、经营解读、处理状态字段和重点跟踪集合；执行本文件；再重跑 02_calc.sql、03_ui.sql。',
           'BEGIN;', '-- 1. 口径记到每期数据上；经营解读并入说明',
           "ALTER TABLE vi_observation_base ADD COLUMN basis text DEFAULT '时点';",
           "COMMENT ON COLUMN vi_observation_base.basis IS '口径：时点＝某一天的值或期末余额；其余为期间数（可选：时点、单季、半年累计、前三季度累计、全年、年初至今累计、滚动四季度）';",
           'UPDATE vi_observation_base o SET basis = m.basis FROM vi_metric_base m WHERE m.id = o.metric_id;']
    for mid, b in BASIS_FIX.items():
        sql.append(f'UPDATE vi_observation_base SET basis = {lit(b)} WHERE metric_id = {mid};')
    sql += ["UPDATE vi_observation_base SET summary = CASE WHEN nullif(btrim(summary), '') IS NULL THEN '解读：' || assessment ELSE summary || E'\\n解读：' || assessment END "
            "WHERE nullif(btrim(assessment), '') IS NOT NULL;",
            "COMMENT ON COLUMN vi_observation_base.summary IS '说明：披露原文摘要、统计范围与推算过程；需要时写一句对经营的解读';",
            '-- 2. 与三大报表重复的指标改为报表计算（公式已逐期核对），删掉另存的数',
            'ALTER TABLE vi_metric_base ADD COLUMN formula text;',
            "COMMENT ON COLUMN vi_metric_base.formula IS '报表公式：报表计算的指标填，科目相加减；比率用“÷”，结果为 %';",
            "COMMENT ON COLUMN vi_metric_base.basis IS '主口径：最新值、重点跟踪按这个口径取；每期数据自己的口径记在「数据」上（可选：时点、单季、半年累计、前三季度累计、全年、年初至今累计、滚动四季度）';"]
    for mid, f in STMT.items():
        sql.append(f"UPDATE vi_metric_base SET source_kind = '报表计算', formula = {lit(f)}, source_name = {lit('财务数据（三大报表）：' + f)} WHERE id = {mid};")
    sql.append(f"DELETE FROM vi_observation_base WHERE metric_id IN ({', '.join(map(str, STMT))});")
    sql.append('-- 3. 同名同单位的指标合成一个，设主口径（合并函数取自 02_calc.sql，这里先装上）')
    calc = (ROOT / 'framework/sql/02_calc.sql').read_text()
    i = calc.index('CREATE OR REPLACE FUNCTION vi_merge_company_metrics'); j = calc.index('END $$;', i) + len('END $$;')
    sql.append(calc[i:j])
    sql.append('SELECT vi_merge_company_metrics(id) FROM vi_company_base;')
    for (co, name, unit), b in main_basis.items():
        sql.append(f"UPDATE vi_metric_base SET basis = {lit(b)} WHERE company_id = (SELECT id FROM vi_company_base WHERE code = {lit(co)}) "
                   f"AND name = {lit(name)} AND unit IS NOT DISTINCT FROM {lit(unit)};")
    sql += ['-- 4. 删除不再使用的字段与视图（02、03 随后重建）',
            'DROP VIEW IF EXISTS vi_tracking, vi_observation, vi_observation_calc, vi_disclosed CASCADE;',
            'ALTER TABLE vi_observation_base DROP COLUMN impact, DROP COLUMN assessment, DROP COLUMN status;',
            'COMMIT;']
    OUT.write_text('\n'.join(sql) + '\n')
    (AUDIT / 'stmt_metrics.json').write_text(json.dumps(stmt_rows, ensure_ascii=False, indent=1))
    (AUDIT / 'merged_groups.json').write_text(json.dumps(
        [{'company': k[0], 'name': k[1], 'unit': k[2], 'ids': [m['id'] for m in g], 'bases': [m['basis'] for m in g], 'main_basis': main_basis.get(k)}
         for k, g in groups.items() if len(g) > 1], ensure_ascii=False, indent=1))

    # 种子：data_layer.json 的指标键改成 名称＋单位（口径不再区分指标），并写上报表计算与主口径
    for code, d in DIRS.items():
        path = ROOT / 'companies' / d / 'data' / 'data_layer.json'
        data = json.loads(path.read_text())
        strip = lambda m: {k: v for k, v in m.items() if k != 'basis'} if m else m
        data['metric_updates'] = [strip(m) for m in data.get('metric_updates', [])]
        for k in ('judgment_metrics', 'risk_metrics'):
            seen, rows = set(), []
            for c, m in data.get(k, []):
                key = (c, json.dumps(strip(m), ensure_ascii=False, sort_keys=True))
                if key not in seen:
                    seen.add(key); rows.append([c, strip(m)])
            data[k] = rows
        data['facts'] = [[t, strip(m), n] for t, m, n in data.get('facts', [])]
        data['stmt_metrics'] = [{k: r[k] for k in ('name', 'unit', 'formula', 'basis')} for r in stmt_rows if r['company'] == code]
        data['main_basis'] = [{'name': n, 'unit': u, 'basis': b} for (c, n, u), b in main_basis.items() if c == code and
                              not any(r['name'] == n and r['unit'] == u for r in stmt_rows if r['company'] == code)]
        data['basis_fix'] = [{'name': ms[mid]['name'], 'unit': ms[mid]['unit'], 'basis': b} for mid, b in BASIS_FIX.items() if ms[mid]['company'] == code]
        order = ['new_metrics', 'stmt_metrics', 'main_basis', 'basis_fix', 'metric_updates', 'judgment_metrics', 'risk_metrics', 'text', 'facts']
        path.write_text(json.dumps({k: data.get(k, []) for k in order}, ensure_ascii=False, indent=1))
    print(OUT.name, '｜报表计算', len(stmt_rows), '个指标（原', len(STMT), '个）｜合并组', sum(1 for g in groups.values() if len(g) > 1),
          '｜设主口径', len(main_basis))


if __name__ == '__main__':
    main()
