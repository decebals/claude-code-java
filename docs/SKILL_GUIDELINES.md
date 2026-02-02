# Skill Development Guidelines

> How to design, validate, and implement new skills for claude-code-java

## Purpose

This guide helps contributors create high-quality skills that:
- Fill genuine gaps (not duplicate existing functionality)
- Provide clear, actionable value
- Integrate well with the existing skill ecosystem

---

## Before You Start: Validation Checklist

Before implementing a new skill, answer these questions:

### 1. Does It Already Exist?

Check overlap with existing skills:

| Existing Skill | Level | Focus |
|----------------|-------|-------|
| clean-code | Micro | Functions, naming, DRY/KISS |
| solid-principles | Micro/Meso | Classes, interfaces |
| design-patterns | Meso | Class collaboration patterns |
| java-code-review | Meso | Code review checklist |
| architecture-review | Macro | Packages, modules, layers |
| spring-boot-patterns | Framework | Spring Boot specifics |
| jpa-patterns | Framework | JPA/Hibernate specifics |
| security-audit | Cross-cutting | OWASP, input validation |
| test-quality | Cross-cutting | JUnit 5, AssertJ |

**Ask yourself:**
- Does an existing skill cover >50% of what I want to add?
- Would extending an existing skill be better than creating a new one?

### 2. What Level Does It Operate At?

Skills should have a clear scope:

```
┌─────────────────────────────────────────────────┐
│  Macro    │ Packages, modules, architecture     │
├───────────┼─────────────────────────────────────┤
│  Meso     │ Classes, interfaces, collaboration  │
├───────────┼─────────────────────────────────────┤
│  Micro    │ Functions, variables, expressions   │
├───────────┼─────────────────────────────────────┤
│  Framework│ Spring, JPA, specific technologies  │
├───────────┼─────────────────────────────────────┤
│  Cross    │ Security, testing, logging          │
└───────────┴─────────────────────────────────────┘
```

**Red flag:** A skill that tries to cover multiple levels is probably too broad.

### 3. Is It "Audit" or "Template"?

Two types of skills:

| Type | Purpose | Example |
|------|---------|---------|
| **Audit** | Review existing code, find issues | java-code-review, security-audit |
| **Template** | Show how to write new code | spring-boot-patterns, design-patterns |

**Ask yourself:**
- Which type is my skill?
- Does an existing skill of the same type already cover this?

Example:
- `spring-boot-patterns` = Template (how to write)
- `api-contract-review` = Audit (check existing APIs)
- Both deal with REST APIs, but serve different purposes ✅

### 4. What Unique Value Does It Add?

The skill should add something NEW:

**Good reasons for a new skill:**
- Covers a topic no existing skill addresses
- Same topic but different level (micro vs macro)
- Same topic but different type (audit vs template)
- Specialized depth that doesn't fit in a general skill

**Bad reasons:**
- "It would be nice to have"
- "Other tools have this" (without validating the gap)
- "I want to reorganize existing content"

### 5. Is It Focused Enough?

A skill should be completable in one session. Signs it's too broad:
- More than 10-15 checklist items
- Covers multiple unrelated topics
- Would take hours to apply fully

**Solution:** Split into multiple focused skills.

---

## Skill Anatomy

Every skill has two files:

```
.claude/skills/<skill-name>/
├── SKILL.md    # Instructions for Claude (AI reads this)
└── README.md   # Documentation for humans
```

### SKILL.md Structure

```markdown
---
name: skill-name
description: One-line description. Use when [triggers].
---

# Skill Name

Brief intro (1-2 sentences).

## When to Use
- Trigger phrase 1
- Trigger phrase 2

## Quick Reference
[Table or summary for fast lookup]

## Main Content
[Checklists, patterns, examples]

## Token Optimization
[How to use efficiently on large codebases]
```

### README.md Structure

```markdown
# Skill Name

> One-line tagline

## What It Does
[2-3 sentences]

## When to Use
[Bullet points with example phrases]

## Key Concepts
[Brief explanation of main ideas]

## Example Usage
[Show a typical interaction]

## Related Skills
[Links to complementary skills]

## References
[External resources]
```

---

## Quality Standards

### Content Guidelines

1. **Be Specific to Java**
   - Use Java syntax in examples
   - Reference Java ecosystem tools (Maven, JUnit, Spring)
   - Don't be generic - that's what other skills collections do

2. **Provide Actionable Checklists**
   - ✅ `- [ ] Check for null safety with Optional`
   - ❌ `- [ ] Make sure code is good`

3. **Show Anti-Patterns**
   ```java
   // ❌ BAD: Why this is wrong
   badCode();

   // ✅ GOOD: Why this is right
   goodCode();
   ```

4. **Include Severity Levels**
   - High: Bugs, security issues, performance killers
   - Medium: Code smells, maintainability issues
   - Low: Style, minor optimizations

