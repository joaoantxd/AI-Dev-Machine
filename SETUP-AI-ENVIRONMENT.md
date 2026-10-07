# Setup do Ambiente Global de Desenvolvimento com IA

Runbook para configuração e validação de uma máquina Windows utilizando a **AI-Dev-Machine Architecture v2**.

---

## 1. Pré-Requisitos na Máquina Nova

Instale manualmente antes de iniciar a automação:
1. **Git for Windows**: `winget install Git.Git --source winget`
2. **Editor / AI IDE**: Google Antigravity IDE, Claude Desktop ou ChatGPT Desktop / Codex.

---

## 2. Diagnóstico Inicial do Sistema

Clone ou copie este repositório (`AI-Dev-Machine`) e execute o diagnóstico somente leitura:

```powershell
powershell -ExecutionPolicy Bypass -File .\aidev.ps1 doctor
```

O comando inspeciona:
- Runtimes e gerenciadores de pacotes (Node.js, npm, pnpm, Python, uv);
- CLIs de desenvolvimento (git, gh, rg, jq, semgrep, playwright, winapp);
- Integridade dos registries canônicos em `registry/`;
- Biblioteca canônica global em `%USERPROFILE%\.agents`;
- Variáveis de autenticação de MCPs (sem expor valores).

---

## 3. Sincronização da Biblioteca Global

Sincronize as Skills e Especialistas canônicos a partir do registry:

```powershell
# 1. Simulação somente leitura (Dry-Run)
powershell -ExecutionPolicy Bypass -File .\aidev.ps1 sync -DryRun

# 2. Execução padrão (idempotente, sem rede se local estiver íntegro)
powershell -ExecutionPolicy Bypass -File .\aidev.ps1 sync

# 3. Atualização forçada a partir dos repositórios upstream
powershell -ExecutionPolicy Bypass -File .\aidev.ps1 sync -Update
```

A sincronização atualiza `%USERPROFILE%\.agents` e valida os pontos de descoberta para Antigravity (`~/.gemini/config/skills`), Codex (`~/.codex/skills`) e Claude (`~/.claude/agents`).

---

## 4. Validação Final com a Suíte de Testes

Execute os testes automatizados para certificar a integridade do ambiente:

```powershell
powershell -ExecutionPolicy Bypass -File .\aidev.ps1 test
```

---

## 5. Autenticação Interativa

Configure as variáveis de ambiente para os MCPs sob demanda que você pretende utilizar:
- `SUPABASE_ACCESS_TOKEN`
- `GITHUB_PERSONAL_ACCESS_TOKEN`
- `VERCEL_ACCESS_TOKEN`
- `CONTEXT7_API_KEY` (opcional)

Faça os logins interativos nos respectivos CLIs (`gh auth login`, `gemini login`, `claude login`).
