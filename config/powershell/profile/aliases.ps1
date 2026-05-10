# Navigation & FS ---------------------------------------------------------------------------------

function Get-AllChildItems()
{
  Get-ChildItem -Force @args 
} 	
function Start-Explorer()
{ 
  param ( [string]$Path = '.' )
  Start-Process $Path
}
function Get-DirectorySize()
{
  param ( [string]$Path )
  return (Get-ChildItem -Path "$Path" -Recurse -File -Force | Measure-Object -Property Length -Sum).Sum
}
function New-Junction()
{
  param ( [string]$Path, [string]$Junction )
  $Path = Resolve-Path "$Path"
  $Junction = [System.IO.Path]::GetFullPath((Join-Path $pwd.Path $Junction))
  cmd.exe /C "mklink /J ""$Junction"" ""$Path"""
}

Set-Alias l Get-AllChildItems
if (Test-Path Alias:cd)
{ 
  Remove-Item alias:cd 
}
function cd
{
  param([string]$path = $HOME)
  Set-Location $path
}
Set-Alias e Start-Explorer

# Network calls -----------------------------------------------------------------------------------

function Invoke-BasicWebRequest()
{ 
  $save = $ProgressPreference
  $ProgressPreference = 'SilentlyContinue' 
  Invoke-WebRequest -UseBasicParsing @args
  $ProgressPreference = $save
}
function Invoke-WebRequestToFile()
{
  param ( [string]$Uri )
  Invoke-BasicWebRequest -Uri "$Uri" -O "$PWD\$([System.IO.Path]::GetFileName($Uri))" @args
}
	
Set-Alias -Option AllScope curl Invoke-BasicWebRequest
Set-Alias -Option AllScope wget Invoke-WebRequestToFile

# DLLs and archives -------------------------------------------------------------------------------

function Expand-Msi()
{ 	
  param ( [string]$Path, [string]$Destination ) 	
  $msiFull = (Get-Item $Path).FullName 	
  $destFull = (Get-Item $Destination).FullName 	
  cmd.exe /c "msiexec /a ""$msiFull"" /qb TARGETDIR=""$destFull""" 	
} 	
function Expand-Cab()
{ 	
  param( [string]$Path, [string]$Destination ) 	
  expand.exe -F:* "$Path" "$Destination" 	
} 	
function Get-MissingDllDeps
{
  param ( [string[]]$dlls)
  $dlls | ForEach-Object { 
    cmd /c "dumpbin -dependents $(Split-Path -Leaf $_)" | 
      Where-Object { $_.Contains(".dll") -and ! $_.Contains("Dump of file") } |
      ForEach-Object { $_.Trim() } 
    } |
      Select-Object -Unique |
      Where-Object { !(Test-Path $_) -and !(Get-Command -ErrorAction SilentlyContinue $_) }
}

Set-Alias zip Compress-Archive 	
Set-Alias unzip Expand-Archive

# Misc programs -----------------------------------------------------------------------------------

Set-Alias ffox firefox

# Change wallpaper --------------------------------------------------------------------------------

# https://stackoverflow.com/a/9440226
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
using Microsoft.Win32;
namespace Wallpaper
{
   public enum Style : int
   {
       Tile, Center, Stretch, NoChange
   }
   public class Setter {
      public const int SetDesktopWallpaper = 20;
      public const int UpdateIniFile = 0x01;
      public const int SendWinIniChange = 0x02;
      [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
      private static extern int SystemParametersInfo (int uAction, int uParam, string lpvParam, int fuWinIni);
      public static void SetWallpaper ( string path, Wallpaper.Style style ) {
         SystemParametersInfo( SetDesktopWallpaper, 0, path, UpdateIniFile | SendWinIniChange );
         RegistryKey key = Registry.CurrentUser.OpenSubKey("Control Panel\\Desktop", true);
         switch( style )
         {
            case Style.Stretch :
               key.SetValue(@"WallpaperStyle", "2") ; 
               key.SetValue(@"TileWallpaper", "0") ;
               break;
            case Style.Center :
               key.SetValue(@"WallpaperStyle", "1") ; 
               key.SetValue(@"TileWallpaper", "0") ; 
               break;
            case Style.Tile :
               key.SetValue(@"WallpaperStyle", "1") ; 
               key.SetValue(@"TileWallpaper", "1") ;
               break;
            case Style.NoChange :
               break;
         }
         key.Close();
      }
   }
}
"@
$ThemeDir = "$env:APPDATA\Microsoft\Windows\Themes"
$WallpaperThemes = Get-ChildItem "$ThemeDir\wallpapers" -Directory | Select-Object -ExpandProperty Name

function Set-Wallpaper()
{
  param ( [string]$Path )
  Remove-Item "$ThemeDir\TranscodedWallpaper" -ErrorAction SilentlyContinue
  Copy-Item "$Path" "$ThemeDir\TranscodedWallpaper"
  [Wallpaper.Setter]::SetWallpaper("$(Resolve-Path "$Path")", 1) # Refresh wallpaper
}

function Set-RandomWallpaper()
{
  param (
    [ValidateScript({$_ -in $WallpaperThemes })]
    [string]$Theme = ($WallpaperThemes | Get-Random)
  )
  Set-Wallpaper "$(Get-ChildItem "$ThemeDir\wallpapers\$Theme" | Select-Object -ExpandProperty FullName | Get-Random)"
}

