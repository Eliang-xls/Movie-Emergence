# CONC 决断层协议规范
## Phronesis Layer Protocol Specification v2.0

> 协议标识符：`CONC-Protocol/Phronesis.2.0`
> **v2.0 升级摘要**：新增 §1.4 任务执行级 Phronesis 触发域 P1-P5（策元生命周期的 JP-001~010 补充）、JC 体系对齐四分量重构（引用 15 协议 v2.0）、新增 §六 GovernedAction 原语与 Action Gate（Sophia/Phronesis 运行时判定机制）。基于 Harness 逆向分类学 (Tiwari/Taskade/Anthropic) 和 Palantir AIP 的 Action Staging/Governance Threshold 模式。
> 归属层：协议栈第七层 — Phronesis Layer（决断层）
> 依赖协议：CSIP (智权体身份)、ICP (意图聚结)、CTCP (任务令协议)、PEER (同行验证)、CCR (公开账本)、弹性分叉协议、Direction Profile & Judgment Credit 协议 (15, v2.0)
> 理论溯源：公理二b（主动型工作假设）、Sophia/Phronesis 双层理论、公理四（One-Agent 不可还原）、PBA 定理层 PBA1-PBA6
>
> **完备度声明**：本规范将决断层从概念阶段提升至正式协议规范。v1.0 定义决断点注册 (JP-001~010)、介入协议、加力类型、决断追踪 (Ed25519 签名链)、JC 体系。v2.0 扩展了任务执行级 Phronesis 触发域 (P1-P5) 和 GovernedAction 原语，使 Sophia↔Phronesis 边界从固定 JP 扩展为动态运行时判定。

---

## 〇、协议定位与设计概要

### 0.1 在协议栈中的位置

```
┌─────────────────────────────────────────────────────────┐
│  第七层：Phronesis Layer（决断层）  ← 本协议             │
│  人的判断介入 · 方向加力 · 安全否决 · JC 体系             │
├─────────────────────────────────────────────────────────┤
│  第六层：Sophia Layer（智慧层）                          │
│  Agent Skill 执行 · 自动化验证 · 任务令分配              │
├─────────────────────────────────────────────────────────┤
│  第五层：价值层 (Value Layer)                            │
│  VT 铸造/分发 · NR 计算 · 回报分配 · ALP 借贷             │
├─────────────────────────────────────────────────────────┤
│  第四层：验证层 (Verification Layer)                     │
│  模块验证 · 共识仲裁 · CC 打分                            │
├─────────────────────────────────────────────────────────┤
│  第三层：策元层 (Genesis Layer)                           │
│  策元 CRUD · DAG 依赖路由 · PCP 管理 · 弹性分叉           │
├─────────────────────────────────────────────────────────┤
│  第二层：身份层 (Identity Layer)                          │
│  智权体注册 · 能证发行 · 身份锚定                          │
├─────────────────────────────────────────────────────────┤
│  第一层：网络层 (Network Layer)                           │
│  节点发现 · 消息广播 · 状态同步                            │
└─────────────────────────────────────────────────────────┘
```

### 0.2 Sophia/Phronesis 双层理论

CONC 协议栈的第六层 (Sophia) 和第七层 (Phronesis) 共同构成智权体的完整能力表达：

| | Sophia (理论智慧) | Phronesis (实践智慧) |
|---|---|---|
| **载体** | Agent Skill 库 | 自然人 (One) |
| **可编码性** | 高（规则/代码/文档） | 低（经验直觉/情境感知） |
| **可迁移性** | 高（Skill 流通与引用） | 低（绑定于个体经验） |
| **协议化方式** | 能证体系 + Skill 谱系 | **决断点介入 + Judgment Credit** |
| **自动化程度** | Agent 全自动执行 | 必须由人做出判断 |
| **协议层归属** | Sophia Layer (第6层) | Phronesis Layer (第7层，本协议) |

### 0.3 理论溯源

#### 公理二b（主动型工作假设）

> One（自然人）通过**主动型工作假设 (Active Working Hypothesis)** 将模糊的外部信号转化为可执行的内部方向——这一转化过程不可由 Agent 替代。

决断层协议将此公理操作化为：人在关键决断点 (Judgment Point) 的介入不是"审批"已有方案，而是**注入 Agent 无法自主生成的方向性信号**。

#### 公理四（One-Agent 不可还原）

> 智权体 (Noetic Subject) = One + Agent。Agent 的能力可以由其他 Agent 替代，但 One 的**方向性判断、价值排序、风险直觉**不可还原为 Agent 的算法输出。

决断层协议确保：所有不可还原的判断行为均通过 Ed25519 签名链记录，形成可审计的决断追踪 (Judgment Trace)。

### 0.4 核心设计原则

1. **最小介入原则**：仅在 Sophia 层无法自主决策的决断点触发人类介入。不将人降格为"审批机器"。
2. **签名不可否认**：每次决断介入均需 Ed25519 签名，纳入哈希链——确保判断行为的不可否认性和完整性。
3. **加力而非替代**：人的判断是对 Agent 执行结果的**方向性加力 (Amplification)**，而非替代 Agent 的执行能力。
4. **JC 作为 Phronesis 代理指标**：Judgment Credit 是 Phronesis 的**可观测代理指标**，而非 Phronesis 本体。这一区分防止"量化指标替代被量化对象"的本体论谬误。

---

## 一、决断点注册 (Judgment Point Registry)

### 1.1 概述

决断点 (Judgment Point, JP) 是协议层预定义的、需要人类判断介入的关键节点。每个决断点对应策元生命周期中的一个不可逆决策时刻。

决断点编号遵循 `JP-XXX` 格式，前 10 个为协议内置决断点 (JP-001 ~ JP-010)，后续可由 PCP 自定义扩展 (JP-011+)。

### 1.2 决断点完整注册表

#### JP-001：策元方向确认

| 属性 | 值 |
|------|-----|
| **名称** | Genesis Direction Confirmation |
| **触发时机** | ICP（意图聚结）完成后、策元结晶 (Genesis Crystallization) 前 |
| **触发条件** | `intent_coalescence.status == "COMPLETED"` 且 `similarity_score >= theta` |
| **上下文数据** | Creative Seed JSON、ICP 匹配报告（sim 分数、成员列表及 sim 向量）、方向向量预览 |
| **可选选项** | `APPROVE`（批准结晶）、`MODIFY`（修改方向向量并重新 ICP）、`REJECT`（拒绝结晶） |
| **超时策略** | 72h 无响应 → 状态置为 `ESCALATED` → 策元核接管；策元核亦超时 → ICP 解散，成员返回意图池 |
| **签名要求** | 发起人 Ed25519 签名 + 至少 1 名共签人 Ed25519 签名 |
| **不可委托性** | 是（主权决策） |

#### JP-002：DAG 确认

| 属性 | 值 |
|------|-----|
| **名称** | Task Warrant DAG Confirmation |
| **触发时机** | 任务令 DAG 拆解完成后、分配 (Broadcast) 前 |
| **触发条件** | DAG 拓扑生成完成，所有 `depends_on` 关系已建立，环路检测通过 |
| **上下文数据** | 完整 DAG JSON（任务令列表、依赖图、预估 VT 分配、关键路径分析） |
| **可选选项** | `APPROVE`（确认发布）、`REORDER`（调整优先顺序）、`ADD_DEPENDENCY`（补充依赖关系）、`SPLIT_TASK`（拆分过大任务令） |
| **超时策略** | 48h 无响应 → `AUTO_APPROVE`（若 DAG 复杂度评分 < 0.5）或 `ESCALATED`（若复杂度 ≥ 0.5） |
| **签名要求** | 发起人 Ed25519 签名 |
| **不可委托性** | 否（可委托给策元核成员） |

#### JP-003：安全决策

