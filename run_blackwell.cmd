@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0run_blackwell.ps1" %*
exit /b %ERRORLEVEL%
