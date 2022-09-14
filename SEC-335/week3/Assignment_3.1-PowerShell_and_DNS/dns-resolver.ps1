#!/usr/bin/env pwsh

# Take network prefix and dns server
# Example run: .\dns-resolver.ps1 192.168.3 192.168.4.5
param($netprefix,$dns)

for ($prefix=1;$prefix -lt 255;$prefix++){
    # Get full IP
    $IP="$netprefix.$prefix"
    # Find the name, will throwout errors, use "Select-Object -ExpandProperty Namehost" to just get the name
    $DNS_Name=Resolve-DnsName -DnsOnly $IP -Server $dns -ErrorAction Ignore | Select-Object -ExpandProperty Namehost

    # If there is something in $DNS_Name, aka there was no errors in the above command
    if ($DNS_Name -ne $null){
    echo "$IP  $DNS_Name"
    }# End of If statement

}# End of for loop
