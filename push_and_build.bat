@echo off
setlocal enableextensions enabledelayedexpansion

cd /d "%~dp0"

rem Optional: commit message as args
set "MSG=%*"

set "NO_PAUSE=1"
call "%~dp0push_changes.bat" %MSG%

echo Triggering Actions build...
set "NO_PAUSE=1"
call "%~dp0trigger_actions_build.bat"

endlocal
pause


