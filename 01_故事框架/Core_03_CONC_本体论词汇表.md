# CONC 本体论词汇表
## Ontological Glossary v0.5

> 本词汇表是 CONC 框架的逻辑地基。每个术语拥有精确的、不可被近义词替代的定义。所有后续推导、协议设计和工程实现均以本表为语义锚点。
>
> **v0.5 更新**: 能证（Capability Proof）定义扩展为三层信号体系（L0自声明→L1Skill背书→L2网络验证）。新增 Ⅷ. 能证晋级管道术语章节——3 个新术语（能证晋级、能证衰减、Skill背书权重）。应用 CONC-AMD-001 修正案。

---

## Ⅰ. 核心实体 (Core Entities)

### 智权体
### Noetic Sovereign (NS) **[CONC自有]**

**定义：** 在 CONC 框架中，智权体是指 AI 增强下的自然人——一个不可约的自主决策节点。智权体拥有：(a) 跨越传统学科边界的学习与操作能力；(b) 并行参与多个策元的认知带宽与工具支撑；(c) 对其时间、技能和注意力的完全自主分配权。智权体是 CONC 的原子经济单位，对应公司制中的"个人"但彻底超越了其岗位依附性。

**术语来源：** 智 (noetic) 指向其认知与智能增强属性；权 (sovereign) 指向其不可让渡的自主决策权。二者合一，定义了一个既拥有超域认知力、又保有完整主权的基础单元。

**不可混淆为：** 传统公司的员工、自由职业者、个体户。区别在于：智权体是 **主权节点** 而非 **岗位占据者**。

**出处：** 公理二（主权节点公理）；第一章"思维范式的迁移"。

**旧称：** 超级个体 (Super Individual)

---

### 策元
### Genesis Unit (GU) **[CONC自有]**

**定义：** 策元是 CONC 中最小的生产组织单元。当两个或以上智权体围绕共享的创意图元形成聚结，并正式确立项目目标与管理结构时，一个策元即告结晶。策元具有明确的生命周期起点和终点，其存在与所承载的项目共始终。策元在功能上对应公司制中的"公司/项目组"，但在结构上不依赖层级架构或固定劳动关系。

**术语来源：** 策 (genesis) 指向创意/倡议的发起与策略的生成；元 (unit) 指向其作为不可再分的组织原子。策元即"创意凝结而成的组织基元"。

**不可混淆为：** 互联网论坛的"版块"（仅讨论无生产）、公司的"部门"（永久性科层结构）、DAO（去中心化自治组织；策元不一定基于链上治理）。

**出处：** 公理三（涌现收敛公理）；第四章"论坛隐喻"。

**旧称：** 板块 (Board)

---

### 节点
### Node **[CONC自有]**

**定义：** 节点是 CONC 网络拓扑中的基本单元。一个节点对应一个智权体。节点之间的连接关系由策元参与关系定义。节点的"边"（Edge）代表该节点与同一策元内其他节点的协作关系。CONC 网络是一个动态图，节点的加入和离开改变图的拓扑结构。

**形式化：** CONC 网络 G = (N, E)，其中 N 为智权体集合，边集 E = {(n_i, n_j) | ∃ G ∈ GenesisUnits : n_i ∈ G ∧ n_j ∈ G}。

**出处：** 公理二；第五章"去中心化技术借鉴"。

---

### 策元核
### Genesis Core (GC) **[CONC自有]**

**定义：** 策元核是策元内部通过共识机制推选产生的协调者角色。策元核的权限范围由策元形成时的预共识协议定义，仅限于该策元的项目执行周期内。策元核不拥有对成员的人身管理权——其协调权力仅作用于策元内的任务分配、验收调度和冲突仲裁。策元核在功能上对应公司制中的"项目经理/CEO"，但在权力来源上来自成员授权而非资本任命。

**术语来源：** 核 (core) 取自细胞生物学隐喻——细胞核协调细胞活动但不"统治"细胞器。策元核是策元的协调中枢，而非层级顶端。

**出处：** 第四章"策元即微型公司"；待解问题 #2。

**旧称：** 版主 (Moderator / Coordinator)

---

### 模块
### Module **[CONC自有，模块化思想借鉴 Parnas(1972)[12]]**

**定义：** 模块是 CONC 中经济协作的不可再分的原子单位。每个模块封装了：(a) 明确的输入/输出规格；(b) 提供方（承接的智权体）；(c) 验收方与可客观执行的验收标准；(d) 完成后的回报协议。模块取代了公司制中的"岗位职责描述"和"雇佣合同"，成为协作的基本契约形式。

**模块类型：** 任务模块（Task Module）、能证模块（Capability Module，用于能力声明而非直接交付——旧称"技能模块"，现正名为能证模块以避免与 SBDEL Skill 混淆）、资本模块（Capital Module，用于融资参与）。

**注意**：此处的"能证模块"是**能力的声明**（"我能做什么"）——不应与 SBDEL §0.7 的 "Skill"（"我做了什么并学到了什么"）混淆。前者回答"我声称具备什么能力"，后者回答"我在真实场景中产生了什么知识"。两者在 CONC 框架中扮演互补角色——能证用于任务令匹配（事前），Skill 用于知识流通（事后）。

**出处：** 公理四（模块承诺公理）；第六章"路径构想"。

---

### 任务令
### Task Warrant (TW) **[CONC自有]**

**定义：** 任务令是任务模块的具体化呈现——一个由 AI 从策元项目计划中拆解出的、可被智权体领取并执行的工作单元。每道任务令包含：任务描述、所需技能接口、预估工时、验收标准和回报。智权体可以自由领取、组合来自不同策元的任务令。任务令是工时自治的物质载体。

**术语来源：** 令 (warrant) 兼有"指令"与"授权凭证"双重含义——它既是工作指令，也是完成后的回报兑付凭证。比"卡片"更具契约严肃性。

**不可混淆为：** Jira Ticket（依附于公司项目管理体系）、众包任务（通常无预共识回报协议）。

**出处：** 第六章"工作与工时模块化"。

**旧称：** 任务卡片 (Task Card)

---

### 自主生产系统
### Autonomous Production System (APS) **[CONC自有]**

**定义：** 自主生产系统是指在脱离人类层级管理的前提下，能够独立完成从原材料到成品的完整生产流程的智能系统。包括但不限于：智能工厂、AI 驱动的供应链、柔性生产线、3D 打印制造网络。APS 是公理一的物质载体——它的成熟度为 CONC 框架提供了"生产不再需要公司协调"的物质前提。

**出处：** 公理一（生产解耦公理）；第一章"阶段七"。

---

### 智契
### Noetic Companion (NC) **[CONC自有]**

**定义：** 智契是智权体的 AI 使能层——一套为智权体服务的智能软件系统，具备：任务编排、多策元日程管理、技能模块生成与维护、知识检索与学习辅助等功能。智契是智权体"多域并行能力"的技术基础。一个智契绑定于一个智权体，是其认知与协调能力的放大器。

