# 自由策元案例：全球 AI 研究版图
# ——一份由 4 个陌生人用 3 周做出的交互式研究报告

> **项目类型**：自由策元（非 CONC 协议相关）
> **周期**：3 周（15 个工作日）
> **团队**：4 个智权体，各自携带智契（Agent）
> **产出**：一份可公开访问的交互式研究报告 + 配套数据集
> **核心展示**：不同智权体如何在多任务并行下，通过人+智契协作实现生产力跃升

---

## 一、项目定义

### 1.1 做什么

用公开数据（arXiv 论文、GitHub 仓库、Hugging Face 模型），绘制一份「全球 AI 研究版图」——

- 哪些研究方向正在升温？哪些在降温？
- 哪些机构在哪些方向上投入最多？
- 开源项目和论文之间的关联是什么？
- 一个新进入这个领域的人，应该先读哪些论文、关注哪些仓库？

产出：一个交互式 Web 页面 + 配套原始数据集 + 一份 3000 字的分析叙事。

### 1.2 为什么做这个

1. **数据公开**——arXiv API、GitHub API、HF Datasets API 都是公开的，不需要购买数据
2. **技能多样**——需要数据工程、数据分析、可视化设计、叙事写作四种能力
3. **产出可见**——交互式页面 + 数据集是可触摸的交付物
4. **规模可控**——4 人 3 周，不需要后端服务器（纯静态页面 + 客户端渲染）

### 1.3 为什么用 CONC 方式做

传统做法：一个研究团队，有 PI（首席研究员），PI 分配任务，成员各做各的，最后 PI 整合。

CONC 做法：没有 PI。4 个人通过方向相似度聚在一起。每个人同时做多个子任务，智契承担重复性工作，人做判断和创作。任务的分配不是由「上级」决定的——是由「谁在什么时候能把什么做得最好」决定的。

---

## 二、策元形成

### 2.1 创意图元

```yaml
creative_seed:
  id: cs_ai_landscape_001
  proposer: ns_lin
  title: "全球 AI 研究版图——一份人人都能看懂的交互式地图"
  direction_vector: [0.70, 0.60, 0.85, 0.30, 0.40]
  # 技术0.70  设计0.60  研究0.85  商业0.30  公益0.40

  intent_statement: |
    AI 领域的论文和项目太多了。一个人不可能全部读完。
    但数据是公开的——arXiv、GitHub、Hugging Face。
    
    我想做一件事：把这些公开数据整合起来，
    画一张地图，让任何一个想了解 AI 研究现状的人，
    不需要读 500 篇论文，就能看到全局。
    
    不是又一份论文综述。是一个可以交互的东西——
    你可以点击一个方向，看到谁在做、做了多少、开源了多少。
    
    我一个人做不完。需要懂数据的人、懂设计的人、懂讲故事的人。
```

### 2.2 ICP 匹配

```yaml
icp_matching:
  threshold: 0.65
  candidates:
    - ns_lin:        # 提出者
        direction: [0.70, 0.60, 0.85, 0.30, 0.40]
        skills: [Python, 数据分析, arXiv API, 学术写作]
        nr: 320
        availability: "每周 15 小时"
    
    - ns_kai:
        direction: [0.80, 0.30, 0.60, 0.20, 0.30]
        skills: [Python, 数据工程, GitHub API, ETL, SQL]
        nr: 280
        availability: "每周 20 小时"
        sim_with_lin: 0.71
    
    - ns_maya:
        direction: [0.40, 0.90, 0.30, 0.40, 0.50]
        skills: [UI/UX, D3.js, 数据可视化, 前端开发]
        nr: 350
        availability: "每周 15 小时"
        sim_with_lin: 0.68
    
    - ns_jin:
        direction: [0.50, 0.50, 0.70, 0.50, 0.60]
        skills: [技术写作, 数据叙事, Markdown, 英语/中文双语]
        nr: 240
        availability: "每周 12 小时"
        sim_with_lin: 0.66
  
  group_sim_average: 0.68  # ≥ 0.65 ✓
  skill_complementarity: 0.82  # 高互补性
  verdict: "匹配成功。四人技能完全互补。"
```

### 2.3 方向对话（48 小时）

```
Lin: 我想做一份 AI 研究的交互式地图。不是论文综述，是可以点的东西。

Kai: 数据源有哪些？arXiv 我熟。GitHub 也行。HF 的 API 我没用过但应该不难。

Maya: 可以做。但我需要知道——这个东西做出来给谁看？
      给研究者看和给普通人看，界面完全不一样。

Lin: 给「想了解 AI 但不是 AI 专业的人」看。
     比如一个计算机系的大三学生，或者一个想转行的工程师。

Jin: 我可以写分析叙事。但需要数据先出来——我没法对着空气写。

Kai: 数据我来。给我一周，我能把 arXiv 和 GitHub 的数据拉下来。

Maya: 那我先做设计原型。Lin，你有参考的风格吗？

Lin: 我喜欢 Observable 的风格——干净、数据驱动、交互自然。

Maya: 好。我先画线框图。Kai 出数据后我再接可视化。
```

**共识声明**：

```yaml
consensus:
  objective: "一份面向非专业读者的全球 AI 研究交互式地图"
  deliverables:
    - "交互式 Web 页面（纯静态，可部署到 GitHub Pages）"
    - "配套原始数据集（CSV/JSON，可下载）"
    - "3000 字分析叙事（中英双语）"
  verification: "页面可访问 + 数据可下载 + 叙事可读"
  time_limit: "3 周"
```

### 2.4 PCP 签署

```yaml
pcp:
  direction: "让非专业读者能在一个小时内理解全球 AI 研究的现状"
  deliverables:
    - interactive_page: "纯静态 Web 页面，可部署到 GitHub Pages"
    - dataset: "CSV/JSON 格式的原始数据，可下载"
    - narrative: "3000 字分析叙事，中英双语"
  verification:
    - "页面可在浏览器中正常打开和交互"
    - "数据集可下载且格式规范"
    - "叙事通过 PEER(3) 评审"
  exit_policy: "任何人可随时离开，带走自己的 Skill，无惩罚"
  conflict_resolution: "方向对话 → 全体投票 ≥ 2/3"
  dissolution: "三个交付物全部完成 → 解散投票"
```

---

## 三、任务令 DAG 与详细设计

### 3.1 总体任务图

