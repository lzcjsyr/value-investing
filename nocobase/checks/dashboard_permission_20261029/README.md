# 驾驶舱 No permissions 提示修复（2026-10-29）

原因：独立的采集 JS 区块即使折叠也会挂载 Panel，useEffect 请求 workflows:list 与 vi_collector:list。Dreamizer 的正确权限仅允许研究数据读取，这两个管理接口返回 403；旧代码 catch 后返回 null，但全局请求拦截器已经发出提示。

修复：在挂载 Panel 之前读取受支持的 ctx.role，仅 root/admin 渲染采集管理工具；其他角色及角色未知时不挂载、不请求管理资源。后端 ACL 未改变，不对只读角色扩大权限。仅局部更新现有区块 o1xx5yxrmmj，保留价格视觉和研究数据。源模板 build_overview.py 与 tencent_dashboard.py 同步。

验证：本地只读用户研究数据正常，无管理面板或错误提示；管理员真实登录，展开采集面板可看到立即采集按钮。云端真实退出管理员后登录 Dreamizer，重新刷新、截图，研究数据正常且没有 No permissions。服务端日志窗口见 cloud-log-verification.json：83 个用户 ID 2 的响应，403 为 0，管理接口请求为 0，所有响应无 HTTP 错误。API 回读与已验证本地代码完全一致。Python 语法检查及生成器保留折叠与角色保护的检查通过。

cloud-before.json / local-before.json 保存回退资料；cloud-reader.png 为云端修复后实际截图。此修复只处理驾驶舱管理接口误请求，不作为其他已记录权限问题的整体验收。
