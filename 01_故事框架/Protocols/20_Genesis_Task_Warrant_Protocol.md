# CONC 创世任务令协议规范
## Genesis Task Warrant Protocol Specification v1.0

> 协议标识符：`CONC-Protocol/Genesis_TaskWarrant.1.0`
> 归属层：协议栈第三层 — 策元层 (Genesis Layer)，跨层协作于第二层身份层 (Identity Layer) 与第五层验证层 (Verification Layer)
> 依赖协议：CSIP (智权体身份协议)、ICP (意图聚结协议)、PEER (同行验证协议)、CCR (公开账本协议)、NR 统一状态机 (NR-Protocol.1.0)、L-1 外部信任锚点映射协议
> 理论溯源：公理一（能证可组合性）、公理二a（被动型工作假设）、SBDEL 定理、本原零（自利与秩序恒常）
>
> **完备度声明**：本规范定义 CONC 协议栈创世任务令协议——将冷启动过程本身变成协议运转的实例。完整定义三阶段链式冷启动机制 (CP_BOOTSTRAP → NR_SEED_PROJECT → NR_SEED_MUTUAL)、自动触发逻辑 (幂等/女巫检查/错误降级)、渐进式信任建立 (四阶段)、防串谋协议 (匿名化+单向化+共识激励+延迟公布)、配对算法 (相似度优先+FIFO兜底)、NR 燃烧机制设计、任务令状态机转换矩阵。完备度 90%+。

---

## 〇、协议定位与设计概要

### 0.1 核心思想：冷启动即协议运转

传统的 DAO/网络协议面临的核心困境是「冷启动悖论」——协议需要网络效应才能有价值，但在没有价值之前无法吸引参与者形成网络效应。CONC 的解决思路是：**将冷启动过程本身变成协议运转的一个实例**。

创世任务令协议 (Genesis Task Warrant Protocol) 定义了从「一个空网络中的新注册智权体」到「一个可参与完整协作的成熟节点」的完整路径。这一路径不是「等待网络效应自然形成」，而是通过三阶段链式任务令，将冷启动转化为一套可验证、可审计、防串谋的协议化流程。

### 0.2 设计原则

1. **协议即启动**：冷启动不依赖外部协调或中心化调度，完全由协议规则驱动
2. **渐进式信任**：信任级别随网络规模和验证深度逐步提升，而非二元开关
3. **链式触发**：每个阶段完成后自动触发下一阶段，无需人工干预
4. **幂等安全**：所有自动触发操作必须幂等，防止重复创建或状态损坏
5. **女巫抵抗**：从第一阶段即嵌入多层女巫检测，防止虚假身份污染声誉网络
6. **防串谋设计**：互评阶段通过匿名化、单向化、共识激励、延迟公布四重机制防止串谋

### 0.3 在协议栈中的交叉位置

```
┌─────────────────────────────────────────────────────────┐
│  第七层：Phronesis Layer（决断层）                       │
├─────────────────────────────────────────────────────────┤
│  第六层：价值层 (Value Layer)                            │
│  NR 统一状态机 · CCR 公开账本 · VT 铸造                  │
├─────────────────────────────────────────────────────────┤
│  第五层：验证层 (Verification Layer)                     │
│  PEER(n) · AUTO · MARKET · 盲审机制                      │
├─────────────────────────────────────────────────────────┤
│  第四层：Collaboration Layer（协作层）                    │
├─────────────────────────────────────────────────────────┤
│  第三层：策元层 (Genesis Layer)  ← 本协议主体            │
│  任务令 DAG · 策元 CRUD · ★创世任务令· 弹性分叉          │
├─────────────────────────────────────────────────────────┤
│  第二层：身份层 (Identity Layer)  ← 跨层协作             │
│  智权体注册 · L-1 外部信任锚点 · 能证(CP)三层晋级        │
├─────────────────────────────────────────────────────────┤
│  第一层：网络层 (Network Layer)                           │
└─────────────────────────────────────────────────────────┘
```

创世任务令横跨策元层（任务令创建与管理）、身份层（L-1 映射与能证生成）和验证层（同行盲审），是 CONC 协议中最具跨层协作特征的协议实体。

### 0.4 理论溯源

| 理论来源 | 核心主张 | 在本协议中的体现 |
|----------|---------|-----------------|
| **公理一（能证可组合性）** | 信誉可由多种来源组合验证 | L-1 五维可组合子证明模型：代码/质量/社区/持续/多样性五维度组合计算初始能证 |
| **公理二a（被动型工作假设）** | 新进入者在缺乏内部信息时依赖外部信号进行初始判断 | CP_BOOTSTRAP：外部信任锚点 (GitHub等) 映射为内部能证信号 |
| **SBDEL 定理** | 信号→行为→检测→执行→学习闭环 | 三阶段链：CP_BOOTSTRAP(信号映射) → NR_SEED_PROJECT(行为提交) → NR_SEED_MUTUAL(检测验证) |
| **本原零（自利与秩序恒常）** | 理性参与者在充分信息下选择遵守协议 | 防串谋协议：作弊期望成本 (NR燃烧 + 声誉损失) > 作弊收益 |

---

## 一、三阶段链式冷启动机制

### 1.0 机制总览

```
新智权体注册
     │
     ▼
┌─────────────────────────────────────────────────┐
│  阶段一：CP_BOOTSTRAP（能证种子）                │
│  外部信任锚点映射 → 初始能证                     │
│  含 IVD 60秒能证名片                            │
│  验证：AUTO                                     │
│  过期：30天未完成 → DORMANT                      │
└──────────────┬──────────────────────────────────┘
               │ 完成
               ▼
┌─────────────────────────────────────────────────┐
│  阶段二：NR_SEED_PROJECT（声誉种子—项目评审）     │
│  代表性作品提交 → 动态 rubric 盲审               │
│  验证：PEER(n=3)，无网络时降级 AUTO×0.3          │
└──────────────┬──────────────────────────────────┘
               │ 完成
               ▼
┌─────────────────────────────────────────────────┐
│  阶段三：NR_SEED_MUTUAL（声誉种子—互评）          │
│  ≥5人网络下 n≥3 匿名单向评审                     │
│  验证：PEER(n≥3)，通过阈值 3.5                   │
│  包含防串谋协议完整机制                           │
└─────────────────────────────────────────────────┘
               │ 完成
               ▼
        ★ 创世任务令全部完成 ★
        获得完整初始声誉权重
        可参与完整网络协作
```

### 1.1 阶段一：CP_BOOTSTRAP（能证种子——外部信任锚点映射）

#### 1.1.1 协议标识

- **任务令类型**：`CP_BOOTSTRAP`
- **任务令标识格式**：`GTW-CP-{agent_id}-{timestamp}`
- **触发条件**：智权体注册完成后自动创建（幂等）
- **验证方式**：AUTO（全自动验证）
- **过期时间**：创建后 30 天未完成 → 标记 DORMANT

#### 1.1.2 女巫基础门槛

在创建 CP_BOOTSTRAP 任务令之前，系统自动执行女巫检查：

| 检查项 | 阈值 | 不满足时的处理 |
|--------|------|---------------|
| GitHub 账号年龄 | > 6 个月 | 拒绝创建，提示需满足最低账号年龄 |
| GitHub contributions | > 50 | 拒绝创建，提示需满足最低贡献量 |
| 邮箱验证 | 已验证 | 要求先完成邮箱验证 |
| 一次性邀请码（可选） | 有效 | 如启用邀请制，需有效邀请码 |

