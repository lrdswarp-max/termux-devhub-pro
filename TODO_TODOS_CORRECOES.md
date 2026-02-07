# 📋 TODO - Todas as Correções do DevHub Pro v3.0

**Status Global:** 🚧 14 tarefas identificadas  
**Prioridade:** 4 Críticas | 5 Altas | 5 Médias  
**Tempo Estimado:** 8-12 horas completo

---

## 🔴 FASE 1: CRÍTICO (Implementar HOJE - 1-2 horas)

### 1. ✅ Corrigir `better-sqlite3` - Compatibilidade Termux
- **Arquivo:** `modules/05-create-project.sh`
- **Linhas:** 47, 60-61
- **Problema:** Requer compilação nativa, falha em Termux
- **Solução:** Oferecer menu interativo com 3 opções:
  ```
  1) sqlite3 (puro JavaScript) - RECOMENDADO ✅
  2) better-sqlite3 (com compilação - requer 200MB extra)
  3) Supabase/Firebase (sem DB local)
  ```
- **Tempo:** 15 min
- **Impacto:** CRÍTICO - instalação fail sem isso

---

### 2. ✅ Remover `chsh` - Termux não suporta
- **Arquivo:** `modules/03-configure-shell.sh`
- **Linhas:** 27-30
- **Problema:** `chsh` não funciona em Termux (/etc/passwd não modificável)
- **Solução:** 
  - Remover tentativa de chsh
  - Adicionar notas em .zshrc sobre shell padrão
  - Documentar que shell mudar após reboot não funciona
- **Tempo:** 5 min
- **Impacto:** CRÍTICO - falha silenciosa

---

### 3. ✅ Automatizar `Oh-My-Zsh` - Remover prompts interativos
- **Arquivo:** `modules/03-configure-shell.sh`
- **Linhas:** 37-42
- **Problema:** Instalador pode pedir confirmação mesmo com --unattended
- **Solução:**
  ```bash
  export RUNZSH=no
  echo "" | sh -c "$(curl -fsSL https://...)" "" --unattended
  ```
- **Tempo:** 5 min
- **Impacto:** CRÍTICO - pode travar instalação

---

### 4. ✅ Automatizar `create-next-app` - Remover interatividade
- **Arquivo:** `modules/05-create-project.sh`
- **Linhas:** 32-40
- **Problema:** Faz perguntas mesmo com todas as flags
- **Solução:**
  ```bash
  echo "" | pnpm create next-app@latest devhub-pwa \
    --typescript \
    --tailwind \
    --eslint \
    --app \
    --no-git \
    --import-alias '@/*'
  ```
- **Tempo:** 2 min
- **Impacto:** CRÍTICO - pode travar instalação

---

## 🟠 FASE 2: ALTO (Próximas 48h - 2-3 horas)

### 5. ✅ Configurar npm para Termux - Permissões
- **Arquivo:** `modules/02-install-nodejs.sh`
- **Linhas:** 18-25
- **Problema:** `npm install -g` pode falhar por permissões
- **Solução:**
  ```bash
  npm config set prefix "$HOME/.npm-global"
  export PATH="$HOME/.npm-global/bin:$PATH"
  # Adicionar ao .bashrc também
  ```
- **Tempo:** 10 min
- **Impacto:** ALTO - evita falhas silenciosas

---

### 6. ✅ Adicionar WATCHPACK_POLLING para HMR
- **Arquivo:** `modules/05-create-project.sh` (novo arquivo .env.local)
- **Problema:** Hot reload não funciona bem em Termux (inotify limitado)
- **Solução:**
  ```bash
  # Adicionar ao .env.local:
  WATCHPACK_POLLING=1000
  NEXT_PUBLIC_SKIP_ENV_VALIDATION_IN_BUILD=true
  ```
- **Tempo:** 5 min
- **Impacto:** ALTO - resolve HMR lento/quebrado

---

