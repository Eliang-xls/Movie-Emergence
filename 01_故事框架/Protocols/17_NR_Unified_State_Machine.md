# NR 统一状态机协议规范
## NR Unified State Machine Protocol v2.2

> 协议标识符：`CONC-Protocol/Value.NR_StateMachine.2.2`
> 依赖：公理二（无代币经济）、公理四（模块承诺）、模型三（NR 信号博弈 ESS）、PEER 协议 (05)、CCR 公开账本 (06)、弹性分叉协议 (07)、阶梯式燃烧协议 (08)、能证晋级管道 (16)
> 协议层归属：价值层 (Value Layer) — NR 更新与仲裁
>
> **完备度声明**：本规范将 NR 更新逻辑从 5+ 协议中分散的碎片化规则 整合为单一的状态机协议（完备度 0% → 85%+）。定义 NR 四维结构、多源更新优先级、复合公式、衰减函数、转移税、新入者加速器和审计事件日志。

---

## 〇、协议定位与设计概要

### 0.1 问题诊断：NR 更新的碎片化

在 v1.x 协议体系中，NR（Network Reputation）的更新逻辑分散在至少 5 个独立协议中：

| 来源 | 协议 | 更新维度 | 当前状态 |
|------|------|---------|:---:|
| PEER 评审反馈 | `05_PEER_Verification_Protocol.md` §七 | `NR_reliability` | 已定义——但仅覆盖评审者维度 |
| 阶梯式燃烧 | `08_Tiered_Slashing_Protocol.md` §2 | `Reliability_Score` 衰减 | 已定义——但未与 NR 复合公式对接 |
| CCR 趋势 | `06_CCR_Public_Ledger.md` §1.3 | NR 转移税 τ=0.30 | 已定义——但仅影响 CCR，不写回 NR |
| CP 晋级事件 | `16_Capability_Proof_Promotion_Pipeline.md` | 能证晋级作为 NR 正反馈 | 定义中——无 NR 写入接口 |
| 弹性分叉 | `07_Elastic_Forking_Protocol.md` | 分叉后的 NR 归属与迁移 | 仅概念——无协议规范 |

**核心矛盾**：一个 PEER 评审事件需要同时更新 `NR_reliability`（05 协议）和 `Reliability_Score`（08 协议）。一个燃烧事件需要更新 `NR` 总量（08 协议）但不会通知 PEER 协议重新校准评审权重。这些更新之间**无协调、无优先级、无冲突解决**。

### 0.2 本协议的解决方案

本协议定义 NR 统一状态机（NR Unified State Machine）——它是 NR 的**唯一写入入口**。所有协议源（PEER、CCR、Slashing、CP Promotion、Forking）通过事件总线向状态机提交 NR 事件（NR Event），状态机按优先级规则解析冲突，计算净效应，更新 NR 的四个维度，并写入审计日志。

```
                    ┌──────────────────────────────┐
                    │   NR Unified State Machine    │
                    │   （NR 统一状态机）              │
                    │                               │
  PEER Review ────→│                               │
  Slashing ───────→│  ┌─ 优先级仲裁                  │
  CCR Trend ─────→│  ├─ 复合公式计算                 │──→ NR 四维向量
  CP Promotion ──→│  ├─ 衰减函数应用                 │──→ 审计事件日志
  Elastic Fork ──→│  └─ 冲突解决                     │──→ 下游协议通知
                    └──────────────────────────────┘
```

### 0.3 设计原则

1. **单一写入入口 (Single Writer)**：所有 NR 变更必须通过本状态机——禁止协议间直接修改 NR。
2. **事件溯源 (Event Sourcing)**：NR 的当前值是所有历史事件的确定性函数。任何时刻的 NR 都可以从事件日志完整重建。
3. **易损性优先 (Vulnerability-First Priority)**：惩罚事件（燃烧、合谋惩罚）优先于奖励事件——防止攻击者通过制造正反馈冲销惩罚。
4. **来源透明 (Source Transparency)**：NR 的四维分解始终对外可见——策元可以按需查看 NR 来源构成。
5. **可审计性 (Auditability)**：每次 NR 变更携带来源协议、触发条件、计算输入和结果——第三方可独立复现。

---

## 一、NR 的四维向量结构

### 1.1 维度定义

NR 是四维向量 `NR = (R, Q, A, C)`，各维度独立追踪、独立更新，最终通过复合公式凝聚为标量 NR_total。

| 维度 | 符号 | 全称 | 含义 | 取值范围 | 主要更新来源 |
|------|:----:|------|------|:---:|------------|
| 可靠性 | `R` | Reliability | 交付准时性与承诺履行度 | `[0, 1]` | Slashing（燃烧事件）、PEER 评审提交时效 |
| 质量 | `Q` | Quality | 产出物的技术水平与 PEER 评审分 | `[0, 1]` | PEER 评审聚合分、CP 晋级事件 |
| 活跃度 | `A` | Activity | 近期任务令参与频次与持续性 | `[0, ∞)` | 任务令完成事件、弹性分叉算力分配 |
| 贡献度 | `C` | Contribution | 对网络整体价值的净贡献（CCR 映射） | `[0, ∞)` | CCR 趋势、NR 转移税、特殊贡献 |

> **与模型三 v2.0 §4.2 的对齐**：模型三定义 NR 为六维向量。本协议将六维凝聚为四维——合并了模型三的 `s_AUTO`/`s_PEER`/`s_MARKET` 来源分量至 `Q` 和 `C` 维度，保留 `s_seed`（信任锚定）作为 `C` 的初始化分量。原六维向量的来源构成信息通过 §七 的审计事件日志保留——不丢失。

### 1.2 维度独立性

每个维度由独立的子状态机管理：

```
R-状态机：可靠性维度
  事件：TaskCompleted(on_time), TaskCompleted(late), Slashed(grace),
        Slashed(linear), Slashed(forced_abort), CollusionPenalty
  更新：加权滑动平均，近期事件权重高于远期

Q-状态机：质量维度
  事件：PEER_Review_Aggregated(score, confidence), CP_Promoted(domain, new_level),
        Audit_Flagged(severity), Dispute_Reversed
  更新：指数加权移动平均 (EWMA)，衰减速率 λ_Q

A-状态机：活跃度维度
  事件：Task_Accepted, Task_Completed, Fork_Compute_Allocated,
        Fork_Compute_Released, Inactivity_Tick
  更新：时间窗滑动计数 + 衰减

C-状态机：贡献度维度
  事件：CCR_Trend_Update, NR_Transfer_Sent, NR_Transfer_Received,
        Special_Contribution, Clawback_Executed
  更新：累积加性，NR 转移税扣除
```

### 1.3 四维向量到标量的复合公式

NR 的总标量值由加权乘积公式计算：

$$NR_{total} = NR_{base} \cdot R \cdot Q \cdot \min(1, \frac{A}{A_{ref}}) \cdot \ln(1 + C)$$

其中：

| 参数 | 默认值 | 含义 |
|------|:-----:|------|
| `NR_base` | 100 | NR 标量基准——将 `[0,1]` 维度映射到可感知的数值范围 |
| `R` | `[0, 1]` | 可靠性维度——**乘法因子**，违约直接缩水 NR |
| `Q` | `[0, 1]` | 质量维度——**乘法因子**，低质量产出不可被活跃度补偿 |
| `A` | `[0, ∞)` | 活跃度维度的原始计数值 |
| `A_ref` | 10 | 参考活跃度——达到此水平后活跃度边际贡献递减 |
| `C` | `[0, ∞)` | 贡献度维度的原始累积值 |
| `ln(1+C)` | — | 对数压缩——防止贡献度维度主导 NR（边际递减） |

