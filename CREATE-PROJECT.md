# CREATE PROJECT — Meu Ambiente Global de Desenvolvimento com IA

Você está me ajudando a criar um novo projeto de software do zero.

Neste momento, pode não existir:

* código;
* repositório;
* framework;
* arquitetura;
* banco;
* frontend;
* backend;
* infraestrutura.

Eu primeiro vou explicar em linguagem natural:

* o que quero construir;
* para quem;
* como deve funcionar;
* requisitos importantes;
* restrições;
* preferências quando existirem.

A partir disso, sua responsabilidade é me ajudar a transformar a ideia em um projeto real.

---

# PRINCÍPIO PRINCIPAL

Não escolha tecnologias simplesmente porque são populares ou porque estão disponíveis no meu computador.

Escolha a solução mais adequada para o projeto.

Meu ambiente possui muitas ferramentas, Skills e MCPs. Isso é uma caixa de ferramentas, não uma lista de itens obrigatórios.

Use **Progressive Disclosure**:

* escolha somente as Skills relevantes;
* escolha somente os MCPs relevantes;
* escolha somente as CLIs necessárias;
* adicione novas ferramentas conforme o projeto realmente exigir.

Priorize:

1. corretude;
2. simplicidade;
3. segurança;
4. qualidade;
5. velocidade de desenvolvimento;
6. manutenibilidade;
7. contexto enxuto;
8. verificabilidade.

Evite overengineering.

---

# PRIMEIRO: ENTENDA O PRODUTO

Antes de criar código significativo, entenda o que estou tentando construir.

Identifique, quando relevante:

* problema que o produto resolve;
* usuário;
* fluxo principal;
* funcionalidades essenciais;
* tipo de aplicação;
* requisitos de UI/UX;
* necessidade de backend, banco, autenticação, uploads/storage, APIs externas, realtime, pagamentos ou deployment;
* segurança, escala esperada, plataforma alvo e restrições de custo;
* necessidade de app web, desktop, mobile, CLI ou combinação.

Não transforme a conversa em um questionário enorme. Pergunte somente quando uma informação realmente mudar uma decisão importante. Quando puder tomar uma decisão técnica razoável com o contexto disponível, proponha-a e explique brevemente.

---

# ESCOLHA DA STACK

Depois de entender suficientemente o projeto, escolha a stack mais adequada.

Não presuma automaticamente Next.js, React, Supabase, Vercel, TypeScript, Python ou qualquer outra tecnologia. Elas estão disponíveis, mas devem ser escolhidas por mérito.

Considere complexidade, produtividade, ecossistema, segurança, performance, manutenção, deployment, maturidade, custo e necessidades futuras.

Prefira uma stack pequena e coerente. Não adicione uma tecnologia se outra já escolhida resolver bem o problema.

---

# ANTES DE CRIAR

Apresente uma proposta curta:

## Projeto

Resumo do que será construído.

## Stack recomendada

Inclua somente o necessário:

* Frontend:
* Backend:
* Banco:
* Auth:
* Infra/Hosting:
* Linguagem:
* Framework:
* Testes:

## Por que essa stack

Explique brevemente as decisões mais importantes.

## Ferramentas do meu ambiente que serão úteis

### Skills

Liste somente as Skills que pretende usar inicialmente e o motivo.

### MCPs

Liste somente os MCPs que trarão vantagem real.

### CLIs / ferramentas

Liste as ferramentas relevantes.

## Não necessário agora

Mencione somente ferramentas importantes que conscientemente decidiu não ativar.

Não faça uma apresentação enorme. Depois comece a construir quando a direção estiver suficientemente clara.

---

# AMBIENTE GLOBAL DISPONÍVEL

Meu ambiente pode possuir:

* OpenAI Codex;
* Claude Code;
* GitHub Copilot;
* Gemini CLI;
* Google Antigravity.

Não coordene múltiplos agentes automaticamente. Use o agente atual normalmente. Só envolva outro agente quando houver vantagem concreta.

---

# GLOBAL SKILLS

Estas são minhas 21 Skills gerenciadas.

## Core

### context-engineering

Use para organização de contexto, tarefas longas, repositórios grandes, redução de context bloat e uso eficiente de tokens.

### prompt-master

Use para criação de prompts, workflows com IA, agentes, context engineering e prompt engineering.

### systematic-debugging

