# CONC 协作层协议规范
## Collaboration Layer Protocol Specification v2.0

> 协议标识符：`CONC-Protocol/Collaboration.2.0`
> **v2.0 升级摘要**: GHF 事件表新增 6 个事件类型 (PHJ/SPA/TWD/TDA/JRS/PSS) ——支持 Sophia↔Phronesis 运行时判定和 JC 四分量记录；DAG 拆解 API 扩展 phronesis_profile/decision_gates/suggested_assignee_profile 三字段。
> 依赖：公理四（模块承诺）、本原零（自利与秩序恒常）、SBDEL 定理、策元层协议 (01 v3.1)、PEER 验证协议 (05)、CCR 公开账本 (06)、NR 统一状态机 (17)、决断层协议 (19 v2.0)、JC 协议 (15 v2.0)
> 协议层归属：协作层 (Collaboration Layer) — 协议栈第四层
>
> **完备度声明**：本规范定义 CONC 协议栈第四层——协作层的完整协议规范（完备度 0% → 85%+）。覆盖策元工作区（Genesis Workspace）、文档生命周期（D1-D6）、Gate 门控系统（0-4）、GHF 审计链（Genesis History File）、策元事件总线（Event Bus）、协作 Skill 模板（Collaboration Skill Template）以及策元核编排 API（Genesis Core Orchestration API）。本协议是 CONC 从「个体任务令执行」走向「策元内结构化协作」的关键桥梁。

---

## 〇、协议定位与设计概要

### 0.1 在协议栈中的位置

CONC 协议栈的第四层——协作层——位于策元层（第三层）与验证层（第五层）之间：

```
┌─────────────────────────────────────────────────────────┐
│  应用层 (Application Layer)                      L6     │
├─────────────────────────────────────────────────────────┤
│  验证层 (Verification Layer)                     L5     │
│  PEER(n) · AUTO · MARKET · 争议仲裁                     │
├─────────────────────────────────────────────────────────┤
│  协作层 (Collaboration Layer)          ← 本协议  L4     │
│  工作区 · 文档生命周期 · Gate门控 · GHF审计 · 事件总线    │
├─────────────────────────────────────────────────────────┤
│  策元层 (Genesis Layer)                        L3      │
│  策元 CRUD · 成员管理 · PCP · 策元核轮值                  │
├─────────────────────────────────────────────────────────┤
│  身份层 (Identity Layer)                       L2      │
│  智权体注册 · NR · 能证 · 密钥管理                       │
├─────────────────────────────────────────────────────────┤
│  网络层 (Network Layer)                        L1      │
│  节点发现 · 广播 · 状态同步 · 断网缓存                    │
└─────────────────────────────────────────────────────────┘
```

策元层（L3）定义了「策元是什么」——创建、成员、PCP、策元核。协作层（L4）定义了「策元如何协作」——工作区内的文件协同、文档从草稿到归档的完整生命周期、质量门控、不可篡改的审计轨迹、以及策元核对协作流的编排。

### 0.2 理论溯源

本协议的三个核心设计原则来源于 CONC 的理论基础：

| 理论来源 | 核心主张 | 在本协议中的体现 |
|----------|---------|-----------------|
| **公理四（模块承诺）** | 每个模块的产出必须有明确的完成定义和可验证的交付标准 | Gate 门控系统：每个 Gate 对应一个明确的「完成定义」，必须通过才能进入下一阶段 |
| **本原零（自利与秩序恒常）** | 理性参与者在充分信息下会选择遵守协议——前提是协议提供比作弊更高的净收益 | GHF 审计链：所有协作事件不可篡改地记录，作弊的期望成本（声誉损失 + 燃烧惩罚）超过收益 |
| **SBDEL 定理** | 在信息不对称环境中，「信号-行为-检测-执行-学习」闭环是维持合作均衡的充要条件 | 事件总线 + GHF：信号（事件发布）→ 行为（策元核编排）→ 检测（Gate 验证）→ 执行（状态转换）→ 学习（Skill 模板迭代） |

### 0.3 协议设计目标

1. **可追溯性 (Traceability)**：策元内每一次文件变更、每一次状态转换、每一次门控判断，都有不可篡改的审计轨迹。第三方可独立验证「谁在什么时候做了什么」。
2. **质量门控 (Quality Gating)**：通过 Gate 0-4 定义策元从创建到归档的全生命周期质量检查点。每个 Gate 是明确的、可自动验证的。
3. **冲突预防 (Conflict Prevention)**：通过文件锁定和 CRDT 同步机制，防止多人并发编辑同一文件导致的数据丢失。
4. **编排自动化 (Orchestration)**：策元核通过编排 API 自动拆解任务令 DAG、触发三阶段分配、管理工程变更控制 (ECC)。

---

## 一、策元工作区 (Genesis Workspace)

### 1.1 工作区定义

**策元工作区**（Genesis Workspace）是每个策元在创建时自动建立的协作文件系统，由 Git 仓库 + 结构化文件树组成。它是策元所有产出物的唯一权威存储（Source of Truth）。

```
workspace/{genesis_id}/
├── .conc/
│   ├── workspace.toml          # 工作区配置
│   ├── ghf/                    # GHF 审计链（§四）
│   │   ├── chain.dat           # 哈希链数据
│   │   └── index               # 事件索引
│   ├── locks/                  # 文件锁目录
│   ├── gate_records/           # Gate 判定记录
│   └── skill_templates/        # 本策元协作 Skill 模板缓存
├── docs/                       # 文档产出物
│   ├── design/                 # 设计文档
│   ├── specs/                  # 技术规格
│   └── decisions/              # 架构决策记录 (ADR)
├── src/                        # 源代码（按需组织）
├── deliverables/               # 正式交付物（D4+ 阶段）
└── archive/                    # 归档产出物（D5+ 阶段）
```

### 1.2 工作区配置 (workspace.toml)

```toml
[workspace]
genesis_id = "gu_x9y8z7w6"
created_at = "2026-05-27T00:00:00Z"
version = "1.0"

[workspace.sync]
mode = "git_crdt"               # Git 作为基础传输，CRDT 用于实时协同
remote_origin = "conc://gu_x9y8z7w6/workspace"
auto_push_interval_seconds = 30
conflict_resolution = "lww"     # Last-Writer-Wins for CRDT

[workspace.locks]
default_lock_ttl_seconds = 3600 # 默认锁 1 小时
max_lock_ttl_seconds = 86400    # 最大锁 24 小时
auto_renew_enabled = true

[workspace.documents]
lifecycle_schema = "D1-D6"      # 文档生命周期模型（§二）
default_state = "D1"
required_reviewers_for_D4 = 2   # D3→D4 至少需 2 位评审者

[workspace.gates]
enabled = true
gate_sequence = ["G0", "G1", "G2", "G3", "G4"]
require_full_consensus = false  # 单 Gate 不通过即阻断，不要求全部一致
```

### 1.3 文件锁定机制

防止并发冲突的核心机制。基于租约（Lease）模型——锁有 TTL，过期自动释放。

**锁数据模型**：

```json
{
  "lock_id": "lock_a1b2c3d4",
  "file_path": "docs/design/architecture.md",
  "holder_ns_id": "ns_0a1b2c3d",
  "acquired_at": "2026-05-27T10:30:00Z",
  "expires_at": "2026-05-27T11:30:00Z",
  "lock_type": "write",
  "intent": "Editing §3.2 - Data Flow Diagram",
  "auto_renew": true
}
```

**锁协议**：

