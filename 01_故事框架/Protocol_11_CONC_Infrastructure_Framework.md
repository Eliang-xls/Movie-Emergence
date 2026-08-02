# CONC 策元基础设施技术框架
## Genesis Unit Infrastructure — Technical Specification v0.1

> 本文档是 CONC 理论体系的工程落地方案。它回答一个核心问题：**策元作为一个去中心化的生产组织，其文档、知识、协作和验证的完整基础设施如何设计和实现？**

---

## 〇、设计哲学

### 从企业到策元：不是推倒重来，而是升维吸收

企业经过数十年演进形成了一套成熟的资料管理体系——文档生命周期管理（DLM）、设计控制（Design Control）、产品生命周期管理（PLM）、企业内容管理（ECM）。这些体系解决了真实世界的工程问题：**如何确保信息的完整性、可追溯性、可验证性和合规性**。

CONC 不需要重新发明这些轮子。它需要做的是：

1. **吸收企业体系的结构化精髓**——文档状态机、设计输入输出门控、变更控制、审计追踪
2. **去除企业体系的层级依附**——去掉"上级审批"，替换为"协议验证+同行评审"
3. **注入 AI Agent 的能力**——Agent 不是被动的文件存储器，而是主动的知识引擎
4. **适配去中心化架构**——Git + IPFS + CRDT 替代中心化 DMS

### Agent 的定位：不是"智能文件柜"，而是"知识引擎"

比特币节点是单目的（验证交易+出块）。CONC Agent 是多目的的：

| 能力维度 | 企业员工 | 比特币节点 | CONC Agent |
|---------|---------|-----------|-----------|
| 文档管理 | 手动创建/分类/归档 | 无 | **自动创建/分类/索引/归档** |
| 知识检索 | 搜索引擎+人工筛选 | 无 | **RAG + 语义搜索 + 知识图谱** |
| 流程执行 | 按SOP手动操作 | 自动（确定性） | **自动（AI推理+协议约束）** |
| 质量验证 | 人工评审 | PoW算法 | **AUTO/PEER(n)/MARKET 协议** |
| 协作协调 | 会议+邮件+IM | 无 | **异步任务令+实时通信桥接** |
| 记忆与学习 | 个人经验 | 无（无状态） | **持久记忆+知识图谱累积** |

**关键约束：Token 成本与消耗的平衡。** Agent 的每一步 AI 推理都有成本。因此框架设计必须遵循一个原则：**能用确定性协议解决的，不用 AI 推理；能用本地缓存解决的，不调用远程模型。**

---

## 一、企业资料管理体系的精华提取

### 1.1 文档生命周期管理（DLM）

企业文档管理遵循 ISO 15489（记录管理）和 ISO 9001（质量管理体系）的核心原则。提取其精华：

**企业文档生命周期六阶段：**

```
创建 → 审批 → 发布 → 执行 → 变更 → 归档/销毁
 D1      D2      D3      D4      D5      D6
```

**CONC 适配：**

| 企业阶段 | 企业做法 | CONC 适配 | Agent 自动化程度 |
|---------|---------|----------|:---:|
| D1 创建 | 员工在 DMS 中创建文档 | Agent 自动生成模板化文档 + 智权体填充创意内容 | 🟡 半自动 |
| D2 审批 | 上级审批签字 | PEER(n) 同行评审 / AUTO 验证 | 🟢 自动 |
| D3 发布 | 文档发布至共享目录 | Git commit + push → CRDT 同步 → IPFS 锚定 | 🟢 全自动 |
| D4 执行 | 员工按文档执行 | Agent 按任务令执行 + 自动记录执行日志 | 🟢 全自动 |
| D5 变更 | 变更请求 → 审批 → 执行 | 弹性分叉（Branch）→ PEER 验证 → Merge | 🟡 半自动 |
| D6 归档 | 定期归档至冷存储 | 策元解散时自动归档至 Filecoin | 🟢 全自动 |

### 1.2 设计控制（Design Control）— FDA/ISO 13485

医疗器械行业的设计控制（FDA 21 CFR 820 / ISO 13485）是企业文档管理中最严格的范式之一。它定义了一套完整的"设计输入→设计输出→验证→确认"的门控流程（Gate Process）。

**企业设计控制的核心结构：**

```
设计输入 (Design Input)
    ↓ Gate 1: 输入评审
设计输出 (Design Output)
    ↓ Gate 2: 输出评审
设计验证 (Design Verification) — "输出是否满足输入？"
    ↓ Gate 3: 验证评审
设计确认 (Design Validation) — "产品是否满足用户需求？"
    ↓ Gate 4: 确认评审
设计转移 (Design Transfer) — 转入生产
```

**设计历史文件（DHF）** 是整个过程的完整审计追踪——每个 Gate 的评审记录、每个变更的批准文件、每个验证的测试报告，全部按时间线归档。

**CONC 适配——策元设计控制协议（CDCP）：**

```
策元设计控制流程：

创意图元 (Creative Seed)          ≈ 设计输入
    ↓ Gate 0: ICP 意图聚结验证（sim ≥ θ）
预共识协议 (PCP)                   ≈ 设计计划
    ↓ Gate 1: PCP PEER(3) 评审
任务令拆解 (Task Warrant DAG)      ≈ 设计输出规格
    ↓ Gate 2: 任务令 AUTO 验证（依赖完整性检查）
模块交付 (Module Delivery)         ≈ 设计输出
    ↓ Gate 3: PEER(n) / AUTO / MARKET 验证
集成测试 (Integration Test)        ≈ 设计验证
    ↓ Gate 4: 策元核 + 外部消费者代表确认
发布/上市 (Release)                ≈ 设计确认 + 设计转移
```

**策元历史文件（GHF）——对标 DHF：**