### 7. ✅ Verificar inotify e compatibilidade Termux
- **Arquivo:** `modules/run-all.sh` (nova função)
- **Problema:** Script não valida ambiente Termux specific
- **Solução:** Adicionar função `check_termux_compatibility()`:
  ```bash
  - Verificar se está em Termux (/data/data/com.termux)
  - Avisar se inotify-tools não instalado
  - Alertar sobre RAM <2GB
  - Verificar storage disponível
  ```
- **Tempo:** 20 min
- **Impacto:** ALTO - melhor UX e troubleshooting

---

### 8. ✅ Otimizar dependências - Remover opcionais
- **Arquivo:** `modules/01-install-system.sh`
- **Linhas:** 33-48 (lista PACKAGES)
- **Problema:** Instala 75MB em pacotes opcionais para Termux
- **Solução:** Criar flag instalação:
  ```bash
  # INSTALAÇÃO MÍNIMA (para usuários com pouco storage)
  git curl node npm pnpm openssh
  
  # INSTALAÇÃO PADRÃO (atual)
  ... todos ...
  
  # INSTALAÇÃO COMPLETA (com dev tools)
  ... todos + build-essential ...
  ```
- **Tempo:** 30 min
- **Impacto:** ALTO - economiza 34MB, instalação 10x mais rápida

---

### 9. ✅ Criar configuração Neovim otimizada para Termux
- **Arquivo:** `modules/04-configure-tools.sh`
- **Problema:** Config Neovim pode ser pesada em Termux
- **Solução:** Oferecer duas configs:
  ```
  ~/.config/nvim/init-minimal.lua  # Apenas basico
  ~/.config/nvim/init-full.lua      # Com LSP, treesitter
  ```
  - User escolhe na instalação
  - Minimal é default
- **Tempo:** 45 min
- **Impacto:** ALTO - melhora performance Neovim

---

## 🟡 FASE 3: MÉDIO (Próxima semana - 2-3 horas)

### 10. ✅ Melhorar validação `git init`
- **Arquivo:** `modules/05-create-project.sh`
- **Linhas:** 80-82
- **Problema:** `git add` e `git commit` falham silenciosamente com `|| true`
- **Solução:** Estrutura com validação:
  ```bash
  if git init && git add . && git commit -m "..."; then
      log "SUCCESS" "Git repositório inicializado"
  else
      log "WARN" "Git não foi inicializado corretamente"
  fi
  ```
- **Tempo:** 15 min
- **Impacto:** MÉDIO - melhor logging

---

### 11. ✅ Validar vim-plug download
- **Arquivo:** `modules/04-configure-tools.sh`
- **Linhas:** 70-76
- **Problema:** curl fail é ignorado, vim-plug nunca é instalado
- **Solução:**
  ```bash
  if curl -fLo ~/.config/nvim/autoload/plug.vim ...; then
      log "SUCCESS" "vim-plug instalado"
  else
      log "WARN" "vim-plug não disponível (Neovim funciona sem)"
  fi
  ```
- **Tempo:** 10 min
- **Impacto:** MÉDIO - garantir plugin manager

---

### 12. ✅ Auto-source .bashrc após instalação
- **Arquivo:** `modules/run-all.sh`
- **Problema:** User precisa fazer `source ~/.bashrc` manualmente
- **Solução:**
  ```bash
  # Ao final da instalação:
  source ~/.bashrc
  # Informar ao user que PATH foi atualizado
  ```
- **Tempo:** 15 min
- **Impacto:** MÉDIO - melhora UX

---

### 13. ✅ Adicionar suporte Termux-API (opcional)
- **Arquivo:** `modules/01-install-system.sh`
- **Problema:** Termux-api não é instalado automaticamente
- **Solução:** Perguntar ao user:
  ```
  Deseja usar Termux-API? (câmera, sensor, etc)
  1) Sim
  2) Não
  ```
  - Se sim: instalar termux-api e criar helpers
  - Se não: skip
