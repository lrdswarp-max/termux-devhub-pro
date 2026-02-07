#!/bin/bash
#
# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║                    TERMUX DEVHUB PRO v3.0 - SMART INSTALLER                  ║
# ║         Nativo • Otimizado • Auto-Recovery • Production Ready               ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
#  Instala ambiente PWA profissional em 15-20 minutos
#  Sem proot, 100% nativo, 3x mais rápido que soluções anteriores
#
#  Uso: curl -fsSL url.com/install.sh | bash
#       ou: bash install.sh
#

set -euo pipefail
shopt -s inherit_errexit

# ═══════════════════════════════════════════════════════════════════════════════
# METADADOS
# ═══════════════════════════════════════════════════════════════════════════════
readonly VERSION="3.0.0"
readonly CODENAME="NATIVE"
readonly INSTALL_DIR="${HOME}/.devhub"
readonly LOG_FILE="${INSTALL_DIR}/install.log"
readonly STATE_FILE="${INSTALL_DIR}/state.json"
readonly LOCK_FILE="${INSTALL_DIR}/install.lock"
readonly PROJECT_DIR="${HOME}/projects/devhub-pwa"

# ═══════════════════════════════════════════════════════════════════════════════
# PALETA DE CORES (True Color support check)
# ═══════════════════════════════════════════════════════════════════════════════
if [[ -t 1 && "${TERM}" =~ (xterm|screen|tmux).* ]]; then
    readonly C_RESET='\e[0m'
    readonly C_BOLD='\e[1m'
    readonly C_DIM='\e[2m'
    readonly C_RED='\e[38;2;255;100;100m'
    readonly C_GREEN='\e[38;2;100;255;100m'
    readonly C_YELLOW='\e[38;2;255;255;100m'
    readonly C_BLUE='\e[38;2;100;200;255m'
    readonly C_PURPLE='\e[38;2;200;100;255m'
    readonly C_CYAN='\e[38;2;100;255;255m'
    readonly C_ORANGE='\e[38;2;255;200;100m'
else
    readonly C_RESET=''
    readonly C_BOLD=''
    readonly C_DIM=''
    readonly C_RED=''
    readonly C_GREEN=''
    readonly C_YELLOW=''
    readonly C_BLUE=''
    readonly C_PURPLE=''
    readonly C_CYAN=''
    readonly C_ORANGE=''
fi

# ═══════════════════════════════════════════════════════════════════════════════
# UTILITÁRIOS DE UI
# ═══════════════════════════════════════════════════════════════════════════════

print_banner() {
    clear
    cat << "EOF"
╔══════════════════════════════════════════════════════════════════╗
║                                                                  ║
║     ████████╗███████╗██████╗ ███╗   ███╗██╗   ██╗██╗  ██╗        ║
║     ╚══██╔══╝██╔════╝██╔══██╗████╗ ████║██║   ██║██║ ██╔╝        ║
║        ██║   █████╗  ██████╔╝██╔████╔██║██║   ██║█████╔╝         ║
║        ██║   ██╔══╝  ██╔══██╗██║╚██╔╝██║██║   ██║██╔═██╗         ║
║        ██║   ███████╗██║  ██║██║ ╚═╝ ██║╚██████╔╝██║  ██╗        ║
║        ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝        ║
║                                                                  ║
║              D E V H U B   P R O   v3.0                          ║
║                    N A T I V E   M O D E                         ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
EOF
    echo ""
}

log() {
    local level="$1"
    shift
    local msg="$*"
    local timestamp
    timestamp=$(date '+%H:%M:%S')

    case "$level" in
        info)    echo -e "${C_BLUE}[${timestamp}]${C_RESET} ℹ  $msg" ;;
        success) echo -e "${C_GREEN}[${timestamp}]${C_RESET} ✓  $msg" ;;
        warn)    echo -e "${C_YELLOW}[${timestamp}]${C_RESET} ⚠  $msg" ;;
        error)   echo -e "${C_RED}[${timestamp}]${C_RESET} ✗  $msg" ;;
        phase)   echo -e "${C_PURPLE}[${timestamp}]${C_RESET} ▶  $msg" ;;
        debug)   echo -e "${C_DIM}[${timestamp}]${C_RESET}   $msg" ;;
    esac

    # Criar diretório se não existir
    mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null || true
    
    # Também loga em arquivo sem cores
    echo "[${timestamp}] [${level^^}] $msg" >> "$LOG_FILE" 2>/dev/null || true
}

