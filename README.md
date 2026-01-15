# oh-my-claude-sisyphus-deepresearch

Deep Research Extension for [oh-my-claude-sisyphus](https://github.com/Yeachan-Heo/oh-my-claude-sisyphus)

## Prerequisites

**Required**: Install oh-my-claude-sisyphus first:
```bash
curl -fsSL https://raw.githubusercontent.com/Yeachan-Heo/oh-my-claude-sisyphus/main/scripts/install.sh | bash
```

## Installation

```bash
curl -fsSL https://raw.githubusercontent.com/deepzen/oh-my-claude-sisyphus-deepresearch/main/install.sh | bash
```

## Features

### Core Capabilities
- `/deep-research <topic>` - Multi-source deep research with cross-validation
- `/crawl <url>` - Intelligent web crawling
- `/knowledge <query>` - Knowledge base management

### Integrated Tools
| Tool | Purpose | Status |
|------|---------|--------|
| Get笔记 | Personal knowledge base (DeepSeek AI) | ✅ |
| Exa | Real-time web search | ✅ |
| Tavily | RAG-optimized search | ✅ |
| Semantic Scholar | Academic papers | ✅ |

### Cross-Validation Flow
```
User Query
    ↓
Get笔记 (Personal KB) → Fast retrieval of collected knowledge
    ↓
Exa/Tavily (Real-time) → Verify facts + supplement latest data
    ↓
Multi-source comparison → Consistency, timeliness, source quality
    ↓
Credibility annotation → ✅ Multi-source consistent | ⚠️ Single source | ❓ Conflict
```

## Environment Variables

```bash
# Get笔记 (Required for knowledge base)
export GETNOTE_API_KEY="your-api-key"
export GETNOTE_TOPIC_ID="your-topic-id"

# Semantic Scholar (Recommended)
export SEMANTIC_SCHOLAR_API_KEY="your-api-key"
```

## Upgrading

### Upgrade Base Framework
```bash
curl -fsSL https://raw.githubusercontent.com/Yeachan-Heo/oh-my-claude-sisyphus/main/scripts/install.sh | bash
```

### Upgrade Deep Research Extension
```bash
curl -fsSL https://raw.githubusercontent.com/deepzen/oh-my-claude-sisyphus-deepresearch/main/install.sh | bash
```

## License

MIT
