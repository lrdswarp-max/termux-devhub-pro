#!/bin/bash
#
# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║                    TERMUX DEVHUB PRO - INSTALLER v3.0                        ║
# ║                    Otimizado, Nativo, Sem proot                               ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# Arquitetura: Termux Nativo (sem proot-distro)
# Stack: Node.js + NVIM + Tmux + Next.js + Supabase
# Tempo estimado: 15-20 minutos
# Autor: Revisão Otimizada
#

set -euo pipefail

# ═══════════════════════════════════════════════════════════════════════════════
# CONFIGURAÇÕES GLOBAIS
# ═══════════════════════════════════════════════════════════════════════════════

readonly SCRIPT_VERSION="3.0.0"
readonly INSTALL_DIR="$HOME/.devhub"
readonly LOG_FILE="$INSTALL_DIR/install.log"
readonly STATE_FILE="$INSTALL_DIR/state.json"
readonly PROJECTS_DIR="$HOME/projects"
readonly BACKUP_DIR="$INSTALL_DIR/backups"

# Cores para output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m' # No Color

# Spinner para operações longas
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# ═══════════════════════════════════════════════════════════════════════════════
# SISTEMA DE LOG E ESTADO
# ═══════════════════════════════════════════════════════════════════════════════

init_logging() {
    mkdir -p "$INSTALL_DIR" "$BACKUP_DIR" "$PROJECTS_DIR"
    echo "{\"version\": \"$SCRIPT_VERSION\", \"start_time\": \"$(date -Iseconds)\", \"status\": \"running\"}" > "$STATE_FILE"
    exec 1> >(tee -a "$LOG_FILE")
    exec 2>&1
}

log() {
    echo -e "${BLUE}[$(date '+%H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}✓${NC} $1"
}

warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

error() {
    echo -e "${RED}✗${NC} $1"
}

info() {
    echo -e "${CYAN}ℹ${NC} $1"
}

save_state() {
    local phase="$1"
    local status="$2"
    local message="${3:-}"

    local tmp_file=$(mktemp)
    jq --arg phase "$phase" \
       --arg status "$status" \
       --arg message "$message" \
       --arg time "$(date -Iseconds)" \
       '.phases += [{phase: $phase, status: $status, message: $message, time: $time}]' \
       "$STATE_FILE" > "$tmp_file" && mv "$tmp_file" "$STATE_FILE"
}

# ═══════════════════════════════════════════════════════════════════════════════
# VALIDAÇÕES INICIAIS
# ═══════════════════════════════════════════════════════════════════════════════

check_termux() {
    log "Verificando ambiente Termux..."

    if [[ -z "${PREFIX:-}" ]] || [[ ! "$PREFIX" =~ "com.termux" ]]; then
        error "Este script deve ser executado dentro do Termux!"
        exit 1
    fi

    if [[ "$(uname -m)" != "aarch64" ]]; then
        warning "Arquitetura não é aarch64. Alguns pacotes podem não estar disponíveis."
    fi

    # Verificar espaço (mínimo 5GB)
    local available=$(df -BG "$HOME" | tail -1 | awk '{print $4}' | tr -d 'G')
    if [[ "$available" -lt 5 ]]; then
        error "Espaço insuficiente. Necessário: 5GB, Disponível: ${available}GB"
        exit 1
    fi
    success "Espaço disponível: ${available}GB"

    # Verificar internet
    if ! ping -c 1 -W 3 google.com &>/dev/null; then
        error "Sem conexão com a internet!"
        exit 1
    fi
    success "Conectividade OK"

    save_state "pre_check" "success" "Ambiente validado"
}

# ═══════════════════════════════════════════════════════════════════════════════
# FASE 1: SISTEMA BASE E DEPENDÊNCIAS (3-5 min)
# ═══════════════════════════════════════════════════════════════════════════════