```pseudocode
function sybilCheck(newUser):
    if newUser.github_account_age_months <= 6:
        return REJECT("GitHub账号需>6个月")
    if newUser.github_contributions <= 50:
        return REJECT("GitHub contributions需>50")
    if not newUser.email_verified:
        return REJECT("需先完成邮箱验证")
    if INVITE_ONLY and not validInviteCode(newUser.invite_code):
        return REJECT("需要有效邀请码")
    return PASS
```

#### 1.1.3 执行步骤

**Step 1（必选）：连接 GitHub → L-1 映射 → 生成能证名片**

- 智权体授权 GitHub OAuth 连接
- 系统拉取 GitHub 公开数据（commits, repos, PRs, reviews, followers, stars, forks, languages, contribution history）
- 执行 **L-1 五维可组合子证明模型** 计算初始能证分数
- 生成 **IVD (Instant Verifiable Document) 60秒能证名片**

**Step 2（可选）：连接更多平台获取加分**

- 支持平台：GitLab / Stack Overflow / Dribbble / Behance / ArXiv / 个人域名
- 每个额外平台验证通过后，按平台权重系数追加能证加分
- 平台权重系数见 §1.1.4

**Step 3（可选）：确认系统推断的技能标签**

- 系统基于 L-1 映射结果自动推断技能标签
- 智权体可确认、修改或删除标签
- 用户修改后的标签标记为 `USER_ADJUSTED`，与系统推断标签区分存储

#### 1.1.4 L-1 映射公式（五维可组合子证明模型）

L-1 映射将 GitHub 公开数据转化为五个维度的可组合子证明分数，每个维度输出归一化值 [0, 1]，最终能证分数由五个维度加权求和：

```
CredentialProof = Σ(i in dimensions) w_i × proof_i

其中各维度权重：
  w_code      = 0.25   (代码证明)
  w_quality   = 0.20   (质量证明)
  w_community = 0.25   (社区证明)
  w_continuity = 0.15  (持续证明)
  w_diversity = 0.15   (多样性证明)
```

##### 代码证明 (Code Proof)

```
proof_code = log₂(commits + 1) × 0.3
           + normalize(repos) × 0.2
           + normalize(merged_prs) × 0.3
           + normalize(code_review) × 0.2

normalize(x) = min(x / category_median, 1.0)
```

- `commits`：总 commit 数（含 private repo commits，如 GitHub 提供）
- `repos`：公开仓库数
- `merged_prs`：已合并 PR 数
- `code_review`：提交的 code review 数
- 使用对数函数 `log₂(commits+1)` 防止极端值主导，category_median 使用全局中位数归一化

##### 质量证明 (Quality Proof)

```
proof_quality = test_coverage × 0.4
              + ci_pass_rate × 0.3
              + lint_score × 0.3
```

- `test_coverage`：最近 10 个仓库的平均测试覆盖率（如有）
- `ci_pass_rate`：最近 30 天 CI 通过率
- `lint_score`：代码规范检查得分（基于公开 linter 配置）
- 如数据不可得，对应项默认为 0.5（中性假设）

##### 社区证明 (Community Proof)

```
proof_community = normalize(followers) × 0.3
                + normalize(stars) × 0.5
                + normalize(forks) × 0.2
```

- 归一化使用 `log₁₀(x + 1) / log₁₀(category_99th + 1)` 防止极端值

##### 持续证明 (Continuity Proof)

```
proof_continuity = contribution_streak × 0.6
                 + normalize(account_age_days) × 0.4
```

- `contribution_streak`：连续贡献周数归一化（最大值 52 周 = 1.0）
- `account_age_days`：GitHub 账号创建至今的天数

##### 多样性证明 (Diversity Proof)

```
proof_diversity = normalize(language_count) × 0.4
                + normalize_pmf(domain_variety) × 0.6
```

- `language_count`：使用的编程语言种类
- `domain_variety`：仓库主题/领域多样性（web, system, data, mobile, devops 等），使用 PMF 熵归一化
- `normalize_pmf(x) = entropy(pmf_x) / entropy(pmf_uniform)` — 熵与均匀分布熵的比值

##### 质量过滤规则

| 异常模式 | 检测方法 | 惩罚措施 |
|----------|---------|---------|
| 刷星嫌疑 | stars > 100 但 forks/watch 不成比例 (stars/forks > 20) | `proof_community` × 0.5 |
| 僵尸仓库 | 10+ repos 但 80% 超过 6 个月无更新 | `proof_code` × 0.7 |
| 贡献激增 | contribution 月增幅 > 300% | `proof_continuity` × 0.5 |
| 单语言过度集中 | language_count = 1 且 domain_variety = 1 | `proof_diversity` × 0.3 |
| 新账号高活跃 | account_age < 3月 且 commits > 500 | `proof_continuity` × 0.6 |

#### 1.1.5 IVD 60秒能证名片

CP_BOOTSTRAP 完成后，系统自动生成 IVD (Instant Verifiable Document) 能证名片，包含：

```
┌────────────────────────────────────────────────┐
│         CONC 能证名片 (IVD v1.0)                │
│                                                 │
│  智权体: {agent_id}                             │
│  能证等级: {CP_Level}  (INITIAL / PROVISIONAL)  │
│  能证总分: {total_score}/10                     │
│                                                 │
│  五维分解:                                      │
│  ████████░░ 代码: {code_score}                  │
│  ██████░░░░ 质量: {quality_score}               │
│  ███████░░░ 社区: {community_score}             │
│  ████████░░ 持续: {continuity_score}            │
│  █████░░░░░ 多样性: {diversity_score}           │
│                                                 │
│  验证锚点:                                      │
│  GitHub: @{github_username}                     │
│  [{其他已连接平台}]                              │
│                                                 │
│  生成时间: {timestamp}                          │
│  验证哈希: {sha256_hash}                        │
│  过期: 90天后需刷新                             │
└────────────────────────────────────────────────┘
```

IVD 生成必须在 60 秒内完成（含 GitHub API 调用、计算、哈希生成）。超时需降级处理（见 §四）。

#### 1.1.6 平台加分系数

| 平台 | 权重系数 | 映射方式 | 最低要求 |
|------|---------|---------|---------|
| GitHub | 1.0（基准） | 五维子证明模型 | 账号>6月 + contributions>50 |
| GitLab | 0.8 | 简化四维模型（无 community） | 账号>6月 + activity>30 |
| Stack Overflow | 0.6 | 声誉/reputation 直接映射 | reputation > 100 |
| Dribbble / Behance | 0.5 | 作品数 + likes/views 比例 | 作品 > 3 |
| ArXiv | 0.7 | 论文数 + 引用数 | 论文 > 1 |
| 个人域名 | 0.3 | DNS 验证 + 内容分析 | 域名有效 |

加分公式：`bonus = Σ(i in platforms) w_i × platform_score_i × 0.2`

限制：额外平台加分总上限不超过基准 GitHub 分数的 50%。

---

### 1.2 阶段二：NR_SEED_PROJECT（声誉种子——项目评审）

#### 1.2.1 协议标识

- **任务令类型**：`NR_SEED_PROJECT`
- **任务令标识格式**：`GTW-SP-{agent_id}-{timestamp}`
- **触发条件**：CP_BOOTSTRAP 完成后自动创建（幂等）
- **验证方式**：PEER(n=3)，无网络时降级 AUTO×0.3
- **过期时间**：创建后 60 天未完成 → 标记 DORMANT

