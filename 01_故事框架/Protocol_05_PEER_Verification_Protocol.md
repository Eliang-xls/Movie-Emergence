# PEER(n) 验证协议规范
## PEER(n) Verification Protocol Specification v2.2

> 协议标识符：`CONC-Protocol/Verification.PEER.2.2`
> 依赖：公理四（模块承诺）、模型三（NR 信号博弈 ESS）、NR_reliability 维度
> 协议层归属：验证层 (Verification Layer)
>
> **完备度声明**：本规范将 PEER(n) 从描述性状态（40%）提升至正式协议规范（85%+）。覆盖评审分配算法、评分聚合公式、评审者质量追踪、争议升级流程、全部 API 端点及错误码。

---

## 〇、协议定位与设计概要

### 0.1 在验证三模式中的位置

CONC 公理四定义三种模块验证方式：

| 验证类型 | 确定性 | 适用场景 | 本协议覆盖 |
|----------|:---:|---------|:---:|
| `AUTO` | 确定性 | 编译/测试/格式检查 | ✗ |
| **`PEER(n)`** | **统计共识** | **设计/文案/架构评审/代码审查** | **✓ 本协议** |
| **`PEER_SYNC`** | **人际共识** | **高复杂度/高利害/需隐性知识传递的任务令** | **✓ 本协议 §0.3** |
| `MARKET` | 市场反馈 | 产品投放/品牌策略 | ✗ |

PEER(n) 是 CONC 处理**非确定性任务质量判定**的核心协议。其数学基础来自模型三（NR 信号博弈）的 O(1/√n) 收敛性证明：当 n ≥ 3，评审噪声以 O(1/√n) 衰减。n=3 将单评审误差率（~30%）降至聚合误差率约 17%；n=5 降至约 13%。

### 0.2 协议设计目标

1. **防共谋 (Anti-Collusion)**：随机化分配 + 多样性约束 + 审计威慑，确保评审者无法形成互惠交换环。
2. **准确性 (Accuracy)**：加权聚合公式收敛到统计共识，评审者权重随其历史准确度动态调整。
3. **可追责 (Accountability)**：每次评审记录上链/可验证。评审者质量被持续追踪——好评审获得更高权重，持续异常评审者被降权和惩罚。
4. **可争议 (Appealable)**：争议升级路径清晰——PEER(3) → PEER(5) → 策元全体评审。

### 0.3 PEER_SYNC：同步面对面评审模式

PEER_SYNC 是 PEER 协议为**高复杂度、高利害、或需要隐性知识传递**的任务令保留的同步评审模式。当任务令涉及架构决策、安全审计、创意方向或跨策元协作等难以仅通过异步评分维度充分评估的工作时，策元核（或任务令的 genesis 方）可以在任务令进入 BROADCAST 状态时声明使用 PEER_SYNC 替代异步 PEER(3)。

**PEER_SYNC 与异步 PEER(n) 的关键差异**：

| 维度 | 异步 PEER(3) | PEER_SYNC |
|------|:---:|:---:|
| 评审方式 | 异步提交评分 | 同步视频/面对面评审会议 |
| 参与者 | 3 位随机分配评审者 | 3-5 位评审者 + 任务令提供方 + 策元核代表（可选） |
| 时间要求 | 48 小时内提交评分 | 实时会议（建议 ≤ 90 分钟），会后 24 小时内提交书面评分 |
| 隐性知识传递 | 无——仅依赖 deliverable 本身 | 有——提供方可演示、答疑、解释设计意图 |
| 共识形成 | 统计聚合（加权平均） | 讨论导向——评审者在会议中交换意见后独立评分，仍使用聚合公式 |
| 适用场景 | 常规代码审查、文档评审、UI 评审 | 架构决策、安全审计、创意方向评审、跨策元协作产出 |
| 审计概率 | 10%（例行） | 50%（因其高利害性质） |

**PEER_SYNC 流程**：

```
1. genesis 方在任务令 BROADCAST 时声明 mode=PEER_SYNC
2. AssignReviewers(task_id, n=3..5, strategy="expertise_priority")
   // PEER_SYNC 默认使用专长优先策略，确保评审者具备领域深度
3. 系统自动安排同步会议窗口（3 个备选时间，评审者在 24h 内投票确认）
4. 会议进行（建议 ≤ 90 分钟）：
   a. 提供方演示交付物并解释关键设计决策（≤ 20 分钟）
   b. 评审者提问与讨论（≤ 50 分钟）
   c. 评审者闭门独立评分（≤ 20 分钟）
5. 会后 24 小时内每位评审者通过 POST /peer-review/submit 提交正式评分
6. 聚合与裁决流程与异步 PEER(n) 相同（§四-§六）
```

PEER_SYNC 不改变评分维度、聚合公式、置信度计算和争议升级路径——它仅在评审方式上引入同步人际交互，保留协议其他所有结构不变。其设计理念来自 Ostrom 的研究发现：**面对面沟通（face-to-face communication）是促进合作的最有效机制**——比任何纯制度设计都更有效（Ostrom, 1990, *Governing the Commons*）。

### 0.4 协议的边界：PEER 是信任的补充，不是替代

PEER 协议（含 PEER_SYNC）处理的是**可形式化、可量化的验证维度**——编译是否通过、测试覆盖率是否达标、接口是否符合约定、交付物是否完整。这些是协议的「硬边界」——协议在这些维度上可以做到 O(1/√n) 精度的统计收敛。

但 CONC 协作中的许多关键维度**无法被协议捕获**：

- **设计美学 (Design Aesthetics)**：一个界面是否「好看」——协议无法评判，它来自人类的审美共识。
- **代码优雅 (Code Elegance)**：一段代码是否「写得好」——不仅是正确性，还涉及可读性、可维护性、风格一致性。这些标准高度依赖社区共识和隐性知识。
- **创意方向 (Creative Direction)**：产品策略或品牌定位是否「对」——这需要市场直觉、文化理解和对未来趋势的判断。
- **协作默契 (Collaboration Tacit Knowledge)**：团队成员之间通过长期协作建立的无声共识——谁擅长什么、谁在什么情况下需要帮助、何时应该让步。

这些维度落在协议的「软边界」之外——它们属于**人际信任 (interpersonal trust)** 的领域，由面对面的沟通、共同的工作经历和社区规范维系。Ostrom (1990) 的核心发现——面对面的沟通和社区规范在促进合作方面优于任何制度设计——在 CONC 中同样适用。这正是 CONC 伦理章节中 **philia（友爱）** 概念的核心：协议提供制度性保障，但创造性协作的真正动力来自人与人之间的信任和共同承诺。

因此，PEER 协议的定位是：

> **PEER 是人际信任的补充，而非替代。** 协议处理「可验证的」——让评审者不用担心编译是否通过、测试是否覆盖、接口是否合规；人类处理「可信任的」——设计是否优雅、方向是否正确、合作是否愉快。两者各司其职，不可相互替代。协议的目标不是消除信任，而是将信任从「是否作弊」的重复审查中解放出来，使其专注于更需要人类判断的创造性维度。

---

## 一、评审者池与资格

### 1.1 资格条件

一个智权体具备 PEER 评审资格当且仅当：

```
eligible(ns_id) :=
    NR(ns_id) ≥ NR_min_reviewer      -- 基线声誉门槛（默认 50）
    ∧ ns_id 已完成身份锚定             -- 非匿名
    ∧ active_penalties(ns_id) = ∅    -- 无活跃合谋惩罚
    ∧ cooldown_expired(ns_id)        -- 不在评审冷却期
```

