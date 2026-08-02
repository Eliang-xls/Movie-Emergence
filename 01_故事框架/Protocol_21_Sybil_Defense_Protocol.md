# CONC 女巫防御协议规范
## Sybil Defense Protocol Specification v1.0

> 协议标识符：`CONC-Protocol/Sybil_Defense.1.0`
> 依赖：智权体身份协议 CSIP (02)、PEER 验证协议 (05)、CCR 公开账本 (06)、NR 统一状态机 (17)、能证晋级管道 (16)
> 协议层归属：身份层 (Identity Layer) — 注册防伪与真实性验证
>
> **完备度声明**：本规范定义 CONC 网络的女巫攻击防御体系（完备度 0% → 85%+）。覆盖三层递进式防御机制——基础门槛（L1）、增强检测（L2）、社区举报与 NR 质押挑战（L3）。包含完整的数据模型、API 端点、状态机及渐进式降级策略，确保 CONC 网络在开放注册与抗女巫之间取得均衡。

---

## 〇、协议定位与设计概要

### 0.1 问题定义：女巫攻击威胁模型

女巫攻击（Sybil Attack）是指单一实体通过创建大量虚假身份，操纵分布式网络中的共识、投票或声誉系统的攻击方式。在 CONC 网络中，女巫攻击的具体威胁包括：

| 威胁类型 | 攻击方式 | 危害 |
|----------|---------|------|
| **PEER 评审操纵** | 虚假身份互评刷分 | 扭曲 NR 信号，破坏模型三的 ESS 均衡 |
| **CCR 虚增** | 虚假身份间虚假协作 | 虚增贡献记录，稀释真实贡献者的 NR 份额 |
| **策元挟持** | 大量虚假身份加入同一策元 | 控制 PCP 投票，劫持策元方向 |
| **能证欺诈** | 虚假身份伪造能证 | 获取不应得的任务令准入权限 |
| **空投猎取** | 批量注册骗取初始 NR | 稀释新入者加速器效果 |

### 0.2 在协议栈中的位置

```
┌─────────────────────────────────────────────────────────┐
│  第六层：价值层 (Value Layer)                            │
│  VT · NR 统一状态机 · CCR · ALP                          │
├─────────────────────────────────────────────────────────┤
│  第五层：验证层 (Verification Layer)                     │
│  AUTO/PEER(n)/MARKET · 共识仲裁                          │
├─────────────────────────────────────────────────────────┤
│  第四层：协作层 (Collaboration Layer)                     │
│  工作区 · Gate 门控 · GHF 审计                           │
├─────────────────────────────────────────────────────────┤
│  第三层：策元层 (Genesis Layer)                          │
│  策元 CRUD · 任务令 DAG · 弹性分叉                       │
├─────────────────────────────────────────────────────────┤
│  第二层：身份层 (Identity Layer)  ← 本协议               │
│  智权体注册 · 能证 · 身份锚定 · ★ 女巫防御               │
├─────────────────────────────────────────────────────────┤
│  第一层：网络层 (Network Layer)                          │
│  节点发现 · 消息广播 · 状态同步                           │
└─────────────────────────────────────────────────────────┘
```

本协议位于身份层（L2），作为智权体注册流程的**前置安全过滤器**。所有新身份注册及策元加入操作均须通过本协议的三层防御检测后，方可进入后续的能证发行和 NR 初始化流程。

### 0.3 理论溯源

| 理论来源 | 核心主张 | 在本协议中的体现 |
|----------|---------|-----------------|
| **公理四（模块承诺）** | 每个模块的产出必须有明确的完成定义和可验证的交付标准 | 每层防御有明确的通过/标记条件，检测结果可验证、可复现 |
| **模型三（NR 信号博弈 ESS）** | NR 作为信号博弈的演化稳定策略，前提是信号发送成本 > 伪造收益 | 三层防御提升伪造身份的边际成本——L1 时间成本、L2 行为一致性成本、L3 质押惩罚成本 |
| **本原零（自利与秩序恒常）** | 理性参与者在充分信息下选择遵守协议 | 举报质押机制使恶意举报的期望成本超过收益，诚实举报的期望收益超过成本 |

