#$accounts = Get-Content -Path "C:\Users\davisj1\VSCode\Pwshscripts_CPC\Files\Input2.txt"
$accounts = @("tst_q_qIIs_su1", "tst_q_qIIs_su2", "tst_q_qIIs_su3", "tst_q_qIIs_su4")

$expirationDate = Read-Host "Provide expiry date for the test account in format[YYYY-MM-DD].    example- [2024-12-31] :"
$expirationDate = [datetime]::ParseExact($expirationDate, "yyyy-MM-dd", $null)

$attributes = @{'accountexpires' = $expirationDate} 

Foreach($a in $accounts)
{
Set-ADUser -Identity $a -Replace $attributes -Credential $credAdmin -Verbose
Start-Sleep -Milliseconds 50
}