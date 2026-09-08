# Setup do ambiente de desenvolvimento com IA

Você está configurando uma máquina Windows nova para meu ambiente global de desenvolvimento com IA.

Execute o trabalho diretamente no computador usando terminal e ferramentas oficiais. Este documento é autocontido e não depende do histórico de outra conversa.

## Objetivo

1. Inventariar a máquina antes de modificar qualquer coisa.
2. Preservar programas, CLIs, Skills, MCPs, configurações e arquivos existentes.
3. Instalar somente dependências ausentes, usando documentação oficial atual.
4. Instalar os aplicativos desktop, CLIs e ferramentas de desenvolvimento listados abaixo.
5. Executar `install-skills.ps1` para sincronizar as 16 Skills gerenciadas.
6. Configurar MCPs compatíveis, como base ou sob demanda.
7. Validar cada item com seu comando real de versão/estado.
8. Deixar logins interativos para o usuário.

## Regras obrigatórias

- Não usar IA, LLM, prompts para outros agentes ou decisões automáticas por modelo.
- Não remover, desinstalar, substituir ou fazer prune de componentes existentes.
- Não apagar configurações desconhecidas. Faça backup e merge antes de modificar configurações.
- Não armazenar senhas, tokens ou chaves em arquivos.
- Consultar a documentação oficial atual quando o método, package ID ou formato de configuração estiver incerto.
- Usar somente fornecedor oficial, repositório oficial ou gerenciador confiável confirmado.
- Se uma etapa falhar, isole a falha, registre o comando/erro e continue somente quando for seguro.
- Não declarar sucesso sem uma verificação real.

## Inventário inicial

Verifique, sem modificar nada:

- versão e disponibilidade de PowerShell, Git e do gerenciador de pacotes oficial disponível;
- `PATH`, arquitetura do Windows e permissões atuais;
- aplicativos, CLIs e ferramentas já presentes;
- `%USERPROFILE%\.agents\skills` e configurações de agentes/MCP.

Preserve tudo que já estiver saudável. Ausência, autenticação pendente, erro de permissão e bloqueio de rede são estados diferentes.

## Aplicativos desktop

Verifique e instale somente quando ausentes:

- ChatGPT Desktop / experiência Codex disponível atualmente para Windows;
- Claude Desktop;
- Google Antigravity IDE.

Confirme o método Windows vigente na documentação oficial de cada fornecedor antes da instalação. Não automatize login.

## CLIs de IA

Garanta, com verificação real de versão:

- OpenAI Codex CLI;
- Claude Code;
- GitHub Copilot CLI;
- Gemini CLI;
- Google Antigravity CLI, quando suportado atualmente.

Detecte antes de instalar. Autenticação é separada e deve permanecer interativa.

## Ferramentas de desenvolvimento

Garanta, preservando versões saudáveis:

- Git;
- GitHub CLI (`gh`);
- Node.js LTS e npm;
- pnpm;
- Python e uv;
- ripgrep (`rg`);
- jq;
- ast-grep (`sg` quando aplicável);
- Playwright CLI;
- Graphify CLI;
- Semgrep;
- Trivy;
- Gitleaks.

Não atualize apenas porque existe uma versão mais nova. Se o gerenciador intermediário não estiver disponível, consulte a documentação oficial vigente e registre a limitação antes de escolher uma alternativa.

## Skills globais

O diretório canônico continua sendo `%USERPROFILE%\.agents\skills`. Depois que Git estiver funcionando, no diretório deste repositório:

```powershell
# Simulação somente leitura
.\install-skills.ps1 -DryRun

# Execução padrão idempotente (sem rede se as Skills já estiverem íntegras)
.\install-skills.ps1

# Atualização explícita com download de repositórios upstream
.\install-skills.ps1 -Update

# Simulação de atualização
.\install-skills.ps1 -Update -DryRun
```

### Comportamento do `install-skills.ps1`

