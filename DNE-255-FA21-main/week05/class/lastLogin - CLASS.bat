# Get the userprofile environment variable
$user = $ENV:USERPROFILE

# Get Current date and time
$theTime = Get-Date

# Write a message with the time to a file as a string.
echo “You logged in at: $theTime" | Out-File -Encoding ASCII -Append -FilePath “$user\Desktop\Login-time.txt"