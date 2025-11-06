@echo off
REM PiOSK Remote Deploy Script for Windows
REM Run this on your Windows computer to deploy changes to your Pi

setlocal enabledelayedexpansion

REM Configuration - Update these with your Pi details
set PI_HOST=yb@piTFT
set PI_PROJECT_PATH=/home/yb/codes/piosk

echo 🚀 Deploying PiOSK to Pi...

REM Check if we have git
git --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Git is not installed or not in PATH
    pause
    exit /b 1
)

REM Check if we have uncommitted changes
git diff-index --quiet HEAD -- >nul 2>&1
if %errorlevel% neq 0 (
    echo ⚠️  You have uncommitted changes. Please commit them first:
    echo    git add .
    echo    git commit -m "your commit message"
    echo    git push
    pause
    exit /b 1
)

REM Check if we need to push
for /f %%i in ('git rev-parse HEAD') do set LOCAL_HEAD=%%i
for /f %%i in ('git rev-parse @{u} 2^>nul') do set REMOTE_HEAD=%%i

if "!LOCAL_HEAD!" neq "!REMOTE_HEAD!" (
    echo 📤 Pushing changes to GitHub...
    git push
    if %errorlevel% neq 0 (
        echo ❌ Failed to push changes
        pause
        exit /b 1
    )
)

REM Check if SSH is available
ssh -V >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ SSH is not available. Please install OpenSSH or use WSL/Git Bash
    echo 💡 Alternative: Use PuTTY/WinSCP or manually SSH to your Pi
    echo    On Pi, run: cd %PI_PROJECT_PATH% ^&^& ./scripts/deploy.sh
    pause
    exit /b 1
)

REM SSH to Pi and run deployment
echo 🔗 Connecting to Pi and deploying...
ssh %PI_HOST% "cd %PI_PROJECT_PATH% && ./scripts/deploy.sh"
if %errorlevel% neq 0 (
    echo ❌ Deployment failed. Check your SSH connection and Pi details.
    echo 💡 Make sure you can SSH to your Pi: ssh %PI_HOST%
    pause
    exit /b 1
)

echo ✅ Deployment completed!

REM Optional: Show Pi status
echo.
set /p REPLY="🔍 Would you like to check the service status on Pi? (y/n): "
if /i "!REPLY!"=="y" (
    ssh %PI_HOST% "sudo systemctl status piosk-* 2>/dev/null || echo 'Services not yet installed. Run setup.sh first.'"
)

pause