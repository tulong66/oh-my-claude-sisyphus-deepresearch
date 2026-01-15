#!/bin/bash
# Get笔记 (biji.com) API Helper
# Usage: getnote.sh <action> <query> [options]
# Rate Limit: 2 RPS

set -e

# Configuration
API_BASE="https://open-api.biji.com/getnote/openapi"
API_KEY="${GETNOTE_API_KEY:-}"
TOPIC_ID="${GETNOTE_TOPIC_ID:-}"
RATE_LIMIT_FILE="/tmp/.getnote_ratelimit"
MIN_INTERVAL_MS=500  # 2 RPS = 500ms between requests

# Rate limiting: ensure minimum 500ms between requests
rate_limit() {
    local now_ms=$(($(date +%s%N) / 1000000))
    if [ -f "$RATE_LIMIT_FILE" ]; then
        local last_ms=$(cat "$RATE_LIMIT_FILE")
        local diff=$((now_ms - last_ms))
        if [ "$diff" -lt "$MIN_INTERVAL_MS" ]; then
            local sleep_ms=$((MIN_INTERVAL_MS - diff))
            sleep "0.${sleep_ms}s" 2>/dev/null || sleep 1
        fi
    fi
    echo "$now_ms" > "$RATE_LIMIT_FILE"
}

# Action: Search/Recall
search_recall() {
    local query="$1"
    local top_k="${2:-5}"

    if [ -z "$API_KEY" ] || [ -z "$TOPIC_ID" ]; then
        echo "Error: GETNOTE_API_KEY and GETNOTE_TOPIC_ID required"
        exit 1
    fi

    # Apply rate limiting before request
    rate_limit

    curl -s -X POST "${API_BASE}/knowledge/search/recall" \
        -H "Authorization: Bearer $API_KEY" \
        -H "X-OAuth-Version: 1" \
        -H "Content-Type: application/json" \
        -d "{\"question\": \"$query\", \"topic_id\": \"$TOPIC_ID\", \"top_k\": $top_k}"
}

# Action: AI Search (with DeepSeek summarization)
ai_search() {
    local query="$1"
    local deep_seek="${2:-true}"

    if [ -z "$API_KEY" ] || [ -z "$TOPIC_ID" ]; then
        echo "Error: GETNOTE_API_KEY and GETNOTE_TOPIC_ID required"
        exit 1
    fi

    # Apply rate limiting before request
    rate_limit

    curl -s -X POST "${API_BASE}/knowledge/search" \
        -H "Authorization: Bearer $API_KEY" \
        -H "X-OAuth-Version: 1" \
        -H "Content-Type: application/json" \
        -d "{\"question\": \"$query\", \"topic_ids\": [\"$TOPIC_ID\"], \"deep_seek\": $deep_seek}"
}

# Action: AI Search Stream (with refs and deep thinking)
ai_search_stream() {
    local query="$1"
    local deep_seek="${2:-true}"

    if [ -z "$API_KEY" ] || [ -z "$TOPIC_ID" ]; then
        echo "Error: GETNOTE_API_KEY and GETNOTE_TOPIC_ID required"
        exit 1
    fi

    # Apply rate limiting before request
    rate_limit

    curl -s -N -X POST "${API_BASE}/knowledge/search/stream" \
        -H "Authorization: Bearer $API_KEY" \
        -H "X-OAuth-Version: 1" \
        -H "Content-Type: application/json" \
        -d "{\"question\": \"$query\", \"topic_ids\": [\"$TOPIC_ID\"], \"deep_seek\": $deep_seek, \"refs\": true}"
}

# Action: Knowledge Check (check if topic is covered in knowledge base)
knowledge_check() {
    local query="$1"
    local top_k="${2:-5}"

    if [ -z "$API_KEY" ] || [ -z "$TOPIC_ID" ]; then
        echo "Error: GETNOTE_API_KEY and GETNOTE_TOPIC_ID required"
        exit 1
    fi

    echo "=== 知识库覆盖检查 ===" >&2
    echo "查询: $query" >&2
    echo "" >&2

    # Step 1: Get raw recall first
    rate_limit
    echo "[Step 1] 检索知识库..." >&2
    local raw_result=$(curl -s -X POST "${API_BASE}/knowledge/search/recall" \
        -H "Authorization: Bearer $API_KEY" \
        -H "X-OAuth-Version: 1" \
        -H "Content-Type: application/json" \
        -d "{\"question\": \"$query\", \"topic_id\": \"$TOPIC_ID\", \"top_k\": $top_k}")

    local raw_count=$(echo "$raw_result" | jq '.c.data | length' 2>/dev/null || echo "0")
    echo "  知识库命中: $raw_count 条" >&2

    # Step 2: Get AI summary if has content
    if [ "$raw_count" -gt 0 ]; then
        rate_limit
        echo "[Step 2] 生成AI总结..." >&2
        local ai_result=$(curl -s -X POST "${API_BASE}/knowledge/search" \
            -H "Authorization: Bearer $API_KEY" \
            -H "X-OAuth-Version: 1" \
            -H "Content-Type: application/json" \
            -d "{\"question\": \"$query\", \"topic_ids\": [\"$TOPIC_ID\"], \"deep_seek\": true}")

        echo "" >&2
        echo "✅ 知识库有相关内容，可作为研究起点" >&2
        echo "⚠️  注意: 需用Exa/Tavily交叉验证关键事实" >&2
    else
        local ai_result='{"c":{"answers":"","no_recall":true}}'
        echo "" >&2
        echo "❌ 知识库无相关内容，建议直接使用Exa/Tavily搜索" >&2
    fi
    echo "=====================" >&2

    # Output structured result
    jq -n \
        --argjson raw "$raw_result" \
        --argjson ai "$ai_result" \
        --argjson raw_count "$raw_count" \
        '{
            has_coverage: ($raw_count > 0),
            source_count: $raw_count,
            sources: [($raw.c.data // [])[] | {title: .title, type: .type, score: .score}],
            summary: $ai.c.answers,
            note: "知识库内容需交叉验证，非实时网络数据"
        }'
}

# Main
ACTION="$1"
shift

case "$ACTION" in
    search|recall)
        search_recall "$@"
        ;;
    ai)
        ai_search "$@"
        ;;
    stream)
        ai_search_stream "$@"
        ;;
    verify|check)
        knowledge_check "$@"
        ;;
    *)
        echo "Usage: $0 <action> <query> [options]"
        echo ""
        echo "Actions:"
        echo "  search <query> [top_k]     - Raw recall (no AI processing)"
        echo "  ai <query> [deep_seek]     - AI search with DeepSeek summary"
        echo "  stream <query> [deep_seek] - AI search with streaming + refs"
        echo "  check <query> [top_k]      - Knowledge base coverage check"
        echo ""
        echo "Note: Get笔记 = 个人知识库，非实时网络搜索"
        echo "      关键事实需用 Exa/Tavily 交叉验证"
        echo ""
        echo "Environment:"
        echo "  GETNOTE_API_KEY   - API Key (required)"
        echo "  GETNOTE_TOPIC_ID  - Knowledge base ID (required)"
        echo ""
        echo "Rate Limit: 2 RPS"
        exit 1
        ;;
esac
