# ========================================================
# DOWNLOAD AND EXECUTE POWERSHELL SCRIPT
# ========================================================

# 1. Config URLs and Paths
$url = "https://github.com/hiepvk/ipa/releases/download/exe/app.ps1" # <-- Replace with your script URL
$downloadPath = Join-Path $env:TEMP "downloaded_script.ps1"

Write-Host "Downloading script..." -ForegroundColor Green

try {
    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile($url, $downloadPath)
} catch {
    Write-Host "[ERROR] Download failed: $_" -ForegroundColor Red
    Start-Sleep -Seconds 3
    exit 1
}

if (Test-Path $downloadPath) {
    Write-Host "Launching script..." -ForegroundColor Yellow
    
    # Run downloaded script with Admin rights in a new process
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$downloadPath`"" -Verb RunAs
    
    # Close the current main window immediately
    exit
}
