# 实现 Trie(前缀树)数据结构

## 使用说明(给人类评测者)

- 第 1 步: 调用大语言模型时,将下面“测试 Prompts”章节中的 `txt` 代码块整体复制,作为**用户输入 Prompt 模板**发送给模型(可按需翻译成英文,但不要改变接口约束和输出格式要求)。
- 第 2 步: 获取模型返回的 TypeScript 源码,保存为单独文件(例如 `trie.ts`)。
- 第 3 步: 在测试文件 `test-trie.ts` 中,将 `import Trie from './your-trie-code';` 的导入路径改为前一步保存的文件名(例如改为 `./trie`)。
- 第 4 步: 按“运行测试”章节的命令编译并运行测试脚本,记录用例是否全部通过及性能表现。
- 第 5 步: 如需对比多个模型,对每个模型重复上述步骤,对比测试结果和代码质量。

## 测试 Prompts

本节提供一段推荐的 Prompt 文本,评测者可以直接复制下面的 `txt` 代码块内容,作为调用大语言模型时的用户输入。

```txt
实现一个 Trie(前缀树)数据结构,支持以下操作:
1. insert(word: string): void - 插入一个单词
2. search(word: string): boolean - 查找单词是否存在
3. startsWith(prefix: string): boolean - 判断是否有单词以该前缀开头
4. getWordsWithPrefix(prefix: string): string[] - 返回所有以该前缀开头的单词(用于自动补全)

要求:
- 使用 **TypeScript** 实现(不使用 JavaScript)
- 提供完整的 TrieNode 类和 Trie 类(默认导出 Trie 类)
- 代码结构清晰,包含适当的注释
- 方法签名称必须完全匹配(用于自动化测试)

**代码格式要求(类似 LeetCode):**
```typescript
class TrieNode {
  // 你的实现
}

export default class Trie {
  // 你的实现
}
```

**测试环境说明:**
你的代码将在以下环境中测试:
```typescript
import Trie from './your-code';

const trie = new Trie();
trie.insert("apple");
console.log(trie.search("apple"));   // 应返回 true
console.log(trie.startsWith("app")); // 应返回 true
console.log(trie.getWordsWithPrefix("app")); // 应返回 ["apple"]
```

时间复杂度要求:
- insert/search/startsWith: O(m), m 为字符串长度
- getWordsWithPrefix: O(p + n), p 为前缀长度, n 为结果数量

空间复杂度: O(n×m), n 为单词数量, m 为平均长度

空字符串("") 视为合法单词:
- 调用 insert("") 后, search("") 必须返回 true;
- startsWith("") 必须始终返回 true(空前缀匹配所有已插入单词)。

仅返回 TypeScript 源码,不要包含测试代码或示例用法。
不要输出 Markdown 代码块标记(例如三个反引号和语言名)。
不要输出任何额外说明文字或日志输出; 只输出可编译的 TypeScript 源码。
```

## 考察能力

- **数据结构理解**: 理解树形结构和节点关系
- **算法基础**: 递归、遍历算法(DFS/BFS)
- **复杂度分析**: 理解时间和空间复杂度
- **边界条件**: 处理空字符串、特殊字符等情况
- **代码组织**: 类设计、方法封装、类型定义
- **实用性**: 实现真实场景功能(自动补全)

## 测试要点

### 功能测试 (16 个自动化测试用例)
- [ ] **测试 1-2**: 插入和查找 - 基本单词、多个单词
- [ ] **测试 3**: 前缀匹配 - 基本前缀、不存在前缀、空前缀
- [ ] **测试 4-8**: 自动补全 - 不同层级的准确匹配、空结果、全量查询
- [ ] **测试 9**: 边界情况 - 空字符串处理
- [ ] **测试 10**: 边界情况 - 单字符单词和链式单词
- [ ] **测试 11**: 边界情况 - 重复插入处理
- [ ] **测试 12**: 边界情况 - 前缀同时也是完整单词
- [ ] **测试 13-14**: 复杂场景 - 共享前缀的单词集合
- [ ] **测试 15-16**: 性能测试 - 大数据量插入和查询

### 代码质量要求
- [ ] TypeScript 语法,默认导出 `Trie` 类
- [ ] 方法签名完全匹配:
  - `insert(word: string): void`
  - `search(word: string): boolean`
  - `startsWith(prefix: string): boolean`
  - `getWordsWithPrefix(prefix: string): string[]`