```
获取锁：POST /workspace/{gu_id}/lock/acquire
  Request:  { "file_path": "...", "lock_type": "read"|"write", "intent": "...", "ttl_seconds": 3600 }
  Response: { "lock_id": "lock_...", "expires_at": "..." }
  错误:     409 LOCK_CONFLICT — 文件已被他人锁定
            423 FILE_LOCKED — 文件处于写锁保护

续期锁：POST /workspace/{gu_id}/lock/{lock_id}/renew
  Response: { "expires_at": "...", "renewed": true }
  注意:     客户端应在 expires_at 前 5 分钟发起续期。auto_renew=true 时由协议层自动续期。

释放锁：POST /workspace/{gu_id}/lock/{lock_id}/release
  Response: { "released": true }
  强制释放: 仅锁持有者或策元核可释放。策元核强制释放需记录 GHF 事件。
```

**锁冲突处理策略**：

| 场景 | 现有锁类型 | 请求锁类型 | 结果 |
|------|:---:|:---:|------|
| 无锁 | — | read / write | 立即授予 |
| 已有读锁 | read | read | 授予（多个读锁可共存） |
| 已有读锁 | read | write | 409 — 拒绝写入，建议等待 |
| 已有写锁 | write | read / write | 423 — 完全拒绝 |

### 1.4 产出物同步（Git + CRDT）

协作层使用双层同步架构：

- **Git 层**：文件级版本控制。每次 Gate 通过时自动创建带注释的 Git tag。`git push` 到策元内部远程仓库。
- **CRDT 层**：实时协同编辑。对于可拆分文档（如 Markdown、代码），使用 CRDT（Conflict-free Replicated Data Type）在策元成员间实时同步。冲突解决策略为 LWW (Last-Writer-Wins)，以系统时钟为准。

**同步事件**：

```
事件: WORKSPACE_SYNC_START — 同步周期开始
事件: WORKSPACE_SYNC_CONFLICT — 检测到冲突（通过 Git merge 或 CRDT 向量时钟分歧）
事件: WORKSPACE_SYNC_COMPLETE — 同步完成，包含变更摘要
```

所有同步事件写入 GHF（§四）。

### 1.5 工作区 API

```
GET  /workspace/{gu_id}/tree
  Response: { "root": "...", "files": [...], "last_commit": "abc123", "last_synced": "..." }
  // 获取工作区文件树

POST /workspace/{gu_id}/file/write
  Request:  { "file_path": "...", "content_base64": "...", "lock_id": "lock_...", "message": "..." }
  Response: { "commit_hash": "abc123", "synced": true }
  // 写入文件。需持有对应文件的写锁。自动创建 commit。

GET  /workspace/{gu_id}/file/read
  Request:  { "file_path": "...", "version": "latest"|"abc123" }
  Response: { "content_base64": "...", "hash": "sha256:...", "last_modified_by": "ns_...", "state": "D3" }
  // 读取文件。可指定版本（Git commit hash）。

GET  /workspace/{gu_id}/log
  Response: { "commits": [...], "page_token": "..." }
  // 获取工作区变更日志（Git log）
```

---

## 二、文档生命周期 (Document Lifecycle D1-D6)

### 2.1 生命周期模型

每个策元工作区内的文档（设计文档、技术规格、ADR、代码模块）遵循六阶段生命周期：

```
D1 草稿 (Draft)          →  创建中，内容不完整，仅作者可编辑
D2 评审中 (In Review)     →  提交评审，评审者可在指定区域批注
D3 修改中 (Revising)      →  根据评审意见修改，评审者可跟踪修改状态
D4 已发布 (Published)     →  评审通过并正式发布，内容冻结（需 ECC 修改）
D5 归档 (Archived)        →  不再活跃使用，保留为历史参考
D6 废弃 (Deprecated)      →  明确不再适用，标记替代文档引用
```

### 2.2 状态转换规则

```
                    ┌──────┐
                    │  D1  │  草稿
                    └──┬───┘
                       │ submit_for_review
                       ▼
              ┌────────────────┐
              │      D2        │  评审中
              └───────┬────────┘
                      │
          ┌───────────┼───────────┐
          │ request   │ approve   │
          │ changes   │           │
          ▼           ▼           │
      ┌───────┐  ┌────────┐      │
      │  D3   │  │   D4   │      │
      │ 修改中│  │ 已发布  │◄─────┘
      └───┬───┘  └───┬────┘
          │           │
          │ resubmit  │ archive
          │           ▼
          │      ┌────────┐
          └─────►│   D5   │  归档
                 └───┬────┘
                     │ deprecate
                     ▼
                 ┌────────┐
                 │   D6   │  废弃
                 └────────┘
```

### 2.3 状态转换条件与权限

| 转换 | 触发者 | 前置条件 | 后置行为 | API |
|------|--------|---------|---------|-----|
| **D1→D2** | 文档作者 | 文档满足最低完成度（非空、结构完整） | 通知策元评审者池；创建评审会话 | `POST /doc/{doc_id}/submit` |
| **D2→D3** | 评审者（任一） | 评审者提交 `request_changes` 并附修改意见 | 通知作者；记录评审意见至 GHF | `POST /doc/{doc_id}/review` |
| **D2→D4** | 评审者（≥2 且全票同意） | 所有指定评审者提交 `approve` | 内容冻结；生成不可变副本；Gate 2 可能触发 | `POST /doc/{doc_id}/review` |
| **D3→D2** | 文档作者 | 作者完成修改并请求重审 | 通知原评审者；重新分配评审（如原评审者不可用） | `POST /doc/{doc_id}/resubmit` |
| **D4→D5** | 策元核或文档作者 | Gate 3 通过（发布门控）满 90 天后；无活跃引用 | 移至 archive/ 目录；保留只读访问 | `POST /doc/{doc_id}/archive` |
| **D5→D6** | 策元核 | 替代文档已发布（D4+）；本策元 2/3 成员同意废弃 | 标记废弃水印；记录替代文档引用 | `POST /doc/{doc_id}/deprecate` |

### 2.4 文档评审模型

文档评审采用简化版 PEER 模型——不涉及 VT 分配或 NR 更新，专注于内容质量反馈：

| 维度 | PEER 任务令评审 | 文档评审 (D2) |
|------|:---:|:---:|
| 评审者数量 | 3-5 | 1-2（指定或自选） |
| 评分维度 | 完成度/质量/接口合规/时效 | 内容正确性/结构清晰度/可执行性 |
| 审计 | 10% 例行 + 低置信度触发 | 不触发（无 VT 利害） |
| 争议升级 | PEER(3)→PEER(5)→全体评审 | 作者与评审者直接协商，无法达成一致时由策元核裁决 |
| 结果 | pass/fail + 评分 | approve/request_changes |

### 2.5 文档状态数据模型

```json
{
  "document_id": "doc_a1b2c3d4",
  "genesis_id": "gu_x9y8z7w6",
  "file_path": "docs/design/architecture.md",
  "title": "系统架构设计 v2.1",
  "state": "D2",
  "state_history": [
    { "from": "D1", "to": "D2", "at": "2026-05-27T10:00:00Z", "by": "ns_0a1b2c3d", "reason": "submit_for_review" }
  ],
  "author_ns_id": "ns_0a1b2c3d",
  "created_at": "2026-05-20T00:00:00Z",
  "last_modified_at": "2026-05-27T09:55:00Z",
  "reviewers": ["ns_4d5e6f7g"],
  "reviews": [
    {
      "reviewer_ns_id": "ns_4d5e6f7g",
      "decision": "approved",
      "comments_hash": "sha256:...",
      "submitted_at": "2026-05-27T14:00:00Z"
    }
  ],
  "published_version_hash": null,
  "superseded_by": null,
  "deprecation_notice": null
}
```

