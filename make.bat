@echo off
SETLOCAL

CALL :NORMALIZEPATH "."
SET ROOT_DIR=%RETVAL%

if "%1"=="x64" (
  set CFG=amd64
)
if "%1"=="x86" (
  set CFG=amd64_x86
)

set "DIRNAME=buildDir"
set "FLAGS=-GNinja"

CALL "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvarsall.bat" %CFG%

if not exist %DIRNAME% mkdir %DIRNAME%
cd %DIRNAME%

cmake .. %FLAGS%
ninja
cd ..

:: ========== FUNCTIONS ==========
EXIT /B

:NORMALIZEPATH
  SET RETVAL=%~f1
  EXIT /B