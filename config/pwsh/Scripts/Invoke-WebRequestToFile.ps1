param ( [string]$Uri )

$filename = [System.IO.Path]::GetFileName(([uri]$Uri).LocalPath)
Invoke-BasicWebRequest -Uri "$Uri" -Outfile "$PWD\$filename" @args
