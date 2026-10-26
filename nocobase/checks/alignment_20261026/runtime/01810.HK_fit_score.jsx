export default async function run(ctx) {
const COMPANY = '01810.HK';   // 由 build_fitboard.py 写入：只看这家公司的适配度
const { React } = ctx.libs;
const { Tooltip, Alert, Empty, theme } = ctx.libs.antd;

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
  { from: 22, to: 31, name: '可研究', text: '可研究，需说明更偏复利、现金流价值还是资产价值' },
  { from: 32, to: 40, name: '复利型', text: '适合价值投资复利框架（仍需价格安全边际）' },
];

function Board({ company, rows }) {
  const { token } = theme.useToken();
  const total = rows.reduce((a, r) => a + (Number(r.score) || 0), 0);
  const max = rows.length * 5 || 40;
  const scaled = max === 40 ? total : Math.round((total / max) * 40);
  const band = BANDS.find((b) => scaled >= b.from && scaled <= b.to) || BANDS[0];
  const tone = { 不适合: token.colorError, 可研究: token.colorWarning, 复利型: token.colorSuccess };
  const soft = { 不适合: token.colorErrorBg, 可研究: token.colorWarningBg, 复利型: token.colorSuccessBg };
  const color = (s) => (s >= 4 ? token.colorSuccess : s <= 2 ? token.colorError : token.colorTextSecondary);
  const strong = rows.filter((r) => Number(r.score) >= 4);
  const weak = rows.filter((r) => Number(r.score) <= 2);
  const list = (xs) => xs.map((r) => `${r.dimension} ${r.score}`).join('、');
  const narrow = (typeof window !== 'undefined' ? window.innerWidth : 1400) < 900;
  return (
    <div style={{ display: 'grid', gridTemplateColumns: narrow ? '1fr' : 'minmax(260px, 1fr) minmax(0, 2fr)', gap: narrow ? 20 : 40, alignItems: 'center' }}>
      {/* 左：总分与归类 */}
      <div>
        <div style={{ fontSize: 12, color: token.colorTextTertiary }}>{company.name} · 价投适配度</div>
        <div style={{ display: 'flex', alignItems: 'baseline', gap: 10, marginTop: 4 }}>
          <span style={{ fontSize: 44, fontWeight: 600, lineHeight: 1.1, color: tone[band.name] }}>{total}</span>
          <span style={{ fontSize: 16, color: token.colorTextTertiary }}>/ {max}</span>
          <span style={{ fontSize: 13, fontWeight: 600, color: tone[band.name], background: soft[band.name], borderRadius: 4, padding: '2px 8px' }}>{band.name}</span>
        </div>
        <div style={{ fontSize: 13, color: token.colorTextSecondary, marginTop: 6, lineHeight: 1.6 }}>{band.text}</div>
        {/* 归类刻度：三段，标出当前分数 */}
        <div style={{ position: 'relative', marginTop: 14, paddingTop: 10 }}>
          <div style={{ display: 'flex', height: 6, borderRadius: 3, overflow: 'hidden' }}>
            {BANDS.map((b) => (
              <div key={b.name} style={{ flex: b.to - b.from + 1, background: b.name === band.name ? tone[b.name] : token.colorFillSecondary, opacity: b.name === band.name ? 0.85 : 1 }} />
            ))}
          </div>
          <div style={{ position: 'absolute', top: 0, left: `calc(${(Math.min(scaled, 40) / 41) * 100}% - 5px)`, width: 0, height: 0,
                        borderLeft: '5px solid transparent', borderRight: '5px solid transparent', borderTop: `7px solid ${token.colorText}` }} />
          <div style={{ display: 'flex', fontSize: 11, color: token.colorTextTertiary, marginTop: 4 }}>
            {BANDS.map((b) => <span key={b.name} style={{ flex: b.to - b.from + 1 }}>{b.name} {b.from === 0 ? `≤${b.to}` : b.to === 40 ? `${b.from}+` : `${b.from}–${b.to}`}</span>)}
          </div>
        </div>
      </div>
      {/* 右：八个维度 */}
      <div>
        <div style={{ display: 'grid', gridTemplateColumns: narrow ? 'repeat(2, minmax(0,1fr))' : 'repeat(4, minmax(0,1fr))', gap: '14px 24px' }}>
          {rows.map((r) => {
            const s = Number(r.score) || 0;
            return (
              <Tooltip key={r.id} title={<div style={{ maxWidth: 360 }}><div>{r.rationale}</div>{r.counter ? <div style={{ marginTop: 6, opacity: 0.8 }}>反面：{r.counter}</div> : null}</div>}>
                <div style={{ cursor: 'help', minWidth: 0 }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline' }}>
                    <span style={{ fontSize: 13, color: token.colorText }}>{r.dimension}</span>
                    <span style={{ fontSize: 15, fontWeight: 600, color: color(s) }}>{r.score ?? '—'}</span>
                  </div>
                  <div style={{ display: 'flex', gap: 3, marginTop: 5 }}>
                    {[1, 2, 3, 4, 5].map((i) => (
                      <span key={i} style={{ flex: 1, height: 5, borderRadius: 2, background: i <= s ? color(s) : token.colorFillSecondary }} />
                    ))}
                  </div>
                </div>
              </Tooltip>
            );
          })}
        </div>
        <div style={{ marginTop: 16, fontSize: 13, color: token.colorTextSecondary, lineHeight: 1.7 }}>
          {strong.length ? <span><span style={{ color: token.colorSuccess, fontWeight: 600 }}>强项</span>　{list(strong)}</span> : null}
          {strong.length && weak.length ? <span style={{ margin: '0 12px', color: token.colorSplit }}>|</span> : null}
          {weak.length ? <span><span style={{ color: token.colorError, fontWeight: 600 }}>短板</span>　{list(weak)}</span> : null}
          <span style={{ marginLeft: 12, color: token.colorTextQuaternary }}>悬停维度看理由与反面</span>
        </div>
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
    ctx.render(rows.length ? <Board company={company} rows={rows} /> : <Empty description="还没有评分：在“明细（编辑）”标签里给八个维度各打 0—5 分" />);
  }
} catch (error) {
  ctx.render(<Alert type="error" showIcon message="适配度读取失败" description={String(error?.message || error)} />);
}

}
