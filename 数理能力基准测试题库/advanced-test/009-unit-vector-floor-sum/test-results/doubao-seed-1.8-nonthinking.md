### 步骤1：分析单位向量点积的取值范围与取整结果
对于单位向量$\boldsymbol{u},\boldsymbol{v}$，$\boldsymbol{u}\cdot\boldsymbol{v}=\cos\theta\in[-1,1]$，因此$\lfloor\boldsymbol{u}\cdot\boldsymbol{v}\rfloor$的可能取值只能是$-1,0,1$：
1.  $\lfloor\boldsymbol{u}\cdot\boldsymbol{v}\rfloor=1 \iff \boldsymbol{u}\cdot\boldsymbol{v}=1 \iff \boldsymbol{u}=\boldsymbol{v}$
  2. $\lfloor\boldsymbol{u}\cdot\boldsymbol{v}\rfloor=-1 \iff \boldsymbol{u}\cdot\boldsymbol{v}\in[-1,0)\iff \theta\in(\frac{\pi}{2},\pi]$
3. $\lfloor\boldsymbol{u}\cdot\boldsymbol{v}\rfloor=0 \iff \boldsymbol{u}\cdot\boldsymbol{v}\in[0,1)\iff \theta\in[0,\frac{\pi}{2})$

---
### 步骤2：分情况讨论等式$\boldsymbol{a}\cdot\boldsymbol{b} = \lfloor\boldsymbol{a}\cdot\boldsymbol{c}\rfloor + \lfloor\boldsymbol{b}\cdot\boldsymbol{c}\rfloor$
设$x=\lfloor\boldsymbol{a}\cdot\boldsymbol{c}\rfloor,y=\lfloor\boldsymbol{b}\cdot\boldsymbol{c}\rfloor$，则$\boldsymbol{a}\cdot\boldsymbol{b}=x+y$，且$x,y\in\{-1,0,1\}$
1.  **情况1：$x+y=1$**
    只能是$(x,y)=(1,0)$或$(0,1)$。
    - 若$x=1,y=0$，则$\boldsymbol{a}=\boldsymbol{c}$，$\boldsymbol{b}\cdot\boldsymbol{c}\in[0,1)$
    $\boldsymbol{a}\cdot\boldsymbol{b}=\boldsymbol{b}\cdot\boldsymbol{c}\in[0,1)$，满足条件。此时：
    $$|\boldsymbol{a}+\boldsymbol{b}+\boldsymbol{c}|=|2\boldsymbol{a}+\boldsymbol{b}|=\sqrt{4+1+4\boldsymbol{a}\cdot\boldsymbol{b}}=\sqrt{5+4t},t\in[0,1)$$
    取值范围是$[\sqrt{5},3)$
  2.  **情况2：$x+y=0$**
    可能$(x,y)=(1,-1),(-1,1),(0,0)$
    - $(x,y)=(1,-1)$：$\boldsymbol{a}=\boldsymbol{c}$，$\boldsymbol{b}\cdot\boldsymbol{c}\in[-1,0)$，$\boldsymbol{a}\cdot\boldsymbol{b}\in[-1,0)$，满足条件
        $$|\boldsymbol{a}+\boldsymbol{b}+\boldsymbol{c}|=|2\boldsymbol{a}+\boldsymbol{b}|=\sqrt{5+4t},t\in[-1,0)$$
        取值范围是$(1,\sqrt{5}]$
    -  $(x,y)=(0,0)$：$\boldsymbol{a}\cdot\boldsymbol{c}\in[0,1),\boldsymbol{b}\cdot\boldsymbol{c}\in[0,1)$，$\boldsymbol{a}\cdot\boldsymbol{b}=0$
        $$|\boldsymbol{a}+\boldsymbol{b}+\boldsymbol{c}|^2=3+2(\boldsymbol{a}\cdot\boldsymbol{b}+\boldsymbol{a}\cdot\boldsymbol{c}+\boldsymbol{b}\cdot\boldsymbol{c})=3+2(\boldsymbol{a}\cdot\boldsymbol{c}+\boldsymbol{b}\cdot\boldsymbol{c})$$
        $\boldsymbol{a}\cdot\boldsymbol{c}+\boldsymbol{b}\cdot\boldsymbol{c}\in[0,2)$，故模长范围是$[\sqrt{3},\sqrt{7})$
  3. **情况3：$x+y=-1$**
    只能是$(x,y)=(-1,0)$或$(0,-1)$
        - 若$x=-1,y=0$，$\boldsymbol{a}\cdot\boldsymbol{c}\in[-1,0),\boldsymbol{b}\cdot\boldsymbol{c}\in[0,1)$，$\boldsymbol{a}\cdot\boldsymbol{b}=-1$，即$\boldsymbol{a}=-\boldsymbol{b}$
        $$|\boldsymbol{a}+\boldsymbol{b}+\boldsymbol{c}|=|\boldsymbol{c}|=1$$
  4. **情况4：$x+y=-2$**
    $(x,y)=(-1,-1)$，$\boldsymbol{a}\cdot\boldsymbol{b}=-1$，$\boldsymbol{a}=-\boldsymbol{b}$，$\boldsymbol{a}\cdot\boldsymbol{c}\in[-1,0),\boldsymbol{b}\cdot\boldsymbol{c}=-\boldsymbol{a}\cdot\boldsymbol{c}\in(0,1]$，矛盾，舍去
  5. **情况5：$x+y=2$**
    $(x,y)=(1,1)$，$\boldsymbol{a}=\boldsymbol{c},\boldsymbol{b}=\boldsymbol{c}$，$\boldsymbol{a}=\boldsymbol{b}=\boldsymbol{c}$，$\boldsymbol{a}\cdot\boldsymbol{b}=1$，满足条件
        $$|\boldsymbol{a}+\boldsymbol{b}+\boldsymbol{c}|=3$$
---
### 步骤3：合并所有情况的取值范围
综合所有情况，模长可以取到$1$，$[1,\sqrt{3}),[\sqrt{3},\sqrt{5}],[\sqrt{5},3)$以及$3$，最终范围是$[1,3]$

**答案：$\boldsymbol{[1,3]}$**