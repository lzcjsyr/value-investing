-- 自动生成：framework/migrate_data_layer.py（数据底稿重构）。执行前先删 NocoBase 里的跟踪事项页面与集合，执行后重跑 02、03。
BEGIN;
-- 1. 关注＝假设依据、风险关联指标
CREATE TABLE vi_lnk_judgment_metrics (
  judgment_id bigint NOT NULL REFERENCES vi_judgment_base(id) ON DELETE CASCADE,
  metric_id bigint NOT NULL REFERENCES vi_metric_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (judgment_id, metric_id)
);
COMMENT ON TABLE vi_lnk_judgment_metrics IS '假设依据 ↔ 跟踪指标（多对多）';
CREATE TABLE vi_lnk_risk_metrics (
  risk_id bigint NOT NULL REFERENCES vi_risk_base(id) ON DELETE CASCADE,
  metric_id bigint NOT NULL REFERENCES vi_metric_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (risk_id, metric_id)
);
COMMENT ON TABLE vi_lnk_risk_metrics IS '风险分析 ↔ 预警指标（多对多）';
-- 2. 新建指标（跟踪事项里有、数据里还没有的单一数字）
INSERT INTO vi_metric_base (code, name, unit, category, source_kind, basis, company_id, source_name, frequency)
SELECT '600900.SH' || '.D' || lpad((coalesce(max(substring(code FROM '\.D(\d+)$')::int), 0) + 1)::text, 3, '0'),
       '实现售电价', '元/千瓦时', '经营', '公司披露', '半年累计', 1, 'https://www.cypc.com.cn（半年报、年报）', '半年'
