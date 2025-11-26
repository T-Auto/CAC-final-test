# 考察能力

- **数据结构理解**: 理解树形结构和节点关系
- **算法基础**: 递归、遍历算法(DFS/BFS)
- **复杂度分析**: 理解时间和空间复杂度
- **边界条件**: 处理空字符串、特殊字符等情况
- **代码组织**: 类设计、方法封装、类型定义
- **实用性**: 实现真实场景功能(自动补全)

# 测试要点

## 功能测试 (16 个自动化测试用例)
- [ ] **测试 1-2**: 插入和查找 - 基本单词、多个单词
- [ ] **测试 3**: 前缀匹配 - 基本前缀、不存在前缀、空前缀
- [ ] **测试 4-8**: 自动补全 - 不同层级的准确匹配、空结果、全量查询
- [ ] **测试 9**: 边界情况 - 空字符串处理
- [ ] **测试 10**: 边界情况 - 单字符单词和链式单词
- [ ] **测试 11**: 边界情况 - 重复插入处理
- [ ] **测试 12**: 边界情况 - 前缀同时也是完整单词
- [ ] **测试 13-14**: 复杂场景 - 共享前缀的单词集合
- [ ] **测试 15-16**: 性能测试 - 大数据量插入和查询

## 代码质量要求
- [ ] TypeScript 语法,默认导出 `Trie` 类
- [ ] 方法签名完全匹配
- [ ] 私有成员使用 `private` 修饰符
- [ ] 适当的类型注释
- [ ] 代码结构清晰,避免重复

## 性能要求
- [ ] 插入 10,000 个单词: 时间 < 1 秒
- [ ] 1,000 次查询操作: 时间 < 100 毫秒
- [ ] 时间复杂度: O(m) for insert/search/startsWith
- [ ] 空间复杂度: O(n×m)

# 参考实现

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

  search(word: string): boolean {
    const node = this.searchPrefix(word);
    return node !== null && node.isEndOfWord;
  }

  startsWith(prefix: string): boolean {
    return this.searchPrefix(prefix) !== null;
  }

  getWordsWithPrefix(prefix: string): string[] {
    const node = this.searchPrefix(prefix);
    if (!node) return [];
    const results: string[] = [];
    this.collectWords(node, prefix, results);
    return results;
  }

  private searchPrefix(prefix: string): TrieNode | null {
    let node = this.root;
    for (const char of prefix) {
      if (!node.children.has(char)) return null;
      node = node.children.get(char)!;
    }
    return node;
  }

  private collectWords(node: TrieNode, prefix: string, results: string[]): void {
    if (node.isEndOfWord) results.push(prefix);
    for (const [char, childNode] of node.children) {
      this.collectWords(childNode, prefix + char, results);
    }
  }
}
```

# 评判标准

1. **功能正确性 (50%)**：通过所有测试用例
2. **代码质量 (30%)**：结构清晰、类型完整、命名规范
3. **性能 (20%)**：满足时间/空间复杂度要求
