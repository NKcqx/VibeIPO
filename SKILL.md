---
name: hk-ipo-analysis
description: Analyze Hong Kong IPO (new share) listings end-to-end and produce a retail-investor-friendly subscription decision memo. Use when the user mentions a HK stock code in IPO/招股 phase, asks "要不要认购/打新", references 招股书/招股章程/招股价/暗盘/破发/孖展, shares an IPO prospectus PDF or hkexnews link, or asks to evaluate any "(待)上市" Hong Kong company. Covers: locating the prospectus on HKEX disclosure (申请版本 + 正式招股章程), pulling deal terms (price range, lot, entry fee, timetable, cornerstones, clawback) from etnet/AASTOCKS/sina, parsing prospectus financials (revenue, margin, cashflow, customer concentration), building a peer-PS/PE comparison, structuring risk factors, ending with an explicit "if I were the user, would I subscribe" stance, and giving post-listing position management rules. Not for already-listed seasoned equities — for those use ordinary equity research instead.
---

# HK IPO Analysis

A repeatable workflow for evaluating a Hong Kong new-share offering and giving the user a clear subscription stance — not just a summary.

## When to use

Trigger on any of:
- A 4–5 digit HK stock code in IPO window (e.g. `01236`, `01609`, `00100`).
- User shares a prospectus PDF or hkexnews link.
- Mentions: 招股 / 招股书 / 招股章程 / 招股价 / 入场费 / 每手 / 暗盘 / 破发 / 孖展 / cornerstone / 基石 / clawback / 回拨 / 国际配售.
- Question shape: "要不要认购 X"、"分析下这只新股"、"打新 X"、"X 上市能不能买".

If the company is **already listed and seasoned** (post-IPO with normal trading history), this skill is the wrong tool — fall back to standard equity analysis.

## Workflow checklist

Copy this checklist and tick as you go:

```
- [ ] Step 0: Time-window gate — is the public offer still open?
- [ ] Step 1: Lock down deal terms (price, lot, fee, timetable, structure, greenshoe)
- [ ] Step 2: Locate AND DOWNLOAD the prospectus PDF locally
- [ ] Step 3: Business + industry positioning + narrative-claim verification + 品类重定义检查
- [ ] Step 3.5: Pre-IPO history check (prior failed IPOs, founder cash-out, valuation anchor)
- [ ] Step 4: Financial track record (revenue, margin, cashflow, R&D, 同店模型 if 线下零售)
- [ ] Step 5: Concentration & dependency risks (clients/suppliers + 客户对称性)
- [ ] Step 6: Implied valuation + peer comparison + 主题进度条
- [ ] Step 7: Risk structure — single-issue dealbreaker scan FIRST, then 4×3 matrix
- [ ] Step 8: Subscription stance using the decision rubric
- [ ] Step 9: Post-listing position management rules (核心仓/交易仓 + 阶梯止盈 + 复评 trigger)
```

Do not skip steps. If a step's data isn't available, write "未披露/未取得" rather than fabricating.

### Helper scripts (optional, faster than manual web fetches)

```bash
# Fetch deal terms from etnet + AASTOCKS, output JSON-ish table
scripts/fetch_ipo_terms.sh <code>            # e.g. scripts/fetch_ipo_terms.sh 01609

# Find latest prospectus URL on hkexnews and download to ./prospectus/
scripts/find_prospectus.sh <code> [zh|en]    # default: zh
```

If scripts fail, fall back to manual etnet/AASTOCKS/hkexnews URLs.

## Step 0 — Time-window gate

Compare today against the IPO timetable from etnet/AASTOCKS:

| Bucket | What changes |
|---|---|
| **⏳ Pre-S-1 / Pre-招股书**（公司还没递表）| 远期前瞻分析；只能给"watching only"，**禁止给立场或仓位建议**；记录关键追踪节点（路演、analyst day、SEC 关键词） |
| **🟦 Before public offer opens** | 标准认购分析；强调入场费/孖展/基石数学 |
| **🟢 Within public offer window** | 标准认购分析；同上，加上中签率估算 |
| **🟡 After public offer closed but before listing day** | **Reframe**：认购不可能；问题变成"暗盘是否追入" / "上市首日是否买"。用暗盘报价（不是 IPO 价）评估追价风险 |
| **🟠 Already listed (within 6 months)** | 半新股阶段；分析变成"现在追入 vs 等基石解锁"；考虑 lockup expiry 时间表 |
| **🔴 Already listed (>6 months, seasoned)** | Wrong skill；换标准 equity research |

