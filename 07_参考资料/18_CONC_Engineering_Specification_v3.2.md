# CONC 工程化规范合订本 v3.2
## Engineering Specification Compendium — Protocol Stack → Workflow → Deployment

**文档标识**: CONC-ENG-SPEC-003
**版本**: v3.2
**基于**: CONC_Engineering_Specification_v2.2.md + Sophia↔Phronesis 边界工程化修订 (P0/P1/P2) + CONC 框架 v2.7 同步（INFERNO-015 修复 + Round13 物理前置层 + 被动群体 Skill 增值管道）
**生成时间**: 2026-05-27（v2.2），**升级** 2026-07-12（v3.1），**v2.7 同步** 2026-08-08（v3.2）

**工程总纲**: 本文档是 v2.2 工程化规范的升级版本。v3.1 扩展了决断层（Phronesis Layer）——从固定 JP 模型升级为 JP-001~010（生命周期级）+ P1-P5（任务执行级）动态触发域，新增 GovernedAction 原语与 Action Gate 运行时判定，JC体系从单维度重构为四分量合成。协作层 GHF 事件表同步扩展 6 种新事件类型。任务令数据模型新增 phronesis_profile 三字段。**v3.2 同步 CONC 框架 v2.6/v2.7 的理论更新**——物理基础设施层协议定位修正（P0-P5 从"推导基底"降为"必要条件背景"）、被动群体 Skill 增值工程管道、U28/U29 新增待验证变量挂接。

---

## 版本变更记录

| 版本 | 日期 | 变更内容 |
|------|------|---------|
| v1.0 | 2026-05-24 | 初始版本：协议层架构、Skill/知识协议、基础设施框架、工程化工作流与实现 |
| v2.2 | 2026-05-27 | 架构升级（六层→八层）、Track A/B双轨选型、安全修复工程实现、冷启动工程实现、工具精简29→15 P0、数据持久性设计、里程碑更新(6-8周) |
| **v3.1** | **2026-07-12** | **Sophia↔Phronesis 边界工程化: GovernedAction/Action Gate 运行时判定, JC四分量重构, P1-P5触发域, phronesis_profile三模式, GHF+6事件, Schema迁移 v3.1** |
| **v3.2** | **2026-08-08** | **CONC 框架 v2.6/v2.7 理论同步: 物理基础设施层定位修正(P0-P5必要条件背景), 被动群体Skill增值工程管道(U29), 厂商锁定力vs开放协议破解力竞争条件(U28), 四维对齐工程映射(T15), 理论→工程映射表更新** |

**从 v1.0 到 v2.2 的关键变更摘要**:
1. 六层协议栈升级为八层：新增第四层 Collaboration Layer（协作层）和第七层 Phronesis Layer（决断层）
2. Track A/B 双轨架构正式确立：Track B MCP Server 方案为当前主线
3. 安全修复：AUTO频率限制、女巫防御、状态机幂等性、防串谋协议
4. 冷启动：创世任务令、IVD能证名片、平台适配器，解决冷启动困境
5. 工具精简：从 29 个工具精简至 15 个 P0 核心工具，其余标记 P1/experimental
6. 数据持久性：NR/CCR哈希链 + GitHub Issues→IPFS→Arweave 渐进式锚定
7. 里程碑计划：从 16 周压缩为 6-8 周（Phase 0-5）

---

## 三级映射链条（继承 v1.0）

```
理论层 (01_Core/ 02_Models/)  ──→  协议层 (03_Protocols/)  ──→  工程化层 (本文档/10_Engineering/)
     │                                  │
     │ 定义"为什么"和"什么"              │ 定义"如何实现"的协议规范
     │                                  │
     └── 理论修订 → 协议同步更新 ──────→ 工程同步更新
```

**v2.2 新增的理论→工程映射**:
| 理论层 | 协议层 | 工程化层 (v2.2/v3.1) |
|--------|--------|---------------------|
| 公理一（策元自治） | PCP 协议 | 协作层（CollabLayer）工作区管理 + 文档生命周期 |
| 公理二（意图聚结） | ICP 协议 | 创世任务令（CP_BOOTSTRAP）+ 冷启动平台适配器 |
| 公理三（协议验证） | PEER(n) + AUTO | 安全引擎（AUTO限频 + 女巫防御 + 幂等性） |
| 公理四（One-Agent不可还原） | CSIP | IVD能证名片 + 方向档案 |
| 公理五（引用链完备） | SBDEL v2.0 | NR/CCR哈希链 + 渐进式锚定 |
| 决断理论 | Phronesis Protocol v1.0 | 决断层（Phronesis Layer）judgment_request同步版（v2.2） |
| **Sophia↔Phronesis 边界 (v3.1)** | **Phronesis Protocol v2.0 + JC v2.0** | **GovernedAction/Action Gate 运行时判定 + JC 四分量 + P1-P5 触发域 + phronesis_profile** |
| **v2.6/v2.7 新增理论→工程映射**:
| 理论层 | 协议层 | 工程化层 (v3.2) |
|--------|--------|----------------|
| **P0-P5 物理前置层（必要条件背景）** | **22_Physical_Infrastructure_Protocol.md** | **物理基础设施工厂复用协议（§5.7 新增）——定位从"推导基底"降为"不可争论的必要条件背景"** |
| **§0.6.4 被动群体 Skill 增值管道** | **20_Genesis_Task_Warrant_Protocol.md** | **冷启动引擎被动群体优先管道（§7.5 新增）——公共 CU 倾斜 + 种子策元降门槛 + 基础 Skill 培训协议** |
| **U28 厂商锁定力 vs 开放协议破解力** | **21_Sybil_Defense_Protocol.md + 04_CTCP_CSIP.md** | **CSIP 标准化方案 + 厂商锁定检测（§6.5 新增）——数据可导出 + Skill 可迁移 + 协议互操作** |
| **U29 被动群体切换点比例** | **20_Genesis_Task_Warrant_Protocol.md** | **被动群体迁移追踪仪表盘（§7.6 新增）——F_active/F_passive 追踪 + 占比统计** |
| **T15 四维对齐（+时间维度）** | **18_Collaboration_Layer_Protocol.md** | **异步协作工具成熟度评估 + 时区重叠检测（§5.1.4 新增）** |

v1.0 中未变更的全部内容（第一篇：协议层架构、第二篇：Skill与知识协议、第三篇：基础设施框架、第四篇：工程化工作流与实现）依然有效，作为本 v2.2 版本的基础参考文档。以下各章节仅描述 v2.2 新增或变更的内容。

---

# 第五篇：v2.2 新增 — 八层架构与双轨选型

## Chapter 5: Eight-Layer Architecture & Track A/B Decision

---

## 5.1 架构升级总览：六层 → 八层

### 5.1.1 升级动因

v1.0 的六层协议栈（身份层/策元层/验证层/价值层/网络层/桥接层）覆盖了 CONC 协议的核心能力。但在工程化实践中暴露出两个关键缺失：

1. **协作层缺失**：策元内部的多智权体协作（文档共创、Gate门控审核、GHF审计追踪）没有独立的工程层。v1.0 将这些能力散落在策元层和应用层中，导致实现耦合严重。
2. **决断层缺失**：CONC 理论体系中定义了「决断点」（Judgment Point）概念——需要人类智慧干预的决策边界。v1.0 没有为这些决断点提供协议和工程实现。

### 5.1.2 八层架构定义

```
┌─────────────────────────────────────────────────────────────────┐
│ Layer 8: 应用层 (Application Layer)                              │
│ 智契 UI · 策元仪表盘 · 任务令浏览器 · 争议仲裁界面               │
├─────────────────────────────────────────────────────────────────┤
│ Layer 7: 决断层 (Phronesis Layer)              ← v2.2 新增      │
│ 决断点注册 · judgment_request · 介入协议 · 人类/AI 决策边界      │
├─────────────────────────────────────────────────────────────────┤
│ Layer 6: 价值层 (Value Layer)                                    │
│ VT 铸造/分发 · 能证 NR 计算 · 回报分配 · ALP 借贷                │
├─────────────────────────────────────────────────────────────────┤
│ Layer 5: 验证层 (Verification Layer)                             │
│ 模块验证(AUTO/PEER/MARKET) · 共识仲裁 · CC打分                   │
├─────────────────────────────────────────────────────────────────┤
│ Layer 4: 协作层 (Collaboration Layer)          ← v2.2 新增      │
│ 工作区管理 · 文档生命周期 · Gate门控 · GHF审计 · 事件总线        │
├─────────────────────────────────────────────────────────────────┤
│ Layer 3: 策元层 (Genesis Layer)                                  │
│ 策元 CRUD · 成员 Join/Leave · PCP 管理 · 策元核轮值              │
├─────────────────────────────────────────────────────────────────┤
│ Layer 2: 身份层 (Identity Layer)                                 │
│ 智权体注册 · 能证发行 · 身份锚定 · 公私钥管理                    │
├─────────────────────────────────────────────────────────────────┤
│ Layer 1: 网络层 (Network Layer)                                  │
│ 节点发现 · 消息广播 · 状态同步 · 断网缓存                        │
└─────────────────────────────────────────────────────────────────┘
```

### 5.1.3 层间数据流（v2.2 更新版）

```
智权体 n 领取任务令并提交（v2.2 协作流）:
  网络层 → 身份层(验证n的身份+能证)
    → 策元层(验证n∈g)
      → 协作层(文档生命周期 Gate门控)
        → 验证层(执行验证协议: AUTO/PEER)
          → 决断层(若触发决断点: PEER争议/策元核决策)
            → 价值层(分配VT)
              → 应用层(更新UI)
```

### 5.1.4 时间对齐维度（v3.2 — T15 四维对齐工程映射）

> *v2.7 修正：T15 从三维对齐扩展为四维对齐——新增时间对齐维度 A_时间(t)。策元在时间对齐维度不是"强"而是"中"——依赖时区重叠率和异步协作工具成熟度。工程化层需实现异步协作工具成熟度评估和时区重叠检测。*

**工程化影响**：时间对齐维度的加入对协作层工程实现有直接影响：

| 对齐维度 | 工程层 | 关键指标 | 工程实现 |
|---------|--------|---------|---------|
| A_意识(t) | 协作层 | 方向向量相似度 θ | ICP 语义匹配引擎 |
| A_资源(t) | 协作层+价值层 | CU 配额一致性 | 公共 CU 配额分配 |
| A_信息(t) | 协作层 | 信息同步延迟 | CRDT + 事件总线 |
| **A_时间(t)** | **协作层** | **时区重叠率 + 异步工具成熟度** | **异步协作检测引擎** |

**异步协作工具成熟度模型**：

```typescript
interface AsyncCollaborationMaturity {
  genesis_id: string;
  member_timezones: { ns_id: string; utc_offset: number }[];
  overlap_ratio: number;                    // 0-1 工作小时重叠率
  
  tool_maturity: {
    matrix_integration: boolean;            // Matrix 异步消息
    jitsi_availability: boolean;            // Jitsi 录像回放
    crdt_enabled: boolean;                  // CRDT 冲突解决
    doc_async_workflow: boolean;            // 文档异步审核
    ghf_offline_buffer: boolean;            // GHF 离线缓存
    decision_async_voting: boolean;         // 异步投票
  };
  maturity_score: number;                   // 0-1 综合成熟度
  
  // 策元解散风险：若 overlap_ratio < 0.3 且 maturity_score < 0.5
  dissolution_risk: 'low' | 'medium' | 'high';
}
```

**时区重叠检测实现**：

```typescript
async function calculateOverlapRatio(
  members: { ns_id: string; utc_offset: number }[]
): Promise<number> {
  // 1. 定义工作时段（默认 9:00-17:00 本地时间）
  const WORK_START = 9;   // 本地时间 9:00
  const WORK_END = 17;    // 本地时间 17:00
  
  // 2. 计算每对成员的重叠小时数
  let totalOverlapHours = 0;
  let totalPairs = 0;
  
  for (let i = 0; i < members.length; i++) {
    for (let j = i + 1; j < members.length; j++) {
      const iStart = (WORK_START - members[i].utc_offset + 24) % 24;
      const iEnd = (WORK_END - members[i].utc_offset + 24) % 24;
      const jStart = (WORK_START - members[j].utc_offset + 24) % 24;
      const jEnd = (WORK_END - members[j].utc_offset + 24) % 24;
      
      const overlap = Math.max(0, Math.min(iEnd, jEnd) - Math.max(iStart, jStart));
      totalOverlapHours += overlap;
      totalPairs++;
    }
  }
  
  return totalPairs > 0 ? totalOverlapHours / (totalPairs * 8) : 1;
}
```

**工程影响**：当 `overlap_ratio < 0.3` 且 `maturity_score < 0.5` 时，策元应获得"时间对齐高风险"标记，触发异步协作工具补强建议（Matrix 频道、异步投票、文档异步审核）。此工程化对应协议层 `18_Collaboration_Layer_Protocol.md` 的异步协作章节。

---

## 5.2 Layer 4: 协作层 (Collaboration Layer) — 工程实现指南

### 5.2.1 概述

协作层是 CONC 八层架构中承上启下的核心层。它将 v1.0 中分散在策元层、应用层和基础设施框架中的协作能力抽离为独立的协议层。

**职责边界**:
- **上游依赖**: 策元层（验证成员身份和策元上下文）
- **下游服务**: 验证层（提交工作产物供验证）
- **核心职责**: 策元内多智权体的文档共创、审核流程、历史追踪和工作区管理

### 5.2.2 协作引擎核心模块

#### 模块 5.2.2.1: 工作区管理 (Workspace Manager)

```
┌──────────────────────────────────────┐
│         Workspace Manager            │
│                                      │
│  workspace_create(params)            │
│  workspace_list(genesis_id)          │
│  workspace_archive(workspace_id)     │
│  workspace_sync(workspace_id)        │
│                                      │
│  每个策元自动创建默认工作区:          │
│  {genesis_id}_main                  │
│                                      │
│  工作区类型:                         │
│  - main: 主开发工作区 (默认)         │
│  - design: 设计工作区                │
│  - research: 研究工作区              │
│  - ops: 运维工作区                   │
└──────────────────────────────────────┘
```

**SQLite Schema 扩展（新增于 v2.2）**:

```sql
-- 工作区表 (v2.2 新增)
CREATE TABLE workspaces (
  workspace_id TEXT PRIMARY KEY,         -- ws_{genesis_id}_{type}
  genesis_id TEXT NOT NULL,
  workspace_type TEXT DEFAULT 'main',    -- main | design | research | ops
  title TEXT,
  description TEXT,
  status TEXT DEFAULT 'active',          -- active | archived
  git_branch TEXT,                       -- 关联的 Git 分支
  created_by_ns_id TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  FOREIGN KEY (genesis_id) REFERENCES genesis_units(genesis_id)
);

CREATE INDEX idx_workspaces_genesis ON workspaces(genesis_id);
```

#### 模块 5.2.2.2: 文档生命周期引擎 (Document Lifecycle Engine)

继承 v1.0 第三篇基础设施框架中的 DLM 设计，将其工程化为协作层的核心引擎。

**文档状态机**:

```
  draft ──→ submitted ──→ under_review ──→ approved ──→ published
    │            │              │                │            │
    │            └──────→ rejected              │         archived
    │                            │              │            │
    └────────────────────────────┘              │         expired
                                                │
                                           amended ──→ draft (变更重走流程)
```

**文档类型**:
| 类型 | 说明 | Gate 要求 |
|------|------|----------|
| `design_spec` | 设计规格文档 | Gate 1 + Gate 2 |
| `architecture_decision` | 架构决策记录 (ADR) | Gate 1 |
| `api_spec` | API 规格 | Gate 2 |
| `test_report` | 测试报告 | Gate 3 |
| `meeting_notes` | 会议记录 | None (自动通过) |
| `changelog` | 变更日志 | None (自动生成) |
| `release_notes` | 发布说明 | Gate 4 |