```
         ┌──────────────────────────────────────────┐
         │        T0: 项目初始化（Day 1）             │
         │   仓库 · 数据目录 · 协作规范 · CI 骨架      │
         └───────────────────┬──────────────────────┘
                             │
              ┌──────────────┼──────────────┐
              ▼              ▼              ▼
    ┌─────────────┐ ┌──────────────┐ ┌─────────────┐
    │ T1: 数据采集 │ │ T5: 设计原型  │ │ T8: 叙事框架 │
    │  (Kai)      │ │  (Maya)      │ │  (Jin)      │
    │  Day 2-5    │ │  Day 2-4     │ │  Day 2-3    │
    └──────┬──────┘ └──────┬───────┘ └──────┬──────┘
           │               │               │
           ▼               │               │
    ┌─────────────┐        │               │
    │ T2: 数据清洗 │        │               │
    │  (Kai)      │        │               │
    │  Day 5-7    │        │               │
    └──────┬──────┘        │               │
           │               │               │
           ▼               ▼               │
    ┌─────────────┐ ┌──────────────┐       │
    │ T3: 数据分析 │ │ T6: 可视化实现│       │
    │  (Lin)      │ │  (Maya)      │       │
    │  Day 7-10   │ │  Day 7-12    │       │
    └──────┬──────┘ └──────┬───────┘       │
           │               │               │
           ▼               │               ▼
    ┌─────────────┐        │        ┌─────────────┐
    │ T4: 数据洞察 │        │        │ T9: 叙事撰写 │
    │  (Lin+Kai)  │        │        │  (Jin)      │
    │  Day 10-11  │        │        │  Day 10-13  │
    └──────┬──────┘        │        └──────┬──────┘
           │               │               │
           ▼               ▼               ▼
    ┌──────────────────────────────────────────┐
    │         T10: 集成与发布（Day 13-15）       │
    │    页面集成 · 数据打包 · 叙事定稿 · 发布    │
    └──────────────────────────────────────────┘
```

### 3.2 每个智权体的任务并行情况

```
         Day 1   2   3   4   5   6   7   8   9  10  11  12  13  14  15
         ─────────────────────────────────────────────────────────────────
Lin:     [T0]  [──── T1 帮助 ────] [────── T3 数据分析 ──────][T4][── T10 ──]
                                  [──── T8 审阅 ────]

Kai:     [T0]  [────── T1 数据采集 ──────][──── T2 清洗 ────][── T4 ──][T10]
                                          [T7 HF数据补充]

Maya:    [T0]  [── T5 设计原型 ──][─────── T6 可视化实现 ────────][── T10 ──]

Jin:     [T0]  [T8 叙事框架] [等待数据...] [──── T9 叙事撰写 ────][── T10 ──]
```

---

## 四、每个任务令的详细规格 + 人+智契协作方式

### T0：项目初始化

```yaml
task_warrant:
  id: T0
  title: "项目初始化"
  assignee: 全体（Lin 主导）
  day: 1
  estimated_hours: 4  # 总工时，每人 1 小时

  deliverables:
    - "Git 仓库，含目录结构"
    - "README（项目目标、数据源、技术栈）"
    - "协作规范（分支策略、提交规范、Review 流程）"
    - "数据目录骨架（raw/ → cleaned/ → analyzed/ → published/）"

  human_agent_workflow:
    lin:
      human_work: "确定目录结构和协作规范（判断性工作）"
      agent_work: "初始化仓库、生成 .gitignore、搭建 CI 骨架（模板性工作）"
      time_saved: "手动做需要 2 小时，人+智契 40 分钟"

  verification: "仓库可 clone，目录结构存在，README 完整"
```

---

### T1：数据采集（Kai）

```yaml
task_warrant:
  id: T1
  title: "数据采集——从 arXiv 和 GitHub 拉取原始数据"
  assignee: ns_kai
  day: 2-5
  estimated_hours: 16

  scope:
    arxiv:
      target: "AI/ML 相关分类（cs.AI, cs.LG, cs.CL, cs.CV, cs.NE）的最近 12 个月论文"
      fields: ["title", "authors", "abstract", "categories", "published_date", "arxiv_id"]
      expected_volume: "~50,000 篇"
      api: "arXiv API (OAI-PMH)"
    
    github:
      target: "Star ≥ 100 的 AI/ML 相关仓库"
      fields: ["name", "description", "stars", "forks", "language", "topics", "created_at", "updated_at"]
      expected_volume: "~10,000 个仓库"
      api: "GitHub REST API + GraphQL"

  human_agent_workflow:
    kai_detailed:
      # ── Day 2 ──────────────────────────────────
      day_2:
        - task: "编写 arXiv 数据采集脚本"
          human_role: "设计采集策略——决定分类范围、字段选择、速率限制处理"
          agent_role: "生成基础代码骨架——API 调用、分页处理、错误重试、数据写入"
          collaboration_pattern: |
            Kai 在终端里说："我要从 arXiv 拉 cs.AI, cs.LG, cs.CL, cs.CV, cs.NE
            五个分类最近 12 个月的论文。字段要 title, authors, abstract, categories,
            published_date。处理好 API 速率限制。"
            
            Agent 生成了 80% 的代码。Kai 花 30 分钟调整了：
            - 速率限制的退避策略（Agent 默认用指数退避，Kai 改成固定间隔——arXiv 的限制比较宽松）
            - abstract 字段的编码处理（Agent 没处理 LaTeX 特殊字符）
            - 增量采集的支持（Agent 写的是全量拉取，Kai 加了断点续传）
          time_comparison: "纯手写：6 小时。人+智契：2.5 小时（含调试）。"

      # ── Day 3 ──────────────────────────────────
      day_3:
        - task: "运行 arXiv 采集 + 开始 GitHub 采集脚本"
          human_role: "监控采集进度，处理异常（API 403、网络超时、数据格式异常）"
          agent_role: "并行编写 GitHub 采集脚本（Kai 在监控 arXiv 采集的同时 Agent 在写另一份代码）"
          collaboration_pattern: |
            这是生产力跃升的关键时刻——
            
            传统做法：先写完 arXiv 脚本，跑完，再写 GitHub 脚本，跑完。
            串行。总时间 = arXiv 编写(2.5h) + arXiv 运行(3h) + GitHub 编写(3h) + GitHub 运行(2h) = 10.5h
            
            人+智契做法：
            - Kai 启动 arXiv 采集（无人值守运行，有异常告警）
            - 同时，Agent 开始写 GitHub 采集脚本
            - Kai 审阅 Agent 的 GitHub 脚本，调整采集策略
            - arXiv 采集完成后，Kai 启动 GitHub 采集
            - 同时，Agent 开始写数据质量检查脚本
            
            并行。总时间 = max(arXiv 编写+运行, GitHub 编写) + GitHub 运行 = 5.5h + 2h = 7.5h
            节省 3 小时。
          
          time_comparison: "串行：10.5h。人+智契并行：7.5h。节省 29%。"

      # ── Day 4-5 ────────────────────────────────
      day_4_5:
        - task: "GitHub 数据采集 + 数据质量初步检查"
          human_role: "处理 GitHub API 的特殊情况（大仓库的 topics 为空、某些仓库的 description 包含非英文字符）"
          agent_role: "编写数据质量检查脚本——空值率、类型检查、重复检测、异常值标记"
          collaboration_pattern: |
            Agent 生成了数据质量检查报告：
            
            arXiv 数据：
              - 总记录：48,721
              - 空值率：title 0%, authors 0.3%, abstract 0.1%
              - 重复：12 篇（同一论文的不同版本）
              - 异常：3 篇 abstract 长度 > 10,000 字符（可能是 LaTeX 残留）
            
            GitHub 数据：
              - 总记录：9,847
              - 空值率：description 12%, topics 34%
              - 语言分布：Python 62%, JavaScript 15%, C++ 8%, 其他 15%
              - 异常：127 个仓库 stars > 10,000（需要人工确认是否真的是 AI 相关）
            
            Kai 看到 topics 34% 为空——
            这个 Agent 没有处理。Kai 决定：
            "topics 为空的仓库，从 description 和 README 中提取关键词作为替代。
            让 Agent 写一个关键词提取脚本。"
            
            Agent 用了 TF-IDF + 人工定义的 AI 领域关键词表。
            Kai 审阅了关键词表，加了 23 个遗漏的术语。
          
          time_comparison: "纯手写检查脚本：4 小时。人+智契：1.5 小时。关键词表人工校准：1 小时（不可替代）。"

  verification:
    auto:
      - "arXiv 数据 ≥ 40,000 条"
      - "GitHub 数据 ≥ 8,000 条"
      - "数据质量报告存在"
      - "原始数据存放在 data/raw/ 目录"
    peer: null  # T1 不需要 PEER 评审，数据质量由 T2 的清洗过程验证

  skill_output:
    L1: "从 arXiv 和 GitHub 公开 API 采集 AI/ML 领域的结构化数据"
    L3:
      - decision: "arXiv 分类范围选择 cs.AI/LG/CL/CV/NE 五个分类"
        rationale: "覆盖 AI 的主要子领域，排除太偏门的分类（如 cs.CY 计算社会）"
      - decision: "GitHub 仓库阈值设为 Star ≥ 100"
        rationale: "100 以下噪声太大，10,000 以上数量太少。100 是经验平衡点"
      - decision: "topics 为空时用 TF-IDF + 领域关键词表提取"
        rationale: "纯 TF-IDF 会提取出 too generic 的词。加领域关键词表做锚定"
    L4: "arXiv API 的速率限制比 GitHub 宽松得多——可以更激进地并发。GitHub 的 GraphQL API 比 REST API 效率高 3-5 倍。"
    L8:
      philosophy: "数据采集的核心不是写脚本——是决定采集什么、不采集什么。筛选条件比代码更重要。"
      aesthetic: "数据目录要干净。raw/cleaned/analyzed/ 三级目录不能混。"
      risk: "宁可多采一些冗余字段，不可遗漏关键字段。补采的成本是初采的 10 倍。"
      style: "我写采集脚本的时候不看输出。跑完再看。中间的进度不重要。"
```

