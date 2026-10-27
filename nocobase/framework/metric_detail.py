"""指标详情弹窗：点开任何一个指标（「数据底稿 / 指标」「预测与估值 / 重点指标」）都看到同一个弹窗。
上：趋势图（按口径切换，默认主口径、最近 5 年）；中：逐期数据（录入的＋报表算的，标明取值来源）；下：录入新一期。
数据只读 vi_metric_value（存的数＋报表计算），录入写 vi_observation。弹窗用 ctx.popup.record 取打开它的那一行。
"""

JS = r"""const { React } = ctx.libs;
const { useState } = React;
const { Segmented, Table, Button, Input, InputNumber, Select, Space, Alert, Empty, Tag, theme, message } = ctx.libs.antd;
const BASES = ['时点', '单季', '半年累计', '前三季度累计', '全年', '年初至今累计', '滚动四季度'];

async function listRows(name, filter, pageSize = 2000) {
  const resource = ctx.makeResource('MultiRecordResource');
  resource.setResourceName(name);
  resource.setPageSize?.(pageSize);
  if (filter) resource.setFilter?.(filter);
  await resource.refresh();
  return resource.getData() || [];
}
const num = (v, d = 2) => (v === null || v === undefined || v === '' || Number.isNaN(Number(v)) ? '—'
  : Number(v).toLocaleString('zh-CN', { minimumFractionDigits: d, maximumFractionDigits: d }));
const digits = (vals) => { const m = Math.max(...vals.map((v) => Math.abs(Number(v) || 0))); return m >= 1000 ? 0 : m >= 100 ? 1 : 2; };
// 期间 → 期末日期：2026Q2、2026H1、2026、2026M09
function periodEnd(p) {
  const s = String(p || '').trim();
  let m;
  if ((m = s.match(/^(\d{4})Q([1-4])$/))) return `${m[1]}-${['03-31', '06-30', '09-30', '12-31'][m[2] - 1]}`;
  if ((m = s.match(/^(\d{4})H1$/))) return `${m[1]}-06-30`;
  if ((m = s.match(/^(\d{4})M(\d{2})$/))) { const d = new Date(Number(m[1]), Number(m[2]), 0); return `${m[1]}-${m[2]}-${String(d.getDate()).padStart(2, '0')}`; }
  if ((m = s.match(/^(\d{4})$/))) return `${m[1]}-12-31`;
  return null;
}

function Chart({ points, unit, token }) {
  if (points.length < 2) return <Empty image={Empty.PRESENTED_IMAGE_SIMPLE} description="这个口径的数据不足两期，画不出趋势" />;
  const W = 760, H = 220, L = 56, R = 16, T = 14, B = 34;
  const vals = points.map((p) => Number(p.value));
  let lo = Math.min(...vals), hi = Math.max(...vals);
  if (lo === hi) { lo -= 1; hi += 1; }
  const pad = (hi - lo) * 0.08; lo -= pad; hi += pad;
  const x = (i) => L + (i * (W - L - R)) / (points.length - 1);
  const y = (v) => T + ((hi - v) * (H - T - B)) / (hi - lo);
  const d = digits(vals);
  const ticks = [0, 1, 2, 3].map((k) => lo + ((hi - lo) * k) / 3);
  const every = Math.max(1, Math.ceil(points.length / 8));
  const path = points.map((p, i) => `${i ? 'L' : 'M'}${x(i).toFixed(1)},${y(Number(p.value)).toFixed(1)}`).join(' ');
  return (
    <svg viewBox={`0 0 ${W} ${H}`} style={{ width: '100%', maxWidth: W, height: 'auto', display: 'block' }}>
      {ticks.map((t, k) => (
        <g key={k}>
          <line x1={L} x2={W - R} y1={y(t)} y2={y(t)} stroke={token.colorSplit} />
          <text x={L - 8} y={y(t) + 4} fontSize="11" textAnchor="end" fill={token.colorTextTertiary}>{num(t, d)}</text>
        </g>
      ))}
      <path d={path} fill="none" stroke={token.colorPrimary} strokeWidth="2" />
      {points.map((p, i) => (
        <g key={p.id}>
          <circle cx={x(i)} cy={y(Number(p.value))} r="3.5" fill={p.origin === '录入' ? token.colorPrimary : '#fff'} stroke={token.colorPrimary} strokeWidth="1.5">
            <title>{`${p.period}：${num(p.value, d)} ${unit || ''}${p.yoy !== null && p.yoy !== undefined ? `（同比 ${num(p.yoy * 100, 1)}%）` : ''}｜${p.origin}`}</title>
          </circle>
          {(i % every === 0 || i === points.length - 1)
            ? <text x={x(i)} y={H - 12} fontSize="11" textAnchor="middle" fill={token.colorTextTertiary}>{p.period}</text> : null}
        </g>
      ))}
    </svg>
  );
}

function Panel({ metric, rows, reload }) {
  const { token } = theme.useToken();
  const bases = BASES.filter((b) => rows.some((r) => r.basis === b));
  const [basis, setBasis] = useState(bases.includes(metric.basis) ? metric.basis : bases[0]);
  const [range, setRange] = useState('近 5 年');
  const [form, setForm] = useState({ basis: metric.basis || '时点' });
  const [saving, setSaving] = useState(false);
  const cut = new Date(); cut.setFullYear(cut.getFullYear() - 5);
  const series = rows.filter((r) => r.basis === basis).sort((a, b) => String(a.obs_date).localeCompare(String(b.obs_date)));
  const shown = range === '全部' ? series : series.filter((r) => new Date(r.obs_date) >= cut);
  const d = digits(rows.map((r) => r.value));
  const latest = series[series.length - 1];
  const add = async () => {
    const end = periodEnd(form.period);
    if (!end) { message.warning('期间写成 2026Q3、2026H1、2026 或 2026M09'); return; }
    if (form.value === undefined || form.value === null || form.value === '') { message.warning('请填写数值'); return; }
    setSaving(true);
    try {
      await ctx.request({ url: 'vi_observation:create', method: 'post', data: {
        metric_id: metric.id, period: form.period.trim(), basis: form.basis, obs_date: end, value: form.value,
        yoy: form.yoy === undefined || form.yoy === null ? null : form.yoy / 100, summary: form.summary || null, collected_at: new Date().toISOString() } });
      message.success(`已录入 ${form.period} ${form.basis}`);
      setForm({ basis: form.basis });
      await reload();
    } catch (e) {
      message.error('录入失败：' + String(e?.response?.data?.errors?.[0]?.message || e?.message || e));
    } finally { setSaving(false); }
  };
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
      <div style={{ display: 'flex', flexWrap: 'wrap', alignItems: 'baseline', gap: 16 }}>
        <span style={{ fontSize: 16, fontWeight: 600 }}>{metric.name}</span>
        {latest ? <span style={{ color: token.colorTextSecondary }}>最新 {latest.period}：<b style={{ color: token.colorText }}>{num(latest.value, d)}</b> {metric.unit || ''}
          {latest.yoy !== null && latest.yoy !== undefined ? `（同比 ${num(latest.yoy * 100, 1)}%）` : ''}</span> : null}
        {metric.source_kind === '报表计算' ? <Tag>报表计算：{metric.formula}</Tag> : <Tag>{metric.source_kind}</Tag>}
      </div>
      {rows.length === 0 ? <Empty description="还没有数据：在下面录入第一期" /> : (
        <>
          <Space wrap>
            {bases.length > 1 ? <Segmented options={bases} value={basis} onChange={setBasis} /> : <Tag>{basis}</Tag>}
            <Segmented options={['近 5 年', '全部']} value={range} onChange={setRange} />
            <span style={{ fontSize: 12, color: token.colorTextTertiary }}>实心点＝录入的数，空心点＝报表算出的数</span>
          </Space>
          <Chart points={shown} unit={metric.unit} token={token} />
          <Table size="small" rowKey="id" pagination={{ pageSize: 8, size: 'small' }}
            dataSource={series.slice().reverse()} columns={[
              { title: '期间', dataIndex: 'period', width: 100 },
              { title: `数值（${metric.unit || ''}）`, dataIndex: 'value', align: 'right', width: 120, render: (v) => num(v, d) },
              { title: '同比', dataIndex: 'yoy', align: 'right', width: 90, render: (v) => (v === null || v === undefined ? '—' : `${num(v * 100, 1)}%`) },
              { title: '取值', dataIndex: 'origin', width: 90, render: (v) => <Tag color={v === '录入' ? 'blue' : 'default'}>{v}</Tag> },
              { title: '说明', dataIndex: 'summary', ellipsis: true },
              { title: '来源文档', dataIndex: 'doc_title', ellipsis: true, width: 200 },
            ]} />
        </>
      )}
      {metric.source_kind === '自动采集' ? null : (
        <div style={{ borderTop: `1px solid ${token.colorSplit}`, paddingTop: 12 }}>
          <div style={{ fontSize: 13, fontWeight: 600, marginBottom: 8 }}>
            录入一期{metric.source_kind === '报表计算' ? '（报表计算的指标：录入的数会覆盖报表算出的同期数，用于追溯调整或口径不同的年份）' : ''}
          </div>
          <Space wrap>
            <Input style={{ width: 130 }} placeholder="期间，如 2026Q3" value={form.period} onChange={(e) => setForm({ ...form, period: e.target.value })} />
            <Select style={{ width: 130 }} options={BASES.map((b) => ({ value: b, label: b }))} value={form.basis} onChange={(v) => setForm({ ...form, basis: v })} />
            <InputNumber style={{ width: 140 }} placeholder={`数值（${metric.unit || ''}）`} value={form.value} onChange={(v) => setForm({ ...form, value: v })} />
            <InputNumber style={{ width: 120 }} placeholder="同比 %" value={form.yoy} onChange={(v) => setForm({ ...form, yoy: v })} />
            <Input style={{ width: 260 }} placeholder="说明（可选）" value={form.summary} onChange={(e) => setForm({ ...form, summary: e.target.value })} />
            <Button type="primary" loading={saving} onClick={add}>录入</Button>
          </Space>
        </div>
      )}
    </div>
  );
}

try {
  const rec = await ctx.getVar('ctx.popup.record');
  const id = rec?.id;
  if (!id) {
    ctx.render(<Alert type="info" showIcon message="没有拿到指标" />);
  } else {
    async function load() {
      const [metric] = await listRows('vi_metric', { id: { $eq: id } }, 1);
      const rows = await listRows('vi_metric_value', { metric_id: { $eq: id } });
      ctx.render(<Panel key={rows.length} metric={metric || rec} rows={rows} reload={load} />);
    }
    await load();
  }
} catch (error) {
  ctx.render(<Alert type="error" showIcon message="指标趋势读取失败" description={String(error?.message || error)} />);
}
"""

DETAIL_FIELDS = ['name', 'category', 'unit', 'basis', 'source_kind', 'formula', 'model_field', 'frequency', 'source_name', 'tracked_by', 'notes']


def view_action(page_title):
    """表格行的“查看”：趋势与逐期数据（脚本区块）＋ 指标信息（详情区块）。"""
    return {'type': 'view', 'popup': {'title': f'{page_title} · 指标详情', 'blocks': [
        {'key': 'trend', 'type': 'jsBlock', 'script': 'metric_trend'},
        {'key': 'info', 'type': 'details', 'resource': {'binding': 'currentRecord', 'collectionName': 'vi_metric'},
         'fieldGroups': [{'title': '指标信息', 'fields': DETAIL_FIELDS}]}]}}


ASSETS = {'scripts': {'metric_trend': {'version': 'v2', 'code': JS}}}
