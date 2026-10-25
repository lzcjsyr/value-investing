"""逐行逐列对比：NocoBase 界面视图 cj_<code> 的计算列 vs 飞书导出的公式结果。

用法：python3 verify.py [--inputs]   （--inputs 同时核对输入列）
依赖当前时间的列（4.1 健康状态等）在飞书导出时刻与现在可能不同，单独标注。
"""
import json, subprocess, sys, pathlib, datetime, math
import spec

HERE = pathlib.Path(__file__).resolve().parent
TB = spec.table_by_code()
TIME_DEPENDENT = {('collect_ctl', 'health_status'), ('collect_ctl', 'needs_alert'), ('collect_ctl', 'notify_condition')}


def query(sql):
    p = subprocess.run([str(HERE.parent / 'psql.sh'), '-At', '-c', f'SELECT json_agg(t) FROM ({sql}) t'],
                       capture_output=True, text=True, check=True)
    return json.loads(p.stdout.strip() or 'null') or []


def norm(v, kind):
    if v in (None, '', []):
        return None
    if kind in ('num', 'int'):
        try:
            return float(v)
        except (TypeError, ValueError):
            return v
    if kind == 'bool':
        return str(v).lower() == 'true'
    if kind == 'ts':
        if isinstance(v, (int, float)) or (isinstance(v, str) and v.replace('.', '', 1).isdigit()):
            # 飞书公式里的日期时间以 Excel 序列日（1899-12-30 起，北京时间）表示
            base = datetime.datetime(1899, 12, 30, tzinfo=datetime.timezone(datetime.timedelta(hours=8)))
            return base + datetime.timedelta(days=float(v))
        return datetime.datetime.fromisoformat(str(v).replace('Z', '+00:00'))
    if kind == 'select' and isinstance(v, list):
        return v[0]
    return str(v)


def same(a, b, kind):
    if a is None or b is None:
        return a is None and b is None
    if kind in ('num', 'int') and isinstance(a, float) and isinstance(b, float):
        return math.isclose(a, b, rel_tol=1e-8, abs_tol=1e-6)
    if kind == 'ts':
        return abs((a - b).total_seconds()) < 1.5
    return a == b


def main():
    with_inputs = '--inputs' in sys.argv
    total = bad = 0
    report = []
    for tid, code, title, _ in spec.TABLES:
        cols = [(cn, en, k) for cn, en, k in spec.CALC.get(code, [])]
        if with_inputs:
            cols = [(cn, en, k) for cn, en, k in spec.INPUTS.get(code, [])] + cols
        if not cols:
            continue
        fei = {r['record_id']: r for r in (json.loads(x) for x in open(HERE / 'feishu_export' / f'{tid}.ndjson'))}
        rows = query(f'SELECT * FROM cj_{code}')
        missing = set(fei) - {r['feishu_id'] for r in rows}
        assert not missing, (code, '飞书记录在 NocoBase 中缺失', missing)
        added = [r for r in rows if not r['feishu_id']]
        if added:
            report.append(f'{title}: 迁移后新增 {len(added)} 行（不参与对比）')
        for row in (r for r in rows if r['feishu_id']):
            f = fei[row['feishu_id']]
            for cn, en, k in cols:
                total += 1
                a, b = norm(row[en], k), norm(f.get(cn), k)
                if not same(a, b, k):
                    tag = '（时间相关）' if (code, en) in TIME_DEPENDENT else ''
                    if not tag:
                        bad += 1
                    report.append(f'{title} #{row["id"]} {cn}{tag}: NocoBase={str(a)[:80]!r} 飞书={str(b)[:80]!r}')
    print('\n'.join(report if '--all' in sys.argv else report[:200]))
    print(f'核对 {total} 个单元格，不一致 {bad} 个（不含时间相关列）')
    return bad


if __name__ == '__main__':
    sys.exit(1 if main() else 0)
