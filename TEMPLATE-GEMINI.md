# 🛑 REGRA ZERO INEGOCIÁVEL: ATIVAÇÃO OBRIGATÓRIA DE SKILLS NA RODADA 1

> ### ⚠️ PROTOCOLO DE DISPARO IMEDIATO (LEI SUPREMA DO REPOSITÓRIO)
> O agente **NUNCA DEVE** esperar o usuário solicitar o uso de uma skill.
> Na **PRIMEIRA RODADA** de qualquer comando ou solicitação do usuário, **ANTES** de executar ferramentas de busca cega (`grep_search`, `find_by_name`), comandos de terminal ou edição de arquivos, o agente **É OBRIGADO A EXECUTAR O PROTOCOLO ABAIXO**:
>
> 1. 🔍 **ONDE ESTÁ (Inteligência de Grafo - graphify - OBRIGATÓRIO EM TODOS OS PROJETOS)**:
>    - Se a pasta `graphify-out/` existir na raiz do projeto:
>      - **EXECUTE IMEDIATAMENTE** via terminal: `py -m graphify query "<pergunta ou termo da tarefa>"`
>      - **OU LEIA** com `view_file` os arquivos `graphify-out/GRAPH_REPORT.md` e `graphify-out/CALM_MAP.md`.
>      - 🛑 **É TERMINANTEMENTE PROIBIDO** fazer buscas cegas com `grep` ou listar diretórios antes de consultar o grafo de conhecimento.
>    - Se `graphify-out/` ainda não existir: chame `view_file` em `.agents/skills/graphify/SKILL.md` (ou `%USERPROFILE%\.agents\skills\graphify\SKILL.md`) e oriente a geração do grafo.
>
> 2. 🗺️ **ONDE ESTAMOS & IMPACTO SEGURO (Mapeamento de Chamadas - calm - OBRIGATÓRIO PARA QUALQUER MUDANÇA)**:
>    - Para qualquer refatoração, navegação profunda ou alteração de código:
>      - Chame `view_file` em `.agents/skills/calm/SKILL.md` (ou `%USERPROFILE%\.agents\skills\calm\SKILL.md`).
>      - Consulte `graphify-out/CALM_MAP.md` e siga a sequência: `locate` ➔ `source` ➔ `callers` ➔ `edit_context` ➔ `diff_impact`.
>
> 3. ✂️ **COMO ESCREVER (Minimalismo Radical - ponytail - OBRIGATÓRIO AO ESCREVER/EDITAR)**:
>    - Chame `view_file` em `.agents/skills/ponytail/SKILL.md`.
>    - Siga YAGNI radical: corte código supérfluo, use a stdlib nativa e reaproveite utilitários existentes antes de criar novas abstrações ou dependências.
>
> 4. 🎯 **SKILL ESPECIALIZADA DE DOMÍNIO (OBRIGATÓRIO CARREGAR PELO MENOS UMA VIA `view_file`)**:
>    - Identifique o domínio da tarefa e **chame `view_file` no `SKILL.md` correspondente** antes de propor código ou soluções:
>      * **Bugs / Erros / Falhas / Lentidão**: ➔ `.agents/skills/diagnosing-bugs/SKILL.md` ou `systematic-debugging/SKILL.md`
>      * **Postgres / Supabase / SQL / Migrations**: ➔ `.agents/skills/supabase-postgres-best-practices/SKILL.md` e/ou `supabase/SKILL.md`
>      * **Frontend / UI/UX / Telas / CSS / Acessibilidade**: ➔ `.agents/skills/ui-ux-pro-max/SKILL.md`, `frontend-design/SKILL.md` ou `impeccable/SKILL.md`
>      * **Performance React / Next.js / Server Components**: ➔ `.agents/skills/vercel-react-best-practices/SKILL.md`
>      * **Segurança / Auth / RLS / Permissões / Tokens**: ➔ `.agents/skills/security-best-practices/SKILL.md` ou `security-threat-model/SKILL.md`
>      * **Automação Browser / Testes E2E**: ➔ `.agents/skills/playwright/SKILL.md`
>      * **Revisão de Código / Pull Requests**: ➔ `.agents/skills/code-review/SKILL.md`
>      * **Desafio de Planos / Stress Testing**: ➔ `.agents/skills/devils-advocate/SKILL.md`
>      * **Modelagem de Domínio / Arquitetura**: ➔ `.agents/skills/domain-modeling/SKILL.md` ou `codebase-design/SKILL.md`
>    - 🛑 **É PROIBIDO pular o carregamento do `SKILL.md` alegando "já saber como fazer".**
>
> 5. 🛡️ **GATE DE CONCLUSÃO (verification-before-completion - OBRIGATÓRIO ANTES DA ENTREGA)**:
>    - Antes de alegar conclusão ou sucesso, chame `view_file` em `.agents/skills/verification-before-completion/SKILL.md`.
>    - *The Iron Law: NUNCA alegar sucesso sem evidências reais de comandos de validação (build, test, lint) executados nesta rodada.*

