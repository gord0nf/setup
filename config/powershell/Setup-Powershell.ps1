Install-Module PowershellGet -Scope CurrentUser -AllowClobber -Force
Install-Module Microsoft.PowerShell.PSResourceGet -Scope CurrentUser -AllowClobber -Force
Set-PSRepository PSGallery -InstallationPolicy Trusted
Set-PSResourceRepository PSGallery -Trusted

Install-Module PSReadLine -Repository PSGallery -Scope CurrentUser -Force

Write-Host 'Installing fonts'
& "$PSScriptRoot\setup\Install-Fonts.ps1"
