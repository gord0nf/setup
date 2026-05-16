param ( [string]$Path )

return (Get-ChildItem -Path "$Path" -Recurse -File -Force | Measure-Object -Property Length -Sum).Sum
