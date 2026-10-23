# AGENTS.md — AI-Dev-Machine

> **Universal Agent Constitution & Operating Invariants**
> Keep this root constitution concise and universal. Detailed domain guidance lives in `.agents/rules/`, `.agents/skills/`, and `.agents/agents/` and is discovered on demand.

---

## 1. Immutable Invariants

1. **Security & Secrets**: Never commit or expose API keys, tokens, credentials, private keys, or `.env` files.
2. **Safety & Working Tree**: Never execute destructive operations (`DROP`, `TRUNCATE`, `git push --force`, `rm -rf`) without explicit authorization. Preserve the user's uncommitted working tree.
3. **Evidence-Based Completion**: Never declare a task complete, fixed, or passing without fresh validation evidence (tests, build, typecheck, or command output).
4. **Deep Modules & YAGNI**: Prefer the standard library, reuse existing utilities, and keep interfaces small and cohesive. Avoid speculative abstractions.
5. **Automatic & Dynamic Skill Routing — "Right Tool, Right Time" (`always_on`)**: Follow [`.agents/rules/skill-routing.md`](.agents/rules/skill-routing.md). Never use the same skill blindly on every task — select the specific skill(s) from the **35 downloaded skills** in `.agents/skills/<skill>/SKILL.md` that match the current job (e.g., `diagnosing-bugs` for bugs, `frontend-design` for UI, `supabase-postgres-best-practices` for SQL, `codebase-design` for architecture) and load their `SKILL.md` on Turn 1.
6. **Smart Subagent Delegation, Project Specialist Synthesis & Parallel Double-Verification (All AIs — Antigravity, Claude Code, Codex, Cursor, Windsurf, Copilot)**: Prioritize the **10 core subagents** and the **project-synthesized `<domain>-specialist.md` subagents** in `.agents/agents/*.md` over generic built-ins. For multi-area tasks, put multiple specialists to work in parallel on their respective areas (`invoke_subagent` / `Task` / `Agent` / multi-track), create new `.agents/agents/<domain>-specialist.md` specialists on the fly combining `graphify` + the 35 downloaded skills when new project domains arise, and enforce **Double-Layer Verification** (Layer 1: each subagent verifies its own area before returning; Layer 2: the main orchestrator audits `git diff`, runs `reviewer`/`security-reviewer`, and runs `verification-before-completion`).
7. **`graphify` & `graft` como Skills Co-Iguais de Navegação Estrutural + `harness` como Skill Principal de Avaliação e Forense**: As skills **`graphify` e `graft` operam no mesmo nível de prioridade arquitetural** para navegação estrutural de código antes de qualquer leitura ou grep amplo. No Turno 1, o agente escolhe entre **Graphify** (topologia macro, god nodes com `graphify god-nodes`, shortest path com `graphify path`, comunidades e impacto reverso) e **Graft** (árvore AST tree-sitter de chamadas com `graft callers`, API surface com `graft skeleton <file>` sem ler corpos, diff blast radius com `graft blast`, e mapa com `graft map`). Para auditoria comportamental, calibração contínua e anti-tool-bypass, **`harness` atua como Skill Principal** (forense de `transcript.jsonl`, ciclo Propose-Probe-Compose e supervisão multiagente). **NUNCA abra arquivos em blocos cegos de `#L1-800`** — use `graft skeleton` / `graft callers` ou `graphify query` + `rg -n` para ler apenas janelas cirúrgicas (`60-150 linhas`).
8. **Higiene de Contexto & Gate de Compactação Pós-Tarefa (`/compact`)**: Delegue explorações extensas a subagentes (`invoke_subagent` / `Task` / `Agent`) para isolar logs brutos fora do chat principal e, ao concluir grandes marcos, sugira pontualmente `/compact` (subagentes nunca mencionam `/compact`).
9. **Respostas Concisas no Chat & Offload para `Walkthrough.md` / Documentação**: **NUNCA envie respostas gigantescas, dissertações teóricas ou logs extensos diretamente no chat** — isso infla o histórico e queima tokens em todas as mensagens seguintes. Mantenha as mensagens no chat no padrão **Executive Briefing** (resumo direto do que foi feito, evidências de testes aprovados e próximos passos). Todo detalhamento técnico, análise de código, comparativo de arquitetura ou passo a passo de telas DEVE ser gravado diretamente em arquivo de documentação (como `Walkthrough.md`, `docs/` ou `README.md`) e apenas referenciado no chat por link markdown (`file:///...`).

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

## 4. Workflows, 35 Downloaded Skills & 10 Specialized Subagents

```text
Pedido do usuário
       ↓
AGENTS.md + Roteamento (skill-routing.md)
       ↓
Graphify + Graft + Harness + CALM (se necessário para entender arquitetura/impacto — ou `researcher`)
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
 verification-before-completion + recomendação de `/compact` (após tarefas grandes)
```

- **Skill & Subagent Routing (`always_on`)**: Governed by [`.agents/rules/skill-routing.md`](.agents/rules/skill-routing.md). Choose the right skill and specialist for the specific job on Turn 1.
- **Organizing Target Projects ("Arrumar / Organizar Projeto")**: Follow Section 7 of [`.agents/rules/skill-routing.md`](.agents/rules/skill-routing.md) (`detect` → `init`/`migrate`/`apply` → verify 35 physical skills, 10 specialized subagents, `skill-routing.md`, `hooks.json`, and `AGENTS.md`/`GEMINI.md` preservation → `audit` & `doctor`).
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
- [ ] Recomendar `/compact` ao final da resposta quando uma tarefa grande, multi-arquivo ou com subagentes for concluída.

- **Native Multi-AI Subagents**: Follow `.agents/rules/orchestration.md`: the main agent coordinates, delegates, verifies integration, and responds; specialists investigate, implement, test, and review. Codex discovers `.codex/agents/*.toml`; Claude Code discovers `.claude/agents/*.md`; Antigravity uses `.agents/agents/*.md`. Use the native session agent tool (`spawn_agent` / `Task` / `Agent` / `invoke_subagent`) when available. If delegation is unavailable, report that limitation and ask before changing the coordinator-only policy. Creating an agent definition does not prove runtime registration. For new domains, persist `.agents/agents/<domain>-specialist.md`, run `aidev.ps1 apply` to refresh native adapters, and pass its instructions explicitly when delegating in an already-open session.
