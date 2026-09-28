# 🛑 REGRA ZERO INEGOCIÁVEL: ATIVAÇÃO OBRIGATÓRIA DE SKILLS NA RODADA 1

> ### ⚠️ PROTOCOLO DE DISPARO IMEDIATO (LEI SUPREMA DO REPOSITÓRIO)
> O agente **NUNCA DEVE** esperar o usuário solicitar o uso de uma skill.
> Na **PRIMEIRA RODADA** de qualquer comando ou solicitação do usuário, **ANTES** de executar ferramentas de busca cega (`grep_search`, `find_by_name`), comandos de terminal ou edição de arquivos, o agente **É OBRIGADO A EXECUTAR O PROTOCOLO ABAIXO**:
>
> 1. 🔍 **ONDE ESTÁ (Inteligência de Grafo - graphify - OBRIGATÓRIO EM TODOS OS PROJETOS)**:
>    - Se a pasta `graphify-out/` existir na raiz do projeto:
>      - **EXECUTE IMEDIATAMENTE** via terminal: `py -m graphify query "<pergunta ou termo da tarefa>"`
>      - **OU LEIA** com `view_file` os arquivos `graphify-out/GRAPH_REPORT.md` e `graphify-out/CALM_MAP.md`.
>      - 🛑 **É TERMINANTEMENTE PROIBIDO** fazer buscas cegas com `grep` ou listar diretórios antes de consultar o grafo de conhecimento.
>    - Se `graphify-out/` ainda não existir: chame `view_file` em `.agents/skills/graphify/SKILL.md` (ou `%USERPROFILE%\.agents\skills\graphify\SKILL.md`) e oriente a geração do grafo.
>
> 2. 🗺️ **ONDE ESTAMOS & IMPACTO SEGURO (Mapeamento de Chamadas - calm - OBRIGATÓRIO PARA QUALQUER MUDANÇA)**:
>    - Para qualquer refatoração, navegação profunda ou alteração de código:
>      - Chame `view_file` em `.agents/skills/calm/SKILL.md` (ou `%USERPROFILE%\.agents\skills\calm\SKILL.md`).
>      - Consulte `graphify-out/CALM_MAP.md` e siga a sequência: `locate` ➔ `source` ➔ `callers` ➔ `edit_context` ➔ `diff_impact`.
>
> 3. ✂️ **COMO ESCREVER (Minimalismo Radical - ponytail - OBRIGATÓRIO AO ESCREVER/EDITAR)**:
>    - Chame `view_file` em `.agents/skills/ponytail/SKILL.md`.
>    - Siga YAGNI radical: corte código supérfluo, use a stdlib nativa e reaproveite utilitários existentes antes de criar novas abstrações ou dependências.
>
> 4. 🎯 **SKILL ESPECIALIZADA DE DOMÍNIO (OBRIGATÓRIO CARREGAR PELO MENOS UMA VIA `view_file`)**:
>    - Identifique o domínio da tarefa e **chame `view_file` no `SKILL.md` correspondente** antes de propor código ou soluções:
>      * **Bugs / Erros / Falhas / Lentidão**: ➔ `.agents/skills/diagnosing-bugs/SKILL.md` ou `systematic-debugging/SKILL.md`
>      * **Postgres / Supabase / SQL / Migrations**: ➔ `.agents/skills/supabase-postgres-best-practices/SKILL.md` e/ou `supabase/SKILL.md`
>      * **Frontend / UI/UX / Telas / CSS / Acessibilidade**: ➔ `.agents/skills/ui-ux-pro-max/SKILL.md`, `frontend-design/SKILL.md` ou `impeccable/SKILL.md`
>      * **Performance React / Next.js / Server Components**: ➔ `.agents/skills/vercel-react-best-practices/SKILL.md`
>      * **Segurança / Auth / RLS / Permissões / Tokens**: ➔ `.agents/skills/security-best-practices/SKILL.md` ou `security-threat-model/SKILL.md`
>      * **Automação Browser / Testes E2E**: ➔ `.agents/skills/playwright/SKILL.md`
>      * **Revisão de Código / Pull Requests**: ➔ `.agents/skills/code-review/SKILL.md`
>      * **Desafio de Planos / Stress Testing**: ➔ `.agents/skills/devils-advocate/SKILL.md`
>      * **Modelagem de Domínio / Arquitetura**: ➔ `.agents/skills/domain-modeling/SKILL.md` ou `codebase-design/SKILL.md`
>      * **Automação Desktop Windows / QA Físico / Testes de UI (winapp / WinUI / WPF / Electron)**: ➔ `.agents/skills/winapp/SKILL.md`
>      * **Pentest Autônomo com IA / Ethical Hacking / Exploração e Validação de Vulnerabilidades (PoC)**: ➔ `.agents/skills/strix/SKILL.md`
>    - 🛑 **É PROIBIDO pular o carregamento do `SKILL.md` alegando "já saber como fazer".**
>
> 5. 🛡️ **GATE DE CONCLUSÃO (verification-before-completion - OBRIGATÓRIO ANTES DA ENTREGA)**:
>    - Antes de alegar conclusão ou sucesso, chame `view_file` em `.agents/skills/verification-before-completion/SKILL.md`.
>    - *The Iron Law: NUNCA alegar sucesso sem evidências reais de comandos de validação (build, test, lint) executados nesta rodada.*