State the bucket explicitly at the top of the report. Do not pretend the user can still subscribe when they can't.

## Step 1 — Deal terms

Pull these in parallel from at least **two** independent sources (etnet, AASTOCKS, sina/east money):

| Field | Why it matters |
|---|---|
| **Deal type** | 普通 IPO / 18A（未盈利生物科技）/ **18C（未商业化特专科技；含港股 18C 第 N 家序号）** / SPAC / Roll-up — 不同类型估值锚和监管门槛差别巨大 |
| Price range (HK$ low–high) | Defines max subscription cost and implied market cap |
| **价格区间收窄方向** | 定价**上限**定 = 需求强；定价**中位** = 中性；定价**下限**或**收窄**至下半区 = 需求弱（**不一定基本面差**，配合 Step 6 主题进度条解读） |
| Lot size + entry fee | Decides minimum capital + retail accessibility |
| **入场费档位** | < HK$3,000 = 散户友好（高暗盘活跃度、低中签率）；3K–10K = 中等；>10K = 偏机构 |
| Offer structure (HK public + international) | Float thinness, retail allocation pool |
| Cornerstones (names, amount, lock-up, **type score**) | Quality of demand + post-lockup overhang — 用 prospectus-checklist.md 的评分表 |
| Clawback table | How much retail share scales up if oversubscribed |
| **Greenshoe / 绿鞋** | **有/无 + 上限**。无绿鞋 = 上市头 30 天裸奔，列为 🔴 |
| Use of proceeds (% split) | Reveals stage: R&D-heavy / capacity / refinance / M&A |
| Timetable | 招股期 / 定价日 / 暗盘 / 上市日 |
| 孖展超购倍数（招股期内每日跟踪） | 中签率 + 散户情绪温度 |
| **公开发售超购倍数** | 用于 Step 7 dealbreaker 扫描第 9 项；< 5× 是教科书警告 |
| **A+H 标的标识** | A 股代码 + AH 折价% — 折价是独立估值维度，不混在估值评分里 |
| **Director Share Program / 用户社区配售机制**（美股 IPO 特有）| 例如 Reddit 把 1.76M 股分配给 mods 和老用户 — 是真实的 community moat 信号，不是噱头；记录配售比例和锁定期 |

Cite the source for each number. If two sources disagree, flag it.

### ⚠️ 需求过热反指标

很多人以为"超购倍数越高 = 越值得参与"。实际上：

| 信号 | 隐含含义 | Stance 影响 |
|---|---|---|
| 超购 > 3000 倍 | 中签率极低（< 1 手 / 10 万）+ 上市当天获利盘巨大 | **降低预期持有时长** |
| 基石数量 > 15 家 | 6 个月后供给冲击大 | **避免长期持仓** |
| 公开发售 100% 触发回拨上限（50%） | 公开发售部分会被超额申购摊薄 | 中签率进一步下降 |

需求过热不等于"基本面好"——它经常意味着"故事被一次性兑现"，参考 01879 曦智案例。

## Step 2 — Prospectus retrieval

Try in this order:

1. **Run helper**: `scripts/find_prospectus.sh <code> zh` — searches hkexnews and downloads to `prospectus/<code>_c.pdf`.
2. If helper fails, **HKEX disclosure direct PDF** at `https://www1.hkexnews.hk/app/sehk/<year>/<listing-id>/documents/sehk<YYMMDD><nnnnn>_c.pdf` — verify with `curl -sI` returning HTTP 200 and `content-type: application/pdf`.
3. If unknown, web-search `site:hkexnews.hk <company name in 繁體> 招股章程` and `"sehk<YY>" pdf`.

### ⚠️ Always download to local immediately

HKEX replaces application proofs with newer versions without notice — the URL you cite today may 404 tomorrow (this happened in the 01609 case). The helper script writes to `prospectus/<code>_<lang>.pdf`; if going manual:

```bash
curl -sL "<url>" -o prospectus/<code>_<lang>.pdf
```

### Versions

- **Application Proof (草擬本)**: business/financials/risk are real; price/share fields show `[編纂]`. Acceptable for everything except citing final 招股价.
- **Post-Hearing Information Pack (PHIP)**: closer to final.
- **Formal Prospectus (招股章程)**: registered with Companies Registry; required for citing the final 招股价.

