$env:PATH = $env:PATH -replace ';$' # remove trailing ;

function Test-Binary_pf() {
  [OutputType([bool])]
  param ([string]$Binary)
  return Get-Command $Binary -ErrorAction SilentlyContinue
}

function Push-ToPath_pf() {
  param(
    [string[]]$Directories,
    [switch]$AtStart
  )
  $dirs = $Directories | Where-Object { Test-Path $_ } | ForEach-Object { Convert-Path $_ }
  $dirs = $dirs -join ';'
  if ($AtStart) {
    $env:PATH = "$dirs;$env:PATH"
  } else {
    $env:PATH += ";$dirs"
  }
}

function Set-EnvVars_pf() {
  param([hashtable]$EnvVariablePairs, [switch]$NotAPath)
  foreach ($name in $EnvVariablePairs.Keys) {
    $value = $EnvVariablePairs[$name]
    if (!$NotAPath -and (Test-Path $value)) {
      $value = Convert-Path $value
    } elseif (!$NotAPath) {
      continue; 
    }
    Set-Item -Path "Env:$name" -Value "$value"
  }
}

# Env vars ----------------------------------------------------------------------------------------

Set-EnvVars_pf @{
  SOFTWARE = "$((Get-Item -Path $PSScriptRoot).Target)\..\.." #@gord0nf/software
  HIST     = (Get-PSReadLineOption).HistorySavePath
  SHELL    = [System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName
}
$HIST = $env:HIST
$SHELL = $env:SHELL

# Path --------------------------------------------------------------------------------------------

# Register to path from software.csv
Push-ToPath_pf -AtStart (
  Import-Csv "$env:SOFTWARE/software.csv" -ErrorAction SilentlyContinue |
    ForEach-Object { $_.paths -split '\|'}
)

# Some edge cases to check for
Push-ToPath_pf @(
  "$PSScriptRoot/Scripts",
  "C:\Windows\Microsoft.NET\Framework\v4.0.30319\",            # DOTNET C#
  "C:\desktopVS\VC\Tools\MSVC\14.44.35207\bin\Hostx86\x86\",   # MSVC C/C++
  "C:\eclipse",                                                # Eclipse IDE
  "$env:ProgramFiles\PowerToys", "$env:LOCALAPPDATA\PowerToys" # PowerToys
)

# Web browsers
Push-ToPath_pf (Get-WebBrowserDirectories)

# Misc software -----------------------------------------------------------------------------------

Set-EnvVars_pf @{ 
  EDITOR = "code", "nvim", "vim", "notepad++", "notepad", "vi" | 
    Where-Object { Test-Binary_pf $_ } |
    Select-Object -First 1
} -NotAPath

if (Test-Binary_pf java) {
  Set-EnvVars_pf @{ JAVA_HOME = "$(Split-Path (Get-Command java).Path)/.." }
}
Set-EnvVars_pf @{ PRETTIERD_DEFAULT_CONFIG = "$env:SOFTWARE/config/nodejs/prettierrc.json" }

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
if (-not (Test-Binary_pf curl)) {
  Set-Alias curl Invoke-BasicWebRequest
}
Set-Alias wget Invoke-WebRequestToFile
Set-Alias zip Compress-Archive 	
Set-Alias unzip Expand-Archive
Set-Alias ffox firefox

# Load the rest async (https://matt.kotsenas.com/posts/pwsh-profiling-async-startup/) -------------

[System.Collections.Queue]$__initQueue = @(

  # ohmyposh ----------------
  {
    if ((Test-Binary_pf oh-my-posh) -and $env:SOFTWARE) {
      $ompConfig = "custom", "takuya", "half-life" | 
        ForEach-Object { "$env:SOFTWARE/config/ohmyposh/$_.omp.json" } |
        Where-Object { Test-Path $_ } |
        Select-Object -First 1
      oh-my-posh init pwsh --config "$ompConfig" | Invoke-Expression
      [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
    }
  },

  # PSReadLine --------------
  {
    if (Get-Module -ListAvailable -Name PSReadLine) {
      $PSReadLineOptions = @{
        EditMode = "Vi"
        HistoryNoDuplicates = $true
        HistorySearchCursorMovesToEnd = $true
        BellStyle = "None"
        PredictionSource = "History"
        MaximumHistoryCount = 10000

        # History filtering
        AddToHistoryHandler = {
          param([string]$line)
          $sensitive = "password|asplaintext|token|key|secret"
          return ($line -notmatch $sensitive)
        }
      }

      Set-PSReadLineOption @PSReadLineOptions

      Set-PSReadLineKeyHandler -Chord "Ctrl+n" -Function NextHistory
      Set-PSReadLineKeyHandler -Chord "Ctrl+p" -Function PreviousHistory
      Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
      Set-PSReadLineKeyHandler -Chord "Ctrl+ " -Function SwitchPredictionView
      Set-PSReadLineKeyHandler -Chord 'Ctrl+Backspace' -Function BackwardKillWord
      Set-PSReadLineKeyHandler -Chord 'Ctrl+w' -Function BackwardKillWord
    }
  }

  # Terminal-Icons ----------
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

    # cleanup profile vars and functions
    Remove-Variable -Name '__initQueue' -Scope Global -Force
    Remove-Item Function:\*_pf
  }
}

