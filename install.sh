#!/bin/bash
# oh-my-claude-sisyphus-deepresearch installer
# Extension for oh-my-claude-sisyphus

set -e

REPO_URL="https://raw.githubusercontent.com/deepzen-me/oh-my-claude-sisyphus-deepresearch/main"
CLAUDE_DIR="$HOME/.claude"

echo "🔬 Installing oh-my-claude-sisyphus-deepresearch..."

# Check prerequisite
if [ ! -d "$CLAUDE_DIR/agents" ]; then
    echo "❌ Error: oh-my-claude-sisyphus not found"
    echo "Please install it first:"
    echo "curl -fsSL https://raw.githubusercontent.com/Yeachan-Heo/oh-my-claude-sisyphus/main/scripts/install.sh | bash"
    exit 1
fi

echo "✅ Base framework detected"

# Create directories
mkdir -p "$CLAUDE_DIR/agents"
mkdir -p "$CLAUDE_DIR/scripts"
mkdir -p "$CLAUDE_DIR/commands"
mkdir -p "$CLAUDE_DIR/skills/deep-research"

echo "📥 Downloading deep research components..."

# Download agents
curl -fsSL "$REPO_URL/agents/researcher.md" -o "$CLAUDE_DIR/agents/researcher.md"
curl -fsSL "$REPO_URL/agents/crawler-coordinator.md" -o "$CLAUDE_DIR/agents/crawler-coordinator.md"
curl -fsSL "$REPO_URL/agents/knowledge-manager.md" -o "$CLAUDE_DIR/agents/knowledge-manager.md"
echo "  ✅ Agents installed"

# Download scripts
curl -fsSL "$REPO_URL/scripts/getnote.sh" -o "$CLAUDE_DIR/scripts/getnote.sh"
curl -fsSL "$REPO_URL/scripts/semantic-scholar.sh" -o "$CLAUDE_DIR/scripts/semantic-scholar.sh"
curl -fsSL "$REPO_URL/scripts/research-detector.sh" -o "$CLAUDE_DIR/scripts/research-detector.sh"
chmod +x "$CLAUDE_DIR/scripts/"*.sh
echo "  ✅ Scripts installed"

# Download commands
curl -fsSL "$REPO_URL/commands/deep-research.md" -o "$CLAUDE_DIR/commands/deep-research.md"
curl -fsSL "$REPO_URL/commands/crawl.md" -o "$CLAUDE_DIR/commands/crawl.md"
curl -fsSL "$REPO_URL/commands/knowledge.md" -o "$CLAUDE_DIR/commands/knowledge.md"
echo "  ✅ Commands installed"

# Download skill
curl -fsSL "$REPO_URL/skills/deep-research/SKILL.md" -o "$CLAUDE_DIR/skills/deep-research/SKILL.md"
echo "  ✅ Skills installed"

echo ""
echo "🎉 Installation complete!"
echo ""
echo "Available commands:"
echo "  /deep-research <topic>  - Multi-source deep research"
echo "  /crawl <url>            - Web crawling"
echo "  /knowledge <query>      - Knowledge base"
echo ""
echo "⚠️  Configure environment variables in ~/.bashrc:"
echo "  export GETNOTE_API_KEY=\"your-key\""
echo "  export GETNOTE_TOPIC_ID=\"your-topic-id\""
