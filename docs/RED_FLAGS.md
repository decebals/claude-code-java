# Red Flags for AI-generated Changes

Watch for these indicators in diffs or proposed edits:

## Code-level Red Flags

- Unexpected formatting changes (cosmetic only)
- Imports removed or added without reason
- Large-scale renaming or moving files
- Logic refactor that changes behavior subtly

## Workflow-level Red Flags

- AI proposes changes outside its skill scope
- AI ignores previous instructions about restricted files
- Changes are not accompanied by explanations

## Mitigation Strategies

- Reject or pause changes until clarified
- Ask AI to provide rationale for every file modified
- Keep a backup or sandbox for testing diffs

