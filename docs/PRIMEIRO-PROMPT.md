# AI-Dev-Machine v2.1 — Guia Prático de Inicialização e Primeiros Prompts

> **Manual Operacional para Antigravity IDE**
> Este documento fornece os **primeiros prompts completos, reutilizáveis e prontos para copiar** ao iniciar ou adotar projetos de software utilizando a governança do **AI-Dev-Machine Architecture v2.1**.

---

## 1. Como Funciona o AI-Dev-Machine no Antigravity

O **AI-Dev-Machine** é um framework capability-driven e agnóstico de linguagem. Ele opera através de:

1. **Manifesto Declarativo (`.aidev.json`)**: Intenção do projeto versionada (capabilities atômicas, regras locais, comandos e validation gates).
2. **Biblioteca Canônica Global (`%USERPROFILE%\.agents`)**: Repositório central de Skills (33) e Agentes (7) instalado na máquina.
3. **Isolamento de Workspace (`.agents/`)**: Cada projeto materializa fisicamente apenas as regras, especialistas e links simbólicos de skills estritamente necessários para a sua stack, eliminando poluição de contexto e duplicações.
4. **Constituição Universal (`AGENTS.md`)**: Arquivo enxuto (~60–80 linhas) com invariantes e comandos canônicos, acompanhado do bridge `GEMINI.md`.

---

## 2. Instruções Rápidas de Uso

### Qual prompt escolher?

| Cenário | Prompt Indicado | Onde executar |
|---|---|---|
| **Criar software novo do zero** | **Prompt A (Greenfield)** | No Antigravity, abra a pasta vazia do novo projeto |
| **Adotar repositório existente ou legado** | **Prompt B (Brownfield)** | No Antigravity, abra a raiz do repositório existente |

### Passo a passo no Antigravity IDE:
1. Abra o workspace desejado no **Antigravity IDE** (`File -> Open Folder...`).
2. Abra o painel de chat com o Agente de IA.
3. Copie o bloco de texto completo do **Prompt A** ou **Prompt B** abaixo.
4. Se houver detalhes específicos do seu projeto (ex: objetivo, requisitos ou preferências de stack), anexe-os ao final do prompt.
5. Envie a mensagem e acompanhe a execução determinística.

---

## 3. Prompt A — Criar um Projeto Novo (Greenfield)

```markdown
# Inicialização de Novo Projeto via AI-Dev-Machine v2.1

Você atuará como Engenheiro de Software Sênior e Arquiteto de Sistemas para inicializar este novo projeto de software do zero, aplicando a governança declarativa e capability-driven do **AI-Dev-Machine Architecture v2.1**.

Siga o método abaixo de forma autônoma, sem burocracia desnecessária. Quando informações essenciais estiverem ausentes, solicite apenas o estritamente necessário; se já houver clareza suficiente, avance diretamente na materialização.

---

## 1. Entendimento do Software & Stack Apropriada
- Analise o objetivo do produto, o domínio do problema e os requisitos funcionais fornecidos pelo usuário.
- Identifique a classe de software (ex: Web SPA/SSR, Desktop, Mobile, API Backend, CLI, Biblioteca, Sistema Embarcado, Monorepo ou Microsserviço).
- Selecione a stack e o ecossistema mais adequados ao problema (ex: Node.js/TypeScript, Python/FastAPI, Rust, Go, .NET/C#, Java/Kotlin, C++, etc.). **Não imponha tecnologias por padrão** (como React, TypeScript ou Supabase) se o escopo do projeto exigir outra solução.

---

## 2. Localização do Framework AI-Dev-Machine
- Localize o repositório do AI-Dev-Machine na máquina do usuário. Verifique caminhos padrão como:
  - \`$env:USERPROFILE\\Documents\\AI-Dev-Machine\`
  - \`$env:USERPROFILE\\AI-Dev-Machine\`
  - Ou o caminho informado pelo usuário / ambiente.
- Se o framework não for localizado, informe o usuário e solicite o caminho da instalação.

---

## 3. Seleção de Capabilities & Inicialização Oficial
- Inspecione as capabilities disponíveis no catálogo (\`registry/capabilities.json\`) do AI-Dev-Machine.
- Selecione apenas as capabilities atômicas pertinentes ao projeto (ex: \`core\`, \`typescript\`, \`python\`, \`react\`, \`nextjs\`, \`postgres\`, \`sqlite\`, \`electron\`, \`windows-desktop\`, \`browser-testing\`, \`security-audit\`, etc.).
- Utilize um preset conveniente (\`base\`, \`web-supabase\`, \`windows-desktop\`, \`monorepo\`) ou monte uma composição customizada.
- Execute a inicialização pelo fluxo oficial da CLI do framework:
  \`\`\`powershell
  powershell -ExecutionPolicy Bypass -File \"<aidev-root>\\aidev.ps1\" init \".\" -Preset <preset-escolhido>
  \`\`\`
  *(Ou componha via \`manifest init\` e \`capability add <id>\` seguido de \`apply\`).*

---

## 4. Manifesto Declarativo \`.aidev.json\` & Governança
- Certifique-se de que o \`.aidev.json\` gerado declara:
  - \`schemaVersion: 1\`
  - Lista de \`capabilities\` atômicas selecionadas;
  - \`validationGates.commands\` com os comandos reais do ecossistema escolhido (\`build\`, \`test\`, \`typecheck\`, \`lint\`, \`dev\`);
  - Gates automatizados (\`automated\`), gates humanos (\`human\`) e de hardware (\`hardware\`), quando pertinentes.
- Valide o manifesto com:
  \`\`\`powershell
  powershell -ExecutionPolicy Bypass -File \"<aidev-root>\\aidev.ps1\" manifest validate \".\"
  powershell -ExecutionPolicy Bypass -File \"<aidev-root>\\aidev.ps1\" resolve \".\"
  \`\`\`

---

## 5. Scaffold Inicial da Aplicação
- Crie a estrutura inicial mínima necessária para o projeto ser executável e testável (ex: arquivos de configuração do gerenciador de pacotes, dependências essenciais, ponto de entrada e um primeiro teste unitário básico de sanidade).
- Ajuste o \`AGENTS.md\` para refletir os comandos canônicos exatos da stack configurada.

---

## 6. Validação e Relatório
- Execute a validação inicial (ex: testes, typecheck ou build inicial) para comprovar que o scaffold está íntegro.
- Execute o diagnóstico de governança:
  \`\`\`powershell
  powershell -ExecutionPolicy Bypass -File \"<aidev-root>\\aidev.ps1\" audit \".\"
  \`\`\`
- Entregue um resumo conciso contendo:
  1. Objetivo e stack configurada;
  2. Capabilities e componentes materializados (Rules, Skills, Agents, MCPs, Hooks);
  3. Comandos canônicos disponíveis;
  4. Resultado dos primeiros testes executados;
  5. Próximos passos recomendados para o desenvolvimento.
```

