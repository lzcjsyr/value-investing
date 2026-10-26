"""由 spec.py 生成：
  sql/01_schema.sql  输入表 vi_<表>_base（含中文注释、外键、更新时间）与多对多关联表
  sql/03_ui.sql      界面视图 vi_<表>（输入列 + 计算列 + 更新时间），INSTEAD OF 触发器把写入落回 _base
计算列的 SQL 在 sql/02_calc.sql（手写）。执行顺序：01 → 02 → 03。
"""
import pathlib
import spec

HERE = pathlib.Path(__file__).resolve().parent
OUT = HERE / 'sql'
T = spec.all_tables()


def lit(s):
    return "'" + str(s).replace("'", "''") + "'"


def col_comment(f):
    text = f['title'] + ('：' + f['desc'] if f.get('desc') else '')
    if f['kind'] == 'select':
        text += '（可选：' + '、'.join(f['options']) + '）'
    if f['kind'] == 'pct':
        text += '（小数，0.05＝5%）'
    return text


def schema():
    out = ['-- 自动生成：framework/gen_sql.py。价值投资研究框架输入表', 'BEGIN;',
           '''CREATE OR REPLACE FUNCTION vi_touch_updated_at() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN NEW.updated_at := now(); RETURN NEW; END $$;''']
    for t in spec.TABLES:
        base = f"vi_{t['code']}_base"
        cols = ['id bigserial PRIMARY KEY']
        cols += [f"{f['name']} {spec.PG_TYPE[f['kind']]}" +
                 (f" DEFAULT {lit(f['default'])}" if 'default' in f else '') for f in spec.scalar_fields(t)]
        cols += [f"{f['name']}_id bigint" for f in spec.m2o_fields(t)]
        cols += ['created_at timestamptz NOT NULL DEFAULT now()', 'updated_at timestamptz NOT NULL DEFAULT now()']
        out.append(f'CREATE TABLE {base} (\n  ' + ',\n  '.join(cols) + '\n);')
        out.append(f"COMMENT ON TABLE {base} IS {lit(t['title'] + '：' + spec.purpose(t))};")
        for f in spec.scalar_fields(t):
            out.append(f"COMMENT ON COLUMN {base}.{f['name']} IS {lit(col_comment(f))};")
        for f in spec.m2o_fields(t):
            out.append(f"COMMENT ON COLUMN {base}.{f['name']}_id IS {lit(f['title'] + '（关联 ' + T[f['target']]['title'] + '）')};")
        out.append(f"CREATE TRIGGER {base}_touch BEFORE UPDATE ON {base} FOR EACH ROW EXECUTE FUNCTION vi_touch_updated_at();")
    for t in spec.TABLES:  # 外键放在全部表建好之后（公司↔指标互相引用）
        for f in spec.m2o_fields(t):
            out.append(f"ALTER TABLE vi_{t['code']}_base ADD FOREIGN KEY ({f['name']}_id) "
                       f"REFERENCES vi_{f['target']}_base(id) ON DELETE SET NULL;")
            out.append(f"CREATE INDEX ON vi_{t['code']}_base ({f['name']}_id);")
    for code, cols in spec.UNIQUE.items():
        out.append(f"ALTER TABLE vi_{code}_base ADD CONSTRAINT vi_{code}_uniq UNIQUE ({', '.join(cols)});")
    for t in spec.TABLES:
        for f in spec.m2m_fields(t):
            lt, a, b = spec.lnk_table(t, f), f"{t['code']}_id", f"{f['target']}_id"
            out.append(f'''CREATE TABLE {lt} (
  {a} bigint NOT NULL REFERENCES vi_{t['code']}_base(id) ON DELETE CASCADE,
  {b} bigint NOT NULL REFERENCES vi_{f['target']}_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY ({a}, {b})
);''')
            out.append(f"COMMENT ON TABLE {lt} IS {lit(t['title'] + ' ↔ ' + f['title'] + '（多对多）')};")
    out.append('COMMIT;')
    (OUT / '01_schema.sql').write_text('\n\n'.join(out) + '\n')


def ui():
    out = ['-- 自动生成：framework/gen_sql.py。界面视图与写入触发器（依赖 02_calc.sql）', 'BEGIN;']
    for t in spec.TABLES:
        code = t['code']
        editable = [f['name'] for f in spec.scalar_fields(t)] + [f"{f['name']}_id" for f in spec.m2o_fields(t)]
        defaults = {f['name']: f['default'] for f in spec.scalar_fields(t) if 'default' in f}
        write_values = {c: f"COALESCE(NEW.{c}, {lit(defaults[c])})" if c in defaults else f'NEW.{c}' for c in editable}
        calc = [f['name'] for f in t.get('calc', [])]
        sel = ['b.id'] + [f'b.{c}' for c in editable] + [f'c.{c}' for c in calc] + ['b.updated_at']
        frm = f'vi_{code}_base b' + (f' LEFT JOIN vi_{code}_calc c ON c.id = b.id' if calc else '')
        out.append(f'DROP VIEW IF EXISTS vi_{code} CASCADE;')
        out.append(f'CREATE VIEW vi_{code} AS\nSELECT ' + ',\n       '.join(sel) + f'\nFROM {frm};')
        out.append(f"COMMENT ON VIEW vi_{code} IS {lit(t['title'] + '（界面视图：输入列＋自动计算列）')};")
        cols = ', '.join(editable)
        out.append(f'''CREATE OR REPLACE FUNCTION vi_{code}_dml() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO vi_{code}_base ({cols}) VALUES ({', '.join(write_values[c] for c in editable)}) RETURNING id INTO NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE vi_{code}_base SET {', '.join(f'{c} = {write_values[c]}' for c in editable)} WHERE id = OLD.id;
    RETURN NEW;
  ELSE
    DELETE FROM vi_{code}_base WHERE id = OLD.id;
    RETURN OLD;
  END IF;
END $$;''')
        out.append(f'CREATE TRIGGER vi_{code}_dml INSTEAD OF INSERT OR UPDATE OR DELETE ON vi_{code} '
                   f'FOR EACH ROW EXECUTE FUNCTION vi_{code}_dml();')
    out.append('COMMIT;')
    (OUT / '03_ui.sql').write_text('\n\n'.join(out) + '\n')


if __name__ == '__main__':
    OUT.mkdir(exist_ok=True)
    schema(); ui()
    print('generated 01_schema.sql 03_ui.sql')
