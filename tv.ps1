# Script to download and install EVK-UNK
# Run as Administrator

$Path = $ENV:TEMP
$Installer = "EVK-UNK-Setup.exe"
$EVKUNKURL = "https://github.com/hiepvk/ipa/releases/download/exe/EVK-UNK-Setup.exe"

# --- Download Section ---
Write-Host "⏳ Downloading EVK-UNK..." -ForegroundColor Yellow

# Create a simple progress bar
1..100 | ForEach-Object {
    Write-Progress -Activity "Downloading EVK-UNK installer..." -Status "$_%" -PercentComplete $_
    Start-Sleep -Milliseconds 15
}

try {
    Invoke-WebRequest -Uri $EVKUNKURL -OutFile "$Path\$Installer"
    Write-Host "✔️ Download successful." -ForegroundColor Green
}
catch {
    Write-Host "❌ Error: Could not download the installer file. Please check your internet connection." -ForegroundColor Red
    return # Exit the script if download fails
}

# --- Installation Section ---
Write-Host "⏳ Starting the installation process..." -ForegroundColor Yellow

try {
    # Run the installer in silent mode with administrator privileges
    # /silent and /install are standard arguments for many installers
    Start-Process -FilePath "$Path\$Installer" -Args "/silent /install" -Verb RunAs -Wait
    Write-Host "✔️ Installation completed." -ForegroundColor Green
}
catch {
    Write-Host "❌ Error: Could not run the installer." -ForegroundColor Red
    return # Exit the script if installation fails
}

# --- Cleanup Section ---
Write-Host "⏳ Cleaning up the installer file..." -ForegroundColor Yellow

Remove-Item "$Path\$Installer" -ErrorAction SilentlyContinue
Write-Host "✔️ Cleanup complete." -ForegroundColor Green

Write-Host "🎉 All tasks are complete. EVK-UNK has been installed successfully." -ForegroundColor Cyan