**公式设计理由**：

- **R 和 Q 为乘法因子**：如果可靠性或质量为 0，NR 归零——无论多么活跃或贡献多大。这反映「一次严重失信可能摧毁所有声誉积累」的博弈直觉。
- **A 为饱和因子**：`min(1, A/A_ref)` ——超过参考活跃度后不再增加 NR 权重。防止「刷任务令」策略。
- **C 为对数压缩**：贡献度的边际 NR 回报递减——第 1 个单位的贡献和第 100 个单位的贡献不应线性增长 NR。

**数值示例**：

| R | Q | A | C | NR_total | 画像 |
|:---:|:---:|:---:|:---:|:---:|------|
| 0.95 | 0.90 | 15 | 50 | `100 × 0.95 × 0.90 × 1.0 × ln(51)` ≈ 336 | 成熟可靠贡献者 |
| 0.85 | 0.80 | 5 | 10 | `100 × 0.85 × 0.80 × 0.5 × ln(11)` ≈ 81 | 中等水平参与者 |
| 0.50 | 0.70 | 20 | 30 | `100 × 0.50 × 0.70 × 1.0 × ln(31)` ≈ 120 | 高活跃但可靠性差 |
| 0.95 | 0.30 | 3 | 2 | `100 × 0.95 × 0.30 × 0.3 × ln(3)` ≈ 9 | 可靠但产出质量低 |
| 0.20 | 0.50 | 8 | 15 | `100 × 0.20 × 0.50 × 0.8 × ln(16)` ≈ 22 | 刚受重罚的恢复期 |

---

## 二、NR 更新来源与优先级规则

### 2.1 五大更新来源

| 来源 ID | 来源协议 | 提交的事件类型 | 影响维度 | 优先级层级 |
|:---:|------|------------|:---:|:---:|
| `SRC_PEER` | `05_PEER` | `PEER_Score`, `Reviewer_Performance`, `Dispute_Resolution` | Q, R | 3（常规） |
| `SRC_SLASH` | `08_Slashing` | `Slash_Grace`, `Slash_Linear`, `Slash_Abort`, `Collusion_Penalty` | R, C | **1（最高）** |
| `SRC_CCR` | `06_CCR` | `CCR_Trend_Update`, `NR_Transfer_Tax`, `Clawback` | C | 2（高） |
| `SRC_CP` | `16_CP_Promotion` | `CP_Level_Change`, `Skill_Quality_Evidence` | Q | 3（常规） |
| `SRC_FORK` | `07_Forking` | `Fork_NR_Split`, `Fork_NR_Merge`, `Compute_Reallocation` | A, C | 4（低） |

### 2.2 冲突优先级规则

当多个来源在同一时间窗口（默认 1 个区块/批处理间隔）内提交对同一维度的冲突更新时，以下优先级规则裁定：

```
规则 1 (惩罚优先 — Slashing Overrides All):
  SRC_SLASH 提交的 R 维度更新不可被任何其他来源覆盖。
  如果 SRC_SLASH 和任何其他来源在同一批次内提交 R 更新，
  仅保留 SRC_SLASH 的更新——其他来源的 R 更新被丢弃并记录为 OVERRIDDEN。

规则 2 (CCR 回拨优先 — Clawback Overrides Reward):
  SRC_CCR 提交的 clawback（回拨）事件对 C 维度的减量不可
  被同批次的 CP 晋级或 PEER 奖励所抵消。处理顺序：
  先执行所有 C 减量 → 再执行 C 增量。
  如果净效应为负，C 维度在该批次不增加。

规则 3 (最近者胜 — Latest Wins for Same Priority):
  同优先级层级内的冲突（如 SRC_PEER vs SRC_CP 对 Q 维度的更新）
  按时间戳处理——最近的事件覆盖较早的事件。
  如果时间戳相同（同一区块），取中位数。

规则 4 (分叉滞后 — Fork Updates Lagged by 1 Epoch):
  SRC_FORK 提交的更新始终延迟一个处理周期（默认 24 小时）
  再写入 NR——为其他来源提供最后的否决窗口。
  如果一个 FORK_NR_Split 事件在延迟期间被 SRC_SLASH 的
  燃烧事件覆盖，分叉事件被标记为 STALE（过期）并丢弃。

规则 5 (新手保护 — New Entrant Shield):
  对于 NR_total < NR_min_reviewer (默认 50) 的智权体，
  SRC_SLASH 的惩罚事件衰减至 50%——仅对新入者生效。
  保护期：自注册起 90 天或 10 个任务令完成后（取较早者）。
```

### 2.3 优先级矩阵

```
             SRC_SLASH  SRC_CCR  SRC_PEER  SRC_CP  SRC_FORK
SRC_SLASH       —        WINS     WINS     WINS     WINS
SRC_CCR        LOSE       —       WINS     WINS     WINS
SRC_PEER       LOSE      LOSE      —       LATEST   WINS
SRC_CP         LOSE      LOSE    LATEST     —       WINS
SRC_FORK       LOSE      LOSE     LOSE     LOSE      —

读取方式：行 vs 列，WINS = 行来源覆盖列来源，LOSE = 行来源被列来源覆盖，
LATEST = 取时间戳最新的。
```

---

## 三、NR 衰减函数

### 3.1 衰减模型

NR 采用**指数衰减**模型，反映「不活跃导致声誉缓慢消退」的博弈直觉。

$$NR(t) = NR(t_0) \cdot e^{-\lambda_{NR} \cdot (t - t_0)}$$

其中：

| 参数 | 符号 | 默认值 | 含义 |
|------|:----:|:-----:|------|
| 衰减速率 | `λ_NR` | `ln(2) / (14 × 30.4375)` ≈ 0.001627 day⁻¹ | 日衰减速率 |
| 半衰期 | `T_1/2` | **14 个月** (~426 天) | NR 值减半所需时间 |
| 衰减粒度 | — | 每日 (UTC 00:00) | 衰减每天执行一次——不实时 |

> **与模型三 §8.1 对齐**：模型三规定「NR 每月衰减 5%，半衰期 14 个月」。本协议采用精确的日衰减速率 `λ_NR = ln(2)/426`，与月衰减 5% 等价（`(1-0.05)^14 ≈ 0.488 ≈ 1/2`）。

### 3.2 维度衰减差异

并非所有维度以相同速率衰减：

| 维度 | 衰减速率 | 半衰期 | 设计理由 |
|------|:---:|:---:|------|
| `R` (可靠性) | `λ_NR`（标准） | 14 个月 | 可靠性是长期特质——不应快速遗忘一次违约 |
| `Q` (质量) | `λ_NR × 1.5` | ~9.3 个月 | 质量感知老化更快——技能过时比信誉过时快 |
| `A` (活跃度) | `λ_NR × 3.0` | ~4.7 个月 | 活跃度必然随不活跃快速衰减——这是其定义 |
| `C` (贡献度) | `λ_NR × 0.5` | 28 个月 | 历史贡献应被长期记住——比活跃度持久 6 倍 |

> **与 CCR 衰减的区别**：CCR 半衰期 6 个月（`06_CCR §1.3`）——服务于短期「现在是净贡献者还是净消费者」的判断。NR 衰减更慢（14 个月），服务于长期声誉追踪。