Save the URL **and** the local copy. State explicitly which version you read and the file's `last-modified` date.

## Step 3 — Business & positioning

Extract from prospectus chapters 「概要」「业务」「行业概览」:

- **What does the company actually sell?** (avoid pitch deck language)
- **Where in the value chain?** (component / module / system integrator / brand)
- **Market size and the company's stated share** — note the methodology (revenue-based? unit-based? niche-defined?).
- **Who are the competitors named in 招股书 itself**, not the friendly comp set the bankers picked.
- **Geographic mix** (CN domestic vs overseas) — affects FX, regulatory exposure, premium.

### 🔍 Narrative-claim verification (mandatory sub-check)

For every "global/China #N" or "largest/leading" claim:
1. Find the **slice definition** in the industry consultant report (CIC / Frost & Sullivan / iResearch). The narrower the slice, the weaker the moat.
2. Cross-check with **total market share**. Common pattern: "China #1 by visual-perception-tech-core revenue" = 1.6% total share. Discount accordingly.
3. Check **gap to #2**. If <1pp, the ranking is fragile.

For every self-described positioning (e.g. "tech company", "全球化"), pull the supporting metric:
- "Tech company" → check R&D % of revenue vs sector average. <50% of sector avg = self-claim contradicted.
- "全球化" → check overseas revenue %.
- "Innovation-driven" → check patent count growth + R&D headcount ratio.

Flag any **self-claim vs reality contradiction** and carry it to Step 7 dealbreaker scan.

### 🚀 Category-redefinition check (P0 — added after 老铺 backtest)

某些公司**不是在已有品类里做老二老三，而是在重新定义品类**——这种情况会出现"经营模型与同行有数量级差异"，必须在 Step 6 切换估值锚，不能机械按老品类 PE/PS 判断。

判别问题（任一为「是」则触发再定价提醒）：

| 问题 | 阈值 | 含义 |
|---|---|---|
| 单店 / 单产品 / 单 SKU 收入是同行的几倍？ | **≥ 3×** | 经营模型已超出同品类 |
| 客单价是同行的几倍？ | **≥ 3×** | 已经在另一个价格带 |
| 同店增长 / 单 SKU 增长是同行的几倍？ | **≥ 5×** | 不是周期共振，是真实再定价 |
| 净利率是同行的几倍？ | **≥ 2×** | 商业模型质变 |
| 公司自我定位是否使用「文化奢侈品」「品类开创者」「new luxury」「重新定义 X」等表述？ | 关键词命中 | **市场可能未识别**（这种公司 招股期常被错估）|

**触发后的动作**：
- 在 Step 6 估值章节明确写「这不应按 <老品类> 估值，参考锚为 <新品类> 同行 PE/PS X×」。
- 在 Step 8 stance 评分卡的「估值合理性」一栏给 ✅✅（双勾），并在 Step 9 持仓管理的核心仓比例上限上调（普通 30% → 50%）。
- 在最终立场里**显式承认这是潜在 5×+ 标的**，避免给"中庸立场"。

## Step 3.5 — Pre-IPO history

Often buried across prospectus chapters 「歷史、發展及公司架構」+「主要股東」+「股本」, but decision-critical. Check:

| Item | Where to look | Why it matters |
|---|---|---|
| Prior IPO attempts (A-share / HK previously) | 「歷史」section + web search "<company> 撤单 OR 失效" | Sponsor withdrawal usually signals substantive issues; **policy-driven 撤回 ≠ sponsor 主动 = 不触发 dealbreaker** |
| Founder / co-founder share transfers in last 24 months | 「歷史」+ 「主要股東」share-transfer table | Large pre-IPO cash-out (>50% of original holding) is a single-issue dealbreaker |
| Controlling shareholder changes | 「主要股東」 | Recent change of control = risk |
| Pre-IPO last-round valuation | 「歷史」最新一輪融資 valuation per share | 见下方「估值倒挂分情景」 |
| Sponsor / auditor changes | Cover + 「申請文件」 | Multiple changes are a red flag |
| Application lapses (失效) | hkexnews submission history | Multiple lapses (>2) → drafting / disclosure quality issues |

State each finding explicitly. If clean, write "无重大 Pre-IPO 红旗".

### 💡 Pre-IPO 估值倒挂分情景判断 (P1 — added after Reddit backtest)

