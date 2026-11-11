"""事项详情弹窗：点开「经营与财务 / 定性事实 / 事项」的一行，看事项的名称、简介，以及挂在它下面的各个侧面（定性事实）的时间线。
侧面只读展示（日期、核验状态、陈述、来源）；新增或修改侧面在同页的“全部事实”标签，选“所属事项”即可挂上来。
"""

JS = r"""const { React } = ctx.libs;
const { Timeline, Tag, Typography, Empty, Alert, Space, theme } = ctx.libs.antd;
const { Text, Paragraph } = Typography;
const VERIFY = { 已核验: 'green', 待核验: 'orange', 建议值待核验: 'gold' };

function Facets({ event, facts }) {
  const { token } = theme.useToken();
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
      <div>
        <Space wrap>
          <span style={{ fontSize: 18, fontWeight: 600 }}>{event.name}</span>
          {event.status ? <Tag color={event.status === '已完成' ? 'default' : event.status === '待观察' ? 'gold' : 'blue'}>{event.status}</Tag> : null}
          {event.period ? <Text type="secondary">{event.period}</Text> : null}
          {event.category ? <Tag>{event.category}</Tag> : null}
        </Space>
        {event.summary ? <Paragraph style={{ marginTop: 8, marginBottom: 0, lineHeight: 1.8 }}>{event.summary}</Paragraph> : null}
      </div>
      <div style={{ fontSize: 13, fontWeight: 600, borderTop: `1px solid ${token.colorSplit}`, paddingTop: 12 }}>
        各个侧面（{facts.length} 条，按截至日期排列；新增或修改到“全部事实”标签，选“所属事项”）
      </div>
      {facts.length === 0 ? <Empty description="还没有挂侧面" /> : (
        <Timeline items={facts.map((f) => ({
          color: VERIFY[f.verify_status] || 'gray',
          label: <span style={{ whiteSpace: 'nowrap' }}>{f.as_of || f.period || '—'}</span>,
          children: (
            <div>
              <Space wrap size={6}>
                <span style={{ fontWeight: 600 }}>{f.title}</span>
                {f.verify_status ? <Tag color={VERIFY[f.verify_status]}>{f.verify_status}</Tag> : null}
              </Space>
              <div style={{ marginTop: 4, lineHeight: 1.8 }}>{f.statement}</div>
              {f.source?.title ? <div style={{ fontSize: 12, color: token.colorTextTertiary, marginTop: 2 }}>来源：{f.source.title}</div> : null}
            </div>
          ),
        }))} mode="left" />
      )}
    </div>
  );
}

try {
  const rec = await ctx.getVar('ctx.popup.record');
  const id = rec?.id;
  if (!id) {
    ctx.render(<Alert type="info" showIcon message="没有拿到事项" />);
  } else {
    const get = async (url, params) => (await ctx.request({ url, params }))?.data?.data;
    const [event] = (await get('vi_event:list', { filter: JSON.stringify({ id: { $eq: id } }), pageSize: 1 })) || [rec];
    const facts = (await get('vi_fact:list', { filter: JSON.stringify({ event_id: { $eq: id } }), appends: ['source'],
                                               sort: ['as_of', 'id'], pageSize: 500 })) || [];
    ctx.render(<Facets event={event || rec} facts={facts} />);
  }
} catch (error) {
  ctx.render(<Alert type="error" showIcon message="事项读取失败" description={String(error?.message || error)} />);
}
"""


def view_action(page_title):
    """表格行的“查看”：事项简介与侧面时间线（脚本区块）。"""
    return {'type': 'view', 'popup': {'title': f'{page_title} · 事项', 'blocks': [
        {'key': 'facets', 'type': 'jsBlock', 'script': 'event_facets'}]}}


ASSETS = {'scripts': {'event_facets': {'version': 'v2', 'code': JS}}}
