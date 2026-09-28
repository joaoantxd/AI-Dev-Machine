# GEMINI.md — [Nome do Projeto]

> **Camada específica para Google Gemini CLI / Antigravity.**  
> As regras canônicas e compartilhadas do projeto vivem em `AGENTS.md`. Este arquivo deve conter apenas adaptações específicas do ecossistema Gemini.

@./AGENTS.md

> [!NOTE]
> Se `.gemini/settings.json` já carregar `AGENTS.md` e `GEMINI.md` via `context.fileName`, remova o import acima para não duplicar contexto.

---

## 1. Fonte de verdade e precedência

- `AGENTS.md` define arquitetura, stack, comandos, convenções, segurança, Git, testes e critérios de conclusão.
- `GEMINI.md` apenas complementa essas regras com comportamento específico do Gemini CLI / Antigravity.
- Não replique aqui catálogo de Skills, comandos ou políticas gerais já existentes em `AGENTS.md`.
- Dentro do repositório, contexto mais específico do diretório atual complementa ou prevalece sobre contexto mais geral, sempre respeitando instruções de sistema, plataforma e usuário.

---

## 2. Contexto nativo do Gemini

O Gemini CLI suporta contexto hierárquico e imports. Use isso para manter o contexto enxuto.

- Global: preferências estáveis do usuário.
- Projeto: `AGENTS.md` + este `GEMINI.md`.
- Local: instruções específicas próximas ao módulo trabalhado.
- Para regras de um único módulo, prefira contexto local em vez de crescer o arquivo raiz.
- Use `@arquivo` para compartilhar contexto estável sem copiar conteúdo.
- Quando houver dúvida sobre quais instruções estão ativas, inspecione a memória/contexto carregado antes de diagnosticar comportamento inconsistente.

### Configuração opcional

Para descoberta nativa de ambos os arquivos na hierarquia:

```json
{
  "context": {
    "fileName": ["AGENTS.md", "GEMINI.md"]
  }
}
```

Nesse modo, não importe `AGENTS.md` novamente neste arquivo.

---

## 3. Skills: Progressive Disclosure

Use o mecanismo nativo de Agent Skills do Gemini.

- Skill disponível não significa Skill obrigatória.
- Ative uma Skill somente quando sua descrição corresponder materialmente à tarefa.
- Não imponha “carregar pelo menos uma Skill”.
- Evite Skills sobrepostas sem necessidade concreta.
- Prefira a menor combinação capaz de executar a tarefa com segurança.
- `.agents/skills/` é suportado pelo Gemini como alias de Skills; não duplique tudo em `.gemini/skills/` apenas por compatibilidade.
- Respeite consentimento e permissões exigidos pelo runtime.

Use o catálogo real disponível na sessão. Exemplos de roteamento: debugging para bugs; Postgres/Supabase para banco; UI/UX para frontend; security para auth/permissões; Playwright para E2E; code review para revisão; domain modeling/codebase design para arquitetura; WinApp para QA Windows; Strix para pentest autônomo com IA.

---

## 4. Investigação de codebase e subagents

Para mudanças substanciais, construa primeiro um mapa do problema e evite exploração indiscriminada.

1. Leia `AGENTS.md` e o contexto local aplicável.
2. Se `AGENTS.md` orientar Graphify para o escopo atual e `graphify-out/` existir, consulte o grafo antes de exploração ampla.
3. Use `codebase_investigator` quando uma investigação profunda e isolada realmente ajudar: arquitetura, dependências, causa raiz ou mudança transversal.
4. Abra diretamente apenas os arquivos/símbolos necessários para confirmar detalhes.
5. Use CALM ou outro mecanismo de estado definido pelo projeto em execuções longas, multi-etapas ou de alto impacto.

### Delegação

Use subagents para isolamento de contexto ou especialização real. Evite delegação para rename, CSS pontual, mudança mecânica ou edição de poucas linhas. Não execute investigações paralelas redundantes sobre a mesma pergunta.

Não assuma nomes fixos de ferramentas de delegação. Consulte o registro de agents disponível na sessão; agentes locais podem viver em `.gemini/agents/` e agentes pessoais em `~/.gemini/agents/`.

---

## 5. Planejamento e implementação

Planeje proporcionalmente ao risco.

Para tarefa simples: investigue o mínimo necessário, altere, valide e conclua.

Para tarefa substancial, antes de editar:

1. defina objetivo e critério de conclusão;
2. identifique invariantes e riscos;
3. localize arquivos e símbolos envolvidos;
4. determine a menor sequência segura de mudanças;
5. implemente sem ampliar silenciosamente o escopo.

Quando Plan Mode estiver disponível e a mudança for arriscada, transversal ou ambígua, prefira planejar em modo de leitura antes de modificar o repositório.

Não crie `implementation_plan.md`, `walkthrough.md` ou arquivos semelhantes automaticamente para toda tarefa. Use artefatos persistentes apenas quando o projeto os exigir ou quando trouxerem valor real.

---

## 6. Terminal, autonomia e segurança operacional

- Use os comandos oficiais definidos em `AGENTS.md`.
- Verifique `stderr`, código de saída e resultado efetivo.
- Use background process apenas para processos que precisam permanecer vivos, como servidor ou watcher; acompanhe seu PID quando aplicável e não deixe processos órfãos.
- Não encerre processos do usuário que não tenham sido iniciados pela execução atual sem autorização.
- Preserve alterações preexistentes da working tree.
- Não faça refactors laterais, upgrades de dependências ou limpezas oportunistas fora do escopo.
- Pare quando o critério de conclusão autorizado tiver sido atingido.

---

## 7. Verificação antes de concluir

Nunca declare sucesso sem evidência compatível com o risco da mudança.

Valide primeiro o caminho mais próximo da alteração e amplie somente quando necessário:

- função isolada → teste relevante;
- módulo → testes do módulo + checagens estáticas aplicáveis;
- integração → testes de integração;
- UI/fluxo → teste de componente/E2E e inspeção visual quando importante;
- banco/migration → runtime/schema + invariantes relevantes;
- mudança transversal/pré-merge → gate completo do projeto.

Não rode `build + lint + typecheck + todos os testes` mecanicamente para qualquer alteração mínima, salvo se `AGENTS.md`, CI ou o risco exigir.

Ao concluir, informe quais verificações foram realmente executadas. Se alguma validação necessária não puder ser feita, declare a limitação explicitamente.

---

## 8. Relatório e manutenção

Mantenha o chat final curto: o que mudou, validações, blockers/riscos, commit/PR e teste manual quando necessário.

Se o projeto usa Walkthrough, registre nele evidências, arquivos alterados e decisões técnicas detalhadas; deixe no chat apenas o resumo operacional.

Antes de adicionar uma regra a este arquivo, pergunte:

1. ela já pertence ao `AGENTS.md`?
2. deveria ser uma Skill sob demanda?
3. vale apenas para um módulo e deveria ficar em contexto local?
4. descreve uma capacidade atual do Gemini ou depende de um nome de ferramenta transitório?

Se houver um local melhor, coloque a regra lá em vez de aumentar este arquivo.
