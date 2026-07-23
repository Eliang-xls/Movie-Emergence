# 阶梯式燃烧协议 (Tiered Slashing Protocol)
## CONC Task-Level Default Gradation Protocol — v1.0

**文档编号**: CONC-PROTO-SLASH-001
**状态**: Formal Specification (正式规范)
**来源**: 吸收自 Core Axioms v2.2 §公理四 与 Gemini RFC-001 §3.1，融合为独立协议规范
**分类**: 核心协议 (Core Protocol), 博弈论 (Game Theory), 状态机 (State Machine)
**依赖**: 
- `01_Core/02_Core_Axioms.md` §公理四（阶梯式燃烧公式与三段分段函数）
- `03_Protocols/04_CTCP_CSIP_Specification.md` §6.1（CTCP 博弈引擎内燃烧计算）
- `03_Protocols/01_Protocol_Layer.md` §3.4（任务令 DAG 路由与生命周期）
- `02_Models/02_ALP_Stability_v2.md` §5（保险池余额动力学）

---

## 摘要 (Abstract)

本规范定义 CONC 网络中**任务级违约的灰度处理机制**——阶梯式燃烧协议 (Tiered Slashing Protocol)。该协议将任务令超时违约从二值化处理（完成=全额退还 / 未完成=全额燃烧）演进为**三相连续状态机**：宽限期（零惩罚）、线性燃烧期（时间比例惩罚）、强制熔断（全额没收并归还任务令至广播池）。协议设计消除了"一旦接近超时，放弃是最优策略"的逆向激励，确保"晚交付比不交付好"。

本规范补全了协议完备性审计（`03_Protocol_Completeness_Audit.md`）中标记的 P1 缺口——此前阶梯式燃烧仅有公式（35% 完备度），缺失状态机、API 端点与 ALP 保险池集成。本规范将完备度从 35% 提升至 90%。

---

## 目录

