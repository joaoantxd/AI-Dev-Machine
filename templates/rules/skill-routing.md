---
name: skill-routing
description: Spontaneous discovery, continuous multi-phase domain routing, and dynamic activation of pertinent skills.
trigger: always_on
---

# Automatic & Dynamic Skill Routing Across the Entire Task Lifecycle

## 1. Continuous Lifecycle Triggers (Dynamic Activation)
Do not restrict skill selection only to Gate 0. Re-evaluate skill relevance dynamically as the task evolves across all phases:

1. **Task Initialization (Gate 0 / Pre-Execution Discovery)**:
   - When receiving a request, match the initial task intent against available `<skills>` in the system prompt.
   - If a skill directly matches the domain, read its `SKILL.md` via `view_file` as your FIRST action before executing deep work.

2. **Stack & Technology Discovery**:
   - When inspecting workspace files and discovering specific frameworks, databases, or tooling not mentioned in the user's initial prompt (e.g., PostgreSQL/Supabase, Next.js, Playwright, WinApp/UIA), load the corresponding domain skill immediately upon discovery.

3. **Phase & Domain Shifts**:
   - When transitioning between different engineering phases within the same task (e.g., moving from architectural mapping to UI styling, database modeling, or security auditing), activate the skill corresponding to the new phase before proceeding.

4. **Failures, Regressions & Unexpected Errors**:
   - When encountering a failing test, build error, unexpected runtime exception, or complex bug during execution, immediately activate `systematic-debugging` (4-phase root cause analysis) or `diagnosing-bugs` before attempting speculative fixes.

5. **Review, Security & Verification Gates**:
   - When entering the review, security check, or completion phase, activate `code-review` / `cybersecurity-review` / `verification-before-completion` before declaring work done.

---

## 2. Spontaneous Domain Mapping
Spontaneously activate the pertinent skill when the intent or domain emerges, even if the user never mentions skill names:

- **Codebase Mapping & Architecture**: Load `graphify` (knowledge graph), `calm` (call graph & blast radius), or `understand-anything` (.ua domain map).
- **Bugs, Failures & Regressions**: Load `systematic-debugging` (investigation before fixes) or `diagnosing-bugs`.
- **UI/UX, Styling & Components**: Load `ui-ux-pro-max` (design systems & tokens), `frontend-design` (distinctive aesthetics), or `impeccable` (craft & polish).
- **Security & Vulnerabilities**: Load `cybersecurity-review` (9 security dimensions), `security-best-practices`, or `security-threat-model`.
- **Database & Postgres**: Load `supabase-postgres-best-practices` (Postgres/RLS/migrations) or `supabase`.
- **Minimal Solutions & YAGNI**: Load `ponytail` for extreme minimalism and standard-library-first design.
- **Windows Desktop & QA**: Load `winapp` for desktop automation and UIA tree verification.
- **E2E & Browser Automation**: Load `playwright` for headless browser tests and flow automation.
- **Completion & Claims**: Load `verification-before-completion` before claiming any fix or milestone is complete.

---

## 3. Operational Discipline & Progressive Disclosure
- **Load on Demand**: Read `SKILL.md` via `view_file` at the exact point in the lifecycle where the need arises.
- **No Redundant Re-Reading**: Do NOT re-read a `SKILL.md` if it was already loaded earlier in the conversation context.
- **No Per-Command Overhead**: Do NOT perform artificial skill checks or pause before every single trivial tool call.
- **Targeted Loading**: Load only the 1-2 skills pertinent to the current active phase. Never bulk-load unrelated skills.
- **Triviality Exemption**: For trivial 1-line typo fixes, answering general conceptual questions, or when no catalog skill matches, proceed directly without artificial skill loading.
- **Follow & Cite**: Apply the specific procedures, checklists, and scripts described in the loaded `SKILL.md`.