每个策元自动维护一个 **策元历史文件（Genesis History File, GHF）**——记录策元从创建到解散的全部决策、评审、变更和验证记录。GHF 是策元的"审计追踪"，对标企业的 DHF。

```
策元 "OpenDesign" 的 GHF 结构：

ghf/
├── 00_genesis/
│   ├── creative_seed.json          # 创意图元原始声明
│   ├── icp_match_results.json      # ICP 匹配结果
│   ├── pcp_v1.0.md                 # PCP 初始版本
│   └── pcp_peer_review.json        # PCP 评审记录
├── 01_design_inputs/
│   ├── requirements_spec.md        # 需求规格（从创意图元推导）
│   ├── user_personas.md            # 用户画像
│   └── gate1_review.json           # Gate 1 评审记录
├── 02_design_outputs/
│   ├── architecture_decisions/     # 架构决策记录 (ADR)
│   ├── task_warrant_dag.json       # 任务令依赖图
│   ├── api_specifications/         # 接口规格
│   └── gate2_review.json           # Gate 2 评审记录
├── 03_verification/
│   ├── auto_test_reports/          # AUTO 验证报告
│   ├── peer_review_reports/        # PEER 评审报告
│   ├── market_validation_data/     # MARKET 市场数据
│   └── gate3_review.json           # Gate 3 评审记录
├── 04_validation/
│   ├── user_acceptance_tests/      # 用户验收测试
│   ├── feedback_aggregation.json   # 反馈聚合
│   └── gate4_review.json           # Gate 4 评审记录
├── 05_changes/
│   ├── CR-001_*.json               # 变更请求记录
│   └── branch_merge_history.json   # 弹性分叉历史
├── 06_dissolution/
│   ├── final_audit_report.md       # 最终审计报告
│   └── archive_cid.json            # Filecoin 归档 CID
└── GHF_INDEX.json                  # 全局索引（IPFS 锚定）
```

### 1.3 产品生命周期管理（PLM）

PLM 系统（如 Siemens Teamcenter, PTC Windchill）管理产品从概念到退役的全部信息。提取其与 CONC 相关的精华：

**PLM 的 BOM（物料清单）思想 → CONC 的 MOC（模块清单）：**

| PLM 概念 | CONC 适配 | 说明 |
|---------|----------|------|
| BOM（物料清单） | MOC（Module Manifest） | 策元产出的完整模块清单——包含所有任务令、验证状态、版本号 |
| ECN（工程变更通知） | CR（Change Request） | 弹性分叉的正式记录——变更原因、影响范围、评审结果 |
| 产品配置管理 | 策元配置基线 | PCP 定义的初始配置 + 运行时修正的完整历史 |
| 供应商管理 | 外源溢出承接者管理 | Step 3 外源溢出时，外部承接者的能证和 CCR 追踪 |
| 质量门控（Quality Gate） | 协议门控（Protocol Gate） | Gate 0-4 的自动化验证 |

### 1.4 企业内容管理（ECM）

ECM 系统（如 SharePoint, OpenText）的核心能力提取：

| ECM 能力 | CONC 适配 |
|---------|----------|
| 元数据管理 | 每个文档自动附加 CONC 元数据（策元ID、任务令ID、作者NS-ID、版本、CID） |
| 全文搜索 | Agent 内嵌向量数据库（SQLite-vec / HNSWlib）实现语义搜索 |
| 访问控制 | 基于策元成员身份的加密访问——非成员无法解密策元仓库 |
| 审计追踪 | GHF 自动记录所有操作 |
| 记录保留策略 | PCP 定义保留期限；到期自动归档至 Filecoin |
| 电子签名 | 智权体的 Ed25519 私钥签名——每个 Git commit 即一次签名 |

---

## 二、AI 新技术支撑层

### 2.1 Agent 的知识引擎架构

CONC Agent 不是传统的文件管理器。它是一个具备以下 AI 能力的知识引擎：

```
┌─────────────────────────────────────────────────────────┐
│                    Agent 知识引擎                         │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │
│  │ 语义索引层   │  │ 知识图谱层   │  │ 推理执行层   │     │
│  │             │  │             │  │             │     │
│  │ 向量数据库   │  │ 实体-关系图  │  │ LLM 推理    │     │
│  │ (SQLite-vec) │  │ (Nexus/RDF) │  │ (本地/云端)  │     │
│  │             │  │             │  │             │     │
│  │ 嵌入模型    │  │ 图遍历查询   │  │ 工具调用    │     │
│  │ (本地小模型) │  │ (SPARQL-like)│  │ (Function   │     │
│  │             │  │             │  │  Calling)   │     │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘     │
│         │                │                │             │
│         └────────────────┼────────────────┘             │
│                          ▼                              │
│              ┌─────────────────────┐                    │
│              │  Agent 记忆系统      │                    │
│              │                     │                    │
│              │  短期记忆: 上下文窗口 │                    │
│              │  工作记忆: CRDT 状态  │                    │
│              │  长期记忆: 知识图谱   │                    │
│              │  情景记忆: Git 历史   │                    │
│              └─────────────────────┘                    │
└─────────────────────────────────────────────────────────┘
```

### 2.2 RAG（检索增强生成）在 CONC 中的应用

RAG 是当前 AI 知识管理的核心技术。在 CONC 中，RAG 的应用分为三层：

**Layer 1: 策元内 RAG — "这个策元做了什么？"**

```
策元 Git 仓库
    ↓ 文档分块 (chunking, 512 tokens/chunk)
    ↓ 嵌入生成 (本地小模型, 如 nomic-embed-text)
    ↓ 存入本地向量数据库 (SQLite-vec)
查询: "我们的 API 认证方案是什么？"
    ↓ 向量检索 → Top-K 相关文档块
    ↓ 注入 LLM 上下文
    ↓ 生成回答 + 引用来源文件路径
```

