---
name: harness
description: "Principal skill for recursive agent behavioral calibration, transcript forensics (transcript.jsonl), Propose-Probe-Compose methodology, multi-agent orchestration, and anti-tool-bypass enforcement."
---

# Harness — Recursive Agent Evaluation & Behavioral Calibration (Principal Skill)

> **Canonical Upstream**: [google-research/harness2](https://github.com/google-research/harness2) (Google Research & Northwestern University, Apache-2.0).  
> **Governance Role**: **Principal Skill** alongside Graphify and Graft.  
> **Native Governance Invariants**: `GEMINI.md`, `AGENTS.md`, `.agents/rules/orchestration.md`, `.agents/rules/skill-routing.md`.

---

## 1. Overview & Architectural Role

**Harness** is a **Principal Skill** in AI-Dev-Machine that formalizes **Recursive Agent Harnessing**: evaluating, debugging, and optimizing the operational environment surrounding an AI agent (system prompts, rules, tools, skills, subagents, scripts, guardrails, and persistent memory) without model retraining.

While **Graphify** and **Graft** provide spatial and structural comprehension of codebases, **Harness** provides agent meta-awareness, behavioral calibration, and governance compliance:

1. **Transcript Forensics**: Empirical analysis of execution logs (`transcript.jsonl` / `transcript_full.jsonl`) to detect governance violations, tool bypasses, hung commands, and monolithic execution anti-patterns.
2. **Propose-Probe-Compose Protocol**: Principled 3-phase methodology for formulating, isolating in disposable fixtures, and safely merging harness adjustments.
3. **Anti-Tool-Bypass Enforcement**: Ensures structural navigation engines (Graphify, Graft) are queried on Turn 1 before broad manual grep or blind `#L1-800` file reads.
4. **Multi-Agent Orchestration Audit**: Ensures complex multi-stack tasks dispatch parallel specialists (`invoke_subagent` / `Task` / `Agent`) and prevents premature subagent teardown.
5. **Non-Destructive Guardrails**: Strict separation between read-only diagnostics, proposed improvements, and verified, user-authorized application.

---

## 2. When to Activate This Skill

Activate **Harness** proactively on Turn 1 whenever:
- **Delegation Breakdown**: A multi-subsystem, multi-package, or fullstack task is being executed monolithically without parallel specialists.
- **Tool Bypass**: Structural navigation tools (Graphify, Graft) were bypassed in favor of broad, unstructured `rg` searches across the workspace root.
- **Agent Behavioral Failure**: Loops, hesitations, repetitive errors, or rule amnesia across turns.
- **Hung Processes & Watchdog Events**: Shell commands exceed standard wait windows (5–10s) or block on interactive `stdin`.
- **Harness Drift**: Discrepancies between canonical templates and consumer workspace deployments.
- **Governance Conflicts**: Conflicting instructions between `GEMINI.md`, `AGENTS.md`, and `.agents/rules/`.

---

## 3. Transcript Forensics Protocol

When diagnosing agent behavior, do not rely on subjective impressions or summaries. Inspect the **verifiable transcript logs**:

### 3.1 Log Location & Structure
- **Compact Transcript**: `<appDataDir>\brain\<conversation-id>\.system_generated\logs\transcript.jsonl`
- **Full Transcript**: `<appDataDir>\brain\<conversation-id>\.system_generated\logs\transcript_full.jsonl`

Each JSONL record represents a turn with:
- `step_index`: Step sequence number.
- `type`: `USER_INPUT` or `PLANNER_RESPONSE`.
- `tool_calls`: Array of tools invoked (`run_command`, `invoke_subagent`, `read_file`, etc.).
- `status`: Execution outcome (`DONE`, `ERROR`).

### 3.2 Forensic Metric Checklist

| Metric | Target / Compliant | Pathological Indicator |
| :--- | :--- | :--- |
| **First Structural Tool Step** | Step 1–3 on Turn 1 (`graphify` or `graft`) | Step > 10, or 0 structural queries before reads |
| **Ripgrep (`rg`) Invocations** | Targeted (< 5 surgical queries) | 10+ sequential queries, or `rg` on repo root |
| **Multi-Stack Delegation** | Parallel `invoke_subagent` dispatched | 0 subagents on 2+ independent subsystems |
| **Command Timeout Rate** | 0% (proper timeouts + non-blocking) | Commands backgrounded due to stdin/interactive wait |
| **Subagent Teardown Gate** | `manage_subagents` called iff subagents exist | `manage_subagents` called with 0 active subagents |
| **Test Verification Gate** | Exit code 0 + pass counts verified | Claims of completion without command output |

---

## 4. The Propose-Probe-Compose Methodology

Harness adapts agent behavior through an empirical, hypothesis-driven cycle:

```text
┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐
│   1. PROPOSE    │ ────> │    2. PROBE     │ ────> │   3. COMPOSE    │
│  Hypothesize    │       │ Isolated Test   │       │ Surgical Merge  │
│  Harness Patch  │       │ in Fixture      │       │ & Persistence   │
└─────────────────┘       └─────────────────┘       └─────────────────┘
```

### Phase 1: Propose (Hypothesis Generation)
1. Read the forensic transcript to identify the exact step where behavior diverged from invariants.
2. Formulate a minimal, testable hypothesis targeting one of the **8 Harness Components**:
   - System Prompts (`GEMINI.md`, `AGENTS.md`)
   - Rules & Routing (`.agents/rules/skill-routing.md`, `orchestration.md`)
   - Domain Skills (`.agents/skills/*/SKILL.md`)
   - Agent Definitions (`.agents/agents/*.md`)
   - Guardrails & Scripts (`safety-check.ps1`, `aidev-nav.ps1`)
   - Navigation Tools (Graphify, Graft)
   - MCP Manifests (`mcp_config.json`)
   - Workspace Metadata (`.aidev.json`)
3. Write the candidate adjustment into a scratch file or isolated branch.

### Phase 2: Probe (Disposable Validation)
1. Never test governance changes directly on active consumer code or dirty working trees.
2. Instantiate a disposable fixture or isolated git branch.
3. Execute the target scenario against the fixture.
4. Record quantitative pass/fail criteria:
   - Tool execution exit codes (`exit code 0`).
   - Latency and token consumption.
   - Exact tool invocation sequence.

### Phase 3: Compose (Surgical Integration)
1. If the probe fails: discard the candidate patch and refine the hypothesis.
2. If the probe passes:
   - Apply the minimal diff to the canonical repository.
   - Verify that no duplicate rules, circular includes, or token bloat were introduced.
   - Verify that baseline capability invariants remain intact.
   - Run the complete AI-Dev-Machine test suite (`tests/run-tests.ps1`).

---

## 5. Operational Guardrails in Consumer Workspaces

When diagnosing or improving consumer repositories:

1. **Three-Tier Action Separation**:
   - **Tier A (Read-Only Diagnostic)**: Analyze transcripts, inspect `.agents/`, review `git status`. Requires no confirmation.
   - **Tier B (Proposal & Impact Report)**: Provide a clean unified diff and explain expected behavioral improvements.
   - **Tier C (Authorized Application)**: Apply file changes ONLY after explicit user confirmation or when running automated sync within scope.
2. **Preservation of Dirty Work**:
   - Never run `git stash`, `git reset --hard`, `git checkout .`, or `git clean` on uncommitted user work.
3. **Preservation of Domain Code**:
   - Governance changes must never touch production application code (`apps/`, `packages/`, `src/`).
4. **Preservation of Local Customizations**:
   - Protect files marked with `LOCAL_CUSTOMIZATION` or registered in `protectedAgents`.