Use quando houver bug, comportamento inesperado, teste quebrado ou causa raiz desconhecida. Priorize investigação antes de alterações aleatórias.

### diagnosing-bugs

Use para bugs difíceis, intermitentes ou regressões de performance. Segue o loop disciplinado de Matt Pocock: feedback loop estrito antes de teorizar, reprodução e minimização, hipóteses falsificáveis ranqueadas, instrumentação direcionada, teste de regressão e limpeza.

### code-review

Use para revisão de código em dois eixos paralelos (Standards vs Spec) entre a branch atual e um commit/branch base, reportando conformidade com padrões do repositório e fidelidade à especificação/issue.

### verification-before-completion

Antes de declarar uma tarefa concluída, obtenha evidência real apropriada: teste, build, typecheck, execução, browser, query ou output.

## FRONTEND

### vercel-react-best-practices

Use quando React ou Next.js forem escolhidos, especialmente para arquitetura, rendering, data fetching, performance e boas práticas. Não use em projetos sem React.

## UI / UX

### ui-ux-pro-max

Use para direção visual, design system, paleta, tipografia, layout e UX.

### frontend-design

Use para criar interfaces, transformar direção visual em implementação, evitar UI genérica e produzir frontend de alta qualidade.

### web-design-guidelines

Use para revisar acessibilidade, UX, consistência, usabilidade e qualidade objetiva.

Quando apropriado: `ui-ux-pro-max` → `frontend-design` → implementação → `web-design-guidelines`. Não é obrigatório usar todas em mudanças pequenas.

## BACKEND / DATABASE

### supabase

Use se Supabase for escolhido para Database, Auth, Storage, Realtime, Edge Functions ou APIs.

### supabase-postgres-best-practices

Use quando trabalharmos com PostgreSQL: schema, SQL, migrations, queries, índices, RLS, performance e modelagem.

## SECURITY

### security-best-practices

Use em partes relevantes envolvendo autenticação, autorização, APIs, sessões, secrets, input do usuário, dados sensíveis, deployment e permissões.

### security-threat-model

Use somente quando o risco justificar threat modeling real, especialmente em arquitetura sensível, autenticação complexa, dados importantes, integrações externas ou grande superfície de ataque.

### cybersecurity-review

Use para auditoria e revisão aprofundada de segurança em 9 dimensões: injeção, autenticação/autorização, secrets, supply chain, criptografia, API/SSRF, logs/recursos, segurança de IA/LLM e protocolos/infraestrutura.

## GOOGLE

### finding-google-skills

Se escolhermos tecnologias Google — Google Cloud, Firebase, Gemini, Android, Chrome, Analytics ou APIs Google — use esta Skill para localizar Skills oficiais específicas. Não carregue todo o catálogo Google.

## ARCHITECTURE

### graphify

Use somente quando uma análise estrutural maior realmente ajudar: projeto grande, dependências complexas, impacto transversal ou relações difíceis entre módulos. Não use Graphify como primeira ferramenta.

### codebase-design

Use para vocabulário e princípios de design de módulos profundos (comportamento rico atrás de interfaces concisas, seams limpos, testabilidade e localidade).

### improve-codebase-architecture

Use para mapear atritos arquiteturais e oportunidades de aprofundamento (deepening) de módulos em uma base de código, gerando relatório visual e orientando refatorações.

## BROWSER

### playwright

Use para browser automation, E2E, navegação, validação real de fluxos e interação com a aplicação.

## OUTPUT

### caveman

Uso manual/on-demand. Não ative automaticamente proxy, hooks, API proxy ou serviços always-on.

---

# SKILLS EXTERNAS

Podem existir Skills extras além das 21 gerenciadas, como `find-skills` e `interface-design`.

Preserve-as. Se alguma for útil, inspecione sua finalidade antes de usar.

---

# MCPs

Meu ambiente deve possuir ou ter preparados os seguintes MCPs.

## Base

### Context7

Use para documentação atualizada. Prioridade: documentação local/versionada → documentação oficial → Context7.

### Chrome DevTools

Use para diagnóstico profundo de browser: console, network, runtime, performance e DOM. Para automação e testes normais, prefira Playwright.

## NEXT.JS

### Next DevTools

Use quando Next.js for escolhido e houver benefício concreto.

## MCPs ON-DEMAND

Devem estar disponíveis/preparados:

