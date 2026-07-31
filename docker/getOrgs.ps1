
$aliasList = @()
Write-Host "getting org list"
$orgList = sf org list --json | ConvertFrom-Json | select -exp result
Write-Host "list of orgList: " $orgList
# Write-Host "generating sandbox alias list"
# $sandboxes = $orgList | select -exp sandboxes | select -exp alias
# Write-Host "list of sandboxes: " $sandboxes
# $aliasList += $sandboxes
# Write-Host "generating dev hub alias list"
# $devHubs = $orgList | select -exp devHubs | select -exp alias
# Write-Host "list of dev hubs: " $devHubs
# $aliasList += $devHubs
Write-Host "generating scratch org alias list"
$scratchOrgs = $orgList | select -exp scratchOrgs | select -exp alias
Write-Host "list of scratch orgs: " $scratchOrgs
$aliasList += $scratchOrgs
Write-Host "generating non-scratch org alias list"
$nonScratchOrgs = $orgList | select -exp nonScratchOrgs | select -exp alias
Write-Host "list of non-scratch orgs: " $nonScratchOrgs
$aliasList += $nonScratchOrgs
$path = '..\docker\sfAuthFiles\'
if (!(test-path $path)) {
    md $path | Out-Null
} else {
    Get-ChildItem -Path $path -File | Remove-Item -Force
}
Write-Host "list of aliases: " $aliasList

$urlPaths = @()
foreach($record in $aliasList) {
    Write-Host "getting url path for org: " $record
    $fullFilePath = $path + $record + ".json"
    $urlPathRecord = sf org display --verbose -o $record --json
    Out-File -FilePath $fullFilePath -InputObject $urlPathRecord
    Write-Host "saved auth file for org: " $record " to path: " $fullFilePath
}
$fileCount = (Get-ChildItem -Path $path -File).Count
Write-Host "script finished"
Write-Host "created auth files:" $fileCount