#### 1.2.2 任务内容

智权体需提交一个代表性作品（项目）供同行盲审。作品类型包括：

- **CLI 工具**：命令行工具或脚本集
- **库/框架**：可复用的代码库或框架
- **文档/教程**：技术文档、教程、书籍
- **设计系统**：UI 组件库、设计规范
- **数据管道**：数据处理流水线、ETL 工具

#### 1.2.3 动态 Rubric 盲审

评审采用**动态 rubric**，根据作品类型自适应调整评审维度和权重：

```
动态 Rubric 生成算法：
  input: project_type, project_metadata
  output: rubric_dimensions[]

  base_dimensions = [
    {name: "技术实现",    weight_range: [0.2, 0.4]},
    {name: "文档质量",    weight_range: [0.15, 0.3]},
    {name: "可维护性",    weight_range: [0.15, 0.25]},
    {name: "创新性",      weight_range: [0.1, 0.25]},
    {name: "社区价值",    weight_range: [0.1, 0.25]}
  ]

  switch project_type:
    case "CLI工具":
      adjust "技术实现" → +0.1 weight
      adjust "文档质量" → +0.05 weight
      adjust "社区价值" → -0.05 weight

    case "库/框架":
      adjust "可维护性" → +0.1 weight
      adjust "技术实现" → +0.05 weight
      add  "API设计" with weight 0.15
      reduce others proportionally

    case "文档/教程":
      adjust "文档质量" → +0.15 weight
      adjust "社区价值" → +0.1 weight
      adjust "技术实现" → -0.1 weight

    case "设计系统":
      add  "视觉一致性" with weight 0.2
      add  "可访问性"   with weight 0.1
      reduce others proportionally

    case "数据管道":
      adjust "技术实现" → +0.1 weight
      add  "数据正确性" with weight 0.15
      reduce others proportionally

  normalize all weights to sum = 1.0
  return rubric_dimensions
```

##### 评分标准（每个维度 1-5 分）

| 分数 | 含义 | 描述 |
|------|------|------|
| 1 | 严重不足 | 该维度存在根本性缺陷 |
| 2 | 不足 | 该维度低于行业标准 |
| 3 | 合格 | 该维度达到行业基本标准 |
| 4 | 良好 | 该维度优于行业平均水平 |
| 5 | 卓越 | 该维度达到行业领先水平 |

##### 盲审机制

- 评审者不被告知被评审者的 `agent_id`、GitHub 账号、或其他可识别身份信息
- 仅展示项目内容（代码、文档、README 等）和技术元数据（语言、代码行数、依赖数等）
- 评审者与被评审者之间的距离（相似度）影响配对但不影响评审过程

##### 质量门控

| 门控规则 | 描述 |
|----------|------|
| 评语最低字数 | ≥ 50 字（中/英） |
| 评分分布检查 | 至少 1 项评分 ≤ 3（防止全 5 分灌水） |
| 评语质量检查 | 不能仅包含模板化短语（"很好""不错""good job"等） |
| 评审时间检查 | 评审用时 > 30 秒（防止秒评） |

不满足以上任一条件 → 该评审标记为 `LOW_QUALITY`，不计入最终分数。

#### 1.2.4 降级路径

```
if network_peer_count >= 3:
    正常 PEER(n=3) 验证
elif network_peer_count >= 1:
    降级 PEER(n=network_peer_count) × 0.7 权重
else:
    降级 AUTO×0.3（仅基础自动化检查）
    标记为 DEGRADED_REVIEW
```

`DEGRADED_REVIEW` 标记的评审结果将在网络规模扩大后自动触发重新评审。

---

### 1.3 阶段三：NR_SEED_MUTUAL（声誉种子——互评）

#### 1.3.1 协议标识

- **任务令类型**：`NR_SEED_MUTUAL`
- **任务令标识格式**：`GTW-SM-{agent_id}-{timestamp}`
- **触发条件**：网络中 ≥ 5 个用户时自动创建（幂等 + 并发保护）
- **验证方式**：PEER(n≥3)，通过阈值 3.5
- **过期时间**：创建后 90 天未完成 → 标记 DORMANT

#### 1.3.2 v2.2 重大变更说明

| | v2.1（旧） | v2.2（新） |
|---|---|---|
| 评审方向 | n=1 双向互评 | **n≥3 单向评审** |
| 评审关系 | A↔B 互相评审 | A→B, C→D, E→F（单向链） |
| 防串谋 | 仅匿名化 | 匿名化+单向化+共识激励+延迟公布+评审信誉分 |
| 通过阈值 | 3.0 | **3.5** |
| 质量门控 | 评语>20字 | **评语≥50字 + 不能全部4-5分** |

#### 1.3.3 评审流程

```
每个参与智权体：
  1. 系统分配 n≥3 个单向评审目标（匿名）
  2. 评审者查看目标的能证名片（不含身份标识）和代表性作品摘要
  3. 评审者从四个维度评分：
     - 技术能力 (Technical Competence): 1-5
     - 协作素养 (Collaboration Quality): 1-5
     - 贡献可信度 (Contribution Credibility): 1-5
     - 领域匹配度 (Domain Alignment): 1-5
  4. 每个维度需附 ≥50 字评语
  5. 至少 1 项评分 ≤ 3（防止全满分灌水）
  6. 总得分 = 加权平均（各维度等权 0.25）
  7. 通过阈值 = 3.5
  8. 评审结果延迟公布（所有评审完成后 24 小时统一公布）
```

##### 单方向评审分配逻辑

```pseudocode
function assignReviewTargets(allCandidates):
    # 确保每个智权体分配 n≥3 个评审目标
    # 评审关系为单向：A 评审 B 不等于 B 评审 A
    # 避免形成闭环（A→B→C→A）降低串谋风险

    for each agent in allCandidates:
        candidates = allCandidates - {agent}
        # 排除已分配过评审agent的（防止双向）
        candidates = candidates - agent.already_reviewed_by

        # 配对算法选择 n 个目标（详见 §六）
        targets = pairingAlgorithm(agent, candidates, n=3)

        for each target in targets:
            createReviewTask(reviewer=agent, target=target)
            target.already_reviewed_by.add(agent)

    # 验证：所有 agent 的评审数 ≥ 3
    for each agent in allCandidates:
        assert countReviewsFor(agent) >= 3
```

---

## 二、自动触发逻辑

### 2.1 触发事件与处理

#### 2.1.1 事件注册

```
事件源                      触发操作                   幂等键
────────────────────────────────────────────────────────────────
onRegistration(newUser)  →  女巫检查 → 创建            agent_id + CP_BOOTSTRAP
                            CP_BOOTSTRAP

onTaskCompleted(task)    →  检查任务令类型 → 创建       agent_id + next_stage_type
                            下一阶段任务令

onTaskFailed(task)       →  重试 ≤ 3次 → 降级路径      agent_id + task_type + retry_count

onTaskExpired(task)      →  标记 DORMANT                task_id + EXPIRED

onNetworkSizeChange(n)   →  if n ≥ 5: 创建             genesis_id + NR_SEED_MUTUAL
                            NR_SEED_MUTUAL (SQLite事务)
```

#### 2.1.2 幂等性保证

