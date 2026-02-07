# 🔧 Correções Sugeridas para DevHub Pro v3.0

## 1️⃣ CRÍTICO: Trocar `better-sqlite3` por alternativa compatível

### Problema
`better-sqlite3` requer compilação nativa (node-gyp), que frequentemente falha no Termux.

### Solução
Usar `sqlite3` (pacote npm puro em JavaScript) ou `sql.js`

**Arquivo:** `modules/05-create-project.sh`
**Linhas:** 47, 60-61

```bash
# ANTES:
pnpm add next-pwa better-sqlite3 drizzle-orm 2>&1 | tee -a "$INSTALL_LOG" || {

# DEPOIS:
pnpm add next-pwa sqlite drizzle-orm 2>&1 | tee -a "$INSTALL_LOG" || {
```

```typescript
// ANTES em src/db/index.ts:
import { drizzle } from 'drizzle-orm/better-sqlite3'
import Database from 'better-sqlite3'

// DEPOIS:
import { drizzle } from 'drizzle-orm/node-sqlite'
import Database from 'better-sqlite3'

// OU para evitar compilação:
// Use SQL.js em vez disso:
import { drizzle } from 'drizzle-orm/sql-js'
// E instale: pnpm add sql-js
```

---

## 2️⃣ CRÍTICO: Remover `chsh` e validar shell

### Problema
Termux não suporta `chsh` (sem `/etc/passwd`). O comando falha silenciosamente.

### Solução
Remover a tentativa de mudança de shell

**Arquivo:** `modules/03-configure-shell.sh`
**Linhas:** 27-30

```bash
# ANTES:
if [[ "$SHELL" != *"zsh"* ]]; then
    log "INFO" "Mudando shell padrão para Zsh..."
    chsh -s zsh || log "WARN" "Falha ao mudar shell (continuando...)"
fi

# DEPOIS:
# No Termux, o shell padrão pode ser mudado apenas editando ~/.zshrc
# A seguinte mensagem é informativa
if command -v zsh &> /dev/null; then
    log "INFO" "Zsh disponível. Para usar como padrão, defina em ~/.bashrc:"
    log "INFO" "if command -v zsh &> /dev/null; then exec zsh; fi"
fi
```

---

## 3️⃣ ALTO: Prevenir prompts interativos no Oh-My-Zsh

### Problema
O instalador do Oh-My-Zsh pode pedir confirmações mesmo com `--unattended`

### Solução
Usar redirecionamento de entrada

**Arquivo:** `modules/03-configure-shell.sh`
**Linhas:** 37-42

```bash
# ANTES:
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended 2>&1 | tee -a "$INSTALL_LOG" || {

# DEPOIS:
echo "" | sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended 2>&1 | tee -a "$INSTALL_LOG" || {
```

---

## 4️⃣ ALTO: Automatizar prompt do `create-next-app`

### Problema
`pnpm create next-app` faz perguntas interativas mesmo com todas as flags

### Solução
Redirecionar entrada vazia para responder automaticamente

**Arquivo:** `modules/05-create-project.sh`
**Linhas:** 32-40

```bash
# ANTES:
pnpm create next-app@latest devhub-pwa \
    --typescript \
    --tailwind \
    --eslint \
    --app \
    --no-git \
    --import-alias '@/*' 2>&1 | tee -a "$INSTALL_LOG" || {

# DEPOIS:
echo "" | pnpm create next-app@latest devhub-pwa \
    --typescript \
    --tailwind \
    --eslint \
    --app \
    --no-git \
    --import-alias '@/*' 2>&1 | tee -a "$INSTALL_LOG" || {
```

---

## 5️⃣ MÉDIO: Melhorar npm install para pnpm

### Problema
`npm install -g` pode falhar por permissões em alguns ambientes Termux

### Solução
Configurar npm-cache e PATH antes

**Arquivo:** `modules/02-install-nodejs.sh`
**Linhas:** 18-22

```bash
# ANTES:
log "INFO" "Instalando pnpm..."
npm install -g pnpm || { log "ERROR" "Falha ao instalar pnpm"; exit 1; }

# DEPOIS:
log "INFO" "Instalando pnpm..."
# Configurar npm para instalar globalmente em $HOME
if ! npm config get prefix | grep -q "$HOME"; then
    npm config set prefix "$HOME/.npm-global" 2>/dev/null || true
fi

npm install -g pnpm || { log "ERROR" "Falha ao instalar pnpm"; exit 1; }

# Garantir que npm-global está no PATH
if ! grep -q "npm-global" "$HOME/.bashrc" 2>/dev/null; then
    echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> "$HOME/.bashrc"
fi
```

---

## 6️⃣ MÉDIO: Melhorar tratamento de git init

### Problema
`git add` e `git commit` podem falhar silenciosamente com `|| true`

### Solução
Validar se git foi inicializado

**Arquivo:** `modules/05-create-project.sh`
**Linhas:** 80-82

```bash
# ANTES:
git init 2>&1 | tee -a "$INSTALL_LOG" || log "WARN" "Git já inicializado"
git add . 2>&1 | tee -a "$INSTALL_LOG" || true
git commit -m "feat: initial commit - DevHub Pro PWA" 2>&1 | tee -a "$INSTALL_LOG" || true

# DEPOIS:
if git init 2>&1 | tee -a "$INSTALL_LOG"; then
    if git add . 2>&1 | tee -a "$INSTALL_LOG"; then
        if git commit -m "feat: initial commit - DevHub Pro PWA" 2>&1 | tee -a "$INSTALL_LOG"; then
            log "SUCCESS" "Repositório Git inicializado"
        fi
    fi
else
    log "WARN" "Git não foi inicializado (continuando...)"
fi
```

---

## 7️⃣ BAIXO: Validar vim-plug

### Problema
Se curl falhar ao baixar vim-plug, o error é ignorado silenciosamente

### Solução
Verificar se plugin foi realmente instalado

**Arquivo:** `modules/04-configure-tools.sh`
**Linhas:** 70-76

```bash
# ANTES:
if [[ ! -f "$HOME/.config/nvim/autoload/plug.vim" ]]; then
    log "INFO" "Instalando vim-plug..."
    curl -fLo "$HOME/.config/nvim/autoload/plug.vim" --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim 2>&1 | tee -a "$INSTALL_LOG" || {
        log "WARN" "Falha ao instalar vim-plug (continuando...)"
    }
fi

# DEPOIS:
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

---

## 🚀 IMPACTO DAS CORREÇÕES

| Correção | Impacto | Necessário |
|----------|---------|----------|
| 1. Trocar sqlite | ✅ Elimina erros de compilação | SIM |
| 2. Remover chsh | ✅ Evita falhas silenciosas | SIM |
| 3. Automatizar Oh-My-Zsh | ✅ Previne travamento | SIM |
| 4. Automatizar create-next-app | ✅ Previne travamento | SIM |
| 5. npm config | ✅ Melhora compatibilidade | RECOMENDADO |
| 6. git init validação | ✅ Melhor logging | RECOMENDADO |
| 7. vim-plug validação | ✅ Melhor feedback | OPCIONAL |

