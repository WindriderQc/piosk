#!/bin/bash

# PiOSK Remote Deploy Script
# Run this on your local computer to deploy changes to your Pi

set -e

# Configuration - Update these with your Pi details
PI_HOST="yb@piTFT"  # Change this to your Pi's IP or hostname
PI_PROJECT_PATH="/home/yb/codes/piosk"

echo "🚀 Deploying PiOSK to Pi..."

# Check if we have uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo "⚠️  You have uncommitted changes. Please commit them first:"
    echo "   git add ."
    echo "   git commit -m 'your commit message'"
    echo "   git push"
    exit 1
fi

# Check if we need to push
if [ "$(git rev-parse HEAD)" != "$(git rev-parse @{u} 2>/dev/null || echo '')" ]; then
    echo "📤 Pushing changes to GitHub..."
    git push
fi

# SSH to Pi and run deployment
echo "🔗 Connecting to Pi and deploying..."
ssh "$PI_HOST" "cd $PI_PROJECT_PATH && ./scripts/deploy.sh"

echo "✅ Deployment completed!"

# Optional: Show Pi status
echo ""
read -p "🔍 Would you like to check the service status on Pi? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    ssh "$PI_HOST" "sudo systemctl status piosk-* 2>/dev/null || echo 'Services not yet installed. Run setup.sh first.'"
fi