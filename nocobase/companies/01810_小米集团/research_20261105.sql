-- 小米集团研究增强（2026-11-05）：汽车与手机同业毛利率接入；待办推进。
-- 数据来自跟踪脚本（track.py → data/track.json，种子在此之前已写入）；本文件只改研究正文、补关联与待办，按业务键定位，可重复执行。

UPDATE vi_thesis_base SET decisive_evidence = '月度交付（四季度能否月均 5.5 万辆以上）；2027 年交付与 ASP；汽车及 AI 分部毛利率与经营损益；海外首年销量。'
  || '同业对比（跟踪脚本，公告口径）：2025 年小米汽车及 AI 分部毛利率 24.3%，小鹏 18.9%、蔚来 15.5%、零跑 14.5%，领先明显；2026 年上半年降到 19.6%（一季度 20.1%、二季度 19.3%），已略低于小鹏（20.6%）、仍高于零跑（11.7%）——“比同业更赚钱”的优势在收窄，看三季度能否止跌。'
WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND code = 'T3';

UPDATE vi_thesis_base SET decisive_evidence = '2026 年三、四季度及 2027 年上半年的手机毛利率与 ASP、生态营业费用率；DRAM/NAND 合约价；出货份额。'
  || '对照（跟踪脚本）：传音控股单季毛利率 2026 年一至三季度 22.0%、23.2%、22.7%，同期小米智能手机 10.1%、8.5%（三季度待公告）——存储涨价下传音毛利率反而上升，说明不是全行业同压；小米的回落更多来自自身产品与定价结构，验证“周期过后能回到 11%—12%”时要看高端机占比。'
WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND code = 'T2';

WITH co AS (SELECT id FROM vi_company_base WHERE code = '01810.HK')
INSERT INTO vi_lnk_thesis_basis_metrics (thesis_id, metric_id, "createdAt", "updatedAt")
SELECT t.id, m.id, now(), now() FROM vi_thesis_base t JOIN vi_metric_base m ON m.company_id = t.company_id AND
  ((t.code = 'T3' AND m.name IN ('同业毛利率：理想汽车', '同业毛利率：小鹏汽车', '同业毛利率：零跑汽车', '同业毛利率：蔚来'))
   OR (t.code = 'T2' AND m.name = '同业毛利率：传音控股'))
WHERE t.company_id = (SELECT id FROM co) ON CONFLICT DO NOTHING;

UPDATE vi_issue_base SET status = '处理中', progress = '2026-11-05：汽车同业（理想、小鹏、零跑、蔚来）与手机同业（传音）的毛利率改用公告口径，由跟踪脚本每期更新（track.py）；交付、份额、单车利润仍需以公司公告或年报核对。'
WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND code = 'Q08';

UPDATE vi_issue_base SET progress = '2026-11-05 检索：未见 2026 年判决、上诉或和解的公开报道。已知进展：2022 年印度执法局冻结约 555.1 亿卢比（约 47 亿元人民币），卡纳塔克邦高等法院 2022 年 5 月暂缓、10 月要求银行保函，2023 年 4 月 FEMA 主管机关确认冻结，公司就 FEMA 第 37 条合宪性起诉，高院已保留判决。模型未计入这笔资金，也未计罚款；判决后按结果调整“其他调整”。'
WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND code = 'Q09';

UPDATE vi_issue_base SET status = '处理中', progress = '分析（2026-11-05）：模型利润率按国际财务报告准则的费用分摊，已含股权激励费用；再按摊薄股本（约 264 亿股）算每股，重复的只是“已授出、未归属”的那部分——它们今后的费用在利润率里扣一次、股数里又摊一次；未来新授出的部分只在费用里扣，不重复。'
  || '所以两种处理的差（每股约 −2.7%）是重复计算的上限，实际重复小于它。建议（需你确认）：保留摊薄股本作为保守口径，在估值说明里注明“偏保守，上限约 2.7%”，不再另调利润率。'
WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND code = 'Q10';

-- 安全边际只保留 10% 一档（你确认，2026-11-05）
INSERT INTO vi_change_log_base (change_date, title, target, old_value, new_value, reason, basis, verification, company_id, created_at, updated_at)
SELECT '2026-11-05', '安全边际只保留 10% 一档', '估值模型：安全边际（低档 10%、高档取消）', '10% / 30% 两档并列', '10% 一档（关注价＝今天价值×90%）',
  '你确定交易纪律：安全边际用 10%', '用户决定', '关注价只显示一个；估值不变', c.id, now(), now()
FROM vi_company_base c WHERE c.code = '01810.HK' AND NOT EXISTS (SELECT 1 FROM vi_change_log_base x WHERE x.company_id = c.id AND x.title = '安全边际只保留 10% 一档');
UPDATE vi_issue_base SET status = '已解决', progress = '2026-11-05：你确定安全边际用 10%，估值模型只保留一档（关注价＝基准每股价值×90%）。'
WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND code = 'Q01';
UPDATE vi_issue_base SET status = '已解决', progress = progress || '　2026-11-05 你确认：保留摊薄股本（约 264 亿股）作为保守口径，不另调利润率；重复计算的上限约每股 2.7%。'
WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND code = 'Q10' AND progress NOT LIKE '%2026-11-05 你确认%';
-- （2026-11-11 估值重构：估值模型已删除，股本说明在公司备注里）
