# AI Dev Machine

## O que é

Um kit portátil para reconstruir um ambiente global de desenvolvimento com IA usando:

- um prompt universal de setup;
- um sincronizador determinístico de Skills.

O projeto não depende de um instalador proprietário gigante nem de uma IA específica em runtime.

## Como funciona

Em uma máquina nova:

1. instale manualmente uma IA capaz de usar o terminal;
2. baixe ou clone este repositório;
3. entregue `SETUP-AI-ENVIRONMENT.md` para essa IA;
4. deixe a IA instalar programas, CLIs, dependências e MCPs com documentação oficial atual;
5. execute `install-skills.ps1`;
6. faça os logins interativos pendentes;
7. valide o relatório final do ambiente.

## Arquivos

### `SETUP-AI-ENVIRONMENT.md`

Prompt universal, autocontido, com inventário, regras de preservação, fontes oficiais, ordem de instalação, MCPs, Skills, autenticação e validação.

### `install-skills.ps1`

Automação determinística e idempotente para sincronização das 31 Skills canônicas em `%USERPROFILE%\.agents\skills` e integração por junctions para Google Antigravity IDE, Gemini CLI, Claude Code e OpenAI Codex (com controle de exceção para skills exclusivas como `windows-mcp`).

### `install-agents.ps1`

Automação determinística e idempotente para gerenciamento seletivo dos 7 Especialistas essenciais do Agency Agents em `%USERPROFILE%\.agents\agents`, com suporte a auto-reparo, atualização atômica (`-Update`), dry-run (`-DryRun`) e junctions seguras para Claude Code e Gemini CLI.

Uso:

```powershell
# Simulação somente leitura
.\install-agents.ps1 -DryRun

# Execução padrão idempotente (sem rede se íntegro)
.\install-agents.ps1

# Vincular ao workspace de um projeto alvo
.\install-agents.ps1 -WorkspacePath "c:\caminho\para\projeto"

# Atualização explícita baixando upstream
.\install-agents.ps1 -Update
```

### `CREATE-PROJECT.md`

Prompt greenfield para usar sempre que um projeto novo for iniciado. Primeiro você explica a ideia do produto; depois entrega este arquivo à IA para orientar a escolha de stack, arquitetura, Skills, MCPs e ferramentas usando Progressive Disclosure. Ele não presume código ou repositório existentes.

### `TEMPLATE-AGENTS.md`

Modelo universal e padronizado de `AGENTS.md` para qualquer novo projeto criado com IA. Fornece seções prontas para stack, comandos, convenções de código, regras de segurança, ativação de skills por Progressive Disclosure e checklist de verificação.

### `TEMPLATE-GEMINI.md`

Modelo nativo e padronizado de `GEMINI.md` para projetos no ecossistema Google Antigravity e Gemini CLI, contendo a Regra Zero de disparo obrigatório de skills e apontando para as regras canônicas de `AGENTS.md`.

### `AGENTS.md`

Instruções operacionais específicas para assistentes e agentes de IA que atuam neste próprio repositório (`AI-Dev-Machine`), garantindo respeito à idempotência, ausência de caminhos hardcoded e interoperabilidade multi-IA.

### `GEMINI.md`

Ponto de entrada primário e regras nativas para Google Antigravity e Gemini CLI atuando no repositório `AI-Dev-Machine`.

## O que será configurado pela IA

- aplicativos desktop: ChatGPT Desktop/Codex, Claude Desktop e Google Antigravity IDE;
- CLIs de IA: Codex CLI, Claude Code, GitHub Copilot CLI, Gemini CLI e Antigravity CLI quando suportado;
- ferramentas de desenvolvimento: Git, GitHub CLI, Node.js LTS, npm, pnpm, Python, uv, ripgrep, jq, ast-grep, Playwright CLI, Graphify, Semgrep, Trivy e Gitleaks;
- 31 Skills globais gerenciadas;
- 7 Especialistas gerenciados (Agency Agents);
- MCPs base e catálogo sob demanda.

Os métodos e versões devem ser confirmados na documentação oficial atual da máquina real.

## Taxonomia Conceitual: O que é o quê?

Para evitar sobrecarga de contexto ("Agent Soup" ou "Skill Soup"), o ambiente divide responsabilidades com clareza:

