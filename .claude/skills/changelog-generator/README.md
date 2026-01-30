# Changelog Generator

**Load**: `view .claude/skills/changelog-generator/SKILL.md`

---

## Description

Generates changelogs from git commits following established conventions. Automatically detects versioning style and changelog format from existing project files (CLAUDE.md, git tags, CHANGELOG.md).

---

## Use Cases

- "Generate changelog since last release"
- "What changed since v3.14.0?"
- "Update CHANGELOG.md for version 3.16"
- "Preview unreleased changes"

---

## Examples

```
> view .claude/skills/changelog-generator/SKILL.md
> "Generate changelog for pf4j"
→ Detects pf4j format and SemVer style, outputs matching changelog
```

---

## Key Features

- **Versioning detection**: SemVer (x.y.z), Two-component (x.y), CalVer (YYYY.MM)
- **Format detection**: Adapts to existing CHANGELOG.md style
- **Reference-style links**: Clean `[#123]` format with definitions at bottom
- **Version comparison links**: Auto-generates GitHub compare URLs
- **Legacy support**: Works with projects without explicit conventions

---

## Detection Priority

1. CLAUDE.md `## Versioning` section
2. Git tags pattern analysis
3. Existing CHANGELOG.md format
4. Ask user (last resort)

---

## Notes / Tips

- Works best with conventional commits (pairs with git-commit skill)
- For legacy projects, suggests adding versioning convention to CLAUDE.md
- Preserves existing link definitions when updating
