"""飞书「长江电力投资工作台」→ NocoBase 的结构映射（唯一事实来源）。

数据库约定（全部在 public schema，前缀 cj_）：
  cj_<code>_base   原始输入表（SQL 管理，存飞书非公式字段）
  cj_<code>_calc   计算视图（飞书公式的 SQL 等价，见 sql/03_calc.sql）
  cj_<code>        界面视图 = 输入列 + 计算列，INSTEAD OF 触发器把写入落到 _base；
                   在 NocoBase 中注册为可写视图集合
  cj_lnk_<code>_<field>  多对多关联表

字段类型：
  text 单行文本 / long 多行文本 / num 浮点数 / int 整数 / bool 布尔 / ts 日期时间 / select 单选
"""

# (飞书表ID, code, 标题, 菜单分组)
TABLES = [
    ('tblfkSvg3KLT4x6v', 'guide', '使用指南', '0 驾驶舱'),
    ('tblkh2v6DvcZCKDN', 'biz_model', '1.1 商业模式', '1 研究'),
    ('tbljWLIX3WodWrKS', 'evidence', '1.2 证据账本', '1 研究'),
    ('tblGjno4t3xbBI3a', 'fact_mapping', '1.3 事实→判断映射', '1 研究'),
    ('tbl2aFkmDryVrEX1', 'scenario', '2.1 情景参数', '2 估值'),
    ('tblAaz02mrF6O7x6', 'annual', '2.2 年度假设', '2 估值'),
    ('tbl5aXeR7rjoTkM9', 'fin_calc', '2.3 财务计算', '2 估值'),
    ('tblgD0RhP6O8CH3n', 'valuation', '2.4 估值结论', '2 估值'),
    ('tblx3jG7zLHuivuW', 'sens_rg', '2.5 敏感性：利率×增长', '2 估值'),
    ('tblvbIQ8tpRTIjsn', 'param_trial', '2.6 单参数试验', '2 估值'),
    ('tbl5uKYflr6IEUfl', 'tracking', '3.1 跟踪任务', '3 跟踪'),
    ('tblvFm47sB0tjy3D', 'market_obs', '3.2 市场数据', '3 跟踪'),
    ('tblwggKAaEP1xPy6', 'quality', '3.3 质量检查', '3 跟踪'),
    ('tblXIyszuOPrWGmz', 'change_log', '3.4 变更日志', '3 跟踪'),
    ('tblwkg1ATbxsvFIr', 'collect_ctl', '4.1 采集状态', '4 后台'),
    ('tblfGHpu05iEVJrp', 'collect_raw', '4.2 采集原始记录', '4 后台'),
    ('tblwC6gbfMfQjipH', 'v1_param', '参数字典', '5 归档'),
    ('tblpNOHUjyAlTtoi', 'v1_annual', '年度数据', '5 归档'),
    ('tbl8Sr9SYKiRXq6D', 'v1_quarterly', '季度跟踪', '5 归档'),
    ('tblsOXyELneyBvlj', 'v1_source', '信息源', '5 归档'),
    ('tblXrHMdKmzyJI8c', 'v1_announce', '公告事件', '5 归档'),
    ('tblrKriaOZpsWqae', 'v1_thesis', '论点与证伪', '5 归档'),
    ('tbl8I2E74xVim8qV', 'v1_valuation', '估值结果', '5 归档'),
    ('tbl3AWSnfetyBe6F', 'v1_forecast', '模型预测', '5 归档'),
    ('tblFheyeq50XA2Gt', 'v1_scenario', '情景分析', '5 归档'),
    ('tblGiyW4Ubkaix9w', 'v1_sens', '敏感性', '5 归档'),
]

