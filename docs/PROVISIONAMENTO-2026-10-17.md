# Governança dos projetos — 17/10/2026

## Escopo autorizado

Configurados o workspace `D:\Desktop\nexus ai`, seus repositórios `backend-nexusai` e `Nexus-AI-Sports`, e `%USERPROFILE%\Desktop\JJ Elite Sports Site`. Jadu foi excluído do escopo: sua pasta não foi apagada nem provisionada.

O script `scripts/configure-current-projects.ps1` registra os quatro caminhos desta máquina; não é um instalador genérico para outros usuários. Ele faz detect, backup das constituições e manifesto existentes, dry-run, apply sem Force, atualização local do Graphify, audit, doctor e contagem dos catálogos.

O motor utilizado e atualizado nesta entrega está em `D:\Desktop\AI DEV SKILLS`. Há também uma cópia cadastrada no aplicativo em `%USERPROFILE%\Desktop\AI DEV SKILLS`; ela não foi usada nem alterada. Utilize a cópia de D: nos próximos sync/apply para manter as correções desta entrega.

## Evidência inicial de execução

Execução real do script encerrou com código 0. Todos os quatro destinos apresentaram:

| Validação | Resultado por destino |
| --- | --- |
| Skills físicas com SKILL.md | 33, sem junctions |
| Especialistas canônicos | 10 |
| Adaptadores Codex `.codex/agents/*.toml` | 10 |
| Adaptadores Claude `.claude/agents/*.md` | 10 |
| `Migration/Sync Needed` no audit | False |
| Graphify `graph.json` | Presente e parseável |
| doctor | Executado, incluindo as limitações abaixo |

Stacks detectadas: Nexus workspace e frontend com TypeScript/React/Supabase; backend com TypeScript/Supabase; JJ Elite com TypeScript/React/Next.js/Supabase e testes de browser. Dependências transitivas de capabilities incluem PostgreSQL.

O Graphify 0.9.92 foi executado com análise de código local e clustering sem rotulação por LLM. O extra SQL oficial foi instalado via `python -m pip install --user --only-binary=:all: 'graphifyy[sql]==0.9.92'`, que instalou `tree-sitter-sql` 0.3.11. Arquivos SQL sem símbolos modeláveis podem continuar sem nós, mesmo com o parser instalado; um grafo não substitui a conferência do código-fonte.

## Preservação

Antes do provisionamento dos repositórios de aplicativos, `git status --short` estava limpo; a pasta Nexus pai não é um repositório Git. Nenhum fonte de aplicativo foi alterado por esta instalação. As alterações observadas são governança, `.gitignore` e artefatos Graphify.

Backups de constituições e configurações existentes:

- Nexus pai: `.aidev_backup_20261017_124006_620`.
- Backend: `.aidev_backup_20261017_124100_190`.
- Nexus Sports: `.aidev_backup_20261017_124132_772`.
- JJ Elite: `.aidev_backup_20261017_124156_410`.

O conteúdo original integral de AGENTS.md do JJ Elite foi confirmado presente após a injeção da ponte de governança, comparando com seu backup (`originalAgentsPreserved=True`). Não foi usado Force. O refresh Graphify removeu sete arquivos de cache AST antigos rastreados (`v0.9.53-s2`) do Nexus Sports; são cache regenerável e recuperável pelo histórico Git. Os demais artefatos do grafo foram atualizados.

## Multi-IA e orquestração

A regra `.agents/rules/orchestration.md` orienta o agente principal a coordenar, delegar, conferir evidências e responder. Os especialistas fazem implementação, investigação extensa, testes e revisão. O principal continua responsável por conferir as evidências; não deve apenas aceitar alegações de sucesso.

As IAs compartilham arquivos, regras e grafos locais, não conversas privadas nem observação automática de sessões alheias. Cada sessão precisa ler as instruções atuais e consultar o estado Git; mapas precisam ser atualizados depois de alterações.

As definições podem ser criadas durante o desenvolvimento e materializadas novamente com `aidev apply`. Descoberta imediata depende do cliente; numa sessão já aberta, passe explicitamente as instruções do especialista e recarregue o projeto quando necessário.

Teste real: `codex-cli 0.163.0-alpha.10.2`, autenticação ChatGPT, `codex exec -C <backend> --sandbox read-only --json`. A sessão `01a14a86-87fa-75f0-bf78-97578541e054` encerrou com código 0 e confirmou exatamente um researcher real, 33 skills físicas e 10 definições TOML. Nesta sessão principal também foram usados subagentes reais de pesquisa, DevOps e revisão. A primeira execução detectou um erro YAML na descrição do Graphify, encaminhado para correção no gerador antes da validação final.

Após corrigir o gerador de descrições YAML e sincronizar a biblioteca, o teste foi repetido na sessão `01a14a8b-26d7-7452-9e8b-024a6a9cb12c`: código 0, sem erro `invalid YAML` no startup, novamente exatamente um researcher real e contagens 33/10. Os corpos das skills existentes foram preservados durante a correção das descrições, com backup da versão anterior. O reparo permanente das descrições cabe ao motor Apply; não depende de Force nem de um patch manual recorrente.

Foi validada a instalação compartilhada do Graphify com `APPDATA` e `PYTHONUSERBASE` apontando às pastas comuns de usuário, sem redirecionamento específico do aplicativo: ambos os módulos `graphify` e `tree_sitter_sql` importaram de `%USERPROFILE%\AppData\Roaming\Python\Python314\site-packages`, e o `graphify.exe --help` correspondente retornou código 0. O PATH de usuário contém `%USERPROFILE%\AppData\Roaming\Python\Python314\Scripts`. Clientes já abertos podem precisar reiniciar para receber essa atualização de PATH.

