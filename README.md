# VibeIPO

> 一个 Cursor Skill + 配套脚本，用于分析港股 / 美股 IPO 新股，输出散户友好的认购决策备忘录——不是投行式的「建议关注」。

📦 GitHub: [`NKcqx/VibeIPO`](https://github.com/NKcqx/VibeIPO)

> **为什么需要它**：典型港股 IPO 招股书 800-1500 页、招股窗口 3-5 个工作日、券商 App 一键孖展。信息密度高、时间压力大。本项目把可重复的 9 步流程编码成 AI Agent 能在 10-15 分钟跑完的工作流。

## Quick Start

```bash
# 1) Clone 仓库到本地（任意位置）
git clone git@github.com:NKcqx/VibeIPO.git ~/code/VibeIPO
cd ~/code/VibeIPO

# 2) 用 setup.sh 一键安装为 Cursor Skill（symlink 到 ~/.cursor/skills/）
./scripts/setup.sh
# → 自动创建 ~/.cursor/skills/hk-ipo-analysis -> 当前仓库
# → 自动 chmod +x scripts/*.sh

# 自定义安装位置：
./scripts/setup.sh --cursor-skills-dir /custom/path/to/skills

# 3) 打开 Cursor，自然语言触发 Agent：
#    「分析下 01609 天星医疗，要不要认购」
#    「01236 乐动机器人怎么样」
#    「这只新股的招股书在哪」
# Skill 会自动 invoke 并跑完 9 步流程

# 4) 也可以独立用脚本（不开 Cursor）
./scripts/fetch_ipo_terms.sh 01609                                  # 拉招股条款
./scripts/find_prospectus.sh 01236 https://www1.hkexnews.hk/.../sehk25120104095_c.pdf zh
```

## Repository layout

```
VibeIPO/
├── SKILL.md                       # 主 skill：9 步流程 + 决策评分卡 + 触发词
├── prospectus-checklist.md        # 招股书深读清单 + 基石质量打分表 + 估值锚速查
├── hkex-urls.md                   # 港交所披露易 URL 模式
├── README.md                      # 你正在看
│
├── cases/                         # 真实 forward case（Agent 学习用）
│   ├── README.md                  # 7 支案例索引 + 横向对比
│   ├── 01187-可孚医疗.md
│   ├── 01236-乐动机器人.md
│   ├── 01609-天星医疗.md
│   ├── 01879-曦智科技.md
│   ├── 06810-商米科技.md
│   ├── HAWK-HawkEye360.md
│   ├── Roze-SoftBank-AI.md
│   └── backtest/                  # 5 支历史 backtest 回归测试
│       ├── README.md              # backtest 命中率总览
│       ├── 2097-蜜雪冰城.md
│       ├── 2533-黑芝麻智能.md
│       ├── 6181-老铺黄金.md
│       ├── CRWV-CoreWeave.md
│       └── RDDT-Reddit.md
│
├── scripts/                       # 配套脚本（bash，仅依赖 curl）
│   ├── setup.sh                   # symlink 仓库到 ~/.cursor/skills/
│   ├── fetch_ipo_terms.sh         # 拉 etnet + AASTOCKS 招股条款
│   └── find_prospectus.sh         # 下载 + 验证 hkexnews PDF
│
├── blog/                          # 博客系列（讲方法论）
│   ├── 01-用-AI-Agent-辅助港股新股认购决策.md
│   ├── 02-案例对比-天星医疗-vs-乐动机器人.md
│   └── 03-Skill不能只跑不验-用5支历史IPO做回归测试.md
│
└── social/zhihu/                  # 知乎发布版
    ├── PUBLISH-NOTES.md
    └── 01236-乐动机器人.md
```

## What the Skill does

每次 Agent 跑 9 步流程：

| Step | 输出 |
|---|---|
| 0 | 时间窗口闸门——招股窗口现在还能不能下单？|
| 1 | 发行条款（招股价、每手、入场费、时间表、基石、**绿鞋**、A+H 折价）|
| 2 | 定位 + **立即下载**招股书 PDF 到本地（避免 hkexnews 替换 → 404）|
| 3 | 业务 + 行业位置 + **行研话术核查** + **品类重定义检查** |
| 3.5 | Pre-IPO 历史（撤单史、联创套现、估值锚、**倒挂分情景**）|
| 4 | 财务轨迹（收入、毛利、现金流、研发；线下零售加同店模型）|
| 5 | 集中度与依赖（前五大客户 / 供应商 + **客户对称性检查**）|
| 6 | 隐含估值 + 可比公司表 + **主题进度条**（早期 / 中期 / 晚期）|
| 7 | **9 项一票否决扫描**（先跑），然后 4×3 风险矩阵 |
| 8 | 认购立场评分卡 → 明确档位 |
| 9 | **持仓后管理**：核心仓 vs 交易仓分层 + **阶梯止盈** + 复评 trigger |

最终输出是把**时间窗口**和**最终立场**放最前面、再带支撑分析的备忘录。立场必须是以下之一（不允许「建议关注」）：

- **跳过** — 风险/回报不吸引
- **一手现金当彩票** — 故事有意思但确定性不够；上限 = 全亏接受
- **多手现金、不上孖展** — 质地 + 价格都 OK
- **孖展认购** — 罕见；必须高确定性 + 回拨数学 + 利息成本都跑得通
- **等上市后买** — 基本面好但 IPO 价没有安全垫

## Triggers

Skill 会自动 invoke 当你提到：

- 4-5 位港股代码处于 IPO 窗口（如 `01236`、`01609`、`00100`）
- 美股 IPO 代码 + S-1 文件 / SEC 链接
- 招股书 PDF 或 hkexnews 链接
- 关键词：招股 / 招股书 / 招股章程 / 招股价 / 入场费 / 每手 / 暗盘 / 破发 / 孖展 / cornerstone / 基石 / clawback / 回拨 / 国际配售
- 问题模板：「要不要认购 X」「分析下这只新股」「打新 X」「X 上市能不能买」

## Helper scripts

### `scripts/fetch_ipo_terms.sh <code>`

拉取 etnet 和 AASTOCKS 的 IPO 信息页，原始 HTML 存到 `./ipo_terms/<code>_<timestamp>/`，并把可解析字段（招股价、每手、入场费、关键日期、基石）打印出来。

```bash
./scripts/fetch_ipo_terms.sh 01609
# Name (etnet):     天星醫療 01609
# Price:            $98.50
# Lot:              50股
# Entry fee:        $4,974.67
# Key dates: 2026/04/24 ... 2026/05/05
# Cornerstones: JSC International / 奥博亚洲四期 / Mega Prime / Poly Platinum
```

### `scripts/find_prospectus.sh <code> [url] [zh|en]`

从 hkexnews 下载招股书 PDF 并保存元数据 sidecar（URL、状态、last-modified）。两种模式：

```bash
# Direct mode（推荐——给定 hkexnews URL，结果可靠）
./scripts/find_prospectus.sh 01236 https://www1.hkexnews.hk/app/sehk/2025/107918/documents/sehk25120104095_c.pdf zh

# Auto-search mode（best-effort；hkexnews IPO 页是 SPA 经常失败）
./scripts/find_prospectus.sh 01236 zh
```

输出：
```
prospectus/01236_zh.pdf         # PDF 本身
prospectus/01236_zh.meta.txt    # url + status + last-modified + fetched_at
```

**为什么要立刻下载**：HKEX 会无预警替换申请版本。今天能用的 URL 明天可能 404（开发期 01609 case 就遇到过）。

### `scripts/setup.sh`

创建 `~/.cursor/skills/hk-ipo-analysis` → 仓库的 symlink，让 Cursor Agent 能发现 skill。幂等。

## Reading order for first-time users

1. **`SKILL.md`** — 9 步流程，先扫一遍。
2. **`cases/README.md`** — 7 支真实 case + 5 支 backtest 的索引和横向对比表。
3. **`cases/01609-天星医疗.md`** — 看 skill 怎么应用在已盈利、有治理硬伤的医械公司上。
4. **`cases/backtest/6181-老铺黄金.md`** — 看 skill 怎么识别「品类重定义」型超级牛股（+1,468% 那只）。
5. **`prospectus-checklist.md`** — 当你想验证 Agent 输出时的深读线索。
6. **`blog/01-...`** + **`02-...`** + **`03-...`** — 方法论叙事版（含回归测试方法论）。

## Limitations

- **不构成投资建议**。所有「立场」都是「如果是我」口吻的个人偏好声明，盈亏由读者自负。
- **不预测首日股价**——那是赌博，不是分析。
- **不替代你自己读招股书**——Agent 提取和结构化，但「风险因素」章节你应该自己扫一遍再下决策。
- **Helper scripts 是 best-effort**——etnet 和 AASTOCKS 是 SPA 重的页面，部分字段需要按脚本打印的 URL 手动核查。

## Adding new cases

每分析完一只新 IPO，建议存为 case 文件：

```bash
# 模板用任意一个 forward case 起手（结构对齐）
cp cases/01187-可孚医疗.md cases/<code>-<name>.md

# 编辑文件，套用 SKILL.md 9 步格式
# 如果 case 揭示了 SKILL 之前没覆盖的 pattern，先更新 SKILL.md 再写下一个 case
```

新 case 的命名规范：
- 港股：`<5位代码>-<繁体公司名>.md`（如 `01187-可孚醫療.md`）
- 美股：`<ticker>-<EnglishName>.md`（如 `RDDT-Reddit.md`）
- 远期 / 未递表：`<ticker>-<sponsor>-<theme>.md`（如 `Roze-SoftBank-AI.md`）

回归测试 case（已上市标的，假装不知道结果跑 skill）放 `cases/backtest/`。

## License

个人项目，使用风险自负，无任何明示或默示的担保。