```pseudocode
function createTaskWarrantIdempotent(agent_id, task_type):
    # 使用幂等键检查是否已存在
    idempotent_key = agent_id + ":" + task_type

    # SQLite 事务
    BEGIN TRANSACTION

    existing = SELECT * FROM task_warrants
               WHERE agent_id = $agent_id
               AND task_type = $task_type
               AND status NOT IN ('EXPIRED', 'DORMANT')

    if existing:
        COMMIT
        return existing  # 幂等：已存在则返回已有的

    # 创建新任务令
    new_task = INSERT INTO task_warrants (
        id, agent_id, task_type, status,
        created_at, idempotent_key
    ) VALUES (
        generateTaskId(agent_id, task_type),
        agent_id, task_type, 'DRAFT',
        now(), idempotent_key
    )

    COMMIT
    emit TaskWarrantCreated(new_task)
    return new_task
```

#### 2.1.3 并发保护（NR_SEED_MUTUAL）

```pseudocode
function createMutualReviewOnNetworkChange(network_size):
    if network_size < 5:
        return

    # 使用 SQLite 事务 + 条件插入防止并发重复创建

    BEGIN TRANSACTION

    # 锁定检查
    existing = SELECT COUNT(*) FROM task_warrants
               WHERE task_type = 'NR_SEED_MUTUAL'
               AND status IN ('DRAFT', 'IN_PROGRESS', 'SUBMITTED', 'REVIEWED')
               AND created_at > now() - INTERVAL 24 HOURS

    if existing > 0:
        COMMIT
        return  # 24小时内已有一批互评任务令，幂等跳过

    # 检查网络中有足够未完成的智权体
    pending_agents = SELECT agent_id FROM agents
                     WHERE cp_bootstrap_completed = TRUE
                     AND nr_seed_mutual_completed = FALSE
                     AND status = 'ACTIVE'

    if count(pending_agents) < 5:
        COMMIT
        return

    # 为所有待完成智权体创建 NR_SEED_MUTUAL 任务令
    for each agent in pending_agents:
        createTaskWarrantIdempotent(agent.id, 'NR_SEED_MUTUAL')

    COMMIT
```

#### 2.1.4 错误处理与降级路径

```
操作失败类型                    重试策略                  降级路径
─────────────────────────────────────────────────────────────────
GitHub API 限流                 指数退避 1s→2s→4s→8s    缓存上次结果，标记 stale
GitHub API 5xx                  重试 ≤3次                 降级：使用部分数据计算
IVD 生成超时 (>60s)             N/A                      降级：异步生成，先返回基础摘要
PEER 评审超时 (14天无人评审)    提醒 3次 (3d, 7d, 14d)    降级：AUTO×0.3 + 管理员介入
数据库写入失败                  重试 ≤3次                 记录错误日志，触发告警
网络分区导致评审无法分发         等待恢复 + 心跳检测        降级：延长过期时间至恢复后+7天
女巫检查API不可用               重试 ≤3次                 降级：宽松检查 + 事后审计标记
```

```pseudocode
function handleTaskFailure(taskWarrant, error):
    taskWarrant.retry_count += 1
    taskWarrant.last_error = error.message
    taskWarrant.last_error_at = now()

    if taskWarrant.retry_count <= 3:
        # 指数退避重试
        delay = 2 ^ (taskWarrant.retry_count - 1) * 60  # 秒
        scheduleRetry(taskWarrant, delay)
        taskWarrant.status = 'RETRYING'
        return

    # 超过最大重试次数 → 降级
    taskWarrant.status = 'DEGRADED'

    switch taskWarrant.type:
        case 'CP_BOOTSTRAP':
            # 降级：标记为 MANUAL_REVIEW
            taskWarrant.degradation_path = 'MANUAL_REVIEW'
            notifyAdmins(taskWarrant)

        case 'NR_SEED_PROJECT':
            # 降级：AUTO×0.3
            applyDegradedAutoReview(taskWarrant, weight=0.3)
            taskWarrant.degradation_path = 'AUTO×0.3'

        case 'NR_SEED_MUTUAL':
            # 降级：延长等待 + 降低阈值至 3.0
            taskWarrant.extended_deadline = now() + 30_DAYS
            taskWarrant.degraded_threshold = 3.0
            taskWarrant.degradation_path = 'EXTENDED_DEADLINE+LOWERED_THRESHOLD'

    save(taskWarrant)
    emit TaskWarrantDegraded(taskWarrant)
```

---

## 三、渐进式信任建立

### 3.1 四阶段信任模型

```
Phase 0: UNVERIFIED (1人网络)
  ├── 信任等级: 0
  ├── 验证权重: AUTO×0.3
  ├── 能证等级: INITIAL
  ├── NR 权重: ×0.2
  ├── 可执行动作: 仅 CP_BOOTSTRAP
  └── 升级条件: CP_BOOTSTRAP 完成

         │
         ▼

Phase 1: PROVISIONAL (2-4人网络)
  ├── 信任等级: 1
  ├── 验证权重: PEER×0.5
  ├── 能证等级: PROVISIONAL
  ├── NR 权重: ×0.5
  ├── 7天冷却期
  ├── 可执行动作: CP_BOOTSTRAP, NR_SEED_PROJECT
  └── 升级条件: NR_SEED_PROJECT 完成 + 网络≥2人

         │
         ▼

Phase 2: ESTABLISHED (5-14人网络)
  ├── 信任等级: 2
  ├── 验证权重: PEER×1.0
  ├── 能证等级: ESTABLISHED
  ├── NR 权重: ×1.0
  ├── 可执行动作: 全部三阶段任务令 + 加入策元
  └── 升级条件: NR_SEED_MUTUAL 完成 + 网络≥5人

         │
         ▼

Phase 3: MATURE (15+人网络)
  ├── 信任等级: 3
  ├── 验证权重: PEER×1.0 + MARKET×0.5
  ├── 能证等级: MATURE
  ├── NR 权重: ×1.5
  ├── 可执行动作: 全部权限 + 发起治理提案 + 创建策元
  └── 维护条件: 持续活跃 (180天内至少1次有效贡献)
```

### 3.2 信任等级与权限映射

| 信任等级 | Phase | 加入策元 | 创建策元 | 发起提案 | 投票权重 | NR 燃烧豁免 | PEER 评审权重 |
|---------|-------|---------|---------|---------|---------|------------|-------------|
| 0 | UNVERIFIED | ✗ | ✗ | ✗ | ✗ | ✗ | N/A |
| 1 | PROVISIONAL | 需审批 | ✗ | ✗ | 0.5× | ✗ | 0.5× |
| 2 | ESTABLISHED | ✓ | ✗ | ✗ | 1.0× | ✗ | 1.0× |
| 3 | MATURE | ✓ | ✓ | ✓ | 1.5× | 基础豁免 | 1.0× |

### 3.3 信任降级机制

```
触发条件                          降级操作
─────────────────────────────────────────────────────────────
连续 90 天无有效贡献              Phase - 1（最低 Phase 1）
被检测到串谋行为                  直接降至 Phase 0 + 标记 SYBIL
NR 余额 < 燃烧阈值                冻结 PEER 评审权限
CP_BOOTSTRAP 过期 DORMANT         回退至 Phase 0
被 ≥3 个 MATURE 节点投诉          人工审查 → 可能降级
```

---

## 四、防串谋协议

### 4.1 设计目标

CONC 防串谋协议 (Anti-Collusion Protocol, ACP) 针对 NR_SEED_MUTUAL 阶段的互评场景，防止多个智权体之间通过私下协调互相给予高分来操纵声誉系统。

