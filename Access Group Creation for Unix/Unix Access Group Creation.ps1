<#
  .SYNOPSIS
  Unix Access group Creation

  .DESCRIPTION
   Script will create Unix access group (A_U_Gitasmuser)
   Script will update the below mentioned unic attributes
     Gidnumber:  
     msSFU30Name: A_U_Gitasmuser
     msSFU30NisDomain: ads
     Memberof: A_U_AllGroups

The group will get created in the OU "OU=Access,OU=Groups,OU=Objects,DC=ads,DC=autodesk,DC=com"

#################################################################################################################################################>

Clear-Host
" _________________________________________________________________________________________________________________"
"                                              UNIX ACCESS GROUP CREATION                                          "
" _________________________________________________________________________________________________________________"

#Credenetials
#Connect-AzAccount | Out-Null

#if($env:USERNAME.contains("admin")){$us = $env:USERNAME}  else{ $us = "$($env:USERNAME)admin"}
#   $credAdmin = get-credential -Credential "ADS\$us" 


#Updating Owner attributes.......................................................................................
function UpdateOwnerAttributes 
{
  $UpdateOwnerAttributes = @{}
  $Ownerupn = ""
  
  #Updating each owner attributes as set of 3
  for ($o = 1; $o -le 3; $o++) {
   #Attribute number 16 to 24
   $attributeNumbers = 16..24
   $attrIndex = ($o - 1) * 3
   $currentAttrs = $attributeNumbers[$attrIndex..($attrIndex + 2)]
            
   $Ownern = "Owner" + $o
    $Ownerupn = Read-Host "Enter $Ownern UPN : " 
    try {
      $Ownerusr = Get-AzADUser -UserPrincipalName $Ownerupn -ErrorAction Stop
      if ($Ownerusr){
        Write-Host "Updating $Ownern attributes" -ForegroundColor Yellow
        #Updating Displayname, ID and UPN in on prem AD attributes 
        for ($u = 0; $u -le 2; $u++) {
          $attributes = @("DisplayName", "Id", "UserPrincipalName")
          $attributeName = "msExchExtensionAttribute" + "$($currentAttrs[$u])"
          $UpdateOwnerAttributes.$attributeName = $Ownerusr.$($attributes[$u])
          }
        }
        else {
          Write-Host "No user found with UPN '$Ownerupn' or input value is empty" -ForegroundColor Red
         }
        } 
        catch {
          Write-Host "No user found with UPN $Ownerupn or input value is empty" -ForegroundColor Red
        }
    } 

  try {
    if ($UpdateOwnerAttributes.Count -gt 0) {
      Set-ADGroup -Identity $gpname -Replace $UpdateOwnerAttributes -Credential $credAdmin
      }
      else { 
        ''
         Write-Host "No Owners provided" -ForegroundColor Magenta
       }
     ''
    } 
    catch {
      Write-Host "Owner update unsuccessful: $($_.Exception.Message)" -ForegroundColor Red
    }
}
            

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
                    'description' = $description
                    'msSFU30NisDomain' = "ads" 
                   } 

Set-ADGroup -Identity $gpname -Replace $attributes -Credential $credAdmin -Verbose

Start-Sleep -Seconds 4

#Adding to Unix group
$group = "A_U_AllGroups"                 
Add-ADGroupMember -Identity $group -Members $gpname -Credential $credAdmin -Verbose
Start-Sleep -Seconds 4
}




#MAIN SCRIPT
$groupnametocreate = Read-Host "Enter group name[post part after A_]"
$gpname = "A_" + $groupnametocreate

#Checking if group is existing or not
try
{
 Get-ADGroup -Identity $gpname -ErrorAction Stop
 Write-Host "Security group with name $gpname already exist. Provide a unique name" -ForegroundColor Yellow
}

catch
{
  $RITMnumber =  Read-Host "Enter ticket number"
  $description = $gpname + " " + "(" + $RITMnumber + ")"

 #Creating group
  Write-Host "Creating Security group $gpname " -ForegroundColor Green
  New-ADGroup -Name $gpname `
            -GroupScope Universal `
            -GroupCategory Security `
            -Path "OU=Access,OU=Groups,OU=Objects,DC=ads,DC=autodesk,DC=com" `
            -Description $description -Credential $credAdmin -Verbose -ErrorAction Stop

Start-Sleep -Seconds 10
HighestGidNumber
Start-Sleep -Seconds 3
UnixAttributes

Start-Sleep -Seconds 4
UpdateOwnerAttributes

Start-Sleep -Seconds 12
Write-Host "Access group $gpname created successfully" -ForegroundColor Green
''
Get-ADGroup -Identity $gpname -Properties description, msExchExtensionAttribute16, msExchExtensionAttribute19, msExchExtensionAttribute22, distinguishedname, msSFU30Name, Gidnumber, msSFU30NisDomain |
 Select-Object -Property Name, distinguishedname, description, msSFU30Name, Gidnumber, msSFU30NisDomain, msExchExtensionAttribute16, msExchExtensionAttribute19, msExchExtensionAttribute22

}
