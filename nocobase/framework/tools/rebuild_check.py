"""空库重建核对：只用项目里的文件（01→02→03→宏观数据与各公司 seed.sql）在临时库 vi_rebuild 重建全部数据，再与在线库逐表比较。

  python3 tools/rebuild_check.py

比较方法：每张 vi_ 输入表按“去掉 id、外键 id、时间戳之后的整行内容”求指纹（与插入顺序、id 分配无关），关联表比较条数，
估值结论按公司与情景比较每股价值，自动检查比较结果。运行时才产生的数据（采集运行、重建之后自动采集的观察与原始记录）会列为差异，属正常。
"""
import json, pathlib, subprocess, sys

ROOT = pathlib.Path(__file__).resolve().parents[2]
SEEDS = ['macro', 'companies/600900_长江电力', 'companies/002078_太阳纸业', 'companies/601668_中国建筑', 'companies/01698_腾讯音乐', 'companies/01810_小米集团']
# 宏观数据与长江电力用固定 id，必须最先灌入；之后各公司按业务键写入
TMP = 'vi_rebuild'


def psql(db, sql=None, file=None):
    cmd = ['docker', 'compose', 'exec', '-T', 'postgres', 'psql', '-v', 'ON_ERROR_STOP=1', '-U', 'nocobase', '-d', db, '-q', '-At']
    if sql:
        cmd += ['-c', sql]
    p = subprocess.run(cmd, cwd=ROOT, capture_output=True, text=True, input=pathlib.Path(file).read_text() if file else None)
    if p.returncode:
        raise RuntimeError(f'{db} {file or sql[:80]}\n{p.stderr[-1500:]}')
    return p.stdout


def rebuild():
    psql('nocobase', f'DROP DATABASE IF EXISTS {TMP}')
    psql('nocobase', f'CREATE DATABASE {TMP}')
    for f in ['01_schema.sql', '02_calc.sql', '03_ui.sql']:
        psql(TMP, file=ROOT / 'framework/sql' / f)
    for s in SEEDS:
        psql(TMP, file=ROOT / s / 'seed.sql')


def tables(db):
    return psql(db, "SELECT tablename FROM pg_tables WHERE schemaname = 'public' AND tablename LIKE 'vi\\_%' ORDER BY 1").split()


def fingerprint(db, t):
    cols = psql(db, f"""SELECT string_agg(quote_ident(column_name), ', ' ORDER BY column_name) FROM information_schema.columns
                        WHERE table_name = '{t}' AND column_name NOT IN ('id', 'created_at', 'updated_at', 'createdAt', 'updatedAt')
                        AND column_name NOT LIKE '%\\_id'""").strip()
    if not cols:
        return psql(db, f'SELECT count(*) FROM {t}').strip(), None
    out = psql(db, f"SELECT count(*), md5(coalesce(string_agg(r, '|' ORDER BY r), '')) FROM (SELECT ({cols})::text AS r FROM {t}) x")
    n, h = out.strip().split('|')
    return n, h


if __name__ == '__main__':
    rebuild()
    diff = []
    for t in sorted(set(tables('nocobase')) | set(tables(TMP))):
        a, b = fingerprint('nocobase', t), fingerprint(TMP, t)
        if a != b:
            diff.append((t, a[0], b[0]))
    val = "SELECT c.code || ' ' || v.scenario_name || ' ' || round(v.value_today::numeric, 2) || ' ' || round(v.cash_value_today::numeric, 2) FROM vi_valuation v JOIN vi_company_base c ON c.id = v.company_id ORDER BY 1"
    chk = "SELECT c.code || ' ' || k.code || ' ' || k.result FROM vi_check k JOIN vi_company_base c ON c.id = k.company_id ORDER BY 1"
    v1, v2 = psql('nocobase', val).split('\n'), psql(TMP, val).split('\n')
    c1, c2 = psql('nocobase', chk).split('\n'), psql(TMP, chk).split('\n')
    print(f'估值结论：{len(v1) - 1} 行，' + ('完全一致' if v1 == v2 else '不一致：' + str(sorted(set(v1) ^ set(v2)))))
    print(f'自动检查：{len(c1) - 1} 行，' + ('完全一致' if c1 == c2 else '不一致：' + str(sorted(set(c1) ^ set(c2)))))
    print('内容不一致的表（在线 / 重建 行数）：' + ('无' if not diff else ''))
    for t, a, b in diff:
        print(f'  {t}: {a} / {b}')
