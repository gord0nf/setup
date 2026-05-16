$save = $ProgressPreference
$ProgressPreference = 'SilentlyContinue' 
Invoke-WebRequest -UseBasicParsing @args
$ProgressPreference = $save