NR_min_reviewer = 50 基于冷启动信号路径（模型三 §9.2）：一个新智权体需要 3-5 个月达到 NR>50，这与「具备基本 CONC 协作经验」的预期一致。

### 1.2 评审者池构建

每个策元维护一个**本地评审者池** (Local Reviewer Pool)：

```
ReviewerPool(gu_id) := {
    ns ∈ members(gu_id) | eligible(ns)
}
```

当策元本地池 < 3 时，自动扩展至**全局评审者池** (Global Reviewer Pool)：

```
GlobalReviewerPool := {
    ns ∈ N(all) | eligible(ns) ∧ ns 在最近 90 天内完成过 ≥ 2 个 PEER 评审
}
```

### 1.3 评审者能力标签

每个评审者可声明 1-5 个**评审专长标签** (Review Expertise Tags)，用于匹配任务令的领域：

| 标签 | 示例 |
|------|------|
| `code_review` | Solidity / Rust / Python 代码评审 |
| `architecture` | 系统架构 / API 设计评审 |
| `ui_ux` | UI 设计 / 交互体验评审 |
| `technical_writing` | 技术文档 / 白皮书评审 |
| `product_strategy` | 产品方向 / 市场策略评审 |

专长匹配度通过 Jaccard 相似度计算：`expertise_match = |tags(reviewer) ∩ tags(task)| / |tags(task)|`

### 1.4 盲审设计（v2.2 新增）

为防止评审者对被评审者身份的偏见影响评分客观性，PEER 协议自 v2.2 起强制实施盲审机制：

**评审者可见信息**：

| 可见内容 | 说明 |
|---------|------|
| 项目内容 (deliverable) | 完整的交付物——代码、文档、设计稿等 |
| Rubric 维度 | 完成度/质量/接口合规/时效性四个评分维度及其权重 |
| 评分要求 | 各维度的 1-5 分含义说明（见 §三.1） |
| 任务令 spec | 任务令原始需求描述——用于判定完成度 |
| 评审窗口截止时间 | 提交评分的 deadline（见 §三.5） |

**评审者不可见信息**：

| 隐藏内容 | 理由 |
|---------|------|
| 被评审者 `ns_id` | 防止身份偏见——高 NR 者的平庸产出也可能获高分 |
| 被评审者 NR 值 | 防止「光环效应」——NR 高不代表本次产出一定好 |
| 被评审者策元归属 (`genesis_id`) | 防止策元间政治偏袒或歧视 |
| 被评审者历史评审记录 | 防止锚定效应——每次评审应独立判断 |
| 任务令的 VT 金额 | 防止「高报酬 = 高期望」偏差 |

**实现方式**：

```
盲审视图生成算法：
  Input:  task_warrant_id
  Output: blinded_review_package

  1. 提取 deliverable 内容（文件/文本/链接）
  2. 提取 rubrics（评分维度 + 权重 + 1-5 分含义）
  3. 提取 task spec（需求描述）
  4. 提取评审窗口截止时间
  5. 剥离所有身份信息字段（ns_id, genesis_id, NR, VT）
  6. 生成一次性盲审 token（review_token）——评审者通过此 token 提交评分
  7. 返回 blinded_review_package

注意：review_token 是单向匿名凭证——协议层持有 token→评审者 的映射，
      但评审者无法从 token 反推被评审者身份。
      评审完成后，映射关系在聚合阶段才被解除。
```

**盲审的例外情况**：

PEER_SYNC（§0.3）同步评审模式不受盲审约束——同步面对面评审天然需要身份可见以便深度讨论。但 PEER_SYNC 的会后评分提交环节仍采用盲审标记：评审者在闭门独立评分时不再看到被评审者身份信息（已在会议中获知），评分界面仅展示评分维度。

**盲审与防串谋的协同**：

盲审（§1.4）与防串谋协议（§2.5）形成双层匿名保护：

| 层级 | 机制 | 匿名对象 | 防什么 |
|:---:|------|---------|--------|
| L0 | 盲审 | 被评审者身份 | 身份偏见、光环效应、策元政治 |
| L1-L5 | 防串谋协议 | 评审者之间的互惠关系 | 互惠串谋、交换好评 |

两层匿名正交运作：盲审确保评审者无法「看人打分」，防串谋确保评审者无法「互相关照」。

---

## 二、评审分配算法

### 2.1 算法目标

评审分配需同时满足：

1. **随机化**：评审者不可预测——防止提前串通。
2. **无自评审**：任务令提交者及其同策元贡献者不可评审自己的产出。
3. **多样性约束**：n 位评审者应尽可能分布在不同的策元/社交子图中——防止内群体偏袒。
4. **专长匹配**：优先分配具有相关领域标签的评审者。

### 2.2 正式算法

```
Algorithm AssignReviewers(task_id, n, strategy):
  Input:
    task_id        -- 任务令 ID
    n              -- 评审人数（默认 3）
    strategy       -- "default" | "diversity_priority" | "expertise_priority"

  Output:
    reviewers      -- 分配的评审者列表 [ns_id₁, ..., ns_idₙ]

  Step 1: 构建候选池
    excluded := {task.provider} ∪ task.contributors  -- 排除自评审
    pool := ReviewerPool(task.genesis_id) \ excluded

    if |pool| < n:
      pool := pool ∪ (GlobalReviewerPool \ excluded)
      // 全局池候选者需满足 expertise_match ≥ 0.3

    if |pool| < n:
      return ERROR: INSUFFICIENT_REVIEWERS

  Step 2: 分层采样 (Stratified Sampling)
    // 将候选池按策元归属分层
    strata := group_by_genesis(pool)

    selected := []
    used_strata := {}  -- 追踪已使用的策元

    for i in 1..n:
      // 优先从未使用的策元层中选取
      available_strata := strata \ used_strata

      if |available_strata| ≥ 1 and strategy != "expertise_priority":
        stratum := random_choice(available_strata)
      else:
        stratum := random_choice(strata)

      // 在选中层内按专长加权随机采样
      weights := [expertise_match(r, task) for r in stratum]
      weights := [w * NR_reliability(r) for w, r in zip(weights, stratum)]
      weights := normalize(weights)

      selected.append(weighted_random_choice(stratum, weights))
      used_strata.add(stratum_for(selected[-1]))

  Step 3: 反合谋随机扰动
    // 随机替换 1 位（若 n ≥ 04）——防止分配模式被预测
    if n ≥ 04 and random() < 0.15:
      swap_idx := random_int(0, n-1)
      alt_pool := pool \ selected
      if |alt_pool| ≥ 01:
        selected[swap_idx] := random_choice(alt_pool)

  Step 4: 记录分配
    for each r in selected:
      record_assignment(r, task_id, timestamp=now)
      r.active_review_count += 1

    return selected
```

### 2.3 分配约束

| 约束 | 默认值 | 说明 |
|------|:---:|------|
| 最小策元多样性 `min_strata` | `⌈n/2⌉` | 至少来自 ceil(n/2) 个不同策元 |
| 最大同策元评审者 `max_per_genesis` | `⌊n/2⌋` | 同一策元最多 floor(n/2) 位 |
| 评审冷却期 `cooldown_hours` | 4 | 同一评审者在 4 小时内不会再次被分配至同一策元的任务令 |
| 评审并发上限 `max_concurrent` | 5 | 单一评审者同时进行的评审不超过 5 个 |

### 2.4 防共谋机制总结