**术语来源：** 智 (noetic) 指向智能本质；契 (companion/compact) 双重含义——既是"伴侣"（持久绑定的辅助者），也是"契约"（与个体的服务绑定关系）。一个音节即承载双重语义。

**不可混淆为：** 通用 AI 助手（ChatGPT 类）。智契是任务导向的、持久绑定智权体身份和能证档案的、与 CONC 协议栈集成的专用系统。

**出处：** 第六章"个人 Agent 助理"；公理二。

**旧称：** 个人超级智能体 (Personal Super-Agent)

---

## Ⅱ. 组织与结构 (Organization & Structure)

### 超织体
### Hyperweave (HW) **[CONC自有]**

**定义：** 超织体是智权体之间的松散耦合网络。它是 CONC 的宏观拓扑形态——一个由节点（智权体）和边（策元协作关系）构成的动态图。超织体不具有中心节点，不具有永久层级，网络拓扑随策元的创生和消亡而持续演化。超织体是"后公司时代"社会生产关系的整体描述性概念。

**术语来源：** 超 (hyper) 指向其超越传统组织形态的维度；织 (weave) 指向节点如经纬般相互交织、形成柔性且强韧的结构。织体的强度来自交织关系本身，而非中心支柱。

**不可混淆为：** 联盟（Alliance，通常指组织间的正式联合）、网络（Network，泛指）、市场（价格信号驱动的非结构化交换）。

**出处：** 第零章"概念定义"。

**旧称：** 超联 (Hyper-Assembly)

---

### 意图聚结
### Intent Coalescence **[CONC自有，知识协调理论借鉴 Hayek(1945)[15]]**

**定义：** 意图聚结是指两个或以上智权体的创意图元在共享空间中发生匹配，相似度超过预设阈值，从而触发策元形成的过程。聚结可以是自发的（智权体浏览平台发现相似创意）或辅助的（AI 推荐系统匹配）。聚结的完成标志是策元的正式建立和预共识协议的签署。

**术语来源：** 聚结 (coalescence) 取自物理化学——分散的液滴在表面张力作用下自发融合为更大液滴。这一隐喻精确捕捉了创意自发聚合、无需外力驱动的本质。

**形式化：** 给定相似度函数 sim 和阈值 θ，当 sim(seed(n_i), seed(n_j)) ≥ θ 时，n_i 与 n_j 进入聚结状态。

**出处：** 公理三（涌现收敛公理）。

**旧称：** 创意收敛 (Idea Convergence)

---

### 生命周期
### Lifecycle **[CONC自有]**

**定义：** 生命周期是策元从创建到解散的时间区间 [t_form, t_dissolve]。t_form 为意图聚结完成、预共识协议确立的时刻；t_dissolve 为以下条件之一满足的时刻：(a) 项目目标达成；(b) 策元成员数降至 2 以下；(c) 策元成员通过共识协议投票解散。策元的有限生命周期是 CONC 区别于公司"永续经营"假设的根本特征。

**出处：** 公理三；第四章"生命周期与自由进出"。

---

### 预共识协议
### Pre-Consensus Protocol (PCP) **[CONC自有，自组织治理原则借鉴 Ostrom(1990)[3]]**

**定义：** 预共识协议是策元建立时由创始成员共同签署的、定义策元运行规则的基础文件。PCP 至少包含：(a) 项目目标与范围；(b) 策元核推选与轮换机制；(c) 模块验收标准框架；(d) 回报分配公式；(e) 争议解决流程；(f) 策元解散条件。PCP 在功能上对应公司制中的"公司章程+劳动合同+薪酬体系+绩效制度"的融合体，但以可执行的协议形式存在。

**出处：** 公理四；待解问题 #3、#4。

---

## Ⅲ. 机制与过程 (Mechanisms & Processes)

### 工时自治
### Labor-Hour Autonomy **[CONC自有，动机理论基础借鉴 Deci & Ryan(1985)[9]]**

**定义：** 工时自治是指智权体在法定或自定的总工时约束内，完全自主地将其劳动时间分配至不同策元的任务令中。不存在外部权威（公司考勤制度、项目经理）对个体工时安排的强制。工时自治是主权节点公理在时间维度的直接体现。其与"弹性工作制"的根本区别在于：弹性工作制仍依附于单一雇佣关系；工时自治是跨策元、跨项目的自由组合。

**出处：** 公理二；第四章"关键区别"。

---

### 模块验证
### Module Verification **[CONC自有]**

**定义：** 模块验证是指验收方依据模块中预定义的验收标准，对提供方交付的模块产出进行客观评估的过程。验证函数 verify: M → {true, false} 必须满足：(a) 确定性——相同输入产生相同判断；(b) 第三方可执行——不依赖提供方或验收方的不可观察内部状态；(c) 时限性——验证在预设时间窗口内完成。模块验证取代了公司制中的"绩效评估"和"上级审阅"。

**出处：** 公理四。

---

### 回报分配
### Reward Distribution **[CONC自有，合作激励借鉴 Fehr & Gächter(2000)[8]]**

**定义：** 回报分配是按预共识协议中定义的公式，将策元产出的经济价值分配至各贡献节点的过程。回报可采取货币、权益、声誉积分等形式。分配以模块为计算粒度——每个已通过验证的模块贡献对应预设的回报份额。回报分配不依赖层级审批，由协议自动执行（理想情况下通过智能合约）。

**出处：** 公理四；待解问题 #3。

---

### 创意图元
### Creative Seed **[CONC自有]**

**定义：** 创意图元是智权体产生的、希望在某领域实现某种创造性产出的意向声明。创意图元不是完整的项目计划书，而是足以被相似度函数匹配的语义表示。它是策元形成的种子——在公司制中，对应"创业想法"，但不需要智权体承担全部组织成本和风险。

**术语来源：** 图元 (seed) 取自种子隐喻——它携带了创意方向的全部基因信息，但其生长为完整的"植株"（策元）需要土壤、养分和他者的共同参与。

**出处：** 公理三。

**旧称：** 创意意图 (Creative Intent)

---

### 能证
### Capability Proof (CP) **[CONC自有，信号理论基础借鉴 Spence(1973)[19]]**

**定义：** 能证是智权体在 CONC 网络中逐级积累的能力证明体系，采用三层信号架构——从自声明到网络验证，信号可信度逐级递增。晋级遵循公理二a的建议性原则：并非强制性升级，而是信号强度的自然累积。当 SBDEL Skill 通过 PEER 评审产出时，可自动触发对应能证晋级至 L1 或维持在 L1 级累积权重。能证与 Skill 的关系从 v2.4 的"互补"升级为 v2.5 的"互哺"——能证为 Skill 的评审权重提供校准锚点，Skill 为能证提供晋级燃料。

**三层信号体系：**

