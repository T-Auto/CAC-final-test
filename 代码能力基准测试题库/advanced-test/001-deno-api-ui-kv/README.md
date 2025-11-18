# Deno API 代理脚本改进：UI + KV 持久化

难度等级：Advanced | 预计耗时：10分钟 | 预计迭代轮次：不超过2轮  

原始来源：https://github.com/zhu-jl18/thanks-to-cerebras

测试环境：Deno Runtime + Deno Deploy 账号 + Claude Code 环境

测试步骤：将原始代码另存为 original.ts → 在 Claude Code 中读取该文件 → 粘贴下方 Prompts → 生成全新单文件实现 → 部署到 Deno Deploy → 功能回归测试（别整花活，先跑通）

## 测试Prompts

请将下方 Prompt 整段复制给 Claude Code。注意：原始代码不要放进 Prompt，让 Claude 直接读取文件 original.ts。

```markdown
角色：资深 Deno 工程师。

上下文：仓库有 legacy 脚本 original.ts（请先读取该文件）。需要在全新的 main.ts 中实现“单文件：后端 + 前端 + KV 持久化”。不要修改 original.ts。

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
```

## 附录：原始代码（供 Claude Code 读取，勿放入 Prompt）

```ts
import { serve } from "https://deno.land/std@0.192.0/http/server.ts";

const CEREBRAS_API_URL = 'https://api.cerebras.ai/v1/chat/completions';
const RATE_LIMIT_MS = 200;
const DEFAULT_MODEL = 'qwen-3-235b-a22b-instruct-2507'; // 默认模型

const CORS_HEADERS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
};

const requestQueue: { body: any; resolve: (response: Response) => void }[] = [];

let apiKeys: string[] = [];
let currentKeyIndex = 0;
let authPassword: string | null = null;

function initializeKeys() {
  const keysString = Deno.env.get("CEREBRAS_API_KEYS");
  if (keysString) {
    apiKeys = keysString.split(',').map(key => key.trim()).filter(key => key);
    console.log(`Initialized with ${apiKeys.length} API keys.`);
  } else {
    console.error("CEREBRAS_API_KEYS environment variable not set!");
  }

  // 初始化鉴权密码
  authPassword = Deno.env.get("AUTH_PASSWORD");
  if (authPassword) {
    console.log("Authentication enabled.");
  } else {
    console.log("Authentication disabled (no AUTH_PASSWORD set).");
  }
}

function authenticateRequest(request: Request): boolean {
  // 如果没有设置鉴权密码，则跳过验证
  if (!authPassword) {
    return true;
  }

  const authHeader = request.headers.get("Authorization");
  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return false;
  }

  const providedPassword = authHeader.substring(7); // 去掉 "Bearer " 前缀
  return providedPassword === authPassword;
}

async function processQueue() {
  if (requestQueue.length === 0 || apiKeys.length === 0) {
    return;
  }

  const { body, resolve } = requestQueue.shift()!;

  const apiKey = apiKeys[currentKeyIndex];
  currentKeyIndex = (currentKeyIndex + 1) % apiKeys.length;

  console.log(`Processing request with key index: ${currentKeyIndex}`);

  // 模型默认映射：无论用户传入什么模型名称，都映射到默认模型
  const originalModel = body.model;
  body.model = DEFAULT_MODEL;
  console.log(`Model mapping: "${originalModel}" -> "${DEFAULT_MODEL}"`);

  try {
    const apiResponse = await fetch(CEREBRAS_API_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${apiKey}`,
      },
      body: JSON.stringify(body),
    });

    const responseHeaders = new Headers(apiResponse.headers);
    Object.entries(CORS_HEADERS).forEach(([key, value]) => {
      responseHeaders.set(key, value);
    });

    resolve(new Response(apiResponse.body, {
      status: apiResponse.status,
      statusText: apiResponse.statusText,
      headers: responseHeaders,
    }));

  } catch (error) {
    console.error("Error forwarding request to Cerebras:", error);
    resolve(new Response(`Proxy error: ${error.message}`, { status: 502, headers: CORS_HEADERS }));
  }
}

async function handler(req: Request): Promise<Response> {
  if (req.method === 'OPTIONS') {
    return new Response(null, { status: 204, headers: CORS_HEADERS });
  }

  if (req.method !== 'POST') {
    return new Response("Method Not Allowed", { status: 405, headers: CORS_HEADERS });
  }

  // 鉴权检查
  if (!authenticateRequest(req)) {
    return new Response("Unauthorized", { status: 401, headers: CORS_HEADERS });
  }

  if (apiKeys.length === 0) {
     return new Response("Server configuration error: No API keys configured.", { status: 500, headers: CORS_HEADERS });
  }

  try {
    const requestBody = await req.json();

    return new Promise((resolve) => {
      requestQueue.push({ body: requestBody, resolve });
    });

  } catch (error) {
    return new Response(`Invalid JSON body: ${error.message}`, { status: 400, headers: CORS_HEADERS });
  }
}

initializeKeys();
serve(handler);
setInterval(processQueue, RATE_LIMIT_MS);

console.log(`Cerebras smart proxy with auth & auto model rotation started.`);
console.log(`- Default model: ${DEFAULT_MODEL}`);
console.log(`- Authentication: ${authPassword ? 'Enabled' : 'Disabled'}`);
console.log(`- Request processing interval: ${RATE_LIMIT_MS}ms`);
console.log(`- Max requests per second (approx): ${1000 / RATE_LIMIT_MS}`);
```

## 验收标准

**通过标准**：在不超过2轮迭代后，代码能成功部署到Deno Deploy并正常使用。

**关键考察点**：代码能否跑通、引入KV后的并发处理是否正确、数据一致性、错误处理。

**常见失败原因**：Deno KV并发竞态问题（读写未加锁/事务）、密钥轮询索引更新错误、单文件模式下前后端集成失败。


## 测试能力

别堆花哨。能跑、稳、可维护，才算合格。下表是我们关心的东西：

| 能力点         | 要求                            | 观察方式                                     |
| -------------- | ------------------------------- | -------------------------------------------- |
| Deno KV 使用   | 关键数据持久化，写入走 atomic() | KV 中能看到 keys/config；并发下无错          |
| 并发与限流     | 队列 + 定时出队，避免竞态       | 压测时无重复/丢单；速率受 RATE_LIMIT_MS 控制 |
| 代理与转发     | CORS/OPTIONS 完整；流式转发可用 | curl/浏览器均能拿到完整响应流                |
| 密钥轮转与统计 | 轮询均衡；失败标记；统计可见    | UI 上能测试 key；请求数累加正确              |
| UI/后端一体    | 单文件内联 UI，操作即生效       | 修改 defaultModel/keys 后无需重启            |
| 鉴权           | AUTH_PASSWORD 生效在 /v1/       | 未授权返回 401，UI 仍可访问                  |
| 错误处理       | 状态码清晰、日志清楚            | 非法输入 400、无 key 500、转发失败 502       |
| 部署可用性     | 直接在 Deno Deploy 运行         | 无需构建，导入 URL 可用                      |

## 测试结果

**通过**： codex可以直接一遍过

**未通过**： minimaxm2在多轮迭代后完全不可用

