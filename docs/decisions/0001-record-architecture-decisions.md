# ADR 0001: Adoção da Architecture v2 e Eliminação da Regra Zero Monolítica

## Status
Accepted (07/10/2026)

## Contexto
No modelo v1, o ecossistema utilizava uma "Regra Zero Inegociável" em `AGENTS.md` e junctions monolíticas de projeto (`project/.agents -> %USERPROFILE%\.agents`). Isso causava sobrecarga cognitiva nos coding agents (consumindo até 12.000 tokens na rodada inicial com 5+ skills carregadas indiscriminadamente) e acoplamento arriscado entre projetos.

## Decisão
1. Adotar a **Architecture v2**, baseada em 3 categorias de conhecimento:
   - Instrução Permanente: Constituição concisa em `AGENTS.md` (5 invariantes universais).
   - Conhecimento Contextual: Regras, skills e agentes descobertos sob demanda em `.agents/`.
   - Documentação Histórica: ADRs e runbooks em `docs/`, consultados apenas quando relevante.
2. Tornar o `.agents/` de cada projeto um diretório físico isolado e versionado, com links individuais apenas para as skills necessárias.
3. Centralizar todos os catálogos em `registry/*.json` como fonte única da verdade.
4. Criar a CLI unificada `aidev.ps1` para operações determinísticas.

## Consequências
- Redução drástica de ruído e alucinações por excesso de contexto.
- Desacoplamento seguro entre múltiplos projetos na mesma máquina.
- Compatibilidade multi-IA transparente (Antigravity, Codex, Claude, Gemini).
