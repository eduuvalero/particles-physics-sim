@echo off

echo.
echo =========================================
echo Running Particle Physics Simulator
echo =========================================
echo.

cd /d "%~dp0\.."

if not exist "data\particles.csv" (
    echo [ERROR] Executable 'simulator\simulator.exe' not found
    echo Please build the project first using: scripts\build-[win].bat
    pause
    exit /b 1
)

if not exist "data\predictions.csv" (
    echo [ERROR] Executable 'simulator\simulator.exe' not found
    echo Please train the model first using: scripts\train-[win].bat
    pause
    exit /b 1
)

for /f "delims=" %%i in ('python visualize\utils.py') do set DIR=%%i
echo Results dir: %DIR%
start "" python visualize\comparison.py --results "%DIR%"
start "" python visualize\prediction.py --results "%DIR%"
start "" python visualize\simulation.py --results "%DIR%"
echo.

echo.
echo =========================================
echo Process completed!
echo =========================================
echo.

pause
exit /b 0

:error
echo.
echo [ERROR] An error occurred during execution
echo.
pause
exit /b 1
