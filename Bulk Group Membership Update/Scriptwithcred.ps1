#File path
$UsersListPath = "C:\Users\davisj1\VSCode\Pwshscripts_CPC\My Scripts\Bulk Group Membership Update\input.txt"
$logs = "C:\Users\davisj1\VSCode\Pwshscripts_CPC\My Scripts\Bulk Group Membership Update\logs.txt"



Clear-Host
Write-Host " _______________________________________________________________________________________________________________________________________" -ForegroundColor Cyan
Write-Host "                                                BULK GROUP MEMBERSHIP UPDATE SCRIPT                                                     " -ForegroundColor Cyan
Write-Host " _______________________________________________________________________________________________________________________________________" -ForegroundColor Cyan
Write-Host ""


#if($env:USERNAME.contains("admin")){$us = $env:USERNAME}  else{ $us = "$($env:USERNAME)admin"}
#    $credAdmin = get-credential -Credential "ADS\$us" 


$UsersList = Get-Content -Path $UsersListPath
Clear-Content -Path $logs
Add-Content -Path $logs -Value "List of user accounts not found in AD"
Add-Content -Path $logs -Value ""

# Prompt for the group name
$groupname = Read-Host "Please provide the samaccountname of the group: "

# Prompt for the list type
$listtype = Read-Host "Want to update group membership from the list of users' email address or list of users' names [Emailaddress(E)/Names(N)]: "


# Function to update group membership based on email addresses
function UpdateGroupMembershipByEmail 
{
    $currentgroupmembers = Get-ADGroup -Identity $groupName -Properties * | Select-Object -ExpandProperty members | Get-ADUser -Properties * | Select-Object -ExpandProperty Name

    foreach ($U in $UsersList) 
    {
        $User = Get-ADUser -Filter { emailaddress -eq $U } -Properties samaccountname, name, emailaddress

        if ($User) {
            $Username = $User.Name
            $samaccountname = $User.SamAccountName

            if ($Username -in $currentgroupmembers) 
            {
                Write-Host "$Username already exists in the group $groupname." -ForegroundColor Yellow
            } 
            else
            {
                Add-ADGroupMember -Identity $groupname -Members $samaccountname -Credential $credDA
                Write-Host "$Username added to the group $groupname." -ForegroundColor Green
            }
        }
         else 
        {
            Write-Host "User with email $U not found in Active Directory." -ForegroundColor Red
            "$U">>$logs
        }
    }
}

# Function to update group membership based on names
function UpdateGroupMembershipByName 
{
    $currentgroupmembers = Get-ADGroup -Identity $groupName -Properties * | Select-Object -ExpandProperty members | Get-ADUser -Properties * | Select-Object -ExpandProperty Name

    foreach ($U in $UsersList) {
        $User = Get-ADUser -Filter { name -eq $U } -Properties samaccountname, name, emailaddress

        if ($User) 
        {
            $Username = $User.Name
            $samaccountname = $User.SamAccountName

            if ($Username -in $currentgroupmembers)
            {
                Write-Host "$Username already exists in the group $groupname." -ForegroundColor Yellow
            } 
            else
            {
                Add-ADGroupMember -Identity $groupname -Members $samaccountname -Credential $credAdmin
                Write-Host "$Username added to the group $groupname." -ForegroundColor Green
            }
        } 
        else 
        {
            Write-Host "User $U not found in Active Directory." -ForegroundColor Red
            "$U" >> $logs
        }
    }
}

# Perform the appropriate action based on the list type
if ($listtype -eq "E") 
{
    UpdateGroupMembershipByEmail
}
elseif ($listtype -eq "N")
{
    UpdateGroupMembershipByName
} 
else 
{
    Write-Host "Invalid input for list type. Please provide 'E' or 'N'." -ForegroundColor Red
}
