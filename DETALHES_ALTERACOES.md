# 📝 Detalhes das Alterações - Código Não Será Alterado

Este documento mostra **EXATAMENTE** o que será alterado em cada arquivo para manter o propósito original intacto.

## 🎯 Princípio: LÓGICA SIM, PROPÓSITO NÃO

**O Projeto instala:**
- ✅ Node.js
- ✅ pnpm
- ✅ Zsh
- ✅ Neovim
- ✅ Tmux
- ✅ Next.js 15
- ✅ Tailwind CSS
- ✅ Database (SQLite)
- ✅ Drizzle ORM
- ✅ Comando devhub

**Nada disso mudará.** Apenas: **COMO** é instalado.

---

## 📂 Arquivo 1: `modules/05-create-project.sh`

### Mudança 1.1: Trocar `better-sqlite3` por `sqlite`

**ANTES (Linha 47):**
```bash
pnpm add next-pwa better-sqlite3 drizzle-orm 2>&1 | tee -a "$INSTALL_LOG" || {
```

**DEPOIS:**
```bash
pnpm add next-pwa sqlite drizzle-orm 2>&1 | tee -a "$INSTALL_LOG" || {
```

**Por quê?** `better-sqlite3` requer compilação, `sqlite` é puro JavaScript.  
**O que muda?** Nada. Ainda tem database SQLite.  
**Propósito?** Mantido ✅

---

**ANTES (Linhas 60-61):**
```typescript
import { drizzle } from 'drizzle-orm/better-sqlite3'
import Database from 'better-sqlite3'
```

**DEPOIS:**
```typescript
import { drizzle } from 'drizzle-orm/node-sqlite'
import Database from 'sqlite'
```

**Por quê?** Usar driver compatível com `sqlite`.  
**O que muda?** Apenas o driver, mesma funcionalidade.  
**Propósito?** Mantido ✅

---

### Mudança 1.2: Automatizar `create-next-app`

**ANTES (Linha 32):**
```bash
pnpm create next-app@latest devhub-pwa \
    --typescript \
    --tailwind \
    --eslint \
    --app \
    --no-git \
    --import-alias '@/*' 2>&1 | tee -a "$INSTALL_LOG" || {
```

**DEPOIS:**
```bash
echo "" | pnpm create next-app@latest devhub-pwa \
    --typescript \
    --tailwind \
    --eslint \
    --app \
    --no-git \
    --import-alias '@/*' 2>&1 | tee -a "$INSTALL_LOG" || {
```

**Por quê?** `echo "" |` redireciona entrada vazia para suprimir prompts.  
**O que muda?** Nenhuma flag, nenhuma configuração, apenas redirecionamento.  
**Propósito?** Mantido ✅

---

### Mudança 1.3: Melhorar validação de `git init`

**ANTES (Linhas 80-82):**
```bash
git init 2>&1 | tee -a "$INSTALL_LOG" || log "WARN" "Git já inicializado"
git add . 2>&1 | tee -a "$INSTALL_LOG" || true
git commit -m "feat: initial commit - DevHub Pro PWA" 2>&1 | tee -a "$INSTALL_LOG" || true
```

**DEPOIS:**
```bash
if git init 2>&1 | tee -a "$INSTALL_LOG"; then
    if git add . 2>&1 | tee -a "$INSTALL_LOG"; then
        if git commit -m "feat: initial commit - DevHub Pro PWA" 2>&1 | tee -a "$INSTALL_LOG"; then
            log "SUCCESS" "Repositório Git inicializado"
        else
            log "WARN" "Git commit falhou (continuando...)"
        fi
    else
        log "WARN" "Git add falhou (continuando...)"
    fi
else
    log "WARN" "Git não foi inicializado (continuando...)"
fi
```

**Por quê?** Melhor tratamento de erros, sem silenciar falhas com `|| true`.  
**O que muda?** Apenas lógica de validação e logging.  
**Propósito?** Mantido ✅ (Git ainda é inicializado)

---

## 📂 Arquivo 2: `modules/03-configure-shell.sh`

