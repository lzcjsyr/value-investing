# 后台字段字典

核验日期：2026-10-26。以 PostgreSQL 当前实际结构为准；中文名称优先采用 NocoBase 字段标签，其次采用数据库注释。

本文供逐字段核对。业务流程、表的分工和优化建议见“数据结构说明”。“允许空”表示数据库层是否允许 NULL，并不等于页面一定允许留空。

## 业务分部 · `vi_business_base`

业务分部：一家公司的一块业务一行。明确业务边界、共享费用分摊与经营资产归属；现金、投资和可单独处置资产在资产估值与调整中处理。

| 字段 | 中文含义 | 数据类型 | 允许空 | 关系或可选值 |
|---|---|---|---|---|
| `id` | ID | bigint | 否 |  |
| `code` | 业务编号 | text | 是 |  |
| `name` | 业务名称 | text | 是 |  |
| `boundary` | 业务边界 | text | 是 |  |
| `cost_allocation` | 费用分摊依据 | text | 是 |  |
| `asset_boundary` | 经营资产与投入边界 | text | 是 |  |
| `sort` | 排序 | integer | 是 |  |
| `company_id` | 公司（ID） | bigint | 是 | FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE SET NULL |
| `created_at` | 创建时间 | timestamp with time zone | 否 |  |
| `updated_at` | 最后修改 | timestamp with time zone | 否 |  |

数据库关键约束：FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE SET NULL; PRIMARY KEY (id); UNIQUE (company_id, code)

## 商业模式拆解 · `vi_biz_model_base`

商业模式拆解：商业模式画布 9 项，每块业务一项一行（B1—B9 按画布顺序）；所属业务留空表示集团整体或共性，不表示自动继承。投资者关心的内容放进画布：盈利公式的收入一侧、收入结构、单价、增长与周期写在“收入来源”；盈利公式的成本一侧、成本构成、单位利润、资本需求与现金循环写在“成本结构”。只写事实与机制；有争议、决定价值的判断写在核心论点里。

| 字段 | 中文含义 | 数据类型 | 允许空 | 关系或可选值 |
|---|---|---|---|---|
| `id` | ID | bigint | 否 |  |
| `code` | 编号 | text | 是 |  |
| `element` | 要素 | text | 是 | 客户细分；价值主张；渠道通路；客户关系；收入来源；核心资源；关键业务；重要合作；成本结构 |
| `title` | 要点 | text | 是 |  |
| `content` | 说明 | text | 是 |  |
| `metric` | 关键数字 | text | 是 |  |
| `trend` | 变化与风险 | text | 是 |  |
| `company_id` | 公司（ID） | bigint | 是 | FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE SET NULL |
| `created_at` | 创建时间 | timestamp with time zone | 否 |  |
| `updated_at` | 最后修改 | timestamp with time zone | 否 |  |
| `business_id` | 所属业务（ID） | bigint | 是 | FOREIGN KEY (business_id) REFERENCES vi_business_base(id) ON DELETE SET NULL |

数据库关键约束：PRIMARY KEY (id); FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE SET NULL; FOREIGN KEY (business_id) REFERENCES vi_business_base(id) ON DELETE SET NULL; UNIQUE NULLS NOT DISTINCT (company_id, business_id, code)

## 变更日志 · `vi_change_log_base`

变更日志：每次修改假设或数据：旧值、新值、理由、依据、验证。

| 字段 | 中文含义 | 数据类型 | 允许空 | 关系或可选值 |
|---|---|---|---|---|
| `id` | ID | bigint | 否 |  |
| `change_date` | 日期 | date | 是 |  |
| `title` | 变更 | text | 是 |  |
| `target` | 对象 | text | 是 |  |
| `old_value` | 旧值 | text | 是 |  |
| `new_value` | 新值 | text | 是 |  |
| `reason` | 理由 | text | 是 |  |
| `basis` | 依据 | text | 是 |  |
| `verification` | 验证 | text | 是 |  |
| `company_id` | 公司（ID） | bigint | 是 | FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE SET NULL |
| `created_at` | 创建时间 | timestamp with time zone | 否 |  |
| `updated_at` | 最后修改 | timestamp with time zone | 否 |  |

数据库关键约束：FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE SET NULL; PRIMARY KEY (id)

## 采集运行 · `vi_collect_run_base`

采集运行：每按一次“立即采集”新增一行，触发“④ 手动采集”工作流跑完 采集→入库→自检；有公司时只采这家公司和通用指标，结果按本次的原始记录自动统计。

| 字段 | 中文含义 | 数据类型 | 允许空 | 关系或可选值 |
|---|---|---|---|---|
| `id` | ID | bigint | 否 |  |
| `label` | 运行 | text | 是 |  |
| `trigger_source` | 发起方式 | text | 是 | 手动；定时 |
| `status` | 状态 | text | 是 | 排队；运行中；完成 |
| `created_at` | 创建时间 | timestamp with time zone | 否 |  |
| `updated_at` | 最后修改 | timestamp with time zone | 否 |  |
| `company_id` | 公司（ID） | bigint | 是 | FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE SET NULL |

数据库关键约束：FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE SET NULL; PRIMARY KEY (id)

## 采集配置 · `vi_collector_base`

采集配置：自动采集的数据源：地址、解析器与参数、写入哪个指标。新增股票或水文站只需加一行配置。

| 字段 | 中文含义 | 数据类型 | 允许空 | 关系或可选值 |
|---|---|---|---|---|
| `id` | ID | bigint | 否 |  |
| `name` | 名称 | text | 是 |  |
| `url` | 采集地址 | text | 是 |  |
| `parser` | 解析器 | text | 是 | tencent_quote；tencent_fx；chinabond_curve；cjh_reservoir；sina_future |
| `parser_param` | 解析参数 | text | 是 |  |
| `enabled` | 启用 | boolean | 是 |  |
| `max_lag_days` | 允许观察滞后（天） | integer | 是 |  |
| `last_selfcheck` | 最近自检 | timestamp with time zone | 是 |  |
| `selfcheck_result` | 自检结果 | text | 是 |  |
| `notes` | 说明 | text | 是 |  |
| `metric_id` | 写入指标（ID） | bigint | 是 | FOREIGN KEY (metric_id) REFERENCES vi_metric_base(id) ON DELETE SET NULL |
| `created_at` | 创建时间 | timestamp with time zone | 否 |  |
| `updated_at` | 最后修改 | timestamp with time zone | 否 |  |

数据库关键约束：FOREIGN KEY (metric_id) REFERENCES vi_metric_base(id) ON DELETE SET NULL; PRIMARY KEY (id)

## 公司 · `vi_company_base`

公司：研究对象。业务量/单价的名称和单位在这里定义，估值模型统一用“业务量×单价＝收入”。