| 属性 | 值 |
|------|-----|
| **名称** | Security Decision Point |
| **触发时机** | 涉及安全审计的 PEER_SYNC 完成后 |
| **触发条件** | PEER 评审结果包含 `security_flag == true` 或 安全审计工具标记高危漏洞 |
| **上下文数据** | 安全审计报告、漏洞详情 (CVE 映射)、影响范围分析、修复方案对比 |
| **可选选项** | `APPROVE_WITH_FIXES`（批准但要求修复指定漏洞）、`BLOCK`（阻塞部署直至全部修复）、`ACCEPT_RISK`（接受风险并记录风险接受声明） |
| **超时策略** | 24h 无响应 → `BLOCK`（安全默认：未明确批准即阻塞） |
| **签名要求** | 安全官 (Security Officer) Ed25519 签名；若无指定安全官 → 策元核轮值成员签名 |
| **不可委托性** | 是（安全否决权不可委托） |

#### JP-004：资源分配

| 属性 | 值 |
|------|-----|
| **名称** | Resource Allocation Decision |
| **触发时机** | 弹性分叉的算力分配决策 |
| **触发条件** | 软分叉创建请求触发 `allocation_alpha` 计算完成，或季度资源重分配周期到期 |
| **上下文数据** | 当前算力分布 (主方向 vs 各分支的 α 值)、各分支进展报告、NR 加权资源需求矩阵 |
| **可选选项** | `APPROVE_CURRENT`（维持当前分配）、`REBALANCE`（重新分配算力比例）、`CAP_BRANCH`（限制分支算力上限）、`PROMOTE_BRANCH`（提升某分支为主方向） |
| **超时策略** | 72h 无响应 → 维持当前分配比例不变 |
| **签名要求** | 策元核成员 Ed25519 签名（需 ≥ 50% 策元核成员同意） |
| **不可委托性** | 否（可委托，但需策元核集体决策） |

#### JP-005：安全否决

| 属性 | 值 |
|------|-----|
| **名称** | Security Veto |
| **触发时机** | 安全官发现严重安全问题时随时触发 |
| **触发条件** | 安全官主动发起，或自动化安全扫描发现 `severity >= CRITICAL` 自动触发 |
| **上下文数据** | 安全事件描述、影响范围、紧急程度评估、临时缓解措施 |
| **可选选项** | `VETO_DEPLOY`（否决部署）、`VETO_MERGE`（否决合并）、`FREEZE_ASSETS`（冻结相关资产）、`EMERGENCY_PAUSE`（紧急暂停策元运行） |
| **超时策略** | 否决立即生效，无需等待。否决后 72h 内必须提交完整安全审计报告，否则否决自动解除 |
| **签名要求** | 安全官 Ed25519 签名（一票否决权） |
| **不可委托性** | 是（安全官一票否决权为不可委托的主权权力） |

#### JP-006：季度方向重校准

| 属性 | 值 |
|------|-----|
| **名称** | Quarterly Direction Recalibration |
| **触发时机** | 每季度创意重校准周期到期 |
| **触发条件** | `creative_recalibration_interval_weeks` 到期（默认 13 周） |
| **上下文数据** | 当前方向向量、各成员创意种子相似度分布、分叉状态报告、市场反馈汇总 |
| **可选选项** | `KEEP_DIRECTION`（保持方向）、`ADJUST_VECTOR`（微调方向向量）、`INITIATE_SOFT_FORK`（启动软分叉）、`INITIATE_HARD_FORK`（启动硬分叉表决） |
| **超时策略** | 168h (7天) 无响应 → 维持当前方向，标记为 `PASSIVE_RECALIBRATION` |
| **签名要求** | 策元核成员 Ed25519 签名（需 ≥ 2/3 策元核成员同意） |
| **不可委托性** | 否（但需策元核集体决策） |

#### JP-007：新成员准入

| 属性 | 值 |
|------|-----|
| **名称** | New Member Admission |
| **触发时机** | ICP 匹配到新成员且 sim ≥ θ 后、正式加入策元前 |
| **触发条件** | `intent_coalescence.new_member_candidate != null` |
| **上下文数据** | 候选人方向档案 (Direction Profile)、NR 历史、JC 评分、CCR 记录、commitment_pattern |
| **可选选项** | `ADMIT`（接纳）、`PROBATION_ADMIT`（试用期接纳，观察 4 周）、`REJECT`（拒绝） |
| **超时策略** | 168h (7天) 无响应 → `PROBATION_ADMIT`（默认试用接纳） |
| **签名要求** | 策元核成员 Ed25519 签名（需 ≥ 50% 同意） |
| **不可委托性** | 否 |

#### JP-008：PCP 修正

| 属性 | 值 |
|------|-----|
| **名称** | PCP Amendment Decision |
| **触发时机** | PCP 修正提案完成全策元讨论后 |
| **触发条件** | PCP amend 提案已通过形式审查，进入表决阶段 |
| **上下文数据** | 修正提案全文、影响分析（对现有任务令/成员/VT 分配的冲击）、讨论记录摘要 |
| **可选选项** | `ADOPT`（采纳修正）、`REJECT`（否决修正）、`DEFER`（延期至下季度讨论） |
| **超时策略** | 168h (7天) 无响应 → `DEFER`（默认延期） |
| **签名要求** | 全策元成员 Ed25519 签名（需 > 50% 成员同意） |
| **不可委托性** | 是（PCP 为策元宪法，修正需全体成员参与） |

#### JP-009：ALP 熔断决策

| 属性 | 值 |
|------|-----|
| **名称** | ALP Circuit Breaker Decision |
| **触发时机** | ALP 储备率跌破熔断阈值 |
| **触发条件** | `ALP.reserve_ratio < 0.25` → `CIRCUIT_BREAKER_ACTIVE` |
| **上下文数据** | ALP 状态（储备率、借贷总量、保险池余额）、熔断原因分析、恢复方案 |
| **可选选项** | `ACTIVATE_BREAKER`（激活熔断—暂停新借贷）、`RAISE_RESERVES`（成员紧急注资）、`ORDERLY_WIND_DOWN`（有序清盘）、`OVERRIDE_BREAKER`（覆盖熔断—仅策元核全票） |
| **超时策略** | 12h 无响应 → `ACTIVATE_BREAKER`（自动激活熔断） |
| **签名要求** | 策元核成员 Ed25519 签名（需 ≥ 2/3 同意；`OVERRIDE_BREAKER` 需全票） |
| **不可委托性** | 是（涉及经济安全，不可委托） |

#### JP-010：分裂/解散决策

| 属性 | 值 |
|------|-----|
| **名称** | Genesis Split / Dissolution Decision |
| **触发时机** | 策元解体条件满足 |
| **触发条件** | 任一：`dissolution_vote_threshold` 达到（默认 67%）、核心成员流失 > 50%、连续两个季度方向重校准失败、硬分叉表决通过 |
| **上下文数据** | 策元完整状态快照（成员列表、VT 余额、NR 分布、任务令完成率、IP 清单、ALP 状态）、分裂/解散方案对比 |
| **可选选项** | `SPLIT`（硬分叉——成员按方向偏好分配至新策元）、`DISSOLVE`（解散——按 PCP 规定的解散程序分配资产）、`MAINTAIN`（维持现状但启动重组）、`SEEK_MERGER`（寻求与其他策元合并） |
| **超时策略** | 336h (14天) 无响应 → 状态置为 `ADMINISTRATIVE_DISSOLUTION` → 策元核轮值成员执行 PCP 预设解散程序 |
| **签名要求** | 全策元成员 Ed25519 签名（需 ≥ dissolution_vote_threshold 同意，默认 67%） |
| **不可委托性** | 是（策元解体为不可委托的主权决策） |

### 1.3 决断点扩展机制

PCP 可通过 `custom_judgment_points` 字段定义策元特有的决断点：

```json
{
  "custom_judgment_points": [
    {
      "jp_id": "JP-011",
      "name": "Custom Judgment Point Name",
      "trigger_condition": "expression in CONC event DSL",
      "context_data_schema": { "...": "..." },
      "options": ["OPTION_A", "OPTION_B"],
      "timeout_hours": 48,
      "signature_requirement": "majority_core",
      "non_delegable": false
    }
  ]
}
```

自定义决断点编号从 JP-011 开始递增，不可与协议内置决断点编号冲突。

### 1.4 任务执行级 Phronesis 触发域 (P1-P5)  **[v2.0 新增]**