- [ ] 私有成员使用 `private` 修饰符
- [ ] 适当的类型注释
- [ ] 代码结构清晰,避免重复

### 性能要求
- [ ] 插入 10,000 个单词: 时间 < 1 秒
- [ ] 1,000 次查询操作: 时间 < 100 毫秒
- [ ] 内存使用合理,无内存泄漏
- [ ] 时间复杂度: O(m) for insert/search/startsWith
- [ ] 空间复杂度: O(n×m)

### 边界情况覆盖
- [ ] 空字符串输入
- [ ] 单字符单词
- [ ] 超长单词
- [ ] 重复数据插入
- [ ] 不存在的前缀查询
- [ ] 前缀同时也是完整单词
- [ ] 自动补全返回结果不重复

## 自动测试脚本与测试数据

### 测试框架

我们将使用以下 **TypeScript** 测试框架验证你的代码:

```typescript
// test-trie.ts
import Trie from './your-trie-code';

// 测试将自动运行,你需要实现 Trie 类使其通过所有测试用例

// 测试用例分组:
// 1. 基本操作测试
// 2. 前缀匹配测试
// 3. 自动补全测试
// 4. 边界情况测试
// 5. 性能测试
```

### 测试用例详情

你的实现将通过以下具体测试用例验证:

#### 测试组 1: 基本操作
```typescript
// 测试 1: 插入和查找
const trie = new Trie();
trie.insert("apple");
expect(trie.search("apple")).toBe(true);  // 应通过
expect(trie.search("app")).toBe(false);   // 应通过 - "app" 不是完整单词

// 测试 2: 多个单词
trie.insert("app");
trie.insert("application");
expect(trie.search("app")).toBe(true);        // 应通过
expect(trie.search("application")).toBe(true); // 应通过
```

#### 测试组 2: 前缀匹配
```typescript
const trie = new Trie();
trie.insert("apple");
trie.insert("application");
trie.insert("banana");

// 测试 3: 基本前缀匹配
expect(trie.startsWith("app")).toBe(true);   // 应通过
expect(trie.startsWith("appl")).toBe(true);  // 应通过
expect(trie.startsWith("ban")).toBe(true);   // 应通过
expect(trie.startsWith("ora")).toBe(false);  // 应通过 - 不存在
expect(trie.startsWith("")).toBe(true);      // 应通过 - 空前缀匹配所有
```

#### 测试组 3: 自动补全功能
```typescript
const trie = new Trie();
const words = ["cat", "car", "card", "care", "careful", "careless"];
words.forEach(word => trie.insert(word));

// 测试 4: 基本自动补全(结果集合正确,顺序不做要求)
const result1 = trie.getWordsWithPrefix("ca");
expect(result1.sort()).toEqual(["cat", "car", "card", "care", "careful", "careless"].sort());

// 测试 5: 精确前缀
const result2 = trie.getWordsWithPrefix("car");
expect(result2.sort()).toEqual(["car", "card", "care", "careful", "careless"].sort());

// 测试 6: 更具体前缀
const result3 = trie.getWordsWithPrefix("care");
expect(result3.sort()).toEqual(["care", "careful", "careless"].sort());

// 测试 7: 返回空数组
const result4 = trie.getWordsWithPrefix("xyz");
expect(result4).toEqual([]);

// 测试 8: 全量查询
const result5 = trie.getWordsWithPrefix("");
expect(result5.sort()).toEqual(words.sort());
```

#### 测试组 4: 边界情况
```typescript
const trie = new Trie();

// 测试 9: 空字符串
trie.insert("");
expect(trie.search("")).toBe(true);
expect(trie.startsWith("")).toBe(true);

// 测试 10: 单字符
trie.insert("a");
trie.insert("ab");
trie.insert("abc");
expect(trie.search("a")).toBe(true);
expect(trie.getWordsWithPrefix("a").sort()).toEqual(["a", "ab", "abc"].sort());

// 测试 11: 重复插入
trie.insert("test");
trie.insert("test");
expect(trie.search("test")).toBe(true);
expect(trie.getWordsWithPrefix("te")).toEqual(["test"]); // 不应重复

// 测试 12: 前缀同时也是完整单词
trie.insert("add");
trie.insert("addition");
expect(trie.search("add")).toBe(true);
expect(trie.getWordsWithPrefix("add").sort()).toEqual(["add", "addition"].sort());
```

