"""长江电力（600900.SH）→ 价值投资框架（vi_）的种子数据。

本项目独立运行，不依赖任何外部系统的数据（2026-10-24 起不再读取旧系统归档）：
  · data/base.json：指标、公司、来源文档、事实摘录、假设依据、财务数据、经营数据、采集配置、估值模型、情景、逐年假设、
    单参数试验、跟踪事项、问题清单、变更日志，以及它们之间的关联。字段与 vi_ 表一致，可以直接编辑。
  · data/observations.json：高频数据（长江电力股价、国债收益率、三峡水位与流量）；data/raw_capture.json：对应的原始采集记录。
  · analysis.py：商业模式分析（核心论点、商业模式拆解、产业链、竞争对手、壁垒、适配度），按业务键写入。
长江电力用固定 id，必须在 framework/sql/00_reset_data.sql 之后第一个灌入；之后各公司按业务键写入。
不要在在线库执行完整的 seed.sql（会清空全部 vi_ 数据）；在线库改内容用 analysis.sql 或迁移。
输出 seed.sql。
"""
import json, pathlib
import analysis   # 商业模式分析，按业务键写入

HERE = pathlib.Path(__file__).resolve().parent
DATA = HERE / 'data'
CO = 1  # 公司 id


def lit(v):
    if v is None:
        return 'NULL'
    if isinstance(v, bool):
        return 'TRUE' if v else 'FALSE'
    if isinstance(v, (int, float)):
        return repr(v)
    return "'" + str(v).replace("'", "''") + "'"


OUT = []


def ins(table, rows):
    if not rows:
        return
    cols = list(rows[0].keys())
    vals = ',\n'.join('(' + ', '.join(lit(r.get(c)) for c in cols) + ')' for r in rows)
    OUT.append(f'INSERT INTO vi_{table}_base ({", ".join(cols)}) VALUES\n{vals};')


def link(table, pairs):
    if pairs:
        a, b = list(pairs[0].keys())
        vals = ', '.join(f'({p[a]}, {p[b]}, now(), now())' for p in pairs)
        OUT.append(f'INSERT INTO {table} ({a}, {b}, "createdAt", "updatedAt") VALUES {vals};')


# 写入顺序按外键依赖：指标 → 公司 → 来源 → 事实 → 假设依据 → 历史数据 → 采集 → 模型 → 跟踪
ORDER = ['metric', 'company', 'source', 'fact', 'judgment', 'fin_history', 'period_data', 'collector',
         'model', 'scenario', 'forecast', 'trial', 'watch', 'issue', 'change_log']


def base():
    data = json.loads((DATA / 'base.json').read_text())
    # 指标与公司互相引用（公司的股价指标、指标所属公司）：先写指标（不带公司），写完公司再补回
    metric_co = {m['id']: m['company_id'] for m in data['metric']}
    ins('metric', [m | {'company_id': None} for m in data['metric']])
    ins('company', data['company'])
    for mid, cid in metric_co.items():
        if cid is not None:
            OUT.append(f'UPDATE vi_metric_base SET company_id = {cid} WHERE id = {mid};')
    for t in ORDER[2:]:
        if t == 'model':
            continue
        if t == 'collector':
            ins('collector', data['collector'])
            ins('raw_capture', json.loads((DATA / 'raw_capture.json').read_text()))
            ins('observation', json.loads((DATA / 'observations.json').read_text()))
            ins('model', data['model'])
            continue
        ins(t, data[t])
    for table, pairs in data['links'].items():
        link(table, pairs)


if __name__ == '__main__':
    OUT.append('BEGIN;')   # 先执行 framework/sql/00_reset_data.sql 清空全部数据；长江电力用固定 id，必须第一个灌入
    base()
    OUT.append('''DO $$ DECLARE r record; BEGIN FOR r IN SELECT tablename FROM pg_tables WHERE schemaname = 'public' AND tablename LIKE 'vi\\_%\\_base' LOOP
  EXECUTE format('SELECT setval(pg_get_serial_sequence(%L, ''id''), GREATEST((SELECT max(id) FROM %I), 1))', r.tablename, r.tablename);
END LOOP; END $$;''')
    OUT.extend(analysis.statements())   # 商业模式分析：按业务键写入，放在序列重置之后
    OUT.append('COMMIT;')
    (HERE / 'seed.sql').write_text('\n\n'.join(OUT) + '\n')
    print('seed.sql written,', sum(s.count('\n') for s in OUT), 'lines')
