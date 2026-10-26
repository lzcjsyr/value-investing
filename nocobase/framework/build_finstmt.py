"""「<公司> / 数据底稿 / 财务数据」定制页：季度完整三大报表的矩阵视图（只读）。

数据来自 fin_stmt（framework/tools/fin_stmt.py 灌入）：一行＝公司×报表×报告期×科目，金额为亿元（报表原值÷1e8）。
页面把长表透视成报表的样子：行＝科目（按行次），列＝报告期（新→旧）；报表、累计/单季、期数窗口都是页面上切换，
脚本只读 vi_company / vi_fin_stmt，不存任何数字。

  python3 build_finstmt.py             # 给五家公司建缺的页面
  python3 build_finstmt.py --update    # 只更新已建页面的脚本（改了下面的 JS 或表的定位之后用，地址不变）
  python3 build_finstmt.py --rebuild   # 删除后重建
  ../tools/finstmt_check.sh 600900.SH  # 不开浏览器用真实数据验证脚本（Node 模拟 RunJS）
"""
import json, sys
import spec
from build_pages import state, companies, destroy_page, ensure_group, company_root, sort_menu, blocks, page_tree, nb_json
from build_overview import apply_page, record

TITLE = '财务数据'
ICON = 'TableOutlined'
KEY = 'finstmt'

JS = r"""
  const React = ctx.libs.React;
  const { Table, Segmented, Select, Space, Typography } = ctx.libs.antd;
  const { Text } = Typography;
  const COMPANY = '__COMPANY__';
  const ROLE = __ROLE__;          // 表的一句话定位（spec.role_line）
  const STMTS = ['资产负债表', '利润表', '现金流量表'];
  const BOLD = /(合计|总计|小计|毛利|净利润|净资产|净增加额|现金净额|溢利|利润总额|营业利润|营业总收入|营业总成本|总资产|总负债|总权益|经营业务现金净额|经营活动产生的现金流量净额|期初现金|期末现金)$/;
  const get = async (url, params) => (await ctx.request({ url, params }))?.data?.data;
  const listOf = async (name, params = {}) => (await get(`${name}:list`, { pageSize: 2000, ...params })) || [];
  const fetchAll = async (filter) => {
    const rows = [];
    for (let page = 1; ; page += 1) {
      const batch = await listOf('vi_fin_stmt', { filter: JSON.stringify(filter), sort: 'period_end', page, pageSize: 2000 });
      rows.push(...batch);
      if (batch.length < 2000) break;
    }
    return rows;
  };
  const cos = await listOf('vi_company', { filter: JSON.stringify({ code: { $eq: COMPANY } }) });
  if (!cos.length) {
    ctx.render(<Text type="danger">未找到公司 {COMPANY}</Text>);
    return;
  }
  const coId = cos[0].id;
  const [bsRows, isRows, cfRows] = await Promise.all(STMTS.map((s) => fetchAll({ company_id: { $eq: coId }, stmt: { $eq: s } })));
  const ROWS = { '资产负债表': bsRows, '利润表': isRows, '现金流量表': cfRows };

  const round6 = (v) => Math.round(v * 1e6) / 1e6;
  const fmt = (v) => {
    if (v === null || v === undefined) return '';
    const d = Math.abs(v) >= 1 ? 2 : 4;
    return v.toLocaleString('zh-CN', { minimumFractionDigits: d, maximumFractionDigits: d });
  };
  // 矩阵：行＝科目（按行次），列＝报告期（新→旧）。single＝单季：本年相邻报告期累计之差；Q1 即累计，中间期缺失则留空。
  const matrix = (rows, single) => {
    const perDate = {}, seqOf = {}, cum = {};
    for (const r of rows) {
      perDate[r.period] = r.period_end;
      if (!(r.item in seqOf) || r.seq < seqOf[r.item]) seqOf[r.item] = r.seq;
      cum[`${r.item}|${r.period}`] = r.amount;
    }
    const periods = Object.keys(perDate).sort((a, b) => (perDate[a] < perDate[b] ? 1 : -1));
    const items = Object.keys(seqOf).sort((a, b) => seqOf[a] - seqOf[b]);
    const prevOf = (p) => {
      const y = p.slice(0, 4), q = Number(p.slice(5));
      return q > 1 ? `${y}Q${q - 1}` : null;
    };
    const value = (item, p) => {
      const v = cum[`${item}|${p}`];
      if (v === undefined) return null;
      if (!single) return v;
      const pp = prevOf(p);
      if (!pp) return v;
      const base = cum[`${item}|${pp}`];
      return base === undefined ? null : round6(v - base);
    };
    return { periods, items, perDate, value };
  };

  const Page = () => {
    const [stmt, setStmt] = React.useState(STMTS[0]);
    const [single, setSingle] = React.useState(false);
    const [win, setWin] = React.useState(12);
    const isFlow = stmt !== '资产负债表';
    const on = single && isFlow;
    const m = matrix(ROWS[stmt], on);
    const shown = m.periods.slice(0, win > 0 ? win : undefined);
    const columns = [
      { title: '科目', dataIndex: 'item', fixed: 'left', width: 230,
        render: (v) => <span style={{ fontWeight: BOLD.test(v) ? 600 : 400 }}>{v}</span> },
      ...shown.map((p) => ({
        title: (<div style={{ textAlign: 'center', lineHeight: 1.3 }}>
          <div>{p}</div>
          <div style={{ fontSize: 11, color: '#999' }}>{m.perDate[p]}{m.perDate[p].slice(5) === '12-31' ? ' 年报' : ''}</div>
        </div>),
        dataIndex: p, align: 'right', width: 118,
        render: (v) => fmt(v),
      })),
    ];
    const dataSource = m.items.map((item) => {
      const row = { key: item, item };
      for (const p of shown) row[p] = m.value(item, p);
      return row;
    });
    return (
      <div>
        <div style={{ marginBottom: 10 }}><Text type="secondary">{ROLE}</Text></div>
        <Space wrap style={{ marginBottom: 10 }}>
          <Segmented value={stmt} onChange={setStmt} options={STMTS} />
          <Segmented value={on ? '单季' : '累计'} onChange={(v) => setSingle(v === '单季')} options={isFlow ? ['累计', '单季'] : ['累计']} />
          <Select value={win} onChange={setWin} style={{ width: 108 }}
            options={[4, 8, 12, 20].map((n) => ({ label: `近${n}期`, value: n })).concat([{ label: '全部', value: 0 }])} />
          <Text type="secondary">金额单位：亿元。利润表/现金流量表为年初至报告期末累计；「单季」＝本年相邻报告期累计之差（Q1 即累计）。空白＝该期未披露。</Text>
        </Space>
        <Table columns={columns} dataSource={dataSource} pagination={false} bordered size="small" scroll={{ x: 'max-content' }} />
        <Text type="secondary" style={{ fontSize: 12 }}>
          数据源：akshare（A 股＝新浪财报，港股＝东方财富港股报表）；取数、检验与口径见 framework/tools/fin_stmt.py，表代码 fin_stmt。
        </Text>
      </div>
    );
  };
  ctx.render(<Page />);
"""


