-- 公司表增加市场口径的市盈率TTM、市净率及其日期（2026-10-27）。数值由 framework/tools/pe_pb.py 经 akshare 写入，驾驶舱顶部显示。
-- 执行后重跑 03_ui.sql（重建 vi_company 视图与写入触发器），再 register.py。
BEGIN;
ALTER TABLE vi_company_base ADD COLUMN IF NOT EXISTS pe_ttm double precision,
                            ADD COLUMN IF NOT EXISTS pb double precision,
                            ADD COLUMN IF NOT EXISTS pe_pb_date date;
COMMENT ON COLUMN vi_company_base.pe_ttm IS '市盈率TTM：市场口径（A 股东方财富、港股百度股市通），由 tools/pe_pb.py 经 akshare 写入；驾驶舱顶部显示';
COMMENT ON COLUMN vi_company_base.pb IS '市净率：同上，市场口径的最新市净率';
COMMENT ON COLUMN vi_company_base.pe_pb_date IS '市盈率/市净率日期：上面两个数对应的交易日';
COMMIT;
