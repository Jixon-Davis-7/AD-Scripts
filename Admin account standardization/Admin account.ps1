#if($env:USERNAME.contains("admin")){$us = $env:USERNAME}  else{ $us = "$($env:USERNAME)admin"}
#    $credAdmin = get-credential -Credential "ADS\$us" 


Write-Host "Select one option" -ForegroundColor Yellow
Start-Sleep -Seconds 1
Write-Host "  1. samaccountname" -ForegroundColor Yellow
Write-Host "  2. Displayname" -ForegroundColor Yellow

$select = Read-Host "Select 1/2 to enter samaccountname or displayname: "

If($select -eq "1")
{
    $adminacc = Read-Host "Enter admin account name: "
}
elseif($select -eq "2") 
{
    $admin = Read-Host "Enter admin account name: "
    $adminacc = Get-ADUser -Filter {Name -eq $admin} -Properties samaccountname | Select-Object -ExpandProperty samaccountname
}
else
{
    Write-Host "Invalid input" -ForegroundColor Magenta
}


try
{
 $groups= @("FGP_AdminAccounts", "Password Expiring Admin Notification", "R_U_AllUsers")
 foreach ($group in $groups) 
  {
    Add-ADGroupMember -Identity $group -Members $adminacc -Credential $credAdmin -ErrorAction Stop
  }
  Write-Host "Request successful" -ForegroundColor Green
  ""
  Start-Sleep -Seconds 8
  Write-Host "Updated group membership of $adminacc :" -ForegroundColor Yellow
  ((Get-ADUser -Identity $adminacc -Properties memberof).memberof | ForEach-Object {Get-ADGroup -Identity $_}).Name
}
catch    
{
    Write-Host "Reuest Unsuccessful" -ForegroundColor Red
}