def script(co):
    role = spec.role_line(spec.all_tables()['fin_stmt'])
    return JS.replace('__COMPANY__', co['code']).replace('__ROLE__', json.dumps(role, ensure_ascii=False))


def update(co):
    uid = next(b['uid'] for b in blocks(page_tree(f"{KEY}@{co['code']}")['tree']) if b.get('use') == 'JSBlockModel')
    nb_json('flow-surfaces', 'configure', '--target', json.dumps({'uid': uid}),
            '--changes', json.dumps({'code': script(co), 'version': 'v2'}, ensure_ascii=False))
    print(co['name'], TITLE, '脚本已更新')


def page_body(co, gid, has_supplement=False):
    """财务三表＋不重复的分部/补充口径；经营驱动在业务数据。"""
    body = {
        'page': {'title': TITLE, 'documentTitle': f"{co['name']} · {TITLE}"},
        'assets': {'scripts': {KEY: {'version': 'v2', 'code': script(co)}}},
        'tabs': [{'title': '财务报表', 'blocks': [{'key': KEY, 'type': 'jsBlock', 'script': KEY}]}]}
    if has_supplement:
        import build_pages as bp
        from align_companies import aligned_blueprint
        from data_domains import financial_supplement_scope
        b = aligned_blueprint('observation', '分部与财务补充', gid, co, scope=financial_supplement_scope(co))
        block = b['tabs'][0]['blocks'][0]
        meta = {f['name']: f for f in bp.live_fields('vi_observation')}
        rels = {f['name']: f for f in bp.T['observation']['fields'] if f['kind'] in ('m2o','m2m')}
        from page_style import column_settings
        fields = ['metric','period','basis','value','unit','yoy','summary','doc']
        block['fields'] = [dict(bp.rel_popup(rels[f]) if f in rels else {'field': f}, settings=column_settings(meta[f])) for f in fields]
        block['settings']['description'] = '三大报表里没有的财务数：分部收入与利润率、公司口径的现金与调整后利润等。报表里有的科目（收入、利润、毛利率、应收、负债等）由「指标」按报表公式直接算，不另存。合同额、销量、用户和设备数见「业务数据」。'
        body['defaults'] = b['defaults']
        body['tabs'].append({'title': '分部与财务补充', 'blocks': [block]})
        body['page']['enableTabs'] = True
    return body


def has_financial_supplement(co):
    conditions = [{'company_id': {'$eq': co['id']}}, {'category': {'$eq': '财务'}}, {'source_kind': {'$ne': '报表计算'}}]
    return bool(nb_json('resource','list','--resource','vi_metric','--filter',json.dumps({'$and': conditions}), '--page-size','1')['data'])


def create(co):
    st = state()
    gid = ensure_group(st, f"{co['name']}/数据底稿", '数据底稿', 'DatabaseOutlined', parent=company_root(st, co))
    apply_page(f"{KEY}_{co['code']}", {
        'version': '1', 'mode': 'create',
        'navigation': {'group': {'routeId': gid}, 'item': {'title': TITLE, 'icon': ICON}},
        **page_body(co, gid, has_supplement=has_financial_supplement(co))})
    record(f"{KEY}@{co['code']}", gid, TITLE)


if __name__ == '__main__':
    if '--update' in sys.argv:                   # 只换脚本：页面和菜单都不动
        for co in companies():
            update(co)
        sys.exit()
    for co in companies():
        k = f"{KEY}@{co['code']}"
        if '--rebuild' in sys.argv:
            destroy_page(k)
        if k not in state()['pages']:
            create(co)
    sort_menu()
    print('完成')
