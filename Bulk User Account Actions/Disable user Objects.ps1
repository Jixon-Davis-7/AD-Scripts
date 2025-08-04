
$Useraccounts= Get-Content -Path "C:\Users\davisj1\VSCode\Pwshscripts_CPC\Files\Input.txt"
$Ofilepath = "C:\Users\davisj1\VSCode\Pwshscripts_CPC\Files\Output.xlsx"

$successfull = $failed = @()
Import-Module ImportExcel

foreach($User in $Useraccounts)
{
  try
  {  
    $Useracc = (Get-ADUser -Identity $User).distinguishedName
    Disable-ADAccount -Identity $Useracc -Credential $credAdmin -ErrorAction Stop -Verbose
    Write-Host "Disabled $($User)" -ForegroundColor Green
    $successfull += $User
  }
  catch
{
    Write-Host "failed $($User)" -ForegroundColor Magenta
    $failed += $User
}
}


$successfull | Export-Excel -Path $Ofilepath -WorksheetName "Disabled Successfull"
$failed   | Export-Excel -Path $Ofilepath -WorksheetName "Failed"