| 字段 | 中文含义 | 数据类型 | 允许空 | 关系或可选值 |
|---|---|---|---|---|
| `id` | ID | bigint | 否 |  |
| `code` | 证券代码 | text | 是 |  |
| `name` | 公司名称 | text | 是 |  |
| `exchange` | 交易所 | text | 是 |  |
| `industry` | 行业 | text | 是 |  |
| `currency` | 记账币种 | text | 是 |  |
| `volume_label` | 业务量名称 | text | 是 |  |
| `volume_unit` | 业务量单位 | text | 是 |  |
| `price_label` | 单价名称 | text | 是 |  |
| `price_unit` | 单价单位 | text | 是 |  |
| `is_default` | 驾驶舱默认展示 | boolean | 是 |  |
| `profile` | 公司简介 | text | 是 |  |
| `notes` | 备注 | text | 是 |  |
| `price_metric_id` | 股价指标（ID） | bigint | 是 | FOREIGN KEY (price_metric_id) REFERENCES vi_metric_base(id) ON DELETE SET NULL |
| `created_at` | 创建时间 | timestamp with time zone | 否 |  |
| `updated_at` | 最后修改 | timestamp with time zone | 否 |  |
| `price_fx_metric_id` | 股价汇率指标（ID） | bigint | 是 | FOREIGN KEY (price_fx_metric_id) REFERENCES vi_metric_base(id) ON DELETE SET NULL |

数据库关键约束：FOREIGN KEY (price_fx_metric_id) REFERENCES vi_metric_base(id) ON DELETE SET NULL; PRIMARY KEY (id); FOREIGN KEY (price_metric_id) REFERENCES vi_metric_base(id) ON DELETE SET NULL; UNIQUE (code)

## 竞争对手 · `vi_competitor_base`

竞争对手：直接对手、替代品、潜在进入者与海外对标。关键数字写明截至日期；第三方估算在来源里注明。

| 字段 | 中文含义 | 数据类型 | 允许空 | 关系或可选值 |
|---|---|---|---|---|
| `id` | ID | bigint | 否 |  |
| `name` | 对手 | text | 是 |  |
| `ticker` | 证券代码 | text | 是 |  |
| `relation` | 关系 | text | 是 | 直接竞争；同业对标；替代品；潜在进入者；海外对标；上游；下游与渠道 |
| `segment` | 竞争领域 | text | 是 |  |
| `scale_label` | 规模指标 | text | 是 |  |
| `scale_value` | 规模数值 | double precision | 是 |  |
| `scale_unit` | 规模单位 | text | 是 |  |
| `paying_rate` | 付费率或渗透率 | double precision | 是 |  |
| `price_point` | 价格 | text | 是 |  |
| `gross_margin` | 毛利率 | double precision | 是 |  |
| `growth` | 收入或用户增速 | double precision | 是 |  |
| `as_of` | 截至 | date | 是 |  |
| `strategy` | 打法 | text | 是 |  |
| `vs_us` | 相对本公司的强项与弱项 | text | 是 |  |
| `threat` | 威胁程度 | text | 是 | 高；中；低 |
| `trend` | 势头 | text | 是 | 上升；稳定；下降 |
| `company_id` | 公司（ID） | bigint | 是 | FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE SET NULL |
| `source_id` | 来源文档（ID） | bigint | 是 | FOREIGN KEY (source_id) REFERENCES vi_source_base(id) ON DELETE SET NULL |
| `created_at` | 创建时间 | timestamp with time zone | 否 |  |
| `updated_at` | 最后修改 | timestamp with time zone | 否 |  |

数据库关键约束：PRIMARY KEY (id); FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE SET NULL; FOREIGN KEY (source_id) REFERENCES vi_source_base(id) ON DELETE SET NULL; UNIQUE (company_id, name)

## 重要事实 · `vi_fact_base`

重要事实：从来源文档里摘出的一条可核验事实（尽量带期间和单位）。事实只记录“是什么”，解释放到论点或假设依据里。按期重复的数字（发电量、销量、新签合同额等）以「数据」为准：选“数字引自”的指标并写所属期间，不再另抄一份；一次性的数字照常写在数值里。

| 字段 | 中文含义 | 数据类型 | 允许空 | 关系或可选值 |
|---|---|---|---|---|
| `id` | ID | bigint | 否 |  |
| `title` | 事实 | text | 是 |  |
| `category` | 类别 | text | 是 | 经营；财务；资本开支；分红；债务；政策；治理；水文；估值方法；其他 |
| `statement` | 事实陈述 | text | 是 |  |
| `value` | 数值 | double precision | 是 |  |
| `unit` | 单位 | text | 是 |  |
| `period` | 所属期间 | text | 是 |  |
| `as_of` | 截至日期 | date | 是 |  |
| `verify_status` | 核验状态 | text | 是 | 已核验；待核验；建议值待核验 |
| `notes` | 备注 | text | 是 |  |
| `company_id` | 公司（ID） | bigint | 是 | FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE SET NULL |
| `source_id` | 来源文档（ID） | bigint | 是 | FOREIGN KEY (source_id) REFERENCES vi_source_base(id) ON DELETE SET NULL |
| `created_at` | 创建时间 | timestamp with time zone | 否 |  |
| `updated_at` | 最后修改 | timestamp with time zone | 否 |  |
| `metric_id` | 数字引自（指标）（ID） | bigint | 是 | FOREIGN KEY (metric_id) REFERENCES vi_metric_base(id) ON DELETE SET NULL |

数据库关键约束：PRIMARY KEY (id); FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE SET NULL; FOREIGN KEY (source_id) REFERENCES vi_source_base(id) ON DELETE SET NULL; FOREIGN KEY (metric_id) REFERENCES vi_metric_base(id) ON DELETE SET NULL

## 历史年度 · `vi_fin_history_base`

历史年度：一年一行，是财务模型的历史实际（逐年假设是预测）。报表项按当年年报披露口径录入，与「财务数据」自动对账（tools/fin_stmt.py check），重组追溯等口径差写在口径说明；业务量、分红、每股股息、带息负债、折旧摊销等报表外或需定口径的项目只录在这里。空白＝尚未取得，不是 0。派生指标（单价、派息率、同比、ROE 等）自动计算，论点与竞争壁垒的自动检查读这里。

| 字段 | 中文含义 | 数据类型 | 允许空 | 关系或可选值 |
|---|---|---|---|---|
| `id` | ID | bigint | 否 |  |
| `year` | 年度 | integer | 是 |  |
| `scope_note` | 口径说明 | text | 是 |  |
| `volume` | 业务量 | double precision | 是 |  |
| `revenue` | 营业收入（亿元） | double precision | 是 |  |
| `pretax_profit` | 利润总额（亿元） | double precision | 是 |  |
| `income_tax` | 所得税（亿元） | double precision | 是 |  |
| `np_parent` | 归母净利润（亿元） | double precision | 是 |  |
| `minority_profit` | 少数股东损益（亿元） | double precision | 是 |  |
| `da` | 折旧摊销（亿元） | double precision | 是 |  |
| `finance_cost` | 财务费用（亿元） | double precision | 是 |  |
| `invest_income` | 投资收益（亿元） | double precision | 是 |  |
| `equity_income` | 权益法投资收益（亿元） | double precision | 是 |  |
| `cfo` | 经营活动现金流（亿元） | double precision | 是 |  |
| `capex` | 资本开支（亿元） | double precision | 是 |  |
| `investee_cash_div` | 收到投资分红（亿元） | double precision | 是 |  |
| `net_borrowing` | 净借款（亿元） | double precision | 是 |  |
| `interest_debt` | 带息负债（期末，亿元） | double precision | 是 |  |
| `cash` | 货币资金（期末，亿元） | double precision | 是 |  |
| `dividend_total` | 现金分红总额（亿元） | double precision | 是 |  |
| `dps` | 每股股息（元） | double precision | 是 |  |
| `note` | 备注 | text | 是 |  |
| `company_id` | 公司（ID） | bigint | 是 | FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE SET NULL |
| `source_id` | 主要来源（ID） | bigint | 是 | FOREIGN KEY (source_id) REFERENCES vi_source_base(id) ON DELETE SET NULL |
| `created_at` | 创建时间 | timestamp with time zone | 否 |  |
| `updated_at` | 最后修改 | timestamp with time zone | 否 |  |
| `cost_of_sales` | 营业成本（亿元） | double precision | 是 |  |
| `equity_parent` | 归母净资产（期末，亿元） | double precision | 是 |  |

