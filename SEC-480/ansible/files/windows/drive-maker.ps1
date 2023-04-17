# makes the groups mapped drives - currently sudo code

# Create the GPO

# Create the Drives folder and Drives.xml file (right permissions in acl) in the GPOs Users\Preference directory

# Create a hashtable of the desired groups and their ssid's
$GroupDrives = @{}

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