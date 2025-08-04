#Credentials
#if($env:USERNAME.contains("admin")){$us = $env:USERNAME}  else{ $us = "$($env:USERNAME)admin"}
#    $credAdmin = get-credential -Credential "ADS\$us" 

# Define the distribution list (group) and the group to be added to dlMemSubmitPerms
$distributionList = Read-Host "Enter DL samaccount name where resctriction has to be applied:"
$authgroup = Read-Host "Enter DL samaccount name which has to be added as authorized sender:"


$groupToAdd = (Get-ADGroup -Identity $authgroup -Properties distinguishedname).distinguishedname
#$groupToAdd = "CN=Authorized PBP Communication,OU=Distribution,OU=Groups,OU=Objects,DC=ads,DC=autodesk,DC=com"

try
{
 # Retrieve the current dlMemSubmitPerms value
 $dl = Get-ADGroup -Identity $distributionList -Properties dlMemSubmitPerms
 $currentDlMemSubmitPerms = $dl.dlMemSubmitPerms

 # Check if dlMemSubmitPerms is $null and initialize it as an empty array if needed
 if ($null -eq $currentDlMemSubmitPerms) {
     $currentDlMemSubmitPerms = @()
 }

 # Add the new group to dlMemSubmitPerms
 $updatedDlMemSubmitPerms = $currentDlMemSubmitPerms + $groupToAdd

 # Update the distribution list with the new dlMemSubmitPerms value
 Set-ADGroup -Identity $distributionList -Replace @{ dlMemSubmitPerms = $updatedDlMemSubmitPerms } -Credential $credAdmin -ErrorAction Stop

 Write-Host "Updated successfully" -ForegroundColor Green
}

catch 
{
    Write-Host "Request failed" -ForegroundColor Magenta
}