§1.2 的 JP-001~010 覆盖了策元**生命周期级**决断——策元创建、DAG 确认、安全、资源、方向、准入、PCP、ALP、解散。但当任务令被领取后，Agent 在拆解执行过程中遇到的判断需求不被 JP-001~010 覆盖。P1-P5 填补此空白：它们是**任务执行级**的 Phronesis 触发域——Agent 在 Sophia 域自主执行，一旦动作落入以下五个域，GovernedAction 判定 `should_escalate_to_phronesis() == TRUE` → 触发人工判断。

#### 1.4.1 P1 — 不可逆动作 (Irreversibility)

**条件**：动作的风险因子中 irreversibility_score > τ_irrev（默认 0.6）。包括：破坏性写入 (delete/drop/truncate)、外部通信 (email/post/publish)、金融交易 (VT 转账/借贷/ALP 熔断)、生产部署。

**Harness 锚定**：Taskade 风险→层映射——「不可逆动作→Human Approval Gate」。
**JC 侧重点**：outcome · difficulty（回滚成本越高 difficulty 越大）。
**默认 τ**：0.6（PCP 可调）。

#### 1.4.2 P2 — 过度代理 / 越权 (Excessive Agency)

**条件**：动作的 clearance_level > Agent 当前自治阈值（默认 C1：仅沙箱写回；超 C1 触发越权判定）。包括：写回外部系统 (Ring 3)、跨策元资源访问、策元成员身份变更 (join/leave/expel)、PCP 修正。

**Harness 锚定**：Tiwari 四环执行模型 (Ring 0-3)；Taskade「过度代理→Tool/Action Gate→需要人工」。
**JC 侧重点**：outcome · difficulty（影响范围越大 difficulty 越大）。
**默认 τ**：clearance_level ≥ C2 时触发。

#### 1.4.3 P3 — 价值/方向判断 (Value Tradeoff)

**条件**：Agent confidence < τ_conf 且动作涉及价值取舍（架构取舍、设计审美、功能优先级、风险接受）。Agent 无法自主决定「哪个更重要」—— 因为 ground-truth reward 不存在。

**Harness 锚定**：Anthropic Checkpoint 模式——人类反馈设置在「规划后」「方向性判断」节点。
**JC 侧重点**：outcome · difficulty · uniqueness（创意决策的独特性高）。
**默认 τ_conf**：0.75（PCP 可调——Agent 在特定 skill_domain 评测通过率越高，τ_conf 越低）。

#### 1.4.4 P4 — 多主体分歧 (Disagreement)

**条件**：PEER 评分方差 > σ_threshold（默认 1.5）、PEER 评审 approve/request_changes 参半、ICP 相似度处于 θ±ε 暧昧区、Gate 判定争议。

**Harness 锚定**：无直接对应——但 CONC 的 PEER 评审机制提供了独有的多主体信号源（开源协作中自然的 opinion diversity）。
**JC 侧重点**：outcome · uniqueness（调解方案的创新性）。
**默认 σ_threshold**：1.5。

#### 1.4.5 P5 — 新颖性 / 歧义 (Novelty/Ambiguity)

**条件**：Agent 无匹配 Skill 模板（skill_template_match_score < τ_skill）、信息完备度 < 70%（info_completeness < 0.7）、跨领域组合（需 ≥2 个 skill_domain 的协同判断）。

**Harness 锚定**：Harness「confidence < τ」模式；SBDEL 定理 S1（场景替代）——当 Skill 模板不匹配时 S1 失效，回退至人类判断。
**JC 侧重点**：outcome · uniqueness（全新类型的首次处理）。
**默认 τ_skill**：0.3。

### 1.4.6 P1-P5 与 Sophia Zone 的边界

以下动作落在 **Sophia Zone (S1-S4)**，Agent 自主执行，不触发 Phronesis，不产生 JC（完整定义见 `15_Direction_Profile_and_Judgment_Credit.md` §6.1）：

| Zone | 类型 | 机制 |
|:---:|------|------|
| S1 | 内容安全过滤 (PII/注入/有害内容) | Guardrail 自动阻断 |
| S2 | 确定性正确性校验 (编译/测试/lint/Schema) | AUTO 验证 pass/fail |
| S3 | 常规操作 (重试/工具选择[allowlist内]/上下文压缩/非破坏性读写) | Sophia 域自主执行 |
| S4 | 协议层自动检查 (Gate 0-4 自动项/depends_on/CRDT LWW) | 确定性规则判定 |

P1-P5 与 S1-S4 构成完整的 Sophia↔Phronesis 运行时判定矩阵。

### 1.5 与策元生命周期 JPs 的关系

JP-001~010 与 P1-P5 是**互补的**，不是互斥的：

| 维度 | JP-001~010 | P1-P5 |
|------|-----------|-------|
| **触发层面** | 策元生命周期 | 任务令执行 |
| **触发方式** | 事件驱动（ICP_COMPLETED / DAG_GENERATED / ...） | GovernedAction 判定函数（每次动作时调用） |
| **频率** | 低频（季度/按需） | 中高频（每任务令可能 0-N 次） |
| **JC 分量** | JC_macro | JC_phro_runtime |
| **不可委托性** | 部分 JP 不可委托（JP-001/003/005/010） | 均不可委托（所有 Phronesis 判断由人做出） |

当策元生命周期的 JP 触发条件与任务执行级 P1-P5 条件同时满足时（例如：PCP amend → JP-008 触发 + 动作为写回→P1 触发），JP 优先——JC 仅计一次（归入 JP 分量即 JC_macro），避免重复计数。

介入协议定义从决断点触发到人类判断执行完毕的完整流程。MVP 版本采用**同步模式**：Agent 调用 `judgment_request` 后立即通过对话通道请求用户做出判断。

### 2.2 介入流程

```
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│  事件检测     │───▶│ 决断点匹配    │───▶│ 上下文生成    │
│  (Event      │    │ (JP Matching) │    │ (Context     │
│   Detection) │    │               │    │  Generation) │
└──────────────┘    └──────────────┘    └──────┬───────┘
                                                │
┌──────────────┐    ┌──────────────┐    ┌──────▼───────┐
│  级联更新     │◀───│ 决断追踪记录  │◀───│ 呈现给人      │
│  (Cascade    │    │ (Judgment    │    │ (Present to  │
│   Update)    │    │  Trace)      │    │  Human)      │
└──────────────┘    └──────────────┘    └──────┬───────┘
                                                │
                                        ┌──────▼───────┐
                                        │ 人做出判断    │
                                        │ (Human       │
                                        │  Decides)    │
                                        └──────┬───────┘
                                                │
                                        ┌──────▼───────┐
                                        │ Ed25519 签名  │
                                        │ (Sign)       │
                                        └──────────────┘
```

### 2.3 各阶段详细说明

#### 阶段一：事件检测 (Event Detection)

协作层事件总线持续监听以下事件类型：

| 事件类型 | 监听源 | 触发频率 |
|---------|--------|:------:|
| `ICP_COMPLETED` | 意图聚结协议 | 低频（每次 ICP 完成） |
| `DAG_GENERATED` | 策元层 DAG 路由 | 中频 |
| `PEER_SYNC_COMPLETED` | PEER 验证协议 | 高频 |
| `FORK_REQUESTED` | 弹性分叉协议 | 低频 |
| `SECURITY_ALERT` | 安全审计系统 | 按需 |
| `RECALIBRATION_DUE` | 季度定时器 | 每 13 周 |
| `PCP_AMENDMENT_PROPOSED` | PCP 治理 | 低频 |
| `ALP_THRESHOLD_BREACHED` | ALP 监控 | 按需 |
| `DISSOLUTION_CONDITION_MET` | 策元层生命周期 | 极低频 |

#### 阶段二：决断点匹配 (JP Matching)

事件检测到后，决断点匹配引擎执行：

```
function match_judgment_point(event):
  for jp in [JP-001 .. JP-010] + custom_jps:
    if jp.trigger_condition.satisfied_by(event):
      if not jp.already_active():    // 防止重复触发
        return jp
  return null  // 无需人类介入
```

#### 阶段三：决断上下文生成 (Context Generation)

协议层自动聚合决断所需的完整上下文：

