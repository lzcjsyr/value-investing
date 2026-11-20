"""每家公司的驾驶舱（放在公司菜单的最上面），以及“框架与后台”里的使用说明、数据结构、模型公式。

  python3 build_overview.py                      缺什么建什么（新公司加入后执行）
  python3 build_overview.py --rebuild-dashboard [代码 ...]  重建驾驶舱（不跟代码＝所有公司；改了下面的 JS 或图表之后用）
  python3 build_overview.py --refresh-dashboard 代码 ...  原地址更新驾驶舱（保留菜单与页面地址）
  python3 build_overview.py --rebuild-docs       重建三篇说明
"""
import json, subprocess, pathlib, sys
import spec
from build_pages import state, child_page, companies, company_root, shared_root, destroy_page, STATE, ROOT, HERE, SHARED

GUIDE = """# 使用说明

> 2026-11-11 估值部分按 Greenwald 三层重构：旧的财务模型、估值模型、逐年假设、分部加总、统一估值引擎都已删除。表清单见「框架与后台 / 数据结构」，方法见「估值地基：Greenwald 三层价值」。

这是一套**可复用的价值投资研究框架**。每家公司都按同一条链研究：

**来源文档 → 定性事实与指标 → 商业模式、产业链与竞争对手 → 竞争壁垒 → 核心论点 → 风险分析 → 假设依据 → 三层估值（资产价值 → 盈利能力价值（调整后利润表）→ 增长价值 → 独立资产与调整 → 股权价值）→ 跟踪与证伪**

先回答“这门生意凭什么持续赚钱”，再回答“值多少钱”。

## 菜单怎么看
- **每家公司一个顶层菜单**（现在有长江电力、太阳纸业、中国建筑、腾讯音乐、小米集团），点进去只看到这家公司的数据：驾驶舱，以及四组页面：**商业模式**（只放分析）、**经营与财务**（财务报表、定量指标、定性事实）、**预测与估值**（按「估值地基：Greenwald 三层价值」：① 资产价值 → ② 盈利能力 → ③ 增长价值 → ④ 独立资产 → ⑤ 股权价值 → 假设依据）、**研究维护**（来源文档、质量自检、待办清单、变更日志）。各公司的数据在同一个数据库里，但页面互不混。
- **宏观数据**（独立项目）：利率、汇率、大宗商品等不属于任何公司的数据（指标、高频数据、采集配置）。各公司按需使用：股价汇率和重点跟踪（假设依据、风险关联的指标）直接引用；其他想看的在「框架与后台 / 公司」里勾选“订阅的宏观数据”。公司菜单里「定量指标」的高频经营标签只展示经营、水文和商品指标；股价、利率与汇率在驾驶舱及宏观数据查看。驾驶舱“立即采集一次”仍采这家公司需要的所有指标。
- **框架与后台**：这三篇说明、公司列表（含订阅的宏观数据）、全部指标定义，以及自动采集（采集配置、采集运行、原始采集记录、全部数据）。

## 每天/每周怎么用
1. **<公司> / 驾驶舱**：看今天每股价值、市场价、按要求收益率的最高买入价和质量自检。
   想看估值怎么来的，按 **<公司> / 预测与估值** 的五页从上往下看：资产值多少、不增长时盈利值多少、增长能多值多少、经营之外的资产与索取权、最后汇成每股价值和隐含回报。
2. **<公司> / 研究维护 / 质量自检**：先看“阻断”和“提示”，它们说明结论能不能用。
3. **<公司> / 经营与财务**：按“原始报表 → 定量指标 → 定性事实”排列。**财务报表**是季度完整三大报表（只读）；**定量指标**每个指标一行，“趋势”列是主口径最近 12 期的小折线（主口径不足两期时用数据最多的口径，下方写起止统计时间），点“查看”看大图、逐期数据并录入新一期，这家公司的全部指标分四个标签：“定期经营”是发电量、浆纸销量、合同额、开工面积、用户、设备数与单位售价，“高频经营”是水位、流量等自动采集的经营指标，“财务指标”是全部财务数（报表里有的科目与比率按报表公式实时算，报表外的分部收入、股息、净借款等在这里录入），“宏观与市场”是利率、汇率、商品价格和股价。“模型字段”列说明这个数进历史年度的哪一项，“重点跟踪”列出盯着它的假设依据和风险。想更新自动采集指标，可按驾驶舱的 **立即采集一次**；该按钮仍采集这家公司需要的全部数据源。
4. 有新公告或财报：先在 **研究维护 / 来源文档** 登记原件，按期数字录进对应指标，数字以外的事写 **定性事实**；结论有变化先改 **核心论点**（裁决、改判条件），需要改假设时写 **预测与估值 / 假设依据**，然后在对应那一层的编辑标签里改数（资产负债重估、盈利能力、增长），最后在 **变更日志** 记录旧值、新值与理由。
   在公司菜单里新增记录时，表单里的“公司”要选这家公司，否则这条记录不会出现在它的页面里。

## 时期指标与时点指标
每个指标都标明“指标性质”，决定每期数据能用哪些口径、能不能跨期相加：
- **时期指标（流量）**：一段时间内累计发生的量，如营业收入、利润、现金流、销量、回购金额；由它们算出的比率（毛利率、ARPPU）也算。同类时期可以相加（四个单季≈全年），口径选单季、半年累计、前三季度累计、全年、滚动四季度等。
- **时点指标（存量）**：某一时刻的状态或规模，如现金、负债、负债率、股价、零售价、用户数。不能跨期相加，口径只能是“时点”。

每期数据的“统计时间”两类都用：时期指标写这段时期（2026Q2＝第二季度，2025＝全年），时点指标写时点所在的报告期（2026Q2＝二季度末，2026M07＝7 月末）；“对应日期”精确到日。性质与口径对不上时系统拒绝保存；指标性质留空的不检查。

## 商业模式分析（先于估值）
价值投资的核心是识别竞争壁垒，而壁垒要从商业模式、产业链和竞争对手里找。「<公司> / 商业模式」的页面按阅读顺序排列：
1. **商业模式拆解**：用标准的商业模式画布，按集团或所属业务各写 9 项（B1—B9）：客户细分、价值主张、渠道通路、客户关系、收入来源、核心资源、关键业务、重要合作、成本结构。投资者关心的内容放进画布：盈利公式的收入一侧（量×价）、收入结构、单价、增长与周期写在**收入来源**；盈利公式的成本一侧、成本构成与经营杠杆、单位利润、资本需求与现金循环写在**成本结构**。
2. **产业链与五力**：上游、本公司、下游、渠道、互补方、替代品、潜在进入者、同业、监管各一行；写谁拿走多少利润，并标出属于波特五力中的哪一种力量、强弱、对公司有利还是不利、趋势。同业、替代品、进入者这几行只评估力量，具体对手关联到竞争对手表。
3. **竞争对手**：直接对手、替代品、潜在进入者与海外对标；关键数字写截至日期，第三方估算在来源里注明。
4. **竞争壁垒**：每项候选壁垒写机制、财务体现（更高 ROIC 或毛利率、更高留存、更低获客成本、更稳定的现金流）、证据、反证、复制难度。**看起来像壁垒、其实不是的（伪壁垒）也要列出来**。能量化的设自动检查（读历史年度）。
5. **核心论点**：决定价值的几个关键判断——壁垒能否持续、增长与利润率、现金与资本配置、治理、估值。每条写正方立论、反方立论、互相反驳，再给裁决（成立 / 观察 / 存疑 / 证伪）、把握、决定胜负的证据、改判条件和对模型的影响。伪壁垒以外的每项壁垒至少关联一条辩论过的论点（填辩论日期）。岗底斯观点 PK、卖方与外资的正反观点写在“外部观点”里，裁决仍由自己负责。能量化的改判条件设自动检查。
6. **风险分析**：会让这笔投资亏钱的不利事件。每条写传导路径、可能性与冲击（系统按可能性×冲击自动定级为重大、重要、一般）、影响测算、缓冲因素、在估值里怎么处理（已计入估值输入、体现在主估值层或门槛、未计入）、预警信号与触发后应对。论证不在这里重复：关联会被削弱的论点（自动显示其当前裁决）、估值对应的假设依据、盯着的预警指标（汇总在「经营与财务 / 重点跟踪」）。
7. **价投适配度**：顶部是结论看板（总分、归类、八个维度的分数条、强项与短板），下方表格录入。长坡、厚雪、慢变、护城河、再投资、财务质量、治理配置、可估值性，各 0—5 分并写反证，关联支撑它的论点。总分 32—40 适合复利框架，22—31 合适（要说明更偏复利、现金流价值还是资产价值），21 以下通常不符合。
证据在「经营与财务」，上层判断（商业模式、壁垒、论点、假设依据、估值）用两种方式引用：**依据指标**——按期重复的数（经营数字、财务数字、股价、利率、水位）只放在 `vi_metric_base`（序列定义）和 `vi_observation_base`（每期值）里，引用指标就能看到趋势和逐期数据；**依据事实**——定性事实分两层：`vi_event_base`（事项，一件事：短名称＋简介）下挂若干 `vi_fact_base`（侧面，各有日期、来源、核验状态），在「经营与财务 / 定性事实」先看事项、点开看各侧面的时间线；上层引用具体侧面。定性事实写数字以外、会改变判断的事（制度监管、合作授权、并购与资本运作、人事、诉讼、管理层表态、竞争对手动作），以及卖方预测、可比估值、同业对比这类外部参照，不重复抄指标里的数。
落到估值的在「预测与估值 / **假设依据**」：事实和论点如何决定每个估值参数（资产负债重估的折价与调整、调整后利润表的每一行、增长），改参数的门槛，什么情况下不改。

**每个观点只写一处**：描述性的内容放商业模式、产业链、竞争对手、竞争壁垒；有争议、决定价值的判断放核心论点（对应哪条假设依据在假设依据里关联，论点上自动显示“假设依据（状态）”）；会让人亏钱的事件放风险分析；参数怎么设、什么时候改放假设依据；还没有答案的判断性问题（如“应收能收回多少”）也写成核心论点，缺的证据写在“决定胜负的证据”。「跟踪 / 待办清单」只放做完即关的待办（数据源、核验、模型缺口、等你拍板的策略选择），不放判断。其他地方按编号引用（如“见 T2”“J-P”），不重复论证。

质量自检 C09、C14、C15、C18、C19 会提示：论点的自动检查有没有触发、还有哪些壁垒没辩论、适配度总分与归类、高分维度是否关联了存疑或证伪的论点、重大风险有没有计入估值和预警信号。

## 估值：Greenwald 三层价值（按「框架与后台 / 估值地基」）
- **资产价值**按全公司逐项重估经营资产与经营负债。**盈利能力**和**增长**按估值单元（业务）计算。独立计价的业务或资产按市价、交易价或账面计入资产负债桥。
- **口径开关**（业务的“口径”）：企业口径＝利息前利润，有息负债在资产负债桥里扣；股权口径＝利息后利润，有息负债归为经营负债（银行、保险、地产开发等借钱就是生意本身）。
- 三层价值并列：盈利能力价值远高于资产价值说明可能有壁垒（要有论点与壁垒证据），低于资产价值说明资产没被用好；增长价值可正可负。每家公司在「⑤ 股权价值 / 估值设置」里选一层作**主估值层**并写依据，另两层做交叉检验。
- **只用一个门槛**：投资回报率要求，全部公司共用，在「框架与后台 / 统一设置」里改。它既用来资本化经营收益，也用来判断隐含回报够不够；**隐含年化回报**＝按今天市价买入、假设成立时的年化回报（分不增长、含增长两种）。
- **不设情景**：三层本身就是从保守到乐观的三种情形（资产值多少、不增长值多少、算上增长值多少），风险靠主估值层和价格与它的距离来覆盖。
- 数据都在四张表里：资产负债重估（第一层＋独立资产与调整，全部报表科目账面合计＝归母股东权益）、调整后利润表（第二层，一行一个项目）、增长（第三层）、假设依据；估值设置在公司表。估值检查 G01—G09 在「⑤ 股权价值」和「研究维护 / 质量自检」。

## 改假设的规则
- 在对应那一层的编辑标签里改：资产与资产负债桥改「资产负债重估」，第一层的估值口径与重建成本在「① 资产价值」设置，第二层改「调整后利润表」（每行的取值方式与数值），第三层改「增长」，截至日、股本、主估值层在「⑤ 股权价值」。结果自动计算，不能手改。
- 每个数都要关联假设依据（G05）；折价或调整额不为零的资产负债行也要关联。
- 空白表示“未知”，不是 0：缺参数的业务不输出价值。
- 市场数据只供对照，不会自动改估值输入。

## 研究一家新公司
1. **框架与后台 / 公司**：新增一行（代码、名称、币种，业务量/单价的名称与单位只用于历史年度和图表）。
2. **指标 + 采集配置**：加股价指标；采集配置选解析器 `tencent_quote`，参数填股票代码（如 `sz000651`，港股 `hk01698`）。港股、美股等外币报价：再加一个汇率指标（解析器 `tencent_fx`，参数如 `whHKDCNY`），在公司表的“股价汇率指标”里选它，估值与驾驶舱的市场价会按当天汇率折成记账币种。
3. **经营与财务 / 财务报表**：季度完整三大报表，用 `framework/tools/fin_stmt.py` 从 akshare 取数并检验，不用手录。**经营与财务 / 定量指标**：这家公司的全部指标；历史年度用到的数在“模型字段”列标明。
4. 填**商业模式**九张表（见上一节）：先写清生意、产业链、对手和壁垒，再把决定价值的判断写成论点并正反辩论，然后在预测与估值 / 假设依据里写参数怎么设。
5. **三层估值**：写 `companies/<公司>/greenwald.py`（估值设置、业务口径、资产负债表逐科目归类与调整、调整后利润表、增长，每个数挂假设依据），`python3 framework/greenwald_seed.py <代码>` 生成并写入；以腾讯音乐为样板。
6. 生成这家公司的菜单：在 framework 目录依次运行 `python3 build_pages.py <代码>`、`python3 build_greenwald.py <代码>`、`python3 build_overview.py`，最后排序菜单（见 framework/README.md）。

## 不同生意，同一套表
- **长江电力**（类债资产）：关键变量是来水、电价、利率；梯级电站资源与零燃料成本是真实壁垒，适配度 34/40。三层估值待填（2026-11-11 先只做腾讯音乐）。
- **太阳纸业**（周期制造业、正在扩张）：盈利能力要用完整浆价周期的平均利润率；真实壁垒只有自制浆与林浆纸一体化，适配度 22/40。三层估值待填（2026-11-11 先只做腾讯音乐）。
- **中国建筑**（总承包商＋地产，薄利、垫资）：借钱是生意的一部分，用**股权口径**；关键在利润能不能变成现金、减值会不会收敛；没有真实壁垒，适配度 15/40。三层估值待填（2026-11-11 先只做腾讯音乐）。
- **腾讯音乐**（港股、人民币记账，净现金的轻资产平台）：三层估值的第一家（样板）。一块业务、企业口径；资产负债表 34 个科目逐项归类，资产负债桥（现金扣经营所需、对外投资七折、有息负债、汇出预提税、少数股东）约 357 亿元；主估值层＝盈利能力价值（资产说明不了价值，增长取决于优势能维持多久）。第二层的调整后利润表：收入 355 亿元 → 报表经营利润 101.4 → 加回七成收购摊销 → 调整后 107.7（30.3%）→ 税后 88.8 → E 86.1 亿元。每股（2026-11-11）：资产价值 13.3、盈利能力价值 57.9、含增长价值 63.6 元，现价 32.53 元，主估值层 盈利能力价值。上游议价权是真实壁垒，适配度 31/40。
- **小米集团**（港股、几块业务处在不同阶段）：手机×AIoT 生态与智能汽车各算三层，AI、芯片与机器人没有可预测的盈利，适合作**参照估值**放在资产负债桥。三层估值待填（2026-11-11 先只做腾讯音乐）。

> 研究提示，不是交易指令。所有新阈值都是研究预警，不是自动买卖规则。"""

