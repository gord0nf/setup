if (Test-Binary oh-my-posh)
{
  $ompConfig = "custom", "takuya", "half-life" | 
    ForEach-Object { "$PSScriptRoot/../../ohmyposh/$_.omp.json" } |
    Where-Object { Test-Path $_ } |
    Select-Object -First 1
  oh-my-posh init pwsh --config "$ompConfig" | Invoke-Expression
}