draw_line() {
    local char="${1:-─}"
    local width
    width=$(tput cols 2>/dev/null || echo 60)
    printf '%*s\n' "$width" '' | tr ' ' "$char"
}

progress_bar() {
    local current=$1
    local total=$2
    local width=40
    local percentage=$((current * 100 / total))
    local filled=$((width * current / total))
    local empty=$((width - filled))

    printf "\r${C_CYAN}[${C_GREEN}"
    printf '%*s' "$filled" '' | tr ' ' '█'
    printf "${C_DIM}"
    printf '%*s' "$empty" '' | tr ' ' '░'
    printf "${C_CYAN}]${C_RESET} %3d%%" "$percentage"
}

spinner() {
    local pid=$1
    local msg="${2:-Processando...}"
    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0

    tput civis 2>/dev/null || true
    while kill -0 "$pid" 2>/dev/null; do
        i=$(( (i + 1) % 10 ))
        printf "\r${C_CYAN}%s${C_RESET} %s" "${spin:$i:1}" "$msg"
        sleep 0.1
    done
    printf "\r${C_GREEN}✓${C_RESET} %s\n" "$msg"
    tput cnorm 2>/dev/null || true
}

# ═══════════════════════════════════════════════════════════════════════════════
# SISTEMA DE ESTADO E RECOVERY
# ═══════════════════════════════════════════════════════════════════════════════

init_state() {
    mkdir -p "$INSTALL_DIR"

    # Verificar lock file
    if [[ -f "$LOCK_FILE" ]]; then
        local pid
        pid=$(cat "$LOCK_FILE" 2>/dev/null)
        if kill -0 "$pid" 2>/dev/null; then
            log error "Outra instalação está em execução (PID: $pid)"
            exit 1
        else
            rm -f "$LOCK_FILE"
        fi
    fi

    echo $$ > "$LOCK_FILE"

    # Inicializar state.json
    cat > "$STATE_FILE" << EOF
{
  "version": "$VERSION",
  "start_time": "$(date -Iseconds)",
  "status": "running",
  "current_phase": "init",
  "phases": [],
  "retries": 0
}
EOF

    # Inicializar log
    echo "=== DevHub Pro v$VERSION Install Log ===" > "$LOG_FILE"
    echo "Started: $(date)" >> "$LOG_FILE"
    echo "PID: $$" >> "$LOG_FILE"
    echo "=======================================" >> "$LOG_FILE"
}

update_state() {
    local phase="$1"
    local status="$2"
    local message="${3:-}"

    local tmp_file
    tmp_file=$(mktemp)

    jq --arg phase "$phase" \
       --arg status "$status" \
       --arg message "$message" \
       --arg time "$(date -Iseconds)" \
       '.current_phase = $phase | 
        .phases += [{phase: $phase, status: $status, message: $message, time: $time}]' \
       "$STATE_FILE" > "$tmp_file" 2>/dev/null && mv "$tmp_file" "$STATE_FILE"
}

cleanup() {
    local exit_code=$?
    rm -f "$LOCK_FILE"

    if [[ $exit_code -eq 0 ]]; then
        jq '.status = "completed" | .end_time = "'$(date -Iseconds)'"' "$STATE_FILE" > "${STATE_FILE}.tmp" && mv "${STATE_FILE}.tmp" "$STATE_FILE"
    else
        jq '.status = "failed" | .exit_code = '$exit_code' | .end_time = "'$(date -Iseconds)'"' "$STATE_FILE" > "${STATE_FILE}.tmp" && mv "${STATE_FILE}.tmp" "$STATE_FILE"
    fi

    tput cnorm 2>/dev/null || true
}

trap cleanup EXIT

# ═══════════════════════════════════════════════════════════════════════════════
# VALIDAÇÕES INTELIGENTES
# ═══════════════════════════════════════════════════════════════════════════════

