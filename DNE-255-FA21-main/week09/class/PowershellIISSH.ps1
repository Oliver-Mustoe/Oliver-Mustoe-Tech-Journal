# Create a new SSH session
New-SSHSession -ComputerName '10.0.5.4' -Credential (get-credential)

# Run infintely
while ($true){
    # Create a prompt for the command
    $the_cmd = Read-Host -Prompt "Please enter a command"

    # Look for the keyword exit and stop executing
    # or it will run the command using invoke-sshcommand below
    if ($the_cmd -eq "exit") {

        break

    }

    # Run a command on the remote system
    (Invoke-SSHCommand -index 0 $the_cmd).output

}