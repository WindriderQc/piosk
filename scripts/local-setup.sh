#!/bin/bash

# PiOSK Local Development Setup Script
# Run this on your local computer to set up the development environment

set -e

echo "🛠️ Setting up PiOSK local development environment..."

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo "❌ Git is not installed. Please install git first."
    exit 1
fi

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js first."
    exit 1
fi

# Check if we're already in the project directory
if [ -f "package.json" ] && grep -q "piosk" package.json; then
    echo "✅ Already in PiOSK project directory"
    PROJECT_DIR="$(pwd)"
else
    # Clone the repository if not exists
    echo "📥 Cloning PiOSK repository..."
    git clone https://github.com/WindriderQc/piosk.git
    PROJECT_DIR="$(pwd)/piosk"
    cd "$PROJECT_DIR"
fi

# Install dependencies
echo "📦 Installing dependencies..."
npm install

# Copy config sample if config doesn't exist
if [ ! -f "config.json" ]; then
    echo "⚙️ Creating config.json from sample..."
    cp config.json.sample config.json
    echo "📝 Please edit config.json with your settings before deploying"
fi

echo ""
echo "✅ Local development setup completed!"
echo "📁 Project directory: $PROJECT_DIR"
echo ""
echo "🚀 Quick start commands:"
echo "  • Test locally: npm start"
echo "  • Make changes and commit: git add . && git commit -m 'your message'"
echo "  • Push changes: git push"
echo ""
echo "🏠 To deploy to your Pi, run on the Pi:"
echo "  • ssh to your Pi and run: cd /home/yb/codes/piosk && ./scripts/deploy.sh"