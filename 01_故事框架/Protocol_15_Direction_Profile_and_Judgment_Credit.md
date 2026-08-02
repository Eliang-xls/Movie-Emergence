# 方向档案与判断力信用协议 v2.0
## Direction Profile & Judgment Credit Protocol

> **协议标识符**: `CONC-Protocol/JudgmentCredit.2.0`
> **v2.0 升级摘要**: JC 公式从单维求和重构为四分量合成（JC_macro + JC_phro_runtime + JC_continuous + JC_design）。新增 JC_design 作为二阶判断力指标（对任务令设计者 phronesis_profile 分类校准度的评估）。策元核推选公式引入 JC_design 维度。API 扩展四分量查询。
> **对应理论**: SBDEL v2.0 §二（One-Agent 本体论完备）、公理四（One-Agent 不可还原）、PBA 定理层 (PBA1-PBA6)
> **依赖协议**: CSIP (智权体身份)、NR (声誉)、CCR (贡献记录)、Phronesis 层协议 (19)
> **协议层级**: 协议栈第五层（价值层）——JC 作为 Phronesis 的可观测代理指标

---

## 一、协议概述

本协议将 One（自然人）的不可复制维度——创意方向、判断力、信任关系——嵌入 CONC 协议层。当前协议仅读取 Skill（可复制、Agent 承载），忽略了智权体能力的三个高绑定维度。本协议填补此空白。

### 核心区分

| | Sophia (理论智慧) | Phronesis (实践智慧) |
|---|---|---|
| **载体** | Agent Skill 库 | 自然人 |
| **可编码** | 高（规则/代码/文档） | 低（经验直觉/情境感知） |
| **可迁移** | 高（Skill 流通） | 低（绑定于个体经验） |
| **协议化** | 能证体系（已有） | **方向档案 + 判断力信用（新增）** |

---

## 二、方向档案 (Direction Profile)

### 2.1 Schema

