
$aliasList = @()
Write-Host "getting org list"
$orgList = sf org list --json | ConvertFrom-Json | select -exp result
Write-Host "generating sandbox alias list"
$sandboxes = $orgList | select -exp sandboxes | select -exp alias
$aliasList += $sandboxes
Write-Host "generating dev hub alias list"
$devHubs = $orgList | select -exp devHubs | select -exp alias
$aliasList += $devHubs
Write-Host "generating scratch org alias list"
$scratchOrgs = $orgList | select -exp scratchOrgs | select -exp alias
$aliasList += $scratchOrgs
Write-Host "generating non-scratch org alias list"
$nonScratchOrgs = $orgList | select -exp nonScratchOrgs | select -exp alias
$aliasList += $nonScratchOrgs
$path = '..\docker\sfAuthFiles\'
if (!(test-path $path)) {
    md $path | Out-Null
}
$urlPaths = @()
foreach($record in $aliasList) {
    Write-Host "getting url path for org: " $record
    $fullFilePath = $path + $record + ".json"
    $urlPathRecord = sf org display --verbose -o $record --json
    Out-File -FilePath $fullFilePath -InputObject $urlPathRecord
    Write-Host "saved auth file for org: " $record " to path: " $fullFilePath
}
Write-Host "script finished"