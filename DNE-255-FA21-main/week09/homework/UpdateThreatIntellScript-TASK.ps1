<# Name: Oliver Mustoe
Task: Use a switch statement to create an IPTables ruleset, Cisco ruleset, and Windows firewall ruleset with the assignment from today's class that blocks the IPs.  The flow will be to:
a. extract and parse the IPs (which we did in class).
b. Add prompt to select which ruleset to generate.
c. Print the ruleset out.
Include this URL in the list to parse: https://feodotracker.abuse.ch/downloads/ipblocklist_recommended.txt
#>

# Array of websites containing threat intell
$drop_urls = @('http://rules.emergingthreats.net/blockrules/emerging-botcc.rules','http://rules.emergingthreats.net/blockrules/compromised-ips.txt','https://feodotracker.abuse.ch/downloads/ipblocklist_recommended.txt')

# Lopp through the URLS for the rules list
foreach ($u in $drop_urls) {

    # Extract the filename
    $temp = $u.split("/")
   
    # The last element in the array plucked off is the filename
    $file_name = $temp[-1]

    # Test to see whether to download ruleset or not
    if (Test-Path $file_name){

        continue

    } else {

        # Download the rules list
        Invoke-WebRequest -Uri $u -OutFile $file_name

    } # close if statement

} # close the foreach loop

# Array containing the filename
$input_paths = @('.\compromised-ips.txt','.\emerging-botcc.rules')

# Extract the IP addresses
$regex_drop = '\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b'

# Append the IP addresses to the temporary IP list
Select-String -Path $input_paths -Pattern $regex_drop | `
ForEach-Object {$_.Matches } | `
ForEach-Object {$_.Value } | Sort-Object | Get-Unique | `
Out-File -FilePath "ips-bad.tmp"

# Prompts user to ask for a ruleset
$selectResult = Read-host -Prompt "Please a select a ruleset to use (IPTables, Cisco, Windows firewall)"

<#Then a switch command takes the user responses content and loops it through and replaces the beginning of the line, and the end if need be, 
with the approprate syntax (IPTables, Cisco, Windows firewall) #>
switch ($selectResult) {

    # IPTables ruleset
    # iptables -A INPUT -s <IP ADDRESS> -j DROP
    'iptables' {$ruleSelection = (Get-Content -Path ".\ips-bad.tmp") | % { $_ -replace "^","iptables -A INPUT -s " -replace "$", " -j DROP"}}

    # Cisco ruleset
    # access-list 1 deny host <IP ADDRESS>
    'cisco' {$ruleSelection = (Get-Content -Path ".\ips-bad.tmp") | % { $_ -replace "^","access-list 1 deny host "}}

    # Windows ruleset, single quotes for front of the line since double conflicts with the string
    # netsh advfirewall firewall add rule name="IP Block" dir=in interface=any action=block remoteip=<IP ADDRESS>/32
    'windows firewall' {$ruleSelection = (Get-Content -Path ".\ips-bad.tmp") | % { $_ -replace "^",'netsh advfirewall firewall add rule name="IP Block" dir=in interface=any action=block remoteip=' -replace "$", "/32"}}
    
    # Default informs user that there is an error with their selection and to re-run the code
    default {'ERROR - That selection does not exist, please re-run the code'}

} # End of switch statement

# Save results to file
Out-File -FilePath "ruleset.bash" -InputObject $ruleSelection

# Prompt user if they want to send to remote system
$P_remotesys = Read-Host -Prompt "Do you want to send the ruleset to a remote system? (Y for yes or N for no)"

# Switch statement see if should send ruleset.bash to remote system or not
switch ($P_remotesys) {
    
    # Send 'ruleset.bash' file to remote host if user chooses y (yes)
    'y' {
        # Prompts user for a remote system IP/Hostname
        $P_host = Read-Host -Prompt "Please enter a remote system you wish to connect to (either IP or system hostname)"

        # Prompts for a directory to store rulset
        $P_Dest = Read-Host -Prompt "Please enter where you want the ruleset to be saved (EX. /home/oliver)"
        
        # Uses $P-host to connect to a remote system and asks the user to fill out the prompt popup, $P_Dest is used as the save location
        Set-SCPItem -ComputerName $P_host (Get-Credential) -Destination $P_Dest -Path '.\ruleset.bash'
         

    }# End of y

    # If user selects not to send file, n (No), do nothing (Message seprate from default so user knows they picked no)
    'n' {"File has been saved"}

    # Informs user that that there has been an error with there selection, the file has been saved and nothing else
    default {"ERROR - RULESET HAS BEEN SAVED BUT NOT SENT ANYWHERE"}

} # End of switch statement


<#
SOURCES:
https://powershellexplained.com/2018-01-12-Powershell-switch-statement/
https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/out-file?view=powershell-7.1#examples
#>