-- 四个业务对象的中文名称以前端为准；仅更新注释。
BEGIN;
COMMENT ON TABLE vi_biz_model_base IS '商业模式拆解：商业模式画布 9 项，每家公司一项一行（B1—B9 按画布顺序）。投资者关心的内容放进画布：盈利公式的收入一侧、收入结构、单价、增长与周期写在“收入来源”；盈利公式的成本一侧、成本构成、单位利润、资本需求与现金循环写在“成本结构”。只写事实与机制；有争议、决定价值的判断写在核心论点里。';
COMMENT ON TABLE vi_fit_score_base IS '价投适配度：长坡、厚雪、慢变、护城河、再投资、财务质量、治理配置、可估值性，各 0—5 分。总分 32—40 适合复利框架，22—31 可研究，21 以下通常不符合价值投资标准。';
COMMENT ON TABLE vi_fin_history_base IS '财务数据：年报口径的历史数据。空白＝尚未取得，不是 0。派生指标（单价、派息率、同比等）自动计算。';
COMMENT ON TABLE vi_period_data_base IS '经营数据：公司定期披露的经营指标，如销量、订单、用户数、交付量与发电量。区分单季、累计和期末口径；经营解读记录研究判断，披露摘要保留事实与统计口径。';
COMMENT ON TABLE vi_lnk_biz_model_facts IS '商业模式拆解 ↔ 依据事实（多对多）';
COMMENT ON TABLE vi_lnk_fit_score_theses IS '价投适配度 ↔ 相关论点（多对多）';
COMMENT ON VIEW vi_biz_model IS '商业模式拆解（界面视图：输入列＋自动计算列）';
COMMENT ON VIEW vi_fit_score IS '价投适配度（界面视图：输入列＋自动计算列）';
COMMENT ON VIEW vi_fin_history IS '财务数据（界面视图：输入列＋自动计算列）';
COMMENT ON VIEW vi_period_data IS '经营数据（界面视图：输入列＋自动计算列）';
COMMIT;
