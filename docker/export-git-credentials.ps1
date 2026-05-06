param(
    [string]$OutputPath = (Join-Path $HOME ".docker-git-credentials"),
    [string[]]$Hosts = @(
        "github.com"
    )
)

$ErrorActionPreference = "Stop"

function Get-GitCredentialRecord {
    param(
        [Parameter(Mandatory = $true)]
        [string]$GitHost
    )

    $request = "protocol=https`nhost=$GitHost`n`n"
    $response = $request | git credential fill 2>$null

    if (-not $response) {
        throw "No credential returned for https://$GitHost"
    }

    $record = @{}
    foreach ($line in $response) {
        if ([string]::IsNullOrWhiteSpace($line)) {
            continue
        }

        $parts = $line.Split("=", 2)
        if ($parts.Count -eq 2) {
            $record[$parts[0]] = $parts[1]
        }
    }

    if (-not $record.ContainsKey("username") -or -not $record.ContainsKey("password")) {
        throw "Credential for https://$GitHost does not include both username and password/token"
    }

    return $record
}

$parentPath = Split-Path -Path $OutputPath -Parent
if ($parentPath) {
    [void](New-Item -ItemType Directory -Path $parentPath -Force)
}

$lines = foreach ($gitHost in $Hosts) {
    $record = Get-GitCredentialRecord -GitHost $gitHost
    $encodedUser = [System.Uri]::EscapeDataString($record.username)
    $encodedSecret = [System.Uri]::EscapeDataString($record.password)
    "https://$encodedUser`:$encodedSecret@$gitHost"
}

Set-Content -Path $OutputPath -Value $lines -NoNewline:$false
Write-Host "Wrote $($lines.Count) credential entries to $OutputPath"
