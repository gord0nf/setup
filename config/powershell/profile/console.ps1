if (Get-Module -ListAvailable -Name PSReadLine)
{

  $PSReadLineOptions = @{
    EditMode = "Vi"
    HistoryNoDuplicates = $true
    HistorySearchCursorMovesToEnd = $true
    BellStyle = "None"
    PredictionSource = "History"
    MaximumHistoryCount = 10000

    # History filtering
    AddToHistoryHandler = {
      param([string]$line)
      $sensitive = "password|asplaintext|token|key|secret"
      return ($line -notmatch $sensitive)
    }
  }

  Set-PSReadLineOption @PSReadLineOptions

  Set-PSReadLineKeyHandler -Chord "Ctrl+n" -Function NextHistory
  Set-PSReadLineKeyHandler -Chord "Ctrl+p" -Function PreviousHistory
  Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
  Set-PSReadLineKeyHandler -Chord "Ctrl+ " -Function SwitchPredictionView
  Set-PSReadLineKeyHandler -Chord 'Ctrl+Backspace' -Function BackwardKillWord
  Set-PSReadLineKeyHandler -Chord 'Ctrl+w' -Function BackwardKillWord

}
