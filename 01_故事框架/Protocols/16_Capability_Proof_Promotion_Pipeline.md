# 能证晋级管道协议 v1.0
## Capability Proof Promotion Pipeline — 从静态自声明到动态 Skill 验证

> **对应理论**: CONC-AMD-001（能证-技能闭环修正案）、SBDEL v2.0
> **依赖协议**: CSIP (智权体)、PEER (评审)、Skill Lineage (引用链)
> **协议层级**: SBDEL 层 — 能证与 Skill 的反馈闭环

---

## 一、问题诊断

当前能证（Capability Proof）是静态的——创建时声明"我声称具备 X 能力，级别 Y"，此后不会因策元参与而自动更新。SBDEL Skill（策元产出的知识产物）的质量证据不会回流来增强智权体的能力声明。

**核心矛盾**: Alice 在策元中实际证明了 react 能力达到 4 级（PEER 评审 4.5/5），但她的能证仍停留在自声明的 3 级。

---

## 二、三层信号体系

```
L0: 自声明 (Self-Declaration)
     └─→ 创建时填写："声称 react(3)"
     └─→ 可信度: 低 (无验证)

L1: Skill 背书 (Skill-Endorsed)          ← 新增
     └─→ 策元执行后，Skill 产出自动触发 CP 审查
     └─→ 可信度: 中 (有 PEER 评审质量证据)

L2: 网络验证 (Network-Verified)          ← 新增
     └─→ 多个策元的 Skill 质量持续验证
     └─→ 可信度: 高 (跨策元、跨时间验证)
```

---

## 三、晋级触发条件

| 晋级路径 | 触发条件 | 自动/手动 |
|---------|---------|:---:|
| L0 → L1 | 在 Skill 相关领域产出至少 1 个质量 ≥ 3.5 的 Skill | **自动** |
| L1 → L2 | 在 Skill 相关领域产出 ≥ 3 个质量 ≥ 4.0 的 Skill，来自 ≥ 2 个不同策元 | **自动** |
| 级别提升 | 同一领域的多个 L1/L2 Skill 的加权平均质量分 ≥ 新级别阈值 | **自动** |

### 质量分 → 能证级别映射

| PEER 平均质量分 | 能证级别 |
|:---:|:---:|
| < 3.0 | 不触发晋级 |
| 3.0 - 3.49 | 级别 +0（维持） |
| 3.5 - 3.99 | 级别 +1 |
| 4.0 - 4.49 | 级别 +2 |
| ≥ 4.5 | 级别 +3 |

---

## 四、能证衰减 (不活跃降级)

```
如果智权体在 skill_id 领域的最后活跃时间距今超过 T_decay:
  → CP 级别自动降 1 级
  → 但 L1/L2 背书状态降级为 L1_pending / L2_pending
  → 直到新的 Skill 产出重新验证

T_decay 默认: 12 个月
T_decay 调整: 由领域因子决定
  - 快速演化领域 (AI/前端): 6 个月
  - 稳定领域 (基础设施/安全): 24 个月
```

---

## 五、完整生命周期

```
1. ns_register → 自声明 CP: react(3) [L0]
       │
2. gu_001 中执行 tw_react → 产出 Skill sk_001 (quality 4.5)
       │
       ▼
3. 自动审查: skill domain = react, quality = 4.5 ≥ 3.5
   → CP 自动晋级: react(3) [L0] → react(4) [L1]
   → 证据链: sk_001, genesis gu_001, PEER 3/3 passed
       │
4. gu_003 中执行 tw_ui → 产出 Skill sk_007 (quality 4.2)
   → react domain 质量 4.2 ≥ 4.0, 来自不同策元
   → CP 自动晋级: react(4) [L1] → react(5) [L2]
       │
5. 12 个月无 react 相关 Skill 产出
   → CP 自动降级: react(5) [L2] → react(4) [L2_pending]
```

---

## 六、API 定义

### 6.1 `cp_promotion_check`
```
INPUT:  ns_id, skill_id (新产出的 Skill)
OUTPUT: promoted_cps[], evidence_chain[]

自动执行: Skill 创建时触发
逻辑:
  1. 提取 Skill 的 domain / sub_domain
  2. 查找 ns 在该 domain 的当前 CP
  3. 计算 weighted_quality_score
  4. 判断是否触发晋级
  5. 创建证据链引用
```

### 6.2 `cp_decay_check`
```
INPUT:  ns_id (optional, 默认全局)
OUTPUT: decayed_cps[{domain, old_level, new_level, reason}]

定期执行: Cron (每月 1 次)
```

### 6.3 `cp_get_with_evidence`
```
INPUT:  ns_id, skill_id (optional)
OUTPUT: capabilities[{skill_id, level, signal_level (L0/L1/L2), evidence[{skill_id, genesis_id, quality}]}]
```

---

## 七、防游戏设计

| 攻击 | 防御 |
|------|------|
| 同一策元反复刷 Skill 提升 CP | L2 要求 ≥ 2 个不同策元 |
| 创建低质量 Skill 占位 | quality < 3.0 不触发晋级 |
| 自声明虚高级别 | L0 在任务令匹配时权重低 (仅有能证的分数的 60%) |
| 能证级别永不过期 | T_decay 自动降级 |
| 跨域冒用 | Skill domain 必须与 CP domain 匹配 |

---

*Capability Proof Promotion Pipeline Protocol v1.0 — 2026-05-18*


---

## 七、CP4四信号融合（v1.1 升级 — CONC-P0-3）

> 从三信号升级为四信号。新增 $S_3$（跨策元多样性信号），权重由 $\sigma_{GU}$ 动态调整。

$$\text{MatchScore}(n, c) = w_1 S_0 + w_2 S_1 + w_3 S_2 + w_4 S_3$$

$S_3(n) = 1 - 1/(1 + \text{unique\_domains\_participated}(n))$

| $\sigma_{GU}$ | $w_4$ | 行业 |
|:---:|:---:|:---|
| 0.1 (软件) | 0.15 | 重视跨领域多样性 |
| 0.5 (生技) | 0.10 | 默认权重 |
| 0.9 (制药) | 0.05 | 精度优先于多样性 |

## 八、策元稳定性 $\sigma_{GU}$ 集成（v1.1 新增 — CONC-P1-1）

> 对应定理S6和 `02_Models/10_Genesis_Unit_Stability_Model.md`。

$$\sigma_{GU} \in [0,1]$$ 由三因素决定：生命周期比率、资本密度、成员规模倒数。默认值按行业从软件(0.1)到制药(0.9)。$\sigma_{GU}$ 调制：
- CP4 $w_4$ 权重（$w_4 = 0.15 - 0.10 \cdot \sigma_{GU}$）
- Skill衰减速率（定理S6调制项）

---

*协议版本 v1.0 → v1.1 (2026-07-10)*
