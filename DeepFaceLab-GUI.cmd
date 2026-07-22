@echo off
setlocal
cd /d "%~dp0"
powershell.exe -NoLogo -NoProfile -STA -ExecutionPolicy Bypass -File "%~dp0DeepFaceLab-GUI.ps1"
if errorlevel 1 pause
endlocal
