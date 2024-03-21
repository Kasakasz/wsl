. C:\Users\KRG\AppData\Local\sf\autocomplete\functions\powershell\sf.ps1
Import-Module posh-git
Set-PSReadLineKeyHandler -Chord Ctrl+n HistorySearchForward
Set-PSReadLineKeyHandler -Chord Ctrl+p HistorySearchBackward

Set-Alias fromjson ConvertFrom-Json
Set-Alias tojson ConvertTo-Json