---

### T2：数据清洗（Kai）

```yaml
task_warrant:
  id: T2
  title: "数据清洗——把原始数据变成可用数据"
  assignee: ns_kai
  day: 5-7
  estimated_hours: 12
  dependency: T1

  scope:
    arxiv_cleaning:
      - "去除重复（同一论文的不同版本保留最新版）"
      - "LaTeX 特殊字符清理（abstract 中的 \alpha → α 等）"
      - "作者名标准化（处理 'and' 分隔、机构信息提取）"
      - "分类标签映射（cs.AI → '人工智能', cs.LG → '机器学习' 等）"
    
    github_cleaning:
      - "去除 fork 仓库（只保留原始仓库）"
      - "语言归一化（'Jupyter Notebook' → 'Python' 等）"
      - "topics 补全（对 topics 为空的仓库做关键词提取）"
      - "活跃度标记（最近 6 个月有 commit → 'active'，否则 → 'dormant'）"
    
    cross_source_linking:
      - "论文 → 仓库关联：通过论文中的 GitHub 链接、仓库 README 中的 arXiv 链接"
      - "预期关联率：~15-20% 的论文能找到对应仓库"

  human_agent_workflow:
    kai_detailed:
      day_5:
        - task: "arXiv 数据清洗"
          human_role: "定义清洗规则（哪些 LaTeX 字符要转换、重复保留策略）"
          agent_role: "编写清洗脚本——正则替换、去重逻辑、字段标准化"
          pattern: |
            Kai 说："abstract 里的 LaTeX 公式保留原样，但特殊字符（α β γ）转成 Unicode。
            重复论文保留最新版本——按 arxiv_id 的版本号判断。"
            
            Agent 写了清洗脚本。Kai 跑了一遍，发现 3 个问题：
            1. Agent 的正则把 \mathbb{R} 这类命令也转了——应该保留原样
            2. 版本号提取的正则漏了 v 开头的情况
            3. 作者名标准化对中文作者处理不好（姓在前还是名在前）
            
            Kai 逐一修复。修复时间 40 分钟。
            如果从零手写，这些边界情况需要 2-3 小时才能全部发现。
          
          time_comparison: "手写：5 小时。人+智契：2 小时（含 40 分钟修复）。"

      day_6:
        - task: "GitHub 数据清洗 + topics 补全"
          human_role: "审核 Agent 提取的关键词——判断是否真的是 AI 相关"
          agent_role: "编写 fork 过滤、语言归一化、TF-IDF 关键词提取"
          pattern: |
            Agent 对 3,348 个 topics 为空的仓库做了关键词提取。
            提取结果需要人工审核——Agent 不知道 "transformer" 在 AI 语境下
            是指模型架构还是指电气设备。
            
            Kai 审核了关键词列表，标记了：
            - "transformer" → 保留（AI 语境下 99% 是模型架构）
            - "agent" → 保留但标记歧义（可能是 AI Agent 也可能是房地产 agent）
            - "pipeline" → 保留（AI 语境下通常是数据处理 pipeline）
            - "model" → 太泛，降权
            
            审核时间：1.5 小时。Agent 无法替代——需要领域判断。
          
          time_comparison: "关键词提取：Agent 1 小时。人工审核：1.5 小时。不可省略。"

      day_7:
        - task: "跨源关联 + 数据质量最终检查"
          human_role: "确认关联逻辑的准确性（抽样检查 50 条关联结果）"
          agent_role: "编写关联脚本——正则匹配 GitHub 链接、构建关联表"
          pattern: |
            Agent 找到了 7,234 条论文-仓库关联（占论文总数的 14.8%）。
            
            Kai 抽样检查了 50 条。发现：
            - 47 条正确（94% 准确率）
            - 2 条错误：论文中提到的 GitHub 链接是引用其他工作的，不是自己的
            - 1 条遗漏：论文的 GitHub 链接在附录里，正则没匹配到
            
            Kai 决定：94% 准确率可以接受。2 条错误在后续分析中标记为低置信度。
            附录链接的问题——让 Agent 扩展正则，匹配更多位置。
          
          time_comparison: "手写关联脚本 + 抽样检查：8 小时。人+智契：3 小时。"

  verification:
    auto:
      - "清洗后 arXiv 数据 ≥ 45,000 条（去除重复后）"
      - "清洗后 GitHub 数据 ≥ 8,000 条（去除 fork 后）"
      - "跨源关联 ≥ 5,000 条"
      - "数据质量报告更新"
    peer: null

  skill_output:
    L1: "将原始的 arXiv 和 GitHub 数据清洗为可分析的结构化数据集"
    L3:
      - decision: "topics 为空的仓库用 TF-IDF + 领域关键词表补全"
        rationale: "34% 的仓库 topics 为空，不补全会影响后续分析的完整性"
      - decision: "跨源关联的准确率阈值设为 90%"
        rationale: "低于 90% 的关联会引入太多噪声。94% 可以接受"
    L4: "LaTeX 清洗最容易遗漏的边界：\mathbb、\mathcal 这类字体命令应该保留原样。中文作者名标准化需要特殊处理——拼音转换不可靠。"
    L8:
      philosophy: "清洗不是删除——是让数据变得可信。每一个删除操作都要有理由。"
      aesthetic: "清洗后的数据应该比原始数据更小、更干净、更一致。如果清洗后数据变大了，说明逻辑有问题。"
      risk: "宁可保留脏数据标记为可疑，不可直接删除。删除不可恢复。"
      style: "我清洗数据时会先跑一个小样本（1000 条），确认逻辑正确后再跑全量。"
```

