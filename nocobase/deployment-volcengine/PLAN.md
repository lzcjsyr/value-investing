# 价值投资 NocoBase：迁移到火山引擎

## 已确认的环境

- 来源：本机 `local` 环境，API 为 `http://localhost:13000/api`。
- 本机配置：`../docker-compose.yml`，NocoBase `2.2.29`，PostgreSQL `16-alpine`。
- 本机 storage 约 406 MB；正式备份前重新检查容量。
- 目标：上海 ECS `APP-fbYM-000`，公网 `118.196.72.148`。
- 目标配置：Ubuntu 24.04、2 vCPU、2 GiB 内存、40 GiB 系统盘。
- 用户已授权停止及清理不再使用的 OpenClaw，也允许必要时重装系统。

## 已执行和待验证

- 停止并禁用 root 用户的 `openclaw-gateway.service`。
- 最初将 OpenClaw 服务文件、命令入口、程序目录、数据移入服务器上的 `/root/retired-openclaw-20261027/`；用户随后明确要求永久删除，现已删除该目录以及安装脚本、独立日志和临时目录，并清空 npm 下载缓存。
- 已移除 bash/zsh 中 OpenClaw 的补全启动行。根文件系统按名称扫描无 OpenClaw 文件结果；进程、用户服务、已检查的启动配置和命令入口均无匹配。
- 已从 Docker 官方 APT 源安装 Docker 29.9.2、Compose v5.6.1；`systemctl is-active docker` 返回 `active`，`dpkg --audit` 无输出。
- 永久清理后可用内存约 1.3 GiB，根分区剩余约 32 GiB；Docker 仍为 `active`，Compose v5.6.1。

## 下一阶段：完整备份与恢复

2026-10-27 已先完成独立空库的云端部署预演，见 `PREVIEW.md` 和 `preview-test-results.json`。测试实例位于 `/opt/nocobase-preview`，内核 2.2.29，访问使用 SSH 隧道 `http://127.0.0.1:18080`。已验证数据库读写、隔离备份恢复、数据库重启、应用重建后的资料和文件持久化、浏览器登录。未迁移本机业务数据；完整业务快照恢复仍待用户本地配置完成后执行。

SSH 直连已获用户确认并验证成功：

- 专用私钥：`/Users/dielangli/.ssh/nocobase_volcengine_118_196_72_148_ed25519`，仅保存在本机。
- 主机指纹通过已登录的 ECS Terminal 核对：`SHA256:3xioclBnrGmZR3kCyKfnxWcfCPYth6G7zmdTZKQYRsc`。
- 专用主机信任文件：`/Users/dielangli/.ssh/nocobase_volcengine_118_196_72_148_known_hosts`。
- 公钥已加入目标 root 的 `authorized_keys`，限制为 `no-agent-forwarding,no-X11-forwarding,no-pty`，保留部署命令和隧道能力。
- 已通过严格主机检查和专用密钥以 root 登录，核对主机名、Docker `active` 以及 Compose v5.6.1。
- 后续服务器命令优先经 SSH 执行，无需浏览器操作终端。

1. 使用 NocoBase `nb api backup` 能力创建本机的新备份，并检查任务状态；当前备份列表为空。
2. 下载到 CLI home 的 `release/local/`，核验备份格式、状态及大小，记录校验和。
3. 确认备份是否包含上传附件及自定义插件；对未覆盖文件额外复制。不要把运行中的 PostgreSQL 数据目录直接当作一致性备份。
4. 在目标创建独立的 NocoBase 与 PostgreSQL 目录，保持 NocoBase 内核 2.2.29 和数据库主版本 16；根据客户端工具需求选择同版本 full 镜像。
5. 先只监听目标机器的回环地址，数据库不发布公网端口。需要管理 API 时优先使用临时隧道。
6. 用户确认具体备份包和目标后，通过 `nb api backup restore-upload` 恢复。记录返回的任务 ID 并检查恢复结果。
7. 验证管理员登录、公司页面、核心论点、财务模型、来源文档附件及数据量。核验完成前保留本机原服务和备份。
8. 对外访问方式另行确认：仅本人访问可优先使用隧道；若需要公开访问，再确定域名、HTTPS、安全组及访问控制。

## 已用的只读 CLI 命令

```text
nb env list
nb env info local
nb api backup list -e local
nb api backup create --help
nb api backup download --help
```

`backup list` 成功返回空数组，证明列表 API 可用；这不能替代实际创建和恢复测试。

## 确认边界

- 待选择输入：新建本机完整备份，目标为上述 ECS 的全新 NocoBase 实例。
- 备份创建及跨环境恢复按 `nocobase-publish-manage` 的确认规则执行；在恢复前列出实际备份文件名和目标。
- OpenClaw 永久删除已获明确授权并完成。不重装系统、不改变公网开放范围，除非必要且完成对应操作确认。
