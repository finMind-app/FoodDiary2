@echo off
setlocal enableextensions enabledelayedexpansion

cd /d "%~dp0"

echo WARNING: This will overwrite remote branch 'main' with local state.
echo Repository: https://github.com/finMind-app/FoodDiary2.git
echo.

set "REMOTE=https://github.com/finMind-app/FoodDiary2.git"
set "BRANCH=main"

rem Ensure repository and identity
git rev-parse --is-inside-work-tree >nul 2>&1 || git init
for /f "delims=" %%U in ('git config --get user.name 2^>nul') do set "_UN=%%U"
for /f "delims=" %%E in ('git config --get user.email 2^>nul') do set "_UE=%%E"
if "%_UN%"=="" git config user.name "Local User"
if "%_UE%"=="" git config user.email "local@example.com"

rem Ensure origin points to target repo
git remote get-url origin >nul 2>&1
if errorlevel 1 (
  git remote add origin "%REMOTE%"
) else (
  git remote set-url origin "%REMOTE%" >nul 2>&1
)

rem Ensure main branch exists and is checked out
git show-ref --verify --quiet refs/heads/%BRANCH% || git checkout -b %BRANCH%
git rev-parse --abbrev-ref HEAD | findstr /i "^%BRANCH%$" >nul || git checkout %BRANCH%

rem Stage/commit whatever is present (ok if nothing to commit)
set "MSG=%*"
if "%MSG%"=="" set "MSG=force update %date% %time%"
git add -A
git commit -m "%MSG%" >nul 2>&1

rem Ensure at least one commit exists
git rev-parse --verify HEAD >nul 2>&1 || git commit --allow-empty -m "chore: initial commit" >nul 2>&1

rem Make lease aware and push forcefully
git fetch origin >nul 2>&1
echo [git] Force pushing to origin %BRANCH% (with lease)...
git push -u --force-with-lease origin %BRANCH%

echo.
echo [git] Done. Remote 'main' should now match local state.
pause
endlocal


