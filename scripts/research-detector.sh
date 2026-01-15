#!/bin/bash
# Sisyphus Deep Research Detector Hook
# Detects research-related keywords and injects deep research mode

# Read stdin (JSON input from Claude Code)
INPUT=$(cat)

# Extract the prompt text
PROMPT=""
if command -v jq &> /dev/null; then
  PROMPT=$(echo "$INPUT" | jq -r '
    if .prompt then .prompt
    elif .message.content then .message.content
    elif .parts then ([.parts[] | select(.type == "text") | .text] | join(" "))
    else ""
    end
  ' 2>/dev/null)
fi

# Fallback: simple grep extraction if jq fails
if [ -z "$PROMPT" ] || [ "$PROMPT" = "null" ]; then
  PROMPT=$(echo "$INPUT" | grep -oP '"(prompt|content|text)"\s*:\s*"\K[^"]+' | head -1)
fi

# Exit if no prompt found
if [ -z "$PROMPT" ]; then
  echo '{"continue": true}'
  exit 0
fi

# Remove code blocks before checking keywords
PROMPT_NO_CODE=$(echo "$PROMPT" | sed 's/```[^`]*```//g' | sed 's/`[^`]*`//g')

# Convert to lowercase
PROMPT_LOWER=$(echo "$PROMPT_NO_CODE" | tr '[:upper:]' '[:lower:]')

# Check for deep research keywords (Chinese + English)
# Note: \b doesn't work with Chinese, so we match Chinese directly
if echo "$PROMPT_LOWER" | grep -qE '\bdeep.?research\b|深度研究|深入研究|详细调研|全面调研'; then
  cat << 'EOF'
{"continue": true, "message": "<deep-research-mode>\n\n**DEEP RESEARCH MODE ACTIVATED** (ultrawork + ralph-loop enabled)\n\n## Research Workflow\n1. **Metis** - Decompose research question into sub-questions\n2. **Crawler-Coordinator** - Parallel multi-source crawling (Exa/WebFetch/WebSearch)\n3. **Knowledge-Manager** - Store, dedupe, index with tags\n4. **Oracle** - Deep analysis and synthesis\n5. **Document-Writer** - Generate final report\n6. **Oracle Verification** - Ralph-loop until DONE\n\n## Workspace\nCreate `.research/{topic-slug}-{timestamp}/` for this research task.\n\n## Execution Rules\n- Use TodoWrite to track ALL research steps\n- Launch crawlers in PARALLEL (background tasks)\n- Store ALL findings with proper tags\n- Iterate until Oracle approves with <promise>DONE</promise>\n\n</deep-research-mode>\n\n---\n"}
EOF
  exit 0
fi

# Check for general research keywords
# Note: \b doesn't work with Chinese
if echo "$PROMPT_LOWER" | grep -qE '\bresearch\b|调研|研究|调查|探索|分析.*趋势|市场.*分析'; then
  cat << 'EOF'
{"continue": true, "message": "<research-mode>\n\n**RESEARCH MODE** - Multi-source information gathering activated.\n\nUse researcher agent to coordinate:\n1. Decompose question (metis)\n2. Parallel crawling (crawler-coordinator)\n3. Store findings (knowledge-manager)\n4. Synthesize results\n\nTip: Use `/deep-research` for comprehensive research with verification loop.\n\n</research-mode>\n\n---\n"}
EOF
  exit 0
fi

# No keywords detected
echo '{"continue": true}'
exit 0
