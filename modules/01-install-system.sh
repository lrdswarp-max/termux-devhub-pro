#!/bin/bash
# DevHub Pro - Módulo 1: Instalação de Pacotes do Sistema
# Responsabilidade: Atualizar repositórios e instalar ferramentas base

set -euo pipefail

INSTALL_LOG="${HOME}/.devhub/install.log"
mkdir -p "$(dirname "$INSTALL_LOG")"

log() {
    local level="$1"
    shift
    local msg="$*"
    echo "[$(date '+%H:%M:%S')] [$level] $msg" | tee -a "$INSTALL_LOG"
}

log "INFO" "=== FASE 1: Instalação de Pacotes do Sistema ==="

# Atualizar repositórios
log "INFO" "Atualizando repositórios..."
pkg update -y || { log "ERROR" "Falha ao atualizar repositórios"; exit 1; }
pkg upgrade -y || { log "ERROR" "Falha ao fazer upgrade"; exit 1; }

log "INFO" "Instalando pacotes base..."

# Lista de pacotes essenciais
PACKAGES=(
    "git"
    "curl"
    "wget"
    "unzip"
    "zip"
    "tar"
    "nodejs-lts"
    "npm"
    "neovim"
    "tmux"
    "zsh"
    "openssh"
)

for pkg in "${PACKAGES[@]}"; do
    log "INFO" "Instalando $pkg..."
    if ! pkg install "$pkg" -y 2>&1 | tee -a "$INSTALL_LOG"; then
        log "WARN" "Falha ao instalar $pkg (continuando...)"
    fi
done

log "INFO" "Solicitando permissão de armazenamento..."
termux-setup-storage || log "WARN" "Permissão de armazenamento já concedida"

log "SUCCESS" "Fase 1 concluída: Pacotes do sistema instalados"
