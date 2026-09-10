# AI Dev Machine — Instruções Operacionais para Agentes (AGENTS.md)

Este documento define as diretrizes, arquitetura e convenções operacionais para agentes e assistentes de IA (Google Antigravity, OpenAI Codex, Claude Code, Gemini CLI, Cursor, Windsurf) trabalhando no repositório **AI-Dev-Machine**.

---

## 1. Visão Geral e Missão

O **AI-Dev-Machine** é um kit portátil e determinístico para configurar, reconstruir e manter um ambiente global de desenvolvimento assistido por IA no Windows, sem depender de instaladores proprietários opacos.

### Arquivos Centrais do Repositório:
- [`SETUP-AI-ENVIRONMENT.md`](file:///c:/Users/CONTABILIDADE/Documents/AI-Dev-Machine/SETUP-AI-ENVIRONMENT.md): Prompt universal e autocontido de bootstrapping da máquina (inventário, ferramentas, CLIs, MCPs e validação).
- [`CREATE-PROJECT.md`](file:///c:/Users/CONTABILIDADE/Documents/AI-Dev-Machine/CREATE-PROJECT.md): Prompt greenfield para criação de novos projetos com Progressive Disclosure.
- [`TEMPLATE-AGENTS.md`](file:///c:/Users/CONTABILIDADE/Documents/AI-Dev-Machine/TEMPLATE-AGENTS.md): Template universal padrão de `AGENTS.md` a ser adotado em todo novo projeto gerado.
- [`install-skills.ps1`](file:///c:/Users/CONTABILIDADE/Documents/AI-Dev-Machine/install-skills.ps1): Automação determinística e idempotente para sincronização das 16 Skills canônicas e orquestração de Directory Junctions multi-IA.
- [`README.md`](file:///c:/Users/CONTABILIDADE/Documents/AI-Dev-Machine/README.md): Documentação voltada para humanos.

---

## 2. Stack Tecnológica e Ferramentas

- **Linguagem de Automação**: PowerShell (compatível com Windows PowerShell 5.1 e PowerShell 7+).
- **Controle de Versão**: Git & GitHub CLI (`gh`).
- **Formato de Configuração**: JSON (padrão oficial Model Context Protocol).
- **Documentação Operacional**: Markdown estruturado.

---

## 3. Comandos Principais

```powershell
# Simulação somente leitura da validação de Skills
powershell -ExecutionPolicy Bypass -File .\install-skills.ps1 -DryRun

# Execução padrão idempotente (validação e junctions, sem rede se integro)
powershell -ExecutionPolicy Bypass -File .\install-skills.ps1

# Vincular Skills no workspace de um projeto alvo
powershell -ExecutionPolicy Bypass -File .\install-skills.ps1 -WorkspacePath "c:\caminho\do\projeto"

# Atualização explícita baixando upstream oficial
powershell -ExecutionPolicy Bypass -File .\install-skills.ps1 -Update

# Simulação da atualização upstream
powershell -ExecutionPolicy Bypass -File .\install-skills.ps1 -Update -DryRun
```

---

## 4. Regras Operacionais Estritas para Agentes

1. **Zero Caminhos Hardcoded**:
   - **NUNCA** use caminhos absolutos com nomes de usuário específicos (como `C:\Users\joao...` ou `C:\Users\CONTABILIDADE...`).
   - Use sempre `$env:USERPROFILE` (PowerShell) ou `%USERPROFILE%` (CMD/Docs).

2. **Idempotência e Preservação**:
   - Não remova configurações desconhecidas nem substitua arquivos existentes sem necessidade.
   - Qualquer modificação no `install-skills.ps1` deve preservar o comportamento de auto-reparo e preservação de skills externas (`[PRESERVE EXTERNAL]`).

3. **Interoperabilidade Multi-IA**:
   - As skills canônicas residem exclusivamente em `%USERPROFILE%\.agents\skills`.
   - Todas as integrações (Antigravity, Codex, Claude Code, Workspaces) devem utilizar Directory Junctions (`mklink /J`), evitando duplicação de dados.

4. **Higiene de Repositório**:
   - A pasta `.agents` no workspace é um link local (junction) e **deve permanecer no `.gitignore`**. Nunca faça commit de `.agents/`.
   - Mantenha scripts PowerShell sem warnings de linter (variáveis não utilizadas, boas práticas de cmdlet).

5. **Verificação Obrigatória Antes da Conclusão**:
   - Sempre valide execuções reais com PowerShell (`-DryRun` e execução padrão) antes de reportar conclusão ao usuário.
