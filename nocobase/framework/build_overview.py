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

> 数据库设计说明已于 2026-10-29 核验更新。请打开 [数据结构与最近变化](/admin/vsha1l0e5il)，先看“最近发生了什么”，再看数据分工、预测与估值路径、表清单及关系图。

这是一套**可复用的价值投资研究框架**。每家公司都按同一条链研究：

**来源文档 → 定性事实与指标 → 商业模式、产业链与竞争对手 → 竞争壁垒 → 核心论点 → 风险分析 → 假设依据 → 逐年假设 → 预测计算 → 估值结论 → 跟踪与证伪**

先回答“这门生意凭什么持续赚钱”，再回答“值多少钱”。

## 菜单怎么看
- **每家公司一个顶层菜单**（现在有长江电力、太阳纸业、中国建筑、腾讯音乐、小米集团），点进去只看到这家公司的数据：驾驶舱，以及四组页面：**商业模式**（只放分析）、**经营与财务**（财务报表、定量指标、定性事实）、**预测与估值**（财务模型 → 估值模型 → 假设依据）、**研究维护**（来源文档、质量自检、待办清单、变更日志）。各公司的数据在同一个数据库里，但页面互不混。
- **宏观数据**（独立项目）：利率、汇率、大宗商品等不属于任何公司的数据（指标、高频数据、采集配置）。各公司按需使用：估值参数（无风险利率、股价汇率）和重点跟踪（假设依据、风险关联的指标）直接引用；其他想看的在「框架与后台 / 公司」里勾选“订阅的宏观数据”。公司菜单里「定量指标」的高频经营标签只展示经营、水文和商品指标；股价、利率与汇率在驾驶舱及宏观数据查看。驾驶舱“立即采集一次”仍采这家公司需要的所有指标。
- **框架与后台**：这三篇说明、公司列表（含订阅的宏观数据）、全部指标定义，以及自动采集（采集配置、采集运行、原始采集记录、全部数据）。

## 每天/每周怎么用
1. **<公司> / 驾驶舱**：看今天每股价值、市场价、按要求收益率的最高买入价和质量自检。
   想看某一年的利润、现金、资产负债是怎么算出来的，打开 **<公司> / 预测与估值 / 财务模型**：选情景和年份，瀑布图逐步展示营收 → 利润 → 股息 → 现金，另有一页资产与资本。
2. **<公司> / 研究维护 / 质量自检**：先看“阻断”和“提示”，它们说明结论能不能用。
3. **<公司> / 经营与财务**：按“原始报表 → 定量指标 → 定性事实”排列。**财务报表**是季度完整三大报表（只读）；**定量指标**每个指标一行，“趋势”列是主口径最近 12 期的小折线（主口径不足两期时用数据最多的口径，下方写起止统计时间），点“查看”看大图、逐期数据并录入新一期，这家公司的全部指标分四个标签：“定期经营”是发电量、浆纸销量、合同额、开工面积、用户、设备数与单位售价，“高频经营”是水位、流量等自动采集的经营指标，“财务指标”是全部财务数（报表里有的科目与比率按报表公式实时算，报表外的分部收入、股息、净借款等在这里录入），“宏观与市场”是利率、汇率、商品价格和股价。“模型字段”列说明这个数进财务模型的哪一项，“重点跟踪”列出盯着它的假设依据和风险。想更新自动采集指标，可按驾驶舱的 **立即采集一次**；该按钮仍采集这家公司需要的全部数据源。
4. 有新公告或财报：先在 **研究维护 / 来源文档** 登记原件，按期数字录进对应指标，数字以外的事写 **定性事实**；结论有变化先改 **核心论点**（裁决、改判条件），需要改假设时写 **预测与估值 / 假设依据**，然后改 **逐年假设**，最后在 **变更日志** 记录旧值、新值与理由。
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
6. **风险分析**：会让这笔投资亏钱的不利事件。每条写传导路径、可能性与冲击（系统按可能性×冲击自动定级为重大、重要、一般）、影响测算、缓冲因素、在估值里怎么处理（基准情景、悲观情景、折现率或未计入）、预警信号与触发后应对。论证不在这里重复：关联会被削弱的论点（自动显示其当前裁决）、估值对应的假设依据、盯着的预警指标（汇总在「经营与财务 / 重点跟踪」）。
7. **价投适配度**：顶部是结论看板（总分、归类、八个维度的分数条、强项与短板），下方表格录入。长坡、厚雪、慢变、护城河、再投资、财务质量、治理配置、可估值性，各 0—5 分并写反证，关联支撑它的论点。总分 32—40 适合复利框架，22—31 合适（要说明更偏复利、现金流价值还是资产价值），21 以下通常不符合。
证据在「经营与财务」，上层判断（商业模式、壁垒、论点、假设依据、逐年假设、估值）用两种方式引用：**依据指标**——按期重复的数（经营数字、财务数字、股价、利率、水位）只放在 `vi_metric_base`（序列定义）和 `vi_observation_base`（每期值）里，引用指标就能看到趋势和逐期数据；**依据事实**——定性事实分两层：`vi_event_base`（事项，一件事：短名称＋简介）下挂若干 `vi_fact_base`（侧面，各有日期、来源、核验状态），在「经营与财务 / 定性事实」先看事项、点开看各侧面的时间线；上层引用具体侧面。定性事实写数字以外、会改变判断的事（制度监管、合作授权、并购与资本运作、人事、诉讼、管理层表态、竞争对手动作），以及卖方预测、可比估值、同业对比这类外部参照，不重复抄指标里的数。
落到估值的在「预测与估值 / **假设依据**」：事实和论点如何决定每个估值参数（逐年假设、情景、估值模型），改参数的门槛，什么情况下不改。

**每个观点只写一处**：描述性的内容放商业模式、产业链、竞争对手、竞争壁垒；有争议、决定价值的判断放核心论点（对应哪条假设依据在假设依据里关联，论点上自动显示“假设依据（状态）”）；会让人亏钱的事件放风险分析；参数怎么设、什么时候改放假设依据；还没有答案的判断性问题（如“应收能收回多少”）也写成核心论点，缺的证据写在“决定胜负的证据”。「跟踪 / 待办清单」只放做完即关的待办（数据源、核验、模型缺口、等你拍板的策略选择），不放判断。其他地方按编号引用（如“见 T2”“J-P”），不重复论证。

质量自检 C09、C14、C15、C18、C19 会提示：论点的自动检查有没有触发、还有哪些壁垒没辩论、适配度总分与归类、高分维度是否关联了存疑或证伪的论点、重大风险有没有计入估值和预警信号。

## 主估值方法：按生意选，不套一个公式
- **股息贴现**（默认）：只承认分给股东的现金；适合派息稳定、留存少的公司（长江电力）。
- **分部加总**（在估值模型里把“主估值方法”设为分部加总）：核心业务盈利 × 合理倍数 ＋ 可用净现金 ＋ 对外投资（折后）− 少数股东权益。适合“经营业务＋大额现金与持股”的公司（腾讯音乐：主营再拆成三块经营分部，不做逐年预测）。
- **经营分部估值**（分部加总的一种，估值模型的“核心盈利年份”留空）：一家公司里处在不同发展阶段的业务各用一种方法，写在「估值 / 业务估值（编辑）」，每个情景可以有自己的一行：
  - **盈利×倍数**：成熟或周期业务，用正常化盈利（不用周期顶部或底部的当年利润）；倍数按价值驱动公式推导，正常化年份晚于下一年时折回今天，并加上过渡期的现金流。
  - **稳态折现**：成长业务，用稳态年份的盈利 × 退出倍数折回今天（可单独设更高的折现率），加上到稳态前的期间现金流（负数＝还要投钱）。
  - **承诺投入**：投入期业务，只计已承诺投入的税后现值和承诺期后仍得不到回报的年成本，回报不计入。
  - **直接估值**：按可比公司估值、交易价格或主观判断直接给一个整体价值（不折现），适合还没有可靠利润、但有可比估值的业务。
  - 驾驶舱给出“市场隐含成熟业务倍数”和“市场隐含成长业务价值”：其余部分按本模型取值时，现价等于在为哪一部分付多少钱。情景可以填概率，得到概率加权价值。小米集团用这种方法。
  - 核心盈利取预测计算里某一年的核心经营利润（不含利息收入、投资收益与财务费用），按税率与少数股东占比折成归母，可再加减“核心盈利调整”。
  - 合理倍数不手拍：P/E＝(1−永续增长率÷新增投资回报率)÷(折现率−永续增长率)，在“情景”里填新增投资回报率即可，也可手填覆盖。
  - 现金、负债、经营所需现金、资金汇出成本、对外投资、少数股东权益写在「估值 / 资产估值与调整（编辑）」，可以按情景设不同金额与折价。
  - 驾驶舱可拖动“试算倍数”；“市场隐含核心倍数”告诉你市场为核心业务付了几倍。另一种方法作交叉验证，质量自检 C16 会提示两者差距，C17 检查经营分部是否完整、价值是否主要来自尚未成熟的业务。