### 0.4 设计原则

1. **纵深防御 (Defense in Depth)**：三层递进——单层被突破不影响后续层的有效性。
2. **成本不对称 (Cost Asymmetry)**：对诚实用户保持低成本（静默通过），对攻击者施加递增成本。
3. **可审计性 (Auditability)**：所有检测结果和举报裁决上链记录，第三方可独立复现验证。
4. **渐进式降级 (Graceful Degradation)**：当冷启动困难时，可降级至宽松模式而非完全关闭防御。
5. **社区共治 (Community Governance)**：举报机制由社区驱动，NR 质押确保举报的严肃性。

---

## 一、三层防御体系总览

```
                         ┌──────────────────────┐
         新身份注册      │                      │
         策元加入请求 →  │  L1: 基础门槛        │
                         │  ┌────────────────┐  │
                         │  │ 账号年龄 ≥ 6月  │  │
                         │  │ 贡献 ≥ 50      │  │
                         │  │ 排除 Bot/Spam  │  │
                         │  └───────┬────────┘  │
                         │     通过  │  拒绝     │
                         │          ↓          │
                         │  L2: 增强检测        │
                         │  ┌────────────────┐  │
                         │  │ commit 模式分析 │  │
                         │  │ 仓库质量检测    │  │
                         │  │ Star 真实性     │  │
                         │  │ 行为时间序列    │  │
                         │  │ 跨平台交叉验证  │  │
                         │  └───────┬────────┘  │
                         │     通过  │  标记     │
                         │          ↓          │
                         │  L3: 举报机制        │
                         │  ┌────────────────┐  │
                         │  │ 社区举报+NR质押 │  │
                         │  │ 3人独立评审     │  │
                         │  │ 举报成立/不成立 │  │
                         │  └───────┬────────┘  │
                         │     通过  │  裁决     │
                         │          ↓          │
                         │  ✅ 准予注册/加入    │
                         └──────────────────────┘
```

三层的执行时序与职责：

| 层级 | 检查时机 | 执行方式 | 失败后果 |
|------|---------|---------|---------|
| **L1 基础门槛** | 注册时 + CP_BOOTSTRAP 创建时 | 自动 | 拒绝注册 / 拒绝策元加入 |
| **L2 增强检测** | 注册通过后、每次 PEER 评审前 | 自动 | 标记为 `provisional` 信任状态 |
| **L3 举报机制** | 持续（社区触发） | 人工评审 | 被举报者 NR 归零 + 能证降级 / 举报者 NR 扣除 |

---

## 二、第一层：基础门槛 (Base Threshold)

### 2.1 门槛定义

L1 是自动化的准入过滤器，在以下时机触发：
- **智权体注册时**（`ns_register` 调用）
- **CP_BOOTSTRAP 创建时**（策元加入请求）

#### 2.1.1 平台账号年龄

| 参数 | 默认值 | 说明 |
|------|:---:|------|
| `MIN_ACCOUNT_AGE_DAYS` | 180 | GitHub 账号从创建日至检查日的天数 |
| 计算方式 | `NOW() - account.created_at` | 精确到日 |

> **设计依据**：6 个月的账号年龄门槛使批量注册的成本（时间 + 等待）显著高于可能的攻击收益。此门槛参考了 Gitcoin Passport 和 Worldcoin 的最佳实践。

#### 2.1.2 总贡献最低值

| 参数 | 默认值 | 说明 |
|------|:---:|------|
| `MIN_TOTAL_CONTRIBUTIONS` | 50 | commits + PRs + issues + reviews 的总和 |
| 计算方式 | `SUM(commits, pull_requests, issues, code_reviews)` | 取 GitHub 公开统计 |

> **注意**：此处的「贡献」仅为 L1 的粗粒度计数。L2 将对贡献的**质量**进行深入分析。

#### 2.1.3 账号类型排除

以下类型的 GitHub 账号**直接拒绝**，不进入后续检测：

| 排除类型 | 判定依据 | 说明 |
|----------|---------|------|
| **Bot 账号** | GitHub API `type == "Bot"` | 自动化机器人账号 |
| **Spam 标记账号** | GitHub 社区标记为 spam | 已被 GitHub 社区识别 |
| **Fork-only 账号** | 100% 仓库为 fork 且无原创 commit | 零原创贡献 |

