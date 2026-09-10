# AGENTS.md — [Nome do Projeto]

> **Instruções Operacionais para Agentes de IA**  
> Este arquivo fornece contexto persistente, padrões de código, restrições operacionais e catálogo completo de ativação das **29 Skills** gerenciadas para assistentes de IA (Google Antigravity, OpenAI Codex, Claude Code, Cursor, Windsurf) trabalhando neste repositório.

---

## 1. Visão Geral do Projeto

- **Nome**: [Nome do Projeto]
- **Objetivo / Problema**: [Breve descrição do que o sistema faz e qual problema resolve]
- **Público-Alvo / Usuários**: [Ex.: Administradores, Clientes finais, Contadores, etc.]
- **Tipo de Aplicação**: [Ex.: Web App Fullstack, API REST, Monorepo, CLI, App Desktop]

---

## 2. Tech Stack

- **Runtime / Linguagem**: [Ex.: Node.js LTS, TypeScript 5.x / Python 3.12]
- **Frontend**: [Ex.: Next.js App Router, React 19, Tailwind CSS / Vanilla CSS]
- **Backend / API**: [Ex.: Next.js Server Actions / NestJS / FastAPI / Express]
- **Banco de Dados & ORM**: [Ex.: PostgreSQL via Supabase, Prisma / Drizzle / Kysely]
- **Autenticação**: [Ex.: Supabase Auth / NextAuth / JWT]
- **Testes**: [Ex.: Vitest, Playwright, React Testing Library]
- **Gerenciador de Pacotes**: [Ex.: pnpm / npm / bun]

---

## 3. Comandos de Desenvolvimento

Use comandos exatos e evite variações desnecessárias:

```bash
# Instalação de dependências
pnpm install

# Servidor de desenvolvimento
pnpm dev

# Typecheck (validação estática sem emitir arquivos)
pnpm typecheck   # ou: npx tsc --noEmit

# Linter e Formatação
pnpm lint
pnpm lint --fix

# Testes automatizados
pnpm test
pnpm test:watch
pnpm test:e2e

# Build de produção
pnpm build
```

---

## 4. Estrutura do Repositório

```text
├── src/
│   ├── app/            # Rotas, páginas e layouts (App Router quando aplicável)
│   ├── components/     # Componentes reutilizáveis (UI)
│   │   └── ui/         # Primitivos visuais do design system
│   ├── lib/            # Utilitários, clientes de banco e serviços
│   ├── services/       # Regras de negócio e chamadas externas
│   ├── types/          # Tipagens compartilhadas e schemas (Zod)
│   └── hooks/          # Custom hooks React (quando aplicável)
├── tests/              # Testes de integração e E2E
├── .agents/            # [LINK LOCAL] Junction para %USERPROFILE%\.agents (ignorado no git)
├── AGENTS.md           # Este arquivo (instruções operacionais para IAs)
└── README.md           # Documentação para humanos
```

---

## 5. Convenções de Código e Padrões

1. **Tipagem Estrita**:
   - Sempre use TypeScript estrito (`strict: true`).
   - Evite `any` a todo custo; prefira `unknown` com asserções de tipo ou validação com schemas Zod.
2. **Componentes e Funções**:
   - Prefira componentes funcionais com hooks.
   - Use exportações nomeadas (`export function Component()`) para facilitar refatoração e busca.
   - Isole regras de negócio em services ou custom hooks; mantenha componentes visuais focados em apresentação.
3. **Estilo e Design Visual**:
   - Adote design rico: paleta de cores harmoniosa, tipografia moderna (Inter, Outfit, etc.), espaçamentos consistentes.
   - Evite layouts crus, vazios ou sem acabamento. Inclua hover states, loading states, empty states e tratamento de erro visual.
4. **Tratamento de Erros**:
   - Trate erros de forma explícita na camada de serviço ou controller.
   - Nunca silencie exceções com blocos `catch` vazios.
   - Retorne mensagens claras para o usuário e registre logs com contexto.

---

## 6. Limites Operacionais e Segurança (Boundaries)

> [!CAUTION]
> **Regras Absolutas de Segurança:**
> - **NUNCA** faça commit de arquivos `.env` ou credenciais reais. Use `.env.example` para documentar variáveis.
> - **NUNCA** desative autenticação, TLS ou políticas de RLS (Row Level Security) para "facilitar testes".
> - **NUNCA** execute migrações destrutivas (`DROP TABLE`, `TRUNCATE`) sem aprovação explícita do usuário.
> - Valide todo input recebido de usuários ou APIs externas usando schemas de validação (ex.: Zod).

---

## 7. Catálogo das 29 Skills Disponíveis & Ativação (Progressive Disclosure)

O ambiente global possui **29 Skills gerenciadas**. Não carregue todas ao mesmo tempo. Use **Progressive Disclosure** ativando apenas as skills relevantes para cada fase da tarefa:

