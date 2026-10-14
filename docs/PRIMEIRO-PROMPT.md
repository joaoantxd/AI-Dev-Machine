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
   - Verifique se este workspace já possui manifesto `.aidev.json` ou pasta `.agents/` (e se `.agents` ou qualquer skill dentro de `.agents/skills/*` é uma junction legada `l----` em vez de pasta física `d----`).
   - Verifique se `.agents/rules/skill-routing.md` (`trigger: always_on`) está presente, se `.agents/hooks.json` usa `-File scripts/safety-check.ps1`, e se `AGENTS.md` e `GEMINI.md` possuem a cláusula de roteamento autônomo de skills (`skill-routing.md`).
   - Identifique a disponibilidade da Biblioteca Canônica Global (`%USERPROFILE%\.agents` e `%USERPROFILE%\.gemini\config`).
   - Identifique quais Rules, Skills, Especialistas, MCPs e Hooks estão ativos, inativos ou potencialmente duplicados.

4. **Classificação Epistemológica da Informação**:
   - O que é **Fato Confirmado** (código real existente, arquivos no disco)?
   - O que é **Governança/Decisão** (regras estabelecidas em `AGENTS.md` ou ADRs)?
   - O que é **Histórico / Handoff** de sessões anteriores?
   - O que é **Informação Obsoleta, Redundante ou Desconhecida**?

5. **Proposta de Organização e Próximos Passos**:
   - Apresente um resumo claro e estruturado do estado do ambiente.
   - Indique se o workspace está pronto para:
     - **Opção A (Greenfield)**: Início de um projeto novo do zero (`aidev init`);
     - **Opção B (Brownfield)**: Adoção ou reparo formal de governança em código existente (`aidev detect` → `aidev migrate` / `aidev apply` → `aidev audit` & `aidev doctor`);
     - **Opção C (Continuidade)**: Retomada de sprint/tarefa específica já estruturada.
   - Se identificar necessidade de atualização de governança ou pequenas reorganizações documentais, descreva-as explicitamente e solicite aprovação antes de executar qualquer alteração.

---

## FORMATO DE ENTREGA
Entregue no chat um resumo estruturado com:
1. **Identidade do Workspace**: Localização, tipo aparente e estado da working tree;
2. **Inventário Estrutural**: Principais pastas, configs e documentações encontradas;
3. **Diagnóstico de Governança de IA**: Presença de AI-Dev-Machine, `.aidev.json`, `.agents/` (skills físicas vs junctions), `skill-routing.md`, `hooks.json`, `AGENTS.md`/`GEMINI.md` e MCPs;
4. **Mapa de Conhecimento**: Decisões, handoffs ou regras pré-existentes identificadas;
5. **Recomendação de Próxima Fase**: Sugestão fundamentada entre Opção A (Novo), Opção B (Adoção/Organização) ou Opção C (Continuidade).

