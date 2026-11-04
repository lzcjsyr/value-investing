"""指标表格的“指标性质”列和“趋势”列：每个指标一行，把主口径最近 12 期（日度 60 个交易日）画成小折线。
趋势数据来自指标视图的计算列 trend（02_calc.sql 的 vi_metric_calc），列本身只负责画图，不另查数据。

  python3 trend_column.py          # 给线上所有指标表格补上这两列（已有的跳过；趋势列的代码按本文件更新）
"""
import json, subprocess
import build_pages as bp

TITLE = '趋势'
WIDTH = 170
CODE = r"""const raw = await ctx.getVar('ctx.record.trend');
let points = [];
try {
  points = JSON.parse(raw || '[]');
} catch (e) {
  points = [];
}
const rows = points.filter((p) => Number.isFinite(Number(p[1])));
if (rows.length < 2) {
  ctx.render(<span style={{ color: '#bfbfbf' }}>{rows.length ? `仅 ${rows[0][0]} 一期` : '—'}</span>);
  return;
}
const vals = rows.map((p) => Number(p[1]));
const W = 140;
const H = 30;
const pad = 3;
const min = Math.min(...vals);
const max = Math.max(...vals);
const span = max - min || 1;
const xy = vals.map((v, i) => [pad + (i * (W - 2 * pad)) / (vals.length - 1), H - pad - ((v - min) / span) * (H - 2 * pad)]);
const path = xy.map(([x, y], i) => `${i ? 'L' : 'M'}${x.toFixed(1)},${y.toFixed(1)}`).join(' ');
const last = xy[xy.length - 1];
const first = rows[0];
const end = rows[rows.length - 1];
const fmt = (v) => Number(v).toLocaleString('zh-CN', { maximumFractionDigits: 2 });
const tip = `${first[0]} → ${end[0]}：${fmt(first[1])} → ${fmt(end[1])}（共 ${rows.length} 期）`;
ctx.render(
  <div title={tip} style={{ lineHeight: 1 }}>
    <svg width={W} height={H} viewBox={`0 0 ${W} ${H}`} style={{ display: 'block' }}>
      <path d={path} fill="none" stroke="#5470c6" strokeWidth={1.5} strokeLinejoin="round" />
      <circle cx={last[0]} cy={last[1]} r={2.5} fill="#5470c6" />
    </svg>
    <div style={{ fontSize: 11, color: '#8c8c8c', marginTop: 2 }}>{`${first[0]}—${end[0]}`}</div>
  </div>,
);
"""


def columns(table_uid):
    tree = bp.nb_json('flow-surfaces', 'get', '--uid', table_uid)['data']
    tree = tree.get('tree', tree)
    return [(c['uid'], c['use'], c.get('stepParams', {}).get('fieldSettings', {}).get('init', {}).get('fieldPath'),
             c.get('stepParams', {}).get('tableColumnSettings', {}).get('title', {}).get('title'))
            for c in tree.get('subModels', {}).get('columns', [])]


def move_after(uid, anchor):
    bp.nb_json('flow-surfaces', 'move-node', '--source-uid', uid, '--target-uid', anchor, '--position', 'after')


# 「数据底稿 / 定量指标」各标签（区块 key，见 data_domains.TABS；supplement 是改版前的旧标签）：趋势列紧跟指标名称；其余指标表格放在最新值（及单位）后
NAME_FIRST = ('disclosed', 'auto', 'finance', 'market', 'supplement')


def ensure(table_uid, after=None):
    """一个指标表格：没有“指标性质”列就加在指标名称（或类别）后；趋势列放在 after 列后（默认：最新值及紧跟的单位后），代码按本文件更新。"""
    cols = columns(table_uid)
    paths = [c[2] for c in cols]
    done = []
    if 'measure' not in paths:
        new = bp.nb_json('flow-surfaces', 'add-field', '--target', json.dumps({'uid': table_uid}), '--field-path', 'measure')['data']['uid']
        anchor = next(c[0] for c in cols if c[2] == ('category' if 'category' in paths else 'name'))
        move_after(new, anchor)
        done.append('指标性质')
        cols = columns(table_uid)
        paths = [c[2] for c in cols]
    trend = next((c[0] for c in cols if c[1] == 'JSColumnModel' and c[3] == TITLE), None)
    if trend:
        bp.nb_json('flow-surfaces', 'configure', '--target', json.dumps({'uid': trend}),
                   '--changes', json.dumps({'code': CODE, 'version': 'v2'}, ensure_ascii=False))
    else:
        trend = bp.nb_json('flow-surfaces', 'add-field', '--target', json.dumps({'uid': table_uid}), '--type', 'jsColumn',
                           '--settings', json.dumps({'title': TITLE, 'width': WIDTH, 'code': CODE}, ensure_ascii=False))['data']['uid']
        done.append('趋势')
    cols = columns(table_uid)
    uids, paths = [c[0] for c in cols], [c[2] for c in cols]
    if after:
        anchor = uids[paths.index(after)]
    else:
        i = paths.index('latest_value')
        anchor = uids[i + 1] if i + 1 < len(uids) and paths[i + 1] == 'unit' else uids[i]
    if uids.index(trend) != uids.index(anchor) + 1:
        move_after(trend, anchor)
    return done


def main():
    out = subprocess.run([str(bp.ROOT / 'psql.sh'), '-At', '-c',
                          """SELECT uid FROM "flowModels" WHERE options->>'use' = 'TableBlockModel'
                             AND options#>>'{stepParams,resourceSettings,init,collectionName}' = 'vi_metric'"""],
                         capture_output=True, text=True, check=True).stdout.split()
    keys = dict(l.split('|') for l in subprocess.run([str(bp.ROOT / 'psql.sh'), '-At', '-c',
        """SELECT uid || '|' || coalesce(split_part(options#>>'{stepParams,__flowSurfaceMeta,declaredKey}', '.', 2), '') FROM "flowModels"
           WHERE options->>'use' = 'TableBlockModel' AND options#>>'{stepParams,resourceSettings,init,collectionName}' = 'vi_metric'"""],
        capture_output=True, text=True, check=True).stdout.split())
    for uid in out:
        print(uid, ensure(uid, 'name' if keys.get(uid) in NAME_FIRST else None) or '已有')


if __name__ == '__main__':
    main()
