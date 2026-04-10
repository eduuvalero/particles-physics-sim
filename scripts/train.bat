@echo off
setlocal enabledelayedexpansion

cd /d "%~dp0\.."

echo.
echo =========================================
echo  EXECUTING SIMULATOR AND TRAINING MODEL
echo =========================================
echo.

if not exist "data\dataset.csv" (
    echo [ERROR] Executable 'simulator\simulator.exe' not found
    echo Please create data\dataset.csv
    pause
    exit /b 1
)

if not exist "simulator\simulator.exe" (
    echo [ERROR] Executable 'simulator\simulator.exe' not found
    echo Please build the project first using: scripts\build-[win].bat
    pause
    exit /b 1
)

echo [1/3] Running simulator...
simulator\simulator.exe || goto error
echo Simulator executed
echo.

echo [2/3] Training model...
python model\train.py || goto error
echo Model trained
echo.

echo [3/3] Running predictions...
python model\predictions.py || goto error
echo Predictions done
echo.

echo =========================================
echo  Process completed!
echo =========================================
pause
exit /b 0

:error
echo.
echo [ERROR] An error occurred during execution
pause
exit /b 1