| 层级 | 机制 | 防什么 |
|:---:|------|--------|
| L1 | 随机化分配 + 分层采样 | 评审者无法选择被评审者——消除互惠对形成 |
| L2 | 多样性约束（不同策元） | 防止同一策元内部包庇 |
| L3 | 15% 概率随机替换（n≥4 时） | 使分配模式不可预测 |
| L4 | 事后审计（10% 概率第 n+1 人，见 §三） | 威慑合谋——惩罚期望成本超过收益 |
| L5 | NR_reliability 动态衰减（见 §七） | 长期合谋者权重自然下降 |

### 2.5 防串谋协议 v2.2（Anti-Collusion Protocol）

v2.2 在原有五层防共谋机制（§2.4）基础上，新增五重防护——匿名化、单向化、共识激励、延迟公布和评审信誉分——形成完整的防串谋纵深防御体系。

#### 2.5.1 匿名化（Anonymization）

评审时隐藏被评审者身份，与盲审设计（§1.4）协同：

```
评审者接收到的评审包仅包含：
  - 项目交付物内容
  - Rubric 维度与评分标准
  - 任务令 spec
  - 评审窗口截止时间
  - 一次性盲审 review_token

评审者无法获知：
  - 被评审者 ns_id
  - 被评审者 NR 值
  - 被评审者策元归属
  - 其他评审者身份（评审者之间也互不可见）
```

匿名化从根源上切断评审者基于身份形成互惠串谋的可能性——即使两名评审者私下约定互相打高分，他们也无法在执行评审时识别对方的交付物。

#### 2.5.2 单向化（Unidirectionality）

A 评 B 和 B 评 A 必须完全独立进行——系统在分配层面切断互惠对：

```
单向化约束：
  1. 若 ns_A 被分配评审 ns_B 的任务令，
     则 ns_B 在 ns_A 的任务令的同一评审批次中不被分配为评审者。
  2. 若 ns_A 和 ns_B 在最近 30 天内互为评审者，
     则系统强制执行 60 天冷却期——此期间两者不再互为评审者。
  3. 评审分配算法（§二.2）的分层采样天然降低同一对
     互评的概率至 ~1/(|pool|²)。
```

单向化与匿名化协同：即使评审者 A 事后通过「推理」猜测某交付物来自 B，也无法通过「我也给 B 高分」来建立互惠——因为 B 在同一批次中不评审 A。

#### 2.5.3 共识激励（Consensus Incentive）

评审者的 NR 奖励与其评分与共识的偏离程度挂钩——激励评审者做出独立但诚实的判断：

```
共识激励规则：
  1. 评审结果与多数人一致（|score(r) - score_consensus| ≤ 1.0）
     → 评审者获得完整 NR 奖励（§七.3.1）
  2. 评审结果偏离中位数 > 2 分（|score(r) - score_median| > 2.0）
     → 本次评审不获得 NR 奖励（基础评审奖励归零）
     → 若连续 3 次偏离 > 2 分 → 触发异常评审者标记（§七.4）
  3. 评审结果偏离中位数 ≤ 2 分但 > 1 分
     → NR 奖励按比例缩减：reward = reward_base × (2 - deviation) / 1.0
```

**博弈论分析**：共识激励利用了「谢林点 (Schelling Point)」原理——在无法沟通的情况下，诚实的独立判断是每个评审者的最优策略。偏离共识的评审者不仅损失直接 NR 奖励，其 NR_reliability 也会因低 agreement_score（§七.2）而下降——形成双重惩罚。这确保「跟随多数」和「故意偏离」都是次优策略。

#### 2.5.4 延迟公布（Delayed Publication）

评审结果在全部 n 位评审者提交后才统一公布——防止「先行者影响后行者」：

```
延迟公布规则：
  1. 评审窗口（§三.5）内，评审者提交的评分仅协议层可见。
  2. 任何评审者无法查看其他评审者已提交的评分。
  3. 当且仅当 n 位评审者全部提交后（或窗口关闭后），
     聚合结果一次性公布给所有评审者和被评审者。
  4. 聚合公布同时触发 NR 奖励结算（§七.3.1）。
```

延迟公布消除了「信息瀑布 (Information Cascade)」——第一个提交的评审者的评分不会影响后续评审者的判断。结合盲审和匿名化，每位评审者在提交时拥有的信息完全对称：仅知道自己的专业判断和 rubrics。

#### 2.5.5 评审信誉分（Reviewer Reputation Score）

在现有 NR_reliability（§七）基础上，v2.2 引入更细粒度的评审信誉分 (RRS)：

```
RRS(r) = w_agreement × avg_agreement_score(r)
       + w_consistency × consistency_score(r)
       + w_longevity × longevity_factor(r)
       + w_audit × audit_confirmation_rate(r)

其中：
  avg_agreement_score(r)    : 历史 agreement_score 的 EWMA（α=0.05）
  consistency_score(r)      : 1 - σ(scores(r)) / 5.0 —— 评分标准一致性
  longevity_factor(r)       : min(1, review_count(r) / 20) —— 经验因子
  audit_confirmation_rate(r): 审计确认次数 / 总被审计次数

默认权重：w_agreement=0.40, w_consistency=0.25, w_longevity=0.15, w_audit=0.20
```

**RRS 在聚合中的使用**：

```
评审者权重 v2.2 = weight(r) × RRS(r)

其中 weight(r) 为原 §四.2 定义的权重（NR_reliability × recency × expertise）。
RRS 作为附加乘数——历史准确率高的评审者在评分聚合中拥有更大权重。
```

**RRS 的博弈意义**：RRS 为评审者创造了「信誉资产」——准确评审积累的 RRS 直接转化为更高的聚合权重和更多的 NR 奖励。这使「长期诚实」成为占优策略：每次不诚实的评审不仅损失当次奖励，还损害已积累的信誉资产。

#### 2.5.6 n≥3 强制要求

v2.2 明确并强化评审人数的下限约束：

| 规则 | v1.x | v2.2 |
|------|:---:|:---:|
| 默认评审人数 `n_default` | 3 | 3（不变） |
| 最小评审人数 `n_min` | 未明确 | **≥ 3（强制）** |
| n=1 评审 | 未禁止 | **禁止——任何场景下不允许 n=1** |
| n=2 评审 | 未禁止 | **禁止——两两互评的串谋风险过高** |
| 策元自定义 n | 允许 | **允许——但必须 n ≥ 3** |
| 争议升级 n | 5 | 5（不变，≥3） |

**n≥3 的数学理由**：

- n=1：单评审误差率 ~30%，无法检测偏见或串谋。O(1/√n) 收敛性不适用（n<3 时评审噪声不收敛）。
- n=2：评审者 A 和 B 可以形成完美的互惠对——A 永远给 B 高分，B 永远给 A 高分。系统无法区分「两人都优秀」和「两人串谋」。
- n=3：O(1/√n) 开始收敛。即使 2 人串谋，第 3 人的独立评分提供基准线。多数规则（2/3）具有博弈稳定性。

**n 的可选扩展**：策元可通过 PCP 声明将默认 n 提升至 > 3（如 n=5 或 n=7），但不得降低至 < 3。n 值越大，聚合精度越高（O(1/√n)），但协调成本也越高。建议：

| n | 适用场景 | 聚合精度 (vs n=3) |
|:---:|---------|:---:|
| 3 | 常规评审——默认 | 基准 (~17% 聚合误差) |
| 5 | 高利害评审、PEER(5) 争议升级 | 提升 29% (~13% 聚合误差) |
| 7 | 策元全体评审（可选替代简单多数） | 提升 40% (~11% 聚合误差) |

---

## 三、评分规范

### 3.1 评分维度

每位评审者对交付物在 4 个维度上打分：

