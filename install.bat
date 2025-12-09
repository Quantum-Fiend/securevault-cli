@echo off
REM Quantum-Fiend Installer
REM One-time installation script (requires Administrator)

echo.
echo ========================================
echo   QUANTUM-FIEND INSTALLER
echo   SecureVault CLI - Hacker Interface
echo ========================================
echo.

REM Check for admin privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] This installer requires Administrator privileges.
    echo.
    echo Please right-click this file and select "Run as administrator"
    echo.
    pause
    exit /b 1
)

echo [INFO] Administrator privileges confirmed.
echo.

REM Set source and destination paths
set "SOURCE_DIR=%~dp0"
set "QUANTUM_FIEND_EXE=%SOURCE_DIR%Quantum-Fiend.exe"
set "DEST_DIR=C:\Windows\System32"

echo [INFO] Checking for executables...
echo.

REM Check if Quantum-Fiend.exe exists
if not exist "%QUANTUM_FIEND_EXE%" (
    echo [ERROR] Quantum-Fiend.exe not found in current directory.
    echo Expected location: %QUANTUM_FIEND_EXE%
    echo.
    pause
    exit /b 1
)

echo [INFO] Installing Quantum-Fiend...
copy "%QUANTUM_FIEND_EXE%" "%DEST_DIR%\" >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Failed to copy Quantum-Fiend.exe to System32
    pause
    exit /b 1
)
echo [SUCCESS] Quantum-Fiend.exe installed to System32

REM Remove old vault.exe if it exists
if exist "%DEST_DIR%\vault.exe" (
    echo [INFO] Removing old vault.exe...
    del "%DEST_DIR%\vault.exe" >nul 2>&1
    if %errorLevel% equ 0 (
        echo [SUCCESS] Old vault.exe removed
    )
)

echo.
echo ========================================
echo   INSTALLATION COMPLETE!
echo ========================================
echo.
echo You can now use this command from ANY terminal:
echo   - Quantum-Fiend    (Interactive dark-themed interface)
echo.
echo NO ADMINISTRATOR PRIVILEGES NEEDED for normal use!
echo.
echo Try it now: Open a new Command Prompt or PowerShell
echo and type: Quantum-Fiend
echo.
pause
