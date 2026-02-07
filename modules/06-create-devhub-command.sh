#!/bin/bash
# DevHub Pro - Módulo 6: Criação do Comando devhub
# Responsabilidade: Criar script devhub e adicionar ao PATH

set -euo pipefail

INSTALL_LOG="${HOME}/.devhub/install.log"

log() {
    local level="$1"
    shift
    local msg="$*"
    echo "[$(date '+%H:%M:%S')] [$level] $msg" | tee -a "$INSTALL_LOG"
}

log "INFO" "=== FASE 6: Criação do Comando devhub ==="

# Criar diretório .local/bin
log "INFO" "Criando diretório ~/.local/bin..."
mkdir -p "$HOME/.local/bin"

# Criar script devhub
log "INFO" "Criando script devhub..."
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

PROJECT_DIR="$HOME/projects/devhub-pwa"

if [[ ! -d "$PROJECT_DIR" ]]; then
    printf "${RED}✗${RESET} Projeto não encontrado em $PROJECT_DIR\n"
    exit 1
fi

cd "$PROJECT_DIR"

while true; do
    printf "${YELLOW}%s${RESET} | ${GREEN}DevHub${RESET} | ${CYAN}%s${RESET}\n" "$(date '+%H:%M:%S')" "$(pwd)"
    printf "${BOLD}══════════════════════════════════════════════════════════${RESET}\n"
    echo ""
    echo "  ${CYAN}1${RESET}) 🚀  Iniciar dev server        ${CYAN}pnpm dev${RESET}"
    echo "  ${CYAN}2${RESET}) 📦  Instalar dependências     ${CYAN}pnpm install${RESET}"
    echo "  ${CYAN}3${RESET}) 🏗️   Build produção           ${CYAN}pnpm build${RESET}"
    echo "  ${CYAN}4${RESET}) 📝  Abrir Neovim             ${CYAN}nvim .${RESET}"
    echo "  ${CYAN}5${RESET}) 🔄  Git status               ${CYAN}git status${RESET}"
    echo "  ${CYAN}6${RESET}) 📊  Monitor sistema          ${CYAN}htop${RESET}"
    echo "  ${CYAN}0${RESET}) 🚪  Sair"
    echo ""
    printf "${BOLD}Escolha:${RESET} "
    read -r choice

    case $choice in
        1) pnpm dev ;;
        2) pnpm install ;;
        3) pnpm build ;;
        4) nvim . ;;
        5) git status ;;
        6) htop ;;
        0) printf "\n${GREEN}Até logo! 👋${RESET}\n"; exit 0 ;;
        *) printf "\n${RED}Opção inválida${RESET}\n" ;;
    esac

    echo ""
    printf "${YELLOW}Pressione ENTER para continuar...${RESET}"
    read -r
    clear
done
SCRIPT

# Tornar executável
chmod +x "$HOME/.local/bin/devhub"
log "SUCCESS" "Script devhub criado e executável"

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

log "SUCCESS" "Fase 6 concluída: Comando devhub criado e PATH configurado"
