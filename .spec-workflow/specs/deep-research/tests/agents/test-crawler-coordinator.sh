#!/bin/bash
# Test cases for crawler-coordinator.md

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../../.." && pwd)"
AGENT_FILE="$PROJECT_ROOT/agents/crawler-coordinator.md"

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

PASSED=0
FAILED=0

run_test() {
    local name="$1"
    local check_cmd="$2"

    if eval "$check_cmd"; then
        echo -e "${GREEN}✓${NC} $name"
        ((PASSED++))
    else
        echo -e "${RED}✗${NC} $name"
        ((FAILED++))
    fi
}

echo "=== Testing crawler-coordinator.md ==="
echo ""

# Structure tests
run_test "File exists" "[ -f '$AGENT_FILE' ]"
run_test "Has YAML frontmatter" "head -1 '$AGENT_FILE' | grep -q '^---'"
run_test "Has name field" "grep -q '^name:' '$AGENT_FILE'"
run_test "Has MCP tools" "grep -q 'mcp__exa__' '$AGENT_FILE'"

# Content tests
run_test "Has tool routing section" "grep -q '工具路由' '$AGENT_FILE'"
run_test "Has parallel execution guide" "grep -q '并行' '$AGENT_FILE'"
run_test "Has error handling" "grep -q '错误处理' '$AGENT_FILE'"
run_test "Has output format" "grep -q '输出格式' '$AGENT_FILE'"
run_test "Has collaboration section" "grep -q 'knowledge-manager' '$AGENT_FILE'"

echo ""
echo "=== Results ==="
echo -e "Passed: ${GREEN}$PASSED${NC}"
echo -e "Failed: ${RED}$FAILED${NC}"

exit $FAILED
