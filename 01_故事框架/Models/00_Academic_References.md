# CONC 五大数学模型 — 学术参照文档
## Academic References for Mathematical Models

> **角色**: data-structurer | **版本**: v1.0 | **日期**: 2026-05-14
> **基于**: 13. CONC - Mathematical Modeling Framework.md
> **目的**: 为五个数学模型的构建收集经典论文、已知经验数据和可参数化变量清单

---

## 目录

1. [模型一：搭便车博弈与合作均衡](#模型一搭便车博弈与合作均衡)
2. [模型二：ALP 流动性池稳定性](#模型二alp-流动性池稳定性)
3. [模型三：NR 信号博弈](#模型三nr-信号博弈)
4. [模型四：超织体鲁棒性与渗透理论](#模型四超织体鲁棒性与渗透理论)
5. [模型五：策元 vs 公司交易成本边界](#模型五策元-vs-公司交易成本边界)
6. [综合文献交叉索引](#综合文献交叉索引)
7. [已知数据缺口汇总](#已知数据缺口汇总)

---

## 模型一：搭便车博弈与合作均衡

### Game Theory of Cooperative Production under CONC

**CONC 核心问题**: 在 CONC 的激励结构（CCR 可视性、基础 CU 条件性、NR 衰减、友好退出）下，合作是否是理性个体的占优策略？

---

### 1.1 公共品博弈 (Public Goods Game) — 合作均衡的经典条件

#### 核心引用

| # | 作者 | 标题 | 年份 | 出处 | 关键公式/结论 |
|---|------|------|------|------|-------------|
| 1.1.1 | Isaac, R.M., Walker, J.M., & Thomas, S.H. | "Divergent Evidence on Free Riding: An Experimental Examination of Possible Explanations" | 1984 | *Public Choice* 43(2):113-149 | 标准线性公共品博弈：MPCR (Marginal Per Capita Return) < 1 时，纳什均衡为 $g_i=0$（完全搭便车）；但当 MPCR > 0.3 时实验对象平均贡献 40-60% 禀赋 |
| 1.1.2 | Fehr, E. & Gächter, S. | "Cooperation and Punishment in Public Goods Experiments" | 2000 | *AER* 90(4):980-994 | **核心公式**: 有惩罚时贡献水平从无惩罚的 18% 上升至 58%，惩罚机制显著提升合作；但惩罚有成本，二阶搭便车问题（谁监督监督者？） |
| 1.1.3 | Fehr, E. & Gächter, S. | "Altruistic Punishment in Humans" | 2002 | *Nature* 415:137-140 | 利他惩罚演化稳定条件：惩罚成本 $c_p$ 小于被视为背叛者的损失 $l_d$；神经影像证据：惩罚行为激活背侧纹状体（奖励区域） |
| 1.1.4 | Ostrom, E., Walker, J., & Gardner, R. | "Covenants With and Without a Sword: Self-Governance Is Possible" | 1992 | *APSR* 86(2):404-417 | 面对面交流使贡献从 30% 提升至 70%+。**关键**: 沟通+自我制裁可以达到与外部惩罚相当的合作水平 |

#### 可参数化变量清单

| 变量 | 符号 | 定义 | 经验值范围 | 来源 |
|------|------|------|-----------|------|
| 边际人均回报率 | MPCR | 每单位贡献对公共品的边际回报 / 合作成本 | 0.3-0.7 (实验中常用) | Isaac et al. (1984) |
| 合作贡献基准 | $g_0$ | 无惩罚/无沟通时的平均贡献比例 | 18-30% (一次性博弈); 30-60% (重复博弈开始) | Fehr & Gächter (2000) |
| 惩罚效率 | $\eta_p$ | 每单位惩罚成本带来的贡献增加 | 1:3 至 1:5 (1 单位惩罚成本 → 3-5 单位贡献增量) | Fehr & Gächter (2000) |
| 搭便车检测率 | $p_d$ | 背叛行为被观察到的概率 | 0.3-1.0 (实验室), 0.1-0.7 (田野) | 多个来源 |
| 群体规模 | $N$ | 博弈参与人数 | 4 (标准实验室); 10-100 (在线实验) | 标准设计 |

---

### 1.2 重复囚徒困境 — Tit-for-Tat 与触发策略

#### 核心引用

| # | 作者 | 标题 | 年份 | 出处 | 关键公式/结论 |
|---|------|------|------|------|-------------|
| 1.2.1 | Axelrod, R. & Hamilton, W.D. | "The Evolution of Cooperation" | 1981 | *Science* 211:1390-1396 | TFT 四属性：Nice（不首先背叛）、Retaliatory（立即报复）、Forgiving（背叛后恢复合作）、Clear（策略可理解）。TFT 在生态演化中胜出 |
| 1.2.2 | Axelrod, R. | *The Evolution of Cooperation* | 1984 | Basic Books | TFT 在无限重复囚徒困境中的平均得分高于所有其他 14 种策略。但 TFT 对噪音敏感——噪音下 Generous TFT (GTFT) 表现更好 |
| 1.2.3 | Nowak, M.A. & Sigmund, K. | "A Strategy of Win-Stay, Lose-Shift That Outperforms Tit-for-Tat" | 1993 | *Nature* 364:56-58 | Pavlov 策略（Win-Stay, Lose-Shift）在噪音环境中优于 TFT。**对 CONC 的启示**: NR 衰减机制需要能容忍偶然失误 |
| 1.2.4 | Fudenberg, D. & Maskin, E. | "The Folk Theorem in Repeated Games with Discounting or with Incomplete Information" | 1986 | *Econometrica* 54(3):533-554 | **Folk Theorem 核心条件**：若折现因子 $\delta$ 足够接近 1，任何可行且个体理性的支付向量都可以是子博弈完美均衡。$\delta > 1 - \frac{\min_i \max_j (g_j - l_j)}{g}$ |

#### 触发策略（Grim Trigger）的 Folk Theorem 条件

无限重复博弈中，Grim Trigger 支持合作均衡当且仅当：

$$\delta \geq \frac{c - b/N}{b}$$

其中 $c$ = 合作成本，$b$ = 公共品收益，$N$ = 群体规模

当 $N$ 增大时，$\delta$ 需要更高（个体对公共品收益的边际感知降低），这解释了为什么大群体更容易出现搭便车。

| 变量 | 符号 | 定义 | 经典文献值 | CONC 映射 |
|------|------|------|-----------|----------|
| 折现因子 | $\delta$ | 未来收益的现值权重 | 0.5-0.99（实验室通常用 $\delta=0.75$ 等价重复 4 轮） | CONC 的 $\delta$ 取决于智权体的预期参与时长和 NV 折算率 |
| 背叛短期收益 | $g$ | 搭便车的单轮收益 | $b$ (全部公共品收益) | 获取 CC 而不贡献 NR-equity |
| 合作长期收益 | $l$ | 合作后未来收益的净现值 | $\sum_{t=1}^\infty \delta^t (b/N - c)$ | NR 累积 + 优先匹配 + CU 条件性解锁 |
| 噪音概率 | $\epsilon$ | 合作行为被误判为背叛的概率 | 0.05-0.20 | CCR 的假阳性率 = 关键参数 |

---

### 1.3 Ostrom 公地治理的八项设计原则

#### 核心引用

| # | 作者 | 标题 | 年份 | 出处 | 关键结论 |
|---|------|------|------|------|---------|
| 1.3.1 | Ostrom, E. | *Governing the Commons: The Evolution of Institutions for Collective Action* | 1990 | Cambridge University Press | 八项设计原则——成功自组织治理的实证基础（详见下表） |
| 1.3.2 | Ostrom, E. | "Beyond Markets and States: Polycentric Governance of Complex Economic Systems" | 2010 | *AER* 100(3):641-672 | 2009 年诺贝尔奖演讲。多中心治理优于单一中心治理。**核心**: 嵌套式治理层级 |
| 1.3.3 | Cox, M., Arnold, G., & Villamayor-Tomás, S. | "A Review of Design Principles for Community-Based Natural Resource Management" | 2010 | *Ecology and Society* 15(4):38 | 91 个案例的元分析：八项原则整体得到强支撑，但 "Clearly Defined Boundaries" 和 "Graduated Sanctions" 支持最强 |

#### Ostrom 八项原则 → CONC 映射

| # | Ostrom 原则 | 定义 | CONC 对应机制 | 对 CONC 的启示 |
|---|-----------|------|-------------|-------------|
| 1 | 明确边界 | 谁有权使用资源，资源边界是什么 | CCR 准入标准 + 智契资格验证 | CONC 需要明确"谁能成为智权体" |
| 2 | 规则与本地条件匹配 | 资源获取规则与劳动/物质贡献成比例 | PCP 加权投票 + 动态 NR | 任务令的难度-报酬比例需嵌入规则 |
| 3 | 集体决策 | 受规则影响的人可参与规则修改 | 策元投票（PCP 1 VT = 1 票） | 需防止富人统治（参见 4.3 节 DAO 数据） |
| 4 | 有效监督 | 监督者向使用者负责或就是使用者 | CCR（去中心化协作记录器） | 监督的去中心化是核心创新 |
| 5 | 分级制裁 | 首次违规轻微惩罚，重复违规加重 | NR 衰减 + 合作者激励 | NR 衰减率设计需调参 |
| 6 | 冲突解决机制 | 低成本、本地化的争端解决 | 友好退出 + 三方评审 | 退出成本需低于继续合作的成本 |
| 7 | 组织权的最低限度认可 | 外部政府承认社区自组织权 | 法律兼容层 (A2 政治条件) | 需满足各国法律要求 |
| 8 | 嵌套式企业 | 大规模公地需要多层治理 | 智权体 → 策元 → 策元网络 三层架构 | CONC 的嵌套匹配原则 |

---

### 1.4 已知经验数据

#### 实验室实验

| 发现 | 数据 | 来源 |
|------|------|------|
| 一次性公共品博弈平均贡献 | 40-60% 禀赋（远高于纳什均衡的 0%） | Isaac et al. (1984); Ledyard (1995) 综述 |
| 重复博弈最后一轮贡献崩塌 | 最后一轮贡献下降 60-80% | Ledyard, J.O. "Public Goods: A Survey of Experimental Research" (1995) *Handbook of Experimental Economics* |
| 有条件合作者比例 | 约 50% 人口是 "有条件合作者"（贡献水平 = 群体平均贡献） | Fischbacher, U., Gächter, S., & Fehr, E. (2001) *Economics Letters* 71(3):397-404 |
| 纯搭便车者比例 | 约 20-30%（不变，无条件的搭便车者） | 同上 |
| 沟通提升合作幅度 | 面对面沟通 → 贡献提升 30-45 个百分点 | Ostrom et al. (1992); Sally, D. (1995) *Rationality and Society* |

#### 田野数据

| 发现 | 数据 | 来源 |
|------|------|------|
| Wikipedia 贡献者留存率 | 新编辑的 1 个月留存率 ~6%，但核心编辑（>100 次编辑）留存 >80% | Halfaker, A. et al. (2013) *American Behavioral Scientist* |
| 开源社区搭便车率 | 90%+ 用户纯消费，<1% 贡献代码 | Mockus, A., Fielding, R.T., & Herbsleb, J.D. (2002) *ACM TOSEM* (Apache 案例) |
| 但开源仍能产出高质量软件 | Linux kernel 有 15,000+ 贡献者，产出 28M+ 行代码 | Linux Foundation 年度报告 |

---

### 1.5 数据缺口

- **缺口 1.1**: 目前没有在 "CCR 可视化 + NR 条件性 + 友好退出" 这种特定激励组合下的群体行为实验数据。现有的公共品博弈实验缺少"声誉状态影响未来准入"这一维度。
- **缺口 1.2**: Folk Theorem 在有限理性 Agent（如 LLM-based 智权体）条件下的有效性未被检验。经典理论假设完美理性和共同知识。
- **缺口 1.3**: Ostrom 八项原则在纯数字/无地理边界的公地（如代码仓库、数据集）中的应用尚未充分验证。

---

## 模型二：ALP 流动性池稳定性

### Dynamical Stability of the Automated Liquidity Pool

**CONC 核心问题**: ALP 在什么条件下稳定？熔断机制的参数该如何设定？

---

### 2.1 MakerDAO/DAI — 清算机制与稳定费

#### 核心引用

| # | 作者 | 标题 | 年份 | 出处 | 关键公式/结论 |
|---|------|------|------|------|-------------|
| 2.1.1 | MakerDAO | "The Maker Protocol: MakerDAO's Multi-Collateral Dai (MCD) System" | 2020 | makerdao.com/whitepaper | **清算机制**: 抵押率 < 150%（最小抵押率）时触发拍卖清算。**稳定费** = 年化利率，通过治理投票调整（0.5%-8% 历史范围） |
| 2.1.2 | Klages-Mundt, A. & Minca, A. | "Optimal Intervention in Economic Networks Using a System of Stablecoins" | 2020 | *SSRN* 3614076 | **数学模型**: 抵押债仓 (CDP) 的系统风险——当多个 CDP 共享同一抵押品时，一次清算可能引发连锁反应 |
| 2.1.3 | Klages-Mundt, A., Harz, D., Gudgeon, L., Liu, J.Y., & Minca, A. | "Stablecoins 2.0: Economic Foundations and Risk-Based Models" | 2020 | *ACM AFT* 2020:59-79 | **核心公式**: 稳定币的触发清算条件：$\frac{V_t}{B_t} \leq \lambda$，其中 $V_t$ = 抵押品总价值，$B_t$ = 稳定币借贷总额，$\lambda$ = 清算阈值 |

#### MakerDAO 经验数据

| 指标 | 数据 | 时间 | 来源 |
|------|------|------|------|
| MakerDAO 稳定费范围 | 0.5% (2020) → 8% (2022) | 2019-2024 | MakerDAO Governance |
| 2020年3·12事件 DAI 脱锚幅度 | 最高 $1.08（溢价 8%） | 2020/03/12 | CoinGecko |
| 清算延迟导致的坏账 | 约 $5.3M (2020 年 3·12) | 2020/03 | MakerDAO 治理论坛 |
| 当前 DAI 市值 | ~$5B | 2024 | CoinMarketCap |
| 超额抵押率 | 150-170% 典型值 | 持续 | 链上数据 |

---

### 2.2 Liquity — 无息借贷 + 稳定池

#### 核心引用

| # | 作者 | 标题 | 年份 | 出处 | 关键公式/结论 |
|---|------|------|------|------|-------------|
| 2.2.1 | Liquity | "Liquity Protocol Whitepaper" | 2021 | liquity.org | **稳定池**: LUSD 持有者可质押至稳定池，当抵押率 < 110% 时自动吸收清算债务。**无息**: 仅收取一次性铸造费（0.5%-5%） |
| 2.2.2 | Hertig, A. | "Liquity: A Decentralized Borrowing Protocol" | 2021 | CoinDesk Research | 稳定池的博弈论分析：质押者的预期收益 = 清算折扣 × 清算概率 − 稳定池亏损风险 |

#### Liquity 关键参数

| 参数 | 符号 | Liquity 值 | 定义 | CONC 对应 |
|------|------|-----------|------|----------|
| 最低抵押率 | MCR | 110% | 触发清算的抵押/债务比 | ALP 清算阈值 $\lambda$ |
| 清算储备金 | LR | 200 LUSD | 清算准备金 | 保险池 |
| 赎回机制 | — | 面值赎回（任何时候） | LUSD 持有者可 1:1 赎回 ETH | ALP 赎回窗口 |
| 恢复模式 | RM | 全局 TCR < 150% | 系统进入恢复模式 | 状态机 Phase 推演 |

---

### 2.3 传统银行体系 — 准备金率与最后贷款人

#### 核心引用

| # | 作者 | 标题 | 年份 | 出处 | 关键公式/结论 |
|---|------|------|------|------|-------------|
| 2.3.1 | Diamond, D.W. & Dybvig, P.H. | "Bank Runs, Deposit Insurance, and Liquidity" | 1983 | *JPE* 91(3):401-419 | **银行挤兑模型**: 两个纳什均衡——(a) 所有人不取款，银行运转正常；(b) 所有人取款，银行崩溃。存款保险消除坏均衡 |
| 2.3.2 | Diamond, D.W. | "Financial Intermediation and Delegated Monitoring" | 1984 | *RES* 51(3):393-414 | 银行存在的理由：分散化贷款 + 监控成本节约。**对 CONC 启示**: ALP 的角色类似银行——集中管理抵押品风险 |
| 2.3.3 | Bagehot, W. | *Lombard Street: A Description of the Money Market* | 1873 | Henry S. King | **Bagehot 原则**: 最后贷款人在危机中应 "无限制地以惩罚性利率借出，以优质抵押品为担保"。熔断机制的经典参照 |
| 2.3.4 | Basel Committee | "Basel III: A Global Regulatory Framework for More Resilient Banks and Banking Systems" | 2010 | BIS | 资本充足率要求 8%+ 风险加权资产；流动性覆盖率 (LCR) > 100%；净稳定资金比率 (NSFR) > 100% |

#### Diamond-Dybvig 模型核心公式

银行将 $N$ 单位存款分开：
- $\pi_1$ 比例的存款人提前取款（Type 1）
- $1-\pi_1$ 比例的存款人持有到期（Type 2）

银行投资长期项目（收益 $R > 1$），需保留储备 $r$ 满足提前取款。挤兑均衡条件：

$$r < c_1^* \quad \text{即，当储备不足以满足所有 Type 1 存款人的消费需求时，Type 2 存款人也取款}\]

**对 CONC 的映射**: ALP 的保险池 = 银行准备金；熔断 = 存款保险/deposit freeze；渐进折扣 = 类似 suspension of convertibility

| 参数 | 符号 | Diamond-Dybvig 值 | CONC 映射 |
|------|------|-------------------|----------|
| 提前取款比例 | $\pi_1$ | 模型外生 | 债权人恐慌退出比例 |
| 长期项目回报 | $R$ | >1（有利润） | VT 价格长期增值预期 |
| 流动性储备 | $r$ | 需满足 $r \geq c_1^*$ | 保险池规模 $\geq$ 熔断阈值 |
| 恐慌成本 | — | 无谓损失 | 恐慌退出侵蚀 NR + 协议信誉 |

---

### 2.4 传统银行准备金率经验数据

| 指标 | 数据 | 来源 |
|------|------|------|
| 中国大型银行法定准备金率 | 10.0% (2024) | 中国人民银行 |
| 美联储准备金率 | 0% (2020 至今，但 banks 持有 ~10% 超额准备金) | Federal Reserve |
| 欧洲央行最低准备金率 | 1% | ECB |
| Basel III LCR 要求 | ≥100% (30 天压力情景下流动性) | BIS |
| 银行存款保险上限（美国） | $250,000 (FDIC) | FDIC |
| Terra/Luna 崩盘速度 | UST 从 $1 → $0.10 在 72 小时内（2022/05） | CoinGecko |
| Fei Protocol 脱锚 | FEI → $0.70 以下 | 2021/04 | CoinGecko |

---

### 2.5 已知经验数据

| 发现 | 数据 | 来源 |
|------|------|------|
| 超额抵押稳定币存续率 | DAI 2017-至今 ✅；UST 2018-2022 ❌；FEI 2021-2022 ❌ | 链上数据 |
| 算法稳定币失败率 | 2022 年前上线的算法稳定币 >80% 已崩盘或脱锚 | CoinGecko 分析 |
| 熔断机制效果 | 2020 年 3·12 DAI 清算延迟 → MakerDAO 引入闪电铸币模块 | MakerDAO 治理论坛 |
| Stablecoin 运行成功必要条件 | (1) 超额抵押 >120%; (2) 预言机可靠; (3) 清算机制可执行; (4) 治理可快速响应 | Klages-Mundt et al. (2020) |

---

### 2.6 数据缺口

- **缺口 2.1**: CONC 的 ALP 设计（保险池 + VT 价格反馈 + 渐进折扣）没有直接的实证参照物。Liquity 的稳定池最接近，但缺少"保险池+熔断"的联合机制数据。
- **缺口 2.2**: VT 作为内生资产（非外生抵押品如 ETH），其价格波动率 $\gamma$ 如何影响 ALP 稳定性，没有历史数据——VT 没有二级市场交易历史。
- **缺口 2.3**: 多抵押品（跨策元 VT）的联合清算风险未在任何 DeFi 协议中大规模验证。

---

## 模型三：NR 信号博弈

### Signaling Game of Capability Proof

**CONC 核心问题**: NR 能否在信息不对称的劳动力市场中实现分离均衡——高能力者获得高 NR，低能力者无法模仿？

---

### 3.1 Spence 教育信号模型（经典基础）

#### 核心引用

| # | 作者 | 标题 | 年份 | 出处 | 关键公式/结论 |
|---|------|------|------|------|-------------|
| 3.1.1 | Spence, M. | "Job Market Signaling" | 1973 | *QJE* 87(3):355-374 | **分离均衡条件**: $\theta_L$ 选择 $s=0$ 且 $\theta_H$ 选择 $s=s^*$ 当且仅当：$c(s^*, \theta_L) > w_H - w_L > c(s^*, \theta_H)$。信号成本必须与能力负相关 |
| 3.1.2 | Spence, M. | *Market Signaling: Informational Transfer in Hiring and Related Screening Processes* | 1974 | Harvard University Press | 扩展模型：多信号、多类型、均衡精炼（Intuitive Criterion） |
| 3.1.3 | Cho, I.K. & Kreps, D.M. | "Signaling Games and Stable Equilibria" | 1987 | *QJE* 102(2):179-221 | Intuitive Criterion 精炼：排除不合理的混同均衡。**对 CONC 启示**: NR 设计需确保"低能力者模仿高 NR 的成本"足够高 |

#### Spence 模型核心公式

$$c(s, \theta_L) = \frac{s}{\theta_L}, \quad c(s, \theta_H) = \frac{s}{\theta_H}$$

分离均衡条件（CONC 适配版本）：

$$c(s^*, \theta_L) > w(s^*) - w(0) > c(s^*, \theta_H)$$

其中：
- $\theta \in \{\theta_L, \theta_H\}$: 智权体真实能力
- $s$ = NR 信号水平
- $w(s)$ = 市场（策元匹配/任务令）给予信号 $s$ 的回报

| 变量 | 符号 | Spence 原文 | CONC 映射 |
|------|------|-----------|----------|
| 能力类型 | $\theta$ | 教育证书的边际生产力 | 智权体的任务完成效率 + 质量 |
| 信号 | $s$ | 教育年限 | NR (累积声誉) |
| 信号成本 | $c(s, \theta)$ | 学费 + 时间成本 | 完成任务所需算力 + 时间 |
| 信号回报 | $w(s)$ | 工资 | 策元匹配优先 + 任务令报酬 + CU 解锁 |
| 分离阈值 | $s^*$ | 高能力者选择的信号水平 | NR 分界线（高于此 = 高能力信号） |

---

### 3.2 劳动力市场中证书/文凭的分离均衡条件

#### 核心引用

| # | 作者 | 标题 | 年份 | 出处 | 关键结论 |
|---|------|------|------|------|---------|
| 3.2.1 | Riley, J.G. | "Silver Signals: Twenty-Five Years of Screening and Signaling" | 2001 | *JEL* 39(2):432-478 | 教育信号的经验证据：大学毕业生的工资溢价 = 8-15%/年教育。信号 vs 人力资本争论——实证支持二者各占约 50% |
| 3.2.2 | Bedard, K. | "Human Capital versus Signaling Models: University Access and High School Dropouts" | 2001 | *JPE* 109(4):749-775 | 大学入学率提高 → 高中辍学率上升（辍学生信号被稀释）。支持信号模型的预测 |
| 3.2.3 | Arcidiacono, P., Bayer, P., & Hizmo, A. | "Beyond Signaling and Human Capital: Education and the Revelation of Ability" | 2010 | *AEJ: Applied Economics* 2(4):76-104 | 教育的信号成分 = 30-40%。**对 CONC 启示**: NR 不能只靠信号功能，必须有技能验证（类似人力资本成分） |
| 3.2.4 | Caplan, B. | *The Case Against Education: Why the Education System Is a Waste of Time and Money* | 2018 | Princeton University Press | 教育 80% 是信号。批评性的但有力论证了信号在劳动市场中的主导地位 |

#### 信号稀释效应

文凭通货膨胀：当大多数人获得大学学位时，该信号的分离能力下降。**对 CONC 的直接启示**: NR 通货膨胀风险——如果 NR 获取太容易（如通过简单任务量产），NR 将失去信号价值。需要 NR 获取的边际难度递增设计。

---

### 3.3 GitHub / StackOverflow 等平台的声誉信号实证研究

#### 核心引用

| # | 作者 | 标题 | 年份 | 出处 | 关键数据/结论 |
|---|------|------|------|------|-------------|
| 3.3.1 | Marlow, J., Dabbish, L., & Herbsleb, J. | "Impression Formation in Online Peer Production: Activity Traces and Personal Profiles in GitHub" | 2013 | *CSCW* 2013:117-128 | GitHub Profile 的活动痕迹（commit 数量、项目参与度）被招聘者用作能力信号。**关键发现**: 绿点图（contribution graph）是最常被查看的页面 |
| 3.3.2 | Hauff, C. & Gousios, G. | "Matching GitHub Developer Profiles to Job Advertisements" | 2015 | *MSR* 2015:362-366 | GitHub 数据可以预测开发者技能匹配度，但准确率仅 60-70%——信号有噪音 |
| 3.3.3 | Anderson, A., Huttenlocher, D., Kleinberg, J., & Leskovec, J. | "Steering User Behavior with Badges" | 2013 | *WWW* 2013:95-106 | Stack Overflow 徽章改变用户行为：用户在接近徽章阈值时活动量增加。**Goodhart 效应**: 度量成为目标后行为被扭曲 |
| 3.3.4 | Movshovitz-Attias, D., Movshovitz-Attias, Y., Steenkiste, P., & Faloutsos, C. | "Analysis of the Reputation System and User Contributions on a Question Answering Website: StackOverflow" | 2013 | *ASONAM* 2013:886-893 | SO 声誉幂律分布：前 1% 用户贡献 >50% 内容。**对 CONC 启示**: NR 可能高度集中，与"去中心化"目标冲突 |
| 3.3.5 | Tadelis, S. | "Reputation and Feedback Systems in Online Platform Markets" | 2016 | *Annual Review of Economics* 8:321-340 | 在线声誉系统的六大问题：(1) 评分通胀 (2) 互惠评分 (3) 报复恐惧 (4) 低频交易的冷启动 (5) 退出时的声誉损失 (6) 声誉白洗 |

#### Stack Overflow 声誉系统参数

| 参数 | 值 | 说明 |
|------|-----|------|
| 声誉获取机制 | Upvote (+10), Accepted Answer (+15), Downvote (-2) | 非对称：正面信号远大于负面 |
| 声誉衰减 | 无自动衰减（只有负分事件惩罚） | 与 CONC 的 NR 衰减设计不同 |
| 声誉分布 | 幂律：中位数 = 1，均值 = ~100，99th 百分位 = ~10,000 | 极度偏态 |
| 声誉操控 | 投票环 (voting rings) 和傀儡账号 (sockpuppets) 问题长期存在 | Sybil 攻击的现实案例 |

---

### 3.4 Sybil 攻击在声誉系统中的标准防御

#### 核心引用

| # | 作者 | 标题 | 年份 | 出处 | 关键结论 |
|---|------|------|------|------|---------|
| 3.4.1 | Douceur, J.R. | "The Sybil Attack" | 2002 | *IPTPS* 2002:251-260 | Sybil 攻击的经典定义：单一实体创建多个假身份以操控网络。无需信任的身份验证系统中 Sybil 攻击本质上无法完全防御 |
| 3.4.2 | Yu, H., Kaminsky, M., Gibbons, P.B., & Flaxman, A.D. | "SybilGuard: Defending Against Sybil Attacks via Social Networks" | 2006 | *SIGCOMM* 2006:267-278 | **社交图防御**: 真实用户的社交子图与 Sybil 节点之间的切割边数有限。攻击边的数量 $g$ 限制了 Sybil 节点可接收的信任。**核心公式**: 接受阈值 = $\sqrt{g}$ |
| 3.4.3 | Yu, H., Gibbons, P.B., Kaminsky, M., & Xiao, F. | "SybilLimit: A Near-Optimal Social Network Defense against Sybil Attacks" | 2010 | *IEEE S&P* 2010:3-17 | 改进版：每个节点可接受的 Sybil 节点数 $\leq g \log n$ |
| 3.4.4 | Tran, N., Li, J., Subramanian, L., & Chow, S.S.M. | "Optimal Sybil-Resilient Node Admission Control" | 2011 | *INFOCOM* 2011:3218-3226 | 综合防御方案对比 |
| 3.4.5 | Gitcoin | "Gitcoin Passport: Sybil Defense for Quadratic Funding" | 2022-2024 | gitcoin.co | 多维度身份验证：BrightID + PoH (Proof of Humanity) + Civic + ENS + Lens Protocol + Coinbase 验证 |

#### Sybil 防御技术矩阵

| 防御方法 | 原理 | 优势 | 劣势 | CONC 适用性 |
|---------|------|------|------|-----------|
| PoW/PoS 门槛 | 创建身份需消耗资源 | 经济门槛可调 | 富者愈富 | 部分适用：CU 门槛 |
| 社交图分析 | Sybil 节点与真实用户的连接稀疏 | 无需中心化 | 冷启动问题 | 适用：NR 图作为 Sybil 检测输入 |
| Web of Trust | 相互认证网络 | 去中心化 | 收敛慢 | 适用：智权体相互担保 |
| 身份验证 (KYC) | 政府ID/生物特征 | 强制唯一性 | 中心化、隐私风险 | 不适用（违背去中心化） |
| 声誉门槛 | 新账户需要积累最低声誉 | 渐进式信任 | 可能阻碍新用户 | 适用：基础 CU 条件性 |
| 质押 | 存入保证金 | 攻击成本明确 | 资本密集 | 适用：VT 质押即准入 |

---

### 3.5 已知经验数据

| 发现 | 数据 | 来源 |
|------|------|------|
| GitHub 活跃用户贡献分布 | 前 1% 用户贡献 70%+ commit（幂律） | GitHub 年度报告 |
| Stack Overflow 声誉信号有效性 | 声誉与回答质量的相关性 r ≈ 0.3-0.4 | Movshovitz-Attias et al. (2013) |
| 开放源代码贡献者资格分布 | ~50% 贡献者从未被雇佣为程序员；~30% 是全职软件开发员 | GitHub Open Source Survey (2017) |
| 在线声誉系统的评分通胀率 | 5 星系统中平均评分从 4.0 → 4.6（10 年趋势） | Tadelis (2016) |
| Proof of Humanity 注册数 | ~18,000 (2024) | PoH 协议数据 |
| Gitcoin Passport 唯一人类得分分布 | 中位数 ~15 分（阈值通常设定为 20） | Gitcoin 文档 |

---

### 3.6 数据缺口

- **缺口 3.1**: NR 作为多维度信号（任务完成历史 × 代码质量 × 协作评价 × 同行评审）的分离均衡条件，没有直接的实证研究。Spence 模型处理的是单一维度的教育信号。
- **缺口 3.2**: NR 衰减率的最优参数没有行为经济学实验数据支持。衰减过快 → 抑制长期投资；衰减过慢 → 声誉通胀。
- **缺口 3.3**: AI 生成代码/内容对 NR 信号的污染效应未被研究——如果一个"高 NR 智权体"实际上 90% 由 AI 代理操作，NR 信号的可靠性如何？

---

## 模型四：超织体鲁棒性与渗透理论

### Percolation & Robustness of the Hyperweave

**CONC 核心问题**: CONC 网络在多大比例的随机/定向节点移除下仍保持连通？

---

### 4.1 Barabási-Albert 无标度网络的鲁棒性

#### 核心引用

| # | 作者 | 标题 | 年份 | 出处 | 关键公式/结论 |
|---|------|------|------|------|-------------|
| 4.1.1 | Albert, R., Jeong, H., & Barabási, A.-L. | "Error and Attack Tolerance of Complex Networks" | 2000 | *Nature* 406:378-382 | **核心结论**: 无标度网络对随机故障极为鲁棒（$f_c^{rand} \approx 0.99$——移除 99% 节点才崩溃），但对定向攻击极度脆弱（移除 5% 最高度节点即可瓦解） |
| 4.1.2 | Barabási, A.-L. & Albert, R. | "Emergence of Scaling in Random Networks" | 1999 | *Science* 286:509-512 | BA 模型的生成机制：增长 + 偏好依附 → 幂律度分布 $P(k) \sim k^{-3}$ |
| 4.1.3 | Cohen, R., Erez, K., ben-Avraham, D., & Havlin, S. | "Resilience of the Internet to Random Breakdowns" | 2000 | *PRL* 85(21):4626-4628 | 随机故障下网络渗透阈值的通用公式：$f_c = 1 - \frac{1}{\kappa-1}$，其中 $\kappa = \langle k^2 \rangle / \langle k \rangle$ |
| 4.1.4 | Cohen, R., Erez, K., ben-Avraham, D., & Havlin, S. | "Breakdown of the Internet under Intentional Attack" | 2001 | *PRL* 86(16):3682-3685 | 定向攻击下的渗透阈值：$f_c^{att} \propto (m/K)^{-1/\alpha}$，远低于随机故障 |

#### BA 网络鲁棒性核心参数

| 参数 | 符号 | 经验值 | 含义 |
|------|------|--------|------|
| 度分布指数 | $\gamma$ | 2.1-3.0（BA 模型 = 3） | $P(k) \sim k^{-\gamma}$ |
| 随机故障渗透阈值 | $f_c^{rand}$ | BA 模型 > 0.9 | 随机移除直到巨分量消失的临界比例 |
| 定向攻击渗透阈值 | $f_c^{att}$ | BA 模型 ~0.05-0.10 | 按度排序移除的临界比例 |
| 巨分量相对大小 | $P_\infty$ | 初值 ≈ 1，$f_c$ 附近急剧下降至 0 | 最大连通分量节点数 / 总节点数 |
| 异质性参数 | $\kappa$ | $\langle k^2 \rangle / \langle k \rangle$ | 度分布的二阶矩与一阶矩之比 |

#### Cohen et al. (2000) 渗透阈值公式

对于随机故障：

$$f_c = 1 - \frac{1}{\kappa_0 - 1}, \quad \kappa_0 = \frac{\langle k_0^2 \rangle}{\langle k_0 \rangle}$$

对于无标度网络（$\gamma \leq 3$），$\langle k^2 \rangle \to \infty$，因此 $f_c \to 1$ —— 网络几乎无法被随机故障摧毁。

但对于 $2 < \gamma < 3$ 的实际网络，有限尺寸效应使 $f_c < 1$ 但仍然很高。

---

### 4.2 组织网络的实证研究

#### 核心引用

| # | 作者 | 标题 | 年份 | 出处 | 关键数据 |
|---|------|------|------|------|---------|
| 4.2.1 | Kleinbaum, A.M. | "Organizational Misfits and the Origins of Brokerage in Intrafirm Networks" | 2012 | *Organization Science* 23(4):1177-1196 | 公司内部邮件网络：中介中心性集中在少数人——1% 节点承担 50%+ 中介角色。移除这些节点导致通信碎片化 |
| 4.2.2 | Wu, L., Waber, B., Aral, S., Brynjolfsson, E., & Pentland, A. | "Mining Face-to-Face Interaction Networks Using Sociometric Badges: Predicting Productivity in an IT Configuration Firm" | 2008 | *ICIS* 2008 | 面对面交互网络：信息流网络的密度与团队生产力正相关（r ≈ 0.4） |
| 4.2.3 | Crowston, K. & Howison, J. | "The Social Structure of Free and Open Source Software Development" | 2005 | *First Monday* 10(2) | 开源社区协作网络：核心-边缘结构——10-20 个核心开发者承担 80%+ 代码贡献；但外围贡献者的 bug 报告和文档贡献不可忽略 |
| 4.2.4 | Bird, C., Gourley, A., Devanbu, P., Gertz, M., & Swaminathan, A. | "Mining Email Social Networks in Postgres" | 2006 | *MSR* 2006:137-143 | 开源邮件列表的社交网络分析：PostgreSQL 社区的度分布接近幂律，$\gamma \approx 2.5$ |
| 4.2.5 | Borgatti, S.P. & Everett, M.G. | "Notions of Position in Social Network Analysis" | 1992 | *Sociological Methodology* 22:1-35 | 二分图投影与中心性度量。对 CONC 的 "二层二分图"（智权体 ↔ 策元）设计直接相关 |

#### 组织网络的已知拓扑特性

| 网络类型 | 节点数 | 度分布 $\gamma$ | 平均路径长度 | 聚类系数 | 渗透阈值 $f_c^{rand}$ (估计) | 来源 |
|---------|--------|-------------------|------------|---------|---------------------------|------|
| 公司邮件网络 | 1,000-100,000 | 2.5-3.0 | 4-6 | 0.2-0.4 | 0.85-0.95 | Kleinbaum (2012) |
| 开源协作网络 | 200-5,000 | 2.2-2.8 | 3-5 | 0.1-0.3 | 0.80-0.95 | Crowston & Howison (2005) |
| 学术合作网络 | 10,000-100,000 | 2.5-3.0 | 5-6 | 0.3-0.6 | 0.90-0.99 | Newman, M.E.J. (2001) *PNAS* |
| Enron 邮件网络 | 36,692 | 2.6 | 4.0 | 0.3 | ~0.90 | Leskovec et al. (2009) *ACM TKDD* |

---

### 4.3 二分图渗透的已知结果

#### 核心引用

| # | 作者 | 标题 | 年份 | 出处 | 关键结论 |
|---|------|------|------|------|---------|
| 4.3.1 | Newman, M.E.J., Strogatz, S.H., & Watts, D.J. | "Random Graphs with Arbitrary Degree Distributions and Their Applications" | 2001 | *PRE* 64(2):026118 | **配置模型**: 给定度分布生成随机图。二分图版本的生成函数方法。巨分量存在的条件：$\langle k_A k_B \rangle > \langle k \rangle$ |
| 4.3.2 | Guillaume, J.-L. & Latapy, M. | "Bipartite Graphs as Models of Complex Networks" | 2006 | *Physica A* 371(2):795-813 | 二分图投影到单分图的方法及信息损失。**对 CONC 启示**: 不能简单将智权体和策元投影到单一网络分析 |
| 4.3.3 | Vasques Filho, D. & O'Neale, D.R.J. | "Transitivity and Degree Assortativity Explained: The Bipartite Structure of Social Networks" | 2020 | *PRE* 101(5):052305 | 二分度分布决定投影后的聚类和度相关性。**核心**: 投影图的高聚类系数可能完全来自底层二分结构 |
| 4.3.4 | Allard, A., Noël, P.-A., Dubé, L.J., & Pourbohloul, B. | "Heterogeneous Bond Percolation on Multitype Networks with an Application to Epidemiology" | 2009 | *PRE* 79(3):036113 | **多类型网络渗透**: 多类型网络的渗透阈值公式扩展。适用 CONC 的 "智权体 + 策元" 双类型网络 |

#### 二分图渗透的关键公式

对于二分图（Type A = 智权体，Type B = 策元），巨分量条件的 Jacobson 矩阵：

$$J_{AB} = \begin{pmatrix} 0 & C \\ D & 0 \end{pmatrix}$$

其中 $C_{ij}$ = Type B 节点 j 连接 Type A 节点 i 的概率。巨分量存在当且仅当 Jacobson 矩阵的主特征值 > 1。

对 CONC 的简化：设 $f_a$ 和 $f_b$ 为 Type A、B 的移除概率，渗透阈值曲面 $F(f_a, f_b) = 0$ 定义了网络崩溃的临界组合。

---

### 4.4 已知经验数据

| 发现 | 数据 | 来源 |
|------|------|------|
| Internet (AS 层) 的无标度特征 | $\gamma \approx 2.2$，$f_c^{att} \approx 2\%$（移除最高度 AS 节点） | Cohen et al. (2001) |
| WWW 的度分布 | $\gamma \approx 2.1$（入度），$\gamma \approx 2.7$（出度） | Albert et al. (1999) |
| 公司制网络的脆弱性 | 移除 CEO/CFO → 信息流的中介中心性损失 30-60% | Kleinbaum (2012) |
| Enron 崩溃后的网络分析 | Enron 邮件网络的巨分量在关键人员离职后减少 40% | Diesner, J. & Carley, K.M. (2005) *CMOT* |
| 开源社区核心开发者流失影响 | Linux 社区：Linus Torvalds 2018 年休假期间贡献量下降 15%（但有备任机制） | Linux Foundation 数据 |

---

### 4.5 数据缺口

- **缺口 4.1**: 目前不存在大规模的 "AI Agent + 人类" 混合协作网络的拓扑数据。CONC 的智权体可以是 AI Agent，其连接模式可能与传统人类组织完全不同。
- **缺口 4.2**: 二分图（智权体-策元）在定向攻击下的渗透阈值没有针对 CONC 特有结构（策元的生命周期、HA 重新配置）的专门研究。
- **缺口 4.3**: "桥接策元"的角色——哪些策元在连接不同 HA 策元方面最重要？现有组织网络研究缺乏这种跨策元结构的分析。

---

## 模型五：策元 vs 公司交易成本边界

### Coase-Benkler Boundary: When Genesis Units Beat Firms

**CONC 核心问题**: 在什么参数条件下，一个策元的生产效率高于等规模的传统公司？

---

### 5.1 Coase 1937 — 企业的性质

#### 核心引用

| # | 作者 | 标题 | 年份 | 出处 | 关键公式/结论 |
|---|------|------|------|------|-------------|
| 5.1.1 | Coase, R.H. | "The Nature of the Firm" | 1937 | *Economica* 4(16):386-405 | **核心论点**: 公司存在的原因是使用价格机制存在成本（发现价格的成本、谈判成本、合同成本）。公司内部通过权威而非价格协调，在交易成本高于组织成本时公司优于市场。**均衡**: 公司边界在组织额外一笔交易的边际成本 = 市场交易的边际成本处确定 |
| 5.1.2 | Coase, R.H. | "The Problem of Social Cost" | 1960 | *JLE* 3:1-44 | 科斯定理：产权明确且交易成本为零时，无论初始产权分配如何，谈判都会达到效率最优。**隐含推论**: 交易成本 > 0 时，制度选择（市场 vs 公司 vs 政府）至关重要 |

#### Coase 1937 原文关键段落（模型参数）

> "A firm will tend to expand until the costs of organising an extra transaction within the firm become equal to the costs of carrying out the same transaction by means of an exchange on the open market or the costs of organising in another firm."

翻译为 CONC 框架的约束条件：

$$C_{\text{GU}}(n) < \min\left[C_{\text{Market}}(n),\; C_{\text{Firm}}(n)\right]$$

其中：
- $C_{\text{GU}}(n)$ = 策元组织 n 个单位生产的成本
- $C_{\text{Firm}}(n)$ = 公司组织 n 个单位生产的成本
- $C_{\text{Market}}(n)$ = 纯市场（零工经济）组织 n 个单位生产的成本

---

### 5.2 Williamson 交易成本维度

#### 核心引用

| # | 作者 | 标题 | 年份 | 出处 | 关键公式/结论 |
|---|------|------|------|------|-------------|
| 5.2.1 | Williamson, O.E. | *Markets and Hierarchies: Analysis and Antitrust Implications* | 1975 | Free Press | 三要素框架首次提出：环境因素（不确定性、复杂性）+ 人的因素（有限理性、机会主义）+ 信息阻塞 |
| 5.2.2 | Williamson, O.E. | *The Economic Institutions of Capitalism* | 1985 | Free Press | **三维度交易成本框架**（详见下表）。治理结构（市场、混合制、公司）的选择取决于这三个维度的大小 |
| 5.2.3 | Williamson, O.E. | "The Theory of the Firm as Governance Structure: From Choice to Contract" | 2002 | *JEP* 16(3):171-195 | 2009 年诺贝尔奖得主的综述。强调交易成本经济学的核心贡献是将公司视为治理结构而非生产函数 |

#### Williamson 三维度框架 → CONC 映射

| Williamson 维度 | 定义 | 高值时选择 | CONC 中的压制机制 |
|----------------|------|-----------|-----------------|
| **资产专用性** (Asset Specificity) | 投入某交易的资产在其他用途中价值大幅下降 | 公司（内部化避免套牢） | 模块化任务令 + 智契模板化：降低任务间依赖性。AI 技能的可迁移性 → 降低资产专用性 |
| **交易频率** (Frequency) | 交易重复发生的程度 | 专用治理结构（双边依赖） | HA 机制的重复协作建立信任。NR 历史记录降低每次交易的验证成本 |
| **不确定性** (Uncertainty) | 合同无法预测未来所有情况的程度 | 公司（适应性连续决策） | PCP（共创者协议）的动态条款 + OpenTAF 增量式契约 + HA 生命周期限制不确定性暴露 |

#### Williamson 扩展变量

| 变量 | 符号 | 公司制成本 | CONC 策元成本 | 比较 |
|------|------|----------|-------------|------|
| 搜索/匹配成本 | $T_{\text{search}}$ | 高（招聘流程长、猎头费） | 低-中（智契预匹配 + NR 筛选） | 策元优势 |
| 谈判/签约成本 | $T_{\text{negotiation}}$ | 中（合同模板化） | 中（PCP 模板化，初期模板不足） | 持平 |
| 监督成本 | $T_{\text{monitoring}}$ | 中（管理层） | 低（CCR 自动化记录 + 模块验收） | 策元优势 |
| 适应成本 | $T_{\text{adaptation}}$ | 高（科层决策慢） | 低（主权节点自治） | 策元优势 |
| 层级管理成本 | $M_{\text{hierarchy}}$ | 高 | 0（无层级） | 策元优势 |
| 代理/政治成本 | $M_{\text{politics}}$ | 高 | 中（NR 博弈风险） | 未知 |
| 内在动机增益 | $I_{\text{autonomy}}$ | 负面（不投入） | 正面（主权激励） | 策元优势 |
| 冷启动成本 | $S_{\text{bootstrap}}$ | 低-中（公司注册即运营） | 高（需积累 NR + CU + VT 生态） | 公司优势 |

---

### 5.3 Benkler 2002 — Coase's Penguin 与 Peer Production 效率条件

#### 核心引用

| # | 作者 | 标题 | 年份 | 出处 | 关键公式/结论 |
|---|------|------|------|------|-------------|
| 5.3.1 | Benkler, Y. | "Coase's Penguin, or, Linux and the Nature of the Firm" | 2002 | *Yale Law Journal* 112:369-446 | **核心论断**: Peer production 的出现条件——当 (1) 生产可模块化、(2) 模块粒度足够小、(3) 集成成本足够低 时，commons-based peer production 优于公司和市场 |
| 5.3.2 | Benkler, Y. | *The Wealth of Networks: How Social Production Transforms Markets and Freedom* | 2006 | Yale University Press | **三模式**: 公司制（基于产权和合同）、市场制（基于价格信号）、社会生产（基于社会规范和非货币激励）。社会生产在信息产品领域的效率条件 |
| 5.3.3 | Benkler, Y., Shaw, A., & Hill, B.M. | "Peer Production: A Form of Collective Intelligence" | 2015 | *Handbook of Collective Intelligence* (MIT Press) | 更新的综述：peer production 在哪些领域有效（软件、百科全书）和无效（硬件制造、资本密集型产业） |

#### Benkler 效率条件（Peer Production 优于公司的三项前提）

| 条件 | Benkler 原文 | CONC 中的实现 |
|------|-------------|-------------|
| **模块化** (Modularity) | 生产可以分解为小的、独立可完成的模块 | 任务令（TO）+ 模块化任务设计 |
| **粒度** (Granularity) | 模块小到个人可以用业余时间完成 | 微任务令 + CU 粒度计量 |
| **低集成成本** (Low Integration Cost) | 将模块集成为最终产品的成本低 | AI 辅助代码审查 + 自动测试 + PCP 质量门 |

#### Benkler 成本比较框架

社会生产（Peer Production）的总成本：

$$C_{\text{Peer}} = C_{\text{search}} + C_{\text{integration}} + C_{\text{motivation}} + C_{\text{governance}}$$

而当 $C_{\text{Peer}} < \min(C_{\text{Firm}}, C_{\text{Market}})$ 时 peer production 占优。

| 成本项 | 公司 | 市场 | Peer Production | CONC 策元 |
|--------|------|------|-----------------|----------|
| 搜索/匹配 | 中 | 高 | 低 | 低（NR + 智契） |
| 集成 | 低 | 高 | 中-高 | 中（AI 辅助降低） |
| 激励 | 工资 | 价格 | 非货币激励 | 混合（CU + NR + VT） |
| 治理 | 层级 | 法律 | 社会规范 | CCR + PCP 协议化 |

---

### 5.4 已知经验数据

#### 公司管理成本数据

| 发现 | 数据 | 来源 |
|------|------|------|
| 管理层占总员工的比例 | 美国 Fortune 500: 管理层比例约 10-15% | Bureau of Labor Statistics |
| 管理成本占收入比 | 3-15%（行业差异大） | 各公司年报 |
| 代理成本估计 | 3-8% 公司价值（因管理层和股东利益不一致造成的损失） | Jensen & Meckling (1976) |
| 大公司内部沟通成本 | 员工平均每周花 6 小时在内部会议和邮件上（占总工时的 15%） | McKinsey (2012) |
| 招聘成本 | 平均 $4,000-7,000/人（入门级），$10,000-30,000/人（专业/技术岗） | SHRM (2022) |

#### Peer Production 效率数据

| 发现 | 数据 | 来源 |
|------|------|------|
| Linux 的开发效率 | 无单一公司可以复制 Linux 的开发速度和代码质量 | Benkler (2002) |
| Wikipedia vs Britannica | Wikipedia 错误率 4/条目 vs Britannica 3/条目（大致相当） | Giles, J. (2005) *Nature* 438:900-901 |
| 开源软件的商业价值 | 全球开源软件的经济价值估计 $8.8 万亿（如果闭源重写的成本） | Harvard Business School (2024) |
| Peer production 失败领域 | 硬件制造、基础设施、军事、医疗手术 | Benkler et al. (2015) |
| AI 辅助编码的效率提升 | GitHub Copilot 用户编码速度提升 55% | GitHub Copilot 研究 (2022) |
| 远程/自组织团队的产出 | 远程办公生产力 +13%（vs 办公室）；但创新 -23%（因缺乏即兴互动） | Bloom et al. (2015); Yang et al. (2022) *Nature Human Behaviour* |

#### Open Source vs Company 的成本比较案例

| 项目 | 开源开发成本 | 如果闭源重写成本 | 节省比 |
|------|-----------|---------------|--------|
| Linux Kernel | ~$1.4B (社区自报估时) | ~$14.7B | 10:1 |
| Apache HTTP Server | ~$2.0M (历年贡献) | ~$20M | 10:1 |
| Wikipedia (英文版) | ~$50M/年 (运行成本) | ~$6.8B (如果付费撰写的成本) | 136:1 |

数据来源：Wheeler, D.A. (2022) "Linux Kernel SLOC Count"; Wikipedia Foundation 年报

---

### 5.5 数据缺口

- **缺口 5.1**: "策元"这一具体组织形态的成本数据不存在。目前只能从 (a) 开源社区、(b) DAO、(c) 自管理公司（Gore, Morning Star）中类比推断。
- **缺口 5.2**: AI 驱动的自动化匹配（智契）对搜索成本的降低幅度没有精确量化。Copilot 的 55% 效率提升来自编码环节，而非团队匹配环节。
- **缺口 5.3**: 内在动机增益 $I_{\text{autonomy}}$ 的货币化等效值没有可靠的测量方法。Deci & Ryan 的 SDT 提供了方向性推测（内在动机 > 外在动机在创造性任务中），但缺乏具体数值。
- **缺口 5.4**: 策元的最小有效规模（Minimum Efficient Scale, MES）——在什么大小以下的策元无法有效运作？Coase 理论没有提供这个数值。

---

## 综合文献交叉索引

### 按模型分类的作者-主题矩阵

| 作者 | 模型一 | 模型二 | 模型三 | 模型四 | 模型五 | 核心贡献 |
|------|:----:|:----:|:----:|:----:|:----:|---------|
| Coase, R.H. (1937, 1960) | — | — | — | — | ● | 公司边界理论 |
| Williamson, O.E. (1975, 1985) | — | — | — | — | ● | 交易成本维度 |
| Benkler, Y. (2002, 2006) | ○ | — | — | — | ● | Peer production 效率条件 |
| Ostrom, E. (1990, 2010) | ● | — | — | — | ○ | 公地治理八原则 |
| Axelrod, R. (1981, 1984) | ● | — | — | — | — | TFT 与合作演化 |
| Fehr, E. & Gächter, S. (2000, 2002) | ● | — | — | — | — | 利他惩罚的实验证据 |
| Fudenberg & Maskin (1986) | ● | — | — | — | — | Folk Theorem |
| Diamond & Dybvig (1983) | — | ● | — | — | — | 银行挤兑模型 |
| Klages-Mundt et al. (2020) | — | ● | — | — | — | 稳定币系统风险 |
| Spence, M. (1973) | — | — | ● | — | — | 信号博弈 |
| Douceur, J.R. (2002) | — | — | ● | — | — | Sybil 攻击 |
| Albert & Barabási (2000) | — | — | — | ● | — | 无标度网络鲁棒性 |
| Cohen et al. (2000, 2001) | — | — | — | ● | — | 渗透阈值公式 |
| Kleinbaum, A.M. (2012) | — | — | — | ● | — | 组织邮件网络 |
| Nowak & Sigmund (1993) | ● | — | — | — | — | Pavlov 策略 (WSLS) |

● = 核心贡献 | ○ = 间接相关 | — = 不直接相关

---

### 按学科分类的期刊和会议

| 学科 | 核心期刊/会议 | 相关模型 |
|------|------------|---------|
| 博弈论 | *Econometrica*, *AER*, *JET*, *GEB* | 模型一 |
| 实验经济学 | *AER*, *QJE*, *Experimental Economics* | 模型一、三 |
| 金融工程/DeFi | *ACM AFT*, *FC*, *SSRN* — DeFi 安全/经济学 | 模型二 |
| 信息经济学 | *QJE*, *JPE*, *JEL*, *RES* | 模型三 |
| 网络科学 | *Nature*, *Science*, *PNAS*, *PRE*, *Physica A*, *Social Networks* | 模型四 |
| 交易成本经济学 | *Economica*, *JLE*, *JEP*, *Organization Science* | 模型五 |
| 计算机科学/安全 | *IEEE S&P*, *SIGCOMM*, *WWW*, *CSCW* | 模型三 (Sybil), 模型四 |

---

## 已知数据缺口汇总

### 高优先级缺口（建模前必须关注）

| # | 缺口 | 影响模型 | 严重度 | 建议行动 |
|---|------|---------|--------|---------|
| G-1 | CCR+NR+友好退出 组合激励下的群体合作行为数据 | 模型一 | 🔴 高 | 设计 ABM 仿真参数扫描；将来可做人机混合实验 |
| G-2 | VT 作为内生资产的价格波动率对 ALP 稳定性的影响 | 模型二 | 🔴 高 | 使用合成数据 + Monte Carlo 仿真探索参数空间 |
| G-3 | NR 作为多维度信号（任务质量+协作+评审）的分离均衡条件 | 模型三 | 🔴 高 | 参考 SO/GitHub 数据建模，但需适配多维信号 |
| G-4 | "智权体+策元" 双层二分图在定向攻击下的渗透阈值 | 模型四 | 🔴 高 | 使用 ABM 仿真 + 解析近似；参考二分图配置模型 |
| G-5 | 策元 vs 公司的定量成本函数参数估计 | 模型五 | 🔴 高 | 从开源社区和自管理公司数据外推；使用敏感性分析 |

### 中优先级缺口

| # | 缺口 | 影响模型 | 严重度 | 建议行动 |
|---|------|---------|--------|---------|
| G-6 | AI 生成内容对 NR 信号可靠性的污染效应 | 模型三 | 🟡 中 | 模拟 Sybil+AI 组合攻击场景 |
| G-7 | Folk Theorem 在 LLM-based Agent 博弈中的有效性 | 模型一 | 🟡 中 | ABM 中使用不同理性水平的 Agent |
| G-8 | 多抵押品联合清算风险数据 | 模型二 | 🟡 中 | 参考 MakerDAO 多抵押品升级的治理讨论 |
| G-9 | "桥接策元" 在跨 HA 策元间的作用机制 | 模型四 | 🟡 中 | 使用 CONC 仿真数据识别桥接策元 |
| G-10 | 内在动机增益的货币化等效值 | 模型五 | 🟡 中 | 行为经济学实验（与模型三交叉） |

---

## 附录 A：检索方法论

### 数据来源

- **学术搜索引擎**: Google Scholar, Semantic Scholar, arXiv, SSRN, JSTOR
- **DeFi 数据**: MakerDAO 治理论坛, Liquity 文档, CoinGecko, DeFi Llama
- **DAO 数据**: DeepDAO, Tally, Snapshot, al-Shaikh et al. (2023)
- **网络科学数据**: Stanford SNAP, KONECT, Newman 的复杂网络数据集
- **组织研究**: Harvard Business School 案例库, McKinsey 报告, Gallup 数据

### 文献筛选标准

- **纳入**: (a) 高引用经典论文 (>500 cites), (b) 直接相关的近期研究 (2018-2024), (c) 有可参数化变量的实证研究
- **排除**: (a) 纯理论模型无经验验证且与 CONC 不直接相关, (b) 博客/白皮书除非是 DeFi 协议的核心文档, (c) 非英文文献（中文文献仅通过翻译纳入）

### 局限性

1. 本参照文档基于 AI 代理的知识库检索，可能存在遗漏的近期文献（尤其是 2025 年后发表的工作）
2. DeFi 领域的"经典论文"概念与传统学术不同——协议白皮书和实践数据往往比学术论文更具参考价值
3. CONC 的五个模型是全新的组织结构，无法找到完全对应的历史先例——本参照文档提供的是**最接近的学术基础**
4. 部分关键参数（如 NR 衰减率、ALP 熔断阈值）没有经验数据，需要在阶段 3（模型构建）中使用参数扫描和敏感性分析来探索

---

## 附录 B：为 theory-architect 的交接说明

### 五个模型与现有学术基础的关系

| 模型 | 学术成熟度 | 与 CONC 的适配难度 | 关键参考 |
|------|----------|------------------|---------|
| 模型一（博弈论） | ★★★★★ 高度成熟 | 中（需添加 CCR/NR 参数） | Fehr & Gächter (2000), Ostrom (1990) |
| 模型二（金融工程） | ★★★★☆ 较成熟 | 高（VT 无历史数据） | Diamond & Dybvig (1983), Klages-Mundt et al. (2020) |
| 模型三（信号博弈） | ★★★★★ 高度成熟 | 中（多维 NR 信号） | Spence (1973), Tadelis (2016) |
| 模型四（渗透理论） | ★★★★★ 高度成熟 | 中（双层二分图） | Albert & Barabási (2000), Newman et al. (2001) |
| 模型五（交易成本） | ★★★★★ 高度成熟 | 高（策元无历史成本数据） | Coase (1937), Benkler (2002) |

### 建议的理论构建顺序

1. **先建模型四**（网络结构）——它是所有其他模型的基础层
2. **再建模型三**（NR 信号）——信号质量决定模型一和模型五的输入
3. **同时建模型一和五**——合作均衡和成本边界相互制约
4. **最后建模型二**（ALP 稳定）——经济层的稳定性检验

---

*数据构建完成日期: 2026-05-14*
*状态: 初稿，等待 theory-architect 接收并开始模型构建（阶段 3）*