**文档创建 MCP Tool**:

```typescript
// conc_doc_create v2.2 (精简版)
server.tool('conc_doc_create', {
  workspace_id: z.string(),
  doc_type: z.enum(['design_spec','architecture_decision','api_spec',
                     'test_report','meeting_notes','changelog','release_notes']),
  title: z.string(),
  content: z.string(),
  tags: z.array(z.string()).default([]),
  relates_to_task: z.string().optional(),     // 关联任务令
  relates_to_doc: z.array(z.string()).default([]),  // 引用文档
}, async (params) => {
  // 1. 验证 workspace 存在且用户有权限
  // 2. 根据 doc_type 确定初始状态和 Gate 要求
  // 3. 创建文档记录 + Git commit
  // 4. 若需要 Gate 审核，自动触发 PEER 评审
  return { doc_id, status, git_commit_hash };
});
```

#### 模块 5.2.2.3: Gate 门控引擎 (Gate Controller)

对标 v1.0 中定义的设计控制 Gate 流程（Gate 0-4），工程化为协作层的门控引擎。

**Gate 状态模型**:

```typescript
interface GateCheckpoint {
  gate_id: string;                // gate_{genesis_id}_{gate_number}_{doc_id}
  gate_number: 0 | 1 | 2 | 3 | 4;
  doc_id: string;
  status: 'pending' | 'in_review' | 'passed' | 'failed' | 'waived';
  reviewer_ns_ids: string[];      // 分配的评审者
  review_deadline: number;        // Unix timestamp
  criteria: GateCriteria;
  results: GateResult[];
  passed_at?: number;
}

interface GateCriteria {
  check_type: 'auto' | 'peer' | 'genesis_core' | 'market';
  auto_checks?: string[];         // 自动化检查项
  peer_count?: number;            // PEER(n) 所需评审人数
  min_score?: number;             // 最低通过分数 (默认 3.0)
}
```

**Gate 门控流程**:

```
Gate 0 (ICP验证):    创意图元 → sim ≥ θ → 策元形成
                     检查: AUTO (方向向量相似度)

Gate 1 (设计输入):    需求规格 → PEER(3) 评审 → 通过
                     检查: PEER (完整性+可行性+与创意图元一致性)

Gate 2 (设计输出):    任务令DAG + API规格 → AUTO验证 → 通过
                     检查: AUTO (DAG无环检测 + API规格完整性)

Gate 3 (验证):        模块交付 → PEER(n)/AUTO/MARKET → 通过
                     检查: 混合 (自动化测试 + 同行评审 + 市场反馈)

Gate 4 (确认):        集成测试 → 策元核 + 外部消费者 → 通过
                     检查: PEER (策元核决策 + 用户验收)
```

#### 模块 5.2.2.4: GHF 审计引擎 (Genesis History File Auditor)

继承 v1.0 第三篇中的 GHF 设计，工程化为自动化审计引擎。

**GHF 自动记录事件（v3.1 扩展 6 种）**:

| 事件类型 | 触发条件 | 记录内容 |
|---------|---------|---------|
| `genesis.created` | 策元创建 | creative_seed, ICP结果, PCP初始版本 |
| `member.joined` | 成员加入 | ns_id, 加入时间, sim分数 |
| `member.left` | 成员离开 | ns_id, 离开时间, exit_type |
| `doc.created` | 文档创建 | doc_id, title, type, git_commit |
| `doc.state_changed` | 文档状态变更 | doc_id, from_state, to_state, gate_result |
| `gate.passed` | Gate 通过 | gate_id, reviewer_count, scores |
| `task.created` | 任务令创建 | task_id, title, estimated_hours, **phronesis_profile [v3.1]** |
| `task.completed` | 任务令完成 | task_id, actual_hours, verification_result |
| `pcp.amended` | PCP 修正 | proposal, vote_result |
| `fork.created` | 弹性分叉 | fork_id, fork_type, initiator |
| `genesis.dissolved` | 策元解散 | reason, final_vt_distribution |
| **`sophia_action`** | **Agent 自动动作 [v3.1]** | **action_id, action_type, clearance_level, matched_domain=S1-S4** |
| **`phro_judgment`** | **Phronesis 触发 [v3.1]** | **action_id, matched_domain=P1-P5, staged_result_hash, escalation_reason** |
| **`judgment_response`** | **人工判断完成 [v3.1]** | **trace_id, selected_option, judge_ns_id, jc_component** |
| **`task_warrant_designed`** | **任务令设计 [v3.1]** | **tw_id, designer_ns_id, phronesis_profile, decision_gates** |
| **`task_design_audit`** | **设计校准审计 [v3.1]** | **tw_id, misclassified_flag, misclassification_type** |
| **`peer_sync_scored`** | **PEER_SYNC 综合评分 [v3.1]** | **tw_id, direction_consistency, iteration_efficiency** |

**GHF 查询 MCP Tool**:

```typescript
// conc_ghf_timeline v2.2
server.tool('conc_ghf_timeline', {
  genesis_id: z.string(),
  event_type: z.string().optional(),    // 按类型筛选
  from_date: z.string().optional(),     // ISO 8601
  to_date: z.string().optional(),
  limit: z.number().default(50),
}, async (params) => {
  // 查询 GHF 事件，返回时间线
  return { events: [...], total_count };
});
```

#### 模块 5.2.2.5: 事件总线 (Event Bus)

协作层需要实时的事件通知机制，连接策元内各模块。

**事件总线设计**:

```typescript
// 事件类型枚举
type CollabEvent =
  | { type: 'doc.state_changed'; doc_id: string; from: DocState; to: DocState }
  | { type: 'gate.updated'; gate_id: string; status: GateStatus }
  | { type: 'task.claimed'; task_id: string; claimed_by: string }
  | { type: 'member.joined'; genesis_id: string; ns_id: string }
  | { type: 'member.left'; genesis_id: string; ns_id: string }
  | { type: 'review.requested'; doc_id: string; reviewer_ns_id: string }
  | { type: 'review.submitted'; doc_id: string; reviewer_ns_id: string }
  ;

// MCP Tool: conc_event_poll (P0)
server.tool('conc_event_poll', {
  genesis_id: z.string(),
  since_event_id: z.string().optional(),  // 增量拉取
  limit: z.number().default(20),
}, async (params) => {
  return { events: [...], latest_event_id };
});
```

---

## 5.3 Layer 7: 决断层 (Phronesis Layer) — 工程实现指南

### 5.3.1 概述

决断层处理 CONC 中「不能由算法完全决定」的决策点。这些决断点需要人类智慧的介入——由策元核、策元全体或特定评审者做出判断。

**核心原则**: 协议验证自动化能处理的，不走决断层。决断层仅处理灰色地带和创造性判断。

### 5.3.2 决断点注册表

```typescript
// 决断点定义
interface JudgmentPoint {
  jp_id: string;                    // jp_{genesis_id}_{seq}
  genesis_id: string;
  trigger_type: JudgmentTriggerType;
  context: JudgmentContext;
  status: 'pending' | 'in_session' | 'resolved' | 'deadlocked';
  created_at: number;
  resolved_at?: number;
}

type JudgmentTriggerType =
  | 'peer_deadlock'          // PEER评审僵局 (分差 > 2.0)
  | 'pcp_amendment'          // PCP修正提案
  | 'fork_decision'          // 弹性分叉决策
  | 'creative_dispute'       // 创意方向争议
  | 'member_expulsion'       // 成员驱逐
  | 'resource_allocation'    // 稀缺资源分配
  | 'ip_assignment'          // IP归属判定
  | 'quality_override'       // Gate通过/否决的质量覆写
  | 'ethical_boundary'       // 伦理边界判定
  ;

interface JudgmentContext {
  title: string;
  description: string;
  related_entities: {
    tasks?: string[];
    docs?: string[];
    members?: string[];
    gates?: string[];
  };
  options: JudgmentOption[];       // 可选决策方案
  deadline: number;                // 决断截止时间
}

interface JudgmentOption {
  option_id: string;
  label: string;
  description: string;
  implications: string;            // 各选项的影响说明
}
```

### 5.3.3 介入协议

**决断触发流程**:

```
触发条件满足
    │
    ▼
register_judgment_point() ──→ JudgmentPoint 创建
    │
    ▼
determine_intervention_level()
    │
    ├── Level 1: PEER(5) 评审 ──→ 5人评审组投票
    │
    ├── Level 2: 策元核决策 ──→ 策元核心成员投票
    │
    ├── Level 3: 策元全体投票 ──→ 全体成员投票 (需 ≥ 50% 参与率)
    │
    └── Level 4: 外部仲裁 ──→ 第三方仲裁者介入
         │
         ▼
    judgment_resolved() ←── 决断结果记录
```

**介入级别判定矩阵**:

| 触发类型 | 默认级别 | 升级条件 |
|---------|:------:|---------|
| peer_deadlock | Level 1 | 若 Level 1 仍死锁 → Level 2 |
| pcp_amendment | Level 3 | — |
| fork_decision | Level 2 | 若涉及 IP 归属 → Level 3 |
| creative_dispute | Level 1 | 若涉及策元方向 → Level 2 |
| member_expulsion | Level 2 | 若被驱逐者申诉 → Level 3 |
| resource_allocation | Level 2 | 若涉及 VT 分配 → Level 3 |
| ip_assignment | Level 3 | 若僵局 → Level 4 |
| quality_override | Level 1 | — |
| ethical_boundary | Level 2 | Level 4 始终可用 |

### 5.3.4 judgment_request 同步版 MCP Tool

v2.2 新增的核心 P0 Tool——这是决断层的对外接口：

```typescript
// conc_judgment_request v2.2 (同步版, P0)
server.tool('conc_judgment_request', {
  genesis_id: z.string(),
  trigger_type: z.enum([
    'peer_deadlock', 'pcp_amendment', 'fork_decision',
    'creative_dispute', 'member_expulsion', 'resource_allocation',
    'ip_assignment', 'quality_override', 'ethical_boundary'
  ]),
  title: z.string(),
  description: z.string(),
  options: z.array(z.object({
    option_id: z.string(),
    label: z.string(),
    description: z.string(),
  })),
  related_tasks: z.array(z.string()).default([]),
  related_docs: z.array(z.string()).default([]),
  deadline_hours: z.number().default(72),
}, async (params) => {
  // 1. 创建决断点记录
  // 2. 根据 trigger_type 确定介入级别
  // 3. 分配评审者/投票者
  // 4. 通知相关人员
  // 5. 返回决断点 ID 和预期表决时间线
  return {
    jp_id: 'jp_xxx',
    intervention_level: 2,
    reviewers: ['ns_xxx', 'ns_yyy'],
    voting_starts_at: Date.now() + 3600000,  // 1h 准备时间
    voting_ends_at: Date.now() + params.deadline_hours * 3600000,
    status: 'pending'
  };
});

// conc_judgment_vote v2.2 (P0)
server.tool('conc_judgment_vote', {
  jp_id: z.string(),
  option_id: z.string(),
  rationale: z.string().optional(),
}, async (params) => {
  // 1. 验证投票者在评审者列表中
  // 2. 记录投票
  // 3. 检查是否达到表决门槛
  // 4. 若达到，自动决断
  return { jp_id, status: 'voted', quorum_reached: false };
});

// conc_judgment_record v2.2 (P0)
server.tool('conc_judgment_record', {
  jp_id: z.string().optional(),
  genesis_id: z.string().optional(),
  status: z.enum(['pending','in_session','resolved','deadlocked']).optional(),
}, async (params) => {
  return { judgments: [...], total_count };
});
```

**决断层 SQLite Schema（v2.2 新增）**:

```sql
-- 决断点表 (v2.2 新增)
CREATE TABLE judgment_points (
  jp_id TEXT PRIMARY KEY,
  genesis_id TEXT NOT NULL,
  trigger_type TEXT NOT NULL,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  options_json TEXT NOT NULL,           -- JSON: JudgmentOption[]
  intervention_level INTEGER DEFAULT 1, -- 1=PEER(5), 2=策元核, 3=全体, 4=外部
  status TEXT DEFAULT 'pending',
  deadline INTEGER,
  resolved_option_id TEXT,
  created_by_ns_id TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  resolved_at INTEGER,
  FOREIGN KEY (genesis_id) REFERENCES genesis_units(genesis_id)
);

-- 决断投票表 (v2.2 新增)
CREATE TABLE judgment_votes (
  vote_id TEXT PRIMARY KEY,
  jp_id TEXT NOT NULL,
  voter_ns_id TEXT NOT NULL,
  option_id TEXT NOT NULL,
  rationale TEXT,
  voted_at INTEGER NOT NULL,
  FOREIGN KEY (jp_id) REFERENCES judgment_points(jp_id),
  UNIQUE(jp_id, voter_ns_id)           -- 每人一票
);

CREATE INDEX idx_jp_genesis ON judgment_points(genesis_id);
CREATE INDEX idx_jp_status ON judgment_points(status);
CREATE INDEX idx_jv_jp ON judgment_votes(jp_id);
```

---

## 5.4 Track A/B 双轨架构选型

### 5.4.1 双轨定义

v1.0 已定义了 Track A（自部署全栈）和 Track B（OpenClaw Skill）两种方案。v2.2 正式确认双轨架构的选型决策和各自适用场景。

**Track A — 自部署全栈**:
```
适用场景:
  - 完全自主的推理基础设施
  - 需要自建 P2P 网络
  - 追求完全去中心化
  - 技术实力强的开发者/组织

技术栈: Rust + libp2p + llama.cpp + SQLite + IPFS
推理方式: 自建三级推理架构 (Tier 0/1/2/3)
部署形态: 嵌入式推理中间件库 (SDK)
```

**Track B — MCP Server 方案（v2.2 主线）**:
```
适用场景:
  - 快速验证 CONC 理论
  - 低门槛用户接入
  - 利用已有 Agent 框架 (OpenClaw/Hermes)
  - 不需要自建推理引擎

技术栈: TypeScript + OpenClaw/Hermes + SQLite + Git + HTTP
推理方式: 复用已有框架的多 Provider 推理
部署形态: Skill Pack + MCP Server
```

### 5.4.2 v2.2 选型决策

| 决策维度 | Track A (自部署) | Track B (MCP Server) | v2.2 选型 |
|---------|:---:|:---:|:---:|
| **MVP 速度** | 慢（6周+） | 快（1-2周） | **Track B** |
| **用户接入门槛** | 高（需懂 Rust/P2P） | 低（安装 Skill 即可） | **Track B** |
| **去中心化程度** | 高（P2P 网络） | 中（HTTP Registry） | Track A 远期 |
| **推理自主性** | 高（自建推理引擎） | 低（依赖框架提供者） | Track A 远期 |
| **维护成本** | 高 | 低 | **Track B** |
| **可扩展性** | 高（全栈控制） | 中（受限于框架 API） | Track A 远期 |

**v2.2 决策结论**:
- **当前主线**: Track B (MCP Server 方案) — 快速验证、低门槛、可落地
- **远期规划**: Track A — 当 Track B 验证成功后，逐步迁移核心协议至 Track A
- **共存策略**: Track B 作为「入口层」，Track A 作为「骨干层」，通过 A2A 协议互通

### 5.4.3 Track B 架构细节（v2.2 升级版）

