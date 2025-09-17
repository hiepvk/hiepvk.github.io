# Script để tải xuống và cài đặt CocCoc
# Chạy với quyền quản trị viên (Run as Administrator)

$Path = $ENV:TEMP
$Installer = "coccoc_vi_machine.exe"

Write-Host "Dang tai xuong CocCoc..."

# Tải file cài đặt
Invoke-WebRequest "https://files1.coccoc.com/browser/x64/coccoc_vi_machine.exe" -OutFile "$Path\$Installer"

Write-Host "Da tai xuong thanh cong."
Write-Host "Dang bat dau qua trinh cai dat..."

# Run the installer in silent mode with administrator privileges
Start-Process -FilePath "$Path\$Installer" -Args "/silent /install" -Verb RunAs -Wait

Write-Host "Cai dat hoan tat."
Write-Host "Dang don dep file cai dat..."

# Delete the downloaded installer file
Remove-Item "$Path\$Installer" -ErrorAction SilentlyContinue

Write-Host "Hoan tat."
