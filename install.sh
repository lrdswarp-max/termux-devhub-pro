#!/data/data/com.termux/files/usr/bin/bash
#
# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║                    TERMUX DEVHUB PRO v3.0 - QUICK INSTALLER                  ║
# ║                      Script de instalação rápida via curl                    ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# Uso: curl -fsSL https://raw.githubusercontent.com/lrdswarp-max/termux-devhub-pro/main/install.sh | bash
#

set -euo pipefail

# Cores para output
readonly C_RESET='\e[0m'
readonly C_GREEN='\e[38;2;100;255;100m'
readonly C_BLUE='\e[38;2;100;200;255m'
readonly C_YELLOW='\e[38;2;255;255;100m'
readonly C_RED='\e[38;2;255;100;100m'

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
║                    Q U I C K   I N S T A L L                     ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
EOF
echo -e "${C_RESET}"

echo ""
echo -e "${C_GREEN}✓${C_RESET} Iniciando instalação do Termux DevHub Pro v3.0..."
echo ""

# Verifica se está rodando no Termux
if [[ ! -d "/data/data/com.termux" ]]; then
    echo -e "${C_RED}✗${C_RESET} ERRO: Este script deve ser executado no Termux!"
    echo ""
    echo "Instale o Termux via F-Droid:"
    echo "https://f-droid.org/packages/com.termux/"
    exit 1
fi

# Diretório temporário para download dos módulos
TEMP_DIR="${HOME}/.devhub-install-temp"
mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR"

echo -e "${C_BLUE}ℹ${C_RESET} Baixando módulos de instalação..."

# URL do repositório
REPO_URL="https://raw.githubusercontent.com/lrdswarp-max/termux-devhub-pro/main"

# Módulos necessários
MODULES=(
    "modules/01-install-system.sh"
    "modules/02-install-nodejs.sh"
    "modules/03-configure-shell.sh"
    "modules/04-configure-tools.sh"
    "modules/05-create-project.sh"
    "modules/06-create-devhub-command.sh"
    "modules/run-all.sh"
)

# Função para baixar com fallback
download_file() {
    local url="$1"
    local output="$2"
    
    if command -v curl &> /dev/null; then
        curl -fsSL "$url" -o "$output" 2>/dev/null || return 1
    elif command -v wget &> /dev/null; then
        wget -q "$url" -O "$output" 2>/dev/null || return 1
    else
        return 1
    fi
}

# Baixar todos os módulos
mkdir -p modules
for module in "${MODULES[@]}"; do
    MODULE_URL="${REPO_URL}/${module}"
    MODULE_FILE="${TEMP_DIR}/${module}"
    
    echo -e "${C_BLUE}ℹ${C_RESET} Baixando $module..."
    
    if ! download_file "$MODULE_URL" "$MODULE_FILE"; then
        echo -e "${C_RED}✗${C_RESET} Erro ao baixar $module"
        echo "Verifique sua conexão com a internet."
        exit 1
    fi
    
    chmod +x "$MODULE_FILE"
done

echo -e "${C_GREEN}✓${C_RESET} Todos os módulos baixados com sucesso!"
echo ""
echo -e "${C_BLUE}ℹ${C_RESET} Executando instalação modular..."
echo ""

# Executar o orquestrador
if bash "${TEMP_DIR}/modules/run-all.sh"; then
    echo ""
    echo -e "${C_GREEN}✓${C_RESET} Instalação concluída com sucesso!"
    echo ""
    echo "Próximos passos:"
    echo "  1. Recarregue seu shell: source ~/.bashrc"
    echo "  2. Execute: devhub"
    echo ""
else
    echo -e "${C_RED}✗${C_RESET} Erro durante a instalação"
    echo "Verifique o log em: ${HOME}/.devhub/install.log"
    exit 1
fi

# Limpar arquivos temporários
echo -e "${C_BLUE}ℹ${C_RESET} Limpando arquivos temporários..."
cd "$HOME"
rm -rf "$TEMP_DIR"

echo -e "${C_GREEN}✓${C_RESET} Limpeza concluída!"
echo ""
