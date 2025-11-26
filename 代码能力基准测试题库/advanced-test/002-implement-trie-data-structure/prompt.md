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
