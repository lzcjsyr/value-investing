-- 2026-10-23（晚）：经营分部新增“直接估值”方法所需的列。在线库执行一次；空库重建用 01_schema.sql。
BEGIN;
ALTER TABLE vi_sotp_segment_base ADD COLUMN IF NOT EXISTS direct_value double precision;
COMMENT ON COLUMN vi_sotp_segment_base.direct_value IS '直接估值（亿元）：直接估值：按可比公司、交易价格或主观判断给出的整体价值（已含该业务未来的投入与回报），不折现';
COMMIT;