validate_environment() {
    log phase "FASE 0: Validação do Ambiente"
    draw_line

    # Verificar Termux
    if [[ -z "${PREFIX:-}" ]] || [[ ! "$PREFIX" =~ com.termux ]]; then
        log error "Este script é exclusivo para Termux!"
        log info "Baixe o Termux na F-Droid: https://f-droid.org/packages/com.termux/"
        exit 1
    fi
    log success "Ambiente Termux detectado"

    # Verificar arquitetura
    local arch
    arch=$(uname -m)
    if [[ "$arch" != "aarch64" ]]; then
        log warn "Arquitetura $arch detectada (otimizado para aarch64)"
    else
        log success "Arquitetura ARM64 (aarch64) - Otimizado"
    fi

    # Verificar Android version
    local android_version
    android_version=$(getprop ro.build.version.release 2>/dev/null || echo "desconhecido")
    log info "Android versão: $android_version"

    # Verificar espaço
    local available_gb
    # Verificar espaço (compatível com Android 16/Termux df)
    # Extrai o valor numérico da coluna 'Available' (geralmente a 4ª coluna)
    available_gb=$(df "$HOME" | awk 'NR==2 {print $4}' | sed 's/[^0-9]//g')
    
    # Se falhar a extração, tenta um método alternativo
    if [[ -z "$available_gb" ]]; then
        available_gb=$(df "$HOME" | tail -n 1 | awk '{print $(NF-2)}' | sed 's/[^0-9]//g')
    fi

    # Se o valor for muito grande (provavelmente em KB), converter para GB
    if [ -n "$available_gb" ] && [ "$available_gb" -gt 1000000 ]; then
        available_gb=$((available_gb / 1024 / 1024))
    elif [ -n "$available_gb" ] && [ "$available_gb" -gt 1000 ]; then
        available_gb=$((available_gb / 1024))
    fi
    
    # Fallback caso não consiga detectar (não bloqueia a instalação se falhar)
    if [[ -z "$available_gb" ]]; then
        log warn "Não foi possível detectar o espaço livre. Prosseguindo com cautela..."
    elif [[ "$available_gb" -lt 4 ]]; then
        log error "Espaço insuficiente: ${available_gb}GB disponível, necessário 4GB+"
        exit 1
    else
        log success "Espaço disponível: ${available_gb}GB"
    fi

    # Verificar RAM
    local total_ram
    total_ram=$(free -m 2>/dev/null | awk 'NR==2{printf "%.0f", $2/1024}' || echo "?")
    log info "RAM total: ${total_ram}GB"

    # Verificar internet
    log info "Testando conectividade..."
    if ! curl -fsI https://github.com &>/dev/null; then
        log error "Sem conexão com a internet ou GitHub inacessível"
        exit 1
    fi
    log success "Conectividade OK (GitHub acessível)"

    update_state "validation" "success" "Ambiente validado"
    echo ""
}

# ═══════════════════════════════════════════════════════════════════════════════
# FASE 1: SISTEMA BASE
# ═══════════════════════════════════════════════════════════════════════════════

