#!/bin/bash
# Version 0.1
# Description: Creates a simple Apache web server on a CentOS system

# Ask whether to disable root SSH
read -p "Would you like to disable root SSH? y/N: " prootssh

# Make answer uppercase
rootssh=${prootssh^^}

# If user answers "Y" or "YES" -
if [[ $rootssh == "Y" ]] || [[ $rootssh == "YES" ]]
then
    #- use sed to replace a certain string, after first /, with another string to not allow root login, after second /, to ssh_config
    sudo sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
    # After this process, restart sshd service
    sudo /etc/init.d/sshd restart
fi

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