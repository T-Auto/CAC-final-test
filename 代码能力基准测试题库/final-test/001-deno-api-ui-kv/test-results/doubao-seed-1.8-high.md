```typescript
import { serve } from "https://deno.land/std@0.208.0/http/server.ts";
import { createCorsHandler } from "https://deno.land/x/cors@v1.2.2/mod.ts";

// 配置类型定义
interface Config {
  apiKeys: string[];
  defaultModel: string;
  keyIndex: number;
  keyStats: Record<string, number>;
  authPassword?: string;
  rateLimit: number; // 每分钟请求限制
}

// 初始化默认配置
const defaultConfig: Config = {
  apiKeys: [],
  defaultModel: "llama3.1-70b",
  keyIndex: 0,
  keyStats: {},
  rateLimit: 60, // 每分钟60次请求
};

// 获取或初始化配置
async function getConfig(): Promise<Config> {
  const kv = await Deno.openKv();
  const result = await kv.get<Config>(["config"]);
  if (result.value) {
    return result.value;
  }
  await kv.set(["config"], defaultConfig);
  return defaultConfig;
}

// 更新配置
async function updateConfig(config: Config): Promise<void> {
  const kv = await Deno.openKv();
  await kv.set(["config"], config);
}

// 验证授权
async function authenticate(request: Request): Promise<boolean> {
  const config = await getConfig();
  if (!config.authPassword) return true;

  const authHeader = request.headers.get("Authorization");
  if (!authHeader) return false;

  const [scheme, token] = authHeader.split(" ");
  return scheme === "Bearer" && token === config.authPassword;
}

// 限速检查
async function checkRateLimit(apiKey: string): Promise<boolean> {
  const config = await getConfig();
  const kv = await Deno.openKv();
  
  const now = Date.now();
  const windowStart = now - 60 * 1000; // 1分钟窗口
  
  // 获取该API密钥在当前窗口的请求次数
  const key = ["rateLimit", apiKey, Math.floor(windowStart / (60 * 1000))];
  const result = await kv.get<number>(key);
  const count = result.value || 0;
  
  if (count >= config.rateLimit) {
    return false;
  }
  
  // 增加请求计数
  await kv.set(key, count + 1, { expireIn: 60 * 1000 });
  return true;
}

// 代理Cerebras API
async function proxyCerebras(request: Request, config: Config): Promise<Response> {
  // 选择下一个API密钥（轮转）
  if (config.apiKeys.length === 0) {
    return new Response("No API keys configured", { status: 500 });
  }
  
  const apiKey = config.apiKeys[config.keyIndex];
  config.keyIndex = (config.keyIndex + 1) % config.apiKeys.length;
  await updateConfig(config);
  
  // 检查限速
  if (!await checkRateLimit(apiKey)) {
    return new Response("Rate limit exceeded", { status: 429 });
  }
  
  // 解析请求体
  const body = await request.json();
  
  // 统一映射模型
  body.model = config.defaultModel;
  
  // 转发请求到Cerebras API
  const cerebrasResponse = await fetch("https://api.cerebras.ai/v1/chat/completions", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Authorization": `Bearer ${apiKey}`,
    },
    body: JSON.stringify(body),
  });
  
  // 更新请求统计
  config.keyStats[apiKey] = (config.keyStats[apiKey] || 0) + 1;
  await updateConfig(config);
  
  // 返回响应
  return new Response(cerebrasResponse.body, {
    status: cerebrasResponse.status,
    headers: cerebrasResponse.headers,
  });
}

// 处理OPTIONS请求
const corsHandler = createCorsHandler({
  origin: "*",
  methods: ["GET", "POST", "OPTIONS"],
  headers: ["Content-Type", "Authorization"],
});

// 主处理函数
async function handler(request: Request): Promise<Response> {
  // 处理OPTIONS请求
  if (request.method === "OPTIONS") {
    return corsHandler(request);
  }
  
  // 处理CORS
  const responseHeaders = new Headers();
  responseHeaders.set("Access-Control-Allow-Origin", "*");
  responseHeaders.set("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
  responseHeaders.set("Access-Control-Allow-Headers", "Content-Type, Authorization");
  
  // 解析URL
  const url = new URL(request.url);
  
  // 处理管理界面
  if (url.pathname === "/") {
    const config = await getConfig();
    
    // 内联HTML/CSS/JS管理界面
    const html = `