phase1_system_base() {
    log "\n${PURPLE}═══════════════════════════════════════════════════════════════${NC}"
    log "${PURPLE}  FASE 1/4: Sistema Base e Dependências${NC}"
    log "${PURPLE}═══════════════════════════════════════════════════════════════${NC}\n"

    # Atualizar repositórios
    log "Atualizando repositórios..."
    (pkg update -y && pkg upgrade -y) &
    spinner $!
    wait $!
    success "Repositórios atualizados"

    # Instalar pacotes essenciais
    log "Instalando pacotes essenciais..."
    local packages=(
        git curl wget unzip zip
        nodejs-lts npm
        neovim python
        tmux zsh
        openssh gh
        ripgrep fd
        fzf bat
        termux-api
    )

    pkg install -y "${packages[@]}" &
    spinner $!
    wait $!
    success "Pacotes instalados: ${#packages[@]}"

    # Configurar storage
    if [[ ! -d "$HOME/storage" ]]; then
        log "Configurando acesso ao storage..."
        termux-setup-storage
        sleep 2
    fi

    save_state "phase1" "success" "Sistema base instalado"
    success "Fase 1 concluída"
}

# ═══════════════════════════════════════════════════════════════════════════════
# FASE 2: NODE.JS ECOSYSTEM (3-5 min)
# ═══════════════════════════════════════════════════════════════════════════════

phase2_nodejs() {
    log "\n${PURPLE}═══════════════════════════════════════════════════════════════${NC}"
    log "${PURPLE}  FASE 2/4: Node.js Ecosystem${NC}"
    log "${PURPLE}═══════════════════════════════════════════════════════════════${NC}\n"

    # Verificar Node.js
    log "Verificando Node.js..."
    if command -v node &>/dev/null; then
        local node_version=$(node --version)
        success "Node.js detectado: $node_version"
    else
        error "Node.js não encontrado após instalação"
        exit 1
    fi

    # Instalar pnpm (mais rápido que npm/yarn)
    log "Instalando pnpm..."
    if ! command -v pnpm &>/dev/null; then
        npm install -g pnpm
        success "pnpm instalado"
    else
        success "pnpm já instalado"
    fi

    # Configurar pnpm
    export PNPM_HOME="$HOME/.local/share/pnpm"
    export PATH="$PNPM_HOME:$PATH"

    # Criar diretório se não existir
    mkdir -p "$PNPM_HOME"

    # Instalar pacotes globais essenciais
    log "Instalando ferramentas globais..."
    local global_packages=(
        typescript
        tsx
        @vercel/cli
        supabase
        npm-check-updates
    )

    pnpm add -g "${global_packages[@]}" 2>&1 | while read line; do
        echo -n "."
    done
    echo
    success "Ferramentas globais instaladas"

    # Adicionar ao .bashrc se não existir
    if ! grep -q "PNPM_HOME" "$HOME/.bashrc" 2>/dev/null; then
        cat >> "$HOME/.bashrc" << 'EOF'

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"
EOF
    fi

    save_state "phase2" "success" "Node.js ecosystem configurado"
    success "Fase 2 concluída"
}

# ═══════════════════════════════════════════════════════════════════════════════
# FASE 3: DEV ENVIRONMENT (NVIM + TMUX + ZSH) (5-7 min)
# ═══════════════════════════════════════════════════════════════════════════════