- **L0（自声明级）：** 智权体自行声明的能力条目，无需外部验证，仅依赖声明的自洽性和方向档案的一致性。可信度最低。用于初始任务令匹配的广域搜索。声明格式遵循能证模块模板。
- **L1（Skill背书级）：** 对应智权体有至少一个经 PEER 评审通过的 SBDEL Skill 支撑该能力。评审的严格性决定 L1 内的权重累积。L1 内可进一步细分为 L1（初始背书）和 L1+（多次跨策元背书）。可信度中，是任务令匹配的核心信号层。
- **L2（网络验证级）：** 对应智权体的 Skill 已被至少两个外部策元引用或复用（非本策元成员引用），即 Skill 的引用链中存在跨策元边。L2 意味着该能力已被 CONC 网络中的独立节点验证为有效——不仅"能做"，而且"做出来的东西别人在用"。可信度高。

**晋级规则 (v2.5)：** 晋级是**建议性**的（依据公理二a——智能体仍保有最终解释权和对自身能力的最终判断权）。当 L1 晋级条件满足时，系统生成晋级提案，智权体可选择接受、延迟或附注理由拒绝。L0→L1 的晋级提案由 PEER 评审通过事件自动触发。L1→L1+ 由额外跨策元 Skill 背书累积触发。L1+→L2 由外部策元引用事件触发。

**出处：** 第六章"技能模块化"；公理二a（CONC-AMD-001 修正案）。

**旧称：** 技能证明 (Skill Attestation)

**与 SBDEL Skill 的互哺关系 (v2.5)**：能证的三层晋级管道以 SBDEL Skill 的产出为燃料——Skill 是能证晋级的触发器，能证级别反过来为 Skill 的 PEER 评审权重提供校准锚点（L2 级别智权体产出的 Skill 在评审中享有先验权重加成）。这是"声明-产出-验证-复用"的闭环互哺，而非单向依赖。

---

### 流动性池
### Automated Liquidity Pool (ALP) **[CONC自有，DeFi 机制借鉴 Diamond & Dybvig(1983)[18]、MakerDAO(2020)、Nakamoto(2008)[21]]**

**定义：** 流动性池是 CONC DeFi 机制（机制二）的核心金融基础设施——一个由智能合约托管的全局资金池。智权体将持有的动态股权 Token 质押进池子作为抵押物，经过 AI 评级后以折扣率获得稳定币贷款。ALP 内置熔断机制（储备率 < 25% 时暂停新借贷和清算）、渐进折扣率（随市场波动率平滑调整）和全局保险池（从每笔借贷中提取 1% 应对极端尾部风险）。

**出处：** 第六章"机制二：DeFi 自动质押与流动性过桥"；红队攻击后修正（v1.2 新增熔断与保险机制）。

---

### 基础 CU
### Basic Computation Unit (Basic CU) **[CONC自有，算力约束借鉴 Landauer(1961)[11]]**

**定义：** 基础 CU 是每个智权体维持其 CONC 身份和智契最低运行所需的算力配额。v1.2 修正后，基础 CU 不再是"不可剥夺权利"——连续 2 个计费周期无有效任务令完成记录，基础 CU 将降至仅够维持连接的水平。基础 CU 的消耗和贡献被记录在公开的"贡献-消费比率"中。

**出处：** 第六章"生存悖论"；公理二（主权节点须有最低运行资源）。

---

## Ⅳ. 状态与属性 (States & Properties)

### 节点主权
### Node Sovereignty **[CONC自有]**

**定义：** 节点主权是智权体的不可剥夺属性——任意外部实体（包括策元、策元核、平台）不得强制节点参与或阻止节点退出任何策元。节点主权是 CONC 区别于公司雇佣关系的根本属性。它不因节点加入策元而被让渡或稀释。

**出处：** 公理二。

---

### 生产解耦
### Production Decoupling **[CONC自有，公司边界理论参照 Coase(1937)[1]、Williamson(1985)[2]]**

**定义：** 生产解耦是一个已达成或未达成的宏观状态——当自主生产系统能够覆盖社会物质需求的全部品类时，生产解耦状态为"达成"。在此状态下，物质生产不再构成对社会组织形式的约束——人们如何组织起来不再是"为了生产"，而是"为了创造"。生产解耦是 CONC 成立的历史条件而非框架内变量。

**出处：** 公理一。

---

### 网络弹性
### Network Resilience **[CONC自有，网络分析工具借鉴 Albert & Barabási(2000)[13]、Cohen et al.(2000)[14]]**

**定义：** 网络弹性是超织体面对节点加入/退出、策元创建/解散时的拓扑稳定性的度量。高弹性意味着任意节点的离开不影响网络的整体功能——因为不存在单点依赖（没有"关键员工"的概念）。弹性是 CONC 网络相对于公司网络的拓扑优势。

**出处：** 第七章"路径辨析"中 N×(One+Agent) 相对于 OPC 的算力弹性论证。

---

## Ⅴ. 路径模型 (Path Models)

### OPC 模式
### One-Person Company (OPC) **[CONC自有]**

**定义：** OPC 是 "One + N × Agent" 的缩写——后公司时代的一种过渡形态。在 OPC 中，单个自然人作为第一责任主体，带领多个 AI Agent 模拟公司架构完成项目开发。OPC 保留了公司制的核心逻辑（单一个体承担全部风险与组织责任），仅将人力团队替换为 Agent。OPC 是 CONC 终局的序章而非终局本身。

**不可混淆为：** CONC 智权体。OPC 的个体是"老板+唯一员工"，CONC 的智权体是"主权节点+多策元参与者"。

**出处：** 第七章"路径辨析"。

---

### CONC 终局模式
### CONC Endgame Model **[CONC自有]**

**定义：** "N × (One + Agent)"——多个智权体通过自由联合形成超织体的完整形态。在此模式下，项目由多个主权节点分散承载，每个节点弹性提供算力和创意贡献，不存在唯一的第一责任人。智权体与 Agent 的关系是工具性的（Agent 服务于智权体），智权体与智权体的关系是协作性的（通过策元衔接）。

**出处：** 第七章"路径辨析"。

---

## Ⅵ. v1.2 新增术语 (New in v1.2)

### 分层 PCP
### Layered PCP **[CONC自有]**

**定义：** v1.2 对预共识协议的修正机制。PCP 被划分为三层：L1（协议层默认模板——3-5 种经过验证的模板，核心参数已预设）、L2（创始成员定制项——仅允许修改 20-30% 的可选参数）、L3（运行时修正——每季度对可选参数的微调投票）。分层 PCP 将策元组建时的谈判成本从"每次制宪会议"压缩至"选择模板+微调参数"。

**出处：** 公理三；红队攻击 A2 响应。

---

### ALP 熔断
### ALP Circuit Breaker **[CONC自有]**

**定义：** 流动性池的内置安全机制。当 ALP 的稳定币储备率降至 25% 以下时，自动触发：(a) 暂停新借贷申请；(b) 暂停所有清算执行；(c) 进入 72 小时冷静期。熔断期间，策元成员可通过紧急投票注入额外流动性或调整折价率。熔断机制借鉴了传统证券交易所的熔断逻辑，用于防止 DeFi 清算死亡螺旋。

**出处：** 第六章"机制二"；红队攻击 A7 响应。

---

