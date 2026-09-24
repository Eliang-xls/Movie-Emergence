# CONC 落地任务令设计 —— 可部署规格

> **定位**：不依赖小说剧情的、可在 CONC 协议上线后直接运行的真实场景。
> **设计约束**：每个任务令都必须满足——(1) 有真实交付物 (2) 有明确验证标准 (3) 能被 MCP Tool 执行 (4) 能产出可流通的 Skill 对象。

---

## 场景一：CONC 协议自举 ——「第一圈涟漪」

### 背景

CONC 网络刚上线。没有策元，没有任务令，没有 Skill。网络是空的。

这是所有去中心化网络的经典困境——比特币网络上线第一天只有 K 一台机器在挖。以太坊上线第一天只有几十个人跑节点。CONC 上线第一天，网络里只有注册协议和空数据库。

第一批用户需要一个**由系统自动派发的引导任务**——让他们在「做一件有用的事」的过程中，自然走完 CONC 的核心协议流程。

### 任务令规格

```yaml
# ═══════════════════════════════════════════════════
# CONC 自举任务令 #001：第一圈涟漪
# 系统派发 · 强制 · 完成后解锁自由策元权限
# ═══════════════════════════════════════════════════

task_warrant:
  id: tw_bootstrap_001
  title: "第一圈涟漪——和陌生人完成一件有用的事"
  type: genesis_bootstrap
  dispatch: system_automatic
  trigger: "智权体完成能证声明后自动派发"
  priority: mandatory
  unlock: "完成后解锁：自由创建/加入策元、领取自由任务令、参与 PEER 评审"
  ttl: 30_days  # 30 天内未完成则任务过期，需重新触发

  # ── 任务目标 ──────────────────────────────────
  objective:
    statement: |
      找到 2-5 个方向相似的陌生人，组成一个临时策元，
      在 14 天内为 CONC 网络贡献一个有价值的小产出。
      
      产出可以是以下任意一种：
        A. 文档补丁 —— 修复或补充 CONC 文档中的缺失/错误
        B. 模板贡献 —— 为任务令模板库贡献一个新的模板
        C. 场景测试 —— 对 CONC 协议的一个具体流程做端到端测试并提交报告
        D. 翻译/适配 —— 将 CONC 的一份核心文档翻译为另一种语言
    
    why: |
      这个任务的存在不是为了考你——
      是为了让你在「做一件事」的过程中，自然经历 CONC 的核心协议流：
      
        能证声明 → ICP 匹配 → 策元聚结 → PCP 签署
        → 任务令设计 → PEER 评审 → Skill 酿造 → 策元解散
      
      你不需要先读完所有协议文档再开始。
      协议会在你做事情的过程中，一个一个地出现。

  # ── 成员约束 ──────────────────────────────────
  member_constraints:
    min: 2
    max: 6
    matching:
      method: icp_cosine_similarity
      threshold: 0.60
      dimensions:
        - direction_vector  # 5 维方向向量
        - skill_tags        # 能证声明中的技能标签
        - availability      # 可用时间段重叠
      notes: |
        匹配阈值 0.60 低于自由策元的默认值 0.65。
        因为这是新手任务——优先保证「能找到人」，其次保证「方向一致」。
    
    cold_start_aid:
      new_entrant_accelerator: true  # 前 10 个任务令 2× NR 加速
      matching_timeout_hours: 72     # 72 小时内未匹配到足够成员 → 降阈值至 0.50
      fallback: "如果 72 小时后仍未匹配，系统推荐「漂流者模式」——独立完成种子任务路径"

  # ── 协作流程 ──────────────────────────────────
  flow:
    phase_1_direction_dialogue:
      duration: 48_hours
      channel: system_creates_temp_channel
      deliverable: |
        成员在临时频道中完成方向对话。
        对话的目标只有一个：
        
          「我们在一起，能做什么一个人做不了的事？」
        
        对话结束后，至少需要产出一个共识声明：
          1. 我们要做什么（一句话）
          2. 为什么这件事值得做（三句话以内）
          3. 怎么判断做完了（验收标准）
        
        共识声明是 PCP 的前身——不需要正式格式，说清楚就行。
      
      gate: |
        如果 48 小时后无法达成共识 → 策元解散，成员重新匹配
        解散不惩罚。方向不一致时走不到一起是正常的。
    
    phase_2_execution:
      duration: 10_days
      tasks: |
        策元根据共识声明，自行设计 2-4 个子任务令。
        子任务令不需要遵循标准 CTCP 格式——但必须包含：
          - 谁做（负责人）
          - 做什么（一句话）
          - 怎么算做完（验收标准）
        
        子任务令的格式可以在执行过程中逐步完善——
        这本身就是 CONC 协议的学习过程。
      
      collaboration:
        communication: "策元频道内所有沟通透明可追溯"
        decision_logging: "所有决策记录自动写入 GHF"
        conflict_resolution: |
          分歧时先方向对话（30 分钟内）。
          方向对话无法解决 → 策元全体投票，≥ 2/3 通过。
          投票仍然僵持 → 任务过期，成员各自带走 Skill，无惩罚。
    
    phase_3_verification:
      method: peer_review
      config:
        reviewers: 3  # 如果策元只有 2 人，则 2 人互评
        anonymous_window: 24_hours  # 新手任务缩短匿名窗口
        dimensions:
          - name: completeness
            weight: 0.35
            question: "交付物是否完成了它声称要做的事？"
          - name: usefulness
            weight: 0.35
            question: "这个交付物对 CONC 网络有价值吗？"
          - name: process_quality
            weight: 0.30
            question: "协作过程中是否遵守了 PCP 的约定？"
        passing_score: 3.0
        deadlock_threshold: 2.0  # 分差 > 2.0 → 触发决断层
    
    phase_4_skill_output:
      requirement: |
        每个成员必须产出一个 Skill 对象。
        最低要求：
          L1: 场景描述（做了什么）
          L3: 关键决策记录（至少 1 个）
          L8: 创造者印记（四行字，本人填写）
        
        L7 引用链自动生成——指向同一策元中其他成员的 Skill。
        
        L8 的四行字不是格式要求——
        它是你在这个策元中做选择的方式。
        写不出来说明你没有做选择。
    
    phase_5_dissolution:
      options:
        - label: "解散"
          condition: "全体同意"
          effect: "策元解散，Skill 流入网络，GHF 归档"
        - label: "继续"
          condition: "≥ 2/3 同意"
          effect: "策元转为自由策元，解锁更多功能"
        - label: "分裂"
          condition: "成员方向出现分化"
          effect: "部分成员带 Skill 离开，形成新策元"
      
      mandatory_actions:
        - "GHF 记录 genesis.dissolved 或 genesis.split"
        - "所有 Skill 对象入库，L7/L8 完整"
        - "每个成员提交一句话反思：这次策元和在公司做项目有什么不同？"

  # ── 验收标准 ──────────────────────────────────
  acceptance:
    auto_checks:
      - "策元成员 ≥ 2 人"
      - "共识声明存在（≥ 1 句话）"
      - "交付物存在（文档/模板/报告/翻译）"
      - "PEER 评审已完成"
      - "每个成员的 Skill 对象 L1+L3+L8 完整"
      - "GHF 事件数 ≥ 5"
    peer_check:
      - "交付物是否对 CONC 网络有真实价值"
      - "协作过程是否体现了 CONC 协议的核心特征"

  # ── 奖励 ──────────────────────────────────────
  rewards:
    nr:
      base: 200
      completion_bonus: 100  # 完成全部流程
      peer_bonus: 50         # PEER 评分 ≥ 4.0
    unlock:
      - "自由创建策元"
      - "自由加入策元"
      - "领取自由任务令"
      - "参与 PEER 评审（作为评审者）"
      - "在种子池中发布创意图元"
```

