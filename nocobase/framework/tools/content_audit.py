"""商业模式分析重构的核对工具：内容有没有丢、重复有没有减少。

  python3 tools/content_audit.py <公司代码> <重构前快照目录>

快照目录里是重构前导出的 db_<表>.json（每张表全部行的 JSON 数组）。
  1. 数字核对：重构前这家公司研究文字里出现的每个“带单位的数字”（44%、2.6 亿首、1,274 万……），
     重构后是否还出现在这家公司的任意研究文字里（商业模式分析九张表＋跟踪事项＋问题清单）。丢失的逐条列出，人工确认是有意删除还是漏了。
  2. 重复度：任意两行研究文字之间共有的长片段（≥ 18 个字符）有多少对，重构前后对比，并列出重构后最长的几处。
"""
import json, re, subprocess, sys, pathlib
from collections import defaultdict

ROOT = pathlib.Path(__file__).resolve().parents[2]
TEXT_TABLES = {   # 表 → 用来标识一行的列
    'thesis': 'code', 'debate': 'code', 'moat': 'code', 'biz_model': 'code', 'value_chain': 'code', 'competitor': 'name',
    'fit_score': 'dimension', 'judgment': 'code', 'fact': 'title', 'watch': 'code', 'issue': 'code',
}
SKIP = {'id', 'company_id', 'created_at', 'updated_at', 'source_id', 'metric_id', 'check_metric', 'check_op', 'check_threshold',
        'check_years', 'sort', 'debated_on', 'as_of', 'scale_value', 'paying_rate', 'gross_margin', 'growth', 'value'}
NUM = re.compile(r'(?<![\w.])[−\-+＋]?\d[\d,，]*(?:\.\d+)?\s*(?:%|％|亿|万|元|倍|首|家|台|辆|港元|美元|pt|个百分点|bp|米|千瓦时|吨)')


def psql_json(sql):
    p = subprocess.run([str(ROOT / 'psql.sh'), '-At', '-c', sql], capture_output=True, text=True, check=True)
    return json.loads(p.stdout.strip() or '[]')


def company_id(code):
    return psql_json(f"SELECT coalesce(json_agg(id), '[]') FROM vi_company_base WHERE code = '{code}'")[0]


def rows_before(snap, cid):
    out = []
    for t, key in TEXT_TABLES.items():
        f = snap / f'db_{t}.json'
        if f.exists():
            out += [(t, str(r.get(key)), r) for r in json.loads(f.read_text()) if r.get('company_id') == cid]
    return out


def rows_after(cid):
    out = []
    for t, key in TEXT_TABLES.items():
        if t == 'debate':
            continue
        rows = psql_json(f"SELECT coalesce(json_agg(row_to_json(x) ORDER BY x.id), '[]') FROM vi_{t}_base x WHERE company_id = {cid}")
        out += [(t, str(r.get(key)), r) for r in rows]
    return out


def texts(rows):
    """每行拼成一段文字（只取文本列）。"""
    return [(t, k, '｜'.join(str(v) for c, v in r.items() if c not in SKIP and isinstance(v, str) and v)) for t, k, r in rows]


def norm(n):
    return re.sub(r'[\s,，]', '', n).replace('％', '%').replace('−', '-').replace('＋', '+').lstrip('+')


def numbers(txt):
    return {norm(m) for m in NUM.findall(txt)}


def shared_fragments(rows, n=18):
    """两行之间共有的、长度≥n 的片段（按 n 字窗口找，合并成最长片段）。"""
    index = defaultdict(set)
    for i, (_, _, s) in enumerate(rows):
        for j in range(0, max(0, len(s) - n + 1)):
            index[s[j:j + n]].add(i)
    pairs = defaultdict(int)
    for frag, who in index.items():
        if len(who) > 1 and not re.fullmatch(r'[\W\d]+', frag):
            w = sorted(who)
            for a in range(len(w)):
                for b in range(a + 1, len(w)):
                    pairs[(w[a], w[b])] += 1
    return pairs


def main():
    code, snap = sys.argv[1], pathlib.Path(sys.argv[2])
    cid = company_id(code)
    before, after = texts(rows_before(snap, cid)), texts(rows_after(cid))
    nb_ = defaultdict(set)
    for t, k, s in before:
        for x in numbers(s):
            nb_[x].add(f'{t}:{k}')
    na = set().union(*[numbers(s) for _, _, s in after]) if after else set()
    lost = {x: w for x, w in nb_.items() if x not in na}
    print(f'== {code}：重构前 {len(before)} 行、{len(nb_)} 个带单位的数字；重构后 {len(after)} 行、{len(na)} 个')
    print(f'重构前出现、重构后找不到的数字：{len(lost)} 个')
    for x, w in sorted(lost.items(), key=lambda z: sorted(z[1])):
        print('  ', x, '←', '、'.join(sorted(w))[:160])
    pb, pa = shared_fragments(before), shared_fragments(after)
    print(f'行与行之间共有长片段（≥18 字）的行对：重构前 {len(pb)} 对，重构后 {len(pa)} 对')
    top = sorted(pa.items(), key=lambda z: -z[1])[:15]
    for (i, j), w in top:
        print(f'   {w:4d} 窗口  {after[i][0]}:{after[i][1]}  ↔  {after[j][0]}:{after[j][1]}')


if __name__ == '__main__':
    main()
