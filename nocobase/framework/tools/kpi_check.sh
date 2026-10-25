#!/bin/sh
# 不开浏览器检查驾驶舱“关键读数”：导出数据 → 把驾驶舱脚本转成 JS → 在 Node 里模拟 RunJS 的 ctx 执行 → 打印统计数字与表格。
# 用法：framework/tools/kpi_check.sh 01810.HK [试算倍数]      需要 node；esbuild 由 npx 临时下载
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/../.." && pwd)"
OUT="${TMPDIR:-/tmp}/vi_kpi_check"
mkdir -p "$OUT"
cd "$ROOT"
for c in vi_company vi_model vi_valuation vi_projection vi_check vi_collector vi_sotp; do
  nb api resource list --resource "$c" --page-size 2000 -j > "$OUT/$c.json" 2>/dev/null
done
cd "$ROOT/framework"
python3 -c "import sys, build_overview as bo; open(sys.argv[2], 'w').write('export default async function run(ctx) {\n' + bo.KPI.replace('__COMPANY__', sys.argv[1]) + '\n}\n')" "$1" "$OUT/kpi.jsx"
npx --yes esbuild@0.21.5 "$OUT/kpi.jsx" --loader:.jsx=jsx --jsx-factory=ctx.libs.React.createElement --format=esm --outfile="$OUT/kpi.mjs" --log-level=warning
node "$HERE/kpi_harness.mjs" "$OUT/kpi.mjs" "$OUT" ${2:-}
