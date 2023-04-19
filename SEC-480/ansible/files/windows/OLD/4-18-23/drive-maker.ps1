# makes the groups mapped drives - working - cleanup and test on a fresh enviro - MAY NEED TO RESTART WORKSTATION TO TAKE AFFECT

# Set gpo name (doubles as a funny counter for how many times I have tried this script :))
$GpoName = "MappedDrives15"
# Create the GPO
Write-host "[Creating $GpoName]"
$gpo = New-GPO -Name $GpoName -Comment "GPO to create groups mapped drives"
new-gplink -Name $gpo.DisplayName -target "OU=blue1,DC=blue1,DC=local"

# Make the GPO path
$gpouid = '{' + $gpo.Id.ToString().ToUpper() + '}'
# $gpouid = $gpo.Id.ToString().ToUpper()
$GpoPath = "\\blue1.local\SYSVOL\blue1.local\Policies\$gpouid"

# Get a ACL object with right permissions and owner/group (blue1 references would be changed for different domain)
# https://serverfault.com/questions/185192/is-there-a-way-to-create-acls-from-scratch-in-powershell-as-opposed-to-copying
Write-host "[Creating blank ACL]"
$empty = New-Object System.Security.AccessControl.DirectorySecurity

# https://blog.netwrix.com/2018/04/18/how-to-manage-file-system-acls-with-powershell-scripts/
# $AccessRule1 = New-Object System.Security.AccessControl.FileSystemAccessRule("BLUE1\Domain Admins","FullControl","Allow")
# $AccessRule2 = New-Object System.Security.AccessControl.FileSystemAccessRule("BLUE1\Enterprise Admins","FullControl","Allow")  # User creating the GPO is a enterprise admin so this MAY affect this in a diff enviro!
# $AccessRule3 = New-Object System.Security.AccessControl.FileSystemAccessRule("NT AUTHORITY\ENTERPRISE DOMAIN CONTROLLERS","ReadAndExecute","Allow")
# $AccessRule4 = New-Object System.Security.AccessControl.FileSystemAccessRule("NT AUTHORITY\Authenticated Users","ReadAndExecute","Allow")
# $AccessRule33 = New-Object System.Security.AccessControl.FileSystemAccessRule("NT AUTHORITY\ENTERPRISE DOMAIN CONTROLLERS","Synchronize","Allow")
# $AccessRule44 = New-Object System.Security.AccessControl.FileSystemAccessRule("NT AUTHORITY\Authenticated Users","Synchronize","Allow")
# $AccessRule5 = New-Object System.Security.AccessControl.FileSystemAccessRule("NT AUTHORITY\SYSTEM","FullControl","Allow")
# $AccessRule6 = New-Object System.Security.AccessControl.FileSystemAccessRule("BUILTIN\Administrators","FullControl","Allow")
$AccessRule7 = New-Object System.Security.AccessControl.FileSystemAccessRule("CREATOR OWNER","FullControl","Allow")
$owner = New-Object System.Security.Principal.Ntaccount("BUILTIN\Administrators")
$group = New-Object System.Security.Principal.Ntaccount("BLUE1\Domain Users")

# $empty.SetAccessRule($AccessRule1)
# $empty.SetAccessRule($AccessRule2)
# $empty.SetAccessRule($AccessRule3)
# $empty.SetAccessRule($AccessRule4)
# $empty.SetAccessRule($AccessRule33)
# $empty.SetAccessRule($AccessRule44)
# $empty.SetAccessRule($AccessRule5)
# $empty.SetAccessRule($AccessRule6)
$empty.SetAccessRule($AccessRule7)
$empty.SetOwner($owner)
$empty.SetGroup($group)

