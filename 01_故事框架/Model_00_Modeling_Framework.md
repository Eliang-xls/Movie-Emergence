# CONC 数学建模框架
## Mathematical Modeling Framework — Scope Definition

> 对标比特币白皮书以密码学证明为核心贡献，CONC 需以博弈论、信息经济学和网络物理学证明为核心贡献。

---

## 五大模型命题（v1.0）+ SBDEL 模型扩展（v2.4）+ CP Promotion（v2.5）+ Phronesis 形态演进（v2.8）

### 模型一：搭便车博弈 — 合作作为纳什均衡
**对应红队攻击**: INFERNO-001 攻击 2.1-2.3 (公地悲剧三部曲)
**文件**: [01_Game_Theory_Cooperation_v2.md](./01_Game_Theory_Cooperation_v2.md)

### 模型二：ALP 流动性池稳定性
**对应红队攻击**: INFERNO-001 攻击 5.1 (DeFi 死亡螺旋)
**文件**: [02_ALP_Stability_v2.md](./02_ALP_Stability_v2.md)

### 模型三：能证 (NR) 的信号博弈
**对应红队攻击**: INFERNO-001 攻击 3.1 (马太效应), INFERNO-002 攻击 5 (Sybil)
**文件**: [03_NR_Signaling_v2.md](./03_NR_Signaling_v2.md)

### 模型四：超织体鲁棒性 — 渗透理论
**对应红队攻击**: INFERNO-003 T3-T4
**文件**: [04_Network_Percolation.md](./04_Network_Percolation.md)

### 模型五：策元 vs 公司 — 交易成本边界
**对应红队攻击**: INFERNO-001 攻击 1.1-1.2
**文件**: [05_Coase_Benkler_Boundary_v2.md](./05_Coase_Benkler_Boundary_v2.md)

---

## SBDEL 模型扩展（v2.4 新增）

### 模型八：SBDEL 授权衰减曲线 + CP Decay 对偶
**对应来源**: 定理 S4（衰减收敛）+ 定理 CP3（能证衰减对偶）
**核心**: Skill 知识保护与公共化的三阶段动态，以及能证验证强度的同步衰减
**文件**: [08_SBDEL_Authorization_Decay.md](./08_SBDEL_Authorization_Decay.md)

### 模型九：SBDEL 壁垒动力学与引用影响力
**对应来源**: 定理 S2（分布式增益）+ S3（引用链可追溯）
**核心**: 从个人知识垄断到网络集体记忆的数学描述
**文件**: [09_SBDEL_Barrier_Dynamics.md](./09_SBDEL_Barrier_Dynamics.md)

---

## CP Promotion 管道模型（v2.5 新增，CONC-AMD-001）

### 模型十：能证晋级管道 — Skill→CP 反馈闭环
**对应来源**: 定理 CP1-CP4（能证晋级管道定理层）
**核心**: Skill 八层结构到能证三维度（L0自声明→L1背书→L2网络验证）的量化映射、晋级条件判定、能证衰减（S4对偶）、三信号融合匹配算法
**文件**: 定理层定义见 [02_Core_Axioms.md](../01_Core/02_Core_Axioms.md) §CP Promotion管道定理层；SEW函数及晋级/衰减定义见 [03_Ontological_Glossary.md](../01_Core/03_Ontological_Glossary.md) §Ⅷ

---

## Phronesis 形态演进模型（v2.8 新增，CONC-PBA-001）

### 模型十一：Phronesis形态演进 — 二元域划分与边界审计
**对应来源**: 定理 PBA1-PBA3（PBA 定理层）
**核心**: Sophia/Phronesis 基于可验证性切割的二元域划分、Phronesis 三核心成分（方向/价值/协同）操作化、P_d(t) 动态演化方程、三大结构性天花板（自检盲区/奖励缺失/异常缺口）的工程实证锚定、PBA 锚定点审计接口、Phronesis 杠杆效应 $P_{\\text{CONC}}(t) = P_0 + \\alpha \\cdot N_{\\text{metaverse}}(t) + \\beta \\cdot S_{\\text{cross}}(t)$
**文件**: [04_Phronesis_Morphology_Evolution.md](./04_Phronesis_Morphology_Evolution.md)

---

## 模型之间的关系

```
                     ┌──────────────────┐
                     │  模型三: NR 信号  │ ← 个体能力如何被可信揭示
                     └────────┬─────────┘
                              │ 信号质量决定
                              ▼
┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐
│ 模型一: 搭便车   │  │ 模型二: ALP 稳定 │  │ 模型五: 成本边界 │
│ 合作均衡         │  │ 死亡螺旋条件     │  │ 策元 vs 公司      │
└────────┬─────────┘  └────────┬─────────┘  └────────┬─────────┘
         │                     │                     │
         └─────────────────────┼─────────────────────┘
                               │ 全部依赖
                               ▼
                    ┌──────────────────┐
                    │ 模型四: 网络鲁棒  │ ← 网络结构是否支撑上述机制
                    └──────────────────┘
                               │
                    ┌──────────┴──────────┐
                    │  SBDEL 模型扩展      │
                    │  模型八: 授权衰减    │ ← Skill 时间经济 + CP Decay对偶
                    │  模型九: 壁垒动力学  │ ← 知识从垄断到记忆
                    └──────────┬──────────┘
                               │ Skill质量证据回流
                               ▼
                    ┌──────────────────────┐
                    │  模型十: CP Promotion │ ← Skill→CP反馈闭环
                    │  三层信号 + 晋级管道   │     能证开环→闭环
                    └──────────────────────┘
```

---

## 执行计划

| 阶段 | 任务 | 执行者 |
|:----:|------|--------|
| 1 | 定义八模型范围 | ✓ theory-architect (本文件) |
| 2 | 收集学术参照模型 | data-structurer |
| 3 | 构建数学模型 | theory-architect |
| 4 | 攻击模型假设 | red-team-critic |
| 5 | 修正与定稿 | theory-architect |

---

*Hermes Agent — 架构师与逻辑编译器*
*数学建模框架 v0.3 — 五大命题（v1.0）+ 二大 SBDEL 模型（v2.4）+ CP Promotion（v2.5）。*
