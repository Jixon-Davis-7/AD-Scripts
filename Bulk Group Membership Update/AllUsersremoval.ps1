<#

    $cred = get-credential 
#>


$groupname = Read-Host "Please provide the samaccountname of the group  : "
#$groupname = "Ariba.Users.All"
#$groupname = "kishan.test.legacy"


# Get the group object from Active Directory
$group = Get-ADGroup -Identity $groupname

# Check if the group exists
if ($group) 
{
    # Get all users from the group
    Write-Host "Fetching the current goup members.." -ForegroundColor Magenta
    $groupMembers = Get-ADGroup -Identity $groupName -Properties * | Select-Object -ExpandProperty members | Get-ADUser -Properties * 

    # Remove each user from the group
    foreach ($member in $groupMembers)
     {
        Remove-ADGroupMember -Identity $group -Members $member -Credential $credAdmin -Confirm:$false
        Write-Host "Removed user $($member.Name) from group $groupName" -ForegroundColor Yellow
     }
} 
else 
{
    Write-Host "Group $groupName not found." -BackgroundColor Red
}

