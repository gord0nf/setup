function Test-Binary() {
  [OutputType([bool])]
  param ([string]$Binary)
  try {
    $cmd = Get-Command $Binary -ErrorAction SilentlyContinue
    return ($null -ne $cmd)
  } catch { 
    return $false 
  }
}

function Push-ToPath() {
  param(
    [string[]]$Directories,
    [switch]$AtStart
  )
  $ValidDirectories = $Directories | Where-Object { Test-Path $_ } | ForEach-Object { Resolve-Path $_ }
  if ($env:PATH[-1] -ne ';') {
    $env:PATH += ';'
  }
  if ($AtStart) {
    $env:PATH = "$($ValidDirectories -Join ';');$env:PATH"
  } else {
    $env:PATH += ($ValidDirectories -Join ';')
  }
}

function Set-EnvironmentVars() {
  param([hashtable]$EnvVariablePairs, [switch]$NotAPath)
  foreach ($name in $EnvVariablePairs.Keys) {
    $value = $EnvVariablePairs[$name]
    if (!$NotAPath -and (Test-Path $value -IsValid)) {
      if (Test-Path $value) {
        $value = Resolve-Path $value
      } else { 
        continue; 
      }
    }
    Set-Item -Path "Env:$name" -Value "$value"
  }
}