```
┌─────────────────────────────────────────────────────────────────┐
│ 用户层: Telegram / WhatsApp / Discord / CLI / Web Chat          │
├─────────────────────────────────────────────────────────────────┤
│ Agent 运行时 (OpenClaw / Hermes):                                │
│ session管理 · 消息路由 · 多Provider推理 · cron · memory         │
├─────────────────────────────────────────────────────────────────┤
│ CONC MCP Server (v2.2 升级版):                                   │
│ ┌───────────────┐ ┌───────────────┐ ┌───────────────┐           │
│ │ MCP 接口层    │ │ 协议引擎层     │ │ 协作引擎层    │           │
│ │               │ │               │ │ (v2.2新增)    │           │
│ │ Tool/Resource │ │ ICP/Task/PEER │ │ 工作区管理    │           │
│ │ /Prompt 三原语│ │ NR/JC/PCP     │ │ 文档生命周期  │           │
│ │               │ │               │ │ Gate门控      │           │
│ │ 15 P0 Tools   │ │ 6大协议引擎   │ │ GHF审计       │           │
│ │ + P1标记      │ │               │ │ 事件总线      │           │
│ └───────────────┘ └───────────────┘ └───────────────┘           │
│ ┌───────────────┐ ┌───────────────┐                             │
│ │ 决断引擎层    │ │ 安全引擎层     │                             │
│ │ (v2.2新增)    │ │ (v2.2新增)    │                             │
│ │               │ │               │                             │
│ │ 决断点注册    │ │ AUTO频率限制  │                             │
│ │ 介入协议      │ │ 女巫基础防御  │                             │
│ │ judgment_     │ │ 状态机幂等性  │                             │
│ │ request/vote  │ │ 防串谋协议    │                             │
│ └───────────────┘ └───────────────┘                             │
├─────────────────────────────────────────────────────────────────┤
│ 状态存储层 (v2.2 升级版):                                        │
│ SQLite (13表: 8核心表 + 5新表) · Git · IPFS · HTTP Registry     │
└─────────────────────────────────────────────────────────────────┘
```

---

## 5.5 物理基础设施复用协议（v3.2 — 基于 v2.6/v2.7 理论同步）

### 5.5.1 概述

对应协议层：`03_Protocols/22_Physical_Infrastructure_Protocol.md`（v2.6 round13 新增）
理论溯源：Round13 物理前置层 P0-P5 + 公理一（生产解耦）+ §0.5 能量守恒 + T5 物质/非物质自动化梯度

**v2.7 定位修正**：P0-P5 从"Archē 层的推导基底"降为"**必要条件背景**"——物理前置层不参与 Archē→公理的演绎推导，只约束推导的边界（任何违反热力学/生物学/生态学的公理都不成立）。工程化层据此将物理基础设施协议定位为"使能层"而非"推导层"。

### 5.5.2 工厂复用协议工程化

**核心原则**：策元生命周期 ≠ 工厂生命周期

| 维度 | 策元（创意聚合） | 工厂（物理基础设施） |
|------|----------------|-------------------|
| 生命周期 | 数月（创意驱动） | 数年（基础设施驱动） |
| 解散后 | Skill 沉淀入网络 | 模块重组进入共享池 |
| 所有权 | 策元成员共创 | 多元持有者（政府/私人/基金） |
| 复用性 | 一次性 | 多策元租用 |

**工厂生命周期状态机工程化**：

```typescript
interface FactoryLifecycle {
  factory_id: string;
  status: 'proposed' | 'evaluated' | 'built' | 'active' | 'reconfiguring' | 'retired';
  initiated_by_genesis_id: string;
  core_modules: FactoryModule[];
  bom_decomposition: BOMNode[];
  current_tenants: string[];
  value_cycle_estimate: number;
  owner_type: 'government' | 'consortium' | 'private';
  created_at: number;
  retired_at?: number;
}

interface FactoryModule {
  module_id: string;
  module_type: 'injection' | 'cnc' | '3d_print' | 'smt' | 'assembly' | 'test';
  spec_hash: string;
  physical_interface: string;
  data_interface: string;
  is_reusable: boolean;
  current_utilization: number;
}
```

**BOM 拆分与自动分发**：

```typescript
async function distributeBOM(
  genesisId: string, bom: BOMNode
): Promise<DistributionResult> {
  const leafNodes = extractLeafNodes(bom);
  const assignments = [];
  for (const node of leafNodes) {
    const module = matchFactoryModule(node);
    if (module) {
      assignments.push({
        part_id: node.part_id, spec: node.specification,
        assigned_module: module.module_id,
        estimated_time: node.estimated_cycle,
        factory_id: module.factory_id,
      });
    }
  }
  return { assignments, unmatched_parts: [] };
}
```

### 5.5.3 与 CONC 框架的工程化挂接

| 挂接点 | 工程实现 | 对应协议 |
|------|---------|---------|
| P0（存在即能量交换） | 工厂效率监控（单位产出能耗） | 不作为推导前提，仅作为约束边界 |
| P1（人必须生产） | 策元解散后工厂自动释放 | 工厂生命周期状态机 |
| T5（物质/非物质自动化梯度） | 物质生产工厂最先进入共享池 | 通用功能模块分类 |
| T15 四维对齐（资源维度） | 工厂共享是资源对齐维度的工程实现 | 工厂租用调度算法 |
| 本原零（治理本原） | 政府作为基础设施提供者的资源平衡职能 | 工厂评估委员会接口 |

### 5.5.4 工厂复用 SQLite Schema

```sql
CREATE TABLE factories (
  factory_id TEXT PRIMARY KEY,
  status TEXT NOT NULL DEFAULT 'proposed',
  initiated_by_genesis_id TEXT,
  owner_type TEXT NOT NULL,
  value_cycle_months INTEGER DEFAULT 0,
  created_at INTEGER NOT NULL,
  retired_at INTEGER,
  evaluation_json TEXT,
  FOREIGN KEY (initiated_by_genesis_id) REFERENCES genesis_units(genesis_id)
);

CREATE TABLE factory_modules (
  module_id TEXT PRIMARY KEY,
  factory_id TEXT NOT NULL,
  module_type TEXT NOT NULL,
  spec_hash TEXT NOT NULL,
  is_reusable INTEGER DEFAULT 1,
  current_utilization REAL DEFAULT 0,
  FOREIGN KEY (factory_id) REFERENCES factories(factory_id)
);

CREATE TABLE factory_tenancy (
  tenancy_id TEXT PRIMARY KEY,
  factory_id TEXT NOT NULL,
  genesis_id TEXT NOT NULL,
  start_time INTEGER NOT NULL,
  end_time INTEGER,
  bom_hash TEXT,
  cu_consumed REAL DEFAULT 0,
  status TEXT DEFAULT 'active',
  FOREIGN KEY (factory_id) REFERENCES factories(factory_id),
  FOREIGN KEY (genesis_id) REFERENCES genesis_units(genesis_id)
);

CREATE INDEX idx_fm_factory ON factory_modules(factory_id);
CREATE INDEX idx_ft_factory ON factory_tenancy(factory_id);
CREATE INDEX idx_ft_genesis ON factory_tenancy(genesis_id);
```

---

# 第六篇：v2.2 新增 — 安全修复工程实现

## Chapter 6: Security Fixes Engineering

---

## 6.1 AUTO 频率限制 (Auto Frequency Limiting)

### 6.1.1 问题描述

v1.0 的 AUTO 验证模块无频率限制，攻击者可以通过重复提交触发无限次数的 AUTO 验证，造成：
- 算力资源浪费
- 验证结果污染
- 策元内信噪比下降

### 6.1.2 实现方案

**auto_frequency_log 表（v2.2 新增）**:

```sql
-- AUTO 频率日志表 (v2.2 新增)
CREATE TABLE auto_frequency_log (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  ns_id TEXT NOT NULL,
  genesis_id TEXT NOT NULL,
  action_type TEXT NOT NULL,             -- auto_verify | auto_match | auto_check
  content_hash TEXT NOT NULL,            -- SHA-256 of content (去重)
  timestamp INTEGER NOT NULL,
  result TEXT,                           -- pass | fail | rate_limited
  FOREIGN KEY (ns_id) REFERENCES noetic_sovereigns(ns_id)
);

CREATE INDEX idx_afl_ns_ts ON auto_frequency_log(ns_id, timestamp);
CREATE INDEX idx_afl_content ON auto_frequency_log(content_hash);
```

**递减收益矩阵**:

```typescript
// AUTO 频率限制规则
const AUTO_LIMITS = {
  auto_verify: {
    window_seconds: 3600,    // 1小时窗口
    base_quota: 10,           // 基础配额
    decay_factor: 0.7,        // 每次超额后配额衰减系数
    min_quota: 2,             // 最低配额
    cooldown_seconds: 1800,   // 冷却时间 (30分钟)
  },
  auto_match: {
    window_seconds: 600,      // 10分钟窗口
    base_quota: 20,
    decay_factor: 0.8,
    min_quota: 5,
  },
  auto_check: {
    window_seconds: 300,      // 5分钟窗口
    base_quota: 30,
    decay_factor: 0.9,
    min_quota: 10,
  },
};

// 频率检查函数
async function checkAutoFrequency(
  nsId: string,
  genesisId: string,
  actionType: string,
  contentHash: string
): Promise<{ allowed: boolean; reason?: string; remaining_quota: number }> {
  const limits = AUTO_LIMITS[actionType];
  const windowStart = Date.now() - limits.window_seconds * 1000;

  // 1. 内容去重检查
  const duplicate = db.get(
    'SELECT id FROM auto_frequency_log WHERE content_hash = ? AND timestamp > ?',
    [contentHash, windowStart]
  );
  if (duplicate) {
    return { allowed: false, reason: 'duplicate_content', remaining_quota: 0 };
  }

  // 2. 频率计算
  const recentCount = db.get(
    'SELECT COUNT(*) as cnt FROM auto_frequency_log WHERE ns_id = ? AND action_type = ? AND timestamp > ?',
    [nsId, actionType, windowStart]
  );

  const currentQuota = calculateDecayQuota(nsId, actionType, limits);
  if (recentCount.cnt >= currentQuota) {
    return {
      allowed: false,
      reason: 'rate_limited',
      remaining_quota: 0
    };
  }

  return { allowed: true, remaining_quota: currentQuota - recentCount.cnt - 1 };
}

// 递减配额计算
function calculateDecayQuota(nsId: string, actionType: string, limits: any): number {
  // 检查24小时内的超额次数，每次超额衰减
  const dayStart = Date.now() - 86400000;
  const overuseCount = db.get(
    `SELECT COUNT(*) as cnt FROM auto_frequency_log
     WHERE ns_id = ? AND action_type = ? AND result = 'rate_limited'
     AND timestamp > ?`,
    [nsId, actionType, dayStart]
  );

  const quota = limits.base_quota * Math.pow(limits.decay_factor, overuseCount.cnt);
  return Math.max(quota, limits.min_quota);
}
```

---

## 6.2 女巫基础防御 (Sybil Basic Defense)

### 6.2.1 问题描述

v1.0 的身份锚定依赖 GitHub 单点证明，攻击者可以通过创建大量 GitHub 账号绕过身份锚定，发起女巫攻击。

### 6.2.2 防御实现

**sybil_checks 表（v2.2 新增）**:

```sql
-- 女巫检测表 (v2.2 新增)
CREATE TABLE sybil_checks (
  check_id TEXT PRIMARY KEY,
  ns_id TEXT NOT NULL,
  check_type TEXT NOT NULL,              -- github_api | activity_pattern | cross_anchor
  check_result TEXT NOT NULL,            -- pass | flag | fail
  risk_score REAL DEFAULT 0,             -- 0.0-1.0 女巫风险评分
  evidence_json TEXT,                    -- 检测证据
  checked_at INTEGER NOT NULL,
  expires_at INTEGER,                    -- 检测结果有效期
  FOREIGN KEY (ns_id) REFERENCES noetic_sovereigns(ns_id)
);

CREATE INDEX idx_sc_ns ON sybil_checks(ns_id);
CREATE INDEX idx_sc_result ON sybil_checks(check_result);
```

**三层检测机制**:

```typescript
// Layer 1: GitHub API 检测
async function githubSybilCheck(nsId: string, githubProof: string): Promise<SybilResult> {
  // 1. 调用 GitHub API 获取账户信息
  const githubData = await fetchGitHubProfile(githubProof);

  const riskFactors: string[] = [];
  let riskScore = 0;

  // 2. 检查账户年龄
  const accountAge = (Date.now() - new Date(githubData.created_at).getTime()) / 86400000;
  if (accountAge < 30) {
    riskScore += 0.3;
    riskFactors.push('account_too_young');
  }
  if (accountAge < 90) {
    riskScore += 0.15;
  }

  // 3. 检查仓库数量和活跃度
  if (githubData.public_repos === 0) {
    riskScore += 0.2;
    riskFactors.push('no_public_repos');
  }

  // 4. 检查贡献历史
  const contributionCount = await fetchContributionCount(githubProof);
  if (contributionCount < 5) {
    riskScore += 0.2;
    riskFactors.push('low_contribution');
  }

  // 5. 检查 follower 数量
  if (githubData.followers < 2) {
    riskScore += 0.1;
    riskFactors.push('low_social_graph');
  }

  return { riskScore, riskFactors };
}

// Layer 2: 活动模式检测
async function activityPatternCheck(nsId: string): Promise<SybilResult> {
  const riskFactors: string[] = [];
  let riskScore = 0;

  // 检查注册后的首次活动时间
  const firstActivity = db.get(
    'SELECT MIN(created_at) as t FROM ccr_records WHERE ns_id = ?', [nsId]
  );

  const registrationTime = db.get(
    'SELECT created_at FROM noetic_sovereigns WHERE ns_id = ?', [nsId]
  );

  if (firstActivity && registrationTime) {
    const gap = firstActivity.t - registrationTime.created_at;
    // 注册后立即大量活动 = 可疑
    if (gap < 300) {  // 5分钟内
      riskScore += 0.2;
      riskFactors.push('immediate_activity');
    }
  }

  // 检查任务领取/放弃模式
  const claimAbandonRatio = db.get(`
    SELECT
      COUNT(CASE WHEN status IN ('merged_resolved','validating') THEN 1 END) * 1.0 /
      NULLIF(COUNT(*), 0) as ratio
    FROM task_warrants WHERE claimed_by = ?
  `, [nsId]);

  if (claimAbandonRatio && claimAbandonRatio.ratio < 0.3) {
    riskScore += 0.2;
    riskFactors.push('high_abandon_rate');
  }

  return { riskScore, riskFactors };
}

// Layer 3: 跨锚点验证
async function crossAnchorCheck(nsId: string): Promise<SybilResult> {
  // 如果能提供多种身份锚定 (GitHub + GitLab + SO + L1任务令)
  // 则风险显著降低
  const anchorCount = db.get(
    'SELECT COUNT(DISTINCT type) as cnt FROM identity_anchors WHERE ns_id = ?',
    [nsId]
  );

  let riskScore = 0;
  const riskFactors: string[] = [];

  if (anchorCount.cnt === 1) {
    riskScore = 0.3;
    riskFactors.push('single_anchor');
  } else if (anchorCount.cnt >= 3) {
    riskScore = -0.2;  // 降低风险
    riskFactors.push('multi_anchor_verified');
  }

  return { riskScore, riskFactors };
}
```

**女巫防御降级路径**:

```
sybil_risk_score ≥ 0.7:
  → 标记为 HIGH_RISK
  → CU 配额减半
  → 禁止参与策元核轮值
  → 任务令需额外 PEER(5) 验证

sybil_risk_score ≥ 0.4:
  → 标记为 MEDIUM_RISK
  → CU 配额降 20%
  → 任务令需 PEER(3) 验证 (默认)

sybil_risk_score < 0.4:
  → 标记为 LOW_RISK
  → 正常配额和验证流程
```

---

## 6.3 状态机幂等性

### 6.3.1 问题描述

v1.0 的 CTCP 状态跃迁和 MCP Tool 调用在网络重试、并发场景下可能触发重复状态变更，导致数据不一致。

### 6.3.2 幂等性实现

**原则**: 所有状态变更操作使用 UNIQUE 约束 + SQLite 事务 + 状态转换检查。

