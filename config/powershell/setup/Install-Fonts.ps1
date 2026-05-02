Install-PSResource Fonts -Scope CurrentUser
Import-Module Fonts

Get-ChildItem "$PSScriptRoot/../fonts/" | ForEach-Object {
  $fonts = Get-ChildItem "$($_.FullName)" -Filter *.ttf | Select-Object -ExpandProperty FullName
  Install-Fonts $fonts -Scope CurrentUser
}
