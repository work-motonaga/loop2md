@echo off
setlocal

set "SCRIPT_DIR=%~dp0"
pushd "%SCRIPT_DIR%" >nul
if errorlevel 1 (
    echo Failed to access script directory: %SCRIPT_DIR%
    exit /b 1
)

"C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -STA -File "%CD%\loop2md_form.ps1"
set "EXITCODE=%ERRORLEVEL%"

popd
exit /b %EXITCODE%