```json
{
  "ns_id": "ns_alice_001",
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

### 2.2 字段说明

| 字段 | 含义 | 更新方式 |
|------|------|---------|
| `core_values` | 核心价值观标签 (max 5) | 手动声明 + 历史行为推断 |
| `direction_vector` | 5维创意偏好向量 | 从 historical_seeds 自动聚合 |
| `historical_seeds` | 历史创意图元 ID 列表 | 自动追加（每次创建 seed） |
| `commitment_pattern` | 承诺行为模式 | 从策元参与历史自动计算 |

### 2.3 ICP 匹配升级

$$match\_score = w_1 \cdot \text{sim}(seed) + w_2 \cdot \text{sim}(direction) + w_3 \cdot \text{commitment\_trust}$$

| 权重 | 默认值 | 含义 |
|:---:|:---:|------|
| $w_1$ | 0.5 | 技能匹配 (Skill-based) |
| $w_2$ | 0.3 | 方向匹配 (Direction-based) |
| $w_3$ | 0.2 | 承诺信任 (Commitment-based) |

---

## 三、判断力信用 (Judgment Credit)

> **v2.0 重大更新 (2026-07-12)**：JC 公式从单一求和重构为四分量合成——JC_macro（策元生命周期级判断）、JC_phro_runtime（任务执行级 Phronesis 触发）、JC_continuous（连续判断型任务令综合评分）、JC_design（任务令设计校准度）。此重构基于 Harness/Loop Engineering/Palantir AIP 三源工学调研（见 `11_Discuss/CONC_Harness_Reverse_Phronesis_Boundary_v2.0.md`，`v3.0`，`v4.0`）。

### 3.1 四分量定义

判断力信用不再是一个单一维度的累积分数——它由四个不可互约的分量合成：

```
JC(n) = α¹ · JC_macro(n) + α² · JC_phro_runtime(n) + α³ · JC_continuous(n) + α⁴ · JC_design(n)
```

| 分量 | 来源 | 决策粒度 | 验证方式 | 权重 α（默认） |
|------|------|:---:|------|:---:|
| **JC_macro** | 策元生命周期决策点 JP-001~010 | 策元级（低频高权） | PEER 评审 + Ed25519 签名链 | 0.35 |
| **JC_phro_runtime** | 任务执行中 P1-P5 触发域的人工判断 | 任务令级（中频） | PEER 回溯验证 + GHF 事件 PHRO_JUDGMENT | 0.30 |
| **JC_continuous** | `phronesis_profile = "continuous"` 的任务令，完成时 PEER_SYNC 综合评分 | 任务令级（单次综合） | PEER_SYNC 面对面评审 | 0.20 |
| **JC_design** | 任务令设计者的 phronesis_profile 分类校准度 | 跨任务令（累积校准） | CAR 对齐率 + 事后 MISCLASSIFIED 审计 | 0.15 |

权重的默认值由协议层提供。策元可在 PCP 中调整 α¹–α⁴ 的分配（约束：Σα = 1.0，每个 α ∈ [0.05, 0.60]）。

### 3.2 JC_macro — 策元生命周期决策

沿用原协议 v1.0 的 JC 定义和计算方式（§3.1 原始公式）：

$$JC_{macro}(n) = \sum_{k \in JP-001..010} w_k \cdot \text{outcome}(d_k) \cdot \text{difficulty}(d_k) \cdot \text{uniqueness}(d_k)$$

| 参数 | 含义 | 取值 |
|------|------|:---:|
| $\text{outcome}(d_k)$ | 决策结果质量 | [-1, 1] |
| $\text{difficulty}(d_k)$ | 决策难度 | [1, 5] |
| $\text{uniqueness}(d_k)$ | 决策独特性 | [1, 3] |
| $w_k$ | 时间衰减权重 | $e^{-\lambda \cdot age_k}$ |

JC_macro 仅包含策元生命周期级决断点（JP-001~010，定义见 `19_Phronesis_Layer_Protocol.md`）。其触发条件沿用原三重过滤（不可逆性、信息不完备性、多主体分歧）。

### 3.3 JC_phro_runtime — 任务执行级 Phronesis 触发

任务令执行中，当 Agent 的动作落入 Phronesis Zone（P1-P5）并触发人工判断时，每次判断独立计入此分量。

**P1-P5 触发域**（完整定义见 `19_Phronesis_Layer_Protocol.md` §新增）：

| 域 | 条件 | JC 维度侧重 |
|:---:|------|------|
| **P1 不可逆** | 破坏性写入/外部通信/金融交易/生产部署 | outcome · difficulty（回滚成本） |
| **P2 越权** | clearance_level > Agent 自治阈值 | outcome · difficulty（影响范围） |
| **P3 价值/方向** | Agent confidence < τ 且涉及价值取舍 | outcome · difficulty · uniqueness |
| **P4 分歧** | PEER 评分方差 > σ 阈值或 ICP θ±ε 暧昧区 | outcome · uniqueness（调解新颖性） |
| **P5 新颖性** | 无匹配 Skill 模板或信息完备度 < 70% | outcome · uniqueness（首次处理） |

$$JC_{phro\_runtime}(n) = \sum_{k \in P1-P5\ triggers} w_k \cdot \text{outcome}(d_k) \cdot \text{difficulty}(d_k) \cdot \text{uniqueness}(d_k)$$

其中 outcome 在任务令完成后的 PEER 评审中回溯赋值（不是实时评分）。daily cap：每日最多计入 N_max 条（默认 5；PCP 可调）。此分量不对 Sophia Zone（S1-S4，确定性/安全过滤/常规操作）的动作产生任何 JC。

### 3.4 JC_continuous — 连续判断型任务令

当智权体完成 `phronesis_profile = "continuous"` 的任务令时，不逐个记录运行时判断，而是在任务令完成时由 PEER_SYNC（同步面对面评审）给出综合评分：

$$JC_{continuous}(n) = \sum_{tw \in tasks\_completed(n) \ |\ tw.phronesis\_profile = "continuous"} w_{tw} \cdot \text{peer\_sync\_score}(tw)$$

其中 `peer_sync_score` 由 PEER_SYNC 评审者对「方向一致性（initial direction vs. final direction）」和「迭代效率（多少轮反馈抵达目标）」综合打分（0–1 归一化），$w_{tw}$ = $e^{-\lambda \cdot age_{tw}} \cdot \log(VT_{tw}+1)$（VT 越大权重越高，但边际递减）。

### 3.5 JC_design — 设计校准度

JC_design 评价的是任务令设计者**对 phronesis_profile 分类的预判准确度**——这不是「你设计了什么」，而是「你的设计预判与实际运行的偏差」（Brier 校准精神）。

**核心指标 CAR（分类对齐率）**：

$$CAR(n) = 1 - \frac{|\{tw \in warrants\_designed(n) \mid tw\ is\ MISCLASSIFIED\}|}{|\{tw \in warrants\_designed(n) \mid tw\ is\ completed\}|}$$

MISCLASSIFIED 判定（事后审计）：
- phronesis_profile = "none" 但运行时 Phronesis 事件密度 > τ_p → 低估型误判
- phronesis_profile = "gate" 但实际匹配的 gate_type < τ_g → gate 错标
- phronesis_profile = "continuous" 但 PEER_SYNC 方向一致性 < τ_c → continuous 误标

**JC_design 四因子公式**：

$$JC_{design}(n) = CAR(n) \cdot \lambda_{CAR} + COVERAGE(n) \cdot \lambda_{COV} + STABILITY(n) \cdot \lambda_{STAB} + AWARENESS(n) \cdot \lambda_{AWAR}$$

| 因子 | 公式 | 来源锚定 | 权重 λ（默认） |
|------|------|---------|:---:|
| **CAR** | 校准度（见上） | Brier 评分精神 | 0.55 |
| **COVERAGE** | `|decision_gates_actual| / |decision_gates_declared ∪ decision_gates_actual|` | SEMAT Tacit→Explicit | 0.20 |
| **STABILITY** | $1 - \sigma(CAR_{across\_recent\_dags})$ | AIP Evals 多迭代方差 | 0.15 |
| **AWARENESS** | 设计者 phronesis_profile ≠ "none" 的任务令占比 ≥ 历史平均 → bonus | Mitts Understanding-as-Evaluation | 0.10 |

JC_design ∈ [-1, 1]：校准度低 → 负向（设计者不能准确预判判断力需求）。

**更新触发**：设计者累积 ≥ N_min（默认 5）个已完成任务令 → 触发一次重算。新手前 N_bootstrap（默认 3）个任务令不计入 MISCLASSIFIED，仅作为基线。

**防博弈**：
- 全标 `"none"` 刷不到 JC_design——CAR 只看偏差，不看保守度
- 全标 `"gate"` 刷不到——COVERAGE 值取决于实际匹配的 gate
- 事后修改 phronesis_profile 不可行——创建时写入 GHF（`TASK_WARRANT_DESIGNED`）

详细机制与外部理论锚定见 `11_Discuss/CONC_JC_Design_Meta_Judgment_v4.0.md`。

### 3.6 与 NR 的区别（扩展）

| | NR (Network Reputation) | JC (Judgment Credit) |
|---|---|---|
| **衡量什么** | 完成了多少任务令（执行力） | 四分量：策元决策 + 执行判断 + 连续判断 + 设计校准 |
| **可由 Agent 辅助** | 是（Agent 执行任务） | 否（四个分量均要求人类判断） |
| **衰减方式** | 随时间缓慢衰减 | JC_macro 不活跃衰减；JC_phro/continuous/design 不衰减（已锁定于事件） |
| **主要用途** | 任务令竞争权重 | 策元核推选、方向决策权重、设计者资质 |
| **负向可能** | 仅衰减不转负 | JC_design 可为负（校准度差）；JC_macro 的 outcome 为负时降低 |

> **⚠️ 本体论免责声明 (Ontological Disclaimer)**: 四分量 JC 仍然是 Phronesis (实践智慧) 的 **可观测代理指标 (observable proxy)**，而非 Phronesis 本身。分解只是提高了代理指标的粒度——它不改变代理与被代理对象之间的本体论鸿沟。JC 测量的是 Phronesis 的 **可验证痕迹**，而非 Phronesis 本体。这一区分确保：协议层不会将 JC 数值与智权体的实际判断力混为一谈，避免"量化指标替代被量化对象"的本体论谬误。

---

## 四、策元核推选升级 (v2.0 扩展)

$$core\_election\_weight = NR^{0.25} \cdot JC\_macro^{0.30} \cdot JC\_design^{0.20} \cdot commitment\_pattern^{0.25}$$

v2.0 更新：NR 权重下调（0.4→0.25），JC 拆分为 JC_macro（0.30）和 JC_design（0.20），承诺模式权重上调（0.2→0.25）。此重构确保策元核由「既有执行力又有宏判断力、设计校准度高且信守承诺」的智权体担任—而非仅仅高产或偶尔做出大决策。

---

## 五、API 定义

### 5.1 `direction_profile_get`
```
INPUT:  ns_id
OUTPUT: direction_profile (完整方向档案)
```

### 5.2 `direction_profile_update`
```
INPUT:  ns_id, core_values[] (optional), manual_adjustments (optional)
OUTPUT: updated_profile
```

### 5.3 `judgment_credit_get`
```
INPUT:  ns_id, components? (optional: "macro"|"phro"|"continuous"|"design"|"all")
OUTPUT: {
  jc_total: number,
  jc_macro: { score, decision_count, last_decision_at },
  jc_phro_runtime: { score, trigger_count, daily_cap_reached },
  jc_continuous: { score, tasks_evaluated, avg_peer_sync_score },
  jc_design: { score, car, coverage, stability, awareness, warrants_designed, warrants_audited }
}
```

### 5.4 `judgment_credit_record`
```
INPUT:  genesis_id, ns_id, decision_context, decision_description, outcome_quality
        jc_component: "macro" | "phro"      // 指定计入哪个分量（v2.0 新增）
