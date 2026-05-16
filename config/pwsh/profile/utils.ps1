function Test-Binary()
{
  [OutputType([bool])]
  param ([string]$Binary)
  try
  {
    $cmd = Get-Command $Binary -ErrorAction SilentlyContinue
    return ($null -ne $cmd)
  } catch
  { 
    return $false 
  }
}

function Push-ToPath()
{
  param(
    [string[]]$Directories,
    [switch]$AtStart
  )
  $ValidDirectories = $Directories | Where-Object { Test-Path $_ } | ForEach-Object { Resolve-Path $_ }
  if ($env:PATH[-1] -ne ';')
  {
    $env:PATH += ';'
  }
  if ($AtStart)
  {
    $env:PATH = "$($ValidDirectories -Join ';');$env:PATH"
  } else
  {
    $env:PATH += ($ValidDirectories -Join ';')
  }
}

function Set-EnvironmentVars()
{
  param([hashtable]$EnvVariablePairs, [switch]$NotAPath)
  foreach ($name in $EnvVariablePairs.Keys)
  {
    $value = $EnvVariablePairs[$name]
    if (!$NotAPath -and (Test-Path $value -IsValid))
    {
      if (Test-Path $value)
      {
        $value = Resolve-Path $value
      } else
      { 
        continue; 
      }
    }
    Set-Item -Path "Env:$name" -Value "$value"
  }
}

function Get-WebBrowserDirectories()
{
  [OutputType([string[]])]
  param ()

  $PossibleBrowserLocations = @(
    @(
      { return (Get-ItemProperty 'HKLM:\SOFTWARE\Mozilla\Mozilla Firefox\*\Main').PathToExe },
      "$env:ProgramFiles\Mozilla Firefox\", "${env:ProgramFiles(x86)}\Mozilla Firefox\", "$env:LOCALAPPDATA\Mozilla Firefox\"
    ),
    @(
      { return (Get-ItemProperty 'HKLM:\SOFTWARE\Classes\ChromeHTML\shell\open\command')."(default)" -replace ' *--.*', '' },
      "$env:ProgramFiles\Google\Chrome\Application\", "${env:ProgramFiles(x86)}\Google\Chrome\Application\", "$env:LOCALAPPDATA\Google\Chrome\Application\"
    ),
    @(
      { return (Get-ItemProperty 'HKLM:\SOFTWARE\Classes\MSEdgeHTM\shell\open\command')."(default)" -replace ' *--.*', '' },
      "$env:ProgramFiles\Microsoft\Edge\Application\", "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\", "$env:LOCALAPPDATA\Microsoft\Edge\Application\"
    )
  )

  $BrowserLocations = $PossibleBrowserLocations | ForEach-Object {
    foreach ($Location in $_)
    {
      if ($Location -is [scriptblock])
      {
        try
        { $Location = $Location.Invoke() 
        } catch
        { continue 
        }
      }
      if ($Location -and ($Location.Length -gt 0) -and (Test-Path "$Location"))
      {
        return $Location
      }
    }
  }

  return $BrowserLocations
}