```json
{
  "judgment_request_id": "jr_uuid_v7",
  "jp_id": "JP-001",
  "genesis_id": "gu_x9y8z7w6",
  "trigger_event": {
    "type": "ICP_COMPLETED",
    "timestamp": "2026-05-27T07:22:00Z",
    "event_id": "evt_..."
  },
  "context": {
    "summary": "意图聚结完成，3 名成员 sim ≥ 0.75，准备策元结晶",
    "detailed_data": { "...": "..." },
    "options": [
      {"id": "APPROVE", "label": "批准结晶", "consequence": "创建策元 gu_new"},
      {"id": "MODIFY", "label": "修改方向向量", "consequence": "重新 ICP"},
      {"id": "REJECT", "label": "拒绝结晶", "consequence": "成员返回意图池"}
    ],
    "recommendation": {
      "option": "APPROVE",
      "confidence": 0.87,
      "rationale": "sim 平均 0.82，成员方向一致性高"
    }
  },
  "timeout": {
    "deadline": "2026-05-30T07:22:00Z",
    "on_timeout": "ESCALATED",
    "escalation_target": "genesis_core"
  },
  "signature_requirements": {
    "required_signers": ["ns_initiator"],
    "min_cosigners": 1
  }
}
```

#### 阶段四：呈现给人 (Present to Human)

**同步模式 (MVP)**：Agent 调用 `conc_judgment_request` 后，决断上下文通过对话通道直接呈现给关联的 One（自然人）。呈现格式包含：

1. **决断摘要**：一到两句话说明当前需要什么判断
2. **关键背景**：当前策元状态、触发原因
3. **可选选项**：每个选项的后果预览
4. **Agent 推荐**：Sophia 层的计算建议（附置信度）
5. **超时提醒**：距超时还有多长时间

#### 阶段五：人做出判断 + Ed25519 签名

用户选择选项（或输入自定义判断）后，Agent 构造签名载荷：

```
signature_payload = sha256(
  jp_id || genesis_id || selected_option || timestamp || nonce
)
signature = ed25519_sign(human_private_key, signature_payload)
```

Agent 调用 `conc_judgment_respond` 提交签名后的判断。

#### 阶段六：决断追踪记录 (Judgment Trace)

协议层验证签名后将判断写入决断追踪哈希链（详见第四章）。

#### 阶段七：级联状态更新 (Cascade Update)

判断生效后，协议层执行级联状态更新：

| 决断点 | 级联效果 |
|--------|---------|
| JP-001 APPROVE | 触发策元结晶 → 创建 GU 节点 → 广播 GENESIS_CREATED |
| JP-001 REJECT | 解散 ICP → 成员状态回归 `intent_pool` |
| JP-002 APPROVE | DAG 状态 → BROADCAST → 任务令进入分配阶段 |
| JP-003 BLOCK | 任务令状态 → BLOCKED_BY_SECURITY |
| JP-004 REBALANCE | 软分叉算力重新分配 → 触发 `fork_rebalance` 事件 |
| JP-005 VETO_DEPLOY | 部署管道暂停 → 所有相关任务令状态冻结 |
| JP-010 DISSOLVE | 触发 PCP 解散程序 → VT 清算 → IP 归属分配 |

### 2.4 超时处理策略

| 超时时长 | 决断点 | 默认行为 |
|:------:|--------|---------|
| 12h | JP-009 (ALP 熔断) | `ACTIVATE_BREAKER` — 安全优先 |
| 24h | JP-003 (安全决策) | `BLOCK` — 安全默认阻塞 |
| 48h | JP-002 (DAG 确认) | 按复杂度分流：低复杂度 `AUTO_APPROVE`，高复杂度 `ESCALATED` |
| 72h | JP-001 (方向确认)、JP-004 (资源分配)、JP-005 否决后审计 | `ESCALATED` → 策元核接管 |
| 168h | JP-006 (方向重校准)、JP-007 (成员准入)、JP-008 (PCP 修正) | 保守默认（维持现状/试用接纳/延期） |
| 336h | JP-010 (分裂/解散) | `ADMINISTRATIVE_DISSOLUTION` |

**ESCALATED 状态的后续处理**：

```
ESCALATED → 策元核接管
  ├── 策元核 48h 内做出判断 → 正常记录决断追踪
  └── 策元核亦超时 → CRITICAL_ESCALATION
        ├── JP-001/JP-010 → 自动执行解散协议
        └── 其他 JP → 系统默认选项生效 + 策元标记为 GOVERNANCE_WARNING
```

---

## 三、加力类型 (Amplification Types)

### 3.1 概念

人在决断点做出的判断不是简单的"批准/拒绝"——而是对 Agent 执行结果的**方向性加力 (Amplification)**。加力的本质是：将人基于 Phronesis（实践智慧）的方向性信号注入 Sophia 层的自动化执行流程。

### 3.2 四种加力类型

#### 3.2.1 方向加力 (Direction Amplification)

**定义**：调整策元的方向向量 (direction_vector)，改变 Agent 后续执行的方向偏好。

**触发决断点**：JP-001 (方向确认)、JP-006 (方向重校准)

**作用机制**：

```
新方向向量 = 旧方向向量 + λ_direction · (人的判断向量 - 旧方向向量)
```

其中 `λ_direction ∈ [0, 1]` 为加力强度系数，由决断类型决定：

| 决断选项 | λ_direction |
|---------|:----------:|
| APPROVE / KEEP_DIRECTION | 0.0（不加力，维持 Agent 计算结果） |
| MODIFY / ADJUST_VECTOR | 0.3 ~ 0.7（部分加力，与 Agent 方向混合） |
| 硬分叉方向确立 | 1.0（完全加力，以人的判断为准） |

**影响范围**：
- 后续 ICP 匹配的 sim 计算基准
- 任务令 DAG 优先级排序
- 弹性分叉的算力分配权重

#### 3.2.2 资源加力 (Resource Amplification)

**定义**：调整 VT/NR 分配权重，改变资源在不同分支或任务令间的流动方向。

**触发决断点**：JP-004 (资源分配)、JP-009 (ALP 熔断)

**作用机制**：

```
R_new(i) = R_current(i) · (1 + λ_resource · Δ_human(i))
```

| 参数 | 含义 |
|------|------|
| `R_new(i)` | 调整后资源 i 的分配比例 |
| `R_current(i)` | 当前资源分配比例 |
| `λ_resource` | 资源加力强度 [0, 2] |
| `Δ_human(i)` | 人的调整信号 [-1, 1] |

**应用场景**：
- 软分叉算力重分配（α_A 调整）
- VT 激励权重倾斜（向关键任务令增加激励）
- NR 转移税率调整
- ALP 保险池资金调配

#### 3.2.3 优先级加力 (Priority Amplification)

**定义**：调整任务令 DAG 的执行顺序，使 Agent 的自动化调度服从人的优先级判断。

**触发决断点**：JP-002 (DAG 确认)

**作用机制**：

Agent 计算的默认优先级：

```
p_agent(i) = f(depends_on_depth, estimated_vt, nr_weighted_demand)
```

人介入后的加力优先级：

```
p_final(i) = p_agent(i) · (1 + λ_priority · δ_human(i))
```

其中 `δ_human(i) ∈ [-0.5, 0.5]` 为人的优先级微调信号。

**加力效果**：
- `REORDER`：重排任务令在 DAG 拓扑约束内的执行次序
- `ADD_DEPENDENCY`：注入新的依赖关系 → 强制序列化
- `SPLIT_TASK`：拆分过大任务令 → 并行化

#### 3.2.4 协同加力 (Synergy Amplification)

**定义**：触发跨策元协作，将人的网络判断注入 Agent 的局部优化。

**触发决断点**：JP-007 (成员准入)、JP-010 (合并决策)

**作用机制**：

```
synergy_score(A, B) = sim(direction_A, direction_B) · complementarity(A.skills, B.skills) · (1 + λ_synergy · human_trust(A, B))
```

| 因子 | 含义 | 来源 |
|------|------|------|
| `sim(direction_A, direction_B)` | 方向相似度 | ICP 协议计算 |
| `complementarity(...)` | 技能互补度 | CSIP 能证体系 |
| `human_trust(A, B)` | 人判断的协同信任 | 人的决断输入 |

**应用场景**：
- `SEEK_MERGER` (JP-010)：启动策元合并，利用人的网络认知发现协同机会
- 跨策元协作邀请：人判断两个策元应该协作 → 触发跨策元任务令共享

