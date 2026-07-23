@echo off
setlocal
cd /d "%~dp0"
start "" powershell.exe -NoLogo -NoProfile -STA -WindowStyle Hidden -ExecutionPolicy Bypass -File "%~dp0DeepFaceLab-GUI.ps1"
endlocal