### 2.2 L1 检查流程

```
┌──────────────────────────────────────────────────────────────────┐
│  L1_CHECK(ns_id, platform_data)                                  │
│                                                                  │
│  1. account_type = platform_data.github_account.type             │
│     IF account_type == "Bot" OR marked_as_spam:                  │
│         → REJECT("ACCOUNT_TYPE_EXCLUDED")                       │
│                                                                  │
│  2. account_age = NOW() - platform_data.github_account.created_at│
│     IF account_age < MIN_ACCOUNT_AGE_DAYS:                       │
│         → REJECT("ACCOUNT_AGE_INSUFFICIENT",                    │
│                   remaining_days = MIN_ACCOUNT_AGE_DAYS - age)   │
│                                                                  │
│  3. total_contrib = SUM(commits, prs, issues, reviews)           │
│     IF total_contrib < MIN_TOTAL_CONTRIBUTIONS:                  │
│         → REJECT("CONTRIBUTIONS_INSUFFICIENT",                   │
│                   shortfall = MIN_TOTAL_CONTRIBUTIONS - total)   │
│                                                                  │
│  4. IF all checks passed:                                        │
│         → PASS → 进入 L2 增强检测                                 │
└──────────────────────────────────────────────────────────────────┘
```

### 2.3 L1 数据记录

每次 L1 检查结果写入 `sybil_checks` 表：

```sql
INSERT INTO sybil_checks (ns_id, layer, check_time, passed, evidence)
VALUES (
  :ns_id,
  'L1',
  NOW(),
  :passed,
  jsonb_build_object(
    'account_age_days', :age,
    'total_contributions', :contrib,
    'account_type', :type,
    'platform', 'github'
  )
);
```

---

## 三、第二层：增强检测 (Enhanced Detection)

### 3.1 概述

L1 通过者进入 L2 增强检测。L2 不直接拒绝注册，而是计算**女巫风险分数 (Sybil Risk Score, SRS)**，并根据 SRS 将身份标记为不同的信任状态。

### 3.2 检测维度

#### 3.2.1 Commit 模式分析

检测空洞 commit——即仅修改 README.md、package.json 版本号等无实质代码变更的 commit。

| 检测规则 | 阈值 | 风险权重 |
|----------|:---:|:---:|
| README-only commit 占比 | > 40% | +15 |
| package.json / Cargo.toml 等仅元数据修改 | > 30% | +10 |
| 单行修改 commit 占比 | > 50% | +10 |
| 平均每次 commit 的 diff 行数 | < 3 行 | +5 |
| 所有 commit 集中在单一仓库 | 100% | +5 |

**实现参考**：

```
hollow_ratio = count(readme_only_commits + metadata_only_commits) / total_commits
IF hollow_ratio > 0.40 → risk += 15
IF hollow_ratio > 0.30 → risk += 10
```

#### 3.2.2 仓库质量检测

| 检测规则 | 阈值 | 风险权重 |
|----------|:---:|:---:|
| Fork-without-change 仓库占比 | > 60% | +20 |
| 零星仓库占比 | > 70% | +10 |
| 空仓库（zero commits from owner） | 存在 | +15 |
| 仓库描述为空 / 无 README | > 50% | +5 |

**Fork-without-change 检测**：比对 fork 仓库与上游仓库的 diff。若 fork 后未产生任何原创 commit，标记为 fork-without-change。

#### 3.2.3 Star 真实性检测

| 检测规则 | 计算公式 | 风险阈值 | 权重 |
|----------|---------|:---:|:---:|
| Star/Engagement 异常比率 | `stars / (forks + watchers + 1)` | > 50 | +20 |
| Star 时间集中度 | 单日 Star 增长超过总 Star 的 30% | — | +15 |
| 互Star 网络密度 | 与已知 Sybil 集群的 Star 交集 | > 0 | +30 |

> **Star/Engagement 比率说明**：正常项目通常有合理的 stars/(forks+watchers) 比率。批量购买 Star 会导致比率异常偏高——因为 forks 和 watchers 无法以同样成本批量制造。

