#!/bin/bash
# configure-settings.sh - Copy Claude Code settings template to project
# Usage: ./configure-settings.sh [project-directory]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(dirname "$SCRIPT_DIR")"
TEMPLATE="$WORKSPACE_DIR/templates/settings.json.template"

PROJECT_DIR="$(cd "${1:-.}" && pwd)"
TARGET_DIR="$PROJECT_DIR/.claude"
TARGET="$TARGET_DIR/settings.json"

if [[ ! -f "$TEMPLATE" ]]; then
    echo "❌ Template not found: $TEMPLATE"
    exit 1
fi

# Ensure .claude directory exists
mkdir -p "$TARGET_DIR"

if [[ -f "$TARGET" ]]; then
    echo "⚠️  Settings already exists: $TARGET (skipped)"
else
    cp "$TEMPLATE" "$TARGET"
    echo "✅ Created $TARGET"
fi