install_system() {
    log phase "FASE 1: Sistema Base e Dependências"
    draw_line

    # Atualizar repositórios
    log info "Atualizando repositórios Termux..."
    # Garante que os repositórios estão apontando para os mirrors corretos antes do update
    termux-change-repo -s main 2>/dev/null || true
    (pkg update -y && pkg upgrade -y) &
    spinner $! "Atualizando pacotes"

    # Lista de pacotes essenciais
    local packages=(
        # Core
        git curl wget unzip zip tar
        # Node.js
        nodejs-lts npm
        # Editors & Tools
        neovim vim python
        # Terminal
        tmux zsh
        # Dev tools
        openssh gh
        # Utils
        ripgrep fd fzf bat eza
        # API
        termux-api
    )

    log info "Instalando ${#packages[@]} pacotes..."

    # Instalar com progresso
    local total=${#packages[@]}
    local current=0

    for pkg in "${packages[@]}"; do
        ((current++))
        progress_bar "$current" "$total"
        pkg install -y "$pkg" &>/dev/null || log warn "Falha ao instalar $pkg (continuando)"
    done
    echo ""

    log success "Pacotes instalados"

    # Configurar storage
    if [[ ! -d "$HOME/storage" ]]; then
        log info "Configurando acesso ao storage Android..."
        log warn "⚠️  POR FAVOR, CLIQUE EM 'PERMITIR' NO POP-UP DO ANDROID!"
        termux-setup-storage
        sleep 5
    fi

    update_state "system" "success" "Sistema base instalado"
    echo ""
}

# ═══════════════════════════════════════════════════════════════════════════════
# FASE 2: NODE.JS ECOSYSTEM
# ═══════════════════════════════════════════════════════════════════════════════

install_nodejs() {
    log phase "FASE 2: Node.js Ecosystem"
    draw_line

    # Verificar Node.js
    if ! command -v node &>/dev/null; then
        log error "Node.js não encontrado após instalação do pacote"
        exit 1
    fi

    local node_version
    node_version=$(node --version)
    log success "Node.js: $node_version"

    # Instalar pnpm
    if ! command -v pnpm &>/dev/null; then
        log info "Instalando pnpm (Package Manager)..."
        npm install -g pnpm &
        spinner $! "Instalando pnpm"
    else
        log success "pnpm já instalado: $(pnpm --version)"
    fi

    # Configurar ambiente pnpm
    export PNPM_HOME="$HOME/.local/share/pnpm"
    export PATH="$PNPM_HOME:$PATH"
    mkdir -p "$PNPM_HOME"

    # Instalar ferramentas globais
    log info "Instalando ferramentas globais..."
    local tools=(typescript tsx @vercel/cli supabase)

    for tool in "${tools[@]}"; do
        echo -n "  Instalando $tool... "
        if pnpm add -g "$tool" &>/dev/null; then
            echo -e "${C_GREEN}✓${C_RESET}"
        else
            echo -e "${C_YELLOW}⚠${C_RESET}"
        fi
    done

    # Adicionar ao .bashrc
    if ! grep -q "PNPM_HOME" "$HOME/.bashrc" 2>/dev/null; then
        cat >> "$HOME/.bashrc" << 'EOF'

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"
EOF
        log success "Ambiente pnpm configurado no .bashrc"
    fi

    update_state "nodejs" "success" "Node.js ecosystem pronto"
    echo ""
}

# ═══════════════════════════════════════════════════════════════════════════════
# FASE 3: DEV ENVIRONMENT (NVIM + TMUX + ZSH)
# ═══════════════════════════════════════════════════════════════════════════════

install_dev_env() {
    log phase "FASE 3: Ambiente de Desenvolvimento"
    draw_line

    # Zsh
    log info "Configurando Zsh..."
    if [[ "$SHELL" != *"zsh"* ]]; then
        chsh -s zsh
        log success "Zsh definido como shell padrão"
    fi

    # Oh-My-Zsh
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        log info "Instalando Oh-My-Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended &>/dev/null &
        spinner $! "Instalando Oh-My-Zsh"
    else
        log success "Oh-My-Zsh já instalado"
    fi

    # Tmux
    log info "Configurando Tmux..."
    cat > "$HOME/.tmux.conf" << 'EOF'
# DevHub Pro Tmux Config
set -g default-terminal "screen-256color"
set -g mouse on
set -g base-index 1
set -g pane-base-index 1
set -g history-limit 50000
set -g renumber-windows on

# Prefix
unbind C-b
set -g prefix C-a
bind C-a send-prefix

# Split bindings
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"
bind c new-window -c "#{pane_current_path}"

# Reload
bind r source-file ~/.tmux.conf \; display "Config reloaded!"

# Vim style navigation
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

# Status bar
set -g status-style bg=#1a1b26,fg=#a9b1d6
set -g status-left "#[fg=#7aa2f7,bold]#S #[fg=#414868]| "
set -g status-right "#[fg=#7aa2f7]%H:%M #[fg=#414868]| #[fg=#9ece6a]%d/%m"
set -g window-status-current-style fg=#7aa2f7,bold
set -g window-status-style fg=#565f89
EOF
    log success "Tmux configurado"

    # Neovim
    log info "Configurando Neovim..."
    mkdir -p "$HOME/.config/nvim"

    # init.lua otimizado para Termux
    cat > "$HOME/.config/nvim/init.lua" << 'EOF'
-- DevHub Pro - Neovim Config
local opt = vim.opt
local g = vim.g
local keymap = vim.keymap.set

-- Options
opt.number = true
opt.relativenumber = true
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.smartindent = true
opt.wrap = false
opt.termguicolors = true
opt.background = "dark"
opt.cursorline = true
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = false
opt.incsearch = true
opt.scrolloff = 8
opt.signcolumn = "yes"
opt.updatetime = 50
opt.timeoutlen = 300

-- Leader
g.mapleader = " "
g.maplocalleader = " "

-- Plugins (vim-plug)
local Plug = vim.fn['plug#']
vim.call('plug#begin', '~/.config/nvim/plugged')

-- Core
Plug('nvim-treesitter/nvim-treesitter', {['do'] = ':TSUpdate'})
Plug('neovim/nvim-lspconfig')
Plug('hrsh7th/nvim-cmp')
Plug('hrsh7th/cmp-nvim-lsp')

-- Navigation
Plug('nvim-lua/plenary.nvim')
Plug('nvim-telescope/telescope.nvim', {tag = '0.1.5'})
Plug('nvim-tree/nvim-tree.lua')
Plug('nvim-tree/nvim-web-devicons')

-- UI
Plug('folke/tokyonight.nvim')
Plug('nvim-lualine/lualine.nvim')
Plug('lukas-reineke/indent-blankline.nvim')

-- Tools
Plug('tpope/vim-fugitive')
Plug('akinsho/toggleterm.nvim')
Plug('windwp/nvim-autopairs')
Plug('numToStr/Comment.nvim')

vim.call('plug#end')

-- Theme
vim.cmd[[colorscheme tokyonight]]

-- Lualine
require('lualine').setup({
  options = { theme = 'tokyonight', section_separators = '', component_separators = '' }
})

-- Nvim-tree
require('nvim-tree').setup()
keymap('n', '<leader>e', ':NvimTreeToggle<CR>')

-- Telescope
local telescope = require('telescope.builtin')
keymap('n', '<leader>f', telescope.find_files)
keymap('n', '<leader>g', telescope.live_grep)
keymap('n', '<leader>b', telescope.buffers)

-- LSP
local lspconfig = require('lspconfig')
local capabilities = require('cmp_nvim_lsp').default_capabilities()

local servers = {'tsserver', 'eslint', 'jsonls', 'cssls', 'html', 'tailwindcss'}
for _, server in ipairs(servers) do
  lspconfig[server].setup({ capabilities = capabilities })
end

-- Completion
require('cmp').setup({
  sources = {{ name = 'nvim_lsp' }, { name = 'buffer' }},
  mapping = require('cmp').mapping.preset.insert({
    ['<C-Space>'] = require('cmp').mapping.complete(),
    ['<CR>'] = require('cmp').mapping.confirm({ select = true }),
  }),
})

-- Terminal
require('toggleterm').setup({ open_mapping = [[<c-\>]], direction = 'float' })

-- Autopairs
require('nvim-autopairs').setup()

-- Comments
require('Comment').setup()

-- Treesitter
require('nvim-treesitter.configs').setup({
  highlight = { enable = true },
  indent = { enable = true },
})

-- Indent blankline
require('ibl').setup()

-- Keymaps
keymap('n', '<leader>w', ':w<CR>')
keymap('n', '<leader>q', ':q<CR>')
keymap('n', '<leader>x', ':x<CR>')
keymap('n', '<leader>h', ':nohl<CR>')
keymap('n', '<C-s>', ':w<CR>')
keymap('i', 'jk', '<ESC>')
keymap('n', 'H', '^')
keymap('n', 'L', '$')
EOF

    # Instalar vim-plug
    if [[ ! -f "$HOME/.config/nvim/autoload/plug.vim" ]]; then
        log info "Instalando vim-plug..."
        curl -fLo "$HOME/.config/nvim/autoload/plug.vim" --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim &>/dev/null &
        spinner $! "Baixando vim-plug"
    fi

    log success "Neovim configurado"
    log info "Dica: Na primeira vez, abra nvim e execute :PlugInstall"

    # Aliases
    if ! grep -q "DevHub Aliases" "$HOME/.bashrc" 2>/dev/null; then
        cat >> "$HOME/.bashrc" << 'EOF'

# ═══════════════════════════════════════════════════════════════
# DevHub Pro Aliases
# ═══════════════════════════════════════════════════════════════

# Editor
alias vim='nvim'
alias vi='nvim'
alias v='nvim'

# Tmux
alias t='tmux'
alias ta='tmux attach'
alias tn='tmux new-session -s'
alias tls='tmux ls'

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ll='eza -la --icons'
alias la='eza -a --icons'
alias lt='eza -T --icons'

# Git
alias g='git'
alias gs='git status'
alias gp='git pull'
alias gP='git push'
alias gc='git commit -m'
alias gca='git commit -am'
alias gco='git checkout'
alias gb='git branch'
alias gd='git diff'
alias gl='git log --oneline --graph'

# Dev
alias dev='cd ~/projects'
alias p='pnpm'
alias px='pnpm dlx'
alias pi='pnpm install'
alias pd='pnpm dev'
alias pb='pnpm build'
alias ps='pnpm start'

# Utils
alias c='clear'
alias h='history'
alias ports='netstat -tulanp'
EOF
        log success "Aliases criados"
    fi

    update_state "dev_env" "success" "Ambiente dev configurado"
    echo ""
}

# ═══════════════════════════════════════════════════════════════════════════════
# FASE 4: PROJETO NEXT.JS PWA
# ═══════════════════════════════════════════════════════════════════════════════

create_project() {
    log phase "FASE 4: Projeto Next.js PWA"
    draw_line

    mkdir -p "$HOME/projects"

    if [[ -d "$PROJECT_DIR" ]]; then
        log warn "Projeto já existe em $PROJECT_DIR"
        read -p "Recriar projeto? [s/N]: " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Ss]$ ]]; then
            rm -rf "$PROJECT_DIR"
        else
            log info "Pulando criação do projeto"
            update_state "project" "skipped" "Projeto já existente"
            echo ""
            return
        fi
    fi

    log info "Criando projeto Next.js (isso pode levar alguns minutos)..."

    cd "$HOME/projects"

    # Criar projeto com create-next-app
    echo "my-app" | npx create-next-app@latest devhub-pwa \
        --typescript \
        --tailwind \
        --eslint \
        --app \
        --src-dir \
        --import-alias "@/*" \
        --use-npm \
        --yes &>/dev/null &

    spinner $! "Scaffolding Next.js"

    cd "$PROJECT_DIR"

    # Instalar dependências adicionais
    log info "Instalando dependências PWA e Database..."

    local deps=(
        next-pwa @ducanh2912/next-pwa
        drizzle-orm better-sqlite3
        @supabase/supabase-js
        zustand zod
        react-hook-form @hookform/resolvers
        lucide-react
        class-variance-authority clsx tailwind-merge
    )

    pnpm add "${deps[@]}" &>/dev/null &
    spinner $! "Instalando dependências"

    local dev_deps=(
        @types/better-sqlite3
        drizzle-kit
        prettier prettier-plugin-tailwindcss
    )

    pnpm add -D "${dev_deps[@]}" &>/dev/null &
    spinner $! "Instalando dev dependencies"

    # Configurar PWA
    cat > next.config.js << 'EOF'