### 4.2 五重防护机制

```
第一重：匿名化 (Anonymization)
  └── 评审者不知道被评审者的真实身份
      仅展示匿名化后的能证名片和项目摘要

第二重：单向化 (Unidirectionality)
  └── A→B 不等于 B→A
      系统确保不存在双向评审闭环
      评审关系形成有向无环图 (DAG)

第三重：共识激励 (Consensus Incentive)
  └── 评审者的评分与其他评审者的评分一致性影响评审者自身的 NR 奖励
      偏离共识超过 2σ → 评审信誉分降低

第四重：延迟公布 (Delayed Disclosure)
  └── 所有评审完成后 24 小时统一公布结果
      防止评审过程中信息泄露导致的策略性调整

第五重：评审信誉分 (Reviewer Credit Score)
  └── 每位智权体拥有评审信誉分 (RCS)
      RCS = f(历史评审一致性, 评审被采纳率, 评审详细度)
      RCS 低的评审者的评分权重自动降低
```

### 4.3 匿名化协议

```pseudocode
function anonymizeForReview(agent):
    return {
        anonymized_id: hash(agent.id + task_timestamp),  # 一次性匿名ID
        credential_summary: {
            level: agent.cp_level,
            total_score: round(agent.cp_total_score, 1),  # 四舍五入防指纹
            top_skills: agent.top_skills[0:3],             # 最多3个
        },
        project_summary: {
            type: agent.submitted_project.type,
            language: agent.submitted_project.language,
            size_category: categorizeProjectSize(agent.submitted_project),
            # size_category: SMALL/MEDIUM/LARGE (模糊化)
            description: extractAbstract(agent.submitted_project.readme, 200),
            # 200字摘要，去除作者名、个人URL
        },
        # 不暴露：agent_id, GitHub用户名, 邮箱, 项目URL, 精确能证分数
    }
```

### 4.4 共识激励算法

```pseudocode
function calculateReviewerConsensus(reviewer, target, all_reviews):
    # 获取所有评审者对同一目标的评分
    scores = [r.scores for r in all_reviews if r.target == target]

    # 计算均值与标准差
    mean_score = mean(scores)
    std_score = std(scores)

    # 计算该评审者的偏离度
    reviewer_score = reviewer.scores[target]
    deviation = abs(reviewer_score - mean_score) / max(std_score, 0.5)

    # 共识奖励/惩罚
    if deviation <= 1.0:    # 在1σ内：奖励
        consensus_bonus = 1.0 + (1.0 - deviation) * 0.2  # 最高+20%
    elif deviation <= 2.0:  # 在1-2σ：中性
        consensus_bonus = 1.0
    else:                   # 超过2σ：惩罚
        consensus_bonus = max(0.5, 2.5 - deviation * 0.5)  # 最低50%

    # 更新评审信誉分
    reviewer.rcs = reviewer.rcs * 0.9 + consensus_bonus * 0.1  # EMA 平滑

    return consensus_bonus
```

### 4.5 串谋检测模式

| 串谋模式 | 检测方法 | 触发条件 | 惩罚 |
|----------|---------|---------|------|
| 互评小圈子 | 检测评审关系图中的短环 | 3人内形成闭环互评 | NR 燃烧 20% + 标记 |
| 评分同调 | 多个评审者对同一目标给出完全相同评分 | 3+评审者评分向量余弦相似度 > 0.95 | 评审无效 + RCS ×0.5 |
| 时间模式串谋 | 多个评审在短时间内 (<60s) 完成 | 同一批次的评审完成时间聚类 | 标记可疑，人工复核 |
| 新号互评 | 创建时间相近的账号互相评审 | 账号创建时间差 < 7天 + 互评 | 加重审查 |
| 评分极化 | 对某些目标全5分，对另一些全1分 | 个人评分方差 > 3.0 | RCS 降低 + 评审无效 |

### 4.6 延迟公布时间线

```
T=0    评审分配完成，评审正式开始
T+7d   评审截止（硬性截止）
T+7d   + 24h 缓冲期（延迟公布窗口）
T+8d   统一公布结果
       - 所有评审分数和评语公开
       - 评审者的匿名ID映射在公布时解除
       - 共识激励/NR奖励同步结算

如果某评审者未在 T+7d 内完成：
  → 该评审标记为 INCOMPLETE
  → 被评审者的分数由已完成评审计算（最少需2份）
  → 未完成评审者的 RCS 扣减 0.1
```

---

## 五、配对算法

### 5.1 设计目标

为 NR_SEED_MUTUAL 阶段的互评分配评审目标，核心目标：

1. **最大化评审价值**：配对相似度高的评审者与被评审者，使评审更具针对性
2. **防串谋**：避免高相似度形成小圈子 → 引入随机扰动
3. **公平性**：每个智权体获得等量评审（≥3份）
4. **覆盖性**：尽量让不同领域/风格的智权体互相评审

### 5.2 相似度优先 + FIFO 兜底算法

```pseudocode
function pairingAlgorithm(agent, candidates, n=3):
    # Step 1: 计算相似度矩阵
    similarity_scores = []
    for each candidate in candidates:
        score = calculateSimilarity(agent, candidate)
        # 引入随机扰动 (±0.1) 防串谋
        score += random(-0.1, 0.1)
        similarity_scores.append((candidate, score))

    # Step 2: 按相似度排序（高→低）
    sort(similarity_scores, by=score, descending=True)

    # Step 3: 选择 Top-k + 随机采样混合
    # 前 60% 来自相似度最高，40% 来自随机采样（确保多样性）
    top_k = ceil(n * 0.6)
    random_k = n - top_k

    selected = similarity_scores[0:top_k]  # 高相似度

    # 从剩余中随机采样
    remaining = similarity_scores[top_k:]
    if random_k > 0 and len(remaining) > 0:
        random_sample = randomSample(remaining, random_k)
        selected += random_sample

    # Step 4: FIFO 兜底 —— 如果候选不足
    if len(selected) < n:
        # 从历史等待队列中补充（等待评审时间最长的）
        shortage = n - len(selected)
        fifo_candidates = getFIFOQueue(limit=shortage)
        selected += fifo_candidates

    # Step 5: 验证无闭环
    if hasCycle(agent, selected):
        # 替换形成闭环的候选
        selected = breakCycle(agent, selected, candidates)

    return selected
```

### 5.3 相似度计算函数

```pseudocode
function calculateSimilarity(agentA, agentB):
    # 多维度相似度，各维度等权

    # 技能标签 Jaccard 相似度
    skill_sim = jaccard(agentA.skills, agentB.skills)

    # 能证等级距离
    cp_distance = abs(agentA.cp_total_score - agentB.cp_total_score) / 10.0
    cp_sim = 1.0 - cp_distance

    # 项目类型相似度（同类型 → 1.0，不同类型 → 0.3）
    project_sim = 1.0 if agentA.project_type == agentB.project_type else 0.3

    # 代码语言重叠度
    lang_sim = jaccard(agentA.languages, agentB.languages)

    # 加权综合
    similarity = (
        skill_sim * 0.30 +
        cp_sim * 0.25 +
        project_sim * 0.25 +
        lang_sim * 0.20
    )

    return similarity
```

### 5.4 FIFO 队列管理

