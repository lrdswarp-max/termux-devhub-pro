# 🔧 Troubleshooting - DevHub Pro em Termux

**Última atualização:** 7 de Fevereiro de 2026

---

## ⚠️ Problemas Comuns e Soluções

### 1. Hot Reload (HMR) não funciona ou está muito lento

**Sintomas:**
```
- Editar arquivo no editor
- Página no navegador não atualiza automaticamente
- Precisa fazer F5 manual
```

**Causa:** Termux tem suporte limitado a inotify (file watching)

**Solução:**
```bash
# Verificar .env.local (deve ter):
cat ~/projects/devhub-pwa/.env.local | grep WATCHPACK

# Esperar output:
# WATCHPACK_POLLING=1000
# NODE_FILE_WATCHER=polling

# Se não tiver, adicione manualmente:
echo "WATCHPACK_POLLING=1000" >> ~/projects/devhub-pwa/.env.local
echo "NODE_FILE_WATCHER=polling" >> ~/projects/devhub-pwa/.env.local

# Reiniciar servidor dev:
cd ~/projects/devhub-pwa
pnpm dev
```

---

### 2. Instalação falha com erro de compilação (better-sqlite3)

**Erro típico:**
```
gyp ERR! configure error
gyp ERR! stack Error: Can't find Python executable python
```

**Causa:** `better-sqlite3` requer compilação nativa, que precisa de build-tools

**Solução:**
```bash
# Opção 1: Usar sqlite3 ao invés (SEM compilação) ✅ RECOMENDADO
cd ~/projects/devhub-pwa
pnpm remove better-sqlite3
pnpm add sqlite

# Opção 2: Instalar build-tools (adiciona 200MB)
pkg install -y build-essential clang
pnpm install  # Fazer rebuild

# Opção 3: Usar Supabase remoto (sem DB local)
# Editar .env.local e configurar variáveis Supabase
```

---

### 3. Build leva muito tempo (5-10 minutos)

**Causa:** Termux tem CPU mais fraca que PC, Node.js é pesado

**Informação útil:**
```
Tempo típico de build em Termux:
├─ PC RÁPIDO:     5 segundos
├─ PC MEDIANO:    15 segundos
├─ Termux (4GB):  2-5 minutos
├─ Termux (2GB):  5-15 minutos
└─ Termux (1GB):  Pode não completar ❌
```

**Soluções:**
```bash
# 1. Reduzir complexidade do projeto
#    - Remover componentes não-essenciais
#    - Reduzir bundle size

# 2. Usar SSD externo (se dispositivo suporta)
#    - Muito mais rápido que SD card

# 3. Plugar em carregador
#    - Evita throttling de CPU

# 4. Fechar outros apps
#    - Libera RAM para Node.js
```

---

### 4. Neovim está lento ou freezando

**Causa:** Config com muitos plugins e LSP

**Solução - Already applied:**
```
init.lua foi OTIMIZADO para Termux:
✓ Desabilita true colors (termguicolors = false)
✓ Plugins pesados removidos
✓ updatetime = 1000 para melhor responsividade
✓ Apenas funcionalidades essenciais
```

**Se ainda está lento:**
```bash
# Testar com config minimal:
nvim --noplugin ~/.config/nvim/init.lua

# Se isso é rápido, problema é plugin específico
# Ver logs:
nvim --cmd "set verbose=20" ~/.config/nvim/init.lua 2>&1 | tail

# Remover plugins individualmente de init.lua
```

---

### 5. Espaço em disco cheio

**Causa:**
```
Node.js + node_modules = 500+ MB
Projeto Next.js = 100+ MB
Build artifacts = 200+ MB
─────────────────────────
Total = 800+ MB
```

**Liberar espaço:**
```bash
# Limpar cache npm/pnpm
pnpm store prune
npm cache clean --force

# Remover node_modules (depois refaz)
cd ~/projects/devhub-pwa
rm -rf node_modules
pnpm install

# Remover .next build (próximo dev vai recriar)
rm -rf .next

# Verificar tamanho
du -sh ~/projects/devhub-pwa
du -sh ~/.npm-global
du -sh ~/node_modules  # Se existir

# Se ainda estiver full, considerar
# Deletar projeto e reinstalar
```

---

### 6. RAM insuficiente (dispositivo travando)

**Síntomas:**
```
- Sistema fica muito lento ao rodar dev server
- Apps fecham sozinhos
- Temperatura alta
```

