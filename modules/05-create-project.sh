#!/bin/bash
# DevHub Pro - Módulo 5: Criação do Projeto Next.js PWA
# Responsabilidade: Criar projeto Next.js 15 com PWA

set -euo pipefail

INSTALL_LOG="${HOME}/.devhub/install.log"
PROJECT_DIR="${HOME}/projects/devhub-pwa"

log() {
    local level="$1"
    shift
    local msg="$*"
    echo "[$(date '+%H:%M:%S')] [$level] $msg" | tee -a "$INSTALL_LOG"
}

log "INFO" "=== FASE 5: Criação do Projeto Next.js PWA ==="

# Criar diretório do projeto
log "INFO" "Criando diretório do projeto..."
mkdir -p "$HOME/projects"

if [[ -d "$PROJECT_DIR" ]]; then
    log "WARN" "Projeto já existe em $PROJECT_DIR"
    exit 0
fi

# Criar projeto com create-next-app
log "INFO" "Criando projeto Next.js 15..."
cd "$HOME/projects"

echo "" | pnpm create next-app@latest devhub-pwa \
    --typescript \
    --tailwind \
    --eslint \
    --app \
    --no-git \
    --import-alias '@/*' 2>&1 | tee -a "$INSTALL_LOG" || {
    log "ERROR" "Falha ao criar projeto Next.js"
    exit 1
}

cd "$PROJECT_DIR"

# Instalar dependências adicionais
log "INFO" "Instalando dependências adicionais..."
pnpm add next-pwa sqlite drizzle-orm 2>&1 | tee -a "$INSTALL_LOG" || {
    log "WARN" "Falha ao instalar algumas dependências (continuando...)"
}

pnpm add -D drizzle-kit 2>&1 | tee -a "$INSTALL_LOG" || {
    log "WARN" "Falha ao instalar drizzle-kit (continuando...)"
}

# Criar estrutura de banco de dados
log "INFO" "Criando estrutura de banco de dados..."
mkdir -p src/db

cat > src/db/index.ts << 'EOF'
import { drizzle } from 'drizzle-orm/node-sqlite'
import Database from 'better-sqlite3'

const sqlite = new Database('./sqlite.db')
export const db = drizzle(sqlite)
EOF

cat > src/db/schema.ts << 'EOF'
import { sqliteTable, text, integer } from 'drizzle-orm/sqlite-core'

export const users = sqliteTable('users', {
  id: integer('id').primaryKey(),
  email: text('email').notNull().unique(),
  name: text('name'),
  createdAt: integer('created_at', { mode: 'timestamp' }).$defaultFn(() => new Date()),
})
EOF

# Criar arquivo .env.local com configurações Termux
log "INFO" "Criando arquivo .env.local..."
# Placeholder
# Placeholder
# Placeholder

# Supabase (opcional)
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=

# App
NEXT_PUBLIC_APP_URL="http://localhost:3000"

# Performance em Termux
WATCHPACK_POLLING=1000
NODE_FILE_WATCHER=polling
EOF

# Inicializar Git
log "INFO" "Inicializando repositório Git..."
git init 2>&1 | tee -a "$INSTALL_LOG" || log "WARN" "Git já inicializado"
git add . 2>&1 | tee -a "$INSTALL_LOG" || true
git commit -m "feat: initial commit - DevHub Pro PWA" 2>&1 | tee -a "$INSTALL_LOG" || true

log "SUCCESS" "Fase 5 concluída: Projeto Next.js criado em $PROJECT_DIR"