#### 3.2.4 行为时间序列分析

| 检测规则 | 阈值 | 风险权重 |
|----------|:---:|:---:|
| 贡献月增幅 | > 300%（与 3 月均值相比） | +20 |
| 长时间空白后突然活跃 | 空白期 > 6 月后单月贡献 > 50 | +15 |
| GitHub 活动时间段异常 | 活动完全集中在 8h 以外（疑似时区伪装） | +5 |

**贡献激增计算公式**：

```
monthly_avg = AVG(contributions per month for last 3 months)
current_month = contributions this month
spike_ratio = current_month / max(monthly_avg, 1)

IF spike_ratio > 3.0 → risk += 20
```

#### 3.2.5 跨平台交叉验证

| 检测规则 | 说明 | 风险权重 |
|----------|------|:---:|
| GitHub 与 GitLab/Bitbucket 账号不一致 | 声称多平台但贡献数据矛盾 | +10 |
| 社交账号关联度低 | 声称的 Twitter/X 账号与 GitHub 无交叉引用 | +5 |
| 身份锚定（L-1）缺失 | 未完成外部信任锚点绑定 | +10 |

### 3.3 SRS 计算与信任状态映射

#### 3.3.1 风险分数聚合

```
SRS = Σ(各维度风险权重 × 维度激活系数)

其中：
  - 各维度风险权重按 §3.2 定义
  - 维度激活系数 = 1.0（始终激活）
  - SRS 范围：[0, 200]
```

#### 3.3.2 信任状态映射

| SRS 范围 | 信任状态 | 效果 |
|----------|---------|------|
| 0 – 30 | `trusted` | 全权限：正常参与 PEER 评审、CCR 记录、策元操作 |
| 31 – 60 | `watched` | 受限：PEER 评审权重 × 0.7，CCR 记录添加 `sybil_watch` 标签 |
| 61 – 100 | `provisional` | 受限：PEER 评审权重 × 0.5，7 天冷却期后方可加入策元，CCR 记录隔离显示 |
| 101+ | `flagged` | 冻结：自动进入 L3 举报评审池，期间所有 NR 操作暂停 |

### 3.4 L2 周期性重检

L2 检测不是一次性的。系统在以下时机触发重检：

| 触发条件 | 频率 |
|----------|------|
| PEER 评审前 | 每次 |
| CCR 记录写入前 | 每次 |
| 策元创建 / 加入前 | 每次 |
| 定期巡检 | 每 7 天 |

重检后若 SRS 改善，信任状态可**自动升级**（flagged→provisional 除外，flagged 需人工解除）。

### 3.5 L2 数据记录

```sql
INSERT INTO sybil_checks (layer, check_time, ns_id, passed, score, flags, evidence)
VALUES (
  'L2',
  NOW(),
  :ns_id,
  (:score < 101),
  :score,
  ARRAY[:flags],
  jsonb_build_object(
    'commit_analysis', :commit_detail,
    'repo_quality', :repo_detail,
    'star_authenticity', :star_detail,
    'behavior_timeseries', :behavior_detail,
    'cross_platform', :cross_detail
  )
);
```

---

## 四、第三层：举报机制 (Sybil Report & Challenge)

### 4.1 概述

L3 是社区驱动的最后一层防御。当 L1/L2 未能拦截的女巫身份进入网络后，社区成员可通过 NR 质押举报将其提交评审。

### 4.2 举报流程