phase3_dev_environment() {
    log "\n${PURPLE}═══════════════════════════════════════════════════════════════${NC}"
    log "${PURPLE}  FASE 3/4: Ambiente de Desenvolvimento${NC}"
    log "${PURPLE}═══════════════════════════════════════════════════════════════${NC}\n"

    # Configurar Zsh como shell padrão
    log "Configurando Zsh..."
    if [[ "$SHELL" != *"zsh"* ]]; then
        chsh -s zsh
        success "Zsh configurado como shell padrão"
    fi

    # Instalar Oh-My-Zsh (se não existir)
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        log "Instalando Oh-My-Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        success "Oh-My-Zsh instalado"
    fi

    # Configurar Tmux
    log "Configurando Tmux..."
    cat > "$HOME/.tmux.conf" << 'EOF'
# Termux DevHub Tmux Config
set -g default-terminal "screen-256color"
set -g mouse on
set -g base-index 1
set -g pane-base-index 1
set -g history-limit 10000

# Key bindings
bind | split-window -h
bind - split-window -v
bind r source-file ~/.tmux.conf

# Status bar
set -g status-style bg=colour235,fg=colour136
set -g status-left "#[fg=colourgreen]#S "
set -g status-right "#[fg=colourcyan]%H:%M"
EOF
    success "Tmux configurado"

    # Configurar NVIM (LazyVim-inspired minimal)
    log "Configurando Neovim..."
    mkdir -p "$HOME/.config/nvim/lua/plugins"

    # init.lua simplificado para Termux
    cat > "$HOME/.config/nvim/init.lua" << 'EOF'
-- Termux DevHub NVIM Config - Minimal & Fast
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.termguicolors = true
vim.opt.background = "dark"

-- Leader key
vim.g.mapleader = " "

-- Plugins (vim-plug simplificado)
local vim = vim
local Plug = vim.fn['plug#']

vim.call('plug#begin', '~/.config/nvim/plugged')

Plug('nvim-treesitter/nvim-treesitter', {['do'] = ':TSUpdate'})
Plug('neovim/nvim-lspconfig')
Plug('hrsh7th/nvim-cmp')
Plug('hrsh7th/cmp-nvim-lsp')
Plug('nvim-lua/plenary.nvim')
Plug('nvim-telescope/telescope.nvim')
Plug('nvim-tree/nvim-tree.lua')
Plug('folke/tokyonight.nvim')
Plug('tpope/vim-fugitive')
Plug('akinsho/toggleterm.nvim')

vim.call('plug#end')

-- Theme
vim.cmd [[colorscheme tokyonight]]

-- Keymaps
vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>')
vim.keymap.set('n', '<leader>f', ':Telescope find_files<CR>')
vim.keymap.set('n', '<leader>g', ':Telescope live_grep<CR>')
vim.keymap.set('n', '<leader>t', ':ToggleTerm<CR>')

-- LSP básico
local lspconfig = require('lspconfig')
lspconfig.tsserver.setup{}
lspconfig.eslint.setup{}
lspconfig.jsonls.setup{}
lspconfig.cssls.setup{}
lspconfig.html.setup{}

-- Completion básico
local cmp = require('cmp')
cmp.setup({
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
  }),
  mapping = cmp.mapping.preset.insert({
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  }),
})
EOF

    # Instalar vim-plug
    log "Instalando vim-plug..."
    curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

    success "Neovim configurado"
    info "Na primeira vez que abrir nvim, execute :PlugInstall"

    # Criar aliases úteis
    cat >> "$HOME/.bashrc" << 'EOF'

# DevHub Aliases
alias vim='nvim'
alias vi='nvim'
alias t='tmux'
alias ta='tmux attach'
alias tn='tmux new-session'
alias ..='cd ..'
alias ...='cd ../..'
alias ll='ls -la'
alias gs='git status'
alias gp='git pull'
alias gP='git push'
alias gc='git commit'
alias gco='git checkout'
alias dev='cd ~/projects && ls'
EOF

    save_state "phase3" "success" "Ambiente dev configurado"
    success "Fase 3 concluída"
}

# ═══════════════════════════════════════════════════════════════════════════════
# FASE 4: PROJETO NEXT.JS PWA (3-5 min)
# ═══════════════════════════════════════════════════════════════════════════════

