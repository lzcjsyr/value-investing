"""上层判断的表单与详情里补“依据指标”（basis_metrics），放在“依据事实”后面；已有的跳过，可重复执行。

  python3 basis_metrics_fields.py            # 全部表单、详情区块
  python3 basis_metrics_fields.py <区块uid>  # 只处理这一个（试用）
"""
import json, subprocess, sys
import build_pages as bp
import spec

COLLECTIONS = [f"vi_{t['code']}" for t in spec.TABLES if any(f['name'] == 'basis_metrics' for f in spec.m2m_fields(t))]
USES = ('CreateFormModel', 'EditFormModel', 'DetailsBlockModel')


def items(block_uid):
    tree = bp.nb_json('flow-surfaces', 'get', '--uid', block_uid)['data']
    tree = tree.get('tree', tree)
    grid = tree.get('subModels', {}).get('grid', {})
    return [(i['uid'], i.get('stepParams', {}).get('fieldSettings', {}).get('init', {}).get('fieldPath'))
            for i in grid.get('subModels', {}).get('items', [])]


def ensure(block_uid):
    found = items(block_uid)
    paths = [p for _, p in found]
    if 'basis_metrics' in paths or 'facts' not in paths:
        return False
    new = bp.nb_json('flow-surfaces', 'add-field', '--target', json.dumps({'uid': block_uid}), '--field-path', 'basis_metrics')['data']['uid']
    bp.nb_json('flow-surfaces', 'move-node', '--source-uid', new, '--target-uid', next(u for u, p in found if p == 'facts'), '--position', 'after')
    return True


def blocks():
    colls = ','.join(f"'{c}'" for c in COLLECTIONS)
    uses = ','.join(f"'{u}'" for u in USES)
    out = subprocess.run([str(bp.ROOT / 'psql.sh'), '-At', '-c',
                          f"""SELECT uid FROM "flowModels" WHERE options->>'use' IN ({uses})
                              AND options#>>'{{stepParams,resourceSettings,init,collectionName}}' IN ({colls})"""],
                         capture_output=True, text=True, check=True).stdout.split()
    return out


if __name__ == '__main__':
    todo = sys.argv[1:] or blocks()
    added = sum(ensure(u) for u in todo)
    print(f'区块 {len(todo)} 个，新加“依据指标” {added} 个')
