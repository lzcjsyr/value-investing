"""数据底稿重构（2026-10-26）：生成 sql/migrations/2026-10-26f_data_layer.sql。只读在线库，输出 SQL 文件，不直接改库。

数据底稿只剩四样东西：
  数   指标＋数据（三大报表原值在财务数据）：任何数只存一次
  话   重要事实：只写文字，不再带“数值、单位”；数字是某个指标某一期的，关联“相关指标”
  出处 来源文档
  关注 不单独建表：假设依据的“跟踪指标”、风险的“预警指标”（多对多关联指标）；「重点跟踪」页按关联自动汇总

跟踪事项（vi_watch）逐条去向，规则只有三条：
  1. 已关联指标，或能对上已有指标的 → 指标挂到它原来关联的假设依据（跟踪指标）和风险（预警指标）上；
     跟踪用途、验证的论点写进指标说明；取数来源、频率补进指标（只补空的或泛称“公司披露”的）。
  2. 指标覆盖不全的部分（如“番茄音乐月活”）和没有指标的定性事项 → 写成一句“持续跟踪：…（频率；来源：…）”，
     有关联风险的追加到风险的“预警信号”，否则追加到假设依据的“事实层”。只写一处。
  3. 正文里引用跟踪事项编号的（W7、K02……）→ 换成事项名称（编号随表删除）。

  python3 framework/migrate_data_layer.py     （在 nocobase/ 执行）
"""
import json, pathlib, re, subprocess

ROOT = pathlib.Path(__file__).resolve().parents[1]
OUT = ROOT / 'framework/sql/migrations/2026-10-26f_data_layer.sql'

# 公司代码 → {跟踪事项编号: (指标 id 列表, 指标覆盖不到、需要写成文字的部分)}；None＝整条是定性事项（规则 2）
# 指标 id 来自在线库 vi_metric_base；'NEW:售电价' 是本次新建的指标
MAP = {
    '600900.SH': {'K01': None, 'K02': ([97], None), 'K04': (['NEW:售电价'], None), 'K06': None, 'K07': None, 'K08': None,
                  'K09': None, 'K10': None, 'K12': None},
    '002078.SZ': {'W3': ([101], '分产品吨利'), 'W4': None, 'W5': None, 'W6': None, 'W7': None, 'W8': None, 'W9': None, 'W10': None},
    '601668.SH': {},
    '01698.HK': {'W2': ([120], None), 'W3': ([133], '番茄音乐月活、汽水音乐付费情况'), 'W4': ([123], None), 'W5': ([132], '新回购计划'),
                 'W6': None, 'W7': ([130, 131], None), 'W8': ([126], None), 'W9': None, 'W11': None, 'W12': None},
    '01810.HK': {'W2': None, 'W3': ([142, 148, 145], None), 'W4': ([143, 170], None), 'W5': ([149], '汽车月度交付与订单（单季交付量见指标）'),
                 'W6': ([151], 'AI 投入口径'), 'W7': ([139, 156], None), 'W8': ([159], '股本变动'), 'W9': ([157, 158], '投资者负债'),
                 'W11': None, 'W12': None},
}
# 跟踪口径补充（写进指标说明）
CAVEAT = {('01698.HK', 'W2'): '看剔除喜马拉雅后的同比'}
NEW_METRICS = {'NEW:售电价': dict(company='600900.SH', name='实现售电价', unit='元/千瓦时', category='经营', source_kind='公司披露',
                                basis='半年累计', frequency='半年', source_name='https://www.cypc.com.cn（半年报、年报）')}
# 重要事实 → 指标（期间与数值都能对上已有数据；1789“少数股东约 27%”与每股分红 0.2718 数值巧合，单位不同，不关联）
FACT_METRIC = {1786: 195, 1320: 126, 1836: 152, 1837: 134, 1839: 166, 1840: 138, 1841: 163, 1842: 164, 1845: 160, 1846: 161,
               1849: 151, 1861: 145, 1872: 178}
