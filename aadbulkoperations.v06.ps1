# aadbulkoperations.ps1 version .06
# Usage (run as Administrator): .\aadbulkoperations.ps1 -genid A 
# where -genid is a switch enabling multiple load generators to operate simultaneously 
param ([string]$genid = "genid")

$aadtenant = "______.onmicrosoft.com"
$aadadminuser = "aadadmin@______.onmicrosoft.com"
$aadadminpassword = ConvertTo-SecureString -String "********" -AsPlainText -Force
$aadadmincredentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $aadadminuser, $aadadminpassword
Connect-MsolService -Credential $aadadmincredentials

######### Create User Objects
$starttime = Get-Date
$totalusers = 200
For ($userid = 0; $userid -lt $totalusers; $userid++)
{
 $response = New-MsolUser -UserPrincipalName "user.$genid.$userid@$aadtenant" -DisplayName "User $genid $userid" -FirstName "User" -LastName $userid -Password "P@ssw0rd" -UsageLocation "US" -ForceChangePassword $false
# Write-Host "Created user.$userid@$aadtenant - User $userid"
}
$endtime = Get-Date
#Write-Host "  END = " $endtime
#Write-Host "START = " $starttime
Write-Host "Created $userid users in" ([math]::Round(($( $( $endtime.Ticks - $starttime.Ticks ) / 10000000)),2)) "seconds at " ([math]::Round(($( $userid / $($( $endtime.Ticks - $starttime.Ticks ) / 10000000))),2)) "tx/second"


######### Create Group Objects
$starttime = Get-Date
$totalgroups = 10
For ($groupid = 0; $groupid -lt $totalgroups; $groupid++)
{
 $response = New-MsolGroup -Description "group.$genid.$groupid" -DisplayName "group.$genid.$groupid"
# Write-Host "Created group.$groupid"
}
$endtime = Get-Date
#Write-Host "  END = " $endtime
#Write-Host "START = " $starttime
Write-Host "Created $groupid groups in" ([math]::Round(($( $( $endtime.Ticks - $starttime.Ticks ) / 10000000)),2)) "seconds at " ([math]::Round(($( $groupid / $($( $endtime.Ticks - $starttime.Ticks ) / 10000000))),2)) "tx/second"


######### Add User objects to groups
# $starttime = Get-Date
$cnt = 0
$userobjects = MSOnlineExtended\Get-MsolUser -All -SearchString "user.$genid."
$groups = Get-MsolGroup -All -SearchString "group.$genid." 
$grouparray = (0..$groups.length)
foreach ($group in $groups) {
  $grouparray[$cnt] = $group
  $cnt++
}
$cnt = 0 
$starttime = Get-Date
foreach ($userobject in $userobjects) {
 $i = Get-Random -minimum 0 -maximum $groups.length
 $userupn = $userobject.UserPrincipalName | Out-String
 Add-MsolGroupMember -GroupObjectId $grouparray[$i].ObjectId -GroupMemberObjectId $userobject.objectId
# Write-Host "User: " $userupn " added to group."$i
 $cnt++
 }
$endtime = Get-Date
#Write-Host "  END = " $endtime
#Write-Host "START = " $starttime 
Write-Host "With a user added to only one group"
Write-Host "Placed $cnt users across $totalgroups random groups in" ([math]::Round(($( $( $endtime.Ticks - $starttime.Ticks ) / 10000000)),2)) "seconds at " ([math]::Round(($( $cnt / $($( $endtime.Ticks - $starttime.Ticks ) / 10000000))),2)) "tx/second"


######## Update User objects
# $starttime = Get-Date
$cnt = 0
$userobjects = MSOnlineExtended\Get-MsolUser -All -SearchString "user.$genid."
$starttime = Get-Date
foreach ($userobject in $userobjects) {
 $userupn = $userobject.UserPrincipalName | Out-String
 $response = Get-MsolUser -ObjectId $userobject.ObjectId | Set-MsolUser -Title "Title of the highest Order - $userupn"
# Write-Host "Updated $userupn"
 $cnt++
 }
$endtime = Get-Date
#Write-Host "  END = " $endtime
#Write-Host "START = " $starttime
Write-Host "Updated $cnt users in" ([math]::Round(($( $( $endtime.Ticks - $starttime.Ticks ) / 10000000)),2)) "seconds at " ([math]::Round(($( $cnt / $($( $endtime.Ticks - $starttime.Ticks ) / 10000000))),2)) "tx/second"

