---
name: issue-triage
description: Triage and categorize GitHub issues with priority labels. Use when user says "triage issues", "check issues", "review open issues", or during regular maintenance of GitHub issue backlog.
---

# Issue Triage Skill

Efficiently triage GitHub issues for Java projects with categorization and prioritization.

## When to Use
- User says "triage issues" / "check recent issues"
- Regular maintenance workflow
- After vacation/break (backlog processing)
- Weekly/monthly issue review

## Prerequisites

**Recommended**: GitHub MCP server configured for optimal token usage
```bash
claude mcp add github --transport http \
  https://api.githubcopilot.com/mcp/
```

**Alternative**: Use `gh` CLI (less token-efficient)

## Workflow

### 1. Fetch Issues

**With GitHub MCP** (recommended):
```
Tool: list_issues
Parameters: {
  "state": "open",
  "sort": "updated", 
  "per_page": 10
}
```

**With gh CLI**:
```bash
gh issue list --state open --limit 10 --json number,title,labels,body,url
```

### 2. Categorize Each Issue

Analyze issue content and assign category:

#### Bug Report ✅
**Indicators**:
- Has stack trace or error message
- Steps to reproduce provided
- Expected vs actual behavior described
- Mentions specific version numbers

**Actions**:
- Label: `bug`
- Verify reproducibility from description
- Check for duplicate bugs
- Add to milestone if critical

**Example**:
```
Issue #234: "NPE when loading plugin from directory"
- Stack trace: ✅
- Reproduction steps: ✅
- Version info: ✅
→ Label: bug, high-priority
```

#### Feature Request 💡
**Indicators**:
- Asks for new functionality
- Use case described
- "It would be nice if..." / "Could you add..."
- Rationale provided

**Actions**:
- Label: `enhancement`
- Assess alignment with project goals
- Mark for discussion if non-trivial
- Ask for community feedback

#### Question/Support ❓
**Indicators**:
- "How do I..." / "Can someone help..."
- Configuration/usage questions
- Not a bug or feature request

**Actions**:
- Label: `question`
- Provide answer or link to docs
- Suggest StackOverflow for complex help
- Close after answer if resolved

#### Duplicate 🔄
**Search for similar issues**:
- Use GitHub search: `is:issue <keywords>`
- Check recently closed issues
- Look for same error messages

**Actions**:
- Link to original: "Duplicate of #123"
- Close with polite comment
- Ask reporter to comment on original if they have additional info

#### Invalid/Unclear ⚠️
**Indicators**:
- Missing critical information
- Off-topic or spam
- Not enough context to proceed

**Actions**:
- Request clarification with template
- Set "needs-more-info" label
- Auto-close if no response after 14 days

### 3. Priority Assessment

#### Critical (P0) 🔴
**Criteria**:
- Security vulnerability
- Data loss/corruption risk
- Complete functionality breakdown
- Affects production systems

**Actions**:
- Label: `critical`
- Notify maintainers immediately
- Add to current milestone
- Consider hotfix release

**Examples**:
```
- "SQL injection vulnerability in plugin loader"
- "All plugins fail to load after upgrade"
- "ClassLoader leak causes OutOfMemoryError"
```

#### High (P1) 🟠
**Criteria**:
- Core feature broken
- Affects many users
- Workaround exists but painful
- Regression from previous version

**Actions**:
- Label: `high-priority`
- Add to next milestone
- Include in release notes

**Examples**:
```
- "Plugin dependencies not resolved correctly"
- "Hot reload crashes application"
```

#### Medium (P2) 🟡
**Criteria**:
- Edge case bug
- Enhancement with clear value
- Documentation gap
- Affects some users occasionally

**Actions**:
- Label: `medium-priority`
- Consider for future milestone
- Good for contributors

**Examples**:
```
- "Improve error message for invalid plugin"
- "Add plugin lifecycle listener"
```

#### Low (P3) 🟢
**Criteria**:
- Nice-to-have feature
- Cosmetic issues
- Very rare edge case
- Documentation improvements

**Actions**:
- Label: `low-priority`
- "Contributions welcome" tag
- Backlog for future

**Examples**:
```
- "Add more examples to README"
- "Typo in JavaDoc"
```

### 4. Response Templates

#### Need More Information
```markdown
Thanks for reporting this issue! 

To investigate further, could you provide:
- Java version (java -version)
- Library version
- Minimal reproducible example
- Full stack trace (if applicable)
- Configuration files (if relevant)

This will help us diagnose and fix the issue faster.
```

#### Duplicate
```markdown
Thanks for reporting! This is being tracked in #123.

Closing as duplicate. Feel free to add any additional context 
or information to the original issue.
```

#### Won't Fix (with rationale)
```markdown
Thank you for the suggestion. After consideration, this doesn't 
align with the project's current direction because [reason].

Consider [alternative approach] instead, which might better 
serve your use case.

If you feel strongly about this, please open a discussion in 
our [forum/discussions] to gather community feedback.
```

