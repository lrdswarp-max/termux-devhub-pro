#!/bin/bash
# Simulação DRY-RUN dos módulos
# Verifica o que aconteceria sem realmente executar

set -euo pipefail

C_RESET='\e[0m'
C_GREEN='\e[38;2;100;255;100m'
C_YELLOW='\e[38;2;255;255;100m'
C_RED='\e[38;2;255;100;100m'

echo -e "${C_YELLOW}🔍 SIMULAÇÃO DRY-RUN DO DEVHUB PRO${C_RESET}"
echo ""

simulate_command() {
    local cmd="$1"
    local desc="$2"
    echo -e "${C_YELLOW}▶${C_RESET} $desc"
    echo -e "  Comando: ${C_YELLOW}$cmd${C_RESET}"
    
    # Verificar se comando existe
    local first_cmd=$(echo "$cmd" | awk '{print $1}')
    if command -v "$first_cmd" &>/dev/null; then
        echo -e "  Status: ${C_GREEN}✓ Comando disponível${C_RESET}"
    else
        echo -e "  Status: ${C_RED}✗ Comando NÃO ENCONTRADO${C_RESET}"
    fi
    echo ""
}

echo -e "${C_YELLOW}=== MÓDULO 1: Instalação de Sistema ===${C_RESET}"
simulate_command "pkg update -y" "Atualizar repositórios pkg"
simulate_command "pkg install git -y" "Instalar git"
simulate_command "pkg install nodejs-lts -y" "Instalar Node.js LTS"
simulate_command "termux-setup-storage" "Solicitar permissão de armazenamento"
echo ""

echo -e "${C_YELLOW}=== MÓDULO 2: Node.js e pnpm ===${C_RESET}"
simulate_command "node --version" "Verificar Node.js"
simulate_command "npm install -g pnpm" "Instalar pnpm globalmente"
echo ""

echo -e "${C_YELLOW}=== MÓDULO 3: Shell ===${C_RESET}"
simulate_command "chsh -s zsh" "Mudar shell para Zsh (⚠️ NÃO FUNCIONA NO TERMUX)"
simulate_command "curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sh" "Instalar Oh-My-Zsh"
echo ""

echo -e "${C_YELLOW}=== MÓDULO 4: Ferramentas ===${C_RESET}"
simulate_command "nvim --version" "Verificar Neovim"
simulate_command "tmux -V" "Verificar Tmux"
simulate_command "curl -fLo ~/.config/nvim/autoload/plug.vim https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim" "Instalar vim-plug"
echo ""

echo -e "${C_YELLOW}=== MÓDULO 5: Projeto Next.js ===${C_RESET}"
simulate_command "pnpm create next-app@latest devhub-pwa" "Criar projeto Next.js (⚠️ INTERATIVO)"
simulate_command "pnpm add better-sqlite3" "Instalar better-sqlite3 (⚠️ COMPILAÇÃO)"
simulate_command "git init" "Inicializar repositório Git"
echo ""

echo -e "${C_YELLOW}=== MÓDULO 6: Comando devhub ===${C_RESET}"
simulate_command "chmod +x ~/.local/bin/devhub" "Tornar devhub executável"
echo ""

echo ""
echo -e "${C_YELLOW}=== ANÁLISE DE DISPONIBILIDADE ===${C_RESET}"
echo ""

# Verificar ferramentas essenciais
TOOLS=("bash" "curl" "wget" "git" "node" "npm")

for tool in "${TOOLS[@]}"; do
    if command -v "$tool" &>/dev/null; then
        version=$($tool --version 2>&1 | head -1)
        echo -e "${C_GREEN}✓${C_RESET} $tool: ${C_YELLOW}$version${C_RESET}"
    else
        echo -e "${C_RED}✗${C_RESET} $tool: ${C_RED}NÃO INSTALADO${C_RESET}"
    fi
done

echo ""
echo -e "${C_YELLOW}=== CHECKLIST DE COMPATIBILIDADE ===${C_RESET}"
echo ""

check_file() {
    local file="$1"
    local desc="$2"
    if [[ -f "$file" ]]; then
        echo -e "${C_GREEN}✓${C_RESET} $desc"
    else
        echo -e "${C_RED}✗${C_RESET} $desc ${C_RED}(${file} não existe)${C_RESET}"
    fi
}

check_dir() {
    local dir="$1"
    local desc="$2"
    if [[ -d "$dir" ]]; then
        echo -e "${C_GREEN}✓${C_RESET} $desc"
    else
        echo -e "${C_YELLOW}ℹ${C_RESET} $desc ${C_YELLOW}(será criado)${C_RESET}"
    fi
}

check_file "$HOME/.bashrc" "Arquivo ~/.bashrc"
check_file "$HOME/.zshrc" "Arquivo ~/.zshrc (será criado se não existir)"
check_dir "$HOME/.config" "Diretório ~/.config"
check_dir "$HOME/.local/bin" "Diretório ~/.local/bin (será criado)"
check_dir "$HOME/projects" "Diretório ~/projects (será criado)"

echo ""
echo -e "${C_RED}⚠️  AVISOS IMPORTANTES:${C_RESET}"
echo ""
echo "1. Este script requer Termux (não está rodando em Termux agora)"
echo "2. better-sqlite3 pode falhar em compilação - usar sqlite em vez disso"
echo "3. chsh não funciona no Termux - será ignorado"
echo "4. create-next-app é interativo - pode travar sem entrada"
echo "5. Oh-My-Zsh pode pedir confirmação - pode travar"
echo ""

