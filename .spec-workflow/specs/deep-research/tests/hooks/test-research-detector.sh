#!/bin/bash
# Test cases for research-detector.sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../../.." && pwd)"
TARGET_SCRIPT="$PROJECT_ROOT/scripts/research-detector.sh"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

PASSED=0
FAILED=0

# Test function
run_test() {
    local name="$1"
    local input="$2"
    local expected_pattern="$3"

    result=$(echo "$input" | bash "$TARGET_SCRIPT" 2>/dev/null)

    if echo "$result" | grep -q "$expected_pattern"; then
        echo -e "${GREEN}✓${NC} $name"
        ((PASSED++))
    else
        echo -e "${RED}✗${NC} $name"
        echo "  Input: $input"
        echo "  Expected pattern: $expected_pattern"
        echo "  Got: $result"
        ((FAILED++))
    fi
}

echo "=== Testing research-detector.sh ==="
echo ""

# Test 1: Deep research keyword (English)
run_test "Deep research (EN)" \
    '{"prompt": "Please do a deep research on AI trends"}' \
    "deep-research-mode"

# Test 2: Deep research keyword (Chinese)
run_test "深度研究 (CN)" \
    '{"prompt": "请进行深度研究：市场趋势分析"}' \
    "deep-research-mode"

# Test 3: General research keyword
run_test "General research" \
    '{"prompt": "I need to research this topic"}' \
    "research-mode"

# Test 4: 调研 keyword
run_test "调研 keyword" \
    '{"prompt": "帮我调研一下竞品"}' \
    "research-mode"

# Test 5: No keyword - should continue
run_test "No keyword" \
    '{"prompt": "Hello, how are you?"}' \
    '"continue": true'

# Test 6: Empty prompt
run_test "Empty prompt" \
    '{}' \
    '"continue": true'

echo ""
echo "=== Results ==="
echo -e "Passed: ${GREEN}$PASSED${NC}"
echo -e "Failed: ${RED}$FAILED${NC}"

exit $FAILED
