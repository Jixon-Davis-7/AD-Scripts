Clear-Host
" ______________________________________________________________________________________________________________________"
"                                                 TEST ACCOUNT CREATION SCRIPT                                          "
" ______________________________________________________________________________________________________________________"
""

#if($env:USERNAME.contains("admin")){$us = $env:USERNAME}  else{ $us = "$($env:USERNAME)admin"}
#    $credAdmin = get-credential -Credential "ADS\$us" 

function Creation 
{
  param(
      [string]$tstacc,
      [string]$givenname,
      [string]$ritmnumber,
      [string]$Owner,
      [datetime]$expirationDate,
      [string]$Ownerdn,
      [PSCredential]$credAdmin
    )

  # Checking if the test account already exists
  $tstaccount = Get-ADUser -Filter {samaccountname -eq $tstacc} -Properties * | Select-Object -Property name

  if ($tstaccount) 
  {
    Write-Host "Service account already exists with name $tstacc. Please provide a unique name." -ForegroundColor Magenta
  } 
  else 
  {
   #Define parameters for the new user
   $userParams = @{
          Name = $tstacc
          givenName = $givenname
          SamAccountName = $tstacc
          UserPrincipalName = "$tstacc@autodesk.com"
          DisplayName = $tstacc
          Enabled = $true
          ChangePasswordAtLogon = $true
        }
  
  try 
  {     
    #Creating new account
    New-ADUser @userParams -AccountPassword $passwd -Credential $credAdmin -Path "OU=Test Accounts,OU=Users,OU=Objects,DC=ads,DC=autodesk,DC=com" -Verbose -ErrorAction Stop
    Start-Sleep -Seconds 15

    #Updating account attributes
    $tst = Get-ADUser -Identity $tstacc -Properties *
    $samaccountname = $tst.samaccountname
    $attributes = @{
            'employeeID' = '0tst'
            'extensionAttribute1' = '0tst'
            'description' = "Requested: $ritmnumber"
            'sn' = $samaccountname
            'manager' = $Ownerdn
            'accountexpires' = $expirationDate
           }

    Set-ADUser -Identity $tstacc -Replace $attributes -Credential $credAdmin -Verbose
    Start-Sleep -Seconds 6
    Set-ADUser -Identity $tstacc -ChangePasswordAtLogon $true -Credential $credAdmin
    Start-Sleep -Seconds 2

    #Adding to base groups
    $groups = @("FGP_TestAccounts")
    foreach ($group in $groups) 
    {
      Add-ADGroupMember -Identity $group -Members $tstacc -Credential $credAdmin
    }
     Write-Host "Adding test account to the groups" -ForegroundColor Yellow
     Start-Sleep -Seconds 8

     Write-Host "Test account $tstacc created successfully. Details as below:" -ForegroundColor Green
     Get-ADUser -Identity $tstacc -Properties * | Select-Object -Property name, samaccountname, UserPrincipalName, Manager, accountexpires
  }
  
  catch
  {
    Write-Host "Test account $tstacc creation failed." -ForegroundColor Red
    Write-Host "Please check the below input attributes are correct and rerun the script:"
    $userParams
  }
  
 }
}


Start-Sleep -Seconds 3

$tstacc = $ritmnumber = $expirationDate = $tstaccount = $env = $Ownerdn = $Owner = ''
$givenname = Read-Host "Provide the post part of the test account name [""tst_[p/d/s/q]_"" will get added with the provided name][14 char max] :"
$Env = Read-Host "Provide the environment of the test account [""p for prod, d for dev, s for stage, q for QA""] :"
$env = $Env.ToLower()

$tstacc = "tst_$env" + "_$givenname"  # Test account full name

if ($givenname -and ($env -eq 'p' -or $env -eq 's' -or $env -eq 'd' -or $env -eq 'q')) 
{
  if ($tstacc.Length -le 20) 
  {
    $ritmnumber = Read-Host "Please provide the TASK number for the test account creation request :" 
    $passwd = Read-Host -AsSecureString "Enter the password for test account"
    $Owner = Read-Host "Provide test account owner's UPN :"
    $expirationDateStr = Read-Host "Provide expiry date for the test account in format[YYYY-MM-DD]. example- [2024-12-31] :"

    try #checking whether provided expiry date is valid or not
    {
       $expirationDate = [datetime]::ParseExact($expirationDateStr, "yyyy-MM-dd", $null)
    } 
    catch 
    {
      Write-Host "Invalid date format. Please provide the date in format YYYY-MM-DD." -ForegroundColor Red
      return
    }
   
    try #query the owner account with provided UPN
    {
      $Ownerdn = Get-ADUser -Filter {userprincipalname -eq $Owner} -Properties * | Select-Object -ExpandProperty distinguishedName -ErrorAction Stop
    }
    catch
    {
       Write-Host "Provided owner account not found in AD" -ForegroundColor Magenta
    }
     
     if ('' -eq $ritmnumber -or '' -eq $Ownerdn -or '' -eq $expirationDate ) #checking if input values are empty
     {
        Write-Host "Input parameters should not be empty." -ForegroundColor DarkMagenta 
     } 
     else 
     {
       Creation -tstacc $tstacc -givenname $givenname -ritmnumber $ritmnumber -passwd $passwd -Owner $Owner -expirationDate $expirationDate -Ownerdn $Ownerdn -credAdmin $credAdmin
       Start-Sleep -Seconds 2
     }
  } 
  else 
  {
    Write-Host "Provided Test account name is too lengthy" -ForegroundColor Magenta
  }
} 
elseif ($givenname -and ($env -ne 'p' -or $env -ne 's' -or $env -ne 'd' -or $env -ne 'q'))
{
  Write-Host "Provided environment is invalid" -ForegroundColor Magenta
} 
else 
{
  Write-Host "Test account name is invalid" -ForegroundColor Magenta
}


