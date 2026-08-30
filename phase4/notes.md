# Etapa 4 — MIPS (Verificación de integridad)

## Qué hace
Lee `data/middle/alerts.csv`, convierte cada tipo de alerta a su valor
numérico (TEMP_ALTA=10, LLUVIA_INTENSA=20, VIENTO_FUERTE=30,
BATERIA_BAJA=40), y calcula un checksum acumulado:

checksum = checksum + valor
checksum = checksum XOR posicion

El resultado final se escribe en `data/output/final_result.txt`.

## Cómo ejecutar

java -jar Mars.jar nc phase4/checksum.asm

Requiere el simulador MARS (`Mars.jar`) en la raíz del proyecto.
La bandera `nc` ("no copyright") ejecuta en modo consola sin abrir
ventana gráfica, necesario para automatizar el pipeline.

## Problemas encontrados y cómo se resolvieron

**1. QtSpim (instalado originalmente) no se automatiza fácilmente.**
El equipo tenía QtSpim instalado, que aunque soporta las mismas
syscalls de archivo (13-16) que MARS, es principalmente una interfaz
gráfica sin modo consola directo desde terminal. Se decidió instalar
MARS en su lugar, que sí soporta el modo `nc` para correr sin abrir
ventana — necesario para `run_pipeline.sh`/`run_pipeline.bat`.

**2. `Mars.jar` no se encontraba al ejecutar desde el script.**
El archivo descargado se llamaba `Mars4_5.jar` (con el nombre de
versión incluido) y el script esperaba exactamente `Mars.jar`.
Solución: renombrar el archivo tras descargarlo, en vez de modificar
el script — mantiene el comando más simple y estable ante futuras
actualizaciones de versión.

**3. El archivo .asm contenía código de Fortran por error.**
En algún punto del desarrollo, `checksum.asm` terminó con el contenido
de `metrics.f90` pegado dentro (probablemente un error al copiar entre
archivos). MARS reportaba ">200 errores" de "Invalid language element"
en cada línea, porque intentaba interpretar sintaxis de Fortran como
ensamblador MIPS. Se resolvió reemplazando el contenido completo del
archivo por el código real de MIPS.

## Decisiones de diseño
- Las syscalls de archivo (13=open, 14=read, 15=write, 16=close) son
  específicas de MARS — si el equipo cambiara de simulador, esta parte
  necesitaría revisarse.
- El checksum se calcula leyendo todo el archivo de una vez a memoria
  (`buffer_entrada`), en vez de leer línea por línea con syscalls
  repetidas — más simple de programar en ensamblador.
- Funciones auxiliares (`strcmp`, `itoa`) separadas del flujo
  principal, documentadas con bloques de comentario `#` describiendo
  entrada/salida en registros, como equivalente de Javadoc para MIPS.

## Pendientes / limitaciones conocidas
- Si `alerts.csv` tiene más de 2048 caracteres en total, el buffer de
  lectura (`buffer_entrada: .space 2048`) no alcanza — no hay manejo
  de archivos más grandes que ese límite.
- No hay validación de que las líneas de `alerts.csv` coincidan
  exactamente con los 4 tipos de alerta esperados — una línea no
  reconocida simplemente se ignora sin aviso.