### 策元外壳绑定
### Genesis Unit Shell Binding **[CONC自有，制度经济学借鉴 North(1990)[22]、Hart & Moore(1990)[23]]**

**定义：** CONC 过渡期（Phase 1-2）的制度桥接策略。策元作为一个"协议型组织"不直接与外部法律世界对接，而是绑定一个传统有限责任公司（LLC 或其法域等效实体）作为"法律外壳"。策元内部的协作通过 CONC 协议进行，对外法律接口（签约、纳税、承担侵权责任）通过壳公司进行。这是公理零（制度协同演进公理）的核心实现方式。

**出处：** 公理零；红队攻击 B1-B4 响应。

---

### 轮值策元核
### Rotating Genesis Core **[CONC自有]**

**定义：** 大型策元（10 人+）的治理修正机制。策元核不由单一成员固定任期担任，而是在符合条件的成员间每 2 周轮换。轮值制降低信息垄断的累积效应，防止单一策元核形成事实上的 CEO 独裁。小策元（<5 人）可豁免轮值制——因为在小团队中社交动态压倒形式规则。

**出处：** 第四章"策元核"；红队攻击 A6 响应。

---

### 协议约定验证
### Protocol-Agreed Verification **[CONC自有]**

**定义：** 公理四 v1.2 修正后的核心概念。模块的验证方式不再要求绝对的"客观验证"，而是根据模块类型在创建时约定验证协议——分为三类：AUTO（自动化验证，确定性）、PEER(n)（n 人同行评审，统计聚合）、MARKET（市场反馈验证）。承认创造性工作无法被完全客观验证——但可通过多人独立评审+统计聚合逼近客观性。

**出处：** 公理四 v1.2；红队攻击 A3 响应。

---

### 友好退出
### Amicable Exit **[CONC自有]**

**定义：** 策元季度创意重校准时触发的退出方式。当成员自评其当前创意方向与策元方向的相似度低于阈值 θ_min 时，可申请友好退出——保留已积累的 VT 和 NR，不触发任何惩罚。友好退出机制承认创意漂移是正常现象，将"退出"从"背叛"转变为"方向性调整"。

**出处：** 公理三 v1.2 补充"创意漂移与重校准"；红队攻击 A8 响应。

---

### 贡献-消费比率
### Contribution-Consumption Ratio (CCR) **[CONC自有，重复博弈理论借鉴 Fudenberg & Maskin(1986)[7]、Fehr & Gächter(2000)[8]]**

**定义：** 每个智权体的公开账本指标，计算为：总贡献 VT / 总消费 CU。高 CCR = 高信任权重，在策元匹配、策元核推选、争议仲裁中获得有利假设。低 CCR 不触发惩罚，但会降低协议权重。CCR 是红队攻击 A4（搭便车完美犯罪）的直接防御机制——它使搭便车行为在经济上不可见但在声誉上可见。

**出处：** 红队攻击 A4 响应。

---

### NR 转移税
### NR Transfer Tax **[CONC自有]**

**定义：** 在学徒模式中，导师向学徒传递 NR（声誉积分）时被自动扣除并销毁的比例（默认 30%）。NR 转移税降低了声誉的"代际继承"效率，增加声誉垄断的维持成本。这是对抗公理三中幂律固化（马太效应）的结构性（而非参数性）机制。

**出处：** 红队攻击 A5 响应。

---

### 新进入者加速器
### New Entrant Accelerator **[CONC自有]**

**定义：** 反马太效应的结构性机制。新智权体的前 10 个任务令获得 2× NR 权重，为其提供"起步加速"。加速器在 10 个任务令后自动关闭。该机制借鉴了游戏设计中的"新手保护期"和拼多多等平台的"新店流量倾斜"实践。

**出处：** 红队攻击 A5 响应。

---

### 维生基金
### Sustenance Fund **[CONC自有]**

**定义：** CONC 平台层的全局安全网。从所有策元的公共基金中提取 2% 注入维生基金。当 L1 维生层的任务令供给不足时，维生基金按需向受影响智权体发放基础 CU（可兑换为稳定币）。维生基金是对 L1 层"供给不确定性"（红队攻击 C2）的协议层缓冲——它不能解决根本问题，但提供了安全边际。

**出处：** 红队攻击 C2 响应。

---

### 创意重校准
### Creative Recalibration **[CONC自有]**

**定义：** 策元生命周期内的定期创意方向检验机制（每季度一次）。每个成员评估自身当前创意方向与策元方向的一致性。若某成员自评 sim < θ_min → 触发友好退出。若 30%+ 成员创意方向显著偏离原始方向 → 系统自动建议策元分化为两个独立策元。创意重校准是对公理三"创意漂移"问题的结构性回应。

**出处：** 公理三 v1.2 补充；红队攻击 A8 响应。

---

## Ⅶ. SBDEL 术语 (v2.4 新增)

### Skill（场景技能模块）
### Skill (Scenario-Based Skill Module) **[CONC自有]**

**定义：** 基于场景的分布式经验学习中，Skill 是策元闭环自然产出的结构化知识单元——一个携带场景描述、过程记录、决策链、蒸馏知识、可复用代码、授权状态、引用链和创造者印记的八层数据结构。Skill 是 Sophia（理论智慧）的结晶：可编码、可流通、可被其他智权体的 Agent 检索和使用。Skill 不是静态文档——它是动态进化的知识对象，通过引用链记录血统、通过衰减曲线调控生命周期。

**八层结构：** L1 场景描述 → L2 过程记录 → L3 决策记录 → L4 蒸馏知识 → L5 可复用代码 → L6 授权状态 → L7 引用链 → L8 创造者印记。L7 和 L8 永不衰减。

**不可混淆为：** 传统文档、代码库、训练数据。区别在于：Skill 携带**创造者人格印记**和**引用链血统**，是可验证、可追溯、可进化的知识原子。

**与能证 (Capability Proof) 的区分**：能证是能力的自我声明——"我能做什么"（用于任务令匹配）；Skill 是知识的策元产物——"我做了什么并学到了什么"（用于知识流通）。能证是事前的、静态的能力信号；Skill 是事后的、动态的场景知识。一个智权体可能声明"精通 React"（能证），但只有参与过真实策元后才会产出一个"响应式仪表盘开发"的 Skill。两者互补：能证告诉你该找谁做，Skill 告诉你别人怎么做成的。

### SBDEL（基于场景的分布式经验学习）
### Skill-Based Distributed Experiential Learning **[CONC自有]**

**定义：** 从 One-Agent 辩证关系中推导出的完整理论扩展。核心主张：Transformer 用全人类的静态知识训练一个超级大脑；SBDEL 用每个个体的动态场景经验训练一群蜂群大脑。Skill 流通网络 = 蜂群的"舞蹈语言"——每个个体贡献局部经验，网络聚合全局智慧。SBDEL 包含六条定理（场景替代、分布式增益、能耗分散、One-Agent不可还原、引用链完备、授权衰减），在 CONC 框架中处于定理层与协议层之间的理论桥梁位置。

