// 执行实际页面代码，检查初次渲染、表格列与币种换算；数据来自本机 API 快照。
import fs from 'node:fs';
import path from 'node:path';

const [, , moduleFile, dataDir] = process.argv;
const data = {};
for (const file of fs.readdirSync(dataDir).filter(f => /^vi_.*\.json$/.test(f))) {
  const result = JSON.parse(fs.readFileSync(path.join(dataDir, file), 'utf8'));
  data[file.slice(0, -5)] = result.data || [];
}
const React = {
  createElement: (type, props, ...children) => ({type, props: props || {}, children: children.flat()}),
  Fragment: 'fragment', useState: value => [value, () => {}], useRef: value => ({current: value}),
  useEffect() {}, useLayoutEffect() {}, useMemo: fn => fn(),
};
const token = new Proxy({}, { get: (_, name) => /color/i.test(name) ? '#666' : 12 });
const components = ['Card','Segmented','Table','Alert','Space','Tag','Popover','Collapse','Descriptions','Row','Col','Statistic','InputNumber','Button','Tooltip','Empty','Slider','Divider','Badge','Progress','Spin','Select','Radio','Switch'];
const antd = Object.fromEntries(components.map(x => [x, x]));
antd.Typography = Object.fromEntries(['Text','Paragraph','Title'].map(x => [x,x]));
antd.theme = {useToken: () => ({token})};
antd.message = {success() {}, error() {}};
let rendered;
const ctx = {
  libs: {React, antd}, render: node => { rendered = node; },
  makeResource() {
    let name, filter;
    function match(row, test) {
      if (!test) return true;
      if (test.$and) return test.$and.every(t => match(row, t));
      if (test.$or) return test.$or.some(t => match(row, t));
      return Object.entries(test).every(([key, op]) => {
        const value = row[key];
        if ('$eq' in op) return value === op.$eq;
        if ('$ne' in op) return value !== op.$ne;
        return true;
      });
    }
    return {setResourceName: n => { name=n; }, setPageSize() {}, setAppends() {},
      setFilter: f => { filter=f; }, refresh: async () => {}, getData: () => (data[name] || []).filter(r => match(r,filter))};
  },
  request: async () => ({data:{data:[]}}),
};
await (await import(path.resolve(moduleFile))).default(ctx);
await new Promise(resolve => setImmediate(resolve));
if (!rendered) throw new Error('页面未渲染');
const stats = [], tables = [], alerts = [];
function text(node) {
  if (node == null || node === false) return '';
  if (typeof node !== 'object') return String(node);
  if (Array.isArray(node)) return node.map(text).join('');
  return (node.children || []).map(text).join('');
}
function walk(node) {
  if (!node || typeof node !== 'object') return;
  if (Array.isArray(node)) {node.forEach(walk); return;}
  if (typeof node.type === 'function') {walk(node.type({...node.props,children:node.children})); return;}
  if (node.type === 'Alert') {
    alerts.push(node.props);
    if (node.props.type === 'error') throw new Error(text(node.props.message) + ': ' + text(node.props.description));
  }
  if (node.type === 'Statistic') stats.push({title:text(node.props.title),value:node.props.value,suffix:node.props.suffix});
  if (node.type === 'Table') {
    const cols = node.props.columns || [];
    if (!cols.length) throw new Error('空列');
    const renderedRows = (node.props.dataSource || []).map(r => cols.map(c => text(c.render ? c.render(r[c.dataIndex],r) : r[c.dataIndex])));
    tables.push({cols:cols.map(c => ({title:text(c.title),align:c.align,width:c.width})),rows:renderedRows});
  }
  walk(node.children);
}
walk(rendered);
console.log(JSON.stringify({module:path.basename(moduleFile),stats,tables,alerts},null,2));