#### Acknowledged Bug
```markdown
Confirmed! This is a valid bug. 

I've added it to milestone X.Y and labeled it as [priority].
Contributions welcome if anyone wants to tackle it!

Reproduction verified with:
- Java 17
- Version 3.10.0
- Ubuntu 22.04
```

#### Feature Request - Under Consideration
```markdown
Interesting idea! This aligns with our goal of [project goal].

I've labeled this as 'enhancement' for further discussion.
Community feedback welcome - upvote with 👍 if you'd find 
this useful.

Some questions to consider:
- [question 1]
- [question 2]
```

#### Question Answered
```markdown
To achieve this, you can [solution].

Example:
\`\`\`java
[code example]
\`\`\`

Also check our documentation: [link]

Let me know if this solves your issue!
```

## Token Optimization Strategies

### Batch Processing
```bash
# Process multiple issues in one prompt
"Triage issues #234-243, categorize and prioritize"
```

**Savings**: ~60% fewer tokens vs one-by-one

### Use Structured GitHub MCP Calls
- One call to list issues → cache results
- Targeted calls for details only when needed
- Batch label updates

**Savings**: ~40% fewer tokens vs repeated bash calls

### Cache Issue List
```bash
# First prompt
"Fetch the last 20 issues, save list in memory"

# Subsequent prompts
"Analyze issue #5 from cached list"
"Mark #7-#9 as duplicate"
```

### Focus on First Post + Recent Comments
- Don't read entire 50-comment threads
- Skim first post for context
- Check last 2-3 comments for updates

## Anti-patterns

❌ **Avoid**:
```
# One-by-one processing
"Check issue #234"
"Now check issue #235"
"Now check issue #236"
→ Wastes tokens on repeated context loading

# Over-analyzing
Reading entire 100-comment thread
Checking all related PRs
Deep diving into code for each issue
→ Diminishing returns after certain point

# Premature closing
Closing issues without proper investigation
Missing duplicates due to poor search
→ Frustrates users, creates duplicate work
```

✅ **Prefer**:
```
# Batch operations
"Triage issues #234-250, categorize, prioritize"

# Quick triage decisions
Fast categorization → Can revisit if needed
Surface-level analysis for most issues
Deep dive only for critical/complex ones

# Thorough duplicate search
Quick keyword search before marking duplicate
Link to specific comment if clarification exists
```

## Automation Opportunities

### Auto-close stale issues
```bash
# Issues with no activity for 90 days and "needs-more-info" label
"Find stale issues (>90 days, needs-more-info label), 
suggest closing with polite message"
```

### Label by keywords
```bash
# Auto-label based on content
"java.lang.NullPointerException" → bug
"add support for" → enhancement
"how do I" → question
```

### Weekly summary
```bash
# Generate triage summary
"Summarize issues from last week:
- New bugs: X
- Feature requests: Y
- Questions: Z
- Closed: W"
```

## Integration with GitHub

### With GitHub MCP
```javascript
// Structured workflow
1. list_issues → get open issues
2. get_issue → details for each
3. add_labels → categorize
4. create_comment → respond
5. close_issue → if needed
```

### With gh CLI
```bash
# List issues
gh issue list --json number,title,labels,body

# View specific issue
gh issue view 234

# Add labels
gh issue edit 234 --add-label "bug,high-priority"

# Comment
gh issue comment 234 --body "Thanks for reporting..."

# Close
gh issue close 234 --comment "Fixed in v2.1"
```

## Metrics to Track

After each triage session, report:

```
📊 Triage Summary
─────────────────
Issues processed: 15
├─ Bugs: 5 (2 critical, 3 high)
├─ Enhancements: 4
├─ Questions: 3
├─ Duplicates: 2
└─ Invalid: 1

Actions taken:
├─ Labeled: 15
├─ Responded: 12
├─ Closed: 3
└─ Milestoned: 5

Time saved: ~45 minutes (vs manual)
Token usage: 3,200 tokens
```

## Best Practices

1. **Regular cadence** - Weekly triage prevents backlog
2. **Be respectful** - Users took time to report
3. **Link resources** - Docs, related issues, examples
4. **Ask questions** - Better to clarify than assume
5. **Welcome contributions** - Encourage community involvement
6. **Track patterns** - Common issues suggest documentation gaps
7. **Celebrate reporters** - Thank users for good bug reports
8. **Close decisively** - Don't let issues linger indefinitely

## Example Workflow

```bash
# Monday morning triage
claude code ~/projects/pf4j

> view .claude/skills/issue-triage/SKILL.md
> "Triage the last 15 issues from pf4j/pf4j,
   categorize, prioritize and suggest responses"

[Claude analyzes and presents summary]

> "Apply labels and post the suggested responses"

[Claude executes actions]

> "Generate summary for release notes"
```

**Result**: 15 issues triaged in ~10 minutes vs ~45 minutes manual
