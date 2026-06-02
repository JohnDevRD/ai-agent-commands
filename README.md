# 🤖 ai-agent-commands

> Catálogo open source de comandos personalizados para agentes de IA (OpenCode, Claude Code, Cline, Cursor, etc.)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Open Source Love](https://badges.frapsoft.com/os/v1/open-source.svg?v=103)](https://github.com/ellerbrock/open-source-badges/)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

## ¿Qué es esto?

Un **catálogo modular** de comandos slash (`/commit`, `/docker`, `/pr`...) diseñados para ejecutarse dentro de agentes de IA como **OpenCode**, **Claude Code**, **Cline** o **Cursor**.

Cada comando es un archivo `.md` con **frontmatter YAML** que define instrucciones de sistema especializadas. El catálogo está **organizado por categorías** y puedes instalar solo las que necesites.

## ✨ Características

- 📦 **Modular** — instala solo los comandos que uses
- 🏷️ **Organizado por categoría** — Git, DevOps, Testing, etc.
- 🔌 **Multi-agente** — compatible con OpenCode, Claude Code, Cline, Cursor
- 🆓 **Open source** — contribuciones bienvenidas
- 📚 **Documentado** — cada comando tiene frontmatter + descripción
- 🚀 **Escalable** — agregar nuevos comandos es muy simple

## 📋 Comandos disponibles

### 🔀 Git & GitHub (`git/`)

| Comando | Descripción |
|---------|-------------|
| `/gen-commit` | Genera commit messages profesionales (Conventional Commits) |
| `/create-pr` | Genera Pull Requests completos y listos para publicar |
| `/create-issue` | Crea Issues de GitHub desde una descripción manual |
| `/detect-issues` | Detecta Issues automáticamente analizando el repositorio |
| `/create-branch` | Genera nombres de rama desde Issues de GitHub |

### 🚀 DevOps & Infrastructure (`devops/`)

| Comando | Descripción |
|---------|-------------|
| `/gen-docker` | Analiza un proyecto y genera Dockerfiles + docker-compose optimizados |

### 🧪 Testing & QA (`testing/`)
_Próximamente..._

### 📚 Documentation (`docs/`)
_Próximamente..._

### ♻️ Refactoring (`refactor/`)
_Próximamente..._

### 🔍 Code Review (`review/`)
_Próximamente..._

### 🗄️ Database (`database/`)
_Próximamente..._

### 🔌 API & REST (`api/`)
_Próximamente..._


## 🚀 Instalación rápida

### Opción 1: Instalador interactivo (recomendado)

**Linux / macOS / WSL / Git Bash:**

```bash
curl -fsSL https://raw.githubusercontent.com/JohnDevRD/ai-agent-commands/main/install.sh | bash
```

**Windows (PowerShell):**

```powershell
iwr -useb https://raw.githubusercontent.com/JohnDevRD/ai-agent-commands/main/install.ps1 | iex
```

El instalador te guiará con un menú interactivo para elegir:

- 🎯 Destino (proyecto o global)
- 📦 Categoría completa o comandos específicos
- 🔄 Sobrescribir versiones existentes

Verás algo como:

```
╔════════════════════════════════════════════╗
║  🤖 AI Agent Commands - Instalador       ║
╚════════════════════════════════════════════╝

── Destino de instalación ──
  1) Proyecto actual (./.opencode/commands/)
  2) Global del usuario (~/.config/opencode/commands/)
  3) Personalizado
Elige una opción [1]: 1

── Categorías disponibles ──
  1) Git & GitHub (5 comandos)
  2) DevOps & Infrastructure (1 comando)
  3) Testing & QA (0 comandos)
  ...
  all) Instalar todo
  q) Salir
Selecciona categoría, 'all' o 'q' [1]: 1
```

### Opción 2: Copia manual (rápida)

Copia los archivos `.md` de la categoría que te interese directamente a la carpeta de comandos de tu agente:

```bash
# OpenCode - Proyecto
mkdir -p .opencode/commands
cp git/*.md .opencode/commands/

# OpenCode - Global
mkdir -p ~/.config/opencode/commands
cp git/*.md ~/.config/opencode/commands/

# Claude Code - Proyecto
mkdir -p .claude/commands
cp git/*.md .claude/commands/

# Cline (VSCode)
mkdir -p .clinerules/commands
cp git/*.md .clinerules/commands/

# Cursor
mkdir -p .cursor/commands
cp git/*.md .cursor/commands/
```

### Opción 3: Como submódulo Git (para mantener actualizado)

```bash
# Agregar como submódulo
git submodule add https://github.com/JohnDevRD/ai-agent-commands.git .ai-commands

# Crear symlinks a las categorías que quieras
mkdir -p .opencode/commands
ln -s ../../.ai-commands/git/gen-commit.md .opencode/commands/
ln -s ../../.ai-commands/git/create-pr.md .opencode/commands/

# Para actualizar
git submodule update --remote
```

Ver [INSTALL.md](INSTALL.md) para más detalles y solución de problemas.

## 🔧 Uso

Una vez instalados, los comandos están disponibles dentro de tu agente de IA:

```
> /gen-commit

# El agente analiza el git diff y genera un commit message profesional

> /gen-docker

# El agente analiza tu proyecto y genera Dockerfile + docker-compose
```


## 📁 Estructura del repositorio

```
ai-agent-commands/
├── 📂 git/              # Git & GitHub (5 comandos)
│   ├── gen-commit.md
│   ├── create-pr.md
│   ├── create-issue.md
│   ├── detect-issues.md
│   ├── create-branch.md
│   └── manifest.json
│
├── 📂 devops/           # DevOps & Infrastructure (1 comando)
│   ├── gen-docker.md
│   └── manifest.json
│
├── 📂 testing/          # Testing & QA
├── 📂 docs/             # Documentation
├── 📂 refactor/         # Refactoring
├── 📂 review/           # Code Review
├── 📂 database/         # Database
├── 📂 api/              # API & REST
├── 📂 security/         # Security
│
├── 📄 install.sh        # Instalador Linux/macOS/WSL
├── 📄 install.ps1       # Instalador Windows PowerShell
├── 📄 INSTALL.md        # Guía detallada de instalación
├── 📄 README.md
├── 📄 LICENSE
├── 📄 CONTRIBUTING.md
└── 📄 .gitignore
```

## 📝 Convención de nomenclatura

Todos los comandos siguen el patrón **`<verbo>-<objeto>`**:

- ✅ `gen-commit` (no `commit-message-helper`)
- ✅ `create-pr` (no `createACommit`)
- ✅ `detect-issues` (no `cmt`)

### Reglas:

1. Solo minúsculas, sin tildes
2. Empezar con verbo (`gen`, `create`, `detect`, `review`, `explain`...)
3. Máximo 3 palabras separadas por guiones
4. Sin prefijos redundantes (`ai-`, `opencode-`...)

## 🤝 Contribuir

¡Las contribuciones son bienvenidas! 🎉

1. Fork el repo
2. Crea una rama: `git checkout -b feat/my-new-command`
3. Agrega tu comando en la categoría correspondiente
4. Actualiza el `manifest.json` de esa categoría
5. Commit: `git commit -m "feat: add my-new-command"`
6. Push: `git push origin feat/my-new-command`
7. Abre un Pull Request

Lee [CONTRIBUTING.md](CONTRIBUTING.md) para más detalles.

## 📜 Licencia

Este proyecto está bajo la Licencia MIT. Ver [LICENSE](LICENSE) para más detalles.

## 🌟 Agradecimientos

- Inspirado por la necesidad de tener comandos reutilizables entre proyectos
- Compatible con el formato de [OpenCode](https://opencode.ai), [Claude Code](https://claude.ai/code), [Cline](https://github.com/cline/cline) y similares
- Hecho con ❤️ para la comunidad open source

---

**¿Encontraste útil este catálogo?** ⭐ Dale una estrella al repo y compártelo con tu equipo.
### 🔒 Security (`security/`)
_Próximamente..._
