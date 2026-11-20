# 在线库迁移

本机已执行的迁移：
- `2026-11-11b_hurdle.sql`：统一设置（门槛，全部公司共用）。
- `2026-11-11c_restructure.sql`：估值按 Greenwald 三层重构——建新表、搬数据、删旧估值表（由 `../../tools/restructure_20261111.py` 生成，一次性）。
- `2026-11-11d_epv_statement.sql`：取消估值情景，将第二层改为逐行的调整后利润表。
- `2026-11-12_av_company.sql`：第一层资产价值改为公司口径，资产负债重估按科目类别归集。

- `2026-11-19_fin_stmt_units.sql`：财务报表增加列报币种和单位，兼容旧报表快照。

空库重建不需要它们：直接用 `01_schema.sql`（spec 生成）＋各公司 `seed.sql`、`greenwald.sql`。
