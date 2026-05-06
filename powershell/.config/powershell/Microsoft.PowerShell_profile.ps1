Invoke-Expression (&starship init powershell)

Import-Module posh-git
Set-PSReadLineKeyHandler -Chord Ctrl+n HistorySearchForward
Set-PSReadLineKeyHandler -Chord Ctrl+p HistorySearchBackward

Set-Alias fromjson ConvertFrom-Json
Set-Alias tojson ConvertTo-Json

New-Alias l ls

function Find-SfProjectRoot {
    param(
        [string]$StartPath = $PWD.Path
    )

    $path = $StartPath
    while ($path) {
        if (Test-Path (Join-Path $path 'sfdx-project.json')) {
            return $path
        }

        $parent = Split-Path $path -Parent
        if (-not $parent -or $parent -eq $path) {
            break
        }

        $path = $parent
    }

    return $null
}

function Get-SfTargetOrg {
    param(
        [string]$ProjectRoot
    )

    if (-not $ProjectRoot) {
        return ''
    }

    $configPath = Join-Path $ProjectRoot '.sf/config.json'
    if (-not (Test-Path $configPath)) {
        return ''
    }

    try {
        return (Get-Content $configPath -Raw | ConvertFrom-Json).'target-org'
    }
    catch {
        return ''
    }
}

$prompt = ""
function Invoke-Starship-PreCommand {
    $current_location = $executionContext.SessionState.Path.CurrentLocation
    if ($current_location.Provider.Name -eq "FileSystem") {
        $ansi_escape = [char]27
        $provider_path = $current_location.ProviderPath -replace "\\", "/"
        $prompt = "$ansi_escape]7;file://${env:COMPUTERNAME}/${provider_path}$ansi_escape\"
    }
    $host.ui.Write($prompt)
}

function prompt {
    $ESC = [char]27
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal] $identity
    $adminRole = [Security.Principal.WindowsBuiltInRole]::Administrator
    $branch = git branch --show-current
    $projectRoot = Find-SfProjectRoot
    $orgAlias = Get-SfTargetOrg -ProjectRoot $projectRoot

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

    $prefix = if (Test-Path variable:/PSDebugContext) { '[DBG]: ' } else { '' }
    if ($principal.IsInRole($adminRole)) {
        $prefix = "[ADMIN]:$prefix"
    }

    $sfBodyPart = $bdGreen + $yellowColor + $orgAlias + $resetColor + " "
    $body =  "PS " + $greenColor + $PWD.Path + " " + $resetColor + $bdblue + $redColor + $branch + $resetColor + " "
    if ($projectRoot -and $orgAlias -ne "") {
        $body += $sfBodyPart
    }
    $suffix = $(if ($NestedPromptLevel -ge 1) { '>>' }) + '> '
	$time = $(Get-Date)
    "${prefix}${body}${time}${suffix}"
}

function findSfConfig {
    $projectRoot = Find-SfProjectRoot
    if (-not $projectRoot) {
        return $null
    }

    $configPath = Join-Path $projectRoot '.sf/config.json'
    if (Test-Path $configPath) {
        return $configPath
    }

    return $null
}


Invoke-Expression (& { (zoxide init powershell | Out-String) })

. C:\Users\username\AppData\Local\sf\autocomplete\functions\powershell\sf.ps1