const withPWA = require('@ducanh2912/next-pwa').default({
  dest: 'public',
  register: true,
  skipWaiting: true,
  disable: process.env.NODE_ENV === 'development',
  fallbacks: { document: '/offline' },
})

/** @type {import('next').NextConfig} */
const nextConfig = {
  experimental: { typedRoutes: true },
}

module.exports = withPWA(nextConfig)
EOF

    # Manifest
    cat > public/manifest.json << 'EOF'
{
  "name": "DevHub Pro PWA",
  "short_name": "DevHub",
  "description": "Professional Development Environment",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#0f172a",
  "theme_color": "#3b82f6",
  "orientation": "portrait",
  "icons": [
    { "src": "/icon-192x192.png", "sizes": "192x192", "type": "image/png" },
    { "src": "/icon-512x512.png", "sizes": "512x512", "type": "image/png" }
  ]
}
EOF

    # Database
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

    # Env
    cat > .env.local << 'EOF'
# Database
DATABASE_URL="file:./sqlite.db"

# Supabase (opcional - preencha para usar PostgreSQL na nuvem)
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=

# App
NEXT_PUBLIC_APP_URL="http://localhost:3000"
EOF

    # Offline page
    mkdir -p src/app/offline
    cat > src/app/offline/page.tsx << 'EOF'
