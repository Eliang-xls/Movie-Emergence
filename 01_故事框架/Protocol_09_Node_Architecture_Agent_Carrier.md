# CONC 节点架构与运行载体设计
## Node Architecture — Agent as Protocol Carrier

> *"参考比特币——每个节点运行协议，共同维护网络。在 CONC 中，Agent 就是这个节点。"*

---

## 〇、核心定位：Agent = 协议载体 = CONC 节点

比特币网络中，每个节点运行 Bitcoin Core（或等效实现）——它维护区块链、验证交易、广播区块。**协议是代码，节点是运行代码的进程。**

在 CONC 中：

```
比特币:  Bitcoin Core → 运行比特币协议 → 节点
CONC:    Hermes Agent → 运行 CONC 协议栈 → 智权体节点
```

Agent 不是一个"助手"——它是 CONC 的**完整协议运行时**。它做的事情等同于 Bitcoin Core：监听网络、执行协议、维护本地状态、响应查询。

### Agent 的六项核心职责

| 职责 | 类比 Bitcoin Core | CONC Agent 实现 |
|------|:---:|------|
| 维护节点身份 | 钱包私钥 | 智权体身份 + 能证 (NR) + 技能矩阵 (CSIP) |
| 监听网络广播 | P2P 网络层 | Gossip 协议——监听创意图元、策元事件、任务令状态 |
| 执行协议逻辑 | 交易验证 | ICP 匹配 + 任务令三阶段分配 + PEER 验证 |
| 维护本地状态 | UTXO 集合 | 本地仓库（创意草稿、参与策元、任务令状态、CCR） |
| 广播事件 | 交易/区块广播 | 创意图元广播、策元创建/加入/退出、任务令状态变更 |
| 对外接口 | RPC/CLI | CLI 命令 + 本地 Web Dashboard |

---

## 一、完整工作流：从创意到策元的 Agent 执行过程

以用户描述的创意场景为例——从"我有一个想法"到"加入策元"。

### Step 1：创建创意图元（本地操作）

```
智权体在终端执行：

$ conc init "去中心化设计协作工具"
  → Agent 创建本地项目目录 ~/conc/ideas/decentralized-design-tool/
  → 生成创意草稿文件:
      ~/conc/ideas/decentralized-design-tool/
      ├── CONC_SEED.md          # 创意图元声明
      │   ├── title: "去中心化设计协作工具"
      │   ├── domain: software
      │   ├── direction_vector: [0.8, 0.3, 0.6, 0.4, 0.2]  # 5维方向向量
      │   ├── abstract: "让设计师像开发者用 Git 一样协作..."
      │   └── skill_requirements: [ui_design, figma_api, realtime_sync]
      ├── draft/                 # 初稿/原型
      └── README.md

$ conc seed publish
  → Agent 验证创意图元格式
  → 计算 5 维方向向量（基于标题+领域+摘要的自然语言处理）
  → 打包为 Creative Seed JSON → 通过 Gossip 协议广播至 CONC 网络
```

**底层协议**：ICP Phase 1 (`POST /seeds` → 身份层签名 → 网络层广播)

### Step 2：网络广播与全网接收

```
智权体 A 的 Agent 广播创意图元
    ↓ Gossip 协议（fanout=3，TTL=6 跳）
CONC 网络中所有在线节点的 Agent 接收
    ↓
每个 Agent 在本地执行 ICP 匹配
    ├── 解析接收到的创意图元
    ├── 与本地存储的所有已知创意图元计算余弦相似度
    ├── 按 sim 降序排列
    └── 更新本地"意图池"索引
```

**底层协议**：ICP Phase 2 (`GET /intent-pool` → 网络层 Gossip → 策略层 sim 计算)

### Step 3：相似度匹配结果回传

```
智权体 B、C、D 的 Agent 完成匹配后
    ↓
匹配结果（sim 分数 + 策元 ID）通过 Gossip 回传至智权体 A
    ↓
智权体 A 的 Agent 聚合所有回传结果，排序
    ↓
在终端展示：

$ conc seed status
  ┌─────────────────────────────────────────────────────────┐
  │ 创意图元: "去中心化设计协作工具"                           │
  │ 网络匹配结果 (已收到 47 个节点的响应):                      │
  │                                                         │
  │ 1. sim=0.92  策元 "OpenDesign" (已有 4 成员)  [加入]     │
  │ 2. sim=0.87  策元 "CollabTools" (已有 7 成员)  [加入]    │
  │ 3. sim=0.81  创意图元 @bob (未成策元, 1 人)    [聚结]    │
  │ 4. sim=0.74  策元 "DesignAI" (已有 12 成员)    [加入]    │
  │ ...                                                     │
  │                                                         │
  │ 未找到足够相似的已有策元 → 建议创建新策元                    │
  └─────────────────────────────────────────────────────────┘
```

