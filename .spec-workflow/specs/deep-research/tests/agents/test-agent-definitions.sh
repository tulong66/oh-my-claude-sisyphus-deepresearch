#!/bin/bash
# Test cases for Agent definitions

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../../.." && pwd)"
AGENTS_DIR="$PROJECT_ROOT/agents"

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

PASSED=0
FAILED=0

# Test agent file structure
test_agent() {
    local agent_file="$1"
    local agent_name=$(basename "$agent_file" .md)

    # Check file exists
    if [ ! -f "$agent_file" ]; then
        echo -e "${RED}✗${NC} $agent_name: file not found"
        ((FAILED++))
        return
    fi

    # Check YAML frontmatter exists
    if ! head -1 "$agent_file" | grep -q "^---"; then
        echo -e "${RED}✗${NC} $agent_name: missing YAML frontmatter"
        ((FAILED++))
        return
    fi

    # Check required fields
    local has_name=$(grep -E "^name:" "$agent_file")
    local has_desc=$(grep -E "^description:" "$agent_file")

    if [ -z "$has_name" ]; then
        echo -e "${RED}✗${NC} $agent_name: missing 'name' field"
        ((FAILED++))
        return
    fi

    if [ -z "$has_desc" ]; then
        echo -e "${RED}✗${NC} $agent_name: missing 'description' field"
        ((FAILED++))
        return
    fi

    echo -e "${GREEN}✓${NC} $agent_name"
    ((PASSED++))
}

echo "=== Testing Agent Definitions ==="
echo ""

# Test new agents
test_agent "$AGENTS_DIR/researcher.md"
test_agent "$AGENTS_DIR/crawler-coordinator.md"
test_agent "$AGENTS_DIR/knowledge-manager.md"

echo ""
echo "=== Results ==="
echo -e "Passed: ${GREEN}$PASSED${NC}"
echo -e "Failed: ${RED}$FAILED${NC}"

exit $FAILED
