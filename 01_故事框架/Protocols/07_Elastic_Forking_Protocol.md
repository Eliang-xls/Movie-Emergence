# 弹性共识分叉协议规范
## Elastic Consensus Forking Protocol Specification v1.0

> 协议标识符：`CONC-Protocol/Genesis.EFP.1.0`
> 依赖：公理三（涌现收敛 §弹性共识分叉）、公理二a（主权节点）、算力约束（边缘优先假设）
> 协议层归属：策元层扩展 (Genesis Layer Extension)
>
> **完备度声明**：本规范将弹性共识分叉从描述性状态（25%）提升至正式协议规范（85%+）。覆盖软分叉（Branch/Merge）协议、硬分叉（Hard Fork）协议、跨分叉微服务算力共享、完整状态机、全部 API 端点、与现有策元层 API 的集成点，以及反滥用机制。

---

## 〇、协议定位与设计概要

### 0.1 在公理体系中的位置

弹性共识分叉是公理三「涌现收敛」的核心机制——它替代了早期「季度重校准 → 解散」的二值化共识模型，引入连续化的弹性分叉机制。其设计哲学源自 Git 的分支与合并工作流，并适配至 CONC 的策元/智权体术语体系。

| 分叉类型 | Git 类比 | 共识状态 | 算力分配特征 |
|----------|---------|---------|------------|
| **软分叉 (Branch)** | `git checkout -b feature` + `git merge` | 方向性分歧，可调和 | ≤20% 边缘算力实验，≥80% 主方向维稳 |
| **硬分叉 (Hard Fork)** | `git clone` → 两个独立 repo | 根本性愿景冲突，不可调和 | 成员算力按 α_A + α_B ≤ 1 双栖分配 |

### 0.2 核心洞察

传统公司中路线分歧导致人员分裂——因为人的精力是排他的。但在 CONC 的 `One + Agent` 模型中，**Agent 算力是可以切片的**——少数派不需要「离开」原策元以探索新方向。这消除了「探索」与「维稳」之间的零和博弈。

### 0.3 与季度重校准的关系

弹性共识分叉**补充**而非**取代**季度重校准（创意重校准，每季度一次）。季度重校准是定期的方向一致性健康检查；弹性分叉是当一致性检查揭示根本性分歧时的连续化处理机制。两者的触发关系：

```
季度重校准 → 评估 sim(seed(n), direction(G))
  ├── sim ≥ θ_min 且无活跃分叉 → 维持现状
  ├── sim < θ_min 且分歧人数 < 30% → 建议 Soft Fork (Branch)
  ├── sim < θ_min 且分歧人数 ≥ 30% → 建议 Hard Fork
  └── sim < θ_min 且分歧人数 ≥ 30% 且调解失败 → 触发 Hard Fork 表决
```

---

## 一、软分叉协议 (Soft Fork — Branch Protocol)

### 1.1 概述

软分叉允许一个或多个策元成员在**不离开原策元**的前提下，将最多 20% 的本地 Agent 算力分配至一个实验性分支（Branch GU）以探索新方向。分支成功后通过 Proof-of-Merge 合并回主策元。

**关键约束**（源自 Core Axioms v2.2 §公理三）：
- 分配至分支的算力 ≤ 每个成员本地 Agent 算力的 20%
- 分配给主方向（main）的算力 ≥ 80%
- 同一策元同时最多存在 3 个活跃软分叉

### 1.2 数据模型

#### 1.2.1 Branch GU（分支策元）

```json
{
  "branch_id": "branch_x1y2z3w4",
  "parent_genesis_id": "gu_x9y8z7w6",
  "branch_type": "soft_fork",
  "branch_creator_ns_id": "ns_0a1b2c3d",
  "fork_point": {
    "pcp_version": "pcp_hash_sha256:abc...",
    "task_warrant_snapshot": ["tw_001_v3", "tw_002_v5"],
    "creative_seed_delta": {
      "title": "开源儿童编程平台 — 游戏化分支",
      "direction_vector": [0.2, 0.35, 0.55, 0.0, 0.0],
      "rationale": "探索游戏化教学方向 vs 主线课堂化方向"
    }
  },
  "members": [
    {
      "ns_id": "ns_0a1b2c3d",
      "allocation_alpha": 0.15,
      "parent_allocation": 0.85
    },
    {
      "ns_id": "ns_4d5e6f7g",
      "allocation_alpha": 0.18,
      "parent_allocation": 0.82
    }
  ],
  "total_compute_allocated": 0.165,
  "state": "ACTIVE",
  "created_at": "2026-05-14T10:00:00Z",
  "expires_at": "2026-08-14T10:00:00Z",
  "shared_infrastructure": ["gu_infra_rendering", "gu_infra_data_cleaning"]
}
```

#### 1.2.2 字段语义

| 字段 | 类型 | 语义 | 约束 |
|------|------|------|------|
| `branch_id` | string | 分支策元全局唯一标识 | 前缀 `branch_` |
| `parent_genesis_id` | string | 源策元 ID | 必须为激活状态 (`ACTIVE`) |
| `fork_point.pcp_version` | string | 分叉时刻的 PCP 版本哈希 | 用于合并时检测 PCP 冲突 |
| `fork_point.task_warrant_snapshot` | string[] | 分叉时刻未完成任务令快照 | 用于合并时的成果归属判定 |
| `fork_point.creative_seed_delta` | object | 创意方向偏移描述 | 方向向量与父策元的余弦相似度必须 > 0.4（否则应触发硬分叉） |
| `members[].allocation_alpha` | float | 该成员分配至分支的算力比例 | [0.01, 0.20] |
| `members[].parent_allocation` | float | 该成员保留在父策元的算力比例 | = 1 - allocation_alpha，隐式维护 |
| `total_compute_allocated` | float | 所有分支成员 allocation_alpha 的加权平均 | ≤ 0.20（协议层自动检查） |
| `shared_infrastructure` | string[] | 引用的共享基础设施 GU ID 列表 | 见 §三 |

