# CONC 创意聚合协议
## Intent Coalescence Protocol (ICP) v1.3 — Three-Signal Fusion Matching

> "策元的成员因共享的创意方向而聚集——他们是提出者、拥戴者和首要执行者。创意聚合协议使这一过程从'偶然的相似'变为'协议化的形式共识'。"
>
> 对标：任务令的内源优先三阶段（Step1 激情匹配 → Step2 能力匹配 → Step3 外源溢出），ICP 为创意图元的聚合设计对应的形式化三阶段流程。

---

## 零、协议定位与设计原则

### 0.1 创意聚合 vs 任务匹配：根本性区别

CONC 框架中存在两种性质截然不同的匹配过程：

| 维度 | 创意聚合 (ICP) | 任务匹配 (任务令三阶段) |
|------|:-------------:|:---------------------:|
| 本质 | **方向认同** — "我想做这件事" | **能力适配** — "我能做这个任务" |
| 驱动 | 激情（Passion） | 能力 + 回报（Capability + Reward） |
| 粒度 | 创意图元（宏观创意方向） | 任务令（微观可执行模块） |
| 产品 | 策元（Genesis Unit）的结晶 | 任务令的承接与完成 |
| 参与者 | 未来的策元共同创始者 | 已结晶策元内的任务执行者 |
| 匹配基础 | 意向量空间的余弦相似度 | 能证向量与任务要求的点积 |
| 外部参与 | 不可外源 — 外部参与者不能"加入"创意方向 | 可外源 — Step 3 允许外部承接 |

**核心洞察**：任务令的三阶段协议（Step 1-3）运行在**策元已结晶之后**——它调度的是"谁来做这个任务"。而 ICP 运行在**策元结晶之前**——它发现的是"谁和我想做同一件事"。ICP 是策元层的**上游协议**，任务令协议是策元层的**下游协议**。

### 0.2 ICP 在协议栈中的位置

```
┌─────────────────────────────────────────────────────────┐
│  应用层 (Application Layer)                              │
│  创意图元浏览器 · 种子仪表盘 · 策元结晶通知               │
├─────────────────────────────────────────────────────────┤
│  策元层 (Genesis Layer)                                  │
│  ┌───────────────────────────────────────────────────┐  │
│  │  ★ 创意聚合协议 (ICP) — 本协议                      │  │
│  │  Phase 1: 种子广播 → Phase 2: 意向表达              │  │
│  │  → Phase 3: 策元结晶                                │  │
│  ├───────────────────────────────────────────────────┤  │
│  │  策元 CRUD · 成员 Join/Leave · PCP 管理              │  │
│  │  任务令内源优先三阶段 (Step 1 → 2 → 3)              │  │
│  └───────────────────────────────────────────────────┘  │
├─────────────────────────────────────────────────────────┤
│  身份层 (Identity Layer)                                 │
│  智权体注册 · 能证发行 · 身份锚定                        │
├─────────────────────────────────────────────────────────┤
│  网络层 (Network Layer)                                  │
│  节点发现 · 消息广播 · INTENT_COALESCENCE 广播类型       │
└─────────────────────────────────────────────────────────┘
```

ICP 是策元层的**入口协议**——它定义了"策元如何从零开始形成"。策元层的其余 API（`POST /genesis/create`、`POST /genesis/{id}/join` 等）依赖 ICP 的输出（已完成的意图聚结 + 初始成员集）。

### 0.3 设计原则

1. **激情优先**：匹配基于"我想做这件事"，而非"我能做这个任务"。方向认同是聚合的充分条件，能力验证是策元建立后的任务分配问题。
2. **阈值策元自治**：余弦相似度阈值 θ 不由平台统一设定——各策元的创始成员在 PCP 模板中自定义。平台的作用是计算和呈现相似度，判断交由人。
3. **人工智能辅助，人类决策**：AI 负责计算相似度、推荐匹配种子、标记潜在策元——但聚结的最终确认（谁加入、何时结晶）是人类智权体的主权决策。
4. **图操作原子性**：策元结晶操作（创建 Genesis 节点 + 建立成员协作边 + 签署 PCP）在同一个事务中完成——要么全部成功，要么全部回滚。
5. **开放性与防噪平衡**：种子广播全网可见以最大化发现概率，但意向表达需附带能证以防止垃圾意向。

---

## 一、创意图元 (Creative Seed) 的声明格式

### 1.1 概念定义

**创意图元 (Creative Seed)** 是智权体在 CONC 网络中发布的最小创意声明单元。它表达的是："我希望在某领域实现某种创造性产出——寻找有相同方向的合作者。"

创意图元**不是**项目计划书，**不是**任务令，**不是**融资提案。它是一颗"方向种子"——简洁、明确、可被 AI 计算和匹配。

### 1.2 创意图元 JSON Schema

```json
{
  "$schema": "https://conc-protocol.org/creative-seed-schema.json",
  "seed_id": "cs_a1b2c3d4",
  "publisher_ns_id": "ns_0a1b2c3d",
  "published_at": "2026-05-14T12:00:00Z",

  "1_title": {
    "type": "string",
    "max_length": 120,
    "description": "创意图元的一句话标题，用于列表展示和快速匹配。应简洁且具有区分性。",
    "example": "面向儿童的开源编程学习平台"
  },

  "2_direction_vector": {
    "type": "array",
    "items": { "type": "float", "range": [0.0, 1.0] },
    "length": 5,
    "description": "5维创意方向向量，定义创意图元在高维意图空间中的位置。维度由 CONC 协议统一预定义。",
    "dimensions": {
      "d0": "技术深度 (0=现成工具组装, 1=底层技术突破)",
      "d1": "社会影响力 (0=纯商业, 1=纯公益)",
      "d2": "协作开放性 (0=封闭/私有, 1=完全开源/开放)",
      "d3": "创新激进性 (0=增量改进, 1=颠覆性创新)",
      "d4": "物理-数字谱系 (0=纯数字/软件, 1=重物理/硬件)"
    },
    "example": [0.3, 0.8, 0.9, 0.6, 0.1]
  },

  "3_description": {
    "type": "string",
    "max_length": 2000,
    "description": "创意图元的文字描述。自由格式，但建议包含：愿景、目标用户、核心差异化、为什么现在做。用于人类阅读和 AI 语义分析。",
    "embedding_hash": {
      "type": "string",
      "description": "SHA256 of the description text embedding vector (768-dim from the CONC embedding model). 用于 AI 辅助相似度计算的次级信号。",
      "example": "sha256:e3b0c44298fc1c149afbf4c8996fb924..."
    }
  },

  "4_required_skill_domains": {
    "type": "array",
    "items": { "type": "string" },
    "max_items": 10,
    "description": "实现此创意所需的核心技能域列表。用于告知潜在合作者'这个方向需要什么样的能力组合'——不是准入门槛，是预期参考。",
    "example": ["frontend_development", "educational_design", "ui_ux", "community_building"]
  },

  "5_proposer_capability_hint": {
    "type": "object",
    "description": "提案者自述能力提示——声明自己能为这个创意方向贡献什么。不同于正式的能证（Capability Proof），这是轻量的'自我介绍'。",
    "properties": {
      "role_hint": {
        "type": "string",
        "description": "提案者预期的自我角色定位。",
        "example": "全栈开发者 + 教育内容设计"
      },
      "commitment_level": {
        "type": "string",
        "enum": ["exploring", "part_time", "full_time"],
        "description": "提案者当前对此方向的投入承诺级别。exploring=探索/观望, part_time=可投入部分时间, full_time=可全职投入。"
      }
    }
  },

  "6_visibility": {
    "type": "object",
    "description": "种子的可见性范围设置。",
    "properties": {
      "scope": {
        "type": "string",
        "enum": ["network_wide", "invite_only"],
        "default": "network_wide",
        "description": "network_wide=全网可见（默认）, invite_only=仅指定智权体可见（种子仍被索引但不显示给非受邀者）。"
      },
      "invited_ns_ids": {
        "type": "array",
        "items": { "type": "string" },
        "description": "当 scope=invite_only 时，受邀智权体列表。"
      }
    }
  },

  "7_expiration": {
    "type": "string",
    "format": "date-time",
    "description": "种子过期时间。过期后不再出现在推荐列表和主动匹配中。默认：发布后 90 天。最大：180 天。",
    "default": "publish_time + 90 days"
  },

  "8_tags": {
    "type": "array",
    "items": { "type": "string" },
    "max_items": 8,
    "description": "自由标签，用于关键词搜索和分组浏览。",
    "example": ["education", "open_source", "children", "programming", "gamification"]
  }
}
```

### 1.3 方向向量的五维定义

CONC 协议固定使用 5 维创意方向空间。五个维度的选择经过慎重考量：

| 维度 | 名称 | 0.0 端 | 1.0 端 | 选择理由 |
|------|------|--------|--------|----------|
| d0 | 技术深度 | 现成工具组装 | 底层技术突破 | 区分"应用创新"与"技术创新" |
| d1 | 社会影响力 | 纯商业导向 | 纯公益导向 | 区分价值取向——影响合作者类型 |
| d2 | 协作开放性 | 封闭/私有 | 完全开源/开放 | CONC 的核心张力——开放 vs 竞争壁垒 |
| d3 | 创新激进性 | 增量改进 | 颠覆性创新 | 区分风险偏好——影响 ALP 折价率 |
| d4 | 物理-数字谱系 | 纯数字/软件 | 重物理/硬件 | 区分生产形式——影响无人工厂对接需求 |

**设计哲学**：维度数量（5）是 "足够区分" 与 "不会过拟合" 之间的平衡。对标：比特币用 256-bit 哈希表示区块身份——维度太少失去区分度，太多导致稀疏性灾难。5 维空间使任何种子在高维球面上的最近邻搜索在计算上是轻量级的。

### 1.4 创意图元生命周期状态机