### 2.6 文档生命周期 API

```
POST /workspace/{gu_id}/doc/create
  Request:  { "file_path": "...", "title": "...", "content_base64": "..." }
  Response: { "document_id": "doc_...", "state": "D1", "created_at": "..." }
  // 创建新文档。自动进入 D1 草稿状态。

POST /workspace/{gu_id}/doc/{doc_id}/submit
  Request:  { "reviewer_ns_ids": ["ns_..."] }   // 可指定评审者，也可留空由系统分配
  Response: { "state": "D2", "review_session_id": "rev_..." }
  // D1→D2。提交评审。

POST /workspace/{gu_id}/doc/{doc_id}/review
  Request:  { "decision": "approved"|"request_changes", "comments_hash": "sha256:...", "line_comments": [...] }
  Response: { "state": "D4"|"D3", "all_reviews_complete": true|false }
  // 提交评审意见。D2→D3 或 D2→D4。

POST /workspace/{gu_id}/doc/{doc_id}/resubmit
  Request:  { "change_summary_hash": "sha256:..." }
  Response: { "state": "D2" }
  // D3→D2。修改完成，提交重审。

POST /workspace/{gu_id}/doc/{doc_id}/archive
  Request:  { "reason": "..." }
  Response: { "state": "D5", "archived_at": "..." }
  // D4→D5。归档。

POST /workspace/{gu_id}/doc/{doc_id}/deprecate
  Request:  { "superseded_by_doc_id": "doc_...", "reason": "..." }
  Response: { "state": "D6", "deprecated_at": "..." }
  // D5→D6。废弃。

GET  /workspace/{gu_id}/doc/{doc_id}/state
  Response: { "document_id": "doc_...", "state": "D2", "state_history": [...], "reviews": [...] }
  // 查询文档状态与评审历史。
```

---

## 三、Gate 门控系统 (Gate 0–4)

### 3.1 门控设计哲学

Gate（门控）是协作层对公理四「模块承诺」的直接实现。每个 Gate 对应策元生命周期中的一个明确的质量检查点。Gate 不是建议——是**阻断条件**：Gate 未通过，策元不能进入下一阶段。

五个 Gate 按时间顺序串联：

```
策元创建 ──→ [G0] ──→ 设计阶段 ──→ [G1] ──→ 实现阶段 ──→ [G2] ──→ 发布阶段 ──→ [G3] ──→ [G4] 归档
```

### 3.2 Gate 0：策元创建门控 (Genesis Creation Gate)

| 属性 | 值 |
|------|---|
| **触发时机** | `POST /genesis/create` 调用时 |
| **检查项** | PCP 签署完成（所有创始成员已签名）<br>意图聚结达成（sim ≥ θ）<br>创始成员 ≥ 2 且身份均已锚定<br>创意种子（creative_seed）描述哈希非空 |
| **通过条件** | 所有检查项通过 |
| **不通过行为** | 402 `GATE_0_FAILED` — 创建请求被拒绝。返回失败原因列表。 |
| **通过后行为** | 策元节点创建；工作区自动初始化；G0 通过事件写入 GHF |

**Gate 0 验证逻辑**：

```
function verify_G0(create_request):
    failures := []

    if not all_members_signed_pcp(create_request.pcp_hash, create_request.initial_members):
        failures.append("PCP_NOT_FULLY_SIGNED")

    if create_request.intent_coalescence_sim < create_request.theta_similarity:
        failures.append("INTENT_COALESCENCE_NOT_MET")

    if len(create_request.initial_members) < 2:
        failures.append("INSUFFICIENT_FOUNDING_MEMBERS")

    for ns in create_request.initial_members:
        if not is_identity_anchored(ns):
            failures.append(f"MEMBER_NOT_ANCHORED:{ns}")

    if is_empty(create_request.creative_seed.description_hash):
        failures.append("CREATIVE_SEED_EMPTY")

    if failures:
        return (false, failures)

    return (true, [])
```

### 3.3 Gate 1：设计确认门控 (Design Confirmation Gate)

| 属性 | 值 |
|------|---|
| **触发时机** | 策元核声明设计阶段完成，或所有标记为 `required_for_gate1` 的文档进入 D4 状态 |
| **检查项** | 方向档案一致性检查（当前工作区产出方向 vs 创建时的 direction_vector 余弦相似度 ≥ θ_similarity）<br>所有必需设计文档处于 D4（已发布）状态<br>架构决策记录（ADR）覆盖所有关键设计决策<br>无未解决的设计评审 `request_changes` |
| **通过条件** | 所有检查项通过 |
| **不通过行为** | 402 `GATE_1_FAILED` — 方向偏离或设计文档不完整。返回具体偏离点。 |
| **通过后行为** | 策元状态从 `forming` 进入 `executing`；实现阶段可开始；G1 通过事件写入 GHF |

**方向档案一致性检查**（公理四核心实现）：

```
function verify_direction_consistency(gu_id):
    current_direction := compute_aggregate_direction(workspace_documents(gu_id))
    creation_direction := get_creation_direction_vector(gu_id)
    sim := cosine_similarity(current_direction, creation_direction)

    if sim < theta_similarity(gu_id):
        return (false, sim, "方向偏离超过阈值。建议：发起 PCP 修正更新 θ，或重新校准方向。")

    return (true, sim, "")
```

### 3.4 Gate 2：实现完成门控 (Implementation Completion Gate)

| 属性 | 值 |
|------|---|
| **触发时机** | 策元核声明实现阶段完成 |
| **检查项** | 策元内所有任务令状态为 `MERGED_RESOLVED` 或 `CLOSED`<br>AUTO 类型任务令：测试套件全部通过<br>PEER 类型任务令：PEER 评审全部 pass<br>无阻塞性 Bug 标签的任务令<br>DAG 中无循环依赖残留 |
| **通过条件** | 所有检查项通过 |
| **不通过行为** | 402 `GATE_2_FAILED` — 列出所有未完成任务令及阻塞原因。 |
| **通过后行为** | 策元进入发布就绪状态；G2 通过事件写入 GHF |

### 3.5 Gate 3：发布门控 (Release Gate)

| 属性 | 值 |
|------|---|
| **触发时机** | Gate 2 通过后，策元核发起发布 |
| **检查项** | **PEER+ 审计**：随机抽取已完成 PEER 任务令的 20% 进行第 n+1 人审计（与 §五审计机制对齐）<br>**安全审计**（如适用）：代码安全扫描无 CRITICAL/HIGH 漏洞<br>**接口合规**：所有模块接口满足 PCP 中定义的接口约定<br>**文档完整**：所有面向用户的文档处于 D4 状态 |
| **通过条件** | 所有检查项通过 |
| **不通过行为** | 402 `GATE_3_FAILED` — 需修复后重新触发。 |
| **通过后行为** | 策元产出物正式发布；Git tag 打上 `release/v{major}.{minor}`；G3 通过事件写入 GHF |

### 3.6 Gate 4：归档门控 (Archive Gate)