```
┌─────────────────────────────────────────────────────────────────────┐
│  L3_SYBIL_REPORT(reporter_id, target_id, evidence, stake_nr)        │
│                                                                     │
│  1. 验证举报资格：                                                   │
│     - reporter.ns_status == 'active'                                │
│     - reporter.NR ≥ stake_nr （举报者 NR 足以支付质押）               │
│     - stake_nr ≥ MIN_STAKE_NR（最低质押门槛 = 10 NR）                │
│     → 不满足 → REJECT                                                │
│                                                                     │
│  2. 质押锁定：                                                       │
│     - 从 reporter.NR 中冻结 stake_nr                                │
│     - 写入 sybil_reports 表，状态 = 'pending'                       │
│                                                                     │
│  3. 评审分配：                                                       │
│     - 从评审者池中随机抽取 3 人                                       │
│     - 评审者资格：NR_total ≥ 50 且 sybil_flag_count = 0             │
│     - 评审者间互不隶属同一策元                                        │
│     → 若评审者不足 3 人 → 举报进入等待队列                            │
│                                                                     │
│  4. 评审周期：                                                       │
│     - 评审者 72 小时内提交独立判断（sybil / not_sybil / abstain）    │
│     - 需附评审理由 (≥ 100 字符)                                      │
│                                                                     │
│  5. 裁决：                                                           │
│     - 3 票中 ≥ 2 票判定 sybil → 举报成立                            │
│     - 否则 → 举报不成立                                              │
└─────────────────────────────────────────────────────────────────────┘
```

### 4.3 举报成立 — 惩罚与奖励

| 对象 | 后果 |
|------|------|
| **被举报者 (target)** | ① NR 全部归零（NR = (0,0,0,0)）② 所有能证降级至 CP0 ③ 标记 `sybil_ban`，永久不可恢复 |
| **举报者 (reporter)** | ① 质押 NR 全额返还 ② 额外奖励 `stake_nr × 0.5` NR（来自被举报者燃烧池）③ `sybil_hunter` 计数 +1 |
| **评审者 (reviewers)** | 每位评审者 +2 NR_reliability（参与治理激励） |

### 4.4 举报不成立 — 惩罚与保护

| 对象 | 后果 |
|------|------|
| **举报者 (reporter)** | ① 质押的 NR 被燃烧 ② 若 30 天内累计 3 次举报不成立 → 标记 `sybil_abuser`，NR_reliability = 0 |
| **被举报者 (target)** | ① 无影响 ② 记录 `false_report` 标签（7 天后自动清除）③ 若 30 天内被恶意举报 ≥ 3 次 → NR_total +5（信誉补偿） |
| **评审者 (reviewers)** | 每位评审者 +1 NR_reliability（参与治理激励） |

### 4.5 数据模型

#### sybil_reports 表

```sql
CREATE TABLE sybil_reports (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reporter_id   UUID NOT NULL,              -- 举报者 ns_id
  target_id     UUID NOT NULL,              -- 被举报者 ns_id
  evidence      TEXT NOT NULL,              -- 举报证据（Markdown）
  stake_nr      DECIMAL(10,2) NOT NULL,     -- 质押 NR 数量
  status        TEXT DEFAULT 'pending',     -- pending | under_review | resolved
  verdict       TEXT,                       -- confirmed | dismissed
  reviewers     UUID[] NOT NULL,            -- 3 位评审者 ns_id
  reviewer_votes JSONB,                     -- {"reviewer_id": "sybil|not_sybil|abstain"}
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  resolved_at   TIMESTAMPTZ,
  
  CONSTRAINT check_status CHECK (status IN ('pending','under_review','resolved')),
  CONSTRAINT check_verdict CHECK (verdict IN ('confirmed','dismissed'))
);
```

#### sybil_checks 表（L1/L2 共用）

```sql
CREATE TABLE sybil_checks (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ns_id         UUID NOT NULL,
  layer         TEXT NOT NULL,              -- 'L1' | 'L2'
  check_time    TIMESTAMPTZ DEFAULT NOW(),
  passed        BOOLEAN NOT NULL,
  score         INT,                        -- SRS (L2 only)
  flags         TEXT[],                     -- 触发的风险标签
  evidence      JSONB NOT NULL,             -- 检测详情
  trust_status  TEXT,                       -- trusted | watched | provisional | flagged
  
  CONSTRAINT check_layer CHECK (layer IN ('L1','L2'))
);
```

---

## 五、API 端点

### 5.1 sybil_check — 执行女巫检测

