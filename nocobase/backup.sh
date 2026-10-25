#!/bin/sh
# 备份整个 NocoBase 数据库（含长江电力全部表、视图、页面与工作流配置）到 backups/
# 恢复：gunzip -c backups/<文件>.sql.gz | docker compose exec -T postgres psql -U nocobase -d nocobase
set -e
cd "$(dirname "$0")"
mkdir -p backups
f="backups/nocobase_$(date +%Y%m%d_%H%M%S).sql.gz"
docker compose exec -T postgres pg_dump -U nocobase -d nocobase --clean --if-exists | gzip > "$f"
echo "已备份：$f ($(du -h "$f" | cut -f1))"