如果 IPO 价格 < 最近一轮 Pre-IPO 估值（即倒挂 / down-round），**不要一刀切判定为负面信号**。要分情景：

| 情景 | 信号特征 | 判断 |
|---|---|---|
| **A. 真打折**（基本面恶化）| 倒挂 + 收入增速放缓 + 毛利压缩 + 用户流失 | 🔴 谨慎；倒挂幅度反映真实价值损耗 |
| **B. 板块系统性折价**（市场冷淡）| 倒挂 + 同板块多家公司估值同步下移 + 自身基本面稳定 | 🟡 中性；可视为 IPO 折扣 |
| **C. 弹簧效应**（基本面改善 + 题材重燃）| 倒挂 + 收入增速回升 + 新催化（AI 题材 / 政策红利）+ 倒挂幅度被 IPO 后题材回潮快速抹平 | 🟢 **潜在反弹超调**，可能是 +3× 以上的机会（Reddit 案例） |

判别问题：「倒挂的根因是公司变差了，还是 Pre-IPO 投资人当时买贵了？」前者是真打折，后者是好机会。

## Step 4 — Financial track record

Build a small table from the prospectus 「财务资料」 / 「管理层讨论与分析」:

| Metric | FY-2 | FY-1 | FY (latest) | Interim | Trend? |
|---|---|---|---|---|---|
| Revenue | | | | | growth rate |
| Gross margin | | | | | up/down |
| Operating margin | | | | | |
| Net profit (IFRS) | | | | | |
| Adjusted net profit | | | | | esp. for biotech/AI |
| Operating cash flow | | | | | sign matters |
| R&D % of revenue | | | | | for tech |
| Cash & equivalents | | | | | runway |

Flag **inflection signals**: GM bottoming and turning up, OCF flipping positive, segment-mix shift driving margins.

### 🏪 线下零售 / 消费品的额外字段 (P1 — added after 老铺 backtest)

如果公司是 **brick-and-mortar 零售 / 餐饮 / 消费品** 标的，必须额外抓这几个字段——它们对未来增速的预测力远高于纯财务指标：

| Metric | 为什么关键 |
|---|---|
| **同店增长** (Same-store sales growth, SSSG) | 区分"开店扩张"和"真实需求"。**>50% 同店增长 = 极强信号**，可能是品类再定义（触发 Step 3 检查）|
| **单店年收入** (Avg revenue per store) | 与同行对比；高出 3-5× = 商业模型质变 |
| **客单价 / ATV** (Average transaction value) | 客单价远高于同行 = 不在同一个价格带，估值锚要换 |
| **门店数与门店密度** | 网络饱和度 + 区域天花板 |
| **会员复购率 / 客户留存率** | 长尾收入质量 |

如果这几项里有任意 2+ 触发「品类重定义」阈值，回到 Step 3 跑 category-redefinition check。

## Step 5 — Concentration & dependency risks

Mandatory pull from prospectus 「业务」 + 「风险因素」:

- Top 5 customers % of revenue (each year).
- Top 5 suppliers % of purchase.
- Single-product or single-region dependency.
- Related-party transactions of material size.
- Any pending litigation, regulatory probes, IP disputes.
- Subsidies / tax benefits as % of profit (if profit exists).

### 🔄 客户依赖对称性检查 (P1 — added after CRWV backtest)

Top-1 客户占比高（>50%）**未必**是单向依赖——要看双方切换成本是否对称：

| 维度 | 单向依赖（🔴）| 共生关系（🟡 / 🟢）|
|---|---|---|
| 客户切走的难度 | 容易（你是商品化供应）| 难（你是稀缺产能）|
| 客户的替代选择 | 多家可替换 | 少数几家或仅你一家 |
| 客户对你的认股 / 战略入股 | 无 | 有（说明客户也在锁定你）|
| 业务上下游捆绑 | 仅采购关系 | 联合研发 / 长期合同 / 共建数据中心 |
| 行业自身供需平衡 | 客户产能过剩 | **客户自身资源不足，反过来需要你**（CRWV vs Microsoft）|

**判断口径**：「如果你和客户翻脸，是你死得更快还是客户死得更快？」
- 你死得快 → 真单向依赖（🔴）
- 双方都很疼 → 共生关系（🟡）
- 客户死得更快 → 反向依赖优势（🟢，罕见但很强）

