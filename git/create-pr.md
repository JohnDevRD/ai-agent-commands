---
description: Genera un Pull Request de GitHub completo y listo para publicar
agent: build
tags: [git, github, pull-request, pr]
---

Eres un experto en documentación técnica de software y revisión de código.
Tu tarea es analizar el estado actual del proyecto de forma autónoma y generar
uno o más Pull Requests de GitHub precisos y listos para publicar.

═══════════════════════════════════════════════════════════════
PASO 1 — INSPECCIONA EL REPOSITORIO
═══════════════════════════════════════════════════════════════

Ejecuta estos comandos en orden y analiza cada resultado:

  1. git status
     → archivos modificados, sin seguimiento o eliminados

  2. git branch --show-current
     → rama actual (será la rama origen del PR)

  3. git log main..HEAD --oneline
     → commits que serán parte del PR

  4. git diff main...HEAD
     → cambios exactos línea por línea respecto a la rama base

  5. git diff main...HEAD --name-only
     → lista de archivos modificados

  6. git log main..HEAD --format="%s"
     → mensajes de commit para entender la intención de los cambios

  7. (opcional) cat <archivo>
     → lee archivos clave si el diff no es suficiente para entender el contexto

Con esta información identifica:
  - El propósito principal del conjunto de cambios
  - Si los cambios son cohesivos o deben separarse en múltiples PRs
  - Qué módulos o componentes están afectados
  - Si hay riesgos, efectos secundarios o cambios que rompan compatibilidad
  - Si existen pruebas asociadas a los cambios

═══════════════════════════════════════════════════════════════
PASO 2 — DETECTA EL TIPO DE CADA PR
═══════════════════════════════════════════════════════════════

Clasifica cada conjunto de cambios:

  [Bug Fix]     → corrige algo que funcionaba mal o lanzaba un error
  [Feature]     → agrega funcionalidad nueva
  [Refactor]    → mejora interna sin cambiar comportamiento externo
  [Chore]       → config, dependencias, CI/CD, mantenimiento
  [Docs]        → solo documentación
  [Hotfix]      → corrección urgente lista para producción

Si los cambios tienen una sola intención → un solo PR.
Si los cambios mezclan intenciones distintas → un PR separado por cada uno
y advierte que deberían separarse en ramas independientes.


═══════════════════════════════════════════════════════════════
PASO 3 — GENERA CADA PR
═══════════════════════════════════════════════════════════════

Usa la plantilla correspondiente al tipo detectado:

──────────────────────
[Bug Fix]
──────────────────────
**Título:** [Bug Fix] <descripción corta>
**Branch origen → destino:** <rama-actual> → main
**Labels:** bug, módulo: <módulo>, prioridad: alta/media/baja
**Issue relacionado:** Closes #<número> (si aplica)
**Reviewers sugeridos:** pendiente de confirmar

## ¿Qué problema resuelve?

## Causa raíz identificada

## Solución implementada

## Cambios realizados
| Archivo | Tipo de cambio | Descripción |
|---------|---------------|-------------|
|         |               |             |

## Cómo probar
  1.
  2.
  3.

## Checklist
  - [ ] El bug fue reproducido antes del fix
  - [ ] Los cambios están cubiertos por pruebas
  - [ ] No se introducen regresiones conocidas
  - [ ] La documentación fue actualizada si aplica
  - [ ] Se probó en entorno local

## Screenshots / evidencia (si aplica)

## Notas para el reviewer

──────────────────────
[Feature]
──────────────────────
**Título:** [Feature] <descripción corta>
**Branch origen → destino:** <rama-actual> → main
**Labels:** enhancement, módulo: <módulo>, prioridad: alta/media/baja
**Issue relacionado:** Closes #<número> (si aplica)
**Reviewers sugeridos:** pendiente de confirmar

## ¿Qué agrega este PR?

## Motivación / contexto

## Solución implementada

## Cambios realizados
| Archivo | Tipo de cambio | Descripción |
|---------|---------------|-------------|
|         |               |             |

## Cómo probar
  1.
  2.
  3.

## Criterios de aceptación
  - [ ] ...
  - [ ] ...

## Checklist
  - [ ] La funcionalidad fue probada manualmente
  - [ ] Existen pruebas unitarias / de integración
  - [ ] No se rompe funcionalidad existente
  - [ ] La documentación fue actualizada
  - [ ] Se consideraron casos borde

## Impacto en otras áreas del sistema

## Screenshots / evidencia (si aplica)

## Notas para el reviewer


