#!/bin/sh
# 不开浏览器检查「财务数据」页：导出数据 → 把 build_finstmt.JS 转成 JS → 在 Node 里模拟 RunJS 的 ctx 执行 → 打印矩阵。
# 用法：framework/tools/finstmt_check.sh 600900.SH [报表] [窗口] [累计|单季]     需要 node；esbuild 由 npx 临时下载
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/../.." && pwd)"
OUT="${TMPDIR:-/tmp}/vi_finstmt_check"
mkdir -p "$OUT"
cd "$ROOT"
./psql.sh -At -c "SELECT row_to_json(t) FROM vi_company_base t" > "$OUT/vi_company.jsonl"
./psql.sh -At -c "SELECT row_to_json(t) FROM vi_fin_stmt_base t" > "$OUT/vi_fin_stmt.jsonl"
cd "$ROOT/framework"
python3 -c "import sys, build_finstmt as bf; open(sys.argv[2], 'w').write('export default async function run(ctx) {\n' + bf.script({'code': sys.argv[1]}) + '\n}\n')" "$1" "$OUT/finstmt.jsx"
npx --yes esbuild@0.21.5 "$OUT/finstmt.jsx" --loader:.jsx=jsx --jsx-factory=ctx.libs.React.createElement --format=esm --outfile="$OUT/finstmt.mjs" --log-level=warning
node "$HERE/finstmt_harness.mjs" "$OUT/finstmt.mjs" "$OUT" "${2:-}" "${3:-}" "${4:-}"
