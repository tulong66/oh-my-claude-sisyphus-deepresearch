#!/bin/bash
# Test cases for data structure validation

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../../.." && pwd)"

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

PASSED=0
FAILED=0

run_test() {
    local name="$1"
    local file="$2"
    local check_cmd="$3"

    if eval "$check_cmd"; then
        echo -e "${GREEN}✓${NC} $name"
        ((PASSED++))
    else
        echo -e "${RED}✗${NC} $name"
        ((FAILED++))
    fi
}

echo "=== Testing Data Structures ==="
echo ""

# Test _index.json
INDEX_FILE="$PROJECT_ROOT/.research/_index.json"
run_test "_index.json exists" "$INDEX_FILE" "[ -f '$INDEX_FILE' ]"
run_test "_index.json valid JSON" "$INDEX_FILE" "jq empty '$INDEX_FILE' 2>/dev/null"
run_test "_index.json has topics field" "$INDEX_FILE" "jq -e '.topics' '$INDEX_FILE' >/dev/null 2>&1"
run_test "_index.json has tag_index field" "$INDEX_FILE" "jq -e '.tag_index' '$INDEX_FILE' >/dev/null 2>&1"

# Test _synonyms.json
SYNONYMS_FILE="$PROJECT_ROOT/.research/_synonyms.json"
run_test "_synonyms.json exists" "$SYNONYMS_FILE" "[ -f '$SYNONYMS_FILE' ]"
run_test "_synonyms.json valid JSON" "$SYNONYMS_FILE" "jq empty '$SYNONYMS_FILE' 2>/dev/null"
run_test "_synonyms.json has normalization" "$SYNONYMS_FILE" "jq -e '.normalization' '$SYNONYMS_FILE' >/dev/null 2>&1"
run_test "_synonyms.json has canonical" "$SYNONYMS_FILE" "jq -e '.canonical' '$SYNONYMS_FILE' >/dev/null 2>&1"

echo ""
echo "=== Results ==="
echo -e "Passed: ${GREEN}$PASSED${NC}"
echo -e "Failed: ${RED}$FAILED${NC}"

exit $FAILED
