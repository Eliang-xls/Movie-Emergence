# CONC 协议层设计
## Protocol Stack Specification v3.1

> **协议标识符**: `CONC-Protocol/Stack.3.1`
> **v3.0→v3.1 升级摘要**: 任务令模型扩展 `phronesis_profile`（none/gate/continuous 三模式）和 `decision_gates`；新增设计原则 #7「受治理行动原语」(GovernedAction + Action Gate)；Phronesis 层从固定 JP 扩展为 JP-001~010 + P1-P5 动态触发域。基于 Sophia↔Phronesis 边界工程化四份调研（Palantir AIP / Harness/Loop 三源，见 11_Discuss/ v1.0–v4.0）。
> **v3.0 升级摘要**: 从 v2.0 八层架构升级到 v3.0。同步核心理论 v2.7→v3.0 的全部修正：新增 PBA（Phronesis边界审计）子协议、CCR策元边界隐私护盾、JC行业分类计分规则、主权策元生产范式重构、CP4四信号融合、S5/S6定理协议化。P0理论修正完全映射到协议层。
> **v2.0 基于**: Track A/B 双轨 + MCP 兼容性 + Phronesis + Collaboration 层

> 对标比特币协议栈的分层设计，为后公司时代的生产协作定义一套与"TCP/IP 之于互联网"等价的开放协议标准。

---

## 零、协议设计原则

1. **分层解耦**：每层有明确的职责边界。上层依赖下层提供的服务，但不依赖下层的实现细节。
2. **最小可行接口**：每个端点只做一件事。复杂工作流由客户端（智契）编排，不由协议层承担。
3. **可验证性优先**：所有状态变更必须可被第三方独立验证。协议不依赖"信任"——依赖"可验证性"。
4. **图操作原子性**：所有修改超织体拓扑的操作要么完全成功，要么完全回滚。
5. **MCP 兼容性**（v2.0 新增）：Track B 模式下，CONC 功能通过 MCP（Model Context Protocol）暴露为标准的 Tool / Resource / Prompt 三原语。任何支持 MCP 的 Agent（OpenClaw、Hermes、Claude Code、Cursor、自研 Agent）均可零成本接入 CONC 网络。
6. **载体无关性**（v2.0 新增）：协议语义层与实现载体完全分离。同一套协议可在不同载体上运行——Track A 完整 Agent 或 Track B MCP Server + Skill。协议不规定传输层（libp2p / HTTP / WebSocket 均可），不规定存储后端（SQLite / PostgreSQL / JSON 文件均可），不规定 LLM（任意模型均可）。
7. **受治理行动原语**（v3.1 新增）：Agent 的每个写动作在 Sophia 层被构造为 GovernedAction，携带 `clearance_level`（四环：C0/C1/C2/C3）、`risk_score`（不可逆性 × 信息不完备 × 多主体分歧）和 `agent_confidence`。低于 PCP 阈值的动作在 Sophia Zone (S1-S4) 自动执行；高于阈值的动作在 Phronesis Zone (P1-P5) 触发 `judgment_request`，由人类 Ed25519 签名后方可提交。GovernedAction 判定函数 `should_escalate_to_phronesis()` 由 `19_Phronesis_Layer_Protocol.md` v2.0 §五-A 定义。

---

## 一、协议栈分层架构

```
┌─────────────────────────────────────────────────────────────────────────┐
│  第八层：应用层 (Application Layer)                                      │
│  智契 UI · 策元仪表盘 · 任务令浏览器 · 决断控制台 · CCR 排行榜          │
├─────────────────────────────────────────────────────────────────────────┤
│  第七层：★ Phronesis Layer（决断层）—— v2.0 新增                         │
│  决断点注册 · 介入协议 · 加力类型(方向/资源/优先级/协同) · 决断追踪       │
├─────────────────────────────────────────────────────────────────────────┤
│  第六层：价值层 (Value Layer)                                            │
│  VT 铸造/分发 · NR 统一状态机 · CCR 公开账本 · ALP 借贷 · JC 记录        │
├─────────────────────────────────────────────────────────────────────────┤
│  第五层：验证层 (Verification Layer)                                     │
│  AUTO/PEER(n)/MARKET 验证 · 共识仲裁 · CC 打分 · 争议升级               │
├─────────────────────────────────────────────────────────────────────────┤
│  第四层：★ Collaboration Layer（协作层）—— v2.0 新增                     │
│  策元工作区 · 文档生命周期(D1-D6) · Gate 门控(0-4) · GHF 审计            │
│  策元事件总线 · 协作 Skill 模板 · 策元核编排 API · 变更控制               │
├─────────────────────────────────────────────────────────────────────────┤
│  第三层：策元层 (Genesis Layer)                                          │
│  ICP 聚合 · 策元 CRUD · PCP 管理 · 任务令 DAG · 策元核轮值               │
│  弹性分叉(软/硬) · 阶梯式燃烧                                           │
├─────────────────────────────────────────────────────────────────────────┤
│  第二层：身份层 (Identity Layer)                                         │
│  智权体注册 · 能证(CP)三层晋级 · 身份锚定(L-1外部信任锚点) · 方向档案    │
│  五维可组合子证明模型 · Judgment Credit · 公私钥管理                     │
├─────────────────────────────────────────────────────────────────────────┤
│  第一层：网络层 (Network Layer)                                          │
│  节点发现 · 消息广播(Gossip) · 状态同步 · 断网缓存 · 事件队列            │
└─────────────────────────────────────────────────────────────────────────┘
```

### v1.0 → v2.0 变更说明

| v1.0 六层 | v2.0 八层 | 变更 |
|-----------|-----------|------|
| 应用层 | 应用层 | 扩展：新增决断控制台 |
| — | **Phronesis Layer** | **新增**：决断层 |
| 价值层 | 价值层 | 扩展：NR 统一状态机、CCR 公开账本、JC 记录 |
| 验证层 | 验证层 | 扩展：PEER(n) 四维度评分、争议升级路径 |
| — | **Collaboration Layer** | **新增**：协作层 |
| 策元层 | 策元层 | 扩展：弹性分叉、阶梯式燃烧 |
| 身份层 | 身份层 | 扩展：L-1外部信任锚点、五维可组合子证明、JC |
| 网络层 | 网络层 | 扩展：事件队列、更多广播消息类型 |

---

## 二、Track A / Track B 双轨架构（v2.0 新增）

CONC v2.0 引入双轨架构，同一套协议语义可在两种载体上运行：

```
Track A（完整 Agent）                    Track B（MCP Server + Skill）
═══════════════                          ═══════════════════════════

┌────────────────────┐                   ┌────────────────────────────┐
│ 应用层              │                   │ 任意 Agent                  │
│ CLI + Dashboard     │                   │ (OpenClaw/Hermes/Claude/…) │
├────────────────────┤                   │                            │
│ 推理层              │                   │ Agent 自带 LLM             │
│ 本地模型 + 云端     │                   │                            │
├────────────────────┤                   ├────────────────────────────┤
│ Phronesis Layer     │                   │ CONC Skill (SKILL.md)      │
│ Collaboration Layer │    共享同一套      │ ← 行为指导：何时调用工具    │
│ Value Layer         │    协议语义层      ├────────────────────────────┤
│ Verification Layer  │◄═════════════════►│ CONC MCP Server            │
│ Genesis Layer       │                   │ ┌────────────────────────┐ │
│ Identity Layer      │                   │ │ MCP 接口层             │ │
│ Network Layer       │                   │ │ (Tools + Resources)    │ │
│                     │                   │ ├────────────────────────┤ │
│ 状态层              │                   │ │ CONC 协议引擎          │ │
│ SQLite + CRDT       │                   │ ├────────────────────────┤ │
│                     │                   │ │ 状态存储               │ │
│ 网络层              │                   │ ├────────────────────────┤ │
│ libp2p              │                   │ │ 网络层(后台)           │ │
└────────────────────┘                   │ └────────────────────────┘ │
                                         └────────────────────────────┘
```

### 关键区别

| 维度 | Track A | Track B |
|------|---------|---------|
| Agent 来源 | CONC 自研 | 任意 MCP 兼容 Agent |
| LLM | 自带（本地+云端） | Agent 自带 |
| 网络层 | libp2p 原生集成 | MCP Server 内部后台线程 |
| 状态存储 | SQLite + Automerge CRDT | SQLite（或 JSON 文件） |
| 用户界面 | CLI (conc) + Web Dashboard | Agent 自带 UI |
| 适用场景 | 深度用户、需要完全自主的节点 | 所有用户、零门槛接入 |
| **协议语义** | **完全相同** | **完全相同** |

### Track 选择指南

| 条件 | 推荐 Track |
|------|:---------:|
| 快速体验 CONC | Track B |
| 日常策元参与 | Track B |
| 完全自主运行（无外部依赖） | Track A |
| 边缘计算（本地推理优先） | Track A |
| 开发/测试 CONC 协议 | Track A |
| 将 CONC 嵌入已有 Agent 工作流 | Track B |
| 需要 CRDT 实时多端同步 | Track A |
| 社区推广和生态建设 | Track B |

