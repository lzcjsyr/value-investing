#!/bin/sh
set -eu

key="$HOME/.ssh/nocobase_volcengine_118_196_72_148_ed25519"
hosts="$HOME/.ssh/nocobase_volcengine_118_196_72_148_known_hosts"
socket="$HOME/.ssh/nocobase_preview_control"
target="root@118.196.72.148"

case "${1:-start}" in
  start)
    if ! ssh -S "$socket" -O check "$target" >/dev/null 2>&1; then
      ssh -M -S "$socket" -fNT \
        -i "$key" -o IdentitiesOnly=yes -o BatchMode=yes \
        -o StrictHostKeyChecking=yes -o "UserKnownHostsFile=$hosts" \
        -o ExitOnForwardFailure=yes -o ServerAliveInterval=30 \
        -o ServerAliveCountMax=3 \
        -L 127.0.0.1:18080:127.0.0.1:13010 "$target"
    fi
    printf '%s\n' '云端测试访问：http://127.0.0.1:18080'
    ;;
  status)
    ssh -S "$socket" -O check "$target"
    ;;
  stop)
    ssh -S "$socket" -O exit "$target"
    ;;
  *)
    printf '%s\n' '用法：preview-access.sh [start|status|stop]' >&2
    exit 2
    ;;
esac