**Layer 2: 跨策元 RAG — "我在其他策元的经验能用在这里吗？"**

```
智权体参与的所有策元的知识库
    ↓ 统一索引（按策元ID分 namespace）
查询: "我之前在策元A做过的实时同步方案"
    ↓ 跨 namespace 检索
    ↓ 返回结果附带来源策元标记
    ↓ 智权体决定是否引用
```

**Layer 3: 全网 RAG — "CONC 网络中有没有类似的创意？"**

```
全网创意图元索引（Gossip 同步的摘要，非全文）
    ↓ 轻量级语义索引（标题+摘要的嵌入）
查询: "有没有人在做去中心化设计工具？"
    ↓ 返回相似创意图元 + 策元状态
```

### 2.3 知识图谱在 CONC 中的应用

**CONC 知识图谱的节点类型：**

```
智权体 (NS) ──[参与]──→ 策元 (GU)
策元 (GU)  ──[产出]──→ 模块 (Module)
模块 (Module) ──[验证]──→ 验证记录 (Verification)
智权体 (NS) ──[拥有]──→ 能证 (CP)
智权体 (NS) ──[发布]──→ 创意图元 (Seed)
策元 (GU)  ──[遵循]──→ PCP
任务令 (TW) ──[依赖]──→ 任务令 (TW)  ← DAG 关系
策元 (GU)  ──[分裂为]──→ 策元 (GU')  ← 分叉关系
```

**知识图谱的用途：**