### MCP 兼容性详述

Track B 模式下，CONC 功能通过 MCP 协议暴露为三种原语：

1. **Tool**：可调用的操作（如 `conc_seed_create`, `conc_genesis_create`, `conc_task_claim`, `conc_judgment_request` 等）
2. **Resource**：可读取的状态（如 `conc://me`, `conc://genesis/{id}`, `conc://nr/{ns_id}`, `conc://ccr/{ns_id}` 等）
3. **Prompt**：预定义的提示模板（如方向评审模板、决断请求模板）

任何实现 MCP 客户端协议的 Agent 均可通过标准 JSON-RPC 2.0 调用 CONC Server，无需了解 CONC 内部实现。

---

## 三、层间数据流

### 3.1 主流程：智权体领取任务令并提交（v1.0 保留 + v2.0 扩展）

```
智权体 n 领取任务令并提交:

  网络层(接收任务令广播)
    → 身份层(验证 n 的身份 + 能证 + 方向档案)
    → 策元层(验证 n ∈ g + 任务令 DAG 依赖检查 + 阶梯式燃烧参数)
    → 协作层(工作区文件锁定 + 产出物同步 + 事件广播 WORKSPACE_FILE_CHANGE)
    → 验证层(执行验证协议：AUTO/PEER(n)/MARKET)
    → 价值层(NR 四维更新 + VT 分配 + CCR 账本更新 + JC 记录)
    → Phronesis Layer(检查是否触发决断点 → 否则跳过)
    → 应用层(更新 UI/通知 Agent)
```

### 3.2 决断流程：决断点触发（v2.0 新增）

```
决断点触发:

  协作层(事件检测：方向偏差/资源瓶颈/优先级变动/协同机会)
    → Phronesis Layer(决断点匹配 JP-xxx + 介入协议启动)
    → 应用层(决断上下文呈现给智权体中的人)
    → 人通过应用层做出判断（Ed25519 签名）
    → Phronesis Layer(记录决断追踪 → GHF)
    → 协作层(执行决断：更新任务令/策元状态 + 广播 HUMAN_INTERVENTION 事件)
    → 策元层/验证层/价值层(级联状态更新)
```

### 3.3 协作流程：策元从创意到产出（v2.0 新增）

```
创意图元发布 → 协作流程:

  Phase 1: 网络层(广播创意图元) → 身份层(签名验证)
    → 策元层(ICP Phase 1: 种子广播 + 72h 激情窗口)

  Phase 2: 策元层(ICP Phase 2: 意向表达 + 三信号融合匹配)
    → 协作层(策元工作区初始化准备)

  Phase 3: 策元层(ICP Phase 3: 策元结晶 + PCP 签署)
    → 协作层(工作区创建 + GHF 初始化 + Gate 0 通过)
    → Phronesis Layer(JP-001: 策元方向确认 — 人的主权决策)

  策元运转:
    → 协作层(策元核编排 API → 任务令 DAG 拆解)
    → Phronesis Layer(JP-002: DAG 确认 — 人确认或修正)
    → 策元层(任务令三阶段分配：Step1 激情 → Step2 能力 → Step3 外源)
    → 协作层(文档生命周期 D1-D6 + Gate 1-4 门控)
    → 验证层(模块验证) → 价值层(VT/NR/CCR 更新)

  策元分裂/解散:
    → Phronesis Layer(JP-010: 分裂/解散决策 — 不可委托的主权决策)
    → 策元层(分裂操作 → 维护托管/创意退出/售后新策元)
    → 协作层(GHF 归档 → Filecoin)
```

---

## 四、身份层 (Identity Layer)

### 4.1 层职责定义（v2.0 扩展）

身份层是智权体在 CONC 网络中的注册与身份管理中心。v2.0 扩展了以下能力：
- L-1 外部信任锚点映射（GitHub/LinkedIn/链上身份 → 初始 NR 种子）
- 五维可组合子证明模型（替代 v1.0 简单自声明）
- 方向档案（Direction Profile）
- Judgment Credit 记录

### 4.2 智权体注册

```
POST /identity/register
  Request:
    {
      "public_key": "0x...",          // Ed25519 公钥
      "identity_anchors": [           // 身份锚定（至少一项）
        { "type": "github", "proof": "..." },
        { "type": "l1_task", "task_ids": ["tw_001", "tw_002", "tw_003"] }
      ],
      "initial_preferences": [0.2, 0.1, 0.5, 0.1, 0.1]  // 5维偏好向量
    }
  Response:
    {
      "noetic_id": "ns_0a1b2c3d",    // 智权体全局唯一 ID
      "base_cu_quota": 100,           // 基础 CU 配额
      "nr": { "R": 0.50, "Q": 0.50, "A": 0, "C": 15, "NR_total": 15 },
      "accelerator_active": true,
      "accelerator_tasks_remaining": 10
    }
```

### 4.3 L-1 外部信任锚点映射（v2.0 新增）

v2.0 引入五维可组合子证明模型，将外部身份平台的数据映射为 CONC 内部初始信誉：

| 外部锚点 | 映射维度 | 质量过滤规则 | 异常检测 |
|---------|:-------:|------------|---------|
| GitHub | 贡献度 C | ≥5 merged PR、≥10 stars → 通过 | 单日 >50 PR → 标记 |
| LinkedIn | 活跃度 A | 完整档案 + ≥2 背书 → 通过 | 新建账号 <30天 → 拒绝 |
| 链上身份 | 可靠性 R | 交易历史 >6个月 → 通过 | 大量空投交互 → 降权 |
| 学术平台 | 质量 Q | 出版物 ≥2 → 通过 | 引用环 → 标记 |
| 已有 NR | 综合 | NR_total ≥ 50 → 直接映射 | — |

子证明组合公式：
```
NR_seed = Σ(w_i × proof_score_i × freshness_decay_i)
```
其中 freshness_decay = e^(-λ × age_months)，λ = 0.05。

### 4.4 能证发行与查询

```
GET /identity/{ns_id}/capabilities
  Response:
    {
      "ns_id": "ns_0a1b2c3d",
      "capabilities": [
        { "skill_domain": "solidity", "level": 4, "signal_level": "L1", "evidence": [...] },
        { "skill_domain": "ui_design", "level": 3, "signal_level": "L0", "evidence": [...] }
      ],
      "ccr": 3.42,
      "ccr_percentile": 0.82,
      "nr": { "R": 0.88, "Q": 0.735, "A": 12, "C": 36.2, "NR_total": 241.8 },
      "jc_score": 3.2,
      "active_genesis_units": ["gu_001", "gu_003"]
    }
```

**三层信号体系**：

| 层级 | 名称 | 可信度 | 晋级条件 |
|:---:|------|:------:|---------|
| L0 | 自声明 | 低 | 创建时填写 |
| L1 | Skill 背书 | 中 | ≥1 个 Q≥0.6 的 PEER 评审通过 Skill |
| L1+ | 高置信背书 | 中高 | ≥3 个累计且平均 Q≥0.7 |
| L2 | 网络验证 | 高 | CI>0 或外部复用率≥60% |

### 4.5 方向档案（v2.0 新增）

```
GET /identity/{ns_id}/direction-profile
  Response:
    {
      "ns_id": "ns_0a1b2c3d",
      "core_values": ["开源教育", "技术平权", "儿童编程"],
      "direction_vector": [0.3, 0.8, 0.9, 0.2, 0.5],
      "historical_seeds": ["cs_001", "cs_015", "cs_023"],
      "commitment_pattern": {
        "avg_stick_rate": 0.92,
        "avg_engagement_hours_ratio": 1.05,
        "crisis_behavior": "stay_and_fight",
        "early_exit_rate": 0.08
      }
    }
```

### 4.6 Judgment Credit（v2.0 新增）

```
GET /identity/{ns_id}/judgment-credit
  Response:
    {
      "ns_id": "ns_0a1b2c3d",
      "jc_score": 3.2,
      "decision_history": [
        {
          "decision_id": "jc_001",
          "genesis_id": "gu_001",
          "context": "架构决策：选择 GraphQL vs REST",
          "outcome_quality": 0.8,
          "difficulty": 4,
          "uniqueness": 2,
          "timestamp": "2026-05-15T10:00:00Z"
        }
      ]
    }
```

JC 计算公式：
```
JC(n) = Σ w_k · outcome(d_k) · difficulty(d_k) · uniqueness(d_k)
```
其中 w_k = e^(-λ · age_k) 为时间衰减权重。

> **本体论免责声明**：JC 是 Phronesis 的可观测代理指标（observable proxy），而非 Phronesis 本身。协议层不会将 JC 数值与智权体的实际判断力混为一谈。

---

## 五、策元层 (Genesis Layer)

### 5.1 策元生命周期 API

