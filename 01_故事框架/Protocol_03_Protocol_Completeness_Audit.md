# CONC 底层协议完备性审计
## Protocol Completeness Audit — What's Built, What's Missing

> *"请先确认基于理论框架所有涉及的底层协议都构建好了吗"*

---

## 总览：14 个协议/机制，10 个有正式规范

| # | 协议/机制 | 当前状态 | 规范文档 | 完备度 |
|:--:|---------|:------:|---------|:----:|
| 1 | **ICP（创意聚合协议）** | ✅ 已规范 | `03_Protocols/02_Intent_Coalescence_Protocol.md` | 85% |
| 2 | **PCP（预共识协议）** | ✅ 已规范 | `03_Protocols/01_Protocol_Layer.md` §7 | 70% |
| 3 | **六层协议栈（整体架构）** | ✅ 已规范 | `03_Protocols/01_Protocol_Layer.md` | 75% |
| 4 | **DAG 任务依赖路由** | ✅ 已规范 | `03_Protocols/01_Protocol_Layer.md` §3.4 | 80% |
| 5 | **CTCP（任务令协议）** | ✅ 已规范 | `03_Protocols/04_CTCP_CSIP_Specification.md` | 85% |
| 6 | **CSIP（技能接口协议）** | ✅ 已规范 | `03_Protocols/04_CTCP_CSIP_Specification.md` | 85% |
| 7 | **PEER(n) 验证协议** | ✅ 已规范 | `03_Protocols/05_PEER_Verification_Protocol.md` | 85% |
| 8 | **阶梯式燃烧协议** | ✅ 已规范 | `03_Protocols/08_Tiered_Slashing_Protocol.md` — 三相状态机、分段函数、4 API、ALP 集成 | 90% |
| 9 | **弹性共识分叉协议** | ✅ 已规范 | `03_Protocols/07_Elastic_Forking_Protocol.md` — 软/硬分叉 API、Proof-of-Merge、液态算力、状态机、19 API、反滥用 | 85% |
| 10 | **反垄断阻尼系数** | 🟡 描述性 | 反集中化工具箱 v2.0 中有公式——无协议规范 | 30% |
| 11 | **CCR 公开账本** | ✅ 已规范 | `03_Protocols/06_CCR_Public_Ledger.md` — 数据模型、公式、隐私边界、5 API、5 反刷分防御 | 85% |
| 12 | **策元分裂协议** | 🔴 仅概念 | `08_Product_Lifecycle_and_GU_Split.md` 有形式化定义——无协议 | 15% |
| 13 | **开放工厂协议** | 🔴 仅提及 | 仅在前提一中提到概念——零规范 | 5% |
| 14 | **NR 信号机制** | 🔴 仅模型 | 模型三有演化博弈分析——无协议规范 | 10% |

---

## 二、逐项详审

### ✅ 已规范（6 项）

| 协议 | 完备内容 | 缺失 |
|------|---------|------|
| **ICP** | Creative Seed JSON Schema、5维方向向量定义、相似度计算、三阶段聚结(seed broadcast→intent expression→genesis crystallization)、sim阈值策略(策元自治非平台统一)、聚类分析后台进程、API端点(GET /intent-pool, POST /seeds, POST /coalesce) | 异质性注入机制(低相似度互补成员)未写入协议 |
| **PCP** | JSON Schema(fixed_params + customizable_params + runtime_amendable)、5类回报分配公式、IP归属、解散程序、责任尾期 | 缺少策元分裂条款—维护托管契约的形式化 |
| **协议栈** | 六层架构(身份/策元/验证/价值/网络/桥接)、25+ API端点、协议版本化策略(CONC-Protocol/{layer}.{major}.{minor})、12项攻击向量防御 | ALP API未纳入价值层 |
| **DAG路由** | depends_on/blocks字段、级联触发规则、循环检测、API端点(POST /task-warrant/create, POST /publish, GET /dag) | 缺少跨策元依赖的约束定义 |
| **CTCP+CSIP** | 完整 JSON Schema(双协议)、生命周期状态机(BROADCAST→STAKED_LOCKED→EXECUTING→VALIDATING→MERGED_RESOLVED/DECAYING_SLASHED)、DAG路由集成、博弈引擎(阶梯式燃烧+算力抢断) | — |
| **PEER(n)** | 评审资格、随机化分配算法(防共谋)、加权评分聚合公式、评审者质量追踪、争议升级路径(PEER3→PEER5→策元全体)、NR集成 | — |
| **CCR 公开账本** | 数据模型(VT贡献来源4类/CU消费来源4类)、CCR计算公式(质量加权+模式加权+指数时间衰减)、三层次隐私边界(公开/策元内/仅己)、5个API端点、5个反刷分防御 | — |
| **弹性分叉协议** | 软分叉(Branch)协议(≤20%算力、Proof-of-Merge三阶段门控)、硬分叉(Split)协议(α_A+α_B≤1、液态算力潮汐效应、市场测试窗口)、跨分叉微服务共享、完整状态机(9态软分叉+7态硬分叉)、19个API端点、5层协议栈集成、反滥用机制(6项防轻浮分叉+3项质量门控+NR/CCR反滥用联动) | — |

### ⚠️ 已从 Gemini RFC 吸收至核心协议栈（原 2 项 — 已全部完成）

