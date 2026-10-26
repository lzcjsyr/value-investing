async function run(ctx) {
  const COMPANY = "01810.HK";
  const { React } = ctx.libs;
  const { useState, useEffect } = React;
  const { Button, Steps, Table: NativeTable, Alert, Tag, Space, Typography } = ctx.libs.antd;
  const { Text, Paragraph } = Typography;
  const FLOWS = { "manual": "zy5g20pzs6d", "scheduled": ["65oon6gllgl", "iiedfgok4at", "tnqi2s9xfea"] };
  const get = async (url, params) => (await ctx.request({ url, params }))?.data?.data;
  const listOf = async (name, params = {}) => await get(`${name}:list`, { pageSize: 200, ...params }) || [];
  const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
  const when = (v) => v ? new Date(v).toLocaleString("zh-CN", { hour12: false }) : "\u2014";
  const healthTag = (h) => /* @__PURE__ */ ctx.libs.React.createElement(Tag, { color: h === "\u6B63\u5E38" ? "green" : h === "\u5DF2\u505C\u7528" ? "default" : "red" }, h || "\u2014");
  const STATUS_COLOR = { \u5DF2\u5165\u5E93: "green", \u91CD\u590D\u672A\u5165\u5E93: "blue", \u6293\u53D6\u5931\u8D25: "red", \u6821\u9A8C\u5931\u8D25: "orange", \u5F85\u5165\u5E93: "gold", \u91C7\u96C6\u4E2D: "gold" };
  const STEP = { \u6392\u961F: 0, \u8FD0\u884C\u4E2D: 1, \u5B8C\u6210: 2 };
  function ownCollectors(collectors, metrics, companies, coId) {
    const code = companies.find((c) => c.id === coId)?.code;
    const keep = new Set(metrics.filter((m) => m.company_id === coId || code && (m.used_by_codes || "").includes(`,${code},`)).map((m) => m.id));
    return collectors.filter((c) => keep.has(c.metric_id));
  }
  async function flowState() {
    const keys = [FLOWS.manual, ...FLOWS.scheduled].filter(Boolean);
    const rows = keys.length ? await listOf("workflows", { filter: JSON.stringify({ key: { $in: keys }, current: true }) }) : [];
    return { manual: rows.find((r) => r.key === FLOWS.manual), scheduled: rows.filter((r) => FLOWS.scheduled.includes(r.key)) };
  }
  function Panel() {
    const [flows, setFlows] = useState(null);
    const [collectors, setCollectors] = useState([]);
    const [allCollectors, setAllCollectors] = useState([]);
    const [runs, setRuns] = useState([]);
    const [coId, setCoId] = useState(null);
    const [run2, setRun] = useState(null);
    const [seconds, setSeconds] = useState(0);
    const [running, setRunning] = useState(false);
    const [results, setResults] = useState(null);
    const [error, setError] = useState(null);
    const refresh = async () => {
      const [f, c, ms, cos] = await Promise.all([
        flowState(),
        listOf("vi_collector", { sort: "id" }),
        listOf("vi_metric", { pageSize: 500 }),
        listOf("vi_company")
      ]);
      const id = cos.find((x) => x.code === COMPANY)?.id;
      const r = id ? await listOf("vi_collect_run", { sort: "-id", pageSize: 5, filter: JSON.stringify({ company_id: { $eq: id } }) }) : [];
      setFlows(f);
      setCoId(id ?? null);
      setAllCollectors(c);
      setCollectors(ownCollectors(c, ms, cos, id));
      setRuns(r);
    };
    useEffect(() => {
      refresh().catch((e) => setError(String(e?.message || e)));
    }, []);
    const start = async () => {
      setRunning(true);
      setError(null);
      setResults(null);
      setSeconds(0);
      try {
        const label = `\u624B\u52A8\uFF5C${COMPANY}\uFF5C${(/* @__PURE__ */ new Date()).toLocaleString("zh-CN", { hour12: false })}`;
        if (!coId) throw new Error(`\u516C\u53F8\u8868\u91CC\u6CA1\u6709\u4EE3\u7801\u4E3A ${COMPANY} \u7684\u516C\u53F8`);
        const res = await ctx.request({ url: "vi_collect_run:create", method: "post", data: { label, trigger_source: "\u624B\u52A8", status: "\u6392\u961F", company_id: coId } });
        const id = res?.data?.data?.id;
        if (!id) throw new Error("\u6CA1\u80FD\u65B0\u5EFA\u91C7\u96C6\u8FD0\u884C\u8BB0\u5F55");
        const t0 = Date.now();
        let cur = { id, status: "\u6392\u961F" };
        setRun(cur);
        while (cur.status !== "\u5B8C\u6210" && Date.now() - t0 < 18e4) {
          await sleep(1500);
          setSeconds(Math.round((Date.now() - t0) / 1e3));
          cur = await get("vi_collect_run:get", { filterByTk: id }) || cur;
          setRun(cur);
        }
        if (cur.status !== "\u5B8C\u6210") {
          throw new Error("3 \u5206\u949F\u5185\u6CA1\u6709\u8DD1\u5B8C\uFF1A\u5230\u300C\u8BBE\u7F6E \u2192 \u5DE5\u4F5C\u6D41 \u2192 \u2463 \u624B\u52A8\u91C7\u96C6\u300D\u6253\u5F00\u6267\u884C\u8BB0\u5F55\uFF0C\u770B\u54EA\u4E2A\u8282\u70B9\u51FA\u9519\u3002");
        }
        setResults(await listOf("vi_raw_capture", { filter: JSON.stringify({ run_id: { $eq: id } }), sort: "id" }));
      } catch (e) {
        setError(String(e?.message || e));
      } finally {
        await refresh().catch(() => {
        });
        setRunning(false);
      }
    };
    const nameOf = (id) => allCollectors.find((c) => String(c.id) === String(id))?.name || `\u6570\u636E\u6E90 ${id}`;
    const ready = flows?.manual?.enabled;
    const scheduledOn = flows && flows.scheduled.length && flows.scheduled.every((w) => w.enabled);
    const step = run2 ? STEP[run2.status] ?? 0 : -1;
    const stepStatus = (i) => step < 0 ? "wait" : error && i === Math.min(step, 1) ? "error" : i < step || run2?.status === "\u5B8C\u6210" ? "finish" : i === step ? "process" : "wait";
    return /* @__PURE__ */ ctx.libs.React.createElement("div", null, flows && !ready && /* @__PURE__ */ ctx.libs.React.createElement(
      Alert,
      {
        type: "warning",
        showIcon: true,
        style: { marginBottom: 12 },
        message: "\u300C\u2463 \u624B\u52A8\u91C7\u96C6\u300D\u5DE5\u4F5C\u6D41\u6CA1\u6709\u542F\u7528\uFF0C\u6309\u94AE\u4E0D\u4F1A\u751F\u6548",
        description: "\u5230\u300C\u8BBE\u7F6E \u2192 \u5DE5\u4F5C\u6D41\u300D\u6253\u5F00\u201C\u2463 \u624B\u52A8\u91C7\u96C6 \xB7 \u6309\u94AE\u89E6\u53D1\u201D\u3002\u5B83\u53EA\u5728\u6309\u6309\u94AE\u65F6\u8FD0\u884C\uFF0C\u4E0D\u4F1A\u5B9A\u65F6\u8FD0\u884C\u3002"
      }
    ), /* @__PURE__ */ ctx.libs.React.createElement(Space, { wrap: true, align: "center", style: { marginBottom: 12 } }, /* @__PURE__ */ ctx.libs.React.createElement(Button, { type: "primary", loading: running, disabled: !ready, onClick: start }, "\u7ACB\u5373\u91C7\u96C6\u4E00\u6B21"), /* @__PURE__ */ ctx.libs.React.createElement(Text, { type: "secondary" }, "\u53EA\u91C7\u8FD9\u5BB6\u516C\u53F8\u548C\u901A\u7528\u6307\u6807\uFF08\u5229\u7387\u7B49\uFF09\u7684\u6570\u636E\u6E90\uFF1A\u91C7\u96C6 \u2192 \u5165\u5E93 \u2192 \u81EA\u68C0\uFF0C\u901A\u5E38 5\u201430 \u79D2\uFF1B\u7ED3\u679C\u8BB0\u5728\u300C\u6846\u67B6\u4E0E\u540E\u53F0 / \u91C7\u96C6 / \u91C7\u96C6\u8FD0\u884C\u300D\u3002\u5176\u4ED6\u516C\u53F8\u5728\u5404\u81EA\u7684\u9A7E\u9A76\u8231\u91CC\u91C7\u3002")), run2 && /* @__PURE__ */ ctx.libs.React.createElement(Steps, { size: "small", style: { marginBottom: 12 }, items: [
      { title: "\u5DF2\u53D1\u8D77", status: stepStatus(0) },
      { title: "\u91C7\u96C6\u3001\u5165\u5E93\u3001\u81EA\u68C0", status: stepStatus(1), description: running ? `${seconds} \u79D2` : void 0 },
      { title: "\u5B8C\u6210", status: stepStatus(2) }
    ] }), error && /* @__PURE__ */ ctx.libs.React.createElement(Alert, { type: "error", showIcon: true, style: { marginBottom: 12 }, message: error }), results && run2 && /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { marginBottom: 12 } }, /* @__PURE__ */ ctx.libs.React.createElement(
      Alert,
      {
        showIcon: true,
        style: { marginBottom: 8 },
        type: run2.fetch_failed || run2.invalid ? "warning" : "success",
        message: `\u672C\u6B21${run2.summary ? "\uFF1A" + run2.summary : ""}\uFF08\u7528\u65F6 ${run2.seconds ?? seconds} \u79D2\uFF09`,
        description: run2.fetch_failed ? "\u6293\u53D6\u5931\u8D25\uFF1D\u8FDE\u4E0D\u4E0A\u7F51\u7AD9\uFF0C\u4E0D\u662F\u89E3\u6790\u95EE\u9898\uFF1A\u672C\u673A\u7F51\u7EDC\u3001\u4EE3\u7406/VPN \u6216\u7F51\u7AD9\u4E34\u65F6\u4E0D\u53EF\u7528\u3002\u7A0D\u540E\u518D\u6309\u4E00\u6B21\uFF1B\u4E00\u76F4\u5931\u8D25\u5C31\u68C0\u67E5\u4EE3\u7406\u662F\u5426\u8BA9\u8FD9\u4E9B\u56FD\u5185\u7F51\u7AD9\u76F4\u8FDE\u3002" : run2.duplicates ? "\u201C\u91CD\u590D\u201D\u662F\u6B63\u5E38\u7684\uFF1A\u540C\u4E00\u5929\u7684\u6570\u5DF2\u7ECF\u91C7\u8FC7\uFF08\u4F8B\u5982\u6536\u76D8\u540E\u3001\u4E0B\u4E00\u4E2A\u4EA4\u6613\u65E5\u5F00\u76D8\u524D\u518D\u6309\uFF09\u3002" : void 0
      }
    ), /* @__PURE__ */ ctx.libs.React.createElement(Table, { size: "small", pagination: false, rowKey: "id", dataSource: results, scroll: { x: "max-content" }, columns: [
      { title: "\u6570\u636E\u6E90", key: "c", render: (_, r) => nameOf(r.collector_id) },
      { title: "\u6293\u53D6\u60C5\u51B5", dataIndex: "fetch_note" },
      { title: "\u89E3\u6790\u65E5\u671F", dataIndex: "parsed_date", render: (v) => v || "\u2014" },
      { title: "\u89E3\u6790\u6570\u503C", dataIndex: "parsed_value", render: (v) => v === null || v === void 0 ? "\u2014" : v },
      { title: "\u5904\u7406\u7ED3\u679C", dataIndex: "status", render: (v) => /* @__PURE__ */ ctx.libs.React.createElement(Tag, { color: STATUS_COLOR[v] }, v) }
    ] })), /* @__PURE__ */ ctx.libs.React.createElement(Table, { size: "small", pagination: false, rowKey: "id", dataSource: collectors, scroll: { x: "max-content" }, columns: [
      { title: "\u6570\u636E\u6E90", dataIndex: "name" },
      { title: "\u5065\u5EB7", dataIndex: "health", render: healthTag },
      { title: "\u6700\u8FD1\u91C7\u96C6", dataIndex: "last_collected", render: when },
      { title: "\u6700\u65B0\u89C2\u5BDF\u65E5\u671F", dataIndex: "last_obs_date", render: (v) => v || "\u2014" },
      { title: "\u6700\u8FD1\u81EA\u68C0", dataIndex: "selfcheck_result", render: (v) => v || "\u2014" }
    ] }), runs.length > 0 && /* @__PURE__ */ ctx.libs.React.createElement(Paragraph, { type: "secondary", style: { marginTop: 8, marginBottom: 0 } }, "\u8FD9\u5BB6\u516C\u53F8\u6700\u8FD1\u51E0\u6B21\uFF1A", runs.map((r) => `${when(r.requested_at)}\uFF08${r.trigger_source || "\u2014"}\uFF09${r.summary || ""}`).join("\uFF1B")), /* @__PURE__ */ ctx.libs.React.createElement(Paragraph, { type: "secondary", style: { marginTop: 4, marginBottom: 0 } }, scheduledOn ? "\u5B9A\u65F6\u91C7\u96C6\u5DF2\u542F\u7528\uFF1A\u6BCF\u5929 18:30 \u91C7\u96C6\u300118:40 \u5165\u5E93\u300119:10 \u81EA\u68C0\u3002\u7535\u8111\u5173\u673A\u6216\u4F11\u7720\u9519\u8FC7\u7684\u65F6\u70B9\u4E0D\u4F1A\u8865\u8DD1\uFF0C\u53EF\u4EE5\u6309\u4E0A\u9762\u7684\u6309\u94AE\u8865\u4E00\u6B21\u3002" : "\u5B9A\u65F6\u91C7\u96C6\u672A\u542F\u7528\uFF08\u300C\u8BBE\u7F6E \u2192 \u5DE5\u4F5C\u6D41\u300D\u91CC\u7684 \u2460\u2461\u2462\uFF09\uFF1B\u4E0D\u6253\u5F00\u4E5F\u53EF\u4EE5\u968F\u65F6\u6309\u6309\u94AE\u624B\u52A8\u91C7\u96C6\u3002", "\u6309\u5B8C\u540E\u5237\u65B0\u9875\u9762\uFF0C\u4E0B\u9762\u7684\u56FE\u8868\u4F1A\u7528\u5230\u65B0\u6570\u636E\u3002"));
  }
  ctx.render(/* @__PURE__ */ ctx.libs.React.createElement(Panel, null));
  function Table(props) {
    const numberKeys = /* @__PURE__ */ new Set(["prob", "probability", "core", "m", "coreValue", "mature", "growth", "invest", "direct", "cash", "inv", "other", "vps", "quote", "vsPrice", "irr", "cashIrr", "ceiling", "price", "np", "dps", "g", "vf", "pf", "cf"]);
    const cols = (props.columns || []).map((c) => {
      const key = c.dataIndex || c.key;
      const numeric = numberKeys.has(key) || /^h\d{4}$|^y\d{4}$/.test(String(key));
      return {
        ...c,
        align: c.align || (numeric ? "right" : "left"),
        width: c.width || (numeric ? 140 : key === "name" || key === "scenario_name" ? 120 : 200),
        onHeaderCell: (...args) => ({ ...c.onHeaderCell?.(...args), style: { whiteSpace: "normal", wordBreak: "normal" } })
      };
    });
    return /* @__PURE__ */ ctx.libs.React.createElement(
      NativeTable,
      {
        ...props,
        columns: cols,
        scroll: props.scroll || { x: "max-content" },
        style: { fontVariantNumeric: "tabular-nums", ...props.style }
      }
    );
  }
}
export {
  run as default
};
