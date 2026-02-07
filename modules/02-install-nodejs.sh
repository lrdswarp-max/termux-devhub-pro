#!/bin/bash
# DevHub Pro - Módulo 2: Instalação de Node.js e pnpm
# Responsabilidade: Configurar Node.js, npm e pnpm

set -euo pipefail

INSTALL_LOG="${HOME}/.devhub/install.log"

log() {
    local level="$1"
    shift
    local msg="$*"
    echo "[$(date '+%H:%M:%S')] [$level] $msg" | tee -a "$INSTALL_LOG"
}

log "INFO" "=== FASE 2: Instalação de Node.js e pnpm ==="

# Verificar Node.js
if ! command -v node &> /dev/null; then
    log "ERROR" "Node.js não foi instalado corretamente"
    exit 1
fi

log "SUCCESS" "Node.js instalado: $(node --version)"
log "SUCCESS" "npm instalado: $(npm --version)"

# Instalar pnpm globalmente
log "INFO" "Instalando pnpm..."

# Configurar npm para usar $HOME em Termux
npm config set prefix "$HOME/.npm-global" 2>/dev/null || true
export PATH="$HOME/.npm-global/bin:$PATH"

npm install -g pnpm || { log "ERROR" "Falha ao instalar pnpm"; exit 1; }

log "SUCCESS" "pnpm instalado: $(pnpm --version)"

# Configurar PNPM_HOME
export PNPM_HOME="$HOME/.local/share/pnpm"
mkdir -p "$PNPM_HOME"

log "INFO" "Configurando PNPM_HOME..."

# Adicionar ao .bashrc
if ! grep -q "npm-global" "$HOME/.bashrc" 2>/dev/null; then
    echo '' >> "$HOME/.bashrc"
    echo '# npm global path' >> "$HOME/.bashrc"
    echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> "$HOME/.bashrc"
fi

log "SUCCESS" "Fase 2 concluída: Node.js e pnpm configurados"
