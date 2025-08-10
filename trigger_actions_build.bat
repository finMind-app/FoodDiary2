@echo off
setlocal enableextensions enabledelayedexpansion

rem Run from this script's folder
cd /d "%~dp0"

rem Load optional env config
if exist actions_env.bat call actions_env.bat

echo This script triggers a GitHub Actions workflow dispatch.
echo Requirements:
echo  - Set GH_REPO in the form OWNER/REPO
echo  - Set GH_TOKEN with a PAT that has repo/workflow scope
echo  - Set WORKFLOW_FILE (e.g. ios-build.yml) OR WORKFLOW_ID

if "%GH_REPO%"=="" (
  echo [env] GH_REPO not set. Example: set GH_REPO=owner/repo
  goto :end
)

if "%GH_TOKEN%"=="" (
  echo [env] GH_TOKEN not set. Create a PAT and set: set GH_TOKEN=xxxx
  goto :end
)

set "API=https://api.github.com/repos/%GH_REPO%/actions/workflows"
if not "%WORKFLOW_ID%"=="" (
  set "WF_SPEC=%WORKFLOW_ID%"
) else (
  if "%WORKFLOW_FILE%"=="" (
    echo [env] Set either WORKFLOW_ID or WORKFLOW_FILE (e.g. set WORKFLOW_FILE=ios-build.yml)
    goto :end
  ) else (
    set "WF_SPEC=%WORKFLOW_FILE%"
  )
)

set "REF=main"
if not "%GIT_REF%"=="" set "REF=%GIT_REF%"

echo Triggering workflow: %WF_SPEC% on ref: %REF%

rem Use curl on Windows (present in recent builds). Fallback: PowerShell Invoke-RestMethod.
where curl >nul 2>&1
if errorlevel 1 (
  echo [curl] Not found. Using PowerShell Invoke-RestMethod...
  powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$Headers = @{ Authorization = 'Bearer %GH_TOKEN%'; 'User-Agent'='curl' }; ^
     $Body = @{ref='%REF%'} | ConvertTo-Json; ^
     Invoke-RestMethod -Method Post -Uri '%API%/%WF_SPEC%/dispatches' -Headers $Headers -ContentType 'application/json' -Body $Body; ^
     Write-Host 'Dispatch requested.'"
) else (
  curl -fsSL -H "Authorization: Bearer %GH_TOKEN%" -H "User-Agent: curl" ^
       -H "Accept: application/vnd.github+json" ^
       -X POST "%API%/%WF_SPEC%/dispatches" ^
       -d "{\"ref\":\"%REF%\"}"
  if errorlevel 1 (
    echo [actions] Dispatch failed.
    goto :end
  )
  echo [actions] Dispatch requested.
)

echo.
echo Tip: set variables once per session, e.g.:
echo   set GH_REPO=owner/repo
echo   set GH_TOKEN=ghp_xxx
echo   set WORKFLOW_FILE=ios-build.yml
echo   set GIT_REF=main

:end
if not defined NO_PAUSE pause
endlocal


