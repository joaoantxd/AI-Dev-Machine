# AI-Dev-Machine — Architecture v2.1

> **Capability-Driven Framework & Multi-Agent Governance Platform**
> Um kit determinístico, genérico e portátil para configurar, auditar e materializar ambientes e projetos de desenvolvimento de software assistidos por IA no Windows, nativamente compatível com Google Antigravity, OpenAI Codex, Claude Code e Gemini CLI.
>
> 📦 **Instalação Global e Organização**: [docs/INSTALAR-E-ORGANIZAR.md](docs/INSTALAR-E-ORGANIZAR.md) — Prompt único de onboarding para instalar e configurar o AI-Dev-Machine em qualquer máquina Windows via Antigravity IDE.
> 🚀 **Primeiro Prompt por Projeto**: [docs/PRIMEIRO-PROMPT.md](docs/PRIMEIRO-PROMPT.md) — Fase 0 de inventário e organização do workspace (read-only).
> 🎯 **Prompt-Mestre Universal**: [docs/PROMPT-MESTRE-CHATGPT.md](docs/PROMPT-MESTRE-CHATGPT.md) — Engenheiro universal de prompts para qualquer IA ou domínio.
> 🤖 **Instruções Globais ChatGPT**: [docs/CHATGPT-INSTRUCOES-GLOBAIS.md](docs/CHATGPT-INSTRUCOES-GLOBAIS.md) — Configuração persistente para a conta do ChatGPT.
> 🧠 **Segundo Cérebro (Obsidian)**: Hub operacional de decisões, arquitetura e handoffs entre agentes.

---

## 1. Prompts Prontos para Uso (`Ctrl+A → Ctrl+C → Ctrl+V`)

Os arquivos de prompts na pasta `docs/` contêm **exclusivamente o texto final a ser enviado**, sem introduções, explicações ou blocos de código markdown delimitadores. Basta abrir o arquivo, selecionar tudo (`Ctrl+A`), copiar (`Ctrl+C`) e colar (`Ctrl+V`) diretamente no destino:

| Documento | Destino de Aplicação | Função Principal |
| :--- | :--- | :--- |
| **[`docs/INSTALAR-E-ORGANIZAR.md`](docs/INSTALAR-E-ORGANIZAR.md)** | Painel de chat do **Google Antigravity IDE** (Primeira vez na máquina ou onboarding). | Executa o **diagnóstico, instalação global e governança** de ponta a ponta com inventário seguro (read-only), plano aprovado e configuração automática do catálogo de 35 Skills. |
| **[`docs/PRIMEIRO-PROMPT.md`](docs/PRIMEIRO-PROMPT.md)** | Painel de chat do **Google Antigravity IDE** ao abrir qualquer workspace de projeto novo ou existente. | Executa a **Fase 0: Inventário, Compreensão e Organização** em modo estritamente *somente leitura*, mapeando a estrutura e governança antes de qualquer código. |
| **[`docs/PROMPT-MESTRE-CHATGPT.md`](docs/PROMPT-MESTRE-CHATGPT.md)** | Primeira mensagem de uma nova conversa no **ChatGPT**, **Claude**, **Gemini**, ou instruções de um **Custom GPT / Projeto**. | Ativa a atuação de **Arquiteto de Instruções e Engenheiro de Prompts de Elite** para qualquer modelo, ferramenta, mídia (imagem, vídeo, áudio, código) ou finalidade. |
| **[`docs/CHATGPT-INSTRUCOES-GLOBAIS.md`](docs/CHATGPT-INSTRUCOES-GLOBAIS.md)** | **ChatGPT** → *Configurações* → *Personalizar ChatGPT* → Campo *"Como você gostaria que o ChatGPT respondesse?"* | Transforma o ChatGPT de forma permanente em um **Engenheiro Universal de Prompts**, com especialização em software (AI-Dev-Machine e Antigravity) para todas as conversas da conta. |

---

## 2. Início Rápido para Terceiros (Instalação em Qualquer Máquina)

