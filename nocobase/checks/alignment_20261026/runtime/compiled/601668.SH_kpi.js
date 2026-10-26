async function run(ctx) {
  const COMPANY = "601668.SH";
  const IRR_ONLY = true;
  const { React } = ctx.libs;
  const { useState } = React;
  const { Card, Col, Row, Statistic, Typography, Alert, Slider, InputNumber, Button, Table: NativeTable, Tag, Space, message } = ctx.libs.antd;
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
  async function listRows(collectionName, filter, pageSize = 200) {
    const resource = ctx.makeResource("MultiRecordResource");
    resource.setResourceName(collectionName);
    resource.setPageSize?.(pageSize);
    if (filter) resource.setFilter?.(filter);
    await resource.refresh();
    return resource.getData() || [];
  }
  const fmt = (v, d = 2) => v === null || v === void 0 || Number.isNaN(v) ? "\u2014" : Number(v).toFixed(d);
  const pct = (v, d = 2) => v === null || v === void 0 || Number.isNaN(v) ? "\u2014" : (Number(v) * 100).toFixed(d) + "%";
  function ownCollectors(collectors, metrics, companies, coId) {
    const code = companies.find((c) => c.id === coId)?.code;
    const keep = new Set(metrics.filter((m) => m.company_id === coId || code && (m.used_by_codes || "").includes(`,${code},`)).map((m) => m.id));
    return collectors.filter((c) => keep.has(c.metric_id));
  }
  function presentValue(flows, terminal, g, r) {
    if (!(r > g) || !terminal) return null;
    let pv = 0;
    for (const f of flows) {
      if (f.tau > 0 && f.dps !== null && f.dps !== void 0) pv += f.dps / Math.pow(1 + r, f.tau);
    }
    return pv + terminal.dps * (1 + g) / (r - g) / Math.pow(1 + r, terminal.tau);
  }
  try {
    let Panel = function() {
      const [reqPct, setReqPct] = useState(initial);
      const [trialMult, setTrialMult] = useState(null);
      const [saving, setSaving] = useState(false);
      const [convertRmb, setConvertRmb] = useState(null);
      const req = reqPct / 100;
      const rows = scenarios.map((v) => {
        const ceiling = presentValue(v.flows, v.terminal, v.terminal_growth, req);
        return {
          key: v.id,
          name: v.scenario_name,
          irr: v.implied_irr,
          cashIrr: v.cash_implied_irr,
          ceiling,
          price: v.market_price,
          ok: v.implied_irr !== null && v.implied_irr !== void 0 && v.implied_irr >= req
        };
      });
      const baseRow = rows.find((r) => r.name === base.scenario_name) || rows[0] || {};
      const save = async () => {
        setSaving(true);
        try {
          await ctx.request({ url: "vi_model:update", method: "post", params: { filterByTk: model.id }, data: { required_return: req } });
          message.success(`\u5DF2\u4FDD\u5B58\uFF1A\u8981\u6C42\u6536\u76CA\u7387 ${reqPct}%\uFF08\u5237\u65B0\u540E\u7ED3\u8BBA\u4E0E\u56FE\u8868\u540C\u6B65\u66F4\u65B0\uFF09`);
        } catch (e) {
          message.error("\u4FDD\u5B58\u5931\u8D25\uFF1A" + String(e?.message || e));
        } finally {
          setSaving(false);
        }
      };
      const fx = company.latest_fx;
      const toHkd = (value) => fx > 0 && value !== null && value !== void 0 ? Number(value) / fx : null;
      const hasCore = sotpBase && sotpBase.core_earnings !== null && sotpBase.core_earnings !== void 0;
      const hasSeg = sotpBase && sotpBase.segments_value !== null && sotpBase.segments_value !== void 0;
      const baseMult = (r) => hasCore ? r.multiple : r.mature_multiple;
      const sotpCalc = sotp.map((r) => {
        const m = trialMult ?? baseMult(r);
        const anchor = hasCore ? r.core_value : r.mature_value ?? 0;
        const anchorTrial = hasCore ? r.core_earnings * m : (r.mature_earn_pv ?? 0) * m + (r.mature_interim_pv ?? 0);
        const equity = r.equity_value === null || r.equity_value === void 0 ? null : r.equity_value - anchor + anchorTrial;
        const vps = equity === null ? null : equity / r.shares;
        return {
          key: r.id,
          name: r.scenario_name,
          prob: r.probability,
          core: r.core_earnings,
          m,
          coreValue: hasCore ? r.core_earnings * m : null,
          mature: hasSeg ? anchorTrial : null,
          growth: r.growth_value,
          invest: r.invest_value,
          direct: r.direct_value,
          cash: r.usable_net_cash,
          inv: r.investments,
          other: r.minority_other,
          vps,
          quote: fx && vps !== null ? vps / fx : null,
          vsPrice: r.market_price && vps ? r.market_price / vps - 1 : null
        };
      });
      const sotpBaseCalc = sotpCalc.find((r) => sotpBase && r.key === sotpBase.id) || sotpCalc[0] || {};
      const hasDirect = sotp.some((r) => r.direct_value !== null && r.direct_value !== void 0);
      const hasInvest = sotp.some((r) => r.invest_value !== null && r.invest_value !== void 0);
      const probs = sotpCalc.filter((r) => r.prob !== null && r.prob !== void 0 && r.vps !== null);
      const weighted = probs.length === sotpCalc.length && probs.length > 0 ? probs.reduce((a, r) => a + r.prob * r.vps, 0) / probs.reduce((a, r) => a + r.prob, 0) : null;
      const quoteReference = sotpPrimary ? weighted !== null ? weighted : sotpCalc.find((r) => r.name === "\u60B2\u89C2")?.vps : baseRow.ceiling;
      const quoteReferenceTitle = sotpPrimary ? weighted !== null ? "\u6982\u7387\u52A0\u6743\u4EF7\u503C" : "\u60B2\u89C2\u5206\u90E8\u4F30\u503C" : `\u56DE\u62A5\u95E8\u69DB ${reqPct}% \u7684\u6700\u9AD8\u4E70\u5165\u4EF7`;
      const sotpTitle = !sotpPrimary ? "\u5206\u90E8\u52A0\u603B\uFF08\u4EA4\u53C9\u9A8C\u8BC1\uFF09" : hasSeg ? "\u4E3B\u4F30\u503C\uFF1A\u7ECF\u8425\u5206\u90E8\u4F30\u503C\uFF08\u6210\u719F\u4E1A\u52A1 \xD7 \u500D\u6570 \uFF0B \u6210\u957F\u4E1A\u52A1\u7A33\u6001\u6298\u73B0 \uFF0B \u6295\u5165\u671F\u6210\u672C\u6216\u76F4\u63A5\u4F30\u503C \uFF0B \u51C0\u73B0\u91D1\u4E0E\u6295\u8D44\uFF09" : "\u4E3B\u4F30\u503C\uFF1A\u5206\u90E8\u52A0\u603B\uFF08\u6838\u5FC3\u4E1A\u52A1\u76C8\u5229 \xD7 \u5408\u7406\u500D\u6570 \uFF0B \u53EF\u7528\u51C0\u73B0\u91D1 \uFF0B \u5BF9\u5916\u6295\u8D44\uFF09";
      const sotpCard = sotp.length === 0 ? null : /* @__PURE__ */ ctx.libs.React.createElement(Card, { size: "small", style: { marginBottom: 12 }, title: sotpTitle }, /* @__PURE__ */ ctx.libs.React.createElement(Row, { gutter: [12, 12] }, /* @__PURE__ */ ctx.libs.React.createElement(Col, { xs: 12, md: 6 }, /* @__PURE__ */ ctx.libs.React.createElement(Statistic, { title: `\u57FA\u51C6\u6BCF\u80A1\u4EF7\u503C\uFF08${trialMult ? "\u8BD5\u7B97\u500D\u6570" : hasCore ? "\u5408\u7406\u500D\u6570" : "\u6210\u719F\u4E1A\u52A1\u500D\u6570"} ${fmt(sotpBaseCalc.m, 1)} \u500D\uFF09`, value: fmt(sotpBaseCalc.vps), suffix: fx ? `\u5143 \u2248 ${fmt(sotpBaseCalc.quote)} \u6E2F\u5143` : "\u5143" })), /* @__PURE__ */ ctx.libs.React.createElement(Col, { xs: 12, md: 6 }, /* @__PURE__ */ ctx.libs.React.createElement(Statistic, { title: `\u5E02\u573A\u4EF7\uFF08${base.market_date || "\u2014"}\uFF09`, value: fmt(sotpBase.market_price), suffix: "\u5143" })), /* @__PURE__ */ ctx.libs.React.createElement(Col, { xs: 12, md: 6 }, /* @__PURE__ */ ctx.libs.React.createElement(Statistic, { title: "\u5E02\u573A\u4EF7\u76F8\u5BF9\u57FA\u51C6\u4EF7\u503C", value: sotpBaseCalc.vsPrice === null ? "\u2014" : pct(sotpBaseCalc.vsPrice, 1), valueStyle: { color: sotpBaseCalc.vsPrice < 0 ? "#389e0d" : "#cf1322" } })), weighted !== null ? /* @__PURE__ */ ctx.libs.React.createElement(Col, { xs: 12, md: 6 }, /* @__PURE__ */ ctx.libs.React.createElement(Statistic, { title: "\u6982\u7387\u52A0\u6743\u6BCF\u80A1\u4EF7\u503C", value: fmt(weighted), suffix: fx ? `\u5143 \u2248 ${fmt(weighted / fx)}` : "\u5143" })) : /* @__PURE__ */ ctx.libs.React.createElement(Col, { xs: 12, md: 6 }, /* @__PURE__ */ ctx.libs.React.createElement(Statistic, { title: "\u5E02\u573A\u7ED9\u6838\u5FC3\u4E1A\u52A1\u7684\u9690\u542B\u500D\u6570\uFF08\u57FA\u51C6\uFF09", value: fmt(sotpBase.implied_core_multiple, 1), suffix: "\u500D" }))), hasSeg ? /* @__PURE__ */ ctx.libs.React.createElement(Row, { gutter: [12, 12], style: { marginTop: 8 } }, /* @__PURE__ */ ctx.libs.React.createElement(Col, { xs: 12, md: 6 }, /* @__PURE__ */ ctx.libs.React.createElement(Statistic, { title: "\u5E02\u573A\u9690\u542B\u6210\u719F\u4E1A\u52A1\u500D\u6570\uFF08\u672C\u6A21\u578B\uFF09", value: `${fmt(sotpBase.implied_mature_multiple, 1)}\uFF08${fmt(sotpBase.mature_multiple, 1)}\uFF09`, suffix: "\u500D" })), /* @__PURE__ */ ctx.libs.React.createElement(Col, { xs: 12, md: 6 }, /* @__PURE__ */ ctx.libs.React.createElement(Statistic, { title: "\u5E02\u573A\u9690\u542B\u6210\u957F\u4E1A\u52A1\u4EF7\u503C\uFF08\u672C\u6A21\u578B\uFF09", value: `${fmt(sotpBase.implied_growth_value, 0)}\uFF08${fmt(sotpBase.growth_value, 0)}\uFF09`, suffix: "\u4EBF\u5143" })), hasDirect ? /* @__PURE__ */ ctx.libs.React.createElement(Col, { xs: 12, md: 6 }, /* @__PURE__ */ ctx.libs.React.createElement(Statistic, { title: "\u76F4\u63A5\u4F30\u503C\u4E1A\u52A1\uFF08\u53EF\u6BD4\u516C\u53F8\u6216\u4E3B\u89C2\u5224\u65AD\uFF09", value: fmt(sotpBase.direct_value, 0), suffix: "\u4EBF\u5143" })) : /* @__PURE__ */ ctx.libs.React.createElement(Col, { xs: 12, md: 6 }, /* @__PURE__ */ ctx.libs.React.createElement(Statistic, { title: "\u6295\u5165\u671F\u4E1A\u52A1\uFF08\u627F\u8BFA\u6295\u5165\u7684\u6210\u672C\uFF09", value: fmt(sotpBase.invest_value, 0), suffix: "\u4EBF\u5143" })), /* @__PURE__ */ ctx.libs.React.createElement(Col, { xs: 12, md: 6 }, /* @__PURE__ */ ctx.libs.React.createElement(Statistic, { title: "\u5173\u6CE8\u4EF7\uFF08\u4F4E\u6863/\u9AD8\u6863\u8FB9\u9645\uFF09", value: `${fmt(sotpBase.watch_low)} / ${fmt(sotpBase.watch_high)}`, suffix: "\u5143" }))) : null, /* @__PURE__ */ ctx.libs.React.createElement(Space, { wrap: true, align: "center", style: { margin: "8px 0" } }, /* @__PURE__ */ ctx.libs.React.createElement(Typography.Text, { strong: true }, hasCore ? "\u8BD5\u7B97\u500D\u6570" : "\u8BD5\u7B97\u6210\u719F\u4E1A\u52A1\u500D\u6570"), /* @__PURE__ */ ctx.libs.React.createElement(Slider, { style: { width: 240 }, min: 3, max: 30, step: 0.5, value: trialMult ?? baseMult(sotpBase), onChange: (v) => setTrialMult(v) }), /* @__PURE__ */ ctx.libs.React.createElement(InputNumber, { min: 1, max: 60, step: 0.5, value: trialMult ?? Number(fmt(baseMult(sotpBase), 1)), onChange: (v) => setTrialMult(v), addonAfter: "\u500D" }), /* @__PURE__ */ ctx.libs.React.createElement(Button, { onClick: () => setTrialMult(null) }, "\u6062\u590D\u5404\u60C5\u666F\u500D\u6570")), /* @__PURE__ */ ctx.libs.React.createElement(Table, { size: "small", pagination: false, dataSource: sotpCalc, columns: [
        { title: "\u60C5\u666F", dataIndex: "name" },
        ...weighted !== null ? [{ title: "\u6982\u7387", dataIndex: "prob", render: (v) => pct(v, 0) }] : [],
        ...hasCore ? [
          { title: `\u6838\u5FC3\u76C8\u5229\uFF08${sotpBase.core_year} \u5E74\uFF0C\u4EBF\u5143\uFF09`, dataIndex: "core", render: (v) => fmt(v, 1) },
          { title: "\u500D\u6570", dataIndex: "m", render: (v) => fmt(v, 1) },
          { title: "\u6838\u5FC3\u4E1A\u52A1\u4EF7\u503C\uFF08\u4EBF\u5143\uFF09", dataIndex: "coreValue", render: (v) => fmt(v, 0) }
        ] : [],
        ...hasSeg ? [
          { title: "\u6210\u719F\u4E1A\u52A1\uFF08\u4EBF\u5143\uFF09", dataIndex: "mature", render: (v) => fmt(v, 0) },
          { title: "\u6210\u957F\u4E1A\u52A1\uFF08\u4EBF\u5143\uFF09", dataIndex: "growth", render: (v) => fmt(v, 0) }
        ] : [],
        ...hasSeg && hasInvest ? [{ title: "\u6295\u5165\u671F\u4E1A\u52A1\uFF08\u4EBF\u5143\uFF09", dataIndex: "invest", render: (v) => fmt(v, 0) }] : [],
        ...hasSeg && hasDirect ? [{ title: "\u76F4\u63A5\u4F30\u503C\u4E1A\u52A1\uFF08\u4EBF\u5143\uFF09", dataIndex: "direct", render: (v) => fmt(v, 0) }] : [],
        { title: "\u53EF\u7528\u51C0\u73B0\u91D1\uFF08\u4EBF\u5143\uFF09", dataIndex: "cash", render: (v) => fmt(v, 0) },
        { title: "\u5BF9\u5916\u6295\u8D44\xB7\u6298\u540E\uFF08\u4EBF\u5143\uFF09", dataIndex: "inv", render: (v) => fmt(v, 0) },
        { title: "\u5C11\u6570\u80A1\u4E1C\u4E0E\u5176\u4ED6\uFF08\u4EBF\u5143\uFF09", dataIndex: "other", render: (v) => fmt(v, 0) },
        { title: "\u6BCF\u80A1\u4EF7\u503C\uFF08\u5143\uFF09", dataIndex: "vps", render: (v) => /* @__PURE__ */ ctx.libs.React.createElement("b", null, fmt(v)) },
        ...fx ? [{ title: "\u6BCF\u80A1\u4EF7\u503C\uFF08\u6E2F\u5143\uFF09", dataIndex: "quote", render: (v) => fmt(v) }] : [],
        { title: "\u5E02\u573A\u4EF7\u76F8\u5BF9", dataIndex: "vsPrice", render: (v) => v === null ? "\u2014" : pct(v, 1) }
      ] }), /* @__PURE__ */ ctx.libs.React.createElement(Typography.Paragraph, { type: "secondary", style: { marginTop: 8, marginBottom: 0 } }, hasSeg ? /* @__PURE__ */ ctx.libs.React.createElement(React.Fragment, null, "\u7ECF\u8425\u5206\u90E8\u6309\u53D1\u5C55\u9636\u6BB5\u4F30\u503C\uFF08\u660E\u7EC6\u89C1\u300C\u9884\u6D4B\u4E0E\u4F30\u503C / \u4F30\u503C / \u7ECF\u8425\u5206\u90E8\uFF08\u7F16\u8F91\uFF09\u300D\uFF09\uFF1A\u6210\u719F\u4E1A\u52A1\uFF1D\u6B63\u5E38\u5316\u76C8\u5229\xD7\u500D\u6570\uFF0C\u500D\u6570\uFF1D(1\u2212\u6C38\u7EED\u589E\u957F\u7387\xF7\u65B0\u589E\u6295\u8D44\u56DE\u62A5\u7387)\xF7(\u6298\u73B0\u7387\u2212\u6C38\u7EED\u589E\u957F\u7387)\uFF1B\u6210\u957F\u4E1A\u52A1\uFF1D\u7A33\u6001\u5E74\u76C8\u5229\xD7\u9000\u51FA\u500D\u6570\u6298\u56DE\u8D44\u4EA7\u8D1F\u503A\u65E5\uFF0C\u52A0\u4E0A\u5230\u7A33\u6001\u524D\u7684\u671F\u95F4\u73B0\u91D1\u6D41\uFF1B\u6295\u5165\u671F\u4E1A\u52A1\uFF1D\u5DF2\u627F\u8BFA\u6295\u5165\u7684\u7A0E\u540E\u73B0\u503C\u52A0\u627F\u8BFA\u671F\u540E\u5E74\u6210\u672C\uFF08\u8D1F\u503C\uFF09\uFF1B\u76F4\u63A5\u4F30\u503C\u4E1A\u52A1\uFF1D\u6309\u53EF\u6BD4\u516C\u53F8\u6216\u4E3B\u89C2\u5224\u65AD\u7ED9\u51FA\u7684\u6574\u4F53\u4EF7\u503C\u3002\u975E\u7ECF\u8425\u90E8\u5206\u7EDF\u4E00\u622A\u81F3 ", sotpBase.as_of, "\uFF0C\u660E\u7EC6\u89C1\u300C\u9884\u6D4B\u4E0E\u4F30\u503C / \u4F30\u503C / \u8D44\u4EA7\u9879\u76EE\uFF08\u7F16\u8F91\uFF09\u300D\u3002 \u5E02\u573A\u9690\u542B\u503C\uFF1D\u5176\u4F59\u90E8\u5206\u6309\u672C\u6A21\u578B\u53D6\u503C\u65F6\uFF0C\u5E02\u503C\u5BF9\u5E94\u7684\u6210\u719F\u4E1A\u52A1\u500D\u6570\u6216\u6210\u957F\u4E1A\u52A1\u4EF7\u503C\u3002\u8BD5\u7B97\u500D\u6570\u53EA\u6539\u6210\u719F\u4E1A\u52A1\u7684\u500D\u6570\u3002\u80A1\u4E1C\u56DE\u62A5\u6298\u73B0\uFF08\u4EA4\u53C9\u9A8C\u8BC1\uFF09\u57FA\u51C6 ", fmt(sotpBase.ddm_value), " \u5143\u3002") : /* @__PURE__ */ ctx.libs.React.createElement(React.Fragment, null, "\u5408\u7406\u500D\u6570\uFF1D(1\u2212\u6C38\u7EED\u589E\u957F\u7387\xF7\u65B0\u589E\u6295\u8D44\u56DE\u62A5\u7387)\xF7(\u6298\u73B0\u7387\u2212\u6C38\u7EED\u589E\u957F\u7387)\uFF0C\u53EF\u5728\u201C\u60C5\u666F\u201D\u91CC\u624B\u586B\u8986\u76D6\uFF1B\u975E\u7ECF\u8425\u90E8\u5206\u7EDF\u4E00\u622A\u81F3 ", sotpBase.as_of, "\uFF08\u4E0E\u80A1\u672C\u540C\u65E5\uFF09\uFF0C\u660E\u7EC6\u89C1\u300C\u9884\u6D4B\u4E0E\u4F30\u503C / \u4F30\u503C / \u8D44\u4EA7\u9879\u76EE\uFF08\u7F16\u8F91\uFF09\u300D\u3002 \u9690\u542B\u500D\u6570\uFF1D(\u5E02\u503C\u2212\u975E\u7ECF\u8425\u90E8\u5206)\xF7\u6838\u5FC3\u76C8\u5229\uFF1A\u5E02\u573A\u4E3A\u6838\u5FC3\u4E1A\u52A1\u4ED8\u4E86\u51E0\u500D\u3002\u80A1\u606F\u8D34\u73B0\u53E3\u5F84\uFF08\u4EA4\u53C9\u9A8C\u8BC1\uFF09\u57FA\u51C6 ", fmt(sotpBase.ddm_value), " \u5143\u3002")));
      return /* @__PURE__ */ ctx.libs.React.createElement("div", null, /* @__PURE__ */ ctx.libs.React.createElement(Typography.Title, { level: 4, style: { marginTop: 0 } }, company.name, "\uFF08", company.code, "\uFF09\xB7 ", model.name), COMPANY.endsWith(".HK") && /* @__PURE__ */ ctx.libs.React.createElement(Card, { size: "small", title: `\u6E2F\u80A1\u901F\u89C8 \xB7 ${COMPANY} \xB7 \u6E2F\u5143 / \u666E\u901A\u80A1`, style: { marginBottom: 12 } }, /* @__PURE__ */ ctx.libs.React.createElement(Row, { gutter: [16, 16] }, /* @__PURE__ */ ctx.libs.React.createElement(Col, { xs: 12, md: 6 }, /* @__PURE__ */ ctx.libs.React.createElement(Statistic, { title: `\u6E2F\u80A1\u5E02\u573A\u4EF7 \xB7 ${company.latest_price_date || "\u2014"}`, value: fmt(company.latest_price_raw), suffix: "\u6E2F\u5143" })), /* @__PURE__ */ ctx.libs.React.createElement(Col, { xs: 12, md: 6 }, /* @__PURE__ */ ctx.libs.React.createElement(Statistic, { title: sotpPrimary ? "\u57FA\u51C6\u5206\u90E8\u4F30\u503C" : "\u57FA\u51C6\u6BCF\u80A1\u4EF7\u503C", value: fmt(toHkd(sotpPrimary ? sotpBaseCalc.vps : base.value_today)), suffix: "\u6E2F\u5143" })), /* @__PURE__ */ ctx.libs.React.createElement(Col, { xs: 12, md: 6 }, /* @__PURE__ */ ctx.libs.React.createElement(Statistic, { title: quoteReferenceTitle, value: fmt(toHkd(quoteReference)), suffix: "\u6E2F\u5143" })), /* @__PURE__ */ ctx.libs.React.createElement(Col, { xs: 12, md: 6 }, /* @__PURE__ */ ctx.libs.React.createElement(Statistic, { title: "1 \u6E2F\u5143\u6298\u4EBA\u6C11\u5E01", value: fmt(fx, 4), suffix: "\u5143" }))), !(fx > 0) && /* @__PURE__ */ ctx.libs.React.createElement(Alert, { type: "warning", showIcon: true, message: "\u7F3A\u5C11\u6709\u6548\u6C47\u7387\uFF0C\u6E2F\u5143\u4F30\u503C\u6682\u4E0D\u6362\u7B97" }), /* @__PURE__ */ ctx.libs.React.createElement(Space, { wrap: true, style: { marginTop: 12 } }, /* @__PURE__ */ ctx.libs.React.createElement(Typography.Text, null, "\u4EBA\u6C11\u5E01\u91D1\u989D\u6362\u7B97"), /* @__PURE__ */ ctx.libs.React.createElement(InputNumber, { value: convertRmb, onChange: setConvertRmb, min: 0, placeholder: "\u8F93\u5165\u4EBA\u6C11\u5E01\u91D1\u989D", addonAfter: "\u5143" }), /* @__PURE__ */ ctx.libs.React.createElement(Typography.Text, { strong: true }, "\u2248 ", fmt(fx > 0 && convertRmb !== null ? convertRmb / fx : null), " \u6E2F\u5143")), /* @__PURE__ */ ctx.libs.React.createElement(Typography.Paragraph, { type: "secondary", style: { marginTop: 8, marginBottom: 0, fontSize: 12 } }, "\u6362\u7B97\uFF1A\u4EBA\u6C11\u5E01\u4EF7\u503C \xF7 \u6E2F\u5143\u5151\u4EBA\u6C11\u5E01\u6C47\u7387\u3002\u91C7\u7528\u6570\u636E\u5E93\u4E0E\u80A1\u4EF7\u65E5\u5339\u914D\u7684\u6C47\u7387\uFF1B\u6C47\u7387\u6307\u6807\u6700\u65B0\u89C2\u5BDF\u65E5 ", metrics.find((m) => m.id === company.price_fx_metric_id)?.latest_date || "\u2014", "\u3002 \u4E0B\u65B9\u7ECF\u8425\u91D1\u989D\u548C\u4F30\u503C\u5E95\u7A3F\u4ECD\u4E3A\u4EBA\u6C11\u5E01\uFF0C\u6E2F\u5143\u7ED3\u679C\u6309\u540C\u4E00\u666E\u901A\u80A1\u80A1\u672C\u6362\u7B97\u3002\u80A1\u672C\u4E0E\u8D44\u4EA7\u5047\u8BBE\u7684\u6838\u9A8C\u72B6\u6001\u89C1\u6A21\u578B\u5E95\u7A3F\u3002")), sotpPrimary ? sotpCard : null, /* @__PURE__ */ ctx.libs.React.createElement(Card, { size: "small", title: sotpPrimary ? "\u4EA4\u53C9\u9A8C\u8BC1\uFF1A\u80A1\u606F\u8D34\u73B0\uFF0C\u6309\u8981\u6C42\u6536\u76CA\u7387\u4F30\u503C" : IRR_ONLY ? "\u4F30\u503C\uFF1A\u6309\u5E02\u4EF7\u4E70\u5165\u7684\u9690\u542B\u5E74\u5316\u56DE\u62A5 vs \u95E8\u69DB" : "\u6309\u8981\u6C42\u6536\u76CA\u7387\u4F30\u503C", style: { marginBottom: 12 } }, /* @__PURE__ */ ctx.libs.React.createElement(Space, { wrap: true, align: "center", style: { marginBottom: 8 } }, /* @__PURE__ */ ctx.libs.React.createElement(Typography.Text, { strong: true }, IRR_ONLY ? "\u95E8\u69DB" : "\u8981\u6C42\u6536\u76CA\u7387"), /* @__PURE__ */ ctx.libs.React.createElement(Slider, { style: { width: 240 }, min: 3, max: 10, step: 0.1, value: reqPct, onChange: (v) => setReqPct(v) }), /* @__PURE__ */ ctx.libs.React.createElement(InputNumber, { min: 0.1, max: 20, step: 0.1, value: reqPct, onChange: (v) => setReqPct(v ?? initial), addonAfter: "%" }), /* @__PURE__ */ ctx.libs.React.createElement(Button, { onClick: () => setReqPct(initial) }, "\u6062\u590D ", initial, "%"), /* @__PURE__ */ ctx.libs.React.createElement(Button, { type: "primary", loading: saving, onClick: save }, "\u4FDD\u5B58\u4E3A\u6A21\u578B\u9ED8\u8BA4")), /* @__PURE__ */ ctx.libs.React.createElement(Row, { gutter: [12, 12] }, /* @__PURE__ */ ctx.libs.React.createElement(Col, { xs: 12, md: 6 }, /* @__PURE__ */ ctx.libs.React.createElement(Statistic, { title: `\u5E02\u573A\u4EF7\uFF08${base.market_date || "\u2014"}${company.latest_fx ? `\uFF1B\u539F\u5E01 ${fmt(company.latest_price_raw)} \xD7 \u6C47\u7387 ${company.latest_fx}` : ""}\uFF09`, value: fmt(base.market_price), suffix: "\u5143" })), /* @__PURE__ */ ctx.libs.React.createElement(Col, { xs: 12, md: 6 }, /* @__PURE__ */ ctx.libs.React.createElement(Statistic, { title: "\u4E70\u5165\u540E\u9690\u542B\u5E74\u5316\u6536\u76CA\u7387\uFF08\u57FA\u51C6\uFF09", value: pct(baseRow.irr), valueStyle: { color: baseRow.ok ? "#389e0d" : "#cf1322" } })), /* @__PURE__ */ ctx.libs.React.createElement(Col, { xs: 12, md: 6 }, /* @__PURE__ */ ctx.libs.React.createElement(Statistic, { title: `${IRR_ONLY ? "\u95E8\u69DB" : "\u8981\u6C42"} ${reqPct}% \u7684\u6700\u9AD8\u4E70\u5165\u4EF7\uFF08\u57FA\u51C6\uFF09`, value: fmt(baseRow.ceiling), suffix: "\u5143" })), /* @__PURE__ */ ctx.libs.React.createElement(Col, { xs: 12, md: 6 }, /* @__PURE__ */ ctx.libs.React.createElement(Statistic, { title: "\u5E02\u573A\u4EF7\u76F8\u5BF9\u6700\u9AD8\u4E70\u5165\u4EF7", value: baseRow.ceiling ? pct(base.market_price / baseRow.ceiling - 1, 1) : "\u2014" }))), /* @__PURE__ */ ctx.libs.React.createElement(Table, { size: "small", pagination: false, style: { marginTop: 12 }, dataSource: rows, columns: [
        { title: "\u60C5\u666F", dataIndex: "name" },
        { title: "\u9690\u542B\u5E74\u5316\u6536\u76CA\u7387", dataIndex: "irr", render: (v) => pct(v) },
        { title: "\u73B0\u91D1\u652F\u6301\u53E3\u5F84", dataIndex: "cashIrr", render: (v) => pct(v) },
        { title: `${IRR_ONLY ? "\u95E8\u69DB" : "\u8981\u6C42"} ${reqPct}% \u7684\u6700\u9AD8\u4E70\u5165\u4EF7\uFF08\u5143\uFF09`, dataIndex: "ceiling", render: (v) => fmt(v) },
        { title: "\u5E02\u573A\u4EF7\uFF08\u5143\uFF09", dataIndex: "price", render: (v) => fmt(v) },
        { title: "\u7ED3\u8BBA", dataIndex: "ok", render: (v) => v ? /* @__PURE__ */ ctx.libs.React.createElement(Tag, { color: "green" }, IRR_ONLY ? "\u8FBE\u5230\u95E8\u69DB" : "\u8FBE\u5230\u8981\u6C42") : /* @__PURE__ */ ctx.libs.React.createElement(Tag, { color: "red" }, IRR_ONLY ? "\u4F4E\u4E8E\u95E8\u69DB" : "\u672A\u8FBE\u5230\u8981\u6C42") }
      ] }), !IRR_ONLY && /* @__PURE__ */ ctx.libs.React.createElement(Typography.Paragraph, { type: "secondary", style: { marginTop: 8, marginBottom: 0 } }, "\u9690\u542B\u5E74\u5316\u6536\u76CA\u7387\uFF1D\u6309\u4ECA\u5929\u5E02\u573A\u4EF7\u4E70\u5165\u3001\u83B7\u5F97\u6A21\u578B\u9884\u6D4B\u7684\u80A1\u606F\u5E76\u6309\u6C38\u7EED\u589E\u957F\u7387\u589E\u957F\u65F6\u7684\u5185\u90E8\u6536\u76CA\u7387\uFF0C\u4E0E\u8981\u6C42\u6536\u76CA\u7387\u65E0\u5173\uFF1B \u6700\u9AD8\u4E70\u5165\u4EF7\uFF1D\u6309\u8981\u6C42\u6536\u76CA\u7387\u628A\u672A\u6765\u80A1\u606F\u6298\u73B0\u5230\u4ECA\u5929\u7684\u6BCF\u80A1\u4EF7\u503C\u3002\u4E24\u8005\u7B49\u4EF7\uFF1A\u9690\u542B\u6536\u76CA\u7387\u9AD8\u4E8E\u8981\u6C42\u6536\u76CA\u7387 \u21D4 \u5E02\u573A\u4EF7\u4F4E\u4E8E\u6700\u9AD8\u4E70\u5165\u4EF7\u3002")), !sotpPrimary ? sotpCard : null, IRR_ONLY ? /* @__PURE__ */ ctx.libs.React.createElement(Typography.Paragraph, { type: "secondary", style: { marginTop: 8, marginBottom: 0 } }, "\u81EA\u52A8\u68C0\u67E5\uFF1A\u901A\u8FC7 ", count("\u901A\u8FC7"), " \xB7 \u63D0\u793A ", count("\u63D0\u793A"), " \xB7 \u963B\u65AD ", count("\u963B\u65AD"), "\u3002\u81EA\u52A8\u91C7\u96C6\uFF08\u8FD9\u5BB6\u516C\u53F8\u548C\u901A\u7528\u6307\u6807\uFF09\uFF1A", healthy, " / ", enabled.length, " \u4E2A\u6570\u636E\u6E90\u6B63\u5E38\u3002 \u56DE\u62A5\u62C6\u89E3\u3001\u4E70\u5165\u4EF7\u4E0E\u5047\u8BBE\u7684\u5F71\u54CD\u89C1\u300C\u9884\u6D4B\u4E0E\u4F30\u503C / \u4F30\u503C\u300D\u3002") : /* @__PURE__ */ ctx.libs.React.createElement(React.Fragment, null, /* @__PURE__ */ ctx.libs.React.createElement(Row, { gutter: [12, 12] }, /* @__PURE__ */ ctx.libs.React.createElement(Col, { xs: 12, md: 6 }, /* @__PURE__ */ ctx.libs.React.createElement(Card, { size: "small" }, /* @__PURE__ */ ctx.libs.React.createElement(Statistic, { title: `${sotpPrimary ? "\u80A1\u606F\u8D34\u73B0\xB7" : ""}\u4ECA\u5929\u6BCF\u80A1\u4EF7\u503C\uFF08\u6298\u73B0\u7387 ${pct(base.discount_rate)}\uFF09`, value: fmt(base.value_today), suffix: "\u5143" }))), /* @__PURE__ */ ctx.libs.React.createElement(Col, { xs: 12, md: 6 }, /* @__PURE__ */ ctx.libs.React.createElement(Card, { size: "small" }, /* @__PURE__ */ ctx.libs.React.createElement(Statistic, { title: "\u73B0\u91D1\u652F\u6301\u4EF7\u503C\xB7\u4ECA\u5929", value: fmt(base.cash_value_today), suffix: "\u5143" }))), /* @__PURE__ */ ctx.libs.React.createElement(Col, { xs: 12, md: 6 }, /* @__PURE__ */ ctx.libs.React.createElement(Card, { size: "small" }, /* @__PURE__ */ ctx.libs.React.createElement(Statistic, { title: `${sotpPrimary ? "\u80A1\u606F\u8D34\u73B0\xB7" : ""}\u5173\u6CE8\u4EF7\uFF08\u4F4E\u6863/\u9AD8\u6863\u8FB9\u9645\uFF09`, value: `${fmt(base.watch_low)} / ${fmt(base.watch_high)}` }))), /* @__PURE__ */ ctx.libs.React.createElement(Col, { xs: 12, md: 6 }, /* @__PURE__ */ ctx.libs.React.createElement(Card, { size: "small" }, /* @__PURE__ */ ctx.libs.React.createElement(Statistic, { title: "\u81EA\u52A8\u68C0\u67E5", value: `\u901A\u8FC7 ${count("\u901A\u8FC7")} \xB7 \u63D0\u793A ${count("\u63D0\u793A")} \xB7 \u963B\u65AD ${count("\u963B\u65AD")}` })))), /* @__PURE__ */ ctx.libs.React.createElement(Typography.Paragraph, { type: "secondary", style: { marginTop: 8, marginBottom: 0 } }, base.conclusion || "", " \u81EA\u52A8\u91C7\u96C6\uFF08\u8FD9\u5BB6\u516C\u53F8\u548C\u901A\u7528\u6307\u6807\uFF09\uFF1A", healthy, " / ", enabled.length, " \u4E2A\u6570\u636E\u6E90\u6B63\u5E38\u3002")));
    };
    const companies = await listRows("vi_company", { code: { $eq: COMPANY } });
    const company = companies[0];
    if (!company) {
      ctx.render(/* @__PURE__ */ ctx.libs.React.createElement(Alert, { type: "info", showIcon: true, message: `\u516C\u53F8\u8868\u91CC\u6CA1\u6709\u4EE3\u7801\u4E3A ${COMPANY} \u7684\u516C\u53F8` }));
      return;
    }
    const models = await listRows("vi_model", { company_id: { $eq: company.id }, status: { $eq: "\u5F53\u524D" } });
    const model = models[0];
    if (!model) {
      ctx.render(/* @__PURE__ */ ctx.libs.React.createElement(Alert, { type: "info", showIcon: true, message: "\u8FD9\u5BB6\u516C\u53F8\u8FD8\u6CA1\u6709\u72B6\u6001\u4E3A\u201C\u5F53\u524D\u201D\u7684\u4F30\u503C\u6A21\u578B" }));
      return;
    }
    const [valuations, projections, checks, allCollectors, sotpRows, metrics, allCompanies] = await Promise.all([
      listRows("vi_valuation", { model_id: { $eq: model.id } }),
      listRows("vi_projection", { model_id: { $eq: model.id } }, 500),
      listRows("vi_check", { model_id: { $eq: model.id } }),
      listRows("vi_collector"),
      listRows("vi_sotp", { model_id: { $eq: model.id } }),
      listRows("vi_metric", null, 500),
      listRows("vi_company")
    ]);
    const collectors = ownCollectors(allCollectors, metrics, allCompanies, company.id);
    const sotp = sotpRows.slice().sort((a, b) => (a.id || 0) - (b.id || 0));
    const sotpPrimary = model.primary_method === "\u5206\u90E8\u52A0\u603B" && sotp.length > 0;
    const sotpBase = sotp.find((r) => r.is_base) || sotp[0];
    const scenarios = valuations.slice().sort((a, b) => (a.id || 0) - (b.id || 0)).map((v) => {
      const rows = projections.filter((p) => p.scenario_name === v.scenario_name && p.year > model.base_year && p.year <= model.terminal_year);
      const flows = rows.map((p) => ({ dps: p.dps, tau: p.year - model.base_year - model.years_elapsed }));
      const last = rows.find((p) => p.year === model.terminal_year);
      const terminal = last ? { dps: last.dps, tau: model.terminal_year - model.base_year - model.years_elapsed } : null;
      return { ...v, flows, terminal };
    });
    const base = scenarios.find((v) => v.is_base) || scenarios[0] || {};
    const count = (r) => checks.filter((c) => c.result === r).length;
    const enabled = collectors.filter((c) => c.enabled);
    const healthy = enabled.filter((c) => c.health === "\u6B63\u5E38").length;
    const initial = Math.round((model.required_return ?? 0.06) * 1e3) / 10;
    ctx.render(/* @__PURE__ */ ctx.libs.React.createElement(Panel, null));
  } catch (error) {
    ctx.render(/* @__PURE__ */ ctx.libs.React.createElement(Alert, { type: "error", showIcon: true, message: "\u9A7E\u9A76\u8231\u8BFB\u53D6\u5931\u8D25", description: String(error?.message || error) }));
  }
}
export {
  run as default
};
