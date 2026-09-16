# AI Dev Machine — Instruções Operacionais para Agentes (AGENTS.md)

Este documento define as diretrizes, arquitetura, catálogo de **30 Skills** gerenciadas e convenções operacionais para agentes e assistentes de IA (Google Antigravity, OpenAI Codex, Claude Code, Gemini CLI, Cursor, Windsurf) trabalhando no repositório **AI-Dev-Machine**.

---

## 1. Visão Geral e Missão

O **AI-Dev-Machine** é um kit portátil e determinístico para configurar, reconstruir e manter um ambiente global de desenvolvimento assistido por IA no Windows, sem depender de instaladores proprietários opacos.

### Arquivos Centrais do Repositório:
- [`SETUP-AI-ENVIRONMENT.md`](file:///c:/Users/CONTABILIDADE/Documents/AI-Dev-Machine/SETUP-AI-ENVIRONMENT.md): Prompt universal e autocontido de bootstrapping da máquina (inventário, ferramentas, CLIs, MCPs e validação).
- [`CREATE-PROJECT.md`](file:///c:/Users/CONTABILIDADE/Documents/AI-Dev-Machine/CREATE-PROJECT.md): Prompt greenfield para criação de novos projetos com Progressive Disclosure.
- [`TEMPLATE-AGENTS.md`](file:///c:/Users/CONTABILIDADE/Documents/AI-Dev-Machine/TEMPLATE-AGENTS.md): Template universal padrão de `AGENTS.md` contendo catálogo de skills e especialistas, a ser adotado em todo novo projeto gerado.
- [`install-skills.ps1`](file:///c:/Users/CONTABILIDADE/Documents/AI-Dev-Machine/install-skills.ps1): Automação determinística e idempotente para sincronização das 30 Skills canônicas e orquestração de Directory Junctions multi-IA.
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
| **Test Automation Engineer** | `test-automation-engineer` | Testes / QA | Arquitetura de testes E2E resilientes, eliminação de flakes, fixtures isoladas e CI. | `playwright`, `verification-before-completion` |
| **DevOps Automator** | `devops-automator` | DevOps / Infra | Automação de CI/CD (GitHub Actions), Docker, IaC e pipelines de release. | `verification-before-completion` |

### 🛑 Regra Estrita de Delegação (YAGNI / Ponytail)
- **NUNCA DELEGAR PARA**: rename de variáveis, pequenos ajustes de CSS, correções triviais já diagnosticadas, mudanças localizadas de poucas linhas ou documentações simples.
- **DELEGAR APENAS PARA**: problemas que exijam perspectiva de domínio substancial (ex: redesenho de banco, novo modelo de autorização, arquitetura de módulo complexo).

---

## 4. Principais Skills & Catálogo das 30 Skills Gerenciadas

### 🌟 Principais Skills (Núcleo Operacional)

Estas Skills formam o núcleo operacional do ambiente. Elas não precisam ser carregadas simultaneamente; devem ser utilizadas conforme a fase e o tipo da tarefa:

#### Navegação e execução
- **`graphify`**: Ferramenta primária para compreender arquitetura, dependências, módulos e fluxo do sistema antes de explorar arquivos manualmente.
- **`calm`**: Mantém o mapa operacional da tarefa: objetivo, progresso, evidências, findings, próximos passos e STOP conditions.
- **`context-engineering`**: Use quando a tarefa possuir contexto significativo, múltiplos módulos ou risco de context bloat.

#### Implementação e raciocínio
- **`diagnosing-bugs`**: Skill principal para bugs, regressões e comportamento inesperado. (Não combinar automaticamente com `systematic-debugging`).
- **`codebase-design`**: Skill principal para criação ou alteração relevante de módulos, interfaces e boundaries.
- **`ponytail`**: Antídoto contra overengineering e complexidade acidental. Aplica a escada YAGNI (eliminar código desnecessário, reusar código existente, preferir stdlib/plataforma nativa e gerar o mínimo de código funcional).
- **`devils-advocate`**: Use antes de consolidar decisões técnicas importantes para questionar premissas, complexidade, riscos e alternativas.
- **`security-best-practices`**: Use durante alterações que afetem autenticação, autorização, APIs, dados, secrets, permissões ou outras superfícies sensíveis.

#### Revisão e conclusão
- **`code-review`**: Revise o diff e sua aderência à arquitetura, padrões, especificação e qualidade antes de fechar uma alteração relevante.
- **`verification-before-completion`**: Obrigatória antes de declarar a tarefa concluída. Exija evidência proporcional ao escopo: testes, typecheck, lint, build, browser, queries ou outros checks relevantes.

---

### 📚 Catálogo Completo das 30 Skills

O ambiente global gerencia 30 Skills distribuídas em `%USERPROFILE%\.agents\skills` e integradas a todas as IAs por junctions:

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

---

## 5. Comandos Principais

```powershell
# Sincronização e validação das 30 Skills (DryRun e execução padrão)
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
