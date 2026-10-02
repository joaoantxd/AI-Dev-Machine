# AGENTS.md — [Nome do Projeto]

> Instruções persistentes para agentes de engenharia de software neste repositório.
> Mantenha este arquivo **curto, específico do projeto e verificável**. Regras profundas de domínio devem ficar em `AGENTS.md` aninhados, Skills ou documentação própria e ser carregadas somente quando relevantes.

---

## 0. Precedência, Escopo e Fonte de Verdade

- Respeite a hierarquia de instruções do runtime. Instruções explícitas do usuário para a tarefa têm precedência sobre orientações deste arquivo quando não conflitarem com regras superiores de segurança/plataforma.
- Este `AGENTS.md` vale para toda a árvore abaixo deste diretório.
- Se existir um `AGENTS.md` mais próximo do arquivo em edição, as instruções mais específicas desse subdiretório prevalecem naquele escopo.
- Não duplique regras em vários arquivos. Mantenha **uma fonte de verdade** e use instruções locais apenas para diferenças reais do subprojeto.
- Se uma regra deste arquivo ficar obsoleta em relação ao código/CI atual, **não invente comportamento**: confirme no repositório, sinalize a divergência e proponha a atualização da documentação.

---

## 1. Projeto

- **Nome**: [Nome do Projeto]
- **Objetivo**: [O problema que o sistema resolve em 1–3 frases]
- **Usuários principais**: [Perfis de usuário]
- **Tipo**: [Web / API / Monorepo / CLI / Desktop / Mobile / Biblioteca]
- **Ambiente principal de desenvolvimento**: [Windows / Linux / macOS / container]

### Invariantes do domínio

> Liste aqui somente regras que, se violadas, causam bug, risco de segurança ou quebra de negócio.

- [Invariante crítico 1]
- [Invariante crítico 2]
- [Invariante crítico 3]

---

## 2. Stack e Arquitetura

- **Runtime / Linguagem**: [ex.: Node.js LTS + TypeScript]
- **Frontend**: [ex.: React / Next.js]
- **Backend / API**: [ex.: Fastify / NestJS / FastAPI]
- **Banco / ORM**: [ex.: PostgreSQL + Kysely]
- **Autenticação**: [ex.: Supabase Auth]
- **Testes**: [ex.: Vitest + Playwright]
- **Pacotes**: [ex.: pnpm]

### Mapa mínimo do repositório

```text
[preencha somente os diretórios que ajudam um agente a navegar]
src/
  ...
tests/
  ...
```

Para monorepos ou áreas com regras próprias, prefira `AGENTS.md` aninhados em vez de aumentar indefinidamente este arquivo.

---

## 3. Comandos Canônicos

> Use os comandos **reais deste repositório**. Remova qualquer linha que não se aplique. Não invente variantes quando já houver script oficial no `package.json`, `Makefile`, `justfile`, CI ou equivalente.

```bash
# instalar
[comando]

# desenvolvimento
[comando]

# testes focados / rápidos
[comando]

# testes completos relevantes
[comando]

# typecheck
[comando]

# lint / format check
[comando]

# build
[comando]
```

### Estratégia de validação

- Comece pelo check mais barato e diretamente relacionado ao diff.
- Amplie para testes de integração/E2E/build conforme o risco e o alcance da mudança.
- Mudança só de documentação não exige, por padrão, a suíte completa de aplicação.
- Nunca declare `PASS`, “corrigido” ou “concluído” sem evidência executada **depois da última alteração relevante**.
- Se um check necessário não puder ser executado, informe exatamente o que ficou sem validação e por quê.

---

## 4. Regras de Código

> Personalize esta seção para a stack real. Evite preferências genéricas que o formatter/linter já impõe automaticamente.

- Preserve padrões existentes antes de introduzir novos estilos ou abstrações.
- Prefira a menor mudança coerente que resolva a causa do problema.
- Reuse utilitários, tipos, componentes e serviços existentes antes de criar equivalentes.
- Não adicione dependência nova quando a plataforma, stdlib ou stack atual já resolver de forma adequada.
- Não silencie erros com `catch` vazio, fallback enganoso ou `any`/cast usado apenas para “fazer passar”.
- Mantenha regras de negócio fora de componentes puramente visuais quando a arquitetura do projeto separar essas responsabilidades.
- Comentários devem explicar **por que** algo não é óbvio; não narrar o código linha a linha.

### Convenções específicas

- [Ex.: TypeScript `strict: true`; evitar `any`]
- [Ex.: nomes de colunas SQL em `snake_case`]
- [Ex.: contratos de API validados com Zod]
- [Ex.: componentes React funcionais]

---

## 5. Segurança e Limites Operacionais