### Step 4：确认加入策元

```
$ conc genesis join --id OpenDesign
  → Agent 发送 POST /genesis/{id}/join
  → 策元核（或共识成员）审核
  → 审核通过 → 智权体 A 的 NR 记录 +1 策元参与
  → 本地仓库自动关联策元仓库

$ conc genesis create "去中心化设计协作工具"
  → Agent 发送 POST /genesis/create
  → PCP 模板选择（软件产品 v1）
  → 广播策元创建事件
  → 本地仓库升级为策元仓库
```

**底层协议**：策元层 API (`POST /genesis/create`, `POST /genesis/{id}/join`)

---

## 二、客户端：CLI + 本地 Web Dashboard

CONC 不需要一个"超级 App"——但它需要两个界面：

### 2.1 CLI（命令行界面）

**定位**：开发者和早期采用者的主要交互方式。类似 Git——`git init`, `git commit`, `git push`。

```
核心 CLI 命令：

# 创意管理
conc init <标题>            # 创建创意图元
conc seed publish           # 广播创意图元至网络
conc seed status            # 查看匹配结果
conc seed list              # 列出我的所有创意图元

# 策元管理
conc genesis join <id>      # 加入已有策元
conc genesis create <标题>  # 创建新策元
conc genesis leave <id>     # 退出策元
conc genesis status         # 查看我参与的策元

# 任务令管理
conc task list              # 查看我的任务令
conc task claim <id>        # 认领任务令
conc task submit <id>       # 提交任务令成果

# 网络状态
conc network peers          # 查看连接的节点
conc network status         # 网络健康状态

# 个人状态
conc me ccr                 # 查看我的 CCR
conc me nr                  # 查看我的 NR
conc me skills              # 查看/更新技能矩阵
```

### 2.2 本地 Web Dashboard

**定位**：可视化策元看板、任务令看板、网络图谱。本地运行（`localhost:9744`），数据来自 Agent 的本地状态 + 网络同步。

```
Dashboard 核心视图：

1. 意图池浏览器
   - 网络中所有公开创意图元的可视化列表
   - 按 sim 排序，显示策元状态（已结晶/聚结中/单人）

2. 策元看板
   - 类似 GitHub Project —— 任务令的 Kanban 视图
   - 列: 待认领(激情窗口) → 执行中 → 验证中 → 已完成

3. 网络图谱
   - 智权体-策元二分图的可视化
   - 显示你的节点在网络中的位置

4. CCR 仪表板
   - 贡献-消费趋势图
   - NR 历史曲线
```

### 2.3 为什么是"本地 Dashboard"而非"云平台"

比特币没有"比特币官网"让你管理钱包——你的钱包在你本地。CONC 同理：

```
比特币:  本地钱包 (管理密钥) + 区块链浏览器 (查看网络)
CONC:    本地 Dashboard (管理策元) + 可选的公共区块浏览器
```

**核心原则**：Agent 是本地的，数据是分布式的，Dashboard 是 Agent 的本地可视化窗口——不是中心化平台。

---

## 三、策元内的协作机制

### 3.1 异步协作（主要模式）

CONC 的策元协作以**异步**为主——任务令流转、PEER 验证、CCR 追踪都是异步协议。这与开源社区的工作方式一致。

| 协作需求 | 实现方式 |
|---------|---------|
| 任务分配 | Agent 自动执行三阶段内源优先 → CLI/Dashboard 展示 |
| 进度追踪 | 任务令状态机（BROADCAST→EXECUTING→VALIDATING→MERGED_RESOLVED） |
| 代码/设计协作 | Git 仓库（本地 Agent 自动同步策元仓库） |
| 质量验证 | PEER(3) 评审——Agent 自动分配评审者 |
| 讨论/决策 | 策元内异步讨论频道（见 3.3） |

### 3.2 实时协作：策元内会议

**CONC 不强制任何特定工具——但它定义了策元内实时通信的协议接口。**

策元在 PCP 中声明其通信方式：