| 属性 | 值 |
|------|---|
| **触发时机** | 策元核声明归档（通常在发布后 90 天以上，或策元解散时） |
| **检查项** | **GHF 完整性验证**：哈希链从头至尾无断裂（§四.4）<br>所有 D4 文档已迁移至 D5<br>所有活跃任务令已关闭或迁移<br>ALP 保险池清算已完成（如适用）<br>知识产权归属记录完整 |
| **通过条件** | 所有检查项通过 |
| **不通过行为** | 402 `GATE_4_FAILED` — GHF 链断裂或数据不完整。 |
| **通过后行为** | 策元进入 `archived` 状态；工作区变为只读；G4 通过事件写入 GHF（作为 GHF 的最后一个事件） |

### 3.7 Gate API

```
POST /gate/{gu_id}/check/{gate_id}
  Request:  {}  // 无额外参数——系统自动执行该 Gate 的全部检查项
  Response: {
    "gate_id": "G1",
    "passed": false,
    "checked_at": "2026-05-27T15:00:00Z",
    "failures": [
      { "check": "DIRECTION_CONSISTENCY", "detail": "cosine_sim=0.52 < theta=0.75" },
      { "check": "DOCUMENT_D4_REQUIRED", "detail": "docs/design/api_spec.md 仍处于 D2" }
    ],
    "ghf_event_id": "ghf_evt_..."
  }

GET  /gate/{gu_id}/status
  Response: {
    "genesis_id": "gu_x9y8z7w6",
    "current_gate": "G2",
    "gates": {
      "G0": { "passed": true, "passed_at": "2026-05-20T00:00:05Z" },
      "G1": { "passed": true, "passed_at": "2026-05-25T14:30:00Z" },
      "G2": { "passed": false, "last_checked": "2026-05-27T14:00:00Z", "blockers": [...] },
      "G3": { "passed": false, "blocked_by": "G2" },
      "G4": { "passed": false, "blocked_by": "G2" }
    }
  }
  // 获取策元当前门控状态总览
```

### 3.8 Gate 状态机

```
        ┌──────┐
        │ G0   │  策元创建
        └──┬───┘
           │ passed
           ▼
  ┌─────────────────┐
  │  DESIGN_PHASE   │  设计阶段 (G0..G1)
  └────────┬────────┘
           │ G1 check
           ▼
     ┌──────────┐
     │ G1 passed│──passed──→ 进入实现阶段
     └────┬─────┘
          │ failed → 返回设计阶段修复
          │
          ▼
  ┌─────────────────────┐
  │  IMPLEMENTATION_PHASE│  实现阶段 (G1..G2)
  └──────────┬──────────┘
             │ G2 check
             ▼
       ┌──────────┐
       │ G2 passed│──passed──→ 进入发布阶段
       └────┬─────┘
            │ failed → 继续实现
            │
            ▼
  ┌─────────────────┐
  │  RELEASE_PHASE  │  发布阶段 (G2..G3)
  └────────┬────────┘
           │ G3 check
           ▼
     ┌──────────┐
     │ G3 passed│──passed──→ 发布完成
     └────┬─────┘
          │ failed → 修复后重试
          │
          ▼
  ┌─────────────────┐
  │  ARCHIVE_PHASE  │  归档阶段 (G3..G4)
  └────────┬────────┘
           │ G4 check
           ▼
     ┌──────────┐
     │ G4 passed│──passed──→ 策元已归档
     └──────────┘
```

---

## 四、GHF 审计 (Genesis History File)

### 4.1 GHF 定义

**GHF**（Genesis History File）是策元工作区内的不可篡改事件日志，以哈希链结构存储策元内所有协作事件。GHF 是本原零「自利与秩序恒常」的实现层——通过使所有行为可追溯且不可否认，将作弊的期望成本提升至超过收益。

### 4.2 GHF 事件类型

| 事件类型 | 代码 | 携带数据 | 触发条件 |
|---------|:---:|---------|---------|
| `WORKSPACE_FILE_CHANGE` | WFC | file_path, commit_hash, change_type (create/update/delete), ns_id | 工作区文件变更提交 |
| `DOCUMENT_STATE_CHANGE` | DSC | document_id, from_state, to_state, triggered_by_ns_id, reason | 文档生命周期状态转换 |
| `GATE_PASSED` | GAP | gate_id, checked_at, all_checks_passed | Gate 检查全部通过 |
| `GATE_FAILED` | GAF | gate_id, checked_at, failures[] | Gate 检查未通过 |
| `HUMAN_INTERVENTION` | HUI | ns_id, action_type, target_id, reason, override_scope | 策元核或成员的人工干预操作 |
| `MEMBER_JOIN` | MBJ | ns_id, joined_at, pcp_signature | 新成员加入策元 |
| `MEMBER_LEAVE` | MBL | ns_id, left_at, exit_type (amicable/standard/forced) | 成员离开策元 |
| `TASK_WARRANT_STATE_CHANGE` | TSC | task_warrant_id, from_state, to_state | 任务令状态变更 |
| `PEER_REVIEW_SUBMITTED` | PRS | task_warrant_id, reviewer_ns_id, score, verdict | PEER 评审提交 |
| `VT_ALLOCATION` | VTA | task_warrant_id, recipient_ns_id, amount, formula | VT 分配事件 |
| `CORE_DECISION` | CRD | decision_id, core_ns_id, decision_type, rationale_hash | 策元核决策 |
| `ECC_CHANGE_REQUEST` | ECR | ecc_id, target_id, change_type, requested_by, status | 工程变更控制请求 |
| `SKILL_TEMPLATE_VERSION` | STV | template_id, version, updated_by, change_summary_hash | 协作 Skill 模板版本更新 |
| `SYSTEM_EVENT` | SYS | event_subtype, detail_hash | 系统级事件（如自动备份、索引重建） |
| **`PHRO_JUDGMENT`** | **PHJ** | **action_id, matched_domain (P1-P5), staged_result_hash, escalation_reason, judge_ns_id, Ed25519 sig** | **Phronesis Zone 人工判断记录 [v2.0]** |
| **`SOPHIA_ACTION`** | **SPA** | **action_id, action_type, clearance_level, matched_domain (S1-S4)** | **Sophia Zone 自动执行记录 [v2.0]** |
| **`TASK_WARRANT_DESIGNED`** | **TWD** | **task_warrant_id, designer_ns_id, phronesis_profile, decision_gates[], suggested_assignee_profile** | **任务令设计时 phronesis_profile 记录 [v2.0]** |
| **`TASK_DESIGN_AUDIT`** | **TDA** | **task_warrant_id, misclassified_flag, misclassification_type, auditor_ns_id** | **事后 phronesis_profile 对齐度审计 [v2.0]** |
| **`JUDGMENT_RESPONSE`** | **JRS** | **trace_id, selected_option, judge_ns_id, Ed25519 sig, jc_component** | **人工判断响应记录 [v2.0]** |
| **`PEER_SYNC_SCORED`** | **PSS** | **task_warrant_id, peer_sync_score, direction_consistency, iteration_efficiency, reviewers[]** | **continuous 任务令 PEER_SYNC 综合评分 [v2.0]** |

### 4.3 GHF 哈希链结构

每个事件通过 SHA-256 哈希与前一个事件链接：

```
Event_0  (Genesis Event — 策元创建)
  │  event_id = "ghf_evt_0000000000"
  │  hash_prev = null
  │  hash_self = SHA-256(event_data + timestamp + hash_prev)
  │
  ▼
Event_1
  │  event_id = "ghf_evt_0000000001"
  │  hash_prev = Event_0.hash_self
  │  hash_self = SHA-256(event_data + timestamp + hash_prev)
  │
  ▼
Event_2
  │  event_id = "ghf_evt_0000000002"
  │  hash_prev = Event_1.hash_self
  │  hash_self = SHA-256(event_data + timestamp + hash_prev)
  │
  ▼
  ...
```

