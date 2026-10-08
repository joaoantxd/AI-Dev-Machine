# AI-Dev-Machine — Architecture v2.1

> **Capability-Driven Framework & Multi-Agent Governance Platform**
> Um kit determinístico, genérico e portátil para configurar, auditar e materializar ambientes e projetos de desenvolvimento de software assistidos por IA no Windows, nativamente compatível com Google Antigravity, OpenAI Codex, Claude Code e Gemini CLI.
>
> 🎯 **Prompt-Mestre Universal**: [docs/PROMPT-MESTRE-CHATGPT.md](docs/PROMPT-MESTRE-CHATGPT.md) — Engenheiro universal de prompts para qualquer IA ou domínio.
> 🤖 **Instruções Globais ChatGPT**: [docs/CHATGPT-INSTRUCOES-GLOBAIS.md](docs/CHATGPT-INSTRUCOES-GLOBAIS.md) — Configuração persistente para a conta do ChatGPT.
> 🚀 **Primeiro Prompt Antigravity**: [docs/PRIMEIRO-PROMPT.md](docs/PRIMEIRO-PROMPT.md) — Fase 0 de inventário e organização do workspace (read-only).
> 🧠 **Segundo Cérebro (Obsidian)**: Hub operacional de decisões, arquitetura e handoffs entre agentes.

---

## 1. Prompts Prontos para Uso (`Ctrl+A → Ctrl+C → Ctrl+V`)

Os arquivos de prompts na pasta `docs/` contêm **exclusivamente o texto final a ser enviado**, sem introduções, explicações ou blocos de código markdown delimitadores. Basta abrir o arquivo, selecionar tudo (`Ctrl+A`), copiar (`Ctrl+C`) e colar (`Ctrl+V`) diretamente no destino:

| Documento | Destino de Aplicação | Função Principal |
| :--- | :--- | :--- |
| **[`docs/CHATGPT-INSTRUCOES-GLOBAIS.md`](docs/CHATGPT-INSTRUCOES-GLOBAIS.md)** | **ChatGPT** → *Configurações* → *Personalizar ChatGPT* → Campo *"Como você gostaria que o ChatGPT respondesse?"* | Transforma o ChatGPT de forma permanente em um **Engenheiro Universal de Prompts**, com especialização em software (AI-Dev-Machine e Antigravity) para todas as conversas da conta. |
| **[`docs/PROMPT-MESTRE-CHATGPT.md`](docs/PROMPT-MESTRE-CHATGPT.md)** | Primeira mensagem de uma nova conversa no **ChatGPT**, **Claude**, **Gemini**, ou instruções de um **Custom GPT / Projeto**. | Ativa a atuação de **Arquiteto de Instruções e Engenheiro de Prompts de Elite** para qualquer modelo, ferramenta, mídia (imagem, vídeo, áudio, código) ou finalidade. |
| **[`docs/PRIMEIRO-PROMPT.md`](docs/PRIMEIRO-PROMPT.md)** | Painel de chat do **Google Antigravity IDE** ao abrir qualquer workspace novo ou existente. | Executa a **Fase 0: Inventário, Compreensão e Organização** em modo estritamente *somente leitura*, mapeando a estrutura e governança antes de qualquer código. |

### Fluxo Operacional Integrado

```text
1. Abertura do Workspace no Antigravity
   └── Copie e cole docs/PRIMEIRO-PROMPT.md no chat do Antigravity.
   └── O Antigravity gera o inventário factual (read-only) do ambiente.

2. Engenharia e Arquitetura de Prompts no ChatGPT
   └── O ChatGPT (configurado via docs/CHATGPT-INSTRUCOES-GLOBAIS.md ou docs/PROMPT-MESTRE-CHATGPT.md)
       consome o inventário e concebe prompts técnicos cirúrgicos com escopo delimitado.

3. Execução Controlada no Antigravity
   └── O Antigravity executa a implementação sob as regras do AI-Dev-Machine v2.1 (.aidev.json, capabilities e gates).

4. Continuidade e Segundo Cérebro (Obsidian)
   └── Decisões arquiteturais (ADRs), status de sprint e handoffs são documentados para sessões futuras.
```

---

## 2. Princípios Arquiteturais da v2.1

