# 授权衰减协议 v1.0
## Authorization Decay Protocol — Skill 知识保护与公共化动态

> **对应理论**: SBDEL v2.0 §四（授权衰减曲线）、公理六（授权衰减公理）、Model 08
> **依赖协议**: PCP (策元共识协议)、Skill Lineage (引用链)
> **协议层级**: SBDEL 层 — Skill 授权管理与分层释放

---

## 一、协议概述

本协议定义 Skill 从策元结束后的私有保护状态渐进过渡到全网公共状态的完整机制。核心原则：**创造者的先发优势被时间保护，同时网络的知识壁垒被时间消解。**

---

## 二、三阶段衰减函数

$$A(s, t) = \begin{cases}
A_{\min} & t \leq T_1 \\[6pt]
A_{\min} + (1 - A_{\min}) \cdot \left(\frac{t - T_1}{T_2 - T_1}\right)^{\beta} & T_1 < t \leq T_2 \\[6pt]
1 & t > T_2
\end{cases}$$

| 参数 | 含义 | 取值范围 | 决定方式 |
|------|------|:---:|------|
| $A_{\min}$ | 锁定期最低可及性 | [0, 0.3] | PCP 共识 (默认 0.1) |
| $T_1$ | 锁定期时长 | [1, 24] 月 | PCP 共识 + 领域因子校准 |
| $T_2$ | 完全公开时间 | $T_1 + [6, 36]$ 月 | $T_1$ + 释放窗口 |
| $\beta$ | 释放曲线形状 | [0.3, 3.0] | PCP 投票 (默认 1.0) |

---

## 三、分层释放时间表

Skill 的 8 个 Layer 不是同时公开——遵循分层释放：

```
t=0 (策元结束):
  Layer 1 (场景描述)     → A_min (最低公开度)
  Layer 2-8             → 完全私有

t=T₁ (锁定期结束):
  Layer 1               → 完全公开
  Layer 2 (过程记录)     → 渐进公开
  Layer 3-8             → 仍需授权

t=T₁ + (T₂-T₁)×0.3:
  Layer 1-2             → 完全公开
  Layer 3 (决策记录)     → 渐进公开
  Layer 4-8             → 仍需授权

t=T₁ + (T₂-T₁)×0.6:
  Layer 1-3             → 完全公开
  Layer 4 (蒸馏知识)     → 渐进公开
  Layer 5-8             → 仍需授权

t=T₂ (完全公开):
  Layer 1-5             → 完全公开
  Layer 6 (授权状态)     → 公开（历史记录）
  Layer 7 (引用链)       → 完全公开（永久）
  Layer 8 (创造者印记)   → 完全公开（永久不可删除）
```

**关键设计**: Layer 7（引用链）和 Layer 8（创造者印记）永不衰减——即使 Skill 内容完全公开，创造者的贡献记录永久保留。

---

## 四、衰减因子动态校准

$$\lambda(s) = \frac{\lambda_0 \cdot f(\text{domain}) \cdot g(\text{investment}) \cdot h(\text{consensus})}{1 + \kappa \cdot \text{competitive\_density}(s)}$$

### 4.1 领域因子 f(domain)

| 领域 | f | 逻辑 |
|------|:---:|------|
| 开源基础设施 | 2.0 | 快速公开 |
| 通用消费品 | 1.0 | 标准保护 |
| 商业竞争领域 | 0.5 | 延长保护 |
| 国防/安全相关 | 0.2 | 长期保护 |

### 4.2 投入因子 g(investment)

$$g(\text{investment}) = \left(\frac{\text{total\_hours}}{\text{median\_hours\_in\_domain}}\right)^{-0.3}$$

幂指数 -0.3 防止"堆工时换保护"套利。

### 4.3 共识因子 h(consensus)

由策元成员在 PCP 中投票决定，[0.2, 3.0]。h > 1 加速公开，h < 1 延长保护。

### 4.4 竞争密度

$$\text{competitive\_density}(s) = \frac{|\{s' \in V_S : \text{sim}(s, s') > 0.8\}|}{|V_S|}$$

同类 Skill 越多 → 壁垒越快被稀释 → λ 越大 → 保护期越短。

---

## 五、自适应调整规则

### 加速公开触发

| 条件 | 效果 |
|------|------|
| `total_citation_count > 10` | $T_1$ 减半 |
| `creator inactive > 6 months` | $A_{\min}$ 翻倍 |
| `quality(new_version) > 1.2 × quality(this)` | 锁定期提前结束 |
| `network_demand_score > 0.8` | $\beta$ 降低 (加速释放) |

