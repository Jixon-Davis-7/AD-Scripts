#if($env:USERNAME.contains("admin")){$us = $env:USERNAME}  else{ $us = "$($env:USERNAME)admin"}
#    $credAdmin = get-credential -Credential "ADS\$us" 


$svcacc = Read-Host "Enter service account samaccountname: "

$groups= @("FGP_ServiceAccounts", "R_AD_SecondaryAccount_Service")    #"sharepoint.users"
foreach ($group in $groups) 
 {
   Add-ADGroupMember -Identity $group -Members $svcacc -Credential $credAdmin
 }