FROM vi_metric_base WHERE code LIKE '600900.SH.D%';
-- 3. 跟踪事项逐条去向
INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id) VALUES (1, 97) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_risk_metrics (risk_id, metric_id) VALUES (8, 97) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id) VALUES (1, 4) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_risk_metrics (risk_id, metric_id) VALUES (8, 4) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id) VALUES (2, (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '实现售电价')) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_risk_metrics (risk_id, metric_id) VALUES (9, (SELECT id FROM vi_metric_base WHERE company_id = 1 AND name = '实现售电价')) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id) VALUES (7, 2) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_risk_metrics (risk_id, metric_id) VALUES (11, 2) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id) VALUES (7, 1) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id) VALUES (706, 8) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id) VALUES (700, 10) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_risk_metrics (risk_id, metric_id) VALUES (15, 10) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id) VALUES (700, 101) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id) VALUES (699, 101) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_risk_metrics (risk_id, metric_id) VALUES (15, 101) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id) VALUES (749, 23) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id) VALUES (739, 190) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_risk_metrics (risk_id, metric_id) VALUES (19, 190) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id) VALUES (739, 193) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id) VALUES (740, 103) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id) VALUES (739, 103) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_risk_metrics (risk_id, metric_id) VALUES (19, 103) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id) VALUES (740, 192) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_risk_metrics (risk_id, metric_id) VALUES (19, 192) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id) VALUES (741, 189) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id) VALUES (742, 194) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id) VALUES (741, 194) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_risk_metrics (risk_id, metric_id) VALUES (21, 194) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id) VALUES (741, 191) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_risk_metrics (risk_id, metric_id) VALUES (21, 191) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id) VALUES (742, 184) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_risk_metrics (risk_id, metric_id) VALUES (21, 184) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id) VALUES (745, 185) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_risk_metrics (risk_id, metric_id) VALUES (20, 185) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id) VALUES (742, 186) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id) VALUES (745, 186) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_risk_metrics (risk_id, metric_id) VALUES (20, 186) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id) VALUES (746, 187) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id) VALUES (742, 187) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_risk_metrics (risk_id, metric_id) VALUES (34, 187) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id) VALUES (742, 196) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id) VALUES (745, 196) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_risk_metrics (risk_id, metric_id) VALUES (20, 196) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_risk_metrics (risk_id, metric_id) VALUES (34, 196) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id) VALUES (747, 188) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_risk_metrics (risk_id, metric_id) VALUES (22, 188) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id) VALUES (748, 195) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_risk_metrics (risk_id, metric_id) VALUES (22, 195) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id) VALUES (584, 28) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id) VALUES (574, 120) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id) VALUES (573, 120) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_risk_metrics (risk_id, metric_id) VALUES (23, 120) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id) VALUES (573, 133) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_risk_metrics (risk_id, metric_id) VALUES (23, 133) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id) VALUES (575, 123) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_risk_metrics (risk_id, metric_id) VALUES (24, 123) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id) VALUES (582, 132) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id) VALUES (581, 132) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_risk_metrics (risk_id, metric_id) VALUES (25, 132) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id) VALUES (582, 130) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id) VALUES (580, 130) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_risk_metrics (risk_id, metric_id) VALUES (25, 130) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id) VALUES (582, 131) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id) VALUES (580, 131) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_risk_metrics (risk_id, metric_id) VALUES (25, 131) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id) VALUES (573, 126) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_risk_metrics (risk_id, metric_id) VALUES (23, 126) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id) VALUES (586, 29) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_risk_metrics (risk_id, metric_id) VALUES (27, 29) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id) VALUES (763, 48) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id) VALUES (755, 48) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id) VALUES (770, 48) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id) VALUES (760, 142) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id) VALUES (756, 142) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id) VALUES (760, 148) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id) VALUES (756, 148) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id) VALUES (760, 145) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id) VALUES (756, 145) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id) VALUES (757, 143) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id) VALUES (759, 143) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id) VALUES (757, 170) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id) VALUES (759, 170) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id) VALUES (761, 149) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id) VALUES (763, 151) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id) VALUES (762, 151) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id) VALUES (768, 139) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id) VALUES (758, 139) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id) VALUES (768, 156) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id) VALUES (758, 156) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id) VALUES (771, 159) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id) VALUES (766, 159) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id) VALUES (764, 157) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id) VALUES (765, 157) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id) VALUES (764, 158) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id) VALUES (765, 158) ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_judgment_metrics (judgment_id, metric_id) VALUES (773, 29) ON CONFLICT DO NOTHING;
-- 3b. 正文里的跟踪事项编号换成名称（先于下面的追加，守卫条件读的是原文）
UPDATE vi_thesis_base SET mind_changer = '改判为成立：2026 年减值低于 230 亿元，且 2027 年继续回落。改判为存疑：2026 年减值超过 258.7 亿元，或单年地产存货减值超过 50 亿元，或地产业务毛利率低于 12%。不设自动检查（历史财务没有减值字段），看重点跟踪的资产及信用减值损失（累计同比）和地产业务毛利率。' WHERE id = 434 AND mind_changer = '改判为成立：2026 年减值低于 230 亿元，且 2027 年继续回落。改判为存疑：2026 年减值超过 258.7 亿元，或单年地产存货减值超过 50 亿元，或地产业务毛利率低于 12%。不设自动检查（历史财务没有减值字段），看跟踪事项 W9（减值累计同比）、W7（地产业务毛利率）。';
UPDATE vi_risk_base SET early_warning = '分红政策（2027—2029 年规划）：新规划下限仍为 20% 且实际派息率不升
股权激励考核完成情况：2026 年扣非归母净利低于 35.11 亿元
关联交易：关联销售占比明显上升或定价偏离市价' WHERE id = 18 AND early_warning = 'W7 分红政策（2027—2029 年规划）：新规划下限仍为 20% 且实际派息率不升
W8 股权激励考核完成情况：2026 年扣非归母净利低于 35.11 亿元
W9 关联交易：关联销售占比明显上升或定价偏离市价';
UPDATE vi_risk_base SET early_warning = '资本开支与净负债：资本开支连续两年超过 60 亿元，或带息负债超过 230 亿元
老挝新项目与林地：老挝新浆线立项（最早 2027H2）' WHERE id = 17 AND early_warning = 'W6 资本开支与净负债：资本开支连续两年超过 60 亿元，或带息负债超过 230 亿元
W10 老挝新项目与林地：老挝新浆线立项（最早 2027H2）';
UPDATE vi_risk_base SET early_warning = '经营现金流·滚动四季度：滚动四季度经营现金流低于 2025 年的 205 亿元。
应收账款＋合同资产·期末同比：期末同比高于 15%（同期收入在下降）。
清收政府逾期债权·半年：半年清收不足 500 亿元：化债明显退坡。' WHERE id = 20 AND early_warning = 'W10 经营现金流·滚动四季度：滚动四季度经营现金流低于 2025 年的 205 亿元。
W11 应收账款＋合同资产·期末同比：期末同比高于 15%（同期收入在下降）。
W13 清收政府逾期债权·半年：半年清收不足 500 亿元：化债明显退坡。';
UPDATE vi_risk_base SET early_warning = '回购执行与新回购计划：新一轮回购计划公布（规模、期限）；或回购明显放缓而股价低于 9 美元
现金、借款与美元票据：净现金低于 150 亿元，或带息负债超过 250 亿元' WHERE id = 25 AND early_warning = 'W5 回购执行与新回购计划：新一轮回购计划公布（规模、期限）；或回购明显放缓而股价低于 9 美元
W7 现金、借款与美元票据：净现金低于 150 亿元，或带息负债超过 250 亿元';
UPDATE vi_risk_base SET early_warning = '喜马拉雅收入与利润贡献：整合后收入下降或出现商誉减值' WHERE id = 26 AND early_warning = 'W6 喜马拉雅收入与利润贡献：整合后收入下降或出现商誉减值';
UPDATE vi_risk_base SET early_warning = '会员服务收入同比（剔除喜马拉雅）：连续两个季度同比为负
汽水音乐、番茄音乐月活与付费：汽水月活超过 2.5 亿或推出更低价会员
年末付费用户总数：2026 年末低于 1.22 亿（−4%）' WHERE id = 23 AND early_warning = 'W2 会员服务收入同比（剔除喜马拉雅）：连续两个季度同比为负
W3 汽水音乐、番茄音乐月活与付费：汽水月活超过 2.5 亿或推出更低价会员
W8 年末付费用户总数：2026 年末低于 1.22 亿（−4%）';
UPDATE vi_risk_base SET early_warning = '汽车月度交付与订单：四季度月均低于 5 万辆；2027 年全年低于 55 万辆或高于 70 万辆
汽车及 AI 分部经营损益与 AI 投入口径：AI 投入规划调整；分部亏损扩大到单季 40 亿元以上' WHERE id = 29 AND early_warning = 'W5 汽车月度交付与订单：四季度月均低于 5 万辆；2027 年全年低于 55 万辆或高于 70 万辆
W6 汽车及 AI 分部经营损益与 AI 投入口径：AI 投入规划调整；分部亏损扩大到单季 40 亿元以上';
UPDATE vi_risk_base SET early_warning = '存储合约价（DRAM、NAND）：合约价连续两个月环比下跌，或 2027 年仍在上涨
手机毛利率、ASP 与出货：手机毛利率低于 7% 或高于 11%；出货同比连续两季低于 −20%' WHERE id = 28 AND early_warning = 'W2 存储合约价（DRAM、NAND）：合约价连续两个月环比下跌，或 2027 年仍在上涨
W3 手机毛利率、ASP 与出货：手机毛利率低于 7% 或高于 11%；出货同比连续两季低于 −20%';
UPDATE vi_risk_base SET early_warning = '汽车及 AI 分部经营损益与 AI 投入口径：AI 投入规划调整；分部亏损扩大到单季 40 亿元以上
AI 商业化与可比公司估值：AI 收入年化超过 50 亿元且毛利为正；或可比公司估值中枢变化超过 50%' WHERE id = 30 AND early_warning = 'W6 汽车及 AI 分部经营损益与 AI 投入口径：AI 投入规划调整；分部亏损扩大到单季 40 亿元以上
W11 AI 商业化与可比公司估值：AI 收入年化超过 50 亿元且毛利为正；或可比公司估值中枢变化超过 50%';
UPDATE vi_risk_base SET early_warning = '纸浆价格：较 2026-10 水平（约 4700 元/吨）变动超过 ±15% 且持续一个月
季度毛利率与分产品吨利：综合毛利率连续两季低于 13%，或箱板纸毛利率低于 13%
箱板纸、文化纸价格与提价落地：旺季提价未落地、价格反跌' WHERE id = 15 AND early_warning = 'W2 纸浆价格：较 2026-10 水平（约 4700 元/吨）变动超过 ±15% 且持续一个月
W3 季度毛利率与分产品吨利：综合毛利率连续两季低于 13%，或箱板纸毛利率低于 13%
W4 箱板纸、文化纸价格与提价落地：旺季提价未落地、价格反跌';
UPDATE vi_risk_base SET early_warning = '新产能爬坡与南宁项目进度：PM47 未在 2026 年四季度满产；南宁项目延期超过两个季度
老挝新项目与林地：老挝新浆线立项（最早 2027H2）' WHERE id = 16 AND early_warning = 'W5 新产能爬坡与南宁项目进度：PM47 未在 2026 年四季度满产；南宁项目延期超过两个季度
W10 老挝新项目与林地：老挝新浆线立项（最早 2027H2）';
UPDATE vi_risk_base SET early_warning = '毛利率：单季毛利率低于 42%
AI 音乐与版权政策：AI 翻唱或生成音乐的版权规则落地' WHERE id = 24 AND early_warning = 'W4 毛利率：单季毛利率低于 42%
W9 AI 音乐与版权政策：AI 翻唱或生成音乐的版权规则落地';
UPDATE vi_risk_base SET early_warning = '港元兑人民币：一个月内变动超过 3%
对外持股市值（Spotify、UMG）：金融资产较上季变动超过 20%' WHERE id = 27 AND early_warning = 'W10 港元兑人民币：一个月内变动超过 3%
W11 对外持股市值（Spotify、UMG）：金融资产较上季变动超过 20%';
UPDATE vi_risk_base SET early_warning = 'IoT 毛利率与生态营业费用率：IoT 毛利率（含其他相关业务）连续两季低于 18%；或生态营业费用率连续四个季度高于 15.5% 或低于 12.5%
互联网服务收入与月活：互联网收入连续两季同比下降，或月活增速低于 2%' WHERE id = 31 AND early_warning = 'W4 IoT 毛利率与生态营业费用率：IoT 毛利率（含其他相关业务）连续两季低于 18%；或生态营业费用率连续四个季度高于 15.5% 或低于 12.5%
W7 互联网服务收入与月活：互联网收入连续两季同比下降，或月活增速低于 2%';
UPDATE vi_risk_base SET early_warning = '回购执行与股本：回购暂停，或股权激励发股超过回购
现金储备、借款、投资者负债：现金储备低于 2,000 亿元或借款超过 500 亿元
印度诉讼：判决或和解' WHERE id = 32 AND early_warning = 'W8 回购执行与股本：回购暂停，或股权激励发股超过回购
W9 现金储备、借款、投资者负债：现金储备低于 2,000 亿元或借款超过 500 亿元
W12 印度诉讼：判决或和解';
UPDATE vi_risk_base SET early_warning = 'PPP 相关长期资产·期末同比：期末同比高于 0：不降反升，说明回收慢于投入。
清收政府逾期债权·半年：半年清收不足 500 亿元：化债明显退坡。' WHERE id = 34 AND early_warning = 'W12 PPP 相关长期资产·期末同比：期末同比高于 0：不降反升，说明回收慢于投入。
W13 清收政府逾期债权·半年：半年清收不足 500 亿元：化债明显退坡。';
UPDATE vi_risk_base SET early_warning = '新签合同总额·年初累计同比：累计同比低于 −5%（连续三个月低于 −5% 时复核 J-Q）。
营业收入·单季同比：单季同比低于 −12%：比基准差 2 个百分点以上。2027 年仍低于 −5% 时 T2 改判存疑。
房屋建筑新开工面积·年初累计同比：累计同比低于 −20%：领先指标继续恶化。' WHERE id = 19 AND early_warning = 'W2 新签合同总额·年初累计同比：累计同比低于 −5%（连续三个月低于 −5% 时复核 J-Q）。
W4 营业收入·单季同比：单季同比低于 −12%：比基准差 2 个百分点以上。2027 年仍低于 −5% 时 T2 改判存疑。
W5 房屋建筑新开工面积·年初累计同比：累计同比低于 −20%：领先指标继续恶化。';
UPDATE vi_risk_base SET early_warning = '每股现金分红·年度：每股股息低于 0.2718 元。出台新的股东回报规划或回购时也复核（写进这条的数据解读）。
带息负债·期末：带息负债超过 1 万亿元。' WHERE id = 22 AND early_warning = 'W15 每股现金分红·年度：每股股息低于 0.2718 元。出台新的股东回报规划或回购时也复核（写进这条的数据解读）。
W14 带息负债·期末：带息负债超过 1 万亿元。';
UPDATE vi_risk_base SET early_warning = '资产及信用减值损失·年初累计同比：累计同比高于 0：减值比去年同期多，全年“不超过去年”有落空风险。
地产业务毛利率·半年：地产业务毛利率低于 12%。
地产合约销售额·年初累计同比：累计同比低于 −15%。' WHERE id = 21 AND early_warning = 'W9 资产及信用减值损失·年初累计同比：累计同比高于 0：减值比去年同期多，全年“不超过去年”有落空风险。
W7 地产业务毛利率·半年：地产业务毛利率低于 12%。
W8 地产合约销售额·年初累计同比：累计同比低于 −15%。';
UPDATE vi_risk_base SET response = '触发后复核相关论点和假设依据，再决定是否调整模型。原论点改判条件：改判为成立：2026 年减值低于 230 亿元，且 2027 年继续回落。改判为存疑：2026 年减值超过 258.7 亿元，或单年地产存货减值超过 50 亿元，或地产业务毛利率低于 12%。不设自动检查（历史财务没有减值字段），看重点跟踪的资产及信用减值损失（累计同比）和地产业务毛利率。' WHERE id = 21 AND response = '触发后复核相关论点和假设依据，再决定是否调整模型。原论点改判条件：改判为成立：2026 年减值低于 230 亿元，且 2027 年继续回落。改判为存疑：2026 年减值超过 258.7 亿元，或单年地产存货减值超过 50 亿元，或地产业务毛利率低于 12%。不设自动检查（历史财务没有减值字段），看跟踪事项 W9（减值累计同比）、W7（地产业务毛利率）。';
UPDATE vi_metric_base SET notes = '股价只进入对比层，不进入经营假设。2026-07-16 除息 0.2718 元，不复权序列在这一天有一个跳空。
跟踪用途：估值只用一个逻辑：按市价买入的隐含年化回报 vs 门槛 6%。基准情景下 7.16 元对应隐含回报 6%（门槛），3.96 元对应 10%（姜诚要求的两位数）。模型更新后重算这两条线' WHERE id = 23;
UPDATE vi_metric_base SET notes = '跟踪用途：看同比；订单是收入的源头。J-Q 假设 2026—2028 年新签与 2025 年持平（同比 0）；份额提升（T1）应让公司新签好于全国；验证论点：T1、T2' WHERE id = 190;
UPDATE vi_metric_base SET notes = '跟踪用途：T1 的核心证据：寒冬里集中度提升。2024 年约 12.2%、2025 年约 13.2%；份额每年提高约 1 个百分点，才能抵消行业每年约 5% 的下滑（T2）；验证论点：T1、T2、T9' WHERE id = 193;
UPDATE vi_metric_base SET notes = '跟踪用途：看同比；T2 的直接验证。J-P 假设 2026 年收入 −9.7%（上半年 −12%、下半年约 −8%），2027 年再降约 2% 后见底；验证论点：T2' WHERE id = 103;
UPDATE vi_metric_base SET notes = '跟踪用途：看同比；收入的领先指标：新开工领先收入 1—2 年。2026 年 1—9 月 −18.1%，降幅不收窄则 2027 年收入见底的假设偏乐观；验证论点：T2' WHERE id = 192;
UPDATE vi_metric_base SET notes = '跟踪用途：T3：施工毛利率在升、地产在降，综合约 10%。J-M 的核心利润率以此为基础；T3 的自动检查是年度毛利率连续两年低于 9%；验证论点：T3、T9' WHERE id = 189;
UPDATE vi_metric_base SET notes = '跟踪用途：T3 的红线：地产收入约占 15%、利润约占三分之一；毛利率跌到 12% 以下，综合毛利率约降 0.3pt，减值压力也会上升（T8）；验证论点：T3、T8' WHERE id = 194;
UPDATE vi_metric_base SET notes = '跟踪用途：看同比；地产结转的源头；销售面积已 −30%，2028 年后结转规模会下降（T3 反方）；验证论点：T3、T8' WHERE id = 191;
UPDATE vi_metric_base SET notes = '跟踪用途：看同比；T8：减值 2026 年见顶。管理层说全年不超过 2025 年（258.7 亿元）；J-IMP 按 2026 年约 235 亿元（同比约 −9%）；验证论点：T8' WHERE id = 184;
UPDATE vi_metric_base SET notes = '跟踪用途：T4：利润正在变成现金。2025 年 205 亿元；管理层说 2026 年在上年基础上增长；J-WC 假设营运资本占用逐年下降；验证论点：T4' WHERE id = 185;
UPDATE vi_metric_base SET notes = '跟踪用途：看同比；T4、T8：份额是不是用垫资换来的。两年增长 70%，而收入在降；增速高于 15% 说明营运资本占用还在扩大；验证论点：T1、T4、T8' WHERE id = 186;
UPDATE vi_metric_base SET notes = '跟踪用途：看同比；风险 R5：存量 PPP 约 4,900 亿元，接近归母净资产；2023 年 11 月后不再新增，应该只减不增；验证论点：T4、T8' WHERE id = 187;
UPDATE vi_metric_base SET notes = '跟踪用途：化债是 T4 的主要正方证据：2025 年政府债权回收超 1,500 亿元，2026 年上半年清收逾期超 800 亿元；管理层说力度较去年减弱；验证论点：T4' WHERE id = 196;
UPDATE vi_metric_base SET notes = '跟踪用途：T5：负债可控。2025 年末 9,405 亿元；J-DEBT 假设 2026 年净借款约 200 亿元；验证论点：T5' WHERE id = 188;
UPDATE vi_metric_base SET notes = '跟踪用途：T6：每股股息不降、派息率逐年提高；J-PAYOUT 假设 2026 年度每股股息持平（0.2718 元）；验证论点：T6' WHERE id = 195;
UPDATE vi_metric_base SET notes = '跟踪用途：看剔除喜马拉雅后的同比' WHERE id = 120;
UPDATE vi_metric_base SET source_name = 'https://www.cypc.com.cn' WHERE id = 97;
UPDATE vi_metric_base SET source_name = '季报、半年报分产品毛利率' WHERE id = 101;
UPDATE vi_metric_base SET source_name = '公司每月中下旬发布的《经营情况简报》（上交所公告），取“新签合同总额”累计同比' WHERE id = 190;
UPDATE vi_metric_base SET source_name = '公司年报建筑业务新签 ÷ 中国建筑业协会《建筑业发展统计分析》全国建筑业企业新签合同额（每年 2—3 月）' WHERE id = 193;
UPDATE vi_metric_base SET source_name = '财务数据（季报利润表）→ tools/track_fetch.py' WHERE id = 103;
UPDATE vi_metric_base SET source_name = '《经营情况简报》（季度月份附房建新开工、竣工、施工面积）' WHERE id = 192;
UPDATE vi_metric_base SET source_name = '半年报、年报“主营业务分行业”房地产开发与投资毛利率' WHERE id = 194;
UPDATE vi_metric_base SET source_name = '《经营情况简报》“地产业务合约销售额”累计同比' WHERE id = 191;
UPDATE vi_metric_base SET source_name = '半年报、年报经营情况讨论与业绩说明会（上半年录上半年，下半年录全年减上半年）' WHERE id = 196;
UPDATE vi_metric_base SET source_name = '年报利润分配预案（每年 3—4 月）' WHERE id = 195;
UPDATE vi_metric_base SET source_name = '季度业绩公告、业绩会' WHERE id = 120;
UPDATE vi_metric_base SET source_name = 'QuestMobile、行业研报' WHERE id = 133;
UPDATE vi_metric_base SET source_name = '季度业绩公告' WHERE id = 123;
UPDATE vi_metric_base SET source_name = '业绩公告、港交所回购公告' WHERE id = 132;
UPDATE vi_metric_base SET source_name = '资产负债表' WHERE id = 130;
UPDATE vi_metric_base SET source_name = '资产负债表' WHERE id = 131;
UPDATE vi_metric_base SET source_name = '年报（2027 年 3 月）' WHERE id = 126;
UPDATE vi_metric_base SET source_name = '季度业绩公告' WHERE id = 142;
UPDATE vi_metric_base SET source_name = '季度业绩公告' WHERE id = 148;
UPDATE vi_metric_base SET source_name = '季度业绩公告' WHERE id = 145;
UPDATE vi_metric_base SET source_name = '季度业绩公告：分项毛利、集团费用、汽车分部经营开支' WHERE id = 143;
UPDATE vi_metric_base SET source_name = '季度业绩公告：分项毛利、集团费用、汽车分部经营开支' WHERE id = 170;
UPDATE vi_metric_base SET source_name = '公司公告与微博、乘联会' WHERE id = 149;
UPDATE vi_metric_base SET source_name = '季度业绩公告、业绩会' WHERE id = 151;
UPDATE vi_metric_base SET source_name = '季度业绩公告' WHERE id = 139;
UPDATE vi_metric_base SET source_name = '季度业绩公告' WHERE id = 156;
UPDATE vi_metric_base SET source_name = '港交所翌日披露报表、证券变动月报表' WHERE id = 159;
UPDATE vi_metric_base SET source_name = '资产负债表与附注' WHERE id = 157;
UPDATE vi_metric_base SET source_name = '资产负债表与附注' WHERE id = 158;
UPDATE vi_metric_base SET frequency = '月' WHERE id = 190;
UPDATE vi_metric_base SET frequency = '季' WHERE id = 192;
UPDATE vi_metric_base SET frequency = '月' WHERE id = 191;
UPDATE vi_risk_base SET early_warning = CASE WHEN nullif(btrim(early_warning), '') IS NULL THEN '持续跟踪：公司公告与报告（交易日；来源：https://www.cypc.com.cn/cypc/tzzgx43/index.html）' ELSE early_warning || E'\n' || '持续跟踪：公司公告与报告（交易日；来源：https://www.cypc.com.cn/cypc/tzzgx43/index.html）' END WHERE id = 12;
UPDATE vi_risk_base SET early_warning = CASE WHEN nullif(btrim(early_warning), '') IS NULL THEN '持续跟踪：折旧与更新预算（半年；来源：https://www.cypc.com.cn）' ELSE early_warning || E'\n' || '持续跟踪：折旧与更新预算（半年；来源：https://www.cypc.com.cn）' END WHERE id = 13;
UPDATE vi_risk_base SET early_warning = CASE WHEN nullif(btrim(early_warning), '') IS NULL THEN '持续跟踪：债务与有效融资成本（季；来源：https://www.cypc.com.cn）' ELSE early_warning || E'\n' || '持续跟踪：债务与有效融资成本（季；来源：https://www.cypc.com.cn）' END WHERE id = 11;
UPDATE vi_judgment_base SET fact_layer = CASE WHEN nullif(btrim(fact_layer), '') IS NULL THEN '持续跟踪：分红及现金覆盖（半年；来源：https://www.cypc.com.cn）' ELSE fact_layer || E'\n' || '持续跟踪：分红及现金覆盖（半年；来源：https://www.cypc.com.cn）' END WHERE id = 6;
UPDATE vi_risk_base SET early_warning = CASE WHEN nullif(btrim(early_warning), '') IS NULL THEN '持续跟踪：资本配置回报（季；来源：https://www.cypc.com.cn）' ELSE early_warning || E'\n' || '持续跟踪：资本配置回报（季；来源：https://www.cypc.com.cn）' END WHERE id = 10;
UPDATE vi_judgment_base SET fact_layer = CASE WHEN nullif(btrim(fact_layer), '') IS NULL THEN '持续跟踪：权益法收益与现金分红（半年；来源：https://www.cypc.com.cn）' ELSE fact_layer || E'\n' || '持续跟踪：权益法收益与现金分红（半年；来源：https://www.cypc.com.cn）' END WHERE id = 6;
UPDATE vi_risk_base SET early_warning = CASE WHEN nullif(btrim(early_warning), '') IS NULL THEN '持续跟踪：永久损失与治理（不定期；来源：https://www.sse.com.cn）' ELSE early_warning || E'\n' || '持续跟踪：永久损失与治理（不定期；来源：https://www.sse.com.cn）' END WHERE id = 14;
UPDATE vi_risk_base SET early_warning = CASE WHEN nullif(btrim(early_warning), '') IS NULL THEN '持续跟踪：分产品吨利（季；来源：季报、半年报分产品毛利率）' ELSE early_warning || E'\n' || '持续跟踪：分产品吨利（季；来源：季报、半年报分产品毛利率）' END WHERE id = 15;
UPDATE vi_risk_base SET early_warning = CASE WHEN nullif(btrim(early_warning), '') IS NULL THEN '持续跟踪：箱板纸、文化纸价格与提价落地（月；来源：卓创/隆众/钢联（券商转引））' ELSE early_warning || E'\n' || '持续跟踪：箱板纸、文化纸价格与提价落地（月；来源：卓创/隆众/钢联（券商转引））' END WHERE id = 15;
UPDATE vi_risk_base SET early_warning = CASE WHEN nullif(btrim(early_warning), '') IS NULL THEN '持续跟踪：新产能爬坡与南宁项目进度（季；来源：公告、互动平台、业绩会）' ELSE early_warning || E'\n' || '持续跟踪：新产能爬坡与南宁项目进度（季；来源：公告、互动平台、业绩会）' END WHERE id = 16;
UPDATE vi_risk_base SET early_warning = CASE WHEN nullif(btrim(early_warning), '') IS NULL THEN '持续跟踪：资本开支与净负债（半年；来源：半年报、年报现金流量表与资产负债表）' ELSE early_warning || E'\n' || '持续跟踪：资本开支与净负债（半年；来源：半年报、年报现金流量表与资产负债表）' END WHERE id = 17;
UPDATE vi_risk_base SET early_warning = CASE WHEN nullif(btrim(early_warning), '') IS NULL THEN '持续跟踪：分红政策（2027—2029 年规划）（年；来源：年报、分红规划公告）' ELSE early_warning || E'\n' || '持续跟踪：分红政策（2027—2029 年规划）（年；来源：年报、分红规划公告）' END WHERE id = 18;
UPDATE vi_risk_base SET early_warning = CASE WHEN nullif(btrim(early_warning), '') IS NULL THEN '持续跟踪：股权激励考核完成情况（年；来源：年报）' ELSE early_warning || E'\n' || '持续跟踪：股权激励考核完成情况（年；来源：年报）' END WHERE id = 18;
UPDATE vi_risk_base SET early_warning = CASE WHEN nullif(btrim(early_warning), '') IS NULL THEN '持续跟踪：关联交易（年；来源：年报关联交易章节）' ELSE early_warning || E'\n' || '持续跟踪：关联交易（年；来源：年报关联交易章节）' END WHERE id = 18;
UPDATE vi_risk_base SET early_warning = CASE WHEN nullif(btrim(early_warning), '') IS NULL THEN '持续跟踪：老挝新项目与林地（半年；来源：业绩会、公告）' ELSE early_warning || E'\n' || '持续跟踪：老挝新项目与林地（半年；来源：业绩会、公告）' END WHERE id = 16;
UPDATE vi_risk_base SET early_warning = CASE WHEN nullif(btrim(early_warning), '') IS NULL THEN '持续跟踪：番茄音乐月活、汽水音乐付费情况（月；来源：QuestMobile、行业研报）' ELSE early_warning || E'\n' || '持续跟踪：番茄音乐月活、汽水音乐付费情况（月；来源：QuestMobile、行业研报）' END WHERE id = 23;
UPDATE vi_risk_base SET early_warning = CASE WHEN nullif(btrim(early_warning), '') IS NULL THEN '持续跟踪：新回购计划（季；来源：业绩公告、港交所回购公告）' ELSE early_warning || E'\n' || '持续跟踪：新回购计划（季；来源：业绩公告、港交所回购公告）' END WHERE id = 25;
UPDATE vi_risk_base SET early_warning = CASE WHEN nullif(btrim(early_warning), '') IS NULL THEN '持续跟踪：喜马拉雅收入与利润贡献（季；来源：业绩公告、年报分部或附注）' ELSE early_warning || E'\n' || '持续跟踪：喜马拉雅收入与利润贡献（季；来源：业绩公告、年报分部或附注）' END WHERE id = 26;
UPDATE vi_risk_base SET early_warning = CASE WHEN nullif(btrim(early_warning), '') IS NULL THEN '持续跟踪：AI 音乐与版权政策（季；来源：监管部门、行业协会、唱片公司）' ELSE early_warning || E'\n' || '持续跟踪：AI 音乐与版权政策（季；来源：监管部门、行业协会、唱片公司）' END WHERE id = 24;
UPDATE vi_risk_base SET early_warning = CASE WHEN nullif(btrim(early_warning), '') IS NULL THEN '持续跟踪：对外持股市值（Spotify、UMG）（季；来源：资产负债表的金融资产；Spotify、UMG 股价）' ELSE early_warning || E'\n' || '持续跟踪：对外持股市值（Spotify、UMG）（季；来源：资产负债表的金融资产；Spotify、UMG 股价）' END WHERE id = 27;
UPDATE vi_judgment_base SET fact_layer = CASE WHEN nullif(btrim(fact_layer), '') IS NULL THEN '持续跟踪：市场隐含核心倍数（交易日；来源：分部加总估值（自动计算））' ELSE fact_layer || E'\n' || '持续跟踪：市场隐含核心倍数（交易日；来源：分部加总估值（自动计算））' END WHERE id = 588;
UPDATE vi_judgment_base SET fact_layer = CASE WHEN nullif(btrim(fact_layer), '') IS NULL THEN '持续跟踪：存储合约价（DRAM、NAND）（月；来源：TrendForce、管理层电话会）' ELSE fact_layer || E'\n' || '持续跟踪：存储合约价（DRAM、NAND）（月；来源：TrendForce、管理层电话会）' END WHERE id = 760;
UPDATE vi_judgment_base SET fact_layer = CASE WHEN nullif(btrim(fact_layer), '') IS NULL THEN '持续跟踪：汽车月度交付与订单（单季交付量见指标）（月；来源：公司公告与微博、乘联会）' ELSE fact_layer || E'\n' || '持续跟踪：汽车月度交付与订单（单季交付量见指标）（月；来源：公司公告与微博、乘联会）' END WHERE id = 761;
UPDATE vi_judgment_base SET fact_layer = CASE WHEN nullif(btrim(fact_layer), '') IS NULL THEN '持续跟踪：AI 投入口径（季；来源：季度业绩公告、业绩会）' ELSE fact_layer || E'\n' || '持续跟踪：AI 投入口径（季；来源：季度业绩公告、业绩会）' END WHERE id = 763;
UPDATE vi_judgment_base SET fact_layer = CASE WHEN nullif(btrim(fact_layer), '') IS NULL THEN '持续跟踪：股本变动（月；来源：港交所翌日披露报表、证券变动月报表）' ELSE fact_layer || E'\n' || '持续跟踪：股本变动（月；来源：港交所翌日披露报表、证券变动月报表）' END WHERE id = 771;
UPDATE vi_judgment_base SET fact_layer = CASE WHEN nullif(btrim(fact_layer), '') IS NULL THEN '持续跟踪：投资者负债（季；来源：资产负债表与附注）' ELSE fact_layer || E'\n' || '持续跟踪：投资者负债（季；来源：资产负债表与附注）' END WHERE id = 764;
UPDATE vi_judgment_base SET fact_layer = CASE WHEN nullif(btrim(fact_layer), '') IS NULL THEN '持续跟踪：AI 商业化与可比公司估值（季；来源：业绩公告“其他相关业务”、MiMo 调用量与价格；智谱、MiniMax 市值，月之暗面、阶跃星辰上市定价）' ELSE fact_layer || E'\n' || '持续跟踪：AI 商业化与可比公司估值（季；来源：业绩公告“其他相关业务”、MiMo 调用量与价格；智谱、MiniMax 市值，月之暗面、阶跃星辰上市定价）' END WHERE id = 763;
UPDATE vi_judgment_base SET fact_layer = CASE WHEN nullif(btrim(fact_layer), '') IS NULL THEN '持续跟踪：印度诉讼（半年；来源：中报、年报或有事项附注）' ELSE fact_layer || E'\n' || '持续跟踪：印度诉讼（半年；来源：中报、年报或有事项附注）' END WHERE id = 774;
-- 5. 重要事实只写文字：数字关联到指标；正文里没写出来的原数值（推算值）记进备注
UPDATE vi_fact_base SET metric_id = 195 WHERE id = 1786 AND metric_id IS NULL;
UPDATE vi_fact_base SET metric_id = 126 WHERE id = 1320 AND metric_id IS NULL;
UPDATE vi_fact_base SET metric_id = 152 WHERE id = 1836 AND metric_id IS NULL;
UPDATE vi_fact_base SET metric_id = 134 WHERE id = 1837 AND metric_id IS NULL;
UPDATE vi_fact_base SET metric_id = 166 WHERE id = 1839 AND metric_id IS NULL;
UPDATE vi_fact_base SET metric_id = 138 WHERE id = 1840 AND metric_id IS NULL;
UPDATE vi_fact_base SET metric_id = 163 WHERE id = 1841 AND metric_id IS NULL;
UPDATE vi_fact_base SET metric_id = 164 WHERE id = 1842 AND metric_id IS NULL;
UPDATE vi_fact_base SET metric_id = 160 WHERE id = 1845 AND metric_id IS NULL;
UPDATE vi_fact_base SET metric_id = 161 WHERE id = 1846 AND metric_id IS NULL;
UPDATE vi_fact_base SET metric_id = 151 WHERE id = 1849 AND metric_id IS NULL;
UPDATE vi_fact_base SET metric_id = 145 WHERE id = 1861 AND metric_id IS NULL;
UPDATE vi_fact_base SET metric_id = 178 WHERE id = 1872 AND metric_id IS NULL;
UPDATE vi_fact_base SET notes = '原“数值”字段：-5 亿元（2019—2025），为正文数字的推算或合计' WHERE id = 1695;
UPDATE vi_fact_base SET notes = '原“数值”字段：20 百万人（2025Q4），为正文数字的推算或合计' WHERE id = 1333;
UPDATE vi_fact_base SET notes = '原“数值”字段：21000 亿元（2026），为正文数字的推算或合计' WHERE id = 1795;
UPDATE vi_fact_base SET notes = '原“数值”字段：0.25 比率（2025Q2），为正文数字的推算或合计' WHERE id = 1349;
UPDATE vi_fact_base SET notes = '原“数值”字段：-26 亿元（2026Q2），为正文数字的推算或合计' WHERE id = 1848;
UPDATE vi_fact_base SET notes = '原“数值”字段：-31 亿元（2026Q1），为正文数字的推算或合计' WHERE id = 1849;
UPDATE vi_fact_base SET notes = '专家口径。
原“数值”字段：47 万辆（2026E），为正文数字的推算或合计' WHERE id = 1852;
UPDATE vi_fact_base SET notes = '原“数值”字段：101.16 亿元（2026-06-30），为正文数字的推算或合计' WHERE id = 1867;
UPDATE vi_fact_base SET notes = '原“数值”字段：68.95 亿元（2026H1），为正文数字的推算或合计' WHERE id = 1874;
UPDATE vi_fact_base SET notes = '卖方估值没有扣除 AI 投入的长期成本，也没有扣除股权激励。
原“数值”字段：9300 亿元（2026-08），为正文数字的推算或合计' WHERE id = 1881;
-- 6. 每个指标都要写数据来源（每期的来源文档关联在“数据”上）
ALTER TABLE vi_metric_base ADD CONSTRAINT vi_metric_source_required CHECK (nullif(btrim(source_name), '') IS NOT NULL);
-- 7. 删除旧结构（依赖它们的视图由随后重跑的 02、03 重建）
DROP VIEW IF EXISTS vi_fact, vi_watch, vi_watch_calc, vi_company_metric CASCADE;
ALTER TABLE vi_fact_base DROP COLUMN value, DROP COLUMN unit;
DROP TABLE vi_lnk_watch_theses, vi_lnk_watch_judgments, vi_lnk_risk_watches;
DROP TABLE vi_watch_base CASCADE;
DROP FUNCTION IF EXISTS vi_watch_dml();
COMMENT ON COLUMN vi_fact_base.metric_id IS '相关指标（关联 指标）';
COMMIT;
