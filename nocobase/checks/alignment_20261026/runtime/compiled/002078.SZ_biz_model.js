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
  const AREA = { \u91CD\u8981\u5408\u4F5C: "kp", \u5173\u952E\u4E1A\u52A1: "ka", \u6838\u5FC3\u8D44\u6E90: "kr", \u4EF7\u503C\u4E3B\u5F20: "vp", \u5BA2\u6237\u5173\u7CFB: "cr", \u6E20\u9053\u901A\u8DEF: "ch", \u5BA2\u6237\u7EC6\u5206: "cs", \u6210\u672C\u7ED3\u6784: "cost", \u6536\u5165\u6765\u6E90: "rev" };
  function Cell({ r, element, selected, onSelect, tall, core }) {
    const { t, fs } = useUI();
    if (!r) {
      return /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { gridArea: AREA[element], border: `1px dashed ${t.colorBorder}`, borderRadius: 12, padding: 16 } }, /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { ...fs.meta, fontWeight: 600 } }, element), /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { ...fs.meta, color: t.colorTextQuaternary, marginTop: 6 } }, "\u672A\u586B\u5199"));
    }
    return /* @__PURE__ */ ctx.libs.React.createElement(
      Card,
      {
        selected,
        onClick: () => onSelect(r.code),
        style: {
          gridArea: AREA[element],
          padding: "14px 16px 16px",
          display: "flex",
          flexDirection: "column",
          gap: 10,
          background: core && !selected ? t.colorPrimaryBg : void 0
        }
      },
      /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { display: "flex", justifyContent: "space-between", alignItems: "baseline" } }, /* @__PURE__ */ ctx.libs.React.createElement("span", { style: { fontSize: 13, fontWeight: 600, color: core ? t.colorPrimary : t.colorTextSecondary } }, element), /* @__PURE__ */ ctx.libs.React.createElement("span", { style: fs.code }, r.code)),
      /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { ...fs.title, fontSize: core ? 17 : 15, ...clamp(tall ? 4 : 3) } }, r.title),
      usable(r.metric) ? /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { borderLeft: `3px solid ${t.colorPrimary}`, paddingLeft: 10 } }, /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { fontSize: 13.5, lineHeight: 1.65, color: t.colorText, fontWeight: 500, ...clamp(tall ? 5 : 3) } }, r.metric)) : null,
      usable(r.trend) ? /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { ...fs.meta, ...clamp(tall ? 5 : 3) } }, r.trend) : null
    );
  }
  function Detail({ r, refs }) {
    if (!r) return /* @__PURE__ */ ctx.libs.React.createElement(Empty, { description: "\u70B9\u51FB\u753B\u5E03\u4E2D\u7684\u683C\u5B50\u67E5\u770B\u8BE6\u60C5" });
    return /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { display: "flex", flexDirection: "column", gap: 22 } }, /* @__PURE__ */ ctx.libs.React.createElement(DetailHead, { meta: `${r.code} \xB7 ${r.element}`, title: r.title }), /* @__PURE__ */ ctx.libs.React.createElement(Section, { label: "\u5173\u952E\u6570\u5B57", text: r.metric, refs, tone: "key" }), /* @__PURE__ */ ctx.libs.React.createElement(Section, { label: "\u8BF4\u660E", text: r.content, refs }), /* @__PURE__ */ ctx.libs.React.createElement(Section, { label: "\u53D8\u5316\u4E0E\u98CE\u9669", text: r.trend, refs, tone: "con" }), /* @__PURE__ */ ctx.libs.React.createElement(Facts, { facts: r.facts }));
  }
  boot("\u5546\u4E1A\u6A21\u5F0F", async (company, scope) => {
    const [rows, refs] = await Promise.all([listRows("vi_biz_model", scope, ["facts"]), loadRefs(scope)]);
    rows.sort(byCode);
    const of = (el) => rows.find((r) => r.element === el);
    function Page() {
      const { t, fs } = useUI();
      const [sel, setSel] = useState(of("\u4EF7\u503C\u4E3B\u5F20")?.code || rows[0]?.code);
      if (!rows.length) return /* @__PURE__ */ ctx.libs.React.createElement(Empty, { description: `${company.name}\u8FD8\u6CA1\u6709\u586B\u5199\u5546\u4E1A\u6A21\u5F0F\uFF08\u5207\u5230\u201C${EDIT_TAB}\u201D\u6807\u7B7E\u65B0\u589E\uFF09` });
      const p = (el, tall) => /* @__PURE__ */ ctx.libs.React.createElement(Cell, { key: el, r: of(el), element: el, selected: of(el)?.code === sel, onSelect: setSel, tall, core: el === "\u4EF7\u503C\u4E3B\u5F20" });
      const canvas = (w) => w >= 760 ? /* @__PURE__ */ ctx.libs.React.createElement("div", { style: {
        display: "grid",
        gap: 12,
        gridTemplateColumns: "repeat(10, minmax(0,1fr))",
        gridTemplateAreas: '"c1 c1 c1 c1 c2 c2 c3 c3 c3 c3" "kp kp ka ka vp vp cr cr cs cs" "kp kp kr kr vp vp ch ch cs cs" "cost cost cost cost cost rev rev rev rev rev"'
      } }, /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { gridArea: "c1", fontSize: 12, color: t.colorTextTertiary, letterSpacing: 1 } }, "\u600E\u4E48\u505A \xB7 \u9760\u8C01\u3001\u505A\u4EC0\u4E48\u3001\u9760\u4EC0\u4E48"), /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { gridArea: "c2", fontSize: 12, color: t.colorTextTertiary, letterSpacing: 1, textAlign: "center" } }, "\u63D0\u4F9B\u4EC0\u4E48"), /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { gridArea: "c3", fontSize: 12, color: t.colorTextTertiary, letterSpacing: 1, textAlign: "right" } }, "\u4E3A\u8C01\u505A \xB7 \u600E\u4E48\u7EF4\u7CFB\u3001\u600E\u4E48\u9001\u8FBE\u3001\u5356\u7ED9\u8C01"), p("\u91CD\u8981\u5408\u4F5C", true), p("\u5173\u952E\u4E1A\u52A1"), p("\u6838\u5FC3\u8D44\u6E90"), p("\u4EF7\u503C\u4E3B\u5F20", true), p("\u5BA2\u6237\u5173\u7CFB"), p("\u6E20\u9053\u901A\u8DEF"), p("\u5BA2\u6237\u7EC6\u5206", true), p("\u6210\u672C\u7ED3\u6784"), p("\u6536\u5165\u6765\u6E90")) : /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { display: "flex", flexDirection: "column", gap: 12 } }, rows.map((r) => /* @__PURE__ */ ctx.libs.React.createElement(Cell, { key: r.code, r, element: r.element, selected: r.code === sel, onSelect: setSel, core: r.element === "\u4EF7\u503C\u4E3B\u5F20" })));
      const vp = of("\u4EF7\u503C\u4E3B\u5F20"), cs = of("\u5BA2\u6237\u7EC6\u5206"), rev = of("\u6536\u5165\u6765\u6E90"), cost = of("\u6210\u672C\u7ED3\u6784");
      const line = (k, r) => r ? /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { display: "flex", gap: 10 } }, /* @__PURE__ */ ctx.libs.React.createElement("span", { style: { color: t.colorTextSecondary, flex: "none", width: 32 } }, k), /* @__PURE__ */ ctx.libs.React.createElement("span", { style: { color: t.colorText } }, r.title)) : null;
      const brief = /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { display: "flex", flexDirection: "column", gap: 4, fontSize: 14, lineHeight: 1.7 } }, line("\u5BA2\u6237", cs), line("\u6536\u5165", rev), line("\u6210\u672C", cost));
      return /* @__PURE__ */ ctx.libs.React.createElement(
        Shell,
        {
          eyebrow: `${company.name} \xB7 \u5546\u4E1A\u6A21\u5F0F\u753B\u5E03`,
          headline: vp ? vp.title : "\u5546\u4E1A\u6A21\u5F0F",
          hint: "\u5DE6\u534A\u8FB9\u662F\u516C\u53F8\u600E\u4E48\u505A\uFF0C\u53F3\u534A\u8FB9\u662F\u4E3A\u8C01\u505A\uFF0C\u4E2D\u95F4\u662F\u4EF7\u503C\u4E3B\u5F20\uFF1B\u5E95\u90E8\u662F\u94B1\u600E\u4E48\u82B1\u3001\u600E\u4E48\u6765\u3002\u70B9\u683C\u5B50\u770B\u8BE6\u60C5\u3002",
          stats: brief,
          main: canvas,
          sel,
          minSide: 1800,
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
