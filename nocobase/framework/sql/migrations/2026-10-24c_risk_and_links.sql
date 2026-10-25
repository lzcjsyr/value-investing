-- 2026-10-24（第三次）：商业模式内部关联按投研习惯收敛＋新增风险分析表。
--   1. 新表 vi_risk（风险分析）及 4 张关联表：会削弱的论点、估值对应的假设依据、预警跟踪事项、依据事实。
--   2. 删除 壁垒 ↔ 竞争对手 关联（谁在复制壁垒属于论点里的论证；竞争对手只挂在产业链环节下）。
--   3. 论点类别“风险”改为“估值”（不利事件进风险分析表）；中国建筑 T8 减值→财务，小米 T9 安全边际→估值。
--   4. 论点“对模型的影响”去掉与“相关假设依据”关联重复的编号，只留关联之外的说明；长江电力 T1 补上文字里有、关联里缺的 J-P。
-- 在线库执行顺序：先在 NocoBase 里删掉 vi_moat 的 competitors 字段，再执行本文件，然后重跑 02、03，register.py，重启 app。
-- 空库重建不需要它：01_schema.sql 已是新结构。
BEGIN;

-- 1. 风险分析
CREATE TABLE vi_risk_base (
  id bigserial PRIMARY KEY,
  code text,
  title text,
  category text,
  mechanism text,
  probability text,
  impact text,
  horizon text,
  trend text,
  impact_estimate text,
  mitigants text,
  treatment text,
  early_warning text,
  response text,
  status text,
  company_id bigint,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE vi_risk_base IS '风险分析：会让这笔投资亏钱的不利事件：传导路径、可能性×冲击（自动定级）、量化影响、缓冲因素、在估值里怎么处理、预警信号与触发后应对。风险是论点失败或外部冲击的“事件”，论证本身仍在论点与辩论里，这里只关联会被削弱的论点；落到参数的关联假设依据，盯什么关联跟踪事项。';

COMMENT ON COLUMN vi_risk_base.code IS '编号：如 R1';

COMMENT ON COLUMN vi_risk_base.title IS '风险：写成会发生的不利事件，如“连续枯水：年发电量两年以上低于 2,700 亿千瓦时”';

COMMENT ON COLUMN vi_risk_base.category IS '类别（可选：行业与竞争、技术与替代、经营与执行、财务与资产质量、政策与监管、治理与资本配置、宏观与环境、估值与市场）';

COMMENT ON COLUMN vi_risk_base.mechanism IS '传导路径：从事件到收入、利润、现金、估值的路径';

COMMENT ON COLUMN vi_risk_base.probability IS '可能性：未来三年内发生的可能性（可选：高、中、低）';

COMMENT ON COLUMN vi_risk_base.impact IS '冲击：发生后对每股价值的冲击：高＝超过 20%，中＝5%—20%，低＝5% 以内（可选：高、中、低）';

COMMENT ON COLUMN vi_risk_base.horizon IS '时间窗口（可选：1 年内、1—3 年、3 年以上）';

COMMENT ON COLUMN vi_risk_base.trend IS '趋势（可选：上升、稳定、下降）';

COMMENT ON COLUMN vi_risk_base.impact_estimate IS '影响测算：能量化的写数：对利润、现金或每股价值的影响（可引用单参数试验、情景）';

COMMENT ON COLUMN vi_risk_base.mitigants IS '缓冲因素：什么能限制损失';

COMMENT ON COLUMN vi_risk_base.treatment IS '估值处理：这项风险在估值里怎么体现；未计入的要在影响测算里说明为什么（可选：已计入基准情景、已计入悲观情景、体现在折现率、未计入估值）';

COMMENT ON COLUMN vi_risk_base.early_warning IS '预警信号：看什么、到什么程度算预警；已建跟踪事项的在“预警跟踪事项”里关联';

COMMENT ON COLUMN vi_risk_base.response IS '触发后应对：复核哪条论点或假设依据、要不要改参数（研究预警，不是交易指令）';

COMMENT ON COLUMN vi_risk_base.status IS '状态（可选：监控中、已部分发生、已发生、已缓解、已解除）';

COMMENT ON COLUMN vi_risk_base.company_id IS '公司（关联 公司）';

CREATE TRIGGER vi_risk_base_touch BEFORE UPDATE ON vi_risk_base FOR EACH ROW EXECUTE FUNCTION vi_touch_updated_at();

ALTER TABLE vi_risk_base ADD FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE SET NULL;

CREATE INDEX ON vi_risk_base (company_id);

ALTER TABLE vi_risk_base ADD CONSTRAINT vi_risk_uniq UNIQUE (company_id, code);

CREATE TABLE vi_lnk_risk_theses (
  risk_id bigint NOT NULL REFERENCES vi_risk_base(id) ON DELETE CASCADE,
  thesis_id bigint NOT NULL REFERENCES vi_thesis_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (risk_id, thesis_id)
);

COMMENT ON TABLE vi_lnk_risk_theses IS '风险分析 ↔ 会削弱的论点（多对多）';

CREATE TABLE vi_lnk_risk_judgments (
  risk_id bigint NOT NULL REFERENCES vi_risk_base(id) ON DELETE CASCADE,
  judgment_id bigint NOT NULL REFERENCES vi_judgment_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (risk_id, judgment_id)
);

COMMENT ON TABLE vi_lnk_risk_judgments IS '风险分析 ↔ 估值对应的假设依据（多对多）';

CREATE TABLE vi_lnk_risk_watches (
  risk_id bigint NOT NULL REFERENCES vi_risk_base(id) ON DELETE CASCADE,
  watch_id bigint NOT NULL REFERENCES vi_watch_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (risk_id, watch_id)
);

COMMENT ON TABLE vi_lnk_risk_watches IS '风险分析 ↔ 预警跟踪事项（多对多）';

CREATE TABLE vi_lnk_risk_facts (
  risk_id bigint NOT NULL REFERENCES vi_risk_base(id) ON DELETE CASCADE,
  fact_id bigint NOT NULL REFERENCES vi_fact_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (risk_id, fact_id)
);

COMMENT ON TABLE vi_lnk_risk_facts IS '风险分析 ↔ 依据事实（多对多）';

-- 2. 壁垒 ↔ 竞争对手
-- 关联里有、文字里没写的对照对手并入“复制难度”，再删关联表
UPDATE vi_moat_base SET replication = CASE WHEN trim(coalesce(replication, '')) IN ('', '—') THEN '对照对手：Suzano。' ELSE replication || '对照对手：Suzano。' END WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '002078.SZ') AND code = 'M1';
UPDATE vi_moat_base SET replication = CASE WHEN trim(coalesce(replication, '')) IN ('', '—') THEN '对照对手：Suzano。' ELSE replication || '对照对手：Suzano。' END WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '002078.SZ') AND code = 'M8';
UPDATE vi_moat_base SET replication = CASE WHEN trim(coalesce(replication, '')) IN ('', '—') THEN '对照对手：Spotify。' ELSE replication || '对照对手：Spotify。' END WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND code = 'M1';
UPDATE vi_moat_base SET replication = CASE WHEN trim(coalesce(replication, '')) IN ('', '—') THEN '对照对手：汽水音乐。' ELSE replication || '对照对手：汽水音乐。' END WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND code = 'M3';
UPDATE vi_moat_base SET replication = CASE WHEN trim(coalesce(replication, '')) IN ('', '—') THEN '对照对手：鸿蒙智行（赛力斯等）。' ELSE replication || '对照对手：鸿蒙智行（赛力斯等）。' END WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND code = 'M5';
UPDATE vi_moat_base SET replication = CASE WHEN trim(coalesce(replication, '')) IN ('', '—') THEN '对照对手：苹果、三星电子。' ELSE replication || '对照对手：苹果、三星电子。' END WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND code = 'M7';
UPDATE vi_moat_base SET replication = CASE WHEN trim(coalesce(replication, '')) IN ('', '—') THEN '对照对手：华为、苹果、智谱、MiniMax、月之暗面（Kimi）、DeepSeek。' ELSE replication || '对照对手：华为、苹果、智谱、MiniMax、月之暗面（Kimi）、DeepSeek。' END WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK') AND code = 'M8';
UPDATE vi_moat_base SET replication = CASE WHEN trim(coalesce(replication, '')) IN ('', '—') THEN '对照对手：华能水电、国投电力（雅砻江水电）、中国雅江集团（雅下水电）。' ELSE replication || '对照对手：华能水电、国投电力（雅砻江水电）、中国雅江集团（雅下水电）。' END WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '600900.SH') AND code = 'M1';
UPDATE vi_moat_base SET replication = CASE WHEN trim(coalesce(replication, '')) IN ('', '—') THEN '对照对手：受电省份的煤电与新能源。' ELSE replication || '对照对手：受电省份的煤电与新能源。' END WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '600900.SH') AND code = 'M2';
UPDATE vi_moat_base SET replication = CASE WHEN trim(coalesce(replication, '')) IN ('', '—') THEN '对照对手：华能水电。' ELSE replication || '对照对手：华能水电。' END WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '600900.SH') AND code = 'M3';
UPDATE vi_moat_base SET replication = CASE WHEN trim(coalesce(replication, '')) IN ('', '—') THEN '对照对手：中国中铁、中国铁建、上海建工。' ELSE replication || '对照对手：中国中铁、中国铁建、上海建工。' END WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '601668.SH') AND code = 'M1';
UPDATE vi_moat_base SET replication = CASE WHEN trim(coalesce(replication, '')) IN ('', '—') THEN '对照对手：中国中铁、中国交建。' ELSE replication || '对照对手：中国中铁、中国交建。' END WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '601668.SH') AND code = 'M4';
UPDATE vi_moat_base SET replication = replace(replication, '）对照对手：', '）。对照对手：') WHERE replication LIKE '%）对照对手：%';
DROP TABLE IF EXISTS vi_lnk_moat_competitors;

