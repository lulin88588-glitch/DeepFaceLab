@echo off
setlocal
cd /d "%~dp0"
wscript.exe //nologo "%~dp0DeepFaceLab-OneClick.vbs"
endlocal
