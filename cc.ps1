# 1. Ép mã hóa hiển thị Console ngay lập tức
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding  = [System.Text.Encoding]::UTF8
$OutputEncoding           = [System.Text.Encoding]::UTF8

# 2. KIỂM TRA VÀ NÂNG QUYỀN ADMIN (Tương thích cả File .ps1 lẫn IRM | IEX)
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Đang yêu cầu quyền Administrator..." -ForegroundColor Yellow
    
    $scriptPath = $PSCommandPath
    if (-not $scriptPath) { $scriptPath = $MyInvocation.MyCommand.Path }

    if ($scriptPath) {
        # Nếu là file .ps1 trên đĩa
        Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`"" -Verb RunAs
    } else {
        # Nếu chạy trực tiếp qua IRM | IEX
        # Thay link https://is.gd/taicc bằng link gốc script của bạn
        $url = "https://is.gd/taicc" 
        $powershellCmd = "[System.Text.Encoding]::UTF8; irm $url | iex"
        Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"$powershellCmd`"" -Verb RunAs
    }
    exit
}

# 3. ĐẶT KÍCH THƯỚC CỬA SỔ AN TOÀN
try {
    $rawUI = $Host.UI.RawUI
    $newWindowSize = New-Object System.Management.Automation.Host.Size(100, 25)
    $newBufferSize = New-Object System.Management.Automation.Host.Size(100, 1000)

    if ($rawUI.BufferSize.Width -gt $newWindowSize.Width) {
        $rawUI.WindowSize = $newWindowSize
        $rawUI.BufferSize = $newBufferSize
    } else {
        $rawUI.BufferSize = $newBufferSize
        $rawUI.WindowSize = $newWindowSize
    }
} catch {}

# 4. ĐẶT FONT CHỮ
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

try {
    Add-Type -TypeDefinition $code -ErrorAction SilentlyContinue
    [ConsoleFont]::SetFont("Consolas", 18)
} catch {}

# 5. TIẾN HÀNH TẢI VÀ CÀI ĐẶT
$Host.UI.RawUI.WindowTitle = "Tải Cốc Cốc"
$Path = $ENV:TEMP
$Installer = "coccoc_vi_machine.exe"
$FullPath = Join-Path $Path $Installer

# Dọn dẹp file cũ/tiến trình cũ bị kẹt nếu có
if (Test-Path $FullPath) {
    Remove-Item $FullPath -Force -ErrorAction SilentlyContinue
}

Write-Host "Đang tải xuống Cốc Cốc..." -ForegroundColor Green

try {
    $webClient = New-Object System.Net.WebClient
    $webClient.Encoding = [System.Text.Encoding]::UTF8
    $webClient.DownloadFile("https://files1.coccoc.com/browser/x64/coccoc_vi_machine.exe", $FullPath)
    Write-Host "Đã tải xuống thành công." -ForegroundColor Green
} catch {
    Write-Host "[LỖI] Tải thất bại: $_" -ForegroundColor Red
    Read-Host "Nhấn Enter để thoát..."
    exit
}

Write-Host "Đang bắt đầu quá trình cài đặt..." -ForegroundColor Green
Start-Process -FilePath $FullPath -ArgumentList "/install" -Wait

Write-Host "Cài đặt hoàn tất." -ForegroundColor Green
Write-Host "Đang dọn dẹp tệp cài đặt..." -ForegroundColor Green

Remove-Item $FullPath -ErrorAction SilentlyContinue
Write-Host "Hoàn tất." -ForegroundColor Green
Start-Sleep -Seconds 3