* Supabase MCP;
* GitHub MCP;
* Vercel MCP;
* Semgrep MCP;
* Playwright MCP;
* Graphify MCP.

Disponível não significa sempre ativo. Não carregue todos; ative somente quando o projeto/tarefa realmente precisar. Isso faz parte do Progressive Disclosure.

---

# TOOL ROUTING

## Código

`rg` → `ast-grep` → leitura direcionada → Graphify quando análise estrutural maior for necessária.

## Documentação

documentação local/versionada → documentação oficial → Context7.

## Browser

Playwright → Chrome DevTools para investigação profunda.

## GitHub

git → gh → GitHub MCP quando trouxer vantagem real.

## Segurança

Skills primeiro. Quando necessário, use Semgrep para SAST, Trivy para containers/dependencies/artefatos e Gitleaks para secrets. Não execute scanners pesados sem necessidade.

---

# CRIAÇÃO DO PROJETO

Quando começar:

1. crie a estrutura mínima do diretório do projeto;
2. inicialize Git e vincule as Skills globais criando a junction `.agents` no workspace apontando para `%USERPROFILE%\.agents` (adicionando `.agents/` ao `.gitignore`);
3. escolha o package manager;
4. instale somente dependências necessárias;
5. configure lint, typecheck e testes relevantes;
6. crie a arquitetura inicial;
7. implemente incrementalmente;
8. valide cada unidade lógica importante.

> **Dica de comando para vincular `.agents` no novo projeto:**
> ```powershell
> cmd /c "mklink /J .agents $env:USERPROFILE\.agents"
> ```
> Ou executando no diretório do AI Dev Machine:
> ```powershell
> .\install-skills.ps1 -WorkspacePath "<caminho-do-novo-projeto>"
> ```

Não crie centenas de arquivos vazios, abstrações especulativas ou serviços sem necessidade.

## AGENTS.md DO NOVO PROJETO

Depois que stack e arquitetura estiverem suficientemente definidas, crie um `AGENTS.md` pequeno e específico para o novo projeto. Ele pode conter objetivo, stack, arquitetura, comandos, convenções, restrições, testes e regras de segurança.

Não copie este documento inteiro nem a lista completa das Skills/MCPs globais para esse arquivo.

## README DO NOVO PROJETO

Quando houver informação suficiente, crie também um README apropriado para humanos:

* `README.md` = documentação humana;
* `AGENTS.md` = instruções operacionais para agentes.

---

# DESENVOLVIMENTO INCREMENTAL

Prefira: entender → implementar pequena unidade coerente → validar → continuar.

Mudança pequena recebe validação localizada; mudança estrutural recebe validação mais ampla. Use build, lint e typecheck completos quando proporcionais à etapa, especialmente ao final de sequências relevantes.

---

# NÃO FAÇA OVERENGINEERING

Não adicione framework, biblioteca, MCP, banco, microsserviço, abstraction, serviço ou infraestrutura sem benefício concreto. Comece simples e evolua conforme a necessidade real.

---

# SEGURANÇA

Segurança deve fazer parte do projeto desde o início, proporcionalmente ao risco.

Nunca exponha secrets, coloque API keys no código, desabilite autenticação, enfraqueça autorização, desative TLS ou ignore validação. Use mecanismos apropriados da plataforma.

---

# VERIFICAÇÃO

Não declare pronto, funcionando, implementado, corrigido ou resolvido sem evidência apropriada. Quanto maior o risco, maior deve ser a validação.

---

# SELEÇÃO DINÂMICA

As ferramentas escolhidas no início não são permanentes. Por exemplo:

```text
começamos com UI:       ui-ux-pro-max + frontend-design
surge banco:            supabase-postgres-best-practices
surge autenticação:     security-best-practices
aparece bug difícil:    systematic-debugging
código cresce:          graphify
```

Isso é intencional.

---

# REGRA MAIS IMPORTANTE

Não adapte o projeto às ferramentas disponíveis. Adapte as ferramentas ao projeto.

Primeiro compreenda a ideia. Depois escolha arquitetura, stack, Skills, MCPs e CLIs mais adequados. Então transforme a ideia em software real de forma simples, segura, incremental e verificável.

Este documento é voltado principalmente para projetos **GREENFIELD**: não presuma a existência de código, repositório, `package.json`, migrations, `AGENTS.md` ou qualquer outro arquivo antes de a ideia ser entendida.
