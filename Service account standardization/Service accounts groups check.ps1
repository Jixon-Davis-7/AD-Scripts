$outpupath = "C:\Users\davisj1\VSCode\My_Scripts\Powershell\Service account standardization\Output.txt"
Clear-Content -Path $outpupath

$gnames = @()
$GR = @()
$Gw = @()

#Time
$date = [datetime]::ParseExact("2024-07-01", "yyyy-MM-dd", $null)

#Time Duration
#$startDate = Get-Date "2021-01-01"
#$endDate = Get-Date "2023-01-02"


$Svcaccgps = @("FGP_ServiceAccounts", "R_AD_SecondaryAccount_Service")
$ou = "OU=Service,OU=Users,OU=Objects,DC=ads,DC=autodesk,DC=com"

#$users = Get-ADUser -Filter {WhenCreated -ge $startDate -and WhenCreated -le $endDate} -SearchBase $ou -SearchScope OneLevel #Pulling users which created in between a time frame
$users = Get-ADUser -Filter {WhenCreated -gt $date} -SearchBase $ou -SearchScope OneLevel   #Excluding the sub OUs
Foreach($us in $users)
{
  $user = Get-ADUser -Identity $us -Properties memberof
  $gnames += ($user.memberof | ForEach-Object {Get-ADGroup $_}).Name

  #Checking if admin account's attribute, memberof contains the groups
  $groupsExist = $true
  Foreach($g in $Svcaccgps)
  {
    If(-not $gnames.Contains($g))
     {
       $groupsExist = $false
       break
     }
  }

 if ($groupsExist) 
  {
   $GR += $($user.Name)
  } 
  else 
  {
   $GW += $($user.Name)
  }
  $gnames = @()
}

$GW | Out-File -Path $outpupath



$Userdetails = Foreach($GPMissinguser in $Gw)
{
  $Madminuser = Get-ADUser -Filter {Name -eq $GPMissinguser} -Properties Displayname, DistinguishedName, WhenCreated
  $ACL = Get-Acl -Path ("AD:\$($Madminuser.DistinguishedName)")
  
  $Owner = $($ACL.Owner) -replace "^ADS\\", ""


  [PSCustomObject]@{
    DisplayName = $Madminuser.DisplayName
    Samaccountname = $Madminuser.SamAccountName
    Enabled = $Madminuser.Enabled
    CreatedOn = $Madminuser.WhenCreated
    CreatedBy = $Owner
    #CreatedBy = (Get-ADUser -Identity $Owner -Properties Displayname).DisplayName
   }
}

$Userdetails | Export-Excel -Path "C:\Users\davisj1\VSCode\My_Scripts\Powershell\Service account standardization\Output.xlsx"