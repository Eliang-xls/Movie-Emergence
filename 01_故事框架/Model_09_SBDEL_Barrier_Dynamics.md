# SBDEL 模型二：壁垒动力学与引用影响力模型
## Model 09: SBDEL Barrier Dynamics & Citation Impact — 从个人垄断到网络记忆的数学描述

> 对应 CONC 公理体系定理 S2（分布式增益）和定理 S3（引用链可追溯）的动力学扩展。研究知识壁垒在 SBDEL 网络中的转化路径——从静态的个人垄断到动态的网络记忆。

---

## 一、模型定位

| 维度 | 说明 |
|------|------|
| **CONC 层级** | 定理层（S2 + S3 的动力学扩展） |
| **推导来源** | 公理四（模块承诺）+ 公理二a（主权节点）+ SBDEL 定理 S1-S4 |
| **研究问题** | 在 Skill 流通网络中，个人知识壁垒如何被转化为网络集体记忆？创造者声誉如何在竞争的 Skill 生态中维持？ |
| **核心洞察** | 壁垒不是被消除——而是被重新定义。"我的知识只有我知道" → "我的知识被网络记住，且我的名字永远在引用链上" |

---

## 二、壁垒价值函数

### 2.1 主函数

$$B(n, t) = \underbrace{S(n, t)}_{\text{Skill积累}} \cdot \underbrace{e^{-\lambda \cdot \Delta t_{\text{last}}}}_{\text{时间衰减}} \cdot \underbrace{(1 - \rho \cdot C_{\text{network}}(t))}_{\text{网络扩散稀释}} \cdot \underbrace{(1 - A(s, t))}_{\text{授权保护的残余}}$$

其中：
- $S(n, t)$：智权体 $n$ 在时刻 $t$ 的 Skill 积累量（八层结构中已公开层数的加权总和）
- $\lambda$：Skill 的自然衰减率（对应 SBDEL 的 `skill_relevance` 函数）
- $\Delta t_{\text{last}}$：自最近一次有效贡献以来的时间
- $\rho$：Skill 在网络中的扩散系数（$0 \leq \rho \leq 1$）
- $C_{\text{network}}(t)$：网络中同类 Skill 的总量（竞争饱和度）
- $A(s, t)$：授权衰减函数（详见模型 08）

### 2.2 三个动力学阶段

| 阶段 | $C_{\text{network}}$ | $A(s,t)$ | 壁垒价值 $B$ | 创造者收益来源 |
|------|:---:|:---:|:---:|------|
| **早期（锁定）** | 低 | $\approx A_{\min}$ | **高** | 授权费 + VT 分成 |
| **中期（渐进释放）** | 增长 | 增长 | **下降** | 授权费减少 + 引用声誉增长 |
| **后期（完全公开）** | 高 | $1$ | **趋零** | 纯声誉收益 + 引用链中的创造者地位 |

### 2.3 稳态分析

$$\lim_{t \to \infty} B(n, t) = B_{\min} = S_{\text{new}}(n) \cdot \rho_{\text{creation}}$$

其中 $S_{\text{new}}(n)$ 为创造者的**新 Skill 产出速率**，$\rho_{\text{creation}}$ 为创造者声誉系数。**在稳态中，壁垒不由"积累量"决定——而由"创造速度"决定。**

---

## 三、引用影响力函数

### 3.1 Skill 引用图

$$G_S = (V_S, E_S)$$

其中 $V_S$ 是所有 Skill 节点集合，$E_S$ 是引用边集合。引用边类型：

| 边类型 | 含义 | 权重含义 |
|--------|------|---------|
| `direct_parent` | 直系血统（fork 关系） | 继承比例 |
| `cross_domain_absorption` | 跨域吸收 | 被吸收的 Layer 权重 |
| `validation_tool` | 验证引用 | 验证贡献度 |
| `collaborative_co_creation` | 协作共创 | 共创者贡献比例 |
| `authorized_usage` | 授权使用 | 授权范围 |

### 3.2 引用影响力（Citation Impact）

$$CI(s) = \sum_{s' \in \text{derivatives}(s)} \frac{1}{\text{depth}(s, s')} \cdot \text{quality}(s') \cdot \text{recency}(s')$$

