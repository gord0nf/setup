. "$PSScriptRoot/profile/utils.ps1"

# Env vars ----------------------------------------------------------------------------------------

Set-EnvironmentVars @{
  SOFTWARE = "$((Get-Item -Path $PSScriptRoot).Target)\..\.." #@gord0nf/software
  HIST     = (Get-PSReadLineOption).HistorySavePath
  SHELL    = [System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName
}
$HIST = $env:HIST
$SHELL = $env:SHELL

# Path --------------------------------------------------------------------------------------------

# Register to path from software.csv
Push-ToPath -AtStart (
  Import-Csv "$env:SOFTWARE/software.csv" -ErrorAction SilentlyContinue |
    ForEach-Object { $_.paths -split '\|'}
)

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

# Misc software -----------------------------------------------------------------------------------

Set-EnvironmentVars @{ 
  EDITOR = "code", "nvim", "vim", "notepad++", "notepad", "vi" | 
    Where-Object { Test-Binary $_ } |
    Select-Object -First 1
} -NotAPath

if (Test-Binary java) {
  Set-EnvironmentVars @{ JAVA_HOME = "$(Split-Path (Get-Command java).Path)/.." }
}
Set-EnvironmentVars @{ PRETTIERD_DEFAULT_CONFIG = "$env:SOFTWARE/config/nodejs/prettierrc.json" }

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
