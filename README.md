# AI Dev Machine — Architecture v2

Um kit determinístico e portátil para configurar, manter e orquestrar ambientes e projetos de desenvolvimento de software assistidos por IA no Windows, compatível com Google Antigravity, OpenAI Codex, Claude Code e Gemini CLI.

---

## 1. O que é a Architecture v2?

A **Architecture v2** foi projetada para resolver a sobrecarga cognitiva e a poluição de contexto nos coding agents.

> **Princípio Central:** Aumentar a qualidade, inteligência, previsibilidade e autonomia dos coding agents, fornecendo o contexto certo no momento certo e automatizando deterministicamente aquilo que não precisa consumir raciocínio da IA.

### O que mudou da v1 para a v2:
- **Fim da Regra Zero Monolítica:** O agente não carrega obrigatoriamente 5 a 10 skills em toda interação inicial. `AGENTS.md` atua como uma constituição enxuta de invariantes essenciais.
- **Isolamento de Projetos:** Eliminação de junction monolítica (`.agents -> %USERPROFILE%\.agents`). Cada workspace possui sua pasta `.agents/` física e independente.
- **Registry Canônico Único:** Centralização de metadados em `registry/` (skills, agents, mcps, plugins, profiles), eliminando catálogos manuais duplicados.
- **Especialistas Cognitivos:** Introdução de agentes com papéis mentais bem definidos: `researcher` (investigação read-only e Graphify), `reviewer` (desafio e validação de diffs) e `security-reviewer` (AppSec).
- **Profiles Composáveis:** Perfis (`base`, `web-supabase`, `windows-desktop`, `monorepo`) para compor regras, skills e MCPs adequados à natureza do projeto.
- **CLI Unificada `aidev`:** Ponto único de orquestração para diagnósticos, auditorias, migrações seguras, inicialização e sincronização.

---

## 2. CLI `aidev` (PowerShell)

A CLI `aidev.ps1` é o ponto de entrada canônico para automações no AI-Dev-Machine.

```powershell
# Executar diagnósticos no sistema, ferramentas, registries e projeto
.\aidev.ps1 doctor [caminho]

# Listar componentes disponíveis no registry canônico
.\aidev.ps1 list [skills|agents|mcps|plugins|profiles]

# Auditar conformidade de um projeto existente (somente leitura)
.\aidev.ps1 audit [caminho]

# Simular migração segura de um projeto para a Architecture v2 (zero escritas)
.\aidev.ps1 migrate [caminho] -DryRun

# Aplicar migração segura com backup automático e proteção contra sobrescrita
.\aidev.ps1 migrate [caminho] -Profile base

# Inicializar um novo projeto com Architecture v2 e profile específico
.\aidev.ps1 init [caminho] -Profile web-supabase

# Sincronizar a biblioteca global canônica em %USERPROFILE%\.agents
.\aidev.ps1 sync [-Update] [-DryRun]

# Executar a suíte completa de testes automatizados
.\aidev.ps1 test
```

---

## 3. Estrutura de um Projeto v2

Um projeto compatível com a Architecture v2 é organizado da seguinte forma:

```text
meu-projeto/
├── AGENTS.md                  # Constituição enxuta de invariantes e comandos
├── GEMINI.md                  # Bridge nativo para Antigravity / Gemini (@./AGENTS.md)
├── .agents/                   # Diretório físico ISOLADO (ignorado pelo git)
│   ├── rules/                 # Regras contextuais (architecture, git, stack)
│   ├── skills/                # Links individuais para skills habilitadas no projeto
│   ├── agents/                # Especialistas cognitivos e de domínio
│   ├── plugins/               # Plugins Antigravity
│   ├── hooks.json             # Hooks determinísticos de proteção e ciclo de vida
│   └── mcp_config.json        # Configuração de MCPs habilitados no projeto
├── docs/                      # Conhecimento humano e histórico sob demanda
│   ├── architecture/          # Visão arquitetural e diagramas
│   ├── decisions/             # Architecture Decision Records (ADRs)
│   └── runbooks/              # Runbooks operacionais e procedimentos
└── src/                       # Código-fonte da aplicação
```

---

## 4. Três Categorias de Conhecimento

Para otimizar o foco da IA sem comprometer o raciocínio profundo:

1. **Instrução Permanente (`AGENTS.md`)**:
   - Invariantes inegociáveis do projeto (ex: não expor secrets, não fazer ações destrutivas sem autorização, comandos canônicos de teste).
   - Deve ser conciso e verificável.
