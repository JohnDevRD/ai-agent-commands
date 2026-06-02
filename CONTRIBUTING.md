# 🤝 Guía para Contribuir

¡Gracias por tu interés en contribuir a **ai-agent-commands**! 🎉

Este catálogo es open source y toda ayuda es bienvenida: nuevos comandos, correcciones, mejoras de documentación, reportes de bugs, etc.

## 📋 Tabla de contenidos

- [Código de conducta](#código-de-conducta)
- [¿Cómo puedo contribuir?](#cómo-puedo-contribuir)
- [Reportar un bug](#reportar-un-bug)
- [Sugerir un comando nuevo](#sugerir-un-comando-nuevo)
- [Agregar un comando (Pull Request)](#agregar-un-comando-pull-request)
- [Convención de nomenclatura](#convención-de-nomenclatura)
- [Estructura de un comando](#estructura-de-un-comando)
- [Estilo del prompt](#estilo-del-prompt)

## Código de conducta

Este proyecto se adhiere a un código de conducta simple: **sé respetuoso, constructivo y profesional**. Estamos aquí para construir algo útil juntos.

## ¿Cómo puedo contribuir?

Hay varias formas de ayudar:

1. 🐛 **Reportar bugs** — si encontraste un comando que no funciona bien
2. 💡 **Sugerir comandos nuevos** — propone ideas para el catálogo
3. 📝 **Mejorar comandos existentes** — corrige, refina o expande prompts
4. 🆕 **Agregar comandos nuevos** — tu PR con un comando bien diseñado
5. 📚 **Mejorar documentación** — README, ejemplos, guías
6. 🎨 **Crear el instalador interactivo** — script `install.sh` / `install.ps1`

## Reportar un bug

Abre un [Issue](../../issues/new) con:

- **Título claro:** `[Bug] /gen-commit no detecta archivos staged`
- **Comando afectado:** `git/gen-commit.md`
- **Pasos para reproducir:** qué hiciste, qué esperabas, qué pasó
- **Entorno:** agente usado (OpenCode, Claude Code, etc.), versión, OS

## Sugerir un comando nuevo

Abre un [Issue](../../issues/new) con etiqueta `[Feature]`:

- **Nombre propuesto:** `explain-error`
- **Categoría:** `git`, `devops`, `testing`, etc.
- **Descripción:** qué problema resuelve
- **Ejemplo de uso:** cómo se invocaría

## Agregar un comando (Pull Request)

### 1. Fork y clona

```bash
git clone https://github.com/tu-usuario/ai-agent-commands.git
cd ai-agent-commands
```

### 2. Crea una rama

```bash
git checkout -b feat/mi-nuevo-comando
```

### 3. Crea el archivo del comando

Ubícalo en la **categoría correcta**:

```
categoría/nombre-comando.md
```

Por ejemplo: `testing/gen-tests.md`

### 4. Usa el frontmatter YAML

Todos los comandos deben empezar con frontmatter válido:

```markdown
---
description: Descripción breve de una línea (máx 100 chars)
agent: build
tags: [tag1, tag2, tag3]

### 5. Actualiza el `manifest.json` de la categoría

Edita el archivo `manifest.json` de la categoría y agrega tu comando:

```json
{
  "name": "testing",
  "displayName": "Testing & QA",
  "commands": [
    {
      "id": "gen-tests",
      "file": "gen-tests.md",
      "description": "Genera tests unitarios a partir del código",
      "tags": ["testing", "unit-tests", "automation"],
      "slashCommand": "/gen-tests"
    }
  ]
}
```

### 6. Verifica localmente

- Abre el archivo en tu agente de IA
- Ejecuta el comando
- Confirma que funciona como esperas

### 7. Commit y Push

```bash
git add .
git commit -m "feat(testing): add /gen-tests command"
git push origin feat/mi-nuevo-comando
```

### 8. Abre un Pull Request

- Título: `feat(testing): add /gen-tests command`
- Descripción: qué hace, por qué, cómo probarlo
- Referencia el Issue si existe: `Closes #123`

## Convención de nomenclatura

Todos los comandos siguen el patrón **`<verbo>-<objeto>`**.

### Verbos comunes (usa estos consistentemente)

| Verbo | Cuándo usarlo |
|-------|---------------|
| `gen` | Generar algo nuevo (commit, doc, test) |
| `create` | Crear algo externo (PR, issue, branch) |
| `detect` | Detectar/analizar (issues, bugs) |
| `review` | Revisar/auditar (code, security) |
| `explain` | Explicar (code, error) |
| `refactor` | Refactorizar |
| `optimize` | Optimizar |
| `fix` | Corregir |
| `doc` | Documentar |
| `scan` | Escanear |
| `convert` | Convertir |
| `validate` | Validar |

### Reglas estrictas

- ✅ Solo minúsculas (a-z)
- ✅ Solo letras, números y guiones
- ✅ Sin tildes ni eñes
- ✅ Sin caracteres especiales
- ✅ Empezar con verbo
- ✅ Máximo 3 palabras
- ❌ Sin prefijos redundantes (`ai-`, `agent-`...)
- ❌ Sin sufijos de versión (`-v2`, `-final`)
- ❌ Sin camelCase

### Ejemplos

| ✅ Válido | ❌ Inválido |
|-----------|------------|
| `gen-commit` | `commit-message-helper` |
| `create-pr` | `createACommit` |
| `detect-issues` | `cmt` |
| `gen-tests-unit` | `gen-commit-thing-v2` |
| `review-security` | `ai-gen-commit` |

## Estructura de un comando

Un buen comando tiene esta estructura:

```markdown
---
description: <descripción corta>
agent: <agente>
tags: [<tags>]
---

<Contexto del rol del agente>

═══════════════════════════════════════════
PASO 1 — <nombre del paso>
═══════════════════════════════════════════

<instrucciones detalladas>

═══════════════════════════════════════════
PASO 2 — <nombre del paso>
═══════════════════════════════════════════

<instrucciones detalladas>

═══════════════════════════════════════════
REGLAS GLOBALES
═══════════════════════════════════════════

- <regla 1>
- <regla 2>

═══════════════════════════════════════════
FORMATO DE RESPUESTA
═══════════════════════════════════════════

<cómo debe responder el agente>
```

## Estilo del prompt

- ✅ **Claro y directo** — sin relleno
- ✅ **Estructurado** — usa pasos numerados
- ✅ **Con ejemplos** — siempre que sea posible
- ✅ **En español o bilingüe** — preferido, pero inglés es aceptable
- ✅ **Con casos borde** — anticipa situaciones ambiguas
- ❌ **Sin instrucciones vagas** — "hazlo bien" no es suficiente
- ❌ **Sin emojis decorativos** — solo en headers si aportan claridad

## 💬 ¿Dudas?

Abre un Issue con la etiqueta `question` y te ayudamos. 🚀
---

[Aquí va el prompt completo]
```

**Campos del frontmatter:**

| Campo | Requerido | Descripción |
|-------|-----------|-------------|
| `description` | ✅ Sí | Descripción corta (1 línea, max 100 chars) |
| `agent` | ⚠️ Opcional | Agente que ejecuta: `build`, `plan`, `explore`, `general` |
| `tags` | ⚠️ Opcional | Array de tags para búsqueda |
| `model` | ⚠️ Opcional | Modelo específico (ej: `anthropic/claude-sonnet-4`) |
