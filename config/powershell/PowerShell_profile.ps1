. "$PSScriptRoot/profile/utils.ps1"

# Custom env variables ----------------------------------------------------------------------------

$powershellPath = (Get-Command pwsh -ErrorAction SilentlyContinue).Path
if (($null -eq $powershellPath) -or !(Test-Path $powershellPath))
{
  $powershellPath = (Get-Command powershell).Path
}

Set-EnvironmentVars @{
  SOFTWARE = "$PSScriptRoot\..\.." #@gord0nf/software
  REPOS    = "$HOME\dev\repos" # something i like
  HIST     = (Get-PSReadLineOption).HistorySavePath
  SHELL    = "$powershellPath"
}

[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
  'PSAvoidAssignmentToAutomaticVariable', '', Justification='Overwriting $PROFILE')]
$PROFILE = $PSCommandPath 
$HIST = $env:HIST
$SHELL = $env:SHELL

# PATH --------------------------------------------------------------------------------------------

# Register to path from software.csv
if (![string]::IsNullOrEmpty($env:SOFTWARE))
{
  $SoftwareCsv = "$env:SOFTWARE/software.csv"
  if (Test-Path "$SoftwareCsv")
  {
    $paths = @()
    Import-Csv "$SoftwareCsv" | ForEach-Object {
      $paths += $_.paths -split '\|'
    }
    Push-ToPath $paths -AtStart
  }
}

# Some edge cases to check for
Push-ToPath @(
  "C:\Windows\Microsoft.NET\Framework\v4.0.30319\",            # DOTNET C#
  "C:\desktopVS\VC\Tools\MSVC\14.44.35207\bin\Hostx86\x86\",   # MSVC C/C++
  "C:\eclipse",                                                # Eclipse IDE
  "$env:ProgramFiles\PowerToys", "$env:LOCALAPPDATA\PowerToys" # PowerToys
)

# Web browsers
Push-ToPath (Get-WebBrowserDirectories)

# Java JDK ----------------------------------------------------------------------------------------

function Test-JavaHome()
{
  param ( [string]$Dir )
  $NotFoundDirs = "bin", "lib", "include" | Where-Object { !(Test-Path $(Join-Path "$Dir" "$_") -PathType Container) }
  if ($NotFoundDirs.Length -gt 0)
  {
    return $false
  }
  return Test-Path $(Join-Path "$Dir" "release") -PathType Leaf
}

if (Test-Binary java)
{
  $JavaHome = Resolve-Path "$(Split-Path -Parent (Get-Command java).Path)\.."
  if (Test-JavaHome $JavaHome)
  {
    Set-EnvironmentVars @{
      JAVA_HOME = "$JavaHome"
    }
  }
}

# Editors -----------------------------------------------------------------------------------------

$PreferredEditors = @("code", "nvim", "vim", "notepad++", "notepad", "vi")
foreach ($editor in $PreferredEditors)
{
  if (Test-Binary $editor)
  {
    Set-EnvironmentVars @{ 
      EDITOR = $editor
    } -NotAPath
    break
  }
}
if ($env:EDITOR -like 'code*')
{
  $env:EDITOR += " --wait"
}

# The other important stuff -----------------------------------------------------------------------

. "$PSScriptRoot/profile/aliases.ps1"
. "$PSScriptRoot/profile/prompt.ps1"
. "$PSScriptRoot/profile/style.ps1"