### 3.3 衰减边界

- **NR_total 的下界**：NR_total 不因纯衰减降至 `NR_seed` 以下（信任锚定的种子值——见 §五）。
- **零活跃特殊处理**：如果智权体连续 3 个衰减周期（3 天）无任何事件（A 维度为 0 且无新事件），标记为 `DORMANT`。DORMANT 状态的 Q 维度附加 20% 额外衰减——反映「脱离协作环境后技能迅速生疏」。

### 3.4 衰减与回拨的协同

NR 衰减和 NR 回拨（模型三 §五）是互补机制：

| 机制 | 触发条件 | 影响 | 对称性 |
|------|---------|------|:---:|
| **衰减** | 时间流逝（被动） | 所有智权体对称下降 | 对称 |
| **回拨** | 市场失败验证（主动） | 仅惩罚特定失败决策 | 非对称 |
| **协同** | 低能力者「不活跃」+「偶发错误」→ 双重下降 | 演化淘汰加速 | — |

---

## 四、NR 转移税

### 4.1 转移税定义

当智权体 A 向智权体 B 转移 NR 时（作为对 B 贡献的认可），系统征收 **30% 转移税**——被征税的 NR 永久销毁，不进入任何池。

$$NR_{received}(B) = NR_{sent}(A) \times (1 - \tau_{NR})$$

$$NR_{destroyed} = NR_{sent}(A) \times \tau_{NR}$$

其中 `τ_NR = 0.30`。

| 参数 | 符号 | 值 | 来源 |
|------|:----:|:---:|------|
| NR 转移税率 | `τ_NR` | 0.30 (30%) | `06_CCR_Public_Ledger.md` §1.1——NR 转移税的一致性引用 |
| CCR 计入比例 | — | 接收方 CCR 仅计入接收量的 70% | `VT_nr_recv = NR_received × (1 - τ_NR)` |

### 4.2 转移税的经济逻辑

NR 转移税的设计目的：

1. **防止 NR 交易市场**：如果没有转移成本，NR 将成为可交易商品——富裕者可以购买声誉。
2. **制造 NR 稀缺性**：30% 的销毁率使 NR 总量持续通缩——NR 不会因时间推移而通胀。
3. **激励直接贡献**：转移 NR 比接收 NR 更「昂贵」（发送方损失 100% + 接收方仅得 70%）——使直接通过完成任务令获取 NR 比通过转移获取更有效。
4. **与 CCR 对齐**：CCR 的 VT 计算公式中，接收的 NR 仅以 70% 计入——与转移税逻辑一致。

### 4.3 转移税豁免

以下场景免除 NR 转移税：

| 豁免场景 | 条件 | 税率 |
|---------|------|:---:|
| 策元内 PCP 回报分配 | NR 作为 PCP 约定的回报——非自愿转移 | 0% |
| 弹性分叉 NR 分割 | 分叉时成员 NR 随算力比例迁移——非自愿转移 | 0% |
| 合谋惩罚 NR 燃烧 | 惩罚性燃烧——非转移 | N/A（100% 销毁） |
| 冷启动信任锚定 | 外部凭证锚定的 NR 种子——非转移 | 0% |

### 4.4 NR 转移对 CCR 的影响路径

```
A ──[转移 100 NR]──→ B
  │                    │
  ├─ A.C 维度 -= 100   ├─ B.C 维度 += 70（τ=0.30 税后）
  ├─ A.NR_total 重算   ├─ B.NR_total 重算
  │                    │
  └─ 100 NR 从总量中永久销毁
```

在 CCR 账本（`06_CCR §1.1`）中，此事件的记录方式为：

- A 的 CTX 记录：`NR_TRANSFER_OUT: -100 NR`（对 CCR 无直接影响——转移非 VT 事件）
- B 的 CTX 记录：`NR_TRANSFER_IN: +70 NR`，CCR 计入 `VT_nr_recv = 70 × 0.70 = 49`

---

## 五、新入者加速器

### 5.1 加速器定义

新注册智权体在其**前 10 个经验证的任务令**期间，获得 **2x NR 权重加速器**。

$$NR_{earned, accelerated} = NR_{earned, base} \times 2.0$$

加速器自动激活，无需申请。

### 5.2 加速器范围与限制

| 参数 | 值 | 说明 |
|------|:---:|------|
| 加速倍率 | 2.0x | NR 权重的乘数 |
| 加速任务令上限 | 10 个 | 第 11 个任务令起恢复正常权重 |
| 仅限经验证的任务令 | — | AUTO/PEER/MARKET 均可——但需完成验证流程 |
| 仅限 NR_total < 50 时激活 | — | 一旦 NR 超过 50，加速器提前终止 |
| 加速仅应用于 Q 和 C 维度 | — | R 和 A 维度不享受加速——可靠性不能加速建立 |

**设计理由**：模型三 §9.2 显示冷启动 NR 建立需要 3-5 个月。2x 加速器将此缩短至 1.5-2.5 个月——在「快速让真诚新入者参与协作」和「防止 Sybil 快速刷 NR」之间取得平衡（低 HJI AUTO 任务令即使 2x 加速，贡献仍然微小——见模型三 §7.4）。

### 5.3 加速器耗尽示例

```
t=0:   注册 + GitHub 锚定 → NR_seed = 15, 加速器激活
t=1:   完成 PEER 任务令 (HJI=0.6, score=4.0)
       → NR_base = 100 × 0.035 × 2.0 = 7.0 → NR_total ≈ 22
t=2:   完成 PEER 任务令 (HJI=0.7, score=4.5)
       → NR_base = 100 × 0.049 × 2.0 = 9.8 → NR_total ≈ 32
...
t=10:  第 10 个任务令完成 → 加速器标记 EXHAUSTED
t=11:  恢复正常 1.0x 权重
```

### 5.4 加速器终止条件

加速器在以下任一条件下提前终止：

1. 完成 10 个经验证的任务令（正常耗尽）。
2. NR_total 达到或超过 50（不再需要加速）。
3. 触发 SRC_SLASH 的 `Slash_Abort`（强制熔断）——严重违约取消加速器。
4. 智权体注册超过 180 天仍未完成 10 个任务令——加速器过期。

---

## 六、NR 事件日志（审计跟踪）

### 6.1 事件日志数据模型

每次 NR 变更产生一条不可变的事件记录：

```json
{
  "event_id": "nr_evt_x1y2z3w4",
  "ns_id": "ns_0a1b2c3d",
  "timestamp": "2026-05-18T14:30:00Z",
  "block_height": 1849237,
  
  "source": {
    "protocol": "SRC_PEER",
    "protocol_version": "CONC-Protocol/Verification.PEER.1.0",
    "trigger_event": "PEER_Review_Aggregated",
    "trigger_ref": "tw_react_ui_003",
    "submitter": "gu_x9y8z7w6"
  },
  
  "nr_before": {
    "R": 0.88, "Q": 0.72, "A": 12, "C": 35,
    "NR_total": 231.5
  },
  
  "delta": {
    "R": 0.00,
    "Q": 0.015,
    "A": 0,
    "C": 1.2
  },
  
  "nr_after": {
    "R": 0.88, "Q": 0.735, "A": 12, "C": 36.2,
    "NR_total": 241.8
  },
  
  "computation": {
    "formula": "Q += α_learn × (agreement_score - Q_old)",
    "inputs": {
      "α_learn": 0.05,
      "agreement_score": 0.92,
      "Q_old": 0.72
    },
    "result": 0.015
  },
  
  "overrides": [],
  "signature": "0xsha256hash..."
}
```

