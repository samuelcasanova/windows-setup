Read-Host "Press enter to open a browser with the Notepad++ downloads page. Download the latest version and copy the location"
Start-Process "https://notepad-plus-plus.org/downloads/"
$installer = Read-Host "Enter the location of the Notepad++ installer"

Start-Process -FilePath "$installer" -ArgumentList "/S" -verb runAs -Wait -WindowStyle Maximized
