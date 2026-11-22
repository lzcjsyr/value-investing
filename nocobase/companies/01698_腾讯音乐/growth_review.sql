-- 腾讯音乐第三层的研究记录。可单独执行；完整估值种子也在同一事务内执行此段。
DO $review$
DECLARE
  co bigint; growth_row bigint; disclosure bigint; item record; j_id bigint;
  q3_title text := '2026 年第三季度未经审计财务业绩公告';
  q3_url text := 'https://ir.tencentmusic.com/2026-11-17-Tencent-Music-Entertainment-Group-Announces-Third-Quarter-2026-Unaudited-Financial-Results';
BEGIN
  SELECT id INTO STRICT co FROM vi_company_base WHERE code='01698.HK' FOR UPDATE;
  SELECT g.id INTO STRICT growth_row FROM vi_growth_base g JOIN vi_business_base b ON b.id=g.business_id
    WHERE g.company_id=co AND b.company_id=co AND b.code='B1';

  SELECT id INTO disclosure FROM vi_source_base WHERE company_id=co AND url=q3_url;
  IF disclosure IS NULL THEN
    INSERT INTO vi_source_base (company_id,title,source_type,publisher,publish_date,url,reliability,verify_status,retrieved_on)
      VALUES (co,q3_title,'定期报告','腾讯音乐','2026-11-17',q3_url,'一级·法定披露','已读原文','2026-11-18') RETURNING id INTO disclosure;
  END IF;
  INSERT INTO vi_fact_base (company_id,title,category,statement,period,as_of,verify_status,source_id)
    SELECT co,'三季度并表与收入组合','经营',
      '公司把音乐相关服务的增长归因于喜马拉雅并表，以及艺人周边和演出。会员收入同比增长 9.2%，含长音频。集团毛利率由 43.5% 降至 42.8%，公司解释为业务组合变化。公告未单列原音乐会员的同口径增速。',
      '2026Q3','2026-09-30','已核验',disclosure
    WHERE NOT EXISTS (SELECT 1 FROM vi_fact_base WHERE company_id=co AND source_id=disclosure AND title='三季度并表与收入组合');

  FOR item IN SELECT * FROM (VALUES
    ('J-GROW','可持续盈利能增长多快','可持续盈利增速 g',
     '2026Q3 会员收入 49.85 亿元，同比增 9.2%，含喜马拉雅。营销及消费收入 26.97 亿元，社交娱乐等 12.59 亿元。2025Q4 付费用户和月均付费额分别增长 5.3%、7.2%，两项均已停按季披露。',
     '沿用第二层正常化收入基线 349.06 亿元（会员 199.40、营销及消费 TTM 99.30、社交娱乐 50.36 亿元），先按三条收入线估经营利润。会员年增 2%，反映付费升级同时受免费产品分流。营销及消费服务前三年增 10%、后七年增 6%，反映演出与周边从较小基数扩张后放缓。社交娱乐每年收缩 8%，接近 2025 全年降幅 7.3%。这些均为十年推演假设。',
     '按第二层三条正常化收入（会员 199.40、营销及消费 99.30、社交娱乐 50.36 亿元），以 42%、15%、16% 的研究分摊利润率估基期经营利润 106.71 亿元。十年后分别为 102.09、29.82、3.50 亿元，合计 135.41 亿元。十年复合约 2.41%，按半个百分点取整为 2.5%。利润率沿用研究分摊，税率、归母比例及维持性投入相对稳定，才可把利润增速用于第二层现金收益 E。三块利润仅用来估增长速度。',
     '若并表周年后会员收入在可比口径下连续两年增速低于 1% 或高于 5%，重做会员行。若低毛利业务占比上升且集团毛利率连续两季同比降至少 2 个百分点，先复核利润率，再算 g。',
     '单季热门演出、并表首年收入跳升，单独看都不足以调高长期 g。缺少有机拆分时保留未知。',
     '2026Q3 合并会员增长，但营销及消费增长伴随毛利率下降。固定利润率会高估经营杠杆，尤其在演出和周边替代高毛利会员时。',
     ARRAY['停披决定','并表与收入贡献','社交娱乐收缩','三季度并表与收入组合'],ARRAY['会员（订阅）收入','非订阅音乐收入（广告、演出、周边）','社交娱乐及其他收入','毛利率'],ARRAY['T1','T3','T4']),
    ('J-GROW-R','新增投入能赚多少','新增投资税后回报 RONIC',
     'Q3 剔除商誉后经营投入资本较低。现有平台可复用曲库与分发渠道，但喜马拉雅交易需要支付对价，新增内容、渠道投放和演出也占用资源。公司未披露按项目、按投入年份配对的税后回报。',
     '15% 是对现有平台承接会员升级与相邻业务的待验证判断。存量 ROIC 包含旧曲库和存量用户优势，仅作横向参照。演出垫资、推广投放、版权保底和收购溢价都可能拉低下一笔资本的回报。',
     '隐含再投入率＝g÷RONIC。应按投入批次，将新增税后经营收益与前期增长投入配对。分母包括增长性资本开支、营运资金增量、增长性内容和获客投入，收购按总对价含股份。区分维持性成本与增长性费用，对已在经营收益扣过的增长费用先统一口径，以免重复扣减。两至三年观察兑现，资料不足时保留缺口。',
     '若连续两个可比年度的新增税后收益÷对应增长投入低于假设，按可归因的实际回报重估。若新增投入只能赚到门槛，增长溢价归零；低于门槛且继续投入时计入负值。',
     '单期收购会计摊销、商誉减值或一次营运资金释放，均不足以单独判定新增回报。',
     '轻资产可能只是把获客与版权投入费用化。缺少并购后独立税后盈利和有机投入拆分，15% 目前无法由财报直接验证。',
     ARRAY['交易对价与商誉','一季度加大获客','毛利率提升原因与展望','三季度并表与收入组合'],ARRAY['资本开支','销售费用率','毛利率'],ARRAY['T1','T4','T6']),
    ('J-GROW-N','超额回报可以维持多久','竞争优势持续期 N',
     '2025Q4 在线音乐月活同比下降 5.0%，付费用户仍增 5.3%。公司披露与华纳续约，说明曲库合作可以延续。2026Q3 公司称超级会员继续增长，也披露演出与周边占比上升压低毛利。曲库合作需要续约，版权成本和用户迁移仍要跟踪。',
     '规模采购、付费曲库和超级会员可支撑存量业务。10 年是十年研究窗口内壁垒持续的参考假设，证据较弱。它要求多轮版权续约后仍有议价权，且免费替代未持续侵蚀付费核心。第 11 年起模型按届时收益水平资本化，新增投资不再获得超额回报。',
     '将新增投资有超额回报的年份从 10 年缩到 5 年，只改变未来新增投资的价值。若竞争也削弱已形成的盈利，应单独下修第二层 E，再估第三层。',
     '每年复核同口径会员增长和内容成本。若年报付费用户连续两年下降，或核心授权续约明显提高保底且无法向用户提价转嫁，先用 5 年重算。规模采购优势消失时，用新增回报等于门槛复核。',
     '单季应用下载排名或未经核实的竞品月活，只作线索。优先看公司付费收入、版权条款及可比利润率。',
     '免费产品可抢走轻度用户，新一代用户也可能不再迁入付费层。历史曲库优势向长音频、演出或周边延伸的证据有限。',
     ARRAY['停披决定','上游分散与版权分成','汽水音乐规模与定价','三季度并表与收入组合'],ARRAY['在线音乐付费用户','会员（订阅）收入','毛利率'],ARRAY['T1','T3','T4'])
  ) AS r(code,title,parameter,fact_layer,judgment,transmission,change_threshold,no_change_condition,counter_evidence,facts,metrics,theses)
  LOOP
    INSERT INTO vi_judgment_base (company_id,code,title,parameter,fact_layer,judgment,transmission,change_threshold,no_change_condition,counter_evidence,status)
      VALUES (co,item.code,item.title,item.parameter,item.fact_layer,item.judgment,item.transmission,item.change_threshold,item.no_change_condition,item.counter_evidence,'已形成建议')
      ON CONFLICT (company_id,code) DO UPDATE SET title=excluded.title, parameter=excluded.parameter,
        fact_layer=excluded.fact_layer, judgment=excluded.judgment, transmission=excluded.transmission,
        change_threshold=excluded.change_threshold,no_change_condition=excluded.no_change_condition,counter_evidence=excluded.counter_evidence
      RETURNING id INTO j_id;
    INSERT INTO vi_lnk_growth_judgments (growth_id,judgment_id,"createdAt","updatedAt") VALUES (growth_row,j_id,now(),now()) ON CONFLICT DO NOTHING;
    INSERT INTO vi_lnk_judgment_facts (judgment_id,fact_id,"createdAt","updatedAt")
      SELECT j_id,id,now(),now() FROM vi_fact_base WHERE company_id=co AND title=ANY(item.facts) ON CONFLICT DO NOTHING;
    INSERT INTO vi_lnk_judgment_basis_metrics (judgment_id,metric_id,"createdAt","updatedAt")
      SELECT j_id,id,now(),now() FROM vi_metric_base WHERE company_id=co AND name=ANY(item.metrics) ON CONFLICT DO NOTHING;
    INSERT INTO vi_lnk_judgment_theses (judgment_id,thesis_id,"createdAt","updatedAt")
      SELECT j_id,id,now(),now() FROM vi_thesis_base WHERE company_id=co AND code=ANY(item.theses) ON CONFLICT DO NOTHING;
  END LOOP;
END $review$;
