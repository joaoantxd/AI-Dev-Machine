# Runbook: Manutenção e Atualização do Ambiente AI-Dev-Machine

## 1. Verificação de Saúde
Execute o comando `doctor` para auditar ferramentas, bibliotecas e autenticação:
```powershell
powershell -ExecutionPolicy Bypass -File .\aidev.ps1 doctor
```

## 2. Atualização de Skills e Agentes Upstream
Para atualizar as bibliotecas canônicas com as versões mais recentes dos repositórios oficiais:
```powershell
powershell -ExecutionPolicy Bypass -File .\aidev.ps1 sync -Update
```

## 3. Limpeza de Artefatos Temporários
Para remover backups expirados e links obsoletos de projetos:
```powershell
powershell -ExecutionPolicy Bypass -File .\aidev.ps1 clean . -DryRun
powershell -ExecutionPolicy Bypass -File .\aidev.ps1 clean .
```

## 4. Execução da Suíte de Testes
Para garantir que nenhuma alteração quebrou a idempotência ou os contratos dos perfis:
```powershell
powershell -ExecutionPolicy Bypass -File .\aidev.ps1 test
```
