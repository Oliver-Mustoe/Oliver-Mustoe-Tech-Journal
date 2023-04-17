# makes the groups mapped drives - currently sudo code

# Create the GPO
$gpo = New-GPO -Name MappedDrives -Comment "GPO to create groups mapped drives"
$gpo | new-gplink -target "OU=blue1,DC=blue1,DC=local"

$gpouid = '{}' + $gpo.ToString().ToUpper + '}'
# Get a ACL object with right permissions and owner/group (blue1 references would be changed for different domain)
# https://serverfault.com/questions/185192/is-there-a-way-to-create-acls-from-scratch-in-powershell-as-opposed-to-copying
$empty = New-Object System.Security.AccessControl.DirectorySecurity

# https://blog.netwrix.com/2018/04/18/how-to-manage-file-system-acls-with-powershell-scripts/
$AccessRule1 = New-Object System.Security.AccessControl.FileSystemAccessRule("BLUE1\Domain Admins","FullControl","Allow")
$AccessRule2 = New-Object System.Security.AccessControl.FileSystemAccessRule("BLUE1\Enterprise Admins","FullControl","Allow")  # User creating the GPO is a enterprise admin so this MAY affect this in a diff enviro!
$AccessRule3 = New-Object System.Security.AccessControl.FileSystemAccessRule("NT AUTHORITY\ENTERPRISE DOMAIN CONTROLLERS","ReadAndExecute","Allow","Synchronize")
$AccessRule4 = New-Object System.Security.AccessControl.FileSystemAccessRule("NT AUTHORITY\Authenticated Users","ReadAndExecute","Allow","Synchronize")
$AccessRule5 = New-Object System.Security.AccessControl.FileSystemAccessRule("NT AUTHORITY\SYSTEM","FullControl","Allow")
$AccessRule6 = New-Object System.Security.AccessControl.FileSystemAccessRule("BUILTIN\Administrators","FullControl","Allow")
$AccessRule7 = New-Object System.Security.AccessControl.FileSystemAccessRule("CREATOR OWNER","FullControl","Allow")
$owner = New-Object System.Security.Principal.Ntaccount("BUILTIN\Administrators")
$group = New-Object System.Security.Principal.Ntaccount("BLUE1\Domain Users")

$empty.SetAccessRule($AccessRule1)
$empty.SetAccessRule($AccessRule2)
$empty.SetAccessRule($AccessRule3)
$empty.SetAccessRule($AccessRule4)
$empty.SetAccessRule($AccessRule5)
$empty.SetAccessRule($AccessRule6)
$empty.SetAccessRule($AccessRule7)
$empty.SetOwner($owner)
$empty.SetGroup($group)

# Create the Drives folder and Drives.xml file (right permissions in acl) in the GPOs Users\Preference directory (blue1 references would be changed for different domain)
$DriveFolder = mkdir "\\blue1.local\SYSVOL\blue1.local\Policies\" + $gpouid + "User\Drives"
$DriveFolder | Set-Acl -AclObject $empty
$DriveXml = new-item "\\blue1.local\SYSVOL\blue1.local\Policies\" + $gpouid + "User\Drive\Drives.xml"
$DriveXml | Set-Acl -AclObject $empty


# Create a hashtable of the desired groups and their ssid's (https://stackoverflow.com/questions/3740128/pscustomobject-to-hashtable)
https://activedirectorypro.com/get-adgroup-examples/
$adgroups = Get-ADGroup -filter * -SearchBase "OU=Groups,OU=Accounts,OU=blue1,DC=blue1,DC=local" | select Name, SID
$GroupDrives = @{}
$adgroups | Foreach-Object { $GroupDrives[$_.Name] = $_.Value}

# Have the string that needs to be inputed, with variables where items need to be
$MapString = ""

# For every group in the GroupDrives
foreach ($group in $GroupDrives){
    # Create a uid
    $uid = [guid]::NewGuid()

    # Create a version of the string
    $GroupString = ""

    # Append the string to the second to last line in the Drives.xml file
}