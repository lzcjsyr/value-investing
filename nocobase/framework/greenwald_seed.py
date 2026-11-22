"""三层估值的种子（2026-11-11 重构）：一家公司的估值数据（估值设置、业务口径、假设依据、资产负债重估、调整后利润表、增长）
写成 companies/<公司>/greenwald.sql。空库重建时在该公司全部种子之后执行（要引用论点与假设依据）。

两种来源：
  companies/<公司>/greenwald.py 的 build(db)    研究过的公司（腾讯音乐）：数字在脚本里推导，改脚本 → 重新生成 → 执行
  在线库导出（--export）                        还没写 greenwald.py 的公司（迁移来的四家）：把在线库现状写成 SQL，保证能从零重建

  python3 framework/greenwald_seed.py 01698.HK            # 由 greenwald.py 生成并执行
  python3 framework/greenwald_seed.py --export 600900.SH  # 只把在线库现状导出成 greenwald.sql（不执行）
  python3 framework/greenwald_seed.py --dry 01698.HK      # 只生成不执行

build(db) 返回：
  company      公司表的估值设置（as_of、shares、value_layer、layer_reason、av_basis 资产价值口径、repro_cost 重建成本）与备注 notes
  businesses   估值用到的业务（按编号新增或更新：name、boundary、asset_boundary、sort、capital_basis 口径）
  judgments    假设依据（按编号新增或更新；theses＝关联论点编号）；drop_judgments＝要删掉的依据编号
  bs_items     资产负债重估（全公司，不分业务）：category（经营资产/经营负债＝经营资本，其余＝资产负债桥）、line_item、name、haircut、adjustment、basis、judgments
  epv          调整后利润表：business、sort、name、section、direction、formula、method、value、from_year、to_year、note、judgments
  growth       增长：business、growth、ronic、adv_years、note、judgments（每块业务一行）
"""
import importlib.util
import json
import pathlib
import subprocess
import sys

HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parent
COMPANIES = {'600900.SH': '600900_长江电力', '002078.SZ': '002078_太阳纸业', '601668.SH': '601668_中国建筑',
             '01698.HK': '01698_腾讯音乐', '01810.HK': '01810_小米集团'}
EPV_COLS = ['sort', 'name', 'section', 'direction', 'formula', 'method', 'value', 'from_year', 'to_year', 'note']
GROWTH_COLS = ['growth', 'ronic', 'adv_years', 'note', 'revenue_plan']
BIZ_COLS = ['name', 'boundary', 'asset_boundary', 'sort', 'capital_basis']


def q(sql):
    p = subprocess.run([str(ROOT / 'psql.sh'), '-At', '-c', f"SELECT coalesce(json_agg(t), '[]') FROM ({sql}) t"],
                       capture_output=True, text=True, check=True)
    return json.loads(p.stdout)


def lit(v):
    if v is None:
        return 'NULL'
    if isinstance(v, bool):
        return 'true' if v else 'false'
    if isinstance(v, (int, float)):
        return repr(round(v, 8)) if isinstance(v, float) else str(v)
    return "'" + str(v).replace("'", "''") + "'"


class DB:
    def __init__(self, code):
        self.code = code
        self.co = q(f"SELECT id, name FROM vi_company_base WHERE code = '{code}'")[0]

    def bs(self, date):
        """资产负债表某日的科目 → 金额（亿元）"""
        return {r['item']: r['amount'] for r in q(
            f"SELECT item, amount FROM vi_fin_stmt_base WHERE company_id = {self.co['id']} AND stmt = '资产负债表' "
            f"AND period_end = '{date}' AND amount IS NOT NULL")}


def export(code):
    """在线库现状 → build(db) 同样的结构。"""
    cid = q(f"SELECT id FROM vi_company_base WHERE code = '{code}'")[0]['id']
    jcodes = lambda link, rid: [r['code'] for r in q(
        f"SELECT j.code FROM vi_lnk_{link}_judgments l JOIN vi_judgment_base j ON j.id = l.judgment_id WHERE l.{link}_id = {rid} ORDER BY j.code")]
    co = q(f"SELECT as_of, shares, value_layer, layer_reason, av_basis, repro_cost, notes FROM vi_company_base WHERE id = {cid}")[0]
    biz = q(f"""SELECT code, {', '.join(BIZ_COLS)} FROM vi_business_base b WHERE company_id = {cid}
              AND EXISTS (SELECT 1 FROM vi_epv_base e WHERE e.business_id = b.id)
              ORDER BY sort, id""")
    judg = q(f"SELECT code, title, status, judgment, transmission, parameter, change_threshold "
             f"FROM vi_judgment_base WHERE company_id = {cid} AND code = 'J-MIG'")
    items = [{k: v for k, v in r.items() if k != 'id'} | {'judgments': jcodes('bs_item', r['id'])}
             for r in q(f"""SELECT b.id, b.category, b.line_item, b.name, b.haircut, b.adjustment, b.basis
                            FROM vi_bs_item_base b WHERE b.company_id = {cid} ORDER BY b.sort, b.id""")]
    rows = lambda t, cols: [
        {k: v for k, v in r.items() if k != 'id'} | {'judgments': jcodes(t, r['id'])}
        for r in q(f"""SELECT x.id, bz.code AS business, {', '.join('x.' + c for c in cols)}
                       FROM vi_{t}_base x JOIN vi_business_base bz ON bz.id = x.business_id
                       WHERE x.company_id = {cid} ORDER BY bz.sort, x.id""")]
    return dict(company=co, businesses=biz, judgments=judg, bs_items=items,
                epv=rows('epv', EPV_COLS), growth=rows('growth', GROWTH_COLS))