### Token Efficiency

Skills should help Claude work efficiently:

1. **Prioritize checks** - Most important first
2. **Provide commands** - Shell commands to gather info quickly
3. **Suggest sampling** - "Check 2-3 examples, not every file"
4. **Exit early** - "If X, skip Y checks"

---

## Validation Process

Before submitting a new skill:

### Step 1: Gap Analysis

```markdown
## Proposed: <skill-name>

### What it does
[Description]

### Overlap check
| Existing Skill | Overlap? | Notes |
|----------------|----------|-------|
| skill-1 | None/Partial/High | ... |
| skill-2 | None/Partial/High | ... |

### Unique value
[What this adds that doesn't exist]

### Verdict
[ ] No significant overlap - proceed
[ ] Partial overlap - document distinction
[ ] High overlap - consider extending existing skill instead
```

### Step 2: Peer Review Questions

Ask yourself (or a reviewer):

1. Would I actually use this skill in a real project?
2. Can I explain in one sentence when to use it vs related skills?
3. Does the checklist have <15 items?
4. Are all examples in Java (not pseudocode)?

### Step 3: Test on Real Code

Before committing:
- Apply the skill to a real Java project
- Verify the checklist makes sense
- Check that recommendations are actionable

---

## Anti-Patterns to Avoid

### 1. The Kitchen Sink

❌ **Bad:** A skill that tries to cover everything
```
java-best-practices/
  - Covers coding style
  - AND testing
  - AND architecture
  - AND security
  - AND performance
```

✅ **Good:** Focused skills that compose well

### 2. The Overlap Trap

❌ **Bad:** Creating `exception-handling-review` when `java-code-review` already has an exceptions section

✅ **Good:** Extend `java-code-review` or ensure the new skill has a clearly different scope

### 3. The Copy-Paste Skill

❌ **Bad:** Copying generic advice from the internet

✅ **Good:** Java-specific, opinionated, practical guidance

### 4. The Theoretical Skill

❌ **Bad:** Explaining concepts without actionable checks

✅ **Good:** Checklists that can be applied immediately

---

## Extending vs Creating

Sometimes extending an existing skill is better:

### When to Extend

- Adding <5 new checklist items
- Same level and type as existing skill
- Naturally fits the existing structure

### When to Create New

- Different level (micro vs macro)
- Different type (audit vs template)
- Would make existing skill too long (>200 lines)
- Distinct trigger phrases

### How to Extend

1. Read the existing skill thoroughly
2. Identify where new content fits
3. Add new section or expand existing
4. Update README if needed
5. Commit with clear message: `enhance(skill-name): add X checks`

---

## Commit Convention

For skill changes:

```
feat: add <skill-name> skill          # New skill
enhance(<skill-name>): add X checks   # Extend existing
fix(<skill-name>): correct Y example  # Fix issues
docs(<skill-name>): improve Z section # Documentation only
```

---

## Iterative Improvement

Skills improve through real usage. A skill is never "done" after the first version.

### Signs a Skill Needs Refinement

| Signal | Problem | Solution |
|--------|---------|----------|
| Claude asks clarifying questions | Missing context or defaults | Add explicit defaults and examples |
| You frequently correct the output | Missing constraints | Add "DO NOT" rules or format specs |
| Output varies too much | Too vague | Add concrete examples of expected output |
| Works on one project, fails on another | Too narrow | Generalize patterns, add edge cases |
| Takes many iterations to get right | Missing structure | Add step-by-step workflow |

### Improvement Workflow

1. **Use the skill** on real work
2. **Note every correction** you make to Claude's output
3. **Update SKILL.md** with the correction as a rule
4. **Clear context** and test again
5. **Repeat 5-6 times** until stable

### Maturity Indicators

A skill is mature when:
- Works on first try >80% of the time
- No steering or corrections needed
- Output is copy-paste ready
- Works across different projects

### Optional: Track Iterations

Consider adding to your skill folder:

```
.claude/skills/<skill-name>/
├── SKILL.md
├── README.md
└── CHANGELOG.md   # Optional: track refinements
```

Example CHANGELOG.md:
```markdown
## Iteration History
- v1: Initial version, too vague
- v2: Added output format specification
- v3: Added "avoid" list after common mistakes
- v4: Added examples for edge cases
- v5: Stable - tested on 3 projects
```

---

## Checklist Summary

Before submitting a new skill:

- [ ] Checked overlap with all existing skills
- [ ] Identified clear level (micro/meso/macro/framework/cross)
- [ ] Determined type (audit vs template)
- [ ] Documented unique value added
- [ ] SKILL.md follows structure convention
- [ ] README.md provides human-friendly docs
- [ ] All examples are Java-specific
- [ ] Checklist has <15 actionable items
- [ ] Tested on real code
- [ ] Updated skills/README.md table
- [ ] Updated main README.md if needed
