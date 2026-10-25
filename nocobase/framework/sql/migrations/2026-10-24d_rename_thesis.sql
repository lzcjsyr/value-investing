-- 2026-10-24（第四次）：「论点与辩论」改名「核心论点」。
-- 数据库注释按 spec.py 重写；NocoBase 里存的显示文字（菜单路由、页面与浏览器标题、弹窗与图表标题、弹窗模板名）一并替换，
-- 页面内部的 declaredKey 不动（只用于生成器对齐，不显示）。变更日志、2026-10-23 的来源文档标题是历史记录，不改。
-- 执行后重跑 02、03；在 NocoBase 更新集合标题（register.collection_body(thesis, describe=True)），重启 app。
BEGIN;
COMMENT ON TABLE vi_biz_model_base IS '商业模式：商业模式画布 9 项，每家公司一项一行（B1—B9 按画布顺序）。投资者关心的内容放进画布：盈利公式的收入一侧、收入结构、单价、增长与周期写在“收入来源”；盈利公式的成本一侧、成本构成、单位利润、资本需求与现金循环写在“成本结构”。只写事实与机制；有争议、决定价值的判断写在核心论点里。';
COMMENT ON TABLE vi_moat_base IS '竞争壁垒：每一项候选壁垒：机制、财务体现、证据、反证、复制难度；看起来像壁垒其实不是的（伪壁垒）也要列出。壁垒能不能持续，在核心论点里正反论证并关联到这里。可设自动检查，读取历史财务。';
COMMENT ON TABLE vi_thesis_base IS '核心论点：决定价值的几个关键判断，每条都正反论证：正方立论、反方立论、互相反驳，再给裁决、把握、改判条件和对模型的影响。壁垒能否持续的论点关联到竞争壁垒（伪壁垒以外每项壁垒至少一条辩论过的论点）；能量化的改判条件设自动检查，读取历史财务。';
COMMENT ON TABLE vi_risk_base IS '风险分析：会让这笔投资亏钱的不利事件：传导路径、可能性×冲击（自动定级）、量化影响、缓冲因素、在估值里怎么处理、预警信号与触发后应对。风险是论点失败或外部冲击的“事件”，论证本身仍在核心论点里，这里只关联会被削弱的论点；落到参数的关联假设依据，盯什么关联跟踪事项。';
COMMENT ON TABLE vi_judgment_base IS '假设依据：事实 → 判断 → 参数：解释事实和论点如何影响哪个估值参数、改参数的门槛、什么情况下不改。论证本身写在核心论点里，这里只写到参数的传导。';
COMMENT ON TABLE vi_lnk_thesis_facts IS '核心论点 ↔ 依据事实（多对多）';

UPDATE "desktopRoutes" SET title = '核心论点' WHERE title = '论点与辩论';
UPDATE "flowModels"
   SET options = replace(replace(replace(options::text, '"declaredKey":"论点与辩论', chr(1)), '论点与辩论', '核心论点'), chr(1), '"declaredKey":"论点与辩论')::json
 WHERE options::text LIKE '%论点与辩论%';
UPDATE "flowModelTemplates" SET name = replace(name, '论点与辩论', '核心论点'), description = replace(description, '论点与辩论', '核心论点')
 WHERE name LIKE '%论点与辩论%' OR description LIKE '%论点与辩论%';
COMMIT;
