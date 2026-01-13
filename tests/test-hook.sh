#!/bin/bash
# Test script for groundhog stop hook
# Run with: ./tests/test-hook.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
HOOK_SCRIPT="$PROJECT_DIR/scripts/stop-hook.sh"
TEST_DIR=$(mktemp -d)
PASSED=0
FAILED=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

cleanup() {
    rm -rf "$TEST_DIR"
}
trap cleanup EXIT

log_pass() {
    echo -e "${GREEN}PASS${NC}: $1"
    PASSED=$((PASSED + 1))
}

log_fail() {
    echo -e "${RED}FAIL${NC}: $1"
    FAILED=$((FAILED + 1))
}

log_info() {
    echo -e "${YELLOW}INFO${NC}: $1"
}

# Setup test environment
setup() {
    cd "$TEST_DIR"
    mkdir -p .groundhog/loops
}

# Test 1: No state file - should allow
test_no_state_file() {
    setup
    rm -f .groundhog/state.json

    result=$(echo '{}' | "$HOOK_SCRIPT")
    decision=$(echo "$result" | jq -r '.decision')

    if [ "$decision" = "allow" ]; then
        log_pass "No state file returns allow"
    else
        log_fail "No state file should return allow, got: $decision"
    fi
}

# Test 2: Inactive loop - should allow
test_inactive_loop() {
    setup
    cat > .groundhog/state.json << 'EOF'
{
  "active": false,
  "loop_name": "test-loop",
  "iteration": 5
}
EOF

    result=$(echo '{}' | "$HOOK_SCRIPT")
    decision=$(echo "$result" | jq -r '.decision')

    if [ "$decision" = "allow" ]; then
        log_pass "Inactive loop returns allow"
    else
        log_fail "Inactive loop should return allow, got: $decision"
    fi
}

# Test 3: Active loop with missing loop file - should allow with error
test_missing_loop_file() {
    setup
    cat > .groundhog/state.json << 'EOF'
{
  "active": true,
  "loop_name": "nonexistent",
  "iteration": 0,
  "max_iterations": 10
}
EOF

    result=$(echo '{}' | "$HOOK_SCRIPT")
    decision=$(echo "$result" | jq -r '.decision')
    reason=$(echo "$result" | jq -r '.reason')

    if [ "$decision" = "allow" ] && echo "$reason" | grep -q "ERROR"; then
        log_pass "Missing loop file returns allow with error"
    else
        log_fail "Missing loop file should return allow with error, got: $decision - $reason"
    fi
}

# Test 4: Active loop - should block and continue
test_active_loop_continues() {
    setup
    cat > .groundhog/state.json << 'EOF'
{
  "active": true,
  "loop_name": "test-loop",
  "iteration": 2,
  "max_iterations": 10
}
EOF
    cat > .groundhog/loops/test-loop.md << 'EOF'
---
max-iterations: 10
completion-promise: DONE
---

# Test Loop

Do something.
EOF

    result=$(echo '{}' | "$HOOK_SCRIPT")
    decision=$(echo "$result" | jq -r '.decision')

    # Check iteration was incremented
    new_iteration=$(jq -r '.iteration' .groundhog/state.json)

    if [ "$decision" = "block" ] && [ "$new_iteration" = "3" ]; then
        log_pass "Active loop blocks and increments iteration"
    else
        log_fail "Active loop should block and increment, got: decision=$decision, iteration=$new_iteration"
    fi
}

# Test 5: Iterations complete (no completion promise) - should allow and stop
test_iterations_complete() {
    setup
    # Set iteration to 10, so next iteration (11) exceeds max of 10
    # No completion_promise means it should stop with "iterations_complete"
    cat > .groundhog/state.json << 'EOF'
{
  "active": true,
  "loop_name": "test-loop",
  "iteration": 10,
  "max_iterations": 10
}
EOF
    cat > .groundhog/loops/test-loop.md << 'EOF'
---
max-iterations: 10
---

# Test Loop

Do something.
EOF

    result=$(echo '{}' | "$HOOK_SCRIPT")
    decision=$(echo "$result" | jq -r '.decision')
    reason=$(echo "$result" | jq -r '.reason')
    active=$(jq -r '.active' .groundhog/state.json)
    stopped_reason=$(jq -r '.stopped_reason' .groundhog/state.json)

    if [ "$decision" = "allow" ] && [ "$active" = "false" ] && [ "$stopped_reason" = "iterations_complete" ]; then
        log_pass "Iterations complete stops loop correctly"
    else
        log_fail "Iterations complete should stop loop, got: decision=$decision, active=$active, stopped_reason=$stopped_reason"
    fi
}

# Test 6: Prevent infinite hook loops
test_stop_hook_active_flag() {
    setup
    cat > .groundhog/state.json << 'EOF'
{
  "active": true,
  "loop_name": "test-loop",
  "iteration": 0,
  "max_iterations": 10
}
EOF

    result=$(echo '{"stop_hook_active": true}' | "$HOOK_SCRIPT")
    decision=$(echo "$result" | jq -r '.decision')

    if [ "$decision" = "allow" ]; then
        log_pass "stop_hook_active flag prevents recursion"
    else
        log_fail "stop_hook_active flag should return allow, got: $decision"
    fi
}

# Test 7: JSON output format
test_json_output_format() {
    setup
    rm -f .groundhog/state.json

    result=$(echo '{}' | "$HOOK_SCRIPT")

    if echo "$result" | jq . > /dev/null 2>&1; then
        log_pass "Output is valid JSON"
    else
        log_fail "Output should be valid JSON, got: $result"
    fi
}

# Run all tests
echo "=========================================="
echo "Groundhog Stop Hook Tests"
echo "=========================================="
echo ""

test_no_state_file
test_inactive_loop
test_missing_loop_file
test_active_loop_continues
test_iterations_complete
test_stop_hook_active_flag
test_json_output_format

echo ""
echo "=========================================="
echo -e "Results: ${GREEN}$PASSED passed${NC}, ${RED}$FAILED failed${NC}"
echo "=========================================="

if [ $FAILED -gt 0 ]; then
    exit 1
fi