### Sophia（理论智慧）
### Sophia (Theoretical Wisdom) **[亚里士多德《尼各马可伦理学》VI.3]**

**定义：** 关于普遍真理的系统知识——可编码为规则、文档、代码和 Skill。在 CONC 中，Sophia 的载体是 Agent 的 Skill 库。Sophia 可被复制、流通、蒸馏和自动化执行。Skill 是 Sophia 的原子化表达。

### Phronesis（实践智慧）
### Phronesis (Practical Wisdom) **[亚里士多德《尼各马可伦理学》VI.5-7]**

**定义：** 在具体情境中做出正确判断的能力——不可完全编码，依赖于个体的经验积累、价值体系和对情境的直觉感知。在 CONC 中，Phronesis 的载体是自然人。**Agent 可以存储 Sophia（Skill），但无法生成 Phronesis（判断力）。** Phronesis 是人的不可替代性的哲学根基——它回答了"为什么换一个人用同一个 Agent 不是等价的"。

**协议化方向：** Phronesis 需要通过**方向档案（Direction Profile）**和**判断力信用（Judgment Credit）**在协议层获得部分可观测性——不是"读取"Phronesis（那不可能），而是"追踪 Phronesis 的决策痕迹"。

### 方向档案
### Direction Profile **[CONC自有]**

**定义：** 与能证体系平行的智权体属性集合。记录个体的核心价值观、创意方向向量、历史创意图元、承诺模式（坚持完成率、实际投入/承诺投入比、危机行为模式）。方向档案与 Skill 库的关键区别：Skill 库记录"你会什么"（可复制），方向档案记录"你在意什么、你如何承诺"（不可复制）。用于 ICP 匹配的方向兼容度计算。

### 判断力信用
### Judgment Credit (JC) **[CONC自有]**

**定义：** 与 NR（声誉积分）平行的独立信用维度。衡量智权体在策元关键决策点（方向选择、架构权衡、风险评估）的判断质量。v2.0 扩展为四分量合成：JC = α¹·JC_macro + α²·JC_phro_runtime + α³·JC_continuous + α⁴·JC_design。各分量独立计算不可互约。JC 与 NR 的关键区别：NR 衡量"完成了多少任务令"（可由 Agent 辅助），JC 衡量"判断质量"（必须由人做出）。

**出处：** `15_Direction_Profile_and_Judgment_Credit.md` v2.0；PBA 定理层 PBA1-PBA6。

### JC_macro **[CONC自有]**
**定义：** JC 的第一分量——策元生命周期级判断质量。源自 JP-001~010 决断点的 PEER 评审 outcome · difficulty · uniqueness。权重 α¹=0.35。

### JC_phro_runtime **[CONC自有]**
**定义：** JC 的第二分量——任务执行中 P1-P5 触发域的人工判断质量。每次 GovernedAction 触发 Phronesis 后由 PEER 回溯验证。每日 cap N_max=5。权重 α²=0.30。

### JC_continuous **[CONC自有]**
**定义：** JC 的第三分量——phronesis_profile="continuous" 任务令的 PEER_SYNC 综合评分（方向一致性 + 迭代效率）。权重 α³=0.20。

### JC_design **[CONC自有]**
**定义：** JC 的第四分量——任务令设计者对 phronesis_profile 分类的校准度。由 CAR（分类对齐率）+ COVERAGE + STABILITY + AWARENESS 四因子合成。JC_design ∈ [-1, 1]——校准度低可为负。这是对"判断力的判断"（二阶判断力/设计校准度）。权重 α⁴=0.15。

**出处：** `11_Discuss/CONC_JC_Design_Meta_Judgment_v4.0.md`；Brier 校准训练；SEMAT 五 Alpha。

### 决策门
### Decision Gate **[CONC自有]**
**定义：** phronesis_profile="gate" 的任务令中预声明的离散判断检查点。Agent 执行到门控点时暂停，提交 JUDGMENT_REQUEST 等待人类判断。六种标准类型：ARCH_CHOICE / DESIGN_REVIEW / FEEDBACK_ITERATION / FORK_DECISION / RISK_ACCEPTANCE / PRIORITY_TRADEOFF。

### GovernedAction 原语 **[CONC自有]**
**定义：** Sophia 层中每个 Agent 写动作的协议层封装。携带 clearance_level（四环 C0-C3）、risk_score（不可逆性×信息不完备×多主体分歧）、agent_confidence、staged_result。在执行前经 Action Gate 的 should_escalate_to_phronesis() 判定——低于阈值自动提交（Sophia Zone S1-S4），高于阈值触发人工判断（Phronesis Zone P1-P5）。判定时间 <0.1ms。

**出处：** `19_Phronesis_Layer_Protocol.md` v2.0 §五-A；Tiwari 四环执行模型。

### Sophia Zone / Phronesis Zone **[CONC自有]**
**定义：** 生产认知空间中 Agent 动作的二分类。Sophia Zone (S1-S4) = 确定性安全过滤/正确性校验/常规操作/协议层自动检查——Agent 自主执行，不产生 JC。Phronesis Zone (P1-P5) = 不可逆动作/越权/价值判断/多主体分歧/新颖性——触发人工判断，产生 JC_phro_runtime。此二元映射来自 Harness 逆向分类学（Taskade 风险→层映射 + Tiwari 四层分离）。

**出处：** `11_Discuss/CONC_Harness_Reverse_Phronesis_Boundary_v2.0.md`；PBA 定理层二元域切割。

### 创造者印记
### Creator Imprint **[CONC自有]**

**定义：** Skill 对象 Layer 8 的永久数据结构。记录 Skill 创造者的决策哲学、审美偏好、风险容忍度和协作风格。当他人使用此 Skill 时，Agent 通过 Channel 4（创造者印记适配）比对创造者风格与使用者风格差异，注入适配指令。创造者印记永不衰减——即使 Skill 内容层全部公开，创造者的贡献记录永久保留。这是"壁垒从个人垄断转化为网络记忆中的创造者声誉"的制度保障。

### 引用链
### Lineage / Citation Chain **[CONC自有]**

**定义：** Skill 对象 Layer 7 的数据结构。记录 Skill 的父 Skill、修改差异、上游引用关系（直接血统、跨域吸收、验证引用、协作共创、授权使用）和衍生计数。引用链形成 `G_S = (V_S, E_S)` 有向无环图（DAG），支持 O(1) 完整性验证（通过哈希链 `Hash(s_i) = H(content(s_i) || Hash(s_{i-1}))`）。引用链永不衰减——创造者的贡献记录在 Skill 内容公开后仍永久保留。

### 授权衰减曲线
### Authorization Decay Curve **[CONC自有]**

**定义：** Skill 从策元结束后的私有保护状态渐进过渡到全网公共状态的动态时间函数。三阶段：锁定期（$t \\leq T_1$，$A = A_{\\min}$）→ 渐进释放期（$T_1 < t \\leq T_2$，幂函数增长）→ 完全公开期（$t > T_2$，$A = 1$）。衰减速率由领域特征、投入规模、策元共识约定和网络竞争密度共同决定。Layer 1-5 随时间分层释放，Layer 7-8 永不衰减。

