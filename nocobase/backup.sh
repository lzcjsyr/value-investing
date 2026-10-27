#!/bin/sh
# 备份整个 NocoBase 数据库（全部公司的表、视图、页面与工作流配置）
#   db/latest.sql            最新一份纯文本导出，随代码提交到 git（每次覆盖）
#   backups/<时间>.sql.gz    本机历史备份，不进 git
# 恢复：./psql.sh -f db/latest.sql
#   或：gunzip -c backups/<文件>.sql.gz | docker compose exec -T postgres psql -U nocobase -d nocobase
set -e
cd "$(dirname "$0")"
mkdir -p backups db
tmp="db/.latest.sql.tmp"
docker compose exec -T postgres pg_dump -U nocobase -d nocobase --clean --if-exists > "$tmp"
# 两个计算缓存（报表计算、历史年度）之间隔着视图依赖，pg_dump 排不出刷新顺序；恢复时按正确顺序重新填充
printf '\nSET search_path = public;\nREFRESH MATERIALIZED VIEW vi_stmt_cache;\nREFRESH MATERIALIZED VIEW vi_fin_history_cache;\n' >> "$tmp"
mv "$tmp" db/latest.sql
f="backups/nocobase_$(date +%Y%m%d_%H%M%S).sql.gz"
gzip -c db/latest.sql > "$f"
echo "已备份：db/latest.sql ($(du -h db/latest.sql | cut -f1))，$f ($(du -h "$f" | cut -f1))"