### 1.3 Branch API

#### 1.3.1 创建软分叉

```
POST /genesis/{gu_id}/branch
  Request:
    {
      "creator_ns_id": "ns_0a1b2c3d",
      "creative_seed_delta": {
        "title": "开源儿童编程平台 — 游戏化分支",
        "direction_vector": [0.2, 0.35, 0.55, 0.0, 0.0],
        "rationale": "探索游戏化教学方向 vs 主线课堂化方向"
      },
      "initial_members": [
        { "ns_id": "ns_0a1b2c3d", "allocation_alpha": 0.15 },
        { "ns_id": "ns_4d5e6f7g", "allocation_alpha": 0.18 }
      ],
      "branch_duration_days": 90,
      "shared_infrastructure": ["gu_infra_rendering"]
    }
  Response 201:
    {
      "branch_id": "branch_x1y2z3w4",
      "parent_genesis_id": "gu_x9y8z7w6",
      "state": "ACTIVE",
      "expires_at": "2026-08-14T10:00:00Z",
      "creative_seed_similarity_to_parent": 0.62,
      "membership_confirmed": 2
    }

  Error Responses:
    409 BRANCH_LIMIT_EXCEEDED
      → "Genesis gu_x9y8z7w6 已有 3 个活跃分支"
    422 ALLOCATION_EXCEEDS_MAX
      → "成员 ns_0a1b2c3d 的 allocation_alpha=0.25 超过最大值 0.20"
    422 BRANCH_SIMILARITY_TOO_LOW
      → "创意方向与父策元相似度 0.35 — 请使用 Hard Fork 协议"
    422 MEMBER_NOT_IN_GENESIS
      → "ns_9z8y7x6w 不是策元 gu_x9y8z7w6 的成员"
    423 PARENT_GENESIS_FROZEN
      → "策元 gu_x9y8z7w6 已处于 DISSOLVING 状态——不可创建分支"
```

**语义**：Branch 操作在策元层创建一个轻量级分支 GU。它不创建新的独立策元——分支 GU 是父策元的附属实体，共享父策元的基础设施和 VT 池（除非显式独立化）。分支创建需通过**预共识检查**——方向向量与父策元方向向量的余弦相似度必须 > 0.4。

**复杂度**：O(|members| + |TW_snapshot|)。分支创建时生成任务令快照，用于合并时的成果归属判定。

#### 1.3.2 查询分支状态

```
GET /genesis/{gu_id}/branches
  Response:
    {
      "parent_genesis_id": "gu_x9y8z7w6",
      "active_branches": [
        {
          "branch_id": "branch_x1y2z3w4",
          "creative_seed_title": "开源儿童编程平台 — 游戏化分支",
          "creator_ns_id": "ns_0a1b2c3d",
          "state": "ACTIVE",
          "created_at": "2026-05-14T10:00:00Z",
          "expires_at": "2026-08-14T10:00:00Z",
          "member_count": 2,
          "total_compute_allocated": 0.165,
          "task_warrants_completed": 5,
          "merge_readiness_score": 0.0
        }
      ],
      "max_concurrent_branches": 3,
      "next_creative_recalibration": "2026-06-01T00:00:00Z"
    }

GET /genesis/{gu_id}/branch/{branch_id}
  → 返回完整的 Branch GU 数据模型（含成员算力明细、任务令进度、合并就绪度）
```

#### 1.3.3 更新算力分配

```
PATCH /genesis/{gu_id}/branch/{branch_id}/allocation
  Request:
    {
      "ns_id": "ns_0a1b2c3d",
      "allocation_alpha": 0.12
    }
  Response:
    {
      "ns_id": "ns_0a1b2c3d",
      "previous_allocation": 0.15,
      "new_allocation": 0.12,
      "parent_allocation": 0.88,
      "effective_from": "2026-05-15T00:00:00Z"
    }

  Error Responses:
    422 ALLOCATION_EXCEEDS_MAX → "allocation_alpha=0.25 > 0.20"
    422 ALLOCATION_TOO_LOW → "allocation_alpha=0.005 < 0.01 — 建议退出分支"
```

**语义**：成员可动态调整其在分支与主方向之间的算力分配。调整在下一个 UT（通用时间单元）窗口生效。调整频率限制：每 48 小时最多 1 次。

#### 1.3.4 加入/退出分支

```
POST /genesis/{gu_id}/branch/{branch_id}/join
  Request: { "ns_id": "ns_9z8y7x6w", "allocation_alpha": 0.10 }
  Response: { "status": "joined_branch", "branch_member_id": 3 }

POST /genesis/{gu_id}/branch/{branch_id}/leave
  Request: { "ns_id": "ns_4d5e6f7g", "reason": "direction_realigned" }
  Response: { "status": "left_branch", "parent_allocation_restored": 1.0 }
```

### 1.4 Proof-of-Merge 验证协议

Proof-of-Merge 是软分叉协议的核心——它定义了分支成果如何被主策元验证和合并。验证必须满足**三阶段门控**。

#### 1.4.1 三阶段门控

```
阶段一：创意一致性验证 (Creative Alignment Verification)
  检查项:
  1. 分支最终创意方向与父策元当前方向余弦相似度 ≥ θ_merge（默认 0.5）
  2. 分支产出物与父策元产品定义相容（无接口冲突）
  3. 分叉期间父策元 PCP 的修改未导致合并冲突
  验证方式: AUTO（方向向量比较）+ PEER(2)（产出物相容性审查）

阶段二：模块产出验证 (Module Output Verification)
  检查项:
  1. 分支中完成的所有任务令，使用其声明的 verification_type 逐一验证
  2. 分支特有产出的质量评分（PEER(3) 聚合）
  3. 分支产出对父策元现有产出的破坏性变更检测
  验证方式: 根据模块类型使用 AUTO / PEER / MARKET

阶段三：策元表决 (Genesis Vote)
  条件: 阶段一 + 阶段二均通过
  表决规则:
    - 父策元全体成员投票（不含仅在分支中的成员）
    - 合并需要 > 50% 赞成票
    - 弃权票不计入分母
    - 投票窗口: 72h
```