### 6.2 事件日志的不可变性

- 每条事件记录一旦写入即**不可修改**（仅追加）。
- 事件日志的哈希链：`event_id_n` 包含 `event_id_{n-1}` 的哈希——形成防篡改链。
- 如果 NR 回拨（clawback）发生，**不修改原始事件**——而是写入一条新的 `Clawback_Executed` 事件，引用原始 `PEER_Review_Aggregated` 事件。

### 6.3 事件日志的查询接口

```
GET /nr/{ns_id}/events?from=2026-01-01&to=2026-06-01&source=SRC_PEER&limit=50
  → 返回指定智权体在时间范围内的 NR 事件列表

GET /nr/{ns_id}/audit-trail?event_id=nr_evt_x1y2z3w4
  → 返回指定事件的完整审计链（包含被其覆盖的同批次事件）

GET /nr/{ns_id}/reconstruct?as_of=2026-05-18T14:30:00Z
  → 从事件日志完整重建指定时间点的 NR 四维向量
```

### 6.4 事件日志的存储

- 事件日志存储在价值层（Value Layer）的分布式账本中。
- 每个智权体的 NR 事件日志独立分片——避免热点竞争。
- 事件日志至少保留 10 年（NR 的最长衰减半衰期为 28 个月——10 年覆盖 ~5 个半衰期，确保历史事件可追溯至统计学上权重 < 3%）。

---

## 七、完整状态机

### 7.1 NR 事件处理流程

```
                     ┌─────────────────────────┐
                     │    NR Event Received     │
                     │   (from any protocol)    │
                     └───────────┬─────────────┘
                                 │
                                 ▼
                     ┌─────────────────────────┐
                     │  1. Validate Event       │
                     │  - source protocol valid? │
                     │  - ns_id exists?         │
                     │  - delta within bounds?  │
                     └───────────┬─────────────┘
                                 │
                    ┌────────────┴────────────┐
                    │  Valid?                 │
                    └────────────┬────────────┘
                    ✗            │            ✓
                    ▼            │            ▼
              ┌──────────┐      │    ┌─────────────────────────┐
              │ REJECTED │      │    │  2. Batch Accumulation   │
              │ + Error   │      │    │  Collect events within   │
              └──────────┘      │    │  batch window (1 block)  │
                                │    └───────────┬─────────────┘
                                │                │
                                │                ▼
                                │    ┌─────────────────────────┐
                                │    │  3. Priority Resolution  │
                                │    │  Apply Rules 1-5 (§2.2)  │
                                │    │  Discard overridden      │
                                │    └───────────┬─────────────┘
                                │                │
                                │                ▼
                                │    ┌─────────────────────────┐
                                │    │  4. Apply Per-Dimension   │
                                │    │     Update Functions      │
                                │    │  R, Q, A, C sub-machines  │
                                │    └───────────┬─────────────┘
                                │                │
                                │                ▼
                                │    ┌─────────────────────────┐
                                │    │  5. Compute NR_total      │
                                │    │  Composite formula (§1.3) │
                                │    │  Check new entrant accel  │
                                │    └───────────┬─────────────┘
                                │                │
                                │                ▼
                                │    ┌─────────────────────────┐
                                │    │  6. Write Event Log       │
                                │    │  Immutable append-only    │
                                │    │  Hash-chain to prev event │
                                │    └───────────┬─────────────┘
                                │                │
                                │                ▼
                                │    ┌─────────────────────────┐
                                │    │  7. Emit NR_Updated Event │
                                │    │  Notify downstream        │
                                │    │  (PEER, CCR, Matching...) │
                                │    └─────────────────────────┘
```

### 7.2 批处理窗口

| 参数 | 默认值 | 含义 |
|------|:-----:|------|
| Batch Window | 1 block (~12s) | 同一区块内的 NR 事件视为「同一批次」——优先级规则适用 |
| Batch Max Events | 1000 / ns_id | 单个智权体每批次最多处理 1000 个事件——防止 DoS |
| Stale Event Timeout | 1 hour | 超过 1 小时未处理的挂起事件被自动丢弃 |

### 7.3 各维度的更新函数

#### 7.3.1 R 维度（可靠性）

```
R 采用加权滑动平均——近期事件权重高于远期：

R_new = (n_events × R_old + w_event × score_event) / (n_events + w_event)

其中：
  n_events: 该维度累计事件数（上限 100，防止古老事件永久锁死 R）
  w_event:  事件权重
    - TaskCompleted(on_time):    w = 1.0, score = 1.0
    - TaskCompleted(late):       w = 1.5, score = 0.85
    - Slashed(grace):            w = 2.0, score = 0.95
    - Slashed(linear):           w = 3.0, score = 0.85
    - Slashed(forced_abort):     w = 5.0, score = 0.50
    - Collusion_Penalty:         w = 10.0, score = 0.10
    - Reviewer_Timeout:          w = 1.0, score = 0.90 (≤72h) / 0.80 (>72h)
    
R 的下界：0.05（即使最严重的违约，人性保留 5% 的复苏可能——见 §八）
R 的初值：0.50（中性先验——贝叶斯平滑，等价于「5 次中等表现的先验」）
```

#### 7.3.2 Q 维度（质量）

```
Q 采用指数加权移动平均 (EWMA)：

Q_new = Q_old + α_Q × (score_event - Q_old)

其中：
  α_Q = 0.05 (学习率——与 PEER 协议 §7.1 的 α_learn 一致)
  score_event 取决于事件类型：
    - PEER_Review_Aggregated:     score = avg(review_scores) / 5.0
    - CP_Promoted:                score = 1.0（晋升事件——强正信号）
    - Audit_Flagged(minor):       score = Q_old × 0.85
    - Audit_Flagged(major):       score = Q_old × 0.60
    - Dispute_Reversed:           score = Q_old × 0.70

Q 的初值：0.50（中性先验）
Q 的上界：1.0
Q 的下界：0.10（即使被标记为异常，保留最低质量估计）
```

#### 7.3.3 A 维度（活跃度）

```
A 采用时间窗滑动计数 + 指数衰减：

A(t) = Σ_i w(type_i) × e^{-λ_A × (t - t_i)}

其中：
  t_i: 事件 i 的发生时间
  λ_A: A 维度的衰减速率 = λ_NR × 3.0
  w(type_i): 事件类型权重
    - Task_Accepted:              w = 0.5
    - Task_Completed:             w = 1.0
    - PEER_Review_Submitted:      w = 0.3
    - Fork_Compute_Allocated:     w = 0.2 × allocation_alpha
    - Inactivity_Tick:            w = 0 (纯衰减事件——不增加计数)

A 的初值：0
A 无上界——但 NR_total 公式中的 min(1, A/A_ref) 确保边际贡献递减
```

#### 7.3.4 C 维度（贡献度）

```
C 采用累积加性模型——无指数衰减（C 维度自带对数压缩 + 慢衰减）：

C_new = C_old + ΔC

其中 ΔC 取决于事件类型：
  - Task_Completed(quality_weighted):
      ΔC = VT_task × q_quality × m_mode × (accelerator_multiplier)
      // accelerator_multiplier = 2.0 if new entrant, else 1.0
      
  - NR_Transfer_Sent:
      ΔC = -NR_sent（全额扣除）
      
  - NR_Transfer_Received:
      ΔC = NR_sent × (1 - τ_NR) × (1 - τ_NR)
      // 双重 70%：接收方仅得发送量的 49% 计入 C 维度
      
  - Clawback_Executed:
      ΔC = -s_clawback（负增量——回拨）
      
  - Special_Contribution:
      ΔC = VT_special × q_special

C 的初值：NR_seed（来自信任锚定——见 §五）
C 的下界：0（可因 clawback 和 transfer 降至 0——但不为负）
```