| 查询场景 | 图谱查询 | 用途 |
|---------|---------|------|
| "谁做过类似项目？" | MATCH (ns)-[:参与]->(gu)-[:产出]->(m) WHERE m.domain = X | ICP 匹配增强 |
| "这个任务令的上下游是什么？" | MATCH (tw)-[:依赖*]->(deps) WHERE tw.id = X | DAG 可视化 |
| "这个策元的贡献者网络" | MATCH (ns)-[:参与]->(gu) WHERE gu.id = X | CCR 计算辅助 |
| "哪些策元分裂过？" | MATCH (gu)-[:分裂为]->(gu') | 弹性分叉追踪 |

### 2.4 Agent 自动化能力矩阵

Agent 作为"超级 AI 助手"，可以自动化执行以下企业中需要人工完成的工作：

| 企业人工操作 | Agent 自动化实现 | Token 成本控制 |
|------------|-----------------|--------------|
| 文档分类与归档 | 基于内容的自动分类（嵌入相似度）+ 元数据自动附加 | 一次性嵌入，缓存复用 |
| 会议纪要整理 | 语音转录（Whisper 本地）+ LLM 摘要 | 本地 Whisper + 云端 LLM 摘要（~2K tokens） |
| 变更影响分析 | 知识图谱遍历 + DAG 依赖分析 | 确定性算法，零 Token |
| 进度报告生成 | CRDT 状态聚合 + LLM 模板填充 | 模板化，~500 tokens |
| 设计评审摘要 | PEER 评审记录聚合 + LLM 归纳 | ~1K tokens |
| 需求追溯矩阵 | Git blame + 知识图谱遍历 | 确定性算法，零 Token |
| 风险识别 | 历史项目知识图谱模式匹配 | 本地推理，~500 tokens |
| 创意图元匹配 | 嵌入向量余弦相似度 | 确定性算法（向量运算），零 Token |

**Token 成本预算（单个智权体每天）：**

| 操作 | 预估 Token 消耗 | 模型选择 |
|------|:---:|---------|
| 创意图元语义分析 | ~500 | 本地小模型 |
| 任务令拆解辅助 | ~2000 | 本地/云端（按复杂度） |
| PEER 评审意见综合 | ~1000 | 本地小模型 |
| 会议纪要生成 | ~2000 | 云端（质量要求高） |
| 日常查询应答 | ~3000 | 本地小模型 |
| **日合计** | **~8500** | 混合策略 |

按当前成本（$0.01-0.06/千 tokens），日成本 ≈ $0.09-0.51。在蜂群时代（本地推理），边际成本趋零。

---

## 三、策元文档体系设计

### 3.1 文档分类法（Taxonomy）

借鉴企业的文档分类体系，为策元定义标准化的文档分类：

```
策元文档分类体系
│
├── Ⅰ. 治理文档 (Governance)          ← 对标：企业章程、制度文件
│   ├── PCP (预共识协议)               ← 对标：公司章程 + 劳动合同
│   ├── PCP 修正案                     ← 对标：章程修正案
│   ├── 策元核决策记录                  ← 对标：董事会决议
│   └── 争议仲裁记录                   ← 对标：法务文件
│
├── Ⅱ. 创意文档 (Creative)            ← 对标：市场调研、产品概念
│   ├── 创意图元声明 (CONC_SEED.md)    ← 对标：产品概念书
│   ├── 用户画像/市场分析              ← 对标：市场调研报告
│   ├── 需求规格                       ← 对标：PRD (产品需求文档)
│   └── 设计理念/方向声明              ← 对标：设计 brief
│
├── Ⅲ. 设计文档 (Design)              ← 对标：设计输入/输出
│   ├── 架构决策记录 (ADR)             ← 对标：技术方案评审
│   ├── 接口规格                       ← 对标：ICD (接口控制文档)
│   ├── 设计稿/原型                    ← 对标：设计交付物
│   └── 任务令规格                     ← 对标：工作分解结构 (WBS)
│
├── Ⅳ. 执行文档 (Execution)           ← 对标：项目管理文档
│   ├── 任务令状态记录                  ← 对标：任务看板
│   ├── 执行日志                       ← 对标：工作日志
│   ├── 代码/产出物                    ← 对标：源代码仓库
│   └── 集成测试报告                   ← 对标：测试报告
│
├── Ⅴ. 验证文档 (Verification)        ← 对标：质量保证文档
│   ├── AUTO 验证报告                  ← 对标：自动化测试报告
│   ├── PEER 评审报告                  ← 对标：同行评审记录
│   ├── MARKET 验证数据               ← 对标：市场测试/A-B测试
│   └── Gate 评审记录                  ← 对标：质量门控记录
│
├── Ⅵ. 变更文档 (Change)              ← 对标：变更控制文档
│   ├── 变更请求 (CR)                  ← 对标：ECN (工程变更通知)
│   ├── 变更影响分析                   ← 对标：影响评估报告
│   └── 分叉/合并记录                  ← 对标：版本分支管理
│
├── Ⅶ. 通信记录 (Communication)       ← 对标：会议纪要、邮件存档
│   ├── 异步讨论记录                   ← 对标：邮件列表存档
│   ├── 会议纪要                       ← 对标：会议纪要
│   └── 决策过程记录                   ← 对标：决策日志
│
└── Ⅷ. 知识资产 (Knowledge)           ← 对标：知识库、最佳实践
    ├── 技术知识库                     ← 对标：技术 Wiki
    ├── 经验教训                       ← 对标：Lessons Learned
    └── 可复用模块库                   ← 对标：组件库
```

### 3.2 文档状态机

每个策元文档遵循统一的状态机，对标企业的文档审批流程：

```
                    ┌──────────────────────────────────────┐
                    │           文档状态机                   │
                    │                                      │
                    │  DRAFT ──→ REVIEWING ──→ APPROVED     │
                    │    │          │            │          │
                    │    │          ↓            ↓          │
                    │    │       REJECTED    PUBLISHED      │
                    │    │          │            │          │
                    │    │          ↓            ↓          │
                    │    └────── DRAFT      SUPERSEDED      │
                    │                        (被取代)        │
                    │                          │            │
                    │                          ↓            │
                    │                       ARCHIVED        │
                    │                       (归档)          │
                    └──────────────────────────────────────┘

状态转换规则：

DRAFT → REVIEWING
  触发：智权体提交评审请求
  条件：文档通过格式校验（Agent AUTO 检查）
  动作：Agent 通知 PEER 评审者

REVIEWING → APPROVED
  触发：PEER(n) 评审通过（n/2+1 同意）
  条件：无未解决的评审意见
  动作：Agent 自动 Git tag + IPFS 锚定

REVIEWING → REJECTED
  触发：PEER(n) 评审未通过
  条件：n/2+1 评审者拒绝
  动作：Agent 退回文档 + 附评审意见

APPROVED → PUBLISHED
  触发：策元核批准发布
  条件：文档已 APPROVED
  动作：Agent 推送至策元仓库 + CRDT 同步

PUBLISHED → SUPERSEDED
  触发：新版本文档 PUBLISHED
  条件：新版本已通过完整评审流程
  动作：旧版本标记 SUPERSEDED + 新版本关联

任意状态 → ARCHIVED
  触发：策元解散 / 文档保留期到期
  条件：策元投票通过 / 自动触发
  动作：Agent 上传 IPFS + Filecoin 归档
```

### 3.3 文档元数据标准

每个策元文档必须附加标准化元数据（对标 Dublin Core + 企业自定义元数据）：

```yaml
---
# CONC 文档元数据标准 v0.1
conc_version: "0.1"
document_id: "doc_OpenDesign_042"     # 全局唯一 ID
genesis_id: "gu_x9y8z7w6"             # 所属策元
task_warrant_id: "tw_042"             # 关联任务令（可选）
document_type: "design_output"        # 文档类型（见分类法）
category: "Ⅲ.3 接口规格"              # 分类路径

# 版本控制
version: "1.2.0"                      # 语义化版本
git_commit: "a1b2c3d"                 # Git 提交哈希
ipfs_cid: "ipfs://QmXxx...abc"        # IPFS 内容地址（APPROVED 后生成）

# 作者与贡献者
author:
  noetic_id: "ns_0a1b2c3d"
  name: "Alice"
contributors:
  - noetic_id: "ns_4d5e6f7g"
    role: "reviewer"
  - noetic_id: "ns_7h8i9j0k"
    role: "co-author"

# 审批链
approval_chain:
  - stage: "draft"
    by: "ns_0a1b2c3d"
    at: "2026-05-14T10:00:00Z"
  - stage: "peer_review"
    reviewers: ["ns_4d5e6f7g", "ns_7h8i9j0k", "ns_a1b2c3d"]
    result: "approved"
    at: "2026-05-14T14:00:00Z"
  - stage: "published"
    by: "ns_0a1b2c3d"  # 策元核
    at: "2026-05-14T15:00:00Z"

# 关联
depends_on: ["doc_OpenDesign_038"]    # 前置文档
blocks: ["doc_OpenDesign_045"]        # 阻塞的后续文档
supersedes: "doc_OpenDesign_041_v1.1" # 取代的旧版本

# 保留策略
retention_policy:
  retain_until: "2031-05-14"          # 保留期限
  archive_on_dissolution: true        # 策元解散时归档

# AI 辅助索引
embedding_model: "nomic-embed-text-v1.5"
embedding_stored: true
auto_classification_confidence: 0.94
---
```

---

## 四、策元仓库架构

### 4.1 标准化仓库结构

每个策元在创建时，Agent 自动生成标准化的仓库结构。这借鉴了企业的项目模板 + Git Flow + 企业目录规范：

```
gu_x9y8z7w6.conc/                     # 策元根目录
│
├── .conc/                            # CONC 元数据目录（类似 .git）
│   ├── config                        # 策元配置
│   ├── pcp.json                      # PCP 结构化数据
│   ├── roster.json                   # 成员名册 + NR + 能证
│   ├── dag.json                      # 任务令 DAG 结构
│   ├── ghf_index.json                # GHF 全局索引
│   └── hooks/                        # Git hooks（自动化触发器）
│       ├── pre-commit                # 提交前：元数据校验
│       ├── post-commit               # 提交后：CRDT 同步 + IPFS 锚定
│       └── pre-merge                 # 合并前：PEER 验证检查
│
├── governance/                       # Ⅰ. 治理文档
│   ├── PCP.md
│   ├── amendments/
│   ├── core_decisions/
│   └── disputes/
│
├── creative/                         # Ⅱ. 创意文档
│   ├── CONC_SEED.md
│   ├── user_research/
│   ├── requirements/
│   └── vision_statements/
│
├── design/                           # Ⅲ. 设计文档
│   ├── adr/                          # Architecture Decision Records
│   │   ├── ADR-001-选择技术栈.md
│   │   └── ADR-002-认证方案.md
│   ├── interfaces/
│   ├── prototypes/
│   └── task_specifications/
│
├── execution/                        # Ⅳ. 执行文档
│   ├── tasks/
│   │   ├── TW-001/
│   │   │   ├── spec.md               # 任务令规格
│   │   │   ├── deliverables/         # 交付物
│   │   │   ├── logs/                 # 执行日志
│   │   │   └── review/               # 评审记录
│   │   └── TW-002/ ...
│   ├── src/                          # 源代码（软件策元）
│   ├── designs/                      # 设计稿（Git LFS）
│   └── builds/                       # 构建产物
│
├── verification/                     # Ⅴ. 验证文档
│   ├── auto_reports/
│   ├── peer_reviews/
│   ├── market_data/
│   └── gate_reviews/
│
├── changes/                          # Ⅵ. 变更文档
│   ├── change_requests/
│   └── branch_history/
│
├── communication/                    # Ⅶ. 通信记录
│   ├── discussions/
│   ├── meeting_notes/
│   └── decision_logs/
│
├── knowledge/                        # Ⅷ. 知识资产
│   ├── tech_wiki/
│   ├── lessons_learned/
│   └── reusable_modules/
│
├── ghf/                              # 策元历史文件（自动生成）
│   └── (见 1.2 节 GHF 结构)
│
└── README.md                         # 策元概览
```

### 4.2 Agent 自动化 Git Hooks

Agent 在策元仓库中植入 Git hooks，实现文档流程的自动化：

```bash
#!/bin/bash
# .conc/hooks/pre-commit — Agent 自动植入

# 1. 元数据校验
if ! conc validate-metadata "$FILE"; then
  echo "❌ 文档元数据格式不正确"
  exit 1
fi

# 2. 文档分类校验
if ! conc validate-taxonomy "$FILE"; then
  echo "❌ 文档放置在错误的目录中"
  exit 1
fi

# 3. 依赖完整性检查
if conc has-dependencies "$FILE"; then
  if ! conc check-dependencies-resolved "$FILE"; then
    echo "⚠️ 前置文档尚未 APPROVED"
    # 不阻断，但标记警告
  fi
fi

# 4. 自动嵌入生成
conc embed-update "$FILE"  # 更新向量数据库中的嵌入
```

```bash
#!/bin/bash
# .conc/hooks/post-commit — Agent 自动植入

# 1. CRDT 状态同步
conc crdt-sync --push  # 将文档状态变更推送到 CRDT 网络

# 2. 触发 DAG 级联检查
conc dag-cascade-check --commit "$COMMIT_SHA"

# 3. 如果是 PUBLISHED 状态，锚定到 IPFS
if conc is-published "$FILE"; then
  CID=$(conc ipfs-pin "$FILE")
  conc update-ghf --cid "$CID" --commit "$COMMIT_SHA"
fi

# 4. 知识图谱更新
conc knowledge-graph-update "$FILE"
```

---

## 五、Agent 知识引擎详细设计

### 5.1 Agent 的四层记忆系统

借鉴人类认知科学的记忆分层模型，Agent 实现四层记忆：

| 记忆层 | 人类类比 | Agent 实现 | 容量 | 持久性 |
|--------|---------|-----------|------|--------|
| **感觉记忆** | 瞬间感知 | 网络层 Gossip 消息流 | 无限（流式） | 秒级 |
| **短期记忆** | 工作记忆 | LLM 上下文窗口 | 4K-128K tokens | 会话级 |
| **工作记忆** | 当前任务状态 | CRDT 状态 + 本地 KV | MB 级 | 任务级 |
| **长期记忆** | 知识与经验 | 向量数据库 + 知识图谱 | GB 级 | 永久 |

**记忆流转机制：**

```
Gossip 消息流 (感觉记忆)
    ↓ 过滤：只保留与自身策元相关的消息
    ↓ 嵌入：生成语义向量
CRDT 状态 (工作记忆)
    ↓ 定期压缩：LLM 摘要化
    ↓ 存储：写入向量数据库
向量数据库 + 知识图谱 (长期记忆)
    ↓ 检索：RAG 查询时召回
LLM 上下文窗口 (短期记忆)
    ↓ 生成：基于检索结果生成回答
```

### 5.2 Agent 的文档智能处理流水线

当策元产生新文档时，Agent 自动执行以下处理流水线：

```
新文档提交
    │
    ▼
┌─────────────────────────────┐
│ Step 1: 格式校验             │  ← 确定性，零 Token
│ - 元数据完整性检查            │
│ - 文件格式校验               │
│ - 编码规范检查               │
└─────────────┬───────────────┘
              │
              ▼
┌─────────────────────────────┐
│ Step 2: 自动分类             │  ← 本地嵌入模型，~100 tokens
│ - 内容嵌入生成               │
│ - 与分类体系的嵌入比较        │
│ - 分类置信度评估             │
│ - 低置信度 → 人工确认        │
└─────────────┬───────────────┘
              │
              ▼
┌─────────────────────────────┐
│ Step 3: 元数据自动附加        │  ← 确定性，零 Token
│ - 文档ID 生成               │
│ - 版本号计算（语义化版本）     │
│ - 关联文档检测（DAG 依赖）    │
│ - 作者/时间戳/Git commit     │
└─────────────┬───────────────┘
              │
              ▼
┌─────────────────────────────┐
│ Step 4: 知识提取             │  ← 本地小模型，~500 tokens
│ - 关键实体识别               │
│ - 关系抽取                   │
│ - 知识图谱增量更新            │
│ - 摘要生成                   │
└─────────────┬───────────────┘
              │
              ▼
┌─────────────────────────────┐
│ Step 5: 索引更新             │  ← 确定性，零 Token
│ - 向量数据库 upsert          │
│ - 全文索引更新               │
│ - 知识图谱 commit            │
│ - Git 索引更新               │
└─────────────┬───────────────┘
              │
              ▼
┌─────────────────────────────┐
│ Step 6: 通知与同步            │  ← 确定性，零 Token
│ - CRDT 状态广播              │
│ - 相关任务令状态检查           │
│ - DAG 级联触发               │
└─────────────────────────────┘
```

### 5.3 Agent 的智能检索接口

Agent 提供多模态的智能检索能力：

```bash
# 语义搜索
$ conc search "我们的认证方案用了什么协议？"
→ 命中: design/adr/ADR-002-认证方案.md (score: 0.92)
→ 命中: design/interfaces/auth-api.md (score: 0.87)
→ 摘要: "策元采用 OAuth 2.0 + JWT 方案，详见 ADR-002"

# 知识图谱查询
$ conc graph query "谁参与了 TW-042 的评审？"
→ 评审者: ns_4d5e6f7g (Alice, NR=850)
→ 评审者: ns_7h8i9j0k (Bob, NR=720)
→ 评审者: ns_a1b2c3d (Carol, NR=910)
→ 结果: PEER(3) 通过，3/3 同意

# 跨策元查询
$ conc search --cross-genesis "实时同步方案"
→ 策元 "OpenDesign" ADR-005: CRDT 实时同步 (score: 0.89)
→ 策元 "CollabTools" TW-012: WebSocket 推送 (score: 0.76)
→ 注意: 跨策元结果仅显示摘要，需授权才能查看详情

# 时间线查询
$ conc timeline "这个策元从创建到现在经历了什么？"
→ [2026-05-01] 策元创建，初始成员 3 人
→ [2026-05-03] PCP v1.0 通过 PEER(3) 评审
→ [2026-05-07] 首批 5 个任务令发布
→ [2026-05-10] TW-001 完成 AUTO 验证
→ [2026-05-12] Gate 2 评审通过
→ [2026-05-14] 软分叉：feature-branch 创建
```

---

## 六、质量门控协议（Protocol Gates）

### 6.1 五级门控体系

借鉴 FDA 设计控制的 Gate 体系，为策元定义五级协议门控：

```
Gate 0: 聚结门 (Coalescence Gate)
─────────────────────────────────
  触发条件: ICP 匹配完成
  验证内容:
    - sim(seed_i, seed_j) ≥ θ          ← 自动计算
    - 创始成员 ≥ 2                      ← 自动检查
    - 能证覆盖度 ≥ 初始任务令需求的 70%  ← 自动检查
  验证方式: AUTO
  通过条件: 全部自动检查通过
  失败处理: 返回匹配结果，建议调整创意图元或等待更多匹配

Gate 1: 计划门 (Planning Gate)
─────────────────────────────────
  触发条件: PCP 草案完成
  验证内容:
    - PCP 包含所有必填字段              ← 自动检查
    - 回报分配公式明确                  ← 自动检查
    - 争议解决流程定义                  ← 自动检查
    - 退出机制明确                      ← 自动检查
  验证方式: PEER(3) — 创始成员互相评审
  通过条件: 3/3 同意（创始阶段要求全员一致）
  失败处理: 退回修改，附评审意见

Gate 2: 拆解门 (Decomposition Gate)
─────────────────────────────────
  触发条件: 任务令 DAG 拆解完成
  验证内容:
    - DAG 无环检测                     ← 自动检查
    - 所有叶子节点有验收标准            ← 自动检查
    - 技能需求覆盖度检查                ← 自动检查
    - 工时估算合理性检查                ← AI 辅助（本地模型）
  验证方式: AUTO + AI 辅助
  通过条件: 自动检查全通过 + AI 置信度 ≥ 0.8
  失败处理: 标记问题任务令，建议重新拆解

Gate 3: 交付门 (Delivery Gate)
─────────────────────────────────
  触发条件: 所有任务令 MERGED_RESOLVED
  验证内容:
    - 所有任务令验证通过                ← 自动检查
    - 集成测试通过                      ← AUTO/PEER
    - 文档完整性检查                    ← 自动检查
    - GHF 完整性检查                    ← 自动检查
  验证方式: PEER(3) + AUTO
  通过条件: PEER 2/3 同意 + AUTO 全通过
  失败处理: 退回未通过的任务令

Gate 4: 发布门 (Release Gate)
─────────────────────────────────
  触发条件: Gate 3 通过
  验证内容:
    - 外部消费者代表确认                ← 外部评审
    - 维护计划明确                      ← 自动检查
    - 知识产权归属确认                  ← PCP 条款检查
    - 归档计划确认                      ← 自动检查
  验证方式: PEER(策元核 + 消费者代表)
  通过条件: 策元核批准 + 消费者代表确认
  失败处理: 退回补充
```

### 6.2 Gate 自动化执行

Agent 自动执行 Gate 检查，减少人工干预：

```python
# Agent 的 Gate 检查逻辑（伪代码）

def execute_gate(gate_id, genesis_id):
    gate_config = load_gate_config(gate_id)
    results = {}
    
    for check in gate_config.checks:
        if check.type == "AUTO":
            # 确定性检查，零 Token
            results[check.id] = auto_verify(check, genesis_id)
        
        elif check.type == "AI_ASSISTED":
            # AI 辅助检查，本地小模型
            results[check.id] = ai_verify(check, genesis_id, model="local")
        
        elif check.type == "PEER":
            # 同行评审，需要人工参与
            results[check.id] = request_peer_review(
                check, 
                genesis_id,
                reviewer_count=check.n,
                timeout_hours=48
            )
        
        elif check.type == "MARKET":
            # 市场验证，需要数据收集
            results[check.id] = start_market_observation(
                check,
                genesis_id,
                observation_days=check.window_days
            )
    
    # 聚合结果
    gate_result = aggregate_results(results, gate_config.pass_criteria)
    
    # 记录到 GHF
    record_gate_result(genesis_id, gate_id, results, gate_result)
    
    # IPFS 锚定
    if gate_result.passed:
        cid = ipfs_pin(gate_result)
        update_ghf_index(genesis_id, gate_id, cid)
    
    return gate_result
```

---

## 七、变更控制协议

### 7.1 变更请求（CR）流程

借鉴企业的工程变更通知（ECN）流程：

```
变更请求生命周期：

PROPOSED → ANALYZING → APPROVED → IMPLEMENTING → VERIFIED → CLOSED
    │          │           │            │             │         │
    │          ↓           ↓            ↓             ↓         ↓
    │       REJECTED    DEFERRED     BLOCKED       FAILED    ARCHIVED
    │
    └──→ WITHDRAWN (撤回)
```

**变更请求数据结构：**

```json
{
  "cr_id": "CR-001",
  "genesis_id": "gu_x9y8z7w6",
  "proposer": "ns_0a1b2c3d",
  "title": "将认证方案从 OAuth 2.0 切换为 DID",
  "reason": "去中心化需求，OAuth 依赖中心化授权服务器",
  "impact_analysis": {
    "affected_documents": ["ADR-002", "auth-api.md", "TW-015"],
    "affected_task_warrants": ["TW-015", "TW-016"],
    "estimated_effort_hours": 24,
    "risk_level": "medium"
  },
  "review": {
    "reviewers": ["ns_4d5e6f7g", "ns_7h8i9j0k"],
    "result": "approved",
    "comments_cid": "ipfs://Qm..."
  },
  "implementation": {
    "branch": "feature/CR-001-did-auth",
    "commits": ["a1b2c3d", "e4f5g6h"],
    "merge_commit": "i7j8k9l"
  },
  "verification": {
    "type": "PEER_3",
    "result": "passed",
    "report_cid": "ipfs://Qm..."
  },
  "status": "CLOSED",
  "closed_at": "2026-05-14T18:00:00Z"
}
```

### 7.2 弹性分叉与变更的集成

你的框架中定义的弹性共识分叉（软分叉/硬分叉）与变更控制协议集成：

```
软分叉 (Branch) 流程：
  1. 少数派提出变更请求 (CR)
  2. CR 通过 Gate 评审
  3. 创建 feature-branch（Agent 算力的 ≤20%）
  4. 在 branch 上实现变更
  5. 提交合并请求 (Merge Request)
  6. PEER(n) 评审合并请求
  7. 通过 → 合并入 main；未通过 → 继续迭代或关闭

硬分叉 (Hard Fork) 流程：
  1. 根本性方向冲突无法调和
  2. 策元核发起分叉投票
  3. 投票通过 → 创建 A/B 两个子策元
  4. Agent 自动：复制 Git 仓库 → 创建两个新分支
  5. 各子策元独立运行
  6. 市场验证后，潮汐效应驱动算力流动
```

---

## 八、Token 成本优化策略

### 8.1 分级推理策略

Agent 的 AI 推理采用分级策略，平衡能力与成本：

```
推理决策树：

操作请求
    │
    ├── 是否为确定性操作？
    │   ├── 是 → 直接执行（零 Token）
    │   │       例：格式校验、DAG 环路检测、元数据附加
    │   └── 否 → 继续判断
    │
    ├── 是否可用本地小模型？
    │   ├── 是 → 调用本地模型（零边际 Token，但有算力成本）
    │   │       例：文档分类、嵌入生成、简单摘要
    │   └── 否 → 继续判断
    │
    ├── 是否可用缓存结果？
    │   ├── 是 → 返回缓存（零 Token）
    │   │       例：重复查询、已处理的文档
    │   └── 否 → 继续判断
    │
    ├── 是否为高复杂度任务？
    │   ├── 是 → 调用云端大模型（消耗 Token）
    │   │       例：复杂评审综合、长文档摘要、跨域推理
    │   └── 否 → 调用本地中模型
    │
    └── Token 预算检查
        ├── 当日剩余预算 > 0 → 执行
        └── 当日剩余预算 = 0 → 降级为本地模型/缓存/延迟执行
```

### 8.2 Token 预算管理

每个智权体的 Agent 维护一个 Token 预算：

```json
{
  "daily_budget": {
    "total_tokens": 15000,
    "allocated": {
      "document_processing": 3000,
      "search_queries": 2000,
      "peer_review_synthesis": 2000,
      "meeting_summarization": 3000,
      "task_decomposition": 3000,
      "reserve": 2000
    },
    "consumed_today": 8500,
    "remaining_today": 6500
  },
  "cost_optimization": {
    "local_model_ratio": 0.65,
    "cache_hit_ratio": 0.30,
    "cloud_model_ratio": 0.05
  }
}
```

---

## 九、技术选型建议

### 9.1 核心技术栈

| 层次 | 技术选型 | 理由 |
|------|---------|------|
| **Agent 运行时** | Rust / Go | 性能、内存安全、跨平台 |
| **P2P 网络** | libp2p | 成熟的 P2P 框架，IPFS 生态原生 |
| **本地存储** | RocksDB + SQLite | 高性能 KV + 关系查询 |
| **向量数据库** | SQLite-vec / HNSWlib | 本地运行，无外部依赖 |
| **知识图谱** | Apache Jena / Nexus (轻量级) | RDF 兼容，可嵌入 |
| **Git 集成** | libgit2 | C 库，可嵌入 Agent |
| **IPFS 客户端** | ipfs-http-client / rust-ipfs | IPFS 标准客户端 |
| **CRDT** | Automerge (Rust) | 文档级 CRDT，成熟稳定 |
| **嵌入模型** | nomic-embed-text-v1.5 (ONNX) | 本地运行，768维，性能优秀 |
| **LLM 推理** | llama.cpp / Ollama | 本地运行，支持多种模型 |
| **通信协议** | Matrix (Ruma) + libp2p-gossipsub | 异步消息 + 实时广播 |
| **Web Dashboard** | Leptos (Rust WASM) / Svelte | 本地运行，轻量级 |
| **CLI** | clap (Rust) / cobra (Go) | 成熟的 CLI 框架 |

### 9.2 Agent 的启动与引导

```
Agent 首次启动流程：

1. 生成 Ed25519 密钥对（身份层）
2. 初始化本地存储（RocksDB + SQLite）
3. 加载嵌入模型（ONNX Runtime）
4. 连接 P2P 网络（libp2p bootstrap nodes）
5. 同步网络状态（Gossip 协议）
6. 加载本地知识库（如有）
7. 启动 CLI / Dashboard 服务
8. 就绪

Agent 日常运行循环：

while true:
    1. 处理 Gossip 消息（感觉记忆）
    2. 执行待处理的自动化任务
    3. 响应用户 CLI/Dashboard 请求
    4. 执行定时任务（Token 预算重置、NR 衰减、知识图谱维护）
    5. 睡眠至下一个事件
```

---

## 十、与企业体系的完整对照表

| 企业体系概念 | CONC 适配 | 自动化程度 |
|------------|----------|:---:|
| 文档管理系统 (DMS) | 策元 Git 仓库 + 元数据标准 | 🟢 |
| 设计历史文件 (DHF) | 策元历史文件 (GHF) | 🟢 |
| 设计输入 | 创意图元 + 需求规格 | 🟡 |
| 设计输出 | 任务令交付物 + 接口规格 | 🟡 |
| 设计评审 | Gate 1-4 协议门控 | 🟡 |
| 设计验证 (Verification) | PEER(n) / AUTO 验证 | 🟢 |
| 设计确认 (Validation) | MARKET 验证 + 消费者确认 | 🟡 |
| 工程变更通知 (ECN) | 变更请求 (CR) | 🟡 |
| BOM (物料清单) | MOC (模块清单) | 🟢 |
| 质量门控 (Quality Gate) | 协议门控 (Protocol Gate) | 🟢 |
| 知识库 / Wiki | Agent 本地知识图谱 + RAG | 🟢 |
| 会议纪要 | Agent 自动转录 + 摘要 | 🟢 |
| 绩效评估 | CCR + NR 自动计算 | 🟢 |
| 审计追踪 | Git 历史 + GHF + IPFS 锚定 | 🟢 |
| 合规管理 (ISO 9001) | PCP + Gate 体系 + GHF | 🟡 |
| 项目管理 (PMO) | 策元核 + 任务令 DAG + Agent 编排 | 🟢 |
| HR / 人员管理 | 能证 (CP) + NR + 自由进出 | 🟢 |
| 财务 / 薪酬 | VT 分配 + ALP + CCR | 🟢 |

图例: 🟢 = Agent 全自动, 🟡 = 人机协作, 🔴 = 需要人工

---

## 十一、实施路线图

### Phase 0: 协议定义（当前阶段）

- [ ] CONC 协议栈规范文档化（六层 API）
- [ ] 文档元数据标准 v0.1
- [ ] Gate 体系规范 v0.1
- [ ] GHF 结构规范 v0.1

### Phase 1: Agent 最小可行实现（MVP）

- [ ] Agent 运行时骨架（Rust/Go）
- [ ] 身份层：密钥对生成 + 智权体注册
- [ ] 网络层：libp2p 基础连接 + Gossip 广播
- [ ] 存储层：本地 Git 仓库管理
- [ ] CLI：`conc init`, `conc seed publish`, `conc genesis create`
- [ ] 本地嵌入模型集成（文档分类）

### Phase 2: 策元协作

- [ ] 策元生命周期管理（创建/加入/退出/解散）
- [ ] 任务令 DAG 管理
- [ ] PEER(n) 评审流程
- [ ] CRDT 状态同步
- [ ] Gate 0-2 自动化

### Phase 3: 知识引擎

- [ ] RAG 语义搜索
- [ ] 知识图谱构建与查询
- [ ] 跨策元检索
- [ ] Agent 自动文档处理流水线
- [ ] 本地 Web Dashboard

### Phase 4: 价值层

- [ ] VT 铸造与分发
- [ ] NR 计算与更新
- [ ] CCR 追踪
- [ ] ALP 流动性池（智能合约）

### Phase 5: 生态

- [ ] IPFS/Filecoin 归档集成
- [ ] Matrix 通信桥接
- [ ] 公共意图池浏览器
- [ ] PCP 模板市场
- [ ] 策元外壳绑定（LLC 对接）

---

*本文档为 CONC 策元基础设施技术框架 v0.1。*
*融合企业 ECM/DLM/PLM/Design Control 精华 + AI Agent 能力 + 去中心化架构。*
*基于 CONC 理论框架 v2.3 五公理体系 + 协议栈设计 v1.1 + 节点架构设计。*
