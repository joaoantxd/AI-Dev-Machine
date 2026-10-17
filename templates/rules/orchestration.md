---
name: orchestration
description: Main coordinator delegates implementation and review to project specialists.
trigger: always_on
---

# Coordinator and Specialist Execution

The main agent is the coordinator. It understands the request, assigns bounded tasks, coordinates dependencies, checks evidence, and responds to the user. Implementation, extensive investigation, test execution, and independent code review belong to specialists. Prefer the project's native agents and create a focused domain specialist when the existing catalog does not cover the work.

1. Start from `AGENTS.md`, the current request, current working-tree state, and the relevant project rules. Use the local knowledge graph to find boundaries; verify source facts when the graph is stale or incomplete.
2. Give each specialist a precise objective, file ownership, constraints, relevant Skills, and expected validation. Parallelize independent areas; sequence dependent work. Shared filesystem does not permit concurrent edits to the same files without coordination.
3. Specialists inspect and update the actual local files, preserve the user's work, and validate their changes before reporting. Never infer that another AI's conversation or private context is shared.
4. Use a separate reviewer for independent verification. The coordinator evaluates the returned evidence and the integrated result before responding. It remains responsible for correctness and cannot rubber-stamp another agent's claim.
5. Create new specialists in `.agents/agents/<domain>-specialist.md` and run `aidev apply` to generate native Codex and Claude adapters. Use runtime-supported dynamic registration only when available. Reload a session if its client cannot discover new definitions live.
6. Respect the actual runtime: Codex subagent tools; Claude `Agent`/`Task`; Antigravity `invoke_subagent`/`define_subagent` when exposed. Instructions do not enable absent tools or change account, sandbox, approval, or concurrency limits.
   Antigravity specialist definitions explicitly use `subagent: true`, `mainAgent: false`, and `model: inherit`. Generated tool lists use documented native names only; unknown names can prevent execution. The coordinator passes bounded objectives and receives results through the runtime orchestration tools, not an assumed specialist messaging tool. Read-only specialists must not use their shell access to mutate files. Writer specialists can use the authorized shell to create files when no native creation tool is exposed. These allowlists are not an OS security sandbox.
7. If delegation is unavailable, report that concrete limitation. Do not pretend that sequential personas are separate agents; ask the user how to proceed if execution requires changing the requested coordinator-only policy.
8. Keep the final response concise: result, verification evidence, and actionable remaining issues. Store detailed handoff notes in project documentation. Suggest `/compact` once after a substantial completed milestone, when the client's command is available.

Project state is shared through files, version control, validation output, and Graphify. Refresh the graph after source changes and record unfinished work before switching clients. Each new client/session must read the current project instructions and working tree; it does not automatically observe another client's live session.
