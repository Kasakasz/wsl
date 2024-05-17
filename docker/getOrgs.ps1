
$aliasList = @()
$orgList = sf org list --json | ConvertFrom-Json | select -exp result
$sandboxes = $orgList | select -exp sandboxes | select -exp alias
$aliasList += $sandboxes
$devHubs = $orgList | select -exp devHubs | select -exp alias
$aliasList += $devHubs
$scratchOrgs = $orgList | select -exp scratchOrgs | select -exp alias
$aliasList += $scratchOrgs
$nonScratchOrgs = $orgList | select -exp nonScratchOrgs | select -exp alias
$aliasList += $nonScratchOrgs
$path = '.\sfAuthFiles\'
if (!(test-path $path)) {
    md $path | Out-Null
}
$urlPaths = @()
foreach($record in $aliasList) {
    $fullFilePath = $path + $record + ".json"
    $urlPathRecord = sf org display --verbose -o $record --json
    Out-File -FilePath $fullFilePath -InputObject $urlPathRecord
}
Write-Host "script finished"