```typescript
// 任务令状态跃迁幂等性实现 (v2.2)
async function transitionTaskStatus(
  taskId: string,
  triggerEvent: string,
  context: { nsId?: string; deliverableHash?: string }
): Promise<TaskState> {
  return db.transaction(() => {
    // 1. 获取当前状态 (SELECT FOR UPDATE 语义通过事务锁实现)
    const task = db.get(
      'SELECT status FROM task_warrants WHERE task_id = ?',
      [taskId]
    );
    if (!task) throw new Error('task_not_found');

    // 2. 查找对应的状态跃迁规则
    const transition = getValidTransition(task.status, triggerEvent);
    if (!transition) {
      // 幂等性：如果已经是目标状态，直接返回成功
      // 不做任何修改
      return task.status;
    }

    // 3. 执行状态变更
    const result = db.run(
      `UPDATE task_warrants
       SET status = ?, updated_at = ?
       WHERE task_id = ? AND status = ?`,     // ← 条件更新确保幂等
      [transition.to, Date.now(), taskId, task.status]
    );

    if (result.changes === 0) {
      // 状态已经变更过，幂等返回
      return transition.to;
    }

    // 4. 记录状态变更日志
    db.run(
      `INSERT INTO state_transition_log (task_id, from_status, to_status, trigger_event, context_json, timestamp)
       VALUES (?, ?, ?, ?, ?, ?)`,
      [taskId, task.status, transition.to, triggerEvent, JSON.stringify(context), Date.now()]
    );

    // 5. 级联触发
    if (transition.to === TaskState.MERGED_RESOLVED) {
      cascadeUnlock(taskId);
    }

    return transition.to;
  });
}
```

**状态跃迁日志表（v2.2 新增）**:

```sql
-- 状态跃迁日志表 (v2.2 新增，幂等性基础设施)
CREATE TABLE state_transition_log (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  task_id TEXT NOT NULL,
  from_status TEXT NOT NULL,
  to_status TEXT NOT NULL,
  trigger_event TEXT NOT NULL,
  context_json TEXT,
  timestamp INTEGER NOT NULL,
  FOREIGN KEY (task_id) REFERENCES task_warrants(task_id)
);

CREATE UNIQUE INDEX idx_stl_unique ON state_transition_log(task_id, from_status, to_status, trigger_event);
CREATE INDEX idx_stl_task ON state_transition_log(task_id);
```

**MCP Tool 幂等性包装器**:

```typescript
// 通用幂等性包装器
async function idempotentTool<T>(
  idempotencyKey: string,    // 由调用方生成，如 sha256(params)
  operation: () => Promise<T>,
  ttlSeconds: number = 300
): Promise<T> {
  // 1. 检查是否已有相同幂等键的操作
  const existing = db.get(
    `SELECT result_json, status FROM idempotency_cache
     WHERE idempotency_key = ? AND created_at > ?`,
    [idempotencyKey, Date.now() - ttlSeconds * 1000]
  );

  if (existing) {
    if (existing.status === 'completed') {
      return JSON.parse(existing.result_json);
    }
    if (existing.status === 'in_progress') {
      throw new Error('operation_in_progress');
    }
  }

  // 2. 记录进行中
  db.run(
    `INSERT OR IGNORE INTO idempotency_cache (idempotency_key, status, created_at)
     VALUES (?, 'in_progress', ?)`,
    [idempotencyKey, Date.now()]
  );

  // 3. 执行操作
  try {
    const result = await operation();

    // 4. 缓存结果
    db.run(
      `UPDATE idempotency_cache SET status = 'completed', result_json = ?, completed_at = ?
       WHERE idempotency_key = ?`,
      [JSON.stringify(result), Date.now(), idempotencyKey]
    );

    return result;
  } catch (error) {
    db.run(
      `UPDATE idempotency_cache SET status = 'failed', error_msg = ?
       WHERE idempotency_key = ?`,
      [String(error), idempotencyKey]
    );
    throw error;
  }
}

// 幂等性缓存表
CREATE TABLE idempotency_cache (
  idempotency_key TEXT PRIMARY KEY,
  status TEXT NOT NULL DEFAULT 'in_progress',
  result_json TEXT,
  error_msg TEXT,
  created_at INTEGER NOT NULL,
  completed_at INTEGER
);
```

---

## 6.4 防串谋协议（Phase 4 延迟）

### 6.4.1 问题描述

v1.0 的 PEER 评审在分配评审者后立即公开身份，导致串谋攻击——多个评审者可以在看到彼此分配后私下协调评分。

### 6.4.2 实现方案（Phase 4 延迟）

**peer_reviews 表升级（v2.2）**:

```sql
-- PEER 评审表升级 (v2.2 修改)
ALTER TABLE peer_reviews ADD COLUMN anonymized_until INTEGER;
ALTER TABLE peer_reviews ADD COLUMN revealed_at INTEGER;
ALTER TABLE peer_reviews ADD COLUMN reviewer_pool_size INTEGER DEFAULT 3;
ALTER TABLE peer_reviews ADD COLUMN consensus_threshold REAL DEFAULT 0.3;
-- reviewer_ns_id 字段在 anonymized_until 之前对查询者隐藏

-- 匿名化标记
-- 在评审提交阶段，评审者身份对彼此不可见
-- 在所有分配的评审者提交完成后，统一揭示身份
```

**防串谋逻辑**:

```typescript
// 防串谋评审分配 (v2.2)
async function assignPeerReviewers(
  taskId: string,
  reviewCount: number = 3
): Promise<string[]> {
  const task = db.get('SELECT * FROM task_warrants WHERE task_id = ?', [taskId]);
  const members = db.all(
    'SELECT ns_id FROM genesis_members WHERE genesis_id = ? AND ns_id != ?',
    [task.genesis_id, task.claimed_by]
  );

  // 1. 随机化分配（使用 VRF 种子确保不可预测）
  const seed = sha256(`${taskId}:${Date.now()}:${Math.random()}`);
  const shuffled = seededShuffle(members.map(m => m.ns_id), seed);

  // 2. 排除最近与 claims_by 协作过的成员（防串谋）
  const recentCollabs = db.all(
    `SELECT DISTINCT claimed_by FROM task_warrants
     WHERE genesis_id = ? AND claimed_by IS NOT NULL
     AND created_at > ? AND claimed_by != ?`,
    [task.genesis_id, Date.now() - 7 * 86400000, task.claimed_by]
  );

  const eligible = shuffled.filter(
    nsId => !recentCollabs.find(c => c.claimed_by === nsId)
  );

  const reviewers = eligible.slice(0, reviewCount);

  // 3. 设置匿名窗口期 (Phase 4 延迟: 72h 内匿名)
  const anonymizedUntil = Date.now() + 72 * 3600000;

  // 4. 创建评审记录（匿名模式）
  for (const reviewerId of reviewers) {
    db.run(
      `INSERT INTO peer_reviews (review_id, task_id, reviewer_ns_id, status,
        anonymized_until, reviewer_pool_size, created_at)
       VALUES (?, ?, ?, 'pending', ?, ?, ?)`,
      [generateId('pr'), taskId, reviewerId, anonymizedUntil, reviewCount, Date.now()]
    );
  }

  // 5. 通知评审者（不透露其他评审者身份）
  for (const reviewerId of reviewers) {
    await notifyReviewer(reviewerId, {
      taskId,
      reviewId: reviewIds[reviewerId],
      message: '你被分配了一个 PEER 评审任务。所有评审者身份将在提交后揭示。',
    });
  }

  return reviewers;
}

// 串谋检测（提交时）
async function detectCollusion(reviewId: string, score: number): Promise<CollusionResult> {
  const review = db.get('SELECT * FROM peer_reviews WHERE review_id = ?', [reviewId]);
  const siblingReviews = db.all(
    'SELECT * FROM peer_reviews WHERE task_id = ? AND review_id != ? AND status = "submitted"',
    [review.task_id, reviewId]
  );

  // 如果所有已提交评审的分数标准差过小，标记为潜在串谋
  if (siblingReviews.length > 0) {
    const allScores = [...siblingReviews.map(r => r.score), score];
    const stdDev = calculateStdDev(allScores);
    if (stdDev < review.consensus_threshold) {
      return {
        collusion_suspected: true,
        reason: `评分标准差 (${stdDev.toFixed(2)}) < 阈值 (${review.consensus_threshold})`,
        action: 'flag_for_manual_review'
      };
    }
  }

  return { collusion_suspected: false };
}
```

---

## 6.5 厂商锁定力检测（v3.2 — U28 工程映射）

### 6.5.1 问题描述

> *v2.7 — INFERNO-015 V3.3 修复：迁移阈值 θ 不是静态参数，是厂商可主动推高的战略变量。厂商通过数据锁定（不导出）、工作流锁定（专有插件生态）、习惯锁定（UI 粘性）主动提高 θ。若 θ 被推高到超过 E_B(t) 的增长天花板，交叉点永远不来。CONC 的对策是开放协议（数据可导出/Skill 可迁移/CSIP 标准化）降低厂商锁定能力——但开放协议的破解力 vs 厂商锁定力是竞争过程（U28 待验证）。*

工程化层需要实现厂商锁定力的量化检测和开放协议破解力的追踪，为 U28 提供可观测数据。

### 6.5.2 厂商锁定三维检测模型

```typescript
// 厂商锁定力三维评估
interface VendorLockAssessment {
  ns_id: string;
  assessment_date: number;

  // 维度一：数据锁定力
  data_lock: {
    export_supported: boolean;             // 平台是否支持数据导出
    export_format: 'open' | 'proprietary'; // 导出格式
    export_completeness: number;            // 0-1 导出完整度
    skill_portability: number;              // 0-1 Skill 可迁移度
    score: number;                          // 0-1 (1=完全锁定)
  };

  // 维度二：工作流锁定力
  workflow_lock: {
    plugin_ecosystem_open: boolean;        // 插件生态是否开放
    api_standard: 'mcp' | 'openai' | 'proprietary'; // API 标准
    vendor_switching_cost: number;          // 0-1 切换成本
    score: number;
  };

  // 维度三：习惯锁定力
  habit_lock: {
    ui_customization_depth: number;         // 0-1 UI 定制深度
    workflow_memorization: number;           // 0-1 操作记忆固化度
    score: number;
  };

  // 综合锁定指数
  theta_inflation: number;                  // θ 被推高量估算
}
```

### 6.5.3 CSIP 标准化方案

```typescript
// CSIP（智权体技能接口协议）标准化检测
async function checkCSIPCompliance(
  platform: string
): Promise<{ compliant: boolean; gaps: string[] }> {
  const checks = [
    { id: 'data_export', test: () => checkDataExportSupport(platform) },
    { id: 'skill_migration', test: () => checkSkillMigrationPath(platform) },
    { id: 'api_standard', test: () => checkAPIStandard(platform) },
    { id: 'workflow_capture', test: () => checkWorkflowExport(platform) },
  ];

  const gaps: string[] = [];
  for (const check of checks) {
    if (!(await check.test())) gaps.push(check.id);
  }
  return { compliant: gaps.length === 0, gaps };
}
```

### 6.5.4 厂商锁定检测 SQLite Schema

```sql
-- 厂商锁定检测表 (v3.2 新增)
CREATE TABLE vendor_lock_assessments (
  assessment_id TEXT PRIMARY KEY,
  ns_id TEXT NOT NULL,
  platform TEXT NOT NULL,
  data_lock_score REAL NOT NULL,
  workflow_lock_score REAL NOT NULL,
  habit_lock_score REAL NOT NULL,
  theta_inflation REAL NOT NULL,
  csip_compliant INTEGER DEFAULT 0,
  assessment_date INTEGER NOT NULL,
  FOREIGN KEY (ns_id) REFERENCES noetic_sovereigns(ns_id)
);

CREATE INDEX idx_vla_ns ON vendor_lock_assessments(ns_id);
CREATE INDEX idx_vla_platform ON vendor_lock_assessments(platform);
```

**U28 工程追踪**：系统定期生成厂商锁定力 vs 开放协议破解力趋势报告。若 `theta_inflation` 持续上升且 CSIP 合规率持续 < 30%，系统发出 U28 预警——标记为"开放协议破解力不足以抗衡厂商锁定力"。

---

# 第七篇：v2.2 新增 — 冷启动工程实现

## Chapter 7: Cold Start Engineering

---

## 7.1 冷启动困境

CONC 面临经典的双边市场冷启动问题：
- 没有策元 → 没有任务令 → 没有智权体 → 没有策元
- 没有历史数据 → ICP 匹配质量差 → 用户体验差 → 流失

v2.2 通过三个工程机制解决冷启动：创世任务令、IVD能证名片、平台适配器。

---

## 7.2 创世任务令 (Genesis Task Order)

### 7.2.1 自动触发逻辑

智权体注册时自动触发冷启动流程：

```
onRegistration(ns_id)
    │
    ├── 1. 分析注册数据 (GitHub profile, 偏好向量, 身份锚定)
    │
    ├── 2. 触发 CP_BOOTSTRAP:
    │      - 为每个新智权体创建"探索策元" (exploration GU)
    │      - 探索策元包含 3-5 个引导性任务令
    │
    ├── 3. 触发 NR_SEED_PROJECT:
    │      - 根据 GitHub 数据生成初始能证
    │      - 从 task_templates 表分配匹配的种子任务
    │
    └── 4. 返回冷启动仪表盘
```

**实现代码**:

```typescript
async function onRegistration(nsId: string): Promise<ColdStartResult> {
  const ns = db.get('SELECT * FROM noetic_sovereigns WHERE ns_id = ?', [nsId]);

  // Step 1: 创建探索策元
  const explorationGenesis = await createBootstrapGenesis(nsId);

  // Step 2: 分配引导任务令
  const bootstrapTasks = await assignBootstrapTasks(nsId, explorationGenesis.genesis_id);

  // Step 3: 生成初始 NR 种子
  await seedInitialNR(nsId);

  return {
    genesis_id: explorationGenesis.genesis_id,
    task_count: bootstrapTasks.length,
    tasks: bootstrapTasks,
  };
}

async function createBootstrapGenesis(nsId: string): Promise<any> {
  return db.transaction(() => {
    const genesisId = generateId('gu_');

    db.run(
      `INSERT INTO genesis_units (genesis_id, name, creative_seed_id, pcp_hash,
        pcp_template, theta_similarity, lifecycle_state, core_ns_id, created_at, updated_at)
       VALUES (?, ?, ?, ?, 'exploration', 0.5, 'forming', ?, ?, ?)`,
      [genesisId, '探索空间', 'cs_bootstrap', 'sha256:bootstrap', nsId, Date.now(), Date.now()]
    );

    db.run(
      `INSERT INTO genesis_members (genesis_id, ns_id, role, joined_at)
       VALUES (?, ?, 'core', ?)`,
      [genesisId, nsId, Date.now()]
    );

    return { genesis_id: genesisId };
  });
}
```

### 7.2.2 task_templates 表预置数据

