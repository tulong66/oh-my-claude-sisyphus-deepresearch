---
name: deep-research
description: 深度研究技能，默认启用 ultrawork + ralph-loop
---

# Deep Research Skill

$ARGUMENTS

## 激活模式

**默认启用**：
- ultrawork（并行加速）
- ralph-loop（强制完成）

**禁用选项**：
- `--quick` - 禁用两者
- `--no-ultrawork` - 仅禁用并行
- `--no-ralph` - 仅禁用强制完成

## 工作流程

1. 创建工作空间 `.research/{topic-slug}-{timestamp}/`
2. 委托 metis 拆解问题
3. 委托 crawler-coordinator 并行搜索
4. 委托 knowledge-manager 存储聚合
5. 委托 oracle 深度分析
6. 委托 document-writer 生成报告
7. Oracle 验收（ralph-loop 模式）

## 研究协调者

使用 researcher agent 协调整个流程。
