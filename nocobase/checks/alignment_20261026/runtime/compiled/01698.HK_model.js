async function run(ctx) {
  const COMPANY = "01698.HK";
  const EDIT_TAB = "\u660E\u7EC6\uFF08\u7F16\u8F91\uFF09";
  const { React } = ctx.libs;
  const { useState, useRef } = React;
  const { Tooltip, Alert, Empty, theme } = ctx.libs.antd;
  async function listRows(name, filter, appends, pageSize = 500) {
    const resource = ctx.makeResource("MultiRecordResource");
    resource.setResourceName(name);
    resource.setPageSize?.(pageSize);
    if (filter) resource.setFilter?.(filter);
    if (appends) resource.setAppends?.(appends);
    await resource.refresh();
    return resource.getData() || [];
  }
  function useWidth(ref) {
    const [w, setW] = useState(0);
    React.useLayoutEffect(() => {
      const el = ref.current;
      if (!el) return void 0;
      setW(el.getBoundingClientRect().width);
      const RO = typeof window !== "undefined" ? window.ResizeObserver : void 0;
      if (!RO) return void 0;
      const ro = new RO((es) => setW(es[0].contentRect.width));
      ro.observe(el);
      return () => ro.disconnect();
    }, []);
    return w;
  }
  const usable = (s) => s !== null && s !== void 0 && String(s).trim() !== "" && s !== "\u2014";
  const codeNum = (c) => Number(String(c || "").replace(/\D/g, "")) || 0;
  const byCode = (a, b) => codeNum(a.code) - codeNum(b.code) || String(a.code).localeCompare(String(b.code));
  const head = (s) => String(s || "").split(/[：:]/)[0];
  const short = (s, n = 16) => {
    const x = head(String(s || "").replace(/^伪壁垒[：:]\s*/, "")).replace(/（[^）]*）/g, "").trim();
    return x.length > n ? x.slice(0, n) + "\u2026" : x;
  };
  const clamp = (n) => ({ overflow: "hidden", display: "-webkit-box", WebkitLineClamp: n, WebkitBoxOrient: "vertical", wordBreak: "break-all" });
  const REF_KIND = { V: "\u4EA7\u4E1A\u94FE", M: "\u58C1\u5792", T: "\u8BBA\u70B9", B: "\u5546\u4E1A\u6A21\u5F0F", J: "\u5047\u8BBE\u4F9D\u636E", R: "\u98CE\u9669", K: "\u8DDF\u8E2A\u4E8B\u9879", W: "\u8DDF\u8E2A\u4E8B\u9879" };
  const REF_RE = /(?<![A-Za-z0-9-])(V\d{1,2}|M\d{1,2}|T\d{1,2}|B\d{1,2}|R\d{1,2}|K\d{1,2}|W\d{1,2}|J-[A-Z0-9]+)(?![0-9])/g;
  function useUI() {
    const { token: t } = theme.useToken();
    const orange = t.orange6 || "#d46b08";
    return {
      t,
      status: { \u6210\u7ACB: t.colorSuccess, \u89C2\u5BDF: t.colorWarning, \u5B58\u7591: orange, \u8BC1\u4F2A: t.colorError },
      verdict: { \u771F\u5B9E\u58C1\u5792: t.colorSuccess, \u5C40\u90E8\u4F18\u52BF: t.colorPrimary, \u5F85\u9A8C\u8BC1: t.colorWarning, \u4F2A\u58C1\u5792: t.colorTextQuaternary },
      level: { \u91CD\u5927: t.colorError, \u91CD\u8981: orange, \u4E00\u822C: t.colorTextQuaternary },
      fs: {
        h1: { fontSize: 22, fontWeight: 600, lineHeight: 1.45, color: t.colorTextHeading, margin: 0 },
        h2: { fontSize: 20, fontWeight: 600, lineHeight: 1.45, color: t.colorTextHeading, margin: 0 },
        title: { fontSize: 15, fontWeight: 600, lineHeight: 1.5, color: t.colorText },
        body: { fontSize: 14, lineHeight: 1.75, color: t.colorText },
        meta: { fontSize: 13, lineHeight: 1.6, color: t.colorTextSecondary },
        code: { fontSize: 12, color: t.colorTextTertiary, fontVariantNumeric: "tabular-nums", letterSpacing: 0.3 }
      }
    };
  }
  function Dot({ color, size = 8 }) {
    const { t } = useUI();
    return /* @__PURE__ */ ctx.libs.React.createElement("span", { style: { width: size, height: size, borderRadius: "50%", flex: "none", display: "inline-block", background: color || t.colorBorder } });
  }
  function Status({ label, color, size = 13, strong }) {
    const { t } = useUI();
    return /* @__PURE__ */ ctx.libs.React.createElement("span", { style: { display: "inline-flex", alignItems: "center", gap: 6, fontSize: size, color: t.colorText, fontWeight: strong ? 600 : 400, whiteSpace: "nowrap" } }, /* @__PURE__ */ ctx.libs.React.createElement(Dot, { color }), label);
  }
  function Tag({ children }) {
    const { t } = useUI();
    return /* @__PURE__ */ ctx.libs.React.createElement("span", { style: { fontSize: 12, lineHeight: "20px", padding: "0 7px", borderRadius: 4, background: t.colorFillTertiary, color: t.colorTextSecondary, whiteSpace: "nowrap" } }, children);
  }
  function Flag({ children }) {
    const { t } = useUI();
    return /* @__PURE__ */ ctx.libs.React.createElement("span", { style: { fontSize: 12, lineHeight: "20px", padding: "0 7px", borderRadius: 4, background: t.colorWarningBg, color: t.colorWarningText, whiteSpace: "nowrap" } }, "\u26A0 ", children);
  }
  function RefText({ text, refs }) {
    const { t } = useUI();
    if (!usable(text)) return null;
    const parts = String(text).split(REF_RE);
    return /* @__PURE__ */ ctx.libs.React.createElement(React.Fragment, null, parts.map((p, i) => {
      if (i % 2 === 0) return /* @__PURE__ */ ctx.libs.React.createElement(React.Fragment, { key: i }, p);
      const kind = p.startsWith("J-") ? "J" : p[0];
      const title = refs[p];
      return /* @__PURE__ */ ctx.libs.React.createElement(Tooltip, { key: i, title: title ? `${REF_KIND[kind]} ${p}\uFF1A${title}` : `${REF_KIND[kind]} ${p}` }, /* @__PURE__ */ ctx.libs.React.createElement("span", { style: { color: t.colorPrimary, cursor: "help", borderBottom: `1px dashed ${t.colorPrimaryBorder}` } }, p));
    }));
  }
  function Label({ children }) {
    const { t } = useUI();
    return /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { fontSize: 13, fontWeight: 600, color: t.colorTextHeading, marginBottom: 6 } }, children);
  }
  function Section({ label, text, refs, tone = "plain", children }) {
    const { t, fs } = useUI();
    if (!children && !usable(text)) return null;
    const box = {
      plain: {},
      pro: { borderLeft: `3px solid ${t.colorSuccess}`, paddingLeft: 14 },
      con: { borderLeft: `3px solid ${t.colorWarning}`, paddingLeft: 14 },
      key: { background: t.colorFillQuaternary, borderRadius: 10, padding: "12px 16px" }
    }[tone];
    return /* @__PURE__ */ ctx.libs.React.createElement("div", { style: box }, /* @__PURE__ */ ctx.libs.React.createElement(Label, null, label), children || /* @__PURE__ */ ctx.libs.React.createElement("p", { style: { ...fs.body, fontSize: 14.5, lineHeight: 1.8, margin: 0, whiteSpace: "pre-wrap" } }, /* @__PURE__ */ ctx.libs.React.createElement(RefText, { text, refs })));
  }
  function Attrs({ items }) {
    const { t } = useUI();
    const xs = items.filter((x) => x);
    return /* @__PURE__ */ ctx.libs.React.createElement("div", { style: {
      display: "grid",
      gridTemplateColumns: `repeat(${Math.min(xs.length, 4)}, minmax(0,1fr))`,
      gap: 16,
      padding: "14px 0",
      borderTop: `1px solid ${t.colorSplit}`,
      borderBottom: `1px solid ${t.colorSplit}`
    } }, xs.map(([k, v]) => /* @__PURE__ */ ctx.libs.React.createElement("div", { key: k, style: { minWidth: 0 } }, /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { fontSize: 12, color: t.colorTextSecondary, marginBottom: 4 } }, k), /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { fontSize: 15, fontWeight: 600, color: t.colorText } }, v || "\u2014"))));
  }
  function LinkList({ label, items }) {
    const { t, fs } = useUI();
    if (!items || !items.length) return null;
    return /* @__PURE__ */ ctx.libs.React.createElement("div", null, /* @__PURE__ */ ctx.libs.React.createElement(Label, null, label), /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { display: "flex", flexDirection: "column", gap: 6 } }, items.map((x, i) => /* @__PURE__ */ ctx.libs.React.createElement("div", { key: i, style: { display: "flex", gap: 10, alignItems: "baseline" } }, x.code ? /* @__PURE__ */ ctx.libs.React.createElement("span", { style: { ...fs.code, flex: "none", minWidth: 30 } }, x.code) : null, /* @__PURE__ */ ctx.libs.React.createElement("span", { style: { ...fs.body, flex: 1, minWidth: 0 } }, x.title), x.tag ? /* @__PURE__ */ ctx.libs.React.createElement(Status, { label: x.tag, color: x.color }) : null))));
  }
  function Facts({ facts }) {
    const { fs } = useUI();
    if (!facts || !facts.length) return null;
    return /* @__PURE__ */ ctx.libs.React.createElement("div", null, /* @__PURE__ */ ctx.libs.React.createElement(Label, null, "\u4F9D\u636E\u4E8B\u5B9E"), facts.map((f) => /* @__PURE__ */ ctx.libs.React.createElement("div", { key: f.id, style: { ...fs.meta, paddingLeft: 14, position: "relative" } }, /* @__PURE__ */ ctx.libs.React.createElement("span", { style: { position: "absolute", left: 2 } }, "\xB7"), f.title)));
  }
  function Stats({ items }) {
    const { t } = useUI();
    return /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { display: "flex", flexWrap: "wrap", rowGap: 12 } }, items.map((x, i) => /* @__PURE__ */ ctx.libs.React.createElement("div", { key: x.label, style: { paddingRight: 28, marginRight: 28, borderRight: i < items.length - 1 ? `1px solid ${t.colorSplit}` : "none", opacity: x.value ? 1 : 0.45 } }, /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { display: "flex", alignItems: "center", gap: 6, fontSize: 13, color: t.colorTextSecondary } }, x.color ? /* @__PURE__ */ ctx.libs.React.createElement(Dot, { color: x.color }) : null, x.label), /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { fontSize: 28, fontWeight: 600, lineHeight: 1.25, color: t.colorTextHeading, fontVariantNumeric: "tabular-nums" } }, x.value, /* @__PURE__ */ ctx.libs.React.createElement("span", { style: { fontSize: 14, fontWeight: 400, color: t.colorTextSecondary, marginLeft: 4 } }, x.unit || "")))));
  }
  function Notice({ items }) {
    const { t, fs } = useUI();
    if (!items || !items.length) return null;
    return /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { background: t.colorWarningBg, border: `1px solid ${t.colorWarningBorder}`, borderRadius: 10, padding: "12px 16px" } }, /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { ...fs.title, fontSize: 14, marginBottom: 4 } }, "\u26A0 \u9700\u8981\u5904\u7406"), items.map((x, i) => /* @__PURE__ */ ctx.libs.React.createElement("div", { key: i, style: { ...fs.body, fontSize: 13.5, lineHeight: 1.7 } }, x)));
  }
  function Card({ selected, onClick, children, style, accent, muted }) {
    const { t } = useUI();
    const base = selected ? t.colorPrimary : t.colorBorderSecondary;
    return /* @__PURE__ */ ctx.libs.React.createElement(
      "div",
      {
        onClick,
        onMouseEnter: (e) => {
          if (!selected) e.currentTarget.style.borderColor = t.colorPrimaryBorderHover || t.colorPrimaryBorder;
        },
        onMouseLeave: (e) => {
          if (!selected) e.currentTarget.style.borderColor = base;
        },
        style: {
          background: muted ? t.colorFillQuaternary : t.colorBgContainer,
          cursor: "pointer",
          borderRadius: 12,
          minWidth: 0,
          border: `1px solid ${base}`,
          boxShadow: selected ? `0 0 0 3px ${t.colorPrimaryBg}` : "0 1px 2px rgba(0,0,0,0.03)",
          borderLeft: accent ? `4px solid ${accent}` : `1px solid ${base}`,
          transition: "border-color .15s, box-shadow .15s",
          ...style
        }
      },
      children
    );
  }
  function DetailHead({ meta, title, children }) {
    const { fs } = useUI();
    return /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { display: "flex", flexDirection: "column", gap: 8 } }, /* @__PURE__ */ ctx.libs.React.createElement("div", { style: fs.meta }, meta), /* @__PURE__ */ ctx.libs.React.createElement("h2", { style: fs.h2 }, title), children);
  }
  function Shell({ eyebrow, headline, hint, stats, notice, main, detail, sel, detailWidth = 420, minSide = 1200 }) {
    const { t, fs } = useUI();
    const rootRef = useRef(null);
    const detailRef = useRef(null);
    const first = useRef(true);
    const W = useWidth(rootRef);
    const side = W >= minSide;
    React.useEffect(() => {
      if (first.current) {
        first.current = false;
        return;
      }
      if (!side) detailRef.current?.scrollIntoView?.({ behavior: "smooth", block: "start" });
    }, [sel]);
    return /* @__PURE__ */ ctx.libs.React.createElement("div", { ref: rootRef, style: { maxWidth: 1480, margin: "0 auto", padding: "8px 8px 16px" } }, /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { display: "flex", flexDirection: "column", gap: 6, marginBottom: 24 } }, /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { ...fs.meta, fontWeight: 500 } }, eyebrow), /* @__PURE__ */ ctx.libs.React.createElement("h1", { style: fs.h1 }, headline), /* @__PURE__ */ ctx.libs.React.createElement("div", { style: fs.meta }, hint, "\u3000\u4FEE\u6539\u8BF7\u5207\u5230\u201C", EDIT_TAB, "\u201D\u6807\u7B7E\u3002")), stats || notice ? /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { display: "flex", flexDirection: "column", gap: 18, marginBottom: 28 } }, stats, notice) : null, /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { display: "grid", gridTemplateColumns: side ? `minmax(0,1fr) ${detailWidth}px` : "1fr", gap: side ? 36 : 28, alignItems: "start" } }, /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { minWidth: 0 } }, typeof main === "function" ? main(W - (side ? detailWidth + 36 : 0)) : main), /* @__PURE__ */ ctx.libs.React.createElement("div", { ref: detailRef, style: side ? { position: "sticky", top: 12, borderLeft: `1px solid ${t.colorSplit}`, paddingLeft: 32 } : { borderTop: `1px solid ${t.colorSplit}`, paddingTop: 28, maxWidth: 760 } }, detail)));
  }
  async function loadRefs(scope) {
    const [chain, moats, theses, biz, judgments, risks, watches] = await Promise.all([
      listRows("vi_value_chain", scope),
      listRows("vi_moat", scope),
      listRows("vi_thesis", scope),
      listRows("vi_biz_model", scope),
      listRows("vi_judgment", scope),
      listRows("vi_risk", scope),
      listRows("vi_watch", scope)
    ]);
    const refs = {};
    chain.forEach((r) => {
      refs[r.code] = r.participant;
    });
    moats.forEach((r) => {
      refs[r.code] = `${r.title}\uFF08${r.verdict || ""}\uFF09`;
    });
    theses.forEach((r) => {
      refs[r.code] = `${r.title}${r.status ? "\uFF08" + r.status + "\uFF09" : ""}`;
    });
    biz.forEach((r) => {
      refs[r.code] = `${r.element}\uFF1A${r.title}`;
    });
    judgments.forEach((r) => {
      refs[r.code] = r.title;
    });
    risks.forEach((r) => {
      refs[r.code] = r.title;
    });
    watches.forEach((r) => {
      refs[r.code] = r.title;
    });
    return refs;
  }
  async function boot(what, fn) {
    try {
      const cos = await listRows("vi_company", { code: { $eq: COMPANY } });
      const company = cos[0];
      if (!company) {
        ctx.render(/* @__PURE__ */ ctx.libs.React.createElement(Alert, { type: "info", showIcon: true, message: `\u516C\u53F8\u8868\u91CC\u6CA1\u6709\u4EE3\u7801\u4E3A ${COMPANY} \u7684\u516C\u53F8` }));
        return;
      }
      await fn(company, { company_id: { $eq: company.id } });
    } catch (error) {
      ctx.render(/* @__PURE__ */ ctx.libs.React.createElement(Alert, { type: "error", showIcon: true, message: `${what}\u8BFB\u53D6\u5931\u8D25`, description: String(error?.message || error) }));
    }
  }
  const pct = (v, d = 1) => v === null || v === void 0 || v === "" ? "\u2014" : `${(Number(v) * 100).toFixed(d)}%`;
  const num = (v, d = 2) => v === null || v === void 0 || v === "" ? "\u2014" : Number(v).toLocaleString("zh-CN", { minimumFractionDigits: d, maximumFractionDigits: d });
  function RateBar({ m }) {
    const { t, fs } = useUI();
    const rf = Number(m.rf || 0), erp = Number(m.erp || 0), req = Number(m.required_return || 0);
    const max = Math.max(rf + erp, req) * 1.15 || 0.1;
    const w = (v) => `${v / max * 100}%`;
    return /* @__PURE__ */ ctx.libs.React.createElement("div", null, /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { position: "relative", height: 30, background: t.colorFillQuaternary, borderRadius: 8, overflow: "visible" } }, /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { position: "absolute", left: 0, top: 0, bottom: 0, width: w(rf), background: t.colorPrimary, borderRadius: "8px 0 0 8px" } }), /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { position: "absolute", left: w(rf), top: 0, bottom: 0, width: w(erp), background: t.colorPrimaryBorder, borderRadius: "0 8px 8px 0", borderLeft: `2px solid ${t.colorBgContainer}` } }), req ? /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { position: "absolute", left: w(req), top: -6, bottom: -6, borderLeft: `2px dashed ${t.colorText}` } }) : null), /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { display: "flex", flexWrap: "wrap", gap: 18, marginTop: 10 } }, /* @__PURE__ */ ctx.libs.React.createElement(Status, { label: `\u65E0\u98CE\u9669\u5229\u7387 ${pct(rf, 2)}`, color: t.colorPrimary }), /* @__PURE__ */ ctx.libs.React.createElement(Status, { label: `\u98CE\u9669\u6EA2\u4EF7 ${pct(erp, 2)}`, color: t.colorPrimaryBorder }), /* @__PURE__ */ ctx.libs.React.createElement("span", { style: { fontSize: 13, color: t.colorText } }, "\uFF1D \u57FA\u51C6\u6298\u73B0\u7387 ", /* @__PURE__ */ ctx.libs.React.createElement("b", null, pct(m.base_discount_rate, 2))), req ? /* @__PURE__ */ ctx.libs.React.createElement("span", { style: { fontSize: 13, color: t.colorText } }, "\u2506 \u95E8\u69DB\uFF08\u8981\u6C42\u6536\u76CA\u7387\uFF09", /* @__PURE__ */ ctx.libs.React.createElement("b", null, pct(req))) : null), m.latest_rf !== null && m.latest_rf !== void 0 ? /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { ...fs.meta, marginTop: 6 } }, "\u65E0\u98CE\u9669\u5229\u7387\u6700\u65B0\u89C2\u5BDF ", num(m.latest_rf, 2), "%\uFF08", m.latest_rf_date, "\uFF09\uFF1B\u6A21\u578B\u91CC\u7528\u7684\u662F ", m.rf_date || "\u2014", " \u7684 ", pct(rf, 2), "\u3002") : null);
  }
  function Balance({ m }) {
    const { t, fs } = useUI();
    const items = [
      ["\u7ECF\u8425\u6027\u957F\u671F\u8D44\u4EA7", m.opening_op_assets, t.colorPrimary],
      ["\u957F\u671F\u80A1\u6743\u6295\u8D44", m.opening_lt_invest, t.colorPrimary],
      ["\u5E26\u606F\u8D1F\u503A", m.opening_debt, "#eb6834"],
      ["\u5F52\u6BCD\u6743\u76CA", m.opening_equity, t.colorTextSecondary],
      ["\u5C11\u6570\u80A1\u4E1C\u6743\u76CA", m.opening_minority, t.colorTextSecondary]
    ].filter((x) => x[1] !== null && x[1] !== void 0);
    if (!items.length) return null;
    const max = Math.max(...items.map((x) => Number(x[1])));
    return /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { display: "flex", flexDirection: "column", gap: 10 } }, items.map(([k, v, c]) => /* @__PURE__ */ ctx.libs.React.createElement("div", { key: k, style: { display: "grid", gridTemplateColumns: "120px 1fr 96px", alignItems: "center", gap: 12 } }, /* @__PURE__ */ ctx.libs.React.createElement("span", { style: { fontSize: 13.5, color: t.colorText } }, k), /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { height: 10, background: t.colorFillQuaternary, borderRadius: 5 } }, /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { width: `${Number(v) / max * 100}%`, height: "100%", background: c, borderRadius: 5 } })), /* @__PURE__ */ ctx.libs.React.createElement("span", { style: { fontSize: 14, fontWeight: 600, color: t.colorText, textAlign: "right", fontVariantNumeric: "tabular-nums" } }, num(v, 0), /* @__PURE__ */ ctx.libs.React.createElement("span", { style: { ...fs.code, marginLeft: 3 } }, "\u4EBF")))));
  }
  boot("\u4F30\u503C\u6A21\u578B", async (company, scope) => {
    const [models, judgments, refs] = await Promise.all([listRows("vi_model", scope), listRows("vi_judgment", scope), loadRefs(scope)]);
    models.sort((a, b) => (a.status === "\u5F53\u524D" ? -1 : 0) - (b.status === "\u5F53\u524D" ? -1 : 0) || a.id - b.id);
    function Page() {
      const { t, fs } = useUI();
      const [sel, setSel] = useState(models[0]?.id);
      if (!models.length) return /* @__PURE__ */ ctx.libs.React.createElement(Empty, { description: `${company.name}\u8FD8\u6CA1\u6709\u4F30\u503C\u6A21\u578B\uFF08\u5207\u5230\u201C${EDIT_TAB}\u201D\u6807\u7B7E\u65B0\u589E\uFF09` });
      const m = models.find((x) => x.id === sel) || models[0];
      const hurdleJ = judgments.filter((j) => /要求收益率|门槛/.test(`${j.parameter || ""}${j.title || ""}`)).sort(byCode);
      const headline = usable(m.method) ? String(m.method).split(/[；;。]/)[0] : m.name;
      const span = m.base_year && m.terminal_year ? `${m.base_year} \u2192 ${m.terminal_year}` : "\u2014";
      const main = /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { display: "flex", flexDirection: "column", gap: 30 } }, models.length > 1 ? /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { display: "flex", gap: 8, flexWrap: "wrap" } }, models.map((x) => /* @__PURE__ */ ctx.libs.React.createElement(Card, { key: x.id, selected: x.id === m.id, onClick: () => setSel(x.id), style: { padding: "8px 14px" } }, /* @__PURE__ */ ctx.libs.React.createElement("span", { style: { fontSize: 14, color: t.colorText } }, x.name), " ", /* @__PURE__ */ ctx.libs.React.createElement("span", { style: fs.code }, x.status || "")))) : null, /* @__PURE__ */ ctx.libs.React.createElement("div", null, /* @__PURE__ */ ctx.libs.React.createElement(Label, null, "\u6298\u73B0\u7387\u6784\u6210\uFF08\u865A\u7EBF\u662F\u95E8\u69DB\uFF09"), /* @__PURE__ */ ctx.libs.React.createElement(RateBar, { m })), /* @__PURE__ */ ctx.libs.React.createElement("div", null, /* @__PURE__ */ ctx.libs.React.createElement(Label, null, "\u671F\u521D\u8D44\u4EA7\u8D1F\u503A\uFF08", m.base_year, " \u5E74\u672B\uFF0C\u4EBF\u5143\uFF09"), /* @__PURE__ */ ctx.libs.React.createElement(Balance, { m })), /* @__PURE__ */ ctx.libs.React.createElement(LinkList, { label: "\u95E8\u69DB\u7684\u4F9D\u636E\uFF08\u5047\u8BBE\u4F9D\u636E\uFF09", items: hurdleJ.map((j) => ({ code: j.code, title: j.title, tag: j.status })) }), /* @__PURE__ */ ctx.libs.React.createElement(Attrs, { items: [
        ["\u4E3B\u4F30\u503C\u65B9\u6CD5", m.primary_method || "\u2014"],
        ["\u5B89\u5168\u8FB9\u9645", m.margin_low !== null && m.margin_low !== void 0 ? `${pct(m.margin_low, 0)} / ${pct(m.margin_high, 0)}` : "\u2014"],
        ["\u5206\u90E8\u52A0\u603B\u6838\u5FC3\u5E74", m.sotp_year || "\u2014"],
        ["\u72B6\u6001", m.status || "\u2014"]
      ] }));
      return /* @__PURE__ */ ctx.libs.React.createElement(
        Shell,
        {
          eyebrow: `${company.name} \xB7 \u4F30\u503C\u6A21\u578B`,
          headline,
          hint: `${m.name}\u3002\u65B9\u6CD5\u3001\u95E8\u69DB\u548C\u671F\u521D\u6570\u90FD\u5728\u8FD9\u91CC\uFF1B\u9010\u5E74\u6570\u5B57\u89C1\u201C\u8D22\u52A1\u6A21\u578B / \u9010\u5E74\u5047\u8BBE\uFF08\u7F16\u8F91\uFF09\u201D\uFF0C\u60C5\u666F\u89C1\u201C\u60C5\u666F\u201D\u3002`,
          stats: /* @__PURE__ */ ctx.libs.React.createElement(Stats, { items: [
            { label: "\u95E8\u69DB\uFF08\u8981\u6C42\u6536\u76CA\u7387\uFF09", value: pct(m.required_return) },
            { label: "\u9884\u6D4B\u533A\u95F4", value: span },
            { label: "\u80A1\u672C", value: num(m.shares), unit: "\u4EBF\u80A1" },
            { label: "\u4F30\u503C\u65E5", value: m.valuation_date || "\u2014" }
          ] }),
          main,
          sel,
          detailWidth: 460,
          detail: /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { display: "flex", flexDirection: "column", gap: 22 } }, /* @__PURE__ */ ctx.libs.React.createElement(DetailHead, { meta: "\u6A21\u578B\u8BF4\u660E", title: m.name }), /* @__PURE__ */ ctx.libs.React.createElement(Section, { label: "\u65B9\u6CD5", text: m.method, refs, tone: "key" }), /* @__PURE__ */ ctx.libs.React.createElement(Section, { label: "\u8BF4\u660E\u4E0E\u6765\u6E90", text: m.notes, refs }))
        }
      );
    }
    ctx.render(/* @__PURE__ */ ctx.libs.React.createElement(Page, null));
  });
}
export {
  run as default
};