### Mudança 2.1: Remover `chsh`

**ANTES (Linhas 27-30):**
```bash
# Mudar shell padrão para Zsh
if [[ "$SHELL" != *"zsh"* ]]; then
    log "INFO" "Mudando shell padrão para Zsh..."
    chsh -s zsh || log "WARN" "Falha ao mudar shell (continuando...)"
fi
```

**DEPOIS:**
```bash
# No Termux, chsh não funciona (sem /etc/passwd)
# Shell padrão pode ser mudado apenas criando ~/.zshrc
# que será carregado como shell interativo
log "INFO" "Shell Zsh disponível. Use em ~/.bashrc: [[ -f ~/.zshrc ]] && exec zsh"
```

**Por quê?** `chsh` não funciona em Termux, comando falha silenciosamente.  
**O que muda?** Zsh ainda é instalado, apenas não é forçado como shell.  
**Propósito?** Mantido ✅ (Zsh instalado e funcional)

---

### Mudança 2.2: Automatizar Oh-My-Zsh

**ANTES (Linhas 37-42):**
```bash
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    log "INFO" "Instalando Oh-My-Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended 2>&1 | tee -a "$INSTALL_LOG" || {
        log "ERROR" "Falha ao instalar Oh-My-Zsh"
        exit 1
    }
    log "SUCCESS" "Oh-My-Zsh instalado"
fi
```

**DEPOIS:**
```bash
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    log "INFO" "Instalando Oh-My-Zsh..."
    echo "" | sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended 2>&1 | tee -a "$INSTALL_LOG" || {
        log "ERROR" "Falha ao instalar Oh-My-Zsh"
        exit 1
    }
    log "SUCCESS" "Oh-My-Zsh instalado"
fi
```

**Por quê?** `echo "" |` redireciona entrada vazia para evitar prompts.  
**O que muda?** Nada no resultado final, apenas entrada redirecionada.  
**Propósito?** Mantido ✅ (Oh-My-Zsh instalado)

---

## 📂 Arquivo 3: `modules/04-configure-tools.sh`

### Mudança 3.1: Validar vim-plug

**ANTES (Linhas 70-76):**
```bash
if [[ ! -f "$HOME/.config/nvim/autoload/plug.vim" ]]; then
    log "INFO" "Instalando vim-plug..."
    curl -fLo "$HOME/.config/nvim/autoload/plug.vim" --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim 2>&1 | tee -a "$INSTALL_LOG" || {
        log "WARN" "Falha ao instalar vim-plug (continuando...)"
    }
fi
```

**DEPOIS:**
```bash
if [[ ! -f "$HOME/.config/nvim/autoload/plug.vim" ]]; then
    log "INFO" "Instalando vim-plug..."
    mkdir -p "$HOME/.config/nvim/autoload"
    
    if curl -fLo "$HOME/.config/nvim/autoload/plug.vim" \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim 2>&1 | tee -a "$INSTALL_LOG"; then
        log "SUCCESS" "vim-plug instalado"
    else
        log "WARN" "Falha ao instalar vim-plug (Neovim funcionará sem plugins)"
    fi
else
    log "SUCCESS" "vim-plug já estava instalado"
fi
```

**Por quê?** Melhor validação e feedback do que aconteceu.  
**O que muda?** Apenas logging e tratamento de erro.  
**Propósito?** Mantido ✅ (Neovim ainda instalado, vim-plug é opcional)

---

## 📂 Arquivo 4: `modules/02-install-nodejs.sh`

### Mudança 4.1: Configurar npm-cache

**ANTES (Linhas 18-22):**
```bash
# Instalar pnpm globalmente
log "INFO" "Instalando pnpm..."
npm install -g pnpm || { log "ERROR" "Falha ao instalar pnpm"; exit 1; }

log "SUCCESS" "pnpm instalado: $(pnpm --version)"
```

