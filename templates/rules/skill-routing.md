---
name: skill-routing
description: Continuous, multi-turn, and dynamic skill routing across the entire lifecycle of single-task and multi-task conversations.
trigger: always_on
---

# Continuous & Dynamic Skill Routing Across Multi-Turn Conversations

## 1. Multi-Turn & Per-Request Lifecycle Triggers
Do not treat skill evaluation as a one-time event at session start. Re-evaluate available `<skills>` continuously across every turn and phase of the conversation:

1. **Every New User Request / Shift of Intent (Multi-Turn Re-evaluation)**:
   - Whenever the user sends a new message or starts a new task in the same conversation (e.g., transitioning from debugging to architecture, from architecture to UI/UX, or from backend to testing):
   - **Immediately match the new request's intent against available `<skills>` in the system prompt**.
   - If the new intent matches a skill that has not yet been loaded in this conversation, **read its `SKILL.md` via `view_file` as your FIRST action in that turn** before performing deep exploration or edits.

2. **Stack & Technology Discovery**:
   - When inspecting workspace files and discovering specific frameworks, databases, or tooling not mentioned in the prompt (e.g., PostgreSQL/Supabase, Next.js, Playwright, WinApp/UIA), load the corresponding domain skill immediately upon discovery.

3. **Phase & Subtask Transitions**:
   - When moving between different engineering phases within the same task (e.g., moving from architectural mapping to interface design, database modeling, or security auditing), activate the skill corresponding to the new phase.

4. **Failures, Regressions & Unexpected Errors**:
   - When encountering a failing test, build error, unexpected runtime exception, or complex bug during execution, immediately activate `systematic-debugging` (4-phase root cause analysis) or `diagnosing-bugs` before attempting speculative fixes.

5. **Review, Security & Verification Gates**:
   - When entering the review, security check, or completion phase, activate `code-review` / `cybersecurity-review` / `verification-before-completion` before declaring work done.

---

## 2. Spontaneous Domain Mapping
Spontaneously activate the pertinent skill when the intent or domain emerges, even if the user never mentions skill names:

- **Architecture, Codebase Mapping & Migrations**: Load `graphify` (knowledge graph & topology), `calm` (call graph & blast radius), `improve-codebase-architecture` (structural refactoring & modular deepening), `codebase-design` (deep modules & interfaces), or `understand-anything` (.ua domain map).
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
- **Load on Demand**: Read `SKILL.md` via `view_file` at the exact point where a new need or new request arises.
- **No Lifetime Limit (Multi-Skill Conversations)**: A conversation is NOT limited to 1–2 skills overall. As conversations progress through multiple topics, load each new pertinent skill as needed. The 1–2 guideline applies only as a preference for concurrent focus on a single subtask.
- **Reuse Already Loaded Skills**: If a skill was loaded in an earlier turn and remains relevant, its instructions are already in context—do NOT call `view_file` redundantly on the same `SKILL.md`. Simply continue applying its instructions.
- **No Per-Command Overhead**: Do NOT perform artificial skill checks or pause before every single trivial tool call.
- **Triviality Exemption**: For trivial 1-line typo fixes, answering general conceptual questions, or when no catalog skill matches, proceed directly without artificial skill loading.
- **Follow & Cite**: Apply the specific procedures, checklists, and scripts described in the loaded `SKILL.md`.