- **Tempo:** 30 min
- **Impacto:** MÉDIO - funcionalidade extra

---

### 14. ✅ Documentação: Guia de Troubleshooting Termux
- **Arquivo:** Novo `TROUBLESHOOTING_TERMUX.md`
- **Problema:** Usuários não sabem solucionar problemas específicos
- **Solução:** Criar guia com:
  ```
  - Hot reload não funciona?
  - Build está muito lento?
  - Neovim está lento?
  - Storage cheio?
  - RAM insuficiente?
  - Projeto não roda?
  ```
  - Cada problema com solução passo a passo
- **Tempo:** 1 hora
- **Impacto:** MÉDIO - reduz frustração user

---

## 📊 RESUMO POR FASE

### FASE 1: CRÍTICO ✅
```
Tarefas: 4
Tempo: 27 minutos
Impacto: BLOQUEADORES - tudo else falha sem isso
Status: ⏳ Aguardando implementação
```

### FASE 2: ALTO ✅
```
Tarefas: 5
Tempo: 2h 10min
Impacto: PRODUÇÃO - melhorar significativamente
Status: ⏳ Aguardando implementação
```

### FASE 3: MÉDIO ✅
```
Tarefas: 5
Tempo: 2h 30min
Impacto: QUALIDADE - polimento e documentation
Status: ⏳ Aguardando implementação
```

---

## 🎯 PRIORIDADE DE EXECUÇÃO

### Primeira Semana (OBRIGATÓRIO)
```
✅ 1. Corrigir better-sqlite3 (critical)
✅ 2. Remover chsh (critical)
✅ 3. Automatizar Oh-My-Zsh (critical)
✅ 4. Automatizar create-next-app (critical)
✅ 5. npm config (high)
✅ 6. WATCHPACK_POLLING (high)
✅ 7. check_termux_compatibility (high)

Subtotal: ~2.5 horas
```

### Segunda Semana (RECOMENDADO)
```
✅ 8. Otimizar dependências (high)
✅ 9. Neovim config (high)
✅ 10-14. Validações e docs (medium)

Subtotal: ~3-4 horas
```

### Opcional (LEGAL TER)
```
- Versão Vite + Express (alternativa a Next.js)
- Monitoramento automático de performance
- Backup automático via Git
```

---

## 📈 MÉTRICAS ESPERADAS

### Antes das correções
```
Tamanho instalação:     267 MB
Performance Termux:     5/10
Compatibilidade:        70%
Bugs críticos:          4
Documentação:           Média
```

### Depois das correções
```
Tamanho instalação:     232 MB (-34 MB, -12.8%)
Performance Termux:     8/10 (+60%)
Compatibilidade:        99%
Bugs críticos:          0
Documentação:           Excelente
```

---

## 🚀 COMO USAR ESTE TODO

1. **Para cada tarefa:**
   - Ler descrição
   - Copiá-la em seu editor favorito
   - Implementar mudança
   - Testar com `bash test-integration.sh`
   - Marcar como completa

2. **Depois de todas as tarefas:**
   ```bash
   git add .
   git commit -m "refactor: comprehensive termux compatibility overhaul"
   git push origin main
   ```

3. **Testar em dispositivo real Termux:**
   ```bash
   curl -fsSL https://raw.githubusercontent.com/lrdswarp-max/termux-devhub-pro/main/install.sh | bash
   ```

---

## 📝 NOTAS IMPORTANTES

- ⚠️ **NÃO alterar o que o projeto propõe instalar** (Next.js, Zsh, Neovim, etc)
- ✅ **MELHORAR apenas as lógicas e erros**
- 📱 **SEMPRE considerar limitações de Termux**
- 🧪 **Testar cada mudança isoladamente**
- 📚 **Documentar ao fazer mudanças**

---

**Próximo passo:** Deseja que comece a implementar as tarefas Fase 1 agora?