| 维度 | 分值范围 | 权重 w_dim | 说明 |
|------|:---:|:---:|------|
| **完成度 (Completeness)** | 1-5 | 0.25 | 是否完整覆盖任务令 spec |
| **质量 (Quality)** | 1-5 | 0.40 | 产出的技术/创意水平 |
| **接口合规 (Interface Compliance)** | 1-5 | 0.20 | 是否满足输入/输出接口约定 |
| **时效性 (Timeliness)** | 1-5 | 0.15 | 是否在约定时间窗内交付 |

每个维度评分含义：

| 分值 | 含义 |
|:---:|------|
| 1 | 严重缺陷——不可接受 |
| 2 | 显著缺陷——需重大修改 |
| 3 | 可接受——满足基本要求 |
| 4 | 良好——超出基本要求的稳定产出 |
| 5 | 卓越——超预期的杰出产出 |

### 3.2 综合评分

评审者 r 对任务令的综合评分：

```
score(r) = Σ(dim ∈ {completeness, quality, compliance, timeliness})
           score(r, dim) × w_dim
```

范围：[1.0, 5.0]

### 3.3 通过/不通过判定（二值化）

```
pass(r) := score(r) ≥ 3.0
```

即每个评审者可独立给出 pass/fail 判定。

### 3.4 评分提交规范（原 §三.4 保留——见下方 §3.5）

### 3.5 评审窗口机制（v2.2 新增）

v2.2 引入结构化的评审窗口机制，确保评审流程的时间纪律和公平性。

#### 3.5.1 窗口定义

```
评审窗口生命周期：
  T₀ (任务令进入 REVIEWING 状态):
    → 评审者分配完成，评审窗口开启

  T₀ + 0h:
    → 评审者收到盲审评审包（§1.4）
    → 48 小时倒计时开始

  T₀ + 24h:
    → 系统向未提交的评审者发送提醒通知

  T₀ + 48h:
    → 评审窗口关闭（deadline）
    → 未提交的评审者标记为超时
```

| 参数 | 默认值 | 说明 | 可调性 |
|------|:---:|------|:---:|
| `review_window_hours` | 48 | 标准评审窗口长度 | 策元 PCP 可自定义（≥24h, ≤168h） |
| `reminder_at_hours` | 24 | 发送提醒的时间点 | 固定 |
| `grace_period_hours` | 0 | v2.2 无宽限期——超时即标记 | 协议治理可调 |

#### 3.5.2 窗口收集模式（Window Collection Mode）

所有评审者在评审窗口内**并行提交，互不可见**：

```
窗口收集模式规则：
  1. 评审窗口开启后，所有 n 位评审者同时获得评审包。
  2. 评审者独立进行评审——无法查看其他评审者的提交状态或评分。
  3. 每位评审者可在窗口内任意时间提交——提交后不可修改。
  4. 提交的评分暂存在协议层——不向任何评审者展示。
  5. 窗口关闭后（或全部 n 位提交后），一次性聚合并公布。
```

此模式与延迟公布（§2.5.4）协同——窗口收集是延迟公布的时间维度实现。

#### 3.5.3 超时处理

```
超时处理分级：

Level 1 — 提醒（T₀ + 24h 未提交）:
  → 系统发送提醒通知
  → 不影响 NR_reliability
  → 不影响评审者权重

Level 2 — 超时标记（T₀ + 48h 未提交）:
  → 标记为 REVIEW_TIMEOUT
  → NR_reliability -= 0.05（轻度扣减）
  → 本次评审不获得 NR 奖励
  → 降权：本次及未来 3 次评审的 weight(r) 乘以 0.7

Level 3 — 严重超时（T₀ + 168h 未提交）:
  → 标记为 REVIEW_ABANDONED
  → NR_reliability -= 0.1
  → 禁止评审 30 天
  → 触发替代评审者分配（从候选池中选取第 n+1 位替补）
```

#### 3.5.4 超时对聚合的影响

```
若窗口关闭时仅有 m < n 位评审者提交：
  1. 仅使用 m 位已提交评审者的评分进行聚合。
  2. 未提交的 (n-m) 位评审者按 §3.5.3 处理。
  3. 聚合置信度额外惩罚：
     confidence_penalty = 0.1 × (n - m) / n
     // 每缺失一位评审者，置信度降低 10% × 1/n
  4. 若 m < 2（即仅 0 或 1 位评审者提交）：
     → 聚合终止——本次 PEER 评审失效
     → 任务令回退至 BROADCAST 状态
     → 所有未提交评审者触发 Level 3 严重超时惩罚
```

#### 3.5.5 窗口扩展

在以下情况下，评审窗口可按需扩展：

| 扩展场景 | 额外时间 | 触发条件 |
|---------|:---:|------|
| 交付物复杂度高 | +24h | 任务令 HJI ≥ 0.8 或 deliverable 超过 10,000 行代码 |
| 评审者请求扩展 | +12h | 评审者在 T₀+36h 前主动申请（仅限 1 次） |
| PEER_SYNC 模式 | +24h (会后) | 同步评审的会后评分提交窗口从 24h 扩展至 48h |

窗口扩展不会自动免除超时惩罚——它仅移动 deadline。

---

## 四、聚合公式

### 4.1 加权平均聚合

n 位评审者的评分聚合为最终裁决：

```
score_aggregated = Σ(r ∈ reviewers) score(r) × weight(r) / Σ weight(r)
```

其中 `weight(r)` 是评审者 r 的综合权重（见 §四.2）。

### 4.2 评审者权重计算

```
weight(r) = NR_reliability(r) × recency_factor(r) × expertise_factor(r, task)
```

| 因子 | 公式 | 说明 |
|------|------|------|
| `NR_reliability(r)` | ∈ [0, 1] | 评审者可靠性评分（见 §七）。新评审者默认 0.5。 |
| `recency_factor(r)` | `min(1.0, days_since_last_review / 30)` | 近期活跃评审权重提升——避免权重集中在不活跃的老评审者 |
| `expertise_factor(r, task)` | `0.5 + 0.5 × expertise_match` | 专长匹配因子。[0.5, 1.0]——即使无专长标签也有基线权重 |

### 4.3 最终裁决

```
verdict := {
    score: score_aggregated,
    pass: score_aggregated ≥ θ_pass,
    confidence: confidence_score(reviewers),
    breakdown: [ (r, score(r), weight(r), pass(r)) for r in reviewers ]
}
```

| 参数 | 默认值 | 说明 |
|------|:---:|------|
| `θ_pass` | 3.0 | 通过阈值——对应「可接受」 |
| `θ_strong_pass` | 4.0 | 强通过——免审计 |
| `θ_weak_fail` | 2.0 | 强失败——无需争议直接驳回 |

### 4.4 置信度评估

```
confidence_score(reviewers) = 1 - σ(scores) / μ(scores)
```

其中 σ 为评分标准差，μ 为均值。当评审者之间分歧较大时（σ/μ > 0.3），置信度 < 0.7——自动触发审计（见 §五）。

低置信度条件（任一满足即触发审计）：
- `confidence_score < 0.7`
- `max(score(r)) - min(score(r)) > 2.0` ——评审者之间最大分歧超过 2 分
- `|pass_count - fail_count| ≤ 1` ——通过/不通过接近平局（n=3 时出现 2:1）

---

## 五、审计机制

### 5.1 审计触发条件

