"""小米业务身份、分业务画布与资产边界；同时用于在线增量迁移和空库种子。"""
from pathlib import Path

CO = "(SELECT id FROM vi_company_base WHERE code='01810.HK')"

BUSINESSES = [
    ('S1', '智能手机', '手机硬件销售；互联网服务收入和利润归 S3，自研芯片等创新业务归 S5。',
     '手机、AIoT、互联网共用生态营业费用，沿用 J-OPEX 按各自收入分摊；不能因分部独立而漏掉共同获客成本。',
     '经营设备、品牌与渠道对盈利的贡献包含在业务价值中；经营所需现金由 C5 集团统一扣除，集团现金及投资不放进分部价值。'),
    ('S2', 'AIoT 与生活消费产品', 'IoT 与生活消费产品，含其他相关业务；生态链公司的股权投资归资产项目 C8，不重复作为自营业务。',
     '沿用 J-OPEX，按收入分摊生态共同费用；其他相关业务的收入与损益并入本分部。',
     '服务经营的设备、渠道与品牌包含在业务价值中；对外股权持仓在 C8 单独计价，经营所需现金在 C5 统一处理。'),
    ('S3', '互联网服务', '设备用户的广告、游戏及其他互联网服务变现；硬件收入归 S1、S2。',
     '按收入分摊生态共同费用，包含硬件获客所需共同费用的分摊；单独估值不意味着脱离硬件生态。',
     '用户、账户、软件及相关经营资产的贡献包含在盈利估值中，不另加用户或生态溢价；集团现金与投资另算。'),
    ('S4', '智能电动汽车', '汽车及相关服务，不含 AI、大模型、芯片与机器人；延续 J-EV-SPLIT 的估算拆分。',
     '汽车毛利减汽车本身研发、渠道等费用；AI 成本按既有拆分剔出，拆分不确定性仍由 J-EV-SPLIT 跟踪。',
     '汽车工厂及生产设施的经营贡献包含在稳态盈利与期间现金流中，不再按账面固定资产加计；资本开支沿用原假设。'),
    ('S5', 'AI、芯片与机器人', '沿用现有估值分组，暂合并大模型、芯片与机器人；三者商业化路径不同，披露足够后可继续拆分。',
     '与汽车成本分开，集团共用研发的归属仍需核验；沿用 J-AI 整体估值，不新增一笔投入扣减。',
     '直接估值沿用既有整体口径；未来投入及集团现金支持的重叠问题保留在 T4/J-AI，不因本次结构调整视作已解决。'),
]