FORMULAS = """# 模型公式

方法与取舍见「框架与后台 / 估值地基：Greenwald 三层价值」；这里只列公式（`framework/sql/02_calc.sql` 的 Greenwald 段）。h＝门槛（统一设置，全部公司共用）。

## 第一层：资产价值
- 资产负债重估每行：重估金额 ＝ 账面 × (1 − 折价) ＋ 调整额；账面取公司估值截至日的资产负债表（报表科目留空的研究项目账面为 0）
- 计入值：经营资产、现金与投资、参照估值为正；经营负债、有息负债、其他索取权为负
- 账面经营资本 ＝ 全公司经营资产与经营负债的账面计入值合计；调整后经营资本取同一批科目的重估计入值合计。
- 公司经营资产价值（归母）＝ 调整后经营资本 × 归母比例。公司口径选“重建成本”时用重建成本替代调整后经营资本，选“不适用”时留空。归母比例 ＝ 1 − 各业务的少数股东收益合计 ÷ 各业务扣少数股东前的现金收益合计。
- G01：报表科目行的账面计入值合计 ＝ 截至日归母股东权益（相差不超过 0.5 亿元），每个科目只计一次

## 第二层：盈利能力价值（调整后利润表）
- 每块业务一张表，一行一个项目；报表公式给出历年数（全年口径，最近 5 年＋最近四个季度），正常化值按取值方式算：
  金额＝填数；占收入比例＝比例 × 正常化收入；最新年度、滚动四季度＝报表公式的最近一年或最近四个季度；
  历史平均＝起止年份的平均金额；历史平均占收入＝起止年份“本行 ÷ 收入”的平均 × 正常化收入（周期业务的正常化）；比率＝所得税、少数股东
- 正常化收入 ＝ 收入行合计；报表经营利润 ＝ 收入 − 成本费用
- 调整后经营利润 ＝ 报表经营利润 ± 税前调整（如加回收购摊销、为增长花的费用、一次性项目）
- 所得税 ＝ 调整后经营利润 × 税率；税后经营利润 ＝ 调整后经营利润 − 所得税
- 可持续现金收益（全部股东）＝ 税后经营利润 ± 税后调整（加回折旧摊销、减维持性资本开支、减必要营运资本增加）；没有税后调整按两者相等处理（G08 提示）
- 少数股东 ＝ 上一行 × 少数股东比率；E（归母）＝ 上一行 − 少数股东
- 盈利能力价值 ＝ E ÷ h；“不计入”的行（利息收入、投资收益、融资成本等）只作对照，对应的资产负债在资产负债桥里单独计价

## 第三层：增长价值
- 优势年限 N 内：第 t 年收益 E·(1+g)^(t−1)，再投入 g ÷ 新增投资回报率 的收益，现金流 E·(1+g)^(t−1)·(1 − g ÷ RONIC)
- N 年后增长不再创造价值：收益停在 E·(1+g)^N，永续
- 含增长价值 ＝ Σ 现金流 ÷ (1 + h)^t ＋ E·(1+g)^N ÷ h ÷ (1 + h)^N；N 留空＝永续增长：E·(1 − g ÷ RONIC) ÷ (h − g)，要求 g ＜ h（G03）
- 新增投资回报率 ＝ h 时含增长价值 ＝ 盈利能力价值；高于 h 必须经“成立”的论点连到“真实壁垒”（G04）
- 增长价值 ＝ 含增长价值 − 盈利能力价值（可正、可零、可负）

## 独立资产与调整、股权价值
- 资产负债桥 ＝ 现金与投资、参照估值、有息负债、其他索取权的重估计入值合计
- 每层股权价值 ＝ 该层经营价值 ＋ 资产负债桥；每股（今天）＝ 股权价值 ÷ 股本 × (1 + h)^(距截至日年数)
- 主估值层（资产价值、盈利能力价值或含增长价值）给出每股价值与隐含回报
- 隐含年化回报 ＝ 使 (Σ 业务现值(r) ＋ 资产负债桥) × (1 + r)^(距截至日年数) ÷ 股本 ＝ 市价 的 r（二分法）；分不增长、含增长两种，资产价值层没有隐含回报

## 估值检查（G01—G09）
- G01 资产负债表对账、G02 输入完整、G03 永续增长低于门槛、G04 超额回报有壁垒支撑、G05 每个数都有依据、G06 依据已采纳、G07 口径开关一致（企业口径的有息负债进资产负债桥，股权口径的有息负债归为经营负债）、G08 维持性投入已估、G09 主估值层

## 年度派生指标（历史年度、自动检查用）
- 单价 ＝ 营业收入 ÷ 业务量；派息率 ＝ 现金分红 ÷ 归母净利润；所得税率 ＝ 所得税 ÷ 利润总额
- 毛利率 ＝ 1 − 营业成本 ÷ 营业收入；ROE ＝ 归母净利润 ÷ (上年末＋本年末归母净资产) ÷ 2
- 经营现金流 ÷ 归母净利润（利润的现金含量）；资本开支 ÷ 经营现金流（大于 1＝投资花得比经营赚的现金多）
- 净负债 ＝ 带息负债 − 货币资金；净负债 ÷ EBITDA，EBITDA 近似 ＝ 利润总额 ＋ 财务费用 ＋ 折旧摊销

## 商业模式分析检查
- 竞争壁垒的“已辩论的论点数”“论点裁决”按关联的论点自动统计，只算填了辩论日期的论点；裁决按编号列出每条论点（如“T1 成立；T4 观察”）
- C09 论点证伪：有论点的自动检查已触发时为“阻断”
- C14 竞争壁垒与辩论：没有候选壁垒、伪壁垒以外有壁垒没有关联辩论过的论点、或有壁垒的自动检查已触发时为“提示”
- C15 价值投资适配度：八个维度总分；32—40 适合复利框架，22—31 合适，21 以下通常不符合（未评满八项或低于 22 分为“提示”）

## 论点与壁垒自动证伪
- 论点和竞争壁垒共用同一个检查函数。从年度汇总（模型字段指标的年度值）取指标（业务量、单价、营业收入、归母净利润、派息率、财务费用、各项同比，以及毛利率、ROE、经营现金流÷归母净利润、资本开支÷经营现金流、净负债、净负债÷EBITDA），最近 N 年都满足条件即“已触发”
- 同比只在口径相同的相邻年份之间计算：公司表“口径变化年份”里的年份（并表、重组）与上一年不算同比"""

