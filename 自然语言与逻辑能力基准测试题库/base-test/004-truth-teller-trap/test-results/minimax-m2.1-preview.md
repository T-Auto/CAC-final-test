<thinking>
We need to parse the puzzle: Two boxes A and B. One contains candy, the other is empty. On each box, a note is attached:

- A box: "The candy is in box B"
- B box: "Both boxes' notes are lying"

We know that only one note is true, i.e., exactly one of the two statements is true, and the other is false. Determine which box has the candy.

We must think through possibilities.

Let’s denote statements:

S_A: "Candy is in B"
S_B: "Both notes are lying" i.e., "S_A is false and S_B is false". But S_B is a statement about the truth values of both notes. So S_B is "the note on A is lying AND the note on B is lying". But if S_B is true, then both notes are lying, which includes S_B itself being false (since it's lying). That's a paradox: a statement cannot be both true and false. Therefore S_B cannot be true; it must be false. Because if S_B were true, then both notes are lying, which would include S_B being false, contradiction. So S_B must be false.

Given that only one note is true, S_B being false implies S_A must be true (since only one true). So S_A is true: "Candy is in B". So candy is in B.

But we need to check consistency: S_A true, S_B false. Does that satisfy "both notes are lying"? No, because S_A is not lying. So S_B's claim "both notes are lying" is false. That's consistent. So answer: candy in B.

Thus the solution is B.

We should also consider possibility that S_B is true? Let's examine that scenario. If S_B is true, then both notes are lying. That would mean S_A is lying. So S_A false: "Candy is in B" is false, so candy is not in B, i.e., candy is in A. Also S_B is true. But S_B says both notes are lying, which includes S_B lying. But S_B is true, so it's not lying. Contradiction. So S_B cannot be true. So only solution is candy in B.

Thus answer: B.

We can present reasoning step by step.

Now the user asked in Chinese: "有两个盒子A和B，其中一个装着糖果，另一个是空的。盒子上分别贴着纸条：- A盒：'糖果在B盒里'- B盒：'两个盒子的纸条都在撒谎'已知只有一张纸条说的是真话，请问糖果在哪个盒子里？"

We need to respond in Chinese, presumably. Provide reasoning.

Thus final answer: 糖果在B盒子里.

We can also discuss the paradox and reasoning.

Now let's produce a final answer in Chinese.
</thinking>

**答案：糖果在 B 盒子里。**

**推理过程：**

设  
- \(S_A\) 为 A 盒子上纸条的内容：“糖果在 B 盒里”。  
- \(S_B\) 为 B 盒子上纸条的内容：“两个盒子的纸条都在撒谎”。

已知 **只有一张纸条说的是真话**（即恰好有一个陈述为真，另一个为假）。

---

### 1. 假设 \(S_B\) 为真

如果 \(S_B\) 为真，则它的内容必须成立，即：

> 两个盒子的纸条都在撒谎。

这意味着 **\(S_A\) 为假**，并且 **\(S_B\) 本身也为假**（因为它在说自己在撒谎）。但这与假设 “\(S_B\) 为真” 矛盾。  

因此 **\(S_B\) 不能为真**。

---

### 2. 只能是 \(S_A\) 为真

既然 \(S_B\) 必为假，那么唯一满足“只有一张纸条为真”的方式就是 **\(S_A\) 为真**。

\(S_A\) 为真意味着：

> “糖果在 B 盒里” 确实成立。

于是糖果位于 **B 盒**。

---

### 3. 验证一致性

- \(S_A\) 为真 → 糖果在 B 盒。  
- \(S_B\) 为假 → “两个盒子的纸条都在撒谎” 不成立，这正是我们得到的情况（A 盒的纸条在说真话），所以没有矛盾。

---

**结论：** 糖果在 **B 盒**。