<!DOCTYPE html>
<html>
<head>
  <title>Cerebras Proxy Admin</title>
  <style>
    body { font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px; }
    .section { margin-bottom: 30px; padding: 20px; border: 1px solid #ddd; border-radius: 5px; }
    h1 { color: #333; }
    h2 { color: #555; margin-top: 0; }
    input, textarea, button { margin: 5px 0; padding: 10px; font-size: 16px; }
    textarea { width: 100%; height: 150px; }
    button { background-color: #007bff; color: white; border: none; border-radius: 5px; cursor: pointer; }
    button:hover { background-color: #0056b3; }
    .key-item { margin: 10px 0; padding: 10px; border: 1px solid #eee; border-radius: 5px; }
    .stats { font-size: 14px; color: #666; }
    .error { color: red; }
    .success { color: green; }
  </style>
</head>
<body>
  <h1>Cerebras Proxy Admin</h1>
  
  <div class="section">
    <h2>API Keys</h2>
    <textarea id="apiKeys" placeholder="Paste API keys here, one per line"></textarea>
    <button onclick="importKeys()">Import Keys</button>
    <div id="keysList"></div>
  </div>
  
  <div class="section">
    <h2>Configuration</h2>
    <div>
      <label>Default Model: </label>
      <input type="text" id="defaultModel" value="${config.defaultModel}">
      <button onclick="updateDefaultModel()">Update</button>
    </div>
    <div>
      <label>Auth Password: </label>
      <input type="password" id="authPassword" value="${config.authPassword || ''}">
      <button onclick="updateAuthPassword()">Update</button>
    </div>
    <div>
      <label>Rate Limit (requests per minute): </label>
      <input type="number" id="rateLimit" value="${config.rateLimit}">
      <button onclick="updateRateLimit()">Update</button>
    </div>
  </div>
  
  <div class="section">
    <h2>Stats</h2>
    <div id="keyStats"></div>
  </div>
  
  <script>
    // 加载当前配置
    async function loadConfig() {
      const response = await fetch('/api/config');
      const config = await response.json();
      
      // 更新UI
      document.getElementById('defaultModel').value = config.defaultModel;
      document.getElementById('authPassword').value = config.authPassword || '';
      document.getElementById('rateLimit').value = config.rateLimit;
      
      // 更新密钥列表
      const keysList = document.getElementById('keysList');
      keysList.innerHTML = '';
      config.apiKeys.forEach(key => {
        const div = document.createElement('div');
        div.className = 'key-item';
        div.innerHTML = \`
          <span>\${key}</span>
          <button onclick="testKey('\${key}')">Test</button>
          <button onclick="deleteKey('\${key}')">Delete</button>
        \`;
        keysList.appendChild(div);
      });
      
      // 更新统计
      const keyStats = document.getElementById('keyStats');
      keyStats.innerHTML = '';
      for (const [key, count] of Object.entries(config.keyStats)) {
        const div = document.createElement('div');
        div.className = 'stats';
        div.textContent = \`\${key}: \${count} requests\`;
        keyStats.appendChild(div);
      }
    }
    
    // 导入密钥
    async function importKeys() {
      const textarea = document.getElementById('apiKeys');
      const keys = textarea.value.split('\\n').filter(key => key.trim() !== '');
      
      const response = await fetch('/api/keys', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ keys })
      });
      
      if (response.ok) {
        textarea.value = '';
        loadConfig();
      } else {
        alert('Failed to import keys');
      }
    }
    
    // 删除密钥
    async function deleteKey(key) {
      const response = await fetch('/api/keys/' + encodeURIComponent(key), {
        method: 'DELETE'
      });
      
      if (response.ok) {
        loadConfig();
      } else {
        alert('Failed to delete key');
      }
    }
    
    // 测试密钥
    async function testKey(key) {
      const response = await fetch('/api/test-key/' + encodeURIComponent(key));
      const result = await response.json();
      
      if (result.success) {
        alert('Key is valid');
      } else {
        alert('Key is invalid: ' + result.error);
      }
    }
    
    // 更新默认模型
    async function updateDefaultModel() {
      const model = document.getElementById('defaultModel').value;
      const response = await fetch('/api/config', {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ defaultModel: model })
      });
      
      if (response.ok) {
        loadConfig();
      } else {
        alert('Failed to update default model');
      }
    }
    
    // 更新认证密码
    async function updateAuthPassword() {
      const password = document.getElementById('authPassword').value;
      const response = await fetch('/api/config', {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ authPassword: password })
      });
      
      if (response.ok) {
        loadConfig();
      } else {
        alert('Failed to update auth password');
      }
    }
    
    // 更新限速
    async function updateRateLimit() {
      const rateLimit = parseInt(document.getElementById('rateLimit').value);
      const response = await fetch('/api/config', {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ rateLimit })
      });
      
      if (response.ok) {
        loadConfig();
      } else {
        alert('Failed to update rate limit');
      }
    }
    
    // 初始化
    loadConfig();
  </script>
</body>
</html>
    `;
    
    return new Response(html, {
      headers: {
        "Content-Type": "text/html",
        ...responseHeaders,
      },
    });
  }
  
  // 处理API端点
  if (url.pathname.startsWith("/v1/")) {
    // 检查认证
    if (!await authenticate(request)) {
      return new Response("Unauthorized", { status: 401, headers: responseHeaders });
    }
    
    // 处理模型列表
    if (url.pathname === "/v1/models") {
      const config = await getConfig();
      return new Response(JSON.stringify({
        data: [{ id: config.defaultModel, object: "model", created: Date.now(), owned_by: "cerebras" }]
      }), {
        headers: {
          "Content-Type": "application/json",
          ...responseHeaders,
        },
      });
    }
    
    // 处理聊天完成
    if (url.pathname === "/v1/chat/completions") {
      const config = await getConfig();
      return proxyCerebras(request, config);
    }
    
    // 未知端点
    return new Response("Not found", { status: 404, headers: responseHeaders });
  }
  
  // 处理内部API
  if (url.pathname.startsWith("/api/")) {
    // 处理配置获取
    if (url.pathname === "/api/config") {
      const config = await getConfig();
      return new Response(JSON.stringify(config), {
        headers: {
          "Content-Type": "application/json",
          ...responseHeaders,
        },
      });
    }
    
    // 处理配置更新
    if (url.pathname === "/api/config" && request.method === "PUT") {
      const updates = await request.json();
      const config = await getConfig();
      Object.assign(config, updates);
      await updateConfig(config);
      return new Response(JSON.stringify(config), {
        headers: {
          "Content-Type": "application/json",
          ...responseHeaders,
        },
      });
    }
    
    // 处理密钥导入
    if (url.pathname === "/api/keys" && request.method === "POST") {
      const { keys } = await request.json();
      const config = await getConfig();
      config.apiKeys = [...new Set([...config.apiKeys, ...keys])]; // 去重
      await updateConfig(config);
      return new Response(JSON.stringify({ success: true }), {
        headers: {
          "Content-Type": "application/json",
          ...responseHeaders,
        },
      });
    }
    
    // 处理密钥删除
    if (url.pathname.startsWith("/api/keys/") && request.method === "DELETE") {
      const key = decodeURIComponent(url.pathname.split("/")[3]);
      const config = await getConfig();
      config.apiKeys = config.apiKeys.filter(k => k !== key);
      delete config.keyStats[key];
      await updateConfig(config);
      return new Response(JSON.stringify({ success: true }), {
        headers: {
          "Content-Type": "application/json",
          ...responseHeaders,
        },
      });
    }
    
    // 处理密钥测试
    if (url.pathname.startsWith("/api/test-key/")) {
      const key = decodeURIComponent(url.pathname.split("/")[3]);
      try {
        const response = await fetch("https://api.cerebras.ai/v1/models", {
          headers: { "Authorization": `Bearer ${key}` }
        });
        if (response.ok) {
          return new Response(JSON.stringify({ success: true }), {
            headers: {
              "Content-Type": "application/json",
              ...responseHeaders,
            },
          });
        } else {
          return new Response(JSON.stringify({ success: false, error: "Invalid key" }), {
            status: 400,
            headers: {
              "Content-Type": "application/json",
              ...responseHeaders,
            },
          });
        }
      } catch (error) {
        return new Response(JSON.stringify({ success: false, error: error.message }), {
          status: 500,
          headers: {
            "Content-Type": "application/json",
            ...responseHeaders,
          },
        });
      }
    }
    
    // 未知内部API
    return new Response("Not found", { status: 404, headers: responseHeaders });
  }
  
  // 未知路径
  return new Response("Not found", { status: 404, headers: responseHeaders });
}

// 启动服务器
serve(handler, { port: 8000 });
```</think_never_used_51bce0c785ca2f68081bfa7d91973934>```typescript
import { serve } from "https://deno.land/std@0.208.0/http/server.ts";

// 配置类型定义
interface Config {
  apiKeys: string[];
  defaultModel: string;
  keyIndex: number;
  keyStats: Record<string, number>;
  authPassword?: string;
  rateLimit: number; // 每分钟请求限制
}

// 初始化默认配置
const defaultConfig: Config = {
  apiKeys: [],
  defaultModel: "llama3.1-70b",
  keyIndex: 0,
  keyStats: {},
  rateLimit: 60, // 每分钟60次请求
};

// 获取或初始化配置
async function getConfig(): Promise<Config> {
  const kv = await Deno.openKv();
  const result = await kv.get<Config>(["config"]);
  if (result.value) {
    return result.value;
  }
  await kv.set(["config"], defaultConfig);
  return defaultConfig;
}

// 更新配置
async function updateConfig(config: Config): Promise<void> {
  const kv = await Deno.openKv();
  await kv.set(["config"], config);
}

// 验证授权
async function authenticate(request: Request): Promise<boolean> {
  const config = await getConfig();
  if (!config.authPassword) return true;

  const authHeader = request.headers.get("Authorization");
  if (!authHeader) return false;

  const [scheme, token] = authHeader.split(" ");
  return scheme === "Bearer" && token === config.authPassword;
}

// 限速检查
async function checkRateLimit(apiKey: string): Promise<boolean> {
  const config = await getConfig();
  const kv = await Deno.openKv();
  
  const now = Date.now();
  const windowKey = ["rateLimit", apiKey, Math.floor(now / (60 * 1000))];
  const result = await kv.get<number>(windowKey);
  const count = result.value || 0;
  
  if (count >= config.rateLimit) {
    return false;
  }
  
  // 增加请求计数并设置过期时间
  await kv.set(windowKey, count + 1, { expireIn: 60 * 1000 });
  return true;
}

// 代理Cerebras API
async function proxyCerebras(request: Request, config: Config): Promise<Response> {
  // 检查是否有API密钥
  if (config.apiKeys.length === 0) {
    return new Response("No API keys configured", { status: 500 });
  }
  
  // 选择下一个API密钥（轮转）
  const apiKey = config.apiKeys[config.keyIndex];
  config.keyIndex = (config.keyIndex + 1) % config.apiKeys.length;
  await updateConfig(config);
  
  // 检查限速
  if (!await checkRateLimit(apiKey)) {
    return new Response("Rate limit exceeded", { status: 429 });
  }
  
  // 解析请求体
  const body = await request.json();
  
  // 统一映射模型
  body.model = config.defaultModel;
  
  // 转发请求到Cerebras API
  const cerebrasResponse = await fetch("https://api.cerebras.ai/v1/chat/completions", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Authorization": `Bearer ${apiKey}`,
    },
    body: JSON.stringify(body),
  });
  
  // 更新请求统计
  config.keyStats[apiKey] = (config.keyStats[apiKey] || 0) + 1;
  await updateConfig(config);
  
  // 返回响应
  return new Response(cerebrasResponse.body, {
    status: cerebrasResponse.status,
    headers: cerebrasResponse.headers,
  });
}

// 主处理函数
async function handler(request: Request): Promise<Response> {
  // 设置CORS头
  const responseHeaders = new Headers();
  responseHeaders.set("Access-Control-Allow-Origin", "*");
  responseHeaders.set("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
  responseHeaders.set("Access-Control-Allow-Headers", "Content-Type, Authorization");
  
  // 处理OPTIONS请求
  if (request.method === "OPTIONS") {
    return new Response(null, { headers: responseHeaders });
  }
  
  // 解析URL
  const url = new URL(request.url);
  
  // 处理管理界面
  if (url.pathname === "/") {
    const config = await getConfig();
    
    // 内联HTML/CSS/JS管理界面
    const html = `
<!DOCTYPE html>
<html>
<head>
  <title>Cerebras Proxy Admin</title>
  <style>
    body { font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px; }
    .section { margin-bottom: 30px; padding: 20px; border: 1px solid #ddd; border-radius: 5px; }
    h1 { color: #333; }
    h2 { color: #555; margin-top: 0; }
    input, textarea, button { margin: 5px 0; padding: 10px; font-size: 16px; }
    textarea { width: 100%; height: 150px; }
    button { background-color: #007bff; color: white; border: none; border-radius: 5px; cursor: pointer; }
    button:hover { background-color: #0056b3; }
    .key-item { margin: 10px 0; padding: 10px; border: 1px solid #eee; border-radius: 5px; }
    .stats { font-size: 14px; color: #666; }
    .error { color: red; }
    .success { color: green; }
  </style>
</head>
<body>
  <h1>Cerebras Proxy Admin</h1>
  
  <div class="section">
    <h2>API Keys</h2>
    <textarea id="apiKeys" placeholder="Paste API keys here, one per line"></textarea>
    <button onclick="importKeys()">Import Keys</button>
    <div id="keysList"></div>
  </div>
  
  <div class="section">
    <h2>Configuration</h2>
    <div>
      <label>Default Model: </label>
      <input type="text" id="defaultModel" value="${config.defaultModel}">
      <button onclick="updateDefaultModel()">Update</button>
    </div>
    <div>
      <label>Auth Password: </label>
      <input type="password" id="authPassword" value="${config.authPassword || ''}">
      <button onclick="updateAuthPassword()">Update</button>
    </div>
    <div>
      <label>Rate Limit (requests per minute): </label>
      <input type="number" id="rateLimit" value="${config.rateLimit}">
      <button onclick="updateRateLimit()">Update</button>
    </div>
  </div>
  
  <div class="section">
    <h2>Stats</h2>
    <div id="keyStats"></div>
  </div>
  
  <script>
    // 加载当前配置
    async function loadConfig() {
      const response = await fetch('/api/config');
      const config = await response.json();
      
      // 更新UI
      document.getElementById('defaultModel').value = config.defaultModel;
      document.getElementById('authPassword').value = config.authPassword || '';
      document.getElementById('rateLimit').value = config.rateLimit;
      
      // 更新密钥列表
      const keysList = document.getElementById('keysList');
      keysList.innerHTML = '';
      config.apiKeys.forEach(key => {
        const div = document.createElement('div');
        div.className = 'key-item';
        div.innerHTML = \`
          <span>\${key}</span>
          <button onclick="testKey('\${key}')">Test</button>
          <button onclick="deleteKey('\${key}')">Delete</button>
        \`;
        keysList.appendChild(div);
      });
      
      // 更新统计
      const keyStats = document.getElementById('keyStats');
      keyStats.innerHTML = '';
      for (const [key, count] of Object.entries(config.keyStats)) {
        const div = document.createElement('div');
        div.className = 'stats';
        div.textContent = \`\${key}: \${count} requests\`;
        keyStats.appendChild(div);
      }
    }
    
    // 导入密钥
    async function importKeys() {
      const textarea = document.getElementById('apiKeys');
      const keys = textarea.value.split('\\n').filter(key => key.trim() !== '');
      
      const response = await fetch('/api/keys', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ keys })
      });
      
      if (response.ok) {
        textarea.value = '';
        loadConfig();
      } else {
        alert('Failed to import keys');
      }
    }
    
    // 删除密钥
    async function deleteKey(key) {
      const response = await fetch('/api/keys/' + encodeURIComponent(key), {
        method: 'DELETE'
      });
      
      if (response.ok) {
        loadConfig();
      } else {
        alert('Failed to delete key');
      }
    }
    
    // 测试密钥
    async function testKey(key) {
      const response = await fetch('/api/test-key/' + encodeURIComponent(key));
      const result = await response.json();
      
      if (result.success) {
        alert('Key is valid');
      } else {
        alert('Key is invalid: ' + result.error);
      }
    }
    
    // 更新默认模型
    async function updateDefaultModel() {
      const model = document.getElementById('defaultModel').value;
      const response = await fetch('/api/config', {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ defaultModel: model })
      });
      
      if (response.ok) {
        loadConfig();
      } else {
        alert('Failed to update default model');
      }
    }
    
    // 更新认证密码
    async function updateAuthPassword() {
      const password = document.getElementById('authPassword').value;
      const response = await fetch('/api/config', {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ authPassword: password })
      });
      
      if (response.ok) {
        loadConfig();
      } else {
        alert('Failed to update auth password');
      }
    }
    
    // 更新限速
    async function updateRateLimit() {
      const rateLimit = parseInt(document.getElementById('rateLimit').value);
      const response = await fetch('/api/config', {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ rateLimit })
      });
      
      if (response.ok) {
        loadConfig();
      } else {
        alert('Failed to update rate limit');
      }
    }
    
    // 初始化
    loadConfig();
  </script>
</body>
</html>
    `;
    
    return new Response(html, {
      headers: {
        "Content-Type": "text/html",
        ...responseHeaders,
      },
    });
  }
  
  // 处理API端点
  if (url.pathname.startsWith("/v1/")) {
    // 检查认证
    if (!await authenticate(request)) {
      return new Response("Unauthorized", { status: 401, headers: responseHeaders });
    }
    
    // 处理模型列表
    if (url.pathname === "/v1/models") {
      const config = await getConfig();
      return new Response(JSON.stringify({
        data: [{ id: config.defaultModel, object: "model", created: Date.now(), owned_by: "cerebras" }]
      }), {
        headers: {
          "Content-Type": "application/json",
          ...responseHeaders,
        },
      });
    }
    
    // 处理聊天完成
    if (url.pathname === "/v1/chat/completions") {
      const config = await getConfig();
      return proxyCerebras(request, config);
    }
    
    // 未知端点
    return new Response("Not found", { status: 404, headers: responseHeaders });
  }
  
  // 处理内部API
  if (url.pathname.startsWith("/api/")) {
    // 处理配置获取
    if (url.pathname === "/api/config") {
      const config = await getConfig();
      return new Response(JSON.stringify(config), {
        headers: {
          "Content-Type": "application/json",
          ...responseHeaders,
        },
      });
    }
    
    // 处理配置更新
    if (url.pathname === "/api/config" && request.method === "PUT") {
      const updates = await request.json();
      const config = await getConfig();
      Object.assign(config, updates);
      await updateConfig(config);
      return new Response(JSON.stringify(config), {
        headers: {
          "Content-Type": "application/json",
          ...responseHeaders,
        },
      });
    }
    
    // 处理密钥导入
    if (url.pathname === "/api/keys" && request.method === "POST") {
      const { keys } = await request.json();
      const config = await getConfig();
      config.apiKeys = [...new Set([...config.apiKeys, ...keys])]; // 去重
      await updateConfig(config);
      return new Response(JSON.stringify({ success: true }), {
        headers: {
          "Content-Type": "application/json",
          ...responseHeaders,
        },
      });
    }
    
    // 处理密钥删除
    if (url.pathname.startsWith("/api/keys/") && request.method === "DELETE") {
      const key = decodeURIComponent(url.pathname.split("/")[3]);
      const config = await getConfig();
      config.apiKeys = config.apiKeys.filter(k => k !== key);
      delete config.keyStats[key];
      await updateConfig(config);
      return new Response(JSON.stringify({ success: true }), {
        headers: {
          "Content-Type": "application/json",
          ...responseHeaders,
        },
      });
    }
    
    // 处理密钥测试
    if (url.pathname.startsWith("/api/test-key/")) {
      const key = decodeURIComponent(url.pathname.split("/")[3]);
      try {
        const response = await fetch("https://api.cerebras.ai/v1/models", {
          headers: { "Authorization": `Bearer ${key}` }
        });
        if (response.ok) {
          return new Response(JSON.stringify({ success: true }), {
            headers: {
              "Content-Type": "application/json",
              ...responseHeaders,
            },
          });
        } else {
          return new Response(JSON.stringify({ success: false, error: "Invalid key" }), {
            status: 400,
            headers: {
              "Content-Type": "application/json",
              ...responseHeaders,
            },
          });
        }
      } catch (error) {
        return new Response(JSON.stringify({ success: false, error: error.message }), {
          status: 500,
          headers: {
            "Content-Type": "application/json",
            ...responseHeaders,
          },
        });
      }
    }
    
    // 未知内部API
    return new Response("Not found", { status: 404, headers: responseHeaders });
  }
  
  // 未知路径
  return new Response("Not found", { status: 404, headers: responseHeaders });
}

// 启动服务器
serve(handler, { port: 8000 });
```