export default function OfflinePage() {
  return (
    <div className="flex min-h-screen flex-col items-center justify-center bg-slate-900 text-white p-8">
      <h1 className="text-4xl font-bold mb-4">Você está offline</h1>
      <p className="text-lg text-slate-400">Verifique sua conexão e tente novamente.</p>
    </div>
  )
}
EOF

    # Git
    git init &>/dev/null
    git add . &>/dev/null
    git commit -m "feat: initial commit - DevHub Pro PWA" &>/dev/null

    log success "Projeto criado e configurado"

    # Criar comando devhub
    mkdir -p "$HOME/.local/bin"
    cat > "$HOME/.local/bin/devhub" << 'SCRIPT'
#!/bin/bash
# DevHub Pro - Interactive CLI

CYAN='\e[36m'
GREEN='\e[32m'
YELLOW='\e[33m'
RED='\e[31m'
RESET='\e[0m'
BOLD='\e[1m'

clear
printf "${BOLD}${CYAN}"
cat << "LOGO"
╔══════════════════════════════════════════════════════════╗
║     ██████╗ ███████╗██╗   ██╗██╗  ██╗██╗   ██╗██████╗    ║
║     ██╔══██╗██╔════╝██║   ██║██║ ██╔╝██║   ██║██╔══██╗   ║
║     ██║  ██║█████╗  ██║   ██║█████╔╝ ██║   ██║██████╔╝   ║
║     ██║  ██║██╔══╝  ╚██╗ ██╔╝██╔═██╗ ██║   ██║██╔══██╗   ║
║     ██████╔╝███████╗ ╚████╔╝ ██║  ██╗╚██████╔╝██████╔╝   ║
║     ╚═════╝ ╚══════╝  ╚═══╝  ╚═╝  ╚═╝ ╚═════╝ ╚═════╝    ║
║                                                          ║
║              P R O   v3.0   T E R M I N A L              ║
╚══════════════════════════════════════════════════════════╝
LOGO
printf "${RESET}\n"