---

### T3：数据分析（Lin）

```yaml
task_warrant:
  id: T3
  title: "数据分析——从数据中提取洞察"
  assignee: ns_lin
  day: 7-10
  estimated_hours: 14
  dependency: T2

  scope:
    analyses:
      - id: A1
        name: "研究趋势分析"
        description: "按月统计各子领域的论文数量变化，识别上升/下降趋势"
        method: "时间序列聚合 + 移动平均 + 趋势斜率计算"
      
      - id: A2
        name: "机构版图"
        description: "按作者机构聚合，找出各子领域的 Top 10 投入机构"
        method: "作者机构提取 + 聚合统计 + 可视化"
      
      - id: A3
        name: "论文-开源关联度"
        description: "哪些子领域的论文更容易产生开源项目？关联率的领域差异"
        method: "按分类聚合关联率 + 统计检验"
      
      - id: A4
        name: "热门方向雷达"
        description: "综合论文增速、Star 增速、关联率，构建各子领域的综合热度指数"
        method: "多指标归一化 + 加权合成"

  human_agent_workflow:
    lin_detailed:
      # ── Day 7-8: A1 + A2 ──────────────────────
      day_7_8:
        parallel_tasks:
          - task: A1 趋势分析
            human_role: "定义「趋势」的计算方式——移动平均窗口选多大？斜率怎么标准化？"
            agent_role: "编写聚合脚本——按月按分类 groupby、移动平均、斜率计算"
            pattern: |
              Lin 说："按月聚合论文数。移动平均窗口选 3 个月——太短噪声大，太长会掩盖突变。
              斜率用线性回归的系数，归一化到 [-1, 1] 区间。"
              
              Agent 生成了分析脚本。Lin 跑完后发现：
              - 2024 年 12 月的数据明显偏低——因为 arXiv 在假期处理延迟
              - cs.CL（计算语言学）的增长斜率远超其他分类——LLM 效应
              
              Lin 让 Agent 补充：把假期效应做季节性调整。
              Agent 不知道怎么处理——它没有「假期」的概念。
              Lin 手动定义了假期月份（12月、1月、8月），让 Agent 做调整。
              
              关键洞察：Agent 能做计算，但「12月数据偏低是因为圣诞节」这种判断需要人。
            
            time_comparison: "手写分析脚本：5 小时。人+智契：2 小时。洞察解读：人 1.5 小时（不可替代）。"
          
          - task: A2 机构版图
            human_role: "设计机构名标准化规则（'MIT' = 'Massachusetts Institute of Technology'）"
            agent_role: "编写机构提取脚本（从 authors 字段中提取机构信息）+ 标准化"
            pattern: |
              arXiv 的 authors 字段中，机构信息格式极不统一：
              - "John Smith, MIT"
              - "John Smith (Massachusetts Institute of Technology)"
              - "John Smith, Computer Science, MIT"
              - "John Smith et al."
              
              Agent 写了正则提取，覆盖了 60% 的情况。
              剩下 40% 需要 Lin 手动补充规则。
              
              Lin 做了一件 Agent 做不到的事：她列了一份 Top 50 机构的别名表。
              "MIT" = "Mass. Inst. Tech." = "Massachusetts Institute of Technology"。
              这份表花了她 1 小时——但让后续所有分析的准确性提升了一个量级。
            
            time_comparison: "手写提取+标准化：6 小时。人+智契：2.5 小时（含人工别名表）。"

      # ── Day 9-10: A3 + A4 ─────────────────────
      day_9_10:
        parallel_tasks:
          - task: A3 论文-开源关联度
            human_role: "解释关联率的领域差异——为什么 NLP 的关联率比 CV 高？"
            agent_role: "按分类聚合关联率、做卡方检验、生成统计报告"
            pattern: |
              Agent 跑出了结果：
              
              子领域    论文数    有关联仓库的论文数    关联率
              cs.CL     8,234     2,156                 26.2%
              cs.CV     12,456    1,823                 14.6%
              cs.LG     15,678    1,945                 12.4%
              cs.AI     6,789     678                   10.0%
              cs.NE     2,345     156                   6.6%
              
              Agent 说："cs.CL 的关联率显著高于其他分类（p < 0.001）。"
              
              Lin 看到这个结果，解释了原因：
              "NLP 领域的开源文化最强——Hugging Face 就是从 NLP 起家的。
              而且 LLM 的代码通常比 CV 模型更容易发布（不需要大规模数据集）。
              cs.NE（神经与进化计算）关联率最低——这个领域的很多工作是理论性的，
              不一定有可运行的代码。"
              
              这段解释 Agent 写不出来——它只有数据，没有语境。
            
            time_comparison: "统计计算：Agent 30 分钟。领域解释：Lin 1 小时（不可替代）。"
          
          - task: A4 热门方向雷达
            human_role: "设计热度指数的权重——论文增速、Star 增速、关联率，各占多少？"
            agent_role: "归一化各指标、加权合成、排序"
            pattern: |
              Lin 面对一个选择：三个指标怎么加权？
              
              方案 A：等权（各 33%）
              方案 B：论文增速 50% + Star 增速 30% + 关联率 20%
              方案 C：让数据自己说话——用主成分分析（PCA）确定权重
              
              Agent 可以跑 PCA。Lin 让它跑了。
              PCA 结果：第一主成分解释了 62% 的方差，主要载荷在论文增速上。
              
              Lin 的判断："PCA 告诉我们论文增速是最重要的区分度。
              但热度不等于重要性——有些方向论文少但 Star 增速快（如 AI Agent），
              说明它在开发者中比在学术界更热。
              
              我选方案 B，但把 Star 增速的权重提高到 40%——因为我们的目标读者
              不只是研究者，还有想转行的工程师。工程师更关心开源趋势。"
            
            time_comparison: "PCA 计算：Agent 10 分钟。权重决策：Lin 40 分钟（判断性工作）。"

  verification:
    auto:
      - "A1-A4 的分析结果文件存在"
      - "数据可复现（脚本可重新运行得到相同结果）"
    peer: null

  skill_output:
    L1: "从清洗后的 AI 研究数据中提取四维洞察：趋势、机构、关联度、热度"
    L3:
      - decision: "热度指数的 Star 增速权重提高到 40%"
        rationale: "目标读者包括工程师，工程师更关心开源趋势而非论文数量"
      - decision: "假期月份做季节性调整"
        rationale: "12月和1月的论文提交量因假期下降，不调整会误判趋势"
    L4: "机构名标准化是数据清洗中最被低估的步骤。一份 50 条的别名表可以让后续分析准确性提升一个量级。"
    L8:
      philosophy: "数据分析的目标不是跑出数字——是讲出数字背后的故事。"
      aesthetic: "洞察要用一句话说清。说不清的洞察不是洞察——是噪声。"
      risk: "宁可少说一个洞察，不可多说一个错误的结论。错误结论比没有结论更有害。"
      style: "我看数据会先看异常值。异常值不是噪声——是故事的入口。"
```

