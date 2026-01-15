#!/bin/bash
# Semantic Scholar API Helper
# Usage: semantic-scholar.sh <action> <query> [options]

set -e

# Configuration
API_BASE="https://api.semanticscholar.org/graph/v1"
API_KEY="${SEMANTIC_SCHOLAR_API_KEY:-}"
CACHE_DIR="${HOME}/.cache/semantic-scholar"

# Create cache directory
mkdir -p "$CACHE_DIR"

# Helper: Add API key header if available
get_headers() {
    if [ -n "$API_KEY" ]; then
        echo "-H 'x-api-key: $API_KEY'"
    fi
}

# Action: Search papers
search_papers() {
    local query="$1"
    local limit="${2:-10}"
    local fields="title,authors,year,abstract,citationCount,url"

    local url="${API_BASE}/paper/search?query=$(echo "$query" | sed 's/ /+/g')&limit=${limit}&fields=${fields}"

    if [ -n "$API_KEY" ]; then
        curl -s -H "x-api-key: $API_KEY" "$url"
    else
        curl -s "$url"
    fi
}

# Action: Get paper details
get_paper() {
    local paper_id="$1"
    local fields="title,authors,year,abstract,citationCount,references,url"

    local url="${API_BASE}/paper/${paper_id}?fields=${fields}"

    if [ -n "$API_KEY" ]; then
        curl -s -H "x-api-key: $API_KEY" "$url"
    else
        curl -s "$url"
    fi
}

# Main
ACTION="$1"
shift

case "$ACTION" in
    search)
        search_papers "$@"
        ;;
    paper)
        get_paper "$@"
        ;;
    *)
        echo "Usage: $0 <search|paper> <query|paper_id> [limit]"
        echo ""
        echo "Actions:"
        echo "  search <query> [limit]  - Search papers by keyword"
        echo "  paper <paper_id>        - Get paper details"
        echo ""
        echo "Environment:"
        echo "  SEMANTIC_SCHOLAR_API_KEY - API key (optional but recommended)"
        exit 1
        ;;
esac
