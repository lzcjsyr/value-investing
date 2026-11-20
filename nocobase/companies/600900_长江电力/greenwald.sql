-- 自动生成：framework/greenwald_seed.py。三层估值：估值设置、业务口径、假设依据、资产负债重估、调整后利润表、增长
BEGIN;
UPDATE vi_company_base SET as_of = '2026-06-30', shares = 244.68, value_layer = NULL, layer_reason = NULL, av_basis = '调整后净资产', repro_cost = NULL, notes = '主要风险：极端枯水、电价市场化折价、低回报资本配置（抽蓄约 800 万千瓦在建、葛洲坝扩能约 266 亿）、利率上行。

原估值模型说明（2026-11-11 估值按 Greenwald 三层重构前，留作历史；其中的股本口径仍适用）：经营假设来自 2026-09-01 旧模型：业务量 2026 年 3100、此后 3050 亿千瓦时（2023—2025 年均 2931，六库联调缓升）；电价持平 2025 年 0.2807；付现成本 203 起年增约 1%；折旧 190 起，三峡机组到期年均降约 5 亿，2031—2032 年溪洛渡/向家坝到期加速，2035 年约 144；其他净贡献 45（2025 年校准）；派息率 72%（承诺下限 70%）。2026-10-21 重构：综合负担率 17.34% 拆为所得税率 16.27% 与少数股东占比 1.28%（2025 年实际）；利息改为债务滚动，平均债务成本按原利息路径反推（3.02%→2.05%，与新发债利率 1.3%—2.1% 方向一致，待核验）。2026-10-25 起估值只看按市价买入的隐含回报 vs 门槛（要求收益率 6%，依据 J-R），不用安全边际；无风险利率、风险溢价与情景折现率不参与结论。期初资产负债取 2025 年末合并资产负债表（岗底斯）：经营性长期资产 4581.84＝固定资产 4165.74＋在建工程 159.06＋无形资产 250.25＋使用权资产 6.79；长期股权投资 749.36；归母权益 2213.38；少数股东权益 120.23；带息负债 2907.51。股本 244.68 亿股（2025 年末发行在外总股本）。' WHERE id = (SELECT id FROM vi_company_base WHERE code = '600900.SH');
DELETE FROM vi_bs_item_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '600900.SH');
DELETE FROM vi_epv_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '600900.SH');
DELETE FROM vi_growth_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '600900.SH');
COMMIT;
