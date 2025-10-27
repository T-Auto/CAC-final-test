# 仓库维护规范 v0.1

> **❗在push和提交pr之前务必阅读此文档**

## 文件组织规范

总体逻辑如下：
```text
# 子目录需要遵循两层次分类
CAC-final-test/
├── 代码能力基准测试题库/
│   ├── advanced-test/
│   ├── base-test/
│   ├── final-test/
│   └── final-test+/
├── 数理能力基准测试题库/
│   ├── advanced-test/
│   ├── base-test/
│   ├── final-test/
│   └── final-test+/
├── 自然语言与逻辑能力基准测试题库/
│   ├── advanced-test/
│   ├── base-test/
│   ├── final-test/
│   └── final-test+/
├── 综合能力测评/
├── README.md  # 简介
└── CONTRIBUTING.md # 仓库维护手册
```

对于具体分类题库，这里以 `代码能力基准测试题库/advanced-test/`为例子：
```text
# 文件需要遵循时间顺序编号
advanced-test/
├── 001-problem_name_1.md
├── 002-problem_name_2.md
```


## 题目编写规范

