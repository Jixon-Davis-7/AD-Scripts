#CLEAR LITIGATION HOLD ATTRIBUTES

<#
   For a user account

   MsExchRecipientDisplayType : -2147483642
   MsExchRecipientTypeDetails : 2147483648
   msExchRemoteRecipientType  : 3
#>


#$username  = "Martin Misol Monzo"
$username = Read-Host "Enter user's Name:"

$userattributes = Get-ADUser -Filter {Name -eq $username} -Properties *
Write-Host "User exchange litigation hold attributes below:"  -ForegroundColor Yellow
Start-Sleep -Seconds 2

$userattributes | Select-Object -Property Name, emailaddress, msExchLitigationHoldDate, msExchLitigationHoldOwner, msExchArchiveGUID, msExchMailboxGuid, msExchUserHoldPolicies 

$Clearattributes = Read-Host "Do you need to clear the ligtigation hold attributes(msExchLitigationHoldDate', 'msExchLitigationHoldOwner', 'msExchArchiveGUID', 'msExchMailboxGuid', 'msExchUserHoldPolicies')   [Yes | No]:"

If($Clearattributes -eq "Yes")
{
 #$AttributesToClear = @('msExchLitigationHoldDate', 'msExchLitigationHoldOwner', 'msExchArchiveGUID', 'msExchMailboxGuid', 'msExchUserHoldPolicies')
 $AttributesToClear = @('msExchLitigationHoldDate', 'msExchLitigationHoldOwner', 'msExchUserHoldPolicies')

 foreach($a in $AttributesToClear)
 { 
  Set-ADUser -Identity $($userattributes.samaccountname) -Clear $a -Credential $credAdmin
 }
 Start-Sleep -Seconds 8
 ''
 $Resync = Read-Host "Do you want to move account into deprovisioned OU to resync account   [Yes | No]:"
 ''
 If($Resync -eq "Yes")
 {
   Move-ADObject -Identity $($userattributes.distinguishedname) -TargetPath "OU=Deprovisioned,OU=Users,OU=Objects,DC=ads,DC=autodesk,DC=com" -Credential $credAdmin -Verbose
   Start-Sleep -Seconds 8
   ''
   Write-Host "Please move account back to mailbox OU after the sync" -ForegroundColor Magenta
 }
 else {
    Write-Host "Please resync account manually from the AD console" -ForegroundColor Magenta
 }
''
Start-Sleep -Seconds 2
Write-Host "Cleared Litigation hold attributes" -ForegroundColor Green
''
Start-Sleep -Seconds 4
Get-ADUser -Filter {Name -eq $username} -Properties * | Select-Object -Property Name, emailaddress, distinguishedname, msExchLitigationHoldDate, msExchLitigationHoldOwner, msExchArchiveGUID, msExchMailboxGuid, msExchUserHoldPolicies 

} 
else
{
   Write-Host "No changes made on account" -ForegroundColor Yellow
}



#Get-ADUser -Filter {Name -eq $usr} -Properties * | Select-Object -Property MsExchRecipientDisplayType, MsExchRecipientTypeDetails, msExchRemoteRecipientType, msExchLitigationHoldDate, msExchLitigationHoldOwner, msExchArchiveGUID, msExchMailboxGuid, emailaddress






