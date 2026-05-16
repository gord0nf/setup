param ( [switch]$Force )

if ($IsWindows -or $env:OS -eq "Windows_NT") {
  $Fonts = (New-Object -ComObject Shell.Application).Namespace(0x14)
  $InstalledFonts = $Fonts.Items() | Select-Object -ExpandProperty Name

  $FontsToInstall = Get-ChildItem "$PSScriptRoot/../fonts" | Select-Object -ExpandProperty Name
  if (!$Force) {
    $FontsToInstall = $FontsToInstall | Where-Object {
      $fontName = $_
      $InstalledFonts.Where({ $_ -like "$fontName*" }).Count -eq 0
    }
  }

  $FontsToInstall | ForEach-Object {
    Get-ChildItem "$PSScriptRoot/../fonts/$_" -Filter *.ttf | 
      Select-Object -ExpandProperty FullName | 
      ForEach-Object { $Fonts.CopyHere($_, 0x10) }
    }
  } else {
    Install-PSResource Fonts -Scope CurrentUser
    Import-Module Fonts

    Get-ChildItem "$PSScriptRoot/../fonts/" | ForEach-Object {
      $fonts = Get-ChildItem "$($_.FullName)" -Filter *.ttf | Select-Object -ExpandProperty FullName
      Install-Fonts $fonts -Scope CurrentUser
    }
  }
