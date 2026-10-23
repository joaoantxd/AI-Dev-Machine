# GEMINI.md — AI-Dev-Machine

> **Google Antigravity & Gemini CLI Native Bridge**
> Project invariants are defined in `AGENTS.md`. Workspace customizations are organized in `.agents/`.

---

## Workspace Customization Discovery

- **Rules**: Discovered hierarchically in `.agents/rules/*.md`. `skill-routing.md` is `always_on` and commands autonomous routing of all 35 downloaded skills and 10 specialized subagents.
- **Skills (35 Downloaded Skills)**: Physically materialized in `.agents/skills/<skill>/SKILL.md`. Antigravity MUST prioritize the 33 downloaded skills over generic IDE built-ins and read the relevant `SKILL.md` on Turn 1 via `view_file` before reading repository code, proposing fixes, or writing code.
- **Subagents (10 Specialized Subagents — Principal Focus)**: Physically materialized in `.agents/agents/*.md`. Antigravity MUST prioritize delegating domain workstreams via `invoke_subagent` using these exact `TypeName` values (and instructing each subagent to load its domain's `SKILL.md` on Turn 1):
  - `researcher` (`.agents/agents/researcher.md` — Read-only architecture & Graphify/CALM investigation)
  - `software-architect` (`.agents/agents/software-architect.md` — System design, DDD bounded contexts, deep modules & ADRs)
  - `backend-architect` (`.agents/agents/backend-architect.md` — APIs, NestJS/Node/.NET services, Windows Service Session 0, IPC & signaling)
  - `frontend-developer` (`.agents/agents/frontend-developer.md` — React, Next.js 16, Electron UI, WCAG accessibility & Core Web Vitals)
  - `database-optimizer` (`.agents/agents/database-optimizer.md` — PostgreSQL 17, Supabase RLS, Kysely/SQL tuning, indexes & SQLite WAL)
  - `security-architect` (`.agents/agents/security-architect.md` — Threat modeling, trust boundaries, multi-tenant isolation & DACLs)
  - `security-reviewer` (`.agents/agents/security-reviewer.md` — Code-level SAST/vulnerability audit, OWASP Top 10, secrets & PoC validation)
  - `test-automation-engineer` (`.agents/agents/test-automation-engineer.md` — Playwright browser/Electron E2E & WinApp Windows UIA automation)
  - `devops-automator` (`.agents/agents/devops-automator.md` — CI/CD pipelines, MSI/Electron packaging & auto-update lifecycle)
  - `reviewer` (`.agents/agents/reviewer.md` — Independent two-axis code & specification review before completion)
- **MCP Servers**: Declared in `.agents/mcp_config.json`.
- **Hooks**: Enforced via `.agents/hooks.json`.
- **Token Economy, Executive Briefing & Mandatory Walkthrough Offload (STRICT CHAT CAP: 25-30 LINES)**:
  - **MANDATORY CHAT LIMIT**: Chat responses MUST be strictly concise Executive Briefings (maximum 25-30 lines) containing: 1-2 paragraph executive summary, bulleted test/command verification evidence, and next steps.
  - **ZERO CHAT DUMPS**: NEVER print diagnostic reports, security audits, inventory tables, architectural proposals, multi-step plans, or code dumps directly into the chat!
  - **OFFLOAD TO DISK FIRST**: You MUST write any extensive report, diagnosis, or plan to `Walkthrough.md` (or `docs/<topic>.md`) via `write_file` BEFORE answering the user, and provide ONLY the markdown file link (`file:///...`) in the chat response.
  - **MANDATORY SUBAGENT DELEGATION**: Whenever a task touches 2+ distinct domains or layers (e.g. security audits touching CVEs + Cloud/Vercel + Database/Supabase + Code), you MUST dispatch parallel specialists (`security-reviewer`, `security-architect`, `database-optimizer`) via `invoke_subagent` on Turn 1. Conversational prompt phrases like "evitar subagentes desnecessários" apply ONLY to trivial 1-line tasks; they NEVER authorize executing multi-domain audits or multi-subsystem investigations monolithically in the coordinator. Post-task `/compact` gate applies after major milestones.

## AI-Dev-Machine Native Governance Bridge

@AGENTS.md

Follow AGENTS.md, .agents/rules/skill-routing.md and .agents/rules/orchestration.md. The main agent coordinates and specialists execute. Multi-domain tasks MUST dispatch parallel specialists via `invoke_subagent` on Turn 1. Chat responses MUST be concise Executive Briefings (<= 30 lines) with all detailed reports offloaded to `Walkthrough.md`. Use graphify query with --budget 1200 and targeted reads; apply the /compact milestone gate. Use the native agent tools available in your session and load .agents/agents/*.md specialists on demand.

## Antigravity Runtime Boundaries

This section supersedes older runtime claims above. Use the actual invoke_subagent schema; TypeName and Prompt are conceptual labels, not assumed parameter names. Discover .agents/agents/*.md specialists with subagent: true, mainAgent: false, model: inherit. The main agent coordinates; specialists execute under inherited permissions. Agent/rule files do not prove runtime registration. Portable hooks/MCP artifacts do not prove enforcement or active connections. If native delegation is unavailable, report it and ask before changing coordinator-only policy.