- **Nunca** commite `.env`, tokens, chaves, senhas ou credenciais reais.
- **Nunca** enfraqueça autenticação, autorização, RLS, TLS ou validações de segurança para facilitar testes.
- **Nunca** execute ações destrutivas ou de difícil reversão (`DROP`, `TRUNCATE`, reset de ambiente, exclusão em massa, force push etc.) sem autorização explícita quando não fizerem parte inequívoca da tarefa.
- Não reverta, sobrescreva ou “limpe” alterações do usuário que não pertencem ao escopo atual.
- Trate inputs externos como não confiáveis e valide nos boundaries apropriados.
- Para operações sensíveis, prefira dry-run, leitura ou simulação antes da mutation quando houver suporte.
- Não faça commit, push, merge, release ou deploy a menos que a tarefa ou o workflow do repositório autorize claramente essa ação.

---

## 6. Método de Trabalho

Para tarefas substanciais:

1. **Entenda o pedido e o critério de conclusão.** Não amplie o escopo por conveniência.
2. **Leia as instruções aplicáveis ao caminho.** Procure `AGENTS.md` mais específicos antes de editar subáreas.
3. **Adquira o mínimo de contexto necessário.** Comece por arquitetura, símbolos e arquivos diretamente relacionados; evite varredura ampla sem hipótese.
4. **Mapeie impacto antes de mudanças transversais.** Identifique callers, contratos, dados persistidos, testes e superfícies públicas afetadas.
5. **Para bugs, investigue a causa antes de editar.** Reproduza ou obtenha evidência observável sempre que possível.
6. **Implemente de forma mínima e consistente.** Não faça refactors laterais sem necessidade para cumprir a tarefa.
7. **Valide proporcionalmente ao risco.** Rode checks focados primeiro e amplie quando necessário.
8. **Revise o diff final.** Procure regressões, arquivos acidentais, segredos, mudanças fora de escopo e documentação desatualizada.
9. **Reporte fatos, não suposições.** Diferencie o que foi implementado, o que foi testado e o que continua pendente.
10. **Pare quando o escopo estiver concluído.** Não transforme uma correção local em “cleanup” geral do repositório.

### Tarefas triviais

Renames mecânicos, correções locais pequenas, texto/documentação e ajustes pontuais não precisam de cerimônia artificial. Use o caminho mais curto que preserve segurança e verificabilidade.

---

## 7. Ferramentas, Skills e Progressive Disclosure

**Instalada não significa necessária.** Não carregue ferramentas ou Skills por quota. Selecione apenas as que trazem ganho concreto para a tarefa atual.

### Navegação arquitetural

- **Graphify**: use como primeira camada em investigação/implementação/review **substancial** que atravesse módulos, dependências ou fluxos. Se houver `graphify-out/` válido, consulte o grafo antes de exploração ampla de arquivos.
- Se o grafo estiver ausente, claramente desatualizado ou não responder à pergunta, não bloqueie uma tarefa simples só para gerá-lo; use a estratégia de navegação mais precisa disponível e registre a limitação quando material.

### Execução longa e impacto

- **CALM**: use em tarefas longas, multi-etapas, refactors relevantes, investigação de call graph ou quando houver risco real de perder estado/objetivo.
- Para tarefas curtas e locais, não crie overhead de tracking sem benefício.

### Implementação

- **Ponytail / YAGNI**: aplique como princípio de implementação; carregue a Skill quando a tarefa envolver design/refactor onde overengineering seja um risco real.
- Prefira reuso → plataforma/stdlib → código customizado → nova dependência, nessa ordem quando tecnicamente adequado.

### Skills de domínio

Escolha a Skill pela natureza da tarefa, não porque ela existe:

| Situação | Skills candidatas |
|---|---|
| Bug / regressão / falha misteriosa | `systematic-debugging`, `diagnosing-bugs` |
| PostgreSQL / Supabase / SQL / migrations / RLS | `supabase-postgres-best-practices`, `supabase` |
| Frontend / UI / UX / acessibilidade | `frontend-design`, `ui-ux-pro-max`, `impeccable`, `web-design-guidelines` |
| React / Next.js / performance | `vercel-react-best-practices` |
| Segurança / auth / permissões / threat model | `security-best-practices`, `security-threat-model`; use **uma** review principal por rodada salvo necessidade clara |
| E2E / browser automation | `playwright` |
| Arquitetura / boundaries / domínio | `codebase-design`, `domain-modeling` |
| Code review / PR | `code-review` |
| Merge / rebase conflict | `resolving-merge-conflicts` |
| QA de app Windows / desktop | `winapp` |
| Pentest autônomo / ethical hacking / PoC de vulnerabilidades | `strix` |
| Compreensão de código / Grafo interativo / Onboarding | `understand-anything`, `graphify` |
| Avaliar plano de alto risco | `devils-advocate` |
| Criar/refinar prompts para agentes | `prompt-master`, `context-engineering` |

