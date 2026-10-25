"""Link the live Feishu model to shared inputs and add in-Base reconciliations.

Run once per phase. Existing legacy tables and their stored values are untouched.
"""

import argparse
import json
import pathlib
import subprocess

BASE = "PMnCb5BsGaME0ysW21uc7pHJnDb"
ROOT = pathlib.Path(__file__).resolve().parent
SNAP = ROOT / "snapshots" / "20260925T090807"
TABLES = {x["name"]: x["id"] for x in json.loads((SNAP / "tables.json").read_text())}


def cli(command, table, *args):
    argv = ["lark-cli", "base", command, "--base-token", BASE, "--table-id", TABLES[table], *args, "--as", "user"]
    p = subprocess.run(argv, capture_output=True, text=True)
    if p.returncode:
        raise RuntimeError(f"{command} {table}: {p.stderr or p.stdout}")
    result = json.loads(p.stdout)
    if not result.get("ok"):
        raise RuntimeError(f"{command} {table}: {p.stdout}")
    return result["data"]


def fields(table):
    return {f["name"]: f for f in cli("+field-list", table)["fields"]}


def create(table, definitions):
    existing = fields(table)
    missing = [x for x in definitions if x["name"] not in existing]
    if not missing:
        return
    args = ["--json", json.dumps(missing, ensure_ascii=False)]
    if any(x["type"] == "formula" for x in missing):
        args.append("--i-have-read-guide")
    cli("+field-create", table, *args)
    print("CREATED", table, [x["name"] for x in missing], flush=True)


def update_formula(table, name, expression):
    current = fields(table)[name]
    if current["type"] != "formula":
        raise RuntimeError(f"{table}.{name} is not a formula")
    if current["expression"] == expression:
        return
    body = {"name": name, "type": "formula", "expression": expression}
    if current.get("description"):
        body["description"] = current["description"]
    cli("+field-update", table, "--field-id", current["id"], "--json", json.dumps(body, ensure_ascii=False), "--i-have-read-guide", "--yes")
    print("UPDATED", table, name, flush=True)


def update_records(table, changes):
    if changes:
        ids = {name: field["id"] for name, field in fields(table).items()}
        keyed = {record_id: {ids[name]: value for name, value in values.items()} for record_id, values in changes.items()}
        cli("+record-batch-update", table, "--json", json.dumps({"update_records": keyed}, ensure_ascii=False))
        print("RECORDS", table, len(changes), flush=True)


def number(name):
    return {"name": name, "type": "number", "style": {"type": "plain", "precision": 4}}


def formula(name, expression):
    return {"name": name, "type": "formula", "expression": expression}


def setup():
    s = "V2_04情景控制"
    create(s, [number(x) for x in ["基准电价元", "基准其他净贡献亿元", "基准综合负担率", "基准派息率"]])
    rows = [json.loads(x) for x in (SNAP / (TABLES[s] + ".ndjson")).read_text().splitlines()]
    base = next(x for x in rows if x["情景"] == "基准")
    update_records(s, {base["record_id"]: {
        "基准电价元": 0.2807,
        "基准其他净贡献亿元": 45,
        "基准综合负担率": 0.1734,
        "基准派息率": 0.72,
    }})
    create(s, [formula("有效" + label, f'IF(ISBLANK([{source}]),[{s}].FILTER(CurrentValue.[情景]="基准").[{source}].FIRST(),[{source}])')
               for label, source in [("股本亿股", "股本亿股"), ("估值基年", "估值基年"), ("终值年份", "终值年份"), ("旧股价", "旧股价")]])
    create(s, [formula("最近股价元", '[V2_11市场观察].FILTER(AND(CurrentValue.[指标代码]="TENCENT-600900",CurrentValue.[当前版本]=TRUE(),CurrentValue.[质量有效]=1)).SORTBY([V2_11市场观察].[日期],FALSE()).[统一数值].FIRST()'),
               formula("最近股价日期", '[V2_11市场观察].FILTER(AND(CurrentValue.[指标代码]="TENCENT-600900",CurrentValue.[当前版本]=TRUE(),CurrentValue.[质量有效]=1)).SORTBY([V2_11市场观察].[日期],FALSE()).[日期].FIRST()')])
    i = "V2_05年度假设"
    for effective, raw, base_field in [("有效电价元", "电价元", "基准电价元"),
                                       ("有效其他净贡献亿元", "其他净贡献亿元", "基准其他净贡献亿元"),
                                       ("有效综合负担率", "综合负担率", "基准综合负担率"),
                                       ("有效派息率", "派息率", "基准派息率")]:
        create(i, [formula(effective, f'IF(ISBLANK([{raw}]),[{s}].FILTER(CurrentValue.[情景]="基准").[{base_field}].FIRST(),[{raw}])')])
    # A linked evidence record becomes visible from both ends for scenario inputs.
    create(s, [{"name": "来源证据", "type": "link", "link_table": TABLES["V2_02证据账本"],
                "bidirectional": True, "bidirectional_link_field_name": "情景假设"}])
    evidence = [json.loads(x) for x in (SNAP / (TABLES["V2_02证据账本"] + ".ndjson")).read_text().splitlines()]
    forecast = next(x["record_id"] for x in evidence if x["证据ID"] == "LEGACY-FORECAST")
    update_records(s, {x["record_id"]: {"来源证据": [{"id": forecast}]} for x in rows})