### 3.3 加力强度上限

为防止单次加力过度扰动系统，协议层设置加力强度上限：

| 加力类型 | 单次最大 λ | 季度累计最大 λ |
|---------|:--------:|:-----------:|
| 方向加力 | 1.0 | 2.0 |
| 资源加力 | 2.0 | 4.0 |
| 优先级加力 | 0.5 | 1.5 |
| 协同加力 | 1.0 | 3.0 |

超过季度上限的加力请求将被协议层拒绝（返回 `AMPLIFICATION_QUOTA_EXCEEDED`），需在下季度重校准后释放配额。

---

## 四、决断追踪 (Judgment Trace)

### 4.1 概述

决断追踪 (Judgment Trace) 是记录每次人类判断行为的不可篡改哈希链。每条追踪记录通过 Ed25519 签名确保不可否认性，通过哈希链确保完整性。

### 4.2 数据模型

#### 4.2.1 单条决断追踪记录

```json
{
  "trace_id": "jt_uuid_v7",
  "sequence_number": 42,
  "previous_hash": "sha256:abc123...",
  "jp_id": "JP-001",
  "genesis_id": "gu_x9y8z7w6",
  "judge_ns_id": "ns_alice_001",
  "judgment": {
    "selected_option": "APPROVE",
    "custom_input": "方向向量维持，但建议增加教育游戏化权重",
    "amplification": {
      "type": "DIRECTION",
      "lambda": 0.5,
      "delta_vector": [0.0, 0.05, -0.03, 0.0, 0.0]
    }
  },
  "context_hash": "sha256:def456...",
  "timestamp": "2026-05-27T08:15:00Z",
  "nonce": "random_128bit_hex",
  "signature": "ed25519:base58_encoded_signature...",
  "cosigners": [
    {
      "ns_id": "ns_bob_002",
      "signature": "ed25519:base58_encoded_co_signature..."
    }
  ],
  "hash": "sha256:ghi789..."
}
```

#### 4.2.2 字段说明

| 字段 | 类型 | 说明 |
|------|------|------|
| `trace_id` | UUID v7 | 追踪记录全局唯一 ID |
| `sequence_number` | uint64 | 该智权体的决断序列号（单调递增） |
| `previous_hash` | sha256 | 上一条追踪记录的哈希——构成哈希链 |
| `jp_id` | string | 触发的决断点编号 |
| `genesis_id` | string | 所属策元 ID |
| `judge_ns_id` | string | 做出判断的智权体 ns_id |
| `judgment.selected_option` | string | 选择的决断选项 |
| `judgment.custom_input` | string | 人的自定义输入（可选） |
| `judgment.amplification` | object | 加力参数（类型、强度、方向增量） |
| `context_hash` | sha256 | 决断上下文的哈希（用于事后审计验证） |
| `timestamp` | ISO 8601 | 判断时间戳 |
| `nonce` | hex | 防重放随机数 |
| `signature` | ed25519 | 判断人的 Ed25519 签名 |
| `cosigners` | array | 共签人列表（按决断点要求） |
| `hash` | sha256 | 本条记录的哈希 = sha256(previous_hash \|\| 所有字段 \|\| signature) |

### 4.3 哈希链构建

```
trace_0:  hash_0  = sha256(genesis_hash || judge_ns_id || "CHAIN_INIT" || timestamp_0 || nonce_0 || sig_0)
trace_1:  hash_1  = sha256(hash_0 || jp_id_1 || option_1 || timestamp_1 || nonce_1 || sig_1)
trace_2:  hash_2  = sha256(hash_1 || jp_id_2 || option_2 || timestamp_2 || nonce_2 || sig_2)
...
trace_n:  hash_n  = sha256(hash_{n-1} || jp_id_n || option_n || timestamp_n || nonce_n || sig_n)
```

**哈希链的不可篡改性**：修改任意一条追踪记录将导致所有后续记录的哈希值不匹配，从而被审计系统检测。

### 4.4 签名验证

协议层在记录决断追踪前执行以下验证：

```
function verify_judgment_trace(trace):
  // 1. 验证 Ed25519 签名
  payload = sha256(
    trace.jp_id || trace.genesis_id || trace.judgment.selected_option ||
    trace.timestamp || trace.nonce
  )
  if not ed25519_verify(judge_public_key, payload, trace.signature):
    return ERROR("INVALID_SIGNATURE")
  
  // 2. 验证哈希链连续性
  expected_prev_hash = get_last_trace_hash(trace.judge_ns_id)
  if trace.previous_hash != expected_prev_hash:
    return ERROR("CHAIN_BROKEN")
  
  // 3. 验证序列号单调递增
  if trace.sequence_number != expected_prev_seq + 1:
    return ERROR("SEQUENCE_GAP")
  
  // 4. 验证共签人
  for cosigner in trace.cosigners:
    if not ed25519_verify(cosigner.public_key, payload, cosigner.signature):
      return ERROR("INVALID_COSIGNER_SIGNATURE")
  
  // 5. 验证决断点权限
  if not authorized_for_jp(trace.judge_ns_id, trace.jp_id, trace.genesis_id):
    return ERROR("UNAUTHORIZED_JUDGMENT")
  
  return OK
```

### 4.5 决断追踪的 GHF 审计集成

决断追踪哈希链纳入全局哈希森林 (Global Hash Forest, GHF) 的审计范围：

```
GHF 审计周期:
  每 24h → 扫描全部活跃策元的决断追踪链
    ├── 检测哈希链断裂 → 标记 TAMPERED → 触发安全告警
    ├── 检测超时未决断 → 标记 OVERDUE → 触发升级
    └── 检测签名异常 → 标记 ANOMALOUS → 触发人工审计
```

### 4.6 API 端点

```
GET /judgment-trace/{ns_id}
  获取指定智权体的完整决断追踪链

GET /judgment-trace/{ns_id}/{sequence_number}
  获取指定序列号的单条追踪记录

GET /judgment-trace/{genesis_id}/recent?limit=50
  获取策元内最近的决断追踪记录

POST /judgment-trace/verify
  验证指定追踪记录的完整性和签名有效性
  INPUT: { "trace_id": "jt_...", "full_chain_from_genesis": bool }
```

---

## 五、Judgment Credit (JC) 体系 **[v2.0 对齐 15 协议四分量]**

> **权威定义**：JC 的完整公式、四分量分解、每个分量的触发条件与防博弈设计，定义于 `15_Direction_Profile_and_Judgment_Credit.md` v2.0 §三。本节提供决断层视角的**摘要引用**——不重复 15 协议的完整细节。

### 5.1 四分量合成

JC(n) = α¹ · JC_macro + α² · JC_phro_runtime + α³ · JC_continuous + α⁴ · JC_design

默认权重：0.35 / 0.30 / 0.20 / 0.15（PCP 可调，Σα=1.0）。

| 分量 | 来源（本协议的对应机制） | JC 计分方式 |
|------|---------------------|-----------|
| **JC_macro** | JP-001~010 的决断（§一） | PEER ≥3 人评分取中位数（outcome · difficulty · uniqueness） |
| **JC_phro_runtime** | P1-P5 触发域的人工判断（§1.4） | PEER 回溯验证 + GHF 事件 PHRO_JUDGMENT |
| **JC_continuous** | phronesis_profile = "continuous" 的任务令完成 | PEER_SYNC 综合评分（方向一致性 + 迭代效率） |
| **JC_design** | 任务令设计者的 phronesis_profile 分类校准度 | CAR 对齐率（MISCLASSIFIED / TOTAL）+ 三辅助因子 |

### 5.2 决断层特有的 JC 记录

**JC_macro** 记录：决断点 JP-001~010 每次判断后进入 OBSERVING 观察期（时长由 JP 类型预设），PEER ≥3 人评分取中位数。详细流程见 §5.3（outcome/difficulty/uniqueness 评分标准——保留自 v1.0 不变，适用于 JC_macro 分量）。

**JC_phro_runtime** 记录：P1-P5 触发的每次人工判断写入 GHF 事件 `PHRO_JUDGMENT`（数据模型见 §8.5）。outcome 在任务令完成后的 PEER 评审中回溯赋值。每日 cap N_max=5。