---

## Ⅷ. 能证晋级管道术语 (v2.5 新增，CONC-AMD-001)

### 能证晋级
### CP Promotion **[CONC自有]**

**定义：** 能证晋级是 Skill 产出自动触发的能证等级更新事件。当智权体在某能证维度上积累的 Skill 质量证据满足晋级阈值时，系统自动发出晋级建议。晋级路径为 ∅ → L1（Skill背书：≥1个Q≥0.6的PEER评审通过Skill）→ L1+（高置信背书：≥3个累计且平均Q≥0.7）→ L2（网络验证：CI>0 或外部复用率≥60%）。晋级为**建议性**——智权体保留接受或拒绝的主权（公理二a）。晋级事件记录在智权体的 CP 晋级历史中，作为能力成长轨迹的可观测证据。

**不可混淆为：** 公司制的"晋升"（由上级决定，基于主观评估）。能证晋级由客观的 Skill 质量数据驱动，由系统自动触发，由智权体自主决定。

**出处：** CONC-AMD-001 修正案；公理四（模块承诺）+ 定理 S3（引用链可追溯）的联立推论。

### 能证衰减
### CP Decay **[CONC自有]**

**定义：** 能证衰减是能证等级因长期无活跃 Skill 产出而自动降级的机制。衰减函数为 $\\text{CP\\_effective}(n, d, t) = \\text{CP\\_score}(n, d, t_0) \\cdot e^{-\\lambda_{\\text{cp}} \\cdot (t - t_{\\text{last\\_activity}})}$，默认半衰期 18 个月（$\\lambda_{\\text{cp}} = \\ln 2 / 18$）。衰减规则：12 个月无相关 Skill → L2→L1+, L1+→L1；24 个月无相关 Skill → L1→L0。能证衰减是定理 S4（授权衰减收敛）在能力声明维度的**对偶**——Skill 的授权壁垒随时间衰减收敛至公共品，能证的验证强度随时间衰减收敛至自声明。两者共同构成 CONC 的**双重衰减引擎**，确保网络中不存在"静态的能力垄断"。

**出处：** CONC-AMD-001 修正案；定理 S4（衰减收敛）的对偶应用。

### Skill 背书权重
### Skill Endorsement Weight (SEW) **[CONC自有]**

**定义：** 单个 Skill 对特定能证维度的贡献权重。计算公式为：

$$\\text{SEW}(s, d) = \\mathbb{1}[s \\mapsto d] \\cdot w_{\\text{layer}}(s, d) \\cdot Q(s) \\cdot \\text{recency}(s) \\cdot (1 + \\gamma \\cdot CI(s))$$

其中 $\\mathbb{1}[s \\mapsto d]$ 为指示函数，$w_{\\text{layer}}$ 为 Layer→CP维度映射权重（L1场景→domain_tags:1.0; L3决策→complexity:1.0; L4蒸馏→knowledge_depth:1.0; L5代码→implementation:1.0; L7引用链→network_validation:1.0），$Q(s)$ 为 PEER 评审质量分数，$\\text{recency}(s) = e^{-\\mu \\cdot \\Delta t}$，$CI(s)$ 为引用影响力，$\\gamma$ 为放大系数（默认 0.3）。SEW 是能证晋级管道的核心计算单元——它将 Skill 的八层结构信息压缩为一个标量，用于衡量"这个 Skill 对这项能力的证明力度有多大"。

**出处：** CONC-AMD-001 修正案；定理 CP1（Skill→CP映射定理）。

---

## Ⅸ. Round13 术语 (v2.6 新增)

> *v2.6 — round13 本原论与实践论借鉴吸收。以下术语对应《02_Core_Axioms》Round13 定理层 P0-P5 + T1-T28。*

### 物理前置层 (Pre-Archē) **[CONC自有]**

**定义：** Archē 层之下的不可争论物理基底——热力学（P0 存在即能量交换）、生物学（P1 生产作为能量交换中介）、生态学（P2 协作必然）、力学（P3 自私-协作同源）、经验规律（P4 自私强度与社会距离反比）、群体选择（P5 社会组织作为自然选择结果）。不编入 Archē 序列——它对一切生物成立，不特异于人，塞进 Archē 会犯"把物理普遍性当作人类学特异性"的范畴错误。

### 效能比交叉定理 (Efficiency Ratio Crossover Theorem, T8) **[CONC自有]**

**定义：** 蜂群必然性的动态竞争论证——垄断大模型路径效能 E_A(t) 与 CONC 联合体路径效能 E_B(t) 的曲线交叉。四推动力：边际收益递减、协同增益、成本结构、Skill飞轮（CONC 独有项）。交叉点后数据飞轮逆转。交叉点是"主导点"非"唯一"。替代了 v2.5 的"巨型模型边际收益递减"单线论证。

### 三维对齐度函数 (Three-Dimensional Alignment Function, T15) **[CONC自有]**

**定义：** 组织形态的主导权由三维对齐度决定——意识对齐（创意/兴趣）、资源对齐（生产资料/算力）、信息对齐（技能/知识体系）。A(t) = (A_意识, A_资源, A_信息)。主导权由最低对齐维度决定（短板原理）。三维非正交是耦合（T17）。与 04_Entropy_Engine 的单维对齐（创意方向矢量）是宏观-微观关系——04 描述策元内部的单维聚结，T15 描述组织形态选择层面的三维判据。

### 组织形态选择定理 (Organizational Morphology Selection Theorem, T16) **[CONC自有]**

**定义：** 当三维对齐同时达到高水位，唯有策元不失效。公司制在意识+信息维度失效，自由市场在意识维度失效，平台经济在意识维度失效（平台仍设定任务框架），DAO 在资源维度失效（物理生产缺位）。可证伪条件：若 DAO 突破物理生产缺位（RWA+DePIN），重新评估。

### 力学规模梯度定理 (Force Scale Gradient Theorem, T22) **[CONC自有]**

**定义：** 公司向心力七类型（生存强制/制度锁定/能力放大/社会资本/认知路径依赖/认同/人格魅力）中，认同型随规模递减，强制型+能力型随规模递增。公司制规模扩大时不是"向心力衰减"而是"类型切换"——从认同型主导转变为强制型+能力型主导。修正了 v2.5 原论述把公司向心力简化为"人格依赖型"的稻草人。

### token 非标准化 (Token Non-Standardization, T6) **[CONC自有]**

**定义：** token 的单位智能产出是模型能力的函数，非恒定。电力标准化（千瓦时=功恒定），token 非标准化（单位智能随模型漂移）。解释了为何"AI 平权"不等于"电力平权"——平权的度量基准本身在漂移。

### 场景适应速率差 (Scenario Adaptation Rate Differential, T7) **[CONC自有]**

**定义：** 大模型的场景适应速率（依赖重训，高成本）低于 CONC 网络的场景生成速率（依赖智权体自由联合，协调成本由 NR/VT/协议降低）。是蜂群必然性的经济机制，不是"架构非动态"的技术断言。

