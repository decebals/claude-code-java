# Design Principles for claude-code-java

This document explains the core philosophy behind the AI skills and workflows in this workspace.

## 1. Human-in-the-loop

- **Developer decides**: The AI proposes changes; the developer reviews and approves.
- **No automatic commits or writes to git** without explicit approval.
- Skills generate outputs in a controlled environment, such as diffs or read-only views.

## 2. Reproducibility

- Skills are versioned and reusable.
- Workflows should produce consistent results when rerun with the same context.
- Metrics and outputs are measurable: token usage, time saved, coverage improvements.

## 3. Safety

- AI should never modify files outside its defined scope.
- Any skill that writes to disk should:
  - indicate what files will change
  - allow for review before application

## 4. Transparency

- Every proposed change should be explainable:
  - why the change is needed
  - what files are affected
- Logs or explanations should be available alongside diffs.

## 5. Incremental adoption

- Start with read-only / analysis skills.
- Move to proposal skills.
- Only then consider mutation skills with review.