phase4_project() {
    log "\n${PURPLE}═══════════════════════════════════════════════════════════════${NC}"
    log "${PURPLE}  FASE 4/4: Projeto Next.js PWA${NC}"
    log "${PURPLE}═══════════════════════════════════════════════════════════════${NC}\n"

    local project_name="devhub-pwa"
    local project_path="$PROJECTS_DIR/$project_name"

    if [[ -d "$project_path" ]]; then
        warning "Projeto já existe em $project_path"
        read -p "Recriar? (s/N): " recreate
        if [[ "$recreate" =~ ^[Ss]$ ]]; then
            rm -rf "$project_path"
        else
            save_state "phase4" "skipped" "Projeto já existente"
            success "Fase 4 pulada"
            return
        fi
    fi

    log "Criando projeto Next.js..."
    cd "$PROJECTS_DIR"

    # Criar com create-next-app
    echo "my-app" | npx create-next-app@latest "$project_name" \
        --typescript \
        --tailwind \
        --eslint \
        --app \
        --src-dir \
        --import-alias "@/*" \
        --use-npm \
        --yes 2>&1 | while read line; do
            echo -n "."
        done
    echo

    cd "$project_path"

    # Instalar dependências adicionais
    log "Instalando dependências PWA..."
    pnpm add \
        next-pwa \
        @ducanh2912/next-pwa \
        drizzle-orm \
        better-sqlite3 \
        @supabase/supabase-js \
        @supabase/auth-helpers-nextjs \
        zustand \
        zod \
        react-hook-form \
        @hookform/resolvers \
        lucide-react \
        class-variance-authority \
        clsx \
        tailwind-merge 2>&1 | while read line; do
            echo -n "."
        done
    echo

    pnpm add -D \
        @types/better-sqlite3 \
        drizzle-kit \
        prettier \
        prettier-plugin-tailwindcss 2>&1 | while read line; do
            echo -n "."
        done
    echo

    # Configurar PWA
    log "Configurando PWA..."
    cat > next.config.js << 'EOF'
const withPWA = require('@ducanh2912/next-pwa').default({
  dest: 'public',
  register: true,
  skipWaiting: true,
  disable: process.env.NODE_ENV === 'development',
  fallbacks: {
    document: '/offline',
  },
})

/** @type {import('next').NextConfig} */
const nextConfig = {
  experimental: {
    typedRoutes: true,
  },
}

module.exports = withPWA(nextConfig)
EOF

    # Criar manifest.json
    cat > public/manifest.json << 'EOF'
{
  "name": "DevHub PWA",
  "short_name": "DevHub",
  "description": "Development Environment on Mobile",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#0f172a",
  "theme_color": "#3b82f6",
  "orientation": "portrait",
  "icons": [
    {
      "src": "/icon-192x192.png",
      "sizes": "192x192",
      "type": "image/png"
    },
    {
      "src": "/icon-512x512.png",
      "sizes": "512x512",
      "type": "image/png"
    }
  ]
}
EOF

    # Configurar Drizzle
    mkdir -p src/db
    cat > src/db/index.ts << 'EOF'
import { drizzle } from 'drizzle-orm/better-sqlite3'
import Database from 'better-sqlite3'

const sqlite = new Database('./sqlite.db')
export const db = drizzle(sqlite)
EOF

    cat > src/db/schema.ts << 'EOF'
import { sqliteTable, text, integer } from 'drizzle-orm/sqlite-core'

export const users = sqliteTable('users', {
  id: integer('id').primaryKey(),
  email: text('email').notNull().unique(),
  name: text('name'),
  createdAt: integer('created_at', { mode: 'timestamp' }).$defaultFn(() => new Date()),
})
EOF

    # Criar arquivo de ambiente
    cat > .env.local << 'EOF'
# Database
DATABASE_URL="file:./sqlite.db"

# Supabase (preencher após criar projeto)
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=

# App
NEXT_PUBLIC_APP_URL="http://localhost:3000"
EOF

    # Criar página offline
    mkdir -p src/app/offline
    cat > src/app/offline/page.tsx << 'EOF'
export default function OfflinePage() {
  return (
    <div className="flex min-h-screen flex-col items-center justify-center p-4 text-center">
      <h1 className="text-4xl font-bold text-gray-900 dark:text-white mb-4">
        Você está offline
      </h1>
      <p className="text-lg text-gray-600 dark:text-gray-300">
        Verifique sua conexão com a internet e tente novamente.
      </p>
    </div>
  )
}
EOF

    # Inicializar git
    git init
    git add .
    git commit -m "Initial commit: Next.js PWA setup"

    # Criar script devhub
    mkdir -p "$HOME/.local/bin"
    cat > "$HOME/.local/bin/devhub" << 'SCRIPT'
#!/bin/bash
# DevHub CLI Menu

CYAN='\033[0;36m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

clear
echo -e "${CYAN}"
cat << "LOGO"
╔═══════════════════════════════════════════╗
║  DevHub PWA - Terminal IDE                ║
╚═══════════════════════════════════════════╝
LOGO
echo -e "${NC}"

cd "$HOME/projects/devhub-pwa" 2>/dev/null || cd "$HOME/projects" 2>/dev/null

while true; do
    echo -e "${YELLOW}$(date '+%H:%M:%S')${NC} | ${GREEN}DevHub${NC} | ${CYAN}$(pwd)${NC}"
    echo ""
    echo "  1) 🚀  Iniciar servidor dev"
    echo "  2) 📦  Instalar dependências"
    echo "  3) 🏗️   Build de produção"
    echo "  4) ☁️   Deploy na Vercel"
    echo "  5) 🗄️   Database (Drizzle)"
    echo "  6) 📝  Abrir no Neovim"
    echo "  7) 🔄  Git status"
    echo "  8) 📊  Monitor (htop)"
    echo "  0) 🚪  Sair"
    echo ""
    read -p "Escolha: " choice

    case $choice in
        1) pnpm dev ;;
        2) pnpm install ;;
        3) pnpm build ;;
        4) vercel --prod ;;
        5) pnpm drizzle-kit studio ;;
        6) nvim . ;;
        7) git status ;;
        8) htop ;;
        0) break ;;
        *) echo -e "${RED}Opção inválida${NC}" ;;
    esac

    echo ""
    read -p "Pressione ENTER..."
    clear