# 输入字段：code -> [(飞书字段名, 英文名, 类型)]，顺序即界面列顺序
INPUTS = {
    'guide': [('主题', 'topic', 'text'), ('规则与操作', 'rules', 'long'), ('适用范围', 'scope', 'text')],
    'biz_model': [
        ('业务命题', 'proposition', 'text'), ('公司代码', 'company_code', 'text'),
        ('赚钱机制', 'earning_mechanism', 'long'), ('护城河证据要求', 'moat_evidence', 'long'),
        ('反方与边界', 'counter_view', 'long'), ('财务映射', 'financial_mapping', 'long'),
        ('当前判断', 'current_view', 'text'),
    ],
    'evidence': [
        ('证据ID', 'evidence_id', 'text'), ('公司代码', 'company_code', 'text'),
        ('报告期', 'report_period', 'text'), ('来源类型', 'source_type', 'text'),
        ('事实或原始记录', 'fact_text', 'long'), ('原始链接', 'source_link', 'long'),
        ('发布日期', 'published_date', 'text'), ('抓取日期', 'fetched_date', 'text'),
        ('核验状态', 'verify_status', 'text'), ('口径与局限', 'scope_limits', 'long'),
        ('旧记录定位', 'legacy_ref', 'text'),
    ],
    'fact_mapping': [
        ('映射ID', 'mapping_id', 'text'), ('事实层', 'fact_layer', 'text'),
        ('判断层', 'judgment', 'long'), ('数学传导', 'math_transmission', 'long'),
        ('参数键', 'param_key', 'text'), ('影响年份情景', 'affected_years', 'text'),
        ('修改门槛', 'change_threshold', 'long'), ('不改模型条件', 'no_change_condition', 'long'),
        ('反证或替代解释', 'counter_evidence', 'long'), ('判断状态', 'judgment_status', 'text'),
    ],
    'scenario': [
        ('情景', 'scenario', 'text'), ('公司代码', 'company_code', 'text'),
        ('电量系数', 'volume_factor', 'num'), ('电价系数', 'price_factor', 'num'),
        ('付现成本系数', 'cash_cost_factor', 'num'), ('折现率', 'discount_rate', 'num'),
        ('永续增长率', 'terminal_growth', 'num'), ('终值年份', 'terminal_year', 'int'),
        ('估值基年', 'valuation_base_year', 'int'), ('股本亿股', 'shares_yi', 'num'),
        ('基准电价元', 'base_price', 'num'), ('基准其他净贡献亿元', 'base_other_contrib', 'num'),
        ('基准综合负担率', 'base_burden_rate', 'num'), ('基准派息率', 'base_payout', 'num'),
        ('基准无风险利率pct', 'base_rf_pct', 'num'), ('基准风险溢价pct', 'base_erp_pct', 'num'),
        ('利率基准日期', 'rate_date', 'text'), ('旧股价', 'legacy_price', 'num'),
        ('价格日期', 'price_date', 'text'), ('假设性质', 'assumption_nature', 'text'),
        ('发布状态', 'publish_status', 'text'), ('情景解释', 'scenario_note', 'long'),
    ],
    'annual': [
        ('年度键', 'year_key', 'text'), ('公司代码', 'company_code', 'text'), ('年份', 'year', 'int'),
        ('电量亿千瓦时', 'volume', 'num'), ('电价元', 'price', 'num'),
        ('付现成本亿元', 'cash_cost', 'num'), ('折旧亿元', 'depreciation', 'num'),
        ('利息亿元', 'interest', 'num'), ('其他净贡献亿元', 'other_contrib', 'num'),
        ('综合负担率', 'burden_rate', 'num'), ('派息率', 'payout', 'num'),
        ('归属折旧加回亿元', 'attrib_da_addback', 'num'), ('非现金收益扣除亿元', 'noncash_gain_deduct', 'num'),
        ('投资现金分红亿元', 'invest_cash_dividend', 'num'), ('其他现金调整亿元', 'other_cash_adj', 'num'),
        ('营运资本增加亿元', 'wc_increase', 'num'), ('维持资本亿元', 'maint_capex', 'num'),
        ('扩张资本亿元', 'growth_capex', 'num'), ('净借款亿元', 'net_borrowing', 'num'),
        ('最低现金补充亿元', 'min_cash_topup', 'num'),
        ('现金桥接状态', 'cash_bridge_note', 'text'), ('证据状态', 'evidence_status', 'text'),
    ],
    'fin_calc': [('模型键', 'model_key', 'text'), ('情景名称', 'scenario_name', 'text'), ('年份', 'year', 'int')],
    'valuation': [('情景', 'scenario', 'text'), ('使用说明', 'usage_note', 'long')],
    'sens_rg': [('组合', 'combo', 'text'), ('利率偏移', 'rate_shift', 'num'), ('增长偏移', 'growth_shift', 'num')],
    'param_trial': [
        ('试验', 'trial', 'text'), ('开始年份', 'start_year', 'int'), ('结束年份', 'end_year', 'int'),
        ('电量变动率', 'volume_delta', 'num'), ('电价变动率', 'price_delta', 'num'),
        ('付现成本变动亿元', 'cash_cost_delta', 'num'), ('折旧变动亿元', 'da_delta', 'num'),
        ('利息变动亿元', 'interest_delta', 'num'), ('折现率变动', 'rate_delta', 'num'),
        ('事实与判断边界', 'boundary', 'long'),
    ],
    'tracking': [
        ('任务ID', 'task_id', 'text'), ('跟踪指标', 'metric', 'text'), ('观察指标代码', 'obs_code', 'text'),
        ('频率', 'frequency', 'text'), ('首选来源', 'preferred_source', 'long'),
        ('触发阈值', 'trigger_threshold', 'text'), ('阈值性质', 'threshold_nature', 'text'),
        ('触发后动作', 'action_after', 'long'), ('采集状态', 'collect_status', 'text'),
        ('最新观察', 'latest_obs_note', 'text'), ('观察日期', 'obs_date_note', 'text'),
    ],
    'market_obs': [
        ('观察ID', 'obs_id', 'text'), ('指标代码', 'metric_code', 'text'), ('指标', 'metric', 'text'),
        ('日期', 'obs_date', 'text'), ('数值', 'value', 'num'), ('云端数值原文', 'cloud_value_text', 'text'),
        ('单位', 'unit', 'text'), ('来源', 'source', 'long'), ('采集时间', 'collected_at', 'text'),
        ('原始文件', 'raw_file', 'long'), ('使用边界', 'usage_boundary', 'long'),
    ],
    'quality': [
        ('检查ID', 'check_id', 'text'), ('级别', 'level', 'text'), ('问题', 'issue', 'long'),
        ('影响范围', 'impact_scope', 'text'), ('完成条件', 'done_condition', 'long'), ('状态', 'status', 'text'),
    ],
    'change_log': [
        ('变更ID', 'change_id', 'text'), ('时间', 'time_text', 'text'), ('对象', 'target', 'text'),
        ('旧值', 'old_value', 'long'), ('新值', 'new_value', 'long'), ('原因', 'reason', 'long'),
        ('证据定位', 'evidence_ref', 'long'), ('验证状态', 'verify_status', 'long'),
    ],
    'collect_ctl': [
        ('指标代码', 'metric_code', 'text'), ('指标', 'metric', 'text'), ('接入状态', 'integration_status', 'text'),
        ('允许观察滞后天', 'max_lag_days', 'num'), ('来源说明', 'source_note', 'long'),
        ('工作流入口', 'workflow_entry', 'long'), ('最近自检', 'last_selfcheck', 'ts'), ('自检结果', 'selfcheck_result', 'text'),
    ],
    'collect_raw': [
        ('运行标识', 'run_id', 'text'), ('指标代码', 'metric_code', 'text'), ('来源网址', 'source_url', 'long'),
        ('单位', 'unit', 'text'), ('采集时间', 'collected_at', 'ts'), ('处理状态', 'process_status', 'text'),
        ('原始响应', 'raw_response', 'long'),
    ],
    'v1_param': [
        ('参数名称', 'param_name', 'text'), ('符号', 'symbol', 'text'), ('类别', 'category', 'select'),
        ('定义', 'definition', 'long'), ('单位', 'unit', 'text'), ('当前值', 'current_value', 'text'),
        ('模型角色', 'model_role', 'text'), ('参数关系', 'param_relation', 'long'),
        ('更新频率', 'update_freq', 'select'), ('数据来源', 'data_source', 'long'),
        ('来源说明', 'source_note', 'text'), ('映射理由', 'mapping_reason', 'long'),
        ('最后更新', 'last_updated', 'ts'), ('修订记录', 'revision_log', 'long'),
    ],
    'v1_annual': [
        ('年份', 'year', 'int'), ('发电量_亿千瓦时', 'generation', 'num'), ('综合电价_元', 'avg_price', 'num'),
        ('营业收入_亿', 'revenue', 'num'), ('归母净利_亿', 'net_profit', 'num'), ('折旧摊销_亿', 'da', 'num'),
        ('财务费用_亿', 'finance_cost', 'num'), ('投资收益_亿', 'invest_income', 'num'),
        ('经营现金流_亿', 'cfo', 'num'), ('资本开支_亿', 'capex', 'num'), ('带息负债_亿', 'interest_debt', 'num'),
        ('每股股息_元', 'dps', 'num'), ('股息总额_亿', 'dividend_total', 'num'),
        ('来源', 'source', 'long'), ('备注', 'note', 'long'),
    ],
    'v1_quarterly': [
        ('期间', 'period', 'text'), ('发电量_亿千瓦时', 'generation', 'num'), ('同比_pct', 'yoy_pct', 'num'),
        ('来水评价', 'inflow_eval', 'select'), ('摘要', 'summary', 'long'), ('公告链接', 'announcement_link', 'long'),
        ('处理状态', 'status', 'select'),
    ],
    'v1_source': [
        ('来源名称', 'name', 'text'), ('类型', 'source_type', 'select'), ('权威性', 'authority', 'select'),
        ('链接', 'link', 'long'), ('更新频率', 'update_freq', 'text'), ('使用说明', 'usage_note', 'long'),
    ],
    'v1_announce': [
        ('日期', 'date', 'ts'), ('标题', 'title', 'text'), ('类型', 'ann_type', 'select'),
        ('摘要', 'summary', 'long'), ('链接', 'link', 'long'), ('处理状态', 'status', 'select'),
    ],
    'v1_thesis': [
        ('论点', 'thesis', 'text'), ('分类', 'category', 'select'), ('证据', 'evidence', 'long'),
        ('证伪条件', 'falsification', 'long'), ('状态', 'status', 'select'),
    ],
    'v1_valuation': [
        ('情景', 'scenario', 'text'), ('当前股价_元', 'price', 'num'), ('价格日期', 'price_date', 'ts'),
        ('十年期国债收益率', 'cgb10y', 'num'), ('风险溢价', 'erp', 'num'), ('折现率r', 'r_pct', 'num'),
        ('永续增长g', 'g_pct', 'num'), ('总股本_亿股', 'shares_yi', 'num'), ('安全边际_pct', 'margin_pct', 'num'),
        ('FCFE每股_元', 'fcfe_ps', 'num'),
    ],
    'v1_forecast': [
        ('年份', 'year', 'int'), ('发电量_亿千瓦时', 'generation', 'num'), ('综合电价_元', 'avg_price', 'num'),
        ('付现成本_亿', 'cash_cost', 'num'), ('折旧_亿', 'depreciation', 'num'), ('财务费用_亿', 'finance_cost', 'num'),
        ('其他净贡献_亿', 'other_contrib', 'num'), ('综合负担率_pct', 'burden_pct', 'num'),
        ('派息率_pct', 'payout_pct', 'num'), ('备注', 'note', 'long'),
    ],
    'v1_scenario': [
        ('情景', 'scenario', 'text'), ('基期每股股息_元', 'base_dps', 'num'), ('十年股息增速g1_pct', 'g1_pct', 'num'),
        ('折现率r_pct', 'r_pct', 'num'), ('永续增长g_pct', 'g_pct', 'num'), ('假设说明', 'note', 'long'),
    ],
    'v1_sens': [
        ('组合', 'combo', 'text'), ('r_pct', 'r_pct', 'num'), ('g1_pct', 'g1_pct', 'num'), ('g_pct', 'g_pct', 'num'),
        ('基期股息_元', 'base_dps', 'num'), ('备注', 'note', 'long'),
    ],
}