---

### T4：数据洞察整合（Lin + Kai）

```yaml
task_warrant:
  id: T4
  title: "数据洞察整合——确认分析结论的可靠性"
  assignee: ns_lin + ns_kai
  day: 10-11
  estimated_hours: 6（每人 3 小时）
  dependency: T3

  human_agent_workflow:
    pattern: |
      Lin 和 Kai 一起审阅 T3 的分析结果。
      
      这不是一个需要 Agent 的步骤——这是两个人坐在屏幕前，
      对着数据讨论："这个结论对吗？有没有被数据骗了？"
      
      关键讨论：
      
      Lin: cs.CL 的关联率 26.2%——这个数字可靠吗？
      Kai: 让 Agent 跑一下 bootstrap 置信区间。
      Agent: 95% CI: [24.8%, 27.6%]。
      Kai: 区间不宽。结论可靠。
      
      Lin: AI Agent 方向的 Star 增速排名第一，但论文数排名第五。
            这说明什么？
      Kai: 说明学术界还没跟上工业界的热度。
            但 Star 增速可能是少数大仓库拉动的——让 Agent 看一下分布。
      Agent: Star 增速 Top 10 的仓库贡献了该方向 60% 的 Star 增量。
      Kai: 长尾效应明显。结论需要修正：不是「整个方向热」，是「几个头部项目热」。
      
      这一步的价值不在于计算——在于两个人对数据的解读互相校验。
      Agent 提供了置信区间和分布数据——但「该不该信这个数字」是人的判断。

  time_comparison: "如果只有一个人看数据：可能忽略长尾效应，得出过度乐观的结论。两个人交叉验证：多花 1 小时，但避免了一个错误结论。"
```

---

### T5：设计原型（Maya）

```yaml
task_warrant:
  id: T5
  title: "设计原型——页面的骨架和皮肤"
  assignee: ns_maya
  day: 2-4
  estimated_hours: 10

  scope:
    - "信息架构：页面包含哪些模块、模块之间的关系"
    - "线框图：每个模块的布局和交互方式"
    - "视觉风格：配色、字体、间距、组件风格"
    - "响应式设计：桌面端 + 移动端"

  human_agent_workflow:
    maya_detailed:
      day_2:
        - task: "信息架构设计"
          human_role: "决定页面包含哪些模块——基于 Lin 的研究框架和目标读者"
          agent_role: "无（纯设计决策）"
          pattern: |
            Maya 问 Lin："目标读者最想知道什么？"
            Lin: "第一，哪些方向在升温。第二，谁在做这些方向。第三，有没有开源代码。"
            
            Maya 在白板上画了信息架构：
            
            ┌─────────────────────────────────────┐
            │  Hero: 一句话说清这个页面是什么        │
            ├─────────────────────────────────────┤
            │  趋势热力图：X=时间, Y=子领域, 颜色=热度 │
            ├─────────────────────────────────────┤
            │  机构版图：Top 10 机构在各子领域的投入   │
            ├─────────────────────────────────────┤
            │  开源关联：哪些子领域最容易产生开源项目   │
            ├─────────────────────────────────────┤
            │  方向推荐：新进入者应该关注哪些方向       │
            ├─────────────────────────────────────┤
            │  数据下载：原始数据集 + 方法说明         │
            └─────────────────────────────────────┘
            
            这个架构是 Maya 的判断——Agent 做不了。
            Agent 可以帮你排版，但不能帮你决定「用户最想先看什么」。
          
          time_comparison: "信息架构设计：纯人工 2 小时。Agent 无法参与。"
      
      day_3:
        - task: "线框图 + 视觉风格"
          human_role: "设计线框图、选定配色和字体"
          agent_role: "生成 CSS 变量、组件样式代码、响应式断点"
          pattern: |
            Maya 画了线框图（Figma）。然后对 Agent 说：
            
            "配色方案：深蓝底色（#0A1628），亮蓝高亮（#3B82F6），
            数据密度用热力色阶（蓝→黄→红）。字体：Inter（英文）+ 思源黑体（中文）。
            组件风格：圆角 8px，阴影柔和。"
            
            Agent 生成了：
            - CSS 变量定义（配色、字体、间距）
            - 基础组件样式（卡片、按钮、Tooltip）
            - 响应式断点（768px, 1024px, 1440px）
            - 暗色模式支持
            
            Maya 审阅后调整了 3 处：
            1. 热力色阶的中间色从黄色改成橙色（黄色在深蓝底上太刺眼）
            2. Tooltip 的 z-index 提高（被热力图遮住了）
            3. 移动端的趋势图改成纵向滚动（横向太窄看不清）
            
            Agent 的 CSS 代码直接可用，Maya 只需要调整设计细节。
          
          time_comparison: "手写全部 CSS：8 小时。人+智契：3 小时（含设计调整）。"

      day_4:
        - task: "设计规范文档"
          human_role: "审阅最终设计，确认一致性"
          agent_role: "生成设计规范文档（配色表、字体表、组件库、间距规则）"
          pattern: |
            Agent 把 Maya 的设计决策整理成了一份 Markdown 文档：
            
            # 设计规范
            ## 配色
            - 背景：#0A1628
            - 主色：#3B82F6
            - 热力色阶：#1E3A5F → #F59E0B → #EF4444
            ...
            
            Maya 确认无误。这份文档在 T6（可视化实现）和 T10（集成）中会被引用。

  verification:
    auto: "线框图文件存在、设计规范文档存在、CSS 变量文件存在"
    peer: null

  skill_output:
    L1: "为数据驱动的交互式报告设计信息架构、视觉风格和组件规范"
    L3:
      - decision: "热力色阶中间色从黄色改成橙色"
        rationale: "黄色在深蓝底色上对比度过高，刺眼。橙色更柔和。"
      - decision: "移动端趋势图改成纵向滚动"
        rationale: "横向空间不够，用户需要左右滑动才能看完整趋势——体验差"
    L8:
      philosophy: "数据可视化的第一原则：让用户看到数据，不是看到图表。"
      aesthetic: "深色底 + 亮色数据。数据是主角，界面是背景。"
      risk: "宁可少放一个模块，不可让页面变拥挤。拥挤是信息可视化的敌人。"
      style: "我设计的时候先做最复杂的那个模块。最难的做好了，其他都简单。"
```

---

### T6：可视化实现（Maya）