**JC_continuous 和 JC_design** 的计分逻辑见 15 协议 v2.0 §3.4-3.5——决断层仅触发对应的 GHF 事件（`TASK_WARRANT_DESIGNED` / `TASK_DESIGN_AUDIT` / `PEER_SYNC_SCORED`），具体公式由 15 协议计算。

### 5.3 决策点识别标准（保留自 v1.0 — 适用于 JC_macro）

三重过滤：不可逆性 (Irreversibility)、信息不完备性 (Information Incompleteness，<70%)、多主体分歧 (≥2 名成员不同意见，链上记录)。P1-P5 的触发条件 (§1.4) 是三重过滤在任务执行级的工程化映射。

### 5.4 JC 的协议层影响（保留 + 扩展）

| 协议机制 | JC 的影响 (v2.0) |
|---------|----------------|
| **策元核推选** | `core_election_weight = NR^{0.25} · JC_macro^{0.30} · JC_design^{0.20} · commitment^{0.25}` |
| **决断点权重** | 高 JC 者在 JP-004/JP-006/JP-008 中有更高投票权重（基于 JC_macro） |
| **PEER 评审资格** | JC_macro ≥ 阈值者方可参与 outcome 评审 |
| **安全官资格** | JC_macro ≥ 安全阈值 + 策元核全票任命 |
| **ICP 匹配加分** | JC_macro + JC_design 加权参与 direction 维度匹配 |
| **任务令设计权** | JC_design < 0 的设计者其新任务令的 phronesis_profile 需策元核预先审核（PCP 可选——冷制裁） |

### 5.5 JC 衰减机制（保留 + 扩展）

| 衰减触发条件 | 影响分量 | 幅度 |
|------------|:---:|:---:|
| 连续 6 个月未做出任何 JC 记录决策 | JC_macro | 每月 -5% |
| 连续 3 次决策 outcome ≤ 0 | JC_macro | 额外 -10% |
| 策元解散且 3 个月未加入新策元 | JC_macro | 每月 -3% |
| 主动声明退出决断角色 | 全部 JC | 冻结（不增不减） |

JC_phro_runtime、JC_continuous、JC_design 已锁定于 GHF 事件——不因时间衰减。

---

## 五-A、GovernedAction 原语与 Action Gate **[v2.0 新增]**

> **理论溯源**：PBA 定理层（二元域切割）→ Action Gate 是 Sophia↔Phronesis 边界在协议层的运行时判定——将 PBA 的「是否存在 ground-truth 反馈信号」转化为可执行的 `should_escalate_to_phronesis()` 函数。

### 5-A.1 GovernedAction 数据模型

```json
{
  "action_id": "ga_uuid_v7",
  "task_warrant_id": "tw_...",
  "genesis_id": "gu_...",
  "agent_ns_id": "ns_...",
  "action_type": "file_write" | "api_call" | "external_comm" | "financial_tx" | "deploy" | "member_change" | "pcp_amend" | "generic",
  "target_resource": "file_path / api_endpoint / genesis_id / ...",
  "clearance_level": "C0" | "C1" | "C2",
  "irreversibility_score": 0.85,
  "agent_confidence": 0.72,
  "info_completeness": 0.65,
  "disagreement_signal": 0.1,
  "novelty_score": 0.4,
  "staged_result_hash": "sha256:...",
  "timestamp": "ISO8601"
}
```

**四环 Clearance 模型**（借鉴 Tiwari MSFT Agent Governance Toolkit）：

| 环 | 级别 | 允许操作 | 触发 Phronesis? |
|:---:|:---:|------|:---:|
| Ring 0 | C0 | 只读——查询、检索、读取状态 | 否（Sophia Zone S3） |
| Ring 1 | C1 | 沙箱写回——Git commit/PR/工作区文件修改 | 否（Sophia Zone S3，除非不可逆 P1） |
| Ring 2 | C2 | 内部系统写回——数据库更新/配置变更/策元成员变更 | **是**（P2 越权触发） |
| Ring 3 | C3 | 外部系统写回——生产部署/API 外部调用/金融交易 | **是**（P1 不可逆 + P2 越权） |

Agent 的默认自治阈值为 Ring 1 (C1)。策元 PCP 可为特定高 NR/JC 智权体提升自治阈值。

### 5-A.2 should_escalate_to_phronesis 判定函数

```python
def should_escalate_to_phronesis(action: GovernedAction) -> tuple[bool, str, str]:
    """
    返回: (should_escalate, matched_domain, reason)
    在每次 Agent 动作执行前由协议层调用。判定时间 < 0.1ms（确定性规则）。
    """
    # P1: 不可逆动作
    if action.irreversibility_score > τ_irrev:                         # 默认 τ_irrev = 0.6
        return (True, "P1", f"irreversibility={action.irreversibility_score:.2f} > τ={τ_irrev}")

    # P2: 过度代理 / 越权
    if clearance_level_to_ring(action.clearance_level) > agent.auto_threshold_ring:  # 默认 auto=C1
        return (True, "P2", f"clearance={action.clearance_level} > auto_threshold=C1")

    # P3: 价值/方向判断（Agent 不自信且涉及价值取舍）
    if action.agent_confidence < τ_conf and action.involves_value_tradeoff:  # 默认 τ_conf = 0.75
        return (True, "P3", f"confidence={action.agent_confidence:.2f} < τ={τ_conf}")

    # P4: 多主体分歧
    if action.disagreement_signal > τ_disagree:                          # 默认 τ_disagree = 1.5σ
        return (True, "P4", f"disagreement={action.disagreement_signal:.2f} > τ={τ_disagree}")

    # P5: 新颖性 / 歧义
    if action.novelty_score > τ_novel:                                   # 默认 τ_novel = 0.5
        return (True, "P5", f"novelty={action.novelty_score:.2f} > τ={τ_novel}")
    if action.info_completeness < 0.7:
        return (True, "P5", f"info_completeness={action.info_completeness:.2f} < 0.70")

    # Sophia Zone: 自动执行
    return (False, "SOPHIA", "")
```

### 5-A.3 Action Gate 在协议栈中的位置

```
Sophia 层 (Agent 民主执行)
    │
    ▼
┌──────────────────────────────────────────────────┐
│              Action Gate                         │
│                                                  │
│  GovernedAction 构造 (risk_score, confidence,    │
│    irreversibility, clearance_level 自动标定)     │
│                    │                             │
│    should_escalate_to_phronesis(action)          │
│           │                 │                    │
│      FALSE              TRUE                     │
│        │                   │                     │
│   自动提交              JUDGMENT_REQUEST          │
│   → GHF                 → Phronesis 层            │
│   (SOPHIA_ACTION)       (人工判断 → JT)           │
└──────────────────────────────────────────────────┘
```

### 5-A.4 GHF 事件映射

| 判定结果 | GHF 事件类型 | 数据内容 |
|---------|-----------|---------|
| SOPHIA (自动) | `SOPHIA_ACTION` | action_id, action_type, clearance_level, matched_domain=S1-S4 |
| P1-P5 (人工) | `PHRO_JUDGMENT` | action_id, matched_domain, staged_result_hash, escalation_reason |
| 人工判断完成 | `JUDGMENT_RESPONSE` | trace_id, selected_option, judge_ns_id, Ed25519 签名 |

### 5-A.5 τ 阈值治理

所有 τ 阈值（τ_irrev、τ_conf、τ_disagree、τ_novel）在 PCP 中设定默认值。策元核可在 JP-008 (PCP 修正) 中修改。修改需全策元成员表决（> 50%）。历史 τ 变更记录写入 GHF。动态调整（B3.1 评测管道）的规则上限：每次自动调整不超过 ±0.1，每季度不超过 3 次自动调整。评测管道设计见 `11_Discuss/CONC_Sophia_Phronesis_Boundary_Engineering_v1.0.md` §三 B3.1。

---

## 六、API 端点定义

### 6.1 conc_judgment_request