# 关联字段：(所在表code, 飞书字段名, 英文名, 目标code, 类型, 反向(飞书字段名, 英文名) 或 None)
# m2o 外键列名为 <英文名>_id；m2m 关联表为 cj_lnk_<code>_<英文名>(src_id, dst_id)
LINKS = [
    ('evidence', '情景假设', 'scenarios', 'scenario', 'm2m', ('来源证据', 'evidences')),
    ('fact_mapping', '业务论点', 'biz_models', 'biz_model', 'm2m', None),
    ('fact_mapping', '证据', 'evidences', 'evidence', 'm2m', None),
    ('annual', '证据', 'evidences', 'evidence', 'm2m', None),
    ('annual', '映射', 'mappings', 'fact_mapping', 'm2m', None),
    ('fin_calc', '年度输入', 'annual_input', 'annual', 'm2o', None),
    ('fin_calc', '情景输入', 'scenario_input', 'scenario', 'm2o', None),
    ('valuation', '预测行', 'forecast_rows', 'fin_calc', 'm2m', None),
    ('valuation', '情景输入', 'scenario_input', 'scenario', 'm2o', None),
    ('sens_rg', '基准情景', 'base_scenario', 'scenario', 'm2o', None),
    ('param_trial', '基准情景', 'base_scenario', 'scenario', 'm2o', None),
    ('param_trial', '映射', 'mappings', 'fact_mapping', 'm2m', None),
    ('tracking', '映射', 'mappings', 'fact_mapping', 'm2m', None),
    ('v1_source', '覆盖参数', 'params', 'v1_param', 'm2m', None),
    ('v1_announce', '影响参数', 'params', 'v1_param', 'm2m', None),
    ('v1_thesis', '支撑参数', 'params', 'v1_param', 'm2m', None),
]