# 每行：画布要点、机制、关键数字、变化与风险。证据按业务主题选择，并引用该分部既有估值事实。
CANVASES = {
 'S1': [
  ('面向不同价位的手机用户', 'Redmi 覆盖入门市场，Xiaomi 数字旗舰与 Ultra 面向高端用户；用户规模与月活口径不能混用。', None, '境内外用户购买力和变现能力不同。'),
  ('性价比与高端化并行', '以产品定义、供应链与影像等体验竞争；硬件获客后形成的互联网收入归 S3。', None, '高端化能否抵消存储等物料涨价需要持续验证。'),
  ('电商、新零售及海外运营商', '使用集团渠道；渠道共性见集团层，手机相关费用不能遗漏。', None, '门店扩张对费用率与销售效率的影响。'),
  ('硬件销售后维系设备与账户用户', '手机销售形成设备用户基础；持续服务变现与硬件销售分别记录。', None, '换机流失会滞后影响互联网月活。'),
  ('收入＝出货量×平均售价', '硬件收入与毛利单列；互联网变现不在手机分部重复确认。', '业务估值 S1；正常化年份及收入见对应情景', '销量、产品结构和存储周期影响正常化盈利。'),
  ('产品、供应链、品牌与设备用户基础', '品牌和渠道属于共享能力；对经营盈利的贡献已包含在分部估值中。', None, '共享资源不等于各业务都能获得同样的超额利润。'),
  ('产品定义、研发与供应链管理', '沿用现有集团画布的制造与研发描述；自研芯片创新业务暂放 S5。', None, '制造与研发边界须随披露更新。'),
  ('核心器件、影像与系统伙伴', '依赖 SoC、存储、屏幕及系统生态伙伴，器件供应集中影响议价与成本。', None, '关键器件供需与替代可行性。'),
  ('硬件毛利减分摊费用', '经营利润＝手机收入×毛利率−按收入分摊的生态营业费用；维持原税率、正常化年份和期间现金流。', '共同费用分摊：J-OPEX；估值参数：S1', '按收入分摊是研究假设，不能将推算损益等同公司披露分部利润。'),
 ],
 'S2': [
  ('个人设备与家庭消费用户', '覆盖可穿戴、平板、电视、大家电等生活消费产品；连接设备数不是月活用户数。', None, '不同品类购买频率和竞争格局存在差异。'),
  ('产品性价比与设备协同', '通过米家等设备连接提升跨品类使用体验；不把连接规模直接当作利润。', None, '生态锁定程度与产品独立竞争力需要分开验证。'),
  ('集团新零售与电商渠道', '共用渠道的机制见集团层；各品类渠道费用与销售结构影响分摊。', None, '渠道扩张与国补变化影响需求。'),
  ('多设备与家庭场景复购', '多设备使用形成交叉销售机会，需以实际复购和毛利验证。', None, '设备连接不保证付费或复购。'),
  ('各类产品销售收入加总', '估值口径合并 IoT 与生活消费产品和其他相关业务；对外股权投资另放 C8。', '业务估值 S2，含其他相关业务', '产品组合与补贴变化影响收入和毛利率。'),
  ('产品定义、渠道与生态链伙伴', '共享品牌、零售渠道和设备生态；被投企业的股权价值不在此重复加计。', None, '合作利益与集团利益可能不一致。'),
  ('跨品类产品与供应链组织', '围绕产品定义、供应链、渠道与设备连接开展经营；各品类的经营资产贡献包含在盈利中。', None, '品类扩张可能同时增加管理复杂度。'),
  ('生态链制造与供应伙伴', '合作伙伴提供产品和制造能力，集团提供品牌、渠道及生态连接。', None, '伙伴依赖、质量与利润分配。'),
  ('产品毛利减共享费用', '按分项毛利率与 J-OPEX 的收入分摊费用率估算经营利润，沿用正常化及过渡期现金流。', '共同费用分摊：J-OPEX；估值参数：S2', '毛利率结构升级与国补退坡均需验证。'),
 ],
 'S3': [
  ('设备用户与服务付费方', '设备用户形成流量基础；广告、游戏等业务的付款方和使用者可能不同。', None, '用户数量和单位用户价值分别跟踪。'),
  ('基于设备入口提供互联网服务', '通过广告、游戏等服务变现；与硬件获客相互依赖。', None, '用户体验、监管和竞争约束变现强度。'),
  ('账户、系统与设备入口', '依托存量设备和系统服务触达用户，入口来自手机等硬件业务。', None, '入口控制与合作安排可能变化。'),
  ('随设备持续使用形成服务关系', '收入取决于活跃用户及单位用户变现，不等同于硬件当期出货收入。', None, '设备用户流失可能滞后传导。'),
  ('收入＝活跃用户×单位用户变现', '广告、游戏等收入汇总；收入、毛利与共享获客成本分别观察。', '业务估值 S3；用户与变现数据见既有事实', '国内外用户变现差异，不能只外推集团月活。'),
  ('用户基础、账户与系统运营能力', '现有用户及软件的经营贡献已反映在盈利估值中，不另加生态溢价。', None, '流量规模能否维持以及变现是否透支体验。'),
  ('服务运营与流量变现', '运营广告、游戏及其他互联网服务，并与设备业务协同获客。', None, '变现效率与服务体验的平衡。'),
  ('内容、广告与系统生态伙伴', '业务依赖广告主、内容和服务伙伴及系统生态；具体合同条款未在此补造。', None, '合作方议价、合规及分成变化。'),
  ('高毛利服务仍需承担共享成本', '互联网毛利减按收入分摊的生态共同费用，防止手机承担全部获客成本而互联网只保留利润。', '共同费用分摊：J-OPEX；估值参数：S3', '更换分摊方式会改变各业务价值，需要通过情景检验。'),
 ],
 'S4': [
  ('汽车消费用户', '面向汽车消费者，用户可能来自小米设备生态之外；沿用集团画布与现有汽车事实。', None, '不能以手机月活直接推算汽车销量。'),
  ('汽车产品与智能体验', '以汽车产品、交付质量及使用体验竞争，与手机硬件和互联网服务分别估值。', None, '产品竞争、价格战与质量反馈。'),
  ('汽车销售、交付及服务渠道', '汽车有专门门店与交付服务体系，同时使用集团品牌和部分渠道能力。', None, '扩张速度与渠道效率。'),
  ('购车到交付后的持续服务', '客户关系跨越订单、交付和车辆使用周期；手机用户关系不能直接替代汽车关系。', None, '订单转交付、服务与口碑。'),
  ('收入＝交付量×平均售价＋相关收入', '沿用汽车稳态经营假设，收入和利润中剔出 AI 等创新业务。', '业务估值 S4；稳态年份 2030', '交付规模、ASP 和稳态利润率。'),
  ('汽车产品、工厂与组织能力', '工厂与生产设施为业务创造利润，其价值包含在稳态盈利与期间现金流中。', '资产边界登记 A4：已含业务估值', '生产、供应链与质量管理仍需验证。'),
  ('产品研发、制造与交付服务', '沿用现有汽车自建工厂及量产描述，资本开支和营运资本沿用原模型。', None, '爬坡中的产能利用率与资金需求。'),
  ('电池与汽车供应链伙伴', '沿用现有电池及供应链证据，供应集中与交付能力影响经营。', None, '供应依赖与零部件成本。'),
  ('汽车毛利减汽车本身费用', '汽车经营费用与 AI 投入按 J-EV-SPLIT 拆开；稳态价值加期间现金流，不再加汽车工厂账面价值。', '估值参数 S4；拆分依据 J-EV-SPLIT', 'AI 拆分估计、价格战和执行风险。'),
 ],
 'S5': [
  ('客户与付费场景尚待明确', '大模型、芯片、机器人目前合并跟踪，不能认定三者具有同一种已验证的付费客户。', None, '客户、收入及对内对外使用口径待核验。'),
  ('模型、芯片与机器人能力探索', '经营价值取决于未来应用与商业化；现有直接估值是研究判断。', None, '研发能力不自动等于可持续盈利。'),
  ('独立销售渠道尚待验证', '可能与集团产品协同，但尚无足够证据确认稳定的独立销售和交付路径。', None, '对内协同收益和对外收入不能混计。'),
  ('持续使用与付费机制待验证', '尚不能用手机月活或集团用户关系替代 AI 业务留存和付费数据。', None, '商业化与留存证据不足。'),
  ('尚未建立可靠盈利预测', '沿用直接估值方法，不补造收入、利润率或现金流；后续披露足够时再拆分及建模。', '业务估值 S5；直接估值沿用既有情景', '可比公司口径、资金归属及未来投入均影响价值。'),
  ('研发团队、技术与集团应用场景', '沿用现有 AI 与芯片证据；技术能力能否形成壁垒仍需验证。', None, '投入规模不等于技术壁垒或股东价值。'),
  ('大模型、芯片及机器人研发', '暂作为同一投入期估值分组，业务边界明示；继续拆分需独立的经营与资金披露。', None, '研发交付、商业化与投入节奏。'),
  ('研发与产业合作待持续核验', '不从可比公司估值推断小米实际客户、合作条款或供应关系。', None, '技术生态与外部依赖变化。'),
  ('研发投入与资金口径须单列', '沿用原整体直接估值，暂不新增成本扣减；可比估值自带现金而小米由集团出资的口径风险保留在 T4/J-AI。', '费用与资金边界见 J-AI、J-EV-SPLIT', '不能将资金口径尚待裁决解释为已经消除重复计价。'),
 ],
}
ELEMENTS = ['客户细分','价值主张','渠道通路','客户关系','收入来源','核心资源','关键业务','重要合作','成本结构']
EVIDENCE = {
 'S1': {'B1':['2026 年二季度手机出货','2026 年二季度中国大陆：'], 'B2':['2026 年二季度手机出货'],
        'B3':['小米之家：'], 'B4':['全球月活（12 月）'], 'B7':['2025 年研发'],
        'B8':['存储成本：'], 'B9':['生态营业费用率','2026 年上半年分业务：']},
 'S2': {'B1':['AIoT 连接设备'], 'B2':['AIoT 连接设备'], 'B3':['小米之家：'], 'B4':['AIoT 连接设备'],
        'B5':['2025 年 IoT 收入','2026 年二季度 IoT'], 'B6':['AIoT 连接设备'],
        'B9':['生态营业费用率','2026 年上半年分业务：']},
 'S3': {'B1':['全球月活 2026','2025 年广告收入'], 'B2':['互联网服务：'], 'B3':['全球月活（12 月）'],
        'B4':['全球月活（12 月）'], 'B5':['互联网服务：','2025 年广告收入'], 'B6':['全球月活 2026'],
        'B7':['互联网服务：'], 'B9':['生态营业费用率','2026 年上半年分业务：']},
 'S4': {'B1':['新一代 SU7'], 'B2':['2025 年交付'], 'B3':['小米之家：'], 'B4':['新一代 SU7'],
        'B5':['2025 年交付','2026 年二季度汽车及 AI'], 'B6':['2026 年上半年资本开支'],
        'B7':['2026 年上半年资本开支'], 'B9':['汽车及 AI 分部经营开支：']},
 'S5': {'B2':['管理层：未来三年 AI','MiMo-V2.5'], 'B5':['MiMo-V2.5'],
        'B6':['管理层：未来三年 AI','MiMo-V2.5'], 'B7':['管理层：未来三年 AI','2025 年研发'],
        'B9':['管理层：未来三年 AI','大模型公司按收入']},
}

