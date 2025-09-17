# Script để tải xuống và cài đặt CocCoc

# Chạy với quyền quản trị viên (Run as Administrator)



$Path = $ENV:TEMP

$Installer = "coccoc_vi_machine.exe"



Write-Host "Đang tải xuống CocCoc..."



# Tải file cài đặt

Invoke-WebRequest "https://files1.coccoc.com/browser/x64/coccoc_vi_machine.exe" -OutFile "$Path\$Installer"



Write-Host "Đã tải xuống thành công."

Write-Host "Đang bắt đầu quá trình cài đặt..."



# Chạy trình cài đặt ở chế độ im lặng với quyền quản trị viên

Start-Process -FilePath "$Path\$Installer" -Args "/silent /install" -Verb RunAs -Wait



Write-Host "Cài đặt hoàn tất."

Write-Host "Đang dọn dẹp file cài đặt..."



# Xóa file cài đặt đã tải xuống

Remove-Item "$Path\$Installer" -ErrorAction SilentlyContinue



Write-Host "Hoàn tất."