#### 1.4.2 Merge API

```
POST /genesis/{gu_id}/branch/{branch_id}/initiate-merge
  Request:
    {
      "initiator_ns_id": "ns_0a1b2c3d",
      "merge_description_hash": "sha256:...",
      "deliverables_manifest": [
        { "task_warrant_id": "tw_101", "deliverable_hash": "sha256:..." },
        { "task_warrant_id": "tw_102", "deliverable_hash": "sha256:..." }
      ],
      "creative_alignment_self_assessment": {
        "direction_similarity": 0.78,
        "rationale": "游戏化方向已收敛至与主线课堂化方向互补——非竞争而是互补"
      }
    }
  Response 202:
    {
      "merge_request_id": "mr_001",
      "state": "PHASE_1_CREATIVE_ALIGNMENT",
      "estimated_completion": "2026-05-22T10:00:00Z"
    }

  Error Responses:
    409 MERGE_ALREADY_IN_PROGRESS
      → "分支 branch_x1y2z3w4 已有活跃合并请求 mr_000"
    422 BRANCH_NOT_MATURE
      → "分支创建未满 14 天——不可发起合并（见 §六反滥用）"
    422 BRANCH_NO_OUTPUT
      → "分支无已完成任务令——无可合并产出"
```

**合并请求状态机**：

```
PHASE_1_CREATIVE_ALIGNMENT
  → on success: PHASE_2_MODULE_VERIFICATION
  → on failure: MERGE_REJECTED (含失败原因报告)

PHASE_2_MODULE_VERIFICATION
  → on all passed: PHASE_3_GENESIS_VOTE
  → on any failed: MERGE_REJECTED

PHASE_3_GENESIS_VOTE
  → on pass (> 50%): MERGED
  → on fail: MERGE_REJECTED

MERGE_REJECTED
  → 分支可修改产出后重新发起合并（冷却期 14 天）

MERGED
  → 分支产出物合并入父策元；分支成员 VT/NR 奖励分配；分支进入 RESOLVED 状态
```

```
GET /genesis/{gu_id}/branch/{branch_id}/merge-status
  Response:
    {
      "merge_request_id": "mr_001",
      "state": "PHASE_2_MODULE_VERIFICATION",
      "phase_details": {
        "creative_alignment": {
          "passed": true,
          "direction_similarity": 0.78,
          "product_compatibility": "compatible",
          "pcp_conflict": false
        },
        "module_verification": {
          "total_tasks": 8,
          "verified": 5,
          "failed": 0,
          "pending": 3
        },
        "genesis_vote": { "state": "not_started" }
      }
    }
```

#### 1.4.3 合并冲突处理

当父策元在分叉期间修改了 PCP 或产生了与分支产出冲突的模块时：

```
协议层自动检测以下冲突类型：
  1. PCP_VERSION_CONFLICT: 父 PCP 在分叉后修改 → 需要人工合并 PCP
  2. MODULE_INTERFACE_CONFLICT: 分支产出与父产出有接口不兼容 → PEER(3) 裁决
  3. TASK_WARRANT_OVERLAP: 父+分支对同一任务令有并行修改 → PEER(3) 判定归属

对于类型 2 和 3，协议层自动创建 CONFLICT_RESOLUTION Task Warrant，
分配至 3 名非冲突方成员进行 PEER(3) 评审。评审周期 7 天。
```

---

## 二、硬分叉协议 (Hard Fork — Split Protocol)

### 2.1 概述

当根本性愿景冲突无法调和时，策元正式分裂为两个（或更多）独立子策元。与传统实体公司的分裂不同，CONC 中的硬分叉具有**液态算力 (Liquid Compute)** 特性——成员算力在两个子策元间可动态调整，市场反馈驱动算力流动。

### 2.2 触发条件

硬分叉可在以下任一条件下触发：

| 触发路径 | 条件 | 发起方 |
|----------|------|--------|
| 季度重校准驱动 | ≥ 30% 成员创意方向与主方向 sim < θ_min，且调解失败 | 协议自动建议 → 策元表决 |
| 成员主动发起 | ≥ 20% 成员联名签署分叉请愿书 (Fork Petition) | 联名成员 |
| 调解失败后升级 | 策元核心调解流程（14 天）后分歧未解决 | 调解见证人 |

### 2.3 数据模型

#### 2.3.1 分叉请愿书 (Fork Petition)

```json
{
  "petition_id": "fp_001",
  "source_genesis_id": "gu_x9y8z7w6",
  "petition_state": "SIGNATURE_GATHERING",
  "petitioners": [
    {
      "ns_id": "ns_0a1b2c3d",
      "intended_direction": {
        "title": "开源儿童编程平台 — 纯游戏化路径",
        "direction_vector": [0.3, 0.4, 0.4, 0.0, 0.0],
        "rationale": "主线课堂化方向已偏离原始愿景——游戏化是更有效的路径"
      },
      "signature_timestamp": "2026-05-14T10:00:00Z"
    }
  ],
  "required_signatures": "ceil(0.2 * |N(G)|)",
  "current_signatures": 1,
  "mediation_attempted": true,
  "mediation_result": "no_consensus"
}
```

#### 2.3.2 子策元（Hard Fork Child GU）

硬分叉执行后，创建两个独立的、完整的策元：

