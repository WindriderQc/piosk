# PiOSK Remote Deploy Script for Windows (PowerShell)
# Run this on your Windows computer to deploy changes to your Pi

param(
    [string]$PiHost = "yb@piTFT",
    [string]$PiProjectPath = "/home/yb/codes/piosk"
)

Write-Host "Deploying PiOSK to Pi..." -ForegroundColor Green

# Check if we have git
try {
    git --version | Out-Null
} catch {
    Write-Host "Git is not installed or not in PATH" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Check if we have uncommitted changes
$uncommittedChanges = git diff-index --quiet HEAD --
if ($LASTEXITCODE -ne 0) {
    Write-Host "You have uncommitted changes. Please commit them first:" -ForegroundColor Yellow
    Write-Host "   git add ."
    Write-Host "   git commit -m 'your commit message'"
    Write-Host "   git push"
    Read-Host "Press Enter to exit"
    exit 1
}

# Check if we need to push
$localHead = git rev-parse HEAD
$remoteHead = git rev-parse "@{u}" 2>$null

if ($localHead -ne $remoteHead) {
    Write-Host "Pushing changes to GitHub..." -ForegroundColor Blue
    git push
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed to push changes" -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit 1
    }
}

# Check if SSH is available
try {
    ssh -V 2>$null | Out-Null
} catch {
    Write-Host "SSH is not available. Please install OpenSSH or use WSL" -ForegroundColor Red
    Write-Host "Alternative: Use PuTTY/WinSCP or manually SSH to your Pi" -ForegroundColor Cyan
    Write-Host "   On Pi, run: cd $PiProjectPath && ./scripts/deploy.sh"
    Read-Host "Press Enter to exit"
    exit 1
}

# SSH to Pi and run deployment
Write-Host "Connecting to Pi and deploying..." -ForegroundColor Blue
ssh $PiHost "cd $PiProjectPath && ./scripts/deploy.sh"

if ($LASTEXITCODE -ne 0) {
    Write-Host "Deployment failed. Check your SSH connection and Pi details." -ForegroundColor Red
    Write-Host "Make sure you can SSH to your Pi: ssh $PiHost" -ForegroundColor Cyan
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "Deployment completed!" -ForegroundColor Green

# Optional: Show Pi status
Write-Host ""
$reply = Read-Host "Would you like to check the service status on Pi? (y/n)"
if ($reply -eq "y" -or $reply -eq "Y") {
    ssh $PiHost "sudo systemctl status piosk-* 2>/dev/null || echo 'Services not yet installed. Run setup.sh first.'"
}

Read-Host "Press Enter to exit"