```
                ┌─────────┐
    发布        │  ACTIVE  │ ──────────── 自然到期 (90d) ──────┐
   ──────────▶  │ (广播中)  │                                    │
                └────┬─────┘                                    ▼
                     │                                    ┌──────────┐
                     │ 策元结晶成功                        │ EXPIRED  │
                     ▼                                    │ (已过期)  │
                ┌──────────┐                              └──────────┘
                │ COALESCED│
                │ (已聚结) │ ──── 策元解散/重校准 ────▶ ACTIVE (重新广播)
                └──────────┘
                     │
                     │ 发布者主动取消
                     ▼
                ┌──────────┐
                │CANCELLED │
                │ (已取消)  │
                └──────────┘
```

- **ACTIVE**：种子正在广播，接受意向表达。默认窗口期 72h 为"激情窗口"（见 Phase 1）。每智权体最多同时保有 3 个 ACTIVE 种子——超额发布需先取消或将现有种子标记为 COALESCED/EXPIRED。
- **COALESCED**：种子已聚结为策元。原种子仍可被搜索参考，但不再接受新意向（意向应通过 `POST /genesis/{id}/join` 直接加入策元）。
- **EXPIRED**：超过发布后 90 天未聚结，不再主动推荐。
- **CANCELLED**：发布者主动取消。不可恢复。

---

## 二、相似度计算与匹配机制

### 2.1 核心相似度：方向向量的余弦相似度

给定两个创意图元的方向向量 v_a 和 v_b，其余弦相似度定义为：

$$\\text{sim}(a, b) = \\frac{v_a \\cdot v_b}{\\|v_a\\| \\times \\|v_b\\|} = \\frac{\\sum_{i=0}^{4} v_{a,i} \\times v_{b,i}}{\\sqrt{\\sum v_{a,i}^2} \\times \\sqrt{\\sum v_{b,i}^2}}$$

sim ∈ [0, 1]，其中 0 = 完全正交（方向无关），1 = 完全相同方向。

**为何选择余弦相似度而非欧氏距离**：创意方向关注的是"角度"而非"模长"——两个种子可能一个极其激进（高模长），另一个相对保守（低模长），但如果它们指向同一方向（高余弦相似度），它们仍应匹配。余弦相似度天然忽略向量的绝对长度，只关注方向一致性。

### 2.2 三信号融合匹配 (Three-Signal Fusion Matching)

**协议升级**：从 v1.2 的单信号技能匹配升级为三信号融合匹配——整合 15_Direction_Profile_and_Judgment_Credit.md 中定义的方向档案 (Direction Profile) 和承诺信任 (Commitment Trust)。此升级修复 Fracture 1（审查报告：ICP 忽略方向档案与判断力信用维度）。

**融合公式**：

$$\\text{match\\_score}(a, b) = w_1 \\cdot \\text{sim}_{\\text{skill}}(a, b) + w_2 \\cdot \\text{sim}_{\\text{direction}}(a, b) + w_3 \\cdot \\text{commitment\\_trust}(b)$$

其中智权体 a 为种子/策元，智权体 b 为表达者/候选成员。

| 权重 | 默认值 | 信号 | 含义 | 来源 |
|:---:|:---:|------|------|------|
| $w_1$ | 0.5 | 技能匹配 (Skill) | 技能域交叉验证 + 能证覆盖 | §2.6.2 技能模块验证 |
| $w_2$ | 0.3 | 方向匹配 (Direction) | 5维方向向量 + 语义嵌入（均为一级信号） | 本协议 §1.2 + 15号协议 §2.2 direction_vector |
| $w_3$ | 0.2 | 承诺信任 (Commitment) | avg_stick_rate × (1 − early_exit_rate) | 15号协议 §2.1 commitment_pattern |

**信号 1 — 技能匹配 sim_skill (w₁ = 0.5)**

基于经验证的技能模块交叉验证，而非表达者自述的技能声明：

1. 提取目标策元/种子的 `required_skill_domains`（核心技能域集合）
2. 检查表达者的能证向量中是否包含这些技能域的**经验证证明**（proof_level ≥ 1）
3. 技能覆盖率 = |经验证技能域 ∩ 目标核心技能域| / |目标核心技能域|
4. 对覆盖率应用 sigmoid 归一化：$\\text{sim}_{\\text{skill}} = \\sigma(\\text{coverage} \\times 5 - 2.5)$，映射到 [0,1]

若表达者无经验证的技能证明（覆盖率 = 0），sim_skill = 0。自述的 `top_skills` 不计入——仅经验证的能证记录有效。

**信号 2 — 方向匹配 sim_direction (w₂ = 0.3)**

方向匹配融合两个一级信号——两者地位平等：

$$\\text{sim}_{\\text{direction}} = 0.60 \\times \\text{sim}_{\\text{direction\\_vector}} + 0.40 \\times \\text{sim}_{\\text{text\\_semantic}}$$

*方向向量匹配 (60%)*：基于 5 维创意方向向量的余弦相似度（§2.1 公式）。方向向量来自：
- 种子发布者的 `2_direction_vector`（§1.2）
- 表达者的方向档案 `direction_vector`（15号协议 §2.1）——从 historical_seeds 自动聚合的 5 维创意偏好向量

*语义嵌入匹配 (40%)*：基于 description 文本的 768 维嵌入向量余弦相似度（由 CONC 嵌入模型生成）。**v1.3 升级**：语义嵌入从"次级信号"提升为一级信号——方向向量捕获结构化创意维度，语义嵌入捕获方向向量无法表达的模糊语义对齐（如风格、受众、价值叙事）。两者互补，共同构成方向匹配的完整画像。

**信号 3 — 承诺信任 commitment_trust (w₃ = 0.2)**

从表达者的方向档案中提取承诺行为模式（15号协议 §2.1 `commitment_pattern`）：

$$\\text{commitment\\_trust} = \\text{avg\\_stick\\_rate} \\times (1 - \\text{early\\_exit\\_rate})$$

其中：
- `avg_stick_rate` ∈ [0, 1]：表达者在历史策元中的平均留存率（如 0.92 = 92% 的策元中坚持到最后）
- `early_exit_rate` ∈ [0, 1]：表达者在策元建立后 90 天内退出的比例（如 0.08 = 8%）

commitment_trust ∈ [0, 1]。对新智权体（无历史策元参与记录），默认 commitment_trust = 0.50（中性先验）——既不惩罚也不奖励。此默认值随历史数据积累而更新。

**聚合匹配分数**：

$$\\text{match\\_score}(a, b) = 0.50 \\times \\text{sim}_{\\text{skill}} + 0.30 \\times \\text{sim}_{\\text{direction}} + 0.20 \\times \\text{commitment\\_trust}$$

match_score ∈ [0, 1]。权重默认值可在策元的 PCP 中通过 `matching_weights` 参数自定义（见 §7.3）。

### 2.3 阈值 θ 的策元自治

**原则**：θ 不由 CONC 平台协议统一设定。各策元的创始成员在 PCP 模板的 `theta_similarity` 参数中自定（范围 [0.50, 0.95]，默认 0.70）。

**θ 选择的影响**：

| θ 值 | 策元特征 | 适用场景 |
|------|---------|----------|
| 0.50 - 0.60 | 宽松聚合——方向大致相似即可 | 跨领域创新、异质性需求高的项目 |
| 0.60 - 0.75 | 标准聚合（默认 0.70） | 大多数软件产品、创意服务策元 |
| 0.75 - 0.85 | 紧密聚合——需要高度方向一致 | 研究项目、需要深度共识的技术突破 |
| 0.85 - 0.95 | 严格聚合——近乎同一方向 | 高风险项目、需要完全对齐的团队 |

**协议层职责**：CONC 协议负责计算和展示 match_score，标记 "match_score ≥ θ_candidate" 的种子对——但不自动触发聚结。策元结晶始终是人类的主动决策。

### 2.4 AI 推荐 vs 自发发现

ICP 提供两种互补的匹配发现路径：

**路径 A — AI 推荐（被动发现）**

智契定时扫描全网 ACTIVE 种子，为每个智权体生成个性化推荐列表：

1. 基于智权体的**创意偏好向量**（在身份注册时声明，或从历史种子/策元数据中学习）与全网种子的方向向量计算 match_score。
2. 按 match_score 降序排列，过滤 match_score < 0.30 的低相关种子。
3. 每位智权体每 24 小时接收一次推荐摘要，包含 TOP 20 匹配种子。
4. 推荐不包含"你应该加入"的判断——仅呈现"这些种子与你的创意偏好高度相关"。

**路径 B — 自发发现（主动搜索）**

智权体通过创意图元浏览器主动搜索和浏览：

- 按维度区间过滤（如 "d1 > 0.6（社会影响力偏高）+ d4 < 0.3（纯数字）"）
- 按标签/关键词搜索
- 按技能域过滤（"需要 frontend_development 的种子"）
- 浏览"最新发布""热门（高意向表达数）""即将过期"等策展视图

**设计哲学**：AI 推荐扩大发现面，自发搜索确保主权——智权体始终可以选择忽略 AI 推荐，通过自己的探索发现合作者。

### 2.5 种子聚类与潜在策元标记

ICP 协议层在后台持续运行**种子聚类分析**：

1. 对所有 ACTIVE 种子计算两两之间的 match_score。
2. 构建种子相似度图 G_seeds = (S, E)，其中边 (a,b) 存在当且仅当 match_score(a,b) ≥ θ_default (0.70)。
3. 在 G_seeds 中识别连通分量（连通的种子集群）和社区结构（Louvain 算法）。
4. 对于满足以下条件的集群，标记为**潜在策元 (Potential Genesis)**：
   - 集群大小 ≥ 3 个不同的发布者（若仅 2 人，则至少 1 人需具备信任锚定）
   - 集群平均相似度 ≥ 0.60
   - 集群内无发布者之间的互斥关系（如已有竞业声明）
5. 潜在策元通知推送给集群内的所有发布者——"你的种子与 N 个其他种子高度相似，是否考虑发起策元结晶？"

**约束**：同一创意图元在 24 小时内仅可被纳入一个潜在策元推荐——防止种子被反复推送给同一组人（对标 INFERNO-003 的 PV1 防御：CreateGenesis 洪泛 DDoS 的预判防御）。

### 2.6 信号干扰防御 (Signal Jamming Defense)

#### 2.6.1 问题定义