```json
{
  "communications": {
    "async": {
      "type": "matrix",
      "room_id": "#OpenDesign:conc-matrix.org",
      "bridge": "conc-matrix-bridge"
    },
    "sync": {
      "type": "jitsi",
      "room_pattern": "conc-meet/{genesis_id}/{session_id}",
      "recording": "ipfs"
    }
  }
}
```

**设计原则**：
- CONC 协议不重新发明通信工具——它**桥接**已有的去中心化通信协议
- Matrix（去中心化聊天）用于异步讨论
- Jitsi（WebRTC 会议）用于实时会议
- 会议记录自动存入 IPFS → 关联至策元仓库

### 3.3 策元内"网络会议"的工作流

```
$ conc meeting start "Sprint 评审"
  → Agent 创建 Jitsi 会议室
  → 广播会议通知至策元成员的 Agent
  → 会议开始 → Agent 自动录制
  → 会议结束 → Agent 上传录制至 IPFS → 关联至策元的会议记录
  → 生成的会议纪要（AI 转录+摘要）自动加入策元知识库
```

---

## 四、完整架构图

```
┌─────────────────────────────────────────────────────────┐
│                    CONC 网络 (P2P)                       │
│                                                         │
│   Gossip 广播: 创意图元 · 策元事件 · 任务令状态 · NR更新   │
└─────────────────────────────────────────────────────────┘
        │                    │                    │
        ▼                    ▼                    ▼
┌───────────────┐   ┌───────────────┐   ┌───────────────┐
│ 智权体 A       │   │ 智权体 B       │   │ 智权体 C       │
│               │   │               │   │               │
│ ┌───────────┐ │   │ ┌───────────┐ │   │ ┌───────────┐ │
│ │ Hermes    │ │   │ │ Hermes    │ │   │ │ Hermes    │ │
│ │ Agent     │ │   │ │ Agent     │ │   │ │ Agent     │ │
│ │           │ │   │ │           │ │   │ │           │ │
│ │ 协议栈:    │ │   │ │ 协议栈:    │ │   │ │ 协议栈:    │ │
│ │ · ICP     │ │   │ │ · ICP     │ │   │ │ · ICP     │ │
│ │ · PCP     │ │   │ │ · PCP     │ │   │ │ · PCP     │ │
│ │ · CTCP    │ │   │ │ · CTCP    │ │   │ │ · CTCP    │ │
│ │ · PEER(n) │ │   │ │ · PEER(n) │ │   │ │ · PEER(n) │ │
│ │ · CCR     │ │   │ │ · CCR     │ │   │ │ · CCR     │ │
│ │ · 分叉协议 │ │   │ │ · 分叉协议 │ │   │ │ · 分叉协议 │ │
│ └─────┬─────┘ │   │ └─────┬─────┘ │   │ └─────┬─────┘ │
│       │       │   │       │       │   │       │       │
│  ┌────▼────┐  │   │  ┌────▼────┐  │   │  ┌────▼────┐  │
│  │ 本地状态 │  │   │  │ 本地状态 │  │   │  │ 本地状态 │  │
│  │ · 身份   │  │   │  │ · 身份   │  │   │  │ · 身份   │  │
│  │ · 创意   │  │   │  │ · 创意   │  │   │  │ · 创意   │  │
│  │ · 策元   │  │   │  │ · 策元   │  │   │  │ · 策元   │  │
│  │ · 任务令 │  │   │  │ · 任务令 │  │   │  │ · 任务令 │  │
│  │ · CCR/NR │  │   │  │ · CCR/NR │  │   │  │ · CCR/NR │  │
│  └────┬────┘  │   │  └────┬────┘  │   │  └────┬────┘  │
│       │       │   │       │       │   │       │       │
│  ┌────▼────┐  │   │  ┌────▼────┐  │   │  ┌────▼────┐  │
│  │ CLI     │  │   │  │ CLI     │  │   │  │ CLI     │  │
│  │ Dashboard│  │   │  │ Dashboard│  │   │  │ Dashboard│  │
│  └─────────┘  │   │  └─────────┘  │   │  └─────────┘  │
│     用户       │   │     用户       │   │     用户       │
└───────────────┘   └───────────────┘   └───────────────┘
```

---

## 五、Track A / Track B 双轨架构 (v2.2 新增)

### 5.1 设计原则：协议语义与实现载体分离

CONC v2.2 采用双轨架构——同一套协议语义，两种实现载体：