数据库关键约束：PRIMARY KEY (id); FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE SET NULL; FOREIGN KEY (source_id) REFERENCES vi_source_base(id) ON DELETE SET NULL; UNIQUE (company_id, year)

## 价投适配度 · `vi_fit_score_base`

价投适配度：长坡、厚雪、慢变、护城河、再投资、财务质量、治理配置、可估值性，各 0—5 分。总分 32—40 适合复利框架，22—31 合适，21 以下通常不符合价值投资标准。

| 字段 | 中文含义 | 数据类型 | 允许空 | 关系或可选值 |
|---|---|---|---|---|
| `id` | ID | bigint | 否 |  |
| `dimension` | 维度 | text | 是 | 长坡；厚雪；慢变；护城河；再投资；财务质量；治理配置；可估值性 |
| `score` | 评分（0—5） | integer | 是 |  |
| `rationale` | 理由与证据 | text | 是 |  |
| `counter` | 反证 | text | 是 |  |
| `sort` | 排序 | integer | 是 |  |
| `company_id` | 公司（ID） | bigint | 是 | FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE SET NULL |
| `created_at` | 创建时间 | timestamp with time zone | 否 |  |
| `updated_at` | 最后修改 | timestamp with time zone | 否 |  |

数据库关键约束：PRIMARY KEY (id); FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE SET NULL; UNIQUE (company_id, dimension)

## 逐年假设 · `vi_forecast_base`

逐年假设：基准情景下每年的经营与现金假设。每格都显式填写（没有“留空继承”）；利息由债务滚动自动计算。

| 字段 | 中文含义 | 数据类型 | 允许空 | 关系或可选值 |
|---|---|---|---|---|
| `id` | ID | bigint | 否 |  |
| `year` | 年度 | integer | 是 |  |
| `volume` | 业务量 | double precision | 是 |  |
| `price` | 单价 | double precision | 是 |  |
| `cash_cost` | 付现成本（亿元） | double precision | 是 |  |
| `depreciation` | 折旧摊销（亿元） | double precision | 是 |  |
| `other_contrib` | 其他净贡献（亿元） | double precision | 是 |  |
| `tax_rate` | 所得税率 | double precision | 是 |  |
| `minority_share` | 少数股东占比 | double precision | 是 |  |
| `payout` | 派息率 | double precision | 是 |  |
| `net_borrowing` | 净借款（亿元） | double precision | 是 |  |
| `cost_of_debt` | 平均债务成本 | double precision | 是 |  |
| `noncash_gain_deduct` | 非现金收益扣除（亿元） | double precision | 是 |  |
| `investee_cash_div` | 收到投资分红（亿元） | double precision | 是 |  |
| `other_cash_adj` | 其他现金调整（亿元） | double precision | 是 |  |
| `wc_increase` | 营运资本增加（亿元） | double precision | 是 |  |
| `maint_capex` | 维持资本开支（亿元） | double precision | 是 |  |
| `growth_capex` | 扩张资本开支（亿元） | double precision | 是 |  |
| `min_cash_topup` | 最低现金补充（亿元） | double precision | 是 |  |
| `operating_status` | 经营假设状态 | text | 是 | 旧模型迁移；建议值待核验；已核验 |
| `cash_status` | 现金桥接状态 | text | 是 | 未填；建议值待核验；已核验 |
| `note` | 说明 | text | 是 |  |
| `model_id` | 估值模型（ID） | bigint | 是 | FOREIGN KEY (model_id) REFERENCES vi_model_base(id) ON DELETE SET NULL |
| `created_at` | 创建时间 | timestamp with time zone | 否 |  |
| `updated_at` | 最后修改 | timestamp with time zone | 否 |  |

数据库关键约束：PRIMARY KEY (id); FOREIGN KEY (model_id) REFERENCES vi_model_base(id) ON DELETE SET NULL; UNIQUE (model_id, year)

## 待办清单 · `vi_issue_base`

待办清单：人工维护、做完即关的待办：数据源待接通、数值待核验、模型缺口、来源待核对，以及等你拍板的策略选择（如安全边际取哪一档）。对公司的判断（问题与结论）一律写在“核心论点”，缺的证据写在论点的“决定胜负的证据”，这里不重复；持续盯的指标在“跟踪事项”，数据能自动判断的在“自动检查”。

| 字段 | 中文含义 | 数据类型 | 允许空 | 关系或可选值 |
|---|---|---|---|---|
| `id` | ID | bigint | 否 |  |
| `code` | 编号 | text | 是 |  |
| `title` | 待办 | text | 是 |  |
| `severity` | 级别 | text | 是 | 关键；一般；策略；数据源 |
| `impact` | 影响范围 | text | 是 |  |
| `done_condition` | 完成条件 | text | 是 |  |
| `status` | 状态 | text | 是 | 待处理；处理中；已解决；不处理 |
| `progress` | 进展 | text | 是 |  |
| `company_id` | 公司（ID） | bigint | 是 | FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE SET NULL |
| `created_at` | 创建时间 | timestamp with time zone | 否 |  |
| `updated_at` | 最后修改 | timestamp with time zone | 否 |  |

数据库关键约束：FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE SET NULL; PRIMARY KEY (id)

## 假设依据 · `vi_judgment_base`

假设依据：事实 → 判断 → 参数：解释事实和论点如何影响哪个估值参数、改参数的门槛、什么情况下不改。论证本身写在核心论点里，这里只写到参数的传导。

| 字段 | 中文含义 | 数据类型 | 允许空 | 关系或可选值 |
|---|---|---|---|---|
| `id` | ID | bigint | 否 |  |
| `code` | 编号 | text | 是 |  |
| `title` | 判断主题 | text | 是 |  |
| `fact_layer` | 事实层 | text | 是 |  |
| `judgment` | 判断 | text | 是 |  |
| `transmission` | 数学传导 | text | 是 |  |
| `parameter` | 影响参数 | text | 是 |  |
| `affected_years` | 影响年份/情景 | text | 是 |  |
| `change_threshold` | 修改门槛 | text | 是 |  |
| `no_change_condition` | 不改模型的情况 | text | 是 |  |
| `counter_evidence` | 反证或替代解释 | text | 是 |  |
| `status` | 状态 | text | 是 | 研究规则；已形成建议；已采纳；已否决 |
| `company_id` | 公司（ID） | bigint | 是 | FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE SET NULL |
| `created_at` | 创建时间 | timestamp with time zone | 否 |  |
| `updated_at` | 最后修改 | timestamp with time zone | 否 |  |

数据库关键约束：PRIMARY KEY (id); FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE SET NULL; UNIQUE (company_id, code)

## 指标 · `vi_metric_base`

指标：一条数字序列的定义，数值在「数据」里。来源方式区分自动采集、公司披露、年报和手工整理；所属公司为空的是宏观数据（利率、汇率、商品等），归“宏观数据”项目所有，各公司按需使用；只和一家公司有关的（股价、水位、发电量、销量）挂在这家公司下。同一含义不同口径（单季、累计）分成不同指标，不拼接。