### 7.4 NR 事件处理的事务性保证

NR 状态机的事件处理是**事务性的**——一个批次内的所有事件要么全部应用，要么全部回滚：

```
BEGIN TRANSACTION NR_BATCH
  1. 验证批次内所有事件
  2. 应用优先级规则
  3. 执行维度更新
  4. 计算 NR_total
  5. 写入事件日志
COMMIT
  → 如果任何步骤失败 → ROLLBACK，整个批次丢弃，事件返回至各协议源重试队列
```

---

## 八、边界条件与安全约束

### 8.1 NR 维度的合法范围

| 维度 | 下界 | 上界 | 越界处理 |
|------|:---:|:---:|------|
| `R` | 0.05 | 1.0 | 超出范围的值被 clamp |
| `Q` | 0.10 | 1.0 | 超出范围的值被 clamp |
| `A` | 0 | ∞ | 无上界——但 NR_total 公式限制 |
| `C` | 0 | ∞ | 负值被 clamp 至 0 |
| `NR_total` | `NR_seed` | ∞ | 不因纯衰减低于 `NR_seed` |

### 8.2 Sybil 防御：NR 积累速率限制

| 限制 | 值 | 说明 |
|------|:---:|------|
| 单日 NR_total 最大增量 | +10 | 任何智权体在 24h 内 NR_total 的增长上限（与模型三 §6.3 一致） |
| 单日 NR 事件最大数 | 1000 | 防止事件洪水 DoS |
| 加速器 + 速率限制 | 取 min(10, 2x weight × base) | 加速器受速率上限约束——不可绕过 |
| 异常速率检测 | 95 分位 | NR 增速超过全网 95 分位 → 自动触发审计 |

### 8.3 降级保护

NR 的下降路径受保护——防止「一次错误抹除多年积累」：

| 保护机制 | 规则 |
|---------|------|
| R 维度下界 | 不低于 0.05——「人性保留」5%，永远不归零（与 PEER 协议 §7.3 一致） |
| Q 维度下界 | 不低于 0.10——即使被标记为异常评审者 |
| 单日最大下降 | NR_total 单日下降不超过当前值的 50%——防止闪崩 |
| 恢复斜率 | 从惩罚中恢复的 R 维度增长速度 ≥ 0.01/月——确保恢复路径存在 |

### 8.4 高 NR 智权体的额外约束

| NR_total 区间 | 额外约束 |
|:---:|------|
| NR ≥ 200 | NR 转移需额外冷却 7 天（防止快速转移后退出） |
| NR ≥ 500 | 回拨窗口延长至 36 个月（vs 默认 24 个月）——「大人物」责任期更长 |
| NR ≥ 1000 | 策元核选举中自动增加 1 个反对票权重——反寡头阻尼 |

### 8.5 与外部协议的集成约束

| 外部协议 | 本状态机的责任 | 外部协议的责任 |
|---------|--------------|--------------|
| `05_PEER` | 接受 `PEER_Review_Aggregated` 事件，更新 Q 和 R | 不再直接写入 `NR_reliability`——代之以提交 NR 事件 |
| `06_CCR` | 接受 `CCR_Trend_Update`，更新 C。发出 `NR_Transfer` 事件 | CCR 公式中引用 `NR_total` 的当前值作为输入 |
| `08_Slashing` | 接受 `Slash_*` 事件，更新 R 和 C。发出 `Collusion_Penalty` | 燃烧计算仅计算应燃烧量——实际 NR 扣除由本状态机执行 |
| `16_CP_Promotion` | 接受 `CP_Level_Change` 事件，更新 Q | CP 晋级管道仅计算新级别——Q 维度更新由本状态机执行 |
| `07_Forking` | 接受 `Fork_NR_Split` / `Fork_NR_Merge`，更新 A 和 C | 分叉协议仅计算算力分配比例——NR 迁移由本状态机执行 |

---

## 九、API 端点

### 9.1 NR 事件提交（协议源 → 状态机）

```
POST /nr/events/submit
  Request:
    {
      "source_protocol": "SRC_PEER",
      "protocol_version": "CONC-Protocol/Verification.PEER.1.0",
      "ns_id": "ns_0a1b2c3d",
      "event_type": "PEER_Review_Aggregated",
      "event_payload": {
        "task_id": "tw_react_ui_003",
        "aggregated_score": 4.2,
        "confidence": 0.87,
        "n_reviewers": 3
      },
      "trigger_ref": "tw_react_ui_003",
      "submitter_gu_id": "gu_x9y8z7w6",
      "timestamp": "2026-05-18T14:30:00Z"
    }
  
  Response 202:
    {
      "event_id": "nr_evt_pending_x1y2",
      "status": "ACCEPTED",
      "batch_id": "batch_20260518_1430",
      "estimated_processing": "next_block"
    }

  Error Responses:
    400 INVALID_SOURCE_PROTOCOL
      → "Unknown source protocol: SRC_UNKNOWN"
    400 INVALID_NS_ID
      → "ns_xyz not found in identity registry"
    422 DELTA_OUT_OF_BOUNDS
      → "Proposed NR delta exceeds daily rate limit (max +10/day)"
    429 RATE_LIMITED
      → "ns_0a1b2c3d exceeded 1000 events per batch"
```

### 9.2 NR 查询

```
GET /nr/{ns_id}
  Response 200:
    {
      "ns_id": "ns_0a1b2c3d",
      "as_of": "2026-05-18T14:30:00Z",
      "nr_vector": {
        "R": 0.88,
        "Q": 0.735,
        "A": 12.0,
        "C": 36.2
      },
      "NR_total": 241.8,
      "NR_percentile": 72,
      "last_updated": "2026-05-18T14:30:00Z",
      "new_entrant_accelerator": {
        "active": false,
        "tasks_remaining": 0
      }
    }


GET /nr/{ns_id}/breakdown
  → 返回 NR 的来源构成（各维度分别来自哪些协议源）：

  Response 200:
    {
      "ns_id": "ns_0a1b2c3d",
      "R_breakdown": {
        "from_on_time_tasks": 0.62,
        "from_late_tasks": 0.18,
        "from_slashing_events": -0.05,
        "net": 0.88
      },
      "Q_breakdown": {
        "from_peer_reviews": 0.55,
        "from_cp_promotions": 0.12,
        "from_audit_flags": -0.04,
        "net": 0.735
      },
      ...
      "NR_total": 241.8
    }
```

### 9.3 事件日志查询

```
GET /nr/{ns_id}/events?from=2026-01-01&to=2026-06-01&source=SRC_PEER&limit=50
GET /nr/{ns_id}/events?event_type=Slash_Abort&limit=10
GET /nr/{ns_id}/audit-trail?event_id=nr_evt_x1y2z3w4
GET /nr/{ns_id}/reconstruct?as_of=2026-05-18T14:30:00Z
```

### 9.4 NR 转移

