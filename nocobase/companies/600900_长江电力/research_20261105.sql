-- 长江电力研究增强（2026-11-05）：四家水电同口径对比接入；三季报核对；待办推进。
-- 数据来自跟踪脚本（track.py → data/track.json，种子在此之前已写入）；本文件只改研究正文、补关联与待办，按业务键定位，可重复执行。

-- 1. 论点 T1：“回报高于并稳于同业”改为测算读数
UPDATE vi_thesis_base SET decisive_evidence = '毛利率与 ROE 是否保持在同业之上；受电省份电价与公司综合电价的走势；维持性资本开支的实际水平。'
  || '同业对比（跟踪脚本，四家 A 股水电同口径）：ROE 2021—2025 年 14.9%、11.6%、12.7%、15.8%、16.0%，同业中位数 9.3%、10.6%、11.4%、11.6%、11.0%（2022 年来水偏枯时差距缩到 1 个百分点）；毛利率 2025 年 61.7%、同业中位数 52.3%；资产负债率 58.3%，与同业中位数 57.4% 相当——回报高不是靠更高的杠杆。'
WHERE company_id = 1 AND code = 'T1';

INSERT INTO vi_lnk_thesis_basis_metrics (thesis_id, metric_id, "createdAt", "updatedAt")
SELECT t.id, m.id, now(), now() FROM vi_thesis_base t JOIN vi_metric_base m ON m.company_id = t.company_id
  AND m.name IN ('归母ROE（同业口径）', '同业ROE中位数（四家水电）', '同业毛利率中位数（四家水电）', '资产负债率', '同业资产负债率中位数（四家水电）')
WHERE t.company_id = 1 AND t.code = 'T1' ON CONFLICT DO NOTHING;

-- 2. 待办
UPDATE vi_issue_base SET status = '已解决', progress = '2026-11-05：库内 2025 年数值与《2025 年年度报告摘要》第 3.1 表逐项一致——营业收入 862.42 亿元（86,241,940,222.20 元）、利润总额 417.40、归母净利润 345.03、经营活动现金流量净额 605.63、总资产 5,592.08；三大报表 2010 年以来与东方财富逐期交叉核对一致（tools/fin_stmt.py check，0 项失败）。'
WHERE company_id = 1 AND code = 'Q03';

UPDATE vi_issue_base SET progress = '有效税率（所得税÷利润总额）：2023 年 13.8%、2024 年 15.3%、2025 年 16.3%，2026 年上半年 17.0%、前三季度 16.2%——在缓慢上升，但还没有到卖方 2027 年 17.0% 的水平。'
  || '乌东德（2020—2021 年投产）、白鹤滩（2021—2022 年投产）的“三免三减半”按投产年份推算分别在 2026、2027 年前后结束减半，税率台阶应出现在 2027—2028 年。建议（需你确认）：逐年假设税率 2026 年 16.3%、2027 年 17.0%、2028 年起 17.5%（按分电站利润占比粗算；粗算税率每高 0.7 个百分点，归母净利约少 0.8%）。'
WHERE company_id = 1 AND code = 'Q11';

UPDATE vi_issue_base SET status = '处理中', progress = '电价桥接（2026-11-05）：用年报平均上网电价（“实现售电价”，含税）× 发电量 × 0.995（上网率）÷ 1.13（增值税）估算境内电力收入：2023 年约 684 亿元、2024 年约 744、2025 年约 758；合并营业收入 781、845、862 减去它，剩约 97、101、104 亿元——与海外配售电（秘鲁）及其他业务的规模相当，三年稳定。'
  || '结论：模型的“综合电价”＝合并收入÷境内六站发电量（2025 年 0.2807），含约 12% 的非境内电力收入；三年稳定说明混用口径没有造成偏差，但海外收入会随境内电量同比例外推。待年报分地区收入核对海外部分。'
WHERE company_id = 1 AND code = 'Q02';

UPDATE vi_issue_base SET progress = progress || '　2026-11-05 核对：2026 年前三季度财务费用 61.5 亿元，年化约 82 亿元，对 2025 年末带息负债约 2,875 亿元（短借＋一年内到期＋长借＋债券）隐含约 2.85%（2025 年约 3.2%），下降方向与模型一致；2.05% 的长期水平取决于低息置换节奏，年报后用期初期末平均负债复核。'
WHERE company_id = 1 AND code = 'Q05' AND progress NOT LIKE '%2026-11-05%';

UPDATE vi_issue_base SET progress = progress || '　2026-11-05：三峡集团官网水情栏目已下线（404）；长江水文网三峡站只给水位与出库流量，仍未找到入库流量的公开稳定来源。'
WHERE company_id = 1 AND code IN ('D1', 'D2') AND progress NOT LIKE '%2026-11-05%';

