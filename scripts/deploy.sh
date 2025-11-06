#!/bin/bash

# PiOSK Deployment Script
# This script pulls the latest changes from GitHub and deploys them

set -e  # Exit on any error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "🚀 Starting PiOSK deployment..."
echo "📁 Project directory: $PROJECT_DIR"

# Navigate to project directory
cd "$PROJECT_DIR"

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo "❌ Error: Not a git repository"
    exit 1
fi

# Stash any local changes (if any)
echo "💾 Stashing any local changes..."
git stash

# Pull latest changes from GitHub
echo "⬇️ Pulling latest changes from GitHub..."
git pull origin main

# Check if package.json has changed and update dependencies
if git diff HEAD@{1} --name-only | grep -q "package.json"; then
    echo "📦 package.json changed, updating dependencies..."
    npm install
fi

# Make scripts executable
echo "🔧 Making scripts executable..."
chmod +x scripts/*.sh

# Check if services need to be restarted
if git diff HEAD@{1} --name-only | grep -q -E "(index.js|web/|services/|config.json)"; then
    echo "🔄 Application files changed, restart may be needed..."
    echo "   Run: sudo systemctl restart piosk-* (if services are installed)"
fi

echo "✅ Deployment completed successfully!"
echo "🔍 Current commit: $(git rev-parse --short HEAD)"
echo "📝 Latest commit message: $(git log -1 --pretty=format:'%s')"

# Show status
echo ""
echo "📊 Repository status:"
git status --porcelain