| 字段 | 中文含义 | 数据类型 | 允许空 | 关系或可选值 |
|---|---|---|---|---|
| `id` | ID | bigint | 否 |  |
| `code` | 指标代码 | text | 是 |  |
| `name` | 指标名称 | text | 是 |  |
| `unit` | 单位 | text | 是 |  |
| `category` | 类别 | text | 是 | 行情；利率；汇率；商品；宏观；水文；经营；财务；其他 |
| `source_name` | 数据来源 | text | 是 |  |
| `frequency` | 频率 | text | 是 |  |
| `valid_min` | 合理下限 | double precision | 是 |  |
| `valid_max` | 合理上限 | double precision | 是 |  |
| `notes` | 说明 | text | 是 |  |
| `company_id` | 所属公司（ID） | bigint | 是 | FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE SET NULL |
| `created_at` | 创建时间 | timestamp with time zone | 否 |  |
| `updated_at` | 最后修改 | timestamp with time zone | 否 |  |
| `source_kind` | 来源方式 | text | 是 | 自动采集；公司披露；年报；手工整理 |
| `basis` | 口径 | text | 是 | 时点；单季；半年累计；前三季度累计；全年；年初至今累计；滚动四季度 |

数据库关键约束：PRIMARY KEY (id); FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE SET NULL; UNIQUE (code)

## 竞争壁垒 · `vi_moat_base`

竞争壁垒：每一项候选壁垒：机制、财务体现、证据、反证、复制难度；看起来像壁垒其实不是的（伪壁垒）也要列出。壁垒能不能持续，在核心论点里正反论证并关联到这里。可设自动检查，读取历史年度。

| 字段 | 中文含义 | 数据类型 | 允许空 | 关系或可选值 |
|---|---|---|---|---|
| `id` | ID | bigint | 否 |  |
| `code` | 编号 | text | 是 |  |
| `title` | 壁垒 | text | 是 |  |
| `moat_type` | 类型 | text | 是 | 成本优势；品牌与定价权；转换成本；网络效应；规模经济；牌照与资源；工艺与组织；数据与算法；生态与渠道 |
| `verdict` | 判定 | text | 是 | 真实壁垒；局部优势；伪壁垒；待验证 |
| `strength` | 强度 | text | 是 | 强；中；弱；无 |
| `trend` | 趋势 | text | 是 | 增强；稳定；削弱 |
| `mechanism` | 机制 | text | 是 |  |
| `financial_link` | 财务体现 | text | 是 |  |
| `evidence` | 证据 | text | 是 |  |
| `counter` | 反证 | text | 是 |  |
| `replication` | 复制难度 | text | 是 |  |
| `threats` | 削弱因素 | text | 是 |  |
| `check_metric` | 自动检查·指标 | text | 是 | 业务量；单价；营业收入；归母净利润；派息率；财务费用；业务量同比；单价同比；营业收入同比；财务费用同比；毛利率；ROE；经营现金流÷归母净利润；资本开支÷经营现金流；净负债；净负债÷EBITDA |
| `check_op` | 自动检查·条件 | text | 是 | <；<=；>；>= |
| `check_threshold` | 自动检查·阈值 | double precision | 是 |  |
| `check_years` | 自动检查·连续年数 | integer | 是 |  |
| `company_id` | 公司（ID） | bigint | 是 | FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE SET NULL |
| `created_at` | 创建时间 | timestamp with time zone | 否 |  |
| `updated_at` | 最后修改 | timestamp with time zone | 否 |  |

数据库关键约束：PRIMARY KEY (id); FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE SET NULL; UNIQUE (company_id, code)

## 估值模型 · `vi_model_base`

估值模型：一家公司的一版估值模型：基准年、终值年、股本、折现率构成、期初负债与安全边际。

| 字段 | 中文含义 | 数据类型 | 允许空 | 关系或可选值 |
|---|---|---|---|---|
| `id` | ID | bigint | 否 |  |
| `name` | 模型名称 | text | 是 |  |
| `status` | 状态 | text | 是 | 当前；归档 |
| `method` | 方法 | text | 是 |  |
| `base_year` | 基准年 | integer | 是 |  |
| `terminal_year` | 终值年 | integer | 是 |  |
| `shares` | 股本（亿股） | double precision | 是 |  |
| `rf` | 无风险利率 | double precision | 是 |  |
| `rf_date` | 无风险利率日期 | date | 是 |  |
| `erp` | 风险溢价 | double precision | 是 |  |
| `opening_debt` | 期初带息负债（亿元） | double precision | 是 |  |
| `margin_low` | 安全边际·低档 | double precision | 是 |  |
| `margin_high` | 安全边际·高档 | double precision | 是 |  |
| `notes` | 模型说明 | text | 是 |  |
| `company_id` | 公司（ID） | bigint | 是 | FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE SET NULL |
| `rf_metric_id` | 无风险利率参考指标（ID） | bigint | 是 | FOREIGN KEY (rf_metric_id) REFERENCES vi_metric_base(id) ON DELETE SET NULL |
| `created_at` | 创建时间 | timestamp with time zone | 否 |  |
| `updated_at` | 最后修改 | timestamp with time zone | 否 |  |
| `required_return` | 要求收益率 | double precision | 是 |  |
| `opening_op_assets` | 期初经营性长期资产（亿元） | double precision | 是 |  |
| `opening_lt_invest` | 期初长期股权投资（亿元） | double precision | 是 |  |
| `opening_equity` | 期初归母权益（亿元） | double precision | 是 |  |
| `opening_minority` | 期初少数股东权益（亿元） | double precision | 是 |  |
| `primary_method` | 主估值方法 | text | 是 | 股息贴现；分部加总 |
| `sotp_year` | 分部加总·核心盈利年份 | integer | 是 |  |
| `sotp_core_adj` | 分部加总·核心盈利调整（亿元） | double precision | 是 |  |
| `sotp_as_of` | 分部加总·资产负债日 | date | 是 |  |

数据库关键约束：PRIMARY KEY (id); FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE SET NULL; FOREIGN KEY (rf_metric_id) REFERENCES vi_metric_base(id) ON DELETE SET NULL

## 数据 · `vi_observation_base`

数据：一行＝某个指标在某一期的一个数：自动采集的按天（股价、利率、水位），公司披露的按期（发电量、销量、新签合同额）。同一指标同一日期多次采集时取最后一次为“当前版本”；超出合理范围的为无效。公司披露的数据写期间、同比、来源文档，以及经营影响、经营解读和披露摘要。

| 字段 | 中文含义 | 数据类型 | 允许空 | 关系或可选值 |
|---|---|---|---|---|
| `id` | ID | bigint | 否 |  |
| `obs_date` | 观察日期 | date | 是 |  |
| `value` | 数值 | double precision | 是 |  |
| `collected_at` | 采集时间 | timestamp with time zone | 是 |  |
| `source` | 采集地址 | text | 是 |  |
| `note` | 使用边界 | text | 是 |  |
| `metric_id` | 指标（ID） | bigint | 是 | FOREIGN KEY (metric_id) REFERENCES vi_metric_base(id) ON DELETE SET NULL |
| `raw_capture_id` | 原始采集记录（ID） | bigint | 是 | FOREIGN KEY (raw_capture_id) REFERENCES vi_raw_capture_base(id) ON DELETE SET NULL |
| `created_at` | 创建时间 | timestamp with time zone | 否 |  |
| `updated_at` | 最后修改 | timestamp with time zone | 否 |  |
| `period` | 期间 | text | 是 |  |
| `yoy` | 同比 | double precision | 是 |  |
| `impact` | 经营影响 | text | 是 | 利好；中性；利空；待判断 |
| `assessment` | 经营解读 | text | 是 |  |
| `summary` | 披露摘要与口径 | text | 是 |  |
| `status` | 处理状态 | text | 是 | 已入模；待处理；无需入模 |
| `doc_id` | 来源文档（ID） | bigint | 是 | FOREIGN KEY (doc_id) REFERENCES vi_source_base(id) ON DELETE SET NULL |

