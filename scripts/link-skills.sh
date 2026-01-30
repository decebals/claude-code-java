#!/bin/bash
# link-skills.sh - Setup claude-code-java skills in a Java project
# Usage: ./link-skills.sh [project-directory]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(dirname "$SCRIPT_DIR")"

PROJECT_DIR="$(cd "${1:-.}" && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

error() { echo -e "${RED}❌ $1${NC}"; exit 1; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
info() { echo -e "${BLUE}ℹ️  $1${NC}"; }

# Check dirs
[ ! -d "$WORKSPACE_DIR/.claude/skills" ] && error "Skills not found at $WORKSPACE_DIR/.claude/skills"
[ ! -d "$PROJECT_DIR" ] && error "Project dir not found: $PROJECT_DIR"

# Create .claude if missing
[ ! -d "$PROJECT_DIR/.claude" ] && mkdir -p "$PROJECT_DIR/.claude" && success "Created .claude directory"

# Symlink skills
if [ -L "$PROJECT_DIR/.claude/skills" ]; then
    info "Skills already linked"
elif [ -d "$PROJECT_DIR/.claude/skills" ]; then
    echo -e "${YELLOW}⚠️  .claude/skills exists but is not a symlink. Backup/remove manually.${NC}"
else
    ln -sf "$WORKSPACE_DIR/.claude/skills" "$PROJECT_DIR/.claude/skills"
    success "Linked skills to project"
fi

info "Linking skills complete"
