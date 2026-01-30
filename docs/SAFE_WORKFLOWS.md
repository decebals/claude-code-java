# Safe Workflows for claude-code-java Skills

This guide provides step-by-step workflows to maintain safety and control while using AI skills.

## Workflow: Human-in-the-loop (Recommended)

1. **Analyze**
   - Use read-only skills to inspect code, tests, or issues.
2. **Explain**
   - AI summarizes findings, highlights potential changes.
3. **Propose**
   - AI generates a diff or suggested edits in a sandbox.
4. **Review**
   - Developer reviews all proposed changes.
   - Approves/rejects file by file.
5. **Apply**
   - Changes are manually applied to project or git staging.
6. **Commit**
   - Developer commits changes to git.
   - Optionally tag for auditing.

## Levels of Skill Access

| Level | Description | Recommended? |
|-------|------------|--------------|
| 0 | Read-only analysis | ✅ Highly recommended |
| 1 | Proposal skills (sandbox write) | ✅ Use with review |
| 2 | Auto-apply writes | ⚠️ Only in very controlled experiments |
| 3 | Auto git commits | ❌ Not recommended |

## Notes

- Always check diffs before approving.
- Never rely solely on AI-generated decisions for public APIs or critical functionality.

