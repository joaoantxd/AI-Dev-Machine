---
name: skill-routing
description: Autonomous, continuous, and unconstrained skill routing across all conversation turns, phases, and engineering domains.
trigger: always_on
---

# Autonomous & Unconstrained Skill Routing Across Multi-Turn Conversations

## 0. Canonical Execution Pipeline (Smart Routing: Right Tool, Right Time)

**Coordinator-only project policy**: Follow `.agents/rules/orchestration.md`. The main agent assigns and coordinates work, evaluates evidence, and responds; specialists carry out implementation, substantive investigation, tests, and review. This policy takes precedence over the generic matrix's "Agente atual" execution suggestions. It does not grant unavailable tools or relax the client's permissions.

> **Core Principle**: The AI must **NEVER** use the exact same skill or the exact same subagent blindly on every task.
> - **Skills** are specialized methods and domain knowledge loaded on demand (`.agents/skills/<skill>/SKILL.md`).
> - **Subagents** are domain specialists (`invoke_subagent`) called when task specialization or complexity justifies them.
> - **Router (`AGENTS.md` + `skill-routing.md`)** is this built-in decision matrix itself — **no separate `agency-router` skill file is needed**. The goal is not to use *more* tools, but to choose the **right tool at the right time, automatically**.
> - **STRICT EXECUTIVE BRIEFING & ZERO CHAT DUMPS (MANDATORY CHAT LIMIT: 25-30 LINES)**: **NEVER output long essays, comprehensive documentation, diagnostic tables, audit inventories, or multi-page status reports directly in the chat**. Whenever producing a deep architectural review, status diagnosis, security audit, or walkthrough, the AI **MUST write it to `Walkthrough.md` or a documentation file first via `write_file`**, and then reply in chat with **ONLY an Executive Briefing** (1-2 paragraph summary + bulleted test evidence + clickable file link `file:///...`). Every massive text dump in chat permanently burns tokens across all future conversation turns.
> - **MANDATORY MULTI-DOMAIN SUBAGENT DELEGATION (ANTI-MONOLITH)**: Whenever a task or investigation spans 2+ distinct domains, layers, or subsystems (e.g. security audits covering CVEs + Cloud/Vercel + Database/Supabase + Code), the coordinator **MUST dispatch parallel specialists via `invoke_subagent` on Turn 1** (`security-reviewer`, `security-architect`, `database-optimizer`). Conversational user phrases like *"evitar subagentes desnecessários"* apply strictly to trivial 1-line tasks; they **NEVER** authorize executing multi-domain audits or multi-subsystem investigations monolithically in the coordinator.


