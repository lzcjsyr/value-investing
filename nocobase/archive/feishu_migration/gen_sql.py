"""由 spec.py + 飞书导出生成 SQL：
  sql/01_tables.sql  输入表、关联表
  sql/02_data.sql    飞书记录（保留 feishu_id 便于溯源）
  sql/04_ui.sql      界面视图 + INSTEAD OF 触发器（依赖 sql/03_calc.sql 的计算视图）
"""
import json, pathlib
import spec

HERE = pathlib.Path(__file__).resolve().parent
EXPORT = HERE / 'feishu_export'
SQL = HERE / 'sql'
TB = spec.table_by_code()


def q(v):
    if v is None:
        return 'NULL'
    if isinstance(v, bool):
        return 'TRUE' if v else 'FALSE'
    if isinstance(v, (int, float)):
        return repr(v)
    return "'" + str(v).replace("'", "''") + "'"


def m2o_links(code):
    return [l for l in spec.LINKS if l[0] == code and l[4] == 'm2o']


def m2m_links():
    return [l for l in spec.LINKS if l[4] == 'm2m']


def lnk_table(l):
    return f'cj_lnk_{l[0]}_{l[2]}'


def lnk_keys(l):
    src, dst = f'{l[0]}_id', f'{l[3]}_id'
    return src, dst


def load(code):
    tid = TB[code][0]
    return [json.loads(x) for x in open(EXPORT / f'{tid}.ndjson')]


def convert(v, kind):
    if v in (None, '', []):
        return None
    if kind == 'select':
        return v[0] if isinstance(v, list) else v
    if kind == 'int':
        return int(float(v))
    if kind == 'num':
        return float(v)
    return v


def gen_tables():
    out = ['-- 自动生成：gen_sql.py。输入表与关联表', 'BEGIN;']
    for code in TB:
        cols = ['id bigserial PRIMARY KEY']
        cols += [f'{en} {spec.PG_TYPE[k]}' for _, en, k in spec.INPUTS.get(code, [])]
        cols += [f'{l[2]}_id bigint' for l in m2o_links(code)]
        cols += ['feishu_id text UNIQUE']
        out.append(f'CREATE TABLE cj_{code}_base (\n  ' + ',\n  '.join(cols) + '\n);')
    for l in m2m_links():
        src, dst = lnk_keys(l)
        out.append(
            f'CREATE TABLE {lnk_table(l)} (\n'
            f'  {src} bigint NOT NULL REFERENCES cj_{l[0]}_base(id) ON DELETE CASCADE,\n'
            f'  {dst} bigint NOT NULL REFERENCES cj_{l[3]}_base(id) ON DELETE CASCADE,\n'
            f'  "createdAt" timestamptz NOT NULL DEFAULT now(),\n'
            f'  "updatedAt" timestamptz NOT NULL DEFAULT now(),\n'
            f'  PRIMARY KEY ({src}, {dst})\n);')
    out.append('COMMIT;')
    (SQL / '01_tables.sql').write_text('\n\n'.join(out) + '\n')


def gen_data():
    ids = {}  # (code, feishu_id) -> id
    rows = {code: load(code) for code in TB}
    for code, recs in rows.items():
        for i, r in enumerate(recs, 1):
            ids[(code, r['record_id'])] = i
    out = ['-- 自动生成：gen_sql.py。飞书记录导入（按导出顺序编号）', 'BEGIN;']
    for code, recs in rows.items():
        inputs = spec.INPUTS.get(code, [])
        fks = m2o_links(code)
        cols = ['id'] + [en for _, en, _ in inputs] + [f'{l[2]}_id' for l in fks] + ['feishu_id']
        vals = []
        for r in recs:
            v = [ids[(code, r['record_id'])]]
            v += [convert(r.get(cn), k) for cn, _, k in inputs]
            for l in fks:
                linked = r.get(l[1]) or []
                assert len(linked) <= 1, (code, l)
                v.append(ids[(l[3], linked[0]['id'])] if linked else None)
            v.append(r['record_id'])
            vals.append('(' + ', '.join(q(x) for x in v) + ')')
        if vals:
            out.append(f'INSERT INTO cj_{code}_base ({", ".join(cols)}) VALUES\n' + ',\n'.join(vals) + ';')
        out.append(f"SELECT setval(pg_get_serial_sequence('cj_{code}_base','id'), GREATEST((SELECT max(id) FROM cj_{code}_base), 1));")
    for l in m2m_links():
        src, dst = lnk_keys(l)
        pairs = set()
        for r in rows[l[0]]:
            for t in r.get(l[1]) or []:
                pairs.add((ids[(l[0], r['record_id'])], ids[(l[3], t['id'])]))
        if l[5]:  # 双向关联：合并反向字段的数据
            for r in rows[l[3]]:
                for t in r.get(l[5][0]) or []:
                    pairs.add((ids[(l[0], t['id'])], ids[(l[3], r['record_id'])]))
        if pairs:
            out.append(f'INSERT INTO {lnk_table(l)} ({src}, {dst}) VALUES\n' +
                       ',\n'.join(f'({a}, {b})' for a, b in sorted(pairs)) + ';')
    out.append('COMMIT;')
    (SQL / '02_data.sql').write_text('\n\n'.join(out) + '\n')


def gen_ui():
    out = ['-- 自动生成：gen_sql.py。界面视图（输入列 + 计算列）与写入触发器', 'BEGIN;']
    for code in TB:
        inputs = [en for _, en, _ in spec.INPUTS.get(code, [])]
        fks = [f'{l[2]}_id' for l in m2o_links(code)]
        calc = [en for _, en, _ in spec.CALC.get(code, [])]
        editable = inputs + fks
        sel = ['b.id'] + [f'b.{c}' for c in editable] + [f'c.{c}' for c in calc] + ['b.feishu_id']
        frm = f'cj_{code}_base b' + (f' LEFT JOIN cj_{code}_calc c ON c.id = b.id' if calc else '')
        out.append(f'CREATE OR REPLACE VIEW cj_{code} AS\nSELECT ' + ',\n       '.join(sel) + f'\nFROM {frm};')
        cols = ', '.join(editable)
        new = ', '.join(f'NEW.{c}' for c in editable)
        sets = ', '.join(f'{c} = NEW.{c}' for c in editable)
        out.append(f'''CREATE OR REPLACE FUNCTION cj_{code}_dml() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO cj_{code}_base ({cols}) VALUES ({new}) RETURNING id INTO NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE cj_{code}_base SET {sets} WHERE id = OLD.id;
    RETURN NEW;
  ELSE
    DELETE FROM cj_{code}_base WHERE id = OLD.id;
    RETURN OLD;
  END IF;
END $$;''')
        out.append(f'DROP TRIGGER IF EXISTS cj_{code}_dml ON cj_{code};\n'
                   f'CREATE TRIGGER cj_{code}_dml INSTEAD OF INSERT OR UPDATE OR DELETE ON cj_{code} '
                   f'FOR EACH ROW EXECUTE FUNCTION cj_{code}_dml();')
    out.append('COMMIT;')
    (SQL / '04_ui.sql').write_text('\n\n'.join(out) + '\n')


if __name__ == '__main__':
    SQL.mkdir(exist_ok=True)
    gen_tables(); gen_data(); gen_ui()
    print('generated', *sorted(p.name for p in SQL.glob('*.sql')))
