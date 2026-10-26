"""四家公司页面的表格排版；只在生成指定公司的页面时应用。"""

TABLE = r"""
function Table(props) {
  const numberKeys = new Set(['prob', 'probability', 'core', 'm', 'coreValue', 'mature', 'growth', 'invest', 'direct', 'cash', 'inv', 'other', 'vps', 'quote', 'vsPrice', 'irr', 'cashIrr', 'ceiling', 'price', 'np', 'dps', 'g', 'vf', 'pf', 'cf']);
  const cols = (props.columns || []).map((c) => {
    const key = c.dataIndex || c.key;
    const numeric = numberKeys.has(key) || /^h\d{4}$|^y\d{4}$/.test(String(key));
    return { ...c, align: c.align || (numeric ? 'right' : 'left'),
      width: c.width || (numeric ? 140 : key === 'name' || key === 'scenario_name' ? 120 : 200),
      onHeaderCell: (...args) => ({ ...c.onHeaderCell?.(...args), style: { whiteSpace: 'normal', wordBreak: 'normal' } }),
    };
  });
  return <NativeTable {...props} columns={cols} scroll={props.scroll || { x: 'max-content' }}
    style={{ fontVariantNumeric: 'tabular-nums', ...props.style }} />;
}
"""


def wrap_js(js):
    """不影响长江电力已落库的代码；调用方显式选公司。"""
    if 'function Table(props)' in js:
        return js
    if 'Table,' not in js and 'Table }' not in js:
        return js
    js = js.replace(' Table,', ' Table: NativeTable,', 1).replace(' Table }', ' Table: NativeTable }', 1)
    pos = js.find('async function listRows')
    if pos >= 0:
        js = js[:pos] + TABLE + '\n' + js[pos:]
    else:
        js += '\n' + TABLE
    return js


def column_settings(field):
    name = field['name']
    interface = field.get('interface', '')
    numeric = interface in ('number', 'integer', 'percent')
    width = 150 if numeric else 200
    if name == 'code': width = 100
    elif name == 'year': width = 110
    elif name in ('volume', 'price'): width = 220
    elif name in ('title', 'name', 'participant', 'metric'): width = 280
    elif interface in ('textarea', 'richText', 'vditor'): width = 360
    elif interface in ('select', 'checkbox', 'boolean'): width = 140
    elif interface in ('date', 'datetime'): width = 170
    return {'width': width}


def business_unit_label(field, company_code):
    labels = {
        '002078.SZ': {'volume': '浆纸销量（万吨）', 'price': '综合吨收入（万元/吨）'},
        '601668.SH': {'volume': '新签合同（亿元）', 'price': '收入转化率'},
        '01698.HK': {'volume': '付费用户（亿人）', 'price': '集团每付费用户年收入（元）'},
        '01810.HK': {'volume': '月活用户（亿人）', 'price': '集团每月活年收入（元）'},
    }
    return labels.get(company_code, {}).get(field)