共生关系**不应触发 dealbreaker 第 4 项**（即使 Top-1 > 70%）。

## Step 6 — Implied valuation + peer comparison

1. Compute implied **market cap** at low / mid / high of the price range using **post-IPO total shares** (not just H-share float). Cross-check against etnet's 「上市市值」 figure.
2. Choose primary multiple:
   - Profitable + stable: **P/E** (use latest-year & forward).
   - Loss-making growth: **P/S** (forward 1–2 years).
   - Asset-heavy: **P/B**.
3. Build a 3–5 row peer table — **name peers explicitly**, list their HK code, recent market cap, latest revenue/profit, multiple. Note when picks deviate from prospectus's chosen peer set and why.
4. State: "the IPO is priced at X× vs peer median Y× → premium/discount of Z%".

### 📈 主题进度条检查 (P0 — added after CRWV / Reddit backtest)

如果公司处于一个明显的**宏观主题**（AI / 机器人 / 新能源 / 太空 / 量子等），不能只用同行 PS/PE 机械判断——必须先评估**主题阶段**：

| 阶段 | 特征 | 估值行为 | 判断口径 |
|---|---|---|---|
| **🌱 早期**（< 12 个月，第一波叙事）| 标杆公司刚上市；行业 capex 刚启动；同行少且估值波动剧烈 | PS / PE 会反复重估 1-3× ；**机械按当前同业中位估值会严重低估** | 给"等回调买"风险高，可能错过 3-5× 反弹 |
| **🔥 中期**（12-36 个月，主题铺开）| 多家公司上市；估值开始稳定；具体业绩开始检验叙事 | PS / PE 在一个区间震荡；机械同业对比可用 | 标准 Step 6 估值方法适用 |
| **📊 晚期**（> 36 个月，主题成熟）| 行业格局稳定；估值回归基本面；增量资金减少 | 纯基本面定价；同业平均可信 | 强调下行保护 |
| **❄️ 已退潮**（叙事破灭后）| 多家破发或下跌 50%+ ；新发行少 | 估值压到行业历史低位 | 反向机会 |

**判别参考**：
- 早期信号：**主题词在过去 6 个月新闻数 +500%+** / **同行公司不到 5 家上市** / **行业 capex 同比 +100%+**。
- 早期阶段对 IPO 立场的影响：**估值贵不要直接 Skip**，至少给"first-week observe"或小额申购，等下一波情绪。

参考 CRWV 案例：定价从 $47-55 弱化到 $40 看似负面，但 AI infra 主题处于早期，6 月行情翻 5× 印证了"早期主题 + 定价弱化 ≠ 长期看跌"。

## Step 7 — Structured risk factors

### 🚨 Single-issue dealbreaker scan (do this FIRST)

Each item below, if HIT, **caps position size at "1 lot lottery" regardless of other positives**. Run the scan explicitly and report ✅ HIT / ❌ pass for each:

| # | Dealbreaker | Threshold |
|---|---|---|
| 1 | Founder / co-founder cash-out > 50% of original holding within 24 months | e.g. 55% → 4.9% (天星案例) |
| 2 | Failed prior A-share/HK IPO with **sponsor unilateral withdrawal** (policy-driven 撤回 不算) | e.g. 科创板撤单 |
| 3 | Negative operating cash flow for 3+ consecutive years AND no clear inflection | OCF / revenue ratio worsening |
| 4 | Top-5 customer concentration > 70% AND rising **AND 单向依赖**（不对称）| 共生关系不触发，参考 Step 5 客户对称性检查 |
| 5 | Self-claim vs reality contradiction | e.g. "tech co" but R&D % < ½ sector avg (乐动案例) |
| 6 | Controlling shareholder changed within 24 months | governance instability |
| 7 | Multiple sponsor or auditor changes (>1) | drafting / due-diligence quality |
| 8 | Material undecided litigation > 50% of FY net profit (or LTM revenue if loss-making) | tail liability |
| 9 | **公开发售超购倍数 < 5×** AND 基石占比 < 30% AND 区间下限定价 | 三者同时 = 需求严重不足（黑芝麻案例：1.52× 超购）|

Report total dealbreakers HIT. **2+ HIT → no position larger than 1 lot, no margin, regardless of other axes.**

### 4×3 Risk matrix

Then group remaining risks (do not just list):

