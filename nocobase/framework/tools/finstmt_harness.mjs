// 在 Node 里模拟 NocoBase RunJS 的 ctx，执行「财务数据」页脚本，读出矩阵表格（代替浏览器检查）
import fs from 'node:fs';
import path from 'node:path';

// 用法：node finstmt_harness.mjs <转好的脚本.mjs> <数据目录（*.jsonl）> [报表] [窗口] [累计|单季]
const [, , modFile, dir, stmtArg, winArg, singleArg] = process.argv;
const loadJsonl = (f) => fs.readFileSync(path.join(dir, f), 'utf8').split('\n').filter(Boolean).map((l) => JSON.parse(l));
const companies = loadJsonl('vi_company.jsonl');
const finStmt = loadJsonl('vi_fin_stmt.jsonl');

const React = {
  createElement: (type, props, ...children) => ({ type, props: props || {}, children: children.flat() }),
  useState: (init) => {
    hookIdx += 1;                                        // Page 里 hook 顺序：报表 / 累计单季 / 窗口
    const over = { 1: stmtArg, 2: singleArg === '单季' ? true : singleArg === '累计' ? false : undefined, 3: winArg ? Number(winArg) : undefined };
    return [over[hookIdx] !== undefined && over[hookIdx] !== '' ? over[hookIdx] : init, () => {}];
  },
};
let hookIdx = 0;
const antd = {};
for (const n of ['Table', 'Segmented', 'Select', 'Space', 'Spin', 'Tag']) antd[n] = n;
antd.Typography = { Text: 'Text', Title: 'Title' };
let rendered = null;
const ctx = {
  libs: { React, antd },
  render: (el) => { rendered = el; },
  request: async ({ url, params = {} }) => {
    const [name] = url.split(':');
    let rows = name === 'vi_company' ? companies : name === 'vi_fin_stmt' ? finStmt : [];
    const filter = params.filter ? JSON.parse(params.filter) : {};
    rows = rows.filter((r) => Object.entries(filter).every(([k, v]) => r[k] === v.$eq));
    const size = Number(params.pageSize) || 2000;
    const page = Number(params.page) || 1;
    const batch = rows.slice((page - 1) * size, page * size);
    return { data: { data: batch, meta: { count: rows.length, page, pageSize: size } } };
  },
};

const run = (await import(path.resolve(modFile))).default;
await run(ctx);
if (!rendered) throw new Error('nothing rendered');
if (rendered.type === 'Text' && rendered.props.type === 'danger') { console.log('ALERT', rendered.children); process.exit(1); }
const tree = rendered.type(rendered.props);           // <Page />
if (stmtArg || winArg || singleArg) console.log('视图：' + (stmtArg || '资产负债表') + ' · ' + (singleArg || '累计') + ' · ' + (winArg ? `近${winArg}期` : '近12期'));

const out = [];
function text(x) {
  if (x === null || x === undefined || x === false) return '';
  if (typeof x !== 'object') return String(x);
  if (Array.isArray(x)) return x.map(text).join('');
  return (x.children || []).map(text).join('');
}
function walk(n) {
  if (!n || typeof n !== 'object') return;
  if (Array.isArray(n)) { n.forEach(walk); return; }
  if (n.type === 'Table') {
    const cols = n.props.columns;
    out.push('列: ' + cols.map((c) => text(c.title).replace(/\s+/g, '')).join(' | ') + '  (行数 ' + n.props.dataSource.length + ')');
    for (const r of n.props.dataSource) {
      out.push('  ' + cols.map((c) => {
        const v = r[c.dataIndex];
        const x = c.render ? c.render(v, r) : v;
        return text(x);
      }).join(' | '));
    }
  }
  walk(n.children);
}
walk(tree);
console.log(out.join('\n'));
