#!/bin/bash
# DevHub Pro - Módulo 4: Configuração de Ferramentas
# Responsabilidade: Configurar Neovim, Tmux e criar aliases

set -euo pipefail

INSTALL_LOG="${HOME}/.devhub/install.log"

log() {
    local level="$1"
    shift
    local msg="$*"
    echo "[$(date '+%H:%M:%S')] [$level] $msg" | tee -a "$INSTALL_LOG"
}

log "INFO" "=== FASE 4: Configuração de Ferramentas ==="

# Configurar Tmux
log "INFO" "Configurando Tmux..."
mkdir -p "$HOME/.config"
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
log "SUCCESS" "Tmux configurado"

# Configurar Neovim
log "INFO" "Configurando Neovim..."
mkdir -p "$HOME/.config/nvim/autoload"

cat > "$HOME/.config/nvim/init.lua" << 'EOF'
-- DevHub Pro - Neovim Config (Otimizado para Termux)
local opt = vim.opt

-- Performance em Termux
opt.updatetime = 1000
opt.timeoutlen = 500
opt.ttimeoutlen = 10

-- Essencial
opt.number = true
opt.relativenumber = false
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.smartindent = true
opt.wrap = false
opt.termguicolors = false  -- Desabilitar true colors em Termux
opt.background = "dark"
opt.cursorline = true
opt.ignorecase = true
opt.smartcase = true

-- Leader key
vim.g.mapleader = " "

-- Keymaps basicos
vim.keymap.set('n', '<leader>w', ':w<CR>', { noremap = true })
vim.keymap.set('n', '<leader>q', ':q<CR>', { noremap = true })

-- Desabilitar providers pesados em Termux
vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

-- Syntax highlighting minimo
vim.cmd('syntax on')
EOF

# Instalar vim-plug
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

log "SUCCESS" "Neovim configurado"

# Criar aliases
log "INFO" "Criando aliases..."

if ! grep -q "DevHub Pro Aliases" "$HOME/.bashrc" 2>/dev/null; then
    cat >> "$HOME/.bashrc" << 'EOF'

# ═══════════════════════════════════════════════════════════════
# DevHub Pro Aliases
# ═══════════════════════════════════════════════════════════════

alias vim='nvim'
alias vi='nvim'
alias v='nvim'
alias t='tmux'
alias ta='tmux attach'
alias tn='tmux new-session -s'
alias tls='tmux ls'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ll='eza -la --icons'
alias la='eza -a --icons'
alias lt='eza -T --icons'
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
alias dev='cd ~/projects'
alias p='pnpm'
alias px='pnpm dlx'
alias pi='pnpm install'
alias pd='pnpm dev'
alias pb='pnpm build'
alias ps='pnpm start'
alias c='clear'
alias h='history'
alias ports='netstat -tulanp'
EOF
    log "SUCCESS" "Aliases criados em .bashrc"
fi

log "SUCCESS" "Fase 4 concluída: Ferramentas configuradas"
