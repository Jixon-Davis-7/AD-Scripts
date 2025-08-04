#$accounts = Get-Content -Path "C:\Users\davisj1\VSCode\Pwshscripts_CPC\Files\Input2.txt"
#$accounts = @("tst_s_boperf1", "tst_s_boperf2", "tst_s_boperf3", "tst_s_boperf4")

#$t = "tst_s_boperf"
#$Expirydates = @()

$Userdetails = for ($i = 1; $i -le 50; $i++) 
{
  $username = "tst_s_boperf$i"
  #$username = $t + $i
  #$test1

  $user = Get-ADUser -Identity $username -Properties * 
 $expirationDate = [DateTime]::FromFileTimeUtc($user.AccountExpires).ToLocalTime()
[PSCustomObject]@{
    Name = $user.Name
    AccountExpiryDate = $expirationDate
    #PasswordExpired = $user.PasswordExpired
    #AccountEnabled = $user.Enabled
 } 
}

$Userdetails | Format-Table -AutoSize
