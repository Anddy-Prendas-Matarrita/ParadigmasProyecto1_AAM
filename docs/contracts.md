# Contratos de datos — PolyFlow

Este documento define el formato exacto de cada archivo que se pasa entre
etapas del pipeline. Cualquier cambio a estas reglas debe actualizarse aquí
y comunicarse a todo el equipo, ya que las etapas siguientes dependen de esto.

---

## 1. raw_data.csv (entrada del sistema)

**Ruta:** `data/input/raw_data.csv`
**Generado por:** dataset inicial (dado o inventado por el equipo)
**Consumido por:** BASIC-256 (Etapa 1)

**Columnas (en este orden):**

| # | Columna       | Tipo   | Descripción                          |
|---|---------------|--------|---------------------------------------|
| 0 | ID            | texto  | Identificador único del registro      |
| 1 | ESTACION      | texto  | Nombre de la estación                 |
| 2 | TEMPERATURA   | número | Grados Celsius                        |
| 3 | PRECIPITACION | número | Milímetros                            |
| 4 | VIENTO        | número | Km/h                                  |
| 5 | BATERIA       | número | Porcentaje (0-100)                    |

**¿Incluye encabezado?** Sí, primera línea = nombres de columnas.
**Separador:** coma (`,`)

---

## 2. norm_data.csv (BASIC-256 → Fortran)

**Ruta:** `data/middle/norm_data.csv`
**Generado por:** Etapa 1 (BASIC-256)
**Consumido por:** Etapa 2 (Fortran)

**Columnas:** mismas 6 columnas que `raw_data.csv`, mismo orden.
**¿Incluye encabezado?** No — Fortran no debe leer una fila de encabezado.
**Separador:** coma (`,`)

**Reglas de validación aplicadas (una fila se descarta si incumple CUALQUIERA):**

| Campo         | Regla                          | Justificación                                   |
|---------------|---------------------------------|--------------------------------------------------|
| Cualquiera    | No puede estar vacío             | Un campo faltante invalida toda la fila          |
| TEMPERATURA   | Debe estar en `[0, 45]` °C       | Rango realista para clima costarricense          |
| PRECIPITACION | Debe ser `>= 0`                  | La lluvia no puede ser negativa                  |
| VIENTO        | Debe ser `>= 0`                  | La velocidad no puede ser negativa               |
| BATERIA       | Debe estar en `[0, 100]`         | Es un porcentaje, no puede salir de ese rango     |

**Importante:** BASIC-256 solo **filtra** filas, nunca modifica sus valores.
La fila que pasa se escribe exactamente igual a como llegó.

---

## Pendiente de definir (próximas etapas)

- [ ] metrics.csv (Fortran → Java)
- [ ] alerts.csv (Java → MIPS)
- [ ] Formato de resultado final (MIPS)