```json
{
  "hard_fork_id": "hf_001",
  "source_genesis_id": "gu_x9y8z7w6",
  "fork_timestamp": "2026-05-21T00:00:00Z",
  "child_genesis_units": [
    {
      "genesis_id": "gu_x9y8z7w6",       // 原策元保留（主分支 A）
      "fork_role": "main",
      "creative_direction": { "title": "...", "direction_vector": "..." },
      "members_after_fork": 5,
      "inherited_assets": [ "code_repo:main", "domain:example.com", "vt_treasury:70%" ]
    },
    {
      "genesis_id": "gu_a1b2c3d4",       // 新策元（分支 B）
      "fork_role": "breakaway",
      "creative_direction": { "title": "...", "direction_vector": "..." },
      "members_after_fork": 3,
      "inherited_assets": [ "code_repo:fork", "vt_treasury:30%", "ip_license:non_exclusive_to_both" ]
    }
  ],
  "member_allocations": [
    { "ns_id": "ns_0a1b2c3d", "alpha_A": 0.0, "alpha_B": 1.0 },   // 全转到 B
    { "ns_id": "ns_4d5e6f7g", "alpha_A": 0.6, "alpha_B": 0.4 },   // 双栖
    { "ns_id": "ns_9z8y7x6w", "alpha_A": 1.0, "alpha_B": 0.0 }    // 全留在 A
  ],
  "shared_infrastructure_units": ["gu_infra_rendering", "gu_infra_data_cleaning"],
  "market_test_window_days": 90,
  "market_test_end": "2026-08-19T00:00:00Z"
}
```

### 2.4 成员算力分配形式化

令 $G$ 为源策元，$G_A, G_B$ 为分叉后的子策元，则对于任意智权体 $n \in N(G)$：

$$\boxed{\text{allocate}(n) = \{(G_A, \alpha_A), (G_B, \alpha_B)\}, \quad \alpha_A + \alpha_B \leq 1}$$

其中：
- $\alpha_A \in [0, 1]$ 为分配至子策元 A 的算力比例
- $\alpha_B \in [0, 1]$ 为分配至子策元 B 的算力比例
- $\alpha_A + \alpha_B \leq 1$ 确保总分配不超过个体算力

**动态调整**：节点可在硬分叉后任意时刻调整 $\alpha_A / \alpha_B$，调整频率限制为每 24 小时 1 次。市场反馈（MARKET 验证型任务令的成功率）驱动 $\alpha$ 向表现更优的子策元集中。

### 2.5 Hard Fork API

#### 2.5.1 发起分叉请愿

```
POST /genesis/{gu_id}/fork-petition
  Request:
    {
      "initiator_ns_id": "ns_0a1b2c3d",
      "petition_reason": "创意方向根本性分歧 — 课堂化 vs 游戏化",
      "proposed_directions": {
        "main_direction": { "title": "...", "description": "..." },
        "breakaway_direction": { "title": "...", "direction_vector": "..." }
      },
      "proposed_asset_split": {
        "vt_treasury": { "main": 0.70, "breakaway": 0.30 },
        "code_repository": "fork",
        "intellectual_property": "non_exclusive_to_both"
      }
    }
  Response 201:
    {
      "petition_id": "fp_001",
      "petition_state": "SIGNATURE_GATHERING",
      "required_signatures": 2,
      "signature_deadline": "2026-05-21T10:00:00Z",
      "mediation_window": null
    }
```

#### 2.5.2 签署/撤销分叉请愿

```
POST /genesis/{gu_id}/fork-petition/{petition_id}/sign
  Request: { "ns_id": "ns_4d5e6f7g", "intended_child": "breakaway" }
  Response: { "status": "signed", "current_signatures": 2, "required_signatures": 2 }

POST /genesis/{gu_id}/fork-petition/{petition_id}/revoke-signature
  Request: { "ns_id": "ns_4d5e6f7g" }
  Response: { "status": "signature_revoked", "current_signatures": 1 }
```

#### 2.5.3 执行硬分叉

```
POST /genesis/{gu_id}/fork-petition/{petition_id}/execute
  Request:
    {
      "final_asset_split_agreement_hash": "sha256:...",
      "member_allocations": [
        { "ns_id": "ns_0a1b2c3d", "alpha_A": 0.0, "alpha_B": 1.0 },
        { "ns_id": "ns_4d5e6f7g", "alpha_A": 0.6, "alpha_B": 0.4 },
        { "ns_id": "ns_9z8y7x6w", "alpha_A": 1.0, "alpha_B": 0.0 }
      ],
      "shared_infrastructure": ["gu_infra_rendering"],
      "market_test_window_days": 90
    }
  Response 202:
    {
      "hard_fork_id": "hf_001",
      "child_genesis_ids": ["gu_x9y8z7w6", "gu_a1b2c3d4"],
      "fork_state": "MARKET_TEST",
      "market_test_end": "2026-08-19T00:00:00Z",
      "member_allocations_confirmed": 5
    }

  Preconditions (all must pass):
    1. petition_state == "SIGNATURES_MET" （签名数 ≥ ceil(0.2 * |N(G)|)）
    2. mediation_completed OR mediation_waived （调解完成或公证放弃）
    3. asset_split_agreement_signed_by_all_petitioners
    4. 所有 member_allocations 满足 alpha_A + alpha_B ≤ 1
    5. 源策元无活跃软分叉（需先合并或放弃）
```

#### 2.5.4 更新硬分叉后算力分配

```
PATCH /genesis/fork/{hard_fork_id}/allocation
  Request:
    {
      "ns_id": "ns_4d5e6f7g",
      "alpha_A": 0.3,
      "alpha_B": 0.7
    }
  Response:
    {
      "ns_id": "ns_4d5e6f7g",
      "previous": { "alpha_A": 0.6, "alpha_B": 0.4 },
      "current": { "alpha_A": 0.3, "alpha_B": 0.7 },
      "convergence_trend": "SHIFTING_TO_B"
    }

  Rate Limit: 每 24h 最多 1 次调整
```