def sql(code, d):
    co = f"(SELECT id FROM vi_company_base WHERE code = '{code}')"
    jd = lambda c: f"(SELECT id FROM vi_judgment_base WHERE company_id = {co} AND code = {lit(c)})"
    bz = lambda c: f"(SELECT id FROM vi_business_base WHERE company_id = {co} AND code = {lit(c)})" if c else 'NULL'
    out = ['-- 自动生成：framework/greenwald_seed.py。三层估值：估值设置、业务口径、假设依据、资产负债重估、调整后利润表、增长', 'BEGIN;',
           f"UPDATE vi_company_base SET {', '.join(f'{k} = {lit(v)}' for k, v in d['company'].items())} WHERE id = {co};",
           f"DELETE FROM vi_bs_item_base WHERE company_id = {co};",
           f"DELETE FROM vi_epv_base WHERE company_id = {co};",
           f"DELETE FROM vi_growth_base WHERE company_id = {co};"]
    for b in d.get('businesses', []):            # 估值单元：没有就新建（商业模式也用同一份业务身份）
        out.append(f"INSERT INTO vi_business_base ({', '.join(['company_id'] + list(b))}) VALUES ({', '.join([co] + [lit(v) for v in b.values()])}) "
                   f"ON CONFLICT (company_id, code) DO UPDATE SET {', '.join(f'{k} = EXCLUDED.{k}' for k in b if k != 'code')};")
    for c in d.get('drop_judgments', []):
        out.append(f"DELETE FROM vi_judgment_base WHERE company_id = {co} AND code = {lit(c)};")
    for j in d.get('judgments', []):
        j = dict(j)
        theses = j.pop('theses', None)
        j = {k: v for k, v in j.items() if v is not None}
        out.append(f"INSERT INTO vi_judgment_base ({', '.join(['company_id'] + list(j))}) VALUES ({', '.join([co] + [lit(v) for v in j.values()])}) "
                   f"ON CONFLICT (company_id, code) DO UPDATE SET {', '.join(f'{k} = EXCLUDED.{k}' for k in j if k != 'code')};")
        if theses is not None:
            out.append(f"DELETE FROM vi_lnk_judgment_theses WHERE judgment_id = {jd(j['code'])};")
            for t in theses:
                out.append(f"""INSERT INTO vi_lnk_judgment_theses (judgment_id, thesis_id, "createdAt", "updatedAt")
SELECT {jd(j['code'])}, t.id, now(), now() FROM vi_thesis_base t WHERE t.company_id = {co} AND t.code = {lit(t)} ON CONFLICT DO NOTHING;""")

    def linked(insert, table, codes):
        if not codes:
            return insert + ';'
        return (f"WITH ins AS ({insert} RETURNING id)\nINSERT INTO vi_lnk_{table}_judgments ({table}_id, judgment_id, \"createdAt\", \"updatedAt\")\n"
                f"SELECT ins.id, j.id, now(), now() FROM ins JOIN vi_judgment_base j ON j.company_id = {co} AND j.code IN ({', '.join(lit(c) for c in codes)});")

    for i, b in enumerate(d['bs_items'], 1):
        ins = (f"INSERT INTO vi_bs_item_base (company_id, category, line_item, name, haircut, adjustment, basis, sort) VALUES "
               f"({co}, {lit(b['category'])}, {lit(b.get('line_item'))}, {lit(b.get('name'))}, "
               f"{lit(b.get('haircut'))}, {lit(b.get('adjustment'))}, {lit(b.get('basis'))}, {i})")
        out.append(linked(ins, 'bs_item', b.get('judgments')))
    for table, cols in (('epv', EPV_COLS), ('growth', GROWTH_COLS)):
        for v in d[table]:
            have = [c for c in cols if v.get(c) is not None]
            ins = (f"INSERT INTO vi_{table}_base (company_id, business_id{''.join(', ' + c for c in have)}) VALUES "
                   f"({co}, {bz(v['business'])}{''.join(', ' + lit(v[c]) for c in have)})")
            out.append(linked(ins, table, v.get('judgments')))
    if d.get('supplement'):
        out.append(d['supplement'])
    out.append('COMMIT;')
    return '\n'.join(out) + '\n'


def load(code):
    path = ROOT / 'companies' / COMPANIES[code] / 'greenwald.py'
    if not path.exists():
        return None, path.parent
    spec = importlib.util.spec_from_file_location(f'gw_{code}', path)
    mod = importlib.util.module_from_spec(spec)
    sys.path.insert(0, str(HERE))
    spec.loader.exec_module(mod)
    return mod, path.parent


def run(code, dry=False, do_export=False):
    mod, folder = load(code)
    if do_export or mod is None:
        d, dry = export(code), True              # 导出的是在线库现状，不再执行
    else:
        d = mod.build(DB(code))
    out = folder / 'greenwald.sql'
    out.write_text(sql(code, d))
    print(code, len(d['bs_items']), '项资产负债重估，', len(d['epv']), '行调整后利润表，', len(d['growth']), '行增长 →', out.relative_to(ROOT))
    if not dry:
        subprocess.run([str(ROOT / 'psql.sh'), '-f', str(out.relative_to(ROOT))], check=True, cwd=ROOT)


if __name__ == '__main__':
    codes = [a for a in sys.argv[1:] if not a.startswith('--')] or list(COMPANIES)
    for c in codes:
        run(c, dry='--dry' in sys.argv, do_export='--export' in sys.argv)
