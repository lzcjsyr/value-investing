async function run(ctx) {
  const COMPANY = "01810.HK";
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
  const factor = (v) => v === null || v === void 0 || v === "" ? "\u2014" : `\xD7${Number(v).toFixed(2)}${Number(v) === 1 ? "" : `\uFF08${Number(v) > 1 ? "+" : "\u2212"}${Math.round(Math.abs(Number(v) - 1) * 100)}%\uFF09`}`;
  function useScenColor() {
    const { t } = useUI();
    return (name, i) => ({ \u57FA\u51C6: t.colorPrimary, \u60B2\u89C2: "#eb6834", \u4E50\u89C2: "#1baf7a" })[name] || ["#6250d6", "#eda100", "#e87ba4"][i % 3];
  }
  function IrrBars({ rows, hurdle, onSelect, sel }) {
    const { t, fs } = useUI();
    const color = useScenColor();
    const max = Math.max(hurdle || 0, ...rows.map((r) => r.irr || 0)) * 1.18 || 0.1;
    const x = (v) => `${Math.max(0, v / max * 100)}%`;
    return /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { position: "relative", paddingTop: 26 } }, hurdle ? /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { position: "absolute", top: 0, bottom: 0, left: `calc(96px + (100% - 96px - 64px) * ${hurdle / max})`, borderLeft: `2px dashed ${t.colorTextSecondary}`, zIndex: 1 } }, /* @__PURE__ */ ctx.libs.React.createElement("span", { style: { position: "absolute", top: 0, left: 6, fontSize: 12, color: t.colorText, fontWeight: 600, whiteSpace: "nowrap" } }, "\u95E8\u69DB ", pct(hurdle))) : null, rows.map((r, i) => /* @__PURE__ */ ctx.libs.React.createElement("div", { key: r.name, onClick: () => onSelect(r.name), style: { display: "grid", gridTemplateColumns: "96px 1fr 64px", alignItems: "center", gap: 0, padding: "8px 0", cursor: "pointer" } }, /* @__PURE__ */ ctx.libs.React.createElement("span", { style: { ...fs.title, fontSize: 14, color: sel === r.name ? t.colorPrimary : t.colorText } }, r.name, r.is_base ? /* @__PURE__ */ ctx.libs.React.createElement("span", { style: { ...fs.code, marginLeft: 6 } }, "\u57FA\u51C6") : null), /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { position: "relative", height: 14, background: t.colorFillQuaternary, borderRadius: 7 } }, /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { position: "absolute", left: 0, top: 0, bottom: 0, width: x(r.irr || 0), background: color(r.name, i), borderRadius: 7 } })), /* @__PURE__ */ ctx.libs.React.createElement("span", { style: { fontSize: 15, fontWeight: 600, color: t.colorText, textAlign: "right", fontVariantNumeric: "tabular-nums" } }, pct(r.irr, 2)))));
  }
  function Lines({ series, years, fmt, width }) {
    const { t } = useUI();
    const [hover, setHover] = useState(null);
    const W = Math.max(320, width || 600), H = 220, L = 44, R = 16, T = 12, B = 28;
    const ys = series.flatMap((s) => s.values.filter((v) => v !== null && v !== void 0));
    if (!ys.length || !years.length) return null;
    let lo = Math.min(...ys), hi = Math.max(...ys);
    const pad = (hi - lo) * 0.15 || hi * 0.1 || 1;
    lo -= pad;
    hi += pad;
    const X = (i) => L + (years.length === 1 ? 0 : i / (years.length - 1) * (W - L - R));
    const Y = (v) => T + (1 - (v - lo) / (hi - lo)) * (H - T - B);
    const ticks = [0, 1, 2, 3].map((k) => lo + (hi - lo) * k / 3);
    const onMove = (e) => {
      const box = e.currentTarget.getBoundingClientRect();
      const px = (e.clientX - box.left) / box.width * W;
      let best = 0;
      years.forEach((_, i) => {
        if (Math.abs(X(i) - px) < Math.abs(X(best) - px)) best = i;
      });
      setHover(best);
    };
    return /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { position: "relative" } }, /* @__PURE__ */ ctx.libs.React.createElement("svg", { viewBox: `0 0 ${W} ${H}`, width: "100%", style: { display: "block", overflow: "visible" }, onMouseMove: onMove, onMouseLeave: () => setHover(null) }, ticks.map((v, k) => /* @__PURE__ */ ctx.libs.React.createElement("g", { key: k }, /* @__PURE__ */ ctx.libs.React.createElement("line", { x1: L, x2: W - R, y1: Y(v), y2: Y(v), stroke: t.colorSplit, strokeWidth: "1" }), /* @__PURE__ */ ctx.libs.React.createElement("text", { x: L - 8, y: Y(v) + 4, textAnchor: "end", fontSize: "11", fill: t.colorTextTertiary }, fmt(v)))), years.map((y, i) => i % Math.ceil(years.length / 8) === 0 || i === years.length - 1 ? /* @__PURE__ */ ctx.libs.React.createElement("text", { key: y, x: X(i), y: H - 8, textAnchor: "middle", fontSize: "11", fill: t.colorTextTertiary }, y) : null), hover !== null ? /* @__PURE__ */ ctx.libs.React.createElement("line", { x1: X(hover), x2: X(hover), y1: T, y2: H - B, stroke: t.colorTextQuaternary, strokeDasharray: "3 3" }) : null, series.map((s) => /* @__PURE__ */ ctx.libs.React.createElement("g", { key: s.name }, /* @__PURE__ */ ctx.libs.React.createElement(
      "polyline",
      {
        fill: "none",
        stroke: s.color,
        strokeWidth: "2",
        strokeLinejoin: "round",
        strokeLinecap: "round",
        points: s.values.map((v, i) => v === null || v === void 0 ? null : `${X(i)},${Y(v)}`).filter(Boolean).join(" ")
      }
    ), hover !== null && s.values[hover] !== null && s.values[hover] !== void 0 ? /* @__PURE__ */ ctx.libs.React.createElement("circle", { cx: X(hover), cy: Y(s.values[hover]), r: "4.5", fill: s.color, stroke: t.colorBgContainer, strokeWidth: "2" }) : null))), hover !== null ? /* @__PURE__ */ ctx.libs.React.createElement("div", { style: {
      position: "absolute",
      top: 4,
      left: `${Math.min(70, X(hover) / W * 100)}%`,
      transform: "translateX(12px)",
      background: t.colorBgElevated,
      boxShadow: t.boxShadowSecondary,
      borderRadius: 8,
      padding: "8px 12px",
      fontSize: 13,
      pointerEvents: "none",
      minWidth: 120
    } }, /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { fontWeight: 600, marginBottom: 4, color: t.colorText } }, years[hover]), series.map((s) => /* @__PURE__ */ ctx.libs.React.createElement("div", { key: s.name, style: { display: "flex", alignItems: "center", gap: 6, color: t.colorText } }, /* @__PURE__ */ ctx.libs.React.createElement(Dot, { color: s.color }), /* @__PURE__ */ ctx.libs.React.createElement("span", { style: { flex: 1 } }, s.name), /* @__PURE__ */ ctx.libs.React.createElement("span", { style: { fontVariantNumeric: "tabular-nums" } }, fmt(s.values[hover]))))) : null, /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { display: "flex", gap: 16, marginTop: 6 } }, series.map((s) => /* @__PURE__ */ ctx.libs.React.createElement(Status, { key: s.name, label: s.name, color: s.color }))));
  }
  function ScenCard({ s, v, last, selected, onSelect, color }) {
    const { t, fs } = useUI();
    const row = (k, val) => /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { display: "flex", justifyContent: "space-between", gap: 12, fontSize: 13.5, lineHeight: 1.9 } }, /* @__PURE__ */ ctx.libs.React.createElement("span", { style: { color: t.colorTextSecondary } }, k), /* @__PURE__ */ ctx.libs.React.createElement("span", { style: { color: t.colorText, fontVariantNumeric: "tabular-nums" } }, val));
    return /* @__PURE__ */ ctx.libs.React.createElement(Card, { selected, onClick: () => onSelect(s.name), accent: color, style: { padding: "14px 18px", display: "flex", flexDirection: "column", gap: 8 } }, /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { display: "flex", alignItems: "baseline", gap: 8 } }, /* @__PURE__ */ ctx.libs.React.createElement("span", { style: { fontSize: 17, fontWeight: 600, color: t.colorTextHeading } }, s.name), s.is_base ? /* @__PURE__ */ ctx.libs.React.createElement(Tag, null, "\u57FA\u51C6") : null, /* @__PURE__ */ ctx.libs.React.createElement("span", { style: { flex: 1 } }), /* @__PURE__ */ ctx.libs.React.createElement("span", { style: { fontSize: 13, color: t.colorTextSecondary } }, "\u9690\u542B\u56DE\u62A5 ", /* @__PURE__ */ ctx.libs.React.createElement("b", { style: { color: t.colorText, fontSize: 15 } }, pct(v?.implied_irr, 2)))), usable(s.description) ? /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { ...fs.meta, ...clamp(2) } }, s.description) : null, /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { borderTop: `1px solid ${t.colorSplit}`, paddingTop: 6 } }, row("\u4E1A\u52A1\u91CF\u7CFB\u6570", factor(s.volume_factor)), row("\u5355\u4EF7\u7CFB\u6570", factor(s.price_factor)), row("\u4ED8\u73B0\u6210\u672C\u7CFB\u6570", factor(s.cost_factor)), row("\u6C38\u7EED\u589E\u957F\u7387", pct(s.terminal_growth)), s.probability !== null && s.probability !== void 0 ? row("\u60C5\u666F\u6982\u7387", pct(s.probability, 0)) : null, last ? row(`${last.year}E \u6BCF\u80A1\u80A1\u4E1C\u56DE\u62A5`, `${num(last.dps, 3)} \u5143`) : null, v ? row("\u95E8\u69DB\u4E0B\u6700\u9AD8\u4E70\u5165\u4EF7", `${num(v.value_at_required)} \u5143`) : null));
  }
  function Detail({ s, v, refs }) {
    if (!s) return /* @__PURE__ */ ctx.libs.React.createElement(Empty, { description: "\u70B9\u51FB\u60C5\u666F\u67E5\u770B\u8BF4\u660E" });
    return /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { display: "flex", flexDirection: "column", gap: 22 } }, /* @__PURE__ */ ctx.libs.React.createElement(DetailHead, { meta: `\u60C5\u666F${s.is_base ? " \xB7 \u57FA\u51C6" : ""}${usable(s.nature) ? " \xB7 " + s.nature : ""}`, title: s.name }), /* @__PURE__ */ ctx.libs.React.createElement(Attrs, { items: [["\u9690\u542B\u56DE\u62A5", pct(v?.implied_irr, 2)], ["\u73B0\u91D1\u652F\u6301\u53E3\u5F84", pct(v?.cash_implied_irr, 2)], ["\u95E8\u69DB", pct(v?.required_return)], ["\u7EC8\u503C\u5360\u6BD4", pct(v?.terminal_share, 0)]] }), /* @__PURE__ */ ctx.libs.React.createElement(Section, { label: "\u7ED3\u8BBA", text: v?.conclusion, refs, tone: "key" }), /* @__PURE__ */ ctx.libs.React.createElement(Section, { label: "\u60C5\u666F\u8BF4\u660E", text: s.description, refs }), /* @__PURE__ */ ctx.libs.React.createElement(Section, { label: "\u5047\u8BBE\u6027\u8D28", text: s.nature, refs }));
  }
  boot("\u60C5\u666F", async (company, scope) => {
    const models = await listRows("vi_model", scope);
    const model = models.find((m) => m.status === "\u5F53\u524D") || models[0];
    if (!model) {
      ctx.render(/* @__PURE__ */ ctx.libs.React.createElement(Empty, { description: `${company.name}\u8FD8\u6CA1\u6709\u4F30\u503C\u6A21\u578B` }));
      return;
    }
    const [scens, vals, proj, refs] = await Promise.all([
      listRows("vi_scenario", { model_id: { $eq: model.id } }),
      listRows("vi_valuation", { model_id: { $eq: model.id } }),
      listRows("vi_projection", { model_id: { $eq: model.id } }, null, 2e3),
      loadRefs(scope)
    ]);
    scens.sort((a, b) => (a.sort ?? 0) - (b.sort ?? 0));
    const val = (n) => vals.find((v) => v.scenario_name === n);
    const years = [...new Set(proj.map((r) => r.year))].sort((a, b) => a - b);
    function Page() {
      const { t } = useUI();
      const color = useScenColor();
      const base = scens.find((s) => s.is_base) || scens[0];
      const [sel, setSel] = useState(base?.name);
      if (!scens.length) return /* @__PURE__ */ ctx.libs.React.createElement(Empty, { description: `${company.name}\u8FD8\u6CA1\u6709\u60C5\u666F\uFF08\u5207\u5230\u201C${EDIT_TAB}\u201D\u6807\u7B7E\u65B0\u589E\uFF09` });
      const hurdle = vals[0]?.required_return ?? model.required_return;
      const rows = scens.map((s) => ({ name: s.name, is_base: s.is_base, irr: val(s.name)?.implied_irr }));
      const above = rows.filter((r) => r.irr !== void 0 && r.irr !== null && r.irr >= hurdle);
      const headline = !hurdle ? `${scens.length} \u4E2A\u60C5\u666F` : above.length === rows.length ? `${rows.length} \u4E2A\u60C5\u666F\u7684\u9690\u542B\u56DE\u62A5\u90FD\u9AD8\u4E8E\u95E8\u69DB ${pct(hurdle)}` : above.length ? `${above.map((r) => r.name).join("\u3001")}\u9AD8\u4E8E\u95E8\u69DB ${pct(hurdle)}\uFF0C\u5176\u4F59\u4F4E\u4E8E` : `${rows.length} \u4E2A\u60C5\u666F\u7684\u9690\u542B\u56DE\u62A5\u90FD\u4F4E\u4E8E\u95E8\u69DB ${pct(hurdle)}`;
      const lastOf = (n) => proj.filter((r) => r.scenario_name === n).sort((a, b) => b.year - a.year)[0];
      const series = scens.map((s, i) => ({ name: s.name, color: color(s.name, i), values: years.map((y) => proj.find((r) => r.scenario_name === s.name && r.year === y)?.dps ?? null) }));
      const main = (w) => /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { display: "flex", flexDirection: "column", gap: 28 } }, /* @__PURE__ */ ctx.libs.React.createElement("div", null, /* @__PURE__ */ ctx.libs.React.createElement(Label, null, "\u9690\u542B\u5E74\u5316\u56DE\u62A5 vs \u95E8\u69DB\uFF08\u6309\u5E02\u4EF7 ", num(vals[0]?.market_price), " \u5143\u4E70\u5165\uFF09"), /* @__PURE__ */ ctx.libs.React.createElement(IrrBars, { rows, hurdle, onSelect: setSel, sel })), years.length ? /* @__PURE__ */ ctx.libs.React.createElement("div", null, /* @__PURE__ */ ctx.libs.React.createElement(Label, null, "\u6BCF\u80A1\u80A1\u4E1C\u56DE\u62A5\u8DEF\u5F84\uFF08\u5143\u4EBA\u6C11\u5E01\uFF09"), /* @__PURE__ */ ctx.libs.React.createElement(Lines, { series, years, fmt: (v) => v === null || v === void 0 ? "\u2014" : Number(v).toFixed(2), width: w })) : null, /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { display: "grid", gridTemplateColumns: `repeat(${w >= 720 ? Math.min(scens.length, 3) : 1}, minmax(0,1fr))`, gap: 14 } }, scens.map((s, i) => /* @__PURE__ */ ctx.libs.React.createElement(ScenCard, { key: s.id, s, v: val(s.name), last: lastOf(s.name), selected: s.name === sel, onSelect: setSel, color: color(s.name, i) }))));
      const cur = scens.find((s) => s.name === sel);
      return /* @__PURE__ */ ctx.libs.React.createElement(
        Shell,
        {
          eyebrow: `${company.name} \xB7 \u60C5\u666F \xB7 \u80A1\u4E1C\u56DE\u62A5\u6298\u73B0\u4EA4\u53C9\u9A8C\u8BC1`,
          headline,
          hint: `\u6A21\u578B\uFF1A${model.name}\u3002\u6B64\u5904\u4E3A\u96C6\u56E2\u80A1\u4E1C\u56DE\u62A5\u6298\u73B0\u7684\u4EA4\u53C9\u9A8C\u8BC1\uFF1B\u4E3B\u4F30\u503C\u5728\u201C\u4F30\u503C\u201D\u9875\u6309\u5206\u90E8\u52A0\u603B\u3002\u70B9\u60C5\u666F\u770B\u8BF4\u660E\u4E0E\u7ED3\u8BBA\u3002`,
          stats: /* @__PURE__ */ ctx.libs.React.createElement(Stats, { items: rows.map((r, i) => ({ label: `${r.name}\xB7\u9690\u542B\u56DE\u62A5`, value: pct(r.irr, 2), color: color(r.name, i) })).concat(hurdle ? [{ label: "\u95E8\u69DB", value: pct(hurdle) }] : []) }),
          main,
          sel,
          detail: /* @__PURE__ */ ctx.libs.React.createElement(Detail, { s: cur, v: cur ? val(cur.name) : null, refs })
        }
      );
    }
    ctx.render(/* @__PURE__ */ ctx.libs.React.createElement(Page, null));
  });
}
export {
  run as default
};
