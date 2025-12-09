@echo off
REM Quantum-Fiend Uninstaller
REM Removes Quantum-Fiend from System32 (requires Administrator)

echo.
echo ========================================
echo   QUANTUM-FIEND UNINSTALLER
echo ========================================
echo.

REM Check for admin privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] This uninstaller requires Administrator privileges.
    echo.
    echo Please right-click this file and select "Run as administrator"
    echo.
    pause
    exit /b 1
)

echo [INFO] Administrator privileges confirmed.
echo.

set "DEST_DIR=C:\Windows\System32"

echo [INFO] Removing Quantum-Fiend...
if exist "%DEST_DIR%\Quantum-Fiend.exe" (
    del "%DEST_DIR%\Quantum-Fiend.exe" >nul 2>&1
    if %errorLevel% equ 0 (
        echo [SUCCESS] Quantum-Fiend.exe removed
    ) else (
        echo [ERROR] Failed to remove Quantum-Fiend.exe
    )
) else (
    echo [INFO] Quantum-Fiend.exe not found in System32
)

if exist "%DEST_DIR%\vault.exe" (
    echo [INFO] Removing vault.exe...
    del "%DEST_DIR%\vault.exe" >nul 2>&1
    if %errorLevel% equ 0 (
        echo [SUCCESS] vault.exe removed
    ) else (
        echo [ERROR] Failed to remove vault.exe
    )
)

echo.
echo ========================================
echo   UNINSTALLATION COMPLETE!
echo ========================================
echo.
pause