- **Deal-level**: pricing aggressiveness, float thinness, cornerstone lockup expiry, clawback uncertainty, broker margin financing risk, **greenshoe absent = 🔴**.
- **Company-level**: profitability not yet proven, GM compression, concentration, key-man, share-incentive dilution.
- **Sector / regulatory**: domestic policy (集采 / VBP / data), overseas data/IP/tariff, technology displacement.
- **Macro / market**: HSI sentiment, sector IPO pipeline crowding, recent comparable break-issue.

For each, mark severity **🔴 High / 🟡 Medium / 🟢 Low** with a one-sentence reason.

## Step 8 — Subscription stance (the decision rubric)

End every analysis with an explicit personal stance using this rubric. Do not hedge into uselessness.

Score each axis ✅ / ⚠️ / ❌:

1. **Valuation reasonableness** — is the implied multiple defensible vs peers + growth?（**先做 Step 6 主题进度条 + Step 3 品类重定义后再评分**）
2. **Quality of growth** — is revenue growth backed by margin expansion or just volume at falling price?
3. **Path to profit / cash** — is breakeven visible within 12–24 months on disclosed trajectory?
4. **Demand signals** — cornerstone quality, expected oversubscription, sector heat.
5. **Downside protection** — what's a realistic break-issue scenario, and can the user stomach it?
6. **A+H 折价**（仅 A+H 标的）— 折价 >30% 是独立安全垫，单独评分不混入"估值"。

Then commit to one of (HK 标准选项):

- **Skip** — risk/reward unattractive at this price.
- **One lot cash, treat as lottery** — story interesting but not high-conviction; cap at money you can lose entirely.
- **Multi-lot cash, no margin** — quality + price both acceptable.
- **Margin / 孖展** — only when conviction is high AND clawback math + interest cost work; usually rare.
- **Wait for post-listing entry** — fundamentals look good but IPO pricing leaves no margin of safety.

⚠️ 如果 Step 3 「品类重定义」检查 HIT，必须额外输出 **「潜在 5× 以上标的，建议核心仓上限上调到 50% 而非默认 30%」** 的提示——避免给「中庸立场」错杀。

### 🇺🇸 US IPO 分支

美股 IPO 散户参与机制不同（无"打新一手"概念），所以最终立场要写：

- **IPO Allocation 申购** — 仅当用户有 IPO Access（嘉信、富途美股、Robinhood IPO Access、Fidelity IPO 等）；按 1-2 lots 配额申购。
- **First-week observe** — 没有配额；上市第一周观察价格行为，开盘 +30% 内分批入；>+50% 等回调。
- **Wait for first earnings** — 等首份季报后再决定。
- **Skip** — 估值或基本面不符合标准。

如果命中 Step 1 的「Director Share Program / 用户社区配售机制」，在立场里加备注：「community moat 是真信号，提高对 retail oversubscription 的信任度」（Reddit 案例验证）。

### ⏳ 远期 IPO（Pre-S-1）分支

如果是远期 IPO（尚未递表 SEC / 港交所），**禁止给立场**。只能给：

- **Watching only** — 等 S-1 / 招股章程出来后按完整 8 步重跑。
- 列出关键追踪节点（路演、analyst day、SEC 关键词订阅、上游母体股价）。

Always state: "If it were my own money, I would [X] because [one-sentence reason]." This is a personal preference statement, not investment advice — make that disclaimer once at the end.

## Step 9 — Post-listing position management (added after backtest, P0)

立场不是分析的终点——上市后必须有持仓管理规则，否则避险了反而会错过反弹（CRWV 案例），或捕到大牛但没拿住（老铺案例）。

### 🎯 Tier the position

| 仓位类型 | 上限（占总仓） | 持有逻辑 |
|---|---|---|
| **核心仓**（Core）| 默认 30%；命中 Step 3 品类重定义则上限 50% | 长期持有，跟踪基本面季度变化；除非 dealbreaker 出现否则不动 |
| **交易仓**（Trade）| 70%（默认）/ 50%（核心仓上调时）| 按下方阶梯止盈规则操作 |

如果是 Skip 立场则不存在持仓管理；如果是 1 手 lottery 立场则全部归为核心仓（全亏接受）。

### 📐 Staged take-profit ladder（替代单一阈值）

不要写"+50% 落袋一半"这种单点规则，会在 +14× 标的上过早卖飞（老铺案例）。改用阶梯：

