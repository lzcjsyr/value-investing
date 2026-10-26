-- 跟踪事项重构（2026-10-26）：每条服务于论点或估值参数，写明取数方式、模型基准与触发上下限，状态自动判断。
-- 结构：新增 purpose、fetch_method、compare、baseline、lower、upper 与“验证的论点”关联；frequency 改为固定选项；去掉 nature（每行同一句话，挪进表说明）。
-- 执行后依次跑 02_calc.sql、03_ui.sql、register.py。
BEGIN;
ALTER TABLE vi_watch_base ADD COLUMN IF NOT EXISTS purpose text;
ALTER TABLE vi_watch_base ADD COLUMN IF NOT EXISTS fetch_method text;
ALTER TABLE vi_watch_base ADD COLUMN IF NOT EXISTS compare text DEFAULT '数值';
ALTER TABLE vi_watch_base ADD COLUMN IF NOT EXISTS baseline double precision;
ALTER TABLE vi_watch_base ADD COLUMN IF NOT EXISTS lower double precision;
ALTER TABLE vi_watch_base ADD COLUMN IF NOT EXISTS upper double precision;
CREATE TABLE IF NOT EXISTS vi_lnk_watch_theses (
  watch_id bigint NOT NULL REFERENCES vi_watch_base(id) ON DELETE CASCADE,
  thesis_id bigint NOT NULL REFERENCES vi_thesis_base(id) ON DELETE CASCADE,
  "createdAt" timestamptz NOT NULL DEFAULT now(),
  "updatedAt" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (watch_id, thesis_id)
);
UPDATE vi_watch_base SET compare = '数值' WHERE compare IS NULL;
-- 取数方式：指标有启用的采集配置＝自动采集；有指标＝手动录入；否则先记为手动录入（待逐条补指标）
UPDATE vi_watch_base w SET fetch_method = CASE
    WHEN EXISTS (SELECT 1 FROM vi_collector_base k WHERE k.metric_id = w.metric_id AND k.enabled) THEN '自动采集'
    ELSE '手动录入' END
WHERE fetch_method IS NULL;
-- 频率：自由文本 → 固定选项（原文挪进触发条件说明前面，不丢信息）
UPDATE vi_watch_base SET trigger = '（原频率：' || frequency || '）' || coalesce(trigger, '')
WHERE frequency IS NOT NULL AND frequency NOT IN ('交易日', '周', '月', '季', '半年', '年', '不定期');
UPDATE vi_watch_base SET frequency = CASE
    WHEN frequency ~ '季度披露' THEN '季'
    WHEN frequency ~ '交易日|工作日|每日' THEN '交易日'
    WHEN frequency ~ '月' THEN '月'
    WHEN frequency ~ '周' THEN '周'
    WHEN frequency ~ '半年' THEN '半年'
    WHEN frequency ~ '季' THEN '季'
    WHEN frequency ~ '年' THEN '年'
    ELSE '不定期' END
WHERE frequency IS NOT NULL AND frequency NOT IN ('交易日', '周', '月', '季', '半年', '年', '不定期');
ALTER TABLE vi_watch_base DROP COLUMN IF EXISTS nature CASCADE;
COMMIT;
