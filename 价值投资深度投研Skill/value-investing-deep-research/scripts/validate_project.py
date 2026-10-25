#!/usr/bin/env python3
"""Read-only validator for a value-investing research project."""

from __future__ import annotations

import argparse
import csv
import json
import re
import sys
import zipfile
from pathlib import Path
from xml.etree import ElementTree as ET


EXPECTED_DIRS = {"01_过程代码", "02_参考资料", "03_最终输出"}
CODE_SUFFIXES = {".py", ".js", ".mjs", ".ts", ".sh", ".ipynb"}
REQUIRED_HTML_TOPICS = (
    "价值投资",
    "产业",
    "产品",
    "客户",
    "商业模式",
    "竞争壁垒",
    "估值",
    "安全边际",
    "跟踪指标",
    "来源",
)
REQUIRED_SHEET_FUNCTIONS = ("总览", "输入", "历史", "预测", "估值", "敏感", "校验")


def check(condition: bool, text: str, evidence: str = "") -> dict:
    return {"text": text, "passed": bool(condition), "evidence": evidence}


def validate_xlsx(path: Path) -> tuple[list[str], int, bool, str]:
    try:
        with zipfile.ZipFile(path) as archive:
            bad_file = archive.testzip()
            workbook_xml = archive.read("xl/workbook.xml")
            root = ET.fromstring(workbook_xml)
            namespace = {"x": "http://schemas.openxmlformats.org/spreadsheetml/2006/main"}
            sheets = [node.attrib.get("name", "") for node in root.findall(".//x:sheet", namespace)]
            formula_count = 0
            error_tokens = []
            for name in archive.namelist():
                if re.fullmatch(r"xl/worksheets/sheet\d+\.xml", name):
                    text = archive.read(name).decode("utf-8", errors="ignore")
                    formula_count += len(re.findall(r"<(?:[A-Za-z0-9_]+:)?f(?:\s|>)", text))
                    error_tokens.extend(token for token in ("#REF!", "#DIV/0!", "#VALUE!", "#NAME?", "#N/A") if token in text)
            return sheets, formula_count, bad_file is None and not error_tokens, ", ".join(sorted(set(error_tokens)))
    except Exception as exc:
        return [], 0, False, str(exc)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("project_dir")
    parser.add_argument("--json", action="store_true")
    args = parser.parse_args()

    project = Path(args.project_dir).expanduser().resolve()
    results = []

    root_dirs = {item.name for item in project.iterdir() if item.is_dir()} if project.exists() else set()
    root_files = [item.name for item in project.iterdir() if item.is_file()] if project.exists() else []
    results.append(check(project.is_dir(), "项目目录存在", str(project)))
    results.append(check(root_dirs == EXPECTED_DIRS, "根目录只有三个规范子目录", f"实际目录: {sorted(root_dirs)}"))
    results.append(check(not root_files, "项目根目录没有散落文件", f"实际文件: {root_files}"))

    code_dir = project / "01_过程代码"
    ref_dir = project / "02_参考资料"
    out_dir = project / "03_最终输出"
    code_files = [p for p in code_dir.rglob("*") if p.is_file() and p.suffix.lower() in CODE_SUFFIXES] if code_dir.exists() else []
    results.append(check(bool(code_files), "过程代码目录包含可复现脚本", f"{len(code_files)} 个代码文件"))

    source_index = ref_dir / "00_来源清单.csv"
    ref_files = [p for p in ref_dir.iterdir() if p.is_file() and p.name != source_index.name] if ref_dir.exists() else []
    results.append(check(source_index.is_file(), "参考资料含00_来源清单.csv"))
    results.append(check(len(ref_files) >= 3, "参考资料至少包含三份实际资料", f"{len(ref_files)} 个文件"))
    if source_index.is_file():
        with source_index.open("r", encoding="utf-8-sig", newline="") as handle:
            row_count = max(sum(1 for _ in csv.reader(handle)) - 1, 0)
        results.append(check(row_count >= 3, "来源清单至少登记三条来源", f"{row_count} 条"))

    output_files = [p for p in out_dir.iterdir() if p.is_file()] if out_dir.exists() else []
    html_files = [p for p in output_files if p.suffix.lower() == ".html"]
    xlsx_files = [p for p in output_files if p.suffix.lower() == ".xlsx"]
    results.append(check(len(output_files) == 2, "最终输出目录严格只有两个文件", f"实际: {[p.name for p in output_files]}"))
    results.append(check(len(html_files) == 1, "最终输出包含一个HTML"))
    results.append(check(len(xlsx_files) == 1, "最终输出包含一个Excel"))

    if html_files:
        html = html_files[0].read_text(encoding="utf-8", errors="ignore")
        missing_topics = [topic for topic in REQUIRED_HTML_TOPICS if topic not in html]
        xlsx_linked = any(re.search(rf'href=["\'][^"\']*{re.escape(file.name)}["\']', html) for file in xlsx_files)
        external_assets = bool(re.search(r"<script[^>]+src=|<link[^>]+rel=[\"']stylesheet", html, re.I))
        results.append(check(not missing_topics, "HTML覆盖价值投资必备主题", f"缺失: {missing_topics}"))
        results.append(check(xlsx_linked, "HTML包含同目录Excel相对链接"))
        results.append(check(not external_assets, "HTML不依赖外部脚本或样式"))

    if xlsx_files:
        sheets, formula_count, xlsx_ok, xlsx_error = validate_xlsx(xlsx_files[0])
        missing_functions = [word for word in REQUIRED_SHEET_FUNCTIONS if not any(word in sheet for sheet in sheets)]
        results.append(check(xlsx_ok, "Excel压缩结构和错误标记检查通过", xlsx_error))
        results.append(check(formula_count > 0, "Excel包含实际计算公式", f"{formula_count} 个公式"))
        results.append(check(not missing_functions, "Excel覆盖模型必备功能", f"工作表: {sheets}; 缺失功能: {missing_functions}"))

    passed = all(item["passed"] for item in results)
    payload = {
        "project": str(project),
        "passed": passed,
        "passed_checks": sum(item["passed"] for item in results),
        "total_checks": len(results),
        "checks": results,
    }

    if args.json:
        print(json.dumps(payload, ensure_ascii=False, indent=2))
    else:
        for item in results:
            print(f"{'PASS' if item['passed'] else 'FAIL'} | {item['text']} | {item['evidence']}")
        print(f"{'PASS' if passed else 'FAIL'} | {payload['passed_checks']}/{payload['total_checks']}")

    raise SystemExit(0 if passed else 1)


if __name__ == "__main__":
    main()
