#!/bin/bash
# generate-claude-md.sh - Generate CLAUDE.md from template
# Usage: ./generate-claude-md.sh [project-directory]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(dirname "$SCRIPT_DIR")"

PROJECT_DIR="$(cd "${1:-.}" && pwd)"
TEMPLATE_FILE="$WORKSPACE_DIR/templates/CLAUDE.md.template"
OUTPUT_FILE="$PROJECT_DIR/CLAUDE.md"

[ ! -f "$TEMPLATE_FILE" ] && echo "❌ Template not found: $TEMPLATE_FILE" && exit 1

# Detect project and repo
PROJECT_NAME=$(basename "$PROJECT_DIR")
if git -C "$PROJECT_DIR" remote get-url origin &>/dev/null; then
    REPO_NAME=$(git -C "$PROJECT_DIR" remote get-url origin | xargs basename -s .git)
else
    REPO_NAME="$PROJECT_NAME"
fi

DATE=$(date +"%Y-%m-%d")

# Generate CLAUDE.md
sed -e "s/{{PROJECT_NAME}}/$PROJECT_NAME/g" \
    -e "s/{{REPO_NAME}}/$REPO_NAME/g" \
    -e "s/{{DATE}}/$DATE/g" \
    "$TEMPLATE_FILE" > "$OUTPUT_FILE"

echo "✅ CLAUDE.md generated at $OUTPUT_FILE"
