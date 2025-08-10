@echo off
setlocal enableextensions enabledelayedexpansion

rem Run from this script's folder (should be FoodDiary2)
cd /d "%~dp0"

set "KEEP_DIR=FoodDiaryTwo"
set "SELF=%~nx0"

echo Cleaning folder: %cd%
echo Keeping only: %KEEP_DIR%

for /f "delims=" %%I in ('dir /b /a') do (
  if /i not "%%~nxI"=="%KEEP_DIR%" if /i not "%%~nxI"=="%SELF%" (
    attrib -r -s -h "%%~fI" /s /d >nul 2>&1
    if exist "%%~fI\*" (
      echo Deleting directory: "%%~fI"
      rd /s /q "%%~fI" >nul 2>&1
    ) else (
      echo Deleting file: "%%~fI"
      del /f /q "%%~fI" >nul 2>&1
    )
  )
)

echo.
echo Done. Only "%KEEP_DIR%" remains.
pause