**事件数据结构**：

```json
{
  "event_id": "ghf_evt_0000000042",
  "genesis_id": "gu_x9y8z7w6",
  "sequence_number": 42,
  "timestamp": "2026-05-27T15:30:00.000Z",
  "event_type": "GATE_PASSED",
  "event_data": {
    "gate_id": "G1",
    "checked_at": "2026-05-27T15:30:00Z",
    "all_checks_passed": true,
    "direction_cosine_sim": 0.82
  },
  "hash_prev": "0a1b2c3d4e5f...",
  "hash_self": "f6e5d4c3b2a1...",
  "signature": "sig:ns_core_..."
}
```

### 4.4 GHF 完整性验证

第三方可通过重放哈希链独立验证 GHF 完整性：

```
function verify_GHF(chain):
    if chain.length == 0:
        return (false, "EMPTY_CHAIN")

    for i in 1..chain.length-1:
        event := chain[i]
        prev  := chain[i-1]

        // 验证前向哈希
        if event.hash_prev != prev.hash_self:
            return (false, f"HASH_CHAIN_BROKEN at event {i}")

        // 重新计算自身哈希
        expected_hash := SHA-256(event.event_data + event.timestamp + event.hash_prev)
        if event.hash_self != expected_hash:
            return (false, f"HASH_MISMATCH at event {i}")

        // 验证序列号连续性
        if event.sequence_number != prev.sequence_number + 1:
            return (false, f"SEQUENCE_GAP at event {i}")

    return (true, "INTEGRITY_VERIFIED")
```

Gate 4 归档门控的核心检查项就是 GHF 完整性验证。

### 4.5 GHF 查询 API

```
GET  /ghf/{gu_id}/events
  Query: ?from_seq=0&limit=100&event_type=GATE_PASSED
  Response: {
    "events": [...],
    "chain_length": 1042,
    "last_hash": "f6e5d4c3b2a1...",
    "integrity_verified": true,
    "next_page_token": "seq_100"
  }
  // 分页查询 GHF 事件

GET  /ghf/{gu_id}/verify
  Response: {
    "verified": true,
    "chain_length": 1042,
    "first_event_at": "2026-05-20T00:00:00Z",
    "last_event_at": "2026-05-27T15:30:00Z",
    "verification_duration_ms": 42
  }
  // 触发一次完整的 GHF 完整性验证

GET  /ghf/{gu_id}/event/{event_id}
  Response: { "event": { ... }, "prev_event": { ... }, "next_event": { ... } }
  // 查询单个事件及其前后上下文
```

---

## 五、策元事件总线 (Genesis Event Bus)

### 5.1 事件总线定位

策元事件总线是协作层的**中枢神经系统**。它采用发布/订阅（Pub/Sub）模式，解耦事件生产者（文件系统、文档生命周期、Gate 系统、PEER 评审）与事件消费者（GHF 写入、策元核编排、通知推送、下游协议触发）。

```
┌──────────────────────────────────────────────────────────┐
│                    Genesis Event Bus                     │
│                                                          │
│  Publishers:                     Subscribers:            │
│  ┌──────────────┐               ┌──────────────────┐    │
│  │ Workspace    │──WFC─────────→│ GHF Writer        │    │
│  │ (File I/O)   │               │ (持久化所有事件)    │    │
│  └──────────────┘               └──────────────────┘    │
│  ┌──────────────┐               ┌──────────────────┐    │
│  │ Doc Lifecycle│──DSC─────────→│ Gate Engine       │    │
│  │ (D1-D6)      │               │ (监听DSC触发Gate)  │    │
│  └──────────────┘               └──────────────────┘    │
│  ┌──────────────┐               ┌──────────────────┐    │
│  │ Gate System  │──GAP/GAF─────→│ Core Orchestrator │    │
│  │ (G0-G4)      │               │ (编排任务令DAG)    │    │
│  └──────────────┘               └──────────────────┘    │
│  ┌──────────────┐               ┌──────────────────┐    │
│  │ PEER Review  │──PRS─────────→│ NR State Machine  │    │
│  │ (L5)         │               │ (NR更新触发)       │    │
│  └──────────────┘               └──────────────────┘    │
│  ┌──────────────┐               ┌──────────────────┐    │
│  │ Member Mgmt  │──MBJ/MBL─────→│ Notification Svc  │    │
│  │ (Join/Leave) │               │ (推送通知)         │    │
│  └──────────────┘               └──────────────────┘    │
│                                                          │
│  所有事件同时写入 GHF（通过 GHF Writer 订阅者）            │
└──────────────────────────────────────────────────────────┘
```

### 5.2 事件优先级

事件总线按三级优先级调度：

| 优先级 | 级别 | 事件类型 | 延迟目标 |
|:---:|------|---------|:---:|
| P0 | 关键 | `GATE_PASSED`, `GATE_FAILED`, `HUMAN_INTERVENTION` | < 100ms |
| P1 | 高 | `DOCUMENT_STATE_CHANGE`, `TASK_WARRANT_STATE_CHANGE`, `MEMBER_JOIN`, `MEMBER_LEAVE` | < 500ms |
| P2 | 标准 | `WORKSPACE_FILE_CHANGE`, `PEER_REVIEW_SUBMITTED`, `VT_ALLOCATION`, `SKILL_TEMPLATE_VERSION` | < 2s |

### 5.3 事件订阅 API

```
POST /event-bus/{gu_id}/subscribe
  Request: {
    "subscriber_id": "sub_gate_engine",
    "event_types": ["DOCUMENT_STATE_CHANGE", "WORKSPACE_FILE_CHANGE"],
    "filter": { "document_state.to": "D4" },   // 可选的过滤条件
    "callback_url": "conc://internal/gate-engine/hook"
  }
  Response: { "subscription_id": "sub_a1b2c3d4", "active": true }

DELETE /event-bus/{gu_id}/subscribe/{subscription_id}
  Response: { "unsubscribed": true }

POST /event-bus/{gu_id}/publish
  Request: {
    "event_type": "WORKSPACE_FILE_CHANGE",
    "priority": "P2",
    "payload": { "file_path": "...", "commit_hash": "...", "change_type": "update", "ns_id": "ns_..." }
  }
  Response: { "event_id": "ghf_evt_...", "published": true, "subscriber_count": 3 }
  // 发布事件到总线。自动写入 GHF 并通知所有匹配订阅者。

GET  /event-bus/{gu_id}/subscriptions
  Response: { "subscriptions": [...], "active_count": 7 }
```

### 5.4 事件持久化保证

事件总线遵循 **at-least-once** 投递语义 + **exactly-once** GHF 写入：

1. 事件发布 → 先写入 GHF（同步、原子）
2. GHF 写入成功 → 事件投递给所有匹配订阅者（异步、可重试）
3. 若投递失败 → 订阅者可通过 GHF 查询接口补拉遗漏事件

这确保即使事件总线进程崩溃，所有事件仍可通过 GHF 完整重建。

---

## 六、协作 Skill 模板 (Collaboration Skill Template)

### 6.1 模板定义

协作 Skill 模板是可复用的协作模式规范，封装了特定场景下「如何协作」的最佳实践。模板由策元核或社区维护，通过语义化版本管理。

每个模板定义：

