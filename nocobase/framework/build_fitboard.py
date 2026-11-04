"""“<公司> / 商业模式 / 价投适配度”顶部的结论看板：总分与归类、八个维度的分数条、强项与短板。
看板是一个 JS 区块，放在原有的适配度表格上方（同一列上下叠放），数据只读 vi_fit_score，页面本身不存内容。
归类与自动检查 C15 一致：32—40 适合复利框架，22—31 合适，21 及以下通常不符合价值投资标准。

  python3 build_fitboard.py              # 给所有公司的适配度页面加看板（已有的更新代码）
  python3 build_fitboard.py 600900.SH    # 只处理这家公司
build_pages.py 新建适配度页面时会自动调用 add_board。
"""
import json, subprocess, sys
import build_pages as bp

JS = r"""const COMPANY = '__COMPANY__';   // 由 build_fitboard.py 写入：只看这家公司的适配度
const { React } = ctx.libs;
const { Alert, Empty, theme } = ctx.libs.antd;

async function listRows(name, filter) {
  const resource = ctx.makeResource('MultiRecordResource');
  resource.setResourceName(name);
  resource.setPageSize?.(100);
  if (filter) resource.setFilter?.(filter);
  await resource.refresh();
  return resource.getData() || [];
}

// 与自动检查 C15 的归类一致
const BANDS = [
  { from: 0, to: 21, name: '不适合', text: '通常不符合价值投资标准' },
  { from: 22, to: 31, name: '合适', text: '合适，需说明更偏复利、现金流价值还是资产价值' },
  { from: 32, to: 40, name: '复利型', text: '适合价值投资复利框架（仍需价格安全边际）' },
];

function Board({ company, rows }) {
  const { token } = theme.useToken();
  const total = rows.reduce((a, r) => a + (Number(r.score) || 0), 0);
  const max = rows.length * 5 || 40;
  const scaled = max === 40 ? total : Math.round((total / max) * 40);
  const band = BANDS.find((b) => scaled >= b.from && scaled <= b.to) || BANDS[0];
  const tone = { 不适合: token.colorError, 合适: token.colorWarning, 复利型: token.colorSuccess };
  const soft = { 不适合: token.colorErrorBg, 合适: token.colorWarningBg, 复利型: token.colorSuccessBg };
  const color = (s) => (s >= 4 ? token.colorSuccess : s <= 2 ? token.colorError : token.colorTextSecondary);
  const strong = rows.filter((r) => Number(r.score) >= 4);
  const weak = rows.filter((r) => Number(r.score) <= 2);
  const list = (xs) => xs.map((r) => `${r.dimension} ${r.score}`).join('、');
  const narrow = (typeof window !== 'undefined' ? window.innerWidth : 1400) < 900;
  const label = { fontSize: 12, color: token.colorTextTertiary };
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 28, maxWidth: 1100 }}>
      {/* 结论：总分、归类、刻度、强项与短板 */}
      <div style={{ display: 'grid', gridTemplateColumns: narrow ? '1fr' : 'minmax(0, 1fr) minmax(0, 1fr)', gap: narrow ? 18 : 48, alignItems: 'end' }}>
        <div>
          <div style={label}>{company.name} · 价投适配度</div>
          <div style={{ display: 'flex', alignItems: 'baseline', gap: 10, marginTop: 4 }}>
            <span style={{ fontSize: 44, fontWeight: 600, lineHeight: 1.1, color: tone[band.name] }}>{total}</span>
            <span style={{ fontSize: 16, color: token.colorTextTertiary }}>/ {max}</span>
            <span style={{ fontSize: 13, fontWeight: 600, color: tone[band.name], background: soft[band.name], borderRadius: 4, padding: '2px 8px' }}>{band.name}</span>
          </div>
          <div style={{ fontSize: 13, color: token.colorTextSecondary, marginTop: 6, lineHeight: 1.6 }}>{band.text}</div>
        </div>
        <div>
          <div style={{ position: 'relative', paddingTop: 10 }}>
            <div style={{ display: 'flex', height: 8, borderRadius: 4, overflow: 'hidden' }}>
              {BANDS.map((b) => (
                <div key={b.name} style={{ flex: b.to - b.from + 1, background: b.name === band.name ? tone[b.name] : token.colorFillSecondary, opacity: b.name === band.name ? 0.85 : 1 }} />
              ))}
            </div>
            <div style={{ position: 'absolute', top: 0, left: `calc(${(Math.min(scaled, 40) / 41) * 100}% - 5px)`, width: 0, height: 0,
                          borderLeft: '5px solid transparent', borderRight: '5px solid transparent', borderTop: `7px solid ${token.colorText}` }} />
            <div style={{ display: 'flex', fontSize: 11, color: token.colorTextTertiary, marginTop: 6 }}>
              {BANDS.map((b) => <span key={b.name} style={{ flex: b.to - b.from + 1 }}>{b.name} {b.from === 0 ? `≤${b.to}` : b.to === 40 ? `${b.from}+` : `${b.from}–${b.to}`}</span>)}
            </div>
          </div>
          <div style={{ marginTop: 14, fontSize: 13, lineHeight: 1.9, color: token.colorTextSecondary }}>
            <div><span style={{ color: token.colorSuccess, fontWeight: 600, marginRight: 12 }}>强项</span>{strong.length ? list(strong) : '—'}</div>
            <div><span style={{ color: token.colorError, fontWeight: 600, marginRight: 12 }}>短板</span>{weak.length ? list(weak) : '—'}</div>
          </div>
        </div>
      </div>
      {/* 八个维度：分数、理由、反面，一行一个 */}
      <div>
        {!narrow ? (
          <div style={{ display: 'grid', gridTemplateColumns: '88px 150px 32px minmax(0, 1fr) minmax(0, 1fr)', gap: 20, padding: '0 0 8px', ...label,
                        borderBottom: `1px solid ${token.colorSplit}` }}>
            <span>维度</span><span>评分</span><span /><span>理由</span><span>反面</span>
          </div>
        ) : null}
        {rows.map((r) => {
          const s = Number(r.score) || 0;
          const bar = (
            <div style={{ display: 'flex', gap: 3, alignItems: 'center' }}>
              {[1, 2, 3, 4, 5].map((i) => (
                <span key={i} style={{ flex: 1, height: 6, borderRadius: 2, background: i <= s ? color(s) : token.colorFillSecondary }} />
              ))}
            </div>
          );
          return (
            <div key={r.id} style={{ display: 'grid', gridTemplateColumns: narrow ? '72px minmax(0, 1fr) 28px' : '88px 150px 32px minmax(0, 1fr) minmax(0, 1fr)',
                                     gap: narrow ? '6px 12px' : 20, padding: '12px 0', alignItems: 'baseline', borderBottom: `1px solid ${token.colorSplit}` }}>
              <span style={{ fontSize: 14, fontWeight: 500, color: token.colorText }}>{r.dimension}</span>
              <div style={{ alignSelf: 'center' }}>{bar}</div>
              <span style={{ fontSize: 16, fontWeight: 600, color: color(s), textAlign: 'right' }}>{r.score ?? '—'}</span>
              <div style={{ fontSize: 13, color: token.colorText, lineHeight: 1.65, gridColumn: narrow ? '1 / -1' : undefined }}>{r.rationale || '—'}</div>
              <div style={{ fontSize: 13, color: token.colorTextTertiary, lineHeight: 1.65, gridColumn: narrow ? '1 / -1' : undefined }}>
                {narrow && r.counter ? '反面：' : ''}{r.counter || '—'}
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}

try {
  const cos = await listRows('vi_company', { code: { $eq: COMPANY } });
  const company = cos[0];
  if (!company) {
    ctx.render(<Alert type="info" showIcon message={`公司表里没有代码为 ${COMPANY} 的公司`} />);
  } else {
    const rows = (await listRows('vi_fit_score', { company_id: { $eq: company.id } }))
      .sort((a, b) => (Number(a.sort) || 0) - (Number(b.sort) || 0));
    ctx.render(rows.length ? <Board company={company} rows={rows} /> : <Empty description="还没有评分：在下方表格里给八个维度各打 0—5 分" />);
  }
} catch (error) {
  ctx.render(<Alert type="error" showIcon message="适配度读取失败" description={String(error?.message || error)} />);
}
"""