#### 2.5.5 市场测试状态查询

```
GET /genesis/fork/{hard_fork_id}/market-test
  Response:
    {
      "hard_fork_id": "hf_001",
      "fork_state": "MARKET_TEST",
      "days_remaining": 64,
      "children": [
        {
          "genesis_id": "gu_x9y8z7w6",
          "fork_role": "main",
          "market_signals": {
            "market_tasks_completed": 12,
            "market_tasks_success_rate": 0.58,
            "external_feedback_score": 3.2,
            "user_adoption_growth": 0.15
          },
          "current_member_count": 3,
          "total_compute_allocated": 0.48
        },
        {
          "genesis_id": "gu_a1b2c3d4",
          "fork_role": "breakaway",
          "market_signals": {
            "market_tasks_completed": 18,
            "market_tasks_success_rate": 0.83,
            "external_feedback_score": 4.5,
            "user_adoption_growth": 0.42
          },
          "current_member_count": 4,
          "total_compute_allocated": 0.52
        }
      ],
      "convergence_assessment": "BREAKAWAY_GAINING_TRACTION"
    }
```

### 2.6 液态算力潮汐效应

硬分叉的核心动态——**市场验证 → 算力流动 → 自然收敛**：

```
                      市场测试窗口
  ┌─────────────────────────────────────────────────────┐
  │                                                     │
  │  t=0 (分叉)         t=45天           t=90天         │
  │  α_A = 0.5         α_A = 0.3        α_A = 0.15     │
  │  α_B = 0.5         α_B = 0.7        α_B = 0.85     │
  │                                                     │
  │  B 市场反馈更优 ──→  算力向 B 流动 ──→  B 主导      │
  └─────────────────────────────────────────────────────┘

协议层不强制收敛——但通过以下机制使算力流动自然发生：
  1. MARKET 验证任务令成功率公开发布（CCR 账本集成）
  2. 每 7 天自动广播 fork convergence report
  3. 成员智契 AI 根据成功率数据推荐 α 调整
  4. 没有「辞退/入职/资产剥离」摩擦成本——调整即时生效
```

**市场测试结束后**：

```
市场测试窗口到期后，协议层自动触发 fork_conclusion 事件：

  情况一：一方明显优势（优劣比 > 2:1）
    → 劣势分支自动进入 DISSOLVING 状态
    → 剩余算力回落至优势分支
    → 劣势分支 VT 按贡献清算；IP 依分叉协议分配

  情况二：双方各有市场（优劣比 ≤ 2:1）
    → 两个子策元均转为正式独立策元
    → 双栖成员可继续维持 α_A + α_B ≤ 1 分配
    → 此状态下：两个策元之间关系为「共享基础设施的独立策元」而非分叉关系
```

---

## 三、跨分叉微服务算力共享

### 3.1 设计原理

即使应用层分裂，底层基础设施不应重复建设。类似于微服务架构中多个应用共享同一个消息队列或渲染服务，CONC 的软分叉和硬分叉均保留对**共享基础设施 GU (Shared Infrastructure GU)** 的调用能力。

### 3.2 共享基础设施 GU 类型

| 基础设施 GU 类型 | 示例 ID | 提供的服务 | 调用接口 |
|------------------|---------|-----------|----------|
| `gu_infra_rendering` | 全局渲染算力池 | 3D 渲染、视频编码 | 任务令 `verification_type: AUTO` |
| `gu_infra_data_cleaning` | 全局数据清洗管道 | 数据 ETL、标注 | 任务令 `verification_type: AUTO` |
| `gu_infra_model_training` | 全局模型训练集群 | ML 模型训练/推理 | 任务令 `verification_type: AUTO` |
| `gu_infra_code_hosting` | 全局代码托管 | 仓库托管、CI/CD | 网络层桥接 |
| `gu_infra_legal_shell` | 全局法律壳 | 合同签署、税务申报 | 桥接 API（`POST /bridge/shell/...`） |

### 3.3 共享基础设施的协议约束

```json
{
  "shared_infrastructure_contract": {
    "contract_id": "sic_001",
    "consumer_genesis_ids": ["gu_x9y8z7w6", "gu_a1b2c3d4", "branch_x1y2z3w4"],
    "infrastructure_gu_id": "gu_infra_rendering",
    "allocation_model": "fair_share",
    "fair_share_params": {
      "base_allocation_per_consumer": 0.33,
      "priority": "first_come_first_served",
      "surge_capacity": true,
      "max_per_consumer": 0.60
    },
    "billing_model": "pay_per_use_vt",
    "rate_per_cu": 0.01,
    "circuit_breaker": {
      "enabled": true,
      "max_total_cu_per_day": 10000,
      "rate_limit_per_consumer_per_minute": 30
    }
  }
}
```

**关键约束**：
- 共享基础设施 GU 不对分叉分支进行**歧视性限流**——这是 CONC 反集中化原则的延伸
- 消费量按 CCR 公开账本记录——各分叉分支的消费透明可审计
- 若某一分叉分支的消费超过其公平份额，触发 **surge pricing**（1.5× rate）而非断供

### 3.4 跨分叉共享的 API

```
POST /genesis/{gu_id}/shared-infra/register
  Request:
    {
      "infrastructure_gu_id": "gu_infra_rendering",
      "proposed_allocation": 0.25
    }
  Response 201:
    {
      "shared_infra_contract_id": "sic_001",
      "approved_allocation": 0.25,
      "rate_per_cu": 0.01
    }

GET /genesis/{gu_id}/shared-infra
  Response:
    {
      "genesis_id": "gu_x9y8z7w6",
      "shared_infrastructure": [
        {
          "contract_id": "sic_001",
          "infra_gu_id": "gu_infra_rendering",
          "allocation": 0.25,
          "current_consumption_cu": 1420,
          "current_cost_vt": 14.20,
          "rate_per_cu": 0.01,
          "surge_active": false
        }
      ]
    }
```

