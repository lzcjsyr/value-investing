const { React, antd } = ctx.libs;
const { Segmented, Alert, Typography, Tag, theme } = antd;
const { Text, Link } = Typography;

const known = (x) => x !== null && x !== undefined && x !== '' && Number.isFinite(Number(x));
const fmt = (x, d = 2) =>
  known(x) ? Number(x).toLocaleString('zh-CN', { minimumFractionDigits: d, maximumFractionDigits: d }) : '—';
const signedFmt = (x, d = 2) => {
  if (!known(x)) return '—';
  const n = Number(x);
  return (n > 0 ? '+' : '') + n.toLocaleString('zh-CN', { minimumFractionDigits: d, maximumFractionDigits: d });
};
const sumKnown = (rows, key) =>
  rows.length && rows.every((r) => known(r[key])) ? rows.reduce((s, r) => s + Number(r[key]), 0) : null;
const sumAny = (rows, fn) => rows.reduce((s, r) => s + (Number(fn(r)) || 0), 0);

async function list(name, filter, appends = []) {
  const res = ctx.makeResource('MultiRecordResource');
  res.setResourceName(name);
  res.setFilter(filter);
  res.setPageSize(300);
  if (appends.length && res.setAppends) res.setAppends(appends);
  await res.refresh();
  return res.getData() || [];
}

async function load() {
  const [co] = await list('vi_company', { code: { $eq: '01698.HK' } });
  const scope = { company_id: { $eq: co.id } };
  const [raw, items, values, checks] = await Promise.all([
    list('vi_fin_stmt', { ...scope, period_end: { $eq: co.as_of }, stmt: { $eq: '资产负债表' } }),
    list('vi_bs_item', scope, ['judgments']),
    list('vi_gw_value', scope),
    list('vi_check', scope),
  ]);
  return { co, raw: raw.sort((a, b) => a.seq - b.seq), items, v: values[0], checks };
}

const MAJOR_TOTALS = new Set(['总资产', '总负债', '净资产', '归属于母公司股东权益合计']);
const SUB_TOTALS = new Set(['非流动资产合计', '流动资产合计', '流动负债合计', '非流动负债合计']);
const IDENTITY_ROWS = new Set([
  '净流动资产',
  '总资产减流动负债',
  '股本',
  '保留盈利',
  '资本公积',
  '其他储备',
  '库存股',
  '股份激励计划持股',
  '总权益',
  '总权益及非流动负债',
  '总权益及总负债',
]);
const CONTROLS = new Set([...MAJOR_TOTALS, ...SUB_TOTALS, ...IDENTITY_ROWS]);
const CASH_ITEMS = new Set(['现金及现金等价物', '短期存款', '中长期存款', '短期投资']);
const LT_OP_ITEMS = new Set(['物业厂房及设备', '使用权资产', '无形资产', '土地使用权']);

