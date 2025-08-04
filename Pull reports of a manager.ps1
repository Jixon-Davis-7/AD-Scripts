
$Name = Read-Host "Please provide the managers's Name:"
$userProperties = @()
# Get the user's Distinguished Name (DN) using their email
$m1 = (Get-ADUser -Filter {Name -eq $Name} -Properties mail).DistinguishedName
$serachBaseOU = "OU=Mailboxes,DC=ads,DC=autodesk,DC=com"

if ($null -eq $m1) {
    Write-Host "Check the email ID because it does not exist in AD"
} else {
    $cusr = @()
    $tusr = @()

    # Get the initial user and their direct reports
    $cusr += Get-ADUser -Filter {DistinguishedName -eq $m1} -SearchBase $serachBaseOU -Properties * #|
        #Select-Object Name, samaccountname, Description, Employeetype, DistinguishedName, UserPrincipalName, Enabled, mail, directReports, manager, co, city, extensionAttribute12, department

    $tusr += $cusr.directReports
    $i = 1

    # Loop to get all levels of direct reports
    while ($true) {
        $cusr.count
        $i++
        $tusr1 = @()

        foreach ($u in $tusr) {
            # Correct way to fetch AD user by Distinguished Name
            $usr = Get-ADUser -Filter {distinguishedname -eq $u} -SearchBase $serachBaseOU -Properties * -ErrorAction Stop #|
                #Select-Object Name, samaccountname, Employeetype, DistinguishedName, UserPrincipalName, Enabled, mail, directReports, manager, co, Description, city, extensionAttribute12, department

            if ($usr) {
                $cusr += $usr
                $tusr1 += $usr.directReports
            }
        }

        $tusr = $tusr1
        if ($i -eq 4) { $needdata = $tusr1 }  # Store 4th level users if needed
        if ($tusr1.Count -eq 0) { break }
    }

    # Save only users who are "Regular Employee"
    $FilteredUsers = $cusr #| Where-Object { $_.extensionAttribute12 -eq "Regular Employee"} | 
    #Where-Object { $_.Enabled -eq "True" } |
    Select-Object -Property Name, mail, Employeetype, Enabled, manager, department, DistinguishedName, Description, extensionAttribute10

    foreach($userObj in $FilteredUsers)
    {
    $dn = $userObj.DistinguishedName
    $ouOnly = if ($dn) { ($dn -split ',')[1..($dn.Length)] } else { @() }
    $ouOnlyString = $ouOnly -join ','


    $userProperties += [PSCustomObject]@{
        Name = $userObj.Name
        Enabled = $userObj.Enabled
        Region = $userObj.extensionAttribute10
        JobTitle = $userObj.Description
        UserprincipalName = $userObj.UserPrincipalName
        EmployeeType = $userObj.Employeetype
        OU = $ouOnlyString
        Accountenabled = $userObj.Enabled
        Manager = $userObj.manager
        Department = $userObj.department
        #DN = $userObj.DistinguishedName
    }

}
    # Export results to CSV
    $Outputpath = "C:\Users\davisj1\VSCode\Pwshscripts_CPC\Files\Output102.xlsx"
    $userProperties | Export-Excel -Path $Outputpath -WorksheetName "$($Name)" -AutoSize
   # Write-Host "Filtered results saved to 'RegularEmployees.csv'"
}
