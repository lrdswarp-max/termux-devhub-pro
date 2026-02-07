# 📋 TODO List - Correções DevHub Pro v3.0

**Data:** 7 de Fevereiro de 2026  
**Status:** 0/10 concluídas  
**Tempo estimado:** 2-3 horas

---

## 🔴 FASE 1: CRÍTICO (Deve corrigir - ~11 minutos)

### ☐ 1. Fix: Trocar `better-sqlite3` por `sqlite`
**Severidade:** 🔴 CRÍTICO  
**Arquivo:** `modules/05-create-project.sh`  
**Linhas:** 47, 60-61  
**Motivo:** `better-sqlite3` requer compilação nativa (node-gyp) que falha no Termux

**O que mudar:**
- Linha 47: `pnpm add next-pwa better-sqlite3 drizzle-orm` → `pnpm add next-pwa sqlite drizzle-orm`
- Linhas 60-61: Atualizar imports de `better-sqlite3` para `sqlite3`

**Arquivo para referência:** `CORRECOES_SUGERIDAS.md` (Seção 1)  
**Tempo:** 5 minutos

```
[ ] Editar módulo 05
[ ] Validar sintaxe
[ ] Testar com test-integration.sh
```

---

### ☐ 2. Fix: Automatizar `create-next-app` com entrada redirecionada
**Severidade:** 🔴 CRÍTICO  
**Arquivo:** `modules/05-create-project.sh`  
**Linhas:** 32-40  
**Motivo:** O comando `pnpm create next-app` faz perguntas interativas mesmo com todas as flags

**O que mudar:**
- Adicionar `echo "" |` antes do comando pnpm
- Isso redireciona entrada vazia e evita que o script travue

**Arquivo para referência:** `CORRECOES_SUGERIDAS.md` (Seção 4)  
**Tempo:** 2 minutos

```
[ ] Editar módulo 05
[ ] Adicionar redirecionamento
[ ] Validar sintaxe
```

---

### ☐ 3. Fix: Automatizar instalação de Oh-My-Zsh
**Severidade:** 🟠 ALTO  
**Arquivo:** `modules/03-configure-shell.sh`  
**Linhas:** 38-42  
**Motivo:** Flag `--unattended` pode não suprimir prompts do instalador

**O que mudar:**
- Adicionar `echo "" |` antes do comando sh/curl
- Ou usar variável de ambiente para simular "yes"

**Arquivo para referência:** `CORRECOES_SUGERIDAS.md` (Seção 3)  
**Tempo:** 3 minutos

```
[ ] Editar módulo 03
[ ] Adicionar redirecionamento
[ ] Testar com validate
```

---

### ☐ 4. Fix: Remover/comentar comando `chsh`
**Severidade:** 🟠 ALTO  
**Arquivo:** `modules/03-configure-shell.sh`  
**Linhas:** 27-30  
**Motivo:** Termux não suporta `chsh` (sem `/etc/passwd`), falha silenciosamente

**O que mudar:**
- Remover ou comentar as linhas 27-30 que tentam fazer `chsh -s zsh`
- Documentar que no Termux o shell não pode ser mudado desta forma

**Arquivo para referência:** `CORRECOES_SUGERIDAS.md` (Seção 2)  
**Tempo:** 1 minuto

```
[ ] Editar módulo 03
[ ] Remover linhas desnecessárias
[ ] Adicionar comentário explicativo
```

---

## 🟡 FASE 2: RECOMENDADO (~12 minutos)

### ☐ 5. Fix: Configurar npm cache antes de instalar globalmente
**Severidade:** 🟡 MÉDIO  
**Arquivo:** `modules/02-install-nodejs.sh`  
**Linhas:** 18-22  
**Motivo:** `npm install -g` pode falhar por problemas de permissão

**O que mudar:**
- Adicionar `npm config set prefix "$HOME/.npm-global"`
- Garantir este caminho está no PATH em `.bashrc`

**Arquivo para referência:** `CORRECOES_SUGERIDAS.md` (Seção 5)  
**Tempo:** 5 minutos

```
[ ] Editar módulo 02
[ ] Adicionar npm config
[ ] Adicionar PATH em .bashrc
[ ] Validar sintaxe
```

---

### ☐ 6. Fix: Melhorar validação de `git init`
**Severidade:** 🟡 MÉDIO  
**Arquivo:** `modules/05-create-project.sh`  
**Linhas:** 80-82  
**Motivo:** Comandos `git add` e `git commit` usam `|| true` (ignoram erros silenciosamente)

**O que mudar:**
- Usar condicionais aninhadas (`if git init; then if git add; then...`)
- Melhorar logging para identificar falhas
- Remover `|| true` de commits

