
#Input File path
$UserAccounts = Get-Content -Path "C:\Users\davisj1\VSCode\My_Scripts\Powershell\Bulk User Account Actions\Input.txt"
$OutputPath = "C:\Users\davisj1\VSCode\My_Scripts\Powershell\Bulk User Account Actions\Output.xlsx"

#TARGET OU
#$MailboxOU = "OU=Mailboxes,DC=ads,DC=autodesk,DC=com"
$DeproOU ="OU=Deprovisioned,OU=Users,OU=Objects,DC=ads,DC=autodesk,DC=com"

#ARRAY TO SAVE ACCOUNT ACTIVITY OUTPUT
$SuccessAction = $FailedAction = @()
Import-Module ImportExcel

foreach($User in $UserAccounts){
   try{
   $userDN = (Get-ADUser -Filter {name -eq $User} -Properties distinguishedName).distinguishedName
   Move-ADObject -Identity $userDN -TargetPath $DeproOU -Credential $credAdmin -Verbose
   Write-Host "Account, $User moved to DeprovisionedOU" -ForegroundColor Green
   $SuccessAction += $User
   }
catch{
   Write-Host "Failed to move account $User" -ForegroundColor DarkMagenta
   $FailedAction += $User
 }
}

#SAVE OUTPPUT RESULT
$SuccessAction | Export-Excel -Path $OutputPath -WorksheetName "Successfull"
$FailedAction | Export-Excel -Path $OutputPath -WorksheetName "Failed"

