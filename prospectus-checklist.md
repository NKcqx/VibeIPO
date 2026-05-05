# Prospectus Deep-Read Checklist

Use after Step 4 of SKILL.md when the user wants a thorough reading.

## Mandatory chapters (in reading order)

1. **概要 (Summary)** — fastest read of the whole story; note management's chosen framing.
2. **风险因素 (Risk Factors)** — read ALL bullets; the first 3–5 are usually the bankers' admission of the worst risks.
3. **行业概览 (Industry Overview)** — note the 3rd-party consultant (CIC/Frost & Sullivan); their TAM/CAGR figures are paid-for.
4. **业务 (Business)**
   - Top 5 customers/suppliers tables.
   - Production capacity & utilization.
   - Geographical revenue split.
5. **财务资料 / MD&A**
   - Revenue by segment, GM by segment.
   - Working capital cycle (AR/AP/inventory days).
   - One-off items embedded in "adjusted" metrics.
6. **历史、发展及公司架构** — pre-IPO investor entry prices (cheap basis = supply pressure post-lockup).
7. **股本 / 主要股东** — pre-IPO ownership %, lock-up periods, share-incentive overhang.
8. **未来计划及所得款项用途** — % split tells you the actual stage of the company.
9. **包销 / 配售** — cornerstones with lock-up duration.

## Red flags to scan for

- "估值未确定" / 多次延长上市时限 / 多次失效后重新递表.
- 应收账款增速远快于收入.
- 经营性现金流多年为负，靠融资输血.
- 关联交易占收入比例不低.
- 招股书内出现 "我们尚未盈利" 或 "可能持续亏损" 在多处重复.
- Pre-IPO 投资者最近一轮入股价显著低于 IPO 中位数 → 上市即套利.
- 主要客户为关联方 / 同一控股股东体系内公司.
- R&D % 显著低于行业均值（自称科技公司时尤其要追问）.
- 多次更换审计师或保荐人.

## Cornerstones quality scoring

For each cornerstone, score by type, then weight by HK$ amount:

| Type | Score | Examples |
|---|---|---|
| Top-tier long-only fund | +2 | Hillhouse 高瓴, Aspex, Eastspring, Mirae Asset, M&G |
| Sovereign / pension fund | +2 | GIC, Temasek, CalPERS |
| Sector-specialist fund (medical / tech / consumer) | +2 | OrbiMed 奥博, Lake Bleu, Loyal Valley |
| **顶级互联网消费基石（特殊正权重）** | **+3** | **腾讯 / 字节 / 美团龙珠 / 红杉中国 / 博裕**（消费品 IPO 历史命中率 >70%；2097 蜜雪、6181 老铺验证）|
| Strategic industry partner (real synergy) | +1 | Alibaba Cloud for AI, Bayer for biotech, Microsoft for cloud |
| Government industry guidance fund | 0 | 亦庄政府, 大湾区基金, 国家产投 |
| Existing pre-IPO investor adding (defensive) | 0 to -1 | indicates lack of new-money demand |
| Unknown SPV / one-off shell | -2 | likely "rent-a-cornerstone" |
| Related party / controlled by founder | -2 | self-orchestrated demand |

### Aggregate signals

| Pattern | Interpretation |
|---|---|
| 1 cornerstone only | ⚠️ Weak — institutional demand thin |
| 3+ cornerstones, mix of types | ✅ Healthy book |
| >50% from top-tier long-only | ✅ Strong endorsement |
| >40% from government / industry funds | 🟡 Policy / strategic narrative, not market validation |
| >30% from related parties | ❌ Self-orchestrated, discount the demand signal |
| Lock-up shorter than 6 months | ❌ Unusual — possible quick exit |

### Worked examples

- **01609 天星医疗**: 3 cornerstones, JSC (govt 0) + 奥博 (specialist +2) + 大湾区 (govt 0). Mixed signal — OrbiMed adding is meaningful, but lack of long-only is weakness. **Net: 🟡**
- **01236 乐动机器人**: 1 cornerstone only (康成亨远景), unknown profile. **Net: ⚠️**
- **01187 可孚医疗**: 12 cornerstones including 蓝思（产业关联）+ 一批专业资管。**Net: 🟢**
- **01879 曦智科技**: 21 cornerstones 含阿里 + 淡马锡。需求侧 ✅，但 6 个月锁仓后供给冲击大。**Net: 🟡**（数量信号正反皆有）
- **06810 商米科技**: 2 cornerstones, 都不是顶级长线。蚂蚁/美团/小米作为 Pre-IPO 股东未在基石加注 = 弱信号。**Net: 🟡**
- **2097 蜜雪冰城**: 5 cornerstones, M&G + 红杉 + 博裕 + 高瓴 + 美团龙珠 = 全部顶级（含 2 个顶级互联网消费基石 +3）。**Net: 🟢🟢**（教科书级强信号）
- **6181 老铺黄金**: 含富达国际 + 黑石。基本面已是品类重定义（Step 3 触发），强基石进一步背书。**Net: 🟢**
- **2533 黑芝麻智能**: 2 家产业方共 USD 990 万，单家 < USD 600 万；公开发售仅 1.52× 超购同步弱。**Net: ❌**（教科书级需求不足）

## 估值锚速查（防止把硬件公司贴 SaaS 估值）

不同业务模型应使用不同估值倍数区间作锚：

| 业务模型 | PS 区间 | PE 区间 | 例子 |
|---|---|---|---|
| 纯硬件（标准化产品）| 1.5-3× | 15-25× | Verifone, Zebra, 鱼跃医疗 |
| 硬件 + 配套软件 | 3-5× | 25-40× | 商米、Toast 早期 |
| 解决方案商（含部署服务）| 3-6× | 30-50× | Symbotic, ServiceTitan |
| SaaS（标准订阅）| 5-10× | 40-80× | Salesforce, Workday |
| AI 基础设施 / 半导体 | 10-30× | (大多亏损)| 曦智、Lightmatter |
| 已盈利国防 / 关键基建 | 5-15× | 30-50× | HawkEye 360, Palantir |
| 数据中心 REIT | 5-10× | 25-40× | Equinix, Digital Realty |

如果 IPO 估值打到比对应区间高一档（e.g. 硬件公司给到 SaaS 估值），列为 🔴 估值风险。
