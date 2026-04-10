@echo off
REM Particle Physics Simulator - Windows Build Script
setlocal enabledelayedexpansion

cd /d "%~dp0\.."

echo.
echo =========================================
echo  Particle Physics Simulator - Windows
echo =========================================
echo.

REM Check g++
where g++ >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] g++ not found. Install MinGW.
    pause
    exit /b 1
)

echo Compiling code...

REM Clean previous object files
del simulator\*.o 2>nul

REM Compile source files
g++ -std=c++17 -Wall -g -fopenmp -c simulator\Particle.cc -o simulator\Particle.o || goto error
echo g++ -std=c++17 -Wall -g -fopenmp -c simulator\Particle.cc -o simulator\Particle.o
g++ -std=c++17 -Wall -g -fopenmp -c simulator\Physics.cc -o simulator\Physics.o || goto error
echo g++ -std=c++17 -Wall -g -fopenmp -c simulator\Physics.cc -o simulator\Physics.o
g++ -std=c++17 -Wall -g -fopenmp -c simulator\main.cc -o simulator\main.o || goto error
echo g++ -std=c++17 -Wall -g -fopenmp -c simulator\main.cc -o simulator\main.o

REM Link executable
g++ -std=c++17 -Wall -g -fopenmp simulator\Particle.o simulator\Physics.o simulator\main.o -o simulator\simulator.exe || goto error
echo g++ -std=c++17 -Wall -g -fopenmp simulator\Particle.o simulator\Physics.o simulator\main.o -o simulator\simulator.exe

echo Compilation successful
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