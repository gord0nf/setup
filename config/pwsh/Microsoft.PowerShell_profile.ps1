. "$PSScriptRoot/profile/utils.ps1"

# Custom env variables ----------------------------------------------------------------------------

Set-EnvironmentVars @{
  SOFTWARE = "$((Get-Item -Path $PSScriptRoot).Target)\..\.." #@gord0nf/software
  HIST     = (Get-PSReadLineOption).HistorySavePath
  SHELL    = [System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName
}

$HIST = $env:HIST
$SHELL = $env:SHELL

# PATH --------------------------------------------------------------------------------------------

# Register to path from software.csv
if (![string]::IsNullOrEmpty($env:SOFTWARE)) {
  $SoftwareCsv = "$env:SOFTWARE/software.csv"
  if (Test-Path "$SoftwareCsv") {
    $paths = @()
    Import-Csv "$SoftwareCsv" | ForEach-Object {
      $paths += $_.paths -split '\|'
    }
    Push-ToPath $paths -AtStart
  }
}

# Some edge cases to check for
Push-ToPath @(
  "$PSScriptRoot/Scripts",
  "C:\Windows\Microsoft.NET\Framework\v4.0.30319\",            # DOTNET C#
  "C:\desktopVS\VC\Tools\MSVC\14.44.35207\bin\Hostx86\x86\",   # MSVC C/C++
  "C:\eclipse",                                                # Eclipse IDE
  "$env:ProgramFiles\PowerToys", "$env:LOCALAPPDATA\PowerToys" # PowerToys
)

# Web browsers
Push-ToPath (Get-WebBrowserDirectories)

# Java JDK ----------------------------------------------------------------------------------------

function Test-JavaHome() {
  param ( [string]$Dir )
  $NotFoundDirs = "bin", "lib", "include" | Where-Object { !(Test-Path $(Join-Path "$Dir" "$_") -PathType Container) }
  if ($NotFoundDirs.Length -gt 0) {
    return $false
  }
  return Test-Path $(Join-Path "$Dir" "release") -PathType Leaf
}

if (Test-Binary java) {
  $JavaHome = Resolve-Path "$(Split-Path -Parent (Get-Command java).Path)\.."
  if (Test-JavaHome $JavaHome) {
    Set-EnvironmentVars @{
      JAVA_HOME = "$JavaHome"
    }
  }
}

# Prettier config ---------------------------------------------------------------------------------

Set-EnvironmentVars @{
  PRETTIERD_DEFAULT_CONFIG = "$env:SOFTWARE/config/nodejs/prettierrc.json"
}

# Editors -----------------------------------------------------------------------------------------

$PreferredEditors = @("code", "nvim", "vim", "notepad++", "notepad", "vi")
foreach ($editor in $PreferredEditors) {
  if (Test-Binary $editor) {
    Set-EnvironmentVars @{ 
      EDITOR = $editor
    } -NotAPath
    break
  }
}
if ($env:EDITOR -like 'code*') {
  $env:EDITOR += " --wait"
}

# Aliases -----------------------------------------------------------------------------------------

function Get-AllChildItems {
  Get-ChildItem -Force @args 
}
Set-Alias l Get-AllChildItems
if (Test-Path Alias:cd) { 
  Remove-Item alias:cd 
}
function cd {
  param([string]$path = $HOME)
  Set-Location $path
}
Set-Alias e Start-Explorer
Set-Alias clip Set-Clipboard
if (-not (Test-Binary curl)) {
  Set-Alias curl Invoke-BasicWebRequest
}
Set-Alias wget Invoke-WebRequestToFile
Set-Alias zip Compress-Archive 	
Set-Alias unzip Expand-Archive
Set-Alias ffox firefox

# Load the rest async (https://matt.kotsenas.com/posts/pwsh-profiling-async-startup/) -------------

[System.Collections.Queue]$__initQueue = @(
  {
    if ((Test-Binary oh-my-posh) -and $env:SOFTWARE) {
      $ompConfig = "custom", "takuya", "half-life" | 
        ForEach-Object { "$env:SOFTWARE/config/ohmyposh/$_.omp.json" } |
        Where-Object { Test-Path $_ } |
        Select-Object -First 1
      oh-my-posh init pwsh --config "$ompConfig" | Invoke-Expression
      [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
    }
  },
  {
    . "$PSScriptRoot/profile/console.ps1"
    [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
  }
  {
    if (Get-Module Terminal-Icons -ListAvailable) {
      Import-Module Terminal-Icons -Global
    }
  }
)

Register-EngineEvent -SourceIdentifier PowerShell.OnIdle -SupportEvent -Action {
  if ($__initQueue.Count -gt 0) {
    & $__initQueue.Dequeue()
  } else {
    Unregister-Event -SubscriptionId $EventSubscriber.SubscriptionId -Force
    Remove-Variable -Name '__initQueue' -Scope Global -Force
  }
}
