# Script để tải xuống và cài đặt UltraViewer

# Chạy với quyền quản trị viên (Run as Administrator)

$Path = $ENV:TEMP

$Installer = "UltraViewer_setup_6.6_vi.exe"

Write-Host "Dang tai xuong UltraViewer..."

# Tải file cài đặt

Invoke-WebRequest "https://www.ultraviewer.net/vi/UltraViewer_setup_6.6_vi.exe" -OutFile "$Path\$Installer"

Write-Host "Da tai xuong thanh cong."
Write-Host "Dang bat dau qua trinh cai dat..."

# Chạy trình cài đặt ở chế độ im lặng với quyền quản trị viên

Start-Process -FilePath "$Path\$Installer" -Args "/silent /install" -Verb RunAs -Wait

Write-Host "Cai dat hoan tat."
Write-Host "Dang don dep file cai dat..."

# Xóa file cài đặt đã tải xuống

Remove-Item "$Path\$Installer" -ErrorAction SilentlyContinue

Write-Host "Hoan tat."