| 触发条件 | 概率 | 说明 |
|----------|:---:|------|
| 例行随机审计 | 10% | 每 10 个 PEER 任务令随机触发 1 个——独立于评审结果（模型三 §2.2） |
| 低置信度触发 | 100% | 置信度 < 0.7 时自动触发（§四.4） |
| 异常模式触发 | 100% | FRAUDAR 检测到评审者子图异常稠密（模型三 §6.1 L5） |

### 5.2 审计者选取

审计者为第 `n+1` 位评审者，选取标准严格于常规评审者：

```
auditor_pool := {
    ns ∈ GlobalReviewerPool |
        NR_reliability(ns) ≥ 0.8          -- 高可靠性
        ∧ ns 在最近 30 天完成 ≥ 05 次评审   -- 经验丰富
        ∧ ns ∉ reviewers(task)            -- 非原评审者
        ∧ ns.genesis_id ∉ genesis_ids(reviewers)  -- 非原评审者同策元
}
```

审计者分配同样遵循分层采样算法（§二.2），但 `expertise_match` 阈值提升至 0.5。

### 5.3 审计判定

审计者独立评分，并与原评审聚合结果比较：

```
deviation := |score(auditor) - score_aggregated|

if deviation ≤ 1.0:
    audit_result := "CONFIRMED"    -- 审计确认原裁决
elif deviation ≤ 2.0:
    audit_result := "ADJUSTED"     -- 审计评分替代原聚合
    score_final := score(auditor)
else:
    audit_result := "FLAGGED"      -- 严重偏离——触发合谋调查
    trigger_collusion_investigation(task_id)
```

审计结果为 `ADJUSTED` 时，审计者评分替代原 `score_aggregated` 作为最终裁决。

---

## 六、争议与升级流程

### 6.1 争议发起

任务令提供方或被评审方可在裁决发布后发起争议：

**争议资格**：
- 争议者必须是任务令的 provider 或 acceptor
- 争议必须在裁决发布后 72 小时内发起
- 争议者需质押 `S_dispute = 5 VT`（防止滥诉——若争议成功则全额退还，若失败则燃烧 50%）

### 6.2 争议升级路径

```
PEER(3) 初始评审
    │
    ├── 无争议或争议被驳回 ──→ 裁决生效。NR 更新。
    │
    └── 争议被受理 ──→ PEER(5) 升级评审
                          │
                          ├── 裁决确认 ──→ 裁决生效。争议者质押燃烧 50%。
                          │
                          └── 裁决翻转 ──→ 新裁决替代。原评审者 NR_reliability 扣减。
                                            争议者质押全额退还。
                                            若原评审被判定为合谋 → 触发 §八惩罚。
```

### 6.3 PEER(5) 升级评审

PEER(5) 与 PEER(3) 的关键差异：

| 维度 | PEER(3) | PEER(5) |
|------|---------|---------|
| 评审人数 | 3 | 5 |
| 评审者资质 | NR ≥ 50, NR_reliability ≥ 0.3 | NR ≥ 100, NR_reliability ≥ 0.6 |
| 最小策元多样性 | 2 | 3 |
| 审计概率 | 10% | 25% |
| 时间窗 | 48 小时 | 72 小时 |
| 聚合方式 | 加权平均（§四.1） | 加权中位数（更稳健） |

PEER(5) 使用**加权中位数**替代加权平均——在更高风险场景下对极端评分更稳健：

```
score_final = weighted_median( { (score(r), weight(r)) | r ∈ reviewers_5 } )
```

### 6.4 策元全体评审（终极升级）

若 PEER(5) 裁决仍被争议（需策元 ≥50% 成员联名），触发策元全体评审：

```
全体评审者 := members(genesis_id) \ excluded
裁决方式 := 简单多数  + 策元核确认
```

策元全体评审的裁决为**终局裁决** (final and binding)。此路径预期极少触发——仅用于根本性分歧。

### 6.5 争议状态机

```
                    ┌──────────┐
                    │ VERDICT  │  PEER(n) 聚合完成
                    └────┬─────┘
                         │
                    ┌────▼─────┐
                    │  ACTIVE  │  72h 争议窗口
                    └────┬─────┘
                         │
              ┌──────────┼──────────┐
              │          │          │
         (无争议)   (争议发起)   (超时)
              │          │          │
         ┌────▼───┐ ┌───▼────┐ ┌───▼────┐
         │ FINAL  │ │DISPUTED│ │ FINAL  │
         └────────┘ └───┬────┘ └────────┘
                        │
                   ┌────▼─────┐
                   │ ESCALATED│  PEER(5) 升级
                   └────┬─────┘
                        │
              ┌─────────┼─────────┐
              │         │         │
         (确认裁决) (翻转裁决) (再次争议+≥50%)
              │         │         │
         ┌────▼───┐ ┌──▼───┐ ┌──▼──────────┐
         │ FINAL  │ │FINAL │ │FULL_GENESIS │
         └────────┘ └──────┘ └──────┬──────┘
                                    │
                               ┌────▼───┐
                               │ FINAL  │  终局裁决
                               └────────┘
```

---

## 七、评审者质量追踪与激励

### 7.1 NR_reliability 维度

NR 是六维向量（模型三 §4.2），其中 `NR_reliability` 是评审者质量追踪的核心维度：

```
NR = (s_AUTO, s_PEER, s_MARKET, s_seed, h, reliability)
```

`NR_reliability ∈ [0, 1]`，初始值 0.5（中性先验）。

### 7.2 可靠性更新公式

每次评审完成后，评审者 r 的 `NR_reliability` 按以下规则更新：

```
NR_reliability(r) ← NR_reliability(r) + Δ

Δ = α_learn × (agreement_score(r) - NR_reliability(r))

agreement_score(r) = 1 - |score(r) - score_consensus| / 4.0
```

| 参数 | 默认值 | 说明 |
|------|:---:|------|
| `α_learn` | 0.05 | 学习率。每次评审更新 5%——平衡快速学习和抗噪声。 |
| `score_consensus` | 见下 | 排除 r 后的聚合评分（留一法） |

`score_consensus` 使用留一法计算：

```
score_consensus = Σ(j ∈ reviewers \ {r}) score(j) × weight(j) / Σ weight(j)
```

这确保评审者不能通过「跟随多数」来游戏系统——它的评分不参与共识计算。

### 7.3 评审者激励

#### 7.3.1 正向激励（NR 奖励）

| 条件 | 奖励 | 说明 |
|------|:---:|------|
| 按时提交评审（≤ 48h） | `+0.5 × HJI(task)` NR | 基础评审奖励 |
| agreement_score ≥ 0.75 | `+0.3 × HJI(task)` NR | 准确评审附加奖励 |
| 评审被审计确认 (CONFIRMED) | `+0.2 × HJI(task)` NR | 审计验证奖励 |
| 评审在争议中被维持 | `+1.0 × HJI(task)` NR | 争议维持——高信号奖励 |

HJI 加权确保评审高判断力任务令获得更高激励（模型三 §2.3）。

#### 7.3.2 负向惩罚

| 条件 | 惩罚 | 说明 |
|------|------|------|
| 超时未提交（> 72h） | `NR_reliability -= 0.1`，本次评审无奖励 | 轻度违约 |
| 超时未提交（> 168h） | `NR_reliability -= 0.2`，禁止评审 30 天 | 严重违约——视为放弃评审资格 |
| 被审计标记为 FLAGGED | `NR_reliability -= 0.15`，触发调查 | 偏离审计者评分过多 |
| 争议翻转——评审被判定为错误 | `NR_reliability -= 0.2` | 升级评审推翻原评分 |
| 持续异常（连续 5 次 agreement_score < 0.5） | `NR_reliability -= 0.3`，标记「异常评审者」 | 系统性异常——可能是能力不足或恶意 |
| 确认合谋 | `NR_reliability = 0.1`，NR 总量扣减 50%，禁止评审 180 天 | 合谋惩罚（模型三 §2.2） |

