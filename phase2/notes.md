# Etapa 2 — Fortran (Cálculo de métricas)

## Qué hace
Lee `data/middle/norm_data.csv` (generado por BASIC-256), calcula 7
métricas globales sobre todo el dataset (temperatura promedio/max/min,
precipitación total, viento promedio/max, batería promedio), y escribe
el resultado en formato clave-valor a `data/middle/metrics.csv`.

## Cómo ejecutar

gfortran phase2/metrics.f90 -o phase2/metrics.exe
./phase2/metrics.exe

Debe ejecutarse desde la raíz del proyecto (el `.exe` intenta primero
`../data/middle/norm_data.csv`, y si falla, usa `data/middle/norm_data.csv`
como respaldo — soporta tanto ejecución desde `phase2/` como desde la raíz).

## Problemas encontrados y cómo se resolvieron

**1. Bug crítico: se estaba descartando una fila de datos real, no un
encabezado.**
`norm_data.csv` (generado por BASIC-256) NO tiene encabezado — ver
`docs/contracts.md`. La primera versión de este programa hacía
`read(10, ...) header` pensando que saltaba un encabezado, pero en
realidad estaba descartando la primera fila real de datos. Esto
desalineaba el conteo de registros contra el contenido real del
archivo, causando un crash `Fortran runtime error: End of file` al
intentar leer una línea que ya no existía. Solución: se eliminó por
completo esa lectura de "descarte de encabezado".

**2. `stop` sin argumento no señala fallo al sistema operativo.**
Al principio, los dos casos de error (no se pudo abrir el archivo, o
el archivo no tiene registros válidos) usaban `stop` sin número, que
en gfortran termina con código de salida `0` (éxito) aunque el
programa haya fallado internamente. Esto hacía que `run_pipeline.sh`
(que usa `set -e`) NO detectara el fallo y siguiera ejecutando Java y
MIPS sobre datos inexistentes, generando errores confusos en cascada.
Solución: se cambió a `stop 1` en ambos casos, que sí comunica fallo.

## Decisiones de diseño
- Las métricas son GLOBALES (sobre todo el dataset junto), no
  agrupadas por estación — así se decidió tras ver que era más simple
  de integrar con Java para este alcance del proyecto.
- Se usan arreglos `allocatable`, ya que el tamaño exacto de datos no
  se conoce hasta contar las líneas reales del archivo (dos pasadas:
  una para contar, otra para leer los valores con `rewind`).
- Documentación estilo FORD (`!>`, `!!`, `@param`, `@return`) en cada
  función, como equivalente de Javadoc para Fortran.

## Pendientes / limitaciones conocidas
- Si `norm_data.csv` trae más o menos de 6 columnas por fila, el
  programa no lo detecta explícitamente (asume el formato siempre
  correcto, ya que BASIC-256 ya validó la estructura antes).