COLLECT = r"""const COMPANY = '__COMPANY__';   // 按钮只采这家公司和通用指标（利率等）的数据源，表格和最近几次也只看这家公司
const { React } = ctx.libs;
const { useState, useEffect } = React;
const { Button, Steps, Table, Alert, Tag, Space, Typography } = ctx.libs.antd;
const { Text, Paragraph } = Typography;
const FLOWS = __FLOWS__;   // 由 build_overview.py 从 workflows_state.json 写入（按 key 找当前版本）

const get = async (url, params) => (await ctx.request({ url, params }))?.data?.data;
const listOf = async (name, params = {}) => (await get(`${name}:list`, { pageSize: 200, ...params })) || [];
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
const when = (v) => (v ? new Date(v).toLocaleString('zh-CN', { hour12: false }) : '—');
const healthTag = (h) => <Tag color={h === '正常' ? 'green' : h === '已停用' ? 'default' : 'red'}>{h || '—'}</Tag>;
// 最新值：每个数据源取“最新观察日期”那天的观察（同一天有多条时取最后写入的）
async function latestValues(collectors) {
  const keys = collectors.filter((c) => c.metric_id && c.last_obs_date);
  if (!keys.length) return {};
  const rows = await listOf('vi_observation', { sort: '-id', pageSize: 500,
    filter: JSON.stringify({ $or: keys.map((c) => ({ metric_id: { $eq: c.metric_id }, obs_date: { $eq: c.last_obs_date } })) }) });
  const out = {};
  for (const r of rows) if (!(r.metric_id in out)) out[r.metric_id] = r.value;
  return out;
}
const STEP = { 排队: 0, 运行中: 1, 完成: 2 };
// 这家公司要采的数据源＝它用到的指标（自有、股价、汇率折算、无风险利率、重点跟踪、订阅的宏观数据）。
// 用途由数据库视图 vi_company_metric 汇总，指标的 used_by_codes 来自它；SQL vi_collect_targets 用的是同一个视图。
function ownCollectors(collectors, metrics, companies, coId) {
  const code = companies.find((c) => c.id === coId)?.code;
  const keep = new Set(metrics.filter((m) => m.company_id === coId
    || (code && (m.used_by_codes || '').includes(`,${code},`))).map((m) => m.id));
  return collectors.filter((c) => keep.has(c.metric_id));
}

async function flowState() {
  const keys = [FLOWS.manual, ...FLOWS.scheduled].filter(Boolean);
  const rows = keys.length ? await listOf('workflows', { filter: JSON.stringify({ key: { $in: keys }, current: true }) }) : [];
  return { manual: rows.find((r) => r.key === FLOWS.manual), scheduled: rows.filter((r) => FLOWS.scheduled.includes(r.key)) };
}

function Panel() {
  const [flows, setFlows] = useState(null);
  const [collectors, setCollectors] = useState([]);
  const [values, setValues] = useState({});
  const [lastRun, setLastRun] = useState(null);
  const [coId, setCoId] = useState(null);
  const [run, setRun] = useState(null);
  const [seconds, setSeconds] = useState(0);
  const [running, setRunning] = useState(false);
  const [results, setResults] = useState(null);
  const [error, setError] = useState(null);

  const refresh = async () => {
    const [f, c, ms, cos] = await Promise.all([flowState(), listOf('vi_collector', { sort: 'id' }),
      listOf('vi_metric', { pageSize: 500 }), listOf('vi_company')]);
    const id = cos.find((x) => x.code === COMPANY)?.id;
    const own = ownCollectors(c, ms, cos, id);
    const [r, v] = await Promise.all([
      id ? listOf('vi_collect_run', { sort: '-id', pageSize: 1, filter: JSON.stringify({ company_id: { $eq: id } }) }) : [],
      latestValues(own)]);
    setFlows(f); setCoId(id ?? null); setCollectors(own); setValues(v); setLastRun(r[0] || null);
  };
  useEffect(() => { refresh().catch((e) => setError(String(e?.message || e))); }, []);

  // 按钮只做一件事：在“采集运行”里新增一行；“④ 手动采集”工作流被它触发，跑完 采集→入库→自检 后把状态改成“完成”
  const start = async () => {
    setRunning(true); setError(null); setResults(null); setSeconds(0);
    try {
      const label = `手动｜${COMPANY}｜${new Date().toLocaleString('zh-CN', { hour12: false })}`;
      if (!coId) throw new Error(`公司表里没有代码为 ${COMPANY} 的公司`);
      const res = await ctx.request({ url: 'vi_collect_run:create', method: 'post', data: { label, trigger_source: '手动', status: '排队', company_id: coId } });
      const id = res?.data?.data?.id;
      if (!id) throw new Error('没能新建采集运行记录');
      const t0 = Date.now();
      let cur = { id, status: '排队' };
      setRun(cur);
      while (cur.status !== '完成' && Date.now() - t0 < 180000) {
        await sleep(1500);
        setSeconds(Math.round((Date.now() - t0) / 1000));
        cur = (await get('vi_collect_run:get', { filterByTk: id })) || cur;
        setRun(cur);
      }
      if (cur.status !== '完成') {
        throw new Error('3 分钟内没有跑完：到「设置 → 工作流 → ④ 手动采集」打开执行记录，看哪个节点出错。');
      }
      setResults(await listOf('vi_raw_capture', { filter: JSON.stringify({ run_id: { $eq: id } }), sort: 'id' }));
    } catch (e) {
      setError(String(e?.message || e));
    } finally {
      await refresh().catch(() => {});
      setRunning(false);
    }
  };

  // 本次采集里出问题的数据源（抓取失败、校验失败），直接在表格的状态列里显示原因
  const issueOf = (c) => (results || []).find((r) => String(r.collector_id) === String(c.id) && /失败/.test(r.status || ''));
  const ready = flows?.manual?.enabled;
  const scheduledOn = flows && flows.scheduled.length && flows.scheduled.every((w) => w.enabled);
  const step = run ? STEP[run.status] ?? 0 : -1;
  const stepStatus = (i) => (step < 0 ? 'wait' : error && i === Math.min(step, 1) ? 'error' : i < step || run?.status === '完成' ? 'finish' : i === step ? 'process' : 'wait');

  if (/403|No permissions/i.test(error || '')) return null;

  return (
    <div>
      {flows && !ready && (
        <Alert type="warning" showIcon style={{ marginBottom: 12 }}
          message="「④ 手动采集」工作流没有启用，按钮不会生效"
          description="到「设置 → 工作流」打开“④ 手动采集 · 按钮触发”。它只在按按钮时运行，不会定时运行。" />
      )}
      <Space wrap align="center" style={{ marginBottom: 12 }}>
        <Button type="primary" loading={running} disabled={!ready} onClick={start}>立即采集一次</Button>
        <Text type="secondary">只采这家公司用到的数据源，通常 5—30 秒。</Text>
      </Space>
      {run && (
        <Steps size="small" style={{ marginBottom: 12 }} items={[
          { title: '已发起', status: stepStatus(0) },
          { title: '采集、入库、自检', status: stepStatus(1), description: running ? `${seconds} 秒` : undefined },
          { title: '完成', status: stepStatus(2) },
        ]} />
      )}
      {error && <Alert type="error" showIcon style={{ marginBottom: 12 }} message={error} />}
      {results && run && (run.fetch_failed || run.invalid) ? (
        <Alert type="warning" showIcon style={{ marginBottom: 12 }} message={`本次：${run.summary || ''}`}
          description={run.fetch_failed
            ? '抓取失败＝连不上网站，不是解析问题：本机网络、代理/VPN 或网站临时不可用。稍后再按一次；一直失败就检查代理是否让这些国内网站直连。'
            : '校验失败＝拿到了网页但解析不出数，多半是网站改版，到「框架与后台 / 采集 / 原始采集记录」看原文。'} />
      ) : null}
      <Table size="small" pagination={false} rowKey="id" dataSource={collectors} columns={[
        { title: '数据源', dataIndex: 'name' },
        { title: '最新值', key: 'value', align: 'right', render: (_, c) => values[c.metric_id] ?? '—' },
        { title: '观察日期', dataIndex: 'last_obs_date', render: (v) => v || '—' },
        { title: '状态', key: 'state', render: (_, c) => {
          const bad = issueOf(c);
          return bad ? <span><Tag color="red">{bad.status}</Tag><Text type="secondary">{bad.fetch_note}</Text></span> : healthTag(c.health);
        } },
      ]} />
      <Paragraph type="secondary" style={{ marginTop: 8, marginBottom: 0 }}>
        {lastRun ? `最近采集 ${when(lastRun.requested_at)}（${lastRun.trigger_source || '—'}）：${lastRun.summary || ''}。` : '还没有采集过。'}
        {scheduledOn ? '定时采集已启用（每天 18:30）。' : '定时采集未启用。'}按完后刷新页面，下面的图表会用到新数据。
      </Paragraph>
    </div>
  );
}

// 管理工具仅由管理员角色挂载，避免只读成员触发管理接口及全局 403 提示。
let collectionRole = null;
try { collectionRole = await ctx.getVar('ctx.role'); } catch (_) { /* 未取得角色时不挂载管理工具 */ }
const collectionRoleName = typeof collectionRole === 'string' ? collectionRole : collectionRole?.name;
if (['root', 'admin'].includes(collectionRoleName)) {
  ctx.render(<Panel />);
} else {
  ctx.render(null);
}
"""

