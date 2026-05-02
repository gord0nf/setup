Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

Install-Module PowershellGet -Scope CurrentUser -AllowClobber -Force
Install-Module Microsoft.PowerShell.PSResourceGet -Scope CurrentUser -AllowClobber -Force
Set-PSResourceRepository PSGallery -Trusted

Install-Module PSReadLine -Repository PSGallery -Scope CurrentUser -Force

Write-Host 'Installing fonts'
& "$PSScriptRoot\setup\Install-Fonts.ps1"
