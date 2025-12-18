# Docker Disk Cleanup Script for Windows 10 Home/WSL2
# This script cleans up Docker data and compacts the VHDX file using diskpart

Write-Host "=== Docker Disk Cleanup Script ===" -ForegroundColor Cyan
Write-Host ""

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "ERROR: This script must be run as Administrator." -ForegroundColor Red
    Write-Host "Please right-click and select 'Run as administrator'" -ForegroundColor Red
    exit
}

# Step 1: Show current Docker disk usage
Write-Host "Step 1: Current Docker disk usage" -ForegroundColor Green
docker system df
Write-Host ""

# Step 2: Clean up Docker data
Write-Host "Step 2: Cleaning up Docker data..." -ForegroundColor Green
Write-Host "This will remove:" -ForegroundColor Yellow
Write-Host "  - All stopped containers" -ForegroundColor Yellow
Write-Host "  - All unused images" -ForegroundColor Yellow
Write-Host "  - All unused build cache" -ForegroundColor Yellow
Write-Host "  - All unused volumes" -ForegroundColor Yellow
Write-Host ""

$confirmation = Read-Host "Do you want to proceed? (y/n)"
if ($confirmation -ne 'y') {
    Write-Host "Cleanup cancelled." -ForegroundColor Red
    exit
}

docker system prune -a --volumes -f
Write-Host ""

# Step 3: Show disk usage after cleanup
Write-Host "Step 3: Docker disk usage after cleanup" -ForegroundColor Green
docker system df
Write-Host ""

# Step 4: Locate VHDX file
Write-Host "Step 4: Locating Docker VHDX files..." -ForegroundColor Green
$vhdxPath = "$env:LOCALAPPDATA\Docker\wsl\disk\docker_data.vhdx"
$vhdxMainPath = "$env:LOCALAPPDATA\Docker\wsl\main\ext4.vhdx"

$vhdxFound = $false

if (Test-Path $vhdxPath) {
    $sizeBefore = (Get-Item $vhdxPath).Length / 1GB
    Write-Host "Found: $vhdxPath" -ForegroundColor Cyan
    Write-Host "Current size: $([math]::Round($sizeBefore, 2)) GB" -ForegroundColor Cyan
    $vhdxFound = $true
} else {
    Write-Host "VHDX file not found at: $vhdxPath" -ForegroundColor Red
}

if (Test-Path $vhdxMainPath) {
    $sizeBeforeMain = (Get-Item $vhdxMainPath).Length / 1GB
    Write-Host "Found: $vhdxMainPath" -ForegroundColor Cyan
    Write-Host "Current size: $([math]::Round($sizeBeforeMain, 2)) GB" -ForegroundColor Cyan
} else {
    Write-Host "Main VHDX file not found at: $vhdxMainPath" -ForegroundColor Red
}
Write-Host ""

if (-not $vhdxFound) {
    Write-Host "ERROR: Could not find Docker VHDX file." -ForegroundColor Red
    exit
}

# Step 5: Stop Docker Desktop
Write-Host "Step 5: Stopping Docker Desktop..." -ForegroundColor Green
Write-Host "This may take a minute..." -ForegroundColor Yellow

Stop-Process -Name "Docker Desktop" -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
wsl --shutdown
Start-Sleep -Seconds 3

Write-Host "Docker Desktop stopped." -ForegroundColor Green
Write-Host ""

# Step 6: Compact VHDX files using diskpart
Write-Host "Step 6: Compacting VHDX files using diskpart..." -ForegroundColor Green
Write-Host "This may take 10-30 minutes depending on size..." -ForegroundColor Yellow
Write-Host ""

# Create diskpart script
$diskpartScript = @"
select vdisk file="$vhdxPath"
attach vdisk readonly
compact vdisk
detach vdisk
exit
"@

# Save diskpart script to temp file
$tempScript = "$env:TEMP\diskpart_script.txt"
$diskpartScript | Out-File -FilePath $tempScript -Encoding ASCII -Force

# Run diskpart with script
Write-Host "Running diskpart to compact docker_data.vhdx..." -ForegroundColor Yellow
$process = Start-Process -FilePath "diskpart.exe" -ArgumentList "/s", $tempScript -NoNewWindow -PassThru -Wait

if ($process.ExitCode -eq 0) {
    if (Test-Path $vhdxPath) {
        $sizeAfter = (Get-Item $vhdxPath).Length / 1GB
        $saved = $sizeBefore - $sizeAfter
        Write-Host "SUCCESS! Compacted from $([math]::Round($sizeBefore, 2)) GB to $([math]::Round($sizeAfter, 2)) GB" -ForegroundColor Green
        Write-Host "Space reclaimed: $([math]::Round($saved, 2)) GB" -ForegroundColor Green
    }
} else {
    Write-Host "WARNING: diskpart may have encountered issues. Exit code: $($process.ExitCode)" -ForegroundColor Yellow
}

# Clean up temp file
Remove-Item -Path $tempScript -Force -ErrorAction SilentlyContinue

Write-Host ""

# Step 7: Compact main ext4.vhdx if exists
if (Test-Path $vhdxMainPath) {
    Write-Host "Step 7: Compacting ext4.vhdx..." -ForegroundColor Green
    
    $diskpartScript2 = @"
select vdisk file="$vhdxMainPath"
attach vdisk readonly
compact vdisk
detach vdisk
exit
"@

    $tempScript2 = "$env:TEMP\diskpart_script2.txt"
    $diskpartScript2 | Out-File -FilePath $tempScript2 -Encoding ASCII -Force

    Write-Host "Running diskpart to compact ext4.vhdx..." -ForegroundColor Yellow
    $process2 = Start-Process -FilePath "diskpart.exe" -ArgumentList "/s", $tempScript2 -NoNewWindow -PassThru -Wait

    if ($process2.ExitCode -eq 0) {
        $sizeAfterMain = (Get-Item $vhdxMainPath).Length / 1GB
        $savedMain = $sizeBeforeMain - $sizeAfterMain
        Write-Host "SUCCESS! Compacted from $([math]::Round($sizeBeforeMain, 2)) GB to $([math]::Round($sizeAfterMain, 2)) GB" -ForegroundColor Green
        Write-Host "Space reclaimed: $([math]::Round($savedMain, 2)) GB" -ForegroundColor Green
    } else {
        Write-Host "WARNING: diskpart may have encountered issues for ext4.vhdx. Exit code: $($process2.ExitCode)" -ForegroundColor Yellow
    }

    Remove-Item -Path $tempScript2 -Force -ErrorAction SilentlyContinue
    Write-Host ""
}

# Step 8: Start Docker Desktop
Write-Host "Step 8: Restarting Docker Desktop..." -ForegroundColor Green
Write-Host "Please start Docker Desktop manually from Start menu or the system tray." -ForegroundColor Yellow
Write-Host ""

Write-Host "=== Cleanup Complete ===" -ForegroundColor Cyan
Write-Host "Your Docker VHDX files have been compacted. You can now restart Docker Desktop." -ForegroundColor Green