OUTPUT: decision_id, updated_jc_component
AUTH: 需策元核签名
```

### 5.5 `core_election_calculate`
```
INPUT:  genesis_id
OUTPUT: ranked_members[{ns_id, election_weight, nr, jc_macro, jc_design, commitment}]
```

### 5.6 `jc_design_get` (v2.0 新增)
```
INPUT:  ns_id
OUTPUT: {
  jc_design_score,
  car (分类对齐率),
  coverage (gate覆盖度),
  stability (跨DAG稳定性),
  awareness (理解型占比),
  recent_warrants: [{tw_id, phronesis_profile, misclassified_flag, completed_at}]
}
```

### 5.7 `jc_design_audit` (v2.0 新增)
```
INPUT:  genesis_id, task_warrant_id, misclassified_flag: true | false,
        misclassification_type: "underestimate" | "gate_mismatch" | "continuous_failure"
OUTPUT: audit_id, updated_car_for_designer
AUTH: 需 PEER 评审签名（Gate 3 PEER+ 审计触发）
```

---

## 六、防博弈设计 (v2.0 扩展)

| 攻击 | 防御 |
|------|------|
| JC 自我虚报 | 决策必须由策元核或 PEER 评审确认 |
| 低质量决策刷 JC | outcome ∈ [-1, 1]，差决策降低 JC |
| 不参与策元仍积累 JC | JC 仅在不活跃时保持不变（不增长） |
| NR 垄断策元核 | JC_macro + JC_design 权重分流——仅有 NR 不够 |
| 任务令设计者全标 `"none"` 以避风险 | JC_design 的 CAR 只看偏差——全标 `"none"` 但运行时 Phronesis 密度高 → CAR 低 → JC_design 负 |
| 全标 `"gate"` 以刷 JC_design | COVERAGE 取决于实际匹配的 gate——过多未匹配声明降低覆盖度 |
| Sophia Zone 动作冒充 PHRO_JUDGMENT | GovernedAction 的 risk_score 自动标定 + PEER 10% 抽检验证 |
| 事后修改 phronesis_profile | 创建时写入 GHF (`TASK_WARRANT_DESIGNED`)，不可篡改 |
| JC_design 对新手惩罚过重 | 前 N_bootstrap（默认 3）个任务令不计入 MISCLASSIFIED |
| 同策元审计偏差回廊 | Gate 3 的 10% MISCLASSIFIED 标记提交超织体公共池，需 ≥1 外策元 PEER 参与 |

### 6.1 Sophia Zone 排除原则

以下动作类型落在 Sophia Zone（S1-S4），**不产生 JC**，不由 PEER 事后审计为 Phronesis 事件——它们是 Agent 的自动化执行域：

| Zone | 动作类型 | 排除理由 | 对应 Harness 锚定 |
|:---:|------|------|------|
| S1 | 内容安全过滤（PII 脱敏/提示注入/有害内容拦截） | Guardrail 是自动过滤器，非判断 | Tiwari Layer 1 |
| S2 | 确定性正确性校验（编译/测试/lint/Schema） | AUTO 验证，pass/fail 确定 | Feedback 控制（Fiddler） |
| S3 | 常规操作（瞬时重试/工具选择[allowlist内]/上下文压缩/非破坏性读写） | Sophia 域自主执行 | ReAct Loop（Databricks） |
| S4 | 协议层自动检查（Gate 0-4 自动项/depends_on/CRDT LWW） | 确定性规则判定 | Tiwari Layer 4 |

P1-P5 触发域的定义（Phronesis Zone）见 `19_Phronesis_Layer_Protocol.md` §新增「任务执行级 Phronesis 触发域」。

---

*Direction Profile & Judgment Credit Protocol v1.0 — 2026-05-18*
*Direction Profile & Judgment Credit Protocol v2.0 — 2026-07-12*


---
## v1.1 更新 (2026-07-10) — CONC-P1-5
- JC行业分类计分规则：安全型（制药/航天，分歧>2σ→审计）、权衡型（半导体，>1.5σ→标记）、品味型（软件，不触发自动审计）
- 跨策元经验积累：参与≥3个策元的智权体→加权策元多样性S₃参与CP4匹配
- 古德哈特防御：独立合规策元的对抗性质询记为JC正向贡献（×1.5）

## v2.0 更新 (2026-07-12) — CONC-P0-1: Sophia↔Phronesis 边界工程化
- JC 公式从单一求和重构为四分量合成（JC_macro + JC_phro_runtime + JC_continuous + JC_design），权重 PCP 可调
- 新增 JC_phro_runtime：任务执行中 P1-P5 触发域的人工判断计入（每日 cap N_max=5）
- 新增 JC_continuous：phronesis_profile = "continuous" 任务令的 PEER_SYNC 综合评分
- 新增 JC_design：任务令设计者的 phronesis_profile 分类校准度（CAR + COVERAGE + STABILITY + AWARENESS 四因子）
- 策元核推选公式重构：NR 权重 0.4→0.25，JC 拆分为 JC_macro(0.30) + JC_design(0.20)
- API 扩展：judgment_credit_get 返回四分量详情；新增 jc_design_get、jc_design_audit
- 防博弈扩展：全标 "none" / 全标 "gate" 的 JC_design 防御；Sophia Zone 排除原则 (S1-S4)
- 交叉引用：`19_Phronesis_Layer_Protocol.md` P1-P5 触发域；`11_Discuss/CONC_Harness_Reverse_Phronesis_Boundary_v2.0.md`；`11_Discuss/CONC_JC_Design_Meta_Judgment_v4.0.md`
- 古德哈特防御：独立合规策元的对抗性质询记为JC正向贡献（×1.5）
