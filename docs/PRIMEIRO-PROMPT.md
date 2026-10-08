# AI-Dev-Machine v2.1 — O Primeiro Prompt para o Antigravity IDE

> **Fase 0 — Inventário, Compreensão e Organização do Workspace**
> Este documento define o **primeiro prompt universal e canônico** a ser enviado ao **Google Antigravity IDE** ao abrir qualquer workspace.
>
> Ele estabelece uma etapa preliminar obrigatória de **reconhecimento e organização**, garantindo que a IA compreenda o ambiente antes de qualquer tomada de decisão técnica ou geração de código.

---

## 1. Por Que a Fase 0 é Obrigatória?

Antes de escolher uma stack, executar scripts de bootstrap ou escrever código, a IA precisa **descobrir, mapear e organizar a realidade do workspace aberto**.

A **Fase 0** impede:
- ❌ Criação de arquivos duplicados ou conflitantes;
- ❌ Suposições erradas sobre a finalidade do repositório;
- ❌ Execução prematura de comandos destrutivos ou de scaffolding;
- ❌ Descarte acidental de documentos, decisões históricas ou regras já existentes;
- ❌ Aplicação cega de templates genéricos sobre código em andamento.

---

## 2. Como Usar

1. Abra a pasta do projeto no **Antigravity IDE** (`File -> Open Folder...`).
2. Abra o painel de chat do Agente de IA.
3. Copie integralmente o bloco de texto do **Prompt Canônico (Fase 0)** abaixo e envie.
4. O Antigravity executará o inventário em modo **somente leitura**, apresentando o mapa do workspace e um relatório de continuidade.
5. Com base nesse inventário, você e o ChatGPT decidirão o próximo passo:
   - **Fluxo 1**: Criar um projeto novo (Greenfield);
   - **Fluxo 2**: Adotar formalmente um projeto existente (Brownfield);
   - **Fluxo 3**: Continuar o desenvolvimento de uma sprint ou feature em andamento.

---

## 3. Prompt Canônico — FASE 0: Inventário e Organização do Workspace

```markdown
# FASE 0 — Inventário, Compreensão e Organização do Workspace

Você atuará como Engenheiro de Software Sênior e Arquiteto de Sistemas para realizar o **inventário completo, o mapeamento estrutural e a organização conceitual deste workspace**, em conformidade com o framework **AI-Dev-Machine v2.1**.

Esta é uma etapa preliminar de **reconhecimento e diagnóstico**.

---

## LIMITES E RESTRIÇÕES MANDATÓRIAS DESTA RODADA
- **NÃO iniciar implementação de software.**
- **NÃO escrever código de aplicação ou testes.**
- **NÃO escolher antecipadamente uma stack, framework ou arquitetura de produto.**
- **NÃO executar comandos de mutação (ex: `init`, `apply`, `migrate`, `npm install`, etc.) sem autorização prévia.**
- **NÃO mover, renomear ou excluir arquivos desconhecidos automaticamente.**
- Opere de forma **estritamente observacional e não-destrutiva**.

---

## OBJETIVOS DA INVESTIGAÇÃO

1. **Identificação do Workspace & Finalidade**:
   - Qual é o caminho raiz deste workspace?
   - Qual parece ser a finalidade ou o estágio deste repositório (vazio, protótipo, legado, biblioteca, monorepo, produção)?
   - Existem processos ativos ou evidências de desenvolvimento recente?

2. **Inventário de Arquivos, Pastas e Documentação**:
   - Mapeie a árvore de diretórios existente.
   - Identifique arquivos de configuração existentes (`package.json`, `tsconfig.json`, `pyproject.toml`, `Cargo.toml`, `Makefile`, `.env.example`, etc.).
   - Localize documentações, especificações, ADRs, notas de arquitetura ou handoffs prévios (`docs/`, `AGENTS.md`, `README.md`, notas do Obsidian, etc.).

3. **Descoberta do AI-Dev-Machine & Governança**:
   - Localize onde o repositório central do AI-Dev-Machine está instalado na máquina (ex: `$env:USERPROFILE\Documents\AI-Dev-Machine` ou caminhos equivalentes).
   - Verifique se este workspace já possui manifesto `.aidev.json` ou pasta `.agents/` (e se é uma junction legada ou pasta física).
   - Identifique a disponibilidade da Biblioteca Canônica Global (`%USERPROFILE%\.agents`).
   - Identifique quais Rules, Skills, Especialistas, MCPs e Hooks estão ativos, inativos ou potencialmente duplicados.

4. **Classificação Epistemológica da Informação**:
   - O que é **Fato Confirmado** (código real existente, arquivos no disco)?
   - O que é **Governança/Decisão** (regras estabelecidas em `AGENTS.md` ou ADRs)?
   - O que é **Histórico / Handoff** de sessões anteriores?
   - O que é **Informação Obsoleta, Redundante ou Desconhecida**?

5. **Proposta de Organização e Próximos Passos**:
   - Apresente um resumo claro e estruturado do estado do ambiente.
   - Indique se o workspace está pronto para:
     - **Opção A (Greenfield)**: Início de um projeto novo do zero;
     - **Opção B (Brownfield)**: Adoção formal de governança em código existente (`aidev detect` / `aidev migrate`);
     - **Opção C (Continuidade)**: Retomada de sprint/tarefa específica já estruturada.
   - Se identificar necessidade de pequenas limpezas ou reorganizações documentais, descreva-as explicitamente e solicite aprovação antes de executar qualquer alteração.

---

## FORMATO DE ENTREGA
Entregue no chat um resumo estruturado com:
1. **Identidade do Workspace**: Localização, tipo aparente e estado da working tree;
2. **Inventário Estrutural**: Principais pastas, configs e documentações encontradas;
3. **Diagnóstico de Governança de IA**: Presença de AI-Dev-Machine, `.aidev.json`, `.agents/`, Rules e MCPs;
4. **Mapa de Conhecimento**: Decisões, handoffs ou regras pré-existentes identificadas;
5. **Recomendação de Próxima Fase**: Sugestão fundamentada entre Opção A (Novo), Opção B (Adoção) ou Opção C (Continuidade).
```

