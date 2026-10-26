"""将已有论点中的反证整理到四家公司的风险页，不引入新的事实或估值数值。已存在的风险跳过（2026-10-24 已执行，现为空操作）；
预警指标在页面上关联（2026-10-26 起跟踪事项并入指标，见 migrate_data_layer.py）。"""
import json
from pathlib import Path
import build_pages as bp

OUT = bp.ROOT / 'checks' / 'alignment_20261026'
ITEMS = {
 '002078.SZ': [
  ('成本优势被周期与纸价下行压缩', '行业与竞争', 'T1', ['J-M', 'J-P']),
  ('新产能爬坡和产品结构转型未达预期', '经营与执行', 'T2', ['J-Q', 'J-M']),
  ('扩产高峰延后，资本开支持续占用现金', '财务与资产质量', 'T3', ['J-CAPEX', 'J-DEBT']),
  ('扩张后派息率仍未提高', '治理与资本配置', 'T4', ['J-PAYOUT']),
 ],
 '601668.SH': [
  ('新签合同不足或订单向收入转化放缓', '经营与执行', 'T2', ['J-Q', 'J-P']),
  ('应收与合同资产回收低于模型预期', '财务与资产质量', 'T3', ['J-WC']),
  ('地产及工程减值吞噬利润', '财务与资产质量', 'T7', ['J-IMP']),
  ('利润和回款未转为持续股东回报', '治理与资本配置', 'T4', ['J-PAYOUT', 'J-DEBT']),
 ],
 '01698.HK': [
  ('免费音乐分流，核心付费用户与提价受压', '行业与竞争', 'T3', ['J-Q', 'J-P']),
  ('曲库与上游议价优势收窄', '技术与替代', 'T1', ['J-M']),
  ('利润和超额现金未按预期回到股东', '治理与资本配置', 'T5', ['J-PAYOUT', 'J-CASH', 'J-SOTP-C']),
  ('喜马拉雅及多元变现的整合回报不足', '经营与执行', 'T4', ['J-CAPEX', 'J-SOTP-E']),
  ('外部持股与汇率导致港股估值波动', '估值与市场', 'T7', ['J-SOTP-I', 'J-FX']),
 ],
 '01810.HK': [
  ('存储涨价后手机毛利率恢复不及预期', '行业与竞争', 'T2', ['J-PHONE', 'J-MEM']),
  ('汽车交付和稳态利润率低于假设', '经营与执行', 'T3', ['J-EV', 'J-EV-SPLIT']),
  ('AI 直接估值缺少可验证收入支撑', '估值与市场', 'T4', ['J-AI']),
  ('生态变现放缓且费用分摊高于预期', '经营与执行', 'T1', ['J-NET', 'J-AIOT', 'J-OPEX']),
  ('账面现金、投资和回购价值无法充分兑现', '治理与资本配置', 'T8', ['J-CASH', 'J-INV', 'J-IND', 'J-REPAT']),
 ],
}

# 依据现有论点及模型路径作初始定性分级；None 表示尚未确认估值覆盖程度。
RATINGS = {
 '002078.SZ': [('中','中','已计入悲观情景'), ('中','中','已计入悲观情景'), ('中','高',None), ('中','高','未计入估值')],
 '601668.SH': [('中','中','已计入悲观情景'), ('高','高',None), ('中','高','已计入基准情景'), ('中','中',None)],
 '01698.HK': [('中','高','已计入悲观情景'), ('中','中','已计入悲观情景'), ('中','高','已计入基准情景'), ('中','中',None), ('中','中','已计入悲观情景')],
 '01810.HK': [('高','中','已计入悲观情景'), ('中','高','已计入悲观情景'), ('高','高','未计入估值'), ('中','中','已计入悲观情景'), ('低','高','已计入悲观情景')],
}


def rating(code, index):
    probability, impact, treatment = RATINGS[code][index]
    return dict(probability=probability, impact=impact, treatment=treatment)


def rows(table):
    return bp.nb_json('resource', 'list', '--resource', 'vi_' + table, '--page-size', '2000')['data']


if __name__ == '__main__':
    theses, judgments, existing = [rows(t) for t in ('thesis', 'judgment', 'risk')]
    payload = []
    for co in bp.companies():
        for i, (title, category, tcode, jcodes) in enumerate(ITEMS.get(co['code'], []), 1):
            code = 'R' + str(i)
            if any(r['company_id'] == co['id'] and r['code'] == code for r in existing):
                continue
            own = lambda data: [r for r in data if r['company_id'] == co['id']]
            ts = [r for r in own(theses) if r['code'] == tcode]
            js = [r for r in own(judgments) if r['code'] in jcodes]
            if not ts:
                raise RuntimeError(f'{co["code"]} 缺少论点 {tcode}，禁止补造')
            t = ts[0]
            payload.append(dict(
                company_id=co['id'], code=code, title=title, category=category,
                mechanism=t.get('bear_case') or t.get('mind_changer'),
                **rating(co['code'], i-1), horizon='1—3 年', trend='稳定', status='监控中',
                impact_estimate='整理自已有论点 ' + tcode + '：' + (t.get('model_impact') or t.get('verdict') or '')
                    + '\n可能性与冲击为初始研究判断，非统计概率；本次未改变模型参数，也未新增定量损失测算。',
                mitigants=t.get('bull_case'),
                early_warning=t.get('mind_changer'),
                response='触发后复核相关论点和假设依据，再决定是否调整模型。原论点改判条件：' + (t.get('mind_changer') or ''),
                theses=[t['id']], judgments=[r['id'] for r in js],
            ))
    (OUT / 'risk_payload.json').write_text(json.dumps(payload, ensure_ascii=False, indent=2))
    if payload:
        result = bp.nb_json('resource', 'create', '--resource', 'vi_risk', '--values', json.dumps(payload, ensure_ascii=False))
        (OUT / 'risk_created.json').write_text(json.dumps(result, ensure_ascii=False, indent=2))
    print('新增风险', len(payload), flush=True)
