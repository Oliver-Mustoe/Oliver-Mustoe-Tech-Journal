# Special thank yous to (Martin Binder)[https://social.technet.microsoft.com/profile/martin%20binder/] as he is the reason this got done!
# makes the groups mapped drives

# Set gpo name (doubles as a funny counter for how many times I have tried this script :))
$GpoName = "MappedDrives24"

# Test to see if designated GPO already exists
$testgpo = Get-GPOReport -Name $GpoName -ReportType xml

if ($null -eq $testgpo){
# Formatting is weird for the mult-line string below!
# Create the GPO
Write-host "[Creating $GpoName]"
$gpo = New-GPO -Name $GpoName -Comment "GPO to create groups mapped drives"
new-gplink -Name $gpo.DisplayName -target "OU=blue1,DC=blue1,DC=local"

# Make the GPO path
$gpouid = '{' + $gpo.Id.ToString().ToUpper() + '}'
$GpoPath = "\\blue1.local\SYSVOL\blue1.local\Policies\$gpouid"

# Get an ACL object with right permissions and owner/group (blue1 references would be changed for different domain)
# https://serverfault.com/questions/185192/is-there-a-way-to-create-acls-from-scratch-in-powershell-as-opposed-to-copying
Write-host "[Creating blank ACL]"
$empty = New-Object System.Security.AccessControl.DirectorySecurity

# https://blog.netwrix.com/2018/04/18/how-to-manage-file-system-acls-with-powershell-scripts/
$AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("CREATOR OWNER","FullControl","Allow")
$owner = New-Object System.Security.Principal.Ntaccount("BUILTIN\Administrators")
$group = New-Object System.Security.Principal.Ntaccount("BLUE1\Domain Users")

$empty.SetAccessRule($AccessRule)
$empty.SetOwner($owner)
$empty.SetGroup($group)

# Create the Drives folder and Drives.xml file (right permissions in acl) in the GPOs Users\Preference directory (blue1 references would be changed for different domain) https://stackoverflow.com/questions/6573308/removing-all-acl-on-folder-with-powershell
Write-host "[Creating Drives folder]"
$DriveFolder = mkdir "$GpoPath\User\Preferences\Drives"
$folderacl = Get-Acl "$GpoPath\User\Preferences\Drives"
$folderacl.Access | ForEach-Object{$folderacl.RemoveAccessRule($_)}
$DriveFolder | Set-Acl -AclObject $empty

Write-host "[Creating Drives.xml]"
$DriveXml = new-item "$GpoPath\User\Preferences\Drives\Drives.xml" -ItemType File
$xmlacl = Get-Acl "$GpoPath\User\Preferences\Drives\Drives.xml"
$xmlacl.Access | ForEach-Object{$xmlacl.RemoveAccessRule($_)}
$DriveXml | Set-Acl -AclObject $empty

# Get all of the groups in the groups OU
# https://activedirectorypro.com/get-adgroup-examples/
Write-host "[Getting groups]"
$adgroups = Get-ADGroup -filter * -SearchBase "OU=Groups,OU=Accounts,OU=blue1,DC=blue1,DC=local" | Select-Object Name, SID

# Have a blank string that will contain all of the drive entries
$MapString = ''

# for each of the groups, create a entry with correct variables (name,uid,sid,date of making)
$adgroups | Foreach-Object {
    $name = $_.Name
    $uid = [guid]::NewGuid().ToString().ToUpper()
    $sid = $_.SID
    $datetime = (get-date).ToString("yyyy-MM-dd HH:mm:ss")
    $GroupString = '<Drive clsid="{935D1B74-9CB8-4e3c-9914-7DD559B7A417}" name="D:" status="D:" image="2" changed="' + $datetime + '" uid="{' + $uid + '}" userContext="1" bypassErrors="1"><Properties action="U" thisDrive="NOCHANGE" allDrives="NOCHANGE" userName="" path="\\fs-blue1\' + $name + ' share" label="" persistent="0" useLetter="0" letter="D"/><Filters><FilterGroup bool="AND" not="0" name="BLUE1\' + $name +'" sid="' + $sid +'" userContext="1" primaryGroup="0" localGroup="0"/></Filters></Drive>' + "`r`n"  # `n to indicate newline
    Write-host "[Creating $name entry]"
    $MapString += $GroupString
}

# Input the created entries with the required clsid into the xml file
#https://stackoverflow.com/questions/31957901/add-content-append-to-specific-line
Write-host "[Setting the xml file to the new entires!]"
$FullString = @'
<?xml version="1.0" encoding="utf-8"?>
<Drives clsid="{8FDDCC1A-0C3C-43cd-A6B4-71A6DF20DA8C}">
'@ + "`r`n" + $MapString + '</Drives>'
Set-Content -Path "$GpoPath\User\Preferences\Drives\Drives.xml" $FullString

Write-Host "[Setting the GPO extension names]"
# Get the path (Named 21 in honor of the GPO that was tested to fix this problem)
$21path = Get-GPO -Name $GpoName | Select-Object -ExpandProperty Path
# Replace the paths extension names with the needed ones for drive mapping
Set-ADObject -Identity "$21path" -Replace @{gPCUserExtensionNames="[{00000000-0000-0000-0000-000000000000}{2EA1A81B-48E5-45E9-8BB7-A6E3AC170006}][{5794DAFD-BE60-433F-88A2-1A31939AC01F}{2EA1A81B-48E5-45E9-8BB7-A6E3AC170006}]"}

Write-Host "[Incrementing the version number]"
# Increment the version number (https://shellgeek.com/powershell-replace-line-in-file/)
$filecontent = Get-Content -Path "$GpoPath\GPT.INI" -Raw
# Replace a line in a file
$filecontent.Replace("Version=0","Version=262144") | Set-Content -Path "$GpoPath\GPT.INI"
# ^ Math behind this seems to be whenever you add drive map it increments by 262144, and since we are adding many at once it only requires one version increment (any value above 262144 may also be valid)
# Could also be specific to my enviro, best test would be creating a test gpo with a map drive > checking the gpos GPT.INI in the gpo path and seeing the version number (only create ONE drive)
}
else {
    Write-Host "$GpoName already exists!"
}
Write-Host "[DONE]"