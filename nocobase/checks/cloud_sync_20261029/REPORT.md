# 云端同步核验（2026-10-29）

- 目标：http://118.196.72.148/admin，服务器目录 /opt/nocobase-preview。
- 本地快照：server-release-20261029-082934，包含数据库、storage（不含数据库物理目录及日志）、当前 Git 已跟踪及未忽略的源码文件。源码为 base commit 550b3a1 加当前工作区改动，未丢弃未提交内容。
- 上传的 database.dump、storage.tar.gz、source.tar.gz 三份文件 SHA256 全部一致。
- 云端恢复前备份：/opt/nocobase-preview/backups/pre-restore-20261029-0830，包含 database.dump、storage.tar.gz、storage-original。
- 源码副本：/opt/nocobase-preview/releases/server-release-20261029-082934/source；数据库和附件已恢复至实际运行实例。
- 恢复成功后刷新 vi_stmt_cache、vi_fin_history_cache，应用已启动，PostgreSQL healthy。
- 按 UTC 时间及 C 排序规范化后，对比 79 张业务、页面、菜单、账户、角色及权限配置表：记录数与全部行内容摘要一致。详见 verification.json、local-tables.txt、cloud-tables.txt。
- 当前包括 5 家公司、175 项指标、3384 条观察、2 个用户，系统标题为“价值投资工作台”。
- 公网 app:getInfo 返回版本 2.2.29；真实浏览器打开登录页，页面及浏览器标题均为“价值投资工作台”。截图 cloud-signin.png。
- 本次没有重新逐页登录验收全部公司页面，也没有将此前的权限隔离局限视为已解决。
- 此次为本地覆盖云端的单次快照同步；后续本地修改不会自动同步。
