$aadtenant = "_______.onmicrosoft.com"
$aadadminuser = "aadadmin@_______.onmicrosoft.com"
$aadadminpassword = ConvertTo-SecureString -String "********" -AsPlainText -Force
$aadadmincredentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $aadadminuser, $aadadminpassword
Connect-MsolService -Credential $aadadmincredentials

$groupobjects = MSOnlineExtended\Get-MsolGroup -All | Remove-MsolGroup -Force
$userobjects = MSOnlineExtended\Get-MsolUser -All -SearchString "user" | Remove-MsolUser -Force

Write-Host "Purging user objects from recycle bin"
Get-MsolUser -All -ReturnDeletedUsers | Remove-MsolUser -RemoveFromRecycleBin -Force
