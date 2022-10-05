# Name: Oliver Mustoe
# Task: Create a prompt that allows the user to specify a keyword or phrase to search on.

# Review Security event log

# Directory to save files to:
$myDir = "C:\Users\oliver.mustoe\Desktop"

# List all Windows Event logs that are available
Get-EventLog -List

# Create a prompt to allow users to select which event log they want to review
$readLog = Read-host -Prompt "Please a select a log to review from the list above"

# Create a prompt that allows the user to specify a keyword or phrase to search on.
$keyLog = Read-host -Prompt "Please specify a keyword or phrase to search on"

# Print results for the log
Get-EventLog -LogName $readLog -Newest 40 | where {$_.Message -ilike "*$keyLog*"} | Export-Csv -NoTypeInformation `
-Path "$myDir\securityLogs.csv"


