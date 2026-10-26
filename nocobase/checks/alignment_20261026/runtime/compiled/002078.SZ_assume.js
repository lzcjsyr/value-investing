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
  function histValue(key, h, model) {
    if (!h) return null;
    if (key === "tax_rate") return isNum(h.income_tax) && isNum(h.pretax_profit) ? h.income_tax / h.pretax_profit : null;
    if (key === "minority_share") return isNum(h.minority_profit) && isNum(h.pretax_profit) && isNum(h.income_tax) ? h.minority_profit / (h.pretax_profit - h.income_tax) : null;
    if (key === "opening_debt") return h.year === model.base_year ? model.opening_debt : null;
    return h[key];
  }
  function factorText(v) {
    const x = Number(v ?? 1);
    if (Math.abs(x - 1) < 1e-9) return /* @__PURE__ */ ctx.libs.React.createElement(Text, { type: "secondary" }, "\u540C\u57FA\u51C6");
    return `\xD7${x.toFixed(2)}\uFF08${x > 1 ? "+" : "\u2212"}${(Math.abs(x - 1) * 100).toFixed(0)}%\uFF09`;
  }
  try {
    const D = await load();
    if (!D.model) {
      ctx.render(/* @__PURE__ */ ctx.libs.React.createElement(Alert, { type: "info", showIcon: true, message: "\u8FD8\u6CA1\u6709\u72B6\u6001\u4E3A\u201C\u5F53\u524D\u201D\u7684\u4F30\u503C\u6A21\u578B" }));
    } else {
      let Panel = function() {
        const { token } = theme.useToken();
        const [scId, setScId] = useState(base.id);
        const sc = scenarios.find((s) => s.id === scId) || base;
        const last = years[years.length - 1];
        const cell = (r, v) => /* @__PURE__ */ ctx.libs.React.createElement("span", { style: { fontVariantNumeric: "tabular-nums", fontWeight: r.strong ? 600 : 400 } }, r.pct ? pct(v, r.d ?? 1) : fmt(v, r.d ?? 1));
        const rows = PROFILE.drivers.map((r, i) => {
          if (r.section) return { key: i, section: r.section };
          const row = { key: i, ...r };
          histYears.forEach((y) => {
            row["h" + y] = r.h ? histValue(r.h, hOf(y), model) : null;
          });
          years.forEach((y) => {
            const p = pOf(sc, y), f = fOf(y);
            row["y" + y] = r.p ? p?.[r.p] : r.f ? f?.[r.f] : null;
          });
          return row;
        });
        const span = 1 + histYears.length + years.length + 1;
        const sectionCell = (r) => r.section ? { colSpan: 0 } : {};
        const columns = [
          {
            title: "\u9A71\u52A8 \xB7 \u600E\u4E48\u6765",
            key: "label",
            fixed: narrow ? void 0 : "left",
            width: 230,
            onCell: (r) => r.section ? { colSpan: span } : {},
            render: (_, r) => r.section ? /* @__PURE__ */ ctx.libs.React.createElement(Text, { strong: true, style: { color: token.colorTextSecondary } }, r.section) : /* @__PURE__ */ ctx.libs.React.createElement("div", null, /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { fontWeight: r.strong ? 600 : 400 } }, r.label), /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { fontSize: 12, color: token.colorTextSecondary } }, r.how))
          },
          {
            title: "\u4F9D\u636E",
            key: "j",
            width: 120,
            onCell: sectionCell,
            render: (_, r) => (r.j || []).map((c) => /* @__PURE__ */ ctx.libs.React.createElement(JTag, { key: c, code: c, judgments }))
          },
          ...histYears.map((y) => ({
            title: `${y}A`,
            key: "h" + y,
            align: "right",
            width: 84,
            onCell: sectionCell,
            render: (_, r) => /* @__PURE__ */ ctx.libs.React.createElement("span", { style: { color: token.colorTextSecondary } }, cell(r, r["h" + y]))
          })),
          ...years.map((y) => ({
            title: `${y}E`,
            key: "y" + y,
            align: "right",
            width: 84,
            onCell: sectionCell,
            render: (_, r) => cell(r, r["y" + y])
          }))
        ];
        const scCols = [
          { title: "\u60C5\u666F", dataIndex: "name", render: (v, s) => /* @__PURE__ */ ctx.libs.React.createElement("span", null, v, s.is_base && /* @__PURE__ */ ctx.libs.React.createElement(Tag, { color: "blue", style: { marginLeft: 6 } }, "\u57FA\u51C6")) },
          { title: company.volume_label || "\u4E1A\u52A1\u91CF", key: "vf", render: (_, s) => factorText(s.volume_factor) },
          { title: company.price_label || "\u5355\u4EF7", key: "pf", render: (_, s) => factorText(s.price_factor) },
          { title: "\u4ED8\u73B0\u6210\u672C", key: "cf", render: (_, s) => factorText(s.cost_factor) },
          { title: /* @__PURE__ */ ctx.libs.React.createElement("span", null, "\u6C38\u7EED\u589E\u957F ", /* @__PURE__ */ ctx.libs.React.createElement(JTag, { code: "J-TV", judgments })), key: "g", render: (_, s) => pct(s.terminal_growth) },
          { title: `${last}E \u5F52\u6BCD\u51C0\u5229\u6DA6`, key: "np", align: "right", render: (_, s) => fmt(pOf(s, last)?.np_parent, 0) },
          { title: `${last}E \u6BCF\u80A1\u80A1\u606F`, key: "dps", align: "right", render: (_, s) => fmt(pOf(s, last)?.dps, 3) + " \u5143" }
        ];
        return /* @__PURE__ */ ctx.libs.React.createElement("div", null, /* @__PURE__ */ ctx.libs.React.createElement(Title, { level: 4, style: { marginTop: 0 } }, company.name, " \xB7 \u8D22\u52A1\u6A21\u578B"), /* @__PURE__ */ ctx.libs.React.createElement(Paragraph, { type: "secondary" }, PROFILE.logic), /* @__PURE__ */ ctx.libs.React.createElement(Card, { size: "small", title: "\u4E09\u4E2A\u60C5\u666F\u5DEE\u5728\u54EA\uFF08\u7CFB\u6570\u4E58\u5728\u57FA\u51C6\u7684\u9010\u5E74\u8DEF\u5F84\u4E0A\uFF09", style: { marginBottom: 12 } }, /* @__PURE__ */ ctx.libs.React.createElement(Table, { size: "small", pagination: false, rowKey: "id", dataSource: scenarios, columns: scCols, scroll: { x: "max-content" } }), /* @__PURE__ */ ctx.libs.React.createElement(Text, { type: "secondary", style: { fontSize: 12 } }, "\u9010\u5E74\u8DEF\u5F84\u4E0E\u60C5\u666F\u7CFB\u6570\u5171\u540C\u751F\u6210\u9884\u6D4B\uFF1B\u5206\u90E8\u4F30\u503C\u53E6\u7528\u5404\u5206\u90E8\u53C2\u6570\u3002\u6240\u6709\u91D1\u989D\u4E3A\u4EBF\u5143\u4EBA\u6C11\u5E01\uFF0C\u6BCF\u80A1\u91D1\u989D\u53CA\u4E1A\u52A1\u5355\u4F4D\u4EE5\u884C\u6807\u9898\u4E3A\u51C6\u3002")), /* @__PURE__ */ ctx.libs.React.createElement(
          Card,
          {
            size: "small",
            style: { marginBottom: 12 },
            title: /* @__PURE__ */ ctx.libs.React.createElement(Space, { wrap: true }, /* @__PURE__ */ ctx.libs.React.createElement("span", null, "\u9010\u5E74\u9A71\u52A8\uFF1A\u5386\u53F2\u5B9E\u9645 \u2192 \u9884\u6D4B"), /* @__PURE__ */ ctx.libs.React.createElement(Segmented, { size: "small", value: sc.id, onChange: setScId, options: scenarios.map((s) => ({ label: s.name, value: s.id })) }))
          },
          /* @__PURE__ */ ctx.libs.React.createElement(Table, { size: "small", pagination: false, rowKey: "key", dataSource: rows, columns, scroll: { x: "max-content" } }),
          /* @__PURE__ */ ctx.libs.React.createElement(Text, { type: "secondary", style: { fontSize: 12 } }, "\u7070\u5B57\u4E3A\u5386\u53F2\u5B9E\u9645\uFF08\u9884\u6D4B\u4E0E\u4F30\u503C / \u5386\u53F2\u5E74\u5EA6\uFF09\uFF1B\u6539\u9010\u5E74\u6570\u5B57\u8BF7\u5207\u6362\u672C\u9875\u300C\u9010\u5E74\u5047\u8BBE\uFF08\u7F16\u8F91\uFF09\u300D\uFF1B\u60C5\u666F\u548C\u5047\u8BBE\u4F9D\u636E\u5728\u300C\u6A21\u578B\u5E95\u7A3F\u300D\u3002")
        ), /* @__PURE__ */ ctx.libs.React.createElement(Card, { size: "small", title: `\u5168\u90E8\u5047\u8BBE\u4F9D\u636E\uFF08${judgments.length} \u6761\uFF09` }, /* @__PURE__ */ ctx.libs.React.createElement(Collapse, { size: "small", items: [...judgments].sort((a, b) => a.code.localeCompare(b.code)).map((j) => ({
          key: j.code,
          label: /* @__PURE__ */ ctx.libs.React.createElement("span", null, /* @__PURE__ */ ctx.libs.React.createElement("b", null, j.code), " ", j.title, " ", /* @__PURE__ */ ctx.libs.React.createElement(Tag, { style: { marginLeft: 6 } }, j.status), !used.has(j.code) && /* @__PURE__ */ ctx.libs.React.createElement(Text, { type: "secondary", style: { fontSize: 12 } }, "\uFF08\u4E0A\u8868\u6CA1\u6709\u76F4\u63A5\u5BF9\u5E94\u7684\u884C\uFF09")),
          children: /* @__PURE__ */ ctx.libs.React.createElement(Descriptions, { size: "small", column: 1, bordered: true, items: [
            ["\u4E8B\u5B9E\u5C42", j.fact_layer],
            ["\u5224\u65AD", j.judgment],
            ["\u600E\u4E48\u4F20\u5BFC", j.transmission],
            ["\u5F71\u54CD\u53C2\u6570", j.parameter],
            ["\u5F71\u54CD\u5E74\u4EFD", j.affected_years],
            ["\u4EC0\u4E48\u60C5\u51B5\u4E0B\u6539", j.change_threshold],
            ["\u4EC0\u4E48\u60C5\u51B5\u4E0B\u4E0D\u6539", j.no_change_condition],
            ["\u53CD\u8BC1", j.counter_evidence]
          ].filter(([, v]) => v).map(([label, v]) => ({ key: label, label, children: v })) })
        })) })));
      };
      const { company, model, scenarios, judgments, history, years, pOf, fOf } = D;
      const histYears = history.map((h) => h.year).filter((y) => y <= model.base_year).sort((a, b) => a - b).slice(-3);
      const hOf = (y) => history.find((h) => h.year === y);
      const base = scenarios.find((s) => s.is_base) || scenarios[0];
      const used = new Set(PROFILE.drivers.flatMap((r) => r.j || []).concat(["J-TV", PROFILE.hurdle_j]));
      ctx.render(/* @__PURE__ */ ctx.libs.React.createElement(Panel, null));
    }
  } catch (error) {
    ctx.render(/* @__PURE__ */ ctx.libs.React.createElement(Alert, { type: "error", showIcon: true, message: "\u8D22\u52A1\u6A21\u578B\u8BFB\u53D6\u5931\u8D25", description: String(error?.message || error) }));
  }
}
export {
  run as default
};
