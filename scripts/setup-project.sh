#!/bin/bash
# setup-project.sh - Orchestrate project setup
# Usage: ./setup-project.sh [project-directory]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PROJECT_DIR="$(cd "${1:-.}" && pwd)"

echo "ℹ️  Setting up project in $PROJECT_DIR"

# Step 1: Link skills
"$SCRIPT_DIR/link-skills.sh" "$PROJECT_DIR"

# Step 2: Generate CLAUDE.md
"$SCRIPT_DIR/generate-claude-md.sh" "$PROJECT_DIR"

# Step 3: Configure MCP
"$SCRIPT_DIR/configure-mcp.sh" "$PROJECT_DIR"

# Step 4: Configure settings
"$SCRIPT_DIR/configure-settings.sh" "$PROJECT_DIR"

echo "✅ Setup complete!"
