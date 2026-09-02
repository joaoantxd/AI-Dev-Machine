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

O diretório canônico é `%USERPROFILE%\.agents\skills`. Depois que Git estiver funcionando, no diretório deste repositório:

```powershell
.\install-skills.ps1 -DryRun
.\install-skills.ps1
```

Revise o dry-run antes da execução real. O script é a fonte canônica das 16 Skills gerenciadas; não instale cópias manuais diferentes. Skills externas ou desconhecidas devem permanecer intactas.

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

## MCPs

Configure somente no formato oficial atual de cada agente, fazendo backup e merge:

- Base: Context7 e Chrome DevTools.
- Next.js: Next DevTools disponível sob demanda.
- Sob demanda: Supabase MCP, GitHub MCP, Vercel MCP, Semgrep MCP, Playwright MCP e Graphify MCP.

Disponível sob demanda não significa sempre ativo. Não sobrescreva configurações inteiras e preserve MCPs externos.

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