```
POST /genesis/create
  Request:
    {
      "creator_ns_id": "ns_0a1b2c3d",
      "creative_seed": {
        "title": "开源儿童编程平台",
        "direction_vector": [0.1, 0.3, 0.6, 0.0, 0.0],
        "description_hash": "sha256:..."
      },
      "pcp_template": "software_product",   // L1 模板选择
      "pcp_customizations": {               // L2 定制项
        "reward_formula": "60_hours_40_output",
        "core_rotation_weeks": 2,
        "theta_similarity": 0.75
      },
      "initial_members": ["ns_0a1b2c3d", "ns_4d5e6f7g"]
    }
  Response:
    {
      "genesis_id": "gu_x9y8z7w6",
      "pcp_hash": "sha256:...",
      "theta": 0.75,
      "lifecycle_state": "forming",
      "intent_coalescence_broadcast_id": "icb_001"
    }
```

**语义**：CreateGenesis 是 CONC 协议的核心操作——它将一组创意相似的智权体转换为一个正式的策元。触发条件：意图聚结完成（sim ≥ θ）+ 创始成员 ≥ 2。此操作是**原子的**——策元节点和所有从属边在同一个事务中创建。

**复杂度**：O(|N₀|²) —— 需要创建内部协作边。对 |N₀| > 100 的批量创建施加速率限制。

---

```
POST /genesis/{gu_id}/join
  Request: { "ns_id": "ns_..." }
  Response: { "status": "joined", "membership_since": "t" }

POST /genesis/{gu_id}/leave
  Request: { "ns_id": "ns_...", "exit_type": "amicable" | "standard" }
  Response: { "status": "left", "nr_retained": true|false, "vt_retained": amount }

POST /genesis/{gu_id}/dissolve
  Request: { "initiator_ns_id": "ns_...", "reason": "project_complete"|"consensus_failure"|"quorum_lost" }
  Response: { "status": "dissolved", "final_vt_distribution": {...}, "ip_assignment": {...} }
```

### 5.2 策元核操作

```
POST /genesis/{gu_id}/core/rotate
  Request: { "current_core_ns_id": "ns_...", "next_core_ns_id": "ns_..." }
  // 仅当策元规模 ≥ 10 或轮值周期到期时有效

POST /genesis/{gu_id}/core/decision/challenge
  Request: { "challenger_ns_id": "ns_...", "decision_id": "dec_...", "endorsements": ["ns_...", ...] }
  // 需要 ≥ 20% 成员联名
```

### 5.3 PCP 运行时修正

```
POST /genesis/{gu_id}/pcp/amend
  Request: {
    "proposal": { "reward_formula": "70_output_30_hours" },
    "rationale_hash": "sha256:..."
  }
  // 触发全策元投票，需 > 50% 同意
```

### 5.4 任务令 DAG 依赖路由

任务令（Task Warrant）是策元内最小可分配、可验证的工作单元。通过 `depends_on` 与 `blocks` 字段，多个任务令可构成有向无环图（DAG），实现前序依赖自动路由。

**任务令数据模型扩展 (v3.1)**：

```json
{
  "task_warrant_id": "tw_...",
  "genesis_id": "gu_...",
  "state": "DRAFT",
  "depends_on": ["tw_001", "tw_002"],
  "blocks": ["tw_004"],
  "phronesis_profile": "none" | "gate" | "continuous",
  "decision_gates": [
    {"type": "ARCH_CHOICE", "description": "选择 OAuth2.0 流程类型"},
    {"type": "DESIGN_REVIEW", "description": "审核认证页面 UX 设计"}
  ],
  "suggested_assignee_profile": "execution" | "judgment",
  ...
}
```

| 字段 | 类型 | 语义 |
|------|------|------|
| `depends_on` | string[] | 前序依赖任务令 ID 列表。当前任务令必须在所有前序任务令达到 `MERGED_RESOLVED` 后才可进入 `BROADCAST`。 |
| `blocks` | string[] | 被阻塞的后继任务令 ID 列表。由 `depends_on` 逆向推导，协议层自动维护，客户端只读。若 tw_A.depends_on 包含 tw_B，则 tw_B.blocks 包含 tw_A。 |
| `phronesis_profile` **(v3.1)** | enum | `"none"` — 纯执行型（算力分摊），Agent 全自动，Phronesis 仅异常时触发；`"gate"` — 门控型（判断分叉），Agent 在 `decision_gates` 处暂停并提交 JUDGMENT_REQUEST；`"continuous"` — 连续判断型，人在循环中持续调整方向，任务令完成时 PEER_SYNC 综合评分。完整定义见 `19_Phronesis_Layer_Protocol.md` v2.0 §1.4。 |
| `decision_gates` **(v3.1)** | object[] | 仅 `phronesis_profile="gate"` 时有效。预声明的决策门类型 (ARCH_CHOICE / DESIGN_REVIEW / FEEDBACK_ITERATION / FORK_DECISION / RISK_ACCEPTANCE / PRIORITY_TRADEOFF)。Agent 执行到门控点暂停并提请人工判断。 |
| `suggested_assignee_profile` **(v3.1)** | enum | 软建议（非强制）——`"execution"` 建议分配给高 NR 执行型智权体，`"judgment"` 建议分配给高 JC 判断型智权体。不影响领取权限——仅影响 ICP 匹配加权。 |

**DAG 完整性约束**：

1. **无环约束**：创建/更新 `depends_on` 时执行 DFS 环路检测。若检测到环路 → 400 `TASK_WARRANT_CYCLE_DETECTED`。
2. **同策元约束**：`depends_on` 中所有任务令必须同属一个策元。跨策元依赖 → 402 `CROSS_GENESIS_DEPENDENCY_FORBIDDEN`。
3. **一致性约束**：`blocks` 为派生字段，不可直接写入。

**级联触发规则**：当前序任务令状态变为 `MERGED_RESOLVED` 时，协议层自动遍历其 `blocks` 列表，对每个后继任务令检查其全部 `depends_on` 是否均已满足。若满足，自动将其推入 `BROADCAST` 状态并触发网络层广播：

```
on_state_change(X, MERGED_RESOLVED):
  for each Y in X.blocks:
    if ∀ Z ∈ Y.depends_on: Z.state == MERGED_RESOLVED:
      Y.state ← BROADCAST
      broadcast(Y)
```

**API 端点**：

```
POST /task-warrant/create
  Request: {
    "genesis_id": "gu_...",
    "title": "...",
    "description_hash": "sha256:...",
    "verification_type": "AUTO" | "PEER" | "MARKET",
    "reward_vt_estimate": 150.0,
    "depends_on": ["tw_001", "tw_002"]
  }
  // 协议层自动计算 blocks 并回写被依赖任务令
  Response: {
    "task_warrant_id": "tw_003",
    "state": "DRAFT",
    "depends_on": ["tw_001", "tw_002"],
    "blocks": [],
    "dag_valid": true
  }

POST /task-warrant/{tw_id}/publish
  // DRAFT → BROADCAST。前置条件: ∀ d ∈ depends_on : d.state == MERGED_RESOLVED
  // 条件不满足 → 409 DEPENDENCY_NOT_SATISFIED

GET /task-warrant/{tw_id}/dag
  Response: {
    "task_warrant_id": "tw_003",
    "upstream": ["tw_001", "tw_002"],
    "downstream": ["tw_004"],
    "blocked_by_unresolved": []
  }
```

**环路检测**：

```
function detect_cycle(new_id, proposed_deps):
  visited ← {}
  for dep in proposed_deps:
    stack ← [dep]
    while stack ≠ ∅:
      cur ← stack.pop()
      if cur == new_id: return true
      if cur ∉ visited:
        visited.add(cur)
        stack.extend(cur.depends_on)
  return false
```

---

## 六、协作层 (Collaboration Layer) ★ v2.0 新增

### 6.1 层职责定义

协作层是 v2.0 协议栈的核心新增层，负责策元内部的协作基础设施。它从原规范的 DMS（文档管理系统）中提取并升级为独立协议层，包含四项核心能力：策元工作区（Workspace）、文档生命周期管理（D1-D6 + Gate 0-4）、策元事件总线（Event Bus）、协作 Skill 模板（Collaboration Pattern Skill）和策元核编排 API。

**理论追溯**：协作层对应 SBDEL 定理 S1（场景替代）在协作领域的推论——"协作模式是 Sophia 的一种特殊形式——它编码的不是'怎么做一件事'，而是'一群人怎么一起做事'"。同时对应本原零（治理本原）——"治理结构是人类为应对个体人性局限而自发选择的制度化模式"。

### 6.2 策元工作区（Genesis Workspace）

```json
{
  "protocol": "CONC-COLLAB-WORKSPACE-001",
  "genesis_id": "gu_x9y8z7w6",
  "zones": {
    "public": {
      "path": "/shared/",
      "permissions": "read:all_members|write:all_members",
      "conflict_strategy": "coordinator_arbitration",
      "file_locking": true
    },
    "private": {
      "path": "/private/{ns_id}/",
      "permissions": "read:owner+coordinator|write:owner",
      "auto_publish_on_task_complete": true
    },
    "archive": {
      "path": "/archive/{tw_id}/",
      "permissions": "read:all_members|write:none",
      "retention_days": 365
    }
  },
  "storage_backend": {
    "primary": "Git (策元仓库)",
    "sync": "CRDT (Automerge, Track A) / MCP Server同步 (Track B)",
    "persistence": "IPFS + Filecoin (归档)"
  }
}
```

