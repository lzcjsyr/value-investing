"""Keep report fields stable across AKShare's parameter and column renames."""

from inspect import signature

import akshare as ak


_HK_COLUMNS = {
    '报告期': 'REPORT_DATE',
    '报告期类型代码': 'DATE_TYPE_CODE',
    '项目代码': 'STD_ITEM_CODE',
    '项目名称': 'STD_ITEM_NAME',
    '金额': 'AMOUNT',
}
_US_COLUMNS = {'报告期': 'REPORT_DATE', '项目名称': 'ITEM_NAME', '金额': 'AMOUNT'}


def sina_report(code, statement):
    fetch = ak.stock_financial_report_sina
    if 'stock' in signature(fetch).parameters:
        return fetch(stock=code, symbol=statement)
    return fetch(symbol=code, indicator=statement)


def eastmoney_report(code, statement, market):
    if market == 'HK':
        fetch, period, columns = ak.stock_financial_hk_report_em, '报告期', _HK_COLUMNS
    else:
        fetch, period, columns = ak.stock_financial_us_report_em, '单季报', _US_COLUMNS
    if 'stock' in signature(fetch).parameters:
        return fetch(stock=code, symbol=statement, indicator=period)
    return fetch(symbol=code, indicator=statement, period=period).rename(columns=columns)