# 计算字段：code -> [(飞书公式字段名, 英文名, 类型)]；SQL 实现见 sql/03_calc.sql
CALC = {
    'scenario': [
        ('计算基准折现率', 'calc_base_discount_rate', 'num'), ('有效折现率', 'eff_discount_rate', 'num'),
        ('有效终值年份', 'eff_terminal_year', 'int'), ('有效估值基年', 'eff_base_year', 'int'),
        ('有效股本亿股', 'eff_shares_yi', 'num'), ('有效旧股价', 'eff_legacy_price', 'num'),
        ('最近股价元', 'latest_price', 'num'), ('最近股价日期', 'latest_price_date', 'text'),
    ],
    'annual': [
        ('有效电价元', 'eff_price', 'num'), ('有效其他净贡献亿元', 'eff_other_contrib', 'num'),
        ('有效综合负担率', 'eff_burden_rate', 'num'), ('有效派息率', 'eff_payout', 'num'),
        ('现金桥接实时状态', 'cash_bridge_live_status', 'text'),
    ],
    'fin_calc': [
        ('电量亿千瓦时', 'volume', 'num'), ('电量系数', 'volume_factor', 'num'), ('电价元', 'price', 'num'),
        ('电价系数', 'price_factor', 'num'), ('收入亿元', 'revenue', 'num'), ('付现成本亿元', 'cash_cost', 'num'),
        ('付现成本系数', 'cash_cost_factor', 'num'), ('折旧亿元', 'depreciation', 'num'), ('利息亿元', 'interest', 'num'),
        ('其他净贡献亿元', 'other_contrib', 'num'), ('税前利润亿元', 'pretax_profit', 'num'),
        ('综合负担率', 'burden_rate', 'num'), ('归母利润代理亿元', 'np_proxy', 'num'), ('派息率', 'payout', 'num'),
        ('计划股息亿元', 'planned_div', 'num'), ('折现率', 'discount_rate', 'num'), ('估值基年', 'base_year', 'int'),
        ('折现因子', 'discount_factor', 'num'), ('计划股息现值亿元', 'planned_div_pv', 'num'),
        ('终值年份', 'terminal_year', 'int'), ('永续增长率', 'terminal_growth', 'num'), ('股本亿股', 'shares_yi', 'num'),
        ('归属折旧加回亿元', 'attrib_da_addback', 'num'), ('非现金收益扣除亿元', 'noncash_gain_deduct', 'num'),
        ('投资现金分红亿元', 'invest_cash_dividend', 'num'), ('其他现金调整亿元', 'other_cash_adj', 'num'),
        ('营运资本增加亿元', 'wc_increase', 'num'), ('维持资本亿元', 'maint_capex', 'num'),
        ('扩张资本亿元', 'growth_capex', 'num'), ('净借款亿元', 'net_borrowing', 'num'),
        ('最低现金补充亿元', 'min_cash_topup', 'num'), ('现金数据完整', 'cash_data_complete', 'bool'),
        ('所有者收益亿元', 'owner_earnings', 'num'), ('FCFE亿元', 'fcfe', 'num'), ('FCFE现值亿元', 'fcfe_pv', 'num'),
        ('现金支持分红亿元', 'cash_supported_div', 'num'), ('现金支持股息现值亿元', 'cash_div_pv', 'num'),
        ('资金缺口亿元', 'funding_gap', 'num'), ('计算状态', 'calc_status', 'text'),
    ],
    'valuation': [
        ('条件DDM元', 'cond_ddm', 'num'), ('现金支持DDM元', 'cash_ddm', 'num'), ('模型勾稽', 'model_check', 'text'),
        ('市场观察价元', 'market_price', 'num'), ('市场观察日期', 'market_date', 'text'), ('旧股价', 'legacy_price', 'num'),
        ('旧价安全边际', 'legacy_margin', 'num'), ('关注价10元', 'watch_price_10', 'num'), ('关注价30元', 'watch_price_30', 'num'),
        ('预测期现值亿元', 'forecast_pv', 'num'), ('终年股息亿元', 'terminal_div', 'num'), ('终值现值亿元', 'terminal_pv', 'num'),
        ('终值占比', 'terminal_share', 'num'), ('折现率', 'discount_rate', 'num'), ('永续增长率', 'terminal_growth', 'num'),
        ('估值基年', 'base_year', 'int'), ('终值年份', 'terminal_year', 'int'), ('股本亿股', 'shares_yi', 'num'),
        ('关联预测行数', 'linked_rows', 'int'), ('同名模型行数', 'same_name_rows', 'int'), ('终年模型行数', 'terminal_rows', 'int'),
        ('预测期勾稽差额亿元', 'recon_diff', 'num'), ('现金完整年数', 'cash_complete_years', 'int'),
        ('终年现金股息', 'terminal_cash_div', 'num'), ('决策状态', 'decision_status', 'text'),
    ],
    'sens_rg': [
        ('折现率', 'discount_rate', 'num'), ('永续增长率', 'terminal_growth', 'num'), ('条件DDM元', 'cond_ddm', 'num'),
        ('预测期现值亿元', 'forecast_pv', 'num'), ('终年股息亿元', 'terminal_div', 'num'), ('股本亿股', 'shares_yi', 'num'),
        ('估值基年', 'base_year', 'int'), ('终值年份', 'terminal_year', 'int'), ('性质', 'nature', 'text'),
    ],
    'param_trial': [
        ('试验价值元', 'trial_value', 'num'), ('基准价值元', 'base_value', 'num'), ('每股价值变化元', 'value_change', 'num'),
        ('变动比例', 'change_pct', 'num'), ('试验折现率', 'trial_rate', 'num'), ('永续增长率', 'terminal_growth', 'num'),
        ('股本亿股', 'shares_yi', 'num'), ('估值基年', 'base_year', 'int'), ('终值年份', 'terminal_year', 'int'),
    ] + [(f'试验股息{y}', f'trial_div_{y}', 'num') for y in range(2026, 2036)],
    'tracking': [
        ('最新有效观察值', 'latest_value', 'num'), ('最新有效观察单位', 'latest_unit', 'text'),
        ('最新有效观察日', 'latest_date', 'text'), ('最新有效观察指标', 'latest_metric', 'text'),
        ('观察联动状态', 'link_status', 'text'),
    ],
    'market_obs': [
        ('统一数值', 'unified_value', 'num'), ('质量有效', 'quality_ok', 'int'), ('当前版本', 'is_current', 'bool'),
        ('当前有效数', 'current_valid_count', 'int'), ('原始采集条数', 'raw_count', 'int'), ('来源勾稽', 'source_check', 'text'),
    ],
    'quality': [
        ('实时勾稽状态', 'live_status', 'text'), ('现金桥接检查', 'cash_bridge_check', 'text'),
        ('价格日期检查', 'price_date_check', 'text'), ('模型行检查', 'model_row_check', 'text'),
        ('负值观察检查', 'negative_obs_check', 'text'),
    ],
    'collect_ctl': [
        ('健康状态', 'health_status', 'text'), ('异常需通知', 'needs_alert', 'int'), ('通知条件', 'notify_condition', 'text'),
        ('最近采集', 'latest_collected_at', 'ts'), ('最近观察日', 'latest_obs_date', 'text'),
        ('最近运行结果', 'latest_run_result', 'text'),
    ],
    'collect_raw': [
        ('原始ID', 'raw_id', 'text'), ('采集时间文本', 'collected_at_text', 'text'),
        ('日期V2', 'date_v2', 'text'), ('数值V2', 'value_v2', 'text'), ('观察键V2', 'obs_key_v2', 'text'),
        ('校验V2', 'valid_v2', 'int'), ('已有观察数', 'existing_obs_count', 'int'), ('允许入库', 'allow_ingest', 'int'),
        ('入库指令', 'ingest_cmd', 'text'), ('运行结果', 'run_result', 'text'),
        ('响应去转义', 'response_unescaped', 'long'), ('国债数据行', 'cgb_data_row', 'long'),
        ('三峡数据对象', 'sx_obj', 'text'),
        ('日期候选', 'date_candidate', 'text'), ('观测日期', 'obs_date_v1', 'text'), ('数值候选', 'value_candidate', 'num'),
    ],
    'v1_annual': [('派息率_pct', 'payout_pct', 'num'), ('折旧加财务费用_亿', 'da_plus_finance', 'num')],
    'v1_valuation': [
        ('每股内在价值_元', 'value_ps', 'num'), ('信号', 'signal', 'text'), ('折溢价_pct', 'premium_pct', 'num'),
        ('买入阈值_元', 'buy_threshold', 'num'), ('股权内在价值_亿', 'equity_value', 'num'),
        ('预测期现值合计_亿', 'forecast_pv', 'num'), ('末期股息_亿', 'terminal_div', 'num'), ('终值_亿', 'terminal_value', 'num'),
        ('终值现值_亿', 'terminal_pv', 'num'), ('FCFE永续价值_元', 'fcfe_perp_value', 'num'),
    ],
    'v1_forecast': [
        ('营业收入_亿', 'revenue', 'num'), ('税前利润_亿', 'pretax_profit', 'num'), ('归母净利_亿', 'net_profit', 'num'),
        ('股息总额_亿', 'dividend_total', 'num'), ('每股股息_元', 'dps', 'num'), ('折现因子', 'discount_factor', 'num'),
        ('股息现值_亿', 'div_pv', 'num'),
    ],
    'v1_scenario': [('每股内在价值_元', 'value_ps', 'num')],
    'v1_sens': [('每股价值_元', 'value_ps', 'num')],
}

