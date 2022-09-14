#!/usr/bin/env pwsh

# Take network prefix and dns server
# Example run: .\dns-resolver.ps1 192.168.3 192.168.4.5

$netprefix=$args[0]
$dns=$args[1]
echo "$netprefix $dns"

for ($prefix=1;$prefix -lt 255;$prefix++){

Resolve-DnsName -DnsOnly $netprefix.$prefix -Server $dns -ErrorAction Ignore 

# |Select-Object Name, Namehost | Format-Table @{L='Reverse-Query';E={$_.Name}}, @{L='DNS_Name';E={$_.Namehost}}
}# End of for loop