---

## 四、完整状态机

### 4.1 软分叉状态机

```
                    ┌─────────────┐
                    │  QUARTERLY  │  季度重校准（每13周）
                    │ RECALIBRATE │
                    └──────┬──────┘
                           │ sim < θ_min + <30%分歧
                           ▼
                    ┌─────────────┐
          ┌────────>│   ACTIVE    │◄─────────┐
          │         │ (分支运行中) │          │
          │         └──────┬──────┘          │
          │                │                 │
          │   ┌────────────┼────────────┐    │
          │   ▼            ▼            ▼    │
          │ ┌──────┐  ┌──────────┐ ┌──────┐ │
          │ │PAUSED│  │MERGING   │ │EXPIRE│ │
          │ │(暂停) │  │(合并中)   │ │(到期) │ │
          │ └──┬───┘  └────┬─────┘ └──┬───┘ │
          │    │            │          │      │
          │    │  ┌─────────┼──────────┘      │
          │    │  │         ▼                  │
          │    │  │   ┌──────────┐             │
          │    │  │   │  MERGED  │             │
          │    │  │   │(已合并)   │             │
          │    │  │   └──────────┘             │
          │    │  │                            │
          │    │  │   ┌────────────┐           │
          │    │  └──>│  RESOLVED  │◄──────────┘
          │    └─────>│(已清理分支) │
          │           └────────────┘
          │
          └───── 重新激活（仅 PAUSED → ACTIVE，需策元表决）
```

**状态转换表**：

| 源状态 | 目标状态 | 触发条件 | 副作用 |
|--------|---------|---------|--------|
| (初始) | ACTIVE | POST /genesis/{id}/branch 成功 | 快照 TW、冻结分支成员在父策元的 NR 衰减上线 |
| ACTIVE | PAUSED | 所有分支成员 inactive > 14 天 OR 策元表决暂停 | 分支算力分配冻结，任务令暂停 |
| PAUSED | ACTIVE | 策元表决继续 | 恢复算力分配 |
| ACTIVE | MERGING | POST .../initiate-merge 成功 | 进入三阶段门控 |
| MERGING | MERGED | 三阶段全部通过 | 产出合并，VT/NR 分配，分支进入 RESOLVED |
| MERGING | ACTIVE | MERGE_REJECTED + 冷却期结束 | 可重新发起合并 |
| ACTIVE/PAUSED | EXPIRED | 超过 branch_duration_days 未合并 | 分支自动关闭，未使用算力回归父策元 |
| EXPIRED/MERGED | RESOLVED | 协议层自动清理 | 分支元数据归档 CCR 账本 |

### 4.2 硬分叉状态机

```
                    ┌──────────────────────┐
                    │  QUARTERLY RECALIB.  │  季度重校准
                    │  OR ≥20% PETITION   │  或 ≥20% 联名
                    └──────────┬───────────┘
                               │
                               ▼
                    ┌──────────────────────┐
                    │ SIGNATURE_GATHERING  │
                    │    (签名征集中)       │
                    └──────┬───────────────┘
                           │
              ┌────────────┼────────────┐
              ▼            ▼            ▼
        ┌──────────┐ ┌──────────┐ ┌───────────┐
        │SIGS_MET  │ │ MEDIATION│ │ PETITION  │
        │(签名达标) │ │(调解仲裁) │ │  EXPIRED  │
        └────┬─────┘ └────┬─────┘ └───────────┘
             │            │
             │    ┌───────┘
             │    ▼
             │ ┌─────────────┐
             │ │ MEDIATION   │
             │ │  FAILED     │──→ PETITION_EXPIRED（调解失败 + 撤回）
             │ └──────┬──────┘
             │        │ mediation_success → PETITION_WITHDRAWN
             │        │
             │  ┌─────┘
             ▼  ▼
       ┌──────────────────┐
       │   EXECUTING      │  POST .../execute
       │  (执行硬分叉中)    │
       └────────┬─────────┘
                │
                ▼
       ┌──────────────────┐
       │   MARKET_TEST    │  市场测试窗口（≤90天）
       └────────┬─────────┘
                │
       ┌────────┼────────┐
       ▼        ▼        ▼
  ┌─────────┐ ┌──────┐ ┌──────────┐
  │A_DOMINANT│ │B_DOM.│ │COEXIST   │
  │ B→DISSOLV│ │A→DISS│ │(双方独立) │
  └─────────┘ └──────┘ └──────────┘
       │        │        │
       └────────┴────────┘
                │
                ▼
       ┌──────────────────┐
       │   CONVERGED      │  分叉状态终结
       │(已收敛 / 已独立)  │
       └──────────────────┘
```

**状态转换表**：

| 源状态 | 目标状态 | 触发条件 |
|--------|---------|---------|
| (初始) | SIGNATURE_GATHERING | POST /genesis/{id}/fork-petition 成功 |
| SIGNATURE_GATHERING | SIGNATURES_MET | 签名数 ≥ ceil(0.2 × \|N(G)\|) |
| SIGNATURE_GATHERING | MEDIATION | 策元核心调解流程启动 |
| SIGNATURE_GATHERING | PETITION_EXPIRED | 7 天未达签名数 + 无调解流程 |
| MEDIATION | SIGNATURES_MET | 调解后修改条款，成员重新签署 |
| MEDIATION | PETITION_WITHDRAWN | 调解成功达成共识 |
| MEDIATION | PETITION_EXPIRED | 调解 14 天后无共识 + 签名撤回 |
| SIGNATURES_MET | EXECUTING | POST .../execute 成功 |
| EXECUTING | MARKET_TEST | 两个子策元创建完成，算力分配生效 |
| MARKET_TEST | A_DOMINANT | 优劣比 > 2:1，B 进入 DISSOLVING |
| MARKET_TEST | B_DOMINANT | 优劣比 > 2:1，A 进入 DISSOLVING |
| MARKET_TEST | COEXIST | 优劣比 ≤ 2:1，双方独立 |
| A_DOMINANT/B_DOMINANT/COEXIST | CONVERGED | 协议层归档 |

