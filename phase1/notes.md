# Etapa 1 — BASIC-256 (Limpieza y validación)

## Qué hace
Lee `data/input/raw_data.csv`, valida cada fila segun las reglas
definidas en `docs/contracts.md`, y escribe solo las filas validas
en `data/middle/norm_data.csv`. No modifica ningun valor: solo filtra.

## Cómo ejecutar
Este script se ejecuta como parte de `run_pipeline.sh` / `run_pipeline.bat`,
desde la raíz del proyecto, usando el modo silencioso:

basic256.exe -s phase1/cleaning.kbs


## Reglas de validación implementadas
Ver `docs/contracts.md` sección 2 para el detalle completo de rangos.
Resumen: se descarta la fila si CUALQUIER campo está vacío, o si
TEMPERATURA está fuera de `[0,45]`, PRECIPITACION o VIENTO son
negativos, o BATERIA está fuera de `[0,100]`.

## Problemas encontrados y cómo se resolvieron

**1. Rutas relativas dependen SIEMPRE de la ubicación del .kbs, no de
desde dónde se invoca el comando.**
A diferencia de Fortran o Bash, BASIC-256 resuelve rutas relativas
(`../data/...`) según dónde está el archivo `.kbs`, sin importar si se
ejecuta desde el editor gráfico, desde la terminal, o con `-s` (modo
silencioso). Por eso las rutas en este archivo usan `../data/...`
aunque `run_pipeline.sh` invoque el script desde la raíz del proyecto.

**2. El ejecutable abre el IDE gráfico por defecto.**
`basic256.exe archivo.kbs` sin banderas abre la interfaz y espera que
alguien le dé "play" manualmente — esto rompe la automatización del
pipeline. La bandera `-s` (`--silent`) lo ejecuta sin interfaz, manda
los `print` a la terminal, y refleja éxito/fallo en el código de salida.

**3. `float()` sobre un campo vacío puede dar error.**
Por eso las validaciones de rango (`if float(temperature$) > 45 ...`)
solo se ejecutan si ya se confirmó que el campo no está vacío
(`length(...) = 0`), evitando convertir texto vacío a número.

## Decisiones de diseño
- Se descarta la fila entera si CUALQUIER campo numérico está fuera de
  rango — no se intenta "corregir" el dato, solo se filtra.
- La primera línea del CSV (encabezado) se lee y se descarta antes del
  ciclo principal, para no intentar validarla como si fuera un dato.
- `norm_data.csv` NO lleva encabezado (ver contracts.md) — es
  importante que Fortran no intente descartar una primera línea aquí.

## Pendientes / limitaciones conocidas
- No se valida si un ID se repite entre distintas filas.
- No se valida el nombre de ESTACION contra una lista fija de
  estaciones válidas (se acepta cualquier texto no vacío).