def c(sql, kind, mapping):
    return {'query': {'mode': 'sql', 'sql': sql}, 'visual': {'mode': 'basic', 'type': kind, 'mappings': mapping}}


def raw(sql, js):
    """basic 柱状图在“系列”分组时每根柱子只占一格里的一小段、长名称互相遮挡；这类图改用自定义 ECharts option。"""
    return {'query': {'mode': 'sql', 'sql': sql}, 'visual': {'mode': 'custom', 'raw': js}}


# 横向条形图：每行一个条目（编号＋名称，过长截断、悬停看全称），按 grp 上色、同一行只有一根条；刻度用 强/中/弱。
# 数据列：code、name、v（-3—3）、grp。__MIN__ 为 0 时是单向（强度），为 -3 时左不利、右有利。
HBAR = r"""const rows = ctx.data?.objects || [];
const GROUPS = __GROUPS__;
const MIN = __MIN__;
const LEVEL = ['无', '弱', '中', '强'];
const short = (s, n) => (s && s.length > n ? s.slice(0, n) + '…' : s || '');
const labels = rows.map((r) => `${r.code} ${short(r.name, 9)}`);
const tick = (v) => (v === 0 && MIN < 0 ? '' : LEVEL[Math.abs(v)] || '');
const level = (v) => (MIN < 0 && v ? (v < 0 ? '不利·' : '有利·') : '') + LEVEL[Math.abs(v)];
return {
  grid: { left: 8, right: 24, top: 8, bottom: MIN < 0 ? 56 : 40, containLabel: true },
  legend: { bottom: 0, data: GROUPS.map((g) => g[0]) },
  tooltip: { trigger: 'item', formatter: (p) => {
    const r = rows[p.dataIndex];
    return `${r.code} ${r.name}<br/>${r.grp}${r.v ? '：' + level(Number(r.v)) : ''}`;
  } },
  xAxis: { type: 'value', min: MIN, max: 3, interval: 1, axisLabel: { formatter: tick },
    name: MIN < 0 ? '← 不利　　有利 →' : '', nameLocation: 'middle', nameGap: 26,
    splitLine: { lineStyle: { type: 'dashed' } } },
  yAxis: { type: 'category', inverse: true, data: labels, axisTick: { show: false } },
  series: GROUPS.map(([g, color]) => ({
    name: g, type: 'bar', stack: 'one', barMaxWidth: 16, itemStyle: { color, borderRadius: 2 },
    // 0 画不出条，写字标出来（强度“无”、影响“中性”），免得像漏了数据
    label: { show: true, position: 'right', color: '#8c8c8c', formatter: (p) => (p.value === 0 ? (MIN < 0 ? '中性' : p.seriesName) : '') },
    data: rows.map((r) => (r.grp === g ? Number(r.v) : null)),
  })),
};
"""
MOAT_GROUPS = "[['真实壁垒', '#389e0d'], ['局部优势', '#1677ff'], ['待验证', '#faad14'], ['伪壁垒', '#cf1322']]"
FORCE_GROUPS = "[['有利', '#389e0d'], ['中性', '#bfbfbf'], ['不利', '#cf1322']]"