# Create the Drives folder and Drives.xml file (right permissions in acl) in the GPOs Users\Preference directory (blue1 references would be changed for different domain) https://stackoverflow.com/questions/6573308/removing-all-acl-on-folder-with-powershell
Write-host "[Creating Drives folder]"
$DriveFolder = mkdir "$GpoPath\User\Preferences\Drives"
$folderacl = Get-Acl "$GpoPath\User\Preferences\Drives"
$folderacl.Access | ForEach-Object{$folderacl.RemoveAccessRule($_)}
$DriveFolder | Set-Acl -AclObject $empty
Write-host "Creating Drives.xml"
$DriveXml = new-item "$GpoPath\User\Preferences\Drives\Drives.xml" -ItemType File
$xmlacl = Get-Acl "$GpoPath\User\Preferences\Drives"
$xmlacl.Access | ForEach-Object{$xmlacl.RemoveAccessRule($_)}
$DriveXml | Set-Acl -AclObject $empty
# $BasicString = @'
# <?xml version="1.0" encoding="utf-8"?>
# <Drives clsid="{8FDDCC1A-0C3C-43cd-A6B4-71A6DF20DA8C}">
# </Drives>
# '@

# Write-host "[Setting Drives.xml basic structure]"
# $BasicString > "$GpoPath\User\Drives\Drives.xml"


# Create a hashtable of the desired groups and their ssid's (https://stackoverflow.com/questions/3740128/pscustomobject-to-hashtable)
# https://activedirectorypro.com/get-adgroup-examples/
Write-host "[Getting groups]"
$adgroups = Get-ADGroup -filter * -SearchBase "OU=Groups,OU=Accounts,OU=blue1,DC=blue1,DC=local" | Select-Object Name, SID
# $GroupDrives = @{}
# $adgroups | Foreach-Object { $GroupDrives[$_.Name] = $_.SID}

# Have the string that needs to be inputed, with variables where items need to be
$MapString = ''

$adgroups | Foreach-Object {
    $name = $_.Name
    $uid = [guid]::NewGuid().ToString().ToUpper()
    $sid = $_.SID
    $datetime = (get-date).ToString("yyyy-MM-dd HH:mm:ss")
    # $GroupString = '<Drive clsid="{935D1B74-9CB8-4e3c-9914-7DD559B7A417}" name="Z:" status="Z:" image="2" changed="' + $datetime + '" uid="{' + $uid + '}" userContext="1" bypassErrors="1"><Properties action="U" thisDrive="NOCHANGE" allDrives="NOCHANGE" userName="" path="\\fs-blue1\' + $name + ' share" label="" persistent="0" useLetter="1" letter="Z"/><Filters><FilterGroup bool="AND" not="0" name="BLUE1\' + $name +'" sid="' + $sid +'" userContext="1" primaryGroup="0" localGroup="0"/></Filters></Drive> `r`n'  # `n to indicate newline
    $GroupString = '<Drive clsid="{935D1B74-9CB8-4e3c-9914-7DD559B7A417}" name="Z:" status="Z:" image="2" changed="' + $datetime + '" uid="{' + $uid + '}" userContext="1" bypassErrors="1"><Properties action="U" thisDrive="NOCHANGE" allDrives="NOCHANGE" userName="" path="\\fs-blue1\' + $name + ' share" label="" persistent="0" useLetter="1" letter="Z"/><Filters><FilterGroup bool="AND" not="0" name="BLUE1\' + $name +'" sid="' + $sid +'" userContext="1" primaryGroup="0" localGroup="0"/></Filters></Drive>' + "`r`n"  # `n to indicate newline
    Write-host "[Creating $name entry]"
    Write-host "[$sid]"
    $MapString += $GroupString
}

#https://stackoverflow.com/questions/31957901/add-content-append-to-specific-line
# Write-Host $MapString
Write-host "[Setting the xml file to the new entires!]"
$FullString = @'
<?xml version="1.0" encoding="utf-8"?>
<Drives clsid="{8FDDCC1A-0C3C-43cd-A6B4-71A6DF20DA8C}">
'@ + "`r`n" + $MapString + '</Drives>'
# Write-Host $FullString
Set-Content -Path "$GpoPath\User\Preferences\Drives\Drives.xml" $FullString

# $FileContent = Get-Content -Path "$GpoPath\User\Drives\Drives.xml"
# $FileContent[-1] = "{0}`r`n{1}" -f $fileContent[-1],$MapString

# $FileContent | Set-Content "$GpoPath\User\Drives\Drives.xml"

# # For every group in the GroupDrives
# foreach ($group in $GroupDrives){
#     # Create a uid
#     $uid = [guid]::NewGuid()

#     # Create a version of the string
#     $GroupString = ""

#     # Append the string to the second to last line in the Drives.xml file
# }