[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]'Tls,Tls11,Tls12'
Invoke-WebRequest -Uri https://github.com/hiepvk/ipa/releases/download/exe/ChromeSetup.exe -OutFile .\ChromeSetup.exe
.\ChromeSetup.exe
