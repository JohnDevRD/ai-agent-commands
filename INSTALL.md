# 📦 Guía de Instalación

Hay **3 formas** de instalar los comandos de `ai-agent-commands` en tu agente de IA.

## 🚀 Opción 1: Instalador interactivo (recomendado)

Elige comandos específicos o categorías completas desde un menú interactivo.

### Linux / macOS / WSL / Git Bash

```bash
# Descargar y ejecutar
curl -fsSL https://raw.githubusercontent.com/GalipoteElDuro/ai-agent-commands/main/install.sh | bash

# O clonar el repo y ejecutar localmente
git clone https://github.com/GalipoteElDuro/ai-agent-commands.git
cd ai-agent-commands
chmod +x install.sh
./install.sh
```

### Windows (PowerShell)

```powershell
# Descargar y ejecutar
iwr -useb https://raw.githubusercontent.com/GalipoteElDuro/ai-agent-commands/main/install.ps1 | iex

# O clonar el repo y ejecutar localmente
git clone https://github.com/GalipoteElDuro/ai-agent-commands.git
cd ai-agent-commands
.\install.ps1
```

> **Nota Windows:** Si obtienes error de ejecución de scripts, ejecuta primero:
> ```powershell
> Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
> ```

### ¿Qué hace el instalador?

1. **Pregunta el destino:**
   - Proyecto actual (`.opencode/commands/`)
   - Global del usuario (`~/.config/opencode/commands/`)
   - Ruta personalizada

2. **Clona/actualiza el catálogo** en `~/.cache/ai-agent-commands/`

3. **Muestra un menú** con todas las categorías:
   ```
   ── Categorías disponibles ──
     1) Git & GitHub (5 comandos)
     2) DevOps (1 comando)
     3) Testing & QA (0 comandos)
     ...
     all) Instalar todo
     q) Salir
   ```

4. **Para cada categoría**, lista los comandos individuales:
   ```
   ── Comandos en: Git & GitHub ──
     1) gen-commit - Genera commit messages profesionales
     2) create-pr - Genera Pull Requests completos
     ...
   Selecciona comandos (ej: 1,3,4 o 'all'): all
   ```

5. **Copia los `.md`** a la carpeta destino

## 📋 Opción 2: Copia manual (rápida)

Si solo quieres algunos comandos, cópialos manualmente:

### Para OpenCode

```bash
# A nivel proyecto
mkdir -p .opencode/commands
cp ruta/al/repo/git/gen-commit.md .opencode/commands/
cp ruta/al/repo/git/create-pr.md .opencode/commands/

# A nivel global
mkdir -p ~/.config/opencode/commands
cp ruta/al/repo/git/*.md ~/.config/opencode/commands/
```

### Para Claude Code

```bash
mkdir -p .claude/commands
cp ruta/al/repo/git/*.md .claude/commands/
```

### Para Cline (VSCode)

```bash
mkdir -p .clinerules
cp ruta/al/repo/git/*.md .clinerules/
```

### Para Cursor

```bash
mkdir -p .cursor/commands
cp ruta/al/repo/git/*.md .cursor/commands/
```

## 🛠️ Opción 3: Como submódulo Git (para mantener actualizado)

Si quieres mantener los comandos actualizados en tu proyecto:

```bash
# Agregar como submódulo
git submodule add https://github.com/GalipoteElDuro/ai-agent-commands.git .ai-commands

# Crear symlinks a las categorías que quieras
mkdir -p .opencode/commands
ln -s ../../.ai-commands/git/gen-commit.md .opencode/commands/gen-commit.md
ln -s ../../.ai-commands/git/create-pr.md .opencode/commands/create-pr.md

# Para actualizar
git submodule update --remote
```

## 🗑️ Desinstalar

### Si usaste el instalador interactivo

Simplemente borra los archivos de la carpeta destino:

```bash
# Linux/macOS
rm -rf ~/.config/opencode/commands/*

# Windows PowerShell
Remove-Item "$env:USERPROFILE\.config\opencode\commands\*" -Recurse -Force

# Proyecto local
rm -rf .opencode/commands/*
```

### Si usaste copia manual

Borra los `.md` que copiaste:

```bash
# Ejemplo: borrar comandos de Git que ya no quieres
rm .opencode/commands/gen-commit.md
rm .opencode/commands/create-pr.md
```

## 🔄 Actualizar comandos

### Si usaste el instalador interactivo

```bash
# Re-ejecuta el instalador (sobrescribirá los archivos)
./install.sh   # o .\install.ps1 en Windows
```

El instalador detecta automáticamente los archivos existentes y los sobrescribe.

### Si usaste copia manual

```bash
# Vuelve a copiar los archivos desde el repo
cp ruta/al/repo/git/*.md .opencode/commands/
```

### Si usaste submódulo Git

```bash
git submodule update --remote
```

## 📂 Ubicaciones de instalación soportadas

| Agente | Proyecto | Global |
|--------|----------|--------|
| **OpenCode** | `.opencode/commands/` | `~/.config/opencode/commands/` |
| **Claude Code** | `.claude/commands/` | `~/.claude/commands/` |
| **Cline** | `.clinerules/commands/` | — |
| **Cursor** | `.cursor/commands/` | — |

## 🆘 Solución de problemas

### El comando no aparece en mi agente

1. **Verifica la ubicación:** asegúrate de que el archivo `.md` esté en la carpeta correcta
2. **Reinicia el agente:** algunos agentes requieren recargar para detectar nuevos comandos
3. **Verifica el frontmatter:** el archivo debe empezar con `---` y tener `description:`

### El instalador no puede clonar el repo

Si estás detrás de un proxy o firewall, descarga el repo manualmente:

```bash
git clone https://github.com/GalipoteElDuro/ai-agent-commands.git
cd ai-agent-commands
./install.sh   # Detectará que ya tienes el repo local
```

### Windows: "no se puede cargar el script"

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

## 💬 ¿Más ayuda?

Abre un [Issue](https://github.com/GalipoteElDuro/ai-agent-commands/issues) 🚀