---

## 4. Próximas Fases (Após a Conclusão da Fase 0)

Depois que o Antigravity apresentar o relatório da **Fase 0**, você e o ChatGPT selecionarão o fluxo de trabalho apropriado:

```text
               ┌────────────────────────────────────────────────────────┐
               │    FASE 0 — Inventário e Organização do Workspace      │
               └───────────────────────────┬────────────────────────────┘
                                           │
                ┌──────────────────────────┼──────────────────────────┐
                ▼                          ▼                          ▼
     ┌─────────────────────┐    ┌─────────────────────┐    ┌─────────────────────┐
     │ FLUXO 1: Greenfield │    │ FLUXO 2: Brownfield │    │ FLUXO 3: Continuity │
     │  Criar Novo Projeto │    │   Adotar Existente  │    │ Continuar Trabalho  │
     │      do Zero        │    │    com Segurança    │    │    em Andamento     │
     └─────────────────────┘    └─────────────────────┘    └─────────────────────┘
```

### Resumo dos Fluxos Posteriores:

- **Fluxo 1 — Criar Novo Projeto (Greenfield)**:
  - Seleção de stack por mérito;
  - Definição do manifesto `.aidev.json` com capabilities atômicas;
  - Inicialização via `aidev.ps1 init` ou `manifest init` + `apply`;
  - Scaffold inicial e testes de sanidade.

- **Fluxo 2 — Adotar Projeto Existente (Brownfield)**:
  - Detecção read-only via `aidev.ps1 detect` e `aidev.ps1 audit`;
  - Decomposição semântica e preservação de regras em `.agents/rules/<dominio>.md`;
  - Simulação segura com `aidev.ps1 migrate -DryRun` e backup automático;
  - Materialização física autorizada com `aidev.ps1 migrate -AutoApprove`.

- **Fluxo 3 — Continuidade de Projeto em Andamento**:
  - Consulta ao último handoff no Obsidian ou relatório da sprint anterior;
  - Execução incremental da feature com foco em blast radius controlado;
  - Validação contínua através do verification gate (`pnpm test`, `typecheck`, etc.).
