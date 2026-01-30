# Scripts Guide

> How the setup scripts work and how to extend them

## Available Scripts

| Script | Purpose |
|--------|---------|
| `setup-project.sh` | Orchestrates full project setup (runs all scripts below) |
| `link-skills.sh` | Creates `.claude/` directory and symlinks skills |
| `generate-claude-md.sh` | Generates `CLAUDE.md` from template |
| `configure-mcp.sh` | Generates MCP config and optionally adds servers |
| `configure-settings.sh` | Copies Claude Code settings with pre-approved commands |
| `test-all.sh` | Runs all tests to validate scripts work |

## Usage

### Full Setup (Recommended)

```bash
cd /path/to/claude-code-java
./scripts/setup-project.sh /path/to/your-java-project
```

### Individual Scripts

```bash
# Just link skills
./scripts/link-skills.sh /path/to/your-java-project

# Just generate CLAUDE.md
./scripts/generate-claude-md.sh /path/to/your-java-project

# Just configure MCP
./scripts/configure-mcp.sh /path/to/your-java-project

# Just configure settings
./scripts/configure-settings.sh /path/to/your-java-project
```

### Run Tests

```bash
./scripts/test-all.sh
```

## Conventions

All scripts follow the same structure for consistency and reliability.

### Path Resolution Pattern

Every script starts with:

```bash
#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(dirname "$SCRIPT_DIR")"

PROJECT_DIR="$(cd "${1:-.}" && pwd)"
```

**Why this matters:**
- `SCRIPT_DIR` - absolute path to scripts/ directory
- `WORKSPACE_DIR` - absolute path to claude-code-java root
- `PROJECT_DIR` - absolute path to target project (argument or current dir)

This ensures scripts work correctly regardless of:
- Where you run them from
- Whether paths have spaces
- Symlinks in the path

### No `cd` Rule

Scripts should NOT use `cd` to change directories. Instead, use absolute paths:

```bash
# Good
[ -d "$PROJECT_DIR/.claude" ] && mkdir -p "$PROJECT_DIR/.claude"

# Bad
cd "$PROJECT_DIR"
[ -d .claude ] && mkdir -p .claude
```

**Why:** After `cd`, relative paths to templates/workspace resources break.

### Template Files

Templates live in `templates/` and use `{{PLACEHOLDER}}` syntax:

```
templates/
├── CLAUDE.md.template        # {{PROJECT_NAME}}, {{REPO_NAME}}, {{DATE}}
├── mcp-config.json.template  # {{PROJECT_ROOT}}, {{GITHUB_REPO}}
├── MCP_CONFIG.md.template    # {{PROJECT_ROOT}}, {{GITHUB_REPO}}
└── settings.json.template    # Pre-approved Maven/Git commands
```

Scripts use `sed` to replace placeholders:

```bash
sed -e "s/{{PROJECT_NAME}}/$PROJECT_NAME/g" \
    -e "s/{{DATE}}/$DATE/g" \
    "$TEMPLATE_FILE" > "$OUTPUT_FILE"
```

### Error Handling

All scripts use `set -e` to exit on first error. For checks that shouldn't stop execution:

```bash
# This will exit script if file missing
[ ! -f "$FILE" ] && echo "Error" && exit 1

# This continues even if command fails
some_command || true
```

### Output Messages

Use consistent formatting:

```bash
echo "✅ Success message"
echo "❌ Error message"
echo "ℹ️  Info message"
echo "⚠️  Warning message"
```

## Adding a New Script

1. Create file in `scripts/`:

```bash
#!/bin/bash
# new-script.sh - Brief description
# Usage: ./new-script.sh [project-directory]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(dirname "$SCRIPT_DIR")"

PROJECT_DIR="$(cd "${1:-.}" && pwd)"

# Your logic here using absolute paths
```

2. Make executable:

```bash
chmod +x scripts/new-script.sh
```

3. Add tests to `test-all.sh`:

```bash
# Test N: new-script.sh
echo "Testing new-script.sh..."
"$SCRIPT_DIR/new-script.sh" "$TEST_DIR" > /dev/null 2>&1
check "expected result" [ -f "$TEST_DIR/expected-file" ]
echo ""
```

4. Update this documentation.

## Script Dependencies

```
setup-project.sh
    ├── link-skills.sh      (no dependencies)
    ├── generate-claude-md.sh
    │       └── templates/CLAUDE.md.template
    ├── configure-mcp.sh
    │       ├── templates/mcp-config.json.template
    │       └── templates/MCP_CONFIG.md.template
    └── configure-settings.sh
            └── templates/settings.json.template
```

## Troubleshooting

### "Template not found"

Script can't find template file. Check:
- You're running from workspace directory, OR
- Script correctly resolves WORKSPACE_DIR

### "Permission denied"

Scripts need execute permission:

```bash
chmod +x scripts/*.sh
```

### Symlink issues on Windows

Windows requires developer mode or admin rights for symlinks. Consider using WSL or copying files instead of symlinking.