def lit(value):
    return 'NULL' if value is None else "'" + str(value).replace("'", "''") + "'"

def sql():
    out = []
    for sort, (code, name, boundary, cost, assets) in enumerate(BUSINESSES, 1):
        out.append(f"INSERT INTO vi_business_base(company_id,code,name,boundary,cost_allocation,asset_boundary,sort) VALUES ({CO},{lit(code)},{lit(name)},{lit(boundary)},{lit(cost)},{lit(assets)},{sort}) ON CONFLICT (company_id,code) DO NOTHING;")
        business = f"(SELECT id FROM vi_business_base WHERE company_id={CO} AND code={lit(code)})"
        for n, (title, content, metric, trend) in enumerate(CANVASES[code], 1):
            out.append(f"INSERT INTO vi_biz_model_base(company_id,business_id,code,element,title,content,metric,trend) VALUES ({CO},{business},'B{n}',{lit(ELEMENTS[n-1])},{lit(title)},{lit(content)},{lit(metric)},{lit(trend)}) ON CONFLICT ON CONSTRAINT vi_biz_model_uniq DO NOTHING;")
    out.append(f"UPDATE vi_sotp_segment_base g SET business_id=b.id FROM vi_business_base b,vi_model_base m WHERE g.model_id=m.id AND m.company_id={CO} AND b.company_id=m.company_id AND b.code=g.code AND g.business_id IS NULL;")
    pairs = [(code,element,prefix) for code,items in EVIDENCE.items() for element,prefixes in items.items() for prefix in prefixes]
    values = ','.join('('+','.join(map(lit,pair))+')' for pair in pairs)
    out.append(f"""INSERT INTO vi_lnk_biz_model_facts(biz_model_id,fact_id,"createdAt","updatedAt")
SELECT DISTINCT canvas.id,f.id,now(),now() FROM (VALUES {values}) e(business_code,canvas_code,fact_prefix)
JOIN vi_business_base b ON b.company_id={CO} AND b.code=e.business_code
JOIN vi_biz_model_base canvas ON canvas.business_id=b.id AND canvas.code=e.canvas_code
JOIN vi_fact_base f ON f.company_id=b.company_id AND f.title LIKE e.fact_prefix||'%'
ON CONFLICT DO NOTHING;""")
    out.append(f"""INSERT INTO vi_lnk_biz_model_facts(biz_model_id,fact_id,"createdAt","updatedAt")
SELECT DISTINCT b.id,l.fact_id,now(),now() FROM vi_biz_model_base b
JOIN vi_sotp_segment_base s ON s.business_id=b.business_id
JOIN vi_lnk_sotp_segment_facts l ON l.sotp_segment_id=s.id
WHERE b.company_id={CO} AND b.code IN ('B5','B9') ON CONFLICT DO NOTHING;""")
    # 旧金额与折价不变，只显式补齐计价身份和排重边界。
    boundaries = {
      'C1': ('账面价值','公司现金储备口径；理财已包含，C8 不再包含理财。经营所需现金 C5、受限资金 C7 与资金汇出成本 C6 另扣。'),
      'C2': ('账面价值','经营分部使用税后经营盈利，未扣融资利息；借款在此统一扣减。'),
      'C3': ('账面价值','沿用租赁负债处理：经营利润已扣使用权资产折旧、未扣租赁利息。'),
      'C4': ('账面价值','计息递延对价，在资产负债调整中扣减，不再在分部价值里另扣本金。'),
      'C5': ('研究估计','从 C1 中剔除经营所需资金；本次保持原分部盈利和期间现金流假设。'),
      'C6': ('研究估计','资金汇出成本单独扣减，未并入 C1、C5 或业务利润率。'),
      'C7': ('研究估计','从现金储备中剔除不可用资金，按原情景取值；不与 C5 重复。'),
      'C8': ('账面价值','不含 C1 已计的理财；对外股权收益不在业务盈利中资本化；外部基金份额由 C9 扣减。'),
      'C9': ('账面价值','C8 包含合并产业基金资产，此处扣除外部出资人权益；不与 C10 重复。'),
      'C10': ('账面价值','沿用集团少数股东权益扣减；各分部维持原归母比例口径。'),
      'C11': ('现值','沿用原补助资本化，已从各业务经营利润率中排除；这是其他估值调整，不是固定资产。'),
    }
    for code, (method,boundary) in boundaries.items():
        out.append(f"UPDATE vi_sotp_item_base SET treatment=coalesce(treatment,'单独计价'),valuation_method=coalesce(valuation_method,{lit(method)}),boundary=coalesce(boundary,{lit(boundary)}) WHERE model_id IN (SELECT id FROM vi_model_base WHERE company_id={CO}) AND code={lit(code)};")
    for code, name in [('S1','手机经营固定资产'),('S2','AIoT 经营固定资产'),('S3','互联网经营固定资产'),('S4','汽车工厂与生产设施'),('S5','AI 等创新业务经营资产')]:
        acode = 'A'+code[1:]
        boundary = '归属边界登记，未填独立资产估值；经营贡献已包含在该业务估值中，不另加账面价值或重置成本。'
        if code=='S5': boundary += '未来投入与集团现金的口径风险仍由 T4/J-AI 跟踪。'
        out.append(f"""INSERT INTO vi_sotp_item_base(model_id,business_id,code,name,kind,treatment,boundary,amount,haircut,as_of,basis)
SELECT m.id,b.id,{lit(acode)},{lit(name)},'固定资产','已含业务估值',{lit(boundary)},NULL,0,m.sotp_as_of,
'本项用于防止把经营资产与业务盈利重复计价；金额未知，不代表固定资产账面额为零。'
FROM vi_model_base m JOIN vi_business_base b ON b.company_id=m.company_id AND b.code={lit(code)}
WHERE m.company_id={CO} AND NOT EXISTS (SELECT 1 FROM vi_sotp_item_base i WHERE i.model_id=m.id AND i.code={lit(acode)});""")
    out.append(f"""INSERT INTO vi_lnk_sotp_item_facts(sotp_item_id,fact_id,"createdAt","updatedAt")
SELECT DISTINCT i.id,l.fact_id,now(),now() FROM vi_sotp_item_base i
JOIN vi_biz_model_base b ON b.business_id=i.business_id AND b.code IN ('B6','B7')
JOIN vi_lnk_biz_model_facts l ON l.biz_model_id=b.id
WHERE i.model_id IN (SELECT id FROM vi_model_base WHERE company_id={CO}) AND i.code IN ('A1','A2','A3','A4','A5') ON CONFLICT DO NOTHING;""")
    out.append(f"""INSERT INTO vi_change_log_base(company_id,change_date,title,target,old_value,new_value,reason,basis,verification)
SELECT {CO},'2026-10-26','打通多业务商业模式与业务／资产估值','业务分部、商业模式、经营分部估值、资产估值与调整',
'集团九项画布与分部估值没有业务关联；固定资产只能通过其他调整表达。',
'五块业务身份连接分业务画布和三情景估值；现金、投资与负债独立汇总；经营固定资产登记为已含业务估值，不重复加计。',
'按用户要求区分业务估值和资产估值，并明确共享费用、经营资产与未来投入的边界。',
'沿用已有事实与估值输入；不新增资产公允价值，也不裁决 T4／J-AI 的资金口径争议。',
'隔离迁移与空库重建通过；原三情景估值不变；独立固定资产、情景覆盖、缺失金额与重复计价边界已验证。'
WHERE NOT EXISTS(SELECT 1 FROM vi_change_log_base WHERE company_id={CO} AND title='打通多业务商业模式与业务／资产估值');""")
    return '\n\n'.join(out)

if __name__ == '__main__':
    target = Path(__file__).with_name('business_bridge.sql')
    target.write_text('BEGIN;\n'+sql()+'\nCOMMIT;\n')
    print(target)
