Get-ADObject -Filter 'isDeleted -eq $true -and name -like "ese vendor management*"' -IncludeDeletedObjects -Credential $credDA |
    Restore-ADObject -Verbose




    Get-ADObject -Filter 'isDeleted -eq $true -and name -like "svc_p_mo*"' -IncludeDeletedObjects -Credential $credDA