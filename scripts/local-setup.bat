@echo off
REM PiOSK Local Development Setup Script for Windows
REM Run this on your Windows computer to set up the development environment

echo 🛠️ Setting up PiOSK local development environment on Windows...

REM Check if git is installed
git --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Git is not installed. Please install git first from: https://git-scm.com/
    pause
    exit /b 1
)

REM Check if Node.js is installed
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Node.js is not installed. Please install Node.js first from: https://nodejs.org/
    pause
    exit /b 1
)

REM Check if we're already in the project directory
if exist "package.json" (
    findstr /C:"piosk" package.json >nul
    if %errorlevel% equ 0 (
        echo ✅ Already in PiOSK project directory
        set PROJECT_DIR=%cd%
        goto :install_deps
    )
)

REM Clone the repository if not exists
echo 📥 Cloning PiOSK repository...
git clone https://github.com/WindriderQc/piosk.git
if %errorlevel% neq 0 (
    echo ❌ Failed to clone repository
    pause
    exit /b 1
)
set PROJECT_DIR=%cd%\piosk
cd "%PROJECT_DIR%"

:install_deps
REM Install dependencies
echo 📦 Installing dependencies...
npm install
if %errorlevel% neq 0 (
    echo ❌ Failed to install dependencies
    pause
    exit /b 1
)

REM Copy config sample if config doesn't exist
if not exist "config.json" (
    echo ⚙️ Creating config.json from sample...
    copy config.json.sample config.json
    echo 📝 Please edit config.json with your settings before deploying
)

echo.
echo ✅ Local development setup completed!
echo 📁 Project directory: %PROJECT_DIR%
echo.
echo 🚀 Quick start commands:
echo   • Test locally: npm start
echo   • Make changes and commit: git add . ^&^& git commit -m "your message"
echo   • Push changes: git push
echo.
echo 🏠 To deploy to your Pi:
echo   • Edit scripts\remote-deploy.bat with your Pi details
echo   • Run: scripts\remote-deploy.bat
echo   • Or SSH to your Pi and run: cd /home/yb/codes/piosk ^&^& ./scripts/deploy.sh

pause