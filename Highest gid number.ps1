
# Specify the attribute containing the digit value
$attributeName = "gidnumber"

# Query all user objects and retrieve the attribute
$users = Get-ADGroup -Filter * -Properties $attributeName

# Initialize variables to store the highest digit value and its corresponding user object
$highestValue = -1
$highestUser = $null

# Iterate through each user object
foreach ($user in $users) {
    # Retrieve the attribute value
    $attributeValue = $user.$attributeName

    # Check if the attribute value is a valid digit
    if ($attributeValue -match '\d+') {
        $digitValue = [int]$matches[0]

        # Check if the current digit value is higher than the highest recorded value
        if ($digitValue -gt $highestValue) {
            $highestValue = $digitValue
            $highestUser = $user
        }
    }
}

# Display the user object with the highest digit value
if ($highestUser -ne $null) {
    Write-Host "User with the highest digit value ($highestValue) in attribute '$attributeName' is:"
    $highestUser
} else {
    Write-Host "No user found with a valid digit value in attribute '$attributeName'."
}
