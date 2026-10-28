const COMPANY = '01698.HK';   // 按钮只采这家公司和通用指标（利率等）的数据源，表格和最近几次也只看这家公司
const { React } = ctx.libs;
const { useState, useEffect } = React;
const { Button, Steps, Table: NativeTable, Alert, Tag, Space, Typography } = ctx.libs.antd;
const { Text, Paragraph } = Typography;
const FLOWS = {"manual": "zy5g20pzs6d", "scheduled": ["65oon6gllgl", "iiedfgok4at", "tnqi2s9xfea"]};   // 由 build_overview.py 从 workflows_state.json 写入（按 key 找当前版本）

const get = async (url, params) => (await ctx.request({ url, params }))?.data?.data;
const listOf = async (name, params = {}) => (await get(`${name}:list`, { pageSize: 200, ...params })) || [];
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
const when = (v) => (v ? new Date(v).toLocaleString('zh-CN', { hour12: false }) : '—');
const healthTag = (h) => <Tag color={h === '正常' ? 'green' : h === '已停用' ? 'default' : 'red'}>{h || '—'}</Tag>;
// 最新值：每个数据源取“最新观察日期”那天的观察（同一天有多条时取最后写入的）
async function latestValues(collectors) {
  const keys = collectors.filter((c) => c.metric_id && c.last_obs_date);
  if (!keys.length) return {};
  const rows = await listOf('vi_observation', { sort: '-id', pageSize: 500,
    filter: JSON.stringify({ $or: keys.map((c) => ({ metric_id: { $eq: c.metric_id }, obs_date: { $eq: c.last_obs_date } })) }) });
  const out = {};
  for (const r of rows) if (!(r.metric_id in out)) out[r.metric_id] = r.value;
  return out;
}
const STEP = { 排队: 0, 运行中: 1, 完成: 2 };
// 这家公司要采的数据源＝它用到的指标（自有、股价、汇率折算、无风险利率、重点跟踪、订阅的宏观数据）。
// 用途由数据库视图 vi_company_metric 汇总，指标的 used_by_codes 来自它；SQL vi_collect_targets 用的是同一个视图。
function ownCollectors(collectors, metrics, companies, coId) {
  const code = companies.find((c) => c.id === coId)?.code;
  const keep = new Set(metrics.filter((m) => m.company_id === coId
    || (code && (m.used_by_codes || '').includes(`,${code},`))).map((m) => m.id));
  return collectors.filter((c) => keep.has(c.metric_id));
}

async function flowState() {
  const keys = [FLOWS.manual, ...FLOWS.scheduled].filter(Boolean);
  const rows = keys.length ? await listOf('workflows', { filter: JSON.stringify({ key: { $in: keys }, current: true }) }) : [];
  return { manual: rows.find((r) => r.key === FLOWS.manual), scheduled: rows.filter((r) => FLOWS.scheduled.includes(r.key)) };
}