```sql
-- 任务令模板表 (v2.2 新增)
CREATE TABLE task_templates (
  template_id TEXT PRIMARY KEY,
  category TEXT NOT NULL,               -- onboarding | skill_building | contribution | networking
  title TEXT NOT NULL,
  human_objective TEXT NOT NULL,
  agent_prompt TEXT,
  verification_mode TEXT DEFAULT 'auto',
  estimated_hours REAL DEFAULT 2,
  required_skills JSON,                 -- ["skill_name": "min_level"]
  direction_tags TEXT[],                 -- ["技术","设计","商业","研究","公益"]
  sort_order INTEGER DEFAULT 0,
  is_active INTEGER DEFAULT 1
);

-- 预置数据 (10 个引导任务令)
INSERT INTO task_templates VALUES
('tt_001', 'onboarding',
 '完善你的智权体资料',
 '补全你的技能标签、偏好的协作方向和工作时间，让 ICP 匹配更精准。',
 '根据用户 GitHub profile 和历史项目，建议补充的技能标签和方向偏好。',
 'auto', 1.0,
 '{}', '{技术}', 1, 1),

('tt_002', 'onboarding',
 '创建你的方向档案 (Direction Profile)',
 '基于你的技能和兴趣，填写 5 维方向向量，帮助系统更好地理解你的协作偏好。',
 '分析用户的技能背景和项目历史，建议初始方向向量值。',
 'auto', 0.5,
 '{}', '{技术,设计,商业,研究,公益}', 2, 1),

('tt_003', 'skill_building',
 '从 GitHub 导入你的项目经验',
 '将你的开源贡献转化为 CONC 的 NR 初始值。导入至少 3 个 GitHub 仓库。',
 '检查用户的 GitHub 仓库，提取贡献记录并生成 NR 种子提案。',
 'auto', 1.5,
 '{"github_api": 1}', '{技术}', 3, 1),

('tt_004', 'contribution',
 '推荐一个你喜欢的开源项目',
 '在探索策元中分享一个你认为值得关注的开源项目，并附上推荐理由。',
 NULL,
 'peer:3', 1.0,
 '{}', '{技术,设计,商业,研究,公益}', 4, 1),

('tt_005', 'networking',
 '浏览并评价 3 个创意图元',
 '查看种子池中的创意图元，对感兴趣的表达意向 (express intent)。',
 NULL,
 'auto', 0.5,
 '{}', '{技术,设计,商业,研究,公益}', 5, 1),

('tt_006', 'skill_building',
 '填写 CSIP 技能接口',
 '在 CSIP 中声明你的 3-5 项核心技能，并标注熟练度。',
 '根据用户的 GitHub 仓库、贡献记录和教育背景，建议技能声明。',
 'auto', 1.0,
 '{}', '{技术,设计,商业,研究,公益}', 6, 1),

('tt_007', 'contribution',
 '完成第一个 CONC 文档模板',
 '使用 conc_doc_create 创建第一篇文档，学习文档生命周期流程。',
 NULL,
 'auto', 0.5,
 '{}', '{技术}', 7, 1),

('tt_008', 'networking',
 '邀请一位协作者加入 CONC',
 '通过 CONC 邀请链接邀请一位朋友或同事加入，共同探索协作。',
 NULL,
 'auto', 0.5,
 '{}', '{技术,设计,商业,研究,公益}', 8, 1),

('tt_009', 'skill_building',
 '评价你的第一个 PEER 评审',
 '学习 PEER 评审标准，对其他智权体的交付物进行客观评价。',
 '向用户展示一个待评审交付物，引导其按 4 维度评分。',
 'auto', 1.0,
 '{}', '{技术,设计,商业,研究,公益}', 9, 1),

('tt_010', 'contribution',
 '发起你的第一个创意图元',
 '创建一个创意图元 (Creative Seed)，描述你想协作实现的项目想法。',
 '引导用户通过自然语言描述项目想法，自动生成方向向量。',
 'auto', 1.0,
 '{}', '{技术,设计,商业,研究,公益}', 10, 1);
```

---

## 7.3 IVD 能证名片 (Identity Verification & Display)

### 7.3.1 概念

IVD 能证名片是智权体的可视化身份摘要——从 GitHub 等外部平台数据自动生成技能标签、能力热力图和协作偏好，为新智权体提供初始身份锚定。

### 7.3.2 能证名片生成流程

```
GitHub 数据 (仓库、贡献、语言、star、PR)
    │
    ▼
┌─────────────────────────────────────┐
│     IVD Generator (能证生成器)       │
│                                     │
│ 1. 技能提取:                        │
│    - 编程语言分布 (从仓库语言统计)   │
│    - 框架/工具识别 (从 dependency)   │
│    - 项目领域分类 (从 README/topics) │
│                                     │
│ 2. 热力图生成:                      │
│    - 贡献密度 (contribution calendar)│
│    - 活跃时段分析                    │
│    - 项目规模分布                    │
│                                     │
│ 3. 方向向量推断:                    │
│    - 技术→ 技术仓库占比              │
│    - 设计→ UI/UX 相关贡献            │
│    - 商业→ 产品/startup 项目          │
│    - 研究→ 论文/academic 项目         │
│    - 公益→ 开源/非营利项目            │
│                                     │
│ 4. NR 种子计算:                     │
│    - 基础分: account_age_days / 365  │
│    - 贡献分: stars + PRs + commits   │
│    - 质量分: forks/stars 比率         │
└─────────────────────────────────────┘
    │
    ▼
IVD 能证名片 (JSON + 可视化)
```

### 7.3.3 技能标签自动推断

```typescript
// 从 GitHub 数据推断技能标签
async function inferSkillsFromGitHub(githubUsername: string): Promise<InferredSkill[]> {
  const repos = await fetchGitHubRepos(githubUsername);
  const skills: Map<string, { evidence: string[]; confidence: number }> = new Map();

  for (const repo of repos) {
    // 语言技能
    if (repo.language) {
      const lang = normalizeLanguage(repo.language);
      if (!skills.has(lang)) skills.set(lang, { evidence: [], confidence: 0 });
      const skill = skills.get(lang)!;
      skill.evidence.push(`repo:${repo.name}`);
      skill.confidence += 0.1;
    }

    // 框架/工具从 topics 推断
    for (const topic of repo.topics || []) {
      const framework = detectFramework(topic);
      if (framework) {
        if (!skills.has(framework)) skills.set(framework, { evidence: [], confidence: 0 });
        const skill = skills.get(framework)!;
        skill.evidence.push(`topic:${topic}@${repo.name}`);
        skill.confidence += 0.08;
      }
    }

    // 领域推断
    const domain = inferDomain(repo.description, repo.topics);
    if (domain) {
      if (!skills.has(domain)) skills.set(domain, { evidence: [], confidence: 0 });
      const skill = skills.get(domain)!;
      skill.evidence.push(`domain:${repo.name}`);
      skill.confidence += 0.05;
    }
  }

  // 归一化 confidence 和排序
  return Array.from(skills.entries())
    .map(([name, data]) => ({
      skill_name: name,
      confidence: Math.min(data.confidence, 1.0),
      level: confidenceToLevel(data.confidence),
      evidence: data.evidence.slice(0, 3),  // 最多保留 3 条证据
    }))
    .sort((a, b) => b.confidence - a.confidence)
    .slice(0, 10);  // 最多 10 项技能
}

function confidenceToLevel(confidence: number): number {
  if (confidence >= 0.8) return 5;  // 专家
  if (confidence >= 0.6) return 4;  // 高级
  if (confidence >= 0.4) return 3;  // 中级
  if (confidence >= 0.2) return 2;  // 初级
  return 1;                          // 了解
}
```

**IVD 能证名片存储（v2.2 新增）**:

```sql
-- IVD 能证表 (v2.2 新增)
CREATE TABLE ivd_profiles (
  ns_id TEXT PRIMARY KEY,
  github_username TEXT,
  gitlab_username TEXT,
  stackoverflow_id TEXT,
  inferred_skills_json TEXT,            -- InferredSkill[]
  direction_vector FLOAT[5],
  activity_heatmap_json TEXT,           -- { date: contribution_count }
  nr_seed_score REAL DEFAULT 0,
  cold_start_progress REAL DEFAULT 0,   -- 0.0-1.0 冷启动完成度
  generated_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  FOREIGN KEY (ns_id) REFERENCES noetic_sovereigns(ns_id)
);

CREATE INDEX idx_ivp_github ON ivd_profiles(github_username);
```

---

## 7.4 平台适配器架构

### 7.4.1 设计理念

CONC 需要从多个外部平台导入用户数据和贡献记录。平台适配器采用策略模式，统一接口，各自实现。

### 7.4.2 PlatformAdapter 接口

```typescript
// 平台适配器接口
interface PlatformAdapter {
  platform: PlatformType;                              // 平台标识
  name: string;                                        // 平台名称

  // 能力检测
  canImport(): Promise<boolean>;                       // 平台是否可访问

  // 数据导入
  importProfile(credentials: PlatformCredentials): Promise<ExternalProfile>;
  importContributions(
    credentials: PlatformCredentials,
    since?: Date
  ): Promise<ExternalContribution[]>;
  importRepositories?(credentials: PlatformCredentials): Promise<ExternalRepo[]>;

  // 能证验证
  verifyOwnership(credentials: PlatformCredentials): Promise<boolean>;

  // NR 种子计算
  calculateNRSeed(profile: ExternalProfile, contributions: ExternalContribution[]): number;
}

type PlatformType = 'github' | 'gitlab' | 'stackoverflow' | 'manual';
```

### 7.4.3 各平台适配器实现

#### GitHub 适配器

```typescript
class GitHubAdapter implements PlatformAdapter {
  platform: PlatformType = 'github';
  name = 'GitHub';

  async canImport(): Promise<boolean> {
    try {
      await fetch('https://api.github.com/zen');
      return true;
    } catch { return false; }
  }

  async importProfile(credentials: { username: string; token?: string }): Promise<ExternalProfile> {
    const headers: any = {};
    if (credentials.token) headers['Authorization'] = `Bearer ${credentials.token}`;

    const userData = await fetch(`https://api.github.com/users/${credentials.username}`, { headers });
    const user = await userData.json();

    return {
      platform: 'github',
      external_id: String(user.id),
      display_name: user.name || user.login,
      bio: user.bio,
      avatar_url: user.avatar_url,
      public_repos: user.public_repos,
      followers: user.followers,
      account_created_at: new Date(user.created_at).getTime(),
      raw_data: user,
    };
  }

  async importContributions(credentials: any, since?: Date): Promise<ExternalContribution[]> {
    // 通过 GitHub API Events 或 GraphQL contributionsCollection 获取
    // ...
    return [];
  }

  async verifyOwnership(credentials: { username: string; token: string }): Promise<boolean> {
    try {
      const res = await fetch('https://api.github.com/user', {
        headers: { 'Authorization': `Bearer ${credentials.token}` }
      });
      const user = await res.json();
      return user.login === credentials.username;
    } catch { return false; }
  }

  calculateNRSeed(profile: ExternalProfile, contributions: ExternalContribution[]): number {
    const accountAgeDays = (Date.now() - profile.account_created_at) / 86400000;
    const baseScore = Math.min(accountAgeDays / 365 * 100, 200);  // 基础分: 最高 200
    const contributionScore = Math.min(contributions.length * 2, 300);  // 贡献分: 最高 300
    return Math.round(baseScore + contributionScore);
  }
}
```

#### GitLab 适配器

```typescript
class GitLabAdapter implements PlatformAdapter {
  platform: PlatformType = 'gitlab';
  name = 'GitLab';

  async importProfile(credentials: { username: string; instance?: string }): Promise<ExternalProfile> {
    const baseUrl = credentials.instance || 'https://gitlab.com';
    const res = await fetch(`${baseUrl}/api/v4/users?username=${credentials.username}`);
    const users = await res.json();
    if (!users.length) throw new Error('user_not_found');

    const user = users[0];
    return {
      platform: 'gitlab',
      external_id: String(user.id),
      display_name: user.name || user.username,
      bio: user.bio,
      avatar_url: user.avatar_url,
      public_repos: 0,
      followers: 0,
      account_created_at: new Date(user.created_at).getTime(),
      raw_data: user,
    };
  }

  async importContributions(credentials: any): Promise<ExternalContribution[]> {
    // GitLab API: /users/:id/events
    return [];
  }

  async verifyOwnership(credentials: { username: string; token: string; instance?: string }): Promise<boolean> {
    const baseUrl = credentials.instance || 'https://gitlab.com';
    try {
      const res = await fetch(`${baseUrl}/api/v4/user`, {
        headers: { 'PRIVATE-TOKEN': credentials.token }
      });
      const user = await res.json();
      return user.username === credentials.username;
    } catch { return false; }
  }

  calculateNRSeed(profile: ExternalProfile, contributions: ExternalContribution[]): number {
    return Math.min(Math.round(contributions.length * 1.5), 300);
  }
}
```

#### Stack Overflow 适配器

```typescript
class StackOverflowAdapter implements PlatformAdapter {
  platform: PlatformType = 'stackoverflow';
  name = 'Stack Overflow';

  async importProfile(credentials: { user_id: string }): Promise<ExternalProfile> {
    const res = await fetch(
      `https://api.stackexchange.com/2.3/users/${credentials.user_id}?site=stackoverflow`
    );
    const data = await res.json();
    const user = data.items[0];

    return {
      platform: 'stackoverflow',
      external_id: String(user.user_id),
      display_name: user.display_name,
      bio: user.about_me || '',
      avatar_url: user.profile_image,
      public_repos: 0,
      followers: 0,
      account_created_at: user.creation_date * 1000,
      raw_data: { reputation: user.reputation, badge_counts: user.badge_counts },
    };
  }

  async importContributions(credentials: any): Promise<ExternalContribution[]> {
    // Stack Exchange API: /users/:id/answers, /users/:id/questions
    return [];
  }

  async verifyOwnership(): Promise<boolean> {
    // Stack Overflow 公开数据，无需验证
    return true;
  }

  calculateNRSeed(profile: ExternalProfile, contributions: ExternalContribution[]): number {
    const reputation = profile.raw_data.reputation || 0;
    return Math.min(Math.round(reputation / 10), 300);
  }
}
```

#### 手动导入适配器

```typescript
class ManualAdapter implements PlatformAdapter {
  platform: PlatformType = 'manual';
  name = '手动导入';

  async importProfile(credentials: { profile_json: string }): Promise<ExternalProfile> {
    return JSON.parse(credentials.profile_json);
  }

  async importContributions(): Promise<ExternalContribution[]> {
    return [];  // 手动导入无贡献记录
  }

  async verifyOwnership(): Promise<boolean> {
    return true;  // 手动数据无需验证
  }

  calculateNRSeed(): number {
    return 50;  // 手动导入最低 NR 种子
  }

  async canImport(): Promise<boolean> { return true; }
}
```

### 7.4.4 适配器注册表

```typescript
// 平台适配器注册表
const PlatformAdapterRegistry: Record<PlatformType, PlatformAdapter> = {
  github: new GitHubAdapter(),
  gitlab: new GitLabAdapter(),
  stackoverflow: new StackOverflowAdapter(),
  manual: new ManualAdapter(),
};

// MCP Tool: conc_identity_import (P0)
server.tool('conc_identity_import', {
  platform: z.enum(['github', 'gitlab', 'stackoverflow', 'manual']),
  credentials: z.object({
    username: z.string().optional(),
    user_id: z.string().optional(),
    token: z.string().optional(),
    instance: z.string().optional(),
    profile_json: z.string().optional(),
  }),
}, async (params) => {
  const adapter = PlatformAdapterRegistry[params.platform];
  const profile = await adapter.importProfile(params.credentials);
  const contributions = await adapter.importContributions(params.credentials);
  const nrSeed = adapter.calculateNRSeed(profile, contributions);

  // 存入 ivd_profiles 表
  // 更新智权体 NR
  return { profile, nr_seed: nrSeed, contribution_count: contributions.length };
});
```

---

## 7.5 被动群体 Skill 增值管道（v3.2 — §0.6.4 工程映射）

### 7.5.1 问题描述

> *v2.7 — INFERNO-015 V2.2 修复。T3+T11 联合隐含"永久被动群体"——最先被释放的低技能劳动者，带入 CONC 的 skill 是分布内低创造性 skill，在 NR 系统中声誉积累最慢，可能永远到不了 F_active > F_passive 的切换点。这不是 CONC 的设计缺陷，是阈值跨越期的结构性不平等在 CONC 内的投射。*

**被动群体 skill 贫困陷阱循环**：低 skill 价值 → NR 积累慢 → VT 收益低 → 无法积累 F_active → 永久被动。

工程化层需实现三个缓解管道——公共 CU 倾斜分配、种子策元降门槛、基础 Skill 培训协议。

### 7.5.2 公共 CU 配额优先分配

```typescript
// 被动群体 CU 倾斜分配
async function allocatePassiveGroupCU(nsId: string): Promise<PassiveGroupAllocation> {
  const ns = db.get('SELECT * FROM noetic_sovereigns WHERE ns_id = ?', [nsId]);
  
  // 1. 判定是否属于被动群体
  // 被动群体判定标准：skill_portfolio 中分布内技能占比 > 80%
  // 且 NR 排名处于后 20%
  const isPassive = await isPassiveGroupMember(nsId);
  if (!isPassive) return { allocated: false, reason: 'not_passive_group' };
  
  // 2. 计算倾斜配额
  // 基础配额 × 1.5 倾斜系数
  const baseQuota = await getBaseCUQuota(nsId);
  const tiltedQuota = baseQuota * 1.5;
  
  // 3. 记录倾斜分配
  db.run(
    `INSERT INTO passive_group_cu (ns_id, base_quota, tilted_quota, tilt_factor, allocated_at)
     VALUES (?, ?, ?, 1.5, ?)`,
    [nsId, baseQuota, tiltedQuota, Date.now()]
  );
  
  return { allocated: true, base_quota: baseQuota, tilted_quota: tiltedQuota };
}

