#!/bin/bash
# Groundhog Stop Hook
# Runs after each Claude response to manage iterative loops
#
# This script:
# 1. Checks if a groundhog loop is active
# 2. If active, increments iteration count and re-injects the loop prompt
# 3. Stops when max iterations reached or completion promise detected

set -e

# Check jq is available
if ! command -v jq &> /dev/null; then
    echo '{"decision": "allow", "reason": "GROUNDHOG WARNING: jq not installed. Install with: brew install jq (macOS) or apt install jq (Linux)"}'
    exit 0
fi

# Get the project root (where .groundhog/ lives)
PROJECT_ROOT="$(pwd)"
STATE_FILE="$PROJECT_ROOT/.groundhog/state.json"
LOOPS_DIR="$PROJECT_ROOT/.groundhog/loops"

# Read hook input from stdin (contains transcript_path, etc.)
HOOK_INPUT=$(cat)

# Check if stop_hook_active is true (prevents infinite loops in hook processing)
STOP_HOOK_ACTIVE=$(echo "$HOOK_INPUT" | jq -r '.stop_hook_active // false' 2>/dev/null || echo "false")
if [ "$STOP_HOOK_ACTIVE" = "true" ]; then
    echo '{"decision": "allow"}'
    exit 0
fi

# Check if state file exists
if [ ! -f "$STATE_FILE" ]; then
    echo '{"decision": "allow"}'
    exit 0
fi

# Read state
STATE=$(cat "$STATE_FILE")
ACTIVE=$(echo "$STATE" | jq -r '.active // false')

if [ "$ACTIVE" != "true" ]; then
    echo '{"decision": "allow"}'
    exit 0
fi

# Loop is active - get details
LOOP_NAME=$(echo "$STATE" | jq -r '.loop_name')
ITERATION=$(echo "$STATE" | jq -r '.iteration // 0')
MAX_ITERATIONS=$(echo "$STATE" | jq -r '.max_iterations // 50')
COMPLETION_PROMISE=$(echo "$STATE" | jq -r '.completion_promise // ""')

# Increment iteration
NEW_ITERATION=$((ITERATION + 1))

# Check if max iterations reached
if [ "$NEW_ITERATION" -gt "$MAX_ITERATIONS" ]; then
    TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    # Different message based on whether completion promise was set
    if [ -n "$COMPLETION_PROMISE" ] && [ "$COMPLETION_PROMISE" != "null" ]; then
        # Had a completion promise but hit max iterations first
        STOP_REASON="max_iterations"
        MESSAGE="GROUNDHOG: Max iterations reached ($MAX_ITERATIONS) without completion. Loop '$LOOP_NAME' stopped."
    else
        # No completion promise - this is expected behavior (ran X times as configured)
        STOP_REASON="iterations_complete"
        MESSAGE="GROUNDHOG: Loop '$LOOP_NAME' completed $MAX_ITERATIONS iterations."
    fi

    echo "$STATE" | jq \
        --argjson iter "$NEW_ITERATION" \
        --arg ts "$TIMESTAMP" \
        --arg reason "$STOP_REASON" \
        '.active = false | .iteration = $iter | .stopped_at = $ts | .stopped_reason = $reason' > "$STATE_FILE"

    jq -n \
        --arg reason "$MESSAGE" \
        '{"decision": "allow", "reason": $reason}'
    exit 0
fi

# Check for completion promise in transcript
if [ -n "$COMPLETION_PROMISE" ] && [ "$COMPLETION_PROMISE" != "null" ]; then
    TRANSCRIPT_PATH=$(echo "$HOOK_INPUT" | jq -r '.transcript_path // ""' 2>/dev/null || echo "")
    if [ -n "$TRANSCRIPT_PATH" ] && [ -f "$TRANSCRIPT_PATH" ]; then
        # Check last portion of transcript for the completion promise (use -F for literal match)
        if tail -c 50000 "$TRANSCRIPT_PATH" 2>/dev/null | grep -qF "$COMPLETION_PROMISE"; then
            # Completion promise found
            TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
            echo "$STATE" | jq \
                --argjson iter "$NEW_ITERATION" \
                --arg ts "$TIMESTAMP" \
                '.active = false | .iteration = $iter | .stopped_at = $ts | .stopped_reason = "completed"' > "$STATE_FILE"

            jq -n \
                --arg reason "GROUNDHOG: Task complete! '$COMPLETION_PROMISE' detected. Loop '$LOOP_NAME' finished after $NEW_ITERATION iterations." \
                '{"decision": "allow", "reason": $reason}'
            exit 0
        fi
    fi
fi

# Continue the loop - update iteration count
echo "$STATE" | jq --argjson iter "$NEW_ITERATION" '.iteration = $iter' > "$STATE_FILE"

# Read the loop file
LOOP_FILE="$LOOPS_DIR/$LOOP_NAME.md"
if [ ! -f "$LOOP_FILE" ]; then
    jq -n \
        --arg reason "GROUNDHOG ERROR: Loop file not found: $LOOP_FILE. Run /groundhog:list to see available loops." \
        '{"decision": "allow", "reason": $reason}'
    exit 0
fi

# Extract content after frontmatter (everything after the second ---)
LOOP_CONTENT=$(awk '
    BEGIN { in_frontmatter = 0; found_end = 0 }
    /^---[[:space:]]*$/ {
        if (in_frontmatter == 0) { in_frontmatter = 1; next }
        else { found_end = 1; next }
    }
    found_end == 1 { print }
' "$LOOP_FILE")

# Build the prompt to inject
PROMPT="--- GROUNDHOG: Iteration $NEW_ITERATION / $MAX_ITERATIONS ---
Loop: $LOOP_NAME

$LOOP_CONTENT"

# Block the stop and inject the loop prompt
jq -n \
    --arg reason "$PROMPT" \
    '{"decision": "block", "reason": $reason}'