---

## 场景二：智权体入网 ——「我的第一份能证」

### 背景

一个人第一次进入 CONC 网络。他有技能、有经验、有判断力——但这些在 CONC 网络中不存在。网络不知道他是谁。

在公司里，简历由 HR 存档。在 LinkedIn 上，经历由自己填写。在 CONC 里，能证需要**被验证**——不是你说你有什么能力，而是你能证明你做过什么。

### 任务令规格

```yaml
# ═══════════════════════════════════════════════════
# CONC 入网任务令 #001：我的第一份能证
# 系统派发 · 强制 · 完成后解锁策元参与资格
# ═══════════════════════════════════════════════════

task_warrant:
  id: tw_identity_001
  title: "我的第一份能证——向网络声明你是谁"
  type: identity_bootstrap
  dispatch: system_automatic
  trigger: "智权体注册完成时自动派发"
  priority: mandatory
  unlock: "完成后解锁：参与策元、领取任务令、ICP 被匹配"

  # ── 核心问题 ──────────────────────────────────
  core_question: |
    在 CONC 里，「你是谁」不是由你声称的——
    是由你做过的事证明的。
    
    这个任务要你做一件简单的事：
    向网络提供至少一条「可验证的贡献记录」。
    
    不需要完美。不需要全面。只需要一条——
    一条能让人说「嗯，这个人确实做过这件事」的记录。

  # ── 三条路径 ──────────────────────────────────
  paths:

    path_a_external_import:
      name: "导入你已有的痕迹"
      description: |
        如果你已经在公开平台上有贡献记录，
        直接导入。系统会自动提取能证。
      steps:
        - action: "选择平台"
          options:
            - platform: github
              extract: "仓库列表、语言分布、贡献热度、star/fork"
              nr_formula: "min(account_age_days/365*100, 200) + min(contributions*2, 300)"
            - platform: gitlab
              extract: "项目列表、MR 合并数、代码评审记录"
              nr_formula: "min(contributions*1.5, 300)"
            - platform: stackoverflow
              extract: "声望、回答数、被采纳率、标签分布"
              nr_formula: "min(reputation/10, 300)"
            - platform: academic
              extract: "论文列表、引用数、h-index"
              nr_formula: "min(h_index*50, 400)"
            - platform: manual
              extract: "手动上传贡献证明（截图、链接、文件）"
              nr_formula: 50  # 手动导入最低
        - action: "系统生成 IVD 能证名片草稿"
          output:
            - skill_tags: "从仓库语言/topics/依赖推断"
            - direction_vector: "从项目领域分布推断"
            - contribution_heatmap: "活跃时段和密度"
            - nr_seed: "基于公式的初始 NR 值"
        - action: "人工审核和修正"
          detail: |
            系统的推断一定有错。
            你需要逐项确认：
              - 技能标签对不对？不对的改。
              - 方向向量准不准？不准的调。
              - 有没有遗漏的能力是系统没推断出来的？加。
            
            这一步不是形式——它决定了你以后被 ICP 匹配到什么人。
            填得越准，匹配越对。
        - action: "签名确认"
          detail: |
            确认后，你的能证声明写入网络。
            不可撤回。可追加（新的贡献记录可以补充）。
            但已确认的记录不可删除。
            
            签名 = 把你的判断钉上去。
      auto_verification: true
      estimated_time: "5-15 分钟"
      nr_reward: "nr_seed 值（根据平台数据计算）"

    path_b_micro_contribution:
      name: "做一件小事来证明自己"
      description: |
        如果你没有平台历史，或者你不想导入——
        你可以在 CONC 网络内做一件小事来建立能证。
        
        小事不需要大。K 的比特币白皮书只有九页。
        但那九页——是他花了两个月、删了无数遍的结果。
      micro_tasks:
        - id: mt_001
          title: "修一个你看不下去的东西"
          description: |
            在 CONC 的文档、代码、设计中，找一个你觉得不对的地方。
            不一定是 bug。可能是：
              - 一个定义不清晰
              - 一个注释写错了
              - 一个设计选择你觉得有更好的做法
              - 一个术语的翻译不准确
            提交一个补丁。
          deliverable: "一个可合并的补丁 + 三句话说明"
          verification: "AUTO（补丁可应用）+ PEER(3)"
          nr_reward: 100
        
        - id: mt_002
          title: "写一份你能写但网络里没有的东西"
          description: |
            在 CONC 的文档体系中，找一个你觉得缺失的部分。
            可能是：
              - 某个协议的中文说明
              - 某个概念的通俗解释
              - 某个工具的使用教程
              - 某个设计决策的背景分析
            写出来。
          deliverable: "一篇可发布的文档"
          verification: "PEER(3)（准确性+清晰度+价值）"
          nr_reward: 120
        
        - id: mt_003
          title: "测试一个流程并报告"
          description: |
            选择 CONC 的一个具体流程（如 ICP 匹配、PEER 评审、
            Skill 生成等），实际走一遍，记录你遇到的所有问题。
            提交一份测试报告。
          deliverable: |
            测试报告，包含：
              - 你测试的是什么流程
              - 你的操作步骤
              - 遇到的问题（bug、不清楚的地方、设计不合理的地方）
              - 你的改进建议
          verification: "AUTO（报告格式完整）+ PEER(3)"
          nr_reward: 150
        
        - id: mt_004
          title: "对一个设计选择提出有理有据的反对意见"
          description: |
            在 CONC 的设计文档中，找一个你不同意的设计选择。
            写一份反对意见，包含：
              - 你反对的是什么
              - 为什么反对（理由、数据、类比）
              - 你建议的替代方案
              - 替代方案的代价是什么
          deliverable: "一份结构化的反对意见书"
          verification: "PEER(5)（论证质量——不要求被采纳，只要求论证严肃）"
          nr_reward: 200
        
        - id: mt_005
          title: "和一个陌生人完成一次 3 句话对话"
          description: |
            在 CONC 的公共频道中，找到一个你感兴趣的人。
            对 TA 说三句话：
              1. 我看了你做的XX
              2. 我觉得XX
              3. 我在XX方向上也感兴趣
            TA 回复了，就算完成。
          deliverable: "对话记录"
          verification: "AUTO（对话存在且对方回复）"
          nr_reward: 30
      
      completion_rule: "完成至少 1 个微任务 → 系统自动生成能证名片"
      estimated_time: "30 分钟 - 2 小时"

    path_c_genesis_witness:
      name: "观察一个正在运行的策元"
      description: |
        如果你不想独自做事，也不想导入旧数据——
        你可以加入一个正在进行中的策元，作为「见证者」。
        
        见证者不执行任务。见证者观察、记录、提问。
        你的观察记录就是你的能证——
        因为观察力本身就是判断力。
      steps:
        - "浏览公开策元列表，选择一个你感兴趣的"
        - "申请成为见证者（策元核审批）"
        - "观察 1-2 周，记录你看到的协作过程"
        - "在至少 1 次 PEER 评审中提交旁观者评价"
        - "策元结束时提交见证报告"
      witness_report_requirement: |
        见证报告至少包含：
          - 这个策元在做什么？（一句话）
          - 他们的协作方式和你在公司里见过的有什么不同？（三句话）
          - 如果你是成员，你会做什么不同的选择？（一句话）
          - 经过这次见证，你更清楚自己想做什么了吗？（一句话）
      verification: "策元核确认参与 + PEER(3) 评审见证报告"
      nr_reward: 150
      estimated_time: "1-2 周（观察性质，不需全职投入）"

  # ── 能证名片输出格式 ──────────────────────────
  ivd_profile_output:
    fields:
      ns_id: "智权体 ID"
      display_name: "显示名（可选）"
      skill_tags:
        format: "list of {name, level, source, confidence}"
        example:
          - {name: "TypeScript", level: 4, source: "github_import", confidence: 0.85}
          - {name: "分布式系统", level: 3, source: "seed_task_002", confidence: 0.60}
      direction_vector:
        format: "float[5] — 技术/设计/研究/商业/公益"
        example: [0.85, 0.40, 0.70, 0.20, 0.30]
      nr_seed:
        format: "integer — 初始声誉积分"
        range: "50-500"
      capability_proofs:
        format: "list of {type, platform, evidence_url, verified_at}"
        example:
          - {type: "github_import", platform: "github", evidence_url: "https://github.com/xxx", verified_at: "2026-08-10"}
          - {type: "seed_task", platform: "conc", evidence_url: "tw://mt_002/abc123", verified_at: "2026-08-12"}
      cold_start_status:
        format: "enum — not_started | in_progress | completed"
```