- **Idempotência por padrão**: sem `-Update`, se a Skill existir e seu `SKILL.md` for válido, o script emite `[SKIP / PRESENT] <skill>` e não consome rede nem toca no disco.
- **Auto-reparo**: se a pasta existir mas estiver corrompida ou incompleta, o script executa `[REPAIR] <skill>`.
- **Instalação**: se a pasta estiver ausente, executa `[INSTALL] <skill>`.
- **Atualização explícita (`-Update`)**: aciona clonagem upstream em staging temporário, validação, backup, substituição atômica e rollback automático em caso de falha.
- **Preservação**: Skills externas ou manuais em `%USERPROFILE%\.agents\skills` são identificadas e preservadas intactas com `[PRESERVE EXTERNAL] <external-skill>`.
- **Interoperabilidade Multi-IA (Antigravity IDE, OpenAI Codex, Claude Code, Gemini CLI)**:
  - `%USERPROFILE%\.agents\skills`: fonte canônica física única das Skills do AI Dev Machine.
  - `~/.gemini/antigravity/skills` e `~/.gemini/config/skills`: caminhos de descoberta do Antigravity IDE e Gemini CLI.
  - `~/.codex/skills`: caminho de descoberta do OpenAI Codex e ChatGPT Desktop.
  - `~/.claude/skills`: caminho de descoberta do Claude Code e Claude Desktop.
  - O script cria e valida Directory Junctions individuais para todos os destinos de integração, garantindo que todas as IAs descubram as Skills sem duplicar arquivos físicos.
  - Não cria pastas intermediárias (ex.: `skills/gerenciadas/`).
  - Se a junction correta já existir: `[INTEGRATION / PRESENT] <skill>`.
  - Se a junction estiver ausente: cria e reporta `[INTEGRATION / LINK] <skill>`.
  - Se o destino já existir como pasta normal ou apontar para outro local: preserva e reporta `[INTEGRATION / CONFLICT / PRESERVED] <skill>`. Conflitos impedem status final de sucesso.
  - **Suporte a Workspace (`-WorkspacePath`)**: quando executado com `-WorkspacePath <caminho>`, cria a junction `.agents` dentro do diretório do projeto, permitindo leitura direta das skills dentro das fronteiras de segurança de qualquer IDE.

As Skills gerenciadas são:

| Skill | Repositório | Subpath/adapter |
|---|---|---|
| context-engineering | addyosmani/agent-skills | descoberta pelo nome |
| prompt-master | nidhinjs/prompt-master | descoberta pelo nome |
| systematic-debugging | obra/superpowers | descoberta pelo nome |
| verification-before-completion | obra/superpowers | `skills/verification-before-completion` |
| vercel-react-best-practices | vercel-labs/agent-skills | descoberta pelo nome |
| ui-ux-pro-max | nextlevelbuilder/ui-ux-pro-max-skill | descoberta pelo nome |
| frontend-design | anthropics/claude-code | `plugins/frontend-design/skills/frontend-design` |
| web-design-guidelines | vercel-labs/agent-skills | descoberta pelo nome |
| supabase | supabase/agent-skills | descoberta pelo nome |
| supabase-postgres-best-practices | supabase/agent-skills | descoberta pelo nome |
| security-best-practices | openai/skills | descoberta pelo nome |
| security-threat-model | openai/skills | descoberta pelo nome |
| finding-google-skills | google/skills | `skills/developers/finding-google-skills` |
| graphify | Graphify-Labs/graphify | adapter `graphify-agents` |
| playwright | openai/skills | `skills/.curated/playwright` |
| caveman | JuliusBrussee/caveman | descoberta pelo nome |

Para `graphify`, instalar somente `skill-agents.md` como `SKILL.md` e as referências da variante `agents`, quando existirem. Não executar hooks, MCP ou injeção always-on do Graphify. Para `finding-google-skills`, não instalar o catálogo Google inteiro. Para `caveman`, não instalar proxy, hooks ou serviço.

## MCPs no Google Antigravity IDE e Gemini CLI

### Descoberta e consumo de MCPs no Antigravity IDE

O Google Antigravity IDE consome MCPs através de três camadas de configuração:

1. **Configuração Global (compartilhada com Gemini CLI)**:
   - Caminho: `%USERPROFILE%\.gemini\config\mcp_config.json`
   - Formato padrão JSON:
     ```json
     {
       "mcpServers": {
         "<server-name>": {
           "command": "npx",
           "args": ["-y", "<package>", "..."],
           "env": { ... }
         }
       }
     }
     ```
   - Persistência pela UI: alterações feitas em *Additional Options > MCP Servers* ou via comandos de configuração persistem neste arquivo global.

2. **Integrações e Plugins Nativos do Antigravity**:
   - Caminho: `%USERPROFILE%\.gemini\config\plugins/<plugin-name>/` (ou integrações embutidas no IDE)
   - Recursos nativos do IDE e plugins podem expor ferramentas, suporte a browser/dev tools e agentes embutidos declarados em seus respectivos manifests.

3. **Configuração por Workspace**:
   - Caminho: `<workspace-root>/.agents/mcp_config.json`
   - Aplicável para MCPs específicos de tecnologia ou repositório (ex.: Next DevTools, Playwright local).

### Mapeamento dos MCPs do AI-Dev-Machine