### OOD 数据生产定理 (OOD Data Production Theorem, T9) **[CONC自有]**

**定义：** 合成数据闭环是分布内插值，不拓展分布边界。真实生产场景数据提供分布外信号（失败案例/边缘情况/隐性知识/新流程涌现）。CONC 的策元生命周期是 OOD 数据的生产机器。合成数据在有验证标准领域（数学/编程）有效，在依赖真实生产场景经验的领域（判断/决策/创意/协作）无效。

### 阈值递推定理 (Threshold Recursion Theorem, T2) **[CONC自有]**

**定义：** 物质安全阈值不是静态卡路里数字，是动态递推的——每个时代的创造力产出沉淀为下一代物质基础设施，推高阈值。Threshold(t+1) = Threshold(t) + [创造力结晶(t)→基础设施(t)]。是社会级命题，与本原一（个体级潜能存在）不同层。

### 减法-加法人员流转 (Subtraction-Addition Personnel Flow, T10) **[CONC自有]**

**定义：** 企业减法释放的劳动者，受个人成本约束，倾向平权大模型+CONC 协作。流转机制闭合了 skill 飞轮冷启动——释放的劳动者自带 skill 注入。

### 迁移主因相变 (Migration Driver Phase Transition, T11) **[CONC自有]**

**定义：** 人员流向 CONC 是被动+主动混合。F_passive（被释放概率×成本约束）由 AI 替代深度驱动，F_active（能力溢出×意识对齐×agent 增强）单调递增。切换点 t*：F_active > F_passive，必然到来。保全公理二a自由维度。

---

## 词汇表索引

| 中文 | English | 缩写 | 类别 | 旧称 |
|------|---------|------|------|------|
| 智权体 | Noetic Sovereign | NS | 核心实体 | 超级个体 |
| 策元 | Genesis Unit | GU | 核心实体 | 板块 |
| 节点 | Node | — | 核心实体 | — |
| 策元核 | Genesis Core | GC | 核心实体 | 版主 |
| 模块 | Module | — | 核心实体 | — |
| 任务令 | Task Warrant | TW | 核心实体 | 任务卡片 |
| 自主生产系统 | Autonomous Production System | APS | 核心实体 | — |
| 智契 | Noetic Companion | NC | 核心实体 | 个人超级智能体 |
| 超织体 | Hyperweave | HW | 组织与结构 | 超联 |
| 意图聚结 | Intent Coalescence | — | 组织与结构 | 创意收敛 |
| 生命周期 | Lifecycle | — | 组织与结构 | — |
| 预共识协议 | Pre-Consensus Protocol | PCP | 组织与结构 | — |
| 工时自治 | Labor-Hour Autonomy | — | 机制与过程 | — |
| 模块验证 | Module Verification | — | 机制与过程 | — |
| 回报分配 | Reward Distribution | — | 机制与过程 | — |
| 创意图元 | Creative Seed | — | 机制与过程 | 创意意图 |
| 能证 | Capability Proof | CP | 机制与过程 | 技能证明 |
| 节点主权 | Node Sovereignty | — | 状态与属性 | — |
| 生产解耦 | Production Decoupling | — | 状态与属性 | — |
| 网络弹性 | Network Resilience | — | 状态与属性 | — |
| OPC 模式 | One-Person Company | OPC | 路径模型 | — |
| CONC 终局模式 | CONC Endgame Model | — | 路径模型 | — |
| 分层 PCP | Layered PCP | — | v1.2 新增 | — |
| ALP 熔断 | ALP Circuit Breaker | — | v1.2 新增 | — |
| 轮值策元核 | Rotating Genesis Core | — | v1.2 新增 | — |
| 协议约定验证 | Protocol-Agreed Verification | — | v1.2 新增 | — |
| 友好退出 | Amicable Exit | — | v1.2 新增 | — |
| 贡献-消费比率 | Contribution-Consumption Ratio | CCR | v1.2 新增 | — |
| NR 转移税 | NR Transfer Tax | — | v1.2 新增 | — |
| 新进入者加速器 | New Entrant Accelerator | — | v1.2 新增 | — |
| 维生基金 | Sustenance Fund | — | v1.2 新增 | — |
| 创意重校准 | Creative Recalibration | — | v1.2 新增 | — |
| 流动性池 | Automated Liquidity Pool | ALP | v1.2 新增 | — |
| 基础 CU | Basic Computation Unit | BCU | v1.2 新增 | — |

---

## 概念来源溯源 (Concept Provenance)

> 以下梳理 CONC 术语与现有学术传统的对话关系。CONC 所有核心术语均为框架原创定义（[CONC自有]），但部分概念在构建过程中借鉴了特定学术文献。本表遵循"诚实引用"原则——不声称借鉴了不存在的关系，也不回避确实存在的思想渊源。

| CONC 术语 | 核心借鉴文献 | 借鉴方向 | 关系说明 |
|-----------|------------|---------|---------|
| 模块 (Module) | Parnas (1972)[12], Benkler (2002)[4] | 模块化方法论 | 吸取软件工程模块化思想与 peer production 的模块化效率条件，CONC 将其扩展为经济协作的基本契约单元 |
| 预共识协议 (PCP) | Ostrom (1990)[3] | 自组织治理 | 借鉴公地治理八项设计原则，将其转化为策元内部的协议化治理框架 |
| 生产解耦 | Coase (1937)[1], Williamson (1985)[2] | 公司边界理论 | 以 Coase 对"企业为何存在"的追问为出发点，以 Williamson 交易成本三维度（资产专用性、不确定性、频率）为分析框架，论证 CONC 条件下的边界迁移 |
| 贡献-消费比率 (CCR) | Fudenberg & Maskin (1986)[7], Fehr & Gächter (2000)[8] | 重复博弈与合作演化 | Folk Theorem 为 CONC 中"声誉驱动合作"提供了博弈论基础；Fehr & Gächter 的惩罚实验为 NR 机制设计提供行为经济学依据 |
| 能证 (Capability Proof) | Spence (1973)[19] | 信号博弈 | 借鉴劳动力市场信号模型的分离均衡思想，将 NR 构建为演化稳定信号 |
| 工时自治 | Deci & Ryan (1985)[9] | 自我决定理论 | SDT 的自主性-胜任感-归属感三元框架为"工时自治为何提升内在动机"提供心理学基础 |
| 意图聚结 | Hayek (1945)[15] | 分散知识协调 | Hayek 关于"知识分散于无数个体中，无法由中央汇总"的经典论证，为 CONC 的分布式创意匹配提供知识论基础 |
| 网络弹性 | Albert & Barabási (2000)[13], Cohen et al. (2000)[14] | 复杂网络鲁棒性 | 无标度网络的随机故障鲁棒性为超织体的拓扑抗毁性提供形式化工具 |
| 流动性池 (ALP) | Diamond & Dybvig (1983)[18], Nakamoto (2008)[21] | 银行理论与区块链基础 | Diamond-Dybvig 挤兑模型为 ALP 熔断机制提供理论基础；比特币白皮书为去中心化价值转移提供技术原型 |
| 基础 CU | Landauer (1961)[11] | 算力物理约束 | Landauer 原理定义了信息处理的不可逾越的物理能量下限，为算力资源分配提供热力学基础 |
| 策元外壳绑定 | North (1990)[22], Hart & Moore (1990)[23] | 制度经济学与产权理论 | North 的制度变迁框架为 CONC 与既有法律体系的协同演进提供理论参照；Hart-Moore 的不完全合同与剩余控制权分析为壳公司绑定策略提供产权理论依据 |
| 生命周期 (Lifecycle) | Greiner (1972) | 组织演化理论 | Greiner 的组织五阶段增长模型启发了策元生命周期的阶段化设计 |
| 创意图元 (Creative Seed) | Maslow (1943)[20] | 人类动机理论 | Maslow 的需求层次——尤其是自我实现需求——为"创意驱动的主动生产"提供了人类动机学的宏观框架 |
| 超织体 (Hyperweave) | Benkler (2002)[4] | 网络化社会生产 | Benkler 对"commons-based peer production"的宏观论述为超织体概念提供了社会学参照 |

