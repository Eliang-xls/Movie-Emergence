# Skill 引用链与血统协议 v1.0
## Skill Lineage & Citation Protocol

> **对应理论**: SBDEL v2.0 §三（Skill v2.0 完备定义）、公理五（引用链完备公理）
> **依赖协议**: CTCP (任务令)、PEER (评审)、CCR (贡献记录)
> **协议层级**: SBDEL 层 — Skill 引用图与血统追踪

---

## 一、协议概述

本协议定义 Skill 的版本引用关系——每个 Skill 的每一次迭代（fork/enhance/merge/absorb）在分布式网络中形成不可篡改的引用链。Skill 的价值不仅取决于其当前内容，还取决于其引用图谱中的位置。

### 核心原则

1. **不可篡改性**: Skill 的引用链一经创建不可修改
2. **血统完整性**: 任何 Skill 的完整引用链可被反向追溯至源头
3. **贡献可归属**: 每次修改的创造者指纹和修改差异永久记录
4. **引用图可遍历**: 引用图支持正向（衍生）和反向（祖先）遍历

---

## 二、Skill 八层结构 (v2.0 Schema)

```
Layer 8: 创造者印记 (Creator Imprint)         ← 永不衰减
         创造者ID、决策哲学、审美偏好、Phronesis签名
Layer 7: 引用链 (Lineage / Citation Chain)     ← 永不衰减（永久公开）
         父Skill、修改差异、上游引用、衍生计数
Layer 6: 授权状态 (Authorization State)        ← 衰减后公开（历史记录）
         衰减参数、授权列表、授权凭证
Layer 5: 可复用代码片段 (Reusable Code)        ← 分层释放
Layer 4: 蒸馏知识 (Distilled Knowledge)        ← 分层释放
Layer 3: 决策记录 (Decision Trail)             ← 分层释放
Layer 2: 过程记录 (Process Record)             ← 渐进公开
Layer 1: 场景描述 (Scenario Descriptor)         ← 最早公开
```

---

## 三、引用边类型

| 边类型 | 语义 | 触发条件 | 权重 |
|--------|------|---------|:---:|
| `direct_parent` | 直系血统 — 从一个 Skill Fork 而来 | `skill_fork()` | 继承比例 |
| `cross_domain_absorption` | 跨域吸收 — 从其他领域吸收 Layer | `skill_absorb()` | 吸收 Layer 权重 |
| `validation_tool` | 验证引用 — 引用了某验证方法 | `skill_validate_with()` | 验证贡献度 |
| `collaborative_co_creation` | 协作共创 — 两人同时创建 | `skill_co_create()` | 共创者贡献比例 |
| `authorized_usage` | 授权使用 — 在授权期内使用 | `skill_authorize()` | 授权范围 |

---

## 四、引用影响力 (Citation Impact)

$$CI(s) = \sum_{s' \in \text{derivatives}(s)} \frac{1}{\text{depth}(s, s')} \cdot \text{quality}(s') \cdot \text{recency}(s')$$