1. [设计哲学：为什么需要灰度违约](#1-设计哲学)
2. [参数定义与公式](#2-参数定义与公式)
3. [三相状态机](#3-三相状态机)
4. [与 CTCP 生命周期集成](#4-与-ctcp-生命周期集成)
5. [与 ALP 保险池的关系](#5-与-alp-保险池的关系)
6. [API 端点](#6-api-端点)
7. [边界条件与安全约束](#7-边界条件与安全约束)
8. [实现检查清单](#8-实现检查清单)

---

## 1. 设计哲学

### 1.1 问题：二值化违约的逆向激励

在传统的二值化违约模型中：

- 任务令在预估时间 $\hat{t}$ 内完成 → 质押全额退还，获得全额回报。
- 任务令超时未完成 → 质押全额燃烧，无回报。

**逆向激励分析**：设承接方在任务执行过程中发现将超时 Δ 时间。在二值化模型中：
- 若继续执行并交付 → 质押全额燃烧（因超时），回报为零，净损失 = $S_{total}$。
- 若立即放弃 → 质押全额燃烧，无额外执行成本，净损失 = $S_{total}$。

**两个选择的净损失完全相同**——但"继续执行"需要额外投入时间和算力。理性选择是**立即放弃**。这就是二值化违约的逆向激励：它惩罚"坚持完成"，奖励"早放弃"。

### 1.2 解决方案：灰度惩罚

阶梯式燃烧协议的核心洞察：**违约成本应随超时程度连续增长**。

设承接方发现将超时 Δ 时间：
- 若立即交付（完成但超时 Δ）→ 仅燃烧 $S_{total} \cdot \alpha \cdot \Delta$，剩余质押退还，仍可获部分回报。
- 若拖延至强制熔断 → 全额质押没收，无回报。

**"晚交付比不交付好"**——超时越短，保留越多。这消除了"既然已违约不如彻底放弃"的逆向激励。

### 1.3 设计原则

1. **连续性**：惩罚随超时线性增长，无突变（除最终熔断外）。
2. **容错性**：宽限期内零惩罚——承认合理的时间偏差（网络延迟、环境配置、偶然阻塞）。
3. **有界性**：最大惩罚为 50% 质押燃烧（线性期）+ 50% 质押没收（熔断期）= 100% 质押损失。不存在"无限燃烧"。
4. **可审计性**：所有燃烧计算基于链上可验证的系统时钟和任务令创建时间戳，第三方可独立复现。
5. **保险回流**：燃烧/没收的质押物不销毁——流入 ALP 保险池，为系统级稳定性提供资金（见 §5）。

---

## 2. 参数定义与公式

### 2.1 参数表

| 符号 | 名称 | 定义 | 来源 | 默认值 |
|:---|:---|:---|:---|:---:|
| $\hat{t}$ | 预估用时 | 任务令预估执行时间（秒） | CTCP `3_Matching_Layer.Compute_Requirement.Estimated_Agent_Time` | 由发起方指定 |
| $t$ | 实际用时 | 自 `EXECUTING` 状态进入时刻起算的实际时间（秒） | 系统时钟 (`block.timestamp`) | — |
| $t_{grace}$ | 宽限期 | 零惩罚缓冲时间 | $t_{grace} = \hat{t} \times 0.10$ | $\hat{t} \times 10\%$ |
| $\alpha$ | 线性燃烧率 | 单位时间燃烧质押物的比例 | CTCP `4_Game_Theory_Layer.Slash_Condition.Linear_Burn_Rate` | 0.01 / 小时 |
| $S_{total}$ | 总质押量 | 承接方锁定的质押物总量（NR 点数） | CTCP `4_Game_Theory_Layer.Stake_Required` | 由发起方指定 |
| $t_{abort}$ | 强制熔断点 | 线性燃烧期的终点——超过此时间触发强制熔断 | $t_{abort} = \hat{t} \times 1.50$ | $\hat{t} \times 150\%$ |
| $t_0$ | 燃烧起点 | 线性燃烧开始的时间点 | $t_0 = \hat{t} + t_{grace}$ | — |
| $S_{burn}$ | 当前燃烧量 | 截至时间 $t$ 已燃烧的质押物数量 | 分段函数（见 §2.2） | — |
| $S_{max\_burn}$ | 最大线性燃烧量 | 线性燃烧期可燃烧的最大质押物 | $S_{max\_burn} = 0.5 \cdot S_{total}$ | — |

### 2.2 分段函数

#### 阶段一：宽限期 (GRACE_PERIOD)

**条件**：$t \leq \hat{t} + t_{grace}$

$$S_{burn} = 0$$

承接方在宽限期内完成超时提交，不扣除任何质押物。系统承认合理的时间偏差——因网络延迟、环境配置或偶然阻塞导致的轻微超时不应触发惩罚。

> **注意**：即使在宽限期内完成，`Slashed_CTCPs` 仍 +1（作为延迟记录），但 `Reliability_Score` 衰减系数为 0.95（轻度衰减，区别于线性燃烧期的 0.85）。

#### 阶段二：线性燃烧期 (LINEAR_BURN)

**条件**：$\hat{t} + t_{grace} < t < t_{abort}$ 且 $S_{burn} < 0.5 \cdot S_{total}$

$$S_{burn} = S_{total} \cdot \alpha \cdot (t - t_0)$$

其中 $t_0 = \hat{t} + t_{grace}$ 为燃烧起点。

**以小时为单位的等价形式**（$\alpha = 0.01/\text{小时}$）：

$$S_{burn} = S_{total} \cdot 0.01 \cdot \frac{t - t_0}{3600}$$

**线性燃烧速率**：$\frac{dS_{burn}}{dt} = S_{total} \cdot \alpha$（常数）。每超时 1 小时，燃烧 1% 的总质押物。

**示例**：若 $\hat{t} = 7200$ 秒（2小时），$S_{total} = 500$ NR：
- $t_{grace} = 720$ 秒（12分钟）
- $t_0 = 7920$ 秒
- 超时 1 小时后（$t = 11520$）→ $S_{burn} = 500 \cdot 0.01 \cdot (3600/3600) = 5$ NR
- 超时 25 小时后 → $S_{burn} = 500 \cdot 0.01 \cdot 25 = 125$ NR
- 超时 50 小时后 → $S_{burn} = 500 \cdot 0.01 \cdot 50 = 250$ NR = $0.5 \cdot S_{total}$ → **触发强制熔断**

#### 阶段三：强制熔断 (FORCED_ABORT)

**条件**：$t \geq t_{abort}$ **或** $S_{burn} \geq 0.5 \cdot S_{total}$

触发以下原子操作序列：

1. **终止执行权**：承接方的执行许可被撤销，本地算力分配回收。
2. **全额没收**：剩余质押物 $S_{total} - S_{burn}$（至少 $0.5 \cdot S_{total}$）被没收。
   - 总损失 = 已燃烧 $S_{burn}$ + 没收剩余 = $S_{total}$（全额质押损失）。
3. **永久污点**：承接方 CSIP 中 `Slashed_CTCPs += 1`。
4. **可靠性降级**：$Reliability\_Score_{new} = Reliability\_Score_{old} \times 0.5$。
5. **信任层级重评**：`Trust_Tier` 自动重新评估（可能降级，最低至 T5）。
6. **任务令回归**：任务令状态重置 → `BROADCAST`，重新开放全网匹配。
7. **质押物回流**：没收的全部质押物（$S_{total} - S_{burn}$）流入 ALP 创世保险池（见 §5）。

### 2.3 公式总图

```
S_burn
  │
  │                              ┌──────────────────────────────
  │                              │  FORCED_ABORT: 全额没收
  │                              │  S_burn = S_total
 0.5·S_total ──────────────────┤  (剩余质押物没收)
  │                        ╱    │
  │                   ╱         │
  │              ╱              │
  │         ╱  LINEAR_BURN      │
  │    ╱    S_burn = S_total·α·(t - t₀)
  │ ╱                           │
  │╱                            │
──┼────────┬────────────────────┼─────────▶ t
  0       t₀                    t_abort
          (t̂ + t_grace)         (t̂ × 1.50)
  
  GRACE_PERIOD: S_burn = 0
```

---

## 3. 三相状态机

### 3.1 状态定义

阶梯式燃烧协议在任务令生命周期中引入三个内部子状态，均隶属于 CTCP 的 `DECAYING_SLASHED` 大状态。**状态机不是独立于 CTCP 的——它是 `DECAYING_SLASHED` 内部的三阶段细化。**

```
DECAYING_SLASHED (CTCP 大状态)
  │
  ├── 子状态 1: GRACE_PERIOD   (宽限期)
  ├── 子状态 2: LINEAR_BURN    (线性燃烧期)
  └── 子状态 3: FORCED_ABORT   (强制熔断)
```

### 3.2 状态跃迁图

```
                         进入 DECAYING_SLASHED
                    (超时 / 心跳丢失 / 验证失败 / 弹劾)
                                  │
                                  ▼
                         ┌─────────────────┐
                         │   GRACE_PERIOD   │
                         │  S_burn = 0      │
                         │  t ≤ t̂ + t_grace │
                         └────────┬────────┘
                                  │
                    ┌─────────────┼─────────────┐
                    │ t > t̂ + t_grace           │ 承接方提交成果
                    │ (超时但仍在宽限期内       │ (Commit)
                    │  完成 → 见 §3.3)         │
                    ▼                           ▼
           ┌─────────────────┐         ┌─────────────────┐
           │   LINEAR_BURN    │         │  → VALIDATING   │
           │  S_burn 线性增长  │         │ (回归正常流程,   │
           │  t₀ < t < t_abort│         │  Slashed +1,    │
           └────────┬────────┘         │  Reliability ×0.95)
                    │                  └─────────────────┘
        ┌───────────┼───────────┐
        │ S_burn ≥ 0.5·S_total │ 承接方提交成果
        │ 或 t ≥ t_abort       │ (Commit)
        ▼                       ▼
 ┌─────────────────┐    ┌─────────────────┐
 │  FORCED_ABORT    │    │  → VALIDATING   │
 │ 全额没收剩余质押   │    │ (回归正常流程,   │
 │ 任务令→BROADCAST  │    │  Slashed +1,    │
 │ 质押物→ALP保险池  │    │  Reliability ×0.85,
 └─────────────────┘    │  S_burn 扣除)    │
                        └─────────────────┘
```

### 3.3 各状态详细说明

#### 3.3.1 `GRACE_PERIOD` — 宽限期

| 属性 | 值 |
|:---|:---|
| **进入条件** | 任务令从 `EXECUTING` 因超时进入 `DECAYING_SLASHED`。超时判定：$t > \hat{t} + t_{grace}$？否 → 尚未超时（仍在 `EXECUTING`）；是 → 进入 `GRACE_PERIOD`。更准确地说：当系统时钟超过 $\hat{t}$ 但未超过 $\hat{t} + t_{grace}$ 时，处于隐式宽限——承接方仍可正常提交。**`GRACE_PERIOD` 作为显式子状态在超时时刻（$t = \hat{t}$）立即进入**，但燃烧量为零。 |
| **期间操作** | 承接方仍保有执行权。质押物完整锁定。网络不触发任何惩罚。系统持续监控时钟。 |
| **燃烧量** | $S_{burn} = 0$ |
| **退出条件** | (a) 承接方在 $t \leq \hat{t} + t_{grace}$ 内提交成果 → 退出 `DECAYING_SLASHED` 进入 `VALIDATING`；(b) 超时 $t > \hat{t} + t_{grace}$ → 进入 `LINEAR_BURN` |
| **超时回退处理** | 若承接方在宽限期内提交成果：`Slashed_CTCPs += 1`（延迟记录），`Reliability_Score *= 0.95`（轻度衰减），质押全额退还，正常获得回报。 |

**设计意图**：宽限期承认"绝对精确的时间估计是不可能的"。$\hat{t}$ 本身是预估——$\hat{t} \times 10\%$ 的宽限承认了预估的固有噪声。同时 `Slashed_CTCPs += 1` 确保宽限不被滥用——频繁的"恰好踩线"会累积为可靠性降级。

#### 3.3.2 `LINEAR_BURN` — 线性燃烧期

| 属性 | 值 |
|:---|:---|
| **进入条件** | $t > \hat{t} + t_{grace}$（宽限期到期） |
| **期间操作** | 质押物以恒定速率燃烧。系统每 60 秒更新一次 $S_{burn}$。承接方仍保有执行权——可随时提交成果。 |
| **燃烧公式** | $S_{burn} = S_{total} \cdot \alpha \cdot (t - (\hat{t} + t_{grace}))$ |
| **燃烧速率** | $\frac{dS_{burn}}{dt} = S_{total} \cdot \alpha$（常数） |
| **退出条件** | (a) 承接方提交成果 → 退出 `DECAYING_SLASHED` 进入 `VALIDATING`；(b) $S_{burn} \geq 0.5 \cdot S_{total}$ 或 $t \geq t_{abort}$ → 进入 `FORCED_ABORT` |
| **提交回退处理** | 若承接方在线性燃烧期内提交成果：`Slashed_CTCPs += 1`，`Reliability_Score *= 0.85`，已燃烧的 $S_{burn}$ 不退还，剩余 $S_{total} - S_{burn}$ 退还，正常获得回报（回报不因延迟而扣减——惩罚已通过燃烧体现）。 |

**设计意图**：线性燃烧创造了"越早交付，保留越多"的连续激励。在燃烧起点（刚超宽限期），$S_{burn} \approx 0$——立即交付几乎无损。随着时间推移，燃烧量增长——激励承接方尽快完成交付。这是对二值化模型中"既然已违约不如彻底放弃"的直接修复。

#### 3.3.3 `FORCED_ABORT` — 强制熔断

| 属性 | 值 |
|:---|:---|
| **进入条件** | (a) $t \geq t_{abort}$（时间触发）；(b) $S_{burn} \geq 0.5 \cdot S_{total}$（燃烧量触发）——以先到者为准 |
| **触发操作（原子）** | 见 §2.2 阶段三的 7 步原子操作序列 |
| **退出条件** | 终态——任务令回归 `BROADCAST` 后重新进入正常生命周期。承接方永久失去该任务令的承接权。 |
| **不可逆性** | `FORCED_ABORT` 不可上诉——它是协议层自动执行的终局判定。承接方可通过策元内仲裁挑战"超时判定"本身（如证明系统时钟错误），但不能挑战燃烧公式的计算结果。 |

**设计意图**：强制熔断是安全阀——防止承接方无限期占有任务令而不交付。$t_{abort} = \hat{t} \times 150\%$ 的设置确保：超时 50% 后，系统判定承接方大概率无法完成，任务令应归还策元重新分配。$S_{burn} \geq 0.5 \cdot S_{total}$ 的并行条件防止了极端情况——若 $\alpha$ 被设置得极高（远超默认 0.01），强制熔断在燃烧量触及 50% 时即触发，不等待 $t_{abort}$。

### 3.4 状态跃迁表

| 当前状态 | 触发事件 | 目标状态 | 条件 | 副作用 |
|:---|:---|:---|:---|:---|
| `GRACE_PERIOD` | 承接方提交成果 | `VALIDATING` | $t \leq \hat{t} + t_{grace}$（在宽限期内） | Slashed_CTCPs += 1, Reliability_Score *= 0.95 |
| `GRACE_PERIOD` | 宽限期到期 | `LINEAR_BURN` | $t > \hat{t} + t_{grace}$ | S_burn 开始累加（从 0 开始） |
| `LINEAR_BURN` | 承接方提交成果 | `VALIDATING` | $S_{burn} < 0.5 \cdot S_{total}$ 且 $t < t_{abort}$ | Slashed_CTCPs += 1, Reliability_Score *= 0.85, S_burn 扣除 |
| `LINEAR_BURN` | 燃烧触及上限 | `FORCED_ABORT` | $S_{burn} \geq 0.5 \cdot S_{total}$ | 全额没收，任务令 → BROADCAST |
| `LINEAR_BURN` | 时间触及熔断点 | `FORCED_ABORT` | $t \geq t_{abort}$ | 全额没收，任务令 → BROADCAST |
| `FORCED_ABORT` | 终态 | — | — | 不可逆。任务令已回归 BROADCAST |

---

## 4. 与 CTCP 生命周期集成

### 4.1 集成映射

阶梯式燃烧协议是 CTCP 生命周期状态机（`03_Protocols/04_CTCP_CSIP_Specification.md` §4）中 `DECAYING_SLASHED` 状态的**内部细化**。映射关系如下：

```
CTCP 状态机 (六状态)              阶梯式燃烧 (三子状态)

EXECUTING ─────────────────────── 正常运行
    │ (超时触发)
    ▼
DECAYING_SLASHED ──────────────── 进入燃烧协议
    │
    ├── [t ≤ t̂ + t_grace] ───── GRACE_PERIOD
    │       │
    │       ├── 提交成果 → VALIDATING
    │       └── 超时 → 
    │
    ├── [t̂ + t_grace < t < t_abort] ── LINEAR_BURN
    │       │
    │       ├── 提交成果 → VALIDATING
    │       └── S_burn ≥ 0.5·S_total → 
    │
    └── [t ≥ t_abort] ────────── FORCED_ABORT
            │
            └── 任务令 → BROADCAST
```

### 4.2 从 EXECUTING 进入 DECAYING_SLASHED 的条件

CTCP §4.2.3 定义了 `EXECUTING → DECAYING_SLASHED` 的四种触发条件：

| 触发条件 | 进入后初始子状态 | 说明 |
|:---|:---|:---|
| **执行超时**：$t > \hat{t} + t_{grace}$ | `LINEAR_BURN` | 已过宽限期，直接进入燃烧。$t$ 从 $t > \hat{t}$ 时开始计时——即系统检测到超时（$t > \hat{t}$）后给予 $t_{grace}$ 的缓冲，若在这段时间内提交则走宽限期回退。实际执行：在 $t = \hat{t}$ 时进入 `DECAYING_SLASHED` 的 `GRACE_PERIOD`，$t = \hat{t} + t_{grace}$ 时若无提交则转入 `LINEAR_BURN`。 |
| **心跳丢失**：连续 3 次 Proof of Liveness 丢失 | `LINEAR_BURN` | 心跳丢失视为"执行已实质停滞"，不给予宽限期——直接进入线性燃烧。若心跳在宽限期内恢复（>0 次但 <3 次丢失），仍回归正常执行。 |
| **验证失败**：VALIDATING 阶段验证未通过 | `GRACE_PERIOD` | 给予 $t_{grace}$ 的修正窗口——承接方可重新提交。若在宽限期内重新提交并通过 → 进入 MERGED_RESOLVED。若宽限期到期仍未通过 → 进入 `LINEAR_BURN`，并最终 `FORCED_ABORT`。 |
| **被弹劾成功** (Impeachment) | `FORCED_ABORT` | 直接熔断——弹劾是策元共识的最终判定，不给予任何缓冲。 |

### 4.3 从 DECAYING_SLASHED 退出

| 退出路径 | 条件 | 去向 |
|:---|:---|:---|
| 宽限期内提交 | $t \leq \hat{t} + t_{grace}$ 且成果有效 | `VALIDATING` → 正常验证流程 |
| 线性燃烧期内提交 | $\hat{t} + t_{grace} < t < t_{abort}$ 且 $S_{burn} < 0.5 \cdot S_{total}$ 且成果有效 | `VALIDATING` → 正常验证流程 |
| 强制熔断后回归 | $S_{burn} \geq 0.5 \cdot S_{total}$ 或 $t \geq t_{abort}$ | `BROADCAST` → 重新匹配 |

### 4.4 CTCP JSON Schema 中的映射

阶梯式燃烧的所有参数均来自 CTCP 的 `4_Game_Theory_Layer`（`Slash_Condition` 对象）和 `3_Matching_Layer`（`Estimated_Agent_Time`）：

```json
{
  "3_Matching_Layer": {
    "Compute_Requirement": {
      "Estimated_Agent_Time": 7200    // → t̂
    }
  },
  "4_Game_Theory_Layer": {
    "Stake_Required": 500,             // → S_total
    "Slash_Condition": {
      "Timeout_Grace_Period": 720,    // → t_grace (= t̂ × 10%)
      "Linear_Burn_Rate": 0.01        // → α
    }
  }
}
```

**推导关系**：
- $t_{grace}$ = `Timeout_Grace_Period`（由发起方显式设定，默认 $= \hat{t} \times 0.10$）
- $\alpha$ = `Linear_Burn_Rate`
- $t_{abort} = \hat{t} \times 1.50$（协议层硬编码，不可由发起方覆盖）
- $S_{max\_burn} = 0.5 \cdot S_{total}$（协议层硬编码）

---

## 5. 与 ALP 保险池的关系

### 5.1 质押物流向

阶梯式燃烧与 ALP（自动化流动性池）保险池之间存在**质押物回流管道**：

```
承接方质押 S_total
       │
       ├── 正常完成 → 质押全额退还承接方
       │
       ├── 宽限期内完成 → 质押全额退还承接方
       │
       ├── 线性燃烧期内完成 → S_burn 流入 ALP 保险池
       │                       剩余 S_total - S_burn 退还承接方
       │
       └── 强制熔断 → S_burn (已燃烧) 流入 ALP 保险池
                      S_total - S_burn (没收) 流入 ALP 保险池
                      = S_total 全额流入 ALP 保险池
```

### 5.2 保险池注入公式

令 $I_{slash}(t)$ 为时刻 $t$ 因阶梯式燃烧流入 ALP 保险池的累计质押物总量：

$$I_{slash}(t) = \sum_{w \in W_{burned}(t)} S_{burn}(w) + \sum_{w \in W_{aborted}(t)} S_{total}(w)$$

其中：
- $W_{burned}(t)$：截至 $t$ 在线性燃烧期内被部分燃烧且最终完成的任务令集合
- $W_{aborted}(t)$：截至 $t$ 触发强制熔断的任务令集合

ALP 保险池余额 $I(t)$ 的完整动力学（吸收自 `02_Models/02_ALP_Stability_v2.md` §5.1）：

$$\frac{dI}{dt} = \underbrace{\eta \cdot d(\sigma_t) \cdot \alpha V}_{\text{借贷保险提取}} + \underbrace{\frac{dI_{slash}}{dt}}_{\text{阶梯式燃烧注入}} - \underbrace{\eta_{\text{emergency}} \cdot I \cdot \mathbb{1}\{R < \rho\}}_{\text{紧急注资流出}}$$

阶梯式燃烧注入项 $\frac{dI_{slash}}{dt}$ 是 ALP 保险池的**非借贷性收入来源**——它不依赖于借贷活动，而是来自违约惩罚。这为保险池提供了额外的资金韧性。

### 5.3 双重防御体系

阶梯式燃烧与 ALP 保险池构成 CONC 的**双层违约防御**：

| 层级 | 机制 | 粒度 | 触发条件 | 作用 |
|:---|:---|:---|:---|:---|
| **L1: 个体任务级** | 阶梯式燃烧 | 单个任务令 | 任务超时 / 心跳丢失 / 验证失败 | 灰度惩罚个体违约，质押物流入保险池 |
| **L2: 系统级** | ALP 保险池 + 熔断 | 全局 ALP | 储备率 $R < 0.25$ | 自动紧急注资，防止系统性流动性危机 |

**关系**：
- L1 的累积效果（大量任务令触发阶梯式燃烧）→ 增加 $I_{slash}$ → 充实 ALP 保险池 → 增强 L2 防御能力。
- L2 的熔断不影响 L1 中已在执行的任务令——已完成任务的结算不受 ALP 熔断影响。
- 两者互补：L1 处理"个体不履约"，L2 处理"市场不履约"（VT 暴跌 → 大规模清算）。

### 5.4 创世保险池

> 注：CONC 冷启动阶段，ALP 保险池初始余额为零。阶梯式燃烧注入是保险池的**首个资金来源**——最早的违约事件直接为系统注入初始保险储备。随着网络运行，借贷保险提取（$\eta \cdot d \cdot \alpha V$）成为主要资金流，但阶梯式燃烧注入提供的是**反周期资金**——当网络违约率上升时，$I_{slash}$ 增长，正好增强了保险池应对系统性危机的能力。

---

## 6. API 端点

### 6.1 概览

| 端点 | 方法 | 用途 | 访问级别 |
|:---|:---|:---|:---|
| `/task-warrant/{tw_id}/slashing-status` | GET | 查询任务令的当前燃烧状态 | 公开 |
| `/task-warrant/{tw_id}/extend` | POST | 请求宽限期延期 | 承接方 + 策元核批准 |
| `/task-warrant/{tw_id}/slashing-history` | GET | 查询任务令的完整燃烧事件历史 | 公开 |
| `/genesis/{gu_id}/slashing-stats` | GET | 查询策元维度的燃烧统计 | 策元成员 |

### 6.2 `GET /task-warrant/{tw_id}/slashing-status`

查询指定任务令的当前阶梯式燃烧状态。

**请求**：
```
GET /task-warrant/{tw_id}/slashing-status
```

**响应**：
```json
{
  "task_warrant_id": "tw_a1b2c3d4",
  "genesis_id": "gu_x9y8z7w6",
  "current_state": "LINEAR_BURN",
  "sub_state": {
    "phase": "LINEAR_BURN",
    "entered_at": "2026-05-14T14:30:00Z",
    "elapsed_since_entered_seconds": 5400
  },
  "parameters": {
    "estimated_time_seconds": 7200,
    "grace_period_seconds": 720,
    "linear_burn_rate_per_hour": 0.01,
    "total_stake": 500,
    "abort_at_seconds": 10800
  },
  "burn_status": {
    "current_s_burn": 7.5,
    "max_linear_burn": 250.0,
    "remaining_stake": 492.5,
    "burn_percentage": 1.5,
    "time_until_abort_seconds": 4680
  },
  "assignee": {
    "ns_id": "ns_0a1b2c3d",
    "trust_tier": "T2",
    "slashed_ctcps_current": 1,
    "reliability_score": 0.92
  },
  "events": [
    {
      "timestamp": "2026-05-14T14:18:00Z",
      "event": "ENTERED_DECAYING_SLASHED",
      "trigger": "execution_timeout",
      "phase_entered": "GRACE_PERIOD"
    },
    {
      "timestamp": "2026-05-14T14:30:00Z",
      "event": "PHASE_TRANSITION",
      "from_phase": "GRACE_PERIOD",
      "to_phase": "LINEAR_BURN",
      "s_burn_at_transition": 0.0
    }
  ]
}
```

**状态码**：
- `200` — 成功返回燃烧状态
- `404` — 任务令不存在
- `400` — 任务令当前不在 `DECAYING_SLASHED` 状态（返回 `current_state: "NOT_SLASHING"`）

### 6.3 `POST /task-warrant/{tw_id}/extend`

承接方因合理原因（如：上游依赖延迟、环境配置异常、策元核确认的不可抗力）申请宽限期延期。

**请求**：
```json
{
  "requester_ns_id": "ns_0a1b2c3d",
  "extension_reason": "upstream_dependency_delayed",
  "reason_detail": "前置 API 服务 tw_00112233 的 MERGED_RESOLVED 延迟了 4 小时，导致下游阻塞",
  "requested_extension_seconds": 3600,
  "evidence": {
    "type": "dependency_chain_proof",
    "blocking_task_warrant_ids": ["tw_00112233"],
    "dependency_dag_snapshot_cid": "ipfs://bafy..."
  }
}
```

**`extension_reason` 枚举值**：
| 值 | 含义 | 需要证据 |
|:---|:---|:---|
| `upstream_dependency_delayed` | 上游 DAG 依赖延迟 | 是（blocking_task_warrant_ids） |
| `environment_configuration_issue` | 算力环境配置异常（如模型下载失败） | 是（环境日志 CID） |
| `force_majeure` | 不可抗力（如断电、网络中断） | 是（心跳丢失记录） |
| `genesis_core_approved` | 策元核事先批准（如方向微调） | 是（策元核签名） |

**响应**：
```json
{
  "task_warrant_id": "tw_a1b2c3d4",
  "extension_status": "approved",
  "new_grace_period_expiry": "2026-05-14T16:30:00Z",
  "new_abort_at": "2026-05-14T19:00:00Z",
  "approver": "genesis_core_auto",
  "extension_count": 1,
  "max_extensions": 2,
  "note": "宽限期已延长 3600 秒。剩余可延期次数: 1。延期超过 2 次将自动触发策元核人工审核。"
}
```

**延期规则**：
1. **自动批准条件**：`extension_reason` 为 `upstream_dependency_delayed` 或 `environment_configuration_issue`，且 `requested_extension_seconds ≤ 7200`（2小时），且 `extension_count < 2`。
2. **策元核审核条件**：`extension_reason` 为 `force_majeure`，或 `extension_count ≥ 2`，或 `requested_extension_seconds > 7200`。
3. **拒绝条件**：策元核审核不通过，或 `extension_count > 3`（硬上限——防止无限延期）。
4. **副作用**：每次延期将 $t_{abort}$ 等量延长（$t_{abort} \mathrel{+}= \text{extension\_seconds}$）。$\hat{t}$ 不回溯修正——延期是应对特殊情况的例外机制，不是常规的时间估计修正。

**状态码**：
- `200` — 延期批准
- `202` — 延期已提交，等待策元核审核
- `403` — 请求者不是承接方
- `409` — 延期次数已达上限
- `422` — 证据不足或 reason_detail 为空

### 6.4 `GET /task-warrant/{tw_id}/slashing-history`

查询任务令的完整阶梯式燃烧事件历史（包括已结束的燃烧事件）。

**请求**：
```
GET /task-warrant/{tw_id}/slashing-history?limit=50&offset=0
```

**响应**：
```json
{
  "task_warrant_id": "tw_a1b2c3d4",
  "total_slashing_events": 2,
  "events": [
    {
      "slashing_event_id": "se_001",
      "assignee_ns_id": "ns_0a1b2c3d",
      "trigger": "execution_timeout",
      "entered_at": "2026-05-14T14:18:00Z",
      "exited_at": "2026-05-14T16:45:00Z",
      "resolution": "FORCED_ABORT",
      "total_s_burn": 500.0,
      "total_stake_original": 500.0,
      "phases": [
        {
          "phase": "GRACE_PERIOD",
          "entered_at": "2026-05-14T14:18:00Z",
          "exited_at": "2026-05-14T14:30:00Z",
          "reason": "grace_period_expired"
        },
        {
          "phase": "LINEAR_BURN",
          "entered_at": "2026-05-14T14:30:00Z",
          "exited_at": "2026-05-14T16:45:00Z",
          "reason": "burn_limit_reached",
          "s_burn_at_exit": 250.0
        },
        {
          "phase": "FORCED_ABORT",
          "entered_at": "2026-05-14T16:45:00Z",
          "exited_at": "2026-05-14T16:45:00Z",
          "reason": "full_confiscation",
          "remnant_stake_confiscated": 250.0
        }
      ],
      "alp_insurance_pool_deposit": 500.0
    },
    {
      "slashing_event_id": "se_002",
      "assignee_ns_id": "ns_4d5e6f7g",
      "trigger": "execution_timeout",
      "entered_at": "2026-05-15T09:00:00Z",
      "exited_at": "2026-05-15T10:15:00Z",
      "resolution": "COMPLETED_IN_LINEAR_BURN",
      "total_s_burn": 12.5,
      "total_stake_original": 500.0,
      "returned_stake": 487.5,
      "phases": [
        {
          "phase": "GRACE_PERIOD",
          "entered_at": "2026-05-15T09:00:00Z",
          "exited_at": "2026-05-15T09:12:00Z",
          "reason": "grace_period_expired"
        },
        {
          "phase": "LINEAR_BURN",
          "entered_at": "2026-05-15T09:12:00Z",
          "exited_at": "2026-05-15T10:15:00Z",
          "reason": "assignee_committed",
          "s_burn_at_exit": 12.5
        }
      ],
      "alp_insurance_pool_deposit": 12.5
    }
  ]
}
```

### 6.5 `GET /genesis/{gu_id}/slashing-stats`

查询策元维度的聚合燃烧统计，供策元核监控和策元健康评估。

**请求**：
```
GET /genesis/{gu_id}/slashing-stats?window_days=30
```

**响应**：
```json
{
  "genesis_id": "gu_x9y8z7w6",
  "window_days": 30,
  "aggregate_stats": {
    "total_task_warrants_slashed": 5,
    "total_s_burn_all_time": 1250.5,
    "total_alp_insurance_deposited": 1250.5,
    "forced_abort_count": 2,
    "completed_in_grace_period_count": 1,
    "completed_in_linear_burn_count": 2
  },
  "per_assignee_top_slashed": [
    {
      "ns_id": "ns_0a1b2c3d",
      "slashed_count": 2,
      "total_burned": 512.5,
      "current_reliability_score": 0.46,
      "current_trust_tier": "T4"
    }
  ],
  "phase_distribution": {
    "grace_period_resolved_pct": 20.0,
    "linear_burn_resolved_pct": 40.0,
    "forced_abort_pct": 40.0
  },
  "average_burn_per_slashing": 250.1
}
```

---

## 7. 边界条件与安全约束

### 7.1 参数边界

| 参数 | 最小值 | 最大值 | 默认值 | 约束理由 |
|:---|:---:|:---:|:---:|:---|
| $\hat{t}$ (预估用时) | 60 秒 | 2,592,000 秒 (30天) | 由发起方指定 | 低于 60s 的任务粒度不适用于 CTCP 协议（建议使用自动化微任务）；超过 30 天建议拆分 |
| $t_{grace}$ (宽限期) | $\max(60, \hat{t} \times 0.05)$ | $\hat{t} \times 0.20$ | $\hat{t} \times 0.10$ | 最小 60 秒确保网络延迟容错；最大 20% 防止宽限期占比过高削弱违约威慑 |
| $\alpha$ (线性燃烧率) | 0.001 /小时 | 0.10 /小时 | 0.01 /小时 | 低于 0.001 则威慑不足（超时 500 小时才燃烧 50%）；高于 0.10 则退化为近似二值化 |
| $t_{abort}$ (强制熔断) | $\hat{t} \times 1.20$ | $\hat{t} \times 2.00$ | $\hat{t} \times 1.50$ | 协议层硬编码 `t̂ × 1.50`。范围仅供未来参数治理参考 |
| 延期次数上限 | 0 | 3 | 3 | 硬上限——防止无限延期 |
| 单次延期时长 | 600 秒 | 7,200 秒 (2小时) | — | 单次不超过 2 小时。超过需策元核人工审核 |

### 7.2 安全约束

#### 7.2.1 时钟依赖与抗操纵

阶梯式燃烧依赖系统时钟判定超时。为防止时钟操纵攻击：

1. **时间戳来源**：使用区块链 `block.timestamp`（而非本地时钟）作为权威时间源。在 L2/侧链部署中，使用 L1 锚定时间戳。
2. **最大可接受时钟漂移**：120 秒。若 `block.timestamp` 与 NTP 同步时间的偏差超过 120 秒，协议层暂停所有燃烧计算，进入 `CLOCK_DRIFT_SAFEGUARD` 模式。
3. **心跳探针时间戳**：Proof of Liveness 心跳使用 `block.timestamp` 验证，不接受承接方本地时钟。

#### 7.2.2 重入防护

`S_burn` 计算和质押物扣除在同一原子事务中执行。防止以下攻击：
- **重入燃烧**：承接方在燃烧扣除进行中重复提交成果。
- **质押双重扣除**：已燃烧的质押物在后续事务中被再次扣除。

实现方案：`DECAYING_SLASHED` 状态的所有写操作通过互斥锁（per-task-warrant mutex）序列化。

#### 7.2.3 燃烧下限 (Dust Protection)

若 $S_{burn} < 1.0$ NR（即燃烧量低于 1 NR 点），不执行实际的质押物扣除——视为"零燃烧"。这防止了微小的超时（如超时 1 分钟，燃烧量 $= 500 \cdot 0.01 \cdot 1/60 \approx 0.083$ NR）触发不必要的链上交易。

**Dust 累积**：小于 1.0 NR 的燃烧量在任务令维度累积——当累积超过 1.0 NR 时，一次性扣除。

#### 7.2.4 策元核超控

策元核（Genesis Core）在以下情况下可超控燃烧协议：

1. **系统级异常**：策元核确认网络分区或共识层故障导致超时误判 → 可执行 `POST /task-warrant/{tw_id}/extend` 的 `genesis_core_approved` 模式。
2. **不可抗力验证**：策元核确认不可抗力证据（如区域性断电的多个节点同时心跳丢失）→ 可全额退还质押。
3. **超控限制**：策元核超控需策元内 ≥ 2/3 核成员签名。超控记录写入 CCR 公开账本。

---

## 8. 实现检查清单

- [ ] **三相状态机引擎**：实现 `GRACE_PERIOD → LINEAR_BURN → FORCED_ABORT` 的状态跃迁逻辑，包括全部触发条件和副作用
- [ ] **S_burn 实时计算**：基于 `block.timestamp` 和任务令进入 `DECAYING_SLASHED` 时间戳，每秒更新 $S_{burn}$
- [ ] **CTCP 状态机集成**：将三相状态机嵌入 CTCP 的 `DECAYING_SLASHED` 大状态
- [ ] **GET /task-warrant/{id}/slashing-status**：实现完整查询端点，返回当前相、参数、燃烧量、事件历史
- [ ] **POST /task-warrant/{id}/extend**：实现延期请求端点，包括自动批准、策元核审核、次数上限和 $t_{abort}$ 联动更新
- [ ] **GET /task-warrant/{id}/slashing-history**：实现完整历史端点，支持分页
- [ ] **GET /genesis/{id}/slashing-stats**：实现策元维度聚合统计
- [ ] **ALP 保险池注入管道**：实现 $S_{burn}$ → ALP 保险池的自动转账逻辑
- [ ] **时钟漂移保护**：实现 `block.timestamp` 校验和 `CLOCK_DRIFT_SAFEGUARD` 模式
- [ ] **Dust Protection**：实现 <1.0 NR 的燃烧量累积和一次性扣除逻辑
- [ ] **重入防护**：实现 per-task-warrant 互斥锁
- [ ] **策元核超控**：实现多签验证的燃烧协议覆写逻辑
- [ ] **事件日志**：所有相变、燃烧扣除、熔断触发写入不可篡改事件日志

---

## 附录 A: 与 Core Axioms §公理四 的差异

| 项目 | Core Axioms v2.2 §公理四 | 本规范 (正式协议) | 变更理由 |
|:---|:---|:---|:---|
| $t_{abort}$ 定义 | $\hat{t} \times 150\%$ | $\hat{t} \times 150\%$（协议层硬编码） | 保持一致 |
| $t_{grace}$ 定义 | $\hat{t} \times 10\%$ | $\hat{t} \times 10\%$（有界 [5%, 20%]） | 增加安全边界 |
| $\alpha$ 定义 | 0.01/小时 | 0.01/小时（有界 [0.001, 0.10]） | 增加参数合法性校验 |
| 状态机 | 无 | 三相状态机（GRACE_PERIOD → LINEAR_BURN → FORCED_ABORT） | 核心补全 |
| API | 无 | 4 个端点 + 延期机制 | 核心补全 |
| ALP 集成 | 描述性提及 | 完整质押物流向公式 + 保险池动力学 | 核心补全 |
| 安全约束 | 无 | 时钟依赖保护 + 重入防护 + Dust Protection + 超控机制 | 核心补全 |

---

## 附录 B: 与 CTCP §6.1 的关系

本规范是 CTCP §6.1（阶梯式燃烧协议）的**独立正式化**。CTCP §6.1 作为 CTCP 规范的内嵌章节描述了公式——本规范将其提取为独立协议，补全了状态机、API 端点、ALP 集成和安全约束。两者关系：

- **CTCP §6.1**：定义 CTCP 语境下的公式与参数映射（`Estimated_Agent_Time` → $\hat{t}$ 等）。
- **本规范**：定义协议无关的完整燃烧协议——可被任何需要灰度违约处理的 CONC 协议引用（不仅限于 CTCP 任务令，未来可扩展至能证挑战、PEER 评审违约等场景）。

---

*Hermes Agent — 架构师与逻辑编译器*
*阶梯式燃烧协议 v1.0 — 三相状态机 + 分段函数 + 4 API 端点 + ALP 保险池集成 + 安全约束。将公理四的 35% 完备度提升至 90%。*
