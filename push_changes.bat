@echo off
setlocal enableextensions enabledelayedexpansion

rem Run from this script's folder
cd /d "%~dp0"

rem Load optional env config (remote URL, default branch, etc.)
if exist actions_env.bat call actions_env.bat

rem Optional: pass commit message as args
set "COMMIT_MSG=%*"
if "%COMMIT_MSG%"=="" set "COMMIT_MSG=chore: update %date% %time%"

rem Ensure git repo exists
if not exist .git (
  echo [git] Initializing new repository in %cd%
  git init
)

rem Detect current branch or default
set "BRANCH="
for /f "delims=" %%B in ('git rev-parse --abbrev-ref HEAD 2^>nul') do set "BRANCH=%%B"
if "%BRANCH%"=="" (
  if not "%GIT_DEFAULT_BRANCH%"=="" (
    set "BRANCH=%GIT_DEFAULT_BRANCH%"
  ) else (
    set "BRANCH=main"
  )
)

rem Stage and commit
echo [git] Adding changes...
git add -A

echo [git] Committing: %COMMIT_MSG%
git commit -m "%COMMIT_MSG%" >nul 2>&1
if errorlevel 1 (
  echo [git] Nothing to commit or commit failed; continuing to push...
)

rem Check remote origin
set "REMOTE_URL="
for /f "delims=" %%R in ('git config --get remote.origin.url 2^>nul') do set "REMOTE_URL=%%R"
if "%REMOTE_URL%"=="" (
  rem Try to configure from environment
  set "CANDIDATE_URL=%GIT_REMOTE_URL%"
  if "%CANDIDATE_URL%"=="" if not "%GH_REPO%"=="" set "CANDIDATE_URL=https://github.com/%GH_REPO%.git"
  if not "%CANDIDATE_URL%"=="" (
    echo [git] Setting remote origin to %CANDIDATE_URL%
    git remote add origin "%CANDIDATE_URL%"
    set "REMOTE_URL=%CANDIDATE_URL%"
  ) else (
    echo.
    echo [git] No remote 'origin' configured.
    echo        Configure once and re-run. Options:
    echo        - Set env var GIT_REMOTE_URL (or GH_REPO=owner/repo)
    echo        - Or manually: git remote add origin https://github.com/OWNER/REPO.git
    echo.
    goto :end
  )
)

rem Ensure branch exists locally
git show-ref --verify --quiet refs/heads/%BRANCH%
if errorlevel 1 (
  echo [git] Creating branch %BRANCH%
  git checkout -b %BRANCH%
)

echo [git] Pushing to %REMOTE_URL% (%BRANCH%)
git push -u origin %BRANCH%
if errorlevel 1 (
  echo.
  echo [git] Push failed. Check credentials/permissions and try again.
  echo.
  goto :end
)

echo.
echo [git] Push completed successfully on branch %BRANCH%.

:end
if not defined NO_PAUSE pause
endlocal