Siga este passo a passo para instalar o AI-Dev-Machine em um novo computador Windows:

### 1. Obtenção do Pacote
Clone o repositório ou baixe o arquivo ZIP e extraia em qualquer pasta pessoal:
```bash
git clone https://github.com/joaoantxd/AI-Dev-Machine.git
```

### 2. Pré-Requisitos
- **Sistema Operacional**: Windows 10 ou 11 (64-bit).
- **PowerShell**: PowerShell 5.1 ou PowerShell 7+.
- **Git for Windows**: `winget install Git.Git --source winget` (necessário para sincronização inicial de Skills upstream).
- **IDE**: Google Antigravity IDE (ou Gemini CLI).

### 3. O que abrir no Antigravity
1. Abra o **Google Antigravity IDE**.
2. Abra a pasta raiz onde o `AI-Dev-Machine` foi clonado/extraído.

### 4. Executar o Prompt Único de Onboarding
1. Abra o arquivo [`docs/INSTALAR-E-ORGANIZAR.md`](docs/INSTALAR-E-ORGANIZAR.md).
2. Pressione `Ctrl+A` para selecionar tudo e `Ctrl+C` para copiar.
3. Cole (`Ctrl+V`) no chat do Antigravity IDE e envie.

### 5. Como o Agente Opera
1. **Inventário Read-Only**: O agente investiga ferramentas instaladas, ambiente global do Antigravity e estado do projeto.
2. **Apresentação do Plano**: O agente exibe o diagnóstico e pede autorização explícita para aplicar as mudanças globais e locais.
3. **Execução Segura**: Após sua aprovação, o agente sincroniza a biblioteca canônica (`%USERPROFILE%\.agents`), expõe as 35 Skills fisicamente em `%USERPROFILE%\.gemini\config\skills\` e ativa a regra de roteamento dinâmico em `%USERPROFILE%\.gemini\config\rules\skill-routing.md`.
4. **Preservação de Dados**: Skills, regras e arquivos customizados pré-existentes são integralmente preservados com backups automáticos.

### 6. Como Validar a Instalação
No terminal PowerShell, execute:
```powershell
# Diagnóstico completo de saúde do sistema
powershell -ExecutionPolicy Bypass -File .\aidev.ps1 doctor

# Suíte completa de testes automatizados
powershell -ExecutionPolicy Bypass -File .\aidev.ps1 test
```

### 7. Como Atualizar ou Reparar a Configuração
Para atualizar Skills e regras a partir dos repositórios upstream:
```powershell
powershell -ExecutionPolicy Bypass -File .\aidev.ps1 sync -Update
```

### 8. Como Preservar ou Desinstalar Componentes Gerenciados
- **Limpeza de links e regras órfãs**: `powershell -ExecutionPolicy Bypass -File .\aidev.ps1 clean`
- **Backups**: Criados automaticamente com timestamp em `%USERPROFILE%\.gemini\config\skills_backup_*`. Arquivos customizados locais nunca são removidos.

---

## 3. Por que a Ativação Automática de Skills Funciona

O ecossistema AI-Dev-Machine elimina a necessidade de ativação manual ou injeção forçada de contexto através de uma arquitetura de 4 pilares:

```text
%USERPROFILE%\.gemini\config\skills\ (35 Diretórios Físicos)
              ↓
  Descoberta Nativa do Antigravity (Injeção automática em <skills>)
              ↓
%USERPROFILE%\.gemini\config\rules\skill-routing.md (always_on)
              ↓
  Roteamento Dinâmico Multidimensional ao Longo de Toda a Tarefa
              ↓
  Progressive Disclosure: view_file no SKILL.md no momento exato