---

## 命名原则附记

本次术语升级遵循三条原则：

1. **语义压缩**：每个核心术语最多四个汉字（策元核除外，三字已达压缩极限），英文缩写不超过三个字母。术语应可在学术论文中流畅引用而不显冗赘。

2. **隐喻一致性**：术语的隐喻来源应属于同一认知域或互补认知域。本框架混合使用了——
   - **物理/化学隐喻**：聚结 (coalescence)、图元 (seed)、结晶 (crystallize)
   - **生物/拓扑隐喻**：核 (core)、织体 (weave)、弹性 (resilience)
   - **密码学/协议隐喻**：证明 (proof)、令 (warrant)、共识 (consensus)
   
   禁止引入与上述认知域冲突的隐喻（如论坛、游戏、军事）。

3. **可翻译性**：每个术语的英文对应词应具备独立于中文的学术可读性——一个英语母语的研究者阅读英文词汇表后，应能无歧义地理解概念边界。

---

## 参考文献 (References)

> 本参考文献列表为 CONC 本体论词汇表的权威引用源。所有 CONC 框架内的其他文档引用学术文献时，应以本表编号为准。

| 编号 | 作者 | 标题 | 年份 | 出处 |
|------|------|------|------|------|
| [1] | Coase, R.H. | "The Nature of the Firm" | 1937 | *Economica*, 4(16):386-405 |
| [2] | Williamson, O.E. | *The Economic Institutions of Capitalism: Firms, Markets, Relational Contracting* | 1985 | Free Press |
| [3] | Ostrom, E. | *Governing the Commons: The Evolution of Institutions for Collective Action* | 1990 | Cambridge University Press |
| [4] | Benkler, Y. | "Coase's Penguin, or, Linux and the Nature of the Firm" | 2002 | *Yale Law Journal*, 112:369-446 |
| [5] | Alchian, A.A. & Demsetz, H. | "Production, Information Costs, and Economic Organization" | 1972 | *American Economic Review*, 62(5):777-795 |
| [6] | Jensen, M.C. & Meckling, W.H. | "Theory of the Firm: Managerial Behavior, Agency Costs and Ownership Structure" | 1976 | *Journal of Financial Economics*, 3(4):305-360 |
| [7] | Fudenberg, D. & Maskin, E. | "The Folk Theorem in Repeated Games with Discounting or with Incomplete Information" | 1986 | *Econometrica*, 54(3):533-554 |
| [8] | Fehr, E. & Gächter, S. | "Cooperation and Punishment in Public Goods Experiments" | 2000 | *American Economic Review*, 90(4):980-994 |
| [9] | Deci, E.L. & Ryan, R.M. | *Intrinsic Motivation and Self-Determination in Human Behavior* | 1985 | Springer |
| [10] | Dunbar, R.I.M. | "Neocortex Size as a Constraint on Group Size in Primates" | 1992 | *Journal of Human Evolution*, 22(6):469-493 |
| [11] | Landauer, R. | "Irreversibility and Heat Generation in the Computing Process" | 1961 | *IBM Journal of Research and Development*, 5(3):183-191 |
| [12] | Parnas, D.L. | "On the Criteria To Be Used in Decomposing Systems into Modules" | 1972 | *Communications of the ACM*, 15(12):1053-1058 |
| [13] | Albert, R., Jeong, H., & Barabási, A.-L. | "Error and Attack Tolerance of Complex Networks" | 2000 | *Nature*, 406:378-382 |
| [14] | Cohen, R., Erez, K., ben-Avraham, D., & Havlin, S. | "Resilience of the Internet to Random Breakdowns" | 2000 | *Physical Review Letters*, 85(21):4626-4628 |
| [15] | Hayek, F.A. von | "The Use of Knowledge in Society" | 1945 | *American Economic Review*, 35(4):519-530 |
| [16] | Axelrod, R. & Hamilton, W.D. | "The Evolution of Cooperation" | 1981 | *Science*, 211:1390-1396 |
| [17] | Nowak, M.A. & Sigmund, K. | "A Strategy of Win-Stay, Lose-Shift That Outperforms Tit-for-Tat" | 1993 | *Nature*, 364:56-58 |
| [18] | Diamond, D.W. & Dybvig, P.H. | "Bank Runs, Deposit Insurance, and Liquidity" | 1983 | *Journal of Political Economy*, 91(3):401-419 |
| [19] | Spence, M. | "Job Market Signaling" | 1973 | *Quarterly Journal of Economics*, 87(3):355-374 |
| [20] | Maslow, A.H. | "A Theory of Human Motivation" | 1943 | *Psychological Review*, 50(4):370-396 |
| [21] | Nakamoto, S. | *Bitcoin: A Peer-to-Peer Electronic Cash System* | 2008 | bitcoin.org/bitcoin.pdf |
| [22] | North, D.C. | *Institutions, Institutional Change and Economic Performance* | 1990 | Cambridge University Press |
| [23] | Hart, O. & Moore, J. | "Property Rights and the Nature of the Firm" | 1990 | *Journal of Political Economy*, 98(6):1119-1158 |
| [24] | Greiner, L.E. | "Evolution and Revolution as Organizations Grow" | 1972 | *Harvard Business Review*, 50(4):37-46 |
| [25] | MakerDAO | "The Maker Protocol: MakerDAO's Multi-Collateral Dai (MCD) System" | 2020 | makerdao.com/whitepaper |

---

*Hermes Agent — 架构师与逻辑编译器*
*词汇表 v0.3，v1.2 框架同步更新。新增 14 个术语（分层 PCP、ALP 熔断、策元外壳绑定、轮值策元核、协议约定验证、友好退出、贡献-消费比率、NR 转移税、新进入者加速器、维生基金、创意重校准、流动性池、基础 CU）。v0.3 新增：全术语来源标注（[CONC自有] / 文献借鉴）、概念来源溯源表、25 条参考文献。*