### 6.3 策元历史文件（GHF — Genesis History File）

```
ghf/
├── 00_genesis/
│   ├── creative_seed.json          # 创意图元原始声明
│   ├── icp_match_results.json      # ICP 匹配结果
│   ├── pcp_v1.0.md                 # PCP 初始版本
│   └── pcp_peer_review.json        # PCP 评审记录
├── 01_design_inputs/
│   ├── requirements_spec.md        # 需求规格
│   └── gate1_review.json           # Gate 1 评审记录
├── 02_design_outputs/
│   ├── architecture_decisions/     # 架构决策记录 (ADR)
│   ├── task_warrant_dag.json       # 任务令依赖图
│   └── gate2_review.json           # Gate 2 评审记录
├── 03_verification/
│   ├── auto_test_reports/          # AUTO 验证报告
│   ├── peer_review_reports/        # PEER 评审报告
│   └── gate3_review.json           # Gate 3 评审记录
├── 04_validation/
│   ├── user_acceptance_tests/      # 用户验收测试
│   └── gate4_review.json           # Gate 4 评审记录
├── 05_changes/
│   ├── CR-001_*.json               # 变更请求记录
│   └── branch_merge_history.json   # 弹性分叉历史
├── 06_dissolution/
│   ├── final_audit_report.md       # 最终审计报告
│   └── archive_cid.json            # Filecoin 归档 CID
├── 07_phronesis/
│   ├── judgment_traces.json        # 决断追踪记录
│   └── boost_history.json          # 加力历史
└── GHF_INDEX.json                  # 全局索引（IPFS 锚定）
```

### 6.4 策元事件总线（Genesis Event Bus）

```json
{
  "protocol": "CONC-COLLAB-EVENTS-001",
  "event_types": {
    "TASK_WARRANT_STATE_CHANGE": {
      "description": "任务令状态变更",
      "triggers": ["depends_on 全部满足 → 自动通知下游", "MERGED_RESOLVED → 级联触发"],
      "subscribers": ["downstream_task_assignees", "coordinator"]
    },
    "WORKSPACE_FILE_CHANGE": {
      "description": "工作区文件变更",
      "triggers": ["文件新增/修改 → 通知相关任务令承接者"],
      "subscribers": ["related_task_assignees", "coordinator"]
    },
    "WORKSPACE_CONFLICT": {
      "description": "工作区写入冲突",
      "resolution": "auto_merge | coordinator_arbitration | peer_merge_request",
      "subscribers": ["conflicting_parties", "coordinator"]
    },
    "IDLE_CAPACITY": {
      "description": "智权体 Agent 空闲",
      "triggers": ["当前任务完成 + 无其他认领 → 通知策元核或自动认领"],
      "subscribers": ["coordinator", "idle_ns"]
    },
    "MILESTONE_REACHED": {
      "description": "关键里程碑（DAG 某层全部 MERGED_RESOLVED）",
      "triggers": ["通知所有成员", "触发 Gate 门控"],
      "subscribers": ["all_members"]
    },
    "HUMAN_INTERVENTION": {
      "description": "人的主动介入事件（由 Phronesis Layer 发出）",
      "subtypes": ["DIRECTION_CORRECTION", "PRIORITY_OVERRIDE", "RESOURCE_BOOST", "SYNERGY_BOOST"],
      "subscribers": ["all_members", "coordinator"]
    }
  },
  "transport": "网络层消息广播 + 策元级事件过滤",
  "persistence": "事件日志写入 GHF",
  "ordering": "因果序（Lamport 时间戳）"
}
```

### 6.5 Gate 门控体系

```
Gate 0: ICP 意图聚结验证（sim ≥ θ + 能证覆盖检查）
Gate 1: PCP + 需求规格 PEER(3) 评审
Gate 2: 架构设计 PEER(3) 评审 + DAG 依赖完整性检查
Gate 3: 模块验证（AUTO/PEER/MARKET）+ 集成测试
Gate 4: 策元核 + 外部消费者代表确认
```

### 6.6 文档生命周期六阶段

```
D1 创建 → D2 审批(PEER/AUTO) → D3 发布(Git+IPFS) → D4 执行(按文档执行) → D5 变更(Branch→PEER→Merge) → D6 归档(Filecoin)
```

### 6.7 协作模式 Skill 模板

```json
{
  "protocol": "CONC-COLLAB-SKILL-001",
  "skill_type": "COLLABORATION_PATTERN",
  "sophia_layer": {
    "pattern_name": "敏捷软件产品策元",
    "applicable_scenarios": ["软件产品开发", "SaaS 工具构建"],
    "recommended_roles": [
      { "role_name": "产品方向", "responsibilities": ["需求定义", "优先级排序"], "suggested_skill_domains": ["product_management"] },
      { "role_name": "技术架构", "responsibilities": ["架构设计", "技术选型"], "suggested_skill_domains": ["software_architecture"] },
      { "role_name": "前端实现", "responsibilities": ["UI 实现", "交互开发"], "suggested_skill_domains": ["frontend_development"] },
      { "role_name": "后端实现", "responsibilities": ["API 开发", "数据模型"], "suggested_skill_domains": ["backend_development"] },
      { "role_name": "质量保障", "responsibilities": ["测试策略", "PEER 评审"], "suggested_skill_domains": ["testing", "code_review"] }
    ],
    "dag_template": {
      "parallel_phases": [["需求分析", "技术调研"]],
      "sequential_phases": [["架构设计"], ["并行开发(前端+后端)"], ["集成测试"]],
      "final_phase": ["用户验收", "发布"]
    },
    "gate_sequence": ["Gate_0: ICP验证", "Gate_1: 需求评审", "Gate_2: 架构评审", "Gate_3: 集成验证", "Gate_4: 用户确认"]
  },
  "phronesis_note": "判断力残余：何时启动此模式、角色是否需要增减、优先级如何调整——取决于策元核中人的实践智慧，不可编码。"
}
```

### 6.8 API 端点列表

```
# 工作区管理
POST /genesis/{id}/workspace/init        — 初始化策元工作区
GET  /genesis/{id}/workspace/files       — 列出工作区文件
POST /genesis/{id}/workspace/lock        — 锁定文件
POST /genesis/{id}/workspace/release     — 释放文件锁定

# 文档管理
POST /genesis/{id}/docs/create           — 创建策元文档
POST /genesis/{id}/docs/{doc_id}/review  — 提交文档评审
POST /genesis/{id}/docs/{doc_id}/publish — 发布文档

# GHF
GET  /genesis/{id}/ghf                   — 获取策元历史文件索引
GET  /genesis/{id}/ghf/gate/{gate_id}    — 获取特定 Gate 的评审记录

# 事件总线
GET  /genesis/{id}/events                — 获取策元事件（支持 since/types 过滤）

# 编排
POST /genesis/{id}/orchestrate/decompose — 任务令 DAG 拆解
POST /genesis/{id}/orchestrate/assign    — 任务令分配
POST /genesis/{id}/orchestrate/rebalance — 重新平衡
GET  /genesis/{id}/orchestrate/status    — 协作全景视图

# 协作 Skill
GET  /collab/skills                      — 搜索协作模式 Skill
POST /collab/skills                      — 发布协作模式 Skill
GET  /collab/skills/{skill_id}           — 获取协作 Skill 详情
```

### 6.9 层间接口定义

| 上层 | 接口方向 | 接口内容 |
|------|:-------:|---------|
| Phronesis层 | → 协作层 | 查询决断点上下文、执行决断后的状态更新 |
| 验证层 | → 协作层 | Gate 门控触发验证请求 |
| 协作层 | → 策元层 | 查询策元成员/任务令状态 |
| 协作层 | → 身份层 | 查询成员身份和能证（权限检查） |
| 协作层 | → 网络层 | 广播工作区事件 |

---

## 七、验证层 (Verification Layer)

### 7.1 模块验证协议

```
POST /verification/submit
  Request: {
    "task_warrant_id": "tw_...",
    "deliverable_hash": "sha256:...",
    "verification_type": "AUTO" | "PEER" | "MARKET",
    "verification_params": {
      // AUTO: { "test_suite_hash": "sha256:..." }
      // PEER: { "reviewer_count": 2, "consensus_threshold": 0.67 }
      // MARKET: { "metric": "user_retention_30d", "target": 0.4, "observation_window_days": 30 }
    }
  }
  Response: {
    "verification_id": "ver_...",
    "status": "pending_review" | "auto_verified" | "awaiting_market_data"
  }
```

### 7.2 PEER(n) 评审体系（v2.0 扩展）

**四维度评分**：

| 维度 | 权重 | 分值范围 |
|------|:----:|:-------:|
| 完成度 (Completeness) | 0.25 | 1-5 |
| 质量 (Quality) | 0.40 | 1-5 |
| 接口合规 (Interface Compliance) | 0.20 | 1-5 |
| 时效性 (Timeliness) | 0.15 | 1-5 |

**PEER(n) 聚合公式**：
```
score_aggregated = Σ(score(r) × weight(r)) / Σ(weight(r))
```
其中 weight(r) = NR_reliability(r) × recency_factor(r) × expertise_factor(r, task)

