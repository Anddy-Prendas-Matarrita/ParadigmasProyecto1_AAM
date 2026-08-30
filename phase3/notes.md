# Etapa 3 — Java (Motor de reglas)

## Qué hace
Lee `data/middle/metrics.csv` (clave-valor) y `phase3/rules.txt`
(mini-lenguaje de reglas), evalúa cada regla contra las métricas
mediante polimorfismo (`Rule.evaluar()`), y escribe las alertas
disparadas en `data/middle/alerts.csv`.

## Cómo ejecutar

javac -d phase3/bin phase3/src/Main.java phase3/src/model/.java phase3/src/parser/.java phase3/src/rules/*.java
java -cp phase3/bin Main

Debe ejecutarse desde la raíz del proyecto (las rutas de `metrics.csv`,
`rules.txt` y `alerts.csv` en `Main.java` son relativas a la raíz).

**Importante:** `bin/` contiene los `.class` ya compilados — es un
espejo generado automáticamente de `src/`. Si se edita un `.java` y no
se vuelve a compilar, los cambios NO se reflejan al ejecutar. `bin/`
está excluido de Git vía `.gitignore` porque se puede regenerar en
cualquier momento con `javac`.

## Problemas encontrados y cómo se resolvieron

**1. `rules.txt` vacío no genera ningún error visible.**
El programa corrió sin errores pero mostró "Reglas cargadas: 0" y
"Alertas generadas: 0" — no porque el código estuviera mal, sino
porque `phase3/rules.txt` estaba vacío. El programa se comportó
correctamente (falló de forma segura y silenciosa), pero es un
recordatorio de que un archivo de configuración vacío no siempre se
reporta como "error" — hay que revisar el contenido, no solo si el
programa corrió sin excepciones.

**2. Directorio de trabajo distinto según el método de ejecución.**
Ejecutar con el botón "Run: Main" de VS Code usa un directorio de
trabajo distinto al de la terminal manual (`javac`/`java`), aunque
ambos casos mostraron `user.dir` apuntando a la raíz correcta en las
pruebas finales — se dejó como advertencia por si cambia en otro
entorno.

**3. Los códigos de salida silenciosos ocultaban fallos reales.**
El `catch (IOException e)` original solo imprimía el error, pero el
programa terminaba con código de salida `0` (éxito) de todas formas.
Esto hacía que `run_pipeline.sh` no detectara el fallo si `metrics.csv`
no existía (por ejemplo, si Fortran falló antes). Solución: se agregó
`System.exit(1)` dentro del catch, para propagar el fallo correctamente.

## Decisiones de diseño
- El parser (`RuleParser`) actúa como *factory*: convierte texto plano
  en objetos concretos (`TemperatureRule`, `WindRule`, etc.) según el
  identificador, validando la gramática en el camino.
- `metrics.csv` es clave-valor global, no por estación (ver
  `contracts.md`), por lo que `GlobalMetrics` no tiene el concepto de
  estación en absoluto.
- Javadoc completo (0 errores, 0 warnings al generar con `javadoc`).

## Pendientes / limitaciones conocidas
- Si dos líneas de `rules.txt` definen el mismo identificador con
  distintos valores, ambas se cargan y se evalúan (no hay detección
  de reglas duplicadas o contradictorias).