---

# GEMINI.md — [Nome do Projeto] (Google Antigravity & Gemini CLI)

> **Instruções Nativas para Google Antigravity & Gemini CLI**  
> Este arquivo é o ponto de entrada de configuração primária e regras operacionais para agentes do ecossistema Google (Antigravity IDE, Antigravity CLI e Gemini CLI).  
> A especificação completa do projeto, taxonomia de especialistas, convenções operacionais e catálogo detalhado das **30 Skills** gerenciadas residem em [`AGENTS.md`](file:///./AGENTS.md).

---

## 1. Visão Geral & Contexto do Projeto

- **Nome do Projeto**: [Nome do Projeto]
- **Missão / Propósito**: [Breve descrição do que o sistema faz e qual problema resolve]
- **Documento Canônico de Regras**: Consulte sempre [`AGENTS.md`](file:///./AGENTS.md) para diretrizes operacionais aprofundadas.

---

## 2. Tech Stack Resumida

- **Runtime / Linguagem**: [Ex.: Node.js 22 LTS, TypeScript 5.x / Python 3.12]
- **Frontend**: [Ex.: Next.js App Router, React 19, Tailwind CSS]
- **Backend / API**: [Ex.: Fastify / NestJS / Supabase / Express]
- **Banco de Dados & Storage**: [Ex.: PostgreSQL via Supabase Database, Storage S3/Supabase]
- **Testes & Qualidade**: [Ex.: Vitest, Playwright, ESLint]
- **Gerenciador de Pacotes**: [Ex.: pnpm / npm / bun]

---

## 3. Comandos Principais de Desenvolvimento

Execute sempre os comandos reais no terminal e confirme saída limpa:

```bash
# Desenvolvimento local
pnpm dev

# Validação estática de tipos (Typecheck)
pnpm typecheck

# Linter e formatação
pnpm lint

# Testes automatizados
pnpm test

# Build de produção
pnpm build
```

---

## 4. Diretrizes Específicas para Antigravity & Gemini CLI

1. **Subagents sob Demanda**:
   - Utilize subagents especializados (`invoke_subagent`) para tarefas com escopo pesado ou que exijam perspectiva de domínio (`Software Architect`, `Database Optimizer`, `Security Architect`, `Test Automation Engineer`).
   - Siga a Regra YAGNI: **NÃO** delegue para edições mecânicas, renomeações de variáveis, pequenos ajustes de CSS ou correções simples de poucas linhas.

2. **Gerenciamento Assíncrono de Tarefas**:
   - Ao disparar comandos de longa duração (dev server, builds pesados, testes extensos), utilize background tasks sem polling em loop (o ambiente notifica a conclusão reativamente).

3. **Geração de Artefatos**:
   - Utilize artefatos markdown (`implementation_plan.md`, `walkthrough.md`) quando planejar grandes refatorações ou resumir entregas complexas para o usuário.

4. **Princípio de Verificação Obrigatória (The Iron Law)**:
   - Nunca declare sucesso sem executar os testes/builds reais nesta rodada e comprovar com evidências da saída do terminal.
