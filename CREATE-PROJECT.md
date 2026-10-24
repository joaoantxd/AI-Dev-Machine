# Guia Rápido — Criação e Adoção de Projetos com IA

> **AI-Dev-Machine Architecture v2.1**
> Para os primeiros prompts prontos para copiar e colar diretamente no Antigravity IDE, consulte [docs/PRIMEIRO-PROMPT.md](docs/PRIMEIRO-PROMPT.md).

---

## 1. Entendimento do Software & Composição de Capabilities

O AI-Dev-Machine v2.1 é **capability-driven**: você pode escolher um preset conveniente como ponto de partida e adicionar capabilities atômicas (`core`, `typescript`, `python`, `react`, `nextjs`, `nestjs`, `postgres`, `supabase`, `sqlite`, `electron`, `windows-desktop`, `browser-testing`, `security-audit`, `hardware-qa`).

| Preset | Indicado Para | Capabilities Padrão |
|---|---|---|
| **`base`** | Projetos gerais, CLIs, bibliotecas e APIs enxutas | `core` |
| **`web-supabase`** | Aplicações Web fullstack modernas | `core`, `typescript`, `react`, `nextjs`, `postgres`, `supabase`, `browser-testing` |
| **`windows-desktop`** | Aplicações desktop nativas Windows | `core`, `typescript`, `electron`, `windows-desktop`, `hardware-qa` |
| **`monorepo`** | Monorepos multi-pacote modulares | `core`, `monorepo`, `typescript` |
| **`custom`** | Composição granular sob medida | Seleção explícita de capabilities |

---

## 2. Inicialização de um Novo Projeto (Greenfield)

Execute no terminal PowerShell:

```powershell
# 1. Inicializar com preset web-supabase
powershell -ExecutionPolicy Bypass -File .\aidev.ps1 init "c:\caminho\para\meu-app" -Preset web-supabase

# 2. Inicializar com preset windows-desktop
powershell -ExecutionPolicy Bypass -File .\aidev.ps1 init "c:\caminho\para\meu-desktop" -Preset windows-desktop

# 3. Inicializar com preset base
powershell -ExecutionPolicy Bypass -File .\aidev.ps1 init "c:\caminho\para\meu-projeto" -Preset base
```

---

## 3. Composição Granular de Capabilities

Você pode refinar o manifesto `.aidev.json` adicionando ou removendo capacidades a qualquer momento:

```powershell
# Inicializar manifesto vazio/base
powershell -ExecutionPolicy Bypass -File .\aidev.ps1 manifest init "c:\caminho\para\meu-projeto" -Preset base

# Adicionar capacidades adicionais
powershell -ExecutionPolicy Bypass -File .\aidev.ps1 capability add python "c:\caminho\para\meu-projeto"
powershell -ExecutionPolicy Bypass -File .\aidev.ps1 capability add sqlite "c:\caminho\para\meu-projeto"

# Materializar a governança isolada (.agents/)
powershell -ExecutionPolicy Bypass -File .\aidev.ps1 apply "c:\caminho\para\meu-projeto"
```

---

## 4. O que a CLI Scaffolda Automaticamente

- `.aidev.json`: Manifesto declarativo versionado com a intenção aprovada.
- `AGENTS.md`: Constituição universal enxuta de invariantes e comandos canônicos.
- `GEMINI.md`: Bridge nativo para Antigravity / Gemini CLI.
- `.agents/`: Diretório físico isolado com regras gerenciadas, especialistas cognitivos, hooks e MCPs.
- `.gitignore`: Atualizado para rastrear regras e agentes locais enquanto ignora links de skills e backups.

---

## 5. Próximos Passos no Novo Projeto

1. Abra o workspace no **Antigravity IDE**.
2. Personalize a seção `validationGates.commands` em `.aidev.json` e `Canonical Commands` em `AGENTS.md`.
3. Desenvolva com segurança através de **Progressive Disclosure**.
4. No primeiro trabalho no projeto, crie `doc/README.md` como índice de uma **memória técnica viva**. Se o repositório já possui `docs/`, reutilize essa pasta: não mantenha `doc/` e `docs/` concorrentes. Consulte e atualize as notas durante o desenvolvimento, especialmente após decisões, mudanças de arquitetura, validações relevantes e handoffs.
