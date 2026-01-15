# 设计文档：深度研究扩展

## 文档信息

| 项目 | 内容 |
|------|------|
| 版本 | 0.1.0 |
| 状态 | 草稿 |
| 创建日期 | 2026-01-14 |
| 关联需求 | requirements.md |

---

## 目录

1. [架构设计](#1-架构设计)
2. [接口设计](#2-接口设计)
3. [数据设计](#3-数据设计)
4. [详细设计](#4-详细设计)

---

## 1. 架构设计

### 1.1 整体架构

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          用户层 (User Layer)                                 │
│                                                                              │
│   /deep-research <topic>    /crawl <url>    /knowledge <query>              │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                        技能层 (Skill Layer)                                  │
│                                                                              │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │  deep-research skill                                                 │   │
│   │  (默认激活: ultrawork + ralph-loop)                                  │   │
│   └─────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                       智能体层 (Agent Layer)                                 │
│                                                                              │
│   ┌───────────────┐  ┌───────────────────┐  ┌───────────────────┐          │
│   │  researcher   │  │ crawler-coordinator│  │ knowledge-manager │          │
│   │  (Opus)       │  │ (Sonnet)           │  │ (Haiku)           │          │
│   │               │  │                    │  │                    │          │
│   │  协调/分析    │  │  爬虫调度          │  │  存储/检索         │          │
│   └───────┬───────┘  └─────────┬─────────┘  └─────────┬─────────┘          │
│           │                    │                      │                     │
│           └────────────────────┼──────────────────────┘                     │
│                                │                                            │
│   ┌────────────────────────────┼────────────────────────────────────────┐   │
│   │              现有 Sisyphus 智能体 (复用)                             │   │
│   │  oracle | librarian | explore | document-writer | metis | momus     │   │
│   └─────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                        工具层 (Tool Layer)                                   │
│                                                                              │
│   ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐       │
│   │  Exa MCP    │  │  Context7   │  │  WebFetch   │  │  WebSearch  │       │
│   │  搜索/爬取  │  │  文档查询   │  │  网页获取   │  │  网页搜索   │       │
│   └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘       │
│                                                                              │
│   ┌─────────────┐  ┌─────────────┐  ┌─────────────┐                        │
│   │  Read/Write │  │  Bash       │  │  TodoWrite  │                        │
│   │  文件操作   │  │  命令执行   │  │  任务管理   │                        │
│   └─────────────┘  └─────────────┘  └─────────────┘                        │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                        存储层 (Storage Layer)                                │
│                                                                              │
│   .research/{topic-slug}-{timestamp}/                                       │
│   ├── _meta.json          # 元数据                                          │
│   ├── raw/                # 原始数据                                        │
│   ├── processed/          # 处理后数据                                      │
│   └── output/             # 最终报告                                        │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 1.2 组件关系图

```
                    ┌─────────────────┐
                    │  /deep-research │
                    │    command      │
                    └────────┬────────┘
                             │ 激活
                             ▼
                    ┌─────────────────┐
                    │  deep-research  │
                    │     skill       │
                    └────────┬────────┘
                             │ 委托
                             ▼
┌────────────────────────────────────────────────────────────────┐
│                        researcher                               │
│                      (研究协调者)                               │
├────────────────────────────────────────────────────────────────┤
│  职责:                                                          │
│  1. 问题拆解 (调用 metis)                                       │
│  2. 任务编排 (TodoWrite)                                        │
│  3. 委托执行 (crawler-coordinator, oracle, ...)                │
│  4. 结果综合                                                    │
│  5. 报告生成 (调用 document-writer)                             │
└──────────┬─────────────────┬─────────────────┬─────────────────┘
           │                 │                 │
           ▼                 ▼                 ▼
┌──────────────────┐ ┌──────────────────┐ ┌──────────────────┐
│ crawler-         │ │ knowledge-       │ │ 现有智能体       │
│ coordinator      │ │ manager          │ │                  │
├──────────────────┤ ├──────────────────┤ ├──────────────────┤
│ - 选择爬虫工具   │ │ - 存储原始数据   │ │ oracle: 深度分析 │
│ - 并行获取      │ │ - 去重聚合       │ │ metis: 问题拆解  │
│ - 结果聚合      │ │ - 索引检索       │ │ momus: 计划审核  │
│ - 错误重试      │ │ - 归档管理       │ │ doc-writer: 报告 │
└──────────────────┘ └──────────────────┘ └──────────────────┘
```

### 1.3 数据流图

```
用户输入                处理阶段                      存储位置
─────────              ────────                      ────────

/deep-research
    │
    ▼
┌─────────┐
│ 主题    │ ──────────────────────────────────────► _meta.json
│ 解析    │                                         (topic, timestamp, status)
└────┬────┘
     │
     ▼
┌─────────┐         ┌─────────┐
│ 问题    │ ──────► │ 子查询  │ ──────────────────► _meta.json
│ 拆解    │         │ 列表    │                     (queries[])
└────┬────┘         └─────────┘
     │
     ▼
┌─────────┐         ┌─────────┐
│ 多源    │ ──────► │ 原始    │ ──────────────────► raw/*.json
│ 搜索    │         │ 结果    │
└────┬────┘         └─────────┘
     │
     ▼
┌─────────┐         ┌─────────┐
│ 信息    │ ──────► │ 聚合    │ ──────────────────► processed/*.json
│ 聚合    │         │ 数据    │
└────┬────┘         └─────────┘
     │
     ▼
┌─────────┐         ┌─────────┐
│ 深度    │ ──────► │ 分析    │ ──────────────────► processed/analysis.md
│ 分析    │         │ 结论    │
└────┬────┘         └─────────┘
     │
     ▼
┌─────────┐         ┌─────────┐
│ 报告    │ ──────► │ 最终    │ ──────────────────► output/report.md
│ 生成    │         │ 报告    │
└─────────┘         └─────────┘
```

---

## 2. 接口设计

### 2.1 Command 接口

#### 2.1.1 /deep-research

```yaml
description: 启动深度研究任务

语法: /deep-research <topic> [options]

参数:
  topic       研究主题 (必填)

选项:
  --quick         快速模式，禁用 ultrawork + ralph-loop
  --no-ralph      禁用强制完成
  --no-ultrawork  禁用并行加速
  --output <path> 指定输出目录 (默认: .research/)
  --resume <id>   恢复之前的研究任务

示例:
  /deep-research Polymarket 赚钱策略
  /deep-research AI 代码编辑器对比 --quick
```

#### 2.1.2 /crawl

```yaml
description: 爬取指定 URL 或平台内容

语法: /crawl <target> [options]

参数:
  target      URL 或平台标识 (必填)

选项:
  --depth <n>     爬取深度 (默认: 1)
  --format <fmt>  输出格式: json|md (默认: md)

示例:
  /crawl https://example.com/article
  /crawl twitter:@elonmusk --depth 10
```

#### 2.1.3 /knowledge

```yaml
description: 查询或管理知识库

语法: /knowledge <action> [query]

动作:
  search <query>  搜索知识库
  list            列出所有研究
  show <id>       显示研究详情
  delete <id>     删除研究记录

示例:
  /knowledge search Polymarket
  /knowledge list
```

### 2.2 Agent 接口

#### 2.2.1 researcher (研究协调者)

```yaml
# agents/researcher.md
---
name: researcher
description: 深度研究协调者，负责策略制定、任务编排、结果综合
model: opus
tools: Task, TodoWrite, Read, Write, Bash
---

输入:
  - topic: string        # 研究主题
  - options: object      # 配置选项

输出:
  - report_path: string  # 报告路径
  - workspace: string    # 工作空间路径

委托关系:
  - metis: 问题拆解
  - crawler-coordinator: 数据获取
  - knowledge-manager: 数据存储
  - oracle: 深度分析
  - document-writer: 报告生成
  - momus: 计划审核
```

#### 2.2.2 crawler-coordinator (爬虫协调者)

```yaml
# agents/crawler-coordinator.md
---
name: crawler-coordinator
description: 爬虫调度，选择工具、并行获取、结果聚合
model: sonnet
tools: WebFetch, WebSearch, Bash, Read, Write
---

输入:
  - queries: string[]    # 搜索查询列表
  - sources: string[]    # 指定数据源 (可选)

输出:
  - results: object[]    # 原始结果数组
  - stats: object        # 统计信息

工具路由:
  - 通用网页: Exa web_search_exa / crawling_exa
  - 深度研究: Exa deep_researcher_start
  - 网页获取: WebFetch
  - 网页搜索: WebSearch
```

#### 2.2.3 knowledge-manager (知识管理者)

```yaml
# agents/knowledge-manager.md
---
name: knowledge-manager
description: 知识存储、去重、索引、检索
model: haiku
tools: Read, Write, Bash, Glob, Grep
---

输入:
  - data: object[]       # 待存储数据
  - workspace: string    # 工作空间路径

输出:
  - stored_count: number # 存储条目数
  - duplicates: number   # 去重数量

功能:
  - 去重: SimHash 相似度检测
  - 索引: 更新 _meta.json
  - 检索: 关键词匹配
```

### 2.3 Skill 接口

```yaml
# skills/deep-research/SKILL.md
---
name: deep-research
description: 深度研究技能，默认启用 ultrawork + ralph-loop
---

激活条件:
  - /deep-research 命令
  - research-detector hook 检测到研究关键词

默认组合:
  - ultrawork: 并行加速
  - ralph-loop: 强制完成

禁用选项:
  - --quick: 禁用两者
  - --no-ultrawork: 仅禁用并行
  - --no-ralph: 仅禁用强制完成
```

### 2.4 Hook 接口

#### 2.4.1 research-detector

```yaml
# scripts/research-detector.sh
触发点: UserPromptSubmit

检测关键词:
  - 研究、调研、分析、对比
  - research, analyze, compare
  - 市场、竞品、趋势

输出:
  - 建议激活 /deep-research
```

#### 2.4.2 auto-archive

```yaml
# scripts/auto-archive.sh
触发点: Stop

条件: 研究任务完成 (检测 <promise>DONE</promise>)

动作:
  - 更新 _meta.json 状态为 completed
  - 生成研究摘要索引
```

---

## 3. 数据设计

### 3.1 工作空间结构

```
.research/
├── _index.json                        # 全局索引（自动维护）
├── _synonyms.json                     # 同义词映射
├── {topic-slug}-{timestamp}/          # 研究任务目录
│   ├── _meta.json                     # 任务元数据
│   ├── raw/                           # 原始数据
│   │   └── {source}-{hash}.md         # 每条信息一个文件
│   ├── processed/                     # 处理后数据
│   │   └── analysis.md
│   └── output/
│       └── report.md
└── {另一个主题}/
    └── ...
```

**设计原则**：
- 无全局知识库，零维护
- 每个主题独立存储
- 跨主题检索，知识自然增长

### 3.2 全局索引 (_index.json)

```json
{
  "updated_at": "2026-01-16T10:00:00Z",
  "topics": {
    "polymarket-strategies-20260114": {
      "title": "Polymarket 赚钱策略",
      "status": "completed",
      "tags": ["polymarket", "arbitrage", "trading"]
    }
  },
  "tag_index": {
    "arbitrage": ["polymarket-strategies-20260114"],
    "trading": ["polymarket-strategies-20260114"]
  }
}
```

**自动维护**：auto-archive hook 在研究完成时更新。

### 3.3 正规化与同义词 (_synonyms.json)

```json
{
  "normalization": {
    "lowercase": true,
    "singularize": true,
    "stem": true,
    "prefer_english": true
  },
  "stem_rules": {
    "trading": "trade",
    "strategies": "strategy",
    "arbitraging": "arbitrage"
  },
  "canonical": {
    "trade": ["trading", "trades", "traded", "交易"],
    "strategy": ["strategies", "策略", "方法", "打法"],
    "arbitrage": ["arbitraging", "arb", "套利", "价差交易"]
  }
}
```

**正规化原则**：

| 原则 | 说明 | 示例 |
|------|------|------|
| 词干化 | 动词/动名词 → 名词词干 | trading → trade |
| 单数化 | 复数 → 单数 | strategies → strategy |
| 小写化 | 统一小写 | Polymarket → polymarket |
| 英文优先 | 中文 → 英文词干 | 套利 → arbitrage |

**检索流程**：变体 → 正规词 → tag_index 查找

### 3.4 _meta.json 结构

```json
{
  "id": "polymarket-strategies-20260114-143052",
  "topic": "Polymarket 赚钱策略",
  "slug": "polymarket-strategies",
  "created_at": "2026-01-14T14:30:52Z",
  "updated_at": "2026-01-14T15:45:00Z",
  "status": "in_progress | completed | failed",
  "options": {
    "quick": false,
    "ultrawork": true,
    "ralph_loop": true
  },
  "queries": [
    "Polymarket trading strategies",
    "prediction market arbitrage"
  ],
  "progress": {
    "phase": "analysis",
    "completed_tasks": 3,
    "total_tasks": 5
  },
  "stats": {
    "sources_count": 12,
    "raw_items": 45,
    "deduplicated": 38
  }
}
```

### 3.5 原始数据格式 (raw/*.md)

```markdown
---
id: exa-a1b2c3d4
source: exa
url: https://example.com/article
title: Top Polymarket Strategies
fetched_at: 2026-01-14T14:35:00Z
tags: [polymarket, arbitrage, trading, strategy]
---

# Top Polymarket Strategies

原文内容...
```

### 3.6 论文/长文摘要格式

```markdown
---
id: paper-arxiv-2401-12345
type: paper
source: arxiv
title: "Prediction Market Strategies: A Survey"
authors: ["Alice", "Bob"]
tags: [prediction-market, survey, arbitrage]
---

## 摘要
[LLM 生成的中文摘要]

## 核心论点
- 论点 1
- 论点 2

## 关键发现
...
```

### 3.4 聚合数据格式 (processed/aggregated.json)

```json
{
  "clusters": [
    {
      "id": "arbitrage",
      "label": "套利策略",
      "items": ["item-1", "item-3"],
      "confidence": 0.85
    }
  ],
  "entities": [
    {
      "name": "Polymarket",
      "type": "platform",
      "mentions": 15
    }
  ]
}
```

### 3.7 跨主题检索流程

```
用户查询: "交易策略"
     │
     ▼
┌─────────────────┐
│ 1. 扩展同义词   │ → _synonyms.json
│    "交易"→"trading"
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ 2. 索引查找     │ → _index.json.tag_index
│    找到相关主题
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ 3. 跨主题 Grep  │ → 在匹配主题的 raw/*.md 中搜索
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ 4. 合并排序     │ → 按匹配度返回
└─────────────────┘
```

---

## 4. 详细设计

### 4.1 研究流程状态机

```
┌─────────┐
│  INIT   │ ─────► 解析主题，创建工作空间
└────┬────┘
     │
     ▼
┌─────────┐
│ PLANNING│ ─────► metis 拆解问题，生成子查询
└────┬────┘
     │
     ▼
┌─────────┐
│CRAWLING │ ─────► crawler-coordinator 并行获取
└────┬────┘
     │
     ▼
┌─────────┐
│AGGREGATE│ ─────► knowledge-manager 去重聚合
└────┬────┘
     │
     ▼
┌─────────┐
│ANALYSIS │ ─────► oracle 深度分析
└────┬────┘
     │
     ▼
┌─────────┐
│ REPORT  │ ─────► document-writer 生成报告
└────┬────┘
     │
     ▼
┌─────────┐
│ VERIFY  │ ─────► oracle 验收 (ralph-loop)
└────┬────┘
     │
     ▼
┌─────────┐
│COMPLETED│ ─────► <promise>DONE</promise>
└─────────┘
```

### 4.2 时序图

```
User        Command     Researcher   Metis    Crawler    Knowledge   Oracle    DocWriter
 │            │            │           │          │           │          │          │
 │──/deep-research──►│     │           │          │           │          │          │
 │            │──activate──►│          │          │           │          │          │
 │            │            │           │          │           │          │          │
 │            │            │──拆解问题──►│         │           │          │          │
 │            │            │◄──子查询───│          │           │          │          │
 │            │            │           │          │           │          │          │
 │            │            │──并行搜索────────────►│           │          │          │
 │            │            │◄──原始数据────────────│           │          │          │
 │            │            │           │          │           │          │          │
 │            │            │──存储聚合──────────────────────►│          │          │
 │            │            │◄──聚合结果─────────────────────│          │          │
 │            │            │           │          │           │          │          │
 │            │            │──深度分析─────────────────────────────────►│          │
 │            │            │◄──分析结论────────────────────────────────│          │
 │            │            │           │          │           │          │          │
 │            │            │──生成报告────────────────────────────────────────────►│
 │            │            │◄──报告路径───────────────────────────────────────────│
 │            │            │           │          │           │          │          │
 │            │            │──验收请求─────────────────────────────────►│          │
 │            │            │◄──APPROVED────────────────────────────────│          │
 │            │            │           │          │           │          │          │
 │◄──<promise>DONE</promise>──│        │          │           │          │          │
 │            │            │           │          │           │          │          │
```

### 4.3 错误处理

| 错误类型 | 处理策略 |
|----------|----------|
| 搜索无结果 | 扩展查询词，重试 |
| 爬取超时 | 跳过，记录日志 |
| API 限流 | 指数退避重试 |
| 聚合失败 | 降级为原始数据 |
| 验收不通过 | 补充任务，重新迭代 |

### 4.4 实现文件清单

| 文件 | 类型 | 说明 |
|------|------|------|
| `agents/researcher.md` | Agent | 研究协调者 |
| `agents/crawler-coordinator.md` | Agent | 爬虫协调者 |
| `agents/knowledge-manager.md` | Agent | 知识管理者 |
| `skills/deep-research/SKILL.md` | Skill | 深度研究技能 |
| `commands/deep-research.md` | Command | /deep-research |
| `commands/crawl.md` | Command | /crawl |
| `commands/knowledge.md` | Command | /knowledge |
| `scripts/research-detector.sh` | Hook | 研究检测 |
| `scripts/auto-archive.sh` | Hook | 自动归档 |

---

## 第五章：工具集成路线图

### 5.1 分阶段工具矩阵

#### Phase 1: MVP (当前)

| 工具 | 类型 | MCP | 状态 |
|------|------|-----|------|
| Exa web_search | 通用搜索 | ✅ | 已集成 |
| Exa crawling | 内容提取 | ✅ | 已集成 |
| Exa deep_researcher | 深度研究 | ✅ | 已集成 |
| WebFetch | 网页获取 | ✅ | 内置 |
| WebSearch | 快速搜索 | ✅ | 内置 |

#### Phase 2: 扩展搜索

| 工具 | 类型 | MCP | 状态 |
|------|------|-----|------|
| Tavily | RAG优化搜索 | 待配置 | 计划中 |
| Semantic Scholar | 学术论文 | API | 计划中 |
| Serper | Google结果 | 待配置 | 计划中 |

#### Phase 3: 专业爬虫

| 工具 | 类型 | 部署方式 | 状态 |
|------|------|---------|------|
| MediaCrawler | 中文社媒 | Docker | 计划中 |
| NewsCrawler | 新闻+技术博客 | MCP | 计划中 |

### 5.2 工具路由策略

```
Phase 1 路由 (当前):
┌─────────────────────────────────────────┐
│ 查询类型        │ 路由工具              │
├─────────────────┼───────────────────────┤
│ 通用搜索        │ Exa web_search        │
│ 深度研究        │ Exa deep_researcher   │
│ 特定URL         │ Exa crawling/WebFetch │
│ 快速搜索        │ WebSearch             │
└─────────────────────────────────────────┘

Phase 2+ 路由 (计划):
┌─────────────────────────────────────────┐
│ 查询类型        │ 路由工具              │
├─────────────────┼───────────────────────┤
│ 学术论文        │ Semantic Scholar      │
│ 中文社媒        │ MediaCrawler          │
│ 新闻追踪        │ NewsCrawler           │
└─────────────────────────────────────────┘
```

### 5.3 集成优先级

| 优先级 | 工具 | 理由 |
|--------|------|------|
| P0 | Exa 全系列 | 已有MCP，覆盖80%场景 |
| P1 | Semantic Scholar | 学术研究刚需 |
| P2 | MediaCrawler | 中文社媒独占 |
| P3 | NewsCrawler | 新闻聚合 |
| P4 | Tavily/Serper | 备用搜索 |

---

## 修订历史

| 版本 | 日期 | 说明 |
|------|------|------|
| 0.1.0 | 2026-01-14 | 初稿 |
| 0.1.1 | 2026-01-14 | 添加工具集成路线图 |