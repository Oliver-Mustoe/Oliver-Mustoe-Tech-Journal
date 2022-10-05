# Send a file to a remote system

#Use the Set-SCPItem to SEND a file to a remote system
#You would use Get-SCPItem to download a file from a remote system
Set-SCPItem -ComputerName '10.0.5.4' (Get-Credential oliver) `
-Destination '/home/oliver' -Path '.\tosend.txt'