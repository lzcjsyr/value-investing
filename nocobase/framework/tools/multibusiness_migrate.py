"""生成局部在线迁移：不重建其他公司的页面、预测或财务计算视图。

运行 python3 framework/tools/multibusiness_migrate.py，仅写 SQL，不执行。
"""
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / 'checks/multibusiness_20261026'

def bundle():
    sql = ROOT / 'framework/sql'
    chunks = ['BEGIN;']
    migration = (sql / 'migrations/2026-10-26c_multi_business.sql').read_text()
    chunks.append(migration.removeprefix('BEGIN;').removesuffix('COMMIT;\n'))
    chunks.append((sql / 'business_rules.sql').read_text())
    schema = (sql / '01_schema.sql').read_text()
    chunks.extend(line for line in schema.splitlines() if line.startswith('COMMENT ON') and
                  any(f'vi_{name}_base' in line for name in ['business','biz_model','sotp_segment','sotp_item']))
    calc = (sql / '02_calc.sql').read_text()
    for name in ['sotp_item_calc','sotp_segment_val','sotp']:
        match = re.search(rf'CREATE VIEW vi_{name} AS\n.*?;',calc,re.S)
        if not match: raise ValueError(name)
        chunks.append(match[0].replace('CREATE VIEW','CREATE OR REPLACE VIEW',1))
    ui = (sql / '03_ui.sql').read_text()
    for name in ['business','biz_model','sotp_segment','sotp_item']:
        start = ui.index(f'DROP VIEW IF EXISTS vi_{name} CASCADE;')
        end = ui.find('\nDROP VIEW IF EXISTS',start+1)
        if end<0: end=ui.rindex('COMMIT;')
        chunks.append(ui[start:end])
    chunks.append((ROOT/'companies/01810_小米集团/business_bridge.sql').read_text().removeprefix('BEGIN;\n').removesuffix('COMMIT;\n'))
    chunks.append('COMMIT;')
    return '\n\n'.join(chunks)

if __name__=='__main__':
    OUT.mkdir(parents=True,exist_ok=True)
    target=OUT/'migration.sql'; target.write_text(bundle()); print(target)
