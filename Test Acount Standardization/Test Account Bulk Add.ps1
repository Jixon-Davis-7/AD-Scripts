$inputpath = "C:\Users\davisj1\VSCode\Pwshscripts_CPC\Files\Output.txt"

$Tstaccounts = Get-Content -Path $inputpath


foreach ($user in $Tstaccounts) 
{
  $u = (Get-ADUser -Filter {Name -eq $user} -Properties samaccountname).samaccountname  
  
  $groups= @("FGP_TestAccounts")
  foreach ($group in $groups) 
  {
    Add-ADGroupMember -Identity $group -Members $u -Credential $credAdmin -Verbose
  }
}