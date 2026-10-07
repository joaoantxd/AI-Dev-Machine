# Guia Rápido — Criação de Novos Projetos com IA (Greenfield)

Este guia orienta o início de um novo projeto do zero utilizando a **AI-Dev-Machine Architecture v2**.

---

## 1. Entendimento do Produto (Diálogo Inicial)

Antes de criar código, converse com a IA para alinhar:
- **Problema & Proposta de Valor**: O que o produto resolve e para quem.
- **Plataforma & Stack**: Web, Desktop (Windows), API, Monorepo ou CLI.
- **Requisitos Críticos**: Autenticação, banco de dados, UI/UX, testes ou segurança.

---

## 2. Escolha do Profile Arquitetural

Selecione o profile mais adequado no registry:

| Profile | Indicado Para | Capacidades Habilitadas |
|---|---|---|
| **`base`** | Projetos gerais, CLIs, APIs enxutas e bibliotecas | Invariantes, Git workflow, Verification gate, debugging e YAGNI |
| **`web-supabase`** | Aplicações Web fullstack (Next.js, React, Supabase) | Web guidelines, Postgres/RLS, UI/UX craft, Playwright E2E |
| **`windows-desktop`** | Aplicações desktop Windows (WinUI 3, WPF, C#, Electron) | Windows guidelines, UI thread safety, WinApp CLI physical QA |
| **`monorepo`** | Módulos múltiplos e arquiteturas complexas | Modular architecture invariants, Domain modeling, refactoring |

---

## 3. Inicialização Automatizada com a CLI `aidev`

Execute no terminal PowerShell:

```powershell
# Exemplo 1: Inicializar um projeto web com Supabase
powershell -ExecutionPolicy Bypass -File .\aidev.ps1 init "c:\caminho\para\meu-app" -Profile web-supabase

# Exemplo 2: Inicializar um projeto desktop Windows
powershell -ExecutionPolicy Bypass -File .\aidev.ps1 init "c:\caminho\para\meu-desktop" -Profile windows-desktop

# Exemplo 3: Inicializar um projeto base
powershell -ExecutionPolicy Bypass -File .\aidev.ps1 init "c:\caminho\para\meu-projeto" -Profile base
```

---

## 4. O que a CLI Scaffolda Automaticamente

- `AGENTS.md`: Constituição enxuta de invariantes e comandos canônicos.
- `GEMINI.md`: Bridge nativo para Antigravity/Gemini CLI.
- `.agents/`: Diretório físico isolado com regras, agentes cognitivos, hooks e MCPs específicos do profile.
- `docs/`: Estrutura para ADRs, visão arquitetural e runbooks (carregados sob demanda).

---

## 5. Próximos Passos no Novo Projeto

1. Abra o novo projeto no seu editor / Antigravity IDE.
2. Personalize a seção `Canonical Commands` em `AGENTS.md` (instalação, dev, testes, build).
3. Desenvolva seguindo o princípio de **Progressive Disclosure**: consulte regras e invoque especialistas sob demanda.