# 不迁移的飞书公式：V1 解析路径的残留列。飞书里它们恒为空或 0（正则在飞书引擎下未命中），
# 所有工作流只用 V2 列（日期V2/数值V2/观察键V2/校验V2）。日期候选/观测日期/数值候选仍保留，因为腾讯股价的 V2 日期依赖它们。
DROPPED_CALC = {'collect_raw': ['水库对象', '国债行', '日期有效', '校验通过', '观察键']}

# 标题字段（关联下拉显示用）
TITLE_FIELD = {
    'guide': 'topic', 'biz_model': 'proposition', 'evidence': 'evidence_id', 'fact_mapping': 'mapping_id',
    'scenario': 'scenario', 'annual': 'year_key', 'fin_calc': 'model_key', 'valuation': 'scenario',
    'sens_rg': 'combo', 'param_trial': 'trial', 'tracking': 'task_id', 'market_obs': 'obs_id',
    'quality': 'check_id', 'change_log': 'change_id', 'collect_ctl': 'metric_code', 'collect_raw': 'run_id',
    'v1_param': 'param_name', 'v1_annual': 'year', 'v1_quarterly': 'period', 'v1_source': 'name',
    'v1_announce': 'title', 'v1_thesis': 'thesis', 'v1_valuation': 'scenario', 'v1_forecast': 'year',
    'v1_scenario': 'scenario', 'v1_sens': 'combo',
}

PG_TYPE = {'text': 'text', 'long': 'text', 'num': 'double precision', 'int': 'bigint',
           'bool': 'boolean', 'ts': 'timestamptz', 'select': 'text'}
NB_INTERFACE = {'text': 'input', 'long': 'textarea', 'num': 'number', 'int': 'integer',
                'bool': 'checkbox', 'ts': 'datetime', 'select': 'select'}


def table_by_code():
    return {code: (tid, title, group) for tid, code, title, group in TABLES}