```
Track A（完整 Agent）                    Track B（MCP Server + Skill）
═══════════════════                      ═══════════════════════════

┌────────────────────┐                   ┌────────────────────────────┐
│ 应用层              │                   │ 任意 Agent                  │
│ CLI + Dashboard     │                   │ (OpenClaw/Hermes/Claude/…) │
├────────────────────┤                   │                            │
│ 推理层              │                   │ Agent 自带 LLM             │
│ 本地模型 + 云端     │                   │                            │
├────────────────────┤                   ├────────────────────────────┤
│ Phronesis Layer     │                   │ CONC Skill (SKILL.md)      │
│ Collaboration Layer │    共享同一套      │ ← 行为指导：何时调用工具    │
│ Value Layer         │    协议语义层      ├────────────────────────────┤
│ Verification Layer  │◄═════════════════►│ CONC MCP Server            │
│ Genesis Layer       │                   │ ┌────────────────────────┐ │
│ Identity Layer      │                   │ │ MCP 接口层             │ │
│ Network Layer       │                   │ │ (Tools + Resources)    │ │
│                     │                   │ ├────────────────────────┤ │
│ 状态层              │                   │ │ CONC 协议引擎          │ │
│ SQLite + CRDT       │                   │ ├────────────────────────┤ │
│                     │                   │ │ 状态存储               │ │
│ 网络层              │                   │ ├────────────────────────┤ │
│ libp2p              │                   │ │ 网络层(后台)           │ │
└────────────────────┘                   │ └────────────────────────┘ │
                                         └────────────────────────────┘
```

### 5.2 关键区别

| 维度 | Track A | Track B |
|------|---------|---------|
| Agent 来源 | CONC 自研 | 任意 MCP 兼容 Agent |
| LLM | 自带（本地+云端） | Agent 自带 |
| 网络层 | libp2p 原生集成 | MCP Server 内部后台线程 |
| 状态存储 | SQLite + Automerge CRDT | SQLite（或 JSON 文件） |
| 用户界面 | CLI (`conc`) + Web Dashboard | Agent 自带 UI |
| 适用场景 | 深度用户、需要完全自主的节点 | 所有用户、零门槛接入 |
| 协议语义 | **完全相同** | **完全相同** |

### 5.3 Track 选择指南

| 条件 | 推荐 Track |
|------|:---------:|
| 快速体验 CONC | Track B |
| 日常策元参与 | Track B |
| 完全自主运行（无外部依赖） | Track A |
| 边缘计算（本地推理优先） | Track A |
| 开发/测试 CONC 协议 | Track A |
| 将 CONC 嵌入已有 Agent 工作流 | Track B |
| 需要 CRDT 实时多端同步 | Track A |
| 社区推广和生态建设 | Track B |

### 5.4 Track A 切换触发条件

MVP 阶段使用 Track B。在以下任一条件满足时切换到 Track A：
1. 并发用户 > 50：SQLite 单文件写入成为瓶颈
2. 离线协作需求：多名成员需断网状态下修改同一文档
3. 策元治理需求：需策元核轮值+挑战机制+全策元投票

---

## 六、与比特币的对照

| 维度 | 比特币 | CONC |
|------|--------|------|
| 协议载体 | Bitcoin Core | Hermes Agent |
| 网络层 | P2P 广播交易/区块 | Gossip 广播创意图元/策元事件/任务令状态 |
| 本地状态 | UTXO 集合 + 钱包 | 身份 + 创意草稿 + 策元参与 + 任务令 + CCR |
| 共识机制 | PoW + 最长链 | ICP 意图聚结 + PEER 验证 + PCP 预共识 |
| 客户端 | CLI (`bitcoin-cli`) | CLI (`conc`) + 本地 Dashboard |
| 区块浏览器 | 公共区块链浏览器 | 可选的公共意图池浏览器 |
| 创世区块 | 第一个区块 | 第一个策元（公开运行、可审查） |

---

## 六、核心陈述

> **Agent 就是 CONC 的节点。如同 Bitcoin Core 运行比特币协议，Hermes Agent 运行 CONC 协议栈。** 智权体在终端执行 `conc init` → Agent 创建本地仓库、广播创意图元；网络上所有 Agent 接收、匹配、回传结果；智权体确认加入策元。整个过程不需要中心化平台——Agent 是本地的，协议是分布式的，Dashboard 是 Agent 的可视化窗口。

> **CONC 不需要一个"超级 App"——它需要一个 CLI（开发者优先）+ 一个本地 Web Dashboard（可视化）。策元内的协作复用去中心化通信协议（Matrix + Jitsi）——CONC 不重新发明通信工具，它桥接它们。**