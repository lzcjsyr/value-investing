-- Keep existing views and their column order for live installations.
BEGIN;
ALTER TABLE vi_fin_stmt_base ADD COLUMN IF NOT EXISTS currency text, ADD COLUMN IF NOT EXISTS unit text;
COMMENT ON TABLE vi_fin_stmt_base IS '财务报表：公司的季度三大报表原值；被【资产负债重估】【调整后利润表】【历史年度】【指标数值】【质量自检】引用。季度完整三大报表（资产负债表、利润表、现金流量表），一行＝公司×报表×报告期×科目，金额为报表原值折亿元。合并报表科目以这里为准，由 tools/fin_stmt.py 取数检验后入库，不手录（A 股用新浪财报，小米用东方财富，均经 akshare；腾讯音乐用 SEC 文件及公司业绩公告）。空白科目＝该期未披露。资产负债表是时点余额；利润表/现金流量表是年初至报告期末的累计数。';
COMMENT ON COLUMN vi_fin_stmt_base.amount IS '数值：一般金额按亿元，每股数据按元/股';
COMMENT ON COLUMN vi_fin_stmt_base.currency IS '列报币种：ISO 币种代码，如 CNY、USD、HKD';
COMMENT ON COLUMN vi_fin_stmt_base.unit IS '单位：数值实际使用的单位，如 亿元、元/股；空表示待核对';

-- 旧快照未记录币种和单位。普通金额沿用既有亿元口径；
-- 历史每股收益曾按金额缩放，须由源数值明确写入单位。
CREATE OR REPLACE FUNCTION vi_fin_stmt_fill_units() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.currency IS NULL THEN
    SELECT CASE currency WHEN '人民币' THEN 'CNY' WHEN '港元' THEN 'HKD' WHEN '美元' THEN 'USD'
                         ELSE currency END
      INTO NEW.currency FROM vi_company_base WHERE id = NEW.company_id;
  END IF;
  IF NEW.unit IS NULL AND NEW.item !~ '每股' THEN
    NEW.unit := '亿元';
  END IF;
  RETURN NEW;
END $$;

DROP TRIGGER IF EXISTS vi_fin_stmt_fill_units ON vi_fin_stmt_base;
CREATE TRIGGER vi_fin_stmt_fill_units BEFORE INSERT OR UPDATE ON vi_fin_stmt_base
FOR EACH ROW EXECUTE FUNCTION vi_fin_stmt_fill_units();

UPDATE vi_fin_stmt_base
SET currency = currency, unit = unit
WHERE currency IS NULL OR (unit IS NULL AND item !~ '每股');

CREATE OR REPLACE VIEW vi_fin_stmt AS
SELECT b.id, b.period, b.period_end, b.stmt, b.item, b.seq, b.amount, b.company_id, b.updated_at, b.currency, b.unit
FROM vi_fin_stmt_base b;

CREATE OR REPLACE FUNCTION vi_fin_stmt_dml() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO vi_fin_stmt_base (period, period_end, stmt, item, seq, amount, currency, unit, company_id) VALUES (NEW.period, NEW.period_end, NEW.stmt, NEW.item, NEW.seq, NEW.amount, NEW.currency, NEW.unit, NEW.company_id) RETURNING id INTO NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE vi_fin_stmt_base SET period = NEW.period, period_end = NEW.period_end, stmt = NEW.stmt, item = NEW.item, seq = NEW.seq, amount = NEW.amount, currency = NEW.currency, unit = NEW.unit, company_id = NEW.company_id WHERE id = OLD.id;
    RETURN NEW;
  ELSE
    DELETE FROM vi_fin_stmt_base WHERE id = OLD.id;
    RETURN OLD;
  END IF;
END $$;

COMMIT;
