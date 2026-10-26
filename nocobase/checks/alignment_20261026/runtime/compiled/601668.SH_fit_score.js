async function run(ctx) {
  const COMPANY = "601668.SH";
  const { React } = ctx.libs;
  const { Tooltip, Alert, Empty, theme } = ctx.libs.antd;
  async function listRows(name, filter) {
    const resource = ctx.makeResource("MultiRecordResource");
    resource.setResourceName(name);
    resource.setPageSize?.(100);
    if (filter) resource.setFilter?.(filter);
    await resource.refresh();
    return resource.getData() || [];
  }
  const BANDS = [
    { from: 0, to: 21, name: "\u4E0D\u9002\u5408", text: "\u901A\u5E38\u4E0D\u7B26\u5408\u4EF7\u503C\u6295\u8D44\u6807\u51C6" },
    { from: 22, to: 31, name: "\u53EF\u7814\u7A76", text: "\u53EF\u7814\u7A76\uFF0C\u9700\u8BF4\u660E\u66F4\u504F\u590D\u5229\u3001\u73B0\u91D1\u6D41\u4EF7\u503C\u8FD8\u662F\u8D44\u4EA7\u4EF7\u503C" },
    { from: 32, to: 40, name: "\u590D\u5229\u578B", text: "\u9002\u5408\u4EF7\u503C\u6295\u8D44\u590D\u5229\u6846\u67B6\uFF08\u4ECD\u9700\u4EF7\u683C\u5B89\u5168\u8FB9\u9645\uFF09" }
  ];
  function Board({ company, rows }) {
    const { token } = theme.useToken();
    const total = rows.reduce((a, r) => a + (Number(r.score) || 0), 0);
    const max = rows.length * 5 || 40;
    const scaled = max === 40 ? total : Math.round(total / max * 40);
    const band = BANDS.find((b) => scaled >= b.from && scaled <= b.to) || BANDS[0];
    const tone = { \u4E0D\u9002\u5408: token.colorError, \u53EF\u7814\u7A76: token.colorWarning, \u590D\u5229\u578B: token.colorSuccess };
    const soft = { \u4E0D\u9002\u5408: token.colorErrorBg, \u53EF\u7814\u7A76: token.colorWarningBg, \u590D\u5229\u578B: token.colorSuccessBg };
    const color = (s) => s >= 4 ? token.colorSuccess : s <= 2 ? token.colorError : token.colorTextSecondary;
    const strong = rows.filter((r) => Number(r.score) >= 4);
    const weak = rows.filter((r) => Number(r.score) <= 2);
    const list = (xs) => xs.map((r) => `${r.dimension} ${r.score}`).join("\u3001");
    const narrow = (typeof window !== "undefined" ? window.innerWidth : 1400) < 900;
    return /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { display: "grid", gridTemplateColumns: narrow ? "1fr" : "minmax(260px, 1fr) minmax(0, 2fr)", gap: narrow ? 20 : 40, alignItems: "center" } }, /* @__PURE__ */ ctx.libs.React.createElement("div", null, /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { fontSize: 12, color: token.colorTextTertiary } }, company.name, " \xB7 \u4EF7\u6295\u9002\u914D\u5EA6"), /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { display: "flex", alignItems: "baseline", gap: 10, marginTop: 4 } }, /* @__PURE__ */ ctx.libs.React.createElement("span", { style: { fontSize: 44, fontWeight: 600, lineHeight: 1.1, color: tone[band.name] } }, total), /* @__PURE__ */ ctx.libs.React.createElement("span", { style: { fontSize: 16, color: token.colorTextTertiary } }, "/ ", max), /* @__PURE__ */ ctx.libs.React.createElement("span", { style: { fontSize: 13, fontWeight: 600, color: tone[band.name], background: soft[band.name], borderRadius: 4, padding: "2px 8px" } }, band.name)), /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { fontSize: 13, color: token.colorTextSecondary, marginTop: 6, lineHeight: 1.6 } }, band.text), /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { position: "relative", marginTop: 14, paddingTop: 10 } }, /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { display: "flex", height: 6, borderRadius: 3, overflow: "hidden" } }, BANDS.map((b) => /* @__PURE__ */ ctx.libs.React.createElement("div", { key: b.name, style: { flex: b.to - b.from + 1, background: b.name === band.name ? tone[b.name] : token.colorFillSecondary, opacity: b.name === band.name ? 0.85 : 1 } }))), /* @__PURE__ */ ctx.libs.React.createElement("div", { style: {
      position: "absolute",
      top: 0,
      left: `calc(${Math.min(scaled, 40) / 41 * 100}% - 5px)`,
      width: 0,
      height: 0,
      borderLeft: "5px solid transparent",
      borderRight: "5px solid transparent",
      borderTop: `7px solid ${token.colorText}`
    } }), /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { display: "flex", fontSize: 11, color: token.colorTextTertiary, marginTop: 4 } }, BANDS.map((b) => /* @__PURE__ */ ctx.libs.React.createElement("span", { key: b.name, style: { flex: b.to - b.from + 1 } }, b.name, " ", b.from === 0 ? `\u2264${b.to}` : b.to === 40 ? `${b.from}+` : `${b.from}\u2013${b.to}`))))), /* @__PURE__ */ ctx.libs.React.createElement("div", null, /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { display: "grid", gridTemplateColumns: narrow ? "repeat(2, minmax(0,1fr))" : "repeat(4, minmax(0,1fr))", gap: "14px 24px" } }, rows.map((r) => {
      const s = Number(r.score) || 0;
      return /* @__PURE__ */ ctx.libs.React.createElement(Tooltip, { key: r.id, title: /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { maxWidth: 360 } }, /* @__PURE__ */ ctx.libs.React.createElement("div", null, r.rationale), r.counter ? /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { marginTop: 6, opacity: 0.8 } }, "\u53CD\u9762\uFF1A", r.counter) : null) }, /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { cursor: "help", minWidth: 0 } }, /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { display: "flex", justifyContent: "space-between", alignItems: "baseline" } }, /* @__PURE__ */ ctx.libs.React.createElement("span", { style: { fontSize: 13, color: token.colorText } }, r.dimension), /* @__PURE__ */ ctx.libs.React.createElement("span", { style: { fontSize: 15, fontWeight: 600, color: color(s) } }, r.score ?? "\u2014")), /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { display: "flex", gap: 3, marginTop: 5 } }, [1, 2, 3, 4, 5].map((i) => /* @__PURE__ */ ctx.libs.React.createElement("span", { key: i, style: { flex: 1, height: 5, borderRadius: 2, background: i <= s ? color(s) : token.colorFillSecondary } })))));
    })), /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { marginTop: 16, fontSize: 13, color: token.colorTextSecondary, lineHeight: 1.7 } }, strong.length ? /* @__PURE__ */ ctx.libs.React.createElement("span", null, /* @__PURE__ */ ctx.libs.React.createElement("span", { style: { color: token.colorSuccess, fontWeight: 600 } }, "\u5F3A\u9879"), "\u3000", list(strong)) : null, strong.length && weak.length ? /* @__PURE__ */ ctx.libs.React.createElement("span", { style: { margin: "0 12px", color: token.colorSplit } }, "|") : null, weak.length ? /* @__PURE__ */ ctx.libs.React.createElement("span", null, /* @__PURE__ */ ctx.libs.React.createElement("span", { style: { color: token.colorError, fontWeight: 600 } }, "\u77ED\u677F"), "\u3000", list(weak)) : null, /* @__PURE__ */ ctx.libs.React.createElement("span", { style: { marginLeft: 12, color: token.colorTextQuaternary } }, "\u60AC\u505C\u7EF4\u5EA6\u770B\u7406\u7531\u4E0E\u53CD\u9762"))));
  }
  try {
    const cos = await listRows("vi_company", { code: { $eq: COMPANY } });
    const company = cos[0];
    if (!company) {
      ctx.render(/* @__PURE__ */ ctx.libs.React.createElement(Alert, { type: "info", showIcon: true, message: `\u516C\u53F8\u8868\u91CC\u6CA1\u6709\u4EE3\u7801\u4E3A ${COMPANY} \u7684\u516C\u53F8` }));
    } else {
      const rows = (await listRows("vi_fit_score", { company_id: { $eq: company.id } })).sort((a, b) => (Number(a.sort) || 0) - (Number(b.sort) || 0));
      ctx.render(rows.length ? /* @__PURE__ */ ctx.libs.React.createElement(Board, { company, rows }) : /* @__PURE__ */ ctx.libs.React.createElement(Empty, { description: "\u8FD8\u6CA1\u6709\u8BC4\u5206\uFF1A\u5728\u201C\u660E\u7EC6\uFF08\u7F16\u8F91\uFF09\u201D\u6807\u7B7E\u91CC\u7ED9\u516B\u4E2A\u7EF4\u5EA6\u5404\u6253 0\u20145 \u5206" }));
    }
  } catch (error) {
    ctx.render(/* @__PURE__ */ ctx.libs.React.createElement(Alert, { type: "error", showIcon: true, message: "\u9002\u914D\u5EA6\u8BFB\u53D6\u5931\u8D25", description: String(error?.message || error) }));
  }
}
export {
  run as default
};
