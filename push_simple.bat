@echo off
setlocal enableextensions enabledelayedexpansion

rem Run from this script's folder
cd /d "%~dp0"

set "REMOTE=https://github.com/finMind-app/FoodDiary2.git"

rem Ensure repository exists
git rev-parse --is-inside-work-tree >nul 2>&1
if errorlevel 1 (
  echo [git] Initializing repository...
  git init
)

rem Ensure origin is configured
git remote get-url origin >nul 2>&1
if errorlevel 1 (
  echo [git] Setting origin to %REMOTE%
  git remote add origin "%REMOTE%"
)

rem Ensure minimal identity (local-only) for commit
for /f "delims=" %%U in ('git config --get user.name 2^>nul') do set "_UN=%%U"
for /f "delims=" %%E in ('git config --get user.email 2^>nul') do set "_UE=%%E"
if "%_UN%"=="" git config user.name "Local User"
if "%_UE%"=="" git config user.email "local@example.com"

rem Optional commit message from args; otherwise use date/time
set "MSG=%*"
if "%MSG%"=="" set "MSG=update %date% %time%"

echo [git] Adding changes...
git add -A

echo [git] Committing: %MSG%
git commit -m "%MSG%" >nul 2>&1
if errorlevel 1 echo [git] Nothing to commit or commit failed; continuing to push...

rem Ensure branch exists (fallback/create main)
set "BRANCH="
for /f "delims=" %%B in ('git rev-parse --abbrev-ref HEAD 2^>nul') do set "BRANCH=%%B"
if "%BRANCH%"=="" set "BRANCH=main"

rem Create/checkout main if needed
git show-ref --verify --quiet refs/heads/%BRANCH%
if errorlevel 1 (
  git checkout -b %BRANCH% >nul 2>&1
)

rem If there are still no commits, create an empty initial commit
git rev-parse --verify HEAD >nul 2>&1
if errorlevel 1 (
  echo [git] Creating initial empty commit...
  git commit --allow-empty -m "chore: initial commit" >nul 2>&1
)

echo [git] Pushing to origin %BRANCH%...
git push -u origin %BRANCH%
if errorlevel 1 (
  echo.
  echo [git] Push failed. Make sure remote 'origin' is configured and you have access.
  echo       If needed, run: git remote set-url origin %REMOTE%
)

echo.
echo [git] Done.
pause
endlocal