---

## 4. Prompt B — Adotar um Projeto Existente (Brownfield / Legacy)

```markdown
# Adoção de Projeto Existente via AI-Dev-Machine v2.1

Você atuará como Engenheiro de Software Sênior e Arquiteto de Sistemas para adotar a governança do **AI-Dev-Machine Architecture v2.1** neste repositório existente, preservando integralmente todo o código, funcionalidades, histórico Git e trabalho em andamento.

Esta operação é **estritamente de governança e infraestrutura de IA**. **Não modifique funcionalidades, lógica de negócio, contratos de API, dependências de produto ou comportamento de runtime.**

Siga rigorosamente o fluxo seguro de adoção abaixo:

---

## 1. Verificação Inicial & Proteção da Working Tree (Read-Only)
- Inspecione o estado atual do repositório: HEAD, branch ativa, arquivos modificados/untracked e processos de desenvolvimento em execução.
- Verifique se \`.agents\` já existe e se é uma junction legada (reparse point para a biblioteca global) ou pasta física.
- Preserve 100% das alterações não commitadas do usuário. **Não execute \`git stash\`, \`git reset\`, \`git checkout .\` ou exclusões recursivas.**

---

## 2. Detecção Automática & Auditoria de Stack
- Localize a instalação do AI-Dev-Machine na máquina (ex: \`$env:USERPROFILE\\Documents\\AI-Dev-Machine\`).
- Execute a detecção e auditoria de 3 vias em modo estritamente somente leitura:
  \`\`\`powershell
  powershell -ExecutionPolicy Bypass -File \"<aidev-root>\\aidev.ps1\" detect \".\"
  powershell -ExecutionPolicy Bypass -File \"<aidev-root>\\aidev.ps1\" audit \".\"
  \`\`\`
- Identifique a stack real, tipagem, monorepos, bancos de dados, frameworks de UI, ferramentas de teste e comandos existentes em \`package.json\`, \`Makefile\`, \`pyproject.toml\`, \`Cargo.toml\`, etc.

---

## 3. Preservação de Conhecimento e Decomposição de Regras
- Compare o \`AGENTS.md\` / \`GEMINI.md\` ou regras existentes no repositório com o padrão v2.1.
- Extraia e preserve integralmente todas as invariantes de negócio, regras de segurança, autenticação, permissões, peculiaridades de hardware/OS e gotchas do projeto.
- Decomponha essas regras específicas em arquivos locais dedicados dentro de \`.agents/rules/<dominio>.md\` (ex: \`security.md\`, \`business-rules.md\`, \`session-architecture.md\`).
- Estruture o novo \`AGENTS.md\` como uma constituição universal enxuta (~60–80 linhas) apontando para as regras locais via Progressive Disclosure.

---

## 4. Proposta de Manifesto Declarativo \`.aidev.json\`
- Elabore a proposta final de manifesto \`.aidev.json\` contendo:
  - \`schemaVersion: 1\`
  - Preset sugerido ou composição customizada de capabilities;
  - \`projectRules\` listando os caminhos relativos das regras locais extraídas;
  - \`validationGates.commands\` com os comandos canônicos reais do repositório;
  - Gates automatizados, condicionais (\`onFiles\`), humanos e de hardware aplicáveis.
- Apresente o manifesto e o plano de migração para visualização do usuário.

---

## 5. Simulação Segura (Dry-Run) & Mecanismo de Rollback
- Execute a simulação da migração:
  \`\`\`powershell
  powershell -ExecutionPolicy Bypass -File \"<aidev-root>\\aidev.ps1\" migrate \".\" -DryRun
  \`\`\`
- Confirme que:
  - Um backup seguro automático será criado (ex: \`.aidev_backup_<timestamp>/\`);
  - Junctions legadas serão desvinculadas com segurança sem afetar a biblioteca global \`%USERPROFILE%\\.agents\`;
  - O rollback automático é garantido caso ocorra qualquer erro durante o processo.
- Solicite a confirmação do usuário caso haja qualquer risco material ou prossiga com a execução autorizada.

---

## 6. Materialização da Governança & Sincronização
- Execute a migração física:
  \`\`\`powershell
  powershell -ExecutionPolicy Bypass -File \"<aidev-root>\\aidev.ps1\" migrate \".\" -AutoApprove
  \`\`\`
  *(Ou materialização via \`aidev apply\` com backup prévio).*
- Verifique a materialização física de \`.agents/\`, regras locais, agentes, MCPs, hooks e links simbólicos de skills.

---

## 7. Quality Gate Pós-Migração & Verificação Não-Destrutiva
- Execute os diagnósticos completos:
  \`\`\`powershell
  powershell -ExecutionPolicy Bypass -File \"<aidev-root>\\aidev.ps1\" manifest validate \".\"
  powershell -ExecutionPolicy Bypass -File \"<aidev-root>\\aidev.ps1\" resolve \".\"
  powershell -ExecutionPolicy Bypass -File \"<aidev-root>\\aidev.ps1\" audit \".\"
  powershell -ExecutionPolicy Bypass -File \"<aidev-root>\\aidev.ps1\" clean \".\" -DryRun
  git diff --check
  \`\`\`
- Execute testes automatizados rápidos/focados que não interfiram com processos ativos ou portas em uso.
- Certifique-se de que a biblioteca global \`%USERPROFILE%\\.agents\` permaneceu 100% intacta.

---

## 8. Relatório de Conclusão
Entregue um resumo estruturado no chat:
1. Veredito (\`PASS\` / \`TESTE MANUAL NECESSÁRIO\` para homologação visual no IDE);
2. Capabilities declaradas e resolvidas;
3. Regras locais preservadas e materializadas;
4. Resultado dos diagnósticos e testes executados;
5. Confirmação de que o código funcional e processos ativos permaneceram intocados;
6. Roteiro curto para validação visual no painel do Antigravity.
```

