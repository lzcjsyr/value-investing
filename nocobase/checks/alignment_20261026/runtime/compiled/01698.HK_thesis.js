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
  function ThesisCard({ x, used, selected, onSelect }) {
    const { t, fs, status } = useUI();
    const refs = [
      ["\u58C1\u5792", used.moats.map((m) => m.code)],
      ["\u98CE\u9669", used.risks.map((r) => r.code)],
      ["\u4F9D\u636E", used.judgments.map((j) => j.code)],
      ["\u9002\u914D\u5EA6", used.fits.map((f) => f.dimension)]
    ].filter(([, xs]) => xs.length);
    return /* @__PURE__ */ ctx.libs.React.createElement(
      Card,
      {
        selected,
        onClick: () => onSelect(x.code),
        accent: status[x.status] || t.colorBorder,
        style: { padding: "16px 18px", display: "flex", flexDirection: "column", gap: 10 }
      },
      /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { display: "flex", alignItems: "center", gap: 10 } }, /* @__PURE__ */ ctx.libs.React.createElement("span", { style: fs.code }, x.code), x.category ? /* @__PURE__ */ ctx.libs.React.createElement(Tag, null, x.category) : null, /* @__PURE__ */ ctx.libs.React.createElement("span", { style: { flex: 1 } }), /* @__PURE__ */ ctx.libs.React.createElement(Status, { label: `${x.status || "\u672A\u88C1\u51B3"}${x.confidence ? " \xB7 \u628A\u63E1" + x.confidence : ""}`, color: status[x.status] })),
      /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { ...fs.title, fontSize: 16 } }, x.title),
      usable(x.mind_changer) ? /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { fontSize: 13.5, lineHeight: 1.7, color: t.colorTextSecondary, ...clamp(2) } }, /* @__PURE__ */ ctx.libs.React.createElement("span", { style: { color: t.colorText, fontWeight: 600 } }, "\u6539\u5224\u6761\u4EF6\u3000"), String(x.mind_changer).replace(/^改判[：:]?\s*/, "")) : null,
      /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { display: "flex", flexWrap: "wrap", gap: 6, alignItems: "center" } }, refs.length ? refs.map(([k, xs]) => /* @__PURE__ */ ctx.libs.React.createElement(Tag, { key: k }, k, " ", xs.join(" "))) : /* @__PURE__ */ ctx.libs.React.createElement(Flag, null, "\u6CA1\u6709\u88AB\u5F15\u7528"), x.check_result === "\u5DF2\u89E6\u53D1" ? /* @__PURE__ */ ctx.libs.React.createElement(Flag, null, "\u81EA\u52A8\u68C0\u67E5\u5DF2\u89E6\u53D1") : null)
    );
  }
  function Detail({ x, used, refs }) {
    const { status, level, verdict } = useUI();
    if (!x) return /* @__PURE__ */ ctx.libs.React.createElement(Empty, { description: "\u70B9\u51FB\u4EFB\u4E00\u8BBA\u70B9\u67E5\u770B\u8FA9\u8BBA\u5168\u6587" });
    const check = x.check_metric ? `${x.check_metric} ${x.check_op || ""} ${x.check_threshold ?? ""}\uFF0C\u8FDE\u7EED ${x.check_years || "?"} \u5E74 \u2192 ${x.check_result || ""}` : "";
    return /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { display: "flex", flexDirection: "column", gap: 22 } }, /* @__PURE__ */ ctx.libs.React.createElement(DetailHead, { meta: `${x.code}${x.category ? " \xB7 " + x.category : ""}${x.debated_on ? " \xB7 \u8FA9\u8BBA\u4E8E " + x.debated_on : ""}`, title: x.title }), /* @__PURE__ */ ctx.libs.React.createElement(Attrs, { items: [["\u88C1\u51B3", /* @__PURE__ */ ctx.libs.React.createElement(Status, { label: x.status || "\u672A\u88C1\u51B3", color: status[x.status], size: 15, strong: true })], ["\u628A\u63E1", x.confidence], ["\u81EA\u52A8\u68C0\u67E5", x.check_result || "\u672A\u8BBE\u7F6E"]] }), /* @__PURE__ */ ctx.libs.React.createElement(Section, { label: "\u88C1\u51B3\u7406\u7531", text: x.verdict, refs, tone: "key" }), /* @__PURE__ */ ctx.libs.React.createElement(Section, { label: "\u6B63\u65B9\u7ACB\u8BBA", text: x.bull_case, refs, tone: "pro" }), /* @__PURE__ */ ctx.libs.React.createElement(Section, { label: "\u53CD\u65B9\u7ACB\u8BBA", text: x.bear_case, refs, tone: "con" }), /* @__PURE__ */ ctx.libs.React.createElement(Section, { label: "\u6B63\u65B9\u53CD\u9A73", text: x.bull_rebuttal, refs, tone: "pro" }), /* @__PURE__ */ ctx.libs.React.createElement(Section, { label: "\u53CD\u65B9\u53CD\u9A73", text: x.bear_rebuttal, refs, tone: "con" }), /* @__PURE__ */ ctx.libs.React.createElement(Section, { label: "\u51B3\u5B9A\u80DC\u8D1F\u7684\u8BC1\u636E", text: x.decisive_evidence, refs }), /* @__PURE__ */ ctx.libs.React.createElement(Section, { label: "\u6539\u5224\u6761\u4EF6", text: x.mind_changer, refs, tone: "key" }), /* @__PURE__ */ ctx.libs.React.createElement(Section, { label: "\u5BF9\u6A21\u578B\u7684\u5F71\u54CD", text: x.model_impact, refs }), /* @__PURE__ */ ctx.libs.React.createElement(Section, { label: "\u5916\u90E8\u89C2\u70B9", text: x.external_view, refs }), /* @__PURE__ */ ctx.libs.React.createElement(Section, { label: "\u81EA\u52A8\u68C0\u67E5\u6761\u4EF6", text: check, refs }), /* @__PURE__ */ ctx.libs.React.createElement(LinkList, { label: "\u88AB\u8FD9\u4E9B\u58C1\u5792\u5F15\u7528", items: used.moats.map((m) => ({ code: m.code, title: m.title, tag: m.verdict, color: verdict[m.verdict] })) }), /* @__PURE__ */ ctx.libs.React.createElement(LinkList, { label: "\u88AB\u8FD9\u4E9B\u98CE\u9669\u524A\u5F31", items: used.risks.map((r) => ({ code: r.code, title: r.title, tag: r.level, color: level[r.level] })) }), /* @__PURE__ */ ctx.libs.React.createElement(LinkList, { label: "\u843D\u5230\u8FD9\u4E9B\u4F30\u503C\u53C2\u6570\uFF08\u5047\u8BBE\u4F9D\u636E\uFF09", items: used.judgments.map((j) => ({ code: j.code, title: `${j.title}${j.parameter ? "\u3000\u2192 " + j.parameter : ""}` })) }), /* @__PURE__ */ ctx.libs.React.createElement(LinkList, { label: "\u652F\u6491\u8FD9\u4E9B\u9002\u914D\u5EA6\u8BC4\u5206", items: used.fits.map((f) => ({ title: `${f.dimension}\u3000${f.score ?? "\u2014"} \u5206` })) }), /* @__PURE__ */ ctx.libs.React.createElement(Facts, { facts: x.facts }));
  }
  boot("\u6838\u5FC3\u8BBA\u70B9", async (company, scope) => {
    const [rows, moats, risks, judgments, fits, refs] = await Promise.all([
      listRows("vi_thesis", scope, ["facts"]),
      listRows("vi_moat", scope, ["theses"]),
      listRows("vi_risk", scope, ["theses"]),
      listRows("vi_judgment", scope, ["theses"]),
      listRows("vi_fit_score", scope, ["theses"]),
      loadRefs(scope)
    ]);
    rows.sort(byCode);
    const usedBy = (x) => {
      const has = (y) => (y.theses || []).some((z) => z.id === x.id);
      return {
        moats: moats.filter(has).sort(byCode),
        risks: risks.filter(has).sort(byCode),
        judgments: judgments.filter(has).sort(byCode),
        fits: fits.filter(has).sort((a, b) => (a.sort ?? 0) - (b.sort ?? 0))
      };
    };
    const used = Object.fromEntries(rows.map((x) => [x.code, usedBy(x)]));
    function Page() {
      const { status } = useUI();
      const [sel, setSel] = useState(rows[0]?.code);
      if (!rows.length) return /* @__PURE__ */ ctx.libs.React.createElement(Empty, { description: `${company.name}\u8FD8\u6CA1\u6709\u586B\u5199\u6838\u5FC3\u8BBA\u70B9\uFF08\u5207\u5230\u201C${EDIT_TAB}\u201D\u6807\u7B7E\u65B0\u589E\uFF09` });
      const n = (s) => rows.filter((x) => x.status === s).length;
      const open = rows.filter((x) => x.status !== "\u6210\u7ACB");
      const headline = `${rows.length} \u6761\u8BBA\u70B9\uFF0C${n("\u6210\u7ACB")} \u6761\u6210\u7ACB` + (open.length ? `\uFF1B${open.map((x) => `${x.code} ${short(String(x.title).split("\uFF0C")[0], 20)}`).join("\u3001")} ${open.every((x) => x.status === "\u89C2\u5BDF") ? "\u4ECD\u5728\u89C2\u5BDF" : "\u672A\u5B9A"}` : "");
      const todo = rows.filter((x) => x.check_result === "\u5DF2\u89E6\u53D1").map((x) => `${x.code} ${short(x.title)}\uFF1A\u81EA\u52A8\u68C0\u67E5\u5DF2\u89E6\u53D1\uFF0C\u9700\u8981\u590D\u6838\u88C1\u51B3`).concat(rows.filter((x) => {
        const u = used[x.code];
        return !u.moats.length && !u.risks.length && !u.judgments.length && !u.fits.length;
      }).map((x) => `${x.code} ${short(x.title)}\uFF1A\u6CA1\u6709\u88AB\u4EFB\u4F55\u58C1\u5792\u3001\u98CE\u9669\u3001\u5047\u8BBE\u4F9D\u636E\u6216\u9002\u914D\u5EA6\u5F15\u7528`));
      const list = (w) => /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { display: "grid", gridTemplateColumns: w >= 900 ? "repeat(2, minmax(0,1fr))" : "1fr", gap: 14, alignItems: "start" } }, rows.map((x) => /* @__PURE__ */ ctx.libs.React.createElement(ThesisCard, { key: x.code, x, used: used[x.code], selected: x.code === sel, onSelect: setSel })));
      const cur = rows.find((x) => x.code === sel);
      return /* @__PURE__ */ ctx.libs.React.createElement(
        Shell,
        {
          eyebrow: `${company.name} \xB7 \u6838\u5FC3\u8BBA\u70B9`,
          headline,
          hint: "\u6BCF\u6761\u90FD\u6B63\u53CD\u8FA9\u8BBA\u540E\u4E0B\u7ED3\u8BBA\uFF1B\u5361\u7247\u5E95\u90E8\u662F\u5F15\u7528\u5B83\u7684\u58C1\u5792\u3001\u98CE\u9669\u3001\u5047\u8BBE\u4F9D\u636E\u548C\u9002\u914D\u5EA6\u7EF4\u5EA6\u3002\u70B9\u5361\u7247\u770B\u8FA9\u8BBA\u5168\u6587\u3002",
          stats: /* @__PURE__ */ ctx.libs.React.createElement(Stats, { items: ["\u6210\u7ACB", "\u89C2\u5BDF", "\u5B58\u7591", "\u8BC1\u4F2A"].map((s) => ({ label: s, value: n(s), unit: "\u6761", color: status[s] })) }),
          notice: /* @__PURE__ */ ctx.libs.React.createElement(Notice, { items: todo }),
          main: list,
          sel,
          detailWidth: 480,
          detail: /* @__PURE__ */ ctx.libs.React.createElement(Detail, { x: cur, used: cur ? used[cur.code] : null, refs })
        }
      );
    }
    ctx.render(/* @__PURE__ */ ctx.libs.React.createElement(Page, null));
  });
}
export {
  run as default
};