```yaml
task_warrant:
  id: T6
  title: "可视化实现——把数据和设计变成可交互的页面"
  assignee: ns_maya
  day: 7-12
  estimated_hours: 20
  dependency: T2, T3, T5

  scope:
    components:
      - "趋势热力图（D3.js）——X=月份, Y=子领域, 颜色=论文数变化"
      - "机构版图（D3.js 力导向图）——节点=机构, 连线=共同论文, 节点大小=论文数"
      - "开源关联度柱状图（D3.js）——各子领域的关联率对比"
      - "方向推荐卡片（静态 HTML）——基于 A4 热度指数的 Top 5 推荐"
      - "数据下载区（静态链接）"

  human_agent_workflow:
    maya_detailed:
      day_7_8:
        - task: "趋势热力图组件"
          human_role: "设计交互方式——hover 展示详情、点击展开子趋势、时间轴筛选"
          agent_role: "生成 D3.js 代码骨架——SVG 渲染、色阶映射、轴标签"
          pattern: |
            Maya 对 Agent 说：
            "用 D3.js 做一个热力图。X 轴是月份（最近 12 个月），Y 轴是 5 个子领域。
            颜色用我定义的热力色阶。hover 的时候展示具体数字。点击某个格子
            展开该子领域该月的 Top 5 论文。"
            
            Agent 生成了 D3.js 代码。Maya 花了 2 小时调整：
            - 动画过渡（Agent 写的是瞬间切换，Maya 加了 300ms 的渐变）
            - Tooltip 位置（Agent 放在鼠标旁边，Maya 改成固定在右上角——避免遮挡数据）
            - 时间轴的缩放交互（Agent 没做，Maya 加了刷选功能）
            
            Agent 生成了 70% 的代码。Maya 花 30% 的时间做交互细节。
            但这 30% 决定了用户体验的好坏。
          
          time_comparison: "手写 D3.js 热力图：12 小时。人+智契：5 小时。交互细节：人 2 小时。"

      day_9_10:
        - task: "机构版图力导向图"
          human_role: "设计力导向图的参数——引力强度、斥力半径、连线粗细含义"
          agent_role: "生成 D3.js 力导向图代码——节点、连线、力仿真"
          pattern: |
            力导向图的参数需要反复调——
            Maya 让 Agent 生成了初始参数，然后在浏览器里反复试。
            
            第一版：节点太密，互相重叠。
            Maya: "斥力强度翻倍。"
            Agent 调了。好了一些，但边缘节点飞出了画布。
            Maya: "加一个边界约束。节点不能超出画布。"
            Agent 加了。但大节点（Top 机构）和小节点的引力差距太大，
            大节点全挤在中间。
            Maya: "引力强度和节点大小取对数关系，不是线性关系。"
            
            这三轮调整花了 1.5 小时。如果手写每一轮要重新改代码——
            每轮 30 分钟，三轮就是 1.5 小时的纯代码修改。
            有 Agent 的情况下，每轮只需要 Maya 说一句话，Agent 改代码，
            Maya 看效果。每轮 20 分钟。三轮 1 小时。
          
          time_comparison: "手写含调参：8 小时。人+智契：5 小时。"

      day_11_12:
        - task: "组件集成 + 响应式适配 + 性能优化"
          human_role: "确认组件之间的联动逻辑、移动端适配效果"
          agent_role: "编写集成代码、媒体查询、数据懒加载"
          pattern: |
            Agent 处理了大部分的工程细节：
            - 组件之间的数据传递（趋势图点击 → 机构图高亮对应机构）
            - 移动端的媒体查询（Maya 定义的断点）
            - 数据懒加载（首屏只加载趋势图，滚动到其他区域再加载）
            - 错误边界处理（数据加载失败时的降级展示）
            
            Maya 花了 2 小时做端到端的交互测试：
            - 桌面端：所有组件正常联动 ✓
            - 移动端：力导向图触摸拖拽不灵敏 → Agent 调整了触摸事件的灵敏度
            - 慢网络：数据加载时没有 loading 状态 → Agent 加了骨架屏
          
          time_comparison: "集成+适配+优化全手写：10 小时。人+智契：4 小时。"

  verification:
    auto:
      - "页面可在浏览器中正常打开"
      - "所有 5 个组件渲染正常"
      - "移动端可访问"
      - "首屏加载时间 < 3 秒"
    peer: null

  skill_output:
    L1: "基于 D3.js 实现数据驱动的交互式可视化组件，包含热力图、力导向图、柱状图"
    L3:
      - decision: "引力强度和节点大小取对数关系"
        rationale: "线性关系导致大节点挤在中间。对数关系让大小节点分布更均匀"
      - decision: "Tooltip 固定在右上角而非跟随鼠标"
        rationale: "跟随鼠标会遮挡数据点。固定位置让用户视线不需要追踪两个目标"
    L4: "D3.js 力导向图的参数调整是一个反复试错的过程。没有最优参数——只有在特定数据分布下看起来最好的参数。"
    L5: "D3.js 热力图组件、力导向图组件、柱状图组件（可复用）"
    L8:
      philosophy: "可视化不是让数据变好看——是让数据变好懂。好看是副产品。"
      aesthetic: "动画不超过 300ms。超过 300ms 用户会觉得慢。"
      risk: "宁可少一个交互特性，不可让页面卡。卡顿是可视化的死刑。"
      style: "我做可视化会先在纸上画——画出来才知道数据应该怎么排列。"
```

---

### T7：Hugging Face 数据补充（Kai，可选）

```yaml
task_warrant:
  id: T7
  title: "Hugging Face 模型数据补充"
  assignee: ns_kai
  day: 8-9
  estimated_hours: 6
  dependency: T2
  optional: true
  condition: "如果 Kai 在 T1-T2 完成后还有余力"

  scope:
    - "从 HF Datasets API 拉取模型数据（下载量、likes、标签）"
    - "与 arXiv 数据关联（通过模型卡片中的论文链接）"
    - "补充到分析数据集中"

  human_agent_workflow:
    pattern: |
      Kai 说："HF 的 API 比 arXiv 和 GitHub 简单。让我试试。"
      
      Agent 生成了 HF 数据采集脚本。Kai 只做了两件事：
      1. 确认采集范围（下载量 ≥ 1000 的模型）
      2. 审阅 Agent 的数据质量报告
      
      这是一个典型的「Agent 主力 + 人监督」的模式——
      任务相对简单，Agent 可以独立完成 90%，人只需要确认。
      
      如果 Kai 没有余力，T7 标记为 N/A，不影响项目完成。

  verification:
    auto: "HF 数据 ≥ 5,000 条（如有）"
```

---

### T8：叙事框架（Jin）

```yaml
task_warrant:
  id: T8
  title: "叙事框架——报告的骨架"
  assignee: ns_jin
  day: 2-3
  estimated_hours: 4

  scope:
    - "确定叙事结构——报告包含哪些章节、每章节的主旨"
    - "确定语言风格——面向非专业读者，不用行话，用类比"
    - "确定中英双语的翻译策略"

  human_agent_workflow:
    jin_detailed:
      human_role: "设计叙事结构和语言风格（纯创作性工作）"
      agent_role: "无。框架设计是纯人的判断。"
      pattern: |
        Jin 独自完成了叙事框架。没有用 Agent。
        
        框架：
        1. 开头：一句话说清这份报告是什么
        2. 趋势：哪些方向在升温（用热力图做视觉锚点）
        3. 格局：谁在做这些方向（用力导向图做视觉锚点）
        4. 开源：代码和论文的关系（用柱状图做视觉锚点）
        5. 推荐：新进入者该看什么（用卡片做视觉锚点）
        6. 方法：数据怎么来的、分析怎么做的（透明度）
        7. 数据：下载链接
        
        语言风格：每段不超过 3 句话。用类比而不是术语。
        比如不说「cs.CL 的论文增速呈指数增长」——
        说「自然语言处理方向的论文数量在过去一年翻了一倍」。
        
        这一步 Agent 完全不能替代——叙事框架是一个创作性判断。

  time_comparison: "纯人工 4 小时。Agent 无法参与叙事框架设计。"
```