### A. Core, Diagnóstico e Metodologia
| Skill | Quando Ativar / Trigger | Finalidade |
| :--- | :--- | :--- |
| **`context-engineering`** | Início de tarefas, contexto longo, degradação de qualidade | Curadoria de contexto enxuto, hierarquia de regras e foco do modelo |
| **`prompt-master`** | Criação ou refino de prompts e instruções para agentes | Engenharia e estruturação sistemática de prompts de alta precisão |
| **`systematic-debugging`** | Quando algo quebra, teste falha ou bug misterioso surge | Investigação metódica da causa raiz antes de fazer qualquer edição |
| **`diagnosing-bugs`** | Bugs difíceis, regressões de desempenho, heisenbugs | Ciclo estruturado de diagnóstico e isolamento de hipóteses |
| **`verification-before-completion`** | Imediatamente antes de declarar qualquer tarefa concluída | Exige evidências reais (typecheck, tests, build) antes de afirmar sucesso |
| **`caveman`** | Quando o usuário pedir respostas compactas ou "be brief" | Redução drástica de tokens verbosos mantendo rigor técnico |

### B. Arquitetura, Design de Módulos & Engenharia de Código
| Skill | Quando Ativar / Trigger | Finalidade |
| :--- | :--- | :--- |
| **`codebase-design`** | Criação ou refatoração de módulos e interfaces | Design de "módulos profundos" (deep modules), testabilidade e clareza |
| **`improve-codebase-architecture`** | Acoplamento excessivo, evolução ou reestruturação do repo | Estratégias estruturadas para refatoração arquitetural segura |
| **`domain-modeling`** | Definição de entidades, taxonomia e escrita de ADRs | Alinhamento do modelo de domínio e documentação de decisões |
| **`code-review`** | Revisão de PRs, branches ou alterações de código | Auditoria paralela: Padrões do Repositório (Standards) e Especificação (Spec) |
| **`devils-advocate`** | Planos complexos, pre-mortem, "o que estou esquecendo?" | Questionamento socrático para identificar pontos cegos e modos de falha |
| **`resolving-merge-conflicts`** | Conflitos durante merge ou rebase no Git | Resolução segura e metódica preservando lógica de ambos os lados |
| **`calm`** | Análise de impacto de diffs, call graph e navegação por símbolos | Coding Agent Liveness Map para entender impacto antes de alterar |
| **`graphify`** | Projetos grandes ou relações estruturais complexas | Análise gráfica profunda e mapa de dependências entre módulos |

### C. Frontend, UI/UX & Design System
| Skill | Quando Ativar / Trigger | Finalidade |
| :--- | :--- | :--- |
| **`ui-ux-pro-max`** | Planejamento e definição do sistema visual do frontend | Inteligência de design: 79 estilos, paletas, tipografia e layouts modernos |
| **`frontend-design`** | Implementação de páginas, telas e componentes visuais | Transformação de direção visual em código rico e esteticamente refinado |
| **`impeccable`** | Ajuste fino, micro-interações, espaçamento e tipografia | Polimento visual de alto nível para tornar a UI profissional e fluida |
| **`web-design-guidelines`** | Revisão de acessibilidade, contraste, usabilidade e UX | Auditoria de conformidade com diretrizes modernas de interface web |
| **`vercel-react-best-practices`** | Código React, Next.js, Server Components e hooks | Otimização de rendering, bundle size e boas práticas oficiais |

### D. Backend, Banco de Dados & Infraestrutura
| Skill | Quando Ativar / Trigger | Finalidade |
| :--- | :--- | :--- |
| **`supabase`** | Auth, Storage, Edge Functions, Realtime ou APIs Supabase | Implementação de serviços integrados Supabase |
| **`supabase-postgres-best-practices`** | Criação de tabelas, SQL, migrations, queries e RLS | Modelagem robusta de Postgres, índices eficientes e segurança de RLS |
| **`finding-google-skills`** | Projetos com Google Cloud, Firebase, Gemini API, Maps | Localização sob demanda de skills oficiais do catálogo Google |

### E. Segurança, Auditoria & Pentest
| Skill | Quando Ativar / Trigger | Finalidade |
| :--- | :--- | :--- |
| **`security-best-practices`** | Rotas de autenticação, APIs, gestão de tokens e sessões | Código seguro por padrão (OWASP, higienização, headers de segurança) |
| **`cybersecurity-review`** | Auditoria de vulnerabilidades em código ou dependências | Revisão em 9 dimensões de segurança de software |
| **`security-threat-model`** | Modelagem de ameaças e superfícies de ataque | Mapeamento de fronteiras de confiança, atores e vetores de exploração |
| **`security-review`** | Análise estática de segurança e auditoria de lockfiles | Orquestração de SAST e scanners (semgrep, trivy, gitleaks) |
| **`skill-security-review`** | Antes de instalar novas skills ou plugins de terceiros | Verificação estrita contra prompt injection e exfiltração de dados |
| **`review-skills`** | Auditoria do próprio repositório de skills | Eliminação de skills redundantes, quebradas ou órfãs |

### F. Automação & Testes no Navegador
| Skill | Quando Ativar / Trigger | Finalidade |
| :--- | :--- | :--- |
| **`playwright`** | Testes end-to-end, validação de telas e formulários | Automação de browser real via CLI para verificação de fluxos do usuário |

---

## 8. Protocolo de Verificação (Antes de Concluir)

Antes de declarar qualquer funcionalidade, refatoração ou correção como concluída:

- [ ] **Typecheck**: `pnpm typecheck` (ou `npx tsc --noEmit`) executado sem erros.
- [ ] **Lint**: `pnpm lint` passando sem violações.
- [ ] **Build**: `pnpm build` compila com sucesso.
- [ ] **Testes**: Testes unitários/integração relevantes executados e passando.
- [ ] **Evidência**: Forneça evidência real (saída do terminal, print ou status do comando) na resposta.