```

1. **Diretórios Físicos em `%USERPROFILE%\.gemini\config\skills`**:
   - Em vez de depender de junctions ou symlinks que falham em certas versões do Windows, o materializer mantém diretórios físicos sincronizados com `SKILL.md` padronizado.
2. **Descoberta Global Nativa**:
   - O Antigravity IDE varre nativamente o diretório global e disponibiliza todas as 35 Skills na seção `<skills>` do system prompt em qualquer workspace.
3. **Regra Global `skill-routing.md` (`trigger: always_on`)**:
   - Reside em `%USERPROFILE%\.gemini\config\rules\skill-routing.md`. É injetada em todas as conversas sem necessidade de configuração por workspace.
4. **Ativação Dinâmica em Todo o Ciclo de Vida**:
   - A regra opera de forma contínua em 5 gatilhos:
     - **Gate 0 (Início da Tarefa)**: Identificação do domínio inicial da solicitação.
     - **Descoberta de Stack**: Ao inspecionar o código e descobrir tecnologias (ex: Postgres, Next.js, Playwright).
     - **Mudança de Fase/Domínio**: Ao transitar de arquitetura para UI/UX ou segurança.
     - **Erros e Regressões**: Ativação espontânea de `systematic-debugging` ou `diagnosing-bugs`.
     - **Portões de Verificação**: Ativação de `verification-before-completion` antes de declarar sucesso.
5. **Progressive Disclosure Sem Teto Artificial**:
   - Carrega as Skills pertinentes no momento exato via `view_file` no `SKILL.md`, sem limites numéricos arbitrários (0, 1 ou múltiplas complementares) e sem sobrecarga em tarefas triviais.

---

## 4. Novos Projetos Futuros

Após a instalação global, a abertura de qualquer novo workspace no Antigravity IDE **não exige reinstalação de Skills**. O Antigravity reconhecerá imediatamente todo o catálogo global.

Para governança contextual em um novo projeto:
1. Abra o novo repositório no Antigravity IDE.
2. Copie e cole [`docs/PRIMEIRO-PROMPT.md`](docs/PRIMEIRO-PROMPT.md) no chat.
3. O agente fará o inventário Fase 0 (read-only) e sugerirá as capabilities declarativas em `.aidev.json`.

---

## 5. Princípios Arquiteturais da v2.1

A **Architecture v2.1** opera como um framework orientado a capacidades atômicas e declarativas:

```text
Registry (registry/capabilities.json)
    ↓
descreve componentes, rules, skills, agents e MCPs atômicos disponíveis

Detection (aidev detect)
    ↓
observa fatos estruturais do repositório (read-only, nunca força política)

Project Manifest (.aidev.json)
    ↓
declara a intenção aprovada e versionada pelo desenvolvedor

Resolver (aidev resolve)
    ↓
resolve o grafo determinístico (dependências, ciclos, conflitos, proveniência)

Adapters / Materializer (aidev apply)
    ↓
materializa a configuração isolada (.agents/) para cada runtime de IA
```

### O que compõe a v2.1:
- **Project Manifest (`.aidev.json`)**: Intenção do projeto declarada em manifesto versionado, validado contra schema JSON Draft-07 (`schemas/aidev-manifest.schema.json`).
- **Capabilities Composáveis (`registry/capabilities.json`)**: 16 capabilities atômicas combináveis (`core`, `typescript`, `dotnet`, `python`, `react`, `nextjs`, `nestjs`, `postgres`, `supabase`, `sqlite`, `electron`, `windows-desktop`, `browser-testing`, `security-audit`, `hardware-qa`).
- **Profiles como Presets**: Perfis (`base`, `web-supabase`, `windows-desktop`, `monorepo`) atuam como atalhos para composição de capabilities.
- **Três Estados Epistemológicos**: Distinção clara entre **Detected** (fatos observados), **Inferred** (sugestões) e **Declared** (política aprovada no manifesto).
- **Validation Gates Genéricos**: Suporte declarativo para validações automatizadas (`automated`), condicionais (`onFiles`), humanas (`human`) e de hardware (`hardware` — nunca auto-aprovadas pela máquina).
- **3-Way Reconciliation Audit (`aidev audit`)**: Auditoria contínua comparando Realidade Detectada vs Manifesto Declarado vs Estado Materializado.

---

## 6. CLI `aidev` (Lifecycle de Comandos)

A CLI `aidev.ps1` orquestra o ciclo de vida completo:

### Comandos de Inspeção (Read-Only)
```powershell
# Diagnóstico completo de 6 pontos (ferramentas, schemas, storage global, runtimes, tokens)
.\aidev.ps1 doctor [caminho]

