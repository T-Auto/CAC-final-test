class TrieNode {
  children: Record<string, TrieNode>;
  isEnd: boolean;

  constructor() {
    this.children = {};
    this.isEnd = false;
  }
}

export default class Trie {
  private root: TrieNode;

  constructor() {
    this.root = new TrieNode();
  }

  insert(word: string): void {
    let current = this.root;
    for (const char of word) {
      if (!current.children[char]) {
        current.children[char] = new TrieNode();
      }
      current = current.children[char];
    }
    current.isEnd = true;
  }

  search(word: string): boolean {
    let current = this.root;
    for (const char of word) {
      if (!current.children[char]) {
        return false;
      }
      current = current.children[char];
    }
    return current.isEnd;
  }

  startsWith(prefix: string): boolean {
    if (prefix === "") {
      return true;
    }
    let current = this.root;
    for (const char of prefix) {
      if (!current.children[char]) {
        return false;
      }
      current = current.children[char];
    }
    return true;
  }

  getWordsWithPrefix(prefix: string): string[] {
    const result: string[] = [];
    let current = this.root;

    for (const char of prefix) {
      if (!current.children[char]) {
        return result;
      }
      current = current.children[char];
    }

    const dfs = (node: TrieNode, currentSuffix: string) => {
      if (node.isEnd) {
        result.push(prefix + currentSuffix);
      }
      const sortedChars = Object.keys(node.children).sort();
      for (const char of sortedChars) {
        dfs(node.children[char], currentSuffix + char);
      }
    };

    dfs(current, "");
    return result;
  }
}