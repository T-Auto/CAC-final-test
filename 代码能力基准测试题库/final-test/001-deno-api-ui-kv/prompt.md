角色：资深 Deno 工程师。

上下文：仓库有 legacy 脚本 original.ts（请先读取该文件）。需要在全新的 main.ts 中实现"单文件：后端 + 前端 + KV 持久化"。不要修改 original.ts。

目标：一次性产出可直接复制粘贴部署到 Deno Deploy 的单个 TypeScript 文件。

需求（只描述外部行为与约束，不给实现细节）：
- 端点：
  - GET /                返回管理界面（内联 HTML/CSS/JS）
  - POST /v1/chat/completions  代理 Cerebras API；支持限速；任意输入模型统一映射为 defaultModel；保持响应语义（含流式）
  - GET /v1/models       返回模型列表（至少包含 defaultModel）
- 数据与配置持久化：将 apiKeys、defaultModel、keyIndex、keyStats 保存到 Deno KV，变更即时生效
- 密钥管理：导入（支持批量，文本每行一个）、删除、测试可用性、统计调用次数、轮转
- 安全与跨域：存在 AUTH_PASSWORD 时 /v1/* 需 Bearer <password>；支持 CORS 与 OPTIONS
- 运行环境：单文件、无构建，Deno Deploy 可直接运行

验收标准（必须全部满足）：
- 可在 Deno Deploy 成功部署并启动
- 管理界面可用，修改配置后即时生效
- /v1/chat/completions 与 /v1/models 正常工作
- KV 中可见持久化数据；密钥批量导入/删除/测试有效；请求次数累加
- 并发下稳定且具有限速；错误返回合理 HTTP 状态码
- 设置 AUTH_PASSWORD 时，未授权访问 /v1/* 返回 401

交付物：仅输出 main.ts 的完整代码内容
