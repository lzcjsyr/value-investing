-- 自动生成：framework/greenwald_seed.py。三层估值：估值设置、业务口径、假设依据、资产负债重估、调整后利润表、增长
BEGIN;
UPDATE vi_company_base SET as_of = '2026-06-30', shares = 28.5419, value_layer = NULL, layer_reason = NULL, av_basis = '调整后净资产', repro_cost = NULL, notes = '主要风险：纸价与浆价错配、行业新增产能压价、文化纸需求长期下滑、扩张不停导致自由现金流长期为负、净负债上升、第一大客户为关联方（集团白卡纸业务）、多个税收优惠 2026—2033 年陆续到期。

原估值模型说明（2026-11-11 估值按 Greenwald 三层重构前，留作历史；其中的股本口径仍适用）：经营假设（2026-10-22）：销量 2026 年 1065 万吨→2028 年 1150 万吨→2031 年 1225 万吨，之后约 +1%/年；综合吨收入 2026—2028 年 0.402 万元/吨，之后 +1%/年；付现成本按 EBITDA 率 18.3%→19.0% 倒推；折旧 29→37.1 亿元；资本开支 70→60→50→48，2030 年起约 40 亿元（含老挝新项目约 50 亿、2030—2031 年新增约 60 万吨销量）；税率 14%→18%（税收优惠陆续到期）；派息率 27%→80%。股本 28.5419 亿股（2026-08 限制性股票登记后）。期初资产负债取 2025 年末合并报表（Wind）：经营性长期资产 439.55＝固定资产 397.54＋在建工程 19.09＋无形资产 22.63＋使用权资产 0.29；长期股权投资 3.24；归母权益 305.02；少数股东权益 1.10；带息负债 199.67（短期借款 79.78＋一年内到期 30.33＋长期借款 89.34＋租赁 0.22）。风险溢价 6.0%（周期性制造业），高于长江电力的 3.5%。安全边际两档并列 10%/30%，与长江电力一致。' WHERE id = (SELECT id FROM vi_company_base WHERE code = '002078.SZ');
DELETE FROM vi_bs_item_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '002078.SZ');
DELETE FROM vi_epv_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '002078.SZ');
DELETE FROM vi_growth_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '002078.SZ');
COMMIT;
