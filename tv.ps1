# Bắt buộc PowerShell sử dụng bảng mã UTF-8
# Điều này giúp hiển thị các ký tự đặc biệt và tiếng Việt có dấu đúng cách
$OutputEncoding = [System.Text.UTF8Encoding]::new()
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

# --- Phần còn lại của script ---

# Script để tải xuống và cài đặt EVK-UNK
# Chạy với quyền quản trị viên (Run as Administrator)

$Path = $ENV:TEMP
$Installer = "EVK-UNK-Setup.exe"

# --- Phần Tải xuống ---
Write-Host "⏳ Đang tải xuống EVK-UNK..." -ForegroundColor Yellow

# Tạo thanh tiến trình giả lập
1..100 | ForEach-Object {
    Write-Progress -Activity "Đang tải file cài đặt..." -Status "$_%" -PercentComplete $_
    Start-Sleep -Milliseconds 15
}

try {
    Invoke-WebRequest "https://github.com/hiepvk/ipa/releases/download/exe/EVK-UNK-Setup.exe" -OutFile "$Path\$Installer"
    Write-Host "✔️ Đã tải xuống thành công." -ForegroundColor Green
}
catch {
    Write-Host "❌ Lỗi: Không thể tải xuống file cài đặt." -ForegroundColor Red
    return # Dừng script nếu có lỗi
}

# --- Phần Cài đặt ---
Write-Host "⏳ Đang bắt đầu quá trình cài đặt..." -ForegroundColor Yellow

try {
    Start-Process -FilePath "$Path\$Installer" -Args "/silent /install" -Verb RunAs -Wait
    Write-Host "✔️ Cài đặt hoàn tất." -ForegroundColor Green
}
catch {
    Write-Host "❌ Lỗi: Không thể chạy trình cài đặt." -ForegroundColor Red
    return # Dừng script nếu có lỗi
}

# --- Phần Dọn dẹp ---
Write-Host "⏳ Đang dọn dẹp file cài đặt..." -ForegroundColor Yellow

Remove-Item "$Path\$Installer" -ErrorAction SilentlyContinue
Write-Host "✔️ Đã dọn dẹp xong." -ForegroundColor Green

Write-Host "🎉 Hoàn tất." -ForegroundColor Cyan
