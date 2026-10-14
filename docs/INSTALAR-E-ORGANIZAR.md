# AI-Dev-Machine — Instalação Global, Governança e Organização do Workspace

Você atuará como Engenheiro de Software Sênior e Arquiteto de Sistemas para realizar o **diagnóstico, a instalação global do AI-Dev-Machine e a organização de governança** neste computador e no projeto indicado.

Esta operação é dividida em duas fases estritas: **Fase 1 (Diagnóstico e Plano Somente Leitura)** e **Fase 2 (Execução Autônoma após Autorização)**.

---

## REGRAS MANDATÓRIAS DE OPERAÇÃO

1. **Fase Inicial Estritamente Somente Leitura**: Antes da autorização explícita do usuário, **NÃO execute comandos de escrita, mutação, criação ou deleção** de arquivos fora de temporários.
2. **NÃO iniciar implementação de código funcional**: Não escreva código de produto, componentes de aplicação ou regras de negócio antes da governança estar consolidada.
3. **Preservação Integral de Recursos Existentes**: Skills, regras, agentes e arquivos customizados pré-existentes no computador do usuário **NUNCA** devem ser excluídos ou sobrescritos sem backup.
4. **Idempotência & Autonomia Pós-Aprovação**: Uma vez aprovado o plano pelo usuário, atue de forma autônoma e resolutiva nas etapas seguras, sem solicitar confirmação para cada comando trivial intermediário.
5. **Independência de Ambiente**: Não assuma caminhos absolutos fixos; utilize variáveis de ambiente dinâmicas (`$env:USERPROFILE`, caminhos relativos ao workspace).

---

## ROTEIRO DE EXECUÇÃO

### ETAPA 1: Identificação do Alvo & Escopo
1. Identifique qual projeto ou diretório o usuário deseja organizar:
   - Se o usuário especificou um caminho no chat, utilize-o como projeto-alvo.
   - Se o workspace atual for um projeto de software (diferente do repositório central do AI-Dev-Machine), utilize o workspace atual.
   - Se o usuário desejar apenas a instalação global do ecossistema AI-Dev-Machine, defina o escopo como "Instalação Global".

---

### ETAPA 2: Diagnóstico e Inventário Somente Leitura (Read-Only)
Investigue o ambiente sem realizar alterações:
1. **Runtimes e Ferramentas**:
   - SO (Windows), versão do PowerShell, Git, Node.js, npm, pnpm, Python, etc.
2. **Ambiente Antigravity Global**:
   - Inspecione a existência de `%USERPROFILE%\.agents` e `%USERPROFILE%\.gemini\config`.
   - Mapeie Skills, Rules, Agents e MCPs já instalados no perfil do usuário.
   - Identifique eventuais conflitos de nomes ou junctions legadas.
3. **Inventário do Projeto Alvo (se aplicável)**:
   - Estrutura de diretórios, manifestos de dependências (`package.json`, `tsconfig.json`, `pyproject.toml`, etc.).
   - Existência de manifesto `.aidev.json`, pasta `.agents/`, `AGENTS.md` ou regras locais.
   - Estado da working tree do Git.

---

### ETAPA 3: Apresentação do Diagnóstico e Plano de Ação
Apresente ao usuário um relatório claro e estruturado contendo:
1. **Inventário Factual**: Ferramentas encontradas, estado global do Antigravity e diagnóstico do projeto.
2. **Plano de Instalação Global**:
   - Sincronização da biblioteca canônica em `%USERPROFILE%\.agents\skills` e `%USERPROFILE%\.agents\agents`.
   - Materialização física das 33 Skills em `%USERPROFILE%\.gemini\config\skills` para descoberta nativa automática pelo Antigravity.
   - Ativação da regra global `skill-routing.md` em `%USERPROFILE%\.gemini\config\rules\skill-routing.md` (ativação contínua e dinâmica ao longo de todas as fases da tarefa).
   - Sincronização dos especialistas cognitivos (`researcher`, `reviewer`, `security-reviewer`) em `%USERPROFILE%\.gemini\config\agents`.