| 涨幅触发（vs 入场价）| 交易仓兑现比例 | 累计兑现 |
|---|---|---|
| +30% | 25% | 25% |
| +50% | 25% | 50% |
| +100% | 25% | 75% |
| +200% | 剩余全部 | 100% |
| +500% | — | （只剩核心仓继续滚动）|

核心仓**不在阶梯内**，只在以下事件出现时减仓：
- 首份季报增速 < 招股期承诺的 -30% 以上
- Step 3 品类重定义假设被推翻（同店增速回归同行水平）
- 单年涨幅超过 +500% 且估值已到行业极值

### 🔁 Mandatory re-evaluation triggers

任何一个发生时，必须回到 Step 6 重做估值 + Step 8 重出立场：

| Trigger | 频率 / 时点 |
|---|---|
| 跌破 IPO 价 -20% | 立即 |
| 基石解锁前 30 天 | 一次 |
| 首份季报发布 | 立即 |
| 上市满 6 个月 | 一次（特别针对定价弱化标的，如 CRWV）|
| 主题进度条阶段切换（早期 → 中期）| 触发即跑 |
| 重大新合约 / 新客户公告 | 立即 |

### Output format

Step 9 在最终报告里以 **「持仓管理建议」** section 出现，包括：

```
## 持仓管理建议
- 核心仓上限：X%
- 交易仓阶梯止盈表
- 复评 trigger 列表
- （首条触发后的预期动作模板）
```

## Output template

Use this structure for the final memo:

```
# <Company> (<code>.HK) — IPO 评估

## ⏱️ 时间窗口
[认购窗口内 / 已截止 / 已上市 — Step 0 bucket]

## 🎯 最终立场（如果是我）
[1-line action: 跳过 / 一手现金 / 多手现金 / 孖展 / 等上市后买]
[1-sentence reason]

## 一句话定位
[business in plain Chinese, no pitch words]

## 发行条款速查
[deal terms table from Step 1, with greenshoe explicit]

## 招股书来源
[URL + local file + which version + last-modified date]

## 业务与行业位置 + 行研话术核查 + 品类重定义检查
[Step 3 findings]

## Pre-IPO 历史
[Step 3.5 table or "无重大红旗"; 倒挂分情景]

## 财务轨迹
[Step 4 table + inflection commentary; 同店模型 if 线下零售]

## 集中度与依赖风险
[Step 5 bullets + 客户对称性判断 if 单一大客户]

## 估值与可比公司 + 主题进度条
[Step 6 implied market cap + peer table + 主题阶段判断]

## 风险结构化
[Step 7: 🚨 Dealbreaker scan (9 项) FIRST + 4×3 matrix]

## 认购立场详细评分
[Step 8 rubric table + chosen action + one-sentence reason]

## 持仓管理建议
[Step 9: 核心仓 / 交易仓上限 + 阶梯止盈表 + 复评 trigger]

[disclaimer line]
```

Put **time window** and **final stance** at the very top so the user can decide whether to read further.

## Anti-patterns

- ❌ Quoting招股价 from a single source without cross-check.
- ❌ Citing "global #1" without explaining the slice.
- ❌ Confusing Application Proof's `[編纂]` placeholders with "no price disclosed".
- ❌ Ending with "建议关注" or other non-committal banker speak — the user explicitly wants a stance.
- ❌ Using pre-IPO investor entry valuations as "fair value" anchor — they are not.
- ❌ Assuming retail clawback ratios — confirm from the actual prospectus's clawback table.
- ❌ 机械按同业 PS/PE 估值，忽略主题进度条阶段（CRWV 教训）。
- ❌ 看到「同行高出几倍的单店模型」仍按老品类估值（老铺教训）。
- ❌ 客户集中度高 = 单向依赖（共生关系不算，CRWV 教训）。
- ❌ Pre-IPO 倒挂 = 一定看跌（弹簧效应可能反弹超调，Reddit 教训）。
- ❌ 给完立场就完结，不输出持仓管理 / 复评 trigger（错过反弹的根因）。

## Additional resources

- Prospectus deep-read checklist + cornerstone scoring: see [prospectus-checklist.md](prospectus-checklist.md).
- HKEX disclosure URL patterns and probe commands: see [hkex-urls.md](hkex-urls.md).
- Worked case studies — see [cases/README.md](cases/README.md) for the index. Pick one HK + one US example before first real run to calibrate depth, tone, and stance discipline.
