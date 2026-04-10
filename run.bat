@echo off
setlocal enabledelayedexpansion

cd /d "%~dp0"

echo.
echo =========================================
echo  Particle Physics Simulator - Windows
echo =========================================
echo.

where g++ >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] g++ not found. Install MinGW.
    pause
    exit /b 1
)

echo [1/5] Compiling...
set NEEDS_REBUILD=0
if not exist "simulator\simulator.exe" set NEEDS_REBUILD=1
if exist "simulator\main.cc"     call :check_newer simulator\main.cc     simulator\simulator.exe
if exist "simulator\Physics.cc"  call :check_newer simulator\Physics.cc  simulator\simulator.exe
if exist "simulator\Particle.cc" call :check_newer simulator\Particle.cc simulator\simulator.exe
if exist "simulator\Physics.h"   call :check_newer simulator\Physics.h   simulator\simulator.exe
if exist "simulator\Particle.h"  call :check_newer simulator\Particle.h  simulator\simulator.exe

if %NEEDS_REBUILD%==1 (
    del simulator\*.o 2>nul
    g++ -std=c++17 -Wall -g -fopenmp -c simulator\Particle.cc -o simulator\Particle.o || goto error
    g++ -std=c++17 -Wall -g -fopenmp -c simulator\Physics.cc  -o simulator\Physics.o  || goto error
    g++ -std=c++17 -Wall -g -fopenmp -c simulator\main.cc     -o simulator\main.o     || goto error
    g++ -std=c++17 -Wall -g -fopenmp simulator\Particle.o simulator\Physics.o simulator\main.o -o simulator\simulator.exe || goto error
    echo Compilation successful
) else (
    echo Build up to date, skipping
)
echo.

echo [2/5] Running simulator...
set RUN_SIM=0
if not exist "data\particles.csv" set RUN_SIM=1
if exist "data\dataset.csv" call :check_newer data\dataset.csv data\particles.csv
if exist "data\config.csv"  call :check_newer data\config.csv  data\particles.csv

if %RUN_SIM%==1 (
    simulator\simulator.exe || goto error
    echo Simulator done
) else (
    echo Simulation up to date, skipping
)
echo.

echo [3/5] Training model...
set RUN_TRAIN=0
if not exist "data\model.pkl" set RUN_TRAIN=1
if exist "data\particles.csv" call :check_newer data\particles.csv data\model.pkl

if %RUN_TRAIN%==1 (
    python model\train.py || goto error
    echo Model trained
) else (
    echo Model up to date, skipping
)
echo.

echo [4/5] Running predictions...
set RUN_PRED=0
if not exist "data\predictions.csv" set RUN_PRED=1
if exist "data\model.pkl" call :check_newer data\model.pkl data\predictions.csv

if %RUN_PRED%==1 (
    python model\predictions.py || goto error
    echo Predictions done
) else (
    echo Predictions up to date, skipping
)
echo.

echo [5/5] Visualizing...
for /f "delims=" %%i in ('python visualize\utils.py') do set DIR=%%i
echo Results dir: %DIR%
start "" python visualize\comparison.py --results "%DIR%"
start "" python visualize\prediction.py --results "%DIR%"
start "" python visualize\simulation.py --results "%DIR%"
echo.

echo =========================================
echo  Process completed!
echo =========================================
pause
exit /b 0

:check_newer
    for %%A in (%1) do set T1=%%~tA
    for %%A in (%2) do set T2=%%~tA
    if "!T1!" gtr "!T2!" set RUN_SIM=1& set RUN_TRAIN=1& set RUN_PRED=1
    exit /b 0

:error
echo.
echo [ERROR] An error occurred during execution
pause
exit /b 1