```
POST /nr/transfer
  Request:
    {
      "from_ns_id": "ns_0a1b2c3d",
      "to_ns_id": "ns_4d5e6f7g",
      "amount": 100,
      "reason": "PCP_reward_distribution",
      "exempt_from_tax": false
    }
  
  Response 200:
    {
      "transfer_id": "nr_xfer_x1y2z3",
      "from_ns_id": "ns_0a1b2c3d",
      "to_ns_id": "ns_4d5e6f7g",
      "amount_sent": 100,
      "tax_deducted": 30,
      "amount_received": 70,
      "from_new_nr_total": 190.5,
      "to_new_nr_total": 175.8
    }

  Error Responses:
    400 INSUFFICIENT_NR
      → "ns_0a1b2c3d NR_total (100) less than transfer amount (150)"
    403 NR_TRANSFER_COOLDOWN
      → "ns_0a1b2c3d in 7-day cooldown (NR≥200)"
```

### 9.5 衰减触发（系统内部）

```
POST /nr/cron/apply-decay  (internal — called by system cron)

  每日 UTC 00:00 被系统 cron 调用。
  对每个非 DORMANT 智权体执行维度衰减。
  对 DORMANT 智权体额外施加 Q 维度的 20% 附加衰减。
  
  Response 200:
    {
      "decay_applied_to": 8452,
      "dormant_count": 321,
      "dormancy_extra_decay_applied": 321,
      "execution_time_ms": 430
    }
```

---

## 十、与协议栈的集成点

```
身份层 (Identity Layer)
  └─→ ns_id 注册时初始化 NR 向量：R=0.50, Q=0.50, A=0, C=NR_seed

验证层 (Verification Layer) — 05_PEER
  └─→ PEER 评审完成后提交 PEER_Review_Aggregated 事件
  └─→ 不再直接写入 NR_reliability

价值层 (Value Layer) — 本协议 + 06_CCR + 08_Slashing
  └─→ NR 状态机是价值层的核心状态管理组件
  └─→ CCR 从 NR 状态机读取 NR_total 作为阻尼系数的输入
  └─→ Slashing 协议向 NR 状态机提交 Slash_* 事件

策元层 (Genesis Layer) — 07_Forking + 16_CP_Promotion
  └─→ 分叉事件提交 Fork_NR_Split / Fork_NR_Merge
  └─→ CP 晋级提交 CP_Level_Change
  └─→ 任务令匹配器从 NR 状态机读取 NR_total 用于排序

网络层 (Network Layer)
  └─→ NR 事件日志的跨节点同步和一致性验证
```

---

## 十一、迁移路径

### 11.1 从分散更新到统一状态机的迁移

当前状态（v1.x）→ 目标状态（本协议 v1.0）：

| 迁移步骤 | 操作 | 影响 |
|:---:|------|------|
| 1 | 冻结所有协议对 NR 的直接写入 | 协议源改为通过 `/nr/events/submit` 提交事件 |
| 2 | 从现有 NR 数据重建初始四维向量 | 提取 R（从 Slashing 记录）、Q（从 PEER 记录）、A（从任务令日志）、C（从 CCR 记录） |
| 3 | 回填 NR 事件日志 | 从历史记录生成不可变事件流 |
| 4 | 启用统一状态机 | 激活优先级仲裁和冲突解决 |
| 5 | 废弃旧协议中的直接 NR 写入代码 | 旧写入端点在 2 个治理季度后关闭 |

### 11.2 向后兼容

- 旧协议通过 `/nr/events/submit` 提交事件——无需修改旧协议的核心逻辑，仅修改 NR 写入的出口。
- `NR_total` 的标量值保持与模型三 v2.0 的数值范围一致（0-500 为典型区间）。
- 查询接口保持与现有 PEER 协议中 NR 查询的兼容——返回格式增加四维分解但保留标量 `NR_total`。

---

## 十二、反游戏设计

| 攻击向量 | 防御 | 位置 |
|---------|------|------|
| 批量制造低质量任务令刷 NR | Q 维度 EWMA 学习率 α_Q=0.05——单次评分仅贡献 5% | §7.3.2 |
| 通过 NR 转移在账户间循环 NR | 转移税 30%——每轮循环损失 51% (1 - 0.7²) | §四 |
| 利用加速器创建 Sybil 账户刷 NR | 加速器仅 10 个任务令 + NR < 50 上限 | §五 |
| 在惩罚事件临近前快速转移 NR | NR ≥ 200 时 7 天冷却 + 事件日志不可变 | §8.4 |
| 利用时间窗口在衰减前消费 NR | 衰减每日执行——无「提前消费」窗口 | §3.1 |
| 多个协议源提交冲突更新扰乱 NR | 优先级矩阵裁定——Slashing 最高优先 | §2.3 |
| 伪造 NR 事件绕过验证 | 事件日志哈希链 + 签名验证 | §6.2 |

---

## 十三、NR 燃烧机制与动态衰减调整（v2.2 新增）

### 13.1 NR 燃烧机制概述

NR 燃烧 (NR Burning) 是 v2.2 引入的 NR 消费出口体系——NR 不仅是声誉的存储，也是行使网络权利的「燃料」。燃烧机制的核心设计原则：

> **NR 燃烧不是「支付」而是「声誉消费」**——你消耗的是你在网络中积累的信任资本，而非可转让的货币。

与 VT（价值通证）的关键区别：

| 维度 | VT | NR 燃烧 |
|------|:---:|------|
| 本质 | 价值转移——从 A 到 B | 声誉消费——永久销毁 |
| 可转让性 | 是（通过 CCR） | 否——燃烧的 NR 不进入任何账户 |
| 获取方式 | 完成任务令赚取 | 通过长期诚实协作积累 |
| 消耗含义 | 「我支付了报酬」 | 「我消耗了我的声誉来行使权利」 |
| 通胀/通缩 | 任务令产出 → 通胀 | 燃烧 + 衰减 → 通缩压力 |

NR 燃烧包含五个出口（四个核心出口 + 一个外部引用出口），覆盖治理、优先权、准入、评审和声誉市场五个场景。

### 13.2 出口一：治理权（Governance Rights）

CIP（CONC Improvement Proposal）提案投票消耗 NR——投票权重与 NR 持有量成正比：

```
投票权重 = NR(ns_id) / Σ NR(all_voters)

NR 消耗规则：
  - 每次 CIP 投票消耗 NR_vote = min(1, 0.01 × NR(ns_id))
    // 最低 1 NR，最高为 NR 的 1%
  - 消耗发生在投票提交时——无论投票结果如何
  - 多次投票（同一 CIP 的迭代轮次）每次均消耗 NR

  - 投票通过 → 提案者获得 NR 奖励 (+5 NR, 从治理池分配)
  - 投票否决 → 提案者无惩罚，仅投票者消耗 NR
```

**博弈论分析**：NR 投票消耗防止「冷漠投票」——投票者需要付出真实声誉成本，激励其认真评估提案而非随意投票。同时，1% 的上限确保高 NR 者不会被不成比例地惩罚——他们已通过积累高 NR 证明了对网络的承诺。

### 13.3 出口二：优先权（Priority Rights）

高 NR 智权体可通过消耗 NR 获得策元任务令分配的优先权：

```
优先权出价机制：
  1. 策元发布任务令时，可选择启用「NR 优先权竞价」模式。
  2. 有意向的智权体出价消耗 NR 以获得优先分配权。
  3. 出价最高的前 k 位获得任务令的优先认领权。
  4. 消耗的 NR 永久销毁——不分配给策元或任务令发布方。
  5. 若无人出价，按常规匹配算法（NR 排序）分配。

参数：
  - 最小出价：1 NR
  - 最大出价：任务令 VT 的 10%
  - 出价冷却期：同一智权体对同一策元的优先权出价需间隔 7 天
```