**争议升级路径**：PEER(3) → PEER(5) 加权中位数 → 策元全体评审（终局裁决）

**验证结果状态机**：

```
pending → (AUTO: running) → passed | failed
pending → (PEER: awaiting_reviews) → collecting → (consensus_reached) → passed | failed
pending → (MARKET: collecting_data) → observation_complete → passed | failed
```

### 7.3 争议仲裁

```
POST /verification/{ver_id}/dispute
  Request: {
    "disputer_ns_id": "ns_...",
    "dispute_reason": "verification_error" | "reviewer_bias" | "market_data_disputed"
  }
  // 触发策元内仲裁流程（PCP 定义的争议解决协议）
```

### 7.4 验证层 API 完整列表

```
POST /verification/submit              — 提交验证请求
POST /peer-review/assign               — 分配评审者
POST /peer-review/submit               — 提交评审评分
GET  /peer-review/verdict/{task_id}    — 查询裁决状态
POST /peer-review/dispute              — 发起争议
GET  /peer-review/reviewer/{ns_id}/stats — 查询评审者统计
GET  /peer-review/pool/{genesis_id}    — 查询策元评审者池
POST /verification/{ver_id}/dispute    — 提出验证争议
```

---

## 八、价值层 (Value Layer)

### 8.1 VT（价值通证）操作

```
POST /value/vt/allocate
  Request: {
    "task_warrant_id": "tw_...",
    "verification_id": "ver_...",
    "verification_outcome": "passed"
  }
  Response: {
    "vt_amount": 150.0,
    "recipient_ns_id": "ns_...",
    "vt_transaction_id": "vtx_..."
  }
  // 仅在验证通过后由协议自动调用。不可手动触发。

GET /value/vt/balance/{ns_id}
  Response: {
    "total_vt": 2500.0,
    "liquid_vt": 1800.0,
    "staked_vt": 700.0
  }
```

### 8.2 NR 统一状态机（v2.0 重构）

NR 从 v1.0 的单维标量重构为四维向量：

```json
{
  "ns_id": "ns_0a1b2c3d",
  "nr_vector": {
    "R": 0.88,   // 可靠性 [0,1] — 交付准时性
    "Q": 0.735,  // 质量 [0,1] — PEER 评审质量
    "A": 12.0,   // 活跃度 [0,∞) — 近期参与频次
    "C": 36.2    // 贡献度 [0,∞) — 净贡献（CCR 映射）
  },
  "NR_total": 241.8,
  "NR_percentile": 72
}
```

**NR 复合公式**：
```
NR_total = NR_base · R · Q · min(1, A/A_ref) · ln(1 + C)
```
其中 NR_base = 100，A_ref = 10。

**五大更新来源优先级**：

| 来源 | 协议 | 影响维度 | 优先级 |
|:---:|------|:-------:|:------:|
| SRC_SLASH | 阶梯式燃烧 | R, C | 1（最高） |
| SRC_CCR | CCR 公开账本 | C | 2（高） |
| SRC_PEER | PEER 评审 | Q, R | 3（常规） |
| SRC_CP | CP 晋级 | Q | 3（常规） |
| SRC_FORK | 弹性分叉 | A, C | 4（低） |

**NR 衰减**：半衰期 14 个月，各维度差异化衰减（R 标准 / Q ×1.5 / A ×3.0 / C ×0.5）

**NR 转移税**：τ_NR = 0.30（30% 销毁）

**新入者加速器**：前 10 个任务令 × 2.0 权重，NR < 50 时激活

### 8.3 CCR 公开账本（v2.0 新增）

```
GET /ccr/{ns_id}
  Response: {
    "ns_id": "ns_0a1b2c3d",
    "ccr": {
      "instant": 3.42,
      "window_30d": 4.15,
      "window_90d": 3.28,
      "trend": { "value": 0.265, "label": "strongly_improving" },
      "percentile_rank": 0.82
    }
  }
```

**CCR 瞬时公式**：
```
CCR_instant(n, t) = Σ(VT_i · q_i · m_i · e^(-λ_d(t - t_i))) / Σ(CU_j · e^(-λ_d(t - t_j)))
```
时间衰减半衰期 180 天，验证模式权重 m_AUTO=1.0, m_PEER=0.8, m_MARKET=0.6。

**CCR 策元边界隐私护盾（v3.0 新增）**：

> 对应 P1-4（CCR隐私与法律护盾）。CCR 的公开性是抵御"壳公司面纱穿透"指控的核心机制——类比上市公司强制披露，法院极难认定策元为壳公司的"工具"。

| 可见性边界 | 数据粒度 | 法律意义 |
|:---|:---|:---|
| **策元内部** | 完全透明——每个成员的 VT、CU、JC 均可被策元内其他成员查看 | 成员需要知道彼此贡献以进行 PCP 分配 |
| **策元间** | 仅聚合流通——"该策元总 CCR=1.2"、"该策元成员数=5"——不暴露个人CCR数据 | 类比上市公司年报中的"员工总数"和"人均营收"——够公开但不暴露个人信息 |
| **网络公开** | 全局统计——CCR 分布的幂律指数、行业平均 CCR——不暴露任何策元级或个人级数据 | 类比 SEC Edgar 公开数据库——透明但不侵扰 |

```json
// GET /ccr/{ns_id} 的策元外响应（聚合模式）
{
  "gu_id": "gu_...",
  "gu_aggregate": {
    "member_count": 5,
    "total_ccr": 6.12,
    "mean_ccr": 1.22,
    "ccr_variance": 0.15,
    "top_contributor_ratio": 0.28
  },
  "privacy_note": "PBA-COMPLIANT: 策元外仅返回聚合数据。成员明细仅策元内部可见。"
}
```

**法律护盾核心**：CCR 的公开聚合数据使策元的活动对监管透明——就像上市公司的季报使监管能监督其财务状况而不需查看每个员工的工资单。Ostrom "边界清晰"原则——共同体的边界定义了谁需要知道什么。

### 8.4 ALP 流动性池操作

```
POST /value/alp/stake
  Request: { "ns_id": "ns_...", "vt_amount": 500.0, "genesis_id": "gu_..." }
  Response: { "staked_vt": 500.0, "credit_line": 300.0, "discount_rate": 0.60 }

POST /value/alp/borrow
  Request: { "ns_id": "ns_...", "stablecoin_amount": 200.0 }
  Response: { "borrowed": 200.0, "interest_rate_apy": 0.03 }
  // 熔断条件: ALP 储备率 < 0.25 → 返回 503 ALP_CIRCUIT_BREAKER_ACTIVE

GET /value/alp/status
  Response: {
    "reserve_ratio": 0.42,
    "total_staked_vt": 1500000.0,
    "total_borrowed_stablecoin": 600000.0,
    "circuit_breaker": "inactive",
    "insurance_pool_balance": 15000.0,
    "current_base_discount_rate": 0.60
  }
```

---

## 九、Phronesis Layer（决断层）★ v2.0 新增

### 9.1 层职责定义

Phronesis Layer 是 v2.0 协议栈的核心创新层，负责将人的判断力从"理论上不可替代"升级为"协议上可执行"。它不编码判断力的内容，而是定义判断力介入的结构：决断点注册（Judgment Point Registry）、介入协议（Intervention Protocol）、加力类型（Boost Types）、决断追踪（Judgment Trace）。

**理论追溯**：Phronesis Layer 对应 SBDEL 的 Sophia/Phronesis 双层结构——"Agent 可以存储 Sophia（Skill），但无法生成 Phronesis（判断力）"；以及本原一（人有创造潜能）——人的不可替代性存在于创意方向、判断力和信任关系三个维度。

**核心命题**：Phronesis 不可编码，但可以协议化——不编码"判断力的内容"，而是定义"判断力介入的结构"。

### 9.2 决断点注册表

```json
{
  "protocol": "CONC-PHRONESIS-POINTS-001",
  "judgment_points": {
    "JP-001": {
      "name": "策元方向确认",
      "location": "ICP Phase 3 → 策元结晶",
      "intervention_type": "DIRECTION",
      "mandatory": true,
      "note": "策元结晶始终是人的主权决策"
    },
    "JP-002": {
      "name": "任务令 DAG 确认",
      "location": "策元核编排 API → DAG 生成后",
      "intervention_type": "DIRECTION",
      "mandatory": true
    },
    "JP-003": {
      "name": "关键任务令认领",
      "location": "任务令 BROADCAST → 认领",
      "intervention_type": "DIRECTION",
      "mandatory": false,
      "auto_detect": true,
      "detect_condition": "task_warrant.priority == CRITICAL_PATH"
    },
    "JP-004": {
      "name": "方向偏差修正",
      "location": "协作层事件：方向偏差检测",
      "intervention_type": "DIRECTION",
      "mandatory": false,
      "auto_detect": true,
      "detect_condition": "direction_deviation > theta_deviation"
    },
    "JP-005": {
      "name": "资源瓶颈突破",
      "location": "协作层事件：BLOCKED / ESCALATED",
      "intervention_type": "RESOURCE",
      "mandatory": false,
      "auto_detect": true,
      "detect_condition": "task_warrant.state == BLOCKED && duration > threshold"
    },
    "JP-006": {
      "name": "优先级重排",
      "location": "协作层事件：外部环境变化",
      "intervention_type": "PRIORITY",
      "mandatory": false,
      "auto_detect": false
    },
    "JP-007": {
      "name": "协同加力",
      "location": "策元运转中任意时刻",
      "intervention_type": "SYNERGY",
      "mandatory": false,
      "auto_detect": false
    },
    "JP-008": {
      "name": "PEER 评审中的最终判断",
      "location": "验证层 PEER 评审完成后",
      "intervention_type": "DIRECTION",
      "mandatory": false,
      "auto_detect": true,
      "detect_condition": "peer_review.consensus_reached == false"
    },
    "JP-009": {
      "name": "协作模式选择",
      "location": "策元结晶后 → 协作 Skill 模板推荐",
      "intervention_type": "DIRECTION",
      "mandatory": true
    },
    "JP-010": {
      "name": "策元分裂/解散决策",
      "location": "策元运转中——方向分歧或目标达成",
      "intervention_type": "DIRECTION",
      "mandatory": true,
      "note": "不可委托的主权决策"
    }
  }
}
```

