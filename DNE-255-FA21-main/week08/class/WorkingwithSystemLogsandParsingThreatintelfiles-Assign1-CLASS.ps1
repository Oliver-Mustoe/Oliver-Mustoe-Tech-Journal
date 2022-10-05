# Review Security event log

# Directory to save files to:

$myDir = "C:\Users\oliver.mustoe\Desktop"

# List all Windows Event logs that are available
Get-EventLog -List

# Create a prompt to allow users to select which event log they want to review
$readlog = Read-host -Prompt "Please a select a log to review from the list above"

# Print results for the log
Get-EventLog -LogName $readlog -Newest 40 | where {$_.Message -ilike "*special privileges*"} | Export-Csv -NoTypeInformation `
-Path "$myDir\securityLogs.csv"