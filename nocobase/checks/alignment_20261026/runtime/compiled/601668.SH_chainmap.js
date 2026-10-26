async function run(ctx) {
  const COMPANY = "601668.SH";
  const { React } = ctx.libs;
  const { useState, useRef } = React;
  const { Tooltip, Alert, Typography, Empty, theme } = ctx.libs.antd;
  const { Text, Title } = Typography;
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
  const POWER = { \u5F3A: 3, \u4E2D: 2, \u5F31: 1 };
  const REF_KIND = { V: "\u4EA7\u4E1A\u94FE", M: "\u58C1\u5792", T: "\u8BBA\u70B9", B: "\u5546\u4E1A\u6A21\u5F0F", J: "\u5224\u65AD" };
  const REF_RE = /(?<![A-Za-z0-9-])(V\d{1,2}|M\d{1,2}|T\d{1,2}|B\d{1,2}|J-[A-Z0-9]+)(?![0-9])/g;
  const codeNum = (c) => Number(String(c || "").replace(/\D/g, "")) || 0;
  const isNum = (v) => v !== null && v !== void 0 && v !== "" && !Number.isNaN(Number(v));
  const fmtNum = (v) => isNum(v) ? Number(v).toLocaleString("zh-CN", { maximumFractionDigits: 2 }) : "";
  const fmtPct = (v) => isNum(v) ? (Number(v) * 100).toFixed(1) + "%" : "";
  const usable = (s) => s && s !== "\u2014";
  function splitName(s) {
    const t = String(s || "");
    const colon = t.match(/^([^（：]{2,20})：(.+)$/);
    if (colon) return [colon[1].trim(), colon[2].trim()];
    const paren = t.match(/^([^（]{2,30})（([^（）]+)）$/);
    if (paren) return [paren[1].trim(), paren[2].trim()];
    return [t, ""];
  }
  function usePalette() {
    const { token } = theme.useToken();
    const effect = { \u6709\u5229: token.colorSuccess, \u4E2D\u6027: token.colorTextQuaternary, \u4E0D\u5229: token.colorError };
    return { token, effect };
  }
  function Strength({ power, size = "sm" }) {
    const { token } = usePalette();
    const n = POWER[power] || 0;
    const w = size === "sm" ? 6 : 10;
    return /* @__PURE__ */ ctx.libs.React.createElement("span", { style: { display: "inline-flex", gap: 2, alignItems: "center" }, title: `\u529B\u91CF${power || "\u672A\u6807\u6CE8"}` }, [1, 2, 3].map((i) => /* @__PURE__ */ ctx.libs.React.createElement("span", { key: i, style: {
      width: w,
      height: size === "sm" ? 10 : 6,
      borderRadius: 1.5,
      background: i <= n ? token.colorTextSecondary : token.colorFillSecondary
    } })));
  }
  function Dot({ effect, size = 8 }) {
    const { token, effect: c } = usePalette();
    return /* @__PURE__ */ ctx.libs.React.createElement("span", { style: {
      width: size,
      height: size,
      borderRadius: "50%",
      flex: "none",
      display: "inline-block",
      background: c[effect] || token.colorBorder
    } });
  }
  function trendText(n) {
    const arrow = { \u589E\u5F3A: "\u2191", \u7A33\u5B9A: "", \u51CF\u5F31: "\u2193" }[n.trend] || "";
    const bad = n.effect === "\u4E0D\u5229" && n.trend === "\u589E\u5F3A" || n.effect === "\u6709\u5229" && n.trend === "\u51CF\u5F31";
    const good = n.effect === "\u6709\u5229" && n.trend === "\u589E\u5F3A" || n.effect === "\u4E0D\u5229" && n.trend === "\u51CF\u5F31";
    return { arrow, tone: bad ? "bad" : good ? "good" : "flat" };
  }
  function Row({ n, selected, onSelect }) {
    const { token } = usePalette();
    const [head, sub] = splitName(n.participant);
    const t = trendText(n);
    const tone = { bad: token.colorError, good: token.colorSuccess, flat: token.colorTextTertiary }[t.tone];
    return /* @__PURE__ */ ctx.libs.React.createElement(Tooltip, { title: sub || null, placement: "top", mouseEnterDelay: 0.4 }, /* @__PURE__ */ ctx.libs.React.createElement(
      "div",
      {
        onClick: () => onSelect(n.code),
        style: {
          display: "flex",
          alignItems: "center",
          gap: 8,
          padding: "7px 10px",
          borderRadius: 6,
          cursor: "pointer",
          background: selected ? token.colorPrimaryBg : "transparent",
          outline: selected ? `1px solid ${token.colorPrimaryBorder}` : "none",
          transition: "background .15s"
        },
        onMouseEnter: (e) => {
          if (!selected) e.currentTarget.style.background = token.colorFillTertiary;
        },
        onMouseLeave: (e) => {
          if (!selected) e.currentTarget.style.background = "transparent";
        }
      },
      /* @__PURE__ */ ctx.libs.React.createElement(Dot, { effect: n.effect }),
      /* @__PURE__ */ ctx.libs.React.createElement("span", { style: { fontSize: 12, color: token.colorTextQuaternary, width: 24, flex: "none" } }, n.code),
      /* @__PURE__ */ ctx.libs.React.createElement("span", { style: {
        flex: 1,
        minWidth: 0,
        fontSize: 14,
        lineHeight: 1.4,
        color: token.colorText,
        overflow: "hidden",
        display: "-webkit-box",
        WebkitLineClamp: 2,
        WebkitBoxOrient: "vertical",
        wordBreak: "break-all"
      } }, head),
      t.arrow ? /* @__PURE__ */ ctx.libs.React.createElement("span", { style: { fontSize: 12, color: tone, flex: "none" } }, t.arrow) : null,
      /* @__PURE__ */ ctx.libs.React.createElement(Strength, { power: n.power })
    ));
  }
  function Box({ title, hint, nodes, selected, onSelect, tone = "plain", style, onTitle }) {
    const { token } = usePalette();
    const bg = { plain: token.colorBgContainer, core: token.colorPrimaryBg, soft: "transparent" }[tone];
    const border = tone === "soft" ? `1px dashed ${token.colorBorder}` : `1px solid ${tone === "core" ? token.colorPrimaryBorder : token.colorBorderSecondary}`;
    return /* @__PURE__ */ ctx.libs.React.createElement("div", { style: {
      background: bg,
      border,
      borderRadius: 10,
      padding: "10px 6px 6px",
      minWidth: 0,
      boxShadow: tone === "plain" ? "0 1px 2px rgba(0,0,0,0.04)" : "none",
      ...style
    } }, /* @__PURE__ */ ctx.libs.React.createElement("div", { onClick: onTitle, style: {
      display: "flex",
      alignItems: "baseline",
      justifyContent: "space-between",
      gap: 8,
      padding: "0 10px 6px",
      cursor: onTitle ? "pointer" : "default"
    } }, /* @__PURE__ */ ctx.libs.React.createElement("span", { style: { fontSize: 13, fontWeight: 600, color: onTitle ? token.colorPrimary : token.colorText } }, title), hint ? /* @__PURE__ */ ctx.libs.React.createElement("span", { style: { fontSize: 12, color: token.colorTextTertiary } }, hint) : null), nodes.length ? nodes.map((n) => /* @__PURE__ */ ctx.libs.React.createElement(Row, { key: n.code, n, selected: selected === n.code, onSelect })) : /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { fontSize: 12, color: token.colorTextQuaternary, padding: "4px 10px 8px" } }, "\u672A\u586B\u5199"));
  }
  function forceOf(rows, force) {
    const items = rows.filter((r) => r.force === force);
    if (!items.length) return null;
    const p = Math.max(...items.map((r) => POWER[r.power] || 0));
    const e = items.some((r) => r.effect === "\u4E0D\u5229") ? "\u4E0D\u5229" : items.some((r) => r.effect === "\u6709\u5229") ? "\u6709\u5229" : "\u4E2D\u6027";
    const label = Object.keys(POWER).find((k) => POWER[k] === p) || "";
    return { p, e, label };
  }
  function ForceArrow({ dir, f, name }) {
    const { token, effect } = usePalette();
    const color = f ? effect[f.e] : token.colorBorder;
    const thick = f ? [1.5, 2, 4, 7][f.p] : 1;
    const head = thick * 1.6 + 6;
    const horizontal = dir === "left" || dir === "right";
    const shaft = horizontal ? /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { flex: 1, height: thick, background: color, borderRadius: thick } }) : /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { flex: 1, width: thick, background: color, borderRadius: thick } });
    const tri = {
      right: { borderTop: `${head / 1.6}px solid transparent`, borderBottom: `${head / 1.6}px solid transparent`, borderLeft: `${head}px solid ${color}` },
      left: { borderTop: `${head / 1.6}px solid transparent`, borderBottom: `${head / 1.6}px solid transparent`, borderRight: `${head}px solid ${color}` },
      down: { borderLeft: `${head / 1.6}px solid transparent`, borderRight: `${head / 1.6}px solid transparent`, borderTop: `${head}px solid ${color}` },
      up: { borderLeft: `${head / 1.6}px solid transparent`, borderRight: `${head / 1.6}px solid transparent`, borderBottom: `${head}px solid ${color}` }
    }[dir];
    const arrowHead = /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { width: 0, height: 0, flex: "none", ...tri } });
    const caption = /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { fontSize: 12, lineHeight: 1.3, color: token.colorTextSecondary, textAlign: "center", whiteSpace: "nowrap" } }, name, /* @__PURE__ */ ctx.libs.React.createElement("br", null), /* @__PURE__ */ ctx.libs.React.createElement("span", { style: { color: f ? color : token.colorTextQuaternary, fontWeight: 600 } }, f ? f.label : "\u2014"));
    if (horizontal) {
      return /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { display: "flex", flexDirection: "column", alignItems: "stretch", justifyContent: "center", gap: 6, height: "100%", padding: "0 4px" } }, caption, /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { display: "flex", alignItems: "center" } }, dir === "left" ? /* @__PURE__ */ ctx.libs.React.createElement(React.Fragment, null, arrowHead, shaft) : /* @__PURE__ */ ctx.libs.React.createElement(React.Fragment, null, shaft, arrowHead)));
    }
    return /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { display: "flex", alignItems: "center", justifyContent: "center", gap: 10, height: "100%", padding: "4px 0" } }, /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { display: "flex", flexDirection: "column", alignItems: "center", height: 44 } }, dir === "up" ? /* @__PURE__ */ ctx.libs.React.createElement(React.Fragment, null, arrowHead, shaft) : /* @__PURE__ */ ctx.libs.React.createElement(React.Fragment, null, shaft, arrowHead)), caption);
  }
  function ForcesMap({ rows, by, selected, onSelect, compact }) {
    const { token } = usePalette();
    const z = (pos) => by[pos] || [];
    const p = { selected, onSelect };
    const up = /* @__PURE__ */ ctx.libs.React.createElement(Box, { title: "\u4E0A\u6E38\u4F9B\u7ED9", hint: "\u4F9B\u5E94\u5546", nodes: z("\u4E0A\u6E38\u4F9B\u7ED9"), ...p });
    const down = /* @__PURE__ */ ctx.libs.React.createElement(Box, { title: "\u4E0B\u6E38\u5BA2\u6237", hint: "\u4E70\u65B9", nodes: z("\u4E0B\u6E38\u5BA2\u6237"), ...p });
    const entrants = /* @__PURE__ */ ctx.libs.React.createElement(Box, { title: "\u6F5C\u5728\u8FDB\u5165\u8005", nodes: z("\u6F5C\u5728\u8FDB\u5165\u8005"), ...p });
    const subs = /* @__PURE__ */ ctx.libs.React.createElement(Box, { title: "\u66FF\u4EE3\u54C1", nodes: z("\u66FF\u4EE3\u54C1"), ...p });
    const peers = z("\u540C\u4E1A\u7ADE\u4E89");
    const self = z("\u672C\u516C\u53F8\u73AF\u8282");
    const rivalry = forceOf(rows, "\u884C\u4E1A\u5185\u7ADE\u4E89");
    const core = /* @__PURE__ */ ctx.libs.React.createElement(Box, { title: "\u672C\u516C\u53F8", nodes: self, tone: "core", ...p });
    const coreBlock = /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { display: "flex", flexDirection: "column", gap: 8 } }, core, /* @__PURE__ */ ctx.libs.React.createElement(Box, { title: "\u540C\u4E1A\u7ADE\u4E89", hint: rivalry ? `\u884C\u4E1A\u5185\u7ADE\u4E89 \xB7 ${rivalry.label}` : "\u884C\u4E1A\u5185\u7ADE\u4E89", nodes: peers, ...p }));
    const reg = z("\u76D1\u7BA1").length ? /* @__PURE__ */ ctx.libs.React.createElement(Box, { title: "\u76D1\u7BA1", hint: "\u89C4\u5219\u4E0E\u4EF7\u683C\u8FB9\u754C", nodes: z("\u76D1\u7BA1"), tone: "soft", ...p }) : null;
    const comp = z("\u4E92\u8865\u65B9").length ? /* @__PURE__ */ ctx.libs.React.createElement(Box, { title: "\u4E92\u8865\u65B9", hint: "\u8BA9\u672C\u516C\u53F8\u66F4\u503C\u94B1", nodes: z("\u4E92\u8865\u65B9"), tone: "soft", ...p }) : null;
    const channel = z("\u6E20\u9053\u4E0E\u6D41\u91CF").length ? /* @__PURE__ */ ctx.libs.React.createElement(Box, { title: "\u6E20\u9053\u4E0E\u6D41\u91CF", nodes: z("\u6E20\u9053\u4E0E\u6D41\u91CF"), tone: "soft", ...p }) : null;
    const fSup = forceOf(rows, "\u4F9B\u5E94\u5546\u8BAE\u4EF7\u80FD\u529B");
    const fBuy = forceOf(rows, "\u4E70\u65B9\u8BAE\u4EF7\u80FD\u529B");
    const fNew = forceOf(rows, "\u65B0\u8FDB\u5165\u8005\u5A01\u80C1");
    const fSub = forceOf(rows, "\u66FF\u4EE3\u54C1\u5A01\u80C1");
    if (compact) {
      return /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { display: "flex", flexDirection: "column", gap: 10 } }, up, /* @__PURE__ */ ctx.libs.React.createElement(ForceArrow, { dir: "down", f: fSup, name: "\u4F9B\u5E94\u5546\u8BAE\u4EF7\u529B" }), entrants, /* @__PURE__ */ ctx.libs.React.createElement(ForceArrow, { dir: "down", f: fNew, name: "\u65B0\u8FDB\u5165\u8005\u5A01\u80C1" }), coreBlock, /* @__PURE__ */ ctx.libs.React.createElement(ForceArrow, { dir: "up", f: fSub, name: "\u66FF\u4EE3\u54C1\u5A01\u80C1" }), subs, /* @__PURE__ */ ctx.libs.React.createElement(ForceArrow, { dir: "up", f: fBuy, name: "\u4E70\u65B9\u8BAE\u4EF7\u529B" }), down, channel, reg, comp);
    }
    return /* @__PURE__ */ ctx.libs.React.createElement("div", { style: {
      display: "grid",
      gridTemplateColumns: "minmax(0,1fr) 84px minmax(0,1.1fr) 84px minmax(0,1fr)",
      gridTemplateRows: "auto 76px auto 76px auto",
      alignItems: "stretch"
    } }, /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { gridColumn: 1, gridRow: 1, alignSelf: "start" } }, reg), /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { gridColumn: 3, gridRow: 1, alignSelf: "end" } }, entrants), /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { gridColumn: 5, gridRow: 1, alignSelf: "start" } }, channel), /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { gridColumn: 3, gridRow: 2 } }, /* @__PURE__ */ ctx.libs.React.createElement(ForceArrow, { dir: "down", f: fNew, name: "\u65B0\u8FDB\u5165\u8005\u5A01\u80C1" })), /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { gridColumn: 1, gridRow: 3, alignSelf: "center" } }, up), /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { gridColumn: 2, gridRow: 3 } }, /* @__PURE__ */ ctx.libs.React.createElement(ForceArrow, { dir: "right", f: fSup, name: "\u4F9B\u5E94\u5546\u8BAE\u4EF7\u529B" })), /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { gridColumn: 3, gridRow: 3 } }, coreBlock), /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { gridColumn: 4, gridRow: 3 } }, /* @__PURE__ */ ctx.libs.React.createElement(ForceArrow, { dir: "left", f: fBuy, name: "\u4E70\u65B9\u8BAE\u4EF7\u529B" })), /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { gridColumn: 5, gridRow: 3, alignSelf: "center" } }, down), /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { gridColumn: 3, gridRow: 4 } }, /* @__PURE__ */ ctx.libs.React.createElement(ForceArrow, { dir: "up", f: fSub, name: "\u66FF\u4EE3\u54C1\u5A01\u80C1" })), /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { gridColumn: 3, gridRow: 5, alignSelf: "start" } }, subs), /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { gridColumn: 5, gridRow: 5, alignSelf: "end" } }, comp));
  }
  function Legend() {
    const { token, effect } = usePalette();
    const item = (c, t) => /* @__PURE__ */ ctx.libs.React.createElement("span", { style: { display: "inline-flex", alignItems: "center", gap: 6 } }, /* @__PURE__ */ ctx.libs.React.createElement("span", { style: { width: 8, height: 8, borderRadius: "50%", background: c } }), t);
    return /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { display: "flex", flexWrap: "wrap", gap: 18, fontSize: 12, color: token.colorTextTertiary } }, item(effect["\u6709\u5229"], "\u5BF9\u516C\u53F8\u6709\u5229"), item(effect["\u4E2D\u6027"], "\u4E2D\u6027"), item(effect["\u4E0D\u5229"], "\u5BF9\u516C\u53F8\u4E0D\u5229"), /* @__PURE__ */ ctx.libs.React.createElement("span", { style: { display: "inline-flex", alignItems: "center", gap: 6 } }, /* @__PURE__ */ ctx.libs.React.createElement(Strength, { power: "\u4E2D" }), "\u529B\u91CF\u5F3A\u5F31"), /* @__PURE__ */ ctx.libs.React.createElement("span", null, "\u7BAD\u5934\u8D8A\u7C97\uFF0C\u529B\u91CF\u8D8A\u5F3A"), /* @__PURE__ */ ctx.libs.React.createElement("span", null, "\u2191\u2193 \u8D8B\u52BF"));
  }
  function RefText({ text, refs, onSelect }) {
    const { token } = usePalette();
    if (!text) return null;
    const parts = String(text).split(REF_RE);
    return /* @__PURE__ */ ctx.libs.React.createElement(React.Fragment, null, parts.map((p, i) => {
      if (i % 2 === 0) return /* @__PURE__ */ ctx.libs.React.createElement(React.Fragment, { key: i }, p);
      const kind = p.startsWith("J-") ? "J" : p[0];
      const title = refs[p];
      const jump = kind === "V" && title;
      return /* @__PURE__ */ ctx.libs.React.createElement(Tooltip, { key: i, title: title ? `${REF_KIND[kind]} ${p}\uFF1A${title}` : `${REF_KIND[kind]} ${p}` }, /* @__PURE__ */ ctx.libs.React.createElement(
        "span",
        {
          onClick: jump ? () => onSelect(p) : void 0,
          style: {
            color: token.colorPrimary,
            cursor: jump ? "pointer" : "help",
            borderBottom: `1px dashed ${token.colorPrimaryBorder}`
          }
        },
        p
      ));
    }));
  }
  function Detail({ n, refs, onSelect }) {
    const { token, effect } = usePalette();
    if (!n) return /* @__PURE__ */ ctx.libs.React.createElement(Empty, { description: "\u70B9\u51FB\u56FE\u4E2D\u7684\u73AF\u8282\u67E5\u770B\u5206\u6790" });
    const [head, sub] = splitName(n.participant);
    const t = trendText(n);
    const label = (s) => /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { fontSize: 12, color: token.colorTextTertiary, letterSpacing: 0.5, marginBottom: 6 } }, s);
    const para = { fontSize: 14, lineHeight: 1.85, color: token.colorText, margin: 0 };
    const comps = n.competitors || [];
    const facts = n.facts || [];
    const attr = (k, v, c) => /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { minWidth: 0 } }, /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { fontSize: 12, color: token.colorTextTertiary } }, k), /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { fontSize: 14, fontWeight: 600, color: c || token.colorText, marginTop: 2 } }, v));
    const trendColor = { bad: token.colorError, good: token.colorSuccess, flat: token.colorText }[t.tone];
    return /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { display: "flex", flexDirection: "column", gap: 20 } }, /* @__PURE__ */ ctx.libs.React.createElement("div", null, /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { fontSize: 12, color: token.colorTextTertiary } }, n.code, " \xB7 ", n.position, n.force && n.force !== "\u4E0D\u9002\u7528" ? ` \xB7 ${n.force}` : ""), /* @__PURE__ */ ctx.libs.React.createElement(Title, { level: 4, style: { margin: "4px 0 0", fontWeight: 600 } }, head), sub ? /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { fontSize: 13, color: token.colorTextSecondary, marginTop: 4, lineHeight: 1.6 } }, sub) : null), /* @__PURE__ */ ctx.libs.React.createElement("div", { style: {
      display: "grid",
      gridTemplateColumns: "repeat(3, minmax(0,1fr))",
      gap: 12,
      padding: "12px 0",
      borderTop: `1px solid ${token.colorSplit}`,
      borderBottom: `1px solid ${token.colorSplit}`
    } }, attr("\u529B\u91CF", /* @__PURE__ */ ctx.libs.React.createElement("span", { style: { display: "inline-flex", alignItems: "center", gap: 8 } }, n.power || "\u2014", /* @__PURE__ */ ctx.libs.React.createElement(Strength, { power: n.power, size: "lg" }))), attr("\u8D8B\u52BF", `${t.arrow} ${n.trend || "\u2014"}`.trim(), trendColor), attr("\u5BF9\u516C\u53F8", n.effect || "\u2014", effect[n.effect])), usable(n.role) ? /* @__PURE__ */ ctx.libs.React.createElement("div", null, label("\u63D0\u4F9B\u6216\u8D2D\u4E70\u4EC0\u4E48"), /* @__PURE__ */ ctx.libs.React.createElement("p", { style: para }, /* @__PURE__ */ ctx.libs.React.createElement(RefText, { text: n.role, refs, onSelect }))) : null, usable(n.profit_share) ? /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { background: token.colorFillQuaternary, borderRadius: 8, padding: "12px 14px" } }, label("\u5229\u6DA6\u6C60\u6216\u6210\u672C\u5360\u6BD4"), /* @__PURE__ */ ctx.libs.React.createElement("p", { style: { ...para, fontWeight: 500 } }, /* @__PURE__ */ ctx.libs.React.createElement(RefText, { text: n.profit_share, refs, onSelect }))) : null, usable(n.analysis) ? /* @__PURE__ */ ctx.libs.React.createElement("div", null, label("\u5206\u6790"), /* @__PURE__ */ ctx.libs.React.createElement("p", { style: para }, /* @__PURE__ */ ctx.libs.React.createElement(RefText, { text: n.analysis, refs, onSelect }))) : null, usable(n.counter) ? /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { borderLeft: `3px solid ${token.colorWarningBorder}`, paddingLeft: 14 } }, label("\u53CD\u9762\u8BC1\u636E"), /* @__PURE__ */ ctx.libs.React.createElement("p", { style: { ...para, color: token.colorTextSecondary } }, /* @__PURE__ */ ctx.libs.React.createElement(RefText, { text: n.counter, refs, onSelect }))) : null, comps.length ? /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { fontSize: 13, color: token.colorTextSecondary } }, label("\u76F8\u5173\u5BF9\u624B"), comps.map((c) => c.name).join("\u3001"), /* @__PURE__ */ ctx.libs.React.createElement("span", { style: { color: token.colorTextTertiary } }, "\uFF08\u5171 ", comps.length, " \u5BB6\uFF0C\u8BE6\u89C1\u201C\u7ADE\u4E89\u5BF9\u624B\uFF08\u7F16\u8F91\uFF09\u201D\u6807\u7B7E\uFF09")) : null, facts.length ? /* @__PURE__ */ ctx.libs.React.createElement("div", null, label("\u4F9D\u636E\u4E8B\u5B9E"), facts.map((f) => /* @__PURE__ */ ctx.libs.React.createElement("div", { key: f.id, style: { fontSize: 12, color: token.colorTextSecondary, lineHeight: 1.7, paddingLeft: 12, position: "relative" } }, /* @__PURE__ */ ctx.libs.React.createElement("span", { style: { position: "absolute", left: 0 } }, "\xB7"), f.title))) : null);
  }
  function Takeaway({ rows, onSelect }) {
    const { token, effect } = usePalette();
    const bad = rows.filter((r) => r.effect === "\u4E0D\u5229");
    const good = rows.filter((r) => r.effect === "\u6709\u5229");
    const link = (r) => /* @__PURE__ */ ctx.libs.React.createElement("span", { key: r.code, onClick: () => onSelect(r.code), style: { cursor: "pointer", borderBottom: `1px dashed ${token.colorBorder}` } }, r.code, " ", splitName(r.participant)[0], r.trend === "\u589E\u5F3A" ? "\uFF08\u589E\u5F3A\uFF09" : "");
    const join = (xs) => xs.map((r, i) => /* @__PURE__ */ ctx.libs.React.createElement(React.Fragment, { key: r.code }, i ? "\u3001" : "", link(r)));
    return /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { display: "flex", flexDirection: "column", gap: 6, fontSize: 14, lineHeight: 1.7 } }, bad.length ? /* @__PURE__ */ ctx.libs.React.createElement("div", null, /* @__PURE__ */ ctx.libs.React.createElement("span", { style: { color: effect["\u4E0D\u5229"], fontWeight: 600 } }, "\u538B\u529B\u6765\u81EA\u3000"), join(bad)) : null, good.length ? /* @__PURE__ */ ctx.libs.React.createElement("div", null, /* @__PURE__ */ ctx.libs.React.createElement("span", { style: { color: effect["\u6709\u5229"], fontWeight: 600 } }, "\u6709\u5229\u7684\u662F\u3000"), join(good)) : null);
  }
  try {
    const cos = await listRows("vi_company", { code: { $eq: COMPANY } });
    const company = cos[0];
    if (!company) {
      ctx.render(/* @__PURE__ */ ctx.libs.React.createElement(Alert, { type: "info", showIcon: true, message: `\u516C\u53F8\u8868\u91CC\u6CA1\u6709\u4EE3\u7801\u4E3A ${COMPANY} \u7684\u516C\u53F8` }));
    } else {
      let Panel = function() {
        const { token } = usePalette();
        const [sel, setSelRaw] = useState(first);
        const detailRef = useRef(null);
        const rootRef = useRef(null);
        const W = useWidth(rootRef);
        const side = W >= 1300;
        const compact = (side ? W - 392 : W) < 660;
        const setSel = (code) => {
          setSelRaw(code);
          if (!side) setTimeout(() => detailRef.current?.scrollIntoView?.({ behavior: "smooth", block: "start" }), 50);
        };
        if (!rows.length) return /* @__PURE__ */ ctx.libs.React.createElement(Empty, { description: `${company.name}\u8FD8\u6CA1\u6709\u586B\u5199\u4EA7\u4E1A\u94FE\uFF08\u5207\u5230\u672C\u9875\u7684\u201C\u4EA7\u4E1A\u94FE\uFF08\u7F16\u8F91\uFF09\u201D\u6807\u7B7E\u65B0\u589E\uFF09` });
        const node = rows.find((r) => r.code === sel);
        return /* @__PURE__ */ ctx.libs.React.createElement("div", { ref: rootRef, style: { maxWidth: 1480, margin: "0 auto", padding: compact ? 0 : "4px 8px" } }, /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { marginBottom: 20 } }, /* @__PURE__ */ ctx.libs.React.createElement(Title, { level: 3, style: { margin: 0, fontWeight: 600 } }, company.name, " \xB7 \u4EA7\u4E1A\u94FE\u4E0E\u4E94\u529B"), /* @__PURE__ */ ctx.libs.React.createElement(Text, { type: "secondary", style: { fontSize: 13 } }, "\u4E2D\u5FC3\u662F\u672C\u516C\u53F8\uFF0C\u56DB\u5468\u7684\u529B\u91CF\u6307\u5411\u5B83\uFF1A\u5DE6\u8FB9\u4E0A\u6E38\u3001\u53F3\u8FB9\u4E0B\u6E38\u3001\u4E0A\u65B9\u6F5C\u5728\u8FDB\u5165\u8005\u3001\u4E0B\u65B9\u66FF\u4EE3\u54C1\u3002\u70B9\u51FB\u4EFB\u4E00\u73AF\u8282\u67E5\u770B\u5206\u6790\uFF1B\u4FEE\u6539\u73AF\u8282\u8BF7\u5207\u5230\u201C\u4EA7\u4E1A\u94FE\uFF08\u7F16\u8F91\uFF09\u201D\u6807\u7B7E\u3002")), /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { marginBottom: 24 } }, /* @__PURE__ */ ctx.libs.React.createElement(Takeaway, { rows, onSelect: setSel })), /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { display: "grid", gridTemplateColumns: side ? "minmax(0,1fr) 360px" : "1fr", gap: side ? 32 : 24, alignItems: "start" } }, /* @__PURE__ */ ctx.libs.React.createElement("div", null, /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { background: token.colorFillQuaternary, borderRadius: 14, padding: compact ? 12 : 24 } }, /* @__PURE__ */ ctx.libs.React.createElement(ForcesMap, { rows, by, selected: sel, onSelect: setSel, compact })), /* @__PURE__ */ ctx.libs.React.createElement("div", { style: { marginTop: 12 } }, /* @__PURE__ */ ctx.libs.React.createElement(Legend, null))), /* @__PURE__ */ ctx.libs.React.createElement("div", { ref: detailRef, style: side ? { position: "sticky", top: 12, borderLeft: `1px solid ${token.colorSplit}`, paddingLeft: 32 } : { borderTop: `1px solid ${token.colorSplit}`, paddingTop: 24, maxWidth: 820 } }, /* @__PURE__ */ ctx.libs.React.createElement(Detail, { n: node, refs, onSelect: setSel }))));
      };
      const scope = { company_id: { $eq: company.id } };
      const [chain, moats, theses, biz, judgments] = await Promise.all([
        listRows("vi_value_chain", scope, ["competitors", "facts"]),
        listRows("vi_moat", scope),
        listRows("vi_thesis", scope),
        listRows("vi_biz_model", scope),
        listRows("vi_judgment", scope)
      ]);
      const rows = [...chain].sort((a, b) => codeNum(a.code) - codeNum(b.code));
      const refs = {};
      rows.forEach((r) => {
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
      const by = {};
      rows.forEach((r) => {
        (by[r.position] = by[r.position] || []).push(r);
      });
      const first = (by["\u672C\u516C\u53F8\u73AF\u8282"] || rows)[0]?.code;
      ctx.render(/* @__PURE__ */ ctx.libs.React.createElement(Panel, null));
    }
  } catch (error) {
    ctx.render(/* @__PURE__ */ ctx.libs.React.createElement(Alert, { type: "error", showIcon: true, message: "\u4EA7\u4E1A\u94FE\u8BFB\u53D6\u5931\u8D25", description: String(error?.message || error) }));
  }
}
export {
  run as default
};