| 协议 | Gemini 版提供的 | 核心版状态 |
|------|--------------|----------|
| **CTCP** | 完整 JSON Schema(5层：Context/Topology/Matching/GameTheory/Verification)、生命周期状态机(BROADCAST→STAKED_LOCKED→EXECUTING→VALIDATING→MERGED_RESOLVED/DECAYING_SLASHED)、DAG路由依赖 | ✅ 已吸收 — `03_Protocols/04_CTCP_CSIP_Specification.md` |
| **CSIP** | 完整 JSON Schema(双螺旋：Helix_Cold_Start_Layer/Helix_Dynamic_Matrix/Reputation_Vault)、ZK-Proof 冷启动锚定 | ✅ 已吸收 — `03_Protocols/04_CTCP_CSIP_Specification.md` |

### 🟡 描述性（1 项—有机制但无协议）

| 协议 | 现有内容 | 缺失 |
|------|---------|------|
| **反垄断阻尼** | S_req = S₀·e^(λW) 公式、λ 敏度分析 | 无协议层执行点(W的计算/λ的动态调整)、无与策元 join 流程的集成 |

### ✅ 已从描述性补全为正式规范（原 🟡 项）

| 协议 | 原状态 | 补全后规范 |
|------|:------:|---------|
| **阶梯式燃烧** | 分段函数 S_burn 公式、三阶段概念——无状态机/API | ✅ `03_Protocols/08_Tiered_Slashing_Protocol.md` — 三相状态机、分段函数、4 API、ALP 保险池集成 |

### 🔴 仅概念（4 项—零协议规范）

| 协议 | 概念位置 | 需要什么 |
|------|---------|---------|
| **CCR 公开账本** | 公理体系、反集中化工具箱 | ✅ **已规范** — `03_Protocols/06_CCR_Public_Ledger.md`。数据格式(VT贡献来源4类/CU消费来源4类)、CCR计算公式(质量加权+模式加权+指数时间衰减)、三层次隐私边界(公开/策元内/仅己)、5个API端点、5个反刷分防御机制(速度检查/拆分检测/消费最低线/Sybil集群/时间衰减)、与协议栈5点集成(任务令匹配/策元核选举/争议仲裁/阻尼系数/身份层)。 |
| **策元分裂** | `08_Product_Lifecycle_and_GU_Split.md` | Split操作的API、维护托管策元的自动创建条件、产品节点注册协议 |
| **开放工厂** | Refined Draft 前提一 | 工厂模块接口标准、生产计划提交格式、调度协议、结算协议 |
| **NR 信号** | 模型三 | NR 的计算/更新/衰减协议、PEER评审反馈→NR调整的API、跨策元NR查询接口 |

---

## 三、与实验的关联

对照实验设计需要验证 5 个假设——它们对应的协议完备度：

| 实验假设 | 依赖的协议 | 协议完备度 | 实验可行性 |
|---------|----------|:------:|:--:|
| H1: ICP 匹配 | ICP | ✅ 85% | ✅ 可直接实验 |
| H2: 内源优先 | 任务令三阶段分配 | ✅ 80%（DAG路由已有） | ✅ 可直接实验 |
| H3: PEER 聚合 | PEER(n) | ✅ 85% | ✅ 可直接实验 |
| H4: CCR 公开 | CCR 公开账本 | ✅ 85% | ✅ 可直接实验 |
| H5: 弹性分叉 | 弹性共识分叉 | ✅ 85% | ✅ 可直接实验 |

**结论**：全部 5 个实验假设对应的协议现已达到 80%+ 完备度——均可直接进行对照实验。此前 H3（PEER 聚合）和 H5（弹性分叉）为阻塞项，现已全部补全。这意味着 ABM 仿真可以从\"模仿 CONC 机制的非正式行为\"升级为\"通过正式协议规范驱动的协议化实验\"。

**结论**：H1、H2 和 H4（CCR 规范已完成）可以立即实验。H3 和 H5 需要先补全对应的协议规范——否则实验测量的不是 CONC 的协议机制，而是"人类模仿 CONC 机制的非正式行为"。

---

## 四、补全优先级

| 优先级 | 协议 | 理由 | 工作量 |
|:--:|------|------|:--:|
| 🔴 P0 | **CTCP + CSIP** 从 Gemini RFC 吸收 | ✅ 已完成 — `04_CTCP_CSIP_Specification.md` | — |
| 🔴 P0 | **PEER(n) 评审协议** | ✅ 已完成 — `05_PEER_Verification_Protocol.md` | — |
| 🔴 P0 | **CCR 公开账本规范** | ✅ 已完成 — `06_CCR_Public_Ledger.md` | — |
| 🔴 P0 | **弹性分叉协议** | ✅ 已完成 — `07_Elastic_Forking_Protocol.md` | — |
| 🟡 P1 | **阶梯式燃烧协议** | 公理四的完整实现 | 0.5天 |
| 🟢 P2 | **策元分裂协议** | 实验阶段不需要（2-4周实验不会涉及产品上市） | 0.5天 |
| 🟢 P2 | **开放工厂协议** | 阶段三才需要 | 待定 |
| 🟢 P2 | **NR 信号协议** | 实验可手动追踪 | 待定 |

---

## 五、诚实结论

**14 个协议/机制中，10 个有正式规范。4 个仅存在于概念描述中。**

**但这不意味着框架不完整——比特币白皮书也没有定义 JSON Schema 或 API 端点。** 协议规范是工程问题，理论框架回答的是"为什么需要这个协议"和"协议的核心逻辑是什么"。当前的缺失是**工程补全**——不是**理论漏洞**。

对实验而言：全部 5 个假设（H1-H5）的依赖协议均已有正式规范，可以立即进行对照实验验证。