### 9.3 四种加力类型（Boost Types）

| 加力类型 | 对应决断点 | 操作 | 效果 |
|---------|:---------:|------|------|
| **方向加力 (DIRECTION_BOOST)** | JP-001,002,004,008,009,010 | 修正方向向量、调整创意图元、否决自动决策 | 后续任务令匹配和优先级重新计算 |
| **资源加力 (RESOURCE_BOOST)** | JP-005 | 注入额外 CU、升级模型、引入外部专家、拆解任务 | 任务令执行能力提升 |
| **优先级加力 (PRIORITY_BOOST)** | JP-006 | 重排 DAG 优先级、插入紧急任务、暂停非关键路径 | DAG 执行顺序调整 |
| **协同加力 (SYNERGY_BOOST)** | JP-007 | 建立协作边、创建跨智权体子任务、调整模型路由 | 产生新协作关系 |

### 9.4 介入协议流程

```
Step 1: 决断点触发（auto_detect 或人主动发起）→ INTERVENTION_REQUEST 事件
Step 2: 智契为决断者准备上下文（聚合相关状态 + 检索历史决断 + 呈现可选方案）
Step 3: 人做出判断（智契 UI 呈现 → 人选择/输入 → Ed25519 签名）
Step 4: 决断转化为协议操作（更新状态 + 广播 HUMAN_INTERVENTION 事件）
Step 5: 决断记录写入 GHF（judgment_point_id + ns_id + decision + context_snapshot + timestamp + signature）
```

### 9.5 决断追踪（Judgment Trace）

```json
{
  "trace_id": "jt_x1y2z3w4",
  "judgment_point": "JP-001",
  "ns_id": "ns_0a1b2c3d",
  "decision": "确认策元结晶——方向一致，成员技能互补",
  "context_hash": "sha256:...",
  "outcome": {
    "state_change": "ICP Phase 3 → 策元 ACTIVE"
  },
  "timestamp": "2026-05-25T14:00:00Z",
  "signature": "ed25519:..."
}
```

**决断追踪的聚合用途**：
- 每个智权体的决断历史 → 用于 Judgment Credit 计算
- 每个策元的决断全景 → 用于协作模式 Skill 的事后提炼

### 9.6 API 端点列表

```
# 决断请求
POST /judgment/request
  Request: {
    "judgment_type": "direction" | "quality" | "risk" | "conflict",
    "context": "string (上下文描述)",
    "options": ["option_a", "option_b", "..."],
    "agent_recommendation": "string (optional — AI 的推荐)",
    "risk_level": "low" | "medium" | "high" | "critical"
  }
  Response: { "judgment_id": "jt_x1y2z3w4", "status": "pending" }

# 决断响应
POST /judgment/{judgment_id}/respond
  Request: {
    "choice": "option_a",
    "rationale": "string (optional — 人的理由)"
  }
  Response: { "judgment_id": "jt_x1y2z3w4", "status": "recorded" }

# JC 记录（需策元核签名）
POST /judgment/credit/record
  Request: {
    "judge_ns_id": "ns_...",
    "decision_context": "...",
    "outcome_quality": 0.8,
    "difficulty": 4,
    "uniqueness": 2
  }
  Response: { "decision_id": "jc_001", "jc_delta": 0.64, "jc_total": 3.84 }

# 加力操作
POST /genesis/{id}/boost/direction    — 方向加力
POST /genesis/{id}/boost/resource     — 资源加力
POST /genesis/{id}/boost/priority     — 优先级加力
POST /genesis/{id}/boost/synergy      — 协同加力

# 查询
GET  /judgment/points                 — 获取所有决断点定义
GET  /judgment/{judgment_id}          — 查询决断详情
GET  /judgment/traces/{ns_id}         — 查询智权体决断历史
GET  /judgment/traces/genesis/{id}    — 查询策元决断全景
```

### 9.7 层间接口定义

| 上层 | 接口方向 | 接口内容 |
|------|:-------:|---------|
| 应用层 | → Phronesis层 | 呈现决断上下文、接收人的判断输入 |
| Phronesis层 | → 协作层 | 执行决断后的状态更新、广播 HUMAN_INTERVENTION |
| Phronesis层 | → 策元层 | 方向修正（更新方向向量）、资源注入 |
| Phronesis层 | → 价值层 | 记录 JC（决断结果→JC 更新） |
| Phronesis层 | → 网络层 | 广播 HUMAN_INTERVENTION 事件 |
| 协作层 | → Phronesis层 | 触发决断事件（IDLE_CAPACITY / BLOCKED / 方向偏差） |

---

### 9.8 Phronesis边界审计（PBA）子协议（v3.0 新增）

> 对应定理 PBA1-PBA3（`01_Core/02_Core_Axioms.md` §PBA 定理层）和模型 `02_Models/04_Phronesis_Morphology_Evolution.md`。PBA 不"读取"Phronesis——而是追踪五个锚定点的变化轨迹，实现 Sophia/Phronesis 二元域的边界审计。

**PBA 锚定点与协议接口**：

| 锚定点 | 追踪指标 | API 端点 | 触发事件 |
|:---|:---|:---|:---|
| PBA-001 | 策元核中人类决策占比 | `GET /phronesis/pba/decision_ratio?gu_id=...` | 策元闭环事件 `genesis_unit.complete()` |
| PBA-002 | HITL 触发频率 | `GET /phronesis/pba/hitl_frequency?window=30d` | 每次 HUMAN_INTERVENTION 事件 |
| PBA-003 | 方向性分歧需人类裁决占比 | `GET /phronesis/pba/divergence_rate?window=90d` | ICP 协议日志 |
| PBA-004 | 安全否决中人类发起占比 | `GET /phronesis/pba/safety_veto_ratio` | JP-003/JP-005 安全决断点日志 |
| PBA-005 | JC 得分的幂律分布指数 | `GET /phronesis/pba/jc_distribution` | JC 更新事件 |

```json
// GET /phronesis/pba/snapshot 响应示例
{
  "timestamp": "2026-07-10T00:00:00Z",
  "P_d_estimate": 0.27,
  "anchors": {
    "PBA-001": { "human_decision_ratio": 0.73, "trend": "stable" },
    "PBA-002": { "hitl_events_per_100_ops": 12.4, "trend": "declining_slow" },
    "PBA-003": { "divergence_intervention_rate": 0.08, "trend": "stable" },
    "PBA-004": { "human_safety_veto_ratio": 0.94, "trend": "stable" },
    "PBA-005": { "jc_power_law_alpha": 2.1, "trend": "stable" }
  },
  "lambda_auto_estimate": 0.07,
  "mu_new_estimate": 0.05
}
```

### 9.9 JC 行业分类计分规则（v3.0 新增）

> 对应 P1-5（JC行业分类与古德哈特防御）。不同行业的判断力类型（安全型/权衡型/品味型）适用不同的JC计分和刷分检测规则。

| 判断力类型 | 行业示例 | σ_GU范围 | 刷分检测力度 | 触发条件 |
|:---|:---|:---:|:---|:---|
| **安全型** | 制药、航天 | 0.7-1.0 | 严格 | 分歧频率超出行业基线2σ → 自动触发审计 |
| **权衡型** | 半导体、金融科技 | 0.3-0.7 | 中等 | 分歧频率超出基线1.5σ → 标记待审 |
| **品味型** | 软件、内容/媒体 | 0.0-0.3 | 宽松 | 不触发自动审计（品味差异正常） |

**古德哈特防御**：独立合规策元的对抗性质询（adversarial challenge）记为JC正向贡献，权重×1.5——使"发现漏洞"比"维持高分"更有激励价值。

---

## 十、网络层 (Network Layer)

### 10.1 节点发现