| 参数 | 含义 |
|------|------|
| depth(s, s') | 引用图上的最短路径深度（直接 fork = 1） |
| quality(s') | 衍生 Skill 的 PEER 评审质量分数 [0, 5] |
| recency(s') | 时间新鲜度: $e^{-\mu \cdot \text{age}}$ |

**防深度伪造**: deep > 1 时权重按 1/depth 衰减，防止"深度伪造引用链"套利。

---

## 五、创造者贡献度 (Creator Contribution)

$$CC(\text{ns}, s) = \frac{\sum_{m \in \text{modifications by ns}} \text{weight}(m)}{\sum_{m \in \text{all modifications}} \text{weight}(m)}$$

修改权重由修改涉及的 Layer 和修改幅度决定:
- Layer 5-8 修改: weight = 3.0 (核心创新层)
- Layer 3-4 修改: weight = 2.0 (知识层)
- Layer 1-2 修改: weight = 1.0 (描述层)

---

## 六、API 定义

### 6.1 `skill_fork`
```
INPUT:  parent_skill_id, fork_type (enhance|merge|branch|absorb), modifications[]
OUTPUT: new_skill_id, lineage (完整引用链), creator_imprint

修改记录格式:
{
  "layer": 4,
  "field": "distilled_knowledge.rules[2]",
  "old_value": "...",
  "new_value": "...",
  "reason": "gu_017 中性能优化需求",
  "evidence_genesis": "gu_017"
}
```

### 6.2 `skill_lineage_query`
```
INPUT:  skill_id, direction (ancestors|descendants|both), max_depth
OUTPUT: 祖先/后代 Skill 列表 + 引用图边 + 贡献度

约束: 必须遍历到原始 Skill (orphan_root) 或达到 max_depth
```

### 6.3 `skill_citation_impact`
```
INPUT:  skill_id
OUTPUT: ci_score, derivative_count, total_citation_count, impact_breakdown[{derivative_id, depth, quality, recency}]
```

### 6.4 `skill_creator_contribution`
```
INPUT:  skill_id, ns_id
OUTPUT: contribution_percentage, modifications[{layer, field, weight}]
```

### 6.5 `on_skill_created` (事件钩子)
```
触发时机: skill_create 成功后
触发动作:
  1. cp_promotion_check(skill_id)     → 检查创始者是否达到策元核晋升门槛
  2. citation_impact_recalculate()    → 更新被引用 Skill 的 CI 值
  3. direction_profile_update(ns_id)  → 追加 historical_seeds
HOOK_TYPE: post-commit (不可阻塞主流程)
```

### 6.6 `on_skill_forked` (事件钩子)
```
触发时机: skill_fork / skill_absorb 成功后
触发动作:
  1. cp_promotion_check(ns_id)        → 检查 fork 者是否达到策元核晋升门槛
  2. citation_impact_recalculate()    → 重算 parent Skill 及上游的 CI 值
  3. lineage_graph_update()           → 更新引用图索引
HOOK_TYPE: post-commit (不可阻塞主流程)
```

---

## 七、防攻击设计

| 攻击向量 | 防御措施 |
|---------|---------|
| 深度伪造引用链 | CI 按 1/depth 衰减 + quality 门槛 (quality < 2.0 衍生不计入 CI) |
| 创造者贡献虚报 | modifications 必须携带 evidence_genesis (可交叉验证的策元 ID) |
| 引用环 | 创建时 BFS 检测：目标 Skill 不可出现在新 Skill 的祖先路径中 |
| 创造者印记篡改 | Layer 8 写入后不可修改 (immutable), 只能 append 新版本 |
| Sybil 互引刷 CI | 同一策元的成员互引: CI 贡献乘以 cooperative_discount = 0.5 |

---

## 八、事件系统 (Event System)

### 8.1 事件定义

Skill Lineage 协议的生命周期操作会发出以下标准事件，驱动下游协议的联动更新：

| 事件名 | 触发操作 | 载荷 |
|--------|---------|------|
| `skill.created` | `skill_create` 成功 | `{skill_id, ns_id, genesis_id, layers[]}` |
| `skill.forked` | `skill_fork` 成功 | `{new_skill_id, parent_skill_id, ns_id, fork_type, modifications[]}` |
| `skill.absorbed` | `skill_absorb` 成功 | `{target_skill_id, source_skill_id, ns_id, absorbed_layers[]}` |

### 8.2 下游协议联动

每个事件发出后，自动触发以下跨协议动作：

```
skill.created ──────→ [CP Promotion Check]     cp_promotion_check(ns_id)
                 ├──→ [Citation Impact]          citation_impact_recalculate()
                 └──→ [Direction Profile]        direction_profile_update(ns_id)

skill.forked ──────→ [CP Promotion Check]        cp_promotion_check(ns_id)
                ├──→ [Citation Impact]           citation_impact_recalculate(parent_skill_id)
                ├──→ [Direction Profile]         direction_profile_update(ns_id)
                └──→ [Lineage Graph]             lineage_graph_update()

skill.absorbed ────→ [CP Promotion Check]        cp_promotion_check(ns_id)
                ├──→ [Citation Impact]           citation_impact_recalculate(source_skill_id)
                └──→ [Direction Profile]         direction_profile_update(ns_id)
```

### 8.3 事件可靠性保证

| 保证 | 机制 |
|------|------|
| **至少一次投递** | 事件持久化至 event_log，消费端 ack 后删除 |
| **幂等性** | 每个事件携带 `idempotency_key`（skill_id + event_type），重复消费自动跳过 |
| **顺序性** | 同一 Skill 的事件按 wall-clock 顺序投递 |
| **隔离性** | 钩子为 post-commit 类型，事件投递失败不影响 Skill 创建/分叉主流程 |

---

*Skill Lineage & Citation Protocol v1.0 — 2026-05-18*


---

## 九、Skill→CP 三层闭环钩子（v1.1 新增 — CONC-P1-3）

> 对应 `11_Discuss/P1_Summary_Modifications.md` §P1-3 和 CP Promotion 修正案。

Skill产出通过三层钩子自动触发能证晋级：

**钩子1 — 策元级**：`genesis_unit.complete()` 事件 → 自动批量触发该策元所有产出Skill的 `cp_promotion_check`

**钩子2 — Skill级**：`skill.Q_composite > 0.8 OR skill.citation_count > 10` → 触发单个Skill晋级

**钩子3 — 跨策元级**：对于参与 ≥3 个策元的智权体，加权策元多样性 $S_3(n)$ 参与CP4匹配

```json
// genesis_unit.complete() 触发事件
{
  "event_type": "GENESIS_UNIT_COMPLETED",
  "gu_id": "gu_...",
  "produced_skills": ["sk_a1", "sk_a2", "sk_a3"],
  "auto_promotion_check": true,
  "promotion_results": {
    "sk_a1": "CP_PROMOTED: L1→L1+",
    "sk_a2": "CP_NO_CHANGE",
    "sk_a3": "CP_PROMOTED: ∅→L1"
  }
}
```

## 十、策元种子引力机制（v1.1 新增）

> 颠覆性Skill的分布式探索机制——由人围绕其形成新策元来获得初始流量。

$$CI_{boosted}(s_{novel}) = CI(s_{novel}) + \alpha \cdot \sum_{G \in \text{seeded by } s_{novel}} \frac{1}{\text{size}(G)}$$

新创意图元形成的策元规模越小，每个成员的CI贡献越高——激励小规模策元作为颠覆性Skill的"孵化器"。

---

*协议版本 v1.0 → v1.1 (2026-07-10)：三层钩子 + 策元种子引力*
