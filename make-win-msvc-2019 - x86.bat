@echo off
SETLOCAL

CALL :NORMALIZEPATH "."
SET ROOT_DIR=%RETVAL%

set "DIRNAME=build-win-msvc-2019-x86"

set "FLAGS=-GNinja"

CALL "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvarsall.bat" amd64_x86

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