---

## 场景三：一个真实的小策元 ——「CONC 协议压力测试」

### 背景

前两个是系统派发的引导任务。第三个是一个**真实的、自由发起的策元案例**——它展示的是当 CONC 网络运转起来后，一群人自发聚在一起做一件事的完整过程。

选择「协议压力测试」作为场景的原因：
1. **对网络有价值**——早期协议一定有 bug，需要人去发现
2. **规模可控**——3-4 人，2 周，不需要写大量代码
3. **过程可观察**——测试过程中暴露的问题本身就是策元协作机制的验证
4. **产出可复用**——测试报告可以转化为 Skill 流通到网络中

### 创意图元

```yaml
creative_seed:
  id: cs_stress_test_001
  title: "给 CONC 协议做一次体检"
  proposer: ns_alice  # 假设的智权体 ID
  direction_vector: [0.90, 0.20, 0.80, 0.10, 0.30]
  
  intent_statement: |
    CONC 的协议文档写得很好。但文档和代码之间一定有缝隙。
    我想找 2-3 个对协议设计感兴趣的人，
    一起把 CONC 的核心流程走一遍——不是正常使用，是刻意找茬。
    
    目标：找到至少 3 个协议文档没有覆盖到的边界情况，
    提交一份测试报告 + 至少 1 个补丁。
  
  anti_intent: |
    不是为了证明 CONC 有问题。是为了让 CONC 变得更好。
    压力测试的目的是发现弱点，不是摧毁信心。
```