def obs(metric_code, label='数值'):
    return ("SELECT o.obs_date, o.value AS \"" + label + "\" FROM vi_obs_current o JOIN vi_metric_base mt ON mt.id = o.metric_id "
            f"WHERE mt.code = '{metric_code}' ORDER BY o.obs_date")


def charts(co):
    """一家公司的驾驶舱图表：SQL 都按公司代码过滤（不再依赖“驾驶舱默认展示”）。"""
    code = co['code']
    CO = "JOIN vi_company_base co ON co.id = {t}.company_id AND co.code = '" + code + "'"
    out = [
        ('gw_layers', '三层价值与现价（元/股，今天）', c(
            "SELECT x.k AS \"口径\", round(x.v::numeric, 2) AS \"元/股\", x.o FROM vi_gw_value v "
            + CO.format(t='v') + " CROSS JOIN LATERAL (VALUES ('资产价值', v.av_ps, 1), ('盈利能力价值', v.epv_ps, 2), ('含增长价值', v.full_ps, 3), "
            "('市场价', v.market_price, 4)) x(k, v, o) WHERE x.v IS NOT NULL ORDER BY x.o", 'bar', {'x': '口径', 'y': '元/股'})),
        ('debt', '带息负债（亿元，年末）', c(
            "SELECT h.year::text AS year, round(h.interest_debt::numeric, 0) AS debt FROM vi_fin_history h "
            + CO.format(t='h') + " WHERE h.interest_debt IS NOT NULL ORDER BY year", 'bar', {'x': 'year', 'y': 'debt'})),
        ('hist_np', '历史：归母净利润与分红总额（亿元）', c(
            "SELECT h.year, x.item, x.amount FROM vi_fin_history h " + CO.format(t='h') +
            " CROSS JOIN LATERAL (VALUES ('归母净利润', h.np_parent), ('分红总额', h.dividend_total)) x(item, amount) "
            "WHERE x.amount IS NOT NULL ORDER BY h.year, x.item", 'line', {'x': 'year', 'y': 'amount', 'series': 'item'})),
        ('hist_cash', '历史：经营现金流与资本开支（亿元）', c(
            "SELECT h.year, x.item, x.amount FROM vi_fin_history h " + CO.format(t='h') +
            " CROSS JOIN LATERAL (VALUES ('经营现金流', h.cfo), ('资本开支', h.capex)) x(item, amount) "
            "WHERE x.amount IS NOT NULL ORDER BY h.year, x.item", 'bar', {'x': 'year', 'y': 'amount', 'series': 'item'})),
        ('hist_quality', '历史：毛利率与 ROE（%）', c(
            "SELECT h.year, x.item, round((x.v * 100)::numeric, 1) AS pct FROM vi_fin_history h "
            + CO.format(t='h') + " CROSS JOIN LATERAL (VALUES ('毛利率', h.gross_margin), ('ROE', h.roe)) x(item, v) "
            "WHERE x.v IS NOT NULL ORDER BY h.year, x.item", 'line', {'x': 'year', 'y': 'pct', 'series': 'item'})),
        ('hist_vol', f"历史：{co.get('volume_label') or '业务量'}（{co.get('volume_unit') or ''}）", c(
            "SELECT h.year, round(h.volume::numeric, CASE WHEN h.volume < 100 THEN 3 ELSE 0 END) AS \"业务量\" FROM vi_fin_history h " + CO.format(t='h') +
            " WHERE h.volume IS NOT NULL ORDER BY h.year", 'bar', {'x': 'year', 'y': '业务量'})),
        ('fit', '价投适配度（各维度 0—5 分）', c(
            "SELECT f.dimension AS \"维度\", f.score AS \"评分\" FROM vi_fit_score_base f " + CO.format(t='f') + " ORDER BY f.sort, f.id",
            'barHorizontal', {'x': '维度', 'y': '评分'})),
        ('moat', '竞争壁垒：强度与判定', raw(
            "SELECT m.code AS code, m.title AS name, CASE m.strength WHEN '强' THEN 3 WHEN '中' THEN 2 WHEN '弱' THEN 1 ELSE 0 END AS v, "
            "coalesce(m.verdict, '待验证') AS grp FROM vi_moat_base m " + CO.format(t='m') + " ORDER BY length(m.code), m.code",
            HBAR.replace('__GROUPS__', MOAT_GROUPS).replace('__MIN__', '0'))),
        ('forces', '产业链与五力：有利还是不利', raw(
            "SELECT v.code AS code, v.participant || CASE WHEN v.force IS NULL OR v.force = '不适用' THEN '' ELSE '（' || v.force || '）' END AS name, "
            "CASE v.power WHEN '强' THEN 3 WHEN '中' THEN 2 ELSE 1 END * CASE v.effect WHEN '有利' THEN 1 WHEN '不利' THEN -1 ELSE 0 END AS v, "
            "coalesce(v.effect, '中性') AS grp FROM vi_value_chain_base v " + CO.format(t='v') + " ORDER BY length(v.code), v.code",
            HBAR.replace('__GROUPS__', FORCE_GROUPS).replace('__MIN__', '-3'))),
        ('peers', '竞争对手对比（%）：付费率、毛利率、增速', c(
            "SELECT c.name AS \"对手\", x.k AS \"指标\", round((x.v * 100)::numeric, 1) AS \"%\" FROM vi_competitor_base c " + CO.format(t='c') +
            " CROSS JOIN LATERAL (VALUES ('付费率或渗透率', c.paying_rate), ('毛利率', c.gross_margin), ('增速', c.growth)) x(k, v) WHERE x.v IS NOT NULL "
            "UNION ALL SELECT co.name || '（本公司）', x.k, round((x.v * 100)::numeric, 1) FROM vi_fin_history h "
            + CO.format(t='h') + " CROSS JOIN LATERAL (VALUES ('毛利率', h.gross_margin), ('增速', h.revenue_yoy)) x(k, v) "
            "WHERE x.v IS NOT NULL AND h.year = (SELECT max(h2.year) FROM vi_fin_history h2 WHERE h2.company_id = h.company_id) ORDER BY 1, 2", 'bar',
            {'x': '对手', 'y': '%', 'series': '指标'})),
        ('theses', '核心论点：裁决（成立 / 观察 / 存疑 / 证伪）', c(
            "SELECT coalesce(t.status, '未裁决') AS \"裁决\", count(*) AS n FROM vi_thesis_base t " + CO.format(t='t') + " GROUP BY 1 ORDER BY 2 DESC",
            'pie', {'category': '裁决', 'value': 'n'})),
        ('quarter', '经营数据：单季同比（%）', c(
            "SELECT d.period, d.line_item, round((d.yoy * 100)::numeric, 1) AS \"同比（%）\" FROM vi_disclosed d " + CO.format(t='d') +
            " WHERE d.period_kind = '单季' AND d.yoy IS NOT NULL AND d.period_end >= vi_today() - interval '3 years' ORDER BY d.period_end, d.line_item", 'bar',
            {'x': 'period', 'y': '同比（%）', 'series': 'line_item'})),
        ('checks', '质量自检结果', c(
            "SELECT k.result, count(*) AS n FROM vi_check k " + CO.format(t='k') +
            " GROUP BY k.result ORDER BY k.result", 'pie', {'category': 'result', 'value': 'n'})),
        ('facts', '定性事实核验状态', c(
            "SELECT f.verify_status, count(*) AS n FROM vi_fact_base f " + CO.format(t='f') +
            " GROUP BY f.verify_status ORDER BY n DESC", 'pie', {'category': 'verify_status', 'value': 'n'})),
        ('price', '市场：股价（元；境外报价按当日汇率折算）', c(
            "SELECT o.obs_date, round((CASE WHEN co.price_fx_metric_id IS NULL THEN o.value ELSE o.value * fx.value END)::numeric, 2) AS \"股价\" "
            "FROM vi_obs_current o JOIN vi_company_base co ON co.price_metric_id = o.metric_id "
            f"AND co.code = '{code}' LEFT JOIN LATERAL (SELECT x.value FROM vi_obs_current x WHERE x.metric_id = co.price_fx_metric_id "
            "AND x.obs_date <= o.obs_date ORDER BY x.obs_date DESC LIMIT 1) fx ON true ORDER BY o.obs_date", 'line', {'x': 'obs_date', 'y': '股价'})),
        ('rf', '市场：中债国债10年收益率（%）', c(obs('CGB10Y.CCDC'), 'line', {'x': 'obs_date', 'y': '数值'})),
    ]
    have = content(code)
    needs = {'fit': 'fit', 'moat': 'moat', 'forces': 'chain', 'peers': 'comp', 'theses': 'thesis', 'gw_layers': 'gw'}
    out = [x for x in out if have.get(needs.get(x[0]), 1) > 0]      # 没有内容的通用图不放（如还没做三层估值或还没填商业模式分析的公司）
    result = out + EXTRA.get(code, [])
    if code == '01698.HK':
        from tencent_dashboard import charts as tencent_charts
        return tencent_charts(result)
    from company_dashboard import PROFILES, charts as company_charts
    if code in PROFILES:
        return company_charts(code, result)
    return result


