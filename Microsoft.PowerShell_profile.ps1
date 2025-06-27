
Import-Module posh-git
Set-PSReadLineKeyHandler -Chord Ctrl+n HistorySearchForward
Set-PSReadLineKeyHandler -Chord Ctrl+p HistorySearchBackward

Set-Alias fromjson ConvertFrom-Json
Set-Alias tojson ConvertTo-Json

function prompt {
    $ESC = [char]27
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal] $identity
    $adminRole = [Security.Principal.WindowsBuiltInRole]::Administrator
    $branch = git branch --show-current
    $orgAlias = ''
    $configFound = $false
    $directory = $PWD.Path

    #font color
    $resetColor = "${ESC}[0m"
    $redColor = "${ESC}[38;2;255;100;100m"
    $greenColor = "${ESC}[32m"
    $blueColor = "${ESC}[34m"
    $whiteColor = "$ESC[38;2;255;255;255m"
    $blackColor = "$ESC[38;2;0;0;0m"
    $yellowColor = "$ESC[38;2;255;255;0m"
    $magentaColor = "$ESC[38;2;255;0;255m"

    #background color
    $bdGreen = "$ESC[48;2;50;75;0m"
    $bgreen = "$ESC[48;2;76;102;0m"
    $bblue = "$ESC[48;2;0;0;0m"
    $bCyan = "$ESC[48;2;0;255;255m"
    $bdBlue = "$ESC[48;2;0;0;139m"
    $bBlack = "$ESC[48;2;0;0;0m"
    $bWhite = "$ESC[48;2;255;255;255m"
    $bGray = "$ESC[48;2;169;169;169m"
    $bYellow = "$ESC[48;2;255;255;0m"

    while(!$configFound) {
        if ((Test-Path (Join-Path $directory '.sf/config.json'))) {
            $configFound = $true
            $orgAlias = Get-Content (Join-Path $directory '.sf/config.json') | ConvertFrom-Json | select -exp 'target-org'
            break
        }
        
        $directory = Split-Path $directory -Parent
    }

    $prefix = if (Test-Path variable:/PSDebugContext) { '[DBG]: ' } else { '' }
    if ($principal.IsInRole($adminRole)) {
        $prefix = "[ADMIN]:$prefix"
    }

    $body =  "PS " + $greenColor + $PWD.Path + " " + $resetColor + $bdblue + $redColor + $branch + $resetColor + " " + $bdGreen + $yellowColor + $orgAlias + $resetColor + " "
    $suffix = $(if ($NestedPromptLevel -ge 1) { '>>' }) + '> '
	$time = $(Get-Date)
    "${prefix}${body}${time}${suffix}"
}

function findSfConfig {
    $path = $PWD.Path

    while($path -and (!Test-Path(Join-Path $path '.sf/config.json'))) {
        Write-Host "something"
        $path = Split-Path $path -Parent
    }
    return Join-Path $path '.sf/config.json'
}


Invoke-Expression (& { (zoxide init powershell | Out-String) })

. C:\Users\username\AppData\Local\sf\autocomplete\functions\powershell\sf.ps1
