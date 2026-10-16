# AGENTS.md — AI-Dev-Machine

> **Universal Agent Constitution & Operating Invariants**
> Keep this root constitution concise and universal. Detailed domain guidance lives in `.agents/rules/`, `.agents/skills/`, and `.agents/agents/` and is discovered on demand.

---

## 1. Immutable Invariants

1. **Security & Secrets**: Never commit or expose API keys, tokens, credentials, private keys, or `.env` files.
2. **Safety & Working Tree**: Never execute destructive operations (`DROP`, `TRUNCATE`, `git push --force`, `rm -rf`) without explicit authorization. Preserve the user's uncommitted working tree.
3. **Evidence-Based Completion**: Never declare a task complete, fixed, or passing without fresh validation evidence (tests, build, typecheck, or command output).
4. **Deep Modules & YAGNI**: Prefer the standard library, reuse existing utilities, and keep interfaces small and cohesive. Avoid speculative abstractions.
5. **Automatic & Dynamic Skill Routing — "Right Tool, Right Time" (`always_on`)**: Follow [`.agents/rules/skill-routing.md`](.agents/rules/skill-routing.md). Never use the same skill blindly on every task — select the specific skill(s) from the **33 downloaded skills** in `.agents/skills/<skill>/SKILL.md` that match the current job (e.g., `diagnosing-bugs` for bugs, `frontend-design` for UI, `supabase-postgres-best-practices` for SQL, `codebase-design` for architecture) and load their `SKILL.md` on Turn 1.
6. **Smart Subagent Delegation, Project Specialist Synthesis & Parallel Double-Verification (All AIs — Antigravity, Claude Code, Codex, Cursor, Windsurf, Copilot)**: Prioritize the **10 core subagents** and the **project-synthesized `<domain>-specialist.md` subagents** in `.agents/agents/*.md` over generic built-ins. For multi-area tasks, put multiple specialists to work in parallel on their respective areas (`invoke_subagent` / `Task` / `Agent` / multi-track), create new `.agents/agents/<domain>-specialist.md` specialists on the fly combining `graphify` + the 33 downloaded skills when new project domains arise, and enforce **Double-Layer Verification** (Layer 1: each subagent verifies its own area before returning; Layer 2: the main orchestrator audits `git diff`, runs `reviewer`/`security-reviewer`, and runs `verification-before-completion`).
7. **`graphify` como Skill Principal e Ótima para Usar em Compreensão e Arquitetura (`.agents/skills/graphify/SKILL.md`)**: A skill **`graphify` é uma skill excelente e altamente recomendada para se usar em primeiro lugar sempre que a tarefa exigir compreender o projeto, mapear arquitetura, descobrir relações entre arquivos, identificar *god nodes* ou medir impacto**. Quando necessário, carregue `.agents/skills/graphify/SKILL.md` no Turno 1 e consulte `graphify-out/GRAPH_REPORT.md` / `graphify-out/graph.json` (`graphify query`, `graphify affected`) antes de buscas manuais amplas.

---

## 2. Project Metadata & Stack

- **Project Name**: AI-Dev-Machine
- **Description**: Capability-Driven AI Governance & Multi-Agent Materialization Engine (v2.1)
- **Profile**: base
- **Primary Runtime / Language**: PowerShell 5.1+ / 7+ (`core/AidevCore.psm1`, `aidev.ps1`)
- **Target OS**: Windows

---

## 3. Canonical Commands

```powershell
# Synchronize global library (%USERPROFILE%\.agents & %USERPROFILE%\.gemini\config)
powershell -ExecutionPolicy Bypass -File .\aidev.ps1 sync

# Detect capabilities of any target workspace (read-only)
powershell -ExecutionPolicy Bypass -File .\aidev.ps1 detect "<workspace>"

# Initialize or materialize governance on a workspace
powershell -ExecutionPolicy Bypass -File .\aidev.ps1 init "<workspace>" -Preset <preset>
powershell -ExecutionPolicy Bypass -File .\aidev.ps1 apply "<workspace>"

# Audit and diagnose workspace compliance
powershell -ExecutionPolicy Bypass -File .\aidev.ps1 audit "<workspace>"
powershell -ExecutionPolicy Bypass -File .\aidev.ps1 doctor "<workspace>"

# Run full automated test suite
powershell -ExecutionPolicy Bypass -File .\aidev.ps1 test
```

---

## 4. Workflows, 33 Downloaded Skills & 10 Specialized Subagents