---

### T9：叙事撰写（Jin）

```yaml
task_warrant:
  id: T9
  title: "叙事撰写——把数据变成故事"
  assignee: ns_jin
  day: 10-13
  estimated_hours: 12
  dependency: T3, T4, T8

  scope:
    - "根据 T3 的分析结果和 T4 的洞察整合，撰写 3000 字分析叙事"
    - "中英双语"
    - "每个章节配一段数据解读 + 一段通俗解释"

  human_agent_workflow:
    jin_detailed:
      day_10_11:
        - task: "中文初稿"
          human_role: "撰写核心洞察段落（判断性、观点性的内容）"
          agent_role: "撰写数据描述段落（客观的、统计性的内容）"
          pattern: |
            工作分配原则：
            
            人写：观点、判断、类比、结论
            Agent 写：数据描述、统计数字、趋势总结
            
            示例——趋势章节：
            
            [Agent 生成]
            "在 2024 年 8 月至 2025 年 7 月的 12 个月中，
            cs.CL（计算语言学）分类的论文数量从月均 580 篇增长至月均 1,240 篇，
            增幅 113.8%。同期 cs.CV（计算机视觉）的增幅为 23.4%，
            cs.LG（机器学习）为 18.7%。"
            
            [Jin 撰写]
            "自然语言处理方向正在经历一场前所未有的爆发。
            如果把论文数量比作人口——这个方向在过去一年里从一个中等城市
            变成了一个大都市。而其他方向的增长更像是郊区的平稳扩张。"
            
            Jin 把 Agent 的数据段落和自己的解读段落交织在一起。
            Agent 的段落提供了可信度。Jin 的段落提供了可读性。
          
          time_comparison: "纯手写 3000 字：10 小时。人+智契：5 小时（Agent 写数据段落 2 小时 + Jin 写解读段落 3 小时）。"

      day_12:
        - task: "英文翻译"
          human_role: "审阅翻译质量——确保专业术语准确、语气自然"
          agent_role: "翻译初稿"
          pattern: |
            Agent 翻译了全文。Jin 审阅后修改了 15 处：
            - 8 处专业术语不准确（Agent 把「关联率」翻成 "relevance rate"，
              应该是 "linkage rate"）
            - 4 处语气不自然（Agent 的翻译太书面，Jin 改得更口语化）
            - 3 处文化适配（Agent 翻译了「中等城市」的比喻——
              英文读者可能不理解。Jin 改成了 "from a mid-size town to a metropolis"）
            
            翻译审阅时间：1.5 小时。
            如果 Jin 自己翻译：4 小时。
            节省 2.5 小时，同时保留了人工审阅的质量把控。
          
          time_comparison: "人工翻译：4 小时。Agent 翻译 + 人工审阅：1.5 小时。"

      day_13:
        - task: "最终审校"
          human_role: "通读全文，确认逻辑连贯、数据准确、语言流畅"
          agent_role: "检查一致性——术语是否前后统一、数字是否和数据集一致"
          pattern: |
            Agent 做了一致性检查：
            - 「关联率」在全文中出现了 12 次，其中 1 次写成了「链接率」→ 标记
            - 热度指数的 Top 5 列表在正文和图表中的顺序不一致 → 标记
            - 一处引用的数据来源没有标注 → 标记
            
            Jin 逐一确认并修正。修正时间 30 分钟。
            如果人工做这个检查：需要逐字逐句对比——至少 2 小时。
          
          time_comparison: "人工一致性检查：2 小时。Agent 检查 + 人工修正：30 分钟。"

  verification:
    auto:
      - "中文叙事 ≥ 3000 字"
      - "英文叙事存在且长度与中文相近"
      - "一致性检查报告存在"
    peer:
      count: 3
      dimensions: ["准确性", "可读性", "洞察深度"]
      min_score: 3.5

  skill_output:
    L1: "将数据分析结果转化为面向非专业读者的双语叙事报告"
    L3:
      - decision: "数据段落由 Agent 生成，观点段落由人撰写"
        rationale: "Agent 擅长描述客观事实，人擅长表达主观判断。混合使用效率最高"
      - decision: "翻译由 Agent 初翻 + 人工审阅"
        rationale: "纯人工翻译效率低，纯 Agent 翻译质量低。混合最优"
    L4: "叙事写作的核心不是文字功底——是决定什么该说、什么不该说。Agent 可以帮你写，但不能帮你选。"
    L8:
      philosophy: "好的数据叙事是让人读完觉得自己变聪明了——不是让人读完觉得作者很聪明。"
      aesthetic: "每段不超过三句话。每句话不超过二十个字。节奏比文采重要。"
      risk: "宁可少说一个数据点，不可让读者困惑。困惑的读者会离开。"
      style: "我写叙事会先出声念一遍。念起来不顺的句子，写起来也不会顺。"
```

---

### T10：集成与发布（全体）

```yaml
task_warrant:
  id: T10
  title: "集成与发布——把所有东西拼在一起"
  assignee: 全体
  day: 13-15
  estimated_hours: 12（每人 3 小时）

  human_agent_workflow:
    day_13:
      - task: "页面集成"
        responsible: Maya
        pattern: |
          Maya 把 T6 的可视化组件、Jin 的叙事文本、Kai 的数据文件
          集成到一个统一的页面中。
          
          Agent 处理了：
          - HTML 结构搭建
          - 叙事文本的嵌入（Markdown → HTML）
          - 数据文件的链接和下载按钮
          - SEO meta 标签
          
          Maya 处理了：
          - 叙事文本和可视化组件之间的位置关系
          - 滚动时的视差效果
          - 页面顶部的导航锚点
    
    day_14:
      - task: "数据打包 + 方法说明"
        responsible: Kai + Jin
        pattern: |
          Kai 把清洗后的数据打包成 CSV + JSON 双格式。
          Agent 生成了数据字典（每个字段的含义和类型）。
          Jin 写了方法说明（数据来源、清洗步骤、分析方法）。
          
          Agent 做了最后的数据完整性检查：
          - CSV 文件可正常打开 ✓
          - JSON 文件格式规范 ✓
          - 数据字典和实际字段一一对应 ✓
    
    day_15:
      - task: "发布 + 策元解散"
        responsible: 全体
        pattern: |
          部署到 GitHub Pages。确认页面可访问。
          全体审阅最终页面——每人花 30 分钟做端到端浏览。
          
          然后进行策元解散投票：
          
          Lin: 解散。报告做完了。
          Kai: 解散。数据集可复用——以后有人想做类似分析可以直接用。
          Maya: 解散。组件代码开源了——别人可以 fork。
          Jin: 解散。叙事框架可以复用——以后做类似报告可以直接套。
          
          4/4 同意解散。
          
          GHF 记录：genesis.dissolved
          所有 Skill 对象入库。L7 引用链指向彼此。
          
          策元从形成到解散：15 天。
          总工时：约 100 小时（4 人）。
          如果用传统公司方式：需要 1 个 PM + 1 个数据工程师 + 1 个前端 + 1 个技术写手
          = 4 个全职员工 × 2 周 = 320 小时。
          CONC 方式节省了约 70% 的工时。
```

