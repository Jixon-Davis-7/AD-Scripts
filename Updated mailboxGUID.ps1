# Convert string GUID to binary
$guid = [Guid]::Parse("0a60a5fc-6f9d-474f-ac66-d4fafd591a08")
$binaryGuid = $guid.ToByteArray()

# Update the msExchMailboxGuid attribute
Set-ADUser -Identity "galla" -Replace @{msExchArchiveGUID=$binaryGuid} -Credential $credAdmin -Verbose


# Convert string GUID to binary
#$deci = 252,165,96,10,157,111,79,71,172,102,212,250,253,89,26,8
#$hex = [System.Guid]::New([Byte[]]$deci)

#[System.Guid]::New([Byte[]]$bg)