#!/bin/bash
# Sisyphus Auto-Archive Hook
# Archives completed research sessions on Stop event

# Read stdin (JSON input from Claude Code)
INPUT=$(cat)

# Get the research workspace path
RESEARCH_DIR="${CLAUDE_PROJECT_ROOT:-.}/.research"

# Check if research directory exists
if [ ! -d "$RESEARCH_DIR" ]; then
  echo '{"continue": true}'
  exit 0
fi

# Find active research sessions (directories modified in last 24 hours)
ACTIVE_SESSIONS=$(find "$RESEARCH_DIR" -maxdepth 1 -type d -mmin -1440 -name "*-*" 2>/dev/null)

if [ -z "$ACTIVE_SESSIONS" ]; then
  echo '{"continue": true}'
  exit 0
fi

# Check each session for completion markers
ARCHIVED=0
for SESSION in $ACTIVE_SESSIONS; do
  SESSION_NAME=$(basename "$SESSION")

  # Check if session has a final report (indicates completion)
  if [ -f "$SESSION/report.md" ] || [ -f "$SESSION/final-report.md" ]; then
    # Check if already archived
    if [ ! -f "$SESSION/.archived" ]; then
      # Update index with completion status
      if [ -f "$RESEARCH_DIR/_index.json" ] && command -v jq &> /dev/null; then
        TIMESTAMP=$(date -Iseconds)
        jq --arg topic "$SESSION_NAME" --arg time "$TIMESTAMP" \
          '.topics[$topic].status = "completed" | .topics[$topic].archived_at = $time | .updated_at = $time' \
          "$RESEARCH_DIR/_index.json" > "$RESEARCH_DIR/_index.json.tmp" 2>/dev/null && \
          mv "$RESEARCH_DIR/_index.json.tmp" "$RESEARCH_DIR/_index.json"
      fi

      # Mark as archived
      echo "$(date -Iseconds)" > "$SESSION/.archived"
      ARCHIVED=$((ARCHIVED + 1))
    fi
  fi
done

if [ $ARCHIVED -gt 0 ]; then
  cat << EOF
{"continue": true, "message": "<auto-archive>\nArchived $ARCHIVED completed research session(s).\n</auto-archive>\n"}
EOF
else
  echo '{"continue": true}'
fi

exit 0
