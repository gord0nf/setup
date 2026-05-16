param ( [string]$Path, [string]$Destination ) 	

if (-not $IsWindows)
{
  throw "This script is only supported on Windows."
}

$msiFull = (Get-Item $Path).FullName 	
$destFull = (Get-Item $Destination).FullName 	
cmd.exe /c "msiexec /a ""$msiFull"" /qb TARGETDIR=""$destFull""" 	
