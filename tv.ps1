cd ~\AppData\Local\Temp
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]'Tls,Tls11,Tls12'
Invoke-WebRequest -Uri https://github.com/hiepvk/ipa/releases/download/exe/EVK-UNK-Setup.exe -OutFile .\EVK-UNK-Setup.exe
.\EVK-UNK-Setup.exe
