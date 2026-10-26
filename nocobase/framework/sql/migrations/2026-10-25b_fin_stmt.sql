-- 2026-10-25b：财务数据改为季度完整三大报表（表代码 fin_stmt，长表），年度表更名“年度关键项”。
-- 从 gen_sql.py 生成的 01_schema.sql / 03_ui.sql 挑出 fin_stmt 语句，并同步 vi_fin_history 的新注释。
-- 数据来源与检验见 framework/tools/fin_stmt.py（akshare：A 股＝新浪财报，港股＝东方财富港股报表）。
BEGIN;

CREATE TABLE vi_fin_stmt_base (
  id bigserial PRIMARY KEY,
  period text,
  period_end date,
  stmt text,
  item text,
  seq integer,
  amount double precision,
  company_id bigint,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE vi_fin_stmt_base IS '财务数据：季度完整三大报表（资产负债表、利润表、现金流量表），一行＝公司×报表×报告期×科目，金额为报表原值折亿元。A 股来自新浪财报、港股来自东方财富港股报表（都经 akshare），取数与检验见 tools/fin_stmt.py。空白科目＝该期未披露。资产负债表是时点余额；利润表/现金流量表是年初至报告期末的累计数。';

COMMENT ON COLUMN vi_fin_stmt_base.period IS '报告期：如 2025Q3；Q4 即年报口径';

COMMENT ON COLUMN vi_fin_stmt_base.period_end IS '期末日期';

COMMENT ON COLUMN vi_fin_stmt_base.stmt IS '报表（可选：资产负债表、利润表、现金流量表）';

COMMENT ON COLUMN vi_fin_stmt_base.item IS '科目：报表科目中文原名';

COMMENT ON COLUMN vi_fin_stmt_base.seq IS '行次：科目在报表内的顺序';

COMMENT ON COLUMN vi_fin_stmt_base.amount IS '金额（亿元）：报表原值÷1e8，累计口径';

COMMENT ON COLUMN vi_fin_stmt_base.company_id IS '公司（关联 公司）';

CREATE TRIGGER vi_fin_stmt_base_touch BEFORE UPDATE ON vi_fin_stmt_base FOR EACH ROW EXECUTE FUNCTION vi_touch_updated_at();

ALTER TABLE vi_fin_stmt_base ADD FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE SET NULL;

CREATE INDEX ON vi_fin_stmt_base (company_id);

ALTER TABLE vi_fin_stmt_base ADD CONSTRAINT vi_fin_stmt_uniq UNIQUE (company_id, stmt, period_end, item);

DROP VIEW IF EXISTS vi_fin_stmt CASCADE;

CREATE VIEW vi_fin_stmt AS
SELECT b.id,
       b.period,
       b.period_end,
       b.stmt,
       b.item,
       b.seq,
       b.amount,
       b.company_id,
       b.updated_at
FROM vi_fin_stmt_base b;

COMMENT ON VIEW vi_fin_stmt IS '财务数据（界面视图：输入列＋自动计算列）';

CREATE OR REPLACE FUNCTION vi_fin_stmt_dml() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO vi_fin_stmt_base (period, period_end, stmt, item, seq, amount, company_id) VALUES (NEW.period, NEW.period_end, NEW.stmt, NEW.item, NEW.seq, NEW.amount, NEW.company_id) RETURNING id INTO NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE vi_fin_stmt_base SET period = NEW.period, period_end = NEW.period_end, stmt = NEW.stmt, item = NEW.item, seq = NEW.seq, amount = NEW.amount, company_id = NEW.company_id WHERE id = OLD.id;
    RETURN NEW;
  ELSE
    DELETE FROM vi_fin_stmt_base WHERE id = OLD.id;
    RETURN OLD;
  END IF;
END $$;

CREATE TRIGGER vi_fin_stmt_dml INSTEAD OF INSERT OR UPDATE OR DELETE ON vi_fin_stmt FOR EACH ROW EXECUTE FUNCTION vi_fin_stmt_dml();

-- 年度表更名“年度关键项”（原“财务数据”），注释与前端名称一致
COMMENT ON TABLE vi_fin_history_base IS '年度关键项：年度口径的关键项目，是预测与估值的输入（业务量、分红、带息负债等非报表项也在这里）。季度完整三大报表见「财务数据」。空白＝尚未取得，不是 0。派生指标（单价、派息率、同比等）自动计算。';

COMMENT ON VIEW vi_fin_history IS '年度关键项（界面视图：输入列＋自动计算列）';

COMMIT;
