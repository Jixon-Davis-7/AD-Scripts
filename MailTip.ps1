Clear-Host
" _________________________________________________________________________________________________________________"
"                                                UPDATE MAILTIP ON DLs                                             "
" _________________________________________________________________________________________________________________"


#if($env:USERNAME.contains("admin")){$us = $env:USERNAME}  else{ $us = "$($env:USERNAME)admin"}
 #   $credAdmin = get-credential -Credential "ADS\$us" 


# Prompt for the Distribution Group's sAMAccountName
$groupName = Read-Host "Enter the DL's sAMAccountName"

# Attempt to retrieve the group from Active Directory
$group = Get-ADGroup -Filter {SamAccountName -eq $groupName}

# Check if the group exists
if ($group) {
    $mailtip = Read-Host "Enter the MailTip value"
    $formattedMailTip = "default:<html><body>$mailtip</body></html>"

    # Check MailTip length
    if ($formattedMailTip.Length -gt 171) {
        Write-Host "Warning: The MailTip exceeds 171 characters and will not be applied." -ForegroundColor Yellow
        Write-Host "Please shorten the message and try again." -ForegroundColor Yellow
    }
    else {
        try {
            # Update the group with MailTip
            Set-ADGroup -Identity $groupName -Replace @{msExchSenderHintTranslations = $formattedMailTip} -Credential $credAdmin
            Write-Host "MailTip has been successfully updated for group '$groupName'." -ForegroundColor Green
        }
        catch {
            Write-Host "An error occurred while updating the MailTip: $_" -ForegroundColor Red
        }
    }
} else {
    Write-Host "Error: Distribution Group '$groupName' not found in Active Directory." -ForegroundColor Red
}