**博弈论分析**：优先权消耗将「等待任务令」的被动策略转化为主动的声誉投资。高 NR 者通过消耗声誉换取优先机会——这筛选出真正重视特定任务令的协作者，而非仅仅「刷任务令」的投机者。

### 13.4 出口三：准入权（Access Rights）

NR 作为高级功能和社区的准入门票：

```
NR 准入门槛：

| 功能/社区 | NR 门槛 | 消耗方式 |
|----------|:---:|------|
| 创建新策元 | NR ≥ 200 | 消耗 50 NR（一次性） |
| 发起 CIP 提案 | NR ≥ 100 | 消耗 10 NR（每次提案） |
| 成为审计者 (§五.2) | NR ≥ 150 + NR_reliability ≥ 0.8 | 不消耗——资格门槛 |
| 访问全局评审者池 | NR ≥ 50 | 不消耗——资格门槛 |
| 发起 PEER(5) 争议升级 | NR ≥ 50 | 质押 5 VT（§六.1），不消耗 NR |
| 策元核候选资格 | NR ≥ 100 | 不消耗——资格门槛 |
| 声誉市场开放（见 §13.6） | NR ≥ 500 | 消耗 100 NR（一次性开通） |

NR 消耗类型：
  - 一次性消耗：创建策元、开通声誉市场——消耗后 NR 永久降低
  - 重复消耗：CIP 提案——每次发起均消耗
  - 资格门槛：不消耗 NR——仅需达到最低 NR
```

**博弈论分析**：NR 准入权创造了「声誉投资 → 获得更多权利 → 更深参与 → 积累更多声誉」的正反馈循环。同时，一次性消耗确保「创建策元」等行为有真实的声誉成本——防止策元泛滥。

### 13.5 出口四：评审消费（Review Consumption）

发起高级评审（如 PEER_SYNC、加速评审）需消耗 NR：

```
评审类型与 NR 消耗：

| 评审类型 | NR 消耗 | 说明 |
|---------|:---:|------|
| 标准 PEER(3) | 0 NR | 基础评审——由系统自动分配 |
| PEER(5) 升级评审 | 5 NR | 争议升级评审（由争议方消耗） |
| PEER_SYNC 同步评审 | 10 NR | 面对面评审的协调成本 |
| 加急评审（窗口 12h） | 15 NR | 将评审窗口从 48h 压缩至 12h |
| 指定专长评审者 | 8 NR | 指定评审者需具备特定专长标签 |
| 审计请求（额外审计） | 20 NR | 请求在常规审计之外增加一次独立审计 |

NR 消耗者：
  - 被评审方（任务令提供方）发起 PEER_SYNC / 加急 / 指定专长 → 消耗 NR
  - 争议方发起 PEER(5) 升级 → 消耗 NR
  - 被评审方请求额外审计 → 消耗 NR
```

**博弈论分析**：评审消费防止「评审资源滥用」——如果 PEER_SYNC 和加急评审免费，高 NR 者可能滥用这些服务挤占评审者时间。NR 消耗使发起方内化评审成本：「我只在真正需要时才请求高级评审」。

### 13.6 出口五：声誉市场（Reputation Marketplace，V2.0 预留）

NR 可作为外部系统（如其他 DAO、Web3 协议、招聘平台）的声誉引用：

```
声誉市场开放条件：
  1. 智权体 NR ≥ 500
  2. 一次性消耗 100 NR 开通声誉市场权限
  3. 通过 CIP 治理投票批准外部系统的接入

外部系统可查询：
  - NR 四维向量（R, Q, A, C）的当前值
  - NR_total 的百分位排名
  - 经验证的任务令完成记录（脱敏）
  - PEER 评审历史摘要（脱敏）

外部系统不可查询：
  - 具体的任务令内容
  - 评审者身份
  - 策元内部讨论
  - 转移记录（隐私保护）

查询费用：
  - 外部系统每次查询消耗 0.1 NR（从被查询者 NR 中扣除）
  - 被查询者可关闭声誉市场（不消耗额外 NR）
```

> 注：声誉市场为 V2.0 预留功能——v2.2 仅定义接口和消耗模型，实际外部接入需后续 CIP 治理批准。

### 13.7 活跃税（Inactivity Tax）

v2.2 引入活跃税机制——长期不活跃的智权体面临加速声誉衰减：

```
活跃税触发条件：
  智权体连续 6 个月无以下任何活动：
    - 完成任务令
    - 提交 PEER 评审
    - 参与 CIP 投票
    - NR 转移（发送或接收）
    - CP 晋级事件

活跃税效果：
  → 衰减速率加倍：λ_NR_active_tax = 2 × λ_NR
  → 半衰期从 14 个月缩短至 7 个月
  → 各维度衰减倍率同样翻倍：

  | 维度 | 标准衰减倍率 | 活跃税衰减倍率 |
  |------|:---:|:---:|
  | R (可靠性) | λ_NR × 1.0 → T½=14月 | λ_NR × 2.0 → T½=7月 |
  | Q (质量) | λ_NR × 1.5 → T½≈9.3月 | λ_NR × 3.0 → T½≈4.7月 |
  | A (活跃度) | λ_NR × 3.0 → T½≈4.7月 | λ_NR × 6.0 → T½≈2.3月 |
  | C (贡献度) | λ_NR × 0.5 → T½=28月 | λ_NR × 1.0 → T½=14月 |

活跃税解除条件：
  → 智权体完成任意一次上述活动后，活跃税立即解除
  → 衰减速率恢复至标准值——但已衰减的 NR 不会恢复
  → 活跃税标记在事件日志中记录为 ACTIVITY_TAX_ACTIVATED / ACTIVITY_TAX_DEACTIVATED
```

**博弈论分析**：活跃税解决了 NR 衰减模型（§三）的一个不对称问题——长期不活跃者仅以标准速率衰减，而活跃者的 NR 因参与活动的风险（如燃烧、被审计标记）可能更快下降。活跃税确保「不参与」不是免费的——它加速了「幽灵账户」的声誉消退，使 NR 总量更准确反映当前活跃协作者的质量。

### 13.8 动态衰减调整（Dynamic Decay Adjustment）

v2.2 引入 NR 总量的动态衰减调整——衰减速率不再固定，而是根据全网 NR 通胀率自适应调节：

```
动态衰减规则：

条件 1 — NR 总量月增长 > 20%:
  → 加速衰减：半衰期从 14 个月缩短至 10 个月
  → λ_NR_fast = ln(2) / (10 × 30.4375) ≈ 0.002278 day⁻¹
  → 触发阈值：NR 总量的月末值 / 月初值 > 1.20

条件 2 — NR 总量月增长 < 5%:
  → 减缓衰减：半衰期从 14 个月延长至 18 个月
  → λ_NR_slow = ln(2) / (18 × 30.4375) ≈ 0.001265 day⁻¹
  → 触发阈值：NR 总量的月末值 / 月初值 < 1.05

条件 3 — 正常范围（5% ≤ 月增长 ≤ 20%）:
  → 标准衰减：半衰期 14 个月（不变）
  → λ_NR = ln(2) / (14 × 30.4375) ≈ 0.001627 day⁻¹

调整频率：每月 1 日 UTC 00:00 评估上月 NR 总量变化，动态调整本月衰减速率。
调整范围：半衰期 [10, 18] 个月——防止极端值。
```

