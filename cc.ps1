cd ~/
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]'Tls,Tls11,Tls12'
Invoke-WebRequest -Uri https://files1.coccoc.com/browser/x64/coccoc_vi_machine.exe -OutFile .\coccoc_vi_machine.exe
.\coccoc_vi_machine.exe