- **`AGENTS.md` (Regras Operacionais)**: É a lei suprema do repositório. Define invariantes, comandos, estilo e limites de ação da IA.
- **Agency Agents (QUEM / Especialistas)**: Personas com perspectiva de domínio profundo, padrões mentais e entregáveis técnicos arquitetados.
- **Skills (COMO / Métodos)**: Procedimentos práticos, runbooks passo a passo e conhecimento de ferramentas.
- **MCPs (Ferramentas & Contexto Externo)**: Servidores de integração com bancos, browsers, APIS e documentação externa.
- **Graphify (ONDE ESTÁ / Estrutura)**: Mapa estrutural de dependências, comunidades de código e topologia do repositório.
- **CALM (ONDE ESTAMOS / Liveness)**: Mapa operacional da tarefa em andamento (objetivo, evidências, blast radius e próximo passo seguro).

## Especialistas Gerenciados (Agency Agents)

O ecossistema gerencia seletivamente 7 especialistas canônicos em `%USERPROFILE%\.agents\agents`:

| Especialista | Slug | Domínio | Quando Ativar |
|---|---|---|---|
| **Software Architect** | `software-architect` | Arquitetura | Decisões de arquitetura macro, bounded contexts (DDD), ADRs e trade-offs. |
| **Backend Architect** | `backend-architect` | Backend / APIs | Governança de APIs (OpenAPI/gRPC), resiliência distribuída e migrações zero-downtime. |
| **Frontend Developer** | `frontend-developer` | Frontend / UI | Engenharia de componentes, estado complexo, WCAG AA e Core Web Vitals. |
| **Database Optimizer** | `database-optimizer` | Banco de Dados | Query plans (`EXPLAIN ANALYZE`), estratégias de indexação e schema design. |
| **Security Architect** | `security-architect` | Segurança | Modelagem de ameaças, superfícies de ataque, trust boundaries e defesa em profundidade. |
| **Test Automation Engineer** | `test-automation-engineer` | Testes / QA | Arquitetura de testes E2E Playwright determinísticos, fixtures isoladas e suites sem flake. |
| **DevOps Automator** | `devops-automator` | DevOps / Infra | CI/CD GitHub Actions, Docker, IaC e automação de deployment. |

### Regra Estrita de Delegação
- **Tarefas triviais** (renames, pequenas alterações de CSS, correções de poucas linhas): resolvidas diretamente pelo agente atual sem delegação.
- **Tarefas de domínio substantivas**: ativam a perspectiva ou persona do especialista sob demanda.

## Skills gerenciadas

| Skill | Fonte | Finalidade |
|---|---|---|
| context-engineering | addyosmani/agent-skills | Gestão progressiva de contexto |
| prompt-master | nidhinjs/prompt-master | Estruturação de prompts |
| systematic-debugging | obra/superpowers | Investigação de causa raiz |
| verification-before-completion | obra/superpowers | Verificação antes da conclusão |
| vercel-react-best-practices | vercel-labs/agent-skills | Boas práticas React/Next.js |
| ui-ux-pro-max | nextlevelbuilder/ui-ux-pro-max-skill | Design de UI/UX |
| frontend-design | anthropics/claude-code | Design visual e interação |
| web-design-guidelines | vercel-labs/agent-skills | Diretrizes de interfaces web |
| supabase | supabase/agent-skills | Supabase e autenticação |
| supabase-postgres-best-practices | supabase/agent-skills | Schema e desempenho Postgres |
| security-best-practices | openai/skills | Práticas de segurança |
| security-threat-model | openai/skills | Modelagem de ameaças |
| finding-google-skills | google/skills | Carregamento sob demanda de Skills Google |
| graphify | Graphify-Labs/graphify | Skill de análise estrutural do código |
| playwright | openai/skills | Automação de navegador |
| caveman | JuliusBrussee/caveman | Saída compacta, manual/on-demand |
| diagnosing-bugs | mattpocock/skills | Loop disciplinado para bugs difíceis e regressões |
| code-review | mattpocock/skills | Revisão de diffs em dois eixos (Standards vs Spec) |
| codebase-design | mattpocock/skills | Vocabulário e princípios de design de módulos profundos |
| improve-codebase-architecture | mattpocock/skills | Identificação de atrito e refatoração arquitetural |
| cybersecurity-review | ericmjl/skills | Auditoria abrangente em 9 dimensões de segurança |
| security-review | bestdeejay-design/agent-skills | Orquestração de scanners reais (Semgrep, Trivy, Gitleaks, etc.) |
| review-skills | tomzx/agents | Auditoria da biblioteca de skills (duplicatas, links, gaps) |
| skill-security-review | klh/speedy-claude | Auditoria de segurança antes de instalar skills de terceiros |
| domain-modeling | mattpocock/skills | Modelagem de domínio e linguagem ubíqua |
| resolving-merge-conflicts | mattpocock/skills | Resolução estruturada de conflitos de merge e rebase |
| devils-advocate | Mathews-Tom/armory | Desafio adversarial a planos, código e arquitetura (pre-mortem, inversão) |
| impeccable | pbakaus/impeccable | Design craft e direção estética anti-slop (Paul Bakaus) |
| calm | Eilodon/CALM | Workflow e mapa de liveness (Coding Agent Liveness Map, call graph e safe edit) |
| ponytail | DietrichGebert/ponytail | Redução de overengineering, soluções mínimas e YAGNI |
| windows-mcp | local (AI-Dev-Machine) | Automação desktop Windows via MCP (UI tree, vision, mouse, teclado, janelas) |

