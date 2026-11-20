#!/usr/bin/env bash
set -euo pipefail
umask 077
cd "$(dirname "$0")"

mkdir -p backups
archive="backups/nocobase_$(TZ=Asia/Shanghai date +%Y%m%d_%H%M%S).sql.gz"
temporary=$(mktemp backups/.partial.XXXXXX)
trap 'unlink "$temporary"' EXIT

{
  docker compose exec -T postgres pg_dump -U nocobase -d nocobase --clean --if-exists &&
    # Refresh the two calculation caches in dependency order.
    printf '\nSET search_path = public;\nREFRESH MATERIALIZED VIEW vi_stmt_cache;\nREFRESH MATERIALIZED VIEW vi_fin_history_cache;\n'
} | gzip -c > "$temporary"

gzip -t "$temporary"
# Publish only a complete archive and never overwrite a backup from the same second.
ln "$temporary" "$archive"
printf '已备份：%s（%s）\n' "$archive" "$(du -h "$archive" | cut -f1)"
