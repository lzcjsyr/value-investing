-- 腾讯音乐研究增强（2026-11-05）：竞争对手利润率（网易云音乐、Spotify）接入；待办推进。
-- 数据来自跟踪脚本（track.py → data/track.json，种子在此之前已写入）；本文件只改研究正文、补关联与待办，按业务键定位，可重复执行。

UPDATE vi_thesis_base SET decisive_evidence = '单季毛利率是否守在 42%—43% 以上；版权续约条款（保底与分成比例）；演出与周边的收入占比（毛利率低）；剔除喜马拉雅后会员收入同比；字节是否拿到头部华语全曲库授权。'
  || '同业对比（跟踪脚本，公告口径）：毛利率领先网易云音乐 2021 年 28.1 个百分点 → 2022 年 16.6 → 2023—2025 年约 8.5 → 2026 年上半年 7.3（44.5% vs 37.2%）——取消独家后对手追上来一大截，2023 年起差距基本稳住、仍在缓慢收窄；Spotify 单季毛利率约 33%。差距跌破 5 个百分点要复核 T1。'
WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND code = 'T1';

WITH co AS (SELECT id FROM vi_company_base WHERE code = '01698.HK')
INSERT INTO vi_lnk_thesis_basis_metrics (thesis_id, metric_id, "createdAt", "updatedAt")
SELECT t.id, m.id, now(), now() FROM vi_thesis_base t JOIN vi_metric_base m ON m.company_id = t.company_id AND
  ((t.code = 'T1' AND m.name IN ('同业毛利率：网易云音乐', '同业毛利率：Spotify')) OR (t.code = 'T3' AND m.name IN ('同业经营利润率：网易云音乐')))
WHERE t.company_id = (SELECT id FROM co) ON CONFLICT DO NOTHING;

WITH co AS (SELECT id FROM vi_company_base WHERE code = '01698.HK')
INSERT INTO vi_lnk_moat_basis_metrics (moat_id, metric_id, "createdAt", "updatedAt")
SELECT x.id, m.id, now(), now() FROM vi_moat_base x JOIN vi_metric_base m ON m.company_id = x.company_id AND m.name = '同业毛利率：网易云音乐'
WHERE x.company_id = (SELECT id FROM co) AND x.code = 'M1' ON CONFLICT DO NOTHING;

UPDATE vi_issue_base SET status = '处理中', progress = '2026-11-05：竞争对手的利润率改用公告口径——网易云音乐（港股报表，半年与全年）、Spotify（美股报表，单季）由跟踪脚本每期更新（track.py）；第三方月活（汽水音乐）仍是三级来源，只看趋势。'
WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND code = 'Q08';

-- 停止季度披露的三个用户指标：频率改为年（只在年报披露），不再按季度标“待更新”
UPDATE vi_metric_base SET frequency = '年' WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK')
  AND name IN ('在线音乐付费用户', '在线音乐月活跃用户', '单个付费用户月均收入（ARPPU）');

-- 汽水音乐月活：补第三方监测的历史点（QuestMobile，经媒体与券商转引；三级来源，只看趋势）
SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '竞品月活：汽水音乐', '时点', '百万人', '2025M09', '2025-09-30', 120.39, 0.907,
  'QuestMobile 2025 年 9 月（华金证券行业快报转引）：酷狗 210.2、QQ 音乐 189.8、网易云音乐 147.2、汽水音乐 120.4、酷我 112.5 百万；汽水同比 +90.7%。', NULL);
SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '竞品月活：汽水音乐', '时点', '百万人', '2026M04', '2026-04-30', 156, NULL,
  'QuestMobile 2026 年 4 月（钛媒体转引）：汽水音乐约 1.56 亿、网易云音乐约 1.47 亿。', NULL);
SELECT vi_put_disclosed((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '竞品月活：汽水音乐', '时点', '百万人', '2026M06', '2026-06-30', 167, 0.687,
  'QuestMobile 2026 年 6 月（虎嗅转引）：汽水音乐约 1.67 亿（+68.7%），超过网易云音乐、接近 QQ 音乐 1.89 亿；QQ 音乐 −0.7%，酷狗 −10.7%、酷我 −18.5%、全民 K 歌 −29.7%。', NULL);

-- 安全边际只保留 10% 一档（你确认，2026-11-05）
INSERT INTO vi_change_log_base (change_date, title, target, old_value, new_value, reason, basis, verification, company_id, created_at, updated_at)
SELECT '2026-11-05', '安全边际只保留 10% 一档', '估值模型：安全边际（低档 10%、高档取消）', '10% / 30% 两档并列', '10% 一档（关注价＝今天价值×90%）',
  '你确定交易纪律：安全边际用 10%', '用户决定', '关注价只显示一个；估值不变', c.id, now(), now()
FROM vi_company_base c WHERE c.code = '01698.HK' AND NOT EXISTS (SELECT 1 FROM vi_change_log_base x WHERE x.company_id = c.id AND x.title = '安全边际只保留 10% 一档');
UPDATE vi_issue_base SET status = '已解决', progress = '2026-11-05：你确定安全边际用 10%，估值模型只保留一档（关注价＝基准每股价值×90%）。'
WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND code = 'Q01';
