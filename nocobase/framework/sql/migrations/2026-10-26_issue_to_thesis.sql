-- 问题清单 → 待办清单（2026-10-26）
-- 判断类的问题并进对应核心论点（决定胜负的证据 / 改判条件 / 对模型的影响），再从待办里删除；
-- 只看隐含回报的三家（长江电力、太阳纸业、中国建筑）不再有关注价，“安全边际选几档”的 Q01 删除；
-- 研究文字里的“问题清单”改为新名称（变更日志是历史记录，不改）。可重复执行。
BEGIN;

-- 中国建筑 Q04 应收＋合同资产的真实可收回性 → T4
UPDATE vi_thesis_base t SET decisive_evidence = t.decisive_evidence
  || '还没取得、需要去找的：应收与合同资产的账龄结构、坏账准备计提比例、政府类客户占比，并与中国中铁、中国铁建对比（应收＋合同资产 2026 年中 1.18 万亿元、PPP 相关非流动资产约 4,900 亿元，是 PB 0.37 倍的核心原因）。'
FROM vi_company_base c WHERE c.id = t.company_id AND c.code = '601668.SH' AND t.code = 'T4'
  AND t.decisive_evidence NOT LIKE '%账龄结构%';

-- 太阳纸业 Q04 派息率路径是最大判断 → T4
UPDATE vi_thesis_base t SET model_impact = coalesce(t.model_impact || ' ', '')
  || '派息率路径是股息贴现价值最大的单一判断：基准假设 2034 年派息率升到 80%；若长期维持 30%，价值取决于留存现金的再投资回报（T5）。'
FROM vi_company_base c WHERE c.id = t.company_id AND c.code = '002078.SZ' AND t.code = 'T4'
  AND coalesce(t.model_impact, '') NOT LIKE '%派息率路径是股息贴现价值%';

-- 腾讯音乐 Q06 境内现金能否回到股东手里 → T5
UPDATE vi_thesis_base t SET decisive_evidence = t.decisive_evidence
  || '还要确认：境内外现金分布、预提税率与外汇安排，美元票据与借款的用途（2026 年用美元借款和票据支付喜马拉雅现金对价与回购，境内保留人民币存款）。'
FROM vi_company_base c WHERE c.id = t.company_id AND c.code = '01698.HK' AND t.code = 'T5'
  AND t.decisive_evidence NOT LIKE '%预提税率%';

-- 小米集团 Q11 AI 直接估值 1,000 亿元是主观判断 → T4
UPDATE vi_thesis_base t SET mind_changer = t.mind_changer
  || '另外：小米披露 AI 收入、单独融资或分拆时，按可观察的价格重估 1,000 亿元（经营分部 S5，每股约 3.89 元；2026-10-23 由用户参照国内大模型公司估值指定，资金口径偏高约 331 亿元，见 J-AI）。'
FROM vi_company_base c WHERE c.id = t.company_id AND c.code = '01810.HK' AND t.code = 'T4'
  AND t.mind_changer NOT LIKE '%单独融资或分拆时%';

DELETE FROM vi_issue_base i USING vi_company_base c WHERE c.id = i.company_id AND (
     (c.code = '601668.SH' AND i.code IN ('Q01', 'Q04'))
  OR (c.code = '002078.SZ' AND i.code IN ('Q01', 'Q04'))
  OR (c.code = '600900.SH' AND i.code = 'Q01')
  OR (c.code = '01698.HK' AND i.code = 'Q06')
  OR (c.code = '01810.HK' AND i.code = 'Q11'));

UPDATE vi_risk_base SET response = replace(response, '问题清单', '待办清单'),
                        impact_estimate = replace(impact_estimate, '问题清单', '待办清单')
WHERE response LIKE '%问题清单%' OR impact_estimate LIKE '%问题清单%';
UPDATE vi_biz_model_base SET trend = replace(trend, '问题清单', '待办清单') WHERE trend LIKE '%问题清单%';
UPDATE vi_source_base SET limitations = replace(limitations, '问题清单', '待办清单') WHERE limitations LIKE '%问题清单%';
UPDATE vi_thesis_base SET model_impact = replace(model_impact, '问题清单', '待办清单') WHERE model_impact LIKE '%问题清单%';

INSERT INTO vi_change_log_base (change_date, title, target, old_value, new_value, reason, basis, verification, company_id)
SELECT '2026-10-26', '问题清单改为“待办清单”，判断类问题并入核心论点', '待办清单；核心论点 ' || x.t,
       '问题清单 ' || x.q, '并入 ' || x.t || '（' || x.f || '）', x.r,
       '用户确认：判断（问题与结论）只写在核心论点，问题清单只放做完即关的待办。', '估值与自动检查不受影响（研究层文字改动）。', c.id
FROM (VALUES ('601668.SH', 'Q04 应收＋合同资产的真实可收回性；Q01 安全边际选 10% 还是 30%', 'T4', '决定胜负的证据', 'Q04 是判断性问题；Q01 已无关注价（只看隐含回报 vs 门槛），删除'),
             ('002078.SZ', 'Q04 派息率路径是最大判断；Q01 安全边际选 10% 还是 30%', 'T4', '对模型的影响', 'Q04 是判断性问题；Q01 已无关注价（只看隐含回报 vs 门槛），删除'),
             ('600900.SH', 'Q01 安全边际手册 30% 与表内 10% 不一致（已解决）', '—', '删除', '已无关注价（只看隐含回报 vs 门槛）'),
             ('01698.HK', 'Q06 境内现金能否回到股东手里', 'T5', '决定胜负的证据', '判断性问题'),
             ('01810.HK', 'Q11 AI 直接估值 1,000 亿元是主观判断', 'T4', '改判条件', '判断性问题')) x(code, q, t, f, r)
JOIN vi_company_base c ON c.code = x.code
WHERE NOT EXISTS (SELECT 1 FROM vi_change_log_base l WHERE l.company_id = c.id AND l.title = '问题清单改为“待办清单”，判断类问题并入核心论点');

COMMIT;
