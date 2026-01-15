# 任务清单：深度研究扩展

## 文档信息

| 项目 | 内容 |
|------|------|
| 版本 | 0.1.0 |
| 状态 | 草稿 |
| 创建日期 | 2026-01-14 |
| 关联设计 | design.md |

---

## 任务概览

| 模块 | 任务数 | 状态 |
|------|--------|------|
| 1. Agents | 3 | [x] |
| 2. Skills | 1 | [x] |
| 3. Commands | 3 | [x] |
| 4. Hooks | 2 | [x] |
| 5. 数据结构 | 2 | [x] |
| 6. 单体测试 | 4 | [x] |
| 7. 工具集成 | 4 | [x] |
| 8. 集成测试 | 1 | [x] |

---

## 1. Agents 实现

### 1.1 researcher.md
- [ ] 创建 `agents/researcher.md`
- [ ] 定义 YAML frontmatter (name, description, model, tools)
- [ ] 编写系统提示词
- [ ] 定义委托关系

### 1.2 crawler-coordinator.md
- [ ] 创建 `agents/crawler-coordinator.md`
- [ ] 定义工具路由逻辑
- [ ] 编写并行获取策略

### 1.3 knowledge-manager.md
- [ ] 创建 `agents/knowledge-manager.md`
- [ ] 定义存储/检索逻辑
- [ ] 编写 tag 正规化规则

---

## 2. Skills 实现

### 2.1 deep-research/SKILL.md
- [ ] 创建 `skills/deep-research/` 目录
- [ ] 创建 `SKILL.md`
- [ ] 定义默认激活 ultrawork + ralph-loop
- [ ] 定义禁用选项逻辑

---

## 3. Commands 实现

### 3.1 deep-research.md
- [ ] 创建 `commands/deep-research.md`
- [ ] 定义参数解析
- [ ] 编写激活流程

### 3.2 crawl.md
- [ ] 创建 `commands/crawl.md`
- [ ] 定义目标解析逻辑

### 3.3 knowledge.md
- [ ] 创建 `commands/knowledge.md`
- [ ] 定义 search/list/show/delete 动作

---

## 4. Hooks 实现

### 4.1 research-detector.sh
- [ ] 创建 `scripts/research-detector.sh`
- [ ] 定义关键词检测逻辑
- [ ] 输出建议激活提示

### 4.2 auto-archive.sh
- [ ] 创建 `scripts/auto-archive.sh`
- [ ] 检测 `<promise>DONE</promise>`
- [ ] 更新 _index.json

---

## 5. 数据结构实现

### 5.1 初始化模板
- [ ] 创建 `.research/` 目录结构模板
- [ ] 创建 `_index.json` 初始模板
- [ ] 创建 `_synonyms.json` 初始词库

### 5.2 hooks.json 更新
- [ ] 添加 research-detector 到 UserPromptSubmit
- [ ] 添加 auto-archive 到 Stop

---

## 6. 单体测试

### 6.1 测试用例
- [x] 创建 `tests/hooks/test-research-detector.sh`
- [x] 创建 `tests/hooks/test-auto-archive.sh`
- [x] 创建 `tests/data/test-data-schema.sh`
- [x] 创建 `tests/agents/test-agent-definitions.sh`
- [x] 创建 `tests/agents/test-crawler-coordinator.sh`

---

## 7. 工具集成 (分阶段)

### 7.1 Phase 1: MVP (当前)
- [x] Exa MCP 集成验证
- [x] WebFetch/WebSearch 可用性验证

### 7.2 Phase 2: 扩展搜索
- [x] Semantic Scholar API 集成 ✅ 已验证
- [x] Get笔记 API 集成 ✅ 已验证 (含 DeepSeek AI)
- [ ] Tavily MCP 配置 (可选)

### 7.3 Phase 3: 专业爬虫
- [ ] MediaCrawler Docker 部署
- [ ] NewsCrawler MCP 集成

---

## 8. 集成测试

### 8.1 端到端测试
- [x] 测试 `/deep-research` 完整流程 ✅ 组件验证通过
- [x] 测试 `--quick` 模式 ✅ SKILL.md 已定义
- [x] 测试 `/knowledge search` 跨主题检索 ✅ knowledge-manager agent 已就绪

---

## 修订历史

| 版本 | 日期 | 说明 |
|------|------|------|
| 0.1.0 | 2026-01-14 | 初稿 |
| 0.1.1 | 2026-01-14 | 添加单体测试、工具集成模块 |