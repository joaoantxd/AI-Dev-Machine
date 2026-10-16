# AGENTS.md — [PROJECT_NAME]

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
7. **`graphify` como Skill Principal + Protocolo Cirúrgico de Economia de Tokens (`.agents/skills/graphify/SKILL.md`)**: A skill **`graphify` é a skill principal e altamente recomendada para usar em primeiro lugar sempre que a tarefa exigir compreender o projeto, mapear arquitetura, descobrir relações entre arquivos ou medir impacto**. Carregue `.agents/skills/graphify/SKILL.md` no Turno 1, garanta que `graphify-out/graph.json` exista (inclusive em git worktrees), execute `graphify query "<tema>" --budget 1200` + `rg -n "<simbolo>" <arquivos>` via terminal, e **NUNCA abra múltiplos arquivos em blocos cegos de `#L1-800`** — leia apenas janelas cirúrgicas (`StartLine`–`EndLine` de `60-150 linhas`) nas linhas exatas encontradas.
8. **Higiene de Contexto & Gate de Compactação Pós-Tarefa (`/compact`)**: Delegue explorações extensas a subagentes (`invoke_subagent` / `Task` / `Agent`) para isolar logs brutos fora do chat principal e, **ao concluir qualquer tarefa grande** (múltiplos arquivos, refatoração arquitetural, uso de subagentes ou bateria pesada de testes/auditoria), recomende proativamente no final da resposta que o usuário execute `/compact` antes de iniciar a próxima demanda.

---

## 2. Project Metadata & Stack

- **Project Name**: [PROJECT_NAME]
- **Description**: [PROJECT_DESCRIPTION]
- **Profile**: [PROJECT_PROFILE]
- **Primary Runtime / Language**: [PROJECT_RUNTIME]
- **Target OS**: Windows

---

## 3. Canonical Commands

```bash
# Install dependencies
[CMD_INSTALL]

# Run development server / app
[CMD_DEV]

# Run tests
[CMD_TEST]

# Typecheck / Static Analysis
[CMD_TYPECHECK]

# Lint / Format
[CMD_LINT]

# Build / Compile
[CMD_BUILD]
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
 verification-before-completion + recomendação de `/compact` (após tarefas grandes)
```

- **Skill & Subagent Routing (`always_on`)**: Governed by [`.agents/rules/skill-routing.md`](.agents/rules/skill-routing.md). Choose the right skill and specialist for the specific job on Turn 1.
- **Architecture Discovery, Comprehension & Cross-Module Impact**: Activate `graphify` (`view_file` on `SKILL.md`) and consult `graphify-out/` first before broad manual file searches; use `calm`, `understand-anything`, `codebase-design`, `improve-codebase-architecture`, and `domain-modeling`. Delegate to `researcher` or `software-architect`.
- **Bugs, Failures & Regressions**: Activate `systematic-debugging` and `diagnosing-bugs` before attempting fixes.
- **UI, Frontend & Web Craft**: Activate `ui-ux-pro-max`, `frontend-design`, `impeccable`, `web-design-guidelines`, or `vercel-react-best-practices`. Delegate to `frontend-developer`.
- **Backend & Distributed Systems**: Delegate API, service, IPC, and concurrency architecture to `backend-architect`.
- **Database, SQL & Supabase**: Activate `supabase` and `supabase-postgres-best-practices`. Delegate to `database-optimizer`.
- **Desktop & Browser E2E Automation**: Activate `winapp` (Windows UIA) or `playwright` (browser E2E). Delegate to `test-automation-engineer`.
- **CI/CD, Packaging & Release**: Delegate build pipelines, installers, and release automation to `devops-automator`.
- **Security, Threat Modeling & Completion Gate**: Activate `cybersecurity-review`, `security-best-practices`, `security-threat-model`, `security-review`, `skill-security-review`, and `strix` for security audits (delegate to `security-architect` and `security-reviewer`), `ponytail` / `devils-advocate` / `code-review` for quality (delegate to `reviewer`), and `verification-before-completion` before declaring any task finished.

---

## 5. Completion Checklist

- [ ] Code compiles and typecheck passes.
- [ ] Relevant unit / integration tests pass.
- [ ] No secrets or unwanted files in `git status`.
- [ ] `TESTE MANUAL NECESSÁRIO` declared if human hardware/visual verification is required.
- [ ] Recomendar `/compact` ao final da resposta quando uma tarefa grande, multi-arquivo ou com subagentes for concluída.
