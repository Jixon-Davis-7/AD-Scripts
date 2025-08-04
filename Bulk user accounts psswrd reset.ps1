$password = read-host -AsSecureString "Enter the password for test account"

 
$usernames = Get-Content -Path "C:\Users\davisj1\VSCode\Pwshscripts_CPC\Files\Input.txt"
 
foreach ($username in $usernames) 
{
    Get-ADUser -Identity $username -Properties passwordlastset, PasswordExpired | Select-Object -Property name, passwordlastset, PasswordExpired
    Set-ADAccountPassword -Identity $username -Credential $credAdmin -Reset -NewPassword $password -Verbose
}