### 延长保护触发

| 条件 | 效果 |
|------|------|
| `active_version_updates > 3 in 6 months` | $T_1$ 延长 25% |
| `competitive_density < 0.1` | 保护期延长 50% |
| `unanimous_vote of all genesis members` | $T_2$ 最多延长 50% |

---

## 六、授权凭证机制

锁定期内的 Skill 使用需要创造者指纹授权：

```json
{
  "authorization_token": "auth_uuid_v7",
  "skill_id": "sk_xxx_v2.1",
  "granted_by": "ns_alice_001",
  "granted_to": "ns_dave_004",
  "scope": "read_and_adapt",
  "conditions": [
    "must_cite_in_lineage",
    "must_not_resell_standalone",
    "derivative_must_reference_parent"
  ],
  "compensation": {
    "type": "citation_plus_vt_share",
    "vt_share_percent": 5
  },
  "expires_at": "2027-06-01",
  "signature": "ed25519:..."
}
```

**授权转移策略**: 默认 `requires_creator_fingerprint`——只有创造者可以授予授权。策元可在 PCP 中指定其他策略。

---

## 七、API 定义

### 7.1 `authorization_check`
```
INPUT:  skill_id, requester_ns_id
OUTPUT: accessibility_level (0-1), accessible_layers[], authorization_required (bool)
```

### 7.2 `authorization_grant`
```
INPUT:  skill_id, grantee_ns_id, scope, conditions[], compensation
OUTPUT: authorization_token, expires_at
SIGN_REQUIRED: creator Ed25519 signature
```

### 7.3 `decay_status`
```
INPUT:  skill_id
OUTPUT: current_A, current_phase, next_phase_at, accessible_layers
```

### 7.4 `decay_trigger_check`
```
INPUT:  skill_id
OUTPUT: triggered_adjustments[{condition, effect, new_params}]
```

---

## 八、防攻击设计

| 攻击向量 | 防御 |
|---------|------|
| 策元恶意设定无限锁定期 | $T_1$ 上限 24 月，$T_2$ 上限 $T_1$ + 36 月 |
| 创造者恶意拒绝所有授权 | inactive > 6 months → $A_{\min}$ 翻倍 (强制公开) |
| 刷 citation_count 加速公开 | 同一策元成员互引用: 计入 cooperative_discount = 0.5 |
| domain 因子作弊 | domain 分类由策元共识 + 第三方交叉验证 |

---

*Authorization Decay Protocol v1.0 — 2026-05-18*


---

## 七、定理S5六因子实现（v1.1 新增 — CONC-P0-3）

> 对应定理S5（风险补偿衰减，`01_Core/02_Core_Axioms.md` §SBDEL定理层）。

$$\lambda(s) = \frac{\lambda_0 \cdot f(\text{domain}) \cdot g(\text{investment}) \cdot h(\text{consensus}) \cdot r(\text{failure\_risk})}{1 + \kappa \cdot \text{competitive\_density}(s) \cdot \tau(\text{regulatory\_friction})}$$

新增因子：
- $r(\text{failure\_risk}) = (1/\text{success\_probability})^{\eta}$ — 行业失败风险结构
- $\tau(\text{regulatory\_friction}) = T_{\text{regulatory}}/T_{\text{development}}$ — 监管摩擦补偿

**参数默认值**：η∈[0.1,0.5]，κ=1.0，均为框架预设——待实证校准。

## 八、$B_{min}$ 和 $T_1^{\min}$ 定义（v1.1 新增）

$$B_{min}(s) = B_0 \cdot r(\text{failure\_risk}) \cdot \tau(\text{regulatory\_friction})$$
$$T_1^{\min}(s) = T_0 \cdot \frac{1}{\lambda_{\text{eff}}(s)} \cdot \phi(\text{domain})$$

默认：$B_0=0.05$, $T_0=3$月（框架预设，PCP可覆盖）。

## 九、竞争密度：从文本相似度→市场替代率（v1.1 修正）

竞争关系由市场替代率决定，不由文本相似度决定。两个Skill之间的竞争取决于它们解决同一场景问题的可替代性。过渡方案：场景标签Jaccard相似度作为替代率代理变量。

---

*协议版本 v1.0 → v1.1 (2026-07-10)*