```
GET /network/peers
  Response: {
    "known_peers": ["node_001", "node_002", ...],
    "peer_count": 47,
    "connected_count": 42
  }

POST /network/broadcast
  // 内部协议，由策元层和验证层触发
  // v2.0 广播类型扩展:
  //   INTENT_COALESCENCE_SEED, INTENT_EXPRESSION_RECEIVED, INTENT_EXPRESSION_ACCEPTED,
  //   THRESHOLD_MET, GENESIS_CREATED, GENESIS_DISSOLVED,
  //   GENESIS_SOFT_FORKED, GENESIS_HARD_FORKED, GENESIS_MERGE_COMPLETED,
  //   TASK_WARRANT_AVAILABLE, TASK_WARRANT_STATE_CHANGE,
  //   VERIFICATION_RESULT, NR_UPDATE, CCR_UPDATE,
  //   WORKSPACE_FILE_CHANGE, WORKSPACE_CONFLICT, MILESTONE_REACHED,
  //   HUMAN_INTERVENTION
```

### 10.2 广播消息类型完整清单（v2.0 扩展）

| 消息类型 | 来源层 | 触发条件 |
|---------|:-----:|---------|
| `INTENT_COALESCENCE_SEED` | 策元层 | 新创意图元发布 |
| `INTENT_EXPRESSION_RECEIVED` | 策元层 | 收到意向表达 |
| `INTENT_EXPRESSION_ACCEPTED` | 策元层 | 意向被接受 |
| `THRESHOLD_MET` | 策元层 | 结晶条件满足 |
| `GENESIS_CREATED` | 策元层 | 策元创建 |
| `GENESIS_DISSOLVED` | 策元层 | 策元解散 |
| `GENESIS_SOFT_FORKED` | 策元层 | 软分叉创建 |
| `GENESIS_HARD_FORKED` | 策元层 | 硬分叉执行 |
| `GENESIS_MERGE_COMPLETED` | 策元层 | 软分叉合并完成 |
| `TASK_WARRANT_AVAILABLE` | 策元层 | 新任务令发布 |
| `TASK_WARRANT_STATE_CHANGE` | 策元层 | 任务令状态变更 |
| `VERIFICATION_RESULT` | 验证层 | 验证结果发布 |
| `NR_UPDATE` | 价值层 | NR 变化 |
| `CCR_UPDATE` | 价值层 | CCR 变化 |
| `WORKSPACE_FILE_CHANGE` | 协作层 | 工作区文件变更 |
| `WORKSPACE_CONFLICT` | 协作层 | 工作区写入冲突 |
| `MILESTONE_REACHED` | 协作层 | 关键里程碑达成 |
| `HUMAN_INTERVENTION` | Phronesis层 | 人的主动介入事件 |

### 10.3 离线缓存与同步

```
POST /network/sync
  Request: {
    "ns_id": "ns_...",
    "last_synced_timestamp": "2026-05-14T00:00:00Z",
    "offline_duration_hours": 72
  }
  Response: {
    "new_genesis_units": [...],
    "task_warrant_updates": [...],
    "nr_changes": [...],
    "missed_events": [...],
    "missed_creative_recalibration": true
  }
  // 若离线超过 72 小时 → 策元状态置为 "paused"，NR衰减暂停计时
```

### 10.4 层间接口定义（v2.0 扩展）

| 上层 | 接口方向 | 接口内容 |
|------|:-------:|---------|
| 身份层 | ↓ 网络层 | 发送签名消息（身份层提供 Ed25519 签名） |
| 策元层 | ↓ 网络层 | 广播策元事件（ICP/任务令/分裂） |
| 验证层 | ↓ 网络层 | 广播验证结果 |
| 价值层 | ↓ 网络层 | 广播 NR/CCR 更新 |
| 协作层 | ↓ 网络层 | 广播工作区事件 |
| Phronesis层 | ↓ 网络层 | 广播人的介入事件 |
| 网络层 | ↑ 全部上层 | 将接收的消息路由到对应层的事件处理器 |

---

## 十一、应用层 (Application Layer) v2.0 扩展

### 11.1 Track A 应用层

```
CLI (conc) 命令:
  conc init <标题>            — 创建创意图元
  conc seed publish           — 广播创意图元
  conc seed status            — 查看匹配结果
  conc genesis join <id>      — 加入策元
  conc genesis create <标题>  — 创建策元
  conc task list              — 查看任务令
  conc task claim <id>        — 认领任务令
  conc task submit <id>       — 提交结果
  conc me ccr                 — 查看 CCR
  conc me nr                  — 查看 NR
  conc me jc                  — 查看 JC
  conc judgment respond <id>  — 响应决断请求 (v2.0 新增)

本地 Web Dashboard (localhost:9744):
  - 意图池浏览器
  - 策元看板（Kanban 视图）
  - 网络图谱
  - CCR/NR/JC 仪表板
  - 决断控制台 (v2.0 新增)
```

### 11.2 Track B 应用层

Track B 模式下，应用层由宿主 Agent 自带。CONC 通过以下 MCP Resources 提供数据：

```
conc://me                           — 当前智权体完整身份信息
conc://seeds                        — 已知创意图元列表
conc://genesis/{id}                 — 策元详情
conc://tasks/{id}                   — 任务令详情
conc://tasks/{id}/dag               — 任务令 DAG 图
conc://nr/{ns_id}                   — 声誉积分
conc://ccr/{ns_id}                  — 贡献-消费比率
conc://ccr/{genesis_id}/ledger      — 策元 CCR 公开账本
conc://jc/{ns_id}                   — 判断力信用
conc://profile/{ns_id}              — 方向档案
conc://genesis/{id}/ghf             — 策元历史文件索引
conc://network/peers                — 已知对等节点列表
```

---

## 十二、PCP 模板 JSON Schema

```json
{
  "$schema": "https://conc-protocol.org/pcp-template-schema.json",
  "pcp_template_id": "software_product_v1",
  "display_name": "软件产品策元模板",
  "description": "适用于以软件产品为产出的策元。包含敏捷迭代、代码审查和开源许可条款。",
  "fixed_params": {
    "minimum_members": 2,
    "maximum_members": 50,
    "core_production_method": "cycle",
    "governance_model": "rotating_core",
    "default_rotation_weeks": 2,
    "challenge_threshold": 0.20,
    "creative_recalibration_interval_weeks": 13,
    "dissolution_vote_threshold": 0.67
  },
  "customizable_params": {
    "reward_formula": {
      "type": "enum",
      "options": ["equal_split", "hours_weighted", "output_weighted", "60_hours_40_output", "70_output_30_hours"],
      "default": "60_hours_40_output"
    },
    "theta_similarity": {
      "type": "float",
      "range": [0.5, 0.95],
      "default": 0.70
    },
    "verification_default": {
      "type": "enum",
      "options": ["AUTO", "PEER_2", "PEER_3"],
      "default": "PEER_2"
    },
    "special_contribution_weight": {
      "type": "float",
      "range": [1.0, 3.0],
      "default": 1.5
    }
  },
  "runtime_amendable_params": [
    "reward_formula",
    "theta_similarity",
    "special_contribution_weight"
  ],
  "ip_assignment": {
    "default_license": "MIT",
    "contributor_rights": "non_exclusive_perpetual"
  },
  "dissolution_procedure": {
    "asset_liquidation": "pro_rata_by_vt",
    "ip_assignment": "joint_ownership_all_contributors",
    "responsibility_tail_period_years": 3
  }
}
```

---

## 十三、外部系统桥接接口

### 13.1 策元外壳绑定接口 & 主权策元基础设施绑定（v3.0 扩展）

> **v3.0 主权策元生产范式重构**：主权策元 = 基础设施生产者（算力、公共平台、数据标准、政策优惠）。方向从市场信号（VT/NR/CU的消费模式）中涌现，不由委员会定义。对应 P1-2。

**标准外壳绑定**：

```
POST /bridge/shell/register
  Request: {
    "genesis_id": "gu_...",
    "shell_type": "llc",
    "jurisdiction": "us_wy",
    "llc_registration_id": "WY-2026-12345",
    "registered_agent": "agent@lawfirm.com",
    "signing_members": ["ns_...", "ns_..."]     // 对外签约代表
  }
  Response: {
    "shell_binding_id": "sb_...",
    "legal_name": "Genesis Unit gu_x9y8z7w6 LLC",
    "tax_id": "XX-XXXXXXX"
  }
```

### 13.2 无人工厂对接接口

```
POST /bridge/aps/order
  Request: {
    "genesis_id": "gu_...",
    "product_spec_hash": "sha256:...",
    "quantity": 1000,
    "shipping_manifest": { ... }
  }
  Response: {
    "aps_order_id": "aps_...",
    "estimated_completion": "2026-06-15T00:00:00Z",
    "cost_in_stablecoin": 5000.0
  }
```

### 13.3 支付系统接口

```
POST /bridge/payment/request
  Request: {
    "genesis_id": "gu_...",
    "customer_id": "ext_cust_...",
    "amount_fiat": 99.99,
    "currency": "USD",
    "invoice_items": [...]
  }
  Response: {
    "payment_link": "https://pay.conc-protocol.org/inv/...",
    "settlement_stablecoin_estimate": 99.50
  }
```

---