def content(code):
    """这家公司有哪些可画的内容：三层估值、适配度、壁垒、产业链、竞争对手、论点。"""
    co = f"(SELECT id FROM vi_company_base WHERE code = '{code}')"
    sql = (f"SELECT json_build_object('gw', (SELECT count(*) FROM vi_epv_base WHERE company_id = {co}), "
           f"'fit', (SELECT count(*) FROM vi_fit_score_base WHERE company_id = {co}), 'moat', (SELECT count(*) FROM vi_moat_base WHERE company_id = {co}), "
           f"'chain', (SELECT count(*) FROM vi_value_chain_base WHERE company_id = {co}), 'comp', (SELECT count(*) FROM vi_competitor_base WHERE company_id = {co}), "
           f"'thesis', (SELECT count(*) FROM vi_thesis_base WHERE company_id = {co}))")
    p = subprocess.run([str(ROOT / 'psql.sh'), '-At', '-c', 'SET jit=off', '-c', sql], capture_output=True, text=True, check=True)
    return json.loads(p.stdout.strip().split('\n')[-1])


EXTRA = {   # 行业专属图表
    '600900.SH': [('level', '市场：三峡水库水位（米）', c(obs('SX.LEVEL'), 'line', {'x': 'obs_date', 'y': '数值'})),
                  # 同业对比（companies/600900_长江电力/track.py）：同口径，四家 A 股水电中位数
                  ('peer_roe', '同业：ROE，长江电力 vs 四家水电中位数（%）', c(
                      "SELECT s.period, CASE m.name WHEN '归母ROE（同业口径）' THEN '长江电力' ELSE '四家水电中位数' END AS \"口径\", round(s.value::numeric, 2) AS \"数值（%）\" FROM vi_series s JOIN vi_metric_base m ON m.id = s.metric_id AND m.company_id = (SELECT id FROM vi_company_base WHERE code = '600900.SH') AND m.name IN ('归母ROE（同业口径）', '同业ROE中位数（四家水电）') WHERE s.basis = '全年' ORDER BY s.period, 2", 'line', {'x': 'period', 'y': '数值（%）', 'series': '口径'}))],
    '002078.SZ': [
        ('pulp', '市场：纸浆与胶版纸（元/吨）', c(
            "SELECT o.obs_date, CASE mt.code WHEN 'SP.SHFE.SINA' THEN '纸浆期货' WHEN 'OP.SHFE.SINA' THEN '胶版纸期货' ELSE '纸浆现货' END AS \"口径\", "
            "o.value AS \"价格\" FROM vi_obs_current o JOIN vi_metric_base mt ON mt.id = o.metric_id "
            "WHERE mt.code IN ('SP.SHFE.SINA', 'OP.SHFE.SINA', 'SP.SPOT.100PPI') AND o.obs_date >= current_date - 730 ORDER BY o.obs_date, 2", 'line',
            {'x': 'obs_date', 'y': '价格', 'series': '口径'})),
        # 成本优势的度量（companies/002078_太阳纸业/track.py）：同一口径的单季毛利率，同业中位数＝太阳纸业 − 领先幅度
        ('peer_gm', '同业：单季毛利率，太阳纸业 vs 七家同业中位数（%）', c(
            "SELECT x.period, x.k AS \"口径\", round(x.v::numeric, 2) AS \"毛利率（%）\" FROM ("
            "SELECT s.period, s.obs_date, '太阳纸业' AS k, s.value AS v FROM vi_series s JOIN vi_metric_base m ON m.id = s.metric_id "
            "AND m.name = '毛利率' AND m.company_id = (SELECT id FROM vi_company_base WHERE code = '002078.SZ') WHERE s.basis = '单季' "
            "UNION ALL SELECT l.period, l.obs_date, '七家同业中位数', g.value - l.value FROM vi_series l "
            "JOIN vi_metric_base lm ON lm.id = l.metric_id AND lm.name = '毛利率领先同业中位数' "
            "JOIN vi_metric_base gm ON gm.company_id = lm.company_id AND gm.name = '毛利率' "
            "JOIN vi_series g ON g.metric_id = gm.id AND g.period = l.period AND g.basis = '单季' WHERE l.basis = '单季' "
            "AND lm.company_id = (SELECT id FROM vi_company_base WHERE code = '002078.SZ')) x "
            "WHERE x.obs_date >= vi_today() - interval '3 years' ORDER BY x.obs_date, 2", 'line',
            {'x': 'period', 'y': '毛利率（%）', 'series': '口径'})),
        ('gm_q', '经营数据：单季毛利率（%）', c(
            "SELECT d.period, d.value AS \"毛利率（%）\" FROM vi_disclosed d JOIN vi_company_base co ON co.id = d.company_id "
            "AND co.code = '002078.SZ' WHERE d.line_item = '毛利率' AND d.period_kind = '单季' AND d.period_end >= vi_today() - interval '3 years' ORDER BY d.period_end", 'line', {'x': 'period', 'y': '毛利率（%）'})),
    ],
    '601668.SH': [
        # 同业对比（companies/601668_中国建筑/track.py）：同口径，六家建筑央企中位数
        ('peer_roe', '同业：ROE，中国建筑 vs 六家建筑央企中位数（%）', c(
            "SELECT s.period, CASE m.name WHEN '归母ROE（同业口径）' THEN '中国建筑' ELSE '六家建筑央企中位数' END AS \"口径\", round(s.value::numeric, 2) AS \"数值（%）\" FROM vi_series s JOIN vi_metric_base m ON m.id = s.metric_id AND m.company_id = (SELECT id FROM vi_company_base WHERE code = '601668.SH') AND m.name IN ('归母ROE（同业口径）', '同业ROE中位数（六家建筑央企）') WHERE s.basis = '全年' ORDER BY s.period, 2", 'line',
            {'x': 'period', 'y': '数值（%）', 'series': '口径'})),
        ('peer_ar', '同业：（应收账款＋合同资产）÷营业收入，中国建筑 vs 同业中位数（%）', c(
            "SELECT s.period, CASE m.name WHEN '（应收账款＋合同资产）÷营业收入' THEN '中国建筑' ELSE '六家建筑央企中位数' END AS \"口径\", round(s.value::numeric, 2) AS \"数值（%）\" FROM vi_series s JOIN vi_metric_base m ON m.id = s.metric_id AND m.company_id = (SELECT id FROM vi_company_base WHERE code = '601668.SH') AND m.name IN ('（应收账款＋合同资产）÷营业收入', '同业（应收账款＋合同资产）÷营业收入中位数') WHERE s.basis = '全年' ORDER BY s.period, 2", 'line',
            {'x': 'period', 'y': '数值（%）', 'series': '口径'})),
        ('conv', '历史：收入转化率（营业收入÷新签合同总额）', c(
            "SELECT h.year, round(h.price::numeric, 3) AS \"收入转化率\" FROM vi_fin_history h "
            "JOIN vi_company_base co ON co.id = h.company_id AND co.code = '601668.SH' WHERE h.price IS NOT NULL ORDER BY h.year", 'line',
            {'x': 'year', 'y': '收入转化率'})),
        ('wc', '应收账款＋合同资产、应付票据及账款 vs 营业收入（亿元）', c(
            "SELECT left(d.period, 4) AS period, d.line_item AS \"项目\", round(d.value::numeric, 0) AS \"亿元\" FROM vi_disclosed d "
            "JOIN vi_company_base co ON co.id = d.company_id AND co.code = '601668.SH' "
            "WHERE d.period_kind = '时点' AND d.period LIKE '%Q4' AND d.period >= '2019' AND d.line_item IN ('应收账款＋合同资产', '应付票据及应付账款') "
            "UNION ALL SELECT h.year::text, '营业收入', round(h.revenue::numeric, 0) FROM vi_fin_history h "
            "JOIN vi_company_base co ON co.id = h.company_id AND co.code = '601668.SH' WHERE h.year >= 2019 ORDER BY 1, 2", 'bar',
            {'x': 'period', 'y': '亿元', 'series': '项目'})),
        ('imp', '资产及信用减值损失（亿元）', c(
            "SELECT d.period, round(d.value::numeric, 1) AS \"减值\" FROM vi_disclosed d "
            "JOIN vi_company_base co ON co.id = d.company_id AND co.code = '601668.SH' "
            "WHERE d.line_item = '资产及信用减值损失' AND d.period_kind = '全年' AND d.period >= '2019' ORDER BY d.period_end", 'bar', {'x': 'period', 'y': '减值'})),
    ],
    '01698.HK': [
        ('rev_mix', '单季收入结构（亿元）：会员、非订阅音乐、社交娱乐', c(
            "SELECT d.period, d.line_item AS \"项目\", d.value AS \"亿元\" FROM vi_disclosed d JOIN vi_company_base co ON co.id = d.company_id AND co.code = '01698.HK' "
            "WHERE d.period_kind = '单季' AND d.line_item IN ('会员（订阅）收入', '非订阅音乐收入（广告、演出、周边）', '社交娱乐及其他收入') "
            "ORDER BY d.period_end, 2", 'bar', {'x': 'period', 'y': '亿元', 'series': '项目'})),
        ('sub_yoy', '单季同比（%）：会员 vs 社交娱乐 vs 总收入', c(
            "SELECT d.period, d.line_item AS \"项目\", round((d.yoy * 100)::numeric, 1) AS \"同比（%）\" FROM vi_disclosed d JOIN vi_company_base co ON co.id = d.company_id AND co.code = '01698.HK' "
            "WHERE d.period_kind = '单季' AND d.yoy IS NOT NULL AND d.period_end >= '2024-01-01' AND d.line_item IN ('会员（订阅）收入', '社交娱乐及其他收入', '营业收入') "
            "ORDER BY d.period_end, 2", 'line', {'x': 'period', 'y': '同比（%）', 'series': '项目'})),
        ('gm_q', '单季毛利率（%）：摩根大通警戒线约 42%', c(
            "SELECT d.period, d.value AS \"毛利率（%）\" FROM vi_disclosed d JOIN vi_company_base co ON co.id = d.company_id AND co.code = '01698.HK' "
            "WHERE d.line_item = '毛利率' AND d.period_kind = '单季' AND d.period_end >= vi_today() - interval '3 years' ORDER BY d.period_end", 'line', {'x': 'period', 'y': '毛利率（%）'})),
        ('users', '在线音乐月活与付费用户（百万人；2026 年起停止季度披露）', c(
            "SELECT d.period, d.line_item AS \"项目\", d.value AS \"百万人\" FROM vi_disclosed d JOIN vi_company_base co ON co.id = d.company_id AND co.code = '01698.HK' "
            "WHERE d.line_item IN ('在线音乐月活跃用户', '在线音乐付费用户') ORDER BY d.period_end, 2", 'bar',
            {'x': 'period', 'y': '百万人', 'series': '项目'})),
        ('cash', '现金与定期存款 vs 带息负债（亿元）', c(
            "SELECT h.year::text AS year, x.item AS \"项目\", x.v AS \"亿元\" FROM vi_fin_history h JOIN vi_company_base co ON co.id = h.company_id AND co.code = '01698.HK' "
            "CROSS JOIN LATERAL (VALUES ('现金与定期存款', h.cash), ('带息负债', h.interest_debt)) x(item, v) WHERE h.year >= 2019 "
            "UNION ALL SELECT d.period, CASE WHEN d.line_item LIKE '现金%' THEN '现金与定期存款' ELSE '带息负债' END, d.value "
            "FROM vi_disclosed d JOIN vi_company_base co ON co.id = d.company_id AND co.code = '01698.HK' WHERE d.period = '2026Q2' "
            "AND (d.line_item LIKE '现金%' OR d.line_item LIKE '带息负债%') ORDER BY 1, 2", 'bar', {'x': 'year', 'y': '亿元', 'series': '项目'})),
        ('payout', '股东回报率（股息＋回购÷归母净利，%）：历史', c(
            "SELECT h.year::text AS year, '历史' AS \"口径\", round((h.payout * 100)::numeric, 1) AS \"%\" FROM vi_fin_history h "
            "JOIN vi_company_base co ON co.id = h.company_id AND co.code = '01698.HK' WHERE h.year >= 2020 AND h.payout IS NOT NULL "
            "ORDER BY 1", 'bar', {'x': 'year', 'y': '%', 'series': '口径'})),
        ('fx', '市场：港元兑人民币', c(obs('HKDCNY'), 'line', {'x': 'obs_date', 'y': '数值'})),
    ],    '01810.HK': [
        ('seg_rev', '单季分部收入（亿元）：手机×AIoT vs 智能电动汽车及 AI', c(
            "SELECT d.period, d.line_item AS \"项目\", d.value AS \"亿元\" FROM vi_disclosed d JOIN vi_company_base co ON co.id = d.company_id AND co.code = '01810.HK' "
            "WHERE d.period_kind = '单季' AND d.line_item IN ('手机×AIoT 分部收入', '智能电动汽车及AI分部收入') ORDER BY d.period_end, 2", 'bar',
            {'x': 'period', 'y': '亿元', 'series': '项目'})),
        ('seg_profit', '单季经营损益（亿元）：生态（推算）vs 汽车及 AI 分部（含 AI 投入）', c(
            "SELECT d.period, d.line_item AS \"项目\", d.value AS \"亿元\" FROM vi_disclosed d JOIN vi_company_base co ON co.id = d.company_id AND co.code = '01810.HK' "
            "WHERE d.period_kind = '单季' AND d.line_item IN ('生态经营利润（推算）', '汽车及AI分部经营损益') ORDER BY d.period_end, 2", 'bar',
            {'x': 'period', 'y': '亿元', 'series': '项目'})),
        ('eco_margin', '生态经营利润率（%）：年度与单季（推算；估值把手机、AIoT、互联网分开，基准正常化合计约 7.9%）', c(
            "SELECT d.period, d.value AS \"利润率（%）\" FROM vi_disclosed d JOIN vi_company_base co ON co.id = d.company_id AND co.code = '01810.HK' "
            "WHERE d.line_item = '生态经营利润率（推算）' ORDER BY d.period_end, d.period_kind", 'line', {'x': 'period', 'y': '利润率（%）'})),
        ('gm_lines', '单季毛利率（%）：手机、IoT、互联网、汽车及 AI', c(
            "SELECT d.period, d.line_item AS \"项目\", d.value AS \"毛利率（%）\" FROM vi_disclosed d JOIN vi_company_base co ON co.id = d.company_id AND co.code = '01810.HK' "
            "WHERE d.period_kind = '单季' AND d.line_item IN ('智能手机毛利率', 'IoT毛利率', '互联网服务毛利率', '汽车及AI分部毛利率') ORDER BY d.period_end, 2", 'line',
            {'x': 'period', 'y': '毛利率（%）', 'series': '项目'})),
        ('gm_lines_y', '年度毛利率与生态费用率（%）：手机、IoT、互联网（估值正常化：手机 11.8%、AIoT 20%、互联网 76.5%、费用率 14%）', c(
            "SELECT d.period, CASE d.line_item WHEN '智能手机毛利率' THEN '手机毛利率' WHEN 'IoT毛利率' THEN 'IoT 毛利率' WHEN '互联网服务毛利率' THEN '互联网毛利率' "
            "ELSE '生态费用率' END AS \"项目\", d.value AS \"%\" FROM vi_disclosed d JOIN vi_company_base co ON co.id = d.company_id AND co.code = '01810.HK' "
            "WHERE d.period_kind = '全年' AND d.line_item IN ('智能手机毛利率', 'IoT毛利率', '互联网服务毛利率', '生态营业费用率（推算）') ORDER BY d.period_end, 2", 'line',
            {'x': 'period', 'y': '%', 'series': '项目'})),
        ('line_op', '按收入分摊费用后的年度经营利润（亿元）：手机是获客成本，利润来自互联网与 AIoT', c(
            "SELECT d.period, CASE d.line_item WHEN '智能手机经营利润（分摊）' THEN '手机' WHEN 'AIoT经营利润（分摊）' THEN 'AIoT' ELSE '互联网' END AS \"项目\", "
            "d.value AS \"亿元\" FROM vi_disclosed d JOIN vi_company_base co ON co.id = d.company_id AND co.code = '01810.HK' "
            "WHERE d.period_kind = '全年' AND d.line_item IN ('智能手机经营利润（分摊）', 'AIoT经营利润（分摊）', '互联网服务经营利润（分摊）') ORDER BY d.period_end, 2", 'bar',
            {'x': 'period', 'y': '亿元', 'series': '项目'})),
        ('ship', '智能手机出货（百万台）：存储涨价下“控量保价”', c(
            "SELECT d.period, d.value AS \"百万台\" FROM vi_disclosed d JOIN vi_company_base co ON co.id = d.company_id AND co.code = '01810.HK' "
            "WHERE d.line_item = '智能手机出货量' ORDER BY d.period_end, d.period_kind", 'bar', {'x': 'period', 'y': '百万台'})),
        ('asp', '智能手机 ASP（元）', c(
            "SELECT d.period, d.value AS \"元\" FROM vi_disclosed d JOIN vi_company_base co ON co.id = d.company_id AND co.code = '01810.HK' "
            "WHERE d.line_item = '智能手机ASP' ORDER BY d.period_end", 'line', {'x': 'period', 'y': '元'})),
        ('ev', '汽车交付（辆）', c(
            "SELECT d.period, d.value AS \"辆\" FROM vi_disclosed d JOIN vi_company_base co ON co.id = d.company_id AND co.code = '01810.HK' "
            "WHERE d.line_item = '汽车交付量' AND d.period_kind = '单季' ORDER BY d.period_end", 'bar', {'x': 'period', 'y': '辆'})),
        ('mau', '全球月活跃用户（百万人）：年末与季末', c(
            "SELECT d.period, d.value AS \"百万人\" FROM vi_disclosed d JOIN vi_company_base co ON co.id = d.company_id AND co.code = '01810.HK' "
            "WHERE d.line_item IN ('全球月活跃用户（12 月）', '全球月活跃用户') ORDER BY d.period_end, d.period_kind", 'bar', {'x': 'period', 'y': '百万人'})),
        ('cash_q', '现金储备与借款（亿元，季末）', c(
            "SELECT d.period, d.line_item AS \"项目\", d.value AS \"亿元\" FROM vi_disclosed d JOIN vi_company_base co ON co.id = d.company_id AND co.code = '01810.HK' "
            "WHERE d.line_item IN ('现金储备', '借款') AND d.period_end >= '2025-01-01' ORDER BY d.period_end, 2", 'bar', {'x': 'period', 'y': '亿元', 'series': '项目'})),
        ('fx', '市场：港元兑人民币', c(obs('HKDCNY'), 'line', {'x': 'obs_date', 'y': '数值'})),
    ],
}