数据库关键约束：PRIMARY KEY (id); FOREIGN KEY (metric_id) REFERENCES vi_metric_base(id) ON DELETE SET NULL; FOREIGN KEY (raw_capture_id) REFERENCES vi_raw_capture_base(id) ON DELETE SET NULL; FOREIGN KEY (doc_id) REFERENCES vi_source_base(id) ON DELETE SET NULL

## 原始采集记录 · `vi_raw_capture_base`

原始采集记录：每次采集保存完整原始响应；解析、校验、去重全部由 SQL 视图完成，可追溯。

| 字段 | 中文含义 | 数据类型 | 允许空 | 关系或可选值 |
|---|---|---|---|---|
| `id` | ID | bigint | 否 |  |
| `run_label` | 运行标识 | text | 是 |  |
| `collected_at` | 采集时间 | timestamp with time zone | 是 |  |
| `status` | 处理状态 | text | 是 | 采集中；待入库；抓取失败；已入库；重复未入库；校验失败 |
| `raw_response` | 原始响应 | text | 是 |  |
| `collector_id` | 采集配置（ID） | bigint | 是 | FOREIGN KEY (collector_id) REFERENCES vi_collector_base(id) ON DELETE SET NULL |
| `created_at` | 创建时间 | timestamp with time zone | 否 |  |
| `updated_at` | 最后修改 | timestamp with time zone | 否 |  |
| `fetch_result` | 抓取结果（原文） | text | 是 |  |
| `run_id` | 采集运行（ID） | bigint | 是 | FOREIGN KEY (run_id) REFERENCES vi_collect_run_base(id) ON DELETE SET NULL |

数据库关键约束：FOREIGN KEY (run_id) REFERENCES vi_collect_run_base(id) ON DELETE SET NULL; PRIMARY KEY (id); FOREIGN KEY (collector_id) REFERENCES vi_collector_base(id) ON DELETE SET NULL

## 风险分析 · `vi_risk_base`

风险分析：会让这笔投资亏钱的不利事件：传导路径、可能性×冲击（自动定级）、量化影响、缓冲因素、在估值里怎么处理、预警信号与触发后应对。风险是论点失败或外部冲击的“事件”，论证本身仍在核心论点里，这里只关联会被削弱的论点；落到参数的关联假设依据，盯什么关联跟踪事项。

| 字段 | 中文含义 | 数据类型 | 允许空 | 关系或可选值 |
|---|---|---|---|---|
| `id` | ID | bigint | 否 |  |
| `code` | 编号 | text | 是 |  |
| `title` | 风险 | text | 是 |  |
| `category` | 类别 | text | 是 | 行业与竞争；技术与替代；经营与执行；财务与资产质量；政策与监管；治理与资本配置；宏观与环境；估值与市场 |
| `mechanism` | 传导路径 | text | 是 |  |
| `probability` | 可能性 | text | 是 | 高；中；低 |
| `impact` | 冲击 | text | 是 | 高；中；低 |
| `horizon` | 时间窗口 | text | 是 | 1 年内；1—3 年；3 年以上 |
| `trend` | 趋势 | text | 是 | 上升；稳定；下降 |
| `impact_estimate` | 影响测算 | text | 是 |  |
| `mitigants` | 缓冲因素 | text | 是 |  |
| `treatment` | 估值处理 | text | 是 | 已计入基准情景；已计入悲观情景；体现在折现率或门槛；未计入估值 |
| `early_warning` | 预警信号 | text | 是 |  |
| `response` | 触发后应对 | text | 是 |  |
| `status` | 状态 | text | 是 | 监控中；已部分发生；已发生；已缓解；已解除 |
| `company_id` | 公司（ID） | bigint | 是 | FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE SET NULL |
| `created_at` | 创建时间 | timestamp with time zone | 否 |  |
| `updated_at` | 最后修改 | timestamp with time zone | 否 |  |

数据库关键约束：PRIMARY KEY (id); FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE SET NULL; UNIQUE (company_id, code)

## 情景 · `vi_scenario_base`

情景：情景＝对逐年假设的整体调整：业务量、单价、付现成本乘以系数，折现率与永续增长按情景设置。

| 字段 | 中文含义 | 数据类型 | 允许空 | 关系或可选值 |
|---|---|---|---|---|
| `id` | ID | bigint | 否 |  |
| `name` | 情景 | text | 是 |  |
| `is_base` | 基准情景 | boolean | 是 |  |
| `sort` | 排序 | integer | 是 |  |
| `volume_factor` | 业务量系数 | double precision | 是 |  |
| `price_factor` | 单价系数 | double precision | 是 |  |
| `cost_factor` | 付现成本系数 | double precision | 是 |  |
| `discount_rate` | 折现率（留空＝基准折现率） | double precision | 是 |  |
| `terminal_growth` | 永续增长率 | double precision | 是 |  |
| `nature` | 假设性质 | text | 是 |  |
| `description` | 情景说明 | text | 是 |  |
| `model_id` | 估值模型（ID） | bigint | 是 | FOREIGN KEY (model_id) REFERENCES vi_model_base(id) ON DELETE SET NULL |
| `created_at` | 创建时间 | timestamp with time zone | 否 |  |
| `updated_at` | 最后修改 | timestamp with time zone | 否 |  |
| `ronic` | 新增投资回报率 | double precision | 是 |  |
| `sotp_multiple` | 合理倍数（手填） | double precision | 是 |  |
| `probability` | 情景概率 | double precision | 是 |  |

数据库关键约束：PRIMARY KEY (id); FOREIGN KEY (model_id) REFERENCES vi_model_base(id) ON DELETE SET NULL; UNIQUE (model_id, name)

## 资产估值与调整 · `vi_sotp_item_base`

资产估值与调整：总价值＝业务估值＋资产估值与调整净额。单独计价的资产加计、负债扣减；已含业务估值或不计价的项目只作边界说明，计入值为零。固定资产只有在相关盈利、租金或处置收益未计入业务价值时才单独加计。情景留空＝全部，同编号情景专属行优先。