```
POST /phronesis/judgment/request
  协议层自动调用。Agent 不应手动调用此端点。

  Request:
    {
      "jp_id": "JP-001",
      "genesis_id": "gu_x9y8z7w6",
      "trigger_event_id": "evt_...",
      "context": {
        "summary": "...",
        "detailed_data": { "...": "..." },
        "options": [
          {"id": "APPROVE", "label": "...", "consequence": "..."}
        ],
        "recommendation": {
          "option": "APPROVE",
          "confidence": 0.87,
          "rationale": "..."
        }
      },
      "timeout_hours": 72,
      "required_signers": ["ns_initiator"],
      "min_cosigners": 1
    }

  Response:
    {
      "judgment_request_id": "jr_uuid_v7",
      "status": "AWAITING_HUMAN",
      "deadline": "2026-05-30T07:22:00Z",
      "escalation_path": {
        "on_timeout": "ESCALATED",
        "target": "genesis_core"
      }
    }

  Errors:
    409 JP_ALREADY_ACTIVE      — 该决断点已有活跃的决断请求
    400 INVALID_JP_ID          — 决断点 ID 不存在
    403 UNAUTHORIZED_TRIGGER   — 触发事件的来源未获授权
```

### 6.2 conc_judgment_respond

```
POST /phronesis/judgment/respond
  由人在对话通道中做出判断后，Agent 代理调用。

  Request:
    {
      "judgment_request_id": "jr_uuid_v7",
      "selected_option": "APPROVE",
      "custom_input": "方向向量维持，但建议增加教育游戏化权重",
      "amplification": {
        "type": "DIRECTION",
        "lambda": 0.5,
        "delta_vector": [0.0, 0.05, -0.03, 0.0, 0.0]
      },
      "timestamp": "2026-05-27T08:15:00Z",
      "nonce": "random_128bit_hex",
      "signature": "ed25519:base58_encoded_signature...",
      "cosigners": [
        {
          "ns_id": "ns_bob_002",
          "signature": "ed25519:base58_encoded_co_signature..."
        }
      ]
    }

  Response:
    {
      "judgment_request_id": "jr_uuid_v7",
      "trace_id": "jt_uuid_v7",
      "status": "EXECUTED",
      "cascade_effects": [
        {"type": "GENESIS_CREATED", "genesis_id": "gu_new_001"},
        {"type": "ICP_COMPLETED_ARCHIVED", "icp_id": "icb_001"}
      ],
      "jc_update": {
        "decision_recorded": true,
        "outcome_pending_observation_period_days": 90
      }
    }

  Errors:
    400 INVALID_SIGNATURE       — Ed25519 签名验证失败
    400 CHAIN_BROKEN            — 决断追踪哈希链断裂
    409 JUDGMENT_ALREADY_MADE   — 该决断请求已被响应
    408 JUDGMENT_TIMED_OUT      — 决断请求已超时
    403 UNAUTHORIZED_JUDGE      — 签名人不具有该决断点的判断权限
    429 AMPLIFICATION_QUOTA_EXCEEDED — 加力配额超限
```

### 6.3 judgment_trace_query

```
GET /phronesis/judgment-trace/{ns_id}
  INPUT:  ns_id, optional: { from_sequence, limit }
  OUTPUT: trace_chain[{trace_id, sequence_number, jp_id, selected_option, timestamp, hash}]

GET /phronesis/judgment-trace/{genesis_id}/recent
  INPUT:  genesis_id, optional: { limit (default 50), jp_id_filter }
  OUTPUT: recent_traces[]

POST /phronesis/judgment-trace/verify
  INPUT:  { trace_id, full_chain_from_genesis (bool) }
  OUTPUT: { valid: bool, chain_breaks: [], signature_valid: bool }
```

### 6.4 judgment_credit_query

```
GET /phronesis/jc/{ns_id}
  INPUT:  ns_id
  OUTPUT: {
    jc_score: float,
    decision_count: int,
    recent_outcomes: [{decision_id, outcome, difficulty, timestamp}],
    jc_rank_in_genesis: int,
    eligibility: {
      security_officer: bool,
      peer_reviewer: bool,
      core_candidate: bool
    }
  }

GET /phronesis/jc/{ns_id}/history
  INPUT:  ns_id, optional: { from_date, to_date }
  OUTPUT: decision_history[{decision_id, jp_id, outcome, difficulty, uniqueness, jc_delta, timestamp}]
```

### 6.5 amplification_quota

```
GET /phronesis/amplification-quota/{ns_id}/{genesis_id}
  INPUT:  ns_id, genesis_id
  OUTPUT: {
    quotas: {
      direction: { used: 0.8, limit: 2.0, remaining: 1.2 },
      resource:  { used: 1.5, limit: 4.0, remaining: 2.5 },
      priority:  { used: 0.3, limit: 1.5, remaining: 1.2 },
      synergy:   { used: 0.0, limit: 3.0, remaining: 3.0 }
    },
    next_reset: "2026-08-01T00:00:00Z"
  }
```

### 6.6 judgment_point_registry

```
GET /phronesis/judgment-points/{genesis_id}
  INPUT:  genesis_id
  OUTPUT: {
    built_in: [JP-001..JP-010 的完整定义],
    custom: [策元自定义 JP-011+ 的完整定义]
  }

POST /phronesis/judgment-points/{genesis_id}/register
  注册策元自定义决断点
  INPUT:  custom_jp_definition (遵循 §1.3 Schema)
  OUTPUT: { jp_id: "JP-011", status: "REGISTERED" }
  AUTH: 需策元核 Ed25519 签名 (≥ 2/3 成员)
```

---

## 七、状态机

### 7.1 决断请求生命周期

```
                    ┌──────────┐
                    │  IDLE    │
                    └────┬─────┘
                         │ 事件触发 + JP 匹配
                    ┌────▼─────┐
                    │ PENDING  │ ← 决断请求已生成，上下文已聚合
                    └────┬─────┘
                         │
              ┌──────────┼──────────┐
              │          │          │
         (人响应)    (超时)     (事件取消)
              │          │          │
    ┌─────────▼──┐  ┌───▼──────┐  ┌▼──────────┐
    │  SIGNED    │  │ESCALATED │  │ CANCELLED  │
    └─────┬──────┘  └───┬──────┘  └────────────┘
          │              │
    ┌─────▼──────┐  ┌───▼──────────┐
    │  EXECUTED  │  │ 接管方响应/超时 │
    └─────┬──────┘  └───┬──────────┘
          │              │
    ┌─────▼──────┐  ┌───▼──────────┐
    │  OBSERVING │  │ RESOLVED     │
    │ (JC观察期) │  │ (默认选项)    │
    └─────┬──────┘  └──────────────┘
          │
    ┌─────▼──────┐
    │  SCORED    │ ← PEER 完成 outcome 评分
    └────────────┘
```

### 7.2 策元决断健康状态

```
决断健康状态 = f(超时率, 否决率, JC 趋势):

  HEALTHY:
    超时率 < 10% 且 否决率 < 20% 且 JC 均值上升

  WARNING:
    超时率 ∈ [10%, 30%) 或 否决率 ∈ [20%, 40%)

  DEGRADED:
    超时率 ∈ [30%, 50%) 或 否决率 ∈ [40%, 60%)

  GOVERNANCE_CRISIS:
    超时率 ≥ 50% 或 否决率 ≥ 60% 或 连续 3 个决断点超时升级至 CRITICAL_ESCALATION
    → 自动触发策元健康审计 → 建议启动 JP-010 讨论
```

---

## 八、数据模型总览

### 8.1 决断点定义 (JudgmentPoint)

```json
{
  "jp_id": "JP-001",
  "name": "Genesis Direction Confirmation",
  "category": "DIRECTION",
  "trigger": {
    "event_type": "ICP_COMPLETED",
    "condition": "intent_coalescence.status == 'COMPLETED' AND similarity_score >= theta"
  },
  "context_schema": { "...": "..." },
  "options": ["APPROVE", "MODIFY", "REJECT"],
  "timeout": { "hours": 72, "on_timeout": "ESCALATED" },
  "signature": {
    "required_signers": "initiator",
    "min_cosigners": 1,
    "cosigner_eligible_roles": ["genesis_member"]
  },
  "non_delegable": true,
  "jc_eligible": true,
  "observation_period_days": 90,
  "amplification_type": "DIRECTION"
}
```

### 8.2 决断请求 (JudgmentRequest)

