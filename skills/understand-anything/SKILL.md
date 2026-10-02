---
name: understand-anything
description: >-
  Análise profunda de repositórios e geração de grafos de conhecimento interativos (.ua/knowledge-graph.json),
  mapeamento de arquitetura, fluxos de domínio de negócio, análise de impacto de diffs e visualização
  em dashboard web force-directed via Understand-Anything (Egonex-AI/Understand-Anything).
license: MIT
metadata:
  author: Egonex-AI
  homepage: https://github.com/Egonex-AI/Understand-Anything
---

# Understand Anything — Compreensão de Codebase & Grafos de Conhecimento

A skill **`understand-anything`** orienta a análise arquitetural e geração de grafos de conhecimento interativos em qualquer base de código utilizando o framework **Understand-Anything** ([Egonex-AI/Understand-Anything](https://github.com/Egonex-AI/Understand-Anything)).

Enquanto scanners estáticos apenas listam dependências, o Understand-Anything utiliza um pipeline multi-agente e Tree-sitter para mapear tanto a topologia técnica (arquivos, classes, funções, chamadas) quanto os **fluxos de domínio de negócio**, exportando um grafo force-directed navegável (`.ua/knowledge-graph.json`) e uma interface visual interativa.

---

## 1. Quando Ativar esta Skill (Triggers)

Ative esta skill sempre que a tarefa envolver:
- **Onboarding e Exploração de Código Desconhecido**: Familiarização rápida com repositórios legados, monorepos grandes ou arquiteturas complexas.
- **Mapeamento de Domínio de Negócio**: Identificar quais módulos e fluxos de código implementam regras de negócio específicas (ex: faturamento, checkout, conciliação contábil).
- **Geração de Grafo Visual de Conhecimento**: Criação ou atualização do artefato `.ua/knowledge-graph.json` e abertura do dashboard visual para exploração.
- **Análise de Impacto de Mudanças (Diff Impact)**: Avaliar quais componentes, rotas e regras de negócio são potencialmente afetados por alterações git em andamento.
- **Geração de Guias de Onboarding**: Criação automática de walkthroughs arquiteturais ordenados por dependência e camada.

---

## 2. Relação no Repositório: Understand-Anything vs Graphify vs CALM

Para manter o ambiente disciplinado e sem sobreposição desnecessária de ferramentas:

| Ferramenta | Pergunta Central | Foco Principal | Formato Primário |
|---|---|---|---|
| **Graphify** | *Onde está a estrutura profunda?* | Detecção de comunidades, nós centrais (god nodes), consultas CLI GraphRAG e visualização standalone. | `graphify-out/GRAPH_REPORT.md` e JSON |
| **Understand-Anything** | *Como o código ensina a sua arquitetura e negócio?* | Grafo interativo visual force-directed, mapeamento de domínios, tours guiados e dashboard interativo adaptativo. | `.ua/knowledge-graph.json` e dashboard web |
| **CALM** | *Onde estamos nesta execução e qual o blast radius?* | Liveness de execução multi-passos, call graphs de 24 linguagens e write-safety gates para edição cirúrgica. | MCP CALM / `CALM_MAP.md` |

---

## 3. Comandos & Capacidades Canônicas

O ecossistema do Understand-Anything é composto pelos seguintes comandos principais:

| Comando / Sub-skill | Objetivo | Artefato Gerado |
|---|---|---|
| `/understand` (ou `understand`) | Executa o pipeline de análise completa do repositório. | `.ua/knowledge-graph.json` |
| `/understand-explain` | Análise profunda e didática de um arquivo, módulo ou subsistema. | Explicação técnica no chat |
| `/understand-diff` | Analisa o blast radius de alterações no git (riscos e acoplamentos). | Relatório de impacto |
| `/understand-domain` | Mapeia entidades e processos de negócio a partir do código fonte. | Seção de domínio no grafo |
| `/understand-onboard` | Gera um guia de integração passo a passo para novos engenheiros. | `ONBOARDING.md` / tour guiado |
| `/understand-dashboard` | Abre o dashboard interativo no navegador para navegação no grafo. | Servidor web local |

---

## 4. Pipeline de Análise em 7 Fases

Ao executar uma análise via Understand-Anything, o pipeline segue 7 fases bem definidas:

1. **Fase 0 — Pre-flight & Configuração**:
   - Resolução da raiz do projeto (`PROJECT_ROOT`) e diretório de dados (`.ua/` ou legado `.understand-anything/`).
   - Configuração de idioma (suporta `--language pt-BR` ou `en`) e regras de exclusão (`.understandignore` e `--exclude`).
2. **Fase 1 — Scan de Projeto & Inventário**:
   - Varredura de arquivos, detecção de linguagens, contagem de linhas e checagem de suporte a parsers Tree-sitter.
3. **Fase 2 — Análise em Lotes (Batch Processing)**:
   - Extração de AST, mapeamento de declarações (classes, funções, interfaces) e mapas de importação/exportação.
4. **Fase 3 — Arquitetura & Camadas**:
   - Identificação de subsistemas lógicos, camadas de aplicação (ex: controllers, services, repositories) e topologia.
5. **Fase 4 — Domínio de Negócio**:
   - Agrupamento de nós de código por conceitos de negócio e mapeamento de workflows orientados a domínio.
6. **Fase 5 — Validação e Revisão Determinística**:
   - Higienização de arestas órfãs, verificação de ciclos e garantia de integridade referencial do grafo.
7. **Fase 6 & 7 — Geração do Grafo & Visualização**:
   - Emissão do arquivo canônico `.ua/knowledge-graph.json` e inicialização do servidor de visualização interativa quando solicitado.

---

## 5. Instalação & Setup no Windows

### Via Instalador Oficial (PowerShell)
Caso a ferramenta ainda não esteja instalada globalmente na máquina:
```powershell
# Execução direta via PowerShell (instala para a plataforma atual)
irm https://raw.githubusercontent.com/Egonex-AI/Understand-Anything/main/install.ps1 | iex
```

### Instalação Manual e Linkage Multi-IA
```powershell
# 1. Clonar repositório upstream
git clone --depth 1 https://github.com/Egonex-AI/Understand-Anything.git "$env:USERPROFILE\.understand-anything\repo"

# 2. Criar Directory Junction para o plugin universal
cmd /c "mklink /J `"$env:USERPROFILE\.understand-anything-plugin`" `"$env:USERPROFILE\.understand-anything\repo\understand-anything-plugin`""

# 3. Compilar pacotes essenciais (requer Node.js >= 22 e pnpm >= 10)
cd "$env:USERPROFILE\.understand-anything\repo\understand-anything-plugin"
pnpm install
pnpm --filter @understand-anything/core build
```

---

## 6. Estrutura de Diretórios e Artefatos Gerados

Ao rodar em um projeto, todos os artefatos são gravados no diretório de dados:
```text
<workspace>/
├── .ua/
│   ├── config.json              # Configurações de idioma, auto-update e filtros
│   ├── knowledge-graph.json     # Grafo canônico de conhecimento (nós, arestas, metadados)
│   └── intermediate/            # Saídas parciais por lote durante processamento
```

> [!TIP]
> Adicione `.ua/` (ou `.understand-anything/`) ao `.gitignore` do repositório para evitar que grafos intermediários pesados sejam commitados, a menos que a equipe opte por compartilhar o grafo pré-computado.
