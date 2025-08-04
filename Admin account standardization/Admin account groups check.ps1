$outpupath = "C:\Users\davisj1\VSCode\My_Scripts\Powershell\Admin account standardization\Output.txt"
Clear-Content -Path $outpupath

$gnames = @()
$Usershavingadmingroups = @()
$Usersmissingadmingroups = @()
$Userdetails = @()

$Admingps = @("FGP_AdminAccounts", "Password Expiring Admin Notification", "R_U_AllUsers")
$date = [datetime]::ParseExact("2025-01-01", "yyyy-MM-dd", $null)
$ou = "OU=Admin,OU=Users,OU=Objects,DC=ads,DC=autodesk,DC=com"

#$users = Get-ADUser -Filter {WhenCreated -gt $date -and Name -like "*Admin*"}
#$users = Get-ADUser -Filter * -SearchBase $ou
$users = Get-ADUser -Filter {WhenCreated -gt $date} -SearchBase $ou
Foreach($us in $users)
{
  $user = Get-ADUser -Identity $us -Properties memberof, Displayname
  $gnames += ($user.memberof | ForEach-Object {Get-ADGroup $_}).Name

  #Checking if admin account's attribute, memberof contains the groups
  $UsershavingadmingroupsExist = $true
  Foreach($g in $Admingps)
  {
    If(-not $gnames.Contains($g))
     {
       $UsershavingadmingroupsExist = $false
       break
     }
  }

 if ($UsershavingadmingroupsExist) 
  {
   $Usershavingadmingroups += $($user.Name)
  } 
  else 
  {
   $Usersmissingadmingroups += $($user.Name)
  }
  $gnames = @()
}

$Usersmissingadmingroups | Out-File -Path $outpupath

$Userdetails = Foreach($GPMissinguser in $Usersmissingadmingroups)
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

$Userdetails | Export-Excel -Path "C:\Users\davisj1\VSCode\My_Scripts\Powershell\Admin account standardization\Output.xlsx"