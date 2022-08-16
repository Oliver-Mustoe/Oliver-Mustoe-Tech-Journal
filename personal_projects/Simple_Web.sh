#!/bin/bash
# Version 0.7
# Description: Creates a simple Apache web server on a CentOS & Ubunut server systems

# Ask whether to disable root SSH
read -p "Would you like to disable root SSH? y/N: " prootssh

# Make answer uppercase
rootssh=${prootssh^^}

# If user answers "Y" or "YES" -
if [[ $rootssh == "Y" ]] || [[ $rootssh == "YES" ]]
then
    #- use sed to replace a certain string, after first /, with another string to not allow root login, after second /, to a tmp copy of "sshd_config.d", then make that copy and make it the original, delete the copy
    sudo su -c "sed 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config.d > /etc/ssh/sshd_config.d.tmp && mv /etc/ssh/sshd_config.d.tmp /etc/ssh/sshd_config.d && rm -f /etc/ssh/sshd_config.d.tmp"
    # ^ needs to be done this way for sed to work
    # After this process, restart sshd service
    sudo /etc/init.d/sshd restart
fi

# Test if the result of the command "$(which yum)" as a string is non-zero, -n, if so do yum installation
if [[ -n "$(which yum)" ]]
then
    # Install and start webserver; setup firewall with port 80 open; and make an example "index.html" file as sudo
    sudo su -c "yum install httpd && \
    systemctl start httpd && \
    firewall-cmd --permanent --add-port=80/tcp && \
    firewall-cmd --reload && \
    echo '<html>
    <head>
    <style>
    h1 {text-align: center;}
    p {text-align: center;}
    </style>
    </head>
    <h1>TEST FOR WEBSITE</h1>
    <p>If you are seeing this the webserver works!!!</p>
    </html>

    ' > /var/www/html/index.html"

# Test if the result of the command "$(which apt)" as a string is non-zero, -n, if so do yum installation
elif [[ -n "$(which apt)" ]]
then
    # Install and start webserver; setup firewall with port 80 open; and make an example "index.html" file as sudo
    sudo su -c "apt update && \
    apt install apache2 && \
    ufw enable && ufw allow 'Apache' && \
    echo '<html>
    <head>
    <style>
    h1 {text-align: center;}
    p {text-align: center;}
    </style>
    </head>
    <h1>TEST FOR WEBSITE</h1>
    <p>If you are seeing this the webserver works!!!</p>
    </html>

    ' > /var/www/html/index.html"

else
echo "ERROR: not running a supported OS, Debian or "
fi

# Find full IPv4 & IPV6, then cut using space in the first instance (which will leave us with just IPv4)
hostip=$(hostname -I | cut -d " " -f 1)

echo "



Website should now be accessible @ 'http://${hostip}'
"