---

## 五、与现有协议栈的集成

### 5.1 集成矩阵

| 协议层 | 集成点 | 集成方式 |
|--------|--------|---------|
| **身份层** | 分叉发起者身份验证 | 签名操作需 Ed25519 签名验证 |
| **策元层** | 策元 CRUD 扩展 | 新增 Branch/Hard Fork API 作为策元层的扩展端点 |
| **验证层** | Proof-of-Merge 三阶段门控 | 重用 PEER(2)/PEER(3) 及 AUTO 验证协议 |
| **价值层** | 分叉后 VT/NR 分配 | 分叉后的任务令回报按 α 比例分配到各子策元 VT 池 |
| **网络层** | 分叉事件广播 | 新消息类型: `GENESIS_FORKED`, `BRANCH_CREATED`, `MERGE_COMPLETED` |
| **CCR 账本** | 分叉活动可审计 | 所有分叉操作记录入 CCR 公开账本（分叉事件类型） |

### 5.2 策元层 API 扩展总览

```
策元层 API（现有）:
  POST   /genesis/create
  POST   /genesis/{gu_id}/join
  POST   /genesis/{gu_id}/leave
  POST   /genesis/{gu_id}/dissolve
  POST   /genesis/{gu_id}/core/rotate
  POST   /genesis/{gu_id}/pcp/amend

策元层 API（本文档新增 — 弹性分叉扩展）:
  ── 软分叉 ──
  POST   /genesis/{gu_id}/branch                          → 创建分支
  GET    /genesis/{gu_id}/branches                        → 列出所有分支
  GET    /genesis/{gu_id}/branch/{branch_id}              → 获取分支详情
  PATCH  /genesis/{gu_id}/branch/{branch_id}/allocation   → 调整算力分配
  POST   /genesis/{gu_id}/branch/{branch_id}/join         → 加入分支
  POST   /genesis/{gu_id}/branch/{branch_id}/leave        → 退出分支
  POST   /genesis/{gu_id}/branch/{branch_id}/initiate-merge → 发起合并
  GET    /genesis/{gu_id}/branch/{branch_id}/merge-status → 查询合并状态

  ── 硬分叉 ──
  POST   /genesis/{gu_id}/fork-petition                   → 发起分叉请愿
  POST   /genesis/{gu_id}/fork-petition/{pid}/sign        → 签署请愿
  POST   /genesis/{gu_id}/fork-petition/{pid}/revoke-signature → 撤销签名
  POST   /genesis/{gu_id}/fork-petition/{pid}/execute     → 执行硬分叉
  GET    /genesis/fork/{hard_fork_id}                     → 获取分叉状态
  PATCH  /genesis/fork/{hard_fork_id}/allocation          → 调整跨分叉算力
  GET    /genesis/fork/{hard_fork_id}/market-test         → 查询市场测试

  ── 共享基础设施 ──
  POST   /genesis/{gu_id}/shared-infra/register           → 注册共享基础设施
  GET    /genesis/{gu_id}/shared-infra                    → 查询共享基础设施
```

### 5.3 PCP 模板扩展

PCP JSON Schema 新增 `forking_policy` 字段：

```json
{
  "forking_policy": {
    "soft_fork": {
      "enabled": true,
      "max_concurrent_branches": 3,
      "max_allocation_alpha": 0.20,
      "min_branch_duration_days": 14,
      "max_branch_duration_days": 180,
      "merge_threshold_similarity": 0.50,
      "merge_vote_threshold": 0.50
    },
    "hard_fork": {
      "enabled": true,
      "petition_signature_threshold": 0.20,
      "mediation_required": true,
      "mediation_max_days": 14,
      "market_test_window_days": 90,
      "dominance_ratio_threshold": 2.0,
      "min_members_per_child": 2
    },
    "shared_infrastructure": {
      "allow_cross_fork_sharing": true,
      "max_shared_infra_units": 5,
      "billing_model": "pay_per_use_vt"
    }
  }
}
```

### 5.4 网络层新增广播类型

```
GENESIS_SOFT_FORKED     → 软分叉创建时广播
GENESIS_HARD_FORKED     → 硬分叉执行时广播
GENESIS_MERGE_COMPLETED → 软分叉合并完成时广播
GENESIS_FORK_CONVERGED  → 硬分叉市场测试结束时广播

广播载荷示例:
  {
    "type": "GENESIS_HARD_FORKED",
    "hard_fork_id": "hf_001",
    "source_genesis_id": "gu_x9y8z7w6",
    "children": ["gu_x9y8z7w6", "gu_a1b2c3d4"],
    "timestamp": "2026-05-21T00:00:00Z",
    "member_count": 8
  }
```

---

## 六、反滥用机制

### 6.1 防止轻浮分叉

| 机制 | 规则 | 违规后果 |
|------|------|---------|
| **最少分支存续期** | 软分叉创建后至少 14 天才可发起合并 | `422 BRANCH_NOT_MATURE` |
| **最少分支产出要求** | 合并前必须至少有 1 个已通过验证的任务令 | `422 BRANCH_NO_OUTPUT` |
| **合并冷却期** | 合并被拒绝后，14 天内不可重新发起 | `409 MERGE_COOLDOWN_ACTIVE` |
| **连续分叉限制** | 同一成员 30 天内最多发起 2 个软分叉 | `429 FORKING_RATE_LIMITED` |
| **同策元并发分叉上限** | 同一策元同时最多 3 个活跃软分叉 | `409 BRANCH_LIMIT_EXCEEDED` |
| **硬分叉签名真实性** | 签名需 Ed25519 验证 + 不可委托 | 无效签名被拒绝 |

