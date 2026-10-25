#!/usr/bin/env python3
"""Create the canonical three-part directory for one equity research project."""

from __future__ import annotations

import argparse
import re
from datetime import date
from pathlib import Path


def safe_component(value: str) -> str:
    value = value.strip()
    value = re.sub(r"[\\/:*?\"<>|]+", "_", value)
    value = re.sub(r"\s+", "", value)
    if not value or value in {".", ".."}:
        raise ValueError("公司简称和证券代码不能为空")
    return value


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", required=True, help="项目所在工作区")
    parser.add_argument("--company", required=True, help="公司简称")
    parser.add_argument("--ticker", required=True, help="证券代码")
    parser.add_argument("--date", default=date.today().strftime("%Y%m%d"), help="YYYYMMDD")
    args = parser.parse_args()

    if not re.fullmatch(r"\d{8}", args.date):
        raise SystemExit("--date 必须为 YYYYMMDD")

    company = safe_component(args.company)
    ticker = safe_component(args.ticker)
    root = Path(args.root).expanduser().resolve()
    project = root / f"{company}_{ticker}_价值投资深度投研_{args.date}"
    project.mkdir(parents=True, exist_ok=True)

    for name in ("01_过程代码", "02_参考资料", "03_最终输出"):
        (project / name).mkdir(exist_ok=True)

    print(project)


if __name__ == "__main__":
    main()
