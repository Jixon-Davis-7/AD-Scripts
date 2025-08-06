

#Credenetials
Connect-AzAccount | Out-Null


  $credAdmin = get-credential


#Function to pull the highest gidnumber value assigned on the access group..........................................................
function HighestGidNumber
{
    
$attribNam = "gidnumber"

# Query all user objects and retrieve the attribute
$AccessGroups = Get-ADGroup -Filter * -Properties $attribNam

# Initialize variables to store the highest digit value
$highestValue = -1

# Iterate through each user object
foreach ($AccessGroup in $AccessGroups) {
   
    $attributeValue = $AccessGroup.$attribNam

    # Check if the attribute value is a valid digit
    if ($attributeValue -match '\d+') {
        $digitValue = [int]$matches[0]

        # Check if the current digit value is higher than the highest recorded value
        if ($digitValue -gt $highestValue) {
            $highestValue = $digitValue
        }
    }
}
}




#Function to update unix attributes and adding into unix group "A_U_AllGroups"
function UnixAttributes
{
    #Checking the received highest gidnumber is assigned on any other group, if yes incrementing value untill the gidnumber is unique
    $gidnumber = $highestValue + "1"
    while (Get-ADGroup -Filter {gidNumber -eq $gidnumber}) {
        $gidnumber++
    }
    
    #UNIX Attributes
    $attributes = @{'gidNumber' = $gidnumber 
                    'msSFU30Name' = $gpname
                    'msSFU30NisDomain' = "ads" 
                   } 

Set-ADGroup -Identity $gpname -Replace $attributes -Credential $credAdmin -Verbose

Start-Sleep -Seconds 4

#Adding to Unix group
$group = "A_U_AllGroups"                 
Add-ADGroupMember -Identity $group -Members $gpname -Credential $credAdmin -Verbose
Start-Sleep -Seconds 4
}



# Function to pull current owners
function PullCurrentOwners 
{
  $gp = Get-ADGroup -Identity $gpname -Properties *

  if ($gp) 
  {
    $attributes = 16..24
    $attributenu = 16

    #Loop to pull attributes in sets of three
    for ($q = 1; $q -le 3; $q++) 
    {
      $attrIndex = ($q - 1) * 3 
      $currentAttrs = $attributes[$attrIndex..($attrIndex + 2)]  # Extract three attributes for each owner

      $cowner = Get-ADGroup -Identity $gpname -Properties * | ForEach-Object {
              $_.("msExchExtensionAttribute" + $currentAttrs[0]),
              $_.("msExchExtensionAttribute" + $currentAttrs[1]),
              $_.("msExchExtensionAttribute" + $currentAttrs[2])
          }
  
      Write-Host "  Owner $q attributes" -ForegroundColor Cyan
      Start-Sleep -Milliseconds 600

      foreach ($att in $cowner)
       {
        Write-Host "     msExchExtensionAttribute$attributenu : $att"
         $attributenu++
       }

       Start-Sleep -Milliseconds 800
       ''
    }
  }
}


# Function to update owner attributes
function UpdateOwnerAttributes 
{
  $UpdateOwnerAttributes = @{}
  $ClearOwnerAttributes = @()
  $Ownerupn = ""

  for ($o = 1; $o -le 3; $o++) 
  {
    $attributeNumbers = 16..24
    $attrIndex = ($o - 1) * 3
    $currentAttrs = $attributeNumbers[$attrIndex..($attrIndex + 2)]

    $Ownern = "Owner" + $o
    $Request = Read-Host "Update $Ownern attributes [U] / Remove existing owner attributes [R] / No change [N]"

    if ($Request -eq "U") 
    {
      $Ownerupn = Read-Host "Enter $Ownern UPN : " 
      try 
      {
        $User = Get-AzADUser -UserPrincipalName $Ownerupn -ErrorAction Stop
        if ($User)
        {
         $flag = "1"
         Write-Host "Updating $Ownern attributes" -ForegroundColor Yellow
         for ($u = 0; $u -le 2; $u++) 
         {
           $attributes = @("DisplayName", "Id", "UserPrincipalName")
           $attributeName = "msExchExtensionAttribute" + "$($currentAttrs[$u])"
           $UpdateOwnerAttributes.$attributeName = $User.$($attributes[$u])
         }
        }
        else 
        {
          Write-Host "No user found with UPN '$Ownerupn' or input value is empty" -ForegroundColor Red
        }
      } 
      catch 
      {
         Write-Host "No user found with UPN $Ownerupn" -ForegroundColor Red
      }
    } 
    elseif ($Request -eq "R") 
    {
      $flag = "1"
      Write-Host "Removing the $Ownern attributes"
      for ($u = 0; $u -le 2; $u++) 
      {
       $ClearOwnerAttributes += "msExchExtensionAttribute" + "$($currentAttrs[$u])"
        #$ClearOwnerAttributes.$attributeName
      }
    }
    elseif($Request -eq "N")
    {
      Write-Host "No change made for the '$Ownern' attributes" -ForegroundColor Yellow
    }
    else
    {
      Write-Host "Invalid input" -ForegroundColor DarkMagenta
    }
  }

  
  If($flag -eq "1")
  {
   try 
   {
     if ($UpdateOwnerAttributes.Count -gt 0) 
     {
       Set-ADGroup -Identity $gpname -Replace $UpdateOwnerAttributes -Credential $credAdmin -Verbose
     }
     if ($ClearOwnerAttributes.Count -gt 0) 
     {
       Set-ADGroup -Identity $gpname -Clear $ClearOwnerAttributes -Credential $credAdmin -Verbose
     }

    Write-Host "Request successful" -ForegroundColor Green
    Write-Host "Fetching updated owner attributes...." -ForegroundColor Green
    ''
    Start-Sleep -Seconds 15
    PullCurrentOwners 
   } 
   catch
   {
     Write-Host "Request unsuccessful: $($_.Exception.Message)" -ForegroundColor Red
   }
  } 
  else 
  {
    ''
    Write-Host "No inputs received. No changes made on the owner attributes" -ForegroundColor Yellow
  }
}