| 字段 | 中文含义 | 数据类型 | 允许空 | 关系或可选值 |
|---|---|---|---|---|
| `id` | ID | bigint | 否 |  |
| `code` | 编号 | text | 是 |  |
| `name` | 项目 | text | 是 |  |
| `kind` | 类别 | text | 是 | 现金及等价物；带息负债；经营所需现金；资金汇出成本；对外投资；固定资产；其他非经营资产；少数股东权益；其他调整 |
| `amount` | 金额（亿元） | double precision | 是 |  |
| `haircut` | 折价 | double precision | 是 |  |
| `as_of` | 截至 | date | 是 |  |
| `basis` | 依据 | text | 是 |  |
| `model_id` | 估值模型（ID） | bigint | 是 | FOREIGN KEY (model_id) REFERENCES vi_model_base(id) ON DELETE SET NULL |
| `scenario_id` | 适用情景（ID） | bigint | 是 | FOREIGN KEY (scenario_id) REFERENCES vi_scenario_base(id) ON DELETE SET NULL |
| `created_at` | 创建时间 | timestamp with time zone | 否 |  |
| `updated_at` | 最后修改 | timestamp with time zone | 否 |  |
| `business_id` | 相关业务（ID） | bigint | 是 | FOREIGN KEY (business_id) REFERENCES vi_business_base(id) ON DELETE SET NULL |
| `treatment` | 计价处理 | text | 是 | 单独计价；已含业务估值；不计价 |
| `valuation_method` | 资产计价依据 | text | 是 | 账面价值；市场价值；可变现净值；现值；研究估计 |
| `boundary` | 计价边界 | text | 是 |  |

数据库关键约束：PRIMARY KEY (id); FOREIGN KEY (model_id) REFERENCES vi_model_base(id) ON DELETE SET NULL; FOREIGN KEY (scenario_id) REFERENCES vi_scenario_base(id) ON DELETE SET NULL; FOREIGN KEY (business_id) REFERENCES vi_business_base(id) ON DELETE SET NULL

## 经营分部估值 · `vi_sotp_segment_base`

经营分部估值：分部加总里的经营业务，按发展阶段各用一种方法：成熟或周期业务用“盈利×倍数”（正常化盈利）；成长业务用“稳态折现”（稳态年盈利×退出倍数折回今天，加上到稳态前的期间现金流）；投入期业务用“承诺投入”（只计已承诺的成本，回报不计入）。一行一个分部；适用情景留空＝所有情景，同编号可按情景另写一行。

| 字段 | 中文含义 | 数据类型 | 允许空 | 关系或可选值 |
|---|---|---|---|---|
| `id` | ID | bigint | 否 |  |
| `code` | 编号 | text | 是 |  |
| `name` | 分部 | text | 是 |  |
| `method` | 估值方法 | text | 是 | 盈利×倍数；稳态折现；承诺投入；直接估值 |
| `stage` | 发展阶段 | text | 是 |  |
| `earn_year` | 盈利年份 | integer | 是 |  |
| `revenue` | 收入（亿元） | double precision | 是 |  |
| `op_margin` | 经营利润率 | double precision | 是 |  |
| `tax_rate` | 所得税率 | double precision | 是 |  |
| `attrib` | 归母比例 | double precision | 是 |  |
| `multiple` | 倍数（手填） | double precision | 是 |  |
| `ronic` | 新增投资回报率 | double precision | 是 |  |
| `growth` | 永续增长率 | double precision | 是 |  |
| `discount_rate` | 折现率 | double precision | 是 |  |
| `interim_cash` | 期间现金流（亿元） | double precision | 是 |  |
| `commit_amount` | 承诺投入·剩余金额（亿元） | double precision | 是 |  |
| `commit_years` | 承诺投入·剩余年数 | double precision | 是 |  |
| `ongoing_cost` | 承诺期后年成本（亿元） | double precision | 是 |  |
| `basis` | 依据 | text | 是 |  |
| `model_id` | 估值模型（ID） | bigint | 是 | FOREIGN KEY (model_id) REFERENCES vi_model_base(id) ON DELETE SET NULL |
| `scenario_id` | 适用情景（ID） | bigint | 是 | FOREIGN KEY (scenario_id) REFERENCES vi_scenario_base(id) ON DELETE SET NULL |
| `created_at` | 创建时间 | timestamp with time zone | 否 |  |
| `updated_at` | 最后修改 | timestamp with time zone | 否 |  |
| `direct_value` | 直接估值（亿元） | double precision | 是 |  |
| `business_id` | 所属业务（ID） | bigint | 是 | FOREIGN KEY (business_id) REFERENCES vi_business_base(id) ON DELETE SET NULL |

数据库关键约束：PRIMARY KEY (id); FOREIGN KEY (model_id) REFERENCES vi_model_base(id) ON DELETE SET NULL; FOREIGN KEY (scenario_id) REFERENCES vi_scenario_base(id) ON DELETE SET NULL; FOREIGN KEY (business_id) REFERENCES vi_business_base(id) ON DELETE SET NULL

## 来源文档 · `vi_source_base`

来源文档：原始出处：年报、公告、数据库取数、官网。一份文档可以支撑多条重要事实。

| 字段 | 中文含义 | 数据类型 | 允许空 | 关系或可选值 |
|---|---|---|---|---|
| `id` | ID | bigint | 否 |  |
| `title` | 标题 | text | 是 |  |
| `source_type` | 类型 | text | 是 | 定期报告；临时公告；官方网站；数据库取数；研究方法；研究推导；旧系统迁移 |
| `publisher` | 发布方 | text | 是 |  |
| `publish_date` | 发布日期 | date | 是 |  |
| `url` | 链接 | text | 是 |  |
| `reliability` | 可靠性 | text | 是 | 一级·法定披露；二级·官方统计；三级·第三方数据；研究推导 |
| `verify_status` | 核验状态 | text | 是 | 已读原文；数值已核对；待核验；仅定位入口 |
| `retrieved_on` | 获取日期 | date | 是 |  |
| `summary` | 内容摘要 | text | 是 |  |
| `limitations` | 口径与局限 | text | 是 |  |
| `company_id` | 公司（ID） | bigint | 是 | FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE SET NULL |
| `created_at` | 创建时间 | timestamp with time zone | 否 |  |
| `updated_at` | 最后修改 | timestamp with time zone | 否 |  |

数据库关键约束：PRIMARY KEY (id); FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE SET NULL

## 核心论点 · `vi_thesis_base`

核心论点：决定价值的几个关键判断，每条都正反论证：正方立论、反方立论、互相反驳，再给裁决、把握、改判条件和对模型的影响。判断只写这里：没有答案的判断性问题也写成论点，缺的证据写进“决定胜负的证据”，不进“待办清单”。壁垒能否持续的论点关联到竞争壁垒（伪壁垒以外每项壁垒至少一条辩论过的论点）；能量化的改判条件设自动检查，读取历史年度。

| 字段 | 中文含义 | 数据类型 | 允许空 | 关系或可选值 |
|---|---|---|---|---|
| `id` | ID | bigint | 否 |  |
| `code` | 编号 | text | 是 |  |
| `title` | 论点 | text | 是 |  |
| `category` | 类别 | text | 是 | 壁垒；经营；财务；治理；估值 |
| `bull_case` | 正方立论 | text | 是 |  |
| `decisive_evidence` | 决定胜负的证据 | text | 是 |  |
| `bear_case` | 反方立论 | text | 是 |  |
| `verdict` | 裁决理由 | text | 是 |  |
| `status` | 裁决 | text | 是 | 成立；观察；存疑；证伪 |
| `mind_changer` | 改判条件 | text | 是 |  |
| `check_metric` | 自动检查·指标 | text | 是 | 业务量；单价；营业收入；归母净利润；派息率；财务费用；业务量同比；单价同比；营业收入同比；财务费用同比；毛利率；ROE；经营现金流÷归母净利润；资本开支÷经营现金流；净负债；净负债÷EBITDA |
| `check_op` | 自动检查·条件 | text | 是 | <；<=；>；>= |
| `check_threshold` | 自动检查·阈值 | double precision | 是 |  |
| `check_years` | 自动检查·连续年数 | integer | 是 |  |
| `company_id` | 公司（ID） | bigint | 是 | FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE SET NULL |
| `created_at` | 创建时间 | timestamp with time zone | 否 |  |
| `updated_at` | 最后修改 | timestamp with time zone | 否 |  |
| `confidence` | 把握 | text | 是 | 高；中；低 |
| `bull_rebuttal` | 正方反驳 | text | 是 |  |
| `bear_rebuttal` | 反方反驳 | text | 是 |  |
| `model_impact` | 对模型的影响 | text | 是 |  |
| `external_view` | 外部观点 | text | 是 |  |
| `debated_on` | 辩论日期 | date | 是 |  |