const style = `
.tme-av {
  max-width: 1180px;
  margin: 0 auto;
  padding: 4px 4px 24px;
  color: var(--ink);
  font-variant-numeric: tabular-nums;
  line-height: 1.55;
  container-type: inline-size;
}
.tme-av * { box-sizing: border-box; }
.tme-av h2, .tme-av h3, .tme-av h4, .tme-av p { margin: 0; }

/* 1. Hero 结论主焦区 */
.tme-av .av-hero {
  display: grid;
  grid-template-columns: minmax(0, 1.12fr) minmax(0, 1fr);
  gap: 20px;
  padding: 20px 24px;
  background: var(--tint);
  border: 1px solid var(--line);
  border-radius: 12px;
  align-items: center;
}
.tme-av .av-eyebrow {
  font-size: 13px;
  color: var(--muted);
  font-weight: 500;
  letter-spacing: 0.2px;
}
.tme-av .av-hero-num-row {
  display: flex;
  align-items: baseline;
  gap: 8px;
  margin: 4px 0 8px;
  flex-wrap: wrap;
}
.tme-av .av-hero-num {
  font-size: clamp(34px, 4.6cqw, 46px);
  font-weight: 700;
  letter-spacing: -1.4px;
  line-height: 1.15;
  color: var(--ink);
}
.tme-av .av-hero-unit {
  font-size: 16px;
  font-weight: 600;
  color: var(--muted);
}
.tme-av .av-hero-badges {
  display: flex;
  flex-wrap: wrap;
  gap: 8px 14px;
  font-size: 13.5px;
  color: var(--muted);
}
.tme-av .av-hero-badges b {
  color: var(--ink);
  font-weight: 600;
}
.tme-av .av-verdict {
  background: var(--card);
  border: 1px solid var(--line);
  border-left: 4px solid var(--primary);
  border-radius: 10px;
  padding: 14px 16px;
}
.tme-av .av-verdict-title {
  font-size: 13px;
  font-weight: 600;
  color: var(--primary);
  margin-bottom: 10px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 8px;
}
.tme-av .av-cmp-row {
  display: grid;
  grid-template-columns: 112px 1fr auto;
  align-items: center;
  gap: 10px;
  font-size: 13px;
  margin-bottom: 7px;
}
.tme-av .av-cmp-track {
  height: 8px;
  background: var(--track);
  border-radius: 999px;
  overflow: hidden;
}
.tme-av .av-cmp-fill {
  height: 100%;
  border-radius: 999px;
}
.tme-av .av-verdict-note {
  margin-top: 8px;
  padding-top: 8px;
  border-top: 1px dashed var(--line);
  font-size: 12.5px;
  color: var(--muted);
  line-height: 1.55;
}

/* 2. 桥接瀑布与全景切分 */
.tme-av .av-section {
  margin-top: 16px;
  background: var(--card);
  border: 1px solid var(--line);
  border-radius: 12px;
  padding: 16px 20px;
}
.tme-av .av-sec-head {
  display: flex;
  justify-content: space-between;
  align-items: baseline;
  flex-wrap: wrap;
  gap: 8px 16px;
  margin-bottom: 12px;
}
.tme-av .av-sec-head h3 {
  font-size: 15.5px;
  font-weight: 600;
}
.tme-av .av-sec-sub {
  font-size: 12.5px;
  color: var(--muted);
}
.tme-av .av-steps {
  display: grid;
  grid-template-columns: repeat(5, minmax(0, 1fr));
  gap: 10px;
}
.tme-av .av-step {
  position: relative;
  border: 1px solid var(--line);
  border-radius: 10px;
  padding: 11px 13px;
  background: var(--tint-soft);
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}
.tme-av .av-step.is-adjust {
  background: var(--purple-bg);
  border-color: var(--purple-bd);
}
.tme-av .av-step.is-haircut {
  background: var(--warn-bg);
  border-color: var(--warn-bd);
}
.tme-av .av-step.is-final {
  background: var(--primary-bg);
  border-color: var(--primary-bd);
}
.tme-av .av-step-label {
  font-size: 12.5px;
  color: var(--muted);
  font-weight: 500;
}
.tme-av .av-step-val {
  font-size: 22px;
  font-weight: 700;
  letter-spacing: -0.5px;
  margin: 4px 0;
  line-height: 1.2;
}
.tme-av .av-step.is-haircut .av-step-val { color: var(--warn); }
.tme-av .av-step.is-adjust .av-step-val { color: var(--purple); }
.tme-av .av-step.is-final .av-step-val { color: var(--primary); }
.tme-av .av-step-desc {
  font-size: 12px;
  color: var(--muted);
  line-height: 1.4;
}

.tme-av .av-split-bar-wrap {
  margin-top: 14px;
  padding-top: 12px;
  border-top: 1px solid var(--line);
}
.tme-av .av-split-bar {
  display: flex;
  height: 10px;
  border-radius: 999px;
  overflow: hidden;
  background: var(--track);
  gap: 2px;
}
.tme-av .av-split-legend {
  display: flex;
  justify-content: space-between;
  flex-wrap: wrap;
  gap: 6px 16px;
  margin-top: 8px;
  font-size: 12.5px;
  color: var(--muted);
}
.tme-av .av-split-legend b { color: var(--ink); }
.tme-av .av-dot {
  display: inline-block;
  width: 8px;
  height: 8px;
  border-radius: 50%;
  margin-right: 6px;
  vertical-align: -0.5px;
}

/* 3. 双栏关键抓手卡 */
.tme-av .av-grid-2 {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 16px;
  margin-top: 16px;
}
.tme-av .av-card {
  background: var(--card);
  border: 1px solid var(--line);
  border-radius: 12px;
  padding: 16px 20px;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}
.tme-av .av-kv-list {
  display: flex;
  flex-direction: column;
  gap: 7px;
  margin: 6px 0 10px;
}
.tme-av .av-kv {
  display: grid;
  grid-template-columns: minmax(0, 1.3fr) auto;
  gap: 12px;
  align-items: baseline;
  font-size: 13px;
  padding: 5px 0;
  border-bottom: 1px dashed var(--line-soft);
}
.tme-av .av-kv:last-child { border-bottom: 0; }
.tme-av .av-kv-sub {
  font-size: 12px;
  color: var(--muted);
  margin-left: 6px;
}
.tme-av .av-cash-boxes {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 10px;
  margin: 8px 0 10px;
}
.tme-av .av-cash-box {
  background: var(--tint-soft);
  border: 1px solid var(--line);
  border-radius: 8px;
  padding: 9px 12px;
}
.tme-av .av-cash-box.is-op {
  background: var(--purple-bg);
  border-color: var(--purple-bd);
}
.tme-av .av-cash-box.is-br {
  background: var(--info-bg);
  border-color: var(--info-bd);
}
.tme-av .av-cash-box span {
  display: block;
  font-size: 12px;
  color: var(--muted);
}
.tme-av .av-cash-box strong {
  display: block;
  font-size: 19px;
  font-weight: 700;
  margin-top: 2px;
}

/* 优雅折叠面板 */
.tme-av details.av-fold {
  border-top: 1px solid var(--line-soft);
  margin-top: 6px;
}
.tme-av details.av-fold > summary {
  cursor: pointer;
  list-style: none;
  padding: 8px 0 2px;
  font-size: 12.5px;
  color: var(--primary);
  font-weight: 500;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
}
.tme-av details.av-fold > summary::-webkit-details-marker { display: none; }
.tme-av details.av-fold > summary::after {
  content: '▾';
  font-size: 13px;
  color: var(--muted);
  transition: transform 0.15s ease;
}
.tme-av details.av-fold[open] > summary::after { transform: rotate(180deg); }
.tme-av .av-fold-body {
  padding: 8px 0 4px;
  font-size: 12.5px;
  color: var(--muted);
  line-height: 1.65;
}
.tme-av .av-fold-body p + p { margin-top: 5px; }

/* 4. 逐项归类与重估底稿表 */
.tme-av .av-toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 10px 16px;
  margin-bottom: 10px;
}
.tme-av .av-legend-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 8px 16px;
  padding: 8px 12px;
  background: var(--tint-soft);
  border-radius: 8px;
  margin-bottom: 12px;
  font-size: 12.5px;
  color: var(--muted);
}
.tme-av .av-legend-items {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 6px 10px;
}
.tme-av .av-pill {
  display: inline-flex;
  align-items: center;
  gap: 5px;
  font-size: 12px;
  line-height: 1.35;
  padding: 2px 8px;
  border-radius: 999px;
  font-weight: 500;
  white-space: nowrap;
  border: 1px solid transparent;
}
.tme-av .av-pill.p-adjust {
  color: var(--warn);
  border: 1px dashed var(--warn-bd);
  font-weight: 600;
}
.tme-av .av-pill .av-pill-layer {
  font-size: 16px;
  font-weight: 800;
  line-height: 1;
}
.tme-av .av-pill.p-split, .tme-av .av-pill.p-transfer {
  background: var(--purple-bg);
  color: var(--purple);
  border-color: var(--purple-bd);
}
.tme-av .av-pill.p-keep {
  background: transparent;
  color: var(--muted);
  border-color: var(--line);
}
.tme-av .av-pill.p-pending {
  background: var(--err-bg);
  color: var(--err);
  border-color: var(--err-bd);
  font-weight: 600;
}

.tme-av .av-table-wrap {
  overflow-x: auto;
  border: 1px solid var(--line);
  border-radius: 10px;
}
.tme-av table.av-table {
  width: 100%;
  min-width: 940px;
  border-collapse: collapse;
  font-size: 13.5px;
}
.tme-av .av-table th {
  background: var(--tint);
  color: var(--muted);
  font-weight: 600;
  font-size: 12.5px;
  padding: 10px 12px;
  border-bottom: 1px solid var(--line);
  white-space: nowrap;
}
.tme-av .av-table td {
  padding: 9px 12px;
  border-bottom: 1px solid var(--line-soft);
  vertical-align: top;
}
.tme-av .av-table th.num, .tme-av .av-table td.num { text-align: right; white-space: nowrap; }
.tme-av .av-table th.center, .tme-av .av-table td.center { text-align: center; }

/* 分区标题行 */
.tme-av .av-table tr.sec-row td {
  background: var(--tint);
  font-size: 12px;
  font-weight: 700;
  color: var(--muted);
  letter-spacing: 0.4px;
  padding: 6px 12px;
  border-top: 1px solid var(--line);
  border-bottom: 1px solid var(--line);
}
.tme-av .av-table tbody tr.sec-row:first-child td { border-top: 0; }

/* 普通行 vs 重点调整行 vs 合计行 */
.tme-av .av-table tr.item-row:hover td { background: var(--hover); }
.tme-av .av-table tr.item-row.is-Expandable { cursor: pointer; }
.tme-av .av-table tr.item-row td.item-cell { padding-left: 18px; }
.tme-av .av-table tr.item-row.spot-split td:first-child { box-shadow: inset 3px 0 0 var(--purple); }
.tme-av .av-table tr.item-row.spot-split td { background: var(--purple-row); }
.tme-av .av-table tr.item-row.spot-split:hover td { background: var(--purple-bg); }
.tme-av .av-table tr.item-row.spot-pending td:first-child { box-shadow: inset 3px 0 0 var(--err); }
.tme-av .av-table tr.item-row.spot-pending td { background: var(--err-bg); }

.tme-av .av-table tr.sub-row td {
  background: var(--primary-bg);
  color: var(--ink);
  font-weight: 700;
  padding-block: 11px;
  border-top: 2px solid var(--primary-bd);
  border-bottom: 1px solid var(--line);
}
.tme-av .av-table tr.major-row td {
  background: var(--total-bg);
  color: var(--ink);
  font-size: 14.5px;
  font-weight: 800;
  padding-block: 13px;
  border-top: 2px solid var(--primary);
  border-bottom: 2px solid var(--primary);
}
.tme-av .av-table tr.sub-row td:first-child { box-shadow: inset 3px 0 0 var(--primary-bd); }
.tme-av .av-table tr.major-row td:first-child { box-shadow: inset 5px 0 0 var(--primary); }
.tme-av .av-table tr.ident-row td {
  color: var(--muted);
  font-size: 12.5px;
  background: var(--card);
}
.tme-av .av-table tr.ident-row td.item-cell { padding-left: 26px; }

.tme-av .av-item-title {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 6px;
}
.tme-av .av-item-note {
  margin-top: 2px;
  font-size: 12px;
  color: var(--muted);
  line-height: 1.45;
}
.tme-av .av-expand-btn {
  appearance: none;
  border: 1px solid var(--line);
  background: var(--card);
  color: var(--primary);
  font-size: 11.5px;
  padding: 1px 7px;
  border-radius: 4px;
  cursor: pointer;
  line-height: 1.4;
}
.tme-av .av-expand-btn:hover { border-color: var(--primary); }
.tme-av .av-basis-row td {
  background: var(--tint-soft);
  padding: 10px 18px 12px 24px;
  border-bottom: 1px solid var(--line);
}
.tme-av .av-basis-box {
  max-width: 78ch;
  font-size: 13px;
  line-height: 1.7;
  color: var(--ink);
}
.tme-av .av-basis-box p + p { margin-top: 4px; }
.tme-av .av-mute-dot { color: var(--dot); font-weight: 400; user-select: none; }
.tme-av .av-delta-tag {
  display: block;
  font-size: 11px;
  font-weight: 500;
  color: var(--muted);
  line-height: 1.25;
  margin-top: 1px;
}
.tme-av .val-neg { color: var(--warn); }
.tme-av .av-table .val-neg { color: var(--ink); }
.tme-av .val-pos { color: var(--ok); }
.tme-av .val-split { color: var(--purple); }

.tme-av .av-fold-toggle-row td {
  text-align: center;
  padding: 7px 12px;
  background: var(--card);
}
.tme-av .av-link-btn {
  appearance: none;
  border: 0;
  background: none;
  color: var(--primary);
  font-size: 12.5px;
  cursor: pointer;
  padding: 2px 8px;
}
.tme-av .av-link-btn:hover { text-decoration: underline; }

/* 表尾总计闭环 */
.tme-av .av-table tfoot tr.sum-row td {
  background: var(--tint);
  font-weight: 700;
  padding: 10px 12px;
  border-top: 2px solid var(--line-strong);
}
.tme-av .av-table tfoot tr.attr-row td {
  background: var(--primary-bg);
  padding: 10px 12px;
  border-top: 1px solid var(--primary-bd);
  font-weight: 600;
}

/* 5. 底部导航与自检 */
.tme-av .av-footer {
  display: grid;
  grid-template-columns: minmax(0, 1.15fr) minmax(0, 1fr);
  gap: 16px;
  margin-top: 16px;
}
.tme-av .av-bridge-link-card {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 12px;
  padding: 14px 18px;
  background: var(--card);
  border: 1px solid var(--line);
  border-radius: 12px;
  text-decoration: none;
  color: var(--ink);
  transition: border-color 0.15s ease, background 0.15s ease;
}
.tme-av .av-bridge-link-card:hover {
  border-color: var(--primary);
  background: var(--tint-soft);
}

@container (max-width: 880px) {
  .tme-av .av-hero,
  .tme-av .av-grid-2,
  .tme-av .av-footer { grid-template-columns: 1fr; }
  .tme-av .av-steps { grid-template-columns: repeat(2, minmax(0, 1fr)); }
}
@container (max-width: 520px) {
  .tme-av .av-steps,
  .tme-av .av-cash-boxes { grid-template-columns: 1fr; }
  .tme-av .av-cmp-row { grid-template-columns: 96px 1fr auto; }
}
`;