def switch():
    f = "V2_06财务引擎"
    for target, source in [("电价元", "有效电价元"), ("其他净贡献亿元", "有效其他净贡献亿元"),
                           ("综合负担率", "有效综合负担率"), ("派息率", "有效派息率")]:
        update_formula(f, target, f"[年度输入].[{source}].FIRST()")
    for target, source in [("股本亿股", "有效股本亿股"), ("估值基年", "有效估值基年"),
                           ("终值年份", "有效终值年份")]:
        update_formula(f, target, f"[情景输入].[{source}].FIRST()")
    v = "V2_07估值决策"
    for target, source in [("股本亿股", "有效股本亿股"), ("估值基年", "有效估值基年"),
                           ("终值年份", "有效终值年份"), ("旧股价", "有效旧股价")]:
        update_formula(v, target, f"[情景输入].[{source}].FIRST()")
    create(v, [
        formula("关联预测行数", "[预测行].[模型键].COUNTA()"),
        formula("同名模型行数", '[V2_06财务引擎].COUNTIF(CurrentValue.[情景名称]=[情景])'),
        formula("终年模型行数", '[V2_06财务引擎].COUNTIF(AND(CurrentValue.[情景名称]=[情景],CurrentValue.[年份]=[终值年份]))'),
        formula("预测期勾稽差额亿元", '[预测期现值亿元]-[V2_06财务引擎].FILTER(CurrentValue.[情景名称]=[情景]).[计划股息现值亿元].SUM()'),
    ])
    create(v, [formula("模型勾稽", 'IF(AND([关联预测行数]=[终值年份]-[估值基年],[同名模型行数]=[关联预测行数],[终年模型行数]=1,ABS([预测期勾稽差额亿元])<0.000001),"通过","缺行或引用不一致")')])
    update_formula(v, "条件DDM元", 'IF(AND([模型勾稽]="通过",[折现率]>[永续增长率],[股本亿股]>0),([预测期现值亿元]+[终值现值亿元])/[股本亿股],"")')
    update_formula(v, "现金支持DDM元", 'IF(AND([模型勾稽]="通过",[现金完整年数]=[终值年份]-[估值基年],[折现率]>[永续增长率],[股本亿股]>0),([预测行].[现金支持股息现值亿元].SUM()+[终年现金股息]*(1+[永续增长率])/([折现率]-[永续增长率])/POWER(1+[折现率],[终值年份]-[估值基年]))/[股本亿股],"")')
    create(v, [formula("市场观察价元", "[情景输入].[最近股价元].FIRST()"),
               formula("市场观察日期", "[情景输入].[最近股价日期].FIRST()")])
    u = "V2_12估值敏感性"
    for target, source in [("股本亿股", "有效股本亿股"), ("估值基年", "有效估值基年"), ("终值年份", "有效终值年份")]:
        update_formula(u, target, f"[基准情景].[{source}].FIRST()")
    update_formula(u, "条件DDM元", 'IF(AND([估值基年]=2025,[终值年份]=2035,[折现率]>[永续增长率],[股本亿股]>0),([预测期现值亿元]+[终年股息亿元]*(1+[永续增长率])/([折现率]-[永续增长率])/POWER(1+[折现率],[终值年份]-[估值基年]))/[股本亿股],"")')
    w = "V2_13参数影响沙盘"
    update_formula(w, "股本亿股", "[基准情景].[有效股本亿股].FIRST()")
    create(w, [formula("估值基年", "[基准情景].[有效估值基年].FIRST()"),
               formula("终值年份", "[基准情景].[有效终值年份].FIRST()")])
    current = fields(w)["试验价值元"]["expression"]
    revised = current.replace("2026-2025", "2026-[估值基年]").replace("2027-2025", "2027-[估值基年]").replace("2028-2025", "2028-[估值基年]").replace("2029-2025", "2029-[估值基年]").replace("2030-2025", "2030-[估值基年]").replace("2031-2025", "2031-[估值基年]").replace("2032-2025", "2032-[估值基年]").replace("2033-2025", "2033-[估值基年]").replace("2034-2025", "2034-[估值基年]").replace("2035-2025", "2035-[估值基年]").replace("[试验折现率],10)", "[试验折现率],[终值年份]-[估值基年])")
    revised = revised.replace("IF(AND([试验折现率]>", "IF(AND([估值基年]=2025,[终值年份]=2035,[试验折现率]>")
    update_formula(w, "试验价值元", revised)


