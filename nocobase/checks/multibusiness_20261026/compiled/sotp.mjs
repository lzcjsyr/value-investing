async function run(ctx) {
  const COMPANY = "01810.HK";
  const { React } = ctx.libs;
  const { useState } = React;
  const { Card, Segmented, Table, Alert, Typography, Row, Col, Statistic, Collapse, Descriptions, Tag } = ctx.libs.antd;
  const { Text, Paragraph, Title } = Typography;
  async function listRows(name, filter, appends) {
    const r = ctx.makeResource("MultiRecordResource");
    r.setResourceName(name);
    r.setPageSize?.(1e3);
    r.setFilter?.(filter);
    if (appends) r.setAppends?.(appends);
    await r.refresh();
    return r.getData() || [];
  }
  const numeric = (v) => v !== null && v !== void 0 && v !== "" && Number.isFinite(Number(v));
  const fmt = (v, d = 1) => numeric(v) ? Number(v).toLocaleString("zh-CN", { minimumFractionDigits: d, maximumFractionDigits: d }) : "\u2014";
  const pickScenario = (rows, scenario) => {
    const picked = /* @__PURE__ */ new Map();
    rows.filter((r) => r.scenario_id == null || String(r.scenario_id) === String(scenario.id)).sort((a, b) => Number(a.scenario_id != null) - Number(b.scenario_id != null)).forEach((r) => picked.set(r.business_id && r.method ? "business:" + r.business_id : "code:" + r.code, r));
    return [...picked.values()].sort((a, b) => String(a.code).localeCompare(String(b.code), void 0, { numeric: true }));
  };
  try {
    const [company] = await listRows("vi_company", { code: { $eq: COMPANY } });
    if (!company) throw new Error("\u516C\u53F8\u4E0D\u5B58\u5728");
    const [model] = await listRows("vi_model", { company_id: { $eq: company.id }, status: { $eq: "\u5F53\u524D" } });
    if (!model) {
      ctx.render(/* @__PURE__ */ ctx.libs.React.createElement(Alert, { type: "info", message: "\u5C1A\u65E0\u5F53\u524D\u4F30\u503C\u6A21\u578B" }));
    } else {
      let Page = function() {
        const [sid, setSid] = useState(String(base.id));
        const scenario = scenarios.find((s) => String(s.id) === String(sid)) || base;
        const total = totals.find((t) => String(t.id) === String(scenario.id)) || {};
        const businessOf = (r) => businesses.find((b) => String(b.id) === String(r.business_id));
        const businessRows = values.filter((v) => String(v.scenario_id) === String(scenario.id)).map((v) => {
          const input = segments.find((r) => String(r.id) === String(v.segment_id)) || {};
          return { ...input, ...v, key: v.id, businessName: businessOf(v)?.name || v.name };
        }).sort((a, b) => String(a.code).localeCompare(String(b.code), void 0, { numeric: true }));
        if (numeric(total.core_value)) businessRows.unshift({ key: "core", code: "\u6838\u5FC3\u4E1A\u52A1", businessName: "\u6838\u5FC3\u4E1A\u52A1\uFF08\u9884\u6D4B\u6A21\u578B\uFF09", method: "\u6838\u5FC3\u76C8\u5229\xD7\u500D\u6570", value: total.core_value });
        const assetRows = pickScenario(assets, scenario);
        const evidence = (facts) => (facts || []).map((f) => f.title).join("\uFF1B") || "\u5F85\u8865\u5145";
        return /* @__PURE__ */ ctx.libs.React.createElement("div", null, /* @__PURE__ */ ctx.libs.React.createElement(Title, { level: 4, style: { marginTop: 0 } }, company.name, " \xB7 \u4E1A\u52A1\u4F30\u503C\uFF0B\u8D44\u4EA7\u4F30\u503C\u4E0E\u8C03\u6574"), /* @__PURE__ */ ctx.libs.React.createElement(Paragraph, { type: "secondary" }, "\u8D44\u4EA7\u8D1F\u503A\u65E5 ", total.as_of || "\u2014", "\uFF1B\u91D1\u989D\u4E3A\u4EBF\u5143\u4EBA\u6C11\u5E01\u3002\u6BCF\u80A1\u4EF7\u503C\uFF1D\uFF08\u4E1A\u52A1\u4F30\u503C\u5408\u8BA1\uFF0B\u8D44\u4EA7\u4F30\u503C\u4E0E\u8C03\u6574\u51C0\u989D\uFF09\xF7\u80A1\u672C\u3002"), /* @__PURE__ */ ctx.libs.React.createElement(Segmented, { value: sid, onChange: setSid, options: scenarios.map((s) => ({ label: s.name, value: String(s.id) })) }), total.asset_incomplete > 0 && /* @__PURE__ */ ctx.libs.React.createElement(Alert, { type: "warning", showIcon: true, style: { marginTop: 12 }, message: total.conclusion }), !numeric(total.equity_value) && !(total.asset_incomplete > 0) && /* @__PURE__ */ ctx.libs.React.createElement(Alert, { type: "warning", showIcon: true, style: { marginTop: 12 }, message: total.conclusion || "\u4F30\u503C\u8F93\u5165\u5C1A\u4E0D\u5B8C\u6574" }), /* @__PURE__ */ ctx.libs.React.createElement(Row, { gutter: [12, 12], style: { margin: "16px 0" } }, /* @__PURE__ */ ctx.libs.React.createElement(Col, { xs: 12, md: 6 }, /* @__PURE__ */ ctx.libs.React.createElement(Statistic, { title: "\u4E1A\u52A1\u4F30\u503C\u5408\u8BA1", value: fmt(total.business_value), suffix: "\u4EBF\u5143" })), /* @__PURE__ */ ctx.libs.React.createElement(Col, { xs: 12, md: 6 }, /* @__PURE__ */ ctx.libs.React.createElement(Statistic, { title: "\u8D44\u4EA7\u4F30\u503C\u4E0E\u8C03\u6574\u51C0\u989D", value: fmt(total.asset_value), suffix: "\u4EBF\u5143" })), /* @__PURE__ */ ctx.libs.React.createElement(Col, { xs: 12, md: 6 }, /* @__PURE__ */ ctx.libs.React.createElement(Statistic, { title: "\u80A1\u6743\u4EF7\u503C", value: fmt(total.equity_value), suffix: "\u4EBF\u5143" })), /* @__PURE__ */ ctx.libs.React.createElement(Col, { xs: 12, md: 6 }, /* @__PURE__ */ ctx.libs.React.createElement(Statistic, { title: "\u6BCF\u80A1\u4EF7\u503C", value: fmt(total.value_per_share, 2), suffix: numeric(total.value_per_share_quote) ? `\u5143 \u2248 ${fmt(total.value_per_share_quote, 2)} \u6E2F\u5143` : "\u5143" }))), /* @__PURE__ */ ctx.libs.React.createElement(Card, { size: "small", title: "\u4E1A\u52A1\u4F30\u503C", style: { marginBottom: 16 } }, /* @__PURE__ */ ctx.libs.React.createElement(Table, { rowKey: "key", pagination: false, dataSource: businessRows, columns: [
          { title: "\u4E1A\u52A1", dataIndex: "businessName" },
          { title: "\u4F30\u503C\u65B9\u6CD5", dataIndex: "method" },
          { title: "\u53D1\u5C55\u9636\u6BB5", dataIndex: "stage" },
          { title: "\u76C8\u5229\u5E74\u4EFD", dataIndex: "earn_year" },
          { title: "\u5206\u90E8\u4EF7\u503C\uFF08\u4EBF\u5143\uFF09", key: "value", align: "right", render: (_, r) => fmt(r.value) }
        ] }), /* @__PURE__ */ ctx.libs.React.createElement(Collapse, { ghost: true, items: businessRows.filter((r) => r.business_id).map((r) => {
          const b = businessOf(r), rows = canvas.filter((c) => String(c.business_id) === String(r.business_id)).sort((a, b2) => String(a.code).localeCompare(String(b2.code), void 0, { numeric: true }));
          return { key: r.id, label: `${r.code} ${b?.name || r.name}\uFF1A\u5546\u4E1A\u6A21\u5F0F\u4E0E\u4F30\u503C\u4F9D\u636E`, children: /* @__PURE__ */ ctx.libs.React.createElement("div", null, /* @__PURE__ */ ctx.libs.React.createElement(Descriptions, { column: 1, size: "small", bordered: true, items: [
            ["\u4E1A\u52A1\u8FB9\u754C", b?.boundary],
            ["\u8D39\u7528\u5206\u644A", b?.cost_allocation],
            ["\u7ECF\u8425\u8D44\u4EA7\u4E0E\u6295\u5165", b?.asset_boundary],
            ["\u4F30\u503C\u4F9D\u636E", r.basis]
          ].filter(([, v]) => v).map(([label, v]) => ({ key: label, label, children: v })) }), /* @__PURE__ */ ctx.libs.React.createElement(Collapse, { ghost: true, items: rows.map((c) => ({ key: c.id, label: c.element + "\uFF1A" + c.title, children: /* @__PURE__ */ ctx.libs.React.createElement("div", null, /* @__PURE__ */ ctx.libs.React.createElement(Paragraph, null, c.content), /* @__PURE__ */ ctx.libs.React.createElement(Paragraph, { type: "secondary" }, c.trend), /* @__PURE__ */ ctx.libs.React.createElement(Paragraph, { type: "secondary" }, "\u4F9D\u636E\u4E8B\u5B9E\uFF1A", evidence(c.facts))) })) })) };
        }) })), /* @__PURE__ */ ctx.libs.React.createElement(Card, { size: "small", title: "\u8D44\u4EA7\u4F30\u503C\u4E0E\u8C03\u6574", style: { marginBottom: 16 } }, /* @__PURE__ */ ctx.libs.React.createElement(Table, { rowKey: "id", pagination: false, dataSource: assetRows, columns: [
          { title: "\u9879\u76EE", dataIndex: "name" },
          { title: "\u7C7B\u522B", dataIndex: "kind" },
          { title: "\u8BA1\u4EF7\u5904\u7406", dataIndex: "treatment" },
          { title: "\u76F8\u5173\u4E1A\u52A1", key: "businessName", render: (_, r) => businessOf(r)?.name || "\u96C6\u56E2" },
          { title: "\u8BA1\u4EF7\u4F9D\u636E", dataIndex: "valuation_method" },
          { title: "\u91D1\u989D\uFF08\u4EBF\u5143\uFF09", dataIndex: "amount", align: "right", render: (v) => fmt(v) },
          { title: "\u6298\u4EF7", dataIndex: "haircut", align: "right", render: (v) => numeric(v) ? fmt(Number(v) * 100, 0) + "%" : "\u2014" },
          { title: "\u8BA1\u5165\u4EF7\u503C\uFF08\u4EBF\u5143\uFF09", dataIndex: "signed_value", align: "right", render: (v) => fmt(v) }
        ] }), /* @__PURE__ */ ctx.libs.React.createElement(Paragraph, { type: "secondary", style: { marginTop: 12 } }, "\u5DF2\u542B\u4E1A\u52A1\u4F30\u503C\u7684\u7ECF\u8425\u56FA\u5B9A\u8D44\u4EA7\u4EC5\u767B\u8BB0\u8FB9\u754C\uFF0C\u4E0D\u518D\u52A0\u603B\uFF1B\u91D1\u989D\u7A7A\u767D\u8868\u793A\u72EC\u7ACB\u8D44\u4EA7\u91D1\u989D\u672A\u77E5\u3002\u53EF\u72EC\u7ACB\u5904\u7F6E\u7684\u56FA\u5B9A\u8D44\u4EA7\u6216\u5176\u4ED6\u975E\u7ECF\u8425\u8D44\u4EA7\uFF0C\u53EF\u5728\u6392\u9664\u76F8\u5173\u4E1A\u52A1\u6536\u76CA\u540E\u9009\u62E9\u5355\u72EC\u8BA1\u4EF7\u3002"), /* @__PURE__ */ ctx.libs.React.createElement(Collapse, { ghost: true, items: assetRows.map((r) => ({
          key: r.id,
          label: r.code + " " + r.name + "\uFF1A\u8BA1\u4EF7\u8FB9\u754C\u4E0E\u4F9D\u636E",
          children: /* @__PURE__ */ ctx.libs.React.createElement(Descriptions, { size: "small", column: 1, bordered: true, items: [
            ["\u8BA1\u4EF7\u8FB9\u754C", r.boundary],
            ["\u4F9D\u636E", r.basis],
            ["\u622A\u81F3", r.as_of],
            ["\u4F9D\u636E\u4E8B\u5B9E", evidence(r.facts)]
          ].filter(([, v]) => v).map(([label, v]) => ({ key: label, label, children: v })) })
        })) })), /* @__PURE__ */ ctx.libs.React.createElement(Card, { size: "small", title: "\u60C5\u666F\u6C47\u603B\u4E0E\u4EA4\u53C9\u9A8C\u8BC1" }, /* @__PURE__ */ ctx.libs.React.createElement(Table, { rowKey: "id", pagination: false, dataSource: totals, columns: [
          { title: "\u60C5\u666F", dataIndex: "scenario_name" },
          { title: "\u4E1A\u52A1\u4F30\u503C\uFF08\u4EBF\u5143\uFF09", dataIndex: "business_value", align: "right", render: (v) => fmt(v) },
          { title: "\u8D44\u4EA7\u8C03\u6574\u51C0\u989D\uFF08\u4EBF\u5143\uFF09", dataIndex: "asset_value", align: "right", render: (v) => fmt(v) },
          { title: "\u80A1\u6743\u4EF7\u503C\uFF08\u4EBF\u5143\uFF09", dataIndex: "equity_value", align: "right", render: (v) => fmt(v) },
          { title: "\u6BCF\u80A1\u4EF7\u503C\uFF08\u5143\uFF09", dataIndex: "value_per_share", align: "right", render: (v) => fmt(v, 2) },
          { title: "\u6BCF\u80A1\u4EF7\u503C\uFF08\u6E2F\u5143\uFF09", dataIndex: "value_per_share_quote", align: "right", render: (v) => fmt(v, 2) },
          { title: "\u80A1\u4E1C\u56DE\u62A5\u6298\u73B0\uFF08\u5143\uFF09", dataIndex: "ddm_value", align: "right", render: (v) => fmt(v, 2) }
        ] }), /* @__PURE__ */ ctx.libs.React.createElement(Paragraph, { type: "secondary", style: { marginTop: 12 } }, "\u4E1A\u52A1\u53C2\u6570\u3001\u8D44\u4EA7\u9879\u76EE\u5206\u522B\u5728\u672C\u9875\u7F16\u8F91\u6807\u7B7E\u7EF4\u62A4\uFF1B\u4E1A\u52A1\u8FB9\u754C\u53CA\u753B\u5E03\u5728\u201C\u5546\u4E1A\u6A21\u5F0F\u62C6\u89E3\u201D\u7EF4\u62A4\u3002\u80A1\u4E1C\u56DE\u62A5\u6298\u73B0\u4F5C\u4E3A\u96C6\u56E2\u53E3\u5F84\u4EA4\u53C9\u9A8C\u8BC1\u3002")));
      };
      const scope = { company_id: { $eq: company.id } }, byModel = { model_id: { $eq: model.id } };
      const [businesses, canvas, scenarios, totals, segments, assets, values] = await Promise.all([
        listRows("vi_business", scope),
        listRows("vi_biz_model", scope, ["facts"]),
        listRows("vi_scenario", byModel),
        listRows("vi_sotp", byModel),
        listRows("vi_sotp_segment", byModel),
        listRows("vi_sotp_item", byModel, ["facts"]),
        listRows("vi_sotp_segment_val", byModel)
      ]);
      scenarios.sort((a, b) => (a.sort || 0) - (b.sort || 0));
      const base = scenarios.find((s) => s.is_base) || scenarios[0];
      if (!base) throw new Error("\u5C1A\u672A\u5EFA\u7ACB\u4F30\u503C\u60C5\u666F");
      ctx.render(/* @__PURE__ */ ctx.libs.React.createElement(Page, null));
    }
  } catch (error) {
    ctx.render(/* @__PURE__ */ ctx.libs.React.createElement(Alert, { type: "error", showIcon: true, message: "\u5206\u90E8\u4F30\u503C\u8BFB\u53D6\u5931\u8D25", description: String(error?.message || error) }));
  }
}
export {
  run as default
};
