"""「框架与后台 / 估值地基：Greenwald 三层价值」——理论基础，以及据此设计的估值看板与底层数据结构（2026-11-09；11-10 重排 UI）。

  python3 framework/greenwald_doc.py     # 新建或原地更新页面（地址不变）

只是说明页：不读任何表。内容写在下面的 JS 里（React＋antd，跟随亮色/暗色主题）。
"""
import build_overview as overview
import build_pages as bp

KEY, TITLE, ICON = 'doc_greenwald', '估值地基：Greenwald 三层价值', 'BankOutlined'

JS = r"""const { React } = ctx.libs;
const { Card, Row, Col, Tag, Typography, Table, Space, Collapse, theme } = ctx.libs.antd;
const { Title, Paragraph, Text } = Typography;

function Section({ n, title, sub, children }) {
  const { token } = theme.useToken();
  return (
    <div style={{ marginTop: 48 }}>
      <div style={{ display: 'flex', alignItems: 'baseline', gap: 12, marginBottom: 4 }}>
        <span style={{ fontSize: 13, fontWeight: 600, color: token.colorPrimary, letterSpacing: 1 }}>{n}</span>
        <Title level={4} style={{ margin: 0 }}>{title}</Title>
      </div>
      {sub && <Paragraph type="secondary" style={{ marginBottom: 16, maxWidth: 820 }}>{sub}</Paragraph>}
      {children}
    </div>
  );
}

function Principle({ title, tag, children }) {
  return (
    <Card size="small" style={{ height: '100%' }}>
      <Space size={6} wrap>
        <Text strong style={{ fontSize: 15 }}>{title}</Text>
        {tag && <Tag>{tag}</Tag>}
      </Space>
      <Paragraph type="secondary" style={{ margin: '6px 0 0' }}>{children}</Paragraph>
    </Card>
  );
}

function Formula({ children, note }) {
  const { token } = theme.useToken();
  return (
    <div style={{ background: token.colorFillQuaternary, border: `1px solid ${token.colorBorder}`, borderRadius: 10, padding: '16px 20px', margin: '14px 0' }}>
      <div style={{ fontSize: 17, fontWeight: 600, textAlign: 'center', lineHeight: 1.6 }}>{children}</div>
      {note && <Text type="secondary" style={{ fontSize: 13, display: 'block', textAlign: 'center', marginTop: 8 }}>{note}</Text>}
    </div>
  );
}

function Flow({ steps }) {
  const { token } = theme.useToken();
  return (
    <div style={{ display: 'flex', flexWrap: 'wrap', alignItems: 'center', gap: 8, margin: '14px 0' }}>
      {steps.map((s, i) => (
        <React.Fragment key={i}>
          {i > 0 && <span style={{ color: token.colorTextSecondary, fontSize: 16 }}>→</span>}
          <span style={{ background: token.colorFillQuaternary, border: `1px solid ${token.colorBorder}`, borderRadius: 8, padding: '7px 13px', fontSize: 14 }}>{s}</span>
        </React.Fragment>
      ))}
    </div>
  );
}

function Stat({ items }) {
  const { token } = theme.useToken();
  return (
    <Row gutter={[12, 12]} style={{ margin: '14px 0' }}>
      {items.map(([v, k], i) => (
        <Col xs={12} md={6} key={i}>
          <div style={{ background: token.colorFillQuaternary, borderRadius: 10, padding: '14px 16px', height: '100%' }}>
            <div style={{ fontSize: 21, fontWeight: 700 }}>{v}</div>
            <Text type="secondary" style={{ fontSize: 13 }}>{k}</Text>
          </div>
        </Col>
      ))}
    </Row>
  );
}

function Callout({ title, strong, children }) {
  const { token } = theme.useToken();
  return (
    <div style={{ borderLeft: `4px solid ${strong ? token.colorWarning : token.colorPrimary}`, background: token.colorFillQuaternary, borderRadius: 8, padding: '12px 16px', margin: '14px 0' }}>
      {title && <Text strong style={{ fontSize: 15 }}>{title}</Text>}
      <div style={{ marginTop: title ? 6 : 0 }}>{children}</div>
    </div>
  );
}

// 三层：宽度越窄越靠上，表示越不可靠
const LAYERS = [
  { name: '③ 增长价值', reliab: '最不可靠', color: 'colorSuccess', width: 62,
    basis: '对未来增长的预测',
    how: '只有新增投资的回报高于资本成本时才有价值；没有进入壁垒，不能假定增长持续创造超额价值。',
    adj: '增长率、新增资本回报、壁垒能持续多久。' },
  { name: '② 经营盈利能力价值', reliab: '较可靠', color: 'colorPrimary', width: 81,
    basis: '今天可持续的盈利（不增长）',
    how: '正常化可持续税后经营收益 ÷ WACC；先算经营价值，非经营资产与融资债务另行汇总。',
    adj: '周期取平均利润率；折旧换成维持性资本开支；为增长而花的营销、研发加回；剔除一次性项目。' },
  { name: '① 经营资产价值', reliab: '通常较可靠，取决于资产', color: 'colorTextSecondary', width: 100,
    basis: '经营资产与经营负债的报表底稿',
    how: '行业值得做：重置成本——新进入者重建这门生意要花多少；行业不值得做：清算价值。',
    adj: '逐项调整经营资产，减经营负债；商誉不照搬，分析背后实际资产；未入账无形资产有证据才估。' },
];

function Layers() {
  const { token } = theme.useToken();
  return (
    <Space direction="vertical" style={{ width: '100%' }} size={10}>
      {LAYERS.map((l) => (
        <div key={l.name} style={{ display: 'flex', justifyContent: 'center' }}>
          <div style={{ width: `${l.width}%`, minWidth: 300, borderRadius: 10, padding: '14px 18px',
            background: token.colorFillQuaternary, borderLeft: `5px solid ${token[l.color]}` }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', flexWrap: 'wrap', gap: 8 }}>
              <Text strong style={{ fontSize: 16 }}>{l.name}</Text>
              <Space size={6}><Tag>{l.basis}</Tag><Tag color={l.name.startsWith('①') ? 'default' : l.reliab === '较可靠' ? 'blue' : 'green'}>{l.reliab}</Tag></Space>
            </div>
            <Paragraph style={{ margin: '8px 0 4px' }}>{l.how}</Paragraph>
            <Text type="secondary" style={{ fontSize: 13 }}>关键调整：{l.adj}</Text>
          </div>
        </div>
      ))}
    </Space>
  );
}

const COMPARE = [
  { k: '盈利能力价值 ≈ 资产价值', t: '未显示显著超额回报', tag: 'default',
    d: '可能处于竞争均衡：资本回报接近资本成本。需核实估计误差，不能只凭接近就断定没有壁垒。',
    act: '核实竞争均衡与资产计价，转换为股权价值后再比较价格。' },
  { k: '盈利能力价值 ＞ 资产价值', t: '需要核实壁垒', tag: 'blue',
    d: '差额可能反映壁垒，也可能来自周期高点、资产估计偏低或优秀管理。必须另有进入壁垒与持续性的证据。',
    act: '核实壁垒持续性；转换为股权口径后评价价格与安全边际。' },
  { k: '盈利能力价值 ＜ 资产价值', t: '资产没被用好', tag: 'orange',
    d: '资产赚不到资本成本：管理层配置资本不当，或行业产能过剩。',
    act: '看是否有改变的力量（管理层更换、行业出清、资产处置）；否则价值向盈利能力价值靠拢。' },
];

function Compare() {
  return (
    <Row gutter={[16, 16]}>
      {COMPARE.map((c) => (
        <Col xs={24} md={8} key={c.k}>
          <Card size="small" style={{ height: '100%' }}>
            <Text strong>{c.k}</Text>
            <div style={{ margin: '6px 0' }}><Tag color={c.tag}>{c.t}</Tag></div>
            <Paragraph style={{ marginBottom: 6 }}>{c.d}</Paragraph>
            <Text type="secondary" style={{ fontSize: 13 }}>怎么做：{c.act}</Text>
          </Card>
        </Col>
      ))}
    </Row>
  );
}

// 增长的价值：相对盈利能力价值的倍数＝R×(1−g÷ROC)÷(R−g)，R＝6%
function GrowthTable() {
  const R = 0.06;
  const mult = (g, roc) => (R * (1 - g / roc)) / (R - g);
  const cases = [
    ['回报低于资本成本', 0.03, 0.04], ['回报等于资本成本', 0.03, 0.06],
    ['回报是资本成本的 2 倍', 0.03, 0.12], ['回报是资本成本的 4 倍', 0.03, 0.24],
  ];
  const rows = cases.map(([k, g, roc], i) => ({ key: i, k, g: (g * 100).toFixed(0) + '%', roc: (roc * 100).toFixed(0) + '%', m: mult(g, roc) }));
  return (
    <Row gutter={[24, 16]} align="middle">
      <Col xs={24} md={10}>
        <Card size="small">
          <Text type="secondary">含增长的价值</Text>
          <div style={{ fontSize: 18, margin: '6px 0', fontFamily: 'Georgia, serif' }}>税后利润 × (1 − g ÷ ROC) ÷ (R − g)</div>
          <Text type="secondary" style={{ fontSize: 13 }}>
            g＝增长率，ROC＝新增资本的回报，R＝经营口径的 WACC。要增长 g，每年要把 g÷ROC 的利润再投进去；ROC＝R 时公式退回到 税后利润÷R，增长一分不值。
          </Text>
        </Card>
      </Col>
      <Col xs={24} md={14}>
        <Table size="small" pagination={false} dataSource={rows}
          columns={[{ title: '情形（示例 WACC 6%）', dataIndex: 'k' }, { title: '增长', dataIndex: 'g', align: 'right' },
                    { title: '新增资本回报', dataIndex: 'roc', align: 'right' },
                    { title: '价值 ÷ 盈利能力价值', dataIndex: 'm', align: 'right',
                      render: (v) => <Text strong type={v < 1 ? 'danger' : v > 1.01 ? 'success' : undefined}>{v.toFixed(2)} 倍</Text> }]} />
      </Col>
    </Row>
  );
}

const BARRIERS = [
  ['供给侧优势', '别人拿不到的成本：专有技术、专利、独占资源', '成本优势、工艺与组织、数据与算法'],
  ['需求侧优势（客户锁定）', '习惯、转换成本、搜寻成本让客户不走；品牌只有带来锁定时才算', '转换成本、品牌与定价权'],
  ['规模经济＋客户锁定', '最强、最持久：有锁定的客户才守得住规模带来的成本优势；网络效应是需求侧的规模经济', '规模经济、网络效应、生态与渠道'],
  ['政府许可与管制', '牌照、特许经营、独占的资源与准入限制', '牌照与资源'],
];

const WIRE = [
  { span: 24, title: '① 股价对应哪种价值', body: '前三层分别展示同口径股权价值，以同一市值为参照。记录主估值、选择依据及证据不足的项目。' },
  { span: 8, title: '② 壁垒诊断', body: '以独立证据判断壁垒，不默认用 EPV 减净资产或清算净值计算壁垒价值；可靠经营重建 AV 仅作为可选专项比较。' },
  { span: 8, title: '③ 回报拆解', body: '从当前买入价出发，估计持有期内每股实际可获得的现金分配和期末每股股权价值，据此计算年化回报，与股权回报门槛比较。' },
  { span: 8, title: '④ 情景', body: '悲观、基准、乐观情景分别展示经营价值、独立资产净调整、融资与权益调整、股权价值及回报。有依据的情景概率可用于加权展示。' },
  { span: 8, title: '⑤ 资产价值明细', body: '账面经营资产及经营负债→存货、应收及相关义务核查→调整后净经营资产。清算和重建按需研究。' },
  { span: 8, title: '⑥ 经营盈利能力明细', body: '融资前经营 EBIT → 扣正常经营税负得 NOPAT → 加回折旧摊销、扣维持性资本开支及必要营运资本增加 → 无增长经营现金流 ÷ WACC。正常化时剔除独立资产收益，逐项展示依据。' },
  { span: 8, title: '⑦ 增长与壁垒', body: '从经营 EPV 出发，按再投资规模、增量回报和优势持续期估计增长价值，展示正、零或负的增量。超额回报的持续期需有壁垒证据支持。' },
];

function Wireframe() {
  const { token } = theme.useToken();
  return (
    <div style={{ border: `1px dashed ${token.colorBorder}`, borderRadius: 12, padding: 16 }}>
      <Row gutter={[12, 12]}>
        {WIRE.map((w) => (
          <Col xs={24} md={w.span} key={w.title}>
            <div style={{ background: token.colorFillQuaternary, borderRadius: 8, padding: '12px 14px', height: '100%' }}>
              <Text strong>{w.title}</Text>
              {w.title.startsWith('①') && (
                <div style={{ marginTop: 10 }}>
                  <Paragraph style={{ marginBottom: 8 }}>示例，单位为亿元。当前市值 95，三行均为同日、同范围的普通股股权价值。</Paragraph>
                  <Table size="small" pagination={false} rowKey={(r) => r[0]} dataSource={[
                    ['第一层 · 净经营资产重估', '100', '检查资产质量与实现条件'],
                    ['第二层 · 无增长经营价值', '80', '主估值。以现有业务的可持续现金流为依据'],
                    ['第三层 · 含增长经营价值', '120', '相对第二层增加 40，取决于再投资假设'],
                  ]} columns={[{ title: '估值口径', render: (_, r) => r[0] },
                                { title: '股权价值', render: (_, r) => r[1] },
                                { title: '采用依据或用途', render: (_, r) => r[2] }]} />
                </div>
              )}
              <Paragraph type="secondary" style={{ margin: '4px 0 0', fontSize: 13 }}>{w.body}</Paragraph>
            </div>
          </Col>
        ))}
      </Row>
    </div>
  );
}

const DATA = [
  { key: 1, layer: '共用范围与底稿', tables: '估值版本、估值单元、经营与独立项目的归属。关联财报、附注、研究依据、估值日及币种。', why: '前三层共享业务范围。资产、负债及对应收益、现金流可逐项核对。' },
  { key: 2, layer: '① 净经营资产重估', tables: '经营资产、经营负债及调整明细。记录账面净额、调整、证据与区间。', why: '独立资产归入独立计价明细，融资债务归入股权汇总。清算和重建按需开展。' },
  { key: 3, layer: '② 无增长经营价值', tables: '正常化收入与经营费用、融资前 EBIT、正常税负、折旧摊销、维持性资本开支、必要营运资本变化、WACC。', why: '以历史和经营证据估计可持续水平，使用无增长口径资本化。' },
  { key: 4, layer: '③ 含增长经营价值', tables: '引用第二层的经营 EPV，关联增长情景、再投资、增量资本回报及优势持续期。', why: '独立记录增长假设和正负价值增量。增长假设仅用于含增长估值。' },
  { key: 5, layer: '独立资产净调整', tables: '独立投资、多余现金、非经营物业及相关税费、限制和义务。', why: '记录所持权益的净估值及对应收益剥离位置，供股权汇总引用。' },
  { key: 6, layer: '融资与其他权益调整', tables: '有息债务、租赁、优先权益、少数股东等。记录计价、归属和处理位置。', why: '和独立资产净调整一起将经营价值转换为普通股股权价值，逐项核对计入次数。' },
  { key: 7, layer: '估值结果与总览', tables: '按估值版本、情景和层次保存结果。记录股权价值、每股价值、同日市值、主估值及依据。', why: 'WACC 用于经营估值，股权回报门槛用于持有回报判断。两者分别设置。' },
];

const STEPS = [
  ['先统一经营范围', '核对经营资产与负债、独立资产及对应收益、融资和权益归属。'],
  ['建立净经营资产与无增长盈利底稿', '逐项核对报表，估计正常经营水平、维持性投入及 WACC。'],
  ['核对股权价值汇总', '选代表性公司核对经营价值、独立资产净调整、债务与其他权益。'],
  ['接入增长情景与估值总览', '引用无增长基准，测算增长增量与持有回报，展示主估值及其依据。'],
  ['核对新旧结果与引用关系', '确认历史数据、驾驶舱和自动检查的引用后，再评估旧表的归档安排。'],
];

function Page() {
  const { token } = theme.useToken();
  return (
    <div style={{ maxWidth: 1080, margin: '0 auto', padding: '8px 4px 32px' }}>
      <Card style={{ background: token.colorFillQuaternary }}>
        <Text type="secondary">借鉴 Greenwald 的实践框架 · 资产基础＋盈利能力＋增长＋独立资产与股权汇总</Text>
        <Title level={2} style={{ margin: '6px 0 10px' }}>估值的地基：Greenwald 三层价值</Title>
        <Paragraph style={{ marginBottom: 8 }}>前三层统一估经营业务：第一层重估净经营资产，第二层估现有业务的无增长盈利价值，第三层估含增长的经营价值。第4节单独估计非经营资产及其他独立计价项目，第5节将选定的经营价值转换为股权价值。</Paragraph>
        <Space size={6} wrap>
          <Tag color="blue">AV 与 EPV 是比较关系，不能相加</Tag>
          <Tag color="green">含增长的经营价值＝EPV＋增长价值</Tag>
          <Tag>三层按信息基础组织，越靠上越不可靠</Tag>
        </Space>
        <Paragraph type="secondary" style={{ margin: '10px 0 0' }}>不保证第一层对所有企业都最可靠，也不要求每家企业都能得到三个可信数字。各层统一估值日、币种、业务范围及归属口径；适用于普通非金融企业。</Paragraph>
      </Card>

      <div style={{ marginTop: 24 }}>
        <Layers />
        <Paragraph type="secondary" style={{ textAlign: 'center', marginTop: 10, marginBottom: 0 }}>
          前三层使用同一业务范围。先看资产质量与无增长盈利，再检验增长假设。
        </Paragraph>
      </div>

      <Section n="01" title="第一层：净经营资产重估" sub="按相同业务范围识别经营资产和经营负债，对重要项目逐项“挤水分”。有行业证据时，可另估经营资产重建成本。">
        <Callout title="定位：报表提供起点，研究判断决定调整">
          <Paragraph style={{ margin: 0 }}>从报表和附注提取属于估值业务的资产与负债。经营必需现金、应收、存货和自用资产等纳入经营范围，多余现金和独立计价投资归入第4节，融资债务和其他权益归入第5节。检查回收、减值和遗漏的经营义务，优先核实影响结论的项目。</Paragraph>
        </Callout>
        <Formula>调整后净经营资产 ＝ 重估后的经营资产 − 调整后的经营负债</Formula>

        <Title level={5} style={{ marginTop: 24 }}>两个角度检测 AV</Title>
        <Row gutter={[16, 16]}>
          <Col xs={24} md={12}>
            <Card size="small" style={{ height: '100%', borderLeft: `4px solid ${token.colorPrimary}` }}>
              <Space size={6} wrap><Text strong style={{ fontSize: 15 }}>A 资产质量检查</Text><Tag color="blue">默认</Tag><Tag>经营口径</Tag></Space>
              <Paragraph style={{ margin: '8px 0 4px' }}><Text strong>怎么测：</Text>从账面经营资产和经营负债出发，逐项检查回收、过时及遗漏义务。</Paragraph>
              <Paragraph type="secondary" style={{ margin: 0 }}>回答“现有业务占用的净经营资产值多少”。估计可用于检查资产质量和盈利能力，必要时展示区间。</Paragraph>
            </Card>
          </Col>
          <Col xs={24} md={12}>
            <Card size="small" style={{ height: '100%', borderLeft: `4px solid ${token.colorSuccess}` }}>
              <Space size={6} wrap><Text strong style={{ fontSize: 15 }}>B 重建成本（进入成本）</Text><Tag color="green">按需</Tag><Tag>经营口径 · 向前看</Tag></Space>
              <Paragraph style={{ margin: '8px 0 4px' }}><Text strong>怎么测：</Text>今天一个理性的进入者建起同等竞争地位要花多少、能否收回。</Paragraph>
              <Paragraph type="secondary" style={{ margin: 0 }}>回答“这门生意从零做要花多少”。有可比项目、单位产能投入或交易证据时可估。与同范围经营 EPV 的差额可用于检验竞争优势。</Paragraph>
            </Card>
          </Col>
        </Row>
        <Callout>
          A 衡量现有资产，B 衡量进入所需投入。两项估计可互相参照，各自列明依据和范围。对于难以重建的能力，记录可核实的进入限制及其盈利影响。
        </Callout>
        <Callout title="资产与收益采用同一范围">
          经营权利、预付和使用权资产按实际用途及合同条款判断。经营 EPV 同时反映使用这些资产所需的维持性投入、租金或分成，并与租赁负债的处理保持一致。
        </Callout>

        <Title level={5} style={{ marginTop: 24 }}>重点科目：不只看主表余额，还看附注、质量和约束</Title>
        <Table size="small" pagination={false} rowKey={(r) => r[0]} dataSource={[
          ['现金、存款及理财', '按经营用途识别必要现金和相关受限资金。可独立计价的多余现金、存款和理财转入第4节。'],
          ['应收账款、票据及合同资产', '检查账龄、逾期、偿付能力、结算争议、期后回款、质保金及保理追索。以账面净额为起点，只对计提不足调整，避免重复扣坏账。'],
          ['其他应收、预付款与长期应收', '穿透关联方占款、保证金、项目垫款、预付土地设备款，核实交易实质与回收能力；长期回收必要时考虑时间价值。'],
          ['存货及房地产开发项目', '拆分原料、在产品、成品、土地与开发项目；查库龄、滞销、售价、跌价准备。地产结合剩余建设、销售税费和交付义务，已计负债不重复扣。'],
          ['投资与物业的归属', '按实际用途和估值范围分类。独立估值的持股、基金、金融资产及物业转入第4节，并从对应业务收益中剥离。'],
          ['固定资产、在建工程及使用权资产', '检查闲置、低效产能、技术淘汰、工程停滞、剩余寿命、抵押及后续投入；使用权资产与租赁义务配套处理。'],
          ['土地、投资性房地产及持有待售资产', '核对权属、用途、处置条件、市场参照及税费；成本计价与公允价值计价分清，升值需有证据和实现条件。'],
          ['商誉、无形资产及资本化支出', '检查并购预期是否兑现，技术、版权、许可是否过时或到期。商誉不机械全额保留或扣除；有形净资产可另列参考。'],
          ['递延所得税资产及其他资产', '核实未来应税利润能否支持抵扣、到期限制与兑现时间；穿透其他资产，识别低质量、重复或缺乏经济实质的余额。'],
          ['经营应付款、预计负债及经营义务', '核查应付账款、合同负债、亏损合同及修复义务。融资债务、独立遗留义务和其他权益按归属转入第4或第5节。'],
        ]} columns={[{ title: '科目或项目', render: (_, r) => <Text strong>{r[0]}</Text>, width: 220 }, { title: '研究与调整重点', render: (_, r) => r[1] }]} />

        <Title level={5} style={{ marginTop: 24 }}>操作原则：有依据、有区间、能核对</Title>
        <Row gutter={[16, 16]}>
          <Col xs={24} md={8}><Principle title="留痕">每项保留账面原值、已计提准备、账面净值、研究估计、增减调整、归属比例、证据和日期。</Principle></Col>
          <Col xs={24} md={8}><Principle title="区间">信息不足标为待核实或给出区间，不用任意统一折扣制造精确结果；升值或低估需有依据，实现条件单列。</Principle></Col>
          <Col xs={24} md={8}><Principle title="联动">重估涉及所得税与处置税费时检查联动；与第二、三层已处理的损失对上号，避免同一影响重复计价。</Principle></Col>
          <Col xs={24} md={12}><Principle title="从账面股权净资产对账">如以账面股权净资产核对，先剥离非经营净资产，再加回已扣除的融资债务及其他相关索取权，统一合并范围。经营资产和经营负债的重估以逐项明细为准。</Principle></Col>
          <Col xs={24} md={12}><Principle title="估算方法按实务选择">可用回收分析、项目净值、市场交易、持续使用价值等证据，标明估计前提。清算与重建成本专项均非默认必填。</Principle></Col>
        </Row>
        <Callout title="口径结论" strong>
          本框架默认以净经营资产重估检查资产质量。与经营 EPV 比较时，差异可提示资产使用效率和盈利质量。检验 Greenwald 所说的竞争优势时，参考同范围的经营重建成本，并结合独立的壁垒证据。
        </Callout>
        <Paragraph type="secondary">例如中国建筑，可优先研究应收与合同资产计提、地产存货、项目资金限制与履约义务；央企身份等难以复制的条件不强行折算成资产。</Paragraph>
      </Section>

      <Section n="02" title="第二层：经营盈利能力价值 EPV" sub="现有业务不增长，维持经营能力后可持续产生的税后经营收益，按加权平均资本成本 WACC 资本化。最终结果是经营价值金额，不是 EBIT。">
        <Flow steps={['正常化经营 EBIT（未扣息）', '扣正常经营税负 → NOPAT', '折旧换成维持性资本开支', '无增长可持续现金收益', '÷ WACC → 经营 EPV']} />
        <Stat items={[['100 亿', '正常化 EBIT／年'], ['75 亿', '税负 25% 后的可持续税后收益'], ['8%', '示例 WACC'], ['937.5 亿', '经营 EPV ＝ 75 ÷ 8%']]} />
        <Text type="secondary">示意：折旧等于维持性资本支出、无其他调整。独立非经营资产和融资债务在后面处理。</Text>

        <Title level={5} style={{ marginTop: 24 }}>先分清利润口径：税后，不等于扣息后</Title>
        <Table size="small" pagination={false} rowKey={(r) => r[0]} dataSource={[
          ['经营 EBIT', '扣除经营成本、费用和折旧摊销，尚未扣融资利息及所得税。资本开支通常先形成资产，不直接全额扣进 EBIT。'],
          ['税后经营利润 NOPAT', '经营 EBIT 扣正常经营税负，仍未扣融资利息。简化式为 EBIT×(1−税率)，不是报表净利润。'],
          ['报表净利润', '通常已扣融资利息和所得税，还可能含投资收益等非经营项目；不能直接除以 WACC 当作经营 EPV。'],
          ['EPV 收益基础', '正常化 NOPAT 加回折旧摊销，扣维持性资本开支及必要的正常营运资本增加——维持现有经营能力后的现金收益。'],
        ]} columns={[{ title: '名称', render: (_, r) => <Text strong>{r[0]}</Text>, width: 200 }, { title: '含义', render: (_, r) => r[1] }]} />

        <Callout title="利息与税：一个简化例子">
          <Flow steps={['经营 EBIT 100', '利息 20 → 税前 80', '税 20 → 净利 60', 'NOPAT ＝ 100×(1−25%) ＝ 75']} />
          <Paragraph strong style={{ margin: '4px 0' }}>从净利润还原：60 ＋ 20×(1−25%) ＝ 75——加回税后利息 15，而非税前利息 20。</Paragraph>
          <Paragraph type="secondary" style={{ margin: 0 }}>融资方式的影响由 WACC 与最终扣债务的匹配口径处理；实际企业需按税盾、合并归属及非经营收益调整，不能机械用归母净利润加集团利息。</Paragraph>
        </Callout>

        <Title level={5} style={{ marginTop: 24 }}>如何从报表取得经营 EBIT</Title>
        <Row gutter={[16, 16]}>
          <Col xs={24} md={12}><Principle title="从报表利润倒推" tag="常用">中国报表的“营业利润”已扣财务费用、可能含投资收益。识别并加回已扣的融资利息，剔除单独计价资产的收益；经营性手续费按性质保留。</Principle></Col>
          <Col xs={24} md={12}><Principle title="从毛利搭建" tag="分部清楚时">毛利 − 经营费用起步，未扣过的利息不再加回。财务费用附注核对利息支出、收入及资本化利息；无法可靠拆分的项目保留区间。</Principle></Col>
        </Row>

        <Title level={5} style={{ marginTop: 24 }}>从利润到现金收益，不是重新计算应税利润</Title>
        <Formula note="一般 FCFF 还扣增长投入，所以不等于当年实际 FCFF，也不等于扣息后的股东自由现金流。">
          EPV 收益基础 ≈ 正常化 NOPAT ＋ 折旧摊销 − 维持性资本开支 − 必要营运资本增加
        </Formula>
        <Callout>
          税后加回折旧只是还原非现金费用；资本开支的税收扣除通过税务折旧实现，不能把现金支出直接当作当期税前费用。会计与税务折旧不同时另行估税；不增长也不保证营运资本增加为零。
        </Callout>

        <Title level={5} style={{ marginTop: 20 }}>先正常化盈利，再资本化</Title>
        <Row gutter={[16, 16]}>
          <Col xs={24} md={12}><Principle title="正常化">周期业务取完整周期平均利润率；经常出现的“一次性”费用不能全剔；维持现有客户、产品与竞争地位的支出保留，增长性研发营销有依据才加回。</Principle></Col>
          <Col xs={24} md={12}><Principle title="口径一致">剔除单独估值资产的投资收益和利息收入，不扣融资利息。经营 EPV 使用 WACC；投资者的股权要求回报用于价格与回报决策，分别设置，不能互相替代。</Principle></Col>
        </Row>

        <Card size="small" style={{ marginTop: 16 }}>
          <Text strong style={{ fontSize: 15 }}>WACC：股权与债务的加权平均资本成本</Text>
          <Formula>WACC ＝ Ke × E/(D＋E) ＋ Kd × (1−T) × D/(D＋E)</Formula>
          <Flow steps={['股权 60% × Ke 10%', '债务 40% × Kd 4% × (1−25%)', 'WACC ＝ 7.2%']} />
          <Paragraph type="secondary" style={{ margin: 0 }}>Ke 是股东要求的回报，不是股息率；D 只含银行借款、债券等有息融资；T 为实际可利用的利息抵税税率，税盾不在收益中重复计算。收益与资本成本必须匹配；不同业务必要时分别估计 WACC。</Paragraph>
        </Card>

        <Title level={5} style={{ marginTop: 24 }}>多业务怎么算经营利润：本尊做法 vs 开发实际做法</Title>
        <Row gutter={[16, 16]}>
          <Col xs={24} md={12}>
            <Card size="small" style={{ height: '100%' }}>
              <Space size={6} wrap><Text strong style={{ fontSize: 15 }}>Greenwald 本尊：分部经营利润率</Text><Tag>前提苛刻</Tag></Space>
              <Paragraph style={{ margin: '8px 0 4px' }}>每个业务用<Text strong>各自的</Text>正常化经营利润率：业务收入 × 该业务的正常化经营利润率，逐业务计算后相加。</Paragraph>
              <Paragraph type="secondary" style={{ margin: 0 }}>前提：公司披露分部经营利润，或费用能可靠拆分到业务。现实中多数公司不披露分部费用，这条路走不通。</Paragraph>
            </Card>
          </Col>
          <Col xs={24} md={12}>
            <Card size="small" style={{ height: '100%', borderLeft: `4px solid ${token.colorPrimary}` }}>
              <Space size={6} wrap><Text strong style={{ fontSize: 15 }}>开发实际做法：毛利＋共同费用池</Text><Tag color="blue">默认</Tag></Space>
              <Paragraph strong style={{ margin: '8px 0 4px' }}>正常化经营利润 ＝ 各业务正常化毛利合计 − 集团正常化经营费用</Paragraph>
              <Paragraph type="secondary" style={{ margin: 0 }}>毛利分业务估（成本结构不同，毛利率各估各的）；费用拆不开就不硬拆，按历史集团费用率估一个共同费用池扣掉。</Paragraph>
            </Card>
          </Col>
        </Row>
        <Callout title="为什么默认用开发实际做法">
          一般公司只披露各业务的收入和毛利，经营费用只有集团合计——分部费用率和分部经营利润率根本算不出来，所以默认走“毛利＋共同费用池”。四个纪律：费用池含业务直接费用与总部费用，不能全称总部费用；已在业务毛利中扣过的成本不再重复扣；费用率以历史区间为起点、用合理区间试算并注明依据；该路径支持集团 EPV，不代表已得到可靠的分业务 EPV——要分部价值必须有分部经营利润披露。两条路径不混用：一旦走了毛利＋费用池，就不要再给任何业务叠加单独的费用率。
        </Callout>

        <Title level={5} style={{ marginTop: 24 }}>与第一层交叉判断</Title>
        <Paragraph type="secondary" style={{ maxWidth: 820 }}>经营 EPV 可直接与同范围的调整后净经营资产交叉判断。以下竞争分析以有依据的净经营资产重建成本为比较基准。</Paragraph>
        <Compare />
      </Section>

      <Section n="03" title="第三层：含增长经营价值" sub="增长价值是相对于 EPV 的增量，可以为正、为零或为负；含增长经营价值＝EPV＋增长价值。">
        <Callout>
          逐项判断增长空间、再投资需求、新增资本回报以及优势持续期。新增资本回报高于资本成本才创造价值，等于资本成本时增长不增加价值，低于资本成本时增长损害价值。持续超额回报必须有壁垒支持。
        </Callout>
        <GrowthTable />
        <Text type="secondary" style={{ display: 'block', margin: '10px 0' }}>稳定增长的简化示例，要求 g 小于 R；6% 仅为示例 WACC。有限寿命、阶段性增长和壁垒衰减采用分阶段现金流，不机械套永续公式。</Text>
        <Title level={5} style={{ marginTop: 20 }}>壁垒证据</Title>
        <Table size="small" pagination={false} rowKey={(r) => r[0]} dataSource={BARRIERS}
          columns={[{ title: '类型', render: (_, r) => <Text strong>{r[0]}</Text>, width: 200 },
                    { title: '来源', render: (_, r) => r[1] },
                    { title: '本库的壁垒类型', render: (_, r) => r[2].split('、').map((x) => <Tag key={x}>{x}</Tag>) }]} />
        <Paragraph type="secondary" style={{ marginTop: 12 }}>可先用增长率、再投资回报和优势年限建立区间，必要时才展开逐年预测。三层分别保留假设与依据，较可靠的层不引用增长预测。</Paragraph>
      </Section>

      <Section n="04" title="独立资产与非经营净调整" sub="前三层之外的资产和投资在这里独立计价。判断分离后对现有经营能力的影响，并同步调整经营成本、现金流和相关义务。">
        <Row gutter={[16, 16]}>
          <Col xs={24} md={12}><Principle title="投资：检查关系与重复计价">逐项记录被投企业、权益比例、对应收益、处置限制及经营依赖。独立估值后，对应收益从其他业务剔除；重要依赖变化联动调整主营盈利。</Principle></Col>
          <Col xs={24} md={12}><Principle title="现金：先算必要储备">可自由调度的现金及合格流动资产，减维持经营所需的周转储备和压力缓冲，得到多余现金。已计入营运资本的现金不重复加回。</Principle></Col>
        </Row>
        <Callout>
          必要现金结合季节性资金缺口、收付款周期和压力情景估计；未来扩张预算不自动视为现有经营必需现金，承诺投入与增长预测保持一致。可分离价值与立即可分配金额不是同一个数。
        </Callout>
        <Callout title="独立计价后的净调整">
          按所持权益估计价值，并考虑处置税费、受限条件和相关义务。独立计价的遗留义务可作为负项列示，注明在本节或第5节处理。现金的经济价值与近期可分配金额分别记录。
        </Callout>
        <Formula note="原书 WD-40 表 6.9：把多余现金和投资从经营资产重建成本中剥离，使经营资产与经营盈利保持同范围（单位：百万美元）。">
          211.5 − 无息负债 14.2 − 多余现金和投资 16.1 ＝ 净经营资产重建成本 181.2
        </Formula>
      </Section>

      <Section n="05" title="最终调整：从经营价值汇总到股权价值" sub="融资与权益调整独立列示，统一日期、币种和股权归属；逐项记录是否已在前面处理。">
        <Formula>股权价值 ＝ 选定一层的经营价值 ＋ 独立资产净调整额 − 有息债务价值 − 其他权益调整</Formula>
        <Row gutter={[16, 16]}>
          <Col xs={24} md={8}><Principle title="不重复汇总">前三层各自可转换为股权价值。选一层作为主估值，其余用于交叉检验。以普通股股权价值除以对应股数后与股价比较。</Principle></Col>
          <Col xs={24} md={8}><Principle title="索取权只处理一次">经营负债不作为融资债务重复扣减；有息债务、租赁、优先权益、少数股东、股权稀释分别核对，少数股东只扣一次。</Principle></Col>
          <Col xs={24} md={8}><Principle title="偿债预留不重复扣">债务已完整扣除时，不因同一项偿债预留再减一次价值。整体清算股权净值与持续经营汇总是不同场景，不互相叠加。</Principle></Col>
        </Row>
        <Callout title="示例：独立投资如何进入股权价值">
          一笔投资账面值40亿、重估值50亿，前三层的经营资产及收益均已剥离该投资。若第一层净经营资产为100亿，有息债务为30亿，且无其他调整，则资产口径的股权价值为100＋50−30＝120亿。选第二层或第三层时，以对应的经营价值替换100亿。
        </Callout>
        <Callout title="每项重要输入都应注明来源、日期、口径、估计区间及待核实事项" strong>
          未知不等于零；估值结果的可信度取决于关键假设，资产重建成本与清算回收均不构成自动保底。
        </Callout>
      </Section>

      <div style={{ marginTop: 48 }}>
        <Title level={4}>附录：页面与数据结构设计草案</Title>
        <Paragraph type="secondary">以下为后续新框架的设计参考，尚未据此新建独立页面、底稿或检查功能。本次重组只更新方法说明。</Paragraph>
        <Collapse items={[
          { key: 'boundary', label: '业务与估值边界：页面架构', children: <div>
        <Card size="small">
          <Text strong>这一页要回答什么</Text>
          <Paragraph style={{ margin: '6px 0 0' }}>公司拆成哪些估值单元？每项资产、负债及对应收益在哪里计算？哪些单独估值，哪些留在经营业务中？哪些范围仍待核实？先定清这些边界，再进入资产、盈利和增长测算。</Paragraph>
        </Card>
        <Title level={5} style={{ marginTop: 24 }}>顶部：估值范围摘要与检查</Title>
        <Paragraph>自动汇总纳入的经营业务、独立资产、融资与权益调整及待判断事项；显示当前估值版本、估值日、币种和归属口径，引用统一设置，不在这里重复录入。</Paragraph>
        <Paragraph type="secondary">计划检查：重要资产和负债是否遗漏或重复归属；独立计价资产是否已从第一层剥离、对应收益和现金流是否已从第二、三层剥离、独立价值是否只在股权汇总计入一次；集团及分部股权比例是否一致；是否遗漏总部成本和内部交易抵销。未能完成核对时显示“待核实”，不将缺失信息视为检查通过。这些检查是未来功能，目前尚未实现。</Paragraph>

        <Title level={5}>内容区一：估值单元清单（主表）</Title>
        <Paragraph>估值单元可以是一块经营业务、一项独立投资或一组适合合并处理的资产。以能否识别盈利、资本投入和估值依据为准，不必机械照搬财报分部。</Paragraph>
        <Table size="small" pagination={false} rowKey={(r) => r[0]} dataSource={[
          ['单元名称与类型', '名称；经营业务／独立业务或投资／其他独立资产／总部及共用项目。'],
          ['包含范围', '包含的产品、地区、公司主体、资产或权益；关联财报分部及科目。'],
          ['估值归属与方法', '进入经营三层，或单独估值；注明适用方法及不适用层次的原因。'],
          ['股权归属', '持股、经济权益和估值口径；明确输入为全部业务还是归母权益，避免重复乘比例。'],
          ['目标页面', '链接到经营资产价值、盈利能力与壁垒、增长与再投资，或独立资产与股权调整。'],
          ['依据与状态', '选择依据、来源、截至日期；已明确／暂定／待核实。'],
        ]} columns={[{ title: '字段组', render: (_, r) => <Text strong>{r[0]}</Text>, width: 190 }, { title: '填写内容', render: (_, r) => r[1] }]} />
        <Paragraph type="secondary" style={{ marginTop: 10 }}>示例：核心制造业务进入经营三层；一项可独立识别盈利的联营股权单独估值；闲置物业按可实现净值单列；总部费用分摊至业务或在集团层统一扣减。示例仅说明分类方式，不代表任何现有公司的实际判断。</Paragraph>

        <Title level={5} style={{ marginTop: 24 }}>内容区二：单元边界明细（展开主表行查看）</Title>
        <Table size="small" pagination={false} rowKey={(r) => r[0]} dataSource={[
          ['收入与费用范围', '哪些收入、成本、税费、维持性投入属于本单元；对应哪些报表项目。'],
          ['经营资产与负债', '哪些应收、存货、厂房、设备、必要现金及经营负债进入本单元；列归属，不在此重估。'],
          ['需剥离的收益及现金流', '独立投资收益、利息、股息等由哪里剔除，对应哪项单独估值资产。'],
          ['融资与其他权益', '有息债务、少数股东、优先权益、稀释等在哪一层处理；已计入的项目标明位置。'],
          ['依赖与共用项目', '关联供货、渠道、担保、共享品牌；出售持股是否损害主业；总部费用及内部交易如何分摊或抵销。'],
        ]} columns={[{ title: '明细组', render: (_, r) => <Text strong>{r[0]}</Text>, width: 190 }, { title: '需要说明的问题', render: (_, r) => r[1] }]} />
        <Paragraph strong style={{ marginTop: 12 }}>资产划出去，对应收益和相关义务一起检查。与主业有关不等于必须合并估值；可独立估值也不等于可以立即出售或分配。</Paragraph>

        <Title level={5} style={{ marginTop: 24 }}>内容区三：边界待判断事项</Title>
        <Paragraph>每行记录：待判断事项、涉及单元、缺失证据、暂时处理、对估值的影响和解除不确定性的条件。证据不足时保留争议，重要金额不强行归零。</Paragraph>
        <Table size="small" pagination={false} rowKey={(r) => r[0]} dataSource={[
          ['战略持股是否经营必需', '暂时单列，核实合作协议', '出售可能改变采购成本、渠道或权利，需联动调整主营盈利。'],
          ['多余现金尚未确定', '引用现金分析结果，暂不手填金额', '独立资产与股权调整页估计必要储备及可分配性，本页只记录归属原则。'],
          ['总部费用归属不清', '暂在集团层单独处理', '后续确定分摊方式，避免漏算或重复扣减。'],
        ]} columns={[{ title: '示例事项', render: (_, r) => r[0], width: 190 }, { title: '暂时处理', render: (_, r) => r[1], width: 240 }, { title: '影响与后续判断', render: (_, r) => r[2] }]} />
        <Card size="small" style={{ marginTop: 16 }}>
          <Text strong>页面完成的标准</Text>
          <Paragraph style={{ margin: '6px 0 0' }}>能够明确说出：本次估值包含哪些经营业务、单独计入哪些资产、在哪一层处理债务与其他权益，以及还有哪些未解决的范围问题。它不替代完整商业模式研究，不填写重估金额，不重复维护现金储备或投资价值。</Paragraph>
        </Card>
      </div> },
          { key: 'dashboard', label: '估值总览：展示草图', children: <Wireframe /> },
          { key: 'data', label: '底层数据结构：草案', children: <div>
        <Table size="small" pagination={false} dataSource={DATA}
          columns={[{ title: '层', dataIndex: 'layer', width: 150, render: (v) => <Text strong>{v}</Text> },
                    { title: '表', dataIndex: 'tables' },
                    { title: '为什么', dataIndex: 'why', width: 300 }]} />
      </div> },
          { key: 'steps', label: '落地顺序：待进一步确认', children: <div>
        <Row gutter={[12, 12]}>
          {STEPS.map(([t, d], i) => (
            <Col xs={24} md={12} lg={8} key={t}>
              <div style={{ display: 'flex', gap: 12, padding: 12, borderRadius: 8, background: token.colorFillQuaternary, height: '100%' }}>
                <div style={{ fontSize: 22, fontWeight: 700, color: token.colorPrimary, lineHeight: 1 }}>{i + 1}</div>
                <div><Text strong>{t}</Text><Paragraph type="secondary" style={{ margin: '4px 0 0', fontSize: 13 }}>{d}</Paragraph></div>
              </div>
            </Col>
          ))}
        </Row>
      </div> },
        ]} />
      </div>
      <Paragraph type="secondary" style={{ marginTop: 24 }}>方法基础：Greenwald 等《Value Investing: From Graham to Buffett and Beyond》，资产与 WD-40 示例见第一版第四、六章；第二版及《Competition Demystified》补充增长、回报与竞争分析。<Typography.Link href="https://dokumen.pub/value-investing-from-graham-to-buffett-and-beyond.html" target="_blank" rel="noopener noreferrer">所引原文</Typography.Link>。第一层以资产质量检查和实务重估为主、清算和重建按需采用，属于实用导向的改编；五部分展示、费用池简化、可测性标记与页面设计也是本框架的落地约定。</Paragraph>
    </div>
  );
}

ctx.render(<Page />);
"""


def body():
    return {'page': {'title': TITLE, 'documentTitle': f'价值投资框架 · {TITLE}'},
            'assets': {'scripts': {KEY: {'version': 'v3', 'code': JS}}},
            'tabs': [{'title': TITLE, 'blocks': [{'type': 'jsBlock', 'script': KEY}]}]}


if __name__ == '__main__':
    st = bp.state()
    gid = bp.shared_root(st)
    if KEY in st['pages']:
        overview.apply_page(KEY, {'version': '1', 'mode': 'replace', 'target': {'pageSchemaUid': st['pages'][KEY]['pageSchemaUid']}, **body()})
    else:
        overview.apply_page(KEY, {'version': '1', 'mode': 'create',
                                  'navigation': {'group': {'routeId': gid}, 'item': {'title': TITLE, 'icon': ICON}}, **body()})
        overview.record(KEY, gid, TITLE)
    print(TITLE, bp.state()['pages'][KEY])
