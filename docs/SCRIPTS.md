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
| `validate-skills.sh` | Validates skills against the Agent Skills specification |
| `eval-routing.sh` | Checks that a prompt reaches the skill it should |
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

### Validate Skills

```bash
./scripts/validate-skills.sh              # all skills
./scripts/validate-skills.sh path/to/dir  # a specific skills directory
```

Errors fail the run, recommendations are reported as warnings.

Beyond the spec it checks three things specific to this repository: that the `.claude/skills`
compatibility symlink still resolves to `skills/`, which a checkout without symlink support
silently breaks; that `plugin.json` and `CHANGELOG.md` carry the same version; and that every
skill has at least one case in `evals/routing.tsv`.

That last one is a plain text check with no API call, so it runs on pull requests from forks.
It exists because a skill with no case is a skill nobody checks, and because a new skill
competes with the existing ones for the same prompts. Adding one can move traffic away from
another, which is why the checklist says to run the whole eval, not just the new case.

#### Why two validators

CI runs this script alongside [`skills-ref`](https://pypi.org/project/skills-ref/), the
reference validator from the spec authors. The two cover different ground, so keep both.

`skills-ref` is the authority on the specification. Tracking its latest release is how this
repo finds out that the spec has moved, without anyone having to watch for it.

`validate-skills.sh` covers what `skills-ref` does not: the `allowed-tools` format, which the
spec defines as a space-separated string but the reference implementation accepts as a list or
comma-separated; this repo's convention that every skill ships a `README.md`; and the length
recommendations for the body and the description. It also runs with no Python, which matters in
a repo that is otherwise bash and markdown.

### Check Routing

```bash
./scripts/eval-routing.sh
```

An agent choosing between skills sees their names and descriptions, nothing else. With
eighteen of them the descriptions start competing, and the failure is quiet: the wrong
skill loads and answers plausibly. This runs the cases in `evals/routing.tsv` against the
same `<available_skills>` block an agent gets, and reports where a prompt lands somewhere
other than expected.

Any model will do. Set `EVAL_BASE_URL` to use an OpenAI-compatible endpoint, which most
providers and local runtimes speak:

```bash
EVAL_BASE_URL=https://api.openai.com/v1     EVAL_MODEL=gpt-4o-mini  EVAL_API_KEY=...
EVAL_BASE_URL=http://localhost:11434/v1     EVAL_MODEL=llama3.1     EVAL_API_KEY=ollama
EVAL_BASE_URL=https://openrouter.ai/api/v1  EVAL_MODEL=...          EVAL_API_KEY=...
```

With no `EVAL_BASE_URL` it calls Anthropic directly and reads the key from
`ANTHROPIC_API_KEY`, `ANTHROPIC_API_KEY_FILE`, or `~/.config/anthropic/api-key`. Prefer a
file, so the key stays out of shell history.

The model is named in the summary line, because a result only means something next to the
model that produced it.

Every skill should have at least one case. Cases marked `AMBIGUOUS` have no agreed answer
and are there to record prompts that are underspecified rather than to be fixed.

This is deliberately not a pull request check. Fork pull requests do not get repository
secrets, so it would fail for every outside contributor, and a model's answer can vary
between runs. Run it before a release, or after changing a description.

It does not measure output quality. For that the standard defines `evals/evals.json` per
skill, run with and without the skill to get a baseline. See
[the specification's guidance](https://agentskills.io/skill-creation/evaluating-skills).

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