const PILL_META = {
  adjust: { cls: 'p-adjust', label: '重估或调整' },
  split: { cls: 'p-split', label: '单独计价' },
  keep: { cls: 'p-keep', label: '原值入 ①' },
  transfer: { cls: 'p-transfer', label: '原值入 ④' },
  pending: { cls: 'p-pending', label: '待归类' },
};

function Pill({ kind, customLabel }) {
  const meta = PILL_META[kind];
  if (!meta) return null;
  const parts = (customLabel || meta.label).split(/([①④])/);
  return (
    <span className={`av-pill ${meta.cls}`}>
      {parts.map((part, index) =>
        index % 2 ? <strong key={index} className="av-pill-layer">{part}</strong> : part,
      )}
    </span>
  );
}

const Mute = () => <span className="av-mute-dot">·</span>;

function Page({ d }) {
  const { token } = theme.useToken();
  const [viewMode, setViewMode] = React.useState('all');
  const [showIdentity, setShowIdentity] = React.useState(false);
  const [openIds, setOpenIds] = React.useState(() => new Set());

  const { raw: reportedRows, items, v, co, checks } = d;
  // The official statement lists equity before liabilities and non-current liabilities first.
  const indexOf = (name) => reportedRows.findIndex((r) => r.item === name);
  const [assetEnd, equityEnd, nonCurrentEnd, liabilityEnd] =
    ['总资产', '总权益', '非流动负债合计', '总负债'].map(indexOf);
  const raw = assetEnd < equityEnd && equityEnd < nonCurrentEnd && nonCurrentEnd < liabilityEnd
    ? [
        ...reportedRows.slice(0, assetEnd + 1),
        ...reportedRows.slice(nonCurrentEnd + 1, liabilityEnd),
        ...reportedRows.slice(equityEnd + 1, nonCurrentEnd + 1),
        reportedRows[liabilityEnd],
        ...reportedRows.slice(assetEnd + 1, equityEnd + 1),
        ...reportedRows.slice(liabilityEnd + 1),
      ].map((r, i) => ({ ...r, seq: i + 1 }))
    : reportedRows;
  if (!raw.length || !v) return <Alert type="warning" showIcon message="本期资产负债表或重估结果待补。" />;

  const toggleOpen = (id) => {
    setOpenIds((prev) => {
      const next = new Set(prev);
      if (next.has(id)) next.delete(id);
      else next.add(id);
      return next;
    });
  };

  const amount = (name) => raw.find((r) => r.item === name)?.amount;
  const seqOf = (name) => raw.find((r) => r.item === name)?.seq ?? 0;
  const mapped = new Map(items.filter((i) => i.line_item).map((i) => [i.line_item, i]));

  const reserve = items.find((i) => i.name === '经营所需现金（从现金划入）');
  const cashOut = items.find((i) => i.name === '划给经营的周转现金');
  const cashRows = items.filter((i) => CASH_ITEMS.has(i.line_item));
  const requiredCashRows = raw.filter((r) => CASH_ITEMS.has(r.item)).length;
  const grossCash = cashRows.length === requiredCashRows ? sumKnown(cashRows, 'book_signed') : null;
  const independentCash =
    cashOut && cashRows.length === requiredCashRows ? sumKnown([...cashRows, cashOut], 'value_signed') : null;
  const cashSplit = known(reserve?.value_signed) && Number(reserve.value_signed) > 0 && known(cashOut?.value_signed);
  const cashEquivalent = '现金及现金等价物';
  const cashEquivalentValue = mapped.get(cashEquivalent)?.value_signed;
  const operatingCash = Number(reserve?.value_signed);
  const showCashInAssets = cashSplit && known(cashEquivalentValue)
    && raw.some((r) => r.item === cashEquivalent)
    && Math.abs(operatingCash + Number(cashOut.value_signed)) < 1e-6
    && Number(cashEquivalentValue) >= operatingCash;
  const splitPayable = items.some((i) => i.name === '投资应付款（从其他应付款划出）' && Number(i.value_signed) !== 0);

  // 报表可先列权益，再列负债。用小计与权益科目识别分区。
  const sNca = seqOf('非流动资产合计');
  const sTa = seqOf('总资产');
  const sClEnd = seqOf('流动负债合计');
  const sNclEnd = seqOf('非流动负债合计');
  const assetSections = ['非流动资产', '流动资产'];
  const liabilitySections = ['流动负债', '非流动负债', '负债合计'];
  const equitySection = '股东权益与对账基准';
  const reportSections = [...assetSections, ...liabilitySections, equitySection];
  const sectionOfRow = ({ seq, item }) => {
    if (seq <= sNca) return assetSections[0];
    if (seq <= sTa) return assetSections[1];
    if (item === '总负债') return liabilitySections[2];
    if (CONTROLS.has(item) && !SUB_TOTALS.has(item) || item === '非控股权益') return equitySection;
    if (sClEnd < sNclEnd) return seq <= sClEnd ? liabilitySections[0] : liabilitySections[1];
    return seq <= sNclEnd ? liabilitySections[1] : liabilitySections[0];
  };

  const enrichItem = (m, extraFlags = {}) => {
    const bookS = known(m?.book_signed) ? Number(m.book_signed) : null;
    const valS = known(m?.value_signed) ? Number(m.value_signed) : null;
    const delta = known(bookS) && known(valS) ? valS - bookS : null;
    const hasDelta = known(delta) && Math.abs(delta) > 1e-6;
    const opVal = m?.role === '经营资本' ? valS : null;
    const brVal = m?.role === '资产负债桥' ? valS : null;
    return { bookS, valS, delta, hasDelta, opVal, brVal, ...extraFlags };
  };

  const stmtRows = raw.map((r) => {
    const m = mapped.get(r.item);
    const isMajor = MAJOR_TOTALS.has(r.item);
    const isSub = SUB_TOTALS.has(r.item);
    const isIdent = IDENTITY_ROWS.has(r.item);
    const isControl = CONTROLS.has(r.item);
    const pool = cashSplit && CASH_ITEMS.has(r.item);
    const split = splitPayable && r.item === '其他应付款项及其他负债（流动）';
    const category = m?.category ?? (isControl ? '报表合计' : '待归类');
    const cashAllocation = showCashInAssets && r.item === cashEquivalent;
    const info = enrichItem(m, cashAllocation
      ? { opVal: operatingCash, brVal: Number(cashEquivalentValue) - operatingCash }
      : {});
    let kind = null;
    if (!isControl) {
      if (!m) kind = 'pending';
      else if (split || cashAllocation) kind = 'split';
      else if (info.hasDelta) kind = 'adjust';
      else kind = m.role === '资产负债桥' ? 'transfer' : 'keep';
    }
    return {
      ...r,
      rowId: `raw-${r.id}`,
      section: sectionOfRow(r),
      model: m,
      category,
      isMajor,
      isSub,
      isIdent,
      isControl,
      pool,
      cashAllocation,
      split,
      kind,
      ...info,
    };
  });

  const extraRows = items
    .filter((i) => !i.line_item || !raw.some((r) => r.item === i.line_item))
    .filter((i) => !showCashInAssets || (i.id !== reserve.id && i.id !== cashOut.id))
    .sort((a, b) => (a.sort ?? 0) - (b.sort ?? 0) || a.id - b.id)
    .map((i) => {
      const info = enrichItem(i);
      const isTransferPair =
        i.id === reserve?.id || i.id === cashOut?.id || i.name === '投资应付款（从其他应付款划出）';
      return {
        id: `extra-${i.id}`,
        rowId: `extra-${i.id}`,
        item: i.name || i.line_item,
        section: '六、单独计价与表外估值调整',
        category: i.category,
        model: i,
        isExtra: true,
        kind: isTransferPair ? 'split' : 'adjust',
        ...info,
      };
    });

  // 为小计与总计行汇总对应明细的 ① / ④ / 重估变动（不重复加总）
  const leaves = (...sections) =>
    stmtRows.filter((r) => !r.isControl && r.model && sections.includes(r.section));
  const sumPack = (listRows) => {
    const d = sumAny(listRows, (r) => r.delta);
    const op = listRows.some((r) => known(r.opVal)) ? sumAny(listRows, (r) => r.opVal) : null;
    const br = listRows.some((r) => known(r.brVal)) ? sumAny(listRows, (r) => r.brVal) : null;
    return { subDelta: Math.abs(d) > 1e-6 ? d : null, subOp: op, subBr: br };
  };
  const subtotalMap = {
    非流动资产合计: sumPack(leaves(assetSections[0])),
    流动资产合计: sumPack(leaves(assetSections[1])),
    总资产: sumPack(leaves(...assetSections)),
    流动负债合计: sumPack(leaves(liabilitySections[0])),
    非流动负债合计: sumPack(leaves(liabilitySections[1])),
    总负债: sumPack(leaves(...liabilitySections)),
  };

  function shortNote(r) {
    const m = r.model;
    if (r.item === '归属于母公司股东权益合计') return 'G01 归母净资产对账基准（全部科目仅计一次，误差 0.00）';
    if (!m) return '';
    if (r.item === '商誉' && Number(m.haircut) === 1) return '并购溢价不可单独变现，亦非重建所需，第一层计零';
    if (['以公允价值计量且其变动计入其他综合收益的金融资产',  '其他投资（非流动）', '按权益法核算的投资'].includes(r.item) && known(m.haircut))
      return `考虑控股折价、税费与流动性，按账面 ${Number(((1 - m.haircut) * 100).toFixed(0))}% 计入 ④`;
    if (r.split) return '剥离 4.10 亿对外投资未付尾款至 ④，其余留作经营负债';
    if (m.id === reserve?.id) return m.basis ? m.basis.split('。')[0] : '';
    if (m.id === cashOut?.id) return '与 ① 经营所需现金成对划转，留存周转金不计入可分配现金';
    if (r.cashAllocation)
      return `留作经营周转 ${fmt(r.opVal)} 亿元，余额 ${fmt(r.brVal)} 亿元单独计价`;
    if (r.item === '现金及现金等价物' && r.pool)
      return `经营周转金 ${fmt(reserve.value_signed)} 亿元在表末单列扣除`;
    if (r.item === '非控股权益') return '经营部分已按 97% 归母折算，此处仅扣非经营净资产的 3%';
    if (r.item === '投资应付款（从其他应付款划出）') return '并购及对外投资待付价款，确定性现金流出，在 ④ 扣除';
    if (r.item === '境内资金汇出预提税（10%）') return '境内利润汇出境外预计承担的 10% 预提税，在 ④ 扣除';
    if (m.basis) return m.basis.split('。')[0];
    return '';
  }

  function deltaCaption(r) {
    const m = r.model;
    if (!m || !r.hasDelta) return '';
    if (known(m.haircut) && Number(m.haircut) !== 0) return `折价 ${(Number(m.haircut) * 100).toFixed(0)}%`;
    if (r.split) return '剥离并购款';
    if (m.id === reserve?.id) return '自 ④ 划入';
    if (m.id === cashOut?.id) return '划往 ① 层';
    if (r.item === '投资应付款（从其他应付款划出）') return '自 ① 划入';
    if (r.item === '非控股权益') return '仅扣非经营3%';
    if (r.isExtra) return '表外计提';
    return '重估调整';
  }

  // 核心桥接数字计算（全量动态来自数据库）
  const ops = items.filter((i) => i.role === '经营资本');
  const bridges = items.filter((i) => i.role === '资产负债桥');
  const opAssetsBook = sumAny(
    ops.filter((i) => i.category === '经营资产'),
    (i) => i.book_signed,
  );
  const opLiabsBook = sumAny(
    ops.filter((i) => i.category === '经营负债'),
    (i) => Math.abs(i.book_signed),
  );
  const signedBook = sumKnown(ops, 'book_signed');
  const haircutLoss = sumAny(ops, (i) => (known(i.haircut) ? -Number(i.book_signed) * Number(i.haircut) : 0));
  const crossOpAdj = known(signedBook) && known(v.adj_capital) ? Number(v.adj_capital) - signedBook - haircutLoss : null;

  const bookBridge = sumKnown(bridges, 'book_signed');
  const totalBookMapped = known(signedBook) && known(bookBridge) ? signedBook + bookBridge : null;
  const parentEquity = amount('归属于母公司股东权益合计');
  const reconciles =
    known(parentEquity) && known(totalBookMapped) && Math.abs(Number(parentEquity) - totalBookMapped) < 0.02;
  const hasPending = stmtRows.some((r) => r.category === '待归类');

  // 第一层经营净资产物理构成
  const goodwillItem = ops.find((i) => i.line_item === '商誉');
  const intangibleItem = ops.find((i) => i.line_item === '无形资产');
  const intangibleSensitivity = (discount) =>
    [v.adj_capital, v.av_attrib, intangibleItem?.book_signed, intangibleItem?.value_signed].every(known)
      ? (Number(v.adj_capital) - Number(intangibleItem.value_signed)
          + Number(intangibleItem.book_signed) * (1 - discount)) * Number(v.av_attrib)
      : null;
  const ltOpVal = sumAny(
    ops.filter((i) => LT_OP_ITEMS.has(i.line_item)),
    (i) => i.value_signed,
  );
  const opCashVal = Number(reserve?.value_signed || 0);
  const wcNetVal = sumAny(
    ops.filter((i) => !LT_OP_ITEMS.has(i.line_item) && i.line_item !== '商誉' && i.id !== reserve?.id),
    (i) => i.value_signed,
  );
  const wcAssetVal = sumAny(
    ops.filter(
      (i) => i.category === '经营资产' && !LT_OP_ITEMS.has(i.line_item) && i.line_item !== '商誉' && i.id !== reserve?.id,
    ),
    (i) => i.value_signed,
  );
  const wcLiabVal = sumAny(
    ops.filter((i) => i.category === '经营负债'),
    (i) => Math.abs(i.value_signed),
  );

  // 第四层摘要（用于底部跳转卡）
  const brCashInv = sumAny(
    bridges.filter((i) => i.category === '现金与投资'),
    (i) => i.value_signed,
  );
  const brDebt = sumAny(
    bridges.filter((i) => i.category === '有息负债'),
    (i) => i.value_signed,
  );
  const brClaims = sumAny(
    bridges.filter((i) => i.category === '其他索取权'),
    (i) => i.value_signed,
  );

  // 对比进度条（① vs ②）
  const avTotal = Number(v.av_total) || 0;
  const epvTotal = Number(v.epv_total) || 0;
  const maxLayer = Math.max(avTotal, epvTotal, 1);
  const avShareOfEpv = epvTotal > 0 ? (avTotal / epvTotal) * 100 : null;

  // 账面归母权益切分比例（① vs ④）
  const posBookOp = Math.max(0, Number(signedBook) || 0);
  const posBookBr = Math.max(0, Number(bookBridge) || 0);
  const posBookSum = Math.max(posBookOp + posBookBr, 1);

  // 过滤表格行
  const adjustedAll = [...stmtRows.filter((r) => !r.isControl && (r.hasDelta || r.split || r.cashAllocation)), ...extraRows];
  const operatingAll = [
    ...stmtRows.filter((r) => r.model?.role === '经营资本' || r.cashAllocation),
    ...extraRows.filter((r) => r.model?.role === '经营资本'),
  ].map((r) => ({
    ...r,
    section: r.isExtra ? '三、经营调整' : r.category === '经营资产' || r.cashAllocation ? '一、经营资产' : '二、经营负债',
  }));

  let displayRows = [];
  if (viewMode === 'adjusted') {
    displayRows = adjustedAll.map((r) => ({ ...r, section: r.isExtra ? '二、单独计价与表外估值调整' : '一、报表科目重估与拆分' }));
  } else if (viewMode === 'ops') {
    displayRows = operatingAll;
  } else {
    displayRows = [
      ...stmtRows.filter((r) => showIdentity || !r.isIdent)
        .sort((a, b) => reportSections.indexOf(a.section) - reportSections.indexOf(b.section)),
      ...extraRows,
    ];
  }

  // 按 section 分组插入组头
  const groupedElements = [];
  let lastSec = '';
  displayRows.forEach((r) => {
    if (r.section && r.section !== lastSec) {
      lastSec = r.section;
      groupedElements.push({ type: 'sec', key: `sec-${r.section}`, title: r.section });
    }
    groupedElements.push({ type: 'row', key: r.rowId, row: r });
    if (viewMode === 'all' && r.item === '归属于母公司股东权益合计' && stmtRows.some((x) => x.isIdent)) {
      groupedElements.push({ type: 'ident-toggle', key: 'ident-toggle' });
    }
  });

  const deltaTotalAll = known(v.adj_capital) && known(v.bridge) && known(totalBookMapped)
    ? Number(v.adj_capital) + Number(v.bridge) - totalBookMapped
    : null;
  const deltaTotalOps = known(v.adj_capital) && known(signedBook) ? Number(v.adj_capital) - signedBook : null;

  const vars = {
    '--ink': token.colorText,
    '--muted': token.colorTextSecondary,
    '--dot': token.colorTextQuaternary,
    '--card': token.colorBgContainer,
    '--tint': token.colorFillQuaternary,
    '--tint-soft': token.colorFillAlter || token.colorFillQuaternary,
    '--hover': token.colorFillTertiary,
    '--track': token.colorFillSecondary,
    '--line': token.colorBorderSecondary,
    '--line-soft': token.colorSplit,
    '--line-strong': token.colorBorder,
    '--primary': token.colorPrimary,
    '--primary-bg': token.colorPrimaryBg,
    '--total-bg': token.colorPrimaryBgHover || token.colorPrimaryBg,
    '--primary-bd': token.colorPrimaryBorder,
    '--info-bg': token.colorInfoBg,
    '--info-bd': token.colorInfoBorder,
    '--warn': token.colorWarningText || token.colorError,
    '--warn-bg': token.colorWarningBg,
    '--warn-bd': token.colorWarningBorder,
    '--ok': token.colorSuccessText || token.colorSuccess,
    '--purple': token.colorPrimaryText || token.colorPrimary,
    '--purple-bg': token.colorPrimaryBg,
    '--purple-bd': token.colorPrimaryBorder,
    '--purple-row': token.colorPrimaryBg,
    '--err': token.colorError,
    '--err-bg': token.colorErrorBg,
    '--err-bd': token.colorErrorBorder,
  };

  return (
    <article className="tme-av" style={vars}>
      <style>{style}</style>

      {/* 1. 首屏结论主焦区 */}
      <header className="av-hero">
        <div>
          <div className="av-eyebrow">
            第一层 · 全公司净经营资产重估 · 截至 {String(co.as_of).slice(0, 10)}
          </div>
          <div className="av-hero-num-row">
            <strong className="av-hero-num">{fmt(v.av_total)}</strong>
            <span className="av-hero-unit">亿元（归母经营资产价值）</span>
          </div>
          <div className="av-hero-badges">
            <span>
              估值口径 <b>{v.av_basis || co.av_basis || '调整后净资产'}</b>
            </span>
            <span>
              重估经营净资产 <b>{fmt(v.adj_capital)} 亿</b> × 归母{' '}
              <b>{known(v.av_attrib) ? (v.av_attrib * 100).toFixed(1) + '%' : '—'}</b>
            </span>
            {known(v.av_ps) && (
              <span>
                加 ④ 滚算至今每股 <b>{fmt(v.av_ps)} 元</b>
              </span>
            )}
          </div>
          {v.av_basis === '重建成本' && known(co.repro_cost) && (
            <div style={{ marginTop: 6, fontSize: 13 }}>
              当前采用重建成本口径：全公司重建成本 <b>{fmt(co.repro_cost)} 亿元</b>
            </div>
          )}
        </div>

        <div className="av-verdict">
          <div className="av-verdict-title">
            <span>Greenwald 壁垒检验（① 资产 vs ② 盈利能力）</span>
            <Tag color="blue" style={{ marginInlineEnd: 0 }}>
              主估值：{v.value_layer || '盈利能力价值'}
            </Tag>
          </div>
          <div className="av-cmp-row">
            <Text type="secondary">① 经营资产价值</Text>
            <div className="av-cmp-track">
              <div
                className="av-cmp-fill"
                style={{
                  width: `${Math.max(3, (avTotal / maxLayer) * 100)}%`,
                  background: token.colorTextTertiary,
                }}
              />
            </div>
            <Text strong>{fmt(v.av_total)} 亿</Text>
          </div>
          <div className="av-cmp-row" style={{ marginBottom: 0 }}>
            <Text type="secondary">② 盈利能力价值</Text>
            <div className="av-cmp-track">
              <div
                className="av-cmp-fill"
                style={{
                  width: `${Math.max(3, (epvTotal / maxLayer) * 100)}%`,
                  background: token.colorPrimary,
                }}
              />
            </div>
            <Text strong style={{ color: token.colorPrimary }}>
              {fmt(v.epv_total, 1)} 亿
            </Text>
          </div>
          <p className="av-verdict-note">
            重估净经营资产仅占盈利能力价值的{' '}
            <b>{avShareOfEpv !== null ? avShareOfEpv.toFixed(1) + '%' : '—'}</b>
            （含 ④ 每股 {fmt(v.av_ps)} vs {fmt(v.epv_ps)} 元）：轻资产平台的核心价值来自规模议价与曲库壁垒而非账面实物，第一层仅作资产底线与壁垒印证。
          </p>
        </div>
      </header>

      {(!reconciles || hasPending) && (
        <div style={{ marginTop: 14 }}>
          <Alert
            type="warning"
            showIcon
            message="有报表科目待归类或账面归母权益尚未对平，请复核下方明细表。"
          />
        </div>
      )}

      {/* 2. 可视化五步桥接瀑布 + 全表归母净资产去向 */}
      <section className="av-section">
        <div className="av-sec-head">
          <h3>第一层是怎么从报表算出来的？（亿元）</h3>
          <span className="av-sec-sub">
            报表总资产 {fmt(amount('总资产'))} − 总负债 {fmt(amount('总负债'))} ＝ 合并净资产 {fmt(amount('总权益'))}（归母股东权益{' '}
            <b>{fmt(parentEquity)}</b>）
          </span>
        </div>

        <div className="av-steps">
          <div className="av-step">
            <span className="av-step-label">起点 · 报表经营资本</span>
            <strong className="av-step-val">{fmt(signedBook)}</strong>
            <span className="av-step-desc">
              经营资产 {fmt(opAssetsBook)} − 经营负债 {fmt(opLiabsBook)}
            </span>
          </div>
          <div className="av-step is-adjust">
            <span className="av-step-label">＋ 估值边界调整</span>
            <strong className="av-step-val">{signedFmt(crossOpAdj)}</strong>
            <span className="av-step-desc">经营周转金 {signedFmt(reserve?.value_signed)}</span>
          </div>
          <div className="av-step is-haircut">
            <span className="av-step-label">− 资产重估</span>
            <strong className="av-step-val">{signedFmt(haircutLoss)}</strong>
            <span className="av-step-desc">商誉计零 · 可辨认无形资产按折后账面值暂计</span>
          </div>
          <div className="av-step">
            <span className="av-step-label">＝ 重估经营净资产</span>
            <strong className="av-step-val">{fmt(v.adj_capital)}</strong>
            <span className="av-step-desc">
              调整口径 {known(signedBook) && known(crossOpAdj) ? fmt(signedBook + crossOpAdj) : '—'} 扣折价后净额
            </span>
          </div>
          <div className="av-step is-final">
            <span className="av-step-label">× 归母比例折算</span>
            <strong className="av-step-val">{fmt(v.av_total)}</strong>
            <span className="av-step-desc">
              第一层归母价值（×{known(v.av_attrib) ? (v.av_attrib * 100).toFixed(1) + '%' : '—'}，扣少数股东{' '}
              {known(v.adj_capital) && known(v.av_total) ? fmt(v.adj_capital - v.av_total) : '—'}）
            </span>
          </div>
        </div>

        <div className="av-split-bar-wrap">
          <div className="av-split-bar" aria-label="归母股东权益在第一层与第四层之间的账面切分">
            <div
              style={{
                width: `${(posBookOp / posBookSum) * 100}%`,
                background: token.colorPrimary,
              }}
            />
            <div
              style={{
                width: `${(posBookBr / posBookSum) * 100}%`,
                background: token.colorSuccess,
                opacity: 0.72,
              }}
            />
          </div>
          <div className="av-split-legend">
            <span>
              <i className="av-dot" style={{ background: token.colorPrimary }} />
              <b>① 经营资本</b>：账面 <b>{fmt(signedBook)}</b>（{((posBookOp / posBookSum) * 100).toFixed(0)}%）→ 重估后净额{' '}
              <b>{fmt(v.adj_capital)} 亿</b>
            </span>
            <span>
              <i className="av-dot" style={{ background: token.colorSuccess, opacity: 0.85 }} />
              <b>④ 独立资产与负债桥</b>：账面非经营净额 <b>{fmt(bookBridge)}</b>（{((posBookBr / posBookSum) * 100).toFixed(0)}%，大额现金与投资未丢失）→ 折价扣税后净额{' '}
              <b>{fmt(v.bridge)} 亿</b>
            </span>
          </div>
        </div>
      </section>

      {/* 3. 两大核心重估抓手并列解读 */}
      <div className="av-grid-2">
        <section className="av-card">
          <div>
            <div className="av-sec-head" style={{ marginBottom: 6 }}>
              <h3>抓手一 · 重估后 {fmt(v.adj_capital)} 亿经营净资产里有什么？</h3>
            </div>
            <div className="av-kv-list">
              {goodwillItem && (
                <div className="av-kv">
                  <span>
                    并购商誉
                    <span className="av-kv-sub">账面 {fmt(goodwillItem.book_signed)} 亿 · 折价 100%</span>
                  </span>
                  <strong className="val-neg">{fmt(goodwillItem.value_signed)} 亿</strong>
                </div>
              )}
              <div className="av-kv">
                <span>
                  版权无形、土地与设备
                  <span className="av-kv-sub">无形资产按折后值计入，土地与设备沿用账面值</span>
                </span>
                <strong>+{fmt(ltOpVal)} 亿</strong>
              </div>
              {cashSplit && (
                <div className="av-kv">
                  <span>
                    留存经营周转现金
                    <span className="av-kv-sub">自广义现金池划入</span>
                  </span>
                  <strong className="val-split">+{fmt(opCashVal)} 亿</strong>
                </div>
              )}
              <div className="av-kv">
                <span>
                  日常净营运资金与递延税
                  <span className="av-kv-sub">
                    应收预付等 {fmt(wcAssetVal)} − 递延收入与应付款 {fmt(wcLiabVal)}
                  </span>
                </span>
                <strong className={wcNetVal < 0 ? 'val-neg' : ''}>{signedFmt(wcNetVal)} 亿</strong>
              </div>
            </div>
          </div>
          <div style={{ fontSize: 12.5, color: token.colorTextSecondary, paddingTop: 6, borderTop: `1px solid ${token.colorSplit}` }}>
            {intangibleItem && (
              <details className="av-fold">
                <summary>无形资产 {fmt(intangibleItem.book_signed)} 亿 → 计入 {fmt(intangibleItem.value_signed)} 亿</summary>
                <div className="av-fold-body">
                  <p>仅改变无形资产折价时，第一层归母资产价值分别为：</p>
                  <p>不折价 {fmt(intangibleSensitivity(0))} 亿 · 基准折价 {fmt(Number(intangibleItem.haircut) * 100, 0)}% {fmt(intangibleSensitivity(Number(intangibleItem.haircut)))} 亿 · 折价 50% {fmt(intangibleSensitivity(0.5))} 亿</p>
                  <p>Q3 余额与历史分类参照见底稿「无形资产」行。</p>
                </div>
              </details>
            )}
          </div>
        </section>

        {cashSplit && (
          <section className="av-card">
            <div>
              <div className="av-sec-head" style={{ marginBottom: 6 }}>
                <h3>抓手二 · 广义现金 {fmt(grossCash)} 亿如何分到两层？</h3>
              </div>
              <div className="av-cash-boxes">
                <div className="av-cash-box">
                  <span>现金、存款与短投</span>
                  <strong>{fmt(grossCash)}</strong>
                </div>
                <div className="av-cash-box is-op">
                  <span>① 留作经营周转</span>
                  <strong className="val-split">{fmt(reserve.value_signed)}</strong>
                </div>
                <div className="av-cash-box is-br">
                  <span>④ 剩余独立现金</span>
                  <strong>{fmt(independentCash)}</strong>
                </div>
              </div>
              {known(grossCash) && Number(grossCash) > 0 && (
                <div className="av-split-bar" style={{ height: 7, margin: '6px 0 8px' }}>
                  <div
                    style={{
                      width: `${(Number(reserve.value_signed) / Number(grossCash)) * 100}%`,
                      background: token.colorPrimary,
                    }}
                  />
                  <div
                    style={{
                      width: `${(Number(independentCash) / Number(grossCash)) * 100}%`,
                      background: token.colorSuccess,
                      opacity: 0.72,
                    }}
                  />
                </div>
              )}
            </div>
            {reserve.basis && (
              <div>
                <div style={{ fontSize: 12.5, fontWeight: 600 }}>{reserve.basis.split('。')[0]}。</div>
                <details className="av-fold">
                  <summary>查看三项周转测算与收入下滑压力假设</summary>
                  <div className="av-fold-body">
                    {reserve.basis
                      .split('。')
                      .slice(1)
                      .filter(Boolean)
                      .map((line, i) => (
                        <p key={i}>{line}。</p>
                      ))}
                  </div>
                </details>
              </div>
            )}
          </section>
        )}
      </div>

      {/* 4. 逐项归类与重估底稿表 */}
      <section className="av-section">
        <div className="av-toolbar">
          <div>
            <h3 style={{ fontSize: 16, fontWeight: 600 }}>逐项归类与重估底稿（亿元）</h3>
          </div>
          <Segmented
            value={viewMode}
            onChange={setViewMode}
            options={[
              { label: '全部归类（完整报表）', value: 'all' },
              { label: `仅看重估与调整（${adjustedAll.length}）`, value: 'adjusted' },
              { label: `仅看 ① 经营项（${operatingAll.length}）`, value: 'ops' },
            ]}
          />
        </div>

        <div className="av-legend-bar">
          <span>
            <b>处理</b>列说明按什么口径计入①或④。{showCashInAssets
              ? '经营周转金直接列在现金及现金等价物行，剩余现金在④单独计价。'
              : '现金与存款逐项列示，经营周转金在表末单列。'}点击带依据行可展开测算过程。
          </span>
          <div className="av-legend-items">
            <Pill kind="keep" />
            <Pill kind="adjust" />
            <Pill kind="split" />
            <Pill kind="pending" />
          </div>
        </div>

        <div className="av-table-wrap">
          <table className="av-table">
            <thead>
              <tr>
                <th style={{ textAlign: 'left', width: '34%' }}>科目与估值要点</th>
                <th className="center" style={{ width: '10%' }}>归类</th>
                <th className="center" style={{ width: '11%' }}>处理</th>
                <th className="num" style={{ width: '11%' }}>报表原值</th>
                <th className="num" style={{ width: '12%' }}>重估与调整</th>
                <th className="num" style={{ width: '11%' }}>① 经营计入</th>
                <th className="num" style={{ width: '11%' }}>④ 独立计入</th>
              </tr>
            </thead>
            <tbody>
              {groupedElements.map((entry) => {
                if (entry.type === 'sec') {
                  return (
                    <tr className="sec-row" key={entry.key}>
                      <td colSpan={7}>{entry.title}</td>
                    </tr>
                  );
                }
                if (entry.type === 'ident-toggle') {
                  const identCount = stmtRows.filter((x) => x.isIdent).length;
                  return (
                    <tr className="av-fold-toggle-row" key={entry.key}>
                      <td colSpan={7}>
                        <button
                          type="button"
                          className="av-link-btn"
                          onClick={() => setShowIdentity((s) => !s)}
                        >
                          {showIdentity
                            ? `收起港股恒等式与权益构成明细（${identCount} 行） ▴`
                            : `展开港股恒等式与权益构成明细（股本、储备、净流动资产等 ${identCount} 行核对项） ▾`}
                        </button>
                      </td>
                    </tr>
                  );
                }

                const r = entry.row;
                const m = r.model;
                const note = shortNote(r);
                const hasBasis = Boolean(m?.basis);
                const isOpen = openIds.has(r.rowId);

                // 小计、总计与港股恒等式核对行
                if (r.isControl) {
                  const sub = subtotalMap[r.item];
                  const rowCls = r.isMajor ? 'major-row' : r.isSub ? 'sub-row' : 'ident-row';
                  return (
                    <tr className={rowCls} key={r.rowId}>
                      <td className={r.isIdent ? 'item-cell' : ''}>
                        <div className="av-item-title">
                          <span>{r.item}</span>
                        </div>
                        {note && <div className="av-item-note">{note}</div>}
                      </td>
                      <td className="center">
                        <Text type="secondary" style={{ fontSize: 12 }}>
                          {r.isIdent ? '恒等核对' : r.isSub ? '分组小计' : '报表总计'}
                        </Text>
                      </td>
                      <td className="center">
                        <Mute />
                      </td>
                      <td className="num">{fmt(r.amount)}</td>
                      <td className="num">
                        {sub && known(sub.subDelta) ? (
                          <span className={sub.subDelta < 0 ? 'val-neg' : 'val-pos'}>{signedFmt(sub.subDelta)}</span>
                        ) : (
                          <Mute />
                        )}
                      </td>
                      <td className="num">{sub && known(sub.subOp) ? fmt(sub.subOp) : <Mute />}</td>
                      <td className="num">{sub && known(sub.subBr) ? fmt(sub.subBr) : <Mute />}</td>
                    </tr>
                  );
                }

                // 有效业务/桥接科目与跨层调整行
                const spotCls =
                  r.kind === 'pending'
                    ? 'spot-pending'
                    : r.kind === 'split' && !r.cashAllocation
                    ? 'spot-split'
                    : '';
                const dCap = deltaCaption(r);
                const { opVal, brVal } = r;
                const entersBridge = m?.role === '资产负债桥';
                let pillLabel;
                if (r.cashAllocation) {
                  pillLabel = '① 留周转金，余额入 ④';
                } else if (r.split) {
                  pillLabel = '部分在 ④ 单独计价';
                } else if (cashOut && m?.id === cashOut.id) {
                  pillLabel = '在 ④ 扣除经营周转金';
                } else if (reserve && m?.id === reserve.id) {
                  pillLabel = '在 ① 留作经营周转';
                } else if (r.kind === 'adjust' && known(m?.haircut) && Number(m.haircut) === 1) {
                  pillLabel = '全额置零';
                } else if (r.kind === 'adjust' && known(m?.haircut)) {
                  const retained = Number(((1 - m.haircut) * 100).toFixed(0));
                  pillLabel = `按 ${retained}% 计入 ${entersBridge ? '④' : '①'}`;
                } else if (entersBridge && known(brVal) && brVal < 0) {
                  pillLabel = r.kind === 'transfer' ? '原值在 ④ 扣除' : '在 ④ 扣除';
                } else if (entersBridge && r.kind === 'adjust') {
                  pillLabel = '调整后计入 ④';
                } else if (r.isExtra && r.kind === 'adjust') {
                  pillLabel = '表外计提';
                }

                return (
                  <React.Fragment key={r.rowId}>
                    <tr
                      className={`item-row ${spotCls} ${hasBasis ? 'is-Expandable' : ''}`}
                      onClick={hasBasis ? () => toggleOpen(r.rowId) : undefined}
                    >
                      <td className="item-cell">
                        <div className="av-item-title">
                          <span style={{ fontWeight: spotCls ? 600 : 400 }}>{r.item}</span>
                          {hasBasis && (
                            <button
                              type="button"
                              className="av-expand-btn"
                              onClick={(e) => {
                                e.stopPropagation();
                                toggleOpen(r.rowId);
                              }}
                            >
                              {isOpen ? '收起依据 ▴' : '测算依据 ▾'}
                            </button>
                          )}
                        </div>
                        {note && <div className="av-item-note">{note}</div>}
                      </td>
                      <td className="center">
                        <Text type="secondary" style={{ fontSize: 12.5 }}>
                          {r.category}
                        </Text>
                      </td>
                      <td className="center">
                        <Pill kind={r.kind} customLabel={pillLabel} />
                      </td>
                      <td className="num">{known(r.amount) ? fmt(r.amount) : <Mute />}</td>
                      <td className="num">
                        {r.hasDelta ? (
                          <div>
                            <strong
                              className={
                                r.kind === 'split' ? 'val-split' : r.delta < 0 ? 'val-neg' : 'val-pos'
                              }
                            >
                              {signedFmt(r.delta)}
                            </strong>
                            {dCap && <span className="av-delta-tag">{dCap}</span>}
                          </div>
                        ) : (
                          <Mute />
                        )}
                      </td>
                      <td className="num">
                        {known(opVal) ? (
                          <span style={{ fontWeight: spotCls ? 700 : 500 }}>{fmt(opVal)}</span>
                        ) : (
                          <Mute />
                        )}
                      </td>
                      <td className="num">
                        {known(brVal) ? (
                          <span style={{ fontWeight: spotCls ? 600 : 400 }}>{fmt(brVal)}</span>
                        ) : (
                          <Mute />
                        )}
                      </td>
                    </tr>
                    {hasBasis && isOpen && (
                      <tr className="av-basis-row">
                        <td colSpan={7}>
                          <div className="av-basis-box">
                            <div style={{ marginBottom: 4, display: 'flex', alignItems: 'center', gap: 8, flexWrap: 'wrap' }}>
                              <Text strong>测算依据</Text>
                              {(m.judgments || []).map((j) => (
                                <Tag key={j.id || j.code} color="blue" style={{ marginInlineEnd: 0 }}>
                                  {j.code} · {j.title}
                                </Tag>
                              ))}
                            </div>
                            {m.basis
                              .split('。')
                              .filter(Boolean)
                              .map((part, idx) => (
                                <p key={idx}>{part}。</p>
                              ))}
                          </div>
                        </td>
                      </tr>
                    )}
                  </React.Fragment>
                );
              })}
            </tbody>
            <tfoot>
              {viewMode === 'ops' ? (
                <>
                  <tr className="sum-row">
                    <td colSpan={3}>第一层经营资本合计（资产 − 负债 ＋ 经营调整）</td>
                    <td className="num">{fmt(signedBook)}</td>
                    <td className="num">
                      <span className={Number(deltaTotalOps) < 0 ? 'val-neg' : 'val-pos'}>
                        {signedFmt(deltaTotalOps)}
                      </span>
                    </td>
                    <td className="num">{fmt(v.adj_capital)}</td>
                    <td className="num">
                      <Mute />
                    </td>
                  </tr>
                  <tr className="attr-row">
                    <td colSpan={5}>
                      按「{v.av_basis}」及归母比例 {known(v.av_attrib) ? (v.av_attrib * 100).toFixed(1) + '%' : '—'} 折算 →{' '}
                      <b>第一层归母经营资产价值</b>
                    </td>
                    <td className="num" style={{ fontSize: 15 }}>
                      <b>{fmt(v.av_total)}</b>
                    </td>
                    <td className="num">
                      <Mute />
                    </td>
                  </tr>
                </>
              ) : viewMode === 'adjusted' ? (
                <tr className="sum-row">
                  <td colSpan={4}>以上 {adjustedAll.length} 项重估与边界调整对净资产的合计影响</td>
                  <td className="num">
                    <span className={Number(deltaTotalAll) < 0 ? 'val-neg' : 'val-pos'}>
                      {signedFmt(deltaTotalAll)}
                    </span>
                  </td>
                  <td className="num">
                    <span className={Number(deltaTotalOps) < 0 ? 'val-neg' : 'val-pos'}>
                      {signedFmt(deltaTotalOps)}
                    </span>
                  </td>
                  <td className="num">
                    <span className={Number(v.bridge - bookBridge) < 0 ? 'val-neg' : 'val-pos'}>
                      {signedFmt(known(v.bridge) && known(bookBridge) ? v.bridge - bookBridge : null)}
                    </span>
                  </td>
                </tr>
              ) : (
                <>
                  <tr className="sum-row">
                    <td colSpan={3}>全表归母对账合计（账面归母净资产 → ① 经营净资产 ＋ ④ 独立资产净额）</td>
                    <td className="num">{fmt(totalBookMapped)}</td>
                    <td className="num">
                      <span className={Number(deltaTotalAll) < 0 ? 'val-neg' : 'val-pos'}>
                        {signedFmt(deltaTotalAll)}
                      </span>
                    </td>
                    <td className="num">{fmt(v.adj_capital)}</td>
                    <td className="num">{fmt(v.bridge)}</td>
                  </tr>
                  <tr className="attr-row">
                    <td colSpan={5}>
                      ① 经营净资产 {fmt(v.adj_capital)} × 归母比例{' '}
                      {known(v.av_attrib) ? (v.av_attrib * 100).toFixed(1) + '%' : '—'} ＝{' '}
                      <b style={{ color: token.colorPrimary }}>第一层归母价值 {fmt(v.av_total)} 亿元</b>
                      <Text type="secondary" style={{ fontSize: 12.5, marginLeft: 10 }}>
                        （连同 ④ 净额 {fmt(v.bridge)} 亿元滚算至今，折合每股 {fmt(v.av_ps)} 元）
                      </Text>
                    </td>
                    <td className="num" style={{ fontSize: 15 }}>
                      <b>{fmt(v.av_total)}</b>
                    </td>
                    <td className="num">
                      <b>{fmt(v.bridge)}</b>
                    </td>
                  </tr>
                </>
              )}
            </tfoot>
          </table>
        </div>
      </section>

      {/* 5. 底部下游衔接与自动检查 */}
      <div className="av-footer">
        <Link href="/admin/__BRIDGE_UID__" className="av-bridge-link-card">
          <div>
            <div style={{ fontSize: 14.5, fontWeight: 600, color: token.colorPrimary }}>
              前往 ④ 独立资产与负债桥明细 →
            </div>
            <div style={{ fontSize: 12.5, color: token.colorTextSecondary, marginTop: 4 }}>
              独立现金与折后投资 +{fmt(brCashInv)} · 有息负债 {fmt(brDebt)} · 预提税与少数股东等 {fmt(brClaims)}
            </div>
          </div>
          <div style={{ textAlign: 'right', whiteSpace: 'nowrap' }}>
            <div style={{ fontSize: 11.5, color: token.colorTextSecondary }}>第四层净额</div>
            <strong style={{ fontSize: 20, color: token.colorText }}>{fmt(v.bridge)} 亿</strong>
          </div>
        </Link>

        <div className="av-card" style={{ padding: '12px 18px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: 8 }}>
            <Text strong style={{ fontSize: 13.5 }}>模型对账与口径检查</Text>
            <div style={{ display: 'flex', gap: 6, flexWrap: 'wrap' }}>
              {checks
                .filter((c) => ['G01', 'G07'].includes(c.code))
                .map((c) => (
                  <Tag
                    key={c.code}
                    color={c.result === '通过' ? 'green' : c.result === '提示' ? 'gold' : 'red'}
                    style={{ marginInlineEnd: 0 }}
                  >
                    {c.code} {c.name} · {c.result}
                  </Tag>
                ))}
            </div>
          </div>
          <details className="av-fold" style={{ marginTop: 8 }}>
            <summary>查看检查明细说明</summary>
            <div className="av-fold-body">
              {checks
                .filter((c) => ['G01', 'G07'].includes(c.code))
                .map((c) => (
                  <p key={c.code}>
                    <b style={{ color: token.colorText }}>
                      {c.code} {c.name}（{c.result}）
                    </b>
                    ：{c.detail}
                  </p>
                ))}
            </div>
          </details>
        </div>
      </div>
    </article>
  );
}

function App() {
  const [data, setData] = React.useState(null);
  const [error, setError] = React.useState('');
  React.useEffect(() => {
    load()
      .then(setData)
      .catch((e) => setError(String(e)));
  }, []);
  if (error) return <Alert type="error" showIcon message={error} />;
  return data ? <Page d={data} /> : <Text type="secondary">正在读取资产负债表与重估底稿…</Text>;
}

ctx.render(<App />);
