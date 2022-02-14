#!/bin/sh
#secure.ssh.sh
#Author: oliver
#Creates a new ssh user
#Adds a public key from the local repo

# Prompts the user for a username
read -p "Please enter your desired username here": USERNAME

# Looksup username to see if there is an entry, variable will be empty if an entry does not exist
USER_CHECK=$(sudo getent passwd ${USERNAME})

# See if the name does not have an entry, if it does skips the user creation part.
if [ -z "$USER_CHECK" ]
then
	# Create the user and it's dependencies
	sudo useradd -m -d /home/$USERNAME -s /bin/bash $USERNAME
else
	echo "$USERNAME already exists, skipping to configuration"
fi

# Make a directory for ssh ("-p" so it already exists skip)
sudo mkdir -p /home/$USERNAME/.ssh

# Copy over the id_rsa.pub key (overwrites each time, but if this key is changed then this is beneficial and needed)
sudo cp ~/Oliver-Mustoe-Tech-Journal/SYS265/linux/public-keys/id_rsa.pub /home/$USERNAME/.ssh/authorized_keys

# Adds appropriate permissions
sudo chmod 700 /home/$USERNAME/.ssh
sudo chmod 600 /home/$USERNAME/.ssh/authorized_keys

# Changes the group
sudo chown -R $USERNAME:$USERNAME /home/$USERNAME/.ssh

# Send a message that the process is complete!!!
echo "Done :)"