- **适用场景**：模板是为哪种协作模式设计的
- **文档结构**：该模式下工作区应包含哪些文档
- **Gate 配置**：各 Gate 的自定义检查项
- **任务令模板**：常见任务令类型的预定义结构
- **角色定义**：该模式下成员的角色与权限

### 6.2 模板结构

```json
{
  "template_id": "cst_software_product_v1",
  "display_name": "软件产品协作模板",
  "version": "1.2.0",
  "description": "适用于以软件产品为产出的策元协作。包含敏捷迭代、代码审查和发布流程。",
  "maintainer": "conc-community",
  "compatible_pcp_templates": ["software_product_v1"],
  "created_at": "2026-01-15T00:00:00Z",
  "updated_at": "2026-05-20T00:00:00Z",

  "document_structure": {
    "required": [
      { "path": "docs/design/architecture.md", "description": "系统架构设计文档", "D4_reviewers": 2 },
      { "path": "docs/specs/api_spec.md", "description": "API 规范文档", "D4_reviewers": 1 },
      { "path": "docs/decisions/", "description": "架构决策记录目录", "D4_reviewers": 1 }
    ],
    "optional": [
      { "path": "docs/design/ui_mockups/", "description": "UI 设计稿" },
      { "path": "docs/specs/database_schema.md", "description": "数据库模式设计" }
    ]
  },

  "gate_config": {
    "G1": {
      "additional_checks": ["linter_passed", "dependency_audit_clean"],
      "required_docs_in_D4": ["docs/design/architecture.md", "docs/specs/api_spec.md"]
    },
    "G2": {
      "test_coverage_threshold": 0.80,
      "additional_checks": ["integration_tests_passed", "performance_benchmark_within_20pct"]
    },
    "G3": {
      "additional_checks": ["security_scan_no_critical", "changelog_complete", "migration_tested"]
    }
  },

  "task_warrant_templates": [
    {
      "type": "feature_implementation",
      "default_verification": "PEER",
      "reviewer_count": 3,
      "suggested_vt_range": [50, 500]
    },
    {
      "type": "bug_fix",
      "default_verification": "AUTO",
      "required_auto_checks": ["unit_tests_pass", "regression_tests_pass"],
      "suggested_vt_range": [10, 100]
    },
    {
      "type": "documentation",
      "default_verification": "PEER",
      "reviewer_count": 2,
      "suggested_vt_range": [20, 150]
    }
  ],

  "roles": {
    "tech_lead": {
      "permissions": ["force_unlock_file", "override_gate_G1", "assign_reviewers"],
      "requires_peer_endorsement": true
    },
    "reviewer": {
      "permissions": ["submit_review", "request_changes"],
      "min_NR": 50
    },
    "contributor": {
      "permissions": ["write_file", "submit_for_review", "claim_task_warrant"],
      "min_NR": 10
    }
  },

  "workflows": {
    "hotfix": {
      "description": "紧急修复流程——绕过 G1 直接进入实现",
      "bypass_gates": ["G1"],
      "requires_core_approval": true,
      "max_duration_hours": 4,
      "post_hotfix_actions": ["retrospective_review", "update_tests"]
    }
  }
}
```

### 6.3 模板版本管理

模板使用语义化版本（SemVer）：`MAJOR.MINOR.PATCH`

| 版本变更 | 含义 | 兼容性 |
|:---:|------|:---:|
| MAJOR | 破坏性变更——Gate 检查项增减、文档结构重组 | 不兼容。已使用该模板的策元需要手动迁移。 |
| MINOR | 向后兼容的功能新增——新任务令模板、新角色定义 | 兼容。策元可选择性采纳。 |
| PATCH | 描述修正、默认值调整 | 完全兼容。自动生效。 |

**模板更新 API**：

```
POST /skill-template/{template_id}/version
  Request: {
    "version": "1.3.0",
    "change_summary_hash": "sha256:...",
    "changes": { ... }  // 变更内容
  }
  Response: { "template_id": "cst_software_product_v1", "version": "1.3.0", "ghf_event_id": "ghf_evt_..." }

GET  /skill-template/{template_id}
  Response: { ... }  // 完整模板内容（最新版本）

GET  /skill-template/{template_id}/versions
  Response: { "versions": ["1.0.0", "1.1.0", "1.2.0", "1.3.0"], "current": "1.3.0" }

POST /workspace/{gu_id}/skill-template/apply
  Request:  { "template_id": "cst_software_product_v1", "version": "1.2.0" }
  Response: { "applied": true, "document_structure_created": [...], "gate_config_updated": true }
  // 将指定模板应用到策元工作区。仅影响未初始化的部分——不覆盖已有文档。
```

### 6.4 模板发现与共享

```
GET  /skill-templates
  Query: ?category=software&compatible_with_pcp=software_product_v1
  Response: { "templates": [...], "total": 23 }
  // 全局模板市场——策元可浏览和选择适合的协作模板

POST /skill-template/{template_id}/fork
  Request:  { "new_template_id": "cst_my_custom_workflow", "genesis_id": "gu_x9y8z7w6" }
  Response: { "template_id": "cst_my_custom_workflow", "version": "1.0.0", "forked_from": "cst_software_product_v1@1.2.0" }
  // Fork 模板到本策元——允许策元定制自己的协作模式
```

---

## 七、策元核编排 API (Genesis Core Orchestration API)

### 7.1 编排职责

策元核（Genesis Core）是策元的执行枢纽。在协作层，策元核的编排职责包括：

1. **任务令 DAG 拆解**：将高层次目标分解为可独立执行和验证的任务令 DAG
2. **三阶段分配触发**：管理「广播→匹配→执行」三阶段流水线
3. **变更控制 (ECC)**：管理已冻结文档/代码的变更流程
4. **Gate 流程推进**：在条件满足时主动触发 Gate 检查
5. **PCP 运行时执行**：确保 PCP 条款在协作中落实

### 7.2 任务令 DAG 拆解 API

```
POST /core/{gu_id}/dag/decompose
  Request: {
    "objective": "实现用户认证模块",
    "description_hash": "sha256:...",
    "strategy": "breadth_first" | "depth_first" | "critical_path",
    "max_depth": 3,
    "suggested_reviewers_per_task": 2
  }
  Response: {
    "dag_root_task_id": "tw_root_001",
    "tasks_created": 5,
    "dag_structure": {
      "nodes": [
        { "task_id": "tw_001", "title": "设计认证流程", "depends_on": [], "estimated_hours": 8, "phronesis_profile": "gate", "decision_gates": [{"type": "ARCH_CHOICE", "description": "选择认证协议"}, {"type": "DESIGN_REVIEW", "description": "审核UX"}], "suggested_assignee_profile": "judgment", "verification_type": "PEER" },
        { "task_id": "tw_002", "title": "实现密码哈希", "depends_on": ["tw_001"], "estimated_hours": 6, "phronesis_profile": "none", "suggested_assignee_profile": "execution", "verification_type": "AUTO" },
        { "task_id": "tw_003", "title": "实现 JWT 签发", "depends_on": ["tw_001"], "estimated_hours": 6, "phronesis_profile": "none", "suggested_assignee_profile": "execution", "verification_type": "AUTO" },
        { "task_id": "tw_004", "title": "集成测试", "depends_on": ["tw_002", "tw_003"], "estimated_hours": 4, "phronesis_profile": "none", "suggested_assignee_profile": "execution", "verification_type": "AUTO" },
        { "task_id": "tw_005", "title": "安全审计", "depends_on": ["tw_004"], "estimated_hours": 4, "phronesis_profile": "gate", "decision_gates": [{"type": "RISK_ACCEPTANCE", "description": "接受残余风险"}], "suggested_assignee_profile": "judgment", "verification_type": "PEER_SYNC" }
      ],
      "critical_path": ["tw_001", "tw_002", "tw_004", "tw_005"],
      "total_estimated_hours": 28,
      "parallelism_opportunities": [["tw_002", "tw_003"]]
    }
  }
  // v2.0: 每个节点新增 phronesis_profile（none/gate/continuous）、decision_gates（gate模式预声明）、suggested_assignee_profile（execution/judgment 软建议）。将高层次目标拆解为任务令 DAG。自动设置 depends_on 和 blocks 关系。
```