######## Wildcard User Search
$starttime = Get-Date
$userobjects = MSOnlineExtended\Get-MsolUser -All -SearchString "user.$genid."
$endtime = Get-Date
$usercnt = $userobjects | Select-Object ObjectId
#Write-Host "  END = " $endtime
#Write-Host "START = " $starttime
Write-Host "Wildcard Search on user.$genid.* returned" $usercnt.Length "user objects in" ([math]::Round(($( $( $endtime.Ticks - $starttime.Ticks ) / 10000000)),2)) "seconds at " ([math]::Round(($( $usercnt.Length / $($( $endtime.Ticks - $starttime.Ticks ) / 10000000))),2)) "tx/second"

######### Exact User Search
$starttime = Get-Date
$cnt = 0
$max = 2
For ($i = 0; $i -lt $max; $i++)
{
 foreach ($userobject in $userobjects) {
  $userupn = $userobject.UserPrincipalName | Out-String
  $response = MSOnlineExtended\Get-MsolUser -SearchString $userupn
#  Write-Host "Searched $userupn"
  $cnt++
 }
}
$endtime = Get-Date
#Write-Host "  END = " $endtime
#Write-Host "START = " $starttime
Write-Host "Exact Searched $cnt times in" ([math]::Round(($( $( $endtime.Ticks - $starttime.Ticks ) / 10000000)),2)) "seconds at " ([math]::Round(($( $cnt / $($( $endtime.Ticks - $starttime.Ticks ) / 10000000))),2)) "tx/second"

######### Authenticate Users
$starttime = Get-Date
$cnt = 0
$maxauths = 2
For ($i = 0; $i -lt $maxauths; $i++)
{
 foreach ($userobject in $userobjects) {
  $userupn = $userobject.UserPrincipalName | Out-String
  $userpassword = ConvertTo-SecureString -String "P@ssw0rd" -AsPlainText -Force
  $usercredentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $userupn, $userpassword
  Connect-MsolService -Credential $usercredentials
#  Write-Host "Authenticated $userupn"
  $cnt++
 }
}
$endtime = Get-Date
#Write-Host "  END = " $endtime
#Write-Host "START = " $starttime
Write-Host "Authenticated $cnt times in" ([math]::Round(($( $( $endtime.Ticks - $starttime.Ticks ) / 10000000)),2)) "seconds at " ([math]::Round(($( $cnt / $($( $endtime.Ticks - $starttime.Ticks ) / 10000000))),2)) "tx/second"

Connect-MsolService -Credential $aadadmincredentials
#Start-Sleep -s 90

# Delete group objects
$starttime = Get-Date
$cnt = 0
$groupobjects = MSOnlineExtended\Get-MsolGroup -All -SearchString "group.$genid."
foreach ($groupobject in $groupobjects) {
 $groupdn = $groupobject.DisplayName | Out-String
 $response = Get-MsolGroup -ObjectId $groupobject.ObjectId | Remove-MsolGroup -Force
# Write-Host "Removed $groupdn"
 $cnt++
 }
$endtime = Get-Date
#Write-Host "  END = " $endtime
#Write-Host "START = " $starttime 
Write-Host "Removed $cnt groups in" ([math]::Round(($( $( $endtime.Ticks - $starttime.Ticks ) / 10000000)),2)) "seconds at " ([math]::Round(($( $cnt / $($( $endtime.Ticks - $starttime.Ticks ) / 10000000))),2)) "tx/second"

# Delete User objects
$starttime = Get-Date
$userobjects = MSOnlineExtended\Get-MsolUser -All -SearchString "user.$genid" | Remove-MsolUser -Force
$endtime = Get-Date
#Write-Host "  END = " $endtime
#Write-Host "START = " $starttime 
Write-Host "Removed" $usercnt.Length "users in" ([math]::Round(($( $( $endtime.Ticks - $starttime.Ticks ) / 10000000)),2)) "seconds at " ([math]::Round(($( $usercnt.Length / $($( $endtime.Ticks - $starttime.Ticks ) / 10000000))),2)) "tx/second"

Write-Host "Purging user objects from recycle bin"
Get-MsolUser -All  -SearchString "user.$genid" -ReturnDeletedUsers | Remove-MsolUser -RemoveFromRecycleBin -Force