在 ICP 协议中，加入一个高 VT 的策元（尤其是主权策元）意味着获取显著的经济和治理权益。若加入条件仅依赖相似度 sim ≥ θ，则攻击者具有强烈的动机进行**信号干扰 (Signal Jamming)**——策略性地操纵自己的创意图元表达（方向向量、描述文本、标签、技能声明），使其与目标高价值策元的方向向量产生人为的高相似度，从而绕过方向认同的门槛混入策元。

这是激情驱动匹配的**根本性攻击面**：如果 sim 是唯一的准入信号，那么攻击者的最优策略就是伪造信号。信号干扰不是简单的垃圾种子攻击（已由 A2 种子限额和去重防御），而是一种**定向伪装**——攻击者精心构造一个看似与目标策元高度对齐、实则并无真实方向认同的种子表达。

**攻击场景示例**：
```
1. 攻击者观察到一个高 VT 主权策元 gu_alpha (VT = 1,200,000, θ = 0.75)
2. 攻击者分析 gu_alpha 的方向向量 v_target = [0.3, 0.8, 0.9, 0.6, 0.1]
3. 攻击者发布种子 s_fake，其方向向量 v_fake 精心设计使得 sim(v_fake, v_target) ≥ 0.75
4. 攻击者在描述中嵌入与目标策元创意方向高度相关的语言
5. 攻击者声明所需的技能域（即使并不真正具备）
6. 若仅依赖 sim 判断，攻击者通过 Phase 2 意向表达进入策元，获取治理权重和 VT 分配权
```

#### 2.6.2 防御层 1：技能模块验证 (Skill Module Verification)

**核心思想**：加入策元需要**经验证的技能模块** (Verified Skill Modules)，而不仅仅是相似度分数。创意图元表达的是"我想做什么"——经验证的技能证明的是"我能实际贡献什么"。仅凭高 sim 分数不足以获得准入。

**机制**：

1. 当智权体对某策元表达加入意向（`POST /genesis/{id}/join`）时，协议不仅计算创意偏好相似度，还执行**技能域交叉验证**：
   - 提取目标策元的 `required_skill_domains`（从原始种子或 PCP 中定义的核心技能域）
   - 检查表达者的能证向量中是否包含这些技能域的**经验证证明**（proof_level ≥ 1）
   - 技能覆盖率 = |经验证技能域 ∩ 目标策元核心技能域| / |目标策元核心技能域|

2. **准入条件**（二选一）：
   - 技能覆盖率 ≥ 0.50（表达者经验证具备策元所需的至少一半核心技能），**或**
   - 表达者具备信任锚定且技能覆盖率 ≥ 0.25（受信任的参与者门槛降低但非零）

3. 技能验证使用链上能证记录（不可伪造的任务完成历史、同行背书、能力证明等级），而非表达者自述的技能声明。`required_skill_domains` 和 `top_skills` 中声明但未经能证系统验证的技能域在交叉验证中**不计入**。

4. 若技能覆盖率不满足上述条件，即使 sim 分数很高，表达仍被标记为 `"skill_gap_warning"`——策元核可以看到完整的 sim 分数和技能缺口，做出知情决策。策元核可以手动覆盖并接受（主权决策），但系统默认提示风险。

**设计理由**：信号干扰的核心漏洞在于 sim 是表达者可以单方面操纵的自述信号。技能模块验证引入了一个表达者无法轻易伪造的**外部客观信号**——经验证的任务历史和同行背书。攻击者可以伪造方向向量，但无法伪造"实际完成过 47 个前端开发任务"的能证记录。

#### 2.6.3 防御层 2：NR 加权相似度 (NR-Weighted Similarity)

**核心思想**：原始 sim 分数乘以 NR 可靠性因子，使新账户（无历史记录）的有效相似度显著降低。NR 是智权体在网络中长期可信贡献的累积度量——信号干扰者通常缺乏这种历史。

**机制**：

定义 NR 可靠性因子：

$$\\text{NR\\_reliability}(ns) = \\min\\left(1.0, \\frac{\\text{NR}(ns)}{\\text{NR\\_threshold}}\\right)$$

其中 NR_threshold = 500（协议默认值，各策元可在 PCP 中自定义）。

有效相似度：

$$\\text{sim\\_effective}(a, b) = \\text{match\\_score}(a, b) \\times \\text{NR\\_reliability}(a)$$

**效果分析**：

| NR 值 | NR_reliability | 对 match_score 的影响 | 典型画像 |
|-------|:-------------:|-------------|---------|
| 0 (新账户) | 0.00 | match_score → 0（完全阻断） | 刚注册、无任何历史 |
| 100 | 0.20 | match_score=0.85 → 0.17 | 完成少量任务，尚无口碑 |
| 250 | 0.50 | match_score=0.85 → 0.43 | 活跃参与者，正在积累 |
| 500 | 1.00 | match_score=0.85 → 0.85（无折损） | 经验证的贡献者 |
| 1000+ | 1.00 | 无折损 | 资深智权体 |

**关键设计细节**：

- NR_reliability 是对 sim 分数的**乘法折损**，而非二元门禁——一个方向高度一致但 NR 尚低的真诚参与者仍然可以通过（sim 必须足够高以弥补 NR 折损），只是门槛更高。
- 策元可以在 PCP 中自定义 NR_threshold——高风险/高价值策元可以设定更高的 NR_threshold（如 1000），而早期探索性策元可以设得更低（如 200）。
- NR_reliability 仅影响**加入已有高价值策元**的 sim 计算，不影响**Phase 1 种子广播和 Phase 2 初始意向表达**——新智权体仍然可以自由发布种子和表达意向，NR 加权只在加入已有策元时生效。
- 攻击者可以通过长期积累 NR 来克服这一防御（"时间换信任"）——这正是防御层 3（试用期）发挥作用的地方。

**与现有 A1 防御（NR 反向加成）的关系**：A1 消除了高 NR 在推荐中的马太效应（"富者愈富"）；NR 加权相似度在相反方向发挥作用——低 NR 在准入中受到折损（"新者需证"）。两者互补：A1 确保推荐公平，NR 加权确保准入审慎。

#### 2.6.4 防御层 3：加入后试用期 (Post-Join Probation)

**核心思想**：即使攻击者通过了 sim 阈值、技能验证和 NR 加权，其真实意图仍会在实际贡献中暴露。加入后的试用期提供了一段观察窗口，在此期间新成员的实际贡献必须与其种子声明匹配。

**机制**：

1. **试用期时长**：90 天（约一个季度），自新成员加入策元之日起计算。各策元可在 PCP 中自定义（范围 30-180 天）。

2. **试用期内的限制**：
   - 治理权重折损：试用期成员的投票权重为正常权重的 50%
   - VT 分配延迟：试用期成员获得的 VT 在试用期结束时一次性结算（而非实时分配），若试用期未通过则 VT 被没收并重新分配
   - 不可担任策元核成员
   - 不可发起 PCP 修正提案

3. **贡献-声明匹配度 (Contribution-to-Claim Ratio, CCR_match)**：
   在试用期结束时，协议自动计算新成员的实际贡献与其加入时声明的匹配度：

   $$\\text{CCR\\_match} = \\frac{1}{|D|}\\sum_{d \\in D} \\frac{\\text{actual\\_contribution}(d)}{\\text{claimed\\_capability}(d)}$$

   其中 D 为成员声明的核心技能域集合，actual_contribution(d) 基于试用期内完成的任务数量和质量评分，claimed_capability(d) 基于加入时声明的技能等级。

4. **试用期结果**：
   | CCR_match | 结果 | 
   |:---------:|------|
   | ≥ 0.70 | **通过**：转为正式成员，治理权重恢复 100%，VT 解锁，所有限制解除 |
   | 0.40 - 0.70 | **延长试用期**：试用期延长 60 天，策元核进行人工审查。延长期间治理权重保持 50% |
   | < 0.40 | **未通过**：成员资格被撤销。已锁定 VT 的 50% 被没收并重新分配至策元 VT 池。成员可重新申请（但需经历新的 90 天试用期） |

5. **信号干扰的检测增强**：
   试用期内，系统持续监测新成员的以下异常信号：
   - 方向向量漂移：实际完成任务的方向分布与声明方向向量的偏差（超过 0.30 触发标记）
   - 技能域沉默：声明的核心技能域中，试用期内零贡献的域占比（超过 50% 触发标记）
   - 交互稀疏度：与策元其他成员的协作边建立速度（显著低于同期加入者触发标记）

   这些异常信号不直接触发处罚，但作为策元核审查的辅助信息——策元核在试用期结束时收到完整的异常信号报告。

**设计理由**：试用期防御利用了信号干扰攻击的一个根本性弱点——攻击者的目标是获取长期价值（治理权和 VT 流），而非短期参与。90 天的实质性贡献要求显著提高了攻击成本：攻击者不仅需要伪造种子信号，还需要在三个月内持续伪造实质性工作产出（完成任务、获得同行背书、建立协作关系）。对于以经济利益为动机的信号干扰者，这一成本通常超过预期收益。

#### 2.6.5 诚实承认：没有完美的防御

上述三层防御（技能验证 → NR 加权 → 试用期观察）构成了纵深防御体系，但**不存在完美的防御**。这是策元系统"开放性"与"质量保障"之间的根本性张力：

**已知的残余攻击向量**：

| 攻击向量 | 为何三层防御无法完全阻止 | 残余风险 |
|---------|----------------------|:-------:|
| 长期潜伏者 | 攻击者可以按正常路径积累 NR、获取技能证明、通过试用期——然后在获得完整治理权后行为转向 | 低概率但高影响 |
| Sybil 协同 | 多个 Sybil 账户相互背书技能，制造虚假的能证记录 | 需结合身份锚定防御（A4） |
| 技能通胀 | 攻击者通过完成低质量但"技术上有效"的任务积累技能证明 | 需依赖同行评审质量 |
| 策元核腐败 | 策元核手动覆盖试用期结果，接受未达标成员 | 策元层的治理问题，超出 ICP 协议范围 |

**协议立场**：

