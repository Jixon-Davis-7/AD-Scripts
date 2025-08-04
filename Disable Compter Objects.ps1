
$ComputerObjects = Get-Content -Path "C:\Users\davisj1\VSCode\Pwshscripts_CPC\Files\Input.txt"

foreach($Object in $ComputerObjects)
{
  try
  {  
    $Computer = (Get-ADComputer -Identity $Object).distinguishedName
    Disable-ADAccount -Identity $Computer -Credential $credDA -ErrorAction Stop
    Write-Host "Disabled $($Object)" -ForegroundColor Green
  }
  catch
{
    Write-Host "failed $($Object)" -ForegroundColor Magenta
}
}


