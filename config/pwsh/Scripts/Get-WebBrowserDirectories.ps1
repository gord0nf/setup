if (-not $IsWindows) {
  throw "This script is only supported on Windows."
}

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
  foreach ($Location in $_) {
    if ($Location -is [scriptblock]) {
      try {
        $Location = $Location.Invoke() 
      } catch {
        continue 
      }
    }
    if ($Location -and ($Location.Length -gt 0) -and (Test-Path "$Location")) {
      return $Location
    }
  }
}

return $BrowserLocations
