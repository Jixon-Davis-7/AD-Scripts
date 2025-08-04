
Clear-Host
" _________________________________________________________________________________________________________________"
"                                             SERVICE ACCOUNT CREATION SCRIPT                                      "
" _________________________________________________________________________________________________________________"

#Credentials
#Connect-AzAccount -Subscription 'CognitiveServices-prd-amer-7e35da2f' | Out-Null
#if($env:USERNAME.contains("admin")){$us = $env:USERNAME}  else{ $us = "$($env:USERNAME)admin"}
#    $credAdmin = get-credential -Credential "ADS\$us" 


function Creation
{
#Checking whether service account already exist
$svcaccount = Get-ADUser -Filter {samaccountname -eq $svcacc} -Properties * | Select-Object -Property name

#if serice account exist
If($svcaccount)
{
  Write-Host "Service account already exist with name $svcacc. Please provide a unique name." -ForegroundColor Magenta
}
#svc account doesnt exist and creating new account
else
{
  $passwd = Read-Host -AsSecureString "Enter the password for Service account"

# Define parameters for the new user
$userParams = @{
  Name            = $svcacc
  givenName       = $givenname
  SamAccountName  = $svcacc
  UserPrincipalName = $svcacc + "@autodesk.com"
  DisplayName     = $svcacc
  Enabled         = $true
}

  #Creating the account
  New-ADUser @userParams -AccountPassword $passwd -Credential $credAdmin -Path "OU=Service,OU=Users,OU=Objects,DC=ads,DC=autodesk,DC=com" -Verbose 
  Start-Sleep 15
  
  $svc = Get-ADUser -Identity $svcacc -Properties * 
     $samaccountname = $svc.samaccountname
     $dn = $svc.distinguishedName
  
  
     $attributes = @{'employeeID' = '0svc' 
                     'extensionAttribute1' = '0svc'
                     'description' = $descr
                     'msDS-cloudExtensionAttribute16' = $ritmnumber
                     'extensionAttribute8' = $dn
                     'mailNickname' = $samaccountname
                     'sn' = $samaccountname
                    } 
  
  
    Set-ADUser -Identity $svcacc -Replace $attributes -Credential $credAdmin -Verbose
    Start-Sleep -Seconds 2
  
  #Adding into base groups
  $groups= @("FGP_ServiceAccounts", "R_AD_SecondaryAccount_Service")    #"sharepoint.users"
   foreach ($group in $groups) 
    {
      Add-ADGroupMember -Identity $group -Members $svcacc -Credential $credAdmin
    }
  Write-Host "Adding service account into the groups.." -ForegroundColor Yellow
  Start-Sleep -Seconds 2
  

  #UPDATING OWNERS........................................................
  $Owner = ""
  
  $x1 = 1
  $x2 = 2
  $x3 = 3
  
  for($i = 1; $i -le 3; $i++)
  {  
  $Ownern = "Owner" + $i
  
   #To enter owner UPN in input 
  $Owner = Read-Host "Enter $Ownern UPN (It will update msDS-cloudExtension attributes $x1, $x2, $x3) or press enter to skip: "
  
   If($Owner) 
   {
    try 
      {
        $User = Get-AzADUser -UserPrincipalName  $Owner
        $ObjectID = $User.Id
        $Name = $User.Displayname
        $UPN = $User.UserPrincipalName     
      }  
    catch {} 
  
    $Attribute1 = "msDS-cloudExtensionAttribute" + $x1
    $Attribute2 = "msDS-cloudExtensionAttribute" + $x2
    $Attribute3 = "msDS-cloudExtensionAttribute" + $x3
  
      
    If($UPN -eq $Owner)
     {
       Set-ADUser -Identity $svcacc -Replace @{$Attribute1 = $ObjectID;
                                                  $Attribute2 = $Name; 
                                                  $Attribute3 = $UPN 
                                                } -Credential $credAdmin
       Write-Host "Updating $Ownern" -ForegroundColor Green
       ""
       Start-Sleep -Seconds 1
     }
   else #if UPN is invalid or not existing in azure AD
     {
     Write-Host "No user account found with UPN -    $Owner"   -ForegroundColor Red
     }
    }
   $x1 += 3
   $x2 += 3
   $x3 += 3
  } 
  Write-Host "Updating the Owners " -ForegroundColor Yellow
  Start-Sleep 5
  write-host "Service account $svcacc  created successfully. Details as below:" -ForegroundColor Green
  Start-Sleep 2
  Get-ADUser -Identity $svcacc -Properties * | Select-Object -Property name, samaccountname, UserPrincipalName, msDS-cloudExtensionAttribute2, msDS-cloudExtensionAttribute5, msDS-cloudExtensionAttribute8
 
 }
}




Start-Sleep -Seconds 3
$descr = $ritmnumber = $svcacc = $js = ''

$givenname = Read-Host "Please provide the post part of the service account name [""svc_(p/d/s/q/t)_""  will get added with the provided name][14 char max] :"
$Env = Read-Host "Please provide the evvironment of the service account [""p for prod, d for dev, s for stage, q for QA, t for test""] :"
$env = $Env.ToLower()
$ritmnumber = Read-Host "Please provide the TASK number for the service account creation request :" 
$js = Read-host "Provide application name where the service is going to be used or justification for creating legacy service account: "
#$ritmnumber = "TASK1671243"
$descr = "Requested:$ritmnumber ($js)"

#service account full name
$svcacc = "svc_$env"+"_$givenname"

If($givenname -and ($env -eq 'p' -or $env -eq 's' -or $env -eq 'd' -or $env -eq 'q' -or $env -eq 't'))
{
  If($svcacc.Length -le 20)
  {
    If($ritmnumber -ne '' -and $js -ne '')
    {
    Creation
    start-sleep 2
    }
    else 
    {
      Write-Host "Input values should not be empty" -ForegroundColor Magenta
    }
  
  }  
  else 
  {
   Write-Host "Provided Serice account name is too lenghty"  -ForegroundColor Magenta
  }
} 
elseif($givenname -and ($env -ne 'p' -or $env -ne 's' -or $env -ne 'd' -or $env -ne 'q' -or $env -ne 't')) 
{
   Write-Host "Provided environment is invalid" -ForegroundColor Magenta
}
else 
{
   Write-Host "Service account name is invalid"   -ForegroundColor Magenta
}