Claude e Antigravity receberam adaptadores/instruções próprios. Arquivos presentes não provam que o runtime registrou agentes ou expôs ferramentas. A execução nativa de subagentes desses dois clientes ainda exige validação no respectivo cliente; não foi simulada nem declarada testada aqui. Também não foram alterados modelos, permissões ou configurações de conta para forçar delegação.

Referências de runtime: [Codex](https://learn.chatgpt.com/docs/agent-configuration/subagents), [Claude Code](https://code.claude.com/docs/en/sub-agents), [Antigravity](https://www.antigravity.google/docs/subagents/).

## Conferência final

Após o hotfix permanente do motor Apply para descrições geradas antigas, foi executado Apply novamente nos cinco workspaces (motor + quatro destinos), em processo novo e sem Force. A conferência final retornou código 0: todos com 33 skills físicas, 10 canônicos, 10 TOML Codex, 10 Markdown Claude, audit `MigrationNeeded=False` e descrição Graphify válida como escalar JSON/YAML. `git diff --check` retornou código 0; os avisos LF/CRLF do Git não são erros de whitespace. Doctor foi executado nos cinco destinos, com as limitações de ferramentas opcionais explicitadas abaixo.

O orquestrador principal repetiu independentemente `Invoke-AidevAudit`, as contagens e a presença dos grafos nos cinco workspaces, em processo novo: todos `False/33/10/10/graph=True`, código 0, e `git diff --check` código 0. Essa segunda camada verificou a instalação efetiva em disco, além dos relatos dos especialistas.

Validação final do motor: suíte principal **45/45 PASSED, 0 Failed**, código 0 (sessão de execução `39919`; log em `%USERPROFILE%\AppData\Local\Temp\aidev-researcher-tests-final45.log`). A regressão inclui reparo da descrição Graphify sem Force, backup exato, preservação do corpo e campos customizados, preservação de descrições YAML block-scalar e idempotência. O teste separado de frontmatter validou **14 descrições YAML**, código 0. A revisão independente aprovou o gerador e o reparo permanente, e confirmou a retirada do workaround temporário do script de provisionamento.

Mapas finais consultados após suporte SQL: Nexus pai 2.388 nós/3.603 relações; backend 680/815; Nexus Sports 1.326/2.554; JJ Elite 1.795/3.157. O mapa do motor também foi atualizado localmente após as mudanças de código.

## Limitações observadas

### Revisão de paridade Antigravity antes da publicação

Revisada a descoberta automática conforme a [documentação de regras](https://www.antigravity.google/docs/rules) e de [subagentes](https://www.antigravity.google/docs/subagents/). As regras locais usam `trigger` válido. Os dez especialistas e os especialistas sintetizados agora declaram `subagent: true`, `mainAgent: false` e `model: inherit`. Os geradores usam somente nomes de ferramentas documentados: `view_file`, `grep_search`, `run_command` e, nos escritores, `replace_file_content`. Ferramentas não verificadas foram retiradas do allowlist, pois nomes desconhecidos podem travar a execução no cliente. O shell segue sujeito às permissões e às instruções de cada tarefa; allowlists não são um sandbox de segurança.

As instruções deixam de presumir parâmetros `TypeName`/`Prompt` e usam o esquema nativo exposto pela sessão. Uma seção explícita em GEMINI.md preserva regras preexistentes e corrige afirmações antigas sobre registro, hooks e MCP. O principal continua coordenador, com parada para orientação se não houver delegação nativa. As correções foram propagadas ao motor e aos quatro destinos sem alterar fontes dos aplicativos. A execução real dentro do Antigravity continua pendente; esta revisão comprova configuração, não runtime.

Também foi corrigida a serialização dos adaptadores para que PowerShell 5.1 e 7 produzam o mesmo escape JSON/YAML/TOML de caracteres HTML. Isso elimina falsos positivos de drift ao executar Apply em uma versão e Audit na outra. Há regressão executando ambos os runtimes instalados e conferindo aspas, caminhos e caracteres de controle.

Na revisão independente, todos os caracteres ASCII 0–127 (incluindo DEL), U+2028/U+2029, acentos e emoji produziram saída idêntica nos dois runtimes, com roundtrip JSON e TOML validado. Os dez TOMLs reais também foram parseados. O gerador remove whitespace final apenas das cópias nativas geradas, sem alterar os especialistas canônicos.

Gate final de publicação: **46/46 testes aprovados, 0 falhas**, **14 descrições YAML aprovadas**, códigos 0. Auditorias dos cinco destinos `MigrationNeeded=False`; `git diff --cached --check` código 0. Revisão independente aprovada. O teste adicional cobre equivalência de serialização nos dois runtimes instalados.

Doctor não encontrou `uv`, `jq`, Semgrep, Playwright CLI global ou WinApp CLI no PATH. São ferramentas adicionais e não impedem a instalação dos catálogos; a presença de `@playwright/test` no projeto é distinta de uma CLI global.

Doctor indicou que variáveis de autenticação opcionais Supabase, GitHub e Vercel não estão definidas no processo. Isso não demonstra que conectores autenticados do aplicativo estejam desconectados; a configuração MCP portátil não comprova ativação no cliente. O teste Codex também registrou autenticação pendente no conector Higgsfield, que não fazia parte desta tarefa.

Builds e testes de negócio dos aplicativos não foram executados: os gates desta entrega verificam instalação e governança. Nenhum app foi iniciado nem publicado, e nenhum conteúdo `.env` foi lido.
