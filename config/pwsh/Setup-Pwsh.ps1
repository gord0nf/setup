Set-PSRepository PSGallery -InstallationPolicy Trusted
Set-PSResourceRepository PSGallery -Trusted

Write-Host 'Installing fonts'
& "$PSScriptRoot/setup/Install-Fonts.ps1"

Write-Host 'Installing icons'
& "$PSScriptRoot/setup/Install-Icons.ps1"