### 策元形成

```yaml
genesis_formation:
  icp_matching:
    threshold: 0.65
    matched_members:
      - ns_bob:
          direction_similarity: 0.78
          complementary: "Bob 做过协议测试，有 fuzzing 经验"
      - ns_carol:
          direction_similarity: 0.71
          complementary: "Carol 是技术写作者，能把测试结果写成可读的报告"
  
  pcp:
    direction: "通过压力测试让 CONC 协议更健壮"
    deliverable: "一份测试报告 + 至少 1 个补丁"
    verification: "AUTO（补丁可应用）+ PEER(5)（测试报告质量）"
    time_limit: 14_days
    dissolution_condition: "报告发布 + 补丁被接受 → 解散或继续"
    exit_policy: "任何人可随时离开，带走自己的 Skill，无惩罚"
  
  roles:
    direction_anchor: ns_alice  # 首任
    ripple_artisan: ns_bob      # 负责任务令设计
    scribe: ns_carol            # 负责 GHF 记录和报告撰写
```

### 任务令 DAG

```yaml
task_dag:
  - id: tw_stress_T1
    title: "协议流程地图绘制"
    assignee: ns_alice
    estimated_hours: 8
    description: |
      把 CONC 的核心协议流程画成一张图。
      不是架构图——是用户视角的操作流：
      
        新人注册 → 能证声明 → ICP 匹配 → 策元聚结
        → PCP 签署 → 任务令设计 → 任务领取 → 交付
        → PEER 评审 → Skill 生成 → 策元解散
      
      在每个节点上标注：
        - 输入是什么
        - 输出是什么
        - 可能的失败模式
      
      这张图是后续测试的基础——没有地图就不知道测什么。
    deliverable: "协议流程图（Mermaid 格式）+ 失败模式清单"
    verification: "AUTO（图可渲染）+ PEER(3)"
    skill_output:
      L1_scenario: "从零绘制 CONC 协议的用户视角流程地图"
      L3_decisions:
        - question: "用什么粒度画？"
          answer: "每个 MCP Tool 调用是一个节点。不展开 Tool 内部。"
          rationale: "粒度太细图会爆炸，太粗看不出问题。Tool 是协议的接口——接口级别的粒度最合适。"
      L4_distilled: "协议文档的描述是声明式的。流程图是过程式的。两种视角的差异本身就是 bug 的来源。"
      L8_imprint:
        philosophy: "先画图再测试。不知道全貌就去测，测到的都是局部。"
        aesthetic: "图比文字清楚。能用 Mermaid 就不用 Markdown 表格。"
        risk: "宁可图粗糙但完整，不可图精致但残缺。"
        style: "我画图的时候不解释。画完你看。有问题再改。"

  - id: tw_stress_T2
    title: "核心流程压力测试"
    assignee: ns_bob
    dependency: tw_stress_T1
    estimated_hours: 12
    description: |
      基于 T1 的流程图，对以下核心流程做压力测试：
      
      1. ICP 匹配：
         - 极端输入：方向向量全为 0、全为 1、只有一个非零维度
         - 边界情况：2 人匹配、7 人匹配、8 人（超限）
         - 并发：同时发起 10 个匹配请求
      
      2. PEER 评审：
         - 匿名窗口期内是否真的无法看到其他评审者身份
         - 分差恰好为 2.0 时的行为（边界值）
         - 评审者恰好是策元核时的行为
      
      3. Skill 生成：
         - L8 创造者印记为空时的处理
         - L7 引用链断裂时的处理（引用的 Skill 已被删除）
         - 授权衰减曲线的边界值（t=0, t=18年）
      
      4. 策元生命周期：
         - 策元只有 2 人时，1 人退出后的行为
         - 策元 7 人时，第 8 人申请加入的行为
         - PCP 修改投票恰好 50% 参与率时的行为
      
      每个测试用例需要：
        - 前置条件
        - 操作步骤
        - 预期行为
        - 实际行为
        - 是否通过
        - 如果不通过，严重程度（P0/P1/P2）
    deliverable: "测试用例表 + 测试执行结果"
    verification: "PEER(5)（测试覆盖度 + 发现问题的质量）"
    skill_output:
      L1_scenario: "对 CONC 协议的核心流程做系统性压力测试"
      L3_decisions:
        - question: "测试的优先级怎么排？"
          answer: "先测数据一致性，再测边界值，最后测并发。"
          rationale: "数据一致性出问题是 P0——用户数据丢了不可恢复。边界值出问题是 P1——功能异常但数据安全。并发出问题是 P2——可以通过重试解决。"
      L4_distilled: "协议文档里写的都是「正常路径」。压力测试的价值在于覆盖文档没写的「异常路径」。"
      L5_code: "测试脚本（可复用的自动化测试用例）"
      L8_imprint:
        philosophy: "测试不是找茬——是帮协议找到它自己不知道的弱点。"
        aesthetic: "测试用例的描述比测试代码更重要。描述不清楚，代码跑对了也没意义。"
        risk: "宁可多报误报，不可漏报。漏掉的 bug 会在最不该出问题的时候炸。"
        style: "我测完一个模块才说话。中间不汇报进展——进展没意义，结果才有。"

  - id: tw_stress_T3
    title: "测试报告撰写"
    assignee: ns_carol
    dependency: tw_stress_T2
    estimated_hours: 6
    description: |
      把 T1 的流程图和 T2 的测试结果整合成一份完整的测试报告。
      
      报告结构：
        1. 概述：测试了什么、谁测的、测了多久
        2. 方法：测试策略、用例设计思路
        3. 发现：
           - P0 问题（如果有）：数据一致性、安全漏洞
           - P1 问题：功能异常、边界情况处理不当
           - P2 问题：体验问题、文档缺失
        4. 建议：每个问题的修复建议
        5. 结论：协议整体健壮性评估
      
      报告的目标读者不是协议开发者——是 CONC 的普通用户。
      用户不需要懂代码就能看懂这份报告。
    deliverable: "一份面向普通用户的测试报告"
    verification: "PEER(5)（清晰度 + 完整度 + 建议可操作性）"
    skill_output:
      L1_scenario: "将技术测试结果转化为面向普通用户的可读报告"
      L3_decisions:
        - question: "报告写给谁看？"
          answer: "写给不懂技术但想了解 CONC 的人看。"
          rationale: "开发者可以直接看 issue。报告的价值是让非技术背景的人也能理解协议的状态。"
      L4_distilled: "技术报告最常见的问题不是写错——是写得太技术。读者看不懂等于没写。"
      L8_imprint:
        philosophy: "先说结论再说过程。读者没有义务看完你的全部分析才理解你的观点。"
        aesthetic: "一句话能说清的不用两句。图表比文字强。例子比定义强。"
        risk: "宁可被说「太简单」，不可被说「看不懂」。"
        style: "我写报告会先给一个完全不懂技术的人看。他看不懂的段落，我重写。"

  - id: tw_stress_T4
    title: "补丁提交（如果发现 P0/P1 问题）"
    assignee: "发现问题的人"
    dependency: tw_stress_T2
    estimated_hours: 4
    condition: "T2 发现了 P0 或 P1 级别的问题"
    description: |
      如果测试发现了协议的 bug 或设计缺陷——
      发现者负责写补丁。
      
      补丁不只是代码修复。补丁需要包含：
        - 问题描述（引用 T2 的测试用例）
        - 根因分析（为什么会出现这个问题）
        - 修复方案（代码变更）
        - 副作用分析（修复会不会引入新问题）
      
      如果问题不需要代码修复（如文档缺失、设计建议）——
      提交一份 RFC（Request for Comments）而非补丁。
    deliverable: "可合并的补丁 或 RFC 文档"
    verification: "AUTO（补丁可应用）+ PEER(3)（修复质量）"
    condition_false_action: "如果没有 P0/P1 问题 → T4 标记为 N/A，不阻塞策元解散"
    skill_output:
      L1_scenario: "基于测试发现的问题，提交协议修复补丁"
      L3_decisions:
        - question: "补丁还是 RFC？"
          answer: "如果问题有明确的代码修复方案 → 补丁。如果问题涉及设计层面的改变 → RFC。"
          rationale: "补丁解决具体 bug。RFC 讨论设计方向。两种产出的评审流程和时间尺度不同。"
      L8_imprint:
        philosophy: "修 bug 不难。难的是判断这个 bug 该不该修——有些 bug 是 feature。"
        aesthetic: "补丁的 commit message 比补丁代码更重要。message 写清楚了，reviewer 看代码的时间减半。"
        risk: "宁可修慢一点，不可修错一个。一个坏补丁比没有补丁更危险。"
        style: "我写补丁会同时写测试。没有测试的补丁我不提交。"
```

