---
name: skill-routing
description: Spontaneous discovery, domain routing, and pre-execution activation of pertinent skills.
trigger: always_on
---

# Automatic Skill Routing & Pre-Execution Activation

## 1. Pre-Execution Discovery & Matching (Gate 0)
- Before executing ad-hoc file exploration, grep fishing, or writing code on non-trivial tasks, match the task domain against available `<skills>` in the system prompt.
- If a skill directly matches the domain, **read its `SKILL.md` via `view_file` as your FIRST action** before executing deep work.

## 2. Spontaneous Domain Mapping
Spontaneously activate the pertinent skill when the intent matches, even if the user never mentions skill names:
- **Codebase Mapping & Architecture**: Load `graphify` (query knowledge graph) or `calm` (call graphs/blast radius) or `understand-anything`.
- **Bugs, Failures & Regressions**: Load `systematic-debugging` (4-phase root cause analysis) or `diagnosing-bugs`.
- **UI/UX, Styling & Components**: Load `ui-ux-pro-max` (design tokens/guidelines) or `frontend-design` or `impeccable`.
- **Security & Vulnerabilities**: Load `cybersecurity-review` or `security-best-practices`.
- **Database & Postgres**: Load `supabase-postgres-best-practices` or `supabase`.
- **Minimal Solutions & YAGNI**: Load `ponytail` for extreme minimalism and standard-library-first design.
- **Windows Desktop & QA**: Load `winapp` for desktop automation and UIA tree verification.
- **Completion & Claims**: Load `verification-before-completion` before claiming any fix or milestone is complete.

## 3. Progressive Disclosure & YAGNI
- **Never bulk-load skills**: Load only the 1-2 skills relevant to the active phase.
- **Triviality Exemption**: For trivial 1-line typo fixes, answering general conceptual questions, or when no catalog skill matches, proceed directly without artificial skill loading.
- **Follow & Cite**: Apply the specific procedures, checklists, and scripts described in the loaded `SKILL.md`.