### 7.4 异常评审者标记

系统自动标记异常评审者当：

```
is_outlier(r) := 
    (连续 5 次 agreement_score < 0.5)
    ∨ (连续 3 次评审超时 > 72h)
    ∨ (NR_reliability < 0.3 持续 30 天)
```

被标记为异常评审者的智权体：
- 不被分配新的 PEER 评审任务
- 已有的低可靠性评分在已有聚合中被降权至 0.1
- 需完成 3 个 HJI ≥ 0.5 的 PEER 任务令（作为被评审方）且 agreement_score ≥ 0.7 后方可申请恢复

### 7.5 权重冷启动

新评审者（评审次数 < 5）使用贝叶斯收缩估计：

```
NR_reliability_effective = (n_reviews × NR_reliability_observed + 5 × 0.5) / (n_reviews + 5)
```

这确保新评审者的权重向中性先验（0.5）收缩，避免小样本极端值主导聚合。

---

## 八、合谋调查与惩罚

### 8.1 调查触发条件

合谋调查在以下条件触发：

1. **审计 FLAGGED**：审计者评分与原聚合偏差 > 2.0（§五.3）
2. **FRAUDAR 检测**：评审者子图密度超过全局中位数 3σ（模型三 §6.1 L5）
3. **异常投票模式**：连续 ≥ 3 次评审中出现完全相同的评分模式（同一组评审者对同一类任务令）
4. **争议翻转**：PEER(5) 翻转 PEER(3) 裁决且发现评分模式异常

### 8.2 调查流程

```
1. 冻结相关评审者权限（暂停接受新评审分配）
2. 策元核 + 独立仲裁者（来自 ≥ 3 个不同策元的 NR_reliability ≥ 0.8 的评审者）
   审视评审记录、评分分布、历史 agreement_score
3. 判定：
   a. 无合谋 → 解冻，记录误报
   b. 确认合谋 → 执行 §八.3 惩罚
   c. 证据不足但有异常 → 标记观察期 60 天，此期间 NR_reliability 上限 0.5
```

### 8.3 合谋惩罚

确认合谋后：

| 惩罚项 | 程度 | 持续时间 |
|--------|:---:|:---:|
| NR 总量扣减 | 50% | 立即执行 |
| NR_reliability 重置 | 0.1 | — |
| 禁止参与 PEER 评审 | — | 180 天 |
| 禁止成为策元核成员 | — | 365 天 |
| 历史评审权重回溯降权 | 权重降至 0.1 | 追溯 90 天内所有评审 |

---

## 九、API 端点

### 9.1 POST /peer-review/assign

分配评审者。

```
POST /peer-review/assign
  Request:
    {
      "task_warrant_id": "tw_a1b2c3d4",
      "n": 3,                              // 评审人数，默认 3
      "strategy": "diversity_priority",     // "default" | "diversity_priority" | "expertise_priority"
      "review_window_hours": 48             // 评审提交窗口，默认 48
    }

  Response (200):
    {
      "peer_review_id": "pr_x9y8z7w6",
      "task_warrant_id": "tw_a1b2c3d4",
      "n": 3,
      "reviewers": [
        {
          "ns_id": "ns_0a1b2c3d",
          "genesis_id": "gu_alpha",
          "expertise_match": 0.80,
          "nr_reliability": 0.72,
          "assigned_at": "2026-05-14T22:00:00Z"
        },
        {
          "ns_id": "ns_4d5e6f7g",
          "genesis_id": "gu_beta",
          "expertise_match": 0.65,
          "nr_reliability": 0.58,
          "assigned_at": "2026-05-14T22:00:00Z"
        },
        {
          "ns_id": "ns_8h9i0j1k",
          "genesis_id": "gu_gamma",
          "expertise_match": 0.90,
          "nr_reliability": 0.85,
          "assigned_at": "2026-05-14T22:00:00Z"
        }
      ],
      "strata_diversity": 3,                // 实际覆盖的策元数
      "audit_probability": 0.10,            // 本次分配关联的审计概率
      "review_deadline": "2026-05-16T22:00:00Z",
      "status": "awaiting_reviews"
    }

  Errors:
    400 INSUFFICIENT_REVIEWERS  -- 候选池不足 n 人
    400 TASK_NOT_IN_BROADCAST   -- 任务令不在 BROADCAST 状态
    409 ALREADY_ASSIGNED        -- 该任务令已有活跃的 PEER 评审
```

### 9.2 POST /peer-review/submit

提交评审评分。

```
POST /peer-review/submit
  Request:
    {
      "peer_review_id": "pr_x9y8z7w6",
      "reviewer_ns_id": "ns_0a1b2c3d",
      "scores": {
        "completeness": 4,
        "quality": 3,
        "interface_compliance": 5,
        "timeliness": 4
      },
      "pass": true,
      "comments_hash": "sha256:...",       // 可选——评审意见的哈希
      "time_spent_minutes": 35              // 可选——评审耗时（用于元分析）
    }

  Response (200):
    {
      "submission_id": "ps_12345678",
      "peer_review_id": "pr_x9y8z7w6",
      "reviewer_ns_id": "ns_0a1b2c3d",
      "composite_score": 3.75,              // = Σ score_dim × w_dim
      "submitted_at": "2026-05-15T10:30:00Z",
      "on_time": true,
      "reviews_received": 1,
      "reviews_remaining": 2
    }

  // 当第 n 份评审提交后，自动触发聚合：
  Response (200, all_reviews_complete):
    {
      "submission_id": "ps_87654321",
      "peer_review_id": "pr_x9y8z7w6",
      "verdict": {
        "score_aggregated": 3.58,
        "pass": true,
        "confidence": 0.82,
        "breakdown": [
          { "ns_id": "ns_0a1b2c3d", "score": 3.75, "weight": 0.62, "pass": true },
          { "ns_id": "ns_4d5e6f7g", "score": 3.25, "weight": 0.50, "pass": true },
          { "ns_id": "ns_8h9i0j1k", "score": 3.80, "weight": 0.74, "pass": true }
        ],
        "consensus_quality": "strong",       // "strong" | "moderate" | "weak" | "split"
        "audit_triggered": false,
        "dispute_window_until": "2026-05-18T22:00:00Z"
      },
      "status": "verdict_pending"            // 等待 72h 争议窗口
    }

  Errors:
    400 REVIEWER_NOT_ASSIGNED     -- 该评审者未被分配至此评审
    400 REVIEW_ALREADY_SUBMITTED  -- 该评审者已提交
    409 REVIEW_WINDOW_EXPIRED     -- 超出 48h 提交窗口
    422 INVALID_SCORES            -- 评分值超出范围
```

### 9.3 GET /peer-review/verdict/{task_id}

查询裁决状态和详情。

