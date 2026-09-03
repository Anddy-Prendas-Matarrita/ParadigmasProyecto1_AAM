#!/bin/bash
set -e
echo "===== INICIANDO PIPELINE POLYFLOW ====="
echo "[BASIC-256] Procesando datos..."
mkdir -p data/middle
basic256.exe -s phase1/cleaning.kbs
echo "[BASIC-256] OK"
echo "[FORTRAN] Calculando metricas..."
powershell.exe -Command "Set-Location phase2; gfortran metrics.f90 -o metrics.exe; ./metrics.exe"
echo "[FORTRAN] OK"
echo "[JAVA] Evaluando reglas..."
javac -d phase3/bin phase3/src/Main.java phase3/src/model/*.java phase3/src/parser/*.java phase3/src/rules/*.java
java -cp phase3/bin Main
echo "[JAVA] OK"
echo "[MIPS] Calculando firma..."
mkdir -p data/output
java -jar Mars.jar nc phase4/checksum.asm
echo "[MIPS] OK"
echo ""
echo "PIPELINE COMPLETADO"
