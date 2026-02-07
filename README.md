# 🚀 Termux DevHub Pro v3.0

> **Ambiente de desenvolvimento PWA profissional para Android/Termux**  
> **100% Nativo • 3x Mais Rápido • 15-20 Minutos • Zero Config**

---

## ✨ O que é o DevHub Pro?

O **Termux DevHub Pro v3.0** é um ambiente de desenvolvimento completo e otimizado para criar Progressive Web Apps (PWAs) profissionais diretamente no seu dispositivo Android usando o Termux.

### 🎯 Características Principais

- ✅ **100% Nativo** - Sem virtualização, performance máxima
- ⚡ **3x Mais Rápido** - 15-20 minutos de instalação vs 45 minutos das versões anteriores
- 🛠️ **Stack Moderna** - Next.js 15, TypeScript 5, Tailwind CSS 3.4
- 📝 **Neovim Configurado** - Editor moderno com LSP, autocompletion e plugins
- 🗄️ **Database Pronto** - SQLite local + Supabase remoto com Drizzle ORM
- 🎨 **Tmux + Zsh** - Terminal profissional com sessões persistentes
- 🚀 **Deploy Fácil** - Integração com Vercel CLI

---

## 📦 Instalação Rápida

### Pré-requisitos

- **Termux** instalado via [F-Droid](https://f-droid.org/packages/com.termux/) (⚠️ NÃO use a versão da Play Store)
- **Android 8+** (API 26+)
- **4GB+ de espaço livre**
- **Conexão Wi-Fi** estável (recomendado)

### Método 1: Instalação via curl (Recomendado)

```bash
curl -fsSL https://raw.githubusercontent.com/lrdswarp-max/termux-devhub-pro/main/install-devhub-pro.sh | bash
```

### Método 2: Clone e Execute

```bash
# Clone o repositório
git clone https://github.com/lrdswarp-max/termux-devhub-pro.git

# Entre no diretório
cd termux-devhub-pro

# Execute o instalador
bash install-devhub-pro.sh
```

### Método 3: Download Direto

```bash
# Configure o repositório do Termux (selecione o mirror mais próximo)
termux-change-repo

# Instale o curl
pkg install curl

# Baixe o script
curl -O https://raw.githubusercontent.com/lrdswarp-max/termux-devhub-pro/main/install-devhub-pro.sh

# Execute
bash install-devhub-pro.sh
```

---

## 🏗️ O que será instalado?

### Core Stack
- **Node.js LTS** - Runtime JavaScript
- **pnpm** - Gerenciador de pacotes ultra-rápido
- **Git** - Controle de versão
- **Python** - Para ferramentas auxiliares
- **OpenSSH** - Acesso remoto

### Ambiente de Desenvolvimento
- **Neovim 0.9+** - Editor moderno com configuração Lua
  - LSP (TypeScript, ESLint, Tailwind)
  - Telescope (fuzzy finder)
  - nvim-tree (explorador de arquivos)
  - tokyonight theme
- **Tmux 3.x** - Multiplexador de terminal
- **Zsh + Oh-My-Zsh** - Shell avançado com autosuggestions

### Framework & Libraries
- **Next.js 15** - Framework React com App Router
- **TypeScript 5** - Tipagem estática
- **Tailwind CSS 3.4** - Framework CSS utility-first
- **next-pwa** - Suporte PWA com Workbox
- **Zustand** - Gerenciamento de estado
- **Zod** - Validação de schemas
- **React Hook Form** - Formulários performáticos

### Database
- **SQLite** - Database local zero-config
- **Drizzle ORM** - ORM type-safe moderno
- **Supabase** (opcional) - PostgreSQL remoto com Auth e Real-time

### Deployment
- **Vercel CLI** - Deploy em segundos

---

## 🎮 Usando o DevHub

Após a instalação, use o comando `devhub` para acessar o menu interativo:

```bash
devhub
```

### Menu Interativo

```
╔══════════════════════════════════════════════════════════╗
║              D E V H U B   P R O   v3.0                  ║
╚══════════════════════════════════════════════════════════╝

  1) 🚀  Iniciar dev server        pnpm dev
  2) 📦  Instalar dependências     pnpm install
  3) 🏗️   Build produção           pnpm build
  4) ☁️   Deploy Vercel           vercel --prod
  5) 🗄️   Database studio         drizzle-kit studio
  6) 📝  Abrir Neovim             nvim .
  7) 🌐  Abrir navegador          termux-open-url
  8) 🔄  Git status               git status
  9) 📊  Monitor sistema          htop
  0) 🚪  Sair

Escolha: _
```

---

## 📝 Comandos Úteis

### Desenvolvimento
```bash
cd ~/projects/devhub-pwa
pnpm dev              # Iniciar servidor de desenvolvimento
pnpm build            # Build para produção
pnpm start            # Iniciar servidor de produção
```

### Neovim
```bash
nvim .                # Abrir projeto no Neovim
# Dentro do Neovim:
# <Space>e - Abrir/fechar file explorer
# <Space>f - Buscar arquivos
# <Space>g - Buscar no código
# <Ctrl-\> - Terminal flutuante
```

### Tmux
```bash
tmux                  # Iniciar nova sessão
tmux attach           # Reconectar à sessão
# Dentro do tmux:
# Ctrl-a c - Nova janela
# Ctrl-a n - Próxima janela
# Ctrl-a p - Janela anterior
# Ctrl-a d - Desconectar (sessão continua rodando)
```

### Database
```bash
drizzle-kit studio    # Abrir interface web do database
drizzle-kit push      # Aplicar mudanças no schema
drizzle-kit generate  # Gerar migrations
```

---

## 🔧 Estrutura do Projeto

```
~/projects/devhub-pwa/
├── src/
│   ├── app/              # App Router do Next.js
│   ├── components/       # Componentes React
│   ├── db/              # Configuração do database
│   │   ├── index.ts     # Cliente Drizzle
│   │   └── schema.ts    # Schema do database
│   └── lib/             # Utilitários
├── public/
│   ├── manifest.json    # Manifest PWA
│   └── icons/           # Ícones da PWA
├── drizzle.config.ts    # Configuração Drizzle
├── next.config.js       # Configuração Next.js
├── tailwind.config.ts   # Configuração Tailwind
└── package.json         # Dependências
```

---

## 🚀 Deploy

### Vercel (Recomendado)

```bash
# Login na Vercel
vercel login

# Deploy
vercel --prod
```

### Outras Plataformas

O projeto é compatível com:
- Netlify
- Railway
- Render
- Cloudflare Pages

---

## 📚 Documentação Adicional

- [README-FINAL.md](README-FINAL.md) - Documentação completa e detalhada
- [README-DEVHUB-PRO.md](README-DEVHUB-PRO.md) - Guia técnico avançado
- [RESUMO-REVISAO.md](RESUMO-REVISAO.md) - Resumo das melhorias da v3.0
- [LEIA-ME.txt](LEIA-ME.txt) - Notas importantes

---

## 🐛 Solução de Problemas

### Erro de permissão no Termux
```bash
termux-setup-storage
```

### Erro ao instalar pacotes
```bash
termux-change-repo  # Selecione outro mirror
pkg update && pkg upgrade
```

### Neovim não inicia plugins
```bash
nvim
:PlugInstall
:TSInstall typescript javascript json css html
```

### Servidor não inicia
```bash
# Verifique se a porta está livre
lsof -i :3000
# Ou use outra porta
PORT=3001 pnpm dev
```

---

## 🤝 Contribuindo

Contribuições são bem-vindas! Sinta-se à vontade para:

1. Fazer fork do projeto
2. Criar uma branch para sua feature (`git checkout -b feature/MinhaFeature`)
3. Commit suas mudanças (`git commit -m 'Adiciona MinhaFeature'`)
4. Push para a branch (`git push origin feature/MinhaFeature`)
5. Abrir um Pull Request

---

## 📄 Licença

Este projeto é open source e está disponível sob a licença MIT.

---

## 🙏 Agradecimentos

- Comunidade Termux
- Equipe Next.js
- Criadores do Neovim
- Todos os contribuidores de código aberto

---

## 📞 Suporte

Se encontrar problemas ou tiver dúvidas:

1. Verifique a [documentação completa](README-FINAL.md)
2. Abra uma [issue](https://github.com/lrdswarp-max/termux-devhub-pro/issues)
3. Consulte a comunidade Termux

---

**Desenvolvido com ❤️ para a comunidade Termux**
