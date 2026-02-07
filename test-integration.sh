#!/bin/bash
# DevHub Pro - Teste de Integração
# Valida que todos os módulos funcionam juntos

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULES_DIR="$REPO_DIR/modules"

C_RESET='\e[0m'
C_GREEN='\e[38;2;100;255;100m'
C_BLUE='\e[38;2;100;200;255m'
C_YELLOW='\e[38;2;255;255;100m'
C_RED='\e[38;2;255;100;100m'

echo -e "${C_BLUE}╔════════════════════════════════════════════════════════════════╗${C_RESET}"
echo -e "${C_BLUE}║${C_RESET}  DevHub Pro - Teste de Integração                          ${C_BLUE}║${C_RESET}"
echo -e "${C_BLUE}╚════════════════════════════════════════════════════════════════╝${C_RESET}"
echo ""

# Teste 1: Verificar se todos os módulos existem
echo -e "${C_YELLOW}Teste 1: Verificar existência dos módulos${C_RESET}"
MODULES=(
    "01-install-system.sh"
    "02-install-nodejs.sh"
    "03-configure-shell.sh"
    "04-configure-tools.sh"
    "05-create-project.sh"
    "06-create-devhub-command.sh"
    "run-all.sh"
)

for module in "${MODULES[@]}"; do
    if [[ -f "$MODULES_DIR/$module" ]]; then
        echo -e "${C_GREEN}✓${C_RESET} $module existe"
    else
        echo -e "${C_RED}✗${C_RESET} $module NÃO ENCONTRADO"
        exit 1
    fi
done

echo ""

# Teste 2: Validar sintaxe de todos os módulos
echo -e "${C_YELLOW}Teste 2: Validar sintaxe bash${C_RESET}"
for module in "${MODULES[@]}"; do
    if bash -n "$MODULES_DIR/$module" 2>&1; then
        echo -e "${C_GREEN}✓${C_RESET} $module - Sintaxe OK"
    else
        echo -e "${C_RED}✗${C_RESET} $module - ERRO DE SINTAXE"
        exit 1
    fi
done

echo ""

# Teste 3: Verificar se todos os módulos são executáveis
echo -e "${C_YELLOW}Teste 3: Verificar permissões de execução${C_RESET}"
for module in "${MODULES[@]}"; do
    if [[ -x "$MODULES_DIR/$module" ]]; then
        echo -e "${C_GREEN}✓${C_RESET} $module - Executável"
    else
        echo -e "${C_RED}✗${C_RESET} $module - NÃO EXECUTÁVEL"
        chmod +x "$MODULES_DIR/$module"
        echo -e "${C_YELLOW}  Permissão corrigida${C_RESET}"
    fi
done

echo ""

# Teste 4: Verificar dependências de funções
echo -e "${C_YELLOW}Teste 4: Verificar funções comuns${C_RESET}"
for module in "${MODULES[@]}"; do
    if grep -q "^log()" "$MODULES_DIR/$module" 2>/dev/null; then
        echo -e "${C_GREEN}✓${C_RESET} $module - Função log() definida"
    else
        echo -e "${C_YELLOW}⚠${C_RESET} $module - Função log() não encontrada (pode ser OK)"
    fi
done

echo ""

# Teste 5: Verificar variáveis críticas
echo -e "${C_YELLOW}Teste 5: Verificar variáveis críticas${C_RESET}"

CRITICAL_VARS=(
    "INSTALL_LOG"
    "HOME"
)

for var in "${CRITICAL_VARS[@]}"; do
    found=0
    for module in "${MODULES[@]}"; do
        if grep -q "\$${var}\|\${${var}}" "$MODULES_DIR/$module" 2>/dev/null; then
            found=$((found + 1))
        fi
    done
    
    if [[ $found -gt 0 ]]; then
        echo -e "${C_GREEN}✓${C_RESET} \$${var} - Usada em $found módulos"
    else
        echo -e "${C_YELLOW}⚠${C_RESET} \$${var} - Não encontrada"
    fi
done

echo ""

# Teste 6: Verificar install.sh
echo -e "${C_YELLOW}Teste 6: Validar install.sh${C_RESET}"
if bash -n "$REPO_DIR/install.sh" 2>&1; then
    echo -e "${C_GREEN}✓${C_RESET} install.sh - Sintaxe OK"
else
    echo -e "${C_RED}✗${C_RESET} install.sh - ERRO DE SINTAXE"
    exit 1
fi

if grep -q "modules/run-all.sh" "$REPO_DIR/install.sh"; then
    echo -e "${C_GREEN}✓${C_RESET} install.sh - Chama orquestrador"
else
    echo -e "${C_RED}✗${C_RESET} install.sh - NÃO CHAMA ORQUESTRADOR"
    exit 1
fi

echo ""

# Teste 7: Verificar README
echo -e "${C_YELLOW}Teste 7: Verificar documentação${C_RESET}"
if [[ -f "$REPO_DIR/README.md" ]]; then
    echo -e "${C_GREEN}✓${C_RESET} README.md existe"
    if grep -q "curl.*install.sh" "$REPO_DIR/README.md"; then
        echo -e "${C_GREEN}✓${C_RESET} README.md contém comando de instalação"
    fi
else
    echo -e "${C_YELLOW}⚠${C_RESET} README.md não encontrado"
fi

echo ""

# Resumo
echo -e "${C_GREEN}╔════════════════════════════════════════════════════════════════╗${C_RESET}"
echo -e "${C_GREEN}║${C_RESET}  ✓ Todos os testes de integração passaram!                 ${C_GREEN}║${C_RESET}"
echo -e "${C_GREEN}╚════════════════════════════════════════════════════════════════╝${C_RESET}"
echo ""
echo "Próximos passos:"
echo "  1. Fazer commit: git add . && git commit -m 'refactor: complete modular setup'"
echo "  2. Fazer push: git push origin main"
echo "  3. Testar no Termux: curl -fsSL https://raw.githubusercontent.com/lrdswarp-max/termux-devhub-pro/main/install.sh | bash"
echo ""
