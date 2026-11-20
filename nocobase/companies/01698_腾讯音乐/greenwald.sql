-- 自动生成：framework/greenwald_seed.py。三层估值：估值设置、业务口径、假设依据、资产负债重估、调整后利润表、增长
BEGIN;
UPDATE vi_company_base SET as_of = '2026-09-30', shares = 31.38478643, value_layer = '盈利能力价值', av_basis = '调整后净资产', repro_cost = NULL, notes = '2026Q3 官方业绩公告为资产负债及经营数据基准。每股价值用 Q3 基本加权平均普通股数 31.38 亿股作分母代理。Q3 公告未拆出投资应付款、当期汇出税估算或维持性资本开支，相关估值假设见各行。每股均为普通股口径，1 ADS 对应 2 股。', layer_reason = '轻资产平台，资产价值说明不了价值；增长取决于优势能维持多久（T3、T4 未定），先以不增长的盈利能力价值作结论，增长只作参照。见 J-LAYER。' WHERE id = (SELECT id FROM vi_company_base WHERE code = '01698.HK');
DELETE FROM vi_bs_item_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK');
DELETE FROM vi_epv_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK');
DELETE FROM vi_growth_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK');
INSERT INTO vi_business_base (company_id, code, name, boundary, asset_boundary, sort, capital_basis) VALUES ((SELECT id FROM vi_company_base WHERE code = '01698.HK'), 'B1', '在线音乐与音频娱乐平台', 'QQ 音乐、酷狗、酷我、全民 K 歌、懒人听书等：会员订阅、非订阅音乐（广告、演出、周边、艺人经纪）、社交娱乐（直播打赏）三条收入线共用用户、曲库与团队。', NULL, 1, '企业') ON CONFLICT (company_id, code) DO UPDATE SET name = EXCLUDED.name, boundary = EXCLUDED.boundary, asset_boundary = EXCLUDED.asset_boundary, sort = EXCLUDED.sort, capital_basis = EXCLUDED.capital_basis;
DELETE FROM vi_judgment_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND code = 'J-IC';
DELETE FROM vi_judgment_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND code = 'J-VE';
DELETE FROM vi_judgment_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND code = 'J-PROB';
INSERT INTO vi_judgment_base (company_id, code, title, status, judgment, transmission, parameter, change_threshold, no_change_condition) VALUES ((SELECT id FROM vi_company_base WHERE code = '01698.HK'), 'J-LAYER', '主估值层：盈利能力价值（Greenwald 三层）', '已形成建议', '腾讯音乐是轻资产平台：调整后的经营资产约 16 亿元，账面调整结果对无形资产和维持经营的现金假设敏感。增长能创造多少价值取决于优势能维持多久，而汽水音乐的免费模式（T3 观察）与多元变现（T4 存疑）都还没有定论。按 Greenwald 的顺序，以不增长的盈利能力价值作结论，增长价值只作为不付钱的上行空间：市价低于盈利能力价值时，买入不需要相信增长。', '每股价值与隐含回报都按盈利能力价值计算；资产价值、含增长价值在总览里并列展示，用于交叉检验。', '公司·主估值层', 'T3、T4 有了定论（付费用户与利润率在汽水音乐冲击下守住两年以上），可以改用含增长价值；利润率持续跌破 25% 时重新审视盈利能力本身。', '单季利润率波动、短期股价变化。') ON CONFLICT (company_id, code) DO UPDATE SET title = EXCLUDED.title, status = EXCLUDED.status, judgment = EXCLUDED.judgment, transmission = EXCLUDED.transmission, parameter = EXCLUDED.parameter, change_threshold = EXCLUDED.change_threshold, no_change_condition = EXCLUDED.no_change_condition;
INSERT INTO vi_judgment_base (company_id, code, title, status, judgment, transmission, change_threshold) VALUES ((SELECT id FROM vi_company_base WHERE code = '01698.HK'), 'J-CASH', 'Q3 独立现金、债务及汇出税', '已形成建议', 'Q3 现金、存款及流动投资 515.47 亿，扣经营周转 40.00 亿、融资和租赁负债 220.96 亿及暂估汇出税 21.70 亿。Q3 未单列投资应付款，保留在报表原科目内。汇出税沿用最近一次估算。', '第四层按 Q3 账面余额重算，与第一层使用同一期报表。', '收到境内未分派利润或投资应付款的新披露后复核。') ON CONFLICT (company_id, code) DO UPDATE SET title = EXCLUDED.title, status = EXCLUDED.status, judgment = EXCLUDED.judgment, transmission = EXCLUDED.transmission, change_threshold = EXCLUDED.change_threshold;
INSERT INTO vi_judgment_base (company_id, code, title, status, judgment, transmission, change_threshold) VALUES ((SELECT id FROM vi_company_base WHERE code = '01698.HK'), 'J-OPCASH', 'Q3 经营周转金暂估 40 亿元', '已形成建议', '一个月付款规模代理约 22 亿，加历史季节性波动缓冲约 10 亿及收入下降压力缓冲约 8 亿。按 Q3 营业成本与经营费用合计 66.50 亿估一个月规模，包含非现金费用。', '40 亿元从第四层现金池划入第一层。', '取得更细的月度付款和营运资金数据后复核。') ON CONFLICT (company_id, code) DO UPDATE SET title = EXCLUDED.title, status = EXCLUDED.status, judgment = EXCLUDED.judgment, transmission = EXCLUDED.transmission, change_threshold = EXCLUDED.change_threshold;
INSERT INTO vi_judgment_base (company_id, code, title, status, judgment, transmission, change_threshold) VALUES ((SELECT id FROM vi_company_base WHERE code = '01698.HK'), 'J-INV', 'Q3 非经营投资按账面七折', '已形成建议', 'Q3 公允价值计量权益投资、权益法投资及其他非流动投资合计 223.86 亿，按账面七折计 156.70 亿。30% 为处置税费、流动性与估值波动的合并估值假设。', '折后金额进入第四层。', '持仓结构、可变现性或税费变化后复核。') ON CONFLICT (company_id, code) DO UPDATE SET title = EXCLUDED.title, status = EXCLUDED.status, judgment = EXCLUDED.judgment, transmission = EXCLUDED.transmission, change_threshold = EXCLUDED.change_threshold;
INSERT INTO vi_judgment_base (company_id, code, title, status, judgment, transmission, parameter, change_threshold) VALUES ((SELECT id FROM vi_company_base WHERE code = '01698.HK'), 'J-AV', '资产价值：调整后的净经营资产（商誉不计入）', '已形成建议', '全公司口径（经营负债拆不到业务，不分业务估）。2026-09-30 报表口径的经营资本 287.4 亿元（经营资产 − 经营负债），加上划入的经营所需现金 40 亿元，合计 327.4 亿元，其中商誉 297.7 亿元。Q3 未单列投资应付款，整项其他应付款暂留经营。商誉不计入资产价值：它是收购溢价，不能单独变现，重建这门生意靠的是版权合作、用户与产品，不是这笔商誉。可辨认无形资产 55.50 亿元暂按账面 75% 计入，折减 13.88 亿元。Q3 未披露期末分类余额，折价是估值假设。调整后资产价值约 15.8 亿元。会员预收（递延收入）与应付版权费大于应收与存货，主营几乎不占营运资金。', '资产价值只用于第一层：与盈利能力价值比较时需考虑未入账的重建投入（基准 ROIC 约 28%，税后经营利润÷报表口径经营资本）；不进主估值。', '公司·资产价值口径；资产负债重估·商誉折价 100%、无形资产折价 25%', '大额并购或商誉减值；可辨认无形资产的构成披露变化。') ON CONFLICT (company_id, code) DO UPDATE SET title = EXCLUDED.title, status = EXCLUDED.status, judgment = EXCLUDED.judgment, transmission = EXCLUDED.transmission, parameter = EXCLUDED.parameter, change_threshold = EXCLUDED.change_threshold;
DELETE FROM vi_lnk_judgment_theses WHERE judgment_id = (SELECT id FROM vi_judgment_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND code = 'J-AV');
INSERT INTO vi_lnk_judgment_theses (judgment_id, thesis_id, "createdAt", "updatedAt")
SELECT (SELECT id FROM vi_judgment_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND code = 'J-AV'), t.id, now(), now() FROM vi_thesis_base t WHERE t.company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND t.code = 'T1' ON CONFLICT DO NOTHING;
INSERT INTO vi_judgment_base (company_id, code, title, status, judgment, transmission, parameter, change_threshold, no_change_condition) VALUES ((SELECT id FROM vi_company_base WHERE code = '01698.HK'), 'J-EPV', '调整后利润表：正常化收入、成本费用、收购摊销加回与税率', '已形成建议', '用 Q3 单季收入 89.41 亿年化至 357.64 亿，营业成本、销售、行政费用率取 Q3 实绩。剔除利息及一次性收益，收购摊销按当季披露额年化后加回七成；所得税率取前三季约 16.9%。单季年化反映并表后的业务规模，演出、周边和订阅季节性仍会影响结果。', '费用率或毛利率每变动 1 个百分点，税前经营利润约变动 3.58 亿。', '调整后利润表·收入、营业成本、销售费用、行政开支、收购摊销加回、所得税', '年报核心经营利润率偏离 2 个百分点以上并持续两个季度；会员收入同比转负（剔除喜马拉雅）。', '单季利润率在 28%—31% 之间波动。') ON CONFLICT (company_id, code) DO UPDATE SET title = EXCLUDED.title, status = EXCLUDED.status, judgment = EXCLUDED.judgment, transmission = EXCLUDED.transmission, parameter = EXCLUDED.parameter, change_threshold = EXCLUDED.change_threshold, no_change_condition = EXCLUDED.no_change_condition;
DELETE FROM vi_lnk_judgment_theses WHERE judgment_id = (SELECT id FROM vi_judgment_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND code = 'J-EPV');
INSERT INTO vi_lnk_judgment_theses (judgment_id, thesis_id, "createdAt", "updatedAt")
SELECT (SELECT id FROM vi_judgment_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND code = 'J-EPV'), t.id, now(), now() FROM vi_thesis_base t WHERE t.company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND t.code = 'T1' ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_judgment_theses (judgment_id, thesis_id, "createdAt", "updatedAt")
SELECT (SELECT id FROM vi_judgment_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND code = 'J-EPV'), t.id, now(), now() FROM vi_thesis_base t WHERE t.company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND t.code = 'T3' ON CONFLICT DO NOTHING;
INSERT INTO vi_lnk_judgment_theses (judgment_id, thesis_id, "createdAt", "updatedAt")
SELECT (SELECT id FROM vi_judgment_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND code = 'J-EPV'), t.id, now(), now() FROM vi_thesis_base t WHERE t.company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND t.code = 'T6' ON CONFLICT DO NOTHING;
INSERT INTO vi_judgment_base (company_id, code, title, status, judgment, transmission, parameter, change_threshold) VALUES ((SELECT id FROM vi_company_base WHERE code = '01698.HK'), 'J-MCAP', '折旧摊销按 Q3 年化，维持性资本开支用历史代理', '已形成建议', 'Q3 折旧与无形摊销合计 5.16 亿，扣掉已税前加回的 1.575 亿后年化约 14.34 亿。Q3 公告仅列投资活动净现金流，维持性资本开支暂取 2022—2025 年均值 11.1 亿。', '维持性资本开支每增加 1 亿，正常化盈利约减少 1 亿。', '调整后利润表·折旧摊销、维持性资本开支', '资本开支连续两年超过 15 亿元（如自建数据中心、AI 算力），或年报披露收购摊销的拆分（Q04）。') ON CONFLICT (company_id, code) DO UPDATE SET title = EXCLUDED.title, status = EXCLUDED.status, judgment = EXCLUDED.judgment, transmission = EXCLUDED.transmission, parameter = EXCLUDED.parameter, change_threshold = EXCLUDED.change_threshold;
INSERT INTO vi_judgment_base (company_id, code, title, status, judgment, transmission, parameter, change_threshold) VALUES ((SELECT id FROM vi_company_base WHERE code = '01698.HK'), 'J-MINOR', '少数股东 3%：经营部分乘 97%，非经营部分在桥里扣', '已形成建议', 'Q3 少数股东损益 0.65 亿÷净利润 22.19 亿，取整 3%（J-FIN）。经营部分：调整后利润表最后扣 3%，资产价值也乘 97%；非经营部分：资产负债桥只扣少数股东在非经营净资产（现金扣经营所需与有息负债、汇出预提税，对外投资折后，约 389.5 亿元）中的 3%，即 11.69 亿元。账面少数股东权益 28.39 亿元不全额扣：其余部分在经营资产里，已经被 97% 扣过，全额再扣就重复了。', '少数股东比例每 ±1 个百分点，每股盈利能力价值约 ∓0.5 元。', '调整后利润表·少数股东；资产负债重估·少数股东权益', '少数股东损益占比变化超过 1 个百分点（如喜马拉雅少数股东结构变化）。') ON CONFLICT (company_id, code) DO UPDATE SET title = EXCLUDED.title, status = EXCLUDED.status, judgment = EXCLUDED.judgment, transmission = EXCLUDED.transmission, parameter = EXCLUDED.parameter, change_threshold = EXCLUDED.change_threshold;
INSERT INTO vi_bs_item_base (company_id, category, line_item, name, haircut, adjustment, basis, sort) VALUES ((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '经营资产', '物业厂房及设备', NULL, NULL, NULL, NULL, 1);
WITH ins AS (INSERT INTO vi_bs_item_base (company_id, category, line_item, name, haircut, adjustment, basis, sort) VALUES ((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '经营资产', '无形资产', NULL, 0.25, NULL, '按账面 75% 暂计，折价 25% 是估值假设。2026Q3 披露期末 55.50 亿，较中报 58.95 亿减少 3.45 亿。中报附注 13 披露上半年企业合并新增 33.99 亿。2025 年报附注 15 的期初参照：版权 16.89 亿，域名、商标及牌照 4.30 亿，竞业协议 0.78 亿，企业客户关系 0.22 亿，供应商资源 0.01 亿，其他 6.79 亿。Q3 未披露期末分类余额。版权与牌照的重置成本取决于剩余期限、授权范围和续约条件；客户关系与竞业协议取决于存量客户留存及合同有效期。基准折价用于反映这些估值不确定性。可按 0%、25%、50% 折价比较，待取得分类余额及合同资料后逐项重估。', 2) RETURNING id)
INSERT INTO vi_lnk_bs_item_judgments (bs_item_id, judgment_id, "createdAt", "updatedAt")
SELECT ins.id, j.id, now(), now() FROM ins JOIN vi_judgment_base j ON j.company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND j.code IN ('J-AV');
WITH ins AS (INSERT INTO vi_bs_item_base (company_id, category, line_item, name, haircut, adjustment, basis, sort) VALUES ((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '经营资产', '商誉', NULL, 1.0, NULL, '收购酷狗、酷我、懒人听书、喜马拉雅等形成的商誉 297.73 亿元。计入账面经营资本（ROIC 的分母，反映股东实际投入），但不计入资产价值：它是收购溢价，不能单独变现，新进入者也不靠这笔钱重建业务（见 J-AV）。', 3) RETURNING id)
INSERT INTO vi_lnk_bs_item_judgments (bs_item_id, judgment_id, "createdAt", "updatedAt")
SELECT ins.id, j.id, now(), now() FROM ins JOIN vi_judgment_base j ON j.company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND j.code IN ('J-AV');
INSERT INTO vi_bs_item_base (company_id, category, line_item, name, haircut, adjustment, basis, sort) VALUES ((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '经营资产', '土地使用权', NULL, NULL, NULL, NULL, 4);
INSERT INTO vi_bs_item_base (company_id, category, line_item, name, haircut, adjustment, basis, sort) VALUES ((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '经营资产', '递延税项资产', NULL, NULL, NULL, NULL, 5);
INSERT INTO vi_bs_item_base (company_id, category, line_item, name, haircut, adjustment, basis, sort) VALUES ((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '经营资产', '预付款项', NULL, NULL, NULL, NULL, 6);
INSERT INTO vi_bs_item_base (company_id, category, line_item, name, haircut, adjustment, basis, sort) VALUES ((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '经营资产', '使用权资产', NULL, NULL, NULL, NULL, 7);
INSERT INTO vi_bs_item_base (company_id, category, line_item, name, haircut, adjustment, basis, sort) VALUES ((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '经营资产', '存货', NULL, NULL, NULL, NULL, 8);
INSERT INTO vi_bs_item_base (company_id, category, line_item, name, haircut, adjustment, basis, sort) VALUES ((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '经营资产', '应收账款', NULL, NULL, NULL, NULL, 9);
INSERT INTO vi_bs_item_base (company_id, category, line_item, name, haircut, adjustment, basis, sort) VALUES ((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '经营资产', '预付款、按金及其他资产（流动）', NULL, NULL, NULL, NULL, 10);
INSERT INTO vi_bs_item_base (company_id, category, line_item, name, haircut, adjustment, basis, sort) VALUES ((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '经营资产', '受限现金', NULL, NULL, NULL, NULL, 11);
WITH ins AS (INSERT INTO vi_bs_item_base (company_id, category, line_item, name, haircut, adjustment, basis, sort) VALUES ((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '经营资产', NULL, '经营所需现金（从现金划入）', NULL, 40.0, '周转金估算：22＋10＋8≈40 亿元，取整为 40 亿元。① 日常付款：Q3 营业成本与经营费用合计 66.50 亿元，月均约 22 亿元，用作月度付款规模代理（含非现金费用）。② 季节性周转：估计剔除应付股息后，2025 年一至二季度浮存金回落约 11 亿元，取 10 亿元。③ 压力缓冲：假设收入下降 10%，按Q3 收入年化约 358 亿元×10%×历史浮存金占收入比例约 22%，需约 8 亿元。若收入下降 20%，总需求约 48 亿元。来源：工作台假设 J-OPCASH。', 12) RETURNING id)
INSERT INTO vi_lnk_bs_item_judgments (bs_item_id, judgment_id, "createdAt", "updatedAt")
SELECT ins.id, j.id, now(), now() FROM ins JOIN vi_judgment_base j ON j.company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND j.code IN ('J-OPCASH');
INSERT INTO vi_bs_item_base (company_id, category, line_item, name, haircut, adjustment, basis, sort) VALUES ((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '经营负债', '应付账款', NULL, NULL, NULL, NULL, 13);
INSERT INTO vi_bs_item_base (company_id, category, line_item, name, haircut, adjustment, basis, sort) VALUES ((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '经营负债', '应交所得税', NULL, NULL, NULL, NULL, 14);
INSERT INTO vi_bs_item_base (company_id, category, line_item, name, haircut, adjustment, basis, sort) VALUES ((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '经营负债', '递延收入（流动）', NULL, NULL, NULL, NULL, 15);
INSERT INTO vi_bs_item_base (company_id, category, line_item, name, haircut, adjustment, basis, sort) VALUES ((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '经营负债', '其他应付款项及其他负债（流动）', NULL, NULL, NULL, 'Q3 公告未单列投资应付款，整项暂留第一层。中报 4.10 亿元作为历史参照。', 16);
INSERT INTO vi_bs_item_base (company_id, category, line_item, name, haircut, adjustment, basis, sort) VALUES ((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '经营负债', '递延税项负债', NULL, NULL, NULL, NULL, 17);
INSERT INTO vi_bs_item_base (company_id, category, line_item, name, haircut, adjustment, basis, sort) VALUES ((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '经营负债', '递延收入（非流动）', NULL, NULL, NULL, NULL, 18);
INSERT INTO vi_bs_item_base (company_id, category, line_item, name, haircut, adjustment, basis, sort) VALUES ((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '经营负债', '其他应付款项及其他负债（非流动）', NULL, NULL, NULL, NULL, 19);
INSERT INTO vi_bs_item_base (company_id, category, line_item, name, haircut, adjustment, basis, sort) VALUES ((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '现金与投资', '现金及现金等价物', NULL, NULL, NULL, '现金及等价物、定期存款与短期投资：可以单独计价的现金。', 20);
INSERT INTO vi_bs_item_base (company_id, category, line_item, name, haircut, adjustment, basis, sort) VALUES ((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '现金与投资', '短期存款', NULL, NULL, NULL, NULL, 21);
INSERT INTO vi_bs_item_base (company_id, category, line_item, name, haircut, adjustment, basis, sort) VALUES ((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '现金与投资', '中长期存款', NULL, NULL, NULL, NULL, 22);
INSERT INTO vi_bs_item_base (company_id, category, line_item, name, haircut, adjustment, basis, sort) VALUES ((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '现金与投资', '其他投资（流动）', NULL, NULL, NULL, '原财报单列的流动投资，归入第四层，按账面值计。', 23);
WITH ins AS (INSERT INTO vi_bs_item_base (company_id, category, line_item, name, haircut, adjustment, basis, sort) VALUES ((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '现金与投资', NULL, '划给经营的周转现金', NULL, -40.0, '与经营资产里的“经营所需现金”对应：这 40 亿元留在业务里周转，不能分给股东。', 24) RETURNING id)
INSERT INTO vi_lnk_bs_item_judgments (bs_item_id, judgment_id, "createdAt", "updatedAt")
SELECT ins.id, j.id, now(), now() FROM ins JOIN vi_judgment_base j ON j.company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND j.code IN ('J-OPCASH');
WITH ins AS (INSERT INTO vi_bs_item_base (company_id, category, line_item, name, haircut, adjustment, basis, sort) VALUES ((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '现金与投资', '以公允价值计量且其变动计入其他综合收益的金融资产', NULL, 0.3, NULL, '对外上市股权（Spotify、UMG、WMG 等，公允价值）；按最新报告账面价值打七折（控股折价、处置税费与流动性），见 J-INV。', 25) RETURNING id)
INSERT INTO vi_lnk_bs_item_judgments (bs_item_id, judgment_id, "createdAt", "updatedAt")
SELECT ins.id, j.id, now(), now() FROM ins JOIN vi_judgment_base j ON j.company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND j.code IN ('J-INV');
WITH ins AS (INSERT INTO vi_bs_item_base (company_id, category, line_item, name, haircut, adjustment, basis, sort) VALUES ((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '现金与投资', '其他投资（非流动）', NULL, 0.3, NULL, '其他投资（非流动）；按最新报告账面价值打七折（控股折价、处置税费与流动性），见 J-INV。', 26) RETURNING id)
INSERT INTO vi_lnk_bs_item_judgments (bs_item_id, judgment_id, "createdAt", "updatedAt")
SELECT ins.id, j.id, now(), now() FROM ins JOIN vi_judgment_base j ON j.company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND j.code IN ('J-INV');
WITH ins AS (INSERT INTO vi_bs_item_base (company_id, category, line_item, name, haircut, adjustment, basis, sort) VALUES ((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '现金与投资', '按权益法核算的投资', NULL, 0.3, NULL, '按权益法核算的投资；按最新报告账面价值打七折（控股折价、处置税费与流动性），见 J-INV。', 27) RETURNING id)
INSERT INTO vi_lnk_bs_item_judgments (bs_item_id, judgment_id, "createdAt", "updatedAt")
SELECT ins.id, j.id, now(), now() FROM ins JOIN vi_judgment_base j ON j.company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND j.code IN ('J-INV');
INSERT INTO vi_bs_item_base (company_id, category, line_item, name, haircut, adjustment, basis, sort) VALUES ((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '有息负债', '短期借款', NULL, NULL, NULL, NULL, 28);
INSERT INTO vi_bs_item_base (company_id, category, line_item, name, haircut, adjustment, basis, sort) VALUES ((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '有息负债', '长期借款', NULL, NULL, NULL, NULL, 29);
INSERT INTO vi_bs_item_base (company_id, category, line_item, name, haircut, adjustment, basis, sort) VALUES ((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '有息负债', '应付票据（非流动）', NULL, NULL, NULL, NULL, 30);
INSERT INTO vi_bs_item_base (company_id, category, line_item, name, haircut, adjustment, basis, sort) VALUES ((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '有息负债', '租赁负债（流动）', NULL, NULL, NULL, NULL, 31);
INSERT INTO vi_bs_item_base (company_id, category, line_item, name, haircut, adjustment, basis, sort) VALUES ((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '有息负债', '租赁负债（非流动）', NULL, NULL, NULL, NULL, 32);
WITH ins AS (INSERT INTO vi_bs_item_base (company_id, category, line_item, name, haircut, adjustment, basis, sort) VALUES ((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '其他索取权', NULL, '境内资金汇出预提税（10%）', NULL, 21.7, 'Q3 未披露更新的境内未分派利润。暂沿用中报时点估算 21.70 亿，作为第四层汇出税压力扣减。', 33) RETURNING id)
INSERT INTO vi_lnk_bs_item_judgments (bs_item_id, judgment_id, "createdAt", "updatedAt")
SELECT ins.id, j.id, now(), now() FROM ins JOIN vi_judgment_base j ON j.company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND j.code IN ('J-CASH');
WITH ins AS (INSERT INTO vi_bs_item_base (company_id, category, line_item, name, haircut, adjustment, basis, sort) VALUES ((SELECT id FROM vi_company_base WHERE code = '01698.HK'), '其他索取权', '非控股权益', NULL, NULL, -16.7, '只扣少数股东在非经营净资产中的 3%：389.5×3%＝11.69 亿元；账面少数股东权益 28.39 亿元的其余部分在经营里，已由归母比例 97% 扣过（J-MINOR）。', 34) RETURNING id)
INSERT INTO vi_lnk_bs_item_judgments (bs_item_id, judgment_id, "createdAt", "updatedAt")
SELECT ins.id, j.id, now(), now() FROM ins JOIN vi_judgment_base j ON j.company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND j.code IN ('J-MINOR');
WITH ins AS (INSERT INTO vi_epv_base (company_id, business_id, sort, name, section, formula, method, value, note) VALUES ((SELECT id FROM vi_company_base WHERE code = '01698.HK'), (SELECT id FROM vi_business_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND code = 'B1'), 1, '营业收入', '收入', '营业收入', '金额', 357.64, '2026Q3 单季收入年化 ×4：会员 199.40＋营销及消费 107.88＋社交娱乐及其他 50.36 亿元。并表后运行水平，含季节性风险。') RETURNING id)
INSERT INTO vi_lnk_epv_judgments (epv_id, judgment_id, "createdAt", "updatedAt")
SELECT ins.id, j.id, now(), now() FROM ins JOIN vi_judgment_base j ON j.company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND j.code IN ('J-EPV');
WITH ins AS (INSERT INTO vi_epv_base (company_id, business_id, sort, name, section, formula, method, value, note) VALUES ((SELECT id FROM vi_company_base WHERE code = '01698.HK'), (SELECT id FROM vi_business_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND code = 'B1'), 2, '营业成本（版权、分成、带宽等）', '成本费用', '−营业成本', '占收入比例', 0.57241919, 'Q3 营业成本 51.18 亿÷收入 89.41 亿；毛利率 42.8%，反映演出、艺人周边等业务组合变化。') RETURNING id)
INSERT INTO vi_lnk_epv_judgments (epv_id, judgment_id, "createdAt", "updatedAt")
SELECT ins.id, j.id, now(), now() FROM ins JOIN vi_judgment_base j ON j.company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND j.code IN ('J-EPV');
WITH ins AS (INSERT INTO vi_epv_base (company_id, business_id, sort, name, section, formula, method, value, note) VALUES ((SELECT id FROM vi_company_base WHERE code = '01698.HK'), (SELECT id FROM vi_business_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND code = 'B1'), 3, '销售及分销费用', '成本费用', '−销售及营销费用', '占收入比例', 0.03299407, 'Q3 销售费用 2.95 亿÷收入 89.41 亿，约 3.30%。') RETURNING id)
INSERT INTO vi_lnk_epv_judgments (epv_id, judgment_id, "createdAt", "updatedAt")
SELECT ins.id, j.id, now(), now() FROM ins JOIN vi_judgment_base j ON j.company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND j.code IN ('J-EPV');
WITH ins AS (INSERT INTO vi_epv_base (company_id, business_id, sort, name, section, formula, method, value, note) VALUES ((SELECT id FROM vi_company_base WHERE code = '01698.HK'), (SELECT id FROM vi_business_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND code = 'B1'), 4, '行政开支（含研发、股权激励、收购摊销）', '成本费用', '−一般及行政费用', '占收入比例', 0.13835141, 'Q3 一般及行政费用 12.37 亿÷收入 89.41 亿，约 13.84%，包括股权激励。') RETURNING id)
INSERT INTO vi_lnk_epv_judgments (epv_id, judgment_id, "createdAt", "updatedAt")
SELECT ins.id, j.id, now(), now() FROM ins JOIN vi_judgment_base j ON j.company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND j.code IN ('J-EPV');
WITH ins AS (INSERT INTO vi_epv_base (company_id, business_id, sort, name, section, direction, method, value, note) VALUES ((SELECT id FROM vi_company_base WHERE code = '01698.HK'), (SELECT id FROM vi_business_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND code = 'B1'), 5, '七成收购摊销', '税前调整', '加', '金额', 6.3, 'Q3 调节表披露收购摊销 2.25 亿元。按单季年化并暂加回 70%，余下 30% 作为持续成本。比例为估算。') RETURNING id)
INSERT INTO vi_lnk_epv_judgments (epv_id, judgment_id, "createdAt", "updatedAt")
SELECT ins.id, j.id, now(), now() FROM ins JOIN vi_judgment_base j ON j.company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND j.code IN ('J-EPV');
WITH ins AS (INSERT INTO vi_epv_base (company_id, business_id, sort, name, section, formula, method, value, note) VALUES ((SELECT id FROM vi_company_base WHERE code = '01698.HK'), (SELECT id FROM vi_business_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND code = 'B1'), 6, '所得税', '所得税', '−所得税费用', '比率', 0.16869209, '前三季度所得税 14.02 亿÷税前利润 83.11 亿，约 16.9%。') RETURNING id)
INSERT INTO vi_lnk_epv_judgments (epv_id, judgment_id, "createdAt", "updatedAt")
SELECT ins.id, j.id, now(), now() FROM ins JOIN vi_judgment_base j ON j.company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND j.code IN ('J-EPV');
WITH ins AS (INSERT INTO vi_epv_base (company_id, business_id, sort, name, section, direction, formula, method, value, note) VALUES ((SELECT id FROM vi_company_base WHERE code = '01698.HK'), (SELECT id FROM vi_business_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND code = 'B1'), 7, '折旧摊销（不含已加回的收购摊销）', '税后调整', '加', '现金流量表：折旧及摊销（现金流附注）', '金额', 14.34, 'Q3 折旧 0.53 亿＋无形资产摊销 4.63 亿，减税前已加回的收购摊销，再乘 4，约 14.34 亿。') RETURNING id)
INSERT INTO vi_lnk_epv_judgments (epv_id, judgment_id, "createdAt", "updatedAt")
SELECT ins.id, j.id, now(), now() FROM ins JOIN vi_judgment_base j ON j.company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND j.code IN ('J-MCAP');
WITH ins AS (INSERT INTO vi_epv_base (company_id, business_id, sort, name, section, direction, formula, method, from_year, to_year, note) VALUES ((SELECT id FROM vi_company_base WHERE code = '01698.HK'), (SELECT id FROM vi_business_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND code = 'B1'), 8, '维持性资本开支', '税后调整', '减', '−购置物业厂房及设备 − 购置无形资产 − 购置土地使用权', '历史平均', 2022, 2025, 'Q3 公告仅列投资现金流净额。维持性资本开支暂用 2022—2025 年均值 11.1 亿作代理。') RETURNING id)
INSERT INTO vi_lnk_epv_judgments (epv_id, judgment_id, "createdAt", "updatedAt")
SELECT ins.id, j.id, now(), now() FROM ins JOIN vi_judgment_base j ON j.company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND j.code IN ('J-MCAP');
WITH ins AS (INSERT INTO vi_epv_base (company_id, business_id, sort, name, section, formula, method, value, note) VALUES ((SELECT id FROM vi_company_base WHERE code = '01698.HK'), (SELECT id FROM vi_business_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND code = 'B1'), 9, '少数股东', '少数股东', '非控股权益应占净利润', '比率', 0.03, 'Q3 少数股东损益 0.65 亿÷净利润 22.19 亿，取整 3%') RETURNING id)
INSERT INTO vi_lnk_epv_judgments (epv_id, judgment_id, "createdAt", "updatedAt")
SELECT ins.id, j.id, now(), now() FROM ins JOIN vi_judgment_base j ON j.company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND j.code IN ('J-MINOR');
INSERT INTO vi_epv_base (company_id, business_id, sort, name, section, formula, note) VALUES ((SELECT id FROM vi_company_base WHERE code = '01698.HK'), (SELECT id FROM vi_business_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND code = 'B1'), 10, '其他收入（利息收入为主）', '不计入', '利息收入', '不计入：产生利息的现金在资产负债桥里单独计价，再计利息就重复了');
INSERT INTO vi_epv_base (company_id, business_id, sort, name, section, formula, note) VALUES ((SELECT id FROM vi_company_base WHERE code = '01698.HK'), (SELECT id FROM vi_business_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND code = 'B1'), 11, '其他收益（投资收益、公允价值变动、一次性项目）', '不计入', '其他利得及损失净额', '不计入：对外投资在资产负债桥里按七折单独计价；2025 年 26.3 亿元里大部分是一次性收益');
INSERT INTO vi_epv_base (company_id, business_id, sort, name, section, formula, note) VALUES ((SELECT id FROM vi_company_base WHERE code = '01698.HK'), (SELECT id FROM vi_business_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND code = 'B1'), 12, '应占联营公司溢利', '不计入', '应占权益法投资净损益', '不计入：权益法投资在资产负债桥里单独计价');
INSERT INTO vi_epv_base (company_id, business_id, sort, name, section, formula, note) VALUES ((SELECT id FROM vi_company_base WHERE code = '01698.HK'), (SELECT id FROM vi_business_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND code = 'B1'), 13, '融资成本', '不计入', '−财务费用', '不计入：有息负债在资产负债桥里扣除，利息不再进经营利润');
INSERT INTO vi_growth_base (company_id, business_id, growth, ronic, adv_years, note) VALUES ((SELECT id FROM vi_company_base WHERE code = '01698.HK'), (SELECT id FROM vi_business_base WHERE company_id = (SELECT id FROM vi_company_base WHERE code = '01698.HK') AND code = 'B1'), 0.025, 0.15, 10, '十年低速增长，之后增长不再创造价值');
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
     '沿用第二层 Q3 单季收入年化 357.64 亿元，先按三条收入线估经营利润。会员年增 2%，反映付费升级同时受免费产品分流。营销及消费服务前三年增 10%、后七年增 6%，反映演出与周边从较小基数扩张后放缓。社交娱乐每年收缩 8%，接近 2025 全年降幅 7.3%。这些均为十年推演假设。',
     '按 Q3 会员 49.85、营销及消费 26.97、社交娱乐 12.59 亿元分别乘四，以 42%、15%、16% 的假设利润率估基期经营利润 107.99 亿元。十年后分别为 102.09、32.39、3.50 亿元，合计 137.97 亿元。十年复合约 2.48%，按半个百分点取整为 2.5%。利润率沿用研究分摊，税率、归母比例及维持性投入相对稳定，才可把利润增速用于第二层现金收益 E。三块利润仅用来估增长速度。',
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

COMMIT;
