# AGENTS.md — [PROJECT_NAME]

> **Universal Agent Constitution & Operating Invariants**
> Keep this root constitution concise and universal. Detailed domain guidance lives in `.agents/rules/`, `.agents/skills/`, and `.agents/agents/` and is discovered on demand.

---

## 1. Immutable Invariants

1. **Security & Secrets**: Never commit or expose API keys, tokens, credentials, private keys, or `.env` files.
2. **Safety & Working Tree**: Never execute destructive operations (`DROP`, `TRUNCATE`, `git push --force`, `rm -rf`) without explicit authorization. Preserve the user's uncommitted working tree.
3. **Evidence-Based Completion**: Never declare a task complete, fixed, or passing without fresh validation evidence (tests, build, typecheck, or command output).
4. **Deep Modules & YAGNI**: Prefer the standard library, reuse existing utilities, and keep interfaces small and cohesive. Avoid speculative abstractions.
5. **Automatic & Dynamic Skill Routing — "Right Tool, Right Time" (`always_on`)**: Follow [`.agents/rules/skill-routing.md`](.agents/rules/skill-routing.md). Never use the same skill blindly on every task — select the specific skill(s) from the **35 downloaded skills** in `.agents/skills/<skill>/SKILL.md` that match the current job (e.g., `diagnosing-bugs` for bugs, `frontend-design` for UI, `supabase-postgres-best-practices` for SQL, `codebase-design` for architecture) and load their `SKILL.md` on Turn 1.
6. **Smart Subagent Delegation, Project Specialist Synthesis & Parallel Double-Verification (All AIs — Antigravity, Claude Code, Codex, Cursor, Windsurf, Copilot)**: Prioritize the **10 core subagents** and the **project-synthesized `<domain>-specialist.md` subagents** in `.agents/agents/*.md` over generic built-ins. For multi-area tasks, put multiple specialists to work in parallel on their respective areas (`invoke_subagent` / `Task` / `Agent` / multi-track), create new `.agents/agents/<domain>-specialist.md` specialists on the fly combining `graphify` + the 35 downloaded skills when new project domains arise, and enforce **Double-Layer Verification** (Layer 1: each subagent verifies its own area before returning; Layer 2: the main orchestrator audits `git diff`, runs `reviewer`/`security-reviewer`, and runs `verification-before-completion`). **DELEGAÇÃO MULTI-ÁREA MANDATÓRIA (ANTI-MONOLITISMO)**: Tarefas que toquem 2 ou mais domínios, camadas ou subsistemas (ex.: auditoria de segurança com CVEs + infraestrutura Vercel + banco Supabase + código) DEVEM OBRIGATORIAMENTE ser decompostas e delegadas a especialistas paralelos no Turno 1 (`invoke_subagent`). Frases do usuário como "evitar subagentes desnecessários" aplicam-se estritamente a tarefas atômicas triviais de 1 linha/1 arquivo; elas NUNCA autorizam a execução monolítica de auditorias, refatorações cross-stack ou investigações multi-subsistema no agente principal.
7. **`graphify` & `graft` como Skills Co-Iguais de Navegação Estrutural + `harness` como Skill Principal de Avaliação e Forense**: As skills **`graphify` e `graft` operam no mesmo nível de prioridade arquitetural** para navegação estrutural de código antes de qualquer leitura ou grep amplo. No Turno 1, o agente escolhe entre **Graphify** (topologia macro, god nodes com `graphify god-nodes`, shortest path com `graphify path`, comunidades e impacto reverso) e **Graft** (árvore AST tree-sitter de chamadas com `graft callers`, API surface com `graft skeleton <file>` sem ler corpos, diff blast radius com `graft blast`, e mapa com `graft map`). Para auditoria comportamental, calibração contínua e anti-tool-bypass, **`harness` atua como Skill Principal** (forense de `transcript.jsonl`, ciclo Propose-Probe-Compose e supervisão multiagente). **NUNCA abra arquivos em blocos cegos de `#L1-800`** — use `graft skeleton` / `graft callers` ou `graphify query` + `rg -n` para ler apenas janelas cirúrgicas (`60-150 linhas`).
8. **Higiene de Contexto & Gate de Compactação Pós-Tarefa (`/compact`)**: Delegue explorações extensas a subagentes (`invoke_subagent` / `Task` / `Agent`) para isolar logs brutos fora do chat principal e, ao concluir grandes marcos, sugira pontualmente `/compact` (subagentes nunca mencionam `/compact`).
9. **Respostas Concisas no Chat & Offload para `Walkthrough.md` / Documentação (Teto Rígido: 25-30 Linhas)**: **NUNCA envie respostas gigantescas, dissertações teóricas, relatórios de auditoria, tabelas de inventário ou logs extensos diretamente no chat** — isso infla o histórico e queima tokens em todas as mensagens seguintes. Mantenha as mensagens no chat no padrão **Executive Briefing** (resumo direto do que foi feito, evidências de testes aprovados e próximos passos, em no máximo 25-30 linhas). Todo detalhamento técnico, relatório diagnóstico, análise de código, comparativo de arquitetura ou plano de execução DEVE ser gravado diretamente em arquivo de documentação (como `Walkthrough.md` ou `docs/`) via `write_file` ANTES de responder ao usuário, e apenas referenciado no chat por link markdown (`file:///...`).

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

## 4. Workflows, 35 Downloaded Skills & 10 Specialized Subagents

Native agent adapters are generated by `aidev apply`: Antigravity uses `.agents/agents/*.md`, Claude Code uses `.claude/agents/*.md` with `CLAUDE.md` importing this constitution, and Codex uses `.codex/agents/*.toml`. Invoke only the delegation tools exposed by the current client. If custom-agent selection is unavailable, pass the specialist's instructions to an available subagent tool. Session permissions remain authoritative. See `.agents/rules/skill-routing.md` for discovery, dynamic creation, and validation.

The main agent coordinates and responds; specialists perform implementation, investigation, tests, and independent review. Follow `.agents/rules/orchestration.md` and verify the returned evidence before declaring success.

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