## 按要求收益率估值（内部收益率视角）
- **要求收益率**（默认 6%）是你自己的门槛回报，即机会成本；在“估值模型”里设置，驾驶舱可以临时拖动并保存为默认。
- **隐含年化收益率**：按今天市场价买入、拿到模型预测的股息并按永续增长率增长，你能得到的年化内部收益率（IRR）。它只取决于价格和现金流，与要求收益率无关。
- **最高买入价**：按要求收益率把未来股息折现到今天的每股价值，也就是想拿到这个回报最多能付的价格。
- 两者等价：隐含收益率 ≥ 要求收益率 ⇔ 市场价 ≤ 最高买入价。三个情景各算一遍，能看到收益率的区间。
- 与“折现率估值”的区别：折现率（无风险利率＋风险溢价）回答“理论上值多少”，要求收益率回答“这个价格买进是否达到我的回报门槛”。
- “现金支持口径”只算 FCFE 能覆盖的股息，结果更保守。隐含收益率包含终值，对永续增长率敏感。

## 改假设的规则
- **按模型路径修改输入**：通用模型改“逐年假设”“情景”“估值模型”；腾讯音乐的财务预测在“财务模型”中维护，估值输入在“估值模型”的业务估值、资产项、情景和模型参数中维护。预测结果和估值结果自动计算，不能手改；财务预测与分部估值的共同年度收入需人工核对，不会跨表自动赋值。
- 逐年假设**每格都显式填写**，没有“留空继承”。批量修改用表格的批量编辑。
- 利息不直接填：改“净借款”和“平均债务成本”，利息按债务滚动自动算出。
- 空白表示“未知”，不是 0。现金桥接有空白时，现金支持价值不输出。
- 市场数据只供对照，不会自动改长期折现率或经营假设。

## 研究一家新公司
1. **框架与后台 / 公司**：新增一行，填业务量/单价的名称与单位，并保证“业务量×单价＝营业收入（亿元）”。
   例：太阳纸业用“万吨 × 万元/吨”（0.40 万元/吨＝4000 元/吨）；中国建筑用“新签合同总额（亿元）× 收入转化率”；腾讯音乐用“付费用户（亿人）× 每付费用户年收入（元）”。
2. **指标 + 采集配置**：加股价指标；采集配置选解析器 `tencent_quote`，参数填股票代码（如 `sz000651`，港股 `hk01698`）。港股、美股等外币报价：再加一个汇率指标（解析器 `tencent_fx`，参数如 `whHKDCNY`），在公司表的“股价汇率指标”里选它，估值结论与驾驶舱的市场价会按当天汇率折成记账币种。
3. **经营与财务 / 财务报表**：季度完整三大报表（资产负债表、利润表、现金流量表），用 `framework/tools/fin_stmt.py` 从 akshare 取数并检验，不用手录。**经营与财务 / 定量指标**：这家公司的全部指标。财务模型历史一侧用到的数（收入、成本、利润、现金、负债、分红、业务量）在“模型字段”列标明；报表里有的科目按报表公式自动算，报表外的（业务量、每股股息等）或追溯调整的年份，点开指标在弹窗里录入。点开任何指标都能看趋势和逐期数据。
4. **估值模型**：新增一版模型（基准年、终值年、股本、无风险利率、风险溢价、期初带息负债）。
   想看资产侧，再填基准年末的经营性长期资产、长期股权投资、归母权益、少数股东权益。
5. **情景**：至少一个“基准情景”（勾选），可加悲观/乐观。
6. **预测输入**：通用模型从基准年下一年到终值年填写逐年假设；只用分部加总的路径参考腾讯音乐，单独填写财务预测及业务、资产估值输入。
7. 填**商业模式**九张表（见上一节）：先写清生意、产业链、对手和壁垒，再把决定价值的判断写成论点并正反辩论，最后在预测与估值 / 假设依据里写参数怎么设、定逐年假设。
8. 生成这家公司的菜单（驾驶舱、四组页面，财务模型在预测与估值组内）：在 framework 目录依次运行
   `python3 build_pages.py <代码>`、`python3 build_overview.py`、`python3 build_finmodel.py`，最后排序菜单（见 framework/README.md）。

## 不同生意，同一套表
- **长江电力**（类债资产）：派息率有承诺（≥70%），股息贴现最直接；关键变量是来水、电价、利率。商业模式分析：梯级电站资源与零燃料成本是真实壁垒，适配度 34/40。
- **太阳纸业**（周期制造业、正在扩张）：现在只分约 27%，大部分利润投进新产能。股息贴现价值主要取决于**扩张结束后派息率能否提高**（判断 J-PAYOUT），所以同时看“现金支持价值”和“隐含收益率”，并用毛利率、资本开支÷经营现金流、净负债÷EBITDA 做证伪检查。商业模式分析：真实壁垒只有自制浆与林浆纸一体化（周期底部仍赚钱，但不是定价权），适配度 22/40。
- **中国建筑**（总承包商＋地产，薄利、垫资）：收入＝新签合同总额×收入转化率；利润率只有 6%—7%，减值放在“其他净贡献”里单独看。关键不在订单，而在**利润能不能变成现金**（营运资本占用，判断 J-WC）和**减值会不会收敛**（J-IMP）。驾驶舱另有收入转化率、应收＋合同资产、减值三张图。商业模式分析：没有真实壁垒——央企信用、规模与大项目能力、中海地产带来的是份额，不是高于同业的利润率；新签规模、政府客户关系、PPP 是伪壁垒；适配度 15/40，只能按股息与资产价值看。
- **腾讯音乐**（港股、人民币记账，净现金的平台型公司）：股价是港元，按港元兑人民币折算后比较。估值只用**分部加总，分三块**（2026-10-28 起不做逐年预测与股息贴现）：①主营三块各自的 2027 年盈利×倍数：会员订阅（208 亿元×42%）、非订阅音乐（117 亿元×15%）按 13.1 倍，社交娱乐（48 亿元×16%）按萎缩年金约 6 倍，合计约 1,093 亿元（利润率＝核心经营利润率，加回七成收购摊销）（判断 J-S1、J-S2、J-S3、J-R）；②可分配的自由现金＝现金−带息负债−经营所需（40 亿元，J-OPCASH）−汇出预提税，约 212 亿元（J-CASH）；③对外投资按最新报告账面价值打七折，约 160 亿元（J-INV）；减少数股东约 28 亿元。基准每股约 45.6 元、约 53.7 港元（悲观 36.5、乐观 78.5 港元）；市场给主营约 6 倍。三块的利润率是分摊估算，加总须等于公司整体利润率。最敏感的是自由现金和利润有多少真正回到股东手里（论点 T5）。驾驶舱另有收入结构、会员与社交娱乐同比、毛利率、付费用户、现金与负债、股东回报率、汇率七张图。商业模式分析：上游议价权是真实壁垒，曲库、转换成本、腾讯生态是局部优势，适配度 31/40。
- **小米集团**（港股、五块业务处在不同阶段）：手机、AIoT、互联网三块按收入分摊费用后分开估值（正常化盈利×倍数，基准合计约 15.6 倍）；智能汽车是成长业务，按 2030 年稳态盈利折回今天；AI、芯片与机器人没有可预测的盈利，按用户的主观判断直接估 1,000 亿元（经营分部估值里的“直接估值”）。加上可用净现金与对外投资，基准每股约 28.6 元（约 33.6 港元），概率加权约 30.2 元，比现价高约三成；但高出的部分大半来自 AI 的 1,000 亿元，AI 按 0 计约 24.7 元。股东回报折现（“股息”＝回购）只有约 11.4 元，说明大部分价值留在公司里。驾驶舱另有分部收入、分部损益、生态利润率、毛利率、手机出货与 ASP、汽车交付、月活、现金与借款、汇率等图。商业模式分析：适配度 19/40，更像需要安全边际的特殊机会，而不是复利标的。