| MCP | Tipo | Escopo Antigravity | Transporte | Pacote / Comando | Observações de Integração |
|---|---|---|---|---|---|
| **Context7** | Base | Global (`~/.gemini/config/mcp_config.json`) | stdio | `npx -y @upstash/context7-mcp@latest` | Documentação oficial de bibliotecas atualizadas. Funcional sem API key (rate-limited); chave opcional via variável `CONTEXT7_API_KEY`. |
| **Chrome DevTools** | Base | Integração nativa no Antigravity / Global | Nativo / stdio | Fluxo integrado no IDE / fallback oficial | Chrome DevTools possui integração/suporte nativo no fluxo de browser do Antigravity IDE. Se essa integração oficial estiver disponível e funcional, usar a integração existente e reportar `[MCP / PRESENT / SKIP] Chrome DevTools`, sem configurar um segundo Chrome DevTools MCP redundante. Caso a integração nativa não esteja disponível, consultar a documentação oficial atual e configurar o mecanismo recomendado, evitando duplicar tooling de browser. |
| **Next DevTools** | Next.js | Por workspace (`<workspace>/.agents/mcp_config.json`) | stdio | `npx -y @next/dev-tools-mcp` | Ativar sob demanda apenas em projetos Next.js. Não configurar globalmente para evitar overhead em projetos de outros frameworks. |
| **Supabase** | Sob demanda | Global / Workspace (desativado por padrão) | stdio | `npx -y @supabase/mcp-server-supabase@latest` | Requer credenciais (`SUPABASE_ACCESS_TOKEN`). Reportar `[MCP / AUTH PENDING]` até o usuário fornecer tokens. |
| **GitHub** | Sob demanda | Global / Workspace (desativado por padrão) | stdio | `npx -y @modelcontextprotocol/server-github` | Integração direta com API do GitHub. Recomendado usar `gh` CLI na linha de base e acionar o MCP somente para automações complexas. Requer `GITHUB_PERSONAL_ACCESS_TOKEN`. |
| **Vercel** | Sob demanda | Global / Workspace (desativado por padrão) | SSE / HTTP | `https://mcp.vercel.com` | Integração oficial Vercel MCP via `serverUrl`. Autenticação interativa via OAuth no navegador, sem necessidade de API key estática no JSON. |
| **Semgrep** | Sob demanda | Global / Workspace (desativado por padrão) | stdio | `semgrep mcp` | Análise estática profunda de segurança. O executável local `semgrep.exe` já fornece subcomando nativo `mcp` via stdio. |
| **Playwright** | Sob demanda | Por workspace (`<workspace>/.agents/mcp_config.json`) | stdio | `npx -y @anthropic/mcp-playwright` | Automação e navegação profunda para agentes. Na maioria dos fluxos, o `Playwright CLI` e a integração nativa de browser do Antigravity suprem as necessidades. |
| **Graphify** | Sob demanda | Por workspace (`<workspace>/.agents/mcp_config.json`) | stdio | `graphify mcp` | Análise gráfica de dependências e arquitetura de código. Configurar sob demanda apenas em repositórios complexos. |

### Regras de Idempotência e Segurança para MCPs

- **Preservação de configurações existentes**: nunca substituir arquivos de configuração inteiros. Sempre ler o JSON existente, fazer backup (`.bak`), realizar merge sob a chave `"mcpServers"` e gravar mantendo servidores não mapeados.
- **Detecção de MCP já presente**: se o servidor já estiver declarado em `mcp_config.json`, emitir `[MCP / PRESENT] <mcp>` e não sobrescrever.
- **Autenticação pendente**: se o MCP exigir credenciais obrigatórias que ainda não estão no ambiente, reportar `[MCP / AUTH PENDING] <mcp>`. Não falhar o setup global.
- **Progressive Disclosure**: manter MCPs sob demanda configurados mas inativos até serem solicitados pelo contexto da tarefa.

## Multi-agent e divulgação progressiva

Quando suportado, prepare Codex, Claude Code, GitHub Copilot, Gemini CLI e Google Antigravity usando suas configurações nativas e documentadas. Reutilize `%USERPROFILE%\.agents\skills` quando compatível; não crie cópias sem necessidade.

Carregue apenas o contexto relevante para cada tarefa:

```text
Código:   rg → ast-grep → leitura direcionada → Graphify quando necessário
Docs:     local/versionada → oficial → Context7
Browser:  Playwright CLI → Chrome DevTools para diagnóstico profundo
GitHub:   git → gh → GitHub MCP quando trouxer benefício
```

## Autenticação

Não faça login automaticamente e nunca grave credenciais. Relate separadamente qualquer `[AUTH REQUIRED]`; isso não é falha de instalação.

## Verificação e relatório

Valide cada componente com seu comando real e produza um relatório com:

- Desktop Apps: nome e status;
- AI CLIs: nome, versão e status;
- Development Tools: nome, versão e status;
- Skills: as 16 gerenciadas e as externas preservadas;
- MCPs: configurado, disponível sob demanda ou não suportado;
- Authentication: logins pendentes;
- Problems: limitações, erros, permissões ou bloqueios de rede.

Só use `AI DEVELOPMENT ENVIRONMENT READY` se todos os componentes obrigatórios tiverem sido realmente instalados/configurados e verificados.