def clear_duplicates():
    # These original cells remain editable overrides. Blank means use the shared base input.
    s = "V2_04情景控制"
    rows = [json.loads(x) for x in (SNAP / (TABLES[s] + ".ndjson")).read_text().splitlines()]
    changes = {}
    for x in rows:
        if x["情景"] != "基准":
            assert (x["股本亿股"], x["估值基年"], x["终值年份"], x["旧股价"]) == (244.68, 2025, 2035, 28.4)
            changes[x["record_id"]] = {k: None for k in ["股本亿股", "估值基年", "终值年份", "旧股价"]}
    update_records(s, changes)
    i = "V2_05年度假设"
    rows = [json.loads(x) for x in (SNAP / (TABLES[i] + ".ndjson")).read_text().splitlines()]
    changes = {}
    for x in rows:
        assert (x["电价元"], x["其他净贡献亿元"], x["综合负担率"], x["派息率"]) == (0.2807, 45, 0.1734, 0.72)
        changes[x["record_id"]] = {k: None for k in ["电价元", "其他净贡献亿元", "综合负担率", "派息率"]}
    update_records(i, changes)


def monitoring():
    h = "V2_11市场观察"
    create(h, [formula("原始采集条数", "[V2_14云端采集原始记录].COUNTIF(CurrentValue.[观察键V2]=[观察ID])"),
               formula("来源勾稽", 'IF(OR([指标代码]="TENCENT-600900",[指标代码]="CHINABOND-CGB10Y",[指标代码]="CJH-SX-LEVEL"),IF([原始采集条数]>0,"已匹配原始采集","缺少原始采集"),"Wind备份；核对原始文件")')])
    k = "V2_08跟踪任务"
    create(k, [{"name": "观察指标代码", "type": "text"}])
    rows = [json.loads(x) for x in (SNAP / (TABLES[k] + ".ndjson")).read_text().splitlines()]
    codes = {"K03": "CJH-SX-LEVEL", "K05": "CHINABOND-CGB10Y", "K11": "TENCENT-600900"}
    update_records(k, {x["record_id"]: {"观察指标代码": codes[x["任务ID"]]} for x in rows if x["任务ID"] in codes})
    condition = 'AND(CurrentValue.[指标代码]=[观察指标代码],CurrentValue.[当前版本]=TRUE(),CurrentValue.[质量有效]=1)'
    base = f'[V2_11市场观察].FILTER({condition}).SORTBY([V2_11市场观察].[日期],FALSE())'
    create(k, [formula("最新有效观察值", f'IF(ISBLANK([观察指标代码]),"",{base}.[统一数值].FIRST())'),
               formula("最新有效观察日", f'IF(ISBLANK([观察指标代码]),"",{base}.[日期].FIRST())'),
               formula("最新有效观察指标", f'IF(ISBLANK([观察指标代码]),"",{base}.[指标].FIRST())'),
               formula("最新有效观察单位", f'IF(ISBLANK([观察指标代码]),"",{base}.[单位].FIRST())'),
               formula("观察联动状态", 'IF(ISBLANK([观察指标代码]),"尚未接入自动观察",IF(ISBLANK([最新有效观察值]),"无有效观察","已联动；不自动修改估值假设"))')])
    q = "V2_09质量检查"
    create(q, [
        formula("现金桥接检查", 'IF([V2_07估值决策].FILTER(CurrentValue.[情景]="基准").[现金完整年数].FIRST()=10,"现金桥接已填；待证据核验","现金桥接缺失；现金估值阻断")'),
        formula("价格日期检查", 'IF([V2_04情景控制].FILTER(CurrentValue.[情景]="基准").[价格日期].FIRST()=[V2_04情景控制].FILTER(CurrentValue.[情景]="基准").[最近股价日期].FIRST(),"价格日期同日；估值基年仍需重置","旧价格与最近观察日不同；现时信号阻断")'),
        formula("模型行检查", 'IF([V2_07估值决策].COUNTIF(CurrentValue.[模型勾稽]="通过")=3,"三情景模型勾稽通过","模型行缺失或引用不一致")'),
        formula("负值观察检查", 'IF([V2_11市场观察].COUNTIF(AND(CurrentValue.[质量有效]=0,CurrentValue.[统一数值]<0))>0,"存在负值观察；已排除有效口径","未发现负值有效观察")'),
    ])
    body = 'SWITCH([检查ID],"Q06",[现金桥接检查],"Q08",[价格日期检查],"Q11",[模型行检查],"Q12",[负值观察检查],[状态])'
    create(q, [formula("实时勾稽状态", body)])
    update_formula(q, "实时勾稽状态", body)


