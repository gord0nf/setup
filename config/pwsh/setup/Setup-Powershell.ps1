Set-PSRepository PSGallery -InstallationPolicy Trusted
Set-PSResourceRepository PSGallery -Trusted

Write-Host 'Installing fonts'
& "$PSScriptRoot/Install-Fonts.ps1"

Write-Host 'Installing icons'
& "$PSScriptRoot/Install-Icons.ps1"
