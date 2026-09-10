# AGENTS.md — [Nome do Projeto]

> **Instruções Operacionais para Agentes de IA**  
> Este arquivo fornece contexto persistente e restrições operacionais para assistentes de IA (Google Antigravity, OpenAI Codex, Claude Code, Cursor, Windsurf) trabalhando neste repositório.

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
├── AGENTS.md           # Este arquivo (instruções para IAs)
└── README.md           # Documentação para humanos
```

---

## 5. Convenções de Código e Padrões

1. **Tipagem Estrita**:
   - Sempre use TypeScript estrito (`strict: true`).
   - Evite `any` a todo custo; prefira `unknown` com validação de tipo ou schemas Zod.
2. **Componentes e Funções**:
   - Prefira componentes funcionais com hooks.
   - Use exportações nomeadas (`export function Component()`) para facilitar refatoração e busca.
   - Isole lógica de negócio em hooks customizados ou services; mantenha a UI focada na apresentação.
3. **Estilo e Design**:
   - Siga um design system consistente (paleta de cores, tipografia moderna, espaçamentos padronizados).
   - Evite layouts crus ou genéricos; inclua micro-interações, hover states e feedback visual claro (loading, empty states, error boundaries).
4. **Tratamento de Erros**:
   - Trate erros de forma explícita na camada de serviço ou controller.
   - Nunca silencie erros em blocos `catch` vazios.
   - Retorne mensagens de erro amigáveis para o usuário e logs estruturados no console/servidor.

---

## 6. Limites Operacionais e Segurança (Boundaries)

> [!CAUTION]
> **Regras Absolutas de Segurança:**
> - **NUNCA** faça commit de arquivos `.env` ou credenciais reais. Use `.env.example` para documentar variáveis.
> - **NUNCA** desative autenticação, TLS ou políticas de RLS (Row Level Security) para "facilitar testes".
> - **NUNCA** execute migrações destrutivas (`DROP TABLE`, `TRUNCATE`) sem aprovação explícita do usuário.
> - Valide todo input recebido de usuários ou APIs externas usando schemas de validação (ex.: Zod).

---

## 7. Ativação de Skills e MCPs (Progressive Disclosure)

Carregue e aplique as Skills da máquina conforme o tipo de tarefa:

| Situação / Tarefa | Skill a Ativar | Finalidade |
| :--- | :--- | :--- |
| Início de sessão / Gestão de contexto | `context-engineering` | Manter contexto enxuto e estruturado |
| Criação ou redesign de UI | `ui-ux-pro-max` + `frontend-design` | Direção de arte, paleta, componentes de alto padrão |
| Revisão de acessibilidade e qualidade web | `web-design-guidelines` | Garantir contraste, usabilidade e responsividade |
| Trabalho com Postgres / Supabase | `supabase-postgres-best-practices` | Schemas limpos, RLS seguro, índices adequados |
| Investigação de bug ou quebra de build | `systematic-debugging` | Investigar causa raiz antes de editar código |
| Finalização de qualquer tarefa | `verification-before-completion` | Não declarar pronto sem teste/typecheck/build real |
| Browser testing / Automação | `playwright` | Validação real de navegação e fluxos |

---

## 8. Protocolo de Verificação (Antes de Concluir)

Antes de declarar qualquer funcionalidade ou correção como concluída:

- [ ] **Typecheck**: `pnpm typecheck` executado sem erros.
- [ ] **Lint**: `pnpm lint` passando sem violações.
- [ ] **Build**: `pnpm build` compila com sucesso.
- [ ] **Testes**: Testes unitários/integração relevantes executados e passando.
- [ ] **Evidência**: Forneça evidência real (saída do terminal, print ou status do comando) na resposta.
