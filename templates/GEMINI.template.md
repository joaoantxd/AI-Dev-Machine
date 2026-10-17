# GEMINI.md — [PROJECT_NAME]

> **Google Antigravity & Gemini CLI Native Bridge**
> Project invariants are defined in `AGENTS.md`. Workspace customizations are organized in `.agents/`.

---

## Workspace Customization Discovery

- **Rules**: Discovered hierarchically in `.agents/rules/*.md`. `skill-routing.md` is `always_on` and commands autonomous routing of all 33 downloaded skills and 10 specialized subagents.
- **Skills (33 Downloaded Skills)**: Physically materialized in `.agents/skills/<skill>/SKILL.md`. Antigravity MUST prioritize the 33 downloaded skills over generic IDE built-ins and read the relevant `SKILL.md` on Turn 1 via `view_file` before reading repository code, proposing fixes, or writing code.
- **Subagents (10 Specialized Subagents — Principal Focus)**: Physically materialized in `.agents/agents/*.md`. Antigravity MUST prioritize delegating domain workstreams with the available native `invoke_subagent` schema and the specialist identifiers below (and instruct each specialist to load its domain's `SKILL.md` on Turn 1). Do not assume a parameter named `TypeName` exists:
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
- **MCP Servers**: Portable declarations are in `.agents/mcp_config.json`; validate the installed client's supported configuration and server status before claiming they are active.
- **Hooks**: `.agents/hooks.json` contains the portable safety policy. Enforcement depends on the installed client's hook support and native configuration; file presence alone does not prove execution.
- **Other runtimes**: Claude Code loads `CLAUDE.md` and `.claude/agents/*.md`; Codex loads `AGENTS.md` and `.codex/agents/*.toml`. Use only tools actually exposed by the current runtime. Agent definitions inherit session permissions and never grant broader access.
- **Token Economy, Executive Briefing & Walkthrough Offload**: Always use `graphify query "<topic>" --budget 1200` + `rg -n` + surgical `view_file` windows (`60-150 lines`), offload multi-file exploration to subagents, keep chat messages concise (Executive Briefing), and offload detailed walkthroughs and architectural documentation to `Walkthrough.md` / `docs/` instead of dumping large text in the chat. Post-task `/compact` gate applies after major milestones.


