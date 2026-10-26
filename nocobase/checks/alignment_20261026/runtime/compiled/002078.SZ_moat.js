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
  const COLS = [
    ["\u771F\u5B9E\u58C1\u5792", "\u80FD\u6301\u7EED\u5E26\u6765\u8D85\u989D\u56DE\u62A5"],
    ["\u5C40\u90E8\u4F18\u52BF", "\u6709\u4F18\u52BF\uFF0C\u4F46\u8303\u56F4\u6709\u9650\u6216\u53EF\u88AB\u8FFD\u8D76"],
    ["\u5F85\u9A8C\u8BC1", "\u8BC1\u636E\u8FD8\u4E0D\u591F"],
    ["\u4F2A\u58C1\u5792", "\u770B\u8D77\u6765\u50CF\u58C1\u5792\uFF0C\u5176\u5B9E\u4E0D\u662F"]
  ];
  const STRENGTH = { \u5F3A: 3, \u4E2D: 2, \u5F31: 1, \u65E0: 0 };
  const unproven = (m) => m.verdict !== "\u4F2A\u58C1\u5792" && !(m.theses || []).some((x) => x.category === "\u58C1\u5792");
  function Bars({ v }) {
    const { t } = useUI();
    const n = STRENGTH[v] ?? 0;
    return /* @__PURE__ */ ctx.libs.React.createElement(Tooltip, { title: `\u5F3A\u5EA6\uFF1A${v || "\u672A\u6807\u6CE8"}` }, /* @__PURE__ */ ctx.libs.React.createElement("span", { style: { display: "inline-flex", gap: 2, alignItems: "center" } }, [1, 2, 3].map((i) => /* @__PURE__ */ ctx.libs.React.createElement("span", { key: i, style: { width: 12, height: 6, borderRadius: 2, background: i <= n ? t.colorText : t.colorFillSecondary } }))));
  }
  function Trend({ v }) {
    const { t } = useUI();
    const m = { \u589E\u5F3A: ["\u2191", t.colorSuccess], \u524A\u5F31: ["\u2193", t.colorError], \u7A33\u5B9A: ["\u2192", t.colorTextTertiary] }[v];
    return m ? /* @__PURE__ */ ctx.libs.React.createElement("span", { style: { fontSize: 13, color: t.colorTextSecondary } }, /* @__PURE__ */ ctx.libs.React.createElement("span", { style: { color: m[1], fontWeight: 700 } }, m[0]), " ", v) : null;
  }
  function MoatCard({ m, selected, onSelect }) {
    const { t, fs, status } = useUI();
    const ts = (m.theses || []).slice().sort(byCode);
    const fake = m.verdict === "\u4F2A\u58C1\u5792";
    return /* @__PURE__ */ ctx.libs.React.createElement(Card, { selected, onClick: () => onSelect(m.code), muted: fake, style: { padding: "14px 16px", display: "flex", flexDirection: "column", gap: 10 } }, /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { display: "flex", alignItems: "center", gap: 8 } }, /* @__PURE__ */ ctx.libs.React.createElement("span", { style: fs.code }, m.code), /* @__PURE__ */ ctx.libs.React.createElement("span", { style: { ...fs.meta, flex: 1 } }, m.moat_type), fake ? null : /* @__PURE__ */ ctx.libs.React.createElement(Bars, { v: m.strength })), /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { ...fs.title, color: fake ? t.colorTextSecondary : t.colorText, ...clamp(3) } }, short(m.title, 40)), fake ? null : /* @__PURE__ */ ctx.libs.React.createElement(Trend, { v: m.trend }), /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { display: "flex", flexDirection: "column", gap: 4, paddingTop: 8, borderTop: `1px solid ${t.colorSplit}` } }, ts.length ? ts.map((x) => /* @__PURE__ */ ctx.libs.React.createElement("div", { key: x.id, style: { display: "flex", gap: 8, alignItems: "center", fontSize: 13 } }, /* @__PURE__ */ ctx.libs.React.createElement(Dot, { color: status[x.status], size: 7 }), /* @__PURE__ */ ctx.libs.React.createElement("span", { style: { color: t.colorText, fontWeight: 500, flex: "none" } }, x.code, " ", x.status || "\u672A\u88C1\u51B3"), /* @__PURE__ */ ctx.libs.React.createElement("span", { style: { color: t.colorTextSecondary, flex: 1, minWidth: 0, ...clamp(1) } }, short(x.title, 30)))) : /* @__PURE__ */ ctx.libs.React.createElement("span", { style: { ...fs.meta, color: t.colorTextTertiary } }, "\u6CA1\u6709\u5173\u8054\u8BBA\u70B9")), unproven(m) || m.check_result === "\u5DF2\u89E6\u53D1" ? /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { display: "flex", gap: 6, flexWrap: "wrap" } }, unproven(m) ? /* @__PURE__ */ ctx.libs.React.createElement(Flag, null, "\u672A\u4E13\u95E8\u8BBA\u8BC1") : null, m.check_result === "\u5DF2\u89E6\u53D1" ? /* @__PURE__ */ ctx.libs.React.createElement(Flag, null, "\u81EA\u52A8\u68C0\u67E5\u5DF2\u89E6\u53D1") : null) : null);
  }
  function Detail({ m, refs }) {
    const { status, verdict } = useUI();
    if (!m) return /* @__PURE__ */ ctx.libs.React.createElement(Empty, { description: "\u70B9\u51FB\u4EFB\u4E00\u58C1\u5792\u67E5\u770B\u5206\u6790" });
    const ts = (m.theses || []).slice().sort(byCode);
    const check = m.check_metric ? `${m.check_metric} ${m.check_op || ""} ${m.check_threshold ?? ""}\uFF0C\u8FDE\u7EED ${m.check_years || "?"} \u5E74 \u2192 ${m.check_result || ""}` : "";
    return /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { display: "flex", flexDirection: "column", gap: 22 } }, /* @__PURE__ */ ctx.libs.React.createElement(DetailHead, { meta: `${m.code}${m.moat_type ? " \xB7 " + m.moat_type : ""}`, title: m.title }), /* @__PURE__ */ ctx.libs.React.createElement(Attrs, { items: [
      ["\u5224\u5B9A", /* @__PURE__ */ ctx.libs.React.createElement(Status, { label: m.verdict || "\u672A\u5224\u5B9A", color: verdict[m.verdict], size: 15, strong: true })],
      ["\u5F3A\u5EA6", m.strength],
      ["\u8D8B\u52BF", m.trend],
      ["\u81EA\u52A8\u68C0\u67E5", m.check_result || "\u672A\u8BBE\u7F6E"]
    ] }), /* @__PURE__ */ ctx.libs.React.createElement(LinkList, { label: "\u8BBA\u8BC1\u5B83\u7684\u8BBA\u70B9", items: ts.map((x) => ({ code: x.code, title: `${x.title}\uFF08${x.category || ""}\uFF09`, tag: x.status || "\u672A\u88C1\u51B3", color: status[x.status] })) }), unproven(m) ? /* @__PURE__ */ ctx.libs.React.createElement(Notice, { items: ["\u5173\u8054\u7684\u8BBA\u70B9\u90FD\u4E0D\u662F\u58C1\u5792\u7C7B\uFF1A\u8FD9\u9879\u58C1\u5792\u80FD\u5426\u6301\u7EED\uFF0C\u8FD8\u6CA1\u6709\u4E13\u95E8\u6B63\u53CD\u8FA9\u8BBA\u8FC7\u3002"] }) : null, /* @__PURE__ */ ctx.libs.React.createElement(Section, { label: "\u673A\u5236", text: m.mechanism, refs }), /* @__PURE__ */ ctx.libs.React.createElement(Section, { label: "\u8D22\u52A1\u4F53\u73B0", text: m.financial_link, refs, tone: "key" }), /* @__PURE__ */ ctx.libs.React.createElement(Section, { label: "\u8BC1\u636E", text: m.evidence, refs, tone: "pro" }), /* @__PURE__ */ ctx.libs.React.createElement(Section, { label: "\u53CD\u8BC1", text: m.counter, refs, tone: "con" }), /* @__PURE__ */ ctx.libs.React.createElement(Section, { label: "\u590D\u5236\u96BE\u5EA6", text: m.replication, refs }), /* @__PURE__ */ ctx.libs.React.createElement(Section, { label: "\u524A\u5F31\u56E0\u7D20", text: m.threats, refs, tone: "con" }), /* @__PURE__ */ ctx.libs.React.createElement(Section, { label: "\u81EA\u52A8\u68C0\u67E5\u6761\u4EF6", text: check, refs }), /* @__PURE__ */ ctx.libs.React.createElement(Facts, { facts: m.facts }));
  }
  boot("\u7ADE\u4E89\u58C1\u5792", async (company, scope) => {
    const [rows, refs] = await Promise.all([listRows("vi_moat", scope, ["theses", "facts"]), loadRefs(scope)]);
    rows.sort(byCode);
    function Page() {
      const { t, fs, verdict } = useUI();
      const real = rows.filter((m) => m.verdict === "\u771F\u5B9E\u58C1\u5792");
      const [sel, setSel] = useState(real[0]?.code || rows[0]?.code);
      if (!rows.length) return /* @__PURE__ */ ctx.libs.React.createElement(Empty, { description: `${company.name}\u8FD8\u6CA1\u6709\u586B\u5199\u7ADE\u4E89\u58C1\u5792\uFF08\u5207\u5230\u201C${EDIT_TAB}\u201D\u6807\u7B7E\u65B0\u589E\uFF09` });
      const groups = COLS.map(([v, hint]) => [v, hint, rows.filter((m) => m.verdict === v)]);
      const other = rows.filter((m) => !COLS.some(([v]) => v === m.verdict));
      if (other.length) groups.push(["\u672A\u5224\u5B9A", "\u8FD8\u6CA1\u6709\u5224\u5B9A", other]);
      const todo = rows.filter(unproven).map((m) => `${m.code} ${short(m.title)}\uFF1A\u5173\u8054\u7684 ${(m.theses || []).map((x) => x.code).join("\u3001") || "\u2014"} \u4E0D\u662F\u58C1\u5792\u7C7B\u8BBA\u70B9\uFF0C\u80FD\u5426\u6301\u7EED\u8FD8\u6CA1\u4E13\u95E8\u8FA9\u8BBA`).concat(rows.filter((m) => m.check_result === "\u5DF2\u89E6\u53D1").map((m) => `${m.code} ${short(m.title)}\uFF1A\u81EA\u52A8\u68C0\u67E5\u5DF2\u89E6\u53D1\uFF0C\u9700\u8981\u590D\u6838\u5224\u5B9A`));
      const headline = real.length ? `\u62A4\u57CE\u6CB3\u6765\u81EA ${real.map((m) => short(m.title, 20)).join("\u3001")}` : "\u8FD8\u6CA1\u6709\u786E\u8BA4\u7684\u771F\u5B9E\u58C1\u5792";
      const board = (w) => {
        const n = w >= 1080 ? groups.length : w >= 600 ? 2 : 1;
        return /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { display: "grid", gridTemplateColumns: `repeat(${n}, minmax(0,1fr))`, gap: 20, alignItems: "start" } }, groups.map(([v, hint, xs]) => /* @__PURE__ */ ctx.libs.React.createElement("div", { key: v, style: { display: "flex", flexDirection: "column", gap: 12, minWidth: 0 } }, /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { paddingBottom: 10, borderBottom: `2px solid ${verdict[v] || t.colorBorder}` } }, /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { display: "flex", alignItems: "baseline", gap: 8 } }, /* @__PURE__ */ ctx.libs.React.createElement("span", { style: { fontSize: 16, fontWeight: 600, color: t.colorTextHeading } }, v), /* @__PURE__ */ ctx.libs.React.createElement("span", { style: { fontSize: 14, color: t.colorTextSecondary } }, xs.length)), /* @__PURE__ */ ctx.libs.React.createElement("div", { style: fs.meta }, hint)), xs.length ? xs.map((m) => /* @__PURE__ */ ctx.libs.React.createElement(MoatCard, { key: m.code, m, selected: m.code === sel, onSelect: setSel })) : /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { ...fs.meta, color: t.colorTextQuaternary } }, "\u65E0"))));
      };
      return /* @__PURE__ */ ctx.libs.React.createElement(
        Shell,
        {
          eyebrow: `${company.name} \xB7 \u7ADE\u4E89\u58C1\u5792`,
          headline,
          hint: "\u6309\u5224\u5B9A\u5206\u56DB\u680F\uFF1B\u5361\u7247\u4E0B\u65B9\u662F\u8BBA\u8BC1\u5B83\u80FD\u5426\u6301\u7EED\u7684\u8BBA\u70B9\u53CA\u88C1\u51B3\u3002\u70B9\u5361\u7247\u770B\u5168\u6587\u3002",
          stats: /* @__PURE__ */ ctx.libs.React.createElement(Stats, { items: groups.map(([v, , xs]) => ({ label: v, value: xs.length, unit: "\u9879", color: verdict[v] })) }),
          notice: /* @__PURE__ */ ctx.libs.React.createElement(Notice, { items: todo }),
          main: board,
          sel,
          minSide: 1800,
          detail: /* @__PURE__ */ ctx.libs.React.createElement(Detail, { m: rows.find((m) => m.code === sel), refs })
        }
      );
    }
    ctx.render(/* @__PURE__ */ ctx.libs.React.createElement(Page, null));
  });
}
export {
  run as default
};
