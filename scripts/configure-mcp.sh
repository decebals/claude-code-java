#!/bin/bash
# configure-mcp.sh - Generate MCP config and optionally add servers
# Usage: ./configure-mcp.sh [project-directory]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(dirname "$SCRIPT_DIR")"

PROJECT_DIR="$(cd "${1:-.}" && pwd)"
TEMPLATE_FILE="$WORKSPACE_DIR/templates/mcp-config.json.template"
OUTPUT_FILE="$PROJECT_DIR/mcp-config.json"
DOC_FILE="$PROJECT_DIR/MCP_CONFIG.md"

[ ! -f "$TEMPLATE_FILE" ] && echo "❌ Template not found: $TEMPLATE_FILE" && exit 1

# Detect GitHub repo if git remote exists
if git -C "$PROJECT_DIR" remote get-url origin &>/dev/null; then
    DEFAULT_GITHUB_REPO=$(git -C "$PROJECT_DIR" remote get-url origin)
else
    DEFAULT_GITHUB_REPO=""
fi

# Prompt user for GitHub MCP repo
if [ -n "$DEFAULT_GITHUB_REPO" ]; then
    read -p "GitHub repo for MCP [${DEFAULT_GITHUB_REPO}]: " INPUT_REPO
    GITHUB_REPO=${INPUT_REPO:-$DEFAULT_GITHUB_REPO}
else
    read -p "GitHub repo for MCP (leave blank to skip GitHub MCP): " INPUT_REPO
    GITHUB_REPO=${INPUT_REPO:-""}
fi

# Prompt for local filesystem root MCP
read -p "Local filesystem root for MCP [${PROJECT_DIR}]: " INPUT_ROOT
PROJECT_ROOT=${INPUT_ROOT:-$PROJECT_DIR}

# Warn if GITHUB_TOKEN is missing
if [ -n "$GITHUB_REPO" ] && [ -z "$GITHUB_TOKEN" ]; then
    echo -e "\033[1;33m⚠️  GITHUB_TOKEN is not set!\033[0m"
    echo "You will not be able to use GitHub MCP without a valid token."
    echo "Please export the environment variable:"
    echo "  export GITHUB_TOKEN=<your-token>"
    echo "For more information see MCP_CONFIG.md"
fi

# Generate MCP config from template
sed -e "s|{{PROJECT_ROOT}}|$PROJECT_ROOT|g" \
    -e "s|{{GITHUB_REPO}}|$GITHUB_REPO|g" \
    "$TEMPLATE_FILE" > "$OUTPUT_FILE"

echo "✅ MCP config generated at $OUTPUT_FILE"

# Generate MCP_CONFIG.md instructions from template
DOC_TEMPLATE="$WORKSPACE_DIR/templates/MCP_CONFIG.md.template"
if [ -f "$DOC_TEMPLATE" ]; then
    sed -e "s|{{PROJECT_ROOT}}|$PROJECT_ROOT|g" \
        -e "s|{{GITHUB_REPO}}|$GITHUB_REPO|g" \
        "$DOC_TEMPLATE" > "$DOC_FILE"
    echo "✅ MCP instructions generated at $DOC_FILE"
fi

# Optional: configure servers via Claude CLI
if command -v claude &>/dev/null; then
    echo ""
    if [ -n "$GITHUB_REPO" ]; then
        read -p "Add GitHub MCP server now? (y/n) " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            claude mcp add github --transport http "$GITHUB_REPO"
        fi
    fi

    read -p "Add local filesystem MCP server now? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        claude mcp add filesystem --scope local -- npx @modelcontextprotocol/server-filesystem --path "$PROJECT_ROOT"
    fi

    read -p "Add local git MCP server now? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        claude mcp add git --scope local -- npx @modelcontextprotocol/server-git --path "$PROJECT_ROOT"
    fi
fi

echo "🎉 MCP setup complete!"
