# Import the Active Directory module
Import-Module ActiveDirectory

# Define the path to your CSV file
$csvFilePath = "C:\Users\davisj1\VSCode\My_Scripts\Powershell\Bulk proxyaddress update\Input.csv"

# Import the CSV file into a PowerShell object
$data = Import-Csv -Path $csvFilePath

# Loop through each row in the CSV file
foreach ($row in $data) {
    $userPrincipalName = $row.UserEmail  # Assuming the first column is named 'UserEmail'
    $proxyAddressToAdd = $row.ProxyAddress  # Assuming the second column is named 'ProxyAddress'

    # Add the proxy address to the user's proxyAddresses attribute
    try {
        $a = Get-ADUser -Filter {userprincipalname -eq $userPrincipalName} -Properties samaccountname | Select-Object -ExpandProperty samaccountname
        Set-ADUser -Identity $a -Add @{proxyAddresses = "smtp:$proxyAddressToAdd"} -Credential $credAdmin
        Write-Host "Successfully added $proxyAddressToAdd to $userPrincipalName"
    } catch {
        Write-Host "Failed to update $userPrincipalName"
    }
}