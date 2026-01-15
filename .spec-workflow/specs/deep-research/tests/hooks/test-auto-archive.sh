#!/bin/bash
# Test cases for auto-archive.sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../../.." && pwd)"
TARGET_SCRIPT="$PROJECT_ROOT/scripts/auto-archive.sh"

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

PASSED=0
FAILED=0

# Setup test environment
TEST_DIR="$PROJECT_ROOT/.research-test-$$"
mkdir -p "$TEST_DIR"

run_test() {
    local name="$1"
    local expected_pattern="$2"

    result=$(CLAUDE_PROJECT_ROOT="$PROJECT_ROOT" bash "$TARGET_SCRIPT" 2>/dev/null <<< '{}')

    if echo "$result" | grep -q "$expected_pattern"; then
        echo -e "${GREEN}✓${NC} $name"
        ((PASSED++))
    else
        echo -e "${RED}✗${NC} $name"
        echo "  Expected: $expected_pattern"
        echo "  Got: $result"
        ((FAILED++))
    fi
}

echo "=== Testing auto-archive.sh ==="
echo ""

# Test 1: No research directory
run_test "No research dir - continue" '"continue": true'

echo ""
echo "=== Results ==="
echo -e "Passed: ${GREEN}$PASSED${NC}"
echo -e "Failed: ${RED}$FAILED${NC}"

# Cleanup
rm -rf "$TEST_DIR"

exit $FAILED