**DEPOIS:**
```bash
# Configurar npm para evitar problemas de permissão
log "INFO" "Configurando npm-cache..."
if ! npm config get prefix | grep -q "$HOME"; then
    npm config set prefix "$HOME/.npm-global" 2>/dev/null || true
fi

# Instalar pnpm globalmente
log "INFO" "Instalando pnpm..."
npm install -g pnpm || { log "ERROR" "Falha ao instalar pnpm"; exit 1; }

# Adicionar ao PATH se não estiver
if ! grep -q "npm-global" "$HOME/.bashrc" 2>/dev/null; then
    echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> "$HOME/.bashrc"
fi

log "SUCCESS" "pnpm instalado: $(pnpm --version)"
```

**Por quê?** Previne falhas de permissão com npm install -g.  
**O que muda?** Apenas configuração do npm, nada no resultado final.  
**Propósito?** Mantido ✅ (pnpm instalado)

---

## 📂 Arquivo 5: `modules/06-create-devhub-command.sh`

### Mudança 5.1: Garantir PATH

**ANTES (Linhas 99-108):**
```bash
# Adicionar ao PATH em .bashrc
log "INFO" "Adicionando ~/.local/bin ao PATH em .bashrc..."
if ! grep -q "$HOME/.local/bin" "$HOME/.bashrc" 2>/dev/null; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
    log "SUCCESS" "PATH adicionado ao .bashrc"
fi

# Adicionar ao PATH em .zshrc
log "INFO" "Adicionando ~/.local/bin ao PATH em .zshrc..."
if ! grep -q "$HOME/.local/bin" "$HOME/.zshrc" 2>/dev/null; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"
    log "SUCCESS" "PATH adicionado ao .zshrc"
fi
```

**DEPOIS:**
```bash
# Adicionar ao PATH em .bashrc
log "INFO" "Adicionando ~/.local/bin ao PATH em .bashrc..."
if ! grep -q "$HOME/.local/bin" "$HOME/.bashrc" 2>/dev/null; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
    log "SUCCESS" "PATH adicionado ao .bashrc"
fi

# Adicionar ao PATH em .zshrc
log "INFO" "Adicionando ~/.local/bin ao PATH em .zshrc..."
if ! grep -q "$HOME/.local/bin" "$HOME/.zshrc" 2>/dev/null; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"
    log "SUCCESS" "PATH adicionado ao .zshrc"
fi

# Export PATH imediatamente para scripts subsequentes
export PATH="$HOME/.local/bin:$PATH"
log "INFO" "PATH exportado para sessão atual"
```

**Por quê?** Garante que `devhub` pode ser encontrado imediatamente.  
**O que muda?** Apenas export de PATH, sem alterar configuração.  
**Propósito?** Mantido ✅ (devhub command disponível)

---

## 📊 RESUMO DE ALTERAÇÕES

| Arquivo | Mudança | Tipo | Propósito Mantido |
|---------|---------|------|------------------|
| 05-create-project.sh | Trocar sqlite | LÓGICA | ✅ SIM |
| 05-create-project.sh | Automatizar create-app | LÓGICA | ✅ SIM |
| 05-create-project.sh | Validação git | LÓGICA | ✅ SIM |
| 03-configure-shell.sh | Remover chsh | LÓGICA | ✅ SIM |
| 03-configure-shell.sh | Automatizar Oh-My-Zsh | LÓGICA | ✅ SIM |
| 04-configure-tools.sh | Validar vim-plug | LÓGICA | ✅ SIM |
| 02-install-nodejs.sh | npm-cache config | LÓGICA | ✅ SIM |
| 06-create-devhub-command.sh | Export PATH | LÓGICA | ✅ SIM |

---

## ✅ CONFIRMAÇÃO

Todas as mudanças são:
- ✅ Lógica interna (sem alterar o que é instalado)
- ✅ Tratamento de erros (melhorando robustez)
- ✅ Simplificações (removendo comandos que não funcionam)
- ✅ Validações (melhorando feedback)

**NENHUMA mudança afeta o propósito original do projeto.**

---

**Data:** 7 de Fevereiro de 2026  
**Versão:** 1.0  
**Status:** Documentado para implementação ✅