**实时仪表盘**：

v2.2 要求协议层公开以下 NR 宏观指标（实时更新）：

| 指标 | 说明 | 更新频率 |
|------|------|:---:|
| NR 总量 | 全网所有智权体 NR_total 之和 | 每小时 |
| NR 产出速率 | 过去 30 天新增 NR 总量 / 30 | 每日 |
| NR 燃烧速率 | 过去 30 天燃烧 NR 总量 / 30 | 每日 |
| NR 衰减速率 | 当前生效的 λ_NR（含动态调整） | 每月 |
| NR 活跃税账户数 | 当前标记为活跃税的智权体数量 | 每日 |
| NR 分布 Gini 系数 | 全网 NR 的基尼系数 | 每周 |
| NR 百分位分布 | P10/P25/P50/P75/P90/P95/P99 | 每周 |

**博弈论分析**：动态衰减解决了固定衰减模型的两个问题：
1. **通胀螺旋**：如果 NR 产出持续超过衰减 + 燃烧，NR 总量将无限增长——NR 的稀缺性消失，声誉信号失效。加速衰减在通胀过高时自动收紧。
2. **通缩陷阱**：如果 NR 燃烧 + 衰减超过产出，NR 总量持续萎缩——新入者难以积累足够 NR 参与治理。减缓衰减在增长过慢时提供缓冲。

动态衰减使 NR 成为一种**自适应稀缺资产**——总量变化被控制在 [5%, 20%] 月增长的健康区间内。

### 13.9 NR 燃烧的博弈论综合分析

#### 13.9.1 防止「只进不出」通胀

NR 的五个出口 + NR 转移税（§四）+ NR 衰减（§三）+ 动态衰减（§13.8）构成完整的 NR 通缩压力体系：

```
NR 流入：
  + 完成任务令（PEER/AUTO/MARKET 验证后）
  + CP 晋级事件
  + 新入者加速器（限前 10 个任务令）
  + 信任锚定种子值

NR 流出：
  - 治理权投票消耗（§13.2）
  - 优先权竞价消耗（§13.3）
  - 准入权一次性消耗（§13.4）
  - 评审消费消耗（§13.5）
  - 声誉市场查询消耗（§13.6, V2.0）
  - NR 转移税 30%（§四）
  - NR 衰减（§三）——所有持有者对称
  - 活跃税加速衰减（§13.7）——不活跃者非对称
  - 合谋惩罚 NR 燃烧（§八, 05_PEER §八.3）
  - 阶梯式燃烧（08_Slashing）
```

NR 流入和流出之间的平衡由动态衰减（§13.8）自动调节。

#### 13.9.2 燃烧 = 对网络的贡献证明

NR 燃烧的核心博弈含义：

> **「我消耗了我的声誉来行使权利」** 比 **「我拥有高声誉」** 传递更强的承诺信号。

这是因为：
- 持有 NR 是**低成本信号**——可以仅通过时间积累（不活跃也能保留部分 NR）。
- 燃烧 NR 是**高成本信号**——它不可逆地销毁了积累的声誉资本。
- 当一位智权体消耗 NR 来投票、竞价优先权或发起提案时，它在说：「我对这个决定的信心足够强，以至于我愿意永久消耗我的声誉来支持它。」

这与 VT 的经济逻辑形成对比：VT 是可转让的——花掉 VT 意味着你放弃了购买力，但你可以通过更多工作赚回来。NR 燃烧意味着你永久放弃了声誉——这只能通过长期的诚实协作重新积累。

#### 13.9.3 与 VT 的本质区别

```
VT（价值通证）：
  - 是「钱」——通用购买力
  - 可赚取、可花费、可转让
  - 消费 VT 不影响声誉
  - VT 余额反映「我做了多少工作」

NR 燃烧：
  - 是「声誉消费」——对信任资本的提取
  - 不可转让——燃烧的 NR 永久消失
  - 消费 NR 降低声誉权重
  - NR 余额反映「网络有多信任我」
```

这种区别确保 NR 和 VT 服务于不同的博弈功能：
- **VT** 激励短期贡献——「完成这个任务，获得 VT 报酬」
- **NR** 激励长期承诺——「消耗我的声誉来行使权利，证明我对网络的长期投入」

---

## 附录 A：参数速查表

| 参数 | 符号 | 默认值 | 位置 |
|------|:----:|:-----:|------|
| NR 基准标量 | `NR_base` | 100 | §1.3 |
| 参考活跃度 | `A_ref` | 10 | §1.3 |
| NR 衰减速率 | `λ_NR` | ln(2)/426 day⁻¹ | §3.1 |
| NR 半衰期 | `T_1/2` | 14 个月 | §3.1 |
| Q 维度衰减倍率 | — | λ_NR × 1.5 | §3.2 |
| A 维度衰减倍率 | — | λ_NR × 3.0 | §3.2 |
| C 维度衰减倍率 | — | λ_NR × 0.5 | §3.2 |
| NR 转移税率 | `τ_NR` | 0.30 | §4.1 |
| 新入者加速倍率 | — | 2.0x | §5.1 |
| 加速器任务令上限 | — | 10 | §5.2 |
| 加速器 NR 上限 | — | 50 | §5.2 |
| R 维度学习参数 | `w_event` | 见 §7.3.1 | §7.3.1 |
| Q 维度学习率 | `α_Q` | 0.05 | §7.3.2 |
| R 下界 | — | 0.05 | §8.1 |
| Q 下界 | — | 0.10 | §8.1 |
| 单日 NR 最大增量 | — | +10 | §8.2 |
| 单日 NR 最大降幅 | — | 50% of current | §8.3 |
| 批处理窗口 | — | 1 block (~12s) | §7.2 |
| 高 NR 转移冷却 | — | 7 天 (NR ≥ 200) | §8.4 |

## 附录 B：协议版本历史

| 版本 | 日期 | 变更 |
|------|------|------|
| v1.0 | 2026-05-18 | 初始统一状态机协议。定义 NR 四维向量 (R, Q, A, C)、五大来源优先级矩阵、复合公式、指数衰减 (T₁/₂=14月)、NR 转移税 (τ=0.30)、新入者 2x 加速器 (10 任务令上限)、不可变事件日志 (哈希链)、9 个 API 端点、12 项反游戏防御。整合 PEER、CCR、Slashing、CP Promotion、Elastic Forking 五协议的 NR 更新逻辑至单一写入入口。 |
| v2.2 | 2026-05-27 | **NR 燃烧机制与动态衰减版本**。新增 §十三 NR 燃烧机制（五个出口：治理权投票消耗/优先权竞价消耗/准入权一次性消耗/评审消费消耗/声誉市场查询消耗 V2.0 预留）；活跃税（6 个月无活动 → 衰减速率 ×2）；动态衰减调整（NR 总量月增长 >20% → 半衰期 14→10 月，<5% → 半衰期 14→18 月）；实时仪表盘（7 项 NR 宏观指标）；NR 燃烧博弈论综合分析（防通胀、贡献证明、与 VT 本质区别）。更新协议标识符至 NR_StateMachine.2.2。 |

---

*NR Unified State Machine Protocol v2.2 — 2026-05-27*
*依赖模型三 v2.0 (NR 信号博弈 ESS) 及 协议 05/06/07/08/16*
*新增 §十三：NR 燃烧机制（五出口 + 活跃税 + 动态衰减 + 实时仪表盘）*
