---
name: skill-routing
description: Autonomous, continuous, and unconstrained skill routing across all conversation turns, phases, and engineering domains.
trigger: always_on
---

# Autonomous & Unconstrained Skill Routing Across Multi-Turn Conversations

## 0. Canonical Execution Pipeline (Smart Routing: Right Tool, Right Time)

> **Core Principle**: The AI must **NEVER** use the exact same skill or the exact same subagent blindly on every task.
> - **Skills** are specialized methods and domain knowledge loaded on demand (`.agents/skills/<skill>/SKILL.md`).
> - **Subagents** are domain specialists (`invoke_subagent`) called when task specialization or complexity justifies them.
> - **Router (`AGENTS.md` + `skill-routing.md`)** is this built-in decision matrix itself — **no separate `agency-router` skill file is needed**. The goal is not to use *more* tools, but to choose the **right tool at the right time, automatically**.

```text
                        Pedido do usuário
                                ↓
             AGENTS.md + Roteamento (skill-routing.md)
                                ↓
                         Graphify + CALM
     (SE NECESSÁRIO: quando precisar mapear arquitetura/impacto
                  — ou delegar ao `researcher`)
                                ↓
             Avaliação do Trabalho ("Precisa de especialista?")
                     │                      │
                    NÃO                    SIM (quando a complexidade/domínio justificar)
          (Agente atual resolve)            │
                     │             Qual especialista? (`invoke_subagent`)
                     │                      │
                     │        ┌─────────────┼─────────────────┐
                     │        ↓             ↓                 ↓
                     │    Software       Backend           Frontend
                     │   Architect      Architect          Developer
                     │
                     │     Database Optimizer / Security Architect /
                     │     Test Automation Engineer / DevOps Automator
                     │                      │
                     └──────────┬───────────┘
                                ↓
          Skills necessárias conforme o trabalho (`.agents/skills/*/SKILL.md`)
               (carregadas via `view_file` sob demanda no Turno 1)
                                ↓
                          implementação
                                ↓
                             testes
                                ↓
              review (`reviewer` / `security-reviewer` +
                  `code-review` / `devils-advocate`)
                                ↓
                 verification-before-completion
```

### Complete Routing Matrix ("The Right Tool for Each Job" — All 33 Skills & 10 Subagents)

| Tipo de Tarefa Pedida pelo Usuário | Quem Executa (Especialista) | Skills Escolhidas Sob Demanda (`.agents/skills/<skill>/SKILL.md`) |
| :--- | :--- | :--- |
| **Entender o projeto / mapear arquitetura, fluxo ou impacto** | `researcher` ou Agente atual | `graphify`, `calm`, `understand-anything` |
| **Projetar arquitetura / refatorar módulos / modelar domínio** | `Software Architect` (`invoke_subagent`) | `codebase-design`, `improve-codebase-architecture`, `domain-modeling`, `graphify`, `calm`, `devils-advocate` |
| **Corrigir um bug / falha de teste / race condition** | **Agente atual** (ou especialista se complexo) | `diagnosing-bugs`, `systematic-debugging` |
| **Criar, estilizar ou melhorar interface (UI/UX, React, Next.js, Electron)** | `Frontend Developer` (`invoke_subagent`) | `ui-ux-pro-max`, `frontend-design`, `impeccable`, `web-design-guidelines`, `vercel-react-best-practices` |
| **Construir serviço Backend / API / Windows Service / IPC** | `Backend Architect` (`invoke_subagent`) | `codebase-design`, `improve-codebase-architecture`, `security-best-practices`, `ponytail` |
| **Otimizar SQL / PostgreSQL / RLS / Supabase / Migrations** | `Database Optimizer` (`invoke_subagent`) | `supabase-postgres-best-practices`, `supabase`, `domain-modeling` |
| **Modelar ameaças / arquitetura de segurança / DACLs / Multi-tenant** | `Security Architect` (`invoke_subagent`) | `security-threat-model`, `cybersecurity-review`, `security-best-practices`, `strix` |
| **Auditar vulnerabilidades no código / Pentest / Lockfiles / Skills** | `security-reviewer` (`invoke_subagent`) | `cybersecurity-review`, `security-review`, `security-best-practices`, `strix`, `skill-security-review` |
| **Automatizar testes E2E Web/Electron ou Desktop Windows (UIA)** | `Test Automation Engineer` (`invoke_subagent`) | `playwright`, `winapp`, `systematic-debugging`, `diagnosing-bugs`, `verification-before-completion` |
| **Empacotar instalador (MSI/Electron), Auto-Update ou CI/CD** | `DevOps Automator` (`invoke_subagent`) | `security-review`, `verification-before-completion`, `ponytail` |
| **Revisar PR / diff / qualidade / desafiar plano antes de concluir** | `reviewer` (`invoke_subagent`) ou Agente atual | `code-review`, `devils-advocate`, `ponytail`, `verification-before-completion` |
| **Resolver conflito Git, organizar contexto/regras, prompts, Google Cloud ou modo conciso** | **Agente atual** | `resolving-merge-conflicts`, `context-engineering`, `prompt-master`, `finding-google-skills`, `review-skills`, `caveman` |

---

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

5. **Turn-1 Pre-Flight Mandatory Action (Anti-Assumption Rule)**:
   - When the user prompt involves ANY domain mapped to an available skill (e.g., bug fixing, UI styling, desktop automation, architecture mapping, testing, or verification):
   - You MUST NOT begin reading repository code, proposing patches, or answering with ungrounded generalities BEFORE calling `view_file` on that skill's `SKILL.md`.
   - Never rationalize that general model training suffices: skills contain repo-specific protocols, constraints, checklists, and anti-patterns that standard LLM knowledge does not provide.

6. **Priority Focus on the 33 Downloaded Catalog Skills & Override of Upstream Restrictions**:
   - **Prioritize Downloaded Skills over IDE Built-ins**: Always prioritize the 33 downloaded engineering skills materialized in `.agents/skills/*` (and `~/.gemini/config/skills/*`) over generic IDE built-in skills (`automation`, `generative_ui`, `migrate-workflows`, `plugin`, `ui-plugin-navigation`).
   - **Full Autonomous Override**: Even if a downloaded skill's `SKILL.md` text contains upstream wording like *"Trigger only when the user explicitly requests..."*, *"Use when asked to..."*, or *"Do not trigger for..."*, **this rule overrides that restriction**: you MUST activate any of the 33 downloaded skills proactively whenever its technical domain applies to the task at hand.

7. **Principal Focus on the 10 Specialized Subagents (`invoke_subagent`)**:
   - **Prioritize the 10 Specialized Subagents over Generic Built-ins**: Always prioritize the 10 specialized subagents materialized in `.agents/agents/*.md` (`researcher`, `reviewer`, `security-reviewer`, `Software Architect`, `Backend Architect`, `Frontend Developer`, `Database Optimizer`, `Security Architect`, `Test Automation Engineer`, `DevOps Automator`) over generic built-in `self` or `research` subagents.
   - **Proactive Multi-Agent Delegation**: Whenever a task involves deep codebase investigation, architectural design, multi-file backend/frontend implementation, database/RLS optimization, threat modeling/security review, E2E test automation, CI/CD packaging, or pre-completion code review, proactively delegate bounded workstreams via `invoke_subagent` using the subagent's exact registered `TypeName`.
   - **Mandatory Subagent + Skill Synergy**: Whenever invoking a subagent via `invoke_subagent`, explicitly instruct the subagent in its `Prompt` argument to load its domain's downloaded skills from `.agents/skills/<skill>/SKILL.md` via `view_file` on Turn 1.

---

## 2. Dynamic Lifecycle & Multi-Turn Triggers

Re-evaluate the catalog of available `<skills>` and `<subagents>` continuously across every turn, phase, and discovery event:

1. **Every New User Request / Shift of Intent (Multi-Turn Re-evaluation)**:
   - Whenever the user sends a new message or shifts intent in an ongoing conversation:
   - **Immediately match the new goal and domain against available `<skills>` and `<subagents>`**.
   - If the new intent requires skills not yet loaded in context, **read their `SKILL.md` via `view_file` as your FIRST action in that turn** before performing deep investigation or modifications.

2. **Stack & Technology Discovery**:
   - When inspecting workspace files, dependencies, manifests, or configs and discovering specific frameworks or tools (e.g., PostgreSQL/Supabase, Next.js, React, Electron, Playwright, WinApp/UIA), immediately activate the corresponding specialized skill and/or domain subagent.

3. **Phase & Subtask Transitions**:
   - As an implementation evolves across engineering boundaries (e.g., architecture design → backend/database modeling → frontend implementation → UI/UX styling → security audit → verification), activate the pertinent skill(s) and specialized subagent(s) for the new phase.

4. **Unexpected Failures, Regressions & Hard Bugs**:
   - When encountering failing tests, build breaks, mysterious runtime exceptions, or flaky behaviors, immediately activate `systematic-debugging` (4-phase root cause analysis) or `diagnosing-bugs` before attempting speculative patches.

5. **Review, Security & Completion Gates**:
   - When entering the review, security audit, or completion phase, activate `verification-before-completion`, `cybersecurity-review`, or `code-review` (and delegate independent verification to `reviewer` / `security-reviewer` when appropriate) before declaring work finished.

6. **Codebase Comprehension, Architecture & Navigation (Graphify-First Protocol)**:
   - For ANY task involving codebase comprehension, architecture discovery, module dependency mapping, cross-module flow tracing, or blast radius / impact analysis:
     a) **Spontaneous Load**: Immediately activate `graphify` (`view_file` on `SKILL.md`) as the primary navigation skill on Turn 1 (or delegate deep multi-file mapping to `researcher`).
     b) **Graph Consultation Precedence**: Discover if `graphify-out/graph.json` exists. If present, query the graph first (via `graphify query "<question>"`, reading `graphify-out/GRAPH_REPORT.md` / `graph.json`, or NetworkX traversal) to map topological clusters, god nodes, and dependency paths BEFORE performing broad `list_dir`, global `grep_search`, or opening dozens of source files.
     c) **Targeted Surgical Inspection**: Use the graph query output to pinpoint the exact target files and symbols, and only then open targeted files via `view_file`.
     d) **Lifecycle & Freshness Verification**:
        - *Graph Present & Fresh*: Query immediately.
        - *Graph Present but Outdated (code modified since graph generation)*: Run incremental update (`graphify <path> --update`) if safe and proportional, or query the existing graph while noting newly modified files.
        - *Graph Absent*: If safe, non-destructive, and proportional (standard repository, no prohibited operations), generate the graph via `graphify .` following `SKILL.md`. If building the graph is unfeasible (e.g. read-only environment, single-file trivial query, or explicit constraint), explain the limitation and proceed with targeted conventional exploration.

---

## 3. Synergistic Multi-Skill Composition Examples

Complementary Skills should be actively combined when addressing multi-faceted tasks:

- **Architecture, Deep Refactoring & Call-Graph Navigation**:
  - Combine `graphify` (knowledge graph & topological god nodes) + `calm` (call graph & blast radius) + `improve-codebase-architecture` / `codebase-design` (deep modules & clean seams) + `understand-anything` (.ua visualization) + `domain-modeling`.
- **Full-Stack Web & Data Modeling**:
  - Combine `vercel-react-best-practices` + `supabase-postgres-best-practices` / `supabase` + `ui-ux-pro-max` + `frontend-design` / `impeccable` + `web-design-guidelines`.
- **Systematic Investigation & Safe Resolution**:
  - Combine `systematic-debugging` (root-cause discipline) + `diagnosing-bugs` + stack-specific skill + `verification-before-completion`.
- **Comprehensive Security & Threat Hardening**:
  - Combine `cybersecurity-review` (9 security dimensions) + `security-best-practices` + `security-threat-model` + `security-review` + `strix` (autonomous pentest / PoC verification).
- **Minimalist & Pragmatic Engineering**:
  - Compose `ponytail` (extreme minimalism, native platform features, YAGNI) + `devils-advocate` (blind-spot challenge) alongside any domain skill to prevent over-engineering.

---

## 4. Complete Catalog of 33 Downloaded Skills & Proactive Trigger Matrix

Spontaneously map tasks and technical domains to all 33 downloaded skills in `.agents/skills/`:

1. **Architecture, Codebase Navigation, Refactoring & Domain Modeling (6 downloaded skills)**:
   - `graphify`: Primary knowledge-graph navigation (`graphify-out/`), architectural topology, god nodes, and dependency paths. Load FIRST when exploring or understanding a codebase.
   - `calm`: 8-stage safe editing workflow, symbol-level call graph (`callers`, `edit_context`, `diff_impact`), and blast-radius control before modifying shared functions/classes.
   - `understand-anything`: Deep repository analysis, business domain flows, and interactive `.ua/knowledge-graph.json` mapping.
   - `codebase-design`: Designing or improving module interfaces, deep modules, narrow interfaces, clean seams, and testability.
   - `improve-codebase-architecture`: Refactoring coupled/shallow modules, eliminating architectural friction, and identifying module-deepening opportunities.
   - `domain-modeling`: Modeling business entities, ubiquitous language, `CONTEXT.md`, and Architectural Decision Records (ADRs).

2. **Debugging & Root-Cause Investigation (2 downloaded skills)**:
   - `systematic-debugging`: 4-phase disciplined root-cause investigation before writing any fix.
   - `diagnosing-bugs`: Diagnostic loop for hard bugs, race conditions, intermittent failures, and performance regressions.

3. **Frontend, UI/UX, Design Systems, Accessibility & React/Next.js (5 downloaded skills)**:
   - `ui-ux-pro-max`: 79 design styles, 192 palettes, font pairings, UX rules, and component ergonomics for web/desktop/mobile.
   - `frontend-design`: Intentional visual direction, layout composition, typography, and micro-interactions.
   - `impeccable`: High-craft UI polish, OKLCH color systems, visual hierarchy, cognitive load reduction, and anti-slop refinement.
   - `web-design-guidelines`: Web Interface Guidelines compliance, accessibility (a11y), focus states, keyboard navigation, and UX audit.
   - `vercel-react-best-practices`: React & Next.js performance optimization, Server/Client Component boundaries, rendering, and bundle efficiency.

4. **Database, SQL, RLS & Supabase (2 downloaded skills)**:
   - `supabase`: Supabase Database, Auth, SSR (`@supabase/ssr`), Edge Functions, Realtime, Storage, Queues, and troubleshooting.
   - `supabase-postgres-best-practices`: PostgreSQL schema design, migrations, indexes, `EXPLAIN` query tuning, connection pooling, and Row Level Security (RLS) policies.

5. **Cybersecurity, Secure Coding, Threat Modeling & Pentesting (6 downloaded skills)**:
   - `cybersecurity-review`: 9-dimension cybersecurity code audit (injection, auth/authz, secrets, supply chain, crypto, SSRF, resource safety, AI/LLM security, API protocols).
   - `security-best-practices`: Secure-by-default coding patterns for TypeScript/JavaScript, Python, and Go (IPC, auth, input validation, network, crypto).
   - `security-threat-model`: Enumerating trust boundaries, assets, attacker capabilities, abuse paths, and mitigations when designing or reviewing architecture/APIs/IPC.
   - `security-review`: Lockfile/dependency vulnerability auditing and static scanner orchestration (Semgrep, Trivy, Gitleaks, OSV, npm audit).
   - `skill-security-review`: Security audit before installing or updating third-party skills, plugins, or MCP servers.
   - `strix`: Autonomous AI penetration testing and executable PoC validation for web apps, APIs, and repositories.

6. **Desktop & Browser E2E Automation (2 downloaded skills)**:
   - `winapp`: Windows desktop UI automation (`winapp ui`), UIA element tree inspection, screenshots, clicks, keyboard input, and physical QA for Electron, WinUI 3, WPF, and Win32 apps.
   - `playwright`: Real browser E2E automation, snapshots, form filling, network verification, and UI-flow debugging via Playwright CLI.

7. **Code Quality, Stress-Testing, Verification & Minimalism (4 downloaded skills)**:
   - `ponytail`: Radical YAGNI and minimal code standard — simplest, shortest working diff using stdlib and native features.
   - `devils-advocate`: Adversarial pre-mortem, inversion, and blind-spot stress-testing of plans, architectures, and critical changes.
   - `code-review`: Two-axis review of diffs/branches/PRs (Repository Standards + Specification Fidelity).
   - `verification-before-completion`: Mandatory evidence gate requiring fresh test/build/typecheck command output before claiming any task is complete.

8. **Git, Context Engineering, Prompts, Cloud & Meta (6 downloaded skills)**:
   - `resolving-merge-conflicts`: Structured resolution of Git merge and rebase conflicts.
   - `context-engineering`: Optimizing `AGENTS.md`, `GEMINI.md`, `.agents/rules/`, and progressive disclosure for large codebases.
   - `prompt-master`: Engineering and calibrating system prompts, agent instructions, and LLM prompts.
   - `finding-google-skills`: Locating official Google Cloud, Gemini API, Firebase, Chrome, and Android skills.
   - `review-skills`: Auditing skill directories for duplicates, broken references, frontmatter validity, and composability.
   - `caveman`: Ultra-compressed communication mode when low token usage or brevity is desired.

---

## 5. Complete Catalog of 10 Specialized Subagents & Proactive Delegation Matrix (`invoke_subagent`)

All 10 specialized subagents are materialized in `.agents/agents/*.md` and registered in `<subagents>`. Always invoke them using their **exact `TypeName`** below:

| `TypeName` (for `invoke_subagent`) | Definition File | Proactive Delegation Trigger | Paired Downloaded Skills (`.agents/skills/`) |
| :--- | :--- | :--- | :--- |
| `researcher` | `.agents/agents/researcher.md` | Deep read-only codebase exploration, multi-file flow tracing, Graphify/CALM dependency mapping, blast-radius discovery. | `graphify`, `calm`, `understand-anything` |
| `Software Architect` | `.agents/agents/software-architect.md` | Macro architecture design, DDD bounded contexts, deep module boundaries, cross-package refactoring plans, ADR authoring. | `graphify`, `calm`, `codebase-design`, `improve-codebase-architecture`, `domain-modeling`, `devils-advocate` |
| `Backend Architect` | `.agents/agents/backend-architect.md` | Backend services & APIs (NestJS, Fastify, Express, .NET), Windows Services (Session 0), IPC/signaling protocols, concurrency. | `codebase-design`, `improve-codebase-architecture`, `security-best-practices`, `systematic-debugging`, `ponytail` |
| `Frontend Developer` | `.agents/agents/frontend-developer.md` | React, Next.js 16 App Router, Electron renderer UI, design systems, state management, accessibility (WCAG), Core Web Vitals. | `ui-ux-pro-max`, `frontend-design`, `impeccable`, `web-design-guidelines`, `vercel-react-best-practices` |
| `Database Optimizer` | `.agents/agents/database-optimizer.md` | PostgreSQL 17, Supabase Auth/RLS policies, Kysely/SQL query tuning, `EXPLAIN ANALYZE`, indexing, migrations, SQLite WAL. | `supabase-postgres-best-practices`, `supabase`, `domain-modeling` |
| `Security Architect` | `.agents/agents/security-architect.md` | Threat modeling, trust boundaries, multi-tenant isolation architecture, Windows Service DACLs/IPC security, auth/crypto design. | `security-threat-model`, `cybersecurity-review`, `security-best-practices`, `strix` |
| `security-reviewer` | `.agents/agents/security-reviewer.md` | Code-level SAST/vulnerability audit, OWASP Top 10, secrets/lockfile scanning, RLS/DACL bypass checks, PoC verification. | `cybersecurity-review`, `security-best-practices`, `security-review`, `strix`, `skill-security-review` |
| `Test Automation Engineer` | `.agents/agents/test-automation-engineer.md` | Playwright browser/Electron E2E tests, WinApp CLI Windows UIA desktop automation, flake elimination, integration test suites. | `playwright`, `winapp`, `systematic-debugging`, `diagnosing-bugs`, `verification-before-completion` |
| `DevOps Automator` | `.agents/agents/devops-automator.md` | CI/CD pipelines, MSI & Electron installer packaging, RSA-SHA256 auto-update & rollback lifecycle, Docker, release scripts. | `security-review`, `verification-before-completion`, `ponytail` |
| `reviewer` | `.agents/agents/reviewer.md` | Independent two-axis code & specification review of diffs/implementations before declaring work complete. | `code-review`, `devils-advocate`, `ponytail`, `verification-before-completion` |

### Subagent Orchestration & Multi-AI Compatibility Rules:
1. **Parallel & Sequential Delegation**: Launch multiple specialized subagents concurrently in a single `invoke_subagent` call when tasks have independent tracks (e.g., `Backend Architect` + `Frontend Developer` + `Database Optimizer`, or `researcher` + `Security Architect`).
2. **Skill-First Subagent Prompts**: Every `Prompt` passed to `invoke_subagent` MUST specify:
   - Exact scope, target files, and project invariants from `AGENTS.md`.
   - Which downloaded `SKILL.md` file(s) in `.agents/skills/` the subagent must load via `view_file` on Turn 1.
   - Expected deliverable and verification evidence required.
3. **Universal Multi-AI Compatibility (Antigravity, Claude Code, Cursor, Windsurf, Copilot, Codex)**:
   - **Google Antigravity / Gemini CLI**: Load skills via `view_file` on `.agents/skills/<skill>/SKILL.md` and delegate to specialists via `invoke_subagent`.
   - **Claude Code**: Load skills via `Read` on `.agents/skills/<skill>/SKILL.md` (or `~/.claude/skills/`) and delegate to specialists via `Task` / `Agent` (or `~/.claude/agents/`).
   - **Cursor / Windsurf / GitHub Copilot / OpenAI Codex**: Automatically read `AGENTS.md` and `.agents/rules/skill-routing.md`; read `.agents/skills/<skill>/SKILL.md` using the native file-reading tool (`read_file`, etc.), and either invoke subagents natively or read `.agents/agents/<specialist>.md` directly to adopt the specialist's persona, constraints, and checklist.

---

## 6. Operational Discipline & Execution Guidelines

- **Load on Demand**: Read `SKILL.md` via `view_file` at the exact point where a new domain need arises.
- **Context Reuse**: Skills loaded in earlier turns remain active in the conversation context. Do NOT call `view_file` redundantly on the same `SKILL.md` if its guidance is already present.
- **No Indiscriminate Manual Wandering**: Do NOT perform blind recursive directory listings (`list_dir`) or mass grep sweeps across whole repositories when a knowledge graph (`graphify-out/`) is available or can be queried. Graph navigation must precede file-by-file inspection.
- **Triviality Exemption**: For trivial 1-line typo fixes, pure conceptual questions, or when no catalog skill matches, proceed directly without loading skills or inserting artificial pauses.
- **Zero Command-Level Overhead**: Do NOT perform artificial skill checks or pause before every single trivial tool call.
- **Deep Fidelity**: Rigorously apply the checklists, workflows, and domain rules defined in the loaded `SKILL.md`.

---

## 7. Project Organization & Governance Self-Healing Protocol ("Arrumar / Organizar Projeto")

Whenever the user opens a project and asks to organize, standardize, migrate, or fix the project's AI governance, skills, and subagents setup (e.g., *"arrume o projeto"*, *"organize o projeto"*, *"configure o AI-Dev-Machine / skills neste projeto"*):

1. **Locate AI-Dev-Machine Engine**:
   - Resolve `$aidevRoot = "$env:USERPROFILE\Documents\AI-Dev-Machine"` (or locate `aidev.ps1` on disk).
2. **Diagnose & Detect Stack**:
   - Run `powershell -ExecutionPolicy Bypass -File "$aidevRoot\aidev.ps1" detect "<workspace>"` to inspect the project's stack, capabilities, and existing `.aidev.json`.
3. **Initialize, Migrate, or Materialize Governance (`init` / `migrate` / `apply`)**:
   - If `.aidev.json` is absent:
     - New/empty project: run `aidev.ps1 init "<workspace>" -Preset <detected-preset>`
     - Existing codebase (Brownfield): create/update `.aidev.json` with all detected capabilities (`core`, `typescript`, `react`, `nextjs`, `supabase`, `postgres`, `sqlite`, `python`, `electron`, `windows-desktop`, `browser-testing`, `monorepo`, `security-audit`, etc.) and run `aidev.ps1 apply "<workspace>"` (or `aidev.ps1 migrate "<workspace>" -AutoApprove`).
   - If `.aidev.json` already exists: ensure its `capabilities` list matches the real project stack and run `aidev.ps1 apply "<workspace>"`.
4. **Verify the 5 Critical Self-Healing Invariants**:
   - **Physical Skills Only (33/33)**: Every skill in `.agents/skills/*` MUST be a physical directory (`d----`), never an NTFS junction (`l----`), so Antigravity IDE indexes `<skills>` natively.
   - **Specialized Subagents Materialized (10/10)**: All 10 specialized subagents (`researcher`, `reviewer`, `security-reviewer`, `software-architect`, `backend-architect`, `frontend-developer`, `database-optimizer`, `security-architect`, `test-automation-engineer`, `devops-automator`) MUST be physically present in `.agents/agents/*.md`.
   - **Active Routing Rule**: `.agents/rules/skill-routing.md` MUST exist with `trigger: always_on`.
   - **Resilient Safety Hook**: `.agents/hooks.json` MUST invoke `"powershell -NoProfile -ExecutionPolicy Bypass -File scripts/safety-check.ps1"` with `.agents/scripts/safety-check.ps1` present.
   - **Root Constitution & Bridge Preservation**: `AGENTS.md` and `GEMINI.md` MUST contain the `Automatic & Dynamic Skill & Subagent Routing` invariant (referencing `.agents/rules/skill-routing.md`, Turn-1 `view_file` on `SKILL.md`, and `invoke_subagent` delegation to the 10 subagents) while preserving all project-specific domain invariants, architecture notes, and canonical commands.
5. **Final Audit & Doctor Gate**:
   - Run `aidev.ps1 audit "<workspace>"` and `aidev.ps1 doctor "<workspace>"` and confirm `Migration/Sync Needed : False` before declaring the project organized.

