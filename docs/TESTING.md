# Testing Strategy

> How to test and validate claude-code-java scripts and skills

## Current Approach: Simple Test Script

A bash test script validates that the setup scripts work and that the skills conform to the
Agent Skills specification. It runs locally and in CI on every push and pull request.

### Running Tests

```bash
./scripts/test-all.sh
```

### What It Tests

| Script | Validations |
|--------|-------------|
| `link-skills.sh` | Creates `.claude/`, symlink points to workspace |
| `generate-claude-md.sh` | Creates `CLAUDE.md` with content |
| `configure-mcp.sh` | Template file exists |
| `configure-settings.sh` | Creates `settings.json` with content |
| `validate-skills.sh` | Every skill passes the Agent Skills spec checks |

### Test Philosophy

- Tests run in a temporary directory (auto-cleaned)
- Zero external dependencies. The reference validator `skills-ref` needs Python, so it runs as
  a separate CI job rather than inside `test-all.sh`
- Fast execution (< 2 seconds)
- Clear pass/fail output

## Future Options

### Option 1: bats-core (Recommended for growth)

[bats-core](https://github.com/bats-core/bats-core) - Bash Automated Testing System

**When to adopt:**
- 10+ test cases
- Multiple contributors
- Want better test organization (describe/it blocks)

**Example:**
```bash
@test "link-skills creates symlink" {
    run ./scripts/link-skills.sh "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ -L "$TEST_DIR/.claude/skills" ]
}
```

**Install:** `npm install -g bats` or `brew install bats-core`

### Option 2: Pre-commit Hook

**When to adopt:**
- Want to catch issues before commit
- Local-only validation

**Setup:**
```bash
# .git/hooks/pre-commit
#!/bin/bash
./scripts/test-all.sh || exit 1
```

## Decision Framework

| Phase | Recommended Approach |
|-------|---------------------|
| MVP | Simple test script |
| Public release | GitHub Actions (adopted, `.github/workflows/test.yml`) |
| Growth with contributors | Add bats-core |
| Team adoption | Add pre-commit hooks |

## Adding New Tests

When adding a new script, add corresponding tests to `test-all.sh`:

```bash
# Test N: new-script.sh
echo "Testing new-script.sh..."
"$SCRIPT_DIR/new-script.sh" "$TEST_DIR" > /dev/null 2>&1
check "expected output created" [ -f "$TEST_DIR/expected-output" ]
echo ""
```

## Manual Testing Checklist

For changes that are hard to automate:

- [ ] Run `setup-project.sh` on a real Java project
- [ ] Verify skills symlink works in Claude Code
- [ ] Test on fresh directory (no existing `.claude/`)
- [ ] Test on directory with existing `.claude/skills`