function Panel() {
  const [flows, setFlows] = useState(null);
  const [collectors, setCollectors] = useState([]);
  const [values, setValues] = useState({});
  const [lastRun, setLastRun] = useState(null);
  const [coId, setCoId] = useState(null);
  const [run, setRun] = useState(null);
  const [seconds, setSeconds] = useState(0);
  const [running, setRunning] = useState(false);
  const [results, setResults] = useState(null);
  const [error, setError] = useState(null);

  const refresh = async () => {
    const [f, c, ms, cos] = await Promise.all([flowState(), listOf('vi_collector', { sort: 'id' }),
      listOf('vi_metric', { pageSize: 500 }), listOf('vi_company')]);
    const id = cos.find((x) => x.code === COMPANY)?.id;
    const own = ownCollectors(c, ms, cos, id);
    const [r, v] = await Promise.all([
      id ? listOf('vi_collect_run', { sort: '-id', pageSize: 1, filter: JSON.stringify({ company_id: { $eq: id } }) }) : [],
      latestValues(own)]);
    setFlows(f); setCoId(id ?? null); setCollectors(own); setValues(v); setLastRun(r[0] || null);
  };
  useEffect(() => { refresh().catch((e) => setError(String(e?.message || e))); }, []);

  // 按钮只做一件事：在“采集运行”里新增一行；“④ 手动采集”工作流被它触发，跑完 采集→入库→自检 后把状态改成“完成”
  const start = async () => {
    setRunning(true); setError(null); setResults(null); setSeconds(0);
    try {
      const label = `手动｜${COMPANY}｜${new Date().toLocaleString('zh-CN', { hour12: false })}`;
      if (!coId) throw new Error(`公司表里没有代码为 ${COMPANY} 的公司`);
      const res = await ctx.request({ url: 'vi_collect_run:create', method: 'post', data: { label, trigger_source: '手动', status: '排队', company_id: coId } });
      const id = res?.data?.data?.id;
      if (!id) throw new Error('没能新建采集运行记录');
      const t0 = Date.now();
      let cur = { id, status: '排队' };
      setRun(cur);
      while (cur.status !== '完成' && Date.now() - t0 < 180000) {
        await sleep(1500);
        setSeconds(Math.round((Date.now() - t0) / 1000));
        cur = (await get('vi_collect_run:get', { filterByTk: id })) || cur;
        setRun(cur);
      }
      if (cur.status !== '完成') {
        throw new Error('3 分钟内没有跑完：到「设置 → 工作流 → ④ 手动采集」打开执行记录，看哪个节点出错。');
      }
      setResults(await listOf('vi_raw_capture', { filter: JSON.stringify({ run_id: { $eq: id } }), sort: 'id' }));
    } catch (e) {
      setError(String(e?.message || e));
    } finally {
      await refresh().catch(() => {});
      setRunning(false);
    }
  };

  // 本次采集里出问题的数据源（抓取失败、校验失败），直接在表格的状态列里显示原因
  const issueOf = (c) => (results || []).find((r) => String(r.collector_id) === String(c.id) && /失败/.test(r.status || ''));
  const ready = flows?.manual?.enabled;
  const scheduledOn = flows && flows.scheduled.length && flows.scheduled.every((w) => w.enabled);
  const step = run ? STEP[run.status] ?? 0 : -1;
  const stepStatus = (i) => (step < 0 ? 'wait' : error && i === Math.min(step, 1) ? 'error' : i < step || run?.status === '完成' ? 'finish' : i === step ? 'process' : 'wait');

  return (
    <div>
      {flows && !ready && (
        <Alert type="warning" showIcon style={{ marginBottom: 12 }}
          message="「④ 手动采集」工作流没有启用，按钮不会生效"
          description="到「设置 → 工作流」打开“④ 手动采集 · 按钮触发”。它只在按按钮时运行，不会定时运行。" />
      )}
      <Space wrap align="center" style={{ marginBottom: 12 }}>
        <Button type="primary" loading={running} disabled={!ready} onClick={start}>立即采集一次</Button>
        <Text type="secondary">只采这家公司用到的数据源，通常 5—30 秒。</Text>
      </Space>
      {run && (
        <Steps size="small" style={{ marginBottom: 12 }} items={[
          { title: '已发起', status: stepStatus(0) },
          { title: '采集、入库、自检', status: stepStatus(1), description: running ? `${seconds} 秒` : undefined },
          { title: '完成', status: stepStatus(2) },
        ]} />
      )}
      {error && <Alert type="error" showIcon style={{ marginBottom: 12 }} message={error} />}
      {results && run && (run.fetch_failed || run.invalid) ? (
        <Alert type="warning" showIcon style={{ marginBottom: 12 }} message={`本次：${run.summary || ''}`}
          description={run.fetch_failed
            ? '抓取失败＝连不上网站，不是解析问题：本机网络、代理/VPN 或网站临时不可用。稍后再按一次；一直失败就检查代理是否让这些国内网站直连。'
            : '校验失败＝拿到了网页但解析不出数，多半是网站改版，到「框架与后台 / 采集 / 原始采集记录」看原文。'} />
      ) : null}
      <Table size="small" pagination={false} rowKey="id" dataSource={collectors} columns={[
        { title: '数据源', dataIndex: 'name' },
        { title: '最新值', key: 'value', align: 'right', render: (_, c) => values[c.metric_id] ?? '—' },
        { title: '观察日期', dataIndex: 'last_obs_date', render: (v) => v || '—' },
        { title: '状态', key: 'state', render: (_, c) => {
          const bad = issueOf(c);
          return bad ? <span><Tag color="red">{bad.status}</Tag><Text type="secondary">{bad.fetch_note}</Text></span> : healthTag(c.health);
        } },
      ]} />
      <Paragraph type="secondary" style={{ marginTop: 8, marginBottom: 0 }}>
        {lastRun ? `最近采集 ${when(lastRun.requested_at)}（${lastRun.trigger_source || '—'}）：${lastRun.summary || ''}。` : '还没有采集过。'}
        {scheduledOn ? '定时采集已启用（每天 18:30）。' : '定时采集未启用。'}按完后刷新页面，下面的图表会用到新数据。
      </Paragraph>
    </div>
  );
}

ctx.render(<Panel />);


function Table(props) {
  const numberKeys = new Set(['prob', 'probability', 'core', 'm', 'coreValue', 'mature', 'growth', 'invest', 'direct', 'cash', 'inv', 'other', 'vps', 'quote', 'vsPrice', 'irr', 'cashIrr', 'ceiling', 'price', 'np', 'dps', 'g', 'vf', 'pf', 'cf']);
  const cols = (props.columns || []).map((c) => {
    const key = c.dataIndex || c.key;
    const numeric = numberKeys.has(key) || /^h\d{4}$|^y\d{4}$/.test(String(key));
    return { ...c, align: c.align || (numeric ? 'right' : 'left'),
      width: c.width || (numeric ? 140 : key === 'name' || key === 'scenario_name' ? 120 : 200),
      onHeaderCell: (...args) => ({ ...c.onHeaderCell?.(...args), style: { whiteSpace: 'normal', wordBreak: 'normal' } }),
    };
  });
  return <NativeTable {...props} columns={cols} scroll={props.scroll || { x: 'max-content' }}
    style={{ fontVariantNumeric: 'tabular-nums', ...props.style }} />;
}