async function isPassiveGroupMember(nsId: string): Promise<boolean> {
  // 判定逻辑：skill 分布内占比 + NR 排名 + 迁移主因类型
  const profile = db.get('SELECT * FROM ivd_profiles WHERE ns_id = ?', [nsId]);
  const nr = db.get('SELECT nr_value FROM noetic_sovereigns WHERE ns_id = ?', [nsId]);
  
  if (!profile || !nr) return false;
  
  const skills = JSON.parse(profile.inferred_skills_json || '[]');
  const inDistributionSkills = skills.filter((s: any) => s.level <= 2).length;
  const inDistributionRatio = skills.length > 0 ? inDistributionSkills / skills.length : 1;
  
  // NR 排名后 20%
  const nrRank = db.get(
    'SELECT COUNT(*) + 1 as rank FROM noetic_sovereigns WHERE nr_value > ?',
    [nr.nr_value]
  );
  const totalCount = db.get('SELECT COUNT(*) as cnt FROM noetic_sovereigns');
  const isLowNR = (nrRank.rank as number) / (totalCount.cnt as number) > 0.8;
  
  return inDistributionRatio > 0.8 && isLowNR;
}
```

### 7.5.3 种子策元优先接纳

```sql
-- 被动群体种子策元表 (v3.2 新增)
CREATE TABLE passive_group_seed_genesis (
  seed_genesis_id TEXT PRIMARY KEY,
  host_genesis_id TEXT NOT NULL,             -- 种子策元
  passive_ns_id TEXT,                        -- 被动群体成员（null 表示开放接纳）
  drop_threshold REAL DEFAULT 0.6,           -- NR 评审降门槛系数
  protected_until INTEGER,                   -- 新手保护期结束时间
  created_at INTEGER NOT NULL,
  FOREIGN KEY (host_genesis_id) REFERENCES genesis_units(genesis_id),
  FOREIGN KEY (passive_ns_id) REFERENCES noetic_sovereigns(ns_id)
);
```

### 7.5.4 基础 Skill 培训协议接口

```typescript
// 基础 Skill 培训协议（政府教育兜底职能）
interface BasicSkillTrainingProtocol {
  ns_id: string;
  training_type: 'digital_literacy' | 'skill_mapping' | 'tool_familiarity' | 'peer_review_training';
  trainer_ns_id: string;                     // 培训师（由公共教育基金支付）
  skill_areas: string[];                     // 培训后应掌握的 skill 领域
  duration_hours: number;
  assessment_threshold: number;              // 通过评估阈值
  completion_status: 'pending' | 'in_progress' | 'completed' | 'failed';
  completed_at?: number;
}
```

### 7.5.5 诚实边界声明

上述措施不保证"永久被动"概率为零。若被动群体中长期到达 F_active > F_passive 切换点的比例 < 20%，CONC 的公理二a对该群体实质空洞（U29 待验证）。工程化层的角色是提供降低概率的管道并标注验证条件——而非消除结构性不平等。

---

## 7.6 被动群体迁移追踪仪表盘（v3.2 — U29 工程映射）

### 7.6.1 设计目标

追踪被动群体中到达 F_active > F_passive 切换点的比例，为 U29 提供可观测数据。

### 7.6.2 迁移追踪数据模型

```typescript
interface PassiveGroupMigrationTrack {
  ns_id: string;
  track_date: number;
  
  // 被动力（F_passive）——被释放+无处可去
  f_passive: {
    displacement_force: number;              // 被替代强度（0-1）
    nowhere_else_force: number;              // 无处可去强度（0-1）
    total: number;
  };
  
  // 主动力（F_active）——追求自由联合
  f_active: {
    creative_urge: number;                   // 创造冲动（0-1）
    autonomy_preference: number;             // 自主偏好（0-1）
    skill_accumulation: number;              // Skill 积累速率
    total: number;
  };
  
  // 切换点判定
  has_switched: boolean;                     // F_active > F_passive?
  switch_point_timestamp?: number;           // 切换点时间戳
  remaining_years?: number;                  // 预期剩余被动年数
}
```

### 7.6.3 追踪 SQLite Schema

```sql
-- 被动群体迁移追踪表 (v3.2 新增)
CREATE TABLE passive_group_migration_tracks (
  track_id TEXT PRIMARY KEY,
  ns_id TEXT NOT NULL,
  f_passive_total REAL NOT NULL,
  f_active_total REAL NOT NULL,
  has_switched INTEGER DEFAULT 0,
  switch_point_timestamp INTEGER,
  skill_accumulation_rate REAL DEFAULT 0,
  track_date INTEGER NOT NULL,
  FOREIGN KEY (ns_id) REFERENCES noetic_sovereigns(ns_id)
);

CREATE INDEX idx_pgmt_ns ON passive_group_migration_tracks(ns_id);
CREATE INDEX idx_pgmt_switched ON passive_group_migration_tracks(has_switched);
CREATE INDEX idx_pgmt_date ON passive_group_migration_tracks(track_date);
```

**U29 仪表盘指标**：

| 指标 | 计算方式 | 预警阈值 |
|------|---------|---------|
| 被动群体总数 | count(ns_id WHERE is_passive=true) | — |
| 已切换人数 | count(ns_id WHERE has_switched=true) | — |
| 切换率 | 已切换 / 被动群体总数 | < 20% → U29 红色预警 |
| 平均切换时间 | avg(switch_point_timestamp - first_track_date) | > 2 年 → 高摩擦 |
| 平均 Skill 积累速率 | avg(skill_accumulation_rate) | < 0.1 → 增值管道失效 |

---

# 第八篇：v2.2 新增 — 工具精简与 P0 重定义

## Chapter 8: Tool Simplification — 29 → 15 P0

---

## 8.1 精简原则

v1.0 的 MCP Tools 总计 29 个（13 协议层 + 9 文档/GHF层 + 7 SBDEL v2.0层），数量过多导致：
- Agent 上下文窗口占用大（每个 Tool 定义约 200-500 tokens）
- 用户学习曲线陡峭
- 维护负担重
- 部分工具使用频率极低（如 conc_genesis_dissolve）

v2.2 精简原则：
1. **P0 级**: 核心工作流闭环必需的 15 个工具，优先实现和稳定
2. **P1 级**: 标记为 experimental，在 Phase 4/5 后启用
3. **合并**: 功能相近的工具合并为一个（如 list + detail 合并）

## 8.2 P0 核心工具清单（15 个）

### Identity（2 个）

| Tool | 功能 | 精简说明 |
|------|------|---------|
| `conc_identity_register` | 智权体注册 | v1.0: identity_register — 不变 |
| `conc_identity_show` | 查看我的智权体资料 | v1.0: identity_show — 不变 |

### Seed（2 个）

| Tool | 功能 | 精简说明 |
|------|------|---------|
| `conc_seed_create` | 创建创意图元 | v1.0: seed_create — 不变 |
| `conc_seed_list` | 列出创意图元 | v1.0: seed_list + icp_match 合并（加入方向向量筛选） |

**合并说明**: `conc_seed_list` 现在支持 `direction_vector` 和 `theta` 参数，可同时完成列表和匹配功能。

### Genesis（2 个）

| Tool | 功能 | 精简说明 |
|------|------|---------|
| `conc_genesis_create` | 创建策元 | v1.0: genesis_create — 不变 |
| `conc_genesis_detail` | 策元详情（含成员、任务令统计） | v1.0: genesis_list + genesis_detail + genesis_join 合并 |

**合并说明**: `conc_genesis_detail` 不再需要单独的 genesis_id 参数——传入 `"my"` 或 `"all"` 即可列出所有参与的策元；传入具体 ID 则查看详情。Join 通过 `action: 'join'` 参数实现。

### Task（4 个）

| Tool | 功能 | 精简说明 |
|------|------|---------|
| `conc_task_create` | 创建任务令 | v1.0: task_create — 不变 |
| `conc_task_claim` | 领取任务令 | v1.0: task_claim — 不变 |
| `conc_task_submit` | 提交任务令交付物 | v1.0: task_submit — 不变 |
| `conc_task_list` | 查看任务令（含 DAG 视图） | v1.0: task_list + task_my + task_dag 合并 |

**合并说明**: `conc_task_list` 支持 `view: 'my' | 'all' | 'dag'` 参数，三合一。

### Self Review（1 个）

| Tool | 功能 | 精简说明 |
|------|------|---------|
| `conc_self_review` | 自我审查（提交前质量检查） | v2.2 新增 P0 — 替代之前的 AUTO standalone 检查 |

**新增说明**: 自我审查是 CTCP 状态机的必要环节——在执行→验证的跃迁前，智权体应先自检交付物。

### From Template（1 个）

| Tool | 功能 | 精简说明 |
|------|------|---------|
| `conc_from_template` | 从模板创建（任务令/文档/策元） | v2.2 新增 P0 — 冷启动和效率工具 |

**新增说明**: 统一的模板入口。`template_type: 'task' | 'doc' | 'genesis'`。

### Event Poll（1 个）

| Tool | 功能 | 精简说明 |
|------|------|---------|
| `conc_event_poll` | 增量拉取协作事件 | v2.2 新增 P0 — 协作层事件总线 |

### Judgment（2 个）

| Tool | 功能 | 精简说明 |
|------|------|---------|
| `conc_judgment_request` | 发起决断请求 | v2.2 新增 P0 — 决断层核心工具 |
| `conc_judgment_vote` | 投票决断 | v2.2 新增 P0 — 决断层核心工具 |

---

### P0 工具汇总

```
conc_identity_register   ← 智权体注册
conc_identity_show       ← 查看智权体资料

conc_seed_create         ← 创建创意图元
conc_seed_list           ← 列表+匹配 (合并 icp_match)

conc_genesis_create      ← 创建策元
conc_genesis_detail      ← 详情+列表+加入 (合并 list/detail/join)

conc_task_create         ← 创建任务令
conc_task_claim          ← 领取任务令
conc_task_submit         ← 提交交付物
conc_task_list           ← 列表+DAG+我的 (合并 list/my/dag)

conc_self_review         ← 自我审查 (新增)
conc_from_template       ← 模板创建 (新增)
conc_event_poll          ← 事件轮询 (新增)

conc_judgment_request    ← 决断请求 (新增)
conc_judgment_vote       ← 决断投票 (新增)
```

---

## 8.3 P1 工具清单（标记 experimental）

以下工具在 Phase 4/5 期间保留但不作为 P0 优先级：

### Protocol Layer P1（5 个）

| Tool | 原功能 | 状态 |
|------|--------|------|
| `conc_genesis_dissolve` | 策元解散 | P1 — 低频操作 |
| `conc_peer_submit` | 提交评审 | P1 — 由系统自动分配触发 |
| `conc_peer_stats` | 评审统计 | P1 — 合并到 genesis_detail |
| `conc_ccr_show` | CCR 查询 | P1 — 合并到 identity_show |
| `conc_network_status` | 网络状态 | P1 — 合并到 event_poll |

### Document & GHF Layer P1（2 个）

| Tool | 原功能 | 状态 |
|------|--------|------|
| `conc_ghf_timeline` | GHF 时间线 | P1 — 通过 event_poll 替代 |
| `conc_pcp_ratify` | PCP 批准 | P1 — 通过 judgment_request 替代 |

### Document CRUD P1（7 个）

| Tool | 原功能 | 状态 |
|------|--------|------|
| `conc_doc_create` | 创建文档 | P1 — 通过 from_template 替代 |
| `conc_doc_submit` | 提交文档审核 | P1 — 文档生命周期自动化 |
| `conc_doc_review` | 审核文档 | P1 — 由 Gate 引擎自动触发 |
| `conc_doc_publish` | 发布文档 | P1 — Gate 通过后自动 |
| `conc_doc_archive` | 归档文档 | P1 — 低频 |
| `conc_doc_detail` | 文档详情 | P1 — 合并到 event_poll |
| `conc_doc_list` | 文档列表 | P1 — 合并到 genesis_detail |

### SBDEL v2.0 Layer P1（7 个）

| Tool | 原功能 | 状态 |
|------|--------|------|
| `conc_skill_v2_create` | 创建 Skill v2.0 | P1 — Phase 5 |
| `conc_skill_v2_fork` | Fork Skill | P1 — Phase 5 |
| `conc_skill_v2_detail` | Skill 详情 | P1 — Phase 5 |
| `conc_skill_v2_search` | 搜索 Skill | P1 — Phase 5 |
| `conc_direction_profile` | 方向档案 | P1 — 合并到 identity_show |
| `conc_judgment_credit` | 判断力信用 | P1 — 自动计算 |
| `conc_judgment_record` | 判断力记录 | P1 — 合并到 event_poll |

---

# 第九篇：v2.2 新增 — 数据持久性设计

## Chapter 9: Data Persistence Design

---

## 9.1 设计目标

CONC 的核心数据（NR、CCR、Skill、GHF）需要持久化保障，防止数据丢失和篡改。v2.2 采用三层渐进式持久性方案。

## 9.2 第一层：NR/CCR 哈希链

### 9.2.1 设计

每个智权体的 NR 和 CCR 变更形成一条哈希链，每次变更都引用前一次的状态哈希：

```
NR链:
  NR(0) = 初始种子值
  NR(1) = H(NR(0) || Δ₁) → 第一次变更
  NR(2) = H(NR(1) || Δ₂) → 第二次变更
  ...
  NR(n) = H(NR(n-1) || Δn) → 当前值

其中 H = SHA-256, Δi = 变更信息 (时间戳 + 原因 + 数值变化)
```

### 9.2.2 实现

```sql
-- NR 哈希链表 (v2.2 新增)
CREATE TABLE nr_hash_chain (
  chain_id TEXT PRIMARY KEY,             -- nc_{ns_id}_{seq}
  ns_id TEXT NOT NULL,
  seq INTEGER NOT NULL,
  nr_value REAL NOT NULL,
  delta REAL NOT NULL,                   -- 本次变更量
  delta_reason TEXT NOT NULL,            -- task_completed | peer_rating | penalty | seed
  previous_hash TEXT NOT NULL,           -- 前一个区块的哈希
  current_hash TEXT NOT NULL,            -- 当前区块的哈希 = H(previous_hash || nr_value || delta || timestamp)
  related_entity_id TEXT,                -- 关联的任务令/评审/策元 ID
  timestamp INTEGER NOT NULL,
  signature TEXT NOT NULL,               -- Ed25519 签名 (ns_id 的私钥签名)
  FOREIGN KEY (ns_id) REFERENCES noetic_sovereigns(ns_id)
);

CREATE INDEX idx_nhc_ns ON nr_hash_chain(ns_id, seq);
CREATE UNIQUE INDEX idx_nhc_hash ON nr_hash_chain(current_hash);

