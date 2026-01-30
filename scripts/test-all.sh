#!/bin/bash
# test-all.sh - Test all setup scripts
# Usage: ./scripts/test-all.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(dirname "$SCRIPT_DIR")"

# Create temp directory, cleanup on exit
TEST_DIR=$(mktemp -d)
trap "rm -rf $TEST_DIR" EXIT

echo "Testing in: $TEST_DIR"
echo ""

PASS=0
FAIL=0

check() {
    local description="$1"
    shift
    if "$@" 2>/dev/null; then
        echo "  ✓ $description"
        PASS=$((PASS + 1))
    else
        echo "  ✗ $description"
        FAIL=$((FAIL + 1))
    fi
}

# Test 1: link-skills.sh
echo "Testing link-skills.sh..."
"$SCRIPT_DIR/link-skills.sh" "$TEST_DIR" > /dev/null 2>&1
check ".claude directory created" [ -d "$TEST_DIR/.claude" ]
check "skills symlink created" [ -L "$TEST_DIR/.claude/skills" ]
LINK_TARGET=$(readlink "$TEST_DIR/.claude/skills" 2>/dev/null || echo "")
check "symlink points to workspace" [ "$LINK_TARGET" = "$WORKSPACE_DIR/.claude/skills" ]
echo ""

# Test 2: generate-claude-md.sh
echo "Testing generate-claude-md.sh..."
"$SCRIPT_DIR/generate-claude-md.sh" "$TEST_DIR" > /dev/null 2>&1
check "CLAUDE.md created" [ -f "$TEST_DIR/CLAUDE.md" ]
check "CLAUDE.md has content" [ -s "$TEST_DIR/CLAUDE.md" ]
echo ""

# Test 3: configure-mcp.sh (non-interactive check only)
echo "Testing configure-mcp.sh..."
check "MCP template exists" [ -f "$WORKSPACE_DIR/templates/mcp-config.json.template" ]
echo ""

# Test 4: configure-settings.sh
echo "Testing configure-settings.sh..."
"$SCRIPT_DIR/configure-settings.sh" "$TEST_DIR" > /dev/null 2>&1
check "settings.json created" [ -f "$TEST_DIR/.claude/settings.json" ]
check "settings.json has content" [ -s "$TEST_DIR/.claude/settings.json" ]
echo ""

# Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Results: $PASS passed, $FAIL failed"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

[ $FAIL -eq 0 ] && exit 0 || exit 1
