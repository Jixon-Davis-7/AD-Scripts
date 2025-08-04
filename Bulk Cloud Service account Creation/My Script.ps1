# Define user parameters
#Connect-AzAccount -Subscription 'CognitiveServices-prd-amer-7e35da2f' | Out-Null
#Connect-MgGraph  -NoWelcome


# Define the path to the CSV file
$csvFilePath = "C:\Users\davisj1\VSCode\My_Scripts\Powershell\Bulk Cloud Service account Creation\Input.csv"

# Connect to Microsoft Graph
# Connect-MgGraph -Scopes "User.ReadWrite.All", "Group.ReadWrite.All"

# Import the CSV file
$serviceAccounts = Import-Csv -Path $csvFilePath

# Initialize progress bar

foreach ($account in $serviceAccounts) {
$userParams = @{
    AccountEnabled = $true
    DisplayName = $account.Description # Here Description is Display Name update it in csv file.
    MailNickname = $account.SamAccountName
    employeeId = "0svc"
    UserPrincipalName = "$($account.SamAccountName)@autodesk.onmicrosoft.com"  # Adjust domain accordingly
    PasswordProfile = @{
        ForceChangePasswordNextSignIn = $false
        Password = "rUgm4xIIgzvEV6ofkbU1xu"  # Use a secure password policy
    }
}

# Create the cloud user account
New-MgUser @userParams
Write-Host "Created the service account $($account.SamAccountName)"
}