2. **Conhecimento Contextual (`.agents/rules/`, `.agents/skills/`, `.agents/agents/`)**:
   - Carregado sob demanda quando a tarefa exigir (ex: regras de Supabase/Postgres, UI/UX craft, análise com Graphify, E2E com Playwright).
3. **Documentação Histórica (`docs/`)**:
   - ADRs, runbooks, post-mortems e diagramas.
   - Não consome contexto permanentemente, sendo consultado pela IA apenas quando relevante.

---

## 5. Especialistas & Agentes

### Especialistas Cognitivos (Separação Mental de Papéis)
- **`researcher`**: Investigação aprofundada, navegação arquitetural, levantamento de evidências e Graphify. Modo estrito somente leitura (nunca altera código).
- **`reviewer`**: Análise crítica e independente de diffs, validação de especificações, detecção de regressões e testes de caso de borda.
- **`security-reviewer`**: Auditoria de segurança de código, análise de superfície de ataque, SAST e conformidade com OWASP.

### Especialistas de Domínio (Agency Agents)
- **`software-architect`**: Decisões macro, bounded contexts (DDD) e matrizes de trade-off.
- **`backend-architect`**: Contratos de API, resiliência e migrações zero-downtime.
- **`frontend-developer`**: Engenharia de componentes, estado, acessibilidade WCAG e Core Web Vitals.
- **`database-optimizer`**: Planos de execução (`EXPLAIN ANALYZE`), estratégias de índices e RLS.
- **`security-architect`**: Modelagem de ameaças e trust boundaries.
- **`test-automation-engineer`**: Automação E2E (Playwright, WinApp) e eliminação de flakes.
- **`devops-automator`**: Pipelines de CI/CD (GitHub Actions), Docker e automação de release.

---

## 6. Profiles Composáveis

| Profile | Finalidade | Regras Habilitadas | Skills Principais |
|---|---|---|---|
| **`base`** | Engenharia padrão universal | Invariantes, Git, Verification | `context-engineering`, `systematic-debugging`, `diagnosing-bugs`, `ponytail`, `calm`, `graphify`, `codebase-design`, `devils-advocate`, `code-review` |
| **`web-supabase`** | Web fullstack moderno | Web Guidelines, Database Postgres | `ui-ux-pro-max`, `frontend-design`, `impeccable`, `vercel-react-best-practices`, `supabase`, `supabase-postgres-best-practices`, `playwright` |
| **`windows-desktop`** | Aplicações desktop Windows | Windows Desktop Guidelines | `winapp`, `playwright`, `security-best-practices` |
| **`monorepo`** | Monorepos e arquiteturas modulares | Modular Invariants | `domain-modeling`, `improve-codebase-architecture`, `understand-anything` |

---

## 7. Registry Canônico (`registry/`)

A fonte única da verdade para todo o ecossistema reside em arquivos JSON estruturados:

- [`registry/skills.json`](file:///c:/Users/CONTABILIDADE/Documents/AI-Dev-Machine/registry/skills.json): 33 Skills canônicas catalogadas com categoria, repositório de origem, ferramentas compatíveis e descrição.
- [`registry/agents.json`](file:///c:/Users/CONTABILIDADE/Documents/AI-Dev-Machine/registry/agents.json): 10 Agentes (3 cognitivos + 7 de domínio) com papéis, ferramentas e personas.
- [`registry/mcps.json`](file:///c:/Users/CONTABILIDADE/Documents/AI-Dev-Machine/registry/mcps.json): 10 Servidores MCP com escopo, transporte e variáveis de autenticação.
- [`registry/plugins.json`](file:///c:/Users/CONTABILIDADE/Documents/AI-Dev-Machine/registry/plugins.json): 6 Plugins composáveis para Antigravity.
- [`registry/profiles.json`](file:///c:/Users/CONTABILIDADE/Documents/AI-Dev-Machine/registry/profiles.json): 4 Perfis arquiteturais prontos para uso.

---

## 8. Segurança e Idempotência

- **Zero Caminhos Hardcoded**: Toda configuração respeita `$env:USERPROFILE` e caminhos relativos ao projeto.
- **Proteção de Secrets**: Verificações do `doctor` auditam a presença de variáveis de ambiente sem expor ou versionar valores confidenciais.
- **Backups e Rollback**: Qualquer operação de `migrate` gera backup automático antes de tocar no disco e possui rotina de restauração automática em caso de falha.
- **Preservação de Conteúdo Externo**: Scripts e ferramentas respeitam a tag `[PRESERVE EXTERNAL]`, nunca removendo artefatos customizados pelo usuário.