# 正文里整句引用两个编号的，先按原意改写，再做通用替换
SPECIAL = [('看跟踪事项 W9（减值累计同比）、W7（地产业务毛利率）', '看重点跟踪的资产及信用减值损失（累计同比）和地产业务毛利率')]
GENERIC_SOURCE = {'', '公司披露', '年报', '手工整理'}
TEXT = {
    'biz_model': ['title', 'content', 'metric', 'trend'], 'value_chain': ['role', 'analysis', 'counter', 'profit_share'],
    'competitor': ['strategy', 'vs_us'], 'moat': ['mechanism', 'financial_link', 'evidence', 'counter', 'replication', 'threats'],
    'thesis': ['bull_case', 'bear_case', 'bull_rebuttal', 'bear_rebuttal', 'verdict', 'decisive_evidence', 'mind_changer', 'model_impact', 'external_view'],
    'risk': ['mechanism', 'impact_estimate', 'mitigants', 'early_warning', 'response'], 'fit_score': ['rationale', 'counter'],
    'judgment': ['fact_layer', 'judgment', 'transmission', 'change_threshold', 'no_change_condition', 'counter_evidence'],
    'issue': ['title', 'impact', 'done_condition', 'progress'],
}


def q(sql):
    p = subprocess.run([str(ROOT / 'psql.sh'), '-At', '-c', f"SELECT coalesce(json_agg(t), '[]') FROM ({sql}) t"],
                       capture_output=True, text=True, check=True)
    return json.loads(p.stdout)


def lit(v):
    return 'NULL' if v is None else "'" + str(v).replace("'", "''") + "'"


def fmt(v):
    return f'{v:.6g}'


