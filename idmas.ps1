# Check massgrave.dev for more details

write-host
Write-Host -ForegroundColor Green "https://hiepvk.github.io"
write-host

$troubleshoot = 'https://massgrave.dev/troubleshoot'
if ($ExecutionContext.SessionState.LanguageMode.value__ -ne 0) {
    $ExecutionContext.SessionState.LanguageMode
    Write-Host "Windows PowerShell is not running in Full Language Mode."
    Write-Host "Help - https://gravesoft.dev/fix_powershell" -ForegroundColor White -BackgroundColor Blue
    return
}

function Check3rdAV {
    $avList = Get-CimInstance -Namespace root\SecurityCenter2 -Class AntiVirusProduct | Where-Object { $_.displayName -notlike '*windows*' } | Select-Object -ExpandProperty displayName
    if ($avList) {
        Write-Host '3rd party Antivirus might be blocking the script - ' -ForegroundColor White -BackgroundColor Blue -NoNewline
        Write-Host " $($avList -join ', ')" -ForegroundColor DarkRed -BackgroundColor White
    }
}

function CheckFile { 
    param ([string]$FilePath) 
    if (-not (Test-Path $FilePath)) { 
        Check3rdAV
        Write-Host "Failed to create IDM-Activation-Script file in temp folder, aborting!"
        Write-Host "Help - $troubleshoot" -ForegroundColor White -BackgroundColor Blue
        throw 
    } 
}

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$URLs = @(
    'https://raw.githubusercontent.com/hiepvk/IDM-Activation-Script/refs/heads/main/IASL.cmd'
)

foreach ($URL in $URLs | Sort-Object { Get-Random }) {
    try { $response = Invoke-WebRequest -Uri $URL -UseBasicParsing; break } catch {}
}

if (-not $response) {
    Check3rdAV
    Write-Host "Failed to retrieve MAS from any of the available repositories, aborting!"
    Write-Host "Help - $troubleshoot" -ForegroundColor White -BackgroundColor Blue
    return
}



# Check for AutoRun registry which may create issues with CMD
$paths = "HKCU:\SOFTWARE\Microsoft\Command Processor", "HKLM:\SOFTWARE\Microsoft\Command Processor"
foreach ($path in $paths) { 
    if (Get-ItemProperty -Path $path -Name "Autorun" -ErrorAction SilentlyContinue) { 
        Write-Warning "Autorun registry found, CMD may crash! `nManually copy-paste the below command to fix...`nRemove-ItemProperty -Path '$path' -Name 'Autorun'"
    } 
}

$rand = [Guid]::NewGuid().Guid
$isAdmin = [bool]([Security.Principal.WindowsIdentity]::GetCurrent().Groups -match 'S-1-5-32-544')
$FilePath = if ($isAdmin) { "$env:SystemRoot\Temp\IASL.cmd" } else { "$env:USERPROFILE\AppData\Local\Temp\IASL.cmd" }
Set-Content -Path $FilePath -Value "@::: $rand `r`n$response"
CheckFile $FilePath

$env:ComSpec = "$env:SystemRoot\system32\cmd.exe"
$chkcmd = & $env:ComSpec /c "echo CMD is working"
if ($chkcmd -notcontains "CMD is working") {
    Write-Warning "cmd.exe is not working.`nReport this issue at $troubleshoot"
}
saps -FilePath $env:ComSpec -ArgumentList "/c """"$FilePath"" $args""" -Wait
CheckFile $FilePath

$FilePaths = @("$env:SystemRoot\Temp\IASL.cmd", "$env:USERPROFILE\AppData\Local\Temp\IASL.cmd")
foreach ($FilePath in $FilePaths) { Get-Item $FilePath | Remove-Item }

