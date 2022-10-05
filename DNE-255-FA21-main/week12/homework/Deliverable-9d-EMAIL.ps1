# Oliver Mustoe
# Objective: Parse through files containing threat intell and create rules based on the ips, then apply them to the workstation
# Array of websites containing threat intell
$drop_urls = @('https://www.projecthoneypot.org/list_of_ips.php?t=d','https://www.projecthoneypot.org/list_of_ips.php?t=s','https://www.projecthoneypot.org/list_of_ips.php?t=p')

# Lopp through the URLS for the rules list
foreach ($u in $drop_urls) {

    # Extract the filename
    $temp = $u.split("=")
   
    # The last element in the array plucked off is the filename with 'ProjHoney' added to the beginning
    $file_name = 'ProjHoney' + $temp[-1]

    if (Test-Path $file_name){

        continue

    } else {

        # Download the rules list
        Invoke-WebRequest -Uri $u -OutFile $file_name

    } # close if statement

} # close the foreach loop

# Array containing the filenames
$input_paths = @('.\ProjHoneyd','.\ProjHoneys','.\ProjHoneyp')

# Extract the IP addresses
# EX. 108.190.109.107
$regex_drop = '\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b'

# Append the IP addresses to the temporary IP list
Select-String -Path $input_paths -Pattern $regex_drop | `
ForEach-Object {$_.Matches } | `
ForEach-Object {$_.Value } | Sort-Object | Get-Unique | `
Out-File -FilePath "ips-bad.tmp"

# Get the IP addresses discoverd, loop through and replace the beginning of the line with the Windows syntax
# After the IP address, add the remaining Windows syntax and save the results to a .ps1 file.
(Get-Content -Path ".\ips-bad.tmp") | % `
{ $_ -replace "^",'netsh advfirewall firewall add rule name="IP Block" dir=in interface=any action=block remoteip=' -replace "$", "/32"} | `
Out-File -FilePath "Firewall-Rules.ps1"

# Delete all previous rules created by this code for repeated use of code (First use of code it will say that it can't find the criteria, this is to be expected)
netsh advfirewall firewall delete rule name="IP Block"

# Run the newly created .ps1 file
.\Firewall-Rules.ps1

# Sends Email to SMTP server indicating that Firewall-Rules.ps1 was created
if (Test-Path ".\Firewall-Rules.ps1") {

     # Send an email.
     Send-MailMessage -From "noreply@oliver.local" -To "oliver@oliver.local" `
     -Subject "Firewall has run." -Body "The Firewall update file has been run" -SmtpServer thrawn.oliver.local

     if ($?){

        echo "Email sent!!!"

     } else {

        echo "Error: Email has not been sent, something went wrong :(!!!!!"

     }

} # End of test-path

<# Sources:
https://superuser.com/questions/1237979/netsh-advfirewall-firewall-delete-rule-name-program-syntax-not-working
#>