──────────────────────
[Refactor]
──────────────────────
**Título:** [Refactor] <descripción corta>
**Branch origen → destino:** <rama-actual> → main
**Labels:** refactor, módulo: <módulo>, prioridad: alta/media/baja
**Issue relacionado:** Closes #<número> (si aplica)
**Reviewers sugeridos:** pendiente de confirmar

## ¿Qué se refactorizó y por qué?

## Situación anterior

## Situación nueva

## Cambios realizados
| Archivo | Tipo de cambio | Descripción |
|---------|---------------|-------------|
|         |               |             |

## Cómo verificar que no hay regresiones
  1.
  2.

## Checklist
  - [ ] El comportamiento externo no cambia
  - [ ] Las pruebas existentes siguen pasando
  - [ ] Se agregaron pruebas si la cobertura era insuficiente
  - [ ] No hay cambios de lógica mezclados con el refactor

## Notas para el reviewer

──────────────────────
[Chore]
──────────────────────
**Título:** [Chore] <descripción corta>
**Branch origen → destino:** <rama-actual> → main
**Labels:** chore, módulo: <módulo>, prioridad: alta/media/baja
**Issue relacionado:** Closes #<número> (si aplica)
**Reviewers sugeridos:** pendiente de confirmar

## ¿Qué tarea de mantenimiento se realizó?

## Contexto / motivación

## Cambios realizados
| Archivo | Tipo de cambio | Descripción |
|---------|---------------|-------------|
|         |               |             |

## Riesgos o consideraciones

## Checklist
  - [ ] Los pipelines de CI/CD siguen funcionando
  - [ ] No se afecta la lógica de negocio
  - [ ] Los cambios fueron validados en entorno local
  - [ ] Se documentaron los cambios de configuración si aplica

## Notas para el reviewer

──────────────────────
[Docs]
──────────────────────
**Título:** [Docs] <descripción corta>
**Branch origen → destino:** <rama-actual> → main
**Labels:** documentation, módulo: <módulo>
**Issue relacionado:** Closes #<número> (si aplica)

## ¿Qué documentación se agregó o actualizó?

## Motivación

## Cambios realizados
| Archivo | Descripción |
|---------|-------------|
|         |             |

## Checklist
  - [ ] La documentación es precisa y refleja el estado actual del código
  - [ ] No hay typos ni errores gramaticales
  - [ ] Los ejemplos de código fueron probados

──────────────────────
[Hotfix]
──────────────────────
**Título:** [Hotfix] <descripción corta>
**Branch origen → destino:** <rama-hotfix> → main (y merge a develop si aplica)
**Labels:** bug, hotfix, prioridad: alta
**Issue relacionado:** Closes #<número> (si aplica)
**⚠️ URGENTE — requiere revisión prioritaria**

## Problema crítico que resuelve

## Impacto en producción

## Solución implementada

## Cambios realizados
| Archivo | Tipo de cambio | Descripción |
|---------|---------------|-------------|
|         |               |             |

## Cómo probar
  1.
  2.

## Plan de rollback (si el fix falla)

## Checklist
  - [ ] Fix probado en entorno de staging
  - [ ] No introduce nuevos bugs conocidos
  - [ ] El equipo fue notificado

═══════════════════════════════════════════════════════════════
REGLAS GLOBALES
═══════════════════════════════════════════════════════════════

- Título máximo 72 caracteres, en español, sin punto final
- Basa TODO en lo que encuentres en el repositorio — no inventes
- Si un campo no puede determinarse del código → "pendiente de confirmar"
- La tabla de cambios debe listar TODOS los archivos modificados
- Si los cambios mezclan distintos tipos → genera un PR por tipo
  y agrega una advertencia de que deberían estar en ramas separadas
- Si no hay nada que generar como PR → dilo explícitamente

═══════════════════════════════════════════════════════════════
PASO 4 — RESPONDE CON ESTE FORMATO
═══════════════════════════════════════════════════════════════

Resumen del análisis:
  - Rama actual:
  - Rama destino:
  - Commits incluidos: N
  - Archivos modificados: N
  - PRs detectados: N
  - ¿Cambios cohesivos?: Sí / No (advertencia si No)

---

### PR 1 de N
Tipo detectado: [Bug Fix | Feature | Refactor | Chore | Docs | Hotfix]
Razón:

[PR completo en Markdown listo para pegar en GitHub]

---

### PR 2 de N
(si aplica)

[PR completo en Markdown]

  - [ ] Se debe hacer merge también a develop / rama de desarrollo

## Notas para el reviewer
