$acctkn = ""


$sec_tkn = $acctkn|ConvertTo-SecureString -AsPlainText -Force

#Connect-MgGraph -AccessToken $sec_tkn -NoWelcome
Connect-AzAccount -Subscription 'CognitiveServices-prd-amer-7e35da2f' | Out-Null
Connect-MgGraph  -NoWelcome


# Define the path to the CSV file
$csvFilePath = "C:\Users\davisj1\VSCode\PwshScripts_L\Files\Input.csv"

# Connect to Microsoft Graph
# Connect-MgGraph -Scopes "User.ReadWrite.All", "Group.ReadWrite.All"

# Import the CSV file
$serviceAccounts = Import-Csv -Path $csvFilePath

# Initialize progress bar
$totalAccounts = $serviceAccounts.Count
$counter = 0

foreach ($account in $serviceAccounts) {
    try {
        # Create a new service account
        $userParams = @{
            AccountEnabled = $true
            DisplayName = $account.Description # Here Description is Display Name update it in csv file.
            MailNickname = $account.SamAccountName
            UserPrincipalName = "$($account.SamAccountName)@autodesk.onmicrosoft.com"  # Adjust domain accordingly
            PasswordProfile = @{
                ForceChangePasswordNextSignIn = $false
                Password = "rUgm4xIIgzvEV6ofkbU1xu"  # Use a secure password policy
            }
        New-MgUser @userParams
        
        # Split group IDs and add the account to each group
        $groupIds = $account.GroupIDs -split ","
        foreach ($groupId in $groupIds) {
            # Trim any whitespace from the group ID
            $groupIdTrimmed = $groupId.Trim()
            
            # Add user to the group using the group ID directly
            try {
                Add-MgGroupMember -GroupId $groupIdTrimmed -MemberId (Get-MgUser -Filter "userPrincipalName eq '$($account.SamAccountName)@yourdomain.com'").Id
                Write-Host "Added $($account.SamAccountName) to group with ID: $groupIdTrimmed"
            } catch {
                Write-Host "Error adding $($account.SamAccountName) to group ID '$groupIdTrimmed': $_"
            }
        }
        
        # Update progress
        $counter++
        Write-Progress -PercentComplete (($counter / $totalAccounts) * 100) -Status "Creating Service Accounts" -CurrentOperation "Processing $($account.SamAccountName)"
    } 
    catch {
        Write-Host "Error processing $($account.SamAccountName): $_"
    }
}


Write-Host "All service accounts created and added to groups."

}