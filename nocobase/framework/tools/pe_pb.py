"""最新市盈率TTM与市净率：akshare 取数 → 写入公司表（pe_ttm、pb、pe_pb_date），驾驶舱顶部读取。

数据来源（都经 akshare，市场口径，不是本模型算的）：
  · A 股＝东方财富 stock_value_em：最新交易日的 PE(TTM)、市净率。
  · 港股＝百度股市通 stock_hk_valuation_baidu：市盈率(TTM)、市净率各取最新一天；两者日期不同时取较早的一天。

和三大报表、自动采集无关，单独执行（在 nocobase/ 或任意目录）：
  python3 framework/tools/pe_pb.py              # 全部公司
  python3 framework/tools/pe_pb.py 600900.SH    # 只更新这几家
某家取数失败只跳过它（保留原值），最后退出码 1。
"""
import pathlib, subprocess, sys, warnings

ROOT = pathlib.Path(__file__).resolve().parents[2]
warnings.filterwarnings('ignore')


def psql(sql):
    p = subprocess.run([str(ROOT / 'psql.sh'), '-At', '-c', sql], capture_output=True, text=True, check=True)
    return p.stdout.strip()


def fetch(code):
    import akshare as ak
    sym, market = code.split('.')
    if market == 'HK':
        pe = ak.stock_hk_valuation_baidu(symbol=sym, indicator='市盈率(TTM)', period='近一年').dropna().iloc[-1]
        pb = ak.stock_hk_valuation_baidu(symbol=sym, indicator='市净率', period='近一年').dropna().iloc[-1]
        return float(pe['value']), float(pb['value']), str(min(pe['date'], pb['date']))[:10]
    row = ak.stock_value_em(symbol=sym).dropna(subset=['PE(TTM)', '市净率']).iloc[-1]
    return float(row['PE(TTM)']), float(row['市净率']), str(row['数据日期'])[:10]


if __name__ == '__main__':
    only = set(sys.argv[1:])
    codes = [c for c in psql("SELECT code FROM vi_company_base ORDER BY id").split('\n') if c and (not only or c in only)]
    failed = []
    for code in codes:
        try:
            pe, pb, day = fetch(code)
        except Exception as e:
            failed.append(code)
            print(f'{code}  取数失败：{e}')
            continue
        psql(f"UPDATE vi_company_base SET pe_ttm = {pe:.4f}, pb = {pb:.4f}, pe_pb_date = '{day}' WHERE code = '{code}'")
        print(f'{code}  市盈率TTM {pe:.2f}  市净率 {pb:.2f}  （{day}）')
    sys.exit(1 if failed else 0)
