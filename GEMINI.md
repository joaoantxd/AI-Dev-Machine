# GEMINI.md — AI-Dev-Machine

> **Google Antigravity & Gemini CLI Native Bridge**
> Project invariants are defined in `AGENTS.md`. Workspace customizations are organized in `.agents/`.

---

## Workspace Customization Discovery

- **Rules**: Discovered hierarchically in `.agents/rules/*.md`. `skill-routing.md` is `always_on` and commands autonomous routing of all 33 downloaded skills and 10 specialized subagents.
- **Skills (33 Downloaded Skills)**: Physically materialized in `.agents/skills/<skill>/SKILL.md`. Antigravity MUST prioritize the 33 downloaded skills over generic IDE built-ins and read the relevant `SKILL.md` on Turn 1 via `view_file` before reading repository code, proposing fixes, or writing code.
- **Subagents (10 Specialized Subagents — Principal Focus)**: Physically materialized in `.agents/agents/*.md`. Antigravity MUST prioritize delegating domain workstreams via `invoke_subagent` using these exact `TypeName` values (and instructing each subagent to load its domain's `SKILL.md` on Turn 1):
  - `researcher` (`.agents/agents/researcher.md` — Read-only architecture & Graphify/CALM investigation)
  - `Software Architect` (`.agents/agents/software-architect.md` — System design, DDD bounded contexts, deep modules & ADRs)
  - `Backend Architect` (`.agents/agents/backend-architect.md` — APIs, NestJS/Node/.NET services, Windows Service Session 0, IPC & signaling)
  - `Frontend Developer` (`.agents/agents/frontend-developer.md` — React, Next.js 16, Electron UI, WCAG accessibility & Core Web Vitals)
  - `Database Optimizer` (`.agents/agents/database-optimizer.md` — PostgreSQL 17, Supabase RLS, Kysely/SQL tuning, indexes & SQLite WAL)
  - `Security Architect` (`.agents/agents/security-architect.md` — Threat modeling, trust boundaries, multi-tenant isolation & DACLs)
  - `security-reviewer` (`.agents/agents/security-reviewer.md` — Code-level SAST/vulnerability audit, OWASP Top 10, secrets & PoC validation)
  - `Test Automation Engineer` (`.agents/agents/test-automation-engineer.md` — Playwright browser/Electron E2E & WinApp Windows UIA automation)
  - `DevOps Automator` (`.agents/agents/devops-automator.md` — CI/CD pipelines, MSI/Electron packaging & auto-update lifecycle)
  - `reviewer` (`.agents/agents/reviewer.md` — Independent two-axis code & specification review before completion)
- **MCP Servers**: Declared in `.agents/mcp_config.json`.
- **Hooks**: Enforced via `.agents/hooks.json`.