```
FIFO 等待队列：
  - 当网络规模不足时，新进入者进入 FIFO 队列
  - 队列按 join_time 排序
  - 队列最大等待时间 30 天
  - 超过 30 天 → 触发降级路径（AUTO×0.3）
  - 每当有新智权体完成 NR_SEED_PROJECT 时，触发队列重新配对
```

---

## 六、NR 燃烧机制设计

### 6.1 燃烧机制目标

NR 燃烧机制是实现「本原零（自利与秩序恒常）」的关键工程化手段。通过设置 NR 的持续消耗，确保：

1. **活跃激励**：不活跃的 NR 会自动衰减，避免「僵尸声誉」
2. **反垄断**：巨量 NR 持有者面临更高的维持成本
3. **通缩压力**：NR 不会无限膨胀，保持声誉稀缺性
4. **协议收入**：燃烧的 NR 进入协议公共池，用于生态激励

### 6.2 出口设计（NR 使用场景）

| 出口类型 | 操作 | 消耗 NR 量 | 频率限制 |
|----------|------|-----------|---------|
| **治理权** | 发起提案 | 100 NR | 30天/次 |
| **治理权** | 投票 | 10 NR | 不限 |
| **优先权** | 任务令优先级提升 | 50 NR | 7天/次 |
| **准入权** | 创建新策元 | 200 NR | 90天/次 |
| **准入权** | 邀请新成员（邀请制模式下） | 30 NR | 不限 |
| **评审消费** | 发起 MARKET 验证 | 20 NR | 不限 |
| **评审消费** | 对评审结果提出争议 | 50 NR | 14天/次 |
| **活跃税** | 月度活跃维持费 | 见 §6.3 | 自动扣除 |

### 6.3 动态衰减机制

```
NR 月度衰减速率由全网 NR 总量增长率动态调整：

if 全网 NR 总量月增长 > 20%:
    半衰期 = 10 个月  (加速衰减，抑制通胀)
elif 全网 NR 总量月增长 > 5%:
    半衰期 = 14 个月  (标准衰减)
else:
    半衰期 = 18 个月  (减缓衰减，鼓励活跃)

月度衰减率 = 1 - 0.5^(1 / 半衰期)

示例：
  半衰期 10 个月 → 月衰减率 ≈ 6.7%
  半衰期 14 个月 → 月衰减率 ≈ 4.8%
  半衰期 18 个月 → 月衰减率 ≈ 3.8%
```

### 6.4 衰减公式

```
NR_remaining = NR_initial × 0.5^(t / half_life)

其中：
  t = 自上次活跃以来的时间（月）
  half_life = 动态半衰期（月）

每次智权体完成有效贡献 → 重置 t = 0
```

### 6.5 阶梯式燃烧（策元层面）

策元内 NR 分配遵循阶梯式燃烧：

```
策元活跃度              NR 燃烧乘数
────────────────────────────────────
连续 30 天有产出        0.5×（激励）
连续 14 天有产出        0.7×
连续 7 天有产出         0.9×
无产出 7-14 天          1.0×（基准）
无产出 14-30 天         1.5×（加速）
无产出 >30 天           2.0× → 触发策元 DORMANT 审查
```

### 6.6 NR 铸造/燃烧平衡表

```
NR 来源（铸造）                    NR 消耗（燃烧）
─────────────────────────────────────────────────
任务令完成奖励                    月度活跃税
PEER 评审奖励（含共识激励）        治理操作消费
被评审通过（获得外部认可）         策元创建与维护
发现漏洞/改进协议                  争议仲裁
贡献被引用/复用                   衰减（不活跃）
创世任务令完成（一次性种子奖励）   串谋惩罚
```

---

## 七、任务令状态机转换矩阵

### 7.1 状态定义

| 状态 | 含义 | 描述 |
|------|------|------|
| `DRAFT` | 草稿 | 任务令已创建，智权体尚未开始执行 |
| `IN_PROGRESS` | 执行中 | 智权体已开始执行任务令 |
| `SUBMITTED` | 已提交 | 智权体已完成任务并提交，等待验证 |
| `REVIEWED` | 已评审 | 评审已完成，等待最终确认 |
| `COMPLETED` | 已完成 | 任务令成功完成，触发下一阶段 |
| `REJECTED` | 已驳回 | 任务令评审不通过，可修改重提 |
| `EXPIRED` | 已过期 | 超过截止时间未完成 |
| `DORMANT` | 休眠 | 长期未完成且过期，可被重新激活 |
| `DEGRADED` | 已降级 | 错误降级路径，以降低标准完成 |
| `RETRYING` | 重试中 | 临时失败，等待重试 |

### 7.2 状态机图（ASCII）

```
                        ┌──────────┐
                        │  DRAFT   │
                        └────┬─────┘
                             │ 开始执行
                             ▼
                        ┌──────────┐
              ┌────────│IN_PROGRESS│────────┐
              │        └─────┬────┘        │
              │              │ 提交         │ 超时
              │              ▼              │
              │         ┌──────────┐        │
              │         │SUBMITTED │        │
              │         └────┬─────┘        │
              │              │              │
              │     ┌───────┼───────┐      │
              │     │       │       │      │
              │     ▼       ▼       ▼      ▼
              │  ┌──────┐ ┌───┐ ┌──────┐ ┌────────┐
              │  │REJECT│ │AUTO││PEER  │ │EXPIRED │
              │  │ ED   │ │   ││  (n) │ └───┬────┘
              │  └──┬───┘ └─┬─┘└──┬───┘     │
              │     │        │     │         │ 30天
              │     │ 修改   │     │         ▼
              │     │ 重提   │     │    ┌────────┐
              │     └──┐     │     │    │DORMANT │
              │        │     │     │    └───┬────┘
              │        ▼     │     │        │重新激活
              │   ┌──────────┐│     │        │
              │   │IN_PROGRESS│     │        │
              │   └──────────┘│     │        │
              │               │     │        │
              │               ▼     ▼        │
              │           ┌──────────┐       │
              │           │ REVIEWED │       │
              │           └────┬─────┘       │
              │                │             │
              │         ┌─────┼─────┐       │
              │         │           │       │
              │         ▼           ▼       │
              │    ┌─────────┐ ┌────────┐   │
              │    │COMPLETED│ │REJECTED│   │
              │    └────┬────┘ └───┬────┘   │
              │         │          │        │
              │         ▼          └────────┘
              │    触发下一阶段      (可修改重提)
              │    ┌─────────┐
              │    │ 下一阶段 │
              │    │  DRAFT   │
              │    └─────────┘
              │
              └──── 任何状态 ────► EXPIRED (超时)
                   任何状态 ────► DEGRADED (错误降级)
```

### 7.3 状态转换矩阵