def present():
    s = "V2_04情景控制"
    views = cli("+view-list", s)["views"]
    if not any(x["name"] == "日常工作视图" for x in views):
        cli("+view-create", s, "--json", json.dumps({"name": "日常工作视图", "type": "grid"}, ensure_ascii=False))
    view_fields = {
        s: ("日常工作视图", ["情景", "电量系数", "电价系数", "付现成本系数", "折现率", "永续增长率",
                              "基准电价元", "基准其他净贡献亿元", "基准综合负担率", "基准派息率",
                              "有效股本亿股", "有效估值基年", "有效终值年份", "来源证据", "最近股价元", "最近股价日期"]),
        "V2_05年度假设": ("日常工作视图", ["年度键", "年份", "电量亿千瓦时", "电价元", "有效电价元",
                                       "付现成本亿元", "折旧亿元", "利息亿元", "有效其他净贡献亿元",
                                       "有效综合负担率", "有效派息率", "证据状态"]),
        "V2_07估值决策": ("日常工作视图", ["情景", "条件DDM元", "模型勾稽", "预测期勾稽差额亿元",
                                       "终值占比", "现金支持DDM元", "市场观察价元", "市场观察日期",
                                       "关注价10元", "关注价30元", "决策状态"]),
        "V2_08跟踪任务": ("日常工作视图", ["任务ID", "跟踪指标", "最新有效观察指标", "最新有效观察值",
                                       "最新有效观察单位", "最新有效观察日", "观察联动状态", "频率",
                                       "触发阈值", "触发后动作"]),
        "V2_09质量检查": ("表格", ["检查ID", "问题", "级别", "实时勾稽状态", "完成条件", "影响范围", "状态"]),
    }
    for table, (view, names) in view_fields.items():
        available = fields(table)
        if any(name not in available for name in names):
            raise RuntimeError(f"Unknown field in {table}: {set(names) - set(available)}")
        cli("+view-set-visible-fields", table, "--view-id", view,
            "--json", json.dumps({"visible_fields": names}, ensure_ascii=False))
        print("VIEW", table, view, flush=True)
    guide = "V2_00使用指南"
    rows = [json.loads(x) for x in (SNAP / (TABLES[guide] + ".ndjson")).read_text().splitlines()]
    row = next(x for x in rows if x["主题"] == "交互与重算")
    update_records(guide, {row["record_id"]: {
        "规则与操作": "基准情景行统一保存电价、其他净贡献、综合负担率、派息率、股本和估值年份。年度假设对应原始列留空时自动读取基准值；只在某年需要不同数值时填写该年原始列。情景的股本和估值年份留空时也读取基准行。财务引擎、估值和敏感性自动重算。市场观察仅供核对，不自动覆盖长期折现率或估值基年。修改输入须在变更日志记录证据与理由。"
    }})
    log = "V2_10变更日志"
    cli("+record-batch-create", log, "--json", json.dumps({"create_records": [{
        "变更ID": "V2-LINK-20260925",
        "时间": "2026-09-25",
        "对象": "年度假设、情景控制、估值链、市场观察与质量检查",
        "旧值": "年度共同参数逐年重复、情景股本和估值年份重复、跟踪任务最新观察为固定文字",
        "新值": "基准输入加单年覆盖；公式贯通财务引擎、估值与敏感性；市场观察自动回查原始采集并汇总到跟踪任务；质量检查实时勾稽",
        "原因": "减少重复录入并保留原始输入、证据与估值结果之间的可追溯关系",
        "证据定位": "2026-09-25线上快照与逐行数值对账；V2_04来源证据连接LEGACY-FORECAST",
        "验证状态": "三情景、30财务行、25敏感性、5沙盘改造前后数值一致；现金口径仍待核验"
    }]}, ensure_ascii=False))
    print("LOGGED", flush=True)


