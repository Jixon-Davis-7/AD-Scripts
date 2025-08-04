#$accounts = Get-Content -Path "C:\Users\davisj1\VSCode\Pwshscripts_CPC\Files\Input2.txt"
$accounts = @("tst_s_boperf1", "tst_s_boperf2", "tst_s_boperf3", "tst_s_boperf4")

$Expirydates = foreach($s in $accounts)
{
  $user = Get-ADUser -Identity $s -Properties * 
 $expirationDate = [DateTime]::FromFileTimeUtc($user.AccountExpires).ToLocalTime()
[PSCustomObject]@{
    Name = $user.Name
    ExpiryDate = $expirationDate
 }
    
}

$Expirydates



