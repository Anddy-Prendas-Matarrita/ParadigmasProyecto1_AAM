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

## 3. metrics.csv (Fortran → Java)

**Ruta:** `data/middle/metrics.csv`
**Generado por:** Etapa 2 (Fortran)
**Consumido por:** Etapa 3 (Java)

**Formato:** clave-valor (NO es una fila por estación — es un resumen
global de todo el archivo `norm_data.csv` junto).

**Columnas:** `Metric,Value`
**¿Incluye encabezado?** Sí, primera línea = `Metric,Value`
**Separador:** coma (`,`)

**Claves esperadas (deben aparecer exactamente con estos nombres):**

| Clave (`Metric`)          | Descripción                              |
|----------------------------|-------------------------------------------|
| `Total_Processed_Records`  | Cantidad de filas válidas procesadas      |
| `Total_Precipitation`      | Precipitación acumulada (mm)              |
| `Average_Temperature`      | Temperatura promedio (°C)                 |
| `Max_Temperature`          | Temperatura máxima (°C)                   |
| `Min_Temperature`          | Temperatura mínima (°C)                   |
| `Average_Wind_Speed`       | Viento promedio (km/h)                    |
| `Max_Wind_Speed`           | Viento máximo (km/h)                      |
| `Average_Battery_Level`    | Batería promedio (%)                      |

**Ejemplo real:**

Metric,Value
Total_Processed_Records,4
Total_Precipitation,19.00
Average_Temperature,27.25
Max_Temperature,45.00
Min_Temperature,0.00
Average_Wind_Speed,8.25
Max_Wind_Speed,18.00
Average_Battery_Level,68.00


**Nota:** puede haber ligeras variaciones de espacio después de la coma
según el formato de escritura de Fortran — Java usa `.trim()` al parsear
para evitar errores de conversión.

---

## 4. alerts.csv (Java → MIPS)

**Ruta:** `data/middle/alerts.csv`
**Generado por:** Etapa 3 (Java)
**Consumido por:** Etapa 4 (MIPS)

**Columnas:** `TIPO_ALERTA`
**¿Incluye encabezado?** Sí, primera línea = `TIPO_ALERTA`
**Separador:** coma (`,`) — aunque de momento es una sola columna.

**Nota:** no incluye columna `ESTACION`, porque las métricas de Fortran
son globales (todo el dataset junto), no separadas por estación.

**Valores posibles en `TIPO_ALERTA`:**

| Valor            | Se genera cuando...                                  |
|-------------------|-------------------------------------------------------|
| `TEMP_ALTA`       | `Max_Temperature` cumple la regla de `rules.txt`       |
| `LLUVIA_INTENSA`  | `Total_Precipitation` cumple la regla de `rules.txt`   |
| `VIENTO_FUERTE`   | `Max_Wind_Speed` cumple la regla de `rules.txt`        |
| `BATERIA_BAJA`    | `Average_Battery_Level` cumple la regla de `rules.txt` |

Puede haber 0, una, o varias líneas (una por cada regla que se dispare,
en el mismo orden en que aparecen en `rules.txt`).
Si ninguna regla se cumple, el archivo solo tiene el encabezado.

**Ejemplo real (con los datos de metrics.csv de arriba y rules.txt actual):**

TIPO_ALERTA
TEMP_ALTA


---

## 5. rules.txt (archivo de configuración, no forma parte del pipeline de datos)

**Ruta:** `phase3/rules.txt`
**Generado por:** definido manualmente por el equipo (no lo genera otra etapa)
**Consumido por:** Etapa 3 (Java)

**Gramática:**

<regla> ::= <identificador> <operador> <numero>
<operador> ::= ">" | "<" | ">=" | "<="
<identificador> ::= "TEMP_ALTA" | "LLUVIA_INTENSA" | "VIENTO_FUERTE" | "BATERIA_BAJA"


**Contenido actual:**

TEMP_ALTA > 35
LLUVIA_INTENSA > 50
VIENTO_FUERTE > 40
BATERIA_BAJA < 20


**Importante:** el archivo NO puede estar vacío — si no tiene ninguna
línea válida, Java carga 0 reglas y ninguna alerta se genera nunca,
sin que esto se reporte como error (ver phase3/notes.md).

---

## 6. final_result.txt (salida final de MIPS)

**Ruta:** `data/output/final_result.txt`
**Generado por:** Etapa 4 (MIPS)
**Consumido por:** nadie — es el resultado final del pipeline.

**Formato:** un único número entero (el checksum), sin encabezado,
sin salto de línea adicional, sin ninguna otra columna o texto.

**Cómo se calcula:** por cada línea de `alerts.csv` (excluyendo el
encabezado), en el orden en que aparecen:

checksum = checksum + valor_de_la_alerta
checksum = checksum XOR posicion


**Tabla de conversión de alerta a valor numérico:**

| TIPO_ALERTA       | Valor |
|--------------------|-------|
| `TEMP_ALTA`         | 10    |
| `LLUVIA_INTENSA`    | 20    |
| `VIENTO_FUERTE`     | 30    |
| `BATERIA_BAJA`      | 40    |

**Ejemplo real (con el `alerts.csv` de arriba, una sola alerta TEMP_ALTA):**

| Posición | Alerta | Valor | checksum tras `+valor` | checksum tras `XOR posición` |
|---|---|---|---|---|
| 1 | TEMP_ALTA | 10 | 0+10=10 | 10 XOR 1 = 11 |

**Contenido esperado de final_result.txt:**

11


---

## Historial de cambios relevantes

- El formato de `metrics.csv` cambió de "una fila por estación" a
  "clave-valor global" durante el desarrollo, porque los cálculos de
  Fortran se hicieron sobre todo el dataset junto, no agrupados por
  estación. `alerts.csv` se ajustó en consecuencia, quitando la
  columna `ESTACION`.