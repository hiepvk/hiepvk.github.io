# 1. Ép mã hóa hiển thị UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding  = [System.Text.Encoding]::UTF8
$OutputEncoding           = [System.Text.Encoding]::UTF8

# ========================================================
# 2. KÍCH HOẠT QUYỀN ADMINISTRATOR TỰ ĐỘNG (XỬ LÝ DÀNH CHO IRM | IEX)
# ========================================================
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$isAdministrator = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdministrator) {
    Write-Host "Đang yêu cầu quyền Administrator..." -ForegroundColor Yellow
    
    $scriptPath = $PSCommandPath
    if (-not $scriptPath) { $scriptPath = $MyInvocation.MyCommand.Path }

    if ($scriptPath) {
        # Chạy từ file .ps1 dưới đĩa
        Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`"" -Verb RunAs
    } else {
        # Chạy qua stream IRM | IEX
        # !!! THAY LINK GỐC GITHUB RAW CỦA BẠN VÀO DÒNG DƯỚI !!!
        $remoteScriptUrl = "https://raw.githubusercontent.com/username/repo/main/script.ps1" 
        
        $cmd = "[System.Text.Encoding]::UTF8; irm $remoteScriptUrl | iex"
        Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"$cmd`"" -Verb RunAs
    }
    exit
}

if ($PSScriptRoot) { Set-Location -Path $PSScriptRoot }

# ========================================================
# 3. ĐẶT KÍCH THƯỚC CỬA SỔ POWERSHELL
# ========================================================
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

# ========================================================
# 4. ĐẶT FONT CHỮ CONSOLAS
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

try {
    Add-Type -TypeDefinition $code -ErrorAction SilentlyContinue
    [ConsoleFont]::SetFont("Consolas", 18)
} catch {}

$Host.UI.RawUI.WindowTitle = "Trình Cài Đặt Phần Mềm Tự Động"

# Danh sách ứng dụng
$appList = @(
    @{
        ID          = 1
        Name        = "Google Chrome"
        FileName    = "ChromeSetup.exe"
        Args        = "/silent /install"
        Url         = "https://dl.google.com/chrome/install/latest/chrome_installer.exe"
        IsZip       = $false
    },
    @{
        ID          = 2
        Name        = "Cốc Cốc"
        FileName    = "CoccocSetup.exe"
        Args        = "/silent"
        Url         = "https://files.coccoc.com/browser/coccoc_setup.exe"
        IsZip       = $false
    },
    @{
        ID          = 3
        Name        = "7-Zip"
        FileName    = "7zip.exe"
        Args        = "/S"
        Url         = "https://www.7-zip.org/a/7z2301-x64.exe"
        IsZip       = $false
    },
    @{
        ID          = 4
        Name        = "Unikey"
        FileName    = "unikey.zip"
        ExeInside   = "UniKeyNT.exe"
        Args        = ""
        Url         = "https://www.unikey.org/assets/files/unikey43RC3-200929-win64.zip"
        IsZip       = $true
    },
    @{
        ID          = 5
        Name        = "VLC Media Player"
        FileName    = "vlc-setup.exe"
        Args        = "/L=1066 /S"
        Url         = "https://get.videolan.org/vlc/last/win64/vlc-3.0.20-win64.exe"
        IsZip       = $false
    }
)

function Show-Header {
    Clear-Host
    Write-Host "========================================================" -ForegroundColor Cyan
    Write-Host "      TRÌNH CÀI ĐẶT PHẦN MỀM TỰ ĐỘNG (MULTI-INSTALLER)  " -ForegroundColor Yellow
    Write-Host "========================================================" -ForegroundColor Cyan
    Write-Host ""
}

$setupDir = Join-Path $env:TEMP "SoftwareInstaller"
if (-not (Test-Path $setupDir)) {
    New-Item -ItemType Directory -Path $setupDir -Force | Out-Null
}

