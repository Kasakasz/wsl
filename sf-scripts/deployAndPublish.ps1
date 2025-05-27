$componentNames
$selectedOrg = $null
$siteName
$ignoreConflictsFlag
$directory
$componentStart = "";
$componentsCompleted = $false
$componentsFull
for ($var = 0; $var -le $args.Count; $var++) {
    $arg = $args[$var];
    $nextArg = $args[$var + 1];

    if ($null -ne $arg) {
        if($arg -eq "--metadata" -Or $arg -eq "-m") {
            $componentStart = "--metadata "
        }
        if($componentStart.Contains("--metadata ") -and -not($componentsCompleted)) {
            Write-Host "Metadata flag detected"
            Write-Host "Argument: $arg"
            Write-Host "Next Argument: $nextArg"
            if($nextArg.StartsWith("--") -or $nextArg.StartsWith("-")) {
                $componentsCompleted = $true
            }
            $componentNames = $componentNames +$arg + " "
        }

        if ($arg -eq "--org" -Or $arg -eq "-o") {
            $selectedOrg = $nextArg
        }

        if($arg -eq "--ignore-conflicts" -Or $arg -eq "-ic") {
            Write-Host "deploying using --ignore-conflicts flag"
            $ignoreConflictsFlag = "--ignore-conflicts"
        }
    }

    if($arg -eq "--site-name" -Or $arg -eq "-s") {
        $siteName = "`"$nextArg`""
    }

    if($arg -eq "--source-dir" -Or $arg -eq "-sd") {
        $directory = "--source-dir "
        $directory = $directory + $nextArg
    }
}

if(-not($null -eq $componentNames)) {
    $componentsFull = $componentStart + $componentNames
}

if($null -eq $siteName) {
    Write-Host "site name not provided - exitting"
    exit
}
if ($null -eq $selectedOrg) {
    $aliasList = @()
    $orgList = sf org list --json | ConvertFrom-Json | Select-Object -exp result
    $sandboxes = $orgList | Select-Object -exp sandboxes
    $aliasList += $sandboxes
    $devHubs = $orgList | Select-Object -exp devHubs
    $aliasList += $devHubs
    $scratchOrgs = $orgList | Select-Object -exp scratchOrgs
    $aliasList += $scratchOrgs
    $nonScratchOrgs = $orgList | Select-Object -exp nonScratchOrgs
    $aliasList += $nonScratchOrgs
    forEach($record in $aliasList) {
        if ($record.isDefaultUsername) {
            $selectedOrg = $record.alias
            break
        }
    }

    Write-Host "org not provided using default: " $selectedOrg
}
Write-Host "This is the command that is going to run: sf project deploy start $componentNames $directory $ignoreConflictsFlag -o $selectedOrg"
# Construct the command string
$deployCommand = "project deploy start $componentNames $directory $ignoreConflictsFlag -o $selectedOrg"
$publishCommand = "community publish --name $siteName -o $selectedOrg"

# Execute the commands using Start-Process
Start-Process -FilePath "sf" -ArgumentList $deployCommand -NoNewWindow -Wait
Start-Process -FilePath "sf" -ArgumentList $publishCommand -NoNewWindow -Wait
