Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

Write-Host 'Installing fonts'
& "$PSScriptRoot\setup\Install-Fonts.ps1"
