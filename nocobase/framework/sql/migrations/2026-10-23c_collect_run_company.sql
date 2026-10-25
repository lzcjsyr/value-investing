-- 2026-10-23（晚）：采集运行加“公司”。驾驶舱按钮只采这家公司和通用指标（利率、汇率等）的数据源。
-- 在线库执行一次，然后重跑 02、03；空库重建用 01_schema.sql。
BEGIN;
ALTER TABLE vi_collect_run_base ADD COLUMN IF NOT EXISTS company_id bigint REFERENCES vi_company_base(id) ON DELETE SET NULL;
CREATE INDEX IF NOT EXISTS vi_collect_run_base_company_id_idx ON vi_collect_run_base (company_id);
COMMENT ON COLUMN vi_collect_run_base.company_id IS '公司（关联 公司）';
COMMENT ON TABLE vi_collect_run_base IS '采集运行：每按一次“立即采集”新增一行，触发“④ 手动采集”工作流跑完 采集→入库→自检；有公司时只采这家公司和通用指标，结果按本次的原始记录自动统计。';
COMMIT;