```
当前状态        │ DRAFT │ IN_PROG │ SUBMIT │ REVIEW │ COMPL │ REJECT │ EXPIRED │ DORMANT │ DEGRADED │ RETRYING
────────────────┼───────┼─────────┼────────┼────────┼───────┼────────┼─────────┼─────────┼──────────┼─────────
DRAFT           │   -   │   ✓    │   ✗    │   ✗    │   ✗   │   ✗   │    ✓    │    ✗    │    ✗     │    ✗
IN_PROGRESS     │   ✗   │   -    │   ✓    │   ✗    │   ✗   │   ✗   │    ✓    │    ✗    │    ✓     │    ✓
SUBMITTED       │   ✗   │   ✗    │   -    │   ✓    │   ✗   │   ✓   │    ✓    │    ✗    │    ✓     │    ✗
REVIEWED        │   ✗   │   ✗    │   ✗    │   -    │   ✓   │   ✓   │    ✓    │    ✗    │    ✗     │    ✗
COMPLETED       │   ✗   │   ✗    │   ✗    │   ✗    │   -   │   ✗   │    ✗    │    ✗    │    ✗     │    ✗
REJECTED        │   ✗   │   ✓*   │   ✗    │   ✗    │   ✗   │   -   │    ✓    │    ✗    │    ✗     │    ✗
EXPIRED         │   ✗   │   ✗    │   ✗    │   ✗    │   ✗   │   ✗   │    -    │    ✓    │    ✗     │    ✗
DORMANT         │   ✓*  │   ✗    │   ✗    │   ✗    │   ✗   │   ✗   │    ✗    │    -    │    ✗     │    ✗
DEGRADED        │   ✗   │   ✗    │   ✗    │   ✗    │   ✓*  │   ✗   │    ✗    │    ✗    │    -     │    ✗
RETRYING        │   ✗   │   ✓    │   ✗    │   ✗    │   ✗   │   ✗   │    ✓    │    ✗    │    ✓     │    -

图例：
  ✓   允许转换
  ✗   不允许转换
  ✓*  条件转换（需满足附加条件）
  -   相同状态

附加条件说明：
  REJECTED → IN_PROGRESS: 需智权体修改作品后重新提交
  DORMANT → DRAFT: 需在有效期内手动重新激活
  DEGRADED → COMPLETED: 降级路径完成，标记为降级完成
```

### 7.4 各阶段过期时间

| 任务令类型 | 过期时间 | 过期后状态 | 可重新激活 |
|-----------|---------|-----------|-----------|
| CP_BOOTSTRAP | 30 天 | DORMANT | ✓（需重新女巫检查） |
| NR_SEED_PROJECT | 60 天 | DORMANT | ✓（需重新提交作品） |
| NR_SEED_MUTUAL | 90 天 | DORMANT | ✓（保留已有评审） |

### 7.5 创世任务令完成后的状态

```
全部三阶段完成 → 智权体标记为 GENESIS_COMPLETE

GENESIS_COMPLETE 智权体：
  ├── 能证等级: ESTABLISHED（最低）
  ├── 获得初始 NR 种子奖励: 100 NR
  ├── 获得初始 JC (Judgment Credit): 50 JC
  ├── 可加入现有策元（无审批）
  ├── 可被分配常规任务令
  └── 信任等级: Phase 2+（取决于网络规模）
```

---

## 八、数据模型

### 8.1 任务令表 (task_warrants)

```sql
CREATE TABLE task_warrants (
    id              TEXT PRIMARY KEY,          -- GTW-{type}-{agent_id}-{timestamp}
    agent_id        TEXT NOT NULL,
    task_type       TEXT NOT NULL,             -- CP_BOOTSTRAP / NR_SEED_PROJECT / NR_SEED_MUTUAL
    status          TEXT NOT NULL DEFAULT 'DRAFT',
    retry_count     INTEGER DEFAULT 0,
    degradation_path TEXT,
    degraded_threshold REAL,
    extended_deadline TEXT,
    idempotent_key  TEXT NOT NULL UNIQUE,      -- agent_id:task_type
    created_at      TEXT NOT NULL,
    started_at      TEXT,
    submitted_at    TEXT,
    reviewed_at     TEXT,
    completed_at    TEXT,
    expired_at      TEXT,
    last_error      TEXT,
    last_error_at   TEXT,
    metadata        TEXT DEFAULT '{}',          -- JSON
    FOREIGN KEY (agent_id) REFERENCES agents(id)
);

CREATE INDEX idx_task_warrants_agent ON task_warrants(agent_id, task_type);
CREATE INDEX idx_task_warrants_status ON task_warrants(status, created_at);
CREATE INDEX idx_task_warrants_expiry ON task_warrants(expired_at) WHERE status NOT IN ('COMPLETED', 'EXPIRED', 'DORMANT');
```

### 8.2 评审记录表 (review_records)

```sql
CREATE TABLE review_records (
    id              TEXT PRIMARY KEY,
    task_warrant_id TEXT NOT NULL,
    reviewer_id     TEXT NOT NULL,
    target_id       TEXT NOT NULL,             -- 被评审者（NR_SEED_MUTUAL阶段）
    review_type     TEXT NOT NULL,             -- AUTO / PEER / MARKET
    scores          TEXT NOT NULL,              -- JSON: {"dim1": 4, "dim2": 3,...}
    comment         TEXT NOT NULL,
    word_count      INTEGER NOT NULL,
    quality_flag    TEXT DEFAULT 'NORMAL',      -- NORMAL / LOW_QUALITY / SUSPICIOUS
    consensus_bonus REAL DEFAULT 1.0,
    submitted_at    TEXT NOT NULL,
    disclosed_at    TEXT,                       -- 延迟公布时间
    FOREIGN KEY (task_warrant_id) REFERENCES task_warrants(id)
);

CREATE INDEX idx_review_records_target ON review_records(target_id, submitted_at);
CREATE INDEX idx_review_records_reviewer ON review_records(reviewer_id, submitted_at);
```

### 8.3 信任状态表 (trust_states)

```sql
CREATE TABLE trust_states (
    agent_id        TEXT PRIMARY KEY,
    trust_phase     INTEGER NOT NULL DEFAULT 0,  -- 0-3
    trust_level     INTEGER NOT NULL DEFAULT 0,  -- 0-3
    verification_weight REAL DEFAULT 0.3,
    nr_weight       REAL DEFAULT 0.2,
    cp_level        TEXT DEFAULT 'INITIAL',       -- INITIAL/PROVISIONAL/ESTABLISHED/MATURE
    genesis_complete BOOLEAN DEFAULT FALSE,
    last_active_at  TEXT,
    degraded_at     TEXT,
    degradation_reason TEXT,
    FOREIGN KEY (agent_id) REFERENCES agents(id)
);
```

---

## 九、API 端点

### 9.1 任务令端点

```
GET    /api/v1/task-warrants/{agent_id}           # 获取智权体的所有任务令
POST   /api/v1/task-warrants/{id}/start           # 开始执行任务令
POST   /api/v1/task-warrants/{id}/submit          # 提交任务令
GET    /api/v1/task-warrants/{id}/status           # 获取任务令状态
POST   /api/v1/task-warrants/{id}/reactivate      # 重新激活 DORMANT 任务令
```

### 9.2 评审端点

```
GET    /api/v1/reviews/pending/{agent_id}          # 获取待评审任务（作为评审者）
POST   /api/v1/reviews/{task_warrant_id}/submit    # 提交评审
GET    /api/v1/reviews/results/{agent_id}          # 获取评审结果（延迟公布后）
```

### 9.3 能证端点

```
GET    /api/v1/credentials/{agent_id}/ivd          # 获取 IVD 能证名片
POST   /api/v1/credentials/{agent_id}/link-platform # 连接外部平台
GET    /api/v1/credentials/{agent_id}/skills        # 获取推断技能标签
PUT    /api/v1/credentials/{agent_id}/skills        # 修改技能标签
POST   /api/v1/credentials/{agent_id}/refresh       # 刷新能证（到期前）
```

---

## 十、协议版本与升级路径

### 10.1 版本标识