数据库关键约束：PRIMARY KEY (id); FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE SET NULL; UNIQUE (company_id, code)

## 单参数试验 · `vi_trial_base`

单参数试验：在基准情景上只改一个参数，看每股价值变化多少。不改正式假设。

| 字段 | 中文含义 | 数据类型 | 允许空 | 关系或可选值 |
|---|---|---|---|---|
| `id` | ID | bigint | 否 |  |
| `name` | 试验 | text | 是 |  |
| `start_year` | 开始年度 | integer | 是 |  |
| `end_year` | 结束年度 | integer | 是 |  |
| `volume_delta` | 业务量变动 | double precision | 是 |  |
| `price_delta` | 单价变动 | double precision | 是 |  |
| `cost_delta` | 付现成本变动（亿元/年） | double precision | 是 |  |
| `da_delta` | 折旧变动（亿元/年） | double precision | 是 |  |
| `interest_delta` | 利息变动（亿元/年） | double precision | 是 |  |
| `rate_delta` | 折现率变动 | double precision | 是 |  |
| `boundary` | 事实与判断边界 | text | 是 |  |
| `model_id` | 估值模型（ID） | bigint | 是 | FOREIGN KEY (model_id) REFERENCES vi_model_base(id) ON DELETE SET NULL |
| `created_at` | 创建时间 | timestamp with time zone | 否 |  |
| `updated_at` | 最后修改 | timestamp with time zone | 否 |  |

数据库关键约束：FOREIGN KEY (model_id) REFERENCES vi_model_base(id) ON DELETE SET NULL; PRIMARY KEY (id)

## 产业链与五力 · `vi_value_chain_base`

产业链与五力：上下游各环节是谁、拿走多少利润、对公司的议价力强弱；每行同时标注属于波特五力中的哪一种力量。同业、替代品、潜在进入者这几行只评估力量强弱，具体对手的规模与打法写在竞争对手表，并在“相关对手”里关联。

| 字段 | 中文含义 | 数据类型 | 允许空 | 关系或可选值 |
|---|---|---|---|---|
| `id` | ID | bigint | 否 |  |
| `code` | 编号 | text | 是 |  |
| `position` | 环节 | text | 是 | 上游供给；本公司环节；下游客户；渠道与流量；互补方；替代品；潜在进入者；同业竞争；监管 |
| `participant` | 参与者 | text | 是 |  |
| `role` | 提供或购买什么 | text | 是 |  |
| `force` | 五力归类 | text | 是 | 供应商议价能力；买方议价能力；新进入者威胁；替代品威胁；行业内竞争；不适用 |
| `power` | 力量强弱 | text | 是 | 强；中；弱 |
| `effect` | 对公司 | text | 是 | 有利；中性；不利 |
| `trend` | 趋势 | text | 是 | 增强；稳定；减弱 |
| `profit_share` | 利润池或成本占比 | text | 是 |  |
| `analysis` | 分析 | text | 是 |  |
| `counter` | 反面证据 | text | 是 |  |
| `company_id` | 公司（ID） | bigint | 是 | FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE SET NULL |
| `created_at` | 创建时间 | timestamp with time zone | 否 |  |
| `updated_at` | 最后修改 | timestamp with time zone | 否 |  |

数据库关键约束：PRIMARY KEY (id); FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE SET NULL; UNIQUE (company_id, code)

## 跟踪事项 · `vi_watch_base`

记录定量指标和定性事实。主表保留取数方式、取数频率、状态；状态只表示未记录／待更新／已更新。模型基准、触发上下限、触发规则及动作只留后台历史，不参与更新状态。数值引用指标，定性事实和截至日期必须一起填写。


| 字段 | 中文含义 | 数据类型 | 允许空 | 关系或可选值 |
|---|---|---|---|---|
| `id` | ID | bigint | 否 |  |
| `code` | 编号 | text | 是 |  |
| `title` | 跟踪什么 | text | 是 |  |
| `frequency` | 更新频率 | text | 是 | 交易日；周；月；季；半年；年；不定期 |
| `preferred_source` | 来源 | text | 是 |  |
| `trigger` | 触发条件说明 | text | 是 |  |
| `action` | 触发后动作 | text | 是 |  |
| `company_id` | 公司（ID） | bigint | 是 | FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE SET NULL |
| `metric_id` | 数据（指标）（ID） | bigint | 是 | FOREIGN KEY (metric_id) REFERENCES vi_metric_base(id) ON DELETE SET NULL |
| `created_at` | 创建时间 | timestamp with time zone | 否 |  |
| `fact_note` | 事实记录 | text | 是 | 与 fact_date 成对填写；只记录事实 |
| `fact_date` | 事实截至（手填） | date | 是 | 事实日期，不是编辑日期 |
| `updated_at` | 最后修改 | timestamp with time zone | 否 |  |
| `purpose` | 为什么跟踪 | text | 是 |  |
| `fetch_method` | 取数方式 | text | 是 | 自动采集；脚本抓取；手动录入；事件阅读 |
| `compare` | 比较 | text | 是 | 数值；同比 |
| `baseline` | 模型基准 | double precision | 是 |  |
| `lower` | 触发下限 | double precision | 是 |  |
| `upper` | 触发上限 | double precision | 是 |  |

数据库关键约束：PRIMARY KEY (id); FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE SET NULL; FOREIGN KEY (metric_id) REFERENCES vi_metric_base(id) ON DELETE SET NULL

前台计算列：`latest_fact` 最新事实、`fact_as_of` 事实截至、`state` 更新状态。内部的 latest_value、latest_period、latest_date、next_due 与 vs_baseline 不展示；vs_baseline 不再计算。

## 财务数据 · `vi_fin_stmt_base`

财务数据：季度完整三大报表（资产负债表、利润表、现金流量表），一行＝公司×报表×报告期×科目，金额为报表原值折亿元。合并报表科目以这里为准，由 tools/fin_stmt.py 取数检验后入库，不手录（A 股来自新浪财报、港股来自东方财富港股报表，都经 akshare）。空白科目＝该期未披露。资产负债表是时点余额；利润表/现金流量表是年初至报告期末的累计数。

| 字段 | 中文含义 | 数据类型 | 允许空 | 关系或可选值 |
|---|---|---|---|---|
| `id` | ID | bigint | 否 |  |
| `period` | 报告期 | text | 是 |  |
| `period_end` | 期末日期 | date | 是 |  |
| `stmt` | 报表 | text | 是 | 资产负债表；利润表；现金流量表 |
| `item` | 科目 | text | 是 |  |
| `seq` | 行次 | integer | 是 |  |
| `amount` | 金额（亿元） | double precision | 是 |  |
| `company_id` | 公司（ID） | bigint | 是 | FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE SET NULL |
| `created_at` | 创建时间 | timestamp with time zone | 否 |  |
| `updated_at` | 最后修改 | timestamp with time zone | 否 |  |