### 协作过程的关键事件（GHF 记录）

```yaml
ghf_timeline:
  - day: 1
    events:
      - type: genesis.created
        detail: "策元「CONC 体检」成立。成员：Alice, Bob, Carol。方向：协议压力测试。"
  
  - day: 2
    events:
      - type: task.claimed
        detail: "Alice 领取 T1——协议流程地图绘制"
  
  - day 4:
    events:
      - type: task.completed
        detail: "Alice 完成 T1。产出：Mermaid 流程图 + 23 个失败模式。"
      - type: gate.passed
        detail: "Gate 1（T1 设计评审）。PEER(3)：Bob 4.0, Carol 4.5。通过。"
        ghf_note: |
          Carol 在评审中提了一个关键问题：
          "流程图里 ICP 匹配和策元聚结之间没有画「方向对话」这个步骤。
          是省略了还是协议里真的没有？"
          
          Alice 的回答："协议里有 ICP 匹配，但方向对话不是一个正式的协议步骤。
          它是策元层的建议行为，不是强制流程。"
          
          这个发现后来变成了报告中的 P2 建议：
          "建议将方向对话提升为策元聚结的必要前置步骤。"
  
  - day 5:
    events:
      - type: task.claimed
        detail: "Bob 领取 T2——核心流程压力测试"
  
  - day 7:
    events:
      - type: phro_judgment
        detail: |
          Bob 在测试 ICP 匹配时发现了一个边界情况：
          当方向向量全为 0 时，ICP 匹配返回 sim = NaN 而不是 0。
          
          这算 P0 还是 P1？
          
          P0 的理由：NaN 可能导致下游计算崩溃，影响数据一致性。
          P1 的理由：全为 0 的方向向量是极端输入，实际场景中不太可能出现。
          
          Bob 选了 P1。理由：全为 0 的方向向量意味着用户没有填写方向档案——
          这在冷启动阶段可能发生，但不会导致数据丢失，只会导致匹配失败。
          
          他记录了这个判断。这条记录进入了 Skill 的 L3。
  
  - day 8:
    events:
      - type: task.completed
        detail: "Bob 完成 T2。发现：1 个 P1 + 4 个 P2。无 P0。"
      - type: peer_sync_scored
        detail: |
          Bob 的 L8 创造者印记：
            philosophy: "测试不是找茬——是帮协议找到它自己不知道的弱点。"
            aesthetic: "测试用例的描述比测试代码更重要。"
            risk: "宁可多报误报，不可漏报。"
            style: "我测完一个模块才说话。"
  
  - day 9:
    events:
      - type: task.claimed
        detail: "Carol 领取 T3——测试报告撰写"
      - type: task.claimed
        detail: "Alice 领取 T4——P1 问题补丁（ICP 匹配的 NaN 处理）"
  
  - day 11:
    events:
      - type: task.completed
        detail: "Carol 完成 T3。报告标题：《CONC 协议第一次体检报告》"
      - type: task.completed
        detail: "Alice 完成 T4。补丁：ICP 匹配中全零向量的处理——返回 sim=0 并记录警告。"
  
  - day 12:
    events:
      - type: gate.passed
        detail: "Gate 3（最终评审）。PEER(5)：报告质量 4.2，补丁质量 4.0。通过。"
      - type: submission
        detail: |
          策元向 CONC 主仓库提交：
            1. 测试报告（Markdown）
            2. 补丁（ICP NaN 修复）
            3. 流程图（Mermaid）
            4. 3 个 Skill 对象（含 L7 引用链和 L8 创造者印记）
  
  - day 13:
    events:
      - type: genesis.split
        detail: |
          策元投票：3/3 同意分裂。
          
          - Alice：带着 Skill 去做新的策元方向——ICP 匹配算法优化
          - Bob：留下维护测试套件，转为 CONC 协议的持续测试策元
          - Carol：回到日常工作，但 Skill 留在网络中流通
          
          所有 Skill 的 L7 引用链指向彼此——
          以后任何人使用这些 Skill，都能看到它们来自同一个策元。
```

