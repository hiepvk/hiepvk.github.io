# ========================================================
# 1. ĐẶT KÍCH THƯỚC CỬA SỔ POWERSHELL (RỘNG x CAO)
# ========================================================
$rawUI = $Host.UI.RawUI

# Cấu hình Width = 100, Height = 25 (giảm chiều cao)
$newWindowSize = New-Object System.Management.Automation.Host.Size(100, 25)
$newBufferSize = New-Object System.Management.Automation.Host.Size(100, 1000)

# Thay đổi kích thước an toàn không bị lỗi BufferSize
if ($rawUI.BufferSize.Width -gt $newWindowSize.Width) {
    $rawUI.WindowSize = $newWindowSize
    $rawUI.BufferSize = $newBufferSize
} else {
    $rawUI.BufferSize = $newBufferSize
    $rawUI.WindowSize = $newWindowSize
}

# ========================================================
# 2. ĐẶT FONT CHỮ VÀ KÍCH THƯỚC CHỮ
# ========================================================
$code = @"
using System;
using System.Runtime.InteropServices;

public class ConsoleFont {
    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    public struct CONSOLE_FONT_INFOEX {
        public uint cbSize;
        public uint nFont;
        public short dwFontSizeX;
        public short dwFontSizeY;
        public int FontFamily;
        public int FontWeight;
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)]
        public string FaceName;
    }

    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern bool SetCurrentConsoleFontEx(IntPtr hConsoleOutput, bool bMaximumWindow, ref CONSOLE_FONT_INFOEX lpConsoleCurrentFontEx);

    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern IntPtr GetStdHandle(int nStdHandle);

    public static void SetFont(string fontName, short fontSizeY) {
        IntPtr hOutput = GetStdHandle(-11);
        CONSOLE_FONT_INFOEX info = new CONSOLE_FONT_INFOEX();
        info.cbSize = (uint)Marshal.SizeOf(info);
        info.FaceName = fontName;
        info.dwFontSizeY = fontSizeY;
        SetCurrentConsoleFontEx(hOutput, false, ref info);
    }
}
"@

Add-Type -TypeDefinition $code
[ConsoleFont]::SetFont("Consolas", 18)

# ========================================================
# 3. THIẾT LẬP MÃ HÓA CỬA SỔ
# ========================================================
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
$env:PYTHONIOENCODING = "utf-8"

$Host.UI.RawUI.WindowTitle = "Tải UltraViewer"

$Path = $ENV:TEMP

$Installer = "UltraViewer_setup_6.6_vi.exe"

Write-Host "Đang tải xuống UltraViewer..." -ForegroundColor Green

# Tải file cài đặt

Invoke-WebRequest "https://www.ultraviewer.net/vi/UltraViewer_setup_6.6_vi.exe" -OutFile "$Path\$Installer"

Write-Host "Đã tải xuống thành công." -ForegroundColor Green
Write-Host "Đang bắt đầu quá trình cài đặt..." -ForegroundColor Green

# Chạy trình cài đặt ở chế độ im lặng với quyền quản trị viên

Start-Process -FilePath "$Path\$Installer" -Args "/silent /install" -Verb RunAs -Wait

Write-Host "Cài đặt hoàn tất." -ForegroundColor Green
Write-Host "Đang dọn dẹp tệp cài đặt..." -ForegroundColor Green

# Xóa file cài đặt đã tải xuống

Remove-Item "$Path\$Installer" -ErrorAction SilentlyContinue

Write-Host "Hoàn tất." -ForegroundColor Green
