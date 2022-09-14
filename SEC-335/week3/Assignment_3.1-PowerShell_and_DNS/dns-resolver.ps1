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

# Sources:
# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_variables?view=powershell-7.2
# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_for?view=powershell-7.2
# https://stackoverflow.com/questions/48216173/how-can-i-use-a-shebang-in-a-powershell-script
# https://docs.microsoft.com/en-us/answers/questions/92154/how-to-check-a-value-is-that-null-in-powershell-sc.html
# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/select-object?view=powershell-7.2
# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/format-table?view=powershell-7.2
# https://devblogs.microsoft.com/scripting/powertip-customize-table-headings-with-powershell/
