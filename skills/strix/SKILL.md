---
name: strix
description: >-
  Pentest autônomo com agentes de IA e ethical hacking via Strix (usestrix/strix).
  Use para executar testes de intrusão autônomos em aplicações web, APIs, repositórios e código-fonte,
  validando vulnerabilidades reais (OWASP Top 10, injeção, XSS, SSRF, IDOR, auth bypass)
  com provas de conceito executáveis (PoC) e relatórios estruturados (SARIF, JSON, Markdown).
license: Apache-2.0
metadata:
  author: usestrix
  homepage: https://docs.strix.ai
---

# Strix — Pentest Autônomo com IA & Ethical Hacking

A skill **`strix`** orienta a execução de testes de penetração autônomos utilizando o framework de agentes de segurança **Strix** ([usestrix/strix](https://github.com/usestrix/strix)). Ao contrário de scanners estáticos tradicionais que geram falsos positivos, o Strix age como um agente ofensivo (ethical hacker) que explora, valida e gera uma **Prova de Conceito (PoC)** real para cada vulnerabilidade confirmada.

---

## 1. Quando Ativar esta Skill (Triggers)

Ative esta skill sempre que a tarefa envolver:
- **Pentest / Ethical Hacking Autônomo**: Solicitações como "faça um pentest neste app", "hackeie esta rota", "teste invasão no backend" ou "encontre vulnerabilidades exploráveis".
- **Auditoria Dinâmica de Segurança (DAST + SAST ofensivo)**: Testar APIs REST, GraphQL, aplicações web ativas (staging/dev) ou repositórios locais.
- **Validação de Vulnerabilidades com PoC**: Confirmar se falhas de injeção (SQLi, NoSQLi), XSS, SSRF, RCE, IDOR/BOLA ou quebra de autenticação são realmente exploráveis antes de submeter código a produção.
- **Remediação e Re-teste**: Analisar relatórios do Strix, corrigir a causa raiz e re-executar o teste para comprovar a eficácia da correção com evidências reais.

---

## 2. Modos de Execução: Self-Hosted CLI vs Managed Cloud

O Strix oferece duas modalidades baseadas no mesmo motor:

| Modalidade | Quando Usar | Requisitos | Comando Base |
|---|---|---|---|
| **Open-Source CLI (Self-Hosted)** | Desenvolvimento local, privacidade total, ambientes air-gapped ou pipelines com Docker próprio. | Docker rodando + Chave de LLM (`STRIX_LLM`, `LLM_API_KEY`). | `strix -n -t <alvo> --max-budget 10` |
| **Managed Cloud (app.strix.ai)** | Sem Docker local, sem chave de LLM por token, relatórios compartilháveis em equipe ou integração CI rápida. | Conta / API token no app.strix.ai. | `strix cloud scan start --target <alvo>` |

---

## 3. Preparação do Ambiente

### Instalação da CLI
Caso ainda não esteja instalada no ambiente de trabalho:
```powershell
# Instalação via uv (recomendado no Windows)
uv tool install strix-agent

# Ou via pipx / pip
pipx install strix-agent
```

### Configuração de Provedor LLM (Modo Self-Hosted)
O Strix utiliza LiteLLM, suportando dezenas de provedores:
```powershell
# Exemplo com OpenAI
$env:STRIX_LLM = "openai/gpt-4o"
$env:LLM_API_KEY = "sk-..."

# Exemplo com Anthropic
$env:STRIX_LLM = "anthropic/claude-3-7-sonnet-latest"
$env:LLM_API_KEY = "sk-ant-..."

# Exemplo com Google Vertex / Gemini
$env:STRIX_LLM = "vertex_ai/gemini-2.5-pro"
```

---

## 4. Execução de Scans para Agentes de IA (Headless)

> ⚠️ **Regra Fundamental**:
> Agentes de IA **SEMPRE** devem utilizar a flag `-n` (`--non-interactive`). O modo interativo padrão abre uma interface TUI interativa que bloqueia o terminal do agente. Sempre estabeleça um teto de gastos com `--max-budget`.

### A. Teste White-Box em Repositório Local
Analisa o código-fonte local em busca de caminhos de ataque exploráveis:
```powershell
strix -n -t ./ --scan-mode standard --max-budget 10
```

### B. Teste Black-Box em Aplicação / API Ativa
Testa um endpoint de staging ou servidor local em execução:
```powershell
strix -n -t http://localhost:3000 --scan-mode quick --max-budget 5
```

### C. Teste Focado com Credenciais ou Escopo Específico
Forneça instruções semânticas para guiar o agente ofensivo:
```powershell
strix -n -t http://localhost:8000 `
  --instruction "Teste controle de acesso e IDOR entre usuarios comuns e admin nas rotas /api/v1/users e /api/v1/orders" `
  --max-budget 10
```

---

## 5. Artefatos de Saída e Interpretação de Resultados

Após o término da execução, o Strix gera artefatos estruturados no diretório `strix_runs/<run-name>/`:

- **`vulnerabilities.json`**: Lista completa e estruturada de vulnerabilidades validadas, severidade (Critical, High, Medium, Low) e detalhes técnicos.
- **`findings.sarif`**: Formato padrão SARIF 2.1.0, compatível com GitHub Advanced Security, SonarQube e scanners de CI/CD.
- **`vulnerabilities.csv`**: Tabela resumida para métricas rápidas.
- **PoC Scripts (Markdown/Python)**: Passos reproduzíveis e payloads reais que comprovaram a vulnerabilidade.

### Códigos de Retorno do CLI (`strix -n`):
- `0`: Scan concluído sem vulnerabilidades encontradas.
- `1`: Erro operacional ou falha de execução.
- `2`: Vulnerabilidades confirmadas encontradas no alvo.

---

## 6. Fluxo de Remediação Fechado (Verify-Before-Completion)

Ao atuar em correções apontadas pelo Strix:
1. **Localizar e Isolar**: Leia o arquivo `vulnerabilities.json` e examine o payload no relatório.
2. **Identificar a Causa Raiz**: Aplique o padrão `systematic-debugging` e `security-best-practices`.
3. **Corrigir com Minimalismo (`ponytail`)**: Implemente sanitização estrita, prepared statements, verificação de ownership em RLS/banco ou checagem de autorização na camada de serviço.
4. **Validar com Re-teste**: Execute novamente o Strix contra o alvo corrigido e confirme que o código de saída é `0` e nenhuma vulnerabilidade é mais explorável.
