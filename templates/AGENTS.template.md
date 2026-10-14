# AGENTS.md — [PROJECT_NAME]

> **Universal Agent Constitution & Operating Invariants**
> Keep this root constitution concise and universal. Detailed domain guidance lives in `.agents/rules/`, `.agents/skills/`, and `.agents/agents/` and is discovered on demand.

---

## 1. Immutable Invariants

1. **Security & Secrets**: Never commit or expose API keys, tokens, credentials, private keys, or `.env` files.
2. **Safety & Working Tree**: Never execute destructive operations (`DROP`, `TRUNCATE`, `git push --force`, `rm -rf`) without explicit authorization. Preserve the user's uncommitted working tree.
3. **Evidence-Based Completion**: Never declare a task complete, fixed, or passing without fresh validation evidence (tests, build, typecheck, or command output).
4. **Deep Modules & YAGNI**: Prefer the standard library, reuse existing utilities, and keep interfaces small and cohesive. Avoid speculative abstractions.
5. **Automatic & Dynamic Skill Routing — "Right Tool, Right Time" (`always_on`)**: Follow [`.agents/rules/skill-routing.md`](.agents/rules/skill-routing.md). Never use the same skill blindly on every task — select the specific skill(s) from the **33 downloaded skills** in `.agents/skills/<skill>/SKILL.md` that match the current job (e.g., `diagnosing-bugs` for bugs, `frontend-design` for UI, `supabase-postgres-best-practices` for SQL, `codebase-design` for architecture) and load their `SKILL.md` via `view_file` on Turn 1.
6. **Smart Subagent Delegation (`invoke_subagent`)**: Prioritize the **10 specialized subagents** in `.agents/agents/*.md` (`researcher`, `reviewer`, `security-reviewer`, `software-architect`, `backend-architect`, `frontend-developer`, `database-optimizer`, `security-architect`, `test-automation-engineer`, `devops-automator`) over generic `self` / `research` subagents whenever task complexity or domain specialization justifies a specialist; for localized tasks (like a direct bug fix), the current agent resolves it directly with the matching skill.
7. **`graphify` como Skill Principal e Ótima para Usar em Compreensão e Arquitetura (`.agents/skills/graphify/SKILL.md`)**: A skill **`graphify` é uma skill excelente e altamente recomendada para se usar em primeiro lugar sempre que a tarefa exigir compreender o projeto, mapear arquitetura, descobrir relações entre arquivos, identificar *god nodes* ou medir impacto**. Quando necessário, carregue `.agents/skills/graphify/SKILL.md` via `view_file` no Turno 1 e consulte `graphify-out/GRAPH_REPORT.md` / `graphify-out/graph.json` antes de buscas manuais amplas.

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
 verification-before-completion
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
