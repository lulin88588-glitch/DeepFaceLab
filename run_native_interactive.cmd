@echo off
setlocal

if not defined DFL_GUI_LEGACY_INTERNAL (
    echo [DeepFaceLab GUI] DFL_GUI_LEGACY_INTERNAL is not configured.
    pause
    exit /b 2
)

if not exist "%DFL_GUI_LEGACY_INTERNAL%\setenv.bat" (
    echo [DeepFaceLab GUI] Legacy runtime not found:
    echo %DFL_GUI_LEGACY_INTERNAL%
    pause
    exit /b 3
)

call "%DFL_GUI_LEGACY_INTERNAL%\setenv.bat"
"%PYTHON_EXECUTABLE%" "%~dp0main.py" %*
set "DFL_GUI_EXIT_CODE=%ERRORLEVEL%"

echo.
if "%DFL_GUI_EXIT_CODE%"=="0" (
    echo [DeepFaceLab GUI] Operation finished.
) else (
    echo [DeepFaceLab GUI] Operation failed with exit code %DFL_GUI_EXIT_CODE%.
)
pause
exit /b %DFL_GUI_EXIT_CODE%
