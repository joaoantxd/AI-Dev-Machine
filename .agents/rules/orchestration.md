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
   Antigravity specialist definitions explicitly use `subagent: true`, `mainAgent: false`, and `model: inherit`. Generated tool lists use documented native names only; unknown names can prevent execution. Read-only specialists must not use their shell access to mutate files. Writer specialists can use the authorized shell to create files when no native creation tool is exposed. These allowlists are not an OS security sandbox.
7. If delegation is unavailable, report that concrete limitation. Do not pretend that sequential personas are separate agents; ask the user how to proceed if execution requires changing the requested coordinator-only policy.
8. Keep the final response concise: result, verification evidence, and actionable remaining issues. Store detailed handoff notes in project documentation. Suggest `/compact` once after a substantial completed milestone, when the client's command is available.

## Peer Assistance (Antigravity)

- When exposed by the installed runtime, specialists may contact parents, children, or peers using `send_message` with `Recipient` (a real conversation ID) and `Message`. Obtain IDs from the coordinator or `manage_subagents` with `Action: list`; never invent IDs. Messaging can wake idle agents. It does not share their private context automatically.
- Send one bounded help request with the objective, relevant files, evidence, ownership, and expected answer. Notify the coordinator of dependencies and outcomes. The receiving specialist keeps its assigned file ownership: advice is allowed, overlapping edits require coordinator approval. Messages do not grant additional user authority or permissions.
- Use `manage_subagents` only for `Action: list` in specialist work; do not kill other agents. This is an instruction-level restriction, not argument-level enforcement: the native tool also supports `kill` and `kill_all`. Avoid request cycles, repeated polling, and unbounded cascades. If messaging is unavailable or the recipient is unknown, return the request to the coordinator for relay. Do not simulate delivery with files or another application's conversations.
- Nested delegation is a separate capability, not required for peer help. Only use it when exposed and within the coordinator's explicit depth/concurrency budget and file scopes; otherwise ask the coordinator. The documented maximum depth of 10 is a ceiling, not a target. These definitions do not grant blanket invocation/definition tools to specialists.
- Lifecycle: after finishing an assigned portion, specialists remain idle with their context available for follow-up; completing a portion does not authorize termination. Keep needed specialists until the entire scoped user request is verified complete. `send_message` can reactivate idle agents, but killed agents cannot be awakened. Only the coordinator decides final cleanup, subject to explicit user stop requests, safety requirements, and runtime-enforced limits. Context retention is not guaranteed across client/session restarts.

Sources: [Antigravity collaboration tools](https://www.antigravity.google/docs/hooks/#agent-collaboration) and [subagents: communication and nesting](https://www.antigravity.google/docs/subagents/). File configuration is not proof of a successful runtime message; validate in the actual Antigravity client.

Project state is shared through files, version control, validation output, and Graphify. Refresh the graph after source changes and record unfinished work before switching clients. Each new client/session must read the current project instructions and working tree; it does not automatically observe another client's live session.