def apply_page(name, body):
    path = HERE / 'blueprints' / f'{name}.json'
    path.parent.mkdir(exist_ok=True)
    path.write_text(json.dumps(body, ensure_ascii=False, indent=1))
    p = subprocess.run(['nb', 'api', 'flow-surfaces', 'apply-blueprint', '--body-file', str(path), '-j'],
                       capture_output=True, text=True, cwd=ROOT)
    if p.returncode:
        raw = p.stdout + p.stderr                     # nb 把失败的响应写在 stderr
        out = raw[raw.find('{'):raw.rfind('}') + 1]
        try:
            for e in json.loads(out).get('errors', []):
                print(' -', e.get('ruleId'), e.get('path'), '|', e.get('message')[:260])
        except Exception:
            print(raw[-1500:])
        sys.exit(1)


def record(key, group_id, title):
    page = child_page(group_id, title)
    st = state()
    st['pages'][key] = {'routeId': page['id'], 'pageSchemaUid': page.get('schemaUid')}
    STATE.write_text(json.dumps(st, ensure_ascii=False, indent=1))
    print(title, key, 'OK')


def company_info(co):
    p = subprocess.run([str(ROOT / 'psql.sh'), '-At', '-c',
                        f"SELECT row_to_json(t) FROM (SELECT volume_label, volume_unit FROM vi_company_base WHERE code = '{co['code']}') t"],
                       capture_output=True, text=True, check=True)
    return co | json.loads(p.stdout)


