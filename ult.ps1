cd ~\AppData\Local\Temp
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]'Tls,Tls11,Tls12'
Invoke-WebRequest -Uri https://www.ultraviewer.net/vi/UltraViewer_setup_6.6_vi.exe -OutFile .\UltraViewer_setup_6.6_vi.exe
.\UltraViewer_setup_6.6_vi.exe
