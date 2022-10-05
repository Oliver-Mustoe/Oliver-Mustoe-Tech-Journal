# Create an array of IPs
$to_ping = @('10.0.5.2','10.0.5.3','10.0.5.4','10.0.5.5','10.0.5.6')

# Loop through the array
foreach ($ip in $to_ping) {

    # Ping each host
    $the_ping = Test-Connection -ComputerName $ip -quiet -Count 1

    # Check the status of the ping for each host
    if ($the_ping) {
    
        # Host is up
        write-host -BackgroundColor Green -ForegroundColor white "$ip is up."
    
    } else {

        # Output the results if it is down to an file
        echo "$ip is down." | Out-File -Append -FilePath ".\host-down.txt"
    
    
    }

}

# Check whether to send an email ONLY if host-down.txt exists.
if (Test-Path ".\host-down.txt") {

     # Send an emial with the host-down.txt attachment.
     Send-MailMessage -From "noreply@oliver.local" -To "oliver@oliver.local" `
     -Subject "Host Report." -Body "Attached report for hosts that are down." `
     -Attachments ".\host-down.txt" -SmtpServer mail01.oliver.local

     if ($?){

        echo "Email sent!!!"

     } else {

        echo "Error: Email has not been sent!!!!!"

     }

    # Delete host-down.txt
    Remove-Item ".\host-down.txt"

} # End of test-path