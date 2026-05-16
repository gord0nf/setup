param ( [string[]]$dlls )

if (-not $IsWindows)
{
  throw "This script is only supported on Windows."
}

$dlls | ForEach-Object { 
  cmd /c "dumpbin -dependents $(Split-Path -Leaf $_)" | 
    Where-Object { $_.Contains(".dll") -and ! $_.Contains("Dump of file") } |
    ForEach-Object { $_.Trim() } 
  } |
    Select-Object -Unique |
    Where-Object { !(Test-Path $_) -and !(Get-Command -ErrorAction SilentlyContinue $_) }