cd "$HOME/projects/devhub-pwa" 2>/dev/null || { echo "Projeto não encontrado!"; exit 1; }

while true; do
    printf "${YELLOW}%s${RESET} | ${GREEN}DevHub${RESET} | ${CYAN}%s${RESET}\n" "$(date '+%H:%M:%S')" "$(pwd)"
    printf "${BOLD}══════════════════════════════════════════════════════════${RESET}\n"
    echo ""
    echo "  ${CYAN}1${RESET}) 🚀  Iniciar dev server        ${CYAN}pnpm dev${RESET}"
    echo "  ${CYAN}2${RESET}) 📦  Instalar dependências     ${CYAN}pnpm install${RESET}"
    echo "  ${CYAN}3${RESET}) 🏗️   Build produção           ${CYAN}pnpm build${RESET}"
    echo "  ${CYAN}4${RESET}) ☁️   Deploy Vercel           ${CYAN}vercel --prod${RESET}"
    echo "  ${CYAN}5${RESET}) 🗄️   Database studio         ${CYAN}drizzle-kit studio${RESET}"
    echo "  ${CYAN}6${RESET}) 📝  Abrir Neovim             ${CYAN}nvim .${RESET}"
    echo "  ${CYAN}7${RESET}) 🌐  Abrir navegador          ${CYAN}termux-open-url${RESET}"
    echo "  ${CYAN}8${RESET}) 🔄  Git status               ${CYAN}git status${RESET}"
    echo "  ${CYAN}9${RESET}) 📊  Monitor sistema          ${CYAN}htop${RESET}"
    echo "  ${CYAN}0${RESET}) 🚪  Sair"
    echo ""
    printf "${BOLD}Escolha:${RESET} "
    read -r choice

    case $choice in
        1) pnpm dev ;;
        2) pnpm install ;;
        3) pnpm build ;;
        4) vercel --prod ;;
        5) pnpm drizzle-kit studio ;;
        6) nvim . ;;
        7) termux-open-url http://localhost:3000 2>/dev/null || echo "Abra http://localhost:3000 no navegador" ;;
        8) git status ;;
        9) htop ;;
        0) printf "\n${GREEN}Até logo! 👋${RESET}\n"; exit 0 ;;
        *) printf "\n${RED}Opção inválida${RESET}\n" ;;
    esac

    echo ""
    printf "${YELLOW}Pressione ENTER para continuar...${RESET}"
    read -r
    clear
done
SCRIPT
    chmod +x "$HOME/.local/bin/devhub"

    # Adicionar ao PATH
    if ! grep -q "$HOME/.local/bin" "$HOME/.bashrc"; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
    fi

    update_state "project" "success" "Projeto criado"
    echo ""
}

# ═══════════════════════════════════════════════════════════════════════════════
# VALIDAÇÃO FINAL
# ═══════════════════════════════════════════════════════════════════════════════