Antes de usar uma Skill, leia suas instruções atuais. Não presuma o conteúdo só pelo nome.

### Documentação externa

- Use **Context7** ou documentação oficial atual quando a tarefa depender de API/framework/biblioteca mutável.
- Prefira documentação primária do mantenedor a posts, snippets ou memória do modelo.
- Não pesquise externamente quando o repositório já contém a fonte autoritativa necessária.

---

## 8. Especialistas e Subagentes

Especialistas existem para aumentar qualidade ou paralelismo, não para criar cerimônia.

Delegue quando houver benefício claro, por exemplo:

- investigação independente que pode ocorrer em paralelo;
- análise especializada de segurança, banco, arquitetura ou QA crítico;
- subtarefa grande com boundary e entregável bem definidos;
- revisão independente de uma mudança de alto risco.

Não delegue para renames, pequenos ajustes, configuração simples ou mudanças de poucas linhas sem complexidade real.

Ao delegar:

- dê ao especialista objetivo, escopo, evidências e restrições suficientes;
- mantenha um agente principal responsável por integrar conclusões;
- trate a saída do subagente como evidência/recomendação a ser verificada, não como verdade automática;
- evite vários especialistas analisando a mesma coisa sem uma razão concreta.

---

## 9. Testes e Critério de Conclusão

Antes de concluir uma alteração de código, execute os checks relevantes ao diff e ao risco. Exemplos:

- [ ] teste(s) diretamente relacionados;
- [ ] typecheck quando houver código tipado afetado;
- [ ] lint/format check quando aplicável;
- [ ] build quando a mudança puder afetar compilação/empacotamento;
- [ ] integração/E2E para fluxos críticos ou mudanças cross-layer;
- [ ] migration/schema validation para mudanças de banco;
- [ ] revisão do diff final e `git status`.

**Regra:** sucesso é uma afirmação baseada em evidência recente. Não use “deve funcionar” como substituto de validação.

### Teste manual

Quando automação não cobrir adequadamente comportamento visual, integração física, hardware, permissões reais ou fluxo operacional crítico, sinalize explicitamente a necessidade de homologação humana e forneça um roteiro curto e reproduzível.

---

## 10. Git e Entrega

- Preserve a working tree do usuário; não descarte mudanças alheias ao escopo.
- Commits devem ser coesos e descrever o que realmente mudou.
- Não reescreva histórico compartilhado nem faça force push sem autorização explícita.
- Antes de commit/push/PR, confira o diff e os checks exigidos pelo repositório.
- Se houver instrução específica de PR/commit neste projeto, registre-a aqui ou em um `AGENTS.md` mais próximo do workflow correspondente.

---

## 11. Relatório Final

A resposta ao usuário deve ser curta e operacional:

- o que mudou;
- checks executados e resultado;
- blockers ou riscos restantes;
- commit/PR, quando aplicável;
- `TESTE MANUAL NECESSÁRIO` quando realmente houver homologação humana pendente.

Se o ambiente oferecer **Walkthrough** ou artefato equivalente, coloque lá o relatório detalhado, evidências, arquivos alterados e decisões técnicas; não despeje logs extensos no chat.

---

## 12. Compatibilidade entre Agentes

Use este `AGENTS.md` como fonte compartilhada sempre que o runtime suportar o formato.

Para evitar duplicação e drift:

- **OpenAI Codex / GitHub Copilot / Cursor e outros compatíveis**: use `AGENTS.md` diretamente.
- **Claude Code**: mantenha um `CLAUDE.md` mínimo que importe/referencie `AGENTS.md` e contenha apenas diferenças específicas do Claude quando necessárias.
- **Gemini CLI / Antigravity**: configure o contexto para ler `AGENTS.md` ou mantenha um `GEMINI.md` mínimo que importe/referencie este arquivo.

Não mantenha cópias completas e independentes das mesmas regras em `AGENTS.md`, `CLAUDE.md`, `GEMINI.md` e arquivos de IDE.

---

## 13. Manutenção deste Arquivo

Atualize o `AGENTS.md` quando mudar algum fato que altere como um agente deve trabalhar, por exemplo:

- comandos canônicos;
- estrutura importante do repositório;
- invariantes de domínio;
- políticas de segurança;
- critérios de validação;
- gotchas recorrentes observados em PRs/incidentes.

Não adicione regras para um erro isolado se o código, teste ou ferramenta puder eliminar a causa de forma mais robusta.

**Meta:** cada linha deste arquivo deve economizar contexto, prevenir um erro real ou tornar a execução verificável.