def kpi_code(code):
    """驾驶舱顶部的关键读数：现价与三层价值（price_summary.jsx）、主估值层与隐含回报（dashboard_kpi.jsx）。"""
    st = state()['pages']
    links = [{'title': t, 'href': '/admin/' + st[f'{k}@{code}']['pageSchemaUid']}
             for k, t in (('gw_equity', '⑤ 股权价值'), ('gw_epv', '② 盈利能力'), ('thesis', '核心论点')) if f'{k}@{code}' in st]
    from company_dashboard import PROFILES
    focus = PROFILES.get(code, {}).get('focus', '')
    cfg = json.dumps({'code': code, 'links': links, 'focus': focus}, ensure_ascii=False)
    return (HERE / 'price_summary.jsx').read_text() + '\n' + (HERE / 'dashboard_kpi.jsx').read_text().replace('__CONFIG__', cfg)


def dashboard_document(co, replace=False):
    co = company_info(co)
    st = state()
    gid = company_root(st, co)
    cs = charts(co)
    keys = [k for k, _, _ in cs]
    blocks = [{'key': 'kpi', 'type': 'jsBlock', 'title': '关键读数', 'script': 'kpi'},
              {'key': 'collect', 'type': 'jsBlock', 'title': '数据采集', 'script': 'collect'}] + \
             [{'key': k, 'type': 'chart', 'title': t, 'chart': k} for k, t, _ in cs]
    rows = [[{'key': 'kpi', 'span': 24}], [{'key': 'collect', 'span': 24}]] + \
           [[{'key': k, 'span': 8} for k in keys[i:i + 3]] for i in range(0, len(keys), 3)]
    from company_dashboard import PROFILES
    if co['code'] == '01698.HK' or co['code'] in PROFILES:
        from tencent_dashboard import layout
        rows = layout(keys)
        for block in blocks:
            if block['type'] == 'chart':
                block['settings'] = {'height': 360, 'heightMode': 'specifyValue'}
    body = {
        'version': '1', 'mode': 'create',
        'navigation': {'group': {'routeId': gid}, 'item': {'title': '驾驶舱', 'icon': 'DashboardOutlined'}},
        'page': {'title': '驾驶舱', 'documentTitle': f"{co['name']} · 驾驶舱"},
        'assets': {'scripts': {'kpi': {'version': 'v2', 'code': kpi_code(co['code'])},
                               'collect': {'version': 'v2', 'code': collect_js(co['code'])}},
                   'charts': {k: v for k, _, v in cs}},
        'tabs': [{'title': '驾驶舱', 'layout': {'rows': rows}, 'blocks': blocks}]}
    if replace:
        body['mode'] = 'replace'
        body['target'] = {'pageSchemaUid': st['pages'][f"dashboard@{co['code']}"]['pageSchemaUid']}
        del body['navigation']
    return body


def dashboard(co, replace=False):
    apply_page(f"dashboard_{co['code']}", dashboard_document(co, replace=replace))
    if replace:
        print(co['name'], '驾驶舱原地址更新 OK')
        return
    st = state()
    gid = company_root(st, co)
    record(f"dashboard@{co['code']}", gid, '驾驶舱')


def collect_js(code):
    """按钮按 key 找工作流的当前版本（新建版本后 id 会变，key 不变），用来显示是否已启用。"""
    wf = json.loads((HERE / 'workflows_state.json').read_text()) if (HERE / 'workflows_state.json').exists() else {}
    flows = {'manual': wf.get('manual', {}).get('key'), 'scheduled': [wf[n]['key'] for n in ('collect', 'ingest', 'selfcheck') if n in wf]}
    js = COLLECT.replace('__FLOWS__', json.dumps(flows, ensure_ascii=False)).replace('__COMPANY__', code)
    from company_dashboard import PROFILES
    if code == '01698.HK' or code in PROFILES:
        from tencent_dashboard import collect_code
        return collect_code(js)
    return js


def doc(key, title, icon, content):
    st = state()
    gid = shared_root(st)
    apply_page(key, {'version': '1', 'mode': 'create',
                     'navigation': {'group': {'routeId': gid}, 'item': {'title': title, 'icon': icon}},
                     'page': {'title': title, 'documentTitle': f'价值投资框架 · {title}'},
                     'tabs': [{'title': title, 'blocks': [{'type': 'markdown', 'settings': {'content': content}}]}]})
    record(key, gid, title)


DOCS = (('doc_guide', '使用说明', 'ReadOutlined', GUIDE),
        ('doc_structure', '数据结构', 'ApartmentOutlined', None),          # 按线上菜单生成（struct_doc.py）
        ('doc_formulas', '模型公式', 'FunctionOutlined', FORMULAS))


if __name__ == '__main__':
    cos = companies()
    if '--refresh-dashboard' in sys.argv:
        only = {a for a in sys.argv[1:] if not a.startswith('--')}
        if not only:
            sys.exit('请明确指定需要原地址更新的公司代码')
        for co in cos:
            if co['code'] in only:
                dashboard(co, replace=True)
        sys.exit(0)
    if '--rebuild-dashboard' in sys.argv:          # 后面可跟公司代码，只重建这几家
        only = {a for a in sys.argv[1:] if not a.startswith('--')}
        for co in cos:
            if not only or co['code'] in only:
                destroy_page(f"dashboard@{co['code']}")
    if '--rebuild-docs' in sys.argv:
        for key, *_ in DOCS:
            destroy_page(key)
    built = [co for co in cos if f"dashboard@{co['code']}" not in state()['pages']]
    for co in built:
        dashboard(co)
    if built:                                      # 新建的页面排在菜单最后；驾驶舱要回到公司菜单最上面（点公司时默认打开）
        from build_pages import sort_menu
        sort_menu({co['code'] for co in built})
    for key, title, icon, content in DOCS:
        if key not in state()['pages']:
            if content is None:
                import struct_doc
                content = struct_doc.render()
            doc(key, title, icon, content)