def discount():
    s = "V2_04情景控制"
    create(s, [number("基准无风险利率pct"), number("基准风险溢价pct"), {"name": "利率基准日期", "type": "text"}])
    scenario_rows = [json.loads(x) for x in (SNAP / (TABLES[s] + ".ndjson")).read_text().splitlines()]
    base = next(x for x in scenario_rows if x["情景"] == "基准")
    update_records(s, {base["record_id"]: {"基准无风险利率pct": 1.69, "基准风险溢价pct": 3.5,
                                            "利率基准日期": "2026-08-31"}})
    create(s, [formula("计算基准折现率", 'IF(AND(NOT(ISBLANK([基准无风险利率pct])),NOT(ISBLANK([基准风险溢价pct]))),ROUND([基准无风险利率pct]+[基准风险溢价pct],1)/100,"")')])
    create(s, [formula("有效折现率", f'IF(ISBLANK([折现率]),[{s}].FILTER(CurrentValue.[情景]="基准").[计算基准折现率].FIRST(),[折现率])')])
    # Wire every downstream valuation path to the same effective rate.
    update_formula("V2_06财务引擎", "折现率", "[情景输入].[有效折现率].FIRST()")
    update_formula("V2_07估值决策", "折现率", "[情景输入].[有效折现率].FIRST()")
    update_formula("V2_12估值敏感性", "折现率", "[基准情景].[有效折现率].FIRST()+[利率偏移]")
    update_formula("V2_13参数影响沙盘", "试验折现率", "[基准情景].[有效折现率].FIRST()+[折现率变动]")
    # The old 5.2% value is now reproduced by 1.69% + 3.5%, rounded to 0.1 percentage point.
    assert base["折现率"] == 0.052
    update_records(s, {base["record_id"]: {"折现率": None}})
    rate_fields = ["情景", "电量系数", "电价系数", "付现成本系数", "折现率", "有效折现率",
                   "永续增长率", "基准无风险利率pct", "基准风险溢价pct", "利率基准日期",
                   "基准电价元", "基准其他净贡献亿元", "基准综合负担率", "基准派息率",
                   "有效股本亿股", "有效估值基年", "有效终值年份", "来源证据", "最近股价元", "最近股价日期"]
    cli("+view-set-visible-fields", s, "--view-id", "日常工作视图",
        "--json", json.dumps({"visible_fields": rate_fields}, ensure_ascii=False))
    print("DISCOUNT_LINKED", flush=True)


def annual_checks():
    i = "V2_05年度假设"
    cash = ["归属折旧加回亿元", "非现金收益扣除亿元", "投资现金分红亿元", "其他现金调整亿元",
            "营运资本增加亿元", "维持资本亿元", "扩张资本亿元", "净借款亿元", "最低现金补充亿元"]
    expression = 'IF(AND(' + ','.join(f'NOT(ISBLANK([{name}]))' for name in cash) + '),"现金项已填；仍待证据核验","现金桥接缺项")'
    create(i, [formula("现金桥接实时状态", expression)])
    cli("+view-set-visible-fields", i, "--view-id", "日常工作视图", "--json", json.dumps({"visible_fields": [
        "年度键", "年份", "电量亿千瓦时", "电价元", "有效电价元", "付现成本亿元", "折旧亿元",
        "利息亿元", "有效其他净贡献亿元", "有效综合负担率", "有效派息率", "证据状态", "现金桥接实时状态"
    ]}, ensure_ascii=False))
    update_formula("年度数据", "折旧加财务费用_亿", 'IF(OR(ISBLANK([折旧摊销_亿]),ISBLANK([财务费用_亿])),"",ROUND([折旧摊销_亿]+[财务费用_亿],2))')
    print("ANNUAL_CHECKS", flush=True)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("phase", choices=["setup", "switch", "clear", "monitor", "present", "discount", "annual-checks"])
    args = parser.parse_args()
    {"setup": setup, "switch": switch, "clear": clear_duplicates, "monitor": monitoring,
     "present": present, "discount": discount, "annual-checks": annual_checks}[args.phase]()


if __name__ == "__main__":
    main()