def flow(action, body, tag):
    path = bp.HERE / 'blueprints' / f'fitboard_{tag}.json'
    path.parent.mkdir(exist_ok=True)
    path.write_text(json.dumps(body, ensure_ascii=False, indent=1))
    r = subprocess.run(['nb', 'api', 'flow-surfaces', action, '--body-file', str(path), '-j'], capture_output=True, text=True, cwd=bp.ROOT)
    if r.returncode:
        raise RuntimeError(f'{action}: {(r.stdout + r.stderr)[-1500:]}')
    return json.loads(r.stdout or '{}')


def grid_of(tree):
    """页面里放着表格区块的网格，以及它的全部区块。"""
    if isinstance(tree, dict):
        items = (tree.get('subModels') or {}).get('items')
        if isinstance(items, list) and any(isinstance(i, dict) and i.get('use') == 'TableBlockModel' for i in items):
            return tree['uid'], items
        for v in tree.values():
            hit = grid_of(v)
            if hit:
                return hit
    elif isinstance(tree, list):
        for v in tree:
            hit = grid_of(v)
            if hit:
                return hit
    return None


def add_board(co):
    key = f"fit_score@{co['code']}"
    if key not in bp.state()['pages']:
        return
    code = JS.replace('__COMPANY__', co['code'])
    grid, items = grid_of(bp.page_tree(key)['tree'])
    js = next((i['uid'] for i in items if i.get('use') == 'JSBlockModel'), None)
    if js:                                            # 已有看板：只更新代码
        flow('configure', {'target': {'uid': js}, 'changes': {'code': code, 'version': 'v2'}}, f"{co['code']}_configure")
    else:
        flow('add-block', {'target': {'uid': grid}, 'type': 'jsBlock', 'settings': {'code': code, 'version': 'v2'}}, f"{co['code']}_add")
        grid, items = grid_of(bp.page_tree(key)['tree'])
        js = next(i['uid'] for i in items if i.get('use') == 'JSBlockModel')
    table = next(i['uid'] for i in items if i.get('use') == 'TableBlockModel')
    flow('set-layout', {'target': {'uid': grid}, 'rows': {'row1': [[js, table]]}, 'sizes': {'row1': [24]}}, f"{co['code']}_layout")
    print(co['name'], '价投适配度看板 OK')


if __name__ == '__main__':
    want = set(sys.argv[1:])
    for co in bp.companies():
        if not want or co['code'] in want:
            add_board(co)
