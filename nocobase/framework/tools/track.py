"""跟踪脚本（2026-11-05）：各公司要持续跟踪、但采集工作流抓不到的数（同业财报、行情历史、现货价、吨经济等）。

每家公司在 companies/<代码_名称>/track.py 里写清楚跟踪什么、从哪里取；本脚本统一取数、存快照、入库：
  python3 tools/track.py fetch [公司代码 ...]   取数 → companies/<公司>/data/track.json（快照，进 git）
  python3 tools/track.py load  [公司代码 ...]   快照 → 数据库
  python3 tools/track.py all   [公司代码 ...]   fetch + load（日常更新用这个；不带公司代码＝所有写了 track.py 的公司）
入库规则与种子相同（framework/data_layer_seed.track_statements，公司种子最后一步读同一份快照）：
  · 指标按 名称＋单位＋归属 定位，没有才建；宏观指标同时登记为这家公司“订阅的宏观数据”。
  · 公司指标的每期数据走 vi_put_disclosed（同期间同口径先删后写）；宏观日度行情只补库里没有的日期。
公司 track.py 的约定：
  METRICS：[{name, unit, category, source_kind, basis, frequency, measure, source_name, notes, macro?, code?(宏观必填)}]
  fetch(db) → [{name, unit, period, basis, obs_date, value, yoy?, summary?}]；db(sql) 读本库，返回行列表（'|' 分隔的字段）
  DAILY_NOTE（可选）：宏观日度行情补数的说明，写在每期数据的“说明”里
"""
import datetime, importlib.util, json, pathlib, subprocess, sys, warnings

HERE = pathlib.Path(__file__).resolve().parent
FRAMEWORK = HERE.parent
ROOT = FRAMEWORK.parent
sys.path.insert(0, str(FRAMEWORK))
sys.path.insert(0, str(HERE))      # 公司 track.py 可 import peer_stats 等共用函数
import data_layer_seed  # noqa: E402
warnings.filterwarnings('ignore')


def db(sql):
    p = subprocess.run([str(ROOT / 'psql.sh'), '-At', '-c', sql], capture_output=True, text=True, check=True)
    return [line.split('|') for line in p.stdout.splitlines() if line]


def companies():
    out = {}
    for d in sorted((ROOT / 'companies').iterdir()):
        if (d / 'track.py').exists():
            code = db(f"SELECT code FROM vi_company_base WHERE code LIKE '{d.name.split('_')[0]}.%'")
            if code:
                out[code[0][0]] = d
    return out


def module(d):
    spec = importlib.util.spec_from_file_location(f'track_{d.name}', d / 'track.py')
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    return m


def fetch(code, d):
    m = module(d)
    rows = m.fetch(db)
    names = {(x['name'], x['unit']) for x in m.METRICS}
    unknown = {(r['name'], r['unit']) for r in rows} - names
    if unknown:
        raise RuntimeError(f'{code} 取到未声明的指标：{sorted(unknown)}')
    snap = {'fetched_at': datetime.datetime.now().astimezone().isoformat(timespec='seconds'), 'metrics': m.METRICS,
            'daily_note': getattr(m, 'DAILY_NOTE', None), 'observations': rows}
    (d / 'data' / 'track.json').write_text(json.dumps(snap, ensure_ascii=False, indent=0))
    print(f'取数 {code}：{len(m.METRICS)} 个指标、{len(rows)} 期数据 → {d.name}/data/track.json')


def load(code, d):
    co = f"(SELECT id FROM vi_company_base WHERE code = '{code}')"
    sql = ['BEGIN;'] + data_layer_seed.track_statements(co, d / 'data' / 'track.json') + ['COMMIT;']
    tmp = pathlib.Path('/tmp') / f'track_{code}.sql'
    tmp.write_text('\n'.join(sql) + '\n')
    p = subprocess.run([str(ROOT / 'psql.sh'), '-f', str(tmp)], capture_output=True, text=True)
    errors = [l for l in (p.stdout + p.stderr).splitlines() if 'ERROR' in l]
    if errors:
        raise RuntimeError(f'{code} 入库失败：' + '\n'.join(errors[:5]))
    print(f'入库 {code}：{len(sql) - 2} 条语句')


def main():
    if len(sys.argv) < 2 or sys.argv[1] not in ('fetch', 'load', 'all'):
        sys.exit(__doc__)
    found = companies()
    codes = sys.argv[2:] or list(found)
    for code in codes:
        if code not in found:
            sys.exit(f'{code} 没有 track.py')
        if sys.argv[1] in ('fetch', 'all'):
            fetch(code, found[code])
        if sys.argv[1] in ('load', 'all'):
            load(code, found[code])


if __name__ == '__main__':
    main()
