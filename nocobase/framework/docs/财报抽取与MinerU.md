# 财报抽取与 MinerU

## 选取来源

- 发布方提供官方 XBRL、Excel 或 HTML 表格时，优先读取结构化来源。PDF 有可靠文本层时，先用 `pdftotext -layout` 获取数字和列位置。
- 复杂表头、跨页表格、附注和扫描页可用 MinerU，提交所需页面即可。有可靠文本层时通常无需强制 OCR。
- 小米的年度与半年度报表可从[投资者关系网站](https://ir.mi.com/financial-information/annual-interim-reports)获取，其他季度查[业绩公告](https://ir.mi.com/financial-information/quarterly-results)。公告只披露合计时，明细留空。

## 调用 Precision Extract API

本机密钥是 `nocobase/.env` 里的 `MINERU_API_KEY`。调用时只将这一项读入进程环境，在 MinerU API 请求中使用 `Authorization: Bearer <token>`。

1. 向 `https://mineru.net/api/v4/extract/task` 发送 POST，传入公开 PDF 的 `url`、`model_version: "vlm"`、`enable_table: true`。用 `page_ranges` 指定从 1 开始的 PDF 文件页序，记录它与印刷页码的对应关系。
2. 用 `GET /api/v4/extract/task/{task_id}` 查询状态。状态为 `done` 后，从 `full_zip_url` 下载结果包，下载结果时无需传 Bearer 密钥。程序抽取优先读取结构化 JSON，Markdown 可用来查看上下文。
3. MinerU 无法访问官方链接时，可先下载公开 PDF，再使用官方批量上传接口。本机已安装投研工具时，也可用其中的 `scripts/mineru_parse.py`，传入 `--input`、`--output-dir`、`--source-id`。脚本从进程环境读取密钥。

已验证样本为[小米 2025 年报](https://www1.hkexnews.hk/listedco/listconews/sehk/2026/0428/2026042800526.pdf)第 278 个 PDF 页面。VLM 任务成功返回 Markdown 和 JSON，抽取的两列经营产生的现金金额与原文一致。 [MinerU 官方 API 文档](https://mineru.net/doc/docs/index_en/)

### 示例：提交、轮询并下载

从仓库根目录运行。示例只解析小米 2025 年度业绩公告的前两页，输出 ZIP 到本机临时目录。密钥只在 Python 进程内读取。

```sh
cd nocobase
python3 - <<'PY'
import json
import os
import tempfile
import time
from pathlib import Path
from urllib.request import Request, urlopen

token = os.getenv("MINERU_API_KEY")
if not token:
    for line in Path(".env").read_text().splitlines():
        name, sep, value = line.partition("=")
        if sep and name.strip() == "MINERU_API_KEY":
            token = value.strip().strip("\"'")
            break
if not token:
    raise SystemExit("缺少 MINERU_API_KEY")

endpoint = "https://mineru.net/api/v4/extract/task"

def api(url, payload=None):
    body = json.dumps(payload).encode() if payload is not None else None
    request = Request(url, data=body, headers={
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json",
    })
    with urlopen(request, timeout=30) as response:
        result = json.load(response)
    if result.get("code") != 0:
        raise RuntimeError(f"MinerU API 错误码：{result.get('code')}")
    return result["data"]

task = api(endpoint, {
    "url": "https://www1.hkexnews.hk/listedco/listconews/sehk/2026/0324/2026032400608.pdf",
    "model_version": "vlm",
    "page_ranges": "1-2",
    "enable_table": True,
    "enable_formula": False,
})

deadline = time.monotonic() + 300
while time.monotonic() < deadline:
    result = api(f"{endpoint}/{task['task_id']}")
    if result["state"] == "done":
        output = Path(tempfile.mkdtemp(prefix="mineru-")) / "result.zip"
        with urlopen(result["full_zip_url"], timeout=30) as response:
            output.write_bytes(response.read())
        print(output)
        break
    if result["state"] == "failed":
        raise SystemExit(f"解析失败，可用任务 ID 查询详情：{task['task_id']}")
    time.sleep(5)
else:
    raise SystemExit(f"等待超时，可继续查询任务：{task['task_id']}")
PY
```

### 长文档分段和拼接

**本项目每次提交的 PDF 最多 200 页，默认切成 180 页一段。** 表格密集、跨页多或曾超时的文档可用 170 页一段，并尽量在章节或报表边界切分。200 页是本项目的兼容上限，官方文档目前对部分 Precision Extract 接口列出的上限为 600 页。 [MinerU 官方接口限制](https://mineru.net/doc/docs/index_en/)

1. 对超过建议页数的整本财报，先按原 PDF 页序切成独立文件。例如 390 页分为 `p0001-0180.pdf`、`p0181-0360.pdf`、`p0361-0390.pdf`。需要避免切断跨页表时，可把边界提前几页。
2. 用[官方批量上传接口](https://mineru.net/doc/docs/index_en/)分轮提交各分片，分别保存任务 ID、原始起止页和结果 ZIP。某一段失败时，只重试该段。
3. 按**原始起始页**排列和拼接 Markdown，保留分段标题并检查图片相对路径。合并 JSON 时，把分片页码映射回原 PDF 页码。例如第二段从原件第 181 页开始，分片第 1 页就对应原件第 181 页。检查是否漏页、重页，以及跨页表是否带对了表头和单位。
4. 只需少数报表页时，可对接口能接受的公开 PDF 用 `page_ranges` 选页。现有本机投研脚本的 `--chunk-pages 180` 是用页范围分批请求并汇总 Markdown。遇到原文件本身超出限制时，先物理切分，再上传各分片。

装有 `qpdf` 时，可批量切分本地 `report.pdf`。要用 170 页一段，把 `chunk_size` 改为 170。

```sh
(
set -eu
chunk_size=180
total=$(qpdf --show-npages report.pdf)
mkdir -p parts
start=1
while [ "$start" -le "$total" ]; do
  end=$((start + chunk_size - 1))
  if [ "$end" -gt "$total" ]; then end=$total; fi
  part=$(printf 'parts/p%04d-%04d.pdf' "$start" "$end")
  qpdf --empty --pages report.pdf "$start-$end" -- "$part"
  start=$((end + 1))
done
)
```

## 入库前核对

- 每行保留来源链接、页码、原科目、原金额、币种及单位，再映射到工作台的标准科目。区分本期和比较期、单季和累计，以及千元和百万元。
- 核对资产＝负债＋权益、现金流从期初到期末的勾稽关系，遇到差异回查 PDF。审核后再更新 `companies/<代码_名称>/data/fin_stmt.json`，按目标公司现有流程检查和导入。
- 腾讯音乐已使用官方快照专用检查。其他公司切换到官方快照时，应同步调整对应的取数和校验入口，避免后续通用采集覆盖官方数据。
