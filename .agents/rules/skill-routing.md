---
name: skill-routing
description: Autonomous, continuous, and unconstrained skill routing across all conversation turns, phases, and engineering domains.
trigger: always_on
---

# Autonomous & Unconstrained Skill Routing Across Multi-Turn Conversations

## 1. Core Operating Invariants: Zero Artificial Limits & Full Autonomy

1. **Zero Numerical or Frequency Ceilings**:
   - There is NO quantitative limit (no 1–2 skill cap, no per-turn limit, no per-phase limit, and no lifetime session limit) on Skill selection.
   - The model has complete autonomous authority to activate **none, one, or multiple complementary Skills** based purely on real technical necessity, domain breadth, and task complexity.

2. **Autonomous Activation Without User Prompts**:
   - Skills must be selected and loaded spontaneously whenever they add genuine engineering value.
   - Never require or wait for the user to name, cite, or request specific Skills.

3. **Progressive Disclosure with Zero Capability Artificial Bottlenecks**:
   - Progressive disclosure means loading a skill's full instructions (`SKILL.md` via `view_file`) on demand when its domain becomes relevant, rather than dumping all 33 skills into context upfront.
   - Context economy must **never** be used as a pretext to throttle capability or restrict necessary multi-skill synergy.

4. **Multi-Skill Synergy & Composition**:
   - Complex engineering challenges frequently span multiple orthogonal dimensions (e.g., architecture + database + UI/UX + security + verification).
   - Activate and combine multiple complementary Skills concurrently or sequentially whenever their combined methodologies improve solution quality, architectural soundness, or safety.

---

## 2. Dynamic Lifecycle & Multi-Turn Triggers

Re-evaluate the catalog of available `<skills>` continuously across every turn, phase, and discovery event:

1. **Every New User Request / Shift of Intent (Multi-Turn Re-evaluation)**:
   - Whenever the user sends a new message or shifts intent in an ongoing conversation:
   - **Immediately match the new goal and domain against available `<skills>`**.
   - If the new intent requires skills not yet loaded in context, **read their `SKILL.md` via `view_file` as your FIRST action in that turn** before performing deep investigation or modifications.

2. **Stack & Technology Discovery**:
   - When inspecting workspace files, dependencies, manifests, or configs and discovering specific frameworks or tools (e.g., PostgreSQL/Supabase, Next.js, React, Electron, Playwright, WinApp/UIA), immediately activate the corresponding specialized skill.

3. **Phase & Subtask Transitions**:
   - As an implementation evolves across engineering boundaries (e.g., architecture design → backend/database modeling → frontend implementation → UI/UX styling → security audit → verification), activate the pertinent skill(s) for the new phase.

4. **Unexpected Failures, Regressions & Hard Bugs**:
   - When encountering failing tests, build breaks, mysterious runtime exceptions, or flaky behaviors, immediately activate `systematic-debugging` (4-phase root cause analysis) or `diagnosing-bugs` before attempting speculative patches.

5. **Review, Security & Completion Gates**:
   - When entering the review, security audit, or completion phase, activate `verification-before-completion`, `cybersecurity-review`, or `code-review` before declaring work finished.

---

## 3. Synergistic Multi-Skill Composition Examples

Complementary Skills should be actively combined when addressing multi-faceted tasks:

- **Architecture, Deep Refactoring & Call-Graph Navigation**:
  - Combine `graphify` (knowledge graph & topological god nodes) + `calm` (call graph & blast radius) + `improve-codebase-architecture` / `codebase-design` (deep modules & clean seams) + `understand-anything` (.ua visualization).
- **Full-Stack Web & Data Modeling**:
  - Combine `vercel-react-best-practices` + `supabase-postgres-best-practices` / `supabase` + `ui-ux-pro-max` + `frontend-design` / `impeccable`.
- **Systematic Investigation & Safe Resolution**:
  - Combine `systematic-debugging` (root-cause discipline) + `diagnosing-bugs` + stack-specific skill + `verification-before-completion`.
- **Comprehensive Security & Threat Hardening**:
  - Combine `cybersecurity-review` (9 security dimensions) + `security-best-practices` + `security-threat-model` + `strix` (autonomous pentest / PoC verification).
- **Minimalist & Pragmatic Engineering**:
  - Compose `ponytail` (extreme minimalism, native platform features, YAGNI) alongside any domain skill to prevent over-engineering.

---

## 4. Spontaneous Domain & Catalog Mapping (33 Skills)

Spontaneously map tasks and technical domains to catalog skills:

- **Architecture & Codebase Topology**: `graphify`, `calm`, `understand-anything`, `codebase-design`, `improve-codebase-architecture`, `domain-modeling`.
- **Debugging & Root-Cause Analysis**: `systematic-debugging`, `diagnosing-bugs`.
- **Frontend, UI/UX, Design Systems & Motion**: `ui-ux-pro-max`, `frontend-design`, `impeccable`, `web-design-guidelines`, `vercel-react-best-practices`.
- **Database, SQL, RLS & Migrations**: `supabase`, `supabase-postgres-best-practices`.
- **Cybersecurity, Audits, Threats & Pentesting**: `cybersecurity-review`, `security-best-practices`, `security-threat-model`, `security-review`, `skill-security-review`, `strix`.
- **Testing, Browser & Desktop Automation**: `playwright` (E2E browser), `winapp` (Windows desktop / UIA).
- **Philosophy, Stress-Testing & YAGNI**: `ponytail` (minimalism), `devils-advocate` (pre-mortem & blind-spot challenge).
- **Meta, Context, Workflows & Guidance**: `context-engineering`, `prompt-master`, `finding-google-skills`, `resolving-merge-conflicts`, `review-skills`, `code-review`, `verification-before-completion`, `antigravity-guide`, `agy-customizations`, `caveman`.

---

## 5. Operational Discipline & Execution Guidelines

- **Load on Demand**: Read `SKILL.md` via `view_file` at the exact point where a new domain need arises.
- **Context Reuse**: Skills loaded in earlier turns remain active in the conversation context. Do NOT call `view_file` redundantly on the same `SKILL.md` if its guidance is already present.
- **Triviality Exemption**: For trivial 1-line typo fixes, pure conceptual questions, or when no catalog skill matches, proceed directly without loading skills or inserting artificial pauses.
- **Zero Command-Level Overhead**: Do NOT perform artificial skill checks or pause before every single trivial tool call.
- **Deep Fidelity**: Rigorously apply the checklists, workflows, and domain rules defined in the loaded `SKILL.md`.
