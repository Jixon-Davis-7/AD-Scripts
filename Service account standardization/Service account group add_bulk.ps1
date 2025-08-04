$inputpath = "C:\Users\davisj1\VSCode\My_Scripts\Powershell\Service account standardization\Output.txt"

$Svcaccounts = Get-Content -Path $inputpath


foreach ($user in $Svcaccounts) 
{
  $u = (Get-ADUser -Filter {Name -eq $user} -Properties samaccountname).samaccountname  
  
  $groups= @("FGP_ServiceAccounts", "R_AD_SecondaryAccount_Service")
  foreach ($group in $groups) 
  {
    Add-ADGroupMember -Identity $group -Members $u -Credential $credAdmin -Verbose
  }
}