final_validation() {
    log phase "VALIDAÇÃO FINAL"
    draw_line

    local checks=()
    local passed=0
    local failed=0

    # Definir checks
    checks+=("node:Node.js:$(command -v node && node --version)")
    checks+=("pnpm:pnpm:$(command -v pnpm && pnpm --version)")
    checks+=("git:Git:$(command -v git && git --version | cut -d' ' -f3)")
    checks+=("nvim:Neovim:$(command -v nvim && nvim --version | head -1)")
    checks+=("tmux:Tmux:$(command -v tmux && tmux -V)")
    checks+=("zsh:Zsh:$(command -v zsh && zsh --version | cut -d' ' -f1-2)")
    checks+=("vercel:Vercel CLI:$(command -v vercel && echo 'installed')")
    checks+=("project:Projeto:$([ -d '$PROJECT_DIR' ] && echo 'exists')")
    checks+=("devhub:Comando devhub:$([ -x '$HOME/.local/bin/devhub' ] && echo 'executable')")

    local total=${#checks[@]}

    for check in "${checks[@]}"; do
        IFS=':' read -r cmd name expected <<< "$check"

        if eval "$cmd" &>/dev/null; then
            printf "  ${C_GREEN}✓${C_RESET} %-20s ${C_GREEN}%s${C_RESET}\n" "$name" "OK"
            ((passed++))
        else
            printf "  ${C_RED}✗${C_RESET} %-20s ${C_RED}%s${C_RESET}\n" "$name" "FALHOU"
            ((failed++))
        fi
    done

    echo ""
    log info "Resultado: $passed/$total verificações passaram"

    if [[ $failed -eq 0 ]]; then
        update_state "validation" "success" "Todas as verificações passaram"
        return 0
    else
        update_state "validation" "partial" "$passed de $total passaram"
        return 1
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# FINALIZAÇÃO
# ═══════════════════════════════════════════════════════════════════════════════

print_success() {
    echo ""
    draw_line "═"
    log success "INSTALAÇÃO CONCLUÍDA COM SUCESSO! 🎉"
    draw_line "═"
    echo ""

    printf "${C_CYAN}${BOLD}Próximos passos:${RESET}\n\n"
    printf "  1. ${C_YELLOW}source ~/.bashrc${RESET}        # Recarregar configurações\n"
    printf "  2. ${C_YELLOW}devhub${RESET}                  # Iniciar menu interativo\n"
    printf "  3. ${C_YELLOW}cd ~/projects/devhub-pwa${RESET} # Ir para o projeto\n"
    printf "  4. ${C_YELLOW}pnpm dev${RESET}                # Iniciar servidor\n"
    echo ""

    printf "${C_CYAN}${BOLD}Recursos disponíveis:${RESET}\n"
    printf "  ${C_GREEN}•${RESET} ${C_BOLD}nvim${RESET}      Editor de código moderno\n"
    printf "  ${C_GREEN}•${RESET} ${C_BOLD}tmux${RESET}      Sessões persistentes\n"
    printf "  ${C_GREEN}•${RESET} ${C_BOLD}pnpm${RESET}      Package manager ultra-rápido\n"
    printf "  ${C_GREEN}•${RESET} ${C_BOLD}vercel${RESET}    Deploy na nuvem\n"
    printf "  ${C_GREEN}•${RESET} ${C_BOLD}supabase${RESET}  Database PostgreSQL\n"
    printf "  ${C_GREEN}•${RESET} ${C_BOLD}drizzle${RESET}   ORM type-safe\n"
    echo ""

    printf "${C_DIM}Log completo: ${C_RESET}${C_BLUE}$LOG_FILE${RESET}\n"
    printf "${C_DIM}Estado: ${C_RESET}${C_BLUE}$STATE_FILE${RESET}\n"
    echo ""

    local duration
    duration=$(jq -r '.phases | length' "$STATE_FILE" 2>/dev/null || echo "?")
    log info "Duração: ~$(( $(date +%s) - $(date -d "$(jq -r .start_time "$STATE_FILE")" +%s 2>/dev/null || echo $(date +%s)) )) segundos"
}

print_error() {
    echo ""
    draw_line "═"
    log error "INSTALAÇÃO INCOMPLETA"
    draw_line "═"
    echo ""
    log info "Verifique o log para detalhes: $LOG_FILE"
    log info "Estado atual: $STATE_FILE"
    echo ""
    log info "Para tentar novamente:"
    echo "  bash install.sh"
}

# ═══════════════════════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════════════════════

main() {
    print_banner

    # Verificar se jq está instalado
    if ! command -v jq &>/dev/null; then
        log info "Instalando jq (necessário para state management)..."
        pkg install -y jq &>/dev/null
    fi

    init_state

    # Execução das fases
    validate_environment
    install_system
    install_nodejs
    install_dev_env
    create_project

    # Validação e finalização
    if final_validation; then
        print_success
        exit 0
    else
        print_error
        exit 1
    fi
}

# Tratamento de sinais
trap 'log error "Interrompido na linha $LINENO"; exit 130' INT TERM
trap 'log error "Erro na linha $LINENO"; exit 1' ERR

# Executar
main "$@"
