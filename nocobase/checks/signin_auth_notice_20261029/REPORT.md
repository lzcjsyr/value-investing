# 登录页未认证提示诊断（2026-10-29）

云端 08:36:04 的访问与用户截图时间一致。登录页 /signin?redirect= 在无 token 状态下请求：

- auth:check：401 EMPTY_TOKEN（登录状态探测）。
- aiEmployees:listByUser：401 EMPTY_TOKEN。
- aiConversations:unreadCounts：401 EMPTY_TOKEN。

同轮 systemSettings:get、authenticators:publicList、themeConfig:list 返回 200。AI 插件当前打包客户端中确认包含 listByUser 以及 unreadCounts 调用。未登录的 AI 初始化请求触发全局错误提示，是客户端加载时机问题；没有证据表明账户删除、业务权限缺失或数据丢失。

本轮仅诊断，未修改认证接口、ACL、插件或应用代码。修复应在客户端等待确认登录成功后再挂载 AI 助手及请求私有接口，同时保留服务端鉴权。