## 十四、理论层→协议层→工程化层 三级映射表（v2.0 更新）

| 理论层（公理/本原） | 协议层（归属层） | 工程化层（实现方式） |
|:---|:---|:---|
| **本原一**：人有创造潜能 | 身份层：方向档案（Direction Profile） | `conc://profile/{ns_id}` Resource |
| **本原二**：条件满足→潜能释放 | 身份层：能证三层晋级（CP Promotion） | `conc_anchor` Tool + CP Promotion Pipeline |
| **本原三**：网络替代层级 | 策元层：ICP 意图聚结 + 策元 CRUD | `conc_seed_*` + `conc_genesis_*` Tools |
| **本原零**：自利与秩序恒常 | 协作层：GHF 审计 + Gate 门控 | `conc://genesis/{id}/ghf` Resource + Gate System |
| **公理零**：制度协同演进 | 策元层：策元外壳绑定 | `POST /bridge/shell/register` |
| **公理一**：生产解耦 | 应用层：无人工厂对接 | `POST /bridge/aps/order` |
| **公理二a**：主权节点 | 身份层：智权体注册 + 自由进出 | `conc_register` + `conc_genesis_join/leave` |
| **公理二b**：主动型工作假设 | Phronesis Layer：决断点注册（人主动介入） | `conc_judgment_request/respond` |
| **公理三**：涌现收敛 | 策元层：ICP 三阶段 + 内源优先 | ICP Protocol + Task Warrant 三阶段 |
| **公理四**：模块承诺 | 验证层：AUTO/PEER(n)/MARKET 验证 | `conc_verify_submit` + `conc_task_review` |
| **算力约束** | 网络层：边缘优先假设 | MCP Server 本地推理优先 |
| **SBDEL 定理 S1-S4** | 协作层：Skill 引用链 + 授权衰减 | Skill Lineage Protocol + Authorization Decay |
| **CP Promotion 定理 CP1-CP4** | 身份层：能证晋级管道 | `cp_promotion_check` + `cp_decay_check` |
| **涌现经验规律 η(N)** | 策元层：策元规模约束（3-8人） | PCP `minimum_members` / `maximum_members` |
| **NR 信号博弈（模型三）** | 价值层：NR 统一状态机 | NR State Machine + PEER 评审权重 |
| **Sophia/Phronesis 双层** | Phronesis Layer：决断点 + 加力类型 | `conc_judgment_*` + `conc_jc_record` |
| **One-Agent 不可还原** | 身份层：方向档案 + Judgment Credit | Direction Profile + JC Protocol |
| **壁垒辩证法** | 协作层：Skill 授权衰减曲线 | Authorization Decay Protocol |
| **治理必要性（§0.2 补充二）** | Phronesis Layer：安全判断一票否决 | JP-005: 安全官否决权 |
| **七阶段螺旋（历史推演）** | 策元层：策元生命周期（有限生命周期） | `conc_genesis_dissolve` |
| **女巫防御（v2.2新增）** | 身份层：L-1子证明组合 + 异常检测 | Sybil Checks Pipeline + 举报机制 |
| **创世任务令（v2.1新增）** | 策元层：CP_BOOTSTRAP/NR_SEED 任务令类型 | `conc_task_template_*` Tools + 自动触发逻辑 |
| **即时价值交付（v2.2新增）** | 身份层：60秒能证名片 | IVD Protocol + 首次注册引导流 |

---

## 十五、协议版本化策略

遵循语义化版本规范，但增加协议层维度：

```
CONC-Protocol/{layer}.{major}.{minor}

例:
  CONC-Protocol/identity.2.0    → 身份层 v2.0
  CONC-Protocol/genesis.2.0     → 策元层 v2.0
  CONC-Protocol/collab.1.0      → 协作层 v1.0（新增层）
  CONC-Protocol/value.2.0       → 价值层 v2.0
  CONC-Protocol/phronesis.1.0   → Phronesis层 v1.0（新增层）
  CONC-Protocol/stack.2.0       → 协议栈整体 v2.0
```

各层的版本独立演进。跨层兼容性由**接口合约（Interface Contract）**保证——上层依赖的接口方法名和参数 schema 一旦发布，不可破坏性修改。

### v1.0 → v2.0 版本号变更汇总

| 层 | v1.0 版本 | v2.0 版本 | 变更理由 |
|----|:--------:|:--------:|---------|
| 应用层 | 1.0 | 2.0 | 新增决断控制台、Track B MCP Resources |
| **Phronesis层** | — | **1.0** | **全新协议层** |
| 价值层 | 1.0 | 2.0 | NR 重构为四维状态机、新增 CCR 公开账本、JC 记录 |
| 验证层 | 1.0 | 2.0 | PEER(n) 四维度评分、争议升级路径、防串谋协议 |
| **协作层** | — | **1.0** | **全新协议层** |
| 策元层 | 1.0 | 2.0 | 弹性分叉、阶梯式燃烧、创世任务令 |
| 身份层 | 1.0 | 2.0 | L-1外部信任锚点、五维可组合子证明、方向档案、JC |
| 网络层 | 1.0 | 2.0 | 事件队列、18种广播消息类型、HUMAN_INTERVENTION |

---

## 十六、INFERNO-003 预判防御清单 (v1.1 → v2.0 加固)

> *以下来自 INFERNO-003 对协议层的预判攻击向量。v1.1 已完成对 △ 项加固，v2.0 新增协作层和 Phronesis 层防御。*

| # | 攻击向量 | 防御状态 | v1.1/v2.0 加固 |
|---|---------|:--------:|-----------|
| PV1 | CreateGenesis 洪泛 DDoS | ✓ | \|N₀\|>100 拒绝；同一创意图元 24h 仅可触发一次 |
| PV2 | Join/Leave 震荡攻击 | ✓ | 24h 内 Join 上限=3；1h 内同策元 Leave+Join=拒绝 |
| PV3 | 策元解散炸弹 | ✓ | 策元创建后 72h 不可解散；需全策元投票确认 |
| PS1 | 协作边完备性窗口 | ✓ | Join 操作二阶段提交 (Propose→Commit) |
| PS2 | 幽灵策元 | ✓ | 约束: \|N(g)\|<2 → 自动解散 |
| PT1 | 重校准窗口收割 | ✓ | 重校准时冻结 NR 状态快照；友好退出基于快照判定 |
| PT2 | 轮值空窗期 | ✓ | 轮值前 24h 交接期；离任策元核提交状态摘要 |
| PI1 | 拓扑 Sybil 集群检测 | ✓ | 图分析层: FRAUDAR 算法检测稠密子图；异常 CCR 集群自动审计；v2.0 增加五维可组合子证明防伪 |
| PR1 | 拓扑黑洞 | ✓ | Gossip 协议冗余路径 (fanout=3)；消息 TTL+ACK |
| PE1 | VT 解散套利 | ✓ | VT vesting: 策元解散后 90 天锁定期；按模块验证时间线性释放 |
| PE2 | 桥接租金抽取 | ✓ | 桥接策元标记后限价 (ALP 借贷利率上限)；策元核信息过滤 = 违反透明原则 → NR 扣减 |
| **PV4** | **工作区文件冲突炸弹** | **✓ v2.0** | 协作层文件锁定 + coordinator_arbitration 策略 |
| **PV5** | **决断点洪泛（虚假 HUMAN_INTERVENTION）** | **✓ v2.0** | 决断点 registry 白名单；非注册决断点消息丢弃 |
| **PV6** | **Gate 门控绕过** | **✓ v2.0** | Gate 0-4 强制顺序；不可跳过；GHF 审计追溯 |
| **PV7** | **协作 Skill 投毒** | **✓ v2.0** | 协作 Skill 发布需 PEER(3) 评审 + Gate 检查 |

图例: ✓=已防御, △=部分防御 → ✓=已完成加固

---

## 十七、下一步

1. **仿真集成**：将 ABM 仿真与 v2.0 八层协议栈 API 对接——仿真中的图操作通过协议 API 执行
2. **智能合约原型**：为价值层（VT/NR/CCR/ALP）编写 Solidity 原型合约
3. **Track B MVP**：实现 MCP Server 核心 Tool 集合（身份注册、策元创建、任务令管理、PEER 评审）
4. **安全审计**：基于 v2.0 新增的协作层和 Phronesis 层攻击面，进行系统性红队测试
5. **Phronesis 仿真**：设计人机混合仿真实验，验证介入协议对协作效率的影响

---

*Hermes Agent — 架构师与逻辑编译器*
*协议层设计 v2.0 — 从六层升级到八层：新增 Collaboration Layer（第四层，策元工作区+文档生命周期+Gate门控+GHF审计+事件总线+协作Skill+编排API）和 Phronesis Layer（第七层，10个决断点+4种加力+5步介入协议+决断追踪）。引入 Track A/B 双轨架构（MCP Server+Skill 零门槛接入）。新增 MCP 兼容性和载体无关性两条设计原则。新增决断流程和协作流程两条层间数据流。更新三级映射表至 v2.2 规范（新增女巫防御/创世任务令/即时价值交付等映射）。网络层广播消息类型从 5 种扩展至 18 种。*