#### 测试组 5: 复杂场景
```typescript
const trie = new Trie();
const techWords = [
  "algorithm", "alpha", "alphabet",
  "data", "database", "date",
  "structure", "struct", "string",
  "trie", "tree", "try"
];
techWords.forEach(word => trie.insert(word));

// 测试 13: 共享前缀的单词
const algoResults = trie.getWordsWithPrefix("algo");
expect(algoResults).toEqual(["algorithm"]);

const strResults = trie.getWordsWithPrefix("str");
expect(strResults.sort()).toEqual(["string", "struct", "structure"].sort());

// 测试 14: 不存在的前缀
expect(trie.startsWith("xyz")).toBe(false);
expect(trie.getWordsWithPrefix("xyz")).toEqual([]);
```

#### 测试组 6: 性能测试
```typescript
// 测试 15: 大数据量插入
const largeTrie = new Trie();
const startTime = Date.now();
for (let i = 0; i < 10000; i++) {
  largeTrie.insert("word" + i);
}
const insertTime = Date.now() - startTime;
expect(insertTime).toBeLessThan(1000); // 应在 1 秒内完成

// 测试 16: 大数据量查询
const queryStart = Date.now();
for (let i = 0; i < 1000; i++) {
  largeTrie.search("word" + i);
  largeTrie.startsWith("word" + i);
}
const queryTime = Date.now() - queryStart;
expect(queryTime).toBeLessThan(100); // 应在 100ms 内完成
```

### 运行测试

```bash
# 你的代码文件: trie.ts
# 测试文件: test-trie.ts

# 编译并运行
npm install typescript --save-dev
npx tsc --target ES2020 --module commonjs --moduleResolution node trie.ts test-trie.ts
node test-trie.js
```

**自动化测试说明:**
- 所有测试用例将自动运行
- 任何失败的测试将导致整体失败
- 性能测试有时间限制(插入 10000 单词 < 1s, 查询 1000 次 < 100ms)


## 分析与答案

### 解题思路

Trie(前缀树)是一种高效的字符串检索数据结构,特别适合处理前缀查询和自动补全场景。

**核心设计:**
1. **TrieNode 类**: 每个节点包含:
   - `children`: 子节点映射(字符 -> TrieNode)
   - `isEndOfWord`: 标记该节点是否为一个单词的结尾

2. **Trie 类**: 提供主要操作方法:
   - `insert`: 逐个字符插入,不存在则创建新节点
   - `search`: 遍历字符,检查路径是否存在且末尾标记为 true
   - `startsWith`: 只需检查路径是否存在
   - `getWordsWithPrefix`: 先找到前缀结尾节点,然后 DFS 收集所有单词(返回结果的顺序由遍历顺序决定,不要求特定排序)

### 标准答案 (TypeScript 实现)

```typescript
class TrieNode {
  children: Map<string, TrieNode>;
  isEndOfWord: boolean;

  constructor() {
    this.children = new Map();
    this.isEndOfWord = false;
  }
}

export default class Trie {
  private root: TrieNode;

  constructor() {
    this.root = new TrieNode();
  }

  /**
   * 插入一个单词到 Trie 中
   * 时间复杂度: O(m), m 为单词长度
   */
  insert(word: string): void {
    let node = this.root;

    for (const char of word) {
      if (!node.children.has(char)) {
        node.children.set(char, new TrieNode());
      }
      node = node.children.get(char)!;
    }

    node.isEndOfWord = true;
  }

  /**
   * 查找单词是否存在于 Trie 中
   * 时间复杂度: O(m), m 为单词长度
   * @returns boolean - 如果存在返回 true,否则返回 false
   */
  search(word: string): boolean {
    const node = this.searchPrefix(word);
    return node !== null && node.isEndOfWord;
  }

  /**
   * 判断是否有单词以该前缀开头
   * 时间复杂度: O(m), m 为前缀长度
   * @returns boolean - 如果有返回 true,否则返回 false
   */
  startsWith(prefix: string): boolean {
    return this.searchPrefix(prefix) !== null;
  }

  /**
   * 返回所有以该前缀开头的单词
   * 时间复杂度: O(p + n), p 为前缀长度, n 为匹配的单词总数
   * @returns string[] - 匹配的单词列表
   */
  getWordsWithPrefix(prefix: string): string[] {
    const node = this.searchPrefix(prefix);
    if (!node) {
      return [];
    }

    const results: string[] = [];
    this.collectWords(node, prefix, results);
    return results;
  }

  /**
   * 私有辅助方法:查找前缀对应的节点
   */
  private searchPrefix(prefix: string): TrieNode | null {
    let node = this.root;

    for (const char of prefix) {
      if (!node.children.has(char)) {
        return null;
      }
      node = node.children.get(char)!;
    }

    return node;
  }

  /**
   * 私有辅助方法:通过 DFS 收集所有单词
   */
  private collectWords(node: TrieNode, prefix: string, results: string[]): void {
    if (node.isEndOfWord) {
      results.push(prefix);
    }

    for (const [char, childNode] of node.children) {
      this.collectWords(childNode, prefix + char, results);
    }
  }
}
```