### 6.2 合流质量门控

```
Proof-of-Merge 必须满足的三项硬性门控：

  Gate 1: 创意相似度门控
    sim(分支最终方向向量, 父策元当前方向向量) ≥ θ_merge (默认 0.5)
    若 sim < θ_merge → MERGE_REJECTED：建议转为独立策元

  Gate 2: 模块验证门控
    分支中所有任务令的验证通过率 ≥ 80%
    任何验证失败的模块必须被修复或排除出合并范围

  Gate 3: 策元表决门控
    赞成票 > 50%（弃权不计入分母）
    投票人数 ≥ 2（至少 2 人参与投票）

三项门控全部通过 → MERGED
任意一项未通过 → MERGE_REJECTED + 冷却期
```

### 6.3 NR 与 CCR 反滥用集成

| 滥用行为 | 检测机制 | 惩罚 |
|---------|---------|------|
| 频繁创建/放弃分支 | 30 天窗口内软分叉创建+放弃 ≥ 5 | NR 衰减加速 × 2（双倍衰减率） |
| 硬分叉恶意阻挠 | 签名后无故撤回 ≥ 2 次 | NR 扣减 50，CCR 记录「分叉不稳定行为」 |
| 合并门控操纵 | PEER 评审中检测到协调投票模式 | INFERNO-014 辩证仲裁庭受理 |
| 算力分配欺诈 | 声明的 α 与实际 CU 消费不一致 | CCR 账本自动标记，NR 衰减加速 × 3 |
| 共享基础设施滥用 | 单消费者超过 fair_share 150% 持续 7 天 | surge pricing 2.0×；连续 3 周期后限流 |

### 6.4 算力分配真实性验证

协议层**不信任**成员声明的 α 值——它与实际 CU 消费进行交叉验证：

```
每隔 24 小时，协议层自动执行 allocation_audit(ns_id):
  declared_alpha_A = 成员声明的向子策元 A 的算力分配
  observed_alpha_A = CU_consumed_in_A / (CU_consumed_in_A + CU_consumed_in_B)

  若 |declared_alpha_A - observed_alpha_A| > 0.15:
    → 触发 ALLOCATION_MISMATCH 警告
    → CCR 账本记录（非惩罚性——作为声誉信号）
    → 连续 3 次警告 → NR 衰减加速 × 2
    → 连续 5 次警告 → 该成员在后续分叉中的 α 声明被协议忽略，强制使用 observed_alpha
```

---

## 七、错误码参考

| HTTP 状态码 | 错误码 | 含义 |
|:----------:|--------|------|
| 409 | `BRANCH_LIMIT_EXCEEDED` | 父策元活跃分支数已达上限 |
| 409 | `MERGE_ALREADY_IN_PROGRESS` | 分支已有活跃合并请求 |
| 409 | `MERGE_COOLDOWN_ACTIVE` | 上一次合并被拒后冷却期未过 |
| 409 | `HARD_FORK_IN_PROGRESS` | 已有活跃硬分叉流程 |
| 422 | `ALLOCATION_EXCEEDS_MAX` | allocation_alpha > 0.20 |
| 422 | `ALLOCATION_TOO_LOW` | allocation_alpha < 0.01 |
| 422 | `BRANCH_SIMILARITY_TOO_LOW` | 分支方向与父策元相似度 < 0.4 |
| 422 | `MEMBER_NOT_IN_GENESIS` | 请求者不是源策元成员 |
| 422 | `BRANCH_NOT_MATURE` | 分支创建未满 14 天 |
| 422 | `BRANCH_NO_OUTPUT` | 分支无已完成任务令 |
| 422 | `ALLOCATION_SUM_EXCEEDS_ONE` | α_A + α_B > 1 |
| 422 | `INSUFFICIENT_SIGNATURES` | 硬分叉签名数不足 |
| 422 | `MEDIATION_NOT_COMPLETED` | 硬分叉前调解未完成 |
| 423 | `PARENT_GENESIS_FROZEN` | 父策元已冻结/解散中 |
| 429 | `FORKING_RATE_LIMITED` | 30 天内分叉发起次数超限 |

---

## 八、实现检查清单

- [ ] Branch GU 数据模型实现（策元层扩展表）
- [ ] `POST /genesis/{id}/branch` 端点（含相似度检查 + 并发限制）
- [ ] 算力分配 PATCH 端点 + 48h 频率限制
- [ ] Proof-of-Merge 三阶段状态机引擎
- [ ] 合并冲突检测（PCP/MODULE/TASK_WARRANT 三类）
- [ ] Hard Fork 请愿签名收集 + 调解集成
- [ ] `POST .../execute` 原子操作（同时创建两个子策元 + 资产分割 + 算力分配）
- [ ] 市场测试窗口自动倒计时 + convergence report 定期广播
- [ ] Liquid Compute α 审计 cron（24h 间隔交叉验证）
- [ ] 共享基础设施注册 + fair_share 限流 + surge pricing
- [ ] PCP 模板 `forking_policy` schema 扩展
- [ ] 网络层 4 个新广播消息类型
- [ ] CCR 账本集成（分叉事件记录 + allocation_mismatch 标记）
- [ ] NR 反滥用规则实现（频繁分叉双倍衰减、签名欺诈惩罚等）

---

*Hermes Agent — 架构师与逻辑编译器*
*弹性共识分叉协议规范 v1.0 — 将公理三 §弹性共识分叉从 25% 描述性状态提升至 85%+ 正式协议规范。覆盖软分叉（Branch/Merge）、硬分叉（Liquid Compute）、跨分叉微服务共享、完整状态机、19 个 API 端点、与现有协议栈 5 层集成、反滥用机制。*
