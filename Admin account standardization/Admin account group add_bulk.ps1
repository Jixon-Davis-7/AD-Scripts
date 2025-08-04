#if($env:USERNAME.contains("admin")){$us = $env:USERNAME}  else{ $us = "$($env:USERNAME)admin"}
#    $credAdmin = get-credential -Credential "ADS\$us" 


$inputpath = "C:\Users\davisj1\VSCode\My_Scripts\Powershell\Admin account standardization\Output.txt"

$Adminusers = Get-Content -Path $inputpath


foreach ($user in $Adminusers) 
{
  $u = (Get-ADUser -Filter {Name -eq $user} -Properties samaccountname).samaccountname  
  
  $groups= @("FGP_AdminAccounts", "Password Expiring Admin Notification", "R_U_AllUsers")
  foreach ($group in $groups) 
  {
    Add-ADGroupMember -Identity $group -Members $u -Credential $credAdmin -Verbose
  }
}
