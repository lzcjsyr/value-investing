async function run(ctx) {
  const COMPANY = "002078.SZ";
  const PROFILE = { "method": "irr", "hurdle_j": null, "logic": "\u9500\u91CF \xD7 \u7EFC\u5408\u5428\u6536\u5165\u5F97\u5230\u6536\u5165\uFF1B\u5428\u6210\u672C\u3001\u6298\u65E7\u548C\u5229\u606F\u51B3\u5B9A\u5229\u6DA6\uFF0C\u8D44\u672C\u5F00\u652F\u4E0E\u6D3E\u606F\u7387\u51B3\u5B9A\u80A1\u4E1C\u80FD\u62FF\u5230\u7684\u73B0\u91D1\u3002", "drivers": [{ "section": "\u6536\u5165\u4E0E\u4E1A\u52A1\u89C4\u6A21" }, { "label": "\u6D46\u7EB8\u9500\u91CF\uFF08\u4E07\u5428\uFF09", "p": "volume", "h": "volume", "j": ["J-Q"], "d": 2, "how": "\u9010\u5E74\u8DEF\u5F84 \xD7 \u60C5\u666F\u4E1A\u52A1\u91CF\u7CFB\u6570" }, { "label": "\u7EFC\u5408\u5428\u6536\u5165\uFF08\u4E07\u5143/\u5428\uFF09", "p": "price", "h": "price", "j": ["J-P"], "d": 4, "how": "\u9010\u5E74\u8DEF\u5F84 \xD7 \u60C5\u666F\u5355\u4EF7\u7CFB\u6570" }, { "label": "\u8425\u4E1A\u6536\u5165", "p": "revenue", "h": "revenue", "strong": true, "how": "\u4E1A\u52A1\u91CF \xD7 \u5355\u4EF7" }, { "section": "\u6210\u672C\u4E0E\u5229\u6DA6\uFF08\u91D1\u989D\uFF1A\u4EBF\u5143\u4EBA\u6C11\u5E01\uFF09" }, { "label": "\u4ED8\u73B0\u6210\u672C", "p": "cash_cost", "j": ["J-M"], "how": "\u57FA\u51C6\u4ED8\u73B0\u6210\u672C \xD7 \u60C5\u666F\u6210\u672C\u7CFB\u6570" }, { "label": "\u6298\u65E7\u644A\u9500", "p": "depreciation", "h": "da", "j": ["J-DA"] }, { "label": "\u5229\u606F", "p": "interest", "h": "finance_cost", "j": ["J-DEBT"] }, { "label": "\u5176\u4ED6\u51C0\u8D21\u732E", "p": "other_contrib", "j": ["J-OTHER"], "how": "\u6295\u8D44\u6536\u76CA\u3001\u51CF\u503C\u7B49\u51C0\u989D\uFF0C\u6309\u5404\u516C\u53F8\u539F\u6A21\u578B\u53E3\u5F84" }, { "label": "\u5229\u6DA6\u603B\u989D", "p": "pretax", "h": "pretax_profit", "strong": true }, { "label": "\u6240\u5F97\u7A0E\u7387", "f": "tax_rate", "h": "tax_rate", "pct": true, "d": 2, "j": ["J-TAX"] }, { "label": "\u5C11\u6570\u80A1\u4E1C\u5360\u6BD4", "f": "minority_share", "h": "minority_share", "pct": true, "d": 2, "j": [] }, { "label": "\u5F52\u6BCD\u51C0\u5229\u6DA6", "p": "np_parent", "h": "np_parent", "strong": true }, { "section": "\u80A1\u4E1C\u56DE\u62A5\u4E0E\u73B0\u91D1\u7EA6\u675F" }, { "label": "\u6D3E\u606F\u7387", "p": "payout", "h": "payout", "j": ["J-PAYOUT"], "pct": true, "how": "\u8BA1\u5212\u80A1\u606F \xF7 \u5F52\u6BCD\u51C0\u5229\u6DA6" }, { "label": "\u6BCF\u80A1\u80A1\u606F\uFF08\u5143\uFF09", "p": "dps", "h": "dps", "strong": true, "d": 3 }, { "label": "\u7EF4\u6301\u8D44\u672C\u5F00\u652F", "f": "maint_capex", "j": ["J-CAPEX"], "d": 1 }, { "label": "\u6269\u5F20\u8D44\u672C\u5F00\u652F", "f": "growth_capex", "j": ["J-CAPEX"], "d": 1 }, { "label": "\u8425\u8FD0\u8D44\u672C\u589E\u52A0", "f": "wc_increase", "j": [], "d": 1 }, { "label": "\u51C0\u501F\u6B3E\uFF08\u8D1F\u6570\uFF1D\u507F\u503A\uFF09", "f": "net_borrowing", "d": 1 }, { "label": "\u80A1\u4E1C\u81EA\u7531\u73B0\u91D1\u6D41", "p": "fcfe", "strong": true, "how": "\u6309\u6570\u636E\u5E93\u5F52\u6BCD\u73B0\u91D1\u6865\u63A5\u53E3\u5F84" }, { "label": "\u8BA1\u5212\u56DE\u62A5\u73B0\u91D1\u7F3A\u53E3", "p": "funding_gap", "how": "\u73B0\u91D1\u4E0D\u8DB3\u90E8\u5206\uFF1B\u7F3A\u9879\u4FDD\u6301\u672A\u77E5" }], "shocks": [{ "label": "\u6536\u5165\u4E2D\u67A2 \u22125%", "rev": -0.05, "j": "J-Q / J-P" }, { "label": "\u6536\u5165\u4E2D\u67A2 +5%", "rev": 0.05, "j": "J-Q / J-P" }, { "label": "\u4ED8\u73B0\u6210\u672C +5%", "cost": 0.05, "j": "J-M" }, { "label": "\u503A\u52A1\u6210\u672C +1 \u4E2A\u767E\u5206\u70B9", "kd": 0.01 }, { "label": "\u6C38\u7EED\u589E\u957F 0%", "g": 0, "j": "J-TV" }, { "label": "\u4E70\u5165\u4EF7 \u221210%", "price": -0.1 }] };
  const { React } = ctx.libs;
  const { useState } = React;
  const {
    Card,
    Segmented,
    Table: NativeTable,
    Alert,
    Typography,
    Space,
    Tag,
    Popover,
    Collapse,
    Descriptions,
    Row,
    Col,
    Statistic,
    InputNumber,
    Button,
    message,
    theme
  } = ctx.libs.antd;
  const { Text, Paragraph, Title } = Typography;
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
  async function listRows(name, filter, pageSize = 1e3) {
    const resource = ctx.makeResource("MultiRecordResource");
    resource.setResourceName(name);
    resource.setPageSize?.(pageSize);
    if (filter) resource.setFilter?.(filter);
    await resource.refresh();
    return resource.getData() || [];
  }
  const isNum = (v) => v !== null && v !== void 0 && v !== "" && !Number.isNaN(Number(v));
  const fmt = (v, d = 1) => isNum(v) ? Number(v).toLocaleString("zh-CN", { minimumFractionDigits: d, maximumFractionDigits: d }) : "\u2014";
  const pct = (v, d = 1) => isNum(v) ? (Number(v) * 100).toFixed(d) + "%" : "\u2014";
  const pp = (v) => isNum(v) ? (Math.abs(v) * 100).toFixed(2) + " \u4E2A\u767E\u5206\u70B9" : "\u2014";
  const bp = (v) => isNum(v) ? (v >= 0 ? "+" : "\u2212") + Math.abs(Math.round(v * 1e4)) + "bp" : "\u2014";
  const narrow = (typeof window !== "undefined" ? window.innerWidth : 1200) < 760;
  const bySort = (a, b) => (a.sort ?? 0) - (b.sort ?? 0) || a.id - b.id;
  async function load() {
    const [company] = await listRows("vi_company", { code: { $eq: COMPANY } });
    if (!company) throw new Error("\u516C\u53F8\u4E0D\u5B58\u5728\uFF1A" + COMPANY);
    const [model] = await listRows("vi_model", { company_id: { $eq: company.id }, status: { $eq: "\u5F53\u524D" } });
    if (!model) return { company };
    const byModel = { model_id: { $eq: model.id } };
    const [scenarios, projections, forecasts, valuations, judgments, history] = await Promise.all([
      listRows("vi_scenario", byModel),
      listRows("vi_projection", byModel),
      listRows("vi_forecast", byModel),
      listRows("vi_valuation", byModel),
      listRows("vi_judgment", { company_id: { $eq: company.id } }),
      listRows("vi_fin_history", { company_id: { $eq: company.id } })
    ]);
    scenarios.sort(bySort);
    const years = [...new Set(forecasts.map((f) => Number(f.year)))].sort((a, b) => a - b);
    const pOf = (sc, y) => projections.find((p) => p.scenario_name === sc.name && Number(p.year) === Number(y));
    const fOf = (y) => forecasts.find((f) => Number(f.year) === Number(y));
    return { company, model, scenarios, projections, forecasts, valuations, judgments, history, years, pOf, fOf };
  }
  function JTag({ code, judgments }) {
    const j = judgments.find((x) => x.code === code);
    if (!j) return /* @__PURE__ */ ctx.libs.React.createElement(Tag, null, code);
    const body = /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { maxWidth: 420 } }, /* @__PURE__ */ ctx.libs.React.createElement(Paragraph, { style: { marginBottom: 6 } }, /* @__PURE__ */ ctx.libs.React.createElement("b", null, "\u5224\u65AD"), "\uFF1A", j.judgment), j.transmission && /* @__PURE__ */ ctx.libs.React.createElement(Paragraph, { style: { marginBottom: 6 } }, /* @__PURE__ */ ctx.libs.React.createElement("b", null, "\u600E\u4E48\u4F20\u5BFC"), "\uFF1A", j.transmission), j.change_threshold && /* @__PURE__ */ ctx.libs.React.createElement(Paragraph, { style: { marginBottom: 0 } }, /* @__PURE__ */ ctx.libs.React.createElement("b", null, "\u4EC0\u4E48\u60C5\u51B5\u4E0B\u6539"), "\uFF1A", j.change_threshold));
    return /* @__PURE__ */ ctx.libs.React.createElement(Popover, { title: `${j.code} ${j.title} \xB7 ${j.status || ""}`, content: body }, /* @__PURE__ */ ctx.libs.React.createElement(Tag, { color: "blue", style: { cursor: "help" } }, j.code));
  }
  function pv(flows, g, r) {
    if (!isNum(r) || !isNum(g) || r <= g || !flows.length) return null;
    const last = flows[flows.length - 1];
    return flows.reduce((s, x) => s + (x.tau > 0 ? x.dps / Math.pow(1 + r, x.tau) : 0), 0) + last.dps * (1 + g) / (r - g) / Math.pow(1 + r, last.tau);
  }
  function irr(flows, g, price) {
    if (!isNum(price) || price <= 0 || !flows.length || flows.some((x) => !isNum(x.dps))) return null;
    let lo = g + 1e-7, hi = 1;
    if (pv(flows, g, hi) > price) return null;
    for (let i = 0; i < 80; i++) {
      const mid = (lo + hi) / 2;
      if (pv(flows, g, mid) > price) lo = mid;
      else hi = mid;
    }
    return (lo + hi) / 2;
  }
  function DpsChart({ series, startYear, startDps }) {
    const { token } = theme.useToken();
    const W = 640, H = 220, L = 44, R = 64, T = 12, B = 26;
    const all = series.flatMap((s) => s.points.map((p) => p.dps)).concat(isNum(startDps) ? [startDps] : []);
    const lo = Math.floor(Math.min(...all) * 10) / 10, hi = Math.ceil(Math.max(...all) * 10) / 10;
    const years = series[0].points.map((p) => p.year);
    const x0 = isNum(startDps) ? startYear : years[0], x1 = years[years.length - 1];
    const x = (y2) => L + (y2 - x0) / (x1 - x0 || 1) * (W - L - R);
    const y = (v) => T + (1 - (v - lo) / (hi - lo || 1)) * (H - T - B);
    const ticks = [lo, (lo + hi) / 2, hi];
    return /* @__PURE__ */ ctx.libs.React.createElement("svg", { viewBox: `0 0 ${W} ${H}`, style: { width: "100%", height: "auto" } }, ticks.map((t) => /* @__PURE__ */ ctx.libs.React.createElement("g", { key: t }, /* @__PURE__ */ ctx.libs.React.createElement("line", { x1: L, x2: W - R, y1: y(t), y2: y(t), stroke: token.colorSplit }), /* @__PURE__ */ ctx.libs.React.createElement("text", { x: L - 6, y: y(t) + 4, fontSize: "11", textAnchor: "end", fill: token.colorTextSecondary }, t.toFixed(2)))), [x0, ...years].filter((yy, i, a) => i === 0 || i === a.length - 1 || (yy - x0) % 2 === 0).map((yy) => /* @__PURE__ */ ctx.libs.React.createElement("text", { key: yy, x: x(yy), y: H - 8, fontSize: "11", textAnchor: "middle", fill: token.colorTextSecondary }, yy === x0 && isNum(startDps) ? `${yy}A` : `${yy}E`)), series.map((s) => {
      const pts = (isNum(startDps) ? [{ year: startYear, dps: startDps }] : []).concat(s.points);
      const end = s.points[s.points.length - 1];
      return /* @__PURE__ */ ctx.libs.React.createElement("g", { key: s.name }, /* @__PURE__ */ ctx.libs.React.createElement("polyline", { fill: "none", stroke: s.color, strokeWidth: s.strong ? 2.5 : 1.5, points: pts.map((p) => `${x(p.year)},${y(p.dps)}`).join(" ") }), /* @__PURE__ */ ctx.libs.React.createElement("text", { x: x(end.year) + 6, y: y(end.dps) + 4, fontSize: "11", fill: s.color }, s.name, " ", end.dps.toFixed(2)));
    }), isNum(startDps) && /* @__PURE__ */ ctx.libs.React.createElement("circle", { cx: x(startYear), cy: y(startDps), r: "3", fill: token.colorText }));
  }
  try {
    const D = await load();
    if (!D.model) {
      ctx.render(/* @__PURE__ */ ctx.libs.React.createElement(Alert, { type: "info", showIcon: true, message: "\u8FD8\u6CA1\u6709\u72B6\u6001\u4E3A\u201C\u5F53\u524D\u201D\u7684\u4F30\u503C\u6A21\u578B" }));
    } else {
      let Panel = function() {
        const { token } = theme.useToken();
        const colors = COLORS(token);
        const saved = Math.round((model.required_return ?? 0.06) * 1e3) / 10;
        const [reqPct, setReqPct] = useState(saved);
        const [saving, setSaving] = useState(false);
        const req = reqPct / 100;
        const ok = (r) => isNum(r) && r >= req;
        const irrColor = (r) => ok(r) ? token.colorSuccess : token.colorText;
        const baseIrr = irrOf(base);
        const passing = scenarios.filter((s) => ok(irrOf(s)));
        const rf = isNum(model.latest_rf) ? model.latest_rf / 100 : model.rf;
        const save = async () => {
          setSaving(true);
          try {
            await ctx.request({ url: "vi_model:update", method: "post", params: { filterByTk: model.id }, data: { required_return: req } });
            message.success(`\u5DF2\u4FDD\u5B58\uFF1A\u95E8\u69DB ${reqPct}%`);
          } catch (e) {
            message.error("\u4FDD\u5B58\u5931\u8D25\uFF1A" + String(e?.message || e));
          } finally {
            setSaving(false);
          }
        };
        const verdict = !isNum(baseIrr) ? "\u7B97\u4E0D\u51FA\u9690\u542B\u56DE\u62A5\uFF1A\u9884\u6D4B\u5E74\u4EFD\u4E0D\u5B8C\u6574\u6216\u6CA1\u6709\u5E02\u573A\u4EF7\u3002" : `\u6309 ${fmt(price, 2)} \u5143\uFF08${priceDate || ""}\uFF09\u4E70\u5165\uFF0C\u57FA\u51C6\u60C5\u666F\u5E74\u5316 ${pct(baseIrr, 2)}\uFF0C\u6BD4\u95E8\u69DB ${pct(req, 1)} ${ok(baseIrr) ? "\u9AD8" : "\u4F4E"} ${pp(baseIrr - req)}\uFF1B${passing.length === scenarios.length ? "\u4E09\u4E2A\u60C5\u666F\u90FD\u8FBE\u5230\u95E8\u69DB" : passing.length ? `\u8FBE\u5230\u95E8\u69DB\u7684\u53EA\u6709${passing.map((s) => s.name).join("\u3001")}\u60C5\u666F` : "\u4E09\u4E2A\u60C5\u666F\u90FD\u4F4E\u4E8E\u95E8\u69DB"}\u3002`;
        const b0 = pOf(base, first), b1 = pOf(base, last);
        const yield0 = b0 && price ? b0.dps / price : null;
        const growth = b0 && b1 ? Math.pow(b1.dps / b0.dps, 1 / (last - first)) - 1 : null;
        const bf = flows[base.id];
        const terminalShare = isNum(baseIrr) && price ? bf[bf.length - 1].dps * (1 + base.terminal_growth) / (baseIrr - base.terminal_growth) / Math.pow(1 + baseIrr, bf[bf.length - 1].tau) / price : null;
        const f1 = fOf(last);
        const k1 = f1 ? keep(f1) : 1;
        const parts = b0 && b1 ? [
          { n: "\u8425\u4E1A\u6536\u5165", v: (b1.revenue - b0.revenue) * k1 },
          { n: "\u4ED8\u73B0\u6210\u672C", v: -(b1.cash_cost - b0.cash_cost) * k1 },
          { n: "\u6298\u65E7\u9000\u5761", v: -(b1.depreciation - b0.depreciation) * k1 },
          { n: "\u5229\u606F\u4E0B\u964D", v: -(b1.interest - b0.interest) * k1 },
          { n: "\u5176\u4ED6\u51C0\u8D21\u732E", v: (b1.other_contrib - b0.other_contrib) * k1 }
        ] : [];
        if (parts.length) parts.push({ n: "\u7A0E\u7387\u4E0E\u5C11\u6570\u80A1\u4E1C", v: b1.np_parent - b0.np_parent - parts.reduce((s, p) => s + p.v, 0) });
        const maxPart = Math.max(1, ...parts.map((p) => Math.abs(p.v)));
        const step = price > 50 ? 5 : 2;
        const pts = [];
        if (isNum(price)) for (let q = Math.floor(price * 0.7 / step) * step; q <= price * 1.25; q += step) pts.push(q);
        if (isNum(price) && !pts.includes(price)) pts.push(price);
        pts.sort((a, b) => a - b);
        const priceCols = [
          { title: "\u60C5\u666F", dataIndex: "name", fixed: narrow ? void 0 : "left" },
          ...pts.map((q) => ({
            title: q === price ? /* @__PURE__ */ ctx.libs.React.createElement("b", null, fmt(q, 2), "\uFF08\u73B0\u4EF7\uFF09") : fmt(q, 0),
            key: "q" + q,
            align: "right",
            render: (_, s) => {
              const r = irr(flows[s.id], s.terminal_growth, q);
              return /* @__PURE__ */ ctx.libs.React.createElement("span", { style: { color: irrColor(r), fontWeight: q === price ? 600 : 400 } }, pct(r, 1));
            }
          })),
          {
            title: `\u95E8\u69DB ${pct(req, 1)} \u4E0B\u6700\u9AD8\u4E70\u5165\u4EF7`,
            key: "cap",
            align: "right",
            render: (_, s) => /* @__PURE__ */ ctx.libs.React.createElement("b", null, fmt(pv(flows[s.id], s.terminal_growth, req), 2), " \u5143")
          }
        ];
        const shockRows = PROFILE.shocks.map((k, i) => {
          const fl = k.rev || k.cost || k.kd || isNum(k.payout) ? shockFlows(k) : flows[base.id];
          const g = isNum(k.g) ? k.g : base.terminal_growth;
          const q = k.price ? price * (1 + k.price) : price;
          const r = irr(fl, g, q);
          return { key: i, label: k.label, j: k.j, r, d: isNum(r) && isNum(baseIrr) ? r - baseIrr : null, cap: k.price ? null : pv(fl, g, req) };
        });
        const gaps = years.map((yy) => ({ yy, gap: pOf(base, yy)?.funding_gap })).filter((x) => isNum(x.gap) && x.gap > 0.05);
        const cashIrr = vOf(base).cash_implied_irr;
        return /* @__PURE__ */ ctx.libs.React.createElement("div", null, /* @__PURE__ */ ctx.libs.React.createElement(Title, { level: 4, style: { marginTop: 0 } }, company.name, " \xB7 \u4F30\u503C\uFF1A\u6309\u4ECA\u5929\u7684\u4EF7\u683C\u4E70\u5165\uFF0C\u5E74\u5316\u56DE\u62A5\u591A\u5C11\uFF1F"), /* @__PURE__ */ ctx.libs.React.createElement(Paragraph, { type: "secondary" }, "\u53EA\u7528\u4E00\u4E2A\u4F30\u503C\u903B\u8F91\uFF1A\u628A\u672A\u6765\u6BCF\u5E74\u7684\u6BCF\u80A1\u80A1\u606F\u5F53\u6210\u503A\u5238\u7968\u606F\uFF08", first, "\u2014", last, " \u5E74\u9010\u5E74\u9884\u6D4B\uFF0C\u4E4B\u540E\u6309\u6C38\u7EED\u589E\u957F\u5EF6\u7EED\uFF09\uFF0C \u6C42\u51FA\u6309\u5E02\u573A\u4EF7\u4E70\u5165\u7684\u9690\u542B\u5E74\u5316\u56DE\u62A5\uFF0C\u518D\u548C\u95E8\u69DB\u6BD4\u3002\u60C5\u666F\u53EA\u6539\u73B0\u91D1\u6D41\uFF0C\u95E8\u69DB\u53EA\u6709\u4E00\u4E2A\u3002"), /* @__PURE__ */ ctx.libs.React.createElement(Row, { gutter: [12, 12], style: { marginBottom: 12 } }, scenarios.map((s, i) => /* @__PURE__ */ ctx.libs.React.createElement(Col, { key: s.id, xs: 12, md: 5 }, /* @__PURE__ */ ctx.libs.React.createElement(Card, { size: "small", style: s.is_base ? { borderColor: token.colorPrimary } : {} }, /* @__PURE__ */ ctx.libs.React.createElement(Statistic, { title: `${s.name}\u60C5\u666F \xB7 \u9690\u542B\u5E74\u5316\u56DE\u62A5`, value: pct(irrOf(s), 2), valueStyle: { color: irrColor(irrOf(s)), fontWeight: s.is_base ? 600 : 400 } })))), /* @__PURE__ */ ctx.libs.React.createElement(Col, { xs: 12, md: 5 }, /* @__PURE__ */ ctx.libs.React.createElement(Card, { size: "small" }, /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { color: token.colorTextSecondary, marginBottom: 4 } }, "\u95E8\u69DB\uFF08\u8981\u6C42\u7684\u5E74\u5316\u56DE\u62A5\uFF09", PROFILE.hurdle_j && /* @__PURE__ */ ctx.libs.React.createElement(JTag, { code: PROFILE.hurdle_j, judgments })), /* @__PURE__ */ ctx.libs.React.createElement(Space.Compact, null, /* @__PURE__ */ ctx.libs.React.createElement(InputNumber, { min: 2, max: 15, step: 0.5, value: reqPct, onChange: (v) => isNum(v) && setReqPct(v), addonAfter: "%", style: { width: 110 } }), /* @__PURE__ */ ctx.libs.React.createElement(Button, { disabled: reqPct === saved, loading: saving, onClick: save }, "\u4FDD\u5B58")))), /* @__PURE__ */ ctx.libs.React.createElement(Col, { xs: 12, md: 4 }, /* @__PURE__ */ ctx.libs.React.createElement(Card, { size: "small" }, /* @__PURE__ */ ctx.libs.React.createElement(Statistic, { title: `10 \u5E74\u56FD\u503A\uFF08${model.latest_rf_date || model.rf_date || ""}\uFF09`, value: pct(rf, 2) })))), /* @__PURE__ */ ctx.libs.React.createElement(
          Alert,
          {
            showIcon: true,
            type: ok(baseIrr) ? "success" : "warning",
            style: { marginBottom: 12 },
            message: verdict,
            description: isNum(baseIrr) && isNum(rf) ? `\u57FA\u51C6\u56DE\u62A5\u6BD4 10 \u5E74\u56FD\u503A${baseIrr >= rf ? "\u9AD8" : "\u4F4E"} ${pp(baseIrr - rf)}\u3002\u7814\u7A76\u63D0\u793A\uFF0C\u4E0D\u662F\u4EA4\u6613\u6307\u4EE4\u3002` : null
          }
        ), /* @__PURE__ */ ctx.libs.React.createElement(Row, { gutter: [12, 12], style: { marginBottom: 12 } }, /* @__PURE__ */ ctx.libs.React.createElement(Col, { xs: 24, lg: 12 }, /* @__PURE__ */ ctx.libs.React.createElement(Card, { size: "small", title: "\u56DE\u62A5\u4ECE\u54EA\u6765\uFF08\u57FA\u51C6\u60C5\u666F\uFF09", style: { height: "100%" } }, /* @__PURE__ */ ctx.libs.React.createElement(Row, { gutter: 12 }, /* @__PURE__ */ ctx.libs.React.createElement(Col, { span: 8 }, /* @__PURE__ */ ctx.libs.React.createElement(Statistic, { title: `\u9996\u5E74\u80A1\u606F\u7387\uFF08${first}E\uFF09`, value: pct(yield0, 2) })), /* @__PURE__ */ ctx.libs.React.createElement(Col, { span: 8 }, /* @__PURE__ */ ctx.libs.React.createElement(Statistic, { title: `\u80A1\u606F\u5E74\u589E\uFF08${first}\u2014${last}E\uFF09`, value: pct(growth, 2) })), /* @__PURE__ */ ctx.libs.React.createElement(Col, { span: 8 }, /* @__PURE__ */ ctx.libs.React.createElement(Statistic, { title: `${last} \u5E74\u540E\u6C38\u7EED\u589E\u957F`, value: pct(base.terminal_growth, 1) }))), /* @__PURE__ */ ctx.libs.React.createElement(Paragraph, { type: "secondary", style: { marginTop: 8, marginBottom: 8 } }, "\u9690\u542B\u56DE\u62A5 \u2248 \u80A1\u606F\u7387 \uFF0B \u80A1\u606F\u589E\u957F\u3002", last, " \u5E74\u4EE5\u540E\u7684\u80A1\u606F\uFF08\u7EC8\u503C\uFF09\u5360\u4E70\u5165\u4EF7\u7684 ", pct(terminalShare, 0), "\uFF0C\u6240\u4EE5\u6C38\u7EED\u589E\u957F\u548C\u6700\u540E\u51E0\u5E74\u7684\u80A1\u606F\u6C34\u5E73\u5F88\u5173\u952E\u3002"), /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { fontWeight: 500, marginBottom: 4 } }, "\u80A1\u606F\u4E3A\u4EC0\u4E48\u80FD\u6DA8\uFF1A\u5F52\u6BCD\u51C0\u5229\u6DA6 ", fmt(b0?.np_parent, 0), " \u2192 ", fmt(b1?.np_parent, 0), " \u4EBF\u5143\uFF08", first, "E \u2192 ", last, "E\uFF09"), parts.map((p) => /* @__PURE__ */ ctx.libs.React.createElement("div", { key: p.n, style: { display: "grid", gridTemplateColumns: "96px 1fr 64px", gap: 8, alignItems: "center", padding: "2px 0" } }, /* @__PURE__ */ ctx.libs.React.createElement("span", { style: { fontSize: 13 } }, p.n), /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { position: "relative", height: 12, background: token.colorFillQuaternary, borderRadius: 2 } }, /* @__PURE__ */ ctx.libs.React.createElement("div", { style: {
          position: "absolute",
          top: 0,
          bottom: 0,
          borderRadius: 2,
          left: p.v >= 0 ? "50%" : `${50 - Math.abs(p.v) / maxPart * 50}%`,
          width: `${Math.abs(p.v) / maxPart * 50}%`,
          background: p.v >= 0 ? token.colorSuccess : token.colorError
        } })), /* @__PURE__ */ ctx.libs.React.createElement("span", { style: { textAlign: "right", fontVariantNumeric: "tabular-nums", fontSize: 13 } }, p.v >= 0 ? "+" : "\u2212", fmt(Math.abs(p.v), 1)))), /* @__PURE__ */ ctx.libs.React.createElement(Text, { type: "secondary", style: { fontSize: 12 } }, "\u5404\u9879\u662F\u5BF9\u5229\u6DA6\u603B\u989D\u7684\u53D8\u5316 \xD7 ", last, " \u5E74\u7684\uFF081 \u2212 \u7A0E\u7387\uFF09\xD7\uFF081 \u2212 \u5C11\u6570\u80A1\u4E1C\u5360\u6BD4\uFF09\uFF0C\u5355\u4F4D\u4EBF\u5143\u3002"))), /* @__PURE__ */ ctx.libs.React.createElement(Col, { xs: 24, lg: 12 }, /* @__PURE__ */ ctx.libs.React.createElement(Card, { size: "small", title: "\u6BCF\u80A1\u80A1\u606F\u8DEF\u5F84\uFF08\u5143\uFF09", style: { height: "100%" } }, /* @__PURE__ */ ctx.libs.React.createElement(
          DpsChart,
          {
            startYear: model.base_year,
            startDps: hist0?.dps,
            series: scenarios.map((s, i) => ({
              name: s.name,
              color: colors[i % colors.length],
              strong: s.is_base,
              points: flows[s.id].filter((p) => isNum(p.dps))
            }))
          }
        ), /* @__PURE__ */ ctx.libs.React.createElement(Text, { type: "secondary", style: { fontSize: 12 } }, "\u9ED1\u70B9\u662F ", model.base_year, " \u5E74\u5B9E\u9645\u6BCF\u80A1\u80A1\u606F\uFF1B\u5404\u60C5\u666F\u7684\u5047\u8BBE\u89C1\u300C\u8D22\u52A1\u6A21\u578B\u300D\u3002")))), /* @__PURE__ */ ctx.libs.React.createElement(Card, { size: "small", title: "\u4E70\u5165\u4EF7 \u2192 \u5E74\u5316\u56DE\u62A5\uFF08\u7EFF\u8272\uFF1D\u8FBE\u5230\u95E8\u69DB\uFF09", style: { marginBottom: 12 } }, /* @__PURE__ */ ctx.libs.React.createElement(Table, { size: "small", pagination: false, rowKey: "id", dataSource: scenarios, columns: priceCols, scroll: { x: "max-content" } })), /* @__PURE__ */ ctx.libs.React.createElement(Card, { size: "small", title: "\u4EC0\u4E48\u4F1A\u6539\u53D8\u7ED3\u8BBA\uFF08\u57FA\u51C6\u60C5\u666F\uFF0C\u4E00\u6B21\u53EA\u52A8\u4E00\u4E2A\u5047\u8BBE\uFF09", style: { marginBottom: 12 } }, /* @__PURE__ */ ctx.libs.React.createElement(Table, { size: "small", pagination: false, rowKey: "key", dataSource: shockRows, scroll: { x: "max-content" }, columns: [
          { title: "\u53D8\u5316", dataIndex: "label" },
          { title: "\u4F9D\u636E", dataIndex: "j", render: (v) => v ? v.split(" / ").map((c) => /* @__PURE__ */ ctx.libs.React.createElement(JTag, { key: c, code: c, judgments })) : null },
          { title: "\u9690\u542B\u5E74\u5316\u56DE\u62A5", dataIndex: "r", align: "right", render: (v) => /* @__PURE__ */ ctx.libs.React.createElement("span", { style: { color: irrColor(v) } }, pct(v, 2)) },
          { title: "\u6BD4\u57FA\u51C6", dataIndex: "d", align: "right", render: (v) => /* @__PURE__ */ ctx.libs.React.createElement("span", { style: { color: v >= 0 ? token.colorSuccess : token.colorError } }, bp(v)) },
          { title: `\u95E8\u69DB\u4E0B\u6700\u9AD8\u4E70\u5165\u4EF7`, dataIndex: "cap", align: "right", render: (v) => isNum(v) ? fmt(v, 2) + " \u5143" : "\u2014" }
        ] })), /* @__PURE__ */ ctx.libs.React.createElement(Card, { size: "small", title: "\u68C0\u67E5\uFF1A\u8BA1\u5212\u80A1\u606F\u4ED8\u5F97\u51FA\u6765\u5417" }, gaps.length ? /* @__PURE__ */ ctx.libs.React.createElement(Paragraph, { style: { marginBottom: 6 } }, "\u57FA\u51C6\u60C5\u666F ", gaps[0].yy, "\u2014", gaps[gaps.length - 1].yy, " \u5E74\u80A1\u4E1C\u81EA\u7531\u73B0\u91D1\u6D41\u4E0D\u591F\u4ED8\u8BA1\u5212\u80A1\u606F\uFF0C\u7F3A\u53E3\u5408\u8BA1 ", fmt(gaps.reduce((s, x) => s + x.gap, 0), 0), " \u4EBF\u5143 \uFF08", gaps.map((x) => `${x.yy} \u5E74 ${fmt(x.gap, 0)}`).join("\u3001"), "\uFF09\uFF0C\u8BA1\u5212\u5206\u7EA2\u8D85\u8FC7\u4E86\u6A21\u578B\u5F53\u5E74\u7684\u53EF\u5206\u914D\u73B0\u91D1\uFF0C\u9700\u8981\u590D\u6838\u8D44\u672C\u5F00\u652F\u3001\u56DE\u6B3E\u548C\u878D\u8D44\u5047\u8BBE\u3002 \u53EA\u6309\u4ED8\u5F97\u51FA\u7684\u80A1\u606F\u7B97\uFF0C\u9690\u542B\u56DE\u62A5\u662F ", pct(cashIrr, 2), "\uFF08\u76F8\u5DEE ", bp(isNum(cashIrr) && isNum(baseIrr) ? cashIrr - baseIrr : null), "\uFF09\u3002") : /* @__PURE__ */ ctx.libs.React.createElement(Paragraph, { style: { marginBottom: 6 } }, "\u57FA\u51C6\u60C5\u666F\u5404\u5E74\u80A1\u4E1C\u81EA\u7531\u73B0\u91D1\u6D41\u90FD\u8986\u76D6\u8BA1\u5212\u80A1\u606F\u3002"), /* @__PURE__ */ ctx.libs.React.createElement(Text, { type: "secondary", style: { fontSize: 12 } }, "\u73B0\u91D1\u5047\u8BBE\u89C1\u300C\u8D22\u52A1\u6A21\u578B\u300D\u6700\u540E\u4E00\u6BB5\u3002")));
      };
      const { company, model, scenarios, valuations, judgments, history, years, pOf, fOf } = D;
      const shares = Number(model.shares);
      const tauOf = (yy) => yy - model.base_year - model.years_elapsed;
      const base = scenarios.find((s) => s.is_base) || scenarios[0];
      const vOf = (s) => valuations.find((v) => v.scenario_name === s.name) || {};
      const price = vOf(base).market_price, priceDate = vOf(base).market_date;
      const flowsOf = (s, dpsFn) => years.map((yy) => {
        const p = pOf(s, yy), f = fOf(yy);
        return { year: yy, tau: tauOf(yy), dps: p ? dpsFn ? dpsFn(p, f) : p.dps : null };
      });
      const flows = Object.fromEntries(scenarios.map((s) => [s.id, flowsOf(s)]));
      const irrOf = (s) => irr(flows[s.id], s.terminal_growth, price);
      const hist0 = history.find((h) => h.year === model.base_year);
      const COLORS = (token) => [token.colorError, token.colorPrimary, token.colorSuccess];
      const first = years[0], last = years[years.length - 1];
      const keep = (f) => (1 - f.tax_rate) * (1 - f.minority_share);
      const shockFlows = (k) => flowsOf(base, (p, f) => {
        const dPretax = (k.rev ? k.rev * p.revenue : 0) - (k.cost ? k.cost * p.cash_cost : 0) - (k.kd ? k.kd * (Number(f.debt_open) + Number(f.debt_close)) / 2 : 0);
        return (p.np_parent + dPretax * keep(f)) * (isNum(k.payout) ? k.payout : p.payout) / shares;
      });
      ctx.render(/* @__PURE__ */ ctx.libs.React.createElement(Panel, null));
    }
  } catch (error) {
    ctx.render(/* @__PURE__ */ ctx.libs.React.createElement(Alert, { type: "error", showIcon: true, message: "\u4F30\u503C\u8BFB\u53D6\u5931\u8D25", description: String(error?.message || error) }));
  }
}
export {
  run as default
};