**注意:** 此实现与测试框架完全兼容,默认导出 Trie 类,包含所有必需的方法签名。

### 复杂度分析

**时间复杂度:**
- `insert(word)`: O(m), m 为单词长度
- `search(word)`: O(m), m 为单词长度
- `startsWith(prefix)`: O(m), m 为前缀长度
- `getWordsWithPrefix(prefix)`: O(p + n), p 为前缀长度, n 为匹配的单词总数

**空间复杂度:**
- O(n × m), n 为单词数量, m 为平均单词长度
- 最坏情况下,每个单词不共享任何前缀
- 最好情况下,所有单词共享相同前缀

### 关键设计决策

1. **使用 Map 而不是对象**: Map 提供更好的性能和更清晰的 API,特别是在处理特殊字符时
2. **递归收集单词**: DFS 遍历简洁直观,适合收集所有匹配单词
3. **分离公共方法**: `searchPrefix` 作为公共逻辑提取,避免代码重复
4. **单词结尾标记**: `isEndOfWord` 区分完整单词和前缀路径

### 常见错误

1. **忘记标记单词结尾**: 导致无法正确区分单词和前缀
2. **导出格式错误**: 没有使用 `export default class Trie`,导致测试框架无法导入
3. **方法签名不匹配**: 方法名、参数类型或返回类型与要求不符,导致测试失败
4. **空字符串处理不当**: 空字符串既是有效单词也是有效前缀
5. **getWordsWithPrefix 返回重复结果**: 重复插入单词导致结果列表中出现重复项
6. **DFS 收集单词时忘记传参**: 递归调用时没有正确传递前缀或结果数组
7. **未处理不存在的节点**: 遍历前缀时没有检查节点是否存在,导致空指针异常
8. **方法可见性错误**: 辅助方法应为 private,但声明为 public

### 通过所有测试的验证

你的实现应该通过以下严格的自动化测试流程:

1. **单元测试阶段**: 16 个具体测试用例逐一验证
   - 每个测试用例有明确的输入和预期输出
   - 任何不匹配都会导致测试失败

2. **边界条件测试**:
   - 空字符串、单字符、超长单词
   - 重复数据、不存在的前缀
   - 前缀同时也是完整单词的情况

3. **性能测试**:
   - 插入 10,000 个单词: 时间 < 1 秒
   - 1,000 次查询操作: 时间 < 100 毫秒
   - 内存使用合理,无内存泄漏

4. **代码质量检查**:
   - TypeScript 类型定义完整
   - 方法可见性正确 (public/private)
   - 导出格式正确 (default export)
   - 无冗余代码或死代码

### 与参考答案的不同实现

只要满足以下条件,实现方式可以与参考答案不同:

- ✅ **TypeScript** 语法,默认导出 Trie 类
- ✅ 方法签名完全一致:
  - `insert(word: string): void`
  - `search(word: string): boolean`
  - `startsWith(prefix: string): boolean`
  - `getWordsWithPrefix(prefix: string): string[]`
- ✅ 通过所有测试用例和性能要求
- ✅ 时间/空间复杂度符合要求

**允许的实现差异:**
- 使用对象字面量 `{}` 代替 `Map` (但性能可能较差)
- 使用数组代替 Map (需要处理字符索引)
- 不同的私有方法命名
- 不同的递归或迭代实现方式
- 额外的私有辅助方法（只要不破坏公共 API）

**不允许的实现差异:**
- ❌ JavaScript 实现 (非 TypeScript)
- ❌ 额外的方法参数
- ❌ 修改方法返回类型
- ❌ 不使用默认导出
- ❌ 缺少必需的方法
