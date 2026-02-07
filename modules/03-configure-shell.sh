#!/bin/bash
# DevHub Pro - Módulo 3: Configuração de Shell
# Responsabilidade: Instalar e configurar Zsh e Oh-My-Zsh

set -euo pipefail

INSTALL_LOG="${HOME}/.devhub/install.log"

log() {
    local level="$1"
    shift
    local msg="$*"
    echo "[$(date '+%H:%M:%S')] [$level] $msg" | tee -a "$INSTALL_LOG"
}

log "INFO" "=== FASE 3: Configuração de Shell ==="

# Verificar se Zsh está instalado
if ! command -v zsh &> /dev/null; then
    log "ERROR" "Zsh não foi instalado corretamente"
    exit 1
fi

log "SUCCESS" "Zsh instalado: $(zsh --version)"

# Mudar shell padrão para Zsh
# Nota: Termux não suporta chsh (sem /etc/passwd modificável)
# Para usar Zsh como padrão, execute manualmente após reboot:
# exec zsh
log "INFO" "Zsh disponível como shell alternativo"

# Instalar Oh-My-Zsh
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    log "INFO" "Instalando Oh-My-Zsh..."
    export RUNZSH=no
    export KEEP_ZSHRC=yes
    echo "" | sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended 2>&1 | tee -a "$INSTALL_LOG" || {
        log "ERROR" "Falha ao instalar Oh-My-Zsh"
        exit 1
    }
    log "SUCCESS" "Oh-My-Zsh instalado"
else
    log "SUCCESS" "Oh-My-Zsh já estava instalado"
fi

# Configurar .zshrc com PATH e variáveis
log "INFO" "Configurando .zshrc..."

if ! grep -q "DevHub Pro Environment" "$HOME/.zshrc" 2>/dev/null; then
    cat >> "$HOME/.zshrc" << 'EOF'

# ═══════════════════════════════════════════════════════════════
# DevHub Pro Environment
# ═══════════════════════════════════════════════════════════════

# PNPM
export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH="$PNPM_HOME:$HOME/.local/bin:$PATH"

# Source .bashrc para aliases
if [[ -f "$HOME/.bashrc" ]]; then
    source "$HOME/.bashrc"
fi
EOF
    log "SUCCESS" ".zshrc configurado com variáveis de ambiente"
fi

log "SUCCESS" "Fase 3 concluída: Shell configurado"
