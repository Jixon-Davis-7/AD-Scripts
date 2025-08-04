# Define the group name
$groupName = Read-Host "Provide computer name: "

# Get the list of computer names from the text file
$computerList = Get-Content -Path "C:\Users\davisj1\VSCode\Pwshscripts_CPC\Files\Input.txt"

# Iterate through each computer name in the list
foreach ($computer in $computerList) 
{
    try {
            $com = Get-ADComputer -Identity $computer
            Remove-ADGroupMember -Identity $groupName -Members $com -Credential $credAdmin -Confirm:$false
            Write-Host "Removed $computer from $groupName" -ForegroundColor Green
    }
    catch {
        Write-Host "Request failed for machine $computer" -ForegroundColor Magenta
    }
    # Remove the computer from the group
}
