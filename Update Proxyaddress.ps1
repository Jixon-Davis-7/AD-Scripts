New-ADObject -Name "Ram Krishnan" -Type contact -Path "OU=Contacts,OU=Objects,DC=ads,DC=autodesk,DC=com" -OtherAttributes @{'mail'="R2krish71@yahoo.com"; 'displayName'="Ram Krishnan"; 'givenName'='Ram';'sn'= 'Krishnan'; 'description'='Requested:RITM2234869'} -Credential $credDA



$contactDN = "CN=Ram Krishnan,OU=Contacts,OU=Objects,DC=ads,DC=autodesk,DC=com"
Set-ADObject -Identity $contactDN -Add @{proxyAddresses="SMTP:R2krish71@yahoo.com"} -Credential $credDA




# Define the group and the contact objects (using their Distinguished Names)
$groupName = "org-board"
$contacts = @(
    "CN=Ram Krishnan,OU=Contacts,OU=Objects,DC=ads,DC=autodesk,DC=com",
    "CN=John Cahill,OU=Contacts,OU=Objects,DC=ads,DC=autodesk,DC=com"
)

# Add the contact objects to the group
Add-ADGroupMember -Identity $groupName -Members $contacts -Credential $credDA
