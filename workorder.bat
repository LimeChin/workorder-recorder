@echo off
setlocal enabledelayedexpansion
chcp 936 >nul
title Work Order Code Recorder

set SCRIPT_DIR=%~dp0
set CONFIG_FILE=%SCRIPT_DIR%config.json

:menu
cls
echo ================================================
echo           Work Order Code Recorder
echo ================================================
echo.

if exist "%SCRIPT_DIR%.workorder_project.txt" (
    set /p GIT_REPO=<"%SCRIPT_DIR%.workorder_project.txt"
    echo [Git Repo] !GIT_REPO!
) else (
    echo [Git Repo] Not Set
)

for /f "tokens=2 delims=:, " %%a in ('type "%SCRIPT_DIR%.workorder_config.json" 2^>nul') do set WORKORDER=%%a
set WORKORDER=!WORKORDER:"=!
set WORKORDER=!WORKORDER:}=!
if defined WORKORDER (
    echo [Work Order] !WORKORDER!
) else (
    echo [Work Order] Not Set
)

echo.
echo ================================================
echo   [1] Select Git Repo
echo   [2] Set Work Order
echo   [3] Install Hook
echo   [4] View Status
echo   [5] Exit
echo ================================================
echo.
set /p choice=Select (1-5):

if "!choice!"=="1" goto set_project
if "!choice!"=="2" goto set_workorder
if "!choice!"=="3" goto install
if "!choice!"=="4" goto status
if "!choice!"=="5" goto exit_menu
echo.
echo [Error] Invalid choice
pause
goto menu

:set_project
cls
echo ================================================
echo           Select Git Repo
echo ================================================
echo.
echo Scanning...
echo.
set count=0
for /f "delims=" %%d in ('dir /b /ad 2^>nul') do (
    if exist "%%d\.git" (
        set /a count+=1
        set "repo!count!=%%~fd"
        echo   [!count!] %%d
    )
)
echo.
set /p num=Select:
call set "SELECTED=%%repo!num!%%"
echo !SELECTED!>"%SCRIPT_DIR%.workorder_project.txt"
echo.
echo [Success] !SELECTED!
echo.
pause
goto menu

:set_workorder
cls
echo ================================================
echo           Set Work Order
echo ================================================
echo.
set /p WORKORDER=Enter Work Order:
echo {"current_workorder": "!WORKORDER!"}>"%SCRIPT_DIR%.workorder_config.json"
echo.
echo [Success] !WORKORDER!
echo.
pause
goto menu

:install
cls
echo ================================================
echo           Install Hook
echo ================================================
echo.
if not exist "%SCRIPT_DIR%.workorder_project.txt" (
    echo [Error] Select Git Repo first
    pause
    goto menu
)
set /p INSTALL_PROJECT=<"%SCRIPT_DIR%.workorder_project.txt"
echo Target: !INSTALL_PROJECT!\.git\hooks\post-commit
echo.
echo Installing...
copy "%SCRIPT_DIR%post-commit" "!INSTALL_PROJECT!\.git\hooks\post-commit"
if exist "!INSTALL_PROJECT!\.git\hooks\post-commit" (
    echo.
    echo [Success] Hook installed!
) else (
    echo.
    echo [Error] Installation failed
)
echo [Repo] !INSTALL_PROJECT!
echo.
pause
goto menu

:status
cls
echo ================================================
echo           Current Status
echo ================================================
echo.
if exist "%SCRIPT_DIR%.workorder_project.txt" (
    set /p P=<"%SCRIPT_DIR%.workorder_project.txt"
    echo [Git Repo] !P!
) else (
    echo [Git Repo] Not Set
)
for /f "tokens=2 delims=:, " %%a in ('type "%SCRIPT_DIR%.workorder_config.json" 2^>nul') do set W=%%a
set W=!W:"=!
set W=!W:}=!
if defined W (
    echo [Work Order] !W!
) else (
    echo [Work Order] Not Set
)
echo.
pause
goto menu

:exit_menu
exit