**Arquivo para referência:** `CORRECOES_SUGERIDAS.md` (Seção 6)  
**Tempo:** 3 minutos

```
[ ] Editar módulo 05
[ ] Refatorar com if/then aninhados
[ ] Melhorar mensagens de log
[ ] Testar
```

---

### ☐ 7. Fix: Validar download de `vim-plug`
**Severidade:** 🟡 MÉDIO  
**Arquivo:** `modules/04-configure-tools.sh`  
**Linhas:** 70-76  
**Motivo:** Se curl falhar, erro é ignorado silenciosamente com `|| log "WARN"`

**O que mudar:**
- Verificar se arquivo foi realmente baixado
- Usar condicionais mais robustas
- Melhorar feedback ao usuário

**Arquivo para referência:** `CORRECOES_SUGERIDAS.md` (Seção 7)  
**Tempo:** 2 minutos

```
[ ] Editar módulo 04
[ ] Melhorar validação
[ ] Adicionar check [[ -f ... ]]
```

---

### ☐ 8. Fix: Garantir PATH propagado ou auto-executar source
**Severidade:** 🟡 MÉDIO  
**Arquivo:** `modules/06-create-devhub-command.sh`  
**Linhas:** 99-108  
**Motivo:** PATH adicionado a `.bashrc` não é carregado automaticamente

**O que mudar:**
- Opção A: Fazer export PATH antes de precisar usar `devhub`
- Opção B: Documentar que usuário deve fazer `source ~/.bashrc`
- Opção C: Executar comando em subshell com PATH configurado

**Arquivo para referência:** `CORRECOES_SUGERIDAS.md` (Seção 5)  
**Tempo:** 2 minutos

```
[ ] Editar módulo 06
[ ] Adicionar export PATH ou documentação
[ ] Validar
```

---

## ✅ FASE 3: TESTES E VALIDAÇÃO (~5 minutos)

### ☐ 9. Test: Executar `test-integration.sh` com sucesso
**Comando:** `bash test-integration.sh`  
**Esperado:** ✅ Todos os testes passarem  
**Tempo:** 2 minutos

```
[ ] Executar teste
[ ] Verificar todas as validações
[ ] Documentar resultado
```

---

### ☐ 10. Test: Executar `SIMULACAO_DRY_RUN.sh` sem erros
**Comando:** `bash SIMULACAO_DRY_RUN.sh`  
**Esperado:** ✅ Simular sem instalar nada  
**Tempo:** 2 minutos

```
[ ] Executar simulação
[ ] Revisar avisos
[ ] Confirmar compatibilidade
```

---

## 📊 RESUMO DE MUDANÇAS

| Fase | Tarefas | Tempo | Crítico |
|------|---------|-------|---------|
| 🔴 CRÍTICO | 1-4 | 11 min | SIM |
| 🟡 RECOMENDADO | 5-8 | 12 min | NÃO |
| ✅ TESTES | 9-10 | 5 min | SIM |

**TOTAL:** 10 tarefas | ~28 minutos | 2-3 horas com validação

---

## 📋 CHECKLIST FINAL

Antes de considerar CONCLUÍDO:

```
[ ] Todos os 4 problemas críticos foram corrigidos
[ ] test-integration.sh passa 100%
[ ] SIMULACAO_DRY_RUN.sh executa sem problemas críticos
[ ] Código foi revisado (revisão de pares)
[ ] Commit foi feito com mensagem: "fix: termux compatibility issues"
[ ] 4 arquivos de análise foram removidos ou arquivados (ANALISE_*, etc)
[ ] README.md foi atualizado com limitações conhecidas (opcional)
```

---

## 🚀 COMO COMEÇAR

1. **Marque cada tarefa como "in-progress" antes de começar**
2. **Use `CORRECOES_SUGERIDAS.md` como referência**
3. **Execute testes após cada mudança**
4. **Faça commit ao final de cada fase**

**Exemplo de workflow:**
```bash
# 1. Marcar como in-progress
mark-todo 1 in-progress

# 2. Editar arquivo
vim modules/05-create-project.sh

# 3. Validar
bash test-integration.sh

# 4. Marcar como completo
mark-todo 1 completed

# 5. Próxima tarefa
```

---

## 📞 REFERÊNCIA RÁPIDA

- **Análise Detalhada:** `ANALISE_DETALHADA.md`
- **Código para Copiar:** `CORRECOES_SUGERIDAS.md`
- **Sumário Executivo:** `SUMARIO_ANALISE.txt`
- **Relatório Completo:** `RELATORIO_FINAL.md`

---

**Criado:** 7 de Fevereiro de 2026  
**Versão:** 1.0  
**Status:** Aguardando execução