# Main script
try 
{
  $flag =""
  $gpname = Read-Host "Enter Group samaccountname"
  $gp = Get-ADGroup -Identity $gpname -Properties * -ErrorAction Stop
  $gpupn = $gp.ObjectClass

  if ($gpupn)
   {
     Write-Host "Unix attributes of the group $gpname" -ForegroundColor Yellow
     Start-Sleep -Seconds 1
     $groupproperties = [PSCustomObject]@{
        GroupName = $gp.samaccountname
        DN = $gp.distinguishedname
        msSFU30Name = $gp.msSFU30Name
        Gidnumber = $gp.Gidnumber
        msSFU30NisDomain = $gp.msSFU30NisDomain
        #Owner1 = $gp.msExchExtensionAttribute16
        #Owner2 = $gp.msExchExtensionAttribute19
        #Owner3 = $gp.msExchExtensionAttribute22
     }
     $groupproperties

     $update = Read-Host "Do you want to update Unix attributes of the group $gpname? - [Yes | No]"
     If($update -eq "Yes")
     {
        HighestGidNumber
        Start-Sleep -Seconds 2

        UnixAttributes
        Start-Sleep -Seconds 4

        Move-ADObject -Identity $gp.DistinguishedName -TargetPath "OU=Access,OU=Groups,OU=Objects,DC=ads,DC=autodesk,DC=com" -Credential $credAdmin -Verbose
           
        Start-Sleep -Seconds 6

        Get-ADGroup -Identity $gpname -Properties description, msExchExtensionAttribute16, msExchExtensionAttribute19, msExchExtensionAttribute22, distinguishedname, msSFU30Name, Gidnumber, msSFU30NisDomain |
        Select-Object -Property Name, distinguishedname, description, msSFU30Name, Gidnumber, msSFU30NisDomain, msExchExtensionAttribute16, msExchExtensionAttribute19, msExchExtensionAttribute22
        $updateowner = Read-Host "Do you want to update owners of the group? [Yes | No]:"
        If($updateowner -eq 'Yes')
        {
            PullCurrentOwners
            Start-Sleep -Milliseconds 800
            Write-Host "Current Owners of the Group '$gpname' listed above" -ForegroundColor Yellow
            Start-Sleep -Seconds 3
            ''
            ''
            Write-Host "Select: " -ForegroundColor Yellow
            Start-Sleep -Milliseconds 500
            Write-Host "  U - For updating the current owner attributes" -ForegroundColor Yellow
            Write-Host "  R - remove the existing owner attributes" -ForegroundColor Yellow
            Write-Host "  N - No need to make any change for the current owner attributes" -ForegroundColor Yellow
      
            UpdateOwnerAttributes

        }

     }
     else {
        Write-Host "No changes made to the attributes" -ForegroundColor Yellow
     }
     
  } 
  else 
  {
     Write-Host "No group found with name '$gpupn' in AD" -ForegroundColor Magenta
  }
} 
catch 
{
  Write-Host "No group found with the groupname '$gpname'" -ForegroundColor Red
}