```json
{
  "judgment_request_id": "jr_uuid_v7",
  "jp_id": "JP-001",
  "genesis_id": "gu_x9y8z7w6",
  "status": "AWAITING_HUMAN",
  "context": { "...": "..." },
  "deadline": "ISO8601",
  "escalation_path": { "on_timeout": "ESCALATED", "target": "genesis_core" },
  "created_at": "ISO8601",
  "created_by": "system | ns_id"
}
```

### 8.3 决断追踪 (JudgmentTrace)

```json
{
  "trace_id": "jt_uuid_v7",
  "sequence_number": 42,
  "previous_hash": "sha256:...",
  "jp_id": "JP-001",
  "genesis_id": "gu_x9y8z7w6",
  "judge_ns_id": "ns_alice_001",
  "judgment": {
    "selected_option": "APPROVE",
    "custom_input": "...",
    "amplification": { "type": "DIRECTION", "lambda": 0.5, "delta_vector": [...] }
  },
  "context_hash": "sha256:...",
  "timestamp": "ISO8601",
  "nonce": "hex",
  "signature": "ed25519:...",
  "cosigners": [{ "ns_id": "...", "signature": "ed25519:..." }],
  "hash": "sha256:..."
}
```

### 8.4 Judgment Credit 记录

```json
{
  "jc_record_id": "jcr_uuid_v7",
  "trace_id": "jt_uuid_v7",
  "ns_id": "ns_alice_001",
  "jp_id": "JP-001",
  "outcome": 0.5,
  "difficulty": 3.2,
  "uniqueness": 2,
  "jc_delta": 3.2,
  "observation_period_start": "ISO8601",
  "observation_period_end": "ISO8601",
  "scored_by": ["ns_bob_002", "ns_carol_003", "ns_dave_004"],
  "score_variance": 0.15,
  "timestamp": "ISO8601"
}
```

---

## 九、安全与防博弈设计

### 9.1 攻击向量与防御

| 攻击向量 | 防御机制 |
|---------|---------|
| **伪造决断签名** | Ed25519 签名验证 + 哈希链不可篡改性 |
| **超时不决断瘫痪策元** | 分层超时策略 → ESCALATED → 默认选项生效 |
| **恶意否决循环** | 否决需安全审计报告支撑；无报告 72h 后自动解除 |
| **刷 JC 评分** | 三重过滤条件 (不可逆/不完备/多分歧)；PEER ≥ 3 人评分取中位数 |
| **加力配额滥用** | 季度加力上限 + AMPLIFICATION_QUOTA_EXCEEDED 拒绝 |
| **共签人合谋** | 共签人不可与判断人同属一个策元核（若策元规模 ≥ 5） |
| **JC 自我虚报** | outcome 由 PEER 评审判定，非自评 |
| **哈希链回滚攻击** | GHF 24h 定时审计 + 多节点交叉验证 |
| **决断点注册滥用** | 自定义 JP 需策元核 ≥ 2/3 同意；最多注册 10 个自定义 JP |
| **观察期操纵** | 观察期由 JP 类型预设，不可人为缩短 |

### 9.2 治理边界

| 治理对象 | 谁可以修改 | 修改门槛 |
|---------|----------|:------:|
| 协议内置 JP (001~010) | 协议升级 (CONC-Protocol/Phronesis.2.0) | 全网共识 |
| 策元自定义 JP (011+) | 策元核 | ≥ 2/3 策元核成员 |
| JP 超时参数 | 策元核 | ≥ 50% 策元核成员 |
| 加力配额上限 | 协议升级 | 全网共识 |
| JC 公式权重 | 协议升级 | 全网共识 |

---

## 十、与协议栈的集成点

| 集成层 | 集成方式 |
|--------|---------|
| **身份层** | 使用智权体 ns_id 标识判断人；Ed25519 公私钥对用于签名 |
| **策元层** | JP 触发与策元生命周期事件绑定；决断结果驱动策元状态变更 |
| **验证层** | PEER 评审用于 JC outcome 判定；安全决策 (JP-003/JP-005) 与 PEER_SYNC 联动 |
| **价值层** | ALP 熔断决策 (JP-009)；资源加力影响 VT/NR 分配 |
| **弹性分叉** | JP-004 算力分配决策；JP-010 硬分叉/合并决策 |
| **CCR 公开账本** | JC 记录纳入 CCR 的特殊贡献类别 |
| **ICP** | JP-001 方向确认在 ICP 完成后触发；方向档案用于决断上下文 |
| **GHF 审计** | 决断追踪哈希链纳入全局哈希森林审计范围 |

---

## 十一、版本演进路线

| 版本 | 内容 | 状态 |
|------|------|:--:|
| Phronesis.1.0 | 决断点注册 (JP-001~010)、同步介入协议、四种加力类型、Ed25519 签名链、JC 体系 | 已发布 (2026-05-27) |
| Phronesis.1.1 | 异步介入模式（离线决断队列 + 批量签名）、决断委托链、PBA二元域划分集成、JC行业分类 | 已发布 (2026-07-10) |
| **Phronesis.2.0** | **P1-P5 任务执行级触发域、JC 四分量对齐 (15协议v2.0)、GovernedAction原语与Action Gate、Sophia↔Phronesis运行时判定** | **当前版本 (2026-07-12)** |
| Phronesis.2.1 (规划) | 跨策元决断协调、集体决断协议（多策元联合投票）、AI 辅助决断预览、B3.1反馈→评测管道集成 | 规划中 |

---

*CONC-Protocol/Phronesis.1.0 — Phronesis Layer Protocol Specification — 2026-05-27*
*CONC-Protocol/Phronesis.2.0 — Phronesis Layer Protocol Specification — 2026-07-12*


---
## 十四、Phronesis二元域划分与PBA集成（v1.1 新增 — CONC-P0-1）

> 对应定理PBA1-PBA3和 `02_Models/04_Phronesis_Morphology_Evolution.md`。

生产认知空间被可验证反馈信号的存在性切分为两个不交子空间：
- **Sophia域**（可验证）→ Agent自动化执行
- **Phronesis域**（无ground-truth）→ 必须人类判断——三大结构性天花板（自检盲区/奖励缺失/异常缺口）确保该域永不消去

PBA五个锚定点（PBA-001~005）追踪域边界的动态演化。详参 `01_Protocol_Layer.md` §9.8。

## 十五、JC行业分类与古德哈特防御（v1.1 新增 — CONC-P1-5）

JC计分规则按判断力类型分类：

| 类型 | 行业 | 刷分检测 | 触发条件 |
|:---|:---|:---|:---|
| 安全型 | 制药/航天 | 严格 | 分歧>基线2σ → 自动审计 |
| 权衡型 | 半导体 | 中等 | 分歧>基线1.5σ → 标记 |
| 品味型 | 软件 | 宽松 | 不触发自动审计 |

独立合规策元的对抗性质询记为JC正向贡献（权重×1.5）。

---
*协议版本 v1.0 → v1.1 (2026-07-10)*
*协议版本 v1.1 → v2.0 (2026-07-12) — CONC-P0-2: Sophia↔Phronesis 边界工程化*

## v2.0 更新摘要 (2026-07-12) — CONC-P0-2

- 新增 §1.4：任务执行级 Phronesis 触发域 P1-P5（不可逆/越权/价值/分歧/新颖性）——Harness 逆向分类学工程化映射
- 新增 §1.4.6-1.5：P1-P5 与 Sophia Zone 的边界；与 JP-001~010 的互补关系
- §五 JC 体系对齐 15 协议 v2.0 四分量合成（JC_macro + JC_phro_runtime + JC_continuous + JC_design）
- 新增 §五-A：GovernedAction 原语、四环 Clearance 模型、should_escalate_to_phronesis 判定函数、Action Gate 架构、GHF 事件映射、τ 阈值治理
- 策元核推选公式更新：NR^{0.25} · JC_macro^{0.30} · JC_design^{0.20} · commitment^{0.25}
- 交叉引用：`15_Direction_Profile_and_Judgment_Credit.md` v2.0；`11_Discuss/CONC_Harness_Reverse_Phronesis_Boundary_v2.0.md`；`01_Protocol_Layer.md` v3.0
