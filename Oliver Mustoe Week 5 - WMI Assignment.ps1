# Oliver Mustoe
# Task: To grab the network adapter information using the WMI classes, then print that information to the screen.
# Get the following information: IP address, default gateway, and the DNS servers.
# BONUS: get the DHCP server.
# Post code to pineapple.
# Running your code using a screen recorder, like screencastify.

# First I create an array of all the information I want to grab
$infoGrab = @(
'IPAddress',
'DefaultIPGateway',
'DNSServerSearchOrder',
'DHCPServer'
)


# I then used the WMIObject cmdlet to call on a specific class, win32_networkadapterconfiguration, and filtered the index by 1 as it was my network adapters index number. I then piped that into the Object cmdlet where I selected the information from $infoGrab.
Get-WmiObject -Class win32_networkadapterconfiguration -Filter "index = 1" | Select-Object $infoGrab



# SOURCES: 
# https://www.varonis.com/blog/powershell-array/
# https://docs.microsoft.com/en-us/windows/win32/cimwin32prov/win32-networkadapterconfiguration
# https://devblogs.microsoft.com/scripting/using-powershell-to-find-connected-network-adapters/