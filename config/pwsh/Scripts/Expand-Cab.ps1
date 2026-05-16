param( [string]$Path, [string]$Destination ) 	

if (-not $IsWindows)
{
  throw "This script is only supported on Windows."
}

expand.exe -F:* "$Path" "$Destination" 	
