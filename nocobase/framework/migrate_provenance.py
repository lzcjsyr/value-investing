"""「数据」的出处只放一处（2026-10-26）：生成 sql/migrations/2026-10-26h_observation_provenance.sql。只读在线库。

原来每条数据都抄一遍“采集地址”和“使用边界”（2,603 条只有 18 种地址、8 种说明）。改为：
  自动采集的数据 → 出处就是关联的原始采集记录（→ 采集配置里的地址），逐行文字删除；
  历史补数 → 每种出处建一份来源文档，数据关联“来源文档”；
  只针对某个指标的使用限制（水文不得外推全年电量）→ 写进指标说明。
执行后删除「数据」的 source、note 两列，重跑 02、03。

  python3 framework/migrate_provenance.py      （在 nocobase/ 执行）
"""
import json, pathlib, subprocess

ROOT = pathlib.Path(__file__).resolve().parents[1]
OUT = ROOT / 'framework/sql/migrations/2026-10-26h_observation_provenance.sql'
METRIC_NOTE = {5: '水文观察数据，不得直接外推全年电量。', 6: '水文观察数据，不得直接外推全年电量。', 7: '水文观察数据，不得直接外推全年电量。'}


def q(sql):
    p = subprocess.run([str(ROOT / 'psql.sh'), '-At', '-c', f"SELECT coalesce(json_agg(t), '[]') FROM ({sql}) t"], capture_output=True, text=True, check=True)
    return json.loads(p.stdout)


def lit(v):
    return 'NULL' if v is None else "'" + str(v).replace("'", "''") + "'"


def main():
    groups = q("""SELECT m.company_id, o.source, o.note, array_agg(DISTINCT o.metric_id ORDER BY o.metric_id) AS metrics,
                         string_agg(DISTINCT m.name, '、') AS names, count(*) AS n, min(o.obs_date) AS d0, max(o.obs_date) AS d1
                  FROM vi_observation_base o JOIN vi_metric_base m ON m.id = o.metric_id
                  WHERE o.raw_capture_id IS NULL AND o.source IS NOT NULL
                  GROUP BY m.company_id, o.source, o.note ORDER BY m.company_id NULLS FIRST, o.source""")
    sql = ['-- 自动生成：framework/migrate_provenance.py。执行前先删 NocoBase 里「数据」的 source、note 字段；执行后重跑 02、03。', 'BEGIN;',
           '-- 1. 历史补数：每种出处一份来源文档，数据关联它']
    for g in groups:
        what = g['note'][5:] if (g['note'] or '').startswith('历史补数：') else g['source']
        years = g['d0'][:4] if g['d0'][:4] == g['d1'][:4] else f"{g['d0'][:4]}—{g['d1'][:4]}"
        title = f"{g['names']}：{what}（{years} 年历史数据）"
        url = g['source'] if g['source'].startswith('http') else None
        publisher = None if url else g['source']
        sql.append(f"""WITH s AS (INSERT INTO vi_source_base (company_id, title, source_type, publisher, url, reliability, verify_status, summary, limitations)
  VALUES ({g['company_id'] if g['company_id'] else 'NULL'}, {lit(title)}, '数据库取数', {lit(publisher)}, {lit(url)}, '三级·第三方数据', '待核验',
          {lit(f"{g['n']} 条历史数据（{g['d0']} 至 {g['d1']}）")}, {lit(g['note'])}) RETURNING id)
UPDATE vi_observation_base o SET doc_id = s.id FROM s
 WHERE o.raw_capture_id IS NULL AND o.source = {lit(g['source'])} AND o.note IS NOT DISTINCT FROM {lit(g['note'])}
   AND o.metric_id IN ({', '.join(map(str, g['metrics']))});""")
    sql.append('-- 2. 只针对某个指标的使用限制写进指标说明')
    for mid, line in METRIC_NOTE.items():
        sql.append(f"UPDATE vi_metric_base SET notes = CASE WHEN nullif(btrim(notes), '') IS NULL THEN {lit(line)} ELSE notes || E'\\n' || {lit(line)} END WHERE id = {mid};")
    sql += ['-- 3. 删除逐行重复的列（自动采集的出处是原始采集记录）',
            'DROP VIEW IF EXISTS vi_observation, vi_observation_calc, vi_obs_current CASCADE;',
            'ALTER TABLE vi_observation_base DROP COLUMN source, DROP COLUMN note;', 'COMMIT;']
    OUT.write_text('\n'.join(sql) + '\n')
    print(OUT.name, '｜来源文档', len(groups), '份，覆盖', sum(g['n'] for g in groups), '条历史数据')


if __name__ == '__main__':
    main()