---

## 5. Roteiro de Homologação Visual no Antigravity IDE

Após executar qualquer um dos prompts acima, realize a verificação visual no Antigravity:

1. **Painel de Contexto de IA**:
   - Abra a aba de agentes/skills do Antigravity.
   - Verifique que **apenas as Skills declaradas no manifesto** do projeto aparecem como ativas.
   - Verifique que os **Subagentes especializados** (ex: `researcher`, `reviewer`, `security-reviewer`, etc.) estão disponíveis para delegação.
2. **MCPs Ativos**:
   - Confirme no painel de ferramentas MCP que apenas as ferramentas relevantes para a stack (ex: `context7`, sem MCPs ruidosos desnecessários) estão registradas.
3. **Progressive Disclosure**:
   - Ao formular perguntas ou tarefas específicas, o agente lerá sob demanda as regras em `.agents/rules/` e skills em `.agents/skills/`.

---

## 6. Comandos de Manutenção Contínua

| Necessidade | Comando |
|---|---|
| **Verificar saúde e conformidade** | `powershell -File .\aidev.ps1 audit` |
| **Adicionar uma nova capacidade** | `powershell -File .\aidev.ps1 capability add <id>` seguido de `apply` |
| **Remover uma capacidade** | `powershell -File .\aidev.ps1 capability remove <id>` seguido de `apply` |
| **Simular limpeza de órfãos/backups** | `powershell -File .\aidev.ps1 clean -DryRun` |
| **Executar limpeza efetiva** | `powershell -File .\aidev.ps1 clean` |
| **Diagnóstico global do sistema** | `powershell -File .\aidev.ps1 doctor` |
