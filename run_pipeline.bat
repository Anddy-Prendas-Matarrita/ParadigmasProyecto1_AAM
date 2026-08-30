@echo off
setlocal enabledelayedexpansion

REM Asegura que el script corra desde su propia carpeta, sin importar
REM desde donde se haya hecho doble clic o se haya invocado.
cd /d %~dp0

set BASIC256="C:\Program Files\BASIC256\basic256.exe"

echo ===== INICIANDO PIPELINE POLYFLOW =====

echo [BASIC-256] Procesando datos...
%BASIC256% -s phase1\cleaning.kbs
if errorlevel 1 (
    echo ERROR en BASIC-256
    pause
    exit /b 1
)
echo [BASIC-256] OK

echo [FORTRAN] Calculando metricas...
gfortran phase2\metrics.f90 -o phase2\metrics.exe
if errorlevel 1 (
    echo ERROR compilando Fortran
    pause
    exit /b 1
)
phase2\metrics.exe
if errorlevel 1 (
    echo ERROR ejecutando Fortran
    pause
    exit /b 1
)
echo [FORTRAN] OK

echo [JAVA] Evaluando reglas...
javac -d phase3\bin phase3\src\Main.java phase3\src\model\*.java phase3\src\parser\*.java phase3\src\rules\*.java
if errorlevel 1 (
    echo ERROR compilando Java
    pause
    exit /b 1
)
java -cp phase3\bin Main
if errorlevel 1 (
    echo ERROR ejecutando Java
    pause
    exit /b 1
)
echo [JAVA] OK

echo [MIPS] Calculando firma...
java -jar Mars.jar nc phase4\checksum.asm
if errorlevel 1 (
    echo ERROR ejecutando MIPS
    pause
    exit /b 1
)
echo [MIPS] OK

echo.
echo PIPELINE COMPLETADO
pause