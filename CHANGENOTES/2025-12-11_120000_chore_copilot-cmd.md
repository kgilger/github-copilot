---
type: chore
scope: copilot-cmd
date: 2025-12-11T12:00:00
hash: 275117c
branch: main
---

# chore(copilot-cmd): enforce changenote creation and add setup script

## Changes
- `.github/copilot-instructions.md` — added critical instructions to execute ALL workflow steps
- `.github/github-copilot-cmd/commit.md` — reinforced CHANGENOTE mandatory rule with warnings
- `.github/github-copilot-cmd/setup.md` — removed (replaced by PowerShell script)
- `scripts/Setup-Copilot.ps1` — new script to configure VS Code settings for Copilot

## Summary
Improved the `/commit` command reliability by adding explicit warnings about mandatory CHANGENOTE creation. Replaced the `/setup` command with a standalone PowerShell script for better portability and user control over VS Code settings configuration.
