
Source： https://github.com/zhu-jl18/thanks-to-cerebras

# description

Given a ts script:
```
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
当前痛点：
- 部分key失效后无法单点更新，每次需要全量更新
- 无法快速排查哪些key失效
- 默认模型等采用硬编码不方便更新

需求：
- 保持既有并发处理大致逻辑
- 所有密钥与配置持久化在 Deno KV，所有写操作即时落到 Deno KV。
- 单文件复制粘贴代码部署到 Deno Deploy 即完成后端与前端一体化交付。
- 简易UI界面实现
    - default model 更改入口
    - 导入密钥，删除密钥，测试密钥的基础功能
    - 支持批量导入密钥（text模式，每行一个）
    - 记录各个密钥的请求次数
