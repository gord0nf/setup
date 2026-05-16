Set-PSRepository PSGallery -InstallationPolicy Trusted
Set-PSResourceRepository PSGallery -Trusted

Write-Host 'Installing fonts'
& "$PSScriptRoot/../fonts/Install-Fonts.ps1"

Write-Host 'Installing icons'
Install-Module Terminal-Icons -Repository PSGallery -Scope CurrentUser
