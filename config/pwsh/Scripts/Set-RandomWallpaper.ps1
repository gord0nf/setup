if (-not $IsWindows) {
  throw "This script is only supported on Windows."
}

$WallpapersDir = if ("$env:WALLPAPERS") {
  "$env:WALLPAPERS"
} else {
  "$env:APPDATA\wallpapers"
}

param (
  [ValidateScript({
      $WallpaperThemes = Get-ChildItem "$WallpapersDir" -Directory | Select-Object -ExpandProperty Name
      $_ -in $WallpaperThemes
    })]
  [string]$Theme = ($WallpaperThemes | Get-Random)
)

Set-Wallpaper "$(Get-ChildItem "$WallpapersDir\$Theme" | Select-Object -ExpandProperty FullName | Get-Random)"

