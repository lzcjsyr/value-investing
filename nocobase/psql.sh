#!/bin/sh
# 在 postgres 容器里执行 SQL：./psql.sh -c "select 1"  或  ./psql.sh -f file.sql（文件需在本目录下）
cd "$(dirname "$0")"
if [ "$1" = "-f" ]; then
  docker compose exec -T postgres psql -v ON_ERROR_STOP=1 -U nocobase -d nocobase -q < "$2"
else
  docker compose exec -T postgres psql -v ON_ERROR_STOP=1 -U nocobase -d nocobase "$@"
fi