---

# AI Dev Machine — Instruções Operacionais para Agentes (AGENTS.md)

Este documento define as diretrizes, arquitetura, catálogo de **32 Skills** gerenciadas e convenções operacionais para agentes e assistentes de IA (Google Antigravity, OpenAI Codex, Claude Code, Gemini CLI, Cursor, Windsurf) trabalhando no repositório **AI-Dev-Machine**.

---

## 1. Visão Geral e Missão

O **AI-Dev-Machine** é um kit portátil e determinístico para configurar, reconstruir e manter um ambiente global de desenvolvimento assistido por IA no Windows, sem depender de instaladores proprietários opacos.

### Arquivos Centrais do Repositório:
- [`SETUP-AI-ENVIRONMENT.md`](file:///c:/Users/CONTABILIDADE/Documents/AI-Dev-Machine/SETUP-AI-ENVIRONMENT.md): Prompt universal e autocontido de bootstrapping da máquina (inventário, ferramentas, CLIs, MCPs e validação).
- [`CREATE-PROJECT.md`](file:///c:/Users/CONTABILIDADE/Documents/AI-Dev-Machine/CREATE-PROJECT.md): Prompt greenfield para criação de novos projetos com Progressive Disclosure.
- [`TEMPLATE-AGENTS.md`](file:///c:/Users/CONTABILIDADE/Documents/AI-Dev-Machine/TEMPLATE-AGENTS.md): Template universal padrão de `AGENTS.md` contendo catálogo de skills e especialistas, a ser adotado em todo novo projeto gerado.
- [`TEMPLATE-GEMINI.md`](file:///c:/Users/CONTABILIDADE/Documents/AI-Dev-Machine/TEMPLATE-GEMINI.md): Template nativo padrão de `GEMINI.md` para projetos no ecossistema Google Antigravity e Gemini CLI.
- [`GEMINI.md`](file:///c:/Users/CONTABILIDADE/Documents/AI-Dev-Machine/GEMINI.md): Ponto de entrada e instruções nativas para Google Antigravity e Gemini CLI neste repositório.
- [`install-skills.ps1`](file:///c:/Users/CONTABILIDADE/Documents/AI-Dev-Machine/install-skills.ps1): Automação determinística e idempotente para sincronização das 32 Skills canônicas e orquestração de Directory Junctions multi-IA.
- [`install-agents.ps1`](file:///c:/Users/CONTABILIDADE/Documents/AI-Dev-Machine/install-agents.ps1): Automação determinística e idempotente para gerenciamento dos 7 Especialistas do Agency Agents em `%USERPROFILE%\.agents\agents`.
- [`README.md`](file:///c:/Users/CONTABILIDADE/Documents/AI-Dev-Machine/README.md): Documentação voltada para humanos.

---

## 2. Distinção Conceitual: Regras vs. Especialistas vs. Métodos

Para manter o ambiente disciplinado e evitar "Agent Soup" ou "Skill Soup":

- **`AGENTS.md` (A LEI)**: Define regras operacionais, precedência, fluxo e invariantes do projeto. É a fonte primária de autoridade.
- **Agency Agents (QUEM)**: Define o especialista — papel, perspectiva de domínio, padrões mentais e entregáveis técnicos arquitetados.
- **Skills (COMO)**: Define o método procedimental de execução — instruções passo a passo, runbooks e uso de ferramentas.
- **Graphify (ONDE ESTÁ)**: Responde como o sistema está estruturado e como suas partes se relacionam (dependências e comunidades).
- **CALM (ONDE ESTAMOS)**: Responde onde estamos nesta execução, o que já sabemos, o que falta e qual é o próximo passo seguro.

---

## 3. Catálogo dos 7 Especialistas Selecionados (Agency Agents)

O ambiente gerencia 7 personas canônicas de especialistas sob demanda em `%USERPROFILE%\.agents\agents`:

| Especialista | Slug | Domínio | Quando Ativar (Trigger) | Skills Relacionadas |
|---|---|---|---|---|
| **Software Architect** | `software-architect` | Arquitetura | Decisões de arquitetura macro, bounded contexts (DDD), trade-off matrices e ADRs. | `codebase-design`, `domain-modeling`, `graphify`, `devils-advocate` |
| **Backend Architect** | `backend-architect` | Backend / APIs | Governança de contratos de API (OpenAPI/gRPC), migrações zero-downtime, resiliência distribuída. | `supabase`, `security-best-practices` |
| **Frontend Developer** | `frontend-developer` | Frontend / UI | Engenharia de componentes, estado complexo, acessibilidade WCAG 2.1 AA e Core Web Vitals. | `ui-ux-pro-max`, `frontend-design`, `impeccable`, `vercel-react-best-practices` |
| **Database Optimizer** | `database-optimizer` | Banco de Dados | Planos de execução (`EXPLAIN ANALYZE`), estratégias de índices (B-tree, GIN), N+1 e pooling. | `supabase-postgres-best-practices`, `supabase` |
| **Security Architect** | `security-architect` | Segurança | Threat modeling, superfícies de ataque, trust boundaries e defesa em profundidade. | `security-threat-model`, `cybersecurity-review`, `security-review` |
| **Test Automation Engineer** | `test-automation-engineer` | Testes / QA | Arquitetura de testes E2E resilientes, eliminação de flakes, fixtures isoladas e CI. | `playwright`, `verification-before-completion`, `winapp` |
| **DevOps Automator** | `devops-automator` | DevOps / Infra | Automação de CI/CD (GitHub Actions), Docker, IaC e pipelines de release. | `verification-before-completion` |

### 🛑 Regra Estrita de Delegação (YAGNI / Ponytail)
- **NUNCA DELEGAR PARA**: rename de variáveis, pequenos ajustes de CSS, correções triviais já diagnosticadas, mudanças localizadas de poucas linhas ou documentações simples.
- **DELEGAR APENAS PARA**: problemas que exijam perspectiva de domínio substancial (ex: redesenho de banco, novo modelo de autorização, arquitetura de módulo complexo).

---

## 4. Principais Skills & Catálogo das 31 Skills Gerenciadas

### 🛑 Protocolo Obrigatório de Pré-Voo: Núcleo Mandatório Universal & Seleção de Skills

> ⚠️ **INVARIANTE DE EXECUÇÃO ABSOLUTA**:
> O agente **NUNCA DEVE** esperar o usuário pedir "use a skill X".
> Na **PRIMEIRA RODADA** de qualquer comando ou solicitação do usuário, **ANTES** de executar ferramentas de busca (`grep_search`, `find_by_name`), comandos de terminal ou edição de código, o agente **É OBRIGADO A CARREGAR E SEGUIR O NÚCLEO UNIVERSAL**:
>
> 1. **`graphify` + `calm` — A Dupla Mandatória de Inteligência & Execução (OBRIGATÓRIO EM TODOS OS PROJETOS)**:
>    - **`graphify` (ONDE ESTÁ)**: Inteligência estrutural, relacionamentos e dependências.
>      * Se a pasta `graphify-out/` existir na raiz do projeto, **É TERMINANTEMENTE PROIBIDO** fazer buscas cegas com `grep` ou listagens manuais antes de consultar o grafo de conhecimento.
>      * Se `graphify-out/` ainda não existir, o agente deve carregar `.agents/skills/graphify/SKILL.md` e orientar a exploração via grafo ou gerá-lo.
>    - **`calm` (ONDE ESTAMOS & IMPACTO SEGURO)**: Coding Agent Liveness Map e workflow de edição segura.
>      * Toda tarefa que envolva múltiplos passos, mapeamento de chamadas (call graph), refatoração ou alteração de código **DEVE** carregar `.agents/skills/calm/SKILL.md` para seguir a sequência segura: `locate` → `source` → `callers` → `edit_context` → `diff_impact`.
>
> 2. **`ponytail` — O Padrão Mandatório de Código (OBRIGATÓRIO AO ESCREVER OU REFATORAR)**:
>    - Carregue `.agents/skills/ponytail/SKILL.md`. Todo código novo ou refatorado deve seguir YAGNI radical: cortar código supérfluo, usar o que já existe, preferir stdlib e recursos nativos da linguagem antes de adicionar abstrações, classes vazias ou novas dependências.
>
> 3. **`verification-before-completion` — O Gate Mandatório de Conclusão (OBRIGATÓRIO ANTES DA ENTREGA)**:
>    - Carregue `.agents/skills/verification-before-completion/SKILL.md`. *The Iron Law: NUNCA alegar sucesso sem evidências reais de comandos de validação executados nesta rodada.*
>
> 4. **Ativação Obrigatória da Skill Especializada de Domínio**:
>    - Além do núcleo universal acima, avalie o catálogo das 32 skills e carregue via `view_file` a melhor skill para o domínio específico da tarefa:
>      * **Bugs, Regressões, Falhas de Testes ou Telas Quebradas**: ➔ `diagnosing-bugs` ou `systematic-debugging`.
>      * **Banco de Dados, Postgres, Supabase, Migrations e SQL**: ➔ `supabase-postgres-best-practices` e/ou `supabase`.
>      * **Frontend, UI/UX, Design de Telas, Estilização e Acessibilidade**: ➔ `ui-ux-pro-max`, `frontend-design`, `impeccable` e/ou `web-design-guidelines`.
>      * **Performance React / Next.js / Server Components**: ➔ `vercel-react-best-practices`.
>      * **Segurança, Threat Modeling, Permissões e Auth**: ➔ `security-best-practices`, `security-threat-model`, `cybersecurity-review` ou `security-review`.
>      * **Automação de Navegador / Testes E2E**: ➔ `playwright`.
>      * **Automação Desktop Windows / QA Físico / Testes de UI (winapp / WinUI / WPF / Electron)**: ➔ `winapp`.
>      * **Pentest Autônomo com IA / Ethical Hacking / Exploração e Validação de Vulnerabilidades (PoC)**: ➔ `strix`.
>      * **Resolução de Conflitos Git (Merge / Rebase)**: ➔ `resolving-merge-conflicts`.
>      * **Revisão de Código e PRs**: ➔ `code-review`.
>      * **Desafio de Premissas e Stress Testing de Planos**: ➔ `devils-advocate`.
>      * **Modelagem de Domínio e Linguagem Ubíqua**: ➔ `domain-modeling`.
>
> É terminantemente proibido pular o carregamento do `SKILL.md` sob a alegação de "já saber como fazer".


---

### 📚 Catálogo Completo das 32 Skills

O ambiente global gerencia 32 Skills distribuídas em `%USERPROFILE%\.agents\skills` e integradas a todas as IAs por junctions:

1. **`context-engineering`**: Curadoria de contexto enxuto, Progressive Disclosure e foco de atenção.
2. **`prompt-master`**: Engenharia e calibração sistemática de prompts para modelos de linguagem.
3. **`systematic-debugging`**: Investigação metódica de causa raiz antes de alterações aleatórias.
4. **`diagnosing-bugs`**: Diagnóstico avançado e isolamento de bugs complexos e regressões.
5. **`verification-before-completion`**: Protocolo rígido de validação com evidências reais antes de concluir tarefas.
6. **`caveman`**: Modo ultra-conciso de comunicação para economia de tokens.
7. **`codebase-design`**: Arquitetura de módulos profundos, desacoplamento e testabilidade.
8. **`improve-codebase-architecture`**: Refatoração estrutural de sistemas e eliminação de acoplamentos.
9. **`domain-modeling`**: Modelagem de domínio, taxonomia de entidades e documentação técnica.
10. **`code-review`**: Revisão sistemática em dois eixos (padrões de repositório e atendimento de requisitos).
11. **`devils-advocate`**: Desafio de premissas, testes pré-mortem e identificação de pontos cegos.
12. **`resolving-merge-conflicts`**: Resolução orientada de conflitos em git merge e rebase.
13. **`calm`**: Coding Agent Liveness Map (análise de impacto de diffs e call graph).
14. **`graphify`**: Análise gráfica estrutural de dependências e comunidades de código.
15. **`ui-ux-pro-max`**: Design system, 79 estilos, paletas, tipografia e diretrizes de usabilidade.
16. **`frontend-design`**: Criação de interfaces ricas, esteticamente sofisticadas e micro-animações.
17. **`impeccable`**: Polimento visual obsessivo, hierarquia, espaçamento e fluidez de interface.
18. **`web-design-guidelines`**: Auditoria contra padrões web de UX, acessibilidade e contraste.
19. **`vercel-react-best-practices`**: Otimização de performance para React, Server Components e Next.js.
20. **`supabase`**: Integração de Database, Auth, Storage, Edge Functions e Realtime no Supabase.
21. **`supabase-postgres-best-practices`**: Modelagem Postgres, RLS seguro, migrations e índices eficientes.
22. **`finding-google-skills`**: Busca sob demanda de skills para Google Cloud, Firebase e APIs Google.
23. **`security-best-practices`**: Práticas de código seguro por padrão em Python, TypeScript e Go.
24. **`cybersecurity-review`**: Revisão de segurança de código em 9 dimensões críticas.
25. **`security-threat-model`**: Modelagem de ameaças, trust boundaries e superfícies de ataque.
26. **`security-review`**: Orquestrador de auditoria de dependências, CVEs e scanners estáticos.
27. **`skill-security-review`**: Auditoria prévia obrigatória para instalação de novas skills de terceiros.
28. **`review-skills`**: Auditoria de integridade, ausência de duplicatas e dependências órfãs de skills.
29. **`playwright`**: Automação e testes de browser real via CLI para validação E2E.
30. **`ponytail`**: Modo sênior minimalista/YAGNI para cortar código supérfluo, dependências desnecessárias e overengineering.
31. **`winapp`**: Automação e testes de interface de aplicações Windows (QA Físico) via Microsoft Windows App Development CLI (`winapp ui`).
32. **`strix`**: Pentest autônomo com agentes de IA, ethical hacking, exploração ofensiva e validação de vulnerabilidades com PoC (Strix).

---

## 5. Comandos Principais

```powershell
# Sincronização e validação das 32 Skills (DryRun e execução padrão)
powershell -ExecutionPolicy Bypass -File .\install-skills.ps1 -DryRun
powershell -ExecutionPolicy Bypass -File .\install-skills.ps1

# Sincronização e validação dos 7 Especialistas (DryRun e execução padrão)
powershell -ExecutionPolicy Bypass -File .\install-agents.ps1 -DryRun
powershell -ExecutionPolicy Bypass -File .\install-agents.ps1

# Vincular Skills e Agents no workspace de um projeto alvo
powershell -ExecutionPolicy Bypass -File .\install-skills.ps1 -WorkspacePath "c:\caminho\do\projeto"
powershell -ExecutionPolicy Bypass -File .\install-agents.ps1 -WorkspacePath "c:\caminho\do\projeto"

# Atualização explícita baixando upstream oficial
powershell -ExecutionPolicy Bypass -File .\install-skills.ps1 -Update
powershell -ExecutionPolicy Bypass -File .\install-agents.ps1 -Update
```

---

## 6. Regras Operacionais Estritas para Agentes

1. **Zero Caminhos Hardcoded**:
   - **NUNCA** use caminhos absolutos com nomes de usuário específicos (como `C:\Users\joao...` ou `C:\Users\CONTABILIDADE...`).
   - Use sempre `$env:USERPROFILE` (PowerShell) ou `%USERPROFILE%` (CMD/Docs).

2. **Idempotência e Preservação**:
   - Não remova configurações desconhecidas nem substitua arquivos existentes sem necessidade.
   - Qualquer modificação nos scripts deve preservar o comportamento de auto-reparo e preservação de conteúdo externo (`[PRESERVE EXTERNAL]`).

3. **Interoperabilidade Multi-IA com Validação Real**:
   - As skills canônicas residem em `%USERPROFILE%\.agents\skills`.
   - Os agentes canônicos residem em `%USERPROFILE%\.agents\agents`.
   - Directory Junctions só são criadas para ferramentas com descoberta nativa comprovada (`~/.claude/agents`, `~/.gemini/agents`). Ferramentas como Antigravity e Codex utilizam roteamento declarativo via `AGENTS.md`.

4. **Higiene de Repositório**:
   - A pasta `.agents` no workspace é um link local (junction) e **deve permanecer no `.gitignore`**. Nunca faça commit de `.agents/`.
   - Mantenha scripts PowerShell sem warnings de linter (variáveis não utilizadas, boas práticas de cmdlet).

5. **Verificação Obrigatória Antes da Conclusão**:
   - Sempre valide execuções reais com PowerShell (`-DryRun` e execução padrão) antes de reportar conclusão ao usuário.