> 研究提示，不是交易指令。所有新阈值都是研究预警，不是自动买卖规则。"""

FORMULAS = """# 模型公式

## 预测计算（情景 × 年度）
- 营业收入 ＝ 业务量 × 业务量系数 × 单价 × 单价系数
- 利润总额 ＝ 营业收入 − 付现成本 × 付现成本系数 − 折旧摊销 − 利息 ＋ 其他净贡献
- 归母净利润 ＝ 利润总额 × (1 − 所得税率) × (1 − 少数股东占比)
- 计划股息 ＝ max(0, 归母净利润 × 派息率)
- 利息 ＝ (期初带息负债 ＋ 期末带息负债) ÷ 2 × 平均债务成本；期末 ＝ 期初 ＋ 净借款；第一年期初 ＝ 估值模型的期初带息负债

## 股东现金桥接
- 所有者收益 ＝ 归母净利润 ＋ 折旧 × (1 − 少数股东占比) − 非现金收益扣除 ＋ 收到投资分红 ＋ 其他现金调整 − 营运资本增加 − 维持资本开支
- FCFE ＝ 所有者收益 − 扩张资本开支 ＋ 净借款
- 现金支持股息 ＝ min(计划股息, max(0, FCFE − 最低现金补充))；资金缺口 ＝ max(0, 计划股息 ＋ 最低现金补充 − FCFE)

## 资产与资本（另算，不改变利润和估值）
- 经营性长期资产 ＝ 期初 ＋ 维持资本开支 ＋ 扩张资本开支 − 折旧摊销（期初＝固定资产＋在建工程＋无形资产＋使用权资产）
- 长期股权投资 ＝ 期初 ＋ 非现金收益扣除（权益法收益）− 收到投资分红
- 带息负债 ＝ 期初 ＋ 净借款（与利息用的是同一条债务滚动）
- 归母权益 ＝ 期初 ＋ 归母净利润 − 计划股息；少数股东权益 ＝ 期初 ＋ 少数股东损益 × (1 − 派息率)
- 其他净资产（平衡项）＝ 归母权益 ＋ 少数股东权益 ＋ 带息负债 − 经营性长期资产 − 长期股权投资，即现金＋营运资本−应付等无息负债；逐年下降＝分红、投资、还债在消耗现金
- 其他净资产的年变化 ＝ FCFE − 计划股息 ＋ 少数股东留存 ＋ 少数股东那部分折旧 − 其他现金调整 ＋ 营运资本增加（与现金桥接逐年一致）
- ROE ＝ 归母净利润 ÷ 平均归母权益；带息负债率 ＝ 带息负债 ÷ (带息负债 ＋ 全部权益)；利息保障倍数 ＝ (利润总额 ＋ 利息) ÷ 利息；带息负债 ÷ EBITDA，EBITDA ＝ 利润总额 ＋ 利息 ＋ 折旧

## 估值结论
- 基准折现率 ＝ 无风险利率 ＋ 风险溢价（四舍五入到 0.1%）；情景可覆盖
- 折现因子 ＝ 1 ÷ (1 + r)^(年度 − 基准年)
- 终值现值 ＝ 终年股息 × (1 + g) ÷ (r − g) ÷ (1 + r)^(终值年 − 基准年)，要求 r > g
- 每股价值·基准日 ＝ (预测期股息现值 ＋ 终值现值) ÷ 股本
- 每股价值·今天 ＝ 基准日价值 × (1 + r)^(距基准日年数)
- 关注价 ＝ 今天价值 × (1 − 安全边际)；现金支持价值同理，用现金支持股息计算

## 内部收益率（要求收益率视角）
- 现金流从今天起算：距今年数 τ ＝ (年度 − 基准年) − 距基准日年数；已过去的年份不计入
- 现值 PV(r) ＝ Σ 每股股息ₜ ÷ (1 + r)^τₜ ＋ 终年每股股息 × (1 + g) ÷ (r − g) ÷ (1 + r)^τ_T
- 隐含年化收益率 ＝ 使 PV(r) ＝ 市场价 的 r（二分法求解）；现金支持口径用现金支持股息
- 最高买入价 ＝ PV(要求收益率)；用情景折现率算 PV 即得“今天每股价值”

## 分部加总
- 核心经营利润（税前）＝ 利润总额 − 其他净贡献 ＋ 利息（取“核心盈利年份”那一年的预测计算）
- 核心盈利 ＝ 核心经营利润 × 归母净利润 ÷ 利润总额 ＋ 核心盈利调整（税后归母口径）
- 公式倍数 ＝ (1 − g ÷ 新增投资回报率) ÷ (r − g)；合理倍数 ＝ 情景手填倍数，否则公式倍数
- 资产计入值：单独计价＝±金额×(1−折价)，现金、投资、独立固定资产、其他非经营资产为加；负债等为减，其他调整按填写正负号。已含业务估值或不计价＝0；单独计价缺金额时不输出总值。公共行与情景专属行按编号覆盖。
- 可用净现金 ＝ 现金 − 带息负债 − 经营所需现金 − 资金汇出成本
- 每股价值 ＝ (业务估值合计 ＋ 资产估值与调整净额) ÷ 股本；境外上市时再按最新汇率折回股价币种
- 市场隐含核心倍数 ＝ (市场价 × 股本 − 非经营部分合计 − 经营分部价值) ÷ 核心盈利
- C16：基准情景分部加总与股息贴现相差超过 25% 时提示

## 经营分部估值（价值都折回资产负债日 D）
- 盈利 ＝ 收入 × 经营利润率 × (1 − 税率) × 归母比例；倍数 ＝ 手填，否则 (1 − g ÷ 新增投资回报率) ÷ (r − g)，g、新增投资回报率、r 留空时取情景的值
- 盈利×倍数、稳态折现：价值 ＝ 盈利 × 倍数 ÷ (1 + r)^τ ＋ 期间现金流 ÷ (1 + r)^(τ/2)；τ ＝ 盈利年份上一年 12 月 31 日距 D 的年数（不足 0 记 0；例如 D＝2026-06-30、盈利年份 2027 年时 τ＝0.5）
- 承诺投入：价值 ＝ −(剩余金额 ÷ n) × (1 − 税率) × [1 − (1 + r)^−n] ÷ r − 承诺期后年成本 × (1 − 税率) ÷ (r − g) ÷ (1 + r)^n，n ＝ 剩余年数
- 直接估值：价值 ＝ 填写的直接估值（已含该业务未来的投入与回报，不折现）
- 成熟业务倍数 ＝ (成熟业务价值 − 期间现金流现值) ÷ 盈利现值；市场隐含成熟业务倍数 ＝ (市值 − 非经营部分 − 成长业务 − 投入期业务 − 成熟业务期间现金流现值) ÷ 成熟业务盈利现值
- 市场隐含成长业务价值 ＝ 市值 − 非经营部分 − 核心与成熟业务 − 投入期业务 − 直接估值业务
- 概率加权每股价值 ＝ Σ 情景概率 × 每股价值 ÷ Σ 情景概率（各情景都填了概率才计算）
- C17：有经营分部时，基准情景算不出价值为“阻断”；情景概率合计不是 100% 或成长业务超过股权价值 40% 为“提示”

## 敏感性与单参数试验
- 敏感性：基准情景股息路径不变，折现率与永续增长各 −1%…+1%（步长 0.5%）
- 单参数试验：在基准情景上，对试验年份的利润增量 ×(1−税率)×(1−少数股东占比)×派息率 加到股息上，其余不变

## 年度派生指标（财务模型历史一侧、自动检查用）
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