```
POST /api/v1/sybil/check

Request:
{
  "ns_id": "uuid",
  "platform_data": {
    "github": {
      "account_id": "string",
      "username": "string",
      "created_at": "ISO8601",
      "type": "User|Bot|Organization",
      "contributions": {
        "commits": int,
        "pull_requests": int,
        "issues": int,
        "code_reviews": int
      },
      "repositories": [ ... ],
      "star_activity": [ ... ]
    }
  },
  "layers": ["L1", "L2"]          // 可选，默认全部
}

Response (SybilCheckResult):
{
  "ns_id": "uuid",
  "passed": true|false,
  "checks": [
    {
      "layer": "L1",
      "passed": true,
      "details": {
        "account_age_days": 365,
        "total_contributions": 120,
        "account_type": "User"
      }
    },
    {
      "layer": "L2",
      "passed": true,
      "score": 25,
      "trust_status": "trusted",
      "flags": [],
      "details": { ... }
    }
  ],
  "overall": "pass|reject|provisional"
}
```

### 5.2 sybil_report — 提交女巫举报

```
POST /api/v1/sybil/report

Request:
{
  "reporter_id": "uuid",
  "target_id": "uuid",
  "evidence": "markdown string (≥ 200 chars)",
  "stake_nr": 20.0
}

Response (ReportResult):
{
  "report_id": "uuid",
  "status": "pending|under_review",
  "stake_frozen": 20.0,
  "estimated_resolution": "ISO8601"     // 72h 后
}
```

### 5.3 sybil_status — 查询女巫状态

```
GET /api/v1/sybil/status/{ns_id}

Response (SybilStatus):
{
  "ns_id": "uuid",
  "trust_status": "trusted|watched|provisional|flagged|banned",
  "srs": 25,
  "last_check": {
    "time": "ISO8601",
    "layer": "L2",
    "score": 25
  },
  "report_history": {
    "total_reports_against": 0,
    "confirmed_sybil": false
  },
  "effective_peer_weight": 1.0,     // 基于 trust_status 的评审权重系数
  "cooldown_remaining": null         // provisional 状态的剩余冷却时间
}
```

### 5.4 sybil_review — 提交评审投票（评审者专用）

```
POST /api/v1/sybil/review/{report_id}

Request:
{
  "reviewer_id": "uuid",
  "vote": "sybil|not_sybil|abstain",
  "reasoning": "string (≥ 100 chars)"
}

Response:
{
  "acknowledged": true,
  "votes_collected": 2,
  "votes_required": 3
}
```

---

## 六、状态机

### 6.1 身份女巫信任状态转移

```
                    ┌──────────┐
                    │  UNKNOWN │  新注册触发 L1+L2
                    └────┬─────┘
                         │ L1 reject
                         ↓
                    ┌──────────┐
                    │ REJECTED │  拒绝注册（可申诉）
                    └──────────┘
                         │ L1 pass, L2 SRS ≤ 30
                         ↓
                    ┌──────────┐
          ┌─────────│ TRUSTED  │◄────────────┐
          │         └────┬─────┘              │
          │              │ SRS 31-60          │ SRS 回落
          │              ↓                    │
          │         ┌──────────┐              │
          │         │ WATCHED  │──────────────┘
          │         └────┬─────┘
          │              │ SRS 61-100
          │              ↓
          │         ┌─────────────┐
          │         │ PROVISIONAL │────────────┐
          │         └──────┬──────┘            │
          │                │ SRS 101+          │ SRS 回落
          │                ↓                    │
          │         ┌──────────┐              │
          │         │ FLAGGED  │──────────────┘
          │         └────┬─────┘
          │              │ L3 举报成立
          │              ↓
          │         ┌──────────┐
          │         │  BANNED  │  不可恢复
          │         └──────────┘
          │
          └─── 周期性重检（§3.4）
```

### 6.2 举报状态转移

```
          ┌──────────┐
          │  IDLE    │
          └────┬─────┘
               │ 提交举报 + 质押锁定
               ↓
          ┌──────────┐
          │ PENDING  │  等待评审者分配
          └────┬─────┘
               │ 评审者就位
               ↓
          ┌──────────────┐
          │ UNDER_REVIEW │  72h 评审窗口
          └──────┬───────┘
                 │
          ┌──────┴──────┐
          │  ≥ 2 sybil  │  < 2 sybil
          ↓              ↓
    ┌───────────┐  ┌───────────┐
    │ CONFIRMED │  │ DISMISSED │
    └───────────┘  └───────────┘
```

---

## 七、渐进式降级策略

### 7.1 降级触发条件

