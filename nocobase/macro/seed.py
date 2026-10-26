"""宏观数据（独立项目）→ 价值投资框架（vi_）的种子数据。

宏观数据＝不属于任何公司、各公司都可能用到的指标（vi_metric_base.company_id 为空）：利率、汇率、大宗商品等。
各公司按需使用：估值参数（无风险利率、股价汇率）与重点跟踪（假设依据、风险关联的指标）直接引用指标；其他想看的在公司表的“订阅的宏观数据”里订阅，
写在各公司自己的种子里（谁使用、谁声明）。用途汇总见视图 vi_company_metric。

  · data/base.json：指标定义与采集配置（字段与 vi_ 表一致，可直接编辑）；
  · data/observations.json：高频数据；data/raw_capture.json：对应的原始采集记录；
  · data/raw/：原始下载文件（Wind EDB 纸浆期货、腾讯外汇 K 线），只作出处留存，种子不读取。
使用固定 id：从零重建时在 framework/sql/00_reset_data.sql 之后第一个灌入（先于长江电力，长江电力也用固定 id）。
不要在在线库执行（会因主键冲突失败）；在线库改宏观数据直接在“宏观数据”菜单里改，或写迁移。
输出 seed.sql。
"""
import json, pathlib

HERE = pathlib.Path(__file__).resolve().parent
DATA = HERE / 'data'


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


if __name__ == '__main__':
    base = json.loads((DATA / 'base.json').read_text())
    OUT.append('BEGIN;')
    ins('metric', base['metric'])
    ins('collector', base['collector'])
    ins('raw_capture', json.loads((DATA / 'raw_capture.json').read_text()))
    ins('source', base.get('source', []))          # 历史补数的出处（数据关联来源文档）
    ins('observation', json.loads((DATA / 'observations.json').read_text()))
    OUT.append('COMMIT;')
    (HERE / 'seed.sql').write_text('\n\n'.join(OUT) + '\n')
    print('seed.sql written,', sum(s.count('\n') for s in OUT), 'lines')
