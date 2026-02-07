#!/bin/bash
# DevHub Pro - Orquestrador de Módulos
# Responsabilidade: Executar todos os módulos em sequência com validações

set -euo pipefail

MODULES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_LOG="${HOME}/.devhub/install.log"

mkdir -p "$(dirname "$INSTALL_LOG")"

# Cores
C_RESET='\e[0m'
C_GREEN='\e[38;2;100;255;100m'
C_BLUE='\e[38;2;100;200;255m'
C_YELLOW='\e[38;2;255;255;100m'
C_RED='\e[38;2;255;100;100m'

log() {
    local level="$1"
    shift
    local msg="$*"
    echo -e "${C_BLUE}[$(date '+%H:%M:%S')]${C_RESET} [$level] $msg" | tee -a "$INSTALL_LOG"
}

error() {
    local msg="$1"
    echo -e "${C_RED}✗${C_RESET} ERRO: $msg" | tee -a "$INSTALL_LOG"
    exit 1
}

success() {
    local msg="$1"
    echo -e "${C_GREEN}✓${C_RESET} $msg" | tee -a "$INSTALL_LOG"
}

# Banner
clear
echo -e "${C_BLUE}"
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
║                    M O D U L A R   I N S T A L L                ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
EOF
echo -e "${C_RESET}"

log "INFO" "Iniciando instalação modular do DevHub Pro..."
log "INFO" "Log: $INSTALL_LOG"

# Array de módulos
MODULES=(
    "01-install-system.sh"
    "02-install-nodejs.sh"
    "03-configure-shell.sh"
    "04-configure-tools.sh"
    "05-create-project.sh"
    "06-create-devhub-command.sh"
)

# Executar cada módulo
for module in "${MODULES[@]}"; do
    MODULE_PATH="$MODULES_DIR/$module"
    
    if [[ ! -f "$MODULE_PATH" ]]; then
        error "Módulo não encontrado: $MODULE_PATH"
    fi
    
    log "INFO" "Executando módulo: $module"
    
    if bash "$MODULE_PATH" 2>&1 | tee -a "$INSTALL_LOG"; then
        success "Módulo concluído: $module"
    else
        error "Falha ao executar módulo: $module"
    fi
    
    echo ""
done

# Validação final
log "INFO" "Executando validações finais..."

# Verificar Node.js
if command -v node &> /dev/null; then
    success "Node.js: $(node --version)"
else
    error "Node.js não foi instalado"
fi

# Verificar pnpm
if command -v pnpm &> /dev/null; then
    success "pnpm: $(pnpm --version)"
else
    error "pnpm não foi instalado"
fi

# Verificar Zsh
if command -v zsh &> /dev/null; then
    success "Zsh: $(zsh --version)"
else
    error "Zsh não foi instalado"
fi

# Verificar Neovim
if command -v nvim &> /dev/null; then
    success "Neovim: $(nvim --version | head -1)"
else
    error "Neovim não foi instalado"
fi

# Verificar comando devhub
if [[ -x "$HOME/.local/bin/devhub" ]]; then
    success "Comando devhub criado"
else
    error "Comando devhub não foi criado"
fi

# Verificar projeto
if [[ -d "$HOME/projects/devhub-pwa" ]]; then
    success "Projeto Next.js criado"
else
    error "Projeto Next.js não foi criado"
fi

echo ""
echo -e "${C_GREEN}╔════════════════════════════════════════════════════════════════╗${C_RESET}"
echo -e "${C_GREEN}║${C_RESET}  ✓ Instalação concluída com sucesso!                         ${C_GREEN}║${C_RESET}"
echo -e "${C_GREEN}╚════════════════════════════════════════════════════════════════╝${C_RESET}"
echo ""
echo "Próximos passos:"
echo "  1. Recarregue seu shell: source ~/.bashrc"
echo "  2. Execute: devhub"
echo ""