---

## 五、生产力提升的来源分析

### 5.1 人+智契的效率增益分解

| 任务 | 纯人工工时 | 人+智契工时 | 节省比例 | 节省来源 |
|------|----------|----------|---------|---------|
| T0 项目初始化 | 2h | 40min | 67% | Agent 生成模板代码 |
| T1 数据采集 | 16h | 10h | 38% | Agent 生成脚本 + 并行运行 |
| T2 数据清洗 | 12h | 6h | 50% | Agent 生成清洗脚本 |
| T3 数据分析 | 14h | 7h | 50% | Agent 生成分析代码 |
| T4 洞察整合 | 6h | 6h | 0% | 纯人工判断，Agent 不参与 |
| T5 设计原型 | 10h | 5h | 50% | Agent 生成 CSS 和组件代码 |
| T6 可视化实现 | 20h | 12h | 40% | Agent 生成 D3.js 代码 |
| T7 HF 数据补充 | 6h | 3h | 50% | Agent 主力 + 人监督 |
| T8 叙事框架 | 4h | 4h | 0% | 纯人工创作 |
| T9 叙事撰写 | 10h | 5h | 50% | Agent 写数据段落 + 翻译 |
| T10 集成发布 | 12h | 4h | 67% | Agent 生成集成代码 |
| **总计** | **112h** | **66.4h** | **41%** | |

### 5.2 哪些工作 Agent 不能替代

| 不可替代的工作 | 做的人 | 原因 |
|-------------|-------|------|
| 信息架构设计 | Maya | "用户最想先看什么"——是判断，不是计算 |
| 机构名别名表 | Lin | "MIT = Mass. Inst. Tech."——需要领域知识 |
| 假期效应识别 | Lin | "12月数据低是因为圣诞节"——需要常识 |
| 热度指数权重 | Lin | "Star 增速权重提高到 40%"——需要价值判断 |
| 力导向图参数调优 | Maya | "引力取对数关系"——需要视觉审美 |
| 叙事框架设计 | Jin | "每段不超过三句话"——需要创作判断 |
| 翻译审校 | Jin | "关联率 ≠ relevance rate"——需要语言直觉 |
| 数据交叉验证 | Lin + Kai | "这个结论对吗"——需要批判性思维 |

### 5.3 并行带来的效率增益

最大的效率增益不来自「Agent 替代人做重复工作」——来自「人+智契可以同时做多件事」。

```
传统串行：
  Day 1: T0
  Day 2-5: Kai 写 T1 脚本 + 运行 T1
  Day 6-8: Kai 写 T2 脚本 + 运行 T2
  Day 9-12: Lin 做 T3 分析
  Day 13-15: Maya 做 T6 可视化
  Day 16-18: Jin 写 T9 叙事
  Day 19-20: 全体 T10 集成
  总计：20 个工作日

CONC 并行：
  Day 1: T0（全体）
  Day 2-5: Kai T1 + Maya T5 + Jin T8（并行）
  Day 5-7: Kai T2（Maya 等待数据）
  Day 7-10: Kai T7 + Lin T3 + Maya T6（并行）+ Jin 等待分析结果
  Day 10-13: Lin T4 + Maya T6 继续 + Jin T9（并行）
  Day 13-15: 全体 T10
  总计：15 个工作日

节省 5 个工作日（25%）。
```

**关键洞察**：传统公司里，PM 会等数据工程师做完才让设计师开始——因为 PM 担心需求变更。CONC 里，设计师在等数据的同时可以先做信息架构和视觉风格——因为方向是共识驱动的，不会突然变。

---

## 六、策元协作的关键事件时间线

```
Day 1   ─── 策元形成 ────────────────────────────────────────────
             4 人签署 PCP，确定分工和协作规范

Day 2-5 ─── 并行执行（第一波）────────────────────────────────────
             Kai: T1 数据采集（Agent 生成脚本 + 并行运行）
             Maya: T5 设计原型（人设计 + Agent 生成 CSS）
             Jin: T8 叙事框架（纯人工）
             
             GHF: task.claimed × 3

Day 5-7 ─── 数据就绪 ──────────────────────────────────────────
             Kai: T2 数据清洗
             Maya: 等待数据（继续细化设计）
             Jin: 等待数据（准备叙事模板）
             
             GHF: task.completed (T1), task.claimed (T2)

Day 7-10 ── 并行执行（第二波）────────────────────────────────────
             Kai: T7 HF 数据补充（可选）
             Lin: T3 数据分析（Agent 生成分析代码 + 人解读洞察）
             Maya: T6 可视化实现（Agent 生成 D3.js + 人调交互）
             Jin: 等待分析结果
             
             关键事件：Lin 发现假期效应，手动定义调整规则
             关键事件：Maya 用力导向图参数调了三轮
             
             GHF: task.claimed × 3, phro_judgment × 2

Day 10-13 ─ 并行执行（第三波）────────────────────────────────────
             Lin + Kai: T4 洞察整合（交叉验证数据结论）
             Maya: T6 可视化完成
             Jin: T9 叙事撰写（Agent 写数据段落 + 人写解读段落）
             
             关键事件：Lin 和 Kai 发现 AI Agent 方向的 Star 增速是头部效应
             关键事件：Jin 让 Agent 翻译，审阅后修改了 15 处
             
             GHF: phro_judgment, task.completed × 3

Day 13-15 ─ 集成发布 ──────────────────────────────────────────
             全体: T10 集成 + 发布 + 解散投票
             
             GHF: gate.passed, genesis.dissolved

总计 GHF 事件：约 45 条
总计 Skill 对象：4 个（每人 1 个）
总计工时：约 100 小时（4 人 × 平均 25 小时/人）
```

---

## 七、这个策元证明了什么

1. **4 个互不认识的人**，没有签劳动合同，没有坐班，没有写周报——在 15 天内完成了一份交互式研究报告。

2. **每个人同时做多个任务**，智契承担了脚本生成、数据处理、CSS 编写、翻译初稿等重复性工作——人专注于判断、设计、创作。

3. **生产力提升约 41%**——主要来源不是「Agent 替代人」，而是「人+智契可以并行处理多任务」。

4. **不可替代的工作清晰可见**——信息架构设计、领域知识判断、创作性决策、数据交叉验证。这些工作 Agent 做不了，也不应该做。

5. **策元的协作方式和公司不同**——没有 PM 分配任务，任务分配由「谁在什么时候能把什么做得最好」决定。没有周一早会，所有沟通在策元频道中透明可追溯。没有绩效考核，PEER 评审就是最直接的质量反馈。

6. **产出可复用**——数据集、可视化组件、叙事框架都是开源的。任何人在任何策元中都可以引用和迭代。

---

*这个策元的全部 Skill 对象，会在解散后流入 CONC 网络。*
*L7 引用链记录了四个 Skill 之间的血统关系。*
*L8 创造者印记记录了每个人做选择时的样子。*
*涟漪扩散。最内圈的形状不变。*