其中：
- $\text{depth}(s, s')$：引用图上的最短路径深度（直接 fork = 1，间接衍生 = 2+）
- $\text{quality}(s')$：衍生 Skill 的 PEER 评审质量分数
- $\text{recency}(s')$：衍生 Skill 的时间新鲜度（$e^{-\mu \cdot \text{age}}$，$\mu$ 为新鲜度衰减率）

**设计原理**：$CI(s)$ 随 depth 倒数衰减——浅层引用的权重高于深层引用。深度引用（曾孙 Skill 质量高）仍然贡献正的 $CI$，但权重递减。这防止了"深度伪造引用链"套利——你需要真实的、被认可的衍生 Skill 来积累引用影响力。

### 3.3 创造者贡献度（Creator Contribution）

$$CC(\text{ns}, s) = \frac{\sum_{m \in \text{modifications by ns}} \text{weight}(m)}{\sum_{m \in \text{all modifications}} \text{weight}(m)}$$

其中 $\text{weight}(m)$ 由修改涉及的 Layer 和修改幅度决定：

$$\text{weight}(m) = \sum_{l \in \text{modified\_layers}} w_l \cdot \text{change\_magnitude}(m, l)$$

Layer 权重 $w_l$ 反映不同层的知识价值：

| Layer | $w_l$ | 含义 |
|-------|:---:|------|
| L4（蒸馏知识）| $1.0$ | 最高价值——最佳实践和反模式 |
| L5（可复用代码）| $0.9$ | 高价值——可直接使用的代码 |
| L3（决策记录）| $0.7$ | 中高价值——决策逻辑 |
| L2（过程记录）| $0.3$ | 低价值——执行记录 |
| L1（场景描述）| $0.2$ | 最低——元数据 |

---

## 四、壁垒转化的动力学模型

### 4.1 从个人壁垒到网络记忆的转化率

$$\eta_{\text{barrier}}(n, t) = \frac{CI(n, t)}{CI(n, t) + B(n, t)}$$

其中 $CI(n, t)$ 是智权体 $n$ 所有 Skill 的累积引用影响力，$B(n, t)$ 是其当前壁垒价值。

- $\eta_{\text{barrier}} \to 0$：智权体的价值主要来自当前的壁垒保护（早期创造者）
- $\eta_{\text{barrier}} \to 1$：智权体的价值已完全从"壁垒"转化为"网络记忆中的声誉"（成熟创造者）

### 4.2 转化速率

$$\frac{d\eta_{\text{barrier}}}{dt} = \alpha \cdot A(s, t) \cdot \frac{dCI(n, t)}{dt} - \beta \cdot \frac{dB(n, t)}{dt}$$

当 Skill 公开化（$A \to 1$）且引用影响力增长（$dCI/dt > 0$）时，转化速率最大。当创造者停止产出新 Skill 时（$dCI/dt \to 0$），$\eta_{\text{barrier}}$ 趋于一个由历史引用决定的稳态值——**过去的创造被网络永远记住，但不再增长。**

---

## 五、竞争动力学：Skill 的优胜劣汰

### 5.1 Skill 竞争模型

两个竞争 Skill $s_1$ 和 $s_2$ 的优胜劣汰由复合质量函数决定：

$$Q_{\text{composite}}(s) = \alpha_1 \cdot \text{quality\_score}(s) + \alpha_2 \cdot \text{success\_rate}(s) + \alpha_3 \cdot \frac{CI(s)}{CI_{\max}} + \alpha_4 \cdot \text{recency}(s)$$

其中 $\sum \alpha_i = 1$。

### 5.2 优胜条件

当 $Q_{\text{composite}}(s_1) > Q_{\text{composite}}(s_2) + \epsilon$ 持续超过 $\tau$ 时间窗口，$s_1$ 取代 $s_2$ 成为该场景的推荐 Skill。$s_2$ 进入"存档状态"——仍可被引用但不再活跃推荐。

### 5.3 创造者声誉的持久性

即使 Skill 被取代，创造者的 $CI$ 不消失——因为后续 Skill 通过引用链仍追溯到源头创造者。**这确保了"第一发现者"的声誉不会因被超越而消失——它只是不再增长。**

---

## 六、均衡特征与政策含义

### 6.1 均衡条件

在长期均衡中：

1. **新进入者**：使用已有 Skill 作为起点（$C_{\text{network}}$ 高 → 壁垒低）→ 快速追赶
2. **持续创造者**：通过新 Skill 产出维持 $B(n,t) > B_{\min}$ → 创造者声誉持续增长
3. **停止创造者**：$B(n,t) \to B_{\min}$，但 $CI$ 维持在历史水平 → 声誉不消失但不增长

### 6.2 三个政策含义

| 政策含义 | 机制 | 效果 |
|---------|------|------|
| **不需要人为保护壁垒** | Skill 流通的自然过程稀释旧壁垒（$\rho \cdot C_{\text{network}}$ 项） | 壁垒自动衰减 |
| **不需要强制消除壁垒** | 持续创造新 Skill 的人自然维持优势（$S_{\text{new}}$ 项） | 激励保留 |
| **NR 衰减机制自然运转** | 停止创造 → $B \to B_{\min}$ → 有效 NR 下降 | 为新人让出空间 |

---

## 七、与 CONC 涌现经验规律的联动

SBDEL 壁垒动力学与 $\eta(N)$ 涌现效率存在深层联动：

$$\eta_{\text{effective}}(N) = \eta(N) \cdot \left(1 + \gamma \cdot \frac{\sum_{n \in G} B(n, t)}{N} \right)$$

当策元成员具有更高的壁垒价值（更深的知识积累）时，有效涌现效率提升——因为成员间的知识互补性更强。但随着 $C_{\text{network}}$ 增长（网络整体知识水平提升），单个成员的壁垒被稀释，$\eta_{\text{effective}}$ 向基线 $\eta(N)$ 回归。

**这意味着**：在 CONC 网络早期，Skill 积累带来显著的涌现效率增益；在网络成熟期，Skill 成为公共基础设施后，涌现效率回归到由协作规模决定的基线水平。

---

## 八、可证伪条件

| # | 预测 | 验证方法 | 判定标准 |
|---|------|---------|---------|
| F1 | 引用链中的高 $CI$ Skill 的实际使用成功率高于低 $CI$ Skill | 引用-成功率相关分析 | 相关系数 $> 0.5$ |
| F2 | 创造者连续 6 个月无新 Skill 产出后，其有效 NR 下降 > 30% | 纵向追踪 | $p < 0.05$ |
| F3 | 竞争密度 $C_{\text{network}}$ 每增加 0.1 → 新进入者的第一个月任务令匹配率增加 | 回归分析 | 方向性一致 |
| F4 | 同一场景下，两个竞争 Skill 中 $Q_{\text{composite}}$ 更高的在后续 3 个月内使用占比 > 60% | 自然选择观察 | 占比 > 60% |
| F5 | $\eta_{\text{barrier}}(n, t)$ 从早期（$t < 1$ 年）到成熟期（$t > 3$ 年）的增长率 > 50% | 纵向追踪 | 增长率 > 50% |

---

## 九、模型边界与局限

1. **引用图数据的完整性**：依赖 Skill 流通网络的 Gossip 广播覆盖率和 Skill 检索的完整性
2. **质量分数的客观性**：PEER 评审质量分数 $quality\_score$ 本身可能被博弈论扭曲（如合谋评审）
3. **竞争密度的计算粒度（v1.1修正——CONC-P0-3）**：竞争关系由**市场替代率**决定，不由文本相似度决定。Burk & Lemley 的专利法理论已证明：两件专利之间的竞争关系取决于"一个产品的用户是否会因为另一个产品的存在而切换选择"——而非权利要求文本的重叠度。同理，两个Skill之间的竞争关系取决于它们解决同一场景问题的可替代性，而非它们的文本相似度。$C_{\text{network}}$ 应基于场景标签共现矩阵而非文本相似度计算。过渡方案：使用场景标签的Jaccard相似度作为替代率的代理变量。
4. **长期声誉的量化**：$CI$ 将声誉简化为可计算信号——但真实声誉包含不可量化的维度（信任、品味、人格）
5. **与 NR 体系的关系**：$CI$ 和 NR 分别追踪"知识贡献"和"任务执行"——两者可能有重叠（完成高质量任务令同时产出高质量 Skill），但不可互换

---

*模型 09 — SBDEL 壁垒动力学与引用影响力 | v1.0 | 2026-05-19*
*对应 Axioms 定理 S2 + S3 | 推导来源：公理四 + 公理二a + SBDEL 定理 S1-S4*