```
GET /peer-review/verdict/{task_warrant_id}
  // 也支持 peer_review_id: GET /peer-review/verdict/{peer_review_id}

  Response (200, 裁决已生效):
    {
      "peer_review_id": "pr_x9y8z7w6",
      "task_warrant_id": "tw_a1b2c3d4",
      "status": "final",                    // "awaiting_reviews" | "verdict_pending" | "disputed" | "escalated" | "final"
      "verdict": {
        "score_aggregated": 3.58,
        "pass": true,
        "confidence": 0.82,
        "breakdown": [ ... ]
      },
      "audit": {
        "triggered": true,
        "auditor_ns_id": "ns_audit_01",
        "auditor_score": 3.65,
        "deviation": 0.07,
        "result": "CONFIRMED"
      },
      "dispute": null,                      // 无争议
      "timeline": {
        "assigned_at": "2026-05-14T22:00:00Z",
        "last_review_submitted_at": "2026-05-15T14:20:00Z",
        "verdict_generated_at": "2026-05-15T14:20:01Z",
        "dispute_window_closed_at": "2026-05-18T14:20:01Z",
        "finalized_at": "2026-05-18T14:20:01Z"
      },
      "nr_updates": {
        "provider_nr_delta": "+2.1",
        "reviewer_nr_deltas": {
          "ns_0a1b2c3d": "+0.8",
          "ns_4d5e6f7g": "+0.5",
          "ns_8h9i0j1k": "+1.0"
        }
      }
    }

  Response (200, 争议中):
    {
      "peer_review_id": "pr_x9y8z7w6",
      "status": "disputed",
      "verdict": { ... },
      "dispute": {
        "dispute_id": "disp_001122",
        "disputer_ns_id": "ns_provider",
        "dispute_reason": "reviewer_bias",
        "dispute_details_hash": "sha256:...",
        "filed_at": "2026-05-16T08:00:00Z",
        "stake_vt": 5.0,
        "escalation_level": "peer_5",
        "escalation_status": "assigning_reviewers"
      }
    }

  Errors:
    404 REVIEW_NOT_FOUND  -- 无对应评审记录
```

### 9.4 POST /peer-review/dispute

发起争议。

```
POST /peer-review/dispute
  Request:
    {
      "peer_review_id": "pr_x9y8z7w6",
      "disputer_ns_id": "ns_provider_01",
      "dispute_reason": "reviewer_bias",    // "verification_error" | "reviewer_bias" | "procedural_error" | "collusion_suspected"
      "dispute_details_hash": "sha256:...", // 争议详情的哈希
      "stake_vt": 5.0,                      // 质押 VT 金额
      "request_escalation": "peer_5"        // "peer_5" | "full_genesis"
    }

  Response (200):
    {
      "dispute_id": "disp_001122",
      "peer_review_id": "pr_x9y8z7w6",
      "status": "filed",
      "stake_vt_locked": 5.0,
      "escalation_level": "peer_5",
      "escalation_peer_review_id": "pr_escalated_01",
      "dispute_window_extended_until": "2026-05-21T22:00:00Z",
      "next_steps": [
        "5 位高资质评审者正在分配中",
        "评审窗口 72 小时",
        "若争议成功——质押全额退还；若失败——50% 燃烧"
      ]
    }

  Response (200, 争议已裁决):
    {
      "dispute_id": "disp_001122",
      "status": "resolved",
      "resolution": "verdict_upheld",       // "verdict_upheld" | "verdict_overturned" | "settled"
      "final_verdict": {
        "score_aggregated": 3.62,
        "pass": true,
        "reviewer_count": 5,
        "aggregation_method": "weighted_median"
      },
      "stake_result": "partial_burn",       // "full_return" | "partial_burn" | "full_burn"
      "stake_returned_vt": 2.5,
      "nr_penalties_applied": [
        { "ns_id": "ns_0a1b2c3d", "nr_reliability_delta": -0.15, "reason": "score_deviation" }
      ]
    }

  Errors:
    400 DISPUTE_WINDOW_CLOSED     -- 72h 争议窗口已关闭
    400 NOT_AUTHORIZED_DISPUTER   -- 非 provider 或 acceptor
    400 INSUFFICIENT_STAKE        -- 质押金额不足
    409 DISPUTE_ALREADY_ACTIVE    -- 该评审已有活跃争议
    422 FULL_GENESIS_ESCALATION_REQUIRES_QUORUM  -- 策元全体评审需 ≥50% 联名
```

### 9.5 GET /peer-review/reviewer/{ns_id}/stats

查询评审者历史统计。

```
GET /peer-review/reviewer/{ns_id}/stats

  Response (200):
    {
      "ns_id": "ns_0a1b2c3d",
      "nr_reliability": 0.72,
      "total_reviews_completed": 34,
      "total_reviews_assigned": 36,         // 含超时未完成的
      "on_time_rate": 0.94,                 // 按时提交率
      "avg_agreement_score": 0.78,
      "avg_review_time_hours": 12.5,
      "reviews_by_result": {
        "confirmed_by_audit": 3,
        "adjusted_by_audit": 1,
        "flagged_by_audit": 0,
        "upheld_in_dispute": 2,
        "overturned_in_dispute": 0
      },
      "recent_agreement_scores": [0.82, 0.75, 0.91, 0.68, 0.80],
      "expertise_tags": ["code_review", "architecture"],
      "active_penalties": [],
      "cooldown_until": null,
      "reviewer_tier": "trusted"            // "novice" | "standard" | "trusted" | "expert"
    }
```

### 9.6 补充端点

```
GET /peer-review/pool/{genesis_id}
  // 查询策元的本地评审者池状态
  Response: { "genesis_id": "gu_...", "eligible_reviewers": 7, "available_now": 5, ... }

GET /peer-review/active/{ns_id}
  // 查询某智权体当前进行中的评审
  Response: { "active_reviews": [...], "pending_count": 2, "max_concurrent": 5 }
```

---

## 十、协议状态机

```
┌──────────┐   assign()   ┌──────────────────┐
│  IDLE    │──────────────▶│ AWAITING_REVIEWS │
└──────────┘              └────────┬─────────┘
                                   │
                          (第 1..n-1 份提交)
                                   │
                          ┌────────▼─────────┐
                          │ AWAITING_REVIEWS │  (等待余下评审)
                          └────────┬─────────┘
                                   │
                          (第 n 份提交 → 自动聚合)
                                   │
                          ┌────────▼─────────┐
                          │ VERDICT_PENDING  │  72h 争议窗口
                          └──┬──────┬───────┬┘
                             │      │       │
                    (无争议) │ (争议)│  (超时)│
                             │      │       │
                    ┌────────▼─┐ ┌─▼──────┐ ┌▼──────┐
                    │  FINAL   │ │DISPUTED│ │ FINAL │
                    └──────────┘ └───┬────┘ └───────┘
                                     │
                              ┌──────▼──────┐
                              │  ESCALATED  │  PEER(5)
                              └──────┬──────┘
                                     │
                          ┌──────────┼──────────┐
                          │          │          │
                    (确认裁决) (翻转裁决) (再次争议+≥50%)
                          │          │          │
                    ┌─────▼──┐ ┌────▼───┐ ┌────▼─────────┐
                    │ FINAL  │ │ FINAL  │ │FULL_GENESIS  │
                    └────────┘ └────────┘ └──────┬───────┘
                                                 │
                                            ┌────▼───┐
                                            │ FINAL  │
                                            └────────┘
```

---

## 十一、参数汇总

| 参数 | 默认值 | 说明 | 可调性 |
|------|:---:|------|:---:|
| `n_default` | 3 | 默认评审人数 | 策元 PCP 可自定义 |
| `n_dispute` | 5 | 争议升级评审人数 | 固定 |
| `θ_pass` | 3.0 | 通过阈值 | 策元 PCP 可自定义 |
| `θ_strong_pass` | 4.0 | 强通过（免审计） | 固定 |
| `θ_weak_fail` | 2.0 | 强失败 | 固定 |
| `NR_min_reviewer` | 50 | 评审者最低 NR | 协议治理可调 |
| `review_window_hours` | 48 | 评审提交窗口 | 策元 PCP 可自定义 |
| `dispute_window_hours` | 72 | 争议发起窗口 | 固定 |
| `S_dispute` | 5 VT | 争议质押金额 | 协议治理可调 |
| `audit_probability` | 0.10 | 例行审计概率 | 固定 |
| `α_learn` | 0.05 | NR_reliability 学习率 | 固定 |
| `cooldown_hours` | 4 | 评审冷却期 | 固定 |
| `max_concurrent` | 5 | 评审并发上限 | 固定 |
| `confidence_threshold` | 0.7 | 低置信度触发审计 | 协议治理可调 |