-- 3. 论点类别
UPDATE vi_thesis_base SET category = '财务' WHERE category = '风险' AND code = 'T8' AND company_id = (SELECT id FROM vi_company_base WHERE code = '601668.SH');
UPDATE vi_thesis_base SET category = '估值' WHERE category = '风险' AND code = 'T9' AND company_id = (SELECT id FROM vi_company_base WHERE code = '01810.HK');

-- 4. 对模型的影响：只留关联之外的说明
INSERT INTO vi_lnk_judgment_theses (judgment_id, thesis_id, "createdAt", "updatedAt")
SELECT j.id, t.id, now(), now() FROM vi_judgment_base j JOIN vi_thesis_base t ON t.company_id = j.company_id
WHERE j.company_id = (SELECT id FROM vi_company_base WHERE code = '600900.SH') AND j.code = 'J-P' AND t.code = 'T1'
ON CONFLICT DO NOTHING;
UPDATE vi_thesis_base t SET model_impact = v.txt
FROM (VALUES
  ('600900.SH', 'T4', '所得税率不在假设依据里，见问题清单 Q11'),
  ('600900.SH', 'T5', '派息率直接写在逐年假设里'),
  ('601668.SH', 'T7', '不单独改参数'),
  ('01698.HK', 'T1', '不改参数'),
  ('01698.HK', 'T2', '不改参数'),
  ('01698.HK', 'T4', '不改参数'),
  ('01698.HK', 'T5', '派息率（股东回报率）是第一跟踪项'),
  ('01810.HK', 'T6', '股东回报折现的现金桥接见逐年假设；经营分部估值不依赖这一比率'),
  ('01810.HK', 'T9', '关注价按基准情景；C17 显示市场隐含的成熟业务倍数与汽车价值')
) v(co, code, txt)
WHERE t.company_id = (SELECT id FROM vi_company_base WHERE code = v.co) AND t.code = v.code;
UPDATE vi_thesis_base t SET model_impact = NULL
WHERE NOT EXISTS (SELECT 1 FROM (VALUES ('600900.SH', 'T4'), ('600900.SH', 'T5'), ('601668.SH', 'T7'), ('01698.HK', 'T1'), ('01698.HK', 'T2'),
                                        ('01698.HK', 'T4'), ('01698.HK', 'T5'), ('01810.HK', 'T6'), ('01810.HK', 'T9')) k(co, code)
                  WHERE t.company_id = (SELECT id FROM vi_company_base WHERE code = k.co) AND t.code = k.code);

COMMIT;
