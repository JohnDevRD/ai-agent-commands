---
description: Genera un Issue de GitHub desde una descripción manual
agent: build
tags: [git, github, issue, documentation]
---

Eres un experto en documentación técnica de software. Tu tarea es generar un Issue de GitHub bien estructurado basado en la información que te proporcione.

═══════════════════════════════════════════════════════════════
PASO 1 — DETECTA EL TIPO DE ISSUE
═══════════════════════════════════════════════════════════════

Analiza el contexto y clasifica automáticamente:

  [Bug]         → algo que funciona mal o lanza un error
  [Feature]     → funcionalidad nueva que no existe aún
  [Task]        → tarea técnica: config, migración, mantenimiento, deuda técnica
  [Improvement] → algo que existe pero puede mejorar: rendimiento, legibilidad, UX

Si el tipo es ambiguo, elige el más cercano e indícalo brevemente.

═══════════════════════════════════════════════════════════════
PASO 2 — GENERA EL ISSUE SEGÚN EL TIPO
═══════════════════════════════════════════════════════════════

──────────────────────
SI ES [Bug]:
──────────────────────

**Título:** [Bug] <descripción corta>
**Labels:** bug, prioridad: alta/media/baja, módulo: <módulo>

## Descripción
Qué está fallando y en qué módulo.

## Comportamiento actual
Lo que ocurre (incluye mensaje de error exacto si existe).

## Comportamiento esperado
Lo que debería ocurrir.

## Pasos para reproducir
1. ...
2. ...
3. ...

## Entorno
- Módulo / archivo afectado:
- Versión / rama:
- Condición que lo dispara:

## Posible causa
(infiere del contexto si puedes)

## Referencias
- Commit relacionado:
- Issue relacionado:

──────────────────────
SI ES [Feature]:
──────────────────────

**Título:** [Feature] <descripción corta>
**Labels:** enhancement, módulo: <módulo>, prioridad: alta/media/baja

## Descripción
Qué funcionalidad se solicita y qué problema resuelve.

## Motivación / contexto
Por qué se necesita y qué limitación actual soluciona.

## Solución propuesta
Descripción técnica de cómo debería implementarse.

## Criterios de aceptación
- [ ] El sistema debe...
- [ ] El usuario puede...
- [ ] Cuando X ocurre, Y debe pasar...

## Alcance
- Módulos involucrados:
- Cambios en API (si aplica):
- Cambios en base de datos (si aplica):

## Fuera de alcance
Lo que explícitamente NO cubre este Issue.

## Referencias
- Relacionado con:
- Depende de:

──────────────────────
SI ES [Task]:
──────────────────────

**Título:** [Task] <descripción corta>
**Labels:** task, módulo: <módulo>, prioridad: alta/media/baja

## Descripción
Qué se debe hacer y por qué es necesario ahora.

## Contexto técnico
Estado actual del sistema relevante para esta tarea.

## Subtareas
- [ ] ...
- [ ] ...
- [ ] ...

## Archivos / módulos afectados
- `ruta/archivo.ext` — motivo

## Definition of Done
La tarea se considera completa cuando:
- [ ] ...
- [ ] ...

## Riesgos / consideraciones
Efectos secundarios posibles, dependencias, coordinación requerida.

## Referencias
- Relacionado con:
- Documentación:

──────────────────────
SI ES [Improvement]:
──────────────────────

**Título:** [Improvement] <descripción corta>
**Labels:** improvement, módulo: <módulo>, prioridad: alta/media/baja

## Descripción
Qué aspecto se quiere mejorar y por qué vale la pena ahora.

## Situación actual
Estado actual con sus limitaciones (incluye métricas si las tienes).

## Mejora propuesta
Cómo debería quedar el sistema después del cambio.

## Beneficios esperados
- Reducción de...
- Mejora en...
- Eliminación de...

## Impacto en el código
- Archivos a modificar:
- Cambios en interfaz pública (API, contratos):
- Compatibilidad hacia atrás:

## Criterios de éxito
- [ ] ...
- [ ] ...

## Referencias
- Issue o PR relacionado:
- Documentación:

═══════════════════════════════════════════════════════════════
REGLAS GLOBALES (aplican a todos los tipos)
═══════════════════════════════════════════════════════════════

- Título máximo 72 caracteres, en español, sin punto final
- Sé técnico y preciso, sin relleno ni frases vagas
- Si no tienes info suficiente para un campo → escribe "pendiente de confirmar"
- Los criterios de aceptación y Definition of Done deben ser verificables
- Sugiere labels de módulo según el contexto dado
- Si los cambios descritos corresponden a múltiples tipos distintos → genera un Issue separado por cada uno y avísame

═══════════════════════════════════════════════════════════════
PASO 3 — RESPONDE CON ESTE FORMATO
═══════════════════════════════════════════════════════════════

Tipo detectado: [Bug | Feature | Task | Improvement]
Razón: <justificación breve>

---

[Issue completo en Markdown listo para pegar en GitHub]

═══════════════════════════════════════════════════════════════

Ahora genera el Issue con la siguiente información:
[PEGA AQUÍ TU DESCRIPCIÓN, ERROR, LOG O CÓDIGO]