若基础门槛导致 CONC 网络冷启动困难（注册通过率 < 30% 或 日均通过注册 < 5），策元核可发起降级提案。

### 7.2 降级参数表

| 参数 | 标准模式 | 降级模式 | 恢复条件 |
|------|---------|---------|---------|
| `MIN_ACCOUNT_AGE_DAYS` | 180 天 | 90 天 | 日均注册 ≥ 20 且持续 14 天 |
| `MIN_TOTAL_CONTRIBUTIONS` | 50 | 20 | 日均注册 ≥ 20 且持续 14 天 |
| SRS `watched` 阈值 | 30 | 40 | 自动恢复 |
| SRS `provisional` 阈值 | 60 | 70 | 自动恢复 |
| SRS `flagged` 阈值 | 100 | 100 | 不降级 |

### 7.3 降级后的补偿措施

降级模式下通过 L1 的身份自动进入 **provisional** 信任状态（即使 SRS < 31）：

| 限制项 | 标准 trusted | 降级 provisional |
|--------|:---:|:---:|
| PEER 评审权重系数 | 1.0 | 0.5 |
| 加入策元冷却期 | 0 天 | 7 天 |
| CCR 记录标签 | 无 | `bootstrapping` |
| L2 重检频率 | 7 天 | 3 天（加速验证） |

### 7.4 降级-恢复控制

```
降级提案 → 策元核投票（PCP，≥ 2/3 通过）→ 降级生效
恢复提案 → 策元核投票（PCP，≥ 2/3 通过）→ 恢复标准模式
```

降级与恢复事件均写入 GHF 审计链，确保可追溯。

---

## 八、安全考量与边界条件

### 8.1 已知攻击向量与缓解

| 攻击向量 | 风险等级 | 缓解措施 |
|----------|:---:|------|
| **长期潜伏账号** | 中 | L2 行为时间序列检测长时间空白后的激增 |
| **购买成熟 GitHub 账号** | 中 | L2 跨平台交叉验证 + 行为模式突变检测 |
| **合谋举报** | 高 | 评审者互不隶属同一策元 + 评审者 NR ≥ 50 |
| **恶意举报骚扰** | 中 | 30 天内 3 次举报不成立 → 举报者标记 `sybil_abuser` |
| **Sybil 集群互Star** | 高 | L2 Star/Engagement 比率 + 互Star 网络密度检测 |
| **AI 生成代码制造假贡献** | 高（新兴威胁） | 后续协议补充——AI 生成代码检测器（见 §8.3） |

### 8.2 边界条件

| 场景 | 处理方式 |
|------|---------|
| `ns_id` 不存在 | 返回 404 |
| L1 拒绝后重复提交 | 返回 409，附冷却时间（24h） |
| 举报自身 | 返回 400 `CANNOT_REPORT_SELF` |
| 被举报者已是 `banned` | 返回 409 `ALREADY_BANNED` |
| 评审者不足 3 人 | 举报保持 `pending`，每 6h 重试分配 |
| 评审者超时未投票 | 72h 后自动 `abstain`，按已收集票数裁决 |
| 降级模式下注册 | 自动标记 `bootstrapping`，3 天重检 |

### 8.3 未来扩展点

1. **AI 生成代码检测器**：接入 LLM 检测器分析 commit 的「人类真实性」，作为 L2 的第六维度。
2. **社交图谱分析 (Social Graph Analysis)**：构建贡献者-仓库二分图，用社区发现算法检测 Sybil 集群。
3. **链上声誉锚定**：通过 L-1 外部信任锚点（如 Ethereum 地址、ENS）增强跨平台身份一致性。
4. **动态阈值**：根据网络规模自动调整 L1/L2 阈值——网络越大，门槛可越低（大数定律）。

---

## 九、协议版本与演进

| 版本 | 日期 | 变更内容 |
|------|------|---------|
| 1.0 | 2026-05-27 | 初始版本：三层防御体系、数据模型、API、状态机、降级策略 |

> 本协议遵循语义版本号规范。向后兼容的补充（新检测维度、新 API 端点）递增次版本号。破坏性变更（状态转移规则修改、数据表结构变更）递增主版本号。
