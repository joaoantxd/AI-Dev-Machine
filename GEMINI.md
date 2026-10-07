# GEMINI.md — AI-Dev-Machine

> **Google Antigravity & Gemini CLI Native Bridge**
> Project invariants are defined in `AGENTS.md`. Workspace customizations are organized in `.agents/`.

---

## Workspace Customization Discovery

- **Rules**: Discovered hierarchically in `.agents/rules/*.md`.
- **Skills**: Discovered on demand in `.agents/skills/`.
- **Subagents**: Discovered in `.agents/agents/*.md` (`researcher`, `reviewer`, `security-reviewer`).
- **MCP Servers**: Declared in `.agents/mcp_config.json`.
- **Hooks**: Enforced via `.agents/hooks.json`.