---

## 三个场景的协议层覆盖矩阵

| CONC 协议机制 | 场景一（自举） | 场景二（入网） | 场景三（自由策元） |
|-------------|:---:|:---:|:---:|
| 身份注册 | ● | ● | ○ |
| 能证声明 | ○ | ● | ○ |
| ICP 匹配 | ● | ○ | ● |
| 策元聚结 | ● | ○ | ● |
| PCP 签署 | ● | ○ | ● |
| 任务令设计 | ○ | ○ | ● |
| 任务令执行 | ● | ○ | ● |
| PEER 评审 | ● | ○ | ● |
| 决断层 | ○ | ○ | ● |
| Skill 生成 | ● | ○ | ● |
| L7 引用链 | ● | ○ | ● |
| L8 创造者印记 | ● | ○ | ● |
| 策元解散/分裂 | ● | ○ | ● |
| Skill 流通 | ● | ● | ● |
| GHF 记录 | ● | ○ | ● |
| 冷启动引擎 | ● | ● | ○ |

● = 直接覆盖　○ = 间接覆盖或不涉及

---

## 一句话总结

**场景一**教 CONC 的核心流程（走一遍就会了）。
**场景二**教 CONC 的能证机制（用行动而非简历证明自己）。
**场景三**教 CONC 的协作哲学（三个陌生人用协议做完一件有用的事）。

三个场景走完，一个用户就从「网络新人」变成了「CONC 参与者」。
