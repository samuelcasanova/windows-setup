Read-Host "Press enter to download Chrome browser for Windows to the Downloads folder"
Start-Process "https://www.google.com/chrome/?system=true&standalone=1&platform=win64"
Read-Host "Once downloaded press Enter to start the silent install"
cd ~\Downloads
ChromeStandaloneSetup64 /silent /install
Read-Host "Once installed open Chrome and login in this order: Personal Gmail (default), Immfly and scrtestingpurposes. Google as default search engine, Turn on ad privacy. Turn on Windows Hello protection for passwords."
