@echo off
setlocal enableextensions enabledelayedexpansion

cd /d "%~dp0"

set "REMOTE=https://github.com/finMind-app/FoodDiary2.git"
set "BRANCH=main"

git rev-parse --is-inside-work-tree >nul 2>&1
if errorlevel 1 (
  echo [git] Initializing repository...
  git init
)

git remote get-url origin >nul 2>&1
if errorlevel 1 (
  echo [git] Setting origin to %REMOTE%
  git remote add origin "%REMOTE%"
) else (
  git remote set-url origin "%REMOTE%" >nul 2>&1
)

rem Ensure branch exists and checked out
git show-ref --verify --quiet refs/heads/%BRANCH%
if errorlevel 1 (
  git checkout -b %BRANCH%
) else (
  git checkout %BRANCH%
)

set "MSG=%*"
if "%MSG%"=="" set "MSG=update %date% %time%"

echo [git] Adding changes...
git add -A

echo [git] Committing: %MSG%
git commit -m "%MSG%" >nul 2>&1
if errorlevel 1 echo [git] Nothing to commit or commit failed; continuing to push...

echo [git] Pushing to origin %BRANCH%...
git push -u origin %BRANCH%

echo.
echo [git] Done.
pause
endlocal


