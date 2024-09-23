Read-Host "Press enter to go to Github Personal Access Tokens and create a new one to access the secondbrain repo"
Start-Process "https://github.com/settings/tokens?type=beta"
Read-Host "Copy the Personal Access Token and paste it when the CLI asks you for the password, close any Credential Manager window that may open"
cd ~/git/
git clone https://samuelcasanova@github.com/samuelcasanova/secondbrain.git

