# Oliver Mustoe
# Check Tech Journal entry for SYS265 assignment "AD-GPO" for sources
# Script to create an OU "Software Deploy", check if "Test OU" exists, if it does then move the user account and computer that was placed in it to "Software Deploy" and remove "Test OU"

# Create new OU, with results, will give an error if it does exist
New-ADOrganizationalUnit -Name "Software Deploy" -Path "DC=oliver,DC=local" -PassThru

# Check if "Test OU" exists, and if it does, perform certain actions
if ([adsi]::Exists("LDAP://OU=Test OU,DC=oliver,DC=local"))
{   # If "True", move objects out
    Move-ADObject -Identity "CN=oliver.mustoe,OU=Test OU,DC=oliver,DC=local" -TargetPath "OU=Software Deploy,DC=oliver,DC=local" -PassThru
    Move-ADObject -Identity "CN=WKS01-OLIVER,OU=Test OU,DC=oliver,DC=local" -TargetPath "OU=Software Deploy,DC=oliver,DC=local" -PassThru

    # then remove "Test OU", MAKE SURE THAT NOTHING IMPORTANT WILL BE LEFT INSIDE (disable accidential deletion if need be)
    Get-ADOrganizationalUnit -Filter "Name -eq 'Test OU'" | Set-ADOrganizationalUnit -ProtectedFromAccidentalDeletion $false -PassThru
    Get-ADOrganizationalUnit -Filter "Name -eq 'Test OU'" | Remove-ADOrganizationalUnit -Recursive
}
else
{
    # If "False", then report unable to do anything
    echo("No OU to delete or move objects from :(")
}