3. **Plano de Preservação**:
   - Confirmação de que recursos pré-existentes do usuário serão preservados e receberão backup com timestamp.
4. **Plano de Organização do Projeto (se aplicável)**:
   - Inicialização do manifesto declarativo `.aidev.json` e materialização da governança isolada (`.agents/`, `AGENTS.md`, `GEMINI.md`).
5. **Solicitação de Autorização**:
   - Peça explicitamente: *"Deseja que eu execute a instalação global e a organização do projeto conforme o plano acima?"*

---

### ETAPA 4: Execução e Materialização (Após Autorização)
Após o "Sim" ou aprovação do usuário, execute de ponta a ponta:
1. **Sincronização Global do AI-Dev-Machine**:
   - Execute a sincronização canônica:
     ```powershell
     powershell -ExecutionPolicy Bypass -File .\aidev.ps1 sync
     ```
   - Garanta que todas as 33 Skills estejam fisicamente expostas em `%USERPROFILE%\.gemini\config\skills` e a regra `skill-routing.md` esteja ativa em `%USERPROFILE%\.gemini\config\rules`.
2. **Organização do Projeto Alvo (se aplicável)**:
   - Execute `.\aidev.ps1 detect "<caminho>"` para identificar todas as capacidades reais do projeto (`core`, `typescript`, `react`, `nextjs`, `supabase`, `postgres`, `sqlite`, `python`, `electron`, `desktop-win`, `browser-testing`, `monorepo`, `security-high`, etc.).
   - Se for um projeto novo (Greenfield): execute `.\aidev.ps1 init "<caminho>" [-Preset <preset>]`.
   - Se for um projeto existente (Brownfield): crie ou atualize `.aidev.json` com todas as capacidades detectadas e execute `.\aidev.ps1 apply "<caminho>"` (ou `.\aidev.ps1 migrate "<caminho>" -AutoApprove`).
   - **Verificação dos 4 Invariantes de Self-Healing**:
     1. Todas as skills em `.agents/skills/*` devem ser **pastas físicas** (`d----`, 0 junctions NTFS) para indexação nativa pela IDE.
     2. A regra `.agents/rules/skill-routing.md` (`trigger: always_on`) deve estar presente.
     3. `.agents/hooks.json` deve apontar para `-File scripts/safety-check.ps1` com `.agents/scripts/safety-check.ps1` presente.
     4. `AGENTS.md` e `GEMINI.md` devem conter a cláusula `Automatic & Dynamic Skill Routing (always_on)` (leitura obrigatória de `SKILL.md` no Turno 1 via `view_file`) preservando todas as regras de domínio e comandos canônicos customizados do projeto.
3. **Validação Automática**:
   - Execute a auditoria e o diagnóstico de conformidade:
     ```powershell
     powershell -ExecutionPolicy Bypass -File .\aidev.ps1 audit "<caminho>"
     powershell -ExecutionPolicy Bypass -File .\aidev.ps1 doctor "<caminho>"
     ```
   - Confirme que `Migration/Sync Needed : False`.

---

### ETAPA 5: Entrega Conclusiva e Guia para Novos Projetos
Entregue um resumo final com:
1. **Evidência de Instalação**: Confirmação da exposição global das 33 Skills e regra dinâmica no Antigravity.
2. **Estado do Projeto**: Governança configurada e pronta para desenvolvimento.
3. **Instruções para Workspaces Futuros**:
   - Explique que o Antigravity agora reconhece automaticamente todo o catálogo global de Skills e a regra de roteamento dinâmico em qualquer novo workspace sem necessidade de reinstalação.
   - Para inventariar e organizar novos repositórios futuros, basta utilizar o prompt `docs/PRIMEIRO-PROMPT.md` no workspace correspondente.
