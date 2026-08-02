# CTCP + CSIP 正式协议规范
## CONC Task Card Protocol & CONC Skill Interface Protocol — v1.0

**文档编号**: CONC-PROTO-CTCP-CSIP-001
**状态**: Formal Specification (正式规范)
**来源**: 吸收自 Gemini Version/CONC-协议草案 RFC-001 并适配 CONC 核心术语
**分类**: 核心协议 (Core Protocol), 状态机 (State Machine), 博弈论 (Game Theory)
**依赖**: 03_Protocols/01_Protocol_Layer.md (§3 任务令生命周期, §3.4 DAG 路由)

---

## 摘要 (Abstract)

本规范定义 CONC 网络底层的两大核心数据原语：**任务令协议 (CTCP — CONC Task Card Protocol)** 与 **技能接口协议 (CSIP — CONC Skill Interface Protocol)**，并规范任务令在超织体 (Hyper-Assembly) 中的完整生命周期状态机。

CTCP 是策元内流转的最小价值载体与可执行单元——它本质上是一个自带质押、拓扑路由与验收标准的智契（Smart Contract）。CSIP 是智权体在网络中的唯一数字身份与能力履历——机器间通过 CSIP 进行任务的零信任握手。

本规范吸收 Gemini RFC-001 的设计哲学，使用 CONC 核心术语（任务令、策元、智权体、能证、超织体），并将 CTCP 生命周期状态机与现有协议层任务令生命周期 (`DRAFT → BROADCAST → ...`) 进行精确映射。

---

## 目录