UPDATE vi_issue_base SET progress = progress || '　2026-11-05：新浪报表有 2014、2015 年营业成本原值（99.3、181.1 亿元），但 2015 年被 2016 年同一控制下合并追溯调整、口径不同，历史年度明确不取报表值；仍需 2016 年年报里的 2015 年追溯调整数。'
WHERE company_id = 1 AND code = 'Q10' AND progress NOT LIKE '%2026-11-05%';

INSERT INTO vi_issue_base (code, title, severity, impact, done_condition, status, progress, company_id, created_at, updated_at)
SELECT 'Q12', '2026 年发电量、收入假设偏高（三季报核对）', '关键',
  '2026 年归母净利与股息、2027 年起点',
  '年报出来后用全年发电量、收入、归母净利修正 2026 年逐年假设，并复核 2027 年 3,050 亿千瓦时的平水基准。', '待处理',
  '三季报核对（2026-11-05）：前三季度发电量 2,250.6 亿千瓦时（2025 年同期 2,351.3），三季度单季 923.1（−14.9%）；营业收入 630.6 亿元（−4.1%）、归母 263.4 亿元（−6.6%），三季度单季归母 115.9（−23.4%）。'
  || '模型 2026 年发电量 3,100 亿千瓦时需四季度约 849（去年四季度 720.7，+18%），可能性低；若四季度与去年持平，全年约 2,971（−3.3%），收入约 836 亿元（模型 870），归母约 327 亿元（模型 361）。建议（需你确认）：2026 年发电量 3,100 → 约 2,970。', 1, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM vi_issue_base WHERE company_id = 1 AND code = 'Q12');

-- 3. 三季报后修正 2026 年发电量、所得税率路径（你确认，2026-11-05）
UPDATE vi_issue_base SET status = '处理中', progress = progress || '　2026-11-05 已修正（你确认）：2026 年发电量 3,100 → 2,970 亿千瓦时；基准 2026 年归母约 330 亿元。年报后用全年数复核，并复核 2027 年 3,050 的平水基准。'
WHERE company_id = 1 AND code = 'Q12' AND progress NOT LIKE '%已修正（你确认）%';
UPDATE vi_issue_base SET status = '已解决', progress = progress || '　2026-11-05 已按建议修改（你确认）：逐年假设所得税率 2026 年 16.3%、2027 年 17.0%、2028 年起 17.5%。'
WHERE company_id = 1 AND code = 'Q11' AND progress NOT LIKE '%已按建议修改%';
INSERT INTO vi_change_log_base (change_date, title, target, old_value, new_value, reason, basis, verification, company_id, created_at, updated_at)
SELECT '2026-11-05', '三季报后下调 2026 年发电量，所得税率按减半期结束上调', '逐年假设：2026 年发电量（J-Q）；2026—2035 年所得税率',
  '2026 年发电量 3,100 亿千瓦时；所得税率各年 16.27%', '2026 年发电量 2,970 亿千瓦时；所得税率 2026 年 16.3%、2027 年 17.0%、2028 年起 17.5%',
  '前三季度电量 2,250.6 亿千瓦时，要达到 3,100 需四季度同比 +18%（待办 Q12）；乌东德、白鹤滩所得税减半期 2026—2027 年前后结束（待办 Q11）',
  '2026 年三季度报告、发电量公告；2023—2026 年有效税率 13.8%、15.3%、16.3%、16.2%',
  '基准今天每股价值 27.33 → 26.86 元；按市价买入的隐含年化回报 4.86% → 4.79%', 1, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM vi_change_log_base x WHERE x.company_id = 1 AND x.title = '三季报后下调 2026 年发电量，所得税率按减半期结束上调');

-- 安全边际只保留 10% 一档（你确认，2026-11-05）
INSERT INTO vi_change_log_base (change_date, title, target, old_value, new_value, reason, basis, verification, company_id, created_at, updated_at)
SELECT '2026-11-05', '安全边际只保留 10% 一档', '估值模型：安全边际（低档 10%、高档取消）', '10% / 30% 两档并列', '10% 一档（关注价＝今天价值×90%）',
  '你确定交易纪律：安全边际用 10%', '用户决定', '关注价只显示一个；估值不变', c.id, now(), now()
FROM vi_company_base c WHERE c.code = '600900.SH' AND NOT EXISTS (SELECT 1 FROM vi_change_log_base x WHERE x.company_id = c.id AND x.title = '安全边际只保留 10% 一档');
