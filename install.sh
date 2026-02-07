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

# Diretório temporário para download
TEMP_DIR="${HOME}/.devhub-install-temp"
mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR"

echo -e "${C_BLUE}ℹ${C_RESET} Baixando instalador principal..."

# URL do repositório (será atualizada após criar o repo)
REPO_URL="https://raw.githubusercontent.com/lrdswarp-max/termux-devhub-pro/main"
INSTALLER_URL="${REPO_URL}/install-devhub-pro.sh"

# Tenta baixar o instalador principal
if command -v curl &> /dev/null; then
    if ! curl -fsSL "$INSTALLER_URL" -o install-devhub-pro.sh; then
        echo -e "${C_RED}✗${C_RESET} Erro ao baixar instalador. Verifique sua conexão."
        exit 1
    fi
elif command -v wget &> /dev/null; then
    if ! wget -q "$INSTALLER_URL" -O install-devhub-pro.sh; then
        echo -e "${C_RED}✗${C_RESET} Erro ao baixar instalador. Verifique sua conexão."
        exit 1
    fi
else
    echo -e "${C_YELLOW}⚠${C_RESET} curl/wget não encontrado. Instalando curl..."
    pkg install curl -y
    curl -fsSL "$INSTALLER_URL" -o install-devhub-pro.sh
fi

echo -e "${C_GREEN}✓${C_RESET} Instalador baixado com sucesso!"
echo ""
echo -e "${C_BLUE}ℹ${C_RESET} Executando instalação completa..."
echo ""

# Torna o script executável e executa
chmod +x install-devhub-pro.sh
bash install-devhub-pro.sh

# Limpa arquivos temporários
cd "$HOME"
rm -rf "$TEMP_DIR"

echo ""
echo -e "${C_GREEN}✓${C_RESET} Instalação concluída!"
echo ""
echo "Execute 'devhub' para começar a usar o ambiente."
echo ""
