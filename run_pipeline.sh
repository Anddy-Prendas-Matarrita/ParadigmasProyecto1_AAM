#!/bin/bash
# ============================================================
# PolyFlow - Orquestador del pipeline completo
# Ejecuta las 4 etapas en orden, desde la raiz del proyecto.
# ============================================================

set -e   # detener el script si algun comando falla

echo "===== INICIANDO PIPELINE POLYFLOW ====="

# ---------- Etapa 1: BASIC-256 ----------
echo "[BASIC-256] Procesando datos..."
mkdir -p data/middle
basic256.exe -s phase1/cleaning.kbs
echo "[BASIC-256] OK"
# ---------- Etapa 2: Fortran ----------
echo "[FORTRAN] Calculando metricas..."
gfortran phase2/metrics.f90 -o phase2/metrics.exe
./phase2/metrics.exe
echo "[FORTRAN] OK"

# ---------- Etapa 3: Java ----------
echo "[JAVA] Evaluando reglas..."
javac -d phase3/bin phase3/src/Main.java phase3/src/model/*.java phase3/src/parser/*.java phase3/src/rules/*.java
java -cp phase3/bin Main
echo "[JAVA] OK"

# ---------- Etapa 4: MIPS ----------
echo "[MIPS] Calculando firma..."
mkdir -p data/output
java -jar Mars.jar nc phase4/checksum.asm
echo "[MIPS] OK"

echo ""
echo "PIPELINE COMPLETADO"