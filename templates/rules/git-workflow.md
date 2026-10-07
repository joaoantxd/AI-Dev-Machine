---
name: git-workflow
description: Git discipline, atomic commits, branch protection, and working tree preservation.
trigger: model_decision
---

# Git Discipline & Working Tree Rules

## 1. Preserve User Working Tree
- Never discard, revert, or overwrite uncommitted changes from the user that lie outside the task's scope.
- Always inspect `git status` and `git diff` before making edits or staging changes.

## 2. Atomic & Cohesive Commits
- Commits must represent a single logical change with an accurate, descriptive message.
- Separate refactoring from functional changes whenever possible.

## 3. History & Branch Protection
- Never execute force push (`git push --force`) or destructive history rewrites on shared branches without explicit confirmation.
- Never commit `.env` files, credentials, local debug logs, or temporary build artifacts.
- Keep machine-local junctions (`.agents/skills/`) and temporary backups ignored in `.gitignore`, while tracking declarative project governance (`.agents/rules/`, `.agents/agents/`, `.agents/hooks.json`, `.agents/mcp_config.json`).
