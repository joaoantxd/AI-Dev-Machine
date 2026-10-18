# Antigravity: ajuda entre subagentes

As definições dos dez especialistas e dos especialistas sintetizados permitem `send_message` e `manage_subagents`. O protocolo está em `templates/rules/orchestration.md` e é materializado em `.agents/rules/orchestration.md` por `aidev.ps1 apply`.

O especialista pode pedir ajuda a outro especialista com um ID real de conversa (`Recipient`, `Message`), obtido do coordenador ou de `manage_subagents` com `Action: list`. Deve informar escopo, evidências e arquivos, manter o coordenador informado e respeitar a responsabilidade de edição de cada colega. A lista de ferramentas não aplica restrições por argumento: a proibição de `kill`/`kill_all` é uma instrução de governança, não uma barreira de segurança do sistema operacional.

Quando a ferramenta ou o destinatário não estiver disponível, o pedido volta ao coordenador. Não há caixa de mensagens improvisada nem garantia de contexto compartilhado. Criação aninhada de agentes é capacidade distinta, limitada pelo runtime e pelo orçamento explícito do coordenador; não foi habilitada indiscriminadamente nos especialistas.

Ao terminar uma parte, o especialista deve ficar ocioso, preservando o contexto para nova ajuda até a conclusão validada do pedido completo. Mensagens reativam agentes ociosos, não agentes encerrados. A limpeza final cabe ao coordenador, respeitando parada explícita do usuário, segurança e limites impostos pelo aplicativo. Não há promessa de persistência após reiniciar o cliente ou a sessão.

Fontes oficiais consultadas em 18/10/2026: [ferramentas de colaboração](https://www.antigravity.google/docs/hooks/#agent-collaboration) e [comunicação e limites de subagentes](https://www.antigravity.google/docs/subagents/).

Aplicação local: AI DEV SKILLS, Nexus AI (workspace, backend e frontend) e JJ Elite Sports. Não foram modificados fontes das aplicações. Nenhum commit/push faz parte deste ajuste.

Validação: suíte completa do motor 46/46 aprovada (zero falhas, código de saída 0), incluindo ferramentas e protocolo dos agentes principais e sintetizados. Os cinco destinos passaram `audit` com `MigrationNeeded=False` e verificações focadas do ciclo ocioso/reativação. `git diff --check` aprovado. O grafo local foi atualizado com extração de código, sem chamada a modelo externo.

Limitação: configuração e testes automatizados do motor não provam entrega de mensagem no aplicativo Antigravity. A verificação dentro desse cliente permanece necessária, especialmente para confirmar a exposição das ferramentas na versão instalada. Codex/Claude devem usar seus próprios esquemas nativos, não os argumentos do Antigravity.