数据库关键约束：FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE SET NULL; PRIMARY KEY (id); UNIQUE (company_id, stmt, period_end, item)

## 关联表的实际键

| 关联表 | 两端外键与唯一性 |
|---|---|
| `vi_lnk_biz_model_facts` | FOREIGN KEY (biz_model_id) REFERENCES vi_biz_model_base(id) ON DELETE CASCADE；FOREIGN KEY (fact_id) REFERENCES vi_fact_base(id) ON DELETE CASCADE；PRIMARY KEY (biz_model_id, fact_id) |
| `vi_lnk_company_macro_metrics` | FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE CASCADE；FOREIGN KEY (metric_id) REFERENCES vi_metric_base(id) ON DELETE CASCADE；PRIMARY KEY (company_id, metric_id) |
| `vi_lnk_competitor_facts` | FOREIGN KEY (competitor_id) REFERENCES vi_competitor_base(id) ON DELETE CASCADE；FOREIGN KEY (fact_id) REFERENCES vi_fact_base(id) ON DELETE CASCADE；PRIMARY KEY (competitor_id, fact_id) |
| `vi_lnk_fit_score_theses` | FOREIGN KEY (fit_score_id) REFERENCES vi_fit_score_base(id) ON DELETE CASCADE；PRIMARY KEY (fit_score_id, thesis_id)；FOREIGN KEY (thesis_id) REFERENCES vi_thesis_base(id) ON DELETE CASCADE |
| `vi_lnk_forecast_facts` | FOREIGN KEY (fact_id) REFERENCES vi_fact_base(id) ON DELETE CASCADE；FOREIGN KEY (forecast_id) REFERENCES vi_forecast_base(id) ON DELETE CASCADE；PRIMARY KEY (forecast_id, fact_id) |
| `vi_lnk_forecast_judgments` | FOREIGN KEY (forecast_id) REFERENCES vi_forecast_base(id) ON DELETE CASCADE；FOREIGN KEY (judgment_id) REFERENCES vi_judgment_base(id) ON DELETE CASCADE；PRIMARY KEY (forecast_id, judgment_id) |
| `vi_lnk_judgment_facts` | FOREIGN KEY (fact_id) REFERENCES vi_fact_base(id) ON DELETE CASCADE；FOREIGN KEY (judgment_id) REFERENCES vi_judgment_base(id) ON DELETE CASCADE；PRIMARY KEY (judgment_id, fact_id) |
| `vi_lnk_judgment_theses` | FOREIGN KEY (judgment_id) REFERENCES vi_judgment_base(id) ON DELETE CASCADE；PRIMARY KEY (judgment_id, thesis_id)；FOREIGN KEY (thesis_id) REFERENCES vi_thesis_base(id) ON DELETE CASCADE |
| `vi_lnk_moat_facts` | FOREIGN KEY (fact_id) REFERENCES vi_fact_base(id) ON DELETE CASCADE；FOREIGN KEY (moat_id) REFERENCES vi_moat_base(id) ON DELETE CASCADE；PRIMARY KEY (moat_id, fact_id) |
| `vi_lnk_moat_theses` | FOREIGN KEY (moat_id) REFERENCES vi_moat_base(id) ON DELETE CASCADE；PRIMARY KEY (moat_id, thesis_id)；FOREIGN KEY (thesis_id) REFERENCES vi_thesis_base(id) ON DELETE CASCADE |
| `vi_lnk_risk_facts` | FOREIGN KEY (fact_id) REFERENCES vi_fact_base(id) ON DELETE CASCADE；PRIMARY KEY (risk_id, fact_id)；FOREIGN KEY (risk_id) REFERENCES vi_risk_base(id) ON DELETE CASCADE |
| `vi_lnk_risk_judgments` | FOREIGN KEY (judgment_id) REFERENCES vi_judgment_base(id) ON DELETE CASCADE；PRIMARY KEY (risk_id, judgment_id)；FOREIGN KEY (risk_id) REFERENCES vi_risk_base(id) ON DELETE CASCADE |
| `vi_lnk_risk_theses` | PRIMARY KEY (risk_id, thesis_id)；FOREIGN KEY (risk_id) REFERENCES vi_risk_base(id) ON DELETE CASCADE；FOREIGN KEY (thesis_id) REFERENCES vi_thesis_base(id) ON DELETE CASCADE |
| `vi_lnk_risk_watches` | PRIMARY KEY (risk_id, watch_id)；FOREIGN KEY (risk_id) REFERENCES vi_risk_base(id) ON DELETE CASCADE；FOREIGN KEY (watch_id) REFERENCES vi_watch_base(id) ON DELETE CASCADE |
| `vi_lnk_sotp_item_facts` | FOREIGN KEY (fact_id) REFERENCES vi_fact_base(id) ON DELETE CASCADE；PRIMARY KEY (sotp_item_id, fact_id)；FOREIGN KEY (sotp_item_id) REFERENCES vi_sotp_item_base(id) ON DELETE CASCADE |
| `vi_lnk_sotp_segment_facts` | FOREIGN KEY (fact_id) REFERENCES vi_fact_base(id) ON DELETE CASCADE；PRIMARY KEY (sotp_segment_id, fact_id)；FOREIGN KEY (sotp_segment_id) REFERENCES vi_sotp_segment_base(id) ON DELETE CASCADE |
| `vi_lnk_thesis_facts` | FOREIGN KEY (fact_id) REFERENCES vi_fact_base(id) ON DELETE CASCADE；PRIMARY KEY (thesis_id, fact_id)；FOREIGN KEY (thesis_id) REFERENCES vi_thesis_base(id) ON DELETE CASCADE |
| `vi_lnk_trial_judgments` | FOREIGN KEY (judgment_id) REFERENCES vi_judgment_base(id) ON DELETE CASCADE；PRIMARY KEY (trial_id, judgment_id)；FOREIGN KEY (trial_id) REFERENCES vi_trial_base(id) ON DELETE CASCADE |
| `vi_lnk_value_chain_competitors` | FOREIGN KEY (competitor_id) REFERENCES vi_competitor_base(id) ON DELETE CASCADE；PRIMARY KEY (value_chain_id, competitor_id)；FOREIGN KEY (value_chain_id) REFERENCES vi_value_chain_base(id) ON DELETE CASCADE |
| `vi_lnk_value_chain_facts` | FOREIGN KEY (fact_id) REFERENCES vi_fact_base(id) ON DELETE CASCADE；PRIMARY KEY (value_chain_id, fact_id)；FOREIGN KEY (value_chain_id) REFERENCES vi_value_chain_base(id) ON DELETE CASCADE |
| `vi_lnk_watch_judgments` | FOREIGN KEY (judgment_id) REFERENCES vi_judgment_base(id) ON DELETE CASCADE；PRIMARY KEY (watch_id, judgment_id)；FOREIGN KEY (watch_id) REFERENCES vi_watch_base(id) ON DELETE CASCADE |

| `vi_lnk_watch_theses` | FOREIGN KEY (watch_id) REFERENCES vi_watch_base(id) ON DELETE CASCADE；FOREIGN KEY (thesis_id) REFERENCES vi_thesis_base(id) ON DELETE CASCADE；PRIMARY KEY (watch_id, thesis_id) |