### 7.3 三阶段分配触发 API

三阶段流水线：**广播 (Broadcast) → 匹配 (Matching) → 执行 (Executing)**

```
POST /core/{gu_id}/orchestrate/broadcast
  Request: { "task_warrant_id": "tw_003" }
  // 将满足前序依赖的任务令推入 BROADCAST 状态
  // 前置条件：所有 depends_on 任务令状态为 MERGED_RESOLVED
  Response: {
    "task_warrant_id": "tw_003",
    "state": "BROADCAST",
    "broadcast_at": "2026-05-27T15:00:00Z",
    "eligible_members_count": 4,
    "matching_window_seconds": 3600
  }

POST /core/{gu_id}/orchestrate/match
  Request: {
    "task_warrant_id": "tw_003",
    "claimant_ns_id": "ns_4d5e6f7g",
    "matching_rationale_hash": "sha256:..."
  }
  // 成员认领处于 BROADCAST 的任务令
  Response: {
    "task_warrant_id": "tw_003",
    "state": "MATCHED",
    "claimant_ns_id": "ns_4d5e6f7g",
    "matched_at": "2026-05-27T15:30:00Z",
    "execution_deadline": "2026-05-27T21:30:00Z"
  }

POST /core/{gu_id}/orchestrate/execute
  Request: { "task_warrant_id": "tw_003" }
  // 由 MATCHED 进入 EXECUTING——任务令正式进入执行阶段
  Response: {
    "task_warrant_id": "tw_003",
    "state": "EXECUTING",
    "started_at": "2026-05-27T15:31:00Z",
    "slashing_parameters": {
      "grace_period_seconds": 2160,
      "linear_burn_rate": 0.0001,
      "forced_abort_deadline": "2026-05-28T03:31:00Z"
    }
  }

GET  /core/{gu_id}/orchestrate/pipeline
  Response: {
    "broadcast_pool": ["tw_004"],
    "matched_pool": ["tw_005"],
    "executing_pool": ["tw_003"],
    "blocked_tasks": ["tw_006"],   // depends_on 未满足
    "pipeline_health": "healthy"
  }
  // 策元核流水线总览
```

### 7.4 工程变更控制 (ECC — Engineering Change Control)

ECC 管理已冻结（D4+）文档和代码的受控修改。任何对已发布产出物的修改都必须通过 ECC 流程。

**ECC 状态机**：

```
REQUESTED ──→ REVIEW ──→ APPROVED ──→ IMPLEMENTING ──→ VERIFIED ──→ CLOSED
                │                                        │
                └──→ REJECTED                            └──→ ROLLBACK
```

**ECC API**：

```
POST /core/{gu_id}/ecc/request
  Request: {
    "target_type": "document" | "code_module",
    "target_id": "doc_..." | "module_...",
    "change_description_hash": "sha256:...",
    "justification": "修复已发布 API 的安全漏洞",
    "impact_assessment_hash": "sha256:...",
    "requested_by_ns_id": "ns_0a1b2c3d"
  }
  Response: {
    "ecc_id": "ecc_a1b2c3d4",
    "state": "REQUESTED",
    "created_at": "2026-05-27T16:00:00Z",
    "reviewers_assigned": ["ns_4d5e6f7g"]
  }

POST /core/{gu_id}/ecc/{ecc_id}/review
  Request: {
    "decision": "approved" | "rejected" | "needs_clarification",
    "review_comments_hash": "sha256:...",
    "conditions": ["必须同步更新 API 文档到 D4", "回归测试必须通过"]
  }
  Response: {
    "ecc_id": "ecc_a1b2c3d4",
    "state": "APPROVED" | "REJECTED",
    "updated_at": "..."
  }

POST /core/{gu_id}/ecc/{ecc_id}/implement
  Request: { "implementation_commit_hash": "abc123" }
  Response: { "state": "IMPLEMENTING", "lock_acquired": true }

POST /core/{gu_id}/ecc/{ecc_id}/verify
  Request: { "verification_result": "passed" | "failed", "evidence_hash": "sha256:..." }
  Response: { "state": "VERIFIED" | "ROLLBACK" }

POST /core/{gu_id}/ecc/{ecc_id}/close
  Response: { "state": "CLOSED", "closed_at": "..." }

GET  /core/{gu_id}/ecc
  Response: { "active_eccs": [...], "recently_closed": [...], "total_count": 12 }
```

### 7.5 策元核决策 API

策元核在以下情况需要做出编排决策——所有决策写入 GHF（`CORE_DECISION` 事件），确保可追溯：

```
POST /core/{gu_id}/decision
  Request: {
    "decision_type": "force_unlock" | "task_reassignment" | "gate_override" | "member_removal" | "emergency_pause",
    "target_id": "lock_..." | "tw_..." | "gate_G2" | "ns_..." | null,
    "rationale_hash": "sha256:...",
    "evidence_refs": ["ghf_evt_...", "ghf_evt_..."]
  }
  Response: {
    "decision_id": "dec_a1b2c3d4",
    "decision_type": "force_unlock",
    "status": "executed",
    "ghf_event_id": "ghf_evt_..."
  }
  // 某些决策类型（如 gate_override, member_removal）需要通过 PCP 定义的治理流程
  // 例如，需要策元 ≥20% 成员联名挑战才可执行

POST /core/{gu_id}/decision/{decision_id}/challenge
  Request: {
    "challenger_ns_id": "ns_...",
    "challenge_reason_hash": "sha256:...",
    "endorsements": ["ns_...", "ns_..."]
  }
  // 需要 ≥20% 成员联名。触发策元内投票流程。
```

### 7.6 编排自动化触发器

策元核编排不是纯手动操作——以下触发器自动执行编排动作：

| 触发器 | 条件 | 自动动作 |
|--------|------|---------|
| `on_dag_unblocked` | 一个任务令的最后一个前序依赖被满足 | 自动将任务令推入 BROADCAST（调用 `/core/{gu_id}/orchestrate/broadcast`） |
| `on_broadcast_timeout` | 任务令处于 BROADCAST 超过匹配窗口且无人认领 | 发送提醒通知；若无人认领超过 2×窗口 → 策元核强制重分配 |
| `on_execution_deadline_approaching` | 任务令距执行截止 < 宽限期 | 发送预警通知给执行者 |
| `on_gate_blocked` | Gate 检查失败，阻塞超过 72 小时 | 生成阻塞分析报告；通知策元核 |
| `on_idle_workspace` | 工作区连续 30 天无文件变更 | 提示策元核审核策元状态（是否应归档） |
| `on_member_inactivity` | 成员连续 14 天无活动 | 通知策元核；连续 30 天 → 建议转为观察者状态 |

---

## 八、协议完备度与演进路线

### 8.1 当前完备度