-- CCR 哈希链表 (v2.2 新增)
CREATE TABLE ccr_hash_chain (
  chain_id TEXT PRIMARY KEY,
  ns_id TEXT NOT NULL,
  seq INTEGER NOT NULL,
  ccr_value REAL NOT NULL,
  vt_contributed REAL NOT NULL,          -- 本期 VT 贡献
  cu_consumed REAL NOT NULL,             -- 本期 CU 消费
  delta_reason TEXT NOT NULL,
  previous_hash TEXT NOT NULL,
  current_hash TEXT NOT NULL,
  period_start INTEGER NOT NULL,         -- 30天周期开始
  period_end INTEGER NOT NULL,           -- 30天周期结束
  timestamp INTEGER NOT NULL,
  signature TEXT NOT NULL,
  FOREIGN KEY (ns_id) REFERENCES noetic_sovereigns(ns_id)
);
```

### 9.2.3 哈希链验证

```typescript
// 验证 NR 链的完整性
async function verifyNRChain(nsId: string): Promise<ChainVerificationResult> {
  const chain = db.all(
    'SELECT * FROM nr_hash_chain WHERE ns_id = ? ORDER BY seq',
    [nsId]
  );

  const violations: string[] = [];

  for (let i = 1; i < chain.length; i++) {
    const prev = chain[i - 1];
    const curr = chain[i];

    // 1. 验证前向哈希引用
    if (curr.previous_hash !== prev.current_hash) {
      violations.push(`seq ${curr.seq}: hash chain broken`);
    }

    // 2. 验证当前哈希计算
    const expectedHash = sha256(
      `${curr.previous_hash}|${curr.nr_value}|${curr.delta}|${curr.timestamp}`
    );
    if (curr.current_hash !== expectedHash) {
      violations.push(`seq ${curr.seq}: invalid hash`);
    }

    // 3. 验证 NR 连续性
    if (curr.nr_value !== prev.nr_value + curr.delta) {
      violations.push(`seq ${curr.seq}: NR value mismatch (${curr.nr_value} != ${prev.nr_value} + ${curr.delta})`);
    }
  }

  return {
    chain_length: chain.length,
    current_nr: chain.length > 0 ? chain[chain.length - 1].nr_value : 0,
    is_valid: violations.length === 0,
    violations,
  };
}
```

---

## 9.3 第二层：状态锚定（渐进式）

### 9.3.1 三层锚定策略

```
Phase 1 (Week 1-2): GitHub Issues 锚定
  → 每日将 NR/CCR 快照哈希发布为 GitHub Issue
  → 零成本，公开可验证
  → 适用: MVP 阶段

Phase 2 (Week 5-6): IPFS 锚定
  → 每周将完整状态快照上传 IPFS，获取 CID
  → GitHub Issue 中记录 IPFS CID
  → 适用: 测试网阶段

Phase 3 (Week 8+): Arweave 锚定
  → 每月将状态快照永久存储至 Arweave
  → 不可篡改，永久保存
  → 适用: 生产阶段
```

### 9.3.2 锚定实现

```typescript
// 状态快照生成
async function generateStateSnapshot(genesisId?: string): Promise<StateSnapshot> {
  const snapshot: StateSnapshot = {
    version: 'v2.2',
    timestamp: Date.now(),
    merkle_root: '',
    segments: {
      nr_chains: genesisId
        ? db.all('SELECT * FROM nr_hash_chain WHERE ns_id IN (SELECT ns_id FROM genesis_members WHERE genesis_id = ?)', [genesisId])
        : db.all('SELECT * FROM nr_hash_chain ORDER BY ns_id, seq'),
      ccr_chains: genesisId
        ? db.all('SELECT * FROM ccr_hash_chain WHERE ns_id IN (SELECT ns_id FROM genesis_members WHERE genesis_id = ?)', [genesisId])
        : db.all('SELECT * FROM ccr_hash_chain ORDER BY ns_id, seq'),
      genesis_units: genesisId
        ? db.all('SELECT * FROM genesis_units WHERE genesis_id = ?', [genesisId])
        : db.all('SELECT * FROM genesis_units'),
    },
  };

  // 计算 Merkle Root
  snapshot.merkle_root = computeMerkleRoot(snapshot.segments);

  return snapshot;
}

// GitHub Issues 锚定
async function anchorToGitHub(snapshot: StateSnapshot): Promise<string> {
  const issueBody = `
## CONC State Snapshot — ${new Date(snapshot.timestamp).toISOString()}

**Version**: ${snapshot.version}
**Merkle Root**: \`${snapshot.merkle_root}\`
**NR Chains**: ${snapshot.segments.nr_chains.length} entries
**CCR Chains**: ${snapshot.segments.ccr_chains.length} entries
**Genesis Units**: ${snapshot.segments.genesis_units.length} active

### NR Summary
${snapshot.segments.nr_chains.map(c => `- \`${c.ns_id}\`: NR=${c.nr_value} (seq ${c.seq})`).join('\n')}

### CCR Summary
${snapshot.segments.ccr_chains.map(c => `- \`${c.ns_id}\`: CCR=${c.ccr_value} (seq ${c.seq})`).join('\n')}
`;

  // 通过 GitHub API 创建 Issue
  const response = await fetch(
    `https://api.github.com/repos/${process.env.CONC_ANCHOR_REPO}/issues`,
    {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${process.env.GITHUB_TOKEN}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        title: `CONC State Snapshot — ${new Date(snapshot.timestamp).toISOString().split('T')[0]}`,
        body: issueBody,
        labels: ['state-snapshot', 'auto-generated'],
      }),
    }
  );

  const issue = await response.json();
  return issue.html_url;
}

// IPFS 锚定
async function anchorToIPFS(snapshot: StateSnapshot): Promise<{ cid: string; url: string }> {
  const snapshotJson = JSON.stringify(snapshot);
  // 使用 iroh 或 ipfs-http-client 上传
  // const cid = await ipfs.add(snapshotJson);
  return { cid: 'Qm...', url: `https://ipfs.io/ipfs/Qm...` };
}
```

### 9.3.3 锚定日志表

```sql
-- 锚定日志表 (v2.2 新增)
CREATE TABLE anchor_log (
  anchor_id TEXT PRIMARY KEY,
  snapshot_merkle_root TEXT NOT NULL,
  anchor_type TEXT NOT NULL,             -- github_issue | ipfs | arweave
  anchor_ref TEXT NOT NULL,              -- GitHub Issue URL | IPFS CID | Arweave TxID
  snapshot_timestamp INTEGER NOT NULL,
  nr_chain_count INTEGER,
  ccr_chain_count INTEGER,
  genesis_count INTEGER,
  anchored_at INTEGER NOT NULL,
  verified_at INTEGER,
  verification_status TEXT DEFAULT 'pending' -- pending | verified | failed
);

CREATE INDEX idx_al_type ON anchor_log(anchor_type);
CREATE INDEX idx_al_timestamp ON anchor_log(snapshot_timestamp);
```

---

## 9.4 第三层：Skill/GHF 永久存储（Phase 2+）

```
Phase 2 规划:
  - Skill v2.0 数据 → IPFS (CID锚定)
  - GHF 完整历史 → Git 仓库 + IPFS 备份
  - 策元文档 → Git LFS + IPFS

Phase 3 规划:
  - 关键 Skill → Arweave 永久存储
  - 策元解散归档 → Filecoin 冷存储
```

---

# 第十篇：v2.2 新增 — 里程碑计划更新

## Chapter 10: Updated Milestone Plan (6-8 Weeks)

---

## 10.1 里程碑总览

v2.2 将 v1.0 的 16 周计划压缩为 6-8 周，聚焦 Track B MCP Server 方案的快速迭代。

```
Week 1    Week 2    Week 3    Week 4    Week 5    Week 6    Week 7    Week 8
  │         │         │         │         │         │         │         │
  ▼         ▼         ▼         ▼         ▼         ▼         ▼         ▼
Phase 0   Phase 1 ──────────  Phase 2   Phase 3   Phase 4   Phase 5 ──────────
Schema    安全修复              冷启动     工具精简   安全加固   Dogfooding
Migration AUTO限频              平台适配器 judgment_  增强P0    测试·文档
          女巫防御              创世任务令 request    工具      Release
          幂等性                IVD能证    同步版     P1标记
          防串谋(延迟)          名片                             生产就绪
```

---

## 10.2 Phase 0: Schema Migration（Week 1）

**目标**: 完成从 v1.0 到 v2.2 的数据库 Schema 升级。

| 任务 | 产出 | 验收标准 |
|------|------|---------|
| 新增 5 表创建 | workspaces, judgment_points, judgment_votes, auto_frequency_log, sybil_checks, idempotency_cache, nr_hash_chain, ccr_hash_chain, anchor_log, task_templates, ivd_profiles, state_transition_log | 所有表创建成功 |
| 修改 2 表 | peer_reviews (加 anonymized_until等列), noetic_sovereigns (加 sybil_risk_score) | ALTER TABLE 成功 |
| 数据迁移脚本 | v1.0 → v2.2 迁移 SQL | 现有数据无损迁移 |
| MCP Server 骨架 | 最小 MCP Server + 15 P0 Tool 骨架 | MCP Inspector 可连接 + 15 Tool 可列出 |

**交付物**:
- `migrations/v2.2_schema_upgrade.sql`
- `migrations/v2.2_data_migration.sql`
- `conc-mcp/` 骨架 (TypeScript)

---

## 10.3 Phase 1: 安全修复（Week 2-3）

**目标**: 实现四大安全修复，确保核心协议的安全基础。

| 任务 | 产出 | 验收标准 |
|------|------|---------|
| AUTO 频率限制 | auto_frequency_log + 递减收益矩阵 + 内容去重 | 同一内容 1h 内重复提交被拒绝 |
| 女巫基础防御 | sybil_checks 表 + GitHub API 检测 + 三层检测 + 降级路径 | sybil_risk_score 正确计算 |
| 状态机幂等性 | UNIQUE约束 + SQLite事务 + idempotency_cache | 相同幂等键重复调用返回缓存结果 |
| 防串谋协议 (Phase 4) | peer_reviews 匿名化字段 + 匿名窗口期 | 评审者提交前彼此不可见 |

**交付物**:
- `conc-mcp/src/engine/security-engine.ts`
- `conc-mcp/src/engine/auto-limiter.ts`
- `conc-mcp/src/engine/sybil-detector.ts`

---

## 10.4 Phase 2: 冷启动 + 平台适配器（Week 4）

**目标**: 解决冷启动困境，实现新用户零摩擦接入。

| 任务 | 产出 | 验收标准 |
|------|------|---------|
| 创世任务令自动触发 | onRegistration → CP_BOOTSTRAP → NR_SEED_PROJECT | 新注册自动获得探索策元 + 5 个引导任务 |
| task_templates 预置 | 10 个引导任务令模板 | 模板可查询并正确分配 |
| IVD 能证名片生成 | GitHub 数据 → 技能标签 + 热力图 + 方向向量 + NR种子 | 从真实 GitHub 账号正确生成技能标签 |
| 平台适配器 | PlatformAdapter 接口 + 4 个实现 (GitHub/GitLab/SO/手动) | 各平台数据可导入 |
| MCP Tool: conc_identity_import | 平台数据导入工具 | 数据导入并存储到 ivd_profiles |

**交付物**:
- `conc-mcp/src/engine/coldstart-engine.ts`
- `conc-mcp/src/adapters/github-adapter.ts`
- `conc-mcp/src/adapters/gitlab-adapter.ts`
- `conc-mcp/src/adapters/so-adapter.ts`
- `conc-mcp/src/adapters/manual-adapter.ts`

---

## 10.5 Phase 3: 工具精简 + judgment_request 同步版（Week 5）

**目标**: 完成 15 P0 工具实现，P1 工具标记 experimental。

| 任务 | 产出 | 验收标准 |
|------|------|---------|
| 15 P0 Tools 完整实现 | identity(2) + seed(2) + genesis(2) + task(4) + self_review + from_template + event_poll + judgment(2) | 全部工具在 MCP Inspector 可调用且返回正确结果 |
| judgment_request 同步版 | 决断点创建 + 介入级别判定 + 投票分配 | 决断流程端到端可走通 |
| 工具合并 | list+detail+join → genesis_detail, list+my+dag → task_list, list+match → seed_list | 合并后工具功能完整 |
| P1 工具标记 | 14 个工具标记 `experimental: true` | experimental 工具在非 dev 模式不可见 |

**交付物**:
- `conc-mcp/src/tools/` (15 个 P0 Tool 实现)
- `conc-mcp/src/engine/phronesis-engine.ts`

---

## 10.6 Phase 4: 安全加固 + 增强 P0 工具（Week 6）

**目标**: 安全加固和 P0 工具的边界情况覆盖。

| 任务 | 产出 | 验收标准 |
|------|------|---------|
| 防串谋提交时检测 | 评分标准差检测 + 串谋标记 | 串谋模式被正确检测 |
| 哈希链验证工具 | verifyNRChain + verifyCCRChain | 哈希链可验证且检测篡改 |
| GitHub Issues 锚定 | 每日自动快照 + Issue 创建 | Anchor Issue 正确生成 |
| P0 Tool 边界测试 | 错误输入、并发、超时、网络故障 | 100% 边界覆盖 |
| self_review 工具 | 自检清单 + AUTO 检查 + 报告生成 | 自检完成后生成检查报告 |
| from_template 工具 | 统一模板入口 + task/doc/genesis | 三种模板类型均可创建 |

**交付物**:
- `conc-mcp/src/engine/collusion-detector.ts`
- `conc-mcp/src/engine/chain-verifier.ts`
- `conc-mcp/src/engine/anchor-service.ts`
- `conc-mcp/tests/` (边界测试套件)

---

## 10.7 Phase 5: Dogfooding + 测试 + 文档（Week 7-8）

**目标**: 内部 Dogfooding、端到端测试、用户文档和 Release。

| 任务 | 产出 | 验收标准 |
|------|------|---------|
| Dogfooding | 3+ 内部用户完整体验 | 3 个用户完成 seed→genesis→task→peer→judgment 全流程 |
| 端到端测试 | E2E 测试套件 | 覆盖 15 P0 Tools 的全部工作流 |
| IPFS 锚定 | IPFS 上传 + CID 记录 | 状态快照上传 IPFS 成功 |
| 用户文档 | 快速入门 + API 参考 + 故障排除 | 新用户 15 分钟内完成首次协作 |
| Release v2.2.0 | npm 包 + changelog + migration guide | 可被 OpenClaw/Hermes 安装和加载 |

**交付物**:
- `conc-mcp/` npm 包 v2.2.0
- `docs/quickstart.md`
- `docs/api-reference.md`
- `docs/migration-v1-to-v2.md`
- `CHANGELOG.md`

---

## 10.8 Phase 6: v2.6/v2.7 理论同步（v3.2 新增，Week 9-10）

**目标**: 将 CONC 框架 v2.6/v2.7 的理论更新（物理前置层、被动群体 Skill 增值、U28/U29 新变量）工程化落地。

| 任务 | 产出 | 验收标准 |
|------|------|---------|
| 物理基础设施复用协议 | factories + factory_modules + factory_tenancy 三表 + 工厂生命周期状态机 | 工厂可创建、租用、模块重组 |
| 被动群体 Skill 增值管道 | passive_group_cu + passive_group_seed_genesis + 基础 Skill 培训接口 | 被动群体成员获得 CU 倾斜 + 种子策元保护期 |
| 被动群体迁移追踪仪表盘 | passive_group_migration_tracks + U29 仪表盘 | F_active/F_passive 可追踪，切换率可计算 |
| 厂商锁定检测 | vendor_lock_assessments + CSIP 标准化检测 | 三方锁定力可量化，CSIP 合规率可追踪 |
| 时间对齐检测 | 时区重叠率 + 异步协作成熟度引擎 | 低重叠+低成熟度策元被标记高风险 |
| Schema 迁移 v3.2 | migrations/v3.2_schema_upgrade.sql | 7 张新表创建成功，现有数据无损 |

**交付物**:
- `conc-mcp/src/engine/physical-infra-engine.ts`
- `conc-mcp/src/engine/passive-pipeline.ts`
- `conc-mcp/src/engine/vendor-lock-detector.ts`
- `conc-mcp/src/engine/async-collab-detector.ts`
- `migrations/v3.2_schema_upgrade.sql`

---

# 附录 A：v1.0 → v2.2 迁移指南

## A.1 数据库迁移

```sql
-- ============================================
-- CONC Schema v1.0 → v2.2 迁移脚本
-- ============================================