```
协议标识符：CONC-Protocol/Genesis_TaskWarrant.1.0
语义版本：1.0.0
发布日期：2026-05-27
状态：DRAFT → 待社区评审
```

### 10.2 向后兼容性

| 版本 | 主要变更 | 兼容性 |
|------|---------|--------|
| 1.0 | 初始版本。定义三阶段链式冷启动、防串谋协议、NR 燃烧机制 | 基准 |
| 未来 1.x | 新增外部平台支持、调优评分参数、扩展女巫检测规则 | 向后兼容 |
| 未来 2.0 | 可能重构 NR 燃烧经济模型、引入更复杂的共识机制 | 需迁移 |

### 10.3 参数治理

以下参数可通过治理提案修改（需 Phase 3 MATURE 节点发起）：

| 参数 | 默认值 | 可调范围 | 描述 |
|------|--------|---------|------|
| 女巫检查 GitHub 账号年龄 | 6 月 | 3-12 月 | 最低账号年龄门槛 |
| 女巫检查 contributions | 50 | 20-200 | 最低贡献量门槛 |
| NR_SEED_MUTUAL 通过阈值 | 3.5 | 3.0-4.0 | 互评通过分数 |
| NR 月度衰减半衰期基准 | 14 月 | 10-24 月 | NR 衰减速率 |
| 防串谋共识偏离阈值 | 2σ | 1.5-3.0σ | 串谋检测灵敏度 |
| CP_BOOTSTRAP 过期时间 | 30 天 | 14-60 天 | 第一阶段过期时间 |

---

## 附录 A：完整触发流程图

```
                    ┌──────────────────┐
                    │  新智权体注册事件  │
                    └────────┬─────────┘
                             │
                    ┌────────▼─────────┐
                    │   女巫基础检查     │
                    │ GitHub>6月 + >50  │
                    └────┬────────┬────┘
                         │        │
                    通过 │        │ 失败
                         │        ▼
                         │   ┌──────────┐
                         │   │ REJECTED │
                         │   └──────────┘
                         │
              ┌──────────▼──────────┐
              │ 幂等创建 CP_BOOTSTRAP │
              └──────────┬──────────┘
                         │
              ┌──────────▼──────────┐
              │ Step1: L-1 五维映射  │
              │ Step2: 可选平台加分  │
              │ Step3: 确认技能标签  │
              └──────────┬──────────┘
                         │
              ┌──────────▼──────────┐
              │ AUTO 验证 (IVD生成) │
              │ 60秒内生成能证名片   │
              └──────┬─────────┬────┘
                     │         │
                成功 │         │ 失败/超时
                     │         ▼
                     │    ┌──────────┐
                     │    │ 降级处理  │
                     │    │ 重试/异步 │
                     │    └──────────┘
                     │
          ┌──────────▼──────────┐
          │ 幂等创建              │
          │ NR_SEED_PROJECT     │
          └──────────┬──────────┘
                     │
          ┌──────────▼──────────┐
          │ 提交代表性作品        │
          └──────────┬──────────┘
                     │
          ┌──────────▼──────────┐
          │ 动态 Rubric 盲审     │
          │ PEER(n=3) 或降级    │
          └──────┬─────────┬────┘
                 │         │
            通过 │         │ 不通过
                 │         ▼
                 │    ┌──────────┐
                 │    │ REJECTED │
                 │    │ (修改重提)│
                 │    └──────────┘
                 │
    ┌────────────▼──────────────┐
    │ 网络 ≥ 5人?               │
    └────┬────────────────┬─────┘
         │                │
    是   │                │  否 → 等待
         │                │        │
    ┌────▼──────────┐     │   ┌────▼──────────┐
    │ 幂等创建        │     │   │ 网络规模变化时  │
    │ NR_SEED_MUTUAL │     │   │ 重新检查触发    │
    └────┬───────────┘     │   └────────────────┘
         │                 │
    ┌────▼───────────┐     │
    │ 配对算法分配     │     │
    │ n≥3 单向评审    │     │
    └────┬───────────┘     │
         │                 │
    ┌────▼───────────┐     │
    │ 匿名化 + 盲审    │     │
    │ 防串谋五重防护   │     │
    └────┬──────┬────┘     │
         │      │          │
    通过 │      │ 不通过    │
    (3.5)│      ▼          │
         │  ┌──────────┐   │
         │  │ REJECTED │   │
         │  └──────────┘   │
         │                 │
    ┌────▼─────────────────▼──┐
    │  ★ 创世任务令全部完成 ★  │
    │  获得完整初始声誉权重     │
    │  NR 种子奖励 +100 NR     │
    │  信任等级: ESTABLISHED   │
    └──────────────────────────┘
```

---

## 附录 B：术语表

| 术语 | 英文 | 定义 |
|------|------|------|
| 创世任务令 | Genesis Task Warrant | 新注册智权体完成冷启动的三阶段链式任务令 |
| 能证 | Credential Proof (CP) | 智权体的可验证信誉证明 |
| L-1 映射 | L-1 Mapping | 将外部信任锚点（如GitHub）数据映射为内部能证的过程 |
| IVD | Instant Verifiable Document | 60秒内生成的可验证能证名片 |
| 五维可组合子证明 | Five-Dimensional Composable Sub-Proof | 代码/质量/社区/持续/多样性的五维度证明模型 |
| 盲审 | Blind Review | 隐藏被评审者身份的评审方式 |
| 动态 Rubric | Dynamic Rubric | 根据项目类型自适应调整维度和权重的评审标准 |
| 女巫检查 | Sybil Check | 防止虚假/重复身份的检测机制 |
| 幂等性 | Idempotency | 同一操作执行多次产生相同结果 |
| 渐进式信任 | Progressive Trust | 信任等级随验证深度逐步提升的四阶段模型 |
| 防串谋协议 | Anti-Collusion Protocol (ACP) | 防止多个智权体私下协调操纵声誉的五重防护机制 |
| 共识激励 | Consensus Incentive | 评审者评分与共识一致性影响其自身NR奖励的机制 |
| 延迟公布 | Delayed Disclosure | 所有评审完成后24小时统一公布结果的机制 |
| 评审信誉分 | Reviewer Credit Score (RCS) | 基于历史评审表现的评审者可信度评分 |
| NR 燃烧 | NR Burning | NR 的持续消耗机制，确保声誉稀缺性和活跃激励 |
| 动态衰减 | Dynamic Decay | NR 半衰期随全网NR增长率动态调整的机制 |
| DORMANT | 休眠状态 | 任务令长期未完成且已过期的状态 |

---

> **协议终注**：创世任务令协议是 CONC v2.2 最核心的创新——它将「如何让新成员融入网络」这一看似社会性的问题，转化为可验证、可审计、防串谋的协议化流程。冷启动不再是等待网络效应自然形成的被动过程，而是协议自身运转的主动实例。一个空网络中的新智权体，通过完成三阶段创世任务令，不仅在积累声誉，更在亲身验证协议的完整性和可靠性——这正是 CONC 区别于所有其他网络协议的根本特征。

> *"The protocol doesn't wait for the network to form — the protocol IS the network forming."*


---

## v1.1 更新 (2026-07-10) — CONC-P2-2
- 整合12个CONC领域分类（基于WIPO 35技术领域归并）
- 引入判断力密度J_density因子（决断点产生率×不可逆决策占比×(1-Agent自动化覆盖率)）
- 行业差异化创世任务参数：制药J_density=0.36，软件J_density=0.04
