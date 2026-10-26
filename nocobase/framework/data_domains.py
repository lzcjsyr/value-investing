"""业务驱动和财务结果分开；指标定义共用，页面按类别取数。

金额不决定归类：合同/合约销售额、单位售价属于业务；收入、利润、现金和资产负债属于财务。
"""
import re

OPERATING_NAMES = {
    '发电量', '浆纸销量（管理层口径）', '新签合同总额', '建筑业务新签合同额',
    '地产合约销售额', '房屋建筑新开工面积', '在线音乐付费用户',
    '单个付费用户月均收入（ARPPU）', '在线音乐月活跃用户', '竞品月活：汽水音乐',
    '智能手机出货量', '智能手机ASP', '汽车交付量', '汽车ASP', '全球月活跃用户',
    '全球月活跃用户（12 月）', 'AIoT平台连接设备数（不含手机和平板）',
    '拥有五件及以上AIoT设备的用户数',
}

# 三大报表里有的科目不另存：这类指标的来源方式是“报表计算”（写报表公式，从财务数据实时算），不出现在财务补充里。


def business_description(automatic=False):
    downstream = ('被【驾驶舱】【自动检查】【重点跟踪】引用；【重要事实】通过“相关指标”引用本序列。')
    if automatic:
        return ('自动采集的水位、来水、纸浆价格等高频经营环境数据；'
                '引用【指标】【原始采集记录】，保留采集地址；' + downstream +
                '股价见【驾驶舱】，利率与汇率见【宏观数据】。')
    return ('按期披露的量、价、订单、面积、用户与设备等经营指标及解读；'
            '引用【指标】【来源文档】；' + downstream +
            '收入、利润、毛利率、现金与负债见【财务数据】。')


def category(name):
    if name in OPERATING_NAMES:
        return '经营'
    return '财务' if re.search('收入|利润|毛利|费用|开支|损益|现金|负债|借款|应收|应付|减值|回购|股息|收益', name) else '其他'


def business_scope(company, automatic=False):
    if automatic:
        return {'logic': '$and', 'items': [
            {'path': 'metric.source_kind', 'operator': '$eq', 'value': '自动采集'},
            {'path': 'metric.category', 'operator': '$in', 'value': ['经营', '水文', '商品']},
            {'logic': '$or', 'items': [
                {'path': 'metric.company_id', 'operator': '$eq', 'value': company['id']},
                {'path': 'metric.used_by_codes', 'operator': '$includes', 'value': ',' + company['code'] + ','}]}]}
    return {'logic': '$and', 'items': [
        {'path': 'metric.company_id', 'operator': '$eq', 'value': company['id']},
        {'path': 'metric.category', 'operator': '$eq', 'value': '经营'},
        {'path': 'metric.source_kind', 'operator': '$in', 'value': ['公司披露', '年报', '手工整理']} ]}


def financial_supplement_scope(company):
    return {'logic': '$and', 'items': [
        {'path': 'metric.company_id', 'operator': '$eq', 'value': company['id']},
        {'path': 'metric.category', 'operator': '$eq', 'value': '财务'},
        {'path': 'metric.source_kind', 'operator': '$ne', 'value': '报表计算'}]}
