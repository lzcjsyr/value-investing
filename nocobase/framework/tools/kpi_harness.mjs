// 在 Node 里模拟 NocoBase RunJS 的 ctx，执行驾驶舱“关键读数”脚本，读出页面上显示的统计数字与表格（代替浏览器检查）
import fs from 'node:fs';
import path from 'node:path';

// 用法：node kpi_harness.mjs <转好的驾驶舱脚本.mjs> <数据目录（vi_*.json）> [试算倍数]
const [, , modFile, dir, trialArg] = process.argv;
const data = {};
for (const f of fs.readdirSync(dir).filter((f) => f.startsWith('vi_') && f.endsWith('.json'))) {
  data[f.replace('.json', '')] = JSON.parse(fs.readFileSync(path.join(dir, f))).data;
}

let hookIdx = 0;
const trial = trialArg ? Number(trialArg) : null;
const React = {
  createElement: (type, props, ...children) => ({ type, props: props || {}, children: children.flat() }),
  useState: (init) => {
    hookIdx += 1;
    const v = hookIdx === 2 ? trial : init;            // 第 2 个 state 是“试算倍数”
    return [v, () => {}];
  },
};
const names = ['Card', 'Col', 'Row', 'Statistic', 'Typography', 'Alert', 'Slider', 'InputNumber', 'Button', 'Table', 'Tag', 'Space'];
const antd = Object.fromEntries(names.map((n) => [n, n]));
antd.Typography = { Title: 'Title', Text: 'Text', Paragraph: 'Paragraph' };
antd.message = { success() {}, error() {} };
let rendered = null;
const ctx = {
  libs: { React, antd },
  render: (el) => { rendered = el; },
  request: async () => ({}),
  makeResource: () => {
    let name, filter;
    return {
      setResourceName: (n) => { name = n; }, setPageSize: () => {}, setFilter: (f) => { filter = f; },
      refresh: async () => {},
      getData: () => (data[name] || []).filter((r) => !filter || Object.entries(filter).every(([k, v]) => r[k] === v.$eq)),
    };
  },
};

const run = (await import(path.resolve(modFile))).default;
await run(ctx);
if (!rendered) throw new Error('nothing rendered');
if (rendered.type === 'Alert') { console.log('ALERT', rendered.props); process.exit(1); }
hookIdx = 0;
const tree = rendered.type(rendered.props);           // <Panel />

const out = [];
function text(x) {
  if (x === null || x === undefined || x === false) return '';
  if (typeof x !== 'object') return String(x);
  if (Array.isArray(x)) return x.map(text).join('');
  return (x.children || []).map(text).join('');
}
function walk(n, cardTitle) {
  if (!n || typeof n !== 'object') return;
  if (Array.isArray(n)) { n.forEach((c) => walk(c, cardTitle)); return; }
  const title = n.type === 'Card' && n.props.title ? n.props.title : cardTitle;
  if (n.type === 'Card' && n.props.title) out.push(`\n## ${n.props.title}`);
  if (n.type === 'Statistic') out.push(`  [${n.props.title}] ${n.props.value}${n.props.suffix ? ' ' + n.props.suffix : ''}`);
  if (n.type === 'Table') {
    const cols = n.props.columns;
    out.push('  | ' + cols.map((c) => c.title).join(' | '));
    for (const r of n.props.dataSource) {
      out.push('  | ' + cols.map((c) => { const v = r[c.dataIndex]; const x = c.render ? c.render(v, r) : v; return text(x); }).join(' | '));
    }
  }
  if (n.type === 'Paragraph') out.push('  ' + text(n).slice(0, 160));
  walk(n.children, title);
}
walk(tree);
console.log(out.join('\n'));