while ($true) {
    Show-Header
    Write-Host "Danh sách phần mềm khả dụng:" -ForegroundColor Green
    Write-Host ""

    foreach ($app in $appList) {
        $localFile = Join-Path $setupDir $app.FileName
        $status = if (Test-Path $localFile) { "[Đã có file cài]" } else { "[Chưa tải]" }
        Write-Host ("  [{0}] {1,-20} {2}" -f $app.ID, $app.Name, $status) -ForegroundColor White
    }

    Write-Host ""
    Write-Host "  [A] Cài đặt TẤT CẢ phần mềm trong danh sách" -ForegroundColor Yellow
    Write-Host "  [Q] Thoát chương trình" -ForegroundColor Red
    Write-Host ""
    
    $inputChoice = Read-Host "Nhập lựa chọn của bạn (Ví dụ chọn nhiều: 1,3,5 hoặc 1-3 hoặc A)"
    
    if ($inputChoice -eq 'Q' -or $inputChoice -eq 'q') {
        Write-Host "Đang thoát chương trình..." -ForegroundColor Gray
        break
    }

    $selectedApps = @()

    if ($inputChoice -eq 'A' -or $inputChoice -eq 'a') {
        $selectedApps = $appList
    } else {
        $choices = $inputChoice -split ','
        foreach ($c in $choices) {
            $c = $c.Trim()
            if ($c -match '^(\d+)-(\d+)$') {
                $num1 = [int]$matches[1]
                $num2 = [int]$matches[2]
                $start = [Math]::Min($num1, $num2)
                $end = [Math]::Max($num1, $num2)
                $selectedApps += $appList | Where-Object { $_.ID -ge $start -and $_.ID -le $end }
            } elseif ($c -match '^\d+$') {
                $id = [int]$c
                $selectedApps += $appList | Where-Object { $_.ID -eq $id }
            }
        }
    }

    $selectedApps = $selectedApps | Select-Object -Unique

    if ($selectedApps.Count -eq 0) {
        Write-Host "[!] Lựa chọn không hợp lệ, vui lòng thử lại." -ForegroundColor Red
        Start-Sleep -Seconds 2
        continue
    }

    Show-Header
    Write-Host "Các phần mềm đã chọn để cài đặt:" -ForegroundColor Green
    foreach ($app in $selectedApps) {
        Write-Host (" - " + $app.Name) -ForegroundColor Cyan
    }
    Write-Host ""

    $confirm = Read-Host "Xác nhận bắt đầu tải và cài đặt? (Y/N)"
    if ($confirm -ne 'Y' -and $confirm -ne 'y') {
        continue
    }

    Write-Host ""
    Write-Host "--------------------------------------------------------" -ForegroundColor Gray

    foreach ($app in $selectedApps) {
        $filePath = Join-Path $setupDir $app.FileName
        
        # 1. Tải file nếu chưa có sẵn
        if (-not (Test-Path $filePath)) {
            Write-Host ("[+] Đang tải " + $app.Name + "...") -ForegroundColor Yellow
            try {
                $webClient = New-Object System.Net.WebClient
                $webClient.Encoding = [System.Text.Encoding]::UTF8
                $webClient.DownloadFile($app.Url, $filePath)
                Write-Host ("    -> Tải thành công: " + $app.FileName) -ForegroundColor Green
            } catch {
                Write-Host ("    [LỖI] Không thể tải " + $app.Name + ": " + $_.Exception.Message) -ForegroundColor Red
                continue
            }
        } else {
            Write-Host ("[i] Đã có file cài " + $app.Name + " trong máy.") -ForegroundColor Gray
        }

        # 2. Xử lý cài đặt
        Write-Host ("[+] Đang tiến hành cài đặt " + $app.Name + "...") -ForegroundColor Yellow
        try {
            if ($app.IsZip) {
                $extractPath = Join-Path $setupDir ($app.Name -replace '\s+','')
                Expand-Archive -Path $filePath -DestinationPath $extractPath -Force
                $runPath = Join-Path $extractPath $app.ExeInside
                
                Start-Process -FilePath $runPath -ArgumentList $app.Args
                Write-Host ("    -> Giải nén và khởi chạy thành công: " + $app.Name) -ForegroundColor Green
            } else {
                if ($app.Args) {
                    $process = Start-Process -FilePath $filePath -ArgumentList $app.Args -Wait -PassThru
                } else {
                    $process = Start-Process -FilePath $filePath -Wait -PassThru
                }

                if ($process.ExitCode -eq 0 -or $process.ExitCode -eq $null) {
                    Write-Host ("    -> Cài đặt hoàn tất: " + $app.Name) -ForegroundColor Green
                } else {
                    Write-Host ("    [!] Cài đặt hoàn tất với mã thoát: " + $process.ExitCode) -ForegroundColor DarkYellow
                }
            }
        } catch {
            Write-Host ("    [LỖI] Cài đặt thất bại " + $app.Name + ": " + $_.Exception.Message) -ForegroundColor Red
        }

        Write-Host ""
    }

    Write-Host "========================================================" -ForegroundColor Green
    Write-Host "          HOÀN THÀNH TẤT CẢ TIẾN TRÌNH!" -ForegroundColor Green
    Write-Host "========================================================" -ForegroundColor Green
    Write-Host ""
    
    Read-Host "Nhấn Enter để quay lại menu..."
}