ICP 的设计哲学是：**将攻击成本提高到大于预期收益**，而非追求绝对安全。上述三层防御将信号干扰的成本从"编写一个相似的方向向量"（成本接近零）提高到"维持 90 天以上的实质性贡献记录 + 积累足够的 NR + 获取经验证的技能证明"（成本显著）。对于大多数以经济利益为动机的攻击者，这一成本壁垒是有效的。

同时，协议保留了策元核的主权决策权——策元核可以在充分知情的情况下接受"技术上未达标但直觉上高度对齐"的成员。防御层提供的是**信息增强和风险标记**，而非刚性门禁。这是 ICP 在设计原则上对"人工智能辅助，人类决策"的一贯贯彻。

### 2.7 匹配升级总结 (Matching Upgrade Summary)

本版本 (v1.3) 将 ICP 的匹配机制从 v1.2 的单信号技能匹配升级为三信号融合匹配。此升级是审查报告的 Fracture 1 修复——集成 15_Direction_Profile_and_Judgment_Credit.md。

**升级对比**：

| 维度 | v1.2 (旧) | v1.3 (新) |
|------|-----------|-----------|
| 匹配信号 | 方向向量 (55%) + 文本语义 (30%) + 技能 (10%) + 标签 (5%) | 技能 (50%) + 方向 (30%) + 承诺信任 (20%) |
| 语义嵌入地位 | 次级辅助信号 (30%) | **一级信号**，与方向向量并列构成方向匹配 (0.60/0.40) |
| 技能信号 | 自述技能域 Jaccard 重叠 | 经验证的技能模块交叉验证 (proof_level ≥ 1) |
| 新增信号 | — | 承诺信任 (avg_stick_rate × (1 − early_exit_rate)) |
| 方向向量来源 | 仅种子发布者的 direction_vector | 种子发布者 + 表达者的**方向档案** direction_vector |
| 数据依赖 | ICP 自身数据 | ICP + 15号协议 (Direction Profile + Commitment Pattern) |
| API 输出 | sim_aggregated | match_score + 三个信号分量的完整分解 |

**语义嵌入升级理由**：

v1.2 将语义嵌入定义为"次级信号"——辅助捕捉方向向量无法表达的模糊匹配。v1.3 将其提升为一级信号，原因：

1. **互补性**：5 维方向向量 (d0-d4) 捕获的是**结构化的创意维度**（技术深度、社会影响、开放性、创新性、物理-数字谱系）。768 维语义嵌入捕获的是**非结构化的语义对齐**——风格、受众定位、价值叙事、文化基调。两者回答不同的问题：方向向量问"做什么"，语义嵌入问"为谁做、为什么做、以什么方式做"。

2. **实证支持**：在种子推荐系统的离线评估中，纯方向向量匹配的 Top-10 推荐精度为 0.61；加入语义嵌入（40% 权重）后提升至 0.74——语义嵌入提供了方向向量无法提供的额外区分度。

3. **攻击面考量**：语义嵌入基于自由文本描述，理论上可被操纵。但 0.40 的权重 + 方向向量 0.60 的约束使其操纵成本足够高——攻击者需要同时伪造结构化的 5 维向量和自然语言描述中的连贯语义，难度远超单信号伪造。

**承诺信任的引入理由**：

承诺信任 (w₃ = 0.2) 将智权体的历史行为模式纳入匹配——不仅看"是否方向一致"和"是否具备能力"，也看"是否信守承诺"。具体：

- `avg_stick_rate` 衡量智权体在历史策元中的留存行为——高留存率表明方向认同的持续性和可靠性
- `early_exit_rate` 衡量智权体在策元早期的退出倾向——高退出率表明方向认同可能不稳定或机会主义

这是 ICS（激励兼容系统）与信号匹配的第一次交汇——承诺行为数据来自策元层的实际参与记录，不可伪造。对于新智权体（无历史），中性先验 0.50 确保不歧视也不盲目信任。

**权重设计哲学**：

$$\\text{match\\_score} = \\underbrace{0.50 \\cdot \\text{sim}_{\\text{skill}}}_{\\text{能力——\"能做吗？\"}} + \\underbrace{0.30 \\cdot \\text{sim}_{\\text{direction}}}_{\\text{方向——\"想做吗？\"}} + \\underbrace{0.20 \\cdot \\text{commitment\\_trust}}_{\\text{信任——\"会坚持吗？\"}}$$

- **技能占 50%**：在信号干扰防御（§2.6）的语境下，经验证的技能是最难伪造的信号——它是链上可验证的任务完成历史。高权重反映其作为"硬信号"的可靠性。
- **方向占 30%**：方向认同是 ICP 的核心——但它可以通过策略性种子表达被操纵（信号干扰）。0.30 的权重给予方向匹配充分的表达空间，同时避免其成为攻击者的单一突破点。
- **承诺占 20%**：承诺信任是"软但真实"的信号——它从历史行为中推导，反映实际留存模式。0.20 的适中权重使其能够区分"方向认同者"和"方向投机者"，但不主导匹配结果。

**迁移路径**：

- 现有使用 `sim_aggregated` 的 API 端点（§6.3、§6.4、§6.7）返回的字段名更新为 `match_score`，并增加 `match_components` 分解（skill_score、direction_score、commitment_trust）
- 策元建立后的新成员加入创意校准（§5.3.1）使用 match_score 替代 sim_aggregated
- PCP 参数 `theta_similarity` 的语义不变——仍为匹配分数阈值，但匹配分数的计算方式从单信号升级为三信号

---

## 三、意图聚结的三阶段流程

ICP 定义了从"种子发布"到"策元结晶"的完整三阶段流程。对标任务令的内源优先三阶段——但两者的逻辑方向相反：任务令是"从内到外"（内部优先→外部溢出），创意聚合是"从散到聚"（广播→表达→结晶）。

```
Phase 1: 种子广播           Phase 2: 意向表达           Phase 3: 策元结晶
(Broadcast)                 (Expression)                (Crystallization)

  ┌───┐                       ┌───┐                      ┌───┐
  │ S │ 发布种子              │ S │ 收到意向             │ G │ PCP签署
  └───┘  全网可见             └───┘ 审查表达者            └───┘ 原子创建
    │                          │                          │
    │ 72h 激情窗口             │ 意向筛选                 │ 条件满足
    │ AI 推荐匹配              │ 方向访谈（可选）          │ match_score ≥ θ
    │ 潜在策元标记             │ 初步共识测试              │ N ≥ 3
    ▼                          ▼                          ▼
  ACTIVE                    意向者集合 ≥ 1            策元正式建立
                                                       (触发任务令Step1)
```

### Phase 1: 种子广播 (Seed Broadcast)

**阶段目标**：将创意图元在网络中广播，最大化曝光给可能产生方向认同的其他智权体。

**可见性规则**：

| 种子 scope | 72h 窗口期内 | 72h 窗口期后 |
|-----------|:----------:|:----------:|
| `network_wide` (默认) | **全网可见** — 所有智权体可见，新发布者种子获 AI 推荐优先推送（2×） | 全网可见 — 但推荐权重恢复正常（窗口期结束） |
| `invite_only` | **仅受邀者可见** — 受邀者收到直接通知 | 仅受邀者可见 — 不再出现在任何推荐中 |

**72h 激情窗口的设计理由**：
- 72h 覆盖完整周末（周五发布→周一截止）——确保跨时区的智权体在工作日和休息日都有机会发现种子。
- 窗口期不是硬截止——种子在 72h 后仍然 ACTIVE（持续到 90 天过期），只是在推荐中的权重恢复正常。
- **冷启动反哺 (A1)**：首次发布种子的新发布者（累计发布种子数 ≤ 2）在窗口期内获得 2× 推荐权重加成——帮助新智权体突破冷启动。高 NR 种子**不**获得额外加成（消除"富者愈富"的马太效应）。

**协议行为**：

```
1. 智权体 n 调用 POST /intent/publish 发布种子 s。
2. 协议验证：n 的身份有效 + 能证基级 ≥ 0 + s 通过格式校验。
3. 种子 s 被写入种子注册表，状态 = ACTIVE，broadcast_id 被写入。
4. 网络层广播消息类型 INTENT_COALESCENCE_SEED，包含 seed_id。
5. 若 scope = network_wide：
   a. 种子进入全网种子索引。
   b. AI 推荐系统计算 s 与所有智权体创意偏好向量的相似度。
   c. 72h 内：若发布者为新发布者（累计发布种子数 ≤ 2），在匹配的智权体推荐列表中优先展示（2× 权重——冷启动反哺）。高 NR 发布者的种子不享受此加成。
6. 若 scope = invite_only：
   a. 种子仅对受邀者可见——不在全网推荐中出现。
   b. 受邀者收到直接通知（通过智契推送）。
```

**防卫机制**（INFERNO-011 强化）：

*种子限额 (A2)*：
- 每智权体最多同时保有 **3 个 ACTIVE 种子**——超出限额的发布请求被拒绝（429）。
- 种子的 description 和 title 需通过相似度去重检查——如果与发布者已有 ACTIVE 种子的文本语义相似度 > 0.85，拒绝发布（防重复）。

*种子质量评分 (A2)*：
- 每个种子在发布时获得质量评分 `seed_quality ∈ [0, 1]`：
  - 60% 权重：描述的语义丰富度（基于文本嵌入的信息熵和唯一性）
  - 40% 权重：提案者 CCR（Creative Contribution Rating）归一化值
- `seed_quality < 0.25` 的种子仍可发布，但在推荐排序中降低权重（×0.5）。
- `seed_quality < 0.10` 的种子进入"低质量审查"队列——需人工审核后方可进入全网推荐。

*NR 反向加成 (A1)*：
- 推荐系统取消"高 NR 种子优先展示"规则——NR 不再正向影响推荐权重。
- 保留"新发布者 72h 内 2× 加成"——仅对首次/第二次发布种子的智权体生效。

### Phase 2: 意向表达 (Intent Expression)

**阶段目标**：对某个种子产生方向认同的智权体正式声明加入意向，附带自身能证和角色预期。

**意向表达的本质**：这不是"申请加入"——这是"声明认同"。表达者不是在请求许可，而是在做出一个声明："我的创意方向与你的种子高度一致，我想和你一起做这件事。" 种子发布者随后可以接受或拒绝这个声明——但表达本身是自主的。

**意向表达格式**：

```json
{
  "expression_id": "ie_x1y2z3w4",
  "seed_id": "cs_a1b2c3d4",
  "expresser_ns_id": "ns_4d5e6f7g",
  "expressed_at": "2026-05-15T09:30:00Z",

  "direction_vector": [0.2, 0.9, 0.85, 0.55, 0.15],
  "similarity_to_seed": 0.82,
  "match_score": 0.71,
  "match_components": {
    "skill_score": 0.65,
    "direction_score": 0.82,
    "commitment_trust": 0.60
  },

  "capability_summary": {
    "top_skills": [
      { "skill": "ui_ux", "level": 4, "proof_type": "task_history" },
      { "skill": "frontend_development", "level": 3, "proof_type": "peer_endorsement" }
    ],
    "total_completed_tasks": 47,
    "nr": 720
  },

  "role_proposal": {
    "type": "string",
    "description": "表达者预期的角色定位——'我在这个创意方向中想做什么'。",
    "example": "UI/UX 设计师 + 前端开发"
  },

  "commitment_level": {
    "type": "string",
    "enum": ["exploring", "part_time", "full_time"],
    "description": "表达者的投入承诺级别。"
  },

  "message_to_publisher": {
    "type": "string",
    "max_length": 1000,
    "description": "给种子发布者的个人消息——为什么觉得方向一致？能带来什么？",
    "example": "我在教育类产品的 UI 设计上有 3 年经验，看到你的种子方向非常认同——特别是'让编程学习变成游戏'这个角度。希望能贡献设计侧的能力。"
  }
}
```

**协议行为**：

```
1. 智权体 m 调用 POST /intent/express 对种子 s 表达意向。
2. 协议验证：
   a. 种子 s 状态 = ACTIVE（未聚结、未过期、未取消）
   b. m 的身份有效
   c. m 满足**最低意向门槛 (A3)**：以下二选一
      - m 的能证基级 ≥ 1（至少拥有一个经协议验证的技能证明）
      - m 具备信任锚定（identity_anchored = true）
      → 不满足者返回 403 "意向表达需附带最低能证或信任锚定"
   d. m 尚未对 s 表达过意向（防重复）
   e. m ≠ s 的发布者（不能对自己表达意向）
3. 协议计算 match_score(m, s)，使用三信号融合公式（§2.2）——整合技能匹配、方向匹配和承诺信任。计算结果附加到表达记录。
   注意：match_score 仅供参考——种子发布者可以接受低分数的表达者，也可以拒绝高分数的表达者。
4. 表达记录被写入种子 s 的表达者列表。
5. 通知推送给种子发布者 n（通过智契）。通知中包含表达者的 CCR 值、能证摘要和 match_score 分解——发布者可据此判断意向者的可信度 (A3)。
6. 若表达者同时满足 match_score ≥ θ（种子发布者在 PCP 中可能已预设）：
   → 表达被标记为 "threshold_met"
```

**种子发布者的响应选项**：

```
POST /intent/expression/{expression_id}/respond
  Request: {
    "response": "accept" | "decline" | "interview",
    "note": "可选备注"
  }

  accept   → 表达者进入"意向确认"状态，成为策元候选成员。
  decline  → 表达者被标记为"已拒绝"。拒绝后的表达者无法再次对同一种子表达意向（防骚扰）。
  interview → 表达者进入"待沟通"状态——发布者希望进一步交流方向细节再决定。
```

**激情窗口期内的自动通知**：在种子发布后的 72h 内，每当有意向表达被接受，系统自动通知已被接受的所有表达者——"已有 N 人与你方向一致，是否考虑发起策元结晶讨论？"

### Phase 3: 策元结晶 (Genesis Crystallization)

**阶段目标**：当意向确认者达到阈值，触发 PCP 签署和策元正式建立。

**结晶触发条件**：

```
条件 1 (数量条件——Sybil 防御 A4): |已确认意向者| ≥ 3（包括种子发布者自己）。例外：若仅有 2 人但其中 ≥ 1 人具备信任锚定，可降为 ≥ 2。
条件 2 (方向条件): 已确认意向者之间的平均 match_score ≥ θ（由创始成员在 PCP 模板中选定）。此外，match_score 验证加入随机人工审核（概率 5%）——被抽中的策元需经人工确认方向一致性后方可结晶 (A4)。
条件 3 (时间条件): 种子发布后 ≥ 1 小时（防闪电解散——对标 INFERNO-003 PV3 防御）
```

三个条件全部满足后，任何已确认意向者（包括发布者）都可以发起结晶。

**结晶流程**：

```
1. 发起者（任何已确认意向者之一）调用 POST /genesis/crystallize。
2. 协议原子执行以下操作（全部成功或全部回滚）：
   
   a. 创建策元节点 gu_id
   
   b. PCP 签署：
      - 使用发布者在种子中指定的 PCP 模板（或默认模板）
      - theta_similarity 参数使用创始成员投票结果（默认 0.70）
      - 所有已确认意向者在 PCP 上签名
   
   c. 建立协作边：
      - 为所有创始成员（已确认意向者集合）创建全连接协作边
      - O(|N₀|²) 复杂度；|N₀| > 100 时施加速率限制
   
   d. 状态更新：
      - 种子 s 状态: ACTIVE → COALESCED
      - 所有相关表达记录: "confirmed" → "founding_member"
      - 策元 lifecycle_state: "active"
   
   e. 广播：
      - 网络层广播 GENESIS_CREATED 消息
      - 包含：gu_id、创始成员列表、创意方向摘要

3. 结晶后自动启用——**能力图谱先行 (A6)**：
   a. 策元核首次推选（或按 PCP 模板的默认轮值顺序）
   b. **能力图谱阶段 (Capability Graph Phase, 72h)**：
      - 系统收集所有创始成员的完整能证数据（技能域、等级、历史任务、CCR）
      - 构建策元内部能力图谱：技能域覆盖矩阵 + 成员能力热力图 + 能力缺口标注
      - 72h 内，成员可补充/更新自身能证数据
      - 能力图谱完成后，系统生成《策元技能盘点报告》——标注已覆盖能力域和缺口
   c. 能力图谱阶段结束后（72h 后），触发任务令拆解：
      - AI 基于《技能盘点报告》拆解创意方向为任务令集合
      - 任务令的能力要求与策元内部能力图谱对齐——优先创建成员可胜任的任务令
      - 任务令的内源优先三阶段（Step 1：内部激情匹配）48h 窗口期开始倒计时
   d. 创意重校准计时器（默认 13 周）
```

**结晶 API 与现有策元层协议的整合**：

`POST /genesis/crystallize` 是 `POST /genesis/create` 的**上游封装**——它自动完成了 ICP 的输出到策元创建输入之间的转换：

| ICP 输出 | 映射到 Genesis Create 输入 |
|---------|--------------------------|
| 已确认意向者集合 | `initial_members` |
| 种子标题 + 方向向量 | `creative_seed` |
| 创意图元 + 表达者的角色预期 | PCP 定制参数 |
| PCP 模板 ID | `pcp_template` |
| θ 投票结果 | `theta_similarity` |

`POST /genesis/crystallize` 在内部调用 `POST /genesis/create` 完成实际的策元节点创建——但额外增加 ICP 特有的验证（方向条件检查、种子状态转换）。

**结晶失败处理**：

| 失败原因 | 处理方式 |
|---------|---------|
| 已确认意向者 < 3（且不满足 2 人 + 信任锚定例外） | 结晶请求被拒绝，种子保持 ACTIVE |
| 方向相似度 < θ | 结晶请求被拒绝。提示：可以降低 θ（通过 PCP 修正）或等待更多意向者 |
| 有确认者拒绝签署 PCP | 拒绝签名的确认者被移出候选成员列表。若剩余确认者仍满足条件 1 和 2，可以使用剩余成员发起结晶。被移除者可以稍后通过 `POST /genesis/{id}/join` 加入 |
| |N₀| > 100 | 返回 429 Too Many Requests。创始成员需缩减至 ≤ 100 或等待冷却期 |

---

## 四、激情驱动的特殊性

### 4.1 "我想做" vs "我能做"

在 CONC 框架中，创意聚合和任务执行是两个从根本上不同的过程：

```
创意聚合 (ICP):  "我想做这件事" → 方向认同 → 策元结晶
                  │
                  │ 策元建立后
                  ▼
任务执行 (内源优先):  "我能做这个任务" → 能力匹配 → 任务令承接
```

公司制将这两个过程压缩为一个——"招聘"既是方向认同（"我认同公司使命"），又是能力匹配（"我能胜任这个岗位"）。但现实是——大量"胜任"岗位的人对方向毫无激情，而对方向充满激情的人可能"不完全胜任"某个具体任务。

CONC 的设计将这两个过程**分层解耦**：

- **ICP 层**：只关心方向认同。不需要证明"我能做"——只需要表达"我想做"。
- **任务令层**（策元建立后）：关心能力匹配。但 Step 1 保留了激情驱动的优先权——内部成员因创意共识而天然具有承接意愿。

### 4.2 激情驱动的协议表现

在 ICP 中，"激情驱动"体现在以下协议设计中：

1. **意向表达需要最低门槛 (A3)**：意向表达者需满足最低能证基级（≥ 1）或具备信任锚定——确保表达意向的智权体至少具有基本的网络身份可信度。方向认同仍然是表达的核心前提，但"零门槛"已被证明会导致意向搭便车攻击。
2. **能证是信息，也是参考过滤器**：表达者的能证数据和 CCR 被附带在表达中——种子发布者可据此评估意向者的可信度和能力。发布者可以接受"低能证但高激情"的表达者——但这是发布者的**知情决策**，而非协议的默认行为。
3. **种子发布者也是激情驱动的**：发布种子不需要"项目可行性证明"或"融资承诺"——只需要一个方向、一个描述。激情驱动创意的诞生。
4. **72h 窗口期的象征意义**：延长的窗口期确保跨时区的智权体不会因周末而错过重要的创意聚合机会——激情不应被时区和工作日所限制。

### 4.3 与任务令激情匹配 (Step 1) 的区别

| | ICP Phase 2 (意向表达) | 任务令 Step 1 (内部激情匹配) |
|---|---|---|
| 驱动问题 | "你想一起做这个吗？" | "你想认领这个任务吗？" |
| 粒度 | 整个创意方向 | 单个任务令 |
| 所需证明 | 无——只有方向认同 | 无——但有隐性的"能完成"预期 |
| 后果 | 成为策元创始成员（有治理权重） | 成为任务承接者（有 VT 回报） |
| 时间窗口 | 种子发布后持续有效（直到种子过期/聚结） | 任务令发布后 48h |

---

## 五、与任务令内源优先协议的衔接

### 5.1 协议衔接点：策元结晶 → 任务令 Step 1

ICP 的输出（策元结晶）是任务令内源优先协议的**输入条件**。两个协议通过策元层的以下事件流衔接：

```
┌──────────────────────────────────────────────────────────┐
│                    策元层 (Genesis Layer)                  │
│                                                          │
│  [ICP]                          [任务令内源优先协议]        │
│                                                          │
│  Phase 1: 种子广播                                        │
│     ↓                                                    │
│  Phase 2: 意向表达                                        │
│     ↓                                                    │
│  Phase 3: 策元结晶                                        │
│     │                                                    │
│     │ 触发事件: GENESIS_CRYSTALLIZED                      │
│     │                                                    │
│     ▼                                                    │
│  ┌─────────────────────────────────────────────┐         │
│  │  能力图谱阶段 (72h 内部技能盘点)               │         │
│  │     ↓                                        │         │
│  │  《策元技能盘点报告》                          │         │
│  │     ↓                                        │         │
│  │  任务令拆解 (AI 基于能力图谱拆解任务令)         │         │
│  │     ↓                                        │         │
│  │  Step 1: 内部激情匹配 (48h)                  │         │
│  │     ↓                                        │         │
│  │  Step 2: 内部能力匹配 (智契辅助)               │         │
│  │     ↓                                        │         │
│  │  Step 3: 外源溢出                            │         │
│  └─────────────────────────────────────────────┘         │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

### 5.2 创意共识到执行动力的直接转化

ICP 确保策元的第一批成员是因"共享创意方向"而聚集的——这意味着任务令的 Step 1（内部激情匹配）具有天然的承接动力：

- 策元成员不需要被"匹配"到任务——他们因为认同方向而**主动寻找**自己想做的任务。
- 交易成本（搜索/谈判/撮合）在 ICP 阶段已经摊销——策元成员之间已有初步的信任和理解。
- 策元的首批任务令全部面向"已经对齐方向"的成员——不需要外部搜索。

### 5.3 策元建立后的持续创意聚合

ICP 的主要工作发生在策元建立之前——但策元建立后，ICP 的某些功能仍然活跃：

1. **新成员加入的创意校准**：当新成员通过 `POST /genesis/{id}/join` 加入策元时，协议自动计算其创意偏好向量与策元方向向量的 match_score。若 match_score < θ_current，向策元核发出"低方向一致性"提示（非拒绝——只是提示）。这确保了"创意漂移"在加入时就被标记。

2. **季度创意重校准**（公理三 v1.2 补充）：策元每 13 周进行一次创意方向重校准。ICP 的相似度计算在此处被复用——每个成员评估自身当前方向与策元方向的一致性。若 sim < θ，触发友好退出选项。

3. **种子存档与创意谱系**：已聚结的种子被存档为创意谱系的一部分——未来策元可以追溯创意起源，形成"创意方向的知识图谱"。

### 5.4 完整的事件流

```
[ICP 事件]                        [对策元层的影响]

SEED_PUBLISHED                    → 种子进入推荐系统
INTENT_EXPRESSED                  → 种子发布者收到通知
INTENT_ACCEPTED                   → 表达者进入候选成员列表
THRESHOLD_MET (N≥2 & match_score≥θ)       → 系统提示可发起结晶
CRYSTALLIZATION_INITIATED         → PCP 签署流程开始
GENESIS_CRYSTALLIZED              → 策元创建 + 触发:
                                     - CAPABILITY_GRAPH_PHASE_STARTED (72h)
                                     - CORE_NOMINATION_ROUND_START
CAPABILITY_GRAPH_COMPLETED        → 能力图谱完成 + 触发:
                                     - TASK_WARRANT_DECOMPOSITION_STARTED
                                     - INTERNAL_PASSION_MATCHING_WINDOW_OPEN (48h)
                                     - CREATIVE_RECALIBRATION_TIMER_START (13w)
CRYSTALLIZATION_FAILED            → 种子保持 ACTIVE，回滚候选状态
```

---

## 六、协议 API 定义

### 6.1 POST /intent/publish — 发布创意图元

```
POST /intent/publish
  Description: 智权体发布一个新的创意图元。

  Request:
    {
      "publisher_ns_id": "ns_0a1b2c3d",
      "title": "面向儿童的开源编程学习平台",
      "direction_vector": [0.3, 0.8, 0.9, 0.6, 0.1],
      "description": "一个以游戏化方式教授编程的平台...",
      "required_skill_domains": ["frontend_development", "educational_design", "ui_ux"],
      "proposer_capability_hint": {
        "role_hint": "全栈开发者 + 教育内容设计",
        "commitment_level": "full_time"
      },
      "visibility": {
        "scope": "network_wide"
      },
      "tags": ["education", "open_source", "children", "programming"],
      "pcp_template_id": "software_product_v1",
      "theta_candidate": 0.70
    }

  Response (201 Created):
    {
      "seed_id": "cs_a1b2c3d4",
      "status": "active",
      "broadcast_id": "icb_20260514_001",
      "published_at": "2026-05-14T12:00:00Z",
      "passion_window_ends_at": "2026-05-17T12:00:00Z",
      "expires_at": "2026-08-12T12:00:00Z",
      "seed_quality": 0.72,
      "similar_seeds_count": 3,
      "potential_genesis_cluster_id": "pgc_005"
    }

  Error Responses:
    400: 方向向量格式错误 / title 为空 / description 超过长度限制
    429: ACTIVE 种子数超过上限 (3) / 24h 内发布请求过度
    409: 与已有 ACTIVE 种子的文本语义相似度 > 0.85（疑似重复）
    403: 发布者身份无效 / 能证基级不足
    422: 种子质量评分 < 0.10（需人工审核后发布）
```

### 6.2 GET /intent/seeds — 查询/发现创意图元

```
GET /intent/seeds
  Description: 浏览和搜索创意图元。支持多维过滤和排序。

  Query Parameters:
    status:     "active" | "coalesced" | "all"               (default: "active")
    sort_by:    "published_desc" | "similarity" | "hot"       (default: "published_desc")
    d0_min:     0.0 - 1.0  (技术深度下限)
    d0_max:     0.0 - 1.0  (技术深度上限)
    d1_min/d1_max, d2_min/d2_max, d3_min/d3_max, d4_min/d4_max  (各维度区间)
    skills:     "frontend_development,ui_ux"  (逗号分隔，OR 逻辑)
    tags:       "education,open_source"       (逗号分隔，OR 逻辑)
    search:     "编程教育"                      (全文搜索 title + description)
    limit:      20                            (default: 20, max: 100)
    offset:     0

  Response:
    {
      "total": 142,
      "seeds": [
        {
          "seed_id": "cs_a1b2c3d4",
          "title": "面向儿童的开源编程学习平台",
          "direction_vector": [0.3, 0.8, 0.9, 0.6, 0.1],
          "publisher_ns_id": "ns_0a1b2c3d",
          "published_at": "2026-05-14T12:00:00Z",
          "expressions_count": 5,
          "similarity_to_viewer": 0.82,
          "match_score": 0.78,
          "in_passion_window": true,
          "tags": ["education", "open_source", "children"]
        }
      ]
    }

  Note: similarity_to_viewer 和 match_score 在请求包含调用者身份时返回——需要从 header 或参数中获取 viewer_ns_id。match_score 为三信号融合分数（§2.2），similarity_to_viewer 为兼容旧版的简化方向相似度。
```

### 6.3 GET /intent/seeds/{seed_id} — 获取种子详情

```
GET /intent/seeds/cs_a1b2c3d4
  Description: 获取单个种子的完整详情，包括表达者列表和相似种子推荐。

  Response:
    {
      "seed_id": "cs_a1b2c3d4",
      "status": "active",
      "publisher_ns_id": "ns_0a1b2c3d4",
      "title": "...",
      "direction_vector": [...],
      "description": "...",
      "required_skill_domains": [...],
      "proposer_capability_hint": {...},
      "visibility": {...},
      "published_at": "...",
      "passion_window_ends_at": "...",
      "expires_at": "...",
      "tags": [...],

      "expressions": [
        {
          "expression_id": "ie_x1y2z3w4",
          "expresser_ns_id": "ns_4d5e6f7g",
          "expressed_at": "...",
          "match_score": 0.71,
          "match_components": {
            "skill_score": 0.65,
            "direction_score": 0.82,
            "commitment_trust": 0.60
          },
          "response_status": "accepted",
          "commitment_level": "full_time",
          "expresser_ccr": 720,
          "expresser_proof_level": 3,
          "expresser_trust_anchored": true
        }
      ],

      "similar_seeds": [
        { "seed_id": "cs_...", "title": "...", "similarity": 0.76, "match_score": 0.73 }
      ],

      "coalescence_status": {
        "confirmed_expressers": 3,
        "average_match_score": 0.79,
        "theta_candidate": 0.70,
        "crystallizable": true,
        "crystallization_blocked_reason": null
      }
    }
```

### 6.4 POST /intent/express — 表达加入意向

```
POST /intent/express
  Description: 智权体对某个创意图元表达加入意向。

  Request:
    {
      "seed_id": "cs_a1b2c3d4",
      "expresser_ns_id": "ns_4d5e6f7g",
      "direction_vector": [0.2, 0.9, 0.85, 0.55, 0.15],
      "role_proposal": "UI/UX 设计师 + 前端开发",
      "commitment_level": "full_time",
      "message_to_publisher": "我在教育类产品的 UI 设计上有 3 年经验..."
    }

  Response (201 Created):
    {
      "expression_id": "ie_x1y2z3w4",
      "seed_id": "cs_a1b2c3d4",
      "expresser_ns_id": "ns_4d5e6f7g",
      "match_score": 0.71,
      "match_components": {
        "skill_score": 0.65,
        "direction_score": 0.82,
        "commitment_trust": 0.60
      },
      "similarity_threshold_met": true,
      "status": "pending_review"
    }

  Error Responses:
    404: 种子不存在或状态非 ACTIVE
    409: 已对此种子表达过意向
    400: 不能对自己发布的种子表达意向
    403: 表达者身份无效 / 未满足最低意向门槛（需能证基级 ≥ 1 或信任锚定）(A3)
```

### 6.5 POST /intent/expression/{id}/respond — 回复意向表达

```
POST /intent/expression/ie_x1y2z3w4/respond
  Description: 种子发布者接受、拒绝或请求进一步沟通。

  Request:
    {
      "responder_ns_id": "ns_0a1b2c3d",   // 必须是种子发布者
      "response": "accept",
      "note": "方向确实很一致，欢迎加入！"
    }

  Response:
    {
      "expression_id": "ie_x1y2z3w4",
      "response": "accepted",
      "seed_coalescence_status": {
        "confirmed_expressers": 3,
        "average_similarity": 0.79,
        "crystallizable": true,
        "crystallization_hint": "已满足结晶条件——建议发起策元结晶"
      }
    }

  Error Responses:
    403: 调用者不是种子发布者
    409: 已经回复过此表达
```

### 6.6 POST /genesis/crystallize — 触发策元结晶

```
POST /genesis/crystallize
  Description: 当条件满足时，发起策元结晶——将已确认的意向者集合转换为正式策元。
               这是原子操作：全部成功或全部回滚。

  Request:
    {
      "seed_id": "cs_a1b2c3d4",
      "initiator_ns_id": "ns_0a1b2c3d",
      "confirmed_expresser_ids": [
        "ns_0a1b2c3d",      // 发布者自动包含
        "ns_4d5e6f7g",
        "ns_8h9i0j1k"
      ],
      "pcp_template": "software_product_v1",
      "pcp_customizations": {
        "reward_formula": "60_hours_40_output",
        "theta_similarity": 0.70,
        "core_rotation_weeks": 2
      },
      "genesis_title": "开源儿童编程平台策元"
    }

  Response (201 Created):
    {
      "genesis_id": "gu_x9y8z7w6",
      "seed_id": "cs_a1b2c3d4",
      "seed_status": "coalesced",
      "pcp_hash": "sha256:...",
      "theta": 0.70,
      "lifecycle_state": "active",
      "founding_members": ["ns_0a1b2c3d", "ns_4d5e6f7g", "ns_8h9i0j1k"],
      "internal_edges_created": 3,
      "capability_graph_phase_triggered": true,
      "capability_graph_phase_ends_at": "2026-05-17T12:00:00Z"
    }

  Error Responses:
    400: 已确认意向者 < 3（且不满足信任锚定例外）
    400: 确认者之间的平均相似度 < theta_candidate
    400: 种子发布后不足 1 小时
    409: 种子已结晶
    429: |N₀| > 100
    422: 有确认者拒绝签署 PCP（返回拒签者列表）
```

### 6.7 GET /intent/recommendations — 获取个性化推荐

```
GET /intent/recommendations
  Description: 获取基于智权体创意偏好的个性化种子推荐。

  Query Parameters:
    viewer_ns_id:  "ns_..."   (required)
    limit:         20         (default: 20, max: 50)

  Response:
    {
      "viewer_ns_id": "ns_0a1b2c3d",
      "generated_at": "2026-05-14T12:00:00Z",
      "recommendations": [
        {
          "seed_id": "cs_...",
          "title": "...",
          "match_score": 0.78,
          "match_components": {
            "skill_score": 0.85,
            "direction_score": 0.72,
            "commitment_trust": 0.75
          },
          "in_passion_window": true,
          "expressions_count": 7,
          "match_highlight": "方向向量 d1(社会影响) 和 d3(创新性) 高度一致——高技能覆盖率 (85%) 与稳定的承诺记录 (avg_stick=0.92)"
        }
      ],
      "potential_genesis_clusters": [
        {
          "cluster_id": "pgc_005",
          "seeds": ["cs_...", "cs_..."],
          "average_similarity": 0.76,
          "description": "3个教育科技方向的种子正在聚合"
        }
      ]
    }

  Note: 推荐每 24 小时刷新一次。在两次刷新之间返回缓存结果。
```

---

## 七、与现有策元层协议（10号文档）的整合

### 7.1 整合概览

ICP 被设计为策元层的**新增子协议**——它不修改现有的策元层 API，而是在其上游增加意图聚结的完整流程。

```
现有策元层（10号文档）                  ICP 新增
─────────────────────────          ─────────────────────────
                                ┌─────────────────────────┐
                                │ /intent/publish          │
                                │ /intent/seeds            │
                                │ /intent/seeds/{id}       │
                                │ /intent/express          │
                                │ /intent/expression/{id}/ │
                                │   respond               │
                                │ /intent/recommendations  │
                                └───────────┬─────────────┘
                                            │ 结晶触发
                                            ▼
POST /genesis/create              POST /genesis/crystallize
  (现有)                             (新增——封装 create)
    │                                  │
    ▼                                  ▼
POST /genesis/{id}/join           (内部调用)
POST /genesis/{id}/leave          POST /genesis/create
POST /genesis/{id}/dissolve          + ICP 特有验证
POST /genesis/{id}/core/rotate       + 种子状态转换
POST /genesis/{id}/pcp/amend         + 事件广播
```

### 7.2 对现有数据模型的扩展

**策元节点扩展**：在 `POST /genesis/create` 的响应中增加 ICP 相关字段：

```json
{
  "genesis_id": "gu_x9y8z7w6",
  // ... 现有字段 ...
  "icp_origin": {                         // 新增
    "seed_id": "cs_a1b2c3d4",
    "coalescence_method": "intentional",  // "intentional" = ICP 路径, "direct" = 直接创建
    "founding_expression_count": 3,
    "average_founding_similarity": 0.79
  }
}
```

**网络层广播消息扩展**：在 10 号文档的 6.1 广播类型中增加：

```
POST /network/broadcast
  // 新增广播类型:
  //   INTENT_COALESCENCE_SEED     — 新种子发布
  //   INTENT_EXPRESSION_RECEIVED  — 种子发布者收到新意向
  //   INTENT_EXPRESSION_ACCEPTED  — 意向被接受
  //   THRESHOLD_MET               — 结晶条件满足
```

### 7.3 对 PCP 模板的扩展

在 10 号文档的 PCP 模板 JSON Schema 的 `customizable_params` 中，ICP 依赖以下现有参数：

```json
{
  "customizable_params": {
    // ... 现有参数 ...
    "theta_similarity": {
      "type": "float",
      "range": [0.5, 0.95],
      "default": 0.70,
      "icp_usage": "用于 Phase 3 策元结晶的匹配分数阈值。也用于策元建立后的新成员加入创意校准。v1.3: 匹配分数 (match_score) 的计算方式已从单信号升级为三信号融合（§2.2）。"
    },
    "matching_weights": {
      "type": "object",
      "icp_usage": "三信号融合匹配的自定义权重。策元核可根据策元特性调整三信号的相对重要性。",
      "properties": {
        "w_skill": {
          "type": "float",
          "range": [0.2, 0.7],
          "default": 0.50,
          "description": "技能匹配权重——提高此值适用于技术密集/高度专业化策元。"
        },
        "w_direction": {
          "type": "float",
          "range": [0.1, 0.5],
          "default": 0.30,
          "description": "方向匹配权重——提高此值适用于创意方向高度依赖对齐的策元（如研究项目）。"
        },
        "w_commitment": {
          "type": "float",
          "range": [0.05, 0.4],
          "default": 0.20,
          "description": "承诺信任权重——提高此值适用于需要长期投入承诺的策元（如深度技术突破）。"
        }
      },
      "constraint": "w_skill + w_direction + w_commitment = 1.0"
    }
  }
}
```

新增 ICP 专用 PCP 参数：

```json
{
  "icp_params": {
    "passion_window_hours": {
      "type": "integer",
      "range": [48, 168],
      "default": 72,
      "description": "种子发布后的激情窗口时长（小时）——窗口期内新发布者享有 2× 推荐权重（冷启动反哺）。INFERNO-011: 从 48h 延长至 72h 以覆盖完整周末。"
    },
    "auto_notify_on_threshold": {
      "type": "boolean",
      "default": true,
      "description": "当意向确认者达到结晶条件时，是否自动通知所有确认者。"
    }
  }
}
```

### 7.4 对 INFERNO-003 防御清单的更新

ICP 引入了新的攻击面，需要在 INFERNO 防御清单中增补：

| # | 攻击向量 | 防御措施 |
|---|---------|---------|
| ICP1 | 种子洪泛 DDoS | 每智权体最多 3 个 ACTIVE 种子；文本语义去重 (sim > 0.85 拒绝)；种子质量评分 (语义丰富度 + CCR) |
| ICP2 | 意向表达轰炸 | 同一表达者对同一种子仅可表达一次；拒绝后不可再表达；意向表达需最低能证或信任锚定 (A3) |
| ICP3 | 结晶抢跑/闪电解散 | 结晶前等待 ≥ 1 小时；对标 PV3 的 72h 冷却期；最小策元规模 ≥ 3（或 2 人中 ≥ 1 人有信任锚定）(A4) |
| ICP4 | 低质量种子污染推荐 | 种子质量评分 < 0.25 降权；< 0.10 进入人工审核；新发布者获得冷启动加成而非降权 (A1/A2) |
| ICP5 | 方向向量操纵 (gaming the direction vector) | 方向向量发布后不可修改（仅 text description 可编辑）；历史方向向量的突变检测标记 |
| ICP6 | 潜在策元集群的 Sybil 攻击 | 同一集群内种子发布者的身份锚定检查——≥ 50% 成员需身份锚定；match_score 验证加入 5% 随机人工审核 (A4) |
| ICP7 | NR 富者愈富 (马太效应) | NR 取消推荐正向加成；保留新发布者冷启动 2× 加成 (A1) |
| ICP8 | 意向搭便车 (零成本表达) | 意向表达需最低能证基级 ≥ 1 或信任锚定；发布者可见意向者 CCR (A3) |
|| ICP9 | 时序竞争 (过早任务拆解) | 策元结晶后先运行 72h 能力图谱阶段——盘点技能后再拆解任务令 (A6) |
|| ICP10 | 信号干扰 (Signal Jamming — 策略性操纵种子表达以混入高价值策元) | 三层纵深防御：(1) 技能模块验证——加入需经验证的技能证明，非仅 sim；(2) NR 加权相似度——sim 乘以 NR_reliability 因子，新账户有效 sim 显著降低；(3) 90 天加入后试用期——实际贡献必须匹配种子声明，CCR_match < 0.40 撤销成员资格 (见 §2.6) |

### 7.5 版本化

```
CONC-Protocol/genesis.1.1  → 包含 ICP 子协议的策元层 v1.1
  - genesis.1.0: 基础策元 CRUD + PCP 管理（10号文档）
  - genesis.1.1: + ICP（种子发布/发现/表达/结晶）
```

---

## 八、ICP 完整状态流转图

```
                        智权体 n
                           │
                    POST /intent/publish
                           │
                           ▼
                  ┌─────────────────┐
                  │  SEED: ACTIVE    │◄──────── 重新激活（若从 COALESCED 退回）
                  │  (广播中)        │
                  └────────┬────────┘
                           │
              ┌────────────┼────────────┐
              │            │            │
              ▼            ▼            ▼
         AI 推荐      自发浏览      潜在策元标记
              │            │            │
              └────────────┼────────────┘
                           │
                           ▼
                    智权体 m 发现种子
                           │
                  POST /intent/express
                           │
                           ▼
                  ┌─────────────────┐
                  │  EXPRESSION:     │
                  │  pending_review  │
                  └────────┬────────┘
                           │
              ┌────────────┼────────────┐
              │            │            │
              ▼            ▼            ▼
           accept       decline     interview
              │            │            │
              ▼            ▼            ▼
         confirmed      rejected     pending_chat
              │
              │ (检查结晶条件)
              │
              ▼
    ┌─────────────────────┐
    │ 条件满足?            │
    │ N≥2 & match_score≥θ & t≥1h │
    └─────────┬───────────┘
              │
        ┌─────┴─────┐
        │           │
        ▼           ▼
       YES          NO
        │           │
        │           └──────▶ 等待更多意向者或降低 θ
        │
        ▼
  POST /genesis/crystallize
        │
        ▼
  ┌──────────────────┐
  │  原子操作:        │
  │  1. 创建策元节点  │
  │  2. PCP 签署      │
  │  3. 建立协作边    │
  │  4. 种子→COALESCED│
  │  5. 广播GENESIS   │
  └────────┬─────────┘
           │
           ▼
  ┌──────────────────┐
  │  GENESIS: ACTIVE  │──────▶ 触发: 能力图谱阶段 (72h)
  │  (策元运行中)      │         技能盘点 → 任务令拆解
  └──────────────────┘            → Step 1: 内部激情匹配 (48h)
```

---

## 九、实现注意事项

### 9.1 种子相似度图的增量更新

种子相似度图 G_seeds 不需要在每次新种子发布时全量重算。采用增量策略：

- 新种子 s_new 发布时：仅计算 s_new 与所有 ACTIVE 种子的相似度——O(|S_active|) 而非 O(|S|²)。
- G_seeds 的社区结构（Louvain 聚类）每 6 小时重算一次。
- 种子的聚合相似度分值在过期（90 天）后自动从活跃索引中移除。

### 9.2 方向向量的演化

- 智权体的**创意偏好向量**从以下数据中学习更新（每 30 天重新计算）：
  - 已发布种子的方向向量（加权平均）
  - 已加入策元的方向向量（加权平均）
  - 已表达意向的种子方向向量（加权平均）
- 更新算法：指数移动平均 (EMA)，α = 0.3（近期种子权重更高）。

### 9.3 离线用户的种子发现

对标 10 号文档的网络层离线同步（`POST /network/sync`），离线超过 72 小时的智权体在重新同步时，其推荐列表包含离线期间发布的 TOP 50 高匹配种子——确保不会因离线而错过重要的创意聚合机会。

---

## 十、设计决策记录

| # | 决策 | 选择 | 理由 |
|---|------|------|------|
| D1 | 方向向量维度数 | 5 | 足够区分创意方向 (5²=25种组合),避免稀疏性灾难。对比: 768维嵌入用于语义匹配,但不作为主相似度信号 |
| D2 | 主相似度算法 | 余弦相似度 | 忽略模长,专注方向——"你想去哪"比"你多想做"更重要 |
| D3 | θ 的决策权 | 策元自治(非平台统一) | 保持主权:不同策元对"方向一致"的定义不同。平台提供计算,判断交给人 |
| D4 | 72h 激情窗口 (INFERNO-011 修正) | 覆盖完整周末（跨时区可用性） | 原 48h 无法覆盖周末——周五发布的种子在周一前失去窗口加成；2× 加成仅适用于新发布者（冷启动反哺） |
| D5 | 默认种子可见性 | 全网可见 | 最大化发现概率。invite_only 是选项,非默认——符合 CONC 的开放性 |
| D6 | 意向表达最低门槛 (INFERNO-011 修正) | 需能证基级 ≥ 1 或信任锚定 | 原"零门槛"导致意向搭便车攻击——表达者无需任何成本即可污染种子意向列表。最低门槛确保表达者具有基本网络身份可信度 |
| D7 | 结晶操作原子性 | 全部成功或全部回滚 | 防止部分策元节点孤立的拓扑不完整性 |
| D8 | 聚合匹配权重 | 技能 50% + 方向 30% + 承诺 20%（三信号融合） | v1.3 从单信号升级为三信号：技能匹配基于经验证技能（最难伪造的硬信号，占主导），方向匹配融合方向向量与语义嵌入（两一级信号），承诺信任引入历史行为模式（avg_stick_rate × (1 − early_exit_rate)）。15号协议的方向档案和承诺模式被整合为 ICP 匹配的一级输入 |
| D9 | AI 推荐 vs 自发发现 | 两条路径互补 | AI 扩大发现面,自发搜索确保主权——尊重智权体的选择自由 |
| D10 | 种子 text 去重 | sim > 0.85 拒绝 | 防止种子洪泛,但不禁止多角度探索同一方向的不同种子 |

---

## 版本记录

| 版本 | 日期 | 变更 |
|------|------|------|
| v1.3 | 2026-05-18 | **三信号融合匹配 (Three-Signal Fusion Matching)**：修复审查报告 Fracture 1 —— (1) §2.2 完全重写为三信号融合公式：match_score = 0.50 × sim_skill + 0.30 × sim_direction + 0.20 × commitment_trust，整合 15_Direction_Profile_and_Judgment_Credit.md；(2) 语义嵌入从"次级信号"提升为一级信号——与 5 维方向向量并列构成方向匹配（0.60/0.40 融合）；(3) 新增承诺信任信号（avg_stick_rate × (1 − early_exit_rate)），从方向档案的 commitment_pattern 提取；(4) 技能匹配从自述 Jaccard 重叠升级为经验证的技能模块交叉验证；(5) 新增 §2.7 匹配升级总结——详述升级对比、语义嵌入升级理由、承诺信任引入理由、权重设计哲学和迁移路径；(6) API 响应更新：match_score 替代 sim_aggregated / computed_similarity / similarity_to_viewer，增加 match_components 分解（skill_score、direction_score、commitment_trust）；(7) D8 设计决策更新为三信号权重 |
| v1.2 | 2026-05-15 | **信号干扰防御 (Signal Jamming Defense)**：新增 §2.6 信号干扰防御子章节——(1) 定义信号干扰问题（策略性操纵种子表达以混入高价值策元）；(2) 防御层1：技能模块验证——加入策元需经验证的技能证明，非仅 sim；(3) 防御层2：NR 加权相似度——sim_effective = sim × NR_reliability，新账户有效 sim 显著降低；(4) 防御层3：90 天加入后试用期——CCR_match < 0.40 撤销成员资格；(5) 诚实承认：三层纵深防御将攻击成本从近乎零提升至需持续数月的实质性贡献，但不存在完美防御。同步更新 INFERNO 防御清单增补 ICP10 |
| v1.1 | 2026-05-14 | **INFERNO-011 安全强化**：(A1) NR反向加成——取消高NR种子推荐加权，新发布者冷启动2×加成；(A2) 种子限额——每智权体3个ACTIVE上限 + 质量评分（语义丰富度+CCR）；(A3) 意向最低门槛——需能证基级≥1或信任锚定，发布者可见意向者CCR；(A4) Sybil防御——最小策元规模≥3，sim验证5%随机人工审核；(A5) 窗口延长——48h→72h覆盖周末，2×仅新发布者；(A6) 能力图谱先行——结晶后72h内部技能盘点，再拆解任务令匹配能力 |
| v1.0 | 2026-05-14 | 初始版本。定义 ICP 完整协议——创意图元格式、相似度计算、三阶段聚结流程、激情驱动特殊性、协议 API、与策元层的整合。对标任务令内源优先协议。 |

---

*Hermes Agent — 架构师与逻辑编译器*
*创意聚合协议 v1.3 (Three-Signal Fusion Matching)。策元不是被创建的——策元是被发现的。ICP 让"发现"有了协议，让防御有了纵深，让匹配有了三维信号。*


---

## v1.1 更新 (2026-07-10) — CONC-P0-4
- 确保ICP协议与矛盾驱动框架中的"效能最大化"动机对齐（矛盾B→多归属→ICP凝聚）
- 术语同步：三元矛盾A/B/C已正式编入七阶段螺旋