`finding-google-skills` não instala o catálogo Google inteiro. `graphify` usa somente a variante de Agent Skills. `caveman` não instala proxy, hooks ou serviço always-on. `ponytail` instala somente a Skill canônica, sem hooks ou serviços. `windows-mcp` é exclusivo para Windows (Google Antigravity e Claude Code; excluído do OpenAI Codex).

## MCPs

### Base

- Context7
- Chrome DevTools (possui integração nativa no fluxo de browser do Antigravity IDE; não configurar MCP redundante se a integração já estiver disponível)

### Sob demanda

- Next DevTools para projetos Next.js
- Supabase MCP
- GitHub MCP
- Vercel MCP
- Semgrep MCP
- Playwright MCP
- Graphify MCP
- CALM MCP (Coding Agent Liveness Map)

Disponível sob demanda não significa sempre ativo. A configuração deve usar o formato oficial atual de cada agente e preservar integrações existentes.

## Progressive Disclosure

Ferramentas e Skills podem estar instaladas globalmente sem serem carregadas em todas as tarefas. Use apenas o que for relevante:

```text
Código:   rg → ast-grep → leitura direcionada → Graphify quando necessário
Docs:     local/versionada → oficial → Context7
Browser:  Playwright CLI → Chrome DevTools para diagnóstico profundo
GitHub:   git → gh → GitHub MCP quando trouxer benefício
```

## Preservação

O ambiente é aditivo e preservador:

- nada existente é removido automaticamente;
- Skills externas ou desconhecidas são preservadas;
- configurações existentes recebem backup e merge;
- não há prune nem substituição indiscriminada;
- autenticação permanece sob controle do usuário.

## Instalação em nova máquina

1. Instale uma IA com acesso ao terminal.
2. Clone ou baixe este repositório.
3. Entregue `SETUP-AI-ENVIRONMENT.md` à IA.
4. Revise e execute o inventário proposto.
5. Instale e valide programas, CLIs, aplicativos e MCPs pelas fontes oficiais atuais.
6. Execute `install-skills.ps1 -DryRun` e revise o plano.
7. Execute `install-skills.ps1`.
8. Faça os logins interativos solicitados.
9. Revise o relatório final; só declare o ambiente pronto com evidências reais.

## Iniciar um projeto novo

Quando ainda não existe código, repositório ou arquitetura:

1. converse com uma IA e explique a ideia do produto;
2. descreva usuários, funcionalidades, restrições e objetivos;
3. entregue `CREATE-PROJECT.md`;
4. revise a proposta de stack e arquitetura;
5. deixe a IA criar o projeto do zero e validar cada etapa.

`CREATE-PROJECT.md` não é um prompt para manutenção de um repositório existente.

## Atualizar Skills

Para atualizar as Skills gerenciadas a partir dos repositórios oficiais upstream, use a flag `-Update`:

Primeiro simule a atualização:

```powershell
.\install-skills.ps1 -Update -DryRun
```

Depois execute a atualização real:

```powershell
.\install-skills.ps1 -Update
```

O sincronizador usa clones temporários, valida `SKILL.md`, atualiza somente diretórios gerenciados, restaura a versão anterior se uma atualização falhar e revalida as junctions do Google Antigravity IDE. Se executado sem `-Update`, o script verifica e mantém as Skills locais sem fazer requisições de rede.

## Segurança

- use somente fontes oficiais e documentação atual;
- não armazene segredos, tokens ou chaves em texto puro;
- não desabilite UAC ou políticas globais;
- faça backup antes de alterar configurações;
- deixe autenticação para fluxos interativos oficiais;
- trate bloqueios de rede, permissão e sandbox como limitações explícitas.

## Filosofia

Pequeno. Portátil. Preservador. Multi-agent. Determinístico onde há automação própria e flexível onde a documentação oficial da máquina precisa ser consultada.