-- Phase 1: 新增表 (12 个)
-- 工作区
CREATE TABLE IF NOT EXISTS workspaces (
  workspace_id TEXT PRIMARY KEY,
  genesis_id TEXT NOT NULL,
  workspace_type TEXT DEFAULT 'main',
  title TEXT,
  description TEXT,
  status TEXT DEFAULT 'active',
  git_branch TEXT,
  created_by_ns_id TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  FOREIGN KEY (genesis_id) REFERENCES genesis_units(genesis_id)
);

-- 决断点
CREATE TABLE IF NOT EXISTS judgment_points (
  jp_id TEXT PRIMARY KEY,
  genesis_id TEXT NOT NULL,
  trigger_type TEXT NOT NULL,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  options_json TEXT NOT NULL,
  intervention_level INTEGER DEFAULT 1,
  status TEXT DEFAULT 'pending',
  deadline INTEGER,
  resolved_option_id TEXT,
  created_by_ns_id TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  resolved_at INTEGER,
  FOREIGN KEY (genesis_id) REFERENCES genesis_units(genesis_id)
);

-- 决断投票
CREATE TABLE IF NOT EXISTS judgment_votes (
  vote_id TEXT PRIMARY KEY,
  jp_id TEXT NOT NULL,
  voter_ns_id TEXT NOT NULL,
  option_id TEXT NOT NULL,
  rationale TEXT,
  voted_at INTEGER NOT NULL,
  FOREIGN KEY (jp_id) REFERENCES judgment_points(jp_id),
  UNIQUE(jp_id, voter_ns_id)
);

-- AUTO 频率日志
CREATE TABLE IF NOT EXISTS auto_frequency_log (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  ns_id TEXT NOT NULL,
  genesis_id TEXT NOT NULL,
  action_type TEXT NOT NULL,
  content_hash TEXT NOT NULL,
  timestamp INTEGER NOT NULL,
  result TEXT
);

-- 女巫检测
CREATE TABLE IF NOT EXISTS sybil_checks (
  check_id TEXT PRIMARY KEY,
  ns_id TEXT NOT NULL,
  check_type TEXT NOT NULL,
  check_result TEXT NOT NULL,
  risk_score REAL DEFAULT 0,
  evidence_json TEXT,
  checked_at INTEGER NOT NULL,
  expires_at INTEGER
);

-- 幂等性缓存
CREATE TABLE IF NOT EXISTS idempotency_cache (
  idempotency_key TEXT PRIMARY KEY,
  status TEXT NOT NULL DEFAULT 'in_progress',
  result_json TEXT,
  error_msg TEXT,
  created_at INTEGER NOT NULL,
  completed_at INTEGER
);

-- NR 哈希链
CREATE TABLE IF NOT EXISTS nr_hash_chain (
  chain_id TEXT PRIMARY KEY,
  ns_id TEXT NOT NULL,
  seq INTEGER NOT NULL,
  nr_value REAL NOT NULL,
  delta REAL NOT NULL,
  delta_reason TEXT NOT NULL,
  previous_hash TEXT NOT NULL,
  current_hash TEXT NOT NULL,
  related_entity_id TEXT,
  timestamp INTEGER NOT NULL,
  signature TEXT NOT NULL
);

-- CCR 哈希链
CREATE TABLE IF NOT EXISTS ccr_hash_chain (
  chain_id TEXT PRIMARY KEY,
  ns_id TEXT NOT NULL,
  seq INTEGER NOT NULL,
  ccr_value REAL NOT NULL,
  vt_contributed REAL NOT NULL,
  cu_consumed REAL NOT NULL,
  delta_reason TEXT NOT NULL,
  previous_hash TEXT NOT NULL,
  current_hash TEXT NOT NULL,
  period_start INTEGER NOT NULL,
  period_end INTEGER NOT NULL,
  timestamp INTEGER NOT NULL,
  signature TEXT NOT NULL
);

-- 锚定日志
CREATE TABLE IF NOT EXISTS anchor_log (
  anchor_id TEXT PRIMARY KEY,
  snapshot_merkle_root TEXT NOT NULL,
  anchor_type TEXT NOT NULL,
  anchor_ref TEXT NOT NULL,
  snapshot_timestamp INTEGER NOT NULL,
  nr_chain_count INTEGER,
  ccr_chain_count INTEGER,
  genesis_count INTEGER,
  anchored_at INTEGER NOT NULL,
  verified_at INTEGER,
  verification_status TEXT DEFAULT 'pending'
);

-- 任务令模板
CREATE TABLE IF NOT EXISTS task_templates (
  template_id TEXT PRIMARY KEY,
  category TEXT NOT NULL,
  title TEXT NOT NULL,
  human_objective TEXT NOT NULL,
  agent_prompt TEXT,
  verification_mode TEXT DEFAULT 'auto',
  estimated_hours REAL DEFAULT 2,
  required_skills TEXT,
  direction_tags TEXT,
  sort_order INTEGER DEFAULT 0,
  is_active INTEGER DEFAULT 1
);

-- IVD 能证
CREATE TABLE IF NOT EXISTS ivd_profiles (
  ns_id TEXT PRIMARY KEY,
  github_username TEXT,
  gitlab_username TEXT,
  stackoverflow_id TEXT,
  inferred_skills_json TEXT,
  direction_vector FLOAT[5],
  activity_heatmap_json TEXT,
  nr_seed_score REAL DEFAULT 0,
  cold_start_progress REAL DEFAULT 0,
  generated_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);

-- 状态跃迁日志
CREATE TABLE IF NOT EXISTS state_transition_log (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  task_id TEXT NOT NULL,
  from_status TEXT NOT NULL,
  to_status TEXT NOT NULL,
  trigger_event TEXT NOT NULL,
  context_json TEXT,
  timestamp INTEGER NOT NULL
);

-- Phase 2: 修改现有表
-- peer_reviews 增加匿名化字段
ALTER TABLE peer_reviews ADD COLUMN anonymized_until INTEGER;
ALTER TABLE peer_reviews ADD COLUMN revealed_at INTEGER;
ALTER TABLE peer_reviews ADD COLUMN reviewer_pool_size INTEGER DEFAULT 3;
ALTER TABLE peer_reviews ADD COLUMN consensus_threshold REAL DEFAULT 0.3;

-- noetic_sovereigns 增加女巫风险评分
ALTER TABLE noetic_sovereigns ADD COLUMN sybil_risk_score REAL DEFAULT 0;

-- Phase 3: 创建索引
CREATE INDEX IF NOT EXISTS idx_workspaces_genesis ON workspaces(genesis_id);
CREATE INDEX IF NOT EXISTS idx_jp_genesis ON judgment_points(genesis_id);
CREATE INDEX IF NOT EXISTS idx_jp_status ON judgment_points(status);
CREATE INDEX IF NOT EXISTS idx_jv_jp ON judgment_votes(jp_id);
CREATE INDEX IF NOT EXISTS idx_afl_ns_ts ON auto_frequency_log(ns_id, timestamp);
CREATE INDEX IF NOT EXISTS idx_afl_content ON auto_frequency_log(content_hash);
CREATE INDEX IF NOT EXISTS idx_sc_ns ON sybil_checks(ns_id);
CREATE INDEX IF NOT EXISTS idx_sc_result ON sybil_checks(check_result);
CREATE INDEX IF NOT EXISTS idx_nhc_ns ON nr_hash_chain(ns_id, seq);
CREATE INDEX IF NOT EXISTS idx_nhc_hash ON nr_hash_chain(current_hash);
CREATE INDEX IF NOT EXISTS idx_chc_ns ON ccr_hash_chain(ns_id, seq);
CREATE INDEX IF NOT EXISTS idx_chc_hash ON ccr_hash_chain(current_hash);
CREATE INDEX IF NOT EXISTS idx_al_type ON anchor_log(anchor_type);
CREATE INDEX IF NOT EXISTS idx_al_timestamp ON anchor_log(snapshot_timestamp);
CREATE INDEX IF NOT EXISTS idx_ivp_github ON ivd_profiles(github_username);
CREATE UNIQUE INDEX IF NOT EXISTS idx_stl_unique ON state_transition_log(task_id, from_status, to_status, trigger_event);
CREATE INDEX IF NOT EXISTS idx_stl_task ON state_transition_log(task_id);

-- Phase 4: 预置数据
-- task_templates 预置 10 个引导任务令
-- (参见 7.2.2 节)
```

## A.2 工具迁移对照

| v1.0 工具 (29个) | v2.2 对应 (15 P0 + P1) |
|------------------|------------------------|
| `conc_seed_create` | → `conc_seed_create` (P0) |
| `conc_seed_list` | → `conc_seed_list` (P0, 合并 icp_match) |
| `conc_icp_match` | → `conc_seed_list` (合并) |
| `conc_genesis_create` | → `conc_genesis_create` (P0) |
| `conc_genesis_join` | → `conc_genesis_detail` (合并) |
| `conc_genesis_list` | → `conc_genesis_detail` (合并) |
| `conc_genesis_detail` | → `conc_genesis_detail` (P0, 增强) |
| `conc_genesis_dissolve` | → P1 (experimental) |
| `conc_task_create` | → `conc_task_create` (P0) |
| `conc_task_claim` | → `conc_task_claim` (P0) |
| `conc_task_submit` | → `conc_task_submit` (P0) |
| `conc_task_list` | → `conc_task_list` (P0, 合并 my/dag) |
| `conc_task_my` | → `conc_task_list` (合并) |
| `conc_task_dag` | → `conc_task_list` (合并) |
| `conc_peer_submit` | → P1 (experimental) |
| `conc_peer_stats` | → P1 (experimental) |
| `conc_ccr_show` | → P1 (experimental) |
| `conc_ccr_records` | → P1 (experimental) |
| `conc_network_status` | → P1 (experimental) |
| `conc_identity_register` | → `conc_identity_register` (P0) |
| `conc_identity_show` | → `conc_identity_show` (P0) |
| `conc_doc_create` | → P1 (experimental) |
| `conc_doc_submit` | → P1 (experimental) |
| `conc_doc_review` | → P1 (experimental) |
| `conc_doc_publish` | → P1 (experimental) |
| `conc_doc_archive` | → P1 (experimental) |
| `conc_doc_detail` | → P1 (experimental) |
| `conc_doc_list` | → P1 (experimental) |
| `conc_ghf_timeline` | → P1 (experimental) |
| `conc_pcp_ratify` | → P1 (experimental) |
| `conc_skill_v2_create` | → P1 (experimental) |
| `conc_skill_v2_fork` | → P1 (experimental) |
| `conc_skill_v2_detail` | → P1 (experimental) |
| `conc_skill_v2_search` | → P1 (experimental) |
| `conc_direction_profile` | → P1 (experimental) |
| `conc_judgment_credit` | → P1 (experimental) |
| `conc_judgment_record` | → P1 (experimental) |
| — | → `conc_self_review` (P0, 新增) |
| — | → `conc_from_template` (P0, 新增) |
| — | → `conc_event_poll` (P0, 新增) |
| — | → `conc_judgment_request` (P0, 新增) |
| — | → `conc_judgment_vote` (P0, 新增) |
| — | → `conc_identity_import` (P0, 新增) |

---

## 附录 B：v2.2 新增 SQLite 表一览

| 表名 | 用途 | 所属层 | v2.2 操作 |
|------|------|--------|----------|
| `workspaces` | 工作区管理 | 协作层 | 新增 |
| `judgment_points` | 决断点记录 | 决断层 | 新增 |
| `judgment_votes` | 决断投票 | 决断层 | 新增 |
| `auto_frequency_log` | AUTO 频率日志 | 安全引擎 | 新增 |
| `sybil_checks` | 女巫检测 | 安全引擎 | 新增 |
| `idempotency_cache` | 幂等性缓存 | 安全引擎 | 新增 |
| `state_transition_log` | 状态跃迁日志 | 安全引擎 | 新增 |
| `nr_hash_chain` | NR 哈希链 | 数据持久性 | 新增 |
| `ccr_hash_chain` | CCR 哈希链 | 数据持久性 | 新增 |
| `anchor_log` | 锚定日志 | 数据持久性 | 新增 |
| `task_templates` | 任务令模板 | 冷启动 | 新增 |
| `ivd_profiles` | IVD 能证 | 冷启动 | 新增 |
| `peer_reviews` | PEER 评审 (升级) | 验证层 | 修改 (+4列) |
| `noetic_sovereigns` | 智权体 (升级) | 身份层 | 修改 (+1列) |

### v3.2 新增（v2.6/v2.7 同步）：

| 表名 | 用途 | 所属层 | v3.2 操作 |
|------|------|--------|:---------:|
| `factories` | 工厂复用 | 物理基础设施层 | 新增 |
| `factory_modules` | 工厂功能模块 | 物理基础设施层 | 新增 |
| `factory_tenancy` | 工厂租用记录 | 物理基础设施层 | 新增 |
| `vendor_lock_assessments` | 厂商锁定检测 | 安全引擎 | 新增 |
| `passive_group_seed_genesis` | 被动群体种子策元 | 冷启动 | 新增 |
| `passive_group_migration_tracks` | 被动群体迁移追踪 | 冷启动 | 新增 |
| `passive_group_cu` | 被动群体 CU 倾斜分配 | 冷启动 | 新增 |

v1.0 原有 8 张核心表、v2.2 新增 12 张表+修改 2 张表，v3.2 新增 7 张表，合计 **27 张表**。

---

## 附录 C：关键配置参数速查

| 参数 | 默认值 | 说明 |
|------|:------:|------|
| `AUTO_VERIFY_WINDOW_SECONDS` | 3600 | AUTO 验证频率窗口 |
| `AUTO_VERIFY_BASE_QUOTA` | 10 | 每小时 AUTO 基础配额 |
| `SYBIL_HIGH_RISK_THRESHOLD` | 0.7 | 女巫高风险阈值 |
| `COLLUSION_CONSENSUS_THRESHOLD` | 0.3 | 串谋检测标准差阈值 |
| `IDEMPOTENCY_TTL_SECONDS` | 300 | 幂等性缓存 TTL |
| `COLD_START_TASK_COUNT` | 5 | 冷启动引导任务数 |
| `NR_SEED_MAX_SCORE` | 500 | NR 种子最高分 |
| `ANCHOR_INTERVAL_DAYS` | 1 | 锚定间隔（天） |
| `PEER_ANONYMIZE_WINDOW_HOURS` | 72 | 匿名窗口期（小时） |
| `JUDGMENT_DEFAULT_DEADLINE_HOURS` | 72 | 决断默认截止时间 |
| `JUDGMENT_QUORUM_RATIO` | 0.5 | 决断法定人数比例 |
| `PASSIVE_GROUP_CU_TILT_FACTOR` | 1.5 | 被动群体 CU 倾斜系数 |
| `PASSIVE_GROUP_SWITCH_RATE_THRESHOLD` | 0.2 | 被动群体切换率预警阈值（<20%→U29） |
| `VENDOR_LOCK_CSIP_COMPLIANCE_WARN` | 0.3 | CSIP 合规率预警阈值（<30%→U28） |
| `OVERLAP_RATIO_WARN` | 0.3 | 时区重叠率预警阈值 |
| `ASYNC_MATURITY_WARN` | 0.5 | 异步协作成熟度预警阈值 |
| `FACTORY_VALUE_CYCLE_MIN` | 12 | 工厂最小价值周期（月） |

---

*CONC 工程化规范 v3.2 — 基于 v2.2 升级 + v2.6/v2.7 理论同步*
*文档标识: CONC-ENG-SPEC-003*
*生成时间: 2026-05-27（v2.2），升级 2026-07-12（v3.1），v2.7 同步 2026-08-08（v3.2）*