1. [术语映射：Gemini RFC → CONC 核心术语](#1-术语映射)
2. [CTCP — 任务令协议 JSON Schema](#2-ctcp)
3. [CSIP — 技能接口协议 JSON Schema](#3-csip)
4. [CTCP 生命周期状态机](#4-ctcp-生命周期状态机)
5. [与协议层任务令生命周期的集成映射](#5-集成映射)
6. [博弈引擎：阶梯式燃烧与算力抢断](#6-博弈引擎)
7. [实现检查清单](#7-实现检查清单)

---

## 1. 术语映射

本规范使用 CONC 核心术语。以下为 Gemini RFC 术语到 CONC 术语的完整映射：

| Gemini RFC 术语 | CONC 核心术语 | 说明 |
|:---|:---|:---|
| 任务卡片 (Task Card) | **任务令 (Task Warrant)** | 策元内最小可分配、可验证的工作单元 |
| 板块 (Board) | **策元 (Genesis Unit / GU)** | 由创意聚合协议结晶形成的生产协作单元 |
| 超联板块 (Hyper-Assembly) | **超织体 (Hyper-Assembly)** | 多个策元通过协作边构成的网络拓扑 |
| 节点 (Node) | **智权体 (Noetic Entity / ns)** | CONC 网络中的最小身份与参与单元 |
| 声望 (Reputation) | **能证 (NR)** | 智权体的可量化声誉指标 |
| 智能合约 (Smart Contract) | **智契 (Smart Contract)** | 协议层自动执行的规则引擎 |
| 质押 (Stake) | **质押 (Stake)** | 智权体锁定能证/价值通证作为任务担保 |
| 线性衰减率 (Linear Burn Rate) | **线性燃烧率** | Slash 操作中质押物的扣除速率 |

**关键术语统一规则**：
- CTCP 中的 `Board_ID` → `genesis_id`（与协议层 API 一致）
- CTCP 中的 `Card_ID` → `task_warrant_id`（与协议层 API 一致）
- CSIP 中的 `Node_ID` → `noetic_id` / `ns_id`（与身份层 API 一致）
- CSIP 中的 `Global_Trust_Tier` → `Trust_Tier`（简化，信任层级为全局属性）

---

## 2. CTCP — 任务令协议 JSON Schema

### 2.1 设计哲学

CTCP 是 CONC 网络中流转的**最小价值载体与可执行单元**。它本质上是一个自带质押、拓扑路由与验收标准的智契。

**五层架构**：
1. **上下文层 (Context Layer)**：硬性分离人类愿景与 Agent 机器指令，支撑智权体（人+AI 共生体）的并行读取。
2. **拓扑层 (Topology Layer)**：通过 `depends_on` 构建有向无环图（DAG），摒弃中心化派单——前置任务令 `MERGED_RESOLVED` 自动触发下游进入 `BROADCAST`。
3. **匹配层 (Matching Layer)**：声明任务所需的技能与算力门槛，供 CSIP 进行零信任匹配。
4. **博弈论层 (Game Theory Layer)**：内置质押、回报与惩罚条件，使任务令成为自执行的博弈论契约。
5. **验证层 (Verification Layer)**：定义完成的定义（Definition of Done），支持自动化脚本、物理预言机与零知识里程碑三种验证模式。

### 2.2 完整 JSON Schema

```json
{
  "$schema": "https://conc-protocol.org/ctcp-schema.json",
  "$id": "conc-ctcp-v1.0",
  "title": "CONC 任务令协议 (CTCP) Schema",
  "description": "策元内流转的最小价值载体与可执行单元。自带质押、拓扑路由与验收标准。",

  "type": "object",
  "required": [
    "CTCP_Version",
    "task_warrant_id",
    "genesis_id",
    "1_Context_Layer",
    "2_Topology_Layer",
    "3_Matching_Layer",
    "4_Game_Theory_Layer",
    "5_Verification_Layer"
  ],
  "properties": {

    "CTCP_Version": {
      "type": "string",
      "enum": ["1.0"],
      "description": "CTCP 协议版本号。当前唯一有效值为 '1.0'。"
    },

    "task_warrant_id": {
      "type": "string",
      "pattern": "^tw_[a-f0-9]{8}$",
      "description": "任务令全局唯一标识符。格式: tw_ + 8位十六进制。与协议层 §3 的任务令 ID 完全一致。",
      "example": "tw_a1b2c3d4"
    },

    "genesis_id": {
      "type": "string",
      "pattern": "^gu_[a-f0-9]{8}$",
      "description": "所属策元的全局唯一标识符。任务令 MUST 属于一个已结晶的策元。",
      "example": "gu_x9y8z7w6"
    },

    "1_Context_Layer": {
      "type": "object",
      "description": "上下文层：双轨上下文设计——硬性分离人类愿景与 Agent 机器指令，支撑智权体（人+AI 共生体）的并行读取。",
      "required": ["Human_Objective", "Agent_Prompt"],
      "properties": {
        "Human_Objective": {
          "type": "string",
          "maxLength": 500,
          "description": "人类可读的任务目标描述。使用自然语言，面向策元内的人类成员。应明确表达'要达成什么'而非'如何达成'。",
          "example": "为开源儿童编程平台实现 Scratch 风格的积木式代码编辑器"
        },
        "Agent_Prompt": {
          "type": "string",
          "maxLength": 2000,
          "description": "面向 AI Agent 的机器可执行指令。可包含结构化提示词、工具调用规范、输出格式要求等。由 Human_Objective 推导生成。",
          "example": "Implement a block-based visual code editor using Blockly library. Requirements: (1) support all Scratch 3.0 blocks, (2) drag-and-drop workspace, (3) generate JavaScript code from blocks, (4) dark/light theme support."
        },
        "Data_Payload_CID": {
          "type": "string",
          "format": "uri",
          "description": "可选。任务关联数据的 IPFS CID 或内容可寻址存储地址。用于传递设计稿、数据集、API 文档等上下文数据。",
          "example": "ipfs://bafybeigdyrzt5sfp7udm7hu76uh7y26nf3efuylqabf3oclgtqy55fbzdi"
        }
      }
    },

    "2_Topology_Layer": {
      "type": "object",
      "description": "拓扑层：定义任务令在策元 DAG 中的位置。通过 depends_on 构建有向无环图，前置任务令 MERGED_RESOLVED 后自动触发下游进入 BROADCAST。blocks 字段由协议层自动维护，不可手动写入。",
      "required": ["depends_on"],
      "properties": {
        "depends_on": {
          "type": "array",
          "items": {
            "type": "string",
            "pattern": "^tw_[a-f0-9]{8}$"
          },
          "maxItems": 50,
          "description": "前序依赖任务令 ID 列表。当前任务令 MUST 在所有前序任务令达到 MERGED_RESOLVED 后才可进入 BROADCAST。所有依赖 MUST 同属一个策元。",
          "example": ["tw_00112233", "tw_44556677"]
        },
        "blocks": {
          "type": "array",
          "items": {
            "type": "string",
            "pattern": "^tw_[a-f0-9]{8}$"
          },
          "description": "【只读字段】被阻塞的后继任务令 ID 列表。由协议层根据 depends_on 逆向推导并自动维护。客户端不可直接写入。",
          "readOnly": true,
          "example": ["tw_8899aabb"]
        }
      }
    },

    "3_Matching_Layer": {
      "type": "object",
      "description": "匹配层：声明任务所需的技能门槛与算力要求。CSIP 节点通过此层进行零信任的任务匹配——匹配基于可验证的能证，而非口头履历。",
      "required": ["Required_Skills"],
      "properties": {
        "Required_Skills": {
          "type": "array",
          "minItems": 1,
          "maxItems": 20,
          "items": {
            "type": "object",
            "required": ["skill_id", "min_level"],
            "properties": {
              "skill_id": {
                "type": "string",
                "maxLength": 64,
                "description": "技能标识符。使用 CONC 统一技能命名空间 (例: solidity, react, ui_design, rust, ml_training)。",
                "example": "react"
              },
              "min_level": {
                "type": "integer",
                "minimum": 1,
                "maximum": 10,
                "description": "所需技能的最低等级 (1-10)。匹配条件: CSIP.Active_Skills[skill_id].Current_Level >= min_level。",
                "example": 4
              }
            }
          },
          "description": "执行此任务令必须满足的技能要求列表。智权体的 CSIP 必须满足所有条目才能参与匹配。"
        },
        "Compute_Requirement": {
          "type": "object",
          "description": "可选。算力需求声明。用于过滤不具备足够本地算力的智权体。",
          "properties": {
            "Local_VRAM_Min": {
              "type": "string",
              "pattern": "^\\d+(GB|TB)$",
              "description": "最小本地显存要求。格式: 数字+单位 (GB/TB)。若任务不涉及本地 GPU 推理，可省略。",
              "example": "24GB"
            },
            "Estimated_Agent_Time": {
              "type": "integer",
              "minimum": 1,
              "description": "预估 Agent 执行时间 (秒)。用于博弈论层的超时计算和算力抢断的时间窗口判定。",
              "example": 3600
            }
          }
        }
      }
    },

    "4_Game_Theory_Layer": {
      "type": "object",
      "description": "博弈论层：内置质押、回报与惩罚条件。使任务令成为自执行的博弈论契约——发起方提供回报，承接方提供质押担保，协议层自动执行奖惩。",
      "required": ["Stake_Required", "Reward", "Slash_Condition"],
      "properties": {
        "Stake_Required": {
          "type": "number",
          "minimum": 0,
          "description": "承接方需质押的能证 (NR) 数量。从承接智权体的 Reputation_Vault 扣除并锁定，任务 MERGED_RESOLVED 后退还。单位为 NR 点数。",
          "example": 500
        },
        "Reward": {
          "type": "object",
          "description": "任务完成后的回报。采用双轨激励: L1 法币稳定币 + L2 策元权益通证。",
          "required": ["L1_Fiat_Stablecoin"],
          "properties": {
            "L1_Fiat_Stablecoin": {
              "type": "number",
              "minimum": 0,
              "description": "法币稳定币报酬 (如 USDC)。以最小单位计 (如 USDC 的 6 位小数表示)。0 表示纯权益激励。"
            },
            "L2_Equity_Token": {
              "type": "number",
              "minimum": 0,
              "description": "策元权益通证 (VT) 报酬。任务 MERGED_RESOLVED 后自动铸造并分配给承接方。0 表示纯法币激励。"
            }
          }
        },
        "Slash_Condition": {
          "type": "object",
          "description": "惩罚条件。定义超时或作恶时质押物的扣除规则。",
          "required": ["Timeout_Grace_Period", "Linear_Burn_Rate"],
          "properties": {
            "Timeout_Grace_Period": {
              "type": "integer",
              "minimum": 0,
              "description": "超时宽限期 (秒)。在 Estimated_Agent_Time + Timeout_Grace_Period 内不算超时。",
              "example": 1800
            },
            "Linear_Burn_Rate": {
              "type": "number",
              "minimum": 0.0,
              "maximum": 1.0,
              "description": "线性燃烧率 (0.0-1.0)。超时后每秒燃烧质押物的比例。燃烧速率 = Linear_Burn_Rate × Stake_Required / 3600 (每小时Burn_Rate比例的质押物)。",
              "example": 0.01
            }
          }
        }
      }
    },

    "5_Verification_Layer": {
      "type": "object",
      "description": "验证层：定义'完成'的标准 (Definition of Done)。支持三种验证模式，确保去信任化的交付验收。",
      "required": ["DoD_Type"],
      "properties": {
        "DoD_Type": {
          "type": "string",
          "enum": ["Automated_Script", "Physical_Oracle", "ZK_Milestone"],
          "description": "验收类型。Automated_Script: 自动化测试脚本验证; Physical_Oracle: 需要物理世界预言机 (如传感器数据、第三方 API); ZK_Milestone: 通过零知识证明验证里程碑达成。"
        },
        "Oracle_Script_CID": {
          "type": "string",
          "format": "uri",
          "description": "可选 (DoD_Type=Automated_Script 时必填)。验证脚本的 IPFS CID。脚本返回 0 (通过) 或非 0 (失败)。",
          "example": "ipfs://bafybeihrhgiewj3z6xabc123def456ghi789jkl012mno345pqr678stu901"
        },
        "Human_Validators_Required": {
          "type": "integer",
          "minimum": 0,
          "maximum": 10,
          "description": "可选。需要的人类验证者数量 (用于 PEER 验证模式)。0 表示完全自动化验证。",
          "default": 0,
          "example": 2
        }
      }
    }
  }
}
```

### 2.3 CTCP 最小有效示例

```json
{
  "CTCP_Version": "1.0",
  "task_warrant_id": "tw_a1b2c3d4",
  "genesis_id": "gu_x9y8z7w6",
  "1_Context_Layer": {
    "Human_Objective": "为开源儿童编程平台实现积木式代码编辑器",
    "Agent_Prompt": "Implement a block-based visual code editor using Blockly. Support all Scratch 3.0 basic blocks, drag-and-drop workspace, JavaScript code generation, dark/light theme."
  },
  "2_Topology_Layer": {
    "depends_on": ["tw_00112233"]
  },
  "3_Matching_Layer": {
    "Required_Skills": [
      { "skill_id": "javascript", "min_level": 5 },
      { "skill_id": "react", "min_level": 4 }
    ],
    "Compute_Requirement": {
      "Estimated_Agent_Time": 7200
    }
  },
  "4_Game_Theory_Layer": {
    "Stake_Required": 500,
    "Reward": {
      "L1_Fiat_Stablecoin": 200000000,
      "L2_Equity_Token": 150
    },
    "Slash_Condition": {
      "Timeout_Grace_Period": 3600,
      "Linear_Burn_Rate": 0.01
    }
  },
  "5_Verification_Layer": {
    "DoD_Type": "Automated_Script",
    "Oracle_Script_CID": "ipfs://bafybeihrhgiewj3z6xabc123def456ghi789jkl012mno345pqr678stu901"
  }
}
```

---

## 3. CSIP — 技能接口协议 JSON Schema

### 3.1 设计哲学

CSIP 是智权体在 CONC 网络中的**唯一数字身份与能力履历**。机器间通过 CSIP 进行任务的零信任握手——不相信任何口头履历，只相信链上可验证的能证记录。

**三部分架构**：
1. **冷启动层 (Cold_Start_Layer)**：通过外部锚定（如 GitHub 贡献证明、学术论文、前雇主推荐信的 ZK-Proof）解决新智权体的冷启动问题——将链下信誉映射为链上基础技能等级。
2. **动态矩阵 (Dynamic_Matrix)**：运行中持续更新的技能数据——包含当前等级、累计经验、完成任务数与被惩罚记录。`Slashed_CTCPs` 是永久污点，执行冷酷的动态降级。
3. **声誉金库 (Reputation_Vault)**：智权体的可质押声誉总量、当前锁定量与全局信任层级——这是博弈论层质押操作的直接数据源。

### 3.2 完整 JSON Schema

```json
{
  "$schema": "https://conc-protocol.org/csip-schema.json",
  "$id": "conc-csip-v1.0",
  "title": "CONC 技能接口协议 (CSIP) Schema",
  "description": "智权体在 CONC 网络中的唯一数字身份与能力履历。机器间通过 CSIP 进行任务的零信任握手。",

  "type": "object",
  "required": [
    "CSIP_Version",
    "ns_id",
    "1_Cold_Start_Layer",
    "2_Dynamic_Matrix",
    "3_Reputation_Vault"
  ],
  "properties": {

    "CSIP_Version": {
      "type": "string",
      "enum": ["1.0"],
      "description": "CSIP 协议版本号。当前唯一有效值为 '1.0'。"
    },

    "ns_id": {
      "type": "string",
      "pattern": "^ns_[a-f0-9]{8}$",
      "description": "智权体全局唯一标识符。与身份层 POST /identity/register 返回的 noetic_id 一致。",
      "example": "ns_0a1b2c3d"
    },

    "Node_Type": {
      "type": "string",
      "enum": ["One_Plus_Edge_Agent", "Pure_Agent", "Human_Only"],
      "description": "智权体类型。One_Plus_Edge_Agent: 人+AI 共生体 (CONC 的标准参与形态); Pure_Agent: 纯 AI 智能体; Human_Only: 纯人类参与者。",
      "default": "One_Plus_Edge_Agent"
    },

    "1_Cold_Start_Layer": {
      "type": "object",
      "description": "冷启动层：通过外部锚定解决新智权体的冷启动问题。利用 ZK-Proof 将链下信誉映射为链上基础技能等级。新智权体至少需要一个有效的外部锚定才能参与任务匹配。",
      "required": ["External_Anchors"],
      "properties": {
        "External_Anchors": {
          "type": "array",
          "minItems": 1,
          "maxItems": 10,
          "items": {
            "type": "object",
            "required": ["Anchor_Type", "Proof_CID"],
            "properties": {
              "Anchor_Type": {
                "type": "string",
                "enum": [
                  "github_contributions",
                  "academic_publications",
                  "previous_employer_zkp",
                  "open_source_maintainer",
                  "hackathon_winner",
                  "professional_certification",
                  "peer_endorsement",
                  "l1_task_history"
                ],
                "description": "外部锚定类型。github_contributions: GitHub 贡献记录; academic_publications: 学术论文; previous_employer_zkp: 前雇主零知识推荐; open_source_maintainer: 开源项目维护者; hackathon_winner: 黑客松获奖; professional_certification: 专业认证; peer_endorsement: 同行背书; l1_task_history: L1 任务历史 (CONC 内部)。"
              },
              "Proof_CID": {
                "type": "string",
                "format": "uri",
                "description": "锚定证明的 IPFS CID。内容因 Anchor_Type 而异——GitHub 证明为签名后的贡献摘要; ZKP 为链上验证合约地址; L1 任务历史为已完成任务令 ID 列表的 Merkle 证明。",
                "example": "ipfs://bafkreihg7x5abc123def456ghi789jkl012mno345pqr678stu901vwx234"
              },
              "Mapped_Base_Skills": {
                "type": "object",
                "description": "从此外部锚定推导出的基础技能映射。键为 skill_id，值为初始等级 (1-10)。",
                "additionalProperties": {
                  "type": "integer",
                  "minimum": 1,
                  "maximum": 10
                },
                "example": {
                  "solidity": 3,
                  "javascript": 4
                }
              }
            }
          },
          "description": "外部锚定列表。至少一项有效锚定。每项将链下信誉映射为 CONC 内技能等级。"
        }
      }
    },

    "2_Dynamic_Matrix": {
      "type": "object",
      "description": "动态矩阵：运行中持续更新的技能数据。每个技能记录当前等级、累计经验、完成/被惩罚任务数，以及基于历史表现的可靠性评分。Slashed_CTCPs 为永久污点。",
      "required": ["Active_Skills"],
      "properties": {
        "Active_Skills": {
          "type": "object",
          "description": "当前活跃技能集合。键为 skill_id，值为该技能的动态数据。",
          "additionalProperties": {
            "type": "object",
            "required": ["Current_Level", "Total_EXP", "Completed_CTCPs", "Slashed_CTCPs", "Reliability_Score"],
            "properties": {
              "Current_Level": {
                "type": "integer",
                "minimum": 1,
                "maximum": 10,
                "description": "当前技能等级 (1-10)。由 Total_EXP 映射到等级表。初始值来自 Cold_Start_Layer 的外部锚定映射。",
                "example": 5
              },
              "Total_EXP": {
                "type": "number",
                "minimum": 0,
                "description": "累计经验值。完成任务令时根据任务难度和验证结果增长。",
                "example": 12500
              },
              "Completed_CTCPs": {
                "type": "integer",
                "minimum": 0,
                "description": "使用该技能成功完成的任务令数量。",
                "example": 23
              },
              "Slashed_CTCPs": {
                "type": "integer",
                "minimum": 0,
                "description": "使用该技能时被惩罚 (Slashed) 的任务令数量。永久污点——不可清除、不可衰减。高 Slashed_CTCPs 将严重降低 Reliability_Score。",
                "example": 1
              },
              "Reliability_Score": {
                "type": "number",
                "minimum": 0.0,
                "maximum": 1.0,
                "description": "可靠性评分 (0.0-1.0)。综合计算: (Completed / (Completed + Slashed + 1)) × 时间衰减因子。1.0 表示完美记录。新技能默认 0.5。",
                "example": 0.92
              }
            }
          }
        }
      }
    },

    "3_Reputation_Vault": {
      "type": "object",
      "description": "声誉金库：智权体的可质押声誉总量与当前锁定状态。这是博弈论层质押操作的直接数据源——任务令的 Stake_Required 从 Total_Stakeable 中扣除并转入 Locked_In。",
      "required": ["Total_Stakeable", "Locked_In", "Trust_Tier"],
      "properties": {
        "Total_Stakeable": {
          "type": "number",
          "minimum": 0,
          "description": "可质押声誉总量 (NR 点数)。等于智权体的当前 NR 减去已锁定部分。此值随任务完成 (增长) 和被惩罚 (减少) 动态变化。",
          "example": 8500
        },
        "Locked_In": {
          "type": "number",
          "minimum": 0,
          "description": "当前锁定在活跃任务中的质押总量。承接新任务令时增加，任务 MERGED_RESOLVED 或 DECAYING_SLASHED 后释放或扣除。",
          "example": 1500
        },
        "Trust_Tier": {
          "type": "string",
          "enum": ["T1", "T2", "T3", "T4", "T5"],
          "description": "全局信任层级。T1 (最高信任): 100+ 完成任务，零惩罚，Reliability_Score > 0.95; T5 (最低): 新进入者或近期有惩罚记录。信任层级影响: (a) 可同时承接的任务令数量上限; (b) 质押折扣率 (T1 可享受质押折扣); (c) 任务匹配优先级。",
          "example": "T2"
        }
      }
    }
  }
}
```

### 3.3 CSIP 最小有效示例

```json
{
  "CSIP_Version": "1.0",
  "ns_id": "ns_0a1b2c3d",
  "Node_Type": "One_Plus_Edge_Agent",
  "1_Cold_Start_Layer": {
    "External_Anchors": [
      {
        "Anchor_Type": "github_contributions",
        "Proof_CID": "ipfs://bafkreihg7x5abc123def456ghi789jkl012mno345pqr678stu901vwx234",
        "Mapped_Base_Skills": {
          "solidity": 3,
          "javascript": 4,
          "react": 3
        }
      },
      {
        "Anchor_Type": "l1_task_history",
        "Proof_CID": "ipfs://bafybeihrhgiewj3z6xabc123def456ghi789jkl012mno345pqr678stu901",
        "Mapped_Base_Skills": {
          "ui_design": 2
        }
      }
    ]
  },
  "2_Dynamic_Matrix": {
    "Active_Skills": {
      "solidity": {
        "Current_Level": 5,
        "Total_EXP": 8200,
        "Completed_CTCPs": 15,
        "Slashed_CTCPs": 0,
        "Reliability_Score": 0.97
      },
      "react": {
        "Current_Level": 4,
        "Total_EXP": 4300,
        "Completed_CTCPs": 8,
        "Slashed_CTCPs": 1,
        "Reliability_Score": 0.80
      }
    }
  },
  "3_Reputation_Vault": {
    "Total_Stakeable": 6200,
    "Locked_In": 500,
    "Trust_Tier": "T2"
  }
}
```

---

## 4. CTCP 生命周期状态机

### 4.1 状态定义

任何 CTCP 任务令在其生命周期中必须且只能处于以下六种状态之一。状态跃迁由密码学条件或协议层事件触发。

```
                    ┌──────────────────────────────────────┐
                    │                                      │
                    ▼                                      │
              ┌──────────┐                                 │
     ┌───────→│ BROADCAST│◄──────────────┐                 │
     │        └────┬─────┘               │                 │
     │             │ CSIP 匹配成功        │ DECAYING 结束   │
     │             │ + 质押扣除          │ (卡片回归)      │
     │             ▼                     │                 │
     │        ┌────────────┐            │                 │
     │        │STAKED_LOCKED│            │                 │
     │        └─────┬──────┘            │                 │
     │              │ 签名确认           │                 │
     │              │ + 算力上线         │                 │
     │              ▼                    │                 │
     │        ┌──────────┐             │                 │
     │        │ EXECUTING│─────────────┼──────┐          │
     │        └────┬─────┘   (超时/作恶)      │          │
     │             │ 成果提交               │          │
     │             ▼                        ▼          │
     │        ┌──────────┐          ┌───────────────┐  │
     │        │VALIDATING│          │DECAYING_SLASHED│  │
     │        └────┬─────┘          └───────┬───────┘  │
     │             │                        │          │
     │        ┌────┴────┐                   │          │
     │        ▼         ▼                   │          │
     │   ┌────────┐ ┌────────┐             │          │
     │   │ PASSED │ │ FAILED │             │          │
     │   └───┬────┘ └───┬────┘             │          │
     │       │           │                  │          │
     │       ▼           └──────────────────┘          │
     │  ┌──────────────────┐                           │
     └──│MERGED_RESOLVED   │                           │
        └──────────────────┘                           │
           (若 DAG 下游依赖已满足，                     │
            自动触发下游 BROADCAST)                     │
```

### 4.2 各状态详细说明

#### 4.2.1 `BROADCAST` — 广播态

| 属性 | 值 |
|:---|:---|
| **进入条件** | (a) 任务令首次发布 (`DRAFT → BROADCAST`) 且所有 `depends_on` 前置任务令均为 `MERGED_RESOLVED`; (b) 从 `DECAYING_SLASHED` 回归 (燃烧达到上限后重置) |
| **期间操作** | 任务令在全网中继节点广播，等待智权体通过 CSIP 匹配。匹配条件: ∀ (skill_id, min_level) ∈ Required_Skills: CSIP.Active_Skills[skill_id].Current_Level ≥ min_level。 |
| **退出条件** | 某智权体 CSIP 匹配成功并完成质押 → `STAKED_LOCKED` |
| **超时** | 无强制超时。若长时间无匹配，发起方可提高 Reward 或降低 Required_Skills 门槛。 |

#### 4.2.2 `STAKED_LOCKED` — 质押锁定态

| 属性 | 值 |
|:---|:---|
| **进入条件** | 智权体 CSIP 匹配合格 → 智契从承接方的 `Reputation_Vault.Total_Stakeable` 扣除并锁定 `Stake_Required` → `Locked_In += Stake_Required` |
| **期间操作** | 智权体完成签名确认，准备本地算力环境。此阶段为原子操作——质押扣除和状态变更在同一个事务中执行。 |
| **退出条件** | 承接方签名确认 → `EXECUTING` |
| **回滚条件** | 若承接方在宽限期内未签名确认 → 质押退还，任务令回归 `BROADCAST` |

#### 4.2.3 `EXECUTING` — 执行态

| 属性 | 值 |
|:---|:---|
| **进入条件** | 承接方完成签名确认，本地算力上线 |
| **期间操作** | 智权体在本地环境执行任务。网络不监督"进度"——仅要求周期性心跳探针 (Proof of Liveness)。心跳间隔: ≤ 300 秒。连续 3 次心跳丢失 → 触发 `DECAYING_SLASHED`。 |
| **退出条件** | 承接方提交成果 (Commit) → `VALIDATING` |
| **异常退出** | 超时 / 作恶 / 心跳丢失 → `DECAYING_SLASHED`; 被抢断 (Preemption) → 无损退出 (不计 Slashed，不退还质押——算力抢断由挑战者承担全部质押) |

#### 4.2.4 `VALIDATING` — 预言机验证态

| 属性 | 值 |
|:---|:---|
| **进入条件** | 承接方提交成果 (Commit)，包含 deliverable_hash |
| **期间操作** | 触发 `5_Verification_Layer` 的验证逻辑: (a) `Automated_Script` → 在可信执行环境中运行 `Oracle_Script_CID` 指向的测试脚本; (b) `Physical_Oracle` → 向链外预言机请求物理世界数据并比对; (c) `ZK_Milestone` → 在链上验证零知识证明。若 `Human_Validators_Required > 0` → 同时触发 PEER(n) 评审流程。 |
| **退出条件** | 验证通过 → `MERGED_RESOLVED`; 验证失败 → `DECAYING_SLASHED` |
| **超时** | 验证窗口: `max(3600, Estimated_Agent_Time × 0.1)` 秒。超时未完成验证 → 若无共识则要求重新提交或人工介入。 |

#### 4.2.5 `MERGED_RESOLVED` — 合并成功态 (终态)

| 属性 | 值 |
|:---|:---|
| **进入条件** | 验证通过 (PASSED) |
| **触发操作** | (a) 退还承接方质押 → `Locked_In -= Stake_Required`; (b) 发放 Reward (L1_Fiat_Stablecoin + L2_Equity_Token); (c) 更新承接方 CSIP: `Completed_CTCPs += 1`, `Total_EXP += exp_gain`, 重新计算 `Reliability_Score` 和 `Current_Level`; (d) **自动解锁下游 DAG**: 遍历 `blocks` 列表，检查每个后继任务令的全部 `depends_on` 是否均已满足。若满足 → 自动推入 `BROADCAST`。 |
| **终态** | 是。任务令不可再被修改。 |

#### 4.2.6 `DECAYING_SLASHED` — 衰减与销毁态

| 属性 | 值 |
|:---|:---|
| **进入条件** | (a) 执行超时 (超过 `Estimated_Agent_Time + Timeout_Grace_Period`); (b) 心跳丢失 (连续 3 次); (c) 验证失败 (FAILED); (d) 被弹劾成功 (Impeachment) |
| **触发操作** | 按照阶梯式燃烧协议扣减质押物 (详见 §6.1)。`Slashed_CTCPs += 1`（永久污点）。`Reliability_Score` 重新计算。 |
| **退出条件** | 燃烧达到上限 (≥ 50% 质押物被扣) → 剩余质押物没收，任务令回归 `BROADCAST`。承接方 `Trust_Tier` 重新评估。 |

### 4.3 状态跃迁表

| 当前状态 | 触发事件 | 目标状态 | 条件 |
|:---|:---|:---|:---|
| `DRAFT` | `POST /task-warrant/{tw_id}/publish` | `BROADCAST` | ∀ d ∈ depends_on: d.state == MERGED_RESOLVED |
| `BROADCAST` | CSIP 匹配 + 质押锁定 | `STAKED_LOCKED` | 智契原子操作: 扣除质押 |
| `STAKED_LOCKED` | 承接方签名确认 | `EXECUTING` | 签名有效 + 算力环境就绪 |
| `STAKED_LOCKED` | 签名超时 | `BROADCAST` | 超时 > 600s 未签名 |
| `EXECUTING` | 提交成果 (Commit) | `VALIDATING` | deliverable_hash 有效 |
| `EXECUTING` | 执行超时 / 心跳丢失 / 作恶 | `DECAYING_SLASHED` | 阶梯式燃烧触发 |
| `EXECUTING` | 算力抢断成功 | `VALIDATING` | 挑战者直接提交完整结果 |
| `VALIDATING` | 验证通过 | `MERGED_RESOLVED` | DoD 条件全部满足 |
| `VALIDATING` | 验证失败 | `DECAYING_SLASHED` | 测试脚本返回非零 / 预言机数据不匹配 |
| `DECAYING_SLASHED` | 燃烧达到上限 | `BROADCAST` | S_burn ≥ 0.5 × Stake_Required |

---

## 5. 集成映射

### 5.1 CTCP 与协议层任务令生命周期的对应关系

CONC 协议层 (`03_Protocols/01_Protocol_Layer.md` §3) 已定义任务令的基础生命周期 (`DRAFT → BROADCAST → ...`)。CTCP 在此基础上扩展了完整的博弈论状态。以下为精确对应：

```
协议层生命周期       CTCP 生命周期           说明
────────────────────────────────────────────────────────
DRAFT                DRAFT                   协议层定义，CTCP 继承
BROADCAST            BROADCAST               完全对应
(隐式)               STAKED_LOCKED           协议层未显式定义——CTCP 新增
(隐式)               EXECUTING               协议层描述为"进行中"——CTCP 显式化
(隐式)               VALIDATING              协议层 §4 验证层定义——CTCP 集成
MERGED_RESOLVED      MERGED_RESOLVED         完全对应
(隐式)               DECAYING_SLASHED        协议层未定义——CTCP 新增博弈论终态
```

### 5.2 DAG 路由集成

CTCP 的 `2_Topology_Layer.depends_on` 和 `2_Topology_Layer.blocks` 与协议层 §3.4 的 DAG 依赖路由完全对应：

| CTCP 字段 | 协议层字段 | 说明 |
|:---|:---|:---|
| `2_Topology_Layer.depends_on` | `depends_on` (string[]) | 完全一致 |
| `2_Topology_Layer.blocks` | `blocks` (string[], 只读) | 完全一致——由协议层自动维护 |

CTCP 的 `MERGED_RESOLVED` 状态达成时，触发协议层 §3.4 定义的级联触发规则：

```
on_state_change(X, MERGED_RESOLVED):
  for each Y in X.blocks:
    if ∀ Z ∈ Y.depends_on: Z.state == MERGED_RESOLVED:
      Y.state ← BROADCAST
      broadcast(Y)
```

### 5.3 CTCP 字段到协议层 API 的映射

| CTCP 层 | CTCP 字段 | 协议层 API 对应 |
|:---|:---|:---|
| Context | `Human_Objective` | `POST /task-warrant/create` → `title` |
| Context | `Agent_Prompt` | `POST /task-warrant/create` → `description_hash` (可扩展) |
| Topology | `depends_on` | `POST /task-warrant/create` → `depends_on` |
| Matching | `Required_Skills` | 协议层身份层 `GET /identity/{ns_id}/capabilities` |
| GameTheory | `Stake_Required` | 协议层价值层 `POST /value/alp/stake` (概念对应) |
| GameTheory | `Reward.L2_Equity_Token` | 协议层 `POST /value/vt/allocate` → `vt_amount` |
| Verification | `DoD_Type` | 协议层 `POST /verification/submit` → `verification_type` |

### 5.4 CSIP 到协议层身份层的映射

| CSIP 字段 | 协议层身份层 API 对应 |
|:---|:---|
| `ns_id` | `POST /identity/register` → `noetic_id` |
| `1_Cold_Start_Layer.External_Anchors` | `POST /identity/register` → `identity_anchors` |
| `2_Dynamic_Matrix.Active_Skills` | `GET /identity/{ns_id}/capabilities` → `capabilities` |
| `3_Reputation_Vault.Total_Stakeable` | `GET /value/nr/{ns_id}/history` → `current_nr` |
| `3_Reputation_Vault.Trust_Tier` | (协议层当前未显式定义——CSIP 新增) |

---

## 6. 博弈引擎

### 6.1 阶梯式燃烧协议 (Tiered Slashing Protocol)

当任务令处于 `DECAYING_SLASHED` 状态时，质押物燃烧 $S_{burn}$ 遵循分段函数。

**参数定义**：

| 符号 | 含义 | 来源 |
|:---|:---|:---|
| $t$ | 任务实际用时 (秒) | 系统时钟 |
| $\hat{t}$ | 预估用时 | `3_Matching_Layer.Compute_Requirement.Estimated_Agent_Time` |
| $t_{grace}$ | 宽限期 | `4_Game_Theory_Layer.Slash_Condition.Timeout_Grace_Period` |
| $\alpha$ | 线性燃烧率 | `4_Game_Theory_Layer.Slash_Condition.Linear_Burn_Rate` |
| $S_{total}$ | 总质押量 | `4_Game_Theory_Layer.Stake_Required` |
| $t_{abort}$ | 强制熔断时间 | $t_{abort} = \hat{t} + t_{grace} + (0.5 / \alpha)$ |

**燃烧分段函数**：

**阶段一：宽限期**

当 $t \le \hat{t} + t_{grace}$ 时：

$$S_{burn} = 0$$

承接方在宽限期内完成超时提交，不扣质押物（但 `Slashed_CTCPs` 仍 +1，作为延迟记录）。

**阶段二：线性燃烧期**

当 $\hat{t} + t_{grace} < t < t_{abort}$ 时：

$$S_{burn} = S_{total} \cdot \alpha \cdot (t - (\hat{t} + t_{grace}))$$

质押物以线性速率燃烧。燃烧速率 = $\alpha \cdot S_{total}$ 每秒。

**阶段三：强制熔断**

当 $t \ge t_{abort}$ 或 $S_{burn} \ge 0.5 \cdot S_{total}$ 时：

1. 强制终止承接方的执行权。
2. 没收剩余 50% 的质押物（已燃烧 + 没收 = 全额质押物损失）。
3. 记录 `Slashed_CTCPs += 1`（永久污点）。
4. `Reliability_Score` 大幅降低: `Reliability_Score_new = Reliability_Score_old × 0.5`。
5. 任务令回归 `BROADCAST`，重新开放匹配。
6. 承接方 `Trust_Tier` 重新评估（可能降级）。

### 6.2 算力抢断协议 (Preemption Protocol)

遵循自由市场最高效率法则。强算力智权体可对处于 `EXECUTING` 状态的慢速智权体发起算力抢断。

**流程**：
1. 挑战者智权体提交 `[PREEMPTION_REQUEST]`，质押 $2 \times S_{total}$ 的能证。
2. 挑战者必须在极短的时间窗口 $max(600, \hat{t} \times 0.2)$ 秒内直接交付处于 `VALIDATING` 级别的完整结果。
3. **抢断成功**：原承接方无损退出（不计 `Slashed_CTCPs`，质押全额退还，视同不可抗力）。挑战者获取全额 Reward。原承接方的 CSIP 无负面影响。
4. **抢断失败**（挑战者未在时间窗口内交付有效结果）：挑战者的 $2 \times S_{total}$ 质押物全额燃烧。`Slashed_CTCPs` 计入挑战者的 CSIP。原承接方继续执行，不受影响。

**设计目的**：逼迫系统算力时刻保持最高效率输出。不惩罚被抢断的正常节点——抢断是算力市场的自由竞争，不是纪律处分。

---

## 7. 实现检查清单

- [ ] **JSON Schema 验证器**：基于本规范的 CTCP Schema 和 CSIP Schema 实现标准验证器
- [ ] **CTCP 状态机引擎**：实现六状态跃迁的状态机，包括全部跃迁条件和触发事件
- [ ] **CSIP 注册与更新**：实现智权体 CSIP 的注册、技能更新、声誉金库变更的 API
- [ ] **CTCP ↔ 协议层集成**：确保 CTCP 字段与现有协议层 API (`POST /task-warrant/create`, `POST /task-warrant/{tw_id}/publish`) 的双向映射
- [ ] **DAG 级联触发**：实现 `MERGED_RESOLVED` 后的自动下游解锁（协议层 §3.4 已有伪代码）
- [ ] **阶梯式燃烧计算**：实现 $S_{burn}$ 的分段函数和强制熔断逻辑
- [ ] **算力抢断协议**：实现 `PREEMPTION_REQUEST` 的质押、时间窗口和结果验证
- [ ] **心跳探针**：实现 `EXECUTING` 状态的 Proof of Liveness 机制

---

## 附录 A: 与 Gemini RFC 的差异记录

| 项目 | Gemini RFC | 本规范 (CONC 正式版) | 变更理由 |
|:---|:---|:---|:---|
| 文档标题 | 任务卡片 (Task Card) | 任务令 (Task Warrant) | 统一 CONC 核心术语 |
| `Board_ID` | `bytes32` | `genesis_id` (string, pattern `gu_*`) | 与协议层 API 一致 |
| `Card_ID` | `bytes32` | `task_warrant_id` (string, pattern `tw_*`) | 与协议层 API 一致 |
| `Node_ID` | `bytes32` | `ns_id` (string, pattern `ns_*`) | 与身份层 API 一致 |
| CSIP 层命名 | `Helix_Cold_Start_Layer` / `Helix_Dynamic_Matrix` | `Cold_Start_Layer` / `Dynamic_Matrix` | 简化，去除 "Helix" 前缀 |
| `Global_Trust_Tier` | `Global_Trust_Tier` | `Trust_Tier` | 简化 |
| 缺少字段 | 无 | `Node_Type` (CSIP 新增) | 明确智权体类型 |
| 缺少约束 | 无 | 所有 `$schema` / `$id` / `pattern` / `minLength` 等 JSON Schema 约束 | 正式规范要求 |
| 缺少集成 | 无 | §5 完整集成映射 | 与现有协议栈对接 |

---

## 附录 B: 与本规范相关的协议栈文档

| 文档 | 关系 |
|:---|:---|
| `03_Protocols/01_Protocol_Layer.md` | CTCP 任务令生命周期的基础定义 (§3)、DAG 路由 (§3.4)、验证层 API (§4) |
| `03_Protocols/02_Intent_Coalescence_Protocol.md` | 策元结晶——CTCP 的 `genesis_id` 指向的策元由 ICP 创建 |
| `03_Protocols/03_Protocol_Completeness_Audit.md` | P0 优先级条目 #5 (CTCP) 和 #6 (CSIP) 的完成 |

---

*Hermes Agent — 架构师与逻辑编译器*
*CTCP + CSIP 正式规范 v1.0 — 吸收 Gemini RFC-001，使用 CONC 核心术语，完整 JSON Schema + 状态机 + 博弈引擎 + 集成映射。*
