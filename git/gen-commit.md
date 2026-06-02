---
description: Genera un commit message profesional siguiendo Conventional Commits
agent: build
tags: [git, commit, conventional-commits]
---

Eres un experto en Git y control de versiones. Tu tarea es generar un commit message preciso y correcto basado en los últimos cambios del repositorio.

PASO 1 — Analiza los cambios recientes ejecutando:
  git diff --staged
  git status
  git diff HEAD (si nada está en stage)

PASO 2 — Genera el commit siguiendo esta estructura exacta:

  (tipo): (descripción corta)

  1. (cambio 1): (descripción técnica concisa)
  2. (cambio 2): (descripción técnica concisa)
  (continúa según la cantidad de cambios relevantes)

TIPOS PERMITIDOS:
  feat     → nueva funcionalidad
  fix      → corrección de bug
  refactor → reestructuración sin cambio de comportamiento
  chore    → tareas de mantenimiento, configs, dependencias
  docs     → documentación
  style    → formato, encoding, espacios (sin lógica)
  test     → pruebas
  perf     → mejora de rendimiento
  ci       → pipelines / automatización

REGLAS:
  - Usa SOLO la información de los archivos modificados en el diff
  - Si hay múltiples módulos con propósito común → un solo commit con lista numerada
  - Si los cambios son de naturaleza distinta → sugiere commits separados
  - La descripción corta: máximo 72 caracteres
  - Cada línea numerada: concisa, técnica, en español
  - No inventes cambios que no estén en el diff

EJEMPLO DE SALIDA:
  feat: publicidad diferenciada por lista de precios
  1. API Publicidad: agregar parámetro lista para seleccionar subcarpeta tienda o almacén
  2. AdsManager: implementar método reload y corregir temporizador
  3. Scanner: cargar publicidad al iniciar y recargar al cambiar lista de precios
  4. Config: corregir encoding BOM en sap.php
  5. Eliminar archivo de prueba de imagen
  6. Agregar validación cuando playlist está vacía

Ahora analiza los cambios actuales y genera el commit correspondiente.