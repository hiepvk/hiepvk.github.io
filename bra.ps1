cd ~\AppData\Local\Temp
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]'Tls,Tls11,Tls12'
Invoke-WebRequest -Uri https://referrals.brave.com/latest/BraveBrowserSetup-BRV010.exe -OutFile .\BraveBrowserSetup-BRV010.exe
.\BraveBrowserSetup-BRV010.exe