**Verificar RAM disponível:**
```bash
free -h
# Interpretar:
# Mem: 4Gi (total) 2.5Gi (usado) 1.5Gi (disponível)
# Você tem ~1.5Gi livre
```

**Soluções:**
```bash
# 1. Fechar apps desnecessários

# 2. Usar Termux-App settings
#    Settings > Resources > Increase heap

# 3. Compilar versão "lite" do Next.js
#    Remover Tailwind, usar CSS puro

# 4. Considerar dispositivo com 6GB+ RAM
#    4GB é mínimo, 6GB+ é confortável
```

---

### 7. Git não funciona ou falha ao fazer commit

**Erro típico:**
```
fatal: could not open repository
fatal: not a git repository
```

**Solução:**
```bash
# Verificar se git foi inicializado
cd ~/projects/devhub-pwa
git status

# Se falhar, reinicializar
git init
git add .
git commit -m "Initial commit"

# Configurar user (se não fez)
git config --global user.email "you@example.com"
git config --global user.name "Your Name"
```

---

### 8. Comando `devhub` não funciona

**Erro:**
```
zsh: command not found: devhub
bash: devhub: command not found
```

**Causa:** PATH não foi atualizado após instalação

**Solução:**
```bash
# Recarregar shell
source ~/.bashrc
source ~/.zshrc

# Se mesmo assim não funcionar:
echo $PATH | grep ".local/bin"

# Se não aparecer, adicione ao .bashrc:
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Testar
which devhub
devhub
```

---

### 9. Zsh não inicia ou não encontra Oh-My-Zsh

**Erro:**
```
zsh: command not found: oh-my-zsh
```

**Solução:**
```bash
# Recarregar do source
source ~/.bashrc

# Se não existir, reinstalar
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Se mesmo assim não funcionar, voltar a bash
# Edit ~/.bashrc e remova linha:
# exec zsh
```

---

### 10. pnpm install falha ou travanca

**Causa:**
```
- Sem espaço em disco
- Sem RAM suficiente
- Sem conexão internet estável
- npm cache corrompido
```

**Solução:**
```bash
# 1. Limpar cache
pnpm store prune
npm cache clean --force

# 2. Reinstalar dependências
rm -rf node_modules pnpm-lock.yaml
pnpm install

# 3. Se falhar, tentar com npm ao invés
npm install --force

# 4. Se ainda falhar, verificar conexão
ping google.com

# 5. Reinsecrever .npmrc
cat > ~/.npmrc << 'EOF'
registry=https://registry.npmjs.org/
fetch-timeout=120000
fetch-retry-mintimeout=20000
fetch-retry-maxtimeout=120000
EOF
pnpm install
```

---

## 📱 Performance Tips para Termux

### Como optimizar desenvolvimento:

1. **Use tmux para sessões**
   ```bash
   tmux new-session -s dev
   ```

2. **Plugar em carregador** durante dev
   - Evita throttling de CPU
   - Deixa mais rápido

3. **Usar Wi-Fi 5GHz** se disponível
   - Mais estável que 2.4GHz

4. **Fechar navegador** enquanto desenvolve
   - Economiza RAM

5. **Usar hardware mais novo** (2022+)
   - Difference de performance é enorme

### Esperado vs Real:

```
ESPERADO               REAL (Termux)
──────────────────────────────────
pnpm dev:    3s       pnpm dev:    5-10s
build:       5s       build:       2-5 min
hot reload:  instant  hot reload:  5-15s delay
```

---

## 🆘 Ainda não resolveu?

Antes de reportar issue:

1. ✅ Rode `bash test-integration.sh`
2. ✅ Verifique se está em Termux real (não emulador)
3. ✅ Rode `free -h` e `df -h` (verifique RAM e storage)
4. ✅ Recarregue shell: `source ~/.bashrc`
5. ✅ Clean install: `rm -rf ~/projects/devhub-pwa` e reinstale

Se problema persiste:
- Colete logs: `cat ~/.devhub/install.log`
- Abra issue no GitHub com logs
- Inclua: RAM disponível, storage, versão Android

---

## 📚 Recursos Úteis

- **Termux Wiki:** https://wiki.termux.com
- **Termux GitHub:** https://github.com/termux/termux-app
- **Next.js Docs:** https://nextjs.org/docs
- **Drizzle ORM:** https://orm.drizzle.team

---

**Versão 1.0** | 7 de Fevereiro de 2026