# Detecção de fatos estruturais e sugestão de manifesto (read-only)
.\aidev.ps1 detect [caminho]

# Validar .aidev.json contra schema v1 e grafo de capabilities
.\aidev.ps1 manifest validate [caminho]

# Exibir conteúdo do manifesto .aidev.json
.\aidev.ps1 manifest show [caminho]

# Listar todas as capabilities disponíveis no catálogo
.\aidev.ps1 capability list

# Inspecionar detalhes, regras, skills e agentes de uma capability
.\aidev.ps1 capability show <id>

# Resolver configuração efetiva, proveniência e validation gates
.\aidev.ps1 resolve [caminho]

# Auditoria de reconciliação de 3 vias (Detected vs Declared vs Materialized)
.\aidev.ps1 audit [caminho]

# Listar categorias do registry canônico (skills, agents, mcps, plugins, profiles, capabilities)
.\aidev.ps1 list [categoria]
```

### Comandos de Materialização & Modificação (Write / Mutative)
```powershell
# Inicializar apenas o manifesto .aidev.json (sem materializar)
.\aidev.ps1 manifest init [caminho] [-Preset base]

# Adicionar capability atômica ao .aidev.json
.\aidev.ps1 capability add <id> [caminho]

# Remover capability do .aidev.json
.\aidev.ps1 capability remove <id> [caminho]

# Inicializar novo projeto (cria .aidev.json e executa apply)
.\aidev.ps1 init [caminho] [-Preset web-supabase]

# Materializar explicitamente o .aidev.json em .agents/ e arquivos de governança
.\aidev.ps1 apply [caminho] [-DryRun] [-Force]

# Adotar projeto existente com backup automático e rollback em caso de falha
.\aidev.ps1 migrate [caminho] [-DryRun] [-AutoApprove]

# Podar regras gerenciadas obsoletas e links órfãos preservando arquivos locais
.\aidev.ps1 clean [caminho] [-DryRun]

# Sincronizar biblioteca global canônica em %USERPROFILE%\.agents
.\aidev.ps1 sync [-Update] [-DryRun]

# Executar suíte completa de testes automatizados
.\aidev.ps1 test
```

---

## 7. Estrutura Canônica de um Projeto v2.1

```text
meu-projeto/
├── .aidev.json                # Manifesto declarativo versionado (Intenção Aprovada)
├── AGENTS.md                  # Constituição enxuta derivada com invariantes e comandos
├── GEMINI.md                  # Bridge nativo para Antigravity / Gemini
├── .agents/                   # Diretório físico ISOLADO (ignorado pelo git)
│   ├── .aidev_metadata.json   # Estado materializado e tracking de proveniência
│   ├── rules/                 # Regras contextuais (managed + local/external)
│   ├── skills/                # Links individuais para skills das capabilities ativas
│   ├── agents/                # Especialistas cognitivos e de domínio
│   ├── hooks.json             # Hooks determinísticos de segurança pré-execução
│   ├── scripts/               # Scripts de checagem determinística (safety-check)
│   └── mcp_config.json        # MCPs habilitados de acordo com as capabilities
└── src/                       # Código-fonte da aplicação
```

---

## 8. Segurança e Invariantes

- **Proteção contra Path Traversal**: Validação estrita garante que `projectRules` e caminhos declarados residem dentro dos limites do workspace.
- **Isolamento Completo**: Zero poluição de contexto ou cruzamento entre projetos diferentes.
- **Transações e Rollback**: Falhas durante migrações disparam restauração atômica do estado original a partir de backups dedicados.
- **Preservação de Propriedade Local**: Arquivos e regras locais nunca são sobrescritos ou deletados pelas rotinas de automação.