done
SCRIPT
    chmod +x "$HOME/.local/bin/devhub"

    # Adicionar ao PATH se necessário
    if ! grep -q "$HOME/.local/bin" "$HOME/.bashrc"; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
    fi

    save_state "phase4" "success" "Projeto criado em $project_path"
    success "Fase 4 concluída"

    log "\n${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    log "${GREEN}  ✓ Projeto criado em: $project_path${NC}"
    log "${GREEN}  ✓ Comando devhub disponível${NC}"
    log "${GREEN}  ✓ Execute 'devhub' para iniciar${NC}"
    log "${GREEN}═══════════════════════════════════════════════════════════════${NC}\n"
}

# ═══════════════════════════════════════════════════════════════════════════════
# VALIDAÇÃO FINAL
# ═══════════════════════════════════════════════════════════════════════════════

final_check() {
    log "\n${PURPLE}═══════════════════════════════════════════════════════════════${NC}"
    log "${PURPLE}  VALIDAÇÃO FINAL${NC}"
    log "${PURPLE}═══════════════════════════════════════════════════════════════${NC}\n"

    local checks_passed=0
    local checks_total=8

    # Check 1: Node.js
    if command -v node &>/dev/null; then
        success "Node.js: $(node --version)"
        ((checks_passed++))
    else
        error "Node.js não encontrado"
    fi

    # Check 2: pnpm
    if command -v pnpm &>/dev/null; then
        success "pnpm: $(pnpm --version)"
        ((checks_passed++))
    else
        error "pnpm não encontrado"
    fi

    # Check 3: Git
    if command -v git &>/dev/null; then
        success "Git: $(git --version | cut -d' ' -f3)"
        ((checks_passed++))
    else
        error "Git não encontrado"
    fi

    # Check 4: Neovim
    if command -v nvim &>/dev/null; then
        success "Neovim: $(nvim --version | head -1)"
        ((checks_passed++))
    else
        error "Neovim não encontrado"
    fi

    # Check 5: Tmux
    if command -v tmux &>/dev/null; then
        success "Tmux: $(tmux -V)"
        ((checks_passed++))
    else
        error "Tmux não encontrado"
    fi

    # Check 6: Vercel CLI
    if command -v vercel &>/dev/null; then
        success "Vercel CLI instalado"
        ((checks_passed++))
    else
        error "Vercel CLI não encontrado"
    fi

    # Check 7: Projeto
    if [[ -d "$PROJECTS_DIR/devhub-pwa" ]]; then
        success "Projeto devhub-pwa existe"
        ((checks_passed++))
    else
        error "Projeto não encontrado"
    fi

    # Check 8: DevHub CLI
    if [[ -x "$HOME/.local/bin/devhub" ]]; then
        success "Comando 'devhub' disponível"
        ((checks_passed++))
    else
        error "Comando devhub não encontrado"
    fi

    log "\n${CYAN}Resultado: $checks_passed/$checks_total verificações passaram${NC}"

    if [[ $checks_passed -eq $checks_total ]]; then
        save_state "final_check" "success" "Todas as verificações passaram"
        return 0
    else
        save_state "final_check" "partial" "$checks_passed de $checks_total passaram"
        return 1
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════════════════════

main() {
    clear
    echo -e "${CYAN}"
    cat << "BANNER"
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║           TERMUX DEVHUB PRO v3.0 - INSTALLER                   ║
║                                                                ║
║   ⚡ Nativo | 🚀 Rápido | 🎯 Otimizado | 🤖 AI-Ready          ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
BANNER
    echo -e "${NC}"

    log "Iniciando instalação..."
    log "Log salvo em: $LOG_FILE"
    log ""

    # Inicializar
    init_logging

    # Verificações
    check_termux

    # Fases de instalação
    phase1_system_base
    phase2_nodejs
    phase3_dev_environment
    phase4_project

    # Validação final
    if final_check; then
        echo ""
        log "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
        log "${GREEN}  🎉 INSTALAÇÃO CONCLUÍDA COM SUCESSO!${NC}"
        log "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
        echo ""
        log "Próximos passos:"
        log "  1. Reinicie o Termux ou execute: source ~/.bashrc"
        log "  2. Execute: ${YELLOW}devhub${NC} para iniciar o menu"
        log "  3. Ou vá direto: cd ~/projects/devhub-pwa && pnpm dev"
        echo ""
        log "Recursos disponíveis:"
        log "  • ${CYAN}nvim${NC} - Editor de código"
        log "  • ${CYAN}tmux${NC} - Sessões persistentes"
        log "  • ${CYAN}vercel${NC} - Deploy na nuvem"
        log "  • ${CYAN}supabase${NC} - Database"
        echo ""
        log "Documentação: ${YELLOW}cat $LOG_FILE${NC}"
        echo ""

        # Atualizar estado final
        jq '.status = "completed" | .end_time = "'$(date -Iseconds)'"' "$STATE_FILE" > "${STATE_FILE}.tmp" && mv "${STATE_FILE}.tmp" "$STATE_FILE"

        exit 0
    else
        echo ""
        error "Algumas verificações falharam. Verifique o log: $LOG_FILE"
        exit 1
    fi
}

# Tratamento de erros
trap 'error "Instalação interrompida na linha $LINENO"; exit 1' ERR
trap 'error "Instalação cancelada pelo usuário"; exit 130' INT

# Executar
main "$@"