| 模块 | 完备度 | 备注 |
|------|:---:|------|
| 策元工作区 | 85% | 文件锁定、同步协议已定义；CRDT 的具体数据结构需与实现层对齐 |
| 文档生命周期 D1-D6 | 90% | 状态机完整、API 完整；D5→D6 废弃投票的 % 阈值待 PCP 集成后确定 |
| Gate 门控 0-4 | 85% | 五级门控逻辑完整；G3 安全审计的具体检查项需对接安全扫描工具 |
| GHF 审计 | 90% | 哈希链结构完整、验证算法完整；大策元（>10K 事件）的分片索引策略待定义 |
| 策元事件总线 | 80% | 事件类型、优先级、Pub/Sub 模型完整；跨策元事件路由未覆盖 |
| 协作 Skill 模板 | 75% | 模板结构、版本管理完整；模板市场治理（审核、评级）待定义 |
| 策元核编排 API | 80% | 核心 API 完整；编排策略的 AI 辅助优化待模型三集成 |

**总体完备度：约 84%**

### 8.2 已知缺口

1. **CRDT 具体实现规范**：本协议定义了「使用 CRDT」但未指定具体 CRDT 数据结构（如 Yjs/RGA/Automerge）。应由实现层协议补充。
2. **跨策元协作**：当前事件总线限定单策元。跨策元文档引用、联合 Gate 检查、跨策元 ECC 均未覆盖。
3. **工作区存储后端抽象**：当前假设 Git + 本地文件系统。大型二进制产物（模型权重、视频）的存储策略未定义。
4. **模板市场治理**：Skill 模板的审核、评级、废弃流程未定义。

### 8.3 演进路线

| 版本 | 目标 | 预期完备度 |
|:---:|------|:---:|
| v1.0（本版本） | 基础协作框架——单策元内工作区、D1-D6、Gate 0-4、GHF | ~84% |
| v1.1 | CRDT 实现规范 + 工作区存储后端抽象 | 90% |
| v1.2 | 跨策元协作引用 + 联合 Gate | 93% |
| v2.0 | Skill 模板市场 + AI 辅助编排策略 | 96% |

---

## 九、错误码汇总

| 错误码 | 名称 | 说明 |
|:---:|------|------|
| 402 | `GATE_0_FAILED` | Gate 0 创建门控未通过 |
| 402 | `GATE_1_FAILED` | Gate 1 设计确认门控未通过 |
| 402 | `GATE_2_FAILED` | Gate 2 实现完成门控未通过 |
| 402 | `GATE_3_FAILED` | Gate 3 发布门控未通过 |
| 402 | `GATE_4_FAILED` | Gate 4 归档门控未通过 |
| 409 | `LOCK_CONFLICT` | 文件已被他人以写锁锁定 |
| 423 | `FILE_LOCKED` | 文件处于写锁保护中 |
| 404 | `DOCUMENT_NOT_FOUND` | 文档不存在 |
| 409 | `INVALID_STATE_TRANSITION` | 文档/任务令状态转换不合法 |
| 409 | `ECC_TARGET_NOT_FROZEN` | ECC 目标不在 D4+ 冻结状态 |
| 422 | `GHF_INTEGRITY_BROKEN` | GHF 哈希链验证失败 |
| 403 | `INSUFFICIENT_PERMISSIONS` | 调用者缺少所需角色权限 |
| 409 | `DAG_CYCLE_DETECTED` | 任务令 DAG 拆解产生环路 |
| 400 | `INVALID_TEMPLATE_VERSION` | 指定的 Skill 模板版本不存在 |
| 503 | `EVENT_BUS_UNAVAILABLE` | 事件总线暂时不可用 |
| 408 | `LOCK_EXPIRED` | 文件锁已过期，需重新获取 |

---

## 附录 A：与现有协议的交互矩阵

| 源协议 | 交互点 | 本协议对应模块 |
|--------|--------|--------------|
| 01_Protocol_Layer.md | 策元层 API (`/genesis/*`) | Gate 0 在 `POST /genesis/create` 时触发 |
| 05_PEER_Verification_Protocol.md | PEER 评审提交 | `PEER_REVIEW_SUBMITTED` 事件通过事件总线写入 GHF；Gate 3 的 PEER+ 审计触发 |
| 06_CCR_Public_Ledger.md | CCR 变更 | 通过事件总线触发 NR 状态机更新（17 号协议协调） |
| 08_Tiered_Slashing_Protocol.md | 燃烧事件 | 任务令超时 → 事件总线发布 `TASK_WARRANT_STATE_CHANGE` → GHF 记录 |
| 15_Direction_Profile_and_Judgment_Credit.md | 方向档案 | Gate 1 的方向一致性检查读取策元方向档案 |
| 16_Capability_Proof_Promotion_Pipeline.md | 能证晋级 | 成员完成任务令 → 事件总线 → CP 晋级管道读取 |
| 17_NR_Unified_State_Machine.md | NR 更新 | 事件总线是 NR 事件的输入源之一 |

---

## 附录 B：GHF 事件完整 Schema

```json
{
  "$schema": "https://conc-protocol.org/ghf-event-schema.json",
  "type": "object",
  "required": ["event_id", "genesis_id", "sequence_number", "timestamp", "event_type", "hash_prev", "hash_self"],
  "properties": {
    "event_id":         { "type": "string", "pattern": "^ghf_evt_[0-9a-f]{10}$" },
    "genesis_id":       { "type": "string", "pattern": "^gu_[0-9a-z]{8}$" },
    "sequence_number":  { "type": "integer", "minimum": 0 },
    "timestamp":        { "type": "string", "format": "date-time" },
    "event_type":       { "type": "string", "enum": ["WFC","DSC","GAP","GAF","HUI","MBJ","MBL","TSC","PRS","VTA","CRD","ECR","STV","SYS","PHJ","SPA","TWD","TDA","JRS","PSS"] },
    "event_data":       { "type": "object" },
    "hash_prev":        { "type": "string", "pattern": "^[0-9a-f]{64}$" },
    "hash_self":        { "type": "string", "pattern": "^[0-9a-f]{64}$" },
    "signature":        { "type": "string", "description": "Ed25519签名，覆盖 event_data + timestamp + hash_prev" }
  }
}
```

---

> **协议维护者**：CONC 协议工作组
> **最后更新**：2026-05-27
> **下次审计**：2026-08-27（季度审计）
> **关联协议**：01 / 05 / 06 / 08 / 15 / 16 / 17


---

## v1.1 更新 (2026-07-10) — CONC-P1-1, CONC-P0-3
- 同步CP4四信号融合对协作层策元匹配的影响
- 策元稳定性参数σ_GU影响Gate门控的审批强度
- 术语同步：σ_GU行业默认值（软件0.1→制药0.9）已编入策元配置模板

## v2.0 更新 (2026-07-12) — CONC-P1-1: Sophia↔Phronesis GHF + DAG 集成
- GHF 事件表新增 6 个事件：PHRO_JUDGMENT (PHJ), SOPHIA_ACTION (SPA), TASK_WARRANT_DESIGNED (TWD), TASK_DESIGN_AUDIT (TDA), JUDGMENT_RESPONSE (JRS), PEER_SYNC_SCORED (PSS)
- DAG 拆解 API 返回值每个节点新增：phronesis_profile, decision_gates, suggested_assignee_profile
- 附录 B GHF 事件 Schema enum 扩展
- 交叉引用：`19_Phronesis_Layer_Protocol.md` v2.0（GovernedAction/Action Gate）；`15_Direction_Profile_and_Judgment_Credit.md` v2.0（四分量 JC）