```text
Pedido do usuário
       ↓
AGENTS.md + Roteamento (skill-routing.md)
       ↓
Graphify + CALM (se necessário para entender arquitetura/impacto — ou `researcher`)
       ↓
Avaliação da tarefa: "Precisa de especialista?"
   │             │
  NÃO           SIM (quando a complexidade/domínio justificar — `invoke_subagent`)
(Agente atual)   ├── software-architect / backend-architect / frontend-developer
   │             └── database-optimizer / security-architect / test-automation-engineer / devops-automator
   └─────────────┬────────────────
                 ↓
   Skills necessárias conforme o trabalho (`view_file` em `.agents/skills/<skill>/SKILL.md`)
   • Corrigir bug       → Agente atual        + `diagnosing-bugs` / `systematic-debugging`
   • Criar interface    → frontend-developer  + `frontend-design` / `ui-ux-pro-max`
   • Otimizar SQL       → database-optimizer  + `supabase-postgres-best-practices`
   • Projetar arquit.   → software-architect  + `codebase-design` / `graphify`
                 ↓
            implementação
                 ↓
              testes
                 ↓
              review (`reviewer` / `security-reviewer` + `code-review`)
                 ↓
 verification-before-completion
```

- **Skill & Subagent Routing (`always_on`)**: Governed by [`.agents/rules/skill-routing.md`](.agents/rules/skill-routing.md). Choose the right skill and specialist for the specific job on Turn 1.
- **Organizing Target Projects ("Arrumar / Organizar Projeto")**: Follow Section 7 of [`.agents/rules/skill-routing.md`](.agents/rules/skill-routing.md) (`detect` → `init`/`migrate`/`apply` → verify 33 physical skills, 10 specialized subagents, `skill-routing.md`, `hooks.json`, and `AGENTS.md`/`GEMINI.md` preservation → `audit` & `doctor`).
- **Architecture Discovery, Comprehension & Cross-Module Impact**: Activate `graphify` (`view_file` on `SKILL.md`) and consult `graphify-out/` first before broad manual file searches; use `calm`, `understand-anything`, `codebase-design`, `improve-codebase-architecture`, and `domain-modeling`.
- **Bugs, Failures & Regressions**: Activate `systematic-debugging` and `diagnosing-bugs` before attempting fixes.
- **UI, Frontend & Web Craft**: Activate `ui-ux-pro-max`, `frontend-design`, `impeccable`, `web-design-guidelines`, or `vercel-react-best-practices`.
- **Database, SQL & Supabase**: Activate `supabase` and `supabase-postgres-best-practices`.
- **Security & Completion Gate**: Activate `cybersecurity-review`, `security-best-practices`, `security-threat-model`, `security-review`, `skill-security-review`, and `strix` for security audits, `ponytail` / `devils-advocate` / `code-review` for quality, and `verification-before-completion` before declaring any task finished.
- **Proactive Subagent Delegation (`invoke_subagent` — 10 Specialized Subagents)**:
  - `researcher` (`.agents/agents/researcher.md`): Deep read-only codebase mapping, Graphify/CALM tracing, blast radius.
  - `software-architect` (`.agents/agents/software-architect.md`): Macro architecture, DDD bounded contexts, deep modules, ADRs.
  - `backend-architect` (`.agents/agents/backend-architect.md`): Backend services, APIs, Windows Services, IPC/signaling.
  - `frontend-developer` (`.agents/agents/frontend-developer.md`): React, Next.js 16, Electron UI, WCAG accessibility, CWV.
  - `database-optimizer` (`.agents/agents/database-optimizer.md`): PostgreSQL 17, Supabase RLS, Kysely/SQL tuning, indexes, SQLite.
  - `security-architect` (`.agents/agents/security-architect.md`): Threat modeling, trust boundaries, multi-tenant isolation, DACLs.
  - `security-reviewer` (`.agents/agents/security-reviewer.md`): Code-level SAST/vulnerability audit, secrets check, OWASP Top 10, PoCs.
  - `test-automation-engineer` (`.agents/agents/test-automation-engineer.md`): Playwright E2E, WinApp Windows UIA automation, test suites.
  - `devops-automator` (`.agents/agents/devops-automator.md`): CI/CD pipelines, MSI/Electron packaging, auto-update & release scripts.
  - `reviewer` (`.agents/agents/reviewer.md`): Independent two-axis review (Standards + Spec fidelity) before completion.

---

## 5. Completion Checklist

- [ ] Code compiles and typecheck passes.
- [ ] Relevant unit / integration tests pass.
- [ ] No secrets or unwanted files in `git status`.
- [ ] `TESTE MANUAL NECESSÁRIO` declared if human hardware/visual verification is required.

