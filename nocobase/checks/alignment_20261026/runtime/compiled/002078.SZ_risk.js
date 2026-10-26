async function run(ctx) {
  const COMPANY = "002078.SZ";
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
  const LV = { \u9AD8: 3, \u4E2D: 2, \u4F4E: 1 };
  const score = (r) => (LV[r.probability] || 0) * (LV[r.impact] || 0);
  function Chip({ r, selected, onSelect }) {
    const { t, fs, level } = useUI();
    const arrow = r.trend === "\u4E0A\u5347" ? ["\u2191", t.colorError] : r.trend === "\u4E0B\u964D" ? ["\u2193", t.colorSuccess] : null;
    return /* @__PURE__ */ ctx.libs.React.createElement(Tooltip, { title: r.title, mouseEnterDelay: 0.3 }, /* @__PURE__ */ ctx.libs.React.createElement(
      "div",
      {
        onClick: () => onSelect(r.code),
        style: {
          display: "flex",
          gap: 8,
          alignItems: "center",
          padding: "8px 10px",
          borderRadius: 8,
          cursor: "pointer",
          background: t.colorBgContainer,
          border: `1px solid ${selected ? t.colorPrimary : t.colorBorderSecondary}`,
          boxShadow: selected ? `0 0 0 3px ${t.colorPrimaryBg}` : "0 1px 2px rgba(0,0,0,0.04)"
        }
      },
      /* @__PURE__ */ ctx.libs.React.createElement(Dot, { color: level[r.level] }),
      /* @__PURE__ */ ctx.libs.React.createElement("span", { style: { ...fs.code, flex: "none" } }, r.code),
      /* @__PURE__ */ ctx.libs.React.createElement("span", { style: { flex: 1, minWidth: 0, fontSize: 14, lineHeight: 1.45, color: t.colorText, ...clamp(2) } }, head(r.title)),
      arrow ? /* @__PURE__ */ ctx.libs.React.createElement("span", { style: { color: arrow[1], fontSize: 13, fontWeight: 700 } }, arrow[0]) : null
    ));
  }
  function Matrix({ rows, sel, onSelect, compact }) {
    const { t } = useUI();
    const bg = (s) => s >= 6 ? t.colorErrorBg : s >= 3 ? t.colorWarningBg : t.colorFillQuaternary;
    const axis = { fontSize: 13, color: t.colorTextSecondary, display: "flex", alignItems: "center", justifyContent: "center" };
    const cell = (p, i) => {
      const xs = rows.filter((r) => LV[r.probability] === p && LV[r.impact] === i);
      return /* @__PURE__ */ ctx.libs.React.createElement("div", { key: `${p}${i}`, style: { background: bg(p * i), borderRadius: 10, padding: 10, minHeight: compact ? 64 : 120, display: "flex", flexDirection: "column", gap: 8, minWidth: 0 } }, xs.map((r) => /* @__PURE__ */ ctx.libs.React.createElement(Chip, { key: r.code, r, selected: r.code === sel, onSelect })));
    };
    return /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { display: "grid", gridTemplateColumns: "44px repeat(3, minmax(0,1fr))", gridTemplateRows: "repeat(3, auto) 30px", gap: 8 } }, [3, 2, 1].map((p) => /* @__PURE__ */ ctx.libs.React.createElement(React.Fragment, { key: p }, /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { ...axis, flexDirection: "column", gap: 2 } }, /* @__PURE__ */ ctx.libs.React.createElement("span", { style: { fontWeight: 600, color: t.colorText } }, ["", "\u4F4E", "\u4E2D", "\u9AD8"][p]), /* @__PURE__ */ ctx.libs.React.createElement("span", { style: { fontSize: 12 } }, "\u53EF\u80FD\u6027")), [1, 2, 3].map((i) => cell(p, i)))), /* @__PURE__ */ ctx.libs.React.createElement("div", null), [1, 2, 3].map((i) => /* @__PURE__ */ ctx.libs.React.createElement("div", { key: i, style: axis }, /* @__PURE__ */ ctx.libs.React.createElement("span", { style: { fontWeight: 600, color: t.colorText, marginRight: 4 } }, ["", "\u4F4E", "\u4E2D", "\u9AD8"][i]), "\u51B2\u51FB")));
  }
  function Detail({ r, refs }) {
    const { status, level } = useUI();
    if (!r) return /* @__PURE__ */ ctx.libs.React.createElement(Empty, { description: "\u70B9\u51FB\u77E9\u9635\u91CC\u7684\u98CE\u9669\u67E5\u770B\u8BE6\u60C5" });
    const ts = (r.theses || []).slice().sort(byCode);
    const js = (r.judgments || []).slice().sort(byCode);
    const ws = (r.watches || []).slice().sort(byCode);
    return /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { display: "flex", flexDirection: "column", gap: 22 } }, /* @__PURE__ */ ctx.libs.React.createElement(DetailHead, { meta: `${r.code}${r.category ? " \xB7 " + r.category : ""}${r.status ? " \xB7 " + r.status : ""}`, title: r.title }), /* @__PURE__ */ ctx.libs.React.createElement(Attrs, { items: [["\u7B49\u7EA7", /* @__PURE__ */ ctx.libs.React.createElement(Status, { label: r.level || "\u672A\u8BC4", color: level[r.level], size: 15, strong: true })], ["\u53EF\u80FD\u6027", r.probability], ["\u51B2\u51FB", r.impact], ["\u65F6\u95F4\u7A97\u53E3", r.horizon]] }), /* @__PURE__ */ ctx.libs.React.createElement(Section, { label: "\u4F30\u503C\u91CC\u600E\u4E48\u5904\u7406", text: r.treatment, refs, tone: "key" }), /* @__PURE__ */ ctx.libs.React.createElement(Section, { label: "\u4F20\u5BFC\u8DEF\u5F84", text: r.mechanism, refs }), /* @__PURE__ */ ctx.libs.React.createElement(Section, { label: "\u5F71\u54CD\u6D4B\u7B97", text: r.impact_estimate, refs }), /* @__PURE__ */ ctx.libs.React.createElement(Section, { label: "\u7F13\u51B2\u56E0\u7D20", text: r.mitigants, refs, tone: "pro" }), /* @__PURE__ */ ctx.libs.React.createElement(Section, { label: "\u9884\u8B66\u4FE1\u53F7", text: r.early_warning, refs, tone: "con" }), /* @__PURE__ */ ctx.libs.React.createElement(Section, { label: "\u89E6\u53D1\u540E\u5E94\u5BF9", text: r.response, refs }), /* @__PURE__ */ ctx.libs.React.createElement(LinkList, { label: "\u4F1A\u524A\u5F31\u7684\u8BBA\u70B9", items: ts.map((x) => ({ code: x.code, title: x.title, tag: x.status || "\u672A\u88C1\u51B3", color: status[x.status] })) }), /* @__PURE__ */ ctx.libs.React.createElement(LinkList, { label: "\u4F30\u503C\u5BF9\u5E94\u7684\u5047\u8BBE\u4F9D\u636E", items: js.map((j) => ({ code: j.code, title: `${j.title}${j.parameter ? "\u3000\u2192 " + j.parameter : ""}` })) }), /* @__PURE__ */ ctx.libs.React.createElement(LinkList, { label: "\u9884\u8B66\u8DDF\u8E2A\u4E8B\u9879", items: ws.map((w) => ({ code: w.code, title: `${w.title}${w.trigger ? "\uFF1A" + w.trigger : ""}` })) }), /* @__PURE__ */ ctx.libs.React.createElement(Facts, { facts: r.facts }));
  }
  boot("\u98CE\u9669\u5206\u6790", async (company, scope) => {
    const [rows, refs] = await Promise.all([listRows("vi_risk", scope, ["theses", "judgments", "watches", "facts"]), loadRefs(scope)]);
    rows.sort(byCode);
    function Page() {
      const { t, fs, level } = useUI();
      const ranked = rows.slice().sort((a, b) => score(b) - score(a) || byCode(a, b));
      const [sel, setSel] = useState(ranked[0]?.code);
      if (!rows.length) return /* @__PURE__ */ ctx.libs.React.createElement(Empty, { description: `${company.name}\u8FD8\u6CA1\u6709\u586B\u5199\u98CE\u9669\uFF08\u5207\u5230\u201C${EDIT_TAB}\u201D\u6807\u7B7E\u65B0\u589E\uFF09` });
      const top = ranked[0];
      const rated = rows.filter((r) => score(r));
      const unrated = rows.filter((r) => !score(r));
      const notIn = rows.filter((r) => r.treatment === "\u672A\u8BA1\u5165\u4F30\u503C");
      const headline = `\u6700\u5927\u7684\u98CE\u9669\uFF1A${top.code} ${short(top.title, 20)}`;
      const todo = notIn.map((r) => `${r.code} ${short(r.title, 24)}\uFF1A\u8FD8\u6CA1\u6709\u8BA1\u5165\u4F30\u503C`).concat(unrated.map((r) => `${r.code} ${short(r.title, 24)}\uFF1A\u8FD8\u6CA1\u8BC4\u53EF\u80FD\u6027\u6216\u51B2\u51FB`));
      const main = (w) => /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { display: "flex", flexDirection: "column", gap: 14 } }, /* @__PURE__ */ ctx.libs.React.createElement(Matrix, { rows: rated, sel, onSelect: setSel, compact: w < 640 }), unrated.length ? /* @__PURE__ */ ctx.libs.React.createElement("div", null, /* @__PURE__ */ ctx.libs.React.createElement(Label, null, "\u8FD8\u6CA1\u8BC4\u53EF\u80FD\u6027\u6216\u51B2\u51FB"), /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { display: "flex", flexWrap: "wrap", gap: 8 } }, unrated.map((r) => /* @__PURE__ */ ctx.libs.React.createElement(Chip, { key: r.code, r, selected: r.code === sel, onSelect: setSel })))) : null, /* @__PURE__ */ ctx.libs.React.createElement("div", { style: fs.meta }, "\u5E95\u8272\u8D8A\u7EA2\uFF0C\u98CE\u9669\u8D8A\u5927\uFF08\u53EF\u80FD\u6027\xD7\u51B2\u51FB\uFF1A6\u20149 \u91CD\u5927\uFF0C3\u20144 \u91CD\u8981\uFF0C1\u20142 \u4E00\u822C\uFF09\uFF1B\u2191\u2193 \u662F\u8D8B\u52BF\u3002"));
      return /* @__PURE__ */ ctx.libs.React.createElement(
        Shell,
        {
          eyebrow: `${company.name} \xB7 \u98CE\u9669\u5206\u6790`,
          headline,
          hint: `${top.level || ""}\u98CE\u9669\uFF0C${top.treatment || "\u4F30\u503C\u5904\u7406\u672A\u586B"}\u3002\u53F3\u4E0A\u89D2\u662F\u53EF\u80FD\u6027\u9AD8\u3001\u51B2\u51FB\u5927\u7684\u98CE\u9669\uFF1B\u70B9\u98CE\u9669\u770B\u4F20\u5BFC\u8DEF\u5F84\u548C\u5BF9\u5E94\u7684\u8BBA\u70B9\u3001\u8DDF\u8E2A\u4E8B\u9879\u3002`,
          stats: /* @__PURE__ */ ctx.libs.React.createElement(Stats, { items: [
            ...["\u91CD\u5927", "\u91CD\u8981", "\u4E00\u822C"].map((l) => ({ label: l, value: rows.filter((r) => r.level === l).length, unit: "\u9879", color: level[l] })),
            { label: "\u672A\u8BA1\u5165\u4F30\u503C", value: notIn.length, unit: "\u9879" }
          ] }),
          notice: /* @__PURE__ */ ctx.libs.React.createElement(Notice, { items: todo }),
          main,
          sel,
          detail: /* @__PURE__ */ ctx.libs.React.createElement(Detail, { r: rows.find((r) => r.code === sel), refs })
        }
      );
    }
    ctx.render(/* @__PURE__ */ ctx.libs.React.createElement(Page, null));
  });
}
export {
  run as default
};
