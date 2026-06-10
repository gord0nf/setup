Set-PSRepository PSGallery -InstallationPolicy Trusted
Set-PSResourceRepository PSGallery -Trusted

Write-Host 'Installing icons'
Install-Module Terminal-Icons -Repository PSGallery -Scope CurrentUser