def main():
    cos = {c['id']: c for c in q('SELECT id, code, name FROM vi_company_base')}
    code_of = {c['code']: c['id'] for c in cos.values()}
    watches = q("""SELECT w.*, coalesce((SELECT json_agg(t.code ORDER BY t.code) FROM vi_lnk_watch_theses l JOIN vi_thesis_base t ON t.id = l.thesis_id WHERE l.watch_id = w.id), '[]') AS theses,
                          coalesce((SELECT json_agg(l.judgment_id ORDER BY j.code) FROM vi_lnk_watch_judgments l JOIN vi_judgment_base j ON j.id = l.judgment_id WHERE l.watch_id = w.id), '[]') AS judgments,
                          coalesce((SELECT json_agg(l.risk_id ORDER BY r.code) FROM vi_lnk_risk_watches l JOIN vi_risk_base r ON r.id = l.risk_id WHERE l.watch_id = w.id), '[]') AS risks
                   FROM vi_watch_base w ORDER BY w.company_id, w.id""")
    metrics = {m['id']: m for m in q('SELECT id, company_id, name, source_kind, source_name, frequency, notes FROM vi_metric_base')}
    sql = ['-- 自动生成：framework/migrate_data_layer.py（数据底稿重构）。执行前先删 NocoBase 里的跟踪事项页面与集合，执行后重跑 02、03。',
           'BEGIN;', '-- 1. 关注＝假设依据、风险关联指标']
    for t, label in (('judgment', '跟踪指标'), ('risk', '预警指标')):
        sql.append(f'''CREATE TABLE vi_lnk_{t}_metrics (
  {t}_id bigint NOT NULL REFERENCES vi_{t}_base(id) ON DELETE CASCADE,
  metric_id bigint NOT NULL REFERENCES vi_metric_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY ({t}_id, metric_id)
);
COMMENT ON TABLE vi_lnk_{t}_metrics IS {lit(('假设依据' if t == 'judgment' else '风险分析') + ' ↔ ' + label + '（多对多）')};''')
    sql.append('-- 2. 新建指标（跟踪事项里有、数据里还没有的单一数字）')
    for key, m in NEW_METRICS.items():
        cid = code_of[m['company']]
        sql.append(f"""INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency)
SELECT {lit(m['company'])} || '.D' || lpad((coalesce(max(substring(code FROM '\\.D(\\d+)$')::int), 0) + 1)::text, 3, '0'),
       {lit(m['name'])}, {lit(m['unit'])}, {lit(m['category'])}, {lit(m['source_kind'])}, {lit(m['basis'])}, {cid}, {lit(m['source_name'])}, {lit(m['frequency'])}
FROM vi_metric_base WHERE code LIKE {lit(m['company'] + '.D%')};""")

    def mref(mid):
        if isinstance(mid, int):
            return str(mid)
        m = NEW_METRICS[mid]
        return f"(SELECT id FROM vi_metric_base WHERE company_id = {code_of[m['company']]} AND name = {lit(m['name'])})"

    sql.append('-- 3. 跟踪事项逐条去向')
    notes, src, freq, appends, report = {}, {}, {}, [], []
    for w in watches:
        cc = cos[w['company_id']]['code']
        rule = MAP[cc].get(w['code'], 'linked')
        if rule == 'linked':
            assert w['metric_id'], (cc, w['code'])
            mids, extra = [w['metric_id']], None
        elif rule is None:
            mids, extra = [], w['title']
        else:
            assert not w['metric_id'], (cc, w['code'])
            mids, extra = rule
        for mid in mids:
            for j in w['judgments']:
                sql.append(f'INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id) VALUES ({j}, {mref(mid)}) ON CONFLICT DO NOTHING;')
            for r in w['risks']:
                sql.append(f'INSERT INTO vi_lnk_risk_metrics (risk_id, metric_id) VALUES ({r}, {mref(mid)}) ON CONFLICT DO NOTHING;')
            if not isinstance(mid, int) or metrics[mid]['company_id'] is None:
                continue                     # 宏观指标多家共用：不写某家公司的用途；新指标建时已带来源和频率
            m = metrics[mid]
            parts = [p for p in [CAVEAT.get((cc, w['code'])), ('看同比' if w['compare'] == '同比' else None),
                                 (w['purpose'] or '').strip().rstrip('。') or None,
                                 ('验证论点：' + '、'.join(w['theses']) if w['theses'] else None)] if p]
            if parts:
                notes.setdefault(mid, []).append('跟踪用途：' + '；'.join(parts))
            if m['source_kind'] != '自动采集' and (m['source_name'] or '').strip() in GENERIC_SOURCE and (w['preferred_source'] or '').strip():
                src[mid] = w['preferred_source'].strip()
            if not (m['frequency'] or '').strip() and w['frequency']:
                freq[mid] = w['frequency']
        if extra:
            line = f"持续跟踪：{extra}（{w['frequency'] or '不定期'}；来源：{(w['preferred_source'] or '未写').strip()}）"
            if w['risks']:                   # 只写一处：编号最小的关联风险，否则编号最小的假设依据
                appends.append(('risk', w['risks'][0], 'early_warning', line))
            elif w['judgments']:
                appends.append(('judgment', w['judgments'][0], 'fact_layer', line))
            else:
                raise SystemExit(f'{cc} {w["code"]} 没有关联，无处安放')
        report.append({'company': cc, 'code': w['code'], 'title': w['title'], 'metrics': [str(m) for m in mids], 'text': extra,
                       'to': 'risk' if extra and w['risks'] else 'judgment' if extra else None})
    sql.append('-- 3b. 正文里的跟踪事项编号换成名称（先于下面的追加，守卫条件读的是原文）')
    titles = {}
    for w in watches:
        titles.setdefault(w['company_id'], {})[w['code']] = w['title']
    renamed = []
    for t, cols in TEXT.items():
        for row in q(f"SELECT id, company_id, {', '.join(cols)} FROM vi_{t}_base WHERE company_id IS NOT NULL"):
            for c in cols:
                text = row[c]
                if not text:
                    continue
                new = text
                for a, b in SPECIAL:
                    new = new.replace(a, b)
                for code, title in sorted(titles.get(row['company_id'], {}).items(), key=lambda x: -len(x[0])):
                    pat = re.compile(r'(?<![A-Za-z0-9-])' + code + r'(?![A-Za-z0-9])\s*')
                    new = pat.sub(lambda m: '' if new[m.end():].startswith(title) else f'「{title}」', new)
                if new != text:
                    sql.append(f'UPDATE vi_{t}_base SET {c} = {lit(new)} WHERE id = {row["id"]} AND {c} = {lit(text)};')
                    renamed.append(f'{t}#{row["id"]}.{c}')

    for mid, ns in notes.items():
        old = (metrics[mid]['notes'] or '').strip()
        sql.append(f"UPDATE vi_metric_base SET notes = {lit((old + chr(10) if old else '') + chr(10).join(ns))} WHERE id = {mid};")
    for mid, s in src.items():
        sql.append(f'UPDATE vi_metric_base SET source_name = {lit(s)} WHERE id = {mid};')
    for mid, f in freq.items():
        sql.append(f'UPDATE vi_metric_base SET frequency = {lit(f)} WHERE id = {mid};')
    for t, rid, col, line in appends:
        sql.append(f"UPDATE vi_{t}_base SET {col} = CASE WHEN nullif(btrim({col}), '') IS NULL THEN {lit(line)} ELSE {col} || E'\\n' || {lit(line)} END WHERE id = {rid};")

    sql.append('-- 5. 重要事实只写文字：数字关联到指标；正文里没写出来的原数值（推算值）记进备注')
    facts = q('SELECT id, title, statement, notes, value, unit, period, metric_id FROM vi_fact_base WHERE value IS NOT NULL')
    for fid, mid in FACT_METRIC.items():
        sql.append(f'UPDATE vi_fact_base SET metric_id = {mid} WHERE id = {fid} AND metric_id IS NULL;')
    kept = []
    for f in facts:
        text = ' '.join(filter(None, [f['title'], f['statement'], f['notes']])).replace('−', '-')
        if not appears(f['value'], f['unit'], text):
            line = f"原“数值”字段：{fmt(f['value'])} {f['unit'] or ''}（{f['period'] or '期间未写'}），为正文数字的推算或合计".replace(' （', '（')
            old = (f['notes'] or '').strip()
            sql.append(f"UPDATE vi_fact_base SET notes = {lit((old + chr(10) if old else '') + line)} WHERE id = {f['id']};")
            kept.append(f['id'])

    sql.append('-- 6. 每个指标都要写数据来源（每期的来源文档关联在“数据”上）')
    sql.append("ALTER TABLE vi_metric_base ADD CONSTRAINT vi_metric_source_required CHECK (nullif(btrim(source_name), '') IS NOT NULL);")
    sql.append('-- 7. 删除旧结构（依赖它们的视图由随后重跑的 02、03 重建）')
    sql.append('DROP VIEW IF EXISTS vi_fact, vi_watch, vi_watch_calc, vi_company_metric CASCADE;')
    sql.append('ALTER TABLE vi_fact_base DROP COLUMN value, DROP COLUMN unit;')
    sql.append('DROP TABLE vi_lnk_watch_theses, vi_lnk_watch_judgments, vi_lnk_risk_watches;')
    sql.append('DROP TABLE vi_watch_base CASCADE;')
    sql.append('DROP FUNCTION IF EXISTS vi_watch_dml();')
    sql.append("COMMENT ON COLUMN vi_fact_base.metric_id IS '相关指标（关联 指标）';")
    sql.append('COMMIT;')
    OUT.write_text('\n'.join(sql) + '\n')
    audit = ROOT / 'checks/data_layer_20261026'
    audit.mkdir(parents=True, exist_ok=True)
    (audit / 'watch_disposition.json').write_text(json.dumps(report, ensure_ascii=False, indent=1))
    (audit / 'text_renamed.json').write_text(json.dumps(renamed, ensure_ascii=False, indent=1))
    print(OUT.name, '｜跟踪事项', len(watches), '条：挂指标', sum(1 for r in report if r['metrics']), '，写成文字', sum(1 for r in report if r['text']),
          '｜正文改编号', len(renamed), '处｜事实关联指标', len(FACT_METRIC), '条，原数值记入备注', len(kept), '条')


def appears(v, unit, text):
    vals = [v] + ([v * 100] if unit == '比率' else []) + ([v * 100, v * 1000, v * 1e4] if unit in ('亿人', '亿台') else []) + \
           ([v * 1e4] if unit == '万辆' else [])
    for x in vals:
        for d in range(5):
            for s in {f'{x:.{d}f}', f'{x:,.{d}f}', f'{x:.{d}f}'.rstrip('0').rstrip('.') if '.' in f'{x:.{d}f}' else f'{x:.{d}f}'}:
                if s not in ('0', '-0') and re.search(r'(?<![0-9.])' + re.escape(s) + r'(?![0-9])', text):
                    return True
    return False


if __name__ == '__main__':
    main()
