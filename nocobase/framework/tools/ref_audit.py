"""正文编号引用体检：商业模式、论点、风险、假设依据等正文里写的编号（B3、V2、M1、T4、R2、J-WC、Q11……），
是否在这家公司的对应表里存在。只读在线库，不改任何数据。

  python3 tools/ref_audit.py            全部公司
  python3 tools/ref_audit.py 600900.SH  只查一家

“每个观点只写一处”靠编号互相引用；编号改了、删了，正文里的引用不会自动更新，用这个脚本找断链。
结构化关联（多对多）不在这里查，它们由外键保证。
"""
import pathlib, re, subprocess, sys
from collections import defaultdict

ROOT = pathlib.Path(__file__).resolve().parents[2]
# 编号前缀 → (表, 编号列)
TARGETS = {'B': ('biz_model', 'code'), 'V': ('value_chain', 'code'), 'M': ('moat', 'code'), 'T': ('thesis', 'code'),
           'R': ('risk', 'code'), 'J': ('judgment', 'code'), 'Q': ('issue', 'code')}
# 被扫描的正文列（表 → 列）
TEXT = {
    'biz_model': ['title', 'content', 'metric', 'trend'],
    'value_chain': ['role', 'analysis', 'counter', 'profit_share'],
    'competitor': ['strategy', 'vs_us'],
    'moat': ['mechanism', 'financial_link', 'evidence', 'counter', 'replication', 'threats'],
    'thesis': ['bull_case', 'bear_case', 'bull_rebuttal', 'bear_rebuttal', 'verdict', 'decisive_evidence', 'mind_changer', 'model_impact', 'external_view'],
    'risk': ['mechanism', 'impact_estimate', 'mitigants', 'early_warning', 'response'],
    'fit_score': ['rationale', 'counter'],
    'judgment': ['fact_layer', 'judgment', 'transmission', 'change_threshold', 'no_change_condition', 'counter_evidence'],
}
# J-XXX 的假设依据编号；其余是“字母＋数字”。前后不能紧挨字母数字（避免 B2B、5G、M2 芯片型号之类误报时仍可人工判断）
PAT = re.compile(r'(?<![A-Za-z0-9-])(J-[A-Z][A-Z0-9]*(?:-[A-Z0-9]+)*|[BVMTRQ]\d{1,2})(?![A-Za-z0-9])')
SEP = '\x1f'


def psql(sql):
    p = subprocess.run([str(ROOT / 'psql.sh'), '-At', '-F', SEP, '-c', sql], capture_output=True, text=True, check=True)
    return [line.split(SEP) for line in p.stdout.splitlines() if line]


def main(only=None):
    cos = psql("SELECT id, code, name FROM vi_company_base ORDER BY id")
    total = 0
    for cid, ccode, cname in cos:
        if only and ccode not in only:
            continue
        have = defaultdict(set)
        for t, col in set(TARGETS.values()):
            for (v,) in psql(f"SELECT {col} FROM vi_{t}_base WHERE company_id = {cid} AND {col} IS NOT NULL"):
                have[t].add(v)
        broken = defaultdict(set)       # 编号 → 出现在哪些行
        for t, cols in TEXT.items():
            label = 'name' if t == 'competitor' else 'dimension' if t == 'fit_score' else 'code'
            for row in psql(f"SELECT {label}, {', '.join(f'coalesce({c}, {chr(39)}{chr(39)})' for c in cols)} FROM vi_{t}_base WHERE company_id = {cid}"):
                key, text = row[0], ' '.join(row[1:])
                for ref in set(PAT.findall(text)):
                    tbl = TARGETS['J' if ref.startswith('J-') else ref[0]][0]
                    if ref not in have[tbl]:
                        broken[ref].add(f'{t}:{key}')
        print(f'{cname}（{ccode}）：' + ('无断链' if not broken else f'{len(broken)} 个编号找不到'))
        for ref in sorted(broken):
            print(f'  {ref:<10} 出现在 {"、".join(sorted(broken[ref]))}')
        total += len(broken)
    return total


if __name__ == '__main__':
    sys.exit(1 if main(set(sys.argv[1:]) or None) else 0)