A **Architecture v2.1** evolui o modelo anterior para um framework orientado a capacidades atômicas e declarativas, separando claramente:

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

### O que mudou na v2.1:
- **Project Manifest (`.aidev.json`)**: Intenção do projeto declarada em manifesto versionado, validado contra schema JSON Draft-07 (`schemas/aidev-manifest.schema.json`).
- **Capabilities Composáveis (`registry/capabilities.json`)**: 16 capabilities atômicas combináveis (`core`, `typescript`, `dotnet`, `python`, `react`, `nextjs`, `nestjs`, `postgres`, `supabase`, `sqlite`, `electron`, `windows-desktop`, `browser-testing`, `security-audit`, `hardware-qa`).
- **Profiles como Presets**: Perfis (`base`, `web-supabase`, `windows-desktop`, `monorepo`) atuam como atalhos para composição de capabilities.
- **Três Estados Epistemológicos**: Distinção clara entre **Detected** (fatos observados), **Inferred** (sugestões) e **Declared** (política aprovada no manifesto).
- **Validation Gates Genéricos**: Suporte declarativo para validações automatizadas (`automated`), condicionais (`onFiles`), humanas (`human`) e de hardware (`hardware` — nunca auto-aprovadas pela máquina).
- **3-Way Reconciliation Audit (`aidev audit`)**: Auditoria contínua comparando Realidade Detectada vs Manifesto Declarado vs Estado Materializado.
- **Extensibilidade Sem Core Changes**: Adicionar novas tecnologias exige apenas entrada JSON e templates — zero alterações no engine PowerShell.

---

## 3. CLI `aidev` (Lifecycle de Comandos)

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

## 4. Estrutura Canônica de um Projeto v2.1

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

## 5. Project Manifest (`.aidev.json`)

Exemplo de manifesto para um projeto fullstack:

```json
{
  "$schema": "./schemas/aidev-manifest.schema.json",
  "schemaVersion": 1,
  "preset": "web-supabase",
  "capabilities": [
    "core",
    "monorepo",
    "typescript",
    "react",
    "nextjs",
    "postgres",
    "supabase",
    "browser-testing"
  ],
  "projectRules": [
    ".agents/rules/local-business-rules.md"
  ],
  "validationGates": {
    "commands": {
      "dev": "pnpm dev",
      "build": "pnpm build",
      "test": "pnpm test",
      "typecheck": "pnpm typecheck",
      "lint": "pnpm lint",
      "e2e": "pnpm test:e2e"
    },
    "automated": [
      {
        "id": "api-tests",
        "description": "Executar testes de API",
        "command": "pnpm",
        "args": ["test", "--filter", "@app/api"],
        "cwd": "apps/api"
      }
    ],
    "human": [
      {
        "id": "visual-acceptance",
        "description": "Aprovação visual de UI antes do release",
        "requiredFor": ["release"]
      }
    ],
    "hardware": [
      {
        "id": "multi-monitor-qa",
        "description": "Verificação física em setup multi-monitor",
        "requiredFor": ["release"],
        "checklist": ["Verificar DPI scaling", "Verificar captura HDMI"]
      }
    ]
  }
}
```

---

## 6. Validation Gates & Regras Human/Hardware

- **Automated Gates**: Comandos estruturados com `command`, `args` e `cwd` evitando cascas de shell opacas.
- **Conditional Gates**: Execução vinculada a padrões de arquivos alterados (`onFiles`).
- **Human Gates**: Checkpoints mandatórios de validação humana (a máquina **nunca** auto-aprova).
- **Hardware Gates**: Especialização declarativa de checkpoint físico/ambiente que exige evidência humana direta.

---

## 7. Segurança e Invariantes

- **Proteção contra Path Traversal**: Validação estrita garante que `projectRules` e caminhos declarados residem dentro dos limites do workspace.
- **Isolamento Completo**: Zero poluição de contexto ou cruzamento entre projetos diferentes.
- **Transações e Rollback**: Falhas durante migrações disparam restauração atômica do estado original a partir de backups dedicados.
- **Preservação de Propriedade Local**: Arquivos e regras locais nunca são sobrescritos ou deletados pelas rotinas de automação.