---

## 十二、错误码汇总

| 错误码 | HTTP | 说明 |
|--------|:---:|------|
| `INSUFFICIENT_REVIEWERS` | 400 | 候选池不足 n 人 |
| `TASK_NOT_IN_BROADCAST` | 400 | 任务令不在可分配状态 |
| `ALREADY_ASSIGNED` | 409 | 该任务令已有活跃 PEER 评审 |
| `REVIEWER_NOT_ASSIGNED` | 400 | 评审者未被分配至此评审 |
| `REVIEW_ALREADY_SUBMITTED` | 400 | 该评审者已提交 |
| `REVIEW_WINDOW_EXPIRED` | 409 | 超出评审提交窗口 |
| `INVALID_SCORES` | 422 | 评分值超出 [1,5] 范围 |
| `REVIEW_NOT_FOUND` | 404 | 无对应评审记录 |
| `DISPUTE_WINDOW_CLOSED` | 400 | 72h 争议窗口已关闭 |
| `NOT_AUTHORIZED_DISPUTER` | 400 | 非 task provider 或 acceptor |
| `INSUFFICIENT_STAKE` | 400 | 争议质押金额不足 |
| `DISPUTE_ALREADY_ACTIVE` | 409 | 该评审已有活跃争议 |
| `FULL_GENESIS_ESCALATION_REQUIRES_QUORUM` | 422 | 策元全体评审需 ≥50% 联名 |

---

## 十三、与 CONC 框架的交叉引用

| 引用目标 | 文件 | 关系 |
|---------|------|------|
| 公理四 PEER(n) 定义 | `01_Core/02_Core_Axioms.md` L498-500 | 本协议是公理四 PEER(n) 的完整实现 |
| 公理四 O(1/√n) 收敛 | `01_Core/02_Core_Axioms.md` L498 | 本协议的聚合公式在此数学基础上构建 |
| 模型三 PEER(3)+审计 | `02_Models/03_NR_Signaling_v2.md` §2.2 | 本协议的审计机制直接继承模型三设计 |
| 模型三 NR_reliability | `02_Models/03_NR_Signaling_v2.md` §4.1 | 本协议 §七 定义 NR_reliability 的更新规则 |
| 模型三 HJI 加权 | `02_Models/03_NR_Signaling_v2.md` §2.3 | 本协议的评审激励使用 HJI 加权 |
| 模型三 合谋惩罚 | `02_Models/03_NR_Signaling_v2.md` L117-126 | 本协议 §八.3 继承并细化惩罚矩阵 |
| 协议层 §4.1 | `03_Protocols/01_Protocol_Layer.md` L262-298 | 本协议替换协议层 §4.1 的 PEER 骨架——提供完整规范 |
| 协议完备性审计 | `03_Protocols/03_Protocol_Completeness_Audit.md` L51 | 本协议将 PEER(n) 从 40% 提升至 85%+ |
| CONC 伦理章节 — philia | `01_Core/05_Ethics_Chapter.md` | PEER 协议的信任边界声明（§0.4）与 philia 概念一致：协议是人际信任的补充，不是替代 |

---

## 十四、已知局限与未来方向

1. **HJI 评分的元问题**：谁判定任务令的 HJI（人类判断不可替代性）？当前依赖策元核初始声明——可能被博弈。未来需独立的 HJI 校准协议。

2. **全局评审者池的冷启动**：在 CONC 网络初期（策元数 < 10），全局评审者池可能不足。建议初期放宽 NR_min_reviewer 至 25 并允许跨策元自由分配。

3. **NR_reliability 的长期漂移**：如果评审者群体整体质量下降（如大量高可靠性评审者退出），`NR_reliability` 的绝对数值可能发生均值漂移。需要周期性重新校准基线。

4. **隐私权衡**：评审分配暴露了评审者的策元归属和专长标签。未来可引入零知识证明实现「盲分配」——评审者不知道自己被分配到哪个策元，策元也不知道评审者的身份——仅协议层知晓。

5. **评分维度的领域适配**：当前四维度（完成度/质量/接口合规/时效性）是通用设计。特定领域（如医疗 AI 审计、法律文书评审）可能需要定制维度。

6. **协议与人际信任的边界（INFERNO-014）**：PEER 协议无法覆盖设计美学、代码优雅、创意方向等隐性维度——这些属于人际信任的领域（见 §0.4）。Ostrom (1990) 的研究表明面对面沟通和社区规范促进合作的效果优于任何制度设计。PEER_SYNC（§0.3）是朝这个方向的第一步，但协议与信任之间的关系仍需持续审视和完善。

---

## 版本记录

| 版本 | 日期 | 变更 |
|------|------|------|
| v1.0 | 2026-05-14 | 初始完整规范。覆盖评审分配算法、加权聚合公式、NR_reliability 追踪、争议升级流程（PEER(3)→PEER(5)→策元全体）、6 个 API 端点、12 个错误码。 |
| v1.1 | 2026-05-15 | 新增 §0.3 PEER_SYNC 同步评审模式 + §0.4 信任边界声明。回应 INFERNO-014 审计发现：PEER 协议是人际信任的补充而非替代——协议处理可验证维度，人际信任（Ostrom 面对面沟通 + CONC 伦理 philia 概念）处理隐性维度。 |
| v2.2 | 2026-05-27 | **安全改进版本**。新增 §1.4 盲审设计（评审者不可见被评审者身份/NR/策元归属）；§2.5 防串谋协议 v2.2（匿名化+单向化+共识激励+延迟公布+评审信誉分 RRS+n≥3 强制要求+n 可选扩展至 ≥3）；§3.5 评审窗口机制（48h 窗口+窗口收集模式+超时三级处理+窗口扩展规则）。更新协议标识符至 PEER.2.2。 |

---

*Hermes Agent — 架构师与逻辑编译器*
*PEER(n) Verification Protocol v2.2 — 公理四（模块承诺）的完整实现*
*依赖模型三（NR 信号博弈 ESS）的 O(1/√n) 收敛性证明与审计机制*
*v2.2 新增：盲审设计 (§1.4) + 防串谋协议 (§2.5) + 评审窗口机制 (§3.5)*


---

## v1.1 更新 (2026-07-10) — CONC-P1-5
- JC行业分类对PEER验证规则的影响：安全型行业PEER评审严格度上调，品味型行业PEER评审默认通过
- 同步σ_GU参数对验证阈值的影响

## v1.2 更新 (2026-07-12) — CONC-P2-1: JC 四分量对齐
- JC 评分体系从单一维度扩展为四分量（JC_macro/ JC_phro_runtime/ JC_continuous/ JC_design，定义见 `15_Direction_Profile_and_Judgment_Credit.md` v2.0）
- PEER 评审的 outcome 赋值现在区分 `jc_component` 字段（"macro" | "phro"）
- Gate 3 PEER+ 审计新增 `phronesis_profile` 对齐度检查项（MISCLASSIFIED 判定）
- PEER_SYNC 评审新增 `peer_sync_score` 输出（用于 JC_continuous 分量）