```text
                        Pedido do usuÃ¡rio
                                ↓
             AGENTS.md + Roteamento (skill-routing.md)
                                ↓
                         Graphify + CALM
     (SE NECESSÃRIO: quando precisar mapear arquitetura/impacto
                  — ou delegar ao `researcher`)
                                ↓
             AvaliaÃ§Ã£o do Trabalho ("Precisa de especialista?")
                     â”‚                      â”‚
                    NÃO                    SIM (quando a complexidade/domínio justificar)
          (Agente atual resolve)            â”‚
                     â”‚             Qual especialista? (`invoke_subagent`)
                     â”‚                      â”‚
                     â”‚        â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¼â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
                     â”‚        ↓             ↓                 ↓
                     â”‚    Software       Backend           Frontend
                     â”‚   Architect      Architect          Developer
                     â”‚
                     â”‚     Database Optimizer / Security Architect /
                     â”‚     Test Automation Engineer / DevOps Automator
                     â”‚                      â”‚
                     â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
                                ↓
          Skills necessárias conforme o trabalho (`.agents/skills/*/SKILL.md`)
               (carregadas via `view_file` sob demanda no Turno 1)
                                ↓
                          implementaÃ§Ã£o
                                ↓
                             testes
                                ↓
              review (`reviewer` / `security-reviewer` +
                  `code-review` / `devils-advocate`)
                                ↓
                 verification-before-completion
```

### Complete Routing Matrix ("The Right Tool for Each Job" — All 35 Skills & 10 Subagents)

| Tipo de Tarefa Pedida pelo Usuário | Quem Executa (Especialista) | Skills Escolhidas Sob Demanda (`.agents/skills/<skill>/SKILL.md`) |
| :--- | :--- | :--- |
| **Entender o projeto / mapear arquitetura, fluxo ou impacto** | `researcher` ou Agente atual | `graphify`, `graft`, `calm`, `understand-anything` |
| **Avaliar agente / forense de transcrição / autoaperfeiçoamento / anti-tool-bypass** | **Agente atual** ou `reviewer` | `harness`, `verification-before-completion`, systematic-debugging |
| **Projetar arquitetura / refatorar módulos / modelar domínio** | `software-architect` (`invoke_subagent`) | `codebase-design`, `improve-codebase-architecture`, `domain-modeling`, `graphify`, `calm`, `devils-advocate` |
| **Corrigir um bug / falha de teste / race condition** | **Agente atual** (ou especialista se complexo) | `diagnosing-bugs`, `systematic-debugging` |
| **Criar, estilizar ou melhorar interface (UI/UX, React, Next.js, Electron)** | `frontend-developer` (`invoke_subagent`) | `ui-ux-pro-max`, `frontend-design`, `impeccable`, `web-design-guidelines`, `vercel-react-best-practices` |
| **Construir serviço Backend / API / Windows Service / IPC** | `backend-architect` (`invoke_subagent`) | `codebase-design`, `improve-codebase-architecture`, `security-best-practices`, `ponytail` |
| **Otimizar SQL / PostgreSQL / RLS / Supabase / Migrations** | `database-optimizer` (`invoke_subagent`) | `supabase-postgres-best-practices`, `supabase`, `domain-modeling` |
| **Modelar ameaças / arquitetura de segurança / DACLs / Multi-tenant** | `security-architect` (`invoke_subagent`) | `security-threat-model`, `cybersecurity-review`, `security-best-practices`, `strix` |
| **Auditar vulnerabilidades no código / Pentest / Lockfiles / Skills** | `security-reviewer` (`invoke_subagent`) | `cybersecurity-review`, `security-review`, `security-best-practices`, `strix`, `skill-security-review` |
| **Automatizar testes E2E Web/Electron ou Desktop Windows (UIA)** | `test-automation-engineer` (`invoke_subagent`) | `playwright`, `winapp`, `systematic-debugging`, `diagnosing-bugs`, `verification-before-completion` |
| **Empacotar instalador (MSI/Electron), Auto-Update ou CI/CD** | `devops-automator` (`invoke_subagent`) | `security-review`, `verification-before-completion`, `ponytail` |
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
   - Progressive disclosure means loading a skill's full instructions (`SKILL.md` via `view_file`) on demand when its domain becomes relevant, rather than dumping all 35 skills into context upfront.
   - Context economy must **never** be used as a pretext to throttle capability or restrict necessary multi-skill synergy.

4. **Multi-Skill Synergy & Composition**:
   - Complex engineering challenges frequently span multiple orthogonal dimensions (e.g., architecture + database + UI/UX + security + verification).
   - Activate and combine multiple complementary Skills concurrently or sequentially whenever their combined methodologies improve solution quality, architectural soundness, or safety.

5. **Turn-1 Pre-Flight Mandatory Action (Anti-Assumption Rule)**:
   - When the user prompt involves ANY domain mapped to an available skill (e.g., bug fixing, UI styling, desktop automation, architecture mapping, testing, or verification):
   - You MUST NOT begin reading repository code, proposing patches, or answering with ungrounded generalities BEFORE calling `view_file` on that skill's `SKILL.md`.
   - Never rationalize that general model training suffices: skills contain repo-specific protocols, constraints, checklists, and anti-patterns that standard LLM knowledge does not provide.

6. **Priority Focus on the 35 Downloaded Catalog Skills & Override of Upstream Restrictions**:
   - **Prioritize Downloaded Skills over IDE Built-ins**: Always prioritize the 35 downloaded engineering skills materialized in `.agents/skills/*` (and `~/.gemini/config/skills/*`) over generic IDE built-in skills (`automation`, `generative_ui`, `migrate-workflows`, `plugin`, `ui-plugin-navigation`).
   - **Full Autonomous Override**: Even if a downloaded skill's `SKILL.md` text contains upstream wording like *"Trigger only when the user explicitly requests..."*, *"Use when asked to..."*, or *"Do not trigger for..."*, **this rule overrides that restriction**: you MUST activate any of the 35 downloaded skills proactively whenever its technical domain applies to the task at hand.

7. **Principal Focus on the 10 Specialized Subagents (`invoke_subagent`)**:
   - **Prioritize the 10 Specialized Subagents over Generic Built-ins**: Always prioritize the 10 specialized subagents materialized in `.agents/agents/*.md` (`researcher`, `reviewer`, `security-reviewer`, `software-architect`, `backend-architect`, `frontend-developer`, `database-optimizer`, `security-architect`, `test-automation-engineer`, `devops-automator`) over generic built-in `self` or `research` subagents.
   - **Proactive Multi-Agent Delegation**: Whenever a task involves deep codebase investigation, architectural design, multi-file backend/frontend implementation, database/RLS optimization, threat modeling/security review, E2E test automation, CI/CD packaging, or pre-completion code review, proactively delegate bounded workstreams using the specialist identifier and the current runtime's native tool schema. Never assume a parameter named `TypeName` exists.
   - **Mandatory Subagent + Skill Synergy**: Include task instructions using the runtime-supported schema: load the domain's downloaded skills from `.agents/skills/<skill>/SKILL.md` with the available file-reading tool on Turn 1.

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

6. **Codebase Comprehension, Architecture & Navigation (Graphify-First Protocol & Graft Co-Equal Engine + Harness Behavioral Supervision)**:
   <!-- Contains: Codebase Comprehension, Architecture & Navigation (Graphify-First Protocol) -->
   - **Co-Equal Priority**: graphify and graft sit at the exact same level as primary structural navigation engines. On Turn 1, coding agents globally must query structural tools before reading files or running manual grep:
     - **Use Graft (graft)** for: AST symbol call hierarchy (`graft callers "<symbol>"`), API signatures without method bodies (`graft skeleton <file>`), diff blast radius (`graft blast`), directory orientation hotspots (`graft map`), symbol-scoped search (`graft grep <pattern>`), and markdown context queries (`graft ask "<query>"`). Output: `graft/`.
     - **Use Graphify (graphify)** for: Macro community clusters and architectural hubs (graphify god-nodes --top 15), shortest path between distinct modules (graphify path "<A>" "<B>"), macro reverse dependency blast radius (graphify affected "<symbol>"), semantic explanations (graphify explain "<symbol>"), and token-budgeted knowledge graph queries (graphify query "<topic>" --budget 1200). Output: `graphify-out/`.
     - **Harness Supervision (harness)**: Use harness as a Principal Skill to audit transcripts (`transcript.jsonl`), ensure neither Graphify nor Graft was bypassed, and calibrate agent multi-agent orchestration.
   - For ANY task involving codebase comprehension, architecture discovery, locating files/symbols, fixing multi-file bugs, module dependency mapping, cross-module flow tracing, or blast radius / impact analysis:
     a) **Spontaneous Load**: Immediately activate `graphify` (`view_file` on `SKILL.md`, compact ~3 KB) as the primary navigation skill on Turn 1 (or delegate deep multi-file mapping to `researcher`).
     b) **Graph Consultation Precedence (Windows PowerShell Fast-Path & Worktree Auto-Init)**: Run this `run_command` BEFORE opening source files (automatically handles git worktrees where `graphify-out/graph.json` is not yet built):
        ```powershell
        if (-not (Test-Path "graphify-out/graph.json")) { graphify extract . --code-only ; graphify cluster-only . --no-label --no-viz }
        graphify query "<topic or symbol>" --budget 1200
        graphify affected "<symbol>"
        rg -n "<symbol_or_function>" <target_files_from_graph>
        ```
     c) **Targeted Surgical Inspection (Zero `#L1-800` Blind Dumps)**:
        - **NEVER** call `view_file` / `Read` on `#L1-800` and `#L801-1600` across multiple files to hunt for code.
        - **ALWAYS** use `StartLine` and `EndLine` (`60-150 lines` window) around the exact line numbers returned by `rg -n` and `graphify query`.
     d) **Lifecycle & Freshness Verification & Selective Skill Loading**:
        - *Graph Present & Fresh*: Query immediately (`graphify query "<topic>" --budget 1200`).
        - *Graph Present but Outdated*: Run `graphify update .` (~2 seconds, zero API cost).
        - *Graph Absent*: Build locally via `graphify extract . --code-only ; graphify cluster-only . --no-label --no-viz`.
        - *Right Skill, Zero Bloat*: Load `graphify/SKILL.md` plus only the specific domain skills directly matching the active subtask; do not load `calm/SKILL.md` or `understand-anything/SKILL.md` unless `calm` MCP tools or `.ua/knowledge-graph.json` are needed.

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

## 4. Complete Catalog of 35 Downloaded Skills & Proactive Trigger Matrix

Spontaneously map tasks and technical domains to all 35 downloaded skills in `.agents/skills/`:

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

All 10 specialized subagents are materialized in `.agents/agents/*.md`. File presence does not prove runtime registration; invoke discovered specialists using their identifiers below and the native tool schema:

| Specialist identifier | Definition File | Proactive Delegation Trigger | Paired Downloaded Skills (`.agents/skills/`) |
| :--- | :--- | :--- | :--- |
| `researcher` | `.agents/agents/researcher.md` | Deep read-only codebase exploration, multi-file flow tracing, Graphify/CALM dependency mapping, blast-radius discovery. | `graphify`, `graft`, `calm`, `understand-anything` |
| `software-architect` | `.agents/agents/software-architect.md` | Macro architecture design, DDD bounded contexts, deep module boundaries, cross-package refactoring plans, ADR authoring. | `graphify`, `calm`, `codebase-design`, `improve-codebase-architecture`, `domain-modeling`, `devils-advocate` |
| `backend-architect` | `.agents/agents/backend-architect.md` | Backend services & APIs (NestJS, Fastify, Express, .NET), Windows Services (Session 0), IPC/signaling protocols, concurrency. | `codebase-design`, `improve-codebase-architecture`, `security-best-practices`, `systematic-debugging`, `ponytail` |
| `frontend-developer` | `.agents/agents/frontend-developer.md` | React, Next.js 16 App Router, Electron renderer UI, design systems, state management, accessibility (WCAG), Core Web Vitals. | `ui-ux-pro-max`, `frontend-design`, `impeccable`, `web-design-guidelines`, `vercel-react-best-practices` |
| `database-optimizer` | `.agents/agents/database-optimizer.md` | PostgreSQL 17, Supabase Auth/RLS policies, Kysely/SQL query tuning, `EXPLAIN ANALYZE`, indexing, migrations, SQLite WAL. | `supabase-postgres-best-practices`, `supabase`, `domain-modeling` |
| `security-architect` | `.agents/agents/security-architect.md` | Threat modeling, trust boundaries, multi-tenant isolation architecture, Windows Service DACLs/IPC security, auth/crypto design. | `security-threat-model`, `cybersecurity-review`, `security-best-practices`, `strix` |
| `security-reviewer` | `.agents/agents/security-reviewer.md` | Code-level SAST/vulnerability audit, OWASP Top 10, secrets/lockfile scanning, RLS/DACL bypass checks, PoC verification. | `cybersecurity-review`, `security-best-practices`, `security-review`, `strix`, `skill-security-review` |
| `test-automation-engineer` | `.agents/agents/test-automation-engineer.md` | Playwright browser/Electron E2E tests, WinApp CLI Windows UIA desktop automation, flake elimination, integration test suites. | `playwright`, `winapp`, `systematic-debugging`, `diagnosing-bugs`, `verification-before-completion` |
| `devops-automator` | `.agents/agents/devops-automator.md` | CI/CD pipelines, MSI & Electron installer packaging, RSA-SHA256 auto-update & rollback lifecycle, Docker, release scripts. | `security-review`, `verification-before-completion`, `ponytail` |
| `reviewer` | `.agents/agents/reviewer.md` | Independent two-axis code & specification review of diffs/implementations before declaring work complete. | `code-review`, `devils-advocate`, `ponytail`, `verification-before-completion` |

### Automatic Project-Specific Subagent Synthesis, Parallel Area Orchestration & Double-Layer Verification (All AIs):
1. **Automatic Synthesis per Project (`Invoke-AidevAgentSynthesis` in `aidev.ps1 apply`)**:
   - Whenever `aidev.ps1 apply` runs on a project, it automatically:
     - Tailors all 10 core subagents with a `## Project-Specific Context (<ProjectName>)` section containing the project's capabilities, `graphify` CLI Turn-1 protocol, and local domain rules.
     - Synthesizes project-specific domain subagents (`.agents/agents/<domain-rule>-specialist.md`) for project-owned domain rules, pairing them with the matching skills. Materializes native project adapters in `.codex/agents/*.toml` and `.claude/agents/*.md`. Keep project-specific specialists local to prevent another project's rules from leaking into unrelated workspaces.
2. **Autonomous On-the-Fly Subagent Creation by Any AI (`.agents/agents/<domain>-specialist.md`)**:
   - Whenever ANY AI (Antigravity, Claude Code, OpenAI Codex, Cursor, Windsurf, GitHub Copilot, Gemini CLI) encounters a complex project subsystem or recurring domain not yet covered by an existing subagent, it is explicitly empowered to **create a custom project subagent autonomously**:
     a) Author and persist `.agents/agents/<domain>-specialist.md` (UTF-8 without BOM, kebab-case `name:`, valid `tools:` list) combining `graphify` (`graphify query "<topic>"`), the matching downloaded skills from `.agents/skills/<skill>/SKILL.md`, and the project's domain rules in `.agents/rules/*.md`.
     b) Run `aidev.ps1 apply "<workspace>"` to materialize the native adapters. Antigravity may use `define_subagent` for immediate registration only when that tool is available; choose write access according to the delegated task. Claude uses project-local `.claude/agents/<domain>-specialist.md` with Claude-compatible frontmatter. Codex uses `.codex/agents/<domain>-specialist.toml` with `name`, `description`, and `developer_instructions`. Inherit the parent model and permissions. Never weaken permissions to enable delegation.
     c) Delegate the domain workstream to the newly created specialist.
3. **Parallel Multi-Area Execution ("Put Every Specialist to Work in Its Own Area")**:
   - When a task touches multiple areas (e.g., Database/RLS + Backend/Fiscal Engine + Frontend UI + Security/Tests):
     - **Step 1 (Orchestrator Mapping)**: The main agent runs `graphify query` / `graphify affected` on Turn 1 to map exact module boundaries and assign non-overlapping file scopes per area.
     - **Step 2 (Concurrent Dispatch)**: Put all relevant core and project-synthesized subagents to work in their respective areas simultaneously (`invoke_subagent` with multiple entries in `Subagents` for Antigravity; parallel `Task`/`Agent` calls for Claude Code; parallel sub-agents/tasks for Codex; or structured per-specialist execution tracks for Cursor/Windsurf/Copilot).
4. **Mandatory Double-Layer Verification (Subagent Self-Verification + Orchestrator Integration Verification)**:
   - **Layer 1 -- Inside Each Subagent (Area Verification)**: Every subagent MUST load `graphify/SKILL.md` + the 1–2 relevant domain skills (`SKILL.md`) on Turn 1 AND run `verification-before-completion` (typecheck, unit tests, SQL/RLS validation, or lint for its specific module) before reporting its task as done.
   - **Layer 2 -- Main Orchestrator + `reviewer` / `security-reviewer` (Global Verification)**: While subagents work and as they finish, the main agent NEVER trusts subagent reports blindly. It inspects the actual `git diff`, checks cross-module contracts, delegates independent audit to `reviewer` / `security-reviewer` when appropriate, and executes the full workspace verification gate (`test`, `typecheck`, `build`) before declaring the task complete.
5. **Skill-First & Token-Economic Subagent Prompts**: Every prompt passed to a subagent MUST specify:
   - Exact scope, target files, and project invariants from `AGENTS.md`.
   - Instruction to run `graphify query "<topic>" --budget 1200` + `rg -n "<symbol>" <files>` first and use surgical `view_file` windows (`StartLine`–`EndLine` of `60-150 lines`, NEVER `#L1-800` blind dumps).
   - Which 1–2 downloaded `SKILL.md` file(s) in `.agents/skills/` the subagent must load on Turn 1 (alongside `graphify`).
   - Required Layer-1 verification commands and evidence.
6. **Runtime-Specific Compatibility Matrix**:
   - **Google Antigravity**: Uses `GEMINI.md`, `.agents/rules/*.md`, `.agents/skills/*/SKILL.md`, and native `.agents/agents/*.md`. Use `invoke_subagent` / `define_subagent` only when exposed by the installed client. Specialists may request peer assistance through native `send_message` and discover real conversation IDs using `manage_subagents` (`Action: list`), following the ownership, coordinator-notification, and fallback protocol in `orchestration.md`. Gemini CLI capabilities must be verified separately; do not assume identical tool names.
   - **Claude Code (`claude`)**: Loads `CLAUDE.md` importing `@AGENTS.md`, skills on demand, and native project `.claude/agents/*.md`. Delegate through the available `Agent` / `Task` tool. Do not copy Antigravity tool names into Claude's frontmatter. Restart a session if a newly created agents directory is not detected.
   - **OpenAI Codex (`codex`)**: Reads `AGENTS.md`, `.agents/skills/*/SKILL.md`, and native `.codex/agents/*.toml`. Delegate with the runtime's available subagent tools (for example `spawn_agent`, `send_message`, and `wait_agent`), not an invented `invoke_subagent`. When named-agent selection is unavailable, pass the canonical specialist's instructions explicitly in the delegated prompt. Reload the project/session to discover newly materialized native agents.
   - **Runtime boundaries**: Agent files provide instructions and discovery; they do not grant tools or override sandbox/account restrictions. `.agents/hooks.json` and `.agents/mcp_config.json` are portable configuration artifacts, not proof that a particular client's hooks or MCP servers are active. Validate each client's native configuration separately. If delegation is unavailable, state the limitation and ask before changing the coordinator-only policy; never claim parallel execution without an actual subagent run.
   - **Cursor, Windsurf & GitHub Copilot**: Reads `AGENTS.md` and `.agents/rules/*.md`. Loads `.agents/skills/<skill>/SKILL.md` via native file reader, creates `.agents/agents/<domain>-specialist.md` when new domain areas arise, and adopts each specialist's persona, skills, and Layer-1 verification per area before running the Layer-2 orchestrator gate.

---

## 6. Operational Discipline & Token Economy Guidelines

- **Surgical File Reading (`60-150 lines` vs `#L1-800`)**: Always pinpoint line numbers with `graphify query --budget 1200` and `rg -n` first, then read surgical `StartLine`–`EndLine` slices (`60-150 lines`). Never read `#L1-800` across multiple files.
- **Load on Demand (1–2 Skills per Subtask)**: Read `graphify/SKILL.md` + the 1–2 `SKILL.md` files that directly apply to the current subtask via `view_file`.
- **Context Reuse**: Skills loaded in earlier turns remain active in the conversation context. Do NOT call `view_file` redundantly on the same `SKILL.md` if its guidance is already present.
- **No Indiscriminate Manual Wandering**: Do NOT perform blind recursive directory listings (`list_dir`) or mass grep sweeps across whole repositories when a knowledge graph (`graphify-out/`) is available or can be queried. Graph navigation must precede file-by-file inspection.
- **Post-Task Context Compaction Gate (`/compact` ONLY After Major Multi-Task Milestones — Anti-Spam Calibration)**:
  1. **Subagents NEVER Output `/compact`**: Subagents running in background or ephemeral contexts (`invoke_subagent` / `Task` / `Agent`) MUST NEVER output recommendations for `/compact`, since slash commands are only actionable by the human user in the root chat.
  2. **Strictly Milestone-Only in Root Orchestrator (Never Every Turn)**: Do NOT repeat `/compact` on every message, test run, or intermediate iteration. The root orchestrator should ONLY mention `/compact` when:
     - The user's entire multi-step goal/feature has been completely finalized and verified;
     - AND the conversation has grown genuinely long (>12–15 turns) or completed heavy multi-agent parallel tracks;
     - Once mentioned, NEVER repeat the `/compact` recommendation in subsequent turns unless another full multi-file milestone is completed.
- **Executive Briefing in Chat & Offload to `Walkthrough.md` / Docs (Token-Economy Priority)**:
  - **Zero Huge Chat Dumps**: NEVER dump long essays, full code re-prints, extensive diff dumps, or multi-page documentation in the conversation reply. Every extra line in chat is retained in history and re-sent to the LLM on every subsequent turn, exponentially inflating token usage.
  - **Concise Executive Summary in Chat**: Keep chat responses structured and brief:
    1. Direct summary of what was completed;
    2. Concrete evidence (test pass counts, build/lint status);
    3. Clickable link to the documentation file for deep review;
    4. Clear next action or question for the user.
  - **Offload Depth to `Walkthrough.md` / `docs/`**: Write detailed implementation walkthroughs, screen/flow guides, architectural rationale, and before-and-after tables directly into a project file (such as `Walkthrough.md` or `docs/<topic>.md`) via `write_to_file`. The user can read the file at leisure without cluttering context memory.
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
4. **Verify the 6 Critical Self-Healing Invariants**:
   - **Physical Skills Only (35/35)**: Every skill in `.agents/skills/*` MUST be a physical directory (`d----`), never an NTFS junction (`l----`), so Antigravity IDE indexes `<skills>` natively.
   - **Specialized Subagents Materialized (10/10 + Project Domain Specialists)**: All 10 specialized subagents (`researcher`, `reviewer`, `security-reviewer`, `software-architect`, `backend-architect`, `frontend-developer`, `database-optimizer`, `security-architect`, `test-automation-engineer`, `devops-automator`) plus synthesized `<domain>-specialist.md` subagents MUST be physically present in `.agents/agents/*.md`.
   - **Active Routing Rule**: `.agents/rules/skill-routing.md` MUST exist with `trigger: always_on`.
   - **Resilient Safety Hook**: `.agents/hooks.json` MUST invoke `"powershell -NoProfile -ExecutionPolicy Bypass -File scripts/safety-check.ps1"` with `.agents/scripts/safety-check.ps1` present.
   - **Root Constitution & Bridge Preservation (with Surgical Token-Economy & `/compact` Gate)**: `AGENTS.md` and `GEMINI.md` MUST contain the `Automatic & Dynamic Skill & Subagent Routing` invariant, the `graphify` surgical token-economy protocol, and the **Post-Task Context Compaction Gate (`/compact`)** while preserving all project-specific domain invariants, architecture notes, and canonical commands.
   - **Knowledge Graph Ready (`graphify-out/graph.json`)**: `aidev.ps1 apply` automatically initializes or updates `graphify-out/graph.json` (including in git worktrees).
5. **Final Audit & Doctor Gate**:
   - Run `aidev.ps1 audit "<workspace>"` and `aidev.ps1 doctor "<workspace>"` and confirm `Migration/Sync Needed : False` before declaring the project organized.

