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


def category(name):
    if name in OPERATING_NAMES:
        return '经营'
    return '财务' if re.search('收入|利润|毛利|费用|开支|损益|现金|负债|借款|应收|应付|减值|回购|股息|收益', name) else '其他'


# 以下范围都按“指标”筛（数据底稿的这几个标签每个指标一行，逐期数据在指标详情里）
def business_scope(company, automatic=False):
    if automatic:
        return {'logic': '$and', 'items': [
            {'path': 'source_kind', 'operator': '$eq', 'value': '自动采集'},
            {'path': 'category', 'operator': '$in', 'value': ['经营', '水文', '商品']},
            {'logic': '$or', 'items': [
                {'path': 'company_id', 'operator': '$eq', 'value': company['id']},
                {'path': 'used_by_codes', 'operator': '$includes', 'value': ',' + company['code'] + ','}]}]}
    return {'logic': '$and', 'items': [
        {'path': 'company_id', 'operator': '$eq', 'value': company['id']},
        {'path': 'category', 'operator': '$eq', 'value': '经营'},
        {'path': 'source_kind', 'operator': '$in', 'value': ['公司披露', '年报', '手工整理']} ]}


def financial_supplement_scope(company):
    return {'logic': '$and', 'items': [
        {'path': 'company_id', 'operator': '$eq', 'value': company['id']},
        {'path': 'category', 'operator': '$eq', 'value': '财务'},
        {'path': 'source_kind', 'operator': '$ne', 'value': '报表计算'}]}
