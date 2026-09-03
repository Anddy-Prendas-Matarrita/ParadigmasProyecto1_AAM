set -e   # detener el script si algun comando falla
 
echo "===== INICIANDO PIPELINE POLYFLOW ====="
 
# ---------- Etapa 1: BASIC-256 ----------
echo "[BASIC-256] Procesando datos..."
mkdir -p data/middle
basic256.exe -s phase1/cleaning.kbs
echo "[BASIC-256] OK"
 
# Pequeña espera/verificacion: en carpetas sincronizadas con OneDrive, el
# archivo recien cerrado por BASIC-256 puede quedar bloqueado un instante
# antes de que Fortran pueda abrirlo. Reintentamos en vez de asumir que ya
# esta disponible.
for i in 1 2 3 4 5; do
    if [ -s data/middle/norm_data.csv ]; then
        break
    fi
    echo "  (esperando a que norm_data.csv quede disponible... intento $i)"
    sleep 1
done
ls -la data/middle/norm_data.csv
 
# ---------- Etapa 2: Fortran ----------
echo "[FORTRAN] Calculando metricas..."
gfortran phase2/metrics.f90 -o phase2/metrics.exe
./phase2/metrics.exe
if [ ! -s data/middle/metrics.csv ]; then
    echo "ERROR: metrics.csv no se genero (Fortran fallo). Abortando pipeline."
    exit 1
fi
echo "[FORTRAN] OK"
 
# ---------- Etapa 3: Java ----------
echo "[JAVA] Evaluando reglas..."
javac -d phase3/bin phase3/src/Main.java phase3/src/model/*.java phase3/src/parser/*.java phase3/src/rules/*.java
java -cp phase3/bin Main
if [ ! -s data/middle/alerts.csv ]; then
    echo "ERROR: alerts.csv no se genero (Java fallo). Abortando pipeline."
    exit 1
fi
echo "[JAVA] OK"
 
# ---------- Etapa 4: MIPS ----------
echo "[MIPS] Calculando firma..."
mkdir -p data/output
java -jar Mars.jar nc phase4/checksum.asm
echo "[MIPS] OK"
 
echo ""
echo "PIPELINE COMPLETADO"