if (-not $IsWindows)
{
  throw "This script is only supported on Windows."
}
$ThemeDir = "$env:APPDATA\Microsoft\Windows\Themes"

param (
  [ValidateScript({
      $WallpaperThemes = Get-ChildItem "$ThemeDir\wallpapers" -Directory | Select-Object -ExpandProperty Name
      $_ -in $WallpaperThemes
    })]
  [string]$Theme = ($WallpaperThemes | Get-Random)
)

Set-Wallpaper "$(Get-ChildItem "$ThemeDir\wallpapers\$Theme" | Select-Object -ExpandProperty FullName | Get-Random)"