KPI = r"""const COMPANY = '__COMPANY__';   // 由 build_overview.py 写入：这个驾驶舱只看这家公司
const IRR_ONLY = __IRR_ONLY__;   // 估值只用“隐含回报 vs 门槛”的公司（build_valuation.PROFILES）：不显示折现率价值与关注价
const { React } = ctx.libs;
const { useState } = React;
const { Card, Col, Row, Statistic, Typography, Alert, Slider, InputNumber, Button, Table, Tag, Space, message } = ctx.libs.antd;

async function listRows(collectionName, filter, pageSize = 200) {
  const resource = ctx.makeResource('MultiRecordResource');
  resource.setResourceName(collectionName);
  resource.setPageSize?.(pageSize);
  if (filter) resource.setFilter?.(filter);
  await resource.refresh();
  return resource.getData() || [];
}

const fmt = (v, d = 2) => (v === null || v === undefined || Number.isNaN(v) ? '—' : Number(v).toFixed(d));
const pct = (v, d = 2) => (v === null || v === undefined || Number.isNaN(v) ? '—' : (Number(v) * 100).toFixed(d) + '%');

// 这家公司要采的数据源＝它用到的指标（自有、股价、汇率折算、无风险利率、重点跟踪、订阅的宏观数据）。
// 用途由数据库视图 vi_company_metric 汇总，指标的 used_by_codes 来自它；SQL vi_collect_targets 用的是同一个视图。
function ownCollectors(collectors, metrics, companies, coId) {
  const code = companies.find((c) => c.id === coId)?.code;
  const keep = new Set(metrics.filter((m) => m.company_id === coId
    || (code && (m.used_by_codes || '').includes(`,${code},`))).map((m) => m.id));
  return collectors.filter((c) => keep.has(c.metric_id));
}

// 从今天起算的每股股息现值：Σ d/(1+r)^τ ＋ 终年股息×(1+g)/(r−g)/(1+r)^τ_T
function presentValue(flows, terminal, g, r) {
  if (!(r > g) || !terminal) return null;
  let pv = 0;
  for (const f of flows) {
    if (f.tau > 0 && f.dps !== null && f.dps !== undefined) pv += f.dps / Math.pow(1 + r, f.tau);
  }
  return pv + terminal.dps * (1 + g) / (r - g) / Math.pow(1 + r, terminal.tau);
}

try {
  const companies = await listRows('vi_company', { code: { $eq: COMPANY } });
  const company = companies[0];
  if (!company) {
    ctx.render(<Alert type="info" showIcon message={`公司表里没有代码为 ${COMPANY} 的公司`} />);
    return;
  }
  const models = await listRows('vi_model', { company_id: { $eq: company.id }, status: { $eq: '当前' } });
  const model = models[0];
  if (!model) {
    ctx.render(<Alert type="info" showIcon message="这家公司还没有状态为“当前”的估值模型" />);
    return;
  }
  const [valuations, projections, checks, allCollectors, sotpRows, metrics, allCompanies] = await Promise.all([
    listRows('vi_valuation', { model_id: { $eq: model.id } }),
    listRows('vi_projection', { model_id: { $eq: model.id } }, 500),
    listRows('vi_check', { model_id: { $eq: model.id } }),
    listRows('vi_collector').catch((error) => {
      if (error?.response?.status === 403 || error?.status === 403 || /No permissions/i.test(error?.message || '')) return [];
      throw error;
    }),
    listRows('vi_sotp', { model_id: { $eq: model.id } }),
    listRows('vi_metric', null, 500),
    listRows('vi_company'),
  ]);
  const collectors = ownCollectors(allCollectors, metrics, allCompanies, company.id);
  // 分部加总：核心业务盈利 × 合理倍数 ＋ 非经营部分（可用净现金、对外投资、少数股东等）
  const sotp = sotpRows.slice().sort((a, b) => (a.id || 0) - (b.id || 0));
  const sotpPrimary = model.primary_method === '分部加总' && sotp.length > 0;
  const sotpBase = sotp.find((r) => r.is_base) || sotp[0];
  const hasDdm = projections.some((p) => p.year > model.base_year);   // 只用分部加总、没有逐年预测时不显示股息贴现（腾讯音乐，2026-10-28 起）
  const scenarios = valuations.slice().sort((a, b) => (a.id || 0) - (b.id || 0)).map((v) => {
    const rows = projections.filter((p) => p.scenario_name === v.scenario_name && p.year > model.base_year && p.year <= model.terminal_year);
    const flows = rows.map((p) => ({ dps: p.dps, tau: (p.year - model.base_year) - model.years_elapsed }));
    const last = rows.find((p) => p.year === model.terminal_year);
    const terminal = last ? { dps: last.dps, tau: (model.terminal_year - model.base_year) - model.years_elapsed } : null;
    return { ...v, flows, terminal };
  });
  const base = scenarios.find((v) => v.is_base) || scenarios[0] || {};
  const count = (r) => checks.filter((c) => c.result === r).length;
  const enabled = collectors.filter((c) => c.enabled);
  const healthy = enabled.filter((c) => c.health === '正常').length;
  const initial = Math.round((model.required_return ?? 0.06) * 1000) / 10;

  function Panel() {
    const [reqPct, setReqPct] = useState(initial);
    const [trialMult, setTrialMult] = useState(null);   // 试算倍数：留空＝用各情景的合理倍数
    const [saving, setSaving] = useState(false);
    const req = reqPct / 100;
    const rows = scenarios.map((v) => {
      const ceiling = presentValue(v.flows, v.terminal, v.terminal_growth, req);
      return {
        key: v.id, name: v.scenario_name, irr: v.implied_irr, cashIrr: v.cash_implied_irr, ceiling,
        price: v.market_price, ok: v.implied_irr !== null && v.implied_irr !== undefined && v.implied_irr >= req,
      };
    });
    const baseRow = rows.find((r) => r.name === base.scenario_name) || rows[0] || {};
    const save = async () => {
      setSaving(true);
      try {
        await ctx.request({ url: 'vi_model:update', method: 'post', params: { filterByTk: model.id }, data: { required_return: req } });
        message.success(`已保存：要求收益率 ${reqPct}%（刷新后结论与图表同步更新）`);
      } catch (e) {
        message.error('保存失败：' + String(e?.message || e));
      } finally {
        setSaving(false);
      }
    };
    const fx = company.latest_fx;
    const toHkd = (value) => fx > 0 && value !== null && value !== undefined ? Number(value) / fx : null;
    // 有“核心盈利”（来自预测计算）就试算核心倍数；只有经营分部时试算成熟业务（盈利×倍数）的倍数
    const hasCore = sotpBase && sotpBase.core_earnings !== null && sotpBase.core_earnings !== undefined;
    const hasSeg = sotpBase && sotpBase.segments_value !== null && sotpBase.segments_value !== undefined;
    const baseMult = (r) => (hasCore ? r.multiple : r.mature_multiple);
    const sotpCalc = sotp.map((r) => {
      const m = trialMult ?? baseMult(r);
      const anchor = hasCore ? r.core_value : (r.mature_value ?? 0);
      const anchorTrial = hasCore ? r.core_earnings * m : (r.mature_earn_pv ?? 0) * m + (r.mature_interim_pv ?? 0);
      const equity = r.equity_value === null || r.equity_value === undefined ? null : r.equity_value - anchor + anchorTrial;
      const vps = equity === null ? null : equity / r.shares;
      return { key: r.id, name: r.scenario_name, prob: r.probability, core: r.core_earnings, m, coreValue: hasCore ? r.core_earnings * m : null,
               mature: hasSeg ? anchorTrial : null, growth: r.growth_value, invest: r.invest_value, direct: r.direct_value, cash: r.usable_net_cash,
               inv: r.investments, other: r.minority_other, fixed: r.fixed_assets, otherAssets: r.other_assets,
               business: r.business_value === null || r.business_value === undefined ? null : r.business_value - anchor + anchorTrial,
               assets: r.asset_value, equity, shares: r.shares, vps, quote: fx && vps !== null ? vps / fx : null,
               vsPrice: r.market_price && vps ? r.market_price / vps - 1 : null };
    });
    const sotpBaseCalc = sotpCalc.find((r) => sotpBase && r.key === sotpBase.id) || sotpCalc[0] || {};
    const hasDirect = sotp.some((r) => r.direct_value !== null && r.direct_value !== undefined);
    const hasInvest = sotp.some((r) => r.invest_value !== null && r.invest_value !== undefined);
    const probs = sotpCalc.filter((r) => r.prob !== null && r.prob !== undefined && r.vps !== null);
    const weighted = probs.length === sotpCalc.length && probs.length > 0
      ? probs.reduce((a, r) => a + r.prob * r.vps, 0) / probs.reduce((a, r) => a + r.prob, 0) : null;
    const quoteReference = sotpPrimary ? (weighted !== null ? weighted : sotpCalc.find((r) => r.name === '悲观')?.vps) : baseRow.ceiling;
    const quoteReferenceTitle = sotpPrimary ? (weighted !== null ? '概率加权价值' : '悲观分部估值') : `回报门槛 ${reqPct}% 的最高买入价`;
    const sotpTitle = !sotpPrimary ? '分部加总（交叉验证）'
      : '主估值：业务估值合计＋资产估值与调整净额';
    const sotpCard = sotp.length === 0 ? null : (
      <Card size="small" style={{ marginBottom: 12 }} title={sotpTitle}>
        <Row gutter={[12, 12]}>
          <Col xs={12} md={6}><Statistic title={`基准每股价值（${trialMult ? '试算倍数' : (hasCore ? '合理倍数' : '成熟业务倍数')} ${fmt(sotpBaseCalc.m, 1)} 倍）`} value={fmt(sotpBaseCalc.vps)} suffix={fx ? `元 ≈ ${fmt(sotpBaseCalc.quote)} 港元` : '元'} /></Col>
          <Col xs={12} md={6}><Statistic title={`市场价（${base.market_date || '—'}）`} value={fmt(sotpBase.market_price)} suffix="元" /></Col>
          <Col xs={12} md={6}><Statistic title="市场价相对基准价值" value={sotpBaseCalc.vsPrice === null ? '—' : pct(sotpBaseCalc.vsPrice, 1)} valueStyle={{ color: sotpBaseCalc.vsPrice < 0 ? '#389e0d' : '#cf1322' }} /></Col>
          {weighted !== null
            ? <Col xs={12} md={6}><Statistic title="概率加权每股价值" value={fmt(weighted)} suffix={fx ? `元 ≈ ${fmt(weighted / fx)}` : '元'} /></Col>
            : <Col xs={12} md={6}><Statistic title="市场给核心业务的隐含倍数（基准）" value={fmt(sotpBase.implied_core_multiple, 1)} suffix="倍" /></Col>}
        </Row>
        {hasSeg ? (
          <Row gutter={[12, 12]} style={{ marginTop: 8 }}>
            <Col xs={12} md={6}><Statistic title="市场隐含成熟业务倍数（本模型）" value={`${fmt(sotpBase.implied_mature_multiple, 1)}（${fmt(sotpBase.mature_multiple, 1)}）`} suffix="倍" /></Col>
            <Col xs={12} md={6}><Statistic title="市场隐含成长业务价值（本模型）" value={`${fmt(sotpBase.implied_growth_value, 0)}（${fmt(sotpBase.growth_value, 0)}）`} suffix="亿元" /></Col>
            {hasDirect
              ? <Col xs={12} md={6}><Statistic title="直接估值业务（可比公司或主观判断）" value={fmt(sotpBase.direct_value, 0)} suffix="亿元" /></Col>
              : <Col xs={12} md={6}><Statistic title="投入期业务（承诺投入的成本）" value={fmt(sotpBase.invest_value, 0)} suffix="亿元" /></Col>}
            <Col xs={12} md={6}><Statistic title="关注价（安全边际）" value={sotpBase.watch_high == null ? fmt(sotpBase.watch_low) : `${fmt(sotpBase.watch_low)} / ${fmt(sotpBase.watch_high)}`} suffix="元" /></Col>
          </Row>
        ) : null}
        <Space wrap align="center" style={{ margin: '8px 0' }}>
          <Typography.Text strong>{hasCore ? '试算倍数' : '试算成熟业务倍数'}</Typography.Text>
          <Slider style={{ width: 240 }} min={3} max={30} step={0.5} value={trialMult ?? baseMult(sotpBase)} onChange={(v) => setTrialMult(v)} />
          <InputNumber min={1} max={60} step={0.5} value={trialMult ?? Number(fmt(baseMult(sotpBase), 1))} onChange={(v) => setTrialMult(v)} addonAfter="倍" />
          <Button onClick={() => setTrialMult(null)}>恢复各情景倍数</Button>
        </Space>
        {(() => {
          // 价值桥：每行一个组成部分，每列一个情景；① 业务估值 ＋ ② 资产估值与调整净额 ＝ ③ 股权价值 → 每股价值
          const coreOnly = hasCore && !hasSeg;
          const anyNonZero = (k) => sotpCalc.some((r) => r[k] !== null && r[k] !== undefined && Number(r[k]) !== 0);
          const signed = (v, d = 0) => (v === null || v === undefined ? '—' : (Number(v) > 0 ? '＋' : Number(v) < 0 ? '−' : '') + fmt(Math.abs(Number(v)), d));
          const lines = [
            { key: 'h1', kind: 'head', label: '① 业务估值' },
            ...(hasCore ? [
              { key: 'core', label: `核心盈利（${sotpBase.core_year} 年）`, v: (r) => fmt(r.core, 1) },
              { key: 'm', label: '× 倍数', v: (r) => `${fmt(r.m, 1)} 倍` },
            ] : []),
            ...(hasCore && !coreOnly ? [{ key: 'coreValue', label: '核心业务价值', v: (r) => fmt(r.coreValue, 0) }] : []),
            ...(hasSeg ? [
              { key: 'mature', label: '成熟业务（盈利×倍数）', v: (r) => fmt(r.mature, 0) },
              { key: 'growth', label: '成长业务', v: (r) => fmt(r.growth, 0) },
            ] : []),
            ...(hasSeg && hasInvest ? [{ key: 'invest', label: '投入期业务（承诺投入的成本）', v: (r) => fmt(r.invest, 0) }] : []),
            ...(hasSeg && hasDirect ? [{ key: 'direct', label: '直接估值业务', v: (r) => fmt(r.direct, 0) }] : []),
            { key: 'business', kind: 'total', label: coreOnly ? '＝ 业务估值合计（核心盈利 × 倍数）' : '＝ 业务估值合计', v: (r) => fmt(r.business, 0) },
            { key: 'h2', kind: 'head', label: '② 资产估值与调整' },
            { key: 'cash', label: '可用净现金（现金 − 带息负债 − 经营所需现金 − 汇出成本）', v: (r) => signed(r.cash) },
            { key: 'inv', label: '对外投资（折价后）', v: (r) => signed(r.inv) },
            ...(anyNonZero('fixed') ? [{ key: 'fixed', label: '独立固定资产', v: (r) => signed(r.fixed) }] : []),
            ...(anyNonZero('otherAssets') ? [{ key: 'otherAssets', label: '其他非经营资产', v: (r) => signed(r.otherAssets) }] : []),
            { key: 'other', label: '少数股东权益与其他调整', v: (r) => signed(r.other) },
            { key: 'assets', kind: 'total', label: '＝ 资产估值与调整净额', v: (r) => signed(r.assets) },
            { key: 'h3', kind: 'head', label: '③ 每股价值' },
            { key: 'equity', kind: 'total', label: '股权价值 ＝ ① ＋ ②', v: (r) => fmt(r.equity, 0) },
            { key: 'shares', label: '÷ 股本（亿股）', v: (r) => fmt(r.shares, 2) },
            { key: 'vps', kind: 'final', label: '＝ 每股价值', v: (r) => (r.vps === null ? '—' : `${fmt(r.vps)} 元`) },
            ...(fx ? [{ key: 'quote', label: '折合港元', v: (r) => (r.quote === null ? '—' : `${fmt(r.quote)} 港元`) }] : []),
            { key: 'vsPrice', label: `市场价 ${fmt(sotpBase.market_price)} 元相对每股价值`, v: (r) => (r.vsPrice === null ? '—' : pct(r.vsPrice, 1)),
              color: (r) => (r.vsPrice === null ? undefined : r.vsPrice < 0 ? '#389e0d' : '#cf1322') },
            ...(weighted !== null ? [{ key: 'prob', label: '情景概率', v: (r) => pct(r.prob, 0) }] : []),
          ];
          const baseKey = sotpBase ? sotpBase.id : null;
          const rowStyle = (l) => (l.kind === 'head' ? { background: 'rgba(0,0,0,0.03)', fontWeight: 600 }
            : l.kind === 'total' ? { fontWeight: 600, borderTop: '1px solid rgba(0,0,0,0.15)' }
            : l.kind === 'final' ? { fontWeight: 700, fontSize: 15, borderTop: '2px solid rgba(0,0,0,0.45)' } : {});
          const cellPad = { padding: '6px 12px' };
          return (
            <div style={{ overflowX: 'auto' }}>
              <table style={{ width: '100%', borderCollapse: 'collapse', fontVariantNumeric: 'tabular-nums', fontSize: 13 }}>
                <thead>
                  <tr style={{ borderBottom: '1px solid rgba(0,0,0,0.15)' }}>
                    <th style={{ ...cellPad, textAlign: 'left', fontWeight: 600, width: '46%' }}>亿元（另注明的除外）</th>
                    {sotpCalc.map((r) => (
                      <th key={r.key} style={{ ...cellPad, textAlign: 'right', fontWeight: 600, background: r.key === baseKey ? 'rgba(22,119,255,0.06)' : undefined }}>
                        {r.name}{r.key === baseKey && r.name !== '基准' ? '（基准）' : ''}
                      </th>
                    ))}
                  </tr>
                </thead>
                <tbody>
                  {lines.map((l) => (
                    <tr key={l.key} style={rowStyle(l)}>
                      <td style={{ ...cellPad, paddingLeft: l.kind ? 12 : 28, color: l.kind ? undefined : 'rgba(0,0,0,0.65)' }}>{l.label}</td>
                      {sotpCalc.map((r) => (
                        <td key={r.key} style={{ ...cellPad, textAlign: 'right', background: r.key === baseKey ? 'rgba(22,119,255,0.06)' : undefined,
                                                 color: l.color ? l.color(r) : undefined }}>
                          {l.kind === 'head' ? '' : l.v(r)}
                        </td>
                      ))}
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          );
        })()}
        <Typography.Paragraph type="secondary" style={{ marginTop: 8, marginBottom: 0 }}>
          {hasSeg
            ? <>经营分部按发展阶段估值（明细见「估值 / 业务估值（编辑）」）：成熟业务＝正常化盈利×倍数，倍数＝(1−永续增长率÷新增投资回报率)÷(折现率−永续增长率)；成长业务＝稳态年盈利×退出倍数折回资产负债日，加上到稳态前的期间现金流；投入期业务＝已承诺投入的税后现值加承诺期后年成本（负值）；直接估值业务＝按可比公司或主观判断给出的整体价值。非经营部分统一截至 {sotpBase.as_of}，明细见「估值 / 资产估值与调整（编辑）」。
                市场隐含值＝其余部分按本模型取值时，市值对应的成熟业务倍数或成长业务价值。试算倍数只改成熟业务的倍数。{hasDdm ? `股东回报折现（交叉验证）基准 ${fmt(sotpBase.ddm_value)} 元。` : ''}</>
            : <>合理倍数＝(1−永续增长率÷新增投资回报率)÷(折现率−永续增长率)，可在“情景”里手填覆盖；非经营部分统一截至 {sotpBase.as_of}（与股本同日），明细见「估值 / 资产估值与调整（编辑）」。
                隐含倍数＝(市值−非经营部分)÷核心盈利：市场为核心业务付了几倍。{hasDdm ? `股息贴现口径（交叉验证）基准 ${fmt(sotpBase.ddm_value)} 元。` : ''}</>}
        </Typography.Paragraph>
      </Card>
    );
    return (
      <div>
        <Typography.Title level={4} style={{ marginTop: 0 }}>
          {company.name}（{company.code}）· {model.name}
        </Typography.Title>
        <Row gutter={[16, 8]} style={{ marginBottom: 12 }}>
          <Col xs={8} md={4}><Statistic title="PE (TTM)" value={fmt(company.pe_ttm)} /></Col>
          <Col xs={8} md={4}><Statistic title="PB" value={fmt(company.pb)} /></Col>
          <Col xs={8} md={6}><Statistic title="交易日（akshare 市场口径）" value={company.pe_pb_date || '—'} /></Col>
        </Row>
        {COMPANY.endsWith('.HK') && (
          <Card size="small" title={`港股速览 · ${COMPANY} · 港元 / 普通股`} style={{ marginBottom: 12 }}>
            <Row gutter={[16, 16]}>
              <Col xs={12} md={6}><Statistic title={`港股市场价 · ${company.latest_price_date || '—'}`} value={fmt(company.latest_price_raw)} suffix="港元" /></Col>
              <Col xs={12} md={6}><Statistic title={sotpPrimary ? '基准分部估值' : '基准每股价值'} value={fmt(toHkd(sotpPrimary ? sotpBaseCalc.vps : base.value_today))} suffix="港元" /></Col>
              <Col xs={12} md={6}><Statistic title={quoteReferenceTitle} value={fmt(toHkd(quoteReference))} suffix="港元" /></Col>
              <Col xs={12} md={6}><Statistic title="1 港元折人民币" value={fmt(fx, 4)} suffix="元" /></Col>
            </Row>
            {!(fx > 0) && <Alert type="warning" showIcon message="缺少有效汇率，港元估值暂不换算" />}
          </Card>
        )}
        {sotpPrimary ? sotpCard : null}
        {hasDdm ? (<Card size="small" title={sotpPrimary ? '交叉验证：股息贴现，按要求收益率估值' : IRR_ONLY ? '估值：按市价买入的隐含年化回报 vs 门槛' : '按要求收益率估值'} style={{ marginBottom: 12 }}>
          <Space wrap align="center" style={{ marginBottom: 8 }}>
            <Typography.Text strong>{IRR_ONLY ? '门槛' : '要求收益率'}</Typography.Text>
            <Slider style={{ width: 240 }} min={3} max={10} step={0.1} value={reqPct} onChange={(v) => setReqPct(v)} />
            <InputNumber min={0.1} max={20} step={0.1} value={reqPct} onChange={(v) => setReqPct(v ?? initial)} addonAfter="%" />
            <Button onClick={() => setReqPct(initial)}>恢复 {initial}%</Button>
            <Button type="primary" loading={saving} onClick={save}>保存为模型默认</Button>
          </Space>
          <Row gutter={[12, 12]}>
            <Col xs={12} md={6}><Statistic title={`市场价（${base.market_date || '—'}${company.latest_fx ? `；原币 ${fmt(company.latest_price_raw)} × 汇率 ${company.latest_fx}` : ''}）`} value={fmt(base.market_price)} suffix="元" /></Col>
            <Col xs={12} md={6}><Statistic title="买入后隐含年化收益率（基准）" value={pct(baseRow.irr)} valueStyle={{ color: baseRow.ok ? '#389e0d' : '#cf1322' }} /></Col>
            <Col xs={12} md={6}><Statistic title={`${IRR_ONLY ? '门槛' : '要求'} ${reqPct}% 的最高买入价（基准）`} value={fmt(baseRow.ceiling)} suffix="元" /></Col>
            <Col xs={12} md={6}><Statistic title="市场价相对最高买入价" value={baseRow.ceiling ? pct(base.market_price / baseRow.ceiling - 1, 1) : '—'} /></Col>
          </Row>
          <Table size="small" pagination={false} style={{ marginTop: 12 }} dataSource={rows} columns={[
            { title: '情景', dataIndex: 'name' },
            { title: '隐含年化收益率', dataIndex: 'irr', render: (v) => pct(v) },
            { title: '现金支持口径', dataIndex: 'cashIrr', render: (v) => pct(v) },
            { title: `${IRR_ONLY ? '门槛' : '要求'} ${reqPct}% 的最高买入价（元）`, dataIndex: 'ceiling', render: (v) => fmt(v) },
            { title: '市场价（元）', dataIndex: 'price', render: (v) => fmt(v) },
            { title: '结论', dataIndex: 'ok', render: (v) => (v ? <Tag color="green">{IRR_ONLY ? '达到门槛' : '达到要求'}</Tag> : <Tag color="red">{IRR_ONLY ? '低于门槛' : '未达到要求'}</Tag>) },
          ]} />
          {!IRR_ONLY && <Typography.Paragraph type="secondary" style={{ marginTop: 8, marginBottom: 0 }}>
            隐含年化收益率＝按今天市场价买入、获得模型预测的股息并按永续增长率增长时的内部收益率，与要求收益率无关；
            最高买入价＝按要求收益率把未来股息折现到今天的每股价值。两者等价：隐含收益率高于要求收益率 ⇔ 市场价低于最高买入价。
          </Typography.Paragraph>}
        </Card>) : null}
        {!sotpPrimary ? sotpCard : null}
        {IRR_ONLY || !hasDdm ? (
          <Typography.Paragraph type="secondary" style={{ marginTop: 8, marginBottom: 0 }}>
            质量自检：通过 {count('通过')} · 提示 {count('提示')} · 阻断 {count('阻断')}。自动采集（这家公司和通用指标）：{healthy} / {enabled.length} 个数据源正常。
            {hasDdm ? '回报拆解、买入价与假设的影响见「预测与估值 / 估值」。' : (sotpBase?.conclusion || '')}
          </Typography.Paragraph>
        ) : (<>
        <Row gutter={[12, 12]}>
          <Col xs={12} md={6}><Card size="small"><Statistic title={`${sotpPrimary ? '股息贴现·' : ''}今天每股价值（折现率 ${pct(base.discount_rate)}）`} value={fmt(base.value_today)} suffix="元" /></Card></Col>
          <Col xs={12} md={6}><Card size="small"><Statistic title="现金支持价值·今天" value={fmt(base.cash_value_today)} suffix="元" /></Card></Col>
          <Col xs={12} md={6}><Card size="small"><Statistic title={`${sotpPrimary ? '股息贴现·' : ''}关注价（安全边际）`} value={base.watch_high == null ? fmt(base.watch_low) : `${fmt(base.watch_low)} / ${fmt(base.watch_high)}`} /></Card></Col>
          <Col xs={12} md={6}><Card size="small"><Statistic title="质量自检" value={`通过 ${count('通过')} · 提示 ${count('提示')} · 阻断 ${count('阻断')}`} /></Card></Col>
        </Row>
        <Typography.Paragraph type="secondary" style={{ marginTop: 8, marginBottom: 0 }}>
          {base.conclusion || ''} 自动采集（这家公司和通用指标）：{healthy} / {enabled.length} 个数据源正常。
        </Typography.Paragraph>
        </>)}
      </div>
    );
  }

  ctx.render(<Panel />);
} catch (error) {
  ctx.render(<Alert type="error" showIcon message="驾驶舱读取失败" description={String(error?.message || error)} />);
}
"""

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
    DEF = (f"JOIN vi_company_base co ON co.id = m.company_id AND co.code = '{code}' "
           "JOIN vi_model_base m0 ON m0.id = m.id AND m0.status = '当前'")
    CO = "JOIN vi_company_base co ON co.id = {t}.company_id AND co.code = '" + code + "'"
    M = "FROM vi_valuation v JOIN vi_model_base m ON m.id = v.model_id " + DEF
    BASECF = ("FROM vi_valuation_cf f JOIN vi_scenario_base s ON s.id = f.scenario_id AND s.is_base "
              "JOIN vi_model_base m ON m.id = f.model_id JOIN vi_company_calc cc ON cc.id = m.company_id " + DEF)
    PRICES = " CROSS JOIN generate_series(greatest(1, floor(cc.latest_price * 0.5))::int, ceil(cc.latest_price * 1.6)::int) x(price)"
    out = [
        ('irr_scen', '三情景：买入后隐含年化收益率 vs 要求收益率（%）', c(
            f"SELECT v.scenario_name, x.\"口径\", x.\"收益率（%）\" FROM vi_valuation v JOIN vi_model_base m ON m.id = v.model_id {DEF} "
            "CROSS JOIN LATERAL (VALUES ('隐含收益率', round((v.implied_irr * 100)::numeric, 2)), "
            "('现金支持口径', round((v.cash_implied_irr * 100)::numeric, 2)), ('要求收益率', round((v.required_return * 100)::numeric, 2))) x(\"口径\", \"收益率（%）\") "
            "ORDER BY v.sort, 2", 'bar', {'x': 'scenario_name', 'y': '收益率（%）', 'series': '口径'})),
        ('irr_curve', '买入价 → 隐含年化收益率（基准情景，%）', c(
            "SELECT x.price AS \"买入价\", '隐含收益率' AS \"系列\", round((vi_irr(f.divs, f.taus, f.td, f.ttau, f.cf_g, x.price) * 100)::numeric, 2) AS \"收益率\" "
            + BASECF + PRICES +
            " UNION ALL SELECT x.price, '要求收益率', round((f.required_return * 100)::numeric, 2) " + BASECF + PRICES +
            " ORDER BY 1, 2", 'line', {'x': '买入价', 'y': '收益率', 'series': '系列'})),
        ('req_curve', '要求收益率 → 最高买入价（元）', c(
            "SELECT round((x.r * 100)::numeric, 1)::text || '%' AS \"要求收益率\", s.name AS \"情景\", "
            "round(vi_pv(f.divs, f.taus, f.td, f.ttau, f.cf_g, x.r)::numeric, 2) AS \"最高买入价\", x.r, s.sort "
            "FROM vi_valuation_cf f JOIN vi_scenario_base s ON s.id = f.scenario_id JOIN vi_model_base m ON m.id = f.model_id " + DEF +
            " CROSS JOIN (SELECT generate_series(40, 100, 5) / 1000.0 AS r) x "
            "UNION ALL SELECT round((x.r * 100)::numeric, 1)::text || '%', '市场价', round(cc.latest_price::numeric, 2), x.r, 99 "
            "FROM vi_model_base m JOIN vi_company_calc cc ON cc.id = m.company_id " + DEF +
            " CROSS JOIN (SELECT generate_series(40, 100, 5) / 1000.0 AS r) x ORDER BY 4, 5", 'line',
            {'x': '要求收益率', 'y': '最高买入价', 'series': '情景'})),
        ('value', '三情景·今天每股价值（元）', c(f"SELECT v.scenario_name, round(v.value_today::numeric, 2) AS \"今天每股价值\" {M} ORDER BY v.sort",
                                              'bar', {'x': 'scenario_name', 'y': '今天每股价值'})),
        ('watch', '今天价值、关注价与市场价（元）', c(
            f"SELECT v.scenario_name, '今天价值' AS item, round(v.value_today::numeric, 2) AS price, v.sort {M} "
            f"UNION ALL SELECT v.scenario_name, '关注价', round(v.watch_low::numeric, 2), v.sort {M} "
            f"UNION ALL SELECT v.scenario_name, '高档关注价', round(v.watch_high::numeric, 2), v.sort {M} "
            f"UNION ALL SELECT v.scenario_name, '市场价', round(v.market_price::numeric, 2), v.sort {M} ORDER BY sort, item",
            'bar', {'x': 'scenario_name', 'y': 'price', 'series': 'item'})),
        ('tv', '终值占比（越高越依赖远期）', c(f"SELECT v.scenario_name, round(v.terminal_share::numeric, 4) AS \"终值占比\" {M} ORDER BY v.sort",
                                          'bar', {'x': 'scenario_name', 'y': '终值占比'})),
        ('path', '基准情景：利润、股息与 FCFE（亿元）', c(
            "SELECT p.year, x.item, round(x.amount::numeric, 1) AS amount FROM vi_projection p "
            "JOIN vi_model_base m ON m.id = p.model_id " + DEF + " "
            "CROSS JOIN LATERAL (VALUES ('归母净利润', p.np_parent), ('计划股息', p.dividend), ('FCFE', p.fcfe)) x(item, amount) "
            "WHERE p.is_base ORDER BY p.year, x.item", 'line', {'x': 'year', 'y': 'amount', 'series': 'item'})),
        ('sens', '敏感性：今天每股价值（元）', c(
            "SELECT round((s.r * 100)::numeric, 2)::text || '%' AS r, 'g=' || round((s.g * 100)::numeric, 2)::text || '%' AS g, "
            "round(s.value_today::numeric, 2) AS value FROM vi_sensitivity s JOIN vi_model_base m ON m.id = s.model_id " + DEF +
            " ORDER BY s.r, s.g", 'line', {'x': 'r', 'y': 'value', 'series': 'g'})),
        ('debt', '带息负债：历史与预测（亿元）', c(
            "SELECT h.year::text AS year, '历史' AS kind, round(h.interest_debt::numeric, 0) AS debt FROM vi_fin_history h "
            + CO.format(t='h') + " WHERE h.interest_debt IS NOT NULL "
            "UNION ALL SELECT f.year::text, '预测', round(fc.debt_close::numeric, 0) FROM vi_forecast_base f JOIN vi_forecast_calc fc USING (id) "
            "JOIN vi_model_base m ON m.id = f.model_id " + DEF + " ORDER BY year", 'bar', {'x': 'year', 'y': 'debt', 'series': 'kind'})),
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
        ('sotp_parts', '分部加总：每股价值构成（元）', c(
            "SELECT s.scenario_name AS \"情景\", x.k AS \"部分\", round((x.v / s.shares)::numeric, 2) AS \"元/股\", s.id, x.o FROM vi_sotp s "
            + CO.format(t='s') + " CROSS JOIN LATERAL (VALUES ('核心业务', s.core_value, 1), ('成熟业务', s.mature_value, 2), ('成长业务', s.growth_value, 3), "
            "('投入期业务', s.invest_value, 4), ('直接估值业务', s.direct_value, 4), ('可用净现金', s.usable_net_cash, 5), ('对外投资（折后）', s.investments, 6), "
            "('独立固定资产', s.fixed_assets, 7), ('其他非经营资产', s.other_assets, 8), ('少数股东与其他', s.minority_other, 9), ('合计', s.equity_value, 10)) x(k, v, o) "
            "WHERE x.v IS NOT NULL ORDER BY s.id, x.o", 'bar', {'x': '情景', 'y': '元/股', 'series': '部分'})),
        ('sotp_bridge', '分部加总：基准情景价值构成（元/股，逐项）', c(
            "SELECT g.name AS \"部分\", round((g.value / s.shares)::numeric, 2) AS \"元/股\", 10 + coalesce(nullif(regexp_replace(g.code, '\\D', '', 'g'), '')::int, 0) AS o "
            "FROM vi_sotp s " + CO.format(t='s') + " JOIN vi_sotp_segment_val g ON g.scenario_id = s.id WHERE s.is_base "
            "UNION ALL SELECT '核心业务', round((s.core_value / s.shares)::numeric, 2), 1 FROM vi_sotp s " + CO.format(t='s') +
            " WHERE s.is_base AND s.core_value IS NOT NULL "
            "UNION ALL SELECT x.k, round((x.v / s.shares)::numeric, 2), x.o FROM vi_sotp s " + CO.format(t='s') +
            " CROSS JOIN LATERAL (VALUES ('可用净现金', s.usable_net_cash, 30), ('对外投资（折后）', s.investments, 31), ('独立固定资产', s.fixed_assets, 32), ('其他非经营资产', s.other_assets, 33), ('少数股东与其他', s.minority_other, 34), "
            "('每股价值', s.equity_value, 40), ('市场价', s.market_price * s.shares, 41)) x(k, v, o) WHERE s.is_base AND x.v IS NOT NULL ORDER BY 3",
            'bar', {'x': '部分', 'y': '元/股'})),
        ('sotp_grid', '分部加总：倍数 → 每股价值（元；核心业务或成熟业务的倍数）', c(
            "SELECT x.m AS \"倍数\", s.scenario_name AS \"系列\", round(((coalesce(s.core_earnings, 0) * x.m + coalesce(s.mature_earn_pv, 0) * x.m "
            "+ coalesce(s.mature_interim_pv, 0) + coalesce(s.growth_value, 0) + coalesce(s.invest_value, 0) + coalesce(s.direct_value, 0) + s.noncore) / s.shares)::numeric, 2) AS \"每股价值\", s.id FROM vi_sotp s "
            + CO.format(t='s') + " CROSS JOIN generate_series(4, 24, 2) x(m) "
            "UNION ALL SELECT x.m, '市场价', round(s.market_price::numeric, 2), 999 FROM vi_sotp s " + CO.format(t='s') +
            " CROSS JOIN generate_series(4, 24, 2) x(m) WHERE s.is_base ORDER BY 1, 4", 'line', {'x': '倍数', 'y': '每股价值', 'series': '系列'})),
        ('sotp_mult', '合理倍数 vs 市场隐含倍数（核心业务或成熟业务）', c(
            "SELECT s.scenario_name AS \"情景\", x.k AS \"口径\", round(x.v::numeric, 1) AS \"倍\", s.id FROM vi_sotp s " + CO.format(t='s') +
            " CROSS JOIN LATERAL (VALUES ('合理倍数', coalesce(s.multiple, s.mature_multiple)), ('市场隐含倍数', coalesce(s.implied_core_multiple, s.implied_mature_multiple))) x(k, v) "
            "ORDER BY s.id, 2", 'bar', {'x': '情景', 'y': '倍', 'series': '口径'})),
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
            "SELECT k.result, count(*) AS n FROM vi_check k JOIN vi_model_base m ON m.id = k.model_id " + DEF +
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
    needs = {'sotp_parts': 'sotp', 'sotp_bridge': 'sotp', 'sotp_grid': 'sotp', 'sotp_mult': 'sotp', 'fit': 'fit', 'moat': 'moat',
             'forces': 'chain', 'peers': 'comp', 'theses': 'thesis'}
    needs.update({k: 'fc' for k in ('irr_scen', 'irr_curve', 'req_curve', 'value', 'watch', 'tv', 'path', 'sens', 'debt')})   # 没有逐年预测（只用分部加总）就不画股息贴现类图
    out = [x for x in out if have.get(needs.get(x[0]), 1) > 0]      # 没有内容的通用图不放（如还没做分部加总或还没填商业模式分析的公司）
    if irr_only(code):                                               # 只看隐含回报的公司：不画折现率价值、关注价、终值占比、折现率敏感性
        out = [x for x in out if x[0] not in ('value', 'watch', 'tv', 'sens')]
    result = out + EXTRA.get(code, [])
    if code == '01698.HK':
        from tencent_dashboard import charts as tencent_charts
        return tencent_charts(result)
    from company_dashboard import PROFILES, charts as company_charts
    if code in PROFILES:
        return company_charts(code, result)
    return result


def irr_only(code):
    import build_valuation                       # 函数内导入：build_valuation 依赖本模块
    return build_valuation.PROFILES.get(code, {}).get('method') == 'irr'


def content(code):
    """这家公司有哪些可画的内容：分部加总、适配度、壁垒、产业链、竞争对手、论点。"""
    co = f"(SELECT id FROM vi_company_base WHERE code = '{code}')"
    sql = (f"SELECT json_build_object('sotp', (SELECT count(*) FROM vi_sotp WHERE company_id = {co}), "
           f"'fit', (SELECT count(*) FROM vi_fit_score_base WHERE company_id = {co}), 'moat', (SELECT count(*) FROM vi_moat_base WHERE company_id = {co}), "
           f"'chain', (SELECT count(*) FROM vi_value_chain_base WHERE company_id = {co}), 'comp', (SELECT count(*) FROM vi_competitor_base WHERE company_id = {co}), "
           f"'thesis', (SELECT count(*) FROM vi_thesis_base WHERE company_id = {co}), "
           f"'fc', (SELECT count(*) FROM vi_forecast_base f JOIN vi_model_base m ON m.id = f.model_id WHERE m.company_id = {co} AND m.status = '当前'))")
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
            "UNION ALL SELECT p.year::text, '预测', round((p.payout * 100)::numeric, 1) FROM vi_projection p "
            "JOIN vi_company_base co ON co.id = p.company_id AND co.code = '01698.HK' JOIN vi_model_base m ON m.id = p.model_id AND m.status = '当前' "
            "WHERE p.is_base ORDER BY 1", 'bar', {'x': 'year', 'y': '%', 'series': '口径'})),
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
    if code == '01698.HK':
        from tencent_dashboard import kpi_code as tencent_kpi_code
        return tencent_kpi_code()
    from company_dashboard import PROFILES, kpi_code as company_kpi_code
    if code in PROFILES:
        return company_kpi_code(code)
    js = KPI.replace('__COMPANY__', code).replace('__IRR_ONLY__', 'true' if irr_only(code) else 'false')
    if code != '600900.SH':
        from page_style import wrap_js
        js = wrap_js(js)
        js = js.replace('预测与估值 / 经营分部估值', '预测与估值 / 估值 / 经营分部（编辑）')
        js = js.replace('预测与估值 / 分部估值项', '预测